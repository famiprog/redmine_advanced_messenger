const CACHE_NAME = "RedmineAdvancedMessenger"

self.addEventListener("install", event =>
    event.waitUntil(
        caches.open(CACHE_NAME).then(cache => {
            cache.addAll(["offline.html"]);
        })
    )
)

self.addEventListener('fetch', (event) => {
    event.respondWith(
        caches.match(event.request)
            .then(async () => {
                try {
                    // display the page from network, normal flow when the app have connection
                    return await fetch(event.request);
                } catch {
                    // display the page taken from cache for offline mode
                    return await caches.match('offline.html');
                }
            }));
})