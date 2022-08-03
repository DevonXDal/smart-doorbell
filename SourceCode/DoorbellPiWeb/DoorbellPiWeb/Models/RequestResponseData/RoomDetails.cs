namespace DoorbellPiWeb.Models.RequestResponseData
{
    /// <summary>
    /// Source code for this RoomDetails class can be found at: https://www.twilio.com/blog/video-chat-app-asp-net-core-angular-twilio
    /// </summary>
    public class RoomDetails
    {
        public string Id { get; set; }
        public string Name { get; set; }
        public int ParticipantCount { get; set; }
        public int MaxParticipants { get; set; }
    }
}
