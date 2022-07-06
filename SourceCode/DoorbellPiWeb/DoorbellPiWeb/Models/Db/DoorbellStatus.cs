using DoorbellPiWeb.Enumerations;
using DoorbellPiWeb.Models.Db.NotMapped;
using System.ComponentModel.DataAnnotations.Schema;

namespace DoorbellPiWeb.Models.Db
{
    /// <summary>
    /// This tracks the current state of the doorbell when contacted by the server
    /// </summary>
    public class DoorbellStatus : EntityBase
    {
        public DoorbellState State { get; set; }

        public int DoorbellConnectionId { get; set; }

        [ForeignKey("DoorbellConnectionId")]
        public virtual DoorbellConnection? DoorbellConnection { get; set; }
    }
}
