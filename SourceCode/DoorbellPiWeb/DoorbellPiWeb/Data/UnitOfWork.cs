using DoorbellPiWeb.Data;
using DoorbellPiWeb.Models.Db;
using System;

namespace DoorbellPiWeb.Data
{
    /// <summary>
    /// The class <c>UnitOfWork</c> is used to ensure that changes get saved to all repositories, 
    /// and that repositories can be easily given to each controller without constantly taking them all in
    /// as parameters to that controller's constructor.
    /// </summary>
    public class UnitOfWork : IDisposable
    {
        private DoorbellDbContext _context;


        private bool disposed = false;

        /// <summary>
        /// Initializes a new instance of the <see cref="UnitOfWork"/> class which is used to access the repositories from one place and save changes in all repositories.
        /// </summary>
        /// <param name="context">The context repository.</param>
        /// <param name="videoChatRepo">The repository to manage the various video chat sessions between app users and a doorbell.</param>
        public UnitOfWork(DoorbellDbContext context, 
            RepositoryBase<VideoChat> videoChatRepo,
            RepositoryBase<RelatedFile> relatedFileRepo)
        {
            _context = context;
            VideoChatRepo = videoChatRepo;
            RelatedFileRepo = relatedFileRepo;

        }
        
        public RepositoryBase<VideoChat> VideoChatRepo { get; set; }
        
        public RepositoryBase<RelatedFile> RelatedFileRepo { get; set; }


        /// <summary>
        /// Saves the changes made in the repositories to the database
        /// </summary>
        public void Save()
        {
            _context.SaveChanges();
        }

        /// <summary>
        /// Disposes of the database object in order to prepare itself to be disposed
        /// </summary>
        /// <param name="disposing">Is this object being disposed?</param>
        protected virtual void Dispose(bool disposing)
        {
            if (!this.disposed)
            {
                if (disposing)
                {
                    _context.Dispose();
                }
            }
            this.disposed = true;
        }

        /// <summary>
        /// Calls upon this object to dispose of itself, and its parts
        /// </summary>
        public void Dispose()
        {
            Dispose(true);
            GC.SuppressFinalize(this);
        }
    }
}