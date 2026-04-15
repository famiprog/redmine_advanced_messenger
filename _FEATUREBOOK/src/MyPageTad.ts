class MyPageTad {

    /**
     * @img image.png
     * 
     * Format, e.g.:
     * 
     * ```
     * (1) #1234 Task title - Project by User, 29 minutes ago
     * ```
     * Format, spec:
     * 
     * ```
     * (unreadNotes) #taskNumber taskSubject - projectName by userName, date
     * ```
     * 
     * * `(unreadNotes)` - bold, link to the issue, scrolled to the latest unread message. Useful when the conversation is fresh, and I want to see directly the latest message (and maybe also reply).
     *   * red or orange (for the "to process later" variants). The color is different to communicate to the user the fact that there are in fact 2 links, and not one. Hence avoiding to "hide" the feature.
     * * `#taskNumber taskSubject` - bold, link to the issue; normal link. Useful when I want to have a glimpse of the issue title and description. Then I would use the action `Go to first` or manually scroll. There are a lot of notifications of type "new issue added". This link is perfect for this case.
     * * `projectName` - link to project
     * * `userName` - gray, link to the user
     * * `date` - gray, standard Redmine date rendering (e.g. 15 days ago; on hover => absolute date)
     */
    @Scenario
    feature_lineDisplay() {
    }
}