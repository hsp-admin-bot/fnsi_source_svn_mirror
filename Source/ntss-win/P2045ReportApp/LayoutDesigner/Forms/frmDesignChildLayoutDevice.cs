using LayoutDesigner.Data;
using NKKWebAccessLib;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web.Script.Serialization;
using System.Windows.Forms;

using Excel = Microsoft.Office.Interop.Excel;

using RldUtility = LayoutDesignerUtilityLib.LayoutDesignerUtility;

namespace LayoutDesigner
{
    /// <summary>
    /// デザイナーウィンドウ内グループ編集画面
    /// </summary>
    public partial class frmDesignChildLayoutDevice : LayoutDesignerUtilityLib.Controls.frmRldBase, IRldDesignSendOnlyColleague
    {
        #region メンバ定数定義

        private ComboBox cmbType = new ComboBox();

        // mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
        //private ComboBox cmbLayout = new ComboBox();

        private ComboBox cmbUse = new ComboBox();

        //private ComboBox cmbRecord = new ComboBox();

        private ComboBox cmbMachineType = new ComboBox();
        // mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end

        // add #12194 機器保守項目のフィルタ設定が帳票出力時に反映しない 高 start
        private int lastcmbTypeSelectedIndex = -1;
        // add #12194 機器保守項目のフィルタ設定が帳票出力時に反映しない 高 end

        #endregion

        #region メンバイベント定義

        /// <summary>
        /// 通知用イベント
        /// </summary>
        public event EventHandler<RldDesignNotifyInfoEventArgs> NotifyInfo;

        // add 単一集計帳票／複数集計帳票：帳票分類コンボボックスの追加 鄭  start
        List<ReportType> reportType = new List<ReportType>();
        // add 単一集計帳票／複数集計帳票：帳票分類コンボボックスの追加 鄭  end
        // add 7347 【デグレ】削除されていない帳票が帳票画面のリストに表示されない 吉 start
        public Boolean reportTypeFlag = true;
        // add 7347 【デグレ】削除されていない帳票が帳票画面のリストに表示されない 吉 end
        #endregion

        #region 生成と破棄

        /// <summary>
        /// デザイナーウィンドウ内グループ編集画面の新しいインスタンスを初期化します。
        /// </summary>
        public frmDesignChildLayoutDevice()
        {
            InitializeComponent();


            cmbType.SelectedIndexChanged += new EventHandler(cmbTypeSelectedIndexChanged);
            cmbUse.SelectedIndexChanged += new EventHandler(cmbUseSelectedIndexChanged);
            // mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
            //cmbRecord.SelectedIndexChanged += new EventHandler(cmbRecordSelectedIndexChanged);
            //cmbLayout.SelectedIndexChanged += new EventHandler(cmbLayoutSelectedIndexChanged);
            cmbMachineType.SelectedIndexChanged += new EventHandler(cmbMachineTypeSelectedIndexChanged);
            // mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end
        }

        #endregion

        #region メンバ関数定義(override)

        /// <summary>
        /// Form.Load イベントを発生させます。
        /// </summary>
        /// <param name="e"></param>
        protected override void OnLoad(EventArgs e)
        {
            base.OnLoad(e);

            if (base.DesignMode) return;

            // 画面をクリア
            this.DataClear(true);
        }

        /// <summary>
        /// Form.Shown イベントを発生させます。
        /// </summary>
        /// <param name="e"></param>
        protected override void OnShown(EventArgs e)
        {
            base.OnShown(e);

            BindType();
            // add #7943 帳票レイアウトデザイナーが正しく動作しないの⑮対応 夏 start
            if ("Device".Equals(RldLib.CurrentLayoutData.DesignSettingData.ReportClass))
            {
            // add #7943 帳票レイアウトデザイナーが正しく動作しないの⑮対応 夏 end
                BindUse();
                // mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
                //BindRecord();
                //BindLayout();
                if (RldLib.inspectionLayoutData.ReportType == "0")
                {
                    cmbMachineType.Enabled = true;
                    BindMachineType();
                }
                else
                {
                    cmbMachineType.Enabled = false;
                    cmbMachineType.DataSource = null;
                }
                // mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end
            // add #7943 帳票レイアウトデザイナーが正しく動作しないの⑮対応 夏 start
            }
            // add #7943 帳票レイアウトデザイナーが正しく動作しないの⑮対応 夏 end

            // add UT帳票No.122 再編集時、定期日常点検・交換部品記録簿のレイアウトデータ不正の対応 夏 start
            InspectionLayoutData deviceData = new InspectionLayoutData();
            deviceData.ReportType = RldLib.inspectionLayoutData.ReportType;
            deviceData.UseCD = RldLib.inspectionLayoutData.UseCD;
            // mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
            //deviceData.RecordCD = RldLib.inspectionLayoutData.RecordCD;
            //deviceData.LayoutCD = RldLib.inspectionLayoutData.LayoutCD;
            deviceData.MachineTypeCD = RldLib.inspectionLayoutData.MachineTypeCD;
            // mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end
            // add UT帳票No.122 再編集時、定期日常点検・交換部品記録簿のレイアウトデータ不正の対応 夏 end

            // 画面にデータを読み込む
            //mon 2021-09-22 #6346 単一の患者の請求書を追加する 鄭 start
            //this.DataRead();
            if ("Device".Equals(RldLib.CurrentLayoutData.DesignSettingData.ReportClass))
            {
                this.DataRead();
            }
            else
            {
                this.OnePatientDataRead();
            }
            //mon 2021-09-22 #6346 単一の患者の請求書を追加する 鄭 start

            // add UT帳票No.122 再編集時、定期日常点検・交換部品記録簿のレイアウトデータ不正の対応 夏 start
            cmbType.SelectedValue = deviceData.ReportType;
            cmbUse.SelectedValue = deviceData.UseCD;
            // mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
            //cmbRecord.SelectedValue = deviceData.RecordCD;
            //cmbLayout.SelectedValue = deviceData.LayoutCD;
            cmbMachineType.SelectedValue = deviceData.MachineTypeCD;
            // mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end
            // add UT帳票No.122 再編集時、定期日常点検・交換部品記録簿のレイアウトデータ不正の対応 夏 end
        }

        #endregion

        #region メンバ関数定義

        /// <summary>
        /// 画面の入力内容をクリアします。
        /// </summary>
        /// <param name="aIsKeyClear">(未使用)</param>
        private void DataClear(Boolean aIsKeyClear)
        {
            if (aIsKeyClear)
            {
                this.dgvDeviceList.DataMember = null;
                this.dgvDeviceList.DataSource = null;
            }
        }
        private void BindType()
        {
            // mon 2021-09-22 #6346 単一の患者の請求書を追加する  鄭 start
            //DataTable dtData = new DataTable();
            //dtData.Columns.Add("Value");
            //dtData.Columns.Add("Name");
            //DataRow drData;
            //drData = dtData.NewRow();
            //drData[0] = "0";
            //drData[1] = "シングル";
            //dtData.Rows.Add(drData);
            //drData = dtData.NewRow();
            //drData[0] = "1";
            //drData[1] = "マルチ";
            //dtData.Rows.Add(drData);

            int getReportType = 0;
            if ("Device".Equals(RldLib.CurrentLayoutData.DesignSettingData.ReportClass))
            {
                getReportType = 7;
            }
            else
            {
                getReportType = 2;
            }
            List<SysReportClass> wRepotrType = Task.Run<List<SysReportClass>>(async () => await GetReportType(getReportType)).Result;         
            if (wRepotrType.Count == 1)
            {            
                String jsonString = wRepotrType[0].ReportType;
                JavaScriptSerializer json = new JavaScriptSerializer();
                reportType = json.Deserialize<List<ReportType>>(jsonString);
                var items = reportType.Select(x => x.Name);
                if (items.Count() > 0)
                {
                    this.cmbType.Items.AddRange(items.ToArray());
                }
                // del #11116 単集計帳票の「レイアウト」タブの内容が保存されないことがある 高 start
                //cmbType.SelectedIndex = 0;//设置显示的item索引
                // del #11116 単集計帳票の「レイアウト」タブの内容が保存されないことがある 高 end
            }
            // mon 2021-09-22 #6346 単一の患者の請求書を追加する  鄭 end

            // mod UT帳票No.122 再編集時、定期日常点検・交換部品記録簿のレイアウトデータ不正の対応 夏 start
            if (string.IsNullOrEmpty(RldLib.inspectionLayoutData.ReportType))
            {
                RldLib.inspectionLayoutData.ReportType = "0";
            }
            //RldLib.inspectionLayoutData.ReportType = "0";
            // mod UT帳票No.122 再編集時、定期日常点検・交換部品記録簿のレイアウトデータ不正の対応 夏 end

            // del 2021-09-22 #6346 鄭 start
            //cmbType.ValueMember = "Value";
            //cmbType.DisplayMember = "Name";
            //cmbType.DataSource = dtData;
            // del  2021-09-22 #6346 鄭 end
            cmbType.DropDownStyle = ComboBoxStyle.DropDownList;
            // add #11116 単集計帳票の「レイアウト」タブの内容が保存されないことがある 高 start
            if(reportType.Count > 0)
            {
                int index = reportType.IndexOf(reportType.Where(item => item.Cd == RldLib.inspectionLayoutData.ReportType).FirstOrDefault());
                if (index < 0)   //设置显示的item索引
                {
                    cmbType.SelectedIndex = 0;
                }
                else
                {
                    cmbType.SelectedIndex = index;
                }

            }
            // add #11116 単集計帳票の「レイアウト」タブの内容が保存されないことがある 高 end
        }
        // add 単一集計帳票／複数集計帳票：帳票分類コンボボックスの追加 鄧シン  start
        /// <summary>
        /// 帳票区分リストを取得する。
        /// </summary>
        /// <param name="classCd">帳票種別</param>
        private static async Task<List<SysReportClass>> GetReportType(int classCd)
        {
            try
            {
                List<SysReportClass> m_MstMainteLayoutData = null;

                string wUri = $"{NKKWebAccess.BaseUri}{RldConst.Uri.WEB_APP}{RldConst.Uri.GET_SYS_REPORT_CLASS}{"?classCd="}{classCd}";
                var wReportType = await NKKWebAccess.Get("帳票区分取得", wUri, NKKWebAccess.SKIP_OTP);

                // 取得データを戻り値にセット
                if (wReportType.isLogin && wReportType.response.IsSuccessStatusCode)
                {
                    m_MstMainteLayoutData = RldJsonDataSerializeHelper<List<SysReportClass>>.Deserialize(wReportType.strContent);
                }


                return m_MstMainteLayoutData;
            }
            catch (Exception ex)
            {
                LayoutDesignerUtilityLib.LayoutDesignerUtility.RecordException(ex, true);
                return null;
            }
        }

        private void BindUse()
        {
            DataTable dtData = new DataTable();
            dtData.Columns.Add("Value");
            dtData.Columns.Add("Name");
            // mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
            //DataRow drData;
            //drData = dtData.NewRow();
            //drData[0] = "1";
            //drData[1] = "日常点検用";
            //dtData.Rows.Add(drData);
            //drData = dtData.NewRow();
            //drData[0] = "2";
            //drData[1] = "定期点検用";
            //dtData.Rows.Add(drData);

            // mod #12582 固定帳票「水質管理記録簿」が必要 limingzhe start
            //String[] strItemValue = { "日常点検用", "定期点検用" };
            String[] strItemValue = { "日常点検用", "定期点検用", "水質管理用" };
            // mod #12582 固定帳票「水質管理記録簿」が必要 limingzhe end
            for (Int32 i = 0; i < strItemValue.Length; i++)
            {
                DataRow row = dtData.NewRow();
                row[0] = String.Format("{0}", i + 1);
                row[1] = strItemValue[i];
                dtData.Rows.Add(row);
            }
            // mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end
            // mod UT帳票No.122 再編集時、定期日常点検・交換部品記録簿のレイアウトデータ不正の対応 夏 start
            if (string.IsNullOrEmpty(RldLib.inspectionLayoutData.UseCD))
            {
                RldLib.inspectionLayoutData.UseCD = "1";
            }
            //RldLib.inspectionLayoutData.UseCD = "1";
            // mod UT帳票No.122 再編集時、定期日常点検・交換部品記録簿のレイアウトデータ不正の対応 夏 end
            cmbUse.ValueMember = "Value";
            cmbUse.DisplayMember = "Name";
            cmbUse.DataSource = dtData;
            cmbUse.DropDownStyle = ComboBoxStyle.DropDownList;
        }

        // mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
   //     private void BindRecord()
   //     {
   //         DataTable dtData = new DataTable();
   //         dtData.Columns.Add("Value");
   //         dtData.Columns.Add("Name");
   //         DataRow drData;
   //         drData = dtData.NewRow();
   //         drData[0] = "1";
   //         drData[1] = "定期点検記録簿";
   //         dtData.Rows.Add(drData);
   //         drData = dtData.NewRow();
   //         drData[0] = "2";
   //         drData[1] = "定期交換部品記録簿";
   //         dtData.Rows.Add(drData);
   //         // mod UT帳票No.122 再編集時、定期日常点検・交換部品記録簿のレイアウトデータ不正の対応 夏 start
   //         if (string.IsNullOrEmpty(RldLib.inspectionLayoutData.RecordCD))
   //         {
   //             RldLib.inspectionLayoutData.RecordCD = "1";
   //         }
   //         //RldLib.inspectionLayoutData.RecordCD = "1";
   //         // mod UT帳票No.122 再編集時、定期日常点検・交換部品記録簿のレイアウトデータ不正の対応 夏 end
   //         //add 6856 デザイナーウィンドウ＞レイアウトの用途を「定期点検用」で保存できない 吉 start
   //         if (RldLib.inspectionLayoutData.UseCD == "2")
   //         {
   //             cmbRecord.DataSource = dtData;
   //             cmbRecord.Enabled = true;
   //         }
   //         else
   //         {
   //             cmbRecord.DataSource = null;
   //             cmbRecord.Enabled = false;
   //         }
   //         //add 6856 デザイナーウィンドウ＞レイアウトの用途を「定期点検用」で保存できない 吉 end
   //         cmbRecord.ValueMember = "Value";
   //         cmbRecord.DisplayMember = "Name";
   //         //del 6856 デザイナーウィンドウ＞レイアウトの用途を「定期点検用」で保存できない 吉 start
   //         //cmbRecord.DataSource = dtData;
   //         //del 6856 デザイナーウィンドウ＞レイアウトの用途を「定期点検用」で保存できない 吉 end
   //         cmbRecord.DropDownStyle = ComboBoxStyle.DropDownList;
   //     }

   //     private void BindLayout()
   //     {
   //         DataTable dtData = new DataTable();
   //         dtData.Columns.Add("Value");
   //         dtData.Columns.Add("Name");
   //         DataRow drData;
   //         var wRestRet = Task.Run<RldRestResultData<List<MstMainteLayoutData>>>(async () => await RldLib.GetMstMainteLayoutList()).Result;
   //         if (wRestRet.IsSuccess)
   //         {
   //             foreach (var wMstData in wRestRet.Data)
   //             {
   //                 drData = dtData.NewRow();
   //                 drData[0] = wMstData.MenteLayoutCd;
   //                 drData[1] = wMstData.LayoutName;
   //                 dtData.Rows.Add(drData);
   //             }
   //             // mod UT帳票No.122 再編集時、定期日常点検・交換部品記録簿のレイアウトデータ不正の対応 夏 start
   //             if (string.IsNullOrEmpty(RldLib.inspectionLayoutData.LayoutCD))
   //             {
   //                 RldLib.inspectionLayoutData.LayoutCD = dtData.Rows[0].ItemArray[0].ToString();
   //             }
   //             //RldLib.inspectionLayoutData.LayoutCD = dtData.Rows[0].ItemArray[0].ToString();
   //             // mod UT帳票No.122 再編集時、定期日常点検・交換部品記録簿のレイアウトデータ不正の対応 夏 end
   //             cmbLayout.ValueMember = "Value";
   //             cmbLayout.DisplayMember = "Name";
   //             cmbLayout.DataSource = dtData;
   //             cmbLayout.DropDownStyle = ComboBoxStyle.DropDownList;
   //         }
   //     }

        private void BindMachineType()
        {
            DataTable dtData = new DataTable();
            dtData.Columns.Add("Value");
            dtData.Columns.Add("Name");
            DataRow drData;
            var wRestRet = Task.Run<RldRestResultData<List<MstMachineTypeData>>>(async () => await RldLib.GetMstMachineTypeList()).Result;
            if (wRestRet.IsSuccess)
            {
                foreach (var wMstData in wRestRet.Data)
                {
                    drData = dtData.NewRow();
                    drData[0] = wMstData.MachineTypeCd;
                    drData[1] = wMstData.MachineTypeName;
                    dtData.Rows.Add(drData);
                }
                if (string.IsNullOrEmpty(RldLib.inspectionLayoutData.MachineTypeCD))
                {
                    RldLib.inspectionLayoutData.MachineTypeCD = dtData.Rows[0].ItemArray[0].ToString();
                }

                cmbMachineType.ValueMember = "Value";
                cmbMachineType.DisplayMember = "Name";
                cmbMachineType.DataSource = dtData;
                cmbMachineType.DropDownStyle = ComboBoxStyle.DropDownList;
            }
        }
        // mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end

        private void cmbTypeSelectedIndexChanged(object sender, EventArgs e)
        {
            //mon 2021-09-22 #6346 単一の患者の請求書を追加する 鄭 start
            //if (((ComboBox)sender).Text == "シングル")
            //{
            //    RldLib.inspectionLayoutData.ReportType = "0";
            //    RldLib.inspectionLayoutData.UseCD = "1";
            //    RldLib.inspectionLayoutData.RecordCD = "1";
            //    cmbUse.Enabled = true;
            //    cmbRecord.Enabled = true;
            //    cmbLayout.Enabled = true;
            //    BindUse();
            //    BindRecord();
            //    BindLayout();
            //}
            //else
            //{
            //    RldLib.inspectionLayoutData.ReportType = "1";
            //    RldLib.inspectionLayoutData.UseCD = "0";
            //    RldLib.inspectionLayoutData.RecordCD = "0";
            //    RldLib.inspectionLayoutData.LayoutCD = "0";
            //    cmbUse.Enabled = false;
            //    cmbUse.DataSource = null;
            //    cmbRecord.Enabled = false;
            //    cmbRecord.DataSource = null;
            //    cmbLayout.Enabled = false;
            //    cmbLayout.DataSource = null;
            //}
            if (!"Device".Equals(RldLib.CurrentLayoutData.DesignSettingData.ReportClass))
            {
                 
                RldLib.inspectionLayoutData.ReportType = reportType.Where(item => item.Name == ((ComboBox)sender).Text).Select(item => item.Cd).First();
            }
            else
            {
                // add #12194 機器保守項目のフィルタ設定が帳票出力時に反映しない 高 start
                if (lastcmbTypeSelectedIndex == cmbType.SelectedIndex)
                    return;
                // add #12194 機器保守項目のフィルタ設定が帳票出力時に反映しない 高 end

                // mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
                //// mod 6856 デザイナーウィンドウ＞レイアウトの用途を「定期点検用」で保存できない 吉 start
                //// if (((ComboBox)sender).Text == "シングル")
                //// mod 7347 【デグレ】削除されていない帳票が帳票画面のリストに表示されない 吉 start
                //// if (RldLib.inspectionLayoutData.ReportType == "1" )
                //if (reportTypeFlag && RldLib.inspectionLayoutData.ReportType == "1")
                //{
                //    // mod #12203 装置帳票、レイアウトタブの「帳票区分」名称が意味不明 高 start
                //    //((ComboBox)sender).Text = "マルチ";
                //    ((ComboBox)sender).Text = "汎用帳票";
                //    // mod #12203 装置帳票、レイアウトタブの「帳票区分」名称が意味不明 高 end
                //    reportTypeFlag = false;
                //}
                //if (reportType.Where(item => item.Name == ((ComboBox)sender).Text).Select(item => item.Cd).First() == "0")
                //// mod 7347 【デグレ】削除されていない帳票が帳票画面のリストに表示されない 吉 end
                //// mod 6856 デザイナーウィンドウ＞レイアウトの用途を「定期点検用」で保存できない 吉 end
                //{                 
                //    RldLib.inspectionLayoutData.ReportType = reportType.Where(item => item.Name == ((ComboBox)sender).Text).Select(item => item.Cd).First();
                //    //mod 6856 デザイナーウィンドウ＞レイアウトの用途を「定期点検用」で保存できない 吉 start
                //    //if (null ==RldLib.inspectionLayoutData.UseCD) {
                //    //    RldLib.inspectionLayoutData.UseCD = "1";
                //    //}
                //    //RldLib.inspectionLayoutData.RecordCD = "1";
                //    if (null !=RldLib.inspectionLayoutData.RecordCD && RldLib.inspectionLayoutData.RecordCD.Equals("0")) {
                //        RldLib.inspectionLayoutData.UseCD = "1";
                //        RldLib.inspectionLayoutData.RecordCD = "1";
                //    }
                //    //mod 6856 デザイナーウィンドウ＞レイアウトの用途を「定期点検用」で保存できない 吉 end
                //    cmbUse.Enabled = true;
                //    cmbRecord.Enabled = true;
                //    cmbLayout.Enabled = true;
                //    BindUse();
                //    BindRecord();
                //    BindLayout();
                //}
                //else
                //{
                //    // add 6856 デザイナーウィンドウ＞レイアウトの用途を「定期点検用」で保存できない 吉 start
                //    // mod #12203 装置帳票、レイアウトタブの「帳票区分」名称が意味不明 高 start
                //    //((ComboBox)sender).Text = "マルチ";
                //    ((ComboBox)sender).Text = "汎用帳票";
                //    // mod #12203 装置帳票、レイアウトタブの「帳票区分」名称が意味不明 高 end
                //    // add 6856 デザイナーウィンドウ＞レイアウトの用途を「定期点検用」で保存できない 吉 end
                //    RldLib.inspectionLayoutData.ReportType = reportType.Where(item => item.Name == ((ComboBox)sender).Text).Select(item => item.Cd).First();
                //    RldLib.inspectionLayoutData.UseCD = "0";
                //    RldLib.inspectionLayoutData.RecordCD = "0";
                //    RldLib.inspectionLayoutData.LayoutCD = "0";
                //    cmbUse.Enabled = false;
                //    cmbUse.DataSource = null;
                //    cmbRecord.Enabled = false;
                //    cmbRecord.DataSource = null;
                //    cmbLayout.Enabled = false;
                //    cmbLayout.DataSource = null;
                //}
                RldLib.inspectionLayoutData.ReportType = reportType.Where(item => item.Name == ((ComboBox)sender).Text).Select(item => item.Cd).First();
                if (RldLib.inspectionLayoutData.ReportType == "0")
                {
                    cmbMachineType.Enabled = true;
                    BindMachineType();
                }
                else
                {
                    cmbMachineType.Enabled = false;
                    cmbMachineType.DataSource = null;
                    RldLib.inspectionLayoutData.MachineTypeCD = "";
                }
                // mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end

                //mon 2021-09-22 #6346 単一の患者の請求書を追加する 鄭 end

                // add #12194 機器保守項目のフィルタ設定が帳票出力時に反映しない 高 start
                // del #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
                //if(lastcmbTypeSelectedIndex != -1)
                //    setFilterDatqIni();
                // del #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end

                lastcmbTypeSelectedIndex = cmbType.SelectedIndex;
                // add #12194 機器保守項目のフィルタ設定が帳票出力時に反映しない 高 end
            }
        }

        // del #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
        //private void cmbLayoutSelectedIndexChanged(object sender, EventArgs e)
        //{
        //    // mod #12194 機器保守項目のフィルタ設定が帳票出力時に反映しない 高 start
        //    if (((ComboBox)sender).SelectedValue != null)
        //    {
        //        if(RldLib.inspectionLayoutData.LayoutCD != ((ComboBox)sender).SelectedValue.ToString())
        //                {
        //            RldLib.inspectionLayoutData.LayoutCD = ((ComboBox)sender).SelectedValue.ToString();
        //            setFilterDatqIni();
        //        }
        //    }
        //    // mod #12194 機器保守項目のフィルタ設定が帳票出力時に反映しない 高 end
        //}
        // del #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end

        private void cmbUseSelectedIndexChanged(object sender, EventArgs e)
        {
            // mod #12194 機器保守項目のフィルタ設定が帳票出力時に反映しない 高 start
            if (((ComboBox)sender).SelectedValue != null)
            {
                if (RldLib.inspectionLayoutData.UseCD != ((ComboBox)sender).SelectedValue.ToString())

                {
                    RldLib.inspectionLayoutData.UseCD = ((ComboBox)sender).SelectedValue.ToString();
                    // mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
                    ////add 6856 デザイナーウィンドウ＞レイアウトの用途を「定期点検用」で保存できない 吉 start
                    //BindRecord();
                    ////add 6856 デザイナーウィンドウ＞レイアウトの用途を「定期点検用」で保存できない 吉 end
                    //BindLayout();
                    setFilterDatqIni();
                    // mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end
                }
            }
            // mod #12194 機器保守項目のフィルタ設定が帳票出力時に反映しない 高 end
        }

        // mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
        //private void cmbRecordSelectedIndexChanged(object sender, EventArgs e)
        //{
        //    // mod #12194 機器保守項目のフィルタ設定が帳票出力時に反映しない 高 start
        //    if (((ComboBox)sender).SelectedValue != null)
        //    {
        //        if (RldLib.inspectionLayoutData.RecordCD != ((ComboBox)sender).SelectedValue.ToString())
        //        {
        //            RldLib.inspectionLayoutData.RecordCD = ((ComboBox)sender).SelectedValue.ToString();
        //            setFilterDatqIni();
        //        }
        //    }
        //    // mod #12194 機器保守項目のフィルタ設定が帳票出力時に反映しない 高 end
        //}

        private void cmbMachineTypeSelectedIndexChanged(object sender, EventArgs e)
        {
            // mod #12585 水質管理.水質検査のフィルタ処理仕様修正 高 start
            if (((ComboBox)sender).SelectedValue != null)
            {
                //if (RldLib.inspectionLayoutData.MachineTypeCD != ((ComboBox)sender).SelectedValue.ToString())
                {
                    RldLib.inspectionLayoutData.MachineTypeCD = ((ComboBox)sender).SelectedValue.ToString();
                    setFilterTypeDataIni();
                }
            }
            else
            {
                RldLib.inspectionLayoutData.MachineTypeCD = "";
                setFilterTypeDataIni();
            }
            // mod #12585 水質管理.水質検査のフィルタ処理仕様修正 高 end
        }
        // mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end

        // add #12194 機器保守項目のフィルタ設定が帳票出力時に反映しない 高 start
        // init Filter data in paramList
        private void setFilterDatqIni()
        {
            foreach (var wData in RldLib.CurrentLayoutData.DesignParamList)
            {
                if (wData.FilterType == RldConst.FilterType.Group.INSPECTION)
                {
                    wData.FilterData = string.Empty;
                    wData.FilterState = RldConst.ParamData.VAL_FILTER_STATE_NO;
                }
            }
        }
        // add #12194 機器保守項目のフィルタ設定が帳票出力時に反映しない 高 end

        // add #12585 水質管理.水質検査のフィルタ処理仕様修正 高 start
        // init 水質検査 Filter data in paramList
        private void setFilterTypeDataIni()
        {
            foreach (var wData in RldLib.CurrentLayoutData.DesignParamList)
            {
                if (wData.FilterType == RldConst.FilterType.Group.WQTESTPOINT)
                {
                    wData.FilterData = string.Empty;
                    wData.FilterState = RldConst.ParamData.VAL_FILTER_STATE_NO;
                }
            }
        }
        // add #12585 水質管理.水質検査のフィルタ処理仕様修正 高 end

        /// <summary>
        /// 画面にデータを読み込みます。
        /// </summary>
        private void DataRead()
        {
            try
            {
                this.dgvDeviceList.SuspendLayout();

                this.dgvDeviceList.DataMember = null;

                // mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
                //String[] strItemValue = { "帳票区分", "用途", "記録簿", "点検レイアウト" };
                String[] strItemValue = { "帳票区分", "用途", "型式" };
                // mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end

                DataTable wDataTable = new DataTable();

                wDataTable.Columns.Add(Code.Name);
                wDataTable.Columns.Add(ItemValue.Name);
                wDataTable.Columns.Add(DisplayValue.Name);

                // mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
                //for (Int32 i = 0; i < 4; i++)
                for (Int32 i = 0; i < strItemValue.Length; i++)
                // mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end
                {
                    DataRow row = wDataTable.NewRow();
                    row[Code.Name] = i.ToString();
                    row[ItemValue.Name] = strItemValue[i];
                    wDataTable.Rows.Add(row);
                }

                this.dgvDeviceList.DataSource = wDataTable;

                Rectangle rectType = dgvDeviceList.GetCellDisplayRectangle(2, 0, false);
                cmbType.Left = rectType.Left;
                cmbType.Top = rectType.Top;
                cmbType.Width = rectType.Width;
                cmbType.Height = rectType.Height;
                this.dgvDeviceList.Controls.Add(cmbType);

                Rectangle rectUse = dgvDeviceList.GetCellDisplayRectangle(2, 1, false);
                cmbUse.Left = rectUse.Left;
                cmbUse.Top = rectUse.Top;
                cmbUse.Width = rectUse.Width;
                cmbUse.Height = rectUse.Height;
                this.dgvDeviceList.Controls.Add(cmbUse);

                // mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
                //Rectangle rectRecord = dgvDeviceList.GetCellDisplayRectangle(2, 2, false);
                //cmbRecord.Left = rectRecord.Left;
                //cmbRecord.Top = rectRecord.Top;
                //cmbRecord.Width = rectRecord.Width;
                //cmbRecord.Height = rectRecord.Height;
                //this.dgvDeviceList.Controls.Add(cmbRecord);

                //Rectangle rectLayout = dgvDeviceList.GetCellDisplayRectangle(2, 3, false);
                //cmbLayout.Left = rectLayout.Left;
                //cmbLayout.Top = rectLayout.Top;
                //cmbLayout.Width = rectLayout.Width;
                //cmbLayout.Height = rectLayout.Height;
                //cmbLayout.IntegralHeight = false;
                //cmbLayout.MaxDropDownItems = 20;
                //this.dgvDeviceList.Controls.Add(cmbLayout);

                Rectangle rectLayout = dgvDeviceList.GetCellDisplayRectangle(2, 2, false);
                cmbMachineType.Left = rectLayout.Left;
                cmbMachineType.Top = rectLayout.Top;
                cmbMachineType.Width = rectLayout.Width;
                cmbMachineType.Height = rectLayout.Height;
                cmbMachineType.IntegralHeight = false;
                cmbMachineType.MaxDropDownItems = 20;
                this.dgvDeviceList.Controls.Add(cmbMachineType);
                // mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end

            }
            catch (Exception ex)
            {
                this.SendNotifyInfo(new RldDesignNotifyInfoRequestRecordExceptionEventArgs(ex, true));
            }
            finally
            {
                this.dgvDeviceList.ResumeLayout();
            }
        }
        //add 2021-09-22 #6346 単一の患者の請求書を追加する 鄭 start
        /// <summary>
        /// 画面にデータを読み込みます。
        /// </summary>
        private void OnePatientDataRead()
        {
            try
            {
                this.dgvDeviceList.SuspendLayout();

                this.dgvDeviceList.DataMember = null;

                String[] strItemValue = { "帳票区分" };

                DataTable wDataTable = new DataTable();

                wDataTable.Columns.Add(Code.Name);
                wDataTable.Columns.Add(ItemValue.Name);
                wDataTable.Columns.Add(DisplayValue.Name);

                DataRow row = wDataTable.NewRow();
                row[Code.Name] = "0";
                row[ItemValue.Name] = strItemValue[0];
                wDataTable.Rows.Add(row);
                this.dgvDeviceList.DataSource = wDataTable;

                Rectangle rectType = dgvDeviceList.GetCellDisplayRectangle(2, 0, false);
                cmbType.Left = rectType.Left;
                cmbType.Top = rectType.Top;
                cmbType.Width = rectType.Width;
                cmbType.Height = rectType.Height;
                this.dgvDeviceList.Controls.Add(cmbType);

            }
            catch (Exception ex)
            {
                this.SendNotifyInfo(new RldDesignNotifyInfoRequestRecordExceptionEventArgs(ex, true));
            }
            finally
            {
                this.dgvDeviceList.ResumeLayout();
            }
        }
        //add 2021-09-22 #6346 単一の患者の請求書を追加する 鄭 end

        /// <summary>
        /// 通知用イベントを発行します。
        /// </summary>
        /// <param name="e"></param>
        protected virtual void SendNotifyInfo(RldDesignNotifyInfoEventArgs e) => this.NotifyInfo?.Invoke(this, e);

        #endregion
    }
}
