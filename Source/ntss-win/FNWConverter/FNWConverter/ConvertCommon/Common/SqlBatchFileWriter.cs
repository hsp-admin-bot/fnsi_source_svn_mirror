using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;


namespace ConvertCommon.Common
{
    public enum BatchFileType
    {
        Sql,
        Csv
    }

    public sealed class SqlBatchFileWriter : IDisposable
    {
        private readonly object _lock = new object();

        private readonly string _directory;
        private readonly string _tableName;
        private readonly string _extension;
        private readonly Encoding _encoding;
        private readonly int _maxLines;
        private readonly bool _isSql;

        private int _fileIndex = 1;
        private readonly List<string> _keyBuffer = new List<string>();
        private readonly List<string> _contentBuffer = new List<string>();

        public SqlBatchFileWriter(
            string directory,
            string tableName,
            string extension,
            Encoding encoding,
            BatchFileType type)
        {
            _directory = directory;
            _tableName = tableName;
            _extension = extension;
            _encoding = encoding;

            _isSql = type == BatchFileType.Sql;
            _maxLines = _isSql ? 1000 : 50000;

            Directory.CreateDirectory(directory);
        }

        /// <summary>
        /// 
        /// </summary>
        public void Add(string key, string content)
        {
            lock (_lock)
            {
                _keyBuffer.Add(key);       
                _contentBuffer.Add(content);

                if (_contentBuffer.Count >= _maxLines)
                {
                    Flush_NoLock();
                }
            }
        }

        private void Flush_NoLock()
        {
            if (_contentBuffer.Count == 0)
                return;

            string path = Path.Combine(
                _directory,
                $"{_tableName}_{_fileIndex:D4}{_extension}");

            using (var fs = new FileStream(path, FileMode.Create, FileAccess.Write, FileShare.Read))
            using (var sw = new StreamWriter(fs, _encoding))
            {
              
                if (_isSql)
                {
                    var validKeys = _keyBuffer.Where(k => !string.IsNullOrEmpty(k)).ToList();
                    if (validKeys.Count > 0)
                    {
                        sw.WriteLine(string.Join(",", validKeys));
                    }
                }

               
                foreach (var line in _contentBuffer)
                {
                    sw.WriteLine(line);
                }
            }

            _fileIndex++;
            _keyBuffer.Clear();
            _contentBuffer.Clear();
        }

        public void Dispose()
        {
            lock (_lock)
            {
                Flush_NoLock();
            }
        }
    }

}
