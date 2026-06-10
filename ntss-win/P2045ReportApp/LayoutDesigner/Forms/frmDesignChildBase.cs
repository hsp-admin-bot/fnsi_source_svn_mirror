using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using LayoutDesigner.Helpers;

namespace LayoutDesigner
{
    /// <summary>
    /// デザイン子画面
    /// </summary>
    public partial class frmDesignChildBase
        : LayoutDesignerUtilityLib.Controls.frmRldSizableBase, IRldDesignSendOnlyColleague, IRldDesignRecvOnlyColleague
    {
        #region メンバイベント定義

        /// <summary>
        /// 通知用イベント
        /// </summary>
        public event EventHandler<RldDesignNotifyInfoEventArgs> NotifyInfo;

        /// <summary>
        /// デザイン子画面がアクティブになったことを通知する
        /// </summary>
        public event EventHandler DesignChildActivated;

        #endregion

        #region 生成と破棄

        /// <summary>
        /// 
        /// </summary>
        public frmDesignChildBase()
        {
            InitializeComponent();

            // アイコンの設定
            this.Icon = Properties.Resources.LayoutDesigner;
        }

        #endregion

        #region メンバ関数定義(override...)
        #endregion

        #region メンバ関数定義

        /// <summary>
        /// 通知イベント受信時処理を行います。
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected virtual void ReceiveNotifyInfo(object sender, RldDesignNotifyInfoEventArgs e) { }

        /// <summary>
        /// 通知イベントを発行します。
        /// </summary>
        /// <param name="e"></param>
        protected virtual void SendNotifyInfo(Object sender, RldDesignNotifyInfoEventArgs e) => this.NotifyInfo?.Invoke(sender, e);

        /// <summary>
        /// 通知イベント受信時処理を行います。
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        void IRldDesignRecvOnlyColleague.ReceiveNotifyInfo(object sender, RldDesignNotifyInfoEventArgs e) => this.ReceiveNotifyInfo(sender, e);

        #endregion

        private void FrmDesignChildBase_Activated(object sender, EventArgs e)
        {
            try
            {
                // ローディング/ダイアログが現在操作中のモニタへ出るように記録する。
                LoadingHelper.SetPreferredWorkingArea(this);

                // イベントを発生させる
                if (DesignChildActivated != null)
                {
                    System.Diagnostics.Debug.Print(DateTime.Now.ToString() + " " + ((frmDesignChildBase)sender).Name + " でActivatedイベント発生");
                    this.DesignChildActivated(sender, e);
                }

            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.Print(ex.ToString());
                // メッセージボックスを表示せずにログ記録する
                LayoutDesignerUtilityLib.LayoutDesignerUtility.RecordException(ex, false);
            }

        }

        /// <summary>
        /// ShowWithoutActivation?をオーバーライドしtrueを返す.3つの子ウインドウを相互に全面表示するために必要な処理
        /// </summary>
        protected override bool ShowWithoutActivation => true;

    }
}
