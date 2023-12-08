# redmine-advanced-messenger

## Install
This plugin needs the postgres extension ```pg_trgm```, but the instalation of the migration scripts can fail to install this extension because of insufficient rights. 

In this case the ```pg_trgm``` extension should be installed manually by:
1. connecting to the DB as a super user (e.g. ```psql -U postgres redmine```)

2. manually running: ```CREATE EXTENSION pg_trgm;```
