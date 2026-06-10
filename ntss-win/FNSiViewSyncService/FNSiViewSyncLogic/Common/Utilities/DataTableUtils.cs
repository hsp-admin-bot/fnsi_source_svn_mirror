using System;
using System.Collections.Generic;
using System.Data;

namespace FNSiViewSyncLogicLib.Common.Utilities
{
    public class DataTableUtils
    {
        /// <summary>
        /// DataTableから指定されたカラムのデータを各行ごとに配列として返します。
        /// </summary>
        /// <param name="table">データが含まれるDataTable</param>
        /// <param name="columnIndices">抽出するカラムのインデックスの配列</param>
        /// <returns>各行の指定されたカラムデータを含む配列のリスト</returns>
        public static object GetSelectedColumnsPerRow(DataTable table, int[] columnIndices)
        {
            // columnIndicesが1つの場合はList<string>で返す
            if (columnIndices.Length == 1)
            {
                var columnData = new List<string>();
                foreach (DataRow row in table.Rows)
                {
                    columnData.Add(row[columnIndices[0]].ToString());
                }
                return columnData;
            }
            else
            {
                var rowsData = new List<string[]>();
                foreach (DataRow row in table.Rows)
                {
                    string[] rowData = new string[columnIndices.Length];
                    for (int i = 0; i < columnIndices.Length; i++)
                    {
                        rowData[i] = row[columnIndices[i]].ToString();
                    }
                    rowsData.Add(rowData);
                }
                return rowsData;
            }
        }

    }

}
