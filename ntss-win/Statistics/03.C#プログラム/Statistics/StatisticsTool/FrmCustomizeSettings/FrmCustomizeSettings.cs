using System;
using System.IO;
using System.Data;
using System.Windows.Forms;
using System.Xml.Serialization;
using Fnw.StatisticsTool.Properties;
using Fnw.StatisticsTool.Csv;
using NKKLoggingLib;
using System.Reflection;

namespace Fnw.StatisticsTool.FrmCustomize
{
    /// <summary>
    /// カスタマイズ設定画面
    /// </summary>
    public partial class FrmCustomizeSettings : StatisticsBase
    {
        /// <summary>
        /// コンストラクタ
        /// </summary>
        public FrmCustomizeSettings() : base(isUserLoggedIn: true)
        {
            InitializeComponent();
            // 基底クラスのコンストラクタでイベント登録
            RegisterEvents(this);
        }

        /// <summary>
        /// 子コントロールに対して再帰的にイベントを登録
        /// </summary>
        /// <param name="control"></param>
        private void RegisterEvents(Control control)
        {
            control.MouseEnter += OnUserActivity;
            control.MouseLeave += OnUserActivity;
            control.MouseMove += OnUserActivity;
            control.KeyDown += OnUserActivity;

            foreach (Control child in control.Controls)
            {
                RegisterEvents(child);
            }
        }

        /// <summary>
        /// フォームロード
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void FrmCustomizeSettings_Load(object sender, EventArgs e)
        {
            NKKLogging.GetInstance().AddLogInfo(DateTime.Now, StatisticsUtility.PRODUCT_NAME,
            GetType().Name, NKKLogging.LOGGING_CLASS.INFO, MethodBase.GetCurrentMethod().Name);

            // 「透析時間設定」設定
            if (CustomizeSettings.Instance.IsDispIndDialysisTime)
            {
                rbDialysisTimeInd.Checked = true;
            }
            else
            {
                rbDialysisTimeRst.Checked = true;
            }

            // 「HDF希釈方法、1ｾｯｼｮﾝあたりの置換液量」設定
            if (CustomizeSettings.Instance.IsDispIndHemodiafiltrationInfo)
            {
                rbHdfInfoInd.Checked = true;
            }
            else
            {
                rbHdfInfoRst.Checked = true;
            }

            // 「カルシウム濃度」補正設定
            if (CustomizeSettings.Instance.IsCorrectionCa)
            {
                rbCorrectionCaYes.Checked = true;
            }
            else
            {
                rbCorrectionCaNo.Checked = true;
            }

            // 「ヘモグロビンA1c」補正設定
            if (CustomizeSettings.Instance.IsCorrectionHbA1c)
            {
                rbCorrectionHbA1cYes.Checked = true;
            }
            else
            {
                rbCorrectionHbA1cNo.Checked = true;
            }
        }

        /// <summary>
        /// OKボタンクリック
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnOK_Click(object sender, EventArgs e)
        {
            CustomizeSettings.Instance.IsDispIndDialysisTime = rbDialysisTimeInd.Checked;
            CustomizeSettings.Instance.IsDispIndHemodiafiltrationInfo = rbHdfInfoInd.Checked;
            CustomizeSettings.Instance.IsCorrectionCa = rbCorrectionCaYes.Checked;
            CustomizeSettings.Instance.IsCorrectionHbA1c = rbCorrectionHbA1cYes.Checked;

            // 現在の設定をXMLファイルに保存する
            CustomizeSettings.SaveToXmlFile();

            //-------------------------------------------------
            // 2015年版対応（各処理の完了状態を表示する）
            //-------------------------------------------------
            ConfirmCompletionStatus(true);

            // ダイアログを閉じる
            this.DialogResult = DialogResult.OK;
            this.Close();
        }

        /// <summary>
        /// キャンセルボタンクリック
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnCancel_Click(object sender, EventArgs e)
        {
            // ダイアログを閉じる
            this.DialogResult = DialogResult.Cancel;
            this.Close();
        }
    }
}
