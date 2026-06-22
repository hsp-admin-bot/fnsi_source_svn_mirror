using System.IO;
using System;
using System.Text.RegularExpressions;
using System.Windows.Forms;
using System.Threading;
using System.Collections;
using System.Collections.Generic;
using System.Globalization;
using System.Drawing;
using System.Text;

namespace NKK.BloodPurify
{
    static public class AppCmn
    {
        static private readonly string STATIC_CLASS_NAME = "AppCmn";

        /// <summary>win10フラットスタイルの最小化アイコン風文字のユニコード</summary>
        static public readonly int ChromeMinimize = 0xE921;
        /// <summary>win10フラットスタイルの最大化アイコン風文字のユニコード</summary>
        static public readonly int ChromeMaximize = 0xE922;
        /// <summary>win10フラットスタイルの元に戻すアイコン風文字のユニコード</summary>
        static public readonly int ChromeRestore = 0xE923;
        /// <summary>win10フラットスタイルの閉じるアイコン風文字のユニコード</summary>
        static public readonly int ChromeClose = 0xE8BB;

        /// <summary>アプリがオンラインモードなのかオフラインモードなのか(※サインイン／サインアウト状態とは別)</summary>
        static public bool IsModeOnline = false;

        /// <summary>治療データファイル(アップロードデータのみを収集するファイル)へのファイルアクセス待ちの管理に使うミューテックス</summary>
        static private Dictionary<string, Mutex> FileMutexes = new Dictionary<string, Mutex>();

        static public string GetExeDir(bool argIsSlash)
        {
            return Application.StartupPath + (argIsSlash ? Path.DirectorySeparatorChar.ToString() : "");
        }

        static public string GetCommDataDir()
        {
            return MyConfig.DataDir + @"\CommData";
        }

        /// <summary>
        /// 与えたファイルパスのファイルが既に存在する場合
        /// […\abc_1.txt],[…\abc_2.txt]と連番を振り、ぶつからなくなったら返す
        /// </summary>
        /// <param name="argFilePath">ファイルパス</param>
        /// <param name="argStartSeqNo">連番の開始数字</param>
        /// <returns>ぶつからないファイルパス</returns>
        static public string GetDistinctFilePath(string argFilePath, int argStartSeqNo)
        {
            string org = argFilePath;
            string ret = argFilePath;
            int postfix = argStartSeqNo;

            // _1,_2,_3,…,_2147483647 とぶつからなくなるまで回す
            while (true == File.Exists(ret))
            {
                ret = $"{Path.GetDirectoryName(org)}\\{Path.GetFileNameWithoutExtension(org)}_{postfix++}{Path.GetExtension(org)}";
            }

            return ret;
        }

        /// <summary>
        /// 与えたコントロール(主にフォームを想定)配下の全コントロールを取得
        /// </summary>
        /// <param name="argForm">コントロール(主にフォームを想定)</param>
        /// <returns>与えたコントロール配下の全コントロール</returns>
        static public List<Control> GetAllControls(Control argForm)
        {
            List<Control> buf = new List<Control>();
            foreach (Control c in argForm.Controls)
            {
                buf.Add(c);
                buf.AddRange(GetAllControls(c));
            }

            return buf;
        }

        /// <summary>
        /// bptxtのファイル名を解析して分解する
        /// </summary>
        /// <param name="argFileNameOrPath">bptxtのファイル名／ファイルパス</param>
        /// <returns>DeviceModel/IdName/DataStartState/DataStart/DataEndのキーを持つDictionary</returns>
        static public Dictionary<string, string> BptxtFileNameParser(string argFileNameOrPath)
        {
            Dictionary<string, string> ret = new Dictionary<string, string>();

            string fileNameNoExt = Path.GetFileNameWithoutExtension(argFileNameOrPath);

            // bptxtのファイル名(拡張子抜き)は S/K/i/9/N_装置識別名_YYYYMMDD-HHMMSS治療中/治療開始～(YYYYMMDD-HHMMSS治療終了)
            string[] splitByUnderbar = fileNameNoExt.Split('_');
            string[] splitByNami = splitByUnderbar[2].Split('～');

            // 装置機種名
            string deviceModel = "";
            switch (splitByUnderbar[0])
            {
                case "S": deviceModel = "ACH-Σ"; break;
                case "K": deviceModel = "KM-8900"; break;
                case "i": deviceModel = "プラソートiQ21"; break;
                case "9": deviceModel = "KM-9000"; break;
                case "N": deviceModel = "日機装透析装置"; break;
            }
            ret.Add("DeviceModel", deviceModel);

            // 装置識別名
            ret.Add("IdName", splitByUnderbar[1]);

            // データ記録開始時の治療状態
            ret.Add("DataStartState", splitByNami[0].Substring(15));

            // データ記録開始日時
            DateTime dtStart = DateTime.ParseExact(splitByNami[0].Substring(0, 15), "yyyyMMdd-HHmmss", DateTimeFormatInfo.InvariantInfo, DateTimeStyles.None);
            ret.Add("DataStart", dtStart.ToString("yyyy/MM/dd HH:mm:ss"));

            // データ記録終了日時
            string dataEnd = "";
            if (false == string.IsNullOrWhiteSpace(splitByNami[1]))
            {
                DateTime dtEnd = DateTime.ParseExact(splitByNami[1].Substring(0, 15), "yyyyMMdd-HHmmss", DateTimeFormatInfo.InvariantInfo, DateTimeStyles.None);
                dataEnd = dtEnd.ToString("yyyy/MM/dd HH:mm:ss");
            }
            ret.Add("DataEnd", dataEnd);

            return ret;
        }

        /// <summary>
        /// ファイルパスで一意になるMutex(※無い場合は作成も実施)を所有する
        /// </summary>
        /// <param name="argFilePath">ファイルパス</param>
        static public void WaitOne(string argFilePath)
        {
            // Mutexに「\」は使えないので「円」に置換(※苦肉の策)
            string noBackSlashFilePath = argFilePath.Replace(@"\", "円");

            if (false == FileMutexes.ContainsKey(noBackSlashFilePath))
            {
                FileMutexes.Add(noBackSlashFilePath, new Mutex(false, noBackSlashFilePath));
            }

            FileMutexes[noBackSlashFilePath].WaitOne();
        }

        /// <summary>
        /// ファイルパスで一意になるMutex(※無い場合は作成も実施)を解放する
        /// </summary>
        /// <param name="argFilePath">ファイルパス</param>
        static public void ReleaseMutex(string argFilePath)
        {
            // Mutexに「\」は使えないので「円」に置換(※苦肉の策)
            string noBackSlashFilePath = argFilePath.Replace(@"\", "円");

            if (false == FileMutexes.ContainsKey(noBackSlashFilePath))
            {
                FileMutexes.Add(noBackSlashFilePath, new Mutex(false, noBackSlashFilePath));
            }

            FileMutexes[noBackSlashFilePath].ReleaseMutex();
        }

        /// <summary>
        /// Mutexを使用してスレッドセーフにファイルをムーブ
        /// </summary>
        /// <param name="argSourceFilePath"></param>
        /// <param name="argDestFilePath"></param>
        static public void MoveWithMutex(string argSourceFilePath, string argDestFilePath)
        {
            try
            {
                WaitOne(argSourceFilePath);
                WaitOne(argDestFilePath);

                File.Move(argSourceFilePath, argDestFilePath);
            }
            catch (Exception ex)
            {
                MyLog.AddLogInfo(STATIC_CLASS_NAME, "", ex);
            }
            finally
            {
                ReleaseMutex(argSourceFilePath);
                ReleaseMutex(argDestFilePath);
            }
        }

        /// <summary>
        /// Mutexを使用してスレッドセーフにファイルを連結
        /// </summary>
        /// <param name="argSourceFilePath"></param>
        /// <param name="argDestFilePath"></param>
        static public void CatWithMutex(string argSourceFilePath, string argDestFilePath)
        {
            try
            {
                WaitOne(argSourceFilePath);
                WaitOne(argDestFilePath);

                using (FileStream fsSrc = new FileStream(argSourceFilePath, FileMode.Open, FileAccess.Read))
                {
                    using (FileStream fsDst = new FileStream(argDestFilePath, FileMode.Append, FileAccess.Write))
                    {
                        byte[] srcBytes = new byte[fsSrc.Length];
                        fsSrc.Read(srcBytes, 0, (int)fsSrc.Length);
                        fsDst.Write(srcBytes, 0, srcBytes.Length);
                    }
                }

                File.Delete(argSourceFilePath);
            }
            catch (Exception ex)
            {
                MyLog.AddLogInfo(STATIC_CLASS_NAME, "", ex);
            }
            finally
            {
                ReleaseMutex(argSourceFilePath);
                ReleaseMutex(argDestFilePath);
            }
        }

        /// <summary>
        /// コントロールを丸い形にする
        /// </summary>
        /// <param name="argCtrl">コントロール</param>
        static public void MakeControlCircle(Control argCtrl)
        {
            try
            {
                int size = 40;

                argCtrl.SetBounds(argCtrl.Left, argCtrl.Top, size, size, BoundsSpecified.Size);

                System.Drawing.Drawing2D.GraphicsPath gp = new System.Drawing.Drawing2D.GraphicsPath();
                gp.AddEllipse(new Rectangle(0, 0, size, size));

                argCtrl.Region = new Region(gp);
            }
            catch (Exception ex)
            {
                MyLog.AddLogInfo(STATIC_CLASS_NAME, "", ex);
            }
        }

        /// <summary>
        /// 3秒間リトライを行うファイル書き込み(追記方式)
        /// </summary>
        /// <param name="argText">書き込む文字列</param>
        /// <param name="argFilePath">追加先のファイルパス</param>
        /// <param name="argWriteStartDt">書込み要求日時</param>
        static public void WriteToFile(string argText, string argFilePath, DateTime argWriteStartDt)
        {
            try
            {
                using (StreamWriter w = new StreamWriter(argFilePath, true, new UTF8Encoding(false)))
                {
                    string Message = argWriteStartDt.ToString("yyyyMMdd-HHmmss ") + argText;
                    w.WriteLine(Message);
                    w.Flush();
                    w.Close();
                }
            }
            catch (IOException ex)
            {
                if (ex.Message.Substring(0, 26).Equals("別のプロセスで使用されているため、プロセスはファイル") && (DateTime.Now < argWriteStartDt.AddSeconds(3)))
                {
                    WriteToFile(argText, argFilePath, argWriteStartDt);
                }
                else
                {
                    throw;
                }
            }
            catch (Exception ex)
            {
                MyLog.AddLogInfo(STATIC_CLASS_NAME, "", ex);
            }
        }

        /// <summary>
        /// ファイルが浄化装置のものかどうか
        /// </summary>
        /// <param name="argFileNameOrPath">bptxtのファイル名／ファイルパス</param>
        /// <returns>{"true":"浄化装置", "false":"日機装透析装置"}</returns>
        static public bool IsFileBloodPurify(string argFileNameOrPath)
        {
            string fileName = Path.GetFileName(argFileNameOrPath);
            string devKindChar = fileName.Substring(0, 1);
            switch (devKindChar)
            {
                case "S":
                case "K":
                case "i":
                case "9":
                    return true;
            }

            return false;
        }
    }
}

