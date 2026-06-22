package jp.co.nikkiso.ntss.admin_web.security;

/**
 * NTSS認証処理用定数定義クラス.
 */
public class NtssAuthenticationConstants {

  /**
   * 認証リクエスト用パラメータ.
   */
  public static class Params {
    /**
     * 施設コード.
     */
    public static final String FACILITY_CD = "facilityCd";

    /**
     * ユーザーID.
     */
    public static final String USERNAME = "userId";

    /**
     * パスワード.
     */
    public static final String PASSWORD = "password";

    /**
     * 機能コード.
     */
    public static final String FUNC_CD = "funcCd";

    /**
     * カードコード
     */
    public static final String CARD_CD = "cardCd";

    /**
     * IDのみでサインインするフラグ
     */
    public static final String USER_ID_ONLY = "userIdOnly";

    /**
     * モード
     */
    public static final String MODE = "mode";
	
	// add #12587 スタッフ切替 start
    public static final String switchStatus = "switchStatus";
	// add #12587 スタッフ切替 end
  }

  /**
   * Cookie名.
   */
  public static final String COOKIE_NAME = "JSESSIONID";
}
