namespace DoorbellPiWeb.Models.RequestResponseData
{
    /// <summary>
    /// This DeviceLoginModel is information used by the Web server to determine if an app or doorbell will be allowed access.
    /// Nullable fields are required only for authenticating doorbells.
    /// </summary>
    /// Author: Devon X. Dalrymple
    /// Version: 2022-08-10
    public class DeviceLoginModel
    {
        /// <summary>
        /// A UUID that identifies some unique characteristic of the device such as a MAC address or a random assortment of operating system jargon.
        /// Operating system jargon should contain enough information that no other device would count.
        /// A GUID number is also acceptable.
        /// The device should maintain this UUID for other requests.
        /// </summary>
        public string DeviceUUID { get; set; }

        /// <summary>
        /// How the app or doorbell will be named when fetching data about them. 
        /// This should be three or more letters. 
        /// Your device display name will have a number appended to it on the server if something else if currently using the same display name.
        /// All display names on the server are unique.
        /// </summary>
        public string DisplayName { get; set; }

        /// <summary>
        /// The type of device that is trying to access the Web server
        /// Expected Values:
        /// 1. "App"
        /// 2. "Doorbell"
        /// </summary>
        public string DeviceType { get; set; }

        /// <summary>
        /// The password for the server.
        /// </summary>
        public string Password { get; set; }

        // Provide these for a doorbell login

        /// <summary>
        /// REQUIRED FOR DOORBELLS: The IPv4 address that should be used to reach the doorbell.
        /// Local (NAT assigned) IPv4 addresses are fine only if the doorbell is on the same network.
        /// </summary>
        public string? IPAddress { get; set; }

        /// <summary>
        /// REQUIRED FOR DOORBELLS: The port that the doorbell will listen on for requests.
        /// This requires port forwarding if the doorbell is on a different network.
        /// </summary>
        public int? Port { get; set; }

        /// <summary>
        /// REQUIRED FOR DOORBELLS: UTC UNIX time since EPOCH in seconds since the doorbell was last turned on
        /// </summary>
        public long? LastTurnedOn { get; set; }
    }
}
