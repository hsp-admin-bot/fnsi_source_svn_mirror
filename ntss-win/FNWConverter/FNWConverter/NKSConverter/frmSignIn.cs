using ConvertCommon;
using ConvertCommon.Common;
using ConvertCommon.parts;
using Fnw.IOControl.DB;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Windows.Forms;

namespace NKSConverter
{
    public partial class FrmSignIn : Form
    {
        // add #10753 djy start
        private bool isOraOnLine = false;
        private bool isfnSiOnLine = false;
        // add #10753 djy end

        //add 7997 start
        private HashSet<string> facilitycdList = new HashSet<string>();
        //add 7997 end


        public ListBox listboxMsg;
        DBCtrl db = null;
        public FrmSignIn()
        {
            InitializeComponent();
            db = ConvertControl.DBConnectFnw();
            // add #10753 djy start
            this.StartPosition = FormStartPosition.CenterScreen;
            this.FormBorderStyle = FormBorderStyle.FixedSingle;
            // add #10753 djy end

            //add #7997 start 
            if (CacheInformation.Instance.FacilityCd.Equals("1"))
            {
                textBoxScd.Visible = false;
                dataGridView1.Visible = true;
            }
            else {

                textBoxScd.Visible = true;
                dataGridView1.Visible = false;
            }
            //add #7997 end  

        }


        private void sendWebLogin(string user,string pass, HashSet<string>  facilitycdlist)
        {
            string response;
            const String MSG_TITLE = "確認してください";
            try
            {
                string url = NKSConverter.Properties.Settings.Default.ConvertLogin;
                pass = AesEncryption.Encrypt(pass);
                string facility_cd = string.Join(",", facilitycdlist);
                Dictionary<string, string> parameters=  new Dictionary<String, String> { { "login", user }, { "password", pass }, { "facilitycd", facility_cd } };
                CommonConfig.LoginUrl = url;
                response = HttpControl.sendWebRequestPost(url, parameters);
                JObject jsonObject = JObject.Parse(response);
             
                string code = (string)jsonObject["code"];
                if (string.IsNullOrEmpty(code)) {
                    // mod #10753 djy start
                    //MessageBox.Show(this, "サーバーに通信失敗しました。", MSG_TITLE, MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    MessageBox.Show(this, "サーバーへのサインインが失敗しました。IDとパスワードを確認してください。", MSG_TITLE, MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    // mod #10753 djy end
                }
                else
                if (code.Equals("401"))
                {
                    // mod #10753 djy start
                    //MessageBox.Show(this, (string)jsonObject["Message"], MSG_TITLE, MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    MessageBox.Show(this, "サーバーへのサインインが失敗しました。IDとパスワードを確認してください。", MSG_TITLE, MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    // mod #10753 djy end
                }
                else if (code.Equals("200"))
                {
                    string tokenValue = (string)jsonObject["token"];
                    // mod #10753 djy start
                    
                    CommonConfig.token = tokenValue;

                    var hashValueDict = jsonObject["hashvalue"].ToObject<Dictionary<string, string>>();

                    foreach (var item in hashValueDict)
                    {
                        IMakeSqlParameters param = db.GetIMakeSqlParameters();
                        param.AddParam(":FACILITY_CD", item.Key);
                        param.AddParam(":HASH_VALUE", item.Value);
                        CommonConfig.HashValueSet[item.Key] = item.Value;
                        string usql = "update SYNC_FACILITY_CD set HASH_VALUE=:HASH_VALUE where FACILITY_CD=: FACILITY_CD";
                        db.ExecuteSQL(usql, param.GetParam());
                    }
                    var hashValueDicts = jsonObject["hashvalue"].ToObject<Dictionary<string, string>>();
                    var onlyValues = hashValueDicts.Values.ToList();
                    string jsonStr = Newtonsoft.Json.JsonConvert.SerializeObject(onlyValues);

                    if (isOraOnLine)
                    {
                        // add 10859_9 djy start

                        //mod #7997 SQLインジェクション  start
                        //int con = int.Parse(db.SelectTable("select count(*) as COUNT  from SYNC_CONVERT_HISTORY where TABLE_KIND='ORD' and FACILITY_CD in (" + string.Join(",", facilitycdlist.Select(x => $"'{x}'")) + ")").Rows[0]["COUNT"].ToString());
                        IMakeSqlParameters paramCon = db.GetIMakeSqlParameters();
                        List<string> inParams = new List<string>();
                        int idx = 0;

                        foreach (var cd in facilitycdlist)
                        {
                            string paramName = $":FACILITY_CD{idx}";
                            inParams.Add(paramName);
                            paramCon.AddParam(paramName, cd);
                            idx++;
                        }

                        string sqlCon = $@"
                                select count(*) as COUNT
                                from SYNC_CONVERT_HISTORY
                                where TABLE_KIND = 'ORD'
                                  and FACILITY_CD in ({string.Join(",", inParams)})
                            ";

                        DataTable dt = db.SelectTable(sqlCon, paramCon.GetParam());
                        int con = Convert.ToInt32(dt.Rows[0]["COUNT"]);
                        //mod #7997 SQLインジェクション end

                        CommonConfig.Ord_Addition = con.ToString();
                        if (con == 0)
                        {
                            url = NKSConverter.Properties.Settings.Default.ConvergetOrdMainFormat;
                            
                            string result = HttpControl.sendWebRequestPost(url, new Dictionary<String, String> { { "facilityCd", jsonStr } });
                            if (!string.IsNullOrEmpty(result))
                            {
                                if (!result.Equals("0"))
                                {
                                    string sMessage = "既に透析情報がコンバートされています。" + System.Environment.NewLine + "このまま続けると、レコードが重複する可能性があります。" + System.Environment.NewLine + "実行しますか？";
                                    if (MessageBox.Show(sMessage, "", MessageBoxButtons.YesNo, MessageBoxIcon.Question) == DialogResult.No)
                                    {
                                        return;

                                    }

                                }
                            }
                        }
                        // add 10859_9 djy end
                        // mod #10418 コンバータソースコード改善  吉 start
                        //string sql = "UPDATE SYNC_LOGIN SET  LOGIN ='{0}',PASS ='{1}', TOKEN ='{2}'  WHERE ID = '1'";
                        //sql = string.Format(sql, user, pass, tokenValue);
                        //db.SelectTable(sql);

                        string sql = "UPDATE SYNC_LOGIN SET LOGIN = :LOGIN, PASS = :PASS, TOKEN = :TOKEN WHERE ID = '1'";
                        IMakeSqlParameters param = db.GetIMakeSqlParameters();
                        param.AddParam(":LOGIN", user);
                        param.AddParam(":PASS", pass);
                        param.AddParam(":TOKEN", tokenValue);
                        db.ExecuteSQL(sql, param.GetParam());
                        // mod #10418 コンバータソースコード改善  吉 end
                        this.Hide();
                        ConvertForm frmMain = new ConvertForm();
                        frmMain.Show();
                    }
                    else
                    {
                        this.Hide();
                        ConvertFormOffLine frmMainOffLine = new ConvertFormOffLine();
                        frmMainOffLine.Show();
                    }
                    // mod #10753 djy end
                }
                else {
                    // mod #10753 djy start
                    //MessageBox.Show(this, "サーバーに通信失敗しました。", MSG_TITLE, MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    MessageBox.Show(this, "サーバーへのサインインが失敗しました。IDとパスワードを確認してください。", MSG_TITLE, MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    // mod #10753 djy end
                }
            }
            catch (Exception e)
            {
                ConvertBase.WriteErrorLog("sendWebLogin:{0}", e.Message);
                // mod #10753 djy start
                //MessageBox.Show(this, "サーバーに通信失敗しました。", MSG_TITLE, MessageBoxButtons.OK, MessageBoxIcon.Warning);
                MessageBox.Show(this, "サーバーへのサインインが失敗しました。IDとパスワードを確認してください。", MSG_TITLE, MessageBoxButtons.OK, MessageBoxIcon.Warning);
                // mod #10753 djy end
            }
        }

        private void btnLogin_Click(object sender, EventArgs e)
        {

            //add #7997 start 
            if (CacheInformation.Instance.FacilityCd.Equals("0"))
            {
                DataTable dt = (DataTable)dataGridView1.DataSource;

                DataRow dr = dt.Rows[0];

                string sCD = dr["SERIES_CD"] == DBNull.Value
                    ? "001"
                    : dr["SERIES_CD"].ToString();

                dr["SERIES_CD"] = sCD;
                dr["FACILITY_CD"] = textBoxScd.Text;
                dr["chkSelect"] = "1";
            }
            //add #7997 end 


            // mod #10753 djy start
          
            var start = getFaclityCd();
            if (!string.IsNullOrEmpty(start))
            {
                MessageBox.Show(this, start, "確認してください", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }
            if (isfnSiOnLine)
            {
                // 入力チェックでエラーが発生した場合は抜ける
                if (!this.DataCheck("on"))
                {
                    return;
                }
                if (isOraOnLine)
                {
                    SYNC_FACILITY_CD(dataGridView1.Rows);
                }
                sendWebLogin(this.txtLoginID.Text, this.txtPassword.Text, facilitycdList);
                
            }
            else
            {

                if (!this.DataCheck("off"))
                {
                    return;
                }
                CommonConfig.token = null;
                CommonConfig.LoginUrl = null;
                SYNC_FACILITY_CD(dataGridView1.Rows);
                this.Hide();
                ConvertForm frmMain = new ConvertForm();
                frmMain.Show();
            }
            // mod #10753 djy end
        }
        private Boolean DataCheck(string type)
        {

            const String MSG_TITLE = "確認してください";

            if (type.Equals("on")) {
                // ID 確認
                if (String.IsNullOrWhiteSpace(this.txtLoginID.Text))
                {
                    MessageBox.Show(this, "ユーザーIDが未入力です。", MSG_TITLE, MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    this.txtLoginID.Focus();
                    return false;
                }
                // パスワード 確認
                if (String.IsNullOrWhiteSpace(this.txtPassword.Text))
                {
                    MessageBox.Show(this, "パスワードが未入力です。", MSG_TITLE, MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    this.txtPassword.Focus();
                    return false;
                }
            }
            return true;
        }

        

        private void SYNC_FACILITY_CD(DataGridViewRowCollection rows)
        {
            String deleteSql = "DELETE FROM SYNC_FACILITY_CD";

          
            String insertSql = "INSERT INTO SYNC_FACILITY_CD (ID,VALUE,FACILITY_CD,SERIES_CD,HASH_VALUE)" +
                " VALUES(" +
                " :ID," +
                " :VALUE," +
                " :FACILITY_CD," +
                " :SERIES_CD," +
                " :HASH_VALUE" +
                ")";
            try
            {
                db.ExecuteSQL(deleteSql);
                String sSql = "SELECT  * FROM SYS_SYSTEM_DEFINE WHERE ID=450";
                string sVALUE = db.SelectTable(sSql).Rows[0]["VALUE"].ToString();
                int i = 1;
                foreach (DataGridViewRow row in rows)
                {
                    var value = row.Cells["chkSelect"].Value;

                    bool selected =
                        value != null &&
                        value != DBNull.Value &&
                        (value.ToString() == "1" || value.ToString().ToLower() == "true");
                    if (selected)
                    {
                        string fac = row.Cells["FACILITY_CD"].Value?.ToString();
                        string series = row.Cells["SERIES_CD"].Value?.ToString();
                        IMakeSqlParameters param = db.GetIMakeSqlParameters();
                        param.AddParam(":ID", i);
                        param.AddParam(":VALUE", sVALUE);
                        param.AddParam(":FACILITY_CD", fac);
                        param.AddParam(":SERIES_CD", series);
                        if (CommonConfig.HashValueSet.ContainsKey(fac))
                        {
                            param.AddParam(":HASH_VALUE", CommonConfig.HashValueSet[fac]);
                        }
                        else
                        {
                            param.AddParam(":HASH_VALUE", DBNull.Value);
                        }
                       
                        db.ExecuteSQL(insertSql, param.GetParam());
                        i++;

                    }
                }
               
            }
            catch (Exception e)
            {

                MessageBox.Show(e.Message);
            }
            
        }

        private void FrmSignIn_Load(object sender, EventArgs e)
        {
            // mod #10753 djy start
           
            if (db != null)
            {
                String selectSql = @"SELECT
                            s.SERIES_CD, 
	                        f.FACILITY_CD, CASE WHEN f.SERIES_CD IS NOT NULL THEN 1 ELSE 0 END AS chkSelect
                        FROM
                          SYS_SERIES_FACILITY s left join
                           SYNC_FACILITY_CD f on s.SERIES_CD = f.SERIES_CD
                          WHERE s.DEL_FLG = '0'   AND s.DISP_FLG = '1'
                        ORDER BY s.DISP_ORDER, s.SERIES_CD";
                DataTable dt = db.SelectTable(selectSql);
                if (dt.Rows.Count > 0)
                {
                    dataGridView1.DataSource = dt;
                }

                //add 7997 start

                if (CacheInformation.Instance.FacilityCd.Equals("0"))
                {

                    textBoxScd.Text =dt.Rows[0].Field<string>("FACILITY_CD");
                }
                //add 7997 end

                isOraOnLine = true;
            }

            isfnSiOnLine = fnsidbCheck();

            if (!isOraOnLine && !isfnSiOnLine)
            {
                MessageBox.Show(this, "FNWにもコンバートサーバにも接続できませんでした。各接続を確認してください。", "確認してください", MessageBoxButtons.OK, MessageBoxIcon.Error);
                this.Close();
            }
            // mod #10753 djy end
        }

        // add #10753 djy start
        private bool fnsidbCheck()
        {
            bool rn = false;
            string url = NKSConverter.Properties.Settings.Default.ConvertHealthCheck;
            //add #12338 start
            url = string.Format(url,
                           CommonConfig.ConvertRestWebServerIp,
                           CommonConfig.ConvertRestWebServerPort);
            //mod #12450 コンバート出力後にサーバー処理が続けて実行ができない start 
            if (!string.IsNullOrEmpty(CommonConfig.LoadBalancing) && !url.Contains("server"))
            //mod #12450 コンバート出力後にサーバー処理が続けて実行ができない end 
            {
                url += "?" + CommonConfig.LoadBalancing;
            }
            //add #12338 end
            if (HttpControl.fnsiHealthCheck(url))
            {
                rn = true;
            }
            return rn;
        }

        // add #10753 djy end

        //add 7997 start
        private bool HasAnyChecked()
        {
            foreach (DataGridViewRow row in dataGridView1.Rows)
            {
                var value = row.Cells["chkSelect"].Value;

                bool isChecked =
                    value != null &&
                    value != DBNull.Value &&
                    (value.ToString() == "1" || value.ToString().ToLower() == "true");

                if (isChecked)
                {
                    return true;
                }
            }

            return false;

        }

        //add 7997 start
        private string  getFaclityCd() {

            facilitycdList.Clear();
            if (!HasAnyChecked())
            {
                return "少なくとも一つ施しを選んでください！";

            }
            foreach (DataGridViewRow row in dataGridView1.Rows)
            {
                var value = row.Cells["chkSelect"].Value;

                bool isChecked =
                    value != null &&
                    value != DBNull.Value &&
                    (value.ToString() == "1" || value.ToString().ToLower() == "true");
                if (isChecked)
                {
                    string fac = row.Cells["FACILITY_CD"].Value?.ToString();
                    if (string.IsNullOrEmpty(fac)) {
                        return "施設コード未入力です。";
                    }else if (!Validator.CheckHalfWidthAlphaNumeric(6, fac)) {
                        return $"「{fac}」施設コードは半角英数字6桁で入力してください。";
                    }

                    if (!facilitycdList.Add(fac))
                    {
                        return $"FACILITY_CD「{fac}」重複があります。";
                    }
                }
            }
            return null;

        }
        //add 7997 end
    }
}
