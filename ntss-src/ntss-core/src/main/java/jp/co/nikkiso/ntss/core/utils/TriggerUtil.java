package jp.co.nikkiso.ntss.core.utils;

import jp.co.nikkiso.ntss.core.dao.OrdScheduleDao;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * @author IES_WANGFENG
 */
@Component
public class TriggerUtil {

  /* upd by chamaojia 2026-05-07 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */  
  // private static String IS_DEL_1 = "1";
  private static final String IS_DEL_1 = "1";
  /* upd by chamaojia 2026-05-07 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */

  @Autowired
  private OrdScheduleDao ordScheduleDao;



  public void updateTriggerOrdMain(List<OrdMain> oldOrdMains, List<OrdMain> newOrdMains) {
    this.updateTriggerListOrdMain(oldOrdMains, newOrdMains);
  }

  public void insertTriggerOrdMain(List<OrdMain> newOrdMains) {
    this.insertListTriggerOrdMain(newOrdMains);
  }

  public void deleteTriggerOrdMain(List<OrdMain> oldOrdMains) {
    this.deleteListTriggerOrdMain(oldOrdMains);
  }


  public void updateTriggerListOrdMain(List<OrdMain> oldOrdMains, List<OrdMain> newOrdMains) {
    if (oldOrdMains.isEmpty()) return;
    // #10889 2024.09.05 add ？？？？患者時に例外が発生するため離脱する TDC片口 start
    if (newOrdMains.stream().anyMatch(item -> item.getPatId() == null || item.getIndKurCd() == null || item.getIndBedCd() == null)){
      return;
    }
    // #10889 2024.09.05 add ？？？？患者時に例外が発生するため離脱する TDC片口 end
    List<OrdMain> resultOrdMainList = newOrdMains.stream()
            .filter(item -> oldOrdMains.stream().map(e -> e.getOrdNo())
                    .collect(Collectors.toList()).contains(item.getOrdNo()))
            .collect(Collectors.toList());
    //mod by ztc 2023-02-14 [Optimize runtime insert] --start /
    this.insertListTriggerOrdMain(resultOrdMainList);
    //mod by ztc 2023-02-14 [Optimize runtime insert] --end /
    List<OrdMain> resultOrdMainDiffList = new ArrayList<>();
    for (OrdMain oldOrdMain : oldOrdMains) {
      if (oldOrdMain == null) {
        continue;
      }
      OrdMain newOrdMain = newOrdMains.stream()
        .filter(n -> n.getOrdNo().equals(oldOrdMain.getOrdNo())
          && (!n.getTreatDate().equals(oldOrdMain.getTreatDate())
          || !n.getIndKurCd().equals(oldOrdMain.getIndKurCd())
          || !n.getIndBedCd().equals(oldOrdMain.getIndBedCd()))).findFirst().orElse(null);
      if(newOrdMain != null){
        resultOrdMainDiffList.add(newOrdMain);
      }
    }

    if(!resultOrdMainDiffList.isEmpty()){
      // mod #10553 shiyw start
      //List<Long> deleteDummyScheduleList = resultOrdMainList.stream().map(r -> r.getOrdNo()).collect(Collectors.toList());
      List<Long> deleteDummyScheduleList = resultOrdMainDiffList.stream().map(r -> r.getOrdNo()).collect(Collectors.toList());
      // mod #10553 shiyw end
      /* modify by shiyw 2023-02-24 [#8101] Append the where condition facilityCd, matching the primary key [facility_cd,ord_no], to improve the del speed --start */
      //ordScheduleDao.deleteDummyScheduleList(deleteDummyScheduleList);
      String facilityCd = resultOrdMainList.get(0).getFacilityCd();
      ordScheduleDao.deleteDummyScheduleList(facilityCd,deleteDummyScheduleList);
      /* modify by shiyw 2023-02-24 [#8101] Append the where condition facilityCd, matching the primary key [facility_cd,ord_no], to improve the del speed --end */
      ordScheduleDao.updateOrdScheduleList(resultOrdMainDiffList);
    }
    List<Long> deleteScheduleByOrdNoList = resultOrdMainList.stream()
            .filter(romidl -> IS_DEL_1.equals(romidl.getIsDel())).map(r -> r.getOrdNo()).collect(Collectors.toList());
    if (deleteScheduleByOrdNoList.size() > 0) {
      /* modify by shiyw 2023-02-24 [#8101] Append the where condition facilityCd, matching the primary key [facility_cd,ord_no], to improve the del speed --start */
      //ordScheduleDao.deleteScheduleByOrdNoList(deleteScheduleByOrdNoList);
      String facilityCd = resultOrdMainList.get(0).getFacilityCd();
      ordScheduleDao.deleteScheduleByOrdNoList(facilityCd,deleteScheduleByOrdNoList);
      /* modify by shiyw 2023-02-24 [#8101] Append the where condition facilityCd, matching the primary key [facility_cd,ord_no], to improve the del speed --end */
    }
  }

  /* add by shiyw 2023-02-24 [#8101] --start */
  public void updateOrdMainTriggerForOrdScheduleInsert(List<OrdMain> ordMains) {
    if (ordMains.isEmpty()) return;
    ordMains.stream().forEach(roml -> {
      int ordScheduleRowCnt = ordScheduleDao.selectOrdScheduleRowCntByOrdNo(roml.getFacilityCd(),roml.getOrdNo());
      if (ordScheduleRowCnt == 0) {
        ordScheduleDao.insertOrdSchedule(roml);
      }
    });
  }/* add by shiyw 2023-02-24 [#8101] --end */


  //mod by ztc 2023-02-14 [Optimize runtime insert] --start /
  public void insertListTriggerOrdMain(List<OrdMain> newOrdMains) {
    if (newOrdMains.size() == 0) return;
    String facilityCd = newOrdMains.get(0).getFacilityCd();
    List<Long> ordScheduleRowCntList = newOrdMains.stream().map(r -> r.getOrdNo()).collect(Collectors.toList());
    List<Long> wherOrdScheduleData = ordScheduleDao.selectOrdScheduleRowCntByOrdNoList(facilityCd, ordScheduleRowCntList);
    List<OrdMain> removeOrdScheduleList = new ArrayList<>();
    if(!wherOrdScheduleData.isEmpty()){
      wherOrdScheduleData.forEach(bios->{
        removeOrdScheduleList.addAll(newOrdMains.stream().filter(item -> item.getOrdNo().equals(bios)).collect(Collectors.toList()));
      });
    }
    List<OrdMain> ordMainsRemoveList = new ArrayList<>(newOrdMains);
    ordMainsRemoveList.removeAll(removeOrdScheduleList);
    if(!ordMainsRemoveList.isEmpty()){
      ordScheduleDao.insertOrdScheduleList(ordMainsRemoveList);
    }
  }
  //mod by ztc 2023-02-14 [Optimize runtime end] --start /

  public void deleteListTriggerOrdMain(List<OrdMain> oldOrdMains) {
    if (oldOrdMains.isEmpty()) return;
    List<Long> deleteScheduleByOrdNoList = oldOrdMains.stream().map(r -> r.getOrdNo()).collect(Collectors.toList());
    /* modify by shiyw 2023-02-24 [#8101] Append the where condition facilityCd, matching the primary key [facility_cd,ord_no], to improve the del speed --start */
    //ordScheduleDao.deleteScheduleByOrdNoList(deleteScheduleByOrdNoList);
    String facilityCd = oldOrdMains.get(0).getFacilityCd();
    ordScheduleDao.deleteScheduleByOrdNoList(facilityCd,deleteScheduleByOrdNoList);
    /* modify by shiyw 2023-02-24 [#8101] Append the where condition facilityCd, matching the primary key [facility_cd,ord_no], to improve the del speed --end */
  }

  /**
   * Get the value from HashMap according to fieldKey (compatible with hump naming)
   * @param dataMap
   * @param fieldKey eg. user_name
   * @param <T>
   * @return
   */
  public static <T> T getValueFromMap(Map<String, Object> dataMap, String fieldKey){
    if(dataMap.containsKey(fieldKey)){
      return (T) dataMap.get(fieldKey);
    }
    String humpFieldKey = getHumpStr(fieldKey);
    if(dataMap.containsKey(humpFieldKey)){
      return (T) dataMap.get(humpFieldKey);
    }
    return null;
  }

  /**
   * Underline naming convert to hump naming
   *    eg. "user_name" will be converted to "userName"
   * @param column
   * @return
   */
  private static String getHumpStr(String column) {
    String name = column;
    if (name.indexOf("_") > 0 && name.length() != name.indexOf("_") + 1) {
      int lengthPlace = name.indexOf("_");
      name = name.replaceFirst("_", "");
      String s = name.substring(lengthPlace, lengthPlace + 1);
      s = s.toUpperCase();
      column = name.substring(0, lengthPlace) + s + name.substring(lengthPlace + 1);
    } else {
      return column;
    }
    return getHumpStr(column);
  }

  public static Long getLongValueFromMap(Map<String, Object> dataMap, String fieldKey){
    Object obj = null;
    if(dataMap.containsKey(fieldKey)){
      obj = dataMap.get(fieldKey);
    }
    String humpFieldKey = getHumpStr(fieldKey);
    if(dataMap.containsKey(humpFieldKey)){
      obj = dataMap.get(humpFieldKey);
    }
    Long returnValue = null;
    if(obj != null && !"".equals(obj)){
      if(obj instanceof Long){
        returnValue = (Long) obj;
      }else if(obj instanceof Integer){
        returnValue = ((Integer) obj).longValue();
      }else if(obj instanceof String){
        returnValue = Long.valueOf(String.valueOf(obj));
      }
    }
    return returnValue;
  }

  public static Integer getIntegerValueFromMap(Map<String, Object> dataMap, String fieldKey){
    Object obj = null;
    if(dataMap.containsKey(fieldKey)){
      obj = dataMap.get(fieldKey);
    }
    String humpFieldKey = getHumpStr(fieldKey);
    if(dataMap.containsKey(humpFieldKey)){
      obj = dataMap.get(humpFieldKey);
    }
    Integer returnValue = null;
    if(obj != null && !"".equals(obj)){
      if(obj instanceof Integer){
        returnValue = (Integer) obj;
      }else if(obj instanceof Long){
        returnValue = ((Long) obj).intValue();
      }else if(obj instanceof String){
        returnValue = Integer.valueOf(String.valueOf(obj));
      }
    }
    return returnValue;
  }

  public static String getStringValueFromMap(Map<String, Object> dataMap, String fieldKey){
    Object obj = null;
    if(dataMap.containsKey(fieldKey)){
      obj = dataMap.get(fieldKey);
    }
    String humpFieldKey = getHumpStr(fieldKey);
    if(dataMap.containsKey(humpFieldKey)){
      obj = dataMap.get(humpFieldKey);
    }
    String returnValue = null;
    if(obj != null && !"".equals(obj)){
      if(obj instanceof String){
        returnValue = (String) obj;
      }
    }
    return returnValue;
  }


  public static Timestamp getTimestampValueFromMap(Map<String, Object> dataMap, String fieldKey){
    Object obj = null;
    if(dataMap.containsKey(fieldKey)){
      obj = dataMap.get(fieldKey);
    }
    String humpFieldKey = getHumpStr(fieldKey);
    if(dataMap.containsKey(humpFieldKey)){
      obj = dataMap.get(humpFieldKey);
    }
    Timestamp returnValue = null;
    if(obj != null && !"".equals(obj)){
      if(obj instanceof Timestamp){
        returnValue = (Timestamp) obj;
      }
    }
    return returnValue;
  }

}
