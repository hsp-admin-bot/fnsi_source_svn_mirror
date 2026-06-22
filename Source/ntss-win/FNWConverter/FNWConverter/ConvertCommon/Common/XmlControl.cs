using System;
using System.Text.RegularExpressions;

namespace ConvertCommon.Common
{
    /// <summary>
    /// XMLを操作・検証する関数はこちらへ集約
    /// </summary>
    public class XmlControl
    {
        /// <summary>
        /// 文字列からXML宣言を削除して返す
        /// </summary>
        /// <param name="target"></param>
        /// <returns></returns>
        public static string DeleteXmlDecleare(string target)
        {
            // XML宣言を削除する
            Regex reg = new Regex("^<\\?xml.*\\?>");
            string ret = reg.Replace(target, string.Empty);
            return ret;
        }

        /// <summary>
        /// 文字列からXMLコメントを削除して返す
        /// </summary>
        /// <param name="target"></param>
        /// <returns></returns>
        public static string DeleteXmlComments(string target)
        {
            // XMLコメントを削除する
            Regex reg = new Regex("<!--.*?-->");
            string ret = reg.Replace(target, string.Empty);
            return ret;
        }

        /// <summary>
        /// 文字列から改行を削除して返す
        /// </summary>
        /// <param name="target"></param>
        /// <returns></returns>
        public static string DeleteNewLineCode(string target)
        {
            // XMLコメントを削除する
            string ret = target.Replace("\r\n", "");
            ret = ret.Replace("\n", "");
            return ret;
        }

        /// <summary>
        /// XML文字列を指定した文字列で分割し、文字列の配列を返す
        /// </summary>
        /// <param name="target"></param>
        /// <returns></returns>
        public static string[] SplitXml(string target, string separator)
        {
            string[] separators = new string[] { separator };
            string[] ret = target.Split(separators, StringSplitOptions.RemoveEmptyEntries);
            return ret;
        }
    }
}
