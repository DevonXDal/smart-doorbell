namespace DoorbellPiWeb.Enumerations
{
    /// <summary>
    /// This <see cref="DoorbellState"/> describes the current state of the connected doorbell such as being idle or offline.
    /// </summary>
    public enum DoorbellState
    {
        Idle, // If the doorbell is connected but nothing has happened recently. A doorbell becomes idle immediately after a call ends.
        ButtonRecentlyActivated, // If the doorbell had the button pressed in the last minute
        InCall, // If the doorbell is actively in a call with one or more app users
        UnreachableOrOff // If the doorbell was unable to be contacted by the Web server.
    }
}
