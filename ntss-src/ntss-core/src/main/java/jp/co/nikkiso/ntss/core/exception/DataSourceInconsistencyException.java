package jp.co.nikkiso.ntss.core.exception;

import lombok.Getter;

/**
 * データソース間不整合例外クラス.
 */
public class DataSourceInconsistencyException extends NtssException {

  /**
   * メッセージを生成する.
   * @param userId ユーザーID
   * @param dataSourceNames データソース名のリスト
   * @return
   */
  public static String createMessage(Long userId, String... dataSourceNames) {
    // メッセージにはユーザーIDを含めない
    return String.format("データソース間不整合：%s", String.join(",", dataSourceNames));
  }

  /**
   * 不整合が発生したユーザーID.
   */
  @Getter
  private Long userId;

  /**
   * コンストラクタ.
   * @param userId 不整合が発生したユーザーID
   * @param dataSourceNames 不整合が発生したデータソース名のリスト
   */
  public DataSourceInconsistencyException(Long userId, String... dataSourceNames) {
    super(createMessage(userId, dataSourceNames));

    this.userId = userId;
  }

}
