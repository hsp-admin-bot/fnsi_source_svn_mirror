using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Fnw.StatisticsTool.FrmLogin
{
    public class LoginInfo
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
        public String Password { get; set; } = String.Empty;

        /// <summary>
        /// ドメイン値の取得及び設定を行います。
        /// </summary>
        public String domain { get; set; } = String.Empty;

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

        // add 2020-11-19 FNWで実現していた、「以前の帳票に戻す」機能を追加する 孫 start
        /// <summary>
        /// 利用者名_姓の取得及び設定を行います。
        /// </summary>
        public String UserLastName { get; set; } = String.Empty;

        /// <summary>
        /// 利用者名_名の取得及び設定を行います。
        /// </summary>
        public String UserFirstName { get; set; } = String.Empty;
        // add 2020-11-19 FNWで実現していた、「以前の帳票に戻す」機能を追加する 孫 end
        // add 2021-01-29 No.631:日機装ユーザでログインした際には、「施設選択コンボ」を設置 商 start
        /// <summary>
        /// 利用者種別の取得及び設定を行います。
        /// </summary>
        public String UserType { get; set; } = String.Empty;
        // add 2021-01-29 No.631:日機装ユーザでログインした際には、「施設選択コンボ」を設置 商 end
        #endregion

    }
}
