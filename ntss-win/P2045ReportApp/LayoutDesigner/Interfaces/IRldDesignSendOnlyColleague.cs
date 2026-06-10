using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LayoutDesigner
{
    /// <summary>
    /// デザイン画面送信専用 Colleague インターフェース
    /// </summary>
    public interface IRldDesignSendOnlyColleague : IRldDesignColleague
    {
        /// <summary>
        /// メッセージ通知用イベント
        /// </summary>
        event EventHandler<RldDesignNotifyInfoEventArgs> NotifyInfo;
    }
}
