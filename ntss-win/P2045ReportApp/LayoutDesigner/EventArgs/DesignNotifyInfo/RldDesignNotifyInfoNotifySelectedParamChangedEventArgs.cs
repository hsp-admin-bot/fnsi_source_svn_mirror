using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LayoutDesigner
{
    /// <summary>
    /// パラメータ一覧表示画面での選択パラメータ変更通知用データ
    /// </summary>
    public class RldDesignNotifyInfoNotifySelectedParamChangedEventArgs : RldDesignNotifyInfoEventArgs
    {
        #region 生成と破棄

        /// <summary>
        /// 変更先のセルアドレスを指定してパラメータ一覧表示画面での選択パラメータ変更通知用データの新しいインスタンスを初期化します。
        /// </summary>
        /// <param name="aCellAddress"></param>
        public RldDesignNotifyInfoNotifySelectedParamChangedEventArgs(String aCellAddress) : base(EnumInfoType.NotifySelectedParamChanged)
        {
            this.CellAddress = aCellAddress;
        }

        #endregion

        #region メンバプロパティ定義

        /// <summary>
        /// 変更先セルアドレスの取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        public String CellAddress { get; private set; } = String.Empty;

        #endregion
    }
}
