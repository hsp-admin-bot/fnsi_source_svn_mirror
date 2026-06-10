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

namespace LayoutDesigner
{
    /// <summary>
    /// 水質調査箇所フィルタ選択画面
    /// </summary>
    public partial class frmSelectWaterSurveyPointFilter : LayoutDesignerUtilityLib.Controls.frmRldSizableBase
    {
        #region メンバ列挙体定義
        #endregion

        #region 生成と破棄

        /// <summary>
        /// コンストラクタ
        /// </summary>
        public frmSelectWaterSurveyPointFilter()
        {
            InitializeComponent();

            // アイコンの設定
            this.Icon = Properties.Resources.LayoutDesigner;

            // イベントハンドラ割り当て
            this.lstSurvey.DoubleClick += new System.EventHandler(this.lstSurvey_DoubleClick);
            this.txtFree.TextChanged += new System.EventHandler(this.txtFree_TextChanged);
            this.btnOK.Click += new EventHandler(this.btnOK_Click);
        }

        #endregion

        #region メンバプロパティ定義

        /// <summary>
        /// 設定中のフィルターデータの取得及び設定を行います。
        /// </summary>
        internal String FilterData { get; set; } = String.Empty;

        /// <summary>
        /// 編集箇所を特定できる情報の取得及び設定を行います。
        /// </summary>
        internal String Path { get; set; } = String.Empty;

        /// <summary>
        /// 同一グループの別項目へフィルタを適用するかどうかの取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        internal Boolean IsApplySameGroup { get; private set; } = false;

        /// <summary>
        /// オンライン状態かどうかの取得及び設定を行います。
        /// </summary>
        private Boolean IsOnline { get; set; } = false;

        #endregion

        #region メンバ関数定義(override...)

        /// <summary>
        /// Form.Load イベントを発生させます。
        /// </summary>
        /// <param name="e"></param>
        protected async override void OnLoad(EventArgs e)
        {
            base.OnLoad(e);

            if( base.DesignMode ) return;

            // オンライン/オフライン状態をセット
            this.IsOnline = SignInLib.SignIn.SignInInfo.IsOnline;
            //this.IsOnline = false;

            // 画面をクリア
            this.DataClear(true);

            // 画面を初期化(失敗時は抜ける)
            if( !await this.InitWindow() ) { this.Close(); return; }

            // フィルタが設定済みの場合はデータ読み込み
            this.DataRead();
        }

        #endregion

        #region メンバ関数定義

        /// <summary>
        /// 画面を初期化します。
        /// </summary>
        private async Task<Boolean> InitWindow()
        {
            Boolean wRet = false;

            // オンライン時
            if( this.IsOnline ) {
                //this.pnlHeader.Visible = false;
                this.pnlOffline.Visible = false;
                this.ClientSize = new Size(this.pnlOnline.Width, base.winlblTitle.Height + this.pnlHeader.Height + this.pnlOnline.Height + this.pnlFooter.Height);
                this.pnlOnline.Dock = DockStyle.Fill;
                this.pnlOnline.BringToFront();
                this.MinimumSize = this.Size;
                this.lblMode.Text = String.Empty;
                this.lstSurvey.Select();

                wRet = await this.ShowOnlineWaterSurveyPointList();
            }
            // オフライン時
            else {
                this.pnlOnline.Visible = false;
                this.ClientSize = new Size(this.pnlOffline.Width, base.winlblTitle.Height + this.pnlHeader.Height + this.pnlOffline.Height + this.pnlFooter.Height);
                this.pnlOffline.Dock = DockStyle.Fill;
                this.pnlOffline.BringToFront();
                this.MinimumSize = this.Size;
                this.MaximumSize = this.Size;
                this.lblMode.Text = "オフライン";
                this.txtSurveyCd.Select();

                wRet = true;
            }

            // パスをセット
            this.lblPathAddr.Text = this.Path;

            // TODO: 最大桁数セット
            this.txtSurveyCd.MaxLength = 0;   

            return wRet;
        }

        /// <summary>
        /// 水質調査箇所リストを表示します。
        /// </summary>
        /// <returns></returns>
        private async Task<Boolean> ShowOnlineWaterSurveyPointList()
        {
            Boolean wRet = false;

            var wList = await this.CreateWaterSurveyPointList();

            this.lstSurvey.DisplayMember = "Value";
            this.lstSurvey.ValueMember = "Code";
            this.lstSurvey.BeginUpdate();

            try {
                this.lstSurvey.Items.Clear();

                // フリーワードによるフィルタリングを適用
                if( !String.IsNullOrEmpty(this.txtFree.Text) ) {

                    // 日本語用の検索パラメータ指定用データを取得
                    var wCompareInfo = System.Globalization.CultureInfo.CurrentCulture.CompareInfo;

                    System.Func<String, Int32> wFuncFindIndex = aTarget => wCompareInfo.IndexOf(
                        aTarget,
                        this.txtFree.Text,
                        System.Globalization.CompareOptions.IgnoreCase | System.Globalization.CompareOptions.IgnoreWidth);

                    wList = wList.FindAll(ele => wFuncFindIndex(ele.Value) >= 0);
                }

                wList.ForEach(ele => this.lstSurvey.Items.Add(ele));

                wRet = true;
            }
            finally {
                this.lstSurvey.EndUpdate();
            }

            return wRet;
        }

        /// <summary>
        /// 画面の入力内容をクリアします。
        /// </summary>
        /// <param name="aIsKeyClear"></param>
        private void DataClear(Boolean aIsKeyClear)
        {
            this.txtFree.Clear();
            this.lstSurvey.Items.Clear();
            this.txtSurveyCd.Clear();
        }

        /// <summary>
        /// 画面の入力内容を確認します。
        /// </summary>
        /// <returns></returns>
        private Boolean DataCheck()
        {
            const String MSG_TITLE = @"確認してください";

            // オンライン時
            if( this.IsOnline ) {
                if( this.lstSurvey.SelectedItem == null ) {
                    RldMsgBox.Show("水質調査箇所を選択してください。", MSG_TITLE, MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                    this.lstSurvey.Focus();

                    return false;
                }
            }
            // オフライン時
            else {
                if( String.IsNullOrEmpty(this.txtSurveyCd.Text) ) {
                    RldMsgBox.Show("水質調査箇所コードを入力して下さい。", MSG_TITLE, MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                    this.txtSurveyCd.Focus();

                    return false;
                }

                if( !System.Text.RegularExpressions.Regex.IsMatch(this.txtSurveyCd.Text, "^[a-zA-Z0-9]+ *$") ) {
                    RldMsgBox.Show("水質調査箇所コードは半角英数字のみで入力してください。", MSG_TITLE, MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                    this.txtSurveyCd.Focus();

                    return false;
                }
            }

            return true;
        }

        /// <summary>
        /// 画面にデータを読み込みます。
        /// </summary>
        private void DataRead()
        {
            // フィルタが未設定の場合は抜ける
            if( String.IsNullOrEmpty(this.FilterData) ) return;

            // 設定中のフィルタデータを読み込む(失敗時は抜ける)
            var wXmlDoc = new System.Xml.XmlDocument();
            try {
                wXmlDoc.LoadXml(this.FilterData);
            }
            catch {
                return;
            }

            var wChildNode = wXmlDoc.SelectNodes(String.Format("{0}/{1}", RldConst.FilterData.TAG_ROOT, RldConst.FilterData.TAG_ITEM));
            foreach( System.Xml.XmlNode wXmlChild in wChildNode ) {

                var wCode = wXmlChild.Attributes[RldConst.FilterData.ATT_ITEM_CODE].InnerText;

                // オンライン時
                if( this.IsOnline ) {
                    foreach( Object wElement in this.lstSurvey.Items ) {
                        if( wElement is DesignComboBoxItemData wItem ) {
                            if( wItem.Code == wCode ) {
                                this.lstSurvey.SelectedItem = wElement;
                                break;
                            }
                        }
                    }
                }
                // オフライン時
                else
                    this.txtSurveyCd.Text = wCode;
            }
        }

        /// <summary>
        /// 画面の入力内容を保存します。
        /// </summary>
        private void DataSave()
        {
            var wXmlDoc = new System.Xml.XmlDocument();

            // ルートノードを作成
            var wXmlRoot = wXmlDoc.CreateElement(RldConst.FilterData.TAG_ROOT);

            // コードを取得
            String wCode = this.IsOnline ? (this.lstSurvey.SelectedItem as DesignComboBoxItemData)?.Code : this.txtSurveyCd.Text;

            // アイテムノードを作成
            var wXmlItem = wXmlDoc.CreateElement(RldConst.FilterData.TAG_ITEM);
            wXmlItem.SetAttribute(RldConst.FilterData.ATT_ITEM_CODE, wCode);
            wXmlItem.SetAttribute(RldConst.FilterData.ATT_ITEM_EXAMCLASS_BEFORE, RldConst.FilterData.VAL_ATT_ITEM_EXAMCLASS_OFF);   // TODO: 正式実装時に変更する
            wXmlItem.SetAttribute(RldConst.FilterData.ATT_ITEM_EXAMCLASS_AFTER, RldConst.FilterData.VAL_ATT_ITEM_EXAMCLASS_OFF);    // TODO: 正式実装時に変更する
            wXmlItem.SetAttribute(RldConst.FilterData.ATT_ITEM_EXAMCLASS_OTHER, RldConst.FilterData.VAL_ATT_ITEM_EXAMCLASS_OFF);    // TODO: 正式実装時に変更する
            wXmlRoot.AppendChild(wXmlItem);

            // ドキュメントへ追加
            this.FilterData = (wXmlDoc.AppendChild(wXmlRoot)).OuterXml;

            this.IsApplySameGroup = this.chkDevelopment.Checked;
        }

        #endregion

        #region メンバ関数定義(ListViewItem)

        /// <summary>
        /// 水質調査箇所フィルタ用表示データを作成して取得します。
        /// </summary>
        /// <returns></returns>
        private async Task<List<DesignComboBoxItemData>> CreateWaterSurveyPointList()
        {
            var wResult = await RldLib.FilterDataSet.GetFilterWaterSurveyPointData();
            var wRet = new List<DesignComboBoxItemData>();

            if( wResult.IsSuccess )
                wResult.Data.ForEach(
                    ele => wRet.Add(new DesignComboBoxItemData() {
                        Code = ele.WaterSurveyPointCode.ToString(),
                        Value = ele.WaterSurveyPointName
                    }));

            return wRet;
        }

        #endregion

        #region コントロールイベントハンドラ定義

        /// <summary>
        /// フリーワードの TextChanged イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private async void txtFree_TextChanged(object sender, EventArgs e)
        {
            await this.ShowOnlineWaterSurveyPointList();
        }

        /// <summary>
        /// 一覧表示の DoubleClick イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void lstSurvey_DoubleClick(object sender, EventArgs e)
        {
            this.btnOK.PerformClick();
        }

        /// <summary>
        /// OK ボタンの Click イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnOK_Click(object sender, EventArgs e)
        {
            // 入力内容をチェック
            if( !this.DataCheck() ) return;

            // 入力内容を保存
            this.DataSave();

            // 閉じる
            this.DialogResult = DialogResult.OK;
            this.Close();
        }

        #endregion
    }
}
