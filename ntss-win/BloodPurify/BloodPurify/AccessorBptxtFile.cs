using System.IO;
using System;
using System.Text;

namespace NKK.BloodPurify
{
    /// <summary>
    /// bptxt(UTF-8N/LF、DEのファイル形式と同じ)ファイルを読み書きするクラス
    /// </summary>
    static public class AccessorBptxtFile
    {
        static private readonly string STATIC_CLASS_NAME = "AccessorBptxtFile";

        /// <summary>
        /// 読み出し
        /// </summary>
        /// <param name="argBptxtFilePath">bptxt(UTF-8N/LF、DEのファイル形式と同じ)ファイルのパス</param>
        /// <returns>ファイルの中身</returns>
        static public string Read(string argBptxtFilePath)
        {
            string ret = "";

            try
            {
                AppCmn.WaitOne(argBptxtFilePath);

                if (File.Exists(argBptxtFilePath))
                {
                    string allText = "";

                    using (StreamReader sr = new StreamReader(File.OpenRead(argBptxtFilePath), new UTF8Encoding(false)))
                    {
                        allText = sr.ReadToEnd();
                    }

                    return allText.TrimEnd('\n'); // 末尾に「LF」があれば削除
                }
            }
            catch (Exception ex)
            {
                MyLog.AddLogInfo(STATIC_CLASS_NAME, $"{argBptxtFilePath}の読み出し時に例外が発生しました。", ex);
            }
            finally
            {
                AppCmn.ReleaseMutex(argBptxtFilePath);
            }

            return ret;
        }

        /// <summary>
        /// 書き出し(追記方式)
        /// </summary>
        /// <param name="argBptxtFilePath">bptxt(UTF-8N/LF、DEのファイル形式と同じ)ファイルのパス</param>
        /// <param name="argContent">{"null":"何も変更せずに書き出し／空ファイル作成", "null以外":"書き出す内容"}</param>
        /// <returns>{"true":"成功", "false":"失敗"}</returns>
        static public bool Write(string argBptxtFilePath, string argContent)
        {
            try
            {
                AppCmn.WaitOne(argBptxtFilePath);
                FileInfo fi = new FileInfo(argBptxtFilePath);

                using (StreamWriter sw = new StreamWriter(argBptxtFilePath, true, new UTF8Encoding(false)))
                {
                    if (null == argContent)
                    {
                        sw.Write("");
                    }
                    else
                    {
                        sw.NewLine = "\n"; // 「LF」

                        if (false == fi.Exists || 0 == fi.Length)
                        {
                            // 浄化装置での初めての書き出しの場合は装置機種名を書き込んでおく
                            var bfnp = AppCmn.BptxtFileNameParser(argBptxtFilePath);

                            if ("日機装透析装置" != bfnp["DeviceModel"])
                            {
                                sw.WriteLine($"kind=DEV\ttype={bfnp["DeviceModel"]}");
                            }
                        }

                        sw.WriteLine(argContent);
                    }
                }
            }
            catch (Exception ex)
            {
                MyLog.AddLogInfo(STATIC_CLASS_NAME, $"{argBptxtFilePath}の書き出し時に例外が発生しました。", ex);
                return false;
            }
            finally
            {
                AppCmn.ReleaseMutex(argBptxtFilePath);
            }

            return true;
        }

        /// <summary>
        /// 空ファイルでないかどうか
        /// </summary>
        /// <param name="argBptxtFilePath">bptxt(UTF-8N/LF、DEのファイル形式と同じ)ファイルのパス</param>
        /// <returns>{"0":"空ファイル, "1":"中身あり", "-1":"ファイルが存在しない"}</returns>
        static public int IsFileNoEmpty(string argBptxtFilePath)
        {
            int ret = 0;

            try
            {
                AppCmn.WaitOne(argBptxtFilePath);
                FileInfo fi = new FileInfo(argBptxtFilePath);

                if (fi.Exists)
                {
                    ret = (0 == fi.Length) ? 0 : 1;
                }
                else
                {
                    ret = -1;
                }
            }
            catch (Exception ex)
            {
                MyLog.AddLogInfo(STATIC_CLASS_NAME, $"{argBptxtFilePath}の読み出し時に例外が発生しました。", ex);
            }
            finally
            {
                AppCmn.ReleaseMutex(argBptxtFilePath);
            }

            return ret;
        }
    }
}

