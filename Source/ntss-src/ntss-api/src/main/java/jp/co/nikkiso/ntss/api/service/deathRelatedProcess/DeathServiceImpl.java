package jp.co.nikkiso.ntss.api.service.deathRelatedProcess;

import jp.co.nikkiso.ntss.api.model.JournalCreateRequestPayload;
import jp.co.nikkiso.ntss.api.model.indHistory.ValiDeleteIndPlanPatInfo;
import jp.co.nikkiso.ntss.core.dao.MstKurDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.OrdScheduleDao;
import jp.co.nikkiso.ntss.core.dao.PatExamMainDao;
import jp.co.nikkiso.ntss.core.dao.PatExamPatternDao;
import jp.co.nikkiso.ntss.core.dao.PatIndApproveDao;
import jp.co.nikkiso.ntss.core.dao.PatMainDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.dao.PatRadMainDao;
import jp.co.nikkiso.ntss.core.dao.PatRadPatternDao;
import jp.co.nikkiso.ntss.core.dao.PatTreatmentPatternDao;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.OrdSchedule;
import jp.co.nikkiso.ntss.core.entity.PatExamMain;
import jp.co.nikkiso.ntss.core.entity.PatExamPattern;
import jp.co.nikkiso.ntss.core.entity.PatIndApprove;
import jp.co.nikkiso.ntss.core.entity.PatMain;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.PatRadMain;
import jp.co.nikkiso.ntss.core.entity.PatRadPattern;
import jp.co.nikkiso.ntss.core.entity.PatTreatmentPattern;
import jp.co.nikkiso.ntss.core.logevent.EventLogOutputToMongoDBCommon;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.api.service.indHistory.CreateIndHistoryService;
import jp.co.nikkiso.ntss.api.service.journal.JournalCreatePayloadService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.sql.Timestamp;
import java.text.ParseException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;

/**
 * 患者死亡共通処理
 */
@Service
public class DeathServiceImpl implements DeathService {

  @Autowired
  private PatPersonalMainDao patPersonalMainDao;

  @Autowired
  private PatMainDao patMainDao;

  @Autowired
  private OrdScheduleDao ordScheduleDao;

  @Autowired
  private PatTreatmentPatternDao patTreatmentPatternDao;

  @Autowired
  private PatIndApproveDao patIndApproveDao;

  @Autowired
  private OrdMainDao ordMainDao;

  @Autowired
  private PatRadMainDao patRadMainDao;

  @Autowired
  private PatRadPatternDao patRadPatternDao;

  @Autowired
  private PatExamMainDao patExamMainDao;

  @Autowired
  private PatExamPatternDao patExamPatternDao;

  @Autowired
  private EventLogOutputToMongoDBCommon eventLogOutputToMongoDBCommon;

  @Autowired
  private JournalCreatePayloadService journalCreatePayloadService;

  @Autowired
  private CreateIndHistoryService createIndHistoryService;

  @Autowired
  private MstKurDao mstKurDao;

  /**
   * 死亡処理
   */
  @Transactional
  @Override
  // mod 12005 患者削除時の予定中止は行われるが検査依頼・一般撮影検査依頼の削除が行われない zkm start
//  public List<JournalCreateRequestPayload> deathRelatedProcess(String facilityCd, List<Long> patIdList, Long updId) throws ParseException {
  public List<JournalCreateRequestPayload> deathRelatedProcess(String facilityCd, List<Long> patIdList, Long updId, String actionMode) throws ParseException {
    // mod 12005 患者削除時の予定中止は行われるが検査依頼・一般撮影検査依頼の削除が行われない zkm end

    List<JournalCreateRequestPayload> journalCreateRequestPayloadList = new ArrayList<>();
    Map<String, List<Object>> resultAllChangedAfterDataInfoList = new HashMap<>(); //eventログ 連携用、イベントログ用
    Map<String, List<Object>> resultAllChangeBeforeDataInfoList = new HashMap<>(); //eventログ 連携用、イベントログ用

//    LocalDateTime now = LocalDateTime.now();
//    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
//    String formattedDateTime = now.format(formatter);

    // pat_idを指定して患者取得
    List<PatPersonalMain> listPatPersonalMain = patPersonalMainDao.selectByIdListFacilityCd(patIdList, facilityCd);
    if(listPatPersonalMain != null && listPatPersonalMain.size() > 0) {
      for(PatPersonalMain patPersonalMain : listPatPersonalMain) {
        // mod 12005 患者削除時の予定中止は行われるが検査依頼・一般撮影検査依頼の削除が行われない zkm start
//        Timestamp dieDate = patPersonalMain.getDie_date();
//        Timestamp currentTime = new Timestamp(System.currentTimeMillis());
//        if (dieDate == null || !dieDate.after(currentTime)) {
//          patPersonalMain.setDie_date(currentTime);
//        }
        if ("1".equals(patPersonalMain.getIs_del())) {
          // 1970-01-01 08:00:00.0
          patPersonalMain.setDie_date(new Timestamp(0));
        } else {
          Timestamp dieDate = patPersonalMain.getDie_date();
          Timestamp currentTime = new Timestamp(System.currentTimeMillis());
          if (dieDate == null || !dieDate.after(currentTime)) {
            patPersonalMain.setDie_date(currentTime);
        }
        // mod 12005 患者削除時の予定中止は行われるが検査依頼・一般撮影検査依頼の削除が行われない zkm end
        }
      }

      // 死亡フラグが立っている場合
//      for(Long patId : patIdList) {
//        PatMain pat = new PatMain();
//        pat.setUp_date(formattedDateTime);
//        patMainDao.updateInOutState(patId, "11", null, null, pat);
//
//        PatPersonalMain patPersonalMain = new  PatPersonalMain();
//        patPersonalMain.setUp_date(formattedDateTime);
//        patPersonalMainDao.updateInOutClassById(patId, 2, patPersonalMain);
//      }

      // ord_main_restore へのレコード退避  and ord_mainの削除
      List<OrdMain> beforeOrdMainList = ordMainDao.deathDelOrdMainAndBack(facilityCd, listPatPersonalMain);
      if(beforeOrdMainList != null && beforeOrdMainList.size() > 0) {
        this.addToMapList(resultAllChangeBeforeDataInfoList, "ord_main", beforeOrdMainList); // 変更前データ退避
        // 治療予定の削除
        List<Long> ordNoList = beforeOrdMainList.stream().map(item -> item.getOrdNo()).distinct().collect(Collectors.toList());
        //ord_scheduleの削除
        List<OrdSchedule> beforOrdScheduleList = ordScheduleDao.deathDelByOrdNoList(facilityCd,ordNoList);
        if(beforOrdScheduleList != null && beforOrdScheduleList.size() > 0) {
          this.addToMapList(resultAllChangeBeforeDataInfoList, "ord_schedule", beforOrdScheduleList); // 変更前データ退避
        }
        //指示受け承認情報の削除
        List<PatIndApprove> beforePatIndApproveList = patIndApproveDao.selectPatIndApproveByOrdNoList(facilityCd, ordNoList);
        if(beforePatIndApproveList != null && beforePatIndApproveList.size() > 0) {
          this.addToMapList(resultAllChangeBeforeDataInfoList, "pat_ind_approve", beforePatIndApproveList); // 変更前データ退避
        }
        patIndApproveDao.deleteByOrdNoList(ordNoList);
        List<PatIndApprove> afterPatIndApproveList = patIndApproveDao.selectPatIndApproveByOrdNoList(facilityCd, ordNoList);
        if(afterPatIndApproveList != null && afterPatIndApproveList.size() > 0) {
          this.addToMapList(resultAllChangedAfterDataInfoList, "pat_ind_approve", afterPatIndApproveList); // 変更後データ退避
        }
      }
      //放射線検査データ 削除を実施
      List<PatRadMain> allRadList = patRadMainDao.deletePatRadMainToHistoryByDeathPatList(facilityCd, listPatPersonalMain);
      if (allRadList != null && allRadList.size() > 0) {
        this.addToMapList(resultAllChangeBeforeDataInfoList, "pat_rad_main", allRadList); // 変更前データ退避
      }

      //検査結果データを取得
      List<PatExamMain> allExamList = patExamMainDao.deathSelectPatExamMain(facilityCd, listPatPersonalMain);
      if (allExamList != null && allExamList.size() > 0) {
        this.addToMapList(resultAllChangeBeforeDataInfoList, "pat_exam_main", allExamList); // 変更前データ退避
        /**
         * 検査結果なし⇒物理削除
         * 結果あり→依頼フィールドnull更新
         */
        //結果あり
        List<PatExamMain> hasResultExamList = new ArrayList<>();
        //検査結果なし
        List<PatExamMain> noneResultExamList = new ArrayList<>();
        for(PatExamMain patExamMain : allExamList) {
          if(StringUtils.hasText(patExamMain.getExamResultInfo()) && !"[]".equals(patExamMain.getExamResultInfo())) {
            hasResultExamList.add(patExamMain);
          } else {
            noneResultExamList.add(patExamMain);
          }
        }
        // 削除を実施
        if(hasResultExamList != null && !hasResultExamList.isEmpty()) {
          List<PatExamMain> afterPatExamMainList = patExamMainDao.updatePatExamMainResultByDeathPatList(facilityCd, hasResultExamList);
          if(afterPatExamMainList != null && !afterPatExamMainList.isEmpty()) {
            this.addToMapList(resultAllChangedAfterDataInfoList, "pat_exam_main", afterPatExamMainList); // 変更後データ退避
          }
        }
        if(noneResultExamList != null && !noneResultExamList.isEmpty()) {
          patExamMainDao.deletePatExamMainToHistoryByDeathPatList(facilityCd, noneResultExamList);
        }
      }
      //各パターンデータの削除
      //pat_treatment_patternデータ削除
      List<PatTreatmentPattern> beforePatterList = patTreatmentPatternDao.deletePatTreatmentPatternByPatIdList(facilityCd, patIdList);
      if(beforePatterList != null && !beforePatterList.isEmpty()) {
        this.addToMapList(resultAllChangeBeforeDataInfoList, "pat_treatment_pattern", beforePatterList); // 変更前データ退避
      }

      //pat_rad_patternデータ削除
      List<PatRadPattern> beforeRadPatterList = patRadPatternDao.deleteRadPatternByPatIdList(facilityCd, patIdList);
      if(beforeRadPatterList != null && !beforeRadPatterList.isEmpty()) {
        this.addToMapList(resultAllChangeBeforeDataInfoList, "pat_rad_pattern", beforeRadPatterList); // 変更前データ退避
      }

      //pat_exam_patternデータ削除
      List<PatExamPattern> beforeExamPatterList = patExamPatternDao.deleteExamPatternByPatIdList(facilityCd, patIdList);
      if(beforeExamPatterList != null && !beforeExamPatterList.isEmpty()) {
        this.addToMapList(resultAllChangeBeforeDataInfoList, "pat_exam_pattern", beforeExamPatterList); // 変更前データ退避
      }

      //pat_mianの最終延長可能日をnullに更新
      List<PatMain> beforePatMainList = patMainDao.selectByIdListFacilityCd(patIdList, facilityCd);
      if(beforePatMainList != null && !beforePatMainList.isEmpty()) {
        this.addToMapList(resultAllChangeBeforeDataInfoList, "pat_main", beforePatterList); // 変更前データ退避
      }
      for(Long patId : patIdList) {
        patMainDao.updateSchExtEndDate(patId, null);
      }
      List<PatMain> afterPatMainList = patMainDao.selectByIdListFacilityCd(patIdList, facilityCd);
      if(afterPatMainList != null && !afterPatMainList.isEmpty()) {
        this.addToMapList(resultAllChangedAfterDataInfoList, "pat_main", afterPatMainList); // 変更前データ退避
      }
      //クールマスタ常勤医 or  施設設定マスタのデフォルト医師
      if(updId == null || updId == 0L) {
        String staffCd = mstKurDao.selectStaffByCurrentTimeAndFacilityCd(facilityCd);
        if(StringUtils.hasText(staffCd)) {
          updId = Long.valueOf(staffCd);
        }
      }
      //指示履歴の書き込み
      for(PatPersonalMain patPersonalMain : listPatPersonalMain) {
        if(beforeOrdMainList != null && beforeOrdMainList.size() > 0) {
          List<OrdMain> indHistoryOrdMainList = beforeOrdMainList.stream().filter(ord ->
            Objects.equals(patPersonalMain.getPat_id(),ord.getPatId())).collect(Collectors.toList());
          if(indHistoryOrdMainList != null && indHistoryOrdMainList.size() > 0) {
            Timestamp dieDate = patPersonalMain.getDie_date();
            LocalDate localDate = dieDate.toLocalDateTime().toLocalDate();
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyyMMdd");
            String formattedDate = localDate.format(formatter);
            ValiDeleteIndPlanPatInfo bodyData = new ValiDeleteIndPlanPatInfo();
            bodyData.setFacility_cd(patPersonalMain.getFacility_cd());
            bodyData.setPat_id(patPersonalMain.getPat_id().toString());
            bodyData.setInd_user_id(updId != null ? updId.toString() : "0");
            bodyData.setUpd_user_id(updId != null ? updId.toString() : "0");
            createIndHistoryService.createDeleteHistoryByDeleteIndPlanPatInfo(bodyData, indHistoryOrdMainList, formattedDate,"");
          }
        }
      }

      //eventログ書き込み（削除データ）
      try {
        eventLogOutputToMongoDBCommon.makeEvebtLogToMongoByDataDiff(resultAllChangeBeforeDataInfoList, resultAllChangedAfterDataInfoList);
      } catch (Exception e) {
        //エラー
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("eventLog共通処理 " + e.getMessage());
      }

      //連携共通処理処理の読み出し
      Map<String, List<Object>> beforeDataInfoList = new HashMap<>();
      for (Map.Entry<String, List<Object>> entry : resultAllChangeBeforeDataInfoList.entrySet()) {
        String key = entry.getKey();
        if("ord_main".equals(key) || "pat_exam_main".equals(key) || "pat_rad_main".equals(key)) {
          List<Object> value = entry.getValue();
          beforeDataInfoList.put(key, new ArrayList<>(value));
        }
      }
      // mod 12005 患者削除時の予定中止は行われるが検査依頼・一般撮影検査依頼の削除が行われない zkm start
//      journalCreateRequestPayloadList = journalCreatePayloadService.createJournalPayload(facilityCd,
//        null, beforeDataInfoList, patIdList, updId, "PAT_DEATH");
      journalCreateRequestPayloadList = journalCreatePayloadService.createJournalPayload(facilityCd,
        null, beforeDataInfoList, patIdList, updId, actionMode);
      // mod 12005 患者削除時の予定中止は行われるが検査依頼・一般撮影検査依頼の削除が行われない zkm end
    }

    return journalCreateRequestPayloadList;
  }

  private void addToMapList(Map<String, List<Object>> map, String key, Object value) {
    // Map内存在しない場合は新規で入れる
    if (!map.containsKey(key)) {
      List<Object> list = new ArrayList<>();
      list.addAll((List<?>) value);
      map.put(key, list);
    } else {
      // Map内既に存在するのであれば、既存リストへデータマージ
      List<Object> list = map.get(key);
      list.addAll((List<?>) value);
      list.stream().distinct().collect(Collectors.toList());
    }
  }
}
