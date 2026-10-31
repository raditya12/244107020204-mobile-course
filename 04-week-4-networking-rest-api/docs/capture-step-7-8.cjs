// Jalankan setelah flutter build web; membutuhkan package Node playwright.
const { chromium } = require('playwright');
const http = require('http');
const fs = require('fs');
const path = require('path');
const assert = require('assert/strict');
const root = path.resolve(__dirname, '../build/web');
const output = path.resolve(__dirname, '../../screenshots');
const types = { '.js': 'application/javascript', '.html': 'text/html', '.json': 'application/json', '.wasm': 'application/wasm' };
const server = http.createServer((req, res) => {
  const url = req.url.split('?')[0];
  fs.readFile(path.join(root, url === '/' ? 'index.html' : decodeURIComponent(url)), (error, data) => {
    if (error) { res.writeHead(404); res.end(); return; }
    res.setHeader('Content-Type', types[path.extname(url)] || (url === '/' ? 'text/html' : 'application/octet-stream'));
    res.end(data);
  });
});
(async () => {
  await new Promise(resolve => server.listen(8765, '127.0.0.1', resolve));
  const browser = await chromium.launch({ channel: 'chrome', headless: true });
  try {
    const page = await browser.newPage({ viewport: { width: 1100, height: 850 } });
    const requests = [];
    page.on('request', req => { if (req.url().includes('jsonplaceholder')) requests.push(req.url()); });
    page.on('response', res => { if (res.url().includes('jsonplaceholder')) console.log('API', res.status(), res.url()); });
    async function open(hash = '') {
      await page.goto('about:blank');
      await page.goto('http://127.0.0.1:8765/' + hash);
      await page.locator('flt-semantics-placeholder').evaluate(el => el.click());
    }
    async function capture(name) {
      await page.waitForTimeout(700);
      await page.screenshot({ path: path.join(output, name + '.png') });
      console.log('SCREENSHOT', name);
    }
    await open();
    await page.getByText('sunt aut facere repellat', { exact: false }).waitFor();
    await capture('step-7-post-tile');
    await page.getByText('sunt aut facere repellat', { exact: false }).click();
    await page.getByText('Detail post 1', { exact: true }).waitFor();
    assert(!requests.some(url => url.endsWith('/posts/1')));
    console.log('PASS cached detail: no GET /posts/1');
    await capture('step-7-detail-cache');
    await open('#/post/2');
    await page.getByText('qui est esse', { exact: true }).waitFor();
    assert(requests.some(url => url.endsWith('/posts/2')));
    await capture('step-7-detail-deep-link');

    // Response sengaja ditunda untuk menangkap state loading yang nyata.
    let releaseLoading;
    const loadingGate = new Promise(resolve => { releaseLoading = resolve; });
    await page.route('**/posts?*', async route => {
      await loadingGate;
      await route.continue();
    });
    await open();
    await page.getByText('Posts Paged', { exact: true }).waitFor();
    await capture('step-8-loading');
    releaseLoading();
    await page.getByText('sunt aut facere repellat', { exact: false }).waitFor();
    await page.unroute('**/posts?*');
    await page.route('**/posts?_page=2&_limit=10', route => route.fulfill({
      status: 500, contentType: 'application/json', body: '{}',
    }));
    await page.mouse.move(500, 650);
    await page.mouse.wheel(0, 650);
    await page.waitForTimeout(1000);
    await page.mouse.wheel(0, 500);
    await page.waitForTimeout(1000);
    await page.getByRole('button', { name: 'Coba lagi' }).waitFor();
    await capture('step-8-pagination-error');
    await page.unroute('**/posts?_page=2&_limit=10');
    await page.getByRole('button', { name: 'Coba lagi' }).click();
    await page.waitForResponse(res => res.url().includes('_page=2&') && res.status() === 200);
    await page.mouse.wheel(0, 400);
    await capture('step-8-pagination-success');
    // Scroll sampai server mengembalikan halaman 11 kosong (100 posts total).
    for (let i = 0; i < 35; i++) {
      if (requests.some(url => url.includes('_page=11&'))) break;
      await page.mouse.wheel(0, 1000);
      await page.waitForTimeout(850);
    }
    assert(requests.some(url => url.includes('_page=11&')));
    await page.waitForTimeout(1000);
    await page.mouse.wheel(0, 1000);
    await capture('step-8-pagination-end');
    await page.route('**/posts?*', route => route.fulfill({
      status: 200, contentType: 'application/json', body: '[]',
    }));
    await open();
    await page.getByText('Belum ada data dari server.', { exact: true }).waitFor();
    await capture('step-8-empty');
    console.log('PASS: detail cache/deep link, loading, pagination error/retry/end, empty');
  } finally { await browser.close(); server.close(); }
})().catch(error => { console.error(error); server.close(); process.exitCode = 1; });
