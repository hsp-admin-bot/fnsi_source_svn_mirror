package jp.co.nikkiso.ntss.admin_web.constant;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public enum DeviceModeSameCategory {
  /*
    -1	UNKNOWN
    0	HD
    1	ECUM
    2	HDF
    3	HF
    4	HD_AND_REPLACEMENT
    5	ECUM_AND_REPLACEMENT
    6	AFBF
    7	OHDF
    8	OHF
    9	PURIFICATION
    10	IHDF
  * */
  OFF_LINE("offLine", Arrays.asList(2,3,6)),
  ON_LINE("onLine",Arrays.asList(7,8,10)),
  NO_FLUID("noIv",Arrays.asList(0,1)),;
  private String categoryName;
  private List<Integer> deviceModes;

  private DeviceModeSameCategory(String categoryName, List<Integer> deviceModes) {
    this.categoryName = categoryName;
    this.deviceModes = deviceModes;
  }

  public String getCategoryName() {
    return categoryName;
  }

  public void setCategoryName(String categoryName) {
    this.categoryName = categoryName;
  }

  public List<Integer> getDeviceModes() {
    return deviceModes;
  }

  public void setDeviceModes(List<Integer> deviceModes) {
    this.deviceModes = deviceModes;
  }

  public static boolean existSameCategoryDeviceMode(String indTreatCondIvMode , Integer compareDeviceMode,
                                                     boolean specialPurificationFluidFlag) {
    List<DeviceModeSameCategory> values = Arrays.asList(DeviceModeSameCategory.values());
    // Edit the special purification, and start the rehydration, the special purification into the off-line group
    List<Integer> list = new ArrayList<Integer>();
    if ("offLine".equals(indTreatCondIvMode)) {
      List<Integer> deviceModes = DeviceModeSameCategory.OFF_LINE.deviceModes;
      if (compareDeviceMode==9 && specialPurificationFluidFlag){
        list.add(9);
      }
      if (compareDeviceMode==-1 && specialPurificationFluidFlag){
        list.add(-1);
      }
      list.addAll(deviceModes);
      if (list.contains(compareDeviceMode)) {
        if ((compareDeviceMode==9 || compareDeviceMode ==-1) && specialPurificationFluidFlag) {
          return true;
        }
        if (compareDeviceMode!=9 && compareDeviceMode!=-1) {
          return true;
        }
        return false;
      }
      return false;
    }

    for (DeviceModeSameCategory deviceModeSameCategory : values) {
      if (deviceModeSameCategory.categoryName.equals(indTreatCondIvMode)) {
        List<Integer> deviceModes1 = deviceModeSameCategory.deviceModes;
        if (deviceModes1.contains(compareDeviceMode)) {
          return true;
        }
        return false;
      }
    }
    return false;
  }
}
