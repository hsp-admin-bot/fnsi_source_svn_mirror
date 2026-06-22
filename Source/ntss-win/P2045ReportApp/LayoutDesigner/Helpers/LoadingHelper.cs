using LayoutDesigner.Forms;
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace LayoutDesigner.Helpers
{
    /// <summary>
    /// add 2020-08-10 FNSI-仕様追加 ページロード関連クラスを追加する 李
    /// </summary>
    public class LoadingHelper
    {
        private delegate void CloseDelegate();
        private static frmLoading frmLoad = null;
        // owner を渡せない処理でも、直前に操作していた4画面のモニタへローディングを出す。
        private static Rectangle? preferredWorkingArea = null;
        // del #6453「帳票レイアウトデザイナーで帳票修正時にエラーメッセージが画面に表示される」について、修正する。 孫思遠 start
        // private static Thread thread = null;
        // del #6453「帳票レイアウトデザイナーで帳票修正時にエラーメッセージが画面に表示される」について、修正する。 孫思遠 end
        private static readonly Object syncLock = new Object();

        private LoadingHelper()
        {

        }

        /// <summary>
        /// ロードされたダイアログを開く
        /// </summary>
        public static void ShowLoadingDialog()
        {
            ShowLoadingDialog(preferredWorkingArea);
        }

        /// <summary>
        /// 指定した画面を基準にロードダイアログを開く
        /// </summary>
        /// <param name="owner"></param>
        public static void ShowLoadingDialog(IWin32Window owner)
        {
            var workingArea = GetWorkingArea(owner) ?? preferredWorkingArea;
            if (workingArea.HasValue)
            {
                preferredWorkingArea = workingArea;
            }

            ShowLoadingDialog(workingArea);
        }

        /// <summary>
        /// 指定した画面を以降のロードダイアログ表示位置として記録する
        /// </summary>
        /// <param name="owner"></param>
        public static void SetPreferredWorkingArea(IWin32Window owner)
        {
            var workingArea = GetWorkingArea(owner);
            if (workingArea.HasValue)
            {
                // 子画面のアクティブ化時に記録しておき、後続の非同期処理でも同じモニタを使う。
                preferredWorkingArea = workingArea;
            }
        }

        private static void ShowLoadingDialog(Rectangle? workingArea)
        {
            if (frmLoad != null)
                return;
            // mod #6453「帳票レイアウトデザイナーで帳票修正時にエラーメッセージが画面に表示される」について、修正する。 孫思遠 start
            // thread = new Thread(new ThreadStart(frmLoad.ShowLoadingDialog));
            // thread.IsBackground = true;
            // thread.SetApartmentState(ApartmentState.STA);
            // thread.Start();
            Task.Run(() => {
                frmLoad = workingArea.HasValue
                    ? new frmLoading(workingArea.Value)
                    : new frmLoading();
                frmLoad.ShowDialog();
            });
            // mod #6453「帳票レイアウトデザイナーで帳票修正時にエラーメッセージが画面に表示される」について、修正する。 孫思遠 end

        }

        private static Rectangle? GetWorkingArea(IWin32Window owner)
        {
            if (owner == null)
            {
                return null;
            }

            try
            {
                if (owner is Control control)
                {
                    return Screen.FromControl(control).WorkingArea;
                }
            }
            catch (Exception)
            {
            }

            return null;
        }

        /// <summary>
        /// ロードダイアログを閉じる
        /// </summary>
        public static void CloseLoadingDialog()
        {
            Thread.Sleep(50);
            if (frmLoad != null)
            {
                lock (syncLock)
                {
                    Thread.Sleep(50);
                    if (frmLoad != null)
                    {
                        Thread.Sleep(50);
                        try
                        {
                            if (!frmLoad.IsDisposed)
                            {
                                frmLoad.CloseForm();
                                frmLoad = null;
                            }
                            // del #6453「帳票レイアウトデザイナーで帳票修正時にエラーメッセージが画面に表示される」について、修正する。 孫思遠 start
                            // if (thread.IsAlive)
                            //     thread.Abort();
                            // del #6453「帳票レイアウトデザイナーで帳票修正時にエラーメッセージが画面に表示される」について、修正する。 孫思遠 end
                        }
                        catch (Exception ex){ }
                    }
                }
            }
        }
    }
}
