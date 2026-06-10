using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using LayoutDesignerUtilityLib;

namespace LayoutDesigner
{
    /// <summary>
    /// デザイナーウィンドウ
    /// </summary>
    public partial class frmDesignChildLayout : frmDesignChildBase, IRldDesignMediator
    {
        #region メンバ変数定義

        /// <summary>
        /// イベント通知先格納用リスト
        /// </summary>
        private List<IRldDesignColleague> m_Colleagues = null;

        #endregion

        #region 生成と破棄

        /// <summary>
        /// デザイナーウィンドウクラスの新しいインスタンスを初期化します。
        /// </summary>
        public frmDesignChildLayout()
        {
            InitializeComponent();

            // Colleague リストを生成
            m_Colleagues = new List<IRldDesignColleague>();

            // パラメータ編集画面を初期化
            LFunc_AddFormToTabPage(tbpParam, new frmDesignChildLayoutParam());

            // テンプレート繰返しをサポートしている帳票種別の場合は初期化
            if (RldLib.CurrentLayoutData.DesignSettingData.IsSupportTempleteRepeat)
            {
                LFunc_AddFormToTabPage(tbpTmpl, new frmDesignChildLayoutTemplete());
            }
            else
            {
                tabDesigner.TabPages.Remove(tbpTmpl);
            }

            // グループ編集画面を初期化
            LFunc_AddFormToTabPage(tbpGroup, new frmDesignChildLayoutGroup());

            // add FNSI-699,700,751 装置帳票の記録簿対応 鄭 start
            if ("Device".Equals(RldLib.CurrentLayoutData.DesignSettingData.ReportClass))
            {
                LFunc_AddFormToTabPage(topDevice, new frmDesignChildLayoutDevice());
            }
            //add 2021-09-22 #6346 単一の患者の請求書を追加する 鄭 start
            // del #12403 単患者帳票編集でデザイナーウィンドウの「レイアウト」タブが不要 高 start
            //else if ("OnePatient".Equals(RldLib.CurrentLayoutData.DesignSettingData.ReportClass)) {

            //    LFunc_AddFormToTabPage(topDevice, new frmDesignChildLayoutDevice());
            //}
            // del #12403 単患者帳票編集でデザイナーウィンドウの「レイアウト」タブが不要 高 end
            // add FNSI-699,700,751 単一の患者の請求書を追加する 鄭 end
            else
            {
                tabDesigner.TabPages.Remove(topDevice);
            }
            // add FNSI-699,700,751 装置帳票の記録簿対応 夏 end

            // add FNSI-523 2次元帳票対応 夏 start
            if ("OneTotal".Equals(RldLib.CurrentLayoutData.DesignSettingData.ReportClass) || "MultiTotal".Equals(RldLib.CurrentLayoutData.DesignSettingData.ReportClass))
            {
                //  2次元帳票編集画面を初期化
                LFunc_AddFormToTabPage(tbpTotal, new frmDesignChildLayoutTotal());
                tabDesigner.TabPages.Remove(tbpTmpl);
            } // add #5714 紹介状が正しく出力できない 孟堅 start
            else if ("ReferralLetter".Equals(RldLib.CurrentLayoutData.DesignSettingData.ReportClass))
            {
                if ("".Equals(RldLib.totalLayoutData.ReportType) || RldLib.totalLayoutData.ReportType == null)
                {
                    // mod #11134 集計紹介状作成時のメッセージタイトルが不正 高 start
                    //DialogResult dialogResult = RldMessageBox.Show(this, "集計紹介状を作成しますか", "ていじ", MessageBoxButtons.YesNo, MessageBoxIcon.Question);
                    DialogResult dialogResult = RldMessageBox.Show(this, "集計紹介状を作成しますか", "確認", MessageBoxButtons.YesNo, MessageBoxIcon.Question);
                    // mod #11134 集計紹介状作成時のメッセージタイトルが不正 高 end
                    if (dialogResult == DialogResult.Yes)
                    {
                        RldLib.totalLayoutData.ReportType = "1";
                        LFunc_AddFormToTabPage(tbpTotal, new frmDesignChildLayoutTotal());
                        tabDesigner.TabPages.Remove(tbpTmpl);     
                    }
                    else
                    {
                        RldLib.totalLayoutData.ReportType = "2";
                        // add #11501 レイアウトデザイナのユーザビリティ改善 高 start
                        tabDesigner.TabPages.Remove(tbpTotal);
                        // add #11501 レイアウトデザイナのユーザビリティ改善 高 end
                    }

                }
                else if ("1".Equals(RldLib.totalLayoutData.ReportType))
                {
                    LFunc_AddFormToTabPage(tbpTotal, new frmDesignChildLayoutTotal());
                    tabDesigner.TabPages.Remove(tbpTmpl);
                }
                else 
                {
                    RldLib.totalLayoutData.ReportType = "2";
                    // add #11501 レイアウトデザイナのユーザビリティ改善 高 start
                    tabDesigner.TabPages.Remove(tbpTotal);
                    // add #11501 レイアウトデザイナのユーザビリティ改善 高 end
                }
            }
            // add #5714 紹介状が正しく出力できない 孟堅 end
            else
            {
                tabDesigner.TabPages.Remove(tbpTotal);
            }
            // add FNSI-523 2次元帳票対応 夏 end

            // (ローカル関数) 指定した System.Windows.Forms.TabPage 内に指定した System.Windows.Forms.Form をセットします。
            void LFunc_AddFormToTabPage(TabPage aPage, LayoutDesignerUtilityLib.Controls.frmRldBase aForm)
            {
                // フォームのプロパティを設定
                aForm.TopLevel = false;
                aForm.FormBorderStyle = FormBorderStyle.None;
                aForm.Dock = DockStyle.Fill;
                aForm.CloseEscapeKey = false;

                // タブページにフォームを追加
                aPage.Controls.Add(aForm);

                // 表示して最前面へ移動
                aForm.Show();
                aForm.BringToFront();

                var wColleague = aForm as IRldDesignSendOnlyColleague;
                if (wColleague != null)
                {
                    wColleague.NotifyInfo += new EventHandler<RldDesignNotifyInfoEventArgs>(ColleagueMessageHandler);
                    m_Colleagues.Add(wColleague);
                }
            }
        }

        #endregion

        #region メンバイベント定義

        /// <summary>
        /// 通知用イベント
        /// </summary>
        private event EventHandler<RldDesignNotifyInfoEventArgs> ChildLayoutNotifyInfo;

        #endregion

        #region メンバ関数定義(override)

        /// <summary>
        /// Form.FormClosing イベントを発生させます。
        /// </summary>
        /// <param name="e"></param>
        protected override void OnFormClosing(FormClosingEventArgs e)
        {
            base.OnFormClosing(e);

            if (!RldLib.IsStartDesignWindowClosing)
            {
                e.Cancel = true;
            }
        }

        /// <summary>
        /// 親 Mediator からのメッセージを受信します。
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected override void ReceiveNotifyInfo(object sender, RldDesignNotifyInfoEventArgs e)
        {
            base.ReceiveNotifyInfo(sender, e);

            // 配下の Colleague に対してイベントを通知
            m_Colleagues.ForEach(ele => SendNotifyInfo(sender, ele, e));
        }

        #endregion

        #region メンバ関数定義(Mediator)

        /// <summary>
        /// Colleague にメッセージを送信します。
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="aDestination"></param>
        /// <param name="e"></param>
        private void SendNotifyInfo(object sender, IRldDesignColleague aDestination, RldDesignNotifyInfoEventArgs e)
        {
            try
            {
                var wDestination = aDestination as IRldDesignRecvOnlyColleague;

                if (wDestination != null)
                {
                    ChildLayoutNotifyInfo += new EventHandler<RldDesignNotifyInfoEventArgs>(wDestination.ReceiveNotifyInfo);
                    ChildLayoutNotifyInfo(sender, e);
                    ChildLayoutNotifyInfo -= new EventHandler<RldDesignNotifyInfoEventArgs>(wDestination.ReceiveNotifyInfo);
                }
            }
            finally
            {
            }
        }

        /// <summary>
        /// Colleague からのメッセージを受信するハンドラ関数
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void ColleagueMessageHandler(object sender, RldDesignNotifyInfoEventArgs e)
        {
            // TODO: 送信元と内容で切り分け パラメータ画面と選択アイテム画面の連携

            // 親 Mediator にも通知
            base.SendNotifyInfo(sender, e);
        }

        /// <summary>
        /// 画面の表示を初期化します。
        /// </summary>
        private void InitWindowLayout()
        {
        }

        // add #12545 グループタブ上で異なるグループ名を同じにし、該当セルを選択すると致命的なエラーが発生する 高 start
        private bool _isProcessingDeactivate = false;
        private void frmDesignChildLayout_Deactivate(object sender, EventArgs e)
        {
            if (_isProcessingDeactivate) return;

            _isProcessingDeactivate = true;
            var wColleagues = this.m_Colleagues.SingleOrDefault(ele => ele.GetType() == typeof(frmDesignChildLayoutGroup));
            if (wColleagues != null)
            {
                frmDesignChildLayoutGroup childDataList = (frmDesignChildLayoutGroup)wColleagues;
                if (childDataList != null)
                {
                    childDataList.dgvGroupList_EndEdit();
                }
            }

            // add #12475 FNW帳票取込すると検査日が表示されない 高 start
            wColleagues = this.m_Colleagues.SingleOrDefault(ele => ele.GetType() == typeof(frmDesignChildLayoutParam));
            if (wColleagues != null)
            {
                frmDesignChildLayoutParam childDataList = (frmDesignChildLayoutParam)wColleagues;
                if (childDataList != null)
                {
                    childDataList.dgvList_EndEdit();
                }
            }
            // add #12475 FNW帳票取込すると検査日が表示されない 高 end

            _isProcessingDeactivate = false;
        }
        // add #12545 グループタブ上で異なるグループ名を同じにし、該当セルを選択すると致命的なエラーが発生する 高 end

        // add #12616 データ項目の縮小表示が機能しないことがある 高 start
        private bool _isProcessingActivated = false;
        private void frmDesignChildLayout_Activated(object sender, EventArgs e)
        {
            if (_isProcessingActivated) return;
            _isProcessingActivated = true;

            frmDesignChildLayoutParam.ProcessAtomicAddresses(RldLib.CurrentLayoutData.lastSelectAddr);

            _isProcessingActivated = false;
        }
        // add #12616 データ項目の縮小表示が機能しないことがある 高 end

        #endregion
    }
}
