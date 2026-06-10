package jp.co.nikkiso.ntss.admin_web.request.bloodPurify;

public class TelegramItems {

  private String[] telegrams;

  /**
   * コンストラクタ
   * @param telegramLine
   */
  public TelegramItems(String[] telegramLine) {
    this.telegrams = telegramLine;
  }

  /**
   * 項目追加
   * @param key キー値
   * @param value 設定値
   */
  public void setItemValue(String key, String value) {
    // キー確認
    String val = TelegramControl.getTelegramValue(this.telegrams, key);
    if (val == null) {
      // キーがない場合

      // 項目追加
      String[] work = new String[this.telegrams.length + 1];
      System.arraycopy(this.telegrams, 0, work, 0, this.telegrams.length);
      work[work.length - 1] = String.format("%s=%s", key, value);
      this.telegrams = work;
    } else {
      // キーがある場合

      // キー検索
      for (String item : this.telegrams) {
        if (item.startsWith(key)) {
          // 設定値更新
          item = String.format("%s=%s", key, value);
        }
      }
    }
  }

  /**
   * 項目取得
   * @param key キー値
   * @return 設定値
   */
  public String getItemValue(String key) {
    return TelegramControl.getTelegramValue(this.telegrams, key);
  }

  public EnumRcvDataKind getTelegramKind() {
    return TelegramKey.getEnumKind(getItemValue(TelegramKey.KEY_KIND));
  }

  /**
   * commStatus の前半2桁のHEXを数値化して返す
   * @return
   */
  public Integer getItemCommStatus() {
    String commStatus = getItemValue(TelegramKey.KEY_COMM_STATUS);
    if (commStatus == null) {
      return null;
    }
    // commStatus の前半2桁のHEXを数値化
    if (commStatus.length() < 2) {
      return -1;
    }
    return Integer.parseInt(commStatus.substring(0, 2), 16);
  }

}
