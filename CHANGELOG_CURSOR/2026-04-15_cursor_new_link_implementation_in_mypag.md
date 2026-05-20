# New link implementation in MyPageTad
_Exported on 4/15/2026 at 13:22:54 GMT+2 from Cursor (2.6.21)_

---

**User**

I am starting late to use "specify previous to dev" technique in @redmine_advanced_messenger/_FEATUREBOOK/src/MyPageTad.ts:3-21 .

The new spec is the fact that now there are 2 links. In the old impl, there was only one link (cf. unreadNotes).

Please implement these 2 new links.

---

**User**

I noticed that for forum messages: 1/ you didn't do, 2/ the display is not the same as for issues. Please do both. I updated the spec to reflect the current: @redmine_advanced_messenger/_FEATUREBOOK/src/BottomRightPanelTad.ts:15-20 

---

**User**

user and date are still missing

---

**User**

Not working.
Here is good: DOM Path: div#wrapper > div#main > div#content > div#notifications-placeholder > div.my-page-notification. non-grouped-di.play[0] > ul > li > a[2]
Position: top=246px, left=31px, width=715px, height=35px
HTML Element: <a href="/projects/xops-security" style="color: #628DB6; font-weight: normal;" data-cursor-element-id="cursor-el-1">[content tree & regular] xops-security</a> 

Here is not good: DOM Path: div#wrapper > div#main > div#content > div#notifications-placeholder > div.my-page-notification. non-grouped-di.play[1] > ul > li[0] > a[1]
Position: top=402px, left=31px, width=442px, height=35px
HTML Element: <a href="/boards/19/topics/1946" data-cursor-element-id="cursor-el-213">#1946 Two tables with same entityDescriptor. Make a column appear in only one of the two tables</a> user name and date still missing

---

**User**

the fact that the code is duplicated in so many places: it's a code smell. Please do DRY. I expect a function that renders a line for issue. And another one for forum post. 

This function should be called from various places, w/ appropriate params

---

**User**

@redmine_advanced_messenger/_FEATUREBOOK/src/MyPageTad.ts:16 spec changed

---

**User**

@redmine_advanced_messenger/app/helpers/advanced_messenger_helper.rb:231-232 where did you take these values? it's not DRY. If in THAT places => it won't change in this place

---

**User**

not good; please search in the code where the red and orange are used. it's the border e.g. DOM Path: div#wrapper > div#main > div#content > div#replies > div#message-1954
Position: top=345px, left=16px, width=902px, height=87px
HTML Element: <div class="message reply advanced-messenger-bordered-panel" id="message-1954" data-cursor-element-id="cursor-el-1" style="border-color: red;">Unread Read briefly; to process fully later Read Read but collapsed Ignored RA, CS, MN, CC, DB, GS, EM, CZ, AD, TD, CR, VI, AL RE: Two tables with same entityDescriptor. Make a column appear in only</div> DOM Path: div#wrapper > div#main > div#content > div#replies > div#message-1959
Position: top=437px, left=16px, width=902px, height=113px
HTML Element: <div class="message reply advanced-messenger-bordered-panel" id="message-1959" data-cursor-element-id="cursor-el-364" style="border-color: orange;">Unread Read briefly; to process fully later Read Read but collapsed Ignored RA, CS, MN, CC, DB, GS, EM, CZ, AD, TD, CR, VI, AL RE: Two tables with same entityDescriptor. Make a column appear in only</div> and in the combo box DOM Path: div#wrapper > div#main > div#content > div#replies > div#message-1959 > div.read-unread-indicator.-at-right > span.read_combobox_placeholder > select
Position: top=444px, left=257px, width=226px, height=17px
HTML Element: <select style="color:orange;border-color:orange" onchange="changeReadByUsers(this.value,1959 , 'update_message_read_by_users' )" data-cursor-element-id="cursor-el-371">Unread Read briefly; to process fully later Read Read but collapsed Ignored</select> 

---

**User**

too complex. Extract all these constants as globals: @redmine_advanced_messenger/app/views/advanced_messenger/_html_head.html.erb:82-87 

So no need to use css.

Is there a good place for such globals in this plugin?

In another plugin I created such a place for globals: @redmine_crispico_plugin/lib/crispico_plugin_common.rb 

---

**User**

New spec: @redmine_advanced_messenger/_FEATUREBOOK/src/BottomRightPanelTad.ts:3-8 . Actually the action exists: DOM Path: div.ui-dialog ui-corner-all notification.-dialog ui-widget ui-widget-content ui-front fixed-i.ue-notification.-dialog unread > div#notifications_dialog > div > div[0] > a#go-to-first-one
Position: top=662px, left=1247px, width=95px, height=14px
HTML Element: <a id="go-to-first-one" class="icon icon-down-left-arrow" href="?r=1954#message-1954" data-cursor-element-id="cursor-el-617">Go to first one</a> . We want to change the label and add shortcut.

And there is: @redmine_advanced_messenger/_FEATUREBOOK/src/BottomRightPanelTad.ts:10-20 

---

**User**

mark as read: doesn't work ok:
1/ tuns yellow; OK
2/ but the page reloads; this is not OK
3/ and after page reload, I still see red; however if I reload the page again, i see green. So the change in DB was made.

But 2/ is not good; and if it is good, 3/ will also be good

---

**User**

not working; I'm clicking here: DOM Path: div.ui-dialog ui-corner-all notification.-dialog ui-widget ui-widget-content ui-front fixed-i.ue-notification.-dialog unread > div#notifications_dialog > div > div[0] > a#mark-first-as-read
Position: top=635px, left=1367px, width=136px, height=41px
HTML Element: <a id="mark-first-as-read" class="icon icon-checked-green" style="cursor:pointer" data-cursor-element-id="cursor-el-1">First: mark as read (CTRL + ALT + M)</a> . First unread note is 24. I see in log: @\home\poweruser\.cursor\projects\home-poweruser-workspaces-redmine-cursor-code-workspace\terminals\4.txt:993-1014 

---

**User**

no more page reload; ok
no more error in log; ok
however, the "yellow" highlight happens on the next note; so if i have note 24 and note 25 unread: note 24 will become read, and highlight will happen on note 25

---

**User**

For forum, the yellow is nice, inside the whole border: DOM Path: div#wrapper > div#main > div#content > div#replies > div#message-901
Position: top=300px, left=16px, width=1187px, height=265px
HTML Element: <div class="message reply advanced-messenger-bordered-panel" id="message-901" data-cursor-element-id="cursor-el-1" style="border-color: rgb(85, 203, 133);">Unread Read briefly; to process fully later Read Read but collapsed Ignored RA, CS, MN, CC, DB, GS, CM, EM, CZ, AC, TD, CR, VI, AL, SB, NA, AB RE: Releases of our libs and tools - Added by Cristian S</div> 
For issue, the yellow is smaller; I think: DOM Path: div#wrapper > div#main > div#content > div#history > div#tab-content-history > div#change-584187 > div#note-67
Position: top=212px, left=62px, width=1129px, height=48px
HTML Element: <div id="note-67" class="note" data-cursor-element-id="cursor-el-1" style="">Quote EditActions #67 Unread Read briefly; to process fully later Read Read but collapsed Ignored RA, MN, CC, DB, CZ, TD, CR, VI, AL Updated by Alexandru Luca 2 months ago · Edited Craciun Mihai. Ge</div> 

---

**User**

@redmine_advanced_messenger/app/views/advanced_messenger/_html_head.html.erb:141-148 please explain; 

---

**User**

this csrf trick is for the "success" handler to work?

---

**User**

but how did it work previously, w/o your csrf code?

---

**User**

please clean the code

---

**User**

@redmine_advanced_messenger/app/views/advanced_messenger/_journals_update_js_bottom.js.erb:5-6 why did the args to this function change? @redmine_advanced_messenger/app/views/advanced_messenger/update_journal_read_by_users.js.erb:5-6 @redmine_advanced_messenger/app/views/advanced_messenger/update_journal_read_by_users.js.erb:5-6 

---

**User**

why this change? @redmine_advanced_messenger/app/views/advanced_messenger/update_journal_read_by_users.js.erb:5-6 

---

**User**

so the last 2 corrections were bugs that you saw in code, and I didn't.
How did these bugs manifest?

---

**User**

I cannot find where this text is rendered DOM Path: div.ui-dialog ui-corner-all notification.-dialog ui-widget ui-widget-content ui-front fixed-i.ue-notification.-dialog unread > div#notifications_dialog > a.u.er active
Position: top=552px, left=725px, width=80px, height=14px
HTML Element: <a class="user active" href="/users/1" data-cursor-element-id="cursor-el-1526" draggable="false">redMine Admin</a> 

---

**User**

@redmine_advanced_messenger/app/views/advanced_messenger/_body_bottom.html.erb:85-87 I suspect that these links are hidden based on some logic; I don't see code w/ "if" when rendering @redmine_advanced_messenger/app/views/advanced_messenger/_body_bottom.html.erb:85 

---

**User**

@redmine_advanced_messenger/app/views/advanced_messenger/_body_bottom.html.erb:85 the id is just for show/hide?

---

**User**

1/ I changed the shortcuts: @redmine_advanced_messenger/_FEATUREBOOK/src/BottomRightPanelTad.ts:4 @redmine_advanced_messenger/_FEATUREBOOK/src/BottomRightPanelTad.ts:11 

2/  DOM Path: div.ui-dialog ui-corner-all notification.-dialog ui-widget ui-widget-content ui-front fixed-i.ue-notification.-dialog unread > div#notifications_dialog > div > a#mark-first-as-read
Position: top=617px, left=971px, width=143px, height=27px
HTML Element: <a id="mark-first-as-read" class="icon icon-checked-green" style="cursor:pointer" data-cursor-element-id="cursor-el-1">First one: Mark as read (CTRL+ALT+2)</a> is a "fake link"; the hand cursor is OK; it appears. But the color is black; not blue like the other links

3/ strange: in your browser, clicking on DOM Path: div.ui-dialog ui-corner-all notification.-dialog ui-widget ui-widget-content ui-front fixed-i.ue-notification.-dialog unread > div#notifications_dialog > div > a#mark-all-unread-ignored
Position: top=658px, left=710px, width=162px, height=14px
HTML Element: <a id="mark-all-unread-ignored" class="icon icon-delete-message" data-remote="true" rel="nofollow" data-method="post" data-confirm="You won't be notified about the ignored messages anymore. Are you sure you want to proceed?" href="/advanced_messenger/36854/ignore_all_unread_issues_notes" data-cursor-element-id="cursor-el-4384">Mark all unread as ignored</a> performs the action directly. In Firefox, I have an alert where I need to confirm

---

**User**

@redmine_advanced_messenger/app/helpers/advanced_messenger_helper.rb:15-23 this means additional db hits?  so perf implications? why needed?

---

**User**

@redmine_advanced_messenger/app/views/advanced_messenger/_body_bottom.html.erb:86-87 

can't we fake the link otherwise? maybe put "href=..." and prevent default or something? it's too hardcoded that #169

---

