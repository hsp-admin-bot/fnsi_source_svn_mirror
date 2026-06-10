//----------------------------------------------------------------------------------------------------
//  バージョン情報取得クラス定義
//----------------------------------------------------------------------------------------------------
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading;

#if DEBUG
    using System.Diagnostics;
#endif

//----------------------------------------------------------------------------------------------------
//  名前空間:TdcVersionLib
//----------------------------------------------------------------------------------------------------
namespace TdcVersionInfoLib
{
    //----------------------------------------------------------------------------------------------------
    /// <summary>
    /// VersionInfosクラス
    /// </summary>
    //----------------------------------------------------------------------------------------------------
    public class VersionInfos
    {
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// バージョン情報記録
        /// ※呼び出し元の実行ファイルバージョン+参照DLL群(但し、呼び出し時点でロードされている分のみ)
        /// </summary>
        /// <param name="strLogFIleName">記録されるログファイル名</param>
        /// <returns>バージョン情報</returns>
        //----------------------------------------------------------------------------------------------------
        public static String GetVersionInfo( String strLogFIleName )
        {
            // 各バージョン情報
            StringBuilder sbver = new StringBuilder();
            System.Reflection.Assembly asm = null;
            System.Diagnostics.FileVersionInfo filever = null;
            sbver.AppendLine("System,Version\r\n");

            // 実行ファイルバージョン
            // 呼び出し元のアセンブリ情報取得
            asm = System.Reflection.Assembly.GetEntryAssembly();
            if (asm != null)
            {
                // ファイル情報取得
                filever = System.Diagnostics.FileVersionInfo.GetVersionInfo(asm.Location);
                // 呼び出し元バージョン情報
                sbver.AppendFormat("Process Assembly Version:  {0}\r\n{1}\r\n", asm.GetName().ToString(), filever.ToString());
            }

            // 使用アセンブリ一覧(ロード済みのアセンブリのみ)
            foreach (System.Reflection.Assembly asmitem in System.AppDomain.CurrentDomain.GetAssemblies())
            {
                // 実行ファイル以外の場合
                if( asm.Equals(asmitem) == false )
                {
                    // ファイル情報取得
                    filever = System.Diagnostics.FileVersionInfo.GetVersionInfo(asmitem.Location);

                    // バージョン情報
                    sbver.AppendFormat("AssemblyVersion:  {0}\r\n{1}\r\n", asmitem.ToString(), filever.ToString());
                }
            }

            // バージョン情報を返す
            return (sbver.ToString());
        }
        //----------------------------------------------------------------------------------------------------
    }
    //----------------------------------------------------------------------------------------------------
}
//----------------------------------------------------------------------------------------------------
