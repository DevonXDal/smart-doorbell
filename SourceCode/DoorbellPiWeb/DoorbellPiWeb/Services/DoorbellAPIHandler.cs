using DoorbellPiWeb.Data;
using DoorbellPiWeb.Enumerations;
using DoorbellPiWeb.Models.Db;
using DoorbellPiWeb.Models.Json;
using DoorbellPiWeb.Models.Json.FromDoorbell;

namespace DoorbellPiWeb.Services
{
    /// <summary>
    /// This DoorbellAPIHandler class serves to make requests to one or more doorbells. 
    /// This is seperated from the controllers to provide a centralized location where this is performed and to seperate responsibilities.
    /// 
    /// Author: Devon X. Dalrymple
    /// Version: 2022-07-11
    /// </summary>
    public class DoorbellAPIHandler
    {
        private readonly UnitOfWork _unitOfWork;

        private readonly IConfiguration _config;

        private readonly IHttpClientFactory _httpClientFactory;

        public DoorbellAPIHandler(UnitOfWork unitOfWork, IConfiguration config, IHttpClientFactory httpClientFactory)
        {
            _unitOfWork = unitOfWork;
            _config = config;
            _httpClientFactory = httpClientFactory;
        }

        public async Task<DoorbellStatus> RequestDoorbellUpdate(DoorbellConnection doorbell)
        {
            var httpClient = _httpClientFactory.CreateClient();
            httpClient.Timeout = TimeSpan.FromSeconds(10);

            var getRequestMessage = new HttpRequestMessage(HttpMethod.Get, GetFullURL(doorbell, "/FetchStatusUpdate/"));

            

            try
            {
                var dataUpdateResponse = await httpClient.SendAsync(getRequestMessage);
                dataUpdateResponse.EnsureSuccessStatusCode();

                var stateAsString = (await dataUpdateResponse.Content.ReadFromJsonAsync<DoorbellStateString>()).State;

                DoorbellState state = DoorbellState.Idle;
                switch (stateAsString)
                {
                    case "IDLE":
                        state = DoorbellState.Idle;
                        break;
                    case "AWAITING":
                        state = DoorbellState.ButtonRecentlyActivated;
                        break;
                    case "IN_CALL":
                        state = DoorbellState.InCall;
                        break;
                    default:
                        break; // Assume it is idle
                }

                _unitOfWork.DoorbellStatusRepo.Insert(new DoorbellStatus
                {
                    DoorbellConnectionId = doorbell.Id,
                    State = state
                });

            }
            catch (HttpRequestException _)
            {
                _unitOfWork.DoorbellStatusRepo.Insert(new DoorbellStatus
                {
                    DoorbellConnectionId = doorbell.Id,
                    State = DoorbellState.UnreachableOrOff
                });
            }

            return _unitOfWork.DoorbellStatusRepo.Get().OrderByDescending(x => x.Created).FirstOrDefault();
        }

        // This simplifies the url process for the requests by only requiring the path to go along with the URL.
        // This does not provide the leading '/' before the path
        private string GetFullURL(DoorbellConnection doorbell, string path)
        {
            return $"https://{doorbell.IPAddress}:{doorbell.PortNumber}{path}";
        }
    }
}
