using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

using RldMsgBox = LayoutDesignerUtilityLib.RldMessageBox;
using RldUtility = LayoutDesignerUtilityLib.LayoutDesignerUtility;

namespace LayoutDesigner
{
    /// <summary>
    /// 横の単位/縦の単位選択画面
    /// </summary>
    public partial class frmSelectTotalUnit : LayoutDesignerUtilityLib.Controls.frmRldSizableBase
    {
        #region 生成と破棄

        /// <summary>
        /// 横の単位/縦の単位選択画面
        /// </summary>
        public frmSelectTotalUnit()
        {
            InitializeComponent();

            // アイコンの設定
            this.Icon = Properties.Resources.LayoutDesigner;

            // イベントハンドラ割り当て            
            this.btnCancel.Click += new System.EventHandler(this.btnCancel_Click);
            this.btnOK.Click += new System.EventHandler(this.btnOK_Click);
            this.btnClear.Click += new System.EventHandler(this.btnClear_Click);
            this.dgvTotalUnitList.DataBindingComplete += new DataGridViewBindingCompleteEventHandler(this.dgvConvList_DataBindingComplete);
        }

        #endregion

        #region メンバプロパティ定義

        internal int totalUnitFlag { get; set; } = 1;
        internal Dictionary<string, string> totalUnitDic = new Dictionary<string, string>();
        internal List<String> retTotalUnit;
        //internal List<String> retTotalUnit = new List<String>();

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

            if (totalUnitFlag == 1)  // 横の単位
                this.winlblTitle.Text = "横の単位選択画面";
            else
                this.winlblTitle.Text = "縦の単位選択画面";

            if (!this.MakeList())
            {
                RldMsgBox.Show("項目のリスト作成に失敗しました。", "致命的なエラーが発生しました", MessageBoxButtons.OK, MessageBoxIcon.Stop);
                this.DialogResult = DialogResult.Cancel;
                this.Close();
            }
            //
            this.dgvTotalUnitList.ClearSelection();
            if (retTotalUnit.Count >= 0)
            {
                for (int i = 0; i < this.dgvTotalUnitList.Rows.Count; i++)
                {
                    if(retTotalUnit.Contains(this.dgvTotalUnitList.Rows[i].Cells["CellAddress"].Value.ToString()))
                    {
                        this.dgvTotalUnitList.Rows[i].Selected = true;
                    }
                }
            }
        }

        #endregion

        #region メンバ関数定義

        /// <summary>
        /// DataGridViewを生成します。
        /// </summary>
        private Boolean MakeList()
        {
            Boolean wRet = false;

            try {
                DataTable wDataTable = new DataTable();

   
                wDataTable.Columns.Add(DataName.Name);
                wDataTable.Columns.Add(CellAddress.Name);

                DataRow row;
                foreach(var unit in totalUnitDic)
                { 
                    row = wDataTable.NewRow();

                    row[CellAddress.Name] = unit.Key;
                    row[DataName.Name] = unit.Value;
                    wDataTable.Rows.Add(row);
                }

                this.dgvTotalUnitList.DataSource = wDataTable;

                wRet = true;
            }
            catch( Exception ex ) {
                RldUtility.RecordException(ex, false);
            }

            return wRet;
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
        /// OK ボタンの Click イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnOK_Click(object sender, EventArgs e)
        {
            retTotalUnit.Clear();

            for (int i=0; i < this.dgvTotalUnitList.Rows.Count; i++)
            {
                if (this.dgvTotalUnitList.Rows[i].Selected == true)
                {
                    retTotalUnit.Add(this.dgvTotalUnitList.Rows[i].Cells["CellAddress"].Value.ToString());
                }
            }
            this.DialogResult = DialogResult.OK;
            this.Close();
        }

        /// <summary>
        /// 初期化ボタンの Click イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnClear_Click(object sender, EventArgs e)
        {
            this.dgvTotalUnitList.ClearSelection();
        }

        /// <summary>
        /// データバインド処理
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void dgvConvList_DataBindingComplete(object sender, DataGridViewBindingCompleteEventArgs e)
        {
        }

        #endregion

    }
}
