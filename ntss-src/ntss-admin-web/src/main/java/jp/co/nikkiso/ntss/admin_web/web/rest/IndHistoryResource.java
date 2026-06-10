package jp.co.nikkiso.ntss.admin_web.web.rest;

import java.net.URISyntaxException;
import java.util.List;
import java.util.ArrayList;
import java.util.Map;

//import org.slf4j.Logger;
//import org.slf4j.LoggerFactory;
import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
// del #11004 連携イベント発生部分不正 piao start
// import jp.co.nikkiso.ntss.admin_web.service.treatmentRecord.TreatmentRecordService;
// del #11004 連携イベント発生部分不正 piao end
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.util.CollectionUtils;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.service.indHistory.IndDetailUpdateCondition;
import jp.co.nikkiso.ntss.admin_web.service.indHistory.IndHistory;
import jp.co.nikkiso.ntss.admin_web.service.indHistory.IndHistoryOptions;
import jp.co.nikkiso.ntss.admin_web.service.indHistory.IndHistoryService;
import jp.co.nikkiso.ntss.admin_web.service.indHistory.IndHistoryServiceDynamo;
import jp.co.nikkiso.ntss.admin_web.service.indHistory.IndListUpdateCondition;
import jp.co.nikkiso.ntss.admin_web.service.indHistory.IndSearchResult;
import jp.co.nikkiso.ntss.admin_web.service.indHistory.IndicationSearch;
import jp.co.nikkiso.ntss.admin_web.service.JournalService;
import jp.co.nikkiso.ntss.admin_web.web.rest.util.PaginationUtils;
import jp.co.nikkiso.ntss.admin_web.request.patientCapture.JournalCreateRequestPayload;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;


@RestController
@RequestMapping(Uri.IND_HISTORY)
public class IndHistoryResource {

//  private final Logger log = LoggerFactory.getLogger(getClass());

  @Autowired
  IndHistoryService indHistoryService;

  @Autowired
  IndHistoryServiceDynamo indHistoryServiceDynamo;

  // wp アプリケーションログの適正化 Add Start
  @Autowired
  LogEventUtils logEventUtils;
  // wp アプリケーションログの適正化 Add End

  // add by zs 2023-03-06 [#6118無期限予定の中止：js foreach call journalをjava batch call journalに変更] --start
  @Autowired
  JournalService journalService;
  // add by zs 2023-03-06 [#6118無期限予定の中止：js foreach call journalをjava batch call journalに変更] --end

  // add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao strat
  // del #11004 連携イベント発生部分不正 piao start
  // @Autowired
  // TreatmentRecordService treatmentRecordService;
  // del #11004 連携イベント発生部分不正 piao end
  // add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao end

  /**
   * 指示履歴取得処理
   *
   * @param params
   * @param options
   * @param pageable
   * @return
   * @throws URISyntaxException
   */
  @GetMapping("")
  public ResponseEntity<Page<IndHistory>> findAllMongo(
      IndHistory params,
      IndHistoryOptions options,
      Pageable pageable
      ) throws URISyntaxException {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.IND_HISTORY;
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    Page<IndHistory> page = indHistoryService.findAll(pageable, params, options);
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, "/api/indHistory/mongo", (int)pageable.getOffset(), pageable.getPageSize());


    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    return new ResponseEntity<>(page, headers, HttpStatus.OK);
  }

  /**
   * 指示履歴作成処理
   *
   * @param params
   * @return
   * @throws URISyntaxException
   */
  @GetMapping("create")
  public ResponseEntity<IndHistory> createMongo(
      IndHistory params
      ) throws URISyntaxException {
    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.IND_HISTORY + "/create";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    IndHistory result = indHistoryService.create(params);

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    return new ResponseEntity<>(result, HttpStatus.OK);
  }

  /**
   * 指示検索
   *
   * @param params
   * @return
   * @throws URISyntaxException
   */
  @PostMapping("searchList")
  public ResponseEntity<List<IndSearchResult>> searchByFilter(@RequestBody
      IndicationSearch params
      ) throws URISyntaxException {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.IND_HISTORY + "/searchList";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    List<IndSearchResult> results = indHistoryService.searchByFilter(params);

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    return new ResponseEntity<>(results, HttpStatus.OK);
  }

  /**
   * 指示詳細検索
   *
   * @param params
   * @return
   * @throws URISyntaxException
   */
  @PostMapping("searchDetail")
  public ResponseEntity<List<IndHistory>> getIndHistoryDetail(@RequestBody
      List<String> params
      ) throws URISyntaxException {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.IND_HISTORY + "/searchList";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    List<IndHistory> results = indHistoryService.getIndHistoryDetail(params);

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    return new ResponseEntity<>(results, HttpStatus.OK);
  }

  /**
   * 指示受け承認一覧画面で選択した指示に更新する
   *
   * @param params ユーザーと患者IDと発行日
   * @return 表示形式パターンのResponse
   */
  @PostMapping("updIndHistoryList")
  public ResponseEntity<?> updateIndHistoryInList(
		  @RequestBody IndListUpdateCondition params ) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.IND_HISTORY + "/updIndHistoryList";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    // 表示形式パターンの更新
    boolean result = indHistoryService.updateIndHistoryInListScreen(params);

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    // add by zs 2023-03-06 [#6118無期限予定の中止：js foreach call journalをjava batch call journalに変更] --start
    List<JournalCreateRequestPayload> ctlNoList = new ArrayList<>();
    if (params.getCheckAll() && params.getIsTreatmentUnit()) {
      /* upd EOL対応内部 #7010 by ztc 2023-07-09 --start */
      List<Map<String, Object>> dellistForJournal = params.getIndication();
      /* upd EOL対応内部 #7010 by ztc 2023-07-09 --end */
      if (!dellistForJournal.isEmpty()) {
        // add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao strat
        // del #11004 連携イベント発生部分不正 piao start
        // int modify_send_class = treatmentRecordService.getCoopIniSchModifySendClass(params.getFacility_cd());
        // del #11004 連携イベント発生部分不正 piao end
        String crudTmp;
        // add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao end
        for (int i = 0; i < dellistForJournal.size(); i++) {
          // mod #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao strat
          crudTmp = "U";
          if (!"".equals(params.getOpe_cd())) {
            // del #11004 連携イベント発生部分不正 piao start
            // if (modify_send_class == 2) {
            //   JournalCreateRequestPayload payload = new JournalCreateRequestPayload();
            //   payload.setOpeCd(params.getOpe_cd());
            //   payload.setCrud("D");
            //   if (dellistForJournal.get(i).get("pat_id") != null) {
            //     payload.setPatId(Long.valueOf((String) dellistForJournal.get(i).get("pat_id")));
            //   }
            //   payload.setFacilityCd(params.getFacility_cd());
            //   if (dellistForJournal.get(i).get("hosp_pat_id") != null) {
            //     payload.setHospPatId((String) dellistForJournal.get(i).get("hosp_pat_id"));
            //   }
            //   payload.setOrdNo(null);
            //   payload.setBaseDate(params.getBase_date());
            //   if (params.getUserId() != null) {
            //     payload.setUserId(Long.valueOf(params.getUserId()));
            //   }
            //   ctlNoList.add(payload);
            //   crudTmp = "C";
            // }
            // del #11004 連携イベント発生部分不正 piao end
            JournalCreateRequestPayload payload = new JournalCreateRequestPayload();
            payload.setOpeCd(params.getOpe_cd());
            payload.setCrud(crudTmp);
            if (dellistForJournal.get(i).get("pat_id") != null) {
              /* upd EOL対応内部 #7010 by ztc 2023-07-09 --start */
              payload.setPatId(Long.valueOf((String) dellistForJournal.get(i).get("pat_id")));
              /* upd EOL対応内部 #7010 by ztc 2023-07-09 --end */
            }
            payload.setFacilityCd(params.getFacility_cd());
            /* upd EOL対応内部 #7010 by ztc 2023-07-09 --start */
            if (dellistForJournal.get(i).get("hosp_pat_id") != null) {
              payload.setHospPatId((String) dellistForJournal.get(i).get("hosp_pat_id"));
            }
            /* upd EOL対応内部 #7010 by ztc 2023-07-09 --end */
            payload.setOrdNo(null);
            payload.setBaseDate(params.getBase_date());
            if (params.getUserId() != null) {
              payload.setUserId(Long.valueOf(params.getUserId()));
            }
            ctlNoList.add(payload);
          }
          // mod #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao end
        }
      }
      if (!CollectionUtils.isEmpty(ctlNoList)){
        journalService.callCreateJournalForCtrNo(ctlNoList);
      }
    }
    // add by zs 2023-03-06 [#6118無期限予定の中止：js foreach call journalをjava batch call journalに変更] --end
    // レスポンス生成
    return new ResponseEntity<>(null, result ? HttpStatus.OK : HttpStatus.INTERNAL_SERVER_ERROR);
  }

  /**
   * 指示受け承認詳細画面で選択した指示に更新する
   *
   * @param params ユーザーと患者IDと発行日
   * @return 表示形式パターンのResponse
   */
  @PostMapping("updIndHistoryDetail")
  public ResponseEntity<?> updateIndHistoryInDetailScreen(
		  @RequestBody List<IndDetailUpdateCondition> params ) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.IND_HISTORY + "/updIndHistoryDetail";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    // 表示形式パターンの更新
    boolean result = indHistoryService.updateIndHistoryInDetailScreen(params);
    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    // レスポンス生成
    return new ResponseEntity<>(null, result ? HttpStatus.OK : HttpStatus.INTERNAL_SERVER_ERROR);
  }
  /**
   * 指示履歴取得処理
   *
   * @param params
   * @param options
   * @param pageable
   * @return
   * @throws URISyntaxException
   */
  @GetMapping("dynamo")
  public ResponseEntity<Page<IndHistory>> findAllDynamo(
      IndHistory params,
      IndHistoryOptions options,
      Pageable pageable
      ) throws URISyntaxException {
    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.IND_HISTORY + "/dynamo";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    Page<IndHistory> page = indHistoryServiceDynamo.findAll(pageable, params, options);
    HttpHeaders headers = PaginationUtils.generatePaginationHttpHeaders(page, "/api/indHistory/", (int)pageable.getOffset(), pageable.getPageSize());

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    return new ResponseEntity<>(page, headers, HttpStatus.OK);
  }

  /**
   * 指示履歴作成処理
   *
   * @param params
   * @return
   * @throws URISyntaxException
   */
  // @PostMapping("dynamoCreate")
  @GetMapping("dynamoCreate")
  public ResponseEntity<IndHistory> createDynamo(
      IndHistory params
      ) throws URISyntaxException {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.IND_HISTORY + "/dynamoCreate";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    IndHistory result = indHistoryServiceDynamo.create(params);

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    return new ResponseEntity<>(result, HttpStatus.OK);
  }

  /**
   * クラス名取得
   */
  private String getClassName() {
    return this.getClass().getName();
  }

  /**
   * メソッド名取得
   */
  private String getMethodName() {
    return Thread.currentThread().getStackTrace()[2].getMethodName();
  }
}
