using System.ComponentModel.DataAnnotations.Schema;

namespace DoorbellPiWeb.Models.Db.NotMapped
{
    /// <summary>
    /// This DeviceConnection class represents the data that is common to the various device connection database models.
    /// This includes information such as display names, uuids, and whether the device has been banned from accessing the system.
    /// </summary>
    [NotMapped]
    public class DeviceConnection : EntityBase
    {
        public string DisplayName { get; set; }

        public string UUID { get; set; }

        public DateTime LastLoginTime { get; set; }

        public bool IsBanned { get; set; }
    }
}
