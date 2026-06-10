package jp.co.nikkiso.ntss.certificate_management.constant;

import org.springframework.http.HttpStatus;

import java.util.Arrays;
import java.util.NoSuchElementException;
import java.util.Optional;


/**
 * ntss-client-certificateのメッセージクラス.
 */
public class ClientCertificateMessage {

	 /**
	   * システムエラーメッセージ.
	   */
    // mod FNSI-#4443対応 解 start
	  //private static final String MESSAGE_SYSTEM_ERROR = "システムエラーが発生しました。";
    private static final String MESSAGE_SYSTEM_ERROR = "システムエラーが発生しましたので処理を終了します。";
    // mod FNSI-#4443対応 解 end

	  public enum Error {

	    /**
	     * 表示用ユーザーIDが見つからない.
	     */
	    USER_ID_NOT_FOUND(HttpStatus.BAD_REQUEST, "指定されたユーザーIDが見つかりません。"),

	    /**
	     * 表示用ユーザーIDが重複している.
	     */
	    USER_ID_EXISTED(HttpStatus.BAD_REQUEST, "既にユーザーIDは使われています。\n別のユーザーIDを入力してください。"),

	    /**
	     * 施設コードが見つからない.
	     */
	    FACILITY_CD_NOT_FOUND(HttpStatus.BAD_REQUEST, "指定された施設コードが見つかりません。"),

	    /**
	     * DB間不整合.
	     */
	    DB_INCONSISTENCY(HttpStatus.INTERNAL_SERVER_ERROR, MESSAGE_SYSTEM_ERROR),

	    /**
	     * DB更新エラー.
	     */
	    DB_UPDATE_ERROR(HttpStatus.INTERNAL_SERVER_ERROR, MESSAGE_SYSTEM_ERROR),

	    /**
	     * SQL実行エラー.
	     */
	    SQL_EXECUTION_ERROR(HttpStatus.INTERNAL_SERVER_ERROR, MESSAGE_SYSTEM_ERROR),

	    /**
	     * 文字サイズ不正.
	     */
	    FONT_SIZE_INCORRECT(HttpStatus.BAD_REQUEST, "指定された文字サイズは正しくありません。"),

	    /**
	     * テーマ不正.
	     */
	    THEME_INCORRECT(HttpStatus.BAD_REQUEST, "指定されたテーマは正しくありません。"),

	    /**
	     * メニュー表示フラグ不正.
	     */
	    IS_DISP_MENU_INCORRECT(HttpStatus.BAD_REQUEST, "指定されたメニュー表示は正しくありません。"),

	    /**
	     * 使用機能コード不正.
	     */
	    USE_FUNCTION_INCORRECT(HttpStatus.BAD_REQUEST, "指定された表示機能は正しくありません。"),

	    /**
	     * 初期表示機能コード不正.
	     */
	    INITIAL_FUNCTION_INCORRECT(HttpStatus.BAD_REQUEST, "指定された初期表示機能は正しくありません。"),

	    /**
	     * 画面フレーム分割フラグ不正.
	     */
	    SPLIT_FRAME_INCORRECT(HttpStatus.BAD_REQUEST, "指定された画面フレーム分割フラグは正しくありません。"),

	    /**
	     * マスタデータ不正.
	     */
	    MASTER_RECORD_ERROR(HttpStatus.INTERNAL_SERVER_ERROR, "マスタデータ取得に失敗しました。"),

	    /**
	     * スキーマ情報の定義誤り（存在しないカラム物理名を指定された等）
	     */
	    INVALID_SCHEMA_DEFINITION_ERROR(HttpStatus.BAD_REQUEST, "スキーマ情報の定義に誤りがあります。"),

	    /**
	     * 必須チェックに引っかかった.
	     */
	    REQUIRED_ERROR(HttpStatus.BAD_REQUEST, "必須の項目が存在しません。"),

	    /**
	     * 該当データなし
	     */
	    NOT_EXIST_ERROR(HttpStatus.INTERNAL_SERVER_ERROR, "該当データがありません。"),

	    /**
	     * SessionTimeout.
	     */
	    SESSION_TIMEOUT_ERROR(HttpStatus.UNAUTHORIZED, "一定時間操作しなかった為、強制的にサインアウトしました。"),

	    /**
	     * 楽観的排他制御.
	     */
	    OPTIMISTIC_LOCK_ERROR(HttpStatus.CONFLICT, "他端末で更新されている為、更新できません。");

	    /**
	     * Httpステータスコード.
	     */
	    private HttpStatus httpStatus;

	    /**
	     * エラーメッセージ.
	     */
	    private String message;

	    /**
	     * コンストラクタ.
	     */
	    Error(HttpStatus httpStatus, String message) {
	      this.httpStatus = httpStatus;
	      this.message = message;
	    }

	    /**
	     * Httpステータスコード取得.
	     */
	    public HttpStatus getHttpStatus() {
	      return this.httpStatus;
	    }

	    /**
	     * エラーメッセージ取得.
	     */
	    public String getMessage() {
	      return this.message;
	    }

	    /**
	     * エラーメッセージに対応するHttpステータスコード取得.
	     *
	     * @param message エラーメッセージ
	     * @throws NoSuchElementException
	     */
	    public static HttpStatus getHttpStatus(String message) throws NoSuchElementException {
	      // エラーメッセージに一致するenumを探す
	      Optional<Error> error = Arrays.stream(values()).filter(e -> message.equals(e.getMessage())).findAny();
	      // 該当するenumがあった場合、Httpステータスコードを返す
	      return error.get().getHttpStatus();
	    }

	  }

	  /**
	   * 警告メッセージ.
	   */
	  public enum Warning {
	  }

	  /**
	   * 情報メッセージ.
	   */
	  public enum Information {
	  }

}
