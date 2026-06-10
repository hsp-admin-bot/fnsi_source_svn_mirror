using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using ConvertCommon.dto;
using ConvertCommon.parts;
using ConvertCommon.Common;
using System.Drawing;
using ConvertCommon.Const;
using Fnw.IOControl.DB;
using static ConvertCommon.Common.CacheInformation;


namespace ConvertCommon
{
    /// <summary>
    /// コンバート処理クラス(mst)
    /// </summary>
    sealed public class ConvertMst : ConvertBase
    {
       

        /// <summary>updateなしのテープル</summary>
        private List<string> noUpdList = new List<string>()
        {
            "MST_BED",
            "MST_EXAM_ITEM",
            "MST_BED_GROUP",
            "MST_TREAT_ITEM",
            "PAT_BASIC_INFO"
        };
        // add FNSI-差分コンバート対応 楊 end

        
        public override int FnwDataRowCount()
        {
            return dtFnwData.Rows.Count;
        }
        /// <summary>
        /// コンストラクタ
        /// </summary>
        public ConvertMst() { }

        DataTable rstAddData = new DataTable();

        /// <summary>
        /// マスタを取得
        /// </summary>
        /// <remarks>
        /// マスタ情報定義XMLからSQLを読み込んで実行する
        ///  7403  2022-05-31   url 追加 鄭 
        /// </remarks>
        /// <returns>成功：true、失敗：false</returns>
        public override bool SetFnwDataForMst(string url, string mstCd, bool isSync)
        {
            WriteTraceLog("===== コンバート元データ取得処理開始 =====");

            // XMLConfigNameの設定
            string xmlConfigName = this.fnwTableName + "-" + this.convertTableName;

            rootNodeTableInfo tableConfig = ConfigInfoDtoUtil.getTableInfoByXmlConfigName(xmlConfigName);


            // add FNSI-差分コンバート対応 楊 start
            MakeSqlDto condDto;
            ConvertDatetimeResult resultConvertDatetime = new ConvertDatetimeResult();
            if (CommonConfig.isDiff)
            {
                //mod 8400 zc start
                string typeKind = tableConfig.convertKind;
                //mod #12229  前回convertを実行した時刻 start
                resultConvertDatetime = CacheInformation.Instance.GetEffectiveConvertDatetime(typeKind);
                //mod #12229  前回convertを実行した時刻 end
                string sqlForDiffStr = string.Empty;
                //add #10761 差分コンバートでFNWの治療項目マスタの内容が一部反映されない 孟堅　20240618 start　
                CommonConfig.MST_DIFF_DATETIME = resultConvertDatetime.ConvertDatetime.ToString("yyyy-MM-dd HH:mm:ss");
                //add #10761 差分コンバートでFNWの治療項目マスタの内容が一部反映されない 孟堅　20240618 end　

                //mod #12418 start
                string sqlForExclusiveOutputtedStr = string.Empty;
                if (noUpdList.Contains(this.fnwTableName))
                {
                    sqlForExclusiveOutputtedStr =
                         ExclusiveSqlDispatcher.Resolve(
                             this.convertTableName,
                             this.fnwTableName
                         );
                }
                else
                {

                    sqlForExclusiveOutputtedStr =
                             ExclusiveSqlDispatcher.BuildExclusiveSql(
                                 this.convertTableName,
                                 this.fnwTableName
                             );
                }
                //mod #12418 end

                string sqlForTool = tableConfig.sqlForTool;
                //add #11383  mst_addition start  
                sqlForTool = ExclusiveSqlDispatcher.BuildSqlForTool(sqlForTool, xmlConfigName);
                //add 11383 end
                //mod #10418 start
                condDto = ExclusiveSqlDispatcher.BuildSqlDto(sqlForTool, tableConfig.sqlForSync, sqlForDiffStr, sqlForExclusiveOutputtedStr, isSync, mstCd, this.convertTableName);
                //mod #10418 end

            }
            else
            {

                //mod #10418 start
                condDto = ExclusiveSqlDispatcher.BuildSqlDto(tableConfig.sqlForTool, tableConfig.sqlForSync, "", "", isSync, mstCd,null);
                //mod #10418 end
            }

            //add 9778 zl start
            string output = condDto.sqlForExclusiveOutputted;
            string diffsql = "";
            diffsql = DiffAllTable(diffsql, tableConfig.sqlForTool, tableConfig.sqlForSync, isSync, mstCd, condDto);
            //add 9778 zl end

            string sql = SqlCreator.MakeSqlForAllData(condDto);

            //mod #10418 start
            sql = SqlReplace.BuildExclusiveSql(this.convertTableName, sql, diffsql, output, this.fnwTableName, resultConvertDatetime.ConvertDatetime, db);
            //mod #10418 end

            // テーブル取得

            //mod #10418 start
            dtFnwData = ExecuteSql(sql, resultConvertDatetime.ConvertDatetime);
            //mod #10418 end

            if (!CommonConfig.isDiff && "PAT_BBS_INF".Equals(this.fnwTableName) && "bbs_info".Equals(this.convertTableName))
            {
                dtFnwData = new DataView(dtFnwData)
                {
                    RowFilter = "DELETE_FLG = '1'"
                }.ToTable();
            }

            //mod #12418 start
            if (CommonConfig.isDiff)
            {
                //add  #10418 start
                HandleDiffLogic(
                    fnwTableName,
                    convertTableName,
                    dtFnwData,
                    resultConvertDatetime.ConvertDatetime
                );
                //add #10418 end
            }

            ConvertRgbToHexIfNeeded(this.convertTableName, dtFnwData);
            //mod #12418 end


            if (dtFnwData.Rows.Count == 0)
                return false;

            //add 9778 zc start  
            if (!CommonConfig.isDiff)
            {
                GetMstHisDtlSql(dtFnwData, CommonConfig.isDiff, null);
                //add 9862 zc start
                if (CommonConstants.PHYSICAL_DELETION_DIFF_TABLES.Contains(this.fnwTableName + "-" + this.convertTableName))
                {
                    GetPHYSICALDELETIONDtlSql(dtFnwData);
                }
                //add 9862 end
            }
            //add 9778 zc end 


            dtFnwData.TableName = xmlConfigName;

            //------------------------------------
            // 主テーブルに紐付く子テーブルを取得
            //------------------------------------
            // 子テーブル要素をループ
            //add  #10418 start
            getChildXmlConfigName(tableConfig.child, isSync, mstCd);
            //add  #10418 start

            WriteTraceLog("===== コンバート元データ取得処理完了 =====");
            return true;
        }


        //add #12066  start
        /// <summary>
        /// 中間テーブルを保存し、差分時に比較に使用する
        /// <returns></returns>
        private void SetMstDeviceHis(DataTable childTable)
        {
            db.ExecuteSQL("DELETE FROM SYNC_MST_DEVICE_HIS");
            StringBuilder sql = new StringBuilder();
            sql.Append("INSERT INTO SYNC_MST_DEVICE_HIS (DEVICE_NO, DEVICE_OPTION) ");

            for (int i = 0; i < childTable.Rows.Count; i++)
            {
                if (i == 0)
                    sql.Append("SELECT :DEVICE_NO" + i + ", :DEVICE_OPTION" + i + " FROM DUAL ");
                else
                    sql.Append("UNION ALL SELECT :DEVICE_NO" + i + ", :DEVICE_OPTION" + i + " FROM DUAL ");
            }

            IMakeSqlParameters param = db.GetIMakeSqlParameters();

            for (int i = 0; i < childTable.Rows.Count; i++)
            {
                param.AddParam(":DEVICE_NO" + i, childTable.Rows[i]["DEVICE_NO"]);
                object deviceOptionValue = childTable.Rows[i]["DEVICE_OPTION"];
                if (deviceOptionValue == DBNull.Value || string.IsNullOrEmpty(deviceOptionValue.ToString()))
                {
                    param.AddParam(":DEVICE_OPTION" + i, DBNull.Value);
                }
                else
                {
                    param.AddParam(":DEVICE_OPTION" + i, deviceOptionValue.ToString());
                }
            }

            db.ExecuteSQL(sql.ToString(), param.GetParam());

        }
        //add #12066  end　



        //add 9778 zc start
        private string GetMstHisDtlSql(DataTable dt, bool isdiff, string diffsql)
        {
            string keylist = string.Empty;
            string difflist = string.Empty;
            List<string> difflists = new List<string>();
            // 表示順、表示フラグ、院内コードを変更した場合の更新時間が変更されないテーブル
            if (CommonConstants.DIFF_ALL_TABLES.Contains(this.fnwTableName + "-" + this.convertTableName))
            {
                if (isdiff && ((this.fnwTableName + "-" + this.convertTableName).Equals("MST_STAFF-mst_user") || (this.fnwTableName + "-" + this.convertTableName).Equals("MST_STAFF-mst_user_authentication")))
                {
                    return CommonConfig.DiffUser;
                }
                List<string> Coname = CommonConstants.DIFF_COMPARISON_TABLES[this.fnwTableName];
                DataTable data = new DataTable();
                // 差分コンバート場合
                if (isdiff)
                {
                    string selectSql = "select KEY AS " + Coname[0].ToString();

                    if (Coname[1] != null)
                    {
                        selectSql += " , IN_HOSPITAL_CD1 ";
                    }
                    if (Coname[2] != null)
                    {
                        selectSql += " , IN_HOSPITAL_CD2 ";
                    }
                    if (Coname[3] != null)
                    {
                        selectSql += " , IN_HOSPITAL_CD3 ";
                    }
                    if (Coname[4] != null)
                    {
                        selectSql += " , DISP_ORDER ";
                    }
                    if (Coname[5] != null)
                    {
                        if (this.fnwTableName == "MST_STAFF")
                        {
                            selectSql += " , DEL_FLG AS DISP_FLG_1";
                        }
                        else
                        {
                            selectSql += " , DEL_FLG AS DISP_FLG";

                        }
                    }

                    selectSql += " from SYNC_MST_HIS where TABLENAME = :fnwTableName  and SERIES_CD =:seriesCd";

                    //mod #12408 start
                    var param1 = db.GetIMakeSqlParameters();
                    param1.AddParam(":fnwTableName", this.fnwTableName);
                    param1.AddParam(":seriesCd", this.seriesCd);
                    data = db.SelectTable(selectSql, param1.GetParam());
                    //mod #12408 end

                    // SYNC_MST_HISテーブルにデータがある
                    if (data.Rows.Count > 0)
                    {
                        Coname.Remove("SERIES_CD");
                        string[] name = Coname.Where(r => r != null).ToList().ToArray();

                        DataTable datNew = dt.DefaultView.ToTable(false, name);

                        var query1 = datNew.AsEnumerable();
                        var query2 = data.AsEnumerable();

                        // 比較
                        var exceptAB = query1.Except(query2, DataRowComparer.Default);

                        //add 11383 start
                        if ((this.fnwTableName + "-" + this.convertTableName).Equals("MST_RECEIPT_MEMO-mst_addition"))
                        {
                            var query1Keys = datNew.AsEnumerable()
                                               .Select(row => new
                                               {
                                                   Key = row.Field<string>("RECEIPT_MEMO_CD"),
                                                   DelFlg = row.Field<string>("DISP_FLG")
                                               }).ToList();

                            var query2Keys = data.AsEnumerable()
                                             .Select(row => new
                                             {
                                                 Key = row.Field<string>("RECEIPT_MEMO_CD"),
                                                 DelFlg = row.Field<string>("DISP_FLG")
                                             }).ToList();
                            var exceptCount = query1Keys.Except(query2Keys).ToList();
                            if (exceptCount.Count() > 0)
                            {
                                CommonConfig.diffPatMainAll = true;
                            }
                            var changedRecords = from q1 in query1Keys
                                                 join q2 in query2Keys on q1.Key equals q2.Key
                                                 where q1.DelFlg != q2.DelFlg
                                                 select new
                                                 {
                                                     Key = q1.Key,
                                                     Original = q2,
                                                     Updated = q1
                                                 };
                            if (changedRecords.Count() > 0)
                            {
                                CommonConfig.diffPatMainMongo = true;
                            }

                        }
                        else if ((this.fnwTableName + "-" + this.convertTableName).Equals("MST_DIAL_DIFF_COMENT-mst_dialysis_difficulty"))
                        {

                            var query1Keys = datNew.AsEnumerable()
                                                 .Select(row => new { Key = row.Field<string>("DIAL_DIFF_CD") }).ToList();

                            var query2Keys = data.AsEnumerable()
                                             .Select(row => new { Key = row.Field<string>("DIAL_DIFF_CD") }).ToList();

                            var exceptCount = query1Keys.Except(query2Keys).ToList();
                            if (exceptCount.Count() > 0)
                            {
                                CommonConfig.diffPatPersonalMainAll = true;
                            }
                        }
                        //add 11383 end

                        // 不一致の場合
                        if (exceptAB.Count() > 0)
                        {
                            //10164 start
                            if ((this.fnwTableName + "-" + this.convertTableName).Equals("MST_LLT_KIND-mst_pat_event_sub_category"))
                            {
                                keylist = String.Join(",", datNew.AsEnumerable().Select(c => ("a" + c.Field<string>(Coname[1].ToString()) + c.Field<string>(Coname[0].ToString()))).ToList());
                            }
                            else
                            {
                                keylist = String.Join(",", datNew.AsEnumerable().Select(c => c.Field<object>(Coname[0].ToString())).ToList());

                            }
                            //10164  end
                            // 異なる主キーリスト
                            foreach (var item in exceptAB)
                            {
                                //mod 9638 zc start
                                //difflist += "'" +item[Coname[0]].ToString() + "',";
                                difflists.Add(item[Coname[0]].ToString());
                                //mod 9638 zc end
                            }
                        }

                        if (keylist.Length > 0)
                        {
                            //mod 9638 zc start
                            diffsql = MakeInClause("a." + Coname[0].ToString(), 1000, difflists);
                            //mod 9638 zc end
                            // SYNC_MST_HIS削除
                            var param = db.GetIMakeSqlParameters();
                            param.AddParam(":fnwTableName", this.fnwTableName);
                            param.AddParam(":seriesCd", this.seriesCd);
                            string sql = "delete from SYNC_MST_HIS where TABLENAME = :fnwTableName and SERIES_CD = :seriesCd";
                            db.ExecuteSQL(sql, param.GetParam());
                        }
                    }
                }

                // 差分コンバート且つ差分データがある場合　まだは　初回コンバート場合、SYNC_MST_HIS作成
                if ((isdiff && keylist.Length > 0) || !isdiff || (isdiff && data.Rows.Count == 0))
                {
                    // SYNC_MST_HIS作成

                    int BATCH_SIZE = 1000;

                    for (int i = 0; i < dt.Rows.Count; i += BATCH_SIZE)
                    {
                        var batch = dt.AsEnumerable().Skip(i).Take(BATCH_SIZE).ToList();

                        StringBuilder sql = new StringBuilder();
                        var param = db.GetIMakeSqlParameters();

                        sql.AppendLine(
                            "INSERT INTO SYNC_MST_HIS " +
                            "(TABLENAME, KEY, DISP_ORDER, DEL_FLG,IN_HOSPITAL_CD1,IN_HOSPITAL_CD2,IN_HOSPITAL_CD3, SERIES_CD)"
                        );

                        for (int idx = 0; idx < batch.Count; idx++)
                        {
                            DataRow item = batch[idx];

                            string pTable = $":table_{idx}";
                            string pKey = $":key_{idx}";
                            string pDisp = $":disp_{idx}";
                            string pDel = $":del_{idx}";
                            string pHos1 = $":hos1_{idx}";
                            string pHos2 = $":hos2_{idx}";
                            string pHos3 = $":hos3_{idx}";
                            string pSeries = $":series_{idx}";

                            if (idx > 0)
                            {
                                sql.AppendLine("UNION ALL");
                            }

                            sql.AppendLine(
                                $"SELECT {pTable}, {pKey}, {pDisp}, {pDel}, {pHos1}, {pHos2}, {pHos3}, {pSeries} FROM DUAL"
                            );

                            object ConameHospitalCd1 = GetDbValue(item, Coname[1]); // IN_HOSPITAL_CD1
                            object ConameHospitalCd2 = GetDbValue(item, Coname[2]); // IN_HOSPITAL_CD2
                            object ConameHospitalCd3 = GetDbValue(item, Coname[3]); // IN_HOSPITAL_CD3
                            object ConameDispOrder = GetDbValue(item, Coname[4]); // DISP_ORDER
                            object ConameDelFlg = GetDbValue(item, Coname[5]); // DEL_FLG

                            param.AddParam(pTable, this.fnwTableName);
                            param.AddParam(pKey, item[Coname[0]]);
                            param.AddParam(pDisp, ConameDispOrder);
                            param.AddParam(pDel, ConameDelFlg);
                            param.AddParam(pHos1, ConameHospitalCd1);
                            param.AddParam(pHos2, ConameHospitalCd2);
                            param.AddParam(pHos3, ConameHospitalCd3);
                            param.AddParam(pSeries, this.seriesCd);
                        }

                        db.ExecuteSQL(sql.ToString(), param.GetParam());
                    }
                    //mod  #12229 SQL一括実行 start


                    // MstSelector表示順
                    if (isdiff && keylist.Length > 0)
                    {
                        if (!CommonConstants.NO_ORDER_NO_FLG.Contains(this.fnwTableName))
                        {
                            // mst_personal_user、mst_user_authenticationテーブル場合、mst_selectorにmst_userを設定
                            if (this.convertTableName == "mst_personal_user" || this.convertTableName == "mst_user_authentication")
                            {
                                CommonConfig.Mst_select.Add("mst_user/'" + keylist + "'");
                            }
                            else
                            {
                                CommonConfig.Mst_select.Add(this.convertTableName + "/'" + keylist + "'");
                            }
                        }
                    }
                }
                if (isdiff && (this.fnwTableName + "-" + this.convertTableName).Equals("MST_STAFF-mst_personal_user"))
                {
                    CommonConfig.DiffUser = diffsql;
                }
            }

            return diffsql;
        }

        //add #12229 start
        private static object GetDbValue(DataRow row, string columnName)
        {
            return (string.IsNullOrEmpty(columnName) || row[columnName] == DBNull.Value)
                ? (object)DBNull.Value
                : (object)row[columnName].ToString();
        }
        //add #12229 end

        //add 9778 zc start  
        /// <summary>
        /// データコンバート処理
        /// </summary>
        /// <param name="mapConvertData">コンバートデータ(戻り値)</param>
        /// <param name="listErrorMstCd">失敗したマスタコード(戻り値)</param>
        /// <returns>成功：true、失敗：false</returns>
        public override bool Convert(Dictionary<string, List<NtssRecord>> mapConvertData, List<string> listErrorMstCd)
        {

            // 子テーブル要素をループ

            //mod #10418 start
            Dictionary<string, Dictionary<string, DataRow[]>> dic = BuildChildDictionary();

            // 不要な列の削除
            RemoveUnusedColumns();
            //mod #10418 end

            WriteTraceLog("===== コンバート処理開始 =====");
            // 項目情報を追加

            

            int procCount = 0;
            // 7244 add FNSI_(HD+補液) → OHDF 楊 start
            if (this.convertTableName.Equals("mst_treatment"))
            {
                DataTable addtable = dtFnwData.Copy();
                DataRow[] addrows = addtable.Select("DEVICE_MODE = '4'");
                DataRow[] addrowsohdf = addtable.Select("DEVICE_MODE = '7'and DISP_FLG = '1'");
                if (addrows.Length > 0 && addrowsohdf.Length <= 0)
                {

                    addrows[0]["DISP_FLG"] = 1;
                    addrows[0]["TREAT_ITEM_NAME"] = "OHDF";
                    addrows[0]["DEVICE_MODE"] = "7";
                    dtFnwData.ImportRow(addrows[0]);
                }
            }
            // 7244 add FNSI_(HD+補液) → OHDF 楊 end
            // add #11201 djy start 
            
            if (this.convertTableName.Equals("pat_main_history"))
            {
                StringBuilder sb = new StringBuilder();
                sb.Append("SELECT CODE,START_DATE,PATID");
                sb.Append(" FROM (SELECT M.DIALYSIS_NO,M.CODE,D.START_DATE,D.PATID FROM RST_RECEIPT_MEMO M");
                sb.Append(" INNER JOIN RST_DIALYSIS D ON M.DIALYSIS_NO=D.DIALYSIS_NO");
                sb.Append(" WHERE M.DIVISION ='1' AND M.ADD_FLG='1')");
                var rstAddSql = sb.ToString();
                rstAddData = db.SelectTable(rstAddSql);
            }
            // add #11201 djy end 

            foreach (DataRow row in dtFnwData.Rows)
            {
                // 系列施設コードがある場合は取得

                //mod #10418 start
                string seriesCd = row.Table.Columns.IndexOf("SERIES_CD") >= 0
                                 ? row["SERIES_CD"]?.ToString()
                                 : null;
                //mod #10418 end

                // マスタコードを取得
                var mstCd = row[GetXmlElementValue("fnwPk")].ToString();
                if (listErrorMstCd.Contains(mstCd))
                {
                    // エラーがあったマスタコードのそれ以降のレコード(系列施設レコード)は処理しない
                    continue;
                }

                var isCriticalError = false;
                var isConvertError = false;
                var ntssColumns = new List<NtssColumn>();
                var mapJson = new Dictionary<string, List<JsonElement>>();


                // add FNSI-赤、緑、青の３項目の値でできる色のコードを16進数で同じ色変更 楊 start
                if (this.convertTableName.Equals("mst_monitor_graph"))
                {
                    row["LEFT_POINT_COLOR"] = ToHexColor(row["LEFT_POINT_COLOR"].ToString());
                    row["RIGHT_POINT_COLOR"] = ToHexColor(row["RIGHT_POINT_COLOR"].ToString());
                }
                // add FNSI-赤、緑、青の３項目の値でできる色のコードを16進数で同じ色変更 楊 end

                // add FNSI_(HD+補液) → OHDF 楊 end
                //------------------------------------
                // 主テーブルの加工処理
                //------------------------------------
                ConvertRecord(row, ntssColumns, mapJson, ref isConvertError);
                // クリティカルエラーは廃止

                if (isConvertError)
                {
                    // 次のマスタレコードへ
                    listErrorMstCd.Add(mstCd);
                    continue;
                }

                // add 10870 zkm start
                if (this.convertTableName.Equals("mnt_mainte_main") && this.fnwTableName.Equals("MNT_PERIOD_CHECKLIST"))
                {
                    ntssColumns.Insert(0, CreateNtssColumn("detail", NTSS_DATA_TYPE_CHARACTER_VARYING, "", true));
                }
                // add 10870 zkm end

                //------------------------------------
                // 子テーブルの加工処理
                //------------------------------------
                // 子テーブル要素をループ
                foreach (var child in GetXmlElements("child"))
                {
                    // 子テーブル名
                    //var childTableName = GetXmlElementValue(child, "fnwTableName");
                    // XMLファイルの設定名
                    var xmlConfigName = GetXmlElementValue(child, "xmlConfigName");
                    // 主テーブルの子テーブルに紐付くカラム名
                    var parentPk = GetXmlElementValue(child, "parentPk");
                    // 子テーブルの主キー名
                    var childPk = GetXmlElementValue(child, "childPk");
                    // JSON名
                    var jsonName = GetXmlElementValue(child, "jsonName");
                    if (xmlConfigName == null || parentPk == null || childPk == null || jsonName == null)
                    {
                        return false;
                    }

                    // 主テーブルの子テーブルに紐付くカラムの値
                    var parentValue = row[parentPk].ToString();

                    //mod #10418 start
                    var childRows = GetChildRows(
                        xmlConfigName,
                        dic,
                        parentValue,
                         row);

                    if (childRows == null)
                    {
                        continue;
                    }

                    //mod #10418 end



                    // JSON配列化                  
                    if (CommonConstants.MST_JSON_LIST.Contains(jsonName))
                    {
                        ConvertJsonArrayDeviceSetInfoData(childRows, jsonName, ntssColumns, ref isCriticalError, ref isConvertError);
                    }
                    else if (jsonName.Equals("machine_option"))
                    {
                        for (int i = 0; i < childRows.Count(); i++)
                        {
                            ConvertJsonArrayXmlData(
                            "machine_option",
                            "DEVICE_OPTION",
                            "DEVICE_OPTION",
                            "macop_",
                            ConvertCommon.Const.CommonConstants.MACHINE_OPTION_ELEMENT_NAME_LIST,
                            childRows[i], ntssColumns);
                            if (isCriticalError)
                            {
                                return false;
                            }
                            if (isConvertError)
                            {
                                listErrorMstCd.Add(mstCd);
                            }
                        }
                    }
                    else if (xmlConfigName.Equals("PAT_FREE_COMMENT-pat_main_history-pat_memo_info") || xmlConfigName.Equals("PAT_FREE_COMMENT-pat_main-pat_memo_info"))
                    {

                        ConvertJsonArrayDataPatMemoInfo(childRows, jsonName, ntssColumns, ref isCriticalError, ref isConvertError);
                    }
                    else
                    {
                        ConvertJsonArrayData(childRows, jsonName, ntssColumns, ref isCriticalError, ref isConvertError);
                    }
                    if (isCriticalError)
                    {
                        return false;
                    }
                    if (isConvertError)
                    {
                        // 次のマスタレコードへ
                        listErrorMstCd.Add(mstCd);
                        continue;
                    }
                }

                // add FNSI_患者イベント項目テンプレートマスタ追加 楊 start

                // 項目情報を追加
                //add #10418 start
                mstCd = ApplyNtssColumnRules(convertTableName, ntssColumns, mstCd, row);
                //add #10418 end

                // add FNSI_患者イベント項目テンプレートマスタ追加 楊 end   


                if (mapConvertData.ContainsKey(mstCd) == false)
                {
                    mapConvertData[mstCd] = new List<NtssRecord>();
                }
                mapConvertData[mstCd].Add(new NtssRecord() { columns = ntssColumns });
                if (++procCount % 100 == 0)
                {
                    WriteTraceLog("コンバート処理中 " + procCount.ToString() + "/" + dtFnwData.Rows.Count.ToString());
                }
            }
            WriteTraceLog("===== コンバート処理完了 =====");
            return true;
        }
        //add 10534 zc start
        public DataRow[] setNullRow(DataRow[] rows)
        {
            foreach (DataRow row in rows)
            {
                foreach (String columnName in CommonConstants.PAT_REVISE_OFFWATER_LIST)
                {
                    if (row[columnName] == DBNull.Value || row[columnName] == null)
                    {
                        DataRow dr = rows.Where(crow => (DateTime)crow["UP_DATE"] < (DateTime)row["UP_DATE"] && crow["DAY_OF_WEEK"].ToString() == row["DAY_OF_WEEK"].ToString()
                                ).GroupBy(crow => crow["DAY_OF_WEEK"]).Select(g => g.OrderByDescending(crow => crow["UP_DATE"]).FirstOrDefault()).FirstOrDefault();
                        if (dr != null)
                        {
                            row[columnName] = dr[columnName];
                        }
                    }
                }
            }
            return rows;
        }

        //add 10534 zc end
        // add FNSI-赤、緑、青の３項目の値でできる色のコードを16進数で同じ色変更 楊 start
        private string ToHexColor(String color)
        {
            // add  NULLの値を追加  鄭   start 
            if (string.IsNullOrWhiteSpace(color))
            {
                return "#000000";
            }
            // add  NULLの値を追加  鄭   end
            var colorStr = color.Split(',');
            string R = int.Parse(colorStr[0]).ToString("X2");
            if (R == "0")
                R = "00";
            string G = int.Parse(colorStr[1]).ToString("X2");
            if (G == "0")
                G = "00";
            string B = int.Parse(colorStr[2]).ToString("X2");
            if (B == "0")
                B = "00";
            string HexColor = "#" + R + G + B;
            return HexColor;
        }
        // add FNSI-赤、緑、青の３項目の値でできる色のコードを16進数で同じ色変更 楊 end


    

        //add #10418 start
        private void InsertSyncSysPatCustomKey(DataTable dt, string facilityCd)
        {
            if (dt == null || dt.Rows.Count == 0)
                return;

            StringBuilder sql = new StringBuilder();
            var param = db.GetIMakeSqlParameters();

            sql.AppendLine("INSERT INTO SYNC_SYS_PAT_CUSTOM_KEY (CUSTOM_KEY_CD, PATID, SERIES_CD)");
            sql.AppendLine("SELECT PAT_GROUP_CD, PKEY, FACILITY_CD FROM (");

            int index = 0;

            foreach (DataRow row in dt.Rows)
            {
                if (index > 0)
                    sql.AppendLine("UNION ALL");

                string patGroupParam = ":PAT_GROUP_CD" + index;
                string pkeyParam = ":PKEY" + index;
                string facilityParam = ":FACILITY_CD" + index;

                sql.AppendLine($"SELECT {patGroupParam} AS PAT_GROUP_CD, {pkeyParam} AS PKEY, {facilityParam} AS FACILITY_CD FROM DUAL");

                param.AddParam(patGroupParam, row["PAT_GROUP_CD"]?.ToString());
                param.AddParam(pkeyParam, row["PKEY"]?.ToString());
                param.AddParam(facilityParam, facilityCd);

                index++;
            }

            sql.AppendLine(")");

            db.ExecuteSQL(sql.ToString(), param.GetParam());
        }
        //add #10418 end

        public void GetPHYSICALDELETIONDtlSql(DataTable dt)
        {

            if (!CommonConfig.isDiff)
            {
                //mod #10418 start
                InsertSyncSysPatCustomKey(dt, this.facilityCd);
                //mod #10418 end
            }
            else
            {
                if ("SYS_PAT_CUSTOM_KEY-pat_group_detail".Equals(this.fnwTableName + "-" + this.convertTableName))
                {
                    var param = db.GetIMakeSqlParameters();
                    string sVALUE = "1";
                    string s_CD = " 1=1";
                    if (!string.IsNullOrEmpty(CacheInformation.Instance.FacilityCd))
                    {
                        sVALUE = CacheInformation.Instance.FacilityCd;
                    }
                    if (!sVALUE.Equals("0"))
                    {
                        s_CD = "a.SERIES_CD =:seriesCd";
                        param.AddParam(":seriesCd", this.seriesCd);
                    }

                    string sql = @"WITH PAT_BASIC_INFO_NORMAL AS(SELECT w1.*
                                        FROM PAT_BASIC_INFO w1 INNER JOIN PAT_INDEX_INFO w2 ON(w2.PAT_STATUS = '0' AND w1.PATID = w2.PATID AND w1.REG_DATE = w2.PAT_REG_DATE)),
			                            SYS_CUSTOM_KEY_NORMAL AS(
                                        select
                                        a.CUSTOM_KEY_CD as PAT_GROUP_CD,
			                            a.CUSTOM_KEY_NAME,
			                            a.DEL_FLG,
			                            b.DISP_FLG,
			                            a.UP_DATE
                                        from SYS_CUSTOM_KEY a
                                        left join SYS_CUSTOM_KEY_DISP b on(a.CUSTOM_KEY_CD = b.CUSTOM_KEY_CD)
                                        where a.DEL_FLG = '0' and b.DISP_FLG = '1')
			                            select
                                        a.PAT_GROUP_CD || b.PATID AS KEY
                                        from MST_PAT_GROUP a
                                        left
                                        join PAT_BASIC_INFO_NORMAL b on a.PAT_GROUP_CD = b.PAT_GROUP_CD
                                        where " + s_CD + @" and NOT EXISTS(SELECT * FROM MST_PAT_GROUP b WHERE a.PAT_GROUP_CD = b.PAT_GROUP_CD AND a.UP_DATE < b.UP_DATE)
                                        and b.PATID is not null
                                        and a.PAT_GROUP_CD is not null
                                        union all
                                        select
                                        TO_CHAR(b.PAT_GROUP_CD) || a.PATID as PKEY
                                        from SYS_CUSTOM_KEY_NORMAL b
			                            ,SYS_PAT_CUSTOM_KEY a
                                        INNER JOIN(SELECT w1.PATID, w1.NAME_KANA, w1.NAME, w1.DISP_PATID
                                        FROM PAT_BASIC_INFO w1 INNER JOIN PAT_INDEX_INFO w2 ON(w2.PAT_STATUS= '0' AND w1.PATID= w2.PATID AND
                                        w1.REG_DATE= w2.PAT_REG_DATE)) d
                                         on a.PATID = d.PATID
                                        where b.PAT_GROUP_CD = a.CUSTOM_KEY_CD
                                        and b.PAT_GROUP_CD is not null";

                    List<string> pKEY = db.SelectTable(sql, param.GetParam()).AsEnumerable().Select(r => r["KEY"].ToString()).ToList<string>();


                    string diffsql = string.Empty;
                    if (pKEY.Count > 0)
                    {
                        //mod #10418 start
                        var param1 = db.GetIMakeSqlParameters();
                        if (sVALUE.Equals("1"))
                        {
                            param1.AddParam(":seriesCd", this.seriesCd);
                        }
                        diffsql = MakeInClauseAnd("a.CUSTOM_KEY_CD || a.PATID", 1000, pKEY);
                        DataTable dtdel = db.SelectTable(@"	SELECT  a.CUSTOM_KEY_CD, a.PATID FROM  SYNC_SYS_PAT_CUSTOM_KEY a  WHERE  " + s_CD + " and " + diffsql + "", param1.GetParam());
                        //mod #10418 end

                        if (dtdel != null)
                        {
                            foreach (DataRow item in dtdel.Select("1=1"))
                            {
                                CommonConfig.Mst_DEL.Add(item["CUSTOM_KEY_CD"] + "/" + item["PATID"]);
                            }
                        }
                    }
                    var param2 = db.GetIMakeSqlParameters();
                    param2.AddParam(":SERIES_CD", this.facilityCd);
                    if (sVALUE.Equals("1"))
                    {
                        param2.AddParam(":seriesCd", this.seriesCd);
                    }

                    db.ExecuteSQL(@"begin  DELETE  FROM SYNC_SYS_PAT_CUSTOM_KEY WHERE  SERIES_CD=:SERIES_CD;INSERT INTO SYNC_SYS_PAT_CUSTOM_KEY(SERIES_CD, CUSTOM_KEY_CD, PATID)
                    select :SERIES_CD, TO_CHAR(b.PAT_GROUP_CD ) as PAT_GROUP_CD,
                    a.PATID as PKEY
                    from(select
                    a.CUSTOM_KEY_CD as PAT_GROUP_CD,
                    a.CUSTOM_KEY_NAME,
                    a.DEL_FLG,
                    b.DISP_FLG,
                    a.UP_DATE
                    from SYS_CUSTOM_KEY a
                    left
                    join SYS_CUSTOM_KEY_DISP b on (a.CUSTOM_KEY_CD = b.CUSTOM_KEY_CD)
                    where a.DEL_FLG = '0' and b.DISP_FLG = '1') b
			        ,SYS_PAT_CUSTOM_KEY a
                    INNER JOIN(SELECT w1.PATID, w1.NAME_KANA, w1.NAME, w1.DISP_PATID
                    FROM PAT_BASIC_INFO w1 INNER JOIN PAT_INDEX_INFO w2 ON(w2.PAT_STATUS= '0' AND w1.PATID= w2.PATID AND
                    w1.REG_DATE= w2.PAT_REG_DATE)) d
                     on a.PATID = d.PATID
                    where b.PAT_GROUP_CD = a.CUSTOM_KEY_CD
                    and b.PAT_GROUP_CD is not null
                    union all
	                 select
                            :SERIES_CD,
			                a.PAT_GROUP_CD,
			                b.PATID as PKEY
			                from MST_PAT_GROUP a
			                left join (SELECT w1.*
			                FROM PAT_BASIC_INFO w1 INNER JOIN PAT_INDEX_INFO w2 ON(w2.PAT_STATUS='0' AND w1.PATID=w2.PATID AND w1.REG_DATE=w2.PAT_REG_DATE)) b on a.PAT_GROUP_CD = b.PAT_GROUP_CD
			                where  " + s_CD + @"  and NOT EXISTS ( SELECT * FROM MST_PAT_GROUP b WHERE a.PAT_GROUP_CD = b.PAT_GROUP_CD AND a.UP_DATE <b.UP_DATE )
			                and b.PATID is not null
			                and a.PAT_GROUP_CD is not null;  end;", param2.GetParam());
                }
            }
        }


        //add #10418 start
        private void HandleDiffLogic(
                string fnwTableName,
                string convertTableName,
                DataTable dtFnwData,
                DateTime convertDatetime
                 )
        {
            string tableKey = $"{fnwTableName}-{convertTableName}";

            HandlePhysicalDeletion(tableKey);

            switch (tableKey)
            {
                case "MST_RECEIPT_MEMO-mst_addition":
                    HandleReceiptMemoDiff(dtFnwData, convertDatetime);
                    break;

                case "MST_DIAL_DIFF_COMENT-mst_dialysis_difficulty":
                    HandleDialDiffComentDiff(dtFnwData, convertDatetime);
                    break;
                //add   #12427 非個人所有の車いすが複数患者の装置設定に割り当てされている場合に正しくコンバートされていない  start
                case "MST_WHEELCHAIR-mst_wheel_chair":

                    if (dtFnwData.Rows.Count > 0 && !CommonConfig.diffPatMainAll)
                    {
                        CommonConfig.diffPatMainAll = true;
                    }
                    CommonConfig.diffPatMainMongo = true;
                    break;
                //add   #12427非個人所有の車いすが複数患者の装置設定に割り当てされている場合に正しくコンバートされていない end

            }
        }
        private void HandlePhysicalDeletion(string tableKey)
        {
            if (CommonConstants.PHYSICAL_DELETION_DIFF_TABLES.Contains(tableKey))
            {
                GetPHYSICALDELETIONDtlSql(new DataTable());
            }
        }
        private void HandleReceiptMemoDiff(
            DataTable dtFnwData,
            DateTime convertDatetime
        )
        {
            if (dtFnwData.Rows.Count > 0 && !CommonConfig.diffPatMainAll)
            {
                CommonConfig.diffPatMainAll = true;
            }

            int count = GetUpdateCount(
                db,
                "MST_RECEIPT_MEMO",
                convertDatetime
            );

            if (count > 0)
            {
                CommonConfig.diffPatMainMongo = false;
            }
        }

        private void HandleDialDiffComentDiff(
            DataTable dtFnwData,
            DateTime convertDatetime)
        {
            if (dtFnwData.Rows.Count <= 0)
            {
                return;
            }

            if (dtFnwData.Select("DEL_FLG = 1").Any())
            {
                CommonConfig.diffPatPersonalMainAll = true;
            }

            int count = GetUpdateCount(
                db,
                "MST_DIAL_DIFF_COMENT",
                convertDatetime
            );

            CommonConfig.diffPatPersonalMainMongo = count <= 0;
        }
        private int GetUpdateCount(
            DBCtrl db,
            string tableName,
            DateTime convertDatetime)
        {
            IMakeSqlParameters param = db.GetIMakeSqlParameters();
            param.AddParam(":CONVERT_DATETIME", convertDatetime);

            string sql = $@"
                SELECT COUNT(*) AS COUNT
                FROM {tableName}
                WHERE UP_DATE > :CONVERT_DATETIME";

            return int.Parse(
                db.SelectTable(sql, param.GetParam())
                  .Rows[0]["COUNT"].ToString()
            );
        }

        private void ConvertRgbToHexIfNeeded(
            string convertTableName,
            DataTable dtFnwData)
        {
            switch (convertTableName)
            {
                case "mst_graph_setting":
                    ConvertRgbToHex(
                        dtFnwData,
                        "VALUE",
                        "ID IN (13,20)"
                    );
                    break;

                case "mst_vital_graph":
                    ConvertRgbToHex(
                        dtFnwData,
                        "COLOR",
                        null
                    );
                    break;
                case "mst_self_measure_result":
                    MstSelfMeasureResult();
                    break;
                case "mst_exam_item":
                    MstExamItem();
                    break;
                case "mst_take_medicine":
                    MstTakeMedicine();
                    break;


            }
        }
        private void ConvertRgbToHex(DataTable table, string columnName, string filterExpression)
        {
            DataRow[] rows = string.IsNullOrEmpty(filterExpression)
                ? table.Rows.Cast<DataRow>().ToArray()
                : table.Select(filterExpression);

            foreach (DataRow row in rows)
            {
                if (!Int32.TryParse(row[columnName]?.ToString(), out int rgb))
                {
                    continue;
                }

                Color color = Color.FromArgb(rgb);
                row[columnName] = $"#{color.R:X2}{color.G:X2}{color.B:X2}";
            }
        }

        // add #9219 自己診断判定マスタが正しくコンバートできていない zs start
        private void MstSelfMeasureResult()
        {
            // DCS-200Si、DBB-200-Si、DCS-100NX、DBB-100NXについては、同一機種で異なる通信フォーマットがある場合、それぞれ通信フォーマットP,Qのデータを使ってコンバートしM,Nはコンバートしない。
            // 但し、バージョンが異なる場合は、バージョン毎にコンバートする事。
            DataTable dt = new DataTable();
            dt = dtFnwData.Copy();
            String verDcsSi = null;
            String verDbbSi = null;
            String verDcsNx = null;
            String verDbbNx = null;

            foreach (DataRow row in dtFnwData.Select("MACHINE_NAME = 'DCS-200Si' AND COM_FORMAT_CD = 'P'"))
            {
                verDcsSi = row["VERSION"].ToString();
            }
            foreach (DataRow row in dtFnwData.Select("MACHINE_NAME = 'DBB-200Si' AND COM_FORMAT_CD = 'Q'"))
            {
                verDbbSi = row["VERSION"].ToString();
            }
            foreach (DataRow row in dtFnwData.Select("MACHINE_NAME = 'DCS-100NX' AND COM_FORMAT_CD = 'P'"))
            {
                verDcsNx = row["VERSION"].ToString();
            }
            foreach (DataRow row in dtFnwData.Select("MACHINE_NAME = 'DBB-100NX' AND COM_FORMAT_CD = 'Q'"))
            {
                verDbbNx = row["VERSION"].ToString();
            }

            foreach (DataRow row in dt.Rows)
            {
                if ("DCS-200Si".Equals(row["MACHINE_NAME"].ToString()) && "M".Equals(row["COM_FORMAT_CD"].ToString()))
                {
                    if (row["VERSION"].ToString().Equals(verDcsSi))
                    {
                        row.Delete();
                        continue;
                    }
                }

                if ("DBB-200Si".Equals(row["MACHINE_NAME"].ToString()) && "N".Equals(row["COM_FORMAT_CD"].ToString()))
                {
                    if (row["VERSION"].ToString().Equals(verDbbSi))
                    {
                        row.Delete();
                        continue;
                    }
                }

                if ("DCS-100NX".Equals(row["MACHINE_NAME"].ToString()) && "M".Equals(row["COM_FORMAT_CD"].ToString()))
                {
                    if (row["VERSION"].ToString().Equals(verDcsNx))
                    {
                        row.Delete();
                        continue;
                    }
                }

                if ("DBB-100NX".Equals(row["MACHINE_NAME"].ToString()) && "N".Equals(row["COM_FORMAT_CD"].ToString()))
                {
                    if (row["VERSION"].ToString().Equals(verDbbNx))
                    {
                        row.Delete();
                        continue;
                    }

                }
            }
            dt.AcceptChanges();
            dtFnwData = dt;
        }
        // add #9219 自己診断判定マスタが正しくコンバートできていない zs end

        // add zl start
        private void MstExamItem()
        {

            string log = "";
            foreach (DataRow row in dtFnwData.Select("LOG_FLG = '1'"))
            {
                log += "\r\n";
                log += "検査項目コード :" + row["EXAM_ITEM_CD"] + "、検査項目名 :" + row["EXAM_ITEM_NAME"];
                log += " → 計算項目コード :" + row["ITEM_CD"] + "、計算項目名 : " + row["ITEM_NAME"];
            }
            if (log.Length > 0)
            {
                string errorLog = "検査項目が複数計算項目と関連するため、FNSIに関連なしと処理する。";
                WriteErrorLog(errorLog + log);
            }
        }
        // add zl end


        private void MstTakeMedicine()
        {

            string sSql = @"SELECT
			                    REPLACE(REPLACE(TAKE_MEDICINE_NAME, CHR(13) || CHR(10), ''), CHR(10), '')  as TAKE_MEDICINE_NAME
			                    FROM
			                    MST_TAKE_MEDICINE a
			                    WHERE
			                    NOT EXISTS ( SELECT * FROM MST_TAKE_MEDICINE b WHERE a.TAKE_MEDICINE_CD = b.TAKE_MEDICINE_CD AND a.UP_DATE<b.UP_DATE )
			                    and DEL_FLG = '0' ORDER BY TAKE_MEDICINE_CD";
            List<string> S_NAME = db.SelectTable(sSql).AsEnumerable().Select(r => r["TAKE_MEDICINE_NAME"].ToString()).ToList<string>();
            foreach (DataRow row in dtFnwData.Rows)
            {
                if (row["TAKE_MEDICINE_CD"].Equals("11"))
                {
                    if (S_NAME.Count > 0)
                    {
                        row["list_details"] = string.Join(Environment.NewLine, S_NAME.ToArray());
                    }
                    else
                    {
                        row["list_details"] = row["list_details"].ToString().Replace(",", Environment.NewLine);
                    }
                }
                else
                {
                    row["list_details"] = row["list_details"].ToString().Replace(",", Environment.NewLine);
                }
                //add 10378_20 start
                if (row["UP_DATE"] == DBNull.Value)
                {
                    row["UP_DATE"] = CommonConfig.UpDate.ToString();
                }
                //add 10378_20 end
            }

        }


        private string DiffAllTable(string diffsql, string sqlForTool, string sqlForSync, bool isSync, string mstCd, MakeSqlDto condDto)
        {

            if (CommonConfig.isDiff && CommonConstants.DIFF_ALL_TABLES.Contains(this.fnwTableName + "-" + this.convertTableName))
            {

                //mod #10418 start
                MakeSqlDto condDtoFirst = ExclusiveSqlDispatcher.BuildSqlDto(sqlForTool, sqlForSync, "", "", isSync, mstCd,null);
                //mod #10418 end

                string sqlFirst = SqlCreator.MakeSqlForAllData(condDtoFirst);
                sqlFirst = sqlFirst.Replace("{3}", "");
                DataTable firstData = db.SelectTable(sqlFirst);
                if (firstData.Rows.Count > 0)
                {
                    diffsql = GetMstHisDtlSql(firstData, CommonConfig.isDiff, diffsql);
                    if ("mst_exam_item".Equals(this.convertTableName) || "mst_treatment".Equals(this.convertTableName))
                    {
                        if (diffsql.Length > 0)
                        {
                            condDto.sqlForExclusiveOutputted = condDto.sqlForExclusiveOutputted + " or " + diffsql;
                        }
                    }
                    else if (diffsql.Length > 0)
                    {
                        condDto.sqlForExclusiveOutputted = $"and  ( a.up_date > :CONVERT_DATETIME or {diffsql} )";
                    }
                }
            }
            return diffsql;

        }

        //add #12229 追加PATID条件 start
        private void BuildChildContext(string childXmlConfigName, ref bool isSync, ref string mstCd)
        {
            if (CommonConfig.isDiff &&
                CommonConstants.DIFF_PAT_WHERE_PATID.Contains(childXmlConfigName))
            {
                isSync = true;
                List<string> patIdList = dtFnwData.AsEnumerable()
                         .Select(r => r.Field<string>("PATID"))
                         .Where(v => !string.IsNullOrEmpty(v))
                         .ToList();
                mstCd = CommonFunc.MakeInClause("a.PATID", 1000, patIdList);
            }

        }
        //add #12229 追加PATID条件 end


        private void HandleSpecialBusiness(string xmlName, DataTable table)
        {
            switch (xmlName)
            {
                //add #12066 start
                case "MST_DEVICE-mst_machine-machine_option":
                    SetMstDeviceHis(table);
                    break;
                //add #12066 end

                case "SYS_ACTCHART_DEFINE-mst_treatment_set-ind_cond_info":
                    HandleActChartDefine(table);
                    break;

                case "MST_SET_MEDI_NAME-mst_medicine_mix-mix_info":
                    HandleSetMedicine(table, 1);
                    break;

                case "MST_MEDICINE_GROUP-mst_medicine_group-reg_medicine_info":
                    HandleSetMedicine(table, 2);
                    break;
            }
        }

        //add #7854  鄭晨  start
        private void HandleActChartDefine(DataTable childTable)
        {

            // 血液回路
            List<string> LBoold = CommonConfig.Boold[CommonConfig.seriesCd];
            DataTable dt = new DataTable();
            mapFnwDataJson.TryGetValue("SYS_ACTCHART_DEFINE_EQUIP-mst_treatment_set-ind_equip_info", out dt);
            if (LBoold != null)
            {
                foreach (string item in LBoold)
                {
                    DataRow rows = dt.Select(string.Format("EQUIP_CD='{0}'", item)).FirstOrDefault();
                    if (rows != null)
                    {
                        dt.Rows.Remove(rows);
                        DataRow newrows = childTable.Select("CTL_ID='13'").FirstOrDefault();
                        newrows["INIT_VALUE"] = item;
                        break;
                    }
                }
            }
            //10112 zc start
            if (childTable.Rows.Count > 0)
            {
                string SV = childTable.Select("CTL_ID='12'").First()["INIT_VALUE"].ToString();
                if (SV.Equals("0"))
                {
                    //穿刺針(A針)
                    List<string> Lp_A = CommonConfig.p_A[CommonConfig.seriesCd];
                    if (Lp_A != null)
                    {
                        foreach (string item in Lp_A)
                        {
                            DataRow rows = dt.Select(string.Format("EQUIP_CD='{0}'  and SETTING='1'", item)).FirstOrDefault();
                            if (rows != null)
                            {
                                dt.Rows.Remove(rows);
                                DataRow newrows = childTable.Select(string.Format("CTL_ID='{0}'", "9")).FirstOrDefault();
                                newrows["INIT_VALUE"] = item;
                                break;
                            }
                        }
                    }
                    //穿刺針(V針)
                    List<string> Lp_V = CommonConfig.p_V[CommonConfig.seriesCd];
                    if (Lp_V != null)
                    {
                        foreach (string item in Lp_V)
                        {
                            DataRow rows = dt.Select(string.Format("EQUIP_CD='{0}' and SETTING='2'", item)).FirstOrDefault();
                            if (rows != null)
                            {
                                dt.Rows.Remove(rows);
                                DataRow newrows = childTable.Select(string.Format("CTL_ID='{0}'", "10")).FirstOrDefault();
                                newrows["INIT_VALUE"] = item;
                                break;
                            }
                        }
                    }
                    childTable.Rows.Remove(childTable.Select("CTL_ID  in('11')").FirstOrDefault());
                }
                else
                {
                    //穿刺針(SN針)
                    List<string> Lp_SN = CommonConfig.p_SN[CommonConfig.seriesCd];
                    if (Lp_SN != null)
                    {
                        foreach (string item in Lp_SN)
                        {
                            //DataRow rows = dt.Select(string.Format("EQUIP_CD='{0}' and SETTING='3'", item)).FirstOrDefault();
                            DataRow rows = dt.AsEnumerable()
                            .Where(row => row.Field<string>("EQUIP_CD").Equals("SN" + item.Substring(2)) && row.Field<string>("SETTING") == "3")
                            .FirstOrDefault();
                            if (rows != null)
                            {
                                dt.Rows.Remove(rows);
                                DataRow newrows = childTable.Select(string.Format("CTL_ID='{0}'", "11")).FirstOrDefault();
                                newrows["INIT_VALUE"] = item;
                                break;
                            }
                        }
                    }
                    childTable.Rows.Remove(childTable.Select("CTL_ID  in('9')").FirstOrDefault());
                    childTable.Rows.Remove(childTable.Select("CTL_ID  in('10')").FirstOrDefault());
                }
            }
            //10112 zc end
            //10106 start
            if (dt.Rows.Count > 0)
            {
                List<string> litEQUIP = dt.AsEnumerable().Select(r => r["EQUIP_CD"].ToString()).ToList<string>().Distinct().ToList();
                foreach (var item in litEQUIP)
                {
                    bool de = false;
                    foreach (DataRow dr in dt.Select(string.Format("EQUIP_CD='{0}'", item)))
                    {
                        if (!de)
                        {
                            string sumUn = dt.AsEnumerable().Where(row => row["EQUIP_CD"].ToString() == item).Sum(s => int.Parse(s.Field<string>("QUANTITY"))).ToString();
                            DataRow rows = dt.Select(string.Format("EQUIP_CD='{0}'", item)).FirstOrDefault();
                            rows["QUANTITY"] = sumUn;
                            de = true;
                        }
                        else
                        {
                            dt.Rows.Remove(dr);
                        }
                    }
                }
            }
            //10106 end
        }
        //add #7854  鄭晨  end


        // add #12392 gcl start
        private void HandleSetMedicine(DataTable table, int functionCd)
        {

            if (!CommonConfig.isDiff)
            {
                IMakeSqlParameters param = db.GetIMakeSqlParameters();
                param.AddParam(":SERIES_CD", CommonConfig.seriesCd);
                param.AddParam(":FUNCTION_CD", functionCd);
                db.ExecuteSQL(
                    $"DELETE FROM SYNC_SET_MEDICINE WHERE FUNCTION_CD =:FUNCTION_CD  and SERIES_CD=:SERIES_CD ", param.GetParam());


            }
            else if (table.Rows.Count > 0)
            {
                var keyColumn = functionCd == 1
                    ? "SET_MEDICINE_CD"
                    : "MEDICINE_GROUP_CD";

                var codes = string.Join(",", table.AsEnumerable()
                                .Select(r => r[keyColumn] == null || r[keyColumn] == DBNull.Value
                                    ? "NULL"
                                    : $"'{r[keyColumn].ToString().Replace("'", "''")}'"));

                IMakeSqlParameters param = db.GetIMakeSqlParameters();
                param.AddParam(":SERIES_CD", CommonConfig.seriesCd);
                param.AddParam(":FUNCTION_CD", functionCd);
                db.ExecuteSQL(
                    $"DELETE FROM SYNC_SET_MEDICINE WHERE SET_MEDICINE_CD IN ({codes}) " +
                    $"AND FUNCTION_CD = :FUNCTION_CD and SERIES_CD=:SERIES_CD", param.GetParam());
            }

            foreach (DataRow row in table.Rows)
            {
                InsertSyncMedicine(row, functionCd);
            }

        }

        private void InsertSyncMedicine(DataRow item, int functionCd)
        {

            var keyColumn = functionCd == 1
                    ? "SET_MEDICINE_CD"
                    : "MEDICINE_GROUP_CD";
            string code = item[keyColumn] == null || item[keyColumn] == DBNull.Value
                                        ? "NULL"
                                        : item[keyColumn].ToString().Replace("'", "''");

            string medicineCd = item["MEDICINE_CD"] == null || item["MEDICINE_CD"] == DBNull.Value
                                       ? "NULL"
                                       : item["MEDICINE_CD"].ToString().Replace("'", "''");

            string Sql = $@"INSERT INTO SYNC_SET_MEDICINE (SET_MEDICINE_CD, MEDICINE_CD, FUNCTION_CD,SERIES_CD) VALUES(:SET_MEDICINE_CD, :MEDICINE_CD, :FUNCTION_CD,:SERIES_CD)";


            IMakeSqlParameters param = db.GetIMakeSqlParameters();
            param.AddParam(":SET_MEDICINE_CD", code);
            param.AddParam(":MEDICINE_CD", medicineCd);
            param.AddParam(":FUNCTION_CD", functionCd);
            param.AddParam(":SERIES_CD", CommonConfig.seriesCd);
            db.ExecuteSQL(Sql, param.GetParam());

        }
        // add #12392 gcl end

        private void SaveToMap(string xmlName, DataTable table)
        {
            table.TableName = xmlName;
            mapFnwDataJson[xmlName] = table;
        }
        private void getChildXmlConfigName(rootNodeTableInfoChild[] childs, bool isSync, string mstCd)
        {

            if (childs == null) return;

            foreach (var child in childs)
            {
                // 子テーブルのXMLConfigNameを取得
                string childXmlConfigName = child.xmlConfigName;

                BuildChildContext(childXmlConfigName, ref isSync, ref mstCd);

                //mod #10418 start
                MakeSqlDto childCondDto = ExclusiveSqlDispatcher.BuildSqlDto(child.sqlForTool, child.sqlForSync, "", "", isSync, mstCd,null);
                //mod #10418 end

                //add #12229 追加PATID条件 start
                isSync = false;
                //add #12229 追加PATID条件 start

                string childSql = SqlCreator.MakeSqlForAllData(childCondDto);

                //mod FNSI-host_notification_info設定追加 楊 start
                if (string.IsNullOrWhiteSpace(childSql))
                {
                    mapFnwDataJson[childXmlConfigName] = new DataTable();
                    continue;
                }
                //mod FNSI-host_notification_info設定追加 楊 end
                var param = db.GetIMakeSqlParameters();
                if (childSql.Contains(":SERIES_CD")) {
                    param.AddParam(":SERIES_CD",CommonConfig.seriesCd);
                }
                
                // 子テーブル取得
                DataTable childTable = db.SelectTable(childSql, param.GetParam());


                if (childTable == null)
                {
                    mapFnwDataJson[child.xmlConfigName] = new DataTable();
                    continue;
                }

                HandleSpecialBusiness(child.xmlConfigName, childTable);

                SaveToMap(child.xmlConfigName, childTable);
            }
        }

        private DataTable ExecuteSql(string sql, DateTime ConvertDatetime)
        {
            IMakeSqlParameters param = db.GetIMakeSqlParameters();

            if (sql.Contains(":CONVERT_DATETIME"))
                param.AddParam(":CONVERT_DATETIME", ConvertDatetime);

            if (sql.Contains(":SERIES_CD"))
                param.AddParam(":SERIES_CD", CommonConfig.seriesCd);

            return db.SelectTable(sql, param.GetParam());
        }


        private string ApplyNtssColumnRules(
                string convertTableName,
                List<NtssColumn> ntssColumns,
                string mstCd, DataRow row)
        {
            AddCommonColumns(convertTableName, ntssColumns);

            switch (convertTableName)
            {
                case "mst_user":
                    AddRegPasswordDate(ntssColumns);
                    break;

                case "mst_comsv_setting":
                    AddComsvNo(ntssColumns, mstCd);
                    break;

                case "mst_kur":
                    AddKurAuthentication(ntssColumns);
                    break;

                case "mst_pat_event_sub_category":
                    mstCd = BuildSubCategoryMstCd(ntssColumns);
                    break;

                case "mst_pat_event_data_template":
                    mstCd = BuildTemplateMstCd(ntssColumns, row);
                    break;
            }

            return mstCd;
        }
        //10164 start
        private string BuildTemplateMstCd(List<NtssColumn> columns, DataRow row)
        {
            ConvertJsonArrayEventData("input_params", ConvertCommon.Const.CommonConstants.INPUT_PARAMS_ELEMENT_NAME_LIST_MST, row, columns);
            return columns.Where(col => col.name.Equals("fn_template_cd")).FirstOrDefault().value.ToString();
        }

        private string BuildSubCategoryMstCd(List<NtssColumn> columns)
        {
            return columns.Where(col => col.name.Equals("fn_event_category_class")).FirstOrDefault().value.ToString() + columns.Where(col => col.name.Equals("fn_event_category_cd_2")).FirstOrDefault().value.ToString();

        }
        //10164 end
        private void AddCommonColumns(string tableName, List<NtssColumn> columns)
        {

            // facility_cd 施設コードの列が存在しない
            if (!columns.Any(col => col.name.Equals("facility_cd")))
            {
                columns.Insert(0, CreateNtssColumn("facility_cd", NTSS_DATA_TYPE_CHARACTER_VARYING, this.facilityCd, true));
            }

            // reg_date / up_date  MOD 10205_13  start
            if (!tableName.Equals("pat_group_detail"))
            {
                AddIfNotExists(columns,
                    "reg_date",
                    NTSS_DATA_TYPE_TIMESTAMP,
                    CommonConfig.UpDate.ToString(),
                    false);

                AddIfNotExists(columns,
                    "up_date",
                    NTSS_DATA_TYPE_TIMESTAMP,
                    CommonConfig.UpDate.ToString(),
                    false);
            }
            // reg_date / up_date  MOD 10205_13  end

        }

        private void AddIfNotExists(
            List<NtssColumn> columns,
            string name,
            string type,
            string value,
            bool isPrimaryKey)
        {
            if (!columns.Any(c => c.name.Equals(name)))
            {
                columns.Add(CreateNtssColumn(name, type, value, isPrimaryKey));
            }
        }

        // add #11705 reg_password_dateには、コンバート実行日時を登録すること start
        private void AddRegPasswordDate(List<NtssColumn> columns)
        {
            AddIfNotExists(columns,
                "reg_password_date",
                NTSS_DATA_TYPE_TIMESTAMP,
                CommonConfig.UpDate.ToString(),
                false);
        }
        // add #11705 reg_password_dateには、コンバート実行日時を登録すること end

        // add #12230 差分コンバートにより元に戻ってしまう項目がある limingzhe start
        private void AddComsvNo(List<NtssColumn> columns, string mstCd)
        {
            columns.Add(CreateNtssColumn(
             "fn_comsv_no",
             NTSS_DATA_TYPE_NUMERIC,
             mstCd,
             false));
        }
        // add #12230 差分コンバートにより元に戻ってしまう項目がある limingzhe end

        // add #12401 コンバート施設で予定作成が処理中から進まなくなる gaolin start
        private void AddKurAuthentication(List<NtssColumn> columns)
        {
            string json = "{\"data\": [{\"All\": {\"user_id\": \"0\", \"disp_user_id\": \"0\"}, \"Fri\": {\"user_id\": \"0\", \"disp_user_id\": \"0\"}, \"Mon\": {\"user_id\": \"0\", \"disp_user_id\": \"0\"}, \"Sun\": {\"user_id\": \"0\", \"disp_user_id\": \"0\"}, \"Tues\": {\"user_id\": \"0\", \"disp_user_id\": \"0\"}, \"Satur\": {\"user_id\": \"0\", \"disp_user_id\": \"0\"}, \"Thurs\": {\"user_id\": \"0\", \"disp_user_id\": \"0\"}, \"Wednes\": {\"user_id\": \"0\", \"disp_user_id\": \"0\"}}]}";

            columns.Add(CreateNtssColumn("mst_user_authentication", NTSS_DATA_TYPE_CHARACTER_VARYING, json, false));
        }
        // add #12401 コンバート施設で予定作成が処理中から進まなくなる gaolin end

        private DataRow[] GetChildRows(
            string xmlConfigName,
            Dictionary<string, Dictionary<string, DataRow[]>> dic,
            string parentValue, DataRow row
           )
        {
            if (!dic.ContainsKey(xmlConfigName) ||
                !dic[xmlConfigName].ContainsKey(parentValue))
            {
                return new DataRow[] { };
            }

            if (_needRegDate.Contains(xmlConfigName))
            {
                DateTime regDate = DateTime.Parse(row["REG_DATE"].ToString());

                if (xmlConfigName.Equals("PAT_DEVICE_SET-pat_main_history-host_notification_info"))
                {

                    xmlConfigName = "PAT_DEVICE_SET-pat_main_history-device_set_info";
                }
                var source = dic[xmlConfigName][parentValue]
                    .Where(r => (DateTime)r["UP_DATE"] <= regDate);
                return ApplyStrategy(xmlConfigName, source, dic[xmlConfigName][parentValue], regDate, parentValue, row);
            }
            else  if (_needUpDate.Contains(xmlConfigName))
            {
                DateTime regDate = DateTime.Parse(row["REG_DATE"].ToString());

                if (xmlConfigName.Equals("PAT_DEVICE_SET-pat_main_history-host_notification_info"))
                {

                    xmlConfigName = "PAT_DEVICE_SET-pat_main_history-device_set_info";
                }
                var source = dic[xmlConfigName][parentValue]
                    .Where(r => (DateTime)r["REG_DATE"] <= regDate);
                return ApplyStrategy(xmlConfigName, source, dic[xmlConfigName][parentValue], regDate, parentValue, row);
            }
            else {
                return dic[xmlConfigName][parentValue];
            }

            
        }

        private static readonly HashSet<string> _needRegDate =
    new HashSet<string>(StringComparer.OrdinalIgnoreCase)
            {
                "PAT_INSURANCE-pat_personal_main_history-insurance_info",
                "PAT_CONTACT-pat_personal_main_history-other_contact_info",
                "PAT_CONTACT-pat_personal_main_history-pat_contact_info",
                "PAT_RECEIPT_MEMO-pat_personal_main_history-dial_diff_com_info",
                "PAT_MEDICAL_HST-pat_unique_history-medical_hst_info",
                "PAT_INOUT-pat_unique_history-in_out_visit_history_info",
                "PAT_CTR-pat_unique_history-physical_info",
                "PAT_BASIC_INFO-pat_main_history-pat_group_info",
                "PAT_TABOO-pat_main_history-taboo_allergy_info",
                "PAT_RECEIPT_MEMO-pat_main_history-addition_info",
                "PAT_FREE_COMMENT-pat_main_history-pat_memo_info",
                "PAT_REVISE_OFFWATER-pat_main_history-off_water_info",
                "PAT_REVISE_TARE-pat_main_history-tare_info",
            };

        private static readonly HashSet<string> _needUpDate =
            new HashSet<string>(StringComparer.OrdinalIgnoreCase)
          {
               
                "PAT_DEVICE_SET-pat_main_history-host_notification_info",
                "PAT_DEVICE_SET-pat_main_history-device_set_info",
                "PAT_BASIC_INFO-pat_main_history-medical_care_info",
                "PAT_BASIC_INFO-pat_main_history-charge_staff_info",
                "PAT_INFECT-pat_main_history-infect_info"

          };

        private DataRow[] ApplyStrategy(string xmlConfigName, IEnumerable<DataRow> source, DataRow[] rows, DateTime regDate, string parentValue, DataRow row)
        {
            switch (xmlConfigName)
            {
                case "PAT_INSURANCE-pat_personal_main_history-insurance_info":
                case "PAT_CONTACT-pat_personal_main_history-pat_contact_info":
                        var item = source
                            .OrderByDescending(r => r["UP_DATE"])
                            .FirstOrDefault();
                    return item == null ? null : new[] { item };
                case "PAT_CONTACT-pat_personal_main_history-other_contact_info":

                    return source
                       .GroupBy(crow => crow["CTL_NO"])
                       .Select(g => g.OrderByDescending(crow => crow["UP_DATE"]).FirstOrDefault())
                       .OrderBy(crow => crow["CTL_NO"])
                        .ToArray();


                case "PAT_RECEIPT_MEMO-pat_personal_main_history-dial_diff_com_info":

                    // mod #10995 djy start
                    return rows.GroupBy(crow => (DateTime)crow["UP_DATE"])
                        .OrderByDescending(group => group.Key).Where(crow => (DateTime)crow.Key <= regDate).FirstOrDefault()
                        ?.OrderBy(crow => crow["CODE"]).ToArray();
                // mod #10995 djy end


                case "PAT_MEDICAL_HST-pat_unique_history-medical_hst_info":

                    // mod #11201 zc start 
                    return source
                        .GroupBy(crow => crow["CTL_NO"])
                        .Select(g => g.OrderByDescending(crow => crow["UP_DATE"]).FirstOrDefault())
                        .Where(crow => crow["DEL_FLG"].ToString() == "0")
                        .OrderBy(crow => crow["DISP_ORDER"])
                        .ToArray();
                // mod #11201 zc end


                case "PAT_INOUT-pat_unique_history-in_out_visit_history_info":

                    return source
                        .GroupBy(crow => crow["CTL_NO"])
                        .Select(g => g.OrderByDescending(crow => crow["UP_DATE"]).FirstOrDefault())
                        .Where(crow => crow["DEL_FLG"].ToString() == "0")
                        .OrderBy(crow => crow["UP_DATE"])
                        .ToArray();


                case "PAT_CTR-pat_unique_history-physical_info":
                    //10771 zc  start
                    return source
                        .GroupBy(crow => new
                        {
                            RegDate = (DateTime)crow["REG_DATE"],
                            Flag = crow["FLAG"]
                        }).Select(g => g.OrderByDescending(crow => crow["UP_DATE"]).FirstOrDefault())
                        .Where(crow => crow["DEL_FLG"].ToString() == "0").OrderBy(crow => crow["EXAM_DATE"]).ToArray();
                //10771 zc  end

                case "PAT_DEVICE_SET-pat_main_history-host_notification_info":
                case "PAT_DEVICE_SET-pat_main_history-device_set_info":
                case "PAT_BASIC_INFO-pat_main_history-medical_care_info":
                    var item1= source
                       .OrderByDescending(r => r["REG_DATE"])
                       .FirstOrDefault();
                    return item1 == null ? null : new[] { item1 };

                case "PAT_BASIC_INFO-pat_main_history-charge_staff_info":
                    return source
                      .GroupBy(crow => crow["DISP_ORDER"])
                      .Select(g => g.OrderByDescending(crow => crow["REG_DATE"]).FirstOrDefault())
                      .OrderBy(crow => crow["DISP_ORDER"])
                      .ToArray();
                case "PAT_INFECT-pat_main_history-infect_info":
                    return source
                      .GroupBy(crow => crow["INFECTION_CD"])
                      .Select(g => g.OrderByDescending(crow => crow["REG_DATE"]).FirstOrDefault())
                      .OrderBy(crow => crow["INFECTION_CD"])
                      .ToArray();
                case "PAT_BASIC_INFO-pat_main_history-pat_group_info":
                    // add #10735 djy start
                    string patgroupcd = row["PAT_GROUP_CD"].ToString();
                    DateTime GROUP_DATE = DateTime.Parse(row["GROUP_DATE"].ToString());
                    var childRows1 = rows.Where(crow => ((DateTime)crow["UP_DATE"] <= regDate && crow["DEL_DATE"].ToString() != ""
                    && (DateTime)crow["DEL_DATE"] > regDate) || (patgroupcd != "" && (DateTime)crow["UP_DATE"] == GROUP_DATE)
                        ).OrderBy(crow => crow["UP_DATE"]).ToArray();

                    for (int i = 0; i < childRows1.Count(); i++)
                    {
                        DataRow row1 = childRows1[i];
                        row1["CTL_NO"] = i + 1;
                    }
                    return childRows1;
                // add #10735 djy end
                case "PAT_TABOO-pat_main_history-taboo_allergy_info":
                case "PAT_FREE_COMMENT-pat_main_history-pat_memo_info":
                    return source
                      .GroupBy(crow => crow["CTL_NO"])
                      .Select(g => g.OrderByDescending(crow => crow["UP_DATE"]).FirstOrDefault())
                      .ToArray();
                case "PAT_RECEIPT_MEMO-pat_main_history-addition_info":
                    // add #11201 djy start 
                    var childRowsTemp = source
                     .GroupBy(crow => crow["CODE"])
                     .Select(g => g.OrderByDescending(crow => crow["UP_DATE"]).FirstOrDefault())
                      .Where(crow => crow["DEL_FLG"].ToString() == "0")
                      .ToArray();
                    if (childRowsTemp == null)
                    {
                        return childRowsTemp;
                    }

                    if (rstAddData == null || rstAddData.Rows.Count == 0)
                        return childRowsTemp;

                    if (rstAddData != null && rstAddData.Rows.Count > 0)
                    {
                        var rstAddList = rstAddData.AsEnumerable().Where(r => (parentValue.Equals(r["PATID"])) && ((DateTime)r["START_DATE"] <= regDate))?.ToArray();
                        if (rstAddList != null && rstAddList.Length > 0)
                        {
                            for (int i = 0; i < childRowsTemp.Count(); i++)
                            {
                                DataRow rowAdd = childRowsTemp[i];
                                var rstData = rstAddList.Where(r => r["CODE"].Equals(rowAdd["CODE"])).GroupBy(crow => crow["START_DATE"])
                                    .Select(g => g.OrderByDescending(crow => crow["START_DATE"]).FirstOrDefault())?.ToArray();
                                if (rstData != null && rstData.Length > 0)
                                {
                                    rowAdd["LAST_DATE"] = ((DateTime)rstData[0]["START_DATE"]).ToString("yyyyMMdd"); ;
                                }
                            }
                        }
                    }
                    return childRowsTemp;
                // add #11201 djy end 

                case "PAT_REVISE_OFFWATER-pat_main_history-off_water_info":
                case "PAT_REVISE_TARE-pat_main_history-tare_info":
                    return setNullRow(rows).Where(crow => (DateTime)crow["UP_DATE"] <= regDate
                            ).GroupBy(crow => crow["DAY_OF_WEEK"])
                            .Select(g => g.OrderByDescending(crow => crow["UP_DATE"]).FirstOrDefault())
                            .OrderBy(crow => crow["DAY_OF_WEEK"]).ToArray();
                default:
                   return rows;
            }
        }

        private void RemoveUnusedColumns() {

            
            List<string> delColList = new List<string>();
            // add FNSI_患者イベント項目テンプレートマスタ追加 楊 start
            if (!CommonConstants.NOT_REMOVE_TABLE.Contains(this.convertTableName))
            {
                // add FNSI_患者イベント項目テンプレートマスタ追加 楊 end
                foreach (DataColumn col in dtFnwData.Columns)
                {
                    // NTSSのコンバートに使用しない列かつ子テーブルとの連結に使用しない列
                    // 紐付けテーブルからコンバート先の情報を取得
                    DataRow relation = GetRelation(dtFnwData.TableName, col.Caption);
                    if (relation == null && !col.Caption.Equals(GetXmlElementValue("fnwPk")))
                    {
                        delColList.Add(col.Caption);
                        continue;
                    }
                }
                // add FNSI_患者イベント項目テンプレートマスタ追加 楊 start
            }
            // add FNSI_患者イベント項目テンプレートマスタ追加 楊 end

            foreach (string colName in delColList)
            {
                dtFnwData.Columns.Remove(colName);
            }

        }
        private Dictionary<string, Dictionary<string, DataRow[]>> BuildChildDictionary()
        {
            var dic = new Dictionary<string, Dictionary<string, DataRow[]>>();


            foreach (var child in GetXmlElements("child"))
            {
                // XMLファイルの設定名
                var xmlConfigName = GetXmlElementValue(child, "xmlConfigName");
                // 主テーブルの子テーブルに紐付くカラム名
                var parentPk = GetXmlElementValue(child, "parentPk");
                // 子テーブルの主キー名
                var childPk = GetXmlElementValue(child, "childPk");

                //mod #10418 start 
                dic[xmlConfigName] =
                    mapFnwDataJson[xmlConfigName]?
                        .AsEnumerable()
                        .ToLookup(dr => dr[childPk].ToString())
                        .ToDictionary(
                             drGroup => drGroup.Key,
                             drGroup => drGroup.ToArray()
                        )
                    ?? new Dictionary<string, DataRow[]>();
                //mod #10418 end 

                //mod FNSI-host_notification_info設定追加 楊 end
                //add FNSI-No.7716 DWが正しくコンバートされていない limingyang start
                if (xmlConfigName.Equals("PAT_CTR-pat_unique-physical_info") || xmlConfigName.Equals("PAT_CTR-pat_unique_history-physical_info"))
                {
                    Dictionary<string, DataRow[]> req = dic[xmlConfigName];
                    Dictionary<string, DataRow[]> res = new Dictionary<string, DataRow[]>();

                    foreach (var patInfo in req)
                    {
                        DataTable dt = patInfo.Value.CopyToDataTable();
                        dt.TableName = xmlConfigName;
                        dt.Clear();
                        DataRow drRow = null;

                        string patId = patInfo.Key;
                        if (patInfo.Value.Length == 0)
                        {
                            continue;
                        }
                        string oldValue = null;
                        for (int i = 0; i < patInfo.Value.Length; i++)
                        {
                            object dw = patInfo.Value[i]["DW"];
                            string flag = patInfo.Value[i]["FLAG"].ToString();
                            if (dw != null && dw.ToString() != "" && dw.ToString() != "null" && i == 0)
                            {
                                oldValue = dw.ToString();
                            }
                            if (i == 0 || flag.Equals("1"))
                            {
                                drRow = patInfo.Value[i];
                                dt.ImportRow(drRow);
                            }
                            else
                            {
                                if (dw.ToString().Equals(oldValue) == false)
                                {
                                    drRow = patInfo.Value[i];
                                    dt.ImportRow(drRow);
                                }
                            }
                            if (dw != null && dw.ToString() != "" && dw.ToString() != "null" && i > 0)
                            {
                                oldValue = dw.ToString();
                            }
                        }
                        res.Add(patId, dt.Select());
                    }
                    dic[xmlConfigName] = res;
                }
                //add FNSI-No.7716 DWが正しくコンバートされていない limingyang end
            }

            return dic;
        }
        //add #10418 end
    }

}