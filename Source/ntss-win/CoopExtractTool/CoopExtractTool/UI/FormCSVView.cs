using CoopExtractTool.Datas;
using System;
using System.Diagnostics;
using System.Drawing;
using System.IO;
using System.Reflection;
using System.Text;
using System.Windows.Forms;

namespace CoopExtractTool
{
    public partial class FormCSVView : Form
    {
        /// <summary>
        /// コンストラクタ
        /// </summary>
        public FormCSVView()
        {
            InitializeComponent();
        }

        /// <summary>
        /// フォームロード時
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void FormCSVView_Load(object sender, EventArgs e)
        {
            // 画面タイトルをセット
            var versionInfo = FileVersionInfo.GetVersionInfo(Assembly.GetExecutingAssembly().Location);
            string version = versionInfo.FileVersion;
            this.Text = string.Format("{0}({1}) FNSi連携設定変換結果", Commons.AppName, version);

            BindingSource source = new BindingSource();
            source.DataSource = CSVDataManager.CSVDataList;
            dgvCSVView.DataSource = source;

            dgvCSVView.Columns["key0"].Width = 100;
            dgvCSVView.Columns["key1"].Width = 250;
            dgvCSVView.Columns["key2"].Width = 250;
            dgvCSVView.Columns["value"].Width = 150;
            dgvCSVView.Columns["comment"].Width = 300;
            dgvCSVView.Columns["default_v"].Width = 150;

            // 最初からOffの項目の背景を変更する
            foreach (DataGridViewRow row in dgvCSVView.Rows)
            {
                if (row.IsNewRow) continue; // 新規行はスキップ

                CSVDataItem dataItem = (CSVDataItem)row.DataBoundItem;

                if (dataItem != null && dataItem.isExclude)
                {
                    row.DefaultCellStyle.BackColor = Color.LightGray;
                }
            }
        }

        /// <summary>
        /// 終了ボタン押下時
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnEnd_Click(object sender, EventArgs e)
        {
            this.DialogResult = DialogResult.OK;
            this.Close();
        }

        /// <summary>
        /// 最初からボタン押下時
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnBeginning_Click(object sender, EventArgs e)
        {
            this.DialogResult = DialogResult.Cancel;
            this.Close();
        }

        /// <summary>
        /// フォームが閉じられようとしたとき
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void FormCSVView_FormClosing(object sender, FormClosingEventArgs e)
        {
            if (e.CloseReason == CloseReason.UserClosing)
            {
                if (this.DialogResult != DialogResult.OK && this.DialogResult != DialogResult.Cancel)
                {
                    // ×ボタンで閉じようとしたときの処理
                    this.DialogResult = DialogResult.No;
                }

            }
        }

        /// <summary>
        /// CSV出力ボタン押下時
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnCSVFileOut_Click(object sender, EventArgs e)
        {
            //SaveFileDialogクラスのインスタンスを作成
            SaveFileDialog sfd = new SaveFileDialog();

            //はじめのファイル名を指定する
            //はじめに「ファイル名」で表示される文字列を指定する
            sfd.FileName = string.Format("FNW連携設定_{0}_{1}.csv", CSVDataManager.key0, DateTime.Now.ToString("yyyyMMdd"));
            // ドキュメントフォルダを初期ディレクトリに設定
            sfd.InitialDirectory = Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments);
            //[ファイルの種類]に表示される選択肢を指定する
            //指定しない（空の文字列）の時は、現在のディレクトリが表示される
            sfd.Filter = "Csv Files (*.csv)|*.csv";
            //[ファイルの種類]ではじめに選択されるものを指定する
            //2番目の「すべてのファイル」が選択されているようにする
            sfd.FilterIndex = 1;
            //タイトルを設定する
            sfd.Title = "CSV出力するファイルを選択してください";
            //ダイアログボックスを閉じる前に現在のディレクトリを復元するようにする
            sfd.RestoreDirectory = true;

            //ダイアログを表示する
            if (sfd.ShowDialog() == DialogResult.OK)
            {
                // OKボタンがクリックされたとき
                ExportToCsv(dgvCSVView, sfd.FileName);
            }
        }

        /// <summary>
        /// CSVファイル出力
        /// </summary>
        /// <param name="dgv"></param>
        /// <param name="filePath"></param>
        public static void ExportToCsv(DataGridView dgv, string filePath)
        {
            try
            {
                var sb = new StringBuilder();

                // ヘッダー行
                sb.AppendLine("Key0,Key1,Key2,Value,Comment,DefaultValue,IsEffect");

                // データ行
                foreach (DataGridViewRow row in dgv.Rows)
                {
                    if (row.IsNewRow) continue; // 新規行はスキップ

                    if (row.DefaultCellStyle.BackColor == Color.LightGray)
                    {
                        // 除外の場合はスキップ
                        continue;
                    }

                    for (int i = 0; i < dgv.Columns.Count; i++)
                    {
                        var cellValue = row.Cells[i].Value?.ToString() ?? "";
                        //// カンマやダブルクオートを含む場合は囲む
                        //if (cellValue.Contains(",") || cellValue.Contains("\""))
                        //{
                        //    cellValue = "\"" + cellValue.Replace("\"", "\"\"") + "\"";
                        //}
                        cellValue = "\"" + cellValue.Replace("\"", "\"\"") + "\"";
                        sb.Append(cellValue);
                        if (i < dgv.Columns.Count - 1)
                            sb.Append(",");
                    }
                    sb.Append(",\"1\"");    // IsEffect
                    sb.AppendLine();
                }

                File.WriteAllText(filePath, sb.ToString(), Encoding.UTF8);
            }
            catch
            {
                MessageBox.Show("CSVファイルの出力中にエラーが発生しました。", Commons.AppName, MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }
        }

        /// <summary>
        /// On/Offボタン押下時
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnOnOff_Click(object sender, EventArgs e)
        {
            foreach (DataGridViewRow row in dgvCSVView.SelectedRows)
            {
                if (row.DefaultCellStyle.BackColor == Color.LightGray)
                {
                    row.DefaultCellStyle.BackColor = Color.Empty;
                }
                else
                {
                    row.DefaultCellStyle.BackColor = Color.LightGray;
                }
            }
        }
    }
}
