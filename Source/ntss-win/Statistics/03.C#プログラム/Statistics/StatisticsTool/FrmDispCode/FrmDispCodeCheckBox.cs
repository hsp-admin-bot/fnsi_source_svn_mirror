using System;
using System.Collections.Generic;
using System.Data;
using System.Drawing;
using System.Reflection;
using System.Threading.Tasks;
using System.Windows.Forms;
using Fnw.StatisticsTool.Csv;
using Fnw.StatisticsTool.Models;
using Fnw.StatisticsTool.Properties;
using NKKLoggingLib;

namespace Fnw.StatisticsTool.FrmDispCode
{
    enum CheckBoxType
    {
        /// <summary>なし</summary>
        NONE,
        /// <summary>糖尿病</summary>
        MST_DISEASE_DIABETES,
    }

    /// <summary>
    /// 選択設定画面
    /// </summary>
    public partial class FrmDispCodeCheckBox : StatisticsBase
    {
        #region プロパティ
        /// <summary>
        /// 選択設定の対象種別
        /// </summary>
        internal CheckBoxType EditType { get; set; }

        /// <summary>
        /// 選択設定内容を取得します。
        /// </summary>
        public DataTable DataCodeMatch { get; private set; }
        #endregion

        #region コンストラクタ
        /// <summary>
        /// 選択設定画面コンストラクタ
        /// </summary>
        public FrmDispCodeCheckBox() : base(isUserLoggedIn: true)
        {
            InitializeComponent();
            // 基底クラスのコンストラクタでイベント登録
            RegisterEvents(this);
            this.EditType = CheckBoxType.NONE;
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
                case CheckBoxType.MST_DISEASE_DIABETES:
                    this.Text = "糖尿病設定";
                    this.lblMessage.Text = "糖尿病に該当する病名を選択してください";
                    break;
            }

            // 候補データ作成
            DataTable dt = await MakeDataAsync();
            if (null == dt)
            {
                MessageBox.Show("データの生成に失敗しました", "データ生成エラー", MessageBoxButtons.OK, MessageBoxIcon.Stop);
                return;
            }

            // データバインド
            grdDispCodeList.DataSource = dt;
        }

        /// <summary>
        /// OKクリック
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnOK_Click(object sender, EventArgs e)
        {
            //
            DataTable csv = new DataTable();
            string code;
            string value;

            // 編集前の設定を取得(編集対象になっていない情報を保持し続けるために)
            switch (this.EditType)
            {
                case CheckBoxType.MST_DISEASE_DIABETES:
                    csv = FnwCsv.ReadSelectMstDiseaseDiabetesCsv();
                    code = FnwCsv.C_M_DIS_DIA1;
                    value = FnwCsv.C_M_DIS_DIA2;
                    break;
                default:
                    return;
            }

            for (int i = 0; i < grdDispCodeList.Rows.Count; i++)
            {
                // 対象行に合致する編集前設定を取得
                DataRow[] rows = csv.Select(code + " + '$$' = '" + grdDispCodeList[this.COL_FNW_CODE.Name, i].Value as string + "$$'");

                if (1 == rows.Length)
                {
                    // 設定済の場合は今回の選択結果で上書き
                    rows[0][value] = grdDispCodeList[this.COL_SELECT.Name, i].Value;
                }
                else
                {
                    // 未設定の項目はリストに追加
                    DataRow row = csv.NewRow();
                    row[code] = grdDispCodeList[this.COL_FNW_CODE.Name, i].Value;
                    row[value] = grdDispCodeList[this.COL_SELECT.Name, i].Value;
                    csv.Rows.Add(row);
                }
            }

            // 設定保存
            string path;
            switch (this.EditType)
            {
                case CheckBoxType.MST_DISEASE_DIABETES:
                    path = System.IO.Path.Combine(Settings.Default.PathCsv, Settings.Default.PathSelectMstDiseaseDiabetes);
                    break;
                default:
                    return;
            }

            // 保存
            if (FnwCsv.Write(path, csv))
            {
                // 2015年版対応（各処理の完了状態を表示する）
                ConfirmCompletionStatus(true);

                // 成功
                this.DialogResult = DialogResult.OK;
                this.Close();
            }
            else
            {
                // 失敗
                MessageBox.Show("設定の保存に失敗しました", "保存エラー", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }
        }
        #endregion

        #region 選択設定データ作成
        // 2015年度対応（マスタ設定・ログのプレビュー表示）
        /// <summary>
        /// 選択設定データ作成
        /// </summary>
        /// <returns>選択設定データ(null：エラー)</returns>
        public async Task<DataTable> MakeDataAsync()
        {
            DataTable dt = new DataTable();

            // バインド用カラムを作成
            dt.Columns.Add(this.COL_SELECT.Name);
            dt.Columns.Add(this.COL_FNW_CODE.Name);
            dt.Columns.Add(this.COL_FNW_NAME.Name);

            DiseaseDataResponse diseaseResult;
            DataTable dis;
            switch (this.EditType)
            {
                case CheckBoxType.MST_DISEASE_DIABETES:
                    // API 患者病名データ取得
                    var diseaseRequest = new SysDataSetRequest(
                        sqlCd: -1000005,
                        fromDate: Settings.Default.PeriodStart.ToString("yyyy/MM/dd"),
                        toDate: Settings.Default.PeriodEnd.ToString("yyyy/MM/dd")
                    );
                    diseaseResult = await StatisticsLib.GetDiseaseData(diseaseRequest);
                    List<DiseaseDataType> diseaseList = diseaseResult.Data;
                    // DataTableに変換
                    dis = StatisticsUtility.ConvertToDataTable(diseaseList, null);
                    if (null == dis)
                    {
                        return null;
                    }
                    break;
                default:
                    return null;
            }
            // 現状の設定を取得
            DataTable csv;

            switch (this.EditType)
            {
                case CheckBoxType.MST_DISEASE_DIABETES:
                    csv = FnwCsv.ReadSelectMstDiseaseDiabetesCsv();
                    break;
                default:
                    return null;
            }

            // 選択必要データ数分の処理
            for (int i = 0; i < dis.Rows.Count; i++)
            {
                DataRow row = dt.NewRow();

                // FNWデータはDBからの取得データをコピー
                row[this.COL_SELECT.Name] = 0;  //初期値
                row[this.COL_FNW_CODE.Name] = dis.Rows[i]["COL_FNW_CODE"];
                row[this.COL_FNW_NAME.Name] = dis.Rows[i]["COL_FNW_NAME"];

                // 選択設定済みデータを取得
                string code;
                string value;
                switch (this.EditType)
                {
                    case CheckBoxType.MST_DISEASE_DIABETES:
                        code = FnwCsv.C_M_DIS_DIA1;
                        value = FnwCsv.C_M_DIS_DIA2;
                        break;
                    default:
                        return null;
                }

                // 空白文字を無視するため後方に文字列を追加して完全一致させる
                DataRow[] work = csv.Select(code + " + '$$' = '" + row[this.COL_FNW_CODE.Name] as string + "$$'");

                // 選択設定済みデータがある事を確認
                if (1 == work.Length)
                {
                    // 設定済
                    row[this.COL_SELECT.Name] = work[0][value];
                }

                // 処理済行をバインドデータに追加
                dt.Rows.Add(row);
            }

            this.DataCodeMatch = dt;
            return dt;
        }
        #endregion
    }
}
