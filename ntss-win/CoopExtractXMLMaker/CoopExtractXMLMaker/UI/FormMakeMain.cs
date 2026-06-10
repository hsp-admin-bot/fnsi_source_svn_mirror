using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Windows.Forms;

namespace CoopExtractXMLMaker
{
    public partial class FormMakeMain : Form
    {
        /// <summary>
        /// 現在選択されている変換設定
        /// </summary>
        Item CurrentItem;
        ValueMappingList CurrentValueMapping;

        public class ValueItem
        {
            [DisplayName("FNSi")]
            public string After { get; set; }

            [DisplayName("")]
            public string To { get; set; }

            [DisplayName("FNW")]
            public string Before { get; set; }
        }

        private BindingList<ValueItem> ValueDataList;

        public class ComparisonColumnItem
        {
            public string ColumnA { get; set; }
            public string ColumnB { get; set; }
        }

        private List<string> NoMatchList = new List<string>
        {
            "ConvTarget",
            "INI_SECTION",
            "INI_KEY",
            "INI_VALUE",
            "DEFAULT_VALUE",
            "KEY_TITLE",
            "MEMO",
        };

        private List<ComparisonColumnItem> ComparisonColumnList = new List<ComparisonColumnItem>
        {
            new ComparisonColumnItem { ColumnA = "INI_SECTION", ColumnB = "key1" },
            new ComparisonColumnItem { ColumnA = "INI_KEY", ColumnB = "key2" },
            new ComparisonColumnItem { ColumnA = "INI_VALUE", ColumnB = "value" },
            new ComparisonColumnItem { ColumnA = "DEFAULT_VALUE", ColumnB = "default_v" },
        };

        BindingSource sourceConversion = new BindingSource();
        BindingSource sourceFNW = new BindingSource();

        /// <summary>
        /// 値変換設定リストのエラー発生中
        /// </summary>
        private bool isValueError = false;

        /// <summary>
        /// ボタン押下による画面を閉じるを実行しているか？
        /// </summary>
        bool isClosingByButton = false;

        /// <summary>
        /// コンストラクタ
        /// </summary>
        public FormMakeMain()
        {
            InitializeComponent();

            // 画面右下のリサイズグリップを表示
            this.SizeGripStyle = SizeGripStyle.Show;
        }

        /// <summary>
        /// フォームロード時
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void FormMakeMain_Load(object sender, EventArgs e)
        {
            // 画面タイトルをセット
            var versionInfo = FileVersionInfo.GetVersionInfo(Assembly.GetExecutingAssembly().Location);
            string version = versionInfo.FileVersion;
            this.Text = string.Format("{0}({1}) 設定作成", Commons.AppName, version);

            if (ConfigSettingManager.Data.ConversionDefinition == ConversionDefinitionType.FromDefinition)
            {
                this.Text += " デフォルト定義ファイルからXMLを新規作成";
                btnXMLWrite.Text = "FNSiカルテ種別出力";
            }
            else if (ConfigSettingManager.Data.ConversionDefinition == ConversionDefinitionType.XMLReedit)
            {
                this.Text += " XMLを再編集";
                btnXMLWrite.Text = "FNSiカルテ種別出力";
            }
            else if (ConfigSettingManager.Data.ConversionDefinition == ConversionDefinitionType.OverwriteDefaultDefinition)
            {
                this.Text += " デフォルト変換定義を修正";
                btnXMLWrite.Text = "デフォルト定義ファイルを更新";
            }

            ValueDataList = new BindingList<ValueItem>();

            dgvDBFNWView.RowTemplate.Height = 20;

            sourceFNW.DataSource = ConversionFNWDataManager.ConversionFNWDataList;
            dgvDBFNWView.DataSource = sourceFNW;

            //dgvDBFNWView.Columns["INI_CLASS"].Width = 80;
            dgvDBFNWView.Columns["INI_SECTION"].Width = 200;
            dgvDBFNWView.Columns["INI_KEY"].Width = 100;
            //dgvDBFNWView.Columns["UP_DATE"].Width = 150;
            //dgvDBFNWView.Columns["SECTION_TITLE"].Width = 200;
            //dgvDBFNWView.Columns["KEY_TITLE"].Width = 200;
            dgvDBFNWView.Columns["INI_VALUE"].Width = 100;
            dgvDBFNWView.Columns["DEFAULT_VALUE"].Width = 100;
            //dgvDBFNWView.Columns["MEMO"].Width = 200;
            //dgvDBFNWView.Columns["SERIES_CD"].Width = 80;
            //dgvDBDBFNWView.Columns["SHORT_NAME"].Width = 150;
            dgvDBFNWView.Columns["KEY_TITLE"].Width = 70;
            dgvDBFNWView.Columns["MEMO"].Width = 70;

            // 行ヘッダの幅を設定
            dgvDBFNWView.RowHeadersWidth = 28;
            // 列ヘッダの文字列の折り返しを無効にする
            dgvDBFNWView.ColumnHeadersDefaultCellStyle.WrapMode = DataGridViewTriState.False;


            //IncludeDataList = new BindingList<IncludeItem>();

            dgvIncludeView.RowTemplate.Height = 20;

            sourceConversion.DataSource = ConversionDataManager.ConversionDataList;
            dgvIncludeView.DataSource = sourceConversion;

            dgvIncludeView.Columns["ConvTarget"].Width = 80;
            dgvIncludeView.Columns["key1"].Width = 200;
            dgvIncludeView.Columns["key2"].Width = 100;
            dgvIncludeView.Columns["value"].Width = 50;
            dgvIncludeView.Columns["default_v"].Width = 50;
            dgvIncludeView.Columns["comment"].Width = 70;
            dgvIncludeView.Columns["To"].Width = 25;
            dgvIncludeView.Columns["INI_SECTION"].Width = 200;
            dgvIncludeView.Columns["INI_KEY"].Width = 100;
            dgvIncludeView.Columns["INI_VALUE"].Width = 50;
            dgvIncludeView.Columns["DEFAULT_VALUE"].Width = 50;
            dgvIncludeView.Columns["KEY_TITLE"].Width = 70;
            dgvIncludeView.Columns["MEMO"].Width = 70;

            // 行ヘッダの幅を設定
            dgvIncludeView.RowHeadersWidth = 28;
            dgvIncludeView.Columns["To"].HeaderText = "";

            // 矢印の列を中央表示にする
            dgvIncludeView.Columns["To"].DefaultCellStyle.Alignment = DataGridViewContentAlignment.MiddleCenter;
            // 列ヘッダの文字列の折り返しを無効にする
            dgvIncludeView.ColumnHeadersDefaultCellStyle.WrapMode = DataGridViewTriState.False;
            //dgvIncludeView.DefaultCellStyle.SelectionForeColor = Color.Red;
            //dgvIncludeView.Rows[0].Cells["To"].Style.SelectionForeColor = Color.Red;


            dgvValueView.RowTemplate.Height = 20;
            BindingSource source4 = new BindingSource();
            source4.DataSource = ValueDataList;
            dgvValueView.DataSource = source4;

            DataGridViewButtonColumn column3 = new DataGridViewButtonColumn();
            //列の名前を設定
            column3.Name = "Trash";
            column3.HeaderText = "";
            column3.UseColumnTextForButtonValue = true;
            column3.Text = "del";
            //DataGridViewに追加する
            dgvValueView.Columns.Add(column3);

            dgvValueView.Columns["After"].Width = 80;
            dgvValueView.Columns["To"].Width = 25;
            dgvValueView.Columns["Before"].Width = 80;
            dgvValueView.Columns["Trash"].Width = 30;
            dgvValueView.Columns["To"].HeaderText = "";

            // 行ヘッダの幅を設定
            dgvValueView.RowHeadersWidth = 28;
            // 列ヘッダの文字列の折り返しを無効にする
            dgvValueView.ColumnHeadersDefaultCellStyle.WrapMode = DataGridViewTriState.False;
            // 矢印の列を中央表示にする
            dgvValueView.Columns["To"].DefaultCellStyle.Alignment = DataGridViewContentAlignment.MiddleCenter;

        }

        /// <summary>
        /// 指定したセルと1つ上のセルの値を比較
        /// </summary>
        /// <param name="column"></param>
        /// <param name="row"></param>
        /// <returns></returns>
        bool IsTheSameCellValue(int column, int row)
        {
            DataGridViewCell cell1 = dgvIncludeView[column, row];
            DataGridViewCell cell2 = dgvIncludeView[column, row - 1];

            if (cell1.Value == null || cell2.Value == null)
            {
                return false;
            }

            // ここでは文字列としてセルの値を比較
            if (cell1.Value.ToString() == cell2.Value.ToString())
            {
                return true;
            }
            else
            {
                return false;
            }
        }

        /// <summary>
        /// セルの表示内容を求められたとき
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void dgvIncludeView_CellFormatting(object sender, DataGridViewCellFormattingEventArgs e)
        {

            // 1行目については何もしない
            if (e.RowIndex != 0)
            {
                if (e.ColumnIndex == 1)
                {
                    if (IsTheSameCellValue(e.ColumnIndex, e.RowIndex))
                    {
                        e.Value = "";
                        e.FormattingApplied = true; // 以降の書式設定は不要
                    }
                }
            }

            var row = dgvIncludeView.Rows[e.RowIndex];
            if (row == null) return;
            var item = row.DataBoundItem as ConversionDataItem;
            if (item == null) return;

            if (item.Is_TempAdd == true)
            {
                row.DefaultCellStyle.BackColor = Color.FromArgb(204, 255, 204);

                //row.DefaultCellStyle.BackColor = Color.FromArgb(204, 255, 153);
                //row.DefaultCellStyle.SelectionBackColor = Color.Red;
                //row.Cells["To"].Style.SelectionForeColor = Color.Orange;
            }
            else
            {
                row.DefaultCellStyle.BackColor = Color.White;
            }
            //if (dgvIncludeView.Columns[e.ColumnIndex].Name == "key2")
            //{
            //    if (item.Is_TempAdd == true)
            //    {
            //        e.CellStyle.ForeColor = Color.Green;
            //    }
            //}


            // -------------------------------
            // 未設定行のグレー表示
            // -------------------------------

            // 今処理している列がNoMatchListに登録されているか
            int indexNoMatch = NoMatchList.FindIndex(d => d == dgvIncludeView.Columns[e.ColumnIndex].Name);

            if (indexNoMatch >= 0)
            {
                if (string.IsNullOrEmpty((string)row.Cells["INI_SECTION"].Value) == true)
                {
                    e.CellStyle.BackColor = Color.FromArgb(128, 128, 128);

                    return;
                }
            }


            // -------------------------------
            // 内容に差があるセルの強調表示
            // -------------------------------
            if (string.IsNullOrEmpty((string)row.Cells["INI_SECTION"].Value) == true)
            {
                return;
            }

            if (item.Is_TempAdd == true)
            {
                // 新規追加行の場合
                if (dgvIncludeView.Columns[e.ColumnIndex].Name == "INI_SECTION" ||
                    dgvIncludeView.Columns[e.ColumnIndex].Name == "key1")
                {
                    // 両方のセルの値を取得して比較
                    if (row.Cells["INI_SECTION"].Value != null && row.Cells["key1"].Value != null)
                    {

                        if (row.Cells["INI_SECTION"].Value.ToString() != row.Cells["key1"].Value.ToString())
                        {
                            //e.CellStyle.ForeColor = Color.FromArgb(7, 131, 4);
                            //e.CellStyle.ForeColor = Color.FromArgb(85, 137, 31);
                            e.CellStyle.ForeColor = Color.FromArgb(255, 127, 80);
                            e.CellStyle.Font = new Font(dgvIncludeView.Font, FontStyle.Bold);
                        }
                    }
                    else
                    {
                        e.CellStyle.ForeColor = Color.Black;
                        e.CellStyle.Font = new Font(dgvIncludeView.Font, FontStyle.Regular);
                    }


                }
            }
            else
            {
                // 今処理している列がComparisonColumnListに登録されているか
                int index = ComparisonColumnList.FindIndex(d =>
                     d.ColumnA == dgvIncludeView.Columns[e.ColumnIndex].Name ||
                     d.ColumnB == dgvIncludeView.Columns[e.ColumnIndex].Name);

                if (index >= 0)
                {
                    //var row = dgvIncludeView.Rows[e.RowIndex];

                    // 両方のセルの値を取得して比較
                    if (row.Cells[ComparisonColumnList[index].ColumnA].Value != null && row.Cells[ComparisonColumnList[index].ColumnB].Value != null)
                    {

                        if (row.Cells[ComparisonColumnList[index].ColumnA].Value.ToString() != row.Cells[ComparisonColumnList[index].ColumnB].Value.ToString())
                        {
                            //e.CellStyle.ForeColor = Color.FromArgb(7, 131, 4);
                            //e.CellStyle.ForeColor = Color.FromArgb(85, 137, 31);
                            e.CellStyle.ForeColor = Color.FromArgb(255, 127, 80);
                            e.CellStyle.Font = new Font(dgvIncludeView.Font, FontStyle.Bold);
                        }
                    }
                    else
                    {
                        e.CellStyle.ForeColor = Color.Black;
                        e.CellStyle.Font = new Font(dgvIncludeView.Font, FontStyle.Regular);
                    }
                }
            }

        }

        /// <summary>
        /// セルが描画されなければならないとき
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void dgvIncludeView_CellPainting(object sender, DataGridViewCellPaintingEventArgs e)
        {
            if (e.ColumnIndex != 1)
            {
                return;
            }

            // セルの下側の境界線を「境界線なし」に設定
            e.AdvancedBorderStyle.Bottom = DataGridViewAdvancedCellBorderStyle.None;

            // 1行目や列ヘッダ、行ヘッダの場合は何もしない
            if (e.RowIndex < 1 || e.ColumnIndex < 0)
            {
                return;
            }

            // セルの下側の境界線を「境界線なし」に設定
            //e.AdvancedBorderStyle.Bottom = DataGridViewAdvancedCellBorderStyle.None;

            if (IsTheSameCellValue(e.ColumnIndex, e.RowIndex))
            {
                // セルの上側の境界線を「境界線なし」に設定
                e.AdvancedBorderStyle.Top = DataGridViewAdvancedCellBorderStyle.None;
            }
            else
            {
                // セルの上側の境界線を既定の境界線に設定
                e.AdvancedBorderStyle.Top = dgvIncludeView.AdvancedCellBorderStyle.Top;
            }

        }

        /// <summary>
        /// 値変換設定リストの行の規定値を要求された時
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void dgvValueView_DefaultValuesNeeded(object sender, DataGridViewRowEventArgs e)
        {
            e.Row.Cells["To"].Value = "◀";

            // 入力不可にする
            e.Row.Cells["To"].ReadOnly = true;
        }

        /// <summary>
        /// 「key1」ボタン押下時
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnkey1_Click(object sender, EventArgs e)
        {
            if (dgvDBFNWView.SelectedRows.Count == 0) return;
            var row = dgvDBFNWView.SelectedRows[0];
            if (row == null) return;
            var item = row.DataBoundItem as ConversionFNWDataItem;
            if (item == null) return;

            if (dgvIncludeView.SelectedRows.Count == 0) return;
            var row2 = dgvIncludeView.SelectedRows[0];
            if (row2 == null) return;
            var item2 = row2.DataBoundItem as ConversionDataItem;
            if (item2 == null) return;

            string strkey1 = item2.key1;
            string strINI_SECTION = item.INI_SECTION;


            string msg = CheckINI_SECTION_Using(item.INI_SECTION, item2.key1);
            if (string.IsNullOrEmpty(msg) == false)
            {
                msg = "マッピングできません。" + Environment.NewLine + msg;
                MessageBox.Show(msg, Commons.AppName, MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }

            // マッピングしようとしている、INI_SECTION=key1とINI_KEY=key2の組み合わせが既に使用されているかチェック
            for (int i = 0; i < ConversionFNWDataManager.ConversionFNWDataList.Count; i++)
            {
                ConversionFNWDataItem fnwItem = ConversionFNWDataManager.ConversionFNWDataList[i];

                if (strINI_SECTION != fnwItem.INI_SECTION)
                {
                    continue;
                }

                for (int j = 0; j < ConversionDataManager.ConversionDataList.Count; j++)
                {
                    ConversionDataItem fnsiItem = ConversionDataManager.ConversionDataList[j];

                    // まだkey1解除していないので"key1+key2"の条件が必要、"key1"のデータは解除で消えるので参照しない
                    if (fnsiItem.ConvTarget == "key1+key2" &&
                        fnsiItem.key1 == fnwItem.INI_SECTION &&
                        fnsiItem.key2 == fnwItem.INI_KEY
                        )
                    {
                        msg = "";
                        msg += "マッピングできません。" + Environment.NewLine;
                        msg += "key1:{0}内でkey2:{1}が既に変換対象がkey1+key2でマッピングされています。";
                        msg = string.Format(msg, fnsiItem.key1, fnsiItem.key2);

                        MessageBox.Show(msg, Commons.AppName, MessageBoxButtons.OK, MessageBoxIcon.Error);

                        return;
                    }
                }
            }

            msg = "";
            msg += "下記の設定項目に変換設定を反映します。よろしいですか？" + Environment.NewLine;
            msg += "・FNSiのkey1が{0}の設定項目" + Environment.NewLine;
            msg += "・変換設定がkey1または未マッピングの設定項目";
            msg = string.Format(msg, strkey1);

            DialogResult result = MessageBox.Show(msg, Commons.AppName, MessageBoxButtons.YesNo, MessageBoxIcon.Question, MessageBoxDefaultButton.Button2);
            if (result != DialogResult.Yes)
            {
                // 「はい」以外が選ばれたとき
                return;
            }

            // 設定したいkey1設定が既にあるか？
            bool isInsert = false;
            for (int j = 0; j < ConversionDataManager.ConversionDataList.Count; j++)
            {
                ConversionDataItem fnsiItem = ConversionDataManager.ConversionDataList[j];

                if (fnsiItem.ConvTarget == "key1" &&
                    fnsiItem.key1 == strkey1 && fnsiItem.INI_SECTION == strINI_SECTION)
                {
                    // 既にある
                    isInsert = true;
                    break;
                }
            }

            if (isInsert == false)
            {
                // key1解除処理を実行
                if (string.IsNullOrEmpty(strkey1) == false)
                {
                    key1ReleaseFunc(strkey1);
                }
            }

            // key1マッピングを実行
            Commons.key1Func(strkey1, strINI_SECTION, false, isInsert);

            // FNSiのリスト（左のリスト）を再描画する
            DgvIncludeViewRedraw();
        }

        /// <summary>
        /// 「key1+key2」ボタン押下時
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnkey1key2_Click(object sender, EventArgs e)
        {
            if (dgvDBFNWView.SelectedRows.Count == 0) return;
            var row = dgvDBFNWView.SelectedRows[0];
            if (row == null) return;
            var item = row.DataBoundItem as ConversionFNWDataItem;
            if (item == null) return;

            if (dgvIncludeView.SelectedRows.Count == 0) return;
            var row2 = dgvIncludeView.SelectedRows[0];
            if (row2 == null) return;
            var item2 = row2.DataBoundItem as ConversionDataItem;
            if (item2 == null) return;

            // すでにマッピング済みなら解除してから
            key1key2ReleaseFunc(item2);

            item2.ConvTarget = "key1+key2";
            item2.INI_SECTION = item.INI_SECTION;
            item2.INI_KEY = item.INI_KEY;
            item2.INI_VALUE = item.INI_VALUE;
            item2.DEFAULT_VALUE = item.DEFAULT_VALUE;
            item2.KEY_TITLE = item.KEY_TITLE;
            item2.MEMO = item.MEMO;
            item2.FnwPos = item.FnwPos;
            item2.Is_TempAdd = false;

            Item addItem = new Item();
            addItem.INI_SECTION = item2.INI_SECTION;
            addItem.INI_KEY = item2.INI_KEY;
            addItem.Key1 = item2.key1;
            addItem.Key2 = item2.key2;
            addItem.PublicList = null;
            addItem.LocalList = null;
            MappingSettingManager.AddIndividualItem(addItem);

            // FNWのリストから削除
            ConversionFNWDataManager.ConversionFNWDataList.Remove(item);

            // FNSiのリスト（左のリスト）を再描画する
            DgvIncludeViewRedraw();
        }

        /// <summary>
        /// 「key1解除」ボタン押下時
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnkey1Release_Click(object sender, EventArgs e)
        {
            if (dgvIncludeView.SelectedRows.Count == 0) return;
            var row2 = dgvIncludeView.SelectedRows[0];
            if (row2 == null) return;
            var item2 = row2.DataBoundItem as ConversionDataItem;
            if (item2 == null) return;

            if (string.IsNullOrEmpty(item2.key1) == true) return;
            string strkey1 = item2.key1;

            key1ReleaseFunc(strkey1);

            // FNSiのリスト（左のリスト）を再描画する
            DgvIncludeViewRedraw();
        }

        /// <summary>
        /// key1解除処理
        /// </summary>
        /// <param name="key1"></param>
        private void key1ReleaseFunc(string key1)
        {
            int j;
            for (j = ConversionDataManager.ConversionDataList.Count - 1; j >= 0; j--)
            {
                if (ConversionDataManager.ConversionDataList[j].key1 == key1 &&
                    ConversionDataManager.ConversionDataList[j].ConvTarget == "key1"
                    )
                {
                    key1key2ReleaseFunc(ConversionDataManager.ConversionDataList[j]);
                }
            }

        }

        /// <summary>
        /// 「key1+key2解除」ボタン押下時
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnkey1key2Release_Click(object sender, EventArgs e)
        {
            if (dgvIncludeView.SelectedRows.Count == 0) return;
            var row2 = dgvIncludeView.SelectedRows[0];
            if (row2 == null) return;
            var item2 = row2.DataBoundItem as ConversionDataItem;
            if (item2 == null) return;

            key1key2ReleaseFunc(item2);

            // FNSiのリスト（左のリスト）を再描画する
            DgvIncludeViewRedraw();
        }

        /// <summary>
        /// FNSiのリスト（左のリスト）を再描画する
        /// </summary>
        private void DgvIncludeViewRedraw()
        {
            // 現在のスクロール位置を記憶
            int firstDisplayedRowIndex = dgvIncludeView.FirstDisplayedScrollingRowIndex;
            // sourceから再描画
            sourceConversion.ResetBindings(false);
            // スクロール位置をもどす
            if (firstDisplayedRowIndex >= 0 && firstDisplayedRowIndex < dgvIncludeView.Rows.Count)
            {
                dgvIncludeView.FirstDisplayedScrollingRowIndex = firstDisplayedRowIndex;
            }
        }

        /// <summary>
        /// key1+key2解除処理
        /// </summary>
        /// <param name="item"></param>
        private void key1key2ReleaseFunc(ConversionDataItem item)
        {
            if (string.IsNullOrEmpty(item.ConvTarget) == true) return;

            // FNWのリストに項目を戻す
            bool isInsert = false;
            for (int i = 0; i < ConversionFNWDataManager.ConversionFNWDataList.Count; i++)
            {
                if (ConversionFNWDataManager.ConversionFNWDataList[i].FnwPos > item.FnwPos)
                {
                    FNWDataItem row = FNWDataManager.FNWDataList[item.FnwPos];
                    ConversionFNWDataItem addData = new ConversionFNWDataItem();
                    addData.INI_SECTION = row.INI_SECTION;
                    addData.INI_KEY = row.INI_KEY;
                    addData.INI_VALUE = row.INI_VALUE;
                    addData.DEFAULT_VALUE = row.DEFAULT_VALUE;
                    addData.KEY_TITLE = row.KEY_TITLE;
                    addData.MEMO = row.MEMO;
                    addData.FnwPos = item.FnwPos;
                    ConversionFNWDataManager.ConversionFNWDataList.Insert(i, addData);
                    isInsert = true;
                    break;
                }
            }
            if (isInsert == false)
            {
                // 0件の場合、最後に追加する場合
                FNWDataItem row = FNWDataManager.FNWDataList[item.FnwPos];
                ConversionFNWDataItem addData = new ConversionFNWDataItem();
                addData.INI_SECTION = row.INI_SECTION;
                addData.INI_KEY = row.INI_KEY;
                addData.INI_VALUE = row.INI_VALUE;
                addData.DEFAULT_VALUE = row.DEFAULT_VALUE;
                addData.KEY_TITLE = row.KEY_TITLE;
                addData.MEMO = row.MEMO;
                addData.FnwPos = item.FnwPos;
                ConversionFNWDataManager.ConversionFNWDataList.Add(addData);
            }


            if (item.ConvTarget == "key1")
            {
                // 削除対象以外に同じINI_SECTIONをもつkey1が存在するかチェック
                int cnt = 0;
                for (int i = 0; i < ConversionDataManager.ConversionDataList.Count; i++)
                {
                    if (ConversionDataManager.ConversionDataList[i].ConvTarget == "key1" &&
                        ConversionDataManager.ConversionDataList[i].INI_SECTION == item.INI_SECTION)
                    {
                        cnt++;
                    }
                }

                if (cnt == 1)
                {
                    // 自分自身しかいない場合はSection値変換設定を削除
                    MappingSettingManager.DeleteSectionItem(item.INI_SECTION);
                }
            }
            else
            {
                // Individual値変換設定を削除
                MappingSettingManager.DeletIndividualItem(item.INI_SECTION, item.INI_KEY);
            }

            // FNSIのリストの項目を削除
            if (item.Is_TempAdd == true)
            {
                ConversionDataManager.ConversionDataList.Remove(item);
            }
            else
            {
                item.ConvTarget = "";
                item.INI_SECTION = "";
                item.INI_KEY = "";
                item.INI_VALUE = "";
                item.DEFAULT_VALUE = "";
                item.KEY_TITLE = "";
                item.MEMO = "";
                item.FnwPos = -1;
                item.Is_TempAdd = false;
            }
        }

        /// <summary>
        /// FNSiのリストの選択項目が変更された時
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void dgvIncludeView_SelectionChanged(object sender, EventArgs e)
        {
            SetConvSettings();

        }

        /// <summary>
        /// FNSiのリストの選択項目の変換設定を表示する
        /// </summary>
        private void SetConvSettings()
        {
            if (dgvIncludeView.SelectedRows.Count == 0) return;
            var row2 = dgvIncludeView.SelectedRows[0];
            if (row2 == null) return;
            var item2 = row2.DataBoundItem as ConversionDataItem;
            if (item2 == null) return;

            // 描画を一時停止
            this.SuspendLayout();

            try
            {
                if (item2.ConvTarget == "key1")
                {
                    // 変換対象がkey1の項目が選択された

                    // 現在選択されている変換設定を取得
                    CurrentItem = MappingSettingManager.GetSectionItem(item2.INI_SECTION);
                    //CurrentValueMapping = CurrentItem.LocalList[0];

                    // 「FNW設定」タブ内のコントロールの制御
                    btnkey1Release.Enabled = true;
                    btnkey1key2Release.Enabled = true;

                    if (item2.Is_TempAdd == true)
                    {
                        btnkey1key2.Enabled = false;

                        // 「変換設定」タブ内のコントロールの制御
                        groupBox1.Enabled = false;
                        groupBox2.Enabled = false;
                        //btnConvTargetChange.Enabled = false;
                        //btnAllConvTargetChange.Enabled = false;
                    }
                    else
                    {
                        btnkey1key2.Enabled = true;

                        // 「変換設定」タブ内のコントロールの制御
                        groupBox1.Enabled = true;
                        groupBox2.Enabled = true;
                        //btnConvTargetChange.Enabled = true;
                        //btnAllConvTargetChange.Enabled = true;
                    }
                    label7.Text = "変換対象を[key1+key2]に変更する";
                    label8.Text = "同一key1、INI_SECTIONの変換対象を[key1+key2]に変更する";

                    tableLayoutPanel1.Visible = true;
                    tableLayoutPanel2.Visible = false;
                    groupBox3.Visible = true;

                }
                else if (item2.ConvTarget == "key1+key2")
                {
                    // 変換対象がkey1+key2の項目が選択された

                    // 現在選択されている変換設定を取得
                    CurrentItem = MappingSettingManager.GetIndividualItem(item2.INI_SECTION, item2.INI_KEY);

                    // 「FNW設定」タブ内のコントロールの制御
                    btnkey1Release.Enabled = false;
                    btnkey1key2Release.Enabled = true;
                    btnkey1key2.Enabled = true;

                    // 「変換設定」タブ内のコントロールの制御
                    groupBox1.Enabled = true;
                    groupBox2.Enabled = true;
                    //btnConvTargetChange.Enabled = true;
                    //btnAllConvTargetChange.Enabled = true;
                    label7.Text = "変換対象を[key1]に変更する";
                    label8.Text = "同一key1、INI_SECTIONの変換対象を[key1]に変更する";

                    tableLayoutPanel1.Visible = true;
                    tableLayoutPanel2.Visible = true;
                    groupBox3.Visible = true;

                }
                else
                {
                    // 変換対象がブランクの項目（マッチングしていない項目）が選択された

                    CurrentItem = null;

                    // 「FNW設定」タブ内のコントロールの制御
                    btnkey1Release.Enabled = false;
                    btnkey1key2Release.Enabled = false;
                    btnkey1key2.Enabled = true;

                    // 「変換設定」タブ内のコントロールの制御
                    groupBox1.Enabled = false;
                    groupBox2.Enabled = false;
                    //btnConvTargetChange.Enabled = false;
                    //btnAllConvTargetChange.Enabled = false;
                    label7.Text = "";
                    label8.Text = "";

                    tableLayoutPanel1.Visible = false;
                    tableLayoutPanel2.Visible = false;
                    groupBox3.Visible = false;

                }

                List<string> PublicNameList = new List<string>();
                PublicNameList.Add("");

                var publicValueMappingList = MappingSettingManager.GetPublicValueMappingList();

                if (publicValueMappingList != null)
                {
                    foreach (var item in publicValueMappingList)
                    {
                        PublicNameList.Add(item.Name);
                    }
                }

                cmbPublicList.DataSource = PublicNameList;


                if (CurrentItem == null)
                {
                    textBox2.Text = "";
                    textBox1.Text = "";
                    textBox3.Text = "";
                    textBox4.Text = "";

                    cmbPublicList.Text = "";

                    rdoTypeExactmatch.Checked = true;
                    rdoTypePartialmatch.Checked = false;

                    if (ValueDataList != null) ValueDataList.Clear();
                }
                else
                {
                    textBox2.Text = CurrentItem.INI_SECTION;
                    textBox1.Text = CurrentItem.Key1;
                    textBox3.Text = CurrentItem.INI_KEY;
                    textBox4.Text = CurrentItem.Key2;

                    cmbPublicList.Text = CurrentItem.PublicList;

                    if (CurrentItem.LocalList == null || CurrentItem.LocalList.Count == 0)
                    {
                        rdoTypeExactmatch.Checked = true;
                        rdoTypePartialmatch.Checked = false;

                        if (ValueDataList != null) ValueDataList.Clear();
                    }
                    else
                    {
                        if (CurrentItem.LocalList[0].Type != "1")
                        {
                            rdoTypeExactmatch.Checked = true;
                            rdoTypePartialmatch.Checked = false;
                        }
                        else
                        {
                            rdoTypeExactmatch.Checked = false;
                            rdoTypePartialmatch.Checked = true;
                        }

                        if (ValueDataList != null) ValueDataList.Clear();
                        if (CurrentItem.LocalList[0].ValueList != null)
                        {
                            for (int i = 0; i < CurrentItem.LocalList[0].ValueList.Count; i++)
                            {
                                ValueItem addItem = new ValueItem();
                                addItem.Before = CurrentItem.LocalList[0].ValueList[i].Before;
                                addItem.After = CurrentItem.LocalList[0].ValueList[i].After;
                                addItem.To = "◀";
                                ValueDataList.Add(addItem);
                            }
                        }
                    }
                }

            }
            finally
            {
                // 描画再開
                this.ResumeLayout();
            }

        }

        /// <summary>
        /// 「終了」ボタン押下時
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnEnd_Click(object sender, EventArgs e)
        {
            isClosingByButton = true;
            this.DialogResult = DialogResult.OK;
            this.Close();
        }

        /// <summary>
        /// 「戻る」ボタン押下時
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnBack_Click(object sender, EventArgs e)
        {
            isClosingByButton = true;
            this.DialogResult = DialogResult.Cancel;
            this.Close();
        }

        /// <summary>
        /// 「変換対象変更」ボタン押下
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnConvTargetChange_Click(object sender, EventArgs e)
        {
            if (dgvIncludeView.SelectedRows.Count == 0) return;
            var row2 = dgvIncludeView.SelectedRows[0];
            if (row2 == null) return;
            var item2 = row2.DataBoundItem as ConversionDataItem;
            if (item2 == null) return;


            if (item2.ConvTarget == "key1")
            {
                // 現在選択されている変換設定を取得
                Item wkItem = MappingSettingManager.GetSectionItem(item2.INI_SECTION);
                Item addItem = wkItem.Clone();
                addItem.INI_KEY = item2.INI_KEY;
                addItem.Key2 = item2.key2;
                MappingSettingManager.AddIndividualItem(addItem);

                // 削除対象以外に同じINI_SECTIONをもつkey1が存在するかチェック
                int cnt = 0;
                for (int i = 0; i < ConversionDataManager.ConversionDataList.Count; i++)
                {
                    if (ConversionDataManager.ConversionDataList[i].ConvTarget == "key1" &&
                        ConversionDataManager.ConversionDataList[i].INI_SECTION == item2.INI_SECTION)
                    {
                        cnt++;
                    }
                }

                if (cnt == 1)
                {
                    // 自分自身しかいない場合はSection値変換設定を削除
                    MappingSettingManager.DeleteSectionItem(item2.INI_SECTION);
                }

                item2.ConvTarget = "key1+key2";
            }
            else if (item2.ConvTarget == "key1+key2")
            {
                string msg = CheckINI_SECTION_Using(item2.INI_SECTION, item2.key1);
                if (string.IsNullOrEmpty(msg) == false)
                {
                    msg = "変換対象を変更できません。" + Environment.NewLine + msg;
                    MessageBox.Show(msg, Commons.AppName, MessageBoxButtons.OK, MessageBoxIcon.Error);
                    return;
                }

                // すでにINI_SECTIONがkey1として登録されていたらその変換設定を取得する
                Item wkItem = MappingSettingManager.GetSectionItem(item2.INI_SECTION);

                if (wkItem == null)
                {
                    // nullの場合は同じINI_SECTIONのレコードが存在しない（初めてこのINI_SECTIONをkey1にした）

                    Item iudItem = MappingSettingManager.GetIndividualItem(item2.INI_SECTION, item2.INI_KEY);
                    Item addItem = iudItem.Clone();
                    addItem.INI_SECTION = item2.INI_SECTION;
                    addItem.INI_KEY = null;
                    addItem.Key1 = item2.key1;
                    addItem.Key2 = null;
                    MappingSettingManager.AddSectionItem(addItem);
                }

                // Individual値変換設定を削除
                MappingSettingManager.DeletIndividualItem(item2.INI_SECTION, item2.INI_KEY);

                item2.ConvTarget = "key1";
            }

            // FNSiのリスト（左のリスト）を再描画する
            DgvIncludeViewRedraw();
        }

        /// <summary>
        /// FNSiのリストの項目をダブルクリック時
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void dgvIncludeView_CellDoubleClick(object sender, DataGridViewCellEventArgs e)
        {
            if (e.RowIndex >= 0)
            {
                var row = dgvIncludeView.Rows[e.RowIndex];
                if (row == null) return;
                var item = row.DataBoundItem as ConversionDataItem;
                if (item == null) return;

                // 選択されたkey1を取得
                string key1 = item.key1;

                int startIndex = 0;
                if (dgvDBFNWView.SelectedRows.Count > 0)
                {
                    var row2 = dgvDBFNWView.SelectedRows[0];
                    startIndex = row2.Index;
                }

                int fnwIndex = -1;
                for (int i = startIndex + 1; i < dgvDBFNWView.Rows.Count; i++)
                {
                    var rowFNW = dgvDBFNWView.Rows[i];
                    if (rowFNW == null) continue;
                    var itemFNW = rowFNW.DataBoundItem as ConversionFNWDataItem;
                    if (itemFNW == null) continue;

                    if (key1 == itemFNW.INI_SECTION)
                    {
                        fnwIndex = i;
                        break;
                    }
                }

                if (fnwIndex == -1)
                {
                    // 現在の選択位置から下に探しに行ったけど見つからなかったので先頭から現在の位置までを探す
                    for (int i = 0; i < startIndex; i++)
                    {
                        var rowFNW = dgvDBFNWView.Rows[i];
                        if (rowFNW == null) continue;
                        var itemFNW = rowFNW.DataBoundItem as ConversionFNWDataItem;
                        if (itemFNW == null) continue;

                        if (key1 == itemFNW.INI_SECTION)
                        {
                            fnwIndex = i;
                            break;
                        }
                    }
                }

                if (fnwIndex >= 0)
                {
                    var rowFNW = dgvDBFNWView.Rows[fnwIndex];
                    if (rowFNW == null) return;

                    rowFNW.Selected = true;

                    // スクロールして表示
                    dgvDBFNWView.FirstDisplayedScrollingRowIndex = rowFNW.Index;

                    // フォーカスも移す（任意）
                    dgvDBFNWView.CurrentCell = rowFNW.Cells[0];
                }

            }
        }

        /// <summary>
        /// 「共通値変換設定登録」ボタン押下時
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnCommonConversion_Click(object sender, EventArgs e)
        {

            FormCommonConversion form = new FormCommonConversion();
            form.ShowDialog();
            form.Dispose();

            SetConvSettings();
        }

        /// <summary>
        /// 「FNSiカルテ種別出力」ボタン押下時
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnXMLWrite_Click(object sender, EventArgs e)
        {
            string strXMLPath;

            if (ConfigSettingManager.Data.ConversionDefinition == ConversionDefinitionType.OverwriteDefaultDefinition)
            {
                // デフォルト定義ファイルを修正

                var result = MessageBox.Show("デフォルト定義ファイルを上書きしますか？", Commons.AppName, MessageBoxButtons.YesNo, MessageBoxIcon.Question, MessageBoxDefaultButton.Button2);
                if (result != DialogResult.Yes)
                {
                    // 「はい」以外が選ばれたとき
                    return;
                }

                string strExeDir = AppDomain.CurrentDomain.BaseDirectory;
                strXMLPath = Path.Combine(strExeDir, "DefaultDefinition.xml");
            }
            else
            {

                SaveFileDialog saveFileDialog = new SaveFileDialog();
                // フィルター（保存できるファイルの種類）
                saveFileDialog.Filter = "XMLファイル (*.xml)|*.xml|すべてのファイル (*.*)|*.*";

                if (ConfigSettingManager.Data.ConversionDefinition == ConversionDefinitionType.FromDefinition)
                {
                    // デフォルト定義ファイルからXMLを新規作成

                    // デフォルトのファイル名
                    string wkFileName = "";
                    foreach (JSONDataItem row in JSONDataManager.JSONDataList)
                    {
                        wkFileName = row.key0;
                        break; // 最初の一件だけ
                    }
                    saveFileDialog.FileName = wkFileName;
                    // 初期フォルダ
                    saveFileDialog.InitialDirectory = Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments);
                }
                else
                {
                    // XMLを再編集

                    // 初期フォルダ
                    saveFileDialog.InitialDirectory = Path.GetDirectoryName(ConfigSettingManager.Data.XMLReeditFilePath);

                    // デフォルトのファイル名
                    saveFileDialog.FileName = Path.GetFileName(ConfigSettingManager.Data.XMLReeditFilePath);
                }

                // ダイアログを表示
                if (saveFileDialog.ShowDialog() != DialogResult.OK)
                {
                    return;
                }
                strXMLPath = saveFileDialog.FileName;
            }

            // ------------------------------------
            // 除外設定をセットする
            // ------------------------------------
            MappingSettingManager.InitializationExclude();
            for (int i = 0; i < dgvDBFNWView.Rows.Count; i++)
            {
                var rowFNW = dgvDBFNWView.Rows[i];
                if (rowFNW == null) continue;
                var itemFNW = rowFNW.DataBoundItem as ConversionFNWDataItem;
                if (itemFNW == null) continue;

                Item addItem = new Item();
                addItem.INI_SECTION = itemFNW.INI_SECTION;
                addItem.INI_KEY = itemFNW.INI_KEY;
                addItem.Key1 = null;
                addItem.Key2 = null;
                addItem.PublicList = null;
                addItem.LocalList = null;
                MappingSettingManager.AddExcludeIndividualItem(addItem);
            }

            // Key1とKwy2が同じならINI_SECTIONとINI_KEYにNULLをセットする
            MappingSettingManager.SetKeyNull(true, false);

            // ------------------------------------
            // XMLファイルを出力
            // ------------------------------------
            try
            {
                if (MappingSettingManager.WriteXML(strXMLPath) == Commons.RetCode_Error)
                {
                    MessageBox.Show("XMLファイルの書き込みに失敗しました。", Commons.AppName, MessageBoxButtons.OK, MessageBoxIcon.Error);
                    return;
                }
            }
            finally
            {
                // Key1とKwy2にNULLならINI_SECTIONとINI_KEYから値をコピーする
                MappingSettingManager.SetKeyNull(false, false);
            }

            if (ConfigSettingManager.Data.ConversionDefinition == ConversionDefinitionType.OverwriteDefaultDefinition)
            {
                // デフォルト定義ファイルを修正
                MessageBox.Show("デフォルト定義ファイルを更新しました。", Commons.AppName, MessageBoxButtons.OK, MessageBoxIcon.Information);
            }
        }

        /// <summary>
        /// 値変換設定リストのセルの編集完了したとき
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void dgvValueView_CellEndEdit(object sender, DataGridViewCellEventArgs e)
        {
            CheckValueView();
        }

        /// <summary>
        /// 値変換設定リストの検証中
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void dgvValueView_Validating(object sender, CancelEventArgs e)
        {
            if (isClosingByButton == true)
            {
                return;
            }

            if (isValueError == true)
            {
                MessageBox.Show("FNWの値が重複しています。", Commons.AppName, MessageBoxButtons.OK, MessageBoxIcon.Error);

                e.Cancel = true; // フォーカス移動をキャンセル

                return;
            }

            SetLocalList();


        }

        /// <summary>
        /// ウィンドウメッセージのコールバック
        /// </summary>
        /// <param name="m"></param>
        protected override void WndProc(ref Message m)
        {
            // 画面終了のメッセージが届いた時、Validatingが走行しないようにする
            const int WM_SYSCOMMAND = 0x112;
            const int SC_CLOSE = 0xF060;

            if (m.Msg == WM_SYSCOMMAND && m.WParam.ToInt32() == SC_CLOSE)
            {
                this.AutoValidate = AutoValidate.Disable;
            }

            base.WndProc(ref m);
        }

        /// <summary>
        /// 個別値変換設定名のデータを保存する
        /// </summary>
        private void SetLocalList()
        {
            if (CurrentItem == null) return;

            if (string.IsNullOrEmpty(cmbPublicList.Text) == false)
            {
                CurrentItem.PublicList = cmbPublicList.Text;
            }
            else
            {
                CurrentItem.PublicList = null;
            }


            if (ValueDataList.Count > 0)
            {
                CurrentValueMapping = new ValueMappingList();

                if (rdoTypePartialmatch.Checked == true)
                {
                    CurrentValueMapping.Type = "1";
                }
                else
                {
                    CurrentValueMapping.Type = "0";
                }

                CurrentValueMapping.ValueList = new List<ValueMappingListItem>();
                for (int i = 0; i < ValueDataList.Count; i++)
                {
                    ValueMappingListItem valueMappingListItem = new ValueMappingListItem();
                    if (ValueDataList[i].Before == null)
                    {
                        // XMLを出力したときにタグが出力されるようにブランクを入れておく
                        valueMappingListItem.Before = "";
                    }
                    else
                    {
                        valueMappingListItem.Before = ValueDataList[i].Before;
                    }
                    if (ValueDataList[i].After == null)
                    {
                        // XMLを出力したときにタグが出力されるようにブランクを入れておく
                        valueMappingListItem.After = "";
                    }
                    else
                    {
                        valueMappingListItem.After = ValueDataList[i].After;
                    }
                    CurrentValueMapping.ValueList.Add(valueMappingListItem);
                }

                CurrentItem.LocalList = new List<ValueMappingList>();
                CurrentItem.LocalList.Add(CurrentValueMapping);
            }
            else
            {
                CurrentItem.LocalList = null;
            }

        }

        /// <summary>
        /// 変換タイプのラジオボタンの検証中
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void rdoType_Validating(object sender, CancelEventArgs e)
        {
            SetLocalList();
        }

        /// <summary>
        /// 値変換設定リストの内容をクリックしたとき
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void dgvValueView_CellContentClick(object sender, DataGridViewCellEventArgs e)
        {
            // ヘッダー行や無効なセルは無視
            if (e.RowIndex < 0 || e.ColumnIndex < 0) return;

            // 削除ボタンの列かどうかを確認
            if (dgvValueView.Columns[e.ColumnIndex].Name == "Trash")
            {
                var row = dgvValueView.Rows[e.RowIndex];
                if (row.IsNewRow) return;

                dgvValueView.Rows.RemoveAt(e.RowIndex);
            }
        }

        /// <summary>
        /// 値変換設定リストの行削除（DELキー押下）
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void dgvValueView_RowsRemoved(object sender, DataGridViewRowsRemovedEventArgs e)
        {
            CheckValueView();
        }

        /// <summary>
        /// 値の変換設定のDataGridViewの入力内容をチェックする
        /// </summary>
        private void CheckValueView()
        {
            isValueError = false;

            var duplicateKeys = ValueDataList.GroupBy(item => item.Before)
                                .Where(g => g.Count() > 1)
                                .Select(g => g.Key)
                                .ToList();


            for (int i = 0; i < dgvValueView.Rows.Count; i++)
            {
                var row = dgvValueView.Rows[i];
                if (row.IsNewRow) continue;

                var item = (ValueItem)row.DataBoundItem;
                if (duplicateKeys.Contains(item.Before))
                {
                    row.Cells["Before"].ErrorText = "FNWの値が重複しています";
                    isValueError = true;
                }
                else
                {
                    row.Cells["Before"].ErrorText = "";
                }
            }
        }

        /// <summary>
        /// 「まとめて変換対象変更」ボタン押下
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnAllConvTargetChange_Click(object sender, EventArgs e)
        {
            if (dgvIncludeView.SelectedRows.Count == 0) return;
            var row2 = dgvIncludeView.SelectedRows[0];
            if (row2 == null) return;
            var item2 = row2.DataBoundItem as ConversionDataItem;
            if (item2 == null) return;

            string strINI_SECTION = item2.INI_SECTION;
            string strkey1 = item2.key1;

            if (item2.ConvTarget == "key1")
            {
                // key1+key2へまとめて変換

                string msg = "";
                msg += "下記の設定項目の変換対象をまとめてkey1+key2に変更します。よろしいですか？" + Environment.NewLine;
                msg += "・FNSiのkey1が{0}の設定項目" + Environment.NewLine;
                msg += "・変換設定がkey1の設定項目（新規追加行は除く）";
                msg = string.Format(msg, strkey1);

                DialogResult result = MessageBox.Show(msg, Commons.AppName, MessageBoxButtons.YesNo, MessageBoxIcon.Question, MessageBoxDefaultButton.Button2);
                if (result != DialogResult.Yes)
                {
                    // 「はい」以外が選ばれたとき
                    return;
                }

                // 現在選択されている変換設定を取得
                Item wkItem = MappingSettingManager.GetSectionItem(item2.INI_SECTION);

                for (int i = 0; i < ConversionDataManager.ConversionDataList.Count; i++)
                {
                    var wkConvItem = ConversionDataManager.ConversionDataList[i];

                    if (wkConvItem.ConvTarget != "key1" || wkConvItem.Is_TempAdd == true ||
                        strINI_SECTION != wkConvItem.INI_SECTION || strkey1 != wkConvItem.key1)
                    {
                        // 変換対象ではない場合は次へ
                        continue;
                    }

                    wkConvItem.ConvTarget = "key1+key2";

                    Item addItem = wkItem.Clone();
                    addItem.INI_KEY = wkConvItem.INI_KEY;
                    addItem.Key2 = wkConvItem.key2;
                    // Individual値変換設定を追加
                    MappingSettingManager.AddIndividualItem(addItem);
                }

                // 削除対象以外に同じINI_SECTIONをもつkey1が存在するかチェック
                // 新規追加行は変換されないのでkey1で残っている可能性があるため
                int cnt = 0;
                for (int i = 0; i < ConversionDataManager.ConversionDataList.Count; i++)
                {
                    if (ConversionDataManager.ConversionDataList[i].ConvTarget == "key1" &&
                        ConversionDataManager.ConversionDataList[i].INI_SECTION == strINI_SECTION)
                    {
                        cnt++;
                    }
                }

                if (cnt == 0)
                {
                    // INI_SECTIONが使われていない場合はSection値変換設定を削除
                    MappingSettingManager.DeleteSectionItem(strINI_SECTION);
                }

            }
            else if (item2.ConvTarget == "key1+key2")
            {
                // key1へまとめて変換

                string msg = CheckINI_SECTION_Using(item2.INI_SECTION, item2.key1);
                if (string.IsNullOrEmpty(msg) == false)
                {
                    msg = "変換対象を変更できません。" + Environment.NewLine + msg;
                    MessageBox.Show(msg, Commons.AppName, MessageBoxButtons.OK, MessageBoxIcon.Error);
                    return;
                }

                msg = "";
                msg += "下記の設定項目の変換対象をまとめてkey1に変更します。よろしいですか？" + Environment.NewLine;
                msg += "・FNSiのkey1が{0}の設定項目" + Environment.NewLine;
                msg += "・変換設定がkey1+key2の設定項目";
                msg = string.Format(msg, strkey1);

                DialogResult result = MessageBox.Show(msg, Commons.AppName, MessageBoxButtons.YesNo, MessageBoxIcon.Question, MessageBoxDefaultButton.Button2);
                if (result != DialogResult.Yes)
                {
                    // 「はい」以外が選ばれたとき
                    return;
                }

                // すでにINI_SECTIONがkey1として登録されていたらその変換設定を取得する
                Item wkItem = MappingSettingManager.GetSectionItem(item2.INI_SECTION);

                if (wkItem == null)
                {
                    // nullの場合は同じINI_SECTIONのレコードが存在しない（初めてこのINI_SECTIONをkey1にした）
                    Item iudItem = MappingSettingManager.GetIndividualItem(item2.INI_SECTION, item2.INI_KEY);
                    Item addItem = iudItem.Clone();
                    addItem.INI_SECTION = item2.INI_SECTION;
                    addItem.INI_KEY = null;
                    addItem.Key1 = item2.key1;
                    addItem.Key2 = null;
                    MappingSettingManager.AddSectionItem(addItem);
                }

                for (int i = 0; i < ConversionDataManager.ConversionDataList.Count; i++)
                {
                    var wkConvItem = ConversionDataManager.ConversionDataList[i];

                    if (wkConvItem.ConvTarget != "key1+key2" || strINI_SECTION != wkConvItem.INI_SECTION || strkey1 != wkConvItem.key1)
                    {
                        // 変換対象ではない場合は次へ
                        continue;
                    }

                    wkConvItem.ConvTarget = "key1";

                    // Individual値変換設定を削除
                    MappingSettingManager.DeletIndividualItem(wkConvItem.INI_SECTION, wkConvItem.INI_KEY);
                }
            }

            // FNSiのリスト（左のリスト）を再描画する
            DgvIncludeViewRedraw();
        }

        /// <summary>
        /// 変換対象key1でINI_SECTIONが別のkey1で使用しているかチェックする
        /// </summary>
        /// <param name="INI_SECTION">設定の対象</param>
        /// <param name="key1">設定の対象、これ以外のkey1で使用しているかのチェック</param>
        /// <returns></returns>
        private string CheckINI_SECTION_Using(string INI_SECTION, string key1)
        {
            string ret = "";

            for (int i = 0; i < ConversionDataManager.ConversionDataList.Count; i++)
            {
                var wkConvItem = ConversionDataManager.ConversionDataList[i];

                if (wkConvItem.ConvTarget == "key1" && INI_SECTION == wkConvItem.INI_SECTION && key1 != wkConvItem.key1)
                {
                    // 別のkey1でINI_SECTIONを既に使用している
                    ret = "INI_SECTION:{0}はkey1:{1}に既に変換対象がkey1でマッピングされています。";
                    ret = string.Format(ret, INI_SECTION, wkConvItem.key1);
                    return ret;
                }
            }

            return ret;
        }

        /// <summary>
        /// 共通変換設定名ドロップダウンリストの検証中
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void cmbPublicList_Validating(object sender, CancelEventArgs e)
        {
            SetLocalList();
        }
    }
}
