/**
* @file FelicaLibTdc.cs
* @brief フェリカカードライブラリ
* @author R.Izumi
* @date 2017/11/06
* @details フェリカカードのオープン・クローズ、読み込み・書き込み用のライブラリ
*/

using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Text;
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
        //スレッド実行フラグ
        private static bool running;
        // add #11386 H5体重測定時にカードが読めなくなる 高 start
        public static string wMutexName = @"Global\Global_Felica_QWErty";
        // add #11386 H5体重測定時にカードが読めなくなる 高 end

        // add #11707 体重計AppとカードAppにてカードが読めない事象が発生する 高 start
        public static DateTime? lastErrTime = null;
        // add #11707 体重計AppとカードAppにてカードが読めない事象が発生する 高 end

        // #12738 add 2026.06.08 Ferica処理で処理中状態を返すプロパティを追加 TDC米沢 start
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// Fericaスレッドの動作状態参照用プロパティ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public static bool IsRunning
        {
            get { return running; }
        }
        //----------------------------------------------------------------------------------------------------
        // #12738 add 2026.06.08 Ferica処理で処理中状態を返すプロパティを追加 TDC米沢 end

        #region オープン
        /**
        * @fn static bool Open()
        * @brief FeliCaカードリーダーのオープン
        * @return bool true：成功、false：失敗
        * @details FeliCaカードリーダーのオープン
        */
        public static bool Open()
        {
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
            string errMsg = "";

            // クローズ
            if (false == FDWC.CloseReaderWriter())
            {
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
                return false;
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
            return true;
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
            catch (Exception e)
            {
                FelicaCallError("Lock timeoutエラー", e.Message);
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
            catch (Exception e)
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
            // add #11386 H5体重測定時にカードが読めなくなる 高 end

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
                                lastErrTime = null;

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
                                //while (Lock(ref isTimeout))
                                //{
                                //    if (!isTimeout)
                                //    {

                                //        // フェリカカードポーリング
                                //        Polling();

                                //        Unlock();
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
                //mod #9731 体重計アプリとFNSiカードアプリが同時にカードをつかえない。 donghao end
            }
            // mod #11818 体重計およびカードアプリでカードの読込が遅くなっているる 高 end
        }
        #endregion ポーリングループ処理

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
    }
}
