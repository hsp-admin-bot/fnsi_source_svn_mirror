using Newtonsoft.Json;
using NKKLoggingLib;
using NKKWeightScaleApp.Commons;
using NKKWeightScaleApp.Controller;
using NKKWeightScaleApp.Models;
using NKKWeightScaleApp.Services;
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Windows.Forms;
using TdcLib;
using TdcSocketLib;
using TdcVersionInfoLib;

namespace NKKWeightScaleApp.Views
{
    public partial class FrmWeightMeasurementScreen : Form
    {
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// サービス名称
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly String SERVICE_NAME = System.Reflection.Assembly.GetExecutingAssembly().GetName().Name;

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ログファイル識別子
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        // mod #9696 アプリケーションログのパスとファイル名の修正。 limingzhe start
        private readonly String LOG_FILE_EXT = "WeightScaleApp";
        // mod #9696 アプリケーションログのパスとファイル名の修正。 limingzhe end
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 設定ファイル名
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly String CONFIG_FILE_NAME = "NKKWeight.config";

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 設定ファイル内ログ設定セッション識別子
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly String CONFIG_LOG_SECTION = "Settings\\Log";

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 設定ファイル内GUI設定セッション識別子
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly String CONFIG_GUI_SECTION = "Settings\\Tool";

        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ログ保持日数[既定：20日]
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private int m_nLogFileKeepNumberDays = 20;

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 表示用ログ情報保持リスト
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private Dictionary<String, String> m_lstViewLogInfo = new Dictionary<String, String>();

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 画面タイトル
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private String m_strAppTitle = String.Empty;

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 初回表示フラグ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private bool m_bFirstShow = true;

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 終了フラグ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private bool m_bExit = false;

        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// GUI待受への接続用クライアントソケットオブジェクト
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private TdcBaseSocketClient m_soc = new TdcBaseSocketClient(1024);

        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 前回画面更新日時
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private DateTime m_BeforeRefreshDateTime = DateTime.MinValue;

        //----------------------------------------------------------------------------------------------------

        private string oldValue;
        private Bed bed;
        private Wheelchair wheelchair;
        private PatientEx patient;
        private List<Common> tareInfoList;
        private List<Common> offWaterInfoList;
        private WeightMeasurementEx weightMeasurement;
        private ConvertTool convertTool = new ConvertTool();
        private bool flagClose = false;
        private string buttonName;

        public FrmWeightMeasurementScreen(PatientEx getPatientEx, string _buttonName, WeightMeasurementEx _weightMeasurement = null, Bed _bed = null)
        {
            InitializeComponent();

            // add #12209 体重計アプリ&ツール　アイコン差し替え 高 start
            this.Icon = Properties.Resources.NKKWeight;
            // add #12209 体重計アプリ&ツール　アイコン差し替え 高 end

            if (_weightMeasurement == null)
            {
                weightMeasurement = new WeightMeasurementEx();
            }
            else
                weightMeasurement = _weightMeasurement;
            buttonName = _buttonName;
            tareInfoList = new List<Common>();
            offWaterInfoList = new List<Common>();
            wheelchair = new Wheelchair();
            patient = getPatientEx;
            if (_bed == null)
                bed = new Bed();
            else
                bed = _bed;
            ChangeBackgroundButton(GetModeButton(buttonName));
            LoadPatientSame(patient);
            ShowPatient();
            LoadSetInfo();
            LoadDataEx();
            SaveData();
            ChangeTextButtonSave();
            // ログ設定
            NKKLogging log = NKKLogging.GetInstance();
            //  識別子
            // mod #9696 アプリケーションログのパスとファイル名の修正。 donghao start
            //log.LogExt = this.LOG_FILE_EXT;
            log.LogExt = this.LOG_FILE_EXT +"_"+ System.Net.Dns.GetHostName();
            // mod #9696 アプリケーションログのパスとファイル名の修正。 donghao end

            //  バージョン情報記録用処理登録(ログが変わった場合にログの先頭に記録するため)
            log.FirstWriteEvent = VersionInfos.GetVersionInfo;

            // 設定ファイル名作成
            String strfile = AppDomain.CurrentDomain.BaseDirectory;
            if (strfile.EndsWith("\\") == false)
            {
                strfile += "\\";
            }
            strfile += this.CONFIG_FILE_NAME;

            // システム共通設定クラス初期化
            SystemSettingInfo sys = SystemSettingInfo.GetInstance();
            if (sys.Load(strfile) == false)
            {
                // 設定読み込み失敗

                throw (new Exception(String.Format("Config,{0}", SystemSettingInfo.GetInstance().Error.ToString())));
            }

            // ログ格納先フォルダ
            log.LogFolder = sys.GetSingleLineValue(CONFIG_LOG_SECTION, "Folder", String.Empty).Trim();
            // ログ保持日数[既定：20日]
            if (Int32.TryParse(sys.GetSingleLineValue(CONFIG_LOG_SECTION, "KeepNumberOfDays", String.Empty).Trim(), out int nwork) && 0 <= nwork)
            {
                // ログ保持日数
                this.m_nLogFileKeepNumberDays = nwork;
            }

            // ログ記録：処理開始
            log.AddLogInfo(DateTime.Now, this.SERVICE_NAME, NKKLogging.LOGGING_CLASS.INFO, "処理開始");

            // GUI用接続先IPアドレス
            String ip = sys.GetSingleLineValue(CONFIG_GUI_SECTION, "IPAddress", "127.0.0.1").Trim();
            // GUI用待受ポート番号
            int nport = 5010;
            if (Int32.TryParse(sys.GetSingleLineValue(CONFIG_GUI_SECTION, "PortNo", String.Empty).Trim(), out nwork) && 0 < nwork)
            {
                nport = nwork;
            }

            // クライアントソケット設定
            this.m_soc.SetParams(ip, nwork, 30 * 1000);
            // 接続/切断時
            this.m_soc.ConnectedHandler = this.Connected;
            // 受信時
            this.m_soc.ReceivedHandler = this.ReceivedMessage;

            // クライアントソケット接続
            this.m_soc.StartConnect();
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// サービスとのクライアントソケット接続/切断時
        /// </summary>
        /// <param name="Sender">ベースオブジェクト</param>
        /// <param name="Status">接続状態</param>
        //----------------------------------------------------------------------------------------------------
        private void Connected(Object Sender, TdcBaseSocket.ConnectionStatus Status)
        {
            // 接続状態判定
            if (Status == TdcBaseSocket.ConnectionStatus.CLOSE || Status == TdcBaseSocket.ConnectionStatus.ERROR)
            {
                // 切断時

                DateTime dtnow = DateTime.Now;
                StringBuilder sbwork = new StringBuilder();

                // 保持要素すべてが対象
                foreach (KeyValuePair<String, String> item in this.m_lstViewLogInfo)
                {
                    // 項目の分割
                    String[] stritems = item.Value.Split('\t');

                    // 状態
                    stritems[1] = "不明";
                    // 内容
                    stritems[3] = "サービスから切断";

                    // 記録内容：種別{TAB}状態{TAB}更新日時{TAB}発生内容{CRLF}
                    sbwork.AppendLine(String.Format("{0}\t{1}\t{2:yyyy/MM/dd HH:mm:ss:ffff}\t{3}", stritems[0], stritems[1], dtnow, stritems[3]));
                }

                // 記録内容をバイナリ化
                Byte[] buff = Encoding.UTF8.GetBytes(sbwork.ToString());

                // 通知
                this.ReceivedMessage(Sender, buff, buff.Length);
            }
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// サービスからのメッセージ受信
        /// </summary>
        /// <param name="Sender">ベースオブジェクト</param>
        /// <param name="cRecvData">受信バッファ</param>
        /// <param name="nRecvSize">受信サイズ</param>
        //----------------------------------------------------------------------------------------------------
        private void ReceivedMessage(Object sender, Byte[] cRecvData, int nRecvSize)
        {
            // 受信データの文字列化
            String strdata = Encoding.UTF8.GetString(cRecvData, 0, nRecvSize);

            // 電文の分割
            String[] stritems = strdata.Split(new String[] { "\r\n" }, StringSplitOptions.RemoveEmptyEntries);
            foreach (String strline in stritems)
            {
                // 項目の分割
                String[] stritem = strline.Split('\t');

                // 処理履歴の保持
                if (this.m_lstViewLogInfo.ContainsKey(stritem[0]) == true)
                {
                    // 該当情報あり

                    //　更新
                    this.m_lstViewLogInfo[stritem[0]] = strline;
                }
                else
                {
                    // 該当情報なし

                    //　新規追加
                    this.m_lstViewLogInfo.Add(stritem[0], strline);
                }

                // 画面が表示されている場合
                if (this.Visible == true)
                {
                    // 画面更新(非同期:匿名メソッドによるデリゲート処理)
                    this.BeginInvoke((MethodInvoker)delegate ()
                    {
                        /* this code handle send message from */
                        ShowWeightMeasureValue(strline);
                    });
                }
            }
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ListView項目更新
        /// </summary>
        /// <param name="strData"></param>
        //----------------------------------------------------------------------------------------------------
        private void ShowWeightMeasureValue(String strData)
        {
            try
            {
                // データの分割
                String[] stritem = strData.Split('\t');

                // データ表示
                int nidx = -1;
                switch (stritem[0].ToUpper())
                {
                    case "WEIGHTSCALE":
                        nidx = 3;
                        break;
                }

                if (nidx == 3)
                {
                    /* Set the string patient id into field search */
                    string measuredValue = getWeightMeasureValue(stritem);
                    if (measuredValue != null)
                    {
                        txtMeasuredValue.Text = measuredValue;
                        SaveData();
                    }
                }
            }
            catch (Exception ex)
            {
            }
            finally
            {
            }
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// Get the pationID on the string
        /// </summary>
        /// <param name="stritem"></param>
        //----------------------------------------------------------------------------------------------------
        private string getWeightMeasureValue(string[] stritem)
        {
            if (stritem.LastOrDefault().Split(',')[1].Contains("kg"))
            {
                string weight = Regex.Replace(stritem.LastOrDefault().Split(',')[1], "[^0-9.]", "");
                decimal.TryParse(weight, out decimal value);
                return convertTool.FormatValue(value);
            }
            return null;
        }

        private void GetWeightMeasurement()
        {
            WeightMeasurementController weightMeasurementController = new WeightMeasurementController();
            WeightMeasurementEx _weightMeasurement = weightMeasurementController.GetByID(patient.PatientID);
            if (_weightMeasurement != null)
            {
                if (_weightMeasurement != null && _weightMeasurement.BodyWeight != string.Empty)
                {
                    _weightMeasurement.BodyWeight = string.Empty;
                    _weightMeasurement.MeasurementValue = string.Empty;
                    _weightMeasurement.WheelchairWeight = string.Empty;
                    _weightMeasurement.MeasurementDate = string.Empty;
                    _weightMeasurement.TareInfo = string.Empty;
                    _weightMeasurement.OffWaterInfo = string.Empty;
                    _weightMeasurement.TargetWaterRemoval = string.Empty;
                    _weightMeasurement.BedCd = string.Empty;
                    _weightMeasurement.DW = "0";
                    _weightMeasurement.AfterLastTime = "0";
                }
                weightMeasurement = _weightMeasurement;
            }
            else
            {
                weightMeasurement.DW = "0";
                weightMeasurement.AfterLastTime = "0";
                weightMeasurement.TargetWeight = "0";
                weightMeasurement.WaterRemovalRestriction = "0";
            }
            
        }

        private void LoadSetInfo()
        {          
            SetInfoController setInfoDefaultController = new SetInfoController();
            SetInfoEx setInfoEx = new SetInfoEx();
            setInfoEx = setInfoDefaultController.GetById(patient.PatientID);
            if (setInfoEx != null)
            {
                weightMeasurement.TargetWeight = setInfoEx.TargetWeight.ToString() ?? string.Empty;
                weightMeasurement.WaterRemovalRestriction = setInfoEx.WaterRemovalRestriction.ToString() ?? string.Empty;
                tareInfoList = setInfoEx.TareInfo;
                offWaterInfoList = setInfoEx.OffWaterInfo;
            }
            else
            {
                DeviceSetInfoDefaultController deviceSetInfoDefaultService = new DeviceSetInfoDefaultController();
                tareInfoList = deviceSetInfoDefaultService.GetTareInfo();
                offWaterInfoList = deviceSetInfoDefaultService.GetOffWaterInfo();
            }          
            DeviceSetInfoDefaultController deviceSetInfoDefaultController = new DeviceSetInfoDefaultController();
            if (tareInfoList == null)
            {
                tareInfoList= deviceSetInfoDefaultController.SetDefaultValueTareOrOffWater(((int)ConfigValue.COMMON_STATUS.TARE_INFO).ToString());
            }
            if (offWaterInfoList == null)
            {
                offWaterInfoList = deviceSetInfoDefaultController.SetDefaultValueTareOrOffWater(((int)ConfigValue.COMMON_STATUS.OFF_WATER_INFO).ToString());
            }
            if (tareInfoList != null)
                lblPackingValue.Text = convertTool.FormatValue(tareInfoList.Sum(item => item.Value) / 1000) + ConfigValue.UNIT_KG;
            if (offWaterInfoList != null)
                lblWaterRemovalCompensationValue.Text = convertTool.FormatValue(offWaterInfoList.Sum(item => item.Value) / 1000) + ConfigValue.UNIT_KG;
        }

        private void LoadDataEx()
        {
            BedController bedController = new BedController();
            bed = bedController.GetByID(weightMeasurement.BedCd);
            if (weightMeasurement.WheelchairWeight != string.Empty && weightMeasurement.WheelchairWeight != null)
            {
                decimal.TryParse(weightMeasurement.WheelchairWeight, out decimal wheelchairWeight);
                lblWheelchairValue.Text = convertTool.FormatValue(wheelchairWeight) + ConfigValue.UNIT_KG;
            }
            else
                lblWheelchairValue.Text = ConfigValue.NOT_DETERMINED;
            if (bed != null && bed.BedID != string.Empty && bed.BedID != null)
            {
                btnSelectBed.Text = bed.BedName;
            }
        }

        private Button GetModeButton(string name)
        {
            if (name != string.Empty)
            {
                if (name == btnWeight.Name)
                {
                    if (weightMeasurement.MeasurementValue != string.Empty && weightMeasurement.MeasurementValue != null && buttonName != string.Empty)
                    {
                        decimal.TryParse(weightMeasurement.MeasurementValue, out decimal measuredValue);
                        txtMeasuredValue.Text = convertTool.FormatValue(measuredValue);
                    }
                    EnableWheelchair(btnWeight);
                    return btnWeight;
                }
                else if (name == btnWeightAndWheelchair.Name)
                {
                    if (weightMeasurement.MeasurementValue != string.Empty && weightMeasurement.MeasurementValue != null && buttonName != string.Empty)
                    {
                        decimal.TryParse(weightMeasurement.MeasurementValue, out decimal measuredValue);
                        txtMeasuredValue.Text = convertTool.FormatValue(measuredValue);
                    }
                    EnableWheelchair(btnWeightAndWheelchair);
                    return btnWeightAndWheelchair;
                }
                else
                {
                    if (weightMeasurement.WheelchairWeight != string.Empty && weightMeasurement.WheelchairWeight != null && buttonName != string.Empty)
                    {
                        decimal.TryParse(weightMeasurement.WheelchairWeight, out decimal wheelchairWeight);
                        txtMeasuredValue.Text = convertTool.FormatValue(wheelchairWeight);
                    }
                    EnableWheelchair(btnWheelchair);
                    return btnWheelchair;
                }
            }
            else
            {
                GetWeightMeasurement();
                txtMeasuredValue.Text = "0";
                if (weightMeasurement.WheelchairWeight != string.Empty && weightMeasurement.MeasurementValue == string.Empty)
                {
                    EnableWheelchair(btnWeightAndWheelchair);
                    return btnWeightAndWheelchair;
                }
                if (weightMeasurement.MeasurementValue != string.Empty && weightMeasurement.WheelchairWeight == string.Empty)
                {
                    EnableWheelchair(btnWheelchair);
                    txtMeasuredValue.Text = string.Empty;
                    return btnWheelchair;
                }
                EnableWheelchair(btnWeight);
                return btnWeight;
            }
        }

        private void ShowPatient()
        {
            lblPatientID.Text = patient.PatientID;
            lblPatientName.Text = patient.PatientName;
        }

        private void LoadPatientSame(PatientEx patient)
        {
            PatientController patientService = new PatientController();
            List<PatientEx> patientList = patientService.GetSameName(patient);
            if (patientList.Count != 0)
            {
                lblPatientSame.Visible = true;
            }
            else
            {
                lblPatientSame.Visible = false;
            }
        }

        private Button GetButtonSelected()
        {
            if (btnWeight.BackColor == SystemColors.ActiveCaption)
                return btnWeight;
            else if (btnWeightAndWheelchair.BackColor == SystemColors.ActiveCaption)
                return btnWeightAndWheelchair;
            else
                return btnWheelchair;
        }

        private void btnDetail_Click(object sender, EventArgs e)
        {
            if (txtMeasuredValue.Text.Trim() == string.Empty)
            {
                if (btnWheelchair.BackColor == SystemColors.ActiveCaption)
                {
                    weightMeasurement.WheelchairWeight = txtMeasuredValue.Text.Trim();
                }
                else if (btnWeight.BackColor == SystemColors.ActiveCaption || btnWeightAndWheelchair.BackColor == SystemColors.ActiveCaption)
                {
                    weightMeasurement.BodyWeight = txtMeasuredValue.Text.Trim();
                    weightMeasurement.MeasurementValue = txtMeasuredValue.Text.Trim();
                }
            }
            FrmWeightMeasurementDetailsScreen frmWeightMeasurementDetailsScreen = new FrmWeightMeasurementDetailsScreen(patient, weightMeasurement, GetButtonSelected().Name, bed);
            Close();
            Hide();
            frmWeightMeasurementDetailsScreen.ShowDialog();
        }

        private void btnSelectWheelchair_Click(object sender, EventArgs e)
        {
            FrmModalWheelchair frmModalWheelchair = new FrmModalWheelchair(GetMessage);
            frmModalWheelchair.ShowDialog();
        }

        private void btnTreatmentConditions_Click(object sender, EventArgs e)
        {
            SetInfoEx setInfoEx = new SetInfoEx();
            setInfoEx.PatientId = patient.PatientID;
            setInfoEx.TargetWeight = weightMeasurement.TargetWeight;
            setInfoEx.TareInfo = tareInfoList;
            setInfoEx.OffWaterInfo = offWaterInfoList;
            setInfoEx.WaterRemovalRestriction = weightMeasurement.WaterRemovalRestriction;
            FrmTreatmentConditionScreen frmTreatmentConditionScreen = new FrmTreatmentConditionScreen(patient, setInfoEx, bed);
            Hide();
            frmTreatmentConditionScreen.ShowDialog();
            Show();
            LoadSetInfo();
            SaveData();
        }

        private void btnPacking_Click(object sender, EventArgs e)
        {
            if (tareInfoList != null)
            {
                FrmModalCommon frmModalCommon = new FrmModalCommon(GetMessageList, tareInfoList);
                frmModalCommon.ShowDialog();
            }
        }

        private void btnWaterRemovalRestriction_Click(object sender, EventArgs e)
        {
            if (offWaterInfoList != null)
            {
                FrmModalCommon frmModalCommon = new FrmModalCommon(GetMessageList, offWaterInfoList);
                frmModalCommon.ShowDialog();
            }
        }

        private void btnCancel_Click(object sender, EventArgs e)
        {
            Close();
        }

        private void btnSelectBed_Click(object sender, EventArgs e)
        {
            FrmModalBed frmModalBed = new FrmModalBed(GetMessage);
            frmModalBed.ShowDialog();
        }

        private void btnSend_Click(object sender, EventArgs e)
        {
            try
            {
                weightMeasurement.PatientID = patient.PatientID;
                if (tareInfoList != null)
                {
                    decimal.TryParse(convertTool.ReplaceValue(lblPackingValue.Text.Trim()), out decimal packingValue);
                    weightMeasurement.TareInfo = packingValue.ToString();
                }
                else
                    weightMeasurement.TareInfo = string.Empty;
                if (offWaterInfoList != null)
                {
                    decimal.TryParse(convertTool.ReplaceValue(lblWaterRemovalCompensationValue.Text.Trim()), out decimal waterRemovalCompensationValue);
                    weightMeasurement.OffWaterInfo = waterRemovalCompensationValue.ToString();
                }
                else
                    weightMeasurement.OffWaterInfo = string.Empty;
                if (bed != null)
                    weightMeasurement.BedCd = bed.BedID;
                else
                    weightMeasurement.BedCd = string.Empty;
                WeightMeasurementController weightMeasurementController = new WeightMeasurementController();
                if (weightMeasurement.BodyWeight != null && weightMeasurement.BodyWeight != string.Empty)
                {
                    if (bed == null || bed.BedID == null)
                    {
                        FrmMessageBox frmMessageBox = new FrmMessageBox(MessageShow.CONFIRM_SEND, MessageShow.CANCEL_BUTTON_NAME, MessageShow.OK_BUTTON_NAME, Text, SetFlagClose);
                        frmMessageBox.ShowDialog();
                        if (flagClose == true)
                        {
                            weightMeasurementController.Insert(weightMeasurement);
                            string strweightMeasurement = JsonConvert.SerializeObject(weightMeasurement);
                            LoggerController.WriteLog("[INFO] Weight measurement: " + strweightMeasurement.ToString(), Text);
                            Close();
                        }
                    }
                    else
                    {
                        FrmConfirmScreen frmConfirmScreen = new FrmConfirmScreen(SetFlagClose, weightMeasurement, patient, bed);
                        Hide();
                        frmConfirmScreen.ShowDialog();
                        if (flagClose == true)
                            Close();
                        else
                            Show();
                    }
                }
                else
                {
                    weightMeasurementController.Insert(weightMeasurement);
                    string strweightMeasurement = JsonConvert.SerializeObject(weightMeasurement);
                    LoggerController.WriteLog("[INFO] Weight measurement: " + strweightMeasurement.ToString(), Text);
                    Close();
                }
            }
            catch (Exception ex)
            {
                LoggerController.WriteLog("[ERROR] " + ex.ToString(), Text);
            }
        }

        private void SetFlagClose(bool value)
        {
            flagClose = value;
        }

        private void GetMessageList(List<Common> commons)
        {
            Common common = commons.FirstOrDefault();
            decimal sum = 0;
            if (common != null)
            {
                if (common.Status == ((int)ConfigValue.COMMON_STATUS.TARE_INFO).ToString())
                {
                    tareInfoList = commons;
                    sum = tareInfoList.Sum(item => item.Value);
                    lblPackingValue.Text = convertTool.FormatValue(sum / 1000) + common.Unit;
                    if (txtMeasuredValue.Text != string.Empty)
                        SaveData();
                }
                else if (common.Status == ((int)ConfigValue.COMMON_STATUS.OFF_WATER_INFO).ToString())
                {
                    offWaterInfoList = commons;
                    sum = offWaterInfoList.Sum(item => item.Value);
                    lblWaterRemovalCompensationValue.Text = convertTool.FormatValue(sum / 1000) + common.Unit;
                    if (txtMeasuredValue.Text != string.Empty)
                        SaveData();
                }
                SaveInfoDefault();
            }
        }

        private void SaveInfoDefault()
        {
            SetInfoController setInfoDefaultController = new SetInfoController();
            SetInfoEx setInfoEx = new SetInfoEx();
            setInfoEx.PatientId = patient.PatientID;
            if (weightMeasurement.TargetWeight != string.Empty)
                setInfoEx.TargetWeight = weightMeasurement.TargetWeight;
            else
                setInfoEx.TargetWeight = null;

            if (weightMeasurement.WaterRemovalRestriction != string.Empty)
                setInfoEx.WaterRemovalRestriction = weightMeasurement.WaterRemovalRestriction;
            else
                setInfoEx.WaterRemovalRestriction = null;
            setInfoEx.TareInfo = tareInfoList;
            setInfoEx.OffWaterInfo = offWaterInfoList;
            setInfoDefaultController.SaveData(setInfoEx);
        }

        private void GetMessage<T>(T t)
        {
            if (t is Bed)
            {
                bed = (Bed)(object)t;
                btnSelectBed.Text = bed.BedName;
            }
            else if (t is Wheelchair)
            {
                wheelchair = (Wheelchair)(object)t;
                if (wheelchair.Weight.ToString() != null && wheelchair.Weight.ToString() != string.Empty)
                {
                    lblWheelchairValue.Text = wheelchair.WeightDisplay.ToString();
                    weightMeasurement.WheelchairWeight = convertTool.ReplaceValue(lblWheelchairValue.Text.Trim());
                }
                else
                {
                    weightMeasurement.WheelchairWeight = string.Empty;
                    lblWheelchairValue.Text = ConfigValue.NOT_DETERMINED;
                }
                if (txtMeasuredValue.Text != string.Empty)
                    SaveData();
            }
        }

        private void TextBox_Leave(object sender, EventArgs e)
        {
            TextBox textBox = sender as TextBox;
            if (textBox.Text.Trim() == ".")
                textBox.Text = string.Empty;
            if (textBox.Text != string.Empty)
            {
                decimal.TryParse(textBox.Text.Trim(), out decimal value);
                textBox.Text = convertTool.FormatValue(value);
            }
            SaveData();
        }

        private void TextBox_Enter(object sender, EventArgs e)
        {
            TextBox textBox = sender as TextBox;
            oldValue = textBox.Text.Trim();
        }

        private void TextBox_KeyPress(object sender, KeyPressEventArgs e)
        {
            TextBox textBox = sender as TextBox;
            decimal.TryParse(textBox.Text.Trim(), out decimal value);
            if (e.KeyChar == (char)13)
            {
                if (textBox.Text.Trim() == ".")
                    textBox.Text = string.Empty;
                if (textBox.Text != string.Empty)
                {
                    textBox.Text = convertTool.FormatValue(value);
                }
                SaveData();
            }
            if (!char.IsDigit(e.KeyChar) && (e.KeyChar != '.') && (e.KeyChar != (char)Keys.Back))
            {
                e.Handled = true;
            }
            if ((e.KeyChar == '.') && ((sender as TextBox).Text.IndexOf('.') > -1))
            {
                e.Handled = true;
            }
            if (char.IsDigit(e.KeyChar))
            {
                int cursorPosLeft = textBox.SelectionStart;
                int cursorPosRight = textBox.SelectionStart + textBox.SelectionLength;
                string result = textBox.Text.Substring(0, cursorPosLeft) + e.KeyChar + textBox.Text.Substring(cursorPosRight);
                string[] parts = result.Split('.');
                if (parts.Length > 1)
                {
                    if (parts[1].Length > 2)
                    {
                        e.Handled = true;
                    }
                }
            }
        }

        private void txtMeasuredValue_TextChanged(object sender, EventArgs e)
        {
            TextBox textBox = sender as TextBox;
            int positionCursor = textBox.SelectionStart;
            decimal.TryParse(textBox.Text.Trim(), out decimal value);
            if (value > ConfigValue.MAX_VALUE)
            {
                textBox.Text = oldValue;
                textBox.SelectionStart = (positionCursor <= 0) ? 0 : positionCursor - 1;
            }
            oldValue = textBox.Text.Trim();
            if (textBox.Text == string.Empty || value == 0)
                btnSend.Enabled = false;
        }

        private void btnWeight_Click(object sender, EventArgs e)
        {
            SwitchMode(sender as Button);
        }

        private void btnWeightAndWheelchair_Click(object sender, EventArgs e)
        {
            SwitchMode(sender as Button);
        }

        private void btnWheelchair_Click(object sender, EventArgs e)
        {
            SwitchMode(sender as Button);
        }

        private void SwitchMode(Button button)
        {
            if (button.BackColor == SystemColors.ActiveCaption)
                return;
            if (((txtMeasuredValue.Text != string.Empty && txtMeasuredValue.Text != "0" && txtMeasuredValue.Text != ConfigValue.NOT_DETERMINED) || (weightMeasurement.MeasurementValue != string.Empty
               && weightMeasurement.MeasurementValue != "0" && weightMeasurement.MeasurementValue != ConfigValue.NOT_DETERMINED)
               || (weightMeasurement.WheelchairWeight != string.Empty && weightMeasurement.WheelchairWeight != "0" && weightMeasurement.WheelchairWeight != ConfigValue.NOT_DETERMINED)))
            {
                FrmMessageBox frmMessageBox = new FrmMessageBox(MessageShow.CONFIRM_DELETE, MessageShow.CANCEL_BUTTON_NAME, MessageShow.CHANGE_BUTTON_NAME, Text, SetFlagClose);
                frmMessageBox.ShowDialog();
                if (flagClose == false)
                    return;
            }
            ClearData();
            ChangeBackgroundButton(button);
            EnableWheelchair(button);
            ChangeTextButtonSave();
            if (btnWheelchair.BackColor == SystemColors.ActiveCaption)
                txtMeasuredValue.Text = string.Empty;
            if (btnWeightAndWheelchair.BackColor == SystemColors.ActiveCaption)
                lblWheelchairValue.Text = ConfigValue.NOT_DETERMINED;
            SaveData();
        }

        private void ChangeTextButtonSave()
        {
            if ((weightMeasurement.BodyWeight != string.Empty || btnWeight.BackColor == SystemColors.ActiveCaption
                || (btnWheelchair.BackColor == SystemColors.ActiveCaption && weightMeasurement.MeasurementValue != string.Empty)
                || (btnWeightAndWheelchair.BackColor == SystemColors.ActiveCaption && weightMeasurement.WheelchairWeight != string.Empty)))
                btnSend.Text = ConfigValue.SEND_NAME;
            else
                btnSend.Text = ConfigValue.SAVE_NAME;
        }


        private void ChangeBackgroundButton(Button button)
        {
            btnWeight.BackColor = SystemColors.Control;
            btnWeightAndWheelchair.BackColor = SystemColors.Control;
            btnWheelchair.BackColor = SystemColors.Control;
            button.BackColor = SystemColors.ActiveCaption;
        }

        private void ClearData()
        {
            txtMeasuredValue.Text = "0";
            txtWeightValue.Text = string.Empty;
            weightMeasurement.BodyWeight = string.Empty;
            weightMeasurement.MeasurementValue = string.Empty;
            weightMeasurement.WheelchairWeight = string.Empty;
            weightMeasurement.TareInfo = string.Empty;
            weightMeasurement.OffWaterInfo = string.Empty;
            weightMeasurement.TargetWaterRemoval = string.Empty;
            weightMeasurement.DW = "0";
            weightMeasurement.AfterLastTime = "0";
            lblWheelchairValue.Text = ConfigValue.NOT_DETERMINED;
            btnSend.Enabled = false;
            bed = null;
            btnSelectBed.Text = ConfigValue.BED_NAME_DEFAULT;
        }

        private void EnableWheelchair(Button button)
        {
            if (button.Name == btnWeightAndWheelchair.Name)
            {
                btnSelectWheelchair.Visible = true;
                lblWheelchairValue.Visible = true;
            }
            else
            {
                btnSelectWheelchair.Visible = false;
                lblWheelchairValue.Visible = false;
            }
        }

        private void SaveData()
        {
            listViewError.Items.Clear();
            if (txtMeasuredValue.Text.Trim() == string.Empty)
            {
                txtWeightValue.Text = ConfigValue.NOT_DETERMINED;
                btnSend.Enabled = false;
                return;
            }
            decimal.TryParse(txtMeasuredValue.Text.Trim(), out decimal measuredValue);
            decimal.TryParse(convertTool.ReplaceValue(lblPackingValue.Text.Trim()), out decimal packingValue);
            decimal result = 0;
            if (btnWeight.BackColor == SystemColors.ActiveCaption)
            {
                result = (measuredValue - packingValue);
                txtWeightValue.Text = convertTool.FormatValue(result);
                weightMeasurement.BodyWeight = result.ToString();
                weightMeasurement.MeasurementValue = measuredValue.ToString();
            }
            else if (btnWeightAndWheelchair.BackColor == SystemColors.ActiveCaption)
            {
                if (weightMeasurement.WheelchairWeight != string.Empty && weightMeasurement.WheelchairWeight!=ConfigValue.NOT_DETERMINED)
                {
                    decimal.TryParse(weightMeasurement.WheelchairWeight, out decimal wheelchairWeight);
                    result = measuredValue - packingValue - wheelchairWeight;
                    weightMeasurement.BodyWeight = result.ToString();
                    txtWeightValue.Text = convertTool.FormatValue(result);
                }
                else
                {
                    weightMeasurement.BodyWeight = string.Empty;
                    txtWeightValue.Text = ConfigValue.NOT_DETERMINED;
                }
                weightMeasurement.MeasurementValue = measuredValue.ToString();
            }
            else if (btnWheelchair.BackColor == SystemColors.ActiveCaption)
            {
                if (weightMeasurement.MeasurementValue != string.Empty && weightMeasurement.MeasurementValue != ConfigValue.NOT_DETERMINED)
                {
                    decimal.TryParse(weightMeasurement.MeasurementValue, out decimal oldMeasurementValue);
                    result = (oldMeasurementValue - packingValue - measuredValue);
                    weightMeasurement.BodyWeight = result.ToString();
                    txtWeightValue.Text = convertTool.FormatValue(result);
                }
                else
                {
                    weightMeasurement.BodyWeight = string.Empty;
                    txtWeightValue.Text =ConfigValue.NOT_DETERMINED;
                }
                weightMeasurement.WheelchairWeight = measuredValue.ToString();
            }

            if (weightMeasurement.BodyWeight != string.Empty&& weightMeasurement.BodyWeight != ConfigValue.NOT_DETERMINED && lblWaterRemovalCompensationValue.Text != string.Empty &&
                weightMeasurement.TargetWeight != string.Empty && weightMeasurement.WaterRemovalRestriction != string.Empty)
            {
                decimal.TryParse(convertTool.ReplaceValue(lblWaterRemovalCompensationValue.Text), out decimal waterRemovalCompensationValue);
                decimal.TryParse(weightMeasurement.TargetWeight, out decimal targetWeight);
                decimal.TryParse(weightMeasurement.WaterRemovalRestriction, out decimal waterRemovalRestriction);
                decimal valueCalulation = result + waterRemovalCompensationValue - targetWeight;
                if (valueCalulation < waterRemovalRestriction)
                {
                    weightMeasurement.TargetWaterRemoval = convertTool.FormatValue(valueCalulation);
                }
                else
                {
                    weightMeasurement.TargetWaterRemoval = waterRemovalRestriction.ToString();
                }
                if (valueCalulation < 0)
                {
                    AddItemToListView(MessageShow.ERROR_MESSAGE_1, 1);
                }
            }
            decimal.TryParse(txtWeightValue.Text.Trim(), out decimal weightValue);
            if (measuredValue <= 0 || (weightMeasurement.BodyWeight != string.Empty && txtWeightValue.Text != string.Empty && weightValue <= 0) || CheckError() == true)
                btnSend.Enabled = false;
            else
                btnSend.Enabled = true;
            ChangeTextButtonSave();
        }

        private void FrmWeightMeasurementScreen_FormClosed(object sender, FormClosedEventArgs e)
        {
            GC.Collect();
            Dispose();
        }

        private void AddItemToListView(string error, int status)
        {
            string[] arr = new string[2];
            arr[0] = status.ToString();
            arr[1] = error;
            ListViewItem itm = new ListViewItem(arr);
            if (status == 1)
                itm.BackColor = Color.Salmon;
            else if (status == 2)
                itm.BackColor = Color.Khaki;
            listViewError.Items.Add(itm);
            if (listViewError.Items.Count > 3)
                listViewError.Columns[1].Width = 1210;
            else
                listViewError.Columns[1].Width = 1229;
        }

        private bool CheckError()
        {
            foreach (ListViewItem item in listViewError.Items)
            {
                if (item.SubItems[0].Text == "1")
                    return true;
            }
            return false;
        }

        private void listViewError_ItemSelectionChanged(object sender, ListViewItemSelectionChangedEventArgs e)
        {
            if (e.IsSelected) e.Item.Selected = false;
        }
    }
}