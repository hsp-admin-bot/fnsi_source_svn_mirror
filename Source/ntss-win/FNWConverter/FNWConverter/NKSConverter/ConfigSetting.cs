using ConvertCommon.parts;
using Oracle.ManagedDataAccess.Client;
using System;
using System.Diagnostics;
using System.IO;
using System.Text;
using System.Text.RegularExpressions;
using System.Windows.Forms;
using System.Xml;

namespace NKSConverter
{
    public partial class ConfigSetting : Form
    {
        private bool LinkFlag;
        private bool UrlFlag;
        private string Path;
        private string SqlPlusLink;
        private string url;
        string DBLink;

        public ConfigSetting(string path)
        {
            // インストールパスの取得
            this.Path = path.TrimEnd('\\');

            // 初期化
            LinkFlag = false;
            UrlFlag = false;
            InitializeComponent();

            // add #12685 単体アプリ、サービスの名称見直し limingzhe start
            // 既存設定をUIへ反映（修復/アップグレード時の回顕）
            this.LoadCurrentConfigToForm();
            // add #12685 単体アプリ、サービスの名称見直し limingzhe end

            // 環境変数の設定
            this.SetEnvironmentVariable();

            //add #123338 コンバートツールのデフォルトの設定見直し start
            BindConfigToView();
            //add #123338  コンバートツールのデフォルトの設定見直し end

        }

        // add #12685 単体アプリ、サービスの名称見直し limingzhe start
        private void LoadCurrentConfigToForm()
        {
            try
            {
                string configFile = Path + "\\FNW2FNSI_Converter.config";
                if (!File.Exists(configFile))
                {
                    return;
                }

                XmlDocument xmlDoc = new XmlDocument();
                xmlDoc.Load(configFile);

                XmlNode commonSection = xmlDoc.SelectSingleNode("/configuration/CommonSection");
                if (commonSection == null)
                {
                    return;
                }

                string loadBalancing = "";
                foreach (XmlNode currentNode in commonSection.ChildNodes)
                {
                    string nodeName = currentNode.Name;
                    if (nodeName == "OracleIp")
                        Ip.Text = currentNode.InnerText;
                    else if (nodeName == "OracleUserId")
                        UserName.Text = currentNode.InnerText;
                    else if (nodeName == "OraclePassword")
                        Passworld.Text = currentNode.InnerText;
                    else if (nodeName == "OraclePort")
                        Port.Text = currentNode.InnerText;
                    else if (nodeName == "ConvertRestWebServerIp")
                        URLText.Text = currentNode.InnerText;
                    else if (nodeName == "LoadBalancing")
                        loadBalancing = currentNode.InnerText;
                }

                // LoadBalancing が "server=XX" のときはクラウドを選択し、番号を反映
                if (!string.IsNullOrEmpty(loadBalancing) &&
                    loadBalancing.StartsWith("server=", StringComparison.OrdinalIgnoreCase))
                {
                    string serverNo = loadBalancing.Substring("server=".Length).Trim();
                    decimal serverValue;
                    if (decimal.TryParse(serverNo, out serverValue))
                    {
                        if (serverValue < Balancer.Minimum)
                            serverValue = Balancer.Minimum;
                        if (serverValue > Balancer.Maximum)
                            serverValue = Balancer.Maximum;
                        Balancer.Value = serverValue;
                    }
                    Cloud.Checked = true;
                }
                else
                {
                    Local.Checked = true;
                }
            }
            catch
            {
                // 既存設定の読込失敗時はデフォルト値のまま継続
            }
        }
        // add #12685 単体アプリ、サービスの名称見直し limingzhe end


        //add #123338 コンバートツールのデフォルトの設定見直し start
        private void BindConfigToView()
        {
            string configPath = Path + "\\FNW2FNSI_Converter.config";

            if (string.IsNullOrEmpty(configPath)) {

                return;
            }
            XmlDocument doc = new XmlDocument();
            doc.Load(configPath);
            XmlNode commonSection = doc.SelectSingleNode("/configuration/CommonSection");

            string OracleIp = commonSection.SelectSingleNode("OracleIp").InnerText;
            string OracleUserId = commonSection.SelectSingleNode("OracleUserId").InnerText;
            string OraclePassword = commonSection.SelectSingleNode("OraclePassword").InnerText;
            string OraclePort = commonSection.SelectSingleNode("OraclePort").InnerText;
            string WebServerIp = commonSection.SelectSingleNode("ConvertRestWebServerIp").InnerText;

            string LoadBalancing = commonSection.SelectSingleNode("LoadBalancing").InnerText;

            Ip.Text = OracleIp;
            Port.Text = OraclePort;
            UserName.Text = OracleUserId;
            Passworld.Text = OraclePassword;
            URLText.Text = WebServerIp;

            if (LoadBalancing.Contains("server"))
            {

                Cloud.Checked = true;
                Local.Checked = false;
                Balancer.Text = GetServerNumber(LoadBalancing).ToString();
            }
            else {
                Cloud.Checked = false;
                Local.Checked = true;
            }
        }

        public static int GetServerNumber(string input)
        {
            if (string.IsNullOrWhiteSpace(input))
                return 1;

            var parts = input.Split('=');

            if (parts.Length == 2 && int.TryParse(parts[1].Trim(), out int result))
                return result;

            return 1;
        }
        //add #123338  コンバートツールのデフォルトの設定見直し end

        private void DBTestButton_Click(object sender, EventArgs e)
        {
            if (!checkOraLink())
            {
                return;
            }

            if (CheckLink(DBLink))
            {
                LinkFlag = true;
            }
            else
            {
                LinkFlag = false;
            }
        }

        private bool checkOraLink() {
            // 入力内部チェック
            if (string.IsNullOrEmpty(Ip.Text))
            {
                MessageBox.Show("FNW(oracle)接続先が必要です。");
                return false;
            }
            if (string.IsNullOrEmpty(Port.Text))
            {
                MessageBox.Show("ポートが必要です。");
                return false;
            }
            if (string.IsNullOrEmpty(UserName.Text))
            {
                MessageBox.Show("ユーザー名が必要です。");
                return false;
            }
            if (string.IsNullOrEmpty(Passworld.Text))
            {
                MessageBox.Show("パスワードが必要です。");
                return false;
            }
            string ipv4Pattern = @"^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$";
            if (!Regex.IsMatch(Ip.Text, ipv4Pattern))
            {
                MessageBox.Show("FNW(oracle)接続先に入力されたIPは有効ではありません。");
                return false;
            }
            // 環境構築用
            SqlPlusLink = $"connect {UserName.Text}/{Passworld.Text}@//{Ip.Text}:{Port.Text}/nkkfn3;";
            // Config用
            DBLink = $"User Id={UserName.Text};Password={Passworld.Text};Data Source={Ip.Text}:{Port.Text}/nkkfn3;Pooling=yes;Max Pool Size=30;Min Pool Size=5;Connection Lifetime=0;";
           
            return true;
        }

        private bool checkUrlLink()
        {
            // 入力内部チェック
            if (string.IsNullOrEmpty(URLText.Text))
            {
                MessageBox.Show("サーバ接続先URLが必要です。");
                return false;
            }
            string pattern = @"^(https?:\/\/)((?:\d{1,3}\.){3}\d{1,3}(?::\d+)?|(?:[a-zA-Z0-9\-]+\.)+[a-zA-Z]{2,}(?::\d+)?)$";
            
            if (!Regex.IsMatch(URLText.Text, pattern))
            {
                MessageBox.Show("サーバ接続先URLに登録されたURLは有効ではありません。");
                return false;
            }

            this.url = URLText.Text + "/job/convert/health/check";
            if (Cloud.Checked)
            {
                if (string.IsNullOrEmpty(Balancer.Text))
                {
                    MessageBox.Show("サーバー番号が必要です。");
                    return false;
                }
                this.url = this.url + "?server=" + ((int)Balancer.Value).ToString("D2");
            }
            return true;

        }

        private void OK_Click(object sender, EventArgs e)
        {

            if (!LinkFlag)
            {
                if (!checkOraLink())
                {
                    return;
                }
            }

            if (!UrlFlag)
            {
                if (!checkUrlLink()) 
                {
                    return;
                }
            }

            string modOut = ModifyBuildSetting();

            if (!string.IsNullOrEmpty(modOut))
            {
                MessageBox.Show("環境構築ファイルの読み込みでエラーが発生しました。\n" + modOut);
                return;
            }

            if (BuildCheckBox.Checked)
            {

                string sqlplusOut = OracleBuild();
                // 環境構築エラー発生の場合
                if (!string.IsNullOrEmpty(sqlplusOut))
                {
                    MessageBox.Show("sqlplusが実行できませんでした。\n" +
                        "コンバータツールのインストーラを一旦終了して、oracle をインストールしてください。\n" + sqlplusOut);
                    return;
                }
            }

            if (!SetConfig())
            {
                return;
            }

            this.Close();
        }

        private void DeleteOracleClient()
        {
            string targetDirectory = this.Path + "\\oracle_Client";

            try
            {
                Directory.Delete(targetDirectory, true);
            }
            catch (Exception ex)
            {
                MessageBox.Show("想定外のエラーが発生しました。\n" + ex.Message);
            }
        }

        private void Skip_Click(object sender, EventArgs e)
        {
            DialogResult result = MessageBox.Show("接続設定していません、スキップしていいいですか？",
                                      "Warring",
                                      MessageBoxButtons.YesNo,
                                      MessageBoxIcon.Warning);

            if (result == DialogResult.Yes)
            {
                this.Close();
            }
            else
            {
                return;
            }
        }

        /// <summary>
        /// Oracle接続テスト 
        /// </summary>
        /// <param name="DBLink">Oracle接続文字列</param>
        /// <returns></returns>
        private bool CheckLink(string DBLink)
        {
            try
            {
                using (OracleConnection conn = new OracleConnection(DBLink))
                {
                    conn.Open();
                    MessageBox.Show("FNWのDBに接続成功！");
                    conn.Close();
                }
            }
            catch (OracleException ex)
            {
                MessageBox.Show("Oracleへの接続でエラーが発生しました。\n" + ex.Message);
                return false;
            }
            catch (Exception ex)
            {
                MessageBox.Show("想定外のエラーが発生しました。\n" + ex.Message);
                return false;
            }

            return true;
            
        }

        private void URLTestButton_Click(object sender, EventArgs e)
        {
            if (!checkUrlLink())
            {
                return;
            }
            string ex = null; 
            if (HttpControl.fnsiHealthCheck(this.url,ref ex))
            {
                MessageBox.Show("サーバーへの接続が成功しました。");
                UrlFlag = true;
            }
            else
            {
                MessageBox.Show("サーバーへの接続でエラーが発生しました。\n" + ex);
                UrlFlag = false;
            }
        }

        private string ModifyBuildSetting() {

            Encoding encoding = Encoding.GetEncoding("shift_jis");

            // 環境構築のファイルの設定
            string sqlFileName = Path + "\\Tools\\環境構築\\01_FNW(移行元)環境用スクリプト\\" + "Proc_SQL.sql";
            string sqlFileNameDel = Path + "\\Tools\\環境構築\\01_FNW(移行元)環境用スクリプト\\" + "Del_SQL.sql";
            string datPath = Path + "\\Tools\\環境構築\\01_FNW(移行元)環境用スクリプト";
            string datFileName = datPath + "\\データコンバート環境構築.bat";
            string datFileNameDel = datPath + "\\データコンバート環境構築削除.bat";

            string newSqlString = SqlPlusLink;

            string newDatString = "sqlplus /nolog @.\\Proc_SQL.sql";
            string newDelDatString = "sqlplus /nolog @.\\Del_SQL.sql";

            try
            {
                string[] fileSqlContents = File.ReadAllLines(sqlFileName, encoding);
                int SqlLineToModify = -1;
                for (int i = 0; i < fileSqlContents.Length; i++)
                {
                    if (fileSqlContents[i].Contains("connect"))
                    {
                        SqlLineToModify = i;
                        break;
                    }
                }
                if (SqlLineToModify != -1)
                {
                    fileSqlContents[SqlLineToModify] = newSqlString;

                    File.WriteAllLines(sqlFileName, fileSqlContents, encoding);
                }

                string[] fileDelSqlContents = File.ReadAllLines(sqlFileNameDel, encoding);
                int DelSqlLineToModify = -1;
                for (int i = 0; i < fileDelSqlContents.Length; i++)
                {
                    if (fileDelSqlContents[i].Contains("connect"))
                    {
                        DelSqlLineToModify = i;
                        break;
                    }
                }
                if (DelSqlLineToModify != -1)
                {
                    fileDelSqlContents[DelSqlLineToModify] = newSqlString;

                    File.WriteAllLines(sqlFileNameDel, fileDelSqlContents, encoding);
                }

                string[] fileDatContents = File.ReadAllLines(datFileName, encoding);
                int DatLineToModify = -1;
                for (int i = 0; i < fileDatContents.Length; i++)
                {
                    if (fileDatContents[i].Contains("sqlplus"))
                    {
                        DatLineToModify = i;
                        break;
                    }
                }
                if (DatLineToModify != -1)
                {
                    fileDatContents[DatLineToModify] = newDatString;

                    File.WriteAllLines(datFileName, fileDatContents, encoding);
                }

                string[] fileDelDatContents = File.ReadAllLines(datFileNameDel, encoding);
                int DelDatLineToModify = -1;
                for (int i = 0; i < fileDelDatContents.Length; i++)
                {
                    if (fileDelDatContents[i].Contains("sqlplus"))
                    {
                        DelDatLineToModify = i;
                        break;
                    }
                }
                if (DelDatLineToModify != -1)
                {
                    fileDelDatContents[DelDatLineToModify] = newDelDatString;

                    File.WriteAllLines(datFileNameDel, fileDelDatContents, encoding);
                }
            }
            catch (Exception ex)
            {
                return ex.Message;
            }

            return "";
        }

        /// <summary>
        /// Oracle環境構築
        /// </summary>
        /// <returns></returns>
        private string OracleBuild()
        {
            string datPath = Path + "\\Tools\\環境構築\\01_FNW(移行元)環境用スクリプト";

            // CMDを使用し、データコンバート環境構築.batを実行する
            Process process = new Process();
            process.StartInfo.FileName = "cmd.exe";
            process.StartInfo.Arguments = $"/c cd {datPath} && データコンバート環境構築.bat";
            process.StartInfo.UseShellExecute = false;
            process.StartInfo.RedirectStandardError = true;

            process.Start();

            string ourErr = process.StandardError.ReadToEnd();

            process.WaitForExit();

            return ourErr;
        }

        /// <summary>
        /// Configファイルの設定
        /// </summary>
        /// <returns></returns>
        private bool SetConfig()
        {
            XmlDocument xmlDoc = new XmlDocument();

            try
            {
                // 今のConfigを読み込みする
                xmlDoc.Load(Path + "\\FNW2FNSI_Converter.config");
                XmlNode commonSection = xmlDoc.SelectSingleNode("/configuration/CommonSection");

                // Configの内部設定
                for (int i = 0; i < commonSection.ChildNodes.Count; i++)
                {
                    XmlNode currentNode = commonSection.ChildNodes[i];
                    string nodeName = currentNode.Name;
                    if (nodeName == "OracleIp")
                        currentNode.InnerText = Ip.Text;
                    else if (nodeName == "OracleUserId")
                        currentNode.InnerText = UserName.Text;
                    else if (nodeName == "OraclePassword")
                        currentNode.InnerText = Passworld.Text;
                    else if (nodeName == "OraclePort")
                        currentNode.InnerText = Port.Text;
                    else if (nodeName == "ConvertRestWebServerIp")
                        currentNode.InnerText = URLText.Text;
                    if (nodeName == "LoadBalancing")
                    {
                        if (Cloud.Checked)
                        {
                            string oldItem = currentNode.InnerText;
                            currentNode.InnerText = "server=" + ((int)Balancer.Value).ToString("D2");
                        }
                        else {
                            currentNode.InnerText = "";
                        }
                    }                  
                }

                // Configを保存する
                xmlDoc.Save(Path + "\\FNW2FNSI_Converter.config");
            }
            catch (Exception ex)
            {
                MessageBox.Show("環境構築ファイルの接続先反映に失敗しました。\n" + ex);
                return false;
            }
            return true;
        }

        /// <summary>
        /// 環境変数の設定
        /// </summary>
        private void SetEnvironmentVariable()
        {
            

            // CMD命令設定
            Process process = new Process();
            process.StartInfo.FileName = "cmd.exe";
            process.StartInfo.Arguments = $"/c where oci.dll";
            process.StartInfo.UseShellExecute = false;
            process.StartInfo.RedirectStandardOutput = true;
            process.StartInfo.CreateNoWindow = true;

            // CMDの実行
            process.Start();

            // CMDの戻り値の取得
            string ourPut = process.StandardOutput.ReadToEnd();

            process.WaitForExit();

            // 環境変数取得
            string environment = Environment.GetEnvironmentVariable("Path", EnvironmentVariableTarget.Machine);

            // 環境変数にOracleのoci.dllが含めての判断
            if (!string.IsNullOrEmpty(ourPut))
            {
                if (!string.IsNullOrEmpty(environment))
                {
                    string[] pathList = environment.Split(';');
                    foreach (string path in pathList)
                    {
                        if (ourPut.IndexOf(path, StringComparison.OrdinalIgnoreCase) >= 0)
                        {
                            break;
                        }
                    }
                }
            }

            
        }

        private void Cloud_CheckedChanged(object sender, EventArgs e)
        {
            if (Cloud.Checked)
            {
                Balancer.Visible = true;
                label7.Visible = true;
            }
        }

        private void Local_CheckedChanged(object sender, EventArgs e)
        {
            if (Local.Checked)
            {
                Balancer.Visible = false;
                label7.Visible = false;
            }
        }
    }
}
