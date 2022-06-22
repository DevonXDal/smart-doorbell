using DoorbellPiWeb.Models.Db.NotMapped;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Threading.Tasks;

namespace DoorbellPiWeb.Models.Db
{
    public class RelatedFile : EntityBase
    {
        [MaxLength(255)]
        [Display(Name = "File Path")]
        public String FilePath { get; set; }

        [MaxLength(255)]
        [Display(Name = "File Name")]
        public String FileName { get; set; }

        public int? VideoChatId { get; set; }

        [ForeignKey("ProjectId")]
        public virtual VideoChat? VideoChat { get; set; }

        


    }
}
