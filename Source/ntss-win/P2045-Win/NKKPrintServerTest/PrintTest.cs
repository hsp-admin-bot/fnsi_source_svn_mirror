using System;
using System.Runtime.InteropServices;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using NKKPrintServer;
using System.Linq;

namespace NKKPrintServerTest
{
    [TestClass]
    public class PrintTest
    {
        [TestMethod]
        public void PrintPdfTest()
        {

            string strRegPath;
            Microsoft.Win32.RegistryKey rKey;

            // キーを取得(最初にAcrobat,だめならAdobeReader)
            strRegPath = "SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\App Paths\\Acrobat.exe";
            rKey = Microsoft.Win32.Registry.LocalMachine.OpenSubKey(strRegPath);
            if (rKey is null)
            {
                strRegPath = "SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\App Paths\\AcroRd32.exe";
                rKey = Microsoft.Win32.Registry.LocalMachine.OpenSubKey(strRegPath);
            }

            // 値(exeのパス)を取得(既定の値の場合は空文字指定)
            string location;
            try
            {
                // 値(exeのパス)を取得(既定の値の場合は空文字指定)
                location = (string)rKey.GetValue("");
            }
            catch (NullReferenceException)
            {
                throw new ApplicationException("AcrobatもしくはAdobeReaderがインストールされていないため、PDFファイルの印刷ができません。");
            }
            finally
            {
                // 開いたレジストリキーを閉じる
                rKey.Close();
            }

            // ===Acrobatを起動し印刷===
            string filepath = "D:\\20181029154718.pdf";
            System.Diagnostics.Process pro = new System.Diagnostics.Process();

            // .Net的書き方(C#でも可能な書き方)
            // Acrobatのフルパス設定
            pro.StartInfo.FileName = location;
            pro.StartInfo.Verb = "open";

            // Acrobatのコマンドライン引数設定
            //pro.StartInfo.Arguments = " /n /t " + filepath;
            pro.StartInfo.Arguments = "/s /o /h /t " + filepath + " \"EPSON LP-S950\"";
            //pro.StartInfo.WindowStyle = ProcessWindowStyle.Hidden;

            // プロセスを新しいWindowで起動
            pro.StartInfo.CreateNoWindow = true;

            // プリントサーバの情報取得
            System.Printing.LocalPrintServer prtSv = new System.Printing.LocalPrintServer();

            // 印刷キュー取得
            System.Printing.PrintQueue que = prtSv.DefaultPrintQueue;

            // AdobeReaderプロセス起動して印刷
            //pro.Start();
            System.Security.SecureString password = new System.Security.SecureString();
            //pro = Process.Start(pro.StartInfo.FileName, pro.StartInfo.Arguments, "ntss", password, ".\\");
            //password.AppendChar('i');
            //password.AppendChar('m');
            //password.AppendChar('p');
            //password.AppendChar('u');
            //password.AppendChar('l');
            //password.AppendChar('s');
            //password.AppendChar('e');
            //pro = Process.Start(pro.StartInfo.FileName, pro.StartInfo.Arguments, "admin", password, ".\\");
            password.AppendChar('0');
            password.AppendChar('0');
            password.AppendChar('0');
            password.AppendChar('0');
            //_ = System.Diagnostics.Process.Start(pro.StartInfo.FileName, pro.StartInfo.Arguments, "伊東", password, "se.pccol-tdc.co.jp");
            //NKKPrintServer.ProcessAsUser.Launch(pro.StartInfo.FileName + " " + pro.StartInfo.Arguments);
            //NKKPrintServer.ProcessAsUser.Launch("C:\\Program Files (x86)\\Foxit Software\\Foxit Reader\\FoxitReader.exe /t D:\\20181029154718.pdf \"EPSON LP - S950\"");
            //NKKPrintServer.ProcessAsUser.Launch("notepad.exe");

        }

        [TestMethod]
        public void LaunchProcess3()
        {
            const string path = "abcef";
            const string printerName = "ghijk";
            System.IO.MemoryStream ms = new System.IO.MemoryStream(System.Text.Encoding.UTF8.GetBytes("{\"path\":\"" + path + "\",\"printerName\":\"" + printerName + "\"}"));
            NKKPrintServer.PrintData printData = new NKKPrintServer.PrintData
            {
                filename = @"D:\20181029154718.pdf",
                printerName = "EPSON LP-S950"
            };
            System.IO.MemoryStream stream1 = new System.IO.MemoryStream();
            //System.Runtime.Serialization.Json.DataContractJsonSerializer ser = new System.Runtime.Serialization.Json.DataContractJsonSerializer(typeof(NKKPrintServer.PrintData));
            //System.Runtime.Serialization.Json.DataContractJsonSerializer ser = new System.Runtime.Serialization.Json.DataContractJsonSerializer(deserializedUser.GetType());
            //System.Runtime.Serialization.Json.DataContractJsonSerializer ser = new System.Runtime.Serialization.Json.DataContractJsonSerializer(typeof(NKKPrintServer.PrintData));
            System.Runtime.Serialization.Json.DataContractJsonSerializer ser = new System.Runtime.Serialization.Json.DataContractJsonSerializer(typeof(NKKPrintServer.PrintData));
            ser.WriteObject(stream1, printData);
            stream1.Position = 0;
            System.IO.StreamReader sr = new System.IO.StreamReader(stream1);
            string a = sr.ReadToEnd();
            System.Diagnostics.Trace.WriteLine(a);

            //NKKPrintServer.PrintData deserializedUser = new NKKPrintServer.PrintData();
            //ms.Position = (ms.ReadByte() == 0xef) ? 3 : 0;
            //ms.Position = 0;
            NKKPrintServer.PrintData deserializedUser = ser.ReadObject(ms) as NKKPrintServer.PrintData;
            ms.Close();

            Assert.AreEqual(null, deserializedUser.filename);
            Assert.AreEqual(printerName, deserializedUser.printerName);

        }

        [TestMethod]
        public void LaunchProcess4()
        {
            // Get all processes running on the local computer.
            System.Diagnostics.Process[] localAll = System.Diagnostics.Process.GetProcesses();

            foreach (var item in localAll)
            {
                //System.Diagnostics.Trace.WriteLine(item.ProcessName);
                System.Diagnostics.Debug.WriteLine(item.ProcessName);
            }

        }

        [DllImport("user32.dll", SetLastError = true)]
        static extern IntPtr OpenInputDesktop(uint dwFlags, bool fInherit,
           uint dwDesiredAccess);

        [Flags]
        public enum ACCESS_MASK : uint
        {
            DELETE = 0x00010000,
            READ_CONTROL = 0x00020000,
            WRITE_DAC = 0x00040000,
            WRITE_OWNER = 0x00080000,
            SYNCHRONIZE = 0x00100000,

            STANDARD_RIGHTS_REQUIRED = 0x000F0000,

            STANDARD_RIGHTS_READ = 0x00020000,
            STANDARD_RIGHTS_WRITE = 0x00020000,
            STANDARD_RIGHTS_EXECUTE = 0x00020000,

            STANDARD_RIGHTS_ALL = 0x001F0000,

            SPECIFIC_RIGHTS_ALL = 0x0000FFFF,

            ACCESS_SYSTEM_SECURITY = 0x01000000,

            MAXIMUM_ALLOWED = 0x02000000,

            GENERIC_READ = 0x80000000,
            GENERIC_WRITE = 0x40000000,
            GENERIC_EXECUTE = 0x20000000,
            GENERIC_ALL = 0x10000000,

            DESKTOP_READOBJECTS = 0x00000001,
            DESKTOP_CREATEWINDOW = 0x00000002,
            DESKTOP_CREATEMENU = 0x00000004,
            DESKTOP_HOOKCONTROL = 0x00000008,
            DESKTOP_JOURNALRECORD = 0x00000010,
            DESKTOP_JOURNALPLAYBACK = 0x00000020,
            DESKTOP_ENUMERATE = 0x00000040,
            DESKTOP_WRITEOBJECTS = 0x00000080,
            DESKTOP_SWITCHDESKTOP = 0x00000100,

            WINSTA_ENUMDESKTOPS = 0x00000001,
            WINSTA_READATTRIBUTES = 0x00000002,
            WINSTA_ACCESSCLIPBOARD = 0x00000004,
            WINSTA_CREATEDESKTOP = 0x00000008,
            WINSTA_WRITEATTRIBUTES = 0x00000010,
            WINSTA_ACCESSGLOBALATOMS = 0x00000020,
            WINSTA_EXITWINDOWS = 0x00000040,
            WINSTA_ENUMERATE = 0x00000100,
            WINSTA_READSCREEN = 0x00000200,

            WINSTA_ALL_ACCESS = 0x0000037F
        }


        [StructLayout(LayoutKind.Sequential)]
        public struct SECURITY_ATTRIBUTES
        {
            public int nLength;
            public IntPtr lpSecurityDescriptor;
            public int bInheritHandle;
        }

        // ms-help://MS.VSCC.v80/MS.MSDN.v80/MS.WIN32COM.v10.en/dllproc/base/createdesktop.htm
        [DllImport("user32.dll", EntryPoint = "CreateDesktop", CharSet = CharSet.Unicode, SetLastError = true)]
        public static extern IntPtr CreateDesktop(
                        [MarshalAs(UnmanagedType.LPWStr)] string desktopName,
                        [MarshalAs(UnmanagedType.LPWStr)] string device, // must be null.
                        [MarshalAs(UnmanagedType.LPWStr)] string deviceMode, // must be null,
                        [MarshalAs(UnmanagedType.U4)] int flags,  // use 0
                        [MarshalAs(UnmanagedType.U4)] ACCESS_MASK accessMask,
                        IntPtr attributes /* [MarshalAs(UnmanagedType.LPStruct)] SECURITY_ATTRIBUTES attributes*/);

        // ms-help://MS.VSCC.v80/MS.MSDN.v80/MS.WIN32COM.v10.en/dllproc/base/closedesktop.htm
        [DllImport("user32.dll", EntryPoint = "CloseDesktop", CharSet = CharSet.Unicode, SetLastError = true)]
        [return: MarshalAs(UnmanagedType.Bool)]
        public static extern bool CloseDesktop(IntPtr handle);

        [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
        struct STARTUPINFO
        {
            public Int32 cb;
            public string lpReserved;
            public string lpDesktop;
            public string lpTitle;
            public Int32 dwX;
            public Int32 dwY;
            public Int32 dwXSize;
            public Int32 dwYSize;
            public Int32 dwXCountChars;
            public Int32 dwYCountChars;
            public Int32 dwFillAttribute;
            public Int32 dwFlags;
            public Int16 wShowWindow;
            public Int16 cbReserved2;
            public IntPtr lpReserved2;
            public IntPtr hStdInput;
            public IntPtr hStdOutput;
            public IntPtr hStdError;
        }

        [StructLayout(LayoutKind.Sequential)]
        internal struct PROCESS_INFORMATION
        {
            public IntPtr hProcess;
            public IntPtr hThread;
            public int dwProcessId;
            public int dwThreadId;
        }

        [DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Auto)]
        static extern bool CreateProcess(
           string lpApplicationName,
           string lpCommandLine,
           ref SECURITY_ATTRIBUTES lpProcessAttributes,
           ref SECURITY_ATTRIBUTES lpThreadAttributes,
           bool bInheritHandles,
           uint dwCreationFlags,
           IntPtr lpEnvironment,
           string lpCurrentDirectory,
           [In] ref STARTUPINFO lpStartupInfo,
           out PROCESS_INFORMATION lpProcessInformation);

        [DllImport("kernel32.dll", SetLastError = true)]
        static extern bool CloseHandle(IntPtr hHandle);

        [TestMethod]
        public void CreateDesktopTest()
        {
            //IntPtr current = OpenInputDesktop(0, false, (uint)ACCESS_MASK.GENERIC_ALL);

            const string DesktopName = "AltDesktop";
            _ = CreateDesktop(DesktopName, null, null, 0, ACCESS_MASK.GENERIC_ALL, IntPtr.Zero);

            //SwitchDesktop(desk);

            STARTUPINFO si = new STARTUPINFO();
            si.cb = Convert.ToInt32(Marshal.SizeOf(si));
            si.lpDesktop = $"WinSta0\\{DesktopName}";
            SECURITY_ATTRIBUTES pSec = new SECURITY_ATTRIBUTES();
            SECURITY_ATTRIBUTES tSec = new SECURITY_ATTRIBUTES();

            _ = CreateProcess(
              null,
              @"C:\Windows\notepad.exe d:\a.txt", // 64-bit OSは64-bit版を
              ref pSec,
              ref tSec,
              false,
              0x00000020, // NORMAL_PRIORITY_CLASS
              IntPtr.Zero,
              null,
              ref si,
              out PROCESS_INFORMATION pa
              );

            //System.Threading.Thread.Sleep(3 * 1000);

            //SwitchDesktop(current);

            _ = CloseHandle(pa.hThread);
            _ = CloseHandle(pa.hProcess);

        }

        [DllImport("winspool.drv", SetLastError = true, CharSet = CharSet.Unicode)]
        static extern int OpenPrinter(string pPrinterName, out IntPtr phPrinter, IntPtr pDefault);

        [DllImport("winspool.drv", SetLastError = true)]
        static extern int ClosePrinter(IntPtr hPrinter);

        [DllImport("winspool.drv", CharSet = CharSet.Unicode)]
        static extern bool GetPrinterDriver(IntPtr phPrinter,
                                      System.Text.StringBuilder pEnv,
                                      int Level,
                                      [Out] IntPtr pDriverInfo,
                                      int bufferSize,
                                      ref int Bytes);

        [TestMethod]
        public void GetPrinterDriverTest()
        {
            //コンピュータにインストールされているすべてのプリンタの名前を出力する
            System.Drawing.Printing.PrinterSettings.StringCollection installedPrinters = System.Drawing.Printing.PrinterSettings.InstalledPrinters;
            System.Diagnostics.Debug.WriteLine("プリンター名 dwPrinterDriverAttributes PRINTER_DRIVER_CATEGORY_VIRTUAL");

            IntPtr phPrinter = IntPtr.Zero;

            foreach (string s in installedPrinters)
            {

                if (OpenPrinter(s, out phPrinter, IntPtr.Zero) != 0)
                {

                    try
                    {
                        var pEnv = new System.Text.StringBuilder();

                        //必要なバイト数を取得する
                        int needed = 0;
                        GetPrinterDriver(phPrinter, pEnv, 8, IntPtr.Zero, 0, ref needed);

                        if (needed <= 0)
                        {
                            throw new Exception("失敗しました。");
                        }

                        //メモリを割り当てる
                        IntPtr pPrinterInfo = IntPtr.Zero;
                        pPrinterInfo = Marshal.AllocHGlobal(needed);

                        //プリンタ情報を取得する
                        int temp = 0;
                        if (!GetPrinterDriver(phPrinter, pEnv, 8, pPrinterInfo, needed, ref temp))
                        {
                            throw new System.ComponentModel.Win32Exception(Marshal.GetLastWin32Error());
                        }

                        // DRIVER_INFO_8型にマーシャリングする
                        var printerInfo =
                            (NKKPrintServer.NKKPrint.DRIVER_INFO_8)Marshal.PtrToStructure(pPrinterInfo,
                            typeof(NKKPrintServer.NKKPrint.DRIVER_INFO_8));

                        string message = "";
                        uint x = 1;
                        for (int i = 0; i < 11; i++)
                        {
                            message = message + ((printerInfo.dwPrinterDriverAttributes & x) >> i).ToString() + "\t";
                            x <<= 1;
                        }
                        message += s;
                        System.Diagnostics.Debug.WriteLine(message);

                    }
                    catch (Exception)
                    {
                        throw;
                    }
                    finally
                    {
                        ClosePrinter(phPrinter);

                    }

                }

            }

            System.Collections.Generic.List<NKKPrintServer.MstPrinterData> wList = NKKPrintServer.NKKPrint.CreateMstPrinterDatas(string.Empty, null);
            foreach (MstPrinterData item in from item in wList
                                 where OpenPrinter(item.PrinterName, out phPrinter, IntPtr.Zero) != 0
                                 select item)
            {
                try
                {
                    var pEnv = new System.Text.StringBuilder();

                    //必要なバイト数を取得する
                    int needed = 0;
                    GetPrinterDriver(phPrinter, pEnv, 8, IntPtr.Zero, 0, ref needed);

                    if (needed <= 0)
                    {
                        throw new Exception("失敗しました。");
                    }

                    //メモリを割り当てる
                    IntPtr pPrinterInfo = IntPtr.Zero;
                    pPrinterInfo = Marshal.AllocHGlobal(needed);

                    //プリンタ情報を取得する
                    int temp = 0;
                    if (!GetPrinterDriver(phPrinter, pEnv, 8, pPrinterInfo, needed, ref temp))
                    {
                        throw new System.ComponentModel.Win32Exception(Marshal.GetLastWin32Error());
                    }

                    // DRIVER_INFO_8型にマーシャリングする
                    var printerInfo =
                        (NKKPrintServer.NKKPrint.DRIVER_INFO_8)Marshal.PtrToStructure(pPrinterInfo,
                        typeof(NKKPrintServer.NKKPrint.DRIVER_INFO_8));

                    Assert.AreEqual((uint)0, printerInfo.dwPrinterDriverAttributes & (NKKPrint.PRINTER_DRIVER_XPS | NKKPrint.PRINTER_DRIVER_CATEGORY_FAX | NKKPrint.PRINTER_DRIVER_CATEGORY_FILE | NKKPrint.PRINTER_DRIVER_CATEGORY_VIRTUAL));
                    System.Diagnostics.Debug.WriteLine(item.PrinterName);

                }
                catch (Exception)
                {
                    throw;
                }
                finally
                {
                    ClosePrinter(phPrinter);

                }
            }
        }

        [TestMethod]
        public void ExtractToDirectoryTest()
        {

            //System.IO.Compression.ZipFile.ExtractToDirectory(@"D:\0511154320.zip", @"D:\work2\a\a");
            string destFileName = System.IO.Path.GetTempPath() + System.IO.Path.GetRandomFileName();
            //System.IO.Compression.ZipFile.ExtractToDirectory(@"D:\0511154320.zip", destFileName);
            System.Diagnostics.Trace.WriteLine("Temp file name is [" + destFileName + "]");

            string result = System.IO.Path.GetRandomFileName();
            //Console.WriteLine("Random file name is " + result);
            System.Diagnostics.Trace.WriteLine("Random file name is " + result);

            //result = System.IO.Path.GetTempPath();
            ////Console.WriteLine("Random file name is " + result);
            //System.Diagnostics.Trace.WriteLine("Temp path is " + result);

            //result = System.IO.Path.GetTempFileName();
            ////Console.WriteLine("Random file name is " + result);
            //System.Diagnostics.Trace.WriteLine("Temp file name is " + result);

        }

    }
}

