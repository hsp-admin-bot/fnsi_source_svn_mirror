using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using static LayoutDesigner.MstReportData;

using RldMsgBox = LayoutDesignerUtilityLib.RldMessageBox;
using RldUtility = LayoutDesignerUtilityLib.LayoutDesignerUtility;

namespace LayoutDesigner
{
    /// <summary>
    /// 帳票履歴リスト表示画面
    /// </summary>
    public partial class frmLayoutHistoryList : LayoutDesignerUtilityLib.Controls.frmRldSizableBase
    {
        #region メンバプロパティ定義

        /// <summary>
        /// 帳票情報
        /// </summary>
        public MstReportData SelectReportData { get; set; } = new MstReportData();

        /// <summary>
        /// 更新結果。
        /// </summary>
        public bool UpdateResult { get; set; } = false;

        #endregion

        #region メンバプロパティ定義(private)

        /// <summary>
        /// 帳票履歴 表示用データクラス
        /// </summary>
        private class ReportHistory
        {
            /// <summary>
            /// 版数
            /// </summary>
            public string ctlNo { get; set; }

            /// <summary>
            /// 適用
            /// </summary>
            public string IsSelect { get; set; }

            /// <summary>
            /// 作成日時
            /// </summary>
            public string UpdDate { get; set; }

            /// <summary>
            /// 更新者
            /// </summary>
            public string UpdUserName { get; set; }
        }

        /// <summary>
        /// DataGridView に表示するすべてのデータを保持します。
        /// </summary>
        private BindingList<ReportHistory> ReportHistoryData { get; set; } = new BindingList<ReportHistory>();

        /// <summary>
        /// 適用中
        /// </summary>
        private String IsSelectName = "適用中";

        #endregion

        #region 生成と破棄
        public frmLayoutHistoryList()
        {
            InitializeComponent();
        }
        #endregion

        #region メンバ関数定義(override...)

        /// <summary>
        /// Form.Load イベントを発生させます。
        /// </summary>
        /// <param name="e"></param>
        protected override void OnLoad(EventArgs e)
        {
            base.OnLoad(e);

            // 帳票履歴を設定する
            if (SelectReportData != null && SelectReportData.ReportHstInfo != null
                        && SelectReportData.ReportHstInfo.ReportHstList != null && SelectReportData.ReportHstInfo.ReportHstList.Count > 0)
            {
                // mod #11501 レイアウトデザイナのユーザビリティ改善 高 start
                //foreach (var hstInfo in SelectReportData.ReportHstInfo.ReportHstList.OrderByDescending(dl => (dl.IsSelect, dl.UpdDate)))
                foreach (var hstInfo in SelectReportData.ReportHstInfo.ReportHstList.OrderByDescending(dl => (int.Parse(dl.CtlNo))))
                // mod #11501 レイアウトデザイナのユーザビリティ改善 高 end
                {
                    ReportHistory data = new ReportHistory();


                    data.ctlNo = hstInfo.CtlNo;

                    data.IsSelect = "";
                    if (MstReportData.VAL_IS_SELECT_DONE.Equals(hstInfo.IsSelect))
                    {
                        data.IsSelect = IsSelectName;
                    }

                    DateTime dtDateTime = new DateTime();
                    TdcLib.TdcLib.GetStringToDateTime("yyyyMMddHHmmss", hstInfo.UpdDate, out dtDateTime);
                    data.UpdDate = dtDateTime.ToString("yyyy/MM/dd HH:mm");

                    data.UpdUserName = hstInfo.UpdUserName;

                    ReportHistoryData.Add(data);
                }
            }
            dgvLayOutHistory.DataSource = ReportHistoryData;

            // OKボタンが無効です
            this.btnOK.Enabled = false;
        }

        #endregion

        #region コントロールイベントハンドラ定義

        /// <summary>
        /// キャンセルボタンの Click イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnCancel_Click(object sender, EventArgs e)
        {
            this.DialogResult = DialogResult.Cancel;
            this.Close();
        }

        /// <summary>
        /// OKボタンの Click イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnOK_Click(object sender, EventArgs e)
        {
            if(RldMsgBox.Show(this, "適用します。よろしいですか。", "確認", MessageBoxButtons.YesNo, MessageBoxIcon.Exclamation) == DialogResult.Yes)
            {
                // 版数
                String selectCtlNo = String.Empty;
                for (int i = 0; i < dgvLayOutHistory.Rows.Count; i++)
                {
                    if (dgvLayOutHistory.Rows[i].Selected == true)
                    {
                        // 選択版数
                        selectCtlNo = dgvLayOutHistory.Rows[i].Cells[0].Value.ToString();
                        break;
                    }
                }


                // ④変更した内容を保存します。
                UpdateResult = false;

                try
                {
                    // 変更内容を一括で更新
                    var wRestRet = Task<KeyValuePair<Boolean, String>>.Run(async () => await RldLib.ChangeSelectedHistoryInfo(SelectReportData.ReportCode.ToString(), selectCtlNo)).Result;
                    if (!wRestRet.Key)
                    {

                    }
                    else
                    {
                        // 更新結果を設定する
                        UpdateResult = wRestRet.Key;

                        // 閉じます、前画面に戻ります
                        this.DialogResult = DialogResult.OK;
                        this.Close(); 
                    }
                    
                }
                catch (Exception ex)
                {
                    // 例外情報を生成
                    var wEx = new System.ApplicationException("データ更新に失敗しました。", ex);
                    // 例外情報を記録(画面にメッセージボックスを表示)
                    RldUtility.RecordException(this.ParentForm, wEx, true);
                }
            }
        }

        /// <summary>
        /// DataGridViewの Click イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void dgvLayOutHistory_CellContentClick(object sender, DataGridViewCellEventArgs e)
        {
            // ヘッダのクリック時は抜ける
            if (e.RowIndex < 0 || e.ColumnIndex < 0)
            {
                return;
            }

            // 該当行にバインドされているパラメータデータを取得
            if (!(this.dgvLayOutHistory.Rows[e.RowIndex].DataBoundItem is ReportHistory wData))
            {
                return;
            }

            // 選択した行が[適用中]履歴の場合、OKボタンが無効です
            if (IsSelectName.Equals(wData.IsSelect))
            {
                this.btnOK.Enabled = false;
            }
            else
            {
                this.btnOK.Enabled = true;
            }
        }

        #endregion

        private void dgvLayOutHistory_CellEnter(object sender, DataGridViewCellEventArgs e)
        {
            // ヘッダのクリック時は抜ける
            if (e.RowIndex < 0 || e.ColumnIndex < 0)
            {
                return;
            }

            // 該当行にバインドされているパラメータデータを取得
            if (!(this.dgvLayOutHistory.Rows[e.RowIndex].DataBoundItem is ReportHistory wData))
            {
                return;
            }

            // 選択した行が[適用中]履歴の場合、OKボタンが無効です
            if (IsSelectName.Equals(wData.IsSelect))
            {
                this.btnOK.Enabled = false;
            }
            else
            {
                this.btnOK.Enabled = true;
            }
        }
    }
}
