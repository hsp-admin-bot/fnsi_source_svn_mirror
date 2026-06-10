package jp.co.nikkiso.ntss.core.constant;

public enum CondIvEnum {

  HD(0, CondIvEnum.NO_IV),
  ECUM(1, CondIvEnum.NO_IV),

  HDF(2, CondIvEnum.OFF_LINE),
  HF(3, CondIvEnum.OFF_LINE),
  AFBF(6, CondIvEnum.OFF_LINE),

  OHDF(7, CondIvEnum.ON_LINE),
  OHF(8, CondIvEnum.ON_LINE),
  IHDF(10, CondIvEnum.ON_LINE),

  特殊浄化(9, "noIvOrOffLine"),
  不明(-1, "noIvOrOffLine");

  public Integer getDeviceMode() {
    return deviceMode;
  }

  private Integer deviceMode;

  public String getState() {
    return state;
  }

  private String state;

  CondIvEnum(Integer deviceMode, String state) {
    this.state = state;
    this.deviceMode = deviceMode;
  }

  public static CondIvEnum getByDeviceMode(Integer deviceMode) {
    CondIvEnum[] condIvOnLineOffLines = CondIvEnum.values();
    for (CondIvEnum condIvOnLineOffLine : condIvOnLineOffLines) {
      if (condIvOnLineOffLine.deviceMode.equals(deviceMode)) {
        return condIvOnLineOffLine;
      }
    }
    return null;
  }

  public static final String NO_IV = "noIv";
  public static final String ON_LINE = "onLine";
  public static final String OFF_LINE = "offLine";

}
