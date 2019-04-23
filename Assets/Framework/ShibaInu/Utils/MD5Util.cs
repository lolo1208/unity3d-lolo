using System.IO;
using System.Text;
using System.Security.Cryptography;


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
        public static string GetMD5(string str, bool isShort = true)
        {

            MD5CryptoServiceProvider md5 = new MD5CryptoServiceProvider();
            byte[] data = Encoding.UTF8.GetBytes(str);
            byte[] md5Data = md5.ComputeHash(data, 0, data.Length);
            md5.Clear();

            string destString = "";
            int len = md5Data.Length;
            for (int i = 0; i < len; i++)
            {
                destString += System.Convert.ToString(md5Data[i], 16).PadLeft(2, '0');
            }
            destString = destString.PadLeft(32, '0');

            if (isShort)
                return destString.Substring(8, 16);
            else
                return destString;
        }




        /// <summary>
        /// 获取文件的 MD5 值
        /// </summary>
        /// <returns>The file MD5.</returns>
        /// <param name="filePath">File path.</param>
        /// <param name="isShort">If set to <c>true</c> is short.</param>
        public static string GetFileMD5(string filePath, bool isShort = true)
        {
            FileStream fs = new FileStream(filePath, FileMode.Open);
            MD5 md5 = new MD5CryptoServiceProvider();
            byte[] retVal = md5.ComputeHash(fs);
            fs.Close();

            StringBuilder sb = new StringBuilder();
            int len = retVal.Length;
            for (int i = 0; i < len; i++)
            {
                sb.Append(retVal[i].ToString("x2"));
            }

            if (isShort)
                return sb.ToString().Substring(8, 16);

            return sb.ToString();
        }


        //
    }
}

