using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LayoutDesigner
{
    /// <summary>
    /// デザイン画面で使用する Mediator / Colleague 用イベントデータクラス
    /// </summary>
    public abstract class RldDesignNotifyInfoEventArgs : System.EventArgs
    {
        #region メンバ列挙体定義

        /// <summary>
        /// 通知種別用列挙体
        /// </summary>
        public enum EnumInfoType
        {
            /// <summary>
            /// アプリケーション終了要求
            /// </summary>
            RequestCloseApp,
            /// <summary>
            /// 例外記録要求
            /// </summary>
            RequestRecordException,
            /// <summary>
            /// メッセージボックス表示要求
            /// </summary>
            RequestShowMessage,
            /// <summary>
            /// ダイアログ表示要求
            /// </summary>
            RequestOpenDialog,
            /// <summary>
            /// ドラッグアンドドロップ状態変更通知
            /// </summary>
            NotifyDragDropStatusChanged,
            /// <summary>
            /// ドラッグアンドドロップ操作完了通知
            /// </summary>
            NotifyDragDropCompleted,
            /// <summary>
            /// 選択パラメータ変更通知
            /// </summary>
            NotifySelectedParamChanged,
            /// <summary>
            /// パラメータ編集データクリア要求
            /// </summary>
            RequestRemoveAllParam,
            /// <summary>
            /// プレビュー表示要求
            /// </summary>
            RequestPreview,
            /// <summary>
            /// ファイル保存/破棄要求
            /// </summary>
            RequestSaveDropFile
        }

        #endregion

        #region 生成と破棄

        /// <summary>
        /// 通知種別を指定して、デザイン画面で使用する Mediator / Colleague 用イベントデータクラスの新しいインスタンスを初期化します。
        /// </summary>
        /// <param name="aType"></param>
        protected RldDesignNotifyInfoEventArgs(EnumInfoType aType)
        {
            this.InfoType = aType;
        }

        #endregion

        #region メンバプロパティ定義

        /// <summary>
        /// 通知種別の取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        public EnumInfoType InfoType { get; }
        
        #endregion

    }
}
