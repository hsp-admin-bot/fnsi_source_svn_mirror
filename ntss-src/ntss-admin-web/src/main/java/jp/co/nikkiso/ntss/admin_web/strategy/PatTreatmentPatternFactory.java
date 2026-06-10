package jp.co.nikkiso.ntss.admin_web.strategy;

import jp.co.nikkiso.ntss.admin_web.strategy.deviceModeEnum.DeviceModeEnum;
import jp.co.nikkiso.ntss.admin_web.strategy.patTreatmentPattern.PatTreatmentPatternStategy;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

public class PatTreatmentPatternFactory {
  static Map<String, PatTreatmentPatternStategy> patTreatmentService = new ConcurrentHashMap<>();

  public static PatTreatmentPatternStategy getPatTreatmentStategy(int deviceModeCode) {
    DeviceModeEnum deviceModeEnumByDeviceModeCode = DeviceModeEnum.getDeviceModeEnumByDeviceModeCode(deviceModeCode);
    String name = deviceModeEnumByDeviceModeCode.getName();
    return patTreatmentService.get(name);
  }

  public static void regist(String name,PatTreatmentPatternStategy stategy) {
    patTreatmentService.put(name,stategy);
  }

}
