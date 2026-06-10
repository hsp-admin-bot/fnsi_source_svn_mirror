using Fnw.IOControl.DB;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text.RegularExpressions;

namespace ConvertCommon.Common
{
    /// <summary>
    /// ステータスを保持しない関数はこちらで管理
    /// </summary>
    public class CommonFunc
    {
        /// <summary>
        /// 列名、値のリストからSQLのin句を生成する。
        /// chunkSize以上の値のリストの場合、ORで分割する
        /// 例：列名＝PATID、値のリスト2000個の場合
        /// (
        /// PATID IN ('1','2','3'...'1000')
        /// OR
        /// PATID IN ('1001','1002','1003'...'2000')
        /// )
        /// </summary>
        /// <param name="columnName"></param>
        /// <param name="chunkSize"></param>
        /// <param name="list"></param>
        public static string MakeInClause(string columnName, int chunkSize, List<string> list)
        {

            string inClause = "(" + string.Join(" OR ", list.Select((v, i) => new { v, i })
                .GroupBy(x => x.i / chunkSize)
                .Select(g => columnName + " in (" + string.Join(",", g.Select(x => "'" + x.v + "'").ToArray()) + ")")
                .ToArray()) + ")";

            return inClause;
        }


        // add #10418 start
        public class InClauseResult
        {
            public string Clause { get; set; }
            public List<KeyValuePair<string, object>> Parameters { get; set; }

            public InClauseResult()
            {
                Parameters = new List<KeyValuePair<string, object>>();
            }
            public bool HasValue
            {
                get
                {
                    return !string.IsNullOrWhiteSpace(Clause)
                           && Parameters != null
                           && Parameters.Count > 0;
                }
            }
        }

        /// <summary>
        /// 選択患者リストからSQLのin句の生成,患者ID 1000個ずつでループ
        /// 列名、値のリストからSQLのin句を生成する。
        /// chunkSize以上の値のリストの場合、ORで分割する
        /// 例：列名＝INDID、値のリスト2000個の場合
        /// (
        /// INDID IN (;IND_0,: IND_1,: IND_2,: IND_3,: IND_4,: IND_5,: IND_6,: IND_7)
        /// OR
        /// INDID IN (: IND_8,: IND_9,: IND_10,: IND_11,: IND_12,: IND_13)
        /// )
        /// </summary>
        /// <param name="columnName"></param>
        /// <param name="chunkSize"></param>
        /// <param name="list"></param>
        public static InClauseResult BuildParameterizedInCondition(string columnName, int chunkSize, List<string> list, string paramPrefix)
        {


            InClauseResult result = new InClauseResult();

            List<string> orParts = new List<string>();
            int paramIndex = 0;

            for (int i = 0; i < list.Count; i += chunkSize)
            {
                List<string> paramNames = new List<string>();

                for (int j = i; j < i + chunkSize && j < list.Count; j++)
                {
                    string paramName = ":" + paramPrefix + paramIndex++;
                    paramNames.Add(paramName);

                    result.Parameters.Add(
                        new KeyValuePair<string, object>(paramName, list[j])
                    );
                }

                orParts.Add(columnName + " IN (" + string.Join(",", paramNames) + ")");
            }

            result.Clause = "(" + string.Join(" OR ", orParts) + ")";

            return result;
        }

        public static List<string> GetYmList(string tableName, DateTime startDate, DateTime endDate,DBCtrl db)
        {
            List<string> retList = new List<string>();
            string workStartDate = startDate.AddMonths(-1).ToString("yyyyMM");
            if (CommonConfig.isDiff)
            {
                workStartDate = DateTime.Now.AddMonths(-3).ToString("yyyyMM");
            }
            string workEndDate = endDate.AddMonths(1).ToString("yyyyMM");

            //mod #10418 start 
            string startTableName = $"{tableName}_{workStartDate}";
            string endTableName = $"{tableName}_{workEndDate}";
            var param = db.GetIMakeSqlParameters();
            param.AddParam(":START_TABLE", startTableName);
            param.AddParam(":END_TABLE", endTableName);
            string sql = "SELECT TABLE_NAME FROM USER_TABLES WHERE TABLE_NAME BETWEEN :START_TABLE AND :END_TABLE ORDER BY TABLE_NAME";
            DataTable dt = db.SelectTable(sql, param.GetParam());
            //mod #10418 end

            retList = dt.AsEnumerable().Select(r => r["TABLE_NAME"].ToString()).ToList<string>();
            return retList;
           
        }

        public static void AutoBindSqlParams(
           string sql,
           IMakeSqlParameters param,
           Dictionary<string, object> paramMap)
        {
            var matches = Regex.Matches(sql, @":\w+");

            foreach (Match match in matches)
            {
                string paramName = match.Value;

                if (paramMap.ContainsKey(paramName))
                {
                    param.AddParam(paramName, paramMap[paramName] ?? DBNull.Value);
                }
               
            }
        }

        //:p0,:p1,:p2,...:p999
        public static string BuildSqlInParameterString(
             List<string> list,
             IMakeSqlParameters param)
        {
            var paramNames = new List<string>();
            int paramIndex = 0;

            foreach (var value in list)
            {
                string paramName = ":p" + paramIndex++;
                paramNames.Add(paramName);

                param.AddParam(paramName, value);
            }

            return string.Join(",", paramNames);
        }

        //(:p0,:p1),(:p2,:p3)
        public static InClauseResult BuildParameterizedTupleValues(
                List<string> listParam,
                string paramPrefix)
        {

            var list = new List<Tuple<string, string>>();

            foreach (var item in listParam)
            {
                string cleaned = item.Replace("\"", "");
                string[] arr = cleaned.Split(',');

                list.Add(new Tuple<string, string>(arr[0], arr[1]));
            }
            InClauseResult result = new InClauseResult();

            List<string> tupleParts = new List<string>();
            int paramIndex = 0;

            for (int i = 0; i < list.Count; i++)
            {
                var item = list[i];

                string param1 = ":" + paramPrefix + paramIndex++;
                string param2 = ":" + paramPrefix + paramIndex++;

                tupleParts.Add("(" + param1 + "," + param2 + ")");

                result.Parameters.Add(
                    new KeyValuePair<string, object>(param1, item.Item1));

                result.Parameters.Add(
                    new KeyValuePair<string, object>(param2, item.Item2));
            }

            result.Clause = string.Join(",", tupleParts);

            return result;
        }
        // add #10418 end
    }
}
