using System.ComponentModel.DataAnnotations.Schema;

namespace DoorbellPiWeb.Models.Db.NotMapped
{
    /// <summary>
    /// The entity base class represents the data that is common to the various database models. 
    /// It provides the capability to perform soft deletes and view the time of data creation.
    /// </summary>
    [NotMapped]
    public abstract class EntityBase
    {
        public int Id { get; set; }

        public DateTime Created { get; set; }

        public DateTime LastModified { get; set; }

        public bool IsDeleted { get; set; }
        
    }
}
