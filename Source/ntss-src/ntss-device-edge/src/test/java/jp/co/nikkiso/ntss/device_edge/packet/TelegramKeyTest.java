package jp.co.nikkiso.ntss.device_edge.packet;

public class TelegramKeyTest {
  /**
   * データ種別
   */
  public static final String KEY_KIND = "kind";
  /**
   * 施設コード
   */
  public static final String KEY_FACILITY_CD = "facilitycode";
  /**
   * デバイスエッジ番号
   */
  public static final String KEY_EDGE_NO = "edgeno";
  /**
   * 発生日時
   */
  public static final String KEY_OCCUR_DATE = "occurdate";
  /**
   * 型式コード
   */
  public static final String KEY_DEVICE_TYPE = "devicetype";
  /**
   * 製造番号
   */
  public static final String KEY_SERIAL_NO = "serialno";
  /**
   * 通信フォーマット
   */
  public static final String KEY_COMM_FORMAT = "commformat";
  /**
   * 通信ステータス
   */
  public static final String KEY_COMM_STATUS = "commstatus";
  /**
   * 装置バージョン
   */
  public static final String KEY_VERSION = "version";
  /**
   * 種別 + コード
   */
  public static final String KEY_CODE = "code";
  /**
   * メッセージ
   */
  public static final String KEY_MESSAGE = "message";
  /**
   * 情報
   */
  public static final String KEY_ITEMS = "items";
  /**
   * 補助データ
   */
  public static final String KEY_AUX_DATA_0 = "data0";
  /**
   * 補助データ
   */
  public static final String KEY_AUX_DATA_1 = "data1";
  /**
   * 補助データ
   */
  public static final String KEY_AUX_DATA_2 = "data2";
  /**
   * 補助データ
   */
  public static final String KEY_AUX_DATA_3 = "data3";
  /**
   * 補助データ
   */
  public static final String KEY_AUX_DATA_4 = "data4";
  /**
   * 補助データ
   */
  public static final String KEY_AUX_DATA_5 = "data5";
  /**
   * 補助データ
   */
  public static final String KEY_AUX_DATA_6 = "data6";
  /**
   * 補助データ
   */
  public static final String KEY_AUX_DATA_7 = "data7";

  
  private static final String LOG = "LOG";
  private static final String MONITER = "MON";
  private static final String MONITER_START = "MONS";
  private static final String MONITER_FINISH = "MONF";
  private static final String MNT_UFRC_SELF = "MNT1";
  private static final String MNT_BLEEDING = "MNT2";
  private static final String MNT_DIALYSIS_FLOW = "MNT3";
  private static final String MNT_CONCENTRATION = "MNT4";
  private static final String MNT_TIME = "MNT5";
  private static final String PIPE_TEST = "MT0";
  private static final String DILUTION_TEST = "MT1";
  private static final String USE_TIME = "OPE";
  private static final String DISSOLUTION = "DAR";
  
  /**
   * kindの値からEnum値を返す
   * @param enumKind
   * @return 
   */
  public static EnumRcvDataKind getEnumKind(String kind) {
    EnumRcvDataKind ret = null;
    switch (kind) {
    case LOG:
      ret = EnumRcvDataKind.LOG;
      break;
    case MONITER:
      ret = EnumRcvDataKind.MONITER;
      break;
    case MONITER_START:
      ret = EnumRcvDataKind.MONITER_START;
      break;
    case MONITER_FINISH:
      ret = EnumRcvDataKind.MONITER_FINISH;
      break;
    case MNT_UFRC_SELF:
      ret = EnumRcvDataKind.MNT_UFRC_SELF;
      break;
    case MNT_BLEEDING:
      ret = EnumRcvDataKind.MNT_BLEEDING;
      break;
    case MNT_DIALYSIS_FLOW:
      ret = EnumRcvDataKind.MNT_DIALYSIS_FLOW;
      break;
    case MNT_CONCENTRATION:
      ret = EnumRcvDataKind.MNT_CONCENTRATION;
      break;
    case MNT_TIME:
      ret = EnumRcvDataKind.MNT_TIME;
      break;
    case PIPE_TEST:
      ret = EnumRcvDataKind.PIPE_TEST;
      break;
    case DILUTION_TEST:
      ret = EnumRcvDataKind.DILUTION_TEST;
      break;
    case USE_TIME:
      ret = EnumRcvDataKind.USE_TIME;
      break;
    case DISSOLUTION:
      ret = EnumRcvDataKind.DISSOLUTION;
      break;
    default:
      break;
    }
    return ret;
  }
}
