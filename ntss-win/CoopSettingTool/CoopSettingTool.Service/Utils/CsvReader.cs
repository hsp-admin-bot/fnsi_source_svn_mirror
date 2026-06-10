using System;
using System.Collections.Generic;
using System.IO;
using System.Text;

namespace CoopSettingTool.Service.Utils
{
    /// <summary>
    /// RFC 4180 compliant CSV Reader.
    /// Handles multiline values correctly.
    /// </summary>
    public class CsvReader
    {
        public static IEnumerable<List<string>> Read(string filePath, Encoding encoding)
        {
            using (var reader = new StreamReader(filePath, encoding))
            {
                foreach (var record in Read(reader))
                {
                    yield return record;
                }
            }
        }

        public static IEnumerable<List<string>> Read(TextReader reader)
        {
            var currentRecord = new List<string>();
            var currentField = new StringBuilder();
            bool inQuotes = false;
            int nextChar;

            while ((nextChar = reader.Read()) != -1)
            {
                char c = (char)nextChar;

                if (inQuotes)
                {
                    if (c == '"')
                    {
                        if (reader.Peek() == '"')
                        {
                            // Escaped quote
                            currentField.Append('"');
                            reader.Read(); // consume the second quote
                        }
                        else
                        {
                            // End of quoted field
                            inQuotes = false;
                        }
                    }
                    else
                    {
                        currentField.Append(c);
                    }
                }
                else
                {
                    if (c == '"')
                    {
                        inQuotes = true;
                    }
                    else if (c == ',')
                    {
                        currentRecord.Add(currentField.ToString());
                        currentField.Clear();
                    }
                    else if (c == '\r')
                    {
                        if (reader.Peek() == '\n')
                        {
                            reader.Read(); // consume \n
                        }
                        // End of record
                        currentRecord.Add(currentField.ToString());
                        yield return new List<string>(currentRecord);
                        currentRecord.Clear();
                        currentField.Clear();
                    }
                    else if (c == '\n')
                    {
                        // End of record
                        currentRecord.Add(currentField.ToString());
                        yield return new List<string>(currentRecord);
                        currentRecord.Clear();
                        currentField.Clear();
                    }
                    else
                    {
                        currentField.Append(c);
                    }
                }
            }

            // Return the last record if it's not empty or if we have processed some fields
            if (currentRecord.Count > 0 || currentField.Length > 0)
            {
                currentRecord.Add(currentField.ToString());
                yield return currentRecord;
            }
        }
    }
}
