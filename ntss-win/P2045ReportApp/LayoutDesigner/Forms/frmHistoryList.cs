using System;
using System.Collections.Generic;
using System.Data;
using System.Windows.Forms;

using RldMsgBox = LayoutDesignerUtilityLib.RldMessageBox;
using RldUtility = LayoutDesignerUtilityLib.LayoutDesignerUtility;

namespace LayoutDesigner
{
    /// <summary>
    /// 変更履歴リスト表示画面
    /// </summary>
    public partial class frmHistoryList : LayoutDesignerUtilityLib.Controls.frmRldSizableBase
    {
        #region 生成と破棄

        /// <summary>
        /// 変更履歴リスト表示
        /// </summary>
        public frmHistoryList()
        {
            InitializeComponent();

            // データグリッドビューの列を自動生成しないようにする
            this.dgvData.AutoGenerateColumns = false;
            // データグリッドビューの表示を調整する
            RldGridRCAttributeReflector.ApplyToColumn(this.dgvData, typeof(DesignHistoryData).GetProperties());

            // アイコンの設定
            this.Icon = Properties.Resources.LayoutDesigner;

            // イベントハンドラ割り当て            
            this.btnCancel.Click += (s, e) => this.Close();
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

            if( base.DesignMode ) return;

            // 画面をクリア
            this.DataClear(true);

            // データを画面に読み込み
            this.DataRead();
        }

        #endregion

        #region メンバ関数定義

        /// <summary>
        /// 画面の入力内容をクリアします。
        /// </summary>
        /// <param name="aIsKeyClear">(未使用)</param>
        private void DataClear(Boolean aIsKeyClear)
        {
            if( aIsKeyClear ) {
                this.dgvData.DataMember = null;
                this.dgvData.DataSource = null;
            }

            this.SetHistoryCountLabel(0);

            this.dgvData.RowCount = 0;
        }

        /// <summary>
        /// 画面にデータを読み込みます。
        /// </summary>
        private void DataRead()
        {
            try {
                this.dgvData.SuspendLayout();
                this.dgvData.AutoSizeRowsMode = DataGridViewAutoSizeRowsMode.None;
                this.dgvData.AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.None;

                this.dgvData.DataMember = null;
                this.dgvData.DataSource = RldLib.XlHelper.GetSheetHistoryDataList();

                this.dgvData.AutoSizeRowsMode = DataGridViewAutoSizeRowsMode.AllCells;
                this.dgvData.AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.AllCells;

                // 1行目を選択しておく
                if( this.dgvData.RowCount > 0 ) this.dgvData[0, 0].Selected = true;

                this.SetHistoryCountLabel(this.dgvData.RowCount);
            }
            catch( Exception ex ) {
                //this.SendNotifyInfo(new RldDesignNotifyInfoRequestRecordExceptionEventArgs(ex, true));
            }
            finally {
                this.dgvData.ResumeLayout();
            }
        }

        /// <summary>
        /// 更新履歴件数の表示を更新します。
        /// </summary>
        /// <param name="aCount"></param>
        private void SetHistoryCountLabel(Int32 aCount)
        {
            this.lblCount.Text = String.Format("更新履歴：{0}件", aCount);
        }

        #endregion
    }
}
