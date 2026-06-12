using System.Collections.Generic;
using System.IO;
using System.Linq;
using ICSharpCode.SharpZipLib.Zip;

namespace FNSICloudConvertClient.Logic
{
    //----------------------------------------------------------------------------------------------------
    /// <summary>
    /// ZIP アーカイブ作成ユーティリティ
    /// ICSharpCode.SharpZipLib を使用（パスワード付きZIP対応）
    /// パスワードが空の場合はパスワードなしで圧縮する
    /// </summary>
    //----------------------------------------------------------------------------------------------------
    internal static class ZipArchiver
    {
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ディレクトリを ZIP に圧縮する（再帰的にすべてのファイルを含む）
        /// </summary>
        /// <param name="sourceDir">圧縮元ディレクトリ</param>
        /// <param name="destZip">出力 ZIP ファイルパス</param>
        /// <param name="password">ZIPパスワード（null or 空 = パスワードなし）</param>
        //----------------------------------------------------------------------------------------------------
        public static void CreateFromDirectory(string sourceDir, string destZip, string password = null)
        {
            if (File.Exists(destZip)) File.Delete(destZip);

            using (var fs = new FileStream(destZip, FileMode.Create))
            using (var zipStream = new ZipOutputStream(fs))
            {
                zipStream.SetLevel(9);
                if (!string.IsNullOrEmpty(password))
                    zipStream.Password = password;

                foreach (string filePath in Directory.GetFiles(sourceDir, "*", SearchOption.AllDirectories))
                {
                    string entryName = filePath
                        .Substring(sourceDir.Length)
                        .TrimStart('\\', '/')
                        .Replace('\\', '/');

                    var entry = new ZipEntry(entryName) { DateTime = System.DateTime.Now };
                    zipStream.PutNextEntry(entry);

                    using (var fileStream = File.OpenRead(filePath))
                        fileStream.CopyTo(zipStream);

                    zipStream.CloseEntry();
                }
            }
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 指定ファイル群を ZIP に圧縮する。
        /// ZIP 内のエントリ名はファイル名のみ。
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public static void CreateFromFiles(
            IEnumerable<string> sourceFiles,
            string destZip,
            string password = null)
        {
            if (sourceFiles == null)
                throw new System.ArgumentNullException("sourceFiles");

            var files = sourceFiles
                .Where(path => !string.IsNullOrWhiteSpace(path) && File.Exists(path))
                .ToList();

            if (files.Count == 0)
                throw new System.InvalidOperationException("圧縮対象ファイルがありません。");

            if (File.Exists(destZip)) File.Delete(destZip);

            using (var fs = new FileStream(destZip, FileMode.Create))
            using (var zipStream = new ZipOutputStream(fs))
            {
                zipStream.SetLevel(9);
                if (!string.IsNullOrEmpty(password))
                    zipStream.Password = password;

                foreach (string filePath in files)
                {
                    string entryName = Path.GetFileName(filePath);
                    var entry = new ZipEntry(entryName) { DateTime = System.DateTime.Now };
                    zipStream.PutNextEntry(entry);

                    using (var fileStream = File.OpenRead(filePath))
                        fileStream.CopyTo(zipStream);

                    zipStream.CloseEntry();
                }
            }
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ルートディレクトリ配下の指定サブディレクトリのみを ZIP に圧縮する。
        /// ZIP 内のエントリ名は "{facilityCode}/..." の形式。
        /// </summary>
        /// <param name="rootDir">FNSi 物理ファイルルートフォルダ</param>
        /// <param name="subDirNames">対象施設コードリスト（サブディレクトリ名と一致）</param>
        /// <param name="destZip">出力 ZIP ファイルパス</param>
        /// <param name="password">ZIPパスワード（null or 空 = パスワードなし）</param>
        //----------------------------------------------------------------------------------------------------
        public static void CreateFromSubDirectories(
            string              rootDir,
            IEnumerable<string> subDirNames,
            string              destZip,
            string              password = null)
        {
            if (File.Exists(destZip)) File.Delete(destZip);

            using (var fs = new FileStream(destZip, FileMode.Create))
            using (var zipStream = new ZipOutputStream(fs))
            {
                zipStream.SetLevel(9);
                if (!string.IsNullOrEmpty(password))
                    zipStream.Password = password;

                foreach (string subDirName in subDirNames)
                {
                    string subDir = Path.Combine(rootDir, subDirName);
                    if (!Directory.Exists(subDir)) continue;

                    foreach (string filePath in Directory.GetFiles(subDir, "*", SearchOption.AllDirectories))
                    {
                        string relative = filePath
                            .Substring(subDir.Length)
                            .TrimStart('\\', '/')
                            .Replace('\\', '/');

                        string entryName = subDirName + "/" + relative;

                        var entry = new ZipEntry(entryName) { DateTime = System.DateTime.Now };
                        zipStream.PutNextEntry(entry);

                        using (var fileStream = File.OpenRead(filePath))
                            fileStream.CopyTo(zipStream);

                        zipStream.CloseEntry();
                    }
                }
            }
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 空の ZIP ファイルを作成する
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public static void CreateEmpty(string destZip)
        {
            if (File.Exists(destZip)) File.Delete(destZip);

            using (var fs = new FileStream(destZip, FileMode.Create))
            using (var zipStream = new ZipOutputStream(fs))
            {
                zipStream.SetLevel(0);
                // エントリなし — 有効な ZIP ファイルとして認識される
            }
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ZIP ファイルを指定ディレクトリに展開する
        /// </summary>
        /// <param name="zipPath">展開元 ZIP ファイルパス</param>
        /// <param name="destDir">展開先ディレクトリ</param>
        /// <param name="password">ZIPパスワード（null or 空 = パスワードなし）</param>
        //----------------------------------------------------------------------------------------------------
        public static void ExtractToDirectory(string zipPath, string destDir, string password = null)
        {
            Directory.CreateDirectory(destDir);

            using (var fs = File.OpenRead(zipPath))
            using (var zipStream = new ZipInputStream(fs))
            {
                if (!string.IsNullOrEmpty(password))
                    zipStream.Password = password;

                ZipEntry entry;
                while ((entry = zipStream.GetNextEntry()) != null)
                {
                    if (string.IsNullOrEmpty(entry.Name) || entry.IsDirectory) continue;

                    string destPath = Path.Combine(
                        destDir,
                        entry.Name.Replace('/', Path.DirectorySeparatorChar));

                    string dir = Path.GetDirectoryName(destPath);
                    if (!string.IsNullOrEmpty(dir))
                        Directory.CreateDirectory(dir);

                    using (var fileStream = File.Create(destPath))
                        zipStream.CopyTo(fileStream);
                }
            }
        }
    }
}
