using System;
using System.IO;

namespace NKKWeightScaleApp.Services
{
    public class LoggerController
    {
        private static string _Path = string.Empty;

        public static void WriteException(Exception exception, string fileName)
        {
            _Path = Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().Location);
            string filePath = fileName != null ? string.Format(@"{0}ERROR", fileName) : @"Error";
            string logFolderFilePath = Path.Combine(_Path, "Logs\\Exception");
            if (!File.Exists(logFolderFilePath))
            {
                Directory.CreateDirectory(logFolderFilePath);
            }
            string path = Path.Combine(_Path, "Logs\\Exception\\" + filePath + string.Format("_{0}.txt", DateTime.Now.ToString("MM-dd-yyyy")));
            try
            {
                using (StreamWriter logWriter = File.AppendText(path))
                {
                    logWriter.WriteLine("Message :" + exception.Message + Environment.NewLine + "StackTrace :" + exception.StackTrace +
                       "" + Environment.NewLine + "Date :" + DateTime.Now.ToLongTimeString());
                    logWriter.WriteLine(Environment.NewLine + "-----------------------------------------------------------------------------" + Environment.NewLine);
                    logWriter.Flush();
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex);
            }
        }

        public static void WriteLog(string strLog, string name)
        {
            _Path = Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().Location);
            string logFilePath = Path.Combine(_Path, "Logs\\History\\" + string.Format("{0}.txt", DateTime.Now.ToString("MM-dd-yyyy")));
            FileInfo logFileInfo = new FileInfo(logFilePath);
            DirectoryInfo logDirInfo = new DirectoryInfo(logFileInfo.DirectoryName);
            if (!logDirInfo.Exists) logDirInfo.Create();
            try
            {
                using (FileStream fileStream = new FileStream(logFilePath, FileMode.Append))
                {
                    using (StreamWriter log = new StreamWriter(fileStream))
                    {
                        log.WriteLine(DateTime.Now.ToString() + "," + name +","+ strLog);
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex);
            }
        }
    }
}