using DoorbellPiWeb.Data;
using DoorbellPiWeb.Models.Db;
using DoorbellPiWeb.Models.Db.MtoM;
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
        /// <param name="relatedFileRepo">The repository to manage the files stored on this system for a doorbell.</param>
        /// <param name="doorbellConnectionRepo">The repository to manage the various doorbells that are connected to the Web server.</param>
        /// <param name="appConnectionRepo">The repository to manage the various instances of the app that are connected to the Web server.</param>
        /// <param name="doorbellStatusRepo">The repository to manage the status updates for a doorbell as they come in.</param>
        /// <param name="appConnectionToVideoChatRepo">The repository to manage the app connections to a specific video chat session</param>
        public UnitOfWork(DoorbellDbContext context, 
            RepositoryBase<VideoChat> videoChatRepo,
            RepositoryBase<RelatedFile> relatedFileRepo,
            RepositoryBase<DoorbellConnection> doorbellConnectionRepo,
            RepositoryBase<AppConnection> appConnectionRepo,
            RepositoryBase<DoorbellStatus> doorbellStatusRepo,
            RepositoryBase<AppConnectionToVideoChat> appConnectionToVideoChatRepo)
        {
            _context = context;

            VideoChatRepo = videoChatRepo;
            RelatedFileRepo = relatedFileRepo;
            AppConnectionRepo = appConnectionRepo;
            DoorbellConnectionRepo = doorbellConnectionRepo;
            AppConnectionToVideoChatRepo = appConnectionToVideoChatRepo;
            DoorbellStatusRepo = doorbellStatusRepo;

        }
        
        public RepositoryBase<VideoChat> VideoChatRepo { get; init; }
        
        public RepositoryBase<DoorbellConnection> DoorbellConnectionRepo { get; init; }
        public RepositoryBase<AppConnection> AppConnectionRepo { get; init; }
        public RepositoryBase<DoorbellStatus> DoorbellStatusRepo { get; init; }
        public RepositoryBase<RelatedFile> RelatedFileRepo { get; init; }
        public RepositoryBase<AppConnectionToVideoChat> AppConnectionToVideoChatRepo { get; init; }


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