using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

using RldConst = LayoutDesigner.RldConst;
using RldMsgBox = LayoutDesignerUtilityLib.RldMessageBox;

namespace DataListConverter
{
    public partial class frmMain : LayoutDesignerUtilityLib.Controls.frmRldSizableBase
    {
        private const String MSGBOX_TITLE = "確認してください";

        public frmMain()
        {
            InitializeComponent();

            // イベントハンドラ割り当て
            this.cmdFileSrc.Click += new EventHandler(this.cmdFileSrc_Click);
            this.cmdFileDst.Click += new EventHandler(this.cmdFileDst_Click);
            this.cmdExit.Click += new EventHandler(this.cmdExit_Click);
            this.cmdExec.Click += new EventHandler(this.cmdExec_Click);
        }

        #region メンバ関数定義(override)

        /// <summary>
        /// Form.Load イベントを発生させます。
        /// </summary>
        /// <param name="e"></param>
        protected override void OnLoad(EventArgs e)
        {
            base.OnLoad(e);

            this.DataClear(true);
        }

        #endregion

        #region メンバ関数定義

        /// <summary>
        /// 画面の入力内容をクリアします。
        /// </summary>
        /// <param name="aIsKeyClear"></param>
        private void DataClear(Boolean aIsKeyClear)
        {
            this.txtFileSrc.Clear();
            this.txtFileDst.Clear();
        }

        /// <summary>
        /// 入力内容を確認します。
        /// </summary>
        /// <returns></returns>
        private Boolean DataCheck()
        {
            if( String.IsNullOrWhiteSpace(this.txtFileSrc.Text) ) {
                RldMsgBox.Show(this, "変換元ファイルが未選択です。", MSGBOX_TITLE, MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                this.txtFileSrc.Focus();

                return false;
            }
            else {
                if( !System.IO.File.Exists(this.txtFileSrc.Text) ) {
                    RldMsgBox.Show(this, "変換元ファイルが見つかりません。\r\nファイルパスを確認してください。", MSGBOX_TITLE, MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                    this.txtFileSrc.Focus();

                    return false;
                }
            }

            if( String.IsNullOrWhiteSpace(this.txtFileDst.Text) ) {
                RldMsgBox.Show(this, "変換先ファイルが未選択です。", MSGBOX_TITLE, MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                this.txtFileDst.Focus();

                return false;
            }

            return true;
        }

        /// <summary>
        /// 変換処理を実行します。
        /// </summary>
        /// <returns></returns>
        private Boolean ExecAction()
        {
            Boolean wRet = false;   

            try {
                // 変換元ファイルを読み込み
                var wSrcXmlDoc = new System.Xml.XmlDocument();
                wSrcXmlDoc.Load(this.txtFileSrc.Text);

                // 変換先ファイルを作成
                var wDstXmlDoc = new System.Xml.XmlDocument();
                // XML 宣言作成
                wDstXmlDoc.AppendChild(wDstXmlDoc.CreateXmlDeclaration("1.0", "utf-8", "yes"));
                // ルート要素を作成して追加
                var wDstXmlRoot = wDstXmlDoc.CreateElement(RldConst.ItemList.TAG_REPORTTABLE);

                // ReportList ノード取得
                var wSrcReportList = wSrcXmlDoc.SelectSingleNode("Root/ReportList");

                foreach( System.Xml.XmlElement wSrcReportNode in wSrcReportList.ChildNodes ) {

                    var wDstReport = wDstXmlDoc.CreateElement(RldConst.ItemList.TAG_REPORT);
                    wDstReport.SetAttribute(RldConst.ItemList.ATT_REPORT_TYPE, wSrcReportNode.Name);

                    var wSrcReportInfo = wSrcReportNode.FirstChild;
                    wDstReport.SetAttribute(RldConst.ItemList.ATT_REPORT_DISPNAME, wSrcReportInfo.Attributes[@"DispName"].Value as String);

                    var wSrcDataList = wSrcReportNode.SelectSingleNode("DataList");
                    if( wSrcDataList != null ) {

                        var wDstDataTbl = wDstXmlDoc.CreateElement(RldConst.ItemList.TAG_DATATABLE);

                        foreach( System.Xml.XmlElement wSrcDataNode in wSrcDataList.ChildNodes ) {

                            Console.WriteLine();
                            var wDstData = wDstXmlDoc.CreateElement(RldConst.ItemList.TAG_DATA);
                            wDstData.SetAttribute(RldConst.ItemList.ATT_DATA_DATACODE, "");
                            wDstData.SetAttribute(RldConst.ItemList.ATT_DATA_DATANAME, wSrcDataNode.Attributes["Item"].Value as String);
                            wDstData.SetAttribute(RldConst.ItemList.ATT_DATA_DATACATEGORY, wSrcDataNode.Attributes["Category"].Value as String);
                            wDstData.SetAttribute(RldConst.ItemList.ATT_DATA_DATACLASS, wSrcDataNode.Attributes["Class"].Value as String);
                            wDstData.SetAttribute(RldConst.ItemList.ATT_DATA_SQLCODE, "");
                            wDstData.SetAttribute(RldConst.ItemList.ATT_DATA_DATATYPE, wSrcDataNode.Attributes["DataType"].Value as String);
                            wDstData.SetAttribute(RldConst.ItemList.ATT_DATA_CANREPEAT, wSrcDataNode.Attributes["Repeat"].Value as String == "on" ? RldConst.ItemList.VAL_DATA_CANREPEAT_YES : RldConst.ItemList.VAL_DATA_CANREPEAT_NO);
                            wDstData.SetAttribute(RldConst.ItemList.ATT_DATA_FILTERTYPE, wSrcDataNode.Attributes["AbsType"].Value as String);
                            wDstData.SetAttribute(RldConst.ItemList.ATT_DATA_DISPFORMAT, wSrcDataNode.Attributes["Format"].Value as String);
                            wDstData.SetAttribute(RldConst.ItemList.ATT_DATA_CANCALC, wSrcDataNode.Attributes["CalcFlg"].Value as String == "ok" ? RldConst.ItemList.VAL_DATA_CANCALC_YES : RldConst.ItemList.VAL_DATA_CANCALC_NO);
                            wDstData.SetAttribute(RldConst.ItemList.ATT_DATA_PREVIEW, wSrcDataNode.Attributes["Preview"].Value as String);
                            wDstData.SetAttribute(RldConst.ItemList.ATT_DATA_FACILITYFILTERTYPE, "0");

                            var wSrcConvList = wSrcDataNode.SelectSingleNode("ConvList");
                            if( wSrcConvList != null ) {

                                var wDstConvTbl = wDstXmlDoc.CreateElement(RldConst.ItemList.TAG_CONVTABLE);
                                wDstConvTbl.SetAttribute(RldConst.ItemList.ATT_CONVTABLE_CLS, wSrcConvList.Attributes["Cls"].Value as String);

                                foreach( System.Xml.XmlElement wSrcConvNode in wSrcConvList.ChildNodes ) {

                                    var wDstConv = wDstXmlDoc.CreateElement(RldConst.ItemList.TAG_CONV);
                                    wDstConv.SetAttribute(RldConst.ItemList.ATT_CONV_CODE, wSrcConvNode.Attributes["Code"].Value as String);
                                    wDstConv.SetAttribute(RldConst.ItemList.ATT_CONV_ITEM, wSrcConvNode.Attributes["Item"].Value as String);
                                    wDstConv.SetAttribute(RldConst.ItemList.ATT_CONV_DISP, wSrcConvNode.Attributes["Disp"].Value as String);

                                    wDstConvTbl.AppendChild(wDstConv);
                                }

                                wDstData.AppendChild(wDstConvTbl);
                            }

                            {
                                var wDstFacilityTbl = wDstXmlDoc.CreateElement(RldConst.ItemList.TAG_FACILITYTABLE);
                                wDstData.AppendChild(wDstFacilityTbl);
                            }

                            wDstDataTbl.AppendChild(wDstData);
                        }

                        wDstReport.AppendChild(wDstDataTbl);
                    }
                    
                    wDstXmlRoot.AppendChild(wDstReport);
                }

                wDstXmlDoc.AppendChild(wDstXmlRoot);

                if(wDstXmlDoc != null) 
                    wDstXmlDoc.Save(this.txtFileDst.Text);

                wRet = true;
            }
            catch( Exception ex ) {
                RldMsgBox.Show(this, ex.Message, MSGBOX_TITLE, MessageBoxButtons.OK, MessageBoxIcon.Error);
            }

            return wRet;
        }

        #endregion

        #region コントロールイベントハンドラ定義

        /// <summary>
        /// 閉じるボタンの Click イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void cmdExit_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        /// <summary>
        /// 実行ボタンの Click イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void cmdExec_Click(object sender, EventArgs e)
        {
            if( !this.DataCheck() ) return;
            
            if( RldMsgBox.Show(this, "変換処理を実行します。よろしいですか。", MSGBOX_TITLE, MessageBoxButtons.YesNo, MessageBoxIcon.Question) == DialogResult.No ) return;

            if( this.ExecAction() )
                RldMsgBox.Show(this, "正常に終了しました。", MSGBOX_TITLE, MessageBoxButtons.OK, MessageBoxIcon.Information);
            else
                RldMsgBox.Show(this, "変換処理中にエラーが発生しました。", MSGBOX_TITLE, MessageBoxButtons.OK, MessageBoxIcon.Error);
        }

        /// <summary>
        /// 変換先ファイル保存ダイアログ表示用ボタンの Click イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void cmdFileDst_Click(object sender, EventArgs e)
        {
            // ファイル保存ダイアログ表示
            using( var wDlg = new SaveFileDialog() ) {

                wDlg.FileName = System.IO.Path.GetFileName(LayoutDesignerUtilityLib.LayoutDesignerUtility.DataListFilePath);
                wDlg.Filter = "データリストファイル(*.xml) | *.xml";

                if( wDlg.ShowDialog(this) == DialogResult.OK ) {

                    this.txtFileDst.Text = wDlg.FileName;
                }
            }
        }

        /// <summary>
        /// 変換元ファイル選択ダイアログ表示用ボタンの Click イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void cmdFileSrc_Click(object sender, EventArgs e)
        {
            // ファイル選択ダイアログを表示
            using( var wDlg = new OpenFileDialog() ) {

                wDlg.FileName = "DataList.xml";
                wDlg.FilterIndex = 0;
                wDlg.Filter = "データリストファイル(*.xml)|*.xml|全てのファイル(*.*)|*.*";

                if( wDlg.ShowDialog(this) == DialogResult.OK ) {


                    this.txtFileSrc.Text = wDlg.FileName;
                }
            }
        }

        #endregion
    }
}
