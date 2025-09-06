using GenericMinimalApi.Models;
using GenericMinimalApi.Services;
using Microsoft.Extensions.Options;

namespace GenericMinimalApi.Workers
{
    public class ErrorLogCleanupWorker : BackgroundService
    {
        private readonly IServiceProvider _sp;
        private readonly ILogger<ErrorLogCleanupWorker> _logger;
        private readonly MaintenanceOptions _opts;

        public ErrorLogCleanupWorker(
            IServiceProvider sp,
            IOptions<MaintenanceOptions> opts,
            ILogger<ErrorLogCleanupWorker> logger)
        {
            _sp = sp;
            _logger = logger;
            _opts = opts.Value;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            // small initial delay so app finishes warmup
            await Task.Delay(TimeSpan.FromSeconds(10), stoppingToken);

            var interval = TimeSpan.FromMinutes(Math.Max(1, _opts.PurgeIntervalMinutes));

            while (!stoppingToken.IsCancellationRequested)
            {
                try
                {
                    // await PurgeAsync(stoppingToken);
                }
                catch (OperationCanceledException) when (stoppingToken.IsCancellationRequested) { }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "ErrorLogCleanupWorker failed.");
                }

                try
                {
                    await Task.Delay(interval, stoppingToken);
                }
                catch (OperationCanceledException) { /* shutting down */ }
            }
        }

        private async Task PurgeAsync(CancellationToken ct)
        {
            using var scope = _sp.CreateScope();
            var dapper = scope.ServiceProvider.GetRequiredService<IDapperService>();

            var cutoff = DateTime.UtcNow.AddDays(-Math.Max(1, _opts.ErrorLogRetentionDays));

            // Reuse ExecuteWithOutputAsync so message comes back and gets logged to app logs
            var (success, message) = await dapper.ExecuteWithOutputAsync(
                "PurgeOldErrorLogs",
                new { CutoffUtc = cutoff }
            );

            if (success)
                _logger.LogInformation("ErrorLog purge completed: {Message}", message);
            else
                _logger.LogWarning("ErrorLog purge reported failure: {Message}", message);
        }
    }
}
