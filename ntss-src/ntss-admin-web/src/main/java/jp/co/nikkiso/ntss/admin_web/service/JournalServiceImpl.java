package jp.co.nikkiso.ntss.admin_web.service;

import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
// #9698 アプリケーションログの内容修正 20260327 add yangxuewang start
import java.util.HashMap;
// #9698 アプリケーションログの内容修正 20260327 add yangxuewang end
import java.util.List;
import java.net.URI;
import java.util.Map;
import java.util.stream.Collectors;
// #9698 アプリケーションログの内容修正 20260327 add yangxuewang start
import com.fasterxml.jackson.databind.ObjectMapper;
// #9698 アプリケーションログの内容修正 20260327 add yangxuewang end
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.journal.JournalCreatePayloadService;
import jp.co.nikkiso.ntss.admin_web.service.ordMainDelayTask.OrdMainJournalRequest;
// del #11004 連携イベント発生部分不正 piao start
// import jp.co.nikkiso.ntss.admin_web.service.treatmentRecord.TreatmentRecordService;
// del #11004 連携イベント発生部分不正 piao end
// #9698 アプリケーションログの内容修正 20260327 add yangxuewang start
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
// #9698 アプリケーションログの内容修正 20260327 add yangxuewang end
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dto.OrdMain.JournalEventLinkByPat;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainTreatDate;
import jp.co.nikkiso.ntss.core.utils.BeanBuilderUtils;
// #9698 アプリケーションログの内容修正 20260327 add yangxuewang start
import jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils;
// #9698 アプリケーションログの内容修正 20260327 add yangxuewang end
import org.apache.commons.collections.CollectionUtils;
// #9698 アプリケーションログの内容修正 20260327 add yangxuewang start
import org.springframework.aop.framework.AopProxyUtils;
// #9698 アプリケーションログの内容修正 20260327 add yangxuewang end
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.http.RequestEntity;
import org.springframework.http.ResponseEntity;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.client.RestTemplate;

import jp.co.nikkiso.ntss.core.entity.OrdCoopNo;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.OrdCoopNoDao;
import jp.co.nikkiso.ntss.admin_web.request.patientCapture.JournalCreateRequestPayload;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
// mod FNSI-連携イベントの登録適正化 楊 start
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;

// #9698 アプリケーションログの内容修正 20260327 add yangxuewang start
import static jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils.toJson;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;
// #9698 アプリケーションログの内容修正 20260327 add yangxuewang end
// mod FNSI-連携イベントの登録適正化 楊 end

/**
 * ジャーナル作成のService実装クラス
 */
@Service
public class JournalServiceImpl implements JournalService{

	@Autowired
	OrdCoopNoDao ordCoopNoDao;
  // mod FNSI-連携イベントの登録適正化 楊 start
  @Autowired
  private PatPersonalMainDao patPersonalMainDao ;
  // mod FNSI-連携イベントの登録適正化 楊 start
	/**
	 * {@inheritDoc}
	 */
	@Override
	public List<OrdCoopNo> getByCondition(String facilityCd, Long ordNo, String coopCd) {
		List<OrdCoopNo> list = ordCoopNoDao.selectByCondition(facilityCd, ordNo, coopCd);
		return list;
	}

	@Value("${ntss.admin-web.coop-api.url}")
	private String coopApi;
  /* add by chamaojia 2024-06-21 [10574] communication security related additions --start */
  @Value("${ntss.admin-web.coop-api.header-name}")
  private String headerKey;
  @Value("${ntss.admin-web.coop-api.header-value}")
  private String headerValue;
  /* add by chamaojia 2024-06-21 [10574] communication security related additions --end */
	@Autowired
	private PatInfoService patInfoService;
	@Autowired
	private AsyncService asyncService;
	@Autowired
	LogService logService;

  //add #10185 DW一括登録時に連携イベントが発生しない zhaoqi 20240105 start
  @Autowired
  OrdMainDao ordMainDao;
  //add #10185 DW一括登録時に連携イベントが発生しない zhaoqi 20240105 end

  // add #10553 変更区分送信設定0:削除データを送信しない(変更で送信する)1：削除データを送信する(削除新規で送信する) start
  // del #11004 連携イベント発生部分不正 piao start
  // @Autowired
  // private TreatmentRecordService treatmentRecordService;
  // del #11004 連携イベント発生部分不正 piao end
  // add #10553 変更区分送信設定0:削除データを送信しない(変更で送信する)1：削除データを送信する(削除新規で送信する) end

  // add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao strat
  @Autowired
  private JournalCreatePayloadService journalCreatePayloadService;
  // add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao end

	/**
	 * {@inheritDoc}
	 */
	@Override
  // mod FNSI-連携イベントの登録適正化 楊 start
//	public void callCreateJournal(List<String> dateList, String beforeDate, String afterDate, String facilityCd,
//			Long ordNo, Long userId, Long patId, String coopCd) throws Exception {
  public void callCreateJournal(List<String> dateList, String beforeDate, String afterDate, String facilityCd,
			Long ordNo, Long userId, Long patId, String opeCd, String crud) throws Exception {
    String cDate = "";
    // mod FNSI-連携イベントの登録適正化 楊 end
    if (dateList.contains(beforeDate) && (!beforeDate.equals(afterDate))) {
      // mod FNSI-連携イベントの登録適正化 楊 start
//      JournalCreateRequestPayload payload = new JournalCreateRequestPayload();
//      payload = mappingJournalCreateRequestPayload(userId, facilityCd, patId, coopCd,
//        CoopCdConstant.CRUD_UPDATE);
      // 移動の場合：移動後の日付
      cDate = afterDate;
      // 削除の場合：削除されるデータが持っている日付
      if ("D".equals(crud)) {
        cDate = beforeDate;
      }
    }
    // add FNSI-外部連携の修正 徐 start
    else if (!dateList.contains(beforeDate)) {
      cDate = afterDate;
    }
    // add FNSI-外部連携の修正 徐 end
    // Hosp_pat_idを設定する
    PatPersonalMain patPersonalMain = patPersonalMainDao.selectById(patId);

    JournalCreateRequestPayload payload = new JournalCreateRequestPayload();
    // mod FNSI-連携イベントの登録適正化 楊 end
    try {
      // mod FNSI-連携イベントの登録適正化 楊 start
//        boolean callFlg = true;
//        if (!payload.getCrud().equals("C")) {
//          List<OrdCoopNo> list = new ArrayList<OrdCoopNo>();
//          list = journalService.getByCondition(payload.getFacilityCd(), payload.getOrdNo(),
//            payload.getCoopCd());
//          if (list.size() == 0) {
//            callFlg = false;
//          }
//        }
//        if (callFlg) {
//          RestTemplate rt = new RestTemplate();
//          URI uri = new URI(coopApi + "/journal/create");
//          RequestEntity<JournalCreateRequestPayload> request = RequestEntity.post(uri)
//            .contentType(MediaType.APPLICATION_JSON).body(payload);
//          rt.exchange(request, Object.class);
//        }
      payload = mappingJournalCreateRequestPayload(userId, facilityCd, patPersonalMain.getHosp_pat_id(), patId, opeCd,
        crud, cDate, ordNo);

      // mod by zs 2023-03-06 [#6118無期限予定の中止：js foreach call journalをjava batch call journalに変更] --start
//      RestTemplate rt = new RestTemplate();
//      URI uri = new URI(coopApi + "/journal/create");
//      RequestEntity<JournalCreateRequestPayload> request = RequestEntity.post(uri)
//        .contentType(MediaType.APPLICATION_JSON).body(payload);
//      rt.exchange(request, Object.class);
      asyncService.sendExternalConnection(payload);
      // mod by zs 2023-03-06 [#6118無期限予定の中止：js foreach call journalをjava batch call journalに変更] --end
      // mod FNSI-連携イベントの登録適正化 楊 end
    } catch (Exception ex) {
      //patInfoService.createNotificationMessage(userId, payload);
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(ex));
      if (facilityCd != null) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
    }
	}

  /**
   * {@inheritDoc}
   */
  @Override
  public void callCreateJournalForPayload(JournalCreateRequestPayload payload) {
    try {
      // mod by zs 2023-03-06 [#6118無期限予定の中止：js foreach call journalをjava batch call journalに変更] --start
//      RestTemplate rt = new RestTemplate();
//      URI uri = new URI(coopApi + "/journal/create");
//      RequestEntity<JournalCreateRequestPayload> request = RequestEntity.post(uri)
//        .contentType(MediaType.APPLICATION_JSON).body(payload);
//      rt.exchange(request, Object.class);
      asyncService.sendExternalConnection(payload);
      // mod by zs 2023-03-06 [#6118無期限予定の中止：js foreach call journalをjava batch call journalに変更] --end
    } catch (Exception ex) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(ex));
      if (payload != null && payload.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(payload.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
    }
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public void callCreateJournalForCtrNo(List<JournalCreateRequestPayload> ctlNoList) {
      /* del by shiyw 2023-02-14 start
        if (ctlNoList.size() > 0) {
          try {
            RestTemplate rt = new RestTemplate();
            URI uri = new URI(coopApi + "/journal/createList");
            RequestEntity<List<JournalCreateRequestPayload>> request = RequestEntity.post(uri)
              .contentType(MediaType.APPLICATION_JSON).body(ctlNoList);
            rt.exchange(request, Object.class);
          } catch (Exception ex) {
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage(ex.getLocalizedMessage());
            logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
          }
        } del by shiyw 2023-02-14 end */
     // add by shiyw 2023-02-14 start
      if (ctlNoList.size() > 0) {
          asyncService.requestApiJournalCreateList(ctlNoList);
      }
      // add by shiyw 2023-02-14 end
  }

    /**
	 * 戻り値：編集済のジャーナル登録依頼ペイロード
	 *
	 * @param userId ユーザーID
	 * @param facilityCd 施設コード
	 * @param hospPatId 患者ID
   * @param patId 患者ID
	 * @param opeCd 連携種別
	 * @param crud 作成更新区分
   * @param baseDate 検査日
   * @param ordNo 指示番号
	 * @return
	 */
  // mod FNSI-連携イベントの登録適正化 楊 start
//	private JournalCreateRequestPayload mappingJournalCreateRequestPayload(Long userId, String facilityCd, Long patId,
//			String coopCd, String crud) {
    private JournalCreateRequestPayload mappingJournalCreateRequestPayload(Long userId, String facilityCd, String hospPatId, Long patId,
      String opeCd, String crud, String baseDate, Long ordNo) {
      // mod FNSI-連携イベントの登録適正化 楊 end
		JournalCreateRequestPayload payload = new JournalCreateRequestPayload();
		payload.setFacilityCd(facilityCd);
    // mod FNSI-連携イベントの登録適正化 楊 start
//      payload.setCoopCd(coopCd);
//		payload.setCoopCdIndex("");
//		payload.setCrud(crud);
//		payload.setDirection("S");
//		payload.setAnaResult("0");
//		payload.setCoopResult("0");
		payload.setPatId(patId);
//		payload.setHospPatId("");
//      payload.setOrdNo(0L);
    payload.setCrud(crud);
    payload.setHospPatId(hospPatId);
    payload.setOrdNo(ordNo);
    // mod FNSI-連携イベントの登録適正化 楊 end

		payload.setUserId(userId);
      // mod FNSI-連携イベントの登録適正化 楊 start
    payload.setBaseDate(baseDate);
    payload.setOpeCd(opeCd);
      // mod FNSI-連携イベントの登録適正化 楊 end
		return payload;
	}
  //mod 7068 患者経過総合ビューアで曜日パターン変更すると変更前の削除イベント・変更後の新規イベントが正しく作成されない 卓 start
	@Override
  public void callCreateJournal(List<OrdMain> ordMainList, JournalCreateRequestPayload requestPayload, List<OrdMainJournalRequest> requestList) {
    ordMainList.forEach(ordMain -> {
      JournalCreateRequestPayload payload = new JournalCreateRequestPayload();
      BeanUtils.copyProperties(requestPayload, payload);
      payload.setOrdNo(ordMain.getOrdNo());
      payload.setBaseDate(ordMain.getTreatDate());
      OrdMainJournalRequest journalRequest = new OrdMainJournalRequest();
      journalRequest.setOrdNo(payload.getOrdNo());
      journalRequest.setPatId(payload.getPatId());
      journalRequest.setCrud(payload.getCrud());
      journalRequest.setPayload(payload);

      //  ディレイタスク作成
      requestList.add(journalRequest);
    });
  }
  //mod 7068 患者経過総合ビューアで曜日パターン変更すると変更前の削除イベント・変更後の新規イベントが正しく作成されない 卓 end

  //add #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 start

  /**
   * Batch call Journal API
   * @param journalList
   * @param facilityCd
   * @param userId
   */
  @Override
  @Async
  public void sendJournal(List<OrdMain> journalList, String facilityCd, Long userId) {
    List<JournalCreateRequestPayload> ctlNoList = new ArrayList<>();
    if (journalList != null && !journalList.isEmpty()) {
      // add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao start
      // 治療予定が削除　または　クールが指定→未登録へ　変更した場合、発行すべきDイベント &&
      // 治療予定が登録　または　クールが未登録→指定へ　変更した場合、発行すべきCイベントのリスト
      List<JournalEventLinkByPat> journalEventLinkByPatList = new ArrayList<>();
      Map<String, JournalEventLinkByPat> journalEventLinkByPatListMap = journalEventLinkByPatList.stream().collect(Collectors.toMap(value -> value.getUniqueKey(), value -> value));
      List<Long> patIdList = journalList.stream().map(o -> o.getPatId()).collect(Collectors.toList());
      List<PatPersonalMain> patPersonalMainList = patPersonalMainDao.selectPatPersonalMainForHospPatIdListByPatIdList(facilityCd, patIdList);
      Map<Long, String> patPersonalMainListMap = patPersonalMainList.stream().collect(Collectors.toMap(PatPersonalMain::getPat_id, PatPersonalMain::getHosp_pat_id));
      // add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao end

      for (OrdMain om : journalList) {
        // add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao start
        Long patId = om.getPatId();
        String hospPatId = patPersonalMainListMap.get(patId);
        // add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao end

        JournalCreateRequestPayload jp = new JournalCreateRequestPayload();
        jp.setOpeCd("005001");
        jp.setCrud("D");
        jp.setFacilityCd(facilityCd);
        jp.setPatId(om.getPatId());
        // add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao start
        jp.setHospPatId(hospPatId);
        // add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao end
        jp.setOrdNo(om.getOrdNo());
        jp.setBaseDate(om.getTreatDate());
        jp.setUserId(userId);
        ctlNoList.add(jp);

        // add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao start
        // 治療予定が削除　または　クールが指定→未登録へ　変更した場合、発行すべきDイベント治療日のリストadd
        journalCreatePayloadService.addToBeDEventTreatDate(journalEventLinkByPatListMap, facilityCd, patId, hospPatId, om.getTreatDate(), om.getIndKurCd());
        // add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao end
      }

      // mod #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao start
      String actionMode = "MST_KUR";
      ctlNoList.addAll(journalCreatePayloadService.createJournalPayloadForToBeEventTreatDate(journalEventLinkByPatListMap, userId, actionMode));
      ctlNoList = ctlNoList.stream().filter(o -> o.getOpeCd() != null).collect(Collectors.toList());
      if (! org.apache.commons.collections.CollectionUtils.isEmpty(ctlNoList)) {
        this.callCreateJournalForCtrNo(ctlNoList);
      }
      // if (!ctlNoList.isEmpty()) {
      //   try {
      //     RestTemplate rt = new RestTemplate();
      //     URI uri = new URI(coopApi + "/journal/createList");
      //     RequestEntity<List<JournalCreateRequestPayload>> request = RequestEntity.post(uri)
      //             .contentType(MediaType.APPLICATION_JSON)
      //             /* add by chamaojia 2024-06-21 [10574] communication security related additions --start */
      //             .header(headerKey, headerValue)
      //             /* add by chamaojia 2024-06-21 [10574] communication security related additions --end */
      //             .body(ctlNoList);
      //     rt.exchange(request, Object.class);
      //   } catch (Exception ex) {
      //     ex.printStackTrace();
      //     EventLogMessage eventLogMessage = new EventLogMessage();
      //     eventLogMessage.setLogMessage(ex.getLocalizedMessage());
      //     logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
      //   }
      // }
      // mod #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao end
    }
  }
  //add #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 end

  //add #10185 DW一括登録時に連携イベントが発生しない zhaoqi 20240105 start
  /**
   *
   * @param payload
   */
  @Override
  @Async
  public void sendJournalForDw(List<Map<String, String>> payload, NtssUser user) {
    List<Long> patIdList = new ArrayList<>();
    for(Map<String, String> map : payload){
      Long patId = Long.parseLong(map.get("pat_id"));
      patIdList.add(patId);
    }
    List<JournalCreateRequestPayload> ctlNoList = new ArrayList<>();
    List<OrdMain> ordMainList = ordMainDao.getAllOrdNoWithStateIsNotZero(patIdList);
    if (!ordMainList.isEmpty()) {
      for (OrdMain om : ordMainList) {
        JournalCreateRequestPayload jp = new JournalCreateRequestPayload();
        jp.setOpeCd("008001");
        jp.setCrud("U");
        jp.setFacilityCd(om.getFacilityCd());
        jp.setPatId(om.getPatId());
        jp.setOrdNo(om.getOrdNo());
        jp.setBaseDate(om.getTreatDate());
        jp.setUserId(user.getUserId());
        ctlNoList.add(jp);
      }

      try {
        RestTemplate rt = new RestTemplate();
        URI uri = new URI(coopApi + "/journal/createList");
        RequestEntity<List<JournalCreateRequestPayload>> request = RequestEntity.post(uri)
                .contentType(MediaType.APPLICATION_JSON)
                /* add by chamaojia 2024-06-21 [10574] communication security related additions --start */
                .header(headerKey, headerValue)
                /* add by chamaojia 2024-06-21 [10574] communication security related additions --end */
                .body(ctlNoList);
// #9698 アプリケーションログの内容修正 20260327 mod yangxuewang start
        long start = System.currentTimeMillis();
        ResponseEntity<Object> response = rt.exchange(request, Object.class);
        long cost = System.currentTimeMillis() - start;
        Map<String, Object> map = new HashMap<>();
        map.put("logType", "RESTTEMPLATE-LOG");
        map.put("className", "jp.co.nikkiso.ntss.admin_web.service.JournalServiceImpl");
        map.put("methodName", "sendJournalForDw");
        map.put("method", request.getMethod());
        map.put("url", uri.getPath());
        map.put("headers", request.getHeaders());
        map.put("requestParameter", request.getBody());
        map.put("status",response.getStatusCode());
        map.put("cost", cost);
        map.put("result",response.getBody());
        EventLogMessage restTemplateEventLogMessage = new EventLogMessage();
        restTemplateEventLogMessage.setLogMessage(toJson(map));
        if (user != null && org.apache.commons.lang3.StringUtils.isNotEmpty(user.getFacilityCd())) {
          restTemplateEventLogMessage.setFacilityCd(user.getFacilityCd());
        }
        logService.log(LogLevel.INFO, restTemplateEventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
// #9698 アプリケーションログの内容修正 20260327 mod yangxuewang end
      } catch (Exception ex) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      ex.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end

        EventLogMessage eventLogMessage = new EventLogMessage();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 mod yangxuewang start
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(ex));
        if (user != null && user.getFacilityCd() != null) {
          eventLogMessage.setFacilityCd(user.getFacilityCd());
        }
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 mod yangxuewang end
        logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
      }
    }
  }
  //add #10185 DW一括登録時に連携イベントが発生しない zhaoqi 20240105 end

  // add #10710 【身体情報関連】⑦データリスト 荘 2024-07-12 start
  @Override
  @Async
  public void sendJournalForDwAndTw(long patId,
                                 List<OrdMainTreatDate> effectsIntervalOrdNoList,
                                 Long userId,
                                 String facilityCd,
                                 String editMod,
                                 String baseDate) {
    PatPersonalMain patPersonalMain = patPersonalMainDao.selectById(patId);
    String opeCd;

    // #10553 変更区分送信設定0:削除データを送信しない(変更で送信する)1：削除データを送信する(削除新規で送信する)
    // del #11004 連携イベント発生部分不正 piao start
    // int modify_send_class = this.treatmentRecordService.getCoopIniSchModifySendClass(patPersonalMain.getFacility_cd());
    // del #11004 連携イベント発生部分不正 piao end
    if (CollectionUtils.isNotEmpty(effectsIntervalOrdNoList)) {
      List<JournalCreateRequestPayload> journalCreateRequestPayloadList
        = new ArrayList<>(effectsIntervalOrdNoList.size());
      for (int i = 0; i < effectsIntervalOrdNoList.size(); i++) {
        // ope_cdの設定
    	if (0 == effectsIntervalOrdNoList.get(i).getIndKurCd()) {
    		if (effectsIntervalOrdNoList.get(i).isTargetWeightFlag()) {
    			opeCd = "004214";
    	    } else {
    	        opeCd = "004213";
    	     }
    	} else {
    		if (effectsIntervalOrdNoList.get(i).isTargetWeightFlag()) {
    			opeCd = "004014";
  	        } else {
  	        	opeCd = "004013";
  	        }
    	}
        // ャーナルパラメータ作成
        journalCreateRequestPayloadList.add(
          BeanBuilderUtils.of(JournalCreateRequestPayload::new)
            .with(JournalCreateRequestPayload::setFacilityCd, facilityCd)
            .with(JournalCreateRequestPayload::setOpeCd, opeCd)
            .with(JournalCreateRequestPayload::setCoopCd, "ind_dial")
            .with(JournalCreateRequestPayload::setCoopCdIndex, "")
            // #10553 変更区分送信設定0:削除データを送信しない(変更で送信する)1：削除データを送信する(削除新規で送信する)
            // mod #10553 連携イベント発生部分不正 piao start
            // .with(JournalCreateRequestPayload::setCrud, modify_send_class == 2 ? "D" : "U")
            .with(JournalCreateRequestPayload::setCrud, "U")
            // mod #10553 連携イベント発生部分不正 piao end
            .with(JournalCreateRequestPayload::setDirection, "S")
            .with(JournalCreateRequestPayload::setAnaResult, "0")
            .with(JournalCreateRequestPayload::setCoopResult, "0")
            .with(JournalCreateRequestPayload::setPatId, patId)
            .with(JournalCreateRequestPayload::setHospPatId, patPersonalMain.getHosp_pat_id())
            .with(JournalCreateRequestPayload::setOrdNo, effectsIntervalOrdNoList.get(i).getOrdNo())
            .with(JournalCreateRequestPayload::setBaseDate, effectsIntervalOrdNoList.get(i).getTreatDate())
            .with(JournalCreateRequestPayload::setUserId, userId)
            .build()
        );

        // #10553 変更区分送信設定0:削除データを送信しない(変更で送信する)1：削除データを送信する(削除新規で送信する)
        // del #11004 連携イベント発生部分不正 piao start
        // if (modify_send_class == 2) {
        //   journalCreateRequestPayloadList.add(
        //     BeanBuilderUtils.of(JournalCreateRequestPayload::new)
        //       .with(JournalCreateRequestPayload::setFacilityCd, facilityCd)
        //       .with(JournalCreateRequestPayload::setOpeCd, opeCd)
        //       .with(JournalCreateRequestPayload::setCoopCd, "ind_dial")
        //       .with(JournalCreateRequestPayload::setCoopCdIndex, "")
        //       .with(JournalCreateRequestPayload::setCrud, "C")
        //       .with(JournalCreateRequestPayload::setDirection, "S")
        //       .with(JournalCreateRequestPayload::setAnaResult, "0")
        //       .with(JournalCreateRequestPayload::setCoopResult, "0")
        //       .with(JournalCreateRequestPayload::setPatId, patId)
        //       .with(JournalCreateRequestPayload::setHospPatId, patPersonalMain.getHosp_pat_id())
        //       .with(JournalCreateRequestPayload::setOrdNo, effectsIntervalOrdNoList.get(i).getOrdNo())
        //       .with(JournalCreateRequestPayload::setBaseDate, effectsIntervalOrdNoList.get(i).getTreatDate())
        //       .with(JournalCreateRequestPayload::setUserId, userId)
        //       .build()
        //   );
        // }
        // del #11004 連携イベント発生部分不正 piao end
      }
      //ャーナル更新APIリクエスト
      callCreateJournalForCtrNo(journalCreateRequestPayloadList);
    }

    String opeCdForProfile;
    switch (editMod) {
      case "I" -> opeCdForProfile = "007004";
      case "U" -> opeCdForProfile = "007005";
      case "D" -> opeCdForProfile = "007006";
      default -> opeCdForProfile = null;
    }

    LocalDate localDate;
    if (baseDate.length() > 10) {
      localDate = OffsetDateTime.parse(baseDate, DateTimeFormatter.ISO_OFFSET_DATE_TIME).toLocalDate();
    } else {
      localDate = LocalDate.parse(baseDate, DateTimeFormatter.ISO_DATE);
    }

    if (StringUtils.hasText(opeCdForProfile)) {
      List<JournalCreateRequestPayload> journalCreateRequestPayloadList = List.of(
        BeanBuilderUtils.of(JournalCreateRequestPayload::new)
          .with(JournalCreateRequestPayload::setFacilityCd, facilityCd)
          .with(JournalCreateRequestPayload::setOpeCd, opeCdForProfile)
          .with(JournalCreateRequestPayload::setCrud, "U")
          .with(JournalCreateRequestPayload::setPatId, patId)
          .with(JournalCreateRequestPayload::setHospPatId, patPersonalMain.getHosp_pat_id())
          .with(JournalCreateRequestPayload::setOrdNo, null)
          .with(JournalCreateRequestPayload::setBaseDate, localDate.format(DateTimeFormatter.ofPattern("uuuuMMdd")))
          .with(JournalCreateRequestPayload::setUserId, userId)
          .build()
      );
      //ャーナル更新APIリクエスト
      callCreateJournalForCtrNo(journalCreateRequestPayloadList);
    }
  }
  // add #10710 【身体情報関連】⑦データリスト 荘 2024-07-12 end

  // add #10553 連携イベント発生部分不正【最優先】ope_cd修正 荘 2024-07-29 start
  @Override
  @Async
  public void sendJournalForNotDwAndTw(long patId,
                                       Long userId,
                                       String facilityCd,
                                       String editMod,
                                       String baseDate){
    PatPersonalMain patPersonalMain = patPersonalMainDao.selectById(patId);
    String opeCdForProfile;
    switch (editMod) {
      case "I" -> opeCdForProfile = "007002";
      case "U" -> opeCdForProfile = "007003";
      case "D" -> opeCdForProfile = "007012";
      default -> opeCdForProfile = null;
    }

    LocalDate localDate;
    if (baseDate.length() > 10) {
      localDate = OffsetDateTime.parse(baseDate, DateTimeFormatter.ISO_OFFSET_DATE_TIME).toLocalDate();
    } else {
      localDate = LocalDate.parse(baseDate, DateTimeFormatter.ISO_DATE);
    }

    if (StringUtils.hasText(opeCdForProfile)) {
      List<JournalCreateRequestPayload> journalCreateRequestPayloadList = List.of(
        BeanBuilderUtils.of(JournalCreateRequestPayload::new)
          .with(JournalCreateRequestPayload::setFacilityCd, facilityCd)
          .with(JournalCreateRequestPayload::setOpeCd, opeCdForProfile)
          .with(JournalCreateRequestPayload::setCrud, "U")
          .with(JournalCreateRequestPayload::setPatId, patId)
          .with(JournalCreateRequestPayload::setHospPatId, patPersonalMain.getHosp_pat_id())
          .with(JournalCreateRequestPayload::setOrdNo, null)
          .with(JournalCreateRequestPayload::setBaseDate, localDate.format(DateTimeFormatter.ofPattern("uuuuMMdd")))
          .with(JournalCreateRequestPayload::setUserId, userId)
          .build()
      );
      //ャーナル更新APIリクエスト
      callCreateJournalForCtrNo(journalCreateRequestPayloadList);
    }
  }
  // add #10553 連携イベント発生部分不正【最優先】ope_cd修正 荘 2024-07-29 end
}
