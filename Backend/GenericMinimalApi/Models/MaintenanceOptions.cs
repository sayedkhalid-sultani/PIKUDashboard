namespace GenericMinimalApi.Models
{
    public class MaintenanceOptions
    {
        public int ErrorLogRetentionDays { get; set; } = 7;  // keep 7 days by default
        public int PurgeIntervalMinutes { get; set; } = 360; // run every 6 hours by default
        public int CommandTimeoutSeconds { get; set; } = 60; // SQL timeout
    }
}
