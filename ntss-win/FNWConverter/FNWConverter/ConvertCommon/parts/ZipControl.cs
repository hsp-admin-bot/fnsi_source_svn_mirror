//----------------------------------------------------------------------------------------------------
//  #12451 コンバートツールで使用しているDotNetZipの脆弱性対策(CVE-2024-48510)
//  Ionic.Zip → SharpZipLib切替版
//----------------------------------------------------------------------------------------------------
using System.IO;
using ICSharpCode.SharpZipLib.Zip;

namespace ConvertCommon.parts
{
    public class ZipControl
    {
        // mod settingファイルより、選定されていないアップロードファイル判定を追加する  楊 start
        //public void compress(string zipPath, string folderPath, string password)
        public void compress(string zipPath, string folderPath, string password, int maxFileSize)
        // mod settingファイルより、選定されていないアップロードファイル判定を追加する  楊 end
        {
            ZipOutputStream zip = null;

            try
            {
                // 対象フォルダ存在確認
                if (!Directory.Exists(folderPath))
                {
                    return;
                }

                // フォルダ名取得（ZIP内に最上位フォルダとして含めるため）
                string baseFolderName = Path.GetFileName(
                    folderPath.TrimEnd(Path.DirectorySeparatorChar)
                );

                // 圧縮対象ファイル取得（再帰的に全ファイル）
                string[] files = Directory.GetFiles(folderPath, "*", SearchOption.AllDirectories);

                // 1件も存在しない場合はZIPを作成しない（既存仕様踏襲）
                if (files.Length == 0)
                {
                    return;
                }

                // ZIP出力ストリーム生成（新規作成）
                zip = new ZipOutputStream(File.Create(zipPath));

                // エンコーディングを設定
                ZipStrings.CodePage = 65001;   // UTF-8

                // 圧縮レベル設定（DotNetZipのBestCompression相当）
                zip.SetLevel(9);

                // ZIP64設定（AsNecessary相当）
                //zip.UseZip64 = UseZip64.Dynamic;
                zip.UseZip64 = UseZip64.Off;

                // パスワード設定（指定がある場合のみ）
                if (!string.IsNullOrEmpty(password))
                {
                    zip.Password = password;
                }

                // 追加成功有無フラグ
                // DotNetZipのZipErrorAction.Skipと等価にするため、
                // 1件でも成功した場合のみZIPを有効とする
                bool added = false;

                foreach (string filePath in files)
                {
                    try
                    {
                        // フォルダ基準の相対パス生成
                        string relativePath = filePath
                            .Substring(folderPath.Length)
                            .TrimStart(Path.DirectorySeparatorChar);

                        // ZIP内に最上位フォルダ名を付与する
                        relativePath = baseFolderName + "/" + relativePath;

                        // ZIP仕様に合わせて区切り文字を「/」へ統一
                        relativePath = relativePath.Replace("\\", "/");

                        // エントリ生成
                        ZipEntry entry = new ZipEntry(relativePath);

                        // 更新日時設定
                        entry.DateTime = File.GetLastWriteTime(filePath);

                        // AES256暗号化設定（パスワード指定時のみ）
                        if (!string.IsNullOrEmpty(password))
                        {
                            entry.AESKeySize = 256;
                        }

                        // エントリ開始
                        zip.PutNextEntry(entry);

                        // ファイル内容書き込み
                        using (FileStream fs = File.OpenRead(filePath))
                        {
                            fs.CopyTo(zip);
                        }

                        // エントリ終了
                        zip.CloseEntry();

                        // 1件成功
                        added = true;
                    }
                    catch
                    {
                        // --------------------------------------------------
                        // DotNetZipのZipErrorAction.Skip相当処理
                        // 個別ファイル圧縮失敗時はスキップし処理継続
                        // ZIP構造を破壊しないため、
                        // PutNextEntry～CloseEntryは同一try内で実施
                        // --------------------------------------------------
                    }
                }

                // 1件以上成功した場合のみZIP確定
                if (added)
                {
                    zip.Finish();
                }
                else
                {
                    // 1件も成功しなかった場合はZIPファイル削除
                    zip.Close();
                    File.Delete(zipPath);
                }
            }
            finally
            {
                if (zip != null)
                {
                    zip.Dispose();
                    zip = null;
                }
            }
        }
    }
}
