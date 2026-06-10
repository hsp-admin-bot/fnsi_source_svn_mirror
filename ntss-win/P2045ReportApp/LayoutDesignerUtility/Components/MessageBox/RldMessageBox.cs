using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using System.Windows.Forms;

namespace LayoutDesignerUtilityLib
{
    /// <summary>
    /// 帳票レイアウトデザイナ用メッセージボックスクラス
    /// </summary>
    public class RldMessageBox
    {
        #region メンバ関数定義

        /// <summary>
        /// 指定したテキストを表示するメッセージ ボックスを表示します。
        /// </summary>
        /// <param name="aText"></param>
        /// <returns></returns>
        public static DialogResult Show(string aText)
        {
            return Show(null as IWin32Window, aText);
        }

        /// <summary>
        /// 指定したテキストとキャプションを表示するメッセージ ボックスを表示します。
        /// </summary>
        /// <param name="aText"></param>
        /// <param name="aCaption"></param>
        /// <returns></returns>
        public static DialogResult Show(string aText, string aCaption)
        {
            return Show(null, aText, aCaption);
        }

        /// <summary>
        /// 指定したテキスト、キャプション、およびボタンを表示するメッセージ ボックスを表示します。
        /// </summary>
        /// <param name="aText"></param>
        /// <param name="aCaption"></param>
        /// <param name="aButtons"></param>
        /// <returns></returns>
        public static DialogResult Show(string aText, string aCaption, MessageBoxButtons aButtons)
        {
            return Show(null, aText, aCaption, aButtons, MessageBoxIcon.None);
        }

        /// <summary>
        /// 指定したテキスト、キャプション、ボタン、およびアイコンを表示するメッセージ ボックスを表示します。
        /// </summary>
        /// <param name="aText"></param>
        /// <param name="aCaption"></param>
        /// <param name="aButtons"></param>
        /// <param name="aIcon"></param>
        /// <returns></returns>
        public static DialogResult Show(string aText, string aCaption, MessageBoxButtons aButtons, MessageBoxIcon aIcon)
        {
            return Show(null, aText, aCaption, aButtons, aIcon, MessageBoxDefaultButton.Button1);
        }

        /// <summary>
        /// 指定したテキスト、キャプション、ボタン、アイコン、および既定のボタンを表示するメッセージ ボックスを表示します。
        /// </summary>
        /// <param name="aText"></param>
        /// <param name="aCaption"></param>
        /// <param name="aButtons"></param>
        /// <param name="aIcon"></param>
        /// <param name="aDefaultButton"></param>
        /// <returns></returns>
        public static DialogResult Show(string aText, string aCaption, MessageBoxButtons aButtons, MessageBoxIcon aIcon, MessageBoxDefaultButton aDefaultButton)
        {
            return Show(null, aText, aCaption, aButtons, aIcon, aDefaultButton);
        }


        /// <summary>
        /// 指定したオブジェクトの前に、指定したテキストを表示するメッセージ ボックスを表示します。
        /// </summary>
        /// <param name="aOwner"></param>
        /// <param name="aText"></param>
        /// <returns></returns>
        public static DialogResult Show(IWin32Window aOwner, string aText)
        {
            return Show(aOwner, aText, string.Empty);
        }

        /// <summary>
        /// 指定したオブジェクトの前に、指定したテキストとキャプションを表示するメッセージ ボックスを表示します。
        /// </summary>
        /// <param name="aOwner"></param>
        /// <param name="aText"></param>
        /// <param name="aCaption"></param>
        /// <returns></returns>
        public static DialogResult Show(IWin32Window aOwner, string aText, string aCaption)
        {
            return Show(aOwner, aText, aCaption, MessageBoxButtons.OK);
        }

        /// <summary>
        /// 指定したオブジェクトの前に、指定したテキスト、キャプション、およびボタンを表示するメッセージ ボックスを表示します。
        /// </summary>
        /// <param name="aOwner"></param>
        /// <param name="aText"></param>
        /// <param name="aCaption"></param>
        /// <param name="aButtons"></param>
        /// <returns></returns>
        public static DialogResult Show(IWin32Window aOwner, string aText, string aCaption, MessageBoxButtons aButtons)
        {
            return Show(aOwner, aText, aCaption, aButtons, MessageBoxIcon.None);
        }

        /// <summary>
        /// 指定したオブジェクトの前に、指定したテキスト、キャプション、ボタンおよびアイコンを表示するメッセージ ボックスを表示します。
        /// </summary>
        /// <param name="aOwner"></param>
        /// <param name="aText"></param>
        /// <param name="aCaption"></param>
        /// <param name="aButtons"></param>
        /// <param name="aIcon"></param>
        /// <returns></returns>
        public static DialogResult Show(IWin32Window aOwner, string aText, string aCaption, MessageBoxButtons aButtons, MessageBoxIcon aIcon)
        {
            return Show(aOwner, aText, aCaption, aButtons, aIcon, MessageBoxDefaultButton.Button1);
        }

        /// <summary>
        /// 指定したオブジェクトの前に、指定したテキスト、キャプション、ボタン、アイコン、および既定のボタンを表示するメッセージ ボックスを表示します。
        /// </summary>
        /// <param name="aOwner"></param>
        /// <param name="aText"></param>
        /// <param name="aCaption"></param>
        /// <param name="aButtons"></param>
        /// <param name="aIcon"></param>
        /// <param name="aDefaultButton"></param>
        /// <returns></returns>
        public static DialogResult Show(IWin32Window aOwner,string aText, string aCaption, MessageBoxButtons aButtons, MessageBoxIcon aIcon, MessageBoxDefaultButton aDefaultButton)
        {
            return MessageBox.Show(aOwner, aText, aCaption, aButtons, aIcon, aDefaultButton);
        }

        #endregion
    }
}
