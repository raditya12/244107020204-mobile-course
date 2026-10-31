"""Capture the running Flutter web application, using real UI actions.

Prerequisite: python -m pip install playwright
Serve build/web at http://127.0.0.1:8765 before running this script.
"""
from pathlib import Path
import json
from playwright.sync_api import sync_playwright

ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / 'screenshots'


def enable_semantics(page, detail=False):
    placeholder = page.locator('flt-semantics-placeholder')
    placeholder.wait_for(state='attached')
    placeholder.evaluate('(element) => element.click()')
    if detail:
        page.get_by_role('button', name='Kembali ke catatan', exact=True).wait_for()
    else:
        page.get_by_role('button', name='Tambah catatan', exact=True).wait_for()


def add_note(page, title, body):
    page.get_by_role('button', name='Tambah catatan', exact=True).click()
    page.get_by_role('textbox', name='Judul').fill(title)
    page.get_by_role('textbox', name='Judul').press('Tab')
    page.get_by_role('textbox', name='Isi catatan').click()
    page.get_by_role('textbox', name='Isi catatan').press_sequentially(body, delay=15)
    page.get_by_role('textbox', name='Isi catatan').press('Tab')
    page.get_by_role('button', name='Simpan', exact=True).click()
    page.wait_for_timeout(700)


def verify_note(page, title, body):
    page.get_by_role('button', name=title, exact=False).click()
    page.get_by_text(body, exact=True).wait_for()
    page.get_by_role('button', name='Kembali ke catatan', exact=True).click()
    page.get_by_role('button', name='Tambah catatan', exact=True).wait_for()


def capture(page, name):
    page.wait_for_timeout(500)
    page.screenshot(path=str(OUTPUT / name))
    print('Captured:', name)


def main():
    assert OUTPUT.is_dir(), 'Create screenshots/ first'
    (OUTPUT / 'debug.png').unlink(missing_ok=True)
    with sync_playwright() as p:
        browser = p.chromium.launch(channel='chrome', headless=True)
        context = browser.new_context(viewport={'width': 1100, 'height': 1400},
                                      device_scale_factor=1)
        page = context.new_page()
        errors = []
        page.on('pageerror', lambda error: errors.append(str(error)))
        page.on('console', lambda message: print('Browser:', message.text) if message.type == 'error' else None)
        page.goto('http://127.0.0.1:8765')
        enable_semantics(page)
        try:
            page.get_by_label('100 bacaan tersimpan di cache', exact=True).wait_for(timeout=15000)
        except Exception:
            print('DOM:', page.locator('flt-semantics-host').inner_html())
            print('Errors:', errors)
            capture(page, 'debug.png')
            raise
        capture(page, '01-online-cache-api.png')
        capture(page, '00-catatan-kosong.png')
        page.get_by_role('switch').click()
        add_note(page, 'Belajar offline-first', 'Catatan dibuat tanpa request jaringan; tersimpan di SQLite.')
        verify_note(page, 'Belajar offline-first', 'Catatan dibuat tanpa request jaringan; tersimpan di SQLite.')
        add_note(page, 'Antrean sinkronisasi', 'Dirty = 1 sampai simulasi upload berhasil saat online.')
        verify_note(page, 'Antrean sinkronisasi', 'Dirty = 1 sampai simulasi upload berhasil saat online.')
        page.get_by_label('Belum tersinkron: 2', exact=True).wait_for()
        capture(page, '02-offline-dirty-sebelum-sync.png')

        # Block the API in addition to forceOffline, then reload the application.
        # Flutter renderer assets remain accessible to boot the web application.
        context.route('https://jsonplaceholder.typicode.com/**', lambda route: route.abort())
        page.reload()
        enable_semantics(page)
        page.get_by_label('Belum tersinkron: 2', exact=True).wait_for()
        page.get_by_role('switch').click()
        page.get_by_label('100 bacaan tersimpan di cache', exact=True).wait_for()
        capture(page, '03-cache-dan-catatan-setelah-reload-offline.png')

        # Detail uses the ID in GoRouter and survives a direct route reload.
        page.get_by_role('button', name='Antrean sinkronisasi', exact=False).click()
        page.get_by_role('button', name='Kembali ke catatan', exact=True).wait_for()
        assert '/note/' in page.url, page.url
        page.reload()
        enable_semantics(page, detail=True)
        page.get_by_text('Antrean sinkronisasi', exact=True).wait_for()
        capture(page, '07-detail-catatan-lokal.png')
        page.get_by_role('button', name='Kembali ke catatan', exact=True).click()
        page.get_by_role('switch').wait_for()
        page.get_by_role('switch').click()

        # Verify create, edit, delete while offline using a temporary note.
        add_note(page, 'Catatan sementara', 'Akan diedit dan dihapus secara lokal.')
        page.get_by_label('Belum tersinkron: 3', exact=True).wait_for()
        page.get_by_role('button', name='Edit catatan', exact=True).first.click()
        page.get_by_role('textbox', name='Judul').fill('Catatan sementara diedit')
        capture(page, '08-edit-catatan-offline.png')
        page.get_by_role('button', name='Simpan', exact=True).click()
        page.wait_for_timeout(500)
        page.get_by_role('button', name='Hapus catatan').first.click()
        page.get_by_label('Belum tersinkron: 2', exact=True).wait_for()

        context.unroute('https://jsonplaceholder.typicode.com/**')
        page.get_by_role('switch').click()
        page.get_by_role('button', name='Sinkronkan', exact=True).click()
        page.get_by_label('Belum tersinkron: 0', exact=True).wait_for(timeout=15000)
        capture(page, '04-online-dirty-setelah-sync.png')
        page.get_by_role('button', name='Pengaturan', exact=True).click()
        page.get_by_role('switch').click()
        page.wait_for_timeout(600)
        capture(page, '05-pengaturan-tema-gelap.png')
        page.reload()
        enable_semantics(page)
        page.get_by_role('button', name='Pengaturan', exact=True).click()
        page.wait_for_timeout(500)
        capture(page, '06-preferensi-setelah-reload.png')
        assert page.get_by_role('switch').get_attribute('aria-checked') == 'true'
        assert not errors, errors
        print(json.dumps({'result': 'PASS', 'screenshots': 9,
            'observations': ['API cache: 100 posts', 'offline dirty: 2',
              'SQLite persists after reload', 'offline create/edit/delete: PASS',
              'sync dirty: 2 -> 0', 'dark preference persists after reload',
              'detail route reads local note after direct reload'],
            'page_errors': errors}, indent=2))
        browser.close()


if __name__ == '__main__':
    main()
