# Specification update and production latency
_Exported on 4/15/2026 at 17:38:30 GMT+2 from Cursor (2.6.21)_

---

**User**

@redmine_advanced_messenger/_FEATUREBOOK/src/BottomRightPanelTad.ts:20-22 spec updated.

Now it's not like this. And in prod, there is some latency. I.e. I click, I wait a bit, and then there is the "go to" and "yellow".

---

**User**

Undo. You need to modify the code according the new spec.

---

**User**

Performance. For each line, you do a query to discover the last note: for the date and user.

what is in notification_status? this info is not there already prepared? I think that some things are already prepared, right? e.g. the number of unread? this is not queried each time

---

**User**

Please improve as suggested.

---

**User**

@redmine_advanced_messenger/app/helpers/advanced_messenger_helper.rb:116-117 you don't assign .last_notification on each iteration?

---

