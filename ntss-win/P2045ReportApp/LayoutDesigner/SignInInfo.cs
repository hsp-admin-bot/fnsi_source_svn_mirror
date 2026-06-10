using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LayoutDesigner
{
    /// <summary>
    /// サインイン情報
    /// </summary>
    public class SignInInfo
    {
        #region メンバプロパティ定義

        /// <summary>
        /// ログインIDの取得及び設定を行います。
        /// </summary>
        public String LoginID { get; set; } = String.Empty;

        /// <summary>
        /// パスワードの取得及び設定を行います。
        /// ハッシュ値です。
        /// </summary>
        [System.Obsolete("使用注意")]
        public String Password { get; set; } = String.Empty;

        /// <summary>
        /// 施設ハッシュ値の取得及び設定を行います。
        /// </summary>
        public String FacilityHashText { get; set; } = String.Empty;

        /// <summary>
        /// ログイン施設コードの取得及び設定を行います。
        /// </summary>
        public String FacilityCode { get; set; } = String.Empty;

        /// <summary>
        /// オンライン状態かどうかの取得及び設定を行います。
        /// </summary>
        public Boolean IsOnline { get; set; } = false;

        /// <summary>
        /// 認証済みかどうかの取得及び設定を行います。
        /// </summary>
        public Boolean IsAuthenticated { get; set; } = false;

        /// <summary>
        /// スーパーユーザかどうかの取得及び設定を行います。
        /// </summary>
        public Boolean IsSuperUser { get; set; } = false;

        #endregion
    }
}
