package jp.co.nikkiso.ntss.coop_api.utils;

import org.springframework.http.HttpStatus;

import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * 連携エッジ用の定数クラス
 *
 */
public class IfEdgeConstants {

  /** if edge 管理ID */
  public static final String IF_EDGE_MAINTENANCE = "maintenance";

//#10453 mod 死活監視が動作していない 2024-04-30 卓 start 
  public static final Integer IF_EDGE_TYPE_ALL = 0;
  public static final Integer IF_EDGE_TYPE_MAINTENANCE = 1;
  public static final Integer IF_EDGE_TYPE_JOURNAL = 2;
//#10453 mod 死活監視が動作していない 2024-04-30 卓 end

  /** 連携エッジ実行指示の識別子 */
  public static final String IF_EDGE_CONNECT_SYSTEM_NAME = "NTSS";

  /** フラグOFF */
  public static final String FLAG_FALSE = "0";

  /** 連携管理番号ファイルプレフィクス */
  public static final String CTL_NO_FILE_PREFIX = "ctlno_";

  /** コマンド実行作成ファイル名 */
  public static final String COMMAND_FILE = "maintenance.sh";

  // add 6920 IFエッジ設定更新時に再起動が行われない 張 start
  /** ntss_if.json作成ファイル名 */
  public static final String NTSS_IF_FILE = "ntss_if.json";

  /** ntss_maint.json作成ファイル名 */
  public static final String NTSS_MAINT_FILE = "ntss_maint.json";

  /** setting.config作成ファイル名 */
  public static final String SETTING_CONFIG = "setting.config";

  /** ntssif.env作成ファイル名 */
  public static final String NTSS_IF_ENV = "ntssif.env";
  // add 6920 IFエッジ設定更新時に再起動が行われない 張 end
  /** コマンドファイルの日付ディレクトリ表現 */
  public static final String COMMAND_DIR_DATE_FORMAT = "yyyyMMddHHmmSSS";

  /** データクリア必要なし */
  public static final int DATA_CLEAR_UNNECESSARY = 0;

  /** データクリア連携エッジ制御指示管理のみ */
  public static final int DATA_CLEAR_ONLY_MANAGE = 1;

  /** データクリアすべて */
  public static final int DATA_CLEAR_ALL = 2;

  /** ファイルセパレータ  */
  public static final String FILE_SEPARATOR = "/";

  /** ファイル内置換対象文字列：ディレクトリ */
  public static final String REPLACE_STRING_DIR_PATH = "DATA_PATH";

  /**
   * 連携エッジ結果ステータス
   *
   */
  @Getter
  @AllArgsConstructor
  public enum ResultStatus {
    RESULT("result"),
    CONNECT("connect");

    private String receiveName;

    public static ResultStatus getEnum(String name) {
      for (ResultStatus ifEdgeResultStatus : values()) {
        if (ifEdgeResultStatus.receiveName.equals(name)) {
          return ifEdgeResultStatus;
        }
      }
      return null;
    }
  }

  /**
   * 連携エッジ固定結果定義
   *
   */
  @Getter
  @AllArgsConstructor
  public enum IfedgeFixedResult {
    // add 2020-11-16 各API間の呼び出しフローの修正（エッジ主体からAWS主体へ）→負荷増加回避策が必要 孫 start
    JOURNAL_BUSY(HttpStatus.TOO_MANY_REQUESTS.value(), "if edge journal busy", DATA_CLEAR_UNNECESSARY),
    JOURNAL_DISCONNECT(HttpStatus.SERVICE_UNAVAILABLE.value(), "if edge journal disconnect", DATA_CLEAR_UNNECESSARY),
    SEND_JOURNAL_ERR(HttpStatus.INTERNAL_SERVER_ERROR.value(), "send journal error", DATA_CLEAR_ONLY_MANAGE),
    // add 2020-11-16 各API間の呼び出しフローの修正（エッジ主体からAWS主体へ）→負荷増加回避策が必要 孫 end
    DISCONNECT(HttpStatus.SERVICE_UNAVAILABLE.value(), "if edge disconnect", DATA_CLEAR_UNNECESSARY),
    TIMEOUT(HttpStatus.REQUEST_TIMEOUT.value(), "if edge timeout", DATA_CLEAR_UNNECESSARY),
    BUSY(HttpStatus.TOO_MANY_REQUESTS.value(), "if edge busy", DATA_CLEAR_UNNECESSARY),
    COMMANDNOTFOUND(HttpStatus.BAD_REQUEST.value(), "command not found", DATA_CLEAR_ONLY_MANAGE),
    SERVER_DISCONNECT(HttpStatus.INTERNAL_SERVER_ERROR.value(), "server disconnect", DATA_CLEAR_UNNECESSARY),
    COMMAND_FILE_ERR(HttpStatus.INTERNAL_SERVER_ERROR.value(), "command file create failure", DATA_CLEAR_ONLY_MANAGE),
    CTLNO_FILE_ERR(HttpStatus.INTERNAL_SERVER_ERROR.value(), "ctlNo file create failure", DATA_CLEAR_ONLY_MANAGE),
    CREATE_FILE_ERR(HttpStatus.INTERNAL_SERVER_ERROR.value(), "create zip file error", DATA_CLEAR_ONLY_MANAGE),
    SEND_FILE_ERR(HttpStatus.INTERNAL_SERVER_ERROR.value(), "sendFile error", DATA_CLEAR_ALL),
    REPLACE_ERR(HttpStatus.INTERNAL_SERVER_ERROR.value(), "replace error", DATA_CLEAR_ONLY_MANAGE),
    URI_SYNTAX_ERR(HttpStatus.INTERNAL_SERVER_ERROR.value(), "URISyntax error", DATA_CLEAR_UNNECESSARY),
    IFEDGE_RES_ERR(HttpStatus.INTERNAL_SERVER_ERROR.value(), "ifedge response error", DATA_CLEAR_UNNECESSARY),
    SERVER_SHUTDOWN(HttpStatus.INTERNAL_SERVER_ERROR.value(), "server shutdown", DATA_CLEAR_UNNECESSARY),
    // mod 2022-09-29 bug 6920 IFエッジ設定更新時に再起動が行われない 孫 start
//    COMMAND_MASTER_ERR(HttpStatus.INTERNAL_SERVER_ERROR.value(), "command master get error", DATA_CLEAR_ONLY_MANAGE);
    COMMAND_MASTER_ERR(HttpStatus.INTERNAL_SERVER_ERROR.value(), "command master get error", DATA_CLEAR_ONLY_MANAGE),
    COPY_VERSION_UP_FILE_ERR(HttpStatus.INTERNAL_SERVER_ERROR.value(), "copy version_up file error", DATA_CLEAR_ONLY_MANAGE);
    // mod 2022-09-29 bug 6920 IFエッジ設定更新時に再起動が行われない 孫 end
    // ステータス
    private Integer status;

    // エラーメッセージ
    private String message;

    // エラー時データクリア区分    0:必要なし
    //                             1:連携エッジ制御指示管理のみパージ対応
    //                             2:全パージ対応（連携エッジ制御指示管理・連携エッジクライアント接続状態）
    private Integer dataClearFlg;
  }

  /**
   * 連携エッジ応答ステータス定義
   *
   */
  @Getter
  @AllArgsConstructor
  public enum ResponseStatus {
    ERROR(-2),
    TIMEOUT(-1),
    RUNNING(0),
    DONE(2);

    private int status;
  }

  /**
   * 連携エッジ指示種別
   */
  @Getter
  @AllArgsConstructor
  public enum ExeType {
    COMMAND("command"),
    FILE("file");

    private String type;
  }

  /**
   * 設定ファイル追加
   */
  @Getter
  @AllArgsConstructor
  public enum AddSetting {
    FACILITY_SETTING("1");

    private String addSetting;
  }
}
