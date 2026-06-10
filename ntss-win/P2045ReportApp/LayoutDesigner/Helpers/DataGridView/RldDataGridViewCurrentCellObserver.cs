using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LayoutDesigner
{
    /// <summary>
    /// 帳票レイアウトデザイナ用 DataGridViewCell の 現在セル変更監視クラス
    /// </summary>
    public class RldDataGridViewCurrentCellObserver
    {
        #region メンバイベント定義

        /// <summary>
        /// 現在のセルの位置が変更された後に通知されます。
        /// </summary>
        public event EventHandler CurrentCellChanged;

        #endregion

        #region 生成と破棄

        /// <summary>
        /// 監視対象の DataGridView を指定して、帳票レイアウトデザイナ用 DataGridViewCell の CurrentCell 変更監視クラスの新しいインスタンスを初期化します。
        /// </summary>
        /// <param name="aTarget"></param>
        /// <param name="aColumnName"></param>
        public RldDataGridViewCurrentCellObserver(System.Windows.Forms.DataGridView aTarget)
        {
            // イベントハンドラ割り当て
            aTarget.CurrentCellChanged += new EventHandler(this.Target_CurrentCellChanged);
        }

        #endregion

        #region メンバプロパティ定義

        /// <summary>
        /// 行の変更があったかどうかの取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        public Boolean IsRowChanged { get; protected set; } = false;

        /// <summary>
        /// 列の変更があったかどうかの取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        public Boolean IsColumnChanged { get; protected set; } = false;

        /// <summary>
        /// 変更前のセル位置の取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        public System.Drawing.Point OldCellAddress { get; protected set; } = System.Drawing.Point.Empty;

        /// <summary>
        /// 変更後のセル位置の取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        public System.Drawing.Point NewCellAddress { get; protected set; } = System.Drawing.Point.Empty;

        /// <summary>
        /// セルアドレスのバックアップの取得及び設定を行います。
        /// </summary>
        protected System.Drawing.Point BackupCellAddress { get; set; } = System.Drawing.Point.Empty;

        #endregion

        #region メンバ関数定義

        /// <summary>
        /// CurrentCellChanged イベントを発生させます。
        /// </summary>
        /// <param name="e"></param>
        protected virtual void OnCurrentCellChanged(System.EventArgs e)
        {
            this.CurrentCellChanged?.Invoke(this, e);
        }

        #endregion

        #region イベントハンドラ定義

        /// <summary>
        /// DataGridView の CurrentCellChanged イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void Target_CurrentCellChanged(object sender, EventArgs e)
        {
            var wDataGridView = sender as System.Windows.Forms.DataGridView;
            if( !wDataGridView.ContainsFocus ) return;

            Boolean wIsRowChanged = false, wIsColChanged = false;

            // 移動距離を取得
            var wSubtruct = System.Drawing.Point.Subtract(this.BackupCellAddress, (System.Drawing.Size)wDataGridView.CurrentCellAddress);

            // 列移動チェック
            if( wSubtruct.X != 0 ) wIsColChanged = true;
            // 行移動チェック
            if( wSubtruct.Y != 0 ) wIsRowChanged = true;

            // 変更があった場合は通知する
            if( wIsColChanged || wIsRowChanged ) {

                this.IsColumnChanged = wIsColChanged;
                this.IsRowChanged = wIsRowChanged;
                this.OldCellAddress = this.BackupCellAddress;
                this.NewCellAddress = wDataGridView.CurrentCellAddress;

                this.OnCurrentCellChanged(new System.EventArgs());

                // 現在の選択セルアドレスを記憶しておく
                this.BackupCellAddress = wDataGridView.CurrentCellAddress;
            }
        }

        #endregion
    }
}
