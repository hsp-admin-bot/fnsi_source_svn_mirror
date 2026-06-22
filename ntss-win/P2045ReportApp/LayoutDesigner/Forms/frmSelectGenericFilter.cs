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
    /// 汎用フィルター選択画面
    /// </summary>
    public partial class frmSelectGenericFilter : LayoutDesignerUtilityLib.Controls.frmRldSizableBase
    {
        #region メンバ列挙体定義

        /// <summary>
        /// フィルタ項目
        /// </summary>
        public enum EnumFilterType
        {
            /// <summary>
            /// 初期値
            /// </summary>
            None = 0,
            /// <summary>
            /// 薬剤
            /// </summary>
            Medicine,
            /// <summary>
            /// 医療材料
            /// </summary>
            Equipment,
            /// <summary>
            /// 観察記録種別
            /// </summary>
            ObsKind,
            /// <summary>
            /// イベント
            /// </summary>
            PatEvent,
            /// <summary>
            /// 加算(旧レセプトメモ)
            /// </summary>
            Addition,
            /// <summary>
            /// 透析困難
            /// </summary>
            DialDiff,
            //add #8489 start
            /// <summary>
            /// 配布リスト(ベッド)
            /// </summary>
            Distribution,
            //add #8489 end
            // add #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする 高 start
            /// <summary>
            /// イベント
            /// </summary>
            Category,
            // add #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする 高 end
            // add #11494 データセットにカテゴリ「レセプト」を追加 limingzhe start
            /// <summary>
            /// レセプト
            /// </summary>
            Receipt,
            // add #11494 データセットにカテゴリ「レセプト」を追加 limingzhe end
            // add #11625 クラス「指示履歴」の仕様変更② 高 start
            /// <summary>
            /// 指示履歴
            /// </summary>
            logTarget,
            // add #11625 クラス「指示履歴」の仕様変更② 高 end
            // add #12006 感染症がフィルタできない 高 start
            /// <summary>
            /// 感染症
            /// </summary>
            Infection,
            // add #12006 感染症がフィルタできない 高 end
            // add #12756 クラス「##準備リスト.物品情報」のフィルタ設定が不十分 高 start
            /// <summary>
            /// 物品情報
            /// </summary>
            Goods,
            // add #12756 クラス「##準備リスト.物品情報」のフィルタ設定が不十分 高 end
            // add #10370 装置帳票向けの「水質管理」データ項目を検討する 高 start
            // mod #12585 水質管理.水質検査のフィルタ処理仕様修正 高 start
            /// <summary>
            /// 水質検査
            /// </summary>
            WQTestType,
            // mod #12585 水質管理.水質検査のフィルタ処理仕様修正 高 end
            // add #10370 装置帳票向けの「水質管理」データ項目を検討する 高 end
            // add #11789 【因島】準備リストを医材と薬剤と分けて出力することができない limingzhe start
            /// <summary>
            /// 器材
            /// </summary>
            EquipDia
            // add #11789 【因島】準備リストを医材と薬剤と分けて出力することができない limingzhe end
        }

        #endregion

        #region 生成と破棄

        public frmSelectGenericFilter()
        {
            InitializeComponent();

            // アイコンの設定
            this.Icon = Properties.Resources.LayoutDesigner;

            // イベントハンドラ割り当て
            this.btnOK.Click += new EventHandler(this.btnOK_Click);
        }

        #endregion

        #region メンバプロパティ定義

        /// <summary>
        /// フィルター種別の取得及び設定を行います。
        /// </summary>
        internal EnumFilterType FilterType { get; set; } = frmSelectGenericFilter.EnumFilterType.None;

        /// <summary>
        /// 設定中のフィルターデータの取得及び設定を行います。
        /// </summary>
        internal String FilterData { get; set; } = String.Empty;

        /// <summary>
        /// 編集箇所を特定できる情報の取得及び設定を行います。
        /// </summary>
        internal String Path { get; set; } = String.Empty;

        /// <summary>
        /// 一部のアイテムのみを選択したかどうかの取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        internal Boolean IsSelectPart { get; private set; } = false;

        // add #7840 帳票（単患者）：薬剤にフィルター機能がない 王永吉 start
        private List<string> doPassData = new List<string> { "Medicine", "Equip", "Llt", "Event", "ReceMemo", "DialDiff", "Equipment" };
        // add #7840 帳票（単患者）：薬剤にフィルター機能がない 王永吉 end

        // add #12416 帳票移植時にフィルタ設定が無効化する（横展開） 高 start
        internal int cntErrTotal { get; set; } = 0;
        internal int cntCovert { get; set; } = 0;
        internal int cntTotal { get; set; } = 0;
        internal int cntNotName { get; set; } = 0;
        internal bool clsFilterData { get; set; } = false;
        // add #12416 帳票移植時にフィルタ設定が無効化する（横展開） 高 end

        // add #11625 クラス「指示履歴」の仕様変更② 高 start
        private List<string> logTargetData = new List<string>
        {
            "治療予定",
            "治療方法 ",
            "クール ",
            "治療開始時刻",
            "ベッド",
            "治療時間",
            "VA",
            "DW ",
            "目標体重",
            "除水量制限",
            "ダイアライザ ",
            "吸着カラム ",
            "1次膜 ",
            "2次膜 ",
            "穿刺針(A針) ",
            "穿刺針(V針)",
            "穿刺針(SN)",
            "シングルニードル使用 ",
            "血液回路",
            "血流量 ",
            "透析液 ",
            "透析液流量 ",
            "透析液使用数 ",
            "透析液温度 ",
            "補液",
            "補液量 ",
            "補液選択 ",
            "補液使用数 ",
            "補液温度 ",
            "補液速度 ",
            "抗凝固剤 ",
            "抗凝固剤ワンショット量 ",
            "抗凝固剤持続速度 ",
            "抗凝固剤持続総量 ",
            "IP使用選択 ",
            "IPスタート ",
            "IPワンショット量 ",
            "IP速度 ",
            "IP速度最大値 ",
            "自動ワンショット ",
            "IP電源自動切り ",
            "IP電源自動切り時間 ",
            "IP電源OKモニタ切り ",
            "IP電源OKモニタ切り時間 ",
            "投与薬剤(数量+単位) ",
            "投与薬剤(薬剤名+数量+単位) ",
            "医療材料 ",
            "指示コメント"
        };
        // add #11625 クラス「指示履歴」の仕様変更② 高 end

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

            // 画面をクリア
            this.DataClear(true);

            // 画面を初期化(失敗時は抜ける)
            if( !await this.InitWindow() ) { this.Close(); return; }
            // add #7840 帳票（単患者）：薬剤にフィルター機能がない 王永吉 start
            //if (RldDataGridViewParamDataEditHelper.middleData != null) {
            //    if (RldDataGridViewParamDataEditHelper.middleData.ContainsKey(this.Path))
            //    {
            //        this.FilterData = RldDataGridViewParamDataEditHelper.middleData[this.Path];
            //    }
            //}
            // add #7840 帳票（単患者）：薬剤にフィルター機能がない 王永吉 end
            // フィルタが未設定の場合は全選択状態に設定する
            //update #8489 zhu start
            if (String.IsNullOrEmpty(this.FilterData))
            {
                for(int i=0;i< this.rldTriStateTreeView.Nodes.Count;i++)
                { 
                    ((RldTriStateTreeNode)this.rldTriStateTreeView.Nodes[i]).SetCheckedState(CheckState.Checked);
                    this.IsSelectPart = false;
                }
                return;
            }

            //update #8489 zhu start
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
            // パスをセット
            this.lblPathAddr.Text = this.Path;

            String wTitle = String.Empty;
            TreeNode wNode = null;
            //add #8489 zhu start
            TreeNode wNode2 = null;
            //add #8489 zhu end
            // mod #12416 帳票移植時にフィルタ設定が無効化する（横展開） 高 start
            //switch ( this.FilterType ) {
            //    case EnumFilterType.ObsKind:    // 観察記録種別
            //        wTitle = @"観察記録種別フィルタ設定";
            //        wNode= await this.CreateObsKindTreeNode();
            //        break;

            //    case EnumFilterType.Medicine:   // 薬剤フィルタ
            //        wTitle = @"薬剤フィルタ設定";
            //        wNode = await this.CreateMedicineTreeNode();
            //        break;

            //    case EnumFilterType.Equipment:  // 医材フィルタ
            //        wTitle = @"医療材料フィルタ設定";
            //        wNode = await this.CreateEquipmentTreeNode();
            //        break;

            //    case EnumFilterType.DialDiff:   // 透析困難
            //        wTitle = @"透析困難フィルタ設定";
            //        wNode = await this.CreateDialDiffTreeNode();
            //        break;

            //    case EnumFilterType.PatEvent:   // 患者イベント
            //        wTitle = @"イベントフィルタ設定";
            //        wNode = await this.CreatePatEventTreeNode();
            //        break;

            //    case EnumFilterType.Addition:   // 加算
            //        wTitle = @"加算フィルタ設定";
            //        wNode = await this.CreateAdditionTreeNode();
            //        break;
            //    //add #8489 zhu start
            //    case EnumFilterType.Distribution:
            //        wTitle = @"配布リスト(ベッド)設定";
            //        wNode = await this.CreateMedicineTreeNode();
            //        wNode2 = await this.CreateDistributionsTreeNode();
            //        break;
            //    //add #8489 zhu end
            //    // add #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする 高 start
            //    case EnumFilterType.Category:   // 患者イベント
            //        wTitle = @"患者イベントフィルタ設定";
            //        wNode = await this.CreatePatEventTreeNode();
            //        break;
            //    // add #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする 高 end
            //    // add #11494 データセットにカテゴリ「レセプト」を追加 limingzhe start
            //    case EnumFilterType.Receipt:   // レセプトフィルタ
            //        wTitle = @"レセプトフィルタ設定";
            //        wNode = await this.CreateReceiptTreeNode();
            //        break;
            //    // add #11494 データセットにカテゴリ「レセプト」を追加 limingzhe end
            //    // add #11625 クラス「指示履歴」の仕様変更② 高 start
            //    case EnumFilterType.logTarget:   // 指示履歴フィルタ
            //        wTitle = @"指示履歴フィルタ設定";
            //        wNode = await this.CreateLogTargetTreeNode();
            //        break;
            //    // add #11625 クラス「指示履歴」の仕様変更② 高 end
            //    // add #12006 感染症がフィルタできない 高 start
            //    case EnumFilterType.Infection:   // 感染症フィルタ
            //        wTitle = @"感染症フィルタ設定";
            //        wNode = await this.CreateInfectionTreeNode();
            //        break;
            //    // add #12006 感染症がフィルタできない 高 end
            //    // add #11789 【因島】準備リストを医材と薬剤と分けて出力することができない limingzhe start
            //    case EnumFilterType.EquipDia:   // 器材フィルタ
            //        wTitle = @"器材フィルタ設定";
            //        wNode = await this.CreateEquipDiaTreeNode();
            //        break;
            //    // add #11789 【因島】準備リストを医材と薬剤と分けて出力することができない limingzhe end
            //    default:
            //        break;
            //}

            TreeNodeCreationContext wContext = new TreeNodeCreationContext();
            wContext.wNode = null;
            wContext.wNode2 = null;
            wContext.wTitle = string.Empty;

            wContext = await this.CreateTreeNode(wContext);
            wNode = wContext.wNode;
            wTitle = wContext.wTitle;
            wNode2 = wContext.wNode2;
            // mod #12416 帳票移植時にフィルタ設定が無効化する（横展開） 高 end


            // 表示するデータがない場合はぬける
            if ( wNode == null ) return false;

            this.winlblTitle.Text = wTitle;

            try {
                this.rldTriStateTreeView.SuspendLayout();

                // 表示データをセット
                this.rldTriStateTreeView.Nodes.Add(wNode);
                //add #8489 zhu start
                if (wNode2 != null)
                {
                    this.rldTriStateTreeView.Nodes.Add(wNode2);
                }                
                //add #8489 zhu end
                // ルートノードを展開しておく
                this.rldTriStateTreeView.Nodes[0].Expand();
            }
            finally {
                this.rldTriStateTreeView.ResumeLayout();
            }

            return true;
        }

        /// <summary>
        /// 画面の入力内容をクリアします。
        /// </summary>
        /// <param name="aIsKeyClear"></param>
        private void DataClear(Boolean aIsKeyClear)
        {
            this.rldTriStateTreeView.Nodes.Clear();
        }

        /// <summary>
        /// 画面の入力内容を確認します。
        /// </summary>
        /// <returns></returns>
        private Boolean DataCheck()
        {
            //update #8489 zhu start
            var wFirstNode =new RldTriStateTreeNode();
            bool Ischecked = false;
            foreach (TreeNode tn in rldTriStateTreeView.Nodes)
            {
                wFirstNode = tn as RldTriStateTreeNode;
                if (wFirstNode.CheckState != CheckState.Unchecked)
                {
                    Ischecked = true;
                }
            }
            if( Ischecked==false ) {
                RldMsgBox.Show(this, "絞り込み条件を選択してください。", "確認してください", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                this.rldTriStateTreeView.Focus();
                return false;
            }
            //update #8489 zhu start
            return true;
        }

        /// <summary>
        /// 画面にデータを読み込みます。
        /// </summary>
        private void DataRead()
        {
            // 設定中のフィルタデータを読み込む(失敗時は抜ける)
            var wXmlDoc = new System.Xml.XmlDocument();
            try {
                // mod #7840 帳票（単患者）：薬剤にフィルター機能がない 王永吉 start
                //wXmlDoc.LoadXml(this.FilterData);
                if (RldDataGridViewParamDataEditHelper.middleData.ContainsKey(this.Path))
                {
                    wXmlDoc.LoadXml(RldDataGridViewParamDataEditHelper.middleData[this.Path]);
                } else {
                    wXmlDoc.LoadXml(this.FilterData);
                }
                // mod #7840 帳票（単患者）：薬剤にフィルター機能がない 王永吉 end
            }
            catch {
                return;
            }

            var wChildNode = wXmlDoc.SelectNodes(String.Format("{0}/{1}", RldConst.FilterData.TAG_ROOT, RldConst.FilterData.TAG_ITEM));
            foreach( System.Xml.XmlNode wXmlChild in wChildNode ) {
                String wChildTagText = wXmlChild.Attributes[RldConst.FilterData.ATT_ITEM_TAG].InnerText;

                foreach( RldTriStateTreeNode wTreeNode in this.rldTriStateTreeView.Nodes ) {

                    if( Convert.ToString(wTreeNode.Tag) == wChildTagText ) {
                        // 再帰処理にてツリービューの選択状態を復元
                        LFunc_DataReadRecursive(wXmlChild, wTreeNode);
                        break;
                    }
                }
            }

            /// <summary>
            /// (ローカル関数) 子ノードの選択状態を再帰的に復元します。
            /// </summary>
            /// <param name="aXmlNode"></param>
            /// <param name="aTreeNode"></param>
            void LFunc_DataReadRecursive(System.Xml.XmlNode aXmlNode, RldTriStateTreeNode aTreeNode)
            {
                String wTagText = aXmlNode.Attributes[RldConst.FilterData.ATT_ITEM_TAG].InnerText;
                String wCheckStateText = aXmlNode.Attributes[RldConst.FilterData.ATT_ITEM_CHECKSTATE].InnerText;

                CheckState wCheckState = (CheckState)Enum.Parse(typeof(CheckState), wCheckStateText, false);
                if( wCheckState == CheckState.Checked )
                    aTreeNode.Checked = true;
                else if( wCheckState == CheckState.Unchecked )
                    aTreeNode.Checked = false;
                else {
                    var wChildNodeRecursive = aXmlNode.SelectNodes(RldConst.FilterData.TAG_ITEM);

                    foreach( System.Xml.XmlNode xmlChild in wChildNodeRecursive ) {

                        String wChildTagText = xmlChild.Attributes[RldConst.FilterData.ATT_ITEM_TAG].InnerText;
                        foreach( RldTriStateTreeNode wTreeNodeRecursive in aTreeNode.Nodes ) {

                            if( Convert.ToString(wTreeNodeRecursive.Tag) == wChildTagText ) {
                                LFunc_DataReadRecursive(xmlChild, wTreeNodeRecursive);
                                break;
                            }
                        }
                    }
                }
            }
        }

        /// <summary>
        /// 画面の入力内容を保存します。
        /// </summary>
        private void DataSave()
        {
            // 全ノードを選択した状態にする
            this.IsSelectPart = false;
            this.FilterData = String.Empty;
            // add #12416 帳票移植時にフィルタ設定が無効化する（横展開） 高 start
            bool bFirstNode = false;
            // add #12416 帳票移植時にフィルタ設定が無効化する（横展開） 高 end

            // ノードがない場合は抜ける
            if ( this.rldTriStateTreeView.GetNodeCount(true) == 0 ) return;

            var wXmlDoc = new System.Xml.XmlDocument();

            // ルートノードを作成
            var wXmlRoot = wXmlDoc.CreateElement(RldConst.FilterData.TAG_ROOT);

            foreach( RldTriStateTreeNode wTreeNode in this.rldTriStateTreeView.Nodes ) {
                // 子ノードを追加
                var wXmlElement = LFunc_DataSaveRecursive(wTreeNode);
                wXmlRoot.AppendChild(wXmlElement);
            }

            // ドキュメントへ追加
            this.FilterData = (wXmlDoc.AppendChild(wXmlRoot)).OuterXml;

            // ルートノードが半チェック状態の場合はフィルタの選択状態は全てではない
            //update #8489 zhu start
            //var wFirstNode = this.rldTriStateTreeView.Nodes[0] as RldTriStateTreeNode;
            //if( wFirstNode.CheckState == CheckState.Indeterminate ) {
            //    this.IsSelectPart = true;
            //}
            var wFirstNode = new RldTriStateTreeNode();
            foreach (TreeNode tn in rldTriStateTreeView.Nodes)
            {
                wFirstNode = tn as RldTriStateTreeNode;
                if (wFirstNode.CheckState != CheckState.Checked)
                {
                    this.IsSelectPart = true;
                }
            }
            //update #8489 zhu end

            /// <summary>
            /// (ローカル関数) 子ノードを再帰的に保存します。
            /// </summary>
            /// <param name="aTreeNode"></param>
            System.Xml.XmlElement LFunc_DataSaveRecursive( RldTriStateTreeNode aTreeNode)
            {
                var wRet = wXmlDoc.CreateElement(RldConst.FilterData.TAG_ITEM);
                wRet.SetAttribute(RldConst.FilterData.ATT_ITEM_TAG, Convert.ToString(aTreeNode.Tag));
                // add #12416 帳票移植時にフィルタ設定が無効化する（横展開） 高 start
                if (bFirstNode)
                    wRet.SetAttribute(RldConst.FilterData.ATT_ITEM_NAME, Convert.ToString(aTreeNode.Text));
                else
                    bFirstNode = true;
                // add #12416 帳票移植時にフィルタ設定が無効化する（横展開） 高 end
                wRet.SetAttribute(RldConst.FilterData.ATT_ITEM_CHECKSTATE, Convert.ToString(aTreeNode.CheckState));

                if( aTreeNode.CheckState == CheckState.Indeterminate ) {
                    foreach( RldTriStateTreeNode wChildNode in aTreeNode.Nodes ) {
                        if( wChildNode.CheckState != CheckState.Unchecked ) {
                            var wXmlChildElement = LFunc_DataSaveRecursive(wChildNode);
                            wRet.AppendChild(wXmlChildElement);
                        }
                    }
                }

                return wRet;
            }
            // add #7840 帳票（単患者）：薬剤にフィルター機能がない 王永吉 start
            if (doPassData.Contains(this.FilterType.ToString())) {
                if (RldDataGridViewParamDataEditHelper.middleData.ContainsKey(this.Path))
                {
                    RldDataGridViewParamDataEditHelper.middleData.Remove(this.Path);
                }
                RldDataGridViewParamDataEditHelper.middleData.Add(this.Path, this.FilterData);

            }
            // add #7840 帳票（単患者）：薬剤にフィルター機能がない 王永吉 end
        }

        #endregion

        #region メンバ関数定義(TreeView Node)

        /// <summary>
        /// 観察記録種別フィルタ用 TreeNode を作成して取得します。
        /// </summary>
        /// <returns></returns>
        private async Task<TreeNode> CreateObsKindTreeNode()
        {
            var wRet = new RldTriStateTreeNode() {
                CheckboxVisible = true,
                IsContainer = true,
                Text = "観察記録カテゴリ",
                Tag = EnumFilterType.ObsKind,
            };

            var wList = new List<FilterObsKindData>();

            // 観察記録種別一覧を取得
            if(SignInLib.SignIn.SignInInfo.IsOnline ) {
                if( (await RldLib.FilterDataSet.GetFilterObsKindData() is RldRestResultData<List<FilterObsKindData>> wResult) && wResult.IsSuccess )
                    wList = wResult.Data;
            }
            else {
                for( Int32 i = 0; i < 50; i++ )
                    wList.Add(new FilterObsKindData() { KindNo = i, KindName = String.Format("カテゴリ{0}", i + 1) });
            }

            foreach( var wData in wList ) {
                var wNode = new RldTriStateTreeNode(wData.KindName) {
                    CheckboxVisible = true,
                    Tag = wData.KindNo
                };
                wRet.Nodes.Add(wNode);
            }

            return wRet;
        }

        /// <summary>
        /// 薬剤フィルタ用 TreeNode を作成して取得します。
        /// </summary>
        /// <returns></returns>
        private async Task<TreeNode> CreateMedicineTreeNode()
        {
            var wList = new List<FilterMedicineData>();

            // 薬剤フィルタ一覧を取得
            if( (await RldLib.FilterDataSet.GetFilterMedicineData() is RldRestResultData<List<FilterMedicineData>> wResult) && wResult.IsSuccess )
                wList = wResult.Data;

            // ルートノード生成
            var wRet = new RldTriStateTreeNode() {
                CheckboxVisible = true,
                IsContainer = true,
                Text = "薬剤",
                Tag = EnumFilterType.Medicine
            };

            Int64 wClassCode = Int64.MinValue;
            Int32 wMediType = Int32.MinValue;

            RldTriStateTreeNode wNodeClass = null, wNodeMediType = null;

            foreach( var wData in wList ) {

                // 薬剤分類が変わったらルートノードへ追加
                // mod #7840 帳票（単患者）：薬剤にフィルター機能がない 王永吉 start
                //if( wClassCode != wData.ClassCode ) {
                if( wMediType != wData.MedicineType ) {
                // mod #7840 帳票（単患者）：薬剤にフィルター機能がない 王永吉 end
                    if ( wNodeClass != null ) {
                        // 薬剤種別を薬剤分類ノードへ追加
                        if( wNodeMediType != null ) wNodeClass.Nodes.Add(wNodeMediType);
                        // ルートノードへ追加
                        wRet.Nodes.Add(wNodeClass);
                    }

                    // 薬剤分類ノードを生成
                    wNodeClass = new RldTriStateTreeNode() {
                        CheckboxVisible = true,
                        IsContainer = true,
                        // mod #7840 帳票（単患者）：薬剤にフィルター機能がない 王永吉 start
                        //Tag = wData.ClassCode,
                        //Text = wData.ClassName
                        Tag = wData.MedicineType,
                        Text = wData.MedicineTypeName
                        // mod #7840 帳票（単患者）：薬剤にフィルター機能がない 王永吉 end
                    };
                    // mod #7840 帳票（単患者）：薬剤にフィルター機能がない 王永吉 start
                    //// 薬剤分類を記憶
                    //wClassCode = wData.ClassCode;
                    //// 薬剤種別をクリア
                    //wMediType = Int32.MinValue;
                    // 薬剤種別を記憶
                    wMediType = wData.MedicineType;
                    // 薬剤種別をクリア
                    wClassCode = Int64.MinValue;
                    // mod #7840 帳票（単患者）：薬剤にフィルター機能がない 王永吉 end
                    wNodeMediType = null;
                }

                // 薬剤種別が変わったら薬剤分類ノードへ追加
                // mod #7840 帳票（単患者）：薬剤にフィルター機能がない 王永吉 start
                //if( wMediType != wData.MedicineType ) {
                if (wClassCode != wData.ClassCode){
                // mod #7840 帳票（単患者）：薬剤にフィルター機能がない 王永吉 end
                    // 薬剤種別ノードへ追加
                    if ( wNodeMediType != null ) wNodeClass.Nodes.Add(wNodeMediType);

                    // 薬剤種別ノードを生成
                    wNodeMediType = new RldTriStateTreeNode() {
                        CheckboxVisible = true,
                        IsContainer = true,
                        // mod #7840 帳票（単患者）：薬剤にフィルター機能がない 王永吉 start
                        //Tag = wData.MedicineType,
                        //Text = wData.MedicineTypeName
                        Tag = wData.ClassCode,
                        Text = wData.ClassName
                        // mod #7840 帳票（単患者）：薬剤にフィルター機能がない 王永吉 end
                    };
                    // mod #7840 帳票（単患者）：薬剤にフィルター機能がない 王永吉 start
                    //// 薬剤種別を記憶
                    //wMediType = wData.MedicineType;
                    // 薬剤分類を記憶
                    wClassCode = wData.ClassCode;
                    // mod #7840 帳票（単患者）：薬剤にフィルター機能がない 王永吉 end
                }

                // 薬剤は薬剤種別ノードへ追加
                if( wData.MedicineCode != 0 ) {
                    wNodeMediType.Nodes.Add(new RldTriStateTreeNode() {
                        CheckboxVisible = true,
                        Tag = wData.MedicineCode,
                        Text = wData.MedicineName
                    });
                }
            }

            // 最後の薬剤分類をルートノードへ追加
            if( wNodeClass != null ) {
                if( wNodeMediType != null ) wNodeClass.Nodes.Add(wNodeMediType);
                wRet.Nodes.Add(wNodeClass);
            }

            return wRet;
        }

        // add #12756 クラス「##準備リスト.物品情報」のフィルタ設定が不十分 高 start
        /// <summary>
        /// 薬剤フィルタ用 TreeNode を作成して取得します。
        /// 通常薬剤/調製薬剤が不要
        /// </summary>
        /// <returns></returns>
        private async Task<TreeNode> CreateMedicineNoTreeNode()
        {
            var wList = new List<FilterMedicineData>();

            // 薬剤フィルタ一覧を取得
            if ((await RldLib.FilterDataSet.GetFilterMedicineData() is RldRestResultData<List<FilterMedicineData>> wResult) && wResult.IsSuccess)
                wList = wResult.Data;

            // ルートノード生成
            var wRet = new RldTriStateTreeNode()
            {
                CheckboxVisible = true,
                IsContainer = true,
                Text = "薬剤",
                Tag = EnumFilterType.Medicine
            };

            Int64 wClassCode = Int64.MinValue;
            Int32 wMediType = Int32.MinValue;

            RldTriStateTreeNode wNodeMediType = null;

            foreach (var wData in wList)
            {

                // 薬剤分類が変わったらルートノードへ追加
                if (wMediType != wData.MedicineType)
                {
                    // 薬剤種別を薬剤分類ノードへ追加
                    if (wNodeMediType != null) wRet.Nodes.Add(wNodeMediType);

                    // 薬剤種別を記憶
                    wMediType = wData.MedicineType;

                    // 薬剤種別をクリア
                    wClassCode = Int64.MinValue;
                    wNodeMediType = null;
                }

                // 薬剤種別が変わったら薬剤分類ノードへ追加
                if (wClassCode != wData.ClassCode)
                {
                    // 薬剤種別ノードへ追加
                    if (wNodeMediType != null) wRet.Nodes.Add(wNodeMediType);

                    // 薬剤種別ノードを生成
                    wNodeMediType = new RldTriStateTreeNode()
                    {
                        CheckboxVisible = true,
                        IsContainer = true,
                        Tag = wData.ClassCode,
                        Text = wData.ClassName
                    };

                    // 薬剤分類を記憶
                    wClassCode = wData.ClassCode;
                }

                // 薬剤は薬剤種別ノードへ追加
                if (wData.MedicineCode != 0)
                {
                    wNodeMediType.Nodes.Add(new RldTriStateTreeNode()
                    {
                        CheckboxVisible = true,
                        Tag = wData.MedicineCode,
                        Text = wData.MedicineName
                    });
                }
            }

            // 最後の薬剤分類をルートノードへ追加
            if (wNodeMediType != null) wRet.Nodes.Add(wNodeMediType);

            return wRet;
        }
        // add #12756 クラス「##準備リスト.物品情報」のフィルタ設定が不十分 高 end

        /// <summary>
        /// 医材フィルタ用 TreeNode を作成して取得します。
        /// </summary>
        /// <returns></returns>
        private async Task<TreeNode> CreateEquipmentTreeNode()
        {
            var wList = new List<FilterEquipData>();

            // 医材フィルタ一覧を取得
            if( (await RldLib.FilterDataSet.GetFilterEquipmentData() is RldRestResultData<List<FilterEquipData>> wResult) && wResult.IsSuccess )
                wList = wResult.Data;

            // ルートノード生成
            var wRet = new RldTriStateTreeNode() {
                CheckboxVisible = true,
                IsContainer = true,
                Text = "医材",
                Tag = EnumFilterType.Equipment
            };

            Int64 wClassType = Int64.MinValue;

            RldTriStateTreeNode wNodeClass = null;

            foreach( var wData in wList ) {

                // 医材分類が変わったらルートノードへ追加
                if( wClassType != wData.ClassType ) {

                    // ルートノードへ追加
                    if( wNodeClass != null ) wRet.Nodes.Add(wNodeClass);                   

                    // 医材分類ノードを生成
                    wNodeClass = new RldTriStateTreeNode() {
                        CheckboxVisible = true,
                        IsContainer = true,
                        Tag = wData.ClassType,
                        Text = wData.ClassName
                    };

                    // 医材分類を記憶
                    wClassType = wData.ClassType;
                }

                // 医材は医材分類ノードへ追加
                if( wData.EquipCode != 0 ) {
                    wNodeClass.Nodes.Add(new RldTriStateTreeNode() {
                        CheckboxVisible = true,
                        Tag = wData.EquipCode,
                        Text = wData.EquipName
                    });
                }
            }

            // 最後の医材分類をルートノードへ追加
            if( wNodeClass != null ) wRet.Nodes.Add(wNodeClass);

            return wRet;
        }

        /// <summary>
        /// 透析困難フィルタ用 TreeNode を作成して取得します。
        /// </summary>
        /// <returns></returns>
        private async Task<TreeNode> CreateDialDiffTreeNode()
        {
            var wList = new List<FilterDialDiffData>();

            // 透析困難フィルタを取得
            if( (await RldLib.FilterDataSet.GetFilterDialDiffData() is RldRestResultData<List<FilterDialDiffData>> wResult) && wResult.IsSuccess )
                wList = wResult.Data;

            // ルートノードを生成
            var wRet = new RldTriStateTreeNode() {
                CheckboxVisible = true,
                IsContainer = true,
                Text = "透析困難",
                Tag = EnumFilterType.DialDiff,
            };

            foreach( var wData in wList ) {
                var wNode = new RldTriStateTreeNode(wData.DialDiffName) {
                    CheckboxVisible = true,
                    Tag = wData.DialDiffCode
                };
                wRet.Nodes.Add(wNode);
            }

            return wRet;
        }

        /// <summary>
        /// 患者イベントフィルタ用 TreeNode を作成して取得します。
        /// </summary>
        /// <returns></returns>
        private async Task<TreeNode> CreatePatEventTreeNode()
        {
            var wList = new List<FilterPatEventData>();

            // 患者イベントフィルタを取得
            if( (await RldLib.FilterDataSet.GetFilterPatEventData() is RldRestResultData<List<FilterPatEventData>> wResult) && wResult.IsSuccess )
                wList = wResult.Data;

            // ルートノードを生成
            var wRet = new RldTriStateTreeNode() {
                CheckboxVisible = true,
                IsContainer = true,
                Text = "患者イベント",
                // mod #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする 高 start
                //Tag = EnumFilterType.PatEvent,
                Tag = EnumFilterType.Category,
                // mod #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする 高 end
            };

            Int64 wCategoryCode = Int64.MinValue;

            RldTriStateTreeNode wNodeCategory = null, wNodeSubCategory = null;

            foreach( var wData in wList ) {

                // カテゴリが変わったらルートノードへ追加
                if( wCategoryCode != wData.CategoryCode ) {

                    if( wNodeCategory != null ) {
                        // サブカテゴリをカテゴリノードへ追加
                        if( wNodeSubCategory != null ) wNodeCategory.Nodes.Add(wNodeSubCategory);
                        // ルートノードへ追加
                        wRet.Nodes.Add(wNodeCategory);
                    }

                    // カテゴリノードを生成
                    wNodeCategory= new RldTriStateTreeNode() {
                        CheckboxVisible = true,
                        IsContainer =true,
                        Tag = wData.CategoryCode,
                        Text = wData.CategoryName
                    };

                    // カテゴリを記憶
                    wCategoryCode = wData.CategoryCode;
                    // サブカテゴリをクリア
                    wNodeSubCategory = null;
                }

                // サブカテゴリはカテゴリノードへ追加
                if( wData.SubCategoryCode != 0 ) {
                    wNodeCategory.Nodes.Add(new RldTriStateTreeNode() {
                        CheckboxVisible = true,
                        Tag = wData.SubCategoryCode,
                        Text = wData.SubCategoryName
                    });
                }
            }

            // 最後のカテゴリをルートノードへ追加
            if( wNodeCategory != null ) {
                if( wNodeSubCategory != null ) wNodeCategory.Nodes.Add(wNodeSubCategory);
                wRet.Nodes.Add(wNodeCategory);
            }

            return wRet;
        }

        /// <summary>
        /// 加算フィルタ用 TreeNode を作成して取得します。
        /// </summary>
        /// <returns></returns>
        private async Task<TreeNode> CreateAdditionTreeNode()
        {
            var wList = new List<FilterAdditionData>();

            // 加算フィルタを取得
            if( (await RldLib.FilterDataSet.GetFilterAdditionData() is RldRestResultData<List<FilterAdditionData>> wResult) && wResult.IsSuccess )
                wList = wResult.Data;

            // ルートノードを生成
            var wRet = new RldTriStateTreeNode() {
                CheckboxVisible = true,
                IsContainer = true,
                Text = "加算",
                Tag = EnumFilterType.Addition,
            };

            foreach( var wData in wList ) {
                var wNode = new RldTriStateTreeNode(wData.AdditionName) {
                    CheckboxVisible = true,
                    Tag = wData.AdditionCode
                };
                wRet.Nodes.Add(wNode);
            }

            return wRet;
        }
        //add #8489 zhu start
        /// <summary>
        /// ダイアライザフィルタ用 TreeNode を作成して取得します。
        /// </summary>
        /// <returns></returns>
        private async Task<TreeNode> CreateDistributionTreeNode()
        {
            var wList = new List<FilterDistributionData>();

            // 加算フィルタを取得
            if ((await RldLib.FilterDataSet.GetFilterDistributionData() is RldRestResultData<List<FilterDistributionData>> wResult) && wResult.IsSuccess)
                wList = wResult.Data;

            // ルートノードを生成
            var wRet = new RldTriStateTreeNode()
            {
                CheckboxVisible = true,
                IsContainer = true,
                Text = "ダイアライザ",
                Tag = -10,
            };

            foreach (var wData in wList)
            {
                var wNode = new RldTriStateTreeNode(wData.modelNumber)
                {
                    CheckboxVisible = true,
                    Tag = wData.dialyzerCd,
                    Text= wData.modelNumber
                };
                wRet.Nodes.Add(wNode);
            }

            return wRet;
        }
       
        /// <summary>
        /// 配布リスト(ベッド) TreeNode を作成して取得します。
        /// </summary>
        /// <returns></returns>
        private async Task<TreeNode> CreateDistributionsTreeNode()
        {
            TreeNode wNodeDistribution = await this.CreateDistributionTreeNode();
            TreeNode wNode =  await this.CreateEquipmentTreeNode();
           
            wNode.Nodes.Add(wNodeDistribution);
            return wNode;
        }
        //add #8489 zhu start

        // add #11494 データセットにカテゴリ「レセプト」を追加 limingzhe start
        /// <summary>
        /// レセプトフィルタ用 TreeNode を作成して取得します。
        /// </summary>
        /// <returns></returns>
        private async Task<TreeNode> CreateReceiptTreeNode()
        {
            var wList = new List<FilterReceiptData>();

            // レセプトフィルタ一覧を取得
            if ((await RldLib.FilterDataSet.GetFilterReceiptData() is RldRestResultData<List<FilterReceiptData>> wResult) && wResult.IsSuccess)
                wList = wResult.Data;

            // ルートノード生成
            var wRet = new RldTriStateTreeNode()
            {
                CheckboxVisible = true,
                IsContainer = true,
                Text = "レセプト",
                Tag = EnumFilterType.Receipt
            };

            Int64 wClassType = Int64.MinValue, wKindType = 0;

            RldTriStateTreeNode wNode1 = null, wNode2 = null;

            foreach (var wData in wList)
            {
                // データ種別が変わったらルートノードへ追加
                if (wClassType != wData.ClassCode)
                {
                    if (wNode1 != null)
                    {
                        if (wNode2 != null) wNode1.Nodes.Add(wNode2);
                        wRet.Nodes.Add(wNode1);
                    }

                    wNode1 = new RldTriStateTreeNode()
                    {
                        CheckboxVisible = true,
                        IsContainer = true,
                        Tag = wData.ClassCode,
                        Text = wData.ClassName
                    };

                    wClassType = wData.ClassCode;
                    wKindType = 0;
                    wNode2 = null;
                }
                // データ分類が変わったらルートノードへ追加
                if (wKindType != wData.KindCode)
                {
                    if (wNode2 != null) wNode1.Nodes.Add(wNode2);
                    wNode2 = new RldTriStateTreeNode()
                    {
                        CheckboxVisible = true,
                        IsContainer = true,
                        Tag = wData.KindCode,
                        Text = wData.KindName
                    };

                    wKindType = wData.KindCode;
                }
                // 項目は項目分類ノードへ追加
                if (wData.ReceiptCode != 0)
                {
                    wNode2.Nodes.Add(new RldTriStateTreeNode()
                    {
                        CheckboxVisible = true,
                        Tag = wData.ReceiptCode,
                        Text = wData.ReceiptName
                    });
                }
            }

            // 最後の項目分類をルートノードへ追加
            if (wNode1 != null)
            {
                if (wNode2 != null) wNode1.Nodes.Add(wNode2);
                wRet.Nodes.Add(wNode1);
            }

            return wRet;
        }
        // add #11494 データセットにカテゴリ「レセプト」を追加 limingzhe end

        // add #11625 クラス「指示履歴」の仕様変更② 高 start
        /// <summary>
        /// 指示履歴フィルタ用 TreeNode を作成して取得します。
        /// </summary>
        /// <returns></returns>
        private async Task<TreeNode> CreateLogTargetTreeNode()
        {
            // ルートノード生成
            var wRet = new RldTriStateTreeNode()
            {
                CheckboxVisible = true,
                IsContainer = true,
                Text = "指示履歴",
                Tag = EnumFilterType.logTarget
            };

            Int64 cnt = 0;
            RldTriStateTreeNode wNode1 = null;
            foreach (var wData in logTargetData)
            {
                wNode1 = new RldTriStateTreeNode()
                {
                    CheckboxVisible = true,
                    IsContainer = true,
                    Tag = cnt,
                    Text = wData
                };
                wRet.Nodes.Add(wNode1);
                cnt++;
            }

            return wRet;
        }
        // add #11625 クラス「指示履歴」の仕様変更② 高 end

        // add #12006 感染症がフィルタできない 高 start
        /// <summary>
        /// 感染症フィルタ用 TreeNode を作成して取得します。
        /// </summary>
        /// <returns></returns>
        private async Task<TreeNode> CreateInfectionTreeNode()
        {
            var wList = new List<FilterAdditionData>();

            // 透析困難フィルタを取得
            if ((await RldLib.FilterDataSet.GetFilterInfectionData() is RldRestResultData<List<FilterAdditionData>> wResult) && wResult.IsSuccess)
                wList = wResult.Data;

            // ルートノードを生成
            var wRet = new RldTriStateTreeNode()
            {
                CheckboxVisible = true,
                IsContainer = true,
                Text = "感染症",
                Tag = EnumFilterType.Infection,
            };

            foreach (var wData in wList)
            {
                var wNode = new RldTriStateTreeNode(wData.AdditionName)
                {
                    CheckboxVisible = true,
                    Tag = wData.AdditionCode
                };
                wRet.Nodes.Add(wNode);
            }

            return wRet;
        }
        // add #12006 感染症がフィルタできない 高 end

        // add #12756 クラス「##準備リスト.物品情報」のフィルタ設定が不十分 高 start
        /// <summary>
        /// 物品情報フィルタ用 TreeNode を作成して取得します。
        /// </summary>
        /// <returns></returns>
        private async Task<TreeNode> CreateGoodsTreeNode()
        {
            // ルートノードを生成
            var wRet = new RldTriStateTreeNode()
            {
                CheckboxVisible = true,
                IsContainer = true,
                Text = "物品",
                Tag = EnumFilterType.Goods,
            };

            TreeNode wNode = await this.CreateEquipDiaTreeNode();
            TreeNode wNode2 = await this.CreateMedicineNoTreeNode();

            if (wNode != null && wNode.Nodes.Count != 0)
            {
                wNode.Tag = 1;
                wRet.Nodes.Add(wNode);
            }

            if (wNode2 != null && wNode2.Nodes.Count != 0)
            {
                wNode2.Tag = 2;
                wRet.Nodes.Add(wNode2);
            }

            return wRet;
        }
        // add #12756 クラス「##準備リスト.物品情報」のフィルタ設定が不十分 高 end

        // add #10370 装置帳票向けの「水質管理」データ項目を検討する 高 start
        /// <summary>
        /// 水質検査種別フィルタ用 TreeNode を作成して取得します。
        /// </summary>
        /// <returns></returns>
        // mod #12585 水質管理.水質検査のフィルタ処理仕様修正 高 start
        private async Task<TreeNode> CreateWQTestTypeTreeNode()
        {
            var wList = new List<FilterAdditionData>();

            // 水質検査フィルタを取得
            if ((await RldLib.FilterDataSet.GetFilterWQTestTypeData() is RldRestResultData<List<FilterAdditionData>> wResult) && wResult.IsSuccess)
                wList = wResult.Data;

            // ルートノードを生成
            var wRet = new RldTriStateTreeNode()
            {
                CheckboxVisible = true,
                IsContainer = true,
                Text = "検査種別",
                Tag = EnumFilterType.WQTestType,
            };

            foreach (var wData in wList)
            {
                var wNode = new RldTriStateTreeNode(wData.AdditionName)
                {
                    CheckboxVisible = true,
                    Tag = wData.AdditionCode
                };
                wRet.Nodes.Add(wNode);
            }

            return wRet;
        }
        // mod #12585 水質管理.水質検査のフィルタ処理仕様修正 高 end
        // add #10370 装置帳票向けの「水質管理」データ項目を検討する 高 end

        // add #11789 【因島】準備リストを医材と薬剤と分けて出力することができない limingzhe start
        /// <summary>
        /// 器材フィルタ用 TreeNode を作成して取得します。
        /// </summary>
        /// <returns></returns>
        private async Task<TreeNode> CreateEquipDiaTreeNode()
        {
            TreeNode wNodeDistribution = await this.CreateDistributionTreeNode();
            TreeNode wNode = await this.CreateEquipmentTreeNode();
            wNode.Text = "器材";
            wNode.Tag = EnumFilterType.EquipDia;
            wNode.Nodes.Add(wNodeDistribution);
            return wNode;
        }
        // add #11789 【因島】準備リストを医材と薬剤と分けて出力することができない limingzhe end
        #endregion

        #region コントロールイベントハンドラ定義

        /// <summary>
        /// OKボタンの Click イベント
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

        // add #12416 帳票移植時にフィルタ設定が無効化する（横展開） 高 start
        private class TreeNodeCreationContext
        {
            public string wTitle { get; set; }
            public TreeNode wNode { get; set; }
            public TreeNode wNode2 { get; set; }
        }
        private async Task<TreeNodeCreationContext> CreateTreeNode(TreeNodeCreationContext context)
        {
            switch (this.FilterType)
            {
                case EnumFilterType.ObsKind:    // 観察記録種別
                    context.wTitle = @"観察記録種別フィルタ設定";
                    context.wNode = await this.CreateObsKindTreeNode();
                    break;

                case EnumFilterType.Medicine:   // 薬剤フィルタ
                    context.wTitle = @"薬剤フィルタ設定";
                    context.wNode = await this.CreateMedicineTreeNode();
                    break;

                case EnumFilterType.Equipment:  // 医材フィルタ
                    context.wTitle = @"医療材料フィルタ設定";
                    context.wNode = await this.CreateEquipmentTreeNode();
                    break;

                case EnumFilterType.DialDiff:   // 透析困難
                    context.wTitle = @"透析困難フィルタ設定";
                    context.wNode = await this.CreateDialDiffTreeNode();
                    break;

                case EnumFilterType.PatEvent:   // 患者イベント
                    context.wTitle = @"イベントフィルタ設定";
                    context.wNode = await this.CreatePatEventTreeNode();
                    break;

                case EnumFilterType.Addition:   // 加算
                    context.wTitle = @"加算フィルタ設定";
                    context.wNode = await this.CreateAdditionTreeNode();
                    break;
                //add #8489 zhu start
                case EnumFilterType.Distribution:
                    context.wTitle = @"配布リスト(ベッド)設定";
                    context.wNode = await this.CreateMedicineTreeNode();
                    context.wNode2 = await this.CreateDistributionsTreeNode();
                    break;
                //add #8489 zhu end
                // add #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする 高 start
                case EnumFilterType.Category:   // 患者イベント
                    context.wTitle = @"患者イベントフィルタ設定";
                    context.wNode = await this.CreatePatEventTreeNode();
                    break;
                // add #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする 高 end
                // add #11494 データセットにカテゴリ「レセプト」を追加 limingzhe start
                case EnumFilterType.Receipt:   // レセプトフィルタ
                    context.wTitle = @"レセプトフィルタ設定";
                    context.wNode = await this.CreateReceiptTreeNode();
                    break;
                // add #11494 データセットにカテゴリ「レセプト」を追加 limingzhe end
                // add #11625 クラス「指示履歴」の仕様変更② 高 start
                case EnumFilterType.logTarget:   // 指示履歴フィルタ
                    context.wTitle = @"指示履歴フィルタ設定";
                    context.wNode = await this.CreateLogTargetTreeNode();
                    break;
                // add #11625 クラス「指示履歴」の仕様変更② 高 end
                // add #12006 感染症がフィルタできない 高 start
                case EnumFilterType.Infection:   // 感染症フィルタ
                    context.wTitle = @"感染症フィルタ設定";
                    context.wNode = await this.CreateInfectionTreeNode();
                    break;
                // add #12006 感染症がフィルタできない 高 end
                // add #12756 クラス「##準備リスト.物品情報」のフィルタ設定が不十分 高 start
                case EnumFilterType.Goods:      // 物品情報フィルタ
                    context.wTitle = @"物品情報フィルタ設定";
                    context.wNode = await this.CreateGoodsTreeNode();
                    break;
                // add #12756 クラス「##準備リスト.物品情報」のフィルタ設定が不十分 高 end
                // add #10370 装置帳票向けの「水質管理」データ項目を検討する 高 start
                // mod #12585 水質管理.水質検査のフィルタ処理仕様修正 高 start
                case EnumFilterType.WQTestType:   // 水質検査フィルタ
                    context.wTitle = @"水質検査種別フィルタ設定";
                    context.wNode = await this.CreateWQTestTypeTreeNode();
                    break;
                // mod #12585 水質管理.水質検査のフィルタ処理仕様修正 高 end
                // add #10370 装置帳票向けの「水質管理」データ項目を検討する 高 end
                // add #11789 【因島】準備リストを医材と薬剤と分けて出力することができない limingzhe start
                case EnumFilterType.EquipDia:   // 器材フィルタ
                    context.wTitle = @"器材フィルタ設定";
                    context.wNode = await this.CreateEquipDiaTreeNode();
                    break;
                // add #11789 【因島】準備リストを医材と薬剤と分けて出力することができない limingzhe end
                default:
                    break;
            }

            return context;
        }

        // set code when name is same
        public async void setItemCodeName()
        {
            TreeNode wNode = null;
            TreeNode wNode2 = null;
            bool bExist = false;
            bool bNotNameFlag = false;
            bool bErrTotalFlag = false;
            bool bCovertFlag = false;

            TreeNodeCreationContext wContext = new TreeNodeCreationContext();
            wContext.wNode = null;
            wContext.wNode2 = null;

            // get tree node from DB
            wContext = await this.CreateTreeNode(wContext);
            wNode = wContext.wNode;
            wNode2 = wContext.wNode2;

            // read FilterData of ExamItem from DB
            if (wNode == null || wNode.Nodes.Count == 0)
            {
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

            // get root node
            var wChildNode = wXmlDoc.SelectNodes(String.Format("{0}/{1}", RldConst.FilterData.TAG_ROOT, RldConst.FilterData.TAG_ITEM));
            foreach (System.Xml.XmlNode wXmlChild in wChildNode)
            {
                String wChildTagText = wXmlChild.Attributes[RldConst.FilterData.ATT_ITEM_TAG].InnerText;

                if (Convert.ToString(wNode.Tag) == wChildTagText)
                {
                    LFunc_DataReadRecursive(wXmlChild, (RldTriStateTreeNode) wNode);
                }
                else if(wNode2 != null)     // node2 is not null
                {
                    if (Convert.ToString(wNode2.Tag) == wChildTagText)
                    {
                        LFunc_DataReadRecursive(wXmlChild, (RldTriStateTreeNode)wNode2);
                    }
                }
            }

            // modify FilterData
            if (bExist == true)
            {
                this.FilterData = wXmlDoc.OuterXml;
            }

            /// <summary>
            /// (ローカル関数) 子ノードの選択状態を再帰的に復元します。
            /// </summary>
            /// <param name="aXmlNode"></param>
            /// <param name="aTreeNode"></param>
            void LFunc_DataReadRecursive(System.Xml.XmlNode aXmlNode, RldTriStateTreeNode aTreeNode)
            {
                if (aXmlNode == null || aTreeNode == null) return;
                String wTagText = aXmlNode.Attributes[RldConst.FilterData.ATT_ITEM_TAG].InnerText;
                String wCheckStateText = aXmlNode.Attributes[RldConst.FilterData.ATT_ITEM_CHECKSTATE].InnerText;
                RldTriStateTreeNode wTreeNodeRecursive = null;

                CheckState wCheckState = (CheckState)Enum.Parse(typeof(CheckState), wCheckStateText, false);
                if (wCheckState == CheckState.Indeterminate)
                {
                    var wChildNodeRecursive = aXmlNode.SelectNodes(RldConst.FilterData.TAG_ITEM);

                    foreach (System.Xml.XmlNode xmlChild in wChildNodeRecursive)
                    {
                        if (clsFilterData)
                            break;

                        // get code
                        String wChildTagText = xmlChild.Attributes[RldConst.FilterData.ATT_ITEM_TAG].InnerText;

                        // get name from item
                        var wNameAttr = xmlChild.Attributes[RldConst.FilterData.ATT_ITEM_NAME];
                        if (wNameAttr == null)
                        {
                            if (bNotNameFlag == false)
                            {
                                bNotNameFlag = true;
                                this.cntNotName++;
                            }

                            // find code
                            wTreeNodeRecursive = FindFirstByTag(aTreeNode, wChildTagText);
                            if(wTreeNodeRecursive == null)
                            {
                                if (bErrTotalFlag == false)
                                {
                                    bErrTotalFlag = true;
                                    cntErrTotal++;
                                }
                                break;
                            }
                        }
                        else
                        {
                            string wName = wNameAttr.Value;

                            // find name and code
                            wTreeNodeRecursive = FindFirstByTextAndTag(aTreeNode, wName, wChildTagText);
                            if (wTreeNodeRecursive == null)
                            {
                                if (bErrTotalFlag == false)
                                {
                                    bErrTotalFlag = true;
                                    cntErrTotal++;
                                }

                                // find name, if have many, get node of max code
                                wTreeNodeRecursive = FindFirstByTextAndMaxTag(aTreeNode, wName);
                                if (wTreeNodeRecursive != null)
                                {
                                    // set code with new code
                                    xmlChild.Attributes[RldConst.FilterData.ATT_ITEM_TAG].InnerText = wTreeNodeRecursive.Tag?.ToString();
                                    bExist = true;
                                    if (bCovertFlag == false)
                                    {
                                        bCovertFlag = true;
                                        cntCovert++;
                                    }
                                }
                                else
                                {
                                    clsFilterData = true;
                                    if (bCovertFlag)
                                        cntCovert--;
                                    break;
                                }
                            }
                        }
                        LFunc_DataReadRecursive(xmlChild, wTreeNodeRecursive);
                    }
                }
            }
        }

        // find same code form nodes
        // parent: parent node
        // tagValue: code
        // return : null or first node of max code
        public RldTriStateTreeNode FindFirstByTag(
        RldTriStateTreeNode parent,
        string tagValue)
        {
            if (parent == null || parent.Nodes.Count == 0 || string.IsNullOrEmpty(tagValue))
                return null;

            return parent.Nodes
                .Cast<RldTriStateTreeNode>()
                .Where(child => child != null &&
                               (child.Tag?.ToString() == tagValue))
                .OrderByDescending(child => child.Tag)
                .FirstOrDefault();
        }

        // find same name form nodes
        // parent: parent node
        // searchText: name
        // return : null or first node of max code
        public RldTriStateTreeNode FindFirstByTextAndMaxTag(
            RldTriStateTreeNode parent,
            string searchText)
        {
            if (parent == null || parent.Nodes.Count == 0 || string.IsNullOrEmpty(searchText))
                return null;

            return parent.Nodes
                .Cast<RldTriStateTreeNode>()
                .Where(child => child != null && child.Text == searchText)
                .OrderByDescending(child => child.Tag)
                .FirstOrDefault();
        }

        // find same name and code form nodes
        // parent: parent node
        // searchText: name
        // tagValue: code
        // return : null or first node of max code
        public RldTriStateTreeNode FindFirstByTextAndTag(
            RldTriStateTreeNode parent,
            string searchText,
            string tagValue)
        {
            if (parent == null || parent.Nodes.Count == 0 || string.IsNullOrEmpty(searchText))
                return null;

            var comparer = new TagComparer();

            return parent.Nodes
                .Cast<RldTriStateTreeNode>()
                .Where(child => child != null &&
                               child.Text == searchText &&
                               StringEquals(child.Tag, tagValue))
                .OrderByDescending(child => child.Tag, comparer)
                .FirstOrDefault();
        }

        // string compare
        private bool StringEquals(object tag1, string tag2)
        {
            if (tag1 == null && tag2 == null)
                return true;
            if (tag1 == null || tag2 == null)
                return false;
            return tag1.ToString().Equals(tag2);
        }

        // code compare
        private class TagComparer : IComparer<object>
        {
            public int Compare(object x, object y)
            {
                if (x == null && y == null) return 0;
                if (x == null) return -1;  // is null
                if (y == null) return 1;   // not null

                if (x is IComparable comparableX && y is IComparable comparableY)
                    return comparableX.CompareTo(comparableY);

                return 0;
            }
        }
        // add #12416 帳票移植時にフィルタ設定が無効化する（横展開） 高 end

        #endregion

    }
}
