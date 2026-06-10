using System;
using System.Windows.Forms;
using LayoutDesigner.Data;

namespace LayoutDesigner
{
    /// <summary>
    /// 書式選択画面
    /// </summary>
    public partial class FrmFormatConditions : LayoutDesignerUtilityLib.Controls.frmRldSizableBase
    {
        #region メンバプロパティ定義

        /// <summary>
        /// ルール
        /// </summary>
        public FormatConditionRules Rules { get; set; } = new FormatConditionRules();

        #endregion

        #region 生成と破棄

        /// <summary>
        /// 条件付き書式編集画面
        /// </summary>
        public FrmFormatConditions()
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
                for (int i = 0; i < this.Rules.Count; i++)
                {
                    // DataGirdViewにデータを表示する
                    this.AddDataGridViewRow(this.Rules[i]);
                }

            }

        }

        #endregion

        #region コントロールイベントハンドラ定義

        private void BtnClose_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private void BtnRuleAdd_Click(object sender, EventArgs e)
        {

            try
            {
                // 条件付き書式編集画面
                using (var wDlg = new FrmFormatCondition())
                {
                    // ダイアログの表示
                    if (DialogResult.OK == wDlg.ShowDialog())
                    {

                        // 条件付き書式ダイアログで登録された値を画面に表示する
                        string comparisonOperator = wDlg.ComparisonOperator;
                        string value = wDlg.Value;
                        System.Drawing.Font font = wDlg.Font;
                        System.Drawing.Color foreColor = wDlg.Color;
                        System.Drawing.Color backColor = wDlg.BackColor;
                        //this.Rules.Add((comparisonOperator, value, font, string.Empty));
                        var formatCondition = new FormatConditionRule
                        {
                            ComparisonOperator = comparisonOperator,
                            Value = value,
                            Font = font,
                            Color = foreColor,
                            BackColor = backColor
                        };
                        this.Rules.Add(formatCondition);

                        // DataGirdViewにデータを表示する
                        this.AddDataGridViewRow(formatCondition);

                        // 編集ボタンと削除ボタンを使用可能にする
                        this.btnRuleEdit.Enabled = true;
                        this.btnRuleDelete.Enabled = true;

                    }
                }

            }
            catch (Exception ex)
            {
                ShowErrorMessage(ex.Message);
            }

        }

        /// <summary>
        /// DataGirdViewにデータを追加する
        /// </summary>
        /// <param name="formatCondition">条件付き書式</param>
        private void AddDataGridViewRow(FormatConditionRule formatCondition)
        {
            int rowIndex = this.dgvFormatConditions.Rows.Add(new string[] { "セルの値 " + formatCondition.ComparisonOperator + " " + formatCondition.Value, "Aaあぁアァ亜宇" });
            SetDataGridViewCellStyle(this.dgvFormatConditions[1, rowIndex].Style, formatCondition.Font, formatCondition.Color, formatCondition.BackColor);
        }

        /// <summary>
        /// DataGridViewのセルスタイルを設定する
        /// </summary>
        /// <param name="cellStyle">DataGridViewCellStyle</param>
        /// <param name="font">フォント</param>
        /// <param name="foreColor">文字色</param>
        /// <param name="backColor">背景色</param>
        private static void SetDataGridViewCellStyle(DataGridViewCellStyle cellStyle, System.Drawing.Font font, System.Drawing.Color foreColor, System.Drawing.Color backColor)
        {
            cellStyle.Font = font;
            cellStyle.ForeColor = foreColor;
            cellStyle.BackColor = backColor;
        }

        private void BtnRuleEdit_Click(object sender, EventArgs e)
        {
            try
            {
                // add 2020-08-06 FNSI-仕様修正 修正パラメータを空にするバグ問題 李 start
                if (dgvFormatConditions.CurrentRow == null || this.dgvFormatConditions.Rows.Count == 0)
                    return;
                // add 2020-08-06 FNSI-仕様修正 修正パラメータを空にするバグ問題 李 end

                int rowIndex = this.dgvFormatConditions.CurrentRow.Index;

                // 条件付き書式編集画面
                using (var wDlg = new FrmFormatCondition())
                {

                    // 変更前の値をセットする
                    wDlg.ComparisonOperator = this.Rules[rowIndex].ComparisonOperator;
                    wDlg.Value = this.Rules[rowIndex].Value;
                    wDlg.Font = this.Rules[rowIndex].Font;
                    wDlg.Color = this.Rules[rowIndex].Color;
                    wDlg.BackColor = this.Rules[rowIndex].BackColor;

                    // ダイアログの表示
                    if (DialogResult.OK == wDlg.ShowDialog())
                    {

                        // 条件付き書式ダイアログで登録された値を画面に表示する
                        var formatCondition = new FormatConditionRule
                        {
                            ComparisonOperator = wDlg.ComparisonOperator,
                            Value = wDlg.Value,
                            Font = wDlg.Font,
                            Color = wDlg.Color,
                            BackColor = wDlg.BackColor
                        };
                        this.SetDataGridViewData(rowIndex, formatCondition);
                    }
                }

            }
            catch (Exception ex)
            {
                ShowErrorMessage(ex.Message);
            }

        }

        /// <summary>
        /// DataGridViewに値を表示する
        /// </summary>
        /// <param name="rowIndex">行番号 0～</param>
        /// <param name="p">DataGridViewに表示するデータ</param>
        private void SetDataGridViewData(int rowIndex, FormatConditionRule p)
        {
            //this.Rules[rowIndex] = p;
            //this.Rules[rowIndex].ComparisonOperator = p.ComparisonOperator;
            //this.Rules[rowIndex].Value = p.Value;
            //this.Rules[rowIndex].Font = p.SelectedFont;

            this.Rules[rowIndex] = p;
            //p.ComparisonOperator = p.ComparisonOperator;
            //p.Value = p.Value;
            //p.SelectedFont = p.Font;

            this.dgvFormatConditions[0, rowIndex].Value = "セルの値 " + p.ComparisonOperator + " " + p.Value;
            //this.dgvFormatConditions[1, rowIndex].Style.Font = p.Font;
            SetDataGridViewCellStyle(this.dgvFormatConditions[1, rowIndex].Style, p.Font, p.Color, p.BackColor);

        }

        private void BtnRuleDelete_Click(object sender, EventArgs e)
        {

            try
            {
                // 現在選択中の行を削除する
                if ((this.dgvFormatConditions.Rows.Count > 0) && (this.dgvFormatConditions.CurrentRow != null))
                {

                    // 内部テーブルから削除する
                    this.Rules.RemoveAt(this.dgvFormatConditions.CurrentRow.Index);

                    // DataGridView から削除する
                    this.dgvFormatConditions.Rows.Remove(this.dgvFormatConditions.CurrentRow);

                    // 結果0行になったら編集ボタンと削除ボタンを使用不可にする
                    if (this.dgvFormatConditions.Rows.Count <= 0)
                    {
                        // 編集ボタンと削除ボタンを使用不可にする
                        this.btnRuleEdit.Enabled = false;
                        this.btnRuleDelete.Enabled = false;
                    }

                }

            }
            catch (Exception ex)
            {
                ShowErrorMessage(ex.Message);
            }

        }

        private void BtnUp_Click(object sender, EventArgs e)
        {
            try
            {
                // add 2020-08-05 FNSI-仕様修正 修正パラメータを空にするバグ問題 李 start
                if (dgvFormatConditions.CurrentRow == null || this.dgvFormatConditions.Rows.Count == 1)
                    return;
                // add 2020-08-05 FNSI-仕様修正 修正パラメータを空にするバグ問題 李 end

                // 上へ移動する処理を実装する
                int rowIndex = this.dgvFormatConditions.CurrentRow.Index;
                if (rowIndex > 0)
                {

                    // 「rowIndex - 1」と「rowIndex」を入れ替える
                    ExChangeRowData(rowIndex - 1);

                    this.dgvFormatConditions.CurrentCell = this.dgvFormatConditions[0, rowIndex - 1];

                    // 移動先が先頭行ならば上移動ボタンを使用不可にする
                    if (rowIndex - 1 <= 0)
                    {
                        ((Button)sender).Enabled = false;
                    }

                    // 下へ移動ボタンを使用可能にする
                    if (this.btnDown.Enabled == false)
                    {
                        this.btnDown.Enabled = true;
                    }

                }
                else
                {
                    // 現在のセル位置が0以下の場合、上に移動できない
                    ((Button)sender).Enabled = false;
                }

            }
            catch (Exception ex)
            {
                ShowErrorMessage(ex.Message);
            }

        }

        /// <summary>
        /// ルール一覧の行を入れ替える
        /// </summary>
        /// <param name="rowIndex">入れ替え行 開始インデックス</param>
        private void ExChangeRowData(int rowIndex)
        {
            // 移動先データを一時記憶する
            //(string comparisonOperator, string value, System.Drawing.Font font, string _) temp = this.Rules[rowIndex];
            FormatConditionRule temp = this.Rules[rowIndex];
            this.Rules[rowIndex] = this.Rules[rowIndex + 1];
            this.Rules[rowIndex + 1] = temp;

            // 移動後の状態をDataGridViewに表示する
            this.SetDataGridViewData(rowIndex, this.Rules[rowIndex]);
            this.SetDataGridViewData(rowIndex + 1, this.Rules[rowIndex + 1]);
        }

        private void BtnDown_Click(object sender, EventArgs e)
        {
            try
            {
                // add 2020-08-05 FNSI-仕様修正 修正パラメータを空にするバグ問題 李 start
                if (dgvFormatConditions.CurrentRow == null || this.dgvFormatConditions.Rows.Count == 1)
                    return;
                // add 2020-08-05 FNSI-仕様修正 修正パラメータを空にするバグ問題 李 end

                // 下へ移動する処理を実装する
                int rowIndex = this.dgvFormatConditions.CurrentRow.Index;
                if (rowIndex <= this.dgvFormatConditions.Rows.Count - 1)
                {
                    // 現在のセルが最下行でない

                    // 「rowIndex」と「rowIndex + 1」を入れ替える
                    ExChangeRowData(rowIndex);

                    this.dgvFormatConditions.CurrentCell = this.dgvFormatConditions[0, rowIndex + 1];

                    // 移動先が最下行ならば下移動ボタンを使用不可にする
                    if (rowIndex + 1 >= this.dgvFormatConditions.Rows.Count - 1)
                    {
                        ((Button)sender).Enabled = false;
                    }

                    // 上へ移動ボタンを使用可能にする
                    if (this.btnUp.Enabled == false)
                    {
                        this.btnUp.Enabled = true;
                    }

                }
                else
                {
                    // 現在のセル位置が最下行の場合、下に移動できない
                    ((Button)sender).Enabled = false;

                }

            }
            catch (Exception ex)
            {
                ShowErrorMessage(ex.Message);
            }

        }

        #endregion

        /// <summary>
        /// エラーメッセージをメッセージボックスで表示する
        /// </summary>
        /// <param name="message">メッセージ ボックスに表示するテキスト</param>
        private void ShowErrorMessage(string message)
        {
            _ = MessageBox.Show(message, this.Text, MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
    }
}
