using System;
using System.Data;
using System.IO;
using System.Text;
using Fnw.StatisticsTool.Properties;
using Microsoft.VisualBasic.FileIO;
using NKKLoggingLib;

namespace Fnw.StatisticsTool.Csv
{
    static class FnwCsv
    {
        /// <summary>
        /// CSVファイルを読み取る
        /// </summary>
        /// <param name="path">ファイルのパス</param>
        /// <returns>結果データ nullはエラー</returns>
        public static DataTable Read(string path)
        {
            TextFieldParser parser;
            try
            {
                parser = new TextFieldParser(path, Encoding.GetEncoding("Shift_JIS"));
            }
            catch (Exception ex)
            {
                NKKLogging.GetInstance().AddErrorLogInfo(DateTime.Now, StatisticsUtility.PRODUCT_NAME, nameof(FnwCsv), NKKLogging.LOGGING_CLASS.ERROR, String.Format("CSVファイルオープンエラー,{0},{1}", path, ex.ToString().Replace("\r\n", "{CRLF}")));
                return null;
            }

            parser.TextFieldType = FieldType.Delimited;
            parser.SetDelimiters(",");
            parser.TrimWhiteSpace = false;

            DataTable dt = new DataTable();

            while (false == parser.EndOfData)
            {
                string[] list = parser.ReadFields();

                while (dt.Columns.Count < list.Length)
                {
                    dt.Columns.Add();
                }

                DataRow row = dt.NewRow();

                for (int i = 0; i < list.Length; i++)
                {
                    row[i] = list[i];
                }

                dt.Rows.Add(row);
            }

            parser.Close();
            parser.Dispose();

            return dt;
        }

        /// <summary>
        /// DataTableをCSVフォーマットでファイル出力
        /// </summary>
        /// <param name="path">ファイルパス</param>
        /// <param name="data">出力するデータ</param>
        /// <returns>true:成功 false:失敗</returns>
        public static bool Write(string path, DataTable data)
        {
            if (null == data)
            {
                return false;
            }

            FileStream fs;

            try
            {
                fs = File.Open(path, FileMode.Create, FileAccess.Write, FileShare.Read);
            }
            catch (Exception ex)
            {
                NKKLogging.GetInstance().AddErrorLogInfo(DateTime.Now, StatisticsUtility.PRODUCT_NAME, nameof(FnwCsv), NKKLogging.LOGGING_CLASS.ERROR, String.Format("CSVファイルオープン失敗,{0},{1}", path, ex.ToString().Replace("\r\n", "{CRLF}")));
                return false;
            }

            for (int i = 0; i < data.Rows.Count; i++)
            {
                for (int j = 0; j < data.Columns.Count; j++)
                {
                    string work = data.Rows[i][j] as string;

                    if (false == string.IsNullOrEmpty(work))
                    {
                        // ダブルクオートは重ねてエスケープ
                        work = work.Replace("\"", "\"\"");
                    }
                    else
                    {
                        // nullの場合に備えて空文字に置き換え
                        work = string.Empty;
                    }

                    if (0 <= work.IndexOfAny(new char[] { '\"', ',' }))
                    {
                        // データの中にダブルクオートまたはコンマが入っている場合はダブルクオートで全体を囲む
                        work = "\"" + work + "\"" + (j == data.Columns.Count - 1 ? string.Empty : ",");
                    }
                    else
                    {
                        work = work + (j == data.Columns.Count - 1 ? string.Empty : ",");
                    }

                    byte[] byteStr = Encoding.GetEncoding(932).GetBytes(work);

                    foreach (byte b in byteStr)
                    {
                        fs.WriteByte(b);
                    }
                }

                fs.WriteByte(Encoding.GetEncoding(932).GetBytes("\r")[0]);
                fs.WriteByte(Encoding.GetEncoding(932).GetBytes("\n")[0]);
            }

            fs.Close();
            fs.Dispose();

            return true;
        }


        /// <summary>
        /// DataTableをCSVフォーマットでファイル出力
        /// </summary>
        /// <param name="path">ファイルパス</param>
        /// <param name="data">出力するデータ</param>
        /// <returns>true:成功 false:失敗</returns>
        public static bool AppendWrite(string path, DataTable data)
        {
            if (null == data)
            {
                return false;
            }

            FileStream fs;

            try
            {
                fs = File.Open(path, FileMode.Append, FileAccess.Write, FileShare.Read);
            }
            catch (Exception ex)
            {
                NKKLogging.GetInstance().AddErrorLogInfo(DateTime.Now, StatisticsUtility.PRODUCT_NAME, nameof(FnwCsv), NKKLogging.LOGGING_CLASS.ERROR, String.Format("CSVファイルオープン失敗,{0},{1}", path, ex.ToString().Replace("\r\n", "{CRLF}")));
                return false;
            }

            for (int i = 0; i < data.Rows.Count; i++)
            {
                for (int j = 0; j < data.Columns.Count; j++)
                {
                    string work = data.Rows[i][j] as string;

                    if (false == string.IsNullOrEmpty(work))
                    {
                        // ダブルクオートは重ねてエスケープ
                        work = work.Replace("\"", "\"\"");
                    }
                    else
                    {
                        // nullの場合に備えて空文字に置き換え
                        work = string.Empty;
                    }

                    if (0 <= work.IndexOfAny(new char[] { '\"', ',' }))
                    {
                        // データの中にダブルクオートまたはコンマが入っている場合はダブルクオートで全体を囲む
                        work = "\"" + work + "\"" + (j == data.Columns.Count - 1 ? string.Empty : ",");
                    }
                    else
                    {
                        work = work + (j == data.Columns.Count - 1 ? string.Empty : ",");
                    }

                    byte[] byteStr = Encoding.GetEncoding(932).GetBytes(work);

                    foreach (byte b in byteStr)
                    {
                        fs.WriteByte(b);
                    }
                }

                fs.WriteByte(Encoding.GetEncoding(932).GetBytes("\r")[0]);
                fs.WriteByte(Encoding.GetEncoding(932).GetBytes("\n")[0]);
            }

            fs.Close();
            fs.Dispose();

            return true;
        }


        /// <summary>
        /// 登録済み患者一覧情報取得
        /// </summary>
        /// <returns></returns>
        public static DataTable ReadPatientCsv()
        {
            DataTable dt = FnwCsv.Read(Path.Combine(Settings.Default.PathCsv, Settings.Default.PathPatient));
            if (null == dt)
            {
                dt = new DataTable();
            }

            while (dt.Columns.Count < (int)SheetSum.件数_)
            {
                dt.Columns.Add();
            }

            return dt;
        }

        public const string C_M_PAT1 = "C_M_PAT1";
        /// <summary>FNWのPATID</summary>
        public const string C_M_PAT2 = "C_M_PAT2";
        public const string C_M_PAT3 = "C_M_PAT3";
        /// <summary>
        /// 登録済み患者割当情報取得
        /// </summary>
        /// <returns></returns>
        public static DataTable ReadMatchPatientCsv()
        {
            DataTable dt = FnwCsv.Read(Path.Combine(Settings.Default.PathCsv, Settings.Default.PathMatchPatient));
            if (null == dt)
            {
                dt = new DataTable();
            }

            if (dt.Columns.Count < 1)
            {
                dt.Columns.Add(C_M_PAT1);
            }
            else
            {
                dt.Columns[0].ColumnName = C_M_PAT1;
            }

            if (dt.Columns.Count < 2)
            {
                dt.Columns.Add(C_M_PAT2);
            }
            else
            {
                dt.Columns[1].ColumnName = C_M_PAT2;
            }

            if (dt.Columns.Count < 3)
            {
                dt.Columns.Add(C_M_PAT3);
            }
            else
            {
                dt.Columns[2].ColumnName = C_M_PAT3;
            }

            return dt;
        }

        /// <summary>FNW病名コード</summary>
        public const string C_M_DIS1 = "C_M_DIS1";
        /// <summary>学会の原疾患コード</summary>
        public const string C_M_DIS2 = "C_M_DIS2";
        /// <summary>
        /// 学会の原疾患コードの不明コード
        /// </summary>
        /// <remarks>2015年度対応（未設定項目に不明コードを設定）</remarks>
        public const string C_M_DIS2_Unknown = "210";
        /// <summary>
        /// 病名割当情報取得
        /// </summary>
        /// <returns></returns>
        public static DataTable ReadMatchMstDiseaseCsv()
        {
            // 2021年度版対応(原疾患について前年データがある場合は引き継ぐ) （Start）
            // 前年度のXMLファイルが存在する場合、リネームを行う。
            // ファイルが存在しない場合は、何もしない。
            // 前年度の原疾患ファイルパス
            String strLastYearFilePath = Path.Combine(Settings.Default.PathCsv, Settings.Default.PathMatchMstDiseaseLastYear);
            String strThisYearFilePath = Path.Combine(Settings.Default.PathCsv, Settings.Default.PathMatchMstDisease);
            if (File.Exists(strLastYearFilePath))
            {
                //LogManager.WriteTraceLog(null, null, "前年度の原疾患の設定ファイル名変更 変更前:" + strLastYearFilePath + " 変更後:" + strThisYearFilePath);
                File.Move(strLastYearFilePath, strThisYearFilePath);
            }
            DataTable dt = FnwCsv.Read(strThisYearFilePath);
            // 2021年度版対応(原疾患について前年データがある場合は引き継ぐ) （End）
            if (null == dt)
            {
                dt = new DataTable();
            }

            if (dt.Columns.Count < 1)
            {
                dt.Columns.Add(C_M_DIS1);
            }
            else
            {
                dt.Columns[0].ColumnName = C_M_DIS1;
            }

            if (dt.Columns.Count < 2)
            {
                dt.Columns.Add(C_M_DIS2);
            }
            else
            {
                dt.Columns[1].ColumnName = C_M_DIS2;
            }

            return dt;
        }

        /// <summary>FNW治療方法コード</summary>
        public const string C_M_TRE1 = "C_M_TRE1";
        /// <summary>学会の治療方法コード</summary>
        public const string C_M_TRE2 = "C_M_TRE2";
        /// <summary>
        /// 治療方法割当情報取得
        /// </summary>
        /// <returns></returns>
        public static DataTable ReadMatchMstTreatItemCsv()
        {
            DataTable dt = FnwCsv.Read(Path.Combine(Settings.Default.PathCsv, Settings.Default.PathMatchMstTreatItem));
            if (null == dt)
            {
                dt = new DataTable();
            }

            if (dt.Columns.Count < 1)
            {
                dt.Columns.Add(C_M_TRE1);
            }
            else
            {
                dt.Columns[0].ColumnName = C_M_TRE1;
            }

            if (dt.Columns.Count < 2)
            {
                dt.Columns.Add(C_M_TRE2);
            }
            else
            {
                dt.Columns[1].ColumnName = C_M_TRE2;
            }

            return dt;
        }

        public const string C_M_DIE1 = "C_M_DIE1";
        public const string C_M_DIE2 = "C_M_DIE2";
        /// <summary>
        /// 死因割当情報取得
        /// </summary>
        /// <returns></returns>
        public static DataTable ReadMatchMstDieCsv()
        {
            // 2021年度版対応(死因について前年データがある場合は引き継ぐ) （Start）
            // 前年度のXMLファイルが存在する場合、リネームを行う。
            // ファイルが存在しない場合は、何もしない。
            // 前年度の原疾患ファイルパス
            String strLastYearFilePath = Path.Combine(Settings.Default.PathCsv, Settings.Default.PathMatchMstDieLastYear);
            String strThisYearFilePath = Path.Combine(Settings.Default.PathCsv, Settings.Default.PathMatchMstDie);
            if (File.Exists(strLastYearFilePath))
            {
                //LogManager.WriteTraceLog(null, null, "前年度の死因の設定ファイル名変更 変更前:" + strLastYearFilePath + " 変更後:" + strThisYearFilePath);
                File.Move(strLastYearFilePath, strThisYearFilePath);
            }
            DataTable dt = FnwCsv.Read(strThisYearFilePath);
            // 2021年度版対応(死因について前年データがある場合は引き継ぐ) （End）
            if (null == dt)
            {
                dt = new DataTable();
            }

            if (dt.Columns.Count < 1)
            {
                dt.Columns.Add(C_M_DIE1);
            }
            else
            {
                dt.Columns[0].ColumnName = C_M_DIE1;
            }

            if (dt.Columns.Count < 2)
            {
                dt.Columns.Add(C_M_DIE2);
            }
            else
            {
                dt.Columns[1].ColumnName = C_M_DIE2;
            }

            return dt;
        }

        public const string C_M_FAC1 = "C_M_FAC1";
        public const string C_M_FAC2 = "C_M_FAC2";
        /// <summary>
        /// 施設割当
        /// </summary>
        /// <returns></returns>
        public static DataTable ReadMatchMstFacilityCsv()
        {
            DataTable dt = FnwCsv.Read(Path.Combine(Settings.Default.PathCsv, Settings.Default.PathMatchMstFacility));
            if (null == dt)
            {
                dt = new DataTable();
            }

            if (dt.Columns.Count < 1)
            {
                dt.Columns.Add(C_M_FAC1);
            }
            else
            {
                dt.Columns[0].ColumnName = C_M_FAC1;
            }

            if (dt.Columns.Count < 2)
            {
                dt.Columns.Add(C_M_FAC2);
            }
            else
            {
                dt.Columns[1].ColumnName = C_M_FAC2;
            }

            return dt;
        }

        public const string C_M_EXA1 = "C_M_EXA1";
        public const string C_M_EXA2 = "C_M_EXA2";
        public static DataTable ReadMatchMstExamItemCsv()
        {
            DataTable dt = FnwCsv.Read(Path.Combine(Settings.Default.PathCsv, Settings.Default.PathMatchMstExamItem));
            if (null == dt)
            {
                dt = new DataTable();
            }

            if (dt.Columns.Count < 1)
            {
                dt.Columns.Add(C_M_EXA1);
            }
            else
            {
                dt.Columns[0].ColumnName = C_M_EXA1;
            }

            if (dt.Columns.Count < 2)
            {
                dt.Columns.Add(C_M_EXA2);
            }
            else
            {
                dt.Columns[1].ColumnName = C_M_EXA2;
            }
            return dt;
        }

        /// <summary>FNW病名コード</summary>
        public const string C_M_DIS_DIA1 = "C_M_DIS_DIA1";
        /// <summary>選択結果</summary>
        public const string C_M_DIS_DIA2 = "C_M_DIS_DIA2";
        /// <summary>
        /// 糖尿病選択情報取得
        /// </summary>
        /// <returns></returns>
        public static DataTable ReadSelectMstDiseaseDiabetesCsv()
        {
            DataTable dt = FnwCsv.Read(Path.Combine(Settings.Default.PathCsv, Settings.Default.PathSelectMstDiseaseDiabetes));
            if (null == dt)
            {
                dt = new DataTable();
            }

            if (dt.Columns.Count < 1)
            {
                dt.Columns.Add(C_M_DIS_DIA1);
            }
            else
            {
                dt.Columns[0].ColumnName = C_M_DIS_DIA1;
            }

            if (dt.Columns.Count < 2)
            {
                dt.Columns.Add(C_M_DIS_DIA2);
            }
            else
            {
                dt.Columns[1].ColumnName = C_M_DIS_DIA2;
            }

            return dt;
        }

        public const string C_M_INF1 = "C_M_INF1";
        public const string C_M_INF2 = "C_M_INF2";
        /// <summary>
        /// 感染症割当
        /// </summary>
        /// <returns></returns>
        public static DataTable ReadMatchMstInfectionCsv()
        {
            DataTable dt = FnwCsv.Read(Path.Combine(Settings.Default.PathCsv, Settings.Default.PathMatchMstInfection));
            if (null == dt)
            {
                dt = new DataTable();
            }

            if (dt.Columns.Count < 1)
            {
                dt.Columns.Add(C_M_INF1);
            }
            else
            {
                dt.Columns[0].ColumnName = C_M_INF1;
            }

            if (dt.Columns.Count < 2)
            {
                dt.Columns.Add(C_M_INF2);
            }
            else
            {
                dt.Columns[1].ColumnName = C_M_INF2;
            }

            return dt;
        }

        //2025年度対象項目
        public const string C_M_VA1 = "C_M_VA1";
        public const string C_M_VA2 = "C_M_VA2";
        /// <summary>
        /// バスキュラーアクセス割当
        /// </summary>
        /// <returns></returns>
        public static DataTable ReadMatchMstVaCsv()
        {
            DataTable dt = FnwCsv.Read(Path.Combine(Settings.Default.PathCsv, Settings.Default.PathMatchMstVa));
            if (null == dt)
            {
                dt = new DataTable();
            }

            if (dt.Columns.Count < 1)
            {
                dt.Columns.Add(C_M_VA1);
            }
            else
            {
                dt.Columns[0].ColumnName = C_M_VA1;
            }

            if (dt.Columns.Count < 2)
            {
                dt.Columns.Add(C_M_VA2);
            }
            else
            {
                dt.Columns[1].ColumnName = C_M_VA2;
            }

            return dt;
        }
        //END
    }
}
