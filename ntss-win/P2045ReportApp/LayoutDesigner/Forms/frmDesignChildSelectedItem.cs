using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace LayoutDesigner
{
    /// <summary>
    /// 選択アイテムウィンドウ
    /// </summary>
    public partial class frmDesignChildSelectedItem : frmDesignChildBase
    {
        #region メンバ定数定義

        private const Int32 WM_NCHITTEST = 0x0084;

        private const Int32 HTTOP = 12;
        private const Int32 HTTOPLEFT = 13;
        private const Int32 HTTOPRIGHT = 14;
        private const Int32 HTBOTTOM = 15;
        private const Int32 HTBOTTOMLEFT = 16;
        private const Int32 HTBOTTOMRIGHT = 17;
        private const Int32 HTCLIENT = 1;

        #endregion

        #region メンバ変数定義

        /// <summary>
        /// パラメータ編集用データグリッドビューヘルパークラス
        /// </summary>
        private RldDataGridViewParamDataEditHelper m_ParamGridEditHelper = null;

        #endregion

        #region 生成と破棄

        /// <summary>
        /// 選択アイテムウィンドウ画面の新しいインスタンスを初期化します。
        /// </summary>
        public frmDesignChildSelectedItem()
        {
            InitializeComponent();

            // パラメータ編集用データグリッドビューヘルパークラスを生成
            this.m_ParamGridEditHelper = new RldDataGridViewParamDataEditHelper(this.dgvParamList);
            this.m_ParamGridEditHelper.NotifyInfo += (s, e) => base.SendNotifyInfo(this, e);
        }

        #endregion

        #region メンバ関数定義(override...)

        /// <summary>
        /// Form.FormClosing イベントを発生させます。
        /// </summary>
        /// <param name="e"></param>
        protected override void OnFormClosing(FormClosingEventArgs e)
        {
            base.OnFormClosing(e);

            if( !RldLib.IsStartDesignWindowClosing ) e.Cancel = true;

            if( e.Cancel ) return;

            if( this.m_ParamGridEditHelper != null )
                this.m_ParamGridEditHelper.Clear();
        }

        /// <summary>
        /// Form.Load イベントを発生させます。
        /// </summary>
        /// <param name="e"></param>
        protected override void OnLoad(EventArgs e)
        {
            base.OnLoad(e);

            // 画面をクリア
            this.DataClear(true);
        }

        /// <summary>
        /// Windows メッセージを処理します。
        /// </summary>
        /// <param name="m"></param>
        protected override void WndProc(ref Message m)
        {
            base.WndProc(ref m);

            if( m.Msg == WM_NCHITTEST ) {            // 0x84 : WM_NCHITTEST
                if( m.Result == (IntPtr)HTTOP ||
                    m.Result == (IntPtr)HTBOTTOM ||
                    m.Result == (IntPtr)HTTOPLEFT ||
                    m.Result == (IntPtr)HTTOPRIGHT ||
                    m.Result == (IntPtr)HTBOTTOMLEFT ||
                    m.Result == (IntPtr)HTBOTTOMRIGHT ) {
                    //m.Result = (IntPtr)0;
                    m.Result = (IntPtr)HTCLIENT;
                }
            }

        }

        /// <summary>
        /// 通知イベント受信時処理を行います。
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected override void ReceiveNotifyInfo(object sender, RldDesignNotifyInfoEventArgs e)
        {
            base.ReceiveNotifyInfo(sender, e);

            switch (e.InfoType)
            {
                case RldDesignNotifyInfoEventArgs.EnumInfoType.NotifySelectedParamChanged:
                    // 選択パラメータ変更通知受信
                    this.ActionOfNotifySelectedParamChanged((RldDesignNotifyInfoNotifySelectedParamChangedEventArgs)e);
                    break;

                case RldDesignNotifyInfoEventArgs.EnumInfoType.RequestRemoveAllParam:
                    // 全パラメータ編集データ削除要求受信
                    this.ActionOfRemoveAllParam(sender, (RldDesignNotifyInfoRequestRemoveAllParamEventArgs)e);
                    break;
            }
        }

        #endregion

        #region メンバ関数定義

        /// <summary>
        /// 画面の入力内容をクリアします。
        /// </summary>
        /// <param name="aIsKeyClear"></param>
        private void DataClear(Boolean aIsKeyClear)
        {
            this.m_ParamGridEditHelper.Clear();
        }

        /// <summary>
        /// 指定したセルアドレスに対応するデータを読み込みます。
        /// </summary>
        /// <param name="wCellAddress"></param>
        private void DataRead(String wCellAddress)
        {
            try {
                // 表示対象データをセット
                var list = RldLib.CurrentLayoutData.DesignParamList.Where(ele => ele.CellAddress == wCellAddress).ToList();
                this.m_ParamGridEditHelper.SetData(new BindingList<DesignParamData>(list));

                // 条件付き書式が設定されている場合はセルに背景色を設定する
                if ((list.Count > 0) && (list[0].FormatCondition.Count > 0))
                {
                    this.dgvParamList[DesignParamData.EnumDataIndex.ButtonEditFormatConditionText.ToString(), 0].Style.BackColor = Color.DarkOrange;
                }

            }
            catch( Exception ex ) {
                base.SendNotifyInfo(this, new RldDesignNotifyInfoRequestRecordExceptionEventArgs(ex, true));
            }
        }

        /// <summary>
        /// 選択パラメータ変更通知受信時処理を行います。
        /// </summary>
        /// <param name="e"></param>
        private void ActionOfNotifySelectedParamChanged(RldDesignNotifyInfoNotifySelectedParamChangedEventArgs e)
        {
            // 画面をクリア
            this.DataClear(false);
            // 画面のデータを読み込み
            this.DataRead(e.CellAddress);
        }

        /// <summary>
        /// 全パラメータ編集データ削除要求受信時処理を記述します。
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void ActionOfRemoveAllParam(Object sender, RldDesignNotifyInfoRequestRemoveAllParamEventArgs e)
        {
            try {
                // 画面をクリア
                this.DataClear(true);
                // バインドし直す
                this.DataRead(String.Empty);
            }
            catch( Exception ex ) {
                // TODO:
            }
        }

        #endregion

        /// add 2020-08-11 FNSI-仕様追加 最小化機能を追加 李 start
        /// <summary>
        /// 最小化機能を追加
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void winMinimizeBoxAll_Click(object sender, EventArgs e)
        {
            // add #12482 Excelのダイアログを開いたままアプリ操作で致命的エラー 高 start
            if (RldLib.chkExeclDialog(2) == false)
                return;
            // add #12482 Excelのダイアログを開いたままアプリ操作で致命的エラー 高 end

            // mod #12060 最小化ボタンで最小化しなくなる時がある 高 start
            //(Owner as Form).WindowState = FormWindowState.Minimized;
            Form owne = Owner as Form;
            var oldStyle = owne.FormBorderStyle;
            owne.FormBorderStyle = FormBorderStyle.Sizable;
            owne.WindowState = FormWindowState.Minimized;
            owne.FormBorderStyle = oldStyle;
            // mod #12060 最小化ボタンで最小化しなくなる時がある 高 end
            RldLib.XlHelper.XlApp.Application.ActiveWindow.WindowState = Microsoft.Office.Interop.Excel.XlWindowState.xlMinimized;
        }
        /// add 2020-08-11 FNSI-仕様追加 最小化機能を追加 李 end

        /// add 2020-08-11 FNSI-仕様追加 クローズ機能を追加 李 start
        /// <summary>
        /// クローズ機能を追加
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void winCloseBoxAll_Click(object sender, EventArgs e)
        {
            // 終了確認も選択アイテム画面を owner にして、現在の作業モニタから外さない。
            DialogResult dr = MessageBox.Show(this, "画面を閉じてファイルの修正を保存してよろしいでしょうか？", "終了確認", MessageBoxButtons.YesNo);

            // 拒否した場合は抜ける
            if (dr == DialogResult.No) return;

            // add #12482 Excelのダイアログを開いたままアプリ操作で致命的エラー 高 start
            if (RldLib.chkExeclDialog(2) == false)
                return;
            // add #12482 Excelのダイアログを開いたままアプリ操作で致命的エラー 高 end

            // add #12516 項目の設定されていない帳票出力時にシステムエラーが発生する 高 start
            if (RldLib.CurrentLayoutData.DesignParamList.Count == 0)
            {
                var wData = new RldDesignNotifyInfoRequestShowMessageEventArgs()
                {
                    Text = RldConst.DATA_EMPTY_MESSAGE,
                    Caption = RldConst.DATA_EMPTY_CAPTION,
                    Buttons = System.Windows.Forms.MessageBoxButtons.OK,
                    Icon = System.Windows.Forms.MessageBoxIcon.Exclamation
                };
                base.SendNotifyInfo(this, wData);
                return;
            }
            // add #12516 項目の設定されていない帳票出力時にシステムエラーが発生する 高 end

            // ファイルの削除(依頼のみ)
            base.SendNotifyInfo(this, new RldDesignNotifyInfoRequestSaveDropFileEventArgs()
            {
                IsSave = true,
                IsWorkFile = true
            });

            // 閉じる(終了)
            base.SendNotifyInfo(this, new RldDesignNotifyInfoRequestCloseEventArgs(CloseReason.UserClosing, false, DialogResult.Cancel));
        }

        // add #9379 【デグレ】表示文字列数の設定変更がフォーカスアウトしないと反映しない dong start
        private void dgvParamList_CurrentCellDirtyStateChanged(object sender, EventArgs e)
        {
            var wDataGridView = sender as DataGridView;
            if (wDataGridView.IsCurrentCellDirty)
            {
                if (wDataGridView.CurrentCell is DataGridViewTextBoxCell wTextBoxCell)
                {
                    // add #10485 グループ名編集の挙動でNGが2件 高 start
                    if (this.dgvParamList.Columns[wDataGridView.CurrentCell.ColumnIndex].Name != DesignParamData.GetPropertyName(DesignParamData.EnumDataIndex.GroupName))
                    // add #10485 グループ名編集の挙動でNGが2件 高 end
                    {
                        wDataGridView.EndEdit();
                        this.dgvParamList.BeginEdit(false);
                    }
                }
            }
        }
        // add #9379 【デグレ】表示文字列数の設定変更がフォーカスアウトしないと反映しない dong end
        /// add 2020-08-11 FNSI-仕様追加 クローズ機能を追加 李 end

        // add #12475 FNW帳票取込すると検査日が表示されない 高 start
        private bool _isProcessingDeactivate = false;
        private void frmDesignChildSelectedItem_Deactivate(object sender, EventArgs e)
        {
            if (_isProcessingDeactivate) return;

            _isProcessingDeactivate = true;

            this.dgvList_EndEdit();

            _isProcessingDeactivate = false;
        }

        private void dgvList_EndEdit()
        {
            // データグリッドビュー
            var wDataGridView = this.dgvParamList;

            if (wDataGridView.IsCurrentCellInEditMode)
            {
                wDataGridView.EndEdit();
            }
        }
        // add #12475 FNW帳票取込すると検査日が表示されない 高 end

        // add #12616 データ項目の縮小表示が機能しないことがある 高 start
        private bool _isProcessingActivated = false;
        private void frmDesignChildSelectedItem_Activated(object sender, EventArgs e)
        {
            if (_isProcessingActivated) return;
            _isProcessingActivated = true;

            frmDesignChildLayoutParam.ProcessAtomicAddresses(RldLib.CurrentLayoutData.lastSelectAddr);

            _isProcessingActivated = false;
        }
        // add #12616 データ項目の縮小表示が機能しないことがある 高 end
    }
}
