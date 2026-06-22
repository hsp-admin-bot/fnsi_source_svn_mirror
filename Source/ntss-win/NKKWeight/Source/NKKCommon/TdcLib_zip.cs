//----------------------------------------------------------------------------------------------------
//  共通ライブラリ:Ionic.Zip関連
//----------------------------------------------------------------------------------------------------
using System;
using System.Text;
using System.Data;
using System.Xml;
using System.Globalization;
using System.Collections.Generic;

#if DEBUG
    using System.Diagnostics;
#endif

//----------------------------------------------------------------------------------------------------
//  TdcLib名前空間
//----------------------------------------------------------------------------------------------------
namespace TdcLib
{
    //----------------------------------------------------------------------------------------------------
    /// <summary>
    /// 共通ライブラリクラス
    /// </summary>
    //----------------------------------------------------------------------------------------------------
    public static partial class TdcLib
    {

#region パブリックメソッド

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 指定ファイルをZip圧縮する
        /// ※同名ファイルが既に含まれている場合は上書きされる
        /// </summary>
        /// <param name="Enc">エンコーディングオブジェクト</param>
        /// <param name="strZipFileName">Zipファイル名[フルパス]</param>
        /// <param name="strFileName">圧縮対象ファイル名[フルパス]</param>
        /// <returns>true：成功/false：失敗</returns>
        //----------------------------------------------------------------------------------------------------
        public static bool CompressZipFile(System.Text.Encoding Enc, String strZipFileName, String strFileName)
        {
            return (TdcLib.CompressZipFile(Enc, strZipFileName, strFileName, String.Empty, String.Empty));
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 指定ファイルをZip圧縮する
        /// ※同名ファイルが既に含まれている場合は上書きされる
        /// </summary>
        /// <param name="Enc">エンコーディングオブジェクト</param>
        /// <param name="strZipFileName">Zipファイル名[フルパス]</param>
        /// <param name="strFileName">圧縮対象ファイル名[フルパス]</param>
        /// <param name="strArchveFolder">階層情報</param>
        /// <returns>true：成功/false：失敗</returns>
        //----------------------------------------------------------------------------------------------------
        public static bool CompressZipFile(System.Text.Encoding Enc, String strZipFileName, String strFileName, String strArchveFolder)
        {
            return (TdcLib.CompressZipFile(Enc, strZipFileName, strFileName, strArchveFolder, String.Empty));
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 指定ファイルをZip圧縮する
        /// ※同名ファイルが既に含まれている場合は上書きされる
        /// </summary>
        /// <param name="Enc">エンコーディングオブジェクト</param>
        /// <param name="strZipFileName">Zipファイル名[フルパス]</param>
        /// <param name="strFileName">圧縮対象ファイル名[フルパス]</param>
        /// <param name="strArchveFolder">階層情報</param>
        /// <param name="strPassword">圧縮時のパスワード</param>
        /// <returns>true：成功/false：失敗</returns>
        //----------------------------------------------------------------------------------------------------
        public static bool CompressZipFile(System.Text.Encoding Enc,String strZipFileName, String strFileName, String strArchveFolder, String strPassword)
        {
            return TdcLib.CompressZipFile(Enc, strZipFileName, strFileName, strArchveFolder, strPassword, 0);
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 指定ファイルをZip圧縮する
        /// ※同名ファイルが既に含まれている場合は上書きされる
        /// </summary>
        /// <param name="Enc">エンコーディングオブジェクト</param>
        /// <param name="strZipFileName">Zipファイル名[フルパス]</param>
        /// <param name="strFileName">圧縮対象ファイル名[フルパス]</param>
        /// <param name="strArchveFolder">階層情報</param>
        /// <param name="strPassword">圧縮時のパスワード</param>
        /// <param name="maxMBSize">最大MBサイズ(超えた場合は分割)</param>
        /// <returns>true：成功/false：失敗</returns>
        //----------------------------------------------------------------------------------------------------
        public static bool CompressZipFile(System.Text.Encoding Enc, String strZipFileName, String strFileName, String strArchveFolder, String strPassword, UInt16 nMaxMBSize)
        {
            bool bret = false;
            Ionic.Zip.ZipFile zip = null;

            try
            {
                // 圧縮対象ファイルの有無判定
                if (System.IO.File.Exists(strFileName) == true)
                {
                    // Zip圧縮ファイルの有無判定
                    if (System.IO.File.Exists(strZipFileName) == true)
                    {
                        // ZIPクラスを既存Zipファイルを読み込みインスタンス化
                        zip = new Ionic.Zip.ZipFile(strZipFileName, Enc);
                    }
                    else
                    {
                        // ZIPクラスを新規インスタンス化
                        zip = new Ionic.Zip.ZipFile(Enc);
                    }

                    // 圧縮レベルを設定
                    zip.CompressionLevel = Ionic.Zlib.CompressionLevel.BestCompression;

                    // パスワード設定
                    if (String.IsNullOrEmpty(strPassword) == false)
                    {
                        zip.Password = strPassword;
                    }

                    // ファイルを追加
                    if (String.IsNullOrEmpty(strArchveFolder) == false)
                    {
                        // 階層情報なし
                        zip.AddFile(strFileName, "");
                    }
                    else
                    {
                        // 階層情報あり
                        zip.AddFile(strFileName, strArchveFolder);
                    }

                    // 最大サイズ
                    if (0 < nMaxMBSize)
                    {
                        zip.MaxOutputSegmentSize = nMaxMBSize * 1024 * 1024;
                    }

                    // ディレクトリを追加する場合
                    // zip.AddDirectory(@"C:\追加したいフォルダ");

                    // ZIPファイルを保存
                    zip.Save(strZipFileName);

                    bret = true;
                }
            }
            catch (Exception ex)
            {
                TdcLib.Error = ex;
            }
            finally
            {
                if (zip != null)
                {
                    zip.Dispose();
                }
            }

            return (bret);
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 指定ファイルをZip圧縮する
        /// ※同名ファイルが既に含まれている場合は上書きされる
        /// </summary>
        /// <param name="Enc">エンコーディングオブジェクト</param>
        /// <param name="strZipFileName">Zipファイル名[フルパス]</param>
        /// <param name="strFileName">圧縮対象ファイル名[フルパス]</param>
        /// <param name="strArchveFolder">階層情報</param>
        /// <param name="strPassword">圧縮時のパスワード</param>
        /// <returns>true：成功/false：失敗</returns>
        //----------------------------------------------------------------------------------------------------
        public static bool CompressZipFiles(System.Text.Encoding Enc, String strZipFileName, String[] strFileName, String strArchveFolder, String strPassword)
        {
            return TdcLib.CompressZipFiles(Enc, strZipFileName, strFileName, strArchveFolder, strPassword, 0);
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 指定ファイルをZip圧縮する
        /// ※同名ファイルが既に含まれている場合は上書きされる
        /// </summary>
        /// <param name="Enc">エンコーディングオブジェクト</param>
        /// <param name="strZipFileName">Zipファイル名[フルパス]</param>
        /// <param name="strFileName">圧縮対象ファイル名[フルパス]</param>
        /// <param name="strArchveFolder">階層情報</param>
        /// <param name="strPassword">圧縮時のパスワード</param>
        /// <param name="maxMBSize">最大MBサイズ(超えた場合は分割)</param>
        /// <returns>true：成功/false：失敗</returns>
        //----------------------------------------------------------------------------------------------------
        public static bool CompressZipFiles(System.Text.Encoding Enc, String strZipFileName, String[] strFileName, String strArchveFolder, String strPassword, UInt16 nMaxMBSize)
        {
            bool bret = false;
            Ionic.Zip.ZipFile zip = null;

            try
            {
                for(int i=0; i<strFileName.Length; i++)
                {
                    // 圧縮対象ファイルの有無判定
                    if (System.IO.File.Exists(strFileName[i]) == true)
                    {
                        // Zip圧縮ファイルの有無判定
                        if (System.IO.File.Exists(strZipFileName) == true)
                        {
                            // ZIPクラスを既存Zipファイルを読み込みインスタンス化
                            zip = new Ionic.Zip.ZipFile(strZipFileName, Enc);
                        }
                        else
                        {
                            // ZIPクラスを新規インスタンス化
                            zip = new Ionic.Zip.ZipFile(Enc);
                        }

                        // 圧縮レベルを設定
                        zip.CompressionLevel = Ionic.Zlib.CompressionLevel.BestCompression;

                        // パスワード設定
                        if (String.IsNullOrEmpty(strPassword) == false)
                        {
                            zip.Password = strPassword;
                        }

                        // ファイルを追加
                        if (String.IsNullOrEmpty(strArchveFolder) == false)
                        {
                            // 階層情報なし
                            zip.AddFile(strFileName[i], "");
                        }
                        else
                        {
                            // 階層情報あり
                            zip.AddFile(strFileName[i], strArchveFolder);
                        }

                        // 最大サイズ
                        if (0 < nMaxMBSize)
                        {
                            zip.MaxOutputSegmentSize = nMaxMBSize * 1024 * 1024;
                        }

                        // ディレクトリを追加する場合
                        // zip.AddDirectory(@"C:\追加したいフォルダ");

                        // ZIPファイルを保存
                        zip.Save(strZipFileName);

                        bret = true;
                    }
                }
                
            }
            catch (Exception ex)
            {
                TdcLib.Error = ex;
            }
            finally
            {
                if (zip != null)
                {
                    zip.Dispose();
                }
            }

            return (bret);
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 指定Zipファイルを解凍する
        /// ※解凍先フォルダに同名ファイルが既に含まれている場合は上書きされる
        /// </summary>
        /// <param name="Enc">エンコーディングオブジェクト</param>
        /// <param name="strZipFileName">解凍Zipファイル名[フルパス]</param>
        /// <param name="strFolder">解凍先フォルダ</param>
        /// <returns>true：成功/false：失敗</returns>
        //----------------------------------------------------------------------------------------------------
        public static bool UnCompressZipFile(System.Text.Encoding Enc, String strZipFileName, String strFolder)
        {
            return (TdcLib.UnCompressZipFile(Enc, strZipFileName, strFolder, String.Empty, String.Empty));
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 指定Zipファイルを解凍する
        /// ※解凍先フォルダに同名ファイルが既に含まれている場合は上書きされる
        /// </summary>
        /// <param name="Enc">エンコーディングオブジェクト</param>
        /// <param name="strZipFileName">解凍Zipファイル名[フルパス]</param>
        /// <param name="strFolder">解凍先フォルダ</param>
        /// <param name="strFileName">解凍するファイル名</param>
        /// <returns>true：成功/false：失敗</returns>
        //----------------------------------------------------------------------------------------------------
        public static bool UnCompressZipFile(System.Text.Encoding Enc, String strZipFileName, String strFolder, String strFileName)
        {
            return (TdcLib.UnCompressZipFile(Enc, strZipFileName, strFolder, strFileName, String.Empty));
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 指定Zipファイルを解凍する
        /// ※解凍先フォルダに同名ファイルが既に含まれている場合は上書きされる
        /// </summary>
        /// <param name="Enc">エンコーディングオブジェクト</param>
        /// <param name="strZipFileName">解凍Zipファイル名[フルパス]</param>
        /// <param name="strFolder">解凍先フォルダ</param>
        /// <param name="strFileName">解凍するファイル名</param>
        /// <param name="strPassword">圧縮時のパスワード</param>
        /// <returns>true：成功/false：失敗</returns>
        //----------------------------------------------------------------------------------------------------
        public static bool UnCompressZipFile(System.Text.Encoding Enc, String strZipFileName, String strFolder, String strFileName, String strPassword)
        {
            bool bret = false;

            try
            {
                // 解凍対象Zipファイルの有無判定
                if (System.IO.File.Exists(strZipFileName) == true)
                {
                    // ZIPクラスをインスタンス化
                    using (Ionic.Zip.ZipFile zip = new Ionic.Zip.ZipFile(strZipFileName, Enc))
                    {
                        // 同名がある場合は上書きを設定
                        zip.ExtractExistingFile = Ionic.Zip.ExtractExistingFileAction.OverwriteSilently;

                        // パスワード設定
                        if (String.IsNullOrEmpty(strPassword) == false)
                        {
                            zip.Password = strPassword;
                        }

                        // 解凍するファイル名が指定されているかどうか
                        if (String.IsNullOrEmpty(strFileName) == true)
                        {
                            // 未指定

                            // ZIPファイルを全て解凍
                            zip.ExtractAll(strFolder);

                            bret = true;
                        }
                        else
                        {
                            // 指定

                            // 指定ファイルのみ解凍
                            Ionic.Zip.ZipEntry entry = zip[ strFileName];
                            if (entry != null)
                            {
                                entry.Extract(strFolder);

                                bret = true;
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                TdcLib.Error = ex;
            }

            return (bret);
        }
        //----------------------------------------------------------------------------------------------------

#endregion

    }
    //----------------------------------------------------------------------------------------------------
}
