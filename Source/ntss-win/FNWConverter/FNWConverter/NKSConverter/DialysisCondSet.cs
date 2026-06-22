using ConvertCommon;
using ConvertCommon.Common;
using Fnw.IOControl.DB;
using System;
using System.Collections.Generic;
using System.Data;
using System.Windows.Forms;

namespace NKSConverter
{
    public partial class DialysisCondSet : Form
    {
        public string seriesCd;
        //add 8431 zc start
        DBCtrl db = new DBCtrl(null);
       //add 8431 zc end
        class DispItems
        {
            public string name { get; set; }
            public string value { get; set; }
        }

        public DialysisCondSet()
        {
            //add 8431 zc start
             db = ConvertControl.DBConnectFnw();
            //add 8431 zc start
            InitializeComponent();
        }

        private void DialysisCondSet_Load(object sender, EventArgs e)
        {
            if (false == SetDispData())
            {
                this.Close();
            }
        }

        private void btnCancel_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private void btnSetting_Click(object sender, EventArgs e)
        {
            // 血液回路
            ComParam.Boold = new List<string>();
            foreach(DispItems item in chkbBloodCircuit.CheckedItems)
            {
                ComParam.Boold.Add(item.value);
            }
            // 穿刺針(A針)
            ComParam.p_A = new List<string>();
            foreach (DispItems item in chkbPunctureA.CheckedItems)
            {
                ComParam.p_A.Add(item.value);
            }

            // 穿刺針(V針)
            ComParam.p_V = new List<string>();
            foreach (DispItems item in chkbPunctureV.CheckedItems)
            {
                ComParam.p_V.Add(item.value);
            }

            // 穿刺針(SN)
            ComParam.p_SN = new List<string>();
            foreach (DispItems item in chkbPunctureSN.CheckedItems)
            {
                ComParam.p_SN.Add(item.value);
            }
            //add #7854  鄭晨  start
            CommonConfig.Boold[this.seriesCd] = ComParam.Boold;
            CommonConfig.p_A[this.seriesCd] = ComParam.p_A;
            CommonConfig.p_V[this.seriesCd] = ComParam.p_V;
            CommonConfig.p_SN[this.seriesCd] = ComParam.p_SN;
            //add #7854  鄭晨  end
            //add 8431 zc start
            String sBoold = string.Empty;
            String sp_A = string.Empty;
            String sp_V = string.Empty;
            String sp_SN = string.Empty;
            if (ComParam.Boold.Count != 0)
            {
                sBoold = String.Join(",", ComParam.Boold);
            }
            if (ComParam.p_A.Count != 0)
            {
                sp_A = String.Join(",", ComParam.p_A);
            }
            if (ComParam.p_V.Count != 0)
            {
                sp_V = String.Join(",", ComParam.p_V);
            }
            if (ComParam.p_SN.Count != 0)
            {
                sp_SN = String.Join(",", ComParam.p_SN);
            }
            IMakeSqlParameters param = db.GetIMakeSqlParameters();
            param.AddParam("SERIES_CD", this.seriesCd);
            param.AddParam("Boold", sBoold);
            param.AddParam("p_A", sp_A);
            param.AddParam("p_V", sp_V);
            param.AddParam("p_SN", sp_SN);

            String sql = @"UPDATE SYNC_CONDSET SET
                Boold = :Boold,
                p_A = :p_A,
                p_V = :p_V,
                p_SN = :p_SN
               WHERE SERIES_CD = :SERIES_CD";

            db.SelectTable(sql, param.GetParam());
            //add 8431 zc end

            this.Close();
        }

        private bool SetDispData()
        {
            // 医療材料マスタ取得
            DataTable dt = GetMstEquipment();
            if (null == dt)
            {
                MessageBox.Show("医療材料情報の取得に失敗しました。", "", MessageBoxButtons.OK, MessageBoxIcon.Stop);
                return false;
            }
            //add 8431 zc start
            IMakeSqlParameters param = db.GetIMakeSqlParameters();
            param.AddParam("SERIES_CD", this.seriesCd);
            String sql = @"select Boold,p_A,p_V,p_SN from  SYNC_CONDSET where SERIES_CD=:SERIES_CD";
            DataTable pdt = db.SelectTable(sql, param.GetParam());
            //add 8431 zc end
            // 血液回路
            chkbBloodCircuit.DisplayMember = "name";
            chkbBloodCircuit.ValueMember = "value";

            DataRow[] dr = dt.Select("EQUIP_GROUP_CD = '203'", "DISP_ORDER, EQUIP_CD");
            foreach (DataRow r in dr)
            {

                DispItems di = new DispItems();
                di.name = r["EQUIP_NAME"].ToString();
                di.value = r["EQUIP_CD"].ToString();

                bool chk = false;
                //if (ComParam.Boold != null)
                //{
                //    chk = ComParam.Boold.Exists(e => e == di.value);
                //}
                //add 8431 zc start
                string sBoold = pdt.Rows[0]["Boold"] == null ? null : pdt.Rows[0]["Boold"].ToString();
                string[] arrInt = Array.ConvertAll<string, string>(sBoold.Split(','), s => s);
                foreach (string i in arrInt)
                {
                    if (di.value.Equals(i)) {
                        chk = true;
                        break;
                    }                  
                };
                //add 8431 zc end
                chkbBloodCircuit.Items.Add(di, chk);

            }

            // 穿刺針(A針)
            chkbPunctureA.DisplayMember = "name";
            chkbPunctureA.ValueMember = "value";

            dr = dt.Select("EQUIP_GROUP_CD = '202'", "DISP_ORDER, EQUIP_CD");
            foreach (DataRow r in dr)
            {
                DispItems di = new DispItems();
                di.name = r["EQUIP_NAME"].ToString();
                di.value = r["EQUIP_CD"].ToString();

                bool chk = false;
                //if (ComParam.p_A != null)
                //{
                //    chk = ComParam.p_A.Exists(e => e == di.value);
                //}
                //add 8431 zc start
                string sBoold = pdt.Rows[0]["p_A"] == null ? null : pdt.Rows[0]["p_A"].ToString();
                string[] arrInt = Array.ConvertAll<string, string>(sBoold.Split(','), s => s);
                foreach (string i in arrInt)
                {
                    if (di.value.Equals(i))
                    {
                        chk = true;
                        break;
                    }
                };
                //add 8431 zc end
                chkbPunctureA.Items.Add(di, chk);
            }

            // 穿刺針(V針)
            chkbPunctureV.DisplayMember = "name";
            chkbPunctureV.ValueMember = "value";

            dr = dt.Select("EQUIP_GROUP_CD = '202'", "DISP_ORDER, EQUIP_CD");
            foreach (DataRow r in dr)
            {
                DispItems di = new DispItems();
                di.name = r["EQUIP_NAME"].ToString();
                di.value = r["EQUIP_CD"].ToString();

                bool chk = false;
                //if (ComParam.p_V != null)
                //{
                //    chk = ComParam.p_V.Exists(e => e == di.value);
                //}
                //add 8431 zc start
                string sBoold = pdt.Rows[0]["p_V"] == null ? null : pdt.Rows[0]["p_V"].ToString();
                string[] arrInt = Array.ConvertAll<string, string>(sBoold.Split(','), s => s);
                foreach (string i in arrInt)
                {
                    if (di.value.Equals(i))
                    {
                        chk = true;
                        break;
                    }
                };
                //add 8431 zc end
                chkbPunctureV.Items.Add(di, chk);
            }

            // 穿刺針(SN)
            chkbPunctureSN.DisplayMember = "name";
            chkbPunctureSN.ValueMember = "value";

            dr = dt.Select("EQUIP_GROUP_CD = '202'", "DISP_ORDER, EQUIP_CD");
            foreach (DataRow r in dr)
            {
                DispItems di = new DispItems();
                di.name = r["EQUIP_NAME"].ToString();
                di.value = r["EQUIP_CD"].ToString();

                bool chk = false;
                //if (ComParam.p_SN != null)
                //{
                //    chk = ComParam.p_SN.Exists(e => e == di.value);
                //}
                //add 8431 zc start
                string sBoold = pdt.Rows[0]["p_SN"] == null ? null : pdt.Rows[0]["p_SN"].ToString();
                string[] arrInt = Array.ConvertAll<string, string>(sBoold.Split(','), s => s);
                foreach (string i in arrInt)
                {
                    if (di.value.Equals(i))
                    {
                        chk = true;
                        break;
                    }
                };
                chkbPunctureSN.Items.Add(di, chk);
            }

            return true;
        }

        private DataTable GetMstEquipment()
        {
            DBCtrl db = new DBCtrl(null);

            // パラメータセット
            IMakeSqlParameters param = db.GetIMakeSqlParameters();
            param.AddParam("SERIES_CD", this.seriesCd);

            // SQL生成
            string strSQL = @"
                        select 
                            EQUIP_NAME,
	                        LPAD(TRIM(EQUIP_CD), 10, '0') as EQUIP_CD,DISP_ORDER,EQUIP_GROUP_CD
                        from 
                            V_MST_EQUIPMENT_ALL 
                        where  
                            SERIES_CD = :SERIES_CD 
                        order by 
                            DISP_ORDER,EQUIP_CD";
            // SQL実行
            DataTable dtMst = db.SelectTable(strSQL, param.GetParam());
            return dtMst;
        }
        private void ToggleCheckState(CheckedListBox checkBox,bool checkState)
        {
            if (checkState)
            {
                for (int i = 0; i < checkBox.Items.Count; i++)
                {
                    checkBox.SetItemChecked(i, true);
                }
            }
            else 
            {
                for (int i = 0; i < checkBox.Items.Count; i++)
                {
                    checkBox.SetItemChecked(i, false);
                }
            }
        }
        private void MenuItem_Click(object sender, EventArgs e)
        {
            Dictionary<TabPage, CheckedListBox> tabPageList = new Dictionary<TabPage, CheckedListBox>
            {
                {
                    tabPage1,chkbBloodCircuit
                },
                {
                    tabPage2,chkbPunctureA
                },
                {
                    tabPage3,chkbPunctureV
                },
                {
                    tabPage4, chkbPunctureSN
                }
            };
            ToolStripMenuItem clickedItem = sender as ToolStripMenuItem;
            if ("すべて選択".Equals(clickedItem.AccessibilityObject.Name))
            {
                string tabPageName = tabControl1.SelectedTab.Name;
                foreach (KeyValuePair<TabPage, CheckedListBox> pair in tabPageList)
                {
                    if (pair.Key.Name.Equals(tabPageName))
                    {
                        ToggleCheckState(pair.Value, true);
                    }
                }
            }
            else if("すべて解除".Equals(clickedItem.AccessibilityObject.Name))
            {
                string tabPageName = tabControl1.SelectedTab.Name;
                foreach (KeyValuePair<TabPage, CheckedListBox> pair in tabPageList)
                {
                    if (pair.Key.Name.Equals(tabPageName))
                    {
                        ToggleCheckState(pair.Value, false);
                    }
                }
            }
        }
        private void menuMouseDown(object sender, MouseEventArgs e)
        {
            if (e.Button == MouseButtons.Right)
            {
                contextMenuStrip.Show(tabControl1, e.Location);
            }
        }
    }
}