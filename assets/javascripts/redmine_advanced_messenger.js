const PWA_START_URL = "/my/page";
const PWA_BADGE_VALUE = "PWA_BADGE_VALUE";
const PWA_DISPLAYED_NOTIFICATIONS = "PWA_DISPLAYED_NOTIFICATIONS";
const PWA_RELATIVE_PATH = "/plugin_assets/redmine_advanced_messenger/pwa/service-worker.js";

// register service worker
function registerPWAServiceWorker() {
    if (!checkPWA()) {
        return;
    }
    if (navigator.serviceWorker) {
        window.addEventListener("load", async function () {
            try {
                navigator.serviceWorker.register(PWA_RELATIVE_PATH)
                    .then((registration) => {
                        console.log("Service worker registration succeeded:", registration);
                        // fired any time the ServiceWorkerRegistration.installing property acquires a new service worker, including first install
                        registration.onupdatefound = (event) => {
                            console.log("Service worker was updated");
                        }
                        // maintains SW updated with the latest source code
                        registration.update();
                    })
                askUserForNotificationPermission();
            } catch (error) {
                console.log("service worker not registered", error);
            }
        });
    }

    window.onclick = ((e) => {
        // open all links in a new browser window except the PWA start url 
        if (e.target.localName == 'a' && !e.target.href.endsWith(PWA_START_URL)) {
            e.preventDefault();
            window.open(e.target.href);
        }
    })

    /**
     * Receive a message from the service worker when the button 'markAndSubmitAnswer' is clicked with the notification data. 
     * In this way is easier to make the corresponding API requests from here because Rails.ajax() supplies authorization and CSRF token automatically.
     */
    listenOnBroadcastChannel('markAndSubmitAnswer', (event) => {
        const eventNotification = event.data;
        const isForum = eventNotification.notificationData.url.includes("boards");
        markNoteOrMessageAsRead(eventNotification.notificationData.notificationId, isForum);
        submitAnswerToIssueOrForum(eventNotification.reply, eventNotification.notificationData.taskId, isForum, eventNotification.notificationData.parentTaskId, eventNotification.notificationData.taskSubject)
    });
}

function listenOnBroadcastChannel(channel, onMessageCallback) {
    new BroadcastChannel(channel).onmessage = (event) => onMessageCallback(event);
}

/**
 * Create a note/message for a issue/forum.
 * @param answer - note/message content mandatory.
 * @param taskId - issue/forum id mandatory.
 * @param isForum - check what url to use, by default issue url.
 * @param parentTaskId - if is forum mandatory.
 * @param taskSubject - if is forum mandatory.
 */
function submitAnswerToIssueOrForum(answer, taskId, isForum, parentTaskId, taskSubject) {
    if ((!answer || !taskId)) {
        return;
    }
    if (isForum && (!parentTaskId || !taskSubject)) {
        return;
    }
    Rails.ajax({
        // very important to use '.json' endpoint (for issue) because the update can be done with the XML type also, so the request will be redirected several times resulting in more API calls => more duplicated notes
        url: window.location.origin + (isForum ? `/boards/${parentTaskId}/topics/${taskId}/replies` : `/issues/${taskId}.json`),
        type: isForum ? "POST" : "PUT",
        beforeSend: function (xhr, options) {
            // very important to set 'Content-Type', otherwise the server cannot interpret correctly the body received and it will respond with 500 Internal server error
            xhr.setRequestHeader("Content-Type", "application/json");
            // set the data (body) in here because if I set as a option then the 'Content-Type' will be automatically set to 'application/x-www-form-urlencoded; charset=UTF-8' and I cannot override it
            options.data = JSON.stringify(isForum ? { reply: { content: answer, subject: taskSubject } } : { issue: { notes: answer } });
            return true;
        }
    });
}

function markNoteOrMessageAsRead(messageId, isForum) {
    if (!messageId) {
        return;
    }
    Rails.ajax({ url: window.location.origin + `/advanced_messenger/${messageId}/1/update_${isForum ? "message" : "journal"}_read_by_users`, type: "POST" });
}

// c.f https://stackoverflow.com/a/41749865 check manifest display, needs to update this method if it will be change
function checkPWA() {
    return window.matchMedia('(display-mode: standalone)').matches
}

function refreshPWA(badgeValue, notifications, notificationActions) {
    if (!checkPWA()) {
        return;
    }
    // needs to refresh and redirect to PWA start url if somehow the user succeeded to navigate to another url
    if (!window.location.href.endsWith(PWA_START_URL)) {
        window.location.href = PWA_START_URL;
        return;
    }

    // change app badge if the value was changed
    // use session storage in order to don't have the stored value, in this way when the app will be open the code will be trigger for remaining unread notifications
    const currentBadgeValue = sessionStorage.getItem(PWA_BADGE_VALUE);
    const badgeChanged = currentBadgeValue != badgeValue;
    if (badgeChanged) {
        // check for support first and set the value displayed for PWA badge
        if (navigator.setAppBadge) {
            navigator.setAppBadge(badgeValue);
        }
        sessionStorage.setItem(PWA_BADGE_VALUE, badgeValue);
    }

    // On the first run, skip sending notifications and add all in session storage to be considered as sent
    if (!sessionStorage.getItem(PWA_DISPLAYED_NOTIFICATIONS)) {
        sessionStorage.setItem(PWA_DISPLAYED_NOTIFICATIONS, JSON.stringify(notifications));
    } else {
        let delay = 0;
        const displayedNotifications = JSON.parse(sessionStorage.getItem(PWA_DISPLAYED_NOTIFICATIONS) || '[]');
        // Set current notifications received in session storage so they won't be resent at the next refresh
        sessionStorage.setItem(PWA_DISPLAYED_NOTIFICATIONS, JSON.stringify(notifications));
        notifications.forEach(function (notification) {
            // choose notifications which are not included in session storage
            if (!displayedNotifications.find(displayedNotification => displayedNotification.notificationId == notification.notificationId)) {
                // Increase the delay by 1 second for each subsequent notification
                // Without this delay, notifications would be sent one after another too quickly, causing only the last one to be received
                // e.g., if the delay is 500ms, only the odd notifications would be shown
                setTimeout(() => showNotification(notification.title, notification.message, notification, notificationActions), delay);
                delay += 1000;
            }
        });

        // if badgeChanged or if at least one notification was sent the page needs refresh
        if (badgeChanged || delay > 0) {
            // Delay the page refresh to happen after all notifications have been shown
            // Without this delay, the page refresh would interrupt the notifications from being sent
            setTimeout(() => window.location.href = PWA_START_URL, delay);
        }
    }
}

function askUserForNotificationPermission() {
    if (Notification && !["denied", "granted"].includes(Notification.permission)) {
        Notification.requestPermission().then((permission) => {
            console.log("Request permission for notifications! User permission for notifications was:", permission);
        })
    }
}

/** 
 * Notification sent through service-worker.
 * @param title - Notification title.
 * @param body - Notification content.
 * @param data - Notification data (any) which can be used by notificationclick event listener in service-worker. For example { url: "issueUrl"}.
 * @param actions - Notification action list. E.g: [{ action: "like", title: "Like", type: "button"}, { action: "Comment", title: "Comment", type: "text", placeholder: "Type your comment here"}]
*/
function showNotification(title, body, data, actions = []) {
    if (Notification.permission != "granted") {
        console.log("Notification cannot be shown! User permission for notifications is not granted! Instead was:", Notification.permission);
        return;
    }
    navigator.serviceWorker.getRegistration(PWA_RELATIVE_PATH)
        .then((registration) => {
            registration.showNotification(title, {
                body: body,
                tag: "RedmineAdvancedMessengerNotification_" + new Date().getTime().toString(),
                icon: "../../favicon.ico",
                data: data,
                requireInteraction: true,
                actions: actions,
            });
        });
}