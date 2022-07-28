namespace DoorbellPiWeb.Models.RequestResponseData
{
    public class DoorbellUpdateData
    {
        public string DisplayName { get; set; }
        public long LastTurnedOn { get; set; } // When the doorbell was turned on

        public string DoorbellStatus { get; set; }

        public long LastActivationUnix { get; set; } // Last time the button was pressed

    }
}
