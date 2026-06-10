using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LayoutDesigner
{
    [Obsolete("必要か要再検討")]
    public class RldDesignNotifyInfoNotifyDragDropStatusChangedEventArgs : RldDesignNotifyInfoEventArgs
    {
        #region メンバ列挙体定義

        public enum EnumDragDropStatus
        {
            None = 0,
            Start,
            FinishDrop,
            FinishNoDrop
        }

        #endregion
        
        #region 生成と破棄

        public RldDesignNotifyInfoNotifyDragDropStatusChangedEventArgs(EnumDragDropStatus aStatus) : base(EnumInfoType.NotifyDragDropStatusChanged)
        {
            this.Status = aStatus;
        }

        #endregion

        #region メンバプロパティ定義

        public EnumDragDropStatus Status { get; private set; } = EnumDragDropStatus.None;

        #endregion


    }
}
