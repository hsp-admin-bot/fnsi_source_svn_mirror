using NKKLoggingLib;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Odbc;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FNSiViewSyncLogicLib
{
    /// <summary>
    /// ODBCHelperクラス
    /// </summary>
    class ODBCHelper
    {
        #region プライベート定義

        /// <summary>
        /// サービス名称
        /// </summary>
        private readonly String SERVICE_NAME = String.Format("{0,-20}", System.Reflection.Assembly.GetExecutingAssembly().GetName().Name);

        /// <summary>
        /// DB接続用ODBCオブジェクト
        /// </summary>
        private OdbcConnection m_con = new OdbcConnection();


        /// <summary>
        /// トランザクション オブジェクト
        /// </summary>
        private OdbcTransaction m_trans = null;

        #endregion


        #region パブリックメソッド

        /// <summary>
        /// コンストラクタ
        /// </summary>
        public ODBCHelper(string connString)
        {
            // 構築処理
            this.m_con = new OdbcConnection(connString);

            this.m_con.Open();
        }

        /// <summary>
        /// デストラクタ
        /// </summary>
        ~ODBCHelper()
        {
            try
            {
                if (m_con != null)
                {
                    m_con.Close();
                }
            }
            catch (Exception)
            {

            }
        }

        /// <summary>
        /// トランザクションを開始します
        /// </summary>
        public void BeginTransaction()
        {
            this.m_trans = this.m_con.BeginTransaction();
        }


        /// <summary>
        /// トランザクションをコミットします
        /// </summary>
        public void Commit()
        {
            this.m_trans.Commit();
            this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, String.Format("Commit(),Message:{0},{1}", "Commitトランザクション", "コミット成功"));
        }

        /// <summary>
        /// トランザクションをロールバックします
        /// </summary>
        public void Rollback()
        {
            this.m_trans.Rollback();
            this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, String.Format("Rollback(),Message:{0},{1}", "Rollbackトランザクション", "ロールバック成功"));
        }

        /// <summary>
        /// 検索データ
        /// </summary>
        public DataTable Select(string sqlString)
        {
            OdbcCommand cmd = new OdbcCommand(sqlString, this.m_con, this.m_trans);

            try
            {
                OdbcDataAdapter da = new OdbcDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, String.Format("Select(),Message:{0},{1}", sqlString, "クエリに成功しました"));
                return dt;
            }
            catch(Exception ex)
            {
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, String.Format("Select(),Message:{0},{1}", sqlString, ex.ToString()));
                throw ex;
            }
            finally
            {
                cmd.Dispose();
            }
        }

        /// <summary>
        /// 追加データ
        /// </summary>
        public bool Insert(string sqlString)
        {
            OdbcCommand cmd = new OdbcCommand(sqlString, this.m_con, this.m_trans);
            cmd.CommandTimeout = FNSiViewSyncSetting.SqlExecuteTimeout;
            try
            {
                int count = cmd.ExecuteNonQuery();
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, String.Format("Insert(),Message:{0}件登録成功 {1}", count, sqlString));
                return true;
            }
            catch (Exception ex)
            {
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, String.Format("Insert(),Message:{0},{1}", sqlString, ex.ToString()));
                throw ex;
            }
            finally
            {
                cmd.Dispose();
            }
        }

        /// <summary>
        /// 更新データ
        /// </summary>
        public bool Update(string sqlString)
        {
            OdbcCommand cmd = new OdbcCommand(sqlString, this.m_con, this.m_trans);
            cmd.CommandTimeout = FNSiViewSyncSetting.SqlExecuteTimeout;
            try
            {
                cmd.ExecuteNonQuery();
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, String.Format("Update(),Message:{0},{1}", sqlString, "更新に成功しました"));
                return true;
            }
            catch (Exception ex)
            {
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, String.Format("Update(),Message:{0},{1}", sqlString, ex.ToString()));
                throw ex;
                
            }
            finally
            {
                cmd.Dispose();
            }
        }

        /// <summary>
        /// 削除データ
        /// </summary>
        public int Delete(string sqlString)
        {
            OdbcCommand cmd = new OdbcCommand(sqlString, this.m_con, this.m_trans);
            cmd.CommandTimeout = FNSiViewSyncSetting.SqlExecuteTimeout;
            try
            {
                int count = cmd.ExecuteNonQuery();
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, String.Format("Delete(),Message:{0} 削除{1}件 {2}", "削除に成功しました。", count, sqlString));
                return count;
            }
            catch (Exception ex)
            {
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, String.Format("Delete(),Message:{0},{1}", sqlString, ex.ToString()));
                throw ex;
            }
            finally
            {
                cmd.Dispose();
            }
        }

        /// <summary>
        /// 削除データ
        /// </summary>
        public int DeleteByDialysisNo(string sqlString, int dialysisnos)
        {
            OdbcCommand cmd = new OdbcCommand(sqlString, this.m_con, this.m_trans);
            int count = 0;
            try
            {
                count = cmd.ExecuteNonQuery();
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, String.Format("Delete(),Message:{0} 実行{1}件、削除{2}件", "削除に成功しました。", dialysisnos, count));
                return count;
            }
            catch (Exception ex)
            {
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, String.Format("Delete(),Message:{0},{1}", sqlString, ex.ToString()));
                throw ex;
            }
            finally
            {
                cmd.Dispose();
            }
        }

        #endregion
        /// <summary>
        /// ログ記録
        /// </summary>
        /// <param name="dtNow">発生日時</param>
        /// <param name="LoggingClass">ログ区分</param>
        /// <param name="strMesssage">記録メッセージ</param>
        private void AddLogInfo(DateTime dtNow, NKKLogging.LOGGING_CLASS LoggingClass, String strMesssage)
        {
            // ログオブジェクト取得
            NKKLogging log = NKKLogging.GetInstance();

            // ログ記録
            log.AddLogInfo(dtNow, SERVICE_NAME, LoggingClass, strMesssage);
        }

        #region プライベートメソッド
        #endregion
    }
}
