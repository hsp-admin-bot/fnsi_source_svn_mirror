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

namespace Fnw.StatisticsTool.FrmDispCode
{
    #region 割当種類のenum定義
    /// <summary>
    /// 割当種類のenum定義
    /// </summary>
    enum MatchType
    {
        /// <summary>なし</summary>
        NONE,
        /// <summary>病名</summary>
        MST_DISEASE,
        /// <summary>治療方法</summary>
        MST_TREAT_ITEM,
        /// <summary>死因</summary>
        MST_DIE,
        //// <summary>ダイアライザ</summary>
        ////MST_DIALYZER,
        /// <summary>転入転出施設</summary>
        MST_FACILITY,
        /// <summary>バスキュラーアクセス</summary>
        MST_VA_ACCESS,
        //// <summary>透析液Ca濃度</summary>
        ////MST_DIALYSATE_CA,
    }
    #endregion

    /// <summary>
    /// 割当画面
    /// </summary>
    public partial class FrmDispCodeMatch : StatisticsBase
    {
        #region プロパティ
        /// <summary>
        /// 割当の対象種別
        /// </summary>
        internal MatchType EditType { get; set; }

        /// <summary>
        /// 施設コード
        /// </summary>
        internal string FacilityCode = String.Empty;

        /// <summary>
        /// 施設コード
        /// </summary>
        internal string FacilityName = String.Empty;

        /// <summary>
        /// 割り当て内容を取得します。
        /// </summary>
        public DataTable DataCodeMatch { get; private set; }
        #endregion

        #region コンストラクタ
        /// <summary>
        /// 割当画面コンストラクタ
        /// </summary>
        public FrmDispCodeMatch() : base(isUserLoggedIn: true)
        {
            InitializeComponent();
            // 基底クラスのコンストラクタでイベント登録
            RegisterEvents(this);
            this.EditType = MatchType.NONE;
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

            switch (this.EditType)
            {
                case MatchType.MST_DISEASE:
                    this.Text = "原疾患設定";
                    break;
                case MatchType.MST_TREAT_ITEM:
                    this.Text = "治療方法設定";
                    break;
                case MatchType.MST_DIE:
                    this.Text = "死因設定";
                    break;
                case MatchType.MST_FACILITY:
                    this.Text = "施設設定";
                    break;
                case MatchType.MST_VA_ACCESS:
                    this.Text = "バスキュラーアクセス設定";
                    break;
            }

            // 候補データ作成
            DataTable dt = await this.MakeDataAsync();
            if (null == dt)
            {
                MessageBox.Show("データの生成に失敗しました", "データ生成エラー", MessageBoxButtons.OK, MessageBoxIcon.Stop);
                return;
            }

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
        private void grdDiseaseList_CellClick(object sender, DataGridViewCellEventArgs e)
        {
            if (this.COL_SELECT.Name == grdDispCodeList.Columns[e.ColumnIndex].Name)
            {
                // ボタン列の場合だけ処理
                this.ProcEdit(e.RowIndex);
            }
        }

        /// <summary>
        /// セルのダブルクリック
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void grdDiseaseList_CellDoubleClick(object sender, DataGridViewCellEventArgs e)
        {
            this.ProcEdit(e.RowIndex);
        }

        /// <summary>
        /// 編集処理
        /// </summary>
        /// <param name="rowIndex"></param>
        private void ProcEdit(int rowIndex)
        {
            if ((rowIndex < 0) || (this.grdDispCodeList.Rows.Count <= rowIndex))
            {
                // 無視
                return;
            }

            FrmDispCodeSelect frm = new FrmDispCodeSelect();

            // フォームに情報を格納
            switch (this.EditType)
            {
                case MatchType.MST_DISEASE:
                    frm.SelectList = MedicalDisease.Data;
                    frm.Title = "原疾患";
                    break;
                case MatchType.MST_TREAT_ITEM:
                    frm.SelectList = MedicalTreatItem.Data;
                    frm.Title = "治療方法";
                    break;
                case MatchType.MST_DIE:
                    frm.SelectList = MedicalDie.Data;
                    frm.Title = "死因";
                    break;
                case MatchType.MST_FACILITY:
                    frm.SelectList = MedicalFacility.Data;
                    frm.Title = "施設";
                    break;
                case MatchType.MST_VA_ACCESS:
                    frm.SelectList = MedicalVa.Data;
                    frm.Title = "バスキュラーアクセス";
                    break;
                default:
                    return;
            }

            var targetName = grdDispCodeList[this.COL_FNW_NAME.Name, rowIndex].Value as string;
            var defaultFreeWord = string.Empty;

            switch (this.EditType)
            {
                case MatchType.MST_DISEASE:
                case MatchType.MST_DIE:
                case MatchType.MST_FACILITY:
                case MatchType.MST_VA_ACCESS:
                    // フリーワードのデフォルトにFNW名称を設定
                    defaultFreeWord = grdDispCodeList[this.COL_FNW_NAME.Name, rowIndex].Value as string;
                    break;
                case MatchType.MST_TREAT_ITEM:
                    // フリーワードのデフォルトは無し
                    break;
                default:
                    return;
            }

            // 選択画面表示
            if (DialogResult.OK == this.ShowChildForm(frm, targetName, defaultFreeWord))
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

            // 結果を画面に反映
            this.grdDiseaseList_DataBindingComplete(grdDispCodeList, null);
            this.lastActivity = DateTime.Now;
        }

        /// <summary>
        /// OKクリック
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnOK_Click(object sender, EventArgs e)
        {
            DataTable match;
            string fnwCode;
            string medCode;
            Boolean status = true;

            for (int i = 0; i < grdDispCodeList.Rows.Count; i++)
            {
                if (StatisticsConst.ST_NO.Equals(grdDispCodeList[this.COL_STATUS.Name, i].Value))
                {
                    MessageBox.Show("未割当の情報があります。\r\n完了状態に出来ませんので未割当のマスタについて登録して下さい。", "未割当データあり", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                    status = false;
                    break;
                }
            }

            // 編集前の設定を取得(編集対象になっていない情報を保持し続けるために)
            switch (this.EditType)
            {
                case MatchType.MST_DISEASE:
                    match = FnwCsv.ReadMatchMstDiseaseCsv();
                    fnwCode = FnwCsv.C_M_DIS1;
                    medCode = FnwCsv.C_M_DIS2;
                    break;
                case MatchType.MST_TREAT_ITEM:
                    match = FnwCsv.ReadMatchMstTreatItemCsv();
                    fnwCode = FnwCsv.C_M_TRE1;
                    medCode = FnwCsv.C_M_TRE2;
                    break;
                case MatchType.MST_DIE:
                    match = FnwCsv.ReadMatchMstDieCsv();
                    fnwCode = FnwCsv.C_M_DIE1;
                    medCode = FnwCsv.C_M_DIE2;
                    break;
                case MatchType.MST_FACILITY:
                    match = FnwCsv.ReadMatchMstFacilityCsv();
                    fnwCode = FnwCsv.C_M_FAC1;
                    medCode = FnwCsv.C_M_FAC2;
                    break;
                case MatchType.MST_VA_ACCESS:
                    match = FnwCsv.ReadMatchMstVaCsv();
                    fnwCode = FnwCsv.C_M_VA1;
                    medCode = FnwCsv.C_M_VA2;
                    break;
                default:
                    return;
            }

            for (int i = 0; i < grdDispCodeList.Rows.Count; i++)
            {
                // 対象行に合致する編集前設定を取得
                DataRow[] rows = match.Select(fnwCode + " + '$$' = '" + grdDispCodeList[this.COL_FNW_CODE.Name, i].Value as string + "$$'");

                if (1 == rows.Length)
                {
                    // 設定済の場合は今回の選択結果で上書き
                    rows[0][medCode] = grdDispCodeList[this.COL_MATCH_CODE.Name, i].Value;
                }
                else
                {
                    // 未設定の項目はリストに追加
                    DataRow row = match.NewRow();
                    row[fnwCode] = grdDispCodeList[this.COL_FNW_CODE.Name, i].Value;
                    row[medCode] = grdDispCodeList[this.COL_MATCH_CODE.Name, i].Value;
                    match.Rows.Add(row);
                }
            }

            // 設定保存
            string path;
            switch (this.EditType)
            {
                case MatchType.MST_DISEASE:
                    path = Settings.Default.PathMatchMstDisease;
                    break;
                case MatchType.MST_TREAT_ITEM:
                    path = Settings.Default.PathMatchMstTreatItem;
                    break;
                case MatchType.MST_DIE:
                    path = Settings.Default.PathMatchMstDie;
                    break;
                case MatchType.MST_FACILITY:
                    path = Settings.Default.PathMatchMstFacility;
                    break;
                case MatchType.MST_VA_ACCESS:
                    path = Settings.Default.PathMatchMstVa;
                    break;
                default:
                    return;
            }

            // 自施設名の取得し、APPCONFIGに格納する
            if (status && this.EditType == MatchType.MST_FACILITY)
            {
                for (int i = 0; i < grdDispCodeList.Rows.Count; i++)
                {
                    if (FacilityName == grdDispCodeList[this.COL_FNW_NAME.Name, i].Value.ToString())
                    {
                        string code = grdDispCodeList[this.COL_MATCH_CODE.Name, i].Value.ToString();
                        string name = grdDispCodeList[this.COL_MATCH_NAME.Name, i].Value.ToString().Split(':')[1];
                        if (code == "ZZZZZZ")
                        {
                            // 入力不可
                            MessageBox.Show($"「{FacilityName}」は「未該当」に出来ませんので学会コードを選択してください。", "選択エラー", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                            return;
                        }
                        ConfigHelper.WriteSetting("FacilityName", name);
                        ConfigHelper.WriteSetting("FacilityCode", code);
                    }
                }
            }

            // 保存
            if (FnwCsv.Write(System.IO.Path.Combine(Settings.Default.PathCsv, path), match))
            {
                // 2015年版対応（各処理の完了状態を表示する）
                ConfirmCompletionStatus(status);

                // 成功               
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

        #region 割当データ作成
        /// <summary>
        /// 割当データ作成
        /// </summary>
        /// <returns>割当データ(null：エラー)</returns>
        public async Task<DataTable> MakeDataAsync()
        {
            DataTable dt = new DataTable();
            // バインド用カラムを作成
            dt.Columns.Add(this.COL_FNW_CODE.Name);
            dt.Columns.Add(this.COL_FNW_NAME.Name);
            dt.Columns.Add(this.COL_MATCH_CODE.Name);
            dt.Columns.Add(this.COL_MATCH_NAME.Name);
            dt.Columns.Add(this.COL_STATUS.Name);

            DiseaseDataResponse diseaseResult = null;
            PrimaryDiseaseDataResponse primaryDiseaseResult = null;
            TreatmentDataResponse treatmentResult = null;
            DiseaseDataResponse diseaseDieResult = null;
            PatDieDataResponse patDieResult = null;           
            FacilityDataResponse facilityResult = null;
            VaDataResponse vaResult = null;

            DataTable dis = null;
            DataTable patMain = null;

            switch (this.EditType)
            {
                case MatchType.MST_DISEASE:
                    // API原疾患設定データ取得
                    var diseaseRequest = new SysDataSetRequest(
                        sqlCd: -1000001
                    );
                    diseaseResult = await StatisticsLib.GetDiseaseData(diseaseRequest);
                    List<DiseaseDataType> diseaseList = diseaseResult.Data;
                    // DataTableに変換
                    dis = StatisticsUtility.ConvertToDataTable(diseaseList, null);
                    if (null == dis)
                    {
                        return null;
                    }
                    // API原疾患設定データ取得
                    var primaryDiseaseRequest = new SysDataSetRequest(
                        sqlCd: -1000101
                    );
                    primaryDiseaseResult = await StatisticsLib.GetPrimaryDiseaseData(primaryDiseaseRequest);
                    List<PrimaryDiseaseDataType> primaryDiseaseList = primaryDiseaseResult.Data;
                    // DataTableに変換
                    patMain = StatisticsUtility.ConvertToDataTable(primaryDiseaseList, null);
                    if (null == dt)
                    {
                        return null;
                    }
                    break;
                case MatchType.MST_TREAT_ITEM:
                    var treatmentRequest = new SysDataSetRequest(
                        sqlCd: -1000002,
                        fromDate: Settings.Default.PeriodStart.ToString("yyyy/MM/dd"),
                        toDate: Settings.Default.PeriodEnd.ToString("yyyy/MM/dd")
                    );
                    treatmentResult = await StatisticsLib.GetTreatmentData(treatmentRequest);
                    List<TreatmentDataType> treatmentList = treatmentResult.Data;
                    // DataTableに変換
                    dis = StatisticsUtility.ConvertToDataTable(treatmentList, null);
                    if (null == dis)
                    {
                        return null;
                    }
                    break;
                case MatchType.MST_DIE:
                    // API原疾患設定データ取得
                    var diseaseDieRequest = new SysDataSetRequest(
                        sqlCd: -1000001
                    );
                    diseaseDieResult = await StatisticsLib.GetDiseaseData(diseaseDieRequest);
                    List<DiseaseDataType> diseaseDieList = diseaseDieResult.Data;
                    // DataTableに変換
                    dis = StatisticsUtility.ConvertToDataTable(diseaseDieList, null);
                    if (null == dis)
                    {
                        return null;
                    }
                    // API患者死因データ取得
                    var patDieRequest = new SysDataSetRequest(
                        sqlCd: -1000102
                    );
                    patDieResult = await StatisticsLib.GetPatDieData(patDieRequest);
                    List<PatDieDataType> list2 = patDieResult.Data;
                    // DataTableに変換
                    patMain = StatisticsUtility.ConvertToDataTable(list2, null);
                    if (null == patMain)
                    {
                        return null;
                    }
                    break;
                case MatchType.MST_FACILITY:
                    // API 施設項目データ取得
                    var facilityRequest = new SysDataSetRequest(
                        sqlCd: -1000003
                    );
                    facilityResult = await StatisticsLib.GetFacilityData(facilityRequest);
                    List<FacilityDataType> facilityList = facilityResult.Data;
                    // DataTableに変換
                    dis = StatisticsUtility.ConvertToDataTable(facilityList, null);
                    if (null == dis)
                    {
                        return null;
                    }
                    else
                    {
                        // DataTable.Selectで既存かチェック
                        DataRow[] foundRows = dis.Select($"COL_FNW_NAME = '{FacilityName.Replace("'", "''")}'");

                        if (foundRows.Length == 0)
                        {
                            // 存在しなければ追加
                            DataRow newRow = dis.NewRow();
                            newRow["COL_FNW_CODE"] = FacilityCode;
                            newRow["COL_FNW_NAME"] = FacilityName;
                            // 必要であれば他の列も設定
                            dis.Rows.Add(newRow);
                        }
                    }
                    break;
                case MatchType.MST_VA_ACCESS:
                    // APIバスキュラーアクセスデータ取得
                    var vaRequest = new SysDataSetRequest(
                        sqlCd: -1000028,
                        fromDate: Settings.Default.PeriodStart.ToString("yyyy/MM/dd"),
                        toDate: Settings.Default.PeriodEnd.ToString("yyyy/MM/dd"),
                        ctlNo: "2"
                    );
                    vaResult = await StatisticsLib.GetVaData(vaRequest);
                    List<VaDataType> vaList = vaResult.Data;
                    // DataTableに変換
                    dis = StatisticsUtility.ConvertToDataTable(vaList, null);
                    if (null == dis)
                    {
                        return null;
                    }
                    break;
                default:
                    return null;
            }
            #region 患者個人情報データと結合
            if (this.EditType == MatchType.MST_DISEASE || this.EditType == MatchType.MST_DIE)
            {
                if (patMain != null)
                {
                    // patMain のコードリストを作成
                    HashSet<int> patMainCodes = new HashSet<int>();
                    foreach (DataRow r in patMain.Rows)
                    {
                        if (r.GetType() == typeof(int))
                        {
                            patMainCodes.Add((int)r["COL_FNW_CODE"]);
                        }
                        else
                        {
                            patMainCodes.Add(int.Parse(r["COL_FNW_CODE"].ToString()));
                        }
                    }
                    // dis の中で、patMainCodes に存在する disease_cd だけをフィルタリング
                    DataTable filteredTable = dis.Clone(); // 列構造をコピー
                    foreach (DataRow row in dis.Rows)
                    {

                        if (patMainCodes.Contains((int)row["COL_FNW_CODE"]))
                        {
                            filteredTable.ImportRow(row);
                        }
                    }
                    // フィルタリングした結果を最終的に返す
                    dis = filteredTable;
                }
                else
                {
                    // null だった場合、空の DataTable を返す
                    return null;
                }
            }
            #endregion

            // 現状の設定を取得
            DataTable match;

            // 医学会コード設定を取得
            List<DispCode> med;

            switch (this.EditType)
            {
                case MatchType.MST_DISEASE:
                    match = FnwCsv.ReadMatchMstDiseaseCsv();
                    med = MedicalDisease.Data;
                    break;
                case MatchType.MST_TREAT_ITEM:
                    match = FnwCsv.ReadMatchMstTreatItemCsv();
                    med = MedicalTreatItem.Data;
                    break;
                case MatchType.MST_DIE:
                    match = FnwCsv.ReadMatchMstDieCsv();
                    med = MedicalDie.Data;
                    break;
                case MatchType.MST_FACILITY:
                    match = FnwCsv.ReadMatchMstFacilityCsv();
                    med = MedicalFacility.Data;
                    break;
                case MatchType.MST_VA_ACCESS:
                    match = FnwCsv.ReadMatchMstVaCsv();
                    med = MedicalVa.Data;
                    break;
                default:
                    return null;
            }

            // 割当必要データ数分の処理
            for (int i = 0; i < dis.Rows.Count; i++)
            {
                DataRow row = dt.NewRow();
                // FNWデータはDBからの取得データをコピー
                row[this.COL_FNW_CODE.Name] = dis.Rows[i]["COL_FNW_CODE"].ToString();
                row[this.COL_FNW_NAME.Name] = dis.Rows[i]["COL_FNW_NAME"];

                // 割当済みデータを取得
                string fnwCode;
                string medCode;
                switch (this.EditType)
                {
                    case MatchType.MST_DISEASE:
                        fnwCode = FnwCsv.C_M_DIS1;
                        medCode = FnwCsv.C_M_DIS2;
                        break;
                    case MatchType.MST_TREAT_ITEM:
                        fnwCode = FnwCsv.C_M_TRE1;
                        medCode = FnwCsv.C_M_TRE2;
                        break;
                    case MatchType.MST_DIE:
                        fnwCode = FnwCsv.C_M_DIE1;
                        medCode = FnwCsv.C_M_DIE2;
                        break;
                    case MatchType.MST_FACILITY:
                        fnwCode = FnwCsv.C_M_FAC1;
                        medCode = FnwCsv.C_M_FAC2;
                        break;
                    case MatchType.MST_VA_ACCESS:
                        fnwCode = FnwCsv.C_M_VA1;
                        medCode = FnwCsv.C_M_VA2;
                        break;
                    default:
                        return null;
                }

                // 空白文字を無視するため後方に文字列を追加して完全一致させる
                DataRow[] work = match.Select(fnwCode + " + '$$' = '" + row[this.COL_FNW_CODE.Name] as string + "$$'");

                // 割当済みデータがある事を確認
                if ((1 == work.Length) && (false == string.IsNullOrEmpty(work[0][medCode] as string)))
                {
                    // 設定済
                    //2015年版対応：治療方法コードの振り替え（31 → 30）
                    if (work[0][medCode].Equals("31"))
                    {
                        row[this.COL_MATCH_CODE.Name] = "30";
                    }
                    else
                    {
                        row[this.COL_MATCH_CODE.Name] = work[0][medCode];
                    }
                    row[this.COL_STATUS.Name] = StatisticsConst.ST_MATCH;
                }
                else
                {
                    // 未割当

                    // 自動割当候補を取得
                    DispCode auto = null;
                    switch (this.EditType)
                    {
                        case MatchType.MST_DISEASE:
                        case MatchType.MST_DIE:
                        case MatchType.MST_FACILITY:
                            auto = StaticFunctions.GetAutoMatch(row[this.COL_FNW_NAME.Name] as string, med);
                            break;
                        case MatchType.MST_TREAT_ITEM:
                        case MatchType.MST_VA_ACCESS:
                        // 自動割当しない
                        default:
                            break;
                    }

                    if (null == auto)
                    {
                        // 自動割当候補が無い
                        row[this.COL_MATCH_CODE.Name] = "";
                        row[this.COL_STATUS.Name] = StatisticsConst.ST_NO;
                    }
                    else
                    {
                        // 自動割当を設定
                        row[this.COL_MATCH_CODE.Name] = auto.Code;
                        row[this.COL_STATUS.Name] = StatisticsConst.ST_AUTO;
                    }
                }

                // 学会コードリストから割当済みの名称を取得
                List<DispCode> m = med.FindAll(ele => ele.Code.Equals(row[this.COL_MATCH_CODE.Name]));
                if (1 == m.Count)
                {
                    // 割当コードが学会コードに存在する場合
                    row[this.COL_MATCH_NAME.Name] = m[0].Disp;
                }
                else
                {
                    // 学会コードが無くなっている場合のためにリストに無い場合は設定をクリア
                    row[this.COL_MATCH_CODE.Name] = string.Empty;
                    row[this.COL_MATCH_NAME.Name] = string.Empty;
                    row[this.COL_STATUS.Name] = StatisticsConst.ST_NO;
                }

                // 処理済行をバインドデータに追加
                dt.Rows.Add(row);
            }

            this.DataCodeMatch = dt;
            return dt;
        }
        #endregion
    }

    #region 学会の原疾患コードリスト情報
    /// <summary>
    /// 学会の原疾患コードリスト情報
    /// </summary>
    internal static class MedicalDisease
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

                    m_Data.Add(new DispCode("ZZZ", "未該当"));
                    m_Data.Add(new DispCode("010", "慢性糸球体腎炎"));
                    m_Data.Add(new DispCode("011", "慢性糸球体腎炎(あり)"));
                    m_Data.Add(new DispCode("012", "IgA腎症・紫斑病性腎炎"));
                    m_Data.Add(new DispCode("013", "IgA腎症・紫斑病性腎炎(あり)"));
                    m_Data.Add(new DispCode("016", "膜性腎症"));
                    m_Data.Add(new DispCode("017", "膜性腎症(あり)"));
                    m_Data.Add(new DispCode("018", "膜性増殖性糸球体腎炎"));
                    m_Data.Add(new DispCode("019", "膜性増殖性糸球体腎炎(あり)"));
                    m_Data.Add(new DispCode("240", "巣状糸球体硬化症"));
                    m_Data.Add(new DispCode("241", "巣状糸球体硬化症(あり)"));
                    m_Data.Add(new DispCode("020", "慢性腎盂腎炎"));
                    m_Data.Add(new DispCode("021", "慢性腎盂腎炎(あり)"));
                    m_Data.Add(new DispCode("250", "間質性腎炎"));
                    m_Data.Add(new DispCode("251", "間質性腎炎(あり)"));
                    m_Data.Add(new DispCode("030", "急速進行性糸球体腎炎（ANCA関連腎炎，抗GBM抗体腎炎など）"));
                    m_Data.Add(new DispCode("031", "急速進行性糸球体腎炎（ANCA関連腎炎，抗GBM抗体腎炎など）(あり)"));
                    m_Data.Add(new DispCode("050", "妊娠高血圧症候群（妊娠腎／妊娠中毒症）"));
                    m_Data.Add(new DispCode("051", "妊娠高血圧症候群（妊娠腎／妊娠中毒症）(あり)"));
                    m_Data.Add(new DispCode("060", "その他の分類不能の腎炎"));
                    m_Data.Add(new DispCode("061", "その他の分類不能の腎炎(あり)"));
                    m_Data.Add(new DispCode("070", "多発性嚢胞腎"));
                    m_Data.Add(new DispCode("071", "多発性嚢胞腎(あり)"));
                    m_Data.Add(new DispCode("140", "ネフロン癆"));
                    m_Data.Add(new DispCode("141", "ネフロン癆(あり)"));
                    m_Data.Add(new DispCode("142", "Alport症候群"));
                    m_Data.Add(new DispCode("143", "Alport症候群(あり)"));
                    m_Data.Add(new DispCode("144", "その他遺伝性腎疾患"));
                    m_Data.Add(new DispCode("145", "その他遺伝性腎疾患(あり)"));
                    m_Data.Add(new DispCode("146", "Fabry病"));
                    m_Data.Add(new DispCode("147", "Fabry病(あり)"));
                    m_Data.Add(new DispCode("148", "その他先天性代謝異常に基づく腎不全"));
                    m_Data.Add(new DispCode("149", "その他先天性代謝異常に基づく腎不全(あり)"));
                    m_Data.Add(new DispCode("080", "腎硬化症"));
                    m_Data.Add(new DispCode("081", "腎硬化症(あり)"));
                    m_Data.Add(new DispCode("090", "悪性高血圧（高血圧緊急症）"));
                    m_Data.Add(new DispCode("091", "悪性高血圧（高血圧緊急症）(あり)"));
                    m_Data.Add(new DispCode("100", "糖尿病性糸球体腎硬化症"));
                    m_Data.Add(new DispCode("101", "糖尿病性糸球体腎硬化症(あり)"));
                    m_Data.Add(new DispCode("102", "１型糖尿病"));
                    m_Data.Add(new DispCode("103", "１型糖尿病(あり)"));
                    m_Data.Add(new DispCode("104", "２型糖尿病"));
                    m_Data.Add(new DispCode("105", "２型糖尿病(あり)"));
                    m_Data.Add(new DispCode("110", "ループス腎炎"));
                    m_Data.Add(new DispCode("111", "ループス腎炎(あり)"));
                    m_Data.Add(new DispCode("112", "その他の自己免疫性疾患に伴う腎炎"));
                    m_Data.Add(new DispCode("113", "その他の自己免疫性疾患に伴う腎炎(あり)"));
                    m_Data.Add(new DispCode("120", "アミロイドーシスによる腎障害"));
                    m_Data.Add(new DispCode("121", "アミロイドーシスによる腎障害(あり)"));
                    m_Data.Add(new DispCode("130", "痛風腎"));
                    m_Data.Add(new DispCode("131", "痛風腎(あり)"));
                    m_Data.Add(new DispCode("150", "腎・尿路結核"));
                    m_Data.Add(new DispCode("260", "感染関連腎症（ウイルス感染を含む）"));
                    m_Data.Add(new DispCode("160", "腎・尿路結石"));
                    m_Data.Add(new DispCode("170", "腎・尿路腫瘍"));
                    m_Data.Add(new DispCode("180", "閉塞性尿路障害・排尿障害"));
                    m_Data.Add(new DispCode("190", "パラプロテイン血症（骨髄腫等*）"));
                    m_Data.Add(new DispCode("270", "腎血流障害"));
                    m_Data.Add(new DispCode("272", "微小血管障害(TTP, HUSなど)"));
                    m_Data.Add(new DispCode("274", "その他急性腎障害"));
                    m_Data.Add(new DispCode("280", "薬剤腎障害"));
                    m_Data.Add(new DispCode("282", "コレステロール塞栓症"));
                    m_Data.Add(new DispCode("284", "その他の外因性腎障害"));
                    m_Data.Add(new DispCode("200", "先天性腎尿路異常(CAKUT)"));
                    m_Data.Add(new DispCode("210", "不明"));
                    m_Data.Add(new DispCode("220", "移植後再導入"));
                    m_Data.Add(new DispCode("230", "その他"));
                }

                return m_Data;
            }
        }
    }
    #endregion

    #region 学会の治療方法コードリスト情報
    /// <summary>
    /// 学会の治療方法コードリスト情報
    /// </summary>
    internal static class MedicalTreatItem
    {
        /// <summary>
        /// キャッシュ領域
        /// </summary>
        private static List<DispCode> m_Data = null;

        /// <summary>
        /// 学会の治療法コードリストを取得
        /// </summary>
        internal static List<DispCode> Data
        {
            get
            {
                if (null == m_Data)
                {
                    // キャッシュ情報が無い場合はここで作成
                    m_Data = new List<DispCode>();

                    m_Data.Add(new DispCode("ZZ", "未該当"));
                    m_Data.Add(new DispCode("YY", "ECUM"));
                    m_Data.Add(new DispCode("00", "血液透析(在宅血液透析を除く）"));
                    m_Data.Add(new DispCode("10", "血液透析濾過(オフラインHDF）"));
                    m_Data.Add(new DispCode("11", "血液透析濾過(オンラインHDF）"));
                    m_Data.Add(new DispCode("12", "血液透析濾過(プッシュプルHDF）"));
                    m_Data.Add(new DispCode("13", "アセテートフリーバイオフィルトレーション"));
                    m_Data.Add(new DispCode("14", "間歇的血液透析濾過（IHDF）"));
                    m_Data.Add(new DispCode("15", "オンラインHDFとIHDFの併用"));
                    m_Data.Add(new DispCode("20", "血液濾過"));
                    m_Data.Add(new DispCode("40", "在宅血液透析"));
                    m_Data.Add(new DispCode("50", "腹膜透析（手動バック交換のみ）"));
                    m_Data.Add(new DispCode("51", "腹膜透析（自動腹膜潅流装置のみをを使用したもの）"));
                    m_Data.Add(new DispCode("52", "腹膜透析（手動と自動の両者を行うもの）"));
                    m_Data.Add(new DispCode("61", "腹膜透析と週１回血液透析の併用"));
                    m_Data.Add(new DispCode("62", "腹膜透析と週２回血液透析の併用"));
                    m_Data.Add(new DispCode("63", "腹膜透析と週３回血液透析の併用"));
                    m_Data.Add(new DispCode("64", "腹膜透析と週１回血液透析濾過の併用"));
                    m_Data.Add(new DispCode("65", "腹膜透析と週２回血液透析濾過の併用"));
                    m_Data.Add(new DispCode("66", "腹膜透析と週３回血液透析濾過の併用"));
                    m_Data.Add(new DispCode("67", "上記以外の腹膜透析と血液透析と血液透析濾過の併用"));
                    m_Data.Add(new DispCode("70", "透析離脱"));
                    m_Data.Add(new DispCode("80", "生体腎移植（親から）"));
                    m_Data.Add(new DispCode("81", "生体腎移植（祖父母から）"));
                    m_Data.Add(new DispCode("82", "生体腎移植（兄弟から）"));
                    m_Data.Add(new DispCode("83", "生体腎移植（子から）"));
                    m_Data.Add(new DispCode("84", "生体腎移植（それ以外の血縁者から）"));
                    m_Data.Add(new DispCode("85", "生体腎移植（配偶者から）"));
                    m_Data.Add(new DispCode("86", "生体腎移植（上記以外から）"));
                    m_Data.Add(new DispCode("89", "腎移植（生体腎か献腎か不明の場合）"));
                    m_Data.Add(new DispCode("90", "献腎移植"));
                }

                return m_Data;
            }
        }
    }
    #endregion

    #region 学会の死因コードリスト情報
    /// <summary>
    /// 学会の死因コードリスト情報
    /// </summary>
    internal static class MedicalDie
    {
        /// <summary>
        /// キャッシュ領域
        /// </summary>
        private static List<DispCode> m_Data = null;

        /// <summary>
        /// 学会の死因コードリストを取得
        /// </summary>
        internal static List<DispCode> Data
        {
            get
            {
                if (null == m_Data)
                {
                    // キャッシュ情報が無い場合はここで作成
                    m_Data = new List<DispCode>();

                    m_Data.Add(new DispCode("ZZZ", "未該当"));
                    m_Data.Add(new DispCode("110", "心不全"));
                    m_Data.Add(new DispCode("120", "肺水腫（溢水）"));
                    m_Data.Add(new DispCode("130", "急性心筋梗塞（発症30日以内死亡）"));
                    m_Data.Add(new DispCode("140", "虚血性心疾患（急性心筋梗塞以外）"));
                    m_Data.Add(new DispCode("150", "不整脈、伝導障害"));
                    m_Data.Add(new DispCode("162", "弁膜症*"));
                    m_Data.Add(new DispCode("170", "心外膜炎"));
                    m_Data.Add(new DispCode("180", "心筋症"));
                    m_Data.Add(new DispCode("100", "その他の心疾患"));
                    m_Data.Add(new DispCode("210", "くも膜下出血"));
                    m_Data.Add(new DispCode("220", "脳出血"));
                    m_Data.Add(new DispCode("230", "脳梗塞"));
                    m_Data.Add(new DispCode("200", "その他の脳血管疾患"));
                    m_Data.Add(new DispCode("260", "大動脈瘤（解離性含む）"));
                    m_Data.Add(new DispCode("250", "その他の血管疾患"));
                    m_Data.Add(new DispCode("910", "高カリウム血症"));
                    m_Data.Add(new DispCode("920", "原因不明の突然死"));
                    m_Data.Add(new DispCode("310", "敗血症"));
                    m_Data.Add(new DispCode("320", "中枢神経系感染症"));
                    m_Data.Add(new DispCode("330", "肺炎"));
                    m_Data.Add(new DispCode("340", "インフルエンザ"));
                    m_Data.Add(new DispCode("341", "新型コロナウイルス肺炎 [COVID-19]（COVID-19関連ARDS含む）"));
                    m_Data.Add(new DispCode("164", "感染性心内膜炎"));
                    m_Data.Add(new DispCode("350", "尿路感染症"));
                    m_Data.Add(new DispCode("360", "消化管・胆道系感染症・腹膜炎"));
                    m_Data.Add(new DispCode("380", "結核"));
                    m_Data.Add(new DispCode("390", "ヒト免疫不全ウイルス［HIV］感染症"));
                    m_Data.Add(new DispCode("300", "その他の感染症"));
                    m_Data.Add(new DispCode("410", "中枢神経系の悪性新生物"));
                    m_Data.Add(new DispCode("420", "呼吸器系の悪性新生物"));
                    m_Data.Add(new DispCode("430", "肝細胞癌"));
                    m_Data.Add(new DispCode("442", "胃の悪性新生物"));
                    m_Data.Add(new DispCode("444", "結腸・直腸の悪性新生物"));
                    m_Data.Add(new DispCode("446", "膵臓の悪性新生物"));
                    m_Data.Add(new DispCode("448", "胆嚢・胆管・胆道の悪性新生物"));
                    m_Data.Add(new DispCode("440", "上記以外の消化器系の悪性新生物"));
                    m_Data.Add(new DispCode("450", "乳房の悪性新生物"));
                    m_Data.Add(new DispCode("460", "性器の悪性新生物"));
                    m_Data.Add(new DispCode("472", "腎細胞癌"));
                    m_Data.Add(new DispCode("474", "腎細胞癌以外の腎尿路系の悪性腫瘍"));
                    m_Data.Add(new DispCode("480", "内分泌腺の悪性新生物"));
                    m_Data.Add(new DispCode("490", "造血・リンパ組織の悪性新生物"));
                    m_Data.Add(new DispCode("400", "その他の悪性新生物"));
                    m_Data.Add(new DispCode("510", "ウイルス性肝硬変"));
                    m_Data.Add(new DispCode("520", "非ウイルス性肝硬変"));
                    m_Data.Add(new DispCode("370", "劇症肝炎"));
                    m_Data.Add(new DispCode("530", "劇症肝炎以外の急性肝不全"));
                    m_Data.Add(new DispCode("540", "膵炎"));
                    m_Data.Add(new DispCode("500", "その他の肝胆膵疾患"));
                    m_Data.Add(new DispCode("610", "腸の血行障害"));
                    m_Data.Add(new DispCode("620", "イレウス"));
                    m_Data.Add(new DispCode("630", "消化管出血"));
                    m_Data.Add(new DispCode("640", "被嚢性腹膜硬化症"));
                    m_Data.Add(new DispCode("650", "消化管穿孔"));
                    m_Data.Add(new DispCode("600", "その他の消化器疾患"));
                    m_Data.Add(new DispCode("710", "肺梗塞、肺塞栓症"));
                    m_Data.Add(new DispCode("720", "慢性閉塞性肺疾患(COPD)・慢性呼吸不全"));
                    m_Data.Add(new DispCode("700", "その他肺・呼吸器疾患（肺炎除く）"));
                    m_Data.Add(new DispCode("760", "骨髄不全"));
                    m_Data.Add(new DispCode("750", "その他の血液疾患"));
                    m_Data.Add(new DispCode("810", "悪液質"));
                    m_Data.Add(new DispCode("820", "尿毒症"));
                    m_Data.Add(new DispCode("840", "老衰(年齢以外に明かな原因を認めないもの)"));
                    m_Data.Add(new DispCode("830", "認知症"));
                    m_Data.Add(new DispCode("800", "その他の悪液質/尿毒症"));
                    m_Data.Add(new DispCode("850", "内分泌・代謝疾患"));
                    m_Data.Add(new DispCode("010", "自殺"));
                    m_Data.Add(new DispCode("020", "治療拒否(透析拒否)"));
                    m_Data.Add(new DispCode("030", "災害・事故死"));
                    m_Data.Add(new DispCode("040", "薬物中毒"));
                    m_Data.Add(new DispCode("050", "治療見合わせ"));
                    m_Data.Add(new DispCode("080", "その他"));
                    m_Data.Add(new DispCode("090", "不明"));
                }

                return m_Data;
            }
        }
    }
    #endregion

    #region 学会の施設コードリスト情報
    /// <summary>
    /// 学会の施設コードリスト情報
    /// </summary>
    internal static class MedicalFacility
    {
        /// <summary>
        /// キャッシュ領域
        /// </summary>
        private static List<DispCode> m_Data = null;

        /// <summary>
        /// 学会の施設コードリストを取得
        /// </summary>
        internal static List<DispCode> Data
        {
            get
            {
                if (null == m_Data)
                {
                    // キャッシュ情報が無い場合はここで作成
                    m_Data = new List<DispCode>();

                    m_Data.Add(new DispCode("ZZZZZZ", "未該当", "未該当"));
                    m_Data.Add(new DispCode("010010", "北海道大学病院", "北海道"));
                    m_Data.Add(new DispCode("010033", "小樽市立病院", "北海道"));
                    m_Data.Add(new DispCode("010040", "札幌医科大学医学部", "北海道"));
                    m_Data.Add(new DispCode("010067", "八雲総合病院", "北海道"));
                    m_Data.Add(new DispCode("010073", "市立札幌病院", "北海道"));
                    m_Data.Add(new DispCode("010084", "札幌北辰病院", "北海道"));
                    m_Data.Add(new DispCode("010096", "ＫＫＲ札幌医療センター", "北海道"));
                    m_Data.Add(new DispCode("010128", "宮の森記念病院", "北海道"));
                    m_Data.Add(new DispCode("010169", "クリニック１・９・８札幌", "北海道"));
                    m_Data.Add(new DispCode("010179", "Ｈ・Ｎ・メディックさっぽろ東", "北海道"));
                    m_Data.Add(new DispCode("010199", "札幌北クリニック", "北海道"));
                    m_Data.Add(new DispCode("010256", "旭川赤十字病院", "北海道"));
                    m_Data.Add(new DispCode("010278", "恵庭第一病院", "北海道"));
                    m_Data.Add(new DispCode("010288", "朝里中央病院", "北海道"));
                    m_Data.Add(new DispCode("010302", "旭川医療センター", "北海道"));
                    m_Data.Add(new DispCode("010318", "北彩都病院", "北海道"));
                    m_Data.Add(new DispCode("010328", "道東勤医協釧路協立病院", "北海道"));
                    m_Data.Add(new DispCode("010339", "クリスタル橋内科クリニック", "北海道"));
                    m_Data.Add(new DispCode("010347", "製鉄記念室蘭病院", "北海道"));
                    m_Data.Add(new DispCode("010366", "総合病院釧路赤十字病院", "北海道"));
                    m_Data.Add(new DispCode("010378", "帯広病院", "北海道"));
                    m_Data.Add(new DispCode("010398", "北見北斗病院", "北海道"));
                    m_Data.Add(new DispCode("010403", "留萌市立病院", "北海道"));
                    m_Data.Add(new DispCode("010413", "苫小牧市立病院", "北海道"));
                    m_Data.Add(new DispCode("010436", "北海道済生会小樽病院", "北海道"));
                    m_Data.Add(new DispCode("010443", "市立美唄病院", "北海道"));
                    m_Data.Add(new DispCode("010463", "士別市立病院", "北海道"));
                    m_Data.Add(new DispCode("010473", "市立三笠総合病院", "北海道"));
                    m_Data.Add(new DispCode("010496", "伊達赤十字病院", "北海道"));
                    m_Data.Add(new DispCode("010513", "岩見沢市立総合病院", "北海道"));
                    m_Data.Add(new DispCode("010555", "帯広厚生病院", "北海道"));
                    m_Data.Add(new DispCode("010583", "市立稚内病院", "北海道"));
                    m_Data.Add(new DispCode("010598", "帯広第一病院", "北海道"));
                    m_Data.Add(new DispCode("010618", "勤医協中央病院", "北海道"));
                    m_Data.Add(new DispCode("010623", "市立釧路総合病院", "北海道"));
                    m_Data.Add(new DispCode("010639", "うのクリニック", "北海道"));
                    m_Data.Add(new DispCode("010659", "田中内科医院", "北海道"));
                    m_Data.Add(new DispCode("010663", "滝川市立病院", "北海道"));
                    m_Data.Add(new DispCode("010688", "札幌中央病院", "北海道"));
                    m_Data.Add(new DispCode("010698", "日鋼記念病院", "北海道"));
                    m_Data.Add(new DispCode("010707", "王子総合病院", "北海道"));
                    m_Data.Add(new DispCode("010729", "林田クリニック", "北海道"));
                    m_Data.Add(new DispCode("010769", "札幌東クリニック", "北海道"));
                    m_Data.Add(new DispCode("010779", "石川泌尿器科・腎臓内科", "北海道"));
                    m_Data.Add(new DispCode("010789", "平田泌尿器科", "北海道"));
                    m_Data.Add(new DispCode("010798", "函館五稜郭病院", "北海道"));
                    m_Data.Add(new DispCode("010828", "西２条腎泌尿器科病院", "北海道"));
                    m_Data.Add(new DispCode("010849", "千葉循環呼吸クリニック", "北海道"));
                    m_Data.Add(new DispCode("010868", "札幌北楡病院", "北海道"));
                    m_Data.Add(new DispCode("010883", "市立根室病院", "北海道"));
                    m_Data.Add(new DispCode("010898", "札幌徳洲会病院", "北海道"));
                    m_Data.Add(new DispCode("010905", "ニセコ羊蹄広域 倶知安厚生病院", "北海道"));
                    m_Data.Add(new DispCode("010928", "北海道泌尿器科記念病院", "北海道"));
                    m_Data.Add(new DispCode("010939", "たんだ泌尿器科", "北海道"));
                    m_Data.Add(new DispCode("010949", "だてクリニック", "北海道"));
                    m_Data.Add(new DispCode("010968", "仁楡会札幌病院", "北海道"));
                    m_Data.Add(new DispCode("010978", "曽我病院", "北海道"));
                    m_Data.Add(new DispCode("010988", "新札幌循環器病院", "北海道"));
                    m_Data.Add(new DispCode("010996", "釧路労災病院", "北海道"));
                    m_Data.Add(new DispCode("011009", "しらかば泌尿器科クリニック", "北海道"));
                    m_Data.Add(new DispCode("011018", "札幌南一条病院", "北海道"));
                    m_Data.Add(new DispCode("011028", "江別病院", "北海道"));
                    m_Data.Add(new DispCode("011033", "本別町国民健康保険病院", "北海道"));
                    m_Data.Add(new DispCode("011043", "深川市立病院", "北海道"));
                    m_Data.Add(new DispCode("011058", "手稲渓仁会病院", "北海道"));
                    m_Data.Add(new DispCode("011068", "恵み野病院", "北海道"));
                    m_Data.Add(new DispCode("011078", "三樹会泌尿器科病院", "北海道"));
                    m_Data.Add(new DispCode("011088", "桑園中央病院", "北海道"));
                    m_Data.Add(new DispCode("011109", "恵み野病院附属恵庭クリニック", "北海道"));
                    m_Data.Add(new DispCode("011118", "坂泌尿器科病院", "北海道"));
                    m_Data.Add(new DispCode("011128", "日高徳洲会病院", "北海道"));
                    m_Data.Add(new DispCode("011138", "苫小牧日翔病院", "北海道"));
                    m_Data.Add(new DispCode("011149", "釧路泌尿器科クリニック", "北海道"));
                    m_Data.Add(new DispCode("011169", "岩見沢クリニック", "北海道"));
                    m_Data.Add(new DispCode("011173", "市立函館病院", "北海道"));
                    m_Data.Add(new DispCode("011189", "芸術の森泌尿器科", "北海道"));
                    m_Data.Add(new DispCode("011196", "総合病院浦河赤十字病院", "北海道"));
                    m_Data.Add(new DispCode("011206", "ＮＴＴ東日本札幌病院", "北海道"));
                    m_Data.Add(new DispCode("011219", "江別泌尿器科クリニック", "北海道"));
                    m_Data.Add(new DispCode("011239", "よしだ内科循環器クリニック", "北海道"));
                    m_Data.Add(new DispCode("011258", "富良野病院", "北海道"));
                    m_Data.Add(new DispCode("011288", "札幌真駒内病院", "北海道"));
                    m_Data.Add(new DispCode("011295", "遠軽厚生病院", "北海道"));
                    m_Data.Add(new DispCode("011308", "小林病院", "北海道"));
                    m_Data.Add(new DispCode("011329", "北見循環器クリニック", "北海道"));
                    m_Data.Add(new DispCode("011349", "新緑通りはやし内科", "北海道"));
                    m_Data.Add(new DispCode("011383", "北海道立羽幌病院", "北海道"));
                    m_Data.Add(new DispCode("011398", "東苗穂病院", "北海道"));
                    m_Data.Add(new DispCode("011403", "北海道立北見病院", "北海道"));
                    m_Data.Add(new DispCode("011419", "はまなす医院", "北海道"));
                    m_Data.Add(new DispCode("011428", "萬田記念病院", "北海道"));
                    m_Data.Add(new DispCode("011439", "旭川泌尿器科クリニック", "北海道"));
                    m_Data.Add(new DispCode("011443", "美幌町立国民健康保険病院", "北海道"));
                    m_Data.Add(new DispCode("011458", "洞爺病院", "北海道"));
                    m_Data.Add(new DispCode("011475", "札幌厚生病院", "北海道"));
                    m_Data.Add(new DispCode("011489", "足立泌尿器科クリニック", "北海道"));
                    m_Data.Add(new DispCode("011493", "町立中標津病院", "北海道"));
                    m_Data.Add(new DispCode("011503", "市立室蘭総合病院", "北海道"));
                    m_Data.Add(new DispCode("011519", "新井田医院", "北海道"));
                    m_Data.Add(new DispCode("011528", "石狩病院", "北海道"));
                    m_Data.Add(new DispCode("011533", "公立芽室病院", "北海道"));
                    m_Data.Add(new DispCode("011559", "Ｈ・Ｎ・メディック", "北海道"));
                    m_Data.Add(new DispCode("011579", "ていね泌尿器科", "北海道"));
                    m_Data.Add(new DispCode("011589", "高山泌尿器科", "北海道"));
                    m_Data.Add(new DispCode("011593", "砂川市立病院", "北海道"));
                    m_Data.Add(new DispCode("011608", "ＪＲ札幌病院", "北海道"));
                    m_Data.Add(new DispCode("011629", "神居やわらぎ泌尿器科", "北海道"));
                    m_Data.Add(new DispCode("011639", "布施川内科医院", "北海道"));
                    m_Data.Add(new DispCode("011659", "帯広泌尿器科", "北海道"));
                    m_Data.Add(new DispCode("011665", "ＪＡ北海道厚生連旭川厚生病院", "北海道"));
                    m_Data.Add(new DispCode("011680", "旭川医科大学病院", "北海道"));
                    m_Data.Add(new DispCode("011699", "稲積公園駅前クリニック", "北海道"));
                    m_Data.Add(new DispCode("011708", "音更宏明館病院", "北海道"));
                    m_Data.Add(new DispCode("011715", "網走厚生病院", "北海道"));
                    m_Data.Add(new DispCode("011729", "Ｈ・Ｎ・メディック北広島", "北海道"));
                    m_Data.Add(new DispCode("011738", "中村記念病院", "北海道"));
                    m_Data.Add(new DispCode("011769", "岩内大浜医院", "北海道"));
                    m_Data.Add(new DispCode("011779", "三木内科泌尿器科クリニック", "北海道"));
                    m_Data.Add(new DispCode("011786", "小清水赤十字病院", "北海道"));
                    m_Data.Add(new DispCode("011798", "札幌南徳洲会病院", "北海道"));
                    m_Data.Add(new DispCode("011802", "北海道医療センター", "北海道"));
                    m_Data.Add(new DispCode("011813", "日高町立門別国民健康保険病院", "北海道"));
                    m_Data.Add(new DispCode("011828", "札幌しらかば台病院", "北海道"));
                    m_Data.Add(new DispCode("011859", "森クリニック", "北海道"));
                    m_Data.Add(new DispCode("011868", "北光記念病院", "北海道"));
                    m_Data.Add(new DispCode("011878", "札幌東徳洲会病院", "北海道"));
                    m_Data.Add(new DispCode("011889", "手稲ネフロクリニック", "北海道"));
                    m_Data.Add(new DispCode("011893", "士幌町国民健康保険病院", "北海道"));
                    m_Data.Add(new DispCode("011918", "道南ロイヤル病院", "北海道"));
                    m_Data.Add(new DispCode("011929", "琴似ハート内科・透析クリニック", "北海道"));
                    m_Data.Add(new DispCode("011938", "南札幌病院", "北海道"));
                    m_Data.Add(new DispCode("011949", "医）鳩仁会ゆうあいクリニック", "北海道"));
                    m_Data.Add(new DispCode("011956", "清水赤十字病院", "北海道"));
                    m_Data.Add(new DispCode("011969", "小樽ライフクリニック", "北海道"));
                    m_Data.Add(new DispCode("011979", "さわい内科循環器科クリニック", "北海道"));
                    m_Data.Add(new DispCode("011999", "保坂内科クリニック", "北海道"));
                    m_Data.Add(new DispCode("012019", "真駒内外来プラザ", "北海道"));
                    m_Data.Add(new DispCode("012028", "恵佑会札幌病院", "北海道"));
                    m_Data.Add(new DispCode("012038", "共愛会病院", "北海道"));
                    m_Data.Add(new DispCode("012048", "札幌センチュリー病院", "北海道"));
                    m_Data.Add(new DispCode("012058", "札幌共立五輪橋病院", "北海道"));
                    m_Data.Add(new DispCode("012063", "市立千歳市民病院", "北海道"));
                    m_Data.Add(new DispCode("012083", "市立旭川病院", "北海道"));
                    m_Data.Add(new DispCode("012093", "雄武町国民健康保険病院", "北海道"));
                    m_Data.Add(new DispCode("012113", "江別市立病院", "北海道"));
                    m_Data.Add(new DispCode("012128", "帯広徳洲会病院", "北海道"));
                    m_Data.Add(new DispCode("012139", "宮の沢腎泌尿器科クリニック", "北海道"));
                    m_Data.Add(new DispCode("012144", "JCHO北海道病院", "北海道"));
                    m_Data.Add(new DispCode("012159", "福住泌尿器科クリニック", "北海道"));
                    m_Data.Add(new DispCode("012169", "澄腎クリニック", "北海道"));
                    m_Data.Add(new DispCode("012178", "釧路孝仁会リハビリテーション病院", "北海道"));
                    m_Data.Add(new DispCode("012188", "吉田病院", "北海道"));
                    m_Data.Add(new DispCode("012198", "余市病院", "北海道"));
                    m_Data.Add(new DispCode("012208", "札幌循環器病院", "北海道"));
                    m_Data.Add(new DispCode("012219", "いわもと循環器クリニック", "北海道"));
                    m_Data.Add(new DispCode("012238", "新都市砂原病院", "北海道"));
                    m_Data.Add(new DispCode("012249", "もなみクリニック", "北海道"));
                    m_Data.Add(new DispCode("012258", "愛心メモリアル病院", "北海道"));
                    m_Data.Add(new DispCode("012269", "永山腎泌尿器科クリニック", "北海道"));
                    m_Data.Add(new DispCode("012276", "栗山赤十字病院", "北海道"));
                    m_Data.Add(new DispCode("012289", "北美原クリニック", "北海道"));
                    m_Data.Add(new DispCode("012299", "とよた腎泌尿器科クリニック", "北海道"));
                    m_Data.Add(new DispCode("012303", "松前町立松前病院", "北海道"));
                    m_Data.Add(new DispCode("012319", "帯広東内科循環器科クリニック", "北海道"));
                    m_Data.Add(new DispCode("012338", "旭川リハビリテーション病院", "北海道"));
                    m_Data.Add(new DispCode("012349", "苫小牧泌尿器科・循環器内科", "北海道"));
                    m_Data.Add(new DispCode("012359", "とかち泌尿器科", "北海道"));
                    m_Data.Add(new DispCode("012369", "たけやま腎・泌尿器科クリニック", "北海道"));
                    m_Data.Add(new DispCode("012379", "石田クリニック", "北海道"));
                    m_Data.Add(new DispCode("012398", "釧路孝仁会記念病院", "北海道"));
                    m_Data.Add(new DispCode("012418", "札幌優翔館病院", "北海道"));
                    m_Data.Add(new DispCode("012429", "五稜郭ネフロクリニック", "北海道"));
                    m_Data.Add(new DispCode("012439", "札幌セントラルクリニック", "北海道"));
                    m_Data.Add(new DispCode("012479", "サテライトクリニック知利別", "北海道"));
                    m_Data.Add(new DispCode("012489", "函館おおてまちクリニック", "北海道"));
                    m_Data.Add(new DispCode("012499", "平田内科クリニック", "北海道"));
                    m_Data.Add(new DispCode("012509", "新札幌駅前内科循環器", "北海道"));
                    m_Data.Add(new DispCode("012569", "篠路はまなすクリニック", "北海道"));
                    m_Data.Add(new DispCode("012579", "町立ぴっぷクリニック", "北海道"));
                    m_Data.Add(new DispCode("012589", "さっぽろ内科・腎臓内科クリニック", "北海道"));
                    m_Data.Add(new DispCode("012598", "札樽病院", "北海道"));
                    m_Data.Add(new DispCode("012609", "琴似腎臓内科・泌尿器科", "北海道"));
                    m_Data.Add(new DispCode("012619", "やまだクリニック", "北海道"));
                    m_Data.Add(new DispCode("012628", "手稲いなづみ病院", "北海道"));
                    m_Data.Add(new DispCode("012638", "石橋胃腸病院", "北海道"));
                    m_Data.Add(new DispCode("012653", "広域紋別病院", "北海道"));
                    m_Data.Add(new DispCode("012669", "富丘腎クリニック", "北海道"));
                    m_Data.Add(new DispCode("012678", "こが病院", "北海道"));
                    m_Data.Add(new DispCode("012689", "腎臓内科めぐみクリニック", "北海道"));
                    m_Data.Add(new DispCode("012698", "天使病院", "北海道"));
                    m_Data.Add(new DispCode("012708", "札幌南病院", "北海道"));
                    m_Data.Add(new DispCode("012719", "さっぽろ内科・腎臓内科サテライトクリニック", "北海道"));
                    m_Data.Add(new DispCode("012729", "わだ内科外科クリニック", "北海道"));
                    m_Data.Add(new DispCode("012738", "北斗病院", "北海道"));
                    m_Data.Add(new DispCode("012743", "天塩町立国民健康保険病院", "北海道"));
                    m_Data.Add(new DispCode("012759", "知床らうす国民健康保険診療所", "北海道"));
                    m_Data.Add(new DispCode("012763", "市立芦別病院", "北海道"));
                    m_Data.Add(new DispCode("012779", "北野循環器クリニック", "北海道"));
                    m_Data.Add(new DispCode("012788", "カレス記念病院", "北海道"));
                    m_Data.Add(new DispCode("012793", "足寄町国民健康保険病院", "北海道"));
                    m_Data.Add(new DispCode("012807", "イムス札幌消化器中央総合病院", "北海道"));
                    m_Data.Add(new DispCode("012813", "十勝いけだ地域医療センター", "北海道"));
                    m_Data.Add(new DispCode("012828", "三ツ山病院", "北海道"));
                    m_Data.Add(new DispCode("012839", "古泉循環器内科クリニック", "北海道"));
                    m_Data.Add(new DispCode("012849", "木原循環器科内科医院", "北海道"));
                    m_Data.Add(new DispCode("012859", "豊生会元町総合クリニック", "北海道"));
                    m_Data.Add(new DispCode("012868", "さっぽろ二十四軒病院", "北海道"));
                    m_Data.Add(new DispCode("012878", "新札幌聖陵ホスピタル", "北海道"));
                    m_Data.Add(new DispCode("012888", "札幌ライラック病院", "北海道"));
                    m_Data.Add(new DispCode("012899", "さわむら脳神経・透析クリニック", "北海道"));
                    m_Data.Add(new DispCode("012909", "にれの杜クリニック", "北海道"));
                    m_Data.Add(new DispCode("012918", "月寒あい病院", "北海道"));
                    m_Data.Add(new DispCode("012928", "札幌孝仁会記念病院", "北海道"));
                    m_Data.Add(new DispCode("012939", "伊丹腎クリニック", "北海道"));
                    m_Data.Add(new DispCode("012948", "札幌ススキノ病院", "北海道"));
                    m_Data.Add(new DispCode("012958", "千歳豊友会病院", "北海道"));
                    m_Data.Add(new DispCode("012969", "鶴の園クリニック", "北海道"));
                    m_Data.Add(new DispCode("012979", "のっぽろクリニック", "北海道"));
                    m_Data.Add(new DispCode("012999", "むとう日吉が丘クリニック", "北海道"));
                    m_Data.Add(new DispCode("013008", "北海道社会事業協会岩内病院", "北海道"));
                    m_Data.Add(new DispCode("013019", "腎・透析クリニック南１条", "北海道"));
                    m_Data.Add(new DispCode("013029", "おおた内科循環器クリニック", "北海道"));
                    m_Data.Add(new DispCode("013039", "春光腎クリニック", "北海道"));
                    m_Data.Add(new DispCode("013048", "札幌白石記念病院", "北海道"));
                    m_Data.Add(new DispCode("013053", "斜里町国民健康保険病院", "北海道"));
                    m_Data.Add(new DispCode("013068", "帯広中央病院", "北海道"));
                    m_Data.Add(new DispCode("013079", "札幌心臓血管・透析クリニック", "北海道"));
                    m_Data.Add(new DispCode("013089", "札幌ふしこ内科・透析クリニック", "北海道"));
                    m_Data.Add(new DispCode("013099", "ひろせクリニック", "北海道"));
                    m_Data.Add(new DispCode("013108", "江別谷藤病院", "北海道"));
                    m_Data.Add(new DispCode("013118", "交雄会新さっぽろ病院", "北海道"));
                    m_Data.Add(new DispCode("013129", "札幌東ネフロクリニック", "北海道"));
                    m_Data.Add(new DispCode("013139", "さっぽろ南大橋クリニック", "北海道"));
                    m_Data.Add(new DispCode("013149", "いしむら内科循環器クリニック", "北海道"));
                    m_Data.Add(new DispCode("013153", "市立函館恵山病院", "北海道"));
                    m_Data.Add(new DispCode("013169", "さっぽろ南大橋クリニック　東札幌院", "北海道"));
                    m_Data.Add(new DispCode("017018", "旭川高砂台病院", "北海道"));
                    m_Data.Add(new DispCode("017063", "鹿追町国保病院", "北海道"));
                    m_Data.Add(new DispCode("017083", "北海道立江差病院", "北海道"));
                    m_Data.Add(new DispCode("017103", "枝幸町国保病院", "北海道"));
                    m_Data.Add(new DispCode("017168", "ふらの西病院", "北海道"));
                    m_Data.Add(new DispCode("017179", "曽我クリニック", "北海道"));
                    m_Data.Add(new DispCode("017183", "名寄市立総合病院", "北海道"));
                    m_Data.Add(new DispCode("017209", "田園通りさわざき医院", "北海道"));
                    m_Data.Add(new DispCode("017218", "小樽中央病院", "北海道"));
                    m_Data.Add(new DispCode("017248", "新札幌豊和会病院", "北海道"));
                    m_Data.Add(new DispCode("017268", "函館中央病院", "北海道"));
                    m_Data.Add(new DispCode("017283", "礼文町国民健康保険 船泊診療所", "北海道"));
                    m_Data.Add(new DispCode("017319", "美瑛循環器内科", "北海道"));
                    m_Data.Add(new DispCode("017333", "あかびら市立病院", "北海道"));
                    m_Data.Add(new DispCode("017368", "名寄三愛病院", "北海道"));
                    m_Data.Add(new DispCode("017376", "北見赤十字病院", "北海道"));
                    m_Data.Add(new DispCode("017403", "町立厚岸病院", "北海道"));
                    m_Data.Add(new DispCode("017479", "釧路中央病院", "北海道"));
                    m_Data.Add(new DispCode("017559", "元町泌尿器科医院", "北海道"));
                    m_Data.Add(new DispCode("017615", "摩周厚生病院", "北海道"));
                    m_Data.Add(new DispCode("017649", "及川医院", "北海道"));
                    m_Data.Add(new DispCode("017659", "東光やわらぎ泌尿器科", "北海道"));
                    m_Data.Add(new DispCode("017719", "いぶり腎泌尿器科クリニック", "北海道"));
                    m_Data.Add(new DispCode("017749", "千歳循環器クリニック", "北海道"));
                    m_Data.Add(new DispCode("017813", "木古内町国民健康保険病院", "北海道"));
                    m_Data.Add(new DispCode("017829", "東室蘭サテライトクリニック", "北海道"));
                    m_Data.Add(new DispCode("017926", "帯広病院", "北海道"));
                    m_Data.Add(new DispCode("017949", "留萌セントラルクリニック", "北海道"));
                    m_Data.Add(new DispCode("017959", "函館泌尿器科", "北海道"));
                    m_Data.Add(new DispCode("020060", "弘前大学医学部附属病院", "青森県"));
                    m_Data.Add(new DispCode("020088", "鷹揚郷腎研究所弘前病院", "青森県"));
                    m_Data.Add(new DispCode("020098", "弘前中央病院", "青森県"));
                    m_Data.Add(new DispCode("020106", "青森労災病院", "青森県"));
                    m_Data.Add(new DispCode("020113", "八戸市立市民病院", "青森県"));
                    m_Data.Add(new DispCode("020128", "黒石厚生病院", "青森県"));
                    m_Data.Add(new DispCode("020139", "浩和医院", "青森県"));
                    m_Data.Add(new DispCode("020157", "むつ総合病院", "青森県"));
                    m_Data.Add(new DispCode("020169", "佐々木泌尿器科", "青森県"));
                    m_Data.Add(new DispCode("020173", "十和田市立中央病院", "青森県"));
                    m_Data.Add(new DispCode("020198", "八戸平和病院", "青森県"));
                    m_Data.Add(new DispCode("020208", "鷹揚郷腎研究所青森病院", "青森県"));
                    m_Data.Add(new DispCode("020219", "八戸泌尿器科医院", "青森県"));
                    m_Data.Add(new DispCode("020239", "十和田泌尿器科クリニック", "青森県"));
                    m_Data.Add(new DispCode("020243", "国民健康保険 南部町医療センター", "青森県"));
                    m_Data.Add(new DispCode("020258", "十和田第一病院", "青森県"));
                    m_Data.Add(new DispCode("020268", "メディカルコート八戸西病院", "青森県"));
                    m_Data.Add(new DispCode("020306", "八戸赤十字病院", "青森県"));
                    m_Data.Add(new DispCode("020313", "三戸中央病院", "青森県"));
                    m_Data.Add(new DispCode("020329", "関口内科クリニック", "青森県"));
                    m_Data.Add(new DispCode("020333", "公立野辺地病院", "青森県"));
                    m_Data.Add(new DispCode("020343", "大間病院", "青森県"));
                    m_Data.Add(new DispCode("020359", "きどクリニック", "青森県"));
                    m_Data.Add(new DispCode("020379", "はちのへ９９クリニック", "青森県"));
                    m_Data.Add(new DispCode("020389", "北川ひ尿器科クリニック", "青森県"));
                    m_Data.Add(new DispCode("020399", "のへじクリニック", "青森県"));
                    m_Data.Add(new DispCode("020403", "青森県立中央病院", "青森県"));
                    m_Data.Add(new DispCode("020439", "ＥＳＴクリニック", "青森県"));
                    m_Data.Add(new DispCode("020449", "あおもり腎透析・泌尿器科クリニック", "青森県"));
                    m_Data.Add(new DispCode("020459", "十和田北クリニック", "青森県"));
                    m_Data.Add(new DispCode("020463", "つがる総合病院", "青森県"));
                    m_Data.Add(new DispCode("020479", "はちのへ江陽クリニック", "青森県"));
                    m_Data.Add(new DispCode("020483", "三沢市立三沢病院", "青森県"));
                    m_Data.Add(new DispCode("027079", "得居泌尿器科医院", "青森県"));
                    m_Data.Add(new DispCode("027113", "青森市民病院", "青森県"));
                    m_Data.Add(new DispCode("027189", "青い海公園クリニック", "青森県"));
                    m_Data.Add(new DispCode("027199", "たざわクリニック", "青森県"));
                    m_Data.Add(new DispCode("027219", "津軽三育医院", "青森県"));
                    m_Data.Add(new DispCode("027269", "青い森腎クリニック", "青森県"));
                    m_Data.Add(new DispCode("030011", "岩手医科大学附属病院", "岩手県"));
                    m_Data.Add(new DispCode("030023", "岩手県立中央病院", "岩手県"));
                    m_Data.Add(new DispCode("030038", "三愛病院", "岩手県"));
                    m_Data.Add(new DispCode("030043", "岩手県立大船渡病院", "岩手県"));
                    m_Data.Add(new DispCode("030059", "地ノ森クリニック", "岩手県"));
                    m_Data.Add(new DispCode("030068", "奥州病院", "岩手県"));
                    m_Data.Add(new DispCode("030078", "宝陽病院", "岩手県"));
                    m_Data.Add(new DispCode("030083", "岩手県立中部病院", "岩手県"));
                    m_Data.Add(new DispCode("030096", "北上済生会病院", "岩手県"));
                    m_Data.Add(new DispCode("030103", "岩手県立磐井病院", "岩手県"));
                    m_Data.Add(new DispCode("030118", "一関病院", "岩手県"));
                    m_Data.Add(new DispCode("030128", "せいてつ記念病院", "岩手県"));
                    m_Data.Add(new DispCode("030133", "岩手県立宮古病院", "岩手県"));
                    m_Data.Add(new DispCode("030149", "岩手クリニック一関", "岩手県"));
                    m_Data.Add(new DispCode("030159", "小原クリニック", "岩手県"));
                    m_Data.Add(new DispCode("030169", "みやこ後藤医院", "岩手県"));
                    m_Data.Add(new DispCode("030199", "いするぎ医院", "岩手県"));
                    m_Data.Add(new DispCode("030203", "岩手県立胆沢病院", "岩手県"));
                    m_Data.Add(new DispCode("030219", "三島内科医院", "岩手県"));
                    m_Data.Add(new DispCode("030229", "後藤医院", "岩手県"));
                    m_Data.Add(new DispCode("030233", "町立西和賀さわうち病院", "岩手県"));
                    m_Data.Add(new DispCode("030256", "盛岡赤十字病院", "岩手県"));
                    m_Data.Add(new DispCode("030273", "岩手県立釜石病院", "岩手県"));
                    m_Data.Add(new DispCode("030283", "奥州市総合水沢病院", "岩手県"));
                    m_Data.Add(new DispCode("030303", "種市病院", "岩手県"));
                    m_Data.Add(new DispCode("030323", "岩手県立久慈病院", "岩手県"));
                    m_Data.Add(new DispCode("030339", "日高見中央クリニック", "岩手県"));
                    m_Data.Add(new DispCode("030349", "三愛病院附属矢巾クリニック", "岩手県"));
                    m_Data.Add(new DispCode("030363", "岩手県立遠野病院", "岩手県"));
                    m_Data.Add(new DispCode("030378", "盛岡友愛病院", "岩手県"));
                    m_Data.Add(new DispCode("030389", "岩手沼宮内クリニック", "岩手県"));
                    m_Data.Add(new DispCode("030399", "二戸クリニック", "岩手県"));
                    m_Data.Add(new DispCode("030409", "きたかみ腎クリニック", "岩手県"));
                    m_Data.Add(new DispCode("030418", "孝仁病院", "岩手県"));
                    m_Data.Add(new DispCode("030448", "美希病院", "岩手県"));
                    m_Data.Add(new DispCode("030453", "盛岡市立病院", "岩手県"));
                    m_Data.Add(new DispCode("030473", "八幡平市立病院", "岩手県"));
                    m_Data.Add(new DispCode("037018", "済生会岩泉病院", "岩手県"));
                    m_Data.Add(new DispCode("037033", "岩手県立江刺病院", "岩手県"));
                    m_Data.Add(new DispCode("037059", "大日向医院", "岩手県"));
                    m_Data.Add(new DispCode("037083", "岩手県立千厩病院", "岩手県"));
                    m_Data.Add(new DispCode("037099", "松原クリニック", "岩手県"));
                    m_Data.Add(new DispCode("037173", "岩手県立二戸病院", "岩手県"));
                    m_Data.Add(new DispCode("040044", "JCHO仙台病院", "宮城県"));
                    m_Data.Add(new DispCode("040053", "仙台市立病院", "宮城県"));
                    m_Data.Add(new DispCode("040076", "東北公済病院", "宮城県"));
                    m_Data.Add(new DispCode("040099", "中央クリニック", "宮城県"));
                    m_Data.Add(new DispCode("040109", "長町クリニック", "宮城県"));
                    m_Data.Add(new DispCode("040116", "石巻赤十字病院", "宮城県"));
                    m_Data.Add(new DispCode("040129", "多賀城腎・泌尿器クリニック", "宮城県"));
                    m_Data.Add(new DispCode("040135", "宮城利府掖済会病院", "宮城県"));
                    m_Data.Add(new DispCode("040149", "石巻クリニック", "宮城県"));
                    m_Data.Add(new DispCode("040153", "大崎市民病院", "宮城県"));
                    m_Data.Add(new DispCode("040168", "永仁会病院", "宮城県"));
                    m_Data.Add(new DispCode("040173", "気仙沼市立病院", "宮城県"));
                    m_Data.Add(new DispCode("040189", "泉ヶ丘クリニック", "宮城県"));
                    m_Data.Add(new DispCode("040199", "山本クリニック", "宮城県"));
                    m_Data.Add(new DispCode("040203", "みやぎ県南中核病院", "宮城県"));
                    m_Data.Add(new DispCode("040238", "木町病院", "宮城県"));
                    m_Data.Add(new DispCode("040248", "仙南病院", "宮城県"));
                    m_Data.Add(new DispCode("040263", "公立刈田綜合病院", "宮城県"));
                    m_Data.Add(new DispCode("040273", "登米市立登米市民病院", "宮城県"));
                    m_Data.Add(new DispCode("040289", "達内科", "宮城県"));
                    m_Data.Add(new DispCode("040298", "仙台徳洲会病院", "宮城県"));
                    m_Data.Add(new DispCode("040326", "仙台赤十字病院", "宮城県"));
                    m_Data.Add(new DispCode("040339", "仙台柳生クリニック", "宮城県"));
                    m_Data.Add(new DispCode("040349", "緑の里クリニック", "宮城県"));
                    m_Data.Add(new DispCode("040368", "仙石病院", "宮城県"));
                    m_Data.Add(new DispCode("040379", "中新田クリニック", "宮城県"));
                    m_Data.Add(new DispCode("040399", "仙台透析クリニック", "宮城県"));
                    m_Data.Add(new DispCode("040409", "泉黒澤クリニック", "宮城県"));
                    m_Data.Add(new DispCode("040419", "りふの内科クリニック", "宮城県"));
                    m_Data.Add(new DispCode("040429", "須藤内科クリニック", "宮城県"));
                    m_Data.Add(new DispCode("040439", "やすらぎの里サンクリニック", "宮城県"));
                    m_Data.Add(new DispCode("040440", "東北大学病院", "宮城県"));
                    m_Data.Add(new DispCode("040459", "中山クリニック", "宮城県"));
                    m_Data.Add(new DispCode("040469", "仙台腎泌尿器科", "宮城県"));
                    m_Data.Add(new DispCode("040478", "岩切病院", "宮城県"));
                    m_Data.Add(new DispCode("040489", "仙萩苑クリニック", "宮城県"));
                    m_Data.Add(new DispCode("040498", "泌尿器科 泉中央病院", "宮城県"));
                    m_Data.Add(new DispCode("040509", "台原内科クリニック", "宮城県"));
                    m_Data.Add(new DispCode("040519", "青空クリニック", "宮城県"));
                    m_Data.Add(new DispCode("040529", "柏木クリニック", "宮城県"));
                    m_Data.Add(new DispCode("040539", "吉岡まほろばクリニック", "宮城県"));
                    m_Data.Add(new DispCode("040559", "川平内科", "宮城県"));
                    m_Data.Add(new DispCode("040579", "三浦クリニック", "宮城県"));
                    m_Data.Add(new DispCode("040589", "庄司クリニック", "宮城県"));
                    m_Data.Add(new DispCode("040599", "古川クリニック", "宮城県"));
                    m_Data.Add(new DispCode("040609", "小牛田内科クリニック", "宮城県"));
                    m_Data.Add(new DispCode("040618", "真壁病院", "宮城県"));
                    m_Data.Add(new DispCode("040649", "泉松クリニック", "宮城県"));
                    m_Data.Add(new DispCode("040659", "緑の里第２クリニック", "宮城県"));
                    m_Data.Add(new DispCode("040669", "かわせみクリニック", "宮城県"));
                    m_Data.Add(new DispCode("040679", "鳥越塩釜腎クリニック", "宮城県"));
                    m_Data.Add(new DispCode("040689", "堀田修クリニック", "宮城県"));
                    m_Data.Add(new DispCode("040698", "富谷中央病院", "宮城県"));
                    m_Data.Add(new DispCode("040709", "大崎ミッドタウン総合メディケアクリニック", "宮城県"));
                    m_Data.Add(new DispCode("040718", "（医）清靖会PFC HOSPITAL", "宮城県"));
                    m_Data.Add(new DispCode("040729", "村田透析クリニック", "宮城県"));
                    m_Data.Add(new DispCode("040733", "南三陸病院", "宮城県"));
                    m_Data.Add(new DispCode("040749", "名取透析クリニック", "宮城県"));
                    m_Data.Add(new DispCode("040751", "東北医科薬科大学 若林病院", "宮城県"));
                    m_Data.Add(new DispCode("040761", "東北医科薬科大学病院", "宮城県"));
                    m_Data.Add(new DispCode("040779", "さとう腎臓内科ひ尿器科", "宮城県"));
                    m_Data.Add(new DispCode("040788", "星陵あすか病院", "宮城県"));
                    m_Data.Add(new DispCode("040799", "くにみ透析クリニック", "宮城県"));
                    m_Data.Add(new DispCode("040809", "あやし腎・泌尿器クリニック", "宮城県"));
                    m_Data.Add(new DispCode("040818", "葵会仙台病院", "宮城県"));
                    m_Data.Add(new DispCode("040829", "りんくう透析クリニック", "宮城県"));
                    m_Data.Add(new DispCode("040839", "富沢あおき内科クリニック", "宮城県"));
                    m_Data.Add(new DispCode("040849", "石巻内科透析クリニック", "宮城県"));
                    m_Data.Add(new DispCode("040859", "ふくだまち内科クリニック", "宮城県"));
                    m_Data.Add(new DispCode("047059", "渋谷皮膚科泌尿器科医院　透析センター", "宮城県"));
                    m_Data.Add(new DispCode("050010", "秋田大学医学部附属病院", "秋田県"));
                    m_Data.Add(new DispCode("050027", "中通総合病院", "秋田県"));
                    m_Data.Add(new DispCode("050035", "秋田厚生医療センター", "秋田県"));
                    m_Data.Add(new DispCode("050044", "JCHO秋田病院", "秋田県"));
                    m_Data.Add(new DispCode("050055", "平鹿総合病院", "秋田県"));
                    m_Data.Add(new DispCode("050063", "大館市立総合病院", "秋田県"));
                    m_Data.Add(new DispCode("050075", "由利組合総合病院", "秋田県"));
                    m_Data.Add(new DispCode("050088", "雄勝中央病院", "秋田県"));
                    m_Data.Add(new DispCode("050098", "花園病院", "秋田県"));
                    m_Data.Add(new DispCode("050105", "北秋田市民病院", "秋田県"));
                    m_Data.Add(new DispCode("050115", "大曲厚生医療センター", "秋田県"));
                    m_Data.Add(new DispCode("050123", "市立秋田総合病院", "秋田県"));
                    m_Data.Add(new DispCode("050159", "工藤泌尿器科医院", "秋田県"));
                    m_Data.Add(new DispCode("050168", "清和病院", "秋田県"));
                    m_Data.Add(new DispCode("050179", "東通腎泌尿器科クリニック", "秋田県"));
                    m_Data.Add(new DispCode("050186", "秋田赤十字病院", "秋田県"));
                    m_Data.Add(new DispCode("050195", "かづの厚生病院", "秋田県"));
                    m_Data.Add(new DispCode("050209", "きさかたクリニック", "秋田県"));
                    m_Data.Add(new DispCode("050248", "藤原記念病院", "秋田県"));
                    m_Data.Add(new DispCode("050259", "松田記念泌尿器科クリニック", "秋田県"));
                    m_Data.Add(new DispCode("050263", "市立角館総合病院", "秋田県"));
                    m_Data.Add(new DispCode("050273", "市立横手病院", "秋田県"));
                    m_Data.Add(new DispCode("050289", "菅医院", "秋田県"));
                    m_Data.Add(new DispCode("050319", "秋田泌尿器科クリニック", "秋田県"));
                    m_Data.Add(new DispCode("050328", "本荘第一病院", "秋田県"));
                    m_Data.Add(new DispCode("050333", "男鹿みなと市民病院", "秋田県"));
                    m_Data.Add(new DispCode("050349", "こはま泌尿器科クリニック", "秋田県"));
                    m_Data.Add(new DispCode("050359", "秋田南クリニック", "秋田県"));
                    m_Data.Add(new DispCode("050379", "おのば腎泌尿器科クリニック", "秋田県"));
                    m_Data.Add(new DispCode("050389", "いしやま内科腎クリニック", "秋田県"));
                    m_Data.Add(new DispCode("050399", "立木医院", "秋田県"));
                    m_Data.Add(new DispCode("050400", "秋田大学医学部 小児科", "秋田県"));
                    m_Data.Add(new DispCode("050419", "さが医院", "秋田県"));
                    m_Data.Add(new DispCode("050435", "能代厚生医療センター", "秋田県"));
                    m_Data.Add(new DispCode("050449", "飯島透析クリニック", "秋田県"));
                    m_Data.Add(new DispCode("050459", "こまち透析クリニック", "秋田県"));
                    m_Data.Add(new DispCode("050469", "新屋透析泌尿器科クリニック", "秋田県"));
                    m_Data.Add(new DispCode("057029", "清水泌尿器科内科医院", "秋田県"));
                    m_Data.Add(new DispCode("057095", "湖東厚生病院", "秋田県"));
                    m_Data.Add(new DispCode("057104", "能代山本医師会病院", "秋田県"));
                    m_Data.Add(new DispCode("060013", "山形市立病院済生館", "山形県"));
                    m_Data.Add(new DispCode("060023", "山形県立中央病院", "山形県"));
                    m_Data.Add(new DispCode("060037", "篠田総合病院", "山形県"));
                    m_Data.Add(new DispCode("060048", "矢吹病院", "山形県"));
                    m_Data.Add(new DispCode("060053", "米沢市立病院", "山形県"));
                    m_Data.Add(new DispCode("060068", "三友堂病院", "山形県"));
                    m_Data.Add(new DispCode("060079", "長岡医院", "山形県"));
                    m_Data.Add(new DispCode("060093", "山形県立新庄病院", "山形県"));
                    m_Data.Add(new DispCode("060103", "鶴岡市立荘内病院", "山形県"));
                    m_Data.Add(new DispCode("060115", "鶴岡協立病院", "山形県"));
                    m_Data.Add(new DispCode("060133", "西川町立病院", "山形県"));
                    m_Data.Add(new DispCode("060159", "斎藤医院", "山形県"));
                    m_Data.Add(new DispCode("060169", "本間なかまちクリニック", "山形県"));
                    m_Data.Add(new DispCode("060179", "土田内科医院", "山形県"));
                    m_Data.Add(new DispCode("060190", "山形大学医学部附属病院", "山形県"));
                    m_Data.Add(new DispCode("060206", "山形済生病院", "山形県"));
                    m_Data.Add(new DispCode("060213", "山形県立河北病院", "山形県"));
                    m_Data.Add(new DispCode("060229", "PFC JAPAN CLINIC 山形", "山形県"));
                    m_Data.Add(new DispCode("060238", "庄内余目病院", "山形県"));
                    m_Data.Add(new DispCode("060243", "北村山公立病院", "山形県"));
                    m_Data.Add(new DispCode("060259", "PFC JAPAN CLINIC 東根", "山形県"));
                    m_Data.Add(new DispCode("060263", "日本海総合病院", "山形県"));
                    m_Data.Add(new DispCode("060278", "新庄徳洲会病院透析センター", "山形県"));
                    m_Data.Add(new DispCode("060283", "公立置賜長井病院", "山形県"));
                    m_Data.Add(new DispCode("060303", "公立置賜総合病院", "山形県"));
                    m_Data.Add(new DispCode("060323", "公立高畠病院", "山形県"));
                    m_Data.Add(new DispCode("060338", "山形徳洲会病院", "山形県"));
                    m_Data.Add(new DispCode("060349", "細谷醫院", "山形県"));
                    m_Data.Add(new DispCode("060359", "天童温泉矢吹クリニック", "山形県"));
                    m_Data.Add(new DispCode("060368", "天童温泉篠田病院", "山形県"));
                    m_Data.Add(new DispCode("060378", "（医）清明会PFC HOSPITAL", "山形県"));
                    m_Data.Add(new DispCode("060399", "本町矢吹クリニック", "山形県"));
                    m_Data.Add(new DispCode("060419", "ほなみ透析クリニック", "山形県"));
                    m_Data.Add(new DispCode("060429", "松下クリニック", "山形県"));
                    m_Data.Add(new DispCode("060439", "南陽矢吹クリニック", "山形県"));
                    m_Data.Add(new DispCode("070016", "済生会福島総合病院", "福島県"));
                    m_Data.Add(new DispCode("070048", "大原綜合病院", "福島県"));
                    m_Data.Add(new DispCode("070060", "会津医療センター", "福島県"));
                    m_Data.Add(new DispCode("070078", "竹田綜合病院", "福島県"));
                    m_Data.Add(new DispCode("070089", "徒之町クリニック", "福島県"));
                    m_Data.Add(new DispCode("070097", "会津中央病院", "福島県"));
                    m_Data.Add(new DispCode("070108", "日東病院", "福島県"));
                    m_Data.Add(new DispCode("070118", "寿泉堂綜合病院", "福島県"));
                    m_Data.Add(new DispCode("070143", "いわき市医療センター", "福島県"));
                    m_Data.Add(new DispCode("070155", "白河厚生総合病院", "福島県"));
                    m_Data.Add(new DispCode("070163", "公立藤田総合病院", "福島県"));
                    m_Data.Add(new DispCode("070178", "福島南病院", "福島県"));
                    m_Data.Add(new DispCode("070198", "常磐病院", "福島県"));
                    m_Data.Add(new DispCode("070204", "JCHO二本松病院", "福島県"));
                    m_Data.Add(new DispCode("070228", "飯塚病院附属有隣病院", "福島県"));
                    m_Data.Add(new DispCode("070238", "朝日病院", "福島県"));
                    m_Data.Add(new DispCode("070258", "太田西ノ内病院", "福島県"));
                    m_Data.Add(new DispCode("070269", "さとう内科医院", "福島県"));
                    m_Data.Add(new DispCode("070279", "本田内科医院", "福島県"));
                    m_Data.Add(new DispCode("070299", "須賀川クリニック", "福島県"));
                    m_Data.Add(new DispCode("070308", "大町病院", "福島県"));
                    m_Data.Add(new DispCode("070325", "医療生協わたり病院", "福島県"));
                    m_Data.Add(new DispCode("070349", "ゆうクリニック", "福島県"));
                    m_Data.Add(new DispCode("070359", "いわき泌尿器科", "福島県"));
                    m_Data.Add(new DispCode("070388", "会田病院", "福島県"));
                    m_Data.Add(new DispCode("070398", "須賀川病院", "福島県"));
                    m_Data.Add(new DispCode("070407", "星総合病院", "福島県"));
                    m_Data.Add(new DispCode("070428", "小野田病院", "福島県"));
                    m_Data.Add(new DispCode("070438", "太田熱海病院", "福島県"));
                    m_Data.Add(new DispCode("070448", "相馬中央病院", "福島県"));
                    m_Data.Add(new DispCode("070458", "かしま病院", "福島県"));
                    m_Data.Add(new DispCode("070469", "福島腎泌尿器クリニック", "福島県"));
                    m_Data.Add(new DispCode("070488", "白河病院", "福島県"));
                    m_Data.Add(new DispCode("070499", "佐久間内科", "福島県"));
                    m_Data.Add(new DispCode("070503", "公立小野町地方綜合病院", "福島県"));
                    m_Data.Add(new DispCode("070529", "富岡クリニック", "福島県"));
                    m_Data.Add(new DispCode("070538", "総合南東北病院", "福島県"));
                    m_Data.Add(new DispCode("070550", "福島県立医科大学附属病院", "福島県"));
                    m_Data.Add(new DispCode("070569", "かもめクリニック", "福島県"));
                    m_Data.Add(new DispCode("070579", "会津クリニック", "福島県"));
                    m_Data.Add(new DispCode("070589", "寿泉堂クリニック", "福島県"));
                    m_Data.Add(new DispCode("070593", "福島県立南会津病院", "福島県"));
                    m_Data.Add(new DispCode("070605", "塙厚生病院", "福島県"));
                    m_Data.Add(new DispCode("070619", "おぎはら泌尿器と腎のクリニック", "福島県"));
                    m_Data.Add(new DispCode("070638", "谷病院", "福島県"));
                    m_Data.Add(new DispCode("070649", "横田泌尿器科", "福島県"));
                    m_Data.Add(new DispCode("070659", "蓬莱東クリニック", "福島県"));
                    m_Data.Add(new DispCode("070669", "若松あおいクリニック", "福島県"));
                    m_Data.Add(new DispCode("070679", "めらクリニック", "福島県"));
                    m_Data.Add(new DispCode("070689", "マリアクリニック", "福島県"));
                    m_Data.Add(new DispCode("070708", "あさかホスピタル", "福島県"));
                    m_Data.Add(new DispCode("070719", "ニュータウン腎・内科クリニック", "福島県"));
                    m_Data.Add(new DispCode("070728", "福島寿光会病院", "福島県"));
                    m_Data.Add(new DispCode("070739", "すずきクリニック", "福島県"));
                    m_Data.Add(new DispCode("070749", "喜多方腎泌尿器クリニック", "福島県"));
                    m_Data.Add(new DispCode("070759", "さかえ内科クリニック", "福島県"));
                    m_Data.Add(new DispCode("070769", "あさか野泌尿器透析クリニック", "福島県"));
                    m_Data.Add(new DispCode("070779", "じんキッズクリニック", "福島県"));
                    m_Data.Add(new DispCode("070788", "磐城中央病院", "福島県"));
                    m_Data.Add(new DispCode("070799", "上保原内科", "福島県"));
                    m_Data.Add(new DispCode("070809", "PFC JAPAN CLINIC 福島", "福島県"));
                    m_Data.Add(new DispCode("070818", "枡記念病院", "福島県"));
                    m_Data.Add(new DispCode("070829", "福島セントラルクリニック", "福島県"));
                    m_Data.Add(new DispCode("070833", "南相馬市立総合病院", "福島県"));
                    m_Data.Add(new DispCode("070849", "しらかわ透析・内科クリニック", "福島県"));
                    m_Data.Add(new DispCode("070859", "おなはま腎・泌尿器科クリニック", "福島県"));
                    m_Data.Add(new DispCode("070869", "白河ひがし透析・内科クリニック", "福島県"));
                    m_Data.Add(new DispCode("077018", "福島第一病院", "福島県"));
                    m_Data.Add(new DispCode("077066", "公立相馬総合病院", "福島県"));
                    m_Data.Add(new DispCode("077099", "鏡石クリニック", "福島県"));
                    m_Data.Add(new DispCode("077105", "坂下厚生総合病院", "福島県"));
                    m_Data.Add(new DispCode("077193", "たむら市民病院", "福島県"));
                    m_Data.Add(new DispCode("080016", "水戸赤十字病院", "茨城県"));
                    m_Data.Add(new DispCode("080028", "住吉クリニック病院", "茨城県"));
                    m_Data.Add(new DispCode("080047", "日立総合病院", "茨城県"));
                    m_Data.Add(new DispCode("080065", "総合病院土浦協同病院", "茨城県"));
                    m_Data.Add(new DispCode("080075", "ＪＡとりで総合医療センター", "茨城県"));
                    m_Data.Add(new DispCode("080083", "茨城県立中央病院", "茨城県"));
                    m_Data.Add(new DispCode("080093", "茨城県西部メディカルセンター", "茨城県"));
                    m_Data.Add(new DispCode("080108", "前田病院", "茨城県"));
                    m_Data.Add(new DispCode("080119", "いしかわクリニック", "茨城県"));
                    m_Data.Add(new DispCode("080121", "東京医科大学茨城医療センター", "茨城県"));
                    m_Data.Add(new DispCode("080138", "筑波学園病院", "茨城県"));
                    m_Data.Add(new DispCode("080168", "勝田病院", "茨城県"));
                    m_Data.Add(new DispCode("080178", "田尻ヶ丘病院", "茨城県"));
                    m_Data.Add(new DispCode("080209", "川島クリニック", "茨城県"));
                    m_Data.Add(new DispCode("080215", "茨城県厚生連総合病院水戸協同病院", "茨城県"));
                    m_Data.Add(new DispCode("080220", "筑波大学附属病院", "茨城県"));
                    m_Data.Add(new DispCode("080239", "結城クリニック", "茨城県"));
                    m_Data.Add(new DispCode("080249", "水戸中央クリニック", "茨城県"));
                    m_Data.Add(new DispCode("080258", "藤井病院", "茨城県"));
                    m_Data.Add(new DispCode("080279", "島医院", "茨城県"));
                    m_Data.Add(new DispCode("080289", "ときわクリニック", "茨城県"));
                    m_Data.Add(new DispCode("080355", "茨城西南医療センター病院", "茨城県"));
                    m_Data.Add(new DispCode("080366", "古河赤十字病院", "茨城県"));
                    m_Data.Add(new DispCode("080378", "神立病院", "茨城県"));
                    m_Data.Add(new DispCode("080382", "水戸医療センター", "茨城県"));
                    m_Data.Add(new DispCode("080398", "水海道さくら病院", "茨城県"));
                    m_Data.Add(new DispCode("080408", "つくばセントラル病院", "茨城県"));
                    m_Data.Add(new DispCode("080418", "総和中央病院", "茨城県"));
                    m_Data.Add(new DispCode("080429", "石塚医院", "茨城県"));
                    m_Data.Add(new DispCode("080449", "渡辺内科", "茨城県"));
                    m_Data.Add(new DispCode("080459", "岩本クリニック", "茨城県"));
                    m_Data.Add(new DispCode("080468", "水戸中央病院", "茨城県"));
                    m_Data.Add(new DispCode("080476", "水戸済生会総合病院", "茨城県"));
                    m_Data.Add(new DispCode("080488", "大久保病院", "茨城県"));
                    m_Data.Add(new DispCode("080498", "宮本病院", "茨城県"));
                    m_Data.Add(new DispCode("080509", "渡邉クリニック", "茨城県"));
                    m_Data.Add(new DispCode("080518", "守谷慶友病院", "茨城県"));
                    m_Data.Add(new DispCode("080528", "小山記念病院", "茨城県"));
                    m_Data.Add(new DispCode("080539", "住吉クリニック病院附属大宮診療所", "茨城県"));
                    m_Data.Add(new DispCode("080548", "久保田病院", "茨城県"));
                    m_Data.Add(new DispCode("080557", "（株）日立製作所ひたちなか総合病院", "茨城県"));
                    m_Data.Add(new DispCode("080577", "牛久愛和総合病院", "茨城県"));
                    m_Data.Add(new DispCode("080589", "十王ひがし野クリニック", "茨城県"));
                    m_Data.Add(new DispCode("080599", "北茨城中央クリニック", "茨城県"));
                    m_Data.Add(new DispCode("080608", "山王台病院", "茨城県"));
                    m_Data.Add(new DispCode("080619", "常陸クリニック", "茨城県"));
                    m_Data.Add(new DispCode("080629", "かもめ・大津港クリニック", "茨城県"));
                    m_Data.Add(new DispCode("080649", "山口クリニック", "茨城県"));
                    m_Data.Add(new DispCode("080665", "土浦協同病院なめがた地域医療センター", "茨城県"));
                    m_Data.Add(new DispCode("080679", "つくば学園クリニック", "茨城県"));
                    m_Data.Add(new DispCode("080689", "さくら水戸クリニック", "茨城県"));
                    m_Data.Add(new DispCode("080695", "城南病院附属クリニック", "茨城県"));
                    m_Data.Add(new DispCode("080709", "かもめ・日立クリニック", "茨城県"));
                    m_Data.Add(new DispCode("080719", "利根川橋クリニック", "茨城県"));
                    m_Data.Add(new DispCode("080729", "大場内科クリニック", "茨城県"));
                    m_Data.Add(new DispCode("080739", "那珂クリニック", "茨城県"));
                    m_Data.Add(new DispCode("080748", "大圃病院", "茨城県"));
                    m_Data.Add(new DispCode("080759", "つちだ内科泌尿器科クリニック", "茨城県"));
                    m_Data.Add(new DispCode("080769", "菊池内科クリニック", "茨城県"));
                    m_Data.Add(new DispCode("080778", "美浦中央病院", "茨城県"));
                    m_Data.Add(new DispCode("080789", "緑野クリニック", "茨城県"));
                    m_Data.Add(new DispCode("080799", "一色クリニック", "茨城県"));
                    m_Data.Add(new DispCode("080809", "かわしま内科クリニック", "茨城県"));
                    m_Data.Add(new DispCode("080818", "古河総合病院", "茨城県"));
                    m_Data.Add(new DispCode("080829", "太田ネフロクリニック", "茨城県"));
                    m_Data.Add(new DispCode("080839", "大石内科クリニック", "茨城県"));
                    m_Data.Add(new DispCode("080849", "守谷駅前クリニック", "茨城県"));
                    m_Data.Add(new DispCode("080869", "常南医院", "茨城県"));
                    m_Data.Add(new DispCode("080876", "神栖済生会病院", "茨城県"));
                    m_Data.Add(new DispCode("080889", "つくば腎クリニック", "茨城県"));
                    m_Data.Add(new DispCode("080899", "セントラル腎クリニック龍ケ崎", "茨城県"));
                    m_Data.Add(new DispCode("080908", "西山堂病院", "茨城県"));
                    m_Data.Add(new DispCode("080929", "にへいなかよしクリニック", "茨城県"));
                    m_Data.Add(new DispCode("080939", "大場内科小吹クリニック", "茨城県"));
                    m_Data.Add(new DispCode("080948", "上の原病院", "茨城県"));
                    m_Data.Add(new DispCode("080959", "笠間中央クリニック", "茨城県"));
                    m_Data.Add(new DispCode("080969", "土浦ベリルクリニック", "茨城県"));
                    m_Data.Add(new DispCode("080979", "山王台病院附属眼科・内科クリニック", "茨城県"));
                    m_Data.Add(new DispCode("080988", "城西病院", "茨城県"));
                    m_Data.Add(new DispCode("080999", "トモスみとクリニック", "茨城県"));
                    m_Data.Add(new DispCode("081009", "筑西腎クリニック", "茨城県"));
                    m_Data.Add(new DispCode("081019", "古河おかもと腎クリニック", "茨城県"));
                    m_Data.Add(new DispCode("081039", "大場内科玉造クリニック", "茨城県"));
                    m_Data.Add(new DispCode("081049", "神栖メディカルクリニック", "茨城県"));
                    m_Data.Add(new DispCode("081058", "西山堂慶和病院", "茨城県"));
                    m_Data.Add(new DispCode("081069", "ひたち野うしく腎クリニック", "茨城県"));
                    m_Data.Add(new DispCode("081078", "小美玉市医療センター", "茨城県"));
                    m_Data.Add(new DispCode("081088", "土浦リハビリテーション病院 介護医療院", "茨城県"));
                    m_Data.Add(new DispCode("081099", "いちげ十字路クリニック", "茨城県"));
                    m_Data.Add(new DispCode("081109", "腎臓・透析クリニック こが", "茨城県"));
                    m_Data.Add(new DispCode("081119", "椎貝記念とりでクリニック", "茨城県"));
                    m_Data.Add(new DispCode("081129", "みなみ友部クリニック", "茨城県"));
                    m_Data.Add(new DispCode("090016", "栃木県済生会宇都宮病院", "栃木県"));
                    m_Data.Add(new DispCode("090039", "御殿山クリニック", "栃木県"));
                    m_Data.Add(new DispCode("090046", "足利赤十字病院", "栃木県"));
                    m_Data.Add(new DispCode("090059", "小山クリニック", "栃木県"));
                    m_Data.Add(new DispCode("090061", "自治医科大学附属病院", "栃木県"));
                    m_Data.Add(new DispCode("090071", "獨協医科大学病院", "栃木県"));
                    m_Data.Add(new DispCode("090089", "奥田クリニック", "栃木県"));
                    m_Data.Add(new DispCode("090099", "目黒医院", "栃木県"));
                    m_Data.Add(new DispCode("090108", "菅間記念病院", "栃木県"));
                    m_Data.Add(new DispCode("090126", "那須赤十字病院", "栃木県"));
                    m_Data.Add(new DispCode("090138", "真岡病院", "栃木県"));
                    m_Data.Add(new DispCode("090149", "両毛クリニック", "栃木県"));
                    m_Data.Add(new DispCode("090156", "芳賀赤十字病院", "栃木県"));
                    m_Data.Add(new DispCode("090179", "せいいかいメディカルクリニックOYAMA", "栃木県"));
                    m_Data.Add(new DispCode("090183", "新小山市民病院", "栃木県"));
                    m_Data.Add(new DispCode("090198", "足利中央病院", "栃木県"));
                    m_Data.Add(new DispCode("090209", "東宇都宮クリニック", "栃木県"));
                    m_Data.Add(new DispCode("090228", "宇都宮中央病院", "栃木県"));
                    m_Data.Add(new DispCode("090239", "橋本医院", "栃木県"));
                    m_Data.Add(new DispCode("090249", "尾形クリニック", "栃木県"));
                    m_Data.Add(new DispCode("090259", "森クリニック", "栃木県"));
                    m_Data.Add(new DispCode("090269", "大場医院", "栃木県"));
                    m_Data.Add(new DispCode("090289", "村山医院", "栃木県"));
                    m_Data.Add(new DispCode("090309", "桜井内科医院", "栃木県"));
                    m_Data.Add(new DispCode("090318", "今市病院", "栃木県"));
                    m_Data.Add(new DispCode("090328", "光南病院", "栃木県"));
                    m_Data.Add(new DispCode("090339", "渡部医院", "栃木県"));
                    m_Data.Add(new DispCode("090358", "黒須病院", "栃木県"));
                    m_Data.Add(new DispCode("090378", "足尾双愛病院", "栃木県"));
                    m_Data.Add(new DispCode("090399", "馬場医院", "栃木県"));
                    m_Data.Add(new DispCode("090409", "坂本クリニック", "栃木県"));
                    m_Data.Add(new DispCode("090418", "矢板南病院", "栃木県"));
                    m_Data.Add(new DispCode("090449", "足利腎クリニック", "栃木県"));
                    m_Data.Add(new DispCode("090454", "うつのみや病院", "栃木県"));
                    m_Data.Add(new DispCode("090468", "足利第一病院", "栃木県"));
                    m_Data.Add(new DispCode("090479", "加藤クリニック", "栃木県"));
                    m_Data.Add(new DispCode("090485", "佐野厚生総合病院", "栃木県"));
                    m_Data.Add(new DispCode("090508", "宇都宮第一病院", "栃木県"));
                    m_Data.Add(new DispCode("090518", "佐野メディカルセンター. 佐野市民病院", "栃木県"));
                    m_Data.Add(new DispCode("090528", "とちぎメディカルセンターとちのき", "栃木県"));
                    m_Data.Add(new DispCode("090539", "小山すぎの木クリニック", "栃木県"));
                    m_Data.Add(new DispCode("090549", "二宮中央腎・健診クリニック", "栃木県"));
                    m_Data.Add(new DispCode("090558", "小金井中央病院", "栃木県"));
                    m_Data.Add(new DispCode("090568", "野木病院", "栃木県"));
                    m_Data.Add(new DispCode("090579", "中川内科クリニック", "栃木県"));
                    m_Data.Add(new DispCode("090588", "那須南病院", "栃木県"));
                    m_Data.Add(new DispCode("090598", "国際医療福祉大学病院", "栃木県"));
                    m_Data.Add(new DispCode("090609", "グリーンタウンクリニック", "栃木県"));
                    m_Data.Add(new DispCode("090619", "大野内科医院", "栃木県"));
                    m_Data.Add(new DispCode("090639", "都賀中央医院", "栃木県"));
                    m_Data.Add(new DispCode("090643", "日光市民病院", "栃木県"));
                    m_Data.Add(new DispCode("090659", "竹村内科腎クリニック", "栃木県"));
                    m_Data.Add(new DispCode("090669", "せいいかいメディカルクリニックNASU", "栃木県"));
                    m_Data.Add(new DispCode("090679", "高橋クリニック", "栃木県"));
                    m_Data.Add(new DispCode("090688", "福田記念病院", "栃木県"));
                    m_Data.Add(new DispCode("090698", "リハビリテーション花の舎病院", "栃木県"));
                    m_Data.Add(new DispCode("090718", "日光野口病院", "栃木県"));
                    m_Data.Add(new DispCode("090738", "長﨑病院", "栃木県"));
                    m_Data.Add(new DispCode("090759", "佐野利根川橋クリニック", "栃木県"));
                    m_Data.Add(new DispCode("090769", "橋本腎内科クリニック", "栃木県"));
                    m_Data.Add(new DispCode("090779", "齊藤内科医院", "栃木県"));
                    m_Data.Add(new DispCode("090789", "しもつけ腎・内科クリニック", "栃木県"));
                    m_Data.Add(new DispCode("090798", "御殿山病院", "栃木県"));
                    m_Data.Add(new DispCode("090809", "こひらメディカルクリニック", "栃木県"));
                    m_Data.Add(new DispCode("090829", "冨塚メディカルクリニック", "栃木県"));
                    m_Data.Add(new DispCode("090839", "宇都宮利根川橋クリニック", "栃木県"));
                    m_Data.Add(new DispCode("090847", "とちぎメディカルセンターしもつが", "栃木県"));
                    m_Data.Add(new DispCode("090859", "おぐら内科・腎クリニック", "栃木県"));
                    m_Data.Add(new DispCode("090861", "獨協医科大学日光医療センター", "栃木県"));
                    m_Data.Add(new DispCode("090879", "真岡メディカルクリニック", "栃木県"));
                    m_Data.Add(new DispCode("090889", "宇都宮腎・内科・皮膚科クリニック", "栃木県"));
                    m_Data.Add(new DispCode("090899", "深澤クリニック", "栃木県"));
                    m_Data.Add(new DispCode("090909", "小林内科クリニック", "栃木県"));
                    m_Data.Add(new DispCode("090919", "尾形クリニック那須", "栃木県"));
                    m_Data.Add(new DispCode("090929", "ひらいで公園腎クリニック", "栃木県"));
                    m_Data.Add(new DispCode("090938", "宇都宮記念病院", "栃木県"));
                    m_Data.Add(new DispCode("090947", "石橋総合病院", "栃木県"));
                    m_Data.Add(new DispCode("090959", "ましこ令和クリニック", "栃木県"));
                    m_Data.Add(new DispCode("090969", "芳賀メディカルクリニック", "栃木県"));
                    m_Data.Add(new DispCode("090979", "ゆりなメディカルパーク", "栃木県"));
                    m_Data.Add(new DispCode("090989", "ますだトータルケアクリニック", "栃木県"));
                    m_Data.Add(new DispCode("090998", "那須中央病院", "栃木県"));
                    m_Data.Add(new DispCode("091009", "鬼怒川クリニック", "栃木県"));
                    m_Data.Add(new DispCode("091019", "日光腎クリニック", "栃木県"));
                    m_Data.Add(new DispCode("100010", "群馬大学医学部附属病院", "群馬県"));
                    m_Data.Add(new DispCode("100028", "群馬パース病院", "群馬県"));
                    m_Data.Add(new DispCode("100036", "前橋赤十字病院", "群馬県"));
                    m_Data.Add(new DispCode("100046", "群馬県済生会前橋病院", "群馬県"));
                    m_Data.Add(new DispCode("100058", "綿貫病院", "群馬県"));
                    m_Data.Add(new DispCode("100063", "伊勢崎市民病院", "群馬県"));
                    m_Data.Add(new DispCode("100079", "古作クリニック", "群馬県"));
                    m_Data.Add(new DispCode("100083", "公立富岡総合病院", "群馬県"));
                    m_Data.Add(new DispCode("100098", "東邦病院", "群馬県"));
                    m_Data.Add(new DispCode("100107", "桐生厚生総合病院", "群馬県"));
                    m_Data.Add(new DispCode("100118", "善衆会病院", "群馬県"));
                    m_Data.Add(new DispCode("100128", "日高病院", "群馬県"));
                    m_Data.Add(new DispCode("100138", "黒沢病院", "群馬県"));
                    m_Data.Add(new DispCode("100144", "太田記念病院", "群馬県"));
                    m_Data.Add(new DispCode("100153", "公立藤岡総合病院", "群馬県"));
                    m_Data.Add(new DispCode("100168", "吾妻さくら病院", "群馬県"));
                    m_Data.Add(new DispCode("100179", "田口医院", "群馬県"));
                    m_Data.Add(new DispCode("100218", "くすの木病院", "群馬県"));
                    m_Data.Add(new DispCode("100228", "駒井病院", "群馬県"));
                    m_Data.Add(new DispCode("100235", "利根中央病院", "群馬県"));
                    m_Data.Add(new DispCode("100249", "白根クリニック", "群馬県"));
                    m_Data.Add(new DispCode("100268", "新橋病院", "群馬県"));
                    m_Data.Add(new DispCode("100319", "西片貝クリニック", "群馬県"));
                    m_Data.Add(new DispCode("100339", "渡辺内科クリニック", "群馬県"));
                    m_Data.Add(new DispCode("100347", "本島総合病院", "群馬県"));
                    m_Data.Add(new DispCode("100353", "公立碓氷病院", "群馬県"));
                    m_Data.Add(new DispCode("100369", "有馬クリニック", "群馬県"));
                    m_Data.Add(new DispCode("100379", "富岡クリニック", "群馬県"));
                    m_Data.Add(new DispCode("100388", "渋川中央病院", "群馬県"));
                    m_Data.Add(new DispCode("100398", "せせらぎ病院", "群馬県"));
                    m_Data.Add(new DispCode("100409", "城田クリニック", "群馬県"));
                    m_Data.Add(new DispCode("100419", "中沢クリニック", "群馬県"));
                    m_Data.Add(new DispCode("100428", "わかば病院", "群馬県"));
                    m_Data.Add(new DispCode("100439", "さるきクリニック", "群馬県"));
                    m_Data.Add(new DispCode("100443", "公立館林厚生病院", "群馬県"));
                    m_Data.Add(new DispCode("100459", "前橋広瀬川クリニック", "群馬県"));
                    m_Data.Add(new DispCode("100468", "日高リハビリテーション病院", "群馬県"));
                    m_Data.Add(new DispCode("100479", "赤城クリニック", "群馬県"));
                    m_Data.Add(new DispCode("100489", "島田クリニック", "群馬県"));
                    m_Data.Add(new DispCode("100508", "堀江病院", "群馬県"));
                    m_Data.Add(new DispCode("100518", "おうら病院", "群馬県"));
                    m_Data.Add(new DispCode("100528", "関越中央病院", "群馬県"));
                    m_Data.Add(new DispCode("100539", "大胡クリニック", "群馬県"));
                    m_Data.Add(new DispCode("100549", "呑龍クリニック", "群馬県"));
                    m_Data.Add(new DispCode("100559", "ごが内科楡クリニック", "群馬県"));
                    m_Data.Add(new DispCode("100569", "上毛大橋クリニック", "群馬県"));
                    m_Data.Add(new DispCode("100579", "平成日高クリニック", "群馬県"));
                    m_Data.Add(new DispCode("100589", "ひかりクリニック", "群馬県"));
                    m_Data.Add(new DispCode("100599", "土屋クリニック", "群馬県"));
                    m_Data.Add(new DispCode("100629", "太田じんクリニック", "群馬県"));
                    m_Data.Add(new DispCode("100639", "くりはら医院", "群馬県"));
                    m_Data.Add(new DispCode("100658", "北関東循環器病院", "群馬県"));
                    m_Data.Add(new DispCode("100668", "沼田脳神経外科循環器科病院", "群馬県"));
                    m_Data.Add(new DispCode("100698", "光病院", "群馬県"));
                    m_Data.Add(new DispCode("100709", "古作クリニック韮塚分院", "群馬県"));
                    m_Data.Add(new DispCode("100719", "古作クリニック東分院", "群馬県"));
                    m_Data.Add(new DispCode("100729", "古作クリニック玉村分院", "群馬県"));
                    m_Data.Add(new DispCode("100738", "（医）博仁会第一病院", "群馬県"));
                    m_Data.Add(new DispCode("100749", "細谷透析クリニック", "群馬県"));
                    m_Data.Add(new DispCode("100758", "松井田病院", "群馬県"));
                    m_Data.Add(new DispCode("100769", "太田糖尿病クリニック", "群馬県"));
                    m_Data.Add(new DispCode("100772", "高崎総合医療センター", "群馬県"));
                    m_Data.Add(new DispCode("100789", "細谷腎クリニック藤岡", "群馬県"));
                    m_Data.Add(new DispCode("107049", "櫻井医院", "群馬県"));
                    m_Data.Add(new DispCode("110019", "赤心クリニック", "埼玉県"));
                    m_Data.Add(new DispCode("110023", "川口市立医療センター", "埼玉県"));
                    m_Data.Add(new DispCode("110039", "ウメヅ医院", "埼玉県"));
                    m_Data.Add(new DispCode("110048", "齋藤記念病院", "埼玉県"));
                    m_Data.Add(new DispCode("110054", "埼玉メディカルセンター", "埼玉県"));
                    m_Data.Add(new DispCode("110079", "宮村医院", "埼玉県"));
                    m_Data.Add(new DispCode("110087", "丸山記念総合病院", "埼玉県"));
                    m_Data.Add(new DispCode("110098", "秀和総合病院", "埼玉県"));
                    m_Data.Add(new DispCode("110108", "西狭山病院", "埼玉県"));
                    m_Data.Add(new DispCode("110116", "深谷赤十字病院", "埼玉県"));
                    m_Data.Add(new DispCode("110127", "上尾中央総合病院", "埼玉県"));
                    m_Data.Add(new DispCode("110136", "さいたま赤十字病院", "埼玉県"));
                    m_Data.Add(new DispCode("110143", "蕨市立病院", "埼玉県"));
                    m_Data.Add(new DispCode("110158", "埼友草加病院", "埼玉県"));
                    m_Data.Add(new DispCode("110167", "戸田中央総合病院", "埼玉県"));
                    m_Data.Add(new DispCode("110179", "くぼじまクリニック", "埼玉県"));
                    m_Data.Add(new DispCode("110191", "埼玉医科大学病院", "埼玉県"));
                    m_Data.Add(new DispCode("110208", "関越病院", "埼玉県"));
                    m_Data.Add(new DispCode("110218", "春日部嬉泉病院", "埼玉県"));
                    m_Data.Add(new DispCode("110228", "今井病院", "埼玉県"));
                    m_Data.Add(new DispCode("110238", "望星病院", "埼玉県"));
                    m_Data.Add(new DispCode("110248", "伊奈病院", "埼玉県"));
                    m_Data.Add(new DispCode("110268", "岩槻南病院", "埼玉県"));
                    m_Data.Add(new DispCode("110279", "こいづかクリニック", "埼玉県"));
                    m_Data.Add(new DispCode("110330", "防衛医科大学校病院", "埼玉県"));
                    m_Data.Add(new DispCode("110348", "池袋病院", "埼玉県"));
                    m_Data.Add(new DispCode("110358", "武蔵台病院", "埼玉県"));
                    m_Data.Add(new DispCode("110368", "中島病院", "埼玉県"));
                    m_Data.Add(new DispCode("110377", "菅野病院", "埼玉県"));
                    m_Data.Add(new DispCode("110388", "宏仁会小川病院", "埼玉県"));
                    m_Data.Add(new DispCode("110399", "友愛クリニック", "埼玉県"));
                    m_Data.Add(new DispCode("110406", "埼玉県済生会川口総合病院", "埼玉県"));
                    m_Data.Add(new DispCode("110419", "松本クリニック", "埼玉県"));
                    m_Data.Add(new DispCode("110428", "春日部さくら病院", "埼玉県"));
                    m_Data.Add(new DispCode("110437", "彩の国東大宮メディカルセンター", "埼玉県"));
                    m_Data.Add(new DispCode("110443", "秩父市立病院", "埼玉県"));
                    m_Data.Add(new DispCode("110478", "みさと健和病院", "埼玉県"));
                    m_Data.Add(new DispCode("110498", "堀ノ内病院", "埼玉県"));
                    m_Data.Add(new DispCode("110519", "ＴＭＧサテライトクリニック朝霞台", "埼玉県"));
                    m_Data.Add(new DispCode("110527", "羽生総合病院", "埼玉県"));
                    m_Data.Add(new DispCode("110531", "埼玉医科大学総合医療センター", "埼玉県"));
                    m_Data.Add(new DispCode("110569", "益子腎臓内科透析クリニック", "埼玉県"));
                    m_Data.Add(new DispCode("110579", "埼仁クリニック蕨", "埼玉県"));
                    m_Data.Add(new DispCode("110583", "さいたま市立病院", "埼玉県"));
                    m_Data.Add(new DispCode("110599", "あけとクリニック", "埼玉県"));
                    m_Data.Add(new DispCode("110608", "埼玉石心会病院", "埼玉県"));
                    m_Data.Add(new DispCode("110629", "上福岡腎クリニック", "埼玉県"));
                    m_Data.Add(new DispCode("110639", "北本第一クリニック", "埼玉県"));
                    m_Data.Add(new DispCode("110648", "岡病院", "埼玉県"));
                    m_Data.Add(new DispCode("110668", "金子病院", "埼玉県"));
                    m_Data.Add(new DispCode("110679", "川越駅前クリニック", "埼玉県"));
                    m_Data.Add(new DispCode("110688", "北里大学メディカルセンター", "埼玉県"));
                    m_Data.Add(new DispCode("110699", "所沢くすのき台クリニック", "埼玉県"));
                    m_Data.Add(new DispCode("110706", "埼玉県済生会加須病院", "埼玉県"));
                    m_Data.Add(new DispCode("110718", "埼玉筑波病院", "埼玉県"));
                    m_Data.Add(new DispCode("110727", "八潮中央総合病院", "埼玉県"));
                    m_Data.Add(new DispCode("110738", "慶和病院", "埼玉県"));
                    m_Data.Add(new DispCode("110749", "上尾中央総合病院附属エイトナインクリニック", "埼玉県"));
                    m_Data.Add(new DispCode("110751", "自治医科大学附属さいたま医療センター", "埼玉県"));
                    m_Data.Add(new DispCode("110769", "埼友クリニック", "埼玉県"));
                    m_Data.Add(new DispCode("110779", "吉沢医院", "埼玉県"));
                    m_Data.Add(new DispCode("110789", "所沢腎クリニック", "埼玉県"));
                    m_Data.Add(new DispCode("110799", "陽山会クリニック", "埼玉県"));
                    m_Data.Add(new DispCode("110818", "埼玉県央病院", "埼玉県"));
                    m_Data.Add(new DispCode("110829", "所沢石川クリニック", "埼玉県"));
                    m_Data.Add(new DispCode("110839", "大宮西口クリニック", "埼玉県"));
                    m_Data.Add(new DispCode("110857", "上福岡総合病院", "埼玉県"));
                    m_Data.Add(new DispCode("110868", "騎西病院", "埼玉県"));
                    m_Data.Add(new DispCode("110879", "みさと健和クリニック", "埼玉県"));
                    m_Data.Add(new DispCode("110889", "鶴ヶ島駅前クリニック", "埼玉県"));
                    m_Data.Add(new DispCode("110899", "東飯能駅前クリニック", "埼玉県"));
                    m_Data.Add(new DispCode("110928", "武蔵嵐山病院", "埼玉県"));
                    m_Data.Add(new DispCode("110937", "三愛会総合病院", "埼玉県"));
                    m_Data.Add(new DispCode("110949", "さつき診療所", "埼玉県"));
                    m_Data.Add(new DispCode("110959", "宏仁会高坂醫院", "埼玉県"));
                    m_Data.Add(new DispCode("110968", "さくら記念病院", "埼玉県"));
                    m_Data.Add(new DispCode("110973", "埼玉県立小児医療センター", "埼玉県"));
                    m_Data.Add(new DispCode("110989", "みずほ台サンクリニック", "埼玉県"));
                    m_Data.Add(new DispCode("110999", "和光クリニック", "埼玉県"));
                    m_Data.Add(new DispCode("111009", "川口六間クリニック", "埼玉県"));
                    m_Data.Add(new DispCode("111019", "志木駅前クリニック", "埼玉県"));
                    m_Data.Add(new DispCode("111029", "鴻巣第一クリニック", "埼玉県"));
                    m_Data.Add(new DispCode("111039", "望星クリニック", "埼玉県"));
                    m_Data.Add(new DispCode("111059", "須田医院", "埼玉県"));
                    m_Data.Add(new DispCode("111069", "東松山宏仁クリニック", "埼玉県"));
                    m_Data.Add(new DispCode("111079", "入間台クリニック", "埼玉県"));
                    m_Data.Add(new DispCode("111087", "三郷中央総合病院", "埼玉県"));
                    m_Data.Add(new DispCode("111108", "さくら眼科・内科", "埼玉県"));
                    m_Data.Add(new DispCode("111118", "南古谷病院", "埼玉県"));
                    m_Data.Add(new DispCode("111128", "みさと協立病院", "埼玉県"));
                    m_Data.Add(new DispCode("111139", "幸手クリニック", "埼玉県"));
                    m_Data.Add(new DispCode("111149", "友愛みぬまクリニック", "埼玉県"));
                    m_Data.Add(new DispCode("111159", "朝比奈医院", "埼玉県"));
                    m_Data.Add(new DispCode("111165", "埼玉協同病院", "埼玉県"));
                    m_Data.Add(new DispCode("111177", "新座志木中央総合病院", "埼玉県"));
                    m_Data.Add(new DispCode("111199", "航空公園西口内科", "埼玉県"));
                    m_Data.Add(new DispCode("111208", "秩父第一病院", "埼玉県"));
                    m_Data.Add(new DispCode("111219", "友愛日進クリニック", "埼玉県"));
                    m_Data.Add(new DispCode("111229", "加須ふれあいクリニック", "埼玉県"));
                    m_Data.Add(new DispCode("111239", "入間駅前クリニック", "埼玉県"));
                    m_Data.Add(new DispCode("111249", "アベル内科クリニック", "埼玉県"));
                    m_Data.Add(new DispCode("111259", "台坂クリニック", "埼玉県"));
                    m_Data.Add(new DispCode("111298", "圏央所沢病院", "埼玉県"));
                    m_Data.Add(new DispCode("111309", "秀和総合病院附属　秀和透析クリニック", "埼玉県"));
                    m_Data.Add(new DispCode("111318", "蓮田一心会病院", "埼玉県"));
                    m_Data.Add(new DispCode("111328", "富家病院", "埼玉県"));
                    m_Data.Add(new DispCode("111349", "南古谷クリニック", "埼玉県"));
                    m_Data.Add(new DispCode("111359", "角田クリニック", "埼玉県"));
                    m_Data.Add(new DispCode("111368", "東都春日部病院", "埼玉県"));
                    m_Data.Add(new DispCode("111379", "さきたまクリニック", "埼玉県"));
                    m_Data.Add(new DispCode("111389", "行田ふれあいクリニック", "埼玉県"));
                    m_Data.Add(new DispCode("111399", "寄居本町クリニック", "埼玉県"));
                    m_Data.Add(new DispCode("111408", "皆野病院", "埼玉県"));
                    m_Data.Add(new DispCode("111417", "行田総合病院", "埼玉県"));
                    m_Data.Add(new DispCode("111427", "行田中央総合病院", "埼玉県"));
                    m_Data.Add(new DispCode("111439", "埼友川口クリニック", "埼玉県"));
                    m_Data.Add(new DispCode("111445", "新久喜総合病院", "埼玉県"));
                    m_Data.Add(new DispCode("111458", "蓮田病院", "埼玉県"));
                    m_Data.Add(new DispCode("111469", "新河岸腎クリニック", "埼玉県"));
                    m_Data.Add(new DispCode("111479", "パークタウンクリニック", "埼玉県"));
                    m_Data.Add(new DispCode("111489", "さやま腎クリニック", "埼玉県"));
                    m_Data.Add(new DispCode("111499", "春日部泌尿器科・内科クリニック", "埼玉県"));
                    m_Data.Add(new DispCode("111509", "東松山メディカルクリニック", "埼玉県"));
                    m_Data.Add(new DispCode("111519", "友愛三橋クリニック", "埼玉県"));
                    m_Data.Add(new DispCode("111527", "春日部中央総合病院", "埼玉県"));
                    m_Data.Add(new DispCode("111539", "岡村記念クリニック", "埼玉県"));
                    m_Data.Add(new DispCode("111549", "桶川腎クリニック", "埼玉県"));
                    m_Data.Add(new DispCode("111559", "板倉クリニック", "埼玉県"));
                    m_Data.Add(new DispCode("111569", "越谷大袋クリニック", "埼玉県"));
                    m_Data.Add(new DispCode("111579", "久喜クリニック", "埼玉県"));
                    m_Data.Add(new DispCode("111589", "川本メディカルクリニック", "埼玉県"));
                    m_Data.Add(new DispCode("111609", "イムス三郷クリニック", "埼玉県"));
                    m_Data.Add(new DispCode("111619", "おおしまクリニック", "埼玉県"));
                    m_Data.Add(new DispCode("111629", "あさひ診療所", "埼玉県"));
                    m_Data.Add(new DispCode("111638", "こうのす共生病院", "埼玉県"));
                    m_Data.Add(new DispCode("111649", "大宮𠮷沢クリニック", "埼玉県"));
                    m_Data.Add(new DispCode("111659", "けやきクリニック", "埼玉県"));
                    m_Data.Add(new DispCode("111669", "北朝霞駅前クリニック", "埼玉県"));
                    m_Data.Add(new DispCode("111679", "越生メディカルクリニック", "埼玉県"));
                    m_Data.Add(new DispCode("111697", "白岡中央総合病院", "埼玉県"));
                    m_Data.Add(new DispCode("111709", "長瀞医新クリニック", "埼玉県"));
                    m_Data.Add(new DispCode("111718", "シャローム病院", "埼玉県"));
                    m_Data.Add(new DispCode("111729", "桶川おかもと腎クリニック", "埼玉県"));
                    m_Data.Add(new DispCode("111739", "齋藤記念クリニック", "埼玉県"));
                    m_Data.Add(new DispCode("111748", "イムス三芳総合病院", "埼玉県"));
                    m_Data.Add(new DispCode("111759", "さいたま つきの森クリニック", "埼玉県"));
                    m_Data.Add(new DispCode("111769", "戸田中央腎クリニック", "埼玉県"));
                    m_Data.Add(new DispCode("111779", "上尾中央腎クリニック", "埼玉県"));
                    m_Data.Add(new DispCode("111789", "かみのクリニック", "埼玉県"));
                    m_Data.Add(new DispCode("111801", "埼玉医科大学国際医療センター", "埼玉県"));
                    m_Data.Add(new DispCode("111818", "東鷲宮病院", "埼玉県"));
                    m_Data.Add(new DispCode("111829", "川越南腎クリニック", "埼玉県"));
                    m_Data.Add(new DispCode("111847", "イムス富士見総合病院", "埼玉県"));
                    m_Data.Add(new DispCode("111859", "康正会総合クリニック", "埼玉県"));
                    m_Data.Add(new DispCode("111869", "湯本フラワー通りクリニック", "埼玉県"));
                    m_Data.Add(new DispCode("111877", "大宮中央総合病院", "埼玉県"));
                    m_Data.Add(new DispCode("111909", "若葉内科クリニック", "埼玉県"));
                    m_Data.Add(new DispCode("111919", "くまがやクリニック", "埼玉県"));
                    m_Data.Add(new DispCode("111929", "さいたまほのかクリニック", "埼玉県"));
                    m_Data.Add(new DispCode("111939", "益山クリニック", "埼玉県"));
                    m_Data.Add(new DispCode("111949", "霞ヶ関腎クリニック", "埼玉県"));
                    m_Data.Add(new DispCode("111959", "西大宮腎クリニック", "埼玉県"));
                    m_Data.Add(new DispCode("111961", "獨協医科大学埼玉医療センター", "埼玉県"));
                    m_Data.Add(new DispCode("111979", "小林内科医院", "埼玉県"));
                    m_Data.Add(new DispCode("111989", "富家在宅リハビリテーションケアセンタークリニック", "埼玉県"));
                    m_Data.Add(new DispCode("111993", "草加市立病院", "埼玉県"));
                    m_Data.Add(new DispCode("112009", "こくさいじクリニック", "埼玉県"));
                    m_Data.Add(new DispCode("112029", "上尾駅前クリニック", "埼玉県"));
                    m_Data.Add(new DispCode("112039", "北浦和腎クリニック", "埼玉県"));
                    m_Data.Add(new DispCode("112059", "第二齋藤記念クリニック", "埼玉県"));
                    m_Data.Add(new DispCode("112068", "入間川病院", "埼玉県"));
                    m_Data.Add(new DispCode("112078", "上尾中央第二病院", "埼玉県"));
                    m_Data.Add(new DispCode("112088", "埼玉セントラル病院", "埼玉県"));
                    m_Data.Add(new DispCode("112098", "飯能老年病センター", "埼玉県"));
                    m_Data.Add(new DispCode("112108", "狭山尚寿会病院", "埼玉県"));
                    m_Data.Add(new DispCode("112134", "JCHOさいたま北部医療センター", "埼玉県"));
                    m_Data.Add(new DispCode("112149", "あさか台透析クリニック", "埼玉県"));
                    m_Data.Add(new DispCode("112159", "鶴瀬腎クリニック", "埼玉県"));
                    m_Data.Add(new DispCode("112169", "おばら内科腎クリニック", "埼玉県"));
                    m_Data.Add(new DispCode("112179", "ふじみ野腎クリニック", "埼玉県"));
                    m_Data.Add(new DispCode("112189", "春陽苑にこにこクリニック", "埼玉県"));
                    m_Data.Add(new DispCode("112198", "桃泉園北本病院", "埼玉県"));
                    m_Data.Add(new DispCode("112209", "みどりクリニック 透析センター", "埼玉県"));
                    m_Data.Add(new DispCode("112219", "春日部嬉泉病院附属クリニック", "埼玉県"));
                    m_Data.Add(new DispCode("112228", "ＴＭＧ宗岡中央病院", "埼玉県"));
                    m_Data.Add(new DispCode("112233", "埼玉県立循環器・呼吸器病センター", "埼玉県"));
                    m_Data.Add(new DispCode("112249", "関越腎クリニック", "埼玉県"));
                    m_Data.Add(new DispCode("112258", "ＴＭＧあさか医療センター", "埼玉県"));
                    m_Data.Add(new DispCode("112269", "彩の森 草加クリニック", "埼玉県"));
                    m_Data.Add(new DispCode("112279", "望星東クリニック", "埼玉県"));
                    m_Data.Add(new DispCode("112289", "宮原腎クリニック", "埼玉県"));
                    m_Data.Add(new DispCode("112299", "はんのう内科・腎クリニック", "埼玉県"));
                    m_Data.Add(new DispCode("112309", "さやま地域ケアクリニック", "埼玉県"));
                    m_Data.Add(new DispCode("112319", "北戸田駅前クリニック", "埼玉県"));
                    m_Data.Add(new DispCode("112328", "東川口病院", "埼玉県"));
                    m_Data.Add(new DispCode("112339", "埼友八潮クリニック", "埼玉県"));
                    m_Data.Add(new DispCode("112349", "かわぐち新井宿透析クリニック", "埼玉県"));
                    m_Data.Add(new DispCode("112359", "所沢ハートセンター", "埼玉県"));
                    m_Data.Add(new DispCode("112368", "楽仙堂病院", "埼玉県"));
                    m_Data.Add(new DispCode("112378", "栗橋病院", "埼玉県"));
                    m_Data.Add(new DispCode("112389", "はなぞのクリニック", "埼玉県"));
                    m_Data.Add(new DispCode("112399", "聖蹟プライムクリニック", "埼玉県"));
                    m_Data.Add(new DispCode("117048", "熊谷総合病院", "埼玉県"));
                    m_Data.Add(new DispCode("120020", "千葉大学医学部附属病院", "千葉県"));
                    m_Data.Add(new DispCode("120044", "JCHO千葉病院", "千葉県"));
                    m_Data.Add(new DispCode("120058", "みはま病院", "千葉県"));
                    m_Data.Add(new DispCode("120068", "平山病院", "千葉県"));
                    m_Data.Add(new DispCode("120078", "北習志野花輪病院", "千葉県"));
                    m_Data.Add(new DispCode("120098", "東葛クリニック病院", "千葉県"));
                    m_Data.Add(new DispCode("120118", "山之内病院", "千葉県"));
                    m_Data.Add(new DispCode("120123", "聖隷佐倉市民病院", "千葉県"));
                    m_Data.Add(new DispCode("120139", "東葛クリニック柏", "千葉県"));
                    m_Data.Add(new DispCode("120143", "総合病院国保旭中央病院", "千葉県"));
                    m_Data.Add(new DispCode("120157", "亀田総合病院", "千葉県"));
                    m_Data.Add(new DispCode("120168", "玄々堂君津病院", "千葉県"));
                    m_Data.Add(new DispCode("120188", "三愛記念病院", "千葉県"));
                    m_Data.Add(new DispCode("120219", "市川クリニック", "千葉県"));
                    m_Data.Add(new DispCode("120229", "津田沼医院", "千葉県"));
                    m_Data.Add(new DispCode("120239", "東葛クリニック野田", "千葉県"));
                    m_Data.Add(new DispCode("120259", "東葛クリニック市川", "千葉県"));
                    m_Data.Add(new DispCode("120279", "みはま佐倉クリニック", "千葉県"));
                    m_Data.Add(new DispCode("120299", "東葛クリニック新松戸", "千葉県"));
                    m_Data.Add(new DispCode("120327", "島田総合病院", "千葉県"));
                    m_Data.Add(new DispCode("120334", "安房地域医療センター", "千葉県"));
                    m_Data.Add(new DispCode("120351", "帝京大学ちば総合医療センター", "千葉県"));
                    m_Data.Add(new DispCode("120369", "原村医院", "千葉県"));
                    m_Data.Add(new DispCode("120378", "千葉徳洲会病院", "千葉県"));
                    m_Data.Add(new DispCode("120389", "南浜診療所", "千葉県"));
                    m_Data.Add(new DispCode("120399", "三愛記念市原クリニック", "千葉県"));
                    m_Data.Add(new DispCode("120401", "東京慈恵会医科大学附属柏病院", "千葉県"));
                    m_Data.Add(new DispCode("120419", "みはま成田クリニック", "千葉県"));
                    m_Data.Add(new DispCode("120428", "セントマーガレット病院", "千葉県"));
                    m_Data.Add(new DispCode("120439", "新南行徳クリニック", "千葉県"));
                    m_Data.Add(new DispCode("120448", "塩田病院", "千葉県"));
                    m_Data.Add(new DispCode("120459", "東葛クリニック八柱", "千葉県"));
                    m_Data.Add(new DispCode("120468", "東葛病院", "千葉県"));
                    m_Data.Add(new DispCode("120487", "千葉西総合病院", "千葉県"));
                    m_Data.Add(new DispCode("120508", "船橋二和病院", "千葉県"));
                    m_Data.Add(new DispCode("120519", "浦安駅前クリニック", "千葉県"));
                    m_Data.Add(new DispCode("120539", "新柏クリニック", "千葉県"));
                    m_Data.Add(new DispCode("120559", "前田記念腎研究所茂原クリニック", "千葉県"));
                    m_Data.Add(new DispCode("120567", "みつわ台総合病院", "千葉県"));
                    m_Data.Add(new DispCode("120598", "四街道さくら病院", "千葉県"));
                    m_Data.Add(new DispCode("120609", "望星姉崎クリニック", "千葉県"));
                    m_Data.Add(new DispCode("120618", "五井病院", "千葉県"));
                    m_Data.Add(new DispCode("120629", "東葛クリニック我孫子", "千葉県"));
                    m_Data.Add(new DispCode("120639", "東葉クリニック昭和の森", "千葉県"));
                    m_Data.Add(new DispCode("120641", "東京歯科大学市川総合病院", "千葉県"));
                    m_Data.Add(new DispCode("120658", "たむら記念病院", "千葉県"));
                    m_Data.Add(new DispCode("120686", "成田赤十字病院", "千葉県"));
                    m_Data.Add(new DispCode("120691", "日本医科大学千葉北総病院", "千葉県"));
                    m_Data.Add(new DispCode("120707", "津田沼中央総合病院", "千葉県"));
                    m_Data.Add(new DispCode("120719", "東葛クリニック松戸", "千葉県"));
                    m_Data.Add(new DispCode("120739", "八千代第一クリニック", "千葉県"));
                    m_Data.Add(new DispCode("120749", "東葉クリニック八日市場", "千葉県"));
                    m_Data.Add(new DispCode("120759", "東葉クリニック八街", "千葉県"));
                    m_Data.Add(new DispCode("120768", "大島記念嬉泉病院", "千葉県"));
                    m_Data.Add(new DispCode("120779", "本八幡腎クリニック", "千葉県"));
                    m_Data.Add(new DispCode("120808", "稲毛病院", "千葉県"));
                    m_Data.Add(new DispCode("120819", "柏フォレストクリニック", "千葉県"));
                    m_Data.Add(new DispCode("120829", "ひまわりクリニック", "千葉県"));
                    m_Data.Add(new DispCode("120838", "幸有会記念病院", "千葉県"));
                    m_Data.Add(new DispCode("120849", "東葉クリニック大網", "千葉県"));
                    m_Data.Add(new DispCode("120858", "白井聖仁会病院", "千葉県"));
                    m_Data.Add(new DispCode("120869", "椎名崎クリニック", "千葉県"));
                    m_Data.Add(new DispCode("120878", "山王病院", "千葉県"));
                    m_Data.Add(new DispCode("120887", "行徳総合病院", "千葉県"));
                    m_Data.Add(new DispCode("120899", "玄々堂木更津クリニック", "千葉県"));
                    m_Data.Add(new DispCode("120918", "セコメディック病院", "千葉県"));
                    m_Data.Add(new DispCode("120928", "千葉中央メディカルセンター", "千葉県"));
                    m_Data.Add(new DispCode("120939", "前田記念大原クリニック", "千葉県"));
                    m_Data.Add(new DispCode("120947", "野田総合病院", "千葉県"));
                    m_Data.Add(new DispCode("120959", "原クリニック", "千葉県"));
                    m_Data.Add(new DispCode("120979", "三愛記念そがクリニック", "千葉県"));
                    m_Data.Add(new DispCode("120989", "八柱腎クリニック", "千葉県"));
                    m_Data.Add(new DispCode("120998", "新八街総合病院", "千葉県"));
                    m_Data.Add(new DispCode("121009", "船越クリニック", "千葉県"));
                    m_Data.Add(new DispCode("121018", "我孫子東邦病院", "千葉県"));
                    m_Data.Add(new DispCode("121028", "北柏リハビリ総合病院", "千葉県"));
                    m_Data.Add(new DispCode("121039", "薬円台泌尿器科腎クリニック", "千葉県"));
                    m_Data.Add(new DispCode("121049", "木更津クリニック", "千葉県"));
                    m_Data.Add(new DispCode("121058", "千葉愛友会記念病院", "千葉県"));
                    m_Data.Add(new DispCode("121068", "市川東病院", "千葉県"));
                    m_Data.Add(new DispCode("121073", "千葉県こども病院", "千葉県"));
                    m_Data.Add(new DispCode("121089", "船橋本町クリニック", "千葉県"));
                    m_Data.Add(new DispCode("121099", "東葉クリニック・エアポート", "千葉県"));
                    m_Data.Add(new DispCode("121108", "富家千葉病院", "千葉県"));
                    m_Data.Add(new DispCode("121128", "野田中央病院", "千葉県"));
                    m_Data.Add(new DispCode("121147", "新松戸中央総合病院", "千葉県"));
                    m_Data.Add(new DispCode("121169", "花輪クリニック", "千葉県"));
                    m_Data.Add(new DispCode("121179", "千葉横戸クリニック", "千葉県"));
                    m_Data.Add(new DispCode("121183", "香取おみがわ医療センター", "千葉県"));
                    m_Data.Add(new DispCode("121199", "鎌ヶ谷第一クリニック", "千葉県"));
                    m_Data.Add(new DispCode("121202", "千葉東病院", "千葉県"));
                    m_Data.Add(new DispCode("121211", "順天堂大学医学部附属浦安病院", "千葉県"));
                    m_Data.Add(new DispCode("121229", "いなげ腎クリニック", "千葉県"));
                    m_Data.Add(new DispCode("121239", "むなかたクリニック", "千葉県"));
                    m_Data.Add(new DispCode("121248", "栗山中央病院", "千葉県"));
                    m_Data.Add(new DispCode("121259", "袖ヶ浦クリニック", "千葉県"));
                    m_Data.Add(new DispCode("121269", "千葉北総内科クリニック", "千葉県"));
                    m_Data.Add(new DispCode("121278", "中原病院", "千葉県"));
                    m_Data.Add(new DispCode("121288", "おおたかの森病院", "千葉県"));
                    m_Data.Add(new DispCode("121299", "東葉クリニック佐原", "千葉県"));
                    m_Data.Add(new DispCode("121309", "さとうクリニック", "千葉県"));
                    m_Data.Add(new DispCode("121319", "東葛病院付属診療所 サテライト透析室", "千葉県"));
                    m_Data.Add(new DispCode("121329", "行徳じんクリニック", "千葉県"));
                    m_Data.Add(new DispCode("121339", "習志野腎クリニック", "千葉県"));
                    m_Data.Add(new DispCode("121348", "四街道徳洲会病院", "千葉県"));
                    m_Data.Add(new DispCode("121359", "亀田ファミリークリニック館山", "千葉県"));
                    m_Data.Add(new DispCode("121369", "鈴木内科クリニック", "千葉県"));
                    m_Data.Add(new DispCode("121379", "みはま香取クリニック", "千葉県"));
                    m_Data.Add(new DispCode("121388", "成田病院", "千葉県"));
                    m_Data.Add(new DispCode("121398", "柏たなか病院", "千葉県"));
                    m_Data.Add(new DispCode("121409", "八千代腎クリニック", "千葉県"));
                    m_Data.Add(new DispCode("121418", "上総記念病院", "千葉県"));
                    m_Data.Add(new DispCode("121421", "東京女子医科大学附属八千代医療センター", "千葉県"));
                    m_Data.Add(new DispCode("121438", "我孫子聖仁会病院", "千葉県"));
                    m_Data.Add(new DispCode("121449", "五井クリニック", "千葉県"));
                    m_Data.Add(new DispCode("121458", "大野中央病院", "千葉県"));
                    m_Data.Add(new DispCode("121469", "小見川ひまわりクリニック", "千葉県"));
                    m_Data.Add(new DispCode("121477", "鎌ケ谷総合病院", "千葉県"));
                    m_Data.Add(new DispCode("121489", "秀和会クリニック", "千葉県"));
                    m_Data.Add(new DispCode("121491", "国際医療福祉大学市川病院", "千葉県"));
                    m_Data.Add(new DispCode("121509", "新柏クリニックおおたかの森", "千葉県"));
                    m_Data.Add(new DispCode("121518", "三橋明生病院", "千葉県"));
                    m_Data.Add(new DispCode("121527", "柏厚生総合病院", "千葉県"));
                    m_Data.Add(new DispCode("121539", "八幡クリニック", "千葉県"));
                    m_Data.Add(new DispCode("121548", "館山病院", "千葉県"));
                    m_Data.Add(new DispCode("121553", "国保直営総合病院君津中央病院", "千葉県"));
                    m_Data.Add(new DispCode("121579", "アクロスモール新鎌ヶ谷クリニック", "千葉県"));
                    m_Data.Add(new DispCode("121588", "千葉・柏リハビリテーション病院", "千葉県"));
                    m_Data.Add(new DispCode("121599", "東葉クリニック東新宿", "千葉県"));
                    m_Data.Add(new DispCode("121603", "東京ベイ・浦安市川医療センター", "千葉県"));
                    m_Data.Add(new DispCode("121617", "船橋総合病院", "千葉県"));
                    m_Data.Add(new DispCode("121639", "あずま腎クリニック", "千葉県"));
                    m_Data.Add(new DispCode("121649", "南柏駅前クリニック", "千葉県"));
                    m_Data.Add(new DispCode("121669", "高洲訪問クリニック", "千葉県"));
                    m_Data.Add(new DispCode("121673", "千葉県循環器病センター", "千葉県"));
                    m_Data.Add(new DispCode("121689", "しょうじゅクリニック", "千葉県"));
                    m_Data.Add(new DispCode("121709", "松戸第一クリニック", "千葉県"));
                    m_Data.Add(new DispCode("121729", "緑が丘メディカルクリニック", "千葉県"));
                    m_Data.Add(new DispCode("121738", "平和台病院", "千葉県"));
                    m_Data.Add(new DispCode("121748", "北総白井病院", "千葉県"));
                    m_Data.Add(new DispCode("121758", "成田富里徳洲会病院", "千葉県"));
                    m_Data.Add(new DispCode("121761", "東邦大学医療センター佐倉病院", "千葉県"));
                    m_Data.Add(new DispCode("121779", "土気腎クリニック", "千葉県"));
                    m_Data.Add(new DispCode("121789", "玄々堂じんクリニック", "千葉県"));
                    m_Data.Add(new DispCode("121799", "東船橋クリニック", "千葉県"));
                    m_Data.Add(new DispCode("121809", "ＲＯＳＥ ＧＡＲＤＥＮクリニック", "千葉県"));
                    m_Data.Add(new DispCode("121813", "船橋市立医療センター", "千葉県"));
                    m_Data.Add(new DispCode("121829", "おもて内科糖尿病クリニック", "千葉県"));
                    m_Data.Add(new DispCode("121839", "青い鳥クリニック千葉", "千葉県"));
                    m_Data.Add(new DispCode("121849", "五井病院ホームケアクリニック", "千葉県"));
                    m_Data.Add(new DispCode("121859", "れいわクリニック", "千葉県"));
                    m_Data.Add(new DispCode("121869", "柏なかおクリニック", "千葉県"));
                    m_Data.Add(new DispCode("121871", "国際医療福祉大学成田病院", "千葉県"));
                    m_Data.Add(new DispCode("121889", "ユーカリが丘・腎・内科クリニック", "千葉県"));
                    m_Data.Add(new DispCode("121899", "船橋訪問クリニック", "千葉県"));
                    m_Data.Add(new DispCode("121909", "行徳そらまめクリニック", "千葉県"));
                    m_Data.Add(new DispCode("121919", "いんざいさくらクリニック", "千葉県"));
                    m_Data.Add(new DispCode("121929", "千葉ニュータウン駅前腎クリニック", "千葉県"));
                    m_Data.Add(new DispCode("121938", "いなげ西病院", "千葉県"));
                    m_Data.Add(new DispCode("121949", "新浦安腎クリニック", "千葉県"));
                    m_Data.Add(new DispCode("121958", "千葉南病院", "千葉県"));
                    m_Data.Add(new DispCode("121969", "いちかわ透析クリニック", "千葉県"));
                    m_Data.Add(new DispCode("127098", "名戸ヶ谷病院", "千葉県"));
                    m_Data.Add(new DispCode("130011", "日本大学病院", "東京都"));
                    m_Data.Add(new DispCode("130029", "日本医科大学腎クリニック", "東京都"));
                    m_Data.Add(new DispCode("130036", "東京警察病院", "東京都"));
                    m_Data.Add(new DispCode("130046", "東京逓信病院", "東京都"));
                    m_Data.Add(new DispCode("130058", "三井記念病院", "東京都"));
                    m_Data.Add(new DispCode("130078", "半蔵門病院", "東京都"));
                    m_Data.Add(new DispCode("130108", "聖路加国際病院", "東京都"));
                    m_Data.Add(new DispCode("130119", "中島クリニック", "東京都"));
                    m_Data.Add(new DispCode("130131", "東京慈恵会医科大学附属病院", "東京都"));
                    m_Data.Add(new DispCode("130196", "東京都済生会中央病院", "東京都"));
                    m_Data.Add(new DispCode("130201", "慶應義塾大学医学部 血液浄化・透析センター", "東京都"));
                    m_Data.Add(new DispCode("130211", "東京医科大学", "東京都"));
                    m_Data.Add(new DispCode("130241", "東京女子医科大学腎臓病総合医療センター", "東京都"));
                    m_Data.Add(new DispCode("130259", "練馬中央診療所", "東京都"));
                    m_Data.Add(new DispCode("130269", "代々木ステーションクリニック", "東京都"));
                    m_Data.Add(new DispCode("130284", "東京山手メディカルセンター", "東京都"));
                    m_Data.Add(new DispCode("130292", "国立国際医療研究センター病院", "東京都"));
                    m_Data.Add(new DispCode("130304", "JCHO東京新宿メディカルセンター", "東京都"));
                    m_Data.Add(new DispCode("130339", "腎研クリニック", "東京都"));
                    m_Data.Add(new DispCode("130349", "望星新宿南口クリニック", "東京都"));
                    m_Data.Add(new DispCode("130353", "市立青梅総合医療センター", "東京都"));
                    m_Data.Add(new DispCode("130379", "須田クリニック", "東京都"));
                    m_Data.Add(new DispCode("130399", "あけぼのクリニック", "東京都"));
                    m_Data.Add(new DispCode("130409", "城田医院", "東京都"));
                    m_Data.Add(new DispCode("130411", "日本医科大学付属病院", "東京都"));
                    m_Data.Add(new DispCode("130421", "順天堂大学医学部附属順天堂医院", "東京都"));
                    m_Data.Add(new DispCode("130431", "慶應義塾大学医学部", "東京都"));
                    m_Data.Add(new DispCode("130449", "中野クリニック", "東京都"));
                    m_Data.Add(new DispCode("130469", "野中医院", "東京都"));
                    m_Data.Add(new DispCode("130479", "つばさクリニック", "東京都"));
                    m_Data.Add(new DispCode("130489", "国分寺南口クリニック", "東京都"));
                    m_Data.Add(new DispCode("130509", "渋谷池尻腎クリニック", "東京都"));
                    m_Data.Add(new DispCode("130519", "秋葉原腎クリニック", "東京都"));
                    m_Data.Add(new DispCode("130529", "秋葉原いずみクリニック", "東京都"));
                    m_Data.Add(new DispCode("130536", "ＮＴＴ東日本関東病院", "東京都"));
                    m_Data.Add(new DispCode("130569", "碑文谷腎透析クリニック", "東京都"));
                    m_Data.Add(new DispCode("130586", "東京共済病院", "東京都"));
                    m_Data.Add(new DispCode("130593", "東京都立多摩北部医療センター", "東京都"));
                    m_Data.Add(new DispCode("130609", "中目黒クリニック", "東京都"));
                    m_Data.Add(new DispCode("130611", "東邦大学医療センター大森病院", "東京都"));
                    m_Data.Add(new DispCode("130621", "東京医科大学八王子医療センター", "東京都"));
                    m_Data.Add(new DispCode("130636", "東京労災病院", "東京都"));
                    m_Data.Add(new DispCode("130646", "大森赤十字病院", "東京都"));
                    m_Data.Add(new DispCode("130657", "牧田総合病院", "東京都"));
                    m_Data.Add(new DispCode("130678", "大田病院", "東京都"));
                    m_Data.Add(new DispCode("130689", "千葉医院", "東京都"));
                    m_Data.Add(new DispCode("130699", "長原三和クリニック", "東京都"));
                    m_Data.Add(new DispCode("130708", "京浜病院", "東京都"));
                    m_Data.Add(new DispCode("130718", "東京蒲田病院", "東京都"));
                    m_Data.Add(new DispCode("130728", "東急病院", "東京都"));
                    m_Data.Add(new DispCode("130736", "自衛隊中央病院", "東京都"));
                    m_Data.Add(new DispCode("130758", "三軒茶屋病院", "東京都"));
                    m_Data.Add(new DispCode("130786", "日本赤十字社医療センター", "東京都"));
                    m_Data.Add(new DispCode("130809", "なみきばしクリニック", "東京都"));
                    m_Data.Add(new DispCode("130828", "代々木病院", "東京都"));
                    m_Data.Add(new DispCode("130838", "東立病院", "東京都"));
                    m_Data.Add(new DispCode("130875", "新渡戸記念中野総合病院", "東京都"));
                    m_Data.Add(new DispCode("130889", "河北透析クリニック", "東京都"));
                    m_Data.Add(new DispCode("130899", "新中野透析クリニック", "東京都"));
                    m_Data.Add(new DispCode("130918", "豊島中央病院", "東京都"));
                    m_Data.Add(new DispCode("130948", "敬愛病院", "東京都"));
                    m_Data.Add(new DispCode("131008", "南千住病院", "東京都"));
                    m_Data.Add(new DispCode("131019", "東京ネフロクリニック　西日暮里", "東京都"));
                    m_Data.Add(new DispCode("131021", "帝京大学医学部附属病院", "東京都"));
                    m_Data.Add(new DispCode("131031", "日本大学医学部附属板橋病院", "東京都"));
                    m_Data.Add(new DispCode("131058", "東海病院", "東京都"));
                    m_Data.Add(new DispCode("131078", "西新井病院", "東京都"));
                    m_Data.Add(new DispCode("131088", "敬仁病院", "東京都"));
                    m_Data.Add(new DispCode("131091", "東京慈恵会医科大学葛飾医療センター", "東京都"));
                    m_Data.Add(new DispCode("131108", "嬉泉病院", "東京都"));
                    m_Data.Add(new DispCode("131118", "京葉病院", "東京都"));
                    m_Data.Add(new DispCode("131129", "東葛クリニック小岩", "東京都"));
                    m_Data.Add(new DispCode("131138", "南多摩病院", "東京都"));
                    m_Data.Add(new DispCode("131146", "立川病院", "東京都"));
                    m_Data.Add(new DispCode("131176", "武蔵野赤十字病院", "東京都"));
                    m_Data.Add(new DispCode("131191", "杏林大学医学部付属病院", "東京都"));
                    m_Data.Add(new DispCode("131218", "調布病院", "東京都"));
                    m_Data.Add(new DispCode("131228", "北多摩病院", "東京都"));
                    m_Data.Add(new DispCode("131238", "町田慶泉病院", "東京都"));
                    m_Data.Add(new DispCode("131248", "あけぼの病院", "東京都"));
                    m_Data.Add(new DispCode("131258", "竹口病院", "東京都"));
                    m_Data.Add(new DispCode("131261", "東京慈恵会医科大学附属第三病院", "東京都"));
                    m_Data.Add(new DispCode("131273", "東京都立小児総合医療センター", "東京都"));
                    m_Data.Add(new DispCode("131288", "きよせ旭が丘記念病院", "東京都"));
                    m_Data.Add(new DispCode("131299", "東村山診療所", "東京都"));
                    m_Data.Add(new DispCode("131319", "府中腎クリニック", "東京都"));
                    m_Data.Add(new DispCode("131338", "明理会中央総合病院", "東京都"));
                    m_Data.Add(new DispCode("131368", "大森山王病院", "東京都"));
                    m_Data.Add(new DispCode("131413", "公立福生病院", "東京都"));
                    m_Data.Add(new DispCode("131459", "高松医院", "東京都"));
                    m_Data.Add(new DispCode("131479", "白鳥診療所", "東京都"));
                    m_Data.Add(new DispCode("131499", "新線池袋クリニック", "東京都"));
                    m_Data.Add(new DispCode("131522", "東日本矯正医療センター", "東京都"));
                    m_Data.Add(new DispCode("131549", "日伸駅前クリニック", "東京都"));
                    m_Data.Add(new DispCode("131559", "昭島腎クリニック", "東京都"));
                    m_Data.Add(new DispCode("131569", "かめいど腎臓内科クリニック", "東京都"));
                    m_Data.Add(new DispCode("131579", "田町腎クリニック", "東京都"));
                    m_Data.Add(new DispCode("131599", "大井町駅前クリニック", "東京都"));
                    m_Data.Add(new DispCode("131602", "国立療養所多磨全生園", "東京都"));
                    m_Data.Add(new DispCode("131638", "勝和会病院", "東京都"));
                    m_Data.Add(new DispCode("131663", "都立駒込病院", "東京都"));
                    m_Data.Add(new DispCode("131679", "鶴田板橋クリニック", "東京都"));
                    m_Data.Add(new DispCode("131689", "平和会南大井クリニック", "東京都"));
                    m_Data.Add(new DispCode("131699", "聖橋クリニック", "東京都"));
                    m_Data.Add(new DispCode("131700", "東京科学大学病院", "東京都"));
                    m_Data.Add(new DispCode("131718", "北里大学 北里研究所病院", "東京都"));
                    m_Data.Add(new DispCode("131729", "柴垣医院　自由が丘", "東京都"));
                    m_Data.Add(new DispCode("131749", "渋谷ステーションクリニック", "東京都"));
                    m_Data.Add(new DispCode("131758", "調布東山病院　透析センター入院透析室", "東京都"));
                    m_Data.Add(new DispCode("131769", "東都三軒茶屋クリニック", "東京都"));
                    m_Data.Add(new DispCode("131781", "東邦大学医療センター大橋病院", "東京都"));
                    m_Data.Add(new DispCode("131809", "下落合クリニック", "東京都"));
                    m_Data.Add(new DispCode("131819", "新小岩クリニック", "東京都"));
                    m_Data.Add(new DispCode("131839", "望星赤羽クリニック", "東京都"));
                    m_Data.Add(new DispCode("131859", "新宿石川クリニック", "東京都"));
                    m_Data.Add(new DispCode("131868", "森山脳神経センター病院", "東京都"));
                    m_Data.Add(new DispCode("131893", "公立昭和病院", "東京都"));
                    m_Data.Add(new DispCode("131908", "小豆沢病院", "東京都"));
                    m_Data.Add(new DispCode("131925", "JCHO東京高輪病院", "東京都"));
                    m_Data.Add(new DispCode("131939", "Ｗａｌｔｚクリニック", "東京都"));
                    m_Data.Add(new DispCode("131948", "吉川内科医院", "東京都"));
                    m_Data.Add(new DispCode("131988", "同愛記念病院", "東京都"));
                    m_Data.Add(new DispCode("132009", "小笠原クリニック", "東京都"));
                    m_Data.Add(new DispCode("132019", "西クリニック", "東京都"));
                    m_Data.Add(new DispCode("132049", "品川腎クリニック", "東京都"));
                    m_Data.Add(new DispCode("132079", "村上医院", "東京都"));
                    m_Data.Add(new DispCode("132098", "東京健生病院", "東京都"));
                    m_Data.Add(new DispCode("132109", "田無南口クリニック", "東京都"));
                    m_Data.Add(new DispCode("132118", "イムス記念病院", "東京都"));
                    m_Data.Add(new DispCode("132129", "四ツ谷腎クリニック", "東京都"));
                    m_Data.Add(new DispCode("132146", "虎の門病院", "東京都"));
                    m_Data.Add(new DispCode("132159", "美好腎クリニック", "東京都"));
                    m_Data.Add(new DispCode("132178", "東和病院", "東京都"));
                    m_Data.Add(new DispCode("132182", "東京医療センター", "東京都"));
                    m_Data.Add(new DispCode("132199", "武蔵境駅前クリニック", "東京都"));
                    m_Data.Add(new DispCode("132219", "境南クリニック", "東京都"));
                    m_Data.Add(new DispCode("132238", "玉川病院", "東京都"));
                    m_Data.Add(new DispCode("132249", "西條クリニック下馬", "東京都"));
                    m_Data.Add(new DispCode("132259", "博慈会腎・透析クリニック", "東京都"));
                    m_Data.Add(new DispCode("132268", "吉祥寺あさひ病院", "東京都"));
                    m_Data.Add(new DispCode("132273", "東京都立墨東病院", "東京都"));
                    m_Data.Add(new DispCode("132289", "立花クリニック", "東京都"));
                    m_Data.Add(new DispCode("132293", "東京都立大塚病院", "東京都"));
                    m_Data.Add(new DispCode("132317", "池上総合病院", "東京都"));
                    m_Data.Add(new DispCode("132328", "大田池上病院", "東京都"));
                    m_Data.Add(new DispCode("132338", "寺田病院", "東京都"));
                    m_Data.Add(new DispCode("132359", "国立駅前腎クリニック", "東京都"));
                    m_Data.Add(new DispCode("132369", "飯田橋村井医院", "東京都"));
                    m_Data.Add(new DispCode("132379", "桜ヶ丘東山クリニック", "東京都"));
                    m_Data.Add(new DispCode("132389", "宗像クリニック", "東京都"));
                    m_Data.Add(new DispCode("132399", "桜新町クリニック", "東京都"));
                    m_Data.Add(new DispCode("132408", "東大和病院", "東京都"));
                    m_Data.Add(new DispCode("132411", "昭和医科大学医学部", "東京都"));
                    m_Data.Add(new DispCode("132428", "長久保病院", "東京都"));
                    m_Data.Add(new DispCode("132432", "国立成育医療研究センター", "東京都"));
                    m_Data.Add(new DispCode("132449", "八王子東町クリニック", "東京都"));
                    m_Data.Add(new DispCode("132483", "稲城市立病院", "東京都"));
                    m_Data.Add(new DispCode("132499", "瑞江腎クリニック", "東京都"));
                    m_Data.Add(new DispCode("132509", "菊川橋クリニック", "東京都"));
                    m_Data.Add(new DispCode("132523", "日野市立病院", "東京都"));
                    m_Data.Add(new DispCode("132543", "公立阿伎留医療センター", "東京都"));
                    m_Data.Add(new DispCode("132589", "新江東橋クリニック", "東京都"));
                    m_Data.Add(new DispCode("132599", "小川クリニック", "東京都"));
                    m_Data.Add(new DispCode("132609", "御徒町腎クリニック", "東京都"));
                    m_Data.Add(new DispCode("132618", "慈秀病院", "東京都"));
                    m_Data.Add(new DispCode("132629", "阿佐谷すずき診療所", "東京都"));
                    m_Data.Add(new DispCode("132639", "自由が丘南口クリニック", "東京都"));
                    m_Data.Add(new DispCode("132648", "武蔵野陽和会病院", "東京都"));
                    m_Data.Add(new DispCode("132653", "東京都立多摩総合医療センター", "東京都"));
                    m_Data.Add(new DispCode("132679", "西八王子松村クリニック", "東京都"));
                    m_Data.Add(new DispCode("132689", "医新クリニック", "東京都"));
                    m_Data.Add(new DispCode("132699", "青梅腎クリニック", "東京都"));
                    m_Data.Add(new DispCode("132709", "新葛飾ロイヤルクリニック", "東京都"));
                    m_Data.Add(new DispCode("132719", "駒沢腎クリニック", "東京都"));
                    m_Data.Add(new DispCode("132729", "こやまクリニック", "東京都"));
                    m_Data.Add(new DispCode("132749", "飯田橋西口クリニック", "東京都"));
                    m_Data.Add(new DispCode("132759", "南大沢パオレ腎クリニック", "東京都"));
                    m_Data.Add(new DispCode("132769", "羽村相互診療所", "東京都"));
                    m_Data.Add(new DispCode("132779", "三鷹腎クリニック", "東京都"));
                    m_Data.Add(new DispCode("132799", "立花クリニック", "東京都"));
                    m_Data.Add(new DispCode("132809", "桃井診療所", "東京都"));
                    m_Data.Add(new DispCode("132829", "立川腎と内科・三和クリニック", "東京都"));
                    m_Data.Add(new DispCode("132848", "保谷厚生病院", "東京都"));
                    m_Data.Add(new DispCode("132859", "井の頭クリニック", "東京都"));
                    m_Data.Add(new DispCode("132879", "須田内科クリニック", "東京都"));
                    m_Data.Add(new DispCode("132889", "南池袋診療所", "東京都"));
                    m_Data.Add(new DispCode("132897", "高島平中央総合病院", "東京都"));
                    m_Data.Add(new DispCode("132918", "小金井太陽病院", "東京都"));
                    m_Data.Add(new DispCode("132938", "立川相互病院", "東京都"));
                    m_Data.Add(new DispCode("132949", "敬友クリニック高輪", "東京都"));
                    m_Data.Add(new DispCode("132958", "清湘会記念病院", "東京都"));
                    m_Data.Add(new DispCode("132976", "ＪＲ東京総合病院", "東京都"));
                    m_Data.Add(new DispCode("132999", "佐藤内科循環器科クリニック", "東京都"));
                    m_Data.Add(new DispCode("133008", "江東病院", "東京都"));
                    m_Data.Add(new DispCode("133019", "新宿西口腎クリニック", "東京都"));
                    m_Data.Add(new DispCode("133029", "柳原腎クリニック", "東京都"));
                    m_Data.Add(new DispCode("133038", "調布東山病院　透析センター外来透析室", "東京都"));
                    m_Data.Add(new DispCode("133053", "東京都立大久保病院", "東京都"));
                    m_Data.Add(new DispCode("133069", "十条腎クリニック", "東京都"));
                    m_Data.Add(new DispCode("133088", "東京曳舟病院", "東京都"));
                    m_Data.Add(new DispCode("133098", "滝山病院", "東京都"));
                    m_Data.Add(new DispCode("133119", "日野クリニック", "東京都"));
                    m_Data.Add(new DispCode("133129", "西大島腎クリニック", "東京都"));
                    m_Data.Add(new DispCode("133138", "明和病院", "東京都"));
                    m_Data.Add(new DispCode("133149", "小平北口クリニック", "東京都"));
                    m_Data.Add(new DispCode("133159", "高尾駅前クリニック", "東京都"));
                    m_Data.Add(new DispCode("133169", "成増クリニック", "東京都"));
                    m_Data.Add(new DispCode("133189", "大久保渡辺クリニック", "東京都"));
                    m_Data.Add(new DispCode("133218", "白報会王子病院", "東京都"));
                    m_Data.Add(new DispCode("133229", "目黒じんクリニック", "東京都"));
                    m_Data.Add(new DispCode("133239", "立川北口駅前クリニック", "東京都"));
                    m_Data.Add(new DispCode("133249", "東京ネフロクリニック", "東京都"));
                    m_Data.Add(new DispCode("133259", "旗の台小池クリニック", "東京都"));
                    m_Data.Add(new DispCode("133262", "災害医療センター", "東京都"));
                    m_Data.Add(new DispCode("133277", "河北総合病院", "東京都"));
                    m_Data.Add(new DispCode("133290", "東京大学医学部附属病院", "東京都"));
                    m_Data.Add(new DispCode("133319", "門仲腎クリニック", "東京都"));
                    m_Data.Add(new DispCode("133329", "京王八王子山川クリニック", "東京都"));
                    m_Data.Add(new DispCode("133333", "大島医療センター", "東京都"));
                    m_Data.Add(new DispCode("133359", "すずき内科クリニック", "東京都"));
                    m_Data.Add(new DispCode("133369", "深川橋クリニック", "東京都"));
                    m_Data.Add(new DispCode("133374", "JCHO東京蒲田医療センター", "東京都"));
                    m_Data.Add(new DispCode("133388", "赤羽中央総合病院", "東京都"));
                    m_Data.Add(new DispCode("133396", "関東中央病院", "東京都"));
                    m_Data.Add(new DispCode("133403", "町立八丈病院", "東京都"));
                    m_Data.Add(new DispCode("133419", "総愛診療所", "東京都"));
                    m_Data.Add(new DispCode("133429", "小作クリニック", "東京都"));
                    m_Data.Add(new DispCode("133431", "東京女子医科大学附属足立医療センター", "東京都"));
                    m_Data.Add(new DispCode("133449", "中野南口クリニック", "東京都"));
                    m_Data.Add(new DispCode("133459", "瑞江ゆうあいクリニック", "東京都"));
                    m_Data.Add(new DispCode("133469", "町屋駅前クリニック", "東京都"));
                    m_Data.Add(new DispCode("133509", "腎クリニック高野台", "東京都"));
                    m_Data.Add(new DispCode("133519", "大井小川クリニック", "東京都"));
                    m_Data.Add(new DispCode("133539", "蒲田南口腎クリニック", "東京都"));
                    m_Data.Add(new DispCode("133559", "メディカルクリニック中目黒", "東京都"));
                    m_Data.Add(new DispCode("133569", "鶴田クリニック", "東京都"));
                    m_Data.Add(new DispCode("133588", "西八王子病院", "東京都"));
                    m_Data.Add(new DispCode("133598", "はせがわ病院", "東京都"));
                    m_Data.Add(new DispCode("133609", "自由が丘いずみクリニック", "東京都"));
                    m_Data.Add(new DispCode("133619", "新葛西クリニック", "東京都"));
                    m_Data.Add(new DispCode("133643", "東京都立豊島病院", "東京都"));
                    m_Data.Add(new DispCode("133659", "新橋青木クリニック", "東京都"));
                    m_Data.Add(new DispCode("133668", "板橋中央総合病院", "東京都"));
                    m_Data.Add(new DispCode("133679", "吉祥寺駅前クリニック", "東京都"));
                    m_Data.Add(new DispCode("133709", "高山クリニック", "東京都"));
                    m_Data.Add(new DispCode("133713", "東京都健康長寿医療センター", "東京都"));
                    m_Data.Add(new DispCode("133727", "西東京中央総合病院", "東京都"));
                    m_Data.Add(new DispCode("133749", "成城じんクリニック", "東京都"));
                    m_Data.Add(new DispCode("133758", "関川病院", "東京都"));
                    m_Data.Add(new DispCode("133768", "東京北部病院", "東京都"));
                    m_Data.Add(new DispCode("133779", "二子玉川駅前クリニック", "東京都"));
                    m_Data.Add(new DispCode("133789", "あやせ駅前腎クリニック", "東京都"));
                    m_Data.Add(new DispCode("133793", "町田市民病院", "東京都"));
                    m_Data.Add(new DispCode("133809", "青戸腎クリニック", "東京都"));
                    m_Data.Add(new DispCode("133819", "望星西新宿診療所", "東京都"));
                    m_Data.Add(new DispCode("133829", "幸町腎クリニック", "東京都"));
                    m_Data.Add(new DispCode("133839", "北千住東口腎クリニック", "東京都"));
                    m_Data.Add(new DispCode("133848", "緑風荘病院", "東京都"));
                    m_Data.Add(new DispCode("133859", "東京綾瀬腎クリニック", "東京都"));
                    m_Data.Add(new DispCode("133869", "調布つつじヶ丘じんクリニック", "東京都"));
                    m_Data.Add(new DispCode("133879", "高円寺すずきクリニック", "東京都"));
                    m_Data.Add(new DispCode("133889", "喜多見東山クリニック", "東京都"));
                    m_Data.Add(new DispCode("133899", "新小岩クリニック船堀", "東京都"));
                    m_Data.Add(new DispCode("133919", "すながわ相互診療所", "東京都"));
                    m_Data.Add(new DispCode("133929", "山王メディカルセンター", "東京都"));
                    m_Data.Add(new DispCode("133939", "雪谷三和クリニック", "東京都"));
                    m_Data.Add(new DispCode("133959", "西條クリニック鷹番", "東京都"));
                    m_Data.Add(new DispCode("133969", "すがも腎クリニック", "東京都"));
                    m_Data.Add(new DispCode("133999", "赤羽中央総合病院附属クリニック", "東京都"));
                    m_Data.Add(new DispCode("134018", "昭和の杜病院", "東京都"));
                    m_Data.Add(new DispCode("134028", "井口病院", "東京都"));
                    m_Data.Add(new DispCode("134038", "小林病院", "東京都"));
                    m_Data.Add(new DispCode("134048", "一橋病院", "東京都"));
                    m_Data.Add(new DispCode("134079", "イムス西台透析クリニック", "東京都"));
                    m_Data.Add(new DispCode("134089", "板橋石川クリニック", "東京都"));
                    m_Data.Add(new DispCode("134099", "国領石川クリニック", "東京都"));
                    m_Data.Add(new DispCode("134111", "順天堂東京江東高齢者医療センター", "東京都"));
                    m_Data.Add(new DispCode("134129", "東大和南街クリニック", "東京都"));
                    m_Data.Add(new DispCode("134149", "板橋中央総合病院附属アイ・タワークリニック", "東京都"));
                    m_Data.Add(new DispCode("134159", "熊の前腎クリニック", "東京都"));
                    m_Data.Add(new DispCode("134169", "多摩永山腎・内科クリニック", "東京都"));
                    m_Data.Add(new DispCode("134179", "めじろ台西澤クリニック", "東京都"));
                    m_Data.Add(new DispCode("134198", "あだち共生病院", "東京都"));
                    m_Data.Add(new DispCode("134209", "八王子腎クリニック", "東京都"));
                    m_Data.Add(new DispCode("134229", "下北沢駅前クリニック", "東京都"));
                    m_Data.Add(new DispCode("134239", "吉祥寺クリニック", "東京都"));
                    m_Data.Add(new DispCode("134249", "豊田クリニック", "東京都"));
                    m_Data.Add(new DispCode("134259", "福生駅前クリニック", "東京都"));
                    m_Data.Add(new DispCode("134279", "練馬桜台クリニック", "東京都"));
                    m_Data.Add(new DispCode("134289", "寿町腎・内科クリニック", "東京都"));
                    m_Data.Add(new DispCode("134298", "苑田第二病院", "東京都"));
                    m_Data.Add(new DispCode("134301", "東海大学医学部付属八王子病院", "東京都"));
                    m_Data.Add(new DispCode("134328", "八王子山王病院", "東京都"));
                    m_Data.Add(new DispCode("134359", "南砂腎クリニック", "東京都"));
                    m_Data.Add(new DispCode("134369", "多摩ゆうあいクリニック", "東京都"));
                    m_Data.Add(new DispCode("134379", "優人クリニック", "東京都"));
                    m_Data.Add(new DispCode("134388", "苑田第一病院", "東京都"));
                    m_Data.Add(new DispCode("134399", "みたかの森クリニック", "東京都"));
                    m_Data.Add(new DispCode("134419", "豊洲腎透析クリニック", "東京都"));
                    m_Data.Add(new DispCode("134429", "経堂駅前クリニック", "東京都"));
                    m_Data.Add(new DispCode("134438", "金町中央病院", "東京都"));
                    m_Data.Add(new DispCode("134464", "東京北医療センター", "東京都"));
                    m_Data.Add(new DispCode("134488", "国立さくら病院", "東京都"));
                    m_Data.Add(new DispCode("134508", "森山記念病院", "東京都"));
                    m_Data.Add(new DispCode("134519", "井口腎泌尿器科・内科 親水", "東京都"));
                    m_Data.Add(new DispCode("134529", "みなみ野セントラルクリニック", "東京都"));
                    m_Data.Add(new DispCode("134531", "国際医療福祉大学三田病院", "東京都"));
                    m_Data.Add(new DispCode("134549", "新橋内科クリニック", "東京都"));
                    m_Data.Add(new DispCode("134557", "永寿総合病院", "東京都"));
                    m_Data.Add(new DispCode("134568", "中野共立病院", "東京都"));
                    m_Data.Add(new DispCode("134579", "北八王子クリニック", "東京都"));
                    m_Data.Add(new DispCode("134589", "くろだ明大前クリニック", "東京都"));
                    m_Data.Add(new DispCode("134598", "武蔵村山病院", "東京都"));
                    m_Data.Add(new DispCode("134609", "成守会クリニック", "東京都"));
                    m_Data.Add(new DispCode("134619", "東久留米クリニック", "東京都"));
                    m_Data.Add(new DispCode("134629", "ノリ　メディカルクリニック笹塚南", "東京都"));
                    m_Data.Add(new DispCode("134639", "青梅かすみ台クリニック", "東京都"));
                    m_Data.Add(new DispCode("134648", "東京西徳洲会病院", "東京都"));
                    m_Data.Add(new DispCode("134679", "鶴川駅前クリニック", "東京都"));
                    m_Data.Add(new DispCode("134699", "おおいわ腎クリニック", "東京都"));
                    m_Data.Add(new DispCode("134709", "井口腎泌尿器科 亀有", "東京都"));
                    m_Data.Add(new DispCode("134728", "足立十全病院", "東京都"));
                    m_Data.Add(new DispCode("134739", "さくら並木クリニック", "東京都"));
                    m_Data.Add(new DispCode("134749", "あだち入谷舎人クリニック", "東京都"));
                    m_Data.Add(new DispCode("134759", "金町腎クリニック", "東京都"));
                    m_Data.Add(new DispCode("134761", "順天堂大学医学部附属練馬病院", "東京都"));
                    m_Data.Add(new DispCode("134789", "池上クリニック", "東京都"));
                    m_Data.Add(new DispCode("134798", "世田谷井上病院", "東京都"));
                    m_Data.Add(new DispCode("134807", "博慈会記念総合病院", "東京都"));
                    m_Data.Add(new DispCode("134829", "江戸川橋鈴木クリニック", "東京都"));
                    m_Data.Add(new DispCode("134839", "練馬高野台クリニック", "東京都"));
                    m_Data.Add(new DispCode("134849", "東葛西クリニック", "東京都"));
                    m_Data.Add(new DispCode("134859", "新島村国民健康保険本村診療所", "東京都"));
                    m_Data.Add(new DispCode("134869", "大森邦愛クリニック", "東京都"));
                    m_Data.Add(new DispCode("134879", "狛江腎クリニック", "東京都"));
                    m_Data.Add(new DispCode("134888", "江戸川病院", "東京都"));
                    m_Data.Add(new DispCode("134898", "ふれあい町田ホスピタル", "東京都"));
                    m_Data.Add(new DispCode("134908", "東京品川病院", "東京都"));
                    m_Data.Add(new DispCode("134919", "稲城腎・内科クリニック", "東京都"));
                    m_Data.Add(new DispCode("134929", "西荻窪透析内科クリニック", "東京都"));
                    m_Data.Add(new DispCode("134939", "飯田橋鈴木内科", "東京都"));
                    m_Data.Add(new DispCode("134949", "くめがわ駅前腎・内科クリニック", "東京都"));
                    m_Data.Add(new DispCode("134958", "相武病院", "東京都"));
                    m_Data.Add(new DispCode("134969", "腎内科クリニック世田谷", "東京都"));
                    m_Data.Add(new DispCode("134979", "千歳烏山腎クリニック", "東京都"));
                    m_Data.Add(new DispCode("134989", "立石腎クリニック", "東京都"));
                    m_Data.Add(new DispCode("134999", "あかまつ透析クリニック", "東京都"));
                    m_Data.Add(new DispCode("135001", "日本医科大学多摩永山病院", "東京都"));
                    m_Data.Add(new DispCode("135018", "東京洪誠病院", "東京都"));
                    m_Data.Add(new DispCode("135029", "赤塚幸クリニック", "東京都"));
                    m_Data.Add(new DispCode("135037", "イムス東京葛飾総合病院", "東京都"));
                    m_Data.Add(new DispCode("135049", "優人大泉学園クリニック", "東京都"));
                    m_Data.Add(new DispCode("135068", "等潤病院", "東京都"));
                    m_Data.Add(new DispCode("135109", "ワイズクリニック", "東京都"));
                    m_Data.Add(new DispCode("135119", "敬愛病院附属クリニック", "東京都"));
                    m_Data.Add(new DispCode("135129", "田端駅前クリニック", "東京都"));
                    m_Data.Add(new DispCode("135139", "東武練馬クリニック", "東京都"));
                    m_Data.Add(new DispCode("135149", "小岩駅北口クリニック", "東京都"));
                    m_Data.Add(new DispCode("135163", "東京都立広尾病院", "東京都"));
                    m_Data.Add(new DispCode("135179", "品川ガーデンクリニック", "東京都"));
                    m_Data.Add(new DispCode("135189", "羽田腎クリニック", "東京都"));
                    m_Data.Add(new DispCode("135199", "中野新井腎クリニック", "東京都"));
                    m_Data.Add(new DispCode("135209", "柴垣医院　戸越", "東京都"));
                    m_Data.Add(new DispCode("135219", "笹塚・代田橋透析クリニック", "東京都"));
                    m_Data.Add(new DispCode("135239", "新小岩そらまめクリニック", "東京都"));
                    m_Data.Add(new DispCode("135249", "南青山内科クリニック", "東京都"));
                    m_Data.Add(new DispCode("135279", "メディカルプラザ篠崎駅西口", "東京都"));
                    m_Data.Add(new DispCode("135289", "成瀬腎クリニック", "東京都"));
                    m_Data.Add(new DispCode("135293", "練馬光が丘病院", "東京都"));
                    m_Data.Add(new DispCode("135309", "蒲田駅前クリニック", "東京都"));
                    m_Data.Add(new DispCode("135319", "大泉学園クリニック", "東京都"));
                    m_Data.Add(new DispCode("135329", "西新井大師西腎透析クリニック", "東京都"));
                    m_Data.Add(new DispCode("135338", "明理会東京大和病院", "東京都"));
                    m_Data.Add(new DispCode("135349", "羽田おおぞらクリニック", "東京都"));
                    m_Data.Add(new DispCode("135359", "東京ネクスト内科・透析クリニック", "東京都"));
                    m_Data.Add(new DispCode("135379", "ひがし青梅腎クリニック", "東京都"));
                    m_Data.Add(new DispCode("135389", "銀座医院　上野透析クリニック", "東京都"));
                    m_Data.Add(new DispCode("135399", "井口腎泌尿器科・内科　新小岩", "東京都"));
                    m_Data.Add(new DispCode("135409", "五反田ガーデンクリニック", "東京都"));
                    m_Data.Add(new DispCode("135419", "柴垣医院　久が原", "東京都"));
                    m_Data.Add(new DispCode("135421", "昭和医科大学江東豊洲病院", "東京都"));
                    m_Data.Add(new DispCode("135439", "渋谷笹塚ＨＤクリニック", "東京都"));
                    m_Data.Add(new DispCode("135449", "武蔵野総合クリニック　練馬", "東京都"));
                    m_Data.Add(new DispCode("135459", "ひらくクリニック", "東京都"));
                    m_Data.Add(new DispCode("135479", "清瀬博済堂クリニック", "東京都"));
                    m_Data.Add(new DispCode("135489", "優人上石神井クリニック", "東京都"));
                    m_Data.Add(new DispCode("135499", "三宅村中央診療所", "東京都"));
                    m_Data.Add(new DispCode("135508", "南町田病院", "東京都"));
                    m_Data.Add(new DispCode("135519", "あだち五反野腎クリニック", "東京都"));
                    m_Data.Add(new DispCode("135529", "久我山腎クリニック", "東京都"));
                    m_Data.Add(new DispCode("135538", "慈誠会記念病院", "東京都"));
                    m_Data.Add(new DispCode("135549", "百草園腎クリニック", "東京都"));
                    m_Data.Add(new DispCode("135558", "武蔵野徳洲会病院", "東京都"));
                    m_Data.Add(new DispCode("135569", "嬉泉クリニック", "東京都"));
                    m_Data.Add(new DispCode("135579", "東京新橋透析クリニック", "東京都"));
                    m_Data.Add(new DispCode("135589", "平井ゆうあいクリニック", "東京都"));
                    m_Data.Add(new DispCode("135598", "苑風会病院", "東京都"));
                    m_Data.Add(new DispCode("135609", "東村山ネフロクリニック", "東京都"));
                    m_Data.Add(new DispCode("135618", "聖英病院", "東京都"));
                    m_Data.Add(new DispCode("135629", "グランハート透析クリニック", "東京都"));
                    m_Data.Add(new DispCode("135639", "立川相互錦町クリニック", "東京都"));
                    m_Data.Add(new DispCode("135649", "やまゆりクリニック", "東京都"));
                    m_Data.Add(new DispCode("135659", "石神井公園じんクリニック", "東京都"));
                    m_Data.Add(new DispCode("135669", "小岩ゆうあいクリニック", "東京都"));
                    m_Data.Add(new DispCode("135679", "平山城址腎クリニック", "東京都"));
                    m_Data.Add(new DispCode("135689", "立川腎クリニック", "東京都"));
                    m_Data.Add(new DispCode("135699", "多摩永山高田クリニック", "東京都"));
                    m_Data.Add(new DispCode("135709", "東京透析フロンティア池袋駅前クリニック", "東京都"));
                    m_Data.Add(new DispCode("135719", "高幡不動じんクリニック", "東京都"));
                    m_Data.Add(new DispCode("135739", "羽村透析クリニック", "東京都"));
                    m_Data.Add(new DispCode("135749", "駒込あおば内科", "東京都"));
                    m_Data.Add(new DispCode("135759", "聖蹟桜ヶ丘じんクリニック", "東京都"));
                    m_Data.Add(new DispCode("135769", "あだち江北メディカルクリニック", "東京都"));
                    m_Data.Add(new DispCode("135779", "久米川透析内科クリニック", "東京都"));
                    m_Data.Add(new DispCode("135788", "江戸川メディケア病院", "東京都"));
                    m_Data.Add(new DispCode("135798", "東京臨海病院", "東京都"));
                    m_Data.Add(new DispCode("135808", "西多摩病院", "東京都"));
                    m_Data.Add(new DispCode("135829", "わかやま透析クリニック中野南台", "東京都"));
                    m_Data.Add(new DispCode("135849", "葛西そらまめクリニック", "東京都"));
                    m_Data.Add(new DispCode("135859", "東京透析フロンティア大塚駅前クリニック", "東京都"));
                    m_Data.Add(new DispCode("135869", "糀谷じんクリニック", "東京都"));
                    m_Data.Add(new DispCode("135879", "キノメディッククリニック高田馬場", "東京都"));
                    m_Data.Add(new DispCode("135888", "下北沢病院", "東京都"));
                    m_Data.Add(new DispCode("135899", "西八王子腎クリニック", "東京都"));
                    m_Data.Add(new DispCode("135909", "ファミリア透析クリニック北綾瀬駅前", "東京都"));
                    m_Data.Add(new DispCode("135918", "清湘会東砂病院", "東京都"));
                    m_Data.Add(new DispCode("135929", "東京透析フロンティア西日暮里駅前クリニック", "東京都"));
                    m_Data.Add(new DispCode("135939", "大森牧田クリニック", "東京都"));
                    m_Data.Add(new DispCode("135949", "武蔵野総合クリニック", "東京都"));
                    m_Data.Add(new DispCode("135959", "篠崎透析クリニック", "東京都"));
                    m_Data.Add(new DispCode("135969", "花小金井きのしたクリニック", "東京都"));
                    m_Data.Add(new DispCode("135978", "東都三軒茶屋リハビリテーション病院", "東京都"));
                    m_Data.Add(new DispCode("135989", "駒込じんクリニック", "東京都"));
                    m_Data.Add(new DispCode("135999", "東陽町腎透析クリニック", "東京都"));
                    m_Data.Add(new DispCode("136009", "東和透析クリニック", "東京都"));
                    m_Data.Add(new DispCode("136018", "奥沢病院", "東京都"));
                    m_Data.Add(new DispCode("136029", "馬込駅前クリニック", "東京都"));
                    m_Data.Add(new DispCode("136038", "原整形外科病院", "東京都"));
                    m_Data.Add(new DispCode("136049", "東京ネクスト南砂内科・透析クリニック", "東京都"));
                    m_Data.Add(new DispCode("136068", "木村病院", "東京都"));
                    m_Data.Add(new DispCode("136079", "えどがわ在宅・透析クリニック", "東京都"));
                    m_Data.Add(new DispCode("136089", "東京透析フロンティア 王子駅前クリニック", "東京都"));
                    m_Data.Add(new DispCode("136099", "恵比寿ガーデンクリニック", "東京都"));
                    m_Data.Add(new DispCode("136109", "田島橋クリニック", "東京都"));
                    m_Data.Add(new DispCode("136118", "ＡＯＩ八王子病院", "東京都"));
                    m_Data.Add(new DispCode("136129", "優人光が丘クリニック", "東京都"));
                    m_Data.Add(new DispCode("136139", "上北台じんクリニック", "東京都"));
                    m_Data.Add(new DispCode("136149", "井口腎泌尿器科・内科 北綾瀬", "東京都"));
                    m_Data.Add(new DispCode("136151", "杏林大学医学部付属杉並病院", "東京都"));
                    m_Data.Add(new DispCode("136169", "湯島天神透析クリニック", "東京都"));
                    m_Data.Add(new DispCode("136178", "等潤メディカルプラザ病院 腎センター等潤", "東京都"));
                    m_Data.Add(new DispCode("136188", "希望の丘八王子病院", "東京都"));
                    m_Data.Add(new DispCode("136189", "上北台透析クリニック", "東京都"));
                    m_Data.Add(new DispCode("136199", "葛西透析クリニック", "東京都"));
                    m_Data.Add(new DispCode("136209", "佐々整形外科・透析クリニック", "東京都"));
                    m_Data.Add(new DispCode("136218", "令和あらかわ病院", "東京都"));
                    m_Data.Add(new DispCode("137029", "神津島村国保診療所", "東京都"));
                    m_Data.Add(new DispCode("137048", "日の出ヶ丘病院", "東京都"));
                    m_Data.Add(new DispCode("140010", "横浜市立大学附属病院", "神奈川県"));
                    m_Data.Add(new DispCode("140021", "昭和医科大学藤が丘病院", "神奈川県"));
                    m_Data.Add(new DispCode("140044", "JCHO横浜中央病院", "神奈川県"));
                    m_Data.Add(new DispCode("140069", "長津田健診・透析クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("140078", "康心会汐見台病院", "神奈川県"));
                    m_Data.Add(new DispCode("140108", "徳田病院", "神奈川県"));
                    m_Data.Add(new DispCode("140118", "平和病院", "神奈川県"));
                    m_Data.Add(new DispCode("140129", "よこはま関内じんクリニック", "神奈川県"));
                    m_Data.Add(new DispCode("140131", "日本医科大学武蔵小杉病院", "神奈川県"));
                    m_Data.Add(new DispCode("140141", "聖マリアンナ医科大学", "神奈川県"));
                    m_Data.Add(new DispCode("140158", "小田原循環器病院", "神奈川県"));
                    m_Data.Add(new DispCode("140175", "川崎協同病院", "神奈川県"));
                    m_Data.Add(new DispCode("140186", "関東労災病院", "神奈川県"));
                    m_Data.Add(new DispCode("140193", "川崎市立井田病院", "神奈川県"));
                    m_Data.Add(new DispCode("140206", "虎の門病院分院", "神奈川県"));
                    m_Data.Add(new DispCode("140217", "総合高津中央病院", "神奈川県"));
                    m_Data.Add(new DispCode("140238", "川崎幸病院", "神奈川県"));
                    m_Data.Add(new DispCode("140249", "丸子クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("140256", "横須賀共済病院", "神奈川県"));
                    m_Data.Add(new DispCode("140269", "横須賀クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("140273", "平塚市民病院", "神奈川県"));
                    m_Data.Add(new DispCode("140298", "相武台リハビリテーション病院", "神奈川県"));
                    m_Data.Add(new DispCode("140308", "藤沢御所見病院", "神奈川県"));
                    m_Data.Add(new DispCode("140313", "小田原市立病院", "神奈川県"));
                    m_Data.Add(new DispCode("140328", "小林病院", "神奈川県"));
                    m_Data.Add(new DispCode("140339", "小田原内科・循環器クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("140348", "西湘病院", "神奈川県"));
                    m_Data.Add(new DispCode("140359", "二俣川第一クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("140368", "森下記念病院", "神奈川県"));
                    m_Data.Add(new DispCode("140372", "神奈川病院", "神奈川県"));
                    m_Data.Add(new DispCode("140389", "望星大根クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("140393", "厚木市立病院", "神奈川県"));
                    m_Data.Add(new DispCode("140409", "厚木クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("140429", "及川医院", "神奈川県"));
                    m_Data.Add(new DispCode("140458", "相模台病院", "神奈川県"));
                    m_Data.Add(new DispCode("140469", "恒心会横浜中央クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("140471", "北里大学病院", "神奈川県"));
                    m_Data.Add(new DispCode("140489", "湘南クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("140498", "横浜第一病院", "神奈川県"));
                    m_Data.Add(new DispCode("140508", "さがみ林間病院", "神奈川県"));
                    m_Data.Add(new DispCode("140519", "鷺沼人工腎臓石川クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("140549", "望星藤沢クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("140558", "額田記念病院", "神奈川県"));
                    m_Data.Add(new DispCode("140569", "橋本クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("140576", "横浜栄共済病院", "神奈川県"));
                    m_Data.Add(new DispCode("140589", "つるとうクリニック", "神奈川県"));
                    m_Data.Add(new DispCode("140599", "東神クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("140608", "南大和病院", "神奈川県"));
                    m_Data.Add(new DispCode("140618", "日本鋼管病院", "神奈川県"));
                    m_Data.Add(new DispCode("140629", "川崎クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("140639", "望星関内クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("140649", "上大岡仁正クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("140659", "相模原クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("140669", "新丸子田中内科クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("140677", "湘南藤沢徳洲会病院", "神奈川県"));
                    m_Data.Add(new DispCode("140689", "戸塚新クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("140699", "登戸クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("140709", "湯河原循環器クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("140718", "大和徳洲会病院", "神奈川県"));
                    m_Data.Add(new DispCode("140725", "横浜保土ケ谷中央病院", "神奈川県"));
                    m_Data.Add(new DispCode("140739", "友和クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("140779", "よこはま港南診療所", "神奈川県"));
                    m_Data.Add(new DispCode("140787", "渕野辺総合病院", "神奈川県"));
                    m_Data.Add(new DispCode("140798", "広瀬病院", "神奈川県"));
                    m_Data.Add(new DispCode("140805", "相模原協同病院", "神奈川県"));
                    m_Data.Add(new DispCode("140816", "横浜市南部病院", "神奈川県"));
                    m_Data.Add(new DispCode("140829", "望星平塚クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("140839", "前田記念武蔵小杉クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("140849", "茅ヶ崎セントラルクリニック", "神奈川県"));
                    m_Data.Add(new DispCode("140859", "横浜東口腎クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("140863", "横須賀市立市民病院", "神奈川県"));
                    m_Data.Add(new DispCode("140889", "さがみ循環器クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("140898", "湘南大磯病院", "神奈川県"));
                    m_Data.Add(new DispCode("140909", "金沢クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("140928", "片倉病院", "神奈川県"));
                    m_Data.Add(new DispCode("140938", "ふれあい鎌倉ホスピタル", "神奈川県"));
                    m_Data.Add(new DispCode("140987", "横浜旭中央総合病院", "神奈川県"));
                    m_Data.Add(new DispCode("141008", "東名厚木病院", "神奈川県"));
                    m_Data.Add(new DispCode("141018", "たちばな台病院", "神奈川県"));
                    m_Data.Add(new DispCode("141021", "聖マリアンナ医科大学横浜市西部病院", "神奈川県"));
                    m_Data.Add(new DispCode("141036", "横浜南共済病院", "神奈川県"));
                    m_Data.Add(new DispCode("141049", "西部腎クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("141059", "えいじんクリニック", "神奈川県"));
                    m_Data.Add(new DispCode("141079", "あさおクリニック", "神奈川県"));
                    m_Data.Add(new DispCode("141088", "伊勢原日向病院", "神奈川県"));
                    m_Data.Add(new DispCode("141098", "相原病院", "神奈川県"));
                    m_Data.Add(new DispCode("141109", "逗子桜山クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("141118", "湘南中央病院", "神奈川県"));
                    m_Data.Add(new DispCode("141127", "湘南鎌倉総合病院", "神奈川県"));
                    m_Data.Add(new DispCode("141138", "牧野記念病院", "神奈川県"));
                    m_Data.Add(new DispCode("141159", "前田記念新横浜クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("141163", "藤沢市民病院", "神奈川県"));
                    m_Data.Add(new DispCode("141187", "西横浜国際総合病院", "神奈川県"));
                    m_Data.Add(new DispCode("141199", "今里クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("141203", "横浜市立市民病院", "神奈川県"));
                    m_Data.Add(new DispCode("141211", "帝京大学医学部附属溝口病院", "神奈川県"));
                    m_Data.Add(new DispCode("141229", "渡辺クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("141231", "東海大学医学部", "神奈川県"));
                    m_Data.Add(new DispCode("141249", "三浦シーサイドクリニック", "神奈川県"));
                    m_Data.Add(new DispCode("141259", "コジマ内科クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("141266", "横浜労災病院", "神奈川県"));
                    m_Data.Add(new DispCode("141280", "横浜市立大学附属市民総合医療センター", "神奈川県"));
                    m_Data.Add(new DispCode("141309", "本厚木メディカルクリニック", "神奈川県"));
                    m_Data.Add(new DispCode("141339", "藤沢メディカルクリニック", "神奈川県"));
                    m_Data.Add(new DispCode("141359", "海老名クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("141369", "川崎駅前クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("141373", "川崎市立川崎病院", "神奈川県"));
                    m_Data.Add(new DispCode("141399", "腎健クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("141409", "なかじまクリニック", "神奈川県"));
                    m_Data.Add(new DispCode("141419", "シオンクリニック", "神奈川県"));
                    m_Data.Add(new DispCode("141429", "藤沢湘南台クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("141449", "山田内科", "神奈川県"));
                    m_Data.Add(new DispCode("141469", "横浜つづき腎クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("141489", "本橋内科クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("141498", "中央林間病院", "神奈川県"));
                    m_Data.Add(new DispCode("141507", "大船中央病院", "神奈川県"));
                    m_Data.Add(new DispCode("141519", "越川記念よこはま腎クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("141529", "ひらつか生活習慣病・透析クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("141539", "元町メディカルクリニック", "神奈川県"));
                    m_Data.Add(new DispCode("141549", "横浜南クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("141569", "誠知クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("141573", "大和市立病院", "神奈川県"));
                    m_Data.Add(new DispCode("141587", "横浜総合病院", "神奈川県"));
                    m_Data.Add(new DispCode("141599", "中田駅前泉クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("141629", "住永クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("141639", "阪クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("141646", "平塚共済病院", "神奈川県"));
                    m_Data.Add(new DispCode("141659", "大和クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("141669", "ありあけ内科クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("141679", "さがみ松が枝クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("141689", "北久里浜たくちクリニック", "神奈川県"));
                    m_Data.Add(new DispCode("141729", "白鷗医院", "神奈川県"));
                    m_Data.Add(new DispCode("141739", "日吉斎藤クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("141748", "茅ヶ崎中央病院", "神奈川県"));
                    m_Data.Add(new DispCode("141758", "ふれあい横浜ホスピタル", "神奈川県"));
                    m_Data.Add(new DispCode("141778", "くらた病院", "神奈川県"));
                    m_Data.Add(new DispCode("141789", "さいわい鹿島田クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("141795", "伊勢原協同病院", "神奈川県"));
                    m_Data.Add(new DispCode("141818", "湘南東部総合病院", "神奈川県"));
                    m_Data.Add(new DispCode("141829", "保土ヶ谷第一クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("141838", "オアシス湘南病院", "神奈川県"));
                    m_Data.Add(new DispCode("141849", "溝の口第一クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("141859", "東戸塚第一クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("141869", "相武台ニーレンクリニック", "神奈川県"));
                    m_Data.Add(new DispCode("141879", "日吉せざいクリニック", "神奈川県"));
                    m_Data.Add(new DispCode("141899", "あざみ野駅前クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("141909", "成和クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("141919", "やまとホスぴたじんクリニック", "神奈川県"));
                    m_Data.Add(new DispCode("141929", "緑園都市クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("141931", "昭和医科大学横浜市北部病院", "神奈川県"));
                    m_Data.Add(new DispCode("141949", "追浜仁正クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("141958", "ふれあい鶴見ホスピタル", "神奈川県"));
                    m_Data.Add(new DispCode("141979", "湘英クリニック平塚医院", "神奈川県"));
                    m_Data.Add(new DispCode("141986", "済生会神奈川県病院", "神奈川県"));
                    m_Data.Add(new DispCode("141999", "橋本みなみ内科本院", "神奈川県"));
                    m_Data.Add(new DispCode("142006", "相模原赤十字病院", "神奈川県"));
                    m_Data.Add(new DispCode("142016", "秦野赤十字病院", "神奈川県"));
                    m_Data.Add(new DispCode("142029", "秦野南口クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("142039", "新横浜第一クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("142049", "霧が丘クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("142059", "美しが丘クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("142068", "東戸塚記念病院", "神奈川県"));
                    m_Data.Add(new DispCode("142079", "洋光台セントラルクリニック", "神奈川県"));
                    m_Data.Add(new DispCode("142089", "湘南星和クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("142098", "聖隷横浜病院", "神奈川県"));
                    m_Data.Add(new DispCode("142109", "葉山ハートセンター", "神奈川県"));
                    m_Data.Add(new DispCode("142129", "新百合ヶ丘ガーデンクリニック", "神奈川県"));
                    m_Data.Add(new DispCode("142139", "文庫じんクリニック", "神奈川県"));
                    m_Data.Add(new DispCode("142149", "高座渋谷じんクリニック", "神奈川県"));
                    m_Data.Add(new DispCode("142153", "茅ヶ崎市立病院", "神奈川県"));
                    m_Data.Add(new DispCode("142169", "ティー.エイチ.ピー.メディカルクリニック", "神奈川県"));
                    m_Data.Add(new DispCode("142177", "国際親善総合病院", "神奈川県"));
                    m_Data.Add(new DispCode("142189", "鈴木内科医院", "神奈川県"));
                    m_Data.Add(new DispCode("142198", "小澤病院", "神奈川県"));
                    m_Data.Add(new DispCode("142206", "横浜市立みなと赤十字病院", "神奈川県"));
                    m_Data.Add(new DispCode("142219", "二俣川南口腎クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("142229", "中山駅前クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("142239", "中央林間じんクリニック", "神奈川県"));
                    m_Data.Add(new DispCode("142258", "湘南厚木病院", "神奈川県"));
                    m_Data.Add(new DispCode("142269", "ふれあいクリニック泉", "神奈川県"));
                    m_Data.Add(new DispCode("142279", "花クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("142289", "吉野町第一クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("142309", "つむらや内科", "神奈川県"));
                    m_Data.Add(new DispCode("142316", "済生会横浜市東部病院", "神奈川県"));
                    m_Data.Add(new DispCode("142323", "川崎市立多摩病院", "神奈川県"));
                    m_Data.Add(new DispCode("142339", "大和つきみの腎クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("142359", "新横浜クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("142369", "宮前平健栄クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("142378", "ふれあい東戸塚ホスピタル", "神奈川県"));
                    m_Data.Add(new DispCode("142389", "三保の森クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("142399", "ハートフル瀬谷クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("142408", "ふれあい平塚ホスピタル", "神奈川県"));
                    m_Data.Add(new DispCode("142419", "戸塚共立透析クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("142429", "上永谷クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("142438", "磯子中央病院", "神奈川県"));
                    m_Data.Add(new DispCode("142449", "つるまエキチカじんクリニック", "神奈川県"));
                    m_Data.Add(new DispCode("142457", "海老名総合病院", "神奈川県"));
                    m_Data.Add(new DispCode("142469", "かもめ・みなとみらいクリニック", "神奈川県"));
                    m_Data.Add(new DispCode("142478", "高台病院", "神奈川県"));
                    m_Data.Add(new DispCode("142507", "麻生総合病院", "神奈川県"));
                    m_Data.Add(new DispCode("142539", "上永谷さいとうクリニック", "神奈川県"));
                    m_Data.Add(new DispCode("142549", "弘明寺腎クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("142554", "相模野病院", "神奈川県"));
                    m_Data.Add(new DispCode("142589", "鶴ヶ峰クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("142599", "つるみ腎クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("142609", "菊名記念クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("142619", "戸塚共立ステーションクリニック", "神奈川県"));
                    m_Data.Add(new DispCode("142628", "大倉山記念病院", "神奈川県"));
                    m_Data.Add(new DispCode("142638", "関東病院", "神奈川県"));
                    m_Data.Add(new DispCode("142648", "鎌倉ヒロ病院", "神奈川県"));
                    m_Data.Add(new DispCode("142659", "おおくらやま腎クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("142668", "相和病院", "神奈川県"));
                    m_Data.Add(new DispCode("142679", "多摩向ヶ丘腎クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("142689", "武蔵新城じんクリニック", "神奈川県"));
                    m_Data.Add(new DispCode("142698", "川崎みどりの病院", "神奈川県"));
                    m_Data.Add(new DispCode("142709", "望星二宮クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("142719", "湘南台東口クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("142729", "とよじメディカルクリニック", "神奈川県"));
                    m_Data.Add(new DispCode("142739", "湘南台じんクリニック", "神奈川県"));
                    m_Data.Add(new DispCode("142747", "新百合ヶ丘総合病院", "神奈川県"));
                    m_Data.Add(new DispCode("142759", "元住吉腎クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("142769", "たまプラーザ腎クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("142779", "かもい腎クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("142799", "宮前平第２クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("142809", "瀬谷腎クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("142819", "麻溝じんクリニック", "神奈川県"));
                    m_Data.Add(new DispCode("142829", "橋本みなみ腎クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("142838", "ＡＯＩ国際病院", "神奈川県"));
                    m_Data.Add(new DispCode("142849", "南大和高座クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("142859", "愛川クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("142868", "けいゆう病院", "神奈川県"));
                    m_Data.Add(new DispCode("142879", "綱島腎クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("142888", "赤枝病院", "神奈川県"));
                    m_Data.Add(new DispCode("142899", "井土ヶ谷腎クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("142909", "笠間クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("142919", "青葉台腎クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("142929", "センペル湘南クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("142938", "横浜じんせい病院", "神奈川県"));
                    m_Data.Add(new DispCode("142949", "相模大野内科・腎クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("142959", "白楽腎クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("142962", "横浜医療センター", "神奈川県"));
                    m_Data.Add(new DispCode("142978", "茅ヶ崎徳洲会病院", "神奈川県"));
                    m_Data.Add(new DispCode("142987", "総合相模更生病院", "神奈川県"));
                    m_Data.Add(new DispCode("142993", "横須賀市立総合医療センター", "神奈川県"));
                    m_Data.Add(new DispCode("143009", "西谷腎クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("143019", "つるみ駅前腎クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("143029", "湘南ＧＰクリニック", "神奈川県"));
                    m_Data.Add(new DispCode("143039", "瀬谷南腎クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("143049", "とうめい綾瀬腎クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("143059", "大雄山セントラルクリニック", "神奈川県"));
                    m_Data.Add(new DispCode("143079", "高田腎クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("143088", "湯河原胃腸病院", "神奈川県"));
                    m_Data.Add(new DispCode("143098", "綾瀬厚生病院", "神奈川県"));
                    m_Data.Add(new DispCode("143109", "あつぎ新クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("143119", "内村内科・腎クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("143123", "神奈川県立こども医療センター", "神奈川県"));
                    m_Data.Add(new DispCode("143139", "小田原腎内科クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("143149", "湘英クリニック伊勢原医院", "神奈川県"));
                    m_Data.Add(new DispCode("143168", "横浜いずみ台病院", "神奈川県"));
                    m_Data.Add(new DispCode("143179", "かみみぞ腎クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("143189", "望星平塚第2クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("143199", "ふじさわ駅前ファミリークリニック", "神奈川県"));
                    m_Data.Add(new DispCode("143209", "生麦駅前クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("143218", "中村病院", "神奈川県"));
                    m_Data.Add(new DispCode("143228", "山内病院", "神奈川県"));
                    m_Data.Add(new DispCode("143239", "久地じんクリニック", "神奈川県"));
                    m_Data.Add(new DispCode("143249", "協同ふじさきクリニック", "神奈川県"));
                    m_Data.Add(new DispCode("143259", "つるみ透析内科クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("143269", "とうめい栄町クリニック", "神奈川県"));
                    m_Data.Add(new DispCode("150010", "新潟大学医歯学総合病院", "新潟県"));
                    m_Data.Add(new DispCode("150028", "信楽園病院", "新潟県"));
                    m_Data.Add(new DispCode("150046", "長岡赤十字病院", "新潟県"));
                    m_Data.Add(new DispCode("150059", "片桐記念クリニック", "新潟県"));
                    m_Data.Add(new DispCode("150065", "長岡中央綜合病院", "新潟県"));
                    m_Data.Add(new DispCode("150078", "立川綜合病院", "新潟県"));
                    m_Data.Add(new DispCode("150098", "村上記念病院", "新潟県"));
                    m_Data.Add(new DispCode("150109", "塚野目診療所", "新潟県"));
                    m_Data.Add(new DispCode("150113", "新潟県立新発田病院", "新潟県"));
                    m_Data.Add(new DispCode("150128", "下越病院", "新潟県"));
                    m_Data.Add(new DispCode("150153", "新潟県立中央病院", "新潟県"));
                    m_Data.Add(new DispCode("150163", "あがの市民病院", "新潟県"));
                    m_Data.Add(new DispCode("150173", "新潟県立吉田病院", "新潟県"));
                    m_Data.Add(new DispCode("150189", "大森内科医院", "新潟県"));
                    m_Data.Add(new DispCode("150195", "佐渡総合病院", "新潟県"));
                    m_Data.Add(new DispCode("150209", "渡辺内科医院", "新潟県"));
                    m_Data.Add(new DispCode("150229", "さくらクリニック", "新潟県"));
                    m_Data.Add(new DispCode("150235", "柏崎総合医療センター", "新潟県"));
                    m_Data.Add(new DispCode("150247", "小千谷総合病院", "新潟県"));
                    m_Data.Add(new DispCode("150255", "糸魚川総合病院", "新潟県"));
                    m_Data.Add(new DispCode("150269", "喜多町診療所", "新潟県"));
                    m_Data.Add(new DispCode("150285", "新潟臨港病院", "新潟県"));
                    m_Data.Add(new DispCode("150295", "木戸病院", "新潟県"));
                    m_Data.Add(new DispCode("150305", "上越総合病院", "新潟県"));
                    m_Data.Add(new DispCode("150316", "済生会新潟県央基幹病院", "新潟県"));
                    m_Data.Add(new DispCode("150323", "魚沼市立小出病院", "新潟県"));
                    m_Data.Add(new DispCode("150333", "新潟市民病院", "新潟県"));
                    m_Data.Add(new DispCode("150346", "済生会新潟病院", "新潟県"));
                    m_Data.Add(new DispCode("150355", "新潟白根総合病院", "新潟県"));
                    m_Data.Add(new DispCode("150369", "厚生連小千谷総合病院十日町診療所", "新潟県"));
                    m_Data.Add(new DispCode("150376", "新潟県済生会三条病院", "新潟県"));
                    m_Data.Add(new DispCode("150383", "新潟県立坂町病院", "新潟県"));
                    m_Data.Add(new DispCode("150399", "五泉六島クリニック", "新潟県"));
                    m_Data.Add(new DispCode("150403", "南魚沼市民病院", "新潟県"));
                    m_Data.Add(new DispCode("150429", "舞平クリニック", "新潟県"));
                    m_Data.Add(new DispCode("150435", "けいなん総合病院", "新潟県"));
                    m_Data.Add(new DispCode("150448", "南部郷厚生病院", "新潟県"));
                    m_Data.Add(new DispCode("150469", "山東第二医院", "新潟県"));
                    m_Data.Add(new DispCode("150475", "新潟医療センター", "新潟県"));
                    m_Data.Add(new DispCode("150495", "村上総合病院", "新潟県"));
                    m_Data.Add(new DispCode("150509", "信楽園病院附属有明診療所", "新潟県"));
                    m_Data.Add(new DispCode("150518", "山北徳新会病院", "新潟県"));
                    m_Data.Add(new DispCode("150525", "豊栄病院", "新潟県"));
                    m_Data.Add(new DispCode("150539", "三浦内科医院", "新潟県"));
                    m_Data.Add(new DispCode("150549", "甲田内科クリニック", "新潟県"));
                    m_Data.Add(new DispCode("150559", "向陽メディカルクリニック", "新潟県"));
                    m_Data.Add(new DispCode("150589", "新潟中央透析クリニック", "新潟県"));
                    m_Data.Add(new DispCode("150599", "いわむろ透析クリニック", "新潟県"));
                    m_Data.Add(new DispCode("150603", "魚沼基幹病院", "新潟県"));
                    m_Data.Add(new DispCode("150628", "悠遊健康村病院", "新潟県"));
                    m_Data.Add(new DispCode("150638", "新潟聖籠病院", "新潟県"));
                    m_Data.Add(new DispCode("160016", "富山赤十字病院", "富山県"));
                    m_Data.Add(new DispCode("160028", "横田記念病院", "富山県"));
                    m_Data.Add(new DispCode("160039", "元町内科医院", "富山県"));
                    m_Data.Add(new DispCode("160043", "公立南砺中央病院", "富山県"));
                    m_Data.Add(new DispCode("160055", "高岡病院", "富山県"));
                    m_Data.Add(new DispCode("160069", "吉田内科小児科", "富山県"));
                    m_Data.Add(new DispCode("160078", "あさなぎ病院", "富山県"));
                    m_Data.Add(new DispCode("160088", "長谷川病院", "富山県"));
                    m_Data.Add(new DispCode("160093", "市立砺波総合病院", "富山県"));
                    m_Data.Add(new DispCode("160106", "北陸中央病院", "富山県"));
                    m_Data.Add(new DispCode("160113", "富山市立富山市民病院", "富山県"));
                    m_Data.Add(new DispCode("160123", "高岡市民病院", "富山県"));
                    m_Data.Add(new DispCode("160133", "黒部市民病院", "富山県"));
                    m_Data.Add(new DispCode("160148", "不二越病院", "富山県"));
                    m_Data.Add(new DispCode("160160", "富山大学附属病院", "富山県"));
                    m_Data.Add(new DispCode("160172", "富山病院", "富山県"));
                    m_Data.Add(new DispCode("160189", "市野瀬和田内科医院", "富山県"));
                    m_Data.Add(new DispCode("160198", "坂東病院", "富山県"));
                    m_Data.Add(new DispCode("160206", "富山労災病院", "富山県"));
                    m_Data.Add(new DispCode("160213", "富山県立中央病院", "富山県"));
                    m_Data.Add(new DispCode("160223", "氷見市民病院", "富山県"));
                    m_Data.Add(new DispCode("160239", "泌尿器科小島医院", "富山県"));
                    m_Data.Add(new DispCode("160259", "高陵クリニック", "富山県"));
                    m_Data.Add(new DispCode("160265", "富山協立病院", "富山県"));
                    m_Data.Add(new DispCode("160273", "南砺市民病院", "富山県"));
                    m_Data.Add(new DispCode("160285", "厚生連滑川病院", "富山県"));
                    m_Data.Add(new DispCode("160298", "中村記念病院", "富山県"));
                    m_Data.Add(new DispCode("160306", "富山病院", "富山県"));
                    m_Data.Add(new DispCode("160318", "政岡内科病院", "富山県"));
                    m_Data.Add(new DispCode("160328", "成和病院", "富山県"));
                    m_Data.Add(new DispCode("160338", "富山城南病院", "富山県"));
                    m_Data.Add(new DispCode("160346", "富山県済生会高岡病院", "富山県"));
                    m_Data.Add(new DispCode("160353", "かみいち総合病院", "富山県"));
                    m_Data.Add(new DispCode("160369", "河合内科医院", "富山県"));
                    m_Data.Add(new DispCode("160379", "泉が丘内科クリニック", "富山県"));
                    m_Data.Add(new DispCode("160398", "真生会富山病院", "富山県"));
                    m_Data.Add(new DispCode("160409", "（照風会）三川クリニック", "富山県"));
                    m_Data.Add(new DispCode("160419", "うさかクリニック", "富山県"));
                    m_Data.Add(new DispCode("160427", "富山西総合病院", "富山県"));
                    m_Data.Add(new DispCode("167023", "射水市民病院", "富山県"));
                    m_Data.Add(new DispCode("167097", "あさひ総合病院", "富山県"));
                    m_Data.Add(new DispCode("170033", "公立宇出津総合病院", "石川県"));
                    m_Data.Add(new DispCode("170050", "金沢大学附属病院", "石川県"));
                    m_Data.Add(new DispCode("170063", "石川県立中央病院", "石川県"));
                    m_Data.Add(new DispCode("170074", "JCHO金沢病院", "石川県"));
                    m_Data.Add(new DispCode("170082", "金沢医療センター", "石川県"));
                    m_Data.Add(new DispCode("170098", "城北病院", "石川県"));
                    m_Data.Add(new DispCode("170106", "石川県済生会金沢病院", "石川県"));
                    m_Data.Add(new DispCode("170116", "北陸病院", "石川県"));
                    m_Data.Add(new DispCode("170127", "浅ノ川総合病院", "石川県"));
                    m_Data.Add(new DispCode("170133", "公立能登総合病院", "石川県"));
                    m_Data.Add(new DispCode("170147", "恵寿総合病院", "石川県"));
                    m_Data.Add(new DispCode("170163", "小松市民病院", "石川県"));
                    m_Data.Add(new DispCode("170173", "公立松任石川中央病院", "石川県"));
                    m_Data.Add(new DispCode("170181", "金沢医科大学病院", "石川県"));
                    m_Data.Add(new DispCode("170198", "金沢西病院", "石川県"));
                    m_Data.Add(new DispCode("170233", "市立輪島病院", "石川県"));
                    m_Data.Add(new DispCode("170259", "田谷泌尿器科医院", "石川県"));
                    m_Data.Add(new DispCode("170269", "井村内科・腎透析クリニック", "石川県"));
                    m_Data.Add(new DispCode("170273", "公立羽咋病院", "石川県"));
                    m_Data.Add(new DispCode("170283", "珠洲市総合病院", "石川県"));
                    m_Data.Add(new DispCode("170299", "板谷医院", "石川県"));
                    m_Data.Add(new DispCode("170303", "金沢市立病院", "石川県"));
                    m_Data.Add(new DispCode("170313", "公立穴水総合病院", "石川県"));
                    m_Data.Add(new DispCode("170323", "公立つるぎ病院", "石川県"));
                    m_Data.Add(new DispCode("170333", "能美市立病院", "石川県"));
                    m_Data.Add(new DispCode("170348", "小松ソフィア病院", "石川県"));
                    m_Data.Add(new DispCode("170359", "こしの内科クリニック", "石川県"));
                    m_Data.Add(new DispCode("170366", "金沢赤十字病院", "石川県"));
                    m_Data.Add(new DispCode("170379", "らいふクリニック", "石川県"));
                    m_Data.Add(new DispCode("170389", "西東泌尿器科医院", "石川県"));
                    m_Data.Add(new DispCode("170408", "芳珠記念病院", "石川県"));
                    m_Data.Add(new DispCode("170418", "金沢有松病院", "石川県"));
                    m_Data.Add(new DispCode("170449", "だいもん内科・腎透析クリニック", "石川県"));
                    m_Data.Add(new DispCode("170453", "加賀市医療センター", "石川県"));
                    m_Data.Add(new DispCode("170468", "みずほ病院", "石川県"));
                    m_Data.Add(new DispCode("170479", "西インター内科・透析クリニック", "石川県"));
                    m_Data.Add(new DispCode("170488", "心臓血管センター金沢循環器病院", "石川県"));
                    m_Data.Add(new DispCode("170499", "マッサン内科・透析クリニック", "石川県"));
                    m_Data.Add(new DispCode("170508", "二ツ屋病院", "石川県"));
                    m_Data.Add(new DispCode("170518", "南ヶ丘病院", "石川県"));
                    m_Data.Add(new DispCode("170529", "あだち腎透析高血圧クリニック", "石川県"));
                    m_Data.Add(new DispCode("170539", "金沢てらじクリニック", "石川県"));
                    m_Data.Add(new DispCode("177038", "寺井病院", "石川県"));
                    m_Data.Add(new DispCode("180013", "福井県立病院", "福井県"));
                    m_Data.Add(new DispCode("180026", "福井赤十字病院", "福井県"));
                    m_Data.Add(new DispCode("180036", "福井県済生会病院", "福井県"));
                    m_Data.Add(new DispCode("180048", "藤田記念病院", "福井県"));
                    m_Data.Add(new DispCode("180073", "市立敦賀病院", "福井県"));
                    m_Data.Add(new DispCode("180088", "林病院", "福井県"));
                    m_Data.Add(new DispCode("180109", "福島泌尿器科医院", "福井県"));
                    m_Data.Add(new DispCode("180113", "杉田玄白記念公立小浜病院", "福井県"));
                    m_Data.Add(new DispCode("180129", "細川泌尿器科医院", "福井県"));
                    m_Data.Add(new DispCode("180138", "広瀬病院", "福井県"));
                    m_Data.Add(new DispCode("180144", "若狭高浜病院", "福井県"));
                    m_Data.Add(new DispCode("180150", "福井大学医学部附属病院", "福井県"));
                    m_Data.Add(new DispCode("180169", "あすわクリニック", "福井県"));
                    m_Data.Add(new DispCode("180173", "坂井市立三国病院", "福井県"));
                    m_Data.Add(new DispCode("180198", "福井厚生病院", "福井県"));
                    m_Data.Add(new DispCode("180208", "泉ヶ丘病院", "福井県"));
                    m_Data.Add(new DispCode("180214", "福井勝山総合病院", "福井県"));
                    m_Data.Add(new DispCode("180239", "鈴木クリニック", "福井県"));
                    m_Data.Add(new DispCode("180259", "はやしクリニック", "福井県"));
                    m_Data.Add(new DispCode("180263", "公立丹南病院", "福井県"));
                    m_Data.Add(new DispCode("180278", "木村病院", "福井県"));
                    m_Data.Add(new DispCode("180289", "福井総合クリニック", "福井県"));
                    m_Data.Add(new DispCode("180299", "越前外科内科医院", "福井県"));
                    m_Data.Add(new DispCode("180309", "鯖江腎臓クリニック", "福井県"));
                    m_Data.Add(new DispCode("180318", "岩井病院", "福井県"));
                    m_Data.Add(new DispCode("180329", "大山クリニック", "福井県"));
                    m_Data.Add(new DispCode("180339", "はるそら内科クリニック", "福井県"));
                    m_Data.Add(new DispCode("187028", "中村病院", "福井県"));
                    m_Data.Add(new DispCode("190013", "山梨県立中央病院", "山梨県"));
                    m_Data.Add(new DispCode("190028", "甲府共立病院", "山梨県"));
                    m_Data.Add(new DispCode("190033", "市立甲府病院", "山梨県"));
                    m_Data.Add(new DispCode("190049", "三井クリニック", "山梨県"));
                    m_Data.Add(new DispCode("190073", "富士吉田市立病院", "山梨県"));
                    m_Data.Add(new DispCode("190083", "大月市立中央病院", "山梨県"));
                    m_Data.Add(new DispCode("190098", "山梨厚生病院", "山梨県"));
                    m_Data.Add(new DispCode("190107", "加納岩総合病院", "山梨県"));
                    m_Data.Add(new DispCode("190118", "恵信韮崎病院", "山梨県"));
                    m_Data.Add(new DispCode("190128", "巨摩共立病院", "山梨県"));
                    m_Data.Add(new DispCode("190139", "透析施設　すずきネフロクリニック", "山梨県"));
                    m_Data.Add(new DispCode("190140", "山梨大学医学部附属病院", "山梨県"));
                    m_Data.Add(new DispCode("190153", "峡南医療センター市川三郷病院", "山梨県"));
                    m_Data.Add(new DispCode("190168", "三枝病院", "山梨県"));
                    m_Data.Add(new DispCode("190183", "都留市立病院", "山梨県"));
                    m_Data.Add(new DispCode("190196", "山梨赤十字病院", "山梨県"));
                    m_Data.Add(new DispCode("190209", "甲府昭和腎クリニック", "山梨県"));
                    m_Data.Add(new DispCode("190218", "甲府城南病院", "山梨県"));
                    m_Data.Add(new DispCode("190228", "北杜市立甲陽病院", "山梨県"));
                    m_Data.Add(new DispCode("190238", "石和共立病院", "山梨県"));
                    m_Data.Add(new DispCode("190249", "ふじよしだ勝和クリニック", "山梨県"));
                    m_Data.Add(new DispCode("190253", "上野原市立病院", "山梨県"));
                    m_Data.Add(new DispCode("190268", "白根徳洲会病院", "山梨県"));
                    m_Data.Add(new DispCode("190279", "東甲府医院", "山梨県"));
                    m_Data.Add(new DispCode("190288", "笛吹中央病院", "山梨県"));
                    m_Data.Add(new DispCode("190298", "身延山病院", "山梨県"));
                    m_Data.Add(new DispCode("190303", "北杜市立塩川病院", "山梨県"));
                    m_Data.Add(new DispCode("190319", "武井医院", "山梨県"));
                    m_Data.Add(new DispCode("190329", "原口内科・腎クリニック", "山梨県"));
                    m_Data.Add(new DispCode("190349", "櫻林腎・内科クリニック", "山梨県"));
                    m_Data.Add(new DispCode("190359", "ふじさん腎臓内科クリニック", "山梨県"));
                    m_Data.Add(new DispCode("190369", "アルプス腎クリニック", "山梨県"));
                    m_Data.Add(new DispCode("197018", "組合立飯富病院", "山梨県"));
                    m_Data.Add(new DispCode("197048", "峡南病院", "山梨県"));
                    m_Data.Add(new DispCode("200015", "篠ノ井総合病院", "長野県"));
                    m_Data.Add(new DispCode("200028", "北野病院", "長野県"));
                    m_Data.Add(new DispCode("200043", "長野県立信州医療センター", "長野県"));
                    m_Data.Add(new DispCode("200050", "信州大学医学部附属病院", "長野県"));
                    m_Data.Add(new DispCode("200062", "まつもと医療センター", "長野県"));
                    m_Data.Add(new DispCode("200078", "相澤病院", "長野県"));
                    m_Data.Add(new DispCode("200098", "輝山会記念病院", "長野県"));
                    m_Data.Add(new DispCode("200103", "市立大町総合病院", "長野県"));
                    m_Data.Add(new DispCode("200116", "諏訪赤十字病院", "長野県"));
                    m_Data.Add(new DispCode("200123", "昭和伊南総合病院", "長野県"));
                    m_Data.Add(new DispCode("200135", "北信総合病院", "長野県"));
                    m_Data.Add(new DispCode("200145", "佐久総合病院", "長野県"));
                    m_Data.Add(new DispCode("200158", "丸子中央病院", "長野県"));
                    m_Data.Add(new DispCode("200165", "北アルプス医療センターあづみ病院", "長野県"));
                    m_Data.Add(new DispCode("200178", "軽井沢西部総合病院", "長野県"));
                    m_Data.Add(new DispCode("200183", "長野県立木曽病院", "長野県"));
                    m_Data.Add(new DispCode("200193", "伊那中央病院", "長野県"));
                    m_Data.Add(new DispCode("200208", "諏訪共立病院", "長野県"));
                    m_Data.Add(new DispCode("200229", "柏原クリニック", "長野県"));
                    m_Data.Add(new DispCode("200233", "諏訪中央病院", "長野県"));
                    m_Data.Add(new DispCode("200246", "長野赤十字病院", "長野県"));
                    m_Data.Add(new DispCode("200259", "駒ヶ根共立クリニック", "長野県"));
                    m_Data.Add(new DispCode("200269", "池田クリニック", "長野県"));
                    m_Data.Add(new DispCode("200273", "長野県立阿南病院", "長野県"));
                    m_Data.Add(new DispCode("200293", "飯田市立病院", "長野県"));
                    m_Data.Add(new DispCode("200305", "浅間南麓こもろ医療センター", "長野県"));
                    m_Data.Add(new DispCode("200319", "上田腎臓クリニック", "長野県"));
                    m_Data.Add(new DispCode("200326", "飯山赤十字病院", "長野県"));
                    m_Data.Add(new DispCode("200339", "松塩クリニック", "長野県"));
                    m_Data.Add(new DispCode("200359", "鈴木泌尿器科", "長野県"));
                    m_Data.Add(new DispCode("200365", "長野中央病院", "長野県"));
                    m_Data.Add(new DispCode("200378", "松本協立病院", "長野県"));
                    m_Data.Add(new DispCode("200383", "国保依田窪病院", "長野県"));
                    m_Data.Add(new DispCode("200413", "浅間総合病院", "長野県"));
                    m_Data.Add(new DispCode("200428", "健和会病院", "長野県"));
                    m_Data.Add(new DispCode("200447", "松本市立病院", "長野県"));
                    m_Data.Add(new DispCode("200453", "町立辰野病院", "長野県"));
                    m_Data.Add(new DispCode("200469", "佐藤医院", "長野県"));
                    m_Data.Add(new DispCode("200475", "上伊那生協病院", "長野県"));
                    m_Data.Add(new DispCode("200483", "飯綱町立飯綱病院", "長野県"));
                    m_Data.Add(new DispCode("200496", "下伊那赤十字病院", "長野県"));
                    m_Data.Add(new DispCode("200508", "飯田病院", "長野県"));
                    m_Data.Add(new DispCode("200519", "あおばクリニック", "長野県"));
                    m_Data.Add(new DispCode("200528", "藤森病院", "長野県"));
                    m_Data.Add(new DispCode("200533", "長野市民病院", "長野県"));
                    m_Data.Add(new DispCode("200545", "下伊那厚生病院", "長野県"));
                    m_Data.Add(new DispCode("200559", "長野上田クリニック", "長野県"));
                    m_Data.Add(new DispCode("200579", "南長野クリニック", "長野県"));
                    m_Data.Add(new DispCode("200585", "北アルプス医療センター白馬診療所", "長野県"));
                    m_Data.Add(new DispCode("200595", "富士見高原医療福祉センター 富士見高原病院", "長野県"));
                    m_Data.Add(new DispCode("200608", "塩尻協立病院", "長野県"));
                    m_Data.Add(new DispCode("200628", "千曲中央病院", "長野県"));
                    m_Data.Add(new DispCode("200633", "軽井沢町国民健康保険軽井沢病院", "長野県"));
                    m_Data.Add(new DispCode("200648", "穂高病院", "長野県"));
                    m_Data.Add(new DispCode("200656", "安曇野赤十字病院", "長野県"));
                    m_Data.Add(new DispCode("200663", "東御市民病院", "長野県"));
                    m_Data.Add(new DispCode("200679", "上田透析クリニック", "長野県"));
                    m_Data.Add(new DispCode("200683", "岡谷市民病院", "長野県"));
                    m_Data.Add(new DispCode("200709", "神應透析クリニック", "長野県"));
                    m_Data.Add(new DispCode("200719", "徳永医院", "長野県"));
                    m_Data.Add(new DispCode("200729", "いでうら内科クリニック", "長野県"));
                    m_Data.Add(new DispCode("200758", "上山田病院", "長野県"));
                    m_Data.Add(new DispCode("200769", "須坂 腎・透析クリニック", "長野県"));
                    m_Data.Add(new DispCode("200779", "あさまコスモスクリニック", "長野県"));
                    m_Data.Add(new DispCode("200782", "信州上田医療センター", "長野県"));
                    m_Data.Add(new DispCode("200795", "佐久総合病院　佐久医療センター", "長野県"));
                    m_Data.Add(new DispCode("200805", "長野松代総合病院", "長野県"));
                    m_Data.Add(new DispCode("200819", "ユーインケアクリニック", "長野県"));
                    m_Data.Add(new DispCode("207076", "ＪＡ長野厚生連新町病院", "長野県"));
                    m_Data.Add(new DispCode("207098", "松本中川病院", "長野県"));
                    m_Data.Add(new DispCode("207189", "宮坂クリニック諏訪", "長野県"));
                    m_Data.Add(new DispCode("210010", "岐阜大学医学部附属病院", "岐阜県"));
                    m_Data.Add(new DispCode("210033", "岐阜県総合医療センター", "岐阜県"));
                    m_Data.Add(new DispCode("210043", "岐阜市民病院", "岐阜県"));
                    m_Data.Add(new DispCode("210058", "早徳病院", "岐阜県"));
                    m_Data.Add(new DispCode("210065", "久美愛厚生病院", "岐阜県"));
                    m_Data.Add(new DispCode("210083", "大垣市民病院", "岐阜県"));
                    m_Data.Add(new DispCode("210099", "松岡内科クリニック", "岐阜県"));
                    m_Data.Add(new DispCode("210106", "高山赤十字病院", "岐阜県"));
                    m_Data.Add(new DispCode("210113", "美濃市立美濃病院", "岐阜県"));
                    m_Data.Add(new DispCode("210125", "東濃厚生病院", "岐阜県"));
                    m_Data.Add(new DispCode("210138", "中部国際医療センター", "岐阜県"));
                    m_Data.Add(new DispCode("210148", "博愛会病院", "岐阜県"));
                    m_Data.Add(new DispCode("210155", "中濃厚生病院", "岐阜県"));
                    m_Data.Add(new DispCode("210163", "国民健康保険坂下診療所", "岐阜県"));
                    m_Data.Add(new DispCode("210178", "高井病院", "岐阜県"));
                    m_Data.Add(new DispCode("210198", "澤田病院", "岐阜県"));
                    m_Data.Add(new DispCode("210207", "平野総合病院", "岐阜県"));
                    m_Data.Add(new DispCode("210217", "松波総合病院", "岐阜県"));
                    m_Data.Add(new DispCode("210229", "やまぐち内科クリニック", "岐阜県"));
                    m_Data.Add(new DispCode("210243", "郡上市民病院", "岐阜県"));
                    m_Data.Add(new DispCode("210259", "多治見クリニック", "岐阜県"));
                    m_Data.Add(new DispCode("210263", "岐阜県立下呂温泉病院", "岐阜県"));
                    m_Data.Add(new DispCode("210273", "飛騨市民病院", "岐阜県"));
                    m_Data.Add(new DispCode("210288", "白川病院", "岐阜県"));
                    m_Data.Add(new DispCode("210298", "馬渕病院", "岐阜県"));
                    m_Data.Add(new DispCode("210301", "朝日大学病院", "岐阜県"));
                    m_Data.Add(new DispCode("210313", "岐阜県立多治見病院", "岐阜県"));
                    m_Data.Add(new DispCode("210328", "城山病院", "岐阜県"));
                    m_Data.Add(new DispCode("210338", "操外科病院", "岐阜県"));
                    m_Data.Add(new DispCode("210349", "吉村内科", "岐阜県"));
                    m_Data.Add(new DispCode("210358", "タジミ第一病院", "岐阜県"));
                    m_Data.Add(new DispCode("210366", "東海中央病院", "岐阜県"));
                    m_Data.Add(new DispCode("210379", "新可児クリニック", "岐阜県"));
                    m_Data.Add(new DispCode("210385", "西美濃厚生病院", "岐阜県"));
                    m_Data.Add(new DispCode("210393", "総合病院中津川市民病院", "岐阜県"));
                    m_Data.Add(new DispCode("210409", "羽島クリニック", "岐阜県"));
                    m_Data.Add(new DispCode("210419", "高桑内科クリニック", "岐阜県"));
                    m_Data.Add(new DispCode("210439", "太田メディカルクリニック", "岐阜県"));
                    m_Data.Add(new DispCode("210455", "西濃厚生病院", "岐阜県"));
                    m_Data.Add(new DispCode("210465", "岐阜･西濃医療センター 岐北厚生病院", "岐阜県"));
                    m_Data.Add(new DispCode("210473", "羽島市民病院", "岐阜県"));
                    m_Data.Add(new DispCode("210489", "中津川共立クリニック", "岐阜県"));
                    m_Data.Add(new DispCode("210509", "各務原そはらクリニック", "岐阜県"));
                    m_Data.Add(new DispCode("210518", "東可児病院", "岐阜県"));
                    m_Data.Add(new DispCode("210526", "岐阜赤十字病院", "岐阜県"));
                    m_Data.Add(new DispCode("210539", "水谷医院", "岐阜県"));
                    m_Data.Add(new DispCode("210549", "大垣北クリニック", "岐阜県"));
                    m_Data.Add(new DispCode("210559", "土岐白楊クリニック", "岐阜県"));
                    m_Data.Add(new DispCode("210568", "みどり病院", "岐阜県"));
                    m_Data.Add(new DispCode("210579", "安八診療所", "岐阜県"));
                    m_Data.Add(new DispCode("210589", "山内ホスピタル", "岐阜県"));
                    m_Data.Add(new DispCode("210619", "うぬま東クリニック", "岐阜県"));
                    m_Data.Add(new DispCode("210628", "河村病院", "岐阜県"));
                    m_Data.Add(new DispCode("210638", "岐阜清流病院", "岐阜県"));
                    m_Data.Add(new DispCode("210659", "サンシャインＭ＆Ｄクリニック", "岐阜県"));
                    m_Data.Add(new DispCode("210678", "大垣中央病院", "岐阜県"));
                    m_Data.Add(new DispCode("210688", "古川病院", "岐阜県"));
                    m_Data.Add(new DispCode("210698", "大垣徳洲会病院", "岐阜県"));
                    m_Data.Add(new DispCode("210709", "宮崎レディスクリニック", "岐阜県"));
                    m_Data.Add(new DispCode("210713", "恵那市国民健康保険岩村診療所", "岐阜県"));
                    m_Data.Add(new DispCode("210723", "土岐市立総合病院", "岐阜県"));
                    m_Data.Add(new DispCode("210759", "各務原リハビリテーション病院", "岐阜県"));
                    m_Data.Add(new DispCode("210769", "ゆり形成　内科　整形　おおの", "岐阜県"));
                    m_Data.Add(new DispCode("210773", "下呂市立金山病院", "岐阜県"));
                    m_Data.Add(new DispCode("210783", "市立恵那病院", "岐阜県"));
                    m_Data.Add(new DispCode("210799", "幸クリニック", "岐阜県"));
                    m_Data.Add(new DispCode("210809", "ひばりクリニック", "岐阜県"));
                    m_Data.Add(new DispCode("210818", "多治見市民病院", "岐阜県"));
                    m_Data.Add(new DispCode("210829", "フロンティア岐阜駅前クリニック", "岐阜県"));
                    m_Data.Add(new DispCode("217018", "藤掛病院", "岐阜県"));
                    m_Data.Add(new DispCode("217053", "県北西部地域医療センター国保白鳥病院", "岐阜県"));
                    m_Data.Add(new DispCode("217099", "道しるべ", "岐阜県"));
                    m_Data.Add(new DispCode("217153", "国保関ヶ原診療所", "岐阜県"));
                    m_Data.Add(new DispCode("220013", "静岡市立静岡病院", "静岡県"));
                    m_Data.Add(new DispCode("220023", "静岡県立総合病院", "静岡県"));
                    m_Data.Add(new DispCode("220039", "菅野医院分院", "静岡県"));
                    m_Data.Add(new DispCode("220046", "静岡済生会総合病院", "静岡県"));
                    m_Data.Add(new DispCode("220053", "市立御前崎総合病院", "静岡県"));
                    m_Data.Add(new DispCode("220068", "聖隷浜松病院", "静岡県"));
                    m_Data.Add(new DispCode("220078", "丸山病院", "静岡県"));
                    m_Data.Add(new DispCode("220089", "五十嵐医院", "静岡県"));
                    m_Data.Add(new DispCode("220103", "沼津市立病院", "静岡県"));
                    m_Data.Add(new DispCode("220119", "宮地医院", "静岡県"));
                    m_Data.Add(new DispCode("220124", "三島総合病院", "静岡県"));
                    m_Data.Add(new DispCode("220139", "指出泌尿器科", "静岡県"));
                    m_Data.Add(new DispCode("220143", "磐田市立総合病院", "静岡県"));
                    m_Data.Add(new DispCode("220159", "天野医院", "静岡県"));
                    m_Data.Add(new DispCode("220173", "島田市立総合医療センター", "静岡県"));
                    m_Data.Add(new DispCode("220199", "望星第一クリニック", "静岡県"));
                    m_Data.Add(new DispCode("220209", "関野医院", "静岡県"));
                    m_Data.Add(new DispCode("220213", "富士市立中央病院", "静岡県"));
                    m_Data.Add(new DispCode("220229", "かげやま医院", "静岡県"));
                    m_Data.Add(new DispCode("220233", "浜松医療センター", "静岡県"));
                    m_Data.Add(new DispCode("220256", "静岡赤十字病院", "静岡県"));
                    m_Data.Add(new DispCode("220269", "浜名クリニック", "静岡県"));
                    m_Data.Add(new DispCode("220278", "聖隷三方原病院", "静岡県"));
                    m_Data.Add(new DispCode("220289", "大村クリニック", "静岡県"));
                    m_Data.Add(new DispCode("220299", "富士第一クリニック", "静岡県"));
                    m_Data.Add(new DispCode("220305", "遠州病院", "静岡県"));
                    m_Data.Add(new DispCode("220343", "焼津市立総合病院", "静岡県"));
                    m_Data.Add(new DispCode("220353", "藤枝市立総合病院", "静岡県"));
                    m_Data.Add(new DispCode("220369", "沼津勝和クリニック", "静岡県"));
                    m_Data.Add(new DispCode("220379", "横山医院", "静岡県"));
                    m_Data.Add(new DispCode("220389", "清水館医院", "静岡県"));
                    m_Data.Add(new DispCode("220407", "榛原総合病院", "静岡県"));
                    m_Data.Add(new DispCode("220418", "聖隷沼津病院", "静岡県"));
                    m_Data.Add(new DispCode("220429", "東海クリニック", "静岡県"));
                    m_Data.Add(new DispCode("220433", "富士宮市立病院", "静岡県"));
                    m_Data.Add(new DispCode("220469", "静岡共立クリニック", "静岡県"));
                    m_Data.Add(new DispCode("220476", "伊豆赤十字病院", "静岡県"));
                    m_Data.Add(new DispCode("220488", "南熱海病院", "静岡県"));
                    m_Data.Add(new DispCode("220498", "浜名病院", "静岡県"));
                    m_Data.Add(new DispCode("220503", "静岡市立清水病院", "静岡県"));
                    m_Data.Add(new DispCode("220529", "はぁとふる内科・泌尿器科　川奈", "静岡県"));
                    m_Data.Add(new DispCode("220539", "伊豆長岡第一クリニック", "静岡県"));
                    m_Data.Add(new DispCode("220549", "志都呂クリニック", "静岡県"));
                    m_Data.Add(new DispCode("220566", "浜松赤十字病院", "静岡県"));
                    m_Data.Add(new DispCode("220579", "みしま勝和クリニック", "静岡県"));
                    m_Data.Add(new DispCode("220588", "西伊豆健育会病院", "静岡県"));
                    m_Data.Add(new DispCode("220597", "共立蒲原総合病院", "静岡県"));
                    m_Data.Add(new DispCode("220606", "浜松労災病院", "静岡県"));
                    m_Data.Add(new DispCode("220619", "みつはし医院", "静岡県"));
                    m_Data.Add(new DispCode("220633", "菊川市立総合病院", "静岡県"));
                    m_Data.Add(new DispCode("220659", "泌尿器科・内科三樹医院", "静岡県"));
                    m_Data.Add(new DispCode("220667", "市立湖西病院", "静岡県"));
                    m_Data.Add(new DispCode("220679", "平井医院", "静岡県"));
                    m_Data.Add(new DispCode("220698", "十全記念病院", "静岡県"));
                    m_Data.Add(new DispCode("220709", "杉山クリニック", "静岡県"));
                    m_Data.Add(new DispCode("220719", "錦野クリニック", "静岡県"));
                    m_Data.Add(new DispCode("220738", "東部病院", "静岡県"));
                    m_Data.Add(new DispCode("220740", "浜松医科大学附属病院", "静岡県"));
                    m_Data.Add(new DispCode("220758", "富士病院", "静岡県"));
                    m_Data.Add(new DispCode("220769", "磐田メイツクリニック", "静岡県"));
                    m_Data.Add(new DispCode("220779", "西伊豆健育会病院附属土肥クリニック", "静岡県"));
                    m_Data.Add(new DispCode("220798", "熱川温泉病院", "静岡県"));
                    m_Data.Add(new DispCode("220829", "丸山クリニック", "静岡県"));
                    m_Data.Add(new DispCode("220841", "順天堂大学医学部附属静岡病院", "静岡県"));
                    m_Data.Add(new DispCode("220859", "のぞみ記念下田循環器・腎臓クリニック", "静岡県"));
                    m_Data.Add(new DispCode("220869", "はた医院", "静岡県"));
                    m_Data.Add(new DispCode("220879", "中原クリニック", "静岡県"));
                    m_Data.Add(new DispCode("220899", "田所クリニック", "静岡県"));
                    m_Data.Add(new DispCode("220908", "山の上病院", "静岡県"));
                    m_Data.Add(new DispCode("220918", "聖隷富士病院", "静岡県"));
                    m_Data.Add(new DispCode("220929", "裾野第一クリニック", "静岡県"));
                    m_Data.Add(new DispCode("220939", "追手町クリニック", "静岡県"));
                    m_Data.Add(new DispCode("220948", "御殿場石川病院", "静岡県"));
                    m_Data.Add(new DispCode("220959", "細江クリニック", "静岡県"));
                    m_Data.Add(new DispCode("220969", "城北共立クリニック", "静岡県"));
                    m_Data.Add(new DispCode("220973", "静岡がんセンター", "静岡県"));
                    m_Data.Add(new DispCode("220987", "康心会伊豆東部病院", "静岡県"));
                    m_Data.Add(new DispCode("221009", "あおきクリニック", "静岡県"));
                    m_Data.Add(new DispCode("221019", "北島クリニック", "静岡県"));
                    m_Data.Add(new DispCode("221029", "北川医院", "静岡県"));
                    m_Data.Add(new DispCode("221039", "加藤クリニック", "静岡県"));
                    m_Data.Add(new DispCode("221049", "竜洋クリニック", "静岡県"));
                    m_Data.Add(new DispCode("221059", "さなるサンクリニック", "静岡県"));
                    m_Data.Add(new DispCode("221069", "はいばらクリニック", "静岡県"));
                    m_Data.Add(new DispCode("221078", "新富士病院", "静岡県"));
                    m_Data.Add(new DispCode("221099", "掛川共立クリニック", "静岡県"));
                    m_Data.Add(new DispCode("221109", "ひりゅうクリニック", "静岡県"));
                    m_Data.Add(new DispCode("221118", "コミュニティーホスピタル甲賀病院", "静岡県"));
                    m_Data.Add(new DispCode("221129", "しぶかわ内科クリニック", "静岡県"));
                    m_Data.Add(new DispCode("221138", "富士小山病院", "静岡県"));
                    m_Data.Add(new DispCode("221141", "国際医療福祉大学熱海病院", "静岡県"));
                    m_Data.Add(new DispCode("221158", "静岡徳洲会病院", "静岡県"));
                    m_Data.Add(new DispCode("221179", "伊豆のさと診療所", "静岡県"));
                    m_Data.Add(new DispCode("221189", "東名富士クリニック", "静岡県"));
                    m_Data.Add(new DispCode("221199", "佐野内科クリニック", "静岡県"));
                    m_Data.Add(new DispCode("221219", "宮下内科クリニック", "静岡県"));
                    m_Data.Add(new DispCode("221249", "ひろクリニック", "静岡県"));
                    m_Data.Add(new DispCode("221259", "春の木第一クリニック", "静岡県"));
                    m_Data.Add(new DispCode("221269", "柿田川第一クリニック", "静岡県"));
                    m_Data.Add(new DispCode("221309", "桜井内科クリニック", "静岡県"));
                    m_Data.Add(new DispCode("221338", "浜松とよおか病院", "静岡県"));
                    m_Data.Add(new DispCode("221349", "はぁとふる内科・泌尿器科　伊豆高原", "静岡県"));
                    m_Data.Add(new DispCode("221369", "うちだ泌尿器科・内科クリニック", "静岡県"));
                    m_Data.Add(new DispCode("221388", "すずかけセントラル病院", "静岡県"));
                    m_Data.Add(new DispCode("221399", "さつきの森クリニック", "静岡県"));
                    m_Data.Add(new DispCode("221409", "佐鳴台あさひクリニック", "静岡県"));
                    m_Data.Add(new DispCode("221413", "中東遠総合医療センター", "静岡県"));
                    m_Data.Add(new DispCode("221428", "東名裾野病院", "静岡県"));
                    m_Data.Add(new DispCode("221439", "しみず巴クリニック", "静岡県"));
                    m_Data.Add(new DispCode("221449", "みずほ腎クリニック", "静岡県"));
                    m_Data.Add(new DispCode("221459", "高丘北あさひクリニック", "静岡県"));
                    m_Data.Add(new DispCode("221469", "有東坂しいのきクリニック", "静岡県"));
                    m_Data.Add(new DispCode("221479", "そらまめ腎・泌尿器科クリニック", "静岡県"));
                    m_Data.Add(new DispCode("221489", "あおき腎・泌尿器クリニック", "静岡県"));
                    m_Data.Add(new DispCode("221499", "三澤クリニック", "静岡県"));
                    m_Data.Add(new DispCode("221508", "熱海 海の見える病院", "静岡県"));
                    m_Data.Add(new DispCode("221529", "沼津岡宮第一クリニック", "静岡県"));
                    m_Data.Add(new DispCode("221538", "平安の森記念病院", "静岡県"));
                    m_Data.Add(new DispCode("221548", "伊豆平和病院", "静岡県"));
                    m_Data.Add(new DispCode("221559", "からし種診療所", "静岡県"));
                    m_Data.Add(new DispCode("221569", "もといちば内科クリニック", "静岡県"));
                    m_Data.Add(new DispCode("221579", "愛野メイツクリニック", "静岡県"));
                    m_Data.Add(new DispCode("221589", "キドニークリニック静岡", "静岡県"));
                    m_Data.Add(new DispCode("221599", "東静岡腎クリニック", "静岡県"));
                    m_Data.Add(new DispCode("221609", "やまぎし腎クリニック", "静岡県"));
                    m_Data.Add(new DispCode("221619", "富士宮東名富士クリニック", "静岡県"));
                    m_Data.Add(new DispCode("221629", "おかにし内科 糖尿病・甲状腺クリニック", "静岡県"));
                    m_Data.Add(new DispCode("221639", "KOGAクリニック", "静岡県"));
                    m_Data.Add(new DispCode("221649", "御殿場透析クリニック", "静岡県"));
                    m_Data.Add(new DispCode("221659", "きぼうの森クリニック", "静岡県"));
                    m_Data.Add(new DispCode("221669", "三島だいば第一クリニック", "静岡県"));
                    m_Data.Add(new DispCode("221679", "藤枝クリニック", "静岡県"));
                    m_Data.Add(new DispCode("227078", "静岡県立こども病院", "静岡県"));
                    m_Data.Add(new DispCode("227239", "山下クリニック", "静岡県"));
                    m_Data.Add(new DispCode("230025", "渥美病院", "愛知県"));
                    m_Data.Add(new DispCode("230030", "名古屋大学医学部附属病院", "愛知県"));
                    m_Data.Add(new DispCode("230043", "一宮市立木曽川市民病院", "愛知県"));
                    m_Data.Add(new DispCode("230058", "名古屋共立病院", "愛知県"));
                    m_Data.Add(new DispCode("230068", "葵セントラル病院", "愛知県"));
                    m_Data.Add(new DispCode("230071", "藤田医科大学病院", "愛知県"));
                    m_Data.Add(new DispCode("230096", "中部労災病院", "愛知県"));
                    m_Data.Add(new DispCode("230104", "中京病院", "愛知県"));
                    m_Data.Add(new DispCode("230119", "新生会附属診療所", "愛知県"));
                    m_Data.Add(new DispCode("230120", "名古屋市立大学医学部附属西部医療センター", "愛知県"));
                    m_Data.Add(new DispCode("230134", "名鉄病院", "愛知県"));
                    m_Data.Add(new DispCode("230148", "増子記念病院", "愛知県"));
                    m_Data.Add(new DispCode("230189", "上飯田クリニック", "愛知県"));
                    m_Data.Add(new DispCode("230199", "城北クリニック", "愛知県"));
                    m_Data.Add(new DispCode("230218", "守山友愛病院", "愛知県"));
                    m_Data.Add(new DispCode("230229", "メディカル－サテライト・名古屋", "愛知県"));
                    m_Data.Add(new DispCode("230238", "新生会第一病院", "愛知県"));
                    m_Data.Add(new DispCode("230249", "中京厚生クリニック", "愛知県"));
                    m_Data.Add(new DispCode("230253", "豊橋市民病院", "愛知県"));
                    m_Data.Add(new DispCode("230269", "岡崎メイツ腎・睡眠クリニック", "愛知県"));
                    m_Data.Add(new DispCode("230278", "大雄会第一病院", "愛知県"));
                    m_Data.Add(new DispCode("230283", "公立陶生病院", "愛知県"));
                    m_Data.Add(new DispCode("230298", "青山病院", "愛知県"));
                    m_Data.Add(new DispCode("230303", "豊川市民病院", "愛知県"));
                    m_Data.Add(new DispCode("230317", "刈谷豊田総合病院", "愛知県"));
                    m_Data.Add(new DispCode("230325", "豊田厚生病院", "愛知県"));
                    m_Data.Add(new DispCode("230338", "成田記念病院", "愛知県"));
                    m_Data.Add(new DispCode("230349", "加茂クリニック", "愛知県"));
                    m_Data.Add(new DispCode("230355", "安城更生病院", "愛知県"));
                    m_Data.Add(new DispCode("230369", "西尾クリニック", "愛知県"));
                    m_Data.Add(new DispCode("230389", "蒲郡クリニック", "愛知県"));
                    m_Data.Add(new DispCode("230408", "佐藤病院", "愛知県"));
                    m_Data.Add(new DispCode("230429", "金山クリニック", "愛知県"));
                    m_Data.Add(new DispCode("230449", "知立クリニック", "愛知県"));
                    m_Data.Add(new DispCode("230451", "愛知医科大学病院", "愛知県"));
                    m_Data.Add(new DispCode("230478", "泰玄会病院", "愛知県"));
                    m_Data.Add(new DispCode("230489", "江崎外科内科", "愛知県"));
                    m_Data.Add(new DispCode("230496", "日本赤十字社愛知医療センター名古屋第二病院", "愛知県"));
                    m_Data.Add(new DispCode("230509", "東海クリニック", "愛知県"));
                    m_Data.Add(new DispCode("230538", "あさい病院", "愛知県"));
                    m_Data.Add(new DispCode("230558", "白楊会病院", "愛知県"));
                    m_Data.Add(new DispCode("230563", "春日井市民病院", "愛知県"));
                    m_Data.Add(new DispCode("230579", "おおの腎泌尿器科", "愛知県"));
                    m_Data.Add(new DispCode("230589", "半田クリニック", "愛知県"));
                    m_Data.Add(new DispCode("230599", "春日井クリニック", "愛知県"));
                    m_Data.Add(new DispCode("230629", "刈谷中央クリニック", "愛知県"));
                    m_Data.Add(new DispCode("230639", "海部共立クリニック", "愛知県"));
                    m_Data.Add(new DispCode("230650", "名古屋市立大学病院", "愛知県"));
                    m_Data.Add(new DispCode("230663", "小牧市民病院", "愛知県"));
                    m_Data.Add(new DispCode("230673", "知多半島りんくう病院", "愛知県"));
                    m_Data.Add(new DispCode("230689", "碧南クリニック", "愛知県"));
                    m_Data.Add(new DispCode("230698", "すぎやま病院", "愛知県"));
                    m_Data.Add(new DispCode("230715", "江南厚生病院", "愛知県"));
                    m_Data.Add(new DispCode("230725", "協立総合病院", "愛知県"));
                    m_Data.Add(new DispCode("230738", "かわな病院", "愛知県"));
                    m_Data.Add(new DispCode("230746", "日本赤十字社愛知医療センター名古屋第一病院", "愛知県"));
                    m_Data.Add(new DispCode("230756", "名城病院", "愛知県"));
                    m_Data.Add(new DispCode("230768", "名古屋記念病院", "愛知県"));
                    m_Data.Add(new DispCode("230778", "大同病院", "愛知県"));
                    m_Data.Add(new DispCode("230789", "おけはざまクリニック", "愛知県"));
                    m_Data.Add(new DispCode("230796", "旭労災病院", "愛知県"));
                    m_Data.Add(new DispCode("230808", "寿光会中央病院", "愛知県"));
                    m_Data.Add(new DispCode("230819", "鳴海クリニック", "愛知県"));
                    m_Data.Add(new DispCode("230828", "トヨタ記念病院", "愛知県"));
                    m_Data.Add(new DispCode("230839", "小牧クリニック", "愛知県"));
                    m_Data.Add(new DispCode("230849", "多和田医院", "愛知県"));
                    m_Data.Add(new DispCode("230869", "名西クリニック", "愛知県"));
                    m_Data.Add(new DispCode("230879", "岡本医院本院", "愛知県"));
                    m_Data.Add(new DispCode("230883", "蒲郡市民病院", "愛知県"));
                    m_Data.Add(new DispCode("230899", "はなのきクリニック", "愛知県"));
                    m_Data.Add(new DispCode("230909", "野村内科", "愛知県"));
                    m_Data.Add(new DispCode("230919", "成瀬泌尿器科", "愛知県"));
                    m_Data.Add(new DispCode("230939", "ノア今池クリニック", "愛知県"));
                    m_Data.Add(new DispCode("230943", "新城市民病院", "愛知県"));
                    m_Data.Add(new DispCode("230955", "海南病院", "愛知県"));
                    m_Data.Add(new DispCode("230989", "名古屋東クリニック", "愛知県"));
                    m_Data.Add(new DispCode("231009", "天野記念クリニック", "愛知県"));
                    m_Data.Add(new DispCode("231019", "岡崎北クリニック", "愛知県"));
                    m_Data.Add(new DispCode("231029", "クリニックつしま", "愛知県"));
                    m_Data.Add(new DispCode("231059", "みずのクリニック", "愛知県"));
                    m_Data.Add(new DispCode("231079", "美合クリニック", "愛知県"));
                    m_Data.Add(new DispCode("231089", "稲沢クリニック", "愛知県"));
                    m_Data.Add(new DispCode("231097", "名古屋徳洲会総合病院", "愛知県"));
                    m_Data.Add(new DispCode("231108", "さくら病院", "愛知県"));
                    m_Data.Add(new DispCode("231138", "茶臼山厚生病院", "愛知県"));
                    m_Data.Add(new DispCode("231149", "とよおかクリニック", "愛知県"));
                    m_Data.Add(new DispCode("231163", "岡崎市民病院", "愛知県"));
                    m_Data.Add(new DispCode("231188", "知多小嶋記念病院", "愛知県"));
                    m_Data.Add(new DispCode("231198", "名古屋掖済会病院", "愛知県"));
                    m_Data.Add(new DispCode("231209", "新栄クリニック", "愛知県"));
                    m_Data.Add(new DispCode("231219", "阿久比クリニック", "愛知県"));
                    m_Data.Add(new DispCode("231229", "本地ヶ原クリニック", "愛知県"));
                    m_Data.Add(new DispCode("231239", "愛知クリニック", "愛知県"));
                    m_Data.Add(new DispCode("231249", "明陽クリニック", "愛知県"));
                    m_Data.Add(new DispCode("231258", "さとう病院", "愛知県"));
                    m_Data.Add(new DispCode("231269", "豊橋メイツクリニック", "愛知県"));
                    m_Data.Add(new DispCode("231289", "美浜クリニック", "愛知県"));
                    m_Data.Add(new DispCode("231299", "安城共立クリニック", "愛知県"));
                    m_Data.Add(new DispCode("231309", "樹クリニック", "愛知県"));
                    m_Data.Add(new DispCode("231319", "新生会クリニック", "愛知県"));
                    m_Data.Add(new DispCode("231335", "総合病院南生協病院", "愛知県"));
                    m_Data.Add(new DispCode("231349", "日進クリニック", "愛知県"));
                    m_Data.Add(new DispCode("231369", "偕行会セントラルクリニック", "愛知県"));
                    m_Data.Add(new DispCode("231379", "熱田クリニック", "愛知県"));
                    m_Data.Add(new DispCode("231383", "知多半島総合医療センター", "愛知県"));
                    m_Data.Add(new DispCode("231399", "於大クリニック", "愛知県"));
                    m_Data.Add(new DispCode("231418", "光寿会リハビリテーション病院", "愛知県"));
                    m_Data.Add(new DispCode("231439", "大府クリニック", "愛知県"));
                    m_Data.Add(new DispCode("231449", "みとクリニック", "愛知県"));
                    m_Data.Add(new DispCode("231469", "みらいメディカルクリニック豊橋", "愛知県"));
                    m_Data.Add(new DispCode("231489", "尾張西クリニック", "愛知県"));
                    m_Data.Add(new DispCode("231496", "名古屋セントラル病院", "愛知県"));
                    m_Data.Add(new DispCode("231509", "印場クリニック", "愛知県"));
                    m_Data.Add(new DispCode("231519", "保見クリニック", "愛知県"));
                    m_Data.Add(new DispCode("231529", "東加茂クリニック", "愛知県"));
                    m_Data.Add(new DispCode("231539", "大幸砂田橋クリニック", "愛知県"));
                    m_Data.Add(new DispCode("231548", "刈谷豊田東病院", "愛知県"));
                    m_Data.Add(new DispCode("231559", "むつみ内科", "愛知県"));
                    m_Data.Add(new DispCode("231569", "碧海共立クリニック", "愛知県"));
                    m_Data.Add(new DispCode("231573", "一宮市立市民病院", "愛知県"));
                    m_Data.Add(new DispCode("231589", "東海知多クリニック", "愛知県"));
                    m_Data.Add(new DispCode("231599", "藤山台診療所", "愛知県"));
                    m_Data.Add(new DispCode("231608", "五条川リハビリテーション病院", "愛知県"));
                    m_Data.Add(new DispCode("231619", "東郷春木クリニック", "愛知県"));
                    m_Data.Add(new DispCode("231629", "メディカルサテライト岩倉", "愛知県"));
                    m_Data.Add(new DispCode("231639", "小木南クリニック", "愛知県"));
                    m_Data.Add(new DispCode("231648", "八千代病院", "愛知県"));
                    m_Data.Add(new DispCode("231659", "みずのクリニック水広分院", "愛知県"));
                    m_Data.Add(new DispCode("231669", "豊田共立クリニック", "愛知県"));
                    m_Data.Add(new DispCode("231679", "於大クリニック阿久比", "愛知県"));
                    m_Data.Add(new DispCode("231687", "総合青山病院", "愛知県"));
                    m_Data.Add(new DispCode("231699", "名古屋北クリニック", "愛知県"));
                    m_Data.Add(new DispCode("231709", "半田共立クリニック", "愛知県"));
                    m_Data.Add(new DispCode("231718", "高須病院", "愛知県"));
                    m_Data.Add(new DispCode("231729", "坂下クリニック", "愛知県"));
                    m_Data.Add(new DispCode("231733", "津島市民病院", "愛知県"));
                    m_Data.Add(new DispCode("231748", "小林記念病院", "愛知県"));
                    m_Data.Add(new DispCode("231769", "おおしみず愛知クリニック", "愛知県"));
                    m_Data.Add(new DispCode("231779", "葵クリニック西岡崎", "愛知県"));
                    m_Data.Add(new DispCode("231789", "豊川メイツクリニック", "愛知県"));
                    m_Data.Add(new DispCode("231799", "増子クリニック昴", "愛知県"));
                    m_Data.Add(new DispCode("231809", "半田東クリニック", "愛知県"));
                    m_Data.Add(new DispCode("231819", "あすかクリニック", "愛知県"));
                    m_Data.Add(new DispCode("231829", "名古屋栄クリニック", "愛知県"));
                    m_Data.Add(new DispCode("231839", "桃花台スマイルクリニック", "愛知県"));
                    m_Data.Add(new DispCode("231849", "名港共立クリニック", "愛知県"));
                    m_Data.Add(new DispCode("231859", "メディカルサテライト知多", "愛知県"));
                    m_Data.Add(new DispCode("231869", "春日井セントラルクリニック", "愛知県"));
                    m_Data.Add(new DispCode("231879", "森林公園通クリニック", "愛知県"));
                    m_Data.Add(new DispCode("231889", "宮川醫院", "愛知県"));
                    m_Data.Add(new DispCode("231893", "公立西知多総合病院", "愛知県"));
                    m_Data.Add(new DispCode("231902", "名古屋医療センター", "愛知県"));
                    m_Data.Add(new DispCode("231918", "済衆館病院", "愛知県"));
                    m_Data.Add(new DispCode("231929", "あすかクリニック愛西", "愛知県"));
                    m_Data.Add(new DispCode("231937", "さくら総合病院", "愛知県"));
                    m_Data.Add(new DispCode("231948", "偕行会リハビリテーション病院", "愛知県"));
                    m_Data.Add(new DispCode("231968", "光寿会春日井病院", "愛知県"));
                    m_Data.Add(new DispCode("231999", "白楊クリニック", "愛知県"));
                    m_Data.Add(new DispCode("232029", "あつみメディカルクリニック", "愛知県"));
                    m_Data.Add(new DispCode("232049", "瀬戸共立クリニック", "愛知県"));
                    m_Data.Add(new DispCode("232058", "泰玄会西病院", "愛知県"));
                    m_Data.Add(new DispCode("232079", "たやす腎クリニック", "愛知県"));
                    m_Data.Add(new DispCode("232088", "偕行会城西病院", "愛知県"));
                    m_Data.Add(new DispCode("232099", "日名透析クリニック", "愛知県"));
                    m_Data.Add(new DispCode("232109", "新瑞橋ネフロクリニック", "愛知県"));
                    m_Data.Add(new DispCode("232119", "平針記念クリニック", "愛知県"));
                    m_Data.Add(new DispCode("232129", "ごきそ腎クリニック", "愛知県"));
                    m_Data.Add(new DispCode("232138", "名古屋西病院", "愛知県"));
                    m_Data.Add(new DispCode("232147", "総合上飯田第一病院", "愛知県"));
                    m_Data.Add(new DispCode("232159", "おおぞねメディカルクリニック", "愛知県"));
                    m_Data.Add(new DispCode("232168", "豊橋元町病院", "愛知県"));
                    m_Data.Add(new DispCode("232179", "桜セントラルクリニック", "愛知県"));
                    m_Data.Add(new DispCode("232189", "いつきクリニック石川橋", "愛知県"));
                    m_Data.Add(new DispCode("232199", "いつきクリニック一宮", "愛知県"));
                    m_Data.Add(new DispCode("232209", "大幸砂田橋ブランチクリニック", "愛知県"));
                    m_Data.Add(new DispCode("232210", "名古屋市立大学医学部附属東部医療センター", "愛知県"));
                    m_Data.Add(new DispCode("232228", "桶狭間病院藤田こころケアセンター", "愛知県"));
                    m_Data.Add(new DispCode("232238", "守山いつき病院", "愛知県"));
                    m_Data.Add(new DispCode("232249", "今池腎クリニック", "愛知県"));
                    m_Data.Add(new DispCode("232269", "クリニック大倉", "愛知県"));
                    m_Data.Add(new DispCode("232288", "第二積善病院", "愛知県"));
                    m_Data.Add(new DispCode("232298", "名豊病院", "愛知県"));
                    m_Data.Add(new DispCode("232308", "高浜豊田病院", "愛知県"));
                    m_Data.Add(new DispCode("232311", "藤田医科大学ばんたね病院", "愛知県"));
                    m_Data.Add(new DispCode("232329", "小木こどもファミリークリニック", "愛知県"));
                    m_Data.Add(new DispCode("232349", "浄水共立クリニック", "愛知県"));
                    m_Data.Add(new DispCode("232359", "ゆりクリニック名古屋東", "愛知県"));
                    m_Data.Add(new DispCode("232381", "愛知医科大学メディカルセンター", "愛知県"));
                    m_Data.Add(new DispCode("232409", "引山クリニック", "愛知県"));
                    m_Data.Add(new DispCode("232419", "クリスタルファミリークリニック", "愛知県"));
                    m_Data.Add(new DispCode("232438", "国府病院", "愛知県"));
                    m_Data.Add(new DispCode("232441", "藤田医科大学岡崎医療センター", "愛知県"));
                    m_Data.Add(new DispCode("232458", "ＡＯＩ名古屋病院", "愛知県"));
                    m_Data.Add(new DispCode("232469", "ノア梅森台クリニック", "愛知県"));
                    m_Data.Add(new DispCode("232477", "総合大雄会病院", "愛知県"));
                    m_Data.Add(new DispCode("232489", "リバーサイドクリニック内田橋", "愛知県"));
                    m_Data.Add(new DispCode("237048", "杉石病院", "愛知県"));
                    m_Data.Add(new DispCode("237059", "第２しもざとクリニック", "愛知県"));
                    m_Data.Add(new DispCode("237249", "知多サザンクリニック", "愛知県"));
                    m_Data.Add(new DispCode("237279", "安城新田クリニック", "愛知県"));
                    m_Data.Add(new DispCode("237343", "あいち小児保健医療総合センター", "愛知県"));
                    m_Data.Add(new DispCode("237409", "三河クリニック", "愛知県"));
                    m_Data.Add(new DispCode("240010", "三重大学医学部附属病院", "三重県"));
                    m_Data.Add(new DispCode("240023", "伊賀市立上野総合市民病院", "三重県"));
                    m_Data.Add(new DispCode("240057", "尾鷲総合病院", "三重県"));
                    m_Data.Add(new DispCode("240068", "紀南病院", "三重県"));
                    m_Data.Add(new DispCode("240076", "済生会松阪総合病院", "三重県"));
                    m_Data.Add(new DispCode("240088", "遠山病院", "三重県"));
                    m_Data.Add(new DispCode("240098", "武内病院", "三重県"));
                    m_Data.Add(new DispCode("240104", "四日市羽津医療センター", "三重県"));
                    m_Data.Add(new DispCode("240113", "三重県立総合医療センター", "三重県"));
                    m_Data.Add(new DispCode("240123", "市立四日市病院", "三重県"));
                    m_Data.Add(new DispCode("240138", "主体会病院", "三重県"));
                    m_Data.Add(new DispCode("240143", "市立伊勢総合病院", "三重県"));
                    m_Data.Add(new DispCode("240153", "松阪市民病院", "三重県"));
                    m_Data.Add(new DispCode("240165", "松阪中央総合病院", "三重県"));
                    m_Data.Add(new DispCode("240173", "桑名市総合医療センター", "三重県"));
                    m_Data.Add(new DispCode("240188", "山崎病院", "三重県"));
                    m_Data.Add(new DispCode("240195", "鈴鹿中央総合病院", "三重県"));
                    m_Data.Add(new DispCode("240209", "鈴鹿腎クリニック", "三重県"));
                    m_Data.Add(new DispCode("240216", "伊勢赤十字病院", "三重県"));
                    m_Data.Add(new DispCode("240223", "三重県立志摩病院", "三重県"));
                    m_Data.Add(new DispCode("240239", "たけざわクリニック", "三重県"));
                    m_Data.Add(new DispCode("240258", "四日市消化器病センター", "三重県"));
                    m_Data.Add(new DispCode("240265", "大台厚生病院", "三重県"));
                    m_Data.Add(new DispCode("240273", "亀山市立医療センター", "三重県"));
                    m_Data.Add(new DispCode("240287", "岡波総合病院", "三重県"));
                    m_Data.Add(new DispCode("240309", "ハートクリニック福井", "三重県"));
                    m_Data.Add(new DispCode("240313", "名張市立病院", "三重県"));
                    m_Data.Add(new DispCode("240329", "ほりいクリニック", "三重県"));
                    m_Data.Add(new DispCode("240337", "ヨナハ丘の上病院", "三重県"));
                    m_Data.Add(new DispCode("240349", "伊勢志摩腎クリニック", "三重県"));
                    m_Data.Add(new DispCode("240359", "さくらクリニック松阪", "三重県"));
                    m_Data.Add(new DispCode("240368", "小山田記念温泉病院", "三重県"));
                    m_Data.Add(new DispCode("240389", "四日市セントラルクリニック", "三重県"));
                    m_Data.Add(new DispCode("240395", "三重北医療センター いなべ総合病院", "三重県"));
                    m_Data.Add(new DispCode("240408", "榊原温泉病院", "三重県"));
                    m_Data.Add(new DispCode("240418", "村瀬病院", "三重県"));
                    m_Data.Add(new DispCode("240428", "松阪厚生病院", "三重県"));
                    m_Data.Add(new DispCode("240459", "四日市道しるべ", "三重県"));
                    m_Data.Add(new DispCode("240469", "伊勢志摩腎クリニック松阪分院", "三重県"));
                    m_Data.Add(new DispCode("240489", "津みなみクリニック", "三重県"));
                    m_Data.Add(new DispCode("240499", "四日市腎クリニック", "三重県"));
                    m_Data.Add(new DispCode("240509", "ほりいクリニック希央台", "三重県"));
                    m_Data.Add(new DispCode("240517", "みたき総合病院", "三重県"));
                    m_Data.Add(new DispCode("240529", "くわな共立クリニック", "三重県"));
                    m_Data.Add(new DispCode("240535", "三重北医療センター菰野厚生病院", "三重県"));
                    m_Data.Add(new DispCode("240549", "亀田クリニック", "三重県"));
                    m_Data.Add(new DispCode("240558", "鈴鹿回生病院", "三重県"));
                    m_Data.Add(new DispCode("240568", "伊勢田中病院", "三重県"));
                    m_Data.Add(new DispCode("240579", "玉田クリニック", "三重県"));
                    m_Data.Add(new DispCode("240589", "南伊勢透析クリニック", "三重県"));
                    m_Data.Add(new DispCode("240599", "延久のみちクリニック", "三重県"));
                    m_Data.Add(new DispCode("240619", "しま相和透析クリニック", "三重県"));
                    m_Data.Add(new DispCode("240623", "国民健康保険 志摩市民病院", "三重県"));
                    m_Data.Add(new DispCode("240638", "永井病院", "三重県"));
                    m_Data.Add(new DispCode("240649", "津腎クリニック", "三重県"));
                    m_Data.Add(new DispCode("240659", "花の丘病院 透析センター", "三重県"));
                    m_Data.Add(new DispCode("240669", "正和クリニック", "三重県"));
                    m_Data.Add(new DispCode("240679", "亀山透析クリニック", "三重県"));
                    m_Data.Add(new DispCode("240688", "伊勢ひかり病院", "三重県"));
                    m_Data.Add(new DispCode("240699", "村瀬病院附属クリニック", "三重県"));
                    m_Data.Add(new DispCode("247048", "若葉病院", "三重県"));
                    m_Data.Add(new DispCode("247079", "はくさんクリニック", "三重県"));
                    m_Data.Add(new DispCode("247099", "伊勢志摩腎クリニック志摩分院", "三重県"));
                    m_Data.Add(new DispCode("250016", "大津赤十字病院", "滋賀県"));
                    m_Data.Add(new DispCode("250024", "JCHO滋賀病院", "滋賀県"));
                    m_Data.Add(new DispCode("250039", "瀬田クリニック", "滋賀県"));
                    m_Data.Add(new DispCode("250046", "長浜赤十字病院", "滋賀県"));
                    m_Data.Add(new DispCode("250053", "市立長浜病院", "滋賀県"));
                    m_Data.Add(new DispCode("250063", "近江八幡市立総合医療センター", "滋賀県"));
                    m_Data.Add(new DispCode("250073", "済生会守山市民病院", "滋賀県"));
                    m_Data.Add(new DispCode("250083", "公立甲賀病院", "滋賀県"));
                    m_Data.Add(new DispCode("250098", "琵琶湖養育院病院", "滋賀県"));
                    m_Data.Add(new DispCode("250103", "高島市民病院", "滋賀県"));
                    m_Data.Add(new DispCode("250110", "滋賀医科大学医学部附属病院", "滋賀県"));
                    m_Data.Add(new DispCode("250129", "下坂クリニック", "滋賀県"));
                    m_Data.Add(new DispCode("250139", "（医）池田クリニック彦根", "滋賀県"));
                    m_Data.Add(new DispCode("250159", "荒川クリニック", "滋賀県"));
                    m_Data.Add(new DispCode("250163", "彦根市立病院", "滋賀県"));
                    m_Data.Add(new DispCode("250178", "東近江敬愛病院", "滋賀県"));
                    m_Data.Add(new DispCode("250195", "長浜市立湖北病院", "滋賀県"));
                    m_Data.Add(new DispCode("250208", "琵琶湖大橋病院", "滋賀県"));
                    m_Data.Add(new DispCode("250217", "淡海ふれあい病院", "滋賀県"));
                    m_Data.Add(new DispCode("250229", "富田クリニック", "滋賀県"));
                    m_Data.Add(new DispCode("250238", "日野記念病院", "滋賀県"));
                    m_Data.Add(new DispCode("250258", "神崎中央病院", "滋賀県"));
                    m_Data.Add(new DispCode("250268", "友仁山崎病院", "滋賀県"));
                    m_Data.Add(new DispCode("250273", "市立大津市民病院", "滋賀県"));
                    m_Data.Add(new DispCode("250308", "今津病院", "滋賀県"));
                    m_Data.Add(new DispCode("250349", "小川診療所", "滋賀県"));
                    m_Data.Add(new DispCode("250358", "豊郷病院", "滋賀県"));
                    m_Data.Add(new DispCode("250369", "山崎クリニック", "滋賀県"));
                    m_Data.Add(new DispCode("250378", "生田病院", "滋賀県"));
                    m_Data.Add(new DispCode("250386", "済生会滋賀県病院", "滋賀県"));
                    m_Data.Add(new DispCode("250399", "わたなべ湖西クリニック", "滋賀県"));
                    m_Data.Add(new DispCode("250409", "若林クリニック", "滋賀県"));
                    m_Data.Add(new DispCode("250418", "甲南病院", "滋賀県"));
                    m_Data.Add(new DispCode("250428", "近江草津徳洲会病院", "滋賀県"));
                    m_Data.Add(new DispCode("250439", "第二富田クリニック", "滋賀県"));
                    m_Data.Add(new DispCode("250449", "ハートクリニックこころ", "滋賀県"));
                    m_Data.Add(new DispCode("250469", "おおはし腎透析クリニック", "滋賀県"));
                    m_Data.Add(new DispCode("250479", "正志会ちとせ長命診療所", "滋賀県"));
                    m_Data.Add(new DispCode("250489", "布引内科クリニック", "滋賀県"));
                    m_Data.Add(new DispCode("250493", "滋賀県立総合病院", "滋賀県"));
                    m_Data.Add(new DispCode("250503", "市立野洲病院", "滋賀県"));
                    m_Data.Add(new DispCode("250519", "いしはらファミリークリニック", "滋賀県"));
                    m_Data.Add(new DispCode("260010", "京都大学医学部附属病院", "京都府"));
                    m_Data.Add(new DispCode("260050", "京都府立医科大学附属病院", "京都府"));
                    m_Data.Add(new DispCode("260078", "洛和会東寺南病院", "京都府"));
                    m_Data.Add(new DispCode("260096", "京都第一赤十字病院", "京都府"));
                    m_Data.Add(new DispCode("260127", "京都南病院", "京都府"));
                    m_Data.Add(new DispCode("260138", "京都武田病院", "京都府"));
                    m_Data.Add(new DispCode("260158", "武田病院", "京都府"));
                    m_Data.Add(new DispCode("260167", "武田総合病院", "京都府"));
                    m_Data.Add(new DispCode("260178", "西陣病院", "京都府"));
                    m_Data.Add(new DispCode("260208", "相馬病院", "京都府"));
                    m_Data.Add(new DispCode("260218", "宇治川病院", "京都府"));
                    m_Data.Add(new DispCode("260228", "京都民医連中央病院", "京都府"));
                    m_Data.Add(new DispCode("260238", "洛陽病院", "京都府"));
                    m_Data.Add(new DispCode("260248", "京都民医連あすかい病院", "京都府"));
                    m_Data.Add(new DispCode("260267", "京都岡本記念病院", "京都府"));
                    m_Data.Add(new DispCode("260278", "桃仁会病院", "京都府"));
                    m_Data.Add(new DispCode("260288", "西京都病院", "京都府"));
                    m_Data.Add(new DispCode("260298", "三菱京都病院", "京都府"));
                    m_Data.Add(new DispCode("260326", "舞鶴共済病院", "京都府"));
                    m_Data.Add(new DispCode("260338", "洛和会音羽病院", "京都府"));
                    m_Data.Add(new DispCode("260343", "京都中部総合医療センター", "京都府"));
                    m_Data.Add(new DispCode("260360", "京都府立医科大学附属北部医療センター", "京都府"));
                    m_Data.Add(new DispCode("260429", "伊東泌尿器科医院", "京都府"));
                    m_Data.Add(new DispCode("260438", "宇治徳洲会病院", "京都府"));
                    m_Data.Add(new DispCode("260448", "京都ルネス病院", "京都府"));
                    m_Data.Add(new DispCode("260457", "蘇生会総合病院", "京都府"));
                    m_Data.Add(new DispCode("260463", "京丹後市立弥栄病院", "京都府"));
                    m_Data.Add(new DispCode("260472", "京都医療センター", "京都府"));
                    m_Data.Add(new DispCode("260489", "青葉診療所", "京都府"));
                    m_Data.Add(new DispCode("260509", "池田クリニック", "京都府"));
                    m_Data.Add(new DispCode("260528", "賀茂病院", "京都府"));
                    m_Data.Add(new DispCode("260539", "岡村医院腎クリニック", "京都府"));
                    m_Data.Add(new DispCode("260549", "川端診療所", "京都府"));
                    m_Data.Add(new DispCode("260568", "八幡中央病院", "京都府"));
                    m_Data.Add(new DispCode("260578", "堀川病院", "京都府"));
                    m_Data.Add(new DispCode("260599", "岡所・泌尿器科医院", "京都府"));
                    m_Data.Add(new DispCode("260619", "くぜクリニック", "京都府"));
                    m_Data.Add(new DispCode("260633", "京都市立病院", "京都府"));
                    m_Data.Add(new DispCode("260649", "馬淵診療所", "京都府"));
                    m_Data.Add(new DispCode("260653", "市立福知山市民病院", "京都府"));
                    m_Data.Add(new DispCode("260669", "丸山医院", "京都府"));
                    m_Data.Add(new DispCode("260683", "京都山城総合医療センター", "京都府"));
                    m_Data.Add(new DispCode("260699", "樋口医院", "京都府"));
                    m_Data.Add(new DispCode("260709", "おかもとクリニック透析センターあすなろ", "京都府"));
                    m_Data.Add(new DispCode("260728", "綾部ルネス病院", "京都府"));
                    m_Data.Add(new DispCode("260739", "伊藤人工透析クリニック", "京都府"));
                    m_Data.Add(new DispCode("260743", "綾部市立病院", "京都府"));
                    m_Data.Add(new DispCode("260759", "髙須町塚診療所", "京都府"));
                    m_Data.Add(new DispCode("260769", "いとうクリニック", "京都府"));
                    m_Data.Add(new DispCode("260778", "亀岡シミズ病院", "京都府"));
                    m_Data.Add(new DispCode("260798", "京都九条病院", "京都府"));
                    m_Data.Add(new DispCode("260808", "京都田辺中央病院", "京都府"));
                    m_Data.Add(new DispCode("260818", "千春会病院", "京都府"));
                    m_Data.Add(new DispCode("260829", "北白川クリニック", "京都府"));
                    m_Data.Add(new DispCode("260839", "SD透析クリニック", "京都府"));
                    m_Data.Add(new DispCode("260849", "二条駅前クリニック", "京都府"));
                    m_Data.Add(new DispCode("260868", "宇治武田病院", "京都府"));
                    m_Data.Add(new DispCode("260879", "京都駅前武田透析クリニック", "京都府"));
                    m_Data.Add(new DispCode("260883", "精華町国民健康保険病院", "京都府"));
                    m_Data.Add(new DispCode("260897", "京都桂病院", "京都府"));
                    m_Data.Add(new DispCode("260908", "丹後中央病院", "京都府"));
                    m_Data.Add(new DispCode("260918", "洛和会音羽記念病院", "京都府"));
                    m_Data.Add(new DispCode("260929", "こう内科クリニック", "京都府"));
                    m_Data.Add(new DispCode("260949", "からすま透析クリニック", "京都府"));
                    m_Data.Add(new DispCode("260959", "川上内科", "京都府"));
                    m_Data.Add(new DispCode("260999", "にしがも透析クリニック", "京都府"));
                    m_Data.Add(new DispCode("261008", "男山病院", "京都府"));
                    m_Data.Add(new DispCode("261018", "亀岡病院", "京都府"));
                    m_Data.Add(new DispCode("261029", "ぬくい泌尿器科医院", "京都府"));
                    m_Data.Add(new DispCode("261038", "宮津武田病院", "京都府"));
                    m_Data.Add(new DispCode("261048", "十条武田リハビリテーション病院", "京都府"));
                    m_Data.Add(new DispCode("261058", "京都田辺記念病院", "京都府"));
                    m_Data.Add(new DispCode("261088", "みのやま病院", "京都府"));
                    m_Data.Add(new DispCode("261096", "京都第二赤十字病院", "京都府"));
                    m_Data.Add(new DispCode("261107", "伏見桃山総合病院", "京都府"));
                    m_Data.Add(new DispCode("261118", "泉谷病院", "京都府"));
                    m_Data.Add(new DispCode("261129", "岡村医院 腎・泌尿器科クリニック", "京都府"));
                    m_Data.Add(new DispCode("261139", "桃仁会病院付属診療所", "京都府"));
                    m_Data.Add(new DispCode("261147", "武田総合病院　西館透析室", "京都府"));
                    m_Data.Add(new DispCode("261159", "医)桃仁会かつら透析クリニック", "京都府"));
                    m_Data.Add(new DispCode("261166", "京都済生会病院", "京都府"));
                    m_Data.Add(new DispCode("261179", "舞鶴正峰会クリニック", "京都府"));
                    m_Data.Add(new DispCode("261189", "ふくい腎・泌尿器科クリニック", "京都府"));
                    m_Data.Add(new DispCode("270010", "大阪公立大学医学部附属病院", "大阪府"));
                    m_Data.Add(new DispCode("270020", "大阪公立大学大学院", "大阪府"));
                    m_Data.Add(new DispCode("270030", "大阪大学医学部附属病院", "大阪府"));
                    m_Data.Add(new DispCode("270072", "大阪医療センター", "大阪府"));
                    m_Data.Add(new DispCode("270095", "大阪みなと中央病院", "大阪府"));
                    m_Data.Add(new DispCode("270104", "JCHO大阪病院", "大阪府"));
                    m_Data.Add(new DispCode("270113", "大阪急性期・総合医療センター", "大阪府"));
                    m_Data.Add(new DispCode("270168", "住友病院", "大阪府"));
                    m_Data.Add(new DispCode("270176", "大阪赤十字病院腎臓内科", "大阪府"));
                    m_Data.Add(new DispCode("270188", "新大阪病院", "大阪府"));
                    m_Data.Add(new DispCode("270198", "淀井病院", "大阪府"));
                    m_Data.Add(new DispCode("270208", "白鷺病院", "大阪府"));
                    m_Data.Add(new DispCode("270226", "日本生命病院", "大阪府"));
                    m_Data.Add(new DispCode("270238", "大野記念病院", "大阪府"));
                    m_Data.Add(new DispCode("270246", "関西電力病院", "大阪府"));
                    m_Data.Add(new DispCode("270258", "大阪労働衛生センター第一病院", "大阪府"));
                    m_Data.Add(new DispCode("270278", "東大阪病院", "大阪府"));
                    m_Data.Add(new DispCode("270288", "阪和記念病院", "大阪府"));
                    m_Data.Add(new DispCode("270308", "井上病院", "大阪府"));
                    m_Data.Add(new DispCode("270326", "茨木病院", "大阪府"));
                    m_Data.Add(new DispCode("270338", "藍野病院", "大阪府"));
                    m_Data.Add(new DispCode("270343", "堺市立総合医療センター", "大阪府"));
                    m_Data.Add(new DispCode("270357", "耳原総合病院", "大阪府"));
                    m_Data.Add(new DispCode("270379", "清恵会向陵クリニック", "大阪府"));
                    m_Data.Add(new DispCode("270389", "時実クリニック", "大阪府"));
                    m_Data.Add(new DispCode("270399", "笠原クリニック", "大阪府"));
                    m_Data.Add(new DispCode("270401", "大阪医科薬科大学病院", "大阪府"));
                    m_Data.Add(new DispCode("270421", "関西医科大学総合医療センター", "大阪府"));
                    m_Data.Add(new DispCode("270444", "松下記念病院", "大阪府"));
                    m_Data.Add(new DispCode("270459", "小野山診療所", "大阪府"));
                    m_Data.Add(new DispCode("270464", "星ヶ丘医療センター", "大阪府"));
                    m_Data.Add(new DispCode("270479", "染矢クリニック", "大阪府"));
                    m_Data.Add(new DispCode("270489", "小尾クリニック", "大阪府"));
                    m_Data.Add(new DispCode("270497", "天の川病院", "大阪府"));
                    m_Data.Add(new DispCode("270501", "関西医科大学香里病院", "大阪府"));
                    m_Data.Add(new DispCode("270528", "岸和田徳洲会病院", "大阪府"));
                    m_Data.Add(new DispCode("270538", "府中病院", "大阪府"));
                    m_Data.Add(new DispCode("270549", "𠮷原クリニック", "大阪府"));
                    m_Data.Add(new DispCode("270559", "門真クリニックあいわ診療所", "大阪府"));
                    m_Data.Add(new DispCode("270598", "永山病院", "大阪府"));
                    m_Data.Add(new DispCode("270601", "近畿大学病院", "大阪府"));
                    m_Data.Add(new DispCode("270612", "国立循環器病研究センター", "大阪府"));
                    m_Data.Add(new DispCode("270629", "大阪梅田医誠会透析クリニック", "大阪府"));
                    m_Data.Add(new DispCode("270648", "ＰＬ病院", "大阪府"));
                    m_Data.Add(new DispCode("270658", "大阪回生病院", "大阪府"));
                    m_Data.Add(new DispCode("270669", "髙橋クリニック", "大阪府"));
                    m_Data.Add(new DispCode("270688", "高槻病院", "大阪府"));
                    m_Data.Add(new DispCode("270708", "堺近森病院", "大阪府"));
                    m_Data.Add(new DispCode("270722", "大阪南医療センター", "大阪府"));
                    m_Data.Add(new DispCode("270739", "岸田クリニック", "大阪府"));
                    m_Data.Add(new DispCode("270748", "明生記念病院", "大阪府"));
                    m_Data.Add(new DispCode("270759", "三上クリニック", "大阪府"));
                    m_Data.Add(new DispCode("270768", "明治橋病院", "大阪府"));
                    m_Data.Add(new DispCode("270789", "関西メディカル服部駅前クリニック", "大阪府"));
                    m_Data.Add(new DispCode("270809", "河村クリニック", "大阪府"));
                    m_Data.Add(new DispCode("270818", "八尾徳洲会総合病院", "大阪府"));
                    m_Data.Add(new DispCode("270839", "堺京町・ヒロ・クリニック", "大阪府"));
                    m_Data.Add(new DispCode("270849", "三軒医院", "大阪府"));
                    m_Data.Add(new DispCode("270856", "吹田病院", "大阪府"));
                    m_Data.Add(new DispCode("270868", "玉井病院", "大阪府"));
                    m_Data.Add(new DispCode("270879", "大道クリニック", "大阪府"));
                    m_Data.Add(new DispCode("270888", "藤井病院", "大阪府"));
                    m_Data.Add(new DispCode("270899", "中村クリニック", "大阪府"));
                    m_Data.Add(new DispCode("270918", "野崎徳洲会病院", "大阪府"));
                    m_Data.Add(new DispCode("270928", "共立病院", "大阪府"));
                    m_Data.Add(new DispCode("270938", "医学研究所北野病院　血液浄化センター", "大阪府"));
                    m_Data.Add(new DispCode("270948", "石切生喜病院", "大阪府"));
                    m_Data.Add(new DispCode("270958", "淀川キリスト教病院", "大阪府"));
                    m_Data.Add(new DispCode("270968", "三康病院", "大阪府"));
                    m_Data.Add(new DispCode("270978", "田仲北野田病院", "大阪府"));
                    m_Data.Add(new DispCode("270986", "大阪府済生会中津病院", "大阪府"));
                    m_Data.Add(new DispCode("270998", "堺平成病院", "大阪府"));
                    m_Data.Add(new DispCode("271009", "西岡医院", "大阪府"));
                    m_Data.Add(new DispCode("271017", "医誠会国際総合病院", "大阪府"));
                    m_Data.Add(new DispCode("271028", "相原第二病院", "大阪府"));
                    m_Data.Add(new DispCode("271049", "池田クリニック大阪", "大阪府"));
                    m_Data.Add(new DispCode("271057", "河内総合病院", "大阪府"));
                    m_Data.Add(new DispCode("271089", "寿楽会クリニック", "大阪府"));
                    m_Data.Add(new DispCode("271099", "うめだ天満透析クリニック", "大阪府"));
                    m_Data.Add(new DispCode("271107", "東香里病院", "大阪府"));
                    m_Data.Add(new DispCode("271126", "富田林病院", "大阪府"));
                    m_Data.Add(new DispCode("271139", "円尾クリニック", "大阪府"));
                    m_Data.Add(new DispCode("271149", "トキワクリニック", "大阪府"));
                    m_Data.Add(new DispCode("271159", "大道クリニック", "大阪府"));
                    m_Data.Add(new DispCode("271178", "香里ヶ丘有恵会病院", "大阪府"));
                    m_Data.Add(new DispCode("271189", "三上クリニック第一分院", "大阪府"));
                    m_Data.Add(new DispCode("271207", "加納総合病院", "大阪府"));
                    m_Data.Add(new DispCode("271229", "梶本クリニック", "大阪府"));
                    m_Data.Add(new DispCode("271238", "神原病院", "大阪府"));
                    m_Data.Add(new DispCode("271259", "北大阪クリニック", "大阪府"));
                    m_Data.Add(new DispCode("271269", "水谷クリニック", "大阪府"));
                    m_Data.Add(new DispCode("271278", "羽原病院", "大阪府"));
                    m_Data.Add(new DispCode("271288", "若草第一病院", "大阪府"));
                    m_Data.Add(new DispCode("271297", "医真会八尾総合病院", "大阪府"));
                    m_Data.Add(new DispCode("271306", "大阪労災病院", "大阪府"));
                    m_Data.Add(new DispCode("271319", "昭和町小尾クリニック", "大阪府"));
                    m_Data.Add(new DispCode("271329", "三康クリニック", "大阪府"));
                    m_Data.Add(new DispCode("271348", "千船病院", "大阪府"));
                    m_Data.Add(new DispCode("271359", "赤垣クリニック", "大阪府"));
                    m_Data.Add(new DispCode("271378", "大阪けいさつ病院", "大阪府"));
                    m_Data.Add(new DispCode("271398", "摂津医誠会病院", "大阪府"));
                    m_Data.Add(new DispCode("271409", "柏友クリニック", "大阪府"));
                    m_Data.Add(new DispCode("271419", "佐々木クリニック", "大阪府"));
                    m_Data.Add(new DispCode("271428", "馬場記念病院", "大阪府"));
                    m_Data.Add(new DispCode("271439", "北川クリニック", "大阪府"));
                    m_Data.Add(new DispCode("271449", "裕生会クリニック", "大阪府"));
                    m_Data.Add(new DispCode("271453", "市立吹田市民病院", "大阪府"));
                    m_Data.Add(new DispCode("271469", "富田林ときのクリニック", "大阪府"));
                    m_Data.Add(new DispCode("271487", "友紘会総合病院", "大阪府"));
                    m_Data.Add(new DispCode("271499", "山口クリニック", "大阪府"));
                    m_Data.Add(new DispCode("271518", "光生病院", "大阪府"));
                    m_Data.Add(new DispCode("271538", "佐藤病院", "大阪府"));
                    m_Data.Add(new DispCode("271549", "西本クリニック", "大阪府"));
                    m_Data.Add(new DispCode("271559", "梶本クリニック分院", "大阪府"));
                    m_Data.Add(new DispCode("271569", "西診療所", "大阪府"));
                    m_Data.Add(new DispCode("271598", "ながはら病院", "大阪府"));
                    m_Data.Add(new DispCode("271606", "大阪府済生会泉尾病院", "大阪府"));
                    m_Data.Add(new DispCode("271619", "東大阪病院附属クリニック", "大阪府"));
                    m_Data.Add(new DispCode("271639", "新大阪医誠会透析クリニック", "大阪府"));
                    m_Data.Add(new DispCode("271649", "相原アベノ診療所", "大阪府"));
                    m_Data.Add(new DispCode("271668", "浅香山病院", "大阪府"));
                    m_Data.Add(new DispCode("271679", "清水クリニック", "大阪府"));
                    m_Data.Add(new DispCode("271689", "ソレイユ腎・透析クリニック", "大阪府"));
                    m_Data.Add(new DispCode("271693", "大阪市立総合医療センター", "大阪府"));
                    m_Data.Add(new DispCode("271709", "榊原クリニック", "大阪府"));
                    m_Data.Add(new DispCode("271729", "中西クリニック", "大阪府"));
                    m_Data.Add(new DispCode("271739", "咲花クリニック 咲花透析センター", "大阪府"));
                    m_Data.Add(new DispCode("271748", "枚岡病院", "大阪府"));
                    m_Data.Add(new DispCode("271759", "仁和寺診療所", "大阪府"));
                    m_Data.Add(new DispCode("271768", "大阪暁明館病院", "大阪府"));
                    m_Data.Add(new DispCode("271773", "市立東大阪医療センター", "大阪府"));
                    m_Data.Add(new DispCode("271789", "田仲はびきのクリニック", "大阪府"));
                    m_Data.Add(new DispCode("271798", "守口敬仁会病院", "大阪府"));
                    m_Data.Add(new DispCode("271833", "りんくう総合医療センター", "大阪府"));
                    m_Data.Add(new DispCode("271848", "泉南藤井病院", "大阪府"));
                    m_Data.Add(new DispCode("271859", "羽曳野ときのクリニック", "大阪府"));
                    m_Data.Add(new DispCode("271869", "梅田東血液浄化クリニック", "大阪府"));
                    m_Data.Add(new DispCode("271878", "日新会病院", "大阪府"));
                    m_Data.Add(new DispCode("271889", "清水クリニック", "大阪府"));
                    m_Data.Add(new DispCode("271899", "佐藤クリニックまきの", "大阪府"));
                    m_Data.Add(new DispCode("271907", "北摂総合病院", "大阪府"));
                    m_Data.Add(new DispCode("271919", "永山クリニック", "大阪府"));
                    m_Data.Add(new DispCode("271949", "小阪イナバ診療所", "大阪府"));
                    m_Data.Add(new DispCode("271969", "岡田クリニック", "大阪府"));
                    m_Data.Add(new DispCode("271983", "市立池田病院", "大阪府"));
                    m_Data.Add(new DispCode("271999", "今井クリニック", "大阪府"));
                    m_Data.Add(new DispCode("272008", "茨木医誠会病院", "大阪府"));
                    m_Data.Add(new DispCode("272018", "西淀病院", "大阪府"));
                    m_Data.Add(new DispCode("272027", "ベルランド総合病院", "大阪府"));
                    m_Data.Add(new DispCode("272031", "大阪医科薬科大学三島南病院", "大阪府"));
                    m_Data.Add(new DispCode("272048", "松原徳洲会病院", "大阪府"));
                    m_Data.Add(new DispCode("272059", "北巽白鷺クリニック", "大阪府"));
                    m_Data.Add(new DispCode("272069", "白鷺診療所", "大阪府"));
                    m_Data.Add(new DispCode("272079", "田中泌尿器科医院人工透析センターひらかた", "大阪府"));
                    m_Data.Add(new DispCode("272083", "市立豊中病院", "大阪府"));
                    m_Data.Add(new DispCode("272099", "泉北クリニック", "大阪府"));
                    m_Data.Add(new DispCode("272119", "住道クリニック", "大阪府"));
                    m_Data.Add(new DispCode("272139", "寺川クリニック", "大阪府"));
                    m_Data.Add(new DispCode("272149", "門真けいじん会クリニック", "大阪府"));
                    m_Data.Add(new DispCode("272159", "はやし泌尿器クリニック", "大阪府"));
                    m_Data.Add(new DispCode("272169", "中川クリニック", "大阪府"));
                    m_Data.Add(new DispCode("272199", "医誠会病院付属透析クリニック", "大阪府"));
                    m_Data.Add(new DispCode("272209", "三康診療所", "大阪府"));
                    m_Data.Add(new DispCode("272219", "たくしん会腎透析クリニック", "大阪府"));
                    m_Data.Add(new DispCode("272229", "田中泌尿器科医院古江台診療所", "大阪府"));
                    m_Data.Add(new DispCode("272238", "関西メディカル病院", "大阪府"));
                    m_Data.Add(new DispCode("272249", "佐藤クリニックくずは", "大阪府"));
                    m_Data.Add(new DispCode("272269", "北花田クリニック", "大阪府"));
                    m_Data.Add(new DispCode("272278", "第一東和会病院", "大阪府"));
                    m_Data.Add(new DispCode("272298", "摂南総合病院", "大阪府"));
                    m_Data.Add(new DispCode("272308", "泉北藤井病院", "大阪府"));
                    m_Data.Add(new DispCode("272319", "十三医誠会透析クリニック", "大阪府"));
                    m_Data.Add(new DispCode("272338", "樫本病院", "大阪府"));
                    m_Data.Add(new DispCode("272349", "小野内科医院", "大阪府"));
                    m_Data.Add(new DispCode("272369", "谷口クリニック", "大阪府"));
                    m_Data.Add(new DispCode("272379", "いぶきクリニック", "大阪府"));
                    m_Data.Add(new DispCode("272399", "日野クリニック", "大阪府"));
                    m_Data.Add(new DispCode("272409", "貝塚西出クリニック", "大阪府"));
                    m_Data.Add(new DispCode("272416", "高槻赤十字病院", "大阪府"));
                    m_Data.Add(new DispCode("272429", "井上クリニック", "大阪府"));
                    m_Data.Add(new DispCode("272439", "若江岩田クリニック", "大阪府"));
                    m_Data.Add(new DispCode("272449", "なかじま内科クリニック", "大阪府"));
                    m_Data.Add(new DispCode("272469", "かねはらクリニック", "大阪府"));
                    m_Data.Add(new DispCode("272478", "東大阪山路病院", "大阪府"));
                    m_Data.Add(new DispCode("272488", "高石藤井病院", "大阪府"));
                    m_Data.Add(new DispCode("272499", "あづまクリニック", "大阪府"));
                    m_Data.Add(new DispCode("272509", "高原クリニック", "大阪府"));
                    m_Data.Add(new DispCode("272529", "正志会摂津腎透析クリニック", "大阪府"));
                    m_Data.Add(new DispCode("272549", "柿原クリニック", "大阪府"));
                    m_Data.Add(new DispCode("272559", "佐々木内科クリニック", "大阪府"));
                    m_Data.Add(new DispCode("272569", "かいこうクリニック", "大阪府"));
                    m_Data.Add(new DispCode("272579", "大嶋クリニック", "大阪府"));
                    m_Data.Add(new DispCode("272589", "津久野藤井クリニック", "大阪府"));
                    m_Data.Add(new DispCode("272598", "巽病院", "大阪府"));
                    m_Data.Add(new DispCode("272609", "えのもとクリニック", "大阪府"));
                    m_Data.Add(new DispCode("272629", "ゆうクリニック", "大阪府"));
                    m_Data.Add(new DispCode("272639", "大山クリニック", "大阪府"));
                    m_Data.Add(new DispCode("272646", "大手前病院", "大阪府"));
                    m_Data.Add(new DispCode("272659", "藤井寺敬任会クリニック", "大阪府"));
                    m_Data.Add(new DispCode("272669", "大森クリニック", "大阪府"));
                    m_Data.Add(new DispCode("272709", "暁明館透析クリニック", "大阪府"));
                    m_Data.Add(new DispCode("272718", "畷生会脳神経外科病院", "大阪府"));
                    m_Data.Add(new DispCode("272729", "大星クリニック", "大阪府"));
                    m_Data.Add(new DispCode("272733", "八尾市立病院", "大阪府"));
                    m_Data.Add(new DispCode("272749", "城東医誠会透析クリニック", "大阪府"));
                    m_Data.Add(new DispCode("272769", "にしたに腎・泌尿器クリニック", "大阪府"));
                    m_Data.Add(new DispCode("272779", "深江クリニック", "大阪府"));
                    m_Data.Add(new DispCode("272789", "関目山口クリニック", "大阪府"));
                    m_Data.Add(new DispCode("272799", "マリエ医院", "大阪府"));
                    m_Data.Add(new DispCode("272808", "吉田病院", "大阪府"));
                    m_Data.Add(new DispCode("272821", "関西医科大学附属病院", "大阪府"));
                    m_Data.Add(new DispCode("272838", "交野病院", "大阪府"));
                    m_Data.Add(new DispCode("272849", "かもとクリニック", "大阪府"));
                    m_Data.Add(new DispCode("272859", "藤井寺白鷺クリニック", "大阪府"));
                    m_Data.Add(new DispCode("272869", "白鷺南クリニック", "大阪府"));
                    m_Data.Add(new DispCode("272879", "柏友千代田クリニック", "大阪府"));
                    m_Data.Add(new DispCode("272889", "上牧かねはらクリニック", "大阪府"));
                    m_Data.Add(new DispCode("272899", "のがみ泉州リハビリテーションクリニック", "大阪府"));
                    m_Data.Add(new DispCode("272909", "守口けいじん会クリニック", "大阪府"));
                    m_Data.Add(new DispCode("272938", "協和病院", "大阪府"));
                    m_Data.Add(new DispCode("272949", "奥田クリニック", "大阪府"));
                    m_Data.Add(new DispCode("272959", "中川クリニック第二診療所", "大阪府"));
                    m_Data.Add(new DispCode("272968", "生野愛和病院", "大阪府"));
                    m_Data.Add(new DispCode("272973", "市立岸和田市民病院", "大阪府"));
                    m_Data.Add(new DispCode("272988", "清恵会三宝病院", "大阪府"));
                    m_Data.Add(new DispCode("272999", "しばさきクリニック", "大阪府"));
                    m_Data.Add(new DispCode("273008", "清恵会病院", "大阪府"));
                    m_Data.Add(new DispCode("273018", "福島病院", "大阪府"));
                    m_Data.Add(new DispCode("273039", "共立外科内科", "大阪府"));
                    m_Data.Add(new DispCode("273048", "城山病院", "大阪府"));
                    m_Data.Add(new DispCode("273058", "豊中若葉会病院", "大阪府"));
                    m_Data.Add(new DispCode("273068", "東大阪徳洲会病院", "大阪府"));
                    m_Data.Add(new DispCode("273079", "泉南新家クリニック", "大阪府"));
                    m_Data.Add(new DispCode("273088", "池田病院", "大阪府"));
                    m_Data.Add(new DispCode("273099", "南谷クリニック", "大阪府"));
                    m_Data.Add(new DispCode("273109", "いぶきクリニック分院", "大阪府"));
                    m_Data.Add(new DispCode("273118", "豊中敬仁会病院", "大阪府"));
                    m_Data.Add(new DispCode("273128", "南大阪病院", "大阪府"));
                    m_Data.Add(new DispCode("273138", "泉北陣内病院", "大阪府"));
                    m_Data.Add(new DispCode("273148", "巽今宮病院", "大阪府"));
                    m_Data.Add(new DispCode("273159", "正志会あづま腎透析クリニック", "大阪府"));
                    m_Data.Add(new DispCode("273163", "大阪はびきの医療センター", "大阪府"));
                    m_Data.Add(new DispCode("273179", "秋桜会ファミリークリニック", "大阪府"));
                    m_Data.Add(new DispCode("273188", "南河内おか病院", "大阪府"));
                    m_Data.Add(new DispCode("273219", "寝屋川けいじん会クリニック", "大阪府"));
                    m_Data.Add(new DispCode("273227", "堺若葉会病院", "大阪府"));
                    m_Data.Add(new DispCode("273239", "枚方公園前クリニック", "大阪府"));
                    m_Data.Add(new DispCode("273249", "南大阪クリニック", "大阪府"));
                    m_Data.Add(new DispCode("273259", "三康病院附属診療所", "大阪府"));
                    m_Data.Add(new DispCode("273269", "はしづめ内科", "大阪府"));
                    m_Data.Add(new DispCode("273299", "清田クリニック", "大阪府"));
                    m_Data.Add(new DispCode("273308", "東朋八尾病院", "大阪府"));
                    m_Data.Add(new DispCode("273349", "くりもと循環器クリニック", "大阪府"));
                    m_Data.Add(new DispCode("273369", "明生会クリニック", "大阪府"));
                    m_Data.Add(new DispCode("273379", "髙橋計行クリニック", "大阪府"));
                    m_Data.Add(new DispCode("273399", "吉田クリニック", "大阪府"));
                    m_Data.Add(new DispCode("273409", "ハーバータウンクリニック（大野記念病院グループ）", "大阪府"));
                    m_Data.Add(new DispCode("273429", "さやまクリニック", "大阪府"));
                    m_Data.Add(new DispCode("273439", "透析クリニック大正橋", "大阪府"));
                    m_Data.Add(new DispCode("273449", "大正くすのきクリニック", "大阪府"));
                    m_Data.Add(new DispCode("273459", "腎・循環器もはらクリニック", "大阪府"));
                    m_Data.Add(new DispCode("273469", "森小路清水会クリニック", "大阪府"));
                    m_Data.Add(new DispCode("273479", "堺近森病院附属近森診療所", "大阪府"));
                    m_Data.Add(new DispCode("273488", "寝屋川生野病院", "大阪府"));
                    m_Data.Add(new DispCode("273499", "七ふくハートクリニック", "大阪府"));
                    m_Data.Add(new DispCode("273509", "白岩内科医院", "大阪府"));
                    m_Data.Add(new DispCode("273519", "ＮＴ鶴見クリニック", "大阪府"));
                    m_Data.Add(new DispCode("273529", "豊中けいじん会クリニック", "大阪府"));
                    m_Data.Add(new DispCode("273549", "藤井寺腎・透析クリニック", "大阪府"));
                    m_Data.Add(new DispCode("273579", "坂口クリニック", "大阪府"));
                    m_Data.Add(new DispCode("273589", "かとう鳳クリニック", "大阪府"));
                    m_Data.Add(new DispCode("273599", "たかはしクリニック", "大阪府"));
                    m_Data.Add(new DispCode("273609", "西原クリニック", "大阪府"));
                    m_Data.Add(new DispCode("273619", "桃ヶ池クリニック", "大阪府"));
                    m_Data.Add(new DispCode("273629", "第五なぎさクリニック", "大阪府"));
                    m_Data.Add(new DispCode("273638", "貴生病院", "大阪府"));
                    m_Data.Add(new DispCode("273648", "吹田徳洲会病院", "大阪府"));
                    m_Data.Add(new DispCode("273669", "東花園透析クリニック", "大阪府"));
                    m_Data.Add(new DispCode("273678", "なにわ生野病院", "大阪府"));
                    m_Data.Add(new DispCode("273688", "協和会病院", "大阪府"));
                    m_Data.Add(new DispCode("273696", "枚方公済病院", "大阪府"));
                    m_Data.Add(new DispCode("273729", "たかやまクリニック", "大阪府"));
                    m_Data.Add(new DispCode("273739", "さかいクリニック", "大阪府"));
                    m_Data.Add(new DispCode("273749", "いけだクリニック", "大阪府"));
                    m_Data.Add(new DispCode("273759", "じょうこうクリニック", "大阪府"));
                    m_Data.Add(new DispCode("273768", "明生第二病院", "大阪府"));
                    m_Data.Add(new DispCode("273779", "大川ＶＡ透析クリニック", "大阪府"));
                    m_Data.Add(new DispCode("273788", "仁泉会病院", "大阪府"));
                    m_Data.Add(new DispCode("273799", "堀江やまびこ診療所", "大阪府"));
                    m_Data.Add(new DispCode("273809", "第二なぎさクリニック", "大阪府"));
                    m_Data.Add(new DispCode("273819", "前田診療所", "大阪府"));
                    m_Data.Add(new DispCode("273829", "あいゆうクリニック", "大阪府"));
                    m_Data.Add(new DispCode("273839", "千船病院附属千船クリニック", "大阪府"));
                    m_Data.Add(new DispCode("273849", "生野愛和透析クリニック", "大阪府"));
                    m_Data.Add(new DispCode("273869", "久宝寺透析クリニック", "大阪府"));
                    m_Data.Add(new DispCode("273879", "医療法人紀陽会箕面良風クリニック", "大阪府"));
                    m_Data.Add(new DispCode("273889", "長居田仲クリニック", "大阪府"));
                    m_Data.Add(new DispCode("273898", "阪和いずみ病院", "大阪府"));
                    m_Data.Add(new DispCode("273918", "和泉市立総合医療センター", "大阪府"));
                    m_Data.Add(new DispCode("273929", "中川クリニック しんまち診療所", "大阪府"));
                    m_Data.Add(new DispCode("273959", "井上診療所", "大阪府"));
                    m_Data.Add(new DispCode("273969", "なかもずクリニック", "大阪府"));
                    m_Data.Add(new DispCode("273978", "蒼生病院", "大阪府"));
                    m_Data.Add(new DispCode("273989", "新森透析クリニック", "大阪府"));
                    m_Data.Add(new DispCode("273999", "そうかわ透析シャント腎クリニック", "大阪府"));
                    m_Data.Add(new DispCode("274019", "平野白鷺クリニック", "大阪府"));
                    m_Data.Add(new DispCode("274029", "平野けいじんクリニック", "大阪府"));
                    m_Data.Add(new DispCode("274039", "第２髙橋計行クリニック", "大阪府"));
                    m_Data.Add(new DispCode("274049", "岸辺くすのき透析クリニック", "大阪府"));
                    m_Data.Add(new DispCode("274058", "東朋病院", "大阪府"));
                    m_Data.Add(new DispCode("274069", "健都透析クリニック", "大阪府"));
                    m_Data.Add(new DispCode("274089", "えいかん透析クリニック", "大阪府"));
                    m_Data.Add(new DispCode("274099", "門真介護医療院", "大阪府"));
                    m_Data.Add(new DispCode("274108", "萱島生野病院", "大阪府"));
                    m_Data.Add(new DispCode("274119", "マサキ透析・内科クリニック", "大阪府"));
                    m_Data.Add(new DispCode("274129", "近森クリニック", "大阪府"));
                    m_Data.Add(new DispCode("274139", "梶本クリニック三国ヶ丘分院", "大阪府"));
                    m_Data.Add(new DispCode("274149", "ふくいクリニック", "大阪府"));
                    m_Data.Add(new DispCode("274158", "青樹会病院", "大阪府"));
                    m_Data.Add(new DispCode("274169", "岸和田博陽会クリニック", "大阪府"));
                    m_Data.Add(new DispCode("274179", "河内山本透析クリニック", "大阪府"));
                    m_Data.Add(new DispCode("274189", "ふくながクリニック", "大阪府"));
                    m_Data.Add(new DispCode("274199", "HORIE R.Pクリニック", "大阪府"));
                    m_Data.Add(new DispCode("274209", "東寝屋川けいじん会クリニック", "大阪府"));
                    m_Data.Add(new DispCode("274218", "寺田萬寿病院", "大阪府"));
                    m_Data.Add(new DispCode("274223", "泉大津急性期メディカルセンター", "大阪府"));
                    m_Data.Add(new DispCode("274238", "もりぐち清水会病院", "大阪府"));
                    m_Data.Add(new DispCode("274249", "みかづき透析クリニック", "大阪府"));
                    m_Data.Add(new DispCode("277073", "大阪母子医療センター", "大阪府"));
                    m_Data.Add(new DispCode("277126", "西日本成人矯正医療センター", "大阪府"));
                    m_Data.Add(new DispCode("277508", "明生病院", "大阪府"));
                    m_Data.Add(new DispCode("280010", "神戸大学医学部附属病院", "兵庫県"));
                    m_Data.Add(new DispCode("280034", "神戸中央病院", "兵庫県"));
                    m_Data.Add(new DispCode("280043", "神戸市立医療センター西市民病院", "兵庫県"));
                    m_Data.Add(new DispCode("280058", "原泌尿器科病院", "兵庫県"));
                    m_Data.Add(new DispCode("280069", "元町ＨＤクリニック", "兵庫県"));
                    m_Data.Add(new DispCode("280079", "腎友会クリニック", "兵庫県"));
                    m_Data.Add(new DispCode("280088", "川崎病院", "兵庫県"));
                    m_Data.Add(new DispCode("280108", "新須磨病院", "兵庫県"));
                    m_Data.Add(new DispCode("280118", "佐野病院", "兵庫県"));
                    m_Data.Add(new DispCode("280128", "甲南医療センター", "兵庫県"));
                    m_Data.Add(new DispCode("280138", "姫路田中病院", "兵庫県"));
                    m_Data.Add(new DispCode("280188", "入江病院", "兵庫県"));
                    m_Data.Add(new DispCode("280198", "岡本病院", "兵庫県"));
                    m_Data.Add(new DispCode("280203", "兵庫県立尼崎総合医療センター", "兵庫県"));
                    m_Data.Add(new DispCode("280219", "尼崎永仁会クリニック", "兵庫県"));
                    m_Data.Add(new DispCode("280238", "住吉川病院", "兵庫県"));
                    m_Data.Add(new DispCode("280248", "明舞中央病院", "兵庫県"));
                    m_Data.Add(new DispCode("280251", "兵庫医科大学", "兵庫県"));
                    m_Data.Add(new DispCode("280268", "真星病院", "兵庫県"));
                    m_Data.Add(new DispCode("280279", "日和佐医院", "兵庫県"));
                    m_Data.Add(new DispCode("280296", "近畿中央病院", "兵庫県"));
                    m_Data.Add(new DispCode("280323", "市立西脇病院", "兵庫県"));
                    m_Data.Add(new DispCode("280333", "高砂市民病院", "兵庫県"));
                    m_Data.Add(new DispCode("280358", "姫路第一病院", "兵庫県"));
                    m_Data.Add(new DispCode("280363", "兵庫県立淡路医療センター", "兵庫県"));
                    m_Data.Add(new DispCode("280399", "大植クリニック", "兵庫県"));
                    m_Data.Add(new DispCode("280408", "宝塚病院", "兵庫県"));
                    m_Data.Add(new DispCode("280413", "公立豊岡病院組合立豊岡病院日高クリニック", "兵庫県"));
                    m_Data.Add(new DispCode("280438", "半田中央病院", "兵庫県"));
                    m_Data.Add(new DispCode("280459", "泉外科医院", "兵庫県"));
                    m_Data.Add(new DispCode("280469", "おおくま透析クリニック", "兵庫県"));
                    m_Data.Add(new DispCode("280478", "湊の杜病院", "兵庫県"));
                    m_Data.Add(new DispCode("280488", "服部病院", "兵庫県"));
                    m_Data.Add(new DispCode("280497", "姫路聖マリア病院", "兵庫県"));
                    m_Data.Add(new DispCode("280519", "永井医院", "兵庫県"));
                    m_Data.Add(new DispCode("280523", "公立八鹿病院", "兵庫県"));
                    m_Data.Add(new DispCode("280579", "赤塚クリニック", "兵庫県"));
                    m_Data.Add(new DispCode("280583", "川西市立総合医療センター", "兵庫県"));
                    m_Data.Add(new DispCode("280608", "酒井病院", "兵庫県"));
                    m_Data.Add(new DispCode("280625", "神戸協同病院", "兵庫県"));
                    m_Data.Add(new DispCode("280639", "星優クリニック", "兵庫県"));
                    m_Data.Add(new DispCode("280643", "赤穂市民病院", "兵庫県"));
                    m_Data.Add(new DispCode("280653", "兵庫県立西宮病院", "兵庫県"));
                    m_Data.Add(new DispCode("280686", "関西労災病院", "兵庫県"));
                    m_Data.Add(new DispCode("280699", "宮本クリニック", "兵庫県"));
                    m_Data.Add(new DispCode("280703", "市立伊丹病院", "兵庫県"));
                    m_Data.Add(new DispCode("280719", "岡本クリニック", "兵庫県"));
                    m_Data.Add(new DispCode("280738", "城陽江尻病院", "兵庫県"));
                    m_Data.Add(new DispCode("280768", "明和病院", "兵庫県"));
                    m_Data.Add(new DispCode("280778", "三菱神戸病院", "兵庫県"));
                    m_Data.Add(new DispCode("280789", "當銘医院", "兵庫県"));
                    m_Data.Add(new DispCode("280798", "赤穂中央病院", "兵庫県"));
                    m_Data.Add(new DispCode("280808", "中林病院", "兵庫県"));
                    m_Data.Add(new DispCode("280819", "三上クリニック第二分院", "兵庫県"));
                    m_Data.Add(new DispCode("280829", "まつもとクリニック", "兵庫県"));
                    m_Data.Add(new DispCode("280839", "芦田内科", "兵庫県"));
                    m_Data.Add(new DispCode("280849", "岩崎内科クリニック", "兵庫県"));
                    m_Data.Add(new DispCode("280859", "六島クリニック", "兵庫県"));
                    m_Data.Add(new DispCode("280868", "石井病院", "兵庫県"));
                    m_Data.Add(new DispCode("280879", "中野医院", "兵庫県"));
                    m_Data.Add(new DispCode("280899", "住吉川クリニック", "兵庫県"));
                    m_Data.Add(new DispCode("280909", "はまだ腎透析クリニック", "兵庫県"));
                    m_Data.Add(new DispCode("280913", "明石市立市民病院", "兵庫県"));
                    m_Data.Add(new DispCode("280939", "成山・池内クリニック", "兵庫県"));
                    m_Data.Add(new DispCode("280949", "仁成クリニック", "兵庫県"));
                    m_Data.Add(new DispCode("280959", "石田クリニック", "兵庫県"));
                    m_Data.Add(new DispCode("280979", "尼崎北永仁会クリニック", "兵庫県"));
                    m_Data.Add(new DispCode("280989", "かいべ循環器・透析クリニック", "兵庫県"));
                    m_Data.Add(new DispCode("280998", "北条田仲病院", "兵庫県"));
                    m_Data.Add(new DispCode("281003", "公立宍粟総合病院", "兵庫県"));
                    m_Data.Add(new DispCode("281018", "六甲アイランド甲南病院", "兵庫県"));
                    m_Data.Add(new DispCode("281029", "ひまわりクリニック", "兵庫県"));
                    m_Data.Add(new DispCode("281039", "ツクシクリニック", "兵庫県"));
                    m_Data.Add(new DispCode("281058", "あさひ病院", "兵庫県"));
                    m_Data.Add(new DispCode("281079", "高山クリニック", "兵庫県"));
                    m_Data.Add(new DispCode("281089", "内科　阪本医院", "兵庫県"));
                    m_Data.Add(new DispCode("281098", "とくなが病院", "兵庫県"));
                    m_Data.Add(new DispCode("281108", "大山記念病院", "兵庫県"));
                    m_Data.Add(new DispCode("281114", "ＩＨＩ播磨病院", "兵庫県"));
                    m_Data.Add(new DispCode("281133", "神戸市立西神戸医療センター", "兵庫県"));
                    m_Data.Add(new DispCode("281148", "神戸徳洲会病院", "兵庫県"));
                    m_Data.Add(new DispCode("281156", "済生会兵庫県病院", "兵庫県"));
                    m_Data.Add(new DispCode("281169", "さつきクリニック", "兵庫県"));
                    m_Data.Add(new DispCode("281179", "人工透析ひ尿器科じんけいクリニック", "兵庫県"));
                    m_Data.Add(new DispCode("281188", "ツカザキ病院", "兵庫県"));
                    m_Data.Add(new DispCode("281198", "三栄会広畑病院", "兵庫県"));
                    m_Data.Add(new DispCode("281209", "王子クリニック", "兵庫県"));
                    m_Data.Add(new DispCode("281213", "三田市民病院", "兵庫県"));
                    m_Data.Add(new DispCode("281229", "石川クリニック", "兵庫県"));
                    m_Data.Add(new DispCode("281239", "第二六島クリニック", "兵庫県"));
                    m_Data.Add(new DispCode("281253", "神戸市立医療センター中央市民病院", "兵庫県"));
                    m_Data.Add(new DispCode("281269", "荒川クリニック", "兵庫県"));
                    m_Data.Add(new DispCode("281279", "くきクリニック", "兵庫県"));
                    m_Data.Add(new DispCode("281299", "坂井瑠実クリニック", "兵庫県"));
                    m_Data.Add(new DispCode("281309", "さとうクリニック", "兵庫県"));
                    m_Data.Add(new DispCode("281319", "斉藤内科クリニック", "兵庫県"));
                    m_Data.Add(new DispCode("281329", "今井泌尿器科", "兵庫県"));
                    m_Data.Add(new DispCode("281333", "宝塚市立病院", "兵庫県"));
                    m_Data.Add(new DispCode("281359", "いまい内科クリニック", "兵庫県"));
                    m_Data.Add(new DispCode("281378", "神戸朝日病院", "兵庫県"));
                    m_Data.Add(new DispCode("281388", "神戸掖済会病院", "兵庫県"));
                    m_Data.Add(new DispCode("281419", "とくこだクリニック", "兵庫県"));
                    m_Data.Add(new DispCode("281423", "兵庫県立加古川医療センター", "兵庫県"));
                    m_Data.Add(new DispCode("281439", "さいか医院", "兵庫県"));
                    m_Data.Add(new DispCode("281449", "平明会クリニック", "兵庫県"));
                    m_Data.Add(new DispCode("281469", "田仲医院", "兵庫県"));
                    m_Data.Add(new DispCode("281478", "神明病院", "兵庫県"));
                    m_Data.Add(new DispCode("281488", "伊川谷病院", "兵庫県"));
                    m_Data.Add(new DispCode("281498", "中谷病院", "兵庫県"));
                    m_Data.Add(new DispCode("281508", "笹生病院", "兵庫県"));
                    m_Data.Add(new DispCode("281519", "いでクリニック", "兵庫県"));
                    m_Data.Add(new DispCode("281529", "ゆう透析クリニック", "兵庫県"));
                    m_Data.Add(new DispCode("281539", "ツカザキクリニック", "兵庫県"));
                    m_Data.Add(new DispCode("281548", "明石回生病院", "兵庫県"));
                    m_Data.Add(new DispCode("281559", "平岡内科", "兵庫県"));
                    m_Data.Add(new DispCode("281578", "第二協立病院", "兵庫県"));
                    m_Data.Add(new DispCode("281589", "三宮ＨＤクリニック", "兵庫県"));
                    m_Data.Add(new DispCode("281599", "いたみバラ診療所", "兵庫県"));
                    m_Data.Add(new DispCode("281604", "明石医療センター", "兵庫県"));
                    m_Data.Add(new DispCode("281628", "顕修会　すずらん病院", "兵庫県"));
                    m_Data.Add(new DispCode("281636", "多可赤十字病院", "兵庫県"));
                    m_Data.Add(new DispCode("281649", "野里門クリニック", "兵庫県"));
                    m_Data.Add(new DispCode("281659", "芦屋坂井瑠実クリニック", "兵庫県"));
                    m_Data.Add(new DispCode("281669", "山本クリニック", "兵庫県"));
                    m_Data.Add(new DispCode("281679", "塩屋王子クリニック", "兵庫県"));
                    m_Data.Add(new DispCode("281689", "三郎記念クリニック", "兵庫県"));
                    m_Data.Add(new DispCode("281699", "堀川クリニック", "兵庫県"));
                    m_Data.Add(new DispCode("281709", "田仲和田山クリニック", "兵庫県"));
                    m_Data.Add(new DispCode("281719", "社田仲クリニック", "兵庫県"));
                    m_Data.Add(new DispCode("281728", "洲本伊月病院", "兵庫県"));
                    m_Data.Add(new DispCode("281738", "あおい病院", "兵庫県"));
                    m_Data.Add(new DispCode("281749", "まつざきクリニック", "兵庫県"));
                    m_Data.Add(new DispCode("281759", "第二仁成クリニック", "兵庫県"));
                    m_Data.Add(new DispCode("281768", "広野高原病院", "兵庫県"));
                    m_Data.Add(new DispCode("281778", "大塚病院", "兵庫県"));
                    m_Data.Add(new DispCode("281789", "顕修会クリニック", "兵庫県"));
                    m_Data.Add(new DispCode("281848", "大久保病院", "兵庫県"));
                    m_Data.Add(new DispCode("281859", "はまだクリニック", "兵庫県"));
                    m_Data.Add(new DispCode("281868", "尼崎新都心病院", "兵庫県"));
                    m_Data.Add(new DispCode("281879", "しもかどクリニック", "兵庫県"));
                    m_Data.Add(new DispCode("281889", "城内六島クリニック", "兵庫県"));
                    m_Data.Add(new DispCode("281899", "まつしまクリニック", "兵庫県"));
                    m_Data.Add(new DispCode("281918", "神戸ほくと病院", "兵庫県"));
                    m_Data.Add(new DispCode("281929", "にしかげ内科クリニック", "兵庫県"));
                    m_Data.Add(new DispCode("281939", "光寿会クリニック", "兵庫県"));
                    m_Data.Add(new DispCode("281949", "第二椋本クリニック", "兵庫県"));
                    m_Data.Add(new DispCode("281959", "いけがみクリニック", "兵庫県"));
                    m_Data.Add(new DispCode("281968", "芦屋セントマリア病院", "兵庫県"));
                    m_Data.Add(new DispCode("281988", "西宮敬愛会病院", "兵庫県"));
                    m_Data.Add(new DispCode("281998", "たずみ病院", "兵庫県"));
                    m_Data.Add(new DispCode("282008", "ポートアイランド病院", "兵庫県"));
                    m_Data.Add(new DispCode("282019", "前田クリニック", "兵庫県"));
                    m_Data.Add(new DispCode("282029", "神明クリニック", "兵庫県"));
                    m_Data.Add(new DispCode("282039", "しもかど腎透析クリニック", "兵庫県"));
                    m_Data.Add(new DispCode("282059", "愛正透析クリニック", "兵庫県"));
                    m_Data.Add(new DispCode("282069", "きたうらクリニック", "兵庫県"));
                    m_Data.Add(new DispCode("282078", "尾原病院", "兵庫県"));
                    m_Data.Add(new DispCode("282088", "三木山陽病院", "兵庫県"));
                    m_Data.Add(new DispCode("282098", "高田上谷病院", "兵庫県"));
                    m_Data.Add(new DispCode("282109", "さくま透析クリニック", "兵庫県"));
                    m_Data.Add(new DispCode("282119", "コスモクリニック", "兵庫県"));
                    m_Data.Add(new DispCode("282136", "神戸労災病院", "兵庫県"));
                    m_Data.Add(new DispCode("282149", "樂樂クリニック", "兵庫県"));
                    m_Data.Add(new DispCode("282158", "栄宏会小野病院", "兵庫県"));
                    m_Data.Add(new DispCode("282168", "北播磨総合医療センター", "兵庫県"));
                    m_Data.Add(new DispCode("282173", "加古川中央市民病院", "兵庫県"));
                    m_Data.Add(new DispCode("282189", "伊丹ガーデンズクリニック", "兵庫県"));
                    m_Data.Add(new DispCode("282199", "日並内科外科医院", "兵庫県"));
                    m_Data.Add(new DispCode("282209", "新須磨透析クリニック", "兵庫県"));
                    m_Data.Add(new DispCode("282219", "せいゆうクリニック", "兵庫県"));
                    m_Data.Add(new DispCode("282229", "夙川宮本クリニック", "兵庫県"));
                    m_Data.Add(new DispCode("282238", "野瀬病院", "兵庫県"));
                    m_Data.Add(new DispCode("282248", "昭生病院", "兵庫県"));
                    m_Data.Add(new DispCode("282259", "野瀬まごころ診療所", "兵庫県"));
                    m_Data.Add(new DispCode("282269", "芦屋セントマリアクリニック", "兵庫県"));
                    m_Data.Add(new DispCode("282279", "ふるさと透析診療所", "兵庫県"));
                    m_Data.Add(new DispCode("282288", "明芳外科リハビリテーション病院", "兵庫県"));
                    m_Data.Add(new DispCode("282299", "中山寺いまいクリニック", "兵庫県"));
                    m_Data.Add(new DispCode("282308", "高砂西部病院", "兵庫県"));
                    m_Data.Add(new DispCode("282319", "キセラ川西腎クリニック", "兵庫県"));
                    m_Data.Add(new DispCode("282323", "兵庫県立はりま姫路総合医療センター", "兵庫県"));
                    m_Data.Add(new DispCode("282338", "春日病院", "兵庫県"));
                    m_Data.Add(new DispCode("282348", "神戸大山病院", "兵庫県"));
                    m_Data.Add(new DispCode("282359", "本多聞内科クリニック", "兵庫県"));
                    m_Data.Add(new DispCode("282369", "糖尿病・腎透析にしかげクリニック アネックス", "兵庫県"));
                    m_Data.Add(new DispCode("282378", "神戸百年記念病院", "兵庫県"));
                    m_Data.Add(new DispCode("282389", "クリニック日々青々", "兵庫県"));
                    m_Data.Add(new DispCode("282393", "豊岡病院", "兵庫県"));
                    m_Data.Add(new DispCode("282403", "兵庫県立丹波医療センター", "兵庫県"));
                    m_Data.Add(new DispCode("282419", "ここしあ診療所", "兵庫県"));
                    m_Data.Add(new DispCode("282428", "みどり病院", "兵庫県"));
                    m_Data.Add(new DispCode("282439", "飾西さかいクリニック", "兵庫県"));
                    m_Data.Add(new DispCode("282449", "よしだ内科診療所", "兵庫県"));
                    m_Data.Add(new DispCode("287038", "厚生病院", "兵庫県"));
                    m_Data.Add(new DispCode("287053", "公立香住総合病院", "兵庫県"));
                    m_Data.Add(new DispCode("287088", "井野病院", "兵庫県"));
                    m_Data.Add(new DispCode("287103", "公立神崎総合病院", "兵庫県"));
                    m_Data.Add(new DispCode("287138", "龍野中央病院", "兵庫県"));
                    m_Data.Add(new DispCode("287169", "江尻クリニック", "兵庫県"));
                    m_Data.Add(new DispCode("287278", "八家病院", "兵庫県"));
                    m_Data.Add(new DispCode("287289", "中野泌尿器科", "兵庫県"));
                    m_Data.Add(new DispCode("287439", "フェニックス岩岡クリニック", "兵庫県"));
                    m_Data.Add(new DispCode("287533", "兵庫県立こども病院", "兵庫県"));
                    m_Data.Add(new DispCode("287578", "平島病院", "兵庫県"));
                    m_Data.Add(new DispCode("287699", "さかいクリニック", "兵庫県"));
                    m_Data.Add(new DispCode("290018", "西奈良中央病院", "奈良県"));
                    m_Data.Add(new DispCode("290049", "天理メディカルクリニック", "奈良県"));
                    m_Data.Add(new DispCode("290050", "奈良県立医科大学附属病院 透析部", "奈良県"));
                    m_Data.Add(new DispCode("290066", "済生会中和病院", "奈良県"));
                    m_Data.Add(new DispCode("290078", "高の原中央病院", "奈良県"));
                    m_Data.Add(new DispCode("290083", "奈良県総合医療センター", "奈良県"));
                    m_Data.Add(new DispCode("290109", "翠悠会診療所", "奈良県"));
                    m_Data.Add(new DispCode("290119", "柏井クリニック", "奈良県"));
                    m_Data.Add(new DispCode("290123", "奈良県西和医療センター", "奈良県"));
                    m_Data.Add(new DispCode("290149", "高田診療所", "奈良県"));
                    m_Data.Add(new DispCode("290159", "田中泌尿器科医院　生駒診療所", "奈良県"));
                    m_Data.Add(new DispCode("290168", "西の京病院", "奈良県"));
                    m_Data.Add(new DispCode("290179", "王寺診療所", "奈良県"));
                    m_Data.Add(new DispCode("290188", "奈良友紘会病院", "奈良県"));
                    m_Data.Add(new DispCode("290203", "宇陀市立病院", "奈良県"));
                    m_Data.Add(new DispCode("290216", "奈良病院", "奈良県"));
                    m_Data.Add(new DispCode("290248", "高井病院", "奈良県"));
                    m_Data.Add(new DispCode("290259", "吉江医院", "奈良県"));
                    m_Data.Add(new DispCode("290279", "桜井透析クリニック", "奈良県"));
                    m_Data.Add(new DispCode("290289", "中辻医院", "奈良県"));
                    m_Data.Add(new DispCode("290298", "おかたに病院", "奈良県"));
                    m_Data.Add(new DispCode("290313", "国保中央病院", "奈良県"));
                    m_Data.Add(new DispCode("290328", "阪奈中央病院", "奈良県"));
                    m_Data.Add(new DispCode("290339", "星和台クリニック", "奈良県"));
                    m_Data.Add(new DispCode("290343", "南奈良総合医療センター", "奈良県"));
                    m_Data.Add(new DispCode("290359", "かつらぎクリニック", "奈良県"));
                    m_Data.Add(new DispCode("290376", "済生会御所病院", "奈良県"));
                    m_Data.Add(new DispCode("290383", "大和高田市立病院", "奈良県"));
                    m_Data.Add(new DispCode("290399", "田畑医院", "奈良県"));
                    m_Data.Add(new DispCode("290409", "藤原京クリニック", "奈良県"));
                    m_Data.Add(new DispCode("290419", "西の京病院 プラザ透析センター", "奈良県"));
                    m_Data.Add(new DispCode("290429", "医）近藤クリニック真美ヶ丘腎センター", "奈良県"));
                    m_Data.Add(new DispCode("290449", "旭ヶ丘クリニック", "奈良県"));
                    m_Data.Add(new DispCode("290458", "田北病院", "奈良県"));
                    m_Data.Add(new DispCode("290469", "香芝透析クリニック", "奈良県"));
                    m_Data.Add(new DispCode("290478", "南和病院", "奈良県"));
                    m_Data.Add(new DispCode("290489", "田中泌尿器科医院人工透析センターとみがおか", "奈良県"));
                    m_Data.Add(new DispCode("290499", "アベクリニック", "奈良県"));
                    m_Data.Add(new DispCode("290510", "奈良県立医科大学附属病院", "奈良県"));
                    m_Data.Add(new DispCode("290529", "西の京病院 西大寺クリニック", "奈良県"));
                    m_Data.Add(new DispCode("290539", "ＪＲ奈良 おうとくクリニック", "奈良県"));
                    m_Data.Add(new DispCode("290549", "しらかしクリニック", "奈良県"));
                    m_Data.Add(new DispCode("290558", "奈良東九条病院", "奈良県"));
                    m_Data.Add(new DispCode("290561", "近畿大学奈良病院", "奈良県"));
                    m_Data.Add(new DispCode("290573", "生駒市立病院", "奈良県"));
                    m_Data.Add(new DispCode("290588", "香芝生喜病院", "奈良県"));
                    m_Data.Add(new DispCode("290599", "菊美台クリニック", "奈良県"));
                    m_Data.Add(new DispCode("290608", "奈良東病院", "奈良県"));
                    m_Data.Add(new DispCode("290619", "壬生医院", "奈良県"));
                    m_Data.Add(new DispCode("290629", "奥村クリニック", "奈良県"));
                    m_Data.Add(new DispCode("290638", "大和橿原病院", "奈良県"));
                    m_Data.Add(new DispCode("290649", "清和会クリニック", "奈良県"));
                    m_Data.Add(new DispCode("290659", "たんしょう内科腎臓内科皮膚科クリニック", "奈良県"));
                    m_Data.Add(new DispCode("300010", "和歌山県立医科大学附属病院", "和歌山県"));
                    m_Data.Add(new DispCode("300028", "（医）裕紫会オリオン", "和歌山県"));
                    m_Data.Add(new DispCode("300038", "児玉病院", "和歌山県"));
                    m_Data.Add(new DispCode("300048", "恵友病院", "和歌山県"));
                    m_Data.Add(new DispCode("300058", "石本病院", "和歌山県"));
                    m_Data.Add(new DispCode("300068", "谷口病院", "和歌山県"));
                    m_Data.Add(new DispCode("300073", "ひだか病院", "和歌山県"));
                    m_Data.Add(new DispCode("300084", "紀南病院", "和歌山県"));
                    m_Data.Add(new DispCode("300098", "玉置病院", "和歌山県"));
                    m_Data.Add(new DispCode("300103", "新宮市立医療センター", "和歌山県"));
                    m_Data.Add(new DispCode("300119", "熊野路クリニック", "和歌山県"));
                    m_Data.Add(new DispCode("300123", "くしもと町立病院", "和歌山県"));
                    m_Data.Add(new DispCode("300136", "日本赤十字社和歌山医療センター", "和歌山県"));
                    m_Data.Add(new DispCode("300148", "和歌浦中央病院", "和歌山県"));
                    m_Data.Add(new DispCode("300156", "済生会和歌山病院", "和歌山県"));
                    m_Data.Add(new DispCode("300168", "高山病院", "和歌山県"));
                    m_Data.Add(new DispCode("300179", "宇治田循環器科内科", "和歌山県"));
                    m_Data.Add(new DispCode("300208", "西和歌山病院", "和歌山県"));
                    m_Data.Add(new DispCode("300228", "北出病院", "和歌山県"));
                    m_Data.Add(new DispCode("300239", "中紀クリニック", "和歌山県"));
                    m_Data.Add(new DispCode("300248", "向陽病院", "和歌山県"));
                    m_Data.Add(new DispCode("300259", "紀の川クリニック", "和歌山県"));
                    m_Data.Add(new DispCode("300265", "和歌山生協病院附属診療所", "和歌山県"));
                    m_Data.Add(new DispCode("300279", "紀北クリニック", "和歌山県"));
                    m_Data.Add(new DispCode("300288", "河西田村病院", "和歌山県"));
                    m_Data.Add(new DispCode("300298", "半羽胃腸病院", "和歌山県"));
                    m_Data.Add(new DispCode("300308", "嶋病院", "和歌山県"));
                    m_Data.Add(new DispCode("300318", "桜ヶ丘病院", "和歌山県"));
                    m_Data.Add(new DispCode("300328", "有田南病院", "和歌山県"));
                    m_Data.Add(new DispCode("300339", "柏井内科クリニック", "和歌山県"));
                    m_Data.Add(new DispCode("300348", "紀和病院", "和歌山県"));
                    m_Data.Add(new DispCode("300359", "南紀の台クリニック", "和歌山県"));
                    m_Data.Add(new DispCode("300369", "紀伊クリニック", "和歌山県"));
                    m_Data.Add(new DispCode("300378", "名手病院", "和歌山県"));
                    m_Data.Add(new DispCode("300383", "那智勝浦町立温泉病院", "和歌山県"));
                    m_Data.Add(new DispCode("300399", "きたクリニック", "和歌山県"));
                    m_Data.Add(new DispCode("300409", "けんゆうクリニック", "和歌山県"));
                    m_Data.Add(new DispCode("300418", "西岡病院", "和歌山県"));
                    m_Data.Add(new DispCode("300429", "上富田クリニック", "和歌山県"));
                    m_Data.Add(new DispCode("300449", "紀泉ＫＤクリニック", "和歌山県"));
                    m_Data.Add(new DispCode("300459", "ましょうクリニック", "和歌山県"));
                    m_Data.Add(new DispCode("300469", "まろクリニック", "和歌山県"));
                    m_Data.Add(new DispCode("300479", "土屋クリニック", "和歌山県"));
                    m_Data.Add(new DispCode("300483", "公立那賀病院", "和歌山県"));
                    m_Data.Add(new DispCode("300499", "たなべクリニック", "和歌山県"));
                    m_Data.Add(new DispCode("300509", "白水園", "和歌山県"));
                    m_Data.Add(new DispCode("307048", "串本有田病院", "和歌山県"));
                    m_Data.Add(new DispCode("307058", "誠佑記念病院", "和歌山県"));
                    m_Data.Add(new DispCode("310013", "鳥取県立中央病院", "鳥取県"));
                    m_Data.Add(new DispCode("310025", "鳥取生協病院", "鳥取県"));
                    m_Data.Add(new DispCode("310033", "鳥取市立病院", "鳥取県"));
                    m_Data.Add(new DispCode("310040", "鳥取大学医学部附属病院 腎センター", "鳥取県"));
                    m_Data.Add(new DispCode("310056", "山陰労災病院", "鳥取県"));
                    m_Data.Add(new DispCode("310062", "米子医療センター", "鳥取県"));
                    m_Data.Add(new DispCode("310083", "鳥取県立厚生病院", "鳥取県"));
                    m_Data.Add(new DispCode("310098", "谷口病院", "鳥取県"));
                    m_Data.Add(new DispCode("310109", "上福原内科クリニック", "鳥取県"));
                    m_Data.Add(new DispCode("310148", "博愛病院", "鳥取県"));
                    m_Data.Add(new DispCode("310159", "大山クリニック", "鳥取県"));
                    m_Data.Add(new DispCode("310168", "尾﨑病院", "鳥取県"));
                    m_Data.Add(new DispCode("310176", "境港総合病院", "鳥取県"));
                    m_Data.Add(new DispCode("310183", "国民健康保険智頭病院", "鳥取県"));
                    m_Data.Add(new DispCode("310193", "岩美病院", "鳥取県"));
                    m_Data.Add(new DispCode("310208", "野島病院", "鳥取県"));
                    m_Data.Add(new DispCode("310226", "鳥取赤十字病院", "鳥取県"));
                    m_Data.Add(new DispCode("310239", "吉野・三宅ステーションクリニック", "鳥取県"));
                    m_Data.Add(new DispCode("310259", "のぐち内科クリニック", "鳥取県"));
                    m_Data.Add(new DispCode("310269", "さとに田園クリニック", "鳥取県"));
                    m_Data.Add(new DispCode("310299", "新開山本クリニック", "鳥取県"));
                    m_Data.Add(new DispCode("310309", "谷口病院附属診療所　東伯サテライト", "鳥取県"));
                    m_Data.Add(new DispCode("310319", "真誠会セントラルクリニック透析施設オアシス", "鳥取県"));
                    m_Data.Add(new DispCode("310329", "米子西クリニック", "鳥取県"));
                    m_Data.Add(new DispCode("310339", "クリニック陽まり", "鳥取県"));
                    m_Data.Add(new DispCode("310349", "みらい内科クリニック", "鳥取県"));
                    m_Data.Add(new DispCode("317070", "鳥取大学医学部附属病院　腎臓内科", "鳥取県"));
                    m_Data.Add(new DispCode("317088", "日野病院", "鳥取県"));
                    m_Data.Add(new DispCode("320026", "松江赤十字病院", "島根県"));
                    m_Data.Add(new DispCode("320035", "総合病院松江生協病院", "島根県"));
                    m_Data.Add(new DispCode("320043", "松江市立病院", "島根県"));
                    m_Data.Add(new DispCode("320052", "浜田医療センター", "島根県"));
                    m_Data.Add(new DispCode("320063", "島根県立中央病院", "島根県"));
                    m_Data.Add(new DispCode("320073", "隠岐病院", "島根県"));
                    m_Data.Add(new DispCode("320109", "北村内科クリニック", "島根県"));
                    m_Data.Add(new DispCode("320116", "江津総合病院", "島根県"));
                    m_Data.Add(new DispCode("320129", "森脇医院", "島根県"));
                    m_Data.Add(new DispCode("320133", "出雲市民病院", "島根県"));
                    m_Data.Add(new DispCode("320149", "おおつかクリニック", "島根県"));
                    m_Data.Add(new DispCode("320156", "益田赤十字病院", "島根県"));
                    m_Data.Add(new DispCode("320190", "島根大学医学部附属病院", "島根県"));
                    m_Data.Add(new DispCode("320218", "安来第一病院", "島根県"));
                    m_Data.Add(new DispCode("320228", "平成記念病院", "島根県"));
                    m_Data.Add(new DispCode("320239", "姫野クリニック", "島根県"));
                    m_Data.Add(new DispCode("320243", "公立邑智病院", "島根県"));
                    m_Data.Add(new DispCode("320253", "大田市立病院", "島根県"));
                    m_Data.Add(new DispCode("320269", "松江腎クリニック", "島根県"));
                    m_Data.Add(new DispCode("320273", "安来市立病院", "島根県"));
                    m_Data.Add(new DispCode("320289", "前之園泌尿器科内科医院", "島根県"));
                    m_Data.Add(new DispCode("320299", "大石内科医院", "島根県"));
                    m_Data.Add(new DispCode("320309", "大田姫野クリニック", "島根県"));
                    m_Data.Add(new DispCode("320318", "出雲徳洲会病院", "島根県"));
                    m_Data.Add(new DispCode("320329", "いきいき．クリニック", "島根県"));
                    m_Data.Add(new DispCode("320344", "益田地域医療センター医師会病院", "島根県"));
                    m_Data.Add(new DispCode("320359", "花田クリニック", "島根県"));
                    m_Data.Add(new DispCode("327039", "河原泌尿器科医院", "島根県"));
                    m_Data.Add(new DispCode("327043", "雲南市立病院", "島根県"));
                    m_Data.Add(new DispCode("330010", "岡山大学病院", "岡山県"));
                    m_Data.Add(new DispCode("330081", "川崎医科大学総合医療センター", "岡山県"));
                    m_Data.Add(new DispCode("330098", "岡山中央病院", "岡山県"));
                    m_Data.Add(new DispCode("330106", "岡山済生会総合病院", "岡山県"));
                    m_Data.Add(new DispCode("330122", "岡山医療センター", "岡山県"));
                    m_Data.Add(new DispCode("330137", "総合病院岡山協立病院", "岡山県"));
                    m_Data.Add(new DispCode("330148", "重井医学研究所附属病院", "岡山県"));
                    m_Data.Add(new DispCode("330161", "川崎医科大学附属病院", "岡山県"));
                    m_Data.Add(new DispCode("330178", "倉敷中央病院", "岡山県"));
                    m_Data.Add(new DispCode("330188", "倉敷成人病センター", "岡山県"));
                    m_Data.Add(new DispCode("330195", "水島協同病院", "岡山県"));
                    m_Data.Add(new DispCode("330208", "しげい病院", "岡山県"));
                    m_Data.Add(new DispCode("330218", "津山中央病院", "岡山県"));
                    m_Data.Add(new DispCode("330227", "総合病院落合病院", "岡山県"));
                    m_Data.Add(new DispCode("330239", "西崎内科医院", "岡山県"));
                    m_Data.Add(new DispCode("330249", "福島内科医院", "岡山県"));
                    m_Data.Add(new DispCode("330259", "青江クリニック", "岡山県"));
                    m_Data.Add(new DispCode("330268", "菅病院", "岡山県"));
                    m_Data.Add(new DispCode("330279", "笛木内科医院", "岡山県"));
                    m_Data.Add(new DispCode("330289", "三村医院", "岡山県"));
                    m_Data.Add(new DispCode("330294", "赤磐医師会病院", "岡山県"));
                    m_Data.Add(new DispCode("330309", "木本内科", "岡山県"));
                    m_Data.Add(new DispCode("330318", "児島中央病院", "岡山県"));
                    m_Data.Add(new DispCode("330348", "北川病院", "岡山県"));
                    m_Data.Add(new DispCode("330369", "岩藤胃腸科外科歯科クリニック", "岡山県"));
                    m_Data.Add(new DispCode("330379", "杉本クリニック", "岡山県"));
                    m_Data.Add(new DispCode("330388", "石川病院", "岡山県"));
                    m_Data.Add(new DispCode("330398", "岡村一心堂病院", "岡山県"));
                    m_Data.Add(new DispCode("330408", "さとう記念病院", "岡山県"));
                    m_Data.Add(new DispCode("330429", "新見クリニック", "岡山県"));
                    m_Data.Add(new DispCode("330449", "岡山照陽クリニック", "岡山県"));
                    m_Data.Add(new DispCode("330459", "康愛クリニック", "岡山県"));
                    m_Data.Add(new DispCode("330468", "笠岡第一病院", "岡山県"));
                    m_Data.Add(new DispCode("330498", "幸町記念病院", "岡山県"));
                    m_Data.Add(new DispCode("330509", "小畑醫院", "岡山県"));
                    m_Data.Add(new DispCode("330539", "池田医院", "岡山県"));
                    m_Data.Add(new DispCode("330543", "市立備前病院", "岡山県"));
                    m_Data.Add(new DispCode("330558", "金光病院", "岡山県"));
                    m_Data.Add(new DispCode("330588", "光生病院", "岡山県"));
                    m_Data.Add(new DispCode("330608", "津山第一病院", "岡山県"));
                    m_Data.Add(new DispCode("330618", "心臓病センター榊原病院", "岡山県"));
                    m_Data.Add(new DispCode("330633", "市立吉永病院", "岡山県"));
                    m_Data.Add(new DispCode("330648", "高梁中央病院　", "岡山県"));
                    m_Data.Add(new DispCode("330659", "渡辺医院", "岡山県"));
                    m_Data.Add(new DispCode("330679", "南方クリニック", "岡山県"));
                    m_Data.Add(new DispCode("330689", "ながけクリニック", "岡山県"));
                    m_Data.Add(new DispCode("330698", "玉島中央病院", "岡山県"));
                    m_Data.Add(new DispCode("330719", "なんば内科クリニック", "岡山県"));
                    m_Data.Add(new DispCode("330728", "津山中央記念病院", "岡山県"));
                    m_Data.Add(new DispCode("330736", "済生会吉備病院", "岡山県"));
                    m_Data.Add(new DispCode("330749", "海岸通りクリニック", "岡山県"));
                    m_Data.Add(new DispCode("330769", "JIKEIクリニック", "岡山県"));
                    m_Data.Add(new DispCode("330779", "おさふねクリニック", "岡山県"));
                    m_Data.Add(new DispCode("330789", "東岡山ながけクリニック", "岡山県"));
                    m_Data.Add(new DispCode("330799", "川井クリニック", "岡山県"));
                    m_Data.Add(new DispCode("330829", "吉田内科クリニック", "岡山県"));
                    m_Data.Add(new DispCode("330838", "まび記念病院", "岡山県"));
                    m_Data.Add(new DispCode("330849", "おかやま西クリニック", "岡山県"));
                    m_Data.Add(new DispCode("330858", "岡山西大寺病院", "岡山県"));
                    m_Data.Add(new DispCode("330869", "タカヤクリニック", "岡山県"));
                    m_Data.Add(new DispCode("330875", "玉島協同病院", "岡山県"));
                    m_Data.Add(new DispCode("330886", "岡山赤十字病院", "岡山県"));
                    m_Data.Add(new DispCode("330899", "おおうみクリニック", "岡山県"));
                    m_Data.Add(new DispCode("330919", "多田クリニック", "岡山県"));
                    m_Data.Add(new DispCode("330929", "のなか内科腎診療所", "岡山県"));
                    m_Data.Add(new DispCode("330939", "しげい腎クリニック早島", "岡山県"));
                    m_Data.Add(new DispCode("337088", "福渡病院", "岡山県"));
                    m_Data.Add(new DispCode("340033", "広島市民病院", "広島県"));
                    m_Data.Add(new DispCode("340048", "本永病院", "広島県"));
                    m_Data.Add(new DispCode("340053", "県立広島病院", "広島県"));
                    m_Data.Add(new DispCode("340068", "木曽病院", "広島県"));
                    m_Data.Add(new DispCode("340087", "土谷総合病院", "広島県"));
                    m_Data.Add(new DispCode("340098", "福馬病院", "広島県"));
                    m_Data.Add(new DispCode("340106", "呉共済病院", "広島県"));
                    m_Data.Add(new DispCode("340119", "博愛クリニック", "広島県"));
                    m_Data.Add(new DispCode("340128", "三原城町病院", "広島県"));
                    m_Data.Add(new DispCode("340137", "興生総合病院", "広島県"));
                    m_Data.Add(new DispCode("340157", "福山リハビリテーション病院", "広島県"));
                    m_Data.Add(new DispCode("340193", "市立三次中央病院", "広島県"));
                    m_Data.Add(new DispCode("340208", "一陽会原田病院", "広島県"));
                    m_Data.Add(new DispCode("340219", "中央内科クリニック", "広島県"));
                    m_Data.Add(new DispCode("340222", "東広島医療センター", "広島県"));
                    m_Data.Add(new DispCode("340258", "福山城西病院", "広島県"));
                    m_Data.Add(new DispCode("340268", "安田病院", "広島県"));
                    m_Data.Add(new DispCode("340278", "寺岡記念病院", "広島県"));
                    m_Data.Add(new DispCode("340289", "山下医院", "広島県"));
                    m_Data.Add(new DispCode("340299", "井口医院", "広島県"));
                    m_Data.Add(new DispCode("340309", "尾道クリニック", "広島県"));
                    m_Data.Add(new DispCode("340318", "山陽病院", "広島県"));
                    m_Data.Add(new DispCode("340323", "安芸太田病院", "広島県"));
                    m_Data.Add(new DispCode("340339", "加美川クリニック", "広島県"));
                    m_Data.Add(new DispCode("340343", "福山市民病院", "広島県"));
                    m_Data.Add(new DispCode("340369", "博美医院", "広島県"));
                    m_Data.Add(new DispCode("340376", "総合病院庄原赤十字病院", "広島県"));
                    m_Data.Add(new DispCode("340383", "尾道市公立みつぎ総合病院", "広島県"));
                    m_Data.Add(new DispCode("340418", "阿品土谷病院", "広島県"));
                    m_Data.Add(new DispCode("340428", "日本鋼管福山病院", "広島県"));
                    m_Data.Add(new DispCode("340438", "南海田病院", "広島県"));
                    m_Data.Add(new DispCode("340448", "セントラル病院", "広島県"));
                    m_Data.Add(new DispCode("340458", "梶川病院", "広島県"));
                    m_Data.Add(new DispCode("340475", "吉田総合病院", "広島県"));
                    m_Data.Add(new DispCode("340489", "森本医院", "広島県"));
                    m_Data.Add(new DispCode("340499", "山地内科医院", "広島県"));
                    m_Data.Add(new DispCode("340510", "広島大学病院　腎臓内科", "広島県"));
                    m_Data.Add(new DispCode("340526", "広島赤十字・原爆病院", "広島県"));
                    m_Data.Add(new DispCode("340538", "神原病院", "広島県"));
                    m_Data.Add(new DispCode("340548", "青山病院", "広島県"));
                    m_Data.Add(new DispCode("340552", "呉医療センター", "広島県"));
                    m_Data.Add(new DispCode("340569", "大竹中央クリニック", "広島県"));
                    m_Data.Add(new DispCode("340579", "福山クリニック", "広島県"));
                    m_Data.Add(new DispCode("340588", "千代田中央病院", "広島県"));
                    m_Data.Add(new DispCode("340599", "双樹クリニック", "広島県"));
                    m_Data.Add(new DispCode("340603", "尾道市立市民病院", "広島県"));
                    m_Data.Add(new DispCode("340619", "大町土谷クリニック", "広島県"));
                    m_Data.Add(new DispCode("340624", "カナデビア健康保険組合因島総合病院", "広島県"));
                    m_Data.Add(new DispCode("340639", "サンクリニック", "広島県"));
                    m_Data.Add(new DispCode("340649", "さくらの丘クリニック", "広島県"));
                    m_Data.Add(new DispCode("340653", "府中市民病院", "広島県"));
                    m_Data.Add(new DispCode("340669", "新開医院", "広島県"));
                    m_Data.Add(new DispCode("340678", "広島中央リハビリテーション病院", "広島県"));
                    m_Data.Add(new DispCode("340689", "フェニックスクリニック", "広島県"));
                    m_Data.Add(new DispCode("340699", "稲垣胃腸科・外科クリニック", "広島県"));
                    m_Data.Add(new DispCode("340709", "高須クリニック", "広島県"));
                    m_Data.Add(new DispCode("340718", "西条中央病院", "広島県"));
                    m_Data.Add(new DispCode("340729", "山陽腎クリニック", "広島県"));
                    m_Data.Add(new DispCode("340759", "一陽会クリニック", "広島県"));
                    m_Data.Add(new DispCode("340764", "三次地区医療センター", "広島県"));
                    m_Data.Add(new DispCode("340779", "イーストクリニック", "広島県"));
                    m_Data.Add(new DispCode("340785", "ＪＡ広島総合病院", "広島県"));
                    m_Data.Add(new DispCode("340799", "うらべ医院", "広島県"));
                    m_Data.Add(new DispCode("340803", "府中北市民病院", "広島県"));
                    m_Data.Add(new DispCode("340816", "総合病院三原赤十字病院", "広島県"));
                    m_Data.Add(new DispCode("340820", "広島大学病院　透析内科", "広島県"));
                    m_Data.Add(new DispCode("340839", "中島土谷クリニック", "広島県"));
                    m_Data.Add(new DispCode("340849", "さいきじんクリニック", "広島県"));
                    m_Data.Add(new DispCode("340854", "三原市医師会病院", "広島県"));
                    m_Data.Add(new DispCode("340869", "芸南クリニック", "広島県"));
                    m_Data.Add(new DispCode("340879", "こね森内科医院", "広島県"));
                    m_Data.Add(new DispCode("340889", "小田内科クリニック", "広島県"));
                    m_Data.Add(new DispCode("340899", "やまてクリニック", "広島県"));
                    m_Data.Add(new DispCode("340909", "横川クリニック", "広島県"));
                    m_Data.Add(new DispCode("340918", "大朝ふるさと病院", "広島県"));
                    m_Data.Add(new DispCode("340929", "勝木台クリニック", "広島県"));
                    m_Data.Add(new DispCode("340955", "尾道総合病院", "広島県"));
                    m_Data.Add(new DispCode("340966", "中国中央病院", "広島県"));
                    m_Data.Add(new DispCode("340989", "永井医院", "広島県"));
                    m_Data.Add(new DispCode("340999", "竹中クリニック", "広島県"));
                    m_Data.Add(new DispCode("341009", "クレア焼山クリニック", "広島県"));
                    m_Data.Add(new DispCode("341018", "太田川病院", "広島県"));
                    m_Data.Add(new DispCode("341023", "神石高原町立病院", "広島県"));
                    m_Data.Add(new DispCode("341038", "松尾内科病院", "広島県"));
                    m_Data.Add(new DispCode("341059", "山陽ぬまくま腎クリニック", "広島県"));
                    m_Data.Add(new DispCode("341069", "谷本医院", "広島県"));
                    m_Data.Add(new DispCode("341079", "広島ベイクリニック", "広島県"));
                    m_Data.Add(new DispCode("341089", "はしもとじんクリニック", "広島県"));
                    m_Data.Add(new DispCode("341108", "楠本病院", "広島県"));
                    m_Data.Add(new DispCode("341114", "広島市医師会運営・安芸市民病院", "広島県"));
                    m_Data.Add(new DispCode("341122", "広島西医療センター", "広島県"));
                    m_Data.Add(new DispCode("341139", "サンクリニックみなが", "広島県"));
                    m_Data.Add(new DispCode("341143", "県立二葉の里病院", "広島県"));
                    m_Data.Add(new DispCode("341158", "青木病院", "広島県"));
                    m_Data.Add(new DispCode("341168", "瀬野記念病院", "広島県"));
                    m_Data.Add(new DispCode("341179", "どい腎臓内科透析クリニック", "広島県"));
                    m_Data.Add(new DispCode("341188", "広島心臓血管病院", "広島県"));
                    m_Data.Add(new DispCode("341199", "いやさか腎クリニック", "広島県"));
                    m_Data.Add(new DispCode("347078", "木阪病院", "広島県"));
                    m_Data.Add(new DispCode("347169", "増原会東城病院", "広島県"));
                    m_Data.Add(new DispCode("347199", "村田内科クリニック", "広島県"));
                    m_Data.Add(new DispCode("350013", "下関市立市民病院", "山口県"));
                    m_Data.Add(new DispCode("350029", "細江クリニック", "山口県"));
                    m_Data.Add(new DispCode("350039", "いとう腎クリニック", "山口県"));
                    m_Data.Add(new DispCode("350043", "大島病院", "山口県"));
                    m_Data.Add(new DispCode("350050", "山口大学医学部附属病院", "山口県"));
                    m_Data.Add(new DispCode("350078", "前田内科病院", "山口県"));
                    m_Data.Add(new DispCode("350088", "坂本病院", "山口県"));
                    m_Data.Add(new DispCode("350098", "都志見病院", "山口県"));
                    m_Data.Add(new DispCode("350108", "玉木病院", "山口県"));
                    m_Data.Add(new DispCode("350119", "徳山クリニック", "山口県"));
                    m_Data.Add(new DispCode("350129", "おかもと内科", "山口県"));
                    m_Data.Add(new DispCode("350138", "桑陽病院", "山口県"));
                    m_Data.Add(new DispCode("350148", "岩国中央病院", "山口県"));
                    m_Data.Add(new DispCode("350166", "山口県済生会下関総合病院", "山口県"));
                    m_Data.Add(new DispCode("350185", "長門総合病院", "山口県"));
                    m_Data.Add(new DispCode("350196", "山口県済生会山口総合病院", "山口県"));
                    m_Data.Add(new DispCode("350208", "森田病院", "山口県"));
                    m_Data.Add(new DispCode("350218", "セントヒル病院", "山口県"));
                    m_Data.Add(new DispCode("350228", "岡田病院", "山口県"));
                    m_Data.Add(new DispCode("350234", "徳山中央病院", "山口県"));
                    m_Data.Add(new DispCode("350258", "萩むらた病院", "山口県"));
                    m_Data.Add(new DispCode("350288", "厚南セントヒル病院", "山口県"));
                    m_Data.Add(new DispCode("350299", "南園クリニック", "山口県"));
                    m_Data.Add(new DispCode("350309", "片山クリニック", "山口県"));
                    m_Data.Add(new DispCode("350333", "光総合病院", "山口県"));
                    m_Data.Add(new DispCode("350349", "長府第一クリニック", "山口県"));
                    m_Data.Add(new DispCode("350359", "すみだ内科クリニック", "山口県"));
                    m_Data.Add(new DispCode("350369", "平尾泌尿器科", "山口県"));
                    m_Data.Add(new DispCode("350375", "小郡第一総合病院", "山口県"));
                    m_Data.Add(new DispCode("350398", "宇部仁心会病院", "山口県"));
                    m_Data.Add(new DispCode("350409", "しのはらクリニック", "山口県"));
                    m_Data.Add(new DispCode("350418", "三田尻病院", "山口県"));
                    m_Data.Add(new DispCode("350426", "綜合病院山口赤十字病院", "山口県"));
                    m_Data.Add(new DispCode("350449", "玖珂クリニック", "山口県"));
                    m_Data.Add(new DispCode("350459", "林田クリニック", "山口県"));
                    m_Data.Add(new DispCode("350469", "きし腎泌尿器科", "山口県"));
                    m_Data.Add(new DispCode("350473", "山陽小野田市民病院", "山口県"));
                    m_Data.Add(new DispCode("350485", "周東総合病院", "山口県"));
                    m_Data.Add(new DispCode("350494", "岩国市医療センター医師会病院", "山口県"));
                    m_Data.Add(new DispCode("350504", "下関医療センター", "山口県"));
                    m_Data.Add(new DispCode("350513", "美祢市立病院", "山口県"));
                    m_Data.Add(new DispCode("350529", "かまたクリニック", "山口県"));
                    m_Data.Add(new DispCode("350539", "厚狭セントヒル泌尿器科", "山口県"));
                    m_Data.Add(new DispCode("350542", "柳井医療センター", "山口県"));
                    m_Data.Add(new DispCode("350559", "光山医院", "山口県"));
                    m_Data.Add(new DispCode("350602", "関門医療センター", "山口県"));
                    m_Data.Add(new DispCode("350618", "阿知須共立病院", "山口県"));
                    m_Data.Add(new DispCode("350623", "山口県立総合医療センター", "山口県"));
                    m_Data.Add(new DispCode("350639", "そだクリニック", "山口県"));
                    m_Data.Add(new DispCode("350648", "サンポプラ病院", "山口県"));
                    m_Data.Add(new DispCode("350659", "光山医院　山口", "山口県"));
                    m_Data.Add(new DispCode("350669", "周南ニュークリニック", "山口県"));
                    m_Data.Add(new DispCode("350679", "ひかり腎泌尿器科クリニック", "山口県"));
                    m_Data.Add(new DispCode("357028", "周南記念病院", "山口県"));
                    m_Data.Add(new DispCode("357063", "周南市立新南陽市民病院", "山口県"));
                    m_Data.Add(new DispCode("357086", "山口県済生会豊浦病院", "山口県"));
                    m_Data.Add(new DispCode("357094", "萩市民病院", "山口県"));
                    m_Data.Add(new DispCode("360010", "徳島大学病院", "徳島県"));
                    m_Data.Add(new DispCode("360023", "徳島県立中央病院", "徳島県"));
                    m_Data.Add(new DispCode("360038", "川島病院", "徳島県"));
                    m_Data.Add(new DispCode("360048", "住友内科病院", "徳島県"));
                    m_Data.Add(new DispCode("360059", "赤沢医院", "徳島県"));
                    m_Data.Add(new DispCode("360076", "徳島赤十字病院", "徳島県"));
                    m_Data.Add(new DispCode("360085", "阿南医療センター", "徳島県"));
                    m_Data.Add(new DispCode("360099", "矢野医院", "徳島県"));
                    m_Data.Add(new DispCode("360102", "とくしま医療センター東病院", "徳島県"));
                    m_Data.Add(new DispCode("360115", "阿波病院", "徳島県"));
                    m_Data.Add(new DispCode("360129", "ライフクリニック", "徳島県"));
                    m_Data.Add(new DispCode("360133", "徳島県鳴門病院", "徳島県"));
                    m_Data.Add(new DispCode("360143", "徳島市民病院", "徳島県"));
                    m_Data.Add(new DispCode("360158", "玉真病院", "徳島県"));
                    m_Data.Add(new DispCode("360169", "鴨島川島クリニック", "徳島県"));
                    m_Data.Add(new DispCode("360188", "岩朝病院", "徳島県"));
                    m_Data.Add(new DispCode("360198", "たまき青空病院", "徳島県"));
                    m_Data.Add(new DispCode("360203", "徳島県立三好病院", "徳島県"));
                    m_Data.Add(new DispCode("360218", "小松島金磯病院", "徳島県"));
                    m_Data.Add(new DispCode("360239", "玉真病院牟岐診療所", "徳島県"));
                    m_Data.Add(new DispCode("360248", "三加茂田中病院", "徳島県"));
                    m_Data.Add(new DispCode("360259", "三木医院", "徳島県"));
                    m_Data.Add(new DispCode("360278", "亀井病院", "徳島県"));
                    m_Data.Add(new DispCode("360285", "吉野川医療センター", "徳島県"));
                    m_Data.Add(new DispCode("360299", "鳴門川島クリニック", "徳島県"));
                    m_Data.Add(new DispCode("360303", "つるぎ町立半田病院", "徳島県"));
                    m_Data.Add(new DispCode("360339", "お山のクリニック", "徳島県"));
                    m_Data.Add(new DispCode("360378", "沖の洲病院", "徳島県"));
                    m_Data.Add(new DispCode("360399", "脇町川島クリニック", "徳島県"));
                    m_Data.Add(new DispCode("360409", "川島透析クリニック", "徳島県"));
                    m_Data.Add(new DispCode("360419", "阿南川島クリニック", "徳島県"));
                    m_Data.Add(new DispCode("360429", "藍住たまき青空クリニック", "徳島県"));
                    m_Data.Add(new DispCode("360459", "藍住 川島クリニック", "徳島県"));
                    m_Data.Add(new DispCode("360469", "海べのクリニック", "徳島県"));
                    m_Data.Add(new DispCode("360478", "田岡病院", "徳島県"));
                    m_Data.Add(new DispCode("367028", "協立病院", "徳島県"));
                    m_Data.Add(new DispCode("367058", "徳島健生病院", "徳島県"));
                    m_Data.Add(new DispCode("370013", "香川県立中央病院", "香川県"));
                    m_Data.Add(new DispCode("370029", "海部医院", "香川県"));
                    m_Data.Add(new DispCode("370033", "高松市立みんなの病院", "香川県"));
                    m_Data.Add(new DispCode("370046", "高松赤十字病院", "香川県"));
                    m_Data.Add(new DispCode("370053", "小豆島中央病院", "香川県"));
                    m_Data.Add(new DispCode("370068", "キナシ大林病院", "香川県"));
                    m_Data.Add(new DispCode("370086", "香川労災病院", "香川県"));
                    m_Data.Add(new DispCode("370098", "人工透析センター　宮野病院", "香川県"));
                    m_Data.Add(new DispCode("370112", "四国こどもとおとなの医療センター", "香川県"));
                    m_Data.Add(new DispCode("370123", "三豊総合病院", "香川県"));
                    m_Data.Add(new DispCode("370137", "まるがめ医療センター", "香川県"));
                    m_Data.Add(new DispCode("370156", "香川県済生会病院", "香川県"));
                    m_Data.Add(new DispCode("370168", "河内病院", "香川県"));
                    m_Data.Add(new DispCode("370178", "香川井下病院", "香川県"));
                    m_Data.Add(new DispCode("370189", "横井内科医院", "香川県"));
                    m_Data.Add(new DispCode("370197", "総合病院回生病院", "香川県"));
                    m_Data.Add(new DispCode("370200", "香川大学医学部附属病院", "香川県"));
                    m_Data.Add(new DispCode("370218", "永生病院", "香川県"));
                    m_Data.Add(new DispCode("370223", "さぬき市民病院", "香川県"));
                    m_Data.Add(new DispCode("370239", "中空医院", "香川県"));
                    m_Data.Add(new DispCode("370269", "淡河医院", "香川県"));
                    m_Data.Add(new DispCode("370275", "屋島総合病院", "香川県"));
                    m_Data.Add(new DispCode("370288", "太田病院", "香川県"));
                    m_Data.Add(new DispCode("370298", "岩崎病院", "香川県"));
                    m_Data.Add(new DispCode("370309", "リウマチ・腎臓内科はちまんクリニック", "香川県"));
                    m_Data.Add(new DispCode("370319", "クニタクリニック", "香川県"));
                    m_Data.Add(new DispCode("370329", "大幸医療センター", "香川県"));
                    m_Data.Add(new DispCode("370358", "善通寺前田病院", "香川県"));
                    m_Data.Add(new DispCode("370369", "三好内科医院", "香川県"));
                    m_Data.Add(new DispCode("370379", "湯浅クリニック", "香川県"));
                    m_Data.Add(new DispCode("370389", "あきやまクリニック", "香川県"));
                    m_Data.Add(new DispCode("370396", "ＫＫＲ高松病院", "香川県"));
                    m_Data.Add(new DispCode("370405", "滝宮総合病院", "香川県"));
                    m_Data.Add(new DispCode("370418", "宇多津病院", "香川県"));
                    m_Data.Add(new DispCode("370429", "山本ヒフ泌尿器科医院", "香川県"));
                    m_Data.Add(new DispCode("370439", "ザイタックスクリニック", "香川県"));
                    m_Data.Add(new DispCode("370449", "花ノ宮クリニック", "香川県"));
                    m_Data.Add(new DispCode("370453", "綾川町国民健康保険陶病院", "香川県"));
                    m_Data.Add(new DispCode("370469", "はまもと医院", "香川県"));
                    m_Data.Add(new DispCode("370479", "みとよ内科にれクリニック", "香川県"));
                    m_Data.Add(new DispCode("370493", "坂出市立病院", "香川県"));
                    m_Data.Add(new DispCode("370509", "綾川クリニック", "香川県"));
                    m_Data.Add(new DispCode("370519", "高松にれクリニック", "香川県"));
                    m_Data.Add(new DispCode("370529", "谷本内科医院", "香川県"));
                    m_Data.Add(new DispCode("370539", "さくらの馬場クリニック", "香川県"));
                    m_Data.Add(new DispCode("370549", "こはし内科・腎クリニック", "香川県"));
                    m_Data.Add(new DispCode("370559", "志度あきやまクリニック", "香川県"));
                    m_Data.Add(new DispCode("377028", "ミタニ病院", "香川県"));
                    m_Data.Add(new DispCode("380013", "市立宇和島病院", "愛媛県"));
                    m_Data.Add(new DispCode("380026", "松山赤十字病院", "愛媛県"));
                    m_Data.Add(new DispCode("380033", "愛媛県立中央病院", "愛媛県"));
                    m_Data.Add(new DispCode("380048", "南松山病院", "愛媛県"));
                    m_Data.Add(new DispCode("380066", "済生会今治病院", "愛媛県"));
                    m_Data.Add(new DispCode("380093", "市立八幡浜総合病院", "愛媛県"));
                    m_Data.Add(new DispCode("380118", "住友別子病院", "愛媛県"));
                    m_Data.Add(new DispCode("380128", "村上記念病院", "愛媛県"));
                    m_Data.Add(new DispCode("380143", "市立大洲病院", "愛媛県"));
                    m_Data.Add(new DispCode("380157", "十全総合病院", "愛媛県"));
                    m_Data.Add(new DispCode("380176", "済生会西条病院", "愛媛県"));
                    m_Data.Add(new DispCode("380239", "池田医院", "愛媛県"));
                    m_Data.Add(new DispCode("380249", "三島クリニック", "愛媛県"));
                    m_Data.Add(new DispCode("380259", "みやはら腎・泌尿器科クリニック", "愛媛県"));
                    m_Data.Add(new DispCode("380269", "重信クリニック", "愛媛県"));
                    m_Data.Add(new DispCode("380278", "松山西病院", "愛媛県"));
                    m_Data.Add(new DispCode("380280", "愛媛大学医学部附属病院", "愛媛県"));
                    m_Data.Add(new DispCode("380303", "愛媛県立今治病院", "愛媛県"));
                    m_Data.Add(new DispCode("380326", "四国中央病院", "愛媛県"));
                    m_Data.Add(new DispCode("380348", "広瀬病院", "愛媛県"));
                    m_Data.Add(new DispCode("380358", "長谷川病院", "愛媛県"));
                    m_Data.Add(new DispCode("380369", "木村内科医院", "愛媛県"));
                    m_Data.Add(new DispCode("380379", "村上医院", "愛媛県"));
                    m_Data.Add(new DispCode("380389", "小田ひ尿器科・ふみこ皮フ科", "愛媛県"));
                    m_Data.Add(new DispCode("380399", "飯尾皮フ科泌尿器科", "愛媛県"));
                    m_Data.Add(new DispCode("380403", "西予市立西予市民病院", "愛媛県"));
                    m_Data.Add(new DispCode("380419", "佐藤循環器科内科", "愛媛県"));
                    m_Data.Add(new DispCode("380423", "愛媛県立南宇和病院", "愛媛県"));
                    m_Data.Add(new DispCode("380438", "松山市民病院", "愛媛県"));
                    m_Data.Add(new DispCode("380443", "愛媛県立新居浜病院", "愛媛県"));
                    m_Data.Add(new DispCode("380456", "済生会松山病院", "愛媛県"));
                    m_Data.Add(new DispCode("380468", "北条病院", "愛媛県"));
                    m_Data.Add(new DispCode("380473", "宇和島市立津島病院", "愛媛県"));
                    m_Data.Add(new DispCode("380488", "西条中央病院", "愛媛県"));
                    m_Data.Add(new DispCode("380498", "今治南病院", "愛媛県"));
                    m_Data.Add(new DispCode("380509", "増田泌尿器科", "愛媛県"));
                    m_Data.Add(new DispCode("380519", "武智ひ尿器科・内科", "愛媛県"));
                    m_Data.Add(new DispCode("380539", "衣山クリニック", "愛媛県"));
                    m_Data.Add(new DispCode("380558", "放射線第一病院", "愛媛県"));
                    m_Data.Add(new DispCode("380569", "おだクリニック", "愛媛県"));
                    m_Data.Add(new DispCode("380578", "宇和島徳洲会病院", "愛媛県"));
                    m_Data.Add(new DispCode("380589", "なかの泌尿器科", "愛媛県"));
                    m_Data.Add(new DispCode("380599", "道後一万クリニック", "愛媛県"));
                    m_Data.Add(new DispCode("380609", "桑嶋クリニック", "愛媛県"));
                    m_Data.Add(new DispCode("380629", "松下クリニック", "愛媛県"));
                    m_Data.Add(new DispCode("380639", "くろみつクリニック", "愛媛県"));
                    m_Data.Add(new DispCode("380649", "じょうとく内科クリニック", "愛媛県"));
                    m_Data.Add(new DispCode("380659", "あずま泌尿器科クリニック", "愛媛県"));
                    m_Data.Add(new DispCode("380669", "山下クリニック", "愛媛県"));
                    m_Data.Add(new DispCode("387049", "あゆみクリニック", "愛媛県"));
                    m_Data.Add(new DispCode("387138", "山内病院", "愛媛県"));
                    m_Data.Add(new DispCode("390016", "高知赤十字病院", "高知県"));
                    m_Data.Add(new DispCode("390023", "高知医療センター", "高知県"));
                    m_Data.Add(new DispCode("390032", "高知病院", "高知県"));
                    m_Data.Add(new DispCode("390044", "高知西病院", "高知県"));
                    m_Data.Add(new DispCode("390058", "島津病院", "高知県"));
                    m_Data.Add(new DispCode("390068", "近森病院", "高知県"));
                    m_Data.Add(new DispCode("390078", "高知高須病院", "高知県"));
                    m_Data.Add(new DispCode("390085", "ＪＡ高知病院", "高知県"));
                    m_Data.Add(new DispCode("390098", "北村病院", "高知県"));
                    m_Data.Add(new DispCode("390113", "四万十市立市民病院", "高知県"));
                    m_Data.Add(new DispCode("390129", "幡多クリニック", "高知県"));
                    m_Data.Add(new DispCode("390139", "高知高須病院附属安芸診療所", "高知県"));
                    m_Data.Add(new DispCode("390143", "高知県立あき総合病院", "高知県"));
                    m_Data.Add(new DispCode("390168", "愛宕病院", "高知県"));
                    m_Data.Add(new DispCode("390178", "森木病院", "高知県"));
                    m_Data.Add(new DispCode("390183", "高北国民健康保険病院", "高知県"));
                    m_Data.Add(new DispCode("390199", "クリニックひろと", "高知県"));
                    m_Data.Add(new DispCode("390200", "高知大学医学部附属病院", "高知県"));
                    m_Data.Add(new DispCode("390218", "竹下病院", "高知県"));
                    m_Data.Add(new DispCode("390238", "野市中央病院", "高知県"));
                    m_Data.Add(new DispCode("390258", "くぼかわ病院", "高知県"));
                    m_Data.Add(new DispCode("390268", "渭南病院", "高知県"));
                    m_Data.Add(new DispCode("390278", "北島病院", "高知県"));
                    m_Data.Add(new DispCode("390293", "土佐市立土佐市民病院", "高知県"));
                    m_Data.Add(new DispCode("390308", "松谷病院", "高知県"));
                    m_Data.Add(new DispCode("390319", "島津クリニック", "高知県"));
                    m_Data.Add(new DispCode("390323", "高知県立幡多けんみん病院", "高知県"));
                    m_Data.Add(new DispCode("390339", "高知高須病院室戸クリニック", "高知県"));
                    m_Data.Add(new DispCode("390349", "川村内科クリニック", "高知県"));
                    m_Data.Add(new DispCode("390359", "快聖クリニック", "高知県"));
                    m_Data.Add(new DispCode("390369", "もえぎクリニック", "高知県"));
                    m_Data.Add(new DispCode("390389", "須崎医療クリニック", "高知県"));
                    m_Data.Add(new DispCode("390398", "高知記念病院", "高知県"));
                    m_Data.Add(new DispCode("397043", "国保嶺北中央病院", "高知県"));
                    m_Data.Add(new DispCode("397058", "なかとさ病院", "高知県"));
                    m_Data.Add(new DispCode("397068", "いずみの病院", "高知県"));
                    m_Data.Add(new DispCode("397078", "長浜病院", "高知県"));
                    m_Data.Add(new DispCode("397089", "藤田クリニック", "高知県"));
                    m_Data.Add(new DispCode("400015", "門司掖済会病院", "福岡県"));
                    m_Data.Add(new DispCode("400024", "小倉記念病院", "福岡県"));
                    m_Data.Add(new DispCode("400046", "済生会八幡総合病院", "福岡県"));
                    m_Data.Add(new DispCode("400068", "小倉第一病院", "福岡県"));
                    m_Data.Add(new DispCode("400079", "松島クリニック", "福岡県"));
                    m_Data.Add(new DispCode("400088", "財団はまゆう会新王子病院", "福岡県"));
                    m_Data.Add(new DispCode("400098", "新小文字病院", "福岡県"));
                    m_Data.Add(new DispCode("400109", "城野クリニック", "福岡県"));
                    m_Data.Add(new DispCode("400120", "九州大学病院", "福岡県"));
                    m_Data.Add(new DispCode("400131", "福岡大学病院血液浄化療法センター", "福岡県"));
                    m_Data.Add(new DispCode("400146", "済生会福岡総合病院", "福岡県"));
                    m_Data.Add(new DispCode("400156", "浜の町病院", "福岡県"));
                    m_Data.Add(new DispCode("400163", "福岡市民病院", "福岡県"));
                    m_Data.Add(new DispCode("400176", "福岡赤十字病院", "福岡県"));
                    m_Data.Add(new DispCode("400189", "後藤クリニック", "福岡県"));
                    m_Data.Add(new DispCode("400199", "福岡腎臓内科クリニック", "福岡県"));
                    m_Data.Add(new DispCode("400208", "高木病院", "福岡県"));
                    m_Data.Add(new DispCode("400228", "博腎会病院", "福岡県"));
                    m_Data.Add(new DispCode("400248", "原三信病院", "福岡県"));
                    m_Data.Add(new DispCode("400269", "重松クリニック", "福岡県"));
                    m_Data.Add(new DispCode("400289", "飯田クリニック", "福岡県"));
                    m_Data.Add(new DispCode("400299", "春日医院", "福岡県"));
                    m_Data.Add(new DispCode("400319", "ふくみつクリニック", "福岡県"));
                    m_Data.Add(new DispCode("400321", "久留米大学病院", "福岡県"));
                    m_Data.Add(new DispCode("400334", "久留米総合病院", "福岡県"));
                    m_Data.Add(new DispCode("400348", "聖マリア病院", "福岡県"));
                    m_Data.Add(new DispCode("400358", "古賀病院２１", "福岡県"));
                    m_Data.Add(new DispCode("400369", "松尾内科医院", "福岡県"));
                    m_Data.Add(new DispCode("400384", "社会保険直方病院", "福岡県"));
                    m_Data.Add(new DispCode("400399", "高橋内科クリニック", "福岡県"));
                    m_Data.Add(new DispCode("400409", "なかしま 内科・糖尿病・腎クリニック", "福岡県"));
                    m_Data.Add(new DispCode("400418", "飯塚病院", "福岡県"));
                    m_Data.Add(new DispCode("400428", "一本松すずかけ病院", "福岡県"));
                    m_Data.Add(new DispCode("400437", "北九州総合病院", "福岡県"));
                    m_Data.Add(new DispCode("400449", "木村クリニック川宮医院", "福岡県"));
                    m_Data.Add(new DispCode("400453", "公立八女総合病院", "福岡県"));
                    m_Data.Add(new DispCode("400466", "福岡県済生会二日市病院", "福岡県"));
                    m_Data.Add(new DispCode("400488", "三野原病院", "福岡県"));
                    m_Data.Add(new DispCode("400498", "大手町病院", "福岡県"));
                    m_Data.Add(new DispCode("400508", "千鳥橋病院", "福岡県"));
                    m_Data.Add(new DispCode("400517", "宗像水光会総合病院", "福岡県"));
                    m_Data.Add(new DispCode("400533", "芦屋中央病院", "福岡県"));
                    m_Data.Add(new DispCode("400549", "今立内科クリニック", "福岡県"));
                    m_Data.Add(new DispCode("400559", "行橋クリニック", "福岡県"));
                    m_Data.Add(new DispCode("400568", "田主丸中央病院", "福岡県"));
                    m_Data.Add(new DispCode("400579", "三光クリニック", "福岡県"));
                    m_Data.Add(new DispCode("400589", "たかぼうクリニック", "福岡県"));
                    m_Data.Add(new DispCode("400599", "おおやぶクリニック", "福岡県"));
                    m_Data.Add(new DispCode("400613", "田川市立病院", "福岡県"));
                    m_Data.Add(new DispCode("400638", "東和病院", "福岡県"));
                    m_Data.Add(new DispCode("400649", "おおはし内科循環器内科医院", "福岡県"));
                    m_Data.Add(new DispCode("400669", "門司クリニック", "福岡県"));
                    m_Data.Add(new DispCode("400671", "産業医科大学病院", "福岡県"));
                    m_Data.Add(new DispCode("400688", "芳野病院", "福岡県"));
                    m_Data.Add(new DispCode("400718", "長尾病院", "福岡県"));
                    m_Data.Add(new DispCode("400738", "篠栗病院", "福岡県"));
                    m_Data.Add(new DispCode("400758", "福岡徳洲会病院", "福岡県"));
                    m_Data.Add(new DispCode("400779", "折尾クリニック", "福岡県"));
                    m_Data.Add(new DispCode("400789", "医生ヶ丘クリニック", "福岡県"));
                    m_Data.Add(new DispCode("400799", "くまクリニック", "福岡県"));
                    m_Data.Add(new DispCode("400808", "白十字病院", "福岡県"));
                    m_Data.Add(new DispCode("400828", "福西会病院", "福岡県"));
                    m_Data.Add(new DispCode("400839", "大熊泌尿器科医院", "福岡県"));
                    m_Data.Add(new DispCode("400858", "新中間病院", "福岡県"));
                    m_Data.Add(new DispCode("400868", "米の山病院", "福岡県"));
                    m_Data.Add(new DispCode("400878", "高山病院", "福岡県"));
                    m_Data.Add(new DispCode("400888", "社会保険大牟田天領病院", "福岡県"));
                    m_Data.Add(new DispCode("400898", "加野病院", "福岡県"));
                    m_Data.Add(new DispCode("400908", "ヨコクラ病院", "福岡県"));
                    m_Data.Add(new DispCode("400918", "杉循環器科内科病院", "福岡県"));
                    m_Data.Add(new DispCode("400938", "新古賀リハビリテーション病院みらい", "福岡県"));
                    m_Data.Add(new DispCode("400968", "喜悦会那珂川病院", "福岡県"));
                    m_Data.Add(new DispCode("400979", "島松内科医院", "福岡県"));
                    m_Data.Add(new DispCode("400988", "西福岡病院", "福岡県"));
                    m_Data.Add(new DispCode("400998", "福田病院", "福岡県"));
                    m_Data.Add(new DispCode("401018", "製鉄記念八幡病院", "福岡県"));
                    m_Data.Add(new DispCode("401029", "有吉クリニック", "福岡県"));
                    m_Data.Add(new DispCode("401039", "トーマ・クリニック", "福岡県"));
                    m_Data.Add(new DispCode("401050", "九州大学病院 小児科", "福岡県"));
                    m_Data.Add(new DispCode("401069", "北九州腎臓クリニック", "福岡県"));
                    m_Data.Add(new DispCode("401079", "水巻クリニック", "福岡県"));
                    m_Data.Add(new DispCode("401089", "天神クリニック", "福岡県"));
                    m_Data.Add(new DispCode("401099", "やまがたクリニック", "福岡県"));
                    m_Data.Add(new DispCode("401108", "福岡和白病院", "福岡県"));
                    m_Data.Add(new DispCode("401113", "福岡市立こども病院", "福岡県"));
                    m_Data.Add(new DispCode("401129", "安永クリニック", "福岡県"));
                    m_Data.Add(new DispCode("401138", "貝塚病院", "福岡県"));
                    m_Data.Add(new DispCode("401143", "くらて病院", "福岡県"));
                    m_Data.Add(new DispCode("401159", "松口胃腸科・外科医院", "福岡県"));
                    m_Data.Add(new DispCode("401169", "宮内内科循環器科", "福岡県"));
                    m_Data.Add(new DispCode("401179", "森山内科", "福岡県"));
                    m_Data.Add(new DispCode("401188", "福岡青洲会病院", "福岡県"));
                    m_Data.Add(new DispCode("401199", "はこざき公園内科医院", "福岡県"));
                    m_Data.Add(new DispCode("401209", "百武医院", "福岡県"));
                    m_Data.Add(new DispCode("401228", "佐々木病院", "福岡県"));
                    m_Data.Add(new DispCode("401239", "平川内科クリニック", "福岡県"));
                    m_Data.Add(new DispCode("401249", "信愛クリニック", "福岡県"));
                    m_Data.Add(new DispCode("401259", "今村クリニック", "福岡県"));
                    m_Data.Add(new DispCode("401269", "西新クリニック", "福岡県"));
                    m_Data.Add(new DispCode("401272", "九州医療センター", "福岡県"));
                    m_Data.Add(new DispCode("401289", "西田内科クリニック", "福岡県"));
                    m_Data.Add(new DispCode("401299", "こもたクリニック", "福岡県"));
                    m_Data.Add(new DispCode("401309", "聖和クリニック", "福岡県"));
                    m_Data.Add(new DispCode("401319", "かわい腎臓内科・泌尿器科クリニック", "福岡県"));
                    m_Data.Add(new DispCode("401328", "戸畑けんわ病院", "福岡県"));
                    m_Data.Add(new DispCode("401344", "宗像医師会病院", "福岡県"));
                    m_Data.Add(new DispCode("401359", "北九州ネフロクリニック", "福岡県"));
                    m_Data.Add(new DispCode("401369", "中村クリニック", "福岡県"));
                    m_Data.Add(new DispCode("401379", "吉武泌尿器科医院", "福岡県"));
                    m_Data.Add(new DispCode("401389", "江上内科クリニック", "福岡県"));
                    m_Data.Add(new DispCode("401399", "村石循環器科・内科", "福岡県"));
                    m_Data.Add(new DispCode("401409", "本村内科医院", "福岡県"));
                    m_Data.Add(new DispCode("401428", "うえの病院", "福岡県"));
                    m_Data.Add(new DispCode("401439", "青洲会クリニック", "福岡県"));
                    m_Data.Add(new DispCode("401448", "安本病院", "福岡県"));
                    m_Data.Add(new DispCode("401458", "朝倉健生病院", "福岡県"));
                    m_Data.Add(new DispCode("401469", "よしとみ内科クリニック", "福岡県"));
                    m_Data.Add(new DispCode("401489", "きしもとクリニック", "福岡県"));
                    m_Data.Add(new DispCode("401508", "粕屋南病院", "福岡県"));
                    m_Data.Add(new DispCode("401519", "古原医院", "福岡県"));
                    m_Data.Add(new DispCode("401529", "中野内科循環器科", "福岡県"));
                    m_Data.Add(new DispCode("401537", "大牟田市立病院", "福岡県"));
                    m_Data.Add(new DispCode("401549", "栗林皮膚泌尿器科医院", "福岡県"));
                    m_Data.Add(new DispCode("401559", "いふく内科", "福岡県"));
                    m_Data.Add(new DispCode("401568", "長田病院", "福岡県"));
                    m_Data.Add(new DispCode("401589", "やなせ内科医院", "福岡県"));
                    m_Data.Add(new DispCode("401599", "原三信病院附属呉服町腎クリニック", "福岡県"));
                    m_Data.Add(new DispCode("401604", "JCHO九州病院", "福岡県"));
                    m_Data.Add(new DispCode("401629", "むとう内科クリニック", "福岡県"));
                    m_Data.Add(new DispCode("401639", "飯塚腎クリニック", "福岡県"));
                    m_Data.Add(new DispCode("401649", "まじま内科循環器科", "福岡県"));
                    m_Data.Add(new DispCode("401658", "小波瀬病院", "福岡県"));
                    m_Data.Add(new DispCode("401668", "新行橋病院", "福岡県"));
                    m_Data.Add(new DispCode("401679", "吉祥寺クリニック", "福岡県"));
                    m_Data.Add(new DispCode("401689", "新古賀クリニック", "福岡県"));
                    m_Data.Add(new DispCode("401698", "岡部病院", "福岡県"));
                    m_Data.Add(new DispCode("401709", "大里腎クリニック", "福岡県"));
                    m_Data.Add(new DispCode("401718", "姫野病院", "福岡県"));
                    m_Data.Add(new DispCode("401728", "行橋中央病院", "福岡県"));
                    m_Data.Add(new DispCode("401739", "むらやま泌尿器科クリニック", "福岡県"));
                    m_Data.Add(new DispCode("401749", "あんどう泌尿器科クリニック", "福岡県"));
                    m_Data.Add(new DispCode("401758", "福岡新水巻病院", "福岡県"));
                    m_Data.Add(new DispCode("401768", "新生会病院", "福岡県"));
                    m_Data.Add(new DispCode("401778", "戸畑共立病院", "福岡県"));
                    m_Data.Add(new DispCode("401789", "伊都クリニック", "福岡県"));
                    m_Data.Add(new DispCode("401798", "原病院", "福岡県"));
                    m_Data.Add(new DispCode("401802", "福岡東医療センター", "福岡県"));
                    m_Data.Add(new DispCode("401819", "みぞぐち泌尿器科クリニック", "福岡県"));
                    m_Data.Add(new DispCode("401829", "上の原クリニック", "福岡県"));
                    m_Data.Add(new DispCode("401839", "たまき腎クリニック", "福岡県"));
                    m_Data.Add(new DispCode("401849", "赤間腎クリニック", "福岡県"));
                    m_Data.Add(new DispCode("401859", "宮崎内科循環器内科", "福岡県"));
                    m_Data.Add(new DispCode("401866", "九州労災病院　門司メディカルセンター", "福岡県"));
                    m_Data.Add(new DispCode("401879", "うすい内科・循環器科", "福岡県"));
                    m_Data.Add(new DispCode("401898", "頴田病院", "福岡県"));
                    m_Data.Add(new DispCode("401908", "福岡山王病院", "福岡県"));
                    m_Data.Add(new DispCode("401948", "村上華林堂病院", "福岡県"));
                    m_Data.Add(new DispCode("401959", "賀茂クリニック", "福岡県"));
                    m_Data.Add(new DispCode("401969", "池田バスキュラーアクセス・透析・内科", "福岡県"));
                    m_Data.Add(new DispCode("401989", "三愛クリニック", "福岡県"));
                    m_Data.Add(new DispCode("401998", "福岡和仁会病院", "福岡県"));
                    m_Data.Add(new DispCode("402009", "くるめ駅前クリニック", "福岡県"));
                    m_Data.Add(new DispCode("402029", "はせ川クリニック", "福岡県"));
                    m_Data.Add(new DispCode("402036", "九州中央病院", "福岡県"));
                    m_Data.Add(new DispCode("402049", "ひがしだクリニック", "福岡県"));
                    m_Data.Add(new DispCode("402058", "樋口病院", "福岡県"));
                    m_Data.Add(new DispCode("402069", "加野クリニック", "福岡県"));
                    m_Data.Add(new DispCode("402079", "ひびきクリニック", "福岡県"));
                    m_Data.Add(new DispCode("402089", "岡垣腎クリニック", "福岡県"));
                    m_Data.Add(new DispCode("402109", "野伏間クリニック", "福岡県"));
                    m_Data.Add(new DispCode("402118", "森都病院", "福岡県"));
                    m_Data.Add(new DispCode("402129", "みやまクリニック", "福岡県"));
                    m_Data.Add(new DispCode("402139", "福津中央クリニック", "福岡県"));
                    m_Data.Add(new DispCode("402149", "山下泌尿器科医院", "福岡県"));
                    m_Data.Add(new DispCode("402151", "福岡大学筑紫病院", "福岡県"));
                    m_Data.Add(new DispCode("402168", "聖マリアヘルスケアセンター", "福岡県"));
                    m_Data.Add(new DispCode("402174", "社会保険仲原病院", "福岡県"));
                    m_Data.Add(new DispCode("402188", "二日市徳洲会病院", "福岡県"));
                    m_Data.Add(new DispCode("402199", "桂川腎クリニック", "福岡県"));
                    m_Data.Add(new DispCode("402208", "宮田病院", "福岡県"));
                    m_Data.Add(new DispCode("402219", "天神オーバーナイト透析クリニック", "福岡県"));
                    m_Data.Add(new DispCode("402229", "新北九州腎臓クリニック", "福岡県"));
                    m_Data.Add(new DispCode("402239", "いとしま腎クリニック", "福岡県"));
                    m_Data.Add(new DispCode("402248", "飯塚記念病院", "福岡県"));
                    m_Data.Add(new DispCode("402258", "金隈病院", "福岡県"));
                    m_Data.Add(new DispCode("402269", "ほりた内科・透析クリニック", "福岡県"));
                    m_Data.Add(new DispCode("402279", "ほりクリニック", "福岡県"));
                    m_Data.Add(new DispCode("402289", "田村内科クリニック", "福岡県"));
                    m_Data.Add(new DispCode("402299", "ひろかわ腎クリニック", "福岡県"));
                    m_Data.Add(new DispCode("402308", "久留米南病院", "福岡県"));
                    m_Data.Add(new DispCode("402319", "福岡東ほばしらクリニック", "福岡県"));
                    m_Data.Add(new DispCode("402329", "福岡南透析クリニック", "福岡県"));
                    m_Data.Add(new DispCode("402338", "新古賀病院", "福岡県"));
                    m_Data.Add(new DispCode("402348", "福岡みらい病院", "福岡県"));
                    m_Data.Add(new DispCode("402359", "たかえ内科クリニック", "福岡県"));
                    m_Data.Add(new DispCode("402369", "藤沢内科・腎クリニック", "福岡県"));
                    m_Data.Add(new DispCode("402379", "楠本内科医院", "福岡県"));
                    m_Data.Add(new DispCode("407039", "チクゴ医院", "福岡県"));
                    m_Data.Add(new DispCode("407108", "西野病院", "福岡県"));
                    m_Data.Add(new DispCode("407259", "中村循環器科", "福岡県"));
                    m_Data.Add(new DispCode("407269", "後藤外科胃腸科医院", "福岡県"));
                    m_Data.Add(new DispCode("410013", "佐賀県医療センター好生館", "佐賀県"));
                    m_Data.Add(new DispCode("410028", "なゆたの森病院", "佐賀県"));
                    m_Data.Add(new DispCode("410039", "佐賀クリニック", "佐賀県"));
                    m_Data.Add(new DispCode("410049", "牧野医院", "佐賀県"));
                    m_Data.Add(new DispCode("410058", "藤﨑病院", "佐賀県"));
                    m_Data.Add(new DispCode("410063", "多久市立病院", "佐賀県"));
                    m_Data.Add(new DispCode("410078", "西田病院", "佐賀県"));
                    m_Data.Add(new DispCode("410088", "白石共立病院", "佐賀県"));
                    m_Data.Add(new DispCode("410098", "ふきあげ納富病院", "佐賀県"));
                    m_Data.Add(new DispCode("410109", "じんの内医院", "佐賀県"));
                    m_Data.Add(new DispCode("410120", "佐賀大学医学部附属病院", "佐賀県"));
                    m_Data.Add(new DispCode("410136", "唐津赤十字病院", "佐賀県"));
                    m_Data.Add(new DispCode("410159", "力武医院", "佐賀県"));
                    m_Data.Add(new DispCode("410168", "前田病院", "佐賀県"));
                    m_Data.Add(new DispCode("410179", "高原内科クリニック", "佐賀県"));
                    m_Data.Add(new DispCode("410189", "なばたけ冬野クリニック", "佐賀県"));
                    m_Data.Add(new DispCode("410199", "泌尿器科いまりクリニック", "佐賀県"));
                    m_Data.Add(new DispCode("410209", "岩本内科", "佐賀県"));
                    m_Data.Add(new DispCode("410219", "太田医院", "佐賀県"));
                    m_Data.Add(new DispCode("410229", "和田内科循環器科", "佐賀県"));
                    m_Data.Add(new DispCode("410239", "千葉内科循環器科", "佐賀県"));
                    m_Data.Add(new DispCode("410248", "諸隈病院", "佐賀県"));
                    m_Data.Add(new DispCode("410252", "嬉野医療センター", "佐賀県"));
                    m_Data.Add(new DispCode("410268", "もろどみ中央病院 ", "佐賀県"));
                    m_Data.Add(new DispCode("410279", "こばやしクリニック腎センター", "佐賀県"));
                    m_Data.Add(new DispCode("410288", "やよいがおか鹿毛病院", "佐賀県"));
                    m_Data.Add(new DispCode("410296", "済生会唐津病院", "佐賀県"));
                    m_Data.Add(new DispCode("410309", "横尾クリニック", "佐賀県"));
                    m_Data.Add(new DispCode("410319", "夢咲クリニック", "佐賀県"));
                    m_Data.Add(new DispCode("410329", "栄町クリニック", "佐賀県"));
                    m_Data.Add(new DispCode("410339", "きやま鹿毛医院", "佐賀県"));
                    m_Data.Add(new DispCode("410348", "今村病院", "佐賀県"));
                    m_Data.Add(new DispCode("410359", "ひらまつクリニック 透析センター", "佐賀県"));
                    m_Data.Add(new DispCode("410368", "新武雄病院", "佐賀県"));
                    m_Data.Add(new DispCode("410379", "みやき腎クリニック", "佐賀県"));
                    m_Data.Add(new DispCode("417038", "嬉野温泉病院", "佐賀県"));
                    m_Data.Add(new DispCode("417068", "佐賀市立富士大和温泉病院", "佐賀県"));
                    m_Data.Add(new DispCode("420010", "長崎大学病院", "長崎県"));
                    m_Data.Add(new DispCode("420043", "有川医療センター", "長崎県"));
                    m_Data.Add(new DispCode("420053", "長崎みなとメディカルセンター", "長崎県"));
                    m_Data.Add(new DispCode("420069", "浦クリニック", "長崎県"));
                    m_Data.Add(new DispCode("420079", "田中クリニック", "長崎県"));
                    m_Data.Add(new DispCode("420089", "徳永泌尿器科医院", "長崎県"));
                    m_Data.Add(new DispCode("420108", "光晴会病院", "長崎県"));
                    m_Data.Add(new DispCode("420118", "佐世保中央病院", "長崎県"));
                    m_Data.Add(new DispCode("420123", "佐世保市総合医療センター", "長崎県"));
                    m_Data.Add(new DispCode("420149", "川冨内科医院", "長崎県"));
                    m_Data.Add(new DispCode("420159", "前田医院", "長崎県"));
                    m_Data.Add(new DispCode("420164", "JCHO諫早総合病院", "長崎県"));
                    m_Data.Add(new DispCode("420172", "長崎医療センター", "長崎県"));
                    m_Data.Add(new DispCode("420189", "黒木医院", "長崎県"));
                    m_Data.Add(new DispCode("420198", "柿添病院", "長崎県"));
                    m_Data.Add(new DispCode("420209", "泌尿器科皮ふ科菅医院", "長崎県"));
                    m_Data.Add(new DispCode("420218", "大石共立病院", "長崎県"));
                    m_Data.Add(new DispCode("420239", "さかぐち泌尿器科医院", "長崎県"));
                    m_Data.Add(new DispCode("420249", "品川内科医院", "長崎県"));
                    m_Data.Add(new DispCode("420259", "原口医院", "長崎県"));
                    m_Data.Add(new DispCode("420263", "市立大村市民病院", "長崎県"));
                    m_Data.Add(new DispCode("420273", "長崎県対馬病院", "長崎県"));
                    m_Data.Add(new DispCode("420289", "宮崎医院", "長崎県"));
                    m_Data.Add(new DispCode("420293", "北松中央病院", "長崎県"));
                    m_Data.Add(new DispCode("420303", "長崎県上対馬病院", "長崎県"));
                    m_Data.Add(new DispCode("420328", "千住病院", "長崎県"));
                    m_Data.Add(new DispCode("420338", "青洲会病院", "長崎県"));
                    m_Data.Add(new DispCode("420348", "長崎腎病院", "長崎県"));
                    m_Data.Add(new DispCode("420359", "東長崎皮膚科泌尿器科医院", "長崎県"));
                    m_Data.Add(new DispCode("420368", "聖フランシスコ病院", "長崎県"));
                    m_Data.Add(new DispCode("420388", "長崎北徳洲会病院", "長崎県"));
                    m_Data.Add(new DispCode("420393", "長崎県五島中央病院", "長崎県"));
                    m_Data.Add(new DispCode("420409", "横山内科医院", "長崎県"));
                    m_Data.Add(new DispCode("420416", "佐世保共済病院", "長崎県"));
                    m_Data.Add(new DispCode("420424", "松浦中央病院", "長崎県"));
                    m_Data.Add(new DispCode("420438", "赤木病院", "長崎県"));
                    m_Data.Add(new DispCode("420449", "平井内科医院", "長崎県"));
                    m_Data.Add(new DispCode("420459", "まつお内科医院", "長崎県"));
                    m_Data.Add(new DispCode("420469", "城代医院", "長崎県"));
                    m_Data.Add(new DispCode("420498", "虹が丘病院", "長崎県"));
                    m_Data.Add(new DispCode("420503", "国民健康保険平戸市民病院", "長崎県"));
                    m_Data.Add(new DispCode("420519", "広瀬クリニック", "長崎県"));
                    m_Data.Add(new DispCode("420529", "しもまえ泌尿器科クリニック", "長崎県"));
                    m_Data.Add(new DispCode("420538", "上戸町病院", "長崎県"));
                    m_Data.Add(new DispCode("420549", "たかさご腎クリニック", "長崎県"));
                    m_Data.Add(new DispCode("420559", "新里クリニック浦上", "長崎県"));
                    m_Data.Add(new DispCode("420568", "泉川病院", "長崎県"));
                    m_Data.Add(new DispCode("420578", "井上病院", "長崎県"));
                    m_Data.Add(new DispCode("420588", "和仁会病院", "長崎県"));
                    m_Data.Add(new DispCode("420593", "長崎県上五島病院", "長崎県"));
                    m_Data.Add(new DispCode("420609", "くすもと内科クリニック", "長崎県"));
                    m_Data.Add(new DispCode("420628", "ニュー琴海病院", "長崎県"));
                    m_Data.Add(new DispCode("420638", "波佐見病院", "長崎県"));
                    m_Data.Add(new DispCode("420659", "長崎腎クリニック", "長崎県"));
                    m_Data.Add(new DispCode("420669", "すみれ腎クリニック", "長崎県"));
                    m_Data.Add(new DispCode("420676", "済生会長崎病院", "長崎県"));
                    m_Data.Add(new DispCode("420688", "宮崎病院", "長崎県"));
                    m_Data.Add(new DispCode("420698", "新生病院", "長崎県"));
                    m_Data.Add(new DispCode("420709", "宮崎内科医院", "長崎県"));
                    m_Data.Add(new DispCode("420749", "大村腎クリニック", "長崎県"));
                    m_Data.Add(new DispCode("420759", "八木原わたなべクリニック", "長崎県"));
                    m_Data.Add(new DispCode("420763", "公立小浜温泉病院", "長崎県"));
                    m_Data.Add(new DispCode("427013", "富江病院", "長崎県"));
                    m_Data.Add(new DispCode("427053", "長崎県五島中央病院附属診療所奈留医療センター", "長崎県"));
                    m_Data.Add(new DispCode("427113", "長崎県壱岐病院", "長崎県"));
                    m_Data.Add(new DispCode("430026", "済生会熊本病院", "熊本県"));
                    m_Data.Add(new DispCode("430046", "熊本中央病院", "熊本県"));
                    m_Data.Add(new DispCode("430078", "熊本泌尿器科病院", "熊本県"));
                    m_Data.Add(new DispCode("430088", "嶋田病院", "熊本県"));
                    m_Data.Add(new DispCode("430109", "健軍クリニック", "熊本県"));
                    m_Data.Add(new DispCode("430119", "上村内科クリニック", "熊本県"));
                    m_Data.Add(new DispCode("430128", "九州記念病院", "熊本県"));
                    m_Data.Add(new DispCode("430139", "内科熊本クリニック", "熊本県"));
                    m_Data.Add(new DispCode("430144", "JCHO熊本総合病院", "熊本県"));
                    m_Data.Add(new DispCode("430159", "仁誠会クリニック人吉", "熊本県"));
                    m_Data.Add(new DispCode("430163", "荒尾市立有明医療センター", "熊本県"));
                    m_Data.Add(new DispCode("430173", "国保水俣市立総合医療センター", "熊本県"));
                    m_Data.Add(new DispCode("430198", "天草第一病院", "熊本県"));
                    m_Data.Add(new DispCode("430208", "山鹿中央病院", "熊本県"));
                    m_Data.Add(new DispCode("430218", "間部病院", "熊本県"));
                    m_Data.Add(new DispCode("430222", "熊本医療センター", "熊本県"));
                    m_Data.Add(new DispCode("430249", "大手町腎・高血圧クリニック", "熊本県"));
                    m_Data.Add(new DispCode("430259", "あけぼのクリニック", "熊本県"));
                    m_Data.Add(new DispCode("430289", "右田クリニック", "熊本県"));
                    m_Data.Add(new DispCode("430319", "宇土中央クリニック", "熊本県"));
                    m_Data.Add(new DispCode("430326", "熊本赤十字病院", "熊本県"));
                    m_Data.Add(new DispCode("430333", "天草市立牛深市民病院", "熊本県"));
                    m_Data.Add(new DispCode("430343", "上天草総合病院", "熊本県"));
                    m_Data.Add(new DispCode("430358", "阿蘇立野病院", "熊本県"));
                    m_Data.Add(new DispCode("430368", "江南病院", "熊本県"));
                    m_Data.Add(new DispCode("430379", "医療法人愛生会（外山内科・愛生記念病院）", "熊本県"));
                    m_Data.Add(new DispCode("430389", "仁誠会クリニック黒髪", "熊本県"));
                    m_Data.Add(new DispCode("430392", "国立療養所菊池恵楓園", "熊本県"));
                    m_Data.Add(new DispCode("430409", "荒尾クリニック", "熊本県"));
                    m_Data.Add(new DispCode("430419", "松岡内科クリニック", "熊本県"));
                    m_Data.Add(new DispCode("430429", "玉名第一クリニック", "熊本県"));
                    m_Data.Add(new DispCode("430434", "菊池郡市医師会立病院", "熊本県"));
                    m_Data.Add(new DispCode("430448", "鶴田病院", "熊本県"));
                    m_Data.Add(new DispCode("430458", "宇城総合病院", "熊本県"));
                    m_Data.Add(new DispCode("430460", "熊本大学病院", "熊本県"));
                    m_Data.Add(new DispCode("430473", "くまもと県北病院", "熊本県"));
                    m_Data.Add(new DispCode("430498", "陣内病院", "熊本県"));
                    m_Data.Add(new DispCode("430508", "西日本病院", "熊本県"));
                    m_Data.Add(new DispCode("430519", "保元内科クリニック", "熊本県"));
                    m_Data.Add(new DispCode("430527", "くまもと森都総合病院", "熊本県"));
                    m_Data.Add(new DispCode("430539", "桑原クリニック", "熊本県"));
                    m_Data.Add(new DispCode("430549", "平山泌尿器科医院", "熊本県"));
                    m_Data.Add(new DispCode("430569", "仁誠会クリニック大津", "熊本県"));
                    m_Data.Add(new DispCode("430573", "球磨郡公立多良木病院", "熊本県"));
                    m_Data.Add(new DispCode("430588", "阿蘇温泉病院", "熊本県"));
                    m_Data.Add(new DispCode("430599", "玉名泌尿器科クリニック", "熊本県"));
                    m_Data.Add(new DispCode("430609", "てらさきクリニック", "熊本県"));
                    m_Data.Add(new DispCode("430629", "仁誠会クリニック新屋敷", "熊本県"));
                    m_Data.Add(new DispCode("430643", "阿蘇医療センター", "熊本県"));
                    m_Data.Add(new DispCode("430669", "あけぼの第２クリニック", "熊本県"));
                    m_Data.Add(new DispCode("430679", "中野クリニック", "熊本県"));
                    m_Data.Add(new DispCode("430688", "堤病院", "熊本県"));
                    m_Data.Add(new DispCode("430699", "松本医院", "熊本県"));
                    m_Data.Add(new DispCode("430709", "緑ヶ丘クリニック", "熊本県"));
                    m_Data.Add(new DispCode("430719", "大矢野クリニック", "熊本県"));
                    m_Data.Add(new DispCode("430723", "熊本市民病院 透析室", "熊本県"));
                    m_Data.Add(new DispCode("430739", "仁誠会クリニックながみね", "熊本県"));
                    m_Data.Add(new DispCode("430749", "坂梨ハートクリニック", "熊本県"));
                    m_Data.Add(new DispCode("430759", "ひらやまクリニック", "熊本県"));
                    m_Data.Add(new DispCode("430789", "うきクリニック", "熊本県"));
                    m_Data.Add(new DispCode("430797", "朝日野総合病院", "熊本県"));
                    m_Data.Add(new DispCode("430809", "中央仁クリニック", "熊本県"));
                    m_Data.Add(new DispCode("430819", "武内医院", "熊本県"));
                    m_Data.Add(new DispCode("430829", "七浦てらさきクリニック", "熊本県"));
                    m_Data.Add(new DispCode("430839", "日置町クリニック", "熊本県"));
                    m_Data.Add(new DispCode("430849", "嘉島クリニック", "熊本県"));
                    m_Data.Add(new DispCode("430858", "益城中央病院", "熊本県"));
                    m_Data.Add(new DispCode("430868", "天草慈恵病院", "熊本県"));
                    m_Data.Add(new DispCode("430878", "荒尾中央病院", "熊本県"));
                    m_Data.Add(new DispCode("430889", "中村内科医院", "熊本県"));
                    m_Data.Add(new DispCode("430899", "仁誠会クリニック光の森", "熊本県"));
                    m_Data.Add(new DispCode("430929", "永芳医院", "熊本県"));
                    m_Data.Add(new DispCode("430933", "山都町包括医療センターそよう病院", "熊本県"));
                    m_Data.Add(new DispCode("430948", "矢部広域病院", "熊本県"));
                    m_Data.Add(new DispCode("430958", "くわみず病院", "熊本県"));
                    m_Data.Add(new DispCode("430969", "良町ふくしまクリニック", "熊本県"));
                    m_Data.Add(new DispCode("430978", "桜十字病院", "熊本県"));
                    m_Data.Add(new DispCode("430998", "桜十字熊本宇城病院", "熊本県"));
                    m_Data.Add(new DispCode("431008", "阿梨花病院大津", "熊本県"));
                    m_Data.Add(new DispCode("431018", "さくら病院", "熊本県"));
                    m_Data.Add(new DispCode("431028", "熊本リハビリテーション病院", "熊本県"));
                    m_Data.Add(new DispCode("437019", "宮本内科医院", "熊本県"));
                    m_Data.Add(new DispCode("437039", "武藤泌尿器科クリニック", "熊本県"));
                    m_Data.Add(new DispCode("437069", "植木いまふじクリニック", "熊本県"));
                    m_Data.Add(new DispCode("437108", "瀬戸病院", "熊本県"));
                    m_Data.Add(new DispCode("437159", "みどりかわクリニック", "熊本県"));
                    m_Data.Add(new DispCode("437184", "天草地域医療センター", "熊本県"));
                    m_Data.Add(new DispCode("437199", "鏡クリニック", "熊本県"));
                    m_Data.Add(new DispCode("437219", "まえはら泌尿器科クリニック", "熊本県"));
                    m_Data.Add(new DispCode("437238", "水俣協立病院", "熊本県"));
                    m_Data.Add(new DispCode("437259", "くまもと江津湖療育医療センター", "熊本県"));
                    m_Data.Add(new DispCode("437269", "大塚泌尿器科クリニック", "熊本県"));
                    m_Data.Add(new DispCode("440013", "大分県立病院", "大分県"));
                    m_Data.Add(new DispCode("440038", "塚川第一病院", "大分県"));
                    m_Data.Add(new DispCode("440050", "大分大学医学部附属病院", "大分県"));
                    m_Data.Add(new DispCode("440074", "アルメイダ病院", "大分県"));
                    m_Data.Add(new DispCode("440089", "松山医院大分腎臓内科", "大分県"));
                    m_Data.Add(new DispCode("440092", "別府医療センター", "大分県"));
                    m_Data.Add(new DispCode("440108", "児玉病院", "大分県"));
                    m_Data.Add(new DispCode("440119", "国東循環器クリニック", "大分県"));
                    m_Data.Add(new DispCode("440129", "宗像医院", "大分県"));
                    m_Data.Add(new DispCode("440138", "村上記念病院", "大分県"));
                    m_Data.Add(new DispCode("440148", "梶原病院", "大分県"));
                    m_Data.Add(new DispCode("440158", "日田中央病院", "大分県"));
                    m_Data.Add(new DispCode("440164", "南海医療センター", "大分県"));
                    m_Data.Add(new DispCode("440178", "西田病院", "大分県"));
                    m_Data.Add(new DispCode("440189", "賀来内科医院", "大分県"));
                    m_Data.Add(new DispCode("440193", "国東市民病院", "大分県"));
                    m_Data.Add(new DispCode("440218", "大分中村病院", "大分県"));
                    m_Data.Add(new DispCode("440228", "清瀬病院", "大分県"));
                    m_Data.Add(new DispCode("440269", "中川泌尿器科医院", "大分県"));
                    m_Data.Add(new DispCode("440278", "仁医会病院", "大分県"));
                    m_Data.Add(new DispCode("440289", "大分内科クリニック", "大分県"));
                    m_Data.Add(new DispCode("440298", "福島病院", "大分県"));
                    m_Data.Add(new DispCode("440308", "大分記念病院", "大分県"));
                    m_Data.Add(new DispCode("440318", "別府中央病院", "大分県"));
                    m_Data.Add(new DispCode("440325", "鶴見病院", "大分県"));
                    m_Data.Add(new DispCode("440342", "大分医療センター", "大分県"));
                    m_Data.Add(new DispCode("440368", "諏訪の杜病院", "大分県"));
                    m_Data.Add(new DispCode("440379", "三好内科循環器科医院", "大分県"));
                    m_Data.Add(new DispCode("440388", "中村病院", "大分県"));
                    m_Data.Add(new DispCode("440399", "松本内科循環器科クリニック", "大分県"));
                    m_Data.Add(new DispCode("440419", "玄々堂泌尿器科", "大分県"));
                    m_Data.Add(new DispCode("440429", "杵築泌尿器科クリニック", "大分県"));
                    m_Data.Add(new DispCode("440439", "織部泌尿器科", "大分県"));
                    m_Data.Add(new DispCode("440448", "高田中央病院", "大分県"));
                    m_Data.Add(new DispCode("440459", "竹田クリニック", "大分県"));
                    m_Data.Add(new DispCode("440469", "岩男医院", "大分県"));
                    m_Data.Add(new DispCode("440476", "大分赤十字病院", "大分県"));
                    m_Data.Add(new DispCode("440499", "たかはし泌尿器科", "大分県"));
                    m_Data.Add(new DispCode("440508", "佐賀関病院", "大分県"));
                    m_Data.Add(new DispCode("440518", "中津第一病院", "大分県"));
                    m_Data.Add(new DispCode("440528", "大分循環器病院", "大分県"));
                    m_Data.Add(new DispCode("440538", "あおぞら病院", "大分県"));
                    m_Data.Add(new DispCode("440549", "こうまつ循環器科内科クリニック", "大分県"));
                    m_Data.Add(new DispCode("440554", "津久見中央病院", "大分県"));
                    m_Data.Add(new DispCode("440569", "松岡メディカルクリニック", "大分県"));
                    m_Data.Add(new DispCode("440576", "大分県済生会日田病院", "大分県"));
                    m_Data.Add(new DispCode("440588", "へつぎ病院", "大分県"));
                    m_Data.Add(new DispCode("440598", "大分三愛メディカルセンター", "大分県"));
                    m_Data.Add(new DispCode("440609", "メープル尽クリニック", "大分県"));
                    m_Data.Add(new DispCode("440613", "杵築市立山香病院", "大分県"));
                    m_Data.Add(new DispCode("440628", "鈴木病院", "大分県"));
                    m_Data.Add(new DispCode("440638", "大分岡病院", "大分県"));
                    m_Data.Add(new DispCode("440649", "うすきメディカルクリニック", "大分県"));
                    m_Data.Add(new DispCode("440659", "つつみ泌尿器科医院", "大分県"));
                    m_Data.Add(new DispCode("440669", "星野泌尿器科医院", "大分県"));
                    m_Data.Add(new DispCode("440678", "みえ病院", "大分県"));
                    m_Data.Add(new DispCode("440698", "玄々堂高田病院", "大分県"));
                    m_Data.Add(new DispCode("440708", "杵築中央病院", "大分県"));
                    m_Data.Add(new DispCode("440718", "臼杵病院", "大分県"));
                    m_Data.Add(new DispCode("440723", "中津市立中津市民病院", "大分県"));
                    m_Data.Add(new DispCode("447039", "土生医院", "大分県"));
                    m_Data.Add(new DispCode("447048", "御手洗病院", "大分県"));
                    m_Data.Add(new DispCode("447069", "友成医院", "大分県"));
                    m_Data.Add(new DispCode("447079", "くぼたクリニック", "大分県"));
                    m_Data.Add(new DispCode("447098", "小深田消化器病院", "大分県"));
                    m_Data.Add(new DispCode("447269", "姫島村国民健康保険診療所", "大分県"));
                    m_Data.Add(new DispCode("447273", "豊後大野市民病院", "大分県"));
                    m_Data.Add(new DispCode("447339", "かさぎ泌尿器科医院", "大分県"));
                    m_Data.Add(new DispCode("447349", "椎迫泌尿器科", "大分県"));
                    m_Data.Add(new DispCode("450014", "宮崎江南病院", "宮崎県"));
                    m_Data.Add(new DispCode("450023", "宮崎県立宮崎病院", "宮崎県"));
                    m_Data.Add(new DispCode("450052", "都城医療センター", "宮崎県"));
                    m_Data.Add(new DispCode("450068", "横山病院", "宮崎県"));
                    m_Data.Add(new DispCode("450073", "宮崎県立延岡病院", "宮崎県"));
                    m_Data.Add(new DispCode("450099", "和田クリニック", "宮崎県"));
                    m_Data.Add(new DispCode("450109", "京町共立クリニック", "宮崎県"));
                    m_Data.Add(new DispCode("450120", "宮崎大学医学部附属病院", "宮崎県"));
                    m_Data.Add(new DispCode("450159", "速見泌尿器科医院", "宮崎県"));
                    m_Data.Add(new DispCode("450163", "宮崎県立日南病院", "宮崎県"));
                    m_Data.Add(new DispCode("450179", "中山医院", "宮崎県"));
                    m_Data.Add(new DispCode("450203", "串間市民病院", "宮崎県"));
                    m_Data.Add(new DispCode("450227", "古賀総合病院", "宮崎県"));
                    m_Data.Add(new DispCode("450239", "長沼医院", "宮崎県"));
                    m_Data.Add(new DispCode("450269", "松岡内科医院", "宮崎県"));
                    m_Data.Add(new DispCode("450299", "みのだ泌尿器科医院", "宮崎県"));
                    m_Data.Add(new DispCode("450339", "延岡クリニック", "宮崎県"));
                    m_Data.Add(new DispCode("450359", "海老原内科", "宮崎県"));
                    m_Data.Add(new DispCode("450369", "清風会クリニック", "宮崎県"));
                    m_Data.Add(new DispCode("450373", "高千穂町国民健康保険病院", "宮崎県"));
                    m_Data.Add(new DispCode("450389", "上原内科", "宮崎県"));
                    m_Data.Add(new DispCode("450398", "池井病院", "宮崎県"));
                    m_Data.Add(new DispCode("450409", "みやた内科医院", "宮崎県"));
                    m_Data.Add(new DispCode("450419", "田中隆内科", "宮崎県"));
                    m_Data.Add(new DispCode("450429", "なかむら内科循環器内科", "宮崎県"));
                    m_Data.Add(new DispCode("450439", "黒木内科医院", "宮崎県"));
                    m_Data.Add(new DispCode("450448", "藤元総合病院", "宮崎県"));
                    m_Data.Add(new DispCode("450459", "内田医院", "宮崎県"));
                    m_Data.Add(new DispCode("450468", "千代田病院", "宮崎県"));
                    m_Data.Add(new DispCode("450479", "海老原クリニック", "宮崎県"));
                    m_Data.Add(new DispCode("450483", "小林市立病院", "宮崎県"));
                    m_Data.Add(new DispCode("450529", "山下医院", "宮崎県"));
                    m_Data.Add(new DispCode("450539", "上野医院", "宮崎県"));
                    m_Data.Add(new DispCode("450549", "森山内科・脳神経外科", "宮崎県"));
                    m_Data.Add(new DispCode("450559", "横田内科", "宮崎県"));
                    m_Data.Add(new DispCode("450579", "あそう内科", "宮崎県"));
                    m_Data.Add(new DispCode("450589", "ふくだ泌尿器科", "宮崎県"));
                    m_Data.Add(new DispCode("450599", "おがわクリニック", "宮崎県"));
                    m_Data.Add(new DispCode("450609", "盛田内科クリニック", "宮崎県"));
                    m_Data.Add(new DispCode("450619", "家村内科", "宮崎県"));
                    m_Data.Add(new DispCode("450629", "ひろせみらいクリニック", "宮崎県"));
                    m_Data.Add(new DispCode("450633", "美郷町国民健康保険西郷病院", "宮崎県"));
                    m_Data.Add(new DispCode("450648", "野尻中央病院", "宮崎県"));
                    m_Data.Add(new DispCode("450659", "東内科クリニック", "宮崎県"));
                    m_Data.Add(new DispCode("450669", "さわの内科クリニック", "宮崎県"));
                    m_Data.Add(new DispCode("450679", "おおぬきクリニック", "宮崎県"));
                    m_Data.Add(new DispCode("450689", "戸倉医院", "宮崎県"));
                    m_Data.Add(new DispCode("450698", "平和台病院", "宮崎県"));
                    m_Data.Add(new DispCode("450709", "小林泌尿器科クリニック", "宮崎県"));
                    m_Data.Add(new DispCode("450717", "海老原総合病院", "宮崎県"));
                    m_Data.Add(new DispCode("450738", "川南病院", "宮崎県"));
                    m_Data.Add(new DispCode("450749", "森のクリニック", "宮崎県"));
                    m_Data.Add(new DispCode("450779", "落合内科", "宮崎県"));
                    m_Data.Add(new DispCode("450789", "アイレＨＤクリニック", "宮崎県"));
                    m_Data.Add(new DispCode("450798", "メディカルシティ東部病院", "宮崎県"));
                    m_Data.Add(new DispCode("450808", "鶴田病院", "宮崎県"));
                    m_Data.Add(new DispCode("451089", "御城方じんクリニック", "宮崎県"));
                    m_Data.Add(new DispCode("451099", "ふくどめクリニック", "宮崎県"));
                    m_Data.Add(new DispCode("451109", "南宮崎ヤマモト腎泌尿器科", "宮崎県"));
                    m_Data.Add(new DispCode("451119", "宮崎中央ふかお透析内科クリニック", "宮崎県"));
                    m_Data.Add(new DispCode("451128", "都城明生病院", "宮崎県"));
                    m_Data.Add(new DispCode("451135", "宮崎生協病院", "宮崎県"));
                    m_Data.Add(new DispCode("457048", "和田病院", "宮崎県"));
                    m_Data.Add(new DispCode("457148", "春光会記念病院", "宮崎県"));
                    m_Data.Add(new DispCode("457159", "陽愛ファミリークリニック", "宮崎県"));
                    m_Data.Add(new DispCode("460010", "鹿児島大学病院", "鹿児島県"));
                    m_Data.Add(new DispCode("460043", "鹿児島市立病院", "鹿児島県"));
                    m_Data.Add(new DispCode("460056", "南風病院", "鹿児島県"));
                    m_Data.Add(new DispCode("460066", "済生会鹿児島病院", "鹿児島県"));
                    m_Data.Add(new DispCode("460078", "白石病院", "鹿児島県"));
                    m_Data.Add(new DispCode("460117", "今村総合病院", "鹿児島県"));
                    m_Data.Add(new DispCode("460128", "キラメキテラスヘルスケアホスピタル", "鹿児島県"));
                    m_Data.Add(new DispCode("460158", "サザン・リージョン病院", "鹿児島県"));
                    m_Data.Add(new DispCode("460163", "鹿児島県立薩南病院", "鹿児島県"));
                    m_Data.Add(new DispCode("460188", "高原病院", "鹿児島県"));
                    m_Data.Add(new DispCode("460239", "前田内科クリニック", "鹿児島県"));
                    m_Data.Add(new DispCode("460248", "池田病院", "鹿児島県"));
                    m_Data.Add(new DispCode("460258", "内山病院", "鹿児島県"));
                    m_Data.Add(new DispCode("460268", "種子島医療センター", "鹿児島県"));
                    m_Data.Add(new DispCode("460278", "小原病院", "鹿児島県"));
                    m_Data.Add(new DispCode("460288", "宮上病院", "鹿児島県"));
                    m_Data.Add(new DispCode("460298", "寺田病院", "鹿児島県"));
                    m_Data.Add(new DispCode("460338", "上山病院", "鹿児島県"));
                    m_Data.Add(new DispCode("460346", "済生会川内病院", "鹿児島県"));
                    m_Data.Add(new DispCode("460355", "総合病院鹿児島生協病院", "鹿児島県"));
                    m_Data.Add(new DispCode("460369", "藤井クリニック", "鹿児島県"));
                    m_Data.Add(new DispCode("460379", "坂元内科", "鹿児島県"));
                    m_Data.Add(new DispCode("460413", "鹿児島県立大島病院", "鹿児島県"));
                    m_Data.Add(new DispCode("460428", "加治木温泉病院", "鹿児島県"));
                    m_Data.Add(new DispCode("460455", "国分生協病院", "鹿児島県"));
                    m_Data.Add(new DispCode("460468", "国分中央病院", "鹿児島県"));
                    m_Data.Add(new DispCode("460498", "鹿児島徳洲会病院", "鹿児島県"));
                    m_Data.Add(new DispCode("460509", "上村内科クリニック", "鹿児島県"));
                    m_Data.Add(new DispCode("460519", "森田内科医院", "鹿児島県"));
                    m_Data.Add(new DispCode("460528", "大隅鹿屋病院", "鹿児島県"));
                    m_Data.Add(new DispCode("460549", "小緑内科", "鹿児島県"));
                    m_Data.Add(new DispCode("460559", "島田泌尿器科医院", "鹿児島県"));
                    m_Data.Add(new DispCode("460569", "尾田内科胃腸科", "鹿児島県"));
                    m_Data.Add(new DispCode("460593", "垂水市立医療センター垂水中央病院", "鹿児島県"));
                    m_Data.Add(new DispCode("460604", "肝属郡医師会立病院", "鹿児島県"));
                    m_Data.Add(new DispCode("460619", "おばま医院", "鹿児島県"));
                    m_Data.Add(new DispCode("460629", "じんごあん整形外科内科クリニック", "鹿児島県"));
                    m_Data.Add(new DispCode("460639", "外山内科クリニック", "鹿児島県"));
                    m_Data.Add(new DispCode("460649", "伊東クリニック", "鹿児島県"));
                    m_Data.Add(new DispCode("460659", "山下わたる内科", "鹿児島県"));
                    m_Data.Add(new DispCode("460669", "宮内クリニック", "鹿児島県"));
                    m_Data.Add(new DispCode("460698", "南さつま中央病院", "鹿児島県"));
                    m_Data.Add(new DispCode("460718", "屋久島徳洲会病院", "鹿児島県"));
                    m_Data.Add(new DispCode("460728", "喜界徳洲会病院", "鹿児島県"));
                    m_Data.Add(new DispCode("460739", "山川病院", "鹿児島県"));
                    m_Data.Add(new DispCode("460743", "出水総合医療センター", "鹿児島県"));
                    m_Data.Add(new DispCode("460759", "仁クリニック", "鹿児島県"));
                    m_Data.Add(new DispCode("460768", "水間病院", "鹿児島県"));
                    m_Data.Add(new DispCode("460779", "中種子クリニック", "鹿児島県"));
                    m_Data.Add(new DispCode("460789", "中山クリニック", "鹿児島県"));
                    m_Data.Add(new DispCode("460798", "南薩ケアほすぴたる", "鹿児島県"));
                    m_Data.Add(new DispCode("460808", "クオラリハビリテーション病院", "鹿児島県"));
                    m_Data.Add(new DispCode("460818", "社会医療法人天陽会中央病院", "鹿児島県"));
                    m_Data.Add(new DispCode("460828", "徳之島徳洲会病院", "鹿児島県"));
                    m_Data.Add(new DispCode("460835", "奄美中央病院", "鹿児島県"));
                    m_Data.Add(new DispCode("460848", "昭南病院", "鹿児島県"));
                    m_Data.Add(new DispCode("460869", "うるた内科", "鹿児島県"));
                    m_Data.Add(new DispCode("460878", "沖永良部徳洲会病院", "鹿児島県"));
                    m_Data.Add(new DispCode("460888", "名瀬徳洲会病院", "鹿児島県"));
                    m_Data.Add(new DispCode("460899", "加治木中央クリニック", "鹿児島県"));
                    m_Data.Add(new DispCode("460909", "大塚クリニック", "鹿児島県"));
                    m_Data.Add(new DispCode("460919", "うえぞの内科クリニック", "鹿児島県"));
                    m_Data.Add(new DispCode("460929", "たけクリニック", "鹿児島県"));
                    m_Data.Add(new DispCode("460949", "林泌尿器科クリニック", "鹿児島県"));
                    m_Data.Add(new DispCode("460969", "いまむらクリニック", "鹿児島県"));
                    m_Data.Add(new DispCode("460985", "谷山生協クリニック", "鹿児島県"));
                    m_Data.Add(new DispCode("460998", "財部記念病院", "鹿児島県"));
                    m_Data.Add(new DispCode("461008", "青雲会病院", "鹿児島県"));
                    m_Data.Add(new DispCode("461019", "ＳＫメディカルクリニック", "鹿児島県"));
                    m_Data.Add(new DispCode("461039", "まきのせ泌尿器科", "鹿児島県"));
                    m_Data.Add(new DispCode("461048", "笠利病院", "鹿児島県"));
                    m_Data.Add(new DispCode("461059", "うえやま腎クリニック", "鹿児島県"));
                    m_Data.Add(new DispCode("461069", "さくらやまクリニック", "鹿児島県"));
                    m_Data.Add(new DispCode("461078", "霧島桜ヶ丘病院", "鹿児島県"));
                    m_Data.Add(new DispCode("461109", "川内まきのせ泌尿器・腎クリニック", "鹿児島県"));
                    m_Data.Add(new DispCode("461112", "鹿児島医療センター", "鹿児島県"));
                    m_Data.Add(new DispCode("461125", "鹿児島県厚生連病院", "鹿児島県"));
                    m_Data.Add(new DispCode("461139", "谷山腎クリニック", "鹿児島県"));
                    m_Data.Add(new DispCode("467018", "生駒泌尿器科", "鹿児島県"));
                    m_Data.Add(new DispCode("467068", "与論徳洲会病院", "鹿児島県"));
                    m_Data.Add(new DispCode("467089", "白石記念クリニック", "鹿児島県"));
                    m_Data.Add(new DispCode("467119", "鹿屋ひ尿器科", "鹿児島県"));
                    m_Data.Add(new DispCode("467149", "たまいクリニック", "鹿児島県"));
                    m_Data.Add(new DispCode("467159", "川原腎泌尿器科クリニック", "鹿児島県"));
                    m_Data.Add(new DispCode("467189", "今村泌尿器科", "鹿児島県"));
                    m_Data.Add(new DispCode("467198", "薩摩川内市下甑手打診療所", "鹿児島県"));
                    m_Data.Add(new DispCode("467208", "にいむら病院", "鹿児島県"));
                    m_Data.Add(new DispCode("467308", "瀬戸内徳洲会病院", "鹿児島県"));
                    m_Data.Add(new DispCode("467379", "志布志中央クリニック", "鹿児島県"));
                    m_Data.Add(new DispCode("467429", "八木クリニック", "鹿児島県"));
                    m_Data.Add(new DispCode("467442", "指宿医療センター", "鹿児島県"));
                    m_Data.Add(new DispCode("467469", "よしだ泌尿器科クリニック", "鹿児島県"));
                    m_Data.Add(new DispCode("467483", "公立種子島病院", "鹿児島県"));
                    m_Data.Add(new DispCode("470010", "琉球大学病院", "沖縄県"));
                    m_Data.Add(new DispCode("470038", "大浜第一病院", "沖縄県"));
                    m_Data.Add(new DispCode("470043", "沖縄県立中部病院", "沖縄県"));
                    m_Data.Add(new DispCode("470068", "牧港中央病院", "沖縄県"));
                    m_Data.Add(new DispCode("470075", "とよみ生協病院", "沖縄県"));
                    m_Data.Add(new DispCode("470083", "沖縄県立北部病院", "沖縄県"));
                    m_Data.Add(new DispCode("470103", "那覇市立病院", "沖縄県"));
                    m_Data.Add(new DispCode("470127", "中頭病院", "沖縄県"));
                    m_Data.Add(new DispCode("470138", "沖縄第一病院", "沖縄県"));
                    m_Data.Add(new DispCode("470147", "浦添総合病院", "沖縄県"));
                    m_Data.Add(new DispCode("470153", "沖縄県立宮古病院", "沖縄県"));
                    m_Data.Add(new DispCode("470169", "平安山医院", "沖縄県"));
                    m_Data.Add(new DispCode("470178", "北上中央病院", "沖縄県"));
                    m_Data.Add(new DispCode("470189", "安立医院", "沖縄県"));
                    m_Data.Add(new DispCode("470193", "沖縄県立南部医療センター・こども医療センター", "沖縄県"));
                    m_Data.Add(new DispCode("470209", "よなは医院", "沖縄県"));
                    m_Data.Add(new DispCode("470238", "友愛医療センター", "沖縄県"));
                    m_Data.Add(new DispCode("470248", "中部徳洲会病院", "沖縄県"));
                    m_Data.Add(new DispCode("470258", "南部徳洲会病院", "沖縄県"));
                    m_Data.Add(new DispCode("470269", "池村内科医院", "沖縄県"));
                    m_Data.Add(new DispCode("470273", "沖縄県立八重山病院", "沖縄県"));
                    m_Data.Add(new DispCode("470299", "おおうらクリニック", "沖縄県"));
                    m_Data.Add(new DispCode("470308", "おもろまちメディカルセンター", "沖縄県"));
                    m_Data.Add(new DispCode("470319", "砂川内科医院", "沖縄県"));
                    m_Data.Add(new DispCode("470329", "とうま内科", "沖縄県"));
                    m_Data.Add(new DispCode("470338", "西崎病院", "沖縄県"));
                    m_Data.Add(new DispCode("470348", "ハートライフ病院", "沖縄県"));
                    m_Data.Add(new DispCode("470358", "与那原中央病院", "沖縄県"));
                    m_Data.Add(new DispCode("470369", "こくら台ハートクリニック", "沖縄県"));
                    m_Data.Add(new DispCode("470389", "川根内科外科血管外科クリニック", "沖縄県"));
                    m_Data.Add(new DispCode("470409", "うちま内科", "沖縄県"));
                    m_Data.Add(new DispCode("470419", "喜屋武内科クリニック", "沖縄県"));
                    m_Data.Add(new DispCode("470429", "赤嶺内科", "沖縄県"));
                    m_Data.Add(new DispCode("470434", "北部地区医師会病院", "沖縄県"));
                    m_Data.Add(new DispCode("470449", "徳山クリニック", "沖縄県"));
                    m_Data.Add(new DispCode("470459", "よみたんクリニック", "沖縄県"));
                    m_Data.Add(new DispCode("470469", "首里城下町クリニック第二", "沖縄県"));
                    m_Data.Add(new DispCode("470478", "海邦病院", "沖縄県"));
                    m_Data.Add(new DispCode("470483", "公立久米島病院", "沖縄県"));
                    m_Data.Add(new DispCode("470498", "同仁病院", "沖縄県"));
                    m_Data.Add(new DispCode("470509", "みのり内科クリニック", "沖縄県"));
                    m_Data.Add(new DispCode("470519", "北部山里クリニック", "沖縄県"));
                    m_Data.Add(new DispCode("470528", "石垣島徳洲会病院", "沖縄県"));
                    m_Data.Add(new DispCode("470535", "中部協同病院", "沖縄県"));
                    m_Data.Add(new DispCode("470549", "古堅南クリニック", "沖縄県"));
                    m_Data.Add(new DispCode("470558", "翔南病院", "沖縄県"));
                    m_Data.Add(new DispCode("470569", "ちゅら海クリニック", "沖縄県"));
                    m_Data.Add(new DispCode("470579", "すながわ内科クリニック", "沖縄県"));
                    m_Data.Add(new DispCode("470588", "豊見城中央病院", "沖縄県"));
                    m_Data.Add(new DispCode("470599", "吉クリニック", "沖縄県"));
                    m_Data.Add(new DispCode("470609", "かつれん内科クリニック", "沖縄県"));
                    m_Data.Add(new DispCode("470619", "みやざと内科クリニック", "沖縄県"));
                    m_Data.Add(new DispCode("470639", "うえず内科クリニック", "沖縄県"));
                    m_Data.Add(new DispCode("470649", "西平医院", "沖縄県"));
                    m_Data.Add(new DispCode("470659", "ちばなクリニック", "沖縄県"));
                    m_Data.Add(new DispCode("470669", "安木内科", "沖縄県"));
                    m_Data.Add(new DispCode("470678", "宮古島徳洲会病院", "沖縄県"));
                    m_Data.Add(new DispCode("470689", "たいようのクリニック", "沖縄県"));
                    m_Data.Add(new DispCode("470699", "まつおＴＣクリニック", "沖縄県"));
                    m_Data.Add(new DispCode("470719", "新都心クリニック", "沖縄県"));
                    m_Data.Add(new DispCode("470725", "沖縄協同病院", "沖縄県"));
                    m_Data.Add(new DispCode("470738", "沖縄寿光会与勝病院", "沖縄県"));
                    m_Data.Add(new DispCode("470749", "さくだ内科クリニック", "沖縄県"));
                    m_Data.Add(new DispCode("470759", "登川クリニック", "沖縄県"));
                    m_Data.Add(new DispCode("470766", "沖縄赤十字病院", "沖縄県"));
                    m_Data.Add(new DispCode("470778", "宮古島リハビリ温泉病院", "沖縄県"));
                    m_Data.Add(new DispCode("470789", "つかざん腎クリニック", "沖縄県"));
                    m_Data.Add(new DispCode("470809", "伊江村立診療所", "沖縄県"));
                    m_Data.Add(new DispCode("470819", "メディカルプラザ大道中央", "沖縄県"));
                    m_Data.Add(new DispCode("470829", "豊崎メディカルクリニック", "沖縄県"));
                    m_Data.Add(new DispCode("470839", "みやら内科クリニック", "沖縄県"));
                    m_Data.Add(new DispCode("477019", "那覇西クリニック", "沖縄県"));
                    m_Data.Add(new DispCode("477068", "与勝あやはしクリニック", "沖縄県"));
                }

                return m_Data;
            }
        }
    }
    #endregion

    #region 学会のバスキュラーアクセスコードリスト情報
    /// <summary>
    /// 学会のバスキュラーアクセスコードリスト情報
    /// </summary>
    internal static class MedicalVa
    {
        /// <summary>
        /// キャッシュ領域
        /// </summary>
        private static List<DispCode> m_Data = null;

        /// <summary>
        /// 学会のバスキュラーアクセスリストを取得
        /// </summary>
        internal static List<DispCode> Data
        {
            get
            {
                if (null == m_Data)
                {
                    // キャッシュ情報が無い場合はここで作成
                    m_Data = new List<DispCode>();

                    m_Data.Add(new DispCode("ZZ", "未該当"));
                    m_Data.Add(new DispCode("A", "自己血管による動静脈瘻（AVF）"));
                    m_Data.Add(new DispCode("B", "人工血管による動静脈瘻（AVG）"));
                    m_Data.Add(new DispCode("C", "表在化動脈（上腕動脈、大腿動脈等）"));
                    m_Data.Add(new DispCode("D", "動脈直接穿刺"));
                    m_Data.Add(new DispCode("E", "内頸静脈直接穿刺"));
                    m_Data.Add(new DispCode("F", "大腿静脈直接穿刺"));
                    m_Data.Add(new DispCode("G", "長期留置静脈カテーテル"));
                    m_Data.Add(new DispCode("H", "一時的静脈カテーテル"));
                    m_Data.Add(new DispCode("I", "その他"));
                    m_Data.Add(new DispCode("Z", "不明"));
                }

                return m_Data;
            }
        }
    }
    #endregion

}
