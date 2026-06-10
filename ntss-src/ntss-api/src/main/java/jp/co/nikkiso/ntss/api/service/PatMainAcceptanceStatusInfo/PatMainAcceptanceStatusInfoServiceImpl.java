package jp.co.nikkiso.ntss.api.service.PatMainAcceptanceStatusInfo;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.TimeZone;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.google.common.base.Objects;

import jp.co.nikkiso.ntss.api.utils.ObjectMapperUtil;
import jp.co.nikkiso.ntss.api.service.LogService;
import jp.co.nikkiso.ntss.core.dao.PatMainDao;
import jp.co.nikkiso.ntss.core.entity.PatMain;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainForAcceptanceStatusInfo;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;

/**
 * pat_mainのacceptance_status_infoを更新するServiceインタフェース.
 */
@Service
public class PatMainAcceptanceStatusInfoServiceImpl implements PatMainAcceptanceStatusInfoService {

  @Autowired
  private LogService logService;

  @Autowired
  PatMainDao patMainDao;
  @Autowired
  OrdMainDao ordMainDao;

  /* del by chamaojia 2026-05-07 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
  // //add redmine bug#6484 劉 start
  // private static class MedicalCareInfo {
  //   public String facility_cd;            //施設コード
  //   public String ward_cd;                //病棟コード
  //   public String main_course_cd;         //診療科主科コード
  //   public String dialysis_course_cd;     //診療科透析実施科コード
  //   // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
  //   //public String dialysis_count;         //透析回数
  //   //public String pat_dialysis_count;     //自施設透析回数
  //   //public String other_dialysis_count;   //他施設透析回数
  //   //public String purification_count;     //浄化治療回数
  //   public Integer dialysis_count;         //透析回数
  //   public Integer pat_dialysis_count;     //自施設透析回数
  //   public Integer other_dialysis_count;   //他施設透析回数
  //   public Integer purification_count;     //浄化治療回数
  //   // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
  //   public String dialysis_start_date;    //透析導入日
  //   public String hospital_start_date;    //当院開始日
  // }
  // //add redmine bug#6484 劉 end
  /* del by chamaojia 2026-05-07 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */

  /**
   * 日付型情報をISO8601形式日付文字列に変換する
   * @param date    変換を行う日付
   * @return null：変換失敗/else：変換したISO8601形式日付文字列
   */
  private String DateToISO8601(Date date) {
    String ret = null;
    if( date != null ) {
      try {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSXXX");
        sdf.setTimeZone(TimeZone.getTimeZone("JST"));
        ret = sdf.format(date);
      } catch ( Exception ex ) {
      }
    }
    return ret;
  }

  /**
   * 数字文字列をIntegerに変換する
   * @param text    変換を行う文字列
   * @return null：変換失敗/else：変換値
   */
  private Integer StrToInteger( String text ) {
    //mod #11967 患者情報共通ヘッダーの治療進捗バーの表示が不正 zrx start
//    Integer ret = null;
//    try {
//      if( text != null && ! text.isEmpty() ) {
//        ret = Integer.parseInt(text);
//      }
//    } catch( Exception ex ) {
//    }
//    return ret;
    if (text == null || text.isEmpty()) {
      return null;
    }
    try {
      text = text.trim();
      if ((text.startsWith("\"") && text.endsWith("\"")) ||
        (text.startsWith("'") && text.endsWith("'"))) {
        text = text.substring(1, text.length() - 1);
      }

      return Integer.parseInt(text);
    } catch (NumberFormatException ex) {
      return null;
    }
    //mod #11967 患者情報共通ヘッダーの治療進捗バーの表示が不正 zrx end
  }

  /**
   * 治療進捗状況の更新
   * @param info            治療進捗状況
   * @param isDelete        削除フラグ
   * @param isUpdateDate    日付更新フラグ
   * @param patId           患者ID
   * @param ordNo           オーダー番号
   * @param dialysisState   治療状態[0～6]
   * @param startDateTime   治療開始日時
   * @param treatmentTime   治療時間
   * @return
   */
  private List<Map<String, Object>> rebuidAcceptanceStatusInfo(
      List<Map<String, Object>> info,
      boolean isDelete,
      boolean isUpdateDate,
      Long patId,
      Long ordNo,
      String dialysisState,
      Date startDateTime,
      String treatmentTime) {

    // 治療進捗状態を検索
    Map<String, Object> item = info.stream()
        .filter( i -> Objects.equal(i.get("ord_no").toString(), ordNo.toString()))
        .findFirst()
        .orElse(null);
    if( item != null ) {
      // オーダー番号あり

      // 治療状況削除判定
      if( isDelete ) {
        // 削除する場合

        // 治療状況を削除
        info.remove(item);
      } else {
        // 削除しない場合

        // 治療状況更新
        item.put("class", dialysisState);
      }
    } else {
      // オーダー番号なし

      // 治療状況削除判定
      if( !isDelete ) {
        // 削除しない場合

        // 治療状況を追加
        item = new HashMap<String, Object>();
        item.put("ord_no",      ordNo);
        item.put("class",       dialysisState);
        item.put("start_date_time", null);
        item.put("treatment_time",  null);
        info.add(item);
      }
    }

    // 削除なしで日付更新する場合
    if( !isDelete && isUpdateDate ) {
      // 治療開始日時と治療時間を更新
      item.put("start_date_time",   this.DateToISO8601(startDateTime));
      item.put("treatment_time",    this.StrToInteger(treatmentTime));
    }

    return info;
  }
  //del #9576 自施設通算透析回数と患者通算透析回数が運転開始時に増えている zhou start
  //add redmine bug#6484 劉 start
  /**
   * 共通診療情報の更新
   * @param ordNo           オーダー番号
   * @param info            治療進捗状況
   * @return
   */
//  private MedicalCareInfo rebuildMedicalCareInfo(Long ordNo, String info) {
//    ObjectMapper mapper = new ObjectMapper();
//    MedicalCareInfo medicalCareInfo = new MedicalCareInfo();
//    try {
//      if (!Strings.isNullOrEmpty(info)) {
//        medicalCareInfo = mapper.readValue(info, MedicalCareInfo.class);
//      }
//    } catch (IOException e) {
//      e.printStackTrace();
//    }
//
//    if (ordMainDao.checkSpecialPurification(ordNo)) {
//      //浄化治療回数の更新(特殊浄化の場合は更新します)
//      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
//      //Integer purificationCount = this.StrToInteger(medicalCareInfo.purification_count);
//      Integer purificationCount = medicalCareInfo.purification_count;
//      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
//      if (null != purificationCount) {
//        ++purificationCount;
//      } else {
//        purificationCount = 1;
//      }
//      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
//      //medicalCareInfo.purification_count = purificationCount.toString();
//      medicalCareInfo.purification_count = purificationCount;
//      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
//    } else {
//      //透析回数の更新
//      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
//      //Integer dialysisCount = this.StrToInteger(medicalCareInfo.dialysis_count);
//      Integer dialysisCount = medicalCareInfo.dialysis_count;
//      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
//      if (null != dialysisCount) {
//        ++dialysisCount;
//      } else {
//        dialysisCount = 1;
//      }
//      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
//      //medicalCareInfo.dialysis_count = dialysisCount.toString();
//      medicalCareInfo.dialysis_count = dialysisCount;
//      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
//
//      //自施設透析回数の更新
//      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
//      //Integer patDialysisCount = this.StrToInteger(medicalCareInfo.pat_dialysis_count);
//      Integer patDialysisCount = medicalCareInfo.pat_dialysis_count;
//      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
//      if (null != patDialysisCount) {
//        ++patDialysisCount;
//      } else {
//        patDialysisCount = 1;
//      }
//      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
//      //medicalCareInfo.pat_dialysis_count = patDialysisCount.toString();
//      medicalCareInfo.pat_dialysis_count = patDialysisCount;
//      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
//    }
//
//    return medicalCareInfo;
//  }
  //add redmine bug#6484 劉 end
  //del #9576 自施設通算透析回数と患者通算透析回数が運転開始時に増えている zhou end

  /**
   * 指定したパラメータでpat_mainのacceptance_status_infoを取得する
   *
   * @param patId           患者ID
   * @return JSONオブジェクト文字列
   */
  @Override
  public String get(Long patId) {
    String ret = "[]";
    EventLogMessage eventLogMessage = new EventLogMessage();
    try {
      // pat_mainを開く
      PatMain pat = patMainDao.selectById(patId);
      eventLogMessage.setFacilityCd(pat.getFacility_cd());

      eventLogMessage.setLogMessage("患者基本情報[pat_main]の治療進捗状態[acceptance_status_info]取得開始 patId:" + patId );
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);

      // 治療進捗状態を取得
      ret = pat.getAcceptance_status_info();
    } catch( Exception ex ) {
      eventLogMessage.setLogMessage("患者基本情報[pat_main]の治療進捗状態[acceptance_status_info]取得 patId:" + patId + " 取得失敗 " + ex.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    }
    eventLogMessage.setLogMessage("患者基本情報[pat_main]の治療進捗状態[acceptance_status_info]取得終了 patId:" + patId);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    return ret;
  }

  /**
   * 指定したパラメータでpat_mainのacceptance_status_infoを更新する
   *
   * @param patId           患者ID
   * @param ordNo           オーダー番号
   * @param dialysisState   治療状態[0～6]
   * @param startDateTime   治療開始日時
   * @param treatmentTime   治療時間
   * @return 1：更新成功 / 0：更新失敗
   */
  @Override
  public int update(Long patId, Long ordNo, String dialysisState, Date startDateTime, String treatmentTime) {
    int ret = 0;
    EventLogMessage eventLogMessage = new EventLogMessage();
    try {
      // pat_mainを開く
      PatMain pat = patMainDao.selectById(patId);
      eventLogMessage.setFacilityCd(pat.getFacility_cd());

      eventLogMessage.setLogMessage("患者基本情報[pat_main]の治療進捗状態[acceptance_status_info]更新開始 patId:" + patId + " / ordNo:" + ordNo + " / state:" + dialysisState);
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);

      // 治療状況判定
      boolean isDelete = false;
      boolean isUpdateDate = false;
      if( dialysisState.equals("0") || dialysisState.equals("6")){
        // 治療状況が「0：条件未送信」と「6：版確定」の場合

        // 治療状況を削除
        isDelete = true;

        eventLogMessage.setLogMessage("患者基本情報[pat_main]の治療進捗状態[acceptance_status_info]削除 patId:" + patId + " / ordNo:" + ordNo);
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      } else if (dialysisState.equals("3")){
        // 治療状況が「3：治療中」の場合

        // 治療状況の日付を更新
        isUpdateDate = true;
      }

      // 治療進捗状態を取得
      String info = pat.getAcceptance_status_info();
      List<Map<String, Object>> jsons = new ArrayList<Map<String, Object>>();
      try {
        jsons = ObjectMapperUtil.readListOfMap(info);
      } catch( Exception ex) {
        eventLogMessage.setLogMessage("患者基本情報[pat_main]の治療進捗状態[acceptance_status_info]更新 patId:" + patId + " 治療療進捗状態の取得失敗 " + ex.getMessage());
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      }

      // 治療進捗状態の更新
      jsons = this.rebuidAcceptanceStatusInfo( jsons, isDelete, isUpdateDate, patId, ordNo, dialysisState, startDateTime, treatmentTime);

      // 治療進捗状態の文字列→JSON変換
      info = ObjectMapperUtil.write(jsons);

      eventLogMessage.setLogMessage("患者基本情報[pat_main]の治療進捗状態[acceptance_status_info]更新 patId:" + patId + " / info:" + info);
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);

      ret = patMainDao.updateAcceptanceStatusInfoById(patId, info);
      //del #9576 自施設通算透析回数と患者通算透析回数が運転開始時に増えている zhou start
      //add redmine bug#6484 劉 start
//      if ("3".equals(dialysisState)) {
//        ObjectMapper mapper = new ObjectMapper();
//        MedicalCareInfo medicalCareInfo = this.rebuildMedicalCareInfo(ordNo, pat.getMedical_care_info());
//        ret = patMainDao.updateMedicalCareInfo(patId, mapper.writeValueAsString(medicalCareInfo));
//      }
      //add redmine bug#6484 劉 end
      //del #9576 自施設通算透析回数と患者通算透析回数が運転開始時に増えている zhou  end
    } catch( Exception ex ) {
      eventLogMessage.setLogMessage("患者基本情報[pat_main]の治療進捗状態[acceptance_status_info]更新 patId:" + patId + " 更新失敗 " + ex.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    }
    eventLogMessage.setLogMessage("患者基本情報[pat_main]の治療進捗状態[acceptance_status_info]更新終了 patId:" + patId);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    return ret;
  }

  /**
   * 指定した患者IDのpat_main.acceptance_status_infoを再構築する
   *
   * @param patId   患者ID
   * @return 再構築したJSONオブジェクト文字列
   */
  public String rebuild(Long patId) {
    String ret = "[]";
    EventLogMessage eventLogMessage = new EventLogMessage();
    try {
      // pat_mainを開く
      PatMain pat = patMainDao.selectById(patId);
      eventLogMessage.setFacilityCd(pat.getFacility_cd());

      eventLogMessage.setLogMessage("患者基本情報[pat_main]の治療進捗状態[acceptance_status_info]再構築開始 patId:" + patId );
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);

      // mod FNSI-改修内容 患者情報共通ヘッダー外結No4対応 趙 start
      // 指定患者で治療進捗状況用一覧情報を取得する
      // List<OrdMainForAcceptanceStatusInfo> ords = ordMainDao.selectByPatIdForUpdateAcceptanceStatusInfo(patId);
      SimpleDateFormat format = new SimpleDateFormat("yyyyMMdd");
      String sysDate = format.format(new Date());

      List<OrdMainForAcceptanceStatusInfo> ords = ordMainDao.selectByPatIdForUpdateAcceptanceStatusInfo(patId,sysDate);
      // mod FNSI-改修内容 患者情報共通ヘッダー外結No4対応 趙 end

      // 治療進捗状態を再構築
      List<Map<String, Object>> jsons = new ArrayList<Map<String, Object>>();
      for( OrdMainForAcceptanceStatusInfo ord: ords ) {

        // 治療進捗状態の更新
        jsons = this.rebuidAcceptanceStatusInfo( jsons, false, true, patId, ord.getOrdNo(), ord.getRstDialysisState(), ord.getRstStartDate(), ord.getTreatmentTime());
      };

      // 治療進捗状態の文字列→JSON変換
      String info = ObjectMapperUtil.write(jsons);

      eventLogMessage.setLogMessage("患者基本情報[pat_main]の治療進捗状態[acceptance_status_info]再構築 patId:" + patId + " / info:" + info);
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);

      if( 0 < patMainDao.updateAcceptanceStatusInfoById(patId, info) ) {
        ret = info;
      }
    } catch( Exception ex ) {
      eventLogMessage.setLogMessage("患者基本情報[pat_main]の治療進捗状態[acceptance_status_info]再構築 更新失敗 " + ex.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    }
    eventLogMessage.setLogMessage("患者基本情報[pat_main]の治療進捗状態[acceptance_status_info]再構築終了 patId:" + patId);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    return ret;
  }
}
