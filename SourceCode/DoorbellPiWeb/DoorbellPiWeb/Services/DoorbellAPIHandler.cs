using DoorbellPiWeb.Data;
using DoorbellPiWeb.Enumerations;
using DoorbellPiWeb.Models.Db;
using DoorbellPiWeb.Models.RequestResponseData;
using DoorbellPiWeb.Models.RequestResponseData.FromDoorbell;
using Newtonsoft.Json;
using System.Text;

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

            var getRequestMessage = new HttpRequestMessage(HttpMethod.Get, GetFullURL(doorbell, "/FetchStatusUpdate/"));

            

            try
            {
                var dataUpdateResponse = await GetConfiguredHttpClient().SendAsync(getRequestMessage);
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

        /// <summary>
        ///  This is used to send the JWT token to the doorbell to join into the video call with.
        ///  This should only be called whenver an app user has joined to prevent calls where no app user connects.
        /// </summary>
        /// <param name="doorbell">The doorbell entering into a call with the app user(s)</param>
        /// <param name="connectionData">The data needed to join the call.</param>
        /// <returns>Whether the information was sent successfully to the doorbell.</returns>
        public async Task<bool> NotifyDoorbellOfCall(DoorbellConnection doorbell, Dictionary<string, dynamic> connectionData)
        {
            // https://stackoverflow.com/questions/37750451/send-http-post-message-in-asp-net-core-using-httpclient-postasjsonasync - Set and Cobus Kruger

            try
            {
                string serializedJsonString = JsonConvert.SerializeObject(connectionData);

                await GetConfiguredHttpClient().PostAsync(
                    GetFullURL(doorbell, "/NotifyOfAppAnswer/"), 
                    new StringContent(serializedJsonString, Encoding.UTF8, "application/json")
                    );
                

                return true;
            } catch (HttpRequestException _) // Not reaching the doorbell will lead to an Exception
            {
                return false;
            }

            
        }

        // This simplifies the url process for the requests by only requiring the path to go along with the URL.
        // This does not provide the leading '/' before the path
        private string GetFullURL(DoorbellConnection doorbell, string path)
        {
            return $"http://{doorbell.IPAddress}:{doorbell.PortNumber}{path}";
        }

        // Readies an HttpClient with a ten second timeout
        private HttpClient GetConfiguredHttpClient()
        {
            var httpClient = _httpClientFactory.CreateClient();
            httpClient.Timeout = TimeSpan.FromSeconds(10);

            return httpClient;
        }
    }
}
