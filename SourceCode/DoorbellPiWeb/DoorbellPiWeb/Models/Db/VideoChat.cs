using DoorbellPiWeb.Models.Db.MtoM;
using DoorbellPiWeb.Models.Db.NotMapped;
using System.ComponentModel.DataAnnotations.Schema;

namespace DoorbellPiWeb.Models.Db
{
    /// <summary>
    /// This represents a video chat call made between a doorbell and users of the app connected to this Web server.
    /// </summary>
    public class VideoChat : EntityBase
    {
        public int DoorbellConnectionId { get; set; }

        [ForeignKey("DoorbellConnectionId")]
        public virtual DoorbellConnection? DoorbellConnection { get; set; }

        [InverseProperty("VideoChat")]
        public virtual ICollection<AppConnectionToVideoChat>? AppConnections { get; set; }

        public bool HasAnyoneAppUserAnswered { get; set; }

        public string AssignedUniqueRoomName { get; set; }
    }
}

