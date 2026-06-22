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
    /// 検査項目・検査セット選択画面
    /// </summary>
    public partial class frmSelectExamFilter : LayoutDesignerUtilityLib.Controls.frmRldSizableBase
    {
        #region メンバ列挙体定義

        /// <summary>
        /// フィルタ項目
        /// </summary>
        public enum EnumFilterType
        {
            /// <summary>
            /// 未設定
            /// </summary>
            None = 0,
            // add FNSI-699,700,751 装置帳票の記録簿対応 夏 start
            /// <summary>
            /// 点検
            /// </summary>
            Inspection,
            // add FNSI-699,700,751 装置帳票の記録簿対応 夏 end
            /// <summary>
            /// 検査セット
            /// </summary>
            ExaminSet,
            /// <summary>
            /// 検査項目
            /// </summary>
            ExaminItem,
            // add #12585 水質管理.水質検査のフィルタ処理仕様修正 高 start
            /// <summary>
            /// 水質検査
            /// </summary>
            WQTestPoint,
            // add #12585 水質管理.水質検査のフィルタ処理仕様修正 高 end
            // add FNSI-5915 李 start
            /// <summary>
            /// 
            /// </summary>
            Category
            // add FNSI-5915 李 end
        }

        #endregion

        #region 生成と破棄

        /// <summary>
        /// コンストラクタ
        /// </summary>
        public frmSelectExamFilter()
        {
            InitializeComponent();

            // アイコンの設定
            this.Icon = Properties.Resources.LayoutDesigner;

            // イベントハンドラ割り当て
            this.lstExam.DoubleClick += new System.EventHandler(this.lstExam_DoubleClick);
            this.txtFree.TextChanged += new System.EventHandler(this.txtFree_TextChanged);
            this.btnOK.Click += new EventHandler(this.btnOK_Click);
        }

        #endregion

        #region メンバプロパティ定義

        /// <summary>
        /// フィルター種別の取得及び設定を行います。
        /// </summary>
        internal EnumFilterType FilterType { get; set; } = frmSelectExamFilter.EnumFilterType.None;

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

        //add #9711 既存帳票を開くと致命的エラーが発生 dongzhaolong start
        internal String CellAddress { get; set; } = string.Empty;
        //add #9711 既存帳票を開くと致命的エラーが発生 dongzhaolong end

        // add #12416 帳票移植時にフィルタ設定が無効化する（横展開） 高 start
        internal int cntErrTotal { get; set; } = 0;
        internal int cntCovert { get; set; } = 0;
        internal int cntTotal { get; set; } = 0;
        internal int cntNotName { get; set; } = 0;
        internal bool clsFilterData { get; set; } = false;

        internal bool IsInspection { get; set; } = false;
        // add #12416 帳票移植時にフィルタ設定が無効化する（横展開） 高 end

        #endregion

        #region メンバ関数定義(override...)

        /// <summary>
        /// Form.Load イベントを発生させます。
        /// </summary>
        /// <param name="e"></param>
        // mod #12585 水質管理.水質検査のフィルタ処理仕様修正 高 start
        protected async override void OnLoad(EventArgs e)
        {
            base.OnLoad(e);

            if (base.DesignMode) return;

            // フィルタが設定済みの場合はデータ読み込み
            this.DataRead();
        }

        // 公共初始化方法（可在显示前调用）
        public async Task<bool> InitializeAsync()
        {
            if (base.DesignMode) return true;

            // オンライン/オフライン状態をセット
            this.IsOnline = SignInLib.SignIn.SignInInfo.IsOnline;

            // 画面をクリア
            this.DataClear(true);

            // 画面を初期化
            return await this.InitWindow();
        }
        // mod #12585 水質管理.水質検査のフィルタ処理仕様修正 高 end

        #endregion

        #region メンバ関数定義

        /// <summary>
        /// 画面を初期化します。
        /// </summary>
        private async Task<Boolean> InitWindow()
        {
            Boolean wRet = false;

            // オンライン時
            if (this.IsOnline)
            {
                this.pnlHeader.Visible = false;
                this.pnlOffline.Visible = false;
                this.ClientSize = new Size(this.pnlOnline.Width, base.winlblTitle.Height + this.pnlHeader.Height + this.pnlOnline.Height + this.pnlFooter.Height);
                this.pnlOnline.Dock = DockStyle.Fill;
                this.pnlOnline.BringToFront();
                this.MinimumSize = this.Size;
                this.lstExam.Select();

                wRet = await this.ShowOnlineExamList();
            }
            // オフライン時
            else
            {
                this.pnlOnline.Visible = false;
                this.ClientSize = new Size(this.pnlOffline.Width, base.winlblTitle.Height + this.pnlHeader.Height + this.pnlOffline.Height + this.pnlFooter.Height);
                this.pnlOffline.Dock = DockStyle.Fill;
                this.pnlOffline.BringToFront();
                this.MinimumSize = this.Size;
                this.MaximumSize = this.Size;
                this.lblMode.Text = "オフライン";
                this.txtExamCd.Select();

                wRet = true;
            }

            // パスをセット
            //this.lblPathAddr.Text = this.Path;

            switch (this.FilterType)
            {
                case EnumFilterType.ExaminItem: // 検査項目フィルタ
                    this.winlblTitle.Text = @"検査項目フィルタ設定";
                    this.lblExamCd.Text = @"検査項目コード";
                    this.txtExamCd.MaxLength = 0;   // TODO: 最大桁数セット
                    break;

                case EnumFilterType.ExaminSet:  // 検査セットフィルタ
                    this.winlblTitle.Text = @"検査セットフィルタ設定";
                    this.lblExamCd.Text = @"検査セットコード";
                    this.txtExamCd.MaxLength = 0;   // TODO: 最大桁数セット
                    break;

                // add FNSI-699,700,751 装置帳票の記録簿対応 夏 start
                case EnumFilterType.Inspection:  // 点検フィルタ
                    this.winlblTitle.Text = @"点検項目フィルタ設定";
                    this.lblExamCd.Text = @"点検項目コード";
                    this.txtExamCd.MaxLength = 0;   // TODO: 最大桁数セット
                    this.chkBefore.Visible = false;
                    this.chkAfter.Visible = false;
                    this.chkOther.Visible = false;
                    this.chkDevelopment.Visible = false;
                    this.chkBefore.Checked = false;
                    this.chkAfter.Checked = false;
                    this.chkOther.Checked = false;
                    break;
                // add FNSI-699,700,751 装置帳票の記録簿対応 夏 end
                // add #8615 zhu
                case EnumFilterType.Category:
                    this.winlblTitle.Text = @"患者イベントフィルタ設定";
                    this.lblExamCd.Text = @"患者イベントコード";
                    this.chkBefore.Visible = false;
                    this.chkAfter.Visible = false;
                    this.chkOther.Visible = false;
                    break;
                // add #8615 end
                // add #12585 水質管理.水質検査のフィルタ処理仕様修正 高 start
                case EnumFilterType.WQTestPoint:  // 水質検査フィルタ
                    this.winlblTitle.Text = @"水質検査個所フィルタ設定";
                    this.lblExamCd.Text = @"水質検査項目コード";
                    this.txtExamCd.MaxLength = 0;   // TODO: 最大桁数セット
                    this.chkBefore.Visible = false;
                    this.chkAfter.Visible = false;
                    this.chkOther.Visible = false;
                    this.chkBefore.Checked = false;
                    this.chkAfter.Checked = false;
                    this.chkOther.Checked = false;
                    break;
                // add #12585 水質管理.水質検査のフィルタ処理仕様修正 高 end
                default:
                    break;
            }

            return wRet;
        }

        /// <summary>
        /// 検査項目/セットリストを表示します。
        /// </summary>
        /// <returns></returns>
        private async Task<Boolean> ShowOnlineExamList()
        {
            Boolean wRet = false;
            List<DesignComboBoxItemData> wList = null;

            // 作業用リストの作成
            // add #12416 帳票移植時にフィルタ設定が無効化する（横展開） 高 start
            //switch (this.FilterType)
            //{
            //    case EnumFilterType.Category:
            //        wList = await this.CreateCategoryList();
            //        break;
            //    case EnumFilterType.ExaminItem:
            //        wList = await this.CreateExamItemList();
            //        break;

            //    case EnumFilterType.ExaminSet:
            //        wList = await this.CreateExamSetList();
            //        break;

            //    // add FNSI-699,700,751 装置帳票の記録簿対応 夏 start
            //    case EnumFilterType.Inspection:  // 点検フィルタ
            //        wList = await this.CreateInspectionList();
            //        if (wList.Count == 0)
            //        {
            //            RldMsgBox.Show(String.Format("点検詳細品目コードの取得データがありません。"), "データなし", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
            //            return false;
            //        }

            //        break;
            //        // add FNSI-699,700,751 装置帳票の記録簿対応 夏 end
            //}

            wList = await this.CreateTreeNode();

            if (wList == null || wList.Count == 0)
            {
                if(this.FilterType == EnumFilterType.Inspection)
                {
                    RldMsgBox.Show(String.Format("点検詳細品目コードの取得データがありません。"), "データなし", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                    // add #12628 検査結果のフィルタダイアログが開けない 高 start
                    return false;
                    // add #12628 検査結果のフィルタダイアログが開けない 高 end
                }
                // add #12585 水質管理.水質検査のフィルタ処理仕様修正 高 start
                else if (this.FilterType == EnumFilterType.WQTestPoint)
                {
                    RldMsgBox.Show(String.Format("水質検査項目コードの取得データがありません。"), "データなし", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                    return false;
                }
                // add #12585 水質管理.水質検査のフィルタ処理仕様修正 高 end
                // del #12628 検査結果のフィルタダイアログが開けない 高 start
                //return false;
                // del #12628 検査結果のフィルタダイアログが開けない 高 end
            }
            // add #12416 帳票移植時にフィルタ設定が無効化する（横展開） 高 end

            this.lstExam.DisplayMember = "Value";
            this.lstExam.ValueMember = "Code";
            this.lstExam.BeginUpdate();

            try
            {
                this.lstExam.Items.Clear();

                // フリーワードによるフィルタリングを適用
                if (!String.IsNullOrEmpty(this.txtFree.Text))
                {

                    // 日本語用の検索パラメータ指定用データを取得
                    var wCompareInfo = System.Globalization.CultureInfo.CurrentCulture.CompareInfo;

                    System.Func<String, Int32> wFuncFindIndex = aTarget => wCompareInfo.IndexOf(
                        aTarget,
                        this.txtFree.Text,
                        System.Globalization.CompareOptions.IgnoreCase | System.Globalization.CompareOptions.IgnoreWidth);

                    wList = wList.FindAll(ele => wFuncFindIndex(ele.Value) >= 0);
                }

                wList.ForEach(ele => this.lstExam.Items.Add(ele));

                wRet = true;
            }
            finally
            {
                this.lstExam.EndUpdate();
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
            this.lstExam.Items.Clear();
            this.txtExamCd.Clear();

            this.chkBefore.Checked = true;
            this.chkAfter.Checked = true;
            this.chkOther.Checked = true;
        }

        /// <summary>
        /// 画面の入力内容を確認します。
        /// </summary>
        /// <returns></returns>
        private Boolean DataCheck()
        {
            const String MSG_TITLE = @"確認してください";

            String wCodeType = @"項目";
            if (this.FilterType == EnumFilterType.ExaminSet) wCodeType = @"セット";

            // オンライン時
            if (this.IsOnline)
            {
                if (this.lstExam.SelectedItem == null)
                {
                    RldMsgBox.Show(String.Format("検査{0}を選択してください。", wCodeType), MSG_TITLE, MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                    this.lstExam.Focus();

                    return false;
                }
            }
            // オフライン時
            else
            {
                if (String.IsNullOrEmpty(this.txtExamCd.Text))
                {
                    RldMsgBox.Show(String.Format("検査{0}コードを入力して下さい。", wCodeType), MSG_TITLE, MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                    this.txtExamCd.Focus();

                    return false;
                }

                if (!System.Text.RegularExpressions.Regex.IsMatch(this.txtExamCd.Text, "^[a-zA-Z0-9]+ *$"))
                {
                    RldMsgBox.Show(String.Format("検査{0}コードは半角英数字のみで入力してください。", wCodeType), MSG_TITLE, MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                    this.txtExamCd.Focus();

                    return false;
                }
            }

            // mod FNSI-699,700,751 装置帳票の記録簿対応 夏 start
            //if ( !this.chkBefore.Checked && !this.chkAfter.Checked && !this.chkOther.Checked ) {
            // add #12585 水質管理.水質検査のフィルタ処理仕様修正 高 start
            //if (!this.chkBefore.Checked && !this.chkAfter.Checked && !this.chkOther.Checked && this.FilterType != EnumFilterType.Inspection)
            if (!this.chkBefore.Checked 
                && !this.chkAfter.Checked 
                && !this.chkOther.Checked 
                && this.FilterType != EnumFilterType.Inspection
                && this.FilterType != EnumFilterType.WQTestPoint
                )
            // add #12585 水質管理.水質検査のフィルタ処理仕様修正 高 end
            {
                // mod FNSI-699,700,751 装置帳票の記録簿対応 夏 end
                RldMsgBox.Show("検査区分を一つ以上選択して下さい。", MSG_TITLE, MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                this.chkBefore.Focus();

                return false;
            }

            return true;
        }

        /// <summary>
        /// 画面にデータを読み込みます。
        /// </summary>
        private void DataRead()
        {
            //add #9711 既存帳票を開くと致命的エラーが発生 dongzhaolong start
            bool canFindElement = false;
            //add #9711 既存帳票を開くと致命的エラーが発生 dongzhaolong end

            // フィルタが未設定の場合は抜ける
            if (String.IsNullOrEmpty(this.FilterData)) return;

            // 設定中のフィルタデータを読み込む(失敗時は抜ける)
            var wXmlDoc = new System.Xml.XmlDocument();
            try
            {
                wXmlDoc.LoadXml(this.FilterData);
            }
            catch
            {
                return;
            }

            var wChildNode = wXmlDoc.SelectNodes(String.Format("{0}/{1}", RldConst.FilterData.TAG_ROOT, RldConst.FilterData.TAG_ITEM));
            foreach (System.Xml.XmlNode wXmlChild in wChildNode)
            {

                this.chkBefore.Checked = wXmlChild.Attributes[RldConst.FilterData.ATT_ITEM_EXAMCLASS_BEFORE].InnerText == RldConst.FilterData.VAL_ATT_ITEM_EXAMCLASS_ON ? true : false;
                this.chkAfter.Checked = wXmlChild.Attributes[RldConst.FilterData.ATT_ITEM_EXAMCLASS_AFTER].InnerText == RldConst.FilterData.VAL_ATT_ITEM_EXAMCLASS_ON ? true : false;
                this.chkOther.Checked = wXmlChild.Attributes[RldConst.FilterData.ATT_ITEM_EXAMCLASS_OTHER].InnerText == RldConst.FilterData.VAL_ATT_ITEM_EXAMCLASS_ON ? true : false;

                var wCode = wXmlChild.Attributes[RldConst.FilterData.ATT_ITEM_CODE].InnerText;

                // オンライン時
                if (this.IsOnline)
                {
                    canFindElement = false;
                    foreach (Object wElement in this.lstExam.Items)
                    {
                        if (wElement is DesignComboBoxItemData wItem)
                        {
                            if (wItem.Code == wCode)
                            {
                                this.lstExam.SelectedItem = wElement;
                                //add #9711 既存帳票を開くと致命的エラーが発生 dongzhaolong start
                                canFindElement = true;
                                //add #9711 既存帳票を開くと致命的エラーが発生 dongzhaolong end

                                break;
                            }
                        }
                    }
                    //add #9711 既存帳票を開くと致命的エラーが発生 dongzhaolong start
                    if (canFindElement == false)
                    {
                        DesignParamData paramData = RldLib.CurrentLayoutData.DesignParamList.Where(ele => ele.CellAddress == this.CellAddress).ToList()[0];
                        if (paramData != null)
                        {
                            if (paramData.FilterType != string.Empty)
                            {
                                switch (paramData.FilterType)
                                {
                                    case RldConst.FilterType.Parameter.MEDICINE:         // 検査項目フィルタ
                                        paramData.FilterState = RldConst.GroupData.VAL_FILTER_STATE_ALL;
                                        paramData.FilterData = "<SelectSetting><Item tag=\"Medicine\" checkState=\"Checked\" /></SelectSetting>";
                                        break;
                                    case RldConst.FilterType.Parameter.EQUIP:            // 検査セットフィルタ
                                        paramData.FilterState = RldConst.GroupData.VAL_FILTER_STATE_ALL;
                                        paramData.FilterData = "<SelectSetting><Item tag=\"Equipment\" checkState=\"Checked\" /></SelectSetting>";
                                        break;
                                    // add #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする 高 start
                                    case RldConst.FilterType.Group.CATEGORY:
                                        paramData.FilterState = RldConst.GroupData.VAL_FILTER_STATE_ALL;
                                        paramData.FilterData = "<SelectSetting><Item tag=\"Category\" checkState=\"Checked\" /></SelectSetting>";
                                        break;
                                    // add #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする 高 end
                                    case RldConst.FilterType.Group.PATEVENT:        // イベント
                                    case RldConst.FilterType.Group.ADDITION:        // 加算
                                    case RldConst.FilterType.Group.DIALDIFF:        // 透析困難コメント
                                    case RldConst.FilterType.Group.OBSKIND:         // 観察記録種別
                                    // del #12050 FNW帳票コンバートで維持されない設定がある 高 start
                                    //case RldConst.FilterType.Group.EXAMINE:
                                    //case RldConst.FilterType.Group.EXAM_SET:
                                    // del #12050 FNW帳票コンバートで維持されない設定がある 高 end
                                    case RldConst.FilterType.Group.WATER_SURVEY:
                                    case RldConst.FilterType.Group.INSPECTION:
                                    // add #12585 水質管理.水質検査のフィルタ処理仕様修正 高 start
                                    case RldConst.FilterType.Group.WQTESTPOINT:
                                    // add #12585 水質管理.水質検査のフィルタ処理仕様修正 高 end
                                    // del #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする 高 start
                                    //case RldConst.FilterType.Group.CATEGORY:
                                    // del #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする 高 end
                                        paramData.FilterState = RldConst.ParamData.VAL_FILTER_STATE_NO;
                                        paramData.FilterData = "";
                                        break;
                                    // add #12050 FNW帳票コンバートで維持されない設定がある 高 start
                                    case RldConst.FilterType.Group.EXAMINE:
                                    case RldConst.FilterType.Group.EXAM_SET:
                                        if(paramData.FilterState != RldConst.ParamData.VAL_FILTER_STATE_RESET)
                                        {
                                            paramData.FilterState = RldConst.ParamData.VAL_FILTER_STATE_NO;
                                            paramData.FilterData = "";
                                        }
                                        break;
                                    // add #12050 FNW帳票コンバートで維持されない設定がある 高 end
                                    default:
                                        break;
                                }
                            }
                        }

                    }
                    //add #9711 既存帳票を開くと致命的エラーが発生 dongzhaolong end
                }
                // オフライン時
                else
                {
                    this.txtExamCd.Text = wCode;
                }
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
            String wCode = this.IsOnline ? (this.lstExam.SelectedItem as DesignComboBoxItemData)?.Code : this.txtExamCd.Text;

            // アイテムノードを作成
            var wXmlItem = wXmlDoc.CreateElement(RldConst.FilterData.TAG_ITEM);
            wXmlItem.SetAttribute(RldConst.FilterData.ATT_ITEM_CODE, wCode);
            // add #12026 帳票移植時にフィルタ設定が無効化する（初期対応） 高 start
            // mod #12416 帳票移植時にフィルタ設定が無効化する（横展開） 高 start
            // コードを取得
            if (this.FilterType == EnumFilterType.ExaminItem
                || this.FilterType == EnumFilterType.ExaminSet
                || this.FilterType == EnumFilterType.Inspection
                // add #12585 水質管理.水質検査のフィルタ処理仕様修正 高 start
                || this.FilterType == EnumFilterType.WQTestPoint
                // add #12585 水質管理.水質検査のフィルタ処理仕様修正 高 end
                )
            {
                string wName = this.IsOnline ? (this.lstExam.SelectedItem as DesignComboBoxItemData)?.Value : "";
                wXmlItem.SetAttribute(RldConst.FilterData.ATT_ITEM_NAME, wName);
            }
            // mod #12416 帳票移植時にフィルタ設定が無効化する（横展開） 高 end
            // add #12026 帳票移植時にフィルタ設定が無効化する（初期対応） 高 end
            wXmlItem.SetAttribute(RldConst.FilterData.ATT_ITEM_EXAMCLASS_BEFORE, this.chkBefore.Checked ? RldConst.FilterData.VAL_ATT_ITEM_EXAMCLASS_ON : RldConst.FilterData.VAL_ATT_ITEM_EXAMCLASS_OFF);
            wXmlItem.SetAttribute(RldConst.FilterData.ATT_ITEM_EXAMCLASS_AFTER, this.chkAfter.Checked ? RldConst.FilterData.VAL_ATT_ITEM_EXAMCLASS_ON : RldConst.FilterData.VAL_ATT_ITEM_EXAMCLASS_OFF);
            wXmlItem.SetAttribute(RldConst.FilterData.ATT_ITEM_EXAMCLASS_OTHER, this.chkOther.Checked ? RldConst.FilterData.VAL_ATT_ITEM_EXAMCLASS_ON : RldConst.FilterData.VAL_ATT_ITEM_EXAMCLASS_OFF);
            wXmlRoot.AppendChild(wXmlItem);

            // ドキュメントへ追加
            this.FilterData = (wXmlDoc.AppendChild(wXmlRoot)).OuterXml;

            this.IsApplySameGroup = this.chkDevelopment.Checked;
        }

        #endregion

        #region メンバ関数定義(ListViewItem)

        /// <summary>
        /// 検査項目フィルタ用表示データを作成して取得します。
        /// </summary>
        /// <returns></returns>
        private async Task<List<DesignComboBoxItemData>> CreateExamItemList()
        {
            var wResult = await RldLib.FilterDataSet.GetFilterExamItemData();
            var wRet = new List<DesignComboBoxItemData>();

            if (wResult.IsSuccess)
                wResult.Data.ForEach(
                    ele => wRet.Add(new DesignComboBoxItemData()
                    {
                        Code = ele.ExamItemCode.ToString(),
                        Value = ele.ExamItemName
                    }));

            return wRet;
        }
        private async Task<List<DesignComboBoxItemData>> CreateCategoryList()
        {
            var wResult = await RldLib.FilterDataSet.GetFilterCategoryData();
            var wRet = new List<DesignComboBoxItemData>();

            if (wResult.IsSuccess)
                wResult.Data.ForEach(
                    ele => wRet.Add(new DesignComboBoxItemData()
                    {
                        Code = ele.ItemCode.ToString(),
                        Value = ele.ItemName
                    }));

            return wRet;
        }

        /// <summary>
        /// 検査項目フィルタ用表示データを作成して取得します。
        /// </summary>
        /// <returns></returns>
        private async Task<List<DesignComboBoxItemData>> CreateExamSetList()
        {
            var wResult = await RldLib.FilterDataSet.GetFilterExamSetData();
            var wRet = new List<DesignComboBoxItemData>();

            if (wResult.IsSuccess)
                wResult.Data.ForEach(
                    ele => wRet.Add(new DesignComboBoxItemData()
                    {
                        Code = ele.ExamSetCode.ToString(),
                        Value = ele.ExamSetName
                    }));

            return wRet;
        }

        // add FNSI-699,700,751 装置帳票の記録簿対応 夏 start
        /// <summary>
        /// 点検フィルタ用表示データを作成して取得します。
        /// </summary>
        /// <returns></returns>
        private async Task<List<DesignComboBoxItemData>> CreateInspectionList()
        {
            var wResult = await RldLib.FilterDataSet.GetFilterInspectionData();
            var wRet = new List<DesignComboBoxItemData>();

            if (wResult.IsSuccess)
                wResult.Data.ForEach(
                    ele => wRet.Add(new DesignComboBoxItemData()
                    {
                        Code = ele.InspectionCode.ToString(),
                        // mod FNSI-4872 装置帳票の点検名表示内容改善 夏 start
                        //Value = ele.InspectionName
                        Value = "内容1：" + ele.InspectionName + "。　内容2：" + ele.InspectionName2
                        // mod FNSI-4872 装置帳票の点検名表示内容改善 夏 end
                    }));
            return wRet;
        }
        // add FNSI-699,700,751 装置帳票の記録簿対応 夏 end

        // add #12585 水質管理.水質検査のフィルタ処理仕様修正 高 start
        /// <summary>
        /// 水質検査フィルタ用表示データを作成して取得します。
        /// </summary>
        /// <returns></returns>
        private async Task<List<DesignComboBoxItemData>> CreateWQTestPointTreeNode()
        {
            var wResult = await RldLib.FilterDataSet.GetFilterWQTestPointData();
            var wRet = new List<DesignComboBoxItemData>();

            if (wResult.IsSuccess)
                wResult.Data.ForEach(
                    ele => wRet.Add(new DesignComboBoxItemData()
                    {
                        Code = ele.WaterSurveyPointCd.ToString(),
                        Value = ele.WaterSurveyPointName + "(" + ele.WaterSurveyTypeName + ")"
                    }));

            return wRet;
        }
        // add #12585 水質管理.水質検査のフィルタ処理仕様修正 高 end

        #endregion

        #region コントロールイベントハンドラ定義

        /// <summary>
        /// フリーワードの TextChanged イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private async void txtFree_TextChanged(object sender, EventArgs e)
        {
            await this.ShowOnlineExamList();
        }

        /// <summary>
        /// 一覧表示の DoubleClick イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void lstExam_DoubleClick(object sender, EventArgs e)
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
            if (!this.DataCheck()) return;

            // 入力内容を保存
            this.DataSave();

            // 閉じる
            this.DialogResult = DialogResult.OK;
            this.Close();
        }


        // add #12416 帳票移植時にフィルタ設定が無効化する（横展開） 高 start
        private async Task<List<DesignComboBoxItemData>> CreateTreeNode()
        {
            List<DesignComboBoxItemData> wList = null;

            // 作業用リストの作成
            switch (this.FilterType)
            {
                case EnumFilterType.Category:
                    wList = await this.CreateCategoryList();
                    break;
                case EnumFilterType.ExaminItem:
                    wList = await this.CreateExamItemList();
                    break;

                case EnumFilterType.ExaminSet:
                    wList = await this.CreateExamSetList();
                    break;

                // add #12585 水質管理.水質検査のフィルタ処理仕様修正 高 start
                case EnumFilterType.WQTestPoint:   // 水質検査フィルタ
                    wList = await this.CreateWQTestPointTreeNode();
                    break;
                // add #12585 水質管理.水質検査のフィルタ処理仕様修正 高 end

                // add FNSI-699,700,751 装置帳票の記録簿対応 夏 start
                case EnumFilterType.Inspection:  // 点検フィルタ
                    wList = await this.CreateInspectionList();
                    if (wList.Count == 0)
                    {
                        //RldMsgBox.Show(String.Format("点検詳細品目コードの取得データがありません。"), "データなし", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                        return wList;
                    }
                    break;
                // add FNSI-699,700,751 装置帳票の記録簿対応 夏 end
                default:
                    break;
            }

            return wList;
        }

        // set code when name is same
        public async void setItemCodeName()
        {
            List<DesignComboBoxItemData> wList = null;
            bool bExist = false;
            bool bNotFind = false;

            // get tree node from DB
            wList = await this.CreateTreeNode();

            // read FilterData of ExamItem from DB
            if (wList == null || wList.Count == 0)
            {
                // mod #12628 検査結果のフィルタダイアログが開けない 高 start
                if (this.FilterType == EnumFilterType.Inspection)
                {
                    if (this.IsInspection == false)
                    {
                        this.IsInspection = true;
                        RldMsgBox.Show(String.Format("点検詳細品目コードの取得データがありません。"), "データなし", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                    }
                }
                else if (this.FilterType == EnumFilterType.WQTestPoint)
                {
                    if (this.IsInspection == false)
                    {
                        this.IsInspection = true;
                        RldMsgBox.Show(String.Format("水質検査項目コードの取得データがありません。"), "データなし", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                    }
                }
                // mod #12628 検査結果のフィルタダイアログが開けない 高 end

                // not find item in DB
                clsFilterData = true;
                return;
            }

            // 設定中のフィルタデータを読み込む(失敗時は抜ける)
            var wXmlDoc = new System.Xml.XmlDocument();
            try
            {
                wXmlDoc.LoadXml(this.FilterData);
            }
            catch
            {
                return;
            }

            bExist = false;
            this.cntTotal++;

            var wChildNode = wXmlDoc.SelectNodes(String.Format("{0}/{1}", RldConst.FilterData.TAG_ROOT, RldConst.FilterData.TAG_ITEM));
            foreach (System.Xml.XmlNode wXmlChild in wChildNode)
            {
                // get attributes
                var wCodeAttr = wXmlChild.Attributes[RldConst.FilterData.ATT_ITEM_CODE];
                if (wCodeAttr == null) continue;
                string wCode = wCodeAttr.InnerText;

                var wNameAttr = wXmlChild.Attributes[RldConst.FilterData.ATT_ITEM_NAME];
                if (wNameAttr == null) cntNotName++;

                bNotFind = false;
                List<DesignComboBoxItemData> wList1;
                if (wNameAttr == null)
                {
                    wList1 = wList.FindAll(ele => ele.Code == wCode);
                    if (wList1.Count == 0)
                    {
                        cntErrTotal++;
                        continue;
                    }
                }
                else
                {
                    string wName = wNameAttr.Value;
                    wList1 = wList.FindAll(ele => ele.Code == wCode && ele.Value == wName);
                    if (wList1.Count == 0)
                    {
                        bNotFind = true;
                        cntErrTotal++;
                    }
                }

                if (bNotFind == true)
                {
                    string wName = wNameAttr.Value;
                    var wList2 = wList.FindAll(ele => ele.Value == wName);
                    if (wList2.Count > 0)
                    {
                        // find code 
                        var validItems = wList2
                            .Select(ele => new { Item = ele, CodeNum = int.TryParse(ele.Code, out int num) ? num : (int?)null })
                            .Where(x => x.CodeNum.HasValue)
                            .ToList();

                        if (validItems.Count > 0)
                        {
                            // find max code of same name
                            var maxItem = validItems.OrderByDescending(x => x.CodeNum).First().Item;
                            wCodeAttr.InnerText = maxItem.Code;
                            bExist = true;
                            cntCovert++;
                        }
                        else
                        {
                            // not find code
                            clsFilterData = true;
                            return;
                        }
                    }
                    else
                    {
                        // not find same name
                        clsFilterData = true;
                        return;
                    }
                }

                break;
            }

            // modify FilterData
            if (bExist == true)
            {
                this.FilterData = wXmlDoc.OuterXml;
            }
        }
        // add #12416 帳票移植時にフィルタ設定が無効化する（横展開） 高 end

        #endregion
    }
}
