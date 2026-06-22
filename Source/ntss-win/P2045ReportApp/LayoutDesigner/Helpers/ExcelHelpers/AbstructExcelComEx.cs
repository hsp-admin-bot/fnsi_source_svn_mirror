using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LayoutDesigner
{
    /// <summary>
    /// Microsoft Excel クラス専用共通メソッド抽象クラス
    /// </summary>
    public abstract class AbstructExcelComEx : System.IDisposable
    {
        #region 生成と破棄

        /// <summary>
        /// 管理対象オブジェクトを指定して、Microsoft Excel クラス専用共通メソッドクラスの新しいインスタンスを初期化します。
        /// </summary>
        /// <param name="aTarget"></param>
        protected AbstructExcelComEx(object aTarget)
        {
            if( aTarget == null )
                throw new System.ArgumentNullException("aTarget", "管理対象オブジェクトを正しく指定してください。");

            this.XlObject = aTarget;
        }

        #region IDisposable Support
        private bool disposedValue = false; // 重複する呼び出しを検出するには

        protected virtual void Dispose(bool disposing)
        {
            if( !disposedValue ) {
                if( disposing ) {
                    // no_TODO: マネージド状態を破棄します (マネージド オブジェクト)。
                }

                // done_TODO: アンマネージド リソース (アンマネージド オブジェクト) を解放し、下のファイナライザーをオーバーライドします。
                // done_TODO: 大きなフィールドを null に設定します。
                this.ReleaseXlObject();

                disposedValue = true;
            }
        }

        // done_TODO: 上の Dispose(bool disposing) にアンマネージド リソースを解放するコードが含まれる場合にのみ、ファイナライザーをオーバーライドします。
        ~AbstructExcelComEx()
        {
            // このコードを変更しないでください。クリーンアップ コードを上の Dispose(bool disposing) に記述します。
            Dispose(false);
        }

        // このコードは、破棄可能なパターンを正しく実装できるように追加されました。
        public void Dispose()
        {
            // このコードを変更しないでください。クリーンアップ コードを上の Dispose(bool disposing) に記述します。
            Dispose(true);
            // done_TODO: 上のファイナライザーがオーバーライドされる場合は、次の行のコメントを解除してください。
            GC.SuppressFinalize(this);
        }
        #endregion

        #endregion

        #region メンバプロパティ定義

        /// <summary>
        /// 管理対象オブジェクトへの参照の取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        protected object XlObject { get; private set; } = null;

        #endregion

        #region メンバ関数定義

        /// <summary>
        /// COM オブジェクトの参照を全て解放します。
        /// </summary>
        protected virtual void ReleaseXlObject()
        {
            int i = 0;

            try {
                if( XlObject == null ) return;
                do {
                    i = System.Runtime.InteropServices.Marshal.ReleaseComObject(XlObject);
                } while( i > 0 );
            }
            finally {
            }
        }

        #endregion
    }
}
