using System;
using System.Collections.Generic;
using System.Text;
using System.IO;
using System.Diagnostics;

namespace NKK.FN3.ComServer.Library
{
    public class FN3TSlib
    {

        #region　StrToShort メソッド
        /// <summary>
        /// 文字列から数値に変換（'0'～'9'以外を除去、'-'の場合は値をマイナスにする）
        /// </summary>
        /// <param name="str">文字列</param>
        /// <returns>変換後の数値</returns>
        public static short StrToShort(string str)
        {
            int i, flg;
            short value;
            char ch;
            string work = "";

            for (i = 0, flg = 0; i < str.Length; i++)
            {
                ch = str[i];
                if (ch >= '0' && ch <= '9')
                {
                    work += ch;
                }
                else if (ch == '-')
                {
                    flg++;
                }
            }

            if (work == "")
            {
                value = 0;
            }
            else
            {
                value = Convert.ToInt16(work);
                if (flg > 0)
                {
                    value = (short)(0 - value);
                }
            }

            return (value);
        }
        #endregion

        #region　StrToShortEx メソッド
        /// <summary>
        /// 文字列から数値に変換（'0'～'9','.'以外を除去、'-'の場合は値をマイナスにする）
        /// 又、システムで使用する小数点以下桁数をもとに数値の桁合わせを行う
        ///   例１：”123”で小数点以下桁数2の場合→12300
        ///   例２：”12.3”で小数点以下桁数2の場合→1230
        /// </summary>
        /// <param name="str">文字列</param>
        /// <param name="dec">小数点以下桁数</param>
        /// <returns>変換後の数値</returns>
        public static short StrToShortEx(string str, short dec)
        {
            int i, flg, flg2;
            int inum;
            short value;
            double dval;
            double dnum;
            char ch;
            string work = "";

            for (i = 0, dnum = 1.0; i < dec; i++)
            {
                dnum *= 10.0;
            }

            for (i = 0, flg = 0, flg2 = 0; i < str.Length; i++)
            {
                ch = str[i];
                if (ch >= '0' && ch <= '9')
                {
                    work += ch;
                }
                else if (ch == '.')
                {
                    if (flg == 0)
                    {
                        work += ch;
                    }
                    flg++;
                }
                else if (ch == '-')
                {
                    flg2++;
                }
            }

            if (work == "")
            {
                value = 0;
            }
            else
            {

                dval = Convert.ToDouble(work);
                if (dec > 0)
                {
                    dval *= dnum;
                }
                // <<<<< CHG Y.Takamura 2010/07/26 小数値から整数値への変換で切り上げされる不具合の対応（4.40→441）
                //value = (short)(Math.Ceiling(dval));    // 小数点以下切り上げ
                work = dval.ToString();
                dval = Convert.ToDouble(work);
                dval = Math.Ceiling(dval);  // 小数点以下切り上げ
                work = dval.ToString();
                inum = Convert.ToInt32(work);
                if (inum > (int)(short.MaxValue))
                {
                    inum = (int)(short.MaxValue);
                }
                else if (inum < short.MinValue)
                {
                    inum = (int)(short.MinValue);
                }
                value = (short)inum;
                // >>>>> CHG Y.Takamura 2010/07/26 小数値から整数値への変換で切り上げされる不具合の対応（4.40→441）
                if (flg2 > 0)
                {
                    value = (short)(0 - value);
                }
            }

            return (value);
        }
        #endregion

        #region　StrToByte メソッド
        /// <summary>
        /// String型文字列をByte型配列に入れる
        /// </summary>
        /// <param name="BeforeBuf">
        /// 変換元バッファ</param>
        /// <param name="len">
        /// 変換元文字長</param>
        /// <param name="AfterBuf">
        /// 変換先バッファ</param>
        public static void StrToByte(string BeforeBuf, int len, byte[] AfterBuf)
        {
            char[] c = new char[2048];
            BeforeBuf.CopyTo(0, c, 0, len);
            for (int i = 0; i < len; i++)
            {
                AfterBuf[i] = (byte)c[i];
            }            
        }
        #endregion

        #region　BinToBcdToByte メソッド
        /// <summary>
        /// BIN型をBCD型に変換
        /// </summary>
        /// <param name="bin">
        /// BIN値</param>
        /// <returns>
        /// BCD値</returns>
        public static byte BinToBcdToByte(int bin)
        {
            return( (byte)Convert.ToInt16(string.Format("{0}", bin), 16));
        }
        #endregion

        #region　BcdToBinToByte メソッド
        /// <summary>
        /// BCD型をBIN型に変換
        /// </summary>
        /// <param name="bcd">
        /// BCD値</param>
        /// <returns>
        /// BIN値</returns>
        public static byte BcdToBinToByte(byte bcd)
        {
            return ((byte)Convert.ToInt16(string.Format("{0:x02}", bcd)));
        }
        #endregion

        #region　FormatAdd メソッド
        /// -----------------------------------------------------------------------------------
        /// <summary>
        /// STX・ETX変換、STX・CRC・ETX付加。</summary>
        /// <param name="BeforeBuf">
        /// 変換元バッファ</param>
        /// <param name="BeforeLen">
        /// 変換元バッファ長</param>
        /// <param name="AfterBuf">
        /// 変換先バッファ</param>
        /// -----------------------------------------------------------------------------------
        public static int FormatAdd(byte[] BeforeBuf, int BeforeLen, byte[] AfterBuf)
        {
            short i, len, crc;
            byte[] work = new byte[10240];

            //	BeforeLenチェック
        	if ( BeforeLen<=0 || BeforeLen>=work.Length  ) 
            {
    	    	return (0);
	        }   	

        	//	CRCの算出
	        for ( i=0,crc=0;i<BeforeLen;i++ ) crc+=BeforeBuf[i];

            //memset(work, 0, work.Length);
            Array.Clear(work, 0, work.Length);
        	work[0] = 0x02;		//	STXをセット
        	len = 1;

        	for ( i=0;i<BeforeLen;i++ ) 
            {
        		if ( BeforeBuf[i]==0x02 ) 
                {
			        work[len] = 0x10;
			        len++;
			        work[len] = 0x12;
	    	    }
    		    else if ( BeforeBuf[i]==0x03 ) 
                {
        			work[len] = 0x10;
			        len++;
			        work[len] = 0x13;
		        }
		        else if ( BeforeBuf[i]==0x10 ) 
                {
			        work[len] = 0x10;
			        len++;
			        work[len] = 0x10;
		        }
		        else 
                {
			        work[len] = BeforeBuf[i];
		        }
		        len++;
		        if ( len>=work.Length -2 ) 	//	サイズオーバー(-2:CRC,ETX)
                {
			        len = 0;
			        break;
		        }
	        }
	        if ( len>1 ) 
            {
// 2008.12.13 米沢 以下追加 CRCのDLE追加処理
                //work[len++] = (byte)crc;	//	CRC
                if ((byte)crc == 0x02 || (byte)crc == 0x03 || (byte)crc == 0x10)
                {
                    work[len++] = 0x10;
                    if ((byte)crc < 0x10)
                        work[len++] = (byte)(0x10 + (byte)crc);
                    else
                        work[len++] = (byte)crc;
                }
                else
                {
                    work[len++] = (byte)crc;
                }
// 2008.12.13 米沢 以上追加
                work[len++] = 0x03;			//	ETX

                //memcpy(AfterBuf, work, len);
                Buffer.BlockCopy(work, 0, AfterBuf, 0, len);
            }
	        else {
		        len = 0;
	        }

        	return(len);
        }
        #endregion

        #region　FormatRem メソッド

        /// <summary>
        /// STX・ETX変換、STX・CRC・ETX除去
        /// </summary>
        /// <param name="BeforeBuf">変換元バッファ</param>
        /// <param name="BeforeLen">変換元バッファ長</param>
        /// <param name="AfterBuf">変換先バッファ</param>
        /// <returns>変換データ長(バイト)。先頭がSTXでない場合 -1。末尾がETXでない場合 -2。CRCエラーの場合 -3。</returns>
        public static int FormatRem(byte[] BeforeBuf, int BeforeLen, byte[] AfterBuf)
        {
	        int i,len;
	        short crc;
	        byte[] work=new byte[10240];

	        //	BeforeLenチェック
	        if ( BeforeLen<=0 || BeforeLen>=work.Length  ) 
            {
		        return (0);
	        }	
	        //	STXチェック
	        if ( BeforeBuf[0]!=0x02 ) 
            {
		        return (-1);
	        }	
	        //	ETXチェック
	        if ( BeforeBuf[BeforeLen-1]!=0x03 ) 
            {
		        return (-2);
	        }	

            //memset(work,0,work.Length );
            Array.Clear(work, 0, work.Length);
            for (i = 0, len = 0; i < BeforeLen; i++) 
            {
		        if ( BeforeBuf[i]==0x10 && BeforeBuf[i+1]==0x12 ) 
                {
			        work[len] = 0x02;
			        i++;
		        }
		        else if ( BeforeBuf[i]==0x10 && BeforeBuf[i+1]==0x13 ) 
                {
			        work[len] = 0x03;
			        i++;
		        }
		        else if ( BeforeBuf[i]==0x10 && BeforeBuf[i+1]==0x10 ) 
                {
			        work[len] = BeforeBuf[i];
			        i++;
		        }
		        else 
                {
			        work[len] = BeforeBuf[i];
		        }
		        len++;
		        if ( len>=work.Length  )	//	サイズオーバー
                {
			        len = 0;
			        break;
		        }
	        }
	        if ( len>3 ) 
            {
		        //	CRCチェック
		        for ( i=1,crc=0;i<len-2;i++ ) crc+=work[i];
		        if ( (byte)crc!=work[len-2] ) 
                {
			        len = -3;
		        }
		        else 
                {
			        //memcpy(AfterBuf,work+1,len-3);
                    Buffer.BlockCopy(work, 1, AfterBuf, 0, len - 3);
			        len-=3;
		        }
	        }
	        else 
            {
		        len = 0;
	        }

	        return(len);
        }
        #endregion

        #region　ShortToByte メソッド
        /// <summary>
        /// Short型を上位・下位反転してByte型に変換
        /// </summary>
        /// <param name="AfterBuf">
        /// 変換先バッファ</param>
        /// <param name="off">
        /// 変換先バッファオフセット</param>
        /// <param name="data">
        /// 変換元データ</param>
        public static void ShortToByte(byte[] AfterBuf,int off,short data)
        {
            AfterBuf[off] = (byte)(data >> 8);
            AfterBuf[off + 1] = (byte)(data);
        }
        #endregion

        #region　Int32ToByte メソッド
        /// <summary>
        /// Int32型を上位・下位反転してByte型に変換
        /// </summary>
        /// <param name="AfterBuf">
        /// 変換先バッファ</param>
        /// <param name="off">
        /// 変換先バッファオフセット</param>
        /// <param name="data">
        /// 変換元データ</param>
        public static void Int32ToByte(byte[] AfterBuf, int off, int data)
        {
            AfterBuf[off + 3] = (byte)data;
            AfterBuf[off + 2] = (byte)(data >> 8);
            AfterBuf[off + 1] = (byte)(data >> 16);
            AfterBuf[off] = (byte)(data >> 24);
        }
        #endregion

        #region　DateTimeToBcd メソッド
        /// <summary>
        /// DateTime型をBCD型に変換
        /// </summary>
        /// <param name="AfterBuf">
        /// 変換先バッファ</param>
        /// <param name="off">
        /// 変換先バッファオフセット</param>
        /// <param name="timc">
        /// 日付データ</param>
        public static void DateTimeToBcd(byte[] AfterBuf, int off,DateTime timc)
        {
            AfterBuf[off] = BinToBcdToByte(timc.Year / 100);
            AfterBuf[off + 1] = BinToBcdToByte(timc.Year % 100);
            AfterBuf[off + 2] = BinToBcdToByte(timc.Month);
            AfterBuf[off + 3] = BinToBcdToByte(timc.Day);
            AfterBuf[off + 4] = BinToBcdToByte(timc.Hour);
            AfterBuf[off + 5] = BinToBcdToByte(timc.Minute);
            AfterBuf[off + 6] = BinToBcdToByte(timc.Second);
        }
        #endregion

        #region　ByteToShort メソッド
        /// <summary>
        /// Byte型をShort型に上位・下位反転して変換
        /// </summary>
        /// <param name="Buf">
        /// 変換元バッファ</param>
        /// <param name="off">
        /// 変換元バッファオフセット</param>
        /// <returns>
        /// 変換結果</returns>
        public static short ByteToShort(byte[] Buf, int off)
        {
            return ((short)(Buf[off] * 256 + Buf[off+1]));
        }
        #endregion

        #region　ByteToLong メソッド
        /// <summary>
        /// Byte型をLong型に上位・下位反転して変換
        /// </summary>
        /// <param name="Buf">
        /// 変換元バッファ</param>
        /// <param name="off">
        /// 変換元バッファオフセット</param>
        /// <returns>
        /// 変換結果</returns>
        public static long ByteToLong(byte[] Buf, int off)
        {
            long l;
            l = Buf[off] * 256 * 256 * 256;
            l += Buf[off + 1] * 256 * 256;
            l += Buf[off + 2] * 256;
            l += Buf[off + 3];
            return (l);
        }
        #endregion

        #region　BcdToDateTime メソッド
        /// <summary>
        /// BCD型をDateTime型に変換
        /// </summary>
        /// <param name="Buf">
        /// 変換元バッファ</param>
        /// <param name="off">
        /// 変換元バッファオフセット</param>
        /// <returns>
        /// 変換結果</returns>
        public static DateTime BcdToDateTime(byte[] Buf, int off)
        {
            string d, f;
            DateTime dt = DateTime.MinValue;

            try
            {
                if ((Buf[off] != 0) && (Buf[off + 1] != 0) && (Buf[off + 2] != 0) && (Buf[off + 3] != 0))
                {
                    d = string.Format("{0:0000}/", (BcdToBinToByte(Buf[off]) * 100 + BcdToBinToByte(Buf[off + 1])));
                    d += string.Format("{0:00}/", BcdToBinToByte(Buf[off + 2]));
                    d += string.Format("{0:00} ", BcdToBinToByte(Buf[off + 3]));
                    d += string.Format("{0:00}:", BcdToBinToByte(Buf[off + 4]));
                    d += string.Format("{0:00}:", BcdToBinToByte(Buf[off + 5]));
                    d += string.Format("{0:00}", BcdToBinToByte(Buf[off + 6]));
                    f = "yyyy/MM/dd HH:mm:ss";
                    dt = DateTime.ParseExact(d, f, null);
                }
            
            }
            catch (Exception)
            {
                dt = DateTime.MinValue;
            }
            return (dt); 
        }
        #endregion

        #region GetLoggingFolder メソッド

        // <<<<< ADD H.Yonezawa 2009/08/10 ログファイル格納先フォルダを取得する
        /// <summary>
        /// ログフォルダ取得
        /// ※実行ファイル起動フォルダ以下の[DEBUG]フォルダとする
        /// </summary>
        /// <returns></returns>
        public static string GetLoggingFolder()
        {
            string strfolder = AppDomain.CurrentDomain.BaseDirectory;

            try
            {
                if (strfolder.Substring(strfolder.Length).Equals("\\") != true)
                {
                    strfolder += "\\";
                }
                strfolder += "DEBUG";

                if (Directory.Exists(strfolder) == false)
                {
                    Directory.CreateDirectory(strfolder);
                }
            }
            finally
            {
                strfolder += "\\";
            }
            return (strfolder);
        }
        // <<<<< ADD H.Yonezawa 2009/08/10 ログファイル格納先フォルダを取得する

        #endregion

        #region LoggingFolder_Backup メソッド

        // <<<<< ADD Y.Takamura 2009/08/11 ログファイル格納先フォルダのバックアップを作成する
        /// <summary>
        /// ログフォルダバックアップ（”DEBUG_BAK”Delete、”DEBUG”→”DEBUG_BAK”Move）
        /// ※実行ファイル起動フォルダ以下の[DEBUG][DEBUG_BAK]フォルダを対象とする
        /// </summary>
        /// <returns></returns>
        public static int LoggingFolder_Backup()
        {
            int ret = 0;
            int len = 0;
            string debug = "";
            string debug_bak = "";

            try
            {
                debug = GetLoggingFolder();
                len = debug.Length;
            }
            catch
            {
                ret = 1;
            }

            if (len > 0)
            {
                debug_bak = debug.Remove(len - 1, 1);
                debug_bak += "_BAK";

                try
                {
                    // フォルダを削除する（あれば）
                    Directory.Delete(debug_bak, true);
                }
                catch
                {
                    ret = -1;
                }

                try
                {
                    // フォルダを移動する
                    Directory.Move(debug, debug_bak);
                }
                catch
                {
                    ret += -2;
                }
            }
            return (ret);
        }
        #endregion

        #region　TextWriter メソッド
        /// <summary>
        /// テキストファイル出力
        /// </summary>
        /// <param name="FileName">
        /// 出力ファイル名("":年-月-日.log)</param>
        /// <param name="Mode">
        /// 書き込みモード(true:追記,false:新規作成)</param>
        /// <param name="Text">
        /// 出力テキスト("[yy/MM/dd HH:mm:ss] " + Text)</param>
        /// <returns>
        /// 出力結果</returns>
        public static int TextWriter(string FileName, bool Mode, string Text)
        {
            int Ret = 0;

            // CPU使用率調査のためコメントアウト

            //string logFile;

            //if (string.IsNullOrEmpty(FileName) == true)
            //{
            //    // デフォルト:年-月-日.log
            //    logFile = DateTime.Now.ToShortDateString().Replace(@"/", @"-").Replace(@"\", @"-") + ".log";
            //}
            //else
            //{
            //    logFile = FileName;
            //}

            //try
            //{

            //    // 2009.01.21 Add TDC サービス化対応時処理変更
            //    // DefaultTraceListenerオブジェクトを取得
            //    //DefaultTraceListener drl;
            //    //drl = (DefaultTraceListener)Trace.Listeners["Default"];
            //    //drl.LogFileName = AppDomain.CurrentDomain.BaseDirectory + FileName;

            //    // ログ出力
            //    //string Message = DateTime.Now.ToString("[yy/MM/dd HH:mm:ss] ") + Text;
            //    //Trace.WriteLine(Message);

            //    // ログファイルを開いて情報を追加する
            //    WriteLog(Text, AppDomain.CurrentDomain.BaseDirectory + logFile, DateTime.Now);

            //}
            //catch(Exception)
            //{
            //    Ret = -1;
            //}

            return (Ret);

        }
        #endregion

        #region　TextWriter_Org メソッド
        /// <summary>
        /// テキストファイル出力
        /// </summary>
        /// <param name="FileName">
        /// 出力ファイル名("":年-月-日.log)</param>
        /// <param name="Mode">
        /// 書き込みモード(true:追記,false:新規作成)</param>
        /// <param name="Text">
        /// 出力テキスト("[yy/MM/dd HH:mm:ss] " + Text)</param>
        /// <returns>
        /// 出力結果</returns>
        public static int TextWriter_Org(string FileName, bool Mode, string Text)
        {
            int Ret = 0;

//            // CPU使用率調査のためコメントアウト

//            string logFile;

//            if (string.IsNullOrEmpty(FileName) == true)
//            {
//                /// デフォルト:年-月-日.log
//                logFile = DateTime.Now.ToShortDateString().Replace(@"/", @"-").Replace(@"\", @"-") + ".log";
//            }
//            else
//            {
//                logFile = FileName;
//            }

//            try
//            {

//// <<<<< ADD H.Yonezawa 2009/08/10 書き込みモード実装
//                // 書き込みモードが新規作成の場合
//                if (Mode == false)
//                    // 既存ファイル削除
//                    DeleteLog(logFile);
//// >>>>> ADD H.Yonezawa 2009/08/10 書き込みモード実装

//                // 2009.01.21 Add TDC サービス化対応時処理変更
//                /// DefaultTraceListenerオブジェクトを取得
//                //DefaultTraceListener drl;
//                //drl = (DefaultTraceListener)Trace.Listeners["Default"];
//                //drl.LogFileName = AppDomain.CurrentDomain.BaseDirectory + FileName;

//                ///// ログ出力
//                //string Message = DateTime.Now.ToString("[yy/MM/dd HH:mm:ss] ") + Text;
//                //Trace.WriteLine(Message);

//                // ログファイルを開いて情報を追加する
//// <<<<< CHG H.Yonezawa 2009/08/10 ログフォルダを関数にて取得する
//                //WriteLog(Text, AppDomain.CurrentDomain.BaseDirectory + logFile, DateTime.Now);
//                WriteLog(Text, FN3TSlib.GetLoggingFolder() + logFile, DateTime.Now);
//// >>>>> CHG H.Yonezawa 2009/08/10 ログフォルダを関数にて取得する
//            }
//            catch (Exception)
//            {
//                Ret = -1;
//            }

            return (Ret);
        }
        #endregion

        #region　TextWriter_Debug メソッド
        /// <summary>
        /// テキストファイル出力
        /// </summary>
        /// <param name="FileName">
        /// 出力ファイル名("":年-月-日.log)</param>
        /// <param name="Mode">
        /// 書き込みモード(true:追記,false:新規作成)</param>
        /// <param name="Text">
        /// 出力テキスト("[yy/MM/dd HH:mm:ss] " + Text)</param>
        /// <returns>
        /// 出力結果</returns>
        public static int TextWriter_Debug(string FileName, bool Mode, string Text)
        {
            int Ret = 0;

            // CPU使用率調査のためコメントアウト

            string logFile;

            if (string.IsNullOrEmpty(FileName) == true)
            {
                /// デフォルト:年-月-日.log
                logFile = DateTime.Now.ToShortDateString().Replace(@"/", @"-").Replace(@"\", @"-") + ".log";
            }
            else
            {
                logFile = FileName;
            }

            try
            {

                // <<<<< ADD H.Yonezawa 2009/08/10 書き込みモード実装
                // 書き込みモードが新規作成の場合
                if (Mode == false)
                    // 既存ファイル削除
                    DeleteLog(logFile);
                // >>>>> ADD H.Yonezawa 2009/08/10 書き込みモード実装

                // 2009.01.21 Add TDC サービス化対応時処理変更
                /// DefaultTraceListenerオブジェクトを取得
                //DefaultTraceListener drl;
                //drl = (DefaultTraceListener)Trace.Listeners["Default"];
                //drl.LogFileName = AppDomain.CurrentDomain.BaseDirectory + FileName;

                ///// ログ出力
                //string Message = DateTime.Now.ToString("[yy/MM/dd HH:mm:ss] ") + Text;
                //Trace.WriteLine(Message);

                // ログファイルを開いて情報を追加する
                // <<<<< CHG H.Yonezawa 2009/08/10 ログフォルダを関数にて取得する
                //WriteLog(Text, AppDomain.CurrentDomain.BaseDirectory + logFile, DateTime.Now);
                WriteLog(Text, FN3TSlib.GetLoggingFolder() + logFile, DateTime.Now);
                // >>>>> CHG H.Yonezawa 2009/08/10 ログフォルダを関数にて取得する
            }
            catch (Exception)
            {
                Ret = -1;
            }

            return (Ret);
        }
        #endregion

        /// <summary>
        /// テキストファイルに書き出す
        /// </summary>
        /// <param name="Text">メッセージ</param>
        /// <param name="logFile">ファイル名</param>
        /// <param name="start">処理開始時刻</param>
        private static void WriteLog(string Text, string logFile, DateTime start)
        {

            try
            {

                using (System.IO.StreamWriter w = File.AppendText(logFile))
                {
                    string Message = DateTime.Now.ToString("[yy/MM/dd HH:mm:ss.fff] ") + Text;
                    //FN3TSlib.Log(Message, w);
                    w.WriteLine(Message);
                    w.Flush();
                    w.Close();
                }

            }
            catch (System.IO.IOException ex)
            {

                if (ex.Message.Substring(0, 26).Equals("別のプロセスで使用されているため、プロセスはファイル")
                    && (DateTime.Now < start.AddSeconds(2)))
                {

                    // WriteLogメソッドを再帰呼び出しする
                    WriteLog(Text, logFile, start);
                    
                }
                else
                {
                    throw;
                }            
            
            }
            catch (Exception)
            {
                throw;
            }
        
        }

        /// <summary>
        /// テキストファイルにログメッセージを書き出す
        /// </summary>
        /// <param name="logMessage">メッセージ</param>
        /// <param name="w">TextWriterインスタンス</param>
        private static void Log(String logMessage, System.IO.TextWriter w)
        {
            w.WriteLine(logMessage);
            w.Flush();
        }

        #region　DataWriter メソッド
        /// <summary>
        /// データファイル出力
        /// （HexDump:"00-00-...."）
        /// </summary>
        /// <param name="FileName">
        /// 出力ファイル名("":年-月-日.log)</param>
        /// <param name="Mode">
        /// 書き込みモード(true:追記,false:新規作成)</param>
        /// <param name="Data">
        /// 出力データ("[yy/MM/dd HH:mm:ss] " + Data)</param>
        /// <param name="len">
        /// 出力データ長</param>
        /// <returns>
        /// 出力結果</returns>
        public static int DataWriter(string FileName, bool Mode, byte[] Data, int len)
        {
            int Ret = 0;

            //// CPU使用率調査のためコメントアウト

            //string logFile;
            //string HexDump;

            //if (string.IsNullOrEmpty(FileName) == true)
            //{
            //    /// デフォルト:年-月-日.log
            //    logFile = DateTime.Now.ToShortDateString().Replace(@"/", @"-").Replace(@"\", @"-") + ".log";
            //}
            //else
            //{
            //    logFile = FileName;
            //}

            //try
            //{
            //    Encoding sjisEnc = Encoding.GetEncoding("Shift_JIS");
            //    StreamWriter writer = new StreamWriter(logFile, Mode, sjisEnc);
            //    DateTime dt = DateTime.Now;
            //    byte[] work = new byte[len];
            //    Buffer.BlockCopy(Data, 0, work, 0, len);
            //    HexDump = BitConverter.ToString(work);
            //    writer.WriteLine(dt.ToString("[yy/MM/dd HH:mm:ss] ") + HexDump);
            //    writer.Close();
            //}
            //catch
            //{
            //    Ret = -1;
            //}

            return (Ret);
        }
        #endregion

        #region　DataWriter_Org メソッド
        /// <summary>
        /// データファイル出力
        /// （HexDump:"00-00-...."）
        /// </summary>
        /// <param name="FileName">
        /// 出力ファイル名("":年-月-日.log)</param>
        /// <param name="Mode">
        /// 書き込みモード(true:追記,false:新規作成)</param>
        /// <param name="Data">
        /// 出力データ("[yy/MM/dd HH:mm:ss] " + Data)</param>
        /// <param name="len">
        /// 出力データ長</param>
        /// <returns>
        /// 出力結果</returns>
        public static int DataWriter_Org(string FileName, bool Mode, byte[] Data, int len)
        {
            int Ret = 0;

//            // CPU使用率調査のためコメントアウト

//            string logFile;
//            string HexDump;

//            if (string.IsNullOrEmpty(FileName) == true)
//            {
//                /// デフォルト:年-月-日.log
//                logFile = DateTime.Now.ToShortDateString().Replace(@"/", @"-").Replace(@"\", @"-") + ".log";
//            }
//            else
//            {
//                logFile = FileName;
//            }

//            try
//            {
//                Encoding sjisEnc = Encoding.GetEncoding("Shift_JIS");
//// <<<<< CHG H.Yonezawa 2009/08/10 ログフォルダを関数にて取得する
//                //StreamWriter writer = new StreamWriter(logFile, Mode, sjisEnc);
//                StreamWriter writer = new StreamWriter(FN3TSlib.GetLoggingFolder() + logFile, Mode, sjisEnc);
//// >>>>> CHG H.Yonezawa 2009/08/10 ログフォルダを関数にて取得する
//                DateTime dt = DateTime.Now;
//                byte[] work = new byte[len];
//                Buffer.BlockCopy(Data, 0, work, 0, len);
//                HexDump = BitConverter.ToString(work);
//                //writer.WriteLine(dt.ToString("[yy/MM/dd HH:mm:ss] ") + HexDump);
//                writer.WriteLine(dt.ToString("[yy/MM/dd HH:mm:ss.fff] ") + HexDump);
//                writer.Close();
//            }
//            catch
//            {
//                Ret = -1;
//            }

            return (Ret);
        }
        #endregion

        #region　GetMonitorDataString メソッド

        /// <summary>
        /// 指定された書式のモニタデータ文字列を作成する
        /// ※short型のみ対応
        /// </summary>
        /// <param name="cData">モニタデータ</param>
        /// <param name="intOffset">モニタデータ取得開始位置</param>
        /// <param name="intDataType">データ型[0:整数/1：実数/2：時刻/3：日付/4：文字列]</param>
        /// <param name="intDecimalFigure">小数点以下桁数</param>
        /// <returns>空：変換失敗、無効データ/else：モニタデータ文字列</returns>
        public static string GetXmlDataString(byte[] cData, int intOffset, int intDataType, int intDecimalFigure)
        {
            string strret = string.Empty;

            try
            {
                // モニタデータのShort化
                short sintdata = FN3TSlib.ByteToShort(cData, intOffset);

                // データ値が0x8000以外の場合
                if (sintdata.Equals(-32768) == false)
                {
                    // 表示形式作成
                    string strfmt = "{0";
                    switch (intDataType)
                    {
                        case 0: // 整数
                        case 1: // 実数
                            strfmt += ":0";
                            // 小数点以下桁数が指定されている場合
                            if (0 < intDecimalFigure)
                            {
                                strfmt += "'.'";
                                strfmt += new string('0', intDecimalFigure);
                            }
                            break;

                        case 2: // 時刻
                            strfmt += ":00':'00";
                            int inthour = sintdata / 60;
                            int intmin = sintdata % 60;
                            if ( 23 < inthour )
                            {
                                inthour = 23;
                                intmin = 59;
                            }
                            sintdata = (short)(inthour * 100 + intmin);
                            break;

                        case 3: // 日付
                            strfmt += ":00'/'00";
                            break;

                        case 4: // 文字列
                            break;

                        case 5: // 整数(負の場合は記録しない)
                        case 6: // 実数(負の場合は記録しない)
                            if (sintdata < 0)
                                return (string.Empty);

                            strfmt += ":0";
                            // 小数点以下桁数が指定されている場合
                            if (0 < intDecimalFigure)
                            {
                                strfmt += "'.'";
                                strfmt += new string('0', intDecimalFigure);
                            }
                            break;
                    }
                    strfmt += "}";

                    // 数値→文字列化
                    strret = string.Format(strfmt, sintdata);

                    // 日付の場合
                    if (intDataType == 3)
                    {
                        DateTime a;
                        a = DateTime.Parse( strret );
                        if (a.Equals(DateTime.MinValue) == true)
                            strret = string.Empty;
                    }
                    //                    Console.WriteLine("Data:{0} Type:{1} DecimalFigure:{2} Format:{3} String:{4}", sintData, intDataType, intDecimalFigure, strfmt, strret);
                }
            }
            catch (Exception e)
            {
                Console.WriteLine(e.Source);
                Console.WriteLine(e.Message);

                strret = string.Empty;
            }

            return (strret);
        }

        #endregion

        #region　TextMarge メソッド

        // <<<<< ADD H.Yonezawa 2009/08/10 SourceFileNameの内容全てをDestFileNameへ追記する
        /// <summary>
        /// SourceFileNameの内容全てをDestFileNameへ追記する
        /// </summary>
        /// <param name="SourceFileName">コピー元ファイル名</param>
        /// <param name="DestFileName">コピー先ファイル名</param>
        public static void TextAppendMarge(string SourceFileName, string DestFileName)
        {
            try
            {
                // SourceFileNameの内容を全て読み込み、DestFileNameへ追記する
                System.IO.File.AppendAllText( FN3TSlib.GetLoggingFolder() + DestFileName, System.IO.File.ReadAllText(FN3TSlib.GetLoggingFolder() + SourceFileName));
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Source);
                Console.WriteLine(ex.Message);
            }
        }
        // <<<<< ADD H.Yonezawa 2009/08/10 SourceFileNameの内容全てをDestFileNameの末尾にコピー

        #endregion

        #region　DeleteLog メソッド

        // <<<<< ADD H.Yonezawa 2009/08/10 指定ログファイルの削除を行う
        /// <summary>
        /// 指定ログファイルの削除を行う
        /// </summary>
        /// <param name="LogFileName">削除するログファイル名</param>
        public static void DeleteLog(string LogFileName)
        {
            try
            {
                // 指定ログファイルの削除を行う
                File.Delete(FN3TSlib.GetLoggingFolder() + LogFileName);
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Source);
                Console.WriteLine(ex.Message);
            }
        }
        // <<<<< ADD H.Yonezawa 2009/08/10 SourceFileNameの内容全てをDestFileNameの末尾にコピー

        #endregion

    }
}
