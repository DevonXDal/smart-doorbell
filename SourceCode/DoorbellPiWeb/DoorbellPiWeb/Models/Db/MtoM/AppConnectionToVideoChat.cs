using DoorbellPiWeb.Models.Db.NotMapped;
using System.ComponentModel.DataAnnotations.Schema;

namespace DoorbellPiWeb.Models.Db.MtoM
{
    /// <summary>
    /// This <see cref="AppConnectionToVideoChat"/> class represents the many app connections that are made to many different video chats.
    /// This exists to keep track of participants in each video call and for other data displaying purposes.
    /// </summary>
    public class AppConnectionToVideoChat : EntityBase
    {
        public int? AppConnectionId { get; set; }

        [ForeignKey("AppConnectionId")]
        public virtual AppConnection? AppConnection { get; set; }

        public int? VideoChatId { get; set; }

        [ForeignKey("VideoChatId")]
        public virtual VideoChat? VideoChat { get; set; }
    }
}
