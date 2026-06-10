package jp.co.nikkiso.ntss.admin_web.service.exam;

import java.io.IOException;
import java.sql.Date;
import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;
//add FNSI-「幹対応残課題一覧.xlsx」№10対応 田 start
import jp.co.nikkiso.ntss.admin_web.request.patientCapture.JournalCreateRequestPayload;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.AsyncService;
import jp.co.nikkiso.ntss.admin_web.service.FacilitySettingService;
import jp.co.nikkiso.ntss.admin_web.service.JournalService;
import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
//add FNSI-「幹対応残課題一覧.xlsx」№10対応 田 end
import jp.co.nikkiso.ntss.core.dao.MntRecalcQueDao;
import jp.co.nikkiso.ntss.core.dao.MstExamItemDao;
import jp.co.nikkiso.ntss.core.dao.MstExamSetDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilityDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilitySettingDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.PatExamMainDao;
import jp.co.nikkiso.ntss.core.dao.PatExamMainHstDao;
import jp.co.nikkiso.ntss.core.dao.PatExamPatternDao;
import jp.co.nikkiso.ntss.core.dao.PatMainDao;
import jp.co.nikkiso.ntss.core.dao.PatNameIdentificationDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.dao.PatTreatmentPatternDao;
import jp.co.nikkiso.ntss.core.dao.SysCoopJournalDao;
import jp.co.nikkiso.ntss.core.entity.MntRecalcQue;
import jp.co.nikkiso.ntss.core.entity.MstExamItem;
import jp.co.nikkiso.ntss.core.entity.MstExamSet;
import jp.co.nikkiso.ntss.core.entity.MstFacility;
import jp.co.nikkiso.ntss.core.entity.PatExamMain;
import jp.co.nikkiso.ntss.core.entity.PatExamMainHst;
import jp.co.nikkiso.ntss.core.entity.PatExamPattern;
import jp.co.nikkiso.ntss.core.entity.PatMain;
import jp.co.nikkiso.ntss.core.entity.PatNameIdentification;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.PatTreatmentPattern;
import jp.co.nikkiso.ntss.core.entity.custom.FacilitySettingInfo;
import jp.co.nikkiso.ntss.core.entity.custom.PatExamMainData;
import jp.co.nikkiso.ntss.core.entity.custom.PatExamMainExamOrderInfo;
import jp.co.nikkiso.ntss.core.entity.custom.PatExamMainOrderExamSetInfo;
import jp.co.nikkiso.ntss.core.entity.custom.PatExamMainOrderLabelInfo;
import jp.co.nikkiso.ntss.core.entity.custom.PatExamPatternData;
import jp.co.nikkiso.ntss.core.entity.custom.PatExamPatternExamOrderInfo;
import jp.co.nikkiso.ntss.core.entity.custom.PatExamPatternOrderLabelInfo;
import jp.co.nikkiso.ntss.core.entity.custom.PatPersonalMainData;
import jp.co.nikkiso.ntss.core.logevent.DataUpdateLogCommonNew;
import jp.co.nikkiso.ntss.core.logevent.LogServiceCore;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import org.json.JSONArray;
import org.json.JSONObject;
import org.seasar.doma.jdbc.Config;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

//add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 start
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
//add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 end
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.admin_web.response.exam.ExamRequestResponse;
import jp.co.nikkiso.ntss.core.exception.NotExistException;
import org.springframework.util.CollectionUtils;
import org.springframework.util.StringUtils;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

/**
 * 検査結果のService実装クラス.
 */
@Service
public class ExamRequestServiceImpl implements ExamRequestService {

  /**
   * 追加.
   */
  public static final String INSERT = "1";

  /**
   * 変更.
   */
  public static final String UPDATE = "2";

  /**
   * 検査再計算依頼キューテーブルDaoインタフェース.
   */
  @Autowired
  private MntRecalcQueDao mntRecalcQueDao;

  /**
   * 検査結果Daoインタフェース.
   */
  @Autowired
  private PatExamMainDao patExamMainDao;

  //add FNSI-「幹対応残課題一覧.xlsx」№10対応 田 start
  /**
   * 検査結果Daohstインタフェース.
   */
  @Autowired
  private PatExamMainHstDao patExamMainhstDao;
  //add FNSI-「幹対応残課題一覧.xlsx」№10対応 田 end

  /**
   * 検査セットパターンDaoインタフェース.
   */
  @Autowired
  private PatExamPatternDao patExamPatternDao;

  /**
   * 治療パターンのDaoインタフェース.
   */
  @Autowired
  private PatTreatmentPatternDao patTreatmentPatternDao;

  @Autowired
  private MstFacilityDao mstFacilityDao;
  /**
   * 検査セットマスタのDaoインタフェース.
   */
  @Autowired
  private MstExamSetDao mstExamSetDao;

  /**
   * 治療情報のDaoインタフェース.
   */
  @Autowired
  private OrdMainDao ordMainDao;

  /**
   * 患者情報Daoインタフェース.
   */
  @Autowired
  private PatMainDao patMainDao;

  //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 start
  @Autowired
  private LogService logService;

  // mod 2023-01-14 bug #7627 修正 chen start
  @Autowired
  SysCoopJournalDao sysCoopJournalDao;

  @Autowired
  JournalService journalService;
  // mod 2023-01-14 bug #7627 修正 chen end
  //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 end

  // DB更新ログ出力ロジック xie Start
  @Autowired
  private EventLoggerFactory eventLoggerFactory;

  @Autowired
  private LogServiceCore logServiceCore;
  // DB更新ログ出力ロジック xie End

  @Autowired
  AsyncService asyncService;

  /* add by Lm.Mingyue  2023-02-02 [Transaction] start */
  @Autowired
  private FacilitySettingService facilitySettingService;
  /* add by Lm.Mingyue  2023-02-02 [Transaction] end */

  // 9729-検査再計算ツール画面について 20231115仕様変更 zhoubin add start
  @Autowired
  private PatPersonalMainDao patPersonalMainDao;

  @Autowired
  private PatNameIdentificationDao patNameIdentificationDao;

  @Autowired
  MstFacilitySettingDao mstFacilitySettingDao;
  // 9729-検査再計算ツール画面について 20231115仕様変更 zhoubin add end

  // add #12462 患者情報共有->患者経過総合ビューア fang start
  /**
   * 検査項目Dao.
   */
  @Autowired
  private MstExamItemDao mstExamItemDao;
  // add #12462 患者情報共有->患者経過総合ビューア fang end

  @Override
  /* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --start */
  // public List<PatExamMain> FindPatExamMainByDateCd(int pat_id, String dialysis_date_from, String dialysis_date_to) {
  //   return patExamMainDao.selectPatExamMainByDateCd(pat_id, dialysis_date_from, dialysis_date_to);
  public List<PatExamMain> FindPatExamMainByDateCd(int pat_id, String dialysis_date_from, String dialysis_date_to, Integer patShareMode) {
    // mod #12462 患者情報共有->患者経過総合ビューア fang start
    List<PatExamMain> patExamMains = patExamMainDao.selectPatExamMainByDateCd(pat_id, dialysis_date_from, dialysis_date_to, patShareMode);
    HashMap<String, String> cdMap = new HashMap<>();
    HashMap<String, String> defaultCdMap = new HashMap<>();
    for(PatExamMain patExamMain : patExamMains) {
      if(patExamMain.getExamResultInfo() != null){
        JSONArray jsonArray = new JSONArray(patExamMain.getExamResultInfo());
        for (int i = 0; i < jsonArray.length(); i++) {
          JSONObject obj = jsonArray.getJSONObject(i);
          if(obj.has("item_cd") && obj.get("item_cd") != null) {
            String itemCd = obj.get("item_cd").toString();
            if(!obj.has("jlac10_cd") || obj.get("jlac10_cd") == null || "null".equals(obj.get("jlac10_cd").toString())) {
              String jlac10Cd = "";
              if(cdMap.containsKey(itemCd)) {
                jlac10Cd = cdMap.get(itemCd);
              } else {
                MstExamItem examItem = mstExamItemDao.selectByExamItemCd(Long.parseLong(itemCd));
                if(examItem != null) {
                  jlac10Cd = examItem.getJlac10Cd();
                  if(jlac10Cd != null && !"".equals(jlac10Cd)) {
                    cdMap.put(itemCd, jlac10Cd);
                  }
                }
              }
              if(jlac10Cd != null && !"".equals(jlac10Cd)) {
                obj.put("jlac10_cd", jlac10Cd);
              }
            }
            String defaultCalcExamItemCd = "";
            if(defaultCdMap.containsKey(itemCd)) {
              defaultCalcExamItemCd = defaultCdMap.get(itemCd);
            } else {
              MstExamItem examItem = mstExamItemDao.selectByExamItemCd(Long.parseLong(itemCd));
              if(examItem != null) {
                defaultCdMap.put(itemCd, examItem.getDefaultCalcExamItemCd());
                defaultCalcExamItemCd = examItem.getDefaultCalcExamItemCd();
              }
            }
            obj.put("default_calc_exam_item_cd", defaultCalcExamItemCd);
          }
        }
        patExamMain.setExamResultInfo(jsonArray.toString());
      }
    }
    return patExamMains;
    // mod #12462 患者情報共有->患者経過総合ビューア fang end
  }
  /* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --end */

  // add FNSI-患者検査結果取得用 杜 start
  //add 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao start
  @Override
  public List<PatExamMain> FindPatExamMainByIsOrder(int pat_id, String dialysis_date_from, String dialysis_date_to) {
    return patExamMainDao.selectPatExamMainByIsOrder(pat_id, dialysis_date_from, dialysis_date_to);
  }
  //add 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao end
  /**
   * 患者検査結果取得用
   *
   * @param facility_cd 施設コード
   * @return 検査結果のResponse
   */
  @Override
  public List<PatExamMain> FindPatExamMainByFacilityCd(String facility_cd) {
    return patExamMainDao.selectPatExamMainByFacilityCd(facility_cd);
  }

  // add 検査再計算依頼キューテーブル取得用 杜 start

  /**
   * 検査再計算依頼キューテーブル取得用
   *
   * @param facility_cd 施設コード
   * @return 検査再計算依頼キューテーブルリスト
   */
  @Override
  public List<MntRecalcQue> FindMntRecalcQueByFacilityCd(String facility_cd) {
    return mntRecalcQueDao.selectByFacilityCd(facility_cd);
  }

  // add FNSI-検体検査の表示の修正 楊 start

  /**
   * 検査予定前回検査日取得
   *
   * @param pat_id             患者ID
   * @param dialysis_date_from 表示開始日(YYYYMMDD)
   * @return 前回検査結果のResponse
   */
  @Override
  /* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --start */
  // public PatExamMain FindPatExamMainLastDateByDateCd(int pat_id, String dialysis_date_from) {
  //   List<PatExamMain> lastPatExamMainList = patExamMainDao.selectPatExamMainLastDateByDateCd(pat_id, dialysis_date_from);
  public PatExamMain FindPatExamMainLastDateByDateCd(int pat_id, String dialysis_date_from, Integer patShareMode) {
    List<PatExamMain> lastPatExamMainList = patExamMainDao.selectPatExamMainLastDateByDateCd(pat_id, dialysis_date_from, patShareMode);
  /* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --end */
    PatExamMain resPatExamMain = null;

    // 最新の検査日を戻る
    if (lastPatExamMainList != null && lastPatExamMainList.size() > 0) {
      resPatExamMain = lastPatExamMainList.get(0);
    }

    return resPatExamMain;
  }
  // add FNSI-検体検査の表示の修正 楊 end

  /**
   * 透析予定日変更時、検査依頼日追従
   *
   * @param params 患者ID,変更前日付,変更後日付
   */
  @Override
  @Transactional
  public int updateRegExamDate(Map<String, String> params) throws Exception {
    // DB更新ログ出力ロジック xie Start
    boolean setResult = false;
    DataUpdateLogCommonNew logCommon = null;
    try {
      String tableName = "pat_exam_main";
      // SQL検索条件
      StringBuffer wheres = new StringBuffer("");
      wheres.append(" WHERE\n");
      wheres.append(" pat_id = '" + params.get("patId") + "' and \n");
      wheres.append(" to_char(reg_exam_date,'YYYY/MM/DD') = '" + params.get("beforeDate") + "' and \n");
      wheres.append(" exam_status = '0' \n");
      // logCommon設定
      logCommon = getLogCommon(patExamMainDao, tableName, wheres, getEventLogMessage());
      // ログ出力カラム情報及び更新前データ情報取得
      setResult = logCommon.setInfo();
    } catch (Exception e) {
      setResult = false;
    }
    // DB更新ログ出力ロジック xie End
    /* modify by shiyw 2023-03-25 [#8101] 患者経過総合応答速度の最適化です --start */
//    int updateCount = patExamMainDao.updateRegExamDate(params);
    int updateCount = 0;
    if(setResult){
      updateCount = patExamMainDao.updateRegExamDate(params);
    }
    /* modify by shiyw 2023-03-25 [#8101] 患者経過総合応答速度の最適化です --end */
    // DB更新ログ出力ロジック xie Start
    // 更新後データ取得、差分あれば、log出力
    if (setResult && updateCount > 0) {
      /* modify by chamaojia 2023-03-09 sqlを同期実行し、非同期差分保存ログ  --start */
      logCommon.setAfterResults();
      /* modify by shiyw 2023-03-07 [#8101] --start */
//      logCommon.updateLog();
      asyncService.updateLog(logCommon);
      /* modify by shiyw 2023-03-07 [#8101] --end */
      /* modify by chamaojia 2023-03-09 sqlを同期実行し、非同期差分保存ログ  --end */
    }
    // DB更新ログ出力ロジック xie End

    return updateCount;
  }

  /**
   * 透析予定中止時、検査依頼削除
   *
   * @param params 患者ID,日付
   */
  @Override
  @Transactional
  public void updateIsDel(Map<String, String> params) throws Exception {

    //del 7322 exam_ord連携の出力グループ 20221116 zhaoqi start
//    boolean setResult = false;
//    DataUpdateLogCommonNew logCommon = null;
    // DB更新ログ出力ロジック xie Start
//    try {
//      String tableName = "pat_exam_main";
//      // SQL検索条件
//      StringBuffer wheres = new StringBuffer("");
//      wheres.append(" WHERE\n");
//      wheres.append(" pat_id = '" + params.get("patId") + "' and \n");
//      wheres.append(" to_char(reg_exam_date,'YYYY/MM/DD') = '" + params.get("date") + "'  \n");
//      // logCommon設定
//      logCommon = getLogCommon(patExamMainDao, tableName, wheres, getEventLogMessage());
//      // ログ出力カラム情報及び更新前データ情報取得
////      setResult = logCommon.setInfo();
//    } catch (Exception e) {
////      setResult = false;
//    }
    // DB更新ログ出力ロジック xie End
    //del 7322 exam_ord連携の出力グループ 20221116 zhaoqi end

    //add 7322 exam_ord連携の出力グループ 20221116 zhaoqi start
    Long patId = Long.valueOf(params.get("patId"));
    String date = params.get("date");
    String facilityCd = params.get("facilityCd");
    Long userId = Long.valueOf(params.get("userId"));

    SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
    List<Map<String, String>> updateData = new LinkedList<>();
    List<PatExamPatternData> patExamPatternList = new LinkedList<>();
    List<Map<String, String>> patExtInfoList = new LinkedList<>();
    List<PatExamMain> patExamMainList = patExamMainDao.selectPatExamMainForDel(patId, date);
    // add 10553 連携イベント発生部分不正 関 start
    PatPersonalMain patSrc = patPersonalMainDao.selectById(patId);
    // add 10553 連携イベント発生部分不正 関 end
    /* modify by chamaojia 2023-03-24 [6118] 集合size判定の追加 -- start */
    if (patExamMainList != null && patExamMainList.size() > 0) {
    /* modify by chamaojia 2023-03-24 [6118] 集合size判定の追加 -- end */
      for (int i = 0; i < patExamMainList.size(); i++) {
        PatExamMain patExamMain = patExamMainList.get(i);
        Map<String, String> updateMap = new HashMap<>();
        updateMap.put("clientIp", null);
        updateMap.put("copOrderNo1", null);
        updateMap.put("copOrderNo2", null);
        updateMap.put("dataGenClass", null);
        updateMap.put("examMainCd", patExamMain.getExamMainCd()!= null?patExamMain.getExamMainCd().toString():"");
        updateMap.put("examOrderInfo", "[]");
        updateMap.put("examResultInfo", null);
        updateMap.put("examStatus", patExamMain.getExamStatus());
        updateMap.put("facilityCd", patExamMain.getFacilityCd());
        updateMap.put("fnPatId", null);
        updateMap.put("indUserId", patExamMain.getIndUserId() != null?patExamMain.getIndUserId().toString():null);
        updateMap.put("isDel", "1");
        updateMap.put("isLock", "0");
        updateMap.put("isOrder", "1");
        updateMap.put("operation", "2");
        updateMap.put("operatorId", null);
        updateMap.put("ordNo", null);
        updateMap.put("orderComment", null);
        updateMap.put("orderExamSetInfo", "[]");
        updateMap.put("orderLabelInfo", "[]");
        updateMap.put("patId", String.valueOf(patId));
        updateMap.put("regDate", patExamMain.getRegDate()!=null?patExamMain.getRegDate().toString():"");
        updateMap.put("regExamDate", sdf.format(patExamMain.getRegExamDate()));
        updateMap.put("regOrderClass", patExamMain.getRegOrderClass());
        updateMap.put("regStaff", String.valueOf(patExamMain.getRegStaff()));
        updateMap.put("resultComment", null);
        updateMap.put("resultExamDate", null);
        updateMap.put("strExamDate", sdf.format(patExamMain.getRegExamDate()));
        updateMap.put("targetFacilityCd", null);
        updateMap.put("upDate", patExamMain.getUpDate()!=null?patExamMain.getUpDate().toString():"");
        updateMap.put("upStaff", String.valueOf(patExamMain.getUpStaff()));
        updateData.add(updateMap);
      }
      this.updateMasterData(updateData, facilityCd, null, patExamPatternList, patExtInfoList);
      // mod 2023-01-14 bug #7627 修正 chen start
      // List<Long> ctlNoList = new ArrayList<>();
      List<JournalCreateRequestPayload> ctlNoList = new ArrayList<>();

      List<String> checkRegOrderClassList = new LinkedList<>();
      for (int i = 0; i < patExamMainList.size(); i++) {
        PatExamMain patExamMain = patExamMainList.get(i);
//        String regOrderClass = patExamMain.getRegOrderClass();
//        if(!checkRegOrderClassList.contains(regOrderClass)){
//          checkRegOrderClassList.add(regOrderClass);
//        }else{
//          continue;
//        }
        // JournalCreateRequestPayload payload = new JournalCreateRequestPayload();
        // SysCoopJournal payload = new SysCoopJournal();
        JournalCreateRequestPayload payload = new JournalCreateRequestPayload();
        if(patExamMain.getPhyOrdClass()!=null && "1".equals(patExamMain.getPhyOrdClass())){
          payload.setAnaResult("0");
          // #6993-profile連携で受信した生存の有無登録 周 20230205-reivew対応 mod start
          // #6993-profile連携で受信した生存の有無登録 周 20230204 mod end
          payload.setBaseDate(sdf.format(patExamMain.getRegExamDate()));
          payload.setCoopCd("phy_ord");
          payload.setCoopCdIndex("");
          payload.setCoopResult("0");
          payload.setCrud("D");
          payload.setDirection("S");
          payload.setFacilityCd(facilityCd);
          // mod 10553 連携イベント発生部分不正 関 start
          // payload.setOpeCd("021110");
          payload.setOpeCd("004040");
          // mod 10553 連携イベント発生部分不正 関 end
          // #6993-profile連携で受信した生存の有無登録 周 20230204 mod start
//        payload.setOrdNo(null);
          payload.setOrdNo(patExamMain.getExamMainCd());
          // #6993-profile連携で受信した生存の有無登録 周 20230204 mod end
          payload.setPatId(patId);
          // payload.setRegOrderClass(regOrderClass);
          payload.setUserId(userId);
          // add 10553 連携イベント発生部分不正 関 start
          if (patSrc != null) {
            payload.setHospPatId(patSrc.getHosp_pat_id());
          }
          // add 10553 連携イベント発生部分不正 関 end
        }else{
          payload.setAnaResult("0");
          // #6993-profile連携で受信した生存の有無登録 周 20230205-reivew対応 mod start
          // #6993-profile連携で受信した生存の有無登録 周 20230204 mod end
          payload.setBaseDate(sdf.format(patExamMain.getRegExamDate()));
          payload.setCoopCd("exam_ord");
          payload.setCoopCdIndex("");
          payload.setCoopResult("0");
          payload.setCrud("D");
          payload.setDirection("S");
          payload.setFacilityCd(facilityCd);
          // mod 10553 連携イベント発生部分不正 関 start
          // payload.setOpeCd("021010");
          payload.setOpeCd("004039");
          // mod 10553 連携イベント発生部分不正 関 end
          // #6993-profile連携で受信した生存の有無登録 周 20230204 mod start
//        payload.setOrdNo(null);
          payload.setOrdNo(patExamMain.getExamMainCd());
          // #6993-profile連携で受信した生存の有無登録 周 20230204 mod end
          payload.setPatId(patId);
          // payload.setRegOrderClass(regOrderClass);
          payload.setUserId(userId);
          // add 10553 連携イベント発生部分不正 関 start
          if (patSrc != null) {
            payload.setHospPatId(patSrc.getHosp_pat_id());
          }
          // add 10553 連携イベント発生部分不正 関 end
        }
        // #6993-profile連携で受信した生存の有無登録 周 20230204 mod start
//        payload.setAnaResult("0");
        // #6993-profile連携で受信した生存の有無登録 周 20230205-reivew対応 mod start
//        payload.setAnaResult("S");

        // asyncService.sendExternalConnection(payload);
        // payload.setCtlNo(sysCoopJournalDao.selectNextSeqCtlNo());
        // sysCoopJournalDao.insert(payload);
        // ctlNoList.add(payload.getCtlNo());
        ctlNoList.add(payload);
      }
      //modify  by guanyingshuai 2023.02.10  [#6118-optimize runtime]   start
      if (!CollectionUtils.isEmpty(ctlNoList)){
        journalService.callCreateJournalForCtrNo(ctlNoList);
      }
      //modify  by guanyingshuai 2023.02.10  [#6118-optimize runtime]   end

      // mod 2023-01-14 bug #7627 修正 chen end
    }

    //add 7322 exam_ord連携の出力グループ 20221116 zhaoqi end

    //del 7322 exam_ord連携の出力グループ 20221116 zhaoqi start
//    int updateCount = patExamMainDao.updateIsDel(params);
//
//    // DB更新ログ出力ロジック wangzuo Start
//    // 更新後データ取得、差分あれば、log出力
//    if (setResult && updateCount > 0) {
//      logCommon.updateLog();
//    }
//    // DB更新ログ出力ロジック wangzuo End
//
//    return updateCount;
    //del 7322 exam_ord連携の出力グループ 20221116 zhaoqi end
  }

  /* add by chamaojia 2023-03-24 [6118] 日付コレクションの一括処理の追加、updateIsDelメソッドの拡張 -- start */
  /**
   * 透析予定中止時、検査依頼削除
   *
   * @param patId 患者ID
   * @param userId ユーザID
   * @param facilityCd 施設コード
   * @param dateList 日付コレクション
   */
  @Override
  @Transactional
  public void updateIsDelByDateList(Long patId, Long userId, String facilityCd, List<String> dateList) throws Exception {
    SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
    /* del by chamaojia 2023-04-21 [6118] 変数定義位置エラー -- start */
//    List<Map<String, String>> updateData = new LinkedList<>();
//    List<PatExamPatternData> patExamPatternList = new LinkedList<>();
//    List<Map<String, String>> patExtInfoList = new LinkedList<>();
    /* del by chamaojia 2023-04-21 [6118] 変数定義位置エラー -- end */
    // 時間集合による一括クエリー
    List<PatExamMain> patExamMainAllList = patExamMainDao.selectPatExamMainForDelByPatIdAndDateList(patId, dateList);
    if (patExamMainAllList != null && patExamMainAllList.size() > 0) {
      List<JournalCreateRequestPayload> ctlNoList = new ArrayList<>();
      // 元の論理と一致する時間でグループ化
      Map<String, List<PatExamMain>> patExamMainMap = patExamMainAllList.stream().collect(
        Collectors.groupingBy(p -> sdf.format(p.getRegExamDate()), Collectors.toList()));
      for (String dateStr : patExamMainMap.keySet()) {
        /* add by chamaojia 2023-04-21 [6118] 変数定義位置の移行 -- start */
        List<Map<String, String>> updateData = new LinkedList<>();
        List<PatExamPatternData> patExamPatternList = new LinkedList<>();
        List<Map<String, String>> patExtInfoList = new LinkedList<>();
        /* add by chamaojia 2023-04-21 [6118] 変数定義位置の移行 -- end */
        List<PatExamMain> patExamMainList = patExamMainMap.get(dateStr);
        if (patExamMainList != null && patExamMainList.size() > 0) {
          for (int i = 0; i < patExamMainList.size(); i++) {
            PatExamMain patExamMain = patExamMainList.get(i);
            Map<String, String> updateMap = new HashMap<>();
            updateMap.put("clientIp", null);
            updateMap.put("copOrderNo1", null);
            updateMap.put("copOrderNo2", null);
            updateMap.put("dataGenClass", null);
            updateMap.put("examMainCd", patExamMain.getExamMainCd()!= null?patExamMain.getExamMainCd().toString():"");
            updateMap.put("examOrderInfo", "[]");
            updateMap.put("examResultInfo", null);
            updateMap.put("examStatus", patExamMain.getExamStatus());
            updateMap.put("facilityCd", patExamMain.getFacilityCd());
            updateMap.put("fnPatId", null);
            updateMap.put("indUserId", patExamMain.getIndUserId() != null?patExamMain.getIndUserId().toString():null);
            updateMap.put("isDel", "1");
            updateMap.put("isLock", "0");
            updateMap.put("isOrder", "1");
            updateMap.put("operation", "2");
            updateMap.put("operatorId", null);
            updateMap.put("ordNo", null);
            updateMap.put("orderComment", null);
            updateMap.put("orderExamSetInfo", "[]");
            updateMap.put("orderLabelInfo", "[]");
            updateMap.put("patId", String.valueOf(patId));
            updateMap.put("regDate", patExamMain.getRegDate()!=null?patExamMain.getRegDate().toString():"");
            updateMap.put("regExamDate", sdf.format(patExamMain.getRegExamDate()));
            updateMap.put("regOrderClass", patExamMain.getRegOrderClass());
            updateMap.put("regStaff", String.valueOf(patExamMain.getRegStaff()));
            updateMap.put("resultComment", null);
            updateMap.put("resultExamDate", null);
            updateMap.put("strExamDate", sdf.format(patExamMain.getRegExamDate()));
            updateMap.put("targetFacilityCd", null);
            updateMap.put("upDate", patExamMain.getUpDate()!=null?patExamMain.getUpDate().toString():"");
            updateMap.put("upStaff", String.valueOf(patExamMain.getUpStaff()));
            updateData.add(updateMap);
          }
          this.updateMasterData(updateData, facilityCd, null, patExamPatternList, patExtInfoList);
          // mod 2023-01-14 bug #7627 修正 chen start
          // List<Long> ctlNoList = new ArrayList<>();

          List<String> checkRegOrderClassList = new LinkedList<>();
          for (int i = 0; i < patExamMainList.size(); i++) {
            PatExamMain patExamMain = patExamMainList.get(i);
//        String regOrderClass = patExamMain.getRegOrderClass();
//        if(!checkRegOrderClassList.contains(regOrderClass)){
//          checkRegOrderClassList.add(regOrderClass);
//        }else{
//          continue;
//        }
            // JournalCreateRequestPayload payload = new JournalCreateRequestPayload();
            // SysCoopJournal payload = new SysCoopJournal();
            JournalCreateRequestPayload payload = new JournalCreateRequestPayload();
            if(patExamMain.getPhyOrdClass()!=null && "1".equals(patExamMain.getPhyOrdClass())){
              payload.setAnaResult("0");
              // #6993-profile連携で受信した生存の有無登録 周 20230205-reivew対応 mod start
              // #6993-profile連携で受信した生存の有無登録 周 20230204 mod end
              payload.setBaseDate(sdf.format(patExamMain.getRegExamDate()));
              payload.setCoopCd("phy_ord");
              payload.setCoopCdIndex("");
              payload.setCoopResult("0");
              payload.setCrud("D");
              payload.setDirection("S");
              payload.setFacilityCd(facilityCd);
              payload.setOpeCd("021110");
              // #6993-profile連携で受信した生存の有無登録 周 20230204 mod start
//        payload.setOrdNo(null);
              payload.setOrdNo(patExamMain.getExamMainCd());
              // #6993-profile連携で受信した生存の有無登録 周 20230204 mod end
              payload.setPatId(patId);
              // payload.setRegOrderClass(regOrderClass);
              payload.setUserId(userId);
            }else{
              payload.setAnaResult("0");
              // #6993-profile連携で受信した生存の有無登録 周 20230205-reivew対応 mod start
              // #6993-profile連携で受信した生存の有無登録 周 20230204 mod end
              payload.setBaseDate(sdf.format(patExamMain.getRegExamDate()));
              payload.setCoopCd("exam_ord");
              payload.setCoopCdIndex("");
              payload.setCoopResult("0");
              payload.setCrud("D");
              payload.setDirection("S");
              payload.setFacilityCd(facilityCd);
              payload.setOpeCd("021010");
              // #6993-profile連携で受信した生存の有無登録 周 20230204 mod start
//        payload.setOrdNo(null);
              payload.setOrdNo(patExamMain.getExamMainCd());
              // #6993-profile連携で受信した生存の有無登録 周 20230204 mod end
              payload.setPatId(patId);
              // payload.setRegOrderClass(regOrderClass);
              payload.setUserId(userId);
            }
            // #6993-profile連携で受信した生存の有無登録 周 20230204 mod start
//        payload.setAnaResult("0");
            // #6993-profile連携で受信した生存の有無登録 周 20230205-reivew対応 mod start
//        payload.setAnaResult("S");

            // asyncService.sendExternalConnection(payload);
            // payload.setCtlNo(sysCoopJournalDao.selectNextSeqCtlNo());
            // sysCoopJournalDao.insert(payload);
            // ctlNoList.add(payload.getCtlNo());
            ctlNoList.add(payload);
          }
          // mod 2023-01-14 bug #7627 修正 chen end
        }

      }
      //modify  by guanyingshuai 2023.02.10  [#6118-optimize runtime]   start
      if (!CollectionUtils.isEmpty(ctlNoList)){
        journalService.callCreateJournalForCtrNo(ctlNoList);
      }
      //modify  by guanyingshuai 2023.02.10  [#6118-optimize runtime]   end
    }
  }
  /* add by chamaojia 2023-03-24 [6118] 日付コレクションの一括処理の追加、updateIsDelメソッドの拡張 -- end */

  /**
   * {@inheritDoc}
   */
  //mod #12462 患者情報共有 zrx start
  @Override
  //  public ExamRequestResponse createExamRequestResponse(List<Long> patIdList, String startDate, String endDate, String facilityCd) throws Exception {
  public ExamRequestResponse createExamRequestResponse(
    List<Long> patIdList, String startDate, String endDate, String facilityCd, Integer patientShareMode) throws Exception {
    //mod #12462 患者情報共有 zrx end
    SimpleDateFormat formatDate = new SimpleDateFormat("yyyy/MM/dd");
    formatDate.setLenient(false);
    //表示期間(開始日)の日付フォーマットチェック
    if(!StringUtils.isEmpty(startDate)){
      formatDate.parse(startDate);
    }
    //表示期間(終了日)の日付フォーマットチェック
    if(!StringUtils.isEmpty(endDate)){
      formatDate.parse(endDate);
    }

    // 患者毎の透析予定日のリストを取得
    List<String> ordMainTreatDateList = ordMainDao.selectTreatDateList(patIdList, facilityCd);

    // 施設IDを元に、検査結果を取得
    List<PatExamMainData> patExamMainList = patExamMainDao.selectPatExamMainByPatIdListExamOrder(patIdList, startDate, facilityCd);

    // 患者毎の検査パターンを取得
    List<PatExamPatternData> patExamPatternList = patExamPatternDao.selectPatExamPatternByPatIdList(patIdList, startDate);

    // 患者毎の治療パターンを取得
    List<PatTreatmentPattern> patTreatmentPatternList = patTreatmentPatternDao.selectByPatIdList(patIdList, facilityCd);

    //add #12462 患者は合計 by zrx  start
    if(null!=patIdList && patientShareMode != null && patientShareMode == 0) {
      for (Long l : patIdList) {
        List<PatNameIdentification> listPatIdSrcFromPatTo = patNameIdentificationDao.getListPatIdSrcFromPatTo(l);
        for (PatNameIdentification patIdSrcFromPatTo : listPatIdSrcFromPatTo) {
          // 患者毎の透析予定日のリストを取得
          List<String> ordMainTreatDateListTemp = ordMainDao.selectTreatDateList(Arrays.asList(patIdSrcFromPatTo.getPatIdSrc()), patIdSrcFromPatTo.getFacilityCdSrc());
          ordMainTreatDateList.addAll(ordMainTreatDateListTemp);
          // 施設IDを元に、検査結果を取得
          List<PatExamMainData> patExamMainListTemp = patExamMainDao.selectPatExamMainByPatIdListExamOrder(Arrays.asList(patIdSrcFromPatTo.getPatIdSrc()), startDate, patIdSrcFromPatTo.getFacilityCdSrc());
          patExamMainListTemp.forEach(x -> {
            x.setPatId(l);
            x.setOwnPatId(patIdSrcFromPatTo.getPatIdSrc());
          });
          patExamMainList.addAll(patExamMainListTemp);
          // 患者毎の検査パターンを取得
          List<PatExamPatternData> patExamPatternListTemp = patExamPatternDao.selectPatExamPatternByPatIdList(Arrays.asList(patIdSrcFromPatTo.getPatIdSrc()), startDate);
          patExamPatternListTemp.forEach(x -> {
            x.setPatId(l);
            x.setOwnPatId(patIdSrcFromPatTo.getPatIdSrc());
          });
          patExamPatternList.addAll(patExamPatternListTemp);
          // 患者毎の治療パターンを取得
          List<PatTreatmentPattern> patTreatmentPatternListTemp = patTreatmentPatternDao.selectByPatIdList(Arrays.asList(patIdSrcFromPatTo.getPatIdSrc()), patIdSrcFromPatTo.getFacilityCdSrc());
          patTreatmentPatternListTemp.forEach(x->x.setPatId(l));
          patTreatmentPatternListTemp.forEach(x -> {
            x.setPatId(l);
            x.setOwnPatId(patIdSrcFromPatTo.getPatIdSrc());
          });
          patTreatmentPatternList.addAll(patTreatmentPatternListTemp);
        }
      }
    }
    //add #12462 患者は合計 by zrx  end

    // 日時(検査パターンの横軸)の取得
    List<Map<String, Integer>> tmpPatternColumnList = new ArrayList<Map<String, Integer>>();
    for (PatExamPatternData data : patExamPatternList) {
      Map<String, Integer> patternjson = new HashMap<String, Integer>();
      patternjson.put("examPattern", data.getExamPattern());
      patternjson.put("examWeek", data.getExamWeek());
      tmpPatternColumnList.add(patternjson);
    }
    List<Map<String, Integer>> patternColumnList = tmpPatternColumnList.stream().distinct().collect(Collectors.toList());

    // 検索結果0件の場合、検査結果を空にしてResponseを返す
    if (patExamMainList.isEmpty()) {
      List<String> tmpDateList = new ArrayList<String>();
      return new ExamRequestResponse(patExamMainList, tmpDateList, ordMainTreatDateList, patExamPatternList, patternColumnList, patTreatmentPatternList);
    }

    // 日付(表の横軸)の取得
    List<String> tmpDateList = new ArrayList<String>();
    for (PatExamMainData data : patExamMainList) {
      tmpDateList.add(data.getStrExamDate());
    }
    // 重複を削除し、並び替え
    List<String> examDateList = new ArrayList<String>(new LinkedHashSet<>(tmpDateList));
    Collections.sort(examDateList);

    return new ExamRequestResponse(patExamMainList, examDateList, ordMainTreatDateList, patExamPatternList, patternColumnList, patTreatmentPatternList);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  public boolean updateMasterData(List<Map<String, String>> updateData, String facilityCd, Long userId,
                                  List<PatExamPatternData> patExamPatternList, List<Map<String, String>> patExtInfoList) {

    //add 7322 exam_ord連携の出力グループ 20221116 zhaoqi start
    //8104   ljgadd
    List<Map<String, String>> needToRemoveList = new LinkedList<>();
    List<Map<String, String>> needToRemoveList1 = new LinkedList<>();
    List<Map<String, String>> updateDatacopy = new LinkedList<>();
    List<Map<String, String>> updateDatacopy1 = new LinkedList<>();
    MstFacility MstFacilityisnull= mstFacilityDao.selectByAddvancedSettingCodeAndFacilityCd("A12",facilityCd);
    //8104   ljgadd
    //add 8088 重複した検査依頼が登録され検査依頼を中止しても検査依頼が再度表示される 王永吉 start
    JSONArray strOrderExamSetInfo = new JSONArray();
    if (updateData.size() > 0) {
      try {
        String targetDt = updateData.get(0).get("regExamDate");
        targetDt = targetDt.substring(0, 4) + "/" + targetDt.substring(4, 6) + "/" +targetDt.substring(6, 8) + " 00:00:00";
        Timestamp examDate = new Timestamp(new SimpleDateFormat("yyyy/MM/dd hh:mm:ss").parse(targetDt).getTime());
        List<PatExamMain> patExamMainOrtherData = patExamMainDao.selectPatExamMainByPatIdRegexamdateOrderclass(
               Long.parseLong(updateData.get(0).get("patId")), examDate, "0");
        String strInfo = "[";
        for (int p = 0; p < patExamMainOrtherData.size(); p++){
          strInfo = strInfo + patExamMainOrtherData.get(p).getOrderExamSetInfo().replace("[", "").replace("]", "");
          if (p + 1 < patExamMainOrtherData.size()){
            strInfo = strInfo + ",";
          }
        }
        strInfo = strInfo + "]";
        strOrderExamSetInfo = new JSONArray(strInfo);
      }
      catch (Exception e) { }
    }
    //8104   ljgadd
    if(MstFacilityisnull !=null) {
      for (int i = 0; i < updateData.size(); i++) {
        Map<String, String> patMap = updateData.get(i);
        Map<String, String> patMapcopy = new LinkedHashMap<>(patMap);
        String orderExamSetInfo = patMap.get("orderExamSetInfo");
        String examOrderInfo = patMap.get("examOrderInfo");
        JSONArray orderArray = new JSONArray(orderExamSetInfo);
        JSONArray examArray = new JSONArray(examOrderInfo);
        int x = 0,y=0,m=0,n=0,xx=0;
        List<Integer> nolist = new ArrayList<Integer>();
        JSONArray orderArray1 = new JSONArray("[]");
        JSONArray orderArray2 = new JSONArray("[]");
        for (int j = 0; j < orderArray.length(); j++) {
          JSONObject orderExamSetInfoObject = orderArray.getJSONObject(j);
          List<MstExamSet> mstExamSetphylist = mstExamSetDao.selectExamsetByPhyOrdClass(facilityCd);
          for(int k=0;k<mstExamSetphylist.size();k++){
            if(orderExamSetInfoObject.get("set_cd").toString().equals(mstExamSetphylist.get(k).getExamSetCd().toString())){
              xx =1;
              break;
            }
          }
          if (xx == 1) {
            orderArray2.put(x++, orderExamSetInfoObject);
            //mod 10618検査セットマスタ、検査項目マスタ、一般撮影検査依頼マスタ編集時に関連データを補正する zhao start
            //if (nolist.contains((Integer) orderExamSetInfoObject.get("no")) == false) {
            //  nolist.add((Integer) orderExamSetInfoObject.get("no"));
            if (nolist.contains((Integer) orderExamSetInfoObject.get("set_cd")) == false) {
              nolist.add((Integer) orderExamSetInfoObject.get("set_cd"));
              //mod 10618検査セットマスタ、検査項目マスタ、一般撮影検査依頼マスタ編集時に関連データを補正する zhao end
            }
          } else {
            orderArray1.put(y++, orderExamSetInfoObject);
          }
        }
        if (nolist.size() > 0 && nolist.size() != orderArray.length()) {
          JSONArray examArray1 = new JSONArray("[]");
          JSONArray examArray2 = new JSONArray("[]");
          for (int j = 0; j < examArray.length(); j++) {
            JSONObject orderExamSetInfoObject = examArray.getJSONObject(j);
            //mod 10618検査セットマスタ、検査項目マスタ、一般撮影検査依頼マスタ編集時に関連データを補正する zhao start
            //if (nolist.contains((Integer) orderExamSetInfoObject.get("no"))) {
            if (nolist.contains((Integer) orderExamSetInfoObject.get("set_cd"))) {
            //mod 10618検査セットマスタ、検査項目マスタ、一般撮影検査依頼マスタ編集時に関連データを補正する zhao end
              examArray2.put(m++, orderExamSetInfoObject);
            } else {
              examArray1.put(n++, orderExamSetInfoObject);
            }
          }
          String orderArraycopy = orderArray1.toString();
          String examArraycopy = examArray1.toString();
          String orderArraycopy1 = orderArray2.toString();
          String examArraycopy1 = examArray2.toString();
          patMap.put("orderExamSetInfo", orderArraycopy);
          patMap.put("examOrderInfo", examArraycopy);
          patMapcopy.put("orderExamSetInfo", orderArraycopy1);
          patMapcopy.put("examOrderInfo", examArraycopy1);
          patMap.put("phyOrdClass", null);
          patMapcopy.put("phyOrdClass", "1");
          updateDatacopy.add(patMap);
          updateDatacopy1.add(patMapcopy);
          //add #10125 ケース19  ケース20 zrx start
        } else if (nolist.isEmpty() && orderArray.isEmpty()) {
          // 一般検査・生理検査の削除の場合該当分岐へ入る
          // nolist.isEmpty() は生理検査のセットを使用していない
          // orderArray.isEmpty() はレコード削除（セット全削除）の場合
          if(StringUtils.isEmpty(patMap.get("phyOrdClass"))){
            // 一般検査の削除
            updateDatacopy.add(patMap);
          } else {
            // 生理検査の削除
            updateDatacopy1.add(patMapcopy);
          }
          //add #10125 ケース19  ケース20 zrx end
        } else if (nolist.size() == 0) {
          patMap.put("phyOrdClass", null);
          updateDatacopy.add(patMap);
        } else if (nolist.size() == orderArray.length()) {
          patMapcopy.put("phyOrdClass", "1");
          updateDatacopy1.add(patMapcopy);
        }
      }

      updateData.clear();
      updateData.addAll(updateDatacopy);
      updateData.addAll(updateDatacopy1);
    }
    //8104   ljgadd
    //add 8088 重複した検査依頼が登録され検査依頼を中止しても検査依頼が再度表示される 王永吉 end
    for(int i=0;i<updateData.size();i++){
      Map<String, String> patMap = updateData.get(i);
      String regOrderClass = patMap.get("regOrderClass");
      String isDel = patMap.get("isDel");
      if("0".equals(regOrderClass) && !"1".equals(isDel)){
        needToRemoveList.add(patMap);
      }else{
        needToRemoveList1.add(patMap);
      }
    }
    for(int i=0;i<needToRemoveList.size();i++){
      Map<String, String> patMap = needToRemoveList.get(i);
      String orderExamSetInfo = patMap.get("orderExamSetInfo");
      String examOrderInfo = patMap.get("examOrderInfo");
      JSONArray orderArray = new JSONArray(orderExamSetInfo);
      JSONArray examArray = new JSONArray(examOrderInfo);
      for(int j=0;j<orderArray.length();j++){
        JSONObject orderExamSetInfoObject = orderArray.getJSONObject(j);
        //add 8088 重複した検査依頼が登録され検査依頼を中止しても検査依頼が再度表示される 王永吉 start
        boolean inOutF = false;
        for (int y = 0; y < strOrderExamSetInfo.length(); y++){
          JSONObject strOrderExamSetInfoObject = strOrderExamSetInfo.getJSONObject(y);
          //mod 10618検査セットマスタ、検査項目マスタ、一般撮影検査依頼マスタ編集時に関連データを補正する zhao start
          //if (orderExamSetInfoObject.get("no").equals(strOrderExamSetInfoObject.get("no")) &&
          if (orderExamSetInfoObject.get("set_cd").equals(strOrderExamSetInfoObject.get("set_cd")) &&
          //mod 10618検査セットマスタ、検査項目マスタ、一般撮影検査依頼マスタ編集時に関連データを補正する zhao end
              orderExamSetInfoObject.get("set_name").equals(strOrderExamSetInfoObject.get("set_name")) &&
              orderExamSetInfoObject.get("set_cd").equals(strOrderExamSetInfoObject.get("set_cd"))){
            inOutF = true;
            break;
          }
        }
        if (inOutF){
          continue;
        }
        //add 8088 重複した検査依頼が登録され検査依頼を中止しても検査依頼が再度表示される 王永吉 end
        String orderNo = "";
        //mod 10618検査セットマスタ、検査項目マスタ、一般撮影検査依頼マスタ編集時に関連データを補正する zhao start
        //if(orderExamSetInfoObject.get("no") != null){
        //  orderNo = orderExamSetInfoObject.get("no").toString();
        if(orderExamSetInfoObject.get("set_cd") != null){
          orderNo = orderExamSetInfoObject.get("set_cd").toString();
        //mod 10618検査セットマスタ、検査項目マスタ、一般撮影検査依頼マスタ編集時に関連データを補正する zhao end
        }
        JSONArray newExamOrderInfoArray = new JSONArray();
        for(int m=0;m<examArray.length();m++){
          JSONObject examOrderInfoObject = examArray.getJSONObject(m);
          String examNo = "";
          //mod 10618検査セットマスタ、検査項目マスタ、一般撮影検査依頼マスタ編集時に関連データを補正する zhao start
          //if(examOrderInfoObject.get("no") != null){
          //  examNo = examOrderInfoObject.get("no").toString();
          if(examOrderInfoObject.get("set_cd") != null){
            examNo = examOrderInfoObject.get("set_cd").toString();
          //mod 10618検査セットマスタ、検査項目マスタ、一般撮影検査依頼マスタ編集時に関連データを補正する zhao end
          }
          if(orderNo.equals(examNo)){
            newExamOrderInfoArray.put(examOrderInfoObject);
          }
        }

        Map<String, String> newData = new HashMap<>();
        Iterator it = patMap.entrySet().iterator();
        while (it.hasNext()) {
          Map.Entry entry = (Map.Entry) it.next();
          String key = entry.getKey().toString();
          newData.put(key, patMap.get(key));
          JSONArray newOrderExamSetInfoArray = new JSONArray();
          newOrderExamSetInfoArray.put(orderExamSetInfoObject);
          newData.put("orderExamSetInfo", newOrderExamSetInfoArray.toString());
          newData.put("examOrderInfo", newExamOrderInfoArray.toString());
          newData.put("operation", "1");
        }
        //8104   ljgadd
        needToRemoveList1.add(newData);
        //8104   ljgadd
      }
    }
    //8104   ljgadd
//    updateData.removeAll(needToRemoveList);
    updateData.clear();
    updateData.addAll(needToRemoveList1);
    //add 7322 exam_ord連携の出力グループ 20221116 zhaoqi start
   //8104   ljgadd
    // スケジュール延長最終日更新
    patExtInfoList.forEach(patExtInfo -> {
      Long patId = Long.parseLong(patExtInfo.get("patId"));
      String schExtEndDate = patExtInfo.get("schExtEndDate");
      Boolean isExistEndDate = Boolean.parseBoolean(patExtInfo.get("isExistEndDate"));
      try {
        if (!isExistEndDate) {
          // DB更新ログ出力ロジック xie Start
          boolean setResult = false;
          DataUpdateLogCommonNew logCommon = null;
          try {
            String tableName = "pat_main";
            // SQL検索条件
            StringBuffer wheres = new StringBuffer("");
            wheres.append(" WHERE\n");
            wheres.append(" pat_id = '" + patId + "'\n");
            // logCommon設定
            logCommon = getLogCommon(patMainDao, tableName, wheres, getEventLogMessage());
            // ログ出力カラム情報及び更新前データ情報取得
            setResult = logCommon.setInfo();
          } catch (Exception e) {
            setResult = false;
          }
          // DB更新ログ出力ロジック xie End

          int updateCount = patMainDao.updateSchExtEndDate(patId, schExtEndDate);

          // DB更新ログ出力ロジック xie Start
          // 更新後データ取得、差分あれば、log出力
          if (setResult && updateCount > 0) {
            logCommon.updateLog();
          }
          // DB更新ログ出力ロジック xie End
        }
      } catch (Exception e) {
        throw new NotExistException(e.getMessage());
      }
    });

    // 検査セットパターン登録
    patExamPatternList.forEach(e -> {

      // 登録時間取得
      java.sql.Timestamp regDt = getCurrentDate();

      PatExamPattern patExamPattern = new PatExamPattern() {
        {
          setExamPatternCd(e.getExamPatternCd());
          setPatId(e.getPatId());
          setFacilityCd(facilityCd);
          setRegExamDate(e.getRegExamDate());
          setRegOrderClass(e.getRegOrderClass());
          setExamPattern(e.getExamPattern());
          setExamWeek(e.getExamWeek());
          setExamFrom(e.getExamFrom());
          setExamTo(e.getExamTo());
          setOrderExamSetCd(e.getOrderExamSetCd());
          setExamOrderInfo(e.getExamOrderInfo());
          setOrderLabelInfo(e.getOrderLabelInfo());
          setIsDel(e.getIsDel());
          setRegDate(regDt);
          setRegStaff(userId);
          setUpDate(regDt);
          setUpStaff(userId);
          //mod FNSI-「検査予定パターン削除システムエラー.xlsx」対応 田 start
          //setIndUserId(Long.parseLong(updateData.get(0).get("indUserId")));
          setIndUserId(updateData.size() != 0 ? Long.parseLong(updateData.get(0).get("indUserId")) : null);
          //mod FNSI-「検査予定パターン削除システムエラー.xlsx」対応 田 end
        }
      };

      switch (e.getStatus()) {
        case 0:
          patExamPatternDao.updatePatExamPattern(patExamPattern);
          break;
        case 1:
          break;
        case 2:
          patExamPatternDao.insertPatExamPattern(patExamPattern);
          break;
      }
    });

    // 追加
    insertData(updateData, facilityCd, userId);
    // 更新
    updateData(updateData, userId);

    return true;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<MstExamSet> selectExamSetList(String facilityCd) {
    List<MstExamSet> mstExamSetList = mstExamSetDao.selectExamSetList(facilityCd, true, false);
    return mstExamSetList;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<MstExamSet> selectAllExamSetListByFacility(String facilityCd) {
    List<MstExamSet> mstExamSetList = mstExamSetDao.selectAllExamSetListByFacility(facilityCd);
    return mstExamSetList;
  }

  /**
   * システム日時を取得します
   *
   * @return システム日時
   */
  private java.sql.Timestamp getCurrentDate() {
    return new java.sql.Timestamp(System.currentTimeMillis());
  }

  /**
   * データ追加.
   *
   * @param data       画面で編集したデータ
   * @param facilityCd 施設コード
   * @param userId     ログイン利用者ID
   */
  private void insertData(List<Map<String, String>> data, String facilityCd, Long userId) {

    data.stream().filter(e -> e.get("operation").equals(INSERT)).forEach(e -> {
      try {
        // 変換対象の日付文字列
        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd HH:mm:ss");
        // 変換対象の日付文字列
        SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        // Timestamp型変換
        Timestamp regExamDate = new Timestamp(sdf.parse(e.get("regExamDate").replaceAll("-", "").substring(0, 8) + " 00:00:00").getTime());
        // 登録時間取得
        java.sql.Timestamp regDt = getCurrentDate();
        // 当日の検査結果があるかどうかを問い合わせる
        PatExamMain oldpatExamMain = new PatExamMainData();
        // mod 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 関 start
        // if (!"0".equals(e.get("regOrderClass")) && !"1".equals(e.get("phyOrdClass"))) {
        if (!"1".equals(e.get("phyOrdClass"))) {
          // mod 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 関 end
          // 個別オーダ番号にする条件
          // （検査区分がその他、もしくは追加対象の検査セットの種別が生理検査）
          // でない場合
          // 施設コード、患者ID、検査日、検査区分、
          // 血液検査/心電図フラグが一致する既存のレコードを検索する
          oldpatExamMain = patExamMainDao.selectOneByPatIdAndFacilityCdAndRegExamDate(
            Long.parseLong(e.get("patId")),
            regExamDate.toString().substring(0, 10),
            facilityCd,
            e.get("regOrderClass"),
            e.get("phyOrdClass")
          );
        }
        if (oldpatExamMain != null && oldpatExamMain.getExamMainCd() != null) {
          //add 障害票一覧_检查予定 張岩 start
          oldpatExamMain.setPatId(Long.parseLong(e.get("patId")));
          oldpatExamMain.setRegOrderClass(e.get("regOrderClass"));
          oldpatExamMain.setOrderExamSetInfo(e.get("orderExamSetInfo"));
          oldpatExamMain.setExamOrderInfo(e.get("examOrderInfo"));
          // mod 11602 検査の「院内／院外」を検査項目マスタに持たせる zkm start
//          oldpatExamMain.setOrderLabelInfo(e.get("orderLabelInfo"));
          oldpatExamMain.setOrderLabelInfo("[]");
          // mod 11602 検査の「院内／院外」を検査項目マスタに持たせる zkm end
          oldpatExamMain.setIsLock(e.get("isLock"));
          oldpatExamMain.setIndUserId(Long.parseLong(e.get("indUserId")));
          oldpatExamMain.setIsDel("0");
          oldpatExamMain.setUpDate(regDt);
          oldpatExamMain.setUpStaff(userId);
          oldpatExamMain.setRegDate(regDt);
          oldpatExamMain.setRegStaff(userId);
          oldpatExamMain.setPhyOrdClass(e.get("phyOrdClass"));
          if ("1".equals(oldpatExamMain.getIsOrder())) {
            oldpatExamMain.setExamStatus("0");
          } else {
            oldpatExamMain.setExamStatus("1");
          }
          oldpatExamMain.setIsOrder("1");
          // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
          LogEventUtils.setOperatorId(oldpatExamMain,logService);
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
          // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end

          patExamMainDao.update(oldpatExamMain);
        } else {
          //add 結果を確認し、同じ日に同じレコードを処理します  張岩 end
          PatExamMain patExamMain = new PatExamMain() {
            {
              setPatId(Long.parseLong(e.get("patId")));
              setFacilityCd(facilityCd);
              setRegExamDate(regExamDate);
              setRegOrderClass(e.get("regOrderClass"));
              setExamStatus("0");
              setOrderExamSetInfo(e.get("orderExamSetInfo"));
              setExamOrderInfo(e.get("examOrderInfo"));
              // mod 11602 検査の「院内／院外」を検査項目マスタに持たせる zkm start
//              setOrderLabelInfo(e.get("orderLabelInfo"));
              setOrderLabelInfo("[]");
              // mod 11602 検査の「院内／院外」を検査項目マスタに持たせる zkm end
              setIsLock(e.get("isLock"));
              setIndUserId(Long.parseLong(e.get("indUserId")));
              setIsDel("0");
              setUpDate(regDt);
              setUpStaff(userId);
              setRegDate(regDt);
              setRegStaff(userId);
              setIsOrder("1");
              // #10483 add pat_exam_mainにdata_gen_classをnullで登録する処理が存在する。 2024-04-25 卓 start
              setDataGenClass("0");
              // #10483 add pat_exam_mainにdata_gen_classをnullで登録する処理が存在する。 2024-04-25 卓 end
              setPhyOrdClass(e.get("phyOrdClass"));
            }
          };
          patExamMainDao.insertOrderExamSetInfo(patExamMain);
          //#add 10125 検査予定に関する連携イベント作成不備 zrx start
          e.put("examMainCd", patExamMain.getExamMainCd() > 0 ? patExamMain.getExamMainCd().toString() : null);
          //#add 10125 検査予定に関する連携イベント作成不備 zrx end
          //add 結果を確認し、同じ日に同じレコードを処理します  張岩 end
        }
        //add 結果を確認し、同じ日に同じレコードを処理します  張岩 end
      } catch (ParseException ex) {
        throw new NotExistException("日付の変換に失敗しました。");
      }
    });
  }

  /**
   * データ更新.
   *
   * @param data   画面で編集したデータ
   * @param userId ログイン利用者ID
   */
  private void updateData(List<Map<String, String>> data, Long userId) {
    data.stream().filter(e -> e.get("operation").equals(UPDATE)).forEach(e -> {

      //add FNSI-「幹対応残課題一覧.xlsx」№10対応 田 start
      //      // 登録時間取得
      //      java.sql.Timestamp regDt = getCurrentDate();
      //
      //      PatExamMain patExamMain = new PatExamMain()
      //      {
      //        {
      //          setExamMainCd(Long.parseLong(e.get("examMainCd")));
      //          setOrderExamSetInfo(e.get("orderExamSetInfo"));
      //          setExamOrderInfo(e.get("examOrderInfo"));
      //          setOrderLabelInfo(e.get("orderLabelInfo"));
      //          setIsLock(e.get("isLock"));
      //          setIndUserId(Long.parseLong(e.get("indUserId")));
      //          setIsDel(e.get("isDel"));
      //          setUpDate(regDt);
      //          setUpStaff(userId);
      //        }
      //      };
      //      patExamMainDao.updateOrderExamSetInfo(patExamMain);
      //add 障害票一覧_检查予定 張岩 start
      // 登録時間取得
      Timestamp regDt = getCurrentDate();
      // 変換対象の日付文字列
      SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
      //add 障害票一覧_检查予定 張岩 end
      PatExamMain patExamMain = new PatExamMain() {
        {
          setExamMainCd(Long.parseLong(e.get("examMainCd")));
        }
      };
      PatExamMain ma = patExamMainDao.selectPatExamMain(patExamMain.getExamMainCd());

      PatExamMainHst patExamMainhst = new PatExamMainHst() {
        {
          setPatId(ma.getPatId());
          setFacilityCd(ma.getFacilityCd());
          setRegExamDate(ma.getRegExamDate());
          setRegOrderClass(ma.getRegOrderClass());
          setExamStatus(ma.getExamStatus());
          setOrderExamSetInfo(ma.getOrderExamSetInfo());
          setExamOrderInfo(ma.getExamOrderInfo());
          setOrderLabelInfo(ma.getOrderLabelInfo());
          setIsLock(ma.getIsLock());
          //del #7037 exam_ord連携で送信する利用者番号 zhaoqi 20220914 start
          //setIndUserId(ma.getIndUserId());
          //del #7037 exam_ord連携で送信する利用者番号 zhaoqi 20220914 end
          //add #7037 exam_ord連携で送信する利用者番号 zhaoqi 20220914 start
          if(data.get(0).get("indUserId") != null){
            setIndUserId(Long.valueOf(data.get(0).get("indUserId")));
          }
          //add #7037 exam_ord連携で送信する利用者番号 zhaoqi 20220914 end
          setIsDel(ma.getIsDel());

          //7037 修改hst表数据里的注册和更新人是当前userId而不是从PatExamMain获取 str
          setUpDate(regDt);
          setUpStaff(userId);
          setRegDate(ma.getRegDate());
          setRegStaff(ma.getRegStaff());
          //7037 修改hst表数据里的注册和更新人是当前userId而不是从PatExamMain获取 end

          setIsOrder(ma.getIsOrder());
          setExamMainCd(ma.getExamMainCd());
          setOrdNo(ma.getOrdNo());
          setFnPatId(ma.getFnPatId());
          setOrderComment(ma.getOrderComment());
          setDataGenClass(ma.getDataGenClass());
          setResultExamDate(ma.getResultExamDate());
          setResultComment(ma.getResultComment());
          setExamResultInfo(ma.getExamResultInfo());
          setCopOrderNo1(ma.getCopOrderNo1());
          setCopOrderNo2(ma.getCopOrderNo2());
          setPhyOrdClass(ma.getPhyOrdClass());
        }
      };
      if (e.get("isDel").equals("1") && ma.getExamStatus().equals("0")) {
    	// 中止で検査結果なしの場合はDELETEする
        patExamMainhstDao.insertOrderExamHstSetInfo(patExamMainhst);
        patExamMainDao.deleteByExamMainCd(patExamMain);
      }
      //ここを取り消した 何がしたいのわかりない
      //patExamMainDao.deleteByExamMainCd(patExamMain);
      //add 20210205「障害票一覧_検査予定.xlsx」7対応 顔 start
      String time = e.get("strExamDate").toString();
      e.put("strExamDate", time.substring(0, 4) + "-" + time.substring(4, 6) + "-" + time.substring(6, 8) + " 00:00:00");

      // DB更新ログ出力ロジック xie Start
      String tableName = "pat_exam_main";
      // SQL検索条件
      StringBuffer wheres = new StringBuffer("");
      wheres.append(" WHERE\n");
      wheres.append(" pat_id = '" + e.get("patId").toString() + "' and\n");
      wheres.append(" reg_exam_date = '" + time + "' \n");
      // logCommon設定
      DataUpdateLogCommonNew logCommon = getLogCommon(patExamMainDao, tableName, wheres, getEventLogMessage());
      // ログ出力カラム情報及び更新前データ情報取得
      boolean setResult = logCommon.setInfo();
      // DB更新ログ出力ロジック xie End
      //add 障害票一覧_检查予定 張岩 start
      patExamMain.setPatId(Long.parseLong(e.get("patId")));
      patExamMain.setRegOrderClass(e.get("regOrderClass"));
      patExamMain.setOrderExamSetInfo(e.get("orderExamSetInfo"));
      patExamMain.setExamOrderInfo(e.get("examOrderInfo"));
//      patExamMain.setOrderLabelInfo(e.get("orderLabelInfo"));
      patExamMain.setOrderLabelInfo("[]");
      patExamMain.setIsLock(e.get("isLock"));
      if(e.get("indUserId") != null){
        patExamMain.setIndUserId(Long.parseLong(e.get("indUserId")));
      }
      //mod 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao start
      patExamMain.setIsDel(ma.getIsDel());
      //mod 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao end

      patExamMain.setUpDate(regDt);
      patExamMain.setUpStaff(userId);
      patExamMain.setRegDate(regDt);
      patExamMain.setRegStaff(userId);
      // 中止で検索結果ありの場合は検査予定を[]で更新するため、is_order -> 0に更新する
      if (e.get("isDel").equals("1") && ma.getExamStatus().equals("1")) {
      	patExamMain.setIsOrder("0");
      } else {
      	patExamMain.setIsOrder("1");
      }

      // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
      LogEventUtils.setOperatorId(patExamMain,logService);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
      // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end

      int updateCount = patExamMainDao.update(patExamMain);
      //add 障害票一覧_检查予定 張岩 end
      // DB更新ログ出力ロジック wangzuo Start
      // 更新後データ取得、差分あれば、log出力
      if (setResult && updateCount > 0) {
        logCommon.updateLog();
      }
      // DB更新ログ出力ロジック wangzuo End
      //add 「障害票一覧_検査予定.xlsx」7対応 顔 end
      //add FNSI-「幹対応残課題一覧.xlsx」№10対応 田 end
    });
  }

  /**
   * 期間内に当てはまる検査パターンを登録
   *
   * @param params 以下の３つを含む
   *               patId 患者ID
   *               fromDate 期間開始日 ('YYYY/MM/DD')
   *               toDate 期間終了日 ('YYYY/MM/DD')
   */
  @Override
  @Transactional
  public void createPatExamMain(Map<String, String> params) throws Exception {
    try {

      Date fromDt = Date.valueOf(params.get("fromDate").replace("/", "-"));
      Date toDt = Date.valueOf(params.get("toDate").replace("/", "-"));
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("createPatExamMain Start!");
      logService.log(LogLevel.INFO, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 end

      //期間内に当てはまるパターンを取得
      List<PatExamPattern> patExamPatternList = patExamPatternDao.selectPatExamPatternList(params);

      //取得したレコード分ループ処理
      patExamPatternList.forEach(patExamPattern -> {

        //検査パターンをもとに登録する日付一覧を取得
        List<Date> dateList = getCreateDate(patExamPattern.getExamFrom(), patExamPattern.getExamTo(),
          fromDt, toDt, patExamPattern.getExamPattern(), patExamPattern.getExamWeek());

        // DBから検査セット情報をとってくる
        MstExamSet mstExamSet = mstExamSetDao.selectExamSetByCd(patExamPattern.getOrderExamSetCd());

        //取得した日付分ループ処理
        dateList.forEach(dt -> {

          Timestamp regExamDate = new Timestamp(dt.getTime());

          // 同じ患者・日付・タイミングの検査を検索
          List<PatExamMain> patExamMainList = patExamMainDao
            .selectPatExamMainByPatIdRegexamdateOrderclass(
              patExamPattern.getPatId(),
              regExamDate,
              patExamPattern.getRegOrderClass()
            );

          // 検査予定の取得結果に応じてUpdate/Insertを変える
          if (patExamMainList.size() != 0) {
            // JSONの更新
            // OrderExamSetInfo更新
            StringBuilder sbExamSetInfo = new StringBuilder();
            Integer intNo = 0;  // 通し番号
            try {
              List<PatExamMainOrderExamSetInfo> orderExamSetInfo =
                patExamMainList.get(0).getOrderExamSetInfo() == null || patExamMainList.get(0).getOrderExamSetInfo().isEmpty()
                  ? new ArrayList<>()
                  : new ObjectMapper().readValue(patExamMainList.get(0).getOrderExamSetInfo(), new TypeReference<List<PatExamMainOrderExamSetInfo>>() {
                });

              // 同じ検査セットがあるか最後まで検索
              boolean existExamItemSetCd = false;
              for (int idx = 0; idx < orderExamSetInfo.size(); idx++) {
                if (patExamPattern.getOrderExamSetCd().equals(orderExamSetInfo.get(idx).getSet_cd())) {
                  // 同じ exam_item_set_cd があればセット名を更新
                  intNo = orderExamSetInfo.get(idx).getNo();
                  PatExamMainOrderExamSetInfo updateOrderExamSetInfo = orderExamSetInfo.get(idx);
                  updateOrderExamSetInfo.setSet_name(mstExamSet.getExamSetName());
                  orderExamSetInfo.set(idx, updateOrderExamSetInfo);
                  existExamItemSetCd = true;
                }
              }
              // 同じ exam_item_set_cd がなければ1件レコード追加
              if (!existExamItemSetCd) {
                int intNoForSet = orderExamSetInfo.size() + 1; // no は最大件数+1
                intNo = intNoForSet;
                PatExamMainOrderExamSetInfo addOrderExamSetInfo = new PatExamMainOrderExamSetInfo() {
                  {
                    setNo(intNoForSet);
                    setSet_cd(patExamPattern.getOrderExamSetCd());
                    setSet_name(mstExamSet.getExamSetName());
                  }
                };
                orderExamSetInfo.add(addOrderExamSetInfo);
              }

              // StringBuilderに変換
              orderExamSetInfo.stream().forEach(exam -> sbExamSetInfo.append("," + exam.getValue()));

              // 文字列の前後に"["と"]"を付け加える
              sbExamSetInfo.delete(0, 1);
              sbExamSetInfo.insert(0, "[");
              sbExamSetInfo.append("]");

            } catch (IOException e) {
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
              EventLogMessage eventLogMessageNew = new EventLogMessage();
              eventLogMessageNew.setLogMessage(ExcetionStackTraceToString(e));
              logService.log(LogLevel.ERROR, eventLogMessageNew, "", LoggingConstant.SERVICE_NAME.FNSI, null);
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
            }

            // ExamOrderInfo更新
            StringBuilder sbExamOrderInfo = new StringBuilder();
            try {
              // 既存レコードのデータを取得する
              List<PatExamMainExamOrderInfo> examOrderInfo =
                patExamMainList.get(0).getExamOrderInfo() == null || patExamMainList.get(0).getExamOrderInfo().isEmpty()
                  ? new ArrayList<>()
                  : new ObjectMapper().readValue(patExamMainList.get(0).getExamOrderInfo(), new TypeReference<List<PatExamMainExamOrderInfo>>() {
                });

              // 通し番号と同じのがあれば削除
              int delIdx = 0;
              while (delIdx < examOrderInfo.size()) {
                if (intNo.equals(examOrderInfo.get(delIdx).getNo())) {
                  examOrderInfo.remove(delIdx);
                } else {
                  delIdx++;
                }
              }

              // パターンの元データを取得する
              List<PatExamPatternExamOrderInfo> patternExamOrderInfo =
                patExamPattern.getExamOrderInfo() == null || patExamPattern.getExamOrderInfo().isEmpty()
                  ? new ArrayList<>()
                  : new ObjectMapper().readValue(patExamPattern.getExamOrderInfo(), new TypeReference<List<PatExamPatternExamOrderInfo>>() {
                });

              // パターンの検査項目データをすべて追加登録
              for (int idx = 0; idx < patternExamOrderInfo.size(); idx++) {
                Long examItemCd = patternExamOrderInfo.get(idx).getExam_item_cd();
                String examItemName = patternExamOrderInfo.get(idx).getExam_item_name();
                Integer examNo = intNo;

                PatExamMainExamOrderInfo addExamOrderInfo = new PatExamMainExamOrderInfo() {
                  {
                    setNo(examNo);
                    setItem_cd(examItemCd);
                    setItem_name(examItemName);
                  }
                };
                examOrderInfo.add(addExamOrderInfo);
              }

              // 通し番号順にソート
              Collections.sort(examOrderInfo, new Comparator<PatExamMainExamOrderInfo>() {
                public int compare(PatExamMainExamOrderInfo info1, PatExamMainExamOrderInfo info2) {
                  if (info1.getNo().compareTo(info2.getNo()) < 0) {
                    return -1;
                  } else {
                    return 1;
                  }
                }
              });

              // StringBuilderに変換
              examOrderInfo.stream().forEach(exam -> sbExamOrderInfo.append("," + exam.getValue()));

              // 文字列の前後に"["と"]"を付け加える
              sbExamOrderInfo.delete(0, 1);
              sbExamOrderInfo.insert(0, "[");
              sbExamOrderInfo.append("]");

            } catch (IOException e) {
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
              EventLogMessage eventLogMessageNew = new EventLogMessage();
              eventLogMessageNew.setLogMessage(ExcetionStackTraceToString(e));
              logService.log(LogLevel.ERROR, eventLogMessageNew, "", LoggingConstant.SERVICE_NAME.FNSI, null);
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
            }

            // OrderLabelInfo更新
            StringBuilder sbOrderLabelInfo = new StringBuilder();

            try {
              // 既存レコードのデータを取得する
              List<PatExamMainOrderLabelInfo> orderLabelInfo =
                patExamMainList.get(0).getOrderLabelInfo() == null || patExamMainList.get(0).getOrderLabelInfo().isEmpty()
                  ? new ArrayList<>()
                  : new ObjectMapper().readValue(patExamMainList.get(0).getOrderLabelInfo(), new TypeReference<List<PatExamMainOrderLabelInfo>>() {
                });

              // パターンの元データを取得する
              List<PatExamPatternOrderLabelInfo> patternOrderLabelInfo =
                patExamPattern.getOrderLabelInfo() == null || patExamPattern.getOrderLabelInfo().isEmpty()
                  ? new ArrayList<>()
                  : new ObjectMapper().readValue(patExamPattern.getOrderLabelInfo(), new TypeReference<List<PatExamPatternOrderLabelInfo>>() {
                });

              // パターンの元データを確認する
              for (int ptnIdx = 0; ptnIdx < patternOrderLabelInfo.size(); ptnIdx++) {
                // 既存レコードのデータを確認する
                List<PatExamMainOrderLabelInfo> updateOrderLabelInfoList = new ArrayList<>();
                int updateIdx = 99999;
                for (int idx = 0; idx < orderLabelInfo.size(); idx++) {
                  // 同じexam_spitz_cdのデータがあるか確認
                  if (orderLabelInfo.get(idx).getSpitz_cd().equals(patternOrderLabelInfo.get(ptnIdx).getSpitz_cd())) {
                    // 同じ採血管コードがあるため更新対象データを抽出
                    updateOrderLabelInfoList.add(orderLabelInfo.get(idx));
                    updateIdx = idx;
                  }
                }

                if (updateOrderLabelInfoList.size() == 0) {
                  // 新規
                  //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 20240410 ztc start
//                  String orderSpitzNo = patternOrderLabelInfo.get(ptnIdx).getSpitz_cd();
                  Long orderSpitzNo = patternOrderLabelInfo.get(ptnIdx).getSpitz_cd();
                  //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 20240410 ztc end

                  PatExamMainOrderLabelInfo addOrderLabelInfo = new PatExamMainOrderLabelInfo() {
                    {
                      setSpitz_cd(orderSpitzNo);
                    }
                  };
                  orderLabelInfo.add(addOrderLabelInfo);
                }
              }
              // StringBuilderに変換
              orderLabelInfo.stream().forEach(exam -> sbOrderLabelInfo.append("," + exam.getValue()));

              // 文字列の前後に"["と"]"を付け加える
              sbOrderLabelInfo.delete(0, 1);
              sbOrderLabelInfo.insert(0, "[");
              sbOrderLabelInfo.append("]");

            } catch (IOException e) {
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
              EventLogMessage eventLogMessageNew = new EventLogMessage();
              eventLogMessageNew.setLogMessage(ExcetionStackTraceToString(e));
              logService.log(LogLevel.ERROR, eventLogMessageNew, "", LoggingConstant.SERVICE_NAME.FNSI, null);
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
            }

            // 登録情報の作成
            PatExamMain updatePatExamMain = new PatExamMain() {
              {
                setExamMainCd(patExamMainList.get(0).getExamMainCd());
                setOrderExamSetInfo(sbExamSetInfo.toString());
                setExamOrderInfo(sbExamOrderInfo.toString());
                // mod 11602 検査の「院内／院外」を検査項目マスタに持たせる zkm start
//                setOrderLabelInfo(sbOrderLabelInfo.toString());
                setOrderLabelInfo("[]");
                // mod 11602 検査の「院内／院外」を検査項目マスタに持たせる zkm end
                setIsLock(patExamMainList.get(0).getIsLock());
                setIndUserId(patExamMainList.get(0).getIndUserId());
                setIsDel("0");
                setUpDate(getCurrentDate());
              }
            };

            // update処理
            patExamMainDao.updateOrderExamSetInfo(updatePatExamMain);

          } else {
            // OrderExamSetInfo新規追加
            StringBuilder sbExamSetInfo = new StringBuilder();
            PatExamMainOrderExamSetInfo orderExamSetInfo = new PatExamMainOrderExamSetInfo() {
              {
                setNo(1);
                setSet_cd(patExamPattern.getOrderExamSetCd());
                setSet_name(mstExamSet.getExamSetName());
              }
            };
            sbExamSetInfo.append(orderExamSetInfo.getValue());

            sbExamSetInfo.insert(0, "[");
            sbExamSetInfo.append("]");

            // ExamOrderInfo新規追加
            StringBuilder sbExamOrderInfo = new StringBuilder();
            List<PatExamMainExamOrderInfo> examOrderInfo = new ArrayList<>();
            try {
              // 元データを取得する
              List<PatExamPatternExamOrderInfo> patternExamOrderInfo =
                patExamPattern.getExamOrderInfo() == null || patExamPattern.getExamOrderInfo().isEmpty()
                  ? new ArrayList<>()
                  : new ObjectMapper().readValue(patExamPattern.getExamOrderInfo(), new TypeReference<List<PatExamPatternExamOrderInfo>>() {
                });

              // パターンの検査項目データをすべて登録
              for (int idx = 0; idx < patternExamOrderInfo.size(); idx++) {
                Long examItemCd = patternExamOrderInfo.get(idx).getExam_item_cd();
                String examItemName = patternExamOrderInfo.get(idx).getExam_item_name();

                PatExamMainExamOrderInfo addExamOrderInfo = new PatExamMainExamOrderInfo() {
                  {
                    setNo(1);
                    setItem_cd(examItemCd);
                    setItem_name(examItemName);
                  }
                };
                examOrderInfo.add(addExamOrderInfo);
              }

              // StringBuilderに変換
              examOrderInfo.stream().forEach(exam -> sbExamOrderInfo.append("," + exam.getValue()));

              // 文字列の前後に"["と"]"を付け加える
              sbExamOrderInfo.delete(0, 1);
              sbExamOrderInfo.insert(0, "[");
              sbExamOrderInfo.append("]");

            } catch (IOException e) {
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
              EventLogMessage eventLogMessageNew = new EventLogMessage();
              eventLogMessageNew.setLogMessage(ExcetionStackTraceToString(e));
              logService.log(LogLevel.ERROR, eventLogMessageNew, "", LoggingConstant.SERVICE_NAME.FNSI, null);
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
            }

            // OrderLabelInfo新規作成はpat_exam_patternの内容をそのまま持ってくるため何もしない

            // 登録情報の作成
            PatExamMain insertPatExamMain = new PatExamMain() {
              {
                setPatId((long) patExamPattern.getPatId());
                setFacilityCd(patExamPattern.getFacilityCd());
                setFnPatId(patExamPattern.getFnPatId());
                setRegExamDate(regExamDate);
                setRegOrderClass(patExamPattern.getRegOrderClass());
                setExamStatus("0");
                setOrderExamSetInfo(sbExamSetInfo.toString());
                setExamOrderInfo(sbExamOrderInfo.toString());
                setOrderLabelInfo(patExamPattern.getOrderLabelInfo());
                setDataGenClass("0");
                setIsDel("0");
                setUpDate(getCurrentDate());
                setRegDate(getCurrentDate());
              }
            };

            // insert処理
            patExamMainDao.insertOrderExamSetInfo(insertPatExamMain);
          }
        });
      });
    } catch (Exception e) {
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("エラー");
      logService.log(LogLevel.ERROR, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
      eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 end
      throw new Exception(e);
    }
  }

  /**
   * 検査再計算依頼キューテーブル追加登録
   *
   * @param params
   */
  @Override
  @Transactional
  public void createMntRecalcQue(Map<String, String> params) throws Exception {
    MntRecalcQue mntRecalcQue = new MntRecalcQue() {
      {
        setFacilityCd(params.get("facilityCd"));
        setStatus(params.get("status"));
        setRegId(params.get("regId"));
        setDetail(params.get("detail"));
        setContent(params.get("content"));
        setUpId(params.get("upId"));
        setDispFlg("1");
        setDelFlg("0");
      }
    };
    ;
    mntRecalcQueDao.insertWithSeq(mntRecalcQue);
  }

  /**
   * 検査再計算依頼キューテーブル追加更新
   *
   * @param params
   */
  @Override
  @Transactional
  public void updateMntRecalcQue(Map<String, String> params) throws Exception {
    MntRecalcQue mntRecalcQue = new MntRecalcQue() {
      {
        setStatus(params.get("status"));
        setContent(params.get("content"));
        setDetail(params.get("details"));
        setUpId(params.get("upId"));
        setDispFlg(params.get("dispFlg"));
        setRecalcQueCd(Long.parseLong(params.get("recalcQueCd")));
      }
    };
    ;

    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
    LogEventUtils.setOperatorId(mntRecalcQue,logService);
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
    mntRecalcQueDao.update(mntRecalcQue);
  }

  /**
   * 期間内にマッチする検査パターンの日付一覧を取得
   *
   * @param patternFromDt 患者検査パターン：期間開始日
   * @param patternToDt   患者検査パターン：期間終了日
   * @param paramFromDt   期間開始日
   * @param paramToDt     期間終了日
   * @param pattern       検査パターン
   * @param dayOfWeek     曜日
   */
  private List<Date> getCreateDate(Date patternFromDt, Date patternToDt,
                                   Date paramFromDt, Date paramToDt, int pattern, int dayOfWeek) {
    List<Date> dateList = new ArrayList<>();
    List<Integer> weekList = new ArrayList<>();

    //パターンにより、登録する週を取得
    switch (pattern) {
      case 1: // 指定日1回分(パターンには入らない)
        weekList.add(0);
        break;
      case 2: // 月１：第1週
        weekList.add(1);
        break;
      case 3: // 月１：第2週
        weekList.add(2);
        break;
      case 4: // 月１：第3週
        weekList.add(3);
        break;
      case 5: // 月１：第4週
        weekList.add(4);
        break;
      case 6: // 月２：第1週、第3週
        weekList.add(1);
        weekList.add(3);
        break;
      case 7: // 月２：第2週、第4週
        weekList.add(2);
        weekList.add(4);
        break;
      case 8: // 年間複数日指定(パターンには入らない)
        weekList.add(0);
        break;
      case 9: // 隔週
        dateList = getCreateBiWeeklyDate(patternFromDt, patternToDt, paramFromDt, paramToDt, dayOfWeek);
        return dateList;
    }

    // カレンダーの開始・終了日設定
    //ベースとなる期間開始日と期間終了日を取得
    Date baseFromDt = patternFromDt.after(paramFromDt) ? patternFromDt : paramFromDt;
    Date baseToDt = patternToDt.after(paramToDt) ? paramToDt : patternToDt;
    Calendar calBaseFrom = Calendar.getInstance();
    Calendar calBaseTo = Calendar.getInstance();
    calBaseFrom.setTime(baseFromDt);
    calBaseTo.setTime(baseToDt);

    //期間開始から終了までをループ処理
    while (calBaseFrom.before(calBaseTo) || calBaseFrom.equals(calBaseTo)) {

      //週がマッチした場合、曜日判定
      if (weekList.contains(calBaseFrom.get(Calendar.DAY_OF_WEEK_IN_MONTH))) {

        Date dt = new Date(calBaseFrom.getTime().getTime());

        //曜日がマッチした場合、Listに追加
        switch (dayOfWeek) {
          case 1:
            if (calBaseFrom.get(Calendar.DAY_OF_WEEK) == 2) dateList.add(dt);
            break;
          case 2:
            if (calBaseFrom.get(Calendar.DAY_OF_WEEK) == 3) dateList.add(dt);
            break;
          case 3:
            if (calBaseFrom.get(Calendar.DAY_OF_WEEK) == 4) dateList.add(dt);
            break;
          case 4:
            if (calBaseFrom.get(Calendar.DAY_OF_WEEK) == 5) dateList.add(dt);
            break;
          case 5:
            if (calBaseFrom.get(Calendar.DAY_OF_WEEK) == 6) dateList.add(dt);
            break;
          case 6:
            if (calBaseFrom.get(Calendar.DAY_OF_WEEK) == 7) dateList.add(dt);
            break;
          case 7:
            if (calBaseFrom.get(Calendar.DAY_OF_WEEK) == 1) dateList.add(dt);
            break;
        }
      } else if (weekList.contains(0)) {
        // 指定日１回分または複数日指定の場合は上記処理を行わない
        return dateList;
      }
      ;

      // 対象日時を進める
      calBaseFrom.add(Calendar.DATE, 1);
    }

    return dateList;
  }

  /**
   * 期間内にマッチする検査パターンの日付一覧を取得(隔週)
   *
   * @param patternFromDt 患者検査パターン：期間開始日
   * @param patternToDt   患者検査パターン：期間終了日
   * @param paramFromDt   期間開始日
   * @param paramToDt     期間終了日
   * @param dayOfWeek     曜日
   */
  private List<Date> getCreateBiWeeklyDate(Date patternFromDt, Date patternToDt,
                                           Date paramFromDt, Date paramToDt, int dayOfWeek) {
    List<Date> dateList = new ArrayList<>();

    // 検査パターンの開始日付を取得
    Date biweeklyPtnFromDt = patternFromDt;
    Calendar calBiweeklyPtnFrom = Calendar.getInstance();
    calBiweeklyPtnFrom.setTime(biweeklyPtnFromDt);

    // 指定期間の開始日付を取得
    Date biweeklyPrmFromDt = paramFromDt;
    Calendar calBiweeklyPrmFrom = Calendar.getInstance();
    calBiweeklyPrmFrom.setTime(biweeklyPrmFromDt);

    // 終了日付を取得
    Date biweeklyToDt = patternToDt.after(paramToDt) ? paramToDt : patternToDt;
    Calendar calBiweeklyTo = Calendar.getInstance();
    calBiweeklyTo.setTime(biweeklyToDt);

    // 曜日値の調整
    // dayOfWeek: 1：月曜日 ～ 7：日曜日
    // Calendar.DAY_OF_WEEK: 1：日曜日 ～ 7：土曜日
    int ptnFromDayOfWeek = 0;
    if (calBiweeklyPtnFrom.get(Calendar.DAY_OF_WEEK) == 1) {
      ptnFromDayOfWeek = calBiweeklyPtnFrom.get(Calendar.DAY_OF_WEEK) + 6;  // 日曜日
    } else if (calBiweeklyPtnFrom.get(Calendar.DAY_OF_WEEK) >= 2) {
      ptnFromDayOfWeek = calBiweeklyPtnFrom.get(Calendar.DAY_OF_WEEK) - 1;  // 月～土曜日
    }

    // 基準日を取得(パターンの開始日付から一番近い指定曜日)
    int addDays = 0;
    if (ptnFromDayOfWeek <= dayOfWeek) {
      addDays = dayOfWeek - ptnFromDayOfWeek;
      calBiweeklyPtnFrom.add(Calendar.DATE, addDays);
    } else {
      addDays = 7 - (ptnFromDayOfWeek - dayOfWeek);
      calBiweeklyPtnFrom.add(Calendar.DATE, addDays);
    }

    // 隔週(14日毎)の日付を取得
    while (calBiweeklyPtnFrom.before(calBiweeklyTo) || calBiweeklyPtnFrom.equals(calBiweeklyTo)) {
      if (calBiweeklyPtnFrom.after(calBiweeklyPrmFrom)) {
        // 検査パターンの日付が指定期間後の場合、14日ごとの日付を登録する
        Date dt = new Date(calBiweeklyPtnFrom.getTime().getTime());
        dateList.add(dt);
      }
      // 対象日時を進める
      calBiweeklyPtnFrom.add(Calendar.DATE, 14);
    }

    return dateList;
  }

  /**
   * {@inheritDoc}
   */
  /* add #6358 by zhangruixue 2023-06-13 --start */
  @Override
  public String selectMinSchExtEndDatePost(String facility_cd,List<Long> patIdList) {
    return patMainDao.selectMinSchExtEndDateByFacilityAndPatIds(facility_cd,patIdList);
  }
  /* add #6358 by zhangruixue 2023-06-13 --end */

  // DB更新ログ出力ロジック xie Start

  /**
   * ログ出力共通クラス設定、取得
   *
   * @return logCommon ログ出力共通クラス
   */
  private DataUpdateLogCommonNew getLogCommon(Object dao, String tableName, StringBuffer whereStr, EventLogMessage eventLogMessage) {
    DataUpdateLogCommonNew logCommon = new DataUpdateLogCommonNew();
    logCommon.setEventLoggerFactory(eventLoggerFactory);
    logCommon.setLogServiceCore(logServiceCore);
    logCommon.setConfig(Config.get(dao));
    logCommon.setTableName(tableName);
    logCommon.setWhereStr(whereStr);
    logCommon.setCommonEventLogMessage(eventLogMessage);
    return logCommon;
  }

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
    eventLogMessage.setServiceName(LoggingConstant.MODULE_NAME.ADMIN_WEB + "," + LoggingConstant.SERVICE_NAME.FNSI);
    return eventLogMessage;
  }
  // DB更新ログ出力ロジック xie End

  /* add by Lm.Mingyue  2023-02-01 Transaction start */
  /**
   * FNSI-患者が死亡した後、検査依頼を削除します
   * @param facility_cd 登録施設コード
   */
  @Override
  @Transactional
  public int deleteDeadPatRequest(int overDeadlineCount, Map<String, Object> payload, NtssUser ntssUser) {
    // mod #10597 既往歴，入外・転入出による治療予定中止の動作が不正 20240514 ztc start
    ArrayList<Map<String, String>> moveOutDateMapList = CollectionUtils.isEmpty(Collections.singleton(payload.get("move_out_date")))
            ? new ArrayList<>() : (ArrayList<Map<String, String>>) payload.get("move_out_date");
    if(!CollectionUtils.isEmpty(moveOutDateMapList)){
      Long patId = Long.parseLong(Objects.isNull(payload.get("patId")) ? "0" : payload.get("patId").toString());
      String facilityCd = Objects.isNull(payload.get("facilityCd")) ? "0" : payload.get("facilityCd").toString();
      for(Map<String, String> moveOutDate : moveOutDateMapList) {
//    String dateFrom = payload.get("deleteDate").toString();
        String indStartDate = moveOutDate.get("ind_start_date");
        String indEndDate = moveOutDate.get("ind_end_date");

        // 死亡/転出、離脱、移植、通院拒否・不明日以降の予定データを取得
//        List<PatExamMain> examList = patExamMainDao.selectDeleteTarget(patId, facilityCd, dateFrom);
        List<PatExamMain> examList = patExamMainDao.selectDeleteTarget(patId, facilityCd, indStartDate, indEndDate);
        if (!CollectionUtils.isEmpty(examList)) {
          // 検査依頼変更締切り有無 1015
          String examChangeOnOffWithOrder = facilitySettingService.getFacilitySettingValue(facilityCd, CoreConstant.FacilitySettingNo.EXAM_CHANGE_ON_OFF_WITH_ORDER);
          // 締切りを過ぎているデータを削除対象から除外する
          if (examChangeOnOffWithOrder.equals("1")) {
            // 検査依頼変更締切り日数 1011
            String examScheduleChangeLimitDay = facilitySettingService.getFacilitySettingValue(facilityCd, CoreConstant.FacilitySettingNo.EXAM_SCHEDULE_CHANGE_LIMIT_DAY);
            // 検査依頼変更締切り時間 1012
            String examScheduleChangeLimitTime = facilitySettingService.getFacilitySettingValue(facilityCd, CoreConstant.FacilitySettingNo.EXAM_SCHEDULE_CHANGE_LIMIT_TIME);
            // 初期値の"0000"はエラーになる為補正
            if (examScheduleChangeLimitTime.equals("0000")) {
              examScheduleChangeLimitTime = "00:00";
            }
            int minutes = Integer.valueOf(examScheduleChangeLimitTime.substring(0, 2)) * 60 + Integer.valueOf(examScheduleChangeLimitTime.substring(3, 5));
            Long aLong = Long.valueOf(minutes);
            // 現在日に、締切り日数、時間を加算
            LocalDateTime nowLdt = Timestamp.valueOf(new SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) + " 00:00:00").toLocalDateTime();
            LocalDateTime deadlineLdt = nowLdt.plusDays(Long.valueOf(examScheduleChangeLimitDay)).plusMinutes(aLong);
            String deadlineDate = Timestamp.valueOf(deadlineLdt).toString();

            boolean timeOverFlg = false;
            String nowTime = new SimpleDateFormat("HH:mm:ss").format(new java.util.Date());
            if (nowTime.compareTo(deadlineDate.substring(11, 19)) > 0) {
              // 現在時刻が、締切り時間を過ぎていた場合、現在日 + 締切り日数 の日付の予定を、締め切りを過ぎたものとして扱う
              timeOverFlg = true;
            }

            // 締切りを過ぎているレコードをリストに取得する
            List<PatExamMain> overList = new ArrayList<>();
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            String deadlineDay = deadlineDate.substring(0, 10);
            for (PatExamMain exam : examList) {
              String regExamDate = sdf.format(exam.getRegExamDate());
              if (timeOverFlg) {
                if (deadlineDay.compareTo(regExamDate) >= 0) {
                  overList.add(exam);
                }
              } else {
                if (deadlineDay.compareTo(regExamDate) > 0) {
                  overList.add(exam);
                }
              }
            }
            // 締切りを過ぎているレコードを除外する
            for (PatExamMain idx : overList) {
              examList.remove(idx);
            }
            // 締切りを過ぎていたレコード件数を応答に含める
//          overDeadlineCount = overList.size();
            overDeadlineCount += overList.size();
          }

          // 削除対象の exam_main_cd リストを作成
          List<Long> examMainCdList = examList.stream().map(item -> item.getExamMainCd()).distinct().collect(Collectors.toList());
          // 削除を実施
          Long upStaff = ntssUser.getUserId();
          Long indUserId = Long.parseLong(Objects.isNull(payload.get("indUserId")) ? ntssUser.getUserId().toString() : payload.get("indUserId").toString());
          int i = patExamMainDao.deleteExamRequestByPatId(facilityCd, patId, upStaff, indUserId, examMainCdList);
          // add 10553 連携イベント発生部分不正 関 start
          PatPersonalMain patSrc = patPersonalMainDao.selectById(patId);
          // add 10553 連携イベント発生部分不正 関 end
          // 削除完了後の処理
          if (i > 0) {
            SimpleDateFormat sdf2 = new SimpleDateFormat("yyyyMMdd");
            String type = payload.get("type").toString();
            // mod 10553 連携イベント発生部分不正 関 start
            // String opeCd = type.equals("death") ? "031003" : "007010";
            // 連携イベントの登録処理
            for (PatExamMain exam : examList) {
              // exam_main_cd 毎に連携イベントの登録処理を実施する
              JournalCreateRequestPayload sendPayload = new JournalCreateRequestPayload();
              sendPayload.setFacilityCd(facilityCd);
              // mod 10553 生理検査送信連携不正 関  start
              // sendPayload.setCoopCd("exam_ord");
              if (exam.getPhyOrdClass() != null && "1".equals(exam.getPhyOrdClass() )) {
                sendPayload.setCoopCd("phy_ord");
                sendPayload.setOpeCd(type.equals("death") ? "031013" : "007020");
              } else {
                sendPayload.setCoopCd("exam_ord");
                sendPayload.setOpeCd(type.equals("death") ? "031003" : "007010");
              }
              sendPayload.setCrud("D");
              sendPayload.setPatId(patId);
              sendPayload.setOrdNo(exam.getExamMainCd());
              sendPayload.setBaseDate(sdf2.format(exam.getRegExamDate()));
              sendPayload.setUserId(ntssUser.getUserId());
              if (patSrc != null) {
                sendPayload.setHospPatId(patSrc.getHosp_pat_id());
              }
              // mod 10553 生理検査送信連携不正 関  end
              journalService.callCreateJournalForPayload(sendPayload);
            }
            // mod 10553 連携イベント発生部分不正 関 end
            // 削除処理が実施された場合に、パターンの削除処理も実施
            // mod #10553 ②死亡、転出、一時転出のスケジュール(治療、検査依頼、一般撮影検査依頼)の削除に合わせて連携イベントを発生させるように修正が必要 start
            if("99991231".equals(indEndDate)){
//          patExamPatternDao.updateIsDelByPatIdAndExamTo(patId, facilityCd, dateFrom, ntssUser.getUserId(), indUserId);
              patExamPatternDao.updateIsDelByPatIdAndExamTo(patId, facilityCd, indStartDate, indEndDate, ntssUser.getUserId(), indUserId);
            }
            // mod #10553 ②死亡、転出、一時転出のスケジュール(治療、検査依頼、一般撮影検査依頼)の削除に合わせて連携イベントを発生させるように修正が必要 end
          }
        }
      }
      // mod #10597 既往歴，入外・転入出による治療予定中止の動作が不正 20240514 ztc end
    }
    return overDeadlineCount;
  }
  /* add by Lm.Mingyue  2023-02-01 Transaction end */
  public List<MstExamSet> selectExamsetByPhyOrdClass(String facilityCd){
    return mstExamSetDao.selectExamsetByPhyOrdClass(facilityCd);
  }

  // 9729-検査再計算ツール画面について 20231115仕様変更 zhoubin add start
  /**
   * 患者検査結果取得用(再計算用)
   *
   * @param facilityCd 施設コード
   * @param startDate
   * @param endDate
   * @return 検査結果のResponse
   */
  @Override
  public List<PatPersonalMainData> getPatListByFacilityCd(String facilityCd, String startDate, String endDate) {
    List<PatPersonalMainData> resultList = new ArrayList<>();
    List<String> facilityCdList = new ArrayList<>();
    facilityCdList.add(facilityCd);
    FacilitySettingInfo settingValue = mstFacilitySettingDao.getBySettingNoAndCd(facilityCd, CoreConstant.FacilitySettingNo.SIMPLE_SEARCH_CONDITIONS);
    int conditionalSearchPatient = Integer.parseInt(settingValue.getValue());

    List<PatMain> patMainList = patMainDao.selectByCdListAndSetting(facilityCdList, conditionalSearchPatient);
    List<PatPersonalMain> patPersonalMainList = patPersonalMainDao.selectAllExamRstPat(facilityCdList);
    List<Long> patIdList = patExamMainDao.selectPatByFacilityCdAndDate(facilityCd, startDate, endDate);

    List<PatPersonalMain> ppmList = new ArrayList<>();
    for (PatPersonalMain patPersonalMain : patPersonalMainList) {
      for  (Long patId : patIdList){
        if (patPersonalMain.getPat_id().equals(patId)) {
          ppmList.add(patPersonalMain);
          break;
        }
      }
    }
    for (PatPersonalMain patPersonalMain : ppmList) {
      for (PatMain patMain : patMainList) {
        if (patPersonalMain.getPat_id().equals(patMain.getPat_id())) {
          PatPersonalMainData ppmData = new PatPersonalMainData();
          BeanUtils.copyProperties(patPersonalMain, ppmData);
          ppmData.setIs_same(patMain.getIs_same());
          ppmData.setIn_out_current_state(patMain.getIn_out_current_state());
          resultList.add(ppmData);
        }
      }
    }

    return resultList;
  }
  // 9729-検査再計算ツール画面について 20231115仕様変更 zhoubin add end

  //add #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 20240410 ztc start
  @Override
  public List<PatExamMain> selectExamByRegDate(String facilityCd, Long patId, String regExamDate){
    return patExamMainDao.selectExamByRegDate(facilityCd, patId, regExamDate);
  }

  @Override
  public List<PatExamMain> selectExamByRegDateAndOrderClass(String facilityCd, Long patId, String regExamDate, String regOrderClass){
    return patExamMainDao.selectExamByRegDateAndOrderClass(facilityCd, patId, regExamDate, regOrderClass);
  }
// del 10618 検査セットマスタ、検査項目マスタ、一般撮影検査依頼マスタ編集時に関連データを補正する 関  start
//  @Override
//  public void mergePatExamMain(List<PatExamMain> insertPatExamMainList, List<PatExamMain> updatePatExamMainList, List<PatExamMain> deletePatExamMainList) throws Exception {
//    List<JournalCreateRequestPayload> examordJournalList = new ArrayList<>();
//    if (!CollectionUtils.isEmpty(insertPatExamMainList)) {
//      int insertSucessCount = insertPatExamMainOfMergedList(insertPatExamMainList);
//      if (insertSucessCount > 0) {
//        String facilityCd = insertPatExamMainList.get(0).getFacilityCd();
//        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
//        for (int i = 0; i < insertPatExamMainList.size(); i++) {
//          JournalCreateRequestPayload journalParameter = new JournalCreateRequestPayload();
//          journalParameter.setAnaResult("0");
//          journalParameter.setBaseDate(sdf.format(insertPatExamMainList.get(i).getRegExamDate()));
//          if (insertPatExamMainList.get(i).getPhyOrdClass() != null && "1".equals(insertPatExamMainList.get(i).getPhyOrdClass())) {
//            journalParameter.setCoopCd("phy_ord");
//            journalParameter.setOpeCd("021011");
//          } else {
//            journalParameter.setCoopCd("exam_ord");
//            journalParameter.setOpeCd("021001");
//          }
//          journalParameter.setCoopCdIndex("");
//          journalParameter.setCoopResult("0");
//          journalParameter.setCrud("C");
//          journalParameter.setDirection("S");
//          journalParameter.setFacilityCd(facilityCd);
//          journalParameter.setOrdNo(insertPatExamMainList.get(i).getExamMainCd());
//          journalParameter.setPatId(insertPatExamMainList.get(i).getPatId());
//          journalParameter.setUserId(insertPatExamMainList.get(i).getIndUserId());
//          examordJournalList.add(journalParameter);
//        }
//      }
//    }
//    if (!CollectionUtils.isEmpty(updatePatExamMainList)) {
//      int updateSucessCount = updatePatExamMainOfMergedList(updatePatExamMainList);
//      if (updateSucessCount > 0) {
//        String facilityCd = updatePatExamMainList.get(0).getFacilityCd();
//        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
//        for (int i = 0; i < updatePatExamMainList.size(); i++) {
//          JournalCreateRequestPayload journalParameter = new JournalCreateRequestPayload();
//          journalParameter.setAnaResult("0");
//          journalParameter.setBaseDate(sdf.format(updatePatExamMainList.get(i).getRegExamDate()));
//          if (updatePatExamMainList.get(i).getPhyOrdClass() != null && "1".equals(updatePatExamMainList.get(i).getPhyOrdClass())) {
//            journalParameter.setCoopCd("phy_ord");
//            journalParameter.setOpeCd("021019");
//          } else {
//            journalParameter.setCoopCd("exam_ord");
//            journalParameter.setOpeCd("021009");
//          }
//          journalParameter.setCoopCdIndex("");
//          journalParameter.setCoopResult("0");
//          journalParameter.setCrud("U");
//          journalParameter.setDirection("S");
//          journalParameter.setFacilityCd(facilityCd);
//          journalParameter.setOrdNo(updatePatExamMainList.get(i).getExamMainCd());
//          journalParameter.setPatId(updatePatExamMainList.get(i).getPatId());
//          journalParameter.setUserId(updatePatExamMainList.get(i).getIndUserId());
//          examordJournalList.add(journalParameter);
//        }
//      }
//    }
//    if (!CollectionUtils.isEmpty(deletePatExamMainList)) {
//      //削除した予定をpatExamMainhstテーブルにバックアップする
//      deletePatExamMainList.stream().forEach(dpem -> {
//        PatExamMainHst patExamMainHst = new PatExamMainHst();
//        BeanUtils.copyProperties(dpem, patExamMainHst);
//        patExamMainHst.setExamMainCd(dpem.getExamMainCd());
//        patExamMainHst.setRegDate(new Timestamp(System.currentTimeMillis()));
//        patExamMainHst.setUpDate(new Timestamp(System.currentTimeMillis()));
//        patExamMainhstDao.insertOrderExamHstSetInfo(patExamMainHst);
//      });
//      int deleteSucessCount = deleteByExamMainCdList(deletePatExamMainList.stream()
//              .map(examMain -> examMain.getExamMainCd()).collect(Collectors.toList()));
//      if (deleteSucessCount > 0) {
//        String facilityCd = deletePatExamMainList.get(0).getFacilityCd();
//        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
//        for (int i = 0; i < deletePatExamMainList.size(); i++) {
//          JournalCreateRequestPayload journalParameter = new JournalCreateRequestPayload();
//          journalParameter.setAnaResult("0");
//          journalParameter.setBaseDate(sdf.format(deletePatExamMainList.get(i).getRegExamDate()));
//          if (deletePatExamMainList.get(i).getPhyOrdClass() != null && "1".equals(deletePatExamMainList.get(i).getPhyOrdClass())) {
//            journalParameter.setCoopCd("phy_ord");
//            journalParameter.setOpeCd("021110");
//          } else {
//            journalParameter.setCoopCd("exam_ord");
//            journalParameter.setOpeCd("021010");
//          }
//          journalParameter.setCoopCdIndex("");
//          journalParameter.setCoopResult("0");
//          journalParameter.setCrud("D");
//          journalParameter.setDirection("S");
//          journalParameter.setFacilityCd(facilityCd);
//          journalParameter.setOrdNo(deletePatExamMainList.get(i).getExamMainCd());
//          journalParameter.setPatId(deletePatExamMainList.get(i).getPatId());
//          journalParameter.setUserId(deletePatExamMainList.get(i).getIndUserId());
//          examordJournalList.add(journalParameter);
//        }
//      }
//    }
//    if (!CollectionUtils.isEmpty(examordJournalList)){
//      journalService.callCreateJournalForCtrNo(examordJournalList);
//    }
//  }

//  @Transactional
//  public int insertPatExamMainOfMergedList(List<PatExamMain> insertPatExamMainList) throws Exception {
//    int insertCount = 0;
//    insertCount = patExamMainDao.insertPatExamMainOfMergedList(insertPatExamMainList);
//    return insertCount;
//  }
//
//  @Transactional
//  public int updatePatExamMainOfMergedList(List<PatExamMain> updatePatExamMainList) throws Exception {
//    List<Long> examMainCdList = updatePatExamMainList.stream().map(PatExamMain::getExamMainCd).collect(Collectors.toList());
//    boolean setResult = false;
//    DataUpdateLogCommonNew logCommon = null;
//    try {
//      String tableName = "pat_exam_main";
//      // SQL検索条件
//      StringBuffer wheres = new StringBuffer("");
//      String inStr = getInStr("exam_main_cd in ", examMainCdList);
//      wheres.append(" WHERE\n");
//      wheres.append(inStr + "\n");
//      // logCommon設定
//      logCommon = getLogCommon(patExamMainDao, tableName, wheres, getEventLogMessage());
//      // ログ出力カラム情報及び更新前データ情報取得
//      setResult = logCommon.setInfo();
//    } catch (Exception e) {
//      setResult = false;
//    }
//    int updateCount = 0;
//    if(setResult){
//      updateCount = patExamMainDao.updatePatExamMainOfMergedList(updatePatExamMainList);
//    }
//    // 更新後データ取得、差分あれば、log出力
//    if (setResult && updateCount > 0) {
//      logCommon.setAfterResults();
//      asyncService.updateLog(logCommon);
//    }
//    return updateCount;
//  }
//
//  @Transactional
//  public int deleteByExamMainCdList(List<Long> deletePatExamMainList) throws Exception {
//    boolean setResult = false;
//    DataUpdateLogCommonNew logCommon = null;
//    try {
//      String tableName = "pat_exam_main";
//      // SQL検索条件
//      StringBuffer wheres = new StringBuffer("");
//      String inStr = getInStr("exam_main_cd in ", deletePatExamMainList);
//      wheres.append(" WHERE\n");
//      wheres.append(inStr + "\n");
//      // logCommon設定
//      logCommon = getLogCommon(patExamMainDao, tableName, wheres, getEventLogMessage());
//      // ログ出力カラム情報及び更新前データ情報取得
//      setResult = logCommon.setInfo();
//    } catch (Exception e) {
//      setResult = false;
//    }
//    int updateCount = 0;
//    if(setResult){
//      updateCount = patExamMainDao.deleteByExamMainCdList(deletePatExamMainList);
//    }
//    // 更新後データ取得、差分あれば、log出力
//    if (setResult && updateCount > 0) {
//      logCommon.setAfterResults();
//      asyncService.updateLog(logCommon);
//    }
//    return updateCount;
//  }
//
//  /**
//   * 検索条件 IN情報
//   *
//   * @param fieldInfo カラム情報
//   * @param inList    IN値リスト
//   * @return inStr
//   */
//  public <T> String getInStr(String fieldInfo, List<T> inList) {
//    StringBuffer inStr = new StringBuffer("");
//    inStr.append(fieldInfo);
//    inStr.append(" ( ");
//    for (T obj : inList) {
//      inStr.append(obj);
//      inStr.append(" ,");
//    }
//    inStr.deleteCharAt(inStr.length() - 1);
//    inStr.append(" ) ");
//    return String.valueOf(inStr);
//  }
  //add #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 20240410 ztc end
  // del 10618 検査セットマスタ、検査項目マスタ、一般撮影検査依頼マスタ編集時に関連データを補正する 関  end
}
