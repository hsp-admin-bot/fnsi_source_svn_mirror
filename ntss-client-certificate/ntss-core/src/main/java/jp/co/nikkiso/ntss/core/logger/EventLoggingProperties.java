package jp.co.nikkiso.ntss.core.logger;

import lombok.Getter;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

/**
 * ログのプロパティクラス.
 */
@Component
public class EventLoggingProperties {

  /**
   * ログファイルあたり最大100 MB
   */
  @Getter
  private int maxFileSize = 100;

  /**
   * ログが属するアプリケーション
   */
  @Getter
  @Value("${spring.application.name}")
  private String applicationName;

  /**
   * ログファイル名.
   *  default: /efs/{0}/サーバー/{1}/{2}/{0}.log
   */
  @Getter
  @Value("${ntss.logging.appender.file-name:/efs/{0}/サーバー/{1}/{2}/{0}.log}")
  private String fileName;

  /**
   * ローテーション後のログファイル名.
   *  default: /efs/{0}/サーバー/{1}/{2}/%d'{'yyyyMMdd'}'/{0}_%d'{'yyyyMMdd'}_%i'.log.zip
   */
  @Getter
  // mod #10756 gz形式の圧縮が多数存在する。zipに統一すること dengshen start
  //@Value("${ntss.logging.rolling.file-name-pattern:/efs/{0}/サーバー/{1}/{2}/%d'{'yyyyMMdd'}'/{0}_%d'{'yyyyMMdd'}_%i'.log.gz}")
  @Value("${ntss.logging.rolling.file-name-pattern:/efs/{0}/サーバー/{1}/{2}/%d'{'yyyyMMdd'}'/{0}_%d'{'yyyyMMdd'}_%i'.log.zip}")
  // mod #10756 gz形式の圧縮が多数存在する。zipに統一すること dengshen end
  private String fileNamePattern;

  /**
   * ログファイル保存日数.
   *  default: 180
   */
  @Getter
  @Value("${ntss.logging.rolling.max-history:180}")
  private int maxHistory;

}
