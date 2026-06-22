using Fnw.StatisticsTool.Properties;
using NKKLoggingLib;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace Fnw.StatisticsTool.FrmCsv
{
    /// <summary>
    /// 
    /// </summary>
    public partial class FrmCsvViewer : StatisticsBase
    {
        /// <summary>
        /// 
        /// </summary>
        public FrmCsvViewer() : base(isUserLoggedIn: true)
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
        /// 画面の読み込み
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void FrmCsvViewer_Load(object sender, EventArgs e)
        {
            NKKLogging.GetInstance().AddLogInfo(DateTime.Now, StatisticsUtility.PRODUCT_NAME,
            GetType().Name, NKKLogging.LOGGING_CLASS.INFO, MethodBase.GetCurrentMethod().Name);
            var dt = new DataTable();
            gridCsv.Rows.Clear();
            gridCsv.Columns.Clear();

            string filePath = Path.Combine(Settings.Default.PathExport, Settings.Default.FileSheetSum);
            //var lines = File.ReadLines(filePath, Encoding.GetEncoding("shift-jis"));
            // Shift-JISでファイルを読み込む
            List<List<string>> lines = new List<List<string>>();
            foreach (var line in File.ReadLines(filePath, Encoding.GetEncoding("shift-jis")))
            {
                // クオート内のカンマを処理するためのパース処理
                List<string> parsedFields = ParseCsvLine(line);

                // パースしたデータを全行リストに追加
                lines.Add(parsedFields);
            }

            var enumValues = Enum.GetValues(typeof(SheetSum))
                .Cast<SheetSum>() // Enumのすべての値を取得し、列挙型に変換
                .Where(x => x != SheetSum.件数_)                
                                // 除外したい事務局使用欄を指定
                .Select(x => x.ToString().Substring(x.ToString().IndexOf('_') + 1)) // "_" の後の部分を取得
                .ToList(); // Listに変換
            // DataTableに列を追加（Enumから）
            foreach (var columnName in enumValues)
            {
                dt.Columns.Add(columnName);
            }

            string targetString = "謎";
            foreach (DataGridViewColumn column in gridCsv.Columns)
            {
                if (column.HeaderText.Contains(targetString))
                {
                    column.HeaderText = string.Empty; // 列名を空白に設定
                }
            }

            // DataGridViewにDataTableを設定
            gridCsv.DataSource = dt;

            foreach (DataGridViewColumn column in gridCsv.Columns)
            {
                column.SortMode = DataGridViewColumnSortMode.NotSortable;
            }

            // データをDataTableに読み込む（列数はEnumの数に一致）
            foreach (var line in lines)
            {
                // 行のデータが列数と一致している場合にDataTableに追加
                if (line.Count == enumValues.Count)
                {
                    dt.Rows.Add(line.ToArray());
                }
            }

            // 編集不可に設定
            foreach (DataGridViewColumn column in gridCsv.Columns)
            {
                column.ReadOnly = true;
            }
        }

        /// <summary>
        /// 明細の選択をCSV形式でコピーするメソッド
        /// </summary>
        private async void CopySelectedDataToClipboard(bool copyAll)
        {
            try
            {
                List<string> dataToCopy = new List<string>();

                if (copyAll) // 全データをコピー
                {
                    dataToCopy = gridCsv.Rows.Cast<DataGridViewRow>()
                        .Where(row => !row.IsNewRow) // 新しい行（空の行）は除外
                        .Select(row => string.Join("\t", row.Cells.Cast<DataGridViewCell>()
                            .Select(cell => cell.Value?.ToString() ?? ""))) // セルの値をカンマで区切る
                        .ToList();
                }
                else // 選択範囲のみコピー
                {
                    dataToCopy = gridCsv.SelectedRows.Cast<DataGridViewRow>()
                        .Where(row => !row.IsNewRow) // 新しい行（空の行）は除外
                        .Select(row => string.Join("\t", row.Cells.Cast<DataGridViewCell>()
                            .Select(cell => cell.Value?.ToString() ?? ""))) // セルの値をカンマで区切る
                        .ToList();
                }

                if (dataToCopy.Any())
                {
                    var csvContent = string.Join(Environment.NewLine, dataToCopy);
                    Clipboard.SetText(csvContent); // クリップボードにコピー
                    await Task.Delay(300);
                    MessageBox.Show("表示内容をクリップボードにコピーしました。", "情報", MessageBoxButtons.OK, MessageBoxIcon.Information);
                }
                else
                {
                    MessageBox.Show("コピーするデータがありません。", "情報", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"エラーが発生しました: {ex.Message}", "エラー", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        /// <summary>
        /// OKボタンのクリック
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnOK_Click(object sender, EventArgs e)
        {
            this.Close();
        }

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
        /// 全選択処理のクリック
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnSelectAll_Click(object sender, EventArgs e)
        {
            btnSelectAll.Enabled = false;
            Cursor.Current = Cursors.WaitCursor;
            CopySelectedDataToClipboard(true);
            Cursor.Current = Cursors.Default;
            btnSelectAll.Enabled = true;
        }

        private void FrmCsvViewer_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.Control && e.KeyCode == Keys.C) // Ctrl+C のチェック
            {
                if (gridCsv.Focused || gridCsv.ContainsFocus)
                {
                    Cursor.Current = Cursors.WaitCursor;
                    SetEnabled(false); // ボタンを無効化
                    try
                    {
                        CopySelectedDataToClipboard(false);
                    }
                    finally
                    {
                        SetEnabled(true); // ボタンを再び有効化
                        Cursor.Current = Cursors.Default;
                    }
                    e.Handled = true; // デフォルト動作を無効化
                }
            }
        }

        private void SetEnabled(bool value)
        {
            btnSelectAll.Enabled = value;
            btnOK.Enabled = value;
        }

        static List<string> ParseCsvLine(string line)
        {
            var fields = new List<string>();
            var tempField = new StringBuilder();
            bool insideQuotes = false;

            foreach (var c in line)
            {
                if (c == '"')
                {
                    insideQuotes = !insideQuotes; // 引用符内のデータはそのままに
                }
                else if (c == ',' && !insideQuotes)
                {
                    // カンマ区切りでフィールドを追加（引用符内でない場合）
                    fields.Add(tempField.ToString().Trim());
                    tempField.Clear();
                }
                else
                {
                    tempField.Append(c);
                }
            }

            // 最後のフィールドを追加
            fields.Add(tempField.ToString().Trim());

            return fields;
        }

    }
}
