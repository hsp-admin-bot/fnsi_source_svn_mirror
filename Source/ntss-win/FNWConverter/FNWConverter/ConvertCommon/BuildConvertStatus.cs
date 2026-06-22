using System;
using System.Collections.Generic;
using System.IO;

namespace ConvertCommon
{
    // add 2020-12-13 594 insert文作成ログファイルclass う start
    public class BuildConvertStatus
    {
        // add 2020-12-13 594 データストリームは変数を読み込む う start
        private StreamReader _srRead = null;
        // add 2020-12-13 594 データストリームは変数を読み込む う end

        public BuildConvertStatus()
        {

        }

        //add 2020-12-13 594 ステータスファイルが存在するか否かを判断する う start
        public bool CheckStatusFileExist(string convertFileName)
        {
            string BaseFilePath = Directory.GetCurrentDirectory(); 
            if (File.Exists(BaseFilePath + @"\Log\" + convertFileName + ".log"))
            {
                return true;
            }
            else
            { 
                return false;
            }
        }
        //add 2020-12-13 594 ステータスファイルが存在するか否かを判断する う end

        //add 2020-12-13 594 insert文作成ログを作成する う start
        public bool CreateStatusFile(string convertFileName)
        {
            // add 2023-07-06 #8585 マルチスレッド start
            lock (Common.FileLock.config)
            {
                // add 2023-07-06 #8585 マルチスレッド end
                string BaseFilePath = Directory.GetCurrentDirectory();
                string FileName = BaseFilePath + @"\Log\" + convertFileName + ".log";
                try
                {
                    FileStream fs = new FileStream(FileName, FileMode.Create, FileAccess.ReadWrite);
                    StreamWriter sw = new StreamWriter(fs);
                    sw.Close();
                    return true;
                }
                catch (Exception ex)
                {
                    ConvertBase.WriteErrorLog("CreateStatusFile:{0}", ex.Message);
                    return false;
                }
                // add 2023-07-06 #8585 マルチスレッド start
            }
            // add 2023-07-06 #8585 マルチスレッド end
        }
        //add 2020-12-13 594 insert文作成ログを作成する う end

        //add 2020-12-13 594 開いてinsert文を入力してログを作成します う start
        public bool OpenAndWriteStatusFile(string convertFileName, string writeInfos)
        {
            // add 2023-07-06 #8585 マルチスレッド start
            lock (Common.FileLock.config)
            {
                // add 2023-07-06 #8585 マルチスレッド end
                string BaseFilePath = Directory.GetCurrentDirectory();
                string FileName = BaseFilePath + @"\Log\" + convertFileName + ".log";
                try
                {   //mod 7997 start
                    using (var sw = new StreamWriter(FileName, append: true))
                    {
                        sw.WriteLine(writeInfos);
                    }
                    //mod 7997 end
                    return true;
                }
                catch (Exception ex)
                {
                    ConvertBase.WriteErrorLog("OpenAndWriteStatusFile:{0}", ex.Message);
                    return false;
                }
                // add 2023-07-06 #8585 マルチスレッド start
            }
            // add 2023-07-06 #8585 マルチスレッド end
        }
        //add 2020-12-13 594 開いてinsert文を入力してログを作成します う end

        //add 2020-12-13 594 insert文を開いて読み込んでログを作成します う start
        public void OpenAndReadStatusFile(string convertFileName)
        {
            string BaseFilePath = Directory.GetCurrentDirectory();
            string FileName = BaseFilePath + @"\Log\" + convertFileName + ".log";
            _srRead = File.OpenText(FileName);
        }
        //add 2020-12-13 594 insert文を開いて読み込んでログを作成します う end

        //add 2020-12-13 594 insert文ログを読み込む う start
        public string ReadStatusFile()
        {
            try
            {
                string readInfo = _srRead.ReadLine();
                return readInfo;
            }
            catch (Exception ex)
            {
                ConvertBase.WriteErrorLog("OpenAndWriteStatusFile:{0}", ex.Message);
                return "読み取り失敗";
            }
        }
        //add 2020-12-13 594 insert文ログを読み込む う end

        //add 2020-12-13 594 insert文ログを読み込む う start
        public List<string> ReadStatusFile(string convertFileName)
        {
            List<string> lf = new List<string>();
            try
            {
                string BaseFilePath = Directory.GetCurrentDirectory();
                string FileName = BaseFilePath + @"\Log\" + convertFileName + ".log";
                StreamReader srRead = File.OpenText(FileName);
                string readInfo = "";
                while (readInfo != null)
                {
                    readInfo = _srRead.ReadLine();
                    lf.Add(readInfo);
                }
                return lf;
            }
            catch (Exception ex)
            {
                ConvertBase.WriteErrorLog("ReadStatusFile:{0}", ex.Message);
                lf.Add("読み取り失敗");
                return lf;
            }
        }
        //add 2020-12-13 594 insert文ログを読み込む う end
    }
    // add 2020-12-13 594 insert文作成ログファイルclass う end
}

