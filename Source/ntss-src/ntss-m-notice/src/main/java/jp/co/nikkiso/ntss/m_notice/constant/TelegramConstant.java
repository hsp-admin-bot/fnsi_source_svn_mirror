package jp.co.nikkiso.ntss.m_notice.constant;

/**
 * 緊急発報で扱う電文の定数クラス.
 */
public class TelegramConstant {
  
  /**
   * 電文長定義.
   */
  public static class TelegramLength {
    
    /**
     * 日機装(38byte).
     */
    public static final int NIKKISO = 38;
    
    /**
     * 医機工(80byte).
     */
    public static final int IKIKO = 80;
    
    /**
     * NX(64byte).
     */
    public static final int NX = 64;
    
    /**
     * 死活監視アプリ(26byte).
     */
    public static final int ALIVE_MONI = 26;
    
  }
  
  /**
   * 電文要素名定義.
   */
  public static class TelegramElement {
    
    /**
     * 施設コード.
     */
    public static final String FACILITY_CODE = "施設コード"; 
    
    /**
     * 型式コード.
     */
    public static final String MODEL_CODE = "型式コード";
    
    /**
     * 装置記録コード.
     */
    public static final String RECORDING_CODE = "装置記録コード";
    
    /**
     * 装置記録メッセージ.
     */
    public static final String RECORDING_MESSAGE = "装置記録メッセージ";
    
    /**
     * 装置記録補助データ1.
     */
    public static final String RECORDING_DATA1 = "装置記録補助データ1";
    
    /**
     * 装置記録補助データ2.
     */
    public static final String RECORDING_DATA2 = "装置記録補助データ2";
    
    /**
     * 装置記録補助データ3.
     */
    public static final String RECORDING_DATA3 = "装置記録補助データ3";
    
    /**
     * 装置記録補助データ4.
     */
    public static final String RECORDING_DATA4 = "装置記録補助データ4";
    
    /**
     * チェックサム.
     */
    public static final String CHECK_SUM = "チェックサム";
    
    /**
     * 通信フォーマット.
     */
    public static final String COM_FORMAT_CD = "通信フォーマット";
    
    /**
     * 製造番号.
     */
    public static final String SERIAL_NUMBER = "製造番号";
    
    /**
     * デバイスエッジ番号.
     */
    public static final String DEVICE_EDGE_NUMBER = "デバイスエッジ番号";
    
    /**
     * 人体検出.
     */
    public static final String HUMAN_DETECTION = "人体検出";
    
    /**
     * 小数点位置.
     */
    public static final String DECIMAL_POSITION = "小数点位置";
    
    /**
     * 変更前.
     */
    public static final String CHANGE_BEFORE = "変更前";
    
    /**
     * 変更後.
     */
    public static final String CHANGE_AFTER = "変更後";
    
    /**
     * 予約.
     */
    public static final String RESERVE = "予約";
    
    /**
     * 拡張データ１.
     */
    public static final String EXTENDED_DATA1 = "拡張データ１";
    
    /**
     * 拡張データ２.
     */
    public static final String EXTENDED_DATA2 = "拡張データ２";
    
    /**
     * アドレス２.
     */
    public static final String ADDRESS2 = "アドレス２";
    
    /**
     * アドレス３.
     */
    public static final String ADDRESS3 = "アドレス３";
    
    /**
     * アドレス４.
     */
    public static final String ADDRESS4 = "アドレス４";
    
    /**
     * アドレス５.
     */
    public static final String ADDRESS5 = "アドレス５";
    
    /**
     * アドレス６.
     */
    public static final String ADDRESS6 = "アドレス６";
    
    /**
     * アドレス７.
     */
    public static final String ADDRESS7 = "アドレス７";
    
    /**
     * 発生日付.
     */
    public static final String OCCURRENCE_DATE = "発生日付";
    
    /**
     * 発生時刻.
     */
    public static final String OCCURRENCE_TIME = "発生時刻";
    
    /**
     * 発生日時.
     */
    public static final String OCCURRENCE_DATETIME = "発生日時"; 
    
  }
  
}
