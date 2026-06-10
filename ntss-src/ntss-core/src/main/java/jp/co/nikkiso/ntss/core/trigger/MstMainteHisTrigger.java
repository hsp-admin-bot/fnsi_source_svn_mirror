package jp.co.nikkiso.ntss.core.trigger;

import jp.co.nikkiso.ntss.core.dao.MstMachineTypeDao;
import jp.co.nikkiso.ntss.core.dao.MstMainteCategoryHstDao;
import jp.co.nikkiso.ntss.core.dao.MstMainteDetailHstDao;
import jp.co.nikkiso.ntss.core.dao.MstMainteLayoutGroupHstDao;
import jp.co.nikkiso.ntss.core.dao.MstMainteLayoutHstDao;
import jp.co.nikkiso.ntss.core.entity.MstMainteCategoryHst;
import jp.co.nikkiso.ntss.core.entity.MstMainteDetailHst;
import jp.co.nikkiso.ntss.core.entity.MstMainteLayoutGroupHst;
import jp.co.nikkiso.ntss.core.entity.MstMainteLayoutHst;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.util.ObjectUtils;

import java.sql.Timestamp;
import java.util.HashMap;
import java.util.Map;

import static jp.co.nikkiso.ntss.core.dao.MasterMaintenanceGenericDao.ALIAS_CODE;

@Component
public class MstMainteHisTrigger {

  private static String IS_DISP_1 = "1";
  private static String IS_DEL_0 = "0";

  @Autowired
  MstMainteCategoryHstDao mstMainteCategoryHstDao;

  @Autowired
  MstMainteDetailHstDao mstMainteDetailHstDao;

  @Autowired
  MstMainteLayoutHstDao mstMainteLayoutHstDao;

  @Autowired
  MstMainteLayoutGroupHstDao mstMainteLayoutGroupHstDao;
  @Autowired
  MstMachineTypeDao mstMachineTypeDao;

  public void triggerExecution(String exeTableName, String facilityCd, Map<String, Object> newData) {
    if ("mst_mainte_category".equals(exeTableName)) {
      MstMainteCategoryHst newMstMainteCategoryHst = getCategoryObjFromMap(facilityCd, newData);
      if (newData.containsKey(ALIAS_CODE)) {
        newMstMainteCategoryHst.setMainteCategoryCd((Long) newData.get("code"));
      }
      mstMainteCategoryHstDao.insertCategoryHst(newMstMainteCategoryHst);
    } else if ("mst_mainte_detail".equals(exeTableName)) {
      MstMainteDetailHst newMstMainteDetailHst = getDetailObjFromMap(facilityCd, newData);
      if (newData.containsKey(ALIAS_CODE)) {
        newMstMainteDetailHst.setMainteDetailCd((Long) newData.get("code"));
      }
      mstMainteDetailHstDao.insertDetailHst(newMstMainteDetailHst);
    } else if ("mst_mainte_layout".equals(exeTableName)) {
      MstMainteLayoutHst newMstMainteLayoutHst = getLayoutObjFromMap(facilityCd, newData);
      if (newData.containsKey(ALIAS_CODE)) {
        newMstMainteLayoutHst.setMainteLayoutCd((Long) newData.get("code"));
      }
      mstMainteLayoutHstDao.insertLayoutHst(newMstMainteLayoutHst);
    } else if ("mst_mainte_layout_group".equals(exeTableName)) {
      MstMainteLayoutGroupHst newMstMainteLayoutGroupHst = getLayoutGroupObjFromMap(facilityCd, newData);
      if (newData.containsKey(ALIAS_CODE)) {
        newMstMainteLayoutGroupHst.setMainteLayoutGroupCd((Long) newData.get("code"));
      }
      mstMainteLayoutGroupHstDao.insertLayoutGroupHst(newMstMainteLayoutGroupHst);
    }
  }

  private MstMainteCategoryHst getCategoryObjFromMap(String facilityCd, Map<String, Object> mstMachineData) {
    Map<String, Object> convertMap = new HashMap<>(mstMachineData);
    Map<String, Object> processedMap = convertToUnderlineKey(convertMap);
    MstMainteCategoryHst mstMainteCategoryHst = new MstMainteCategoryHst();
    mstMainteCategoryHst.setMainteCategoryCd(processedMap.containsKey("mainte_category_cd")
      && !ObjectUtils.isEmpty(processedMap.get("mainte_category_cd")) ? (long) processedMap.get("mainte_category_cd") : null);
    mstMainteCategoryHst.setEditionNo(processedMap.containsKey("edition_no") && !ObjectUtils.isEmpty(processedMap.get("edition_no"))
      ? (Integer) processedMap.get("edition_no") : null);
    if ("".equals(facilityCd)) {
      mstMainteCategoryHst.setFacilityCd(processedMap.containsKey("facility_cd") && !ObjectUtils.isEmpty(processedMap.get("facility_cd"))
        ? (String) processedMap.get("facility_cd") : null);
      mstMainteCategoryHst.setCategoryName(processedMap.containsKey("category_name") && !ObjectUtils.isEmpty(processedMap.get("category_name"))
        ? (String) processedMap.get("category_name") : null);
    } else {
      mstMainteCategoryHst.setFacilityCd(facilityCd);
      mstMainteCategoryHst.setCategoryName(processedMap.containsKey("name") && !ObjectUtils.isEmpty(processedMap.get("name"))
        ? (String) processedMap.get("name") : null);
    }
    mstMainteCategoryHst.setIsDisp(processedMap.containsKey("is_disp") && !ObjectUtils.isEmpty(processedMap.get("is_disp"))
      ? (String) processedMap.get("is_disp") : IS_DISP_1);
    mstMainteCategoryHst.setIsDel(processedMap.containsKey("is_del") && !ObjectUtils.isEmpty(processedMap.get("is_del"))
      ? (String) processedMap.get("is_del") : IS_DEL_0);
    mstMainteCategoryHst.setUpDate(new Timestamp(System.currentTimeMillis()));
    mstMainteCategoryHst.setRegDate(new Timestamp(System.currentTimeMillis()));
    mstMainteCategoryHst.setDetail(processedMap.containsKey("detail") && !ObjectUtils.isEmpty(processedMap.get("detail"))
      ? processedMap.get("detail").toString() : null);
    mstMainteCategoryHst.setMainteClass(processedMap.containsKey("mainte_class") && !ObjectUtils.isEmpty(processedMap.get("mainte_class"))
      ? (String) processedMap.get("mainte_class") : null);
    return mstMainteCategoryHst;
  }

  private MstMainteDetailHst getDetailObjFromMap(String facilityCd, Map<String, Object> mstMachineData) {
    Map<String, Object> convertMap = new HashMap<>(mstMachineData);
    Map<String, Object> processedMap = convertToUnderlineKey(convertMap);
    MstMainteDetailHst mstMainteDetailHst = new MstMainteDetailHst();
    mstMainteDetailHst.setMainteDetailCd(processedMap.containsKey("mainte_detail_cd")
      && !ObjectUtils.isEmpty(processedMap.get("mainte_detail_cd")) ? (long) processedMap.get("mainte_detail_cd") : null);
    mstMainteDetailHst.setEditionNo(processedMap.containsKey("edition_no") && !ObjectUtils.isEmpty(processedMap.get("edition_no"))
      ? (Integer) processedMap.get("edition_no") : null);
    if ("".equals(facilityCd)) {
      mstMainteDetailHst.setFacilityCd(processedMap.containsKey("facility_cd") && !ObjectUtils.isEmpty(processedMap.get("facility_cd"))
        ? (String) processedMap.get("facility_cd") : null);
      mstMainteDetailHst.setMainteContent1(processedMap.containsKey("mainte_content_1") && !ObjectUtils.isEmpty(processedMap.get("mainte_content_1"))
        ? (String) processedMap.get("mainte_content_1") : null);
      mstMainteDetailHst.setMainteContent2(processedMap.containsKey("mainte_content_2") && !ObjectUtils.isEmpty(processedMap.get("mainte_content_2"))
        ? (String) processedMap.get("mainte_content_2") : null);
      mstMainteDetailHst.setMainteContent3(processedMap.containsKey("mainte_content_3") && !ObjectUtils.isEmpty(processedMap.get("mainte_content_3"))
        ? (String) processedMap.get("mainte_content_3") : null);
    } else {
      mstMainteDetailHst.setFacilityCd(facilityCd);
      mstMainteDetailHst.setMainteContent1(processedMap.containsKey("mainte_content1") && !ObjectUtils.isEmpty(processedMap.get("mainte_content1"))
        ? (String) processedMap.get("mainte_content1") : null);
      mstMainteDetailHst.setMainteContent2(processedMap.containsKey("mainte_content2") && !ObjectUtils.isEmpty(processedMap.get("mainte_content2"))
        ? (String) processedMap.get("mainte_content2") : null);
      mstMainteDetailHst.setMainteContent3(processedMap.containsKey("mainte_content3") && !ObjectUtils.isEmpty(processedMap.get("mainte_content3"))
        ? (String) processedMap.get("mainte_content3") : null);
    }
    mstMainteDetailHst.setMainteCategoryCd(processedMap.containsKey("mainte_category_cd") && !ObjectUtils.isEmpty(processedMap.get("mainte_category_cd"))
      ? (Long) processedMap.get("mainte_category_cd") : null);
    mstMainteDetailHst.setIsDisp(processedMap.containsKey("is_disp") && !ObjectUtils.isEmpty(processedMap.get("is_disp"))
      ? (String) processedMap.get("is_disp") : IS_DISP_1);
    mstMainteDetailHst.setIsDel(processedMap.containsKey("is_del") && !ObjectUtils.isEmpty(processedMap.get("is_del"))
      ? (String) processedMap.get("is_del") : IS_DEL_0);
    mstMainteDetailHst.setUpDate(new Timestamp(System.currentTimeMillis()));
    mstMainteDetailHst.setRegDate(new Timestamp(System.currentTimeMillis()));
    if (processedMap.containsKey("mainte_class") && !ObjectUtils.isEmpty(processedMap.get("mainte_class"))) {
      mstMainteDetailHst.setMainteClass((String) processedMap.get("mainte_class"));
    }
    if (processedMap.containsKey("ans_pattern") && !ObjectUtils.isEmpty(processedMap.get("ans_pattern"))) {
      mstMainteDetailHst.setAnsPattern((String) processedMap.get("ans_pattern"));
    }
    if (processedMap.containsKey("is_cmt") && !ObjectUtils.isEmpty(processedMap.get("is_cmt"))) {
      mstMainteDetailHst.setIsCmt((String) processedMap.get("is_cmt"));
    }
    mstMainteDetailHst.setIniText(processedMap.containsKey("ini_text") && !ObjectUtils.isEmpty(processedMap.get("ini_text"))
      ? (String) processedMap.get("ini_text") : null);
    return mstMainteDetailHst;
  }

  private MstMainteLayoutHst getLayoutObjFromMap(String facilityCd, Map<String, Object> mstMachineData) {
    Map<String, Object> convertMap = new HashMap<>(mstMachineData);
    Map<String, Object> processedMap = convertToUnderlineKey(convertMap);
    MstMainteLayoutHst mstMainteLayoutHst = new MstMainteLayoutHst();
    mstMainteLayoutHst.setMainteLayoutCd(processedMap.containsKey("mainte_layout_cd")
      && !ObjectUtils.isEmpty(processedMap.get("mainte_layout_cd")) ? (long) processedMap.get("mainte_layout_cd") : null);
    mstMainteLayoutHst.setEditionNo(processedMap.containsKey("edition_no") && !ObjectUtils.isEmpty(processedMap.get("edition_no"))
      ? (Integer) processedMap.get("edition_no") : null);
    if ("".equals(facilityCd)) {
      mstMainteLayoutHst.setFacilityCd(processedMap.containsKey("facility_cd") && !ObjectUtils.isEmpty(processedMap.get("facility_cd"))
        ? (String) processedMap.get("facility_cd") : null);
      mstMainteLayoutHst.setDetailInfo1(processedMap.containsKey("detail_info_1") && !ObjectUtils.isEmpty(processedMap.get("detail_info_1"))
        ? processedMap.get("detail_info_1").toString() : null);
      mstMainteLayoutHst.setDetailInfo2(processedMap.containsKey("detail_info_2") && !ObjectUtils.isEmpty(processedMap.get("detail_info_2"))
        ? processedMap.get("detail_info_2").toString() : null);
    } else {
      mstMainteLayoutHst.setFacilityCd(facilityCd);
      mstMainteLayoutHst.setDetailInfo1(processedMap.containsKey("detail_info1") && !ObjectUtils.isEmpty(processedMap.get("detail_info1"))
        ? processedMap.get("detail_info1").toString() : null);
      mstMainteLayoutHst.setDetailInfo2(processedMap.containsKey("detail_info2") && !ObjectUtils.isEmpty(processedMap.get("detail_info2"))
        ? processedMap.get("detail_info2").toString() : null);
    }
    mstMainteLayoutHst.setLayoutClass(processedMap.containsKey("layout_class") && !ObjectUtils.isEmpty(processedMap.get("layout_class"))
      ? processedMap.get("layout_class").toString() : null);
    mstMainteLayoutHst.setLayoutName(processedMap.containsKey("layout_name") && !ObjectUtils.isEmpty(processedMap.get("layout_name"))
      ? processedMap.get("layout_name").toString() : null);
    mstMainteLayoutHst.setTypeInfo(processedMap.containsKey("type_info") && !ObjectUtils.isEmpty(processedMap.get("type_info"))
      ? processedMap.get("type_info").toString() : null);
    mstMainteLayoutHst.setIsDisp(processedMap.containsKey("is_disp") && !ObjectUtils.isEmpty(processedMap.get("is_disp"))
      ? (String) processedMap.get("is_disp") : IS_DISP_1);
    mstMainteLayoutHst.setIsDel(processedMap.containsKey("is_del") && !ObjectUtils.isEmpty(processedMap.get("is_del"))
      ? (String) processedMap.get("is_del") : IS_DEL_0);
    mstMainteLayoutHst.setUpDate(new Timestamp(System.currentTimeMillis()));
    mstMainteLayoutHst.setRegDate(new Timestamp(System.currentTimeMillis()));
    mstMainteLayoutHst.setLayoutHeader(processedMap.containsKey("layout_header") && !ObjectUtils.isEmpty(processedMap.get("layout_header"))
      ? (String) processedMap.get("layout_header") : null);
    return mstMainteLayoutHst;
  }

  private MstMainteLayoutGroupHst getLayoutGroupObjFromMap(String facilityCd, Map<String, Object> mstMachineData) {
    Map<String, Object> convertMap = new HashMap<>(mstMachineData);
    Map<String, Object> processedMap = convertToUnderlineKey(convertMap);
    MstMainteLayoutGroupHst mstMainteLayoutGroupHst = new MstMainteLayoutGroupHst();
    mstMainteLayoutGroupHst.setMainteLayoutGroupCd(processedMap.containsKey("mainte_layout_group_cd")
      && !ObjectUtils.isEmpty(processedMap.get("mainte_layout_group_cd")) ? (long) processedMap.get("mainte_layout_group_cd") : null);
    mstMainteLayoutGroupHst.setEditionNo(processedMap.containsKey("edition_no") && !ObjectUtils.isEmpty(processedMap.get("edition_no"))
      ? (Integer) processedMap.get("edition_no") : null);
    if ("".equals(facilityCd)) {
      mstMainteLayoutGroupHst.setFacilityCd(processedMap.containsKey("facility_cd") && !ObjectUtils.isEmpty(processedMap.get("facility_cd"))
        ? (String) processedMap.get("facility_cd") : null);
    } else {
      mstMainteLayoutGroupHst.setFacilityCd(facilityCd);
    }
    mstMainteLayoutGroupHst.setGroupName(processedMap.containsKey("group_name") && !ObjectUtils.isEmpty(processedMap.get("group_name"))
      ? (String) processedMap.get("group_name") : null);
    mstMainteLayoutGroupHst.setLayoutList(processedMap.containsKey("layout_list") && !ObjectUtils.isEmpty(processedMap.get("layout_list"))
      ? processedMap.get("layout_list").toString() : null);
    mstMainteLayoutGroupHst.setIsDisp(processedMap.containsKey("is_disp") && !ObjectUtils.isEmpty(processedMap.get("is_disp"))
      ? (String) processedMap.get("is_disp") : IS_DISP_1);
    mstMainteLayoutGroupHst.setIsDel(processedMap.containsKey("is_del") && !ObjectUtils.isEmpty(processedMap.get("is_del"))
      ? (String) processedMap.get("is_del") : IS_DEL_0);
    mstMainteLayoutGroupHst.setUpDate(new Timestamp(System.currentTimeMillis()));
    mstMainteLayoutGroupHst.setRegDate(new Timestamp(System.currentTimeMillis()));
    return mstMainteLayoutGroupHst;
  }

  /**
   * Map内のすべてのkeyをラクダピーク形式からアンダースコア形式に変換する
   *
   * @param map 変換するMap
   * @return 変換後のMap
   */
  public static Map<String, Object> convertToUnderlineKey(Map<String, Object> map) {
    Map<String, Object> result = new HashMap<>();
    for (Map.Entry<String, Object> entry : map.entrySet()) {
      String key = entry.getKey();
      Object value = entry.getValue();
      key = camelToUnderline(key);
      if (value instanceof Map) {
        value = convertToUnderlineKey((Map<String, Object>) value);
      }
      result.put(key, value);
    }
    return result;
  }

  /**
   * ラクダピーク形式の文字列をアンダースコア形式に変換するには
   *
   * @param str 変換する文字列
   * @return 変換後の文字列
   */
  public static String camelToUnderline(String str) {
    StringBuilder sb = new StringBuilder();
    char[] charArray = str.toCharArray();
    for (int i = 0; i < charArray.length; i++) {
      char c = charArray[i];
      if (Character.isUpperCase(c)) {
        sb.append("_").append(Character.toLowerCase(c));
      } else {
        sb.append(c);
      }
    }
    return sb.toString();
  }

}
