namespace DoorbellPiWeb.Models.RequestResponseData
{
    /// <summary>
    /// This DoorbellUpdateData class holds information that is necessary for apps to properly update the current status for a doorbell.
    /// </summary>
    /// Author: Devon X. Dalrymple
    /// Version: 2022-08-10
    public class DoorbellUpdateData
    {
        /// <summary>
        /// The display name of the doorbell that will be seen when joining its call. User friendly name.
        /// </summary>
        public string DisplayName { get; set; }

        /// <summary>
        /// The UNIX time in seconds since EPOCH that the doorbell was last turned on. UTC time.
        /// </summary>
        public long LastTurnedOn { get; set; } // When the doorbell was turned on
        
        /// <summary>
        /// A user friendly string (In English) that identifies the current status of the doorbell.
        /// </summary>
        public string DoorbellStatus { get; set; }


        /// <summary>
        /// The UNIX time in seconds since EPOCH that the button on the doorbell was last pressed. UTC time.
        /// </summary>
        public long LastActivationUnix { get; set; } // Last time the button was pressed

    }
}
