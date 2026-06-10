package jp.co.nikkiso.ntss.admin_web.web.rest;

import jp.co.nikkiso.ntss.admin_web.request.patientCapture.JournalCreateRequestPayload;
import jp.co.nikkiso.ntss.admin_web.service.JournalService;
import jp.co.nikkiso.ntss.admin_web.service.ScheduleListService;
import jp.co.nikkiso.ntss.admin_web.service.indHistory.IndHistory;
// add FNSI-redmine 5461 劉祥霖　start
import jp.co.nikkiso.ntss.admin_web.service.journal.JournalCreatePayloadService;
import jp.co.nikkiso.ntss.admin_web.service.indschedule.IndScheduleService;
import jp.co.nikkiso.ntss.admin_web.service.indschedule.IndScheduleServiceImpl;
import jp.co.nikkiso.ntss.admin_web.service.IndHistoryMakeService;
import jp.co.nikkiso.ntss.admin_web.service.nextpat.NextPatService;
import jp.co.nikkiso.ntss.admin_web.service.statusMap.StatusMapIndSchedule2Service;
import jp.co.nikkiso.ntss.admin_web.web.rest.util.WebApiCallCommonUtil;
// add FNSI-redmine 5461 劉祥霖　end
// add FNSI-redmine 6588 劉祥霖　start
import org.apache.commons.collections.CollectionUtils;
import org.json.JSONObject;
// add FNSI-redmine 6588 劉祥霖　start
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.request.statusMap.StatusMapIndSchedule2Operation;
import jp.co.nikkiso.ntss.admin_web.request.statusMap.StatusMapIndSchedule2Request;
import jp.co.nikkiso.ntss.admin_web.request.scheduleList.UpdateScheduleListDataResponse;
import jp.co.nikkiso.ntss.admin_web.response.sendConditionCancel.SendConditionCancelResponse;
import jp.co.nikkiso.ntss.admin_web.response.statusMap.MarkerInfoResponse;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.OrdMainService;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.sendConditionCancel.SendConditionCancelService;
import jp.co.nikkiso.ntss.admin_web.service.statusMap.TreatmentStatusMapService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.FUNCTION_CODE;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.OrdScheduleDao;
//#9899:スケジュール割り当てで患者IDの列と同姓同名アイコンが表示されていない Start
import jp.co.nikkiso.ntss.core.dao.PatMainDao;
import jp.co.nikkiso.ntss.core.entity.PatMain;
//#9899:スケジュール割り当てで患者IDの列と同姓同名アイコンが表示されていない End
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.OrdSchedule;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainForNotAssignedSchedule;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import lombok.extern.slf4j.Slf4j;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

@RestController
@Slf4j
@RequestMapping(Uri.TREAT_STATUS_MAP)
public class TreatmentStatusMapRestResource {
  /**
   * 治療状況マップ情報の取得
   */
  @Autowired
  private OrdMainDao ordMainDao;

  @Autowired
  private TreatmentStatusMapService treatmentStatusMapService;

  @Autowired
  private SendConditionCancelService sendConditionCancelService;

  @Autowired
  OrdMainService ordMainService;

  @Autowired
  private OrdScheduleDao ordScheduleDao;

  @Autowired
  LogService logService;

  @Autowired
  ScheduleListService scheduleListService;
  // add FNSI-redmine 5461 劉祥霖　start
  @Autowired
  WebApiCallCommonUtil webApiCallCommonUtil;
  //#9899:スケジュール割り当てで患者IDの列と同姓同名アイコンが表示されていない Start
  @Autowired
  private PatMainDao patMainDao;
  //#9899:スケジュール割り当てで患者IDの列と同姓同名アイコンが表示されていない End

  // add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao strat
  @Autowired
  private JournalService journalService;

  @Autowired
  private JournalCreatePayloadService journalCreatePayloadService;
  // add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao end

  // add FNSI-redmine 5461 劉祥霖　end

  @Autowired
  IndScheduleService indScheduleService;

  @Autowired
  IndHistoryMakeService indHistoryMakeService;

  @Autowired
  private StatusMapIndSchedule2Service statusMapIndSchedule2Service;

  @Autowired
  private NextPatService nextPatService;

  /**
   *指定したord_noの治療状況マップアイコン設定情報を取得
   * @param ordNo
   * @return
   */
  @GetMapping("/{ordNo}")
  public ResponseEntity<?> getTreatmentStatusMapinfo(
      @PathVariable List<Long> ordNo,
      @AuthenticationPrincipal NtssUser ntssUser) {
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("getTreatmentStatusMapinfo/ ordNo is " + ordNo);
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_STATUS_MAP, SERVICE_NAME.FNSI, null);
    try {
      // マーカー情報取得
      List<MarkerInfoResponse> treatmentStatusMapinfo = treatmentStatusMapService.getMarkerInfo(ordNo,
          ntssUser.getFacilityCd());
      // エラーがない場合、得られた情報を返す
      return new ResponseEntity<>(treatmentStatusMapinfo, HttpStatus.OK);
    } catch (Exception e) {
      //
      eventLogMessage.setLogMessage("REST request error by get getTreatmentStatusMapinfo : " + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_STATUS_MAP, SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * 利用者マスタリストを取得
   * @param facilityCd
   * @return
   */
  @GetMapping("/user/{facilityCd}")
  public ResponseEntity<?> getUserList(
      @PathVariable String facilityCd) {
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("getUserList/ facilityCd is " + facilityCd);
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_STATUS_MAP, SERVICE_NAME.FNSI, null);
    try {
      // 利用者マスタリスト取得
      List<MstPersonalUser> mstPersonalUserList = treatmentStatusMapService.personalUserSelect(facilityCd);
      // エラーがない場合、得られた情報を返す
      return new ResponseEntity<>(mstPersonalUserList, HttpStatus.OK);
    } catch (Exception e) {
      // エラーの場合
      eventLogMessage.setLogMessage("REST request error by getUserList : " + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_STATUS_MAP, SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * 未割当一覧の取得[指定日付分のみ]
   * @param facilityCd
   * @param treatDate
   * @param bedCd
   * @return
   */
  @GetMapping("notassigned/{facilityCd}/{treatDate}/{bedCd}")
  public ResponseEntity<?> getNotAssignedList(
      @PathVariable String facilityCd,
      @PathVariable String treatDate,
      @PathVariable Long bedCd) {
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("getNotAssignedList/ facilityCd is . treatDate is . bedCd is ." + facilityCd + treatDate + bedCd);
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_STATUS_MAP, SERVICE_NAME.FNSI, null);
    try {
      List<OrdMainForNotAssignedSchedule> notAssignedSchedule = treatmentStatusMapService
          .getNotAssignedOrdMain(facilityCd, treatDate, bedCd);
      List<OrdMainForNotAssignedSchedule> removeItems = new ArrayList<OrdMainForNotAssignedSchedule>();

      // エラーがない場合、得られた情報を返す
      // #9485 mod  患者名の姓または名に連携からnullが登録された場合に、各画面の患者名表示に「null」と表示してしまう。2024-04-25 卓 start
      String pat_last_name = "";
      String pat_first_name = "";
      // #9485 mod  患者名の姓または名に連携からnullが登録された場合に、各画面の患者名表示に「null」と表示してしまう。2024-04-25 卓 end
      for (int intlop = notAssignedSchedule.size() - 1; 0 <= intlop; intlop--) {
        OrdMainForNotAssignedSchedule dat = notAssignedSchedule.get(intlop);
        PatPersonalMain patPersonal = treatmentStatusMapService.patientSelect(dat.getPatId());
        if (patPersonal != null) {
          // #9485 mod  患者名の姓または名に連携からnullが登録された場合に、各画面の患者名表示に「null」と表示してしまう。2024-04-25 卓 start
          // 削除されていない場合は名前を追加
          //dat.setPatName(patPersonal.getPat_last_name() + patPersonal.getPat_first_name());
          pat_last_name = patPersonal.getPat_last_name() == null?"":patPersonal.getPat_last_name();
          pat_first_name = patPersonal.getPat_first_name() == null?"":patPersonal.getPat_first_name();
          dat.setPatName(pat_last_name + pat_first_name);
          // #9485 mod  患者名の姓または名に連携からnullが登録された場合に、各画面の患者名表示に「null」と表示してしまう。2024-04-25 卓 end

          //#9899:スケジュール割り当てで患者IDの列と同姓同名アイコンが表示されていない Start
          //患者ID
          dat.setHospPatId(patPersonal.getHosp_pat_id());
          //入外区分
          dat.setInOutClass(patPersonal.getIn_out_class());

          PatMain pat = patMainDao.selectById(dat.getPatId());
          dat.setIssame(0);
          if (pat != null) {
            dat.setIssame(Integer.parseInt(pat.getIs_same()));
          }
          //#9899:スケジュール割り当てで患者IDの列と同姓同名アイコンが表示されていない End
        } else {
          // 削除されている場合は一覧から削除
          notAssignedSchedule.remove(dat);
        }
      }

      return new ResponseEntity<>(notAssignedSchedule, HttpStatus.OK);
    } catch (Exception e) {
      // エラーの場合
      eventLogMessage.setLogMessage("REST request error by getNotAssignedList : " + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_STATUS_MAP, SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * 推定条件に一致する治療スケジュール情報を取得
   * @param treatDate 治療日
   * @param kurCd     クールCd
   * @param bedCd     ベッドCd
   * @return 条件に一致する治療スケジュール情報一覧
   */
  //mod FNSI redmine 劉祥霖 6588 start
  //  @GetMapping("find-schedule/{treatDate}/{kurCd}/{bedCd}")
  @GetMapping("find-schedule/{treatDate}/{kurCd}/{bedCd}/{facilityCd}/{ordNo}/{patId}/{indTreatmentCd}")
  //mod FNSI redmine 劉祥霖 6588 end
  public ResponseEntity<?> searchSchedule(
      @AuthenticationPrincipal NtssUser ntssUser,
      @PathVariable String treatDate,
      @PathVariable Long kurCd,
      @PathVariable Long bedCd
      //add FNSI redmine 6588 劉祥霖　start
     ,@PathVariable String facilityCd
     ,@PathVariable Long ordNo
     ,@PathVariable Long patId
      //add FNSI redmine 6588 劉祥霖　end
     ,@PathVariable Long indTreatmentCd
  ) {

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("searchSchedule/ facilityCd is " + ntssUser.getFacilityCd() + ". treatDate is " + treatDate +". kurCd is " + kurCd + "]. bedCd is " + bedCd + "." );
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_STATUS_MAP, SERVICE_NAME.FNSI, null);
    try {
      //mod FNSI redmine 6588 劉祥霖　start
      List<Long> ordNoList = new ArrayList<>();
      ordNoList.add(ordNo);
      JSONObject msgJson = new JSONObject("{}");
      String msgCd = "";
      ResponseEntity<List<OrdSchedule>> response = webApiCallCommonUtil.selectForSearchReservedBed(
        facilityCd,
        ordNoList,
        patId,
        bedCd,
        treatDate,
        kurCd,
        false);
      if (response.getBody().size() > 0 && ( response.getBody().get(0).getKurCd()!=kurCd || response.getBody().get(0).getTreatDate() != treatDate )) {
        // 既に治療予定あり → 画面にメッセージを返す
        msgCd = "isDummy";
        msgJson.put("msgCd", msgCd);
      }else {
        List<OrdSchedule> schedule = ordScheduleDao.selectByTreatDateKurCdBedCd(ntssUser.getFacilityCd(), treatDate,
          kurCd, bedCd);
        if(schedule.size()>0){
          msgCd = "notDummy";
          msgJson.put("msgCd", msgCd);
        }else{
          msgCd = "noclash";
          msgJson.put("msgCd", msgCd);
        }
      }
      // add/ #12465同患者同日同治療方法同クールの使用制限をしてもメッセージがでない tianqidong start
      List<OrdMain> ordMainList = ordMainDao.selectPatOrdMainByTreatDate(patId, facilityCd, treatDate);
      List<OrdMain> filteredList = ordMainList.stream()
        .filter(o -> o.getIndTreatmentCd() != null && o.getIndTreatmentCd().equals(indTreatmentCd.intValue()))
        .filter(o -> o.getTreatWeek() != null && o.getIndKurCd().equals(kurCd.intValue()))
        .collect(Collectors.toList());
      List<OrdMain> ordMainAllList = ordMainDao.selectByTreatDateAndFacilityCd(facilityCd, treatDate);
      List<OrdMain> filteredAllList = ordMainAllList.stream()
        .filter(o -> o.getIndTreatmentCd() != null && o.getIndTreatmentCd().equals(indTreatmentCd.intValue()))
        .filter(o -> o.getTreatWeek() != null && o.getIndKurCd().equals(kurCd.intValue()))
        .collect(Collectors.toList());
      filteredAllList.removeAll(filteredList);
      if(filteredAllList.size()>0){
        msgCd = "allSame";
        msgJson.put("msgCd", msgCd);
      }
      // add/ #12465同患者同日同治療方法同クールの使用制限をしてもメッセージがでない tianqidong end
      return new ResponseEntity<String>(msgJson.toString(), HttpStatus.OK);
      //mod FNSI redmine 6588 劉祥霖　end
    } catch (Exception e) {
      // エラーの場合

      eventLogMessage.setLogMessage("REST request error by searchSchedule : " +  e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_STATUS_MAP, SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * 指定条件に一致する治療スケジュール情報と指定ord_noと一致するかどうか判定し、一致した場合は治療状況を取得
   * @param treatDate 治療日
   * @param kurCd     クールCd
   * @param bedCd     ベッドCd
   * @param ordNo     オーダー番号
   * @return null：一致しない/else：治療状況
   */
  @GetMapping("dial-state/{treatDate}/{kurCd}/{bedCd}/{ordNo}")
  public ResponseEntity<?> checkSchedule(
      @AuthenticationPrincipal NtssUser ntssUser,
      @PathVariable String treatDate,
      @PathVariable Long kurCd,
      @PathVariable Long bedCd,
      @PathVariable Long ordNo) {

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("checkSchedule/ facilityCd is" + ntssUser.getFacilityCd() + ". treatDate is"  + treatDate + ". kurCd is " + kurCd + "]. bedCd is " + bedCd +
    		 ". ordNo is " + ordNo + ".");
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_STATUS_MAP, SERVICE_NAME.FNSI, null);

    try {
      String rstDialysisState = "";

      // 治療スケジュールから指定条件で情報を取得
      List<OrdSchedule> schedule = ordScheduleDao.selectByTreatDateKurCdBedCd(ntssUser.getFacilityCd(), treatDate,
        kurCd, bedCd);
      // オーダー番号を一致する情報があるかどうか
      OrdSchedule item = schedule.stream()
        .filter(sche -> Objects.equals(sche.getOrdNo(), ordNo))
        .findFirst()
        .orElse(null);
      if (item != null) {
        // 指定スケジュールあり
        OrdMain info = ordMainDao.selectByOrdNo(ordNo);
        if (info != null) {
          // 治療状況取得
          rstDialysisState = info.getRstDialysisState();
        }
      }
      return new ResponseEntity<>(rstDialysisState, HttpStatus.OK);
    } catch (Exception e) {
      // エラーの場合
      eventLogMessage.setLogMessage("REST request error by checkSchedule : " +  e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_STATUS_MAP, SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * 治療予定のベッド移動前チェック結果を取得
   * @param ordNo     オーダー番号
   * @param bedCd     ベッドCd
   * @return 結果情報
   */
  @GetMapping("check-before-move-ord/{ordNo}/{bedCd}")
  public ResponseEntity<?> checkSchedule(
      @AuthenticationPrincipal NtssUser ntssUser,
      @PathVariable Long ordNo,
      @PathVariable Long bedCd) {

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("checkBedStatus/ facilityCd is" + ntssUser.getFacilityCd() + ". ordNo is"  + ordNo + ". bedCd is " + bedCd + ".");
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_STATUS_MAP, SERVICE_NAME.FNSI, null);

    try {
      // 各種チェックを実施
      List<MarkerInfoResponse> treatmentStatusMapinfo = treatmentStatusMapService.checkBeforeMoveOrdMain(ordNo, bedCd,
          ntssUser.getFacilityCd());
      // エラーがない場合、得られた情報を返す
      return new ResponseEntity<>(treatmentStatusMapinfo, HttpStatus.OK);
    } catch (Exception e) {
      // エラーの場合
      eventLogMessage.setLogMessage("REST request error by checkSchedule : " +  e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_STATUS_MAP, SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * 治療情報にベッドを割り当てる
   * @param facilityCd
   * @param bedCd
   * @param treatDate
   * @param kurCd
   * @return
   */
  @PutMapping("assign/{facilityCd}/{ordNo}/{bedCd}/{treatDate}/{kurCd}/{userId}")
  public ResponseEntity<?> assignOrdMain(
      @PathVariable String facilityCd,
      @PathVariable Long ordNo,
      @PathVariable Long bedCd,
      @PathVariable String treatDate,
      @PathVariable Long kurCd,
      @PathVariable Long userId) {
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("assignOrdMain/facilityCd is . ordNo is . bedCd is . treatDate is . kurCd is . UserId is ." +
            facilityCd + ordNo + bedCd + treatDate + kurCd + userId);
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_STATUS_MAP, SERVICE_NAME.FNSI, null);

    // add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao start
    int ret = 0;
    List<OrdMain> resultOrdMainChangedDataInfoList = new ArrayList<>(); // 連携用、イベントログ用
    List<OrdMain> resultOrdMainChangeBeforeDataInfoList = new ArrayList<>(); // 連携用、イベントログ用
    long patId = 0L;
    // add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao end

    try {
      // 治療情報にベッドを割り当て
      // add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao start
      OrdMain ordMain = treatmentStatusMapService.getOrdMainByOrdNo(ordNo);
      if(ordMain != null){
        resultOrdMainChangeBeforeDataInfoList.add(ordMain); // 変更前データ退避
        patId = ordMain.getPatId();
      }
      // add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao end
      // mod #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao start
      ret = treatmentStatusMapService.assignBedToOrdMain(
          facilityCd, ordNo, bedCd, treatDate, kurCd, userId);
      // mod #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao end

      // add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao start
      OrdMain beforeOrdMain = treatmentStatusMapService.getOrdMainByOrdNo(ordNo);
      if(beforeOrdMain != null){
        resultOrdMainChangedDataInfoList.add(beforeOrdMain); // 変更後データ退避
      }
      // add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao end

      // ベッドが割り当てられている場合
      if (!bedCd.equals(0L)) {
        // ベッドに対して次患者更新実施
        ret = treatmentStatusMapService.updateNextPatInfo(bedCd);
      }

      //add FNSI redmine 6588 劉祥霖　start
      //ベッド登録後、ダミースケジュールを生成する
      String opeMode = "3";
      List<Long> ordNoList = new ArrayList<>();
      if (ordNo != null) {
        ordNoList.add(ordNo);
      }
      ResponseEntity<String> retDummy = webApiCallCommonUtil.operateDummySchedule(ordNoList, bedCd, kurCd, opeMode);
      if ((null == retDummy) || (HttpStatus.OK != retDummy.getStatusCode())) {
        logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
        return new ResponseEntity<>("DBの更新に失敗しました。", null, HttpStatus.INTERNAL_SERVER_ERROR);
      }

      //add FNSI redmine 6588 劉祥霖　end
      // del #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao start
//      return new ResponseEntity<>(ret, HttpStatus.OK);
      // del #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao end
    } catch (Exception e) {
      // エラーの場合
      eventLogMessage.setLogMessage("REST request error by assignOrdMain : " + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_STATUS_MAP, SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
    }

    //指示履歴登録処理 MongoDB
    try {
      List<IndHistory> indHistoryList = indScheduleService.createIndHistoryForIndSchedule(facilityCd, resultOrdMainChangeBeforeDataInfoList, resultOrdMainChangedDataInfoList);
      if (indHistoryList != null && !indHistoryList.isEmpty()) {
        indHistoryMakeService.createHistoryExecuteBatch(indHistoryList, "2");
      }
    } catch (Exception e) {
      //エラー
      eventLogMessage.setLogMessage("指示履歴登録処理 MongoDB " + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_STATUS_MAP, SERVICE_NAME.FNSI, null);
    }

    // add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao start
    // 連携関連呼出
    try {
      String actionMode = "STATUS_MAP";

      Long updUserId = userId;
      List<Long> patIdList = new ArrayList<>();
      patIdList.add(patId);

      Map<String, List<Object>> resultAllChangedDataInfoList = new HashMap<>(); // 連携用、イベントログ用
      List<Object> objectList = new ArrayList<>(resultOrdMainChangedDataInfoList);
      resultAllChangedDataInfoList.put("ord_main", objectList);
      Map<String, List<Object>> resultAllChangeBeforeDataInfoList = new HashMap<>(); // 連携用、イベントログ用
      List<Object> objectBeforeList = new ArrayList<>(resultOrdMainChangeBeforeDataInfoList);
      resultAllChangeBeforeDataInfoList.put("ord_main", objectBeforeList);

      List<JournalCreateRequestPayload> journalList = journalCreatePayloadService.createJournalPayload(facilityCd, resultAllChangedDataInfoList, resultAllChangeBeforeDataInfoList, patIdList, updUserId, actionMode);
      if (!CollectionUtils.isEmpty(journalList)) {
        journalService.callCreateJournalForCtrNo(journalList);
      }
    } catch (Exception e) {
      //エラー
      eventLogMessage.setLogMessage("連携関連呼出 " + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_SCHEDULE_LIST, SERVICE_NAME.FNSI, null);
    }

    return new ResponseEntity<>(ret, HttpStatus.OK);
    // add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao end
  }

  /**
   * 治療情報をベッド未割当にする
   * @param facilityCd
   * @param bedCd
   * @param treatDate
   * @param kurCd
   * @return
   */
  @PutMapping("unassigment/{facilityCd}/{ordNo}/{userId}")
  public ResponseEntity<?> unassigmentOrdMain(
      @PathVariable String facilityCd,
      @PathVariable Long ordNo,
      @PathVariable Long userId) {
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("unassigmentOrdMain/facilityCd is . ordNo is . userId is ." + facilityCd + ordNo + userId);
    logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_STATUS_MAP, SERVICE_NAME.FNSI, null);
    // add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao start
    ResponseEntity<Integer> ret = null;
    List<OrdMain> resultOrdMainChangedDataInfoList = new ArrayList<>(); // 連携用、イベントログ用
    List<OrdMain> resultOrdMainChangeBeforeDataInfoList = new ArrayList<>(); // 連携用、イベントログ用
    long patId = 0L;
    // add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao end
    try {
      // ord_mainを取得
//      OrdMain ordMain = treatmentStatusMapService.getOrdMainByOrdNo(ordNo);
//
//      if (ordMain != null) {
//        Long kurCd;
//        if (ordMain.getIndKurCd() != null) {
//          kurCd = Integer.toUnsignedLong(ordMain.getIndKurCd());
//        } else {
//          kurCd = 0L;
//        }
//        Long bedCd = 0L;
//        if (ordMain.getIndBedCd() != null) {
//          bedCd = Integer.toUnsignedLong(ordMain.getIndBedCd());
//        }
//
//        // 治療情報にベッドを割り当てられたベッドを消す
//        int ret = treatmentStatusMapService.assignBedToOrdMain(
//          facilityCd,
//          ordNo,
//          0L,
//          ordMain.getTreatDate(),
//          kurCd,
//          userId);
//
//        // 元ベッドが割り当てられている場合
//        if (!bedCd.equals(0L)) {
//          // 元ベッドに対して次患者更新実施
//          ret = treatmentStatusMapService.updateNextPatInfo(bedCd);
//        }
//
//        return new ResponseEntity<>(ret, HttpStatus.OK);
//      } else {
//        throw new RuntimeException("unassigmentOrdMain data not found./");
//      }
      // add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao start
      OrdMain ordMain = treatmentStatusMapService.getOrdMainByOrdNo(ordNo);
      if(ordMain != null){
        resultOrdMainChangeBeforeDataInfoList.add(ordMain); // 変更前データ退避
        patId = ordMain.getPatId();
      }
      // add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao end

      // mod #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao start
      ret = treatmentStatusMapService.unassigmentOrdMain(facilityCd, ordNo, userId);
      // mod #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao end

      // add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao start
      OrdMain beforeOrdMain = treatmentStatusMapService.getOrdMainByOrdNo(ordNo);
      if(beforeOrdMain != null){
        resultOrdMainChangedDataInfoList.add(beforeOrdMain); // 変更後データ退避
      }
      // add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao end

    } catch (Exception e) {
      // エラーの場合
      eventLogMessage.setLogMessage("REST request error by unassigmentOrdMain : " + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_STATUS_MAP, SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
    }

    //指示履歴登録処理 MongoDB
    try {
      List<IndHistory> indHistoryList = indScheduleService.createIndHistoryForIndSchedule(facilityCd, resultOrdMainChangeBeforeDataInfoList, resultOrdMainChangedDataInfoList);
      if (indHistoryList != null && !indHistoryList.isEmpty()) {
        indHistoryMakeService.createHistoryExecuteBatch(indHistoryList, "2");
      }
    } catch (Exception e) {
      //エラー
      eventLogMessage.setLogMessage("指示履歴登録処理 MongoDB " + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_STATUS_MAP, SERVICE_NAME.FNSI, null);
    }

    // add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao start
    // 連携関連呼出
    try {
      String actionMode = "STATUS_MAP";

      Long updUserId = userId;
      List<Long> patIdList = new ArrayList<>();
      patIdList.add(patId);

      Map<String, List<Object>> resultAllChangedDataInfoList = new HashMap<>(); // 連携用、イベントログ用
      List<Object> objectList = new ArrayList<>(resultOrdMainChangedDataInfoList);
      resultAllChangedDataInfoList.put("ord_main", objectList);
      Map<String, List<Object>> resultAllChangeBeforeDataInfoList = new HashMap<>(); // 連携用、イベントログ用
      List<Object> objectBeforeList = new ArrayList<>(resultOrdMainChangeBeforeDataInfoList);
      resultAllChangeBeforeDataInfoList.put("ord_main", objectBeforeList);

      List<JournalCreateRequestPayload> journalList = journalCreatePayloadService.createJournalPayload(facilityCd, resultAllChangedDataInfoList, resultAllChangeBeforeDataInfoList, patIdList, updUserId, actionMode);
      if (!CollectionUtils.isEmpty(journalList)) {
        journalService.callCreateJournalForCtrNo(journalList);
      }
    } catch (Exception e) {
      //エラー
      eventLogMessage.setLogMessage("連携関連呼出 " + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_SCHEDULE_LIST, SERVICE_NAME.FNSI, null);
    }

    return ret;
    // add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao end
  }

  /**
   * 条件送信キャンセル
   * @param bedCd
   * @return
   */
  @PutMapping("unassigment/send_condition_cancel/{bedCd}")
  public ResponseEntity<?> sendConditionCansel(
      @PathVariable Long bedCd,
      @AuthenticationPrincipal NtssUser ntssUser) {
    try {
      //mod #10412 次患者更新関連全体見直し対応 朴 start
//      SendConditionCancelResponse ret = sendConditionCancelService.doCancel(ntssUser.getFacilityCd(), bedCd);
      SendConditionCancelResponse ret = sendConditionCancelService.doCancel2(ntssUser.getFacilityCd(), bedCd, null);
      //mod #10412 次患者更新関連全体見直し対応 朴 end

      return new ResponseEntity<>(ret, HttpStatus.OK);
    } catch (Exception e) {
      // エラーの場合
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("REST request error by sendConditionCansel: " + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_STATUS_MAP, SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * 治療情報のベッドを移動する
   * @param facilityCd
   * @param bedCd
   * @param treatDate
   * @param kurCd
   * @return
   */
  @PutMapping("assign/move/{facilityCd}/{ordNo}/{bedCd}/{userId}/{isSendCondition}")
  public ResponseEntity<?> assignMoveOrdMain(
      @PathVariable String facilityCd,
      @PathVariable Long ordNo,
      @PathVariable Long bedCd,
      @PathVariable Long userId,
      @PathVariable String isSendCondition) {
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("assignMoveOrdMain/facilityCd is . ordNo is . bedCd is . userId is ." +
        facilityCd + ordNo + bedCd + userId);
    logService.log(LogLevel.DEBUG, eventLogMessage, "", SERVICE_NAME.FNSI, null);

    // add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao start
    int ret = 0;
    List<OrdMain> resultOrdMainChangedDataInfoList = new ArrayList<>(); // 連携用、イベントログ用
    List<OrdMain> resultOrdMainChangeBeforeDataInfoList = new ArrayList<>(); // 連携用、イベントログ用
    long patId = 0L;
    // add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao end

    try {
      // del #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao start
//      int ret = 0;
      // del #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao start
      // ord_mainを取得
      OrdMain ordMain = treatmentStatusMapService.getOrdMainByOrdNo(ordNo);

      // add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao start
      if(ordMain != null){
        resultOrdMainChangeBeforeDataInfoList.add(ordMain); // 変更前データ退避
        patId = ordMain.getPatId();
      }
      // add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao end

      Long oldBedCd = 0L;
      if (ordMain.getIndBedCd() != null) {
        oldBedCd = Integer.toUnsignedLong(ordMain.getIndBedCd());
      }

      // 治療情報にベッドを再度割り当てる
      if (ordMain != null) {
        ret = treatmentStatusMapService.assignBedToOrdMain(
            facilityCd,
            ordNo,
            bedCd,
            ordMain.getTreatDate(),
            this.getKurCd(ordMain).longValue(),
            userId);
      }

      // add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao start
      OrdMain beforeOrdMain = treatmentStatusMapService.getOrdMainByOrdNo(ordNo);
      if(beforeOrdMain != null){
        resultOrdMainChangedDataInfoList.add(beforeOrdMain); // 変更後データ退避
      }
      // add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao end

      // 元ベッドが割り当てられている場合
      if (!oldBedCd.equals(0L)) {
        // 元ベッドに対して次患者更新実施
        ret = treatmentStatusMapService.updateNextPatInfo(oldBedCd);
      }
      // 現ベッドが割り当てられている場合
      if (!bedCd.equals(0L)) {
        // 現在ベッドに対して次患者更新実施
        ret = treatmentStatusMapService.updateNextPatInfo(bedCd);
      }

      // add FNSI-対応401 付 start
      // sjy: Delete data from ord_checklist by ord_no where the value of rst_dialysis_state of ord_main is in 0,1,2
//      Integer beforBedCd = ordMain.getIndBedCd();
      switch(ordMain.getRstDialysisState()) {
        case "0":
        case "1":
        case "2":
          // sendConditionCancelService.doCancel(facilityCd, beforBedCd.longValue(), null, "2");
          scheduleListService.deleteOrdCheckListByOrdNo(ordNo, facilityCd);
          break;
      }
      // add FNSI-対応401 付 end
      // add FNSI-redmine 5461 劉祥霖　start
      List<Long> ordNoList = new ArrayList<Long>();
      ordNoList.add(ordNo);
      ResponseEntity<String> retDummy = webApiCallCommonUtil.operateDummySchedule(
        ordNoList,
        bedCd,
        this.getKurCd(ordMain).longValue(),
        "1"
      );
      // add FNSI-redmine 5461 劉祥霖　end

      // del #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao start
//      return new ResponseEntity<>(ret, HttpStatus.OK);
      // del #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao end
    } catch (Exception e) {
      // エラーの場合
      eventLogMessage.setLogMessage("REST request error by assignMoveOrdMain : " + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_STATUS_MAP, SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
    }

    //指示履歴登録処理 MongoDB
    try {
      List<IndHistory> indHistoryList = indScheduleService.createIndHistoryForIndSchedule(facilityCd, resultOrdMainChangeBeforeDataInfoList, resultOrdMainChangedDataInfoList);
      if (indHistoryList != null && !indHistoryList.isEmpty()) {
        indHistoryMakeService.createHistoryExecuteBatch(indHistoryList, "2");
      }
    } catch (Exception e) {
      //エラー
      eventLogMessage.setLogMessage("指示履歴登録処理 MongoDB " + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_STATUS_MAP, SERVICE_NAME.FNSI, null);
    }

    // add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao start
    // 連携関連呼出
    try {
      String actionMode = "STATUS_MAP";

      Long updUserId = userId;
      List<Long> patIdList = new ArrayList<>();
      patIdList.add(patId);

      Map<String, List<Object>> resultAllChangedDataInfoList = new HashMap<>(); // 連携用、イベントログ用
      List<Object> objectList = new ArrayList<>(resultOrdMainChangedDataInfoList);
      resultAllChangedDataInfoList.put("ord_main", objectList);
      Map<String, List<Object>> resultAllChangeBeforeDataInfoList = new HashMap<>(); // 連携用、イベントログ用
      List<Object> objectBeforeList = new ArrayList<>(resultOrdMainChangeBeforeDataInfoList);
      resultAllChangeBeforeDataInfoList.put("ord_main", objectBeforeList);

      List<JournalCreateRequestPayload> journalList = journalCreatePayloadService.createJournalPayload(facilityCd, resultAllChangedDataInfoList, resultAllChangeBeforeDataInfoList, patIdList, updUserId, actionMode);
      if (!CollectionUtils.isEmpty(journalList)) {
        journalService.callCreateJournalForCtrNo(journalList);
      }
    } catch (Exception e) {
      //エラー
      eventLogMessage.setLogMessage("連携関連呼出 " + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_SCHEDULE_LIST, SERVICE_NAME.FNSI, null);
    }

    return new ResponseEntity<>(ret, HttpStatus.OK);
    // add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao end
  }

  /**
   * 指示変更確認
   *
   * @param ordNo
   * @return
   */
  @PutMapping("/check-ind/{ordNo}")
  public ResponseEntity<?> updateCheckForMap(@PathVariable Long ordNo, @RequestBody HashMap<String, String> content) {
    try {
      treatmentStatusMapService.updatePatIndApproveCheckForMap(ordNo, content.get("content"));
      return new ResponseEntity<>(HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_STATUS_MAP, SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 治療情報のベッドを入れ替える
   * @param facilityCd
   * @param bedCd
   * @param treatDate
   * @param kurCd
   * @return
   */
  @PutMapping("assign/swap/{ordNo1}/{ordNo2}/{userId}")
  public ResponseEntity<?> assignSwapOrdMain(
      @PathVariable Long ordNo1,
      @PathVariable Long ordNo2,
      @PathVariable Long userId) {
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("assignSwapOrdMain/ ordNo2 is . ordNo2 is . userId is ." + ordNo1 + ordNo2 + userId);
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_STATUS_MAP, SERVICE_NAME.FNSI, null);

    try {
      // 二件のord_mainを取得
      OrdMain ordMain1 = treatmentStatusMapService.getOrdMainByOrdNo(ordNo1);
      OrdMain ordMain2 = treatmentStatusMapService.getOrdMainByOrdNo(ordNo2);
      Long ordMain1BedCd = this.getBedCd(ordMain1).longValue();
      Long ordMain2BedCd = this.getBedCd(ordMain2).longValue();

      // 治療情報にベッドを再度割り当てる
      if (ordMain1 != null && ordMain2 != null) {
        treatmentStatusMapService.assignBedToOrdMain(
            ordMain1.getFacilityCd(),
            ordMain1.getOrdNo(),
            ordMain2BedCd,
            ordMain1.getTreatDate(),
            this.getKurCd(ordMain1).longValue(),
            userId);

        treatmentStatusMapService.assignBedToOrdMain(
            ordMain2.getFacilityCd(),
            ordMain2.getOrdNo(),
            ordMain1BedCd,
            ordMain2.getTreatDate(),
            this.getKurCd(ordMain2).longValue(),
            userId);

        // ベッド1が割り当てられている場合
        if (!ordMain1BedCd.equals(0L)) {
          // 元ベッドに対して次患者更新実施
          treatmentStatusMapService.updateNextPatInfo(ordMain1BedCd);
        }
        // ベッド2が割り当てられている場合
        if (!ordMain2BedCd.equals(0L)) {
          // 現在ベッドに対して次患者更新実施
          treatmentStatusMapService.updateNextPatInfo(ordMain2BedCd);
        }
      }

      // add FNSI-対応401 付 start
      // sjy: Delete data from ord_checklist by ord_no where the value of rst_dialysis_state of ord_main is in 0,1,2
      switch(ordMain1.getRstDialysisState()) {
        case "0":
        case "1":
        case "2":
          scheduleListService.deleteOrdCheckListByOrdNo(ordNo1, ordMain1.getFacilityCd());
          break;
      }
      switch(ordMain2.getRstDialysisState()) {
        case "0":
        case "1":
        case "2":
          scheduleListService.deleteOrdCheckListByOrdNo(ordNo2, ordMain2.getFacilityCd());
          break;
      }
      // add FNSI-対応401 付 end

      //add FNSI redmine 6588 劉祥霖　start
      //ベッド入れ替え後、ダミースケジュールを生成する
      String opeMode = "3";

      List<Long> ordNoList1 = new ArrayList<>();
      if (ordNo1 != null) {
        ordNoList1.add(ordNo1);
      }
      ResponseEntity<String> retDummy1 = webApiCallCommonUtil.operateDummySchedule(ordNoList1, ordMain1BedCd, this.getKurCd(ordMain2).longValue(), opeMode);
      if ((null == retDummy1) || (HttpStatus.OK != retDummy1.getStatusCode())) {
        logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
        return new ResponseEntity<>("DBの更新に失敗しました。", null, HttpStatus.INTERNAL_SERVER_ERROR);
      }

      List<Long> ordNoList2 = new ArrayList<>();
      if (ordNo2 != null) {
        ordNoList2.add(ordNo2);
      }
      ResponseEntity<String> retDummy2 = webApiCallCommonUtil.operateDummySchedule(ordNoList2, ordMain1BedCd, this.getKurCd(ordMain1).longValue(), opeMode);
      if ((null == retDummy2) || (HttpStatus.OK != retDummy2.getStatusCode())) {
        logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
        return new ResponseEntity<>("DBの更新に失敗しました。", null, HttpStatus.INTERNAL_SERVER_ERROR);
      }

      //add FNSI redmine 6588 劉祥霖　end

      return new ResponseEntity<>(null, HttpStatus.OK);
    } catch (Exception e) {
      // エラーの場合
      eventLogMessage.setLogMessage("REST request error by assignSwapOrdMain : " + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_STATUS_MAP, SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
      }
  }

  /**
   * 治療状況マップ: MOVE / SWAP を {@link IndScheduleService#updateIndSchedule2} で行う（統合 REST）。
   *
   * <p>{@code POST /api/status_map/schedule/update}、body に {@code operation} 必須（{@code MOVE} または {@code SWAP}）。
   */
  @PostMapping("/schedule/update")
  public ResponseEntity<UpdateScheduleListDataResponse> updateIndSchedule2(
    @RequestBody StatusMapIndSchedule2Request req,
    @AuthenticationPrincipal NtssUser ntssUser
  ) {
    EventLogMessage eventLogMessage = new EventLogMessage();
    if (req == null || req.getOperation() == null || ntssUser == null) {
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
    try {
      if (req.getOperation() == StatusMapIndSchedule2Operation.MOVE
        || req.getOperation() == StatusMapIndSchedule2Operation.SWAP) {
        return handleIndSchedule2MoveOrSwap(req, ntssUser, eventLogMessage);
      }
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    } catch (Exception e) {
      eventLogMessage.setLogMessage("REST request error by updateIndSchedule2 : " + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_STATUS_MAP, SERVICE_NAME.FNSI, null);
      UpdateScheduleListDataResponse fail = new UpdateScheduleListDataResponse();
      fail.setPROC_RESULT(IndScheduleServiceImpl.PROC_RESULT.ERROR.toString());
      fail.setMessage(e.getMessage());
      return new ResponseEntity<>(fail, HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  private ResponseEntity<UpdateScheduleListDataResponse> handleIndSchedule2MoveOrSwap(
    StatusMapIndSchedule2Request req,
    NtssUser ntssUser,
    EventLogMessage eventLogMessage
  ) throws Exception {
    StatusMapIndSchedule2Operation op = req.getOperation();
    Long userId = req.getUserId();
    String facilityCd;
    List<Long> patIdListForJournal = new ArrayList<>();

    OrdMain ordMainBefore = null;
    Long ordNo = null;
    Long bedCd = null;
    Long oldBedCd = null;

    OrdMain ordMain1 = null;
    OrdMain ordMain2 = null;
    Long ordNo1 = null;
    Long ordNo2 = null;

    if (op == StatusMapIndSchedule2Operation.MOVE) {
      facilityCd = req.getFacilityCd();
      ordNo = req.getOrdNo();
      bedCd = req.getBedCd();
//      if (!ntssUser.isNkkAdminUser()) {
//        OrdMain checkOrdMain = ordMainService.selectByOrdNo(ordNo);
//        if ((checkOrdMain != null && checkOrdMain.getFacilityCd() != null && !checkOrdMain.getFacilityCd().equals(ntssUser.getFacilityCd()))
//          || (facilityCd != null && !facilityCd.equals(ntssUser.getFacilityCd()))) {
//          if (InvestigateLogUtils.enable_log_for_11205) {
//            String msg = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " facilityCd=" + facilityCd + " ordNo=" + ordNo + " ";
//            InvestigateLogUtils.info("11205", msg, "11205-FORBIDDEN");
//          } else {
//            return new ResponseEntity<>(HttpStatus.FORBIDDEN);
//          }
//        }
//      }
      ordMainBefore = treatmentStatusMapService.getOrdMainByOrdNo(ordNo);
      if (ordMainBefore == null) {
        UpdateScheduleListDataResponse bad = new UpdateScheduleListDataResponse();
        bad.setPROC_RESULT(IndScheduleServiceImpl.PROC_RESULT.ERROR.toString());
        bad.setMessage("治療情報が見つかりません。");
        return new ResponseEntity<>(bad, HttpStatus.BAD_REQUEST);
      }
      oldBedCd = getBedCd(ordMainBefore);
      long patId = ordMainBefore.getPatId() != null ? ordMainBefore.getPatId() : 0L;
      if (patId != 0L) {
        patIdListForJournal.add(patId);
      }
    } else if (op == StatusMapIndSchedule2Operation.SWAP) {
      ordNo1 = req.getOrdNo1();
      ordNo2 = req.getOrdNo2();
//      if (!ntssUser.isNkkAdminUser()) {
//        OrdMain checkOrdMain1 = ordMainService.selectByOrdNo(ordNo1);
//        OrdMain checkOrdMain2 = ordMainService.selectByOrdNo(ordNo2);
//        if ((checkOrdMain1 != null && checkOrdMain1.getFacilityCd() != null && !checkOrdMain1.getFacilityCd().equals(ntssUser.getFacilityCd()))
//          || (checkOrdMain2 != null && checkOrdMain2.getFacilityCd() != null && !checkOrdMain2.getFacilityCd().equals(ntssUser.getFacilityCd()))) {
//          if (InvestigateLogUtils.enable_log_for_11205) {
//            InvestigateLogUtils.info("11205", "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd(), "11205-FORBIDDEN");
//          } else {
//            return new ResponseEntity<>(HttpStatus.FORBIDDEN);
//          }
//        }
//      }
      ordMain1 = treatmentStatusMapService.getOrdMainByOrdNo(ordNo1);
      ordMain2 = treatmentStatusMapService.getOrdMainByOrdNo(ordNo2);
      if (ordMain1 == null || ordMain2 == null) {
        UpdateScheduleListDataResponse bad = new UpdateScheduleListDataResponse();
        bad.setPROC_RESULT(IndScheduleServiceImpl.PROC_RESULT.ERROR.toString());
        bad.setMessage("治療情報が見つかりません。");
        return new ResponseEntity<>(bad, HttpStatus.BAD_REQUEST);
      }
      facilityCd = ordMain1.getFacilityCd();
      long patId1 = ordMain1.getPatId() != null ? ordMain1.getPatId() : 0L;
      long patId2 = ordMain2.getPatId() != null ? ordMain2.getPatId() : 0L;
      if (patId1 != 0L) {
        patIdListForJournal.add(patId1);
      }
      if (patId2 != 0L && patId2 != patId1) {
        patIdListForJournal.add(patId2);
      }
    } else {
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }

    UpdateScheduleListDataResponse response = statusMapIndSchedule2Service.updateSchedule2(req);
    if (response == null
      || !IndScheduleServiceImpl.PROC_RESULT.SUCCESS.toString().equals(response.getPROC_RESULT())) {
      return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);
    }

    try {
      nextPatService.CallNextPatChange(facilityCd, response.getDoCallNextPatOrdMainList());
    } catch (Exception e) {
      eventLogMessage.setLogMessage("nextPatService.CallNextPatChange " + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_STATUS_MAP, SERVICE_NAME.FNSI, null);
    }

    if (op == StatusMapIndSchedule2Operation.MOVE) {
      if (!oldBedCd.equals(0L)) {
        treatmentStatusMapService.updateNextPatInfo(oldBedCd);
      }
      if (bedCd != null && !bedCd.equals(0L)) {
        treatmentStatusMapService.updateNextPatInfo(bedCd);
      }
    } else {
      Long ordMain1BedCd = getBedCd(ordMain1);
      Long ordMain2BedCd = getBedCd(ordMain2);
      if (!ordMain1BedCd.equals(0L)) {
        treatmentStatusMapService.updateNextPatInfo(ordMain1BedCd);
      }
      if (!ordMain2BedCd.equals(0L)) {
        treatmentStatusMapService.updateNextPatInfo(ordMain2BedCd);
      }
    }

    if (op == StatusMapIndSchedule2Operation.MOVE) {
      if (ordMainBefore.getRstDialysisState() != null) {
        switch (ordMainBefore.getRstDialysisState()) {
          case "0":
          case "1":
          case "2":
            scheduleListService.deleteOrdCheckListByOrdNo(ordNo, facilityCd);
            break;
          default:
            break;
        }
      }
      List<Long> ordNoList = new ArrayList<>();
      ordNoList.add(ordNo);
      ResponseEntity<String> retDummy = webApiCallCommonUtil.operateDummySchedule(
        ordNoList,
        bedCd,
        getKurCd(ordMainBefore),
        "1"
      );
      if (retDummy == null || HttpStatus.OK != retDummy.getStatusCode()) {
        logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
        response.setPROC_RESULT(IndScheduleServiceImpl.PROC_RESULT.ERROR.toString());
        response.setMessage("ダミースケジュール更新に失敗しました。");
        return new ResponseEntity<>(response, HttpStatus.INTERNAL_SERVER_ERROR);
      }
    } else {
      if (ordMain1.getRstDialysisState() != null) {
        switch (ordMain1.getRstDialysisState()) {
          case "0":
          case "1":
          case "2":
            scheduleListService.deleteOrdCheckListByOrdNo(ordNo1, facilityCd);
            break;
          default:
            break;
        }
      }
      if (ordMain2.getRstDialysisState() != null) {
        switch (ordMain2.getRstDialysisState()) {
          case "0":
          case "1":
          case "2":
            scheduleListService.deleteOrdCheckListByOrdNo(ordNo2, facilityCd);
            break;
          default:
            break;
        }
      }
      Long ordMain1BedCd = getBedCd(ordMain1);
      Long ordMain2BedCd = getBedCd(ordMain2);
      String opeMode = "3";
      List<Long> ordNoList1 = new ArrayList<>();
      ordNoList1.add(ordNo1);
      ResponseEntity<String> retDummy1 = webApiCallCommonUtil.operateDummySchedule(
        ordNoList1, ordMain1BedCd, getKurCd(ordMain2), opeMode);
      if (retDummy1 == null || HttpStatus.OK != retDummy1.getStatusCode()) {
        response.setPROC_RESULT(IndScheduleServiceImpl.PROC_RESULT.ERROR.toString());
        response.setMessage("DBの更新に失敗しました。");
        return new ResponseEntity<>(response, HttpStatus.INTERNAL_SERVER_ERROR);
      }
      List<Long> ordNoList2 = new ArrayList<>();
      ordNoList2.add(ordNo2);
      ResponseEntity<String> retDummy2 = webApiCallCommonUtil.operateDummySchedule(
        ordNoList2, ordMain1BedCd, getKurCd(ordMain1), opeMode);
      if (retDummy2 == null || HttpStatus.OK != retDummy2.getStatusCode()) {
        response.setPROC_RESULT(IndScheduleServiceImpl.PROC_RESULT.ERROR.toString());
        response.setMessage("DBの更新に失敗しました。");
        return new ResponseEntity<>(response, HttpStatus.INTERNAL_SERVER_ERROR);
      }
    }

    try {
      List<OrdMain> beforeOrds = extractOrdMainList(response.getResultAllChangeBeforeDataInfoList(), "ord_main");
      List<OrdMain> afterOrds = extractOrdMainList(response.getResultAllChangedDataInfoList(), "ord_main");
      List<IndHistory> indHistoryList = indScheduleService.createIndHistoryForIndSchedule(facilityCd, beforeOrds, afterOrds);
      if (indHistoryList != null && !indHistoryList.isEmpty()) {
        indHistoryMakeService.createHistoryExecuteBatch(indHistoryList, "2");
      }
    } catch (Exception e) {
      eventLogMessage.setLogMessage("指示履歴登録処理 MongoDB " + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_STATUS_MAP, SERVICE_NAME.FNSI, null);
    }

    try {
      String actionMode = "STATUS_MAP";
      Map<String, List<Object>> resultAllChangedDataInfoList = toObjectMap(response.getResultAllChangedDataInfoList());
      Map<String, List<Object>> resultAllChangeBeforeDataInfoList = toObjectMap(response.getResultAllChangeBeforeDataInfoList());
      List<JournalCreateRequestPayload> journalList = journalCreatePayloadService.createJournalPayload(
        facilityCd, resultAllChangedDataInfoList, resultAllChangeBeforeDataInfoList, patIdListForJournal, userId, actionMode);
      if (!CollectionUtils.isEmpty(journalList)) {
        journalService.callCreateJournalForCtrNo(journalList);
      }
    } catch (Exception e) {
      eventLogMessage.setLogMessage("連携関連呼出 " + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_SCHEDULE_LIST, SERVICE_NAME.FNSI, null);
    }

    return new ResponseEntity<>(response, HttpStatus.OK);
  }

  private static List<OrdMain> extractOrdMainList(Map<String, List<Object>> map, String key) {
    if (map == null) {
      return Collections.emptyList();
    }
    List<Object> raw = map.get(key);
    if (raw == null) {
      return Collections.emptyList();
    }
    List<OrdMain> out = new ArrayList<>();
    for (Object o : raw) {
      if (o instanceof OrdMain) {
        out.add((OrdMain) o);
      }
    }
    return out;
  }

  private static Map<String, List<Object>> toObjectMap(Map<String, List<Object>> src) {
    if (src == null || src.isEmpty()) {
      return new HashMap<>();
    }
    return new HashMap<>(src);
  }

  /**
   * ord_main取得
   * @param orderNo
   * @return
   */
  @GetMapping("/getOrdMainByOrdNo/{ordNo}")
  public ResponseEntity<OrdMain> getOrdMainByOrdNo(@PathVariable Long ordNo) {
    try {
      OrdMain ordMain = ordMainService.selectByOrdNo(ordNo);
      return new ResponseEntity<>(ordMain, HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  // add FNSI-7217 バッチ操作インターフェイスを追加します 查 start
  /**
   * ord_mainバッチ取得
   * @param orderNos
   * @return
   */
  @GetMapping("/getOrdMainListByOrdNo/{ordNos}")
  public ResponseEntity<List<OrdMain>> getOrdMainListByOrdNo(@PathVariable List<Long> ordNos) {
    try {
      List<OrdMain> ordMains = ordMainService.selectListByOrdNo(ordNos);
      return new ResponseEntity<>(ordMains, HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }
  // add FNSI-7217 バッチ操作インターフェイスを追加します 查 end


  /**
   * 条件送信後である
   * @param ordMain
   * @return
   */
  private boolean isSended(OrdMain ordMain) {
    if (ordMain.getRstDialysisState() == null ||
        ordMain.getRstDialysisState().isEmpty() ||
        ordMain.getRstDialysisState().equals("0")) {
      return false;
    } else {
      return true;
    }
  }

  /**
   * 治療状況に応じたベッドコードを取得
   * @param ordMain
   * @return
   */
  private Long getBedCd(OrdMain ordMain) {
    if (this.isSended(ordMain)) {
      // 実績
      return ordMain.getRstBedCd() != null ? ordMain.getRstBedCd().longValue() : 0L;
    } else {
      // 指示
      return ordMain.getIndBedCd() != null ? ordMain.getIndBedCd().longValue() : 0L;
    }
  }

  /**
   * 治療状況に応じたクールコードを取得
   * @param ordMain
   * @return
   */
  private Long getKurCd(OrdMain ordMain) {
    if (this.isSended(ordMain)) {
      // 実績
      return ordMain.getRstKurCd() != null ? ordMain.getRstKurCd().longValue() : 0L;
    } else {
      // 指示
      return ordMain.getIndKurCd() != null ? ordMain.getIndKurCd().longValue() : 0L;
    }

  }
}
