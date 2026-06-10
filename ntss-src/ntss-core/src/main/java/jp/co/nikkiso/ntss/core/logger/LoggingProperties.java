package jp.co.nikkiso.ntss.core.logger;

import java.text.MessageFormat;

import lombok.Getter;
import lombok.RequiredArgsConstructor;
import lombok.Setter;
/**
 * ログプロパティの抽象クラス
 */
@Getter
@Setter
@RequiredArgsConstructor
abstract class LoggingProperties {
  /**
   * ログファイル名.
   */
  private String fileName;

  /**
   * ローテーション後のログファイル名.
   */
  private String fileNamePattern;

  // ログ出力ロジック xie start
  /**
   * ファイルサイズ
   */
  private long maxFileSize;
  // ログ出力ロジック xie end

  /**
   * ログファイル保存日数.
   */
  private final int maxHistory;

  private String outFlg;

  /**
   * ログファイルパスの施設コードを置換する.
   *
   * @param facilityCd 施設コード
   * @return ログファイルパス
   */
  public String getFileName(String facilityCd, String projectName, String serverName) {
    return MessageFormat.format(getFileName(), facilityCd, serverName, projectName);
  }

  /**
   * ログローテーションファイルパスの施設コードを置換する.
   * @param facilityCd 施設コード
   * @return ログローテーションファイルパス
   */
  public String getFileNamePattern(String facilityCd, String serverName, String projectName) {
    return MessageFormat.format(getFileNamePattern(), facilityCd, serverName, projectName);
  }
}
