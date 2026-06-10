//----------------------------------------------------------------------------------------------------
//
//----------------------------------------------------------------------------------------------------
using System;
using System.Collections.Generic;
using System.Text;
using System.Windows.Forms;

////----------------------------------------------------------------------------------------------------
//// 名前空間:TdcLib
////----------------------------------------------------------------------------------------------------
//using TdcLib;

////----------------------------------------------------------------------------------------------------
//// 名前空間:TdcSocketLib
////----------------------------------------------------------------------------------------------------
using TdcSocketLib;
//----------------------------------------------------------------------------------------------------
//  名前空間:TdcViewLogLib
//----------------------------------------------------------------------------------------------------
//using TdcViewLogLib;
//----------------------------------------------------------------------------------------------------
//  名前空間:NKKLoggingLib
//----------------------------------------------------------------------------------------------------
using NKKLoggingLib;
using NKKCommon;

//----------------------------------------------------------------------------------------------------
//  名前空間:NKKWeightApp
//----------------------------------------------------------------------------------------------------
namespace NKKWeightApp
{
    //----------------------------------------------------------------------------------------------------
    /// <summary>
    /// 
    /// </summary>
    //----------------------------------------------------------------------------------------------------
    public partial class FormViewLog : Form
    {
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 表示用ログ情報保持リスト
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private Dictionary<String, String> m_lstViewLogInfo = new Dictionary<String, String>();
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 画面タイトル
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private String m_strAppTitle = String.Empty;
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 初回表示フラグ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private bool m_bFirstShow = true;
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 終了フラグ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private bool m_bExit = false;
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// GUI待受への接続用クライアントソケットオブジェクト
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private TdcBaseSocketClient m_soc = new TdcBaseSocketClient( 1024 );
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 前回画面更新日時
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private DateTime m_BeforeRefreshDateTime = DateTime.MinValue;
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        ///  コンストラクタ
        /// <param name="port">外部GUI用ソケット待受ポート番号</param>
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        // mod FNSI-configから外部GUI用ソケット待受ポート番号を取得する 孫 start
        //public FormViewLog()
        public FormViewLog(int port)
        // mod FNSI-configから外部GUI用ソケット待受ポート番号を取得する 孫 end
        {
            InitializeComponent();

            // add #12209 体重計アプリ&ツール　アイコン差し替え 高 start
            this.Icon = Properties.Resources.NKKWeight;
            // add #12209 体重計アプリ&ツール　アイコン差し替え 高 end

            // 画面タイトル取得
            this.m_strAppTitle = this.Text;

            // 起動時は最小状態でタスクバーに表示されないように設定
            this.WindowState = FormWindowState.Minimized;
            this.ShowInTaskbar = false;

            // 
            this.notifyIcon.Icon = this.Icon;

            //ダブルバッファリングを有効化(ちらつき防止)
            this.DoubleBuffered = true;
            // Reflectionにて設定
            System.Type myType = typeof(ListView);
            System.Reflection.PropertyInfo myPropertyInfo = myType.GetProperty("DoubleBuffered", System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.NonPublic);
            myPropertyInfo.SetValue(this.listView, true, null);


            //項目初期化
            foreach(ListViewItem item in this.listView.Items)
            {
                //// 状態
                //item.SubItems[1].Text = String.Empty; ;
                // 更新日
                item.SubItems[2].Text = DateTime.Now.ToString("yyyy/MM/dd HH:mm:ss:ffff");
                // 内容
                item.SubItems[3].Text = String.Empty;
            }

            // add mongodbに転載、サーバー起動ログ 黄 start
            LogManagement.LogMessage = "体重計アプリが起動しました。";
            LogManagement.SetLogingProperties();
            // add mongodbに転載、サーバー起動ログ 黄 end

            // クライアントソケット設定
            // mod FNSI-configから外部GUI用ソケット待受ポート番号を取得する 孫 start
            //this.m_soc.SetParams("127.0.0.1", 5011, 500);
            this.m_soc.SetParams("127.0.0.1", port, 500);
            // mod FNSI-configから外部GUI用ソケット待受ポート番号を取得する 孫 end
            this.m_soc.ReceivedHandler = this.ReceivedMessage;

            // クライアントソケット接続
            this.m_soc.StartConnect();
        }
        //----------------------------------------------------------------------------------------------------


        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// フォーム破棄時
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        //----------------------------------------------------------------------------------------------------
        private void Form1_FormClosing(object sender, FormClosingEventArgs e)
        {
            // 終了フラグがセットされていない場合
            if (this.m_bExit == false)
            {
                // 終了処理のキャンセル
                e.Cancel = true;

                // フォームの非表示
                this.Visible = false;
            }
        }
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// サービスからのメッセージ受信
        /// </summary>
        /// <param name="Sender">ベースオブジェクト</param>
        /// <param name="cRecvData">受信バッファ</param>
        /// <param name="nRecvSize">受信サイズ</param>
        //----------------------------------------------------------------------------------------------------
        private void ReceivedMessage( Object sender, Byte[] cRecvData, int nRecvSize )
        {
            // 受信データの文字列化
            String strdata = Encoding.UTF8.GetString(cRecvData, 0, nRecvSize);

            // 電文の分割
            String[] stritems = strdata.Split(new String[] { "\r\n"}, StringSplitOptions.RemoveEmptyEntries);
            foreach( String strline in stritems )
            {
                // 項目の分割
                String[] stritem = strline.Split('\t');

                // 処理履歴の保持
                if (this.m_lstViewLogInfo.ContainsKey(stritem[0]) == true)
                {
                    // 該当情報あり

                    //　更新
                    this.m_lstViewLogInfo[stritem[0]] = strline;
                }
                else
                {
                    // 該当情報なし

                    //　新規追加
                    this.m_lstViewLogInfo.Add(stritem[0], strline);
                }

                // 画面が表示されている場合
                if (this.Visible == true)
                {
                    // 画面更新(非同期:匿名メソッドによるデリゲート処理)
                    this.BeginInvoke((MethodInvoker)delegate ()
                    {
                        // 
                        ShowListView(strline);
                    });
                }
            }
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 画面表示
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        //----------------------------------------------------------------------------------------------------
        private void ToolStripMenuItem_View_Click(object sender, EventArgs e)
        {
            // 初回表示の場合
            if (this.m_bFirstShow == true)
            {
                // タスクバーへ表示するように再設定
                this.ShowInTaskbar = true;

                // 初回表示フラグをクリア
                this.m_bFirstShow = false;
            }

            // 表示状態を最小状態とする
            this.WindowState = FormWindowState.Minimized;

            // フォームの表示
            this.Visible = true;

            // 最小状態から元に戻す
            this.WindowState = FormWindowState.Normal; 

            // フォームをアクティブにする
            this.Activate(); 
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 終了
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        //----------------------------------------------------------------------------------------------------
        private void ToolStripMenuItem_Exit_Click(object sender, EventArgs e)
        {
            // 終了確認
            if (MessageBox.Show(this, "終了してもよろしいですか？", Application.ProductName, MessageBoxButtons.OKCancel, MessageBoxIcon.Question, MessageBoxDefaultButton.Button2) == DialogResult.OK)
            {
                // アイコンをトレイから取り除く
                this.notifyIcon.Visible = false;

                // アプリケーション終了のため、終了フラグをセット
                this.m_bExit = true;

                // アプリケーションの終了
                this.Close();
            }
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 選択項目コピー
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        //----------------------------------------------------------------------------------------------------
        private void ToolStripMenuItem_Copy_Click(object sender, EventArgs e)
        {
            // 選択項目チェック
            if (0 < this.listView.SelectedItems.Count)
            {
                // 選択項目分処理
                StringBuilder sbitem = new StringBuilder();
                foreach (ListViewItem item in this.listView.SelectedItems)
                {
                    // 記録内容：種別{TAB}状態{TAB}更新日時{TAB}発生内容{CRLF}
                    sbitem.AppendLine(String.Format("{0}\t{1}\t{2}\t{3}", item.Text, item.SubItems[1].Text, item.SubItems[2].Text, item.SubItems[3].Text));
                }

                // クリップボードへコピー
                Clipboard.SetText(sbitem.ToString(), TextDataFormat.UnicodeText);
            }
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 画面初回表示時
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        //----------------------------------------------------------------------------------------------------
        private void FormViewLog_Shown(object sender, EventArgs e)
        {
            // 処理履歴の表示
            foreach( KeyValuePair<String, String> item in this.m_lstViewLogInfo)
            {
                ShowListView(item.Value);
            }
        }
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ListView項目更新
        /// </summary>
        /// <param name="strData"></param>
        //----------------------------------------------------------------------------------------------------
        private void ShowListView( String strData )
        {
            try
            {
                // データの分割
                String[] stritem = strData.Split('\t');

                // データ表示
                int nidx = -1;
                switch (stritem[0].ToUpper())
                {
                    case "INFO":
                        this.Text = String.Format("{0}：{1}", this.m_strAppTitle , stritem[3]);
                        break;

                    case "SERVER":
                        nidx = 0;
                        break;

                    case "WEBSOCKET":
                        nidx = 1;
                        break;

                    case "FELICA":
                        nidx = 2;
                        break;

                    case "WEIGHTSCALE":
                        nidx = 3;
                        break;

                    case "PRINTER":
                        nidx = 4;
                        break;
                }
                if (0 <= nidx && nidx < this.listView.Items.Count)
                {
                    ListViewItem item = this.listView.Items[nidx];

                    // 状態
                    if( String.IsNullOrWhiteSpace(stritem[1]) == false )
                    {
                        item.SubItems[1].Text = stritem[1];
                    }
                    // 更新日
                    item.SubItems[2].Text = stritem[2];
                    // 内容
                    item.SubItems[3].Text = stritem[3];
                }
            }
            catch(Exception ex)
            {
            }
            finally
            {
            }
        }
    }
    //----------------------------------------------------------------------------------------------------
}//----------------------------------------------------------------------------------------------------
