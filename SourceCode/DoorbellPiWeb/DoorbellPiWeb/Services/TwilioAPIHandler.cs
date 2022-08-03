using DoorbellPiWeb.Models.RequestResponseData;
using Twilio;
using Twilio.Base;
using Twilio.Jwt.AccessToken;
using Twilio.Rest.Video.V1;
using Twilio.Rest.Video.V1.Room;
using Twilio.TwiML.Video;
using static Twilio.Rest.Video.V1.RoomResource;
using ParticipantStatus = Twilio.Rest.Video.V1.Room.ParticipantResource.StatusEnum;

namespace DoorbellPiWeb.Services
{
    /// <summary>
    /// This source code is from a blog on the Twilio website: https://www.twilio.com/blog/video-chat-app-asp-net-core-angular-twilio
    /// 
    /// It has been modified slightly to fit this project.
    /// </summary>
    public class TwilioAPIHandler
    {
        readonly IConfiguration _config;

        public TwilioAPIHandler(IConfiguration config)
        {
            _config = config;

            TwilioClient.Init(_config["Twilio:TwilioAccountSID"], _config["Twilio:TwilioAuthToken"]);
        }

        public string GetTwilioJwt(string identity)
            => new Token(_config["Twilio:TwilioAccountSID"],
                         _config["Twilio:TwilioApiKeySID"],
                         _config["Twilio:TwilioApiKeySecret"],
                         identity ?? Guid.NewGuid().ToString(),
                         grants: new HashSet<IGrant> {
                             new VideoGrant()
                         }).ToJwt();

        public async Task<IEnumerable<RoomDetails>> GetAllRoomsAsync()
        {
            var rooms = await ReadAsync();
            var tasks = rooms.Select(
                room => GetRoomDetailsAsync(
                    room,
                    ParticipantResource.ReadAsync(
                        room.Sid,
                        ParticipantStatus.Connected)));

            return await Task.WhenAll(tasks);

            async Task<RoomDetails> GetRoomDetailsAsync(
                RoomResource room,
                Task<ResourceSet<ParticipantResource>> participantTask)
            {
                var participants = await participantTask;
                return new RoomDetails
                {
                    Name = room.UniqueName,
                    MaxParticipants = room.MaxParticipants ?? 0,
                    ParticipantCount = participants.ToList().Count
                };
            }
        }

        public async Task<RoomResource> CreateRoomAsync()
        {
            return await CreateAsync(new CreateRoomOptions()
            {
                MaxParticipantDuration = 298, // Five minutes of join time for a participant. It is two seconds less in order to avoid the possibility that it will register as 6 minutes for billing purposes
                EmptyRoomTimeout = 1, // One minute of no one joining leads to a shutdown of the call
                Type = RoomTypeEnum.PeerToPeer, // Participants connect usually directly to each other (supports the one video/audio participant [the doorbell] and 10 total audio participants.
                UnusedRoomTimeout = 1, // If no one is in the call for a minute, shut it down. 

            });
        }
    }
}