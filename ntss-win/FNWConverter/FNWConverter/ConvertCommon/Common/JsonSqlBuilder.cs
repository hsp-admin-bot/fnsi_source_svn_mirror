using ConvertCommon.Const;
using ConvertCommon.parts;
using Fnw.IOControl.DB;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using static ConvertCommon.ConvertBase;

namespace ConvertCommon.Common
{
    public static class JsonSqlBuilder
    {
        static private DBCtrl db = ConvertControl.DBConnectFnw();

        /// <summary>smallint</summary>
        static string NTSS_DATA_TYPE_SMALLINT = "smallint";
        /// <summary>integer</summary>
        static string NTSS_DATA_TYPE_INTEGER = "integer";
        /// <summary>bigint</summary>
        static string NTSS_DATA_TYPE_BIGINT = "bigint";
        /// <summary>numeric</summary>
        static string NTSS_DATA_TYPE_NUMERIC = "numeric";
        /// <summary>number</summary>
        static string NTSS_DATA_TYPE_NUMBER = "number";
        /// <summary>inet</summary>
        static string NTSS_DATA_TYPE_BOOLEAN = "boolean";
        /// <summary>inet</summary>
        static string NTSS_DATA_TYPE_BOOL = "bool";

        static string templeteJBOSql = "json_build_object({0})";
        static string templeteJBASql = "json_build_array(VARIADIC ARRAY[{0}])";
        static string templeteCJBASql = "json_build_array({0})";
        static string templeteJBOWithKeyUseFkSql = "{0},json_build_object({1})";
        static string templeteATJsql = "array_to_json((select array_agg(value) from ({0}) as dual))";
        static private List<string> listConvMedicineTypeTbl = new List<string>() { "mst_treatment_set", "ord_main", "pat_treatment_pattern" };
        static private List<string> listConvMedicineTypeField = new List<string>() { "ind_cond_info", "rst_cond_info" };
        // add #9686 指示コンバートで終了日ありにも関わらずそれ以降も延長されている zkm start
        /// <summary>透析条件単位変換リスト</summary>
        private static Dictionary<string, string> UnitConvByCtlNoList = new Dictionary<string, string>()
        {
            { "1", "分" },
            { "2", null },
            { "3", "Kg" },
            { "4", "L" },
            { "5", "本" },
            { "6", "COND" },
            { "7", "COND" },
            { "8", "COND" },
            { "9", "COND" },
            { "10", "COND" },
            { "11", "COND" },
            { "12", null },
            { "13", "COND" },
            { "14", "mL/min" },
            { "15", "COND" },
            { "16", "mL/min" },
            { "17", "COND" },
            { "18", "℃" },
            { "19", "COND" },
            { "20", "L" },
            { "21", null },
            { "22", "COND" },
            { "23", "℃" },
            { "24", "L/h" },
            { "25", "COND" },
            { "26", "COND" },
            { "27", "COND" },
            { "28", "COND" },
            { "29", null },
            { "30", null },
            { "31", "mL" },
            { "32", "mL/h" },
            { "33", "mL/h" },
            { "34", null },
            { "35", null },
            { "36", "分前" },
            { "37", null },
            { "38", "分前" },
            { "39", "COND" },
        };
        /// <summary>透析条件翻訳1変換リスト</summary>
        private static Dictionary<string, string> ValueNameConvByCtlNoList = new Dictionary<string, string>()
        {
            { "1", null },
            { "2", "COND" },
            { "3", null },
            { "4", null },
            { "5", "COND" },
            { "6", "COND" },
            { "7", "COND" },
            { "8", "COND" },
            { "9", "COND" },
            { "10", "COND" },
            { "11", "COND" },
            { "12", "CONVERT"  }, // 設定値 = 0: '使用しない', 設定値 = 1:'使用する', 以外の場合、NULL
            { "13", "COND" },
            { "14", null },
            { "15", "COND" },
            { "16", null },
            { "17", null },
            { "18", null },
            { "19", "COND" },
            { "20", null },
            { "21", "CONVERT" }, // 設定値 = 0: '後補液', 設定値 = 1:'前補液', 以外の場合、NULL
            { "22", null },
            { "23", null },
            { "24", null },
            { "25", "COND" },
            { "26", null },
            { "27", null },
            { "28", null },
            { "29", "CONVERT" }, // 設定値 = 0: '使用しない', 設定値 = 1:'使用する', 以外の場合、NULL
            { "30", "CONVERT" }, // 設定値 = 0: '手動', 設定値 = 1:'自動', 以外の場合、NULL
            { "31", null },
            { "32", null },
            { "33", null },
            { "34", "CONVERT" }, // 設定値 = 0: '使用しない', 設定値 = 1:'使用する', 以外の場合、NULL
            { "35", "CONVERT" }, // 設定値 = 0: '切', 設定値 = 1:'入', 以外の場合、NULL
            { "36", null },
            { "37", "CONVERT" }, // 設定値 = 0: '切', 設定値 = 1:'入', 以外の場合、NULL
            { "38", null },
            { "39", "COND" }
        };

        private static Dictionary<string, Dictionary<string, string>> ValueNameConvertList = new Dictionary<string, Dictionary<string, string>>()
        {
            { "12", new Dictionary<string, string>(){ {"0", "使用しない"}, {"1", "使用する"}, { "2", null }}},
            { "21", new Dictionary<string, string>(){ {"0", "後補液" }, {"1", "前補液" }, { "2", null }}},
            { "29", new Dictionary<string, string>(){ {"0", "使用しない"}, {"1", "使用する"}, { "2", null }}},
            { "30", new Dictionary<string, string>(){ {"0", "手動" }, {"1", "自動" }, { "2", null }}},
            { "34", new Dictionary<string, string>(){ {"0", "使用しない" }, {"1", "使用する" }, { "2", null }}},
            { "35", new Dictionary<string, string>(){ {"0", "切" }, {"1", "入" }, { "2", null }}},
            { "37", new Dictionary<string, string>(){ {"0", "切" }, {"1", "入" }, { "2", null }}}
        };

        // add #9686 指示コンバートで終了日ありにも関わらずそれ以降も延長されている zkm end

        public static string BuildJsonArraySql(string ntssColumnName,
                                            List<List<JsonElement>> jsonElementListList,
                                            ConvertValueInfoBase simpleConvertValueInfo,
                                            Dictionary<string, string> fkConvertSqlMap,
                                            Dictionary<string, string> customCovertValueSqlMap,
                                            NtssRecord ntssRecord, string convertTableName)
        {

            List<JsonElement> jsonValueList = new List<JsonElement>();
            // リストの詰め替え
            jsonElementListList.ForEach(list => jsonValueList.AddRange(list));

            if (jsonValueList.Count == 1 && jsonValueList[0].value.Equals("null"))
            {
                // 値の配列の場合に返す値が存在しない場合、空配列を返す
                return "json_build_array()";
            }

            string sql = string.Join(" union ", jsonValueList.Where(je => je.sqlCreationExclusionFlg == false).Select(je =>
            {
                string value = getSqlStatement(ntssColumnName,
                                                je,
                                                simpleConvertValueInfo,
                                                fkConvertSqlMap,
                                                customCovertValueSqlMap,
                                                ntssRecord,
                                                jsonValueList,
                                                false, convertTableName);
                // 型取得
                string type;
                if (je.jsonValueType.Equals("number"))
                {
                    type = "numeric";
                }
                else
                {
                    type = "text";
                }

                // 外部キー取得SQLの取得対象のカラムの場合、取得したSQLを加工する
                // ADD 20191009 hama 通常の値配列に対応していなかったため、常に下記SQLを使用する
                if (fkConvertSqlMap.ContainsKey(ntssColumnName))
                {
                    value = "select (" + value + ")::" + type + " as value";
                }
                else
                {
                    value = "select " + value + "::" + type + " as value";
                }
                return value;
            }).ToArray());

            return string.Format(templeteATJsql, sql);
        }



        //add #11902 セコム連携 COP_COOP_SEND_HST.MEMOのコンバート start

        public static string BuildJsonNoArraySave2(NtssRecord ntssRecord)
        {

            string memo = ntssRecord.columns.FirstOrDefault(c => c.name == "memo").value.ToString();
            string coopId = ntssRecord.columns.FirstOrDefault(c => c.name == "coop_id").value.ToString();
            string ord_no = ntssRecord.columns.FirstOrDefault(c => c.name == "ord_no").value.ToString();
            string patId = ntssRecord.columns.FirstOrDefault(c => c.name == "pat_id").value.ToString();
            CoopDto dto = CoopMemoUtil.Parse(coopId, memo,CommonConfig.FacilityCd,ord_no, patId);
            string sqlJson = BuildJsonSql(dto, coopId);
            return sqlJson;
        }

        public static string BuildJsonSql(CoopDto dto,string coopId)
        {
            var sb = new StringBuilder();

            sb.Append("json_build_object(");

            Append(sb, "coop_cd", dto.coop_cd);
            AppendRaw(sb, "ord_no", dto.ord_no);
            Append(sb, "memo", dto.memo);

            if ("SCM02".Equals(coopId) || "SCM04".Equals(coopId)) {
                Append(sb, "sequence_no", dto.sequence_no);

            }
                
            if ("SCM02".Equals(coopId)) {

                AppendRaw(sb, "treatment_user_id", dto.treatment_user_id);
                Append(sb, "treatment_send_day", dto.treatment_send_day);
                Append(sb, "treatment_seq_no", dto.treatment_seq_no);

                AppendRaw(sb, "injection_user_id", dto.injection_user_id);
                Append(sb, "injection_send_day", dto.injection_send_day);
                Append(sb, "injection_seq_no", dto.injection_seq_no);

                Append(sb, "medical_send_day", dto.medical_send_day);
                Append(sb, "medical_seq_no", dto.medical_seq_no);

                sb.Append("'item_list', ");
                sb.Append(dto.item_list == null ? "null" : BuildItemList(dto.item_list));
                sb.Append(",");

                
            }
            if (sb[sb.Length - 1] == ',')
                sb.Length--;

            sb.Append(")");

            return sb.ToString();
        }
        private static void Append(StringBuilder sb, string key, string value)
        {
            if (value == null || value == "")
            {
                sb.AppendFormat("'{0}', '',", key);
            }
            else
            {
                sb.AppendFormat("'{0}', '{1}',", key,  MakeColumnSpecialFormat(null, null, value, SpecialColumnType.SQL_STRING, true));
            }
        }

        private static void AppendRaw(StringBuilder sb, string key, string rawSql)
        {
            if (string.IsNullOrEmpty(rawSql))
            {
                sb.AppendFormat("'{0}', '',", key);
            }
            else
            {
                sb.AppendFormat("'{0}', {1},", key, rawSql);
            }
        }
        private static string BuildItemList(List<ItemDto> list)
        {
            if (list == null || list.Count == 0)
                return "json_build_array()";

            var sb = new StringBuilder();
            sb.Append("json_build_array(");

            foreach (var item in list)
            {
                sb.Append("json_build_object(");
                sb.AppendFormat("'medicine_no','{0}',", item.medicine_no);
                sb.AppendFormat("'rp_no','{0}'", item.rp_no);
                sb.Append("),");
            }

            if (sb[sb.Length - 1] == ',')
                sb.Length--;

            sb.Append(")");

            return sb.ToString();
        }
        //add #11902 セコム連携 COP_COOP_SEND_HST.MEMOのコンバート end

        public static string BuildJsonNoArray(string ntssColumnName,
                                           List<List<JsonElement>> jsonElementListList,
                                           ConvertValueInfoBase simpleConvertValueInfo,
                                           Dictionary<string, string> fkConvertSqlMap,
                                           Dictionary<string, string> customCovertValueSqlMap,
                                           NtssRecord ntssRecord, string convertTableName)
        {
            string sql = "";

            foreach (List<JsonElement> jsonElementList in jsonElementListList)
            {
                sql = string.Join(",", jsonElementList.Where(je => je.sqlCreationExclusionFlg == false && !je.keyName.Contains("recrcl_rt")).Select(je =>
                {
                    string value = getSqlStatement(ntssColumnName + je.getKeyNameDeleteEscape(),
                                                       je,
                                                       simpleConvertValueInfo,
                                                       fkConvertSqlMap,
                                                       customCovertValueSqlMap,
                                                       ntssRecord,
                                                       jsonElementList,
                                                       false, convertTableName);
                    return "'" + je.getKeyNameDeleteEscape() + "'," + value;
                }).ToArray());

                // #7475 LL start
                if (ntssColumnName == "rst_weight_info")
                {
                    string rstSQl = "'recrcl_rt', json_build_object('valid_no',{valid_no},'1',json_build_object('rate',{rate1},'bld_vl',{bld1},'datetime',{datetime1},'comment','')," +
                                                "'2',json_build_object('rate',{rate2},'bld_vl',{bld2},'datetime',{datetime2},'comment','')," +
                                                "'3',json_build_object('rate',{rate3},'bld_vl',{bld3},'datetime',{datetime3},'comment','')," +
                                                "'4',json_build_object('rate',{rate4},'bld_vl',{bld4},'datetime',{datetime4},'comment','')," +
                                                "'5',json_build_object('rate',{rate5},'bld_vl',{bld5},'datetime',{datetime5},'comment',''))";
                    foreach (JsonElement e in jsonElementList)
                    {
                        if (e.keyName.Contains("recrcl_rt") && e.jsonDataFormat == JsonDataFormat.JsonNest)
                        {
                            string[] spName = e.keyName.Split('_');
                            string replace = spName[2] + spName[3];
                            if (replace.Contains("datetime") && !e.value.ToString().Equals("null"))
                            {
                                //add #12316 start
                                var date = GetFormatedDate(e.value.ToString());
                                if (date == null)
                                {
                                    rstSQl = rstSQl.Replace("{" + replace.Replace(@"""", "") + "}", "null");
                                }
                                else
                                {

                                    rstSQl = rstSQl.Replace("{" + replace.Replace(@"""", "") + "}", string.Format("'{0}'", ((DateTime)date).ToString("yyyy-MM-ddTHH:mm:ss.fffzzz")));
                                }
                                //add #12316 end
                            }
                            else
                            {
                                rstSQl = rstSQl.Replace("{" + replace.Replace(@"""", "") + "}", e.value.ToString());
                            }
                        }
                        else if (e.keyName.Contains("valid_no"))
                        {
                            rstSQl = rstSQl.Replace("{valid_no}", e.value.ToString());
                        }
                    }
                    sql += "," + rstSQl;
                }
                // #7475 LL end
            }
            //add FNSI-host_notification_info設定追加 楊 start
            if ("''".Equals(sql.Split(',')[0]))
            {
                return string.Format(templeteJBOSql, "");
            }
            //add FNSI-host_notification_info設定追加 楊 end
            return string.Format(templeteJBOSql, sql);
        }


        private static string ShortJsonDisItemInfo(List<List<JsonElement>> jsonElementListList)
        {

            string plan = string.Format(templeteJBOSql, "'component', 'treat-plan','subCategoryNo', 1,'subCategoryItem', json_build_array(VARIADIC ARRAY[json_build_object('itemNo',1 , 'itemName','治療予定')]),'subCategoryName', '治療予定'");
            string method = string.Format(templeteJBOSql, "'component', 'treat-method','subCategoryNo', 2,'subCategoryItem', json_build_array(VARIADIC ARRAY[json_build_object('itemNo',1 , 'itemName','治療方法')]),'subCategoryName', '治療方法'");
            //条件指示「透析開始時刻」の表示切替
            //add 7997 start 
            string sCD = "";
            if (CacheInformation.Instance.FacilityCd.Equals("1"))
            {
                sCD = $" AND  SERIES_CD = '{CommonConfig.seriesCd}'";
            }
            //add 7997 start
            string value = db.SelectTable("select VALUE from SYS_SYSTEM_DEFINE where ID ='80'" + sCD).Rows[0]["VALUE"].ToString();
            string time = null;
            if ("1".Equals(value))
            {
                time = ",json_build_object('itemNo',2 , 'itemName','治療開始時刻')";
            }
            string schedule = string.Format(templeteJBOSql, $"'component', 'schedule','subCategoryNo', 3,'subCategoryItem', json_build_array(VARIADIC ARRAY[json_build_object('itemNo',1 , 'itemName','クール') {time},json_build_object('itemNo',3 , 'itemName','ベッド')]),'subCategoryName', 'スケジュール'");
            string medicine = string.Format(templeteJBOSql, "'component', 'medicine','subCategoryNo', 5,'subCategoryItem', json_build_array(VARIADIC ARRAY[json_build_object('itemNo',1 , 'itemName','投与薬剤(数量+単位)')]),'subCategoryName', '投与薬剤'");
            string equipment = string.Format(templeteJBOSql, "'component', 'equipment','subCategoryNo', 6,'subCategoryItem', json_build_array(VARIADIC ARRAY[json_build_object('itemNo',1 , 'itemName','医療材料')]),'subCategoryName', '医療材料'");
            string comment = string.Format(templeteJBOSql, "'component', 'ind-comment','subCategoryNo', 7,'subCategoryItem', json_build_array(VARIADIC ARRAY[json_build_object('itemNo',1 , 'itemName','指示コメント')]),'subCategoryName', '指示コメント'");

            List<string> subCategoryItem = new List<string>();
            foreach (List<JsonElement> jsonElementList in jsonElementListList)
            {

                string itemNo = jsonElementList.FirstOrDefault(e => e.keyName == "\"itemNo\"").value.ToString();
                string itemName = jsonElementList.FirstOrDefault(e => e.keyName == "\"itemName\"").value.ToString();
                string condJsonList = string.Format(templeteJBOSql, $"'itemNo',{itemNo},'itemName', '{itemName}'");
                subCategoryItem.Add(condJsonList);
            }
            string cond = null;
            if (subCategoryItem.Count > 0)
            {
                string condJson = string.Join(",", subCategoryItem.ToList());
                cond = string.Format(templeteJBOSql, $"'component', 'treat-cond','subCategoryNo', 4,'subCategoryItem', json_build_array(VARIADIC ARRAY[{condJson}]),'subCategoryName', '治療条件'");
            }
            string contents = string.Format(templeteJBOSql, $"'component', 'treatment-contents','categoryNo', 1,'categoryItem', json_build_array(VARIADIC ARRAY[{plan},{method},{schedule},{cond},{medicine},{equipment},{comment}]),'categoryName', '治療情報'");
            return string.Format(templeteJBASql, contents);
        }


        private static void BuildWeight(HashSet<string> targetValues, IEnumerable<IGrouping<object, List<ConvertCommon.ConvertBase.JsonElement>>> groupedByGraphNo, ref List<Tuple<int, string>> sortedList)
        {

            var groupedByWeight = groupedByGraphNo.Where(g => g.Key != null && targetValues.Contains(g.Key));

            string dispItemInfoItem = "";
            foreach (var group in groupedByWeight)
            {
                var firstInnerList = group.FirstOrDefault();
                string graph_kind = firstInnerList.FirstOrDefault(e => e.keyName == "\"graph_kind\"").value.ToString();

                if (!graph_kind.Equals("0"))
                {
                    continue;
                }
                var categoryNo = firstInnerList.FirstOrDefault(e => e.keyName == "\"categoryNo\"").value;
                var categoryName = firstInnerList.FirstOrDefault(e => e.keyName == "\"categoryName\"").value;
                dispItemInfoItem = string.Format(templeteJBOSql, $"'component', 'weight','categoryNo', {categoryNo},'categoryItem', json_build_array(VARIADIC ARRAY[{{0}}]),'categoryName', '{categoryName}'");
                List<string> subCategoryItems = new List<string>();
                var graphMax = firstInnerList.FirstOrDefault(e => e.keyName == "\"graphMax\"").value;
                var graphMin = firstInnerList.FirstOrDefault(e => e.keyName == "\"graphMin\"").value;
                var lastInnerList = group.LastOrDefault();
                var graphMaxLast = lastInnerList.FirstOrDefault(e => e.keyName == "\"graphMax\"").value;
                var graphMinLast = lastInnerList.FirstOrDefault(e => e.keyName == "\"graphMin\"").value;
                int sNo = int.Parse(firstInnerList.FirstOrDefault(e => e.keyName == "\"No\"").value.ToString());

                string sWeight = $"json_build_object('graphMax', {graphMax},'graphMin', {graphMin},'component', 'weight','drugStatus', '指示','subCategoryNo', 1,'subCategoryItem', json_build_array(VARIADIC ARRAY[{{0}}]),'subCategoryName', '体重グラフ①','treatmentStatus', '指示','inspectionStatus', '結果')" +
                    $",json_build_object('graphMax', {graphMaxLast},'graphMin', {graphMinLast},'component', 'weight','drugStatus', '指示','subCategoryNo', 2,'subCategoryItem', json_build_array(VARIADIC ARRAY[{{1}}]),'subCategoryName', '体重グラフ②','treatmentStatus', '指示','inspectionStatus', '結果')";
                List<string> categoryItem = new List<string>();
                string lastValue = "";
                foreach (var innerList in group)
                {
                    List<string> subCategoryItem = new List<string>();
                    foreach (var key in CommonConstants.SUBCATEGORYITEM)
                    {
                        if (key.Equals("itemNo") || key.Equals("itemName") || key.Equals("itemColor") || key.Equals("itemPoint"))
                        {
                            var element = innerList.FirstOrDefault(e => e.keyName == "\"" + key.ToString() + "\"");
                            string value = MakeColumnSpecialFormat(null, null, element?.value?.ToString(), SpecialColumnType.SQL_STRING, true);
                            if (key.Equals("itemColor"))
                            {
                                value = NegativeToHexString(value);
                            }
                            subCategoryItem.Add($"'{key}', '{value}'");

                        }
                    }

                    if (categoryItem.Count < 3)
                    {

                        categoryItem.Add(string.Format(templeteJBOSql, string.Join(",", subCategoryItem.ToArray())));
                    }
                    else
                    {
                        lastValue = string.Format(templeteJBOSql, string.Join(",", subCategoryItem.ToArray()));

                    }
                }
                sWeight = string.Format(sWeight, string.Join(",", categoryItem.ToArray()), lastValue);

                sortedList.Add(Tuple.Create(sNo, string.Format(dispItemInfoItem, sWeight)));
            }


        }

        private static void BuildCATEGORYITEM(string componentElement, List<JsonElement> innerList, ref List<string> categoryItem)
        {

            foreach (var key in CommonConstants.CATEGORYITEM)
            {

                //薬剤グラフ
                if (componentElement.Equals("drug-graph"))
                {
                    if (key.Equals("treatmentStatus") || key.Equals("inspectionStatus"))
                    {
                        continue;
                    }

                }
                if (!componentElement.Equals("drug-graph") && key.Equals("summaryDate"))
                {
                    continue;

                }
                string skey = "\"" + key.ToString() + "\"";
                var element = innerList.FirstOrDefault(e => e.keyName == skey);
                string value = value = element?.value?.ToString();
                if (key.Equals("component"))
                {
                    value = componentElement;
                }
                else if (key.Equals("subCategoryItem"))
                {

                    value = templeteJBASql;
                }
                else if (key.Equals("summaryDate"))
                {

                    value = "none";
                }
                else if (key.Equals("subCategoryNo"))
                {

                    value = (int.Parse(value) + 1).ToString();
                }
                else
                {

                    value = MakeColumnSpecialFormat(null, null, element?.value?.ToString(), SpecialColumnType.SQL_STRING, true);

                }
                if (key.Equals("graphMax") || key.Equals("graphMin"))
                {

                    if (string.IsNullOrEmpty(value) || value.Equals("null"))
                    {
                        value = "0";
                    }

                    if (componentElement.Equals("exam-result"))
                    {
                        if (key.Equals("graphMax"))
                        {
                            categoryItem.Add($"'max', {value}");
                        }
                        else if (key.Equals("graphMin"))
                        {
                            categoryItem.Add($"'min', {value}");
                        }
                    }
                    else
                    {
                        categoryItem.Add($"'{key}', {value}");
                    }

                }
                else
                {

                    if (key.Equals("subCategoryItem") || key.Equals("subCategoryNo"))
                    {
                        categoryItem.Add($"'{key}', {value}");
                    }
                    else
                    {
                        categoryItem.Add($"'{key}', '{value}'");
                    }
                }

            }

        }

        private static void HandleDrugGraph(
                string key,
                string value,
                List<JsonElement> innerList,
                List<string> subCategoryItem)
        {
            switch (key)
            {
                case "itemDate":
                    subCategoryItem.Add($"'{key}', 'none'");
                    break;

                case "itemColor":
                    subCategoryItem.Add($"'{key}', '{NegativeToHexString(value)}'");
                    break;

                case "itemNo":
                    string med_kbn = innerList.FirstOrDefault(e => e.keyName == "\"med_kbn\"")?.value?.ToString();
                    string graph = innerList.FirstOrDefault(e => e.keyName == "\"graph\"")?.value?.ToString();
                    value = getSubquerySql("4", value, med_kbn, graph);
                    subCategoryItem.Add($"'{key}', {value}");
                    break;

                case "graph":
                case "itemName":
                    AddNormalString(key, value, subCategoryItem);
                    break;
            }
        }
        private static void AddNormalString(string key, string value, List<string> subCategoryItem)
        {
            var formatted = MakeColumnSpecialFormat(null, null, value, SpecialColumnType.NORMAL_STRING, true);
            subCategoryItem.Add($"'{key}', {formatted}");
        }

        private static void HandleWeight(
            string key,
            string value,
            List<string> subCategoryItem)
        {
            switch (key)
            {
                case "itemColor":
                    subCategoryItem.Add($"'{key}', '{NegativeToHexString(value)}'");
                    break;

                case "itemNo":
                case "itemPoint":
                case "itemName":
                    AddNormalString(key, value, subCategoryItem);
                    break;
            }
        }
        private static void HandleExamResult(
                string key,
                string value,
                List<string> subCategoryItem)
        {
            switch (key)
            {
                case "itemNo":
                    subCategoryItem.Add($"'{key}', {getSubquerySql("2", value, "", "")}");
                    break;
                case "itemExamClass":
                    subCategoryItem.Add($"'{key}', {value}");
                    break;

                case "itemColor":
                    subCategoryItem.Add($"'{key}', '{NegativeToHexString(value)}'");
                    break;

                case "itemName":
                case "itemPoint":
                    AddNormalString(key, value, subCategoryItem);
                    break;
            }


            if (key.Equals("itemNo") || key.Equals("itemName") || key.Equals("itemColor") || key.Equals("itemPoint") || key.Equals("itemExamClass"))
            {
                if (key.Equals("itemDate"))
                {
                    value = "none";
                    
                }
                else if (key.Equals("itemNo"))
                {
                }
                else if (key.Equals("itemExamClass"))
                {

                    
                }
                else if (key.Equals("itemColor"))
                {
                    
                }
                else
                {
                    value = MakeColumnSpecialFormat(null, null, value, SpecialColumnType.NORMAL_STRING, true);
                    subCategoryItem.Add($"'{key}', {value}");
                }

            }
        }
        private static void BuildSUBCATEGORYITEM(string componentElement, List<JsonElement> innerList, ref List<string> subCategoryItem)
        {

            foreach (var key in CommonConstants.SUBCATEGORYITEM)
            {
                string skey = "\"" + key.ToString() + "\"";
                var element = innerList.FirstOrDefault(e => e.keyName == skey);
                string value = element?.value?.ToString();
                switch (componentElement)
                {

                    case "drug-graph":
                          
                        HandleDrugGraph(key,value,innerList,subCategoryItem);
                        break;

                    case "weight":

                        HandleWeight(key, value, subCategoryItem);
                        break;

                    case "exam-result":

                        HandleExamResult(key, value, subCategoryItem);
                        break;

                    case "comprehensive":
                        if (key.Equals("itemDate") || key.Equals("graph") || key.Equals("itemNo") || key.Equals("itemName") || key.Equals("itemColor") || key.Equals("itemPoint") || key.Equals("itemDivision") || key.Equals("itemExamClass"))
                        {
                            if (key.Equals("itemExamClass") || key.Equals("itemDivision") || key.Equals("graph") || key.Equals("itemPoint"))
                            {
                                if (string.IsNullOrEmpty(value) || value.Equals("null"))
                                {
                                    continue;
                                }
                                else
                                {

                                    if (key.Equals("graph") || key.Equals("itemPoint"))
                                    {
                                        subCategoryItem.Add($"'{key}', '{value}'");
                                    }
                                    else
                                    {
                                        subCategoryItem.Add($"'{key}', {value}");
                                    }

                                }
                            }
                            else if (key.Equals("itemDate"))
                            {
                                if (subCategoryItem.Any(item => item.Contains("graph")))
                                {
                                    subCategoryItem.Add($"'{key}', 'none'");
                                }

                            }
                            else if (key.Equals("itemColor"))
                            {
                                value = NegativeToHexString(value);
                                subCategoryItem.Add($"'{key}', '{value}'");
                            }
                            else if (key.Equals("itemNo"))
                            {
                                string med_kbn = innerList.FirstOrDefault(e => e.keyName == "\"med_kbn\"")?.value?.ToString();
                                string graph = innerList.FirstOrDefault(e => e.keyName == "\"graph\"")?.value?.ToString();
                                string itemDivision = innerList.FirstOrDefault(e => e.keyName == "\"itemDivision\"")?.value?.ToString();
                                value = getSubquerySql(itemDivision, value, med_kbn, graph);
                                subCategoryItem.Add($"'{key}', {value}");
                            }
                            else
                            {
                                value = MakeColumnSpecialFormat(null, null, value, SpecialColumnType.NORMAL_STRING, true);
                                subCategoryItem.Add($"'{key}', {value}");
                            }
                        }
                        break;
                }

            }
        }
        private static void BuildOther(HashSet<string> targetValues, IEnumerable<IGrouping<object, List<ConvertCommon.ConvertBase.JsonElement>>> groupedByGraphNo, ref List<Tuple<int, string>> sortedList)
        {

            string dispItemInfoItem = "";
            var groupedByOther = groupedByGraphNo.Where(g => g.Key != null && !targetValues.Contains(g.Key));
            foreach (var group in groupedByGraphNo)
            {
                var firstInnerList = group.FirstOrDefault();
                string graph_kind = firstInnerList.FirstOrDefault(e => e.keyName == "\"graph_kind\"").value.ToString();

                if (graph_kind.Equals("0"))
                {
                    continue;
                }
                string componentElement = firstInnerList.FirstOrDefault(e => e.keyName == "\"component\"").value.ToString();
                var categoryNo = firstInnerList.FirstOrDefault(e => e.keyName == "\"categoryNo\"").value;
                var categoryName = firstInnerList.FirstOrDefault(e => e.keyName == "\"categoryName\"").value;
                int sNo = int.Parse(firstInnerList.FirstOrDefault(e => e.keyName == "\"No\"").value.ToString());
                List<string> dispItemInfoItemList = new List<string>();

                dispItemInfoItem = $"'component', '{componentElement}','categoryNo', {categoryNo},'categoryItem', json_build_array(VARIADIC ARRAY[{{0}}]),'categoryName', '{categoryName}'";
                dispItemInfoItem = string.Format(templeteJBOSql, dispItemInfoItem);


                if (componentElement.Equals("medicationSupport"))
                {
                    sortedList.Add(Tuple.Create(sNo, $"json_build_object('component', 'medicationSupport', 'categoryNo', 1028, 'categoryItem', json_build_array(json_build_object('component', 'medicationSupport', 'subCategoryNo', 1, 'subCategoryItem', json_build_array(json_build_object('itemNo', 1, 'itemName', '投薬支援マスタ対象', 'itemColor', '#000000', 'itemPoint', 'triangle')), 'subCategoryName', '投薬支援マスタ対象')), 'categoryName', '投薬支援マスタ対象', 'medicineGroupCd', (select medicine_support_cd from mst_medicine_support where fn_medicine_support_cd = '{firstInnerList.FirstOrDefault(e => e.keyName == "\"itemNo\"").value?.ToString()}' and facility_cd = '{CommonConfig.FacilityCd}'))"));
                    break;
                }


                foreach (var innerList in group)
                {
                    List<string> categoryItem = new List<string>();
                    List<string> subCategoryItem = new List<string>();

                    BuildCATEGORYITEM(componentElement, innerList, ref categoryItem);
                    string scategoryItem = string.Format(templeteJBOSql, string.Join(",", categoryItem.ToArray()));


                    BuildSUBCATEGORYITEM(componentElement, innerList, ref subCategoryItem);
                    string subCategoryItems = string.Format(templeteJBOSql, string.Join(",", subCategoryItem.ToArray()));
                    scategoryItem = string.Format(scategoryItem, subCategoryItems);
                    dispItemInfoItemList.Add(scategoryItem);
                }
                sortedList.Add(Tuple.Create(sNo, string.Format(dispItemInfoItem, string.Join(",", dispItemInfoItemList.ToArray()))));

            }

        }


        private static string LongJsonDisItemInfo(List<List<JsonElement>> jsonElementListList)
        {
            var targetValues = new HashSet<string> { "1006", "1007", "1020", "1021" };
            var groupedByGraphNo = jsonElementListList
                .GroupBy(
                    innerList => innerList.FirstOrDefault(e => e.keyName == "\"categoryNo\"")?.value,
                    innerList => innerList
                )
                .Where(g => g.Key != null);
            var sortedList = new List<Tuple<int, string>>();
            //weight
            BuildWeight(targetValues, groupedByGraphNo, ref sortedList);

            //その他
            BuildOther(targetValues, groupedByGraphNo, ref sortedList);


            return string.Format(templeteJBASql, string.Join(",", sortedList.OrderBy(x => x.Item1).Select(x => x.Item2).ToArray()));


        }
        public static string BuildJsonDisItemInfo(List<List<JsonElement>> jsonElementListList, string fnwTableName)
        {


            //add #12339 start
            if (fnwTableName.Equals("SYS_ACTCHART_DEFINE"))
            {
                return ShortJsonDisItemInfo(jsonElementListList);

            }
            //add #12339 end

            //長期
            return LongJsonDisItemInfo(jsonElementListList);

        }



        public static string BuildJsonManyArray(string ntssColumnName,
                                          List<List<JsonElement>> jsonElementListList,
                                          ConvertValueInfoBase simpleConvertValueInfo,
                                          Dictionary<string, string> fkConvertSqlMap,
                                          Dictionary<string, string> customCovertValueSqlMap,
                                          NtssRecord ntssRecord, string convertTableName)
        {

            string sql = "";
            int i = 0;
            List<string> jboSqlList = new List<string>();
            foreach (List<JsonElement> jsonElementList in jsonElementListList)
            {

                sql = string.Join(",", jsonElementList.Where(je => je.sqlCreationExclusionFlg == false).Select(je =>
                {
                    // add #10776 表示順取得 ls start
                    if (je.keyName == ('"' + "Rp" + '"'))
                    {
                        je.value = i + 1;
                    }
                    // add #10776 表示順取得 ls end
                    string value = getSqlStatement(ntssColumnName + je.getKeyNameDeleteEscape(),
                                                    je,
                                                    simpleConvertValueInfo,
                                                    fkConvertSqlMap,
                                                    customCovertValueSqlMap,
                                                    ntssRecord,
                                                    jsonElementList,
                                                    false, convertTableName);

                    return "'" + je.getKeyNameDeleteEscape() + "'," + value;

                }).ToArray());
                List<JsonElement> jsonElementList1 = new List<JsonElement>();
                foreach (JsonElement item in jsonElementList)
                {
                    item.keyName = item.keyName.Replace(@"""", "");
                    if (item.keyName.Equals("R_2"))
                    {
                        item.keyName = "R";
                        jsonElementList1.Add(item);
                    }
                    else if (item.keyName.Equals("F1_2"))
                    {
                        item.keyName = "F1";
                        jsonElementList1.Add(item);
                    }
                    else if (item.keyName.Equals("F2_2"))
                    {
                        item.keyName = "F2";
                        jsonElementList1.Add(item);
                    }
                    else if (item.keyName.Equals("F5_2"))
                    {
                        item.keyName = "F5";
                        jsonElementList1.Add(item);
                    }
                    else if (item.keyName.Equals("F6_2"))
                    {
                        item.keyName = "F6";
                        jsonElementList1.Add(item);
                    }
                    else if (item.keyName.Equals("type"))
                    {
                        item.value = 2;
                        jsonElementList1.Add(item);
                    }
                    else if (item.keyName.Equals("Rp"))
                    {
                        jsonElementList1.Add(item);
                    }
                    else if (item.keyName.Equals("F3"))
                    {
                        item.value = "";
                        jsonElementList1.Add(item);
                    }
                    else if (item.keyName.Equals("F4"))
                    {
                        item.value = "";
                        jsonElementList1.Add(item);
                    }
                    else if (item.keyName.Equals("unchg"))
                    {
                        item.value = "";
                        jsonElementList1.Add(item);
                    }
                    else if (item.keyName.Equals("medicine_unit1"))
                    {
                        item.value = "";
                        jsonElementList1.Add(item);
                    }
                    else if (item.keyName.Equals("medicine_unit2"))
                    {
                        item.value = "";
                        jsonElementList1.Add(item);
                    }
                    else if (item.keyName.Equals("F7"))
                    {
                        item.value = "1";
                        jsonElementList1.Add(item);
                    }
                }
                // 
                jsonElementList1.Add(new JsonElement { keyName = "sub_no", value = "1" });

                string sql1 = string.Join(",", jsonElementList1.Select(je =>
                {
                    // add #10776 表示順取得 ls start
                    if (je.keyName == ('"' + "Rp" + '"'))
                    {
                        je.value = i + 1;
                    }
                    // add #10776 表示順取得 ls end
                    string value = getSqlStatementValue(je);
                    return "'" + je.getKeyNameDeleteEscape() + "'," + value;

                }).ToArray());

                //add 7271 zc start
                sql = sql.Replace("null", "''");
                sql1 = sql1.Replace("null", "''");
                //add 7271 zc end
                jboSqlList.Add(string.Format(templeteJBOSql, sql));
                jboSqlList.Add(string.Format(templeteJBOSql, sql1));

                i++;
            }
            jboSqlList.Add(string.Format(templeteJBOSql, "'R','────────以下、余白─────────', 'F1', '', 'F2','', 'F3','', 'F4','', 'F5','', 'F6','', 'Rp','', 'sub_no','', 'type','E', 'unchg','', 'medicine_cd','', 'medicine_type',''"));
            return string.Format(templeteJBASql, string.Join(",", jboSqlList.ToArray()));

        }




        public static string BuildJsonArray(string ntssColumnName,
                                          List<List<JsonElement>> jsonElementListList,
                                          ConvertValueInfoBase simpleConvertValueInfo,
                                          Dictionary<string, string> fkConvertSqlMap,
                                          Dictionary<string, string> customCovertValueSqlMap,
                                          NtssRecord ntssRecord, string convertTableName)
        {

            string sql = "";
            List<string> jboSqlList = new List<string>();
            foreach (List<JsonElement> jsonElementList in jsonElementListList)
            {


                if (CommonConstants.JSON_NO_KEY.ContainsKey(convertTableName + "-" + ntssColumnName))
                {
                    string jsonKey = CommonConstants.JSON_NO_KEY[convertTableName + "-" + ntssColumnName];
                    var validSqlParts = jsonElementList.Where(je => je.sqlCreationExclusionFlg == false).Select(je =>
                    {
                        string value = getSqlStatement(ntssColumnName + je.getKeyNameDeleteEscape(),
                                                        je,
                                                        simpleConvertValueInfo,
                                                        fkConvertSqlMap,
                                                        customCovertValueSqlMap,
                                                        ntssRecord,
                                                        jsonElementList,
                                                        false, convertTableName);
                        if (je.getKeyNameDeleteEscape() == jsonKey && value == "null")
                        {
                            return null;
                        }
                        return $"'{je.getKeyNameDeleteEscape()}',{value}";
                    }).Where(part => part != null).ToArray();

                    if (validSqlParts.Any())
                    {
                        sql = string.Join(",", validSqlParts);
                    }
                } //add 11749 end
                else
                {
                    sql = string.Join(",", jsonElementList.Where(je => je.sqlCreationExclusionFlg == false).Select(je =>
                    {
                        string value = getSqlStatement(ntssColumnName + je.getKeyNameDeleteEscape(),
                                                        je,
                                                        simpleConvertValueInfo,
                                                        fkConvertSqlMap,
                                                        customCovertValueSqlMap,
                                                        ntssRecord,
                                                        jsonElementList,
                                                        false, convertTableName);
                        return "'" + je.getKeyNameDeleteEscape() + "'," + value;
                    }).ToArray());
                }

                jboSqlList.Add(string.Format(templeteJBOSql, sql));
            }
            if (ntssColumnName.Equals("type_info") && convertTableName.Equals("mst_mainte_layout") && ntssRecord.columns.Where(col => col.name.Equals("layout_class")).First().value.ToString().Equals("2"))
            {

                return string.Format(templeteCJBASql, "'" + ntssRecord.columns.Where(col => col.name.Equals("machine_type_cd")).First().value.ToString() + "'," + string.Join(",", jboSqlList.ToArray()));
            }


            return string.Format(templeteJBASql, string.Join(",", jboSqlList.ToArray()));


        }




        public static string BuildJsonNest(string ntssColumnName,
                                          List<List<JsonElement>> jsonElementListList,
                                          ConvertValueInfoBase simpleConvertValueInfo,
                                          Dictionary<string, string> fkConvertSqlMap,
                                          Dictionary<string, string> customCovertValueSqlMap,
                                          NtssRecord ntssRecord, string convertTableName)
        {
            string sql = "";
            List<string> jboSqlList = new List<string>();

            string parentKey = null;
            List<string> mediTypeList = new List<string> { "15", "19", "25" };
            foreach (List<JsonElement> jsonElementList in jsonElementListList)
            {

                // JSONキー名がkeyのものを親キーとして使用する
                // mod #10025 FNWで生成された治療予定が正常にコンバートされていない zkm start
                sql = string.Join(",", jsonElementList.Where(je => je.sqlCreationExclusionFlg == false).Select(je =>
                // mod #10025 FNWで生成された治療予定が正常にコンバートされていない zkm end
                {
                    // ind_cond_info.value_name_2 5番だけ残します
                    if (je.getKeyNameDeleteEscape().Equals("value_name_2"))
                    {
                        JsonElement js = jsonElementList.Find(s => s.getKeyNameDeleteEscape() == "key");
                        if (js != null && js.value.ToString() != "5")
                        {
                            return "";
                        }
                    }

                    // 薬剤フラグセット(項目番号「011」、「018」、「022」のみ)
                    // ind_cond_info.medicine_type 薬剤フラグセットだけ残します
                    if (listConvMedicineTypeTbl.Contains(convertTableName) && listConvMedicineTypeField.Contains(ntssColumnName) && je.getKeyNameDeleteEscape().Equals("medicine_type"))
                    {
                        JsonElement js = jsonElementList.Find(s => s.getKeyNameDeleteEscape() == "key");
                        if (!mediTypeList.Contains(js.getValueDeleteEscape()))
                        {
                            return "";
                        }
                    }

                    string value;
                    if (je.getKeyNameDeleteEscape().Equals("key"))
                    {
                        // キー項目の退避
                        //parentKey = je.getValueDeleteEscape();
                        parentKey = getSqlStatement(ntssColumnName + je.getKeyNameDeleteEscape(),
                                                    je,
                                                    simpleConvertValueInfo,
                                                    fkConvertSqlMap,
                                                    customCovertValueSqlMap,
                                                    ntssRecord,
                                                    jsonElementList,
                                                    true, convertTableName);
                        if (!je.getValueDeleteEscape().Equals("parentKey"))
                        {

                        }
                        return "";
                    }
                    else
                    {
                        // add #9686 指示コンバートで終了日ありにも関わらずそれ以降も延長されている zkm start
                        if (convertTableName.Equals("ord_main") && "ind_cond_info".Equals(ntssColumnName) && je.getKeyNameDeleteEscape().Equals("unit"))
                        {
                            string key = jsonElementList.FirstOrDefault(json => "key".Equals(json.getKeyNameDeleteEscape())).getValueDeleteEscape();
                            string convUnitVal = null;
                            if (UnitConvByCtlNoList.ContainsKey(key))
                            {
                                convUnitVal = UnitConvByCtlNoList[key];
                                if ("COND".Equals(convUnitVal))
                                {
                                    convUnitVal = getSqlStatement(ntssColumnName + je.getKeyNameDeleteEscape(),
                                                        je,
                                                        simpleConvertValueInfo,
                                                        fkConvertSqlMap,
                                                        customCovertValueSqlMap,
                                                        ntssRecord,
                                                        jsonElementList,
                                                        false, convertTableName);
                                }
                                else
                                {
                                    convUnitVal = convUnitVal == null ? "null" : "'" + convUnitVal + "'";
                                }
                            }
                            value = convUnitVal;
                        }
                        else if (convertTableName.Equals("ord_main") && "ind_cond_info".Equals(ntssColumnName) && je.getKeyNameDeleteEscape().Equals("value_name_1"))
                        {
                            string key = jsonElementList.FirstOrDefault(json => "key".Equals(json.getKeyNameDeleteEscape())).getValueDeleteEscape();
                            string jsonValue = jsonElementList.FirstOrDefault(json => "value".Equals(json.getKeyNameDeleteEscape())).getValueDeleteEscape();
                            string convNameVal = null;
                            if (ValueNameConvByCtlNoList.ContainsKey(key))
                            {
                                convNameVal = ValueNameConvByCtlNoList[key];
                                if ("COND".Equals(convNameVal))
                                {
                                    convNameVal = getSqlStatement(ntssColumnName + je.getKeyNameDeleteEscape(),
                                                        je,
                                                        simpleConvertValueInfo,
                                                        fkConvertSqlMap,
                                                        customCovertValueSqlMap,
                                                        ntssRecord,
                                                        jsonElementList,
                                                        false, convertTableName);
                                }
                                else if ("CONVERT".Equals(convNameVal))
                                {
                                    string valTemp = jsonValue;
                                    if (!"0".Equals(jsonValue) && !"1".Equals(jsonValue))
                                    {
                                        valTemp = "2";
                                    }
                                    convNameVal = ValueNameConvertList[key][valTemp];
                                    convNameVal = convNameVal == null ? "null" : "'" + convNameVal + "'";
                                }
                                else
                                {
                                    convNameVal = convNameVal == null ? "null" : "'" + convNameVal + "'";
                                }
                            }
                            value = convNameVal;
                        }
                        else
                        {

                            // add #9686 指示コンバートで終了日ありにも関わらずそれ以降も延長されている zkm end
                            value = getSqlStatement(ntssColumnName + je.getKeyNameDeleteEscape(),
                                                        je,
                                                        simpleConvertValueInfo,
                                                        fkConvertSqlMap,
                                                        customCovertValueSqlMap,
                                                        ntssRecord,
                                                        jsonElementList,
                                                        false, convertTableName);
                        }
                    }
                    return "'" + je.getKeyNameDeleteEscape() + "'," + value;
                }).Where(value => !value.Equals("")).ToArray());

                jboSqlList.Add(string.Format(templeteJBOWithKeyUseFkSql, parentKey, sql));
            }
            return string.Format(templeteJBOSql, string.Join(",", jboSqlList.ToArray()));



        }


        //add 7271  zc  start
        private static string getSqlStatementValue(JsonElement je)
        {
            string formatValue = FormatJsonValueByValueType(je);
            // 改行コード対応
            // mod #10191 djy start
            return MakeColumnSpecialFormat(null, null, formatValue, SpecialColumnType.SQL_STRING, true);
            // mod #10191 djy end
        }
        //add 7271  zc  end
        /// <summary>
        /// 値変換対象または外部キー取得対象の項目か判定し、該当する場合は
        /// SQL文に変換して返す
        /// </summary>
        /// <param name="key">マップを検索するキー（列名+","+JSON項目名）</param>
        /// <param name="replaceValue">該当する場合に置換変数に埋め込む値</param>
        /// <param name="simpleConvertValueInfo">Case文SQLまたは値変換情報</param>
        /// <param name="fkConvertSqlMap">外部キー変換マップ（キー：列名+","+JSON項目名、値：外部キーを取得するSELECT文）</param>
        /// <param name="customCovertValueSqlMap">カスタム値変換マップ</param>
        /// <param name="ntssRecord">カスタム値変換マップの置換文字列置換用の１レコード</param>
        /// <param name="isJsonNest">JSONが入れ子の場合の固有処理フラグ</param>
        /// <returns></returns>
        private static string getSqlStatement(string key,
                                JsonElement je,
                                ConvertValueInfoBase simpleConvertValueInfo,
                                Dictionary<string, string> fkConvertSqlMap,
                                Dictionary<string, string> customCovertValueSqlMap,
                                NtssRecord ntssRecord,
                                List<JsonElement> jsonElementList,
                                bool isJsonNest, string convertTableName)
        {
            // 値変換対象かチェック
            if (simpleConvertValueInfo.ContainsKey(key))
            {
                // 値変換対象の場合、値をSQL文に置き換え、変換値内の置換変数を設定
                string convertValue = simpleConvertValueInfo.GetConvertValue(key, je.getValueDeleteEscape(), ntssRecord, jsonElementList);
                return ReplaceSubstitutionVariablesToColumnValue(convertValue, ntssRecord, jsonElementList, true, convertTableName);
            }
            // add 7619 コンバートされた施設で掲示板が１件も表示されない  李 start
            int flag = 0;
            foreach (var fkConvert in fkConvertSqlMap)
            {
                if (fkConvert.Key.Contains(key) && key.Equals("pat_info_detail"))
                {
                    flag = 1;
                    break;
                }
                else if (fkConvert.Key.Contains(key) && key.Equals("staff_info_detail"))
                {
                    flag = 2;
                    break;
                }

            }

            // 外部キー取得対象かチェック
            if (fkConvertSqlMap.ContainsKey(key) || flag != 0)
            {
                // 外部キー取得対象の場合、値をSQL文に置き換え
                if (flag == 1)
                {
                    return string.Format(
                    fkConvertSqlMap["pat_info_detailpat_id"],
                    je.getValueDeleteEscape()
                    );
                }
                else if (flag == 2)
                {
                    return string.Format(
                    fkConvertSqlMap["staff_info_detailstaff_cd"],
                    je.getValueDeleteEscape()
                    );
                }
                else
                {
                    return string.Format(
                    fkConvertSqlMap[key],
                    je.getValueDeleteEscape()
                    );
                }

            }
            // add 7619 コンバートされた施設で掲示板が１件も表示されない  李 end
            // カスタム値変換対象かチェック
            if (customCovertValueSqlMap.ContainsKey(key))
            {
                // 外部キー取得対象の場合、値をSQL文に置き換え、置換文字列をカラムの値、JSONの値に置換する
                string sql = customCovertValueSqlMap[key];
                sql = ReplaceSubstitutionVariablesToColumnValue(sql, ntssRecord, jsonElementList, false, convertTableName);
                return sql;
            }
            // add FNSI-FN本体_データマッピング (進捗管理更新) supply_coop対応 楊 start
            if ("addition_infodummy".Equals(key))
            {
                return null;
            }
            // add FNSI-FN本体_データマッピング (進捗管理更新) supply_coop対応 楊 end
            // JSONがネストのときは値を整形せずそのまま返す
            if (isJsonNest)
            {
                return je.getValueDeleteEscape();
            }
            else
            {
                string formatValue = FormatJsonValueByValueType(je);
                // 改行コード対応
                // mod #10191 djy start
                return MakeColumnSpecialFormat(null, null, formatValue, SpecialColumnType.SQL_STRING, true);
                // mod #10191 djy end
            }
        }


        private static string FormatJsonValueByValueType(JsonElement je)
        {
            // データ型に合わせて値を整形
            if (je.getValueDeleteEscape().Equals("null"))
            {
                // 空はnull
                return "null";
            }
            else if (je.jsonValueType == NTSS_DATA_TYPE_SMALLINT ||
                     je.jsonValueType == NTSS_DATA_TYPE_INTEGER ||
                     je.jsonValueType == NTSS_DATA_TYPE_BIGINT ||
                     je.jsonValueType == NTSS_DATA_TYPE_NUMERIC ||
                     je.jsonValueType == NTSS_DATA_TYPE_NUMBER)
            {
                if (je.getValueDeleteEscape().Length >= 2 &&
                    je.getValueDeleteEscape().Substring(0, 1).Equals("0"))
                {
                    // SQL→CSV形式でのコード変換時、コード変換前とコード変換後の型不一致対応
                    // ２文字以上で１文字目が0の場合、文字列として扱う
                    // mod #10191 djy start
                    return string.Format("'{0}'", je.getValueDeleteEscape());
                    // mod #10191 djy end
                }
                else
                {
                    //// 数値はそのまま(""で囲まない)
                    return je.getValueDeleteEscape();
                }
            }
            // add FNSI-exam_dateフォーマット対応 楊 start
            //else if (je.jsonValueType == "yyyyMMddHHmmss" || je.jsonValueType == "yyyyMMdd")
            else if (je.jsonValueType == "yyyyMMddHHmmss" || je.jsonValueType == "yyyyMMdd" || je.jsonValueType == "yyyy-MM-ddTHH:mm:sszzz" || je.jsonValueType == "yyyy-MM-ddTHH:mm:ss.fffzzz")
            // add FNSI-exam_dateフォーマット対応 楊 end
            {
                // 日付型はフォーマット
                var date = GetFormatedDate(je.getValueDeleteEscape());
                if (date == null)
                {
                    string errMsg = "JSON要素の値の日付型変換に失敗しました。key:" + je.getKeyNameDeleteEscape() + " value:" + je.getValueDeleteEscape();
                    WriteErrorLog(errMsg);
                    throw new Exception(errMsg);
                }
                else if (je.jsonValueType == "yyyyMMddHHmmss")
                {
                    return string.Format("'{0}'", ((DateTime)date).ToString("yyyyMMddHHmmss"));
                }
                // add FNSI-exam_dateフォーマット対応 楊 start
                //else
                else if (je.jsonValueType == "yyyyMMdd")
                // add FNSI-exam_dateフォーマット対応 楊 end
                {
                    return string.Format("'{0}'", ((DateTime)date).ToString("yyyyMMdd"));
                }
                // add FNSI-exam_dateフォーマット対応 楊 start
                else if (je.jsonValueType == "yyyy-MM-ddTHH:mm:sszzz")
                // add FNSI-exam_dateフォーマット対応 楊 end
                {
                    return string.Format("'{0}'", ((DateTime)date).ToString("yyyy-MM-ddTHH:mm:sszzz"));
                }
                else
                {
                    // ISO8601形式に変換
                    return string.Format("'{0}'", ((DateTime)date).ToString("yyyy-MM-ddTHH:mm:ss.fffzzz"));
                }
                // add FNSI-exam_dateフォーマット対応 楊 end
            }
            else if (je.jsonValueType == NTSS_DATA_TYPE_NUMBER)
            {
                // 文字列型は文字列('で囲む)(改行コード→\n、\→\\、ダブルクオーテーション→\"、タブ文字→\tに置換)
                // mod #10191 djy start
                return string.Format("'{0}'", je.getValueDeleteEscape());
                // mod #10191 djy end
            }
            else if (je.jsonValueType == NTSS_DATA_TYPE_BOOLEAN)
            {
                // booleanはそのまま(""で囲まない)
                return je.getValueDeleteEscape();
            }
            else if (je.jsonValueType == NTSS_DATA_TYPE_BOOL)
            {
                if (je.getValueDeleteEscape().Equals("1"))
                {
                    return "true";
                }
                else
                {
                    return "false";
                }

            }
            else
            {
                // 型が不明な場合は文字列型として扱う
                // mod #10191 djy start
                return string.Format("'{0}'", je.getValueDeleteEscape());
                // mod #10191 djy end
            }
        }
        /// <summary>
        /// SQLの置換変数を列の値およびJSON各キーの値に置き換える
        /// </summary>
        /// <param name="sql"></param>
        /// <param name="ntssRecord"></param>
        /// <param name="jsonElementList"></param>
        /// <param name="isNullReplacement">いずれかの置換変数がNullの場合、置換変数の置き換え処理を行わずにNullを返すか</param>
        /// <returns></returns>
        private static string ReplaceSubstitutionVariablesToColumnValue(string sql,
                                                            NtssRecord ntssRecord,
                                                            List<JsonElement> jsonElementList,
                                                            bool isNullReplacement, string convertTableName)
        {
            string replaceSql = sql;
            foreach (NtssColumn col in ntssRecord.columns)
            {
                // 置換変数が存在する場合
                if (replaceSql.Contains("{" + col.name + "}"))
                {
                    // 値がnullの項目が１つでもある場合、置換変数の置き換えを行わない
                    if (isNullReplacement && col.value == null)
                    {
                        return "null";
                    }
                    // mod #10191 djy start
                    //replaceSql = replaceSql.Replace("{" + col.name + "}", col.value.ToString());
                    replaceSql = MakeColumnSpecialFormat(replaceSql, col.name, col.value.ToString(), SpecialColumnType.SQL_STRING, true);
                    // mod #10191 djy end
                }
            }

            // JSONリストがある場合はこちらも置換する
            if (jsonElementList != null)
            {
                foreach (JsonElement e in jsonElementList)
                {
                    // 置換変数が存在する場合
                    if (replaceSql.Contains("{" + e.getKeyNameDeleteEscape() + "}"))
                    {
                        // 値がnullの項目が１つでもある場合、置換変数の置き換えを行わない
                        if (isNullReplacement && "null".Equals(e.getValueDeleteEscape()) && !(e.keyName.Contains("value_name_1") && convertTableName.Equals("ord_main")))
                        {
                            return "null";
                        }
                        // mod #10191 djy start

                        replaceSql = MakeColumnSpecialFormat(replaceSql, e.getKeyNameDeleteEscape(), e.getValueDeleteEscape().ToString(), SpecialColumnType.SQL_STRING, true);
                        // mod #10191 djy end
                    }
                }

                // add #9852 チェックリストマスタの種別：医療材料のコンバートについて zkm start
                var funcFlagRecord = jsonElementList.Where(e => e.getKeyNameDeleteEscape().StartsWith("FUNK_FLAG_") && "null" != e.getValueDeleteEscape());
                var funcFlags = string.Join(",", funcFlagRecord.Select(f => f.getValueDeleteEscape()).ToList());
                var classCdRecord = jsonElementList.Where(e => e.getKeyNameDeleteEscape().StartsWith("CLASS_CD_") && "null" != e.getValueDeleteEscape());
                var classCds = string.Join(",", classCdRecord.Select(f => f.getValueDeleteEscape()).ToList());
                if (replaceSql.Contains("{CLASS_CD_LIST}"))
                {
                    replaceSql = replaceSql.Replace("{CLASS_CD_LIST}", string.IsNullOrWhiteSpace(classCds) ? "0000" : classCds);
                }
                if (replaceSql.Contains("{FUNK_FLAG_LIST}"))
                {
                    replaceSql = replaceSql.Replace("{FUNK_FLAG_LIST}", string.IsNullOrWhiteSpace(funcFlags) ? "0000" : funcFlags);
                }
                List<string> classCdDefaultList = new List<string> { "201", "001", "002" };
                var keyRecord = classCdRecord.FirstOrDefault(cd => classCdDefaultList.Contains(cd.getValueDeleteEscape()));
                for (int i = 1; i < 11; i++)
                {
                    var classCdKey = "CLASS_CD_REPEAT_FLG_" + i;
                    if (keyRecord != null)
                    {
                        if (replaceSql.Contains("{" + classCdKey + "}"))
                        {
                            replaceSql = replaceSql.Replace("{" + classCdKey + "}", ("CLASS_CD_" + i) == keyRecord.getKeyNameDeleteEscape() ? "0" : "1");
                        }
                    }
                    else
                    {
                        if (replaceSql.Contains("{" + classCdKey + "}"))
                        {
                            replaceSql = replaceSql.Replace("{" + classCdKey + "}", "0");
                        }
                    }
                }

                // add #9852 チェックリストマスタの種別：医療材料のコンバートについて zkm end
            }
            //add 8332 zc start
            replaceSql = replaceSql.Replace("{name_3}", "");
            //add 8332 zc end


            if (sql.Equals("json_build_object('telegram_format','ST,+{0:00000.00} kg[CR][LF]')"))
            {
                return replaceSql;
            }
            // add 7406  ReMS利用施設をコンバートすると送信先グループマスタや警報通知マスタなどのデータが消えている start
            if (sql.Equals("telegram_format=json_build_object('telegram_format','ST,+{0:00000.00} kg[CR][LF]')"))
            {
                return replaceSql;
            }

            return replaceSql;
        }


        private static string NegativeToHexString(string iNumber)
        {
            if (string.IsNullOrWhiteSpace(iNumber)) return null;

            string sNumber = int.Parse(iNumber).ToString("X8");
            string strResult = "";
            if ("FF".Equals(sNumber.Substring(0, 2)))
            {
                strResult = "#" + sNumber.Substring(2);
            }
            return strResult;
        }

        private static string getSubquerySql(string itemDivision, string value, string med_kbn, string graph)
        {

            if (itemDivision.Equals("4"))
            {
                if (med_kbn.Equals("0") && graph.Equals("投薬"))
                {
                    return $"(SELECT medicine_cd FROM mst_medicine WHERE facility_cd = '{CommonConfig.FacilityCd}' AND fn_medicine_cd = '{value}')";

                }
                else if (med_kbn.Equals("1") && graph.Equals("投薬"))
                {

                    return $"(SELECT 'MEDICINE_GROUP' || CAST ( medicine_group_cd AS VARCHAR ) FROM mst_medicine_group WHERE facility_cd = '{CommonConfig.FacilityCd}' AND fn_medicine_group_cd = '{value}') ";

                }
                else if (med_kbn.Equals("2"))
                {

                    return $"( SELECT 'MEDICINE_MIX' ||CAST ( medicine_mix_cd AS VARCHAR ) FROM mst_medicine_mix WHERE facility_cd = '{CommonConfig.FacilityCd}' AND fn_set_medicine_cd :: CHARACTER VARYING = '{value}' )";

                }
                else if (med_kbn.Equals("0") && graph.Equals("処方"))
                {
                    return $"(SELECT 'MEDICINE'||CAST ( medicine_cd AS VARCHAR ) FROM mst_medicine WHERE facility_cd = '{CommonConfig.FacilityCd}' AND fn_medicine_cd = '{value}')";

                }
                else if (med_kbn.Equals("1") && graph.Equals("処方"))
                {
                    return $"(SELECT 'MEDICINE_GROUPS' || CAST ( medicine_group_cd AS VARCHAR ) FROM mst_medicine_group WHERE facility_cd = '{CommonConfig.FacilityCd}' AND fn_medicine_group_cd = '{value}')";

                }

            }
            else if (itemDivision.Equals("2"))
            {

                return $"(SELECT exam_item_cd FROM mst_exam_item WHERE facility_cd = '{CommonConfig.FacilityCd}' AND fn_exam_item_cd :: CHARACTER VARYING = '{value}')";
            }

            return $"'{value}'";
        }

        /// <summary>
        /// 日時文字列をDateTime型に変換
        /// </summary>
        /// <param name="value">日時文字列</param>
        /// <remarks>
        /// 戻り値はnull許容型なのでDateTime型にキャストすること
        /// </remarks>
        /// <returns>成功：日時、失敗：null</returns>
        private static DateTime? GetFormatedDate(string value)
        {
            DateTime? date = null;

            // フォーマットパターン
            string[] formats = {
                                   "yyyy/MM/dd HH:mm:ss",
                                   "yyyy/M/dd HH:mm:ss",
                                   "yyyy/MM/d HH:mm:ss",
                                   "yyyy/M/d HH:mm:ss",

                                   "yyyy/MM/dd H:mm:ss",
                                   "yyyy/M/dd H:mm:ss",
                                   "yyyy/MM/d H:mm:ss",
                                   "yyyy/M/d H:mm:ss",

                                   "yyyy/MM/dd HH:mm",
                                   "yyyy/M/dd HH:mm",
                                   "yyyy/MM/d HH:mm",
                                   "yyyy/M/d HH:mm",

                                   "yyyy/MM/dd H:mm",
                                   "yyyy/M/dd H:mm",
                                   "yyyy/MM/d H:mm",
                                   "yyyy/M/d H:mm",

                                   "yyyy/MM/dd",
                                   "yyyy/M/dd",
                                   "yyyy/MM/d",
                                   "yyyy/M/d",

                                   "yyyyMMddHHmmss",
                                   "yyyyMMddHHmm",
                                   "yyyyMMdd",
                                   "yyyyMM"
                               };

            var tmpDate = DateTime.MinValue;
            if (DateTime.TryParseExact(value, formats, null, 0, out tmpDate))
            {
                date = (DateTime)tmpDate;
            }
            else
            {
                WriteErrorLog("日時フォーマットに失敗しました。(値：{0})", value);
            }

            return date;
        }

        /// <summary>
        /// ファイル作成時カラム共通処理
        /// </summary>
        /// <param name="replaceSql">sql切替前</param>
        /// <param name="column">カラム名</param>
        /// <param name="value">文字列</param>
        /// <param name="columnType">カラム型</param>
        /// <param name="isSingleString">単純文字列かどうか</param>
        /// <returns>処理後の文字列</returns>
        private static string MakeColumnSpecialFormat(string replaceSql, string column, string value, SpecialColumnType columnType, bool isSingleString)
        {
            if (replaceSql == null)
            {
                if (column == null)
                {
                    switch (columnType)
                    {
                        case SpecialColumnType.SQL_STRING:
                            if (value.Contains("\\"))
                            {
                                return "E" + value;
                            }
                            return value;
                        case SpecialColumnType.NORMAL_STRING:
                            if (value.Contains("\\"))
                            {
                                return "E'" + value + "'";
                            }
                            return "'" + value + "'";
                        case SpecialColumnType.ENCRYPT_STRING:
                            if (isSingleString)
                            {
                                if (value.Contains("\\"))
                                {
                                    return "personal_info_encrypt(E'" + value.Replace("\\\\", "\\\\\\\\") + "')";
                                }
                                return "personal_info_encrypt('" + value + "')";
                            }
                            else
                            {
                                if (value.Contains("\\"))
                                {
                                    return "personal_info_encrypt(E'" + value.Replace("\\\\", "\\\\\\\\") + "::character varying)";
                                }
                                return "personal_info_encrypt(" + value + "::character varying)";
                            }
                        default:
                            return value;
                    }
                }
                else
                {
                    switch (columnType)
                    {
                        case SpecialColumnType.NORMAL_STRING:
                            if (value.Contains("\\"))
                            {
                                return column + "=E'" + value + "'";
                            }
                            return column + "='" + value + "'";
                        case SpecialColumnType.ENCRYPT_STRING:
                            if (value.Contains("\\"))
                            {
                                return column + "=personal_info_encrypt(E'" + value.Replace("\\\\", "\\\\\\\\") + "')";
                            }
                            return column + "=personal_info_encrypt('" + value + "')";
                        default:
                            return column + "='" + value + "'";
                    }

                }
            }
            else
            {
                if (value.Contains("\\"))
                {
                    if (replaceSql.Contains("personal_info_encrypt('{" + column + "}')"))
                    {
                        replaceSql = replaceSql.Replace("personal_info_encrypt('{" + column + "}')", "personal_info_encrypt(E'" + value.Replace("\\\\", "\\\\\\\\") + "')");
                    }
                    replaceSql = replaceSql.Replace("'{" + column + "}'", "E'" + value + "'");
                }
                replaceSql = replaceSql.Replace("{" + column + "}", value);

                return replaceSql;
            }
        }
        // add #10191 djy end
    }
}
