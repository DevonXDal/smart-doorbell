using DoorbellPiWeb.Models.Db.NotMapped;

namespace DoorbellPiWeb.Models.Db
{
    /// <summary>
    /// This DeviceConnection class holds data specific to the connected end-user apps that will be able to connect to calls with the doorbell.
    /// It is seperated from the doorbell connection to better control how details are sent back to the app and keep models 
    /// related to the doorbell seperate.
    /// </summary>
    public class AppConnection : DeviceConnection
    {
        
    }
}
