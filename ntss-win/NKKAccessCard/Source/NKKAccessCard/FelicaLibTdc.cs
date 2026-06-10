/**
* @file FelicaLibTdc.cs
* @brief フェリカカードライブラリ
* @author R.Izumi
* @date 2017/11/06
* @details フェリカカードのオープン・クローズ、読み込み・書き込み用のライブラリ
*/

using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Runtime.InteropServices;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;

//----------------------------------------------------------------------------------------------------
/// <summary>
/// 名前空間:NKKFelicaLib
/// </summary>
//----------------------------------------------------------------------------------------------------
namespace NKKFelicaLib
{
    /**
    * @brief TDCフェリカライブラリ
    * @details フェリカカードのオープン・クローズ、読み込み・書き込み用のクラス
    */
    class FelicaLibTdc
    {
        //
        private static felica_dll_wrapper_basic FDWC = new felica_dll_wrapper_basic();

        /// <summary>
        /// 読み書き用
        /// </summary>
        public static EnumrationFeliCaErrorType FelicaError;
        public static EnumrationRwErrorType RwError;

        // add FNSI-4200ポートを使用している 孫 start
        /// <summary>
        /// カードアプリのGUID
        /// </summary>
        public static String IcGuId = String.Empty;

        /// <summary>
        /// ダイナミックポートFromTo
        /// </summary>
        public static String IcPortFrom = String.Empty;
        public static String IcPortTo = String.Empty;
        // add FNSI-4200ポートを使用している 孫 end

        /// <summary>
        /// フェリカカードシステムコード
        /// </summary>
        public static String IcSystemCode = String.Empty;

        /// <summary>
        /// フェリカカードサービスコード１
        /// </summary>
        public static String IcServiceCode1 = String.Empty;

        /// <summary>
        /// フェリカカードサービスコード２
        /// </summary>
        public static String IcServiceCode2 = String.Empty;

        /// <summary>
        /// ポーリング用
        /// </summary>
        // 表示中フェリカカードのIDm情報
        public static string viewCardIdm = "";
        //フェリカ接続ON
        public static bool? FelicaConnectFlg = null;

        // エラー発生時に呼び出されるイベントハンドラ
        public static event Action<String, String> FelicaErrorEvent;

        // 情報ログ発生時に呼び出されるイベントハンドラ
        public static event Action<String> FelicaInfoEvent;

        //mod #9731 体重計アプリとFNSiカードアプリが同時にカードをつかえない。 donghao start
        // カード読込情報変更イベントハンドラ
        //public static event Action<String, Byte[]> FelicaChangeEvent;
        public static event Func<String, Byte[], bool> FelicaChangeEvent;
        //mod #9731 体重計アプリとFNSiカードアプリが同時にカードをつかえない。 donghao end
        // カード接続情報変更イベントハンドラ
        public static event Action<Boolean?> FelicaConnectChangeEvent;

        // ポーリングと書き込み処理排他制御用ロックオブジェクト
        public static object LockoObj = new object();

        // ポーリング用スレッド
        private static Thread FelicaMonitoringThread = null;
        //mod #9731 体重計アプリとFNSiカードアプリが同時にカードをつかえない。 donghao start
        //スレッド実行フラグ
        //private static bool running;
        public static bool running;


        //mod #9731 体重計アプリとFNSiカードアプリが同時にカードをつかえない。 donghao end
        // add #11386 H5体重測定時にカードが読めなくなる 高 start
        public static string wMutexName = @"Global\Global_Felica_QWErty";
        // add #11386 H5体重測定時にカードが読めなくなる 高 end

        // add #11707 体重計AppとカードAppにてカードが読めない事象が発生する 高 start
        public static DateTime? lastErrTime = null;
        // add #11707 体重計AppとカードAppにてカードが読めない事象が発生する 高 end

        #region オープン
        /**
        * @fn static bool Open()
        * @brief FeliCaカードリーダーのオープン
        * @return bool true：成功、false：失敗
        * @details FeliCaカードリーダーのオープン
        */
        public static bool Open()
        {
            lock (LockoObj)
            {
                // del #11386 H5体重測定時にカードが読めなくなる 高 start
                //FelicaCallInfo("Felicaライブラリ初期化 Start");
                // del #11386 H5体重測定時にカードが読めなくなる 高 end
                try
                {
                    // add #11818 体重計およびカードアプリでカードの読込が遅くなっているる 高 start
                    bool bIsOpen = false;
                    if (true == FDWC.ReaderWriterIsOpen(ref bIsOpen))
                    {
                        if (bIsOpen)
                        {
                            return true;
                        }
                    }
                    // add #11818 体重計およびカードアプリでカードの読込が遅くなっているる 高 end

                    // ライブラリの初期化
                    if (false == FDWC.InitializeLibrary())
                    {
                        FDWC.GetLastErrorTypes(ref FelicaLibTdc.FelicaError, ref FelicaLibTdc.RwError);

                        // FelicaリーダーのUSBケーブルを抜き差しするとライブラリが初期化済みになることへの対策
                        if (FelicaLibTdc.FelicaError != EnumrationFeliCaErrorType.FELICA_LIBRARY_ALREADY_INITIALIZED)
                        {
                            // 初回と接続状態が変わった場合のみ
                            if (FelicaConnectFlg == null || FelicaConnectFlg == true)
                            {
                                // エラーメッセージ表示・ログ書き込み
                                FelicaCallError("Felicaライブラリ初期化エラー", FelicaLibTdc.FelicaError.ToString());
                            }
                            return false;
                        }
                    }
                    // オープン
                    if (false == FDWC.OpenReaderWriterAuto())
                    {
                        FDWC.GetLastErrorTypes(ref FelicaLibTdc.FelicaError, ref FelicaLibTdc.RwError);

                        // 初回と接続状態が変わった場合のみ
                        if (FelicaConnectFlg == null || FelicaConnectFlg == true)
                        {
                            // エラーメッセージ表示・ログ書き込み
                            FelicaCallError("Felicaオープンエラー", FelicaLibTdc.FelicaError.ToString());
                        }

                        return false;
                    }

                    // 初回と接続状態が変わった場合のみ
                    if (FelicaConnectFlg == null || FelicaConnectFlg == false)
                    {
                        // TODO
                        //// ログ書き込み
                        //Cmn.WriteLog(83);
                    }

                    // 最後まで抜けたら成功
                    return true;
                }
                catch (Exception e)
                {
                    // ポーリング終了
                    PollingThreadEnd();

                    // エラーメッセージ表示・ログ書き込み・アプリケーション終了
                    FelicaCallError("Felicaエラー", e.Message + e.StackTrace);

                    return false;
                }
                finally
                {
                    // del #11386 H5体重測定時にカードが読めなくなる 高 start
                    //FelicaCallInfo("Felicaライブラリ初期化 End");
                    // del #11386 H5体重測定時にカードが読めなくなる 高 end
                }
            }
        }
        #endregion オープン

        #region クローズ
        /**
        * @fn static bool Close()
        * @brief FeliCaカードリーダーのクローズ
        * @return bool true：成功、false：失敗
        * @details FeliCaカードリーダーのクローズ
        */
        public static bool Close()
        {
            lock (LockoObj)
            {
                string errMsg = "";

                // クローズ
                bool closeResult = true;
                if (false == FDWC.CloseReaderWriter())
                {
                    closeResult = false;
                    // mod #11707 体重計AppとカードAppにてカードが読めない事象が発生する 高 start
                    if (FelicaConnectFlg == false)
                    {
                        DateTime currentTime = DateTime.Now;
                        if (lastErrTime == null || (currentTime - lastErrTime.Value) >= TimeSpan.FromMinutes(10))
                        {
                            lastErrTime = currentTime;

                            FDWC.GetLastErrorTypes(ref FelicaLibTdc.FelicaError, ref FelicaLibTdc.RwError);

                            errMsg = FelicaLibTdc.FelicaError.ToString();
                            errMsg += "\n\n";
                            errMsg += FelicaLibTdc.RwError.ToString();

                            // ログ書き込み
                            FelicaCallError("Felicaクローズエラー", errMsg);
                        }
                    }
                    // mod #11707 体重計AppとカードAppにてカードが読めない事象が発生する 高 end
                }

                // ライブラリ解放
                if (false == FDWC.DisposeLibrary())
                {
                    FDWC.GetLastErrorTypes(ref FelicaLibTdc.FelicaError, ref FelicaLibTdc.RwError);

                    errMsg = FelicaLibTdc.FelicaError.ToString();
                    errMsg += "\n\n";
                    errMsg += FelicaLibTdc.RwError.ToString();

                    // ログ書き込み
                    FelicaCallError("ライブラリ開放エラー", errMsg);
                    return false;
                }

                // 最後まで抜けたら成功
                return closeResult;
            }
        }
        #endregion クローズ

        //add #9731 体重計アプリとFNSiカードアプリが同時にカードをつかえない。 donghao start
        // mod #11386 H5体重測定時にカードが読めなくなる 高 start
        //public static bool Lock(ref bool isTimeout)
        public static bool Lock(ref bool isTimeout, Mutex wMutex)
        // mod #11386 H5体重測定時にカードが読めなくなる 高 end
        {
            isTimeout = false;
            string errMsg = "";

            // ロック
            // mod #11386 H5体重測定時にカードが読めなくなる 高 start
            //if (false == FDWC.TransactionLock())
            //{
            //    FDWC.GetLastErrorTypes(ref FelicaLibTdc.FelicaError, ref FelicaLibTdc.RwError);

            //    if (FelicaLibTdc.FelicaError == EnumrationFeliCaErrorType.FELICA_TRANSACTION_LOCK_ERROR && FelicaLibTdc.RwError == EnumrationRwErrorType.RW_LOCK_TIMEOUT)
            //    {
            //        isTimeout = true;
            //    }
            //    else
            //    {
            //        errMsg = FelicaLibTdc.FelicaError.ToString();
            //        errMsg += "\n\n";
            //        errMsg += FelicaLibTdc.RwError.ToString();

            //        // ログ書き込み
            //        FelicaCallError("Felicaロックエラー", errMsg);
            //        return false;
            //    }
            //}
            bool isLock = false;

            try
            {
                isLock = wMutex.WaitOne(600, false);
                if (isLock == false)
                {
                    FelicaCallError("Lock timeoutエラー", "WaitOne()");
                    isTimeout = true;
                    return false;
                }
            }
            catch(Exception e)
            {
                FelicaCallError("Lock timeoutエラー", e.Message);
                return false;
            }
            // mod #11386 H5体重測定時にカードが読めなくなる 高 end

            return true;
        }

        // mod #11386 H5体重測定時にカードが読めなくなる 高 start
        //public static bool Lock()
        public static bool Lock(Mutex wMutex)
        // mod #11386 H5体重測定時にカードが読めなくなる 高 end
        {

            string errMsg = "";

            // ロック
            // mod #11386 H5体重測定時にカードが読めなくなる 高 start
            //if (false == FDWC.TransactionLock())
            //{
            //    FDWC.GetLastErrorTypes(ref FelicaLibTdc.FelicaError, ref FelicaLibTdc.RwError);

            //    errMsg = FelicaLibTdc.FelicaError.ToString();
            //    errMsg += "\n\n";
            //    errMsg += FelicaLibTdc.RwError.ToString();

            //    // ログ書き込み
            //    FelicaCallError("Felicaロックエラー", errMsg);
            //    return false;

            //}
            try
            {
                wMutex.WaitOne();
            }
            catch(Exception e)
            {
                FelicaCallError("Lockエラー", e.Message);
                return false;
            }
            // mod #11386 H5体重測定時にカードが読めなくなる 高 end

            return true;
        }

        // mod #11386 H5体重測定時にカードが読めなくなる 高 start
        //public static bool Unlock()
        public static bool Unlock(Mutex wMutex)
        // mod #11386 H5体重測定時にカードが読めなくなる 高 end
        {
            string errMsg = "";

            // ロック解除
            // mod #11386 H5体重測定時にカードが読めなくなる 高 start
            //if (false == FDWC.TransactionUnlock())
            //{
            //    FDWC.GetLastErrorTypes(ref FelicaLibTdc.FelicaError, ref FelicaLibTdc.RwError);

            //    errMsg = FelicaLibTdc.FelicaError.ToString();
            //    errMsg += "\n\n";
            //    errMsg += FelicaLibTdc.RwError.ToString();

            //    // ログ書き込み
            //    FelicaCallError("Felicaロック解除エラー", errMsg);
            //    return false;
            //}
            try
            {
                if (wMutex != null)
                    wMutex.ReleaseMutex();
            }
            catch(Exception e)
            {
                FelicaCallError("unlockエラー", e.Message);
                return false;
            }
            // mod #11386 H5体重測定時にカードが読めなくなる 高 end

            return true;
        }

        public static bool SetLockTimeout(ulong timeout)
        {
            string errMsg = "";

            // ロックタイムアウト設定
            // del #11386 H5体重測定時にカードが読めなくなる 高 start
            //if (false == FDWC.SetLockTimeout(timeout))
            //{
            //    FDWC.GetLastErrorTypes(ref FelicaLibTdc.FelicaError, ref FelicaLibTdc.RwError);

            //    errMsg = FelicaLibTdc.FelicaError.ToString();
            //    errMsg += "\n\n";
            //    errMsg += FelicaLibTdc.RwError.ToString();

            //    // ログ書き込み
            //    FelicaCallError("Felicaロックタイムアウト設定エラー", errMsg);
            //    return false;
            //}
            // del #11386 H5体重測定時にカードが読めなくなる 高 end

            return true;
        }
        //add #9731 体重計アプリとFNSiカードアプリが同時にカードをつかえない。 donghao end
        #region フェリカカードポーリング

        #region ポーリング開始
        /**
        * @fn void PollingThreadStart()
        * @brief フェリカカードの接続状態を監視するスレッドを作成
        * @details フェリカカードの接続状態を監視するスレッドを作成
        */
        public static void PollingThreadStart()
        {
            // スレッドを作成
            FelicaMonitoringThread = new Thread(new ThreadStart(FelicaLibTdc.PollingStart))
            {
                // スレッドをバックグラウンドで実行
                IsBackground = true,
            };
            running = true;
            FelicaMonitoringThread.Start();
        }
        #endregion ポーリング開始

        #region ポーリング終了
        /**
        * @fn void PollingThreadEnd()
        * @brief フェリカカードの接続状態を監視するスレッドを終了
        * @details フェリカカードの接続状態を監視するスレッドを終了
        */
        public static void PollingThreadEnd()
        {
            if (FelicaMonitoringThread != null)
            {
                // 終了
                running = false;
            }
        }
        #endregion ポーリング終了

        #region ポーリングループ処理
        /**
        * @fn void PollingStart()
        * @brief フェリカカードの接続状態を監視
        * @details ループ処理
        */
        public static void PollingStart()
        {
            // mod #11818 体重計およびカードアプリでカードの読込が遅くなっているる 高 start
            // add #11386 H5体重測定時にカードが読めなくなる 高 start
            Mutex wMutex = null;
            int cntError = 0;
            // add #11386 H5体重測定時にカードが読めなくなる 高 start
            double minInterval = 0;

            while (running)
            {
                // 0.1秒待ち
                Thread.Sleep(100);
                //mod #9731 体重計アプリとFNSiカードアプリが同時にカードをつかえない。 donghao start
                //// フェリカカードポーリング
                //Polling();
                bool nowFelicaConFlg = false;

                // mod #11386 H5体重測定時にカードが読めなくなる 高 start
                // mod #11707 体重計AppとカードAppにてカードが読めない事象が発生する 高 start
                try
                {
                    wMutex = null;

                    try
                    {
                        wMutex = new Mutex(false, wMutexName);
                    }
                    catch (Exception ex)
                    {
                        FelicaCallError("new Mutex エラー", ex.Message);
                    }

                    if (wMutex != null)
                    {
                        try
                        {
                            if (Open())
                            {
                                cntError = 0;
                                lastErrTime = null;
                                minInterval = 0;

                                // フェリカ接続ON
                                nowFelicaConFlg = true;

                                // フェリカの接続状態が変更した場合
                                if (FelicaConnectFlg != nowFelicaConFlg)
                                {
                                    // フェリカの接続状態セット
                                    FelicaConnectFlg = nowFelicaConFlg;

                                    // フェリカの接続状態イベント
                                    FelicaConnectChange(FelicaConnectFlg);
                                }

                                //SetLockTimeout(400);

                                //bool isTimeout = false;
                                //bool lockSuccessed = true;

                                //while (lockSuccessed)
                                //{
                                //    lock (LockoObj)
                                //    {
                                //        lockSuccessed = Lock(ref isTimeout);
                                //        if (lockSuccessed)
                                //        {
                                //            if (!isTimeout)
                                //            {
                                //                // フェリカカードポーリング
                                //                Polling();

                                //                Unlock();
                                //            }
                                //        }
                                //    }
                                //    // 0.1秒待ち
                                //    Thread.Sleep(100);
                                //}

                                bool isTimeout = false;
                                bool lockSuccessed = true;

                                while (lockSuccessed)
                                {
                                    lock (LockoObj)
                                    {
                                        try
                                        {
                                            lockSuccessed = Lock(ref isTimeout, wMutex);

                                            if (lockSuccessed)
                                            {
                                                // フェリカカードポーリング
                                                //Polling();
                                                if (Polling() == false)
                                                {
                                                    lockSuccessed = false;
                                                }
                                            }
                                        }
                                        finally
                                        {
                                            Unlock(wMutex);
                                        }
                                    }
                                    // 0.1秒待ち
                                    Thread.Sleep(100);
                                }
                            }
                            else
                            {
                                // カード情報クリア
                                viewCardIdm = "";

                                // フェリカ接続OFF
                                nowFelicaConFlg = false;

                                if (cntError < 21)
                                    cntError++;

                                DateTime currentTime = DateTime.Now;
                                if (cntError == 20 || (cntError > 20 && (currentTime - lastErrTime.Value) >= TimeSpan.FromMinutes(minInterval)))
                                {
                                    if (minInterval < 5)
                                        minInterval++;
                                    else
                                        minInterval = 10;

                                    Close();
                                    rebootFeliCa();
                                }
                            }

                            // フェリカの接続状態が変更した場合
                            if (FelicaConnectFlg != nowFelicaConFlg)
                            {
                                // フェリカの接続状態セット
                                FelicaConnectFlg = nowFelicaConFlg;

                                // フェリカの接続状態イベント
                                FelicaConnectChange(FelicaConnectFlg);
                            }
                        }
                        finally
                        {
                            Close();
                        }
                    }
                }
                catch (Exception ex)
                {
                    FelicaCallError("PollingStart() エラー", ex.Message);
                }
                finally
                {
                    if (wMutex != null)
                    {
                        try
                        {
                            wMutex.Close();
                            wMutex = null;
                        }
                        catch (Exception ex)
                        {
                            FelicaCallError("wMutex Close エラー", ex.Message);
                        }
                    }
                }
                // mod #11707 体重計AppとカードAppにてカードが読めない事象が発生する 高 end
                // mod #11386 H5体重測定時にカードが読めなくなる 高 end
            }
            //mod #9731 体重計アプリとFNSiカードアプリが同時にカードをつかえない。 donghao end
            // mod #11818 体重計およびカードアプリでカードの読込が遅くなっているる 高 end
        }
        #endregion ポーリングループ処理

        // add #11707 体重計AppとカードAppにてカードが読めない事象が発生する 高 start
        static void rebootFeliCa()
        {
            // search FeliCa Devices
            List<DeviceInfo> devices = GetFeliCaDevices();
            if (devices.Count == 0)
            {
                FelicaCallError("[Error]", "Not find Sony FeliCa");
                return;
            }

            // reboot Sony FeliCa
            FelicaCallError("[RestartDevice]", "reboot Sony FeliCa...");
            HashSet<string> restartedDeviceIds = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
            foreach (var device in devices)
            {
                FelicaCallError("[RestartDevice]", "target: " + FormatDeviceInfo(device));
                RestartDeviceAndParents(device, restartedDeviceIds);
            }
        }

        // Information of Sony FeliCa
        private class DeviceInfo
        {
            public string Name { get; set; }
            public string DeviceID { get; set; }
            public string Status { get; set; }
            public string HardwareID { get; set; }
            public List<string> AncestorDeviceIDs { get; set; }
        }

        private const uint DIGCF_PRESENT = 0x00000002;
        private const uint DIGCF_ALLCLASSES = 0x00000004;
        private const uint SPDRP_DEVICEDESC = 0x00000000;
        private const uint SPDRP_HARDWAREID = 0x00000001;
        private const uint SPDRP_FRIENDLYNAME = 0x0000000C;
        private const uint DIF_PROPERTYCHANGE = 0x00000012;
        private const uint DICS_ENABLE = 0x00000001;
        private const uint DICS_DISABLE = 0x00000002;
        private const uint DICS_PROPCHANGE = 0x00000003;
        private const uint DICS_FLAG_GLOBAL = 0x00000001;
        private const int ERROR_NO_MORE_ITEMS = 259;
        private const int CR_SUCCESS = 0;
        private static readonly IntPtr INVALID_HANDLE_VALUE = new IntPtr(-1);
        private static readonly Regex FeliCaDeviceRegex = new Regex("FeliCa|RC-S[0-9]+|NFC", RegexOptions.IgnoreCase);

        [StructLayout(LayoutKind.Sequential)]
        private struct SP_DEVINFO_DATA
        {
            public uint cbSize;
            public Guid ClassGuid;
            public uint DevInst;
            public IntPtr Reserved;
        }

        [StructLayout(LayoutKind.Sequential)]
        private struct SP_CLASSINSTALL_HEADER
        {
            public uint cbSize;
            public uint InstallFunction;
        }

        [StructLayout(LayoutKind.Sequential)]
        private struct SP_PROPCHANGE_PARAMS
        {
            public SP_CLASSINSTALL_HEADER ClassInstallHeader;
            public uint StateChange;
            public uint Scope;
            public uint HwProfile;
        }

        [DllImport("setupapi.dll", EntryPoint = "SetupDiGetClassDevsW", CharSet = CharSet.Unicode, SetLastError = true)]
        private static extern IntPtr SetupDiGetClassDevs(IntPtr ClassGuid, string Enumerator, IntPtr hwndParent, uint Flags);

        [DllImport("setupapi.dll", SetLastError = true)]
        private static extern bool SetupDiEnumDeviceInfo(IntPtr DeviceInfoSet, uint MemberIndex, ref SP_DEVINFO_DATA DeviceInfoData);

        [DllImport("setupapi.dll", EntryPoint = "SetupDiGetDeviceInstanceIdW", CharSet = CharSet.Unicode, SetLastError = true)]
        private static extern bool SetupDiGetDeviceInstanceId(IntPtr DeviceInfoSet, ref SP_DEVINFO_DATA DeviceInfoData, StringBuilder DeviceInstanceId, int DeviceInstanceIdSize, out int RequiredSize);

        [DllImport("setupapi.dll", EntryPoint = "SetupDiGetDeviceRegistryPropertyW", SetLastError = true)]
        private static extern bool SetupDiGetDeviceRegistryProperty(IntPtr DeviceInfoSet, ref SP_DEVINFO_DATA DeviceInfoData, uint Property, out uint PropertyRegDataType, byte[] PropertyBuffer, uint PropertyBufferSize, out uint RequiredSize);

        [DllImport("setupapi.dll", EntryPoint = "SetupDiSetClassInstallParamsW", SetLastError = true)]
        private static extern bool SetupDiSetClassInstallParams(IntPtr DeviceInfoSet, ref SP_DEVINFO_DATA DeviceInfoData, ref SP_PROPCHANGE_PARAMS ClassInstallParams, int ClassInstallParamsSize);

        [DllImport("setupapi.dll", SetLastError = true)]
        private static extern bool SetupDiCallClassInstaller(uint InstallFunction, IntPtr DeviceInfoSet, ref SP_DEVINFO_DATA DeviceInfoData);

        [DllImport("setupapi.dll", SetLastError = true)]
        private static extern bool SetupDiDestroyDeviceInfoList(IntPtr DeviceInfoSet);

        [DllImport("cfgmgr32.dll")]
        private static extern int CM_Get_Parent(out uint pdnDevInst, uint dnDevInst, int ulFlags);

        [DllImport("cfgmgr32.dll", EntryPoint = "CM_Get_Device_IDW", CharSet = CharSet.Unicode)]
        private static extern int CM_Get_Device_ID(uint dnDevInst, StringBuilder Buffer, int BufferLen, int ulFlags);

        [DllImport("cfgmgr32.dll", EntryPoint = "CM_Locate_DevNodeW", CharSet = CharSet.Unicode)]
        private static extern int CM_Locate_DevNode(out uint pdnDevInst, string pDeviceID, int ulFlags);

        [DllImport("cfgmgr32.dll")]
        private static extern int CM_Reenumerate_DevNode(uint dnDevInst, int ulFlags);

        // search FeliCa Devices
        static List<DeviceInfo> GetFeliCaDevices()
        {
            var devices = new List<DeviceInfo>();
            IntPtr deviceInfoSet = SetupDiGetClassDevs(IntPtr.Zero, null, IntPtr.Zero, DIGCF_PRESENT | DIGCF_ALLCLASSES);
            if (deviceInfoSet == INVALID_HANDLE_VALUE)
            {
                FelicaCallError("[SetupAPI Error]", "SetupDiGetClassDevs: " + GetLastWin32ErrorMessage());
                return devices;
            }

            try
            {
                for (uint index = 0; ; index++)
                {
                    SP_DEVINFO_DATA deviceInfoData = CreateDeviceInfoData();
                    if (!SetupDiEnumDeviceInfo(deviceInfoSet, index, ref deviceInfoData))
                    {
                        int errorCode = Marshal.GetLastWin32Error();
                        if (errorCode != ERROR_NO_MORE_ITEMS)
                        {
                            FelicaCallError("[SetupAPI Error]", "SetupDiEnumDeviceInfo: " + GetWin32ErrorMessage(errorCode));
                        }
                        break;
                    }

                    DeviceInfo device = new DeviceInfo
                    {
                        Name = GetDeviceName(deviceInfoSet, ref deviceInfoData),
                        DeviceID = GetDeviceInstanceId(deviceInfoSet, ref deviceInfoData),
                        HardwareID = GetDeviceRegistryProperty(deviceInfoSet, ref deviceInfoData, SPDRP_HARDWAREID),
                        AncestorDeviceIDs = GetAncestorDeviceInstanceIds(deviceInfoData.DevInst),
                        Status = "OK"
                    };

                    if (IsFeliCaDevice(device))
                    {
                        devices.Add(device);
                    }
                }
            }
            finally
            {
                SetupDiDestroyDeviceInfoList(deviceInfoSet);
            }

            return devices;
        }

        private static void RestartDeviceAndParents(DeviceInfo device, HashSet<string> restartedDeviceIds)
        {
            RestartDevice(device.DeviceID, device.Name, restartedDeviceIds);
            ReenumerateDeviceNode(device.DeviceID);

            foreach (string ancestorDeviceId in device.AncestorDeviceIDs ?? new List<string>())
            {
                if (!IsUsbAncestorForRestart(ancestorDeviceId))
                {
                    continue;
                }

                FelicaCallError("[RestartDevice]", "restart parent USB device: " + ancestorDeviceId);
                RestartDevice(ancestorDeviceId, device.Name + " parent", restartedDeviceIds);
                ReenumerateDeviceNode(ancestorDeviceId);
                Thread.Sleep(2000);
                break;
            }
        }

        // reboot Sony FeliCa
        static bool RestartDevice(string instanceId, string friendlyName, HashSet<string> restartedDeviceIds)
        {
            if (string.IsNullOrEmpty(instanceId))
            {
                return false;
            }

            if (restartedDeviceIds != null && !restartedDeviceIds.Add(instanceId))
            {
                FelicaCallError("[RestartDevice]", "skip duplicate device: " + instanceId);
                return false;
            }

            IntPtr deviceInfoSet = SetupDiGetClassDevs(IntPtr.Zero, null, IntPtr.Zero, DIGCF_PRESENT | DIGCF_ALLCLASSES);
            if (deviceInfoSet == INVALID_HANDLE_VALUE)
            {
                FelicaCallError("[SetupAPI Error]", "SetupDiGetClassDevs: " + GetLastWin32ErrorMessage());
                return false;
            }

            try
            {
                for (uint index = 0; ; index++)
                {
                    SP_DEVINFO_DATA deviceInfoData = CreateDeviceInfoData();
                    if (!SetupDiEnumDeviceInfo(deviceInfoSet, index, ref deviceInfoData))
                    {
                        int errorCode = Marshal.GetLastWin32Error();
                        if (errorCode != ERROR_NO_MORE_ITEMS)
                        {
                            FelicaCallError("[SetupAPI Error]", "SetupDiEnumDeviceInfo: " + GetWin32ErrorMessage(errorCode));
                        }
                        break;
                    }

                    string currentInstanceId = GetDeviceInstanceId(deviceInfoSet, ref deviceInfoData);
                    if (!string.Equals(currentInstanceId, instanceId, StringComparison.OrdinalIgnoreCase))
                    {
                        continue;
                    }

                    FelicaCallError("[RestartDevice]", "disable Sony FeliCa: " + friendlyName);
                    bool disabled = ChangeDeviceState(deviceInfoSet, ref deviceInfoData, DICS_DISABLE, "disable");
                    Thread.Sleep(1000);

                    FelicaCallError("[RestartDevice]", "enable Sony FeliCa: " + friendlyName);
                    bool enabled = ChangeDeviceState(deviceInfoSet, ref deviceInfoData, DICS_ENABLE, "enable");
                    Thread.Sleep(2000);
                    bool propChanged = enabled && ChangeDeviceState(deviceInfoSet, ref deviceInfoData, DICS_PROPCHANGE, "propchange");

                    if (disabled && enabled)
                    {
                        FelicaCallError("[RestartDevice]", "reboot Sony FeliCa OK: " + friendlyName + ", propchange=" + propChanged);
                    }
                    return disabled && enabled;
                }

                FelicaCallError("[RestartDevice]", "device not found: " + instanceId);
                return false;
            }
            finally
            {
                SetupDiDestroyDeviceInfoList(deviceInfoSet);
            }
        }

        private static SP_DEVINFO_DATA CreateDeviceInfoData()
        {
            SP_DEVINFO_DATA deviceInfoData = new SP_DEVINFO_DATA();
            deviceInfoData.cbSize = (uint)Marshal.SizeOf(typeof(SP_DEVINFO_DATA));
            return deviceInfoData;
        }

        private static string GetDeviceName(IntPtr deviceInfoSet, ref SP_DEVINFO_DATA deviceInfoData)
        {
            string friendlyName = GetDeviceRegistryProperty(deviceInfoSet, ref deviceInfoData, SPDRP_FRIENDLYNAME);
            if (!string.IsNullOrEmpty(friendlyName))
            {
                return friendlyName;
            }

            return GetDeviceRegistryProperty(deviceInfoSet, ref deviceInfoData, SPDRP_DEVICEDESC);
        }

        private static string GetDeviceInstanceId(IntPtr deviceInfoSet, ref SP_DEVINFO_DATA deviceInfoData)
        {
            StringBuilder instanceId = new StringBuilder(1024);
            int requiredSize;
            if (SetupDiGetDeviceInstanceId(deviceInfoSet, ref deviceInfoData, instanceId, instanceId.Capacity, out requiredSize))
            {
                return instanceId.ToString();
            }

            return string.Empty;
        }

        private static string GetDeviceRegistryProperty(IntPtr deviceInfoSet, ref SP_DEVINFO_DATA deviceInfoData, uint property)
        {
            byte[] buffer = new byte[4096];
            uint propertyRegDataType;
            uint requiredSize;
            if (!SetupDiGetDeviceRegistryProperty(deviceInfoSet, ref deviceInfoData, property, out propertyRegDataType, buffer, (uint)buffer.Length, out requiredSize))
            {
                return string.Empty;
            }

            if (requiredSize == 0)
            {
                return string.Empty;
            }

            int length = (int)Math.Min(requiredSize, (uint)buffer.Length);
            return Encoding.Unicode.GetString(buffer, 0, length).TrimEnd('\0').Replace('\0', ' ');
        }

        private static bool IsFeliCaDevice(DeviceInfo device)
        {
            string target = (device.Name ?? string.Empty) + " " + (device.DeviceID ?? string.Empty) + " " + (device.HardwareID ?? string.Empty);
            return FeliCaDeviceRegex.IsMatch(target);
        }

        private static bool ChangeDeviceState(IntPtr deviceInfoSet, ref SP_DEVINFO_DATA deviceInfoData, uint stateChange, string actionName)
        {
            SP_PROPCHANGE_PARAMS propChangeParams = new SP_PROPCHANGE_PARAMS();
            propChangeParams.ClassInstallHeader.cbSize = (uint)Marshal.SizeOf(typeof(SP_CLASSINSTALL_HEADER));
            propChangeParams.ClassInstallHeader.InstallFunction = DIF_PROPERTYCHANGE;
            propChangeParams.StateChange = stateChange;
            propChangeParams.Scope = DICS_FLAG_GLOBAL;
            propChangeParams.HwProfile = 0;

            if (!SetupDiSetClassInstallParams(deviceInfoSet, ref deviceInfoData, ref propChangeParams, Marshal.SizeOf(typeof(SP_PROPCHANGE_PARAMS))))
            {
                FelicaCallError("[SetupAPI Error]", actionName + " SetupDiSetClassInstallParams: " + GetLastWin32ErrorMessage());
                return false;
            }

            if (!SetupDiCallClassInstaller(DIF_PROPERTYCHANGE, deviceInfoSet, ref deviceInfoData))
            {
                FelicaCallError("[SetupAPI Error]", actionName + " SetupDiCallClassInstaller: " + GetLastWin32ErrorMessage());
                return false;
            }

            return true;
        }

        private static List<string> GetAncestorDeviceInstanceIds(uint devInst)
        {
            List<string> ancestorDeviceIds = new List<string>();
            uint parentDevInst;
            uint currentDevInst = devInst;

            for (int depth = 0; depth < 8; depth++)
            {
                if (CM_Get_Parent(out parentDevInst, currentDevInst, 0) != CR_SUCCESS)
                {
                    break;
                }

                string parentDeviceId = GetCfgMgrDeviceId(parentDevInst);
                if (string.IsNullOrEmpty(parentDeviceId))
                {
                    break;
                }

                ancestorDeviceIds.Add(parentDeviceId);
                currentDevInst = parentDevInst;
            }

            return ancestorDeviceIds;
        }

        private static string GetCfgMgrDeviceId(uint devInst)
        {
            StringBuilder deviceId = new StringBuilder(1024);
            if (CM_Get_Device_ID(devInst, deviceId, deviceId.Capacity, 0) != CR_SUCCESS)
            {
                return string.Empty;
            }

            return deviceId.ToString();
        }

        private static bool IsUsbAncestorForRestart(string instanceId)
        {
            if (string.IsNullOrEmpty(instanceId))
            {
                return false;
            }

            return instanceId.StartsWith("USB\\VID_", StringComparison.OrdinalIgnoreCase);
        }

        private static void ReenumerateDeviceNode(string instanceId)
        {
            if (string.IsNullOrEmpty(instanceId))
            {
                return;
            }

            uint devInst;
            int result = CM_Locate_DevNode(out devInst, instanceId, 0);
            if (result != CR_SUCCESS)
            {
                FelicaCallError("[CfgMgr Error]", "CM_Locate_DevNode: " + instanceId + ", CR=" + result);
                return;
            }

            result = CM_Reenumerate_DevNode(devInst, 0);
            if (result != CR_SUCCESS)
            {
                FelicaCallError("[CfgMgr Error]", "CM_Reenumerate_DevNode: " + instanceId + ", CR=" + result);
            }
        }

        private static string FormatDeviceInfo(DeviceInfo device)
        {
            string ancestors = device.AncestorDeviceIDs == null ? string.Empty : string.Join(" > ", device.AncestorDeviceIDs.ToArray());
            return "Name=" + (device.Name ?? string.Empty)
                + ", DeviceID=" + (device.DeviceID ?? string.Empty)
                + ", HardwareID=" + (device.HardwareID ?? string.Empty)
                + ", Ancestors=" + ancestors;
        }

        private static string GetLastWin32ErrorMessage()
        {
            return GetWin32ErrorMessage(Marshal.GetLastWin32Error());
        }

        private static string GetWin32ErrorMessage(int errorCode)
        {
            return "Win32Error=" + errorCode + " " + new Win32Exception(errorCode).Message;
        }
        // add #11707 体重計AppとカードAppにてカードが読めない事象が発生する 高 end

        /**
        * @fn void Polling()
        * @brief フェリカカードの接続状態を監視
        * @details フェリカカードの接続状態を読み込んで接続状態と読込情報が変わった場合にイベントを発生させる
        */
        // mod #11818 体重計およびカードアプリでカードの読込が遅くなっているる 高 start
        //private static void Polling()
        private static bool Polling()
        // mod #11818 体重計およびカードアプリでカードの読込が遅くなっているる 高 end
        {
            //mod #9731 体重計アプリとFNSiカードアプリが同時にカードをつかえない。 donghao start
            //try
            //{
            //    bool nowFelicaConFlg = false;
            //    lock (FelicaLibTdc.LockoObj)
            //    {
            //        if (Open())
            //        {
            //            // フェリカ接続ON
            //            nowFelicaConFlg = true;

            //            // フェリカの接続状態が変更した場合
            //            if (FelicaConnectFlg != nowFelicaConFlg)
            //            {
            //                // フェリカの接続状態セット
            //                FelicaConnectFlg = nowFelicaConFlg;
            //                // フェリカの接続状態イベント
            //                FelicaConnectChange(FelicaConnectFlg);
            //            }

            //            try
            //            {
            //                StructurePolling sp = new StructurePolling();

            //                // FNW互換カード 対象
            //                byte[] systemCode = new byte[2];
            //                systemCode[0] = Convert.ToByte(IcSystemCode.Substring(0, 2), 16);
            //                systemCode[1] = Convert.ToByte(IcSystemCode.Substring(2, 2), 16);
            //                HandleContainer.gchSystemCode = GCHandle.Alloc(systemCode, GCHandleType.Pinned);
            //                sp.ptrSystemCode = HandleContainer.gchSystemCode.AddrOfPinnedObject();

            //                sp.bytTimeSlot = 0x00;


            //                StructureCardInformation sci = new StructureCardInformation();

            //                byte[] cardIdm = new byte[8]; // InputStructureReadBlock…と共有することでpollingで得たIDmを渡す
            //                HandleContainer.gchCardIdm = GCHandle.Alloc(cardIdm, GCHandleType.Pinned);
            //                sci.ptrCardIdm = HandleContainer.gchCardIdm.AddrOfPinnedObject();

            //                byte[] cardPmm = new byte[8];
            //                HandleContainer.gchCardPmm = GCHandle.Alloc(cardPmm, GCHandleType.Pinned);
            //                sci.ptrCardPmm = HandleContainer.gchCardPmm.AddrOfPinnedObject();

            //                // ポーリングによるカード情報取得
            //                byte numberOfCards = 0x00;
            //                HandleContainer.gchNumberOfCards = GCHandle.Alloc(numberOfCards, GCHandleType.Pinned);
            //                FDWC.PollingAndGetCardInformation(ref sp, ref numberOfCards, ref sci);

            //                // IDmの文字列情報
            //                string strCardIdm = "";

            //                //フェリカカード認識枚数チェック
            //                if (numberOfCards == 1)
            //                {
            //                    strCardIdm = Encoding.ASCII.GetString(cardIdm);
            //                }

            //                // カードが変わったら
            //                if (viewCardIdm != strCardIdm)
            //                {
            //                    viewCardIdm = strCardIdm;

            //                    // カード変更イベント
            //                    CardChenge(strCardIdm, (Byte[])cardIdm);
            //                }

            //            }
            //            finally
            //            {
            //                HandleContainer.FreeHandle();
            //            }

            //            // フェリカカードクローズ
            //            Close();
            //        }
            //        else
            //        {
            //            // フェリカ接続OFF
            //            nowFelicaConFlg = false;

            //            // カード情報クリア
            //            viewCardIdm = "";
            //        }

            //        // フェリカの接続状態が変更した場合
            //        if (FelicaConnectFlg != nowFelicaConFlg)
            //        {
            //            // フェリカの接続状態セット
            //            FelicaConnectFlg = nowFelicaConFlg;

            //            // フェリカの接続状態イベント
            //            FelicaConnectChange(FelicaConnectFlg);
            //        }
            //    }
            // add #11818 体重計およびカードアプリでカードの読込が遅くなっているる 高 start
            bool bRet = true;
            // add #11818 体重計およびカードアプリでカードの読込が遅くなっているる 高 end
            try
            {
                StructurePolling sp = new StructurePolling();

                // FNW互換カード 対象
                byte[] systemCode = new byte[2];
                systemCode[0] = Convert.ToByte(IcSystemCode.Substring(0, 2), 16);
                systemCode[1] = Convert.ToByte(IcSystemCode.Substring(2, 2), 16);
                HandleContainer.gchSystemCode = GCHandle.Alloc(systemCode, GCHandleType.Pinned);
                sp.ptrSystemCode = HandleContainer.gchSystemCode.AddrOfPinnedObject();

                sp.bytTimeSlot = 0x00;


                StructureCardInformation sci = new StructureCardInformation();

                byte[] cardIdm = new byte[8]; // InputStructureReadBlock…と共有することでpollingで得たIDmを渡す
                HandleContainer.gchCardIdm = GCHandle.Alloc(cardIdm, GCHandleType.Pinned);
                sci.ptrCardIdm = HandleContainer.gchCardIdm.AddrOfPinnedObject();

                byte[] cardPmm = new byte[8];
                HandleContainer.gchCardPmm = GCHandle.Alloc(cardPmm, GCHandleType.Pinned);
                sci.ptrCardPmm = HandleContainer.gchCardPmm.AddrOfPinnedObject();

                // ポーリングによるカード情報取得
                byte numberOfCards = 0x00;
                HandleContainer.gchNumberOfCards = GCHandle.Alloc(numberOfCards, GCHandleType.Pinned);
                // add #11818 体重計およびカードアプリでカードの読込が遅くなっているる 高 start
                bool bPolling = true;
                bool bRetFunc;

                bRetFunc = FDWC.ReaderWriterIsAlive(ref bPolling);
                if (bRetFunc == false || bPolling == false)
                {
                    viewCardIdm = "";
                    bRet = false;
                    return bRet;
                }
                // add #11818 体重計およびカードアプリでカードの読込が遅くなっているる 高 end
                FDWC.PollingAndGetCardInformation(ref sp, ref numberOfCards, ref sci);

                // IDmの文字列情報
                string strCardIdm = "";

                //フェリカカード認識枚数チェック
                if (numberOfCards == 1)
                {
                    strCardIdm = Encoding.ASCII.GetString(cardIdm);
                }

                // カードが変わったら
                if (viewCardIdm != strCardIdm)
                {

                    // カード変更イベント
                    if (CardChenge(strCardIdm, (Byte[])cardIdm))
                    {
                        viewCardIdm = strCardIdm;
                    }
                }

            }
            //mod #9731 体重計アプリとFNSiカードアプリが同時にカードをつかえない。 donghao end
            catch (Exception e)
            {
                // ログ書き込み
                FelicaCallError("ポーリングエラー", e.Message + e.StackTrace);
                // add #11818 体重計およびカードアプリでカードの読込が遅くなっているる 高 start
                viewCardIdm = "";
                bRet = false;
                // add #11818 体重計およびカードアプリでカードの読込が遅くなっているる 高 end
            }
            finally
            {
                HandleContainer.FreeHandle();
            }
            // add #11818 体重計およびカードアプリでカードの読込が遅くなっているる 高 start
            return bRet;
            // add #11818 体重計およびカードアプリでカードの読込が遅くなっているる 高 end
        }

        /**
        * @fn void FelicaError(String strErrorMessage1, String strErrorMessage2)
        * @bref エラー発生時に呼ばれる関数
        * @param[in] strErrorMessage1 メッセージ1
        * @param[in] strErrorMessage2 メッセージ2
        * @details エラー発生時に呼ばれる関数
        */
        private static void FelicaCallError(String strErrorMessage1, String strErrorMessage2 )
        {
            FelicaErrorEvent(strErrorMessage1, strErrorMessage2);
        }

        /**
        * @fn void FelicaCallInfo(String strMessage1)
        * @bref 情報ログ発生時に呼ばれる関数
        * @param[in] strMessage1 メッセージ1
        * @details 情報ログ発生時に呼ばれる関数
        */
        private static void FelicaCallInfo(String strMessage1)
        {
            FelicaInfoEvent(strMessage1);
        }

        /**
        * @fn void FelicaConnectChange(Boolaen? conState)
        * @brief フェリカカードの接続状態が変更されたことを伝える関数
        * @param[in] conState 接続状態(true：接続ON、false：接続OFF)
        * @details フェリカカードの接続状態が変更されたことを伝える関数
        */
        private static void FelicaConnectChange(Boolean? conState)
        {
            FelicaConnectChangeEvent(conState);
        }


        /**
        * @fn void CardChenge(Byte[] bIdm)
        * @brief フェリカカードの情報が変更されたことを伝える関数
        * @param[in] strIdm 読み取ったフェリカカードのIDm情報(テキスト)
        * @param[in] bIdm 読み取ったフェリカカードのIDm情報(バイト配列)
        * @details フェリカカードの情報が変更されたことを伝える関数
        */
        //mod #9731 体重計アプリとFNSiカードアプリが同時にカードをつかえない。 donghao start
        //private static void CardChenge(String strIdm, Byte[] bIdm)
        //{
        //    FelicaChangeEvent(strIdm, bIdm);
        //}
        private static bool CardChenge(String strIdm, Byte[] bIdm)
        {
            return FelicaChangeEvent(strIdm, bIdm);
        }
        //mod #9731 体重計アプリとFNSiカードアプリが同時にカードをつかえない。 donghao end
        #endregion フェリカカードポーリング

        #region フェリカカード読み取り
        /**
        * @fn static byte[] Read(byte[] sysCode, byte[] serviceCode, int numberOfBlocks)
        * @brief FeliCaカードの読み取り
        * @param[in] sysCode システムコード
        * @param[in] serviceCode サービスコード
        * @param[in] numberOfBlocks ブロック数
        * @return byte[] 読み取ったFeliCaカード情報のバイト配列
        * @details 指定されたシステムコード、サービスコード、ブロック数の情報をFeliCaカードから読み取る
        */
        public static byte[] Read(byte[] sysCode, byte[] serviceCode, int numberOfBlocks)
        {
            try
            {
                StructurePolling sp = new StructurePolling();

                //byte[] systemCode = new byte[2] { 0xff, 0xff }; // 全カード 対象
                //byte[] systemCode = new byte[2] { 0x88, 0xd5 }; // FNW互換カード 対象
                HandleContainer.gchSystemCode = GCHandle.Alloc(sysCode, GCHandleType.Pinned);
                sp.ptrSystemCode = HandleContainer.gchSystemCode.AddrOfPinnedObject();

                sp.bytTimeSlot = 0x00;


                StructureCardInformation sci = new StructureCardInformation();

                byte[] cardIdm = new byte[8]; // InputStructureReadBlock…と共有することでpollingで得たIDmを渡す
                HandleContainer.gchCardIdm = GCHandle.Alloc(cardIdm, GCHandleType.Pinned);
                sci.ptrCardIdm = HandleContainer.gchCardIdm.AddrOfPinnedObject();

                byte[] cardPmm = new byte[8];
                HandleContainer.gchCardPmm = GCHandle.Alloc(cardPmm, GCHandleType.Pinned);
                sci.ptrCardPmm = HandleContainer.gchCardPmm.AddrOfPinnedObject();


                InputStructureReadBlockWithoutEncryption isrbwe = new InputStructureReadBlockWithoutEncryption();

                isrbwe.ptrCardIdm = HandleContainer.gchCardIdm.AddrOfPinnedObject();

                isrbwe.bytNumberOfServices = 0x01;

                //byte[] serviceCodeList = { 0x49, 0x00 };
                HandleContainer.gchServiceCodeList = GCHandle.Alloc(serviceCode, GCHandleType.Pinned);
                isrbwe.ptrServiceCodeList = HandleContainer.gchServiceCodeList.AddrOfPinnedObject();

                isrbwe.bytNumberOfBlocks = (byte)numberOfBlocks;

                // 「ブロックリスト1つ = 2バイト([アクセスモードなど(通常0x80)]、[ブロック番号])」
                List<byte> blockList = new List<byte>();
                for(int i=0;i<numberOfBlocks;i++)
                {
                    blockList.Add(0x80);
                    blockList.Add((byte)i);
                }
                HandleContainer.gchBlockList = GCHandle.Alloc(blockList.ToArray(), GCHandleType.Pinned);
                isrbwe.ptrBlockList = HandleContainer.gchBlockList.AddrOfPinnedObject();


                OutputStructureReadBlockWithoutEncryption osrbwe = new OutputStructureReadBlockWithoutEncryption();

                //byte[,] readBlockData = new byte[4, 16];
                byte[] readBlockData = new byte[16 * numberOfBlocks];
                HandleContainer.gchReadBlockData = GCHandle.Alloc(readBlockData, GCHandleType.Pinned);
                osrbwe.ptrBlockData = HandleContainer.gchReadBlockData.AddrOfPinnedObject();

                byte resultNumberOfBlocks = 0x00;
                HandleContainer.gchResultNumberOfBlocks = GCHandle.Alloc(resultNumberOfBlocks, GCHandleType.Pinned);
                osrbwe.ptrResultNumberOfBlocks = HandleContainer.gchResultNumberOfBlocks.AddrOfPinnedObject();

                byte statusFlag1 = 0x00;
                HandleContainer.gchStatusFlag1 = GCHandle.Alloc(statusFlag1, GCHandleType.Pinned);
                osrbwe.ptrStatusFlag1 = HandleContainer.gchStatusFlag1.AddrOfPinnedObject();

                byte statusFlag2 = 0x00;
                HandleContainer.gchStatusFlag2 = GCHandle.Alloc(statusFlag2, GCHandleType.Pinned);
                osrbwe.ptrStatusFlag2 = HandleContainer.gchStatusFlag2.AddrOfPinnedObject();


                // ポーリングによるカード情報取得
                byte numberOfCards = 0x00;
                if (false == FDWC.PollingAndGetCardInformation(ref sp, ref numberOfCards, ref sci))
                {
                    FDWC.GetLastErrorTypes(ref FelicaLibTdc.FelicaError, ref FelicaLibTdc.RwError);
                    return null;
                }

                // カード読み取り
                if (false == FDWC.ReadBlockWithoutEncryption(ref isrbwe, ref osrbwe))
                {
                    FDWC.GetLastErrorTypes(ref FelicaLibTdc.FelicaError, ref FelicaLibTdc.RwError);
                    return null;
                }


                // 最後まで抜けたら成功
                return readBlockData;
            }
            finally
            {
                HandleContainer.FreeHandle();
            }
        }
        #endregion フェリカカード読み取り

        #region フェリカカード書き込み
        /**
        * @fn static bool Write(byte[] writeBytes, byte[] sysCode, byte[] serviceCode, int numberOfBlocks)
        * @brief FeliCaカードの書き込み
        * @param[in] writeBytes 書き込む内容のバイト配列
        * @param[in] sysCode システムコード
        * @param[in] serviceCode サービスコード
        * @param[in] numberOfBlocks ブロック数
        * @return bool true：成功、false；失敗
        * @details 指定されたシステムコード、サービスコード、ブロック数の情報をFeliCaカードに書き込む
        */
        public static bool Write(byte[] writeBytes, byte[] sysCode, byte[] serviceCode, int numberOfBlocks)
        {
            try
            {
                StructurePolling sp = new StructurePolling();

                //byte[] systemCode = new byte[2] { 0xff, 0xff }; // 全カード 対象
                //byte[] systemCode = new byte[2] { 0x88, 0xd5 }; // FNW互換カード 対象
                HandleContainer.gchSystemCode = GCHandle.Alloc(sysCode, GCHandleType.Pinned);
                sp.ptrSystemCode = HandleContainer.gchSystemCode.AddrOfPinnedObject();

                sp.bytTimeSlot = 0x00;


                StructureCardInformation sci = new StructureCardInformation();

                byte[] cardIdm = new byte[8]; // InputStructureReadBlock…と共有することでpollingで得たIDmを渡す
                HandleContainer.gchCardIdm = GCHandle.Alloc(cardIdm, GCHandleType.Pinned);
                sci.ptrCardIdm = HandleContainer.gchCardIdm.AddrOfPinnedObject();

                byte[] cardPmm = new byte[8];
                HandleContainer.gchCardPmm = GCHandle.Alloc(cardPmm, GCHandleType.Pinned);
                sci.ptrCardPmm = HandleContainer.gchCardPmm.AddrOfPinnedObject();


                InputStructureWriteBlockWithoutEncryption iswbwe = new InputStructureWriteBlockWithoutEncryption();

                iswbwe.ptrCardIdm = HandleContainer.gchCardIdm.AddrOfPinnedObject();

                iswbwe.bytNumberOfServices = 0x01;

                //byte[] serviceCodeList = { 0x49, 0x00 };
                HandleContainer.gchServiceCodeList = GCHandle.Alloc(serviceCode, GCHandleType.Pinned);
                iswbwe.ptrServiceCodeList = HandleContainer.gchServiceCodeList.AddrOfPinnedObject();

                iswbwe.bytNumberOfBlocks = (byte)numberOfBlocks;

                // 「ブロックリスト1つ = 2バイト([アクセスモードなど(通常0x80)]、[ブロック番号])」
                List<byte> blockList = new List<byte>();
                for (int i = 0; i < numberOfBlocks; i++)
                {
                    blockList.Add(0x80);
                    blockList.Add((byte)i);
                }
                HandleContainer.gchBlockList = GCHandle.Alloc(blockList.ToArray(), GCHandleType.Pinned);
                iswbwe.ptrBlockList = HandleContainer.gchBlockList.AddrOfPinnedObject();

                //byte[] writeBlockData = new byte[16 * 4];
                byte[] writeBlockData = writeBytes;
                HandleContainer.gchWriteBlockData = GCHandle.Alloc(writeBlockData, GCHandleType.Pinned);
                iswbwe.ptrBlockData = HandleContainer.gchWriteBlockData.AddrOfPinnedObject();


                OutputStructureWriteBlockWithoutEncryption oswbwe = new OutputStructureWriteBlockWithoutEncryption();

                byte statusFlag1 = 0x00;
                HandleContainer.gchStatusFlag1 = GCHandle.Alloc(statusFlag1, GCHandleType.Pinned);
                oswbwe.ptrStatusFlag1 = HandleContainer.gchStatusFlag1.AddrOfPinnedObject();

                byte statusFlag2 = 0x00;
                HandleContainer.gchStatusFlag2 = GCHandle.Alloc(statusFlag2, GCHandleType.Pinned);
                oswbwe.ptrStatusFlag2 = HandleContainer.gchStatusFlag2.AddrOfPinnedObject();

                // ポーリングによるカード情報取得
                byte numberOfCards = 0x00;
                if (false == FDWC.PollingAndGetCardInformation(ref sp, ref numberOfCards, ref sci))
                {
                    FDWC.GetLastErrorTypes(ref FelicaLibTdc.FelicaError, ref FelicaLibTdc.RwError);
                    return false;
                }

                // カード書き込み
                if (false == FDWC.WriteBlockWithoutEncryption(ref iswbwe, ref oswbwe))
                {
                    FDWC.GetLastErrorTypes(ref FelicaLibTdc.FelicaError, ref FelicaLibTdc.RwError);
                    return false;
                }

                // 最後まで抜けたら成功
                return true;
            }
            finally
            {
                HandleContainer.FreeHandle();
            }
        }
        #endregion フェリカカード書き込み

        public static bool Write(byte[] writeBytes, byte[] sysCode, byte[] serviceCode, ushort startBlock, int numberOfBlocks)
        {
            try
            {
                StructurePolling sp = new StructurePolling();

                //byte[] systemCode = new byte[2] { 0xff, 0xff }; // 全カード 対象
                //byte[] systemCode = new byte[2] { 0x88, 0xd5 }; // FNW互換カード 対象
                HandleContainer.gchSystemCode = GCHandle.Alloc(sysCode, GCHandleType.Pinned);
                sp.ptrSystemCode = HandleContainer.gchSystemCode.AddrOfPinnedObject();

                sp.bytTimeSlot = 0x00;


                StructureCardInformation sci = new StructureCardInformation();

                byte[] cardIdm = new byte[8]; // InputStructureReadBlock…と共有することでpollingで得たIDmを渡す
                HandleContainer.gchCardIdm = GCHandle.Alloc(cardIdm, GCHandleType.Pinned);
                sci.ptrCardIdm = HandleContainer.gchCardIdm.AddrOfPinnedObject();

                byte[] cardPmm = new byte[8];
                HandleContainer.gchCardPmm = GCHandle.Alloc(cardPmm, GCHandleType.Pinned);
                sci.ptrCardPmm = HandleContainer.gchCardPmm.AddrOfPinnedObject();


                InputStructureWriteBlockWithoutEncryption iswbwe = new InputStructureWriteBlockWithoutEncryption();

                iswbwe.ptrCardIdm = HandleContainer.gchCardIdm.AddrOfPinnedObject();

                iswbwe.bytNumberOfServices = 0x01;

                //byte[] serviceCodeList = { 0x49, 0x00 };
                HandleContainer.gchServiceCodeList = GCHandle.Alloc(serviceCode, GCHandleType.Pinned);
                iswbwe.ptrServiceCodeList = HandleContainer.gchServiceCodeList.AddrOfPinnedObject();

                iswbwe.bytNumberOfBlocks = (byte)numberOfBlocks;

                // 「ブロックリスト1つ = 2バイト([アクセスモードなど(通常0x80)]、[ブロック番号])」
                //List<byte> blockList = new List<byte>();
                byte[] blockList = new byte[numberOfBlocks * 2];
                for (ushort i = 0; i < numberOfBlocks; i++)
                {
                    blockList[i * 2] = (byte)((i + startBlock + 0x8000) >> 8);
                    blockList[i * 2 + 1] = (byte)((i + startBlock) & 0xFF);
                }

                HandleContainer.gchBlockList = GCHandle.Alloc(blockList, GCHandleType.Pinned);
                iswbwe.ptrBlockList = HandleContainer.gchBlockList.AddrOfPinnedObject();

                //byte[] writeBlockData = new byte[16 * 4];
                byte[] writeBlockData = writeBytes;
                HandleContainer.gchWriteBlockData = GCHandle.Alloc(writeBlockData, GCHandleType.Pinned);
                iswbwe.ptrBlockData = HandleContainer.gchWriteBlockData.AddrOfPinnedObject();


                OutputStructureWriteBlockWithoutEncryption oswbwe = new OutputStructureWriteBlockWithoutEncryption();

                byte statusFlag1 = 0x00;
                HandleContainer.gchStatusFlag1 = GCHandle.Alloc(statusFlag1, GCHandleType.Pinned);
                oswbwe.ptrStatusFlag1 = HandleContainer.gchStatusFlag1.AddrOfPinnedObject();

                byte statusFlag2 = 0x00;
                HandleContainer.gchStatusFlag2 = GCHandle.Alloc(statusFlag2, GCHandleType.Pinned);
                oswbwe.ptrStatusFlag2 = HandleContainer.gchStatusFlag2.AddrOfPinnedObject();

                // ポーリングによるカード情報取得
                byte numberOfCards = 0x00;
                if (false == FDWC.PollingAndGetCardInformation(ref sp, ref numberOfCards, ref sci))
                {
                    FDWC.GetLastErrorTypes(ref FelicaLibTdc.FelicaError, ref FelicaLibTdc.RwError);
                    return false;
                }

                // カード書き込み
                if (false == FDWC.WriteBlockWithoutEncryption(ref iswbwe, ref oswbwe))
                {
                    FDWC.GetLastErrorTypes(ref FelicaLibTdc.FelicaError, ref FelicaLibTdc.RwError);
                    return false;
                }

                // 最後まで抜けたら成功
                return true;
            }
            finally
            {
                HandleContainer.FreeHandle();
            }
        }
    }
}
