const CACHE_NAME = "RedmineAdvancedMessenger"
// Request headers keys
const REDMINE_API_KEY_HEADER = "X-Redmine-API-Key";
const CSRF_TOKEN_HEADER = "x-csrf-token";
const CONTENT_TYPE_HEADER = "Content-Type";
const CONTENT_TYPE_JSON = "application/json";

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
    const notificationData = event.notification.data;
    if (event.action == 'openMessage') {
        var url = new URL(notificationData.notificationInfo.url, self.location.origin);
        url.searchParams.append("markNoteAsRead", notificationData.notificationInfo.notificationId);
        event.waitUntil(openUrlInBrowserWindow(url.href));
    } else if (event.action == "markAndSubmitAnswer") {
        var headers = { [CSRF_TOKEN_HEADER]: notificationData.xCsrfToken, [REDMINE_API_KEY_HEADER]: notificationData.apiKey, [CONTENT_TYPE_HEADER]: CONTENT_TYPE_JSON };
        const isForum = notificationData.notificationInfo.url.includes("boards");
        markAsRead(notificationData.notificationInfo.notificationId, isForum, headers);
        if (event.reply) {
            submitAnswer(event.reply, notificationData.notificationInfo.taskId, notificationData.notificationInfo.parentTaskId, notificationData.notificationInfo.taskSubject, isForum, headers)
        };
    } else if (!event.action) {
        event.waitUntil(openUrlInBrowserWindow(notificationData.notificationInfo.url));
    } else {
        console.log(`Unknown action clicked: '${event.action}'`);
    }
});

function submitAnswer(answer, taskId, parentTaskId, taskSubject, isForum, requestHeaders) {
    var body = isForum ? `{"reply":{"content":"${answer}","subject":"${taskSubject}"}}` : `{"issue":{"notes":"${answer}"}}`;
    // very important to use '.json' endpoint because the update can be done with the XML type also, so the request will be redirected several times resulting in more API calls => more notes
    return executeAPIRequest(self.location.origin + (isForum ? `/boards/${parentTaskId}/topics/${taskId}/replies` : `/issues/${taskId}.json`), isForum ? "POST" : "PUT", requestHeaders, body);
}

function markAsRead(messageId, isForum, requestHeaders) {
    var endpoint = `/advanced_messenger/${messageId}/1/update_${isForum ? "message" : "journal"}_read_by_users`;
    return executeAPIRequest(self.location.origin + endpoint, "POST", requestHeaders);
}

function executeAPIRequest(url, methodType, headers, body, successCallback, errorCallback) {
    return fetch(url, { method: methodType, headers: headers, body: body })
        .then(response => {
            if (successCallback) {
                successCallback(response);
            }
        }).catch(error => {
            if (errorCallback) {
                errorCallback(error);
            }
        });
}

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