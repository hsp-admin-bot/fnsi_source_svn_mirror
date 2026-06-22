using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ToGUILib
{
    //----------------------------------------------------------------------------------------------------
    /// <summary>
    /// GUIへの通知クラス
    /// </summary>
    //----------------------------------------------------------------------------------------------------
    public class ToGUI
    {

#region デリゲート定義

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 通知用デリゲート定義
        /// </summary>
        /// <param name="strServiceName">サービス名</param>
        /// <param name="strStatus">状態</param>
        /// <param name="dtNow">発生日時</param>
        /// <param name="strMessage">送信するメッセージ</param>
        //----------------------------------------------------------------------------------------------------
        public delegate void dgtSendMessageToGUI(String strServiceName, String strStatus, DateTime dtNow, String strMessage );
        //----------------------------------------------------------------------------------------------------
#endregion

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 通知用イベントハンドラー
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private dgtSendMessageToGUI m_dgtSendMessageToGUIHandler = null;
        //----------------------------------------------------------------------------------------------------


#region パブリックプロパティ

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 通知用イベントハンドラー参照/設定用プロパティ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public dgtSendMessageToGUI SendMessageToGUIHandler
        {
            get { return (this.m_dgtSendMessageToGUIHandler); }
            set { this.m_dgtSendMessageToGUIHandler = value; }
        }
        //----------------------------------------------------------------------------------------------------
        
#endregion
#region アクセスは、コンテナ クラス、またはコンテナ クラスから派生した型に制限

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// GUIへのメッセージ通知
        /// </summary>
        /// <param name="strServiceName">サービス名</param>
        /// <param name="strStatus">状態</param>
        /// <param name="dtNow">発生日時</param>
        /// <param name="strMessage">送信するメッセージ</param>
        //----------------------------------------------------------------------------------------------------
        protected void SendMessageToGUI( String strServiceName, String strStatus, DateTime dtNow, String strMessage )
        {
            //this.SendMessageToGUIHandler?.Invoke(strServiceName, strStatus,dtNow, strMessage);

            if(this.SendMessageToGUIHandler != null)
            {
                var eventListeners = this.SendMessageToGUIHandler.GetInvocationList();
                for (int index = 0; index < eventListeners.Count(); index++)
                {
                    var methodToInvoke = (dgtSendMessageToGUI)eventListeners[index];
                    methodToInvoke.BeginInvoke(strServiceName, strStatus, dtNow, strMessage, EndAsyncEvent, null);
                }
            }
        }

        private void EndAsyncEvent(IAsyncResult iar)
        {
            var ar = (System.Runtime.Remoting.Messaging.AsyncResult)iar;
            var invokedMethod = (dgtSendMessageToGUI)ar.AsyncDelegate;

            try
            {
                invokedMethod.EndInvoke(iar);
            }
            catch
            {              
            }
        }
        //----------------------------------------------------------------------------------------------------

#endregion
    }
    //----------------------------------------------------------------------------------------------------
}
//----------------------------------------------------------------------------------------------------
