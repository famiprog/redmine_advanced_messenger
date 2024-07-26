const PWA_START_URL = "/my/page";
const PWA_BADGE_VALUE = "PWA_BADGE_VALUE";
const TIMER_CLOSING_OLD_NOTIFICATIONS = 5; // seconds

// register service worker
function registerPWAServiceWorker() {
    if (navigator.serviceWorker) {
        window.addEventListener("load", async function () {
            try {
                navigator.serviceWorker.register("../../plugin_assets/redmine_advanced_messenger/pwa/service-worker.js")
                    .then((registration) => {
                        console.log("Service worker registration succeeded:", registration);
                    })
            } catch (error) {
                console.log("service worker not registered", error);
            }
        });
    }
}

function checkPWA() {
    return window.matchMedia('(display-mode: standalone)').matches
}

function refreshPWA(badgeValue) {
    if (!checkPWA()) {
        return;
    }
    // needs to refresh and redirect to PWA start url
    if (!window.location.href.endsWith(PWA_START_URL)) {
        window.location.href = PWA_START_URL;
        return;
    }

    // change app badge if the value was changed
    if (sessionStorage.getItem(PWA_BADGE_VALUE) != badgeValue) {
        sessionStorage.setItem(PWA_BADGE_VALUE, badgeValue);
        // check for support first and set the value displayed for PWA badge
        if (navigator.setAppBadge) {
            navigator.setAppBadge(badgeValue);
        }
        // send notification
        showNotification();
        // refresh page
        window.location.href = PWA_START_URL;
    }

    // change all links with target="_blank" except the links with href = PWA_START_URL
    jQuery(document).ready(function () {
        $('a').each(function () {
            if (!$(this).attr('href').endsWith(PWA_START_URL)) {
                $(this).attr('target', '_blank')
            }
        });
    });
}

function showNotification() {
    if (Notification.permission != "granted") {
        return;
    }
    var notification = new Notification("Redmine", {
        body: "New redmine notifications!",
        // the id for notification, needs to be unique
        tag: "RedmineAdvancedMessengerNotification_" + new Date().toUTCString(),
        icon: "../../favicon.ico",
    });

    setTimeout(() => {
        notification.close();
    }, TIMER_CLOSING_OLD_NOTIFICATIONS * 1000);
}