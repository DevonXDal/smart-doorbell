using DoorbellPiWeb.Data;
using DoorbellPiWeb.Enumerations;
using DoorbellPiWeb.Helpers.Services;
using DoorbellPiWeb.Models.Db;
using DoorbellPiWeb.Models.Db.MtoM;
using DoorbellPiWeb.Models.RequestResponseData;
using DoorbellPiWeb.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Twilio.Rest.Video.V1;

namespace DoorbellPiWeb.Controllers
{
    /// <summary>
    /// This AppController class handles API calls coming from the app. It returns information for Twilio and connected doorbells.
    /// This controller should only be used by connecting app user type devices. All requests from the doorbell other than for authentication should be sent to
    /// the DoorbellController.
    /// Author: Devon X. Dalrymple
    /// Version 2022-08-10
    /// </summary>
    [ApiController]
    [Route("[controller]")]
    [Authorize]
    public class AppController : ControllerBase
    {
        private readonly ILogger<AppController> _logger;
        private UnitOfWork _unitOfWork;
        private readonly DoorbellAPIHandler _doorbellAPIHandler;
        private readonly TwilioAPIHandler _twilioAPIHandler;
        private readonly FileHandler _fileHandler;

        public AppController(ILogger<AppController> logger, UnitOfWork unitOfWork, DoorbellAPIHandler doorbellAPIHandler, TwilioAPIHandler twilioAPIHandler, FileHandler fileHandler)
        {
            _logger = logger;
            _unitOfWork = unitOfWork;
            _doorbellAPIHandler = doorbellAPIHandler;
            _twilioAPIHandler = twilioAPIHandler;
            _fileHandler = fileHandler;
        }

        /// <summary>
        /// Gets the current status information for every doorbell that is connected to this system and isn't marked as banned and returns them.
        /// </summary>
        /// <returns>Doorbell update information identifying the doorbell, when it was last turned on, current state, etc.</returns>
        /// <response code="200">An OK response that returns a list encoded in JSON with data for each doorbell.</response>
        /// <response code="401">The device making the request did not provide a valid JWT</response>
        [HttpGet("GetDoorbells")]
        public async Task<IActionResult> GetDoorbells()
        {
            ICollection<DoorbellConnection> doorbells = _unitOfWork.DoorbellConnectionRepo.Get(d => !d.IsBanned).ToList();

            List<DoorbellUpdateData> doorbellListData = new();
            foreach (DoorbellConnection doorbell in doorbells)
            {
                doorbellListData.Add(await GetDoorbellUpdateData(doorbell));
            }

            return Ok(doorbellListData);
        }

        /// <summary>
        /// Gets the status update information for a doorbell using the display name provided through the URL query string and returns it.
        /// </summary>
        /// <param name="doorbellDisplayName">The display name of the doorbell</param>
        /// <returns>Status update information for the doorbell</returns>
        /// <response code="200">A JSON response with a few identifying pieces of information used to represent the current state of the doorbell.</response>
        /// <response code="400">The request failed because either the doorbell was not found or it is banned from the Web server</response>
        /// <response code="401">The device making the request did not provide a valid JWT</response>
        [HttpGet("GetDoorbellUpdate")]
        public async Task<IActionResult> GetDoorbellUpdate([FromQuery] string doorbellDisplayName)
        {
            DoorbellConnection? doorbell = _unitOfWork.DoorbellConnectionRepo.Get(d => d.DisplayName == doorbellDisplayName && !d.IsBanned).FirstOrDefault();

            if (doorbell == null)
            {
                return BadRequest(); // The doorbell with the display name is not on this server (or it is banned)
            }

            return Ok(await GetDoorbellUpdateData(doorbell));
        }

        /// <summary>
        /// Gets the image that the doorbell, specified by its display name in the query string, sent when the button was last pressed.
        /// Although this should be used whenever the app detects that the doorbell is awaiting an answer, this will respond with the previous image if there is one.
        /// Do not use this to check for a recent button activation.
        /// </summary>
        /// <param name="doorbellDisplayName">The display name of the doorbell</param>
        /// <returns>The image if there is one of the previous doorbell activation, stored on the server</returns>
        /// <response code="200">The image taken and sent to the server when the doorbell was last activated</response>
        /// <response code="400">The doorbell was either not found or is banned</response>
        /// <response code="401">The device making the request did not provide a valid JWT</response>
        /// <response code="500">The server was unable to locate the image</response>
        [HttpGet("GetImageFromLastDoorbellPress")]
        public async Task<IActionResult> GetImageFromLastDoorbellPress([FromQuery] string doorbellDisplayName)
        {
            DoorbellConnection? doorbell = _unitOfWork.DoorbellConnectionRepo.Get(d => d.DisplayName == doorbellDisplayName && !d.IsBanned).FirstOrDefault();
            if (doorbell == null)
            {
                return BadRequest("Doorbell Not Found"); // The doorbell with the display name is not on this server (or it is banned)
            }

            RelatedFile? lastImageFile = _unitOfWork.RelatedFileRepo.Get(f => f.DoorbellConnectionId == doorbell.Id).OrderByDescending(f => f.Created).FirstOrDefault();
            if (lastImageFile == null)
            {
                return StatusCode(500, "No previous image file");
            }

            return _fileHandler.GetFile(lastImageFile);
        }

        /// <summary>
        /// Gets the Twilio JSON Web token and room name needed to connect to the Twilio room.
        /// If no other app devices were previously connected to the video call/chat room, the doorbell will also be sent the same type of information and will join the call.
        /// This requires the doorbell to be both reachable and expecting of a call (button recently pressed or in a call already).
        /// </summary>
        /// <param name="doorbellDisplayName">The display name of the doorbell</param>
        /// <param name="appDeviceUUID">The UUID that was used to authenticate the app to the Web server</param>
        /// <returns>The Twilio JWT if the data was provided correctly and at the right time</returns>
        /// <response code="200">The Twilio JSON Web token and the room name - { token: '', roomName: ''}</response>
        /// <response code="400">The doorbell was not found or is banned from the server</response>
        /// <response code="401">The device making the request did not provide a valid JWT or the app's UUID is either not known or banned</response>
        /// <response code="500">Either the doorbell is not in the required state (awaiting answer after button press or in call) or Twilio may be down</response>
        /// <response code="530">The doorbell was unable to be reached</response>
        [HttpGet("GetAccessToDoorbellVideoCallRoom")]
        public async Task<IActionResult> GetAccessToDoorbellVideoCallRoom([FromQuery] string doorbellDisplayName, [FromQuery] string appDeviceUUID)
        {
            DoorbellConnection? doorbell = _unitOfWork.DoorbellConnectionRepo.Get(d => d.DisplayName == doorbellDisplayName && !d.IsBanned).FirstOrDefault();
            if (doorbell == null)
            {
                return BadRequest("Doorbell Not Found"); // The doorbell with the display name is not on this server (or it is banned)
            }

            AppConnection? connectingApp = _unitOfWork.AppConnectionRepo.Get(a => a.UUID == appDeviceUUID && !a.IsBanned).FirstOrDefault();
            if (connectingApp == null)
            {
                return Unauthorized("App Device Not Found"); // The doorbell with the display name is not on this server (or it is banned)
            }

            try
            {
                var connectionData = await HandleVideoCallConnection(doorbell, connectingApp);

                if (connectionData == null)
                {
                    return StatusCode(530); // The connection with the doorbell failed
                }
                return new JsonResult(connectionData);
            } catch (InvalidOperationException _) // Twilio problems or doorbell state is not correct for this operation
            {
                return StatusCode(500);
            }

            
        }

        /// <summary>
        /// Gets the app users that are currently in the call with the doorbell.
        /// </summary>
        /// <param name="doorbellDisplayName">The display name of the doorbell</param>
        /// <param name="appDeviceUUID">The UUID that the app used to authenticate with</param>
        /// <returns>A JSON list of connected app display names</returns>
        /// <response code="200">An OK response with a JSON list containing the display names used for each app connected to the video chat/call</response>
        /// <response code="400">Either the doorbell does not exist or is banned</response>
        /// <response code="401">The device making the request did not provide a valid JWT or the app's UUID is either not known or banned</response>
        /// <response code="409">The doorbell is not actually in a call right now</response>
        [HttpGet("GetUsersInDoorbellsVideoChatRoom")]
        public IActionResult GetUsersInDoorbellsVideoChatRoom([FromQuery] string doorbellDisplayName, [FromQuery] string appDeviceUUID)
        {
            DoorbellConnection? doorbell = _unitOfWork.DoorbellConnectionRepo.Get(d => d.DisplayName == doorbellDisplayName && !d.IsBanned).FirstOrDefault();
            if (doorbell == null)
            {
                return BadRequest("Doorbell Not Found"); // The doorbell with the display name is not on this server (or it is banned)
            }

            AppConnection? connectingApp = _unitOfWork.AppConnectionRepo.Get(a => a.UUID == appDeviceUUID && !a.IsBanned).FirstOrDefault();
            if (connectingApp == null)
            {
                return Unauthorized("App Device Not Found"); // The doorbell with the display name is not on this server (or it is banned)
            }

            // Checks if the most recent status was of the doorbell being in a call.
            if (_unitOfWork.DoorbellStatusRepo.Get(s => s.DoorbellConnectionId == doorbell.Id).OrderByDescending(s => s.Created).FirstOrDefault().State == DoorbellState.InCall)
            {
                var currentVideoChat = _unitOfWork.VideoChatRepo.Get(v => v.DoorbellConnectionId == doorbell.Id).OrderByDescending(v => v.Created).FirstOrDefault();
                var appConnectionsForVideoChat = _unitOfWork.AppConnectionToVideoChatRepo.Get(atv => atv.VideoChatId == currentVideoChat.Id);

                List<string> displayNamesOfConnectedAppUsers = new();
                foreach (var appUser in appConnectionsForVideoChat)
                {
                    var appConnectionInformation = _unitOfWork.AppConnectionRepo.GetByID(appUser.AppConnectionId);

                    displayNamesOfConnectedAppUsers.Add(appConnectionInformation.DisplayName);
                }

                return Ok(displayNamesOfConnectedAppUsers);
            }

            return StatusCode(409); // Not in a call.
        }

        // Fetches up-to-date (up to 20 seconds old) data on the status information for the doorbell and returns it. 
        // Useful for extracting common functionality out of the Get methods for doorbell status updates.
        private async Task<DoorbellUpdateData> GetDoorbellUpdateData(DoorbellConnection doorbell)
        {
            DoorbellStatus? mostRecentStatus = _unitOfWork.DoorbellStatusRepo.Get(s => s.DoorbellConnectionId == doorbell.Id).OrderByDescending(s => s.Created).FirstOrDefault();

            if (mostRecentStatus == null || mostRecentStatus.Created.CompareTo(DateTime.UtcNow.AddSeconds(-20)) < 0)
            {
                mostRecentStatus = await _doorbellAPIHandler.RequestDoorbellUpdate(doorbell);
            }

            string state = "";
            switch (mostRecentStatus.State)
            {
                case DoorbellState.Idle:
                    state = "Idle";
                    break;
                case DoorbellState.UnreachableOrOff:
                    state = "Disconnected or Off";
                    break;
                case DoorbellState.ButtonRecentlyActivated:
                    state = "Awaiting Doorbell Answer";
                    break;
                case DoorbellState.InCall:
                    state = "In Call";
                    break;
                default:
                    state = "Unknown State";
                    break;
            }

            DateTime lastLoginTimeWithUtcKind = DateTime.SpecifyKind(doorbell.LastLoginTime, DateTimeKind.Utc);
            DateTime previousActivationTimeWithUtcKind = DateTime.SpecifyKind(doorbell.PreviousActivationTime, DateTimeKind.Utc);

            DoorbellUpdateData updateData = new DoorbellUpdateData()
            { 
                DisplayName = doorbell.DisplayName,
                DoorbellStatus = state,
                LastTurnedOn = (new DateTimeOffset(lastLoginTimeWithUtcKind)).ToUnixTimeSeconds(),
                LastActivationUnix = (new DateTimeOffset(previousActivationTimeWithUtcKind)).ToUnixTimeSeconds(),
            };

            return updateData;
        }

        // Holds the business logic for connecting an app user to a video call. 
        // Assumes doorbell has been null checked.
        // Helps to seperate the logic from the original method to keep the methods short.
        private async Task<Dictionary<String, dynamic>?> HandleVideoCallConnection(DoorbellConnection doorbell, AppConnection connectingApp) 
        {
            DoorbellState currentDoorbellState = _unitOfWork.DoorbellStatusRepo.Get().OrderByDescending(s => s.Created).FirstOrDefault().State;
            if (currentDoorbellState != DoorbellState.ButtonRecentlyActivated && currentDoorbellState != DoorbellState.InCall)
            {
                throw new InvalidOperationException("The doorbell is not waiting for or in a call");
            }

            if (currentDoorbellState == DoorbellState.ButtonRecentlyActivated) // Doorbell needs notified and a room generated with the appropriate rules.
            {
                RoomResource room = await _twilioAPIHandler.CreateRoomAsync();
                string roomName = room.Sid; // Unique name does not yeild the same name each time.

                VideoChat newVideoChat = new()
                {
                    DoorbellConnectionId = doorbell.Id,
                    HasAnyoneAppUserAnswered = true,
                    AssignedUniqueRoomName = roomName,
                };

                _unitOfWork.VideoChatRepo.Insert(newVideoChat);

                var connectionDataApp = FormatRoomConnectionData(_twilioAPIHandler.GetTwilioJwt(connectingApp.DisplayName, roomName), roomName); // App connection data
                var connectionDataDoorbell = FormatRoomConnectionData(_twilioAPIHandler.GetTwilioJwt(doorbell.DisplayName, roomName), roomName); // Doorbell connection data

                if (await _doorbellAPIHandler.NotifyDoorbellOfCall(doorbell, connectionDataDoorbell))
                {
                    _unitOfWork.DoorbellStatusRepo.Insert(new DoorbellStatus
                    {
                        DoorbellConnectionId = doorbell.Id,
                        State = DoorbellState.InCall
                    });

                    _unitOfWork.AppConnectionToVideoChatRepo.Insert(new AppConnectionToVideoChat
                    {
                        AppConnectionId = connectingApp.Id,
                        VideoChatId = newVideoChat.Id
                    });

                    return connectionDataApp;
                }

                return null;
            } 
            
            
            VideoChat videoChat = _unitOfWork.VideoChatRepo.Get(vc => vc.DoorbellConnectionId == doorbell.Id).OrderByDescending(s => s.Created).FirstOrDefault();
            var connectionData = FormatRoomConnectionData(
                _twilioAPIHandler.GetTwilioJwt(connectingApp.DisplayName, videoChat.AssignedUniqueRoomName), 
                videoChat.AssignedUniqueRoomName); // App connection data

            _unitOfWork.AppConnectionToVideoChatRepo.Insert(new AppConnectionToVideoChat
            {
                AppConnectionId = connectingApp.Id,
                VideoChatId = videoChat.Id
            });

            return connectionData;
        }

        // Combines the data for connecting to a room into a JSON capable dictionary and returns it.
        private Dictionary<String, dynamic> FormatRoomConnectionData(string twilioToken, string roomName)
        {
            Dictionary<string, dynamic> connectionData = new();

            connectionData["Token"] = twilioToken;
            connectionData["RoomName"] = roomName;

            return connectionData;
        }
    }
}