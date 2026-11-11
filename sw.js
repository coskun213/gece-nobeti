// Gece NÃ¶beti Ã§evrimdÄ±ÅŸÄ± Ã¶nbelleÄŸi: Ã¶nce internetten en yeni sÃ¼rÃ¼m, baÄŸlantÄ± yoksa Ã¶nbellek
const CACHE = 'gece-nobeti-v2';
const FILES = ['./','./fonts.css','./icon-180.png','./icon-192.png','./icon-512.png','./index.html','./manifest.json','./fonts/f0.woff2','./fonts/f1.woff2','./fonts/f2.woff2','./fonts/f3.woff2','./fonts/f4.woff2','./fonts/f5.woff2','./fonts/f6.woff2','./fonts/f7.woff2','./fonts/f8.woff2','./js/CopyShader.js','./js/EffectComposer.js','./js/LuminosityHighPassShader.js','./js/RenderPass.js','./js/ShaderPass.js','./js/three.min.js','./js/UnrealBloomPass.js'];
self.addEventListener('install', e => { e.waitUntil(caches.open(CACHE).then(c => c.addAll(FILES)).then(() => self.skipWaiting())); });
self.addEventListener('activate', e => { e.waitUntil(caches.keys().then(ks => Promise.all(ks.filter(k => k !== CACHE).map(k => caches.delete(k)))).then(() => self.clients.claim())); });
self.addEventListener('fetch', e => {
  const req = e.request;
  if (req.method !== 'GET' || new URL(req.url).origin !== location.origin) return;
  e.respondWith(
    fetch(req, {cache: 'no-cache'}).then(res => {
      if (res.ok) { const copy = res.clone(); caches.open(CACHE).then(c => c.put(req, copy)); }
      return res;
    }).catch(() => caches.match(req, {ignoreSearch: true}).then(r => r || caches.match('./')))
  );
});