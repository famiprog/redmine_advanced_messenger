# Unread notifications periodic update removal
_Exported on 2/21/2026 at 16:55:55 GMT+1 from Cursor (2.4.31)_

---

**User**

In redmine_advanced_messenger, there is logic that populates, in the top/right corner: Unread notifications (displayed in red). And updated periodically w/ AJAX. Find that code, and remove it. We don't need this periodic update any more.

However, there is also a periodic refresh when in "My page" when the app is in PWA mode. I hope this is a separate mechanism. Because this one, we do need it

---
