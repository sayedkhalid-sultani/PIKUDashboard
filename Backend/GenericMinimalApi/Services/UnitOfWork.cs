// UnitOfWork.cs content placeholder
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using System.Data;

namespace GenericMinimalApi.Services
{
    public class UnitOfWork : IUnitOfWork
    {
        private readonly IConfiguration _config;
        private SqlConnection? _connection;
        private SqlTransaction? _transaction;

        public UnitOfWork(IConfiguration config)
        {
            _config = config;
        }

        public IDbConnection Connection => _connection!;
        public IDbTransaction Transaction => _transaction!;

        public async Task BeginTransactionAsync()
        {
            _connection = new SqlConnection(_config.GetConnectionString("DefaultConnection"));
            await _connection.OpenAsync();
            _transaction = _connection.BeginTransaction();
        }

        public Task CommitTransactionAsync()
        {
            _transaction?.Commit();
            Dispose();
            return Task.CompletedTask;
        }

        public Task RollbackTransactionAsync()
        {
            _transaction?.Rollback();
            Dispose();
            return Task.CompletedTask;
        }

        public void Dispose()
        {
            _transaction?.Dispose();
            _connection?.Dispose();
        }
    }
}
