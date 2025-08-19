using GenericMinimalApi.Services;

public class RefreshTokenCleanupWorker : BackgroundService
{
    private readonly IServiceProvider _sp;
    public RefreshTokenCleanupWorker(IServiceProvider sp) => _sp = sp;

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            using var scope = _sp.CreateScope();
            var dapper = scope.ServiceProvider.GetRequiredService<IDapperService>();
            try
            {
                await dapper.ExecuteWithOutputAsync("PurgeExpiredRefreshTokens", new { });
            }
            catch { /* swallow */ }
            await Task.Delay(TimeSpan.FromHours(6), stoppingToken);
        }
    }
}