"""Real WebGL rendering and touch controls in Chromium mobile emulation.

Requires playwright and Pillow; serve build/web first, or pass a deployed URL.
This test does not replace testing on a physical phone.
"""

import argparse
import io
import shutil
from pathlib import Path

from PIL import Image, ImageChops
from playwright.sync_api import sync_playwright


def run(url: str, output: Path) -> None:
    output.mkdir(parents=True, exist_ok=True)
    with sync_playwright() as playwright:
        browser = playwright.chromium.launch(
            executable_path=shutil.which("chromium") or shutil.which("google-chrome"),
            headless=True,
            args=[
                "--no-sandbox",
                "--use-gl=angle",
                "--use-angle=swiftshader",
                "--enable-unsafe-swiftshader",
                "--disable-dev-shm-usage",
            ],
        )
        device = dict(playwright.devices["Pixel 7"])
        device["device_scale_factor"] = 1
        context = browser.new_context(**device)
        page = context.new_page()
        errors = []
        failed_resources = []
        page.on("pageerror", lambda error: errors.append(str(error)))
        page.on("console", lambda message: errors.append(message.text)
                if message.type == "error" and "404" not in message.text else None)
        page.on("response", lambda response: failed_resources.append(response.url)
                if response.status >= 400 and not response.url.endswith("favicon.ico") else None)
        page.goto(url, wait_until="load")
        page.locator("#status").wait_for(state="detached", timeout=90000)
        page.wait_for_timeout(200)
        viewport = page.viewport_size
        scale = min(viewport["width"] / 720, viewport["height"] / 1080)
        offset_x = (viewport["width"] - 720 * scale) / 2
        offset_y = (viewport["height"] - 1080 * scale) / 2

        def point(x, y):
            return {"x": offset_x + x * scale, "y": offset_y + y * scale}

        def screenshot(name):
            data = page.screenshot(path=str(output / name))
            return Image.open(io.BytesIO(data)).convert("RGB")

        def player_x(image):
            locations = []
            for y in range(int(offset_y + 810 * scale), int(offset_y + 895 * scale)):
                for x in range(viewport["width"]):
                    r, g, b = image.getpixel((x, y))
                    if 50 < r < 140 and g > 190 and b > 190:
                        locations.append(x)
            assert locations, "Le personnage doit être dessiné dans le canvas WebGL"
            return sum(locations) / len(locations)

        cdp = context.new_cdp_session(page)

        def hold(x, y, duration=300):
            cdp.send("Input.dispatchTouchEvent", {
                "type": "touchStart", "touchPoints": [point(x, y)]
            })
            page.wait_for_timeout(duration)
            cdp.send("Input.dispatchTouchEvent", {"type": "touchEnd", "touchPoints": []})
            page.wait_for_timeout(100)

        initial = screenshot("mobile-start.png")
        start_x = player_x(initial)
        hold(90, 1000)
        moved_left = screenshot("mobile-left.png")
        left_x = player_x(moved_left)
        assert left_x < start_x - 20, "Le bouton tactile gauche doit déplacer le personnage"
        hold(630, 1000)
        moved_right = screenshot("mobile-right.png")
        assert player_x(moved_right) > left_x + 20, "Le bouton tactile droit doit déplacer le personnage"
        hold(620, 43, duration=60)
        paused = screenshot("mobile-paused.png")
        page.wait_for_timeout(350)
        paused_again = screenshot("mobile-paused-still.png")
        assert ImageChops.difference(paused, paused_again).getbbox() is None, "La pause tactile doit figer le niveau"
        hold(620, 43, duration=60)
        hold(90, 1000)
        resumed = screenshot("mobile-resumed.png")
        assert player_x(resumed) < player_x(paused) - 20, "La reprise tactile doit permettre de bouger"
        def bullets(image):
            count = 0
            for y in range(int(offset_y + 350 * scale), int(offset_y + 810 * scale)):
                for x in range(viewport["width"]):
                    r, g, b = image.getpixel((x, y))
                    if r > 250 and 215 <= g <= 225 and 128 <= b <= 140:
                        count += 1
            return count
        hold(360, 1000, duration=60)
        page.wait_for_timeout(900)
        stopped = screenshot("mobile-fire-off.png")
        assert bullets(stopped) == 0, "Couper le tir doit arrêter les projectiles"
        hold(360, 1000, duration=60)
        page.wait_for_timeout(250)
        firing = screenshot("mobile-fire-on.png")
        assert bullets(firing) > 0, "Réactiver le tir doit recréer des projectiles"
        assert not errors, errors
        assert not failed_resources, failed_resources
        print("Web mobile : WebGL chargé, gauche/droite, pause/reprise et activation du tir vérifiées ; aucune erreur JS ou ressource manquante.")
        print(f"Captures : {output}")
        browser.close()


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("url", nargs="?", default="http://127.0.0.1:8000/")
    parser.add_argument("--output", type=Path, default=Path("/tmp/math-runner-web-check"))
    arguments = parser.parse_args()
    run(arguments.url, arguments.output)
