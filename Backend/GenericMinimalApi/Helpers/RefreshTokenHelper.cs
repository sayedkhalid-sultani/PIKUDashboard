using System.Security.Cryptography;
using System.Text;

namespace GenericMinimalApi.Helpers
{
    public static class RefreshTokenHelper
    {
        public static string GenerateToken(int bytes = 64)
        {
            var buffer = new byte[bytes];
            RandomNumberGenerator.Fill(buffer);
            return Convert.ToBase64String(buffer); // opaque, random, safe to send to client
        }

        public static string Sha256(string value)
        {
            using var sha = SHA256.Create();
            var bytes = Encoding.UTF8.GetBytes(value);
            return Convert.ToBase64String(sha.ComputeHash(bytes)); // store only hash in DB
        }
    }
}
