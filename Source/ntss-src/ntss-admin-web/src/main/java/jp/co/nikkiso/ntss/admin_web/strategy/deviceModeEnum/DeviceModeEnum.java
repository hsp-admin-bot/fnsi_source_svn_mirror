package jp.co.nikkiso.ntss.admin_web.strategy.deviceModeEnum;

import java.util.Arrays;
import java.util.List;

public enum DeviceModeEnum {
  UNKNOWN(-1,"UNKNOWN"),
  HD(0,"HD"),
  ECUM(1,"ECUM"),
  HDF(2,"HDF"),
  HF(3,"HF"),
  HD_AND_REPLACEMENT(4,"HD_AND_REPLACEMENT"),
  ECUM_AND_REPLACEMENT(5,"ECUM_AND_REPLACEMENT"),
  AFBF(6,"AFBF"),
  OHDF(7,"OHDF"),
  OHF(8,"OHF"),
  PURIFICATION(9,"PURIFICATION"),
  I_HDF(10,"IHDF");

  private int deviceModeCode;
  private String name;

  DeviceModeEnum(int deviceModeCode, String name) {
    this.deviceModeCode = deviceModeCode;
    this.name = name;
  }

  public int getDeviceModeCode() {
    return deviceModeCode;
  }

  public void setDeviceModeCode(int deviceModeCode) {
    this.deviceModeCode = deviceModeCode;
  }

  public String getName() {
    return name;
  }

  public void setName(String name) {
    this.name = name;
  }

  public static DeviceModeEnum getDeviceModeEnumByDeviceModeCode(int deviceModeCode) {
    List<DeviceModeEnum> list = Arrays.asList(DeviceModeEnum.values());
    DeviceModeEnum deviceModeEnum = list.stream()
      .filter(item -> item.deviceModeCode == deviceModeCode)
      .findFirst()
      .orElse(null);
    return deviceModeEnum;
  }
}
