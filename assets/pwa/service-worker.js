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

self.addEventListener('notificationclick', function(event) {
    event.notification.close();
    const urlToOpen = new URL(event.notification.data.url, self.location.origin).href;
    const promiseChain = clients.matchAll({
        type: 'window',
        includeUncontrolled: true
    }).then((windowClients) => {
        for (let client of windowClients) {
            if (client.url === urlToOpen && 'focus' in client) {
                return client.focus();
            }
        }
        if (clients.openWindow) {
            return clients.openWindow(urlToOpen);
        }
    });
    event.waitUntil(promiseChain);
});
