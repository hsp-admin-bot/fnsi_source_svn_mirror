package jp.co.nikkiso.ntss.admin_web.strategy;

import jp.co.nikkiso.ntss.admin_web.strategy.deviceModeEnum.DeviceModeEnum;
import jp.co.nikkiso.ntss.admin_web.strategy.ordMainTreatment.OrdMainTreatmentStrategy;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

public class OrdMainTreatmentFactory {
  static Map<String,OrdMainTreatmentStrategy> service = new ConcurrentHashMap<>();

  public static OrdMainTreatmentStrategy getStrategy(int deviceCode){
    DeviceModeEnum deviceModeEnum = DeviceModeEnum.getDeviceModeEnumByDeviceModeCode(deviceCode);
    String name = deviceModeEnum.getName();
    return service.get(name);
  }

  public static void register(String key,OrdMainTreatmentStrategy value){
    if (service.containsKey(key)) {
    } else {
      service.put(key,value);
    }
  }

}
