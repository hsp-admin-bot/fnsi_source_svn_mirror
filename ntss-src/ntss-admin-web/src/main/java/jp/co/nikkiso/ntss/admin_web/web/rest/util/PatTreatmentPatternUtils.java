package jp.co.nikkiso.ntss.admin_web.web.rest.util;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Treatment.DeviceMode;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.AsyncService;
import jp.co.nikkiso.ntss.admin_web.service.DeviceSetInfoService;
import jp.co.nikkiso.ntss.admin_web.service.SameCategoryFluidComponent;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.constant.TreatmentItemsDef;
import jp.co.nikkiso.ntss.core.dao.MstDialyzerDao;
import jp.co.nikkiso.ntss.core.dao.MstPersonalUserDao;
import jp.co.nikkiso.ntss.core.dao.MstTreatmentDao;
import jp.co.nikkiso.ntss.core.dao.PatExamPatternDao;
import jp.co.nikkiso.ntss.core.dao.PatMainDao;
import jp.co.nikkiso.ntss.core.dao.PatRadPatternDao;
import jp.co.nikkiso.ntss.core.dao.PatTreatmentPatternDao;
import jp.co.nikkiso.ntss.core.entity.MstDialyzer;
import jp.co.nikkiso.ntss.core.entity.MstTreatment;
import jp.co.nikkiso.ntss.core.entity.PatRadPattern;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.logevent.DataUpdateLogCommonNew;
import jp.co.nikkiso.ntss.core.logevent.LogServiceCore;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import jp.co.nikkiso.ntss.core.utils.IvCalAmountAndSpeedUtil;
import jp.co.nikkiso.ntss.core.utils.LiquidCalculateUtils;
import org.apache.commons.lang3.StringUtils;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.seasar.doma.jdbc.Config;
import org.seasar.doma.jdbc.SelectOptions;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.entity.PatTreatmentPattern;
import lombok.Getter;
import lombok.Setter;
import org.springframework.util.CollectionUtils;
import org.springframework.util.ObjectUtils;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.stream.Collectors;

import static jp.co.nikkiso.ntss.admin_web.service.SameCategoryFluidComponent.removeKey;
import jp.co.nikkiso.ntss.core.config.DefaultDb;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

/**
 * 患者治療パターンユーティリティクラス
 */
@Component
public class PatTreatmentPatternUtils {
  @Autowired
  PatTreatmentPatternDao patTreatmentPatternDao;

  @Autowired
  PatMainDao patMainDao;

  @Autowired
	LogService logService;

  // DB更新ログ出力ロジック wangzuo Start
  @Autowired
  private EventLoggerFactory eventLoggerFactory;

  @Autowired
  private LogServiceCore logServiceCore;
  // DB更新ログ出力ロジック wangzuo End
  //add 8008 日次処理のスケジュール自動延長がされない患者が存在する start zhao
  @Autowired
  private PatExamPatternDao patExamPatternDao;
  @Autowired
  private PatRadPatternDao patRadPatternDao;
  //add 8008 日次処理のスケジュール自動延長がされない患者が存在する end zhao

  @Autowired
  AsyncService asyncService;
  // add 9281 日次処理にて正しくスケジュールが作成されない事がある 関 start
  @Autowired
  private MstTreatmentDao mstTreatmentDao;

  @Autowired
  private MstDialyzerDao mstDialyzerDao;

  // add 9664 by kangjie 20240425 start
  @Autowired
  private SameCategoryFluidComponent sameCategoryFluidComponent;
  // add 9664 by kangjie 20240425 end

  /**
   * 利用者マスタ（個人情報DB）のDaoインタフェース
   */
  @Autowired
  private MstPersonalUserDao mstPersonalUserDao;

  @Autowired
  @DefaultDb
  private Config defaultDbConfig;
  // add 9281 日次処理にて正しくスケジュールが作成されない事がある 関 end

  //add 10810月跨ぎの日次処理によるスケジュール自動延長にて濾過率から算出が-1となる zhao start
  @Autowired
  DeviceSetInfoService deviceSetInfoService;
  //add 10810月跨ぎの日次処理によるスケジュール自動延長にて濾過率から算出が-1となる zhao end

  /** 指示項目 */
  public enum IND_ITEM
  {
      /** 治療方法 */
      TREATMENT,
      /** クール */
      KUR,
      /** スケジュール */
      SCHE,
      /** 治療条件 */
      COND,
      /** 投与薬剤 */
      MEDI,
      /** 医療材料 */
      EQUIP,
      /** 指示コメント */
      IND_COMMENT,
      /** 風体 */
      TARE,
      /** 除水 */
      OFF_WATER,
      /** 装置設定 */
      DEVICE_SET_INFO,
  }

  @Getter
  @Setter
  /**
   * 患者治療パターン編集データ
   */
  public static class PatTreatmentPatternEditData {
    /** 治療種別 */
    private Double treatType;
    /** 適用開始日 */
    private String indTreatStartDate;
    /** 指示:治療方法コード */
    private Integer indTreatmentCd;
    /** 指示:クールコード */
    private Long indKurCd;
    /** 治療曜日 */
    private Short treatWeek;
    /** 指示:スケジュール情報(Jsonデータ) */
    private String indSchInfo;
    /** 指示:治療条件情報(Jsonデータ) */
    private String indCondInfo;
    /** 指示:投与薬剤情報(Jsonデータ) */
    private String indMediInfo;
    /** 指示:医療材料情報(Jsonデータ) */
    private String indEquipInfo;
    /** 指示:指示コメント情報(Jsonデータ) */
    private String indIndCommentInfo;
    /** 指示:風体補正情報(Jsonデータ) */
    private String indTareInfo;
    /** 指示:除水補正情報(Jsonデータ) */
    private String indOffWaterInfo;
    /** 指示:装置設定情報(Jsonデータ) */
    private String indDeviceSetInfo;
    // add 9281 日次処理にて正しくスケジュールが作成されない事がある 関 start
    /** 装置モード */
    private Integer deviceMode;
    /** 指示者ID */
    private Long indUserId;
    // add 9281 日次処理にて正しくスケジュールが作成されない事がある 関 end
    // add 10744 医療材料の穴埋め追加によるpat_treatment_patternへの追加処理が不正 関 start
    /** 医療材料 追加方式 */
    private String autoInsert;
    // add 10744 医療材料の穴埋め追加によるpat_treatment_patternへの追加処理が不正 関 end
  }

  @Getter
  @Setter
  /**
   * 患者治療パターン編集データリスト
   */
  public static class PatTreatmentPatternEditDataWeekList {
    private List<Integer> weekPattern;
    private PatTreatmentPatternEditData editData;
  }

  /**
   * 患者治療パターン検索
   * @param patId 抽出データ（処理対象患者の患者ID）
   * @param facilityCd 抽出データ（処理対象施設の施設コード）
   * @param indTreatmentCdList 抽出データ（処理対象治療予定の指示：治療方法コード）  ※全治療方法指定の場合はnull設定
   * @param indKurCdList 抽出データ（処理対象治療予定の指示：クールコード） ※全クール指定の場合はnull設定
   * @param weekPatternList 抽出データ（処理対象治療予定の曜日パターン:処理を実施する曜日番号リスト）  ※全曜日指定の場合はnull設定
   * @return 正常終了:検索条件にヒットした患者治療パターン、異常終了:null
   */
  public List<PatTreatmentPattern> searchPatTreatmentPattern(
      Long patId,
      String facilityCd,
      List<Integer> indTreatmentCdList,
      List<Long> indKurCdList,
      List<Integer> weekPatternList
    ) {
    List<PatTreatmentPattern> searchData = null;
    if (null == indTreatmentCdList) indTreatmentCdList = new ArrayList<Integer>();
    if (null == indKurCdList) indKurCdList = new ArrayList<Long>();
    if (null == weekPatternList) weekPatternList = new ArrayList<Integer>();
    try {
      // 該当患者治療パターン検索
      searchData = patTreatmentPatternDao.selectBySearchInfo(patId, facilityCd, indTreatmentCdList, indKurCdList, weekPatternList);
    } catch(Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("患者治療パターン検索処理に失敗しました:" + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
    }

    return searchData;
  }

  /**
   * 患者治療パターン治療予定中止
   * @param patId 抽出データ（処理対象患者の患者ID）
   * @param facilityCd 抽出データ（処理対象施設の施設コード）
   * @param indTreatmentCdList 抽出データ（処理対象治療予定の指示：治療方法コード）  ※全治療方法指定の場合はnull設定
   * @param indKurCdList 抽出データ（処理対象治療予定の指示：クールコード） ※全クール指定の場合はnull設定
   * @param weekPatternList 抽出データ（処理対象治療予定の曜日パターン:処理を実施する曜日番号リスト）  ※全曜日指定の場合はnull設定
   * @return 処理件数(失敗時は「-1」)
   */
  @Transactional
  public int deletePatTreatmentPatternForTreatPlan(
      Long patId,
      String facilityCd,
      List<Integer> indTreatmentCdList,
      List<Long> indKurCdList,
      List<Integer> weekPatternList
    ) {
    int updateCount = -1;
    if (null == indTreatmentCdList) indTreatmentCdList = new ArrayList<Integer>();
    if (null == indKurCdList) indKurCdList = new ArrayList<Long>();
    if (null == weekPatternList) weekPatternList = new ArrayList<Integer>();
    try {
      // 該当患者治療パターン削除(抽出条件(治療方法、クール)に該当するレコードを削除)
      updateCount = patTreatmentPatternDao.deleteBySearchInfo(patId, null, facilityCd, indTreatmentCdList, indKurCdList, weekPatternList);

      // 治療パターンが全部なくなった場合、該当患者のスケジュール延長最終日をNULLにする
      Long recordCount = patTreatmentPatternDao.selectCountByPatId(patId);
      if (0 == recordCount) {

        // DB更新ログ出力ロジック wangzuo Start
        String tableName = "pat_main";
        // SQL検索条件
        StringBuffer wheres = new StringBuffer("");
        wheres.append(" WHERE\n");
        wheres.append(" pat_id = " + patId + "\n");
        // logCommon設定
        DataUpdateLogCommonNew logCommon = getLogCommon(tableName, wheres, getEventLogMessage());
        // ログ出力カラム情報及び更新前データ情報取得
        boolean setResult = logCommon.setInfo();
        // DB更新ログ出力ロジック wangzuo End


        //mod 8008 日次処理のスケジュール自動延長がされない患者が存在する start zhao
        //int updateCountMain = patMainDao.updateSchExtEndDate(patId, null);
        int examCount = patExamPatternDao.selectPatExamPatternByPatId(patId);
        List<PatRadPattern> patRadPatternList = patRadPatternDao.selectPatRadPatternByPatId(patId);
        int updateCountMain=0;
        if(examCount<=0||patRadPatternList.size()<=0){
          updateCountMain = patMainDao.updateSchExtEndDate(patId, null);
        }
        //mod 8008 日次処理のスケジュール自動延長がされない患者が存在する end zhao
        // DB更新ログ出力ロジック wangzuo Start
        // 更新後データ取得、差分あれば、log出力
        //mod 8008 日次処理のスケジュール自動延長がされない患者が存在する start zhao
        //if (setResult && updateCountMain > 0) {
          //logCommon.updateLog();
        //}
        if (setResult && updateCountMain >= 0) {
          /* modify by chamaojia 2023-03-09 sqlを同期実行し、非同期差分保存ログ  --start */
          logCommon.setAfterResults();
          /* modify by shiyw 2023-03-07 [#8101] --start */
//          logCommon.updateLog();
          asyncService.updateLog(logCommon);
          /* modify by shiyw 2023-03-07 [#8101] --end */
          /* modify by chamaojia 2023-03-09 sqlを同期実行し、非同期差分保存ログ  --end */
        }
        // DB更新ログ出力ロジック wangzuo End
        //mod 8008 日次処理のスケジュール自動延長がされない患者が存在する end zhao
      }
    } catch(Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("患者治療パターン治療予定中止処理に失敗しました:" + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      // ロールバック実行
      throw new RuntimeException();
    }

    return updateCount;
  }

  /**
   * スケジュール情報作成
   * @param indBedCd 指示:ベッドコード
   * @param indTreatStartTime 指示:治療開始時刻
   * @param indUserId 指示者ID
   * @param updUserId 更新者ID
   * @return 患者治療パターン編集データ(JSON形式(String))(失敗時は「null」)
   */
  public String createIndSchInfo(
      Long indBedCd,
      String indTreatStartTime,
      Long indUserId,
      Long updUserId
    ) {
    JSONObject indSchInfo = new JSONObject();
    try {
      indSchInfo.put("ind_bed_cd", (null == indBedCd) ? JSONObject.NULL : indBedCd.toString());
      indSchInfo.put("ind_treat_start_time", (null == indTreatStartTime) ? JSONObject.NULL : indTreatStartTime);
      //  外部結合テスト 患者経過総合ビューアNo95 姜 start
      indSchInfo.put("ind_user_id", (null == indUserId) ? JSONObject.NULL : indUserId);
      indSchInfo.put("upd_user_id", (null == updUserId) ? JSONObject.NULL : updUserId);
      //  外部結合テスト 患者経過総合ビューアNo95 姜 start
    } catch (JSONException e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("スケジュール情報作成処理に失敗しました:" + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      return null;
    }

    return indSchInfo.toString();
  }

  //add 10860 ind_schedule_user_infoのデータ不正 zhao start
  public String createPatternIndSchInfo(
    Long indBedCd,
    String indTreatStartTime,
    Long indUserId,
    MstPersonalUser user,
    Long updUserId,
    MstPersonalUser updUser,
    Long indKurCd
  ) {
    JSONObject indSchInfo = new JSONObject();
    try {
      indSchInfo.put("ind_bed_cd", (null == indBedCd) ? 0 : indBedCd);
      indSchInfo.put("ind_treat_start_time", (null == indTreatStartTime) ? JSONObject.NULL : indTreatStartTime);
      indSchInfo.put("ind_treat_start_time_before", JSONObject.NULL);
      indSchInfo.put("ind_kur_cd_before", JSONObject.NULL);
      indSchInfo.put("ind_user_id", (null == indUserId) ? JSONObject.NULL : indUserId);
      indSchInfo.put("ind_user_first_name", (null == user.getUserFirstName()) ? JSONObject.NULL : user.getUserFirstName());
      indSchInfo.put("ind_user_last_name", (null == user.getUserLastName()) ? JSONObject.NULL : user.getUserLastName());
      indSchInfo.put("upd_user_id", (null == updUserId) ? JSONObject.NULL : updUserId);
      indSchInfo.put("upd_user_first_name", (null == updUser.getUserFirstName()) ? JSONObject.NULL : updUser.getUserFirstName());
      indSchInfo.put("upd_user_last_name", (null == updUser.getUserLastName()) ? JSONObject.NULL : updUser.getUserLastName());
    } catch (JSONException e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("スケジュール情報作成処理に失敗しました:" + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      return null;
    }

    return indSchInfo.toString();
  }
  //add 10860 ind_schedule_user_infoのデータ不正 zhao end

  /**
   * 患者治療パターン治療予定登録
   * @param patId 抽出データ（処理対象患者の患者ID）
   * @param facilityCd 抽出データ（処理対象施設の施設コード）
   * @param weekPatternList 抽出データ（処理対象治療予定の曜日パターン:処理を実施する曜日番号リスト）  ※全曜日指定の場合はnull設定
   * @param upDate 更新日時
   * @param editData 患者治療パターン編集データ
   * @return 処理件数(失敗時は「-1」)
   */
  @Transactional
  public int createPatTreatmentPatternForTreatPlan(
      Long patId,
      String facilityCd,
      List<Integer> weekPatternList,
      Timestamp upDate,
      PatTreatmentPatternEditData editData
    ) {
    int updateCount = -1;
    try {
      List<Integer> localIndTreatmentCd = Arrays.asList(editData.getIndTreatmentCd());
      List<Long> localIndKurCd = Arrays.asList(editData.getIndKurCd());
      // 変更対象の患者治療パターン検索
      List<PatTreatmentPattern> beforeData = this.searchPatTreatmentPattern(patId, facilityCd, localIndTreatmentCd, localIndKurCd, weekPatternList);
      // 患者治療パターン登録
      if (null == weekPatternList) weekPatternList = Arrays.asList(1, 2, 3, 4, 5, 6, 7);
      for (int k = 0; k < weekPatternList.size(); k++) {
        Integer week = weekPatternList.get(k);
        // 登録条件(治療方法、クール、曜日)に該当するデータが存在しているかチェック
        List<PatTreatmentPattern> registData = beforeData.stream().filter(info ->
                                    info.getIndTreatmentCd().equals(editData.getIndTreatmentCd()) &&
                                    info.getIndKurCd().equals(editData.getIndKurCd()) &&
                                    (int)info.getTreatWeek() == week
                                  ).collect(Collectors.toList());
        if (0 == registData.size()) {
          // 患者治療パターン新規登録
          updateCount = patTreatmentPatternDao.insert(this.createData(patId, null, facilityCd, week, upDate, editData));
        } else if (1 == registData.size()) {
          // 患者治療パターン更新
          // 該当患者治療パターン削除(該当レコード(管理番号)を指定して削除)
          updateCount = patTreatmentPatternDao.deleteBySearchInfo(patId, registData.get(0).getCtlNo(), facilityCd, new ArrayList<Integer>(), new ArrayList<Long>(), new ArrayList<Integer>());
          // 患者治療パターン新規登録
          updateCount = patTreatmentPatternDao.insert(this.createData(patId, registData.get(0).getCtlNo(), facilityCd, week, upDate, editData));
        } else {
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage("患者治療パターンの登録データに異常があるため処理をスキップしました:"
          + "[抽出条件:"
          + "患者ID=" + patId
          + "、施設コード=" + facilityCd
          + "、治療方法コード=" + editData.getIndTreatmentCd()
          + "、クールコード=" + editData.getIndKurCd()
          + "、曜日番号=" + week
          + "]、"
          + "[抽出件数:" + registData.size()
          + "]");
          logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
        }
      }
    } catch(Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("患者治療パターン治療予定登録処理に失敗しました:" + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      // ロールバック実行
      throw new RuntimeException();
    }

    return updateCount;
  }

  /**
   * 登録データ作成
   * @param patId 抽出データ（処理対象患者の患者ID）
   * @param ctlNo 管理番号
   * @param facilityCd 抽出データ（処理対象施設の施設コード）
   * @param weekPattern 抽出データ（処理対象治療予定の曜日パターン:登録処理を実施する曜日番号リスト）
   * @param upDate 更新日時
   * @param editData 患者治療パターン編集データ
   * @return 登録データ
   */
  private PatTreatmentPattern createData(
    Long patId,
    Long ctlNo,
    String facilityCd,
    Integer treatWeek,
    Timestamp upDate,
    PatTreatmentPatternEditData editData
  ) {
    // 管理番号発番
    if (null == ctlNo) {
      ctlNo = patTreatmentPatternDao.selectNextCtlNoById(patId);
    }

    // 登録データ作成
    PatTreatmentPattern insertData = new PatTreatmentPattern();
    insertData.setPatId(patId);
    insertData.setCtlNo(ctlNo);
    insertData.setFacilityCd(facilityCd);
    insertData.setTreatType(editData.getTreatType());
    insertData.setIndTreatStartDate(editData.getIndTreatStartDate());
    insertData.setTreatWeek(treatWeek.shortValue());
    insertData.setIndTreatmentCd(editData.getIndTreatmentCd());
    insertData.setIndKurCd(editData.getIndKurCd());
    insertData.setIndSchInfo(editData.getIndSchInfo());
    insertData.setIndCondInfo(editData.getIndCondInfo());
    insertData.setIndMediInfo(editData.getIndMediInfo());
    insertData.setIndEquipInfo(editData.getIndEquipInfo());
    insertData.setIndIndCommentInfo(editData.getIndIndCommentInfo());
    insertData.setIndTareInfo(editData.getIndTareInfo());
    insertData.setIndOffWaterInfo(editData.getIndOffWaterInfo());
    insertData.setIndDeviceSetInfo(editData.getIndDeviceSetInfo());
    insertData.setRegDate(upDate);
    insertData.setUpDate(upDate);

    return insertData;
  }

  /**
   * 患者治療パターン再作成
   * @param patId 抽出データ（処理対象患者の患者ID）
   * @param facilityCd 抽出データ（処理対象施設の施設コード）
   * @param indTreatmentCdList 抽出データ（処理対象治療予定の指示：治療方法コード）  ※全治療方法指定の場合はnull設定
   * @param indKurCdList 抽出データ（処理対象治療予定の指示：クールコード） ※全クール指定の場合はnull設定
   * @param weekPatternList 抽出データ（処理対象治療予定の曜日パターン:処理を実施する曜日番号リスト）  ※全曜日指定の場合はnull設定
   * @param upDate 更新日時
   * @param editDataList 曜日単位の編集データ
   * @return 処理件数(失敗時は「-1」)
   */
  @Transactional
  public int deleteAndCreatePatTreatmentPattern(
      Long patId,
      String facilityCd,
      List<Integer> indTreatmentCdList,
      List<Long> indKurCdList,
      List<Integer> weekPatternList,
      Timestamp upDate,
      List<PatTreatmentPatternEditDataWeekList> editDataWeekList
    ) {
    int updateCount = -1;
    if (null == indTreatmentCdList) indTreatmentCdList = new ArrayList<Integer>();
    if (null == indKurCdList) indKurCdList = new ArrayList<Long>();
    if (null == weekPatternList) weekPatternList = new ArrayList<Integer>();
    try {
      // add #11243 曜日パターン変更でpat_main.sch_ext_end_dateがnullになり、スケジュール延長がされない。 zkm start
      // 該当患者治療パターン削除する前に、患者基本情報.スケジュール延長最終日を検索する
      String oldSchExtEndDate = patMainDao.selectSchextenddate(patId);
      boolean isCreateFlg = false;
      // add #11243 曜日パターン変更でpat_main.sch_ext_end_dateがnullになり、スケジュール延長がされない。 zkm end
      // 該当患者治療パターン削除(抽出条件を指定して削除)
      updateCount = this.deletePatTreatmentPatternForTreatPlan(patId, facilityCd, indTreatmentCdList, indKurCdList, weekPatternList);
      // 患者治療パターン新規登録
      for (int i = 0; i < editDataWeekList.size(); i++) {
        // 曜日リストは、月曜から順にソートされているものとする
        List<Integer> insWeekPattern = editDataWeekList.get(i).getWeekPattern();
        PatTreatmentPatternEditData editData = editDataWeekList.get(i).getEditData();
        // 1件目を通常登録(移動先曜日が複数ある場合、月曜日に近い方に投与間隔が 1：毎週～10：1回／月：最終治療日のデータを引き継ぐ)
        if (insWeekPattern.size() > 0) {
          List<Integer> firstWeekPattern = new ArrayList<Integer>();
          firstWeekPattern.add(insWeekPattern.get(0));
          updateCount = this.createPatTreatmentPatternForTreatPlan(patId, facilityCd, firstWeekPattern, upDate, editData);
          // add #11243 曜日パターン変更でpat_main.sch_ext_end_dateがnullになり、スケジュール延長がされない。 zkm start
          isCreateFlg = true;
          // add #11243 曜日パターン変更でpat_main.sch_ext_end_dateがnullになり、スケジュール延長がされない。 zkm end
        }
        // 2件目以降を投与間隔が 0：毎回 以外の薬剤が増殖しないように削除してから登録
        if (insWeekPattern.size() > 1) {
          List<Integer> secondWeekPattern = new ArrayList<Integer>();
          // 2件目以降の移動先曜日を取得
          for (int n = 1; insWeekPattern.size() > n; n++ ) {
            secondWeekPattern.add(insWeekPattern.get(n));
          }
          JSONArray editMediJson = new JSONArray(editData.getIndMediInfo());
          // 投与間隔が 0:毎回 以外の場合は削除する
          JSONArray tmpMediObj = new JSONArray();
          editMediJson.forEach(medi -> {
            JSONObject mediObj = (JSONObject)medi;
            // 投与間隔(date_interval)を取得
            if (mediObj.getInt("date_interval") == 0) {
              tmpMediObj.put(mediObj);
            }
          });
          editData.setIndMediInfo(tmpMediObj.toString());
          updateCount += this.createPatTreatmentPatternForTreatPlan(patId, facilityCd, secondWeekPattern, upDate, editData);
        }
      }
      // add #11243 曜日パターン変更でpat_main.sch_ext_end_dateがnullになり、スケジュール延長がされない。 zkm start
      // 最終日が未指定の場合にスケジュール延長最終日を更新
      if (isCreateFlg && StringUtils.isNotEmpty(oldSchExtEndDate)) {
        patMainDao.updateSchExtEndDate(patId, oldSchExtEndDate);
      }
      // add #11243 曜日パターン変更でpat_main.sch_ext_end_dateがnullになり、スケジュール延長がされない。 zkm end
    } catch(Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("患者治療パターン再作成処理に失敗しました:" + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      // ロールバック実行
      throw new RuntimeException();
    }

    return updateCount;
  }

  /**
   * 患者治療パターン項目更新
   * @param patId 抽出データ（処理対象患者の患者ID）
   * @param facilityCd 抽出データ（処理対象施設の施設コード）
   * @param indTreatmentCdList 抽出データ（処理対象治療予定の指示：治療方法コード）  ※全治療方法指定の場合はnull設定
   * @param indKurCdList 抽出データ（処理対象治療予定の指示：クールコード） ※全クール指定の場合はnull設定
   * @param weekPatternList 抽出データ（処理対象治療予定の曜日パターン:処理を実施する曜日番号リスト）  ※全曜日指定の場合はnull設定
   * @param updateIndItemList 更新対象指示項目リスト
   * @param upDate 更新日時
   * @param editData 編集データ ※更新したいデータ(画面単位のデータ)のみを設定
   * @return 処理件数(失敗時は「-1」)
   */
  @Transactional
  public int updatePatTreatmentPatternIndItem(
    Long patId,
    String facilityCd,
    List<Integer> indTreatmentCdList,
    List<Long> indKurCdList,
    List<Integer> weekPatternList,
    List<IND_ITEM> updateIndItemList,
    Timestamp upDate,
    PatTreatmentPatternEditData editData,
    // add 10150_9664 by kangjie 20240628 start
    List<OrdMain> ordMain, List<MstTreatment> mstTreatList,
    String ind_treat_cond_iv_mode
    // add 10150_9664 by kangjie 20240628 end
    ) {
    int updateCount = -1;
    //upd by ztc 2023-02-23 [Optimize runtime No.5482] --start /
//    if (null == indTreatmentCdList) indTreatmentCdList = new ArrayList<Integer>();
//    if (null == indKurCdList) indKurCdList = new ArrayList<Long>();
//    if (null == weekPatternList) weekPatternList = new ArrayList<Integer>();
    //upd by ztc 2023-02-23 [Optimize runtime No.5482] --end /
    try {
      // 変更対象の患者治療パターン検索
      List<PatTreatmentPattern> beforeData = this.searchPatTreatmentPattern(patId, facilityCd, indTreatmentCdList, indKurCdList, weekPatternList);
      indTreatmentCdList = beforeData.stream().map(item -> item.getIndTreatmentCd()).distinct().collect(Collectors.toList());
      indKurCdList = beforeData.stream().map(item -> item.getIndKurCd()).distinct().collect(Collectors.toList());
      weekPatternList = beforeData.stream().map(item -> item.getTreatWeek().intValue()).distinct().collect(Collectors.toList());
      //upd by ztc 2023-02-23 [Optimize runtime No.5482] --start /
      List<PatTreatmentPattern> updateDataList = new LinkedList<>();
      //upd by ztc 2023-02-23 [Optimize runtime No.5482] --end /
      // mod 10495 無期限治療条件変更時のpat_treatment_patternの更新バグ 関 start
      List<String> treatmentCdList = indTreatmentCdList.stream()
        .map(Object::toString)
        .collect(Collectors.toList());
      List<MstTreatment> selectedTreat = mstTreatmentDao.selectByCdList(treatmentCdList, facilityCd);
      // mod 10495 無期限治療条件変更時のpat_treatment_patternの更新バグ 関 end
      // add 10150 治療条件変更時のonline、offline補液関連 関  start
      String deviceSetInfoPat = deviceSetInfoService.getDeviceSetInfoPat(Long.valueOf(patId));
      JSONObject deviceSetInfoObject = (deviceSetInfoPat == null || deviceSetInfoPat.isEmpty()) ?
        new JSONObject() :
        new JSONObject(deviceSetInfoPat);
      // add 10150 治療条件変更時のonline、offline補液関連 関  end

      // 患者治療パターン更新
      for (int i = 0; i < indTreatmentCdList.size(); i++) {
        for (int j = 0; j < indKurCdList.size(); j++) {
          for (int k = 0; k < weekPatternList.size(); k++) {
            // 発行条件の治療方法、クール、曜日から更新元データを抽出
            Integer searchTreatmentCd = indTreatmentCdList.get(i);
            Long searchIndKurCd = indKurCdList.get(j);
            Integer searchWeek = weekPatternList.get(k);
            List<PatTreatmentPattern> registData = beforeData.stream().filter(info ->
                                        searchTreatmentCd.equals(info.getIndTreatmentCd()) &&
                                        searchIndKurCd.equals(info.getIndKurCd()) &&
                                        searchWeek.equals((int)info.getTreatWeek())
                                      ).collect(Collectors.toList());
            if (1 == registData.size()) {
              // 更新データ作成
              PatTreatmentPattern updateData = new PatTreatmentPattern();
              String errStr = null;
              //if (null != editData.getFacilityCd()) updateData.setFacilityCd(editData.getFacilityCd());
              //if (null != editData.getTreatType()) updateData.setTreatType(editData.getTreatType());
              //if (null != editData.getIndTreatStartDate()) updateData.setIndTreatStartDate(editData.getIndTreatStartDate());
              //if (null != editData.getTreatWeek()) updateData.setTreatWeek(editData.getTreatWeek());
              updateData.setUpDate(upDate);
              for (int l = 0; l < updateIndItemList.size(); l++) {
                IND_ITEM updateIndItem = updateIndItemList.get(l);
                switch (updateIndItem) {
                  case TREATMENT:
                    if (null != editData.getIndTreatmentCd()) {
                      updateData.setIndTreatmentCd(editData.getIndTreatmentCd());
                    } else {
                      errStr = "治療方法=null";
                    }
                    break;
                  case KUR:
                    if (null != editData.getIndKurCd()) {
                      updateData.setIndKurCd(editData.getIndKurCd());
                    } else {
                      errStr = "クール=null";
                    }
                    break;
                  case SCHE:
                    if (null != editData.getIndSchInfo()) {
                      //add 10860 ind_schedule_user_infoのデータ不正 zhao start
                      JSONObject indSchInfoJSONObjectBefore = new JSONObject(registData.get(0).getIndSchInfo());
                      JSONObject indSchInfoJSONObjectAfter = new JSONObject(editData.getIndSchInfo());
                      indSchInfoJSONObjectAfter.put("ind_kur_cd_before",registData.get(0).getIndKurCd());
                      indSchInfoJSONObjectAfter.put("ind_treat_start_time_before",indSchInfoJSONObjectBefore.get("ind_treat_start_time"));
                      editData.setIndSchInfo(indSchInfoJSONObjectAfter.toString());
                      //add 10860 ind_schedule_user_infoのデータ不正 zhao end
                      updateData.setIndSchInfo(editData.getIndSchInfo());
                    } else {
                      errStr = "スケジュール=null";
                    }
                    break;
                  case COND:
                    if (null != editData.getIndCondInfo()) {
                      // mod 10495 無期限治療条件変更時のpat_treatment_patternの更新バグ 関 start
                      // updateData.setIndCondInfo(editData.getIndCondInfo());
                      if (!registData.get(0).getIndCondInfo().isEmpty() && registData.get(0).getIndCondInfo().length() >0) {

                        List<MstTreatment> treatSetting =  selectedTreat.stream()
                          .filter(item -> item.getTreatmentCd().equals(registData.get(0).getIndTreatmentCd()))
                          .collect(Collectors.toList());

                        Integer deviceMode = null == treatSetting.get(0).getDeviceMode() ? null : treatSetting.get(0).getDeviceMode();

                        JSONObject indCondInfo = new JSONObject(editData.getIndCondInfo());

                        JSONObject beforeIndCondInfo = new JSONObject(registData.get(0).getIndCondInfo());

                        // add 10150 治療条件変更時のonline、offline補液関連 関  start
                        JSONObject indDeviceSetInfo = new JSONObject(registData.get(0).getIndDeviceSetInfo());
                        // add 10150 治療条件変更時のonline、offline補液関連 関  end

                        if (DeviceMode.AFBF.equals(deviceMode) || DeviceMode.I_HDF.equals(deviceMode)) {
                          indCondInfo.remove("11");
                          indCondInfo.remove("12");
                        } else if (beforeIndCondInfo.has("12")) {
                          if (indCondInfo.has("12") && !indCondInfo.getJSONObject("12").isNull("value")) {
                            String needleSelectionVal = String.valueOf(
                              indCondInfo.getJSONObject(TreatmentItemsDef.T_I_NEEDLE_SELECTION.getItemCode()).get("value")
                            );
                            if (StringUtils.equals("1", needleSelectionVal)) {
                              if (beforeIndCondInfo.has(TreatmentItemsDef.T_I_NEEDLE_A.getItemCode())) {
                                beforeIndCondInfo.remove(TreatmentItemsDef.T_I_NEEDLE_A.getItemCode());
                              }
                              if (beforeIndCondInfo.has(TreatmentItemsDef.T_I_NEEDLE_V.getItemCode())) {
                                beforeIndCondInfo.remove(TreatmentItemsDef.T_I_NEEDLE_V.getItemCode());
                              }
                              if (indCondInfo.has("11")) {
                                beforeIndCondInfo.put("11", indCondInfo.getJSONObject("11"));
                              }
                            } else if (StringUtils.equals("0", needleSelectionVal)) {
                              if (beforeIndCondInfo.has(TreatmentItemsDef.T_I_NEEDLE_SN.getItemCode())) {
                                beforeIndCondInfo.remove(TreatmentItemsDef.T_I_NEEDLE_SN.getItemCode());
                              }
                              if (indCondInfo.has("9")) {
                                beforeIndCondInfo.put("9", indCondInfo.getJSONObject("9"));
                              }
                              if (indCondInfo.has("10")) {
                                beforeIndCondInfo.put("10", indCondInfo.getJSONObject("10"));
                              }
                            }
                          } else if (!indCondInfo.has("12") && indCondInfo.has("11")) {
                            beforeIndCondInfo.remove("9");
                            beforeIndCondInfo.remove("10");
                            beforeIndCondInfo.put("11", indCondInfo.getJSONObject("11"));
                          } else if (!indCondInfo.has("12") && (indCondInfo.has("9") || indCondInfo.has("10") )) {
                            beforeIndCondInfo.remove("11");
                            if (indCondInfo.has("9")) {
                              beforeIndCondInfo.put("9", indCondInfo.getJSONObject("9"));
                            }
                            if (indCondInfo.has("10")) {
                              beforeIndCondInfo.put("10", indCondInfo.getJSONObject("10"));
                            }
                          }
                        }
                        // mod 10150 治療条件変更時のonline、offline補液関連 関  start
                        boolean onLineFlag;
                        if (DeviceMode.OHDF.equals(deviceMode) || DeviceMode.OHF.equals(deviceMode)
                          || DeviceMode.I_HDF.equals(deviceMode)) {
                          onLineFlag = true;
                        }else{
                          onLineFlag = false;
                        }
                        for (String key : beforeIndCondInfo.keySet()) {
                          if (indCondInfo.has(key)) {
                            // key 20とkey 24をスキップ
                            if ("20".equals(key) || "24".equals(key)) {
                              continue;
                            }
                            // key21 key22 key23 online offlineそれぞれ更新
                            if ("21".equals(key) || "22".equals(key) || "23".equals(key)) {
                              if ("onLine".equals(ind_treat_cond_iv_mode) && onLineFlag) {
                                beforeIndCondInfo.put(key, indCondInfo.get(key));
                              }else if ("offLine".equals(ind_treat_cond_iv_mode) && !onLineFlag) {
                                beforeIndCondInfo.put(key, indCondInfo.get(key));
                              }
                              // onlineの時はkey 19を更新しない
                            }else if(!("19".equals(key) && onLineFlag)){
                              beforeIndCondInfo.put(key, indCondInfo.get(key));
                            }
                          }
                        }

                        // onlineの時にkey 15をkey 19に割り当てる
                        if (onLineFlag) {
                          if (indCondInfo.has("15")) {
                            beforeIndCondInfo.put("19", indCondInfo.getJSONObject("15"));
                          }
                        }
                        //add 10810月跨ぎの日次処理によるスケジュール自動延長にて濾過率から算出が-1となる zhao start
                        //OHFまたはOHDF自動計算key 20とkey 24
                        String treatTimeStr = indCondInfo.has("1") && !indCondInfo.isNull("1") &&
                          !JSONObject.NULL.equals(indCondInfo.getJSONObject("1").get("value")) ?
                          indCondInfo.getJSONObject("1").get("value").toString() : beforeIndCondInfo.has("1") && !beforeIndCondInfo.isNull("1") &&
                          !JSONObject.NULL.equals(beforeIndCondInfo.getJSONObject("1").get("value")) ?
                          beforeIndCondInfo.getJSONObject("1").get("value").toString(): null;

                        JSONObject indCondInfoCopy = new JSONObject(editData.getIndCondInfo());

                        if (DeviceMode.OHDF.equals(deviceMode) ||
                          DeviceMode.OHF.equals(deviceMode)) {
                          if (indCondInfo.has("1") || indCondInfo.has("14") || indCondInfo.has("19")
                            || indCondInfo.has("20") || indCondInfo.has("21") || indCondInfo.has("22")
                            || indCondInfo.has("23") || indCondInfo.has("24")) {

                            String liquidCalPriority = deviceSetInfoObject.getJSONObject("ope").getJSONObject("dev")
                              .getJSONObject("A").get("389").toString();

                            if (!indCondInfo.has("14") && beforeIndCondInfo.has("14")) {
                              indCondInfo.put("14", beforeIndCondInfo.getJSONObject("14"));
                            }
                            if (!indCondInfo.has("1") && beforeIndCondInfo.has("1")) {
                              indCondInfo.put("1", beforeIndCondInfo.getJSONObject("1"));
                            }
                            if (!indCondInfo.has("20") && beforeIndCondInfo.has("20") || "offLine".equals(ind_treat_cond_iv_mode)) {
                              indCondInfo.put("20", beforeIndCondInfo.getJSONObject("20"));
                            }
                            if (!indCondInfo.has("21") && beforeIndCondInfo.has("21") || "offLine".equals(ind_treat_cond_iv_mode)) {
                              indCondInfo.put("21", beforeIndCondInfo.getJSONObject("21"));
                            }
                            if (!indCondInfo.has("24") && beforeIndCondInfo.has("24") || "offLine".equals(ind_treat_cond_iv_mode)) {
                              indCondInfo.put("24", beforeIndCondInfo.getJSONObject("24"));
                            }
                            Map<String, String> ivCalMap = IvCalAmountAndSpeedUtil.calIvAmountAndIvSpeed(indCondInfo, deviceSetInfoPat, deviceMode);

                            //補液速度算出
                            if ("0".equals(liquidCalPriority)) {
                              if (ivCalMap.containsKey("24") && beforeIndCondInfo.has("24")) {
                                JSONObject changeIndCondInfo = changeCondInfoJson(indCondInfoCopy, ivCalMap.get("24"));

                                beforeIndCondInfo.put("24", changeIndCondInfo);
                              }
                              if (beforeIndCondInfo.has("20") && indCondInfoCopy.has("20") &&
                                !JSONObject.NULL.equals(indCondInfoCopy.getJSONObject("20").get("value"))&& "onLine".equals(ind_treat_cond_iv_mode)) {
                                beforeIndCondInfo.put("20", indCondInfoCopy.get("20"));
                              }else if (ivCalMap.containsKey("20") && beforeIndCondInfo.has("20")) {
                                JSONObject changeIndCondInfo = changeCondInfoJson(indCondInfoCopy, ivCalMap.get("20"));

                                beforeIndCondInfo.put("20", changeIndCondInfo);
                              }
                            }
                            // 1 補液量設定算出
                            if ("1".equals(liquidCalPriority)) {
                              if (ivCalMap.containsKey("20") && beforeIndCondInfo.has("20")) {
                                JSONObject changeIndCondInfo = changeCondInfoJson(indCondInfoCopy, ivCalMap.get("20"));

                                beforeIndCondInfo.put("20", changeIndCondInfo);
                              }
                              if (beforeIndCondInfo.has("24") && indCondInfoCopy.has("24") && "onLine".equals(ind_treat_cond_iv_mode)) {
                                beforeIndCondInfo.put("24", indCondInfoCopy.get("24"));
                              }else if (ivCalMap.containsKey("24") && beforeIndCondInfo.has("24")) {
                                JSONObject changeIndCondInfo = changeCondInfoJson(indCondInfoCopy, ivCalMap.get("24"));

                                beforeIndCondInfo.put("24", changeIndCondInfo);
                              }
                            }
                            // 補液比率
                            if ("2".equals(liquidCalPriority) && ivCalMap != null) {
                              if (ivCalMap.containsKey("20") && beforeIndCondInfo.has("20")) {
                                JSONObject changeIndCondInfo = changeCondInfoJson(indCondInfoCopy, ivCalMap.get("20"));

                                beforeIndCondInfo.put("20", changeIndCondInfo);
                              }
                              if (ivCalMap.containsKey("24") && beforeIndCondInfo.has("24")) {
                                JSONObject changeIndCondInfo = changeCondInfoJson(indCondInfoCopy, ivCalMap.get("24"));

                                beforeIndCondInfo.put("24", changeIndCondInfo);
                              }
                            }
                            //3 濾過率から算出
                            if (liquidCalPriority.equals("3")) {
                              JSONObject jsonObject1 = indCondInfo.getJSONObject(TreatmentItemsDef.T_I_IV_AMOUNT.getItemCode())
                                .put("value", "-1");
                              JSONObject jsonObject2 = indCondInfo.getJSONObject(TreatmentItemsDef.T_I_IV_FLOW_RATE.getItemCode())
                                .put("value", "-1");

                              beforeIndCondInfo.put("20", jsonObject1);// 補液量
                              beforeIndCondInfo.put("24", jsonObject2);// 補液速度
                            }
                          }
                        }
                        if (DeviceMode.I_HDF.equals(deviceMode)) {
                          if ("onLine".equals(ind_treat_cond_iv_mode) || indCondInfo.has("1")) {
                            if (indCondInfo.has("1") || indCondInfo.has("20") || indCondInfo.has("24")) {

                              Map<String, String> resultMap = LiquidCalculateUtils.getIhdfCalculateLiquidAmoutAndSpeed (indDeviceSetInfo , treatTimeStr);
                              if (resultMap.containsKey("20") && beforeIndCondInfo.has("20")) {
                                JSONObject changeIndCondInfo = changeCondInfoJson(indCondInfoCopy, resultMap.get("20"));

                                beforeIndCondInfo.put("20", changeIndCondInfo);
                              }
                              if (resultMap.containsKey("24") && beforeIndCondInfo.has("24")) {
                                JSONObject changeIndCondInfo = changeCondInfoJson(indCondInfoCopy, resultMap.get("24"));

                                beforeIndCondInfo.put("24", changeIndCondInfo);
                              }
                            }
                          }
                        }
                        if (DeviceMode.HDF.equals(deviceMode) || DeviceMode.HF.equals(deviceMode)
                          || DeviceMode.AFBF.equals(deviceMode)) {

                          if (indCondInfo.has("1") && "onLine".equals(ind_treat_cond_iv_mode)) {

                            if (!indCondInfo.has("1") && beforeIndCondInfo.has("1")) {
                              indCondInfo.put("1", beforeIndCondInfo.getJSONObject("1"));
                            }
                            if (beforeIndCondInfo.has("20")) {
                              indCondInfo.put("20", beforeIndCondInfo.getJSONObject("20"));
                              Map<String, String> ivCalMap = IvCalAmountAndSpeedUtil.calIvAmountAndIvSpeed(indCondInfo, deviceSetInfoPat, deviceMode);
                              if (ivCalMap.containsKey("24") && beforeIndCondInfo.has("24")) {
                                JSONObject changeIndCondInfo = changeCondInfoJson(indCondInfoCopy, ivCalMap.get("24"));

                                beforeIndCondInfo.put("24", changeIndCondInfo);
                              }
                            }
                          }else if (!"onLine".equals(ind_treat_cond_iv_mode) && (indCondInfo.has("1") || indCondInfo.has("20")
                          || indCondInfo.has("24"))){
                            if (!indCondInfo.has("1") && beforeIndCondInfo.has("1")) {
                              indCondInfo.put("1", beforeIndCondInfo.getJSONObject("1"));
                            }
                            if (!indCondInfo.has("20") && beforeIndCondInfo.has("20")) {
                              indCondInfo.put("20", beforeIndCondInfo.getJSONObject("20"));
                            }
                            Map<String, String> ivCalMap = IvCalAmountAndSpeedUtil.calIvAmountAndIvSpeed(indCondInfo, deviceSetInfoPat, deviceMode);
                            if (ivCalMap.containsKey("24") && beforeIndCondInfo.has("24")) {
                              JSONObject changeIndCondInfo = changeCondInfoJson(indCondInfoCopy, ivCalMap.get("24"));

                              beforeIndCondInfo.put("24", changeIndCondInfo);
                            }
                            if (beforeIndCondInfo.has("20") && indCondInfoCopy.has("20")) {
                              beforeIndCondInfo.put("20", indCondInfoCopy.get("20"));
                            }
                          }
                        }
                        if ("offLine".equals(ind_treat_cond_iv_mode) && (DeviceMode.UNKNOWN.equals(deviceMode) || DeviceMode.PURIFICATION.equals(deviceMode))) {
                          if (beforeIndCondInfo.has("20") && indCondInfo.has("20")) {
                            beforeIndCondInfo.put("20", indCondInfo.get("20"));
                          }
                          if (beforeIndCondInfo.has("24") && indCondInfo.has("24")) {
                            beforeIndCondInfo.put("24", indCondInfo.get("24"));
                          }
                        }
                        //add 10810月跨ぎの日次処理によるスケジュール自動延長にて濾過率から算出が-1となる zhao end
                        removeKey(beforeIndCondInfo);
                        // mod 10150 治療条件変更時のonline、offline補液関連 関  end
                        updateData.setIndCondInfo(beforeIndCondInfo.toString());
                      }
                      // mod 10495 無期限治療条件変更時のpat_treatment_patternの更新バグ 関 end
                    } else {
                      errStr = "治療条件=null";
                    }
                    break;
                  case MEDI:
                    if (null != editData.getIndMediInfo()) {
                      try {
                        // 元データの対象データと更新データを置換
                        updateData.setIndMediInfo(this.updateJsonData("no", registData.get(0).getIndMediInfo(), editData.getIndMediInfo()));
                      } catch (Exception e) {
                        EventLogMessage eventLogMessage = new EventLogMessage();
                        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
                        if (facilityCd != null) {
                          eventLogMessage.setFacilityCd(facilityCd);
                        }
                        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
                        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
                        logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
                        errStr = "投与薬剤=" + editData.getIndMediInfo();
                      }
                    } else {
                      errStr = "投与薬剤=null";
                    }
                    break;
                  case EQUIP:
                    if (null != editData.getIndEquipInfo()) {
                      try {
                        // mod 10744 医療材料の穴埋め追加によるpat_treatment_patternへの追加処理が不正 関 start
                        boolean existFlag = true;
                        if ("1".equals(editData.getAutoInsert())) {
                          existFlag = this.beforeDataExist("cd", registData.get(0).getIndEquipInfo(), editData.getIndEquipInfo());
                          if (existFlag) {
                            // 元データの対象データと更新データを置換
                            updateData.setIndEquipInfo(this.updateJsonData("cd", registData.get(0).getIndEquipInfo(), editData.getIndEquipInfo()));
                          } else {
                            updateData.setIndEquipInfo(this.insertJsonData("cd", registData.get(0).getIndEquipInfo(), editData.getIndEquipInfo(), true));
                          }
                        } else {
                          // 元データの対象データと更新データを置換
                          updateData.setIndEquipInfo(this.updateJsonData("cd", registData.get(0).getIndEquipInfo(), editData.getIndEquipInfo()));
                        }
                        // mod 10744 医療材料の穴埋め追加によるpat_treatment_patternへの追加処理が不正 関 end
                      } catch (Exception e) {
                        EventLogMessage eventLogMessage = new EventLogMessage();
                        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
                        if (facilityCd != null) {
                          eventLogMessage.setFacilityCd(facilityCd);
                        }
                        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
                        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
                        logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
                        errStr = "医療材料=" + editData.getIndMediInfo();
                      }
                    } else {
                      errStr = "医療材料=null";
                    }
                    break;
                  case IND_COMMENT:
                    if (null != editData.getIndIndCommentInfo()) {
                      try {
                        // 元データの対象データと更新データを置換
                        updateData.setIndIndCommentInfo(this.updateJsonData("no", registData.get(0).getIndIndCommentInfo(), editData.getIndIndCommentInfo()));
                      } catch (Exception e) {
                        EventLogMessage eventLogMessage = new EventLogMessage();
                        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
                        if (facilityCd != null) {
                          eventLogMessage.setFacilityCd(facilityCd);
                        }
                        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
                        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
                        logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
                        errStr = "指示コメント=" + editData.getIndIndCommentInfo();
                      }
                    } else {
                      errStr = "指示コメント=null";
                    }
                    break;
                  case TARE:
                    if (null != editData.getIndTareInfo()) {
                      updateData.setIndTareInfo(editData.getIndTareInfo());
                    } else {
                      errStr = "風体=null";
                    }
                    break;
                  case OFF_WATER:
                    if (null != editData.getIndOffWaterInfo()) {
                      updateData.setIndOffWaterInfo(editData.getIndOffWaterInfo());
                    } else {
                      errStr = "除水=null";
                    }
                    break;
                  case DEVICE_SET_INFO:
                    if (null != editData.getIndDeviceSetInfo()) {
                      updateData.setIndDeviceSetInfo(editData.getIndDeviceSetInfo());
                      // add #10150 装置プログラムのI-HDF設定を変更する場合、pat_treatment_mainの治療条件の補液量(key:20)と補液速度(key:24)を再計算する zkm start
                      List<MstTreatment> treatments = selectedTreat.stream().filter(t -> t.getTreatmentCd().equals(searchTreatmentCd)).toList();
                      // device_mode:10(I-HDF)が変更する時、ind_cond_infoを再設定する
                      if (!CollectionUtils.isEmpty(treatments) && Objects.nonNull(treatments.get(0).getDeviceMode()) && DeviceMode.I_HDF.equals(treatments.get(0).getDeviceMode())) {
                        JSONObject updIndDeviceSetInfo = new JSONObject(editData.getIndDeviceSetInfo());
                        if (updIndDeviceSetInfo.has("ihdf")) {
                          String indCondInfo;
                          if (StringUtils.isEmpty(updateData.getIndCondInfo())) {
                            indCondInfo = registData.get(0).getIndCondInfo();
                          } else {
                            indCondInfo = updateData.getIndCondInfo();
                          }
                          if (!StringUtils.isEmpty(indCondInfo)) {
                            JSONObject condInfo = new JSONObject(indCondInfo);
                            String treatTimeStr = condInfo.getJSONObject("1").getString("value");
                            Map<String, String> liquidAmoutAndSpeed = LiquidCalculateUtils.getIhdfCalculateLiquidAmoutAndSpeed(updIndDeviceSetInfo, StringUtils.isEmpty(treatTimeStr) ? null : treatTimeStr);
                            liquidAmoutAndSpeed.forEach((key, v) -> {
                              if (condInfo.has(key)) {
                                JSONObject jsonObj = condInfo.getJSONObject(key);
                                jsonObj.put("value", v);
                              }
                            });
                            updateData.setIndCondInfo(condInfo.toString());
                          }
                        }
                      }
                      // add #10150 装置プログラムのI-HDF設定を変更する場合、pat_treatment_mainの治療条件の補液量(key:20)と補液速度(key:24)を再計算する zkm end
                    } else {
                      errStr = "装置設定=null";
                    }
                    break;
                }
                if (null != errStr) {
                  EventLogMessage eventLogMessage = new EventLogMessage();
                  eventLogMessage.setLogMessage("患者治療パターンの更新データに異常があるため処理を中断しました:"
                  + "[更新条件:"
                  + "患者ID=" + patId
                  + "、管理番号=" + patId
                  + "]、"
                  + "[更新データ:" + errStr
                  + "]");
                  logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
                  // ロールバック実行
                  throw new RuntimeException();
                }
              }
              // 更新処理実施
              updateData.setCtlNo(registData.get(0).getCtlNo());
              updateData.setPatId(patId);
              // add 9664 by kangjie 20240425 start
              updateData.setIndTreatmentCd(registData.get(0).getIndTreatmentCd());
              // add 9664 by kangjie 20240425 end
              //upd by ztc 2023-02-23 [Optimize runtime No.5482] --start /
              updateDataList.add(updateData);
//              updateCount = patTreatmentPatternDao.updateById(patId, registData.get(0).getCtlNo(), updateData);
              //upd by ztc 2023-02-23 [Optimize runtime No.5482] --end /
            } else {
              EventLogMessage eventLogMessage = new EventLogMessage();
              eventLogMessage.setLogMessage("患者治療パターンの更新元データに異常があるため処理をスキップしました:"
              + "[抽出条件:"
              + "患者ID=" + patId
              + "、施設コード=" + facilityCd
              + "、治療方法コード=" + searchTreatmentCd
              + "、クールコード=" + searchIndKurCd
              + "、曜日番号=" + searchWeek
              + "]、"
              + "[抽出件数:" + registData.size()
              + "]");
              logService.log(LogLevel.WARN, eventLogMessage,"",SERVICE_NAME.FNSI, null);
            }
          }
        }
      }
      //upd by ztc 2023-02-23 [Optimize runtime No.5482] --start /
      //upd by ztc 2023-03-13 [Batch modify data, log_event table has no data and the user is null No.6067] --start /
      if(!updateDataList.isEmpty()){
        List<Long> ctlNoList = updateDataList.stream().map(PatTreatmentPattern::getCtlNo).collect(Collectors.toList());
        Long patIdSr = updateDataList.get(0).getPatId();
        // DB更新ログ出力ロジック wangzuo Start
        String tableName = "pat_treatment_pattern";
        // SQL検索条件
        String inStr = getInStr("ctl_no in ", ctlNoList);
        StringBuffer wheres = new StringBuffer("");
        wheres.append(" WHERE\n");
        wheres.append(inStr + "\n");
        wheres.append("AND pat_id = '" + patIdSr + "'\n");
        // logCommon設定
        DataUpdateLogCommonNew logCommon = getLogCommon(tableName, wheres, getEventLogMessage());
        // ログ出力カラム情報及び更新前データ情報取得
        boolean setResult = logCommon.setInfo();
        // DB更新ログ出力ロジック wangzuo End
        try {
          // mod 10150 治療条件変更時のonline、offline補液関連 関  start
          // add 9664 by kangjie 20240425 start
          // 治療条件 update
          /* List<IND_ITEM> collect = updateIndItemList.stream().filter(item -> item == IND_ITEM.COND).collect(Collectors.toList());
          List<PatTreatmentPattern> mergeFluidList = new ArrayList<>();
          if (!collect.isEmpty()) {
            for (PatTreatmentPattern patTreatmentPattern : updateDataList) {
              // fluid data is not null and deviceMode in the same category
              Integer treatmentCd = patTreatmentPattern.getIndTreatmentCd();
              String indCondInfo = patTreatmentPattern.getIndCondInfo();
              if ( sameCategoryFluidComponent.filterSameCategoryPatternData(treatmentCd,mstTreatList,indCondInfo,ind_treat_cond_iv_mode)) {
                JSONObject indCondJSONData = new JSONObject(patTreatmentPattern.getIndCondInfo());
                // remove fluid data and get new data of fluidJSON
                JSONObject fluidJSONData = sameCategoryFluidComponent.removeFluidData(indCondJSONData);
                patTreatmentPattern.setIndCondInfo(indCondJSONData.toString());
                // merge fluid data
                PatTreatmentPattern mergeFluidData = new PatTreatmentPattern();
                mergeFluidData.setIndCondInfo(fluidJSONData.toString());
                mergeFluidData.setPatId(patTreatmentPattern.getPatId());
                mergeFluidData.setCtlNo(patTreatmentPattern.getCtlNo());
                mergeFluidData.setUpDate(patTreatmentPattern.getUpDate());
                mergeFluidList.add(mergeFluidData);
              }
            }
          }
          updateCount = patTreatmentPatternDao.updateByIdList(updateDataList);
          if (mergeFluidList.size() > 0) {
            sameCategoryFluidComponent.updateNewPatternSteps(mergeFluidList);
          }*/
          // add 9664 by kangjie 20240425 end
          updateCount = patTreatmentPatternDao.updateByIdList(updateDataList);
          // mod 10150 治療条件変更時のonline、offline補液関連 関  end
        } catch (Exception e) {
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
          if (!StringUtils.isEmpty(facilityCd)) {
            eventLogMessage.setFacilityCd(facilityCd);
          }
          logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
        }
        // DB更新ログ出力ロジック wangzuo Start
        // 更新後データ取得、差分あれば、log出力
        if (setResult && updateCount > 0) {
          /* modify by chamaojia 2023-03-09 sqlを同期実行し、非同期差分保存ログ  --start */
          logCommon.setAfterResults();
//        logCommon.updateLog();
          asyncService.updateLog(logCommon);
          /* modify by chamaojia 2023-03-09 sqlを同期実行し、非同期差分保存ログ  --end */
        }
        // DB更新ログ出力ロジック wangzuo End
      }
      //upd by ztc 2023-03-13 [Batch modify data, log_event table has no data and the user is null No.6067] --end /
      //upd by ztc 2023-02-23 [Optimize runtime No.5482] --end /
    } catch(Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("患者治療パターン項目更新処理に失敗しました:" + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      // ロールバック実行
      throw new RuntimeException();
    }

    return updateCount;
  }

  //upd by ztc 2023-03-13 [Batch modify data, log_event table has no data and the user is null No.6067] --start /
  //  add 9281 日次処理にて正しくスケジュールが作成されない事がある 関 start
  /**
   * 治療方法の変更 患者治療パターン項目更新
   * @param patId 抽出データ（処理対象患者の患者ID）
   * @param facilityCd 抽出データ（処理対象施設の施設コード）
   * @param indTreatmentCdList 抽出データ（処理対象治療予定の指示：治療方法コード）  ※全治療方法指定の場合はnull設定
   * @param indKurCdList 抽出データ（処理対象治療予定の指示：クールコード） ※全クール指定の場合はnull設定
   * @param weekPatternList 抽出データ（処理対象治療予定の曜日パターン:処理を実施する曜日番号リスト）  ※全曜日指定の場合はnull設定
   * @param updateIndItemList 更新対象指示項目リスト
   * @param upDate 更新日時
   * @param editData 編集データ ※更新したいデータ(画面単位のデータ)のみを設定
   * @return 処理件数(失敗時は「-1」)
   */
  @Transactional
  public int updatePatTreatmentPatternIndItemForTreat(
    Long patId,
    String facilityCd,
    List<Integer> indTreatmentCdList,
    List<Long> indKurCdList,
    List<Integer> weekPatternList,
    List<IND_ITEM> updateIndItemList,
    Timestamp upDate,
    PatTreatmentPatternEditData editData
  ) {
    int updateCount = -1;
    try {
      // 変更対象の患者治療パターン検索
      List<PatTreatmentPattern> beforeData = this.searchPatTreatmentPattern(patId, facilityCd, indTreatmentCdList, indKurCdList, weekPatternList);
      indTreatmentCdList = beforeData.stream().map(item -> item.getIndTreatmentCd()).distinct().collect(Collectors.toList());
      indKurCdList = beforeData.stream().map(item -> item.getIndKurCd()).distinct().collect(Collectors.toList());
      weekPatternList = beforeData.stream().map(item -> item.getTreatWeek().intValue()).distinct().collect(Collectors.toList());
      List<PatTreatmentPattern> updateDataList = new LinkedList<>();
      MstPersonalUser user = mstPersonalUserDao.selectById(editData.getIndUserId());
      NtssUser ntssUser = (NtssUser) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
      MstPersonalUser updUser = mstPersonalUserDao.selectById(ntssUser.getUserId());
      // 患者治療パターン更新
      for (int i = 0; i < indTreatmentCdList.size(); i++) {
        for (int j = 0; j < indKurCdList.size(); j++) {
          for (int k = 0; k < weekPatternList.size(); k++) {
            // 発行条件の治療方法、クール、曜日から更新元データを抽出
            Integer searchTreatmentCd = indTreatmentCdList.get(i);
            Long searchIndKurCd = indKurCdList.get(j);
            Integer searchWeek = weekPatternList.get(k);
            List<PatTreatmentPattern> registData = beforeData.stream().filter(info ->
              searchTreatmentCd.equals(info.getIndTreatmentCd()) &&
                searchIndKurCd.equals(info.getIndKurCd()) &&
                searchWeek.equals((int)info.getTreatWeek())
            ).collect(Collectors.toList());
            if (1 == registData.size()) {
              // 更新データ作成
              PatTreatmentPattern updateData = new PatTreatmentPattern();
              String errStr = null;
              updateData.setUpDate(upDate);
              for (int l = 0; l < updateIndItemList.size(); l++) {
                IND_ITEM updateIndItem = updateIndItemList.get(l);
                switch (updateIndItem) {
                  case TREATMENT:
                    if (null != editData.getIndTreatmentCd()) {
                      updateData.setIndTreatmentCd(editData.getIndTreatmentCd());
                    } else {
                      errStr = "治療方法=null";
                    }
                    break;
                  case KUR:
                    if (null != editData.getIndKurCd()) {
                      updateData.setIndKurCd(editData.getIndKurCd());
                    } else {
                      errStr = "クール=null";
                    }
                    break;
                  case SCHE:
                    if (null != editData.getIndSchInfo()) {
                      updateData.setIndSchInfo(editData.getIndSchInfo());
                    } else {
                      errStr = "スケジュール=null";
                    }
                    break;
                  case COND:
                    if (null != editData.getIndCondInfo()) {
                      updateData.setIndCondInfo(editData.getIndCondInfo());
                      // 治療条件が空時治療条件デフォルト設定
                    } else {
                      MstTreatment selectedTreat = mstTreatmentDao.selectByCd(editData.getIndTreatmentCd());
                      JSONArray treatCondSetting = null == selectedTreat.getTreatmentConditionSetting() ?
                        new JSONArray() :
                        new JSONArray(selectedTreat.getTreatmentConditionSetting());
                      JSONObject indCondInfo = null == registData.get(0).getIndCondInfo()?
                        new JSONObject() :
                        new JSONObject(registData.get(0).getIndCondInfo());
                      for (int s = 0; s < treatCondSetting.length(); s++) {
                        JSONArray items = treatCondSetting.getJSONObject(s).getJSONArray("items");
                        for (int n = 0; n < items.length(); n++) {
                          String key = items.getJSONObject(n).get("ctl_no").toString();
                          if (items.getJSONObject(n).get("is_use").equals("0")) {
                            indCondInfo.remove(items.getJSONObject(n).get("ctl_no").toString());
                            // 患者治療パターンはDWに登録しない
                          } else if (!indCondInfo.has(key) && !key.equals("39")) {
                            JSONObject json = new JSONObject("{}");
                            // 設定値
                            json.put("value", JSONObject.NULL);
                            // 指示者コード
                            json.put("ind_user_id", user.getUserId());
                            // 登録区分
                            json.put("input_class", 1);
                            // 編集可否フラグ
                            json.put("is_editable", "1");
                            // 更新者コード
                            json.put("upd_user_id", ntssUser.getUserId());
                            // 連携オーダ番号
                            json.put("cop_order_no", JSONObject.NULL);
                            // 指示者名_姓
                            json.put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
                            // 指示者名_名
                            json.put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
                            // 更新者名_姓
                            json.put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
                            // 更新者名_名
                            json.put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);

                            indCondInfo.put(key,json);
                          }
                        }
                      }
                      if (DeviceMode.OHDF.equals(editData.getDeviceMode()) || DeviceMode.OHF.equals(editData.getDeviceMode())) {
                        // #9973 Mod by Zhou.tao fix value's type. Start.
                        // !indCondInfo.getJSONObject("15").get("value").equals(null)
                        if (indCondInfo.getJSONObject("15").has("value")
                          && !indCondInfo.getJSONObject("15").isNull("value")
                        ) {
                          //補液使用数小数点制御
//                          String value = String.valueOf(indCondInfo.getJSONObject("15").get("value"));
//                          String[] decimal = value.split("\\.");
//                          String number = "0";
//                          if (decimal.length > 1) {
//                            number += ".";
//                            for (int m = 1; m < decimal.length; m++) {
//                              number += "0";
//                            }
//                          }
                          // 補液
                          indCondInfo.getJSONObject(TreatmentItemsDef.T_I_IV.getItemCode())
                            .put("value"
                              , indCondInfo.getJSONObject(TreatmentItemsDef.T_I_DIALYSES.getItemCode()).get("value"));
                          // 指示者コード
                          indCondInfo.getJSONObject(TreatmentItemsDef.T_I_IV.getItemCode()).put("ind_user_id", user.getUserId());
                          // 指示者名_姓
                          indCondInfo.getJSONObject(TreatmentItemsDef.T_I_IV.getItemCode()).put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
                          // 指示者名_名
                          indCondInfo.getJSONObject(TreatmentItemsDef.T_I_IV.getItemCode()).put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
                          // 更新者コード
                          indCondInfo.getJSONObject(TreatmentItemsDef.T_I_IV.getItemCode()).put("upd_user_id", ntssUser.getUserId());
                          // 更新者名_姓
                          indCondInfo.getJSONObject(TreatmentItemsDef.T_I_IV.getItemCode()).put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
                          // 更新者名_名
                          indCondInfo.getJSONObject(TreatmentItemsDef.T_I_IV.getItemCode()).put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);


                          // 補液量
//                          indCondInfo.getJSONObject("20").put("value",0);
                          indCondInfo.getJSONObject(TreatmentItemsDef.T_I_IV_AMOUNT.getItemCode())
                            .put("value", TreatmentItemsDef.T_I_IV_AMOUNT.getDefaultValue());
                          // 指示者コード
                          indCondInfo.getJSONObject(TreatmentItemsDef.T_I_IV_AMOUNT.getItemCode()).put("ind_user_id", user.getUserId());
                          // 指示者名_姓
                          indCondInfo.getJSONObject(TreatmentItemsDef.T_I_IV_AMOUNT.getItemCode()).put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
                          // 指示者名_名
                          indCondInfo.getJSONObject(TreatmentItemsDef.T_I_IV_AMOUNT.getItemCode()).put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
                          // 更新者コード
                          indCondInfo.getJSONObject(TreatmentItemsDef.T_I_IV_AMOUNT.getItemCode()).put("upd_user_id", ntssUser.getUserId());
                          // 更新者名_姓
                          indCondInfo.getJSONObject(TreatmentItemsDef.T_I_IV_AMOUNT.getItemCode()).put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
                          // 更新者名_名
                          indCondInfo.getJSONObject(TreatmentItemsDef.T_I_IV_AMOUNT.getItemCode()).put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);

                          // 補液選択
//                          indCondInfo.getJSONObject("21").put("value",1);
                          indCondInfo.getJSONObject(TreatmentItemsDef.T_I_IV_SELECTION.getItemCode())
                            .put("value", TreatmentItemsDef.T_I_IV_SELECTION.getDefaultValue());
                          // 指示者コード
                          indCondInfo.getJSONObject(TreatmentItemsDef.T_I_IV_SELECTION.getItemCode()).put("ind_user_id", user.getUserId());
                          // 指示者名_姓
                          indCondInfo.getJSONObject(TreatmentItemsDef.T_I_IV_SELECTION.getItemCode()).put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
                          // 指示者名_名
                          indCondInfo.getJSONObject(TreatmentItemsDef.T_I_IV_SELECTION.getItemCode()).put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
                          // 更新者コード
                          indCondInfo.getJSONObject(TreatmentItemsDef.T_I_IV_SELECTION.getItemCode()).put("upd_user_id", ntssUser.getUserId());
                          // 更新者名_姓
                          indCondInfo.getJSONObject(TreatmentItemsDef.T_I_IV_SELECTION.getItemCode()).put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
                          // 更新者名_名
                          indCondInfo.getJSONObject(TreatmentItemsDef.T_I_IV_SELECTION.getItemCode()).put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);

                          // 補液使用数
                          indCondInfo.getJSONObject(TreatmentItemsDef.T_I_IV_COUNT.getItemCode())
                            .put("value", TreatmentItemsDef.T_I_IV_COUNT.getDefaultValue());
                          // 指示者コード
                          indCondInfo.getJSONObject(TreatmentItemsDef.T_I_IV_COUNT.getItemCode()).put("ind_user_id", user.getUserId());
                          // 指示者名_姓
                          indCondInfo.getJSONObject(TreatmentItemsDef.T_I_IV_COUNT.getItemCode()).put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
                          // 指示者名_名
                          indCondInfo.getJSONObject(TreatmentItemsDef.T_I_IV_COUNT.getItemCode()).put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
                          // 更新者コード
                          indCondInfo.getJSONObject(TreatmentItemsDef.T_I_IV_COUNT.getItemCode()).put("upd_user_id", ntssUser.getUserId());
                          // 更新者名_姓
                          indCondInfo.getJSONObject(TreatmentItemsDef.T_I_IV_COUNT.getItemCode()).put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
                          // 更新者名_名
                          indCondInfo.getJSONObject(TreatmentItemsDef.T_I_IV_COUNT.getItemCode()).put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);

                          // 補液温度
//                          indCondInfo.getJSONObject("23").put("value",36);
                          indCondInfo.getJSONObject(TreatmentItemsDef.T_I_IV_TEMPERATURE.getItemCode())
                            .put("value", TreatmentItemsDef.T_I_IV_TEMPERATURE.getDefaultValue());
                          // 指示者コード
                          indCondInfo.getJSONObject(TreatmentItemsDef.T_I_IV_TEMPERATURE.getItemCode()).put("ind_user_id", user.getUserId());
                          // 指示者名_姓
                          indCondInfo.getJSONObject(TreatmentItemsDef.T_I_IV_TEMPERATURE.getItemCode()).put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
                          // 指示者名_名
                          indCondInfo.getJSONObject(TreatmentItemsDef.T_I_IV_TEMPERATURE.getItemCode()).put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
                          // 更新者コード
                          indCondInfo.getJSONObject(TreatmentItemsDef.T_I_IV_TEMPERATURE.getItemCode()).put("upd_user_id", ntssUser.getUserId());
                          // 更新者名_姓
                          indCondInfo.getJSONObject(TreatmentItemsDef.T_I_IV_TEMPERATURE.getItemCode()).put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
                          // 更新者名_名
                          indCondInfo.getJSONObject(TreatmentItemsDef.T_I_IV_TEMPERATURE.getItemCode()).put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);

                          // 補液速度
//                          indCondInfo.getJSONObject("24").put("value",0);
                          indCondInfo.getJSONObject(TreatmentItemsDef.T_I_IV_FLOW_RATE.getItemCode())
                            .put("value", TreatmentItemsDef.T_I_IV_FLOW_RATE.getDefaultValue());
                          // 指示者コード
                          indCondInfo.getJSONObject(TreatmentItemsDef.T_I_IV_FLOW_RATE.getItemCode()).put("ind_user_id", user.getUserId());
                          // 指示者名_姓
                          indCondInfo.getJSONObject(TreatmentItemsDef.T_I_IV_FLOW_RATE.getItemCode()).put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
                          // 指示者名_名
                          indCondInfo.getJSONObject(TreatmentItemsDef.T_I_IV_FLOW_RATE.getItemCode()).put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
                          // 更新者コード
                          indCondInfo.getJSONObject(TreatmentItemsDef.T_I_IV_FLOW_RATE.getItemCode()).put("upd_user_id", ntssUser.getUserId());
                          // 更新者名_姓
                          indCondInfo.getJSONObject(TreatmentItemsDef.T_I_IV_FLOW_RATE.getItemCode()).put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
                          // 更新者名_名
                          indCondInfo.getJSONObject(TreatmentItemsDef.T_I_IV_FLOW_RATE.getItemCode()).put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);

                        }
                      }
                      if (DeviceMode.AFBF.equals(editData.getDeviceMode()) || DeviceMode.I_HDF.equals(editData.getDeviceMode())) {
                        if (indCondInfo.has("12")) {
//                          indCondInfo.getJSONObject("12").put("value",0);
                          indCondInfo.getJSONObject(TreatmentItemsDef.T_I_NEEDLE_SELECTION.getItemCode())
                            .put("value", TreatmentItemsDef.T_I_NEEDLE_SELECTION.getDefaultValue());
                          // 指示者コード
                          indCondInfo.getJSONObject(TreatmentItemsDef.T_I_NEEDLE_SELECTION.getItemCode()).put("ind_user_id", user.getUserId());
                          // 指示者名_姓
                          indCondInfo.getJSONObject(TreatmentItemsDef.T_I_NEEDLE_SELECTION.getItemCode()).put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
                          // 指示者名_名
                          indCondInfo.getJSONObject(TreatmentItemsDef.T_I_NEEDLE_SELECTION.getItemCode()).put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
                          // 更新者コード
                          indCondInfo.getJSONObject(TreatmentItemsDef.T_I_NEEDLE_SELECTION.getItemCode()).put("upd_user_id", ntssUser.getUserId());
                          // 更新者名_姓
                          indCondInfo.getJSONObject(TreatmentItemsDef.T_I_NEEDLE_SELECTION.getItemCode()).put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
                          // 更新者名_名
                          indCondInfo.getJSONObject(TreatmentItemsDef.T_I_NEEDLE_SELECTION.getItemCode()).put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);

                        }
                      }
                      if (indCondInfo.has("12")) {
//                        if ((indCondInfo.getJSONObject("12").get("value")).equals(1)) {
                        String needleSelectionVal = String.valueOf(
                          indCondInfo.getJSONObject(TreatmentItemsDef.T_I_NEEDLE_SELECTION.getItemCode()).get("value")
                        );
                        if (StringUtils.equals("1", needleSelectionVal)) {
                          if (indCondInfo.has(TreatmentItemsDef.T_I_NEEDLE_A.getItemCode())) {
                            indCondInfo.remove(TreatmentItemsDef.T_I_NEEDLE_A.getItemCode());
                          }
                          if (indCondInfo.has(TreatmentItemsDef.T_I_NEEDLE_V.getItemCode())) {
                            indCondInfo.remove(TreatmentItemsDef.T_I_NEEDLE_V.getItemCode());
                          }
//                        } else if ((indCondInfo.getJSONObject("12").get("value")).equals(0)) {
                        } else if (StringUtils.equals("0", needleSelectionVal)) {
                          if (indCondInfo.has(TreatmentItemsDef.T_I_NEEDLE_SN.getItemCode())) {
                            indCondInfo.remove(TreatmentItemsDef.T_I_NEEDLE_SN.getItemCode());
                          }
                        }
                      }
                      if (DeviceMode.I_HDF.equals(editData.getDeviceMode())) {
                        if (indCondInfo.has(TreatmentItemsDef.T_I_DIALYZER.getItemCode())
                          && !indCondInfo.isNull(TreatmentItemsDef.T_I_DIALYZER.getItemCode())
                          // add #10154 ダイアライザが未登録のスケジュールをIHDFへ変更するとエラー500発生 dou start
                          && indCondInfo.getJSONObject(TreatmentItemsDef.T_I_DIALYZER.getItemCode()).has("value")
                          && !indCondInfo.getJSONObject(TreatmentItemsDef.T_I_DIALYZER.getItemCode()).isNull("value")) {
                          // add #10154 ダイアライザが未登録のスケジュールをIHDFへ変更するとエラー500発生 dou end
                          Set<Integer> dialyzerCds = new HashSet<>();
                          dialyzerCds.add(Integer.parseInt(indCondInfo.getJSONObject("5").get("value").toString()));
                          List<MstDialyzer> mstDialyzers = mstDialyzerDao.selectAllByCdList(SelectOptions.get(), new ArrayList<>(dialyzerCds));
                          if (!mstDialyzers.isEmpty() &&
                            StringUtils.equals("1", mstDialyzers.get(0).getDialyzerType())
                          ) {
                            indCondInfo.getJSONObject("5").put("value", JSONObject.NULL);
                            // 指示者コード
                            indCondInfo.getJSONObject("5").put("ind_user_id", user.getUserId());
                            // 指示者名_姓
                            indCondInfo.getJSONObject("5").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
                            // 指示者名_名
                            indCondInfo.getJSONObject("5").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
                            // 更新者コード
                            indCondInfo.getJSONObject("5").put("upd_user_id", ntssUser.getUserId());
                            // 更新者名_姓
                            indCondInfo.getJSONObject("5").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
                            // 更新者名_名
                            indCondInfo.getJSONObject("5").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);
                          }
                        }
                      }
                      // add 10495 無期限治療条件変更時のpat_treatment_patternの更新バグ 関  start
                      JSONObject beforeIndCondInfo = null == registData.get(0).getIndCondInfo()?
                        new JSONObject() :
                        new JSONObject(registData.get(0).getIndCondInfo());

                      for (String key : indCondInfo.keySet()) {
                        if (beforeIndCondInfo.has(key)) {
                          indCondInfo.put(key, beforeIndCondInfo.get(key));
                        }
                      }
                      // add 10495 無期限治療条件変更時のpat_treatment_patternの更新バグ 関  end

                      updateData.setIndCondInfo(indCondInfo.toString());
                    }
                    break;
                  // #9973 Mod by Zhou.tao fix value's type. End.
                  case MEDI:
                    if (null != editData.getIndMediInfo()) {
                      try {
                        // 元データの対象データと更新データを置換
                        updateData.setIndMediInfo(this.updateJsonData("no", registData.get(0).getIndMediInfo(), editData.getIndMediInfo()));
                      } catch (Exception e) {
                        EventLogMessage eventLogMessage = new EventLogMessage();
                        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
                        if (facilityCd != null) {
                          eventLogMessage.setFacilityCd(facilityCd);
                        }
                        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
                        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
                        logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
                        errStr = "投与薬剤=" + editData.getIndMediInfo();
                      }
                    } else {
                      errStr = "投与薬剤=null";
                    }
                    break;
                  case EQUIP:
                    if (null != editData.getIndEquipInfo()) {
                      try {
                        // 元データの対象データと更新データを置換
                        updateData.setIndEquipInfo(this.updateJsonData("cd", registData.get(0).getIndEquipInfo(), editData.getIndEquipInfo()));
                      } catch (Exception e) {
                        EventLogMessage eventLogMessage = new EventLogMessage();
                        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
                        if (facilityCd != null) {
                          eventLogMessage.setFacilityCd(facilityCd);
                        }
                        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
                        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
                        logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
                        errStr = "医療材料=" + editData.getIndMediInfo();
                      }
                    } else {
                      errStr = "医療材料=null";
                    }
                    break;
                  case IND_COMMENT:
                    if (null != editData.getIndIndCommentInfo()) {
                      try {
                        // 元データの対象データと更新データを置換
                        updateData.setIndIndCommentInfo(this.updateJsonData("no", registData.get(0).getIndIndCommentInfo(), editData.getIndIndCommentInfo()));
                      } catch (Exception e) {
                        EventLogMessage eventLogMessage = new EventLogMessage();
                        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
                        if (facilityCd != null) {
                          eventLogMessage.setFacilityCd(facilityCd);
                        }
                        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
                        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
                        logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
                        errStr = "指示コメント=" + editData.getIndIndCommentInfo();
                      }
                    } else {
                      errStr = "指示コメント=null";
                    }
                    break;
                  case TARE:
                    if (null != editData.getIndTareInfo()) {
                      updateData.setIndTareInfo(editData.getIndTareInfo());
                    } else {
                      errStr = "風体=null";
                    }
                    break;
                  case OFF_WATER:
                    if (null != editData.getIndOffWaterInfo()) {
                      updateData.setIndOffWaterInfo(editData.getIndOffWaterInfo());
                    } else {
                      errStr = "除水=null";
                    }
                    break;
                  case DEVICE_SET_INFO:
                    if (null != editData.getIndDeviceSetInfo()) {
                      updateData.setIndDeviceSetInfo(editData.getIndDeviceSetInfo());
                      // 装置設定が空の場合装置設定デフォルト値設定
                    } else {
                      JSONObject deviceSetInfo = null == registData.get(0).getIndDeviceSetInfo() ?
                        new JSONObject() :
                        new JSONObject(registData.get(0).getIndDeviceSetInfo());
                      if (DeviceMode.HD.equals(editData.getDeviceMode())) {
                        deviceSetInfo.getJSONObject("ihdf")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("432", "0");
                        // 指示者コード
                        deviceSetInfo.getJSONObject("ihdf").put("ind_user_id", user.getUserId());
                        // 指示者名_姓
                        deviceSetInfo.getJSONObject("ihdf").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
                        // 指示者名_名
                        deviceSetInfo.getJSONObject("ihdf").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
                        // 更新者コード
                        deviceSetInfo.getJSONObject("ihdf").put("upd_user_id", ntssUser.getUserId());
                        // 更新者名_姓
                        deviceSetInfo.getJSONObject("ihdf").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
                        // 更新者名_名
                        deviceSetInfo.getJSONObject("ihdf").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);
                      }
                      if (DeviceMode.ECUM.equals(editData.getDeviceMode())) {
                        deviceSetInfo.getJSONObject("ihdf")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("432", "0");
                        // 指示者コード
                        deviceSetInfo.getJSONObject("ihdf").put("ind_user_id", user.getUserId());
                        // 指示者名_姓
                        deviceSetInfo.getJSONObject("ihdf").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
                        // 指示者名_名
                        deviceSetInfo.getJSONObject("ihdf").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
                        // 更新者コード
                        deviceSetInfo.getJSONObject("ihdf").put("upd_user_id", ntssUser.getUserId());
                        // 更新者名_姓
                        deviceSetInfo.getJSONObject("ihdf").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
                        // 更新者名_名
                        deviceSetInfo.getJSONObject("ihdf").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);
                      }
                      if (DeviceMode.HDF.equals(editData.getDeviceMode())) {
                        deviceSetInfo.getJSONObject("ufr")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("291", "0");
                        deviceSetInfo.getJSONObject("ufr")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("292", "0");
                        deviceSetInfo.getJSONObject("ufr")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("293", "0");
                        deviceSetInfo.getJSONObject("ufr")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("294", "0");
                        deviceSetInfo.getJSONObject("ufr")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("295", "0");
                        deviceSetInfo.getJSONObject("ufr")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("296", "0");
                        deviceSetInfo.getJSONObject("ufr")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("297", "0");
                        deviceSetInfo.getJSONObject("ufr")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("298", "0");
                        deviceSetInfo.getJSONObject("ufr")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("299", "0");
                        deviceSetInfo.getJSONObject("ufr")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("300", "0");
                        // 指示者コード
                        deviceSetInfo.getJSONObject("ufr").put("ind_user_id", user.getUserId());
                        // 指示者名_姓
                        deviceSetInfo.getJSONObject("ufr").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
                        // 指示者名_名
                        deviceSetInfo.getJSONObject("ufr").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
                        // 更新者コード
                        deviceSetInfo.getJSONObject("ufr").put("upd_user_id", ntssUser.getUserId());
                        // 更新者名_姓
                        deviceSetInfo.getJSONObject("ufr").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
                        // 更新者名_名
                        deviceSetInfo.getJSONObject("ufr").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);

                        deviceSetInfo.getJSONObject("ihdf")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("432", "0");
                        // 指示者コード
                        deviceSetInfo.getJSONObject("ihdf").put("ind_user_id", user.getUserId());
                        // 指示者名_姓
                        deviceSetInfo.getJSONObject("ihdf").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
                        // 指示者名_名
                        deviceSetInfo.getJSONObject("ihdf").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
                        // 更新者コード
                        deviceSetInfo.getJSONObject("ihdf").put("upd_user_id", ntssUser.getUserId());
                        // 更新者名_姓
                        deviceSetInfo.getJSONObject("ihdf").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
                        // 更新者名_名
                        deviceSetInfo.getJSONObject("ihdf").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);

                        deviceSetInfo.getJSONObject("dia")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("282", "0");
                        // 指示者コード
                        deviceSetInfo.getJSONObject("dia").put("ind_user_id", user.getUserId());
                        // 指示者名_姓
                        deviceSetInfo.getJSONObject("dia").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
                        // 指示者名_名
                        deviceSetInfo.getJSONObject("dia").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
                        // 更新者コード
                        deviceSetInfo.getJSONObject("dia").put("upd_user_id", ntssUser.getUserId());
                        // 更新者名_姓
                        deviceSetInfo.getJSONObject("dia").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
                        // 更新者名_名
                        deviceSetInfo.getJSONObject("dia").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);

                      }
                      if (DeviceMode.HF.equals(editData.getDeviceMode())) {
                        deviceSetInfo.getJSONObject("ufr")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("291", "0");
                        deviceSetInfo.getJSONObject("ufr")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("292", "0");
                        deviceSetInfo.getJSONObject("ufr")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("293", "0");
                        deviceSetInfo.getJSONObject("ufr")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("294", "0");
                        deviceSetInfo.getJSONObject("ufr")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("295", "0");
                        deviceSetInfo.getJSONObject("ufr")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("296", "0");
                        deviceSetInfo.getJSONObject("ufr")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("297", "0");
                        deviceSetInfo.getJSONObject("ufr")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("298", "0");
                        deviceSetInfo.getJSONObject("ufr")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("299", "0");
                        deviceSetInfo.getJSONObject("ufr")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("300", "0");
                        // 指示者コード
                        deviceSetInfo.getJSONObject("ufr").put("ind_user_id", user.getUserId());
                        // 指示者名_姓
                        deviceSetInfo.getJSONObject("ufr").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
                        // 指示者名_名
                        deviceSetInfo.getJSONObject("ufr").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
                        // 更新者コード
                        deviceSetInfo.getJSONObject("ufr").put("upd_user_id", ntssUser.getUserId());
                        // 更新者名_姓
                        deviceSetInfo.getJSONObject("ufr").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
                        // 更新者名_名
                        deviceSetInfo.getJSONObject("ufr").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);

                        deviceSetInfo.getJSONObject("ihdf")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("432", "0");
                        // 指示者コード
                        deviceSetInfo.getJSONObject("ihdf").put("ind_user_id", user.getUserId());
                        // 指示者名_姓
                        deviceSetInfo.getJSONObject("ihdf").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
                        // 指示者名_名
                        deviceSetInfo.getJSONObject("ihdf").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
                        // 更新者コード
                        deviceSetInfo.getJSONObject("ihdf").put("upd_user_id", ntssUser.getUserId());
                        // 更新者名_姓
                        deviceSetInfo.getJSONObject("ihdf").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
                        // 更新者名_名
                        deviceSetInfo.getJSONObject("ihdf").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);

                        deviceSetInfo.getJSONObject("dia")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("282", "0");
                        // 指示者コード
                        deviceSetInfo.getJSONObject("dia").put("ind_user_id", user.getUserId());
                        // 指示者名_姓
                        deviceSetInfo.getJSONObject("dia").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
                        // 指示者名_名
                        deviceSetInfo.getJSONObject("dia").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
                        // 更新者コード
                        deviceSetInfo.getJSONObject("dia").put("upd_user_id", ntssUser.getUserId());
                        // 更新者名_姓
                        deviceSetInfo.getJSONObject("dia").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
                        // 更新者名_名
                        deviceSetInfo.getJSONObject("dia").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);

                      }
                      if (DeviceMode.AFBF.equals(editData.getDeviceMode())) {
                        deviceSetInfo.getJSONObject("ufr")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("291", "0");
                        deviceSetInfo.getJSONObject("ufr")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("292", "0");
                        deviceSetInfo.getJSONObject("ufr")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("293", "0");
                        deviceSetInfo.getJSONObject("ufr")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("294", "0");
                        deviceSetInfo.getJSONObject("ufr")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("295", "0");
                        deviceSetInfo.getJSONObject("ufr")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("296", "0");
                        deviceSetInfo.getJSONObject("ufr")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("297", "0");
                        deviceSetInfo.getJSONObject("ufr")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("298", "0");
                        deviceSetInfo.getJSONObject("ufr")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("299", "0");
                        deviceSetInfo.getJSONObject("ufr")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("300", "0");
                        // 指示者コード
                        deviceSetInfo.getJSONObject("ufr").put("ind_user_id", user.getUserId());
                        // 指示者名_姓
                        deviceSetInfo.getJSONObject("ufr").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
                        // 指示者名_名
                        deviceSetInfo.getJSONObject("ufr").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
                        // 更新者コード
                        deviceSetInfo.getJSONObject("ufr").put("upd_user_id", ntssUser.getUserId());
                        // 更新者名_姓
                        deviceSetInfo.getJSONObject("ufr").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
                        // 更新者名_名
                        deviceSetInfo.getJSONObject("ufr").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);

                        deviceSetInfo.getJSONObject("ihdf")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("432", "0");
                        // 指示者コード
                        deviceSetInfo.getJSONObject("ihdf").put("ind_user_id", user.getUserId());
                        // 指示者名_姓
                        deviceSetInfo.getJSONObject("ihdf").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
                        // 指示者名_名
                        deviceSetInfo.getJSONObject("ihdf").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
                        // 更新者コード
                        deviceSetInfo.getJSONObject("ihdf").put("upd_user_id", ntssUser.getUserId());
                        // 更新者名_姓
                        deviceSetInfo.getJSONObject("ihdf").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
                        // 更新者名_名
                        deviceSetInfo.getJSONObject("ihdf").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);

                        deviceSetInfo.getJSONObject("dia")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("282", "0");
                        // 指示者コード
                        deviceSetInfo.getJSONObject("dia").put("ind_user_id", user.getUserId());
                        // 指示者名_姓
                        deviceSetInfo.getJSONObject("dia").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
                        // 指示者名_名
                        deviceSetInfo.getJSONObject("dia").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
                        // 更新者コード
                        deviceSetInfo.getJSONObject("dia").put("upd_user_id", ntssUser.getUserId());
                        // 更新者名_姓
                        deviceSetInfo.getJSONObject("dia").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
                        // 更新者名_名
                        deviceSetInfo.getJSONObject("dia").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);

                        deviceSetInfo.getJSONObject("dc")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("340", "0");
                        // 指示者コード
                        deviceSetInfo.getJSONObject("dc").put("ind_user_id", user.getUserId());
                        // 指示者名_姓
                        deviceSetInfo.getJSONObject("dc").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
                        // 指示者名_名
                        deviceSetInfo.getJSONObject("dc").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
                        // 更新者コード
                        deviceSetInfo.getJSONObject("dc").put("upd_user_id", ntssUser.getUserId());
                        // 更新者名_姓
                        deviceSetInfo.getJSONObject("dc").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
                        // 更新者名_名
                        deviceSetInfo.getJSONObject("dc").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);


                        deviceSetInfo.getJSONObject("qbqd")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("431", "0");
                        deviceSetInfo.getJSONObject("qbqd")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("430", "0");
                        // 指示者コード
                        deviceSetInfo.getJSONObject("qbqd").put("ind_user_id", user.getUserId());
                        // 指示者名_姓
                        deviceSetInfo.getJSONObject("qbqd").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
                        // 指示者名_名
                        deviceSetInfo.getJSONObject("qbqd").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
                        // 更新者コード
                        deviceSetInfo.getJSONObject("qbqd").put("upd_user_id", ntssUser.getUserId());
                        // 更新者名_姓
                        deviceSetInfo.getJSONObject("qbqd").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
                        // 更新者名_名
                        deviceSetInfo.getJSONObject("qbqd").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);

                      }
                      if (DeviceMode.OHDF.equals(editData.getDeviceMode())) {
                        deviceSetInfo.getJSONObject("ufr")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("291", "0");
                        deviceSetInfo.getJSONObject("ufr")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("292", "0");
                        deviceSetInfo.getJSONObject("ufr")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("293", "0");
                        deviceSetInfo.getJSONObject("ufr")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("294", "0");
                        deviceSetInfo.getJSONObject("ufr")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("295", "0");
                        deviceSetInfo.getJSONObject("ufr")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("296", "0");
                        deviceSetInfo.getJSONObject("ufr")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("297", "0");
                        deviceSetInfo.getJSONObject("ufr")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("298", "0");
                        deviceSetInfo.getJSONObject("ufr")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("299", "0");
                        deviceSetInfo.getJSONObject("ufr")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("300", "0");
                        // 指示者コード
                        deviceSetInfo.getJSONObject("ufr").put("ind_user_id", user.getUserId());
                        // 指示者名_姓
                        deviceSetInfo.getJSONObject("ufr").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
                        // 指示者名_名
                        deviceSetInfo.getJSONObject("ufr").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
                        // 更新者コード
                        deviceSetInfo.getJSONObject("ufr").put("upd_user_id", ntssUser.getUserId());
                        // 更新者名_姓
                        deviceSetInfo.getJSONObject("ufr").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
                        // 更新者名_名
                        deviceSetInfo.getJSONObject("ufr").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);

                        deviceSetInfo.getJSONObject("ihdf")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("432", "0");
                        // 指示者コード
                        deviceSetInfo.getJSONObject("ihdf").put("ind_user_id", user.getUserId());
                        // 指示者名_姓
                        deviceSetInfo.getJSONObject("ihdf").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
                        // 指示者名_名
                        deviceSetInfo.getJSONObject("ihdf").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
                        // 更新者コード
                        deviceSetInfo.getJSONObject("ihdf").put("upd_user_id", ntssUser.getUserId());
                        // 更新者名_姓
                        deviceSetInfo.getJSONObject("ihdf").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
                        // 更新者名_名
                        deviceSetInfo.getJSONObject("ihdf").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);

                        deviceSetInfo.getJSONObject("dia")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("282", "0");
                        // 指示者コード
                        deviceSetInfo.getJSONObject("dia").put("ind_user_id", user.getUserId());
                        // 指示者名_姓
                        deviceSetInfo.getJSONObject("dia").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
                        // 指示者名_名
                        deviceSetInfo.getJSONObject("dia").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
                        // 更新者コード
                        deviceSetInfo.getJSONObject("dia").put("upd_user_id", ntssUser.getUserId());
                        // 更新者名_姓
                        deviceSetInfo.getJSONObject("dia").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
                        // 更新者名_名
                        deviceSetInfo.getJSONObject("dia").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);
                      }
                      if (DeviceMode.OHF.equals(editData.getDeviceMode())) {
                        deviceSetInfo.getJSONObject("ufr")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("291", "0");
                        deviceSetInfo.getJSONObject("ufr")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("292", "0");
                        deviceSetInfo.getJSONObject("ufr")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("293", "0");
                        deviceSetInfo.getJSONObject("ufr")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("294", "0");
                        deviceSetInfo.getJSONObject("ufr")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("295", "0");
                        deviceSetInfo.getJSONObject("ufr")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("296", "0");
                        deviceSetInfo.getJSONObject("ufr")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("297", "0");
                        deviceSetInfo.getJSONObject("ufr")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("298", "0");
                        deviceSetInfo.getJSONObject("ufr")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("299", "0");
                        deviceSetInfo.getJSONObject("ufr")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("300", "0");
                        // 指示者コード
                        deviceSetInfo.getJSONObject("ufr").put("ind_user_id", user.getUserId());
                        // 指示者名_姓
                        deviceSetInfo.getJSONObject("ufr").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
                        // 指示者名_名
                        deviceSetInfo.getJSONObject("ufr").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
                        // 更新者コード
                        deviceSetInfo.getJSONObject("ufr").put("upd_user_id", ntssUser.getUserId());
                        // 更新者名_姓
                        deviceSetInfo.getJSONObject("ufr").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
                        // 更新者名_名
                        deviceSetInfo.getJSONObject("ufr").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);

                        deviceSetInfo.getJSONObject("ihdf")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("432", "0");
                        // 指示者コード
                        deviceSetInfo.getJSONObject("ihdf").put("ind_user_id", user.getUserId());
                        // 指示者名_姓
                        deviceSetInfo.getJSONObject("ihdf").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
                        // 指示者名_名
                        deviceSetInfo.getJSONObject("ihdf").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
                        // 更新者コード
                        deviceSetInfo.getJSONObject("ihdf").put("upd_user_id", ntssUser.getUserId());
                        // 更新者名_姓
                        deviceSetInfo.getJSONObject("ihdf").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
                        // 更新者名_名
                        deviceSetInfo.getJSONObject("ihdf").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);


                        deviceSetInfo.getJSONObject("dia")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("282", "0");
                        // 指示者コード
                        deviceSetInfo.getJSONObject("dia").put("ind_user_id", user.getUserId());
                        // 指示者名_姓
                        deviceSetInfo.getJSONObject("dia").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
                        // 指示者名_名
                        deviceSetInfo.getJSONObject("dia").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
                        // 更新者コード
                        deviceSetInfo.getJSONObject("dia").put("upd_user_id", ntssUser.getUserId());
                        // 更新者名_姓
                        deviceSetInfo.getJSONObject("dia").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
                        // 更新者名_名
                        deviceSetInfo.getJSONObject("dia").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);
                      }
                      if (DeviceMode.PURIFICATION.equals(editData.getDeviceMode())) {
                        deviceSetInfo.getJSONObject("ufr")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("290", "0");
                        // 指示者コード
                        deviceSetInfo.getJSONObject("ufr").put("ind_user_id", user.getUserId());
                        // 指示者名_姓
                        deviceSetInfo.getJSONObject("ufr").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
                        // 指示者名_名
                        deviceSetInfo.getJSONObject("ufr").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
                        // 更新者コード
                        deviceSetInfo.getJSONObject("ufr").put("upd_user_id", ntssUser.getUserId());
                        // 更新者名_姓
                        deviceSetInfo.getJSONObject("ufr").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
                        // 更新者名_名
                        deviceSetInfo.getJSONObject("ufr").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);

                        deviceSetInfo.getJSONObject("na")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("315", "0");
                        // 指示者コード
                        deviceSetInfo.getJSONObject("na").put("ind_user_id", user.getUserId());
                        // 指示者名_姓
                        deviceSetInfo.getJSONObject("na").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
                        // 指示者名_名
                        deviceSetInfo.getJSONObject("na").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
                        // 更新者コード
                        deviceSetInfo.getJSONObject("na").put("upd_user_id", ntssUser.getUserId());
                        // 更新者名_姓
                        deviceSetInfo.getJSONObject("na").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
                        // 更新者名_名
                        deviceSetInfo.getJSONObject("na").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);

                        deviceSetInfo.getJSONObject("dc")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("340", "0");
                        // 指示者コード
                        deviceSetInfo.getJSONObject("dc").put("ind_user_id", user.getUserId());
                        // 指示者名_姓
                        deviceSetInfo.getJSONObject("dc").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
                        // 指示者名_名
                        deviceSetInfo.getJSONObject("dc").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
                        // 更新者コード
                        deviceSetInfo.getJSONObject("dc").put("upd_user_id", ntssUser.getUserId());
                        // 更新者名_姓
                        deviceSetInfo.getJSONObject("dc").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
                        // 更新者名_名
                        deviceSetInfo.getJSONObject("dc").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);

                        deviceSetInfo.getJSONObject("qbqd")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("430", "0");
                        deviceSetInfo.getJSONObject("qbqd")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("431", "0");
                        // 指示者コード
                        deviceSetInfo.getJSONObject("qbqd").put("ind_user_id", user.getUserId());
                        // 指示者名_姓
                        deviceSetInfo.getJSONObject("qbqd").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
                        // 指示者名_名
                        deviceSetInfo.getJSONObject("qbqd").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
                        // 更新者コード
                        deviceSetInfo.getJSONObject("qbqd").put("upd_user_id", ntssUser.getUserId());
                        // 更新者名_姓
                        deviceSetInfo.getJSONObject("qbqd").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
                        // 更新者名_名
                        deviceSetInfo.getJSONObject("qbqd").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);

                        deviceSetInfo.getJSONObject("ihdf")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("432", "0");
                        // 指示者コード
                        deviceSetInfo.getJSONObject("ihdf").put("ind_user_id", user.getUserId());
                        // 指示者名_姓
                        deviceSetInfo.getJSONObject("ihdf").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
                        // 指示者名_名
                        deviceSetInfo.getJSONObject("ihdf").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
                        // 更新者コード
                        deviceSetInfo.getJSONObject("ihdf").put("upd_user_id", ntssUser.getUserId());
                        // 更新者名_姓
                        deviceSetInfo.getJSONObject("ihdf").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
                        // 更新者名_名
                        deviceSetInfo.getJSONObject("ihdf").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);

                        deviceSetInfo.getJSONObject("bvufc")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("196", "0");
                        // 指示者コード
                        deviceSetInfo.getJSONObject("bvufc").put("ind_user_id", user.getUserId());
                        // 指示者名_姓
                        deviceSetInfo.getJSONObject("bvufc").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
                        // 指示者名_名
                        deviceSetInfo.getJSONObject("bvufc").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
                        // 更新者コード
                        deviceSetInfo.getJSONObject("bvufc").put("upd_user_id", ntssUser.getUserId());
                        // 更新者名_姓
                        deviceSetInfo.getJSONObject("bvufc").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
                        // 更新者名_名
                        deviceSetInfo.getJSONObject("bvufc").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);

                        deviceSetInfo.getJSONObject("dia")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("282", "0");
                        // 指示者コード
                        deviceSetInfo.getJSONObject("dia").put("ind_user_id", user.getUserId());
                        // 指示者名_姓
                        deviceSetInfo.getJSONObject("dia").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
                        // 指示者名_名
                        deviceSetInfo.getJSONObject("dia").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
                        // 更新者コード
                        deviceSetInfo.getJSONObject("dia").put("upd_user_id", ntssUser.getUserId());
                        // 更新者名_姓
                        deviceSetInfo.getJSONObject("dia").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
                        // 更新者名_名
                        deviceSetInfo.getJSONObject("dia").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);
                      }
                      if (DeviceMode.I_HDF.equals(editData.getDeviceMode())) {
                        deviceSetInfo.getJSONObject("ufr")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("290", "0");
                        deviceSetInfo.getJSONObject("ufr")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("291", "0");
                        deviceSetInfo.getJSONObject("ufr")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("292", "0");
                        deviceSetInfo.getJSONObject("ufr")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("293", "0");
                        deviceSetInfo.getJSONObject("ufr")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("294", "0");
                        deviceSetInfo.getJSONObject("ufr")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("295", "0");
                        deviceSetInfo.getJSONObject("ufr")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("296", "0");
                        deviceSetInfo.getJSONObject("ufr")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("297", "0");
                        deviceSetInfo.getJSONObject("ufr")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("298", "0");
                        deviceSetInfo.getJSONObject("ufr")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("299", "0");
                        deviceSetInfo.getJSONObject("ufr")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("300", "0");
                        // 指示者コード
                        deviceSetInfo.getJSONObject("ufr").put("ind_user_id", user.getUserId());
                        // 指示者名_姓
                        deviceSetInfo.getJSONObject("ufr").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
                        // 指示者名_名
                        deviceSetInfo.getJSONObject("ufr").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
                        // 更新者コード
                        deviceSetInfo.getJSONObject("ufr").put("upd_user_id", ntssUser.getUserId());
                        // 更新者名_姓
                        deviceSetInfo.getJSONObject("ufr").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
                        // 更新者名_名
                        deviceSetInfo.getJSONObject("ufr").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);

                        deviceSetInfo.getJSONObject("qbqd")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("430", "0");
                        deviceSetInfo.getJSONObject("qbqd")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("431", "0");
                        // 指示者コード
                        deviceSetInfo.getJSONObject("qbqd").put("ind_user_id", user.getUserId());
                        // 指示者名_姓
                        deviceSetInfo.getJSONObject("qbqd").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
                        // 指示者名_名
                        deviceSetInfo.getJSONObject("qbqd").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
                        // 更新者コード
                        deviceSetInfo.getJSONObject("qbqd").put("upd_user_id", ntssUser.getUserId());
                        // 更新者名_姓
                        deviceSetInfo.getJSONObject("qbqd").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
                        // 更新者名_名
                        deviceSetInfo.getJSONObject("qbqd").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);

                        deviceSetInfo.getJSONObject("bvufc")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("196", "0");
                        // 指示者コード
                        deviceSetInfo.getJSONObject("bvufc").put("ind_user_id", user.getUserId());
                        // 指示者名_姓
                        deviceSetInfo.getJSONObject("bvufc").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
                        // 指示者名_名
                        deviceSetInfo.getJSONObject("bvufc").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
                        // 更新者コード
                        deviceSetInfo.getJSONObject("bvufc").put("upd_user_id", ntssUser.getUserId());
                        // 更新者名_姓
                        deviceSetInfo.getJSONObject("bvufc").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
                        // 更新者名_名
                        deviceSetInfo.getJSONObject("bvufc").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);

                        deviceSetInfo.getJSONObject("dia")
                          .getJSONObject("dev")
                          .getJSONObject("A")
                          .put("282", "0");
                        // 指示者コード
                        deviceSetInfo.getJSONObject("dia").put("ind_user_id", user.getUserId());
                        // 指示者名_姓
                        deviceSetInfo.getJSONObject("dia").put("ind_user_last_name", user != null ? user.getUserLastName() : JSONObject.NULL);
                        // 指示者名_名
                        deviceSetInfo.getJSONObject("dia").put("ind_user_first_name", user != null ? user.getUserFirstName() : JSONObject.NULL);
                        // 更新者コード
                        deviceSetInfo.getJSONObject("dia").put("upd_user_id", ntssUser.getUserId());
                        // 更新者名_姓
                        deviceSetInfo.getJSONObject("dia").put("upd_user_last_name", updUser != null ? updUser.getUserLastName() : JSONObject.NULL);
                        // 更新者名_名
                        deviceSetInfo.getJSONObject("dia").put("upd_user_first_name", updUser != null ? updUser.getUserFirstName() : JSONObject.NULL);
                      }
                      updateData.setIndDeviceSetInfo(deviceSetInfo.toString());
                    }
                    break;
                }
                if (null != errStr) {
                  EventLogMessage eventLogMessage = new EventLogMessage();
                  eventLogMessage.setLogMessage("患者治療パターンの更新データに異常があるため処理を中断しました:"
                    + "[更新条件:"
                    + "患者ID=" + patId
                    + "、管理番号=" + patId
                    + "]、"
                    + "[更新データ:" + errStr
                    + "]");
                  logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
                  // ロールバック実行
                  throw new RuntimeException();
                }
              }
              // 更新処理実施
              updateData.setCtlNo(registData.get(0).getCtlNo());
              updateData.setPatId(patId);
              updateDataList.add(updateData);
            } else {
              EventLogMessage eventLogMessage = new EventLogMessage();
              eventLogMessage.setLogMessage("患者治療パターンの更新元データに異常があるため処理をスキップしました:"
                + "[抽出条件:"
                + "患者ID=" + patId
                + "、施設コード=" + facilityCd
                + "、治療方法コード=" + searchTreatmentCd
                + "、クールコード=" + searchIndKurCd
                + "、曜日番号=" + searchWeek
                + "]、"
                + "[抽出件数:" + registData.size()
                + "]");
              logService.log(LogLevel.WARN, eventLogMessage,"",SERVICE_NAME.FNSI, null);
            }
          }
        }
      }
      if(!updateDataList.isEmpty()){
        List<Long> ctlNoList = updateDataList.stream().map(PatTreatmentPattern::getCtlNo).collect(Collectors.toList());
        Long patIdSr = updateDataList.get(0).getPatId();
        String tableName = "pat_treatment_pattern";
        // SQL検索条件
        String inStr = getInStr("ctl_no in ", ctlNoList);
        StringBuffer wheres = new StringBuffer("");
        wheres.append(" WHERE\n");
        wheres.append(inStr + "\n");
        wheres.append("AND pat_id = '" + patIdSr + "'\n");
        // logCommon設定
        DataUpdateLogCommonNew logCommon = getLogCommon(tableName, wheres, getEventLogMessage());
        // ログ出力カラム情報及び更新前データ情報取得
        boolean setResult = logCommon.setInfo();
        // DB更新ログ出力ロジック wangzuo End
        try {
          updateCount = patTreatmentPatternDao.updateByIdListWithTreatCondSetting(updateDataList);
        } catch (Exception e) {
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
          if (!StringUtils.isEmpty(facilityCd)) {
            eventLogMessage.setFacilityCd(facilityCd);
          }
          logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
        }
        // 更新後データ取得、差分あれば、log出力
        if (setResult && updateCount > 0) {
          logCommon.setAfterResults();
          asyncService.updateLog(logCommon);
        }
      }
    } catch(Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("患者治療パターン項目更新処理に失敗しました:" + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      // ロールバック実行
      throw new RuntimeException();
    }

    return updateCount;
  }
  /**
   * 治療方法セットの変更 患者治療パターン項目更新
   * @param patId 抽出データ（処理対象患者の患者ID）
   * @param facilityCd 抽出データ（処理対象施設の施設コード）
   * @param indTreatmentCdList 抽出データ（処理対象治療予定の指示：治療方法コード）  ※全治療方法指定の場合はnull設定
   * @param indKurCdList 抽出データ（処理対象治療予定の指示：クールコード） ※全クール指定の場合はnull設定
   * @param weekPatternList 抽出データ（処理対象治療予定の曜日パターン:処理を実施する曜日番号リスト）  ※全曜日指定の場合はnull設定
   * @param updateIndItemList 更新対象指示項目リスト
   * @param upDate 更新日時
   * @param editData 編集データ ※更新したいデータ(画面単位のデータ)のみを設定
   * @return 処理件数(失敗時は「-1」)
   */
  @Transactional
  public int updatePatTreatmentPatternIndItemForTreatSet(
    Long patId,
    String facilityCd,
    List<Integer> indTreatmentCdList,
    List<Long> indKurCdList,
    List<Integer> weekPatternList,
    List<IND_ITEM> updateIndItemList,
    Timestamp upDate,
    PatTreatmentPatternEditData editData
  ) {
    int updateCount = -1;
    try {
      // 変更対象の患者治療パターン検索
      List<PatTreatmentPattern> beforeData = this.searchPatTreatmentPattern(patId, facilityCd, indTreatmentCdList, indKurCdList, weekPatternList);
      indTreatmentCdList = beforeData.stream().map(item -> item.getIndTreatmentCd()).distinct().collect(Collectors.toList());
      indKurCdList = beforeData.stream().map(item -> item.getIndKurCd()).distinct().collect(Collectors.toList());
      weekPatternList = beforeData.stream().map(item -> item.getTreatWeek().intValue()).distinct().collect(Collectors.toList());
      List<PatTreatmentPattern> updateDataList = new LinkedList<>();
      // 患者治療パターン更新
      for (int i = 0; i < indTreatmentCdList.size(); i++) {
        for (int j = 0; j < indKurCdList.size(); j++) {
          for (int k = 0; k < weekPatternList.size(); k++) {
            // 発行条件の治療方法、クール、曜日から更新元データを抽出
            Integer searchTreatmentCd = indTreatmentCdList.get(i);
            Long searchIndKurCd = indKurCdList.get(j);
            Integer searchWeek = weekPatternList.get(k);
            List<PatTreatmentPattern> registData = beforeData.stream().filter(info ->
              searchTreatmentCd.equals(info.getIndTreatmentCd()) &&
                searchIndKurCd.equals(info.getIndKurCd()) &&
                searchWeek.equals((int)info.getTreatWeek())
            ).collect(Collectors.toList());
            if (1 == registData.size()) {
              // 更新データ作成
              PatTreatmentPattern updateData = new PatTreatmentPattern();
              String errStr = null;
              updateData.setUpDate(upDate);
              for (int l = 0; l < updateIndItemList.size(); l++) {
                IND_ITEM updateIndItem = updateIndItemList.get(l);
                switch (updateIndItem) {
                  case TREATMENT:
                    if (null != editData.getIndTreatmentCd()) {
                      updateData.setIndTreatmentCd(editData.getIndTreatmentCd());
                    } else {
                      errStr = "治療方法=null";
                    }
                    break;
                  case KUR:
                    if (null != editData.getIndKurCd()) {
                      updateData.setIndKurCd(editData.getIndKurCd());
                    } else {
                      errStr = "クール=null";
                    }
                    break;
                  case SCHE:
                    //mod #11061 患者経過総合ビューア＞スケジュール編集でベッドのプルダウンリスト展開でDB負荷が高くシステムが操作不可となる。(恒久対応) zkm start
                    if (null != registData.get(0).getIndSchInfo()) {
                      updateData.setIndSchInfo(registData.get(0).getIndSchInfo());
                    } else if (null != editData.getIndSchInfo()) {
//                  if (null != editData.getIndSchInfo()) {
                    //mod #11061 患者経過総合ビューア＞スケジュール編集でベッドのプルダウンリスト展開でDB負荷が高くシステムが操作不可となる。(恒久対応) zkm end
                      updateData.setIndSchInfo(editData.getIndSchInfo());
                    } else {
                      errStr = "スケジュール=null";
                    }
                    break;
                  case COND:
                    if (null != editData.getIndCondInfo()) {
                      JSONObject indCondInfo = new JSONObject(editData.getIndCondInfo());
                      JSONObject beforeIndCondInfo = new JSONObject(registData.get(0).getIndCondInfo());
                      if (beforeIndCondInfo.has("3") && indCondInfo.has("3"))
                      indCondInfo.put("3", beforeIndCondInfo.getJSONObject("3"));

                      updateData.setIndCondInfo(indCondInfo.toString());
                    } else {
                      errStr = "治療条件=null";
                    }
                    break;
                  case MEDI:
                    if (null != editData.getIndMediInfo()) {
                      try {
                        updateData.setIndMediInfo(editData.getIndMediInfo());
                      } catch (Exception e) {
                        EventLogMessage eventLogMessage = new EventLogMessage();
                        eventLogMessage.setLogMessage(e.getMessage());
                        logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
                        errStr = "投与薬剤=" + editData.getIndMediInfo();
                      }
                    } else {
                      errStr = "投与薬剤=null";
                    }
                    break;
                  case EQUIP:
                    if (null != editData.getIndEquipInfo()) {
                      try {
                        updateData.setIndEquipInfo(editData.getIndEquipInfo());
                      } catch (Exception e) {
                        EventLogMessage eventLogMessage = new EventLogMessage();
                        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
                        if (facilityCd != null) {
                          eventLogMessage.setFacilityCd(facilityCd);
                        }
                        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
                        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
                        logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
                        errStr = "医療材料=" + editData.getIndMediInfo();
                      }
                    } else {
                      errStr = "医療材料=null";
                    }
                    break;
                  case IND_COMMENT:
                    if (null != editData.getIndIndCommentInfo()) {
                      try {
                        updateData.setIndIndCommentInfo(editData.getIndIndCommentInfo());
                      } catch (Exception e) {
                        EventLogMessage eventLogMessage = new EventLogMessage();
                        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
                        if (facilityCd != null) {
                          eventLogMessage.setFacilityCd(facilityCd);
                        }
                        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
                        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
                        logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
                        errStr = "指示コメント=" + editData.getIndIndCommentInfo();
                      }
                    } else {
                      errStr = "指示コメント=null";
                    }
                    break;
                  case TARE:
                    if (null != editData.getIndTareInfo()) {
                      updateData.setIndTareInfo(editData.getIndTareInfo());
                    } else {
                      errStr = "風体=null";
                    }
                    break;
                  case OFF_WATER:
                    if (null != editData.getIndOffWaterInfo()) {
                      updateData.setIndOffWaterInfo(editData.getIndOffWaterInfo());
                    } else {
                      errStr = "除水=null";
                    }
                    break;
                  case DEVICE_SET_INFO:
                    if (null != editData.getIndDeviceSetInfo()) {
                      updateData.setIndDeviceSetInfo(editData.getIndDeviceSetInfo());
                    } else {
                      errStr = "装置設定=null";
                    }
                    break;
                }
                if (null != errStr) {
                  EventLogMessage eventLogMessage = new EventLogMessage();
                  eventLogMessage.setLogMessage("患者治療パターンの更新データに異常があるため処理を中断しました:"
                    + "[更新条件:"
                    + "患者ID=" + patId
                    + "、管理番号=" + patId
                    + "]、"
                    + "[更新データ:" + errStr
                    + "]");
                  logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
                  // ロールバック実行
                  throw new RuntimeException();
                }
              }
              // 更新処理実施
              updateData.setCtlNo(registData.get(0).getCtlNo());
              updateData.setPatId(patId);
              updateDataList.add(updateData);
            } else {
              EventLogMessage eventLogMessage = new EventLogMessage();
              eventLogMessage.setLogMessage("患者治療パターンの更新元データに異常があるため処理をスキップしました:"
                + "[抽出条件:"
                + "患者ID=" + patId
                + "、施設コード=" + facilityCd
                + "、治療方法コード=" + searchTreatmentCd
                + "、クールコード=" + searchIndKurCd
                + "、曜日番号=" + searchWeek
                + "]、"
                + "[抽出件数:" + registData.size()
                + "]");
              logService.log(LogLevel.WARN, eventLogMessage,"",SERVICE_NAME.FNSI, null);
            }
          }
        }
      }
      if(!updateDataList.isEmpty()){
        List<Long> ctlNoList = updateDataList.stream().map(PatTreatmentPattern::getCtlNo).collect(Collectors.toList());
        Long patIdSr = updateDataList.get(0).getPatId();
        String tableName = "pat_treatment_pattern";
        // SQL検索条件
        String inStr = getInStr("ctl_no in ", ctlNoList);
        StringBuffer wheres = new StringBuffer("");
        wheres.append(" WHERE\n");
        wheres.append(inStr + "\n");
        wheres.append("AND pat_id = '" + patIdSr + "'\n");
        // logCommon設定
        DataUpdateLogCommonNew logCommon = getLogCommon(tableName, wheres, getEventLogMessage());
        // ログ出力カラム情報及び更新前データ情報取得
        boolean setResult = logCommon.setInfo();
        try {
          updateCount = patTreatmentPatternDao.updateByIdListWithTreatCondSetting(updateDataList);
        } catch (Exception e) {
 // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
          if (!StringUtils.isEmpty(facilityCd)) {
            eventLogMessage.setFacilityCd(facilityCd);
          }
          logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
        }
        // 更新後データ取得、差分あれば、log出力
        if (setResult && updateCount > 0) {
          logCommon.setAfterResults();
          asyncService.updateLog(logCommon);
        }
      }
    } catch(Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("患者治療パターン項目更新処理に失敗しました:" + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      // ロールバック実行
      throw new RuntimeException();
    }

    return updateCount;
  }
  // add 9281 日次処理にて正しくスケジュールが作成されない事がある 関 end
  /**
   * 検索条件 IN情報
   *
   * @param fieldInfo カラム情報
   * @param inList    IN値リスト
   * @return inStr
   */
  public <T> String getInStr(String fieldInfo, List<T> inList) {
    StringBuffer inStr = new StringBuffer("");
    inStr.append(fieldInfo);
    inStr.append(" ( ");
    for (T obj : inList) {
      inStr.append(obj);
      inStr.append(" ,");
    }
    inStr.deleteCharAt(inStr.length() - 1);
    inStr.append(" ) ");
    return String.valueOf(inStr);
  }
  // DB更新ログ出力ロジック wangzuo End
//upd by ztc 2023-03-13 [Batch modify data, log_event table has no data and the user is null No.6067] --end /
  /**
   * Jsonデータを対象データに更新(既存データが存在しない場合は追加)
   * @param pk 一意検索条件キー
   * @param base 元データ
   * @param edit 登録データ
   * @return 対象データ追加後のJsonデータ
   */
  private String updateJsonData(String pk, String base, String edit) {
    // 元データ
    /*#10757 mod コンバートされた治療方法セットで指示が作成できない 2024-06-26 卓 start*/
    //JSONArray baseDataList = new JSONArray(base);
    JSONArray baseDataList = new JSONArray(ObjectUtils.isEmpty(base)? "[]" : base);
    // 登録データ
    JSONArray editDataList = new JSONArray(ObjectUtils.isEmpty(edit)? "[]" : edit);
    /*#10757 mod コンバートされた治療方法セットで指示が作成できない 2024-06-26 卓 end*/
    // 元データに登録データを追加
    for (int j = 0; j < editDataList.length(); j++) {
      for (int i = baseDataList.length() - 1; i >= 0; i--) {
        // 一意検索条件キーが一致するデータが存在した場合は以下の処理を実施
        if (baseDataList.getJSONObject(i).get(pk).toString().equals(editDataList.getJSONObject(j).get(pk).toString())) {
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage("既存データが存在したため患者治療パターン項目更新処理で置換しました:[置換前データ=" + baseDataList.getJSONObject(i) + "]、[置換後データ=" + editDataList.getJSONObject(j) +"]");
          logService.log(LogLevel.INFO, eventLogMessage,"",SERVICE_NAME.FNSI, null);
          baseDataList.put(i, editDataList.getJSONObject(j));
          break;
        }
      }
    }
    return baseDataList.toString();
  }

  /**
   * 患者治療パターン項目削除(指示:投与薬剤、指示:医療材料、指示:指示コメント削除用)
   * @param patId 抽出データ（処理対象患者の患者ID）
   * @param facilityCd 抽出データ（処理対象施設の施設コード）
   * @param indTreatmentCdList 抽出データ（処理対象治療予定の指示：治療方法コード）  ※全治療方法指定の場合はnull設定
   * @param indKurCdList 抽出データ（処理対象治療予定の指示：クールコード） ※全クール指定の場合はnull設定
   * @param weekPatternList 抽出データ（処理対象治療予定の曜日パターン:処理を実施する曜日番号リスト）  ※全曜日指定の場合はnull設定
   * @param updateIndItem 削除対象指示項目
   * @param upDate 更新日時
   * @param editData 削除データ ※削除したいデータのみを設定
   * @return 処理件数(失敗時は「-1」)
   */
  @Transactional
  public int deletePatTreatmentPatternIndItemForIndMediAndEquip(
      Long patId,
      String facilityCd,
      List<Integer> indTreatmentCdList,
      List<Long> indKurCdList,
      List<Integer> weekPatternList,
      IND_ITEM updateIndItem,
      Timestamp upDate,
      PatTreatmentPatternEditData editData
    ) {
    int updateCount = -1;
    if (null == indTreatmentCdList) indTreatmentCdList = new ArrayList<Integer>();
    if (null == indKurCdList) indKurCdList = new ArrayList<Long>();
    if (null == weekPatternList) weekPatternList = new ArrayList<Integer>();
    try {
      // 変更対象の患者治療パターン検索
      List<PatTreatmentPattern> beforeData = this.searchPatTreatmentPattern(patId, facilityCd, indTreatmentCdList, indKurCdList, weekPatternList);
      indTreatmentCdList = beforeData.stream().map(item -> item.getIndTreatmentCd()).distinct().collect(Collectors.toList());
      indKurCdList = beforeData.stream().map(item -> item.getIndKurCd()).distinct().collect(Collectors.toList());
      weekPatternList = beforeData.stream().map(item -> item.getTreatWeek().intValue()).distinct().collect(Collectors.toList());
      // 患者治療パターン更新
      for (int i = 0; i < indTreatmentCdList.size(); i++) {
        for (int j = 0; j < indKurCdList.size(); j++) {
          for (int k = 0; k < weekPatternList.size(); k++) {
            // 発行条件の治療方法、クール、曜日から更新元データを抽出
            Integer searchTreatmentCd = indTreatmentCdList.get(i);
            Long searchIndKurCd = indKurCdList.get(j);
            Integer searchWeek = weekPatternList.get(k);
            List<PatTreatmentPattern> registData = beforeData.stream().filter(info ->
                                        info.getIndTreatmentCd().equals(searchTreatmentCd) &&
                                        info.getIndKurCd().equals(searchIndKurCd) &&
                                        (int)info.getTreatWeek() == searchWeek
                                      ).collect(Collectors.toList());
            if (1 == registData.size()) {
              // 更新データ作成
              PatTreatmentPattern updateData = new PatTreatmentPattern();
              String errStr = null;
              updateData.setUpDate(upDate);
              switch (updateIndItem) {
                case MEDI:
                  if (null != editData.getIndMediInfo()) {
                    try {
                      // 元データから削除データを除去
                      updateData.setIndMediInfo(this.deleteJsonData("no", registData.get(0).getIndMediInfo(), editData.getIndMediInfo()));
                    } catch (Exception e) {
                      EventLogMessage eventLogMessage = new EventLogMessage();
                      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
                      if (facilityCd != null) {
                        eventLogMessage.setFacilityCd(facilityCd);
                      }
                      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
                      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
                      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
                      errStr = "投与薬剤=" + editData.getIndMediInfo();
                    }
                  } else {
                    errStr = "投与薬剤=null";
                  }
                  break;
                case EQUIP:
                  if (null != editData.getIndEquipInfo()) {
                    try {
                      // 元データから削除データを除去
                      updateData.setIndEquipInfo(this.deleteJsonData("cd", registData.get(0).getIndEquipInfo(), editData.getIndEquipInfo()));
                    } catch (Exception e) {
                      EventLogMessage eventLogMessage = new EventLogMessage();
                      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
                      if (facilityCd != null) {
                        eventLogMessage.setFacilityCd(facilityCd);
                      }
                      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
                      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
                      errStr = "医療材料=" + editData.getIndMediInfo();
                    }
                  } else {
                    errStr = "医療材料=null";
                  }
                  break;
                case IND_COMMENT:
                  if (null != editData.getIndIndCommentInfo()) {
                    try {
                      // 元データから削除データを除去
                      updateData.setIndIndCommentInfo(this.deleteJsonData("no", registData.get(0).getIndIndCommentInfo(), editData.getIndIndCommentInfo()));
                    } catch (Exception e) {
                      EventLogMessage eventLogMessage = new EventLogMessage();
                      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
                      if (facilityCd != null) {
                        eventLogMessage.setFacilityCd(facilityCd);
                      }
                      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
                      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
                      errStr = "指示コメント=" + editData.getIndIndCommentInfo();
                    }
                  } else {
                    errStr = "指示コメント=null";
                  }
                  break;
                default:
                  errStr = "更新不可項目指定";
                  break;
              }
              if (null != errStr) {
                EventLogMessage eventLogMessage = new EventLogMessage();
                eventLogMessage.setLogMessage("患者治療パターンの削除データに異常があるため処理を中断しました:"
                + "[更新条件:"
                + "患者ID=" + patId
                + "、管理番号=" + patId
                + "]、"
                + "[削除データ:" + errStr
                + "]");
                logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
                // ロールバック実行
                throw new RuntimeException();
              }
              // 更新処理実施
              updateCount = patTreatmentPatternDao.updateById(patId, registData.get(0).getCtlNo(), updateData);
            } else {
              EventLogMessage eventLogMessage = new EventLogMessage();
              eventLogMessage.setLogMessage("患者治療パターンの更新元データに異常があるため処理をスキップしました:"
              + "[抽出条件:"
              + "患者ID=" + patId
              + "、施設コード=" + facilityCd
              + "、治療方法コード=" + searchTreatmentCd
              + "、クールコード=" + searchIndKurCd
              + "、曜日番号=" + searchWeek
              + "]、"
              + "[抽出件数:" + registData.size()
              + "]");
              logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
            }
          }
        }
      }
    } catch(Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("患者治療パターン項目削除処理に失敗しました:" + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      // ロールバック実行
      throw new RuntimeException();
    }

    return updateCount;
  }

  /**
   * Jsonデータから対象データを除去
   * @param pk 一意検索条件キー
   * @param base 元データ
   * @param edit 削除データ
   * @return 対象データ除去後のJsonデータ
   */
  private String deleteJsonData(String pk, String base, String edit) {
    // 元データ
    /*#10757 mod コンバートされた治療方法セットで指示が作成できない 2024-06-26 卓 start*/
    //JSONArray baseDataList = new JSONArray(base);
    JSONArray baseDataList = new JSONArray(ObjectUtils.isEmpty(base)? "[]" : base);
    // 削除データ
    JSONArray editDataList = new JSONArray(ObjectUtils.isEmpty(edit)? "[]" : edit);
    /*#10757 mod コンバートされた治療方法セットで指示が作成できない 2024-06-26 卓 end*/
    // 元データから削除データを除去
    List<String> delDataList = new ArrayList<String>();
    for (int j = 0; j < editDataList.length(); j++) {
      Boolean delProcFlg = false;
      for (int i = baseDataList.length() - 1; i >= 0; i--) {
        // 一意検索条件キーが一致するデータが存在した場合は以下の処理を実施
        if (baseDataList.getJSONObject(i).get(pk).toString().equals(editDataList.getJSONObject(j).get(pk).toString())) {
          baseDataList.remove(i);
          delProcFlg = true;
          break;
        }
      }
      if (false == delProcFlg) {
        delDataList.add(editDataList.getJSONObject(j).toString());
      }
    }
    if (0 != delDataList.size()) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("該当データが存在しないため患者治療パターン項目削除処理を実施できませんでした:[元データ=" + base + "]、[削除データ=" + delDataList +"]");
      logService.log(LogLevel.WARN, eventLogMessage,"",SERVICE_NAME.FNSI, null);
    }

    return baseDataList.toString();
  }

  /**
   * 患者治療パターン項目登録(指示:投与薬剤、指示:医療材料(医療材料コード変更時含む)、指示:指示コメント登録用)
   * @param patId 抽出データ（処理対象患者の患者ID）
   * @param facilityCd 抽出データ（処理対象施設の施設コード）
   * @param indTreatmentCdList 抽出データ（処理対象治療予定の指示：治療方法コード）  ※全治療方法指定の場合はnull設定
   * @param indKurCdList 抽出データ（処理対象治療予定の指示：クールコード） ※全クール指定の場合はnull設定
   * @param weekPatternList 抽出データ（処理対象治療予定の曜日パターン:処理を実施する曜日番号リスト）  ※全曜日指定の場合はnull設定
   * @param updateIndItem 更新対象指示項目
   * @param upDate 更新日時
   * @param editData 新規登録データ ※新規登録したいデータのみを設定
   * @return 処理件数(失敗時は「-1」)
   */
  @Transactional
  public int insertPatTreatmentPatternIndItemForIndMediAndEquip(
      Long patId,
      String facilityCd,
      List<Integer> indTreatmentCdList,
      List<Long> indKurCdList,
      List<Integer> weekPatternList,
      IND_ITEM updateIndItem,
      Timestamp upDate,
      PatTreatmentPatternEditData editData
    ) {
    int updateCount = -1;
    if (null == indTreatmentCdList) indTreatmentCdList = new ArrayList<Integer>();
    if (null == indKurCdList) indKurCdList = new ArrayList<Long>();
    if (null == weekPatternList) weekPatternList = new ArrayList<Integer>();
    try {
      // 変更対象の患者治療パターン検索
      List<PatTreatmentPattern> beforeData = this.searchPatTreatmentPattern(patId, facilityCd, indTreatmentCdList, indKurCdList, weekPatternList);
      indTreatmentCdList = beforeData.stream().map(item -> item.getIndTreatmentCd()).distinct().collect(Collectors.toList());
      indKurCdList = beforeData.stream().map(item -> item.getIndKurCd()).distinct().collect(Collectors.toList());
      weekPatternList = beforeData.stream().map(item -> item.getTreatWeek().intValue()).distinct().collect(Collectors.toList());
      // 患者治療パターン更新
      for (int i = 0; i < indTreatmentCdList.size(); i++) {
        for (int j = 0; j < indKurCdList.size(); j++) {
          for (int k = 0; k < weekPatternList.size(); k++) {
            // 発行条件の治療方法、クール、曜日から更新元データを抽出
            Integer searchTreatmentCd = indTreatmentCdList.get(i);
            Long searchIndKurCd = indKurCdList.get(j);
            Integer searchWeek = weekPatternList.get(k);
            List<PatTreatmentPattern> registData = beforeData.stream().filter(info ->
                                        info.getIndTreatmentCd().equals(searchTreatmentCd) &&
                                        info.getIndKurCd().equals(searchIndKurCd) &&
                                        (int)info.getTreatWeek() == searchWeek
                                      ).collect(Collectors.toList());
            if (1 == registData.size()) {
              // 更新データ作成
              PatTreatmentPattern updateData = new PatTreatmentPattern();
              String errStr = null;
              updateData.setUpDate(upDate);
              switch (updateIndItem) {
                case MEDI:
                  if (null != editData.getIndMediInfo()) {
                    try {
                      // 元データに登録データを追加
                      updateData.setIndMediInfo(this.insertJsonData("no", registData.get(0).getIndMediInfo(), editData.getIndMediInfo(), false));
                    } catch (Exception e) {
                      EventLogMessage eventLogMessage = new EventLogMessage();
                      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
                      if (facilityCd != null) {
                        eventLogMessage.setFacilityCd(facilityCd);
                      }
                      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
                      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
                      errStr = "投与薬剤=" + editData.getIndMediInfo();
                    }
                  } else {
                    errStr = "投与薬剤=null";
                  }
                  break;
                case EQUIP:
                  if (null != editData.getIndEquipInfo()) {
                    try {
                      // mod 10744 医療材料の穴埋め追加によるpat_treatment_patternへの追加処理が不正 関 start
                      boolean autoInsertFlag = false;
                      if ("1".equals(editData.getAutoInsert())) {
                        autoInsertFlag = this.beforeDataExist("cd", registData.get(0).getIndEquipInfo(), editData.getIndEquipInfo());
                      }
                      // 元データに登録データを追加
                      if (!autoInsertFlag) {
                        updateData.setIndEquipInfo(this.insertJsonData("cd", registData.get(0).getIndEquipInfo(), editData.getIndEquipInfo(), true));
                      }
                      // mod 10744 医療材料の穴埋め追加によるpat_treatment_patternへの追加処理が不正 関 end
                    } catch (Exception e) {
                      EventLogMessage eventLogMessage = new EventLogMessage();
                      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
                      if (facilityCd != null) {
                        eventLogMessage.setFacilityCd(facilityCd);
                      }
                      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
                      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
                      errStr = "医療材料=" + editData.getIndMediInfo();
                    }
                  } else {
                    errStr = "医療材料=null";
                  }
                  break;
                case IND_COMMENT:
                  if (null != editData.getIndIndCommentInfo()) {
                    try {
                      // 元データに登録データを追加
                      updateData.setIndIndCommentInfo(this.insertJsonData("no", registData.get(0).getIndIndCommentInfo(), editData.getIndIndCommentInfo(), false));
                    } catch (Exception e) {
                      EventLogMessage eventLogMessage = new EventLogMessage();
                      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
                      if (facilityCd != null) {
                        eventLogMessage.setFacilityCd(facilityCd);
                      }
                      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
                      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
                      errStr = "指示コメント=" + editData.getIndIndCommentInfo();
                    }
                  } else {
                    errStr = "指示コメント=null";
                  }
                  break;
                default:
                  errStr = "更新不可項目指定";
                  break;
              }
              if (null != errStr) {
                EventLogMessage eventLogMessage = new EventLogMessage();
                eventLogMessage.setLogMessage("患者治療パターンの登録データに異常があるため処理を中断しました:"
                + "[更新条件:"
                + "患者ID=" + patId
                + "、管理番号=" + patId
                + "]、"
                + "[登録データ:" + errStr
                + "]");
                logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
                // ロールバック実行
                throw new RuntimeException();
              }
              // 更新処理実施
              updateCount = patTreatmentPatternDao.updateById(patId, registData.get(0).getCtlNo(), updateData);
            } else {
              EventLogMessage eventLogMessage = new EventLogMessage();
              eventLogMessage.setLogMessage("患者治療パターンの更新元データに異常があるため処理をスキップしました:"
              + "[抽出条件:"
              + "患者ID=" + patId
              + "、施設コード=" + facilityCd
              + "、治療方法コード=" + searchTreatmentCd
              + "、クールコード=" + searchIndKurCd
              + "、曜日番号=" + searchWeek
              + "]、"
              + "[抽出件数:" + registData.size()
              + "]");
              logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
            }
          }
        }
      }
    } catch(Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("患者治療パターン項目登録処理に失敗しました:" + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      // ロールバック実行
      throw new RuntimeException();
    }

    return updateCount;
  }
  // add 10744 医療材料の穴埋め追加によるpat_treatment_patternへの追加処理が不正 関 start
  private Boolean beforeDataExist(String pk, String base, String edit) {
    Boolean exist = false;
    // 元データ
    JSONArray baseDataList = new JSONArray();
    if (null != base) {
      /* #10757 mod コンバートされた治療方法セットで指示が作成できない 2024-06-26 卓 start */
      // baseDataList = new JSONArray(base);
      baseDataList = new JSONArray(ObjectUtils.isEmpty(base)? "[]" : base);
    }
    // 登録データ
    JSONArray editDataList = new JSONArray(ObjectUtils.isEmpty(edit)? "[]" : edit);
    /* #10757 mod コンバートされた治療方法セットで指示が作成できない 2024-06-26 卓 end */

    for (int i = baseDataList.length() - 1; i >= 0; i--) {
      for (int j = 0; j < editDataList.length(); j++) {
        if (baseDataList.getJSONObject(i).get(pk).toString().equals(editDataList.getJSONObject(j).get(pk).toString())) {
          return exist = true;
        }
      }
    }

    return exist;
  }
  // add 10744 医療材料の穴埋め追加によるpat_treatment_patternへの追加処理が不正 関 end

  /**
   * Jsonデータに対象データを登録(既存データが存在する場合は置換)
   * @param pk 一意検索条件キー
   * @param base 元データ
   * @param edit 登録データ
   * @param additionFlg 数量合算フラグ(true:合算する、false:合算しない)
   * @return 対象データ追加後のJsonデータ
   */
  private String insertJsonData(String pk, String base, String edit, boolean additionFlg) {
    // mod FNSI-課題５＿FNW→FNSiデータコンバーター 李 start
    // 元データ
    JSONArray baseDataList = new JSONArray();
    if (null != base) {
      /*#10757 mod コンバートされた治療方法セットで指示が作成できない 2024-06-26 卓 start*/
      //JSONArray baseDataList = new JSONArray(base);
      baseDataList = new JSONArray(ObjectUtils.isEmpty(base)? "[]" : base);
    }
    // JSONArray baseDataList = new JSONArray(base);
    // mod FNSI-課題５＿FNW→FNSiデータコンバーター 李 end
    // 登録データ
    JSONArray editDataList = new JSONArray(ObjectUtils.isEmpty(edit)? "[]" : edit);
    /*#10757 mod コンバートされた治療方法セットで指示が作成できない 2024-06-26 卓 end*/
    // 元データに登録データを追加
    for (int j = 0; j < editDataList.length(); j++) {
      Boolean addProcFlg = false;
      for (int i = baseDataList.length() - 1; i >= 0; i--) {
        // 一意検索条件キーが一致するデータが存在した場合は以下の処理を実施
        if (baseDataList.getJSONObject(i).get(pk).toString().equals(editDataList.getJSONObject(j).get(pk).toString())) {
          // 数量合算フラグがtrueの場合は数量を合算し、falseの場合は元データを登録データに置換する
          if (true == additionFlg) {
            double addData = Double.parseDouble(baseDataList.getJSONObject(i).get("amount").toString()) + Double.parseDouble(editDataList.getJSONObject(j).get("amount").toString());
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage("既存データが存在したため患者治療パターン項目登録処理で数量を合算しました:[合算元データ=" + baseDataList.getJSONObject(i) + "]、[合算対象データ=" + editDataList.getJSONObject(j) +"]、[合算数量=" + addData + "]");
            logService.log(LogLevel.INFO, eventLogMessage,"",SERVICE_NAME.FNSI, null);
            baseDataList.getJSONObject(i).put("amount", addData);
            addProcFlg = true;
          } else {
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage("既存データが存在したため患者治療パターン項目登録処理で削除しました:[削除データ=" + baseDataList.getJSONObject(i) + "]");
            logService.log(LogLevel.WARN, eventLogMessage,"",SERVICE_NAME.FNSI, null);
            baseDataList.remove(i);
          }
          break;
        }
      }
      // 数量合算フラグがfalseの場合または数量合算処理が行われなかった場合は登録データを追加
      if ((false == additionFlg) || (false == addProcFlg)) {
        baseDataList.put(editDataList.getJSONObject(j));
      }
    }

    return baseDataList.toString();
  }

  /**
   * 指定曜日の風袋・除水指示の更新
   * @param ind_tare_info 風袋情報
   * @param ind_off_water_info 除水補正情報
   * @param patId 患者ID
   * @param facility_cd 施設コード
   * @param treatWeek 治療曜日
   */
  @Transactional
  public int updateIndTareAndOffWater(
      String ind_tare_info,
      String ind_off_water_info,
      Long patId,
      String facility_cd,
      Integer treatWeek
      ) {
    int updateCount = patTreatmentPatternDao.updateIndTareAndOffWaterByWeek(
        ind_tare_info,
        ind_off_water_info,
        patId,
        facility_cd,
        treatWeek
        );
    return updateCount;
  }

  // DB更新ログ出力ロジック wangzuo Start
  /**
   * ログ情報設定
   *
   * @return eventLogMessage
   */
  private EventLogMessage getEventLogMessage() {
    EventLogMessage eventLogMessage = new EventLogMessage();
    NtssUser user = (NtssUser) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
    if (user != null) {
      // 利用者ID
      eventLogMessage.setUserId(user.getUserId().toString());
      // 施設コード
      eventLogMessage.setFacilityCd(user.getFacilityCd());
      // 接続先IPアドレス
      eventLogMessage.setClientIp(user.getClientIpAddress());
      // セッションID
      eventLogMessage.setSessionId(user.getSessionId());
    }
    // サービス名
    eventLogMessage.setServiceName(LoggingConstant.MODULE_NAME.ADMIN_WEB + "," + SERVICE_NAME.FNSI);
    return eventLogMessage;
  }

  /**
   * ログ出力共通クラス設定、取得
   * @return logCommon ログ出力共通クラス
   */
  private DataUpdateLogCommonNew getLogCommon(String tableName, StringBuffer whereStr, EventLogMessage eventLogMessage) {
    DataUpdateLogCommonNew logCommon = new DataUpdateLogCommonNew();
    logCommon.setEventLoggerFactory(eventLoggerFactory);
    logCommon.setLogServiceCore(logServiceCore);
    logCommon.setConfig(defaultDbConfig);
    logCommon.setTableName(tableName);
    logCommon.setWhereStr(whereStr);
    logCommon.setCommonEventLogMessage(eventLogMessage);
    return logCommon;
  }
  // DB更新ログ出力ロジック wangzuo End
  // add 10150 治療条件変更時のonline、offline補液関連 関  start
  private JSONObject changeCondInfoJson(JSONObject indCondInfo, String value){

    String firstKey = indCondInfo.keys().next();

    JSONObject bufJson = new JSONObject();

    // 指示者コード
    bufJson.put("ind_user_id", indCondInfo.getJSONObject(firstKey).get("ind_user_id"));
    // 指示者名_姓
    bufJson.put("ind_user_last_name", indCondInfo.getJSONObject(firstKey).get("ind_user_last_name"));
    // 指示者名_名
    bufJson.put("ind_user_first_name", indCondInfo.getJSONObject(firstKey).get("ind_user_first_name"));
    // 更新者コード
    bufJson.put("upd_user_id", indCondInfo.getJSONObject(firstKey).get("upd_user_id"));
    // 更新者名_姓
    bufJson.put("upd_user_last_name", indCondInfo.getJSONObject(firstKey).get("upd_user_last_name"));
    // 更新者名_名
    bufJson.put("upd_user_first_name", indCondInfo.getJSONObject(firstKey).get("upd_user_first_name"));
    // 登録区分
    bufJson.put("input_class", 1);
    // 編集可否フラグ
    bufJson.put("is_editable", "1");
    // 連携オーダ番号
    bufJson.put("cop_order_no", JSONObject.NULL);

    bufJson.put("value", value);

    return bufJson;
  }
  // add 10150 治療条件変更時のonline、offline補液関連 関  end
}
