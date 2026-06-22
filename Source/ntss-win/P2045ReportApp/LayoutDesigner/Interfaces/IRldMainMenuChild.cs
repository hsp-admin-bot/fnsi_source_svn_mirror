using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LayoutDesigner
{
    public interface IRldMainMenuChild
    {
        /// <summary>
        /// メッセージ通知用イベント
        /// </summary>
        event EventHandler<RldMainMenuNotifyInfoEventArgs> NotifyInfo;

        /// <summary>
        /// メインメニュー からの通知受信用ハンドラ関数
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        void ReceiveNotifyInfo(object sender, RldMainMenuNotifyInfoEventArgs e);
    }
}
