using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using FNSICloudConvertClient.Models;

namespace FNSICloudConvertClient.Logic
{
    //----------------------------------------------------------------------------------------------------
    /// <summary>
    /// mongo_dump_config.yaml を読み込み、MongoCollectionConfig のリストを返す
    ///
    /// 対応フォーマット（固定構造）:
    ///   mongo-dump:
    ///     collections:
    ///       - name: collection_name
    ///         dump: true | false
    ///         filterField: null | field_name
    /// </summary>
    //----------------------------------------------------------------------------------------------------
    internal static class MongoDumpConfigLoader
    {
        public static List<MongoCollectionConfig> Load(string yamlPath)
        {
            var result = new List<MongoCollectionConfig>();

            if (!File.Exists(yamlPath))
                return result;

            var lines = File.ReadAllLines(yamlPath, Encoding.UTF8);
            MongoCollectionConfig current = null;

            foreach (string rawLine in lines)
            {
                string trimmed = rawLine.TrimStart();

                // 新エントリ開始
                if (trimmed.StartsWith("- name:"))
                {
                    if (current != null)
                        result.Add(current);
                    current = new MongoCollectionConfig { Name = ParseValue(rawLine) };
                    continue;
                }

                if (current == null)
                    continue;

                if (trimmed.StartsWith("dump:"))
                    current.Dump = ParseValue(rawLine).Equals("true", StringComparison.OrdinalIgnoreCase);
                else if (trimmed.StartsWith("filterField:"))
                    current.FilterField = NullOrValue(ParseValue(rawLine));
            }

            if (current != null)
                result.Add(current);

            return result;
        }

        // コロン以降の値を取得し、インラインコメントを除去する
        private static string ParseValue(string line)
        {
            int colon = line.IndexOf(':');
            if (colon < 0) return string.Empty;

            string val = line.Substring(colon + 1).Trim();

            // インラインコメント（スペース + #）を除去
            int commentIdx = val.IndexOf(" #");
            if (commentIdx >= 0)
                val = val.Substring(0, commentIdx).Trim();

            return val;
        }

        // "null" または空文字列は null に変換する
        private static string NullOrValue(string val)
        {
            return string.IsNullOrEmpty(val) || val == "null" ? null : val;
        }
    }
}
