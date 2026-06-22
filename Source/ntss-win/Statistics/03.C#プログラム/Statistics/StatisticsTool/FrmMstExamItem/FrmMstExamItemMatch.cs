using System;
using System.Collections.Generic;
using System.Data;
using System.Drawing;
using System.Windows.Forms;
using Fnw.StatisticsTool.Csv;
using Fnw.StatisticsTool.FrmDispCode;
using Fnw.StatisticsTool.Properties;
using Fnw.StatisticsTool.Models;
using System.Threading.Tasks;
using NKKLoggingLib;
using System.Reflection;

namespace Fnw.StatisticsTool.FrmMstExamItem
{
    /// <summary>
    /// 検査項目設定画面
    /// </summary>
    public partial class FrmMstExamItemMatch : StatisticsBase
    {
        #region インスタンス変数
        //internal string SQL_MST_EXAM_ITEM = "";

        // 検査結果前後対応
        /// <summary>
        /// FrmMstExamItemMatchインスタンス
        /// </summary>
        private static FrmMstExamItemMatch frmMstExamItemInstance;

        /// <summary>
        /// 検査結果前後使用区分（1:使用しない, 2:使用する）
        /// </summary>
        private string usingOrderClass = string.Empty;
        #endregion

        #region プロパティ
        /// <summary>
        /// 設定内容を取得します。
        /// </summary>
        public DataTable DataExamItemMatch { get; private set; }

        /// <summary>
        /// FrmMstExamItemMatchクラスプロパティ（2015年版検査結果前後対応）
        /// </summary>
        public static FrmMstExamItemMatch FrmMstExamItemInstance
        {
            get
            {
                return frmMstExamItemInstance;
            }
            set
            {
                frmMstExamItemInstance = value;
            }
        }

        /// <summary>
        /// 検査結果前後区分使用フラグ（2015年版検査結果前後対応）
        /// </summary>
        public string OrderClass
        {
            get
            {
                return usingOrderClass;
            }
            set
            {
                usingOrderClass = value;
            }
        }
        #endregion

        #region コンストラクタ
        /// <summary>
        /// 割当画面コンストラクタ
        /// </summary>
        public FrmMstExamItemMatch() : base(isUserLoggedIn: true)
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
        /// <summary>
        /// フォームロード
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private async void FrmMstDiseaseMatch_Load(object sender, EventArgs e)
        {
            NKKLogging.GetInstance().AddLogInfo(DateTime.Now, StatisticsUtility.PRODUCT_NAME,
            GetType().Name, NKKLogging.LOGGING_CLASS.INFO, MethodBase.GetCurrentMethod().Name);
            // 候補データ作成
            DataTable dt = await MakeDataAsync();
            if (null == dt)
            {
                MessageBox.Show("データの生成に失敗しました", "データ生成エラー", MessageBoxButtons.OK, MessageBoxIcon.Stop);
                return;
            }

            //検査結果前後使用チェックボックスの設定
            if (this.usingOrderClass == "2")
            {
                this.ckbUsingOrderClass.Checked = true;
            }
            else
            {
                this.ckbUsingOrderClass.Checked = false;
            }
            //検査結果前後使用チェックボックスは非表示とする
            this.ckbUsingOrderClass.Visible = false;
            //ComboBoxに表示する項目のリストを作成する
            DataTable dtOrderClass = new DataTable("");
            dtOrderClass.Columns.Add("Display", typeof(string));
            dtOrderClass.Columns.Add("Value", typeof(string));
            dtOrderClass.Rows.Add("透析前", "0");
            dtOrderClass.Rows.Add("透析後", "1");

            //DataGridViewComboBoxColumnを作成
            DataGridViewComboBoxColumn column = new DataGridViewComboBoxColumn();

            column = (DataGridViewComboBoxColumn)grdDispCodeList.Columns[this.COL_ORDER_CLASS.Name];
            column.DataSource = dtOrderClass;

            column.ValueMember = "Value";
            column.DisplayMember = "Display";
            column.Dispose();
            column = null;
            // データバインド
            grdDispCodeList.DataSource = dt;

        }

        /// <summary>
        /// バインド時処理
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void grdDiseaseList_DataBindingComplete(object sender, DataGridViewBindingCompleteEventArgs e)
        {
            // 状態に応じて色をつける
            // 重複してた：黄色
            // 割当無し　：ピンク
            // 自動割当　：青
            // 割当済み　：無し(白)

            for (int i = 0; i < grdDispCodeList.Rows.Count; i++)
            {
                // 割当コードと対象セルを取得
                DataGridViewCell cell = grdDispCodeList[this.COL_STATUS.Name, i];
                string code = grdDispCodeList[this.COL_MATCH_CODE.Name, i].Value as string;

                // 重複チェック
                bool isMulti = false;
                for (int j = 0; j < grdDispCodeList.Rows.Count; j++)
                {
                    if (i == j)
                    {
                        // 対象行は除外
                        continue;
                    }

                    if (code == grdDispCodeList[this.COL_MATCH_CODE.Name, j].Value as string)
                    {
                        // 同じコードが設定されている
                        isMulti = true;
                        break;
                    }
                }

                // ステータスの文字列によって処理を分岐
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
        /// セルクリック
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private async void grdDiseaseList_CellClick(object sender, DataGridViewCellEventArgs e)
        {
            if (this.COL_SELECT.Name == grdDispCodeList.Columns[e.ColumnIndex].Name)
            {
                // ボタン列の場合だけ処理
                await this.ProcEditAsync(e.RowIndex);
            }
        }

        /// <summary>
        /// セルのダブルクリック
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private async void grdDiseaseList_CellDoubleClick(object sender, DataGridViewCellEventArgs e)
        {
            // 2015年版:検査結果前後対応
            if (this.COL_ORDER_CLASS.Name != grdDispCodeList.Columns[e.ColumnIndex].Name)
            {
                await this.ProcEditAsync(e.RowIndex);
            }
            
        }

        /// <summary>
        /// 編集処理
        /// </summary>
        /// <param name="rowIndex"></param>
        private async Task ProcEditAsync(int rowIndex)
        {
            if ((rowIndex < 0) || (this.grdDispCodeList.Rows.Count <= rowIndex))
            {
                // 無視
                return;
            }

            FrmDispCodeSelect frm = new FrmDispCodeSelect();

            ExamItemDataResponse examItemResult;
            DataTable dt;
            // API 検査マスタを取得
            var examItemRequest = new SysDataSetRequest(
                        sqlCd: -1000004
                    );
            examItemResult = await StatisticsLib.GetExamItemData(examItemRequest);
            List<ExamItemDataType> examItemList = examItemResult.Data;
            // DataTableに変換
            dt = StatisticsUtility.ConvertToDataTable(examItemList, null);
            if (null == dt)
            {
                MessageBox.Show("候補の作成に失敗しました", "エラー", MessageBoxButtons.OK, MessageBoxIcon.Stop);
                return;
            }
            List<DispCode> data = new List<DispCode>();
            for (int i = 0; i < dt.Rows.Count; i++)
            {
                data.Add(new DispCode(dt.Rows[i]["COL_FNW_CODE"].ToString(), dt.Rows[i]["COL_FNW_NAME"] as string));
            }

            // フリーワードのデフォルトに検査項目名称を設定
            //2015年版対応（フリーワードに検索用文字列を設定）
            string examItemName = grdDispCodeList[this.COL_MED_NAME.Name, rowIndex].Value as string;
            if (!string.IsNullOrEmpty(examItemName))
            {
                examItemName = examItemName.Replace(StatisticsConst.SUFFIX_BEFORE, String.Empty);
                examItemName = examItemName.Replace(StatisticsConst.SUFFIX_AFTER, String.Empty);
            }

            // フォームをモーダルで表示
            if (frm.InvokeRequired)
            {
                frm.SelectList = data;
                frm.TargetName = grdDispCodeList[this.COL_MED_NAME.Name, rowIndex].Value as string;
                frm.Invoke(new Action(() =>
                {
                    frm.DefaultFreeWord = examItemName; // フォームがロードされた後に設定
                    frm.ShowList(); // リストを表示
                    ProcessSelection(frm, rowIndex);
                }));
            }
            else
            {
                // UI スレッドの場合は直接アクセス
                frm.SelectList = data;
                frm.TargetName = grdDispCodeList[this.COL_MED_NAME.Name, rowIndex].Value as string;
                frm.DefaultFreeWord = examItemName; // フォームがロードされた後に設定
                frm.ShowList(); // リストを表示
                ProcessSelection(frm, rowIndex);
            }

            // 結果を画面に反映
            this.grdDiseaseList_DataBindingComplete(grdDispCodeList, null);
        }


        private void ProcessSelection(FrmDispCodeSelect frm, int rowIndex)
        {
            // 選択画面表示
            if (DialogResult.OK == this.ShowChildForm(frm, frm.TargetName, frm.DefaultFreeWord))
            {
                // OKを選択
                if (string.IsNullOrEmpty(frm.SelectedCode))
                {
                    // 選択結果が未選択の場合は選択情報を破棄
                    grdDispCodeList[this.COL_MATCH_CODE.Name, rowIndex].Value = string.Empty;
                    grdDispCodeList[this.COL_MATCH_NAME.Name, rowIndex].Value = string.Empty;
                    grdDispCodeList[this.COL_STATUS.Name, rowIndex].Value = StatisticsConst.ST_NO;
                }
                else
                {
                    // 選択情報をリストに反映
                    grdDispCodeList[this.COL_MATCH_CODE.Name, rowIndex].Value = frm.SelectedCode;
                    grdDispCodeList[this.COL_MATCH_NAME.Name, rowIndex].Value = frm.SelectedName;
                    grdDispCodeList[this.COL_STATUS.Name, rowIndex].Value = StatisticsConst.ST_MATCH;
                }
            }
        }

        /// <summary>
        /// OKクリック
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnOK_Click(object sender, EventArgs e)
        {
            Boolean status = true;
            for (int i = 0; i < grdDispCodeList.Rows.Count; i++)
            {
                if (StatisticsConst.ST_NO.Equals(grdDispCodeList[this.COL_STATUS.Name, i].Value))
                {
                    // 2015年版対応（各処理の完了状態を表示する）※強制保存します
                    MessageBox.Show("未割当の情報があります。\r\n完了状態に出来ませんので未割当のマスタについて登録して下さい。", "未割当データあり", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                    status = false;
                    break;
                }
            }

            //2018年版修正
            //透析前と透析後で異なるコードを設定した場合、
            //自動的に「検査結果情報の検査区分に関わらず情報を抽出する」にチェックを入れる
            bool isUsingOrderClass = false;
            //BUN(未該当は除外)
            if ((!grdDispCodeList[this.COL_MATCH_CODE.Name, 0].Value.Equals(
                  grdDispCodeList[this.COL_MATCH_CODE.Name, 1].Value)) &&
                (!grdDispCodeList[this.COL_MATCH_CODE.Name, 0].Value.Equals("ZZZZZZZZZZ")) &&
                (!grdDispCodeList[this.COL_MATCH_CODE.Name, 1].Value.Equals("ZZZZZZZZZZ")))
            {
                isUsingOrderClass = true;
            }
            //クレアチニン濃度(未該当は除外)
            else if ((!grdDispCodeList[this.COL_MATCH_CODE.Name, 2].Value.Equals(
                       grdDispCodeList[this.COL_MATCH_CODE.Name, 3].Value)) &&
                     (!grdDispCodeList[this.COL_MATCH_CODE.Name, 2].Value.Equals("ZZZZZZZZZZ")) &&
                     (!grdDispCodeList[this.COL_MATCH_CODE.Name, 3].Value.Equals("ZZZZZZZZZZ")))
            {
                isUsingOrderClass = true;
            }
            this.ckbUsingOrderClass.Checked = isUsingOrderClass;
            //LogManager.WriteTraceLog(null, null, string.Format("[検査結果情報の検査区分に関わらず情報を抽出する]へのチェックの有無={0}",isUsingOrderClass));

            // 編集前の設定を取得(編集対象になっていない情報を保持し続けるために)
            DataTable match = FnwCsv.ReadMatchMstExamItemCsv();

            for (int i = 0; i < grdDispCodeList.Rows.Count; i++)
            {
                // 対象行に合致する編集前設定を取得
                DataRow[] rows = match.Select(FnwCsv.C_M_EXA1 + " + '$$' = '" + grdDispCodeList[this.COL_MED_CODE.Name, i].Value as string + "$$'");

                if (1 == rows.Length)
                {
                    // 設定済の場合は今回の選択結果で上書き
                    rows[0][FnwCsv.C_M_EXA2] = grdDispCodeList[this.COL_MATCH_CODE.Name, i].Value;
                }
                else
                {
                    // 未設定の項目はリストに追加
                    DataRow row = match.NewRow();
                    row[FnwCsv.C_M_EXA1] = grdDispCodeList[this.COL_MED_CODE.Name, i].Value;
                    row[FnwCsv.C_M_EXA2] = grdDispCodeList[this.COL_MATCH_CODE.Name, i].Value;
                    match.Rows.Add(row);
                }
            }
            
            // 保存
            if (FnwCsv.Write(System.IO.Path.Combine(Settings.Default.PathCsv, Settings.Default.PathMatchMstExamItem), match))
            {
                // 2015年版対応（各処理の完了状態を表示する）
                ConfirmCompletionStatus(status);

                // 2015年版検査結果前後対応
                if (this.ckbUsingOrderClass.Checked == true)
                {
                    this.usingOrderClass = "2";
                }
                else
                {
                    this.usingOrderClass = "1";
                }
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
            else
            {
                // 失敗
                MessageBox.Show("設定の保存に失敗しました", "保存エラー", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }
        }
        #endregion

        #region 割り当てデータ作成
        // 2015年度対応（マスタ設定・ログのプレビュー表示）
        /// <summary>
        /// 割当データ作成
        /// </summary>
        /// <returns>割当データ(null：エラー)</returns>
        public async Task<DataTable> MakeDataAsync()
        {
            DataTable dt = new DataTable();

            // バインド用カラムを作成
            dt.Columns.Add(this.COL_MED_CODE.Name);
            dt.Columns.Add(this.COL_MED_NAME.Name);
            dt.Columns.Add(this.COL_MATCH_CODE.Name);
            dt.Columns.Add(this.COL_MATCH_NAME.Name);
            dt.Columns.Add(this.COL_STATUS.Name);

            ExamItemDataResponse examItemResult;
            DataTable fnw;
            // API 検査マスタを取得
            var examItemRequest = new SysDataSetRequest(
                sqlCd: -1000004
            );
            examItemResult = await StatisticsLib.GetExamItemData(examItemRequest);
            List<ExamItemDataType> examItemList = examItemResult.Data;
            // DataTableに変換
            fnw = StatisticsUtility.ConvertToDataTable(examItemList, null);
            if (null == fnw)
            {
                return null;
            }

            // 現状の設定を取得
            DataTable match = FnwCsv.ReadMatchMstExamItemCsv();

            // 医学会コード設定を取得
            List<DispCode> med = MedicalExamItem.Data;

            // 割当必要データ数分の処理
            for (int i = 0; i < med.Count; i++)
            {
                DataRow row = dt.NewRow();

                // FNWデータはDBからの取得データをコピー
                row[this.COL_MED_CODE.Name] = med[i].Code;
                row[this.COL_MED_NAME.Name] = med[i].Name;

                // 割当済みデータを取得
                // 空白文字を無視するため後方に文字列を追加して完全一致させる
                DataRow[] work = match.Select(FnwCsv.C_M_EXA1 + " + '$$' = '" + med[i].Code + "$$'");

                // 割当済みデータがある事を確認
                if ((1 == work.Length) && (false == string.IsNullOrEmpty(work[0][FnwCsv.C_M_EXA2] as string)))
                {
                    // 設定済
                    row[this.COL_MATCH_CODE.Name] = work[0][FnwCsv.C_M_EXA2];
                    row[this.COL_STATUS.Name] = StatisticsConst.ST_MATCH;
                }
                else
                {
                    // 未割当

                    // 自動割当候補を取得
                    DataRow auto = StaticFunctions.GetAutoMatch(row[this.COL_MED_NAME.Name] as string, fnw, "COL_FNW_NAME");

                    if (null == auto)
                    {
                        // 自動割当候補が無い
                        row[this.COL_MATCH_CODE.Name] = "";
                        row[this.COL_STATUS.Name] = StatisticsConst.ST_NO;
                    }
                    else
                    {
                        // 自動割当を設定
                        row[this.COL_MATCH_CODE.Name] = auto["COL_FNW_CODE"];
                        row[this.COL_STATUS.Name] = StatisticsConst.ST_AUTO;
                    }
                }

                // FNWコードリストから割当済みの名称を取得
                DataRow[] f = fnw.Select("COL_FNW_CODE + '$$' = '" + row[this.COL_MATCH_CODE.Name] as string + "$$'");
                if (1 == f.Length)
                {
                    // 割当コードがFNWコードに存在する場合
                    row[this.COL_MATCH_NAME.Name] = f[0]["COL_FNW_CODE"] + ":" + f[0]["COL_FNW_NAME"];
                }
                else
                {
                    if (row[this.COL_MATCH_CODE.Name] as string == "ZZZZZZZZZZ")
                    {
                        row[this.COL_MATCH_NAME.Name] = row[this.COL_MATCH_CODE.Name] + ":未該当";
                    }
                    else
                    {
                        // FNWコードが無くなっている場合のためにリストに無い場合は設定をクリア
                        row[this.COL_MATCH_CODE.Name] = string.Empty;
                        row[this.COL_MATCH_NAME.Name] = string.Empty;
                        row[this.COL_STATUS.Name] = StatisticsConst.ST_NO;
                    }
                }

                // 処理済行をバインドデータに追加
                dt.Rows.Add(row);
            }

            this.DataExamItemMatch = dt;
            return dt;
        }
        #endregion
    }

    #region 学会の原疾患コードリスト情報
    /// <summary>
    /// 学会の原疾患コードリスト情報
    /// </summary>
    internal static class MedicalExamItem
    {
        /// <summary>
        /// キャッシュ領域
        /// </summary>
        private static List<DispCode> m_Data = null;

        /// <summary>
        /// 学会の原疾患コードリストを取得
        /// </summary>
        internal static List<DispCode> Data
        {
            get
            {
                if (null == m_Data)
                {
                    // キャッシュ情報が無い場合はここで作成
                    m_Data = new List<DispCode>();

                    m_Data.Add(new DispCode(StatisticsConst.EXAM_BUN, "BUN" + StatisticsConst.SUFFIX_BEFORE));
                    m_Data.Add(new DispCode(StatisticsConst.EXAM_BUN_AFTER, "BUN" + StatisticsConst.SUFFIX_AFTER));
                    m_Data.Add(new DispCode(StatisticsConst.EXAM_CREATININE, "クレアチニン濃度" +StatisticsConst.SUFFIX_BEFORE));
                    m_Data.Add(new DispCode(StatisticsConst.EXAM_CREATININE_AFTER, "クレアチニン濃度" + StatisticsConst.SUFFIX_AFTER));
                    m_Data.Add(new DispCode(StatisticsConst.EXAM_CALCIUM, "カルシウム濃度" + StatisticsConst.SUFFIX_BEFORE));
                    m_Data.Add(new DispCode(StatisticsConst.EXAM_PHOSPHORUS, "リン濃度" + StatisticsConst.SUFFIX_BEFORE));
                    m_Data.Add(new DispCode(StatisticsConst.EXAM_ALBUMIN, "アルブミン濃度" + StatisticsConst.SUFFIX_BEFORE));
                    m_Data.Add(new DispCode(StatisticsConst.EXAM_CRP, "CRP濃度" + StatisticsConst.SUFFIX_BEFORE));
                    m_Data.Add(new DispCode(StatisticsConst.EXAM_HEMOGLOBIN, "ヘモグロビン濃度" + StatisticsConst.SUFFIX_BEFORE));
                    m_Data.Add(new DispCode(StatisticsConst.EXAM_PTH, "PTH値"));
                    m_Data.Add(new DispCode(StatisticsConst.EXAM_TOTAL_CHOLESTEROL, "総コレステロール濃度"));
                    m_Data.Add(new DispCode(StatisticsConst.EXAM_HDL_CHOLESTEROL, "HDL-C濃度"));
                    //2025年度対象外項目
                    ////2024年度新設項目
                    //m_Data.Add(new DispCode(StatisticsConst.EXAM_LDL_CHOLESTEROL, "LDL-コレステロール濃度"));
                    //m_Data.Add(new DispCode(StatisticsConst.EXAM_TRIGLYCERIDE, "中性脂肪"));
                    ////END
                    //END
                }

                return m_Data;
            }
        }
    }
    #endregion
}
