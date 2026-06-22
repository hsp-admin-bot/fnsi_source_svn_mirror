using System;
using System.Windows.Forms;

namespace LayoutDesigner
{
    /// <summary>
    /// 書式選択画面
    /// </summary>
    public partial class FrmFormatCondition : LayoutDesignerUtilityLib.Controls.frmRldSizableBase
    {

        /// <summary>
        /// 次の値に等しい
        /// </summary>
        private const string coEqual = "==";

        /// <summary>
        /// 次の値に等しくない
        /// </summary>
        private const string coNotEqual = "!=";

        /// <summary>
        /// 次の値より大きい
        /// </summary>
        private const string coGreaterThan = ">";

        /// <summary>
        /// 次の値より小さい
        /// </summary>
        private const string coLessThan = "<";

        /// <summary>
        /// 次の値以上
        /// </summary>
        private const string coGreaterEqual = ">=";

        /// <summary>
        /// 次の値以下
        /// </summary>
        private const string coLessEqual = "<=";

        #region メンバプロパティ定義

        /// <summary>
        /// 比較演算子
        /// </summary>
        internal string ComparisonOperator { get; set; } = string.Empty;

        /// <summary>
        /// 比較演算の右辺
        /// </summary>
        internal string Value { get; set; } = string.Empty;

        /// <summary>
        /// フォント
        /// </summary>
        internal new System.Drawing.Font Font { get => this.lblExample.Font; set => this.lblExample.Font = value; }

        /// <summary>
        /// 文字色
        /// </summary>
        internal System.Drawing.Color Color { get => this.lblExample.ForeColor; set => this.lblExample.ForeColor = value; }

        /// <summary>
        /// 背景色
        /// </summary>
        internal new System.Drawing.Color BackColor { get => this.lblExample.BackColor; set => this.lblExample.BackColor = value; }

        #endregion

        #region 生成と破棄

        /// <summary>
        /// 条件付き書式編集画面
        /// </summary>
        public FrmFormatCondition()
        {
            InitializeComponent();

            // アイコンの設定
            this.Icon = Properties.Resources.LayoutDesigner;

        }

        #endregion

        #region メンバ関数定義(override...)

        /// <summary>
        /// Form.Load イベントを発生させます。
        /// </summary>
        /// <param name="e"></param>
        protected override void OnLoad(EventArgs e)
        {
            base.OnLoad(e);

            if (base.DesignMode)
            {
                return;
            }
            else
            {
                // デザインモードでない

                // 比較演算子
                switch (this.ComparisonOperator)
                {
                    case coEqual:
                        this.cboComparisonOperator.SelectedIndex = 0;
                        break;
                    case coNotEqual:
                        this.cboComparisonOperator.SelectedIndex = 1;
                        break;
                    case coGreaterThan:
                        this.cboComparisonOperator.SelectedIndex = 2;
                        break;
                    case coLessThan:
                        this.cboComparisonOperator.SelectedIndex = 3;
                        break;
                    case coGreaterEqual:
                        this.cboComparisonOperator.SelectedIndex = 4;
                        break;
                    case coLessEqual:
                        this.cboComparisonOperator.SelectedIndex = 5;
                        break;
                    default:
                        this.cboComparisonOperator.SelectedIndex = -1;
                        break;
                }

                // 比較演算の右辺
                this.txtValue.Text = this.Value;

                // 選択された書式
                this.lblExample.Font = this.Font;
                this.lblExample.ForeColor = this.Color;
                this.lblExample.BackColor = this.BackColor;

            }

        }

        #endregion

        #region コントロールイベントハンドラ定義

        private void btnCancel_Click(object sender, EventArgs e)
        {

            try
            {
                this.Close();
            }
            catch (Exception ex)
            {
                _ = MessageBox.Show(ex.Message, this.Text, MessageBoxButtons.OK, MessageBoxIcon.Error);
            }

        }

        private void btnOK_Click(object sender, EventArgs e)
        {

            try
            {

                switch (this.cboComparisonOperator.SelectedIndex)
                {
                    case 0:
                        // 次の値に等しい
                        this.ComparisonOperator = coEqual;
                        break;
                    case 1:
                        // 次の値に等しくない
                        this.ComparisonOperator = coNotEqual;
                        break;
                    case 2:
                        // 次の値より大きい
                        this.ComparisonOperator = coGreaterThan;
                        break;
                    case 3:
                        // 次の値より小さい
                        this.ComparisonOperator = coLessThan;
                        break;
                    case 4:
                        // 次の値以上
                        this.ComparisonOperator = coGreaterEqual;
                        break;
                    case 5:
                        // 次の値以下
                        this.ComparisonOperator = coLessEqual;
                        break;
                    default:
                        break;
                }
                this.Value = this.txtValue.Text;

                this.Close();

            }
            catch (Exception ex)
            {
                _ = MessageBox.Show(ex.Message, this.Text, MessageBoxButtons.OK, MessageBoxIcon.Error);
            }

        }

        private void BtnFont_Click(object sender, EventArgs e)
        {

            try
            {
                this.fontDialog1.ShowColor = true;
                this.fontDialog1.Font = this.lblExample.Font;
                this.fontDialog1.Color = this.lblExample.ForeColor;

                if (fontDialog1.ShowDialog() != DialogResult.Cancel)
                {
                    this.lblExample.Font = this.fontDialog1.Font;
                    this.lblExample.ForeColor = this.fontDialog1.Color;
                    this.Font = this.fontDialog1.Font;
                }
            }
            catch (Exception ex)
            {
                _ = MessageBox.Show(ex.Message, this.Text, MessageBoxButtons.OK, MessageBoxIcon.Error);
            }

        }

        #endregion

        private void BtnBackColor_Click(object sender, EventArgs e)
        {

            try
            {

                // 色ダイアログを表示する
                this.colorDialog1.Color = this.lblExample.BackColor;
                if (colorDialog1.ShowDialog(this) != DialogResult.Cancel)
                {
                    this.BackColor = colorDialog1.Color;
                }

            }
            catch (Exception ex)
            {
                LayoutDesignerUtilityLib.LayoutDesignerUtility.RecordException(this, ex, true);
            }

        }
    }
}
