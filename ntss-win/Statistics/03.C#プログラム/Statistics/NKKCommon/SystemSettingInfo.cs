//----------------------------------------------------------------------------------------------------
//  システム共通設定
//  ※Singleton
//----------------------------------------------------------------------------------------------------
using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using System.Data;
using System.Xml;


#if DEBUG
    using System.Diagnostics;
#endif


//----------------------------------------------------------------------------------------------------
//  TdcLib名前空間
//----------------------------------------------------------------------------------------------------
namespace TdcLib
{
    //----------------------------------------------------------------------------------------------------
    /// <summary>
    /// システム設定クラス(TdcXmlを継承)
    /// </summary>
    //----------------------------------------------------------------------------------------------------
    public sealed class SystemSettingInfo : TdcXml
    {

#region プライベート定義

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// SettingInfoクラスインスタンス
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private static SystemSettingInfo m_SystemSettingInfo = null;
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ロック用オブジェクト
        /// </summary>
        private static object m_lockSystemSettingInfo = new object();
        //----------------------------------------------------------------------------------------------------

#endregion


        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// SystemSettingInfoクラスのインスタンスを取得します
        /// </summary>
        /// <returns>SystemSettingInfoクラスのインスタンス</returns>
        //----------------------------------------------------------------------------------------------------
        public static SystemSettingInfo GetInstance()
        {
            SystemSettingInfo ret = null;

            try
            {
                // SystemSettingInfoクラスの有無チェック
                if ( m_SystemSettingInfo == null)
                {
                    lock (m_lockSystemSettingInfo)
                    {
                        // SystemSettingInfoクラス構築
                        m_SystemSettingInfo = new SystemSettingInfo();
                    }
                }

                ret = m_SystemSettingInfo;
            }
            catch( Exception ex )
            {
                if( m_SystemSettingInfo != null )
                    m_SystemSettingInfo.Error = new Exception("SysttemSettingInfo", ex);
            }

            return (ret);
        }
        //----------------------------------------------------------------------------------------------------

#region パブリックメソッド

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 設定値読み込み
        /// </summary>
        /// <param name="strTagName">設定項目タグ名称</param>
        /// <param name="strDefaultValue">既定値</param>
        /// <returns>設定値</returns>
        //----------------------------------------------------------------------------------------------------
        public String GetValue(String strTagName, String strDefaultValue)
        {
            return ( base.GetValue("Settings", strTagName, strDefaultValue));
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 設定値読み込み(CRLF除去)
        /// </summary>
        /// <param name="strTagName">設定項目タグ名称</param>
        /// <param name="strDefaultValue">既定値</param>
        /// <returns>設定値</returns>
        //----------------------------------------------------------------------------------------------------
        public String GetSingleLineValue(String strTagName, String strDefaultValue)
        {
            return (base.GetSingleLineValue("Settings", strTagName, strDefaultValue));
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 設定値書込
        /// </summary>
        /// <param name="strTagName">設定項目タグ名称</param>
        /// <param name="strValue">設定値</param>
        /// <returns>true：成功/false：失敗</returns>
        //----------------------------------------------------------------------------------------------------
        public bool SetValue(String strTagName, String strValue)
        {
            return ( base.SetValue( "Settings", strTagName, strValue));
        }
        //----------------------------------------------------------------------------------------------------

#endregion

    }
}
