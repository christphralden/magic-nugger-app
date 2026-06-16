declare const __UNITY_CHECKSUM__: string;

const CACHE_NAME = `unity-v${__UNITY_CHECKSUM__}`;

const UNITY_PATHS = new Set([
  "/Calculon/Build/Calculon.data",
  "/Calculon/Build/Calculon.wasm",
  "/Calculon/Build/Calculon.framework.js",
  "/Calculon/Build/Calculon.loader.js",
]);

const sw = self as unknown as ServiceWorkerGlobalScope;

self.addEventListener("install", (event) => {
  (event as ExtendableEvent).waitUntil(sw.skipWaiting());
});

async function onActivate() {
  const keys = await caches.keys();
  await Promise.all(
    keys.filter((k) => k !== CACHE_NAME).map((k) => caches.delete(k)),
  );
  await sw.clients.claim();
}

async function onFetch(request: Request): Promise<Response> {
  const cache = await caches.open(CACHE_NAME);
  const cached = await cache.match(request);
  if (cached) return cached;
  const response = await fetch(request);
  if (response.ok) cache.put(request, response.clone());
  return response;
}

self.addEventListener("activate", (event) => {
  (event as ExtendableEvent).waitUntil(onActivate());
});

self.addEventListener("fetch", (event) => {
  const fe = event as FetchEvent;
  const url = new URL(fe.request.url);
  if (!UNITY_PATHS.has(url.pathname)) return;
  fe.respondWith(onFetch(fe.request));
});
