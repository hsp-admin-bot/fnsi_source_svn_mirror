using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using FNSICloudConvertClient.Models;

namespace FNSICloudConvertClient.Logic
{
    //----------------------------------------------------------------------------------------------------
    /// <summary>
    /// pg_dump_config.yaml を読み込み、PgTableConfig のリストを返す
    ///
    /// 対応フォーマット（固定構造）:
    ///   pg-dump:
    ///     tables:
    ///       - name: table_name
    ///         idColumn: null | column_name
    ///         sharedPkTable: null | parent_table
    ///         dump: true | false
    ///         whereTemplate: null | "facility_cd IN (:facilityList)"
    ///         direction: both | off2on | on2off
    ///         db: ntss_db4 | ntss_db5 | ntss_db6
    ///         pkGroupTables: [child_table]
    ///         seqName: custom_seq_name
    /// </summary>
    //----------------------------------------------------------------------------------------------------
    internal static class PgDumpConfigLoader
    {
        public static List<PgTableConfig> Load(string yamlPath)
        {
            var result = new List<PgTableConfig>();

            if (!File.Exists(yamlPath))
                return result;

            var lines = File.ReadAllLines(yamlPath, Encoding.UTF8);
            PgTableConfig current = null;

            foreach (string rawLine in lines)
            {
                string trimmed = rawLine.TrimStart();

                if (trimmed.StartsWith("- name:"))
                {
                    if (current != null)
                        result.Add(current);
                    current = new PgTableConfig { Name = ParseValue(rawLine) };
                    continue;
                }

                if (current == null)
                    continue;

                if (trimmed.StartsWith("idColumn:"))
                    current.IdColumn = NullOrValue(ParseValue(rawLine));
                else if (trimmed.StartsWith("sharedPkTable:"))
                    current.SharedPkTable = NullOrValue(ParseValue(rawLine));
                else if (trimmed.StartsWith("dump:"))
                    current.Dump = ParseValue(rawLine).Equals("true", StringComparison.OrdinalIgnoreCase);
                else if (trimmed.StartsWith("whereTemplate:"))
                    current.WhereTemplate = NullOrValue(ParseValueUnquoted(rawLine));
                else if (trimmed.StartsWith("direction:"))
                    current.Direction = ParseValue(rawLine);
                else if (trimmed.StartsWith("db:"))
                    current.Db = ParseValue(rawLine);
                else if (trimmed.StartsWith("pkGroupTables:"))
                    current.PkGroupTables = ParseInlineList(ParseValueUnquoted(rawLine));
                else if (trimmed.StartsWith("seqName:"))
                    current.SeqName = NullOrValue(ParseValue(rawLine));
            }

            if (current != null)
                result.Add(current);

            return result;
        }

        private static string ParseValue(string line)
        {
            int colon = line.IndexOf(':');
            if (colon < 0) return string.Empty;

            string val = line.Substring(colon + 1).Trim();
            int commentIdx = val.IndexOf(" #");
            if (commentIdx >= 0)
                val = val.Substring(0, commentIdx).Trim();

            return val;
        }

        private static string ParseValueUnquoted(string line)
        {
            string val = ParseValue(line);
            if (val.Length >= 2 &&
                ((val[0] == '"'  && val[val.Length - 1] == '"') ||
                 (val[0] == '\'' && val[val.Length - 1] == '\'')))
            {
                return val.Substring(1, val.Length - 2);
            }
            return val;
        }

        private static string NullOrValue(string val)
        {
            return string.IsNullOrEmpty(val) || val == "null" ? null : val;
        }

        private static List<string> ParseInlineList(string val)
        {
            var result = new List<string>();
            if (string.IsNullOrWhiteSpace(val) || val == "null")
                return result;

            string trimmed = val.Trim();
            if (trimmed.StartsWith("[") && trimmed.EndsWith("]"))
                trimmed = trimmed.Substring(1, trimmed.Length - 2);

            if (string.IsNullOrWhiteSpace(trimmed))
                return result;

            foreach (string part in trimmed.Split(','))
            {
                string item = part.Trim();
                if (item.Length >= 2 &&
                    ((item[0] == '"'  && item[item.Length - 1] == '"') ||
                     (item[0] == '\'' && item[item.Length - 1] == '\'')))
                {
                    item = item.Substring(1, item.Length - 2);
                }

                if (!string.IsNullOrWhiteSpace(item))
                    result.Add(item);
            }

            return result;
        }
    }
}
