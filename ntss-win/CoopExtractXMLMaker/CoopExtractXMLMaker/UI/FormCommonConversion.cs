using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Linq;
using System.Windows.Forms;

namespace CoopExtractXMLMaker
{
    public partial class FormCommonConversion : Form
    {
        /// <summary>
        /// 共通値変換設定名リスト
        /// </summary>
        public class NameItem
        {
            [DisplayName("共通値変換設定名")]
            public string Name { get; set; }

            [Browsable(false)]
            public ValueMappingList valueMappingList { get; set; }
        }

        // 共通値変換設定名リスト実体
        private BindingList<NameItem> NameDataList;

        /// <summary>
        /// 値変換設定リスト
        /// </summary>
        public class ValueItem
        {
            [DisplayName("FNSi")]
            public string After { get; set; }

            [DisplayName("")]
            public string To { get; set; }

            [DisplayName("FNW")]
            public string Before { get; set; }
        }

        // 値変換設定実体
        private BindingList<ValueItem> ValueDataList;

        /// <summary>
        /// 現在選択されている変換設定
        /// </summary>
        NameItem CurrentItem;
        ValueMappingList CurrentValueMapping;

        /// <summary>
        /// 「共通値変換設定名が重複しています。」のエラー発生中
        /// </summary>
        private bool isNameError_Duplicate = false;

        /// <summary>
        /// 「共通値変換設定名が未入力です。」のエラー発生中
        /// </summary>
        private bool isNameError_Null = false;

        /// <summary>
        /// 値変換設定リストのエラー発生中
        /// </summary>
        private bool isValueError = false;

        /// <summary>
        /// コンストラクタ
        /// </summary>
        public FormCommonConversion()
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
        private void FormCommonConversion_Load(object sender, EventArgs e)
        {

            NameDataList = new BindingList<NameItem>();

            // 共通値変換設定を取得する
            var publicValueMappingList = MappingSettingManager.GetPublicValueMappingList();

            if (publicValueMappingList != null)
            {
                foreach (var item in publicValueMappingList)
                {
                    NameItem addItem = new NameItem();
                    addItem.Name = item.Name;
                    addItem.valueMappingList = item;
                    NameDataList.Add(addItem);
                }
            }


            // -------------------------------------
            // 値変換設定のリストを用意する（共通変換設定より先）
            // -------------------------------------
            ValueDataList = new BindingList<ValueItem>();

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

            // 完全一致にチェックを付けておく
            rdoTypeExactmatch.Checked = true;


            // -------------------------------------
            // 共通変換設定のリストを用意する
            // -------------------------------------
            dgvNameView.RowTemplate.Height = 20;

            BindingSource source1 = new BindingSource();
            source1.DataSource = NameDataList;
            dgvNameView.DataSource = source1;

            DataGridViewButtonColumn column1 = new DataGridViewButtonColumn();
            //列の名前を設定
            column1.Name = "Trash";
            column1.HeaderText = "";
            column1.UseColumnTextForButtonValue = true;
            column1.Text = "del";
            //DataGridViewに追加する
            dgvNameView.Columns.Add(column1);

            dgvNameView.Columns["Name"].Width = 250;
            dgvNameView.Columns["Trash"].Width = 30;

            // 行ヘッダの幅を設定
            dgvNameView.RowHeadersWidth = 28;
            // 列ヘッダの文字列の折り返しを無効にする
            dgvNameView.ColumnHeadersDefaultCellStyle.WrapMode = DataGridViewTriState.False;

            SetValueSettings();
        }

        /// <summary>
        /// 値変換設定の行の規定値を要求された時
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
        /// 閉じるボタン押下時
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnClose_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        /// <summary>
        /// 共通変換設定名リストの選択行が変更されたとき
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void dgvNameView_SelectionChanged(object sender, EventArgs e)
        {
            SetValueSettings();
        }

        /// <summary>
        /// 値変換設定の表示を更新
        /// </summary>
        private void SetValueSettings()
        {
            bool isViewSetting = true;
            DataGridViewRow row2 = null;
            NameItem item2 = null;
            if (dgvNameView.SelectedRows.Count == 0) isViewSetting = false;
            if (isViewSetting == true)
            {
                row2 = dgvNameView.SelectedRows[0];
            }
            if (row2 == null) isViewSetting = false;
            if (isViewSetting == true)
            {
                item2 = row2.DataBoundItem as NameItem;
            }
            if (item2 == null) isViewSetting = false;

            if (isViewSetting == false)
            {
                groupBox1.Enabled = false;
                rdoTypeExactmatch.Checked = true;
                rdoTypePartialmatch.Checked = false;
                if (ValueDataList != null) ValueDataList.Clear();
                return;
            }


            // 描画を一時停止
            this.SuspendLayout();
            try
            {
                groupBox1.Enabled = true;


                CurrentItem = item2;
                CurrentValueMapping = item2.valueMappingList;

                if (CurrentValueMapping == null)
                {
                    rdoTypeExactmatch.Checked = true;
                    rdoTypePartialmatch.Checked = false;

                    if (ValueDataList != null) ValueDataList.Clear();
                }
                else
                {
                    if (CurrentValueMapping.Type != "1")
                    {
                        // 完全一致
                        rdoTypeExactmatch.Checked = true;
                        rdoTypePartialmatch.Checked = false;
                    }
                    else
                    {
                        // 部分一致
                        rdoTypeExactmatch.Checked = false;
                        rdoTypePartialmatch.Checked = true;
                    }

                    if (ValueDataList != null) ValueDataList.Clear();
                    if (CurrentValueMapping.ValueList != null)
                    {
                        for (int i = 0; i < CurrentValueMapping.ValueList.Count; i++)
                        {
                            ValueItem addItem = new ValueItem();
                            addItem.Before = CurrentValueMapping.ValueList[i].Before;
                            addItem.After = CurrentValueMapping.ValueList[i].After;
                            addItem.To = "◀";
                            ValueDataList.Add(addItem);
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
        /// 共通変換設定名リストの検証中
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void dgvNameView_Validating(object sender, CancelEventArgs e)
        {
            if (SetNameList() == false)
            {
                e.Cancel = true; // フォーカス移動をキャンセル
            }
        }

        /// <summary>
        /// フォームが閉じられようとしているとき
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void FormCommonConversion_FormClosing(object sender, FormClosingEventArgs e)
        {
            if (dgvNameView.IsCurrentCellInEditMode)
            {
                // 編集を確定させる
                if (!dgvNameView.EndEdit())
                {
                    // 編集が確定できなかった
                    e.Cancel = true; // フォームを閉じない
                    return;
                }
            }

            CheckValueView();

            if (SetNameList() == false)
            {
                e.Cancel = true; // フォームを閉じない
            }

            if (isValueError == true)
            {
                MessageBox.Show("FNWの値が重複しています。", Commons.AppName, MessageBoxButtons.OK, MessageBoxIcon.Error);
                e.Cancel = true; // フォームを閉じない
            }
        }

        /// <summary>
        /// 共通値変換設定名のデータを保存する
        /// </summary>
        /// <returns></returns>
        private bool SetNameList()
        {
            if (isNameError_Null == true && isNameError_Duplicate == true)
            {
                string msg = "";
                msg += "共通値変換設定名が未入力です。" + Environment.NewLine;
                msg += "共通値変換設定名が重複しています。";
                MessageBox.Show(msg, Commons.AppName, MessageBoxButtons.OK, MessageBoxIcon.Error);

                //e.Cancel = true; // フォーカス移動をキャンセル

                return false;
            }
            if (isNameError_Null == true)
            {
                MessageBox.Show("共通値変換設定名が未入力です。", Commons.AppName, MessageBoxButtons.OK, MessageBoxIcon.Error);

                //e.Cancel = true; // フォーカス移動をキャンセル

                return false;
            }
            if (isNameError_Duplicate == true)
            {
                MessageBox.Show("共通値変換設定名が重複しています。", Commons.AppName, MessageBoxButtons.OK, MessageBoxIcon.Error);

                //e.Cancel = true; // フォーカス移動をキャンセル

                return false;
            }

            List<ValueMappingList> addList = new List<ValueMappingList>();
            for (int i = 0; i < NameDataList.Count; i++)
            {

                if (NameDataList[i].valueMappingList != null)
                {
                    NameDataList[i].valueMappingList.Name = NameDataList[i].Name;

                    addList.Add(NameDataList[i].valueMappingList);
                }
                else
                {
                    ValueMappingList newItem = new ValueMappingList();

                    newItem.Name = NameDataList[i].Name;
                    addList.Add(newItem);
                }
            }

            MappingSettingManager.SetPublicValueMappingList(addList);

            return true;
        }

        /// <summary>
        /// 共通変換設定名リストの内容をクリックしたとき
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void dgvNameView_CellContentClick(object sender, DataGridViewCellEventArgs e)
        {
            // ヘッダー行や無効なセルは無視
            if (e.RowIndex < 0 || e.ColumnIndex < 0) return;

            // 削除ボタンの列かどうかを確認
            if (dgvNameView.Columns[e.ColumnIndex].Name == "Trash")
            {
                var row = dgvNameView.Rows[e.RowIndex];
                if (row.IsNewRow) return;

                var item2 = row.DataBoundItem as NameItem;
                if (item2 == null) return;

                if (item2.valueMappingList != null && string.IsNullOrEmpty(item2.valueMappingList.Name) == false)
                {                
                    bool isUse = MappingSettingManager.CheckPublicListUse(item2.valueMappingList.Name);
                    if (isUse == true)
                    {
                        string msg = "";
                        msg += "この共通値変換設定は使用されています。" + Environment.NewLine;
                        msg += "削除しますか？";

                        DialogResult result = MessageBox.Show(msg, Commons.AppName, MessageBoxButtons.YesNo, MessageBoxIcon.Question, MessageBoxDefaultButton.Button2);
                        if (result != DialogResult.Yes)
                        {
                            // 「はい」以外が選ばれたとき
                            return;
                        }
                    }

                    if (isUse == true)
                    {
                        // 使用している共通値変換設定を削除
                        MappingSettingManager.UpdaePublicList(item2.valueMappingList.Name, null);
                    }
                }

                dgvNameView.Rows.RemoveAt(e.RowIndex);
            }
        }

        /// <summary>
        /// 共通変換設定名リストの行が削除されようとしているとき（DELキー押下）
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void dgvNameView_UserDeletingRow(object sender, DataGridViewRowCancelEventArgs e)
        {
            var row = e.Row;
            if (row.IsNewRow) return;

            var item2 = row.DataBoundItem as NameItem;
            if (item2 == null) return;

            if (item2.valueMappingList != null && string.IsNullOrEmpty(item2.valueMappingList.Name) == false)
            {
                bool isUse = MappingSettingManager.CheckPublicListUse(item2.valueMappingList.Name);
                if (isUse == true)
                {
                    string msg = "";
                    msg += "この共通値変換設定は使用されています。" + Environment.NewLine;
                    msg += "削除しますか？";

                    DialogResult result = MessageBox.Show(msg, Commons.AppName, MessageBoxButtons.YesNo, MessageBoxIcon.Question, MessageBoxDefaultButton.Button2);
                    if (result != DialogResult.Yes)
                    {
                        // 「はい」以外が選ばれたとき
                        e.Cancel = true; // 削除をキャンセル！
                        return;
                    }
                }

                if (isUse == true)
                {
                    // 使用している共通値変換設定を削除
                    MappingSettingManager.UpdaePublicList(item2.valueMappingList.Name, null);
                }
            }
        }

        /// <summary>
        /// 共通変換設定名リストのセルの編集完了したとき
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void dgvNameView_CellEndEdit(object sender, DataGridViewCellEventArgs e)
        {
            CheckNameData();

            var row = dgvNameView.Rows[e.RowIndex];
            if (row.IsNewRow) return;

            var item2 = row.DataBoundItem as NameItem;
            if (item2 == null) return;

            if (item2.valueMappingList != null && string.IsNullOrEmpty(item2.valueMappingList.Name) == false)
            {
                // 使用している共通値変換設定を変更
                MappingSettingManager.UpdaePublicList(item2.valueMappingList.Name, item2.Name);
            }
            else
            {
                // 新規入力した行ならデータを生成しておく
                item2.valueMappingList = new ValueMappingList();
            }

            CurrentItem = item2;
            CurrentValueMapping = item2.valueMappingList;

            SetValueSettings();
        }

        /// <summary>
        /// 共通変換設定名リストの入力エラーチェック
        /// </summary>
        private void CheckNameData()
        {
            isNameError_Null = false;
            isNameError_Duplicate = false;

            var duplicateKeys = NameDataList.GroupBy(item => item.Name)
                                .Where(g => g.Count() > 1)
                                .Select(g => g.Key)
                                .ToList();

            for (int i = 0; i < dgvNameView.Rows.Count; i++)
            {
                var row = dgvNameView.Rows[i];
                if (row.IsNewRow) continue;

                var item = (NameItem)row.DataBoundItem;

                if (string.IsNullOrEmpty(item.Name) == true)
                {
                    row.Cells["Name"].ErrorText = "共通値変換設定名が未入力です。";
                    isNameError_Null = true;
                }
                else if (duplicateKeys.Contains(item.Name))
                {
                    row.Cells["Name"].ErrorText = "共通値変換設定名が重複しています。";
                    isNameError_Duplicate = true;
                }
                else
                {
                    row.Cells["Name"].ErrorText = "";
                }
            }
        }

        /// <summary>
        /// 共通変換設定名リストの行削除（DELキー押下）
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void dgvNameView_RowsRemoved(object sender, DataGridViewRowsRemovedEventArgs e)
        {
            // 削除されたのでエラーがなくなっているかもしれないので再チェック
            CheckNameData();
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
        /// 値変換設定リストのセルの編集完了したとき
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void dgvValueView_CellEndEdit(object sender, DataGridViewCellEventArgs e)
        {
            CheckValueView();
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
        /// 値変換設定リストの検証中
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void dgvValueView_Validating(object sender, CancelEventArgs e)
        {
            if (isValueError == true)
            {
                MessageBox.Show("FNWの値が重複しています。", Commons.AppName, MessageBoxButtons.OK, MessageBoxIcon.Error);

                e.Cancel = true; // フォーカス移動をキャンセル

                return;
            }

            SetValueList();
        }

        /// <summary>
        /// 値変換設定のデータを保存する
        /// </summary>
        private void SetValueList()
        {
            if (CurrentItem == null) return;

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

                CurrentItem.valueMappingList = CurrentValueMapping;
            }
            else
            {
                CurrentItem.valueMappingList.Type = null;
                CurrentItem.valueMappingList.ValueList = null;                
            }
        }

        /// <summary>
        /// 変換タイプのラジオボタンの検証中
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void rdoType_Validating(object sender, CancelEventArgs e)
        {
            SetValueList();
        }
    }
}
