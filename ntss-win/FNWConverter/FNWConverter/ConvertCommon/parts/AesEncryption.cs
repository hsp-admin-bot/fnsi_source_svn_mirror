using System;
using System.IO;
using System.Security.Cryptography;
using System.Text;


namespace ConvertCommon.parts
{
    public class AesEncryption
    {
        private static readonly string Key = "YX3HC3VMB724YTPM3KCKMJE64HMWXKMU";
        private static readonly string Iv = "L7CJ99TE9RBLR7HK";

        public static string Encrypt(string plainText)
        {
            if (string.IsNullOrEmpty(plainText))
                throw new ArgumentNullException(nameof(plainText));

            byte[] keyBytes = Encoding.UTF8.GetBytes(Key);

            byte[] ivBytes = Encoding.UTF8.GetBytes(Iv);
            byte[] plainTextBytes = Encoding.UTF8.GetBytes(plainText);

            using (Aes aes = Aes.Create())
            {
                aes.Key = keyBytes;
                aes.IV = ivBytes;
                aes.Mode = CipherMode.CBC;
                aes.Padding = PaddingMode.PKCS7;

                using (MemoryStream ms = new MemoryStream())
                {
                    using (CryptoStream cs = new CryptoStream(ms, aes.CreateEncryptor(), CryptoStreamMode.Write))
                    {
                        cs.Write(plainTextBytes, 0, plainTextBytes.Length);
                    }

                    byte[] encryptedBytes = ms.ToArray();
                    return Convert.ToBase64String(encryptedBytes);
                }
            }
        }
    }
}
