using System;
using System.Text;
using System.Windows.Forms;
using System.Xml;

namespace FNWConverter
{
    public partial class ModifyInstallParameter : Form
    {
        public ModifyInstallParameter()
        {
            InitializeComponent();
        }

        string filePath;

        public ModifyInstallParameter(string filepath)
        {
            filePath = filepath;
            InitializeComponent();
            System.Timers.Timer timer = new System.Timers.Timer();
            timer.Interval = 10;
            timer.Enabled = true;
            timer.AutoReset = false;
            timer.Elapsed += new System.Timers.ElapsedEventHandler(timer_Elapsed);
            GetConfig();
        }

        public void timer_Elapsed(object o, EventArgs args)
        {
            this.TopMost = true;
            this.Activate();
        }

        public void GetConfig()
        {
            try
            {
                XmlDocument xmlDoc = new XmlDocument();
                xmlDoc.Load(filePath + "app.config");
                XmlNode xn = xmlDoc["configuration"]["userSettings"]["NKSConverter.Properties.Settings"];
                for (int i = 0; i < xn.ChildNodes.Count; i++)
                {
                    String nodeName = xn.ChildNodes[i].Attributes.GetNamedItem("name").Value;
                    XmlNode nodeItem = xn.ChildNodes[i]["value"];
                    if (nodeName == "OraConnStr")
                    {
                        if (nodeItem.InnerText != null && nodeItem.InnerText != "")
                        {
                            for (int j = 0; j < nodeItem.InnerText.Split(';').Length - 1; j++)
                            {
                                if (nodeItem.InnerText.Split(';')[j].Substring(0, 7) == "User Id")
                                {
                                    Uid.Text = nodeItem.InnerText.Split(';')[j].Trim().Remove(0, 8);
                                }
                                else if (nodeItem.InnerText.Split(';')[j].Substring(0, 8) == "Password")
                                {
                                    Pwd.Text = nodeItem.InnerText.Split(';')[j].Trim().Remove(0, 9);
                                }
                                else if (nodeItem.InnerText.Split(';')[j].Substring(0, 11) == "Data Source")
                                {
                                    int ipLenth = nodeItem.InnerText.Split(';')[j].Trim().IndexOf(":");
                                    IP.Text = nodeItem.InnerText.Split(';')[j].Trim().Substring(12, ipLenth - 12);
                                    int portLenth = nodeItem.InnerText.Split(';')[j].Trim().IndexOf("/");
                                    port.Text = nodeItem.InnerText.Split(';')[j].Trim().Substring(ipLenth + 1, portLenth - ipLenth - 1);
                                    int dbNameLenth = nodeItem.InnerText.Split(';')[j].Trim().Length;
                                    DBNAME.Text = nodeItem.InnerText.Split(';')[j].Trim().Substring(portLenth + 1, dbNameLenth - portLenth - 1);
                                    nodeItem.InnerText.Split(';')[j].Trim().Remove(0, dbNameLenth);
                                }
                                else
                                {
                                    OraConnStr.Text += nodeItem.InnerText.Split(';')[j].Trim() + ";";
                                }
                            }
                        }
                    }
                    else if (nodeName == "ConvertRestWebServerIp")
                        ConvertRestWebServerIp.Text = nodeItem.InnerText;
                    else if (nodeName == "ConvertRestInputFilePath")
                        ServPathValue.Text = nodeItem.InnerText.Replace("\\\\", "\\");
                    else if (nodeName == "txtFacilityCd")
                        txtFacilityCd.Text = nodeItem.InnerText;
                }

            }
            catch (Exception ex)
            {
                MessageBox.Show("元の構成情報を取得できませんでした" + ex);
                throw;
            }
        }

        private void btnConcel_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private void btnConfirm_Click(object sender, EventArgs e)
        {
            try
            {
                XmlDocument xmlDoc = new XmlDocument();
                xmlDoc.Load(filePath + "app.config");

                XmlNode xn = xmlDoc["configuration"]["userSettings"]["NKSConverter.Properties.Settings"];
                for (int i = 0; i < xn.ChildNodes.Count; i++)
                {
                    String nodeName = xn.ChildNodes[i].Attributes.GetNamedItem("name").Value;
                    XmlNode nodeItem = xn.ChildNodes[i]["value"];
                    if (nodeName == "OraConnStr")
                    {
                        StringBuilder oraConnStr = new StringBuilder();
                        oraConnStr.Append("User Id=" + Uid.Text + ";");
                        oraConnStr.Append("Password=" + Pwd.Text + ";");
                        oraConnStr.Append("Data Source=" + IP.Text + ":" + port.Text + "/" + DBNAME.Text + ";");
                        oraConnStr.Append(OraConnStr.Text);
                        nodeItem.InnerText = oraConnStr.ToString();
                    }
                    else if (nodeName == "ConvertRestWebServerIp")
                        nodeItem.InnerText = ConvertRestWebServerIp.Text;
                    else if (nodeName == "ConvertRestInputFilePath" || nodeName == "uploadServPathValue")
                    {
                        String itemValue = string.Empty;
                        for (int j = 0; j < ServPathValue.Text.Split('\\').Length - 1; j++)
                        {
                            if (ServPathValue.Text.Split('\\')[j] != string.Empty)
                            {
                                itemValue += ServPathValue.Text.Split('\\')[j] + "\\\\";
                            }
                        }

                        nodeItem.InnerText = itemValue.Substring(0, itemValue.Length - 2);
                    }
                    else if (nodeName == "txtFacilityCd")
                        nodeItem.InnerText = txtFacilityCd.Text;
                }

                xmlDoc.Save(filePath + "app.config");
                MessageBox.Show("正常に変更されました");
                this.Close();
            }
            catch (Exception ex)
            {
                MessageBox.Show("編集に失敗する" + ex);
                throw;
            }
        }
    }
}
