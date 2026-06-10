using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LayoutDesigner
{
    /// <summary>
    /// メッセージボックス表示要求通知データ
    /// </summary>
    public class RldDesignNotifyInfoRequestShowMessageEventArgs : RldDesignNotifyInfoEventArgs
    {
        #region 生成と破棄

        /// <summary>
        /// メッセージボックス表示要求通知データの新しいインスタンスを初期化します。
        /// </summary>
        public RldDesignNotifyInfoRequestShowMessageEventArgs() : base(EnumInfoType.RequestShowMessage) { }

        #endregion

        #region メンバプロパティ定義

        /// <summary>
        /// メッセージボックスのキャプションの取得及び設定を行います。
        /// </summary>
        public string Caption { get; set; } = string.Empty;

        /// <summary>
        /// メッセージボックスのテキストの取得及び設定を行います。
        /// </summary>
        public string Text { get; set; } = string.Empty;

        /// <summary>
        /// メッセージボックスに表示するボタンの取得及び設定を行います。
        /// </summary>
        public System.Windows.Forms.MessageBoxButtons Buttons { get; set; } = System.Windows.Forms.MessageBoxButtons.OK;

        /// <summary>
        /// メッセージボックスに表示するアイコンの取得及び設定を行います。
        /// </summary>
        public System.Windows.Forms.MessageBoxIcon Icon { get; set; } = System.Windows.Forms.MessageBoxIcon.None;

        /// <summary>
        /// メッセージボックスの既定のボタンの取得及び設定を行います。
        /// </summary>
        public System.Windows.Forms.MessageBoxDefaultButton DefaultButton { get; set; } = System.Windows.Forms.MessageBoxDefaultButton.Button1;

        /// <summary>
        /// メッセージボックスを表示する場合に指定するオプションの取得及び設定を行います。
        /// </summary>
        public System.Windows.Forms.MessageBoxOptions Options { get; set; }

        /// <summary>
        /// メッセージボックスの表示結果の取得及び設定を行います。
        /// </summary>
        public System.Windows.Forms.DialogResult DialogResult { get; set; } = System.Windows.Forms.DialogResult.None;

        #endregion
    }
}
