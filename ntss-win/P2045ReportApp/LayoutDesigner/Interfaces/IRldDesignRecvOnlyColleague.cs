using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LayoutDesigner
{
    /// <summary>
    /// デザイン画面受信専用 Colleague インターフェース
    /// </summary>
    public interface IRldDesignRecvOnlyColleague : IRldDesignColleague
    {
        /// <summary>
        /// 送信可能 Colleague からの通知受信用ハンドラ関数
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        void ReceiveNotifyInfo(object sender, RldDesignNotifyInfoEventArgs e);
    }
}
