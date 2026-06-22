using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LayoutDesigner
{
    /// <summary>
    /// 非アクティブ化を許可するかどうかを示すパラメータデータクラス
    /// </summary>
    public class RldMainMenuNotifyInfoCheckDeactiveEventArgs : RldMainMenuNotifyInfoEventArgs
    {
        #region 生成と破棄

        /// <summary>
        /// 非アクティブ化を許可するかどうかを示すパラメータデータクラスの新しいインスタンスを初期化します。
        /// </summary>
        public RldMainMenuNotifyInfoCheckDeactiveEventArgs() : base(EnumInfoType.Deactive) { }

        #endregion

        #region メンバプロパティ定義

        /// <summary>
        /// 非アクティブ化をキャンセルするかどうかの取得及び設定を行います。
        /// </summary>
        public Boolean Cancel { get; set; } = false;

        #endregion
    }
}
