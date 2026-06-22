using System;
using System.Collections.Generic;
using System.Data;
using System.Reflection;
using System.Threading.Tasks;
using System.Windows.Forms;
using Fnw.StatisticsTool.Models;
using Fnw.StatisticsTool.Properties;
using NKKLoggingLib;

namespace Fnw.StatisticsTool.FrmPat
{
    /// <summary>
    /// 患者選択画面
    /// </summary>
    public partial class FrmPatSelect : StatisticsBase
    {
        /// <summary>
        /// 選択された患者の情報
        /// </summary>
        public DataGridViewCellCollection SelectedCells { get; set; }

        /// <summary>
        /// 割当画面で選択された行の情報
        /// </summary>
        public DataRow MedicalData { get; set; }

        //// 2016年版対応（系列施設対応）
        ///// <summary>
        ///// 系列施設コード
        ///// </summary>
        //private string m_FacilityCd = String.Empty;

        /// <summary>
        /// 全患者のキャッシュ情報
        /// </summary>
        private DataTable m_Data = null;

        /// <summary>
        /// 患者選択画面のコンストラクタ
        /// </summary>
        public FrmPatSelect() : base(isUserLoggedIn: true)
        {
            InitializeComponent();
            // 基底クラスのコンストラクタでイベント登録
            RegisterEvents(this);
        }

        public async Task InitializeAsync()
        {
            DataTable dt;
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
                return;
            }

            // キャッシュ用のテーブルを作成
            m_Data = new DataTable();
            m_Data.Columns.Add("PATID");
            m_Data.Columns.Add("DISP_PATID");
            m_Data.Columns.Add("NAME");
            m_Data.Columns.Add("SEX");
            m_Data.Columns.Add("BIRTHDAY");

            DataRow tmpRow = m_Data.NewRow();

            tmpRow["PATID"] = "-1";
            tmpRow["DISP_PATID"] = "ZZZZZZZZZZ";
            tmpRow["NAME"] = "該当者無し";
            tmpRow["SEX"] = string.Empty;
            tmpRow["BIRTHDAY"] = "1901/01/01";
            m_Data.Rows.Add(tmpRow);

            for (int i = 0; i < dt.Rows.Count; i++)
            {
                DataRow row = m_Data.NewRow();

                row["PATID"] = dt.Rows[i]["PATID"];
                row["DISP_PATID"] = dt.Rows[i]["DISP_PATID"];
                row["NAME"] = dt.Rows[i]["NAME"];
                // 性別コードから文字に変換
                switch ((short)dt.Rows[i]["SEX_CD"])
                {
                    case 1:
                        row["SEX"] = "M";
                        break;
                    case 2:
                        row["SEX"] = "F";
                        break;
                    default:
                        break;
                }
                DateTime day = StaticFunctions.YyyyMmDdToDay(dt.Rows[i]["BIRTHDAY"] as string);
                if (DateTime.MinValue != day)
                {
                    row["BIRTHDAY"] = day.ToString("yyyy/MM/dd");
                }
                m_Data.Rows.Add(row);
            }

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
        private void FrmPatSelect_Load(object sender, EventArgs e)
        {
            NKKLogging.GetInstance().AddLogInfo(DateTime.Now, StatisticsUtility.PRODUCT_NAME,
            GetType().Name, NKKLogging.LOGGING_CLASS.INFO, MethodBase.GetCurrentMethod().Name);

            if (null != MedicalData)
            {
                // 割当画面の選択情報をラベルに表示
                lblName.Text = MedicalData["MEDICAL_NAME"] as string;
                lblSex.Text = MedicalData["MEDICAL_SEX"] as string;
                lblBirthday.Text = MedicalData["MEDICAL_BIRTHDAY"] as string;
            }

            // 現在の画面状態に合わせて患者リストを更新
            this.MakeList();
        }

        /// <summary>
        /// OK
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnOK_Click(object sender, EventArgs e)
        {
            // ラジオボタンチェック
            if (false == rdoNoSelect.Checked)
            {
                // 選択件数を確認
                if (0 == grdPatList.SelectedRows.Count)
                {
                    // 未選択(=抽出件数が0件)
                    MessageBox.Show("選択されていません", "未選択", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    return;
                }

                this.SelectedCells = grdPatList.SelectedRows[0].Cells;
            }
            else
            {
                // 未選択にする
                this.SelectedCells = null;
            }

            // 閉じる
            this.DialogResult = DialogResult.OK;
            this.Close();
        }

        /// <summary>
        /// キャンセル
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnCancel_Click(object sender, EventArgs e)
        {
            this.DialogResult = DialogResult.Cancel;
            this.Close();
        }

        /// <summary>
        /// ラジオボタンのチェックが変更になった
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void rdoType_CheckedChanged(object sender, EventArgs e)
        {
            // ラジオボタンの状態に応じたリストに更新
            this.MakeList();
        }

        /// <summary>
        /// テキストボックスの内容が変更された
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void txtName_TextChanged(object sender, EventArgs e)
        {
            if (rdoName.Checked)
            {
                // 未選択じゃない場合はリストを更新
                this.MakeList();
            }
        }

        /// <summary>
        /// 患者リスト作成
        /// </summary>
        private void MakeList()
        {
            // キャッシュ情報確認
            if (null == m_Data)
            {
                MessageBox.Show("患者リスト取得に失敗しました", "DBエラー", MessageBoxButtons.OK, MessageBoxIcon.Stop);
                rdoName.Enabled = false;
                rdoMedical.Enabled = false;
                rdoNoSelect.Enabled = false;
                btnOK.Enabled = false;
                grdPatList.Enabled = false;
                txtName.Enabled = false;
                return;
            }

            // 絞込み文字列作成
            string select = string.Empty;

            if (rdoMedical.Checked)
            {
                // 氏名の先頭1文字が一致
                if (false == string.IsNullOrEmpty(lblName.Text))
                {
                    select = "(NAME like '" + lblName.Text[0] + "%')";
                }

                // 性別が一致
                if (false == string.IsNullOrEmpty(lblSex.Text))
                {
                    select += (string.IsNullOrEmpty(select) ? string.Empty : " and ") + "(SEX = '" + lblSex.Text + "')";
                }

                // 生年月日が一致
                DateTime work;
                if (DateTime.TryParse(lblBirthday.Text, out work))
                {
                    select += (string.IsNullOrEmpty(select) ? string.Empty : " and ") + "(BIRTHDAY = '" + work.ToString("yyyy/MM/dd") + "')";
                }
            }
            else if (rdoName.Checked)
            {
                // 氏名の部分一致
                select = "NAME like '%" + txtName.Text + "%'";
            }
            else
            {
                // 一致させない
                select = "1 = 0";
            }

            // ビューにフィルタリング
            DataView dv = m_Data.DefaultView;
            dv.RowFilter = select;

            // フィルタリング情報をバインド
            grdPatList.DataSource = dv;
        }

        /// <summary>
        /// リストをダブルクリック
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void grdPatList_CellDoubleClick(object sender, DataGridViewCellEventArgs e)
        {
            if (0 <= e.RowIndex)
            {
                // OKを押した時と同じ処理
                btnOK_Click(btnOK, EventArgs.Empty);
            }
        }
    }
}
