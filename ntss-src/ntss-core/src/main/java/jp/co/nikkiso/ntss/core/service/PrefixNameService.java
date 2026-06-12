package jp.co.nikkiso.ntss.core.service;
import tools.jackson.core.JacksonException;
import tools.jackson.core.type.TypeReference;
import tools.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.DBAppWebAPIDao;
import jp.co.nikkiso.ntss.core.entity.MstMedicineMix;
import jp.co.nikkiso.ntss.core.entity.MstTabooAllergy;
import jp.co.nikkiso.ntss.core.entity.custom.MstTabooAllergyDetailInfo;
import jp.co.nikkiso.ntss.core.entity.custom.PatInfoTabooAllergy;
import jp.co.nikkiso.ntss.core.logevent.LogServiceCore;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.util.ObjectUtils;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

/* add by shiyw 2024-09-13 [10659] 接頭文字対応 --start */
@Component
public class PrefixNameService {

  @Autowired
  private DBAppWebAPIDao dBAppWebAPIDao;

  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
  @Autowired
  private LogServiceCore logServiceCore;
// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end

  /**
   * 薬剤/医療材料/ダイアライザ 名前の接頭辞取得
   * @param patTabooAllergyInfo  禁忌・アレルギー情報(患者)
   * @param tabooAllergyList     禁忌・アレルギーマスタ
   * @param dataType             データ型
   *                                 "1":普通薬剤  "3":医材 "4":ダイアライザ
   * @param cd                   薬剤コード/医療材料コード/ダイアライザコード
   * @param useEndDate           使用終了日
   * @param isDisp               表示フラグ
   * @param isDel                削除フラグ
   * @return
   */
  public String getPrefixOfName(String patTabooAllergyInfo, List<MstTabooAllergy> tabooAllergyList
          , String dataType, Integer cd, String useEndDate
          , String isDisp, String isDel) {
    StringBuilder prefixName = new StringBuilder();
    // 【禁忌・ｱﾚﾙｷﾞｰ】、【禁忌】、【ｱﾚﾙｷﾞｰ】prefix supplementation
    String tabooAllergyType = getTabooAllergyType(patTabooAllergyInfo, tabooAllergyList, dataType, cd);
    if (!ObjectUtils.isEmpty(tabooAllergyType)) {
      String tabooAllergyPrefix = "";
      if ("1".equals(tabooAllergyType)) { // 禁忌
        tabooAllergyPrefix = CoreConstant.NamePrefixJapan.TABOO;
      } else if ("2".equals(tabooAllergyType)) { // ｱﾚﾙｷﾞｰ
        tabooAllergyPrefix = CoreConstant.NamePrefixJapan.ALLERGY;
      } else if ("3".equals(tabooAllergyType)) { // 禁忌・ｱﾚﾙｷﾞｰ
        tabooAllergyPrefix = CoreConstant.NamePrefixJapan.TABOO_AND_ALLERGY;
      }
      prefixName.append(tabooAllergyPrefix);
    }

    /* del by chamaojia 2026-01-16 [11072] マスタに関連する接頭語を削除する --start */
    // // 【期限切れ】prefix supplementation
    // if (isDataExpired(useEndDate)) {
    //   prefixName.append(CoreConstant.NamePrefixJapan.EXPIRED);
    // }
    //
    // // 【削除済み】prefix supplementation
    // if (isDataDeleted(isDisp, isDel)) {
    //   prefixName.append(CoreConstant.NamePrefixJapan.DELETED);
    // }
    /* del by chamaojia 2026-01-16 [11072] マスタに関連する接頭語を削除する --end */

    return prefixName.toString();
  }

  /**
   * 調整薬剤 名前の接頭辞取得
   * @param patTabooAllergyInfo  禁忌・アレルギー情報(患者)
   * @param tabooAllergyList     禁忌・アレルギーマスタ
   * @param medicineMix          MstMedicineMix
   * @return
   */
  public String getMedicineMixPrefixOfName(String patTabooAllergyInfo, List<MstTabooAllergy> tabooAllergyList, MstMedicineMix medicineMix) {
    Integer cd = medicineMix.getMedicineMixCd();
    String mixInfo = medicineMix.getMixInfo();
    /* del by chamaojia 2026-01-16 [11072] マスタに関連する接頭語を削除する --start */
    // String facilityCd = medicineMix.getFacilityCd();
    // String isDisp = medicineMix.getIsDisp();
    // String isDel = medicineMix.getIsDel();
    /* del by chamaojia 2026-01-16 [11072] マスタに関連する接頭語を削除する --end */
    StringBuilder prefixName = new StringBuilder();
    JSONArray mixInfoJSONArray = ObjectUtils.isEmpty(mixInfo) ? new JSONArray() : new JSONArray(mixInfo);

    // 【禁忌・ｱﾚﾙｷﾞｰ】、【禁忌】、【ｱﾚﾙｷﾞｰ】prefix supplementation
    String tabooAllergyType = getTabooAllergyType(patTabooAllergyInfo, tabooAllergyList, "2", cd);
    /* del by chamaojia 2026-01-16 [11072] マスタに関連する接頭語を削除する --start */
    // boolean isDataExpired = false;
    // boolean isDataIncludeDeleted = false;
    // boolean isDataDeleted = isDataDeleted(isDisp, isDel);
    /* del by chamaojia 2026-01-16 [11072] マスタに関連する接頭語を削除する --end */

    if (tabooAllergyType != null && !"3".equals(tabooAllergyType)) {
      Set<String> tabooAllergyTypeSet = new HashSet<>();
      if (!"".equals(tabooAllergyType)) {
        tabooAllergyTypeSet.add(tabooAllergyType);
      }
      for (int i = 0; i < mixInfoJSONArray.length(); i++) {
        JSONObject mediObj = mixInfoJSONArray.getJSONObject(i);
        if (mediObj == null || mediObj.get("cd") == null) {
          continue;
        }

        String subTabooAllergyType = getTabooAllergyType(patTabooAllergyInfo, tabooAllergyList
                , "1", Integer.valueOf(mediObj.get("cd").toString()));
        if (!ObjectUtils.isEmpty(subTabooAllergyType)) {
          if ("3".equals(subTabooAllergyType)) {
            tabooAllergyType = subTabooAllergyType;
            break;
          }
          tabooAllergyTypeSet.add(subTabooAllergyType);
        }
      }

      if (tabooAllergyTypeSet.size() != 0) {
        if (tabooAllergyTypeSet.contains("1") && tabooAllergyTypeSet.contains("2")) {
          tabooAllergyType = "3";
        } else if (tabooAllergyTypeSet.contains("1") && !tabooAllergyTypeSet.contains("2")) {
          tabooAllergyType = "1";
        } else if (!tabooAllergyTypeSet.contains("1") && tabooAllergyTypeSet.contains("2")) {
          tabooAllergyType = "2";
        }
      }
    }

    /* del by chamaojia 2026-01-16 [11072] マスタに関連する接頭語を削除する --start */
    // for (int i = 0; i < mixInfoJSONArray.length(); i++) {
    //   JSONObject mediObj = mixInfoJSONArray.getJSONObject(i);
    //   if (mediObj == null || mediObj.get("cd") == null) {
    //     continue;
    //   }
    //   Map<String,Object> mediMap = dBAppWebAPIDao.selectMedicineInfo(
    //           facilityCd,
    //           1,
    //           Integer.valueOf(mediObj.get("cd").toString()));
    //   if (mediMap != null) {
    //     Object useEndDateObj = getValueFromMap(mediMap, "use_end_date");
    //     String useEndDate = useEndDateObj == null ? null : useEndDateObj.toString();
    //     if (isDataExpired(useEndDate)) {
    //       isDataExpired = true;
    //     }
    //
    //     if (!isDataDeleted) {
    //       String isDispToSub = getValueFromMap(mediMap, "is_disp").toString();
    //       String isDelToSub = getValueFromMap(mediMap, "is_del").toString();
    //       if (isDataDeleted(isDispToSub, isDelToSub)) {
    //         isDataIncludeDeleted = true;
    //       }
    //     }
    //   } else {
    //     isDataIncludeDeleted = true;
    //   }
    // }
    /* del by chamaojia 2026-01-16 [11072] マスタに関連する接頭語を削除する --end */

    // 【禁忌・ｱﾚﾙｷﾞｰ】、【禁忌】、【ｱﾚﾙｷﾞｰ】prefix supplementation
    if (!ObjectUtils.isEmpty(tabooAllergyType)) {
      String tabooAllergyPrefix = "";
      if ("1".equals(tabooAllergyType)) {  // 禁忌
        tabooAllergyPrefix = CoreConstant.NamePrefixJapan.TABOO;
      } else if ("2".equals(tabooAllergyType)) {  // ｱﾚﾙｷﾞｰ
        tabooAllergyPrefix = CoreConstant.NamePrefixJapan.ALLERGY;
      } else if ("3".equals(tabooAllergyType)) {  // 禁忌・ｱﾚﾙｷﾞｰ
        tabooAllergyPrefix = CoreConstant.NamePrefixJapan.TABOO_AND_ALLERGY;
      }
      prefixName.append(tabooAllergyPrefix);
    }

    /* del by chamaojia 2026-01-16 [11072] マスタに関連する接頭語を削除する --start */
    // // 【期限切れ】prefix supplementation
    // if (isDataExpired) {
    //   prefixName.append(CoreConstant.NamePrefixJapan.EXPIRED);
    // }
    //
    // // 【削除済み】prefix supplementation
    // if (isDataDeleted) {
    //   prefixName.append(CoreConstant.NamePrefixJapan.DELETED);
    // } else {
    //   if (isDataIncludeDeleted) {
    //     prefixName.append(CoreConstant.NamePrefixJapan.INCLUDE_DELETED);
    //   }
    // }
    /* del by chamaojia 2026-01-16 [11072] マスタに関連する接頭語を削除する --end */

    return prefixName.toString();
  }

  /**
   * Mapからの値の取得処理
   * 値が取得できない場合(キーが存在しないなど)はnullを返却する
   * @param mapObj Mapオブジェクト
   * @param key  キー
   * @return 取得した値(キーが存在しない場合null)
   */
  private Object getValueFromMap(Map mapObj,String key)
  {
    Object ret = null ;

    try {
      //mapからキーを元に取得
      ret = mapObj.get(key) ;
    }
    catch(Exception e)
    {
      //例外が発生したので、戻り値をnullに設定
      ret = null ;
    }
    return ret ;
  }

  /**
   * Judgment of contraindications and allergies
   * @param patTabooAllergyInfo  禁忌・アレルギー情報(患者)
   * @param tabooAllergyList     禁忌・アレルギーマスタ
   * @param dataType             データ型
   *                                "1":普通薬剤 "2":調製薬剤 "3":医材 "4":ダイアライザ
   * @param cd                   薬剤コード/医療材料コード/ダイアライザコード
   * @return  "": 内容がありません  "1":禁忌  "2":ｱﾚﾙｷﾞｰ  "3":禁忌・ｱﾚﾙｷﾞｰ
   */
  private String getTabooAllergyType(String patTabooAllergyInfo, List<MstTabooAllergy> tabooAllergyList
          , String dataType, Integer cd) {
    if (ObjectUtils.isEmpty(patTabooAllergyInfo) || "[]".equals(patTabooAllergyInfo)) {
      return null;
    }

    try {
      List<PatInfoTabooAllergy> tabooAllergyInfoList = new ObjectMapper()
              .readValue(patTabooAllergyInfo, new TypeReference<ArrayList<PatInfoTabooAllergy>>() {});
      boolean tabooFlag = false;    // 禁忌存在フラグ
      boolean allergyFlag = false;  // アレルギ存在マーカー
      for (PatInfoTabooAllergy tabooAllergyInfo : tabooAllergyInfoList) {
        String tabooAllergyCd = tabooAllergyInfo.getTaboo_allergy_cd();
        Optional<MstTabooAllergy> mstTabooAllergy = tabooAllergyList.stream()
                .filter(a -> a.getTabooAllergyCd().equals(tabooAllergyCd)).findFirst();
        if (mstTabooAllergy.isPresent()) {
          List<MstTabooAllergyDetailInfo> tabooAllergyDetailInfoList = new ObjectMapper()
                  .readValue(mstTabooAllergy.get().getDetailInfo(), new TypeReference<ArrayList<MstTabooAllergyDetailInfo>>() {});
          int existsCount = tabooAllergyDetailInfoList.stream()
                  .filter(t -> dataType.equals(t.getClassCd()) && cd.toString().equals(t.getCd()))
                  .collect(Collectors.toList()).size();
          if (existsCount > 0) {
            if ("1".equals(tabooAllergyInfo.getTaboo_allergy_class())) {
              // 禁忌
              tabooFlag = true;
            } else if ("2".equals(tabooAllergyInfo.getTaboo_allergy_class())) {
              // アレルギー
              allergyFlag = true;
            }
          }
        }
      }

      if (tabooFlag && !allergyFlag) {
        // 禁忌
        return "1";
      } else if (!tabooFlag && allergyFlag) {
        // ｱﾚﾙｷﾞｰ
        return "2";
      } else if (tabooFlag && allergyFlag) {
        // 禁忌・ｱﾚﾙｷﾞｰ
        return "3";
      }
    } catch (JacksonException e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      logServiceCore.log(LogLevel.ERROR, eventLogMessage, "", null, LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
    }
    return "";
  }

  /**
   * Determine whether the data has expired
   * @param useEndDate     使用終了日（yyyyMMdd）
   * @return true: expired
   */
  private boolean isDataExpired(String useEndDate) {
    if (ObjectUtils.isEmpty(useEndDate) || useEndDate.length() != 8) {
      return false;
    }
    try{
      LocalDate endDate = LocalDate.parse(useEndDate, DateTimeFormatter.ofPattern("yyyyMMdd"));
      LocalDate currentDate = LocalDate.now();
      // expiration date before current date
      if (endDate.isBefore(currentDate)) {
        return true;
      }
    }catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      logServiceCore.log(LogLevel.ERROR, eventLogMessage, "", null, LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
    }

    return false;
  }

  /**
   * Determine if the data has been deleted
   * @param isDisp 表示フラグ
   * @param isDel  削除フラグ
   * @return  true: deleted
   */
  private boolean isDataDeleted(String isDisp, String isDel) {
    if (ObjectUtils.isEmpty(isDisp) || ObjectUtils.isEmpty(isDel)) {
      return true;
    }

    if ("0".equals(isDisp) || "1".equals(isDel)) {
      return true;
    }
    return false;
  }

}
/* add by shiyw 2024-09-13 [10659] 接頭文字対応 --end */
