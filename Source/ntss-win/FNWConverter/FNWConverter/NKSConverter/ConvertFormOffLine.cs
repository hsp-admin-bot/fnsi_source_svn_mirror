using ConvertCommon;
using ConvertCommon.Common;
using ConvertCommon.dto;
using ConvertCommon.parts;
using Newtonsoft.Json;
using NKSConverter.Properties;
using System;
using System.Collections.Generic;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Runtime.InteropServices;
using System.Threading;
using System.Windows.Forms;

namespace NKSConverter
{
    public partial class ConvertFormOffLine : Form
    {

        [DllImport("kernel32.dll", EntryPoint = "SetProcessWorkingSetSize")]
        public static extern int SetProcessWorkingSetSize(IntPtr process, int minSize, int maxSize);

    

        private string orderNo = "0";

        private string orderNoStatus = "0";

        private DataTable dtSeriesCdAndFacilityCdList;

        public ConvertFormOffLine()
        {
            InitializeComponent();
            RegisterEnvent();
            InitForm();
            FormShowState();
            SetSeriesCdAndFacilityCdToDataTable();
        }

        public void FormShowState()
        {
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.WindowState = FormWindowState.Maximized;
        }
        
        private void RegisterEnvent()
        {

            updateLogBtn.Click += new EventHandler(UpdateLogBtn_Click1);
            updateProgressBarBtn.Click += new EventHandler(UpdateProgressBarBtn_Click1);
        }

        private void UpdateProgressBarBtn_Click1(object sender, EventArgs e)
        {
            ShowProgressStart();
        }
        
        private void ShowProgress()
        {

            this.DBConnectFnsi();
            bool timeOut = false;
            System.Timers.Timer timer = new System.Timers.Timer();
            string string_status = "";
            string string_content = "";
            int showLineCount = 0;
            IList<BatchConvertTableStatusDto> batchConvertTableStatusDtoList = new List<BatchConvertTableStatusDto>();
            while (threadProgressBar.IsAlive)
            {
                IAsyncResult result = progressBar1.BeginInvoke(new Action(() =>
                {
                    this.getConvertTableStatus(ref batchConvertTableStatusDtoList);

                    showLineCount = progressBar1.Value;
                    
                    for (int i = showLineCount + 1; i < batchConvertTableStatusDtoList.Count; i++)
                    {
                        if (batchConvertTableStatusDtoList.Count > 0)
                        {
                            //fill status to progress bar
                            string_status = batchConvertTableStatusDtoList[batchConvertTableStatusDtoList.Count - 1].status;
                            string_content = batchConvertTableStatusDtoList[batchConvertTableStatusDtoList.Count - 1].content;

                            if (string_status != null && string_status != "")
                            {
                                //split string to array
                                double[] element = Array.ConvertAll(string_status.Split('/'), s => double.Parse(s));
                                double display_value = 0;
                                if (element.Length >= 2 && element[0] != 0 && element[1] != 0)
                                {
                                    display_value = ((Double)element[0] / (Double)element[1]) * 100;
                                    progressBar1.Value = (int)Math.Floor(display_value);
                                }
                                showTime(convertStartTime, (int)Math.Ceiling(display_value));
                            }
                            else
                            {
                                progressBar1.Value = showLineCount;
                                showTime(convertStartTime, showLineCount);
                            }
                        }
                        else
                        {
                            progressBar1.Value = showLineCount;
                            showTime(convertStartTime, showLineCount);
                        }
                    }
                }));

                if (batchConvertTableStatusDtoList.Count > 0)
                {
                    timer.Stop();
                    timeOut = false;
                    string stopShowMsg = batchConvertTableStatusDtoList[batchConvertTableStatusDtoList.Count - 1].content;
                    if (stopShowMsg == "ジョブ正常終了")
                    {
                        string nowTime = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss");
                        ConvertBase.WriteTraceLog("送信終了時間：" + nowTime + "--------------------------------------------------");
                        timer.Dispose();
                        lstLog.EndInvoke(result);
                        ShowConvertLogStop();
                        progressBar1.Invoke(new Action(() =>
                        {
                            progressBar1.Value = 100;
                        }));
                        // mod #11859_7 limingyang start
                        //MessageBox.Show("移行ジョプ正常終了");
                        UpdateUIFromNonUIThread();
                        // mod #11859_7 limingyang end
                        break;
                    }
                }
                else
                {
                    if (timeOut == false)
                    {
                        timer.Interval = 50000;

                        timer.Elapsed += delegate
                        {
                            progressTimerCall(result);
                            timer.Dispose();
                        };
                        timer.Start();
                    }
                }
                Thread.Sleep(5000);
            }
        }

        // add #11859_7 limingyang start
        private void UpdateUIFromNonUIThread()
        {
            if (this.InvokeRequired)
            {
                this.Invoke(new Action(UpdateUIFromNonUIThread));
            }
            else
            {
                MessageBox.Show(this, "移行ジョブ正常終了", "通知", MessageBoxButtons.OK, MessageBoxIcon.Information);
            }
        }
        // mod #11859_7 limingyang end

        private void showTime(DateTime convertStartTime, int showLineCount)
        {
            DateTime currentTime = DateTime.Now;
            if (showLineCount <= 100)
            {
                if (showLineCount == 0)
                {
                    elapsedTimeLb.Text = currentTime.AddSeconds(((currentTime - convertStartTime).TotalSeconds) * 100).ToString("yyyy/MM/dd HH:mm:ss");
                }
                else
                {
                    elapsedTimeLb.Text = currentTime.AddSeconds(((currentTime - convertStartTime).TotalSeconds / showLineCount) * (100 - showLineCount)).ToString("yyyy/MM/dd HH:mm:ss");
                }
            }
        }

        private void progressTimerCall(object obj)
        {
            if (obj != null)
            {
                progressBar1.EndInvoke((IAsyncResult)obj);
            }
            ShowProgressStop();
        }

        Thread threadProgressBar = null;
        DateTime convertStartTime = DateTime.Now;
        public void ShowProgressStart()
        {
            progressBar1.Value = 0;
            if (threadProgressBar == null || threadProgressBar.ThreadState == System.Threading.ThreadState.Aborted || threadProgressBar.ThreadState == System.Threading.ThreadState.Stopped)
            {
                threadProgressBar = new Thread(ShowProgress);
                threadProgressBar.Name = "ShowConvertProgress";
                threadProgressBar.IsBackground = true;
                threadProgressBar.Start();
            }
        }

        public void ShowProgressStop()
        {
            if (threadProgressBar != null && threadProgressBar.ThreadState != System.Threading.ThreadState.Aborted && threadProgressBar.ThreadState != System.Threading.ThreadState.Stopped)
            {
                threadProgressBar.Abort();
                threadProgressBar.Join();
                Thread.EndThreadAffinity();
                threadProgressBar.DisableComObjectEagerCleanup();
            }
            else
            {
                threadProgressBar.DisableComObjectEagerCleanup();
            }
        }

        private void getConvertTableStatus(ref IList<BatchConvertTableStatusDto> batchConvertTableStatusDtoList)
        {
            string url = NKSConverter.Properties.Settings.Default.ConvertRestTableStatusUrlFormat;

            IList<BatchConvertTableStatusDto> addList = HttpControl.getBatchConvertTableStatus(url, CommonConfig.HashValue, orderNoStatus);

            if (null != addList && addList.Count > 0)
            {
                var newlist = (from BatchConvertTableStatusDto t in addList
                               orderby t.order_no
                               select t).ToList();

                orderNoStatus = newlist.Last().order_no.ToString();

                batchConvertTableStatusDtoList = batchConvertTableStatusDtoList.Union(newlist).ToList<BatchConvertTableStatusDto>();

            }
        }

        delegate void AddItemCallback(ListBox listBoxMsg, string text);
        private void LBAddItem(ListBox listBoxMsg, string text)
        {
            bool scroll = false;
            if (listBoxMsg.TopIndex == listBoxMsg.Items.Count - (int)(listBoxMsg.Height / listBoxMsg.ItemHeight))
                scroll = true;
            if (listBoxMsg.InvokeRequired)
            {
                AddItemCallback d = new AddItemCallback(LBAddItem);
                this.Invoke(d, new object[] { listBoxMsg, text });
            }
            else
            {
                listBoxMsg.Items.Add(text);
            }
            if (scroll)
                listBoxMsg.TopIndex = listBoxMsg.Items.Count - (int)(listBoxMsg.Height / listBoxMsg.ItemHeight);
        }
        /// <summary>
        /// データテーブルの設定
        /// </summary>
        /// <returns>成功：true、失敗：false</returns>
        public void SetSeriesCdAndFacilityCdToDataTable()
        {
            dtSeriesCdAndFacilityCdList = new DataTable();
            dtSeriesCdAndFacilityCdList.Columns.Add("ISSELECTED", typeof(bool));
            dtSeriesCdAndFacilityCdList.Columns.Add("SERIES", typeof(string));
            dtSeriesCdAndFacilityCdList.Columns.Add("SERIES_CD", typeof(string));
            dtSeriesCdAndFacilityCdList.Columns.Add("FACILITY", typeof(string));
            dtSeriesCdAndFacilityCdList.Columns.Add("FACILITY_CD", typeof(string));
            dtSeriesCdAndFacilityCdList.Columns.Add("STATE", typeof(string));

            DataRow newRow = dtSeriesCdAndFacilityCdList.NewRow();
            newRow["ISSELECTED"] = true;
            newRow["SERIES"] = "データ移行元施設コード";
            newRow["SERIES_CD"] = "001";
            newRow["FACILITY"] = "データ移行先施設コード";
            newRow["FACILITY_CD"] = CommonConfig.FacilityCd;
            dtSeriesCdAndFacilityCdList.Rows.Add(newRow);

            // ディフォルト1件目は選択の状態です。
            dtSeriesCdAndFacilityCdList.Rows[0]["ISSELECTED"] = true;

            int y = 12;
            string url = NKSConverter.Properties.Settings.Default.ConvertgetMstFacilityUrlFormat;
            Dictionary<string, string> parameters = new Dictionary<String, String> { { "facilityCd", CommonConfig.HashValue } };
            string response = HttpControl.sendWebRequestPost(url, parameters);
            string flag = string.Empty;
            if (!string.IsNullOrEmpty(response))
            {
                List<MstFacilityDto> mf = JsonConvert.DeserializeObject<List<MstFacilityDto>>(response);
                flag = mf[0].isSchextException;
            }
            panelFacilityCdList.Controls.Clear();
            for (int j = 0; j < dtSeriesCdAndFacilityCdList.Rows.Count; j++)
            {
                int x = 20;
                CheckBox checkBox = new CheckBox();
                if (Convert.ToString(dtSeriesCdAndFacilityCdList.Rows[j]["ISSELECTED"]) == "True")
                {
                    checkBox.Checked = true;
                }
                else
                {
                    checkBox.Checked = false;
                }
                checkBox.Text = "";
                checkBox.Location = new Point(x, y);
                checkBox.Size = new Size(15, 14);
                checkBox.Name = "ISSELECTED" + j;
                checkBox.CheckedChanged += new EventHandler(ISSELECTED_CheckedChanged);

                // データ移行元施設コード
                Label labelGen = new Label();
                labelGen.Text = Convert.ToString(dtSeriesCdAndFacilityCdList.Rows[j]["SERIES"]);
                x = x + 17;
                labelGen.Location = new Point(x, y);
                labelGen.Size = new Size(160, 14);
                labelGen.Name = "SERIES" + j;
                labelGen.TextAlign = ContentAlignment.MiddleCenter;

                // 元施設コード
                TextBox textBoxGen = new TextBox();
                textBoxGen.Text = Convert.ToString(dtSeriesCdAndFacilityCdList.Rows[j]["SERIES_CD"]);
                textBoxGen.Enabled = false;
                x = x + 162;
                textBoxGen.Location = new Point(x, y);
                textBoxGen.Size = new Size(100, 14);
                textBoxGen.Name = "SERIES_CD" + j;

                // データ移行先施設コード
                Label labelSaki = new Label();
                labelSaki.Text = Convert.ToString(dtSeriesCdAndFacilityCdList.Rows[j]["FACILITY"]);
                x = x + 105;
                labelSaki.Location = new Point(x, y);
                labelSaki.Size = new Size(160, 14);
                labelSaki.Name = "FACILITY" + j;
                labelSaki.TextAlign = ContentAlignment.MiddleCenter;

                // 先施設コード
                TextBox textBoxSaki = new TextBox();
                textBoxSaki.Text = CommonConfig.FacilityCd;
                textBoxSaki.ReadOnly = true;

                if (checkBox.Checked)
                {
                    textBoxSaki.Enabled = true;
                }
                else
                {
                    textBoxSaki.Enabled = false;
                }
                x = x + 162;
                textBoxSaki.Location = new Point(x, y);
                textBoxSaki.Size = new Size(100, 14);
                textBoxSaki.Name = "FACILITY_CD" + j;

                // 追加
                panelFacilityCdList.Controls.Add(checkBox);
                panelFacilityCdList.Controls.Add(labelGen);
                panelFacilityCdList.Controls.Add(textBoxGen);
                panelFacilityCdList.Controls.Add(labelSaki);
                panelFacilityCdList.Controls.Add(textBoxSaki);

                y += 23;
            }
        }

        /// <summary>
        /// チェックボックスのイベント
        /// <param>sender</param>
        /// <param>e</param>
        /// </summary>
        private void ISSELECTED_CheckedChanged(object sender, EventArgs e)
        {
            for (int j = 0; j < dtSeriesCdAndFacilityCdList.Rows.Count; j++)
            {
                // チェンジ値はdtSeriesCdAndFacilityCdListに保存する
                if (((CheckBox)sender).Name == ("ISSELECTED" + j))
                {
                    if (((CheckBox)sender).Checked == true)
                    {
                        dtSeriesCdAndFacilityCdList.Rows[j]["ISSELECTED"] = "True";
                    }
                    else
                    {
                        dtSeriesCdAndFacilityCdList.Rows[j]["ISSELECTED"] = "False";
                        dtSeriesCdAndFacilityCdList.Rows[j]["FACILITY_CD"] = "";
                    }

                    // チェックした場合、施設コードは活性になる、その他場合、非活性
                    foreach (Control control in panelFacilityCdList.Controls)
                    {
                        if (control is TextBox)
                        {
                            if (control.Name == ("FACILITY_CD" + j))
                            {
                                if (((CheckBox)sender).Checked == true)
                                {
                                    control.Enabled = true;
                                    control.Text = CommonConfig.FacilityCd;
                                    break;
                                }
                                else
                                {
                                    control.Enabled = false;
                                    control.Text = "";
                                    break;
                                }
                            }
                        }
                    }
                    break;
                }
            }
        }

        private void ShowUpdateLog()
        {
            bool timeOut = false;
            System.Timers.Timer timer = new System.Timers.Timer();
            IList<BatchConvertTableLogDto> batchConvertTableLogDtoList = new List<BatchConvertTableLogDto>();
            while (threadConvertLog.IsAlive)
            {
                IAsyncResult result = lstLog.BeginInvoke(new Action(() =>
                {
                    for (int j = 0; j < dtSeriesCdAndFacilityCdList.Select("ISSELECTED = 'True' and FACILITY_CD <> ''").Length; j++)
                    {
                        setFacilityCd(Convert.ToString(dtSeriesCdAndFacilityCdList.Select("ISSELECTED = 'True' and FACILITY_CD <> ''")[j]["FACILITY_CD"]));
                        this.getConvertTableLog(ref batchConvertTableLogDtoList);
                    }

                    int showLineCount = lstLog.Items.Count;
                    for (int i = showLineCount + 1; i < batchConvertTableLogDtoList.Count; i++)
                    {
                        BatchConvertTableLogDto item = batchConvertTableLogDtoList[i];
                        LBAddItem(lstLog, item.reg_date + " : table " + item.table_name + " 移行" + item.content);
                    }
                }));
                if (batchConvertTableLogDtoList.Count > 0)
                {
                    timer.Stop();
                    timeOut = false;
                    string stopShowMsg = batchConvertTableLogDtoList[batchConvertTableLogDtoList.Count - 1].content;
                    if (stopShowMsg == "ジョブ正常終了")
                    {
                        timer.Dispose();
                        lstLog.EndInvoke(result);
                        ShowConvertLogStop();
                        break;
                    }
                }
                else
                {
                    if (timeOut == false)
                    {
                        timer.Interval = 50000;

                        timer.Elapsed += delegate
                        {
                            timerCall(result);
                            timer.Dispose();
                        };
                        timer.Start();
                    }
                }
                Thread.Sleep(5000);
            }
        }

        private void timerCall(object obj)
        {
            if (obj != null)
            {
                lstLog.EndInvoke((IAsyncResult)obj);
            }
            ShowConvertLogStop();
        }

        Thread threadConvertLog = null;
        public void ShowConvertLogStart()
        {
            lstLog.Items.Clear();
            if (threadConvertLog == null || threadConvertLog.ThreadState == System.Threading.ThreadState.Aborted || threadConvertLog.ThreadState == System.Threading.ThreadState.Stopped)
            {
                threadConvertLog = new Thread(ShowUpdateLog);
                threadConvertLog.Name = "ShowConvertLog";
                threadConvertLog.IsBackground = true;
                threadConvertLog.Start();
            }
        }

        public void ShowConvertLogStop()
        {
            if (threadConvertLog != null && threadConvertLog.ThreadState != System.Threading.ThreadState.Aborted && threadConvertLog.ThreadState != System.Threading.ThreadState.Stopped)
            {
                threadConvertLog.Abort();
                threadConvertLog.Join();
                Thread.EndThreadAffinity();
                threadConvertLog.DisableComObjectEagerCleanup();
            }
            else
            {
                if (threadConvertLog != null)
                {
                    threadConvertLog.DisableComObjectEagerCleanup();
                }
            }
        }

        private void UpdateLogBtn_Click1(object sender, EventArgs e)
        {
            ShowConvertLogStart();
        }

        private void getConvertTableLog(ref IList<BatchConvertTableLogDto> batchConvertTableLogDtoList)
        {
            string url = NKSConverter.Properties.Settings.Default.ConvertRestTableLogUrlFormat;
            IList<BatchConvertTableLogDto> addList = HttpControl.getBatchConvertTableLog(url, orderNo, CommonConfig.HashValue);

            if (null != addList && addList.Count > 0)
            {
                var newlist = (from BatchConvertTableLogDto t in addList
                               orderby t.order_no
                               select t).ToList();

                orderNo = newlist.Last().order_no;

                batchConvertTableLogDtoList = batchConvertTableLogDtoList.Union(newlist).ToList<BatchConvertTableLogDto>();

            }
        }

        public class WaitingForm : Form
        {
            public WaitingForm()
            {
                InitializeForm();
            }

            public void InitializeForm()
            {
                Label label = new Label();
                label.TabIndex = 0;
                label.Text = "ログファイルをアップロードしています";
                label.AutoSize = true;
                label.BringToFront();
                label.Visible = true;
                label.Dock = DockStyle.Fill;
                label.TextAlign = ContentAlignment.MiddleCenter;
                label.Padding = new Padding(10);
                label.ForeColor = Color.Red;
                int labelWidth = label.PreferredWidth + 20;
                int labelHeight = label.PreferredHeight + 20;
                this.ClientSize = new Size(labelWidth, labelHeight);

                this.Text = "少々お待ちください";
                this.FormBorderStyle = FormBorderStyle.FixedDialog;
                this.StartPosition = FormStartPosition.CenterScreen;
                this.ControlBox = false;
                
                this.Controls.Add(label);
            }
        }

        private void InitForm()
        {
            DBConnectFnsi();
            this.FNW_Status.BackColor = Color.Red;
        }

        private void DBConnectFnsi()
        {
            string url = NKSConverter.Properties.Settings.Default.ConvertRestCheckConnection;
            if (HttpControl.isFNsiConnection(url))
            {
                FNSi_Status.Text = "FNSi 接続状態：OK";
                FNSi_Status.BackColor = Color.Green;
            }
            else
            {
                FNSi_Status.Text = "FNSi 接続状態：NG";
                FNSi_Status.BackColor = Color.Red;
            }
        }

        // 入力値保存用
        private DateTime dtpStartDateBefore = DateTime.MinValue;
        private DateTime dtpEndDateBefore = DateTime.MaxValue;
        private void ConvertFormOffLine_MenuComplete(object sender, EventArgs e)
        {

        }
        private void ConvertFormOffLine_FormClosing(object sender, FormClosingEventArgs e)
        { 
            Settings.Default.Save();
            CommonConfig.token = null;
            CommonConfig.LoginUrl= null;
            Environment.Exit(0);
        }
        /// <summary>
        /// テーブルSYNC_FACILITY_CDに反映
        /// </summary>
        public void setFacilityCd(string facilityCd)
        {
            TextBox txtFacilityCdValue = new TextBox();
            txtFacilityCdValue.Text = facilityCd;
        }
    }
}