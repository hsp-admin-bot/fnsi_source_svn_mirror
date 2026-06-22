using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using Fnw.StatisticsTool.Csv;
using Fnw.StatisticsTool.FrmDispCode;
using Fnw.StatisticsTool.Models;
using Fnw.StatisticsTool.Properties;

namespace Fnw.StatisticsTool.FrmFnwCode
{

    #region 割当種類のenum定義
    /// <summary>
    /// 割当種類のenum定義
    /// </summary>
    enum FnwMatchType
    {
        /// <summary>なし</summary>
        NONE,
        /// <summary>感染症</summary>
        MST_INFECTION,
    }
    #endregion

    /// <summary>
    /// FNWコード割当画面
    /// </summary>
    public partial class FrmFnwCodeMatch : StatisticsBase
    {
        #region プロパティ
        /// <summary>
        /// 割当の対象種別
        /// </summary>
        internal FnwMatchType EditType { get; set; }

        /// <summary>
        /// 割り当て内容を取得します。
        /// </summary>
        public DataTable DataCodeMatch { get; private set; }
        #endregion

        #region コンストラクタ
        /// <summary>
        ///コンストラクタ
        /// </summary>
        public FrmFnwCodeMatch()
        {
            InitializeComponent();
            this.EditType = FnwMatchType.NONE;
        }
        #endregion

        #region イベント処理
        /// <summary>
        /// フォームロード
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private async void FrmFnwCodeMatch_Load(object sender, EventArgs e)
        {
            switch (this.EditType)
            {
                case FnwMatchType.MST_INFECTION:
                    this.Text = "感染症設定";
                    break;
            }
            DataTable dt =await this.MakeDataAsync();
            if (null == dt)
            {
                MessageBox.Show("データの生成に失敗しました", "データ生成エラー", MessageBoxButtons.OK, MessageBoxIcon.Stop);
                return;
            }
            // データバインド
            grdDispCodeList.DataSource = dt;
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
            dt.Columns.Add(this.COL_ITEM_CODE.Name);
            dt.Columns.Add(this.COL_ITEM_NAME.Name);
            dt.Columns.Add(this.COL_MATCH_CODE.Name);
            dt.Columns.Add(this.COL_MATCH_NAME.Name);
            dt.Columns.Add(this.COL_STATUS.Name);

            // 医学会コード設定
            List<DispCode> mst;

            switch (this.EditType)
            {
                case FnwMatchType.MST_INFECTION:
                    mst = InfectItem.Data;
                    break;
                default:
                    return null;
            }

            // マスタを取得
            var infectionRequest = new SysDataSetRequest(
                sqlCd: -1000026
            );
            InfectionDataResponse　infectionResult = await StatisticsLib.GetInfectionData(infectionRequest);
            List<InfectionDataType> infectionList = infectionResult.Data;
            // DataTableに変換
            DataTable fnw = StatisticsUtility.ConvertToDataTable(infectionList, null);
            if (null == fnw)
            {
                return null;
            }

            // 現状の設定を取得
            DataTable match = FnwCsv.ReadMatchMstInfectionCsv();

            // 割当必要データ数分の処理
            for (int i = 0; i < mst.Count; i++)
            {
                DataRow row = dt.NewRow();

                // FNWデータはDBからの取得データをコピー
                row[this.COL_ITEM_CODE.Name] = mst[i].Code;
                row[this.COL_ITEM_NAME.Name] = mst[i].Name;

                // 割当済みデータを取得
                // 空白文字を無視するため後方に文字列を追加して完全一致させる
                DataRow[] work = match.Select(FnwCsv.C_M_INF1 + " + '$$' = '" + mst[i].Code + "$$'");

                // 割当済みデータがある事を確認
                if ((1 == work.Length) && (false == string.IsNullOrEmpty(work[0][FnwCsv.C_M_INF2] as string)))
                {
                    // 設定済
                    row[this.COL_MATCH_CODE.Name] = work[0][FnwCsv.C_M_INF2];
                    row[this.COL_STATUS.Name] = StatisticsConst.ST_MATCH;
                }
                else
                {
                    // 未割当

                    // 自動割当候補を取得
                    DataRow auto = StaticFunctions.GetAutoMatch(row[this.COL_ITEM_NAME.Name] as string, fnw, "COL_FNW_NAME");

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

            this.DataCodeMatch = dt;

            return dt;
        }
        #endregion

        #region イベント処理
        /// <summary>
        /// バインド時処理
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void grdDispCodeList_DataBindingComplete(object sender, DataGridViewBindingCompleteEventArgs e)
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
        private async void grdDispCodeList_CellClick(object sender, DataGridViewCellEventArgs e)
        {
            if (this.COL_SELECT.Name == grdDispCodeList.Columns[e.ColumnIndex].Name)
            {
                await ProcEditAsync(e.RowIndex);
            }
        }

        /// <summary>
        /// セルのダブルクリック
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private async void grdDispCodeList_CellDoubleClick(object sender, DataGridViewCellEventArgs e)
        {
            if (this.COL_ORDER_CLASS.Name != grdDispCodeList.Columns[e.ColumnIndex].Name)
            {
                await ProcEditAsync(e.RowIndex);
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

            var infectionRequest = new SysDataSetRequest(
                sqlCd: -1000026
            );
            InfectionDataResponse infectionResult = await StatisticsLib.GetInfectionData(infectionRequest);
            List<InfectionDataType> infectionList = infectionResult.Data;
            // DataTableに変換
            DataTable dt = StatisticsUtility.ConvertToDataTable(infectionList, null);
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

            frm.SelectList = data;

            frm.TargetName = grdDispCodeList[this.COL_ITEM_NAME.Name, rowIndex].Value as string;

            // フリーワードのデフォルトに名称を設定
            // （フリーワードに検索用文字列を設定）
            string itemName = grdDispCodeList[this.COL_ITEM_NAME.Name, rowIndex].Value as string;
            if (!string.IsNullOrEmpty(itemName))
            {
                itemName = itemName.Replace(StatisticsConst.SUFFIX_BEFORE, String.Empty);
                itemName = itemName.Replace(StatisticsConst.SUFFIX_AFTER, String.Empty);
            }
            frm.DefaultFreeWord = itemName;

            // 選択画面表示
            if (DialogResult.OK == frm.ShowDialog())
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
            this.grdDispCodeList_DataBindingComplete(grdDispCodeList, null);
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
                    MessageBox.Show("未割当の情報があります。\r\n完了状態に出来ませんので未割当のマスタについて登録して下さい。", "未割当データあり", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                    status = false;
                    break;
                }
            }

            // 編集前の設定を取得(編集対象になっていない情報を保持し続けるために)
            DataTable match = FnwCsv.ReadMatchMstInfectionCsv();

            for (int i = 0; i < grdDispCodeList.Rows.Count; i++)
            {
                // 対象行に合致する編集前設定を取得
                DataRow[] rows = match.Select(FnwCsv.C_M_INF1 + " + '$$' = '" + grdDispCodeList[this.COL_ITEM_CODE.Name, i].Value as string + "$$'");

                if (1 == rows.Length)
                {
                    // 設定済の場合は今回の選択結果で上書き
                    rows[0][FnwCsv.C_M_INF2] = grdDispCodeList[this.COL_MATCH_CODE.Name, i].Value;
                }
                else
                {
                    // 未設定の項目はリストに追加
                    DataRow row = match.NewRow();
                    row[FnwCsv.C_M_INF1] = grdDispCodeList[this.COL_ITEM_CODE.Name, i].Value;
                    row[FnwCsv.C_M_INF2] = grdDispCodeList[this.COL_MATCH_CODE.Name, i].Value;
                    match.Rows.Add(row);
                }
            }

            // 保存
            if (FnwCsv.Write(System.IO.Path.Combine(Settings.Default.PathCsv, Settings.Default.PathMatchMstInfection), match))
            {
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
            else
            {
                // 失敗
                MessageBox.Show("設定の保存に失敗しました", "保存エラー", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }
        }
        #endregion  
    }

    #region 学会の感染症コードリスト情報
    /// <summary>
    /// 学会の感染症コードリスト情報
    /// </summary>
    internal static class InfectItem
    {
        /// <summary>
        /// キャッシュ領域
        /// </summary>
        private static List<DispCode> m_Data = null;

        /// <summary>
        /// 学会の感染症コードリストを取得
        /// </summary>
        internal static List<DispCode> Data
        {
            get
            {
                if (null == m_Data)
                {
                    // キャッシュ情報が無い場合はここで作成
                    m_Data = new List<DispCode>();
                    m_Data.Add(new DispCode(StatisticsConst.INFECT_HBS, "HBs抗原"));
                    m_Data.Add(new DispCode(StatisticsConst.INFECT_HBSAB, "HBs抗体"));
                    m_Data.Add(new DispCode(StatisticsConst.INFECT_HBC, "HBc抗体"));
                    m_Data.Add(new DispCode(StatisticsConst.INFECT_HBV_DNA, "HBV-DNA"));
                    m_Data.Add(new DispCode(StatisticsConst.INFECT_HCV, "HCV抗体"));
                    m_Data.Add(new DispCode(StatisticsConst.INFECT_HCV_RNA, "HCV-RNA"));
                }
                return m_Data;
            }
        }
    }
    #endregion
}
