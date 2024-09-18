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

function refreshPWA(badgeValue, taskId, message, url) {
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
    var currentBadgeValue = sessionStorage.getItem(PWA_BADGE_VALUE);
    if (currentBadgeValue != badgeValue) {
        // check for support first and set the value displayed for PWA badge
        if (navigator.setAppBadge) {
            navigator.setAppBadge(badgeValue);
        }
        // show notification just if badge value is greater than current badge value AND will not be displayed when the application is just started
        if (currentBadgeValue != null && badgeValue > currentBadgeValue) {
            showNotification(taskId, message, url);
        }
        sessionStorage.setItem(PWA_BADGE_VALUE, badgeValue);
        // refresh page
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

function showNotification(taskId, message, url) {
    // Stop if user permission was not granted
    if (Notification && Notification.permission != "granted") {
        return;
    }
    var notification = new Notification("Redmine", {
        body: `Task #${taskId}: ${message}`,
        // the id for notification needs to be unique
        tag: "RedmineAdvancedMessengerNotification_" + new Date().toUTCString(),
        icon: "../../favicon.ico",
        data: { url: url }  // Include the URL to the unread message
    });

    setTimeout(() => {
        notification.close();
    }, TIMER_CLOSING_OLD_NOTIFICATIONS * 1000);
}