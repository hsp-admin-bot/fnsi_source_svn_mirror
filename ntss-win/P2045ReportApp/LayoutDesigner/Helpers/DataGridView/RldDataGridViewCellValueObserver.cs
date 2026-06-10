using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LayoutDesigner
{
    /// <summary>
    /// 帳票レイアウトデザイナ用 DataGridViewCell の Value 変更監視クラス
    /// </summary>
    /// <typeparam name="T"></typeparam>
    public abstract class RldDataGridViewCellValueObserver<T>
    {
        #region メンバイベント定義

        /// <summary>
        /// セルの値が変更された後に通知されます。
        /// </summary>
        public event EventHandler CellValueChanged;

        #endregion

        #region 生成と破棄

        /// <summary>
        /// 監視対象の DataGridView と監視対象列のインデックスを指定して、帳票レイアウトデザイナ用 DataGridViewCell の Value 変更監視クラスの新しいインスタンスを初期化します。
        /// </summary>
        /// <param name="aTarget"></param>
        /// <param name="aColumnIndex"></param>
        protected RldDataGridViewCellValueObserver(System.Windows.Forms.DataGridView aTarget, Int32 aColumnIndex) : this(aTarget, aTarget.Columns[aColumnIndex].Name) { }
        
        /// <summary>
        /// 監視対象の DataGridView と監視対象列の列名を指定して、帳票レイアウトデザイナ用 DataGridViewCell の Value 変更監視クラスの新しいインスタンスを初期化します。
        /// </summary>
        /// <param name="aTarget"></param>
        /// <param name="aColumnName"></param>
        protected RldDataGridViewCellValueObserver(System.Windows.Forms.DataGridView aTarget, String aColumnName)
        {
            this.ColumnName = aColumnName;
            // イベントハンドラ割り当て
            aTarget.CellBeginEdit += new System.Windows.Forms.DataGridViewCellCancelEventHandler(this.Target_CellBeginEdit);
            aTarget.CellEndEdit += new System.Windows.Forms.DataGridViewCellEventHandler(this.Target_CellEndEdit);
        }

        #endregion

        #region メンバプロパティ定義

        /// <summary>
        /// 監視対象列の取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        protected String ColumnName { get; private set; } = String.Empty;

        /// <summary>
        /// セルのバックアップ値の取得及び設定を行います。
        /// </summary>
        protected T CellBackupValue { get; set; } = default(T);

        /// <summary>
        /// 変更があった列インデックスの取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        public Int32 ColumnIndex { get; protected set; } = -1;

        /// <summary>
        /// 変更があった行インデックスの取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        public Int32 RowIndex { get; protected set; } = -1;

        /// <summary>
        /// 変更前のセルの値の取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        public T OldValue { get; protected set; } = default(T);

        /// <summary>
        /// 変更後のセルの値の取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        public T NewValue { get; protected set; } = default(T);

        #endregion

        #region メンバ関数定義

        /// <summary>
        /// 指定した列名が監視対象列かどうか確認します。
        /// </summary>
        /// <param name="aColumnName"></param>
        /// <returns></returns>
        protected virtual Boolean IsTargetColumn(String aColumnName)
        {
            return aColumnName == this.ColumnName;
        }

        /// <summary>
        /// OnCellValueChanged イベントは発行します。
        /// </summary>
        /// <param name="e"></param>
        protected void OnCellValueChangedHandler(System.EventArgs e)
        {
            this.CellValueChanged?.Invoke(this, e);
        }

        #endregion

        #region イベントハンドラ定義

        /// <summary>
        /// DataGridView の CellBeginEdit イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void Target_CellBeginEdit(object sender, System.Windows.Forms.DataGridViewCellCancelEventArgs e)
        {
            var wDataGridView = sender as System.Windows.Forms.DataGridView;

            // 監視対象列ではない場合は抜ける
            if( !this.IsTargetColumn(wDataGridView.Columns[e.ColumnIndex].Name) ) return;

            this.ColumnIndex = -1;
            this.RowIndex = -1;
            this.OldValue = default(T);
            this.NewValue = default(T);

            // セルの値をバックアップ
            this.CellBackupValue = (T)wDataGridView[e.ColumnIndex, e.RowIndex].Value;
        }

        /// <summary>
        /// DataGridView の CellEndEdit イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void Target_CellEndEdit(object sender, System.Windows.Forms.DataGridViewCellEventArgs e)
        {
            var wDataGridView = sender as System.Windows.Forms.DataGridView;

            // 監視対象列ではない場合は抜ける
            if( !this.IsTargetColumn(wDataGridView.Columns[e.ColumnIndex].Name) ) return;

            // 編集後のデータを取得
            var wCurrentValue = (T)wDataGridView[e.ColumnIndex, e.RowIndex].Value;

            // 変更されていたら通知する
            if( !Comparer<T>.Equals(this.CellBackupValue, wCurrentValue) ) {
                this.ColumnIndex = e.ColumnIndex;
                this.RowIndex = e.RowIndex;
                this.OldValue = this.CellBackupValue;
                this.NewValue = wCurrentValue;

                this.OnCellValueChangedHandler(new System.EventArgs());
            }
        }

        #endregion
    }
}
