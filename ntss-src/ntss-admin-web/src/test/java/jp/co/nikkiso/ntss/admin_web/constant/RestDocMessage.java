package jp.co.nikkiso.ntss.admin_web.constant;

/**
 * RestDoc作成時のメッセージクラス
 */
public class RestDocMessage {

  /**
   * リクエスト
   */
  public static class Request {

    /**
     * ユーザーID
     */
    public static final String USER_ID = "[必須]ユーザーID(内部)";

    /**
     * 施設コード
     */
    public static final String FACILITY_CD = "[必須]施設コード";
  }

  /**
   * レスポンス
   */
  public static class Response {

    /**
     * 処理結果
     */
    public static final String IS_SUCCESS = "[必須]処理結果(成功=true/失敗=false)";

    /**
     * エラーメッセージ
     */
    public static final String ERROR_MESSAGE = "エラーメッセージ(失敗時のみ設定)";

    /**
     * レスポンスに設定されたメッセージを使用するか否か(フロント制御用)
     */
    public static final String USE_RESPONSE_MESSAGE = "レスポンスに設定されたメッセージを使用するか否か（システムエラー時のフロントエンド制御に使用）";

    /**
     * エラーメッセージ(DB間不整合時のシステムエラー)
     */
    public static final String SYSTEM_ERROR_MESSAGE = "エラーメッセージ(SQL更新、DB間不整合等のシステムエラーのみ設定)";
  }
}
