using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;
using System.Globalization;
using NKKLoggingLib;
using System.Reflection;

namespace Fnw.StatisticsTool.FrmDispCode
{
    /// <summary>
    /// 候補選択画面
    /// </summary>
    public partial class FrmDispCodeSelect : StatisticsBase
    {
        /// <summary>選択候補として表示するリスト</summary>
        internal List<DispCode> SelectList = null;
        /// <summary>選択したコード(DialogResult.OKの場合のみ有効)</summary>
        internal string SelectedCode { private set; get; }
        /// <summary>選択した候補名称(DialogResult.OKの場合のみ有効)</summary>
        internal string SelectedName { private set; get; }
        /// <summary>選択する項目の分類名称</summary>
        internal string Title { set { base.Text = value + "割当画面"; } }
        /// <summary>選択対象となっている項目の名称</summary>
        internal string TargetName { get { return this.lblTarget.Text; }  set { this.lblTarget.Text = value; } }
        /// <summary>初期設定するフリーワード格納文字列</summary>
        internal string DefaultFreeWord { get { return this.txtFreeWord.Text; } set { this.txtFreeWord.Text = value; } }

        /// <summary>
        /// 候補選択画面コンストラクタ
        /// </summary>
        public FrmDispCodeSelect() : base(isUserLoggedIn: true)
        {
            InitializeComponent();
            // 基底クラスのコンストラクタでイベント登録
            //RegisterEvents(this);
            // リストのバインドメンバー名を設定
            lstSelectList.DisplayMember = DispCode.KEY_DISP;
            lstSelectList.ValueMember = DispCode.KEY_CODE;
        }

        /// <summary>
        /// 子コントロールに対して再帰的にイベントを登録
        /// </summary>
        /// <param name="control"></param>
        private void RegisterEvents(Control control)
        {
            control.MouseEnter += OnUserActivity;
            control.MouseLeave += OnUserActivity;
            control.MouseMove += OnUserActivity;
            control.KeyDown += OnUserActivity;

            foreach (Control child in control.Controls)
            {
                RegisterEvents(child);
            }
        }

        /// <summary>
        /// フォームロード
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void FrmDispCodeSelect_Load(object sender, EventArgs e)
        {
            NKKLogging.GetInstance().AddLogInfo(DateTime.Now, StatisticsUtility.PRODUCT_NAME,
            GetType().Name, NKKLogging.LOGGING_CLASS.INFO, MethodBase.GetCurrentMethod().Name);
            // リスト表示処理
            //this.ShowList();
        }

        /// <summary>
        /// リスト表示処理
        /// </summary>
        public void ShowList()
        {
            if (null == this.SelectList)
            {
                // 選択候補リストが無い
                return;
            }

            // 出力用の一時リスト作成
            List<DispCode> work;

            if (string.IsNullOrEmpty(txtFreeWord.Text))
            {
                // 絞込みが無い場合は全件をコピーしてリスト作成
                work = new List<DispCode>(this.SelectList);
            }
            else
            {
                // 大文字/小文字・全角/半角・ひらがな/カタカナを無視して絞込みを実施
                //CompareInfo ci = CultureInfo.CurrentCulture.CompareInfo;
                work = this.SelectList.FindAll(ele => 0 <= StaticFunctions.AboutIndexOf(ele.Name, txtFreeWord.Text));
            }

            // 常に先頭に未割当を表示
            work.Insert(0, new DispCode(string.Empty, "未割当"));

            // ２番目が「未該当」でない場合は、必ず「未該当」が表示されるようにする
            if (work.Count < 2 || !work[1].Name.Equals("未該当"))
            {
                switch (this.Text)
                {
                    case "原疾患割当画面":
                        work.Insert(1, new DispCode("ZZZ", "未該当"));
                        break;
                    case "死因割当画面":
                        work.Insert(1, new DispCode("ZZZ", "未該当"));
                        break;
                    case "施設割当画面":
                        work.Insert(1, new DispCode("ZZZZZZ", "未該当"));
                        break;
                    case "割当対象選択":
                        work.Insert(1, new DispCode("ZZZZZZZZZZ", "未該当"));
                        break;
                }
            }

            // データバインド
            lstSelectList.DataSource = work;
        }

        /// <summary>
        /// フリーワード変更
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void txtFreeWord_TextChanged(object sender, EventArgs e)
        {
            // リストを更新
            this.ShowList();
        }

        /// <summary>
        /// OKボタンクリック
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnOK_Click(object sender, EventArgs e)
        {
            if (lstSelectList.SelectedIndex < 0)
            {
                // 候補未選択の場合
                MessageBox.Show("候補を選択してください", "未選択", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            // 選択結果取得用情報を格納
            this.SelectedCode = lstSelectList.SelectedValue as string;
            this.SelectedName = lstSelectList.Text;

            // 結果応答
            this.DialogResult = DialogResult.OK;
            this.Close();
        }

        /// <summary>
        /// フリーワードクリア
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnClear_Click(object sender, EventArgs e)
        {
            txtFreeWord.Text = string.Empty;
        }

        /// <summary>
        /// リストのダブルクリック
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void lstSelectList_DoubleClick(object sender, EventArgs e)
        {
            this.btnOK_Click(this.btnOK, EventArgs.Empty);
        }
    }
}
