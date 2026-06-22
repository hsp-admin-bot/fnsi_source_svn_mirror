package jp.co.nikkiso.ntss.admin_web.service;

import jp.co.nikkiso.ntss.admin_web.web.rest.validation.ApiEntityOrdMain;
import jp.co.nikkiso.ntss.core.dao.MstMedicineDao;
import jp.co.nikkiso.ntss.core.dao.MstMedicineMixDao;
import jp.co.nikkiso.ntss.core.dao.PatTreatmentPatternDao;
import jp.co.nikkiso.ntss.core.entity.MstTreatment;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.PatTreatmentPattern;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.util.CollectionUtils;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;

import static jp.co.nikkiso.ntss.admin_web.constant.DeviceModeSameCategory.existSameCategoryDeviceMode;
import static jp.co.nikkiso.ntss.core.constant.TreatmentItemsDef.getDefaultJSONKeyByCode;

/**
 * add 9664 by kangjie 20240425
 * the same category fluid update ordMain and pattern
 */
@Component
public class SameCategoryFluidComponent {

  @Autowired
  OrdMainService ordMainService;
  @Autowired
  PatTreatmentPatternDao patTreatmentPatternDao;
  @Autowired
  MstMedicineDao mstMedicineDao;
  @Autowired
  MstMedicineMixDao mstMedicineMixDao;

  public static void removeKey(JSONObject json) {
    for (String key :json.keySet()) {
      JSONObject jsonObject = json.getJSONObject(key);
      List<String> defaultJSONKeyList = getDefaultJSONKeyByCode(key);
      if (!CollectionUtils.isEmpty(defaultJSONKeyList)) {
        Iterator<String> keys = jsonObject.keys();
        while (keys.hasNext()) {
          String next = keys.next();
          if (!defaultJSONKeyList.contains(next)) {
            keys.remove();
          }
        }
      }
    }
  }
  // add 9664 by kangjie 20240425 start
  /**
   * @param bodyData         compare Object
   * @param updateJsonObject update data
   * @param ordMain          update object
   * @param mstTreatList     get devicemode
   */
  public void updateNewOrdMainSteps(ApiEntityOrdMain.ValiUpdateIndCond bodyData, JSONObject fluidJSONData, List<OrdMain> ordMain, List<MstTreatment> mstTreatList) {

    // 装置の種類
    String indTreatCondIvMode = bodyData.getInd_treat_cond_iv_mode();
    List<Long> ordNos = filterSameCategoryOrdMainData(ordMain,mstTreatList,indTreatCondIvMode);
    ordMainService.updateNewSteps(fluidJSONData.toString(),ordNos);
  }


  /**
   *
   * @param mergeFluidList merge fluid data
   */
  public void updateNewPatternSteps( List<PatTreatmentPattern> mergeFluidList) {
    patTreatmentPatternDao.updateNewPatternSteps(mergeFluidList);
  }

  public boolean filterSameCategoryPatternData( Integer treatmentCd,
                                               List<MstTreatment> mstTreatList, String indCondInfo,
                                               String ind_treat_cond_iv_mode) {
    Integer currentDeviceMode = mstTreatList.stream()
      .filter(item-> Objects.equals(item.getTreatmentCd(),treatmentCd))
      .findFirst().get().getDeviceMode();
    int deviceMode = currentDeviceMode;
    boolean specialPurificationFluidFlag = false;
    if (deviceMode==9 || deviceMode ==-1) {
      specialPurificationFluidFlag = isExistFluid(indCondInfo);
    }
    return existSameCategoryDeviceMode(ind_treat_cond_iv_mode,currentDeviceMode,specialPurificationFluidFlag);
  }

  /**
   * filter the same category data
   *
   * @param ordMains           ordMain  current batch data
   * @param mstTreatList       mstTreatList  Treatment method data under current batch data
   * @param indTreatCondIvMode
   * @return
   */
  public List<Long> filterSameCategoryOrdMainData(List<OrdMain> ordMains, List<MstTreatment> mstTreatList, String indTreatCondIvMode) {

//    String indCondInfo = ordMains.get(0).getIndCondInfo();
    // Whether the modified plan exists fluid rehydration
//    boolean isExistFluid = isExistFluid(indCondInfo);
    // group by deviceMode => Map<deviceMode,treatmentCds>
    Map<Integer, List<Integer>> deviceModeMap = mstTreatList.stream()
      .collect(Collectors.groupingBy(MstTreatment::getDeviceMode
        , Collectors.mapping(MstTreatment::getTreatmentCd, Collectors.toList())));
    // the same category data
    List<Integer> treatmentCdList = new ArrayList<>();
    deviceModeMap.forEach((deviceMode, treatmentCds) ->{
      if (deviceMode==9 || deviceMode==-1) {
        for (Integer treatmentCd : treatmentCds) {
          String indCondInfo1 = ordMains.stream().filter(
            item -> Objects.equals(treatmentCd, item.getIndTreatmentCd()))
            .findFirst().get().getIndCondInfo();
          // Whether the special purification rehydration solution of the same class is opened
          boolean existFluid = isExistFluid(indCondInfo1);
          if (existSameCategoryDeviceMode(indTreatCondIvMode,deviceMode,existFluid)) {
            treatmentCdList.add(treatmentCd);
          }
        }
      } else {
        boolean specialPurificationFluidFlag = false;
        if (existSameCategoryDeviceMode(indTreatCondIvMode,deviceMode, specialPurificationFluidFlag)) {
          treatmentCdList.addAll(treatmentCds);
        }
      }
    });

//    return ordMains.stream()
//      .filter(item->
//        (Objects.equals(item.getRstDialysisState(),"0")
//          || Objects.isNull(item.getRstDialysisState())
//        ) && treatmentCdList.contains(item.getIndTreatmentCd())
//      )
//      .map(OrdMain::getOrdNo)
//      .collect(Collectors.toList());
    return ordMains.stream()
      .filter(item->
        treatmentCdList.contains(item.getIndTreatmentCd())
      )
      .map(OrdMain::getOrdNo)
      .collect(Collectors.toList());
  }

  /**
   * isExist Fluid data
   * @param indCondInfo
   * @return
   */
  public boolean isExistFluid(String indCondInfo) {
    JSONObject fluidJSONData = new JSONObject(indCondInfo);
    return fluidJSONData.has("19");
  }

  /**
   *
   * remove fluid data
   * @param updateJsonObject
   * @return fluid json data
   */
  public JSONObject removeFluidData(JSONObject updateJsonObject) {
    JSONObject fluidJSONData = new JSONObject();
    if (updateJsonObject.has("19")) {
      fluidJSONData.put("19",updateJsonObject.getJSONObject("19"));
      updateJsonObject.remove("19");
    }
    if (updateJsonObject.has("20")) {
      fluidJSONData.put("20",updateJsonObject.getJSONObject("20"));
      updateJsonObject.remove("20");
    }
    if (updateJsonObject.has("21")) {
      fluidJSONData.put("21",updateJsonObject.getJSONObject("21"));
      updateJsonObject.remove("21");
    }
    if (updateJsonObject.has("22")) {
      fluidJSONData.put("22",updateJsonObject.getJSONObject("22"));
      updateJsonObject.remove("22");
    }
    if (updateJsonObject.has("23")) {
      fluidJSONData.put("23",updateJsonObject.getJSONObject("23"));
      updateJsonObject.remove("23");
    }
    if (updateJsonObject.has("24")) {
      fluidJSONData.put("24",updateJsonObject.getJSONObject("24"));
      updateJsonObject.remove("24");
    }
    return fluidJSONData;
  }
  // add 9664 by kangjie 20240425 end

  // add 10150_9664 by kangjie 20240830 start
  /**
  * @Author kangjie
  * @Description
  * @Date 2024/08/30 8:55
  * @Param [updateJSONObject]
  * @return org.json.JSONObject
  **/
  public JSONObject getFluidDataCommon(JSONObject updateJsonObject) {
    JSONObject fluidJSONData = new JSONObject();
    if (updateJsonObject.has("19")) {
      fluidJSONData.put("19",updateJsonObject.getJSONObject("19"));
    }
    if (updateJsonObject.has("20")) {
      fluidJSONData.put("20",updateJsonObject.getJSONObject("20"));
    }
    if (updateJsonObject.has("21")) {
      fluidJSONData.put("21",updateJsonObject.getJSONObject("21"));
    }
    if (updateJsonObject.has("22")) {
      fluidJSONData.put("22",updateJsonObject.getJSONObject("22"));
    }
    if (updateJsonObject.has("23")) {
      fluidJSONData.put("23",updateJsonObject.getJSONObject("23"));
    }
    if (updateJsonObject.has("24")) {
      fluidJSONData.put("24",updateJsonObject.getJSONObject("24"));
    }
    return fluidJSONData;
  }

  /**
  * @Author kangjie
  * @Description
  * @Date 2024/08/30 8:59
  * @Param [updateJsonObject]
  * @return void
  **/
  public void removeFluidDataCommon( JSONObject updateJsonObject) {
    if (updateJsonObject.has("19")) {
      updateJsonObject.remove("19");
    }
    if (updateJsonObject.has("20")) {
      updateJsonObject.remove("20");
    }
    if (updateJsonObject.has("21")) {
      updateJsonObject.remove("21");
    }
    if (updateJsonObject.has("22")) {
      updateJsonObject.remove("22");
    }
    if (updateJsonObject.has("23")) {
      updateJsonObject.remove("23");
    }
    if (updateJsonObject.has("24")) {
      updateJsonObject.remove("24");
    }
  }
  // add 10150_9664 by kangjie 20240830 end
}
