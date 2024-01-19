# redmine-advanced-messenger

## Install
This plugin needs the postgres extension ```pg_trgm```, but the instalation of the migration scripts can fail to install this extension because of insufficient rights. 

In this case the ```pg_trgm``` extension should be installed manually by:
1. connecting to the DB as a super user (e.g. ```psql -U postgres redmine```)

2. manually running: ```CREATE EXTENSION pg_trgm;```

## Known issue in Chrome
If the read status of a note/forum message is changed, the coloring is changed accordingly. But if we navigate away to another page and after that we navigate back to the initial page (by pressing the back button), the note/message has the old status coloring.

This is caused because, as a response to the server action that update the read_status, we execute a js that updates only the modified note, instead of reloading the whole page. And when we land back on the page, the page is re-rendered from the cache and the journals/messages are having the old read statusses.

This is a pattern also used in redmine project when a note text is edited. So the problem is present also in that case.

A solution would have been to reload the entire page when changing the read status of only one note/forum message, but that's something we want to avoid