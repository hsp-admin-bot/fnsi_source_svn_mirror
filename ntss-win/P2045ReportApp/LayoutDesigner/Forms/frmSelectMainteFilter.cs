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
    public partial class frmSelectMainteFilter : LayoutDesignerUtilityLib.Controls.frmRldSizableBase
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
            /// 点検
            /// </summary>
            Inspection
        }

        #endregion

        #region 生成と破棄

        public frmSelectMainteFilter()
        {
            InitializeComponent();

            // アイコンの設定
            this.Icon = Properties.Resources.LayoutDesigner;

            // イベントハンドラ割り当て
            this.btnOK.Click += new EventHandler(this.btnOK_Click);
            this.txtFree.TextChanged += new System.EventHandler(this.txtFree_TextChanged);
            this.rldTriStateTreeView.DoubleClick += new System.EventHandler(this.treeView_DoubleClick);
        }

        #endregion

        #region メンバプロパティ定義

        /// <summary>
        /// フィルター種別の取得及び設定を行います。
        /// </summary>
        internal EnumFilterType FilterType { get; set; } = frmSelectMainteFilter.EnumFilterType.None;

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
        /// 一部のアイテムのみを選択したかどうかの取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        //internal Boolean IsSelectPart { get; private set; } = false;

        internal String CellAddress { get; set; } = string.Empty;
        internal int cntErrTotal { get; set; } = 0;
        internal int cntCovert { get; set; } = 0;
        internal int cntTotal { get; set; } = 0;
        internal int cntNotName { get; set; } = 0;
        internal bool clsFilterData { get; set; } = false;

        internal bool IsInspection { get; set; } = false;

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
            
            // フィルタが未設定の場合は全選択状態に設定する
            if (String.IsNullOrEmpty(this.FilterData))
            {
                return;
            }

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
            String wTitle = String.Empty;
            TreeNode wNode = null;
            TreeNode wNode2 = null;
           
            TreeNodeCreationContext wContext = new TreeNodeCreationContext();
            wContext.wNode = null;
            wContext.wNode2 = null;
            wContext.wTitle = string.Empty;

            wContext = await this.CreateTreeNode(wContext);
            wNode = wContext.wNode;
            wTitle = wContext.wTitle;
            wNode2 = wContext.wNode2;

            // 表示するデータがない場合はぬける
            if ( wNode == null ) return false;

            this.winlblTitle.Text = wTitle;
            this.chkDevelopment.Visible = true;

            try {
                this.rldTriStateTreeView.SuspendLayout();

                // 表示データをセット
                this.rldTriStateTreeView.Nodes.Add(wNode);
                if (wNode2 != null)
                {
                    this.rldTriStateTreeView.Nodes.Add(wNode2);
                }                
                // ルートノードを展開しておく
                this.rldTriStateTreeView.Nodes[0].Expand();
            }
            finally {
                this.rldTriStateTreeView.ResumeLayout();
                this.rldTriStateTreeView.RefreshScrollRange();
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
            bool isNodeSelected = false;

            foreach (TreeNode tn in rldTriStateTreeView.Nodes)
            {
                if (CheckNodeAndChildren(tn))
                {
                    isNodeSelected = true;
                    break;
                }
            }

            if (!isNodeSelected)
            {
                RldMsgBox.Show(this, "項目を選択してください。", "確認してください", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                this.rldTriStateTreeView.Focus();
                return false;
            }

            return true;
        }

        /// <summary>
        /// 内容を確認します。
        /// </summary>
        /// <returns></returns>
        private bool CheckNodeAndChildren(TreeNode node)
        {
            if (node.Nodes.Count == 0)
            {
                if (node.Text == "点検")
                    return false;

                return node.IsSelected;
            }

            foreach (TreeNode childNode in node.Nodes)
            {
                if (CheckNodeAndChildren(childNode))
                {
                    return true;
                }
            }

            return false;
        }

        /// <summary>
        /// 画面にデータを読み込みます。
        /// </summary>
        private void DataRead()
        {
            // 設定中のフィルタデータを読み込む(失敗時は抜ける)
            var wXmlDoc = new System.Xml.XmlDocument();

            try
            {
                if (RldDataGridViewParamDataEditHelper.middleData.ContainsKey(this.Path))
                {
                    wXmlDoc.LoadXml(RldDataGridViewParamDataEditHelper.middleData[this.Path]);
                }
                else
                {
                    wXmlDoc.LoadXml(this.FilterData);
                }
            }
            catch
            {
                return;
            }

            var wChildNode = wXmlDoc.SelectNodes(String.Format("{0}/{1}", RldConst.FilterData.TAG_ROOT, RldConst.FilterData.TAG_ITEM));
            foreach (System.Xml.XmlNode wXmlChild in wChildNode)
            {
                String wChildTagText = wXmlChild.Attributes[RldConst.FilterData.ATT_ITEM_TAG].InnerText;

                foreach (RldTriStateTreeNode wTreeNode in this.rldTriStateTreeView.Nodes)
                {
                    if (Convert.ToString(wTreeNode.Tag) == wChildTagText)
                    {
                        // 再帰処理にてツリービューの選択状態を復元
                        TreeNode selectedNode = LFunc_DataReadRecursive(wXmlChild, wTreeNode);
                        if (selectedNode != null)
                        {
                            this.rldTriStateTreeView.SelectedNode = selectedNode;
                            this.rldTriStateTreeView.Select();
                            this.rldTriStateTreeView.Focus();
                        }
                        break;
                    }
                }
            }

            /// <summary>
            /// (ローカル関数) 子ノードの選択状態を再帰的に復元します。
            /// </summary>
            /// <param name="aXmlNode"></param>
            /// <param name="aTreeNode"></param>
            TreeNode LFunc_DataReadRecursive(System.Xml.XmlNode aXmlNode, RldTriStateTreeNode aTreeNode)
            {
                String wTagText = aXmlNode.Attributes[RldConst.FilterData.ATT_ITEM_TAG].InnerText;
                String wCheckStateText = aXmlNode.Attributes[RldConst.FilterData.ATT_ITEM_CHECKSTATE].InnerText;

                // CheckStateの値を解析
                CheckState wCheckState = (CheckState)Enum.Parse(typeof(CheckState), wCheckStateText, false);

                // Checkedの場合：最底层ノード（叶子节点）で、かつ選択状態にする
                if (wCheckState == CheckState.Checked)
                {
                    // 叶子节点の場合のみ選択状態にする
                    if (aTreeNode.Nodes.Count == 0)
                    {
                        // 選択するノードを返す（実際の選択は後で行う）
                        return aTreeNode;
                    }
                }
                // Indeterminateの場合：中间ノードで、子ノードを処理する
                else if (wCheckState == CheckState.Indeterminate)
                {
                    var wChildNodeRecursive = aXmlNode.SelectNodes(RldConst.FilterData.TAG_ITEM);

                    foreach (System.Xml.XmlNode xmlChild in wChildNodeRecursive)
                    {
                        String wChildTagText = xmlChild.Attributes[RldConst.FilterData.ATT_ITEM_TAG].InnerText;
                        foreach (RldTriStateTreeNode wTreeNodeRecursive in aTreeNode.Nodes)
                        {
                            if (Convert.ToString(wTreeNodeRecursive.Tag) == wChildTagText)
                            {
                                TreeNode result = LFunc_DataReadRecursive(xmlChild, wTreeNodeRecursive);
                                if (result != null)
                                {
                                    return result;
                                }
                                break;
                            }
                        }
                    }
                }
                // Uncheckedの場合は何もしない
                return null;
            }
        }


        private void DataSave()
        {
            // 全ノードを選択した状態にする
            //this.IsSelectPart = false;
            this.FilterData = String.Empty;
            bool bFirstNode = false;

            // ノードがない場合は抜ける
            if (this.rldTriStateTreeView.GetNodeCount(true) == 0) return;

            var wXmlDoc = new System.Xml.XmlDocument();

            // ルートノードを作成
            var wXmlRoot = wXmlDoc.CreateElement(RldConst.FilterData.TAG_ROOT);

            foreach (RldTriStateTreeNode wTreeNode in this.rldTriStateTreeView.Nodes)
            {
                // 子ノードを追加
                var wXmlElement = LFunc_DataSaveRecursive(wTreeNode);
                if (wXmlElement != null) // 選択されたノードがある場合のみ追加
                    wXmlRoot.AppendChild(wXmlElement);
            }

            // ドキュメントへ追加
            if (wXmlRoot.HasChildNodes) // 選択されたノードがある場合のみ保存
            {
                this.FilterData = (wXmlDoc.AppendChild(wXmlRoot)).OuterXml;
            }

            /// <summary>
            /// (ローカル関数) 子ノードを再帰的に保存します（選択された最底层ノードを含む階層を保持）。
            /// </summary>
            /// <param name="aTreeNode"></param>
            System.Xml.XmlElement LFunc_DataSaveRecursive(RldTriStateTreeNode aTreeNode)
            {
                bool hasSelectedChild = false;

                // まず、子ノードの中で選択されたものがあるか確認
                foreach (RldTriStateTreeNode wChildNode in aTreeNode.Nodes)
                {
                    var wChildElement = LFunc_DataSaveRecursive(wChildNode);
                    if (wChildElement != null)
                    {
                        if (!hasSelectedChild)
                        {
                            hasSelectedChild = true;
                        }
                    }
                }

                // 現在のノードが最底层ノード（叶子节点）で選択されている場合、または子ノードに選択されたノードがある場合
                if ((aTreeNode.Nodes.Count == 0 && aTreeNode.IsSelected) || hasSelectedChild)
                {
                    var wRet = wXmlDoc.CreateElement(RldConst.FilterData.TAG_ITEM);
                    wRet.SetAttribute(RldConst.FilterData.ATT_ITEM_TAG, Convert.ToString(aTreeNode.Tag));

                    if (bFirstNode)
                        wRet.SetAttribute(RldConst.FilterData.ATT_ITEM_NAME, Convert.ToString(aTreeNode.Text));
                    else
                        bFirstNode = true;

                    // チェック状態を設定
                    // 最底层ノードで選択されている場合は "Checked"
                    // 中間ノードで子ノードに選択されたノードがある場合は "Indeterminate"
                    if (aTreeNode.Nodes.Count == 0 && aTreeNode.IsSelected)
                    {
                        wRet.SetAttribute(RldConst.FilterData.ATT_ITEM_CHECKSTATE, "Checked");
                    }
                    else if (hasSelectedChild)
                    {
                        wRet.SetAttribute(RldConst.FilterData.ATT_ITEM_CHECKSTATE, "Indeterminate");
                    }
                    else
                    {
                        // このケースは通常発生しないが、念のため
                        wRet.SetAttribute(RldConst.FilterData.ATT_ITEM_CHECKSTATE, "Unchecked");
                    }

                    // 子ノードを追加
                    if (hasSelectedChild)
                    {
                        foreach (RldTriStateTreeNode wChildNode in aTreeNode.Nodes)
                        {
                            var wXmlChildElement = LFunc_DataSaveRecursive(wChildNode);
                            if (wXmlChildElement != null)
                            {
                                wRet.AppendChild(wXmlChildElement);
                            }
                        }
                    }

                    return wRet;
                }

                return null;
            }
        }

        #endregion

        #region メンバ関数定義(TreeView Node)

        /// <summary>
        /// 点検フィルタ用 TreeNode を作成して取得します。
        /// </summary>
        /// <returns></returns>
        private async Task<TreeNode> CreateInspectionTreeNode()
        {
            var wList = new List<FilterInspectionData>();

            if ("Device".Equals(RldLib.CurrentLayoutData.DesignSettingData.ReportClass))
            {
                // 点検フィルタを取得
                if ((await RldLib.FilterDataSet.GetFilterInspectionData() is RldRestResultData<List<FilterInspectionData>> wResult) && wResult.IsSuccess)
                    wList = wResult.Data;
            }
           
            // ルートノードを生成
            var wRet = new RldTriStateTreeNode() {
                CheckboxVisible = false,
                IsContainer = true,
                Text = "点検",
                Tag = EnumFilterType.Inspection,
            };

            Int64 wCategoryCode = Int64.MinValue;

            RldTriStateTreeNode wNode = null, wSubNode = null;

            foreach( var wData in wList ) {

                // 点検グループが変わったらルートノードへ追加
                if ( wCategoryCode != wData.CategoryCode ) {

                    if(wNode != null ) {
                        // 点検を点検グループノードへ追加
                        if (wSubNode != null ) wNode.Nodes.Add(wSubNode);
                        // ルートノードへ追加
                        wRet.Nodes.Add(wNode);
                    }

                    // 点検グループノードを生成
                    wNode = new RldTriStateTreeNode() {
                        CheckboxVisible = false,
                        IsContainer = true,
                        Tag = wData.CategoryCode,
                        Text = wData.CategoryName
                    };

                    // 点検グループを記憶
                    wCategoryCode = wData.CategoryCode;
                    // 点検をクリア
                    wSubNode = null;
                }

                // 点検は点検グループノードへ追加
                if ( wData.InspectionCode != 0 ) {
                    wNode.Nodes.Add(new RldTriStateTreeNode() {
                        CheckboxVisible = false,
                        Tag = wData.InspectionCode,
                        Text = "内容1：" + wData.InspectionName + "。　内容2：" + wData.InspectionName2
                    });
                }
            }

            // 最後の点検グループをルートノードへ追加
            if (wNode != null ) {
                if(wSubNode != null ) wNode.Nodes.Add(wSubNode);
                wRet.Nodes.Add(wNode);
            }

            return wRet;
        }

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
            this.IsApplySameGroup = this.chkDevelopment.Checked;
            this.Close();
        }

        /// <summary>
        /// 一覧表示の DoubleClick イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void treeView_DoubleClick(object sender, EventArgs e)
        {
            this.btnOK.PerformClick();
        }

        /// <summary>
        /// フリーワードの TextChanged イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private async void txtFree_TextChanged(object sender, EventArgs e)
        {
            await this.ShowOnlineExamList();
        }

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
                case EnumFilterType.Inspection:    // 点検
                    context.wTitle = @"点検項目フィルタ設定";
                    context.wNode = await this.CreateInspectionTreeNode();
                    break;

                default:
                    break;
            }

            return context;
        }


        private async Task<Boolean> ShowOnlineExamList()
        {
            Boolean wRet = false;
            TreeNodeCreationContext wContext = new TreeNodeCreationContext();
            wContext.wNode = null;
            wContext.wNode2 = null;
            TreeNode wNode = null;
            TreeNode wNode2 = null;

            // get tree node from DB
            wContext = await this.CreateTreeNode(wContext);
            wNode = wContext.wNode;
            wNode2 = wContext.wNode2;

            if (wNode == null || wNode.Nodes.Count == 0)
            {
                if (this.FilterType == EnumFilterType.Inspection)
                {
                    RldMsgBox.Show(String.Format("点検詳細品目コードの取得データがありません。"), "データなし", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                }
                return false;
            }

            //this.rldTriStateTreeView.BeginUpdate();

            try
            {
                this.rldTriStateTreeView.SuspendLayout();

                // 画面をクリア
                this.DataClear(true);

                // フリーワードによるフィルタリングを適用
                if (!String.IsNullOrEmpty(this.txtFree.Text))
                {
                    // 日本語用の検索パラメータ指定用データを取得
                    var wCompareInfo = System.Globalization.CultureInfo.CurrentCulture.CompareInfo;

                    // 検索条件に一致するノードのみを含む新しいツリーを作成
                    bool hasLeafMatch = false;
                    bool hasLeafMatch2 = false;

                    TreeNode filteredNode = FilterTreeNodes(wNode, this.txtFree.Text, wCompareInfo, false, out hasLeafMatch);
                    TreeNode filteredNode2 = null;

                    if (wNode2 != null)
                    {
                        filteredNode2 = FilterTreeNodes(wNode2, this.txtFree.Text, wCompareInfo, false, out hasLeafMatch2);
                    }

                    // ツリービューにフィルタリングされたノードを追加
                    this.rldTriStateTreeView.Nodes.Clear();
                    if (filteredNode != null)
                    {
                        this.rldTriStateTreeView.Nodes.Add(filteredNode);
                    }
                    if (filteredNode2 != null)
                    {
                        this.rldTriStateTreeView.Nodes.Add(filteredNode2);
                    }

                    // 展開処理：条件に基づいて展開
                    if (this.rldTriStateTreeView.Nodes.Count > 0)
                    {
                        // 条件①：底层に一致するものがある場合 → 底层まで展開
                        // 条件②：底层に一致するものがない場合 → 上层のみ展開（第一層のみ）
                        bool anyLeafMatch = hasLeafMatch || (wNode2 != null && hasLeafMatch2);
                        ExpandTreeBasedOnMatch(this.rldTriStateTreeView.Nodes, anyLeafMatch);
                    }
                }
                else
                {
                    // 条件③：検索内容が空の場合 → 第一層のみ展開
                    this.rldTriStateTreeView.Nodes.Clear();
                    this.rldTriStateTreeView.Nodes.Add(wNode);
                    if (wNode2 != null)
                    {
                        this.rldTriStateTreeView.Nodes.Add(wNode2);
                    }

                    // 第一層のみ展開
                    ExpandFirstLevelOnly(this.rldTriStateTreeView.Nodes);
                }

                wRet = true;
            }
            finally
            {
                //this.rldTriStateTreeView.EndUpdate();
                this.rldTriStateTreeView.ResumeLayout();
                this.rldTriStateTreeView.RefreshScrollRange();
            }

            return wRet;
        }

        /// <summary>
        /// ツリーノードを再帰的に検索し、条件に一致するノードのみを含む新しいツリーを作成する
        /// </summary>
        /// <param name="node">処理するノード</param>
        /// <param name="searchText">検索文字列</param>
        /// <param name="compareInfo">比較情報</param>
        /// <param name="isParentMatched">親ノードが既に一致しているかどうか</param>
        /// <param name="hasLeafMatch">このパスに底层ノードの一致があるかどうか（outパラメータ）</param>
        /// <returns>フィルタリングされたノード（一致するものがない場合はnull）</returns>
        private TreeNode FilterTreeNodes(TreeNode node, string searchText, System.Globalization.CompareInfo compareInfo, bool isParentMatched, out bool hasLeafMatch)
        {
            // 現在のノードのテキストが検索条件に一致するか確認
            bool nodeMatches = compareInfo.IndexOf(
                node.Text,
                searchText,
                System.Globalization.CompareOptions.IgnoreCase | System.Globalization.CompareOptions.IgnoreWidth) >= 0;

            // 親ノードが既に一致している場合、または現在のノードが一致する場合
            bool shouldIncludeNode = isParentMatched || nodeMatches;

            // 子ノードを処理
            List<TreeNode> matchedChildren = new List<TreeNode>();
            bool anyChildHasLeafMatch = false;

            foreach (TreeNode childNode in node.Nodes)
            {
                bool childHasLeafMatch;
                TreeNode filteredChild = FilterTreeNodes(childNode, searchText, compareInfo, isParentMatched || nodeMatches, out childHasLeafMatch);
                if (filteredChild != null)
                {
                    matchedChildren.Add(filteredChild);
                    if (childHasLeafMatch)
                    {
                        anyChildHasLeafMatch = true;
                    }
                }
            }

            // 現在のノードが底层ノード（叶子节点）かどうか
            bool isLeafNode = (node.Nodes.Count == 0);

            // 底层ノードが一致する場合
            bool currentIsLeafMatch = isLeafNode && nodeMatches;

            // hasLeafMatchを設定（このノード以下のパスに底层ノードの一致があるか）
            hasLeafMatch = currentIsLeafMatch || anyChildHasLeafMatch;

            // ノードを含めるべき場合（親が一致、または自分が一致、または子が一致）
            if (shouldIncludeNode || matchedChildren.Count > 0)
            {
                // 新しいノードを作成（元のノードのプロパティをコピー）
                TreeNode newNode = CopyTreeNode(node);

                // 一致した子ノードを追加
                foreach (TreeNode matchedChild in matchedChildren)
                {
                    newNode.Nodes.Add(matchedChild);
                }

                return newNode;
            }

            return null;
        }

        /// <summary>
        /// 検索結果に基づいてツリーを展開する
        /// </summary>
        /// <param name="nodes">ノードコレクション</param>
        /// <param name="hasLeafMatch">底层ノードに一致があるかどうか</param>
        private void ExpandTreeBasedOnMatch(TreeNodeCollection nodes, bool hasLeafMatch)
        {
            foreach (TreeNode node in nodes)
            {
                if (hasLeafMatch)
                {
                    // 条件①：底层に一致がある場合 → すべて展開
                    ExpandAllNodes(node);
                }
                else
                {
                    // 条件②：底层に一致がない場合 → 第一層のみ展開
                    ExpandFirstLevelOnly(nodes);
                    break; // 第一層のみ処理したら終了
                }
            }
        }

        /// <summary>
        /// ノードとそのすべての子ノードを再帰的に展開する
        /// </summary>
        /// <param name="node">展開するノード</param>
        private void ExpandAllNodes(TreeNode node)
        {
            node.Expand();

            foreach (TreeNode childNode in node.Nodes)
            {
                ExpandAllNodes(childNode);
            }
        }

        /// <summary>
        /// ツリーノードの第一層のみを展開する
        /// </summary>
        /// <param name="nodes">ノードコレクション</param>
        private void ExpandFirstLevelOnly(TreeNodeCollection nodes)
        {
            foreach (TreeNode node in nodes)
            {
                // 第一層のノードを展開
                node.Expand();

                // 第二層以降は折りたたむ
                CollapseAllChildren(node.Nodes);
            }
        }

        /// <summary>
        /// すべての子ノードを再帰的に折りたたむ
        /// </summary>
        /// <param name="nodes">ノードコレクション</param>
        private void CollapseAllChildren(TreeNodeCollection nodes)
        {
            foreach (TreeNode node in nodes)
            {
                node.Collapse();

                if (node.Nodes.Count > 0)
                {
                    CollapseAllChildren(node.Nodes);
                }
            }
        }

        /// <summary>
        /// ツリーノードのコピーを作成する
        /// </summary>
        /// <param name="sourceNode">コピー元のノード</param>
        /// <returns>コピーされたノード</returns>
        private TreeNode CopyTreeNode(TreeNode sourceNode)
        {
            if (sourceNode is RldTriStateTreeNode rldNode)
            {
                RldTriStateTreeNode newRldNode = new RldTriStateTreeNode();
                newRldNode.Text = rldNode.Text;
                newRldNode.Tag = rldNode.Tag;
                newRldNode.CheckboxVisible = rldNode.CheckboxVisible;
                newRldNode.IsContainer = rldNode.IsContainer;
                newRldNode.Name = rldNode.Name;
                newRldNode.ToolTipText = rldNode.ToolTipText;

                return newRldNode;
            }
            else
            {
                TreeNode newNode = new TreeNode();
                newNode.Text = sourceNode.Text;
                newNode.Tag = sourceNode.Tag;
                newNode.Name = sourceNode.Name;
                newNode.ToolTipText = sourceNode.ToolTipText;

                return newNode;
            }
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
                if (this.IsInspection == false)
                {
                    this.IsInspection = true;
                    RldMsgBox.Show(String.Format("点検詳細品目コードの取得データがありません。"), "データなし", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                }

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

        #endregion

    }
}
