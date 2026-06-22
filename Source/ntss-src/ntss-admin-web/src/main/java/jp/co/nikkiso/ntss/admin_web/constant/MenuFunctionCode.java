package jp.co.nikkiso.ntss.admin_web.constant;

/**
 * メニュー機能コードのenumクラス.
 * TODO 今はコードだけですが、メニュー名も持っても良いかも
 */
public enum MenuFunctionCode implements CodeEnum<MenuFunctionCode> {
  /**
   * 稼働ビューア.
   */
  OPERATION_VIEWER("001"),
  /**
   * 生体モニタリング.
   */
  BIO_MONITORING("002"),
  /**
   * デバイスエッジ稼働監視.
   */
  DEVICE_EDGE_OPERATION("003"),
  /**
   * 患者経過総合ビューア.
   */
  PAT_VIEWER("004"),
  /**
   * マスタメンテ
   */
  MASTER_MAINTENANCE("005"),
  /**
   * 治療記録
   */
  TREATMENT_RECORD("006"),
  /**
   * 患者情報
   */
  PAT_INFO("007"),
  /**
   * 条件送信
   */
  SEND_CONDITION("013"),
  /**
   * 体重計測定記録
   */
  MEASURE_HISTORY("014"),
  /**
   * チェックリスト
   */
  CHECK_LIST("015"),
  /**
   * 観察記録
   */
  OBSERVE_RECORD("016"),
  /**
   * 治療状況マップ
   */
  STATUS_MAP("012"),
  /**
   * 治療状況リスト
   */
  STATUS_LIST("011"),
  /**
   * 患者イベント
   */
  PAT_EVENT("027");

  private String code;

  MenuFunctionCode(String menu) {
    this.code = menu;
  }

  @Override
  public String getCode() {
    return code;
  }
}
