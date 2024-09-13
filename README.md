# Redmine Advanced Messenger

## Featurebook

See [FEATUREBOOK.md](FEATUREBOOK.md) for detailed description and screenshots.

## Install

For the moment only PostgreSQL is supported. We will gladly accept PRs that add support for other DBs. For a new DB, the main actions are: 1/ find an equivalent to [pg_trgm](https://www.postgresql.org/docs/current/pgtrgm.html) to be able to perform quick searches. 2/ Adapt the SQL syntax. 3/ Perform a series of manual tests, to check if the features are working.

This plugin needs the postgres extension [pg_trgm](https://www.postgresql.org/docs/current/pgtrgm.html). The install scripts contains the commands needed to activate it, but they can fail to install this extension because of insufficient rights. 

In this case the ```pg_trgm``` extension should be installed manually by:
1. connecting to the DB as a super user (e.g. ```psql -U postgres redmine```)

2. manually running: ```CREATE EXTENSION pg_trgm;```

## Known issues

NOTE: for the moment these are rather subtle, w/ very low impact. However, as we find such things, we document them here.

1/ WHEN changed the "Read/Unread" status, AND browser back button, AND browser forward button, THEN recent changes are not shown. <br /> <b>Workaround</b>: a page refresh / F5 is needed.

<details>
TLDR: we noticed a strange minor behavior, when doing browser back + forward, or on duplicating tabs. If I just did an Ajax request (e.g. updated the read/unread status), and then click on back + forward, the update is not seen. Workaround: page refresh. It's related to the caching of Ajax requests. Present in all Ajax requests of Redmine; not only in our plugin.

<details>
<summary>Techincal details (click to expand)</summary>

<br />
If the read status of a note/forum message is changed, the coloring is changed accordingly. But if we navigate away to another page and after that we navigate back to the initial page (by pressing the back button), the note/message has the old status coloring.

This is caused because, as a response to the server action that update the read_status, we execute a js that updates only the modified note, instead of reloading the whole page. And when we land back on the page, the page is re-rendered from the cache and the journals/messages are having the old read statuses.

This is a pattern also used in Redmine project when a note text is edited. So the problem is present also in that case.

The above happens in Chrome. Not in Firefox. However, the issue is present when duplicating tabs. This seems to affect Firefox as well.

A solution would have been to reload the entire page when changing the read status of only one note/forum message, but that's something we want to avoid.
</details>
</details>

2/ WHEN a new forum thread is created, THEN the initials of the creator don't appear among the other recipinents.

<details>
  1/ If you write a note in an issue => your initials appear among the recipients. 2/ The same doesn't happen if you create a forum thread. 3/ However, it does happen if you answer within a thread (because on step 2, you were added as a watcher).

  Item 2/ doesn't happen if you watch the parent forum.
  
  This is the way Redmine works. For cases 1/ and 3/, Redmine actually tries to send you (as author) an email. Many people probably check the setting "My account > I don't want to be notified of changes that I make myself", and they don't actually receive such mails.

  However, Redmine Advanced Messenger works by intercepting the attempt to send email notifications. For 2/, no such attempt => no interception => no initials.

  If this is annoying, then we might add a hack in our interceptor to handle 2/ as well. Ref. [message_patch.rb](https://github.com/famiprog/redmine_advanced_messenger/blob/a9ac897c43cfbd8ff08d1026d60907dd1249d10d/lib/patches/message_patch.rb#L14), something like `users = notified_users | root.notified_watchers | board.notified_watchers | [User.current]
`.
</details>


