using Microsoft.AspNetCore.Mvc;

namespace DoorbellPiWeb.Models.RequestResponseData.FromDoorbell
{
    /// <summary>
    /// This DoorbellActivationData is for form and file data posted to this server to report that someone has activated the doorbell.
    /// 
    /// Author: Devon X. Dalrymple
    /// Version: 2022-07-27
    /// </summary>
    public class DoorbellActivationData
    {
        [FromForm]
        public IFormFile DoorbellImageFormFile { get; set; }

        [FromForm]
        public string UUID { get; set; } // Needed to know which doorbell is notifying

        [FromForm]
        public long ActivationTimeUnix { get; set; }
    }
}
