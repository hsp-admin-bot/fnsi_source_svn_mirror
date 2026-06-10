using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Reflection;
using System.Windows.Forms;
using Oracle.DataAccess.Client;

namespace jp.co.nikkiso.fn3.Cooperation.CSICoop
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        private void button1_Click(object sender, EventArgs e)
        {
#region ODP接続テストコード
            OracleConnection OraConn = new OracleConnection();
            OraConn.ConnectionString = "Data Source=NKKFN3;User ID=nkk;Password=nkk";
            string strSQL = "SELECT TO_CHAR(SYSDATE, 'YYYY/MM/DD HH24:MI:SS') FROM DUAL";
            OracleCommand OraCmd = new OracleCommand(strSQL, OraConn);
            OraConn.Open();
            OracleDataReader OraReader;
            OraReader = OraCmd.ExecuteReader();
            String strResult = "";
            while (OraReader.Read())
            {
                strResult += OraReader.GetString(0);
            }
            OraReader.Close();
            OraConn.Close();
            MessageBox.Show(strResult);
#endregion

            object oDbObject = null;
            bool bInRet = false;

            // CSI連携I/F共通オブジェクト取得
            object oJMSCOMMON;
            oJMSCOMMON = CSICommonMethod.CreateObject(CSICommonConst.CSIPROGRAMID_COMMON);
//            oJMSCOMMON = CSICommon.CreateObject("JMSCOMMON.clsProcessEvent");
            
            // CSI患者属性検索オブジェクト取得
            object oJMSPATSCH;
            oJMSPATSCH = CSICommonMethod.CreateObject(CSICommonConst.CSIPROGRAMID_PATSCH);

            // DB接続オブジェクトの取得
            bInRet = CSICommonMethod.pDbOpen(oJMSCOMMON, ref oDbObject, ref CSICommon.colERR);
            if (bInRet)
            {
                MessageBox.Show(oDbObject.GetType().FullName);
            }
            else
            {
                MessageBox.Show(oDbObject.GetType().FullName);
                MessageBox.Show("DB接続オブジェクト取れてない");
            }
           
            if(bInRet)
            {
                // 患者属性検索の入力パラメータ設定
                CSICommon.varINPARAM = new object[1];
                CSICommon.varINPARAM[0] = "00000002";
//                CSICommon.varINPARAM[0] = "90000001";

                // 患者属性検索呼び出し
                bInRet = CSICommonMethod.pPatSch(oJMSPATSCH, 
                                           CSICommon.varINPARAM, 
                                           ref CSICommon.varPATSCH, 
                                           ref CSICommon.colERR, 
                                           oDbObject);

                if (bInRet)
                {
                    // エラー数をチェック
                    // ※検索結果0件の場合、検索メソッド自体は成功で返る
                    if (CSICommon.pGetERRCollectionCount() == 0)
                    {
                        string sString;
                        sString = CSICommon.varPATSCH[CSICommon.CON_PAT_PATIENTNO].ToString();
                        MessageBox.Show("Get: " + sString);
                        sString = CSICommon.varPATSCH[CSICommon.CON_PAT_PATIENTNM].ToString();
                        MessageBox.Show("Get: " + sString);
                        sString = CSICommon.varPATSCH[CSICommon.CON_PAT_PATIENTNMKANA].ToString();
                        MessageBox.Show("Get: " + sString);
                        sString = CSICommon.varPATSCH[CSICommon.CON_PAT_BIRTHDAY].ToString();
                        MessageBox.Show("Get: " + sString);
                    }
                    else
                    {
                        showError("pPatSch");
                    }

                    // DB接続オブジェクトの解放
                    bInRet = CSICommonMethod.pDbClose(oJMSCOMMON, oDbObject, ref CSICommon.colERR);
                    if (!bInRet)
                    {
                        showError("db close");
                    }
                    else
                    {
                        MessageBox.Show(oDbObject.ToString());
                    }

                }
                else
                {
                    showError("load DB");
                }
            }
            else
            {
                showError("db connect");
            }
        }

        public enum CONFIRMINFO
        {
            NO = 0,
            YES,
            ALARM,
        }
        /// <summary>
        /// 通知種別を設定する 
        /// (ここを更新する場合は、DBアプリのMultiCastConnect.csも更新する)
        /// </summary>
        private enum NOTIFYTYPE
        {
            /// <summary>血圧未測定</summary>
            UN_BLOOD_MESURE = 0,
            /// <summary>ケア報知</summary>
            UN_CARE,
            /// <summary>ベッド未登録</summary>
            UN_BED_ENTRY,
            /// <summary>未割付患者</summary>
            UN_ALLOCATION,
            /// <summary>未送信患者</summary>
            UN_SENT,
            /// <summary>指示変更</summary>
            REVISE,
            /// <summary>新規装置接続</summary>
            NEW_DEVICE_CONNECT,
            /// <summary>装置接続情報</summary>
            DEVICE_CONNECT_INFO,
            /// <summary>オプション読み込み</summary>
            DEVICE_OPTION_READ,
            /// <summary>警報/報知(全体)</summary>
            DEVICE_ALARM_ALL,
            /// <summary>警報(個別)</summary>
            DEVICE_ALARM_PERSONAL,
            /// <summary>報知(個別)</summary>
            DEVICE_ALARM_NOTIFY_PERSONAL,
        }

        /// <summary>
        /// エラー内容表示サンプル処理
        /// </summary>
        /// <param name="value"></param>
        private void showError(string value)
        {
            int iCount = CSICommon.pGetERRCollectionCount();
            MessageBox.Show("["+ value +"] colERR count: " + iCount.ToString());

            object oColKey = string.Empty;
            string sErrLevel = string.Empty;
            string sErrCode = string.Empty;
            string sErrText = string.Empty;

            for (int i = 1; i <= iCount; i++)
            {
                CSICommon.pGetERRCollectionItem(i, ref sErrLevel, ref sErrCode, ref sErrText);
                String strErrMsg = "colERR(" + i.ToString() + ") is: " + oColKey + "/" + sErrLevel + "/" + sErrCode + "/" + sErrText;
                MessageBox.Show(strErrMsg);

                // アラーム送信テスト
                //System.IO.File.AppendAllText(Application.StartupPath + "\\log.txt", strErrMsg);

                //String strAlarmMsg = NOTIFYTYPE.DEVICE_ALARM_ALL.GetHashCode().ToString() + "," 
                //                   + CONFIRMINFO.NO.GetHashCode().ToString() + "," 
                //                   + String.Format("{0},{1},,,,,,{2},{3}", "1234", strErrMsg.Replace(",", ""), "", "");


                //byte[] data = Encoding.UTF8.GetBytes(strAlarmMsg);
                //System.IO.File.AppendAllText(Application.StartupPath + "\\log.txt", data.Length.ToString());

                
                ////▼-- 2009.12.21 T.Kijima Add ソケットの接続確立 --▼
                ////ブロードキャスト設定
                //System.Net.Sockets.UdpClient server2 = new System.Net.Sockets.UdpClient(9050);
                //int nSendLength = server2.Send(data, data.Length, "192.168.10.1", 9051);
                //MessageBox.Show(nSendLength.ToString());
                //server2.Close();
                ////▲-- 2009.12.21 T.Kijima Add ソケットの接続確立 --▲
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void button2_Click(object sender, EventArgs e)
        {
            // コレクション生成クラスの使用テスト
            CollectionFactory.clsVBACollectionClass objVBACollection = new CollectionFactory.clsVBACollectionClass();
            VBA.Collection col = objVBACollection.CreateVBACollection();
            object obj;
            obj = "test01";
            objVBACollection.AddObject(ref col, ref obj);
            obj = "test02";
            objVBACollection.AddObject(ref col, ref obj);

            object idx = 1;
            MessageBox.Show(col.Item(ref idx).ToString());

        }

        private CollectionFactory.clsVBACollectionClass clsCollect = new CollectionFactory.clsVBACollectionClass();
        private VBA.Collection vbaCollection;

        private void button3_Click(object sender, EventArgs e)
        {
            vbaCollection = clsCollect.CreateVBACollection();
            try
            {
                for (int j = 1; j <= 10; j++)
                {
                    for (int i = 1; i <= 1000; i++)
                    {
                        object value = "テスト値" + i.ToString();
                        object key = (object)i;
                        clsCollect.AddObject2(ref vbaCollection, ref value, ref key);
                        //clsCollect.AddObject(ref vbaCollection, ref value);
                    }
                    //for (int i = 1; i <= 1000; i++)
                    //{
                    //    object key = (object)i;
                    //    clsCollect.RemoveObject(ref vbaCollection, ref key);
                    //    //vbaCollection.Remove(ref key);
                    //}
                    clsCollect.ClearVBACollection(ref vbaCollection);
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.ToString());
            }
            GC.Collect();
        }
    }
}
