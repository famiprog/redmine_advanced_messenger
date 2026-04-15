class BottomRightPanelTad {

    /**
     * @img image.png
     * 
     * `First unread: Go to (CTRL+ALT+1)`. Link to the first unread note.
     */
    @Scenario
    feature_firstGoTo() {
    }

    /**
     * `First unread: Mark as read (CTRL+ALT+2)`. 
     * 
     * Jumps to the first unread note. Like clicking on `First: go to`. Sets the status to `Read` (green). 
     * 
     * Puts the whole note w/ a yellow background that will fade out in 5 seconds. This is to visually show where the modification is made. 
     * Because w/o this, the user won't know exactly what was the note on which the action operated.
     */
    @Scenario
    feature_firstMarkRead() {
    }

}