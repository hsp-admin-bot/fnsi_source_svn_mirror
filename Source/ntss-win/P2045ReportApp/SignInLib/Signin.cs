using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using NKKWebAccessLib;

using RldMsgBox = LayoutDesignerUtilityLib.RldMessageBox;
using RldUtility = LayoutDesignerUtilityLib.LayoutDesignerUtility;

namespace SignInLib
{
    /// <summary>
    /// 帳票レイアウトデザイナ共通パラメータクラス
    /// </summary>
    public static class SignIn
    {

        #region メンバ定数定義

        /// <summary>
        /// スーパーユーザ用ID
        /// </summary>
        private const string SUPER_USER_LOGIN_ID = "";

        /// <summary>
        /// スーパーユーザ用パスワード
        /// </summary>
        private const string SUPER_USER_PASSOWRD = "";

        #endregion

        #region メンバプロパティ定義

        /// <summary>
        /// サインイン情報の取得を行います。値の取得のみ可能です。
        /// </summary>
        public static SignInInfo SignInInfo { get; set; } = null;

        #endregion

        #region メンバ関数定義(アプリケーション開始/終了処理)

        /// <summary>
        /// アプリケーション開始前処理を実行します。
        /// </summary>
        /// <returns></returns>
        public static bool PreAppStartUp()
        {
            bool wRet = false;

            try
            {
                // アプリケーション共通開始前処理を実行
                if (!RldUtility.PreAppStartUp())
                {
                    return false;
                }

                // 読み込み済みの情報でサインイン情報を生成
                SignInInfo = new SignInInfo()
                {
                    LoginID = RldUtility.LoginID,
                    Password = RldUtility.Password,
                    FacilityHashText = RldUtility.FacilityHash,
                };

                wRet = true;
            }
            catch (Exception ex)
            {
                RldUtility.RecordException(ex);
            }

            return wRet;
        }

        #endregion

        #region メンバ関数定義

        /// <summary>
        /// 指定されたユーザがスーパーユーザかどうか確認します。
        /// </summary>
        /// <param name="aLoginID"></param>
        /// <param name="aPassword"></param>
        /// <returns></returns>
        public static bool IsSuperUser(string aLoginID, string aPassword)
        {
            string wLoginID = aLoginID.Trim();
            string wPassword = aPassword.Trim();

            // ユーザID確認
            if (string.CompareOrdinal(wLoginID, SUPER_USER_LOGIN_ID) != 0)
            {
                return false;
            }
            // パスワード確認
            if (string.CompareOrdinal(wPassword, SUPER_USER_PASSOWRD) != 0)
            {
                return false;
            }

            return true;
        }

        #endregion
    }
}
