using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LayoutDesigner
{
    /// <summary>
    /// 全パラメータ編集データクリア要求通知用データクラス
    /// </summary>
    public class RldDesignNotifyInfoRequestRemoveAllParamEventArgs : RldDesignNotifyInfoEventArgs
    {
        #region 生成と破棄

        /// <summary>
        /// 全パラメータ編集データクリア要求通知用データクラスの新しいインスタンスを初期化します。
        /// </summary>
        public RldDesignNotifyInfoRequestRemoveAllParamEventArgs() : base(EnumInfoType.RequestRemoveAllParam) { }

        #endregion

        #region メンバプロパティ定義
        #endregion
    }
}
