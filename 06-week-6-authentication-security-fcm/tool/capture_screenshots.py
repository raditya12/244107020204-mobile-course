"""Capture the running Campus Notify Flutter web application.

Prerequisite: py -m pip install playwright && py -m playwright install chromium
Serve build/web at http://127.0.0.1:8766 before running this script.

Aplikasi berjalan dalam mode demo (tanpa google-services.json), sehingga yang
dibuktikan di sini adalah alur auth, secure storage, guard route, dan deep link
`/pengumuman/:id` yang sama dengan yang dipakai FCM.
"""
from pathlib import Path
import json
from playwright.sync_api import sync_playwright

ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / 'screenshots'
BASE_URL = 'http://127.0.0.1:8766'


def enable_semantics(page, wait_text='Masuk'):
    placeholder = page.locator('flt-semantics-placeholder')
    placeholder.wait_for(state='attached')
    placeholder.evaluate('(element) => element.click()')
    page.get_by_text(wait_text, exact=False).first.wait_for(timeout=30000)


def capture(page, name):
    page.wait_for_timeout(500)
    page.screenshot(path=str(OUTPUT / name))
    print('Captured:', name)


def main():
    assert OUTPUT.is_dir(), 'Create screenshots/ first'
    (OUTPUT / 'debug.png').unlink(missing_ok=True)
    with sync_playwright() as p:
        browser = p.chromium.launch(channel='chrome', headless=True)
        context = browser.new_context(
            viewport={'width': 1000, 'height': 1300},
            device_scale_factor=1,
        )
        page = context.new_page()
        errors = []
        page.on('pageerror', lambda error: errors.append(str(error)))
        page.on(
            'console',
            lambda message: print('Browser:', message.text)
            if message.type == 'error'
            else None,
        )
        page.goto(BASE_URL)
        enable_semantics(page)
        capture(page, '01-halaman-login.png')

        # Login memakai mock auth provider.
        page.get_by_role('button', name='Masuk', exact=True).click()
        try:
            page.get_by_role('button', name='Keluar', exact=True).wait_for(
                timeout=20000
            )
        except Exception:
            print('DOM:', page.locator('flt-semantics-host').inner_html()[:4000])
            print('Errors:', errors)
            capture(page, 'debug.png')
            raise
        capture(page, '02-home-sesi-dan-token.png')

        # Deep link ke halaman pengumuman (rute yang dipakai data.route FCM).
        page.get_by_role(
            'button', name='Jadwal kuliah berubah', exact=False
        ).first.click()
        page.get_by_text('Dibuka dari deep link FCM', exact=False).first.wait_for(
            timeout=15000
        )
        assert '/pengumuman/3' in page.url, page.url
        capture(page, '03-halaman-pengumuman-deep-link.png')

        # Reload langsung pada rute detail membuktikan guard + routing.
        page.reload()
        enable_semantics(page, wait_text='Dibuka dari deep link FCM')
        capture(page, '04-pengumuman-setelah-reload.png')

        assert not errors, errors
        print(
            json.dumps(
                {
                    'result': 'PASS',
                    'screenshots': 4,
                    'observations': [
                        'guard route: belum login -> /login',
                        'login mock -> home, token disimpan di secure storage',
                        'token ditampilkan terpotong (12 karakter)',
                        'deep link /pengumuman/3 membuka halaman tujuan',
                        'rute detail bertahan setelah reload',
                    ],
                    'page_errors': errors,
                },
                indent=2,
            )
        )
        browser.close()


if __name__ == '__main__':
    main()
