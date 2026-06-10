package jp.co.nikkiso.ntss.device_edge.packet;

public class TelegramItems {

  private String[] telegrams;

  public TelegramItems(String[] telegramLine) {
    this.telegrams = telegramLine;
  }

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
  public int getItemCommStatus() {

    String commStatus = getItemValue(TelegramKey.KEY_COMM_STATUS);
    // commStatus の前半2桁のHEXを数値化
    // mod FNSI-バグ 通信サーバ #8176 高 start
    // if (commStatus.length() < 2) {
    if (commStatus.length() < 4) {
      return -1;
    }
    // return Integer.parseInt(commStatus.substring(0, 2), 16);
    return Integer.parseInt(commStatus.substring(2, 4), 16);
    // mod FNSI-バグ 通信サーバ #8176 高 end
  }

}
