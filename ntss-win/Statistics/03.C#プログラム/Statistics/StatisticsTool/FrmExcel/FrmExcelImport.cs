using System;
using System.IO;
using System.Data;
using System.Windows.Forms;
using Fnw.StatisticsTool.Properties;
using Fnw.StatisticsTool.Csv;
using NKKLoggingLib;
using System.Reflection;
using System.Linq;
using System.Collections.Generic;

namespace Fnw.StatisticsTool.FrmExcel
{
    /// <summary>
    /// エクセル取込画面
    /// </summary>
    public partial class FrmExcelImport : StatisticsBase
    {
        private List<string> enumValues;

        /// <summary>
        /// コンストラクタ
        /// </summary>
        public FrmExcelImport() : base(isUserLoggedIn: true)
        {
            InitializeComponent();
            // 基底クラスのコンストラクタでイベント登録
            RegisterEvents(this);
            // チラつき防止
            SetDoubleBuffering(gridCsv, true);
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
        private void FrmExcelImport_Load(object sender, EventArgs e)
        {
            NKKLogging.GetInstance().AddLogInfo(DateTime.Now, StatisticsUtility.PRODUCT_NAME,
            GetType().Name, NKKLogging.LOGGING_CLASS.INFO, MethodBase.GetCurrentMethod().Name);

            enumValues = Enum.GetValues(typeof(SheetSum))
                .Cast<SheetSum>() // Enumのすべての値を取得し、列挙型に変換
                .Where(x => x != SheetSum.件数_
                )
                // 除外したい事務局使用欄を指定
                .Select(x => x.ToString().Substring(x.ToString().IndexOf('_') + 1)) // "_" の後の部分を取得
                .ToList(); // Listに変換

            gridCsv.Rows.Clear();
            gridCsv.Columns.Clear();

            foreach (var columnName in enumValues)
            {
                gridCsv.Columns.Add(columnName, columnName);
            }

            string targetString = "謎"; 
            foreach (DataGridViewColumn column in gridCsv.Columns)
            {
                if (column.HeaderText.Contains(targetString))
                {
                    column.HeaderText = string.Empty; // 列名を空白に設定
                }
            }

            foreach (DataGridViewColumn column in gridCsv.Columns)
            {
                column.SortMode = DataGridViewColumnSortMode.NotSortable;
            }

        }

        /// <summary>
        /// 処理開始ボタンクリック
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnRun_Click(object sender, EventArgs e)
        {
            try
            {
                this.Cursor = Cursors.WaitCursor;

                // DataTable の作成
                DataTable dtNew = new DataTable();

                // DataGridView の列を DataTable の列に追加
                foreach (DataGridViewColumn column in gridCsv.Columns)
                {
                    dtNew.Columns.Add(column.HeaderText, typeof(string));
                }

                // DataGridView の行を DataTable に追加
                foreach (DataGridViewRow row in gridCsv.Rows)
                {
                    if (!row.IsNewRow) // 新しい空行は無視
                    {
                        DataRow dataRow = dtNew.NewRow();
                        for (int i = 0; i < gridCsv.ColumnCount; i++)
                        {
                            dataRow[i] = row.Cells[i].Value ?? ""; // null の場合は空文字
                        }
                        dtNew.Rows.Add(dataRow);
                    }
                }

                // CSVファイルにデータを書き込み
                if (!FnwCsv.Write(Path.Combine(Settings.Default.PathCsv, Settings.Default.PathPatient), dtNew))
                {
                    MessageBox.Show(
                        "データの作成に失敗しました。\r\n" +
                        "ファイルが使用中でないか、保存先のパスが正しいかを確認してください。\r\n" +
                        $"保存先: {Settings.Default.PathCsv}\\{Settings.Default.PathPatient}",
                        "出力エラー",
                        MessageBoxButtons.OK,
                        MessageBoxIcon.Error
                    );
                    return;
                }

                // 処理終了メッセージ
                MessageBox.Show(
                    $"データの作成が完了しました。\r\n登録済み患者数: {dtNew.Rows.Count}件\r\nファイル: {Settings.Default.PathCsv}\\{Settings.Default.PathPatient}",
                    "完了",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Information
                );

                ConfirmCompletionStatus(true);
                this.DialogResult = DialogResult.Cancel;
                this.Close();
            }
            finally
            {
                this.Cursor = Cursors.Default;
            }
        }

        /// <summary>
        /// キャンセルボタンクリック
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnCancel_Click(object sender, EventArgs e)
        {
            // ダイアログを閉じる
            this.DialogResult = DialogResult.Cancel;
            this.Close();
        }

        ///// <summary>
        ///// クリップボードのデータが正しいかどうかをチェックする
        ///// </summary>
        ///// <param name="clipboardData">クリップボードのデータ</param>
        ///// <param name="enumNow">現在の列名リスト（カラム数）</param>
        ///// <returns>クリップボードデータが正しい場合はtrue、不足がある場合はfalse</returns>
        //private bool IsValidClipboardData(string clipboardData, List<string> enumNow , out string errorMessage)
        //{
        //    // 行ごとに分割
        //    var rows = clipboardData.Split(new[] { "\r\n", "\n" }, StringSplitOptions.RemoveEmptyEntries);

        //    if (rows.Length == 0)
        //    {
        //        errorMessage = "クリップボードにデータがありません。";
        //        return false;
        //    }

        //    // 各行にタブが含まれているか確認
        //    foreach (var row in rows)
        //    {
        //        if (!row.Contains("\t"))
        //        {
        //            errorMessage = "クリップボードのデータが正しくありません。";
        //            return false;
        //        }
        //    }

        //    // 各行のカラム数が一致するか確認
        //    int clipboardColumnCount = rows[0].Split('\t').Length;

        //    // enumNow の項目数（列数）を取得
        //    int enumNowColumnCount = enumNow.Count;

        //    // クリップボードのカラム数が不足している場合
        //    if (clipboardColumnCount < enumNowColumnCount)
        //    {
        //        errorMessage = $"不足しているカラム数: {enumNowColumnCount - clipboardColumnCount}";
        //        return false;
        //    }
        //    // クリップボードのカラム数が多い場合
        //    else if (clipboardColumnCount > enumNowColumnCount)
        //    {
        //        errorMessage = $"余分なカラム数: {clipboardColumnCount - enumNowColumnCount}";
        //        return false;
        //    }

        //    errorMessage = null;
        //    return true;
        //}

        /// <summary>
        /// チラつき防止
        /// </summary>
        /// <param name="dgv"></param>
        /// <param name="enable"></param>
        public static void SetDoubleBuffering(DataGridView dgv, bool enable)
        {
            typeof(DataGridView).GetProperty("DoubleBuffered", BindingFlags.NonPublic | BindingFlags.Instance)
                .SetValue(dgv, enable, null);
        }

        /// <summary>
        /// 
        /// </summary>
        private void PasteClipboardToDataGridView()
        {
            try
            {
                gridCsv.Rows.Clear();
                this.Cursor = Cursors.WaitCursor;
                // クリップボードからデータを取得
                string clipboardText = Clipboard.GetText();
                if (string.IsNullOrWhiteSpace(clipboardText))
                {
                    MessageBox.Show("クリップボードにデータがありません。", "エラー", MessageBoxButtons.OK, MessageBoxIcon.Stop);
                    return;
                }

                // DataGridView の既存データをクリア
                gridCsv.Rows.Clear();

                // 行データを分割
                string[] lines = clipboardText.Split(new[] { "\r\n", "\n" }, StringSplitOptions.RemoveEmptyEntries);

                foreach (var line in lines)
                {
                    // 列データを分割 (タブ区切りを想定)
                    string[] cells = line.Split('\t');

                    // 行明細がすべて空の場合はスキップ
                    if (cells.All(string.IsNullOrWhiteSpace))
                    {
                        continue;
                    }

                    // DataGridView の列数と一致しない場合、補完または切り捨て
                    var row = new object[enumValues.Count];
                    for (int i = 0; i < enumValues.Count; i++)
                    {
                        row[i] = i < cells.Length ? cells[i] : ""; // データがない場合は空文字
                    }

                    // 行を追加
                    gridCsv.Rows.Add(row);
                }

                // 開始位置を(0, 0)に移動（オプション: 最初のセルを選択）
                if (gridCsv.RowCount > 0 && gridCsv.ColumnCount > 0)
                {
                    gridCsv.CurrentCell = gridCsv[0, 0];
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"エラーが発生しました: {ex.Message}");
            }
            finally
            {
                this.Cursor = Cursors.Default;
            }
        }

        private void FrmExcelImport_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.Control && e.KeyCode == Keys.V)
            {
                // DataGridViewがフォーカスを持つ、または内部にフォーカスがある場合に処理
                if (gridCsv.Focused || gridCsv.ContainsFocus)
                {
                    PasteClipboardToDataGridView();
                    e.Handled = true; // イベント処理済み
                }
            }
        }

        private void btnPaste_Click_1(object sender, EventArgs e)
        {
            PasteClipboardToDataGridView();
        }
    }
}
