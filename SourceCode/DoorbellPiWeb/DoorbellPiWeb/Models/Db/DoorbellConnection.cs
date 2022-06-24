using DoorbellPiWeb.Models.Db.NotMapped;
using System.ComponentModel.DataAnnotations.Schema;

namespace DoorbellPiWeb.Models.Db
{
    /// <summary>
    /// This DoorbellConnection class serves as a model to provide information about a connected doorbell.
    /// </summary>
    public class DoorbellConnection : DeviceConnection
    {
        public string IPAddress { get; set; } // IP Address should be statically assigned.

        public int PortNumber { get; set; }

        [InverseProperty("DoorbellConnection")]
        public virtual ICollection<RelatedFile>? RelatedFiles { get; set; }

        [InverseProperty("DoorbellConnection")]
        public virtual ICollection<DoorbellStatus>? DoorbellStatuses { get; set; }
    }
}
