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

self.addEventListener('notificationclick', function (event) {
    event.notification.close();
    if (event.action == 'openMessage') {
        var url = new URL(event.notification.data.url, self.location.origin);
        url.searchParams.append("markNoteAsRead", event.notification.data.notificationId);
        event.waitUntil(openUrlInBrowserWindow(url.href));
    } else if (event.action == "markAndSubmitAnswer") {
        // post a message to the channel which will be received in the main page, in this way we don't need to deal about the authorization for the requests
        event.waitUntil(async () => new BroadcastChannel('markAndSubmitAnswer').postMessage({ reply: event.reply, notificationData: event.notification.data }));
    } else if (!event.action) {
        event.waitUntil(openUrlInBrowserWindow(event.notification.data.url));
    } else {
        console.log(`Unknown action clicked: '${event.action}'`);
    }
});

function openUrlInBrowserWindow(url) {
    const urlToOpen = new URL(url, self.location.origin).href;
    return clients.matchAll({
        type: 'window',
        includeUncontrolled: true
    }).then(() => {
        if (clients.openWindow) {
            return clients.openWindow(urlToOpen);
        } else {
            console.log('clients.openWindow is not supported by this browser');
        }
    });
}