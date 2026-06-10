package jp.co.nikkiso.ntss.admin_web.exception;

import org.springframework.security.core.AuthenticationException;

import jp.co.nikkiso.ntss.core.exception.DataSourceInconsistencyException;
import lombok.Getter;

/**
 * 認証時データソース間不整合例外クラス.
 */
public class DataSourceInconsistencyAuthenticationException extends AuthenticationException {

  /**
   * 不整合が発生したユーザーID.
   */
  @Getter
  private Long userId;

  /**
   * コンストラクタ.
   * @param userId 不整合が発生したユーザーID
   * @param dataSourceNames 不整合が発生したデータソース名
   */
  public DataSourceInconsistencyAuthenticationException(Long userId, String... dataSourceNames) {
    super(DataSourceInconsistencyException.createMessage(userId, dataSourceNames));

    this.userId = userId;
  }

}
