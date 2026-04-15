# Featurebook > BottomRightPanelTad.md
Go to [Featurebook > Index](FEATUREBOOK.md)

## TOC

* [`@Scenario` `feature_firstGoTo()`](#feature_firstGoTo)
* [`@Scenario` `feature_firstMarkRead()`](#feature_firstMarkRead)

## Scenarios

<a id="feature_firstGoTo"></a>
<table>
<tr><td> 

`@Scenario` `feature_firstGoTo()`<br />
</td></tr>
<tr><td>

![image.png](../featurebook-img/BottomRightPanelTad/feature_firstGoTo/image.png)

`First unread: Go to (CTRL+ALT+1)`. Link to the first unread note.
</td></tr>
</table>

<a id="feature_firstMarkRead"></a>
<table>
<tr><td> 

`@Scenario` `feature_firstMarkRead()`<br />
</td></tr>
<tr><td>

`First unread: Mark as read (CTRL+ALT+2)`. 

Jumps to the first unread note. Like clicking on `First: go to`. Sets the status to `Read` (green). 

Puts the whole note w/ a yellow background that will fade out in 5 seconds. This is to visually show where the modification is made. 
Because w/o this, the user won't know exactly what was the note on which the action operated.
</td></tr>
</table>
