namespace DoorbellPiWeb.Models.Json
{
    public class DeviceLoginModel
    {
        public string DeviceUUID { get; set; }

        public string DisplayName { get; set; }

        /// <summary>
        /// The type of device that is trying to access the Web server
        /// Expected Values:
        /// 1. App
        /// 2. Doorbell
        /// </summary>
        public string DeviceType { get; set; }

        public string Password { get; set; }

        // Provide these for a doorbell login

        public string? IPAddress { get; set; }

        public int? Port { get; set; }

        public long? LastTurnedOn { get; set; }
    }
}
