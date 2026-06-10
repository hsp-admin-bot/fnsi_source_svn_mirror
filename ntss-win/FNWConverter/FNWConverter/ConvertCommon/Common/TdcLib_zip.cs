//----------------------------------------------------------------------------------------------------
//  共通ライブラリ:Ionic.Zip関連 → SharpZipLib版
//  #12451 コンバートツールで使用しているDotNetZipの脆弱性対策(CVE-2024-48510)
//----------------------------------------------------------------------------------------------------
using System;
using System.IO;
using ConvertCommon;
using ICSharpCode.SharpZipLib.Zip;

#if DEBUG
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
        public static bool CompressZipFile(System.Text.Encoding Enc, String strZipFileName, String strFileName, String strArchveFolder, String strPassword)
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
        /// <param name="maxMBSize">最大MBサイズ(超えた場合は分割)※SharpZipLib版ではサポートしない</param>
        /// <returns>true：成功/false：失敗</returns>
        //----------------------------------------------------------------------------------------------------
        public static bool CompressZipFile(System.Text.Encoding Enc, String strZipFileName, String strFileName, String strArchveFolder, String strPassword, UInt16 nMaxMBSize)
        {
            bool bret = false;
            ZipOutputStream zip = null;

            try
            {
                // 圧縮対象ファイルの存在確認
                if (System.IO.File.Exists(strFileName) == true)
                {
                    // SharpZipLibによるZIPストリーム生成（新規作成）
                    zip = new ZipOutputStream(File.Create(strZipFileName));

                    // エンコーディングを設定
                    ZipStrings.CodePage = Enc.CodePage;

                    // 圧縮レベル設定（DotNetZipのBestCompression相当）
                    zip.SetLevel(9);

                    // パスワード設定（指定がある場合のみ）
                    if (String.IsNullOrEmpty(strPassword) == false)
                    {
                        zip.Password = strPassword;
                    }

                    // ZIP内エントリ名生成
                    string entryName;
                    if (String.IsNullOrEmpty(strArchveFolder) == false)
                    {
                        // ZIP内にフォルダ階層を付与する場合
                        entryName = Path.Combine(strArchveFolder, Path.GetFileName(strFileName));
                    }
                    else
                    {
                        // フォルダ階層なし（ファイル名のみ）
                        entryName = Path.GetFileName(strFileName);
                    }

                    // ZIP仕様に合わせて区切り文字を「/」へ統一
                    entryName = entryName.Replace("\\", "/");

                    // ZIPエントリ生成
                    ZipEntry entry = new ZipEntry(entryName);

                    // 元ファイルの最終更新日時を設定
                    entry.DateTime = File.GetLastWriteTime(strFileName);

                    // エントリ開始
                    zip.PutNextEntry(entry);

                    // ファイル内容を書き込み
                    using (FileStream fs = File.OpenRead(strFileName))
                    {
                        fs.CopyTo(zip);
                    }

                    // エントリ終了
                    zip.CloseEntry();

                    // 分割ZIP（SharpZipLibでは未対応）
                    // zip.MaxOutputSegmentSize = nMaxMBSize * 1024 * 1024;

                    // ZIP出力完了処理
                    zip.Finish();

                    bret = true;
                }
            }
            catch (Exception ex)
            {
                // 例外発生時はfalseを返却（既存仕様踏襲）
                //TdcLib.Error = ex;
                ConvertBase.WriteErrorLog("CompressZipFile:{0}", ex.Message);
            }
            finally
            {
                if (zip != null)
                {
                    zip.Dispose();
                    zip = null;
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
        /// <param name="maxMBSize">最大MBサイズ(超えた場合は分割)※SharpZipLib版ではサポートしない</param>
        /// <returns>true：成功/false：失敗</returns>
        //----------------------------------------------------------------------------------------------------
        public static bool CompressZipFiles(System.Text.Encoding Enc, String strZipFileName, String[] strFileName, String strArchveFolder, String strPassword, UInt16 nMaxMBSize)
        {
            bool bret = false;
            ZipOutputStream zip = null;

            try
            {
                // 圧縮対象ファイルが1件でも存在するか事前チェック
                bool hasValidFile = false;
                for (int i = 0; i < strFileName.Length; i++)
                {
                    if (System.IO.File.Exists(strFileName[i]) == true)
                    {
                        hasValidFile = true;
                        break;
                    }
                }

                // 1件も存在しない場合はZIPファイルを作成せず終了（既存仕様踏襲）
                if (!hasValidFile)
                {
                    return false;
                }

                // SharpZipLibによるZIP圧縮ストリーム生成（新規作成）
                zip = new ZipOutputStream(File.Create(strZipFileName));

                // エンコーディングを設定
                ZipStrings.CodePage = Enc.CodePage;

                // 圧縮レベル設定（DotNetZipのBestCompression相当）
                zip.SetLevel(9);

                // パスワード設定（指定がある場合のみ）
                if (String.IsNullOrEmpty(strPassword) == false)
                {
                    zip.Password = strPassword;
                }

                for (int i = 0; i < strFileName.Length; i++)
                {
                    // 圧縮対象ファイルの存在確認
                    if (System.IO.File.Exists(strFileName[i]) == true)
                    {
                        // ZIP内エントリ名生成
                        string entryName;

                        if (String.IsNullOrEmpty(strArchveFolder) == false)
                        {
                            // ZIP内にフォルダ階層を付与する場合
                            entryName = Path.Combine(strArchveFolder, Path.GetFileName(strFileName[i]));
                        }
                        else
                        {
                            // フォルダ階層なし（ファイル名のみ）
                            entryName = Path.GetFileName(strFileName[i]);
                        }

                        // ZIP仕様に合わせて区切り文字を「/」へ統一
                        entryName = entryName.Replace("\\", "/");

                        // ZIPエントリ生成
                        ZipEntry entry = new ZipEntry(entryName);

                        // 元ファイルの最終更新日時を設定
                        entry.DateTime = File.GetLastWriteTime(strFileName[i]);

                        // エントリ開始
                        zip.PutNextEntry(entry);

                        // ファイル内容を書き込み
                        using (FileStream fs = File.OpenRead(strFileName[i]))
                        {
                            fs.CopyTo(zip);
                        }

                        // エントリ終了
                        zip.CloseEntry();
                    }
                }

                // 分割ZIP（未対応）
                // zip.MaxOutputSegmentSize = nMaxMBSize * 1024 * 1024;

                // ZIP出力完了処理
                zip.Finish();

                bret = true;
            }
            catch (Exception ex)
            {
                // 例外発生時はfalseを返却（既存仕様踏襲）
                //TdcLib.Error = ex;
                ConvertBase.WriteErrorLog("CompressZipFiles:{0}", ex.Message);
            }
            finally
            {
                if (zip != null)
                {
                    zip.Dispose();
                    zip = null;
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
                    // ZIPクラスをインスタンス化（読み取り専用でオープン）
                    using (ZipFile zip = new ZipFile(File.OpenRead(strZipFileName)))
                    {
                        // エンコーディング設定
                        ZipStrings.CodePage = Enc.CodePage;

                        // ※SharpZipLibは既定で同名ファイルを上書きする（File.Create使用）

                        // パスワード設定（指定がある場合のみ）
                        if (String.IsNullOrEmpty(strPassword) == false)
                        {
                            zip.Password = strPassword;
                        }

                        // 解凍成功フラグ（DotNetZip版の挙動と等価にするため）
                        bool extracted = false;

                        // ZIP内エントリを順次処理
                        foreach (ZipEntry entry in zip)
                        {
                            // ファイルのみ対象（ディレクトリエントリはスキップ）
                            if (!entry.IsFile)
                                continue;

                            // 解凍対象ファイル名が指定されている場合は一致するもののみ処理
                            if (!String.IsNullOrEmpty(strFileName) &&
                                entry.Name != strFileName)
                                continue;

                            // 出力先フルパス生成（ZIP内の相対パス構造を維持）
                            string fullOutputPath = Path.GetFullPath(Path.Combine(strFolder, entry.Name));
                            string fullBasePath = Path.GetFullPath(strFolder);

                            // Zip Slip対策：解凍先フォルダ外への書き込みを禁止
                            if (!fullOutputPath.StartsWith(fullBasePath, StringComparison.OrdinalIgnoreCase))
                            {
                                throw new Exception("不正なパスが含まれています。");
                            }
                            // 出力先
                            string outPath = fullOutputPath;

                            // 出力先ディレクトリが存在しない場合は作成
                            Directory.CreateDirectory(Path.GetDirectoryName(outPath));

                            // ZIPエントリの内容をファイルへ書き出し
                            using (Stream inputStream = zip.GetInputStream(entry))
                            using (FileStream outputStream = File.Create(outPath))
                            {
                                inputStream.CopyTo(outputStream);
                            }

                            // 少なくとも1件解凍成功
                            extracted = true;

                            // 特定ファイル指定時は1件処理後に終了
                            if (!String.IsNullOrEmpty(strFileName))
                                break;
                        }

                        // 解凍成功有無を戻り値へ設定
                        bret = extracted;
                    }
                }
            }
            catch (Exception ex)
            {
                // 例外発生時はfalseを返却（既存仕様踏襲）
                //TdcLib.Error = ex;
               ConvertBase.WriteErrorLog("UnCompressZipFile:{0}", ex.Message);
            }

            return (bret);
        }
        //----------------------------------------------------------------------------------------------------

#endregion

    }
    //----------------------------------------------------------------------------------------------------
}
