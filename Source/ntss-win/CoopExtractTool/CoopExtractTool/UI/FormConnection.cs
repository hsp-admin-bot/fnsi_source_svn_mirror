using CoopExtractTool.Datas;
using Oracle.ManagedDataAccess.Client;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Reflection;
using System.Windows.Forms;

namespace CoopExtractTool
{
    public partial class FormConnection : Form
    {
        /// <summary>
        /// コンストラクタ
        /// </summary>
        public FormConnection()
        {
            InitializeComponent();
        }

        /// <summary>
        /// フォームロード時
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void frmConnection_Load(object sender, EventArgs e)
        {
            // 画面タイトルをセット
            var versionInfo = FileVersionInfo.GetVersionInfo(Assembly.GetExecutingAssembly().Location);
            string version = versionInfo.FileVersion;
            this.Text = string.Format("{0}({1}) FNW DB接続", Commons.AppName, version);

            txtHost.Text = ConfigSettingManager.Data.Connection.IPAddress;
        }

        /// <summary>
        /// 接続ボタン押下時
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnConnection_Click(object sender, EventArgs e)
        {

            if (string.IsNullOrEmpty(txtHost.Text) == true)
            {
                MessageBox.Show("Hostが入力されていません。", Commons.AppName, MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }

            // 設定をセットする
            ConfigSettingManager.Data.Connection.IPAddress = txtHost.Text;

            // 接続文字列を取得
            string connectionString = ConfigSettingManager.GetConnectionString();

            using (OracleConnection conn = new OracleConnection(connectionString))
            {
                try
                {
                    conn.Open();
                }
                catch
                {
                    MessageBox.Show("FNWのDBの接続でエラーが発生しました。", Commons.AppName, MessageBoxButtons.OK, MessageBoxIcon.Error);
                    return;
                }

                //-----------------------------------
                // SYS_COOP_INI_DATAの読み込み
                //-----------------------------------
                // クエリを取得
                string query = ConfigSettingManager.Data.DBView.SQL;

                DBDataManager.DBDataList = new List<DBDataItem>();

                try
                {
                    using (OracleCommand command = new OracleCommand(query, conn))
                    using (OracleDataReader reader = command.ExecuteReader())
                    {
                        // DBからデータをリストに格納する
                        while (reader.Read())
                        {
                            DBDataItem addData = new DBDataItem();
                            addData.INI_CLASS = GetReaderValue(reader["INI_CLASS"]);
                            addData.INI_SECTION = GetReaderValue(reader["INI_SECTION"]);
                            addData.INI_KEY = GetReaderValue(reader["INI_KEY"]);
                            addData.UP_DATE = GetReaderValue(reader["UP_DATE"]);
                            addData.SECTION_TITLE = GetReaderValue(reader["SECTION_TITLE"]);
                            addData.KEY_TITLE = GetReaderValue(reader["KEY_TITLE"]);
                            addData.DATA_TYPE = GetReaderValue(reader["DATA_TYPE"]);
                            addData.INI_VALUE = GetReaderValue(reader["INI_VALUE"]);
                            addData.MAX_VALUE = GetReaderValue(reader["MAX_VALUE"]);
                            addData.MIN_VALUE = GetReaderValue(reader["MIN_VALUE"]);
                            addData.DEFAULT_VALUE = GetReaderValue(reader["DEFAULT_VALUE"]);
                            addData.MEMO = GetReaderValue(reader["MEMO"]);
                            addData.SERIES_CD = GetReaderValue(reader["SERIES_CD"]);
                            //addData.SHORT_NAME = GetReaderValue(reader["SHORT_NAME"]);

                            DBDataManager.DBDataList.Add(addData);
                        }
                    }
                }
                catch
                {
                    MessageBox.Show("FNWのDBの読み取りでエラーが発生しました。", Commons.AppName, MessageBoxButtons.OK, MessageBoxIcon.Error);
                    return;
                }

                //-----------------------------------
                // SYS_SERIES_FACILITYの読み込み
                //-----------------------------------
                query = ConfigSettingManager.Data.DBView.SQL_SYS_SERIES_FACILITY;

                DBDataManager.DBFacilityList = new List<DBFacilityDataItem>();

                try
                {
                    using (OracleCommand command = new OracleCommand(query, conn))
                    using (OracleDataReader reader = command.ExecuteReader())
                    {
                        // DBからデータをリストに格納する
                        while (reader.Read())
                        {
                            DBFacilityDataItem addData = new DBFacilityDataItem();
                            addData.SERIES_CD = GetReaderValue(reader["SERIES_CD"]);
                            addData.SHORT_NAME = GetReaderValue(reader["SHORT_NAME"]);

                            DBDataManager.DBFacilityList.Add(addData);
                        }
                    }
                }
                catch
                {
                    MessageBox.Show("FNWのDBの読み取りでエラーが発生しました。", Commons.AppName, MessageBoxButtons.OK, MessageBoxIcon.Error);
                    return;
                }

                // SHORT_NAMEをセットしておく
                for (int i=0;i< DBDataManager.DBDataList.Count; i++)
                {
                    if (DBDataManager.DBDataList[i].SERIES_CD == "all")
                    {
                        // allの代わりに「-」をいれておく
                        DBDataManager.DBDataList[i].SHORT_NAME = "-";
                    }
                    else
                    {
                        int index = DBDataManager.DBFacilityList.FindIndex(d => d.SERIES_CD == DBDataManager.DBDataList[i].SERIES_CD);
                        if(index >= 0)
                        {
                            DBDataManager.DBDataList[i].SHORT_NAME = DBDataManager.DBFacilityList[index].SHORT_NAME;
                        }
                    }
                }

            }

            this.DialogResult = DialogResult.OK;
            this.Close();
        }

        /// <summary>
        /// オラクルのReaderから値を取得する
        /// </summary>
        /// <param name="obj"></param>
        /// <returns></returns>
        public string GetReaderValue(object obj)
        {
            if(obj == DBNull.Value)
            {
                return null;
            }
            else
            {
                return obj.ToString();
            }
        }

        /// <summary>
        /// 終了ボタン押下時
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnEnd_Click(object sender, EventArgs e)
        {
            this.DialogResult = DialogResult.Cancel;
            this.Close();
        }

    }
}
