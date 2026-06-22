using ConvertCommon.dto;
using Fnw.IOControl.DB;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;

namespace ConvertCommon.dao
{
    public class SyncConvertHistoryDao
    {
        /// <summary>DBコントロール</summary>
        private DBCtrl db;

        /// <summary>
        /// 引数なしコンストラクタは禁止
        /// </summary>
        private SyncConvertHistoryDao()
        {

        }

        /// <summary>
        /// コンストラクタ
        /// </summary>
        /// <param name="db"></param>
        public SyncConvertHistoryDao(DBCtrl db)
        {
            this.db = db;
        }

       

        /// <summary>
        /// コンバート履歴テーブルへ登録
        /// </summary>
        public void InsertOnlySyncConvertHistory(SyncConvertHistoryDto dto)
        {
            dto.seqNo = GetNextSeqNo();
            this.InsertSyncConvertHistory(dto);
        }

        /// <summary>
        /// コンバート履歴、詳細テーブルへ登録
        /// </summary>
        public void Insert(SyncConvertHistoryDto dto)
        {
            dto.seqNo = GetNextSeqNo();
            this.InsertSyncConvertHistory(dto);
            this.InsertSyncConvertHistoryDtl(dto);
        }

        /// <summary>
        /// コンバート履歴テーブルへ登録
        /// </summary>
        private int InsertSyncConvertHistory(SyncConvertHistoryDto dto)
        {
            IMakeSqlParameters param = db.GetIMakeSqlParameters();
            param.AddParam(":FACILITY_CD", dto.facilityCd);
            param.AddParam(":SEQ_NO", dto.seqNo);
            param.AddParam(":TABLE_KIND", dto.tableKind);
            param.AddParam(":TABLE_NAME", dto.tableName);
            param.AddParam(":CONVERT_DATETIME", dto.convertDatetime);
            param.AddParam(":START_DATE", dto.startDate);
            param.AddParam(":END_DATE", dto.endDate);
            return db.ExecuteSQL(this.GetInsertSyncConvertHistorySql(), param.GetParam());
        }

        private int InsertSyncConvertHistoryDtl(SyncConvertHistoryDto dto)
        {
            int totalCount = 0;
            var filteredList = dto.patidList.Distinct()
                .Where(s => !string.IsNullOrEmpty(s))
                .ToList();
            if (filteredList.Count == 0) return 0;

            int batchSize = 1000;
            for (int i = 0; i < filteredList.Count; i += batchSize)
            {
                var batchList = filteredList.Skip(i).Take(batchSize).ToList();
                totalCount += ExecuteBatchInsert(dto.seqNo, batchList);
            }

            return totalCount;
        }

        private int ExecuteBatchInsert(int seqNo, List<string> batchList)
        {

            StringBuilder sql = new StringBuilder();
            sql.Append("INSERT INTO SYNC_CONVERT_HISTORY_DTL (SEQ_NO, CONVERTTS) ");

            for (int i = 0; i < batchList.Count; i++)
            {
                if (i == 0)
                    sql.Append("SELECT :SEQ_NO, :PATID" + i + " FROM DUAL ");
                else
                    sql.Append("UNION ALL SELECT :SEQ_NO, :PATID" + i + " FROM DUAL ");
            }

            IMakeSqlParameters param = db.GetIMakeSqlParameters();
            param.AddParam(":SEQ_NO", seqNo);

            for (int i = 0; i < batchList.Count; i++)
            {
                param.AddParam(":PATID" + i, batchList[i]);
            }

            return db.ExecuteSQL(sql.ToString(), param.GetParam());
        }

        /// <summary>
        /// SEQ_NOのMAX+1を取得する
        /// </summary>
        /// <returns></returns>
        private int GetNextSeqNo()
        {
            // mod FNSI-空判断追加 楊 start
            var dt = db.SelectTable("select nvl(max(seq_no),0) as seq_no from sync_convert_history");
            if (dt == null)
            {
                return 0;

            }
            return int.Parse(dt.Rows[0]["seq_no"].ToString()) + 1;

            //return int.Parse(db.SelectTable("select nvl(max(seq_no),0) as seq_no from sync_convert_history")
            //    .Rows[0]["seq_no"].ToString()) + 1;
            // mod FNSI-空判断追加 楊 end
        }

        private string GetInsertSyncConvertHistorySql()
        {
            string sql = "INSERT INTO SYNC_CONVERT_HISTORY" +
                " VALUES(" +
                " :SEQ_NO," +
                " :FACILITY_CD," +
                " :TABLE_KIND," +
                " :TABLE_NAME," +
                " :CONVERT_DATETIME," +
                " :START_DATE," +
                " :END_DATE)";
            return sql;
        }

    }
}
