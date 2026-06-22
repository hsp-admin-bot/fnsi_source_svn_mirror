using System;
using System.Windows.Forms;

namespace ExcelReportTool
{
    /// <summary>
    /// ラベルの汎用項目1つに対応するユーザコントロール
    /// </summary>
    public partial class ucLabelClass : UserControl
    {
        /// <summary>
        /// 汎用項目編集用ユーザコントロールのコンストラクタ
        /// </summary>
        public ucLabelClass()
        {
            InitializeComponent();

            // コンボボックスにバインドするComboItemクラス用にメンバを登録
            cmbLabelClass.DisplayMember = LayoutDesigner.ComboItem.KEY_DISP;
            cmbLabelClass.ValueMember = LayoutDesigner.ComboItem.KEY_VAL;
        }

        /// <summary>
        /// 編集状態が空かどうかを取得
        /// </summary>
        public bool IsEmpty
        {
            get
            {
                return string.IsNullOrEmpty(cmbLabelClass.SelectedValue as string) && string.IsNullOrEmpty(txtFixString.Text);
            }
        }

        /// <summary>
        /// データ種別を表すタイトルを設定または取得
        /// </summary>
        public string Title
        {
            get
            {
                return lblTitle.Text;
            }
            set
            {
                lblTitle.Text = value;
            }
        }

        /// <summary>
        /// データ候補を設定または取得
        /// </summary>
        internal string SelectClassItem
        {
            get
            {
                return cmbLabelClass.SelectedValue as string;
            }
            set
            {
                try
                {
                    cmbLabelClass.SelectedValue = value;
                }
                catch { }
            }
        }

        /// <summary>
        /// 固定文字列を設定または取得
        /// </summary>
        internal string FixString
        {
            set
            {
                txtFixString.Text = value;
            }
            get
            {
                return txtFixString.Text;
            }
        }

        /// <summary>
        /// データ項目の候補を登録
        /// </summary>
        internal LayoutDesigner.ComboItem[] ClassItems
        {
            set
            {
                // コンボボックスにデータをバインド
                this.cmbLabelClass.DataSource = value;
            }
        }

        /// <summary>
        /// 固定文字列が編集された
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void txtFixString_TextChanged(object sender, EventArgs e)
        {
            // 空文字の場合だけコンボボックスを有効にする
            cmbLabelClass.Enabled = string.IsNullOrEmpty(txtFixString.Text);
        }

        /// <summary>
        /// コンボボックスの選択が変更された
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void cmbLabelClass_SelectedValueChanged(object sender, EventArgs e)
        {
            // 項目が未選択の場合だけ固定文字列の編集を有効にする
            txtFixString.Enabled = string.IsNullOrEmpty(cmbLabelClass.SelectedValue as string);
        }
    }
}
