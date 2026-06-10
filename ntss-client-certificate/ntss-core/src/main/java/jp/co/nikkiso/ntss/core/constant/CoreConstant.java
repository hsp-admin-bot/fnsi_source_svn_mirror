package jp.co.nikkiso.ntss.core.constant;

/**
 * NTSS共通定数クラス.
 */
public class CoreConstant {

  /**
   * パッケージ定義.
   */
  public static class NtssPackage {

    /**
     * ntss-core.
     */
    public static final String CORE = "jp.co.nikkiso.ntss.core";

    /**
     * client_certificate_management.
     */
    public static final String CERTIFICATE_MANAGEMENT = "jp.co.nikkiso.ntss.certificate_management";

    /**
     * client_certificate_download.
     */
    public static final String CERTIFICATE_DOWNLOAD = "jp.co.nikkiso.ntss.certificate_download";
  }

  /**
   * 日時フォーマット
   */
  public static final class DateTimeFormat {
    /**
     * ISO8601
     */
    public static final String ZONED_DATE_TIME_ISO8601 = "yyyy-MM-dd'T'HH:mm:ss.SSSXXX";

    /**
     * タイムゾーン Asia/Tokyo
     */
    public static final String TIME_ZONE_ASIA_TOKYO = "Asia/Tokyo";
  }

  /**
   * Datasource名.
   */
  public static final class DataSourceName {
    /**
     * デフォルトDB.
     */
    public static final String DEFAULT = "defaultDataSource";
    /**
     * 証明書DB.
     */
    public static final String CERTIFICATE = "certificateDataSource";
  }

  /**
   * TransactionManager名.
   */
  public static final class TransactionManagerName {
    /**
     * デフォルトDB.
     */
    public static final String DEFAULT = "defaultTransactionManager";
    /**
     * 証明書DB.
     */
    public static final String CERTIFICATE = "certificateTransactionManager";
  }
  //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
  /**
   * 仮登録クラス.
   */
  public static final class ProvisionalStatus {

    /**
     * 本登録 = 0.
     */
    public static final int NOT_PROVISIONAL = 0;

    /**
     * 仮登録 = 1.
     */
    public static final int PROVISIONAL = 1;
  }
  //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end
}
