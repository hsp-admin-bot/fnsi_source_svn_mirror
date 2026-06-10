using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Runtime.InteropServices;

namespace LayoutDesignerInstallTool
{
    class Program
    {
        // Windows Installer API
        private const int MSIDBOPEN_READONLY = 0;
        private const int MSIDBOPEN_TRANSACT = 1;
        private const int MSI_OPEN_DATABASE_MODE = 1; // MSIDBOPEN_TRANSACT

        // error code
        private const int ERROR_SUCCESS = 0;
        private const int ERROR_NO_MORE_ITEMS = 259;

        // Windows Installer API P/Invoke 
        [DllImport("msi.dll", CharSet = CharSet.Unicode)]
        private static extern int MsiOpenDatabase(string szDatabasePath, IntPtr phPersist, out IntPtr phDatabase);

        [DllImport("msi.dll", CharSet = CharSet.Unicode)]
        private static extern int MsiDatabaseOpenView(IntPtr hDatabase, string szQuery, out IntPtr phView);

        [DllImport("msi.dll")]
        private static extern int MsiViewExecute(IntPtr hView, IntPtr hRecord);

        [DllImport("msi.dll")]
        private static extern int MsiViewFetch(IntPtr hView, out IntPtr phRecord);

        [DllImport("msi.dll", CharSet = CharSet.Unicode)]
        private static extern int MsiRecordGetString(IntPtr hRecord, int iField, StringBuilder szValueBuf, ref int pcchValueBuf);

        [DllImport("msi.dll")]
        private static extern int MsiRecordGetInteger(IntPtr hRecord, int iField);

        [DllImport("msi.dll")]
        private static extern int MsiRecordIsNull(IntPtr hRecord, int iField);

        [DllImport("msi.dll")]
        private static extern int MsiRecordSetString(IntPtr hRecord, int iField, string value);

        [DllImport("msi.dll")]
        private static extern IntPtr MsiCreateRecord(int cParams);

        [DllImport("msi.dll")]
        private static extern int MsiDatabaseCommit(IntPtr hDatabase);

        [DllImport("msi.dll")]
        private static extern int MsiCloseHandle(IntPtr hAny);

        [DllImport("msi.dll")]
        private static extern int MsiViewClose(IntPtr hView);

        static List<string> coverFileList = new List<string>
        {
            "DataListBase.xml",
            "DataVersion.xml",
            "DataList.xml",
            "DataOrder.xml"
        };

        public class MsiFileEntry
        {
            public string FileId { get; set; }
            public string FileName { get; set; }
        }

        static int Main(string[] args)
        {
            // have not msi file
            if (args.Length < 1)
            {
                PrintUsage();
                return 1;
            }

            // msi file
            string msiPath = args[0];

            // check msi file exist
            if (!File.Exists(msiPath))
            {
                Console.WriteLine($"Error: MSI File is not Exist!: {msiPath}");
                return 1;
            }

            try
            {
                // when argement is many, first argement: MSI File path, other is update file name
                return UpdateByFileNames(msiPath);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error: {ex.Message}");
                Console.WriteLine($"Stack: {ex.StackTrace}");
                return 1;
            }
        }

        // print usage
        static void PrintUsage()
        {
            Console.WriteLine("MSI File Update Tool");
            Console.WriteLine("  MsiVersionCli <Msi file path>                      - display file list");
            Console.WriteLine();
            Console.WriteLine("Example:");
            Console.WriteLine(@"  MsiVersionCli.exe ""D:\work\setup.msi""");
        }

        // when argement is many, first argement: MSI File path, other is update file name
        static int UpdateByFileNames(string msiPath)
        {
            var allMatchedFiles = new List<MsiFileEntry>();

            foreach (string fileName in coverFileList)
            {
                var matchedFiles = FindFilesByExactName(msiPath, fileName);
                if (matchedFiles.Count == 0)
                {
                    Console.WriteLine($"Warn: not find file: {fileName}");
                }
                else
                {
                    allMatchedFiles.AddRange(matchedFiles);
                }
            }

            if (allMatchedFiles.Count == 0)
            {
                Console.WriteLine("not find matched file:");
                return 1;
            }

            Console.WriteLine($"find {allMatchedFiles.Count} matched file:");
            foreach (var fileInfo in allMatchedFiles)
            {
                Console.WriteLine($"  - {fileInfo.FileId} -> {fileInfo.FileName}");
            }

            int updatedCount = UpdateFileVersions(msiPath, allMatchedFiles.ConvertAll(f => f.FileId));
            Console.WriteLine($"Update success {updatedCount} file version");
            return updatedCount > 0 ? 0 : 1;
        }

        // find file
        static List<MsiFileEntry> FindFilesByExactName(string msiPath, string fileName)
        {
            var files = new List<MsiFileEntry>();
            IntPtr hDatabase = IntPtr.Zero;
            IntPtr hView = IntPtr.Zero;
            IntPtr hRecord = IntPtr.Zero;

            try
            {
                // open database from msi file
                int result = MsiOpenDatabase(msiPath, (IntPtr)MSIDBOPEN_READONLY, out hDatabase);
                if (result != ERROR_SUCCESS)
                {
                    Console.WriteLine($"Not open MSI file: {result}");
                    return files;
                }

                // open database view
                result = MsiDatabaseOpenView(hDatabase, "SELECT `File`, `FileName` FROM `File`", out hView);
                if (result != ERROR_SUCCESS) return files;

                result = MsiViewExecute(hView, IntPtr.Zero);
                if (result != ERROR_SUCCESS) return files;

                // loop all record
                while (MsiViewFetch(hView, out hRecord) == ERROR_SUCCESS)
                {
                    try
                    {
                        // get field: File (field 1)
                        string fileId = GetStringFromRecord(hRecord, 1);

                        // get field: File name (field 2)
                        string fullFileName = GetStringFromRecord(hRecord, 2);

                        // check file name
                        if (fullFileName.Contains("|" + fileName))
                        {
                            files.Add(new MsiFileEntry { FileId = fileId, FileName = fullFileName });
                        }
                    }
                    finally
                    {
                        if (hRecord != IntPtr.Zero)
                        {
                            MsiCloseHandle(hRecord);
                            hRecord = IntPtr.Zero;
                        }
                    }
                }
            }
            finally
            {
                // free
                if (hView != IntPtr.Zero)
                {
                    MsiViewClose(hView);
                    MsiCloseHandle(hView);
                }
                if (hDatabase != IntPtr.Zero)
                {
                    MsiCloseHandle(hDatabase);
                }
            }

            return files;
        }

        // updata file version
        static int UpdateFileVersions(string msiPath, List<string> targetFiles)
        {
            int updatedCount = 0;
            IntPtr hDatabase = IntPtr.Zero;
            IntPtr hView = IntPtr.Zero;
            IntPtr hRecord = IntPtr.Zero;

            try
            {
                // open database view for updata
                int result = MsiOpenDatabase(msiPath, (IntPtr)MSIDBOPEN_TRANSACT, out hDatabase);
                if (result != ERROR_SUCCESS)
                {
                    Console.WriteLine($"Not open MSI file: {result}");
                    return 0;
                }

                string newVersion = "99.99.99.99";

                foreach (string fileId in targetFiles)
                {
                    // open UPDATE view
                    result = MsiDatabaseOpenView(hDatabase,
                        "UPDATE `File` SET `Version` = ? WHERE `File` = ?",
                        out hView);

                    if (result != ERROR_SUCCESS) continue;

                    // get record
                    hRecord = MsiCreateRecord(2);
                    if (hRecord == IntPtr.Zero) continue;

                    // set new version
                    result = MsiRecordSetString(hRecord, 1, newVersion);
                    if (result != ERROR_SUCCESS) continue;

                    result = MsiRecordSetString(hRecord, 2, fileId);
                    if (result != ERROR_SUCCESS) continue;

                    // update
                    result = MsiViewExecute(hView, hRecord);
                    if (result == ERROR_SUCCESS)
                    {
                        updatedCount++;
                        Console.WriteLine($"Update: {fileId} -> {newVersion}");
                    }

                    // free
                    if (hView != IntPtr.Zero)
                    {
                        MsiViewClose(hView);
                        MsiCloseHandle(hView);
                        hView = IntPtr.Zero;
                    }

                    if (hRecord != IntPtr.Zero)
                    {
                        MsiCloseHandle(hRecord);
                        hRecord = IntPtr.Zero;
                    }
                }

                // commit
                if (updatedCount > 0)
                {
                    result = MsiDatabaseCommit(hDatabase);
                    if (result != ERROR_SUCCESS)
                    {
                        Console.WriteLine($"commit false: {result}");
                    }
                }
            }
            finally
            {
                // free
                if (hView != IntPtr.Zero)
                {
                    MsiViewClose(hView);
                    MsiCloseHandle(hView);
                }
                if (hRecord != IntPtr.Zero)
                {
                    MsiCloseHandle(hRecord);
                }
                if (hDatabase != IntPtr.Zero)
                {
                    MsiCloseHandle(hDatabase);
                }
            }

            return updatedCount;
        }

        // get value from record
        private static string GetStringFromRecord(IntPtr hRecord, int field)
        {
            // malloc
            int bufferSize = 0;
            int result = MsiRecordGetString(hRecord, field, null, ref bufferSize);

            if (result == ERROR_SUCCESS)
            {
                // remalloc
                StringBuilder buffer = new StringBuilder(bufferSize + 1);
                bufferSize = buffer.Capacity;
                result = MsiRecordGetString(hRecord, field, buffer, ref bufferSize);

                if (result == ERROR_SUCCESS)
                {
                    return buffer.ToString();
                }
            }

            return string.Empty;
        }
    }
}
