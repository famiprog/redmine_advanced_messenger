const PWA_START_URL = "/my/page";
const PWA_BADGE_VALUE = "PWA_BADGE_VALUE";
const TIMER_CLOSING_OLD_NOTIFICATIONS = 5; // seconds

// register service worker
function registerPWAServiceWorker() {
    if (!checkPWA()) {
        return;
    }
    if (navigator.serviceWorker) {
        window.addEventListener("load", async function () {
            try {
                navigator.serviceWorker.register("../../plugin_assets/redmine_advanced_messenger/pwa/service-worker.js")
                    .then((registration) => {
                        console.log("Service worker registration succeeded:", registration);
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
}

// c.f https://stackoverflow.com/a/41749865 check manifest display, needs to update this method if it will be change
function checkPWA() {
    return window.matchMedia('(display-mode: standalone)').matches
}

function refreshPWA(badgeValue, notifications) {
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

    if (notifications.length > 0) {
        let delay = 0;
        if (!sessionStorage.getItem('PWA_FIRST_RUN')) {
            // On the first run, skip sending notifications and mark the session as initialized
            sessionStorage.setItem('PWA_FIRST_RUN', 'false');
        } else {
            notifications.forEach(function (notification) {
                setTimeout(function () {
                    showNotification(notification.title, notification.message, { url: notification.url });
                }, delay);
                delay += 1000; // Increase the delay by 1 second for each subsequent notification
                // Without this delay, notifications would be sent one after another too quickly, causing only the last one to be received
                // e.g., if the delay is 500ms, only the odd notifications would be shown
            });
        }

        // Add notifications to sessionStorage so they won't be resent
        const storedNotifications = JSON.parse(sessionStorage.getItem('PWA_NOTIFICATIONS') || '[]');
        const updatedNotifications = storedNotifications.concat(notifications);
        sessionStorage.setItem('PWA_NOTIFICATIONS', JSON.stringify(updatedNotifications));
        // Delay the page refresh to happen after all notifications have been shown
        // Without this delay, the page refresh would interrupt the notifications from being sent
        setTimeout(function () {
            window.location.href = PWA_START_URL;
        }, delay);
    } else if (badgeChanged) {
        // If no notifications and the badge value changed, refresh the page
        window.location.href = PWA_START_URL;
        return;
    }
}

function askUserForNotificationPermission() {
    if (Notification && !["denied", "granted"].includes(Notification.permission)) {
        Notification.requestPermission().then((permission) => {
            console.log("User permission for notifications was: ", permission);
        })
    }
}

/** 
 * Notification sent through service-worker.
 * @param title - Notification title.
 * @param body - Notification content.
 * @param data - Notification data (any) which can be used by notificationclick event listener in service-worker. For example { url: "issueUrl"}.
*/
function showNotification(title, body, data) {
    Notification.requestPermission().then((result) => {
        if (result == "granted") {
            navigator.serviceWorker.getRegistration("../../plugin_assets/redmine_advanced_messenger/pwa/service-worker.js")
                .then((registration) => {
                    registration.showNotification(title, {
                        body: body,
                        tag: "RedmineAdvancedMessengerNotification_" + new Date().getTime().toString(),
                        icon: "../../favicon.ico",
                        data: data,
                        requireInteraction: true,
                    });
                });
        }
    });
}