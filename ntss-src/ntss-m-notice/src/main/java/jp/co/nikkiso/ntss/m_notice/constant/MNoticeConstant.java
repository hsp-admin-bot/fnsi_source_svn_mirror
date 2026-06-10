package jp.co.nikkiso.ntss.m_notice.constant;

/**
 * ntss-m-noticeの定数クラス.
 */
public class MNoticeConstant {

  /**
   * ON/OFFフラグ
   */
  public static class FlagType {

    /**
     * OFF.
     */
    public static final String FLAG_OFF = "0";

    /**
     * ON.
     */
    public static final String FLAG_ON = "1";
  }

  /**
   * 対処ステータス.
   */
  public static class CorrectionStatus {
    /**
     * 未対処(0).
     */
    public static final String UN_HANDLED = "0";
    /**
     * 対応中(2).
     */
    public static final String IN_PROGRESS = "2";
    /**
     * 対処済(1).
     */
    public static final String HANDLED = "1";
  }

  /**
   * メール送信設定.
   */
  public static class MailSetting {
    /**
     * 宛先件数の上限.
     */
    public static final int MAX_ADDRESS = 50;
  }
  
  public static class SalSubscriptionManageStatus {
	  
	  /**
	    * 未受付.
	  */
	  public static final String NOT_ACCEPTED = "0";
	  
	  /**
	    * 受付済み.
	  */
	  public static final String ACCEPTED = "1";
	  
	  /**
	    * 完了済み.
	  */
	  public static final String COMPLETION = "2";
	  
	  /**
	    * キャンセル.
	  */
	  public static final String CANCEL = "9";
  }

  /**
   * 装置動作記録 サービス対応種別
   */
  public static final class ServiceSupportType {
    /**
     * 未受付("0").
     */
    public static final String NOT_ACCEPTED = "0";
    /**
     * 1次対応済み("1").
     */
    public static final String FIRST_SUPPORTED = "1";
    /**
     * サービス対応済み("2").
     */
    public static final String SERVICE_SUPPORTED = "2";
    /**
     * サービス対象外("3").
     */
    public static final String SERVICE_NOT_COVERED = "3";
  }

}
