# Link functionality and permission issues
_Exported on 5/18/2026 at 13:12:06 GMT+2 from Cursor (3.3.30)_

---

**User**

DOM Path: div#wrapper > div#main > div#content > div#notifications-placeholder > div.my-page-notification. non-grouped-di.play > ul > li[1] > a[0]
Position: top=268px, left=31px, width=22px, height=14px
HTML Element: <a href="/advanced_messenger/40833/39/mark_not_visible_journals_as_ignored_and_redirect" style="color: red;" data-cursor-element-id="cursor-el-1">(1)</a> 

works. 

DOM Path: div#wrapper > div#main > div#content > div#notifications-placeholder > div.my-page-notification. non-grouped-di.play > ul > li[0] > a[0]
Position: top=253px, left=31px, width=22px, height=14px
HTML Element: <a href="/advanced_messenger/41300//mark_not_visible_journals_as_ignored_and_redirect" style="color: red;" data-cursor-element-id="cursor-el-182">(1)</a> 

doesn't work, giving the error @\home\poweruser\.cursor\projects\home-poweruser-redmine\terminals\3.txt:1002-1019 & what's rendered now in the browser. I think this appeared when this was implemented (i.e. the text was split in 2: the red link and the blue link): @redmine_advanced_messenger/_FEATUREBOOK/src/MyPageTad.ts:17-20 .

Maybe it's because the user doesn't have view permissions for that particular note? I.e. he had, but now he hasn't any more. And there was a mechanism for this in place, to "silently" mark as read such modifications

---

**User**

please look in the git history at commit 87aa78da7e6009c37c03de35a3ae9f8a80b99c1d

before this commit, the logic was working w/o sentinel or other custom code. Why did it break?

So before the commit, the whole link was practly == the "red link"

---

**User**

I updated the specs. Please implement. @redmine_advanced_messenger/_FEATUREBOOK/src/MyPageTad.ts:19 @redmine_advanced_messenger/_FEATUREBOOK/src/MyPageTad.ts:24-44 

---

**User**

works for forum also, right?

---

