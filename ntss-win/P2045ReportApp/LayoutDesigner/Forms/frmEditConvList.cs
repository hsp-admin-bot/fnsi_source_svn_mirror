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
    /// 変換項目編集画面
    /// </summary>
    public partial class frmEditConvList : LayoutDesignerUtilityLib.Controls.frmRldSizableBase
    {
        #region 生成と破棄

        /// <summary>
        /// 変換項目編集画面
        /// </summary>
        public frmEditConvList()
        {
            InitializeComponent();

            // アイコンの設定
            this.Icon = Properties.Resources.LayoutDesigner;

            // イベントハンドラ割り当て            
            this.btnCancel.Click += new System.EventHandler(this.btnCancel_Click);
            this.btnOK.Click += new System.EventHandler(this.btnOK_Click);
            this.dgvConvList.DataBindingComplete += new DataGridViewBindingCompleteEventHandler(this.dgvConvList_DataBindingComplete);
        }

        #endregion

        #region メンバプロパティ定義

        /// <summary>
        /// 編集箇所を特定できる情報の取得及び設定を行います。
        /// </summary>
        internal String DataPath { get; set; } = String.Empty;

        /// <summary>
        /// 変換項目設定の XML テキストの取得及び設定を行います。
        /// </summary>
        internal DesignConvertList ConvertList { get; set; } = null;

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

            this.lblDataPathAddr.Text = this.DataPath;

            if( !this.MakeList() ) {
                RldMsgBox.Show("変換項目のリスト作成に失敗しました。", "致命的なエラーが発生しました", MessageBoxButtons.OK, MessageBoxIcon.Stop);
                this.DialogResult = DialogResult.Cancel;
                this.Close();
            }
        }

        #endregion

        #region メンバ関数定義

        /// <summary>
        /// XMLからリストを生成します。
        /// </summary>
        private Boolean MakeList()
        {
            Boolean wRet = false;

            try {
                var wXmlDoc = new System.Xml.XmlDocument();

                wXmlDoc.LoadXml(this.ConvertList.ToXmlElementText());

                var wXmlNodeList = wXmlDoc[RldConst.ItemList.TAG_CONVTABLE].GetElementsByTagName(RldConst.ItemList.TAG_CONV);

                DataTable wDataTable = new DataTable();

                wDataTable.Columns.Add(Code.Name);
                wDataTable.Columns.Add(DataName.Name);
                wDataTable.Columns.Add(Disp.Name);

                for( Int32 i = 0; i < wXmlNodeList.Count; i++ ) {
                    DataRow row = wDataTable.NewRow();

                    row[Code.Name] = wXmlNodeList[i].Attributes[RldConst.ItemList.ATT_CONV_CODE].Value;
                    // mod #12528 "検査.検査予定(セット・指定日).予定有無"のフィルタがクラス内の他のフィルタと違う 高 start
                    string dataNameValue = wXmlNodeList[i].Attributes[RldConst.ItemList.ATT_CONV_ITEM].Value;
                    row[DataName.Name] = dataNameValue;
                    if(checkDataName(dataNameValue))
                        row[Disp.Name] = "";
                    else
                        row[Disp.Name] = wXmlNodeList[i].Attributes[RldConst.ItemList.ATT_CONV_DISP].Value;
                    // mod #12528 "検査.検査予定(セット・指定日).予定有無"のフィルタがクラス内の他のフィルタと違う 高 end

                    wDataTable.Rows.Add(row);
                }

                this.dgvConvList.DataSource = wDataTable;

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
            var wList = new DesignConvertList();

            for( Int32 i = 0; i < this.dgvConvList.RowCount; i++ ) {
                wList.Add(new DesignConvertListData() {
                    Code = this.dgvConvList[Code.Name, i].FormattedValue as String,
                    ItemValue = this.dgvConvList[DataName.Name, i].FormattedValue as String,
                    DisplayValue = this.dgvConvList[Disp.Name, i].FormattedValue as String
                });
            }

            this.ConvertList = wList;

            this.DialogResult = DialogResult.OK;
            this.Close();
        }

        /// <summary>
        /// データバインド処理
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void dgvConvList_DataBindingComplete(object sender, DataGridViewBindingCompleteEventArgs e)
        {
            // データバインド時処理
            //DataGridView grd = sender as DataGridView;

            //for( Int32 i = 0; i < grd.RowCount; i++ ) {
            //    DataGridViewCellCollection cells = grd.Rows[i].Cells;

            //    for( Int32 j = 0; j < cells.Count; j++ ) {
            //        if( !cells[j].ReadOnly )
            //            cells[j].Style.BackColor = Color.DarkGray;
            //    }
            //}

            // add #12528 "検査.検査予定(セット・指定日).予定有無"のフィルタがクラス内の他のフィルタと違う 高 start
            DataGridView grd = sender as DataGridView;

            if (grd.Rows.Count == 0 || grd.Columns.Count == 0)
                return;

            DataGridViewColumn dataNameColumn = null;
            DataGridViewColumn dispColumn = null;

            foreach (DataGridViewColumn column in this.dgvConvList.Columns)
            {
                if (column.DataPropertyName == DataName.Name)
                    dataNameColumn = column;
                else if (column.DataPropertyName == Disp.Name)
                    dispColumn = column;
            }

            if (dataNameColumn == null || dispColumn == null)
                return;

            foreach (DataGridViewRow row in grd.Rows)
            {
                // skip new line
                if (row.IsNewRow)
                    continue;

                // check dataName
                if (row.Cells[dataNameColumn.Index].Value != null &&
                    checkDataName(row.Cells[dataNameColumn.Index].Value.ToString()))
                {
                    row.Cells[dispColumn.Index].ReadOnly = true;
                }
                else
                {
                    row.Cells[dispColumn.Index].ReadOnly = false;
                }
            }
            // add #12528 "検査.検査予定(セット・指定日).予定有無"のフィルタがクラス内の他のフィルタと違う 高 end
        }

        // add #12528 "検査.検査予定(セット・指定日).予定有無"のフィルタがクラス内の他のフィルタと違う 高 start
        private bool checkDataName(string dataName)
        {
            bool bRet = false;

            // mod #12383 クラス「検査結果(フィルタなし)」が複数集計にない limingzhe start
            //if (dataName == "予定無し(変換不可)")
            if (dataName.Contains("(変換不可)"))
            // mod #12383 クラス「検査結果(フィルタなし)」が複数集計にない limingzhe end
                bRet = true;

            return bRet;
        }
        // add #12528 "検査.検査予定(セット・指定日).予定有無"のフィルタがクラス内の他のフィルタと違う 高 end

        #endregion

    }
}
