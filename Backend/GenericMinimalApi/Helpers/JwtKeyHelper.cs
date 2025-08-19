using System.Text;
using Microsoft.IdentityModel.Tokens;

namespace GenericMinimalApi.Helpers
{
    public static class JwtKeyHelper
    {
        public static SymmetricSecurityKey BuildSigningKey(IConfiguration cfg)
        {
            var key = cfg["Jwt:Key"] ?? throw new InvalidOperationException("Jwt:Key is not configured.");
            key = key.Trim();

            byte[] keyBytes;

            if (key.StartsWith("base64:", StringComparison.OrdinalIgnoreCase))
            {
                var b64 = key.Substring("base64:".Length).Trim();

                try
                {
                    // standard Base64
                    keyBytes = Convert.FromBase64String(b64);
                }
                catch (FormatException)
                {
                    // tolerate base64url by normalizing
                    var b64url = b64.Replace('-', '+').Replace('_', '/');
                    switch (b64url.Length % 4)
                    {
                        case 2: b64url += "=="; break;
                        case 3: b64url += "="; break;
                    }
                    keyBytes = Convert.FromBase64String(b64url);
                }
            }
            else
            {
                // raw text
                keyBytes = Encoding.UTF8.GetBytes(key);
            }

            if (keyBytes.Length < 32)
                throw new ArgumentOutOfRangeException(nameof(keyBytes),
                    $"JWT key must be at least 32 bytes (256 bits); got {keyBytes.Length}.");

            return new SymmetricSecurityKey(keyBytes);
        }
    }
}
