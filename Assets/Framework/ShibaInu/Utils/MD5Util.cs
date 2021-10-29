using System.IO;
using System.Security.Cryptography;
using System.Text;


namespace ShibaInu
{
    public static class MD5Util
    {


        /// <summary>
        /// 获取字符串的 MD5 值
        /// </summary>
        /// <returns>The M d5.</returns>
        /// <param name="str">String.</param>
        /// <param name="isShort">If set to <c>true</c> is short.</param>
        public static string GetMD5(string str, bool isShort = false)
        {
            using (MD5 md5 = MD5.Create())
            {
                byte[] data = md5.ComputeHash(Encoding.UTF8.GetBytes(str));
                StringBuilder sb = new StringBuilder();
                for (int i = 0; i < data.Length; i++)
                {
                    sb.Append(data[i].ToString("x2"));
                }
                string dest = sb.ToString();
                return isShort ? dest.Substring(8, 16) : dest;
            }
        }


        /// <summary>
        /// 获取文件的 MD5 值
        /// </summary>
        /// <returns>The file MD5.</returns>
        /// <param name="filePath">File path.</param>
        /// <param name="isShort">If set to <c>true</c> is short.</param>
        public static string GetFileMD5(string filePath, bool isShort = false)
        {
            using (MD5 md5 = MD5.Create())
            using (FileStream fs = new FileStream(filePath, FileMode.Open))
            {
                byte[] data = md5.ComputeHash(fs);
                StringBuilder sb = new StringBuilder();
                for (int i = 0; i < data.Length; i++)
                    sb.Append(data[i].ToString("x2"));
                string dest = sb.ToString();
                return isShort ? dest.Substring(8, 16) : dest;
            }
        }


        //
    }
}

