using System;
using System.Collections.Generic;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Reflection;
using System.Threading.Tasks;
using System.Windows.Forms;
using Fnw.StatisticsTool.Csv;
using Fnw.StatisticsTool.Models;
using Fnw.StatisticsTool.Properties;
using NKKLoggingLib;

namespace Fnw.StatisticsTool.FrmPat
{
    /// <summary>
    /// 患者割当画面
    /// </summary>
    public partial class FrmPatMatch : StatisticsBase
    {
        #region プロパティ
        /// <summary>
        /// 患者割り当て結果を取得します。
        /// </summary>
        public DataTable DataPatMatch { get; private set; }

        //// 2016年版対応（系列施設対応）
        ///// <summary>
        ///// 系列施設コード
        ///// </summary>
        //internal string FacilityCd = String.Empty;
        #endregion

        #region コンストラクタ
        /// <summary>
        /// 患者割当画面のコンストラクタ
        /// </summary>
        public FrmPatMatch() : base(isUserLoggedIn:true)
        {
            InitializeComponent();
            // 基底クラスのコンストラクタでイベント登録
            RegisterEvents(this); 
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
        #endregion

        #region イベント処理

        // 2015年版対応（マスタ設定リスト・ログのプレビュー表示）
        /// <summary>
        /// 初期表示イベント処理です。
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private async void FrmPatMatch_Load(object sender, EventArgs e)
        {
            NKKLogging.GetInstance().AddLogInfo(DateTime.Now, StatisticsUtility.PRODUCT_NAME,
            GetType().Name, NKKLogging.LOGGING_CLASS.INFO, MethodBase.GetCurrentMethod().Name);

            DataTable dt = await this.MakeDataAsync();
            if (null == dt)
            {
                MessageBox.Show("データの生成に失敗しました", "データ生成エラー", MessageBoxButtons.OK, MessageBoxIcon.Stop);
                return;
            }
            if (dt.Rows.Count == 0)
            {
                this.SetDisable();
                MessageBox.Show("登録済み患者一覧情報がありません", "患者無し", MessageBoxButtons.OK, MessageBoxIcon.Warning);

                // 2015年版対応（各処理の完了状態を表示する）
                ConfirmCompletionStatus(true);
                return;
            }

            // データをバインド
            grdPatList.DataSource = dt;

            // 腹膜透析列以外を変更不可とする.
            grdPatList.Columns[0].ReadOnly = true;
            grdPatList.Columns[1].ReadOnly = true;
            grdPatList.Columns[2].ReadOnly = true;
            grdPatList.Columns[3].ReadOnly = true;
            grdPatList.Columns[4].ReadOnly = true;
            grdPatList.Columns[5].ReadOnly = true;
            grdPatList.Columns[6].ReadOnly = true;
            grdPatList.Columns[7].ReadOnly = true;
            grdPatList.Columns[8].ReadOnly = true;
            grdPatList.Columns[9].ReadOnly = true;
            grdPatList.Columns[10].ReadOnly = true;
        }

        /// <summary>
        /// キャンセルクリック
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnCancel_Click(object sender, EventArgs e)
        {
            this.DialogResult = DialogResult.Cancel;
            this.Close();
        }

        /// <summary>
        /// OKクリック
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnOK_Click(object sender, EventArgs e)
        {
            // CSV用のテーブル
            DataTable dt = new DataTable();
            dt.Columns.Add(FnwCsv.C_M_PAT1);
            dt.Columns.Add(FnwCsv.C_M_PAT2);
            dt.Columns.Add(FnwCsv.C_M_PAT3);


            // 重複割当の許容フラグ
            bool isOKMulti = false;
            // 未割当の許容フラグ
            bool isOKNotMatch = false;

            Boolean status = true;

            for (int i = 0; i < grdPatList.Rows.Count; i++)
            {
                DataRow row = dt.NewRow();

                // グリッドから医学会コードを抽出
                string seq = grdPatList.Rows[i].Cells["MedicalSequence"].Value as string;
                // グリッドからFNWの患者IDを抽出
                string patID = grdPatList.Rows[i].Cells["DBPatID"].Value as string;
                // グリッドから腹膜患者可否を抽出
                string isPdPat = grdPatList.Rows[i].Cells["IsPdPat"].Value as string;

                // 腹膜透析患者のチェックがされている場合は未割当でもOKとする.
                if (string.IsNullOrEmpty(patID) && false == System.Convert.ToBoolean(isPdPat))
                {
                    // 割当無しの場合
                    if (false == isOKNotMatch)
                    {
                        // 2015年版対応（各処理の完了状態を表示する）※強制保存に変更します
                        // 初回はメッセージボックスで警告
                        //if (DialogResult.Yes == MessageBox.Show("紐付けられていない患者さんが残っています。\r\nこのまま保存してよろしいですか？", "未登録確認", MessageBoxButtons.YesNo, MessageBoxIcon.Question))
                        //MessageBox.Show("紐付けられていない患者さんが残っていますが、このまま保存します", "未登録警告", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                        MessageBox.Show("紐付けられていない患者さんが残っています。\r\n完了状態に出来ませんので患者さんの紐付を行って下さい。", "未登録確認", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                        status = false;
                        //{
                            // 許容されたら以降は確認しない
                            isOKNotMatch = true;
                        //}
                        //else
                        //{
                        //    return;
                        //}
                    }
                }
                else
                {
                    // 割当有り
                    if (false == isOKMulti)
                    {
                        // これまでに登録した中に同じ患者IDが無かったか検索
                        DataRow[] list = dt.Select(FnwCsv.C_M_PAT2 + " + '$$' = '" + patID + "$$'");
                        if (patID != "ZZZZZZZZZZ")
                        {
                            if (0 != list.Length)
                            {
                                // 2015年版対応（各処理の完了状態を表示する）※強制保存に変更します
                                // 重複登録の確認
                                MessageBox.Show("重複して登録されている患者さんが居ますが、このまま保存します", "二重登録警告", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                                //if (DialogResult.Yes == MessageBox.Show("重複して登録されている患者さんが居ます。\r\nこのまま保存してよろしいですか？", "二重登録確認", MessageBoxButtons.YesNo, MessageBoxIcon.Question))
                                //{
                                // 許容されたら以降は確認しない
                                isOKMulti = true;
                                //}
                                //else
                                //{
                                //    return;
                                //}
                            }
                        }
                    }
                }

                // CSV出力のデータとして格納
                row[FnwCsv.C_M_PAT1] = seq;
                row[FnwCsv.C_M_PAT2] = patID;
                row[FnwCsv.C_M_PAT3] = isPdPat;

                dt.Rows.Add(row);
            }

            // 割当データをファイル保存
            if (false == FnwCsv.Write(System.IO.Path.Combine(Settings.Default.PathCsv, Settings.Default.PathMatchPatient), dt))
            {
                MessageBox.Show("設定の保存に失敗しました", "保存エラー", MessageBoxButtons.OK, MessageBoxIcon.Stop);
                return;
            }

            // 各処理の完了状態を表示する
            ConfirmCompletionStatus(status);
            if (status)
            {
                this.DialogResult = DialogResult.OK;
                this.Close();
            }
            else
            {
                return;
            }
        }

        #region DataGridViewイベント
        /// <summary>
        /// データバインドされた
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void grdPatList_DataBindingComplete(object sender, DataGridViewBindingCompleteEventArgs e)
        {
            DataTable dt = grdPatList.DataSource as DataTable;

            // 状態に応じて色をつける
            // 重複してた：黄色
            // 割当無し　：ピンク
            // 自動割当　：青
            // 割当済み　：無し(白)
            for (int i = 0; i < grdPatList.Rows.Count; i++)
            {
                DataGridViewCell cell = grdPatList.Rows[i].Cells["Status"];
                string patID = grdPatList.Rows[i].Cells["DBPatID"].Value as string;
                bool isMulti = 1 != dt.Select("DB_PATID + '$$' = '" + patID + "$$'").Length;

                switch (cell.Value as string)
                {
                    case StatisticsConst.ST_NO:
                        // 割当無し
                        cell.Style.BackColor = Color.Pink;
                        break;
                    case StatisticsConst.ST_AUTO:
                        // 自動割当
                        if (isMulti)
                        {
                            // 重複有り
                            cell.Style.BackColor = Color.Yellow;
                        }
                        else
                        {
                            // 重複無し
                            cell.Style.BackColor = Color.SkyBlue;
                        }
                        break;
                    case StatisticsConst.ST_MATCH:
                        // 割当済み
                        if (isMulti)
                        {
                            // 重複有り
                            cell.Style.BackColor = Color.Yellow;
                        }
                        else
                        {
                            // 重複無し
                            cell.Style.BackColor = Color.Empty;
                        }
                        break;
                }
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private async void grdPatList_CellClick(object sender, DataGridViewCellEventArgs e)
        {
            // クリックされたセルの名前が患者選択ボタン列かどうかチェック
            if ("SelectPat" == grdPatList.Columns[e.ColumnIndex].Name)
            {
                await this.ProcEditAsync(e.RowIndex);
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private async void grdPatList_CellDoubleClick(object sender, DataGridViewCellEventArgs e)
        {
            await this.ProcEditAsync(e.RowIndex);
        }
        #endregion

        #endregion

        #region 2015年版対応（マスタ設定リスト・ログのプレビュー表示）
        /// <summary>
        /// 患者割り当てのデータを作成します。
        /// </summary>
        /// <returns>割当データ。エラーの場合は<c>null</c></returns>
        public async Task<DataTable> MakeDataAsync()
        {
            // DataGridとのバインド用テーブル
            DataTable dt = new DataTable();

            // フィールド名セット
            dt.Columns.Add("MEDICAL_SEQUENCE");
            dt.Columns.Add("MEDICAL_NAME");
            dt.Columns.Add("MEDICAL_SEX");
            dt.Columns.Add("MEDICAL_BIRTHDAY");
            dt.Columns.Add("STATUS");
            dt.Columns.Add("DB_PATID");
            dt.Columns.Add("DB_DISP_PATID");
            dt.Columns.Add("DB_NAME");
            dt.Columns.Add("DB_SEX");
            dt.Columns.Add("DB_BIRTHDAY");
            dt.Columns.Add("IS_PD_PAT");

            // 登録済み患者一覧取得
            DataTable PatList = FnwCsv.ReadPatientCsv();
            if (0 == PatList.Rows.Count)
            {
                this.DataPatMatch = dt;
                return dt;
            }

            // 割当済み情報取得
            DataTable MatchList = FnwCsv.ReadMatchPatientCsv();
            DataTable doneData = null;

            for (int i = 0; i < PatList.Rows.Count; i++)
            {
                DataRow row = dt.NewRow();

                DateTime work = StaticFunctions.GetSheetSumBirthday(PatList.Rows[i]);

                ////独自シーケンス作成(2012年度はシーケンスがExcelに記載されていない可能性があるため)
                string strSeq = string.Empty;
                strSeq = i.ToString();

                // 登録済み情報をコピー
                row["MEDICAL_SEQUENCE"] = strSeq;
                row["MEDICAL_NAME"] = PatList.Rows[i][(int)SheetSum.C15_氏名_姓_漢字] as string;
                row["MEDICAL_NAME"] = row["MEDICAL_NAME"] as string + PatList.Rows[i][(int)SheetSum.C16_氏名_名_漢字] as string;
           
                row["MEDICAL_SEX"] = PatList.Rows[i][(int)SheetSum.C20_性別];

                // 登録済みの生年月日は分割された和暦からの変換が必要
                if (false == DateTime.MinValue.Equals(work))
                {
                    row["MEDICAL_BIRTHDAY"] = work.ToString("yyyy/MM/dd");
                }

                // 割当情報取得
                DataRow[] match = MatchList.Select(FnwCsv.C_M_PAT1 + " + '$$' = '" + strSeq as string + "$$'");

                bool isError = false;
                if (1 != match.Length)
                {
                    (bool success, DataTable resultTable) = await SetPatDBDataAsync(0, PatList.Rows[i], row, doneData);
                    // 割当情報が無い場合
                    if (!success)
                    {
                        isError = true;
                    }
                    doneData = resultTable;
                }
                else
                {
                    long patID = 0;
                    long parsedPatID;
                    if (match[0][FnwCsv.C_M_PAT2] != DBNull.Value && long.TryParse(match[0][FnwCsv.C_M_PAT2].ToString(), out parsedPatID))
                    {
                        patID = parsedPatID; // 正常に変換できたらpatIDにセット
                    }

                    // 割当情報がある場合
                    (bool success, DataTable resultTable) = await SetPatDBDataAsync(patID, PatList.Rows[i], row, doneData);
                    if (!success)
                    {
                        isError = true;
                    }
                    // 腹膜透析患者フラグ
                    row["IS_PD_PAT"] = match[0][FnwCsv.C_M_PAT3];
                    doneData = resultTable;
                }

                if (isError)
                {
                    //// 割当情報の取得でエラーが発生
                    //MessageBox.Show("DBからの情報取得でエラーが発生しました", "DBエラー", MessageBoxButtons.OK, MessageBoxIcon.Stop);
                    //this.SetDisable();
                    return null;
                }

                dt.Rows.Add(row);
            }
            this.DataPatMatch = dt;
            return dt;
        }
        #endregion

        #region 画面表示処理
        /// <summary>
        /// 
        /// </summary>
        /// <param name="rowIndex"></param>
        private async Task ProcEditAsync(int rowIndex)
        {
            if ((rowIndex < 0) || (this.grdPatList.Rows.Count <= rowIndex))
            {
                // 無視
                return;
            }

            // グリッドから元となったデータテーブルを取得
            DataTable dt = grdPatList.DataSource as DataTable;

            // 患者選択のダイアログを作成
            FrmPatSelect dlg = new FrmPatSelect();
            await dlg.InitializeAsync();

            // 選択された行に対応するデータテーブルの行番号を取得
            int dtRowIndex;
            if (!int.TryParse(grdPatList.Rows[rowIndex].Cells["MedicalSequence"].Value as string, out dtRowIndex))
            {
                // 無視
                return;
            }

            // 選択された行の情報をダイアログに渡す
            dlg.MedicalData = dt.Rows[dtRowIndex];
            // 子画面表示
            if (DialogResult.OK == this.ShowChildForm(dlg,string.Empty,string.Empty))
            {
                // 選択状況を確認
                if (null == dlg.SelectedCells)
                {
                    // 患者選択しなおし
                    dt.Rows[dtRowIndex]["STATUS"] = StatisticsConst.ST_NO;
                    dt.Rows[dtRowIndex]["DB_PATID"] = "";
                    dt.Rows[dtRowIndex]["DB_DISP_PATID"] = "";
                    dt.Rows[dtRowIndex]["DB_NAME"] = "";
                    dt.Rows[dtRowIndex]["DB_SEX"] = "";
                    dt.Rows[dtRowIndex]["DB_BIRTHDAY"] = "";
                    dt.Rows[dtRowIndex]["IS_PD_PAT"] = false;
                }
                else
                {
                    // 患者選択しなおし
                    dt.Rows[dtRowIndex]["STATUS"] = StatisticsConst.ST_MATCH;
                    dt.Rows[dtRowIndex]["DB_PATID"] = dlg.SelectedCells["PatID"].Value;
                    dt.Rows[dtRowIndex]["DB_DISP_PATID"] = dlg.SelectedCells["DispPatID"].Value;
                    dt.Rows[dtRowIndex]["DB_NAME"] = dlg.SelectedCells["PatName"].Value;
                    dt.Rows[dtRowIndex]["DB_SEX"] = dlg.SelectedCells["Sex"].Value;
                    dt.Rows[dtRowIndex]["DB_BIRTHDAY"] = dlg.SelectedCells["Birthday"].Value;
                    dt.Rows[dtRowIndex]["IS_PD_PAT"] = false;
                }
            }
            // 選択結果を反映
            grdPatList.DataSource = dt;
            this.lastActivity = DateTime.Now;
        }

        /// <summary>
        /// エラー時処理用のコントロール無効化
        /// </summary>
        private void SetDisable()
        {
            grdPatList.Enabled = false;
            btnOK.Enabled = false;
        }

        /// <summary>
        /// 指定患者IDの情報をDataRowに格納
        /// </summary>
        /// <param name="patID">登録済み患者情報を読み込んだDataRow</param>
        /// <param name="medicalRow">エクセルの登録済み患者情報</param>
        /// <param name="setRow">グリッドにバインドする用の情報を格納するDataRow</param>
        /// <returns>true：成功 false：失敗</returns>
        private async Task<(bool, DataTable)> SetPatDBDataAsync(long patID, DataRow medicalRow, DataRow setRow, DataTable doneTable)
        {
            DataTable dt = doneTable;
            if (dt == null)
            {
                    PatPersonalDataResponse patPersonalResult = await StatisticsLib.GetPatPersonalData(
                    new SysDataSetRequest(
                        sqlCd: -1000103
                    )
                );
                List<PatPersonalDataType> patPersonalList = patPersonalResult.Data;
                // DataTableに変換
                dt = StatisticsUtility.ConvertToDataTable(patPersonalList, null);
                if (null == dt)
                {
                    return (false, null);
                }
            }

            DataRow match = null;

            // PATID が一致するデータを検索
            DataRow[] filteredRows = dt.Select($"PATID = {patID}");

            if (filteredRows.Length == 1)
            {
                // 1 件のみ一致する場合、割当データあり
                match = filteredRows[0];
                setRow["STATUS"] = StatisticsConst.ST_MATCH;
            }
            else if (null != medicalRow)
            {
                // medicalRow が存在する場合に自動割当
                bool isOK = true;

                // 氏名の1文字目が一致する人を探す
                string str = medicalRow[(int)SheetSum.C15_氏名_姓_漢字] as string;
                if (string.IsNullOrEmpty(str))
                {
                    isOK = false;
                }
                else
                {
                    // 1文字目のみ指定する
                    str = str[0].ToString();
                    DataRow[] nameFilteredRows = dt.Select($"NAME LIKE '{str}%'");
                    if (nameFilteredRows.Length > 0)
                    {
                        filteredRows = nameFilteredRows;
                    }
                    else
                    {
                        isOK = false;
                    }
                }

                // 誕生日が一致する人を探す
                DateTime birth = StaticFunctions.GetSheetSumBirthday(medicalRow);
                if (DateTime.MinValue.Equals(birth))
                {
                    isOK = false;
                }
                else
                {
                    filteredRows = filteredRows.Where(row => row["BIRTHDAY"].ToString() == birth.ToString("yyyyMMdd")).ToArray();
                }

                // 性別が一致する人を探す
                str = medicalRow[(int)SheetSum.C20_性別] as string;
                switch (str)
                {
                    case "M":
                        filteredRows = filteredRows.Where(row => (short)row["SEX_CD"] == 1).ToArray();
                        break;
                    case "F":
                        filteredRows = filteredRows.Where(row => (short)row["SEX_CD"] == 2).ToArray();
                        break;
                    default:
                        isOK = false;
                        break;
                }

                // 条件に合うデータが1件だけの場合、それをmatchに設定
                if (isOK && filteredRows.Length == 1)
                {
                    match = filteredRows[0];
                    setRow["STATUS"] = StatisticsConst.ST_AUTO;
                }
            }

            // データの設定処理（変更なし）
            if (null != match)
            {
                setRow["DB_PATID"] = match["PATID"];
                setRow["DB_DISP_PATID"] = match["DISP_PATID"] ?? string.Empty;
                setRow["DB_NAME"] = match["NAME"];

                switch ((short)match["SEX_CD"])
                {
                    case 1:
                        setRow["DB_SEX"] = "M";
                        break;
                    case 2:
                        setRow["DB_SEX"] = "F";
                        break;
                    default:
                        setRow["DB_SEX"] = string.Empty;
                        break;
                }

                DateTime birthday = StaticFunctions.YyyyMmDdToDay(match["BIRTHDAY"] as string);
                setRow["DB_BIRTHDAY"] = birthday != DateTime.MinValue ? birthday.ToString("yyyy/MM/dd") : string.Empty;
            }
            else
            {
                // 割当データがない場合の処理（変更なし）
                setRow["STATUS"] = StatisticsConst.ST_NO;
                setRow["DB_PATID"] = -1;
                setRow["DB_DISP_PATID"] = string.Empty;
                setRow["DB_NAME"] = string.Empty;
                setRow["DB_SEX"] = string.Empty;
                setRow["DB_BIRTHDAY"] = string.Empty;

                if (patID == -1)
                {
                    setRow["STATUS"] = StatisticsConst.ST_MATCH;
                    setRow["DB_PATID"] = -1;
                    setRow["DB_DISP_PATID"] = "ZZZZZZZZZZ";
                    setRow["DB_NAME"] = "該当者無し";
                    setRow["DB_SEX"] = string.Empty;
                    setRow["DB_BIRTHDAY"] = "1901/01/01";
                }
            }

            setRow["IS_PD_PAT"] = false;
            return (true, dt);
        }
        #endregion
    }
}
