package jp.co.nikkiso.ntss.certificate_download.security;

/**
 * NTSS認証処理用定数定義クラス.
 */
public class NtssAuthenticationConstants {

  /**
   * 認証リクエスト用パラメータ.
   */
  public static class Params {

    /**
     * ユーザーID.
     */
    public static final String USERNAME = "userId";

    /**
     * パスワード.
     */
    public static final String PASSWORD = "password";

    /**
     * ユーザーか施設かを確認.
     */
    public static final String ISUSERLOGIN = "isUserLogin";
  }

  /**
   * Cookie名.
   */
  public static final String COOKIE_NAME = "JSESSIONID";
  
	public static class Authority {

    /**
     * 施設の役割.
     */
    public static final String CL_FACILITY_ROLE = "施設";

    /**
     * 管理者の役割.
     */
    public static final String CL_ADMIN_ROLE = "管理者";

    /**
     * ユーザー役割.
     */
		public static final String CL_GENERAL_ROLE = "ユーザー";
	}
}
