package jp.co.nikkiso.ntss.admin_web.web.rest;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Treatment;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.WebSocketTopic;
// #10457 2024.06.18 add デバイスエッジに通知タイミングで現患者クリアを実施 TDC高村 start
import jp.co.nikkiso.ntss.admin_web.request.deviceEdgeOrder.DeviceEdgeOrderRequest;
// #10457 2024.06.18 add デバイスエッジに通知タイミングで現患者クリアを実施 TDC高村 end
import jp.co.nikkiso.ntss.admin_web.request.patientCapture.JournalCreateRequestPayload;
import jp.co.nikkiso.ntss.admin_web.request.weight.PatExamPrintRequest;
import jp.co.nikkiso.ntss.admin_web.request.weight.SendConditionRequest;
// #10457 2024.06.18 add デバイスエッジに通知タイミングで現患者クリアを実施 TDC高村 start
import jp.co.nikkiso.ntss.admin_web.response.deviceEdgeOrder.DeviceEdgeOrderResponse;
// #10457 2024.06.18 add デバイスエッジに通知タイミングで現患者クリアを実施 TDC高村 end
import jp.co.nikkiso.ntss.admin_web.response.sendConditionCancel.SendConditionCancelResponse;
import jp.co.nikkiso.ntss.admin_web.response.weight.SendConditionCheckResponse;
import jp.co.nikkiso.ntss.admin_web.response.weight.SendConditionResponse;
import jp.co.nikkiso.ntss.admin_web.response.weight.WeightKurBedResponse;
import jp.co.nikkiso.ntss.admin_web.response.weight.WeightScheduleResponse;
import jp.co.nikkiso.ntss.admin_web.response.weight.WeighthistoryResponse;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.JournalService;
import jp.co.nikkiso.ntss.admin_web.service.autoPrint.AutoPrintService;
import jp.co.nikkiso.ntss.admin_web.service.autoPrint.AutoPrintService.AutoPrintResult;
import jp.co.nikkiso.ntss.admin_web.service.autoPrint.AutoPrintService.TimingEnum;
// #10457 2024.06.18 add デバイスエッジに通知タイミングで現患者クリアを実施 TDC高村 start
import jp.co.nikkiso.ntss.admin_web.service.deviceEdgeOrder.DeviceEdgeOrderService;
// #10457 2024.06.18 add デバイスエッジに通知タイミングで現患者クリアを実施 TDC高村 end
import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.sendConditionCancel.SendConditionCancelService;
import jp.co.nikkiso.ntss.admin_web.service.statusList.TreatmentStatusListService;
// del #11004 連携イベント発生部分不正 piao start
// import jp.co.nikkiso.ntss.admin_web.service.treatmentRecord.TreatmentRecordService;
// del #11004 連携イベント発生部分不正 piao end
import jp.co.nikkiso.ntss.admin_web.service.webSocketNotify.PayloadBuilder;
import jp.co.nikkiso.ntss.admin_web.service.webSocketNotify.WebSocketNotifyService;
import jp.co.nikkiso.ntss.admin_web.service.webSocketNotify.WebSocketNotifyService.SendTarget;
import jp.co.nikkiso.ntss.admin_web.service.weight.WeightService;
import jp.co.nikkiso.ntss.admin_web.service.weight.WeightService.MachineCurrentOrdDataSet;
import jp.co.nikkiso.ntss.admin_web.service.weight.state.ScaleBedStateService;
import jp.co.nikkiso.ntss.admin_web.web.rest.util.WebAPICheckConditionSend;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.SendCondition;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.rstDialysisState;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.MntMachineStateDao;
import jp.co.nikkiso.ntss.core.dao.MstBedDao;
import jp.co.nikkiso.ntss.core.dao.MstComsvSettingDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilitySettingDao;
import jp.co.nikkiso.ntss.core.dao.MstMachineDao;
import jp.co.nikkiso.ntss.core.dao.MstReportDao;
import jp.co.nikkiso.ntss.core.dao.MstTreatmentDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.entity.MntMachineState;
import jp.co.nikkiso.ntss.core.entity.MstBed;
import jp.co.nikkiso.ntss.core.entity.MstComsvSetting;
import jp.co.nikkiso.ntss.core.entity.MstMachine;
import jp.co.nikkiso.ntss.core.entity.MstReport;
import jp.co.nikkiso.ntss.core.entity.MstRoomBedGroup;
import jp.co.nikkiso.ntss.core.entity.MstTreatment;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.OrdWeightScale;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.custom.FacilitySettingInfo;
import jp.co.nikkiso.ntss.core.entity.custom.OrdWeightScaleBuildInfo;
import jp.co.nikkiso.ntss.core.entity.custom.PatExamMainWeightPrint;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.apache.commons.codec.digest.DigestUtils;
import org.json.JSONObject;
import org.seasar.doma.jdbc.UniqueConstraintException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.RequestEntity;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;

import java.net.URI;
import java.net.URISyntaxException;
import java.nio.charset.StandardCharsets;
// #10457 2024.06.18 add デバイスエッジに通知タイミングで現患者クリアを実施 TDC高村 start
import java.sql.Timestamp;
// #10457 2024.06.18 add デバイスエッジに通知タイミングで現患者クリアを実施 TDC高村 end
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Base64;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_ERROR;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import static jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils.toJson;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end

@RestController
@RequestMapping(Uri.WEIGHT)
public class WeightResource {

  @Autowired
  private WebSocketNotifyService sendWsMsg;
  @Autowired
  private WeightService weightService;
  @Autowired
  private SendConditionCancelService sendConditionCancelService;
  @Autowired
  private AutoPrintService autoPrintService;
  @Autowired
  WebAPICheckConditionSend webAPICheckConditionSend;
  @Autowired
  LogService logService;
  // add 2020-11/10 FNSI-改修内容:カード作成場合、カードIDの変更（pat_id⇒hosp_pat_id） 孫 start
  @Autowired
  private PatPersonalMainDao patPersonalMainDao;
  // add 2020-11/10 FNSI-改修内容:カード作成場合、カードIDの変更（pat_id⇒hosp_pat_id） 孫 end
  @Autowired
  private OrdMainDao ordMainDao;

  // #10833 2024.08.08 del static変数削除 TDC米沢 start
  // // add #7189 【デグレ】条件送信時、サーマルプリンターで印字されない 王永吉 start
  // public static String getWeightScaleNo = "";
  // // add #7189 【デグレ】条件送信時、サーマルプリンターで印字されない 王永吉 end
  // #10833 2024.08.08 del static変数削除 TDC米沢 end

  // add 8140 【デグレ】ベッドマスタにて自動印刷を「印刷しない」にしていた場合、印刷失敗通知が発生する 吉 start
  @Autowired
  private MstBedDao mstBedDao;
  // add 8140 【デグレ】ベッドマスタにて自動印刷を「印刷しない」にしていた場合、印刷失敗通知が発生する 吉 end
  /**
   * ObjectMapper.
   */
  @Autowired
  private ObjectMapper mapper;

  // add #10553 ④装置設定＞風袋・除水補正にて指示への展開保存をした場合には、変更された治療予定毎の連携イベントが必要 piao start
  @Autowired
  private JournalService journalService;
  // del #11004 連携イベント発生部分不正 piao start
  // @Autowired
  // TreatmentRecordService treatmentRecordService;
  // del #11004 連携イベント発生部分不正 piao end
  // add #10553 ④装置設定＞風袋・除水補正にて指示への展開保存をした場合には、変更された治療予定毎の連携イベントが必要 piao end

  // wp アプリケーションログの適正化 Add Start
  @Autowired
  LogEventUtils logEventUtils;
  // wp アプリケーションログの適正化 Add End
  // add #7660 2022/08/24 【デグレ】実績確定するまでの間は治療記録用紙に表示されない項目がある。 王永吉 start
  @Autowired
  TreatmentStatusListService treatmentStatusListService;
  // add #7660 2022/08/24 【デグレ】実績確定するまでの間は治療記録用紙に表示されない項目がある。 王永吉 end
  // add 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 start
  @Autowired
  private MstTreatmentDao mstTreatmentDao;
  @Autowired
  private MstReportDao mstReportDao;
  // add #9616 帳票印刷失敗通知がされない 高　start
  @Autowired
  private MstFacilitySettingDao mstFacilitySettingDao;
  // add #9616 帳票印刷失敗通知がされない 高　end
  // #10457 2024.06.18 add デバイスエッジに通知タイミングで現患者クリアを実施 TDC高村 start
  @Autowired
  private MstComsvSettingDao mstComsvSettingDao;
  @Autowired
  private MstMachineDao mstMachineDao;
  @Autowired
  private MntMachineStateDao mntMachineStateDao;
  @Autowired
  private DeviceEdgeOrderService deviceEdgeOrderService;
  // #10457 2024.06.18 add デバイスエッジに通知タイミングで現患者クリアを実施 TDC高村 end
  // #11987 2026.02.11 add スケールベッド状態書込み用 TDC片口 start
  @Autowired
  private ScaleBedStateService scaleBedStateService;
  // #11987 2026.02.11 add スケールベッド状態書込み用 TDC片口 end

  @Value("${ntss.admin-web.web-api.url}/util/notificationReciever")
  private String webApi;
  // add 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 end
//    del 8074 【デグレ】ログに誤った利用者が記録される 関 start
//  add 8074 【デグレ】ログに誤った利用者が記録される 関 start
//  @Autowired
//  OrdMainService ordMainService;
//  add 8074 【デグレ】ログに誤った利用者が記録される 関  end
//    del 8074 【デグレ】ログに誤った利用者が記録される 関  end
  @GetMapping("find_pat_id/{hospPatId}")
  public ResponseEntity<?> getPatId(
    @PathVariable String hospPatId,
    @AuthenticationPrincipal NtssUser ntssUser) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.WEIGHT + "/find_pat_id";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      hospPatId);
    // wp アプリケーションログの適正化 Add End

    Long res = weightService.getPatId(ntssUser.getFacilityCd(), hospPatId);

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      hospPatId);
    // wp アプリケーションログの適正化 Add End

    return new ResponseEntity<>(res, HttpStatus.OK);
  }


  // add FNSI-次回同じ患者を検索する場合測定値保存する 徐 start

  /**
   * 患者IDから患者体重測定値取得
   *
   * @param patId
   * @return
   */
  @GetMapping("find_measured_value/{patId}")
  public ResponseEntity<?> getMeasuredValue(
    @PathVariable Long patId,
    @AuthenticationPrincipal NtssUser ntssUser) {
    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.WEIGHT + "/find_measured_value";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      patId);
    // wp アプリケーションログの適正化 Add End

    double res = weightService.getMeasuredValue(ntssUser.getFacilityCd(), patId);
    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      patId);
    // wp アプリケーションログの適正化 Add End
    return new ResponseEntity<>(res, HttpStatus.OK);
  }
  // add FNSI-次回同じ患者を検索する場合測定値保存する 徐 end

  /**
   * 非体重計モード時の体重計選択可能フラグ取得用
   *
   * @param ntssUser
   * @return
   */
  @GetMapping("enable-weight-select")
  public ResponseEntity<?> fetchEnableWeightSelect(
    @AuthenticationPrincipal NtssUser ntssUser) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.WEIGHT + "/enable-weight-select";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    return new ResponseEntity<>(weightService.fetchEnableWeightSelect(ntssUser.getFacilityCd()), HttpStatus.OK);
  }

  /**
   * クールとベッドの一覧取得用
   *
   * @param excludeDialysisRoom 1：透析室(group_class = 2)を除外 / -1：全選択
   * @param ntssUser
   * @param facilityCd 施設コード
   * @return
   */
  @GetMapping("kur-bed-list/{excludeDialysisRoom}")
  public ResponseEntity<?> getKur(
    @PathVariable Short excludeDialysisRoom,
    @RequestParam(value = "facilityCd", required = false) String facilityCd,
    @AuthenticationPrincipal NtssUser ntssUser) {
    // 施設コードの指定なしの場合はユーザーの施設コードを使用
    // ※既存の動きに影響を与えないための保護措置
    if(org.apache.commons.lang3.StringUtils.isEmpty(facilityCd)) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("getKur : not facilityCd param, use ntssUser facilityCd");
      logService.log(LogLevel.INFO, eventLogMessage, "", SERVICE_NAME.FNSI, null);
      facilityCd = ntssUser.getFacilityCd();
    }
    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.WEIGHT + "/kur-bed-list/" + excludeDialysisRoom;
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    WeightKurBedResponse res = weightService.getKurBedSelector(facilityCd, excludeDialysisRoom.shortValue());
    res.isSuccess = true;


    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    return new ResponseEntity<>(res, HttpStatus.OK);
  }

  /**
   * ベッドグループ一覧取得用
   *
   * @param ntssUser
   * @return
   */
  @GetMapping("bed_group")
  public ResponseEntity<?> getBedGroup(
    @AuthenticationPrincipal NtssUser ntssUser) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.WEIGHT + "/bed_group";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End


    List<MstRoomBedGroup> res = weightService.getBedGroupList(ntssUser.getFacilityCd());

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    return new ResponseEntity<>(res, HttpStatus.OK);
  }

  /**
   * 患者選択画面用の患者スケジュール一覧取得
   *
   * @param treatDate 治療日
   * @param isPast    過去日フラグ
   * @return
   */
  @GetMapping("schedule/{treatDate}/{isPast}")
  public ResponseEntity<?> getSchedule(
    @PathVariable String treatDate,
    @PathVariable int isPast,
    @AuthenticationPrincipal NtssUser ntssUser) {
    // NOTE:選択するためのスケジュール取得

    // NOTE: 施設コード＋治療日かつis_del=0で版番号rst_editionがゼロのもの（治療未完了）で抽出
    // さらに同ベッドで複数件あった場合、クールの早いものを優先
    // ただし特殊浄化の場合は同クール複数件でも返送する

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.WEIGHT + "/schedule";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      isPast);
    // wp アプリケーションログの適正化 Add End

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      isPast);
    // wp アプリケーションログの適正化 Add End

    return new ResponseEntity<>(
      weightService.selectWeightSchedule(ntssUser.getFacilityCd(), null, treatDate, isPast > 0), HttpStatus.OK);
  }

  /**
   * 条件送信画面用の患者スケジュール取得
   *
   * @param treatDate 治療日
   * @param isPast    過去日フラグ
   * @param hospPatId 院内表示用の患者ID
   * @return
   */
  @GetMapping("schedule/{treatDate}/{isPast}/{hospPatId}")
  public ResponseEntity<?> getPatSchedule(
    @PathVariable String treatDate,
    @PathVariable int isPast,
    @PathVariable String hospPatId,
    @AuthenticationPrincipal NtssUser ntssUser) {
    // 患者スケジュール取得

    // NOTE: 施設コード＋治療日+患者IDかつis_del=0で版番号rst_editionがゼロのもの（治療未完了）で抽出
    // 複数件あった場合、クールの早いものを優先
    // 同クールで複数件あった場合、透析治療が2件以上あった場合はエラー？
    // 透析治療1件とと特殊浄化の組み合わせならば正常に送る

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.WEIGHT + "/schedule";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      isPast);
    // wp アプリケーションログの適正化 Add End

    List<WeightScheduleResponse> schedule = weightService.selectWeightSchedule(ntssUser.getFacilityCd(), hospPatId,
      treatDate, isPast > 0);

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      isPast);
    // wp アプリケーションログの適正化 Add End

    // その日のその患者のスケジュールを全部返す
    return new ResponseEntity<>(schedule, HttpStatus.OK);
  }

  /**
   * 条件送信画面用の指示取得
   *
   * @param ordNo
   * @return
   */
  @GetMapping("order/{ordNo}")
  public ResponseEntity<?> getOrder(
    @PathVariable Long ordNo) {
    // NOTE: ord_mainをord_noで取得する
    // 後体重の場合や透析中でも条件送信画面で表示できるので、指示だけや実績だけを返したりしない

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.WEIGHT + "/order";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      ordNo);
    // wp アプリケーションログの適正化 Add End

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      ordNo);
    // wp アプリケーションログの適正化 Add End

    return new ResponseEntity<>(weightService.buildOrderResponse(ordNo), HttpStatus.OK);
  }
  // add FNSI-分類不一致判断の追加 徐 start

  /**
   * 治療条件分類不一致判断
   *
   * @param ordNo
   * @param ordNos
   * @return
   */
  @GetMapping("order/check/{ordNo}/{ordNos}")
  public ResponseEntity<?> getChkIndCondInfoData(@PathVariable Long ordNo, @PathVariable Long ordNos) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.WEIGHT + "/order/check";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      ordNo);
    // wp アプリケーションログの適正化 Add End

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      ordNo);
    // wp アプリケーションログの適正化 Add End

    SendConditionCheckResponse response = new SendConditionCheckResponse();

    SendConditionCheckResponse res = weightService.getChkIndCondInfoData(ordNo, ordNos, false, false, false);

    response.msgList = res.msgList;
    response.indCondInfoNoLoginMsgList = res.indCondInfoNoLoginMsgList;
    response.indCondInfoTopLimitMsgList = res.indCondInfoTopLimitMsgList;
    response.indCondInfoUseIHDFMsgList = res.indCondInfoUseIHDFMsgList;
    response.indCondInfoLowerLimitMsgList = res.indCondInfoLowerLimitMsgList;
    response.indCondInfoUseAFBFMsgList = res.indCondInfoUseAFBFMsgList;
    response.indCondInfoUseSNMsgList = res.indCondInfoUseSNMsgList;
    response.naInjectionProgramFlg = res.naInjectionProgramFlg;
    response.singleNeedleFlg = res.singleNeedleFlg;
    response.tmpAutomaticTrackingFlg = res.tmpAutomaticTrackingFlg;
    response.deviceOptionsMsgList = res.deviceOptionsMsgList;
    response.isPurificationMsgFlg = res.isPurificationMsgFlg;
    response.replenishmentMsgFlg = res.replenishmentMsgFlg;
    response.replenishmentMsgFlg2 = res.replenishmentMsgFlg2;
    response.replenishmentMsgFlg3 = res.replenishmentMsgFlg3;
    // add FutreNetWeb+SI課題管理No7195 趙 start
    response.replenishmentMsgFlg4 = res.replenishmentMsgFlg4;
    // add FutreNetWeb+SI課題管理No7195 趙 end
    // add #7810 2022/11/20 BVUFCを使用する予定に除水プログラム使用するを展開する場合は警告。。 dou start
    response.diversionBvufcFlg = res.diversionBvufcFlg;
    // add #7810 2022/11/20 BVUFCを使用する予定に除水プログラム使用するを展開する場合は警告。。 dou end
    response.deviceModeMismatchMsgFlg = res.deviceModeMismatchMsgFlg;
    //add #11846 感染症不一致ロジック不正＆スケジュール表で不一致アイコンが点灯しない zrx start
    response.isPurificationWarnMsgFlg = res.isPurificationWarnMsgFlg;
    response.deviceModeUnknownMsgFlg = res.deviceModeUnknownMsgFlg;
    //add #11846 感染症不一致ロジック不正＆スケジュール表で不一致アイコンが点灯しない zrx end
    response.vaDirectionInconsistentMsgFlg = res.vaDirectionInconsistentMsgFlg;
    response.infectionNotConsistentMsgFlg = res.infectionNotConsistentMsgFlg;
    response.mstDelFlgMsgList = res.mstDelFlgMsgList;
    response.mstOverdueMsgList = res.mstOverdueMsgList;

    return new ResponseEntity<>(response, HttpStatus.OK);
  }
  // add FNSI-分類不一致判断の追加 徐 end

  /**
   * 条件送信画面用の指示（スケジュール無し）取得
   *
   * @param patId
   * @return
   */
  @GetMapping("no_order/{patId}")
  public ResponseEntity<?> getNoOrder(
    @AuthenticationPrincipal NtssUser ntssUser,
    @PathVariable Long patId) {
    // NOTE: ord_mainをpat_idで取得する
    // 後体重の場合や透析中でも条件送信画面で表示できるので、指示だけや実績だけを返したりしない

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.WEIGHT + "/no_order";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      patId);
    // wp アプリケーションログの適正化 Add End

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      patId);
    // wp アプリケーションログの適正化 Add End

    return new ResponseEntity<>(weightService.buildOrderResponseNoSchedule(patId, ntssUser.getFacilityCd()),
      HttpStatus.OK);
  }

  @GetMapping("no_pat_order")
  public ResponseEntity<?> getNoPatOrder(@AuthenticationPrincipal NtssUser ntssUser) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.WEIGHT + "/no_pat_order";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    return new ResponseEntity<>(weightService.buildOrderResponseNoPat(ntssUser.getFacilityCd()), HttpStatus.OK);
  }

  @GetMapping("last/history/{ordNo}/{scaleClass}")
  public ResponseEntity<?> lastWeightScale(@PathVariable Long ordNo, @PathVariable Short scaleClass) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.WEIGHT + "/last/history";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      ordNo);
    // wp アプリケーションログの適正化 Add End

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      ordNo);
    // wp アプリケーションログの適正化 Add End
    return new ResponseEntity<>(weightService.fetchLastWeightScale(ordNo, scaleClass), HttpStatus.OK);
  }

  @GetMapping("last/history/no_schedule/{patId}")
  public ResponseEntity<?> lastScaleNoSchedule(@PathVariable Long patId) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.WEIGHT + "/last/history/no_schedule";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      patId);
    // wp アプリケーションログの適正化 Add End

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      patId);
    // wp アプリケーションログの適正化 Add End
    return new ResponseEntity<>(weightService.fetchLastScaleNoSchedule(patId), HttpStatus.OK);
  }

  @GetMapping("target/history/{weightScaleNo}")
  public ResponseEntity<?> targetWeightScale(@PathVariable Long weightScaleNo) {
    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.WEIGHT + "/target/history";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      weightScaleNo);
    // wp アプリケーションログの適正化 Add End

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      weightScaleNo);
    // wp アプリケーションログの適正化 Add End

    return new ResponseEntity<>(weightService.fetchTargetWeightScale(weightScaleNo), HttpStatus.OK);
  }

  /**
   * 前回透析実績体重取得
   *
   * @param ordNo                     オーダーNo
   * @param previousWeightSourceClass 前回後体重取得カテゴリ
   * @return
   */
  @GetMapping("get_last_rst_weight/{ordNo}/{previousWeightSourceClass}")
  public ResponseEntity<?> getLastRstWeight(
    @PathVariable Long ordNo,
    @PathVariable Integer previousWeightSourceClass) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.WEIGHT + "/get_last_rst_weight";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      ordNo);
    // wp アプリケーションログの適正化 Add End


    try {


      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        ordNo);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(weightService.getLastWeightRecord(ordNo, previousWeightSourceClass), HttpStatus.OK);
    } catch (ParseException e) {
      // スケジュールの基準となる日付が取得できず、前回透析が特定不可
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>("", HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 前回透析実績体重取得（患者ベース）
   *
   * @param patId                     患者No
   * @param previousWeightSourceClass 前回後体重取得カテゴリ
   * @return
   */
  @GetMapping("get_last_rst_weight_pat/{patId}/{previousWeightSourceClass}")
  public ResponseEntity<?> getLastRstWeightPat(
    @PathVariable Long patId,
    @PathVariable Integer previousWeightSourceClass) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.WEIGHT + "/get_last_rst_weight_pat";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      patId);
    // wp アプリケーションログの適正化 Add End

    try {

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        patId);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(weightService.getLastWeightRecordPat(patId, previousWeightSourceClass),
        HttpStatus.OK);
    } catch (ParseException e) {
      // スケジュールの基準となる日付が取得できず、前回透析が特定不可
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>("", HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 指定日の透析実績体重取得（患者ベース）
   *
   * @param patId                     患者Id
   * @param previousWeightSourceClass 前回後体重取得カテゴリ
   * @param treatDate                 検索基準日
   * @return
   */
  @GetMapping("get_weight_by_treatdate/{patId}/{previousWeightSourceClass}/{treatDate}")
  public ResponseEntity<?> getWeightByTreatDate(
    @PathVariable Long patId,
    @PathVariable Integer previousWeightSourceClass,
    @PathVariable String treatDate) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.WEIGHT + "/get_weight_by_treatdate";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      patId);
    // wp アプリケーションログの適正化 Add End

    try {

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        patId);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(weightService.getWeightByTreatDate(patId, previousWeightSourceClass, treatDate),
        HttpStatus.OK);
    } catch (ParseException e) {
      // スケジュールの基準となる日付が取得できず、前回透析が特定不可
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>("", HttpStatus.BAD_REQUEST);
    }
  }

  /* #10443 ADD 測定日と同日の治療日の治療データから、測定タイミングと一致する体重を対象にデータ取得をする Start */
  /**
   * Find out weight's info at treatment by pat's id & treatDate & ordClass
   *
   * @param facilityCd
   * @param patId
   * @param ordClass
   * @param treatDate
   * @return
   */
  @GetMapping("/getWeightByTreatDateAndOrdClass/{facilityCd}/{patId}/{ordClass}/{treatDate}/{treatTime}")
  public ResponseEntity<?> getWeightByTreatDateAndOrdClass(
      @PathVariable String facilityCd,
      @PathVariable Long patId,
      @PathVariable String ordClass,
      @PathVariable String treatDate,
      @PathVariable String treatTime
    ){

    String mappingUrl = Uri.WEIGHT + "/getWeightByTreatDateAndOrdClass";
    logEventUtils.resourceLogOutput(
      getClassName()
      , getMethodName()
      , ""
      , AFTER_LOG_FLG_INFO
      , mappingUrl
      , facilityCd,
      patId
    );

    return new ResponseEntity<>(
      weightService.getNearestWeightRecordForPat(facilityCd, patId, ordClass, treatDate, treatTime),
      HttpStatus.OK);
  }
  /* #10443 ADD End */

  // add #10626 shiyw start
  /**
   * Batch get weight's info by pat's id for [データリスト]->[身体情報(追加登録)]
   * @param facilityCd
   * @param patIds
   * @return
   */
  @GetMapping("/getWeightByPatIds/{facilityCd}/{patIds}")
  public ResponseEntity<?> getWeightByPatIds(
    @PathVariable String facilityCd,
    @PathVariable String patIds
  ){
    String ordClass = "2"; // 検査タイミング「2：透析後」
    String treatDate = new SimpleDateFormat("yyyyMMdd").format(new Date());
    String mappingUrl = Uri.WEIGHT + "/getWeightByPatIds";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, facilityCd, patIds);
    Map<String,String> resultMap = new HashMap<>();
    List<String> patIdList = Arrays.stream(patIds.split(",")).toList();
    for (String patId : patIdList) {
      String weight = weightService.getNearestWeightRecordForPat(facilityCd, Long.valueOf(patId), ordClass, treatDate, "");
      if(StringUtils.hasText(weight)) {
        resultMap.put(patId,weight);
      }
    }
    return new ResponseEntity<>(resultMap,HttpStatus.OK);
  }
  // add #10626 shiyw end

  /**
   * 条件送信前の風袋更新
   *
   * @param request 治療情報（使用するのはord_noとind_tare_info）
   * @return
   */
  @PutMapping("order/update/tare")
  public ResponseEntity<?> updateTare(
    @RequestBody SendConditionRequest request
    // add #10553 ④装置設定＞風袋・除水補正にて指示への展開保存をした場合には、変更された治療予定毎の連携イベントが必要 piao start
    , @AuthenticationPrincipal NtssUser user
    // add #10553 ④装置設定＞風袋・除水補正にて指示への展開保存をした場合には、変更された治療予定毎の連携イベントが必要 piao end
  ) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.WEIGHT + "/order/update/tare";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    if (weightService.updateIndTare(request.getOrdNo(), request.getTare())) {

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      // add #10553 ④装置設定＞風袋・除水補正にて指示への展開保存をした場合には、変更された治療予定毎の連携イベントが必要 piao start
      OrdMain ordMain = ordMainDao.selectByOrdNo(request.getOrdNo());
      PatPersonalMain patPersonalMain = patPersonalMainDao.selectById(ordMain.getPatId());
      // del #11004 連携イベント発生部分不正 piao start
      // int modify_send_class = treatmentRecordService.getCoopIniSchModifySendClass(ordMain.getFacilityCd());
      // del #11004 連携イベント発生部分不正 piao end
      List<JournalCreateRequestPayload> ctlNoList = new ArrayList<>();
      JournalCreateRequestPayload payload = new JournalCreateRequestPayload();
      payload.setOpeCd("013013");
      payload.setCrud("U");
      // del #11004 連携イベント発生部分不正 piao start
      // if (modify_send_class == 2) {
      //   payload.setCrud("C");
      //   JournalCreateRequestPayload deljournalCreateRequestPayload = new JournalCreateRequestPayload();
      //   deljournalCreateRequestPayload.setFacilityCd(ordMain.getFacilityCd());
      //   deljournalCreateRequestPayload.setCrud("D");
      //   deljournalCreateRequestPayload.setHospPatId(patPersonalMain.getHosp_pat_id());
      //   deljournalCreateRequestPayload.setPatId(ordMain.getPatId());
      //   deljournalCreateRequestPayload.setUserId(user.getUserId());
      //   deljournalCreateRequestPayload.setOpeCd("013013");
      //   deljournalCreateRequestPayload.setOrdNo(ordMain.getOrdNo());
      //   deljournalCreateRequestPayload.setBaseDate(ordMain.getTreatDate());
      //   ctlNoList.add(deljournalCreateRequestPayload);
      // }
      // del #11004 連携イベント発生部分不正 piao end
      payload.setFacilityCd(ordMain.getFacilityCd());
      payload.setHospPatId(patPersonalMain.getHosp_pat_id());
      payload.setPatId(ordMain.getPatId());
      payload.setOrdNo(request.getOrdNo());
      payload.setBaseDate(ordMain.getTreatDate());
      payload.setUserId(user.getUserId());
      ctlNoList.add(payload);
      journalService.callCreateJournalForCtrNo(ctlNoList);
      // add #10553 ④装置設定＞風袋・除水補正にて指示への展開保存をした場合には、変更された治療予定毎の連携イベントが必要 piao end
      return new ResponseEntity<>(HttpStatus.OK);
    } else {
      SendConditionResponse res = new SendConditionResponse();
      res.errorMessage = "指示風袋データ書き込み失敗";

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 条件送信前の除水補正更新
   *
   * @param request 治療情報（使用するのはord_noとind_off_water_info）
   * @return
   */
  @PutMapping("order/update/off_water")
  public ResponseEntity<?> updateOffWater(
    @RequestBody SendConditionRequest request
    // add #10553 ④装置設定＞風袋・除水補正にて指示への展開保存をした場合には、変更された治療予定毎の連携イベントが必要 piao start
    , @AuthenticationPrincipal NtssUser user
    // add #10553 ④装置設定＞風袋・除水補正にて指示への展開保存をした場合には、変更された治療予定毎の連携イベントが必要 piao end
  ) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.WEIGHT + "/order/update/off_water";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    if (weightService.updateIndOffWater(request.getOrdNo(), request.getOffWater())) {

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      // add #10553 ④装置設定＞風袋・除水補正にて指示への展開保存をした場合には、変更された治療予定毎の連携イベントが必要 piao start
      OrdMain ordMain = ordMainDao.selectByOrdNo(request.getOrdNo());
      PatPersonalMain patPersonalMain = patPersonalMainDao.selectById(ordMain.getPatId());
      // del #11004 連携イベント発生部分不正 piao start
      // int modify_send_class = treatmentRecordService.getCoopIniSchModifySendClass(ordMain.getFacilityCd());
      // del #11004 連携イベント発生部分不正 piao end
      List<JournalCreateRequestPayload> ctlNoList = new ArrayList<>();
      JournalCreateRequestPayload payload = new JournalCreateRequestPayload();
      payload.setOpeCd("013014");
      payload.setCrud("U");
      // del #11004 連携イベント発生部分不正 piao start
      // if (modify_send_class == 2) {
      //   payload.setCrud("C");
      //   JournalCreateRequestPayload deljournalCreateRequestPayload = new JournalCreateRequestPayload();
      //   deljournalCreateRequestPayload.setFacilityCd(ordMain.getFacilityCd());
      //   deljournalCreateRequestPayload.setCrud("D");
      //   deljournalCreateRequestPayload.setHospPatId(patPersonalMain.getHosp_pat_id());
      //   deljournalCreateRequestPayload.setPatId(ordMain.getPatId());
      //   deljournalCreateRequestPayload.setUserId(user.getUserId());
      //   deljournalCreateRequestPayload.setOpeCd("013014");
      //   deljournalCreateRequestPayload.setOrdNo(ordMain.getOrdNo());
      //   deljournalCreateRequestPayload.setBaseDate(ordMain.getTreatDate());
      //   ctlNoList.add(deljournalCreateRequestPayload);
      // }
      // del #11004 連携イベント発生部分不正 piao end
      payload.setFacilityCd(ordMain.getFacilityCd());
      payload.setHospPatId(patPersonalMain.getHosp_pat_id());
      payload.setPatId(ordMain.getPatId());
      payload.setOrdNo(request.getOrdNo());
      payload.setBaseDate(ordMain.getTreatDate());
      payload.setUserId(user.getUserId());
      ctlNoList.add(payload);
      journalService.callCreateJournalForCtrNo(ctlNoList);
      // add #10553 ④装置設定＞風袋・除水補正にて指示への展開保存をした場合には、変更された治療予定毎の連携イベントが必要 piao end
      return new ResponseEntity<>(HttpStatus.OK);
    } else {
      SendConditionResponse res = new SendConditionResponse();
      res.errorMessage = "指示風袋データ書き込み失敗";

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 体重＋車いすの車いす重量未測定時処理
   *
   * @param request
   * @return
   */
  @PostMapping("/save_weight_and_chair")
  public ResponseEntity<?> postSaveWeightAndChair(@RequestBody SendConditionRequest request,
                                                  @AuthenticationPrincipal NtssUser ntssUser) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.WEIGHT + "/save_weight_and_chair";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    SendConditionResponse res = new SendConditionResponse();
    try {

      // 体重値、目標除水量等を\n治療予定「ord_main」に記録する
      // 体重測定履歴に測定履歴を\nステータス：送信待機で記録する
      request.setFacilityCd(ntssUser.getFacilityCd());
      OrdWeightScale scale = weightService.insertSendConditionWeightAndChair(request,
        SendCondition.WeightScaleClass.WAIT);
      if (scale == null) {
        res.errorMessage = "条件データ書き込み失敗";

        // wp アプリケーションログの適正化 Add Start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
          null);
        // wp アプリケーションログの適正化 Add End
        return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
      }
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.OK);

    } catch (UniqueConstraintException e) {
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      res.errorMessage = "データ書き込み失敗";

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
    } catch (Exception e) {
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }

  }

  /**
   * 先に車いすだけ重量測定時処理
   *
   * @param request
   * @return
   */
  @PostMapping("/save_chair")
  public ResponseEntity<?> postChair(@RequestBody SendConditionRequest request,
                                     @AuthenticationPrincipal NtssUser ntssUser) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.WEIGHT + "/save_chair";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    SendConditionResponse res = new SendConditionResponse();
    try {
      // 測定値が車いす重量と同等
      //del #12236 【因島】体重測定の動作不正 zrx start
//      request.setScaleValue(request.getWheelChairWeight());
      //del #12236 因島】体重測定の動作不正 zrx end
      // 体重測定履歴に測定履歴を\nステータス：送信待機で記録する
      request.setFacilityCd(ntssUser.getFacilityCd());
      OrdWeightScale scale = weightService.insertSendConditionChairInfo(request, SendCondition.WeightScaleClass.WAIT);
      if (scale == null) {
        res.errorMessage = "条件データ書き込み失敗";

        // wp アプリケーションログの適正化 Add Start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
          null);
        // wp アプリケーションログの適正化 Add End
        return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
      }

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.OK);

    } catch (UniqueConstraintException e) {
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      res.errorMessage = "データ書き込み失敗";
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End

      return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
    } catch (Exception e) {
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 条件送信を行う
   *
   * @param
   * @return
   */
  @PostMapping("/send_condition")
  public ResponseEntity<?> postSendCondition(
    @RequestBody SendConditionRequest request,
    @AuthenticationPrincipal NtssUser ntssUser) {

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("条件送信処理開始 facilityCd:[" + ntssUser.getFacilityCd() + "] patId:[" + request.getPatId() + "] ordNo[" + request.getOrdNo() + "]");
    eventLogMessage.setPatId(String.valueOf(request.getPatId()));
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);

    SendConditionResponse res = new SendConditionResponse();
    try {

      // 体重測定履歴に測定履歴を\nステータス：測定済みで記録する
      request.setFacilityCd(ntssUser.getFacilityCd());
      // #10833 2024.08.08 del static変数削除 TDC米沢 start
      // // add #7189 【デグレ】条件送信時、サーマルプリンターで印字されない 王永吉 start
      // // 送信処理時測定済みで記録番号取得
      // // mod #7189 【デグレ】条件送信時、サーマルプリンターで印字されない 王永吉 start
      // // weightScaleNo = request.getWeightScaleNo().toString();
      // // add #7189 【デグレ】条件送信時、サーマルプリンターで印字されない 王永吉 start
      // boolean getWeightScaleNoFalg = true;
      // // add #7189 【デグレ】条件送信時、サーマルプリンターで印字されない 王永吉 end
      // if (request.getWeightScaleNo() != null ){
      //   getWeightScaleNo = request.getWeightScaleNo().toString();
      //   // add #7189 【デグレ】条件送信時、サーマルプリンターで印字されない 王永吉 start
      //   getWeightScaleNoFalg = false;
      //   // add #7189 【デグレ】条件送信時、サーマルプリンターで印字されない 王永吉 end
      // }
      // // mod #7189 【デグレ】条件送信時、サーマルプリンターで印字されない 王永吉 end
      // // add #7189 【デグレ】条件送信時、サーマルプリンターで印字されない 王永吉 end
      // #10833 2024.08.08 del static変数削除 TDC米沢 end
      res = weightService.saveSendConditionOrdWeightScale(request, SendCondition.WeightScaleClass.MEASURED);
      if (res.isSuccess == false) {
        eventLogMessage.setLogMessage("条件送信処理失敗 facilityCd:[" + ntssUser.getFacilityCd() + "] patId:[" + request.getPatId() + "] ordNo[" + request.getOrdNo() + "]" + res.errorMessage);
        eventLogMessage.setPatId(String.valueOf(request.getPatId()));
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
      }
      Long weightScaleNo = res.printWeightScaleNo;
      // #11987 2026.02.11 add スケールベッド状態書込み用 TDC片口 start
      request.setWeightScaleNo(weightScaleNo);
      // #11987 2026.02.11 add スケールベッド状態書込み用 TDC片口 end
      // #10833 2024.08.08 del static変数削除 TDC米沢 start
      // // add #7189 【デグレ】条件送信時、サーマルプリンターで印字されない 王永吉 start
      // if (getWeightScaleNoFalg){
      //   getWeightScaleNo = res.printWeightScaleNo.toString();
      // }
      // // add #7189 【デグレ】条件送信時、サーマルプリンターで印字されない 王永吉 end
      // #10833 2024.08.08 del static変数削除 TDC米沢 end
      // add FNSI-条件送信がエラーの場合はord_mainに更新を行わないこと 徐 start
      String weightInfo = null;
      String tareInfo = null;
      String offWaterInfo = null;
      String dw = null;
      // add #7641 自動印刷で値が入らない項目がある 鄭爽 start
      String rstDialysisStateBefore = null;
      // add #7641 自動印刷で値が入らない項目がある 鄭爽 end
      OrdMain ordMainAll = ordMainDao.selectByOrdNo(request.getOrdNo());
      if (ordMainAll != null) {
        weightInfo = ordMainAll.getRstWeightInfo();
        tareInfo = ordMainAll.getRstTareInfo();
        offWaterInfo = ordMainAll.getRstOffWaterInfo();
        if (ordMainAll.getRstDw() != null) {
          dw = String.valueOf(ordMainAll.getRstDw());
        }
        // add #7641 自動印刷で値が入らない項目がある 鄭爽 start
        rstDialysisStateBefore = ordMainAll.getRstDialysisState();
        // add #7641 自動印刷で値が入らない項目がある 鄭爽 end
        // del #9914 補液計算優先項目を「濾過率から算出」に設定した時の補液速度と補液量の表示が不正 dengshen start
        // JSONObject indCondInfo = new JSONObject(ordMainAll.getIndCondInfo());
        // if (indCondInfo.has("20") || indCondInfo.has("24")) {
        //   String value20 = null;
        //   String value24 = null;
        //   if (indCondInfo.has("20")) {
        //     value20 = indCondInfo.getJSONObject("20").get("value").toString();
        //   }
        //   if (indCondInfo.has("24")) {
        //     value24 = indCondInfo.getJSONObject("24").get("value").toString();
        //   }
        //   if ("-1".equals(value20) || "-1".equals(value24)) {
        //     if ("-1".equals(value20)) {
        //
        //       // Mod #9973 By Tao.zhou fix the type of JSON value node. Start Since 2023-10-27
        //       // JSONObject jsonObject1 = indCondInfo.getJSONObject("20").put("value", 0);
        //       JSONObject jsonObject1 = indCondInfo.getJSONObject(TreatmentItemsDef.T_I_IV_AMOUNT.getItemCode())
        //         .put("value", TreatmentItemsDef.T_I_IV_AMOUNT.getDefaultValue());
        //       // Mod #9973 By Tao.zhou fix the type of JSON value node. End Since 2023-10-27
        //
        //       indCondInfo.put("20", jsonObject1);
        //     }
        //     if ("-1".equals(value24)) {
        //
        //       // Mod #9973 By Tao.zhou fix the type of JSON value node. Start Since 2023-10-27
        //       // JSONObject jsonObject2 = indCondInfo.getJSONObject("24").put("value", 0);
        //       JSONObject jsonObject2 = indCondInfo.getJSONObject(TreatmentItemsDef.T_I_IV_FLOW_RATE.getItemCode())
        //         .put("value", TreatmentItemsDef.T_I_IV_FLOW_RATE.getDefaultValue());
        //       // Mod #9973 By Tao.zhou fix the type of JSON value node. End Since 2023-10-27
        //
        //       indCondInfo.put("24", jsonObject2);
        //     }
        //     ordMainDao.updateIndCondInfo(request.getOrdNo(), indCondInfo.toString());
        //   }
        // }
        // del #9914 補液計算優先項目を「濾過率から算出」に設定した時の補液速度と補液量の表示が不正 dengshen end
        // add #7194 OHDF・OHFで濾過率から算出に設定すると補液速度と補液量が不適切 dou end
      }
      // add FNSI-条件送信がエラーの場合はord_mainに更新を行わないこと 徐 end

      //del #10775 前体重測定を2度おこなうと前体重測定データが壊れる start
      // 体重値、目標除水量等を\n治療予定「ord_main」に記録する
//      SendConditionResponse res2 = weightService.saveBeforeWeight(request);
//      if (res2.isSuccess == false) {
//        weightService.updateOrdWeightStatus(
//          weightScaleNo,
//          SendCondition.WeightScaleClass.SEND_NG,
//          res2.errorMessage);
//        eventLogMessage.setLogMessage("条件送信処理失敗 facilityCd:[" + ntssUser.getFacilityCd() + "] patId:[" + request.getPatId() + "] ordNo[" + request.getOrdNo() + "]" + res2.errorMessage);
//        eventLogMessage.setPatId(String.valueOf(request.getPatId()));
//        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
//        // add FNSI-条件送信がエラーの場合はord_mainに更新を行わないこと 徐 start
//        ordMainDao.updateBeforeWeight(request.getOrdNo(), weightInfo, offWaterInfo, tareInfo,null, dw);
//        // add FNSI-条件送信がエラーの場合はord_mainに更新を行わないこと 徐 end
//        return new ResponseEntity<>(res2, HttpStatus.BAD_REQUEST);
//      }
      //del #10775 前体重測定を2度おこなうと前体重測定データが壊れる end

      if (request.getOrdNo() == null) {
        // スケジュール無し患者の場合は条件送信しない
        res.isSuccess = true;
        // #10833 2024.08.08 mod 体重測定番号をセットする TDC米沢 start
        // res.weightScaleNo = null;
        res.weightScaleNo = weightScaleNo;
        // #10833 2024.08.08 mod 体重測定番号をセットする TDC米沢 end
        eventLogMessage.setLogMessage("スケジュール無し facilityCd:[" + ntssUser.getFacilityCd() + "] patId:[" + request.getPatId() + "] ordNo[" + request.getOrdNo() + "]");
        eventLogMessage.setPatId(String.valueOf(request.getPatId()));
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        return new ResponseEntity<>(res, HttpStatus.OK);
      }

      // 特殊浄化フラグ
      boolean isPurification = Objects.equals(request.getDeviceMode(), Treatment.DeviceMode.PURIFICATION);
      try {

        MachineCurrentOrdDataSet machineResp = weightService.findMachineStateByBed(request.getFacilityCd(),
          request.getBedCd());
        // add FNSI-通信種別がオフライン運用com_type = 0 徐 start
        // if (!isPurification) {
        if (!isPurification && machineResp.machine.getComType() != 0) {
          // add FNSI-通信種別がオフライン運用com_type = 0 徐 end
          // 特殊浄化の場合は装置通信状態のチェックを行わない

          switch (weightService.validationMachineStateCanSend(machineResp)) {
            case connectError:
              // 装置通信エラーならば条件送信不可
              weightService.updateOrdWeightStatus(
                weightScaleNo,
                SendCondition.WeightScaleClass.SEND_NG,
                "装置通信不良");
              res.isSuccess = false;
              res.errorMessage = "装置通信不良";
              eventLogMessage.setLogMessage("装置通信不良 facilityCd:[" + ntssUser.getFacilityCd() + "]," + "");
              eventLogMessage.setPatId(String.valueOf(request.getPatId()));
              logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
              // add FNSI-条件送信がエラーの場合はord_mainに更新を行わないこと 徐 start
              ordMainDao.updateBeforeWeight(request.getOrdNo(), weightInfo, offWaterInfo, tareInfo,null, dw);
              // add FNSI-条件送信がエラーの場合はord_mainに更新を行わないこと 徐 end
              // #11987 2026.02.11 add スケールベッド状態書込み用 TDC片口 start
              scaleBedStateService.updateSendStatusError(request.getScaleBedBedCd(), true, weightScaleNo);
              // #11987 2026.02.11 add スケールベッド状態書込み用 TDC片口 end

              return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
            case treating:
              // 装置治療中ならば条件送信不可
              weightService.updateOrdWeightStatus(
                weightScaleNo,
                SendCondition.WeightScaleClass.SEND_NG,
                "装置治療中");
              res.isSuccess = false;
              res.errorMessage = "装置が治療中です";
              eventLogMessage.setLogMessage("装置が治療中です facilityCd:[" + ntssUser.getFacilityCd() + "]," + "");
              eventLogMessage.setPatId(String.valueOf(request.getPatId()));
              logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
              // add FNSI-条件送信がエラーの場合はord_mainに更新を行わないこと 徐 start
              ordMainDao.updateBeforeWeight(request.getOrdNo(), weightInfo, offWaterInfo, tareInfo,null, dw);
              // add FNSI-条件送信がエラーの場合はord_mainに更新を行わないこと 徐 end
              // #11987 2026.02.11 add スケールベッド状態書込み用 TDC片口 start
              scaleBedStateService.updateSendStatusError(request.getScaleBedBedCd(), true, weightScaleNo);
              // #11987 2026.02.11 add スケールベッド状態書込み用 TDC片口 end

              return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
            default:
              break;
          }
        }
        switch (weightService.validationCurrentOrdTargetAction(machineResp.targetMachineCurrentOrdNo)) {
          case clearCurrentOrd:
            // 治療が終わっている場合は現患者クリアする
            SendConditionCancelResponse cpcRes = sendConditionCancelService.currentPatClear(ntssUser.getFacilityCd(),
              machineResp.machine.getMachineTypeCd(), machineResp.machine.getMachineSerial());
            if (!cpcRes.isSuccess) {
              eventLogMessage.setLogMessage("現患者クリア失敗 facilityCd:[" + ntssUser.getFacilityCd() + "] machineTypeCd[" + machineResp.machine.getMachineTypeCd() + "] machineSerial[" +
                machineResp.machine.getMachineSerial() + "]" + cpcRes.exMessage);
              eventLogMessage.setPatId(String.valueOf(request.getPatId()));
              eventLogMessage.setMachineTypeCd(machineResp.machine.getMachineTypeCd());
              logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);

              res.errorMessage = "現患者クリア失敗";
              weightService.updateOrdWeightStatus(
                weightScaleNo,
                SendCondition.WeightScaleClass.SEND_NG,
                cpcRes.errorMessage);
              res.isSuccess = false;
              res.errorMessage = cpcRes.errorMessage;
              // add FNSI-条件送信がエラーの場合はord_mainに更新を行わないこと 徐 start
              ordMainDao.updateBeforeWeight(request.getOrdNo(), weightInfo, offWaterInfo, tareInfo,null, dw);
              // add FNSI-条件送信がエラーの場合はord_mainに更新を行わないこと 徐 end
              // #11987 2026.02.11 add スケールベッド状態書込み用 TDC片口 start
              scaleBedStateService.updateSendStatusError(request.getScaleBedBedCd(), true, weightScaleNo);
              // #11987 2026.02.11 add スケールベッド状態書込み用 TDC片口 end

              return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
            }
            break;
          case dialysis:
            // add #7147 2022-09-02 【デグレ】条件送信ができない。 dou start
            OrdMain machineOrdMain = ordMainDao.selectByOrdNo(machineResp.targetMachineCurrentOrdNo);
			//mod 8347【デグレ】????患者治療割り当てができない zhao start
            //Integer rstBedCd = machineOrdMain.getRstBedCd();
            Integer rstBedCd = machineOrdMain.getRstBedCd().intValue();
			//mod 8347【デグレ】????患者治療割り当てができない zhao end
            if (rstBedCd == null || request.getBedCd().intValue() == rstBedCd) {
              // add #7147 2022-09-02 【デグレ】条件送信ができない。 dou end
              // 治療中ならば条件送信不可
              weightService.updateOrdWeightStatus(
                weightScaleNo,
                SendCondition.WeightScaleClass.SEND_NG,
                "治療中の患者がいます");
              res.isSuccess = false;
              res.errorMessage = "治療中の患者がいます";
              eventLogMessage.setLogMessage("治療中の患者がいます facilityCd:[" + ntssUser.getFacilityCd() + "] machineTypeCd[" + machineResp.machine.getMachineTypeCd() + "] machineSerial[" +
                machineResp.machine.getMachineSerial() + "]");
              eventLogMessage.setPatId(String.valueOf(request.getPatId()));
              eventLogMessage.setMachineTypeCd(machineResp.machine.getMachineTypeCd());
              logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
              // add FNSI-条件送信がエラーの場合はord_mainに更新を行わないこと 徐 start
              ordMainDao.updateBeforeWeight(request.getOrdNo(), weightInfo, offWaterInfo, tareInfo,null, dw);
              // add FNSI-条件送信がエラーの場合はord_mainに更新を行わないこと 徐 end
              // #11987 2026.02.11 add スケールベッド状態書込み用 TDC片口 start
              scaleBedStateService.updateSendStatusError(request.getScaleBedBedCd(), true, weightScaleNo);
              // #11987 2026.02.11 add スケールベッド状態書込み用 TDC片口 end

              return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
              // add #7147 2022-09-02 【デグレ】条件送信ができない。 dou start
            }
            break;
          // add #7147 2022-09-02 【デグレ】条件送信ができない。 dou end
          case doCancel:
            // 条件送信キャンセルが必要ならば実行する
            //mod #10412 次患者更新関連全体見直し対応 朴 start
//            SendConditionCancelResponse sccRes = sendConditionCancelService.doCancel(ntssUser.getFacilityCd(),
//              request.getBedCd(), request.getOrdNo());
            SendConditionCancelResponse sccRes = sendConditionCancelService.doCancel2(ntssUser.getFacilityCd(), request.getBedCd(), request.getOrdNo());
            //mod #10412 次患者更新関連全体見直し対応 朴 end
            if (!sccRes.isSuccess) {
              eventLogMessage.setLogMessage("条件送信キャンセル失敗 facilityCd:[" + ntssUser.getFacilityCd() + "] machineTypeCd[" + machineResp.machine.getMachineTypeCd() + "] machineSerial[" +
                machineResp.machine.getMachineSerial() + "]" + sccRes.exMessage);
              eventLogMessage.setPatId(String.valueOf(request.getPatId()));
              eventLogMessage.setMachineTypeCd(machineResp.machine.getMachineTypeCd());
              logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);

              weightService.updateOrdWeightStatus(
                weightScaleNo,
                SendCondition.WeightScaleClass.SEND_NG,
                sccRes.errorMessage);
              res.isSuccess = false;
              res.errorMessage = sccRes.errorMessage;
              // add FNSI-条件送信がエラーの場合はord_mainに更新を行わないこと 徐 start
              ordMainDao.updateBeforeWeight(request.getOrdNo(), weightInfo, offWaterInfo, tareInfo,null, dw);
              // add FNSI-条件送信がエラーの場合はord_mainに更新を行わないこと 徐 end
              // #11987 2026.02.11 add スケールベッド状態書込み用 TDC片口 start
              scaleBedStateService.updateSendStatusError(request.getScaleBedBedCd(), true, weightScaleNo);
              // #11987 2026.02.11 add スケールベッド状態書込み用 TDC片口 end

              return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
            }
            break;
          default:
            break;
        }
        // 装置の次患者情報が異なるオーダーの場合は差し替える
        if (!Objects.equals(machineResp.targetMachineNextOrdNo, request.getOrdNo())) {
          weightService.updateMachineNextOrdInfo(machineResp.machine, request.getOrdNo());
          // TODO: 通信サーバーへの装置次患者通知が必要か？
        }

      } catch (Exception e) {
        eventLogMessage.setLogMessage("条件送信可否チェックエラー " + e.getMessage());
        logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
        res.errorMessage = "装置状態チェックエラー";
        weightService.updateOrdWeightStatus(
          weightScaleNo,
          SendCondition.WeightScaleClass.SEND_NG,
          "装置状態条件送信可否チェックエラー");
        // add FNSI-条件送信がエラーの場合はord_mainに更新を行わないこと 徐 start
        ordMainDao.updateBeforeWeight(request.getOrdNo(), weightInfo, offWaterInfo, tareInfo,null, dw);
        // add FNSI-条件送信がエラーの場合はord_mainに更新を行わないこと 徐 end
        // #11987 2026.02.11 add スケールベッド状態書込み用 TDC片口 start
        scaleBedStateService.updateSendStatusError(request.getScaleBedBedCd(), true, weightScaleNo);
        // #11987 2026.02.11 add スケールベッド状態書込み用 TDC片口 end

        return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
      }

      //add #10775 前体重測定を2度おこなうと前体重測定データが壊れる start
      SendConditionResponse res2 = weightService.saveBeforeWeight(request);
      if (res2.isSuccess == false) {
        weightService.updateOrdWeightStatus(
          weightScaleNo,
          SendCondition.WeightScaleClass.SEND_NG,
          res2.errorMessage);
        eventLogMessage.setLogMessage("条件送信処理失敗 facilityCd:[" + ntssUser.getFacilityCd() + "] patId:[" + request.getPatId() + "] ordNo[" + request.getOrdNo() + "]" + res2.errorMessage);
        eventLogMessage.setPatId(String.valueOf(request.getPatId()));
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        // add FNSI-条件送信がエラーの場合はord_mainに更新を行わないこと 徐 start
        ordMainDao.updateBeforeWeight(request.getOrdNo(), weightInfo, offWaterInfo, tareInfo,null, dw);
        // add FNSI-条件送信がエラーの場合はord_mainに更新を行わないこと 徐 end
        // #11987 2026.02.11 add スケールベッド状態書込み用 TDC片口 start
        scaleBedStateService.updateSendStatusError(request.getScaleBedBedCd(), true, weightScaleNo);
        // #11987 2026.02.11 add スケールベッド状態書込み用 TDC片口 end

        return new ResponseEntity<>(res2, HttpStatus.BAD_REQUEST);
      }
      //add #10775 前体重測定を2度おこなうと前体重測定データが壊れる end

      // 条件送信データ生成依頼
      try {
        // add FNSI-分類不一致判断の追加 徐 start
        SendConditionCheckResponse resCheck = weightService.getChkIndCondInfoData(request.getOrdNo(), 0L, request.getChkIndCondInfoFlg(), request.getMstDelFlg(), request.getMstOverdueFlg());
        if (resCheck != null) {
          // del #9356 体重測定画面への遷移時と送信ボタン押下時のポップアップ内容の相違 dengshen start
          // // マスタ削除特殊MsgList
          // if (resCheck.mstDelSpecialMsgList.size() > 0) {

          //   res.isSuccess = false;
          //   res.mstDelSpecialMsgList = resCheck.mstDelSpecialMsgList;
          //   // add FNSI-条件送信がエラーの場合はord_mainに更新を行わないこと 徐 start
          //   ordMainDao.updateBeforeWeight(request.getOrdNo(), weightInfo, offWaterInfo, tareInfo,null, dw);
          //   // add FNSI-条件送信がエラーの場合はord_mainに更新を行わないこと 徐 end

          //   return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
          // }
          // del #9356 体重測定画面への遷移時と送信ボタン押下時のポップアップ内容の相違 dengshen start
          // マスタ削除MsgList
          if (resCheck.mstDelFlgMsgList.size() > 0) {

            res.isSuccess = false;
            res.mstDelFlgMsgList = resCheck.mstDelFlgMsgList;
            // add FNSI-条件送信がエラーの場合はord_mainに更新を行わないこと 徐 start
            ordMainDao.updateBeforeWeight(request.getOrdNo(), weightInfo, offWaterInfo, tareInfo,null, dw);
            // add FNSI-条件送信がエラーの場合はord_mainに更新を行わないこと 徐 end
            // #11987 2026.02.11 add スケールベッド状態書込み用 TDC片口 start
            scaleBedStateService.updateSendStatusError(request.getScaleBedBedCd(), true, weightScaleNo);
            // #11987 2026.02.11 add スケールベッド状態書込み用 TDC片口 end

            return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
          }
          // マスタ期限切れMsgList
          if (resCheck.mstOverdueMsgList.size() > 0) {

            res.isSuccess = false;
            res.mstOverdueMsgList = resCheck.mstOverdueMsgList;
            // add FNSI-条件送信がエラーの場合はord_mainに更新を行わないこと 徐 start
            ordMainDao.updateBeforeWeight(request.getOrdNo(), weightInfo, offWaterInfo, tareInfo,null, dw);
            // add FNSI-条件送信がエラーの場合はord_mainに更新を行わないこと 徐 end
            // #11987 2026.02.11 add スケールベッド状態書込み用 TDC片口 start
            scaleBedStateService.updateSendStatusError(request.getScaleBedBedCd(), true, weightScaleNo);
            // #11987 2026.02.11 add スケールベッド状態書込み用 TDC片口 end

            return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
          }

          // 治療条件分類不一致MsgList
          if (resCheck.msgList.size() > 0) {

            res.isSuccess = false;
            res.errorMessagelist = resCheck.msgList;
            // add FNSI-条件送信がエラーの場合はord_mainに更新を行わないこと 徐 start
            ordMainDao.updateBeforeWeight(request.getOrdNo(), weightInfo, offWaterInfo, tareInfo,null, dw);
            // add FNSI-条件送信がエラーの場合はord_mainに更新を行わないこと 徐 end
            // #11987 2026.02.11 add スケールベッド状態書込み用 TDC片口 start
            scaleBedStateService.updateSendStatusError(request.getScaleBedBedCd(), true, weightScaleNo);
            // #11987 2026.02.11 add スケールベッド状態書込み用 TDC片口 end

            return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
          }
          // 治療条件未登録MsgList
          if (resCheck.indCondInfoNoLoginMsgList.size() > 0) {

            res.isSuccess = false;
            res.indCondInfoNoLoginMsgList = resCheck.indCondInfoNoLoginMsgList;

            String errorMessage = "";
            for (int i = 0; i < resCheck.indCondInfoNoLoginMsgList.size(); i++) {
              if (i == resCheck.indCondInfoNoLoginMsgList.size() - 1) {
                errorMessage = errorMessage + resCheck.indCondInfoNoLoginMsgList.get(i) + "が未登録のため条件送信できません。";
              } else {
                errorMessage = errorMessage + resCheck.indCondInfoNoLoginMsgList.get(i) + "、";
              }
            }

            weightService.updateOrdWeightStatus(
              weightScaleNo,
              SendCondition.WeightScaleClass.SEND_NG,
              errorMessage);
            // add FNSI-条件送信がエラーの場合はord_mainに更新を行わないこと 徐 start
            ordMainDao.updateBeforeWeight(request.getOrdNo(), weightInfo, offWaterInfo, tareInfo,null, dw);
            // add FNSI-条件送信がエラーの場合はord_mainに更新を行わないこと 徐 end
            // #11987 2026.02.11 add スケールベッド状態書込み用 TDC片口 start
            scaleBedStateService.updateSendStatusError(request.getScaleBedBedCd(), true, weightScaleNo);
            // #11987 2026.02.11 add スケールベッド状態書込み用 TDC片口 end

            return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
          }
          // 治療条件上限MsgList
          if (resCheck.indCondInfoTopLimitMsgList.size() > 0) {

            res.isSuccess = false;
            res.indCondInfoTopLimitMsgList = resCheck.indCondInfoTopLimitMsgList;

            String errorMessage = "";
            for (int i = 0; i < resCheck.indCondInfoTopLimitMsgList.size(); i++) {
              if (i == resCheck.indCondInfoTopLimitMsgList.size() - 1) {
                errorMessage = errorMessage + resCheck.indCondInfoTopLimitMsgList.get(i) + "が上限を超えているため条件送信できません。";
              } else {
                errorMessage = errorMessage + resCheck.indCondInfoTopLimitMsgList.get(i) + "、";
              }
            }

            weightService.updateOrdWeightStatus(
              weightScaleNo,
              SendCondition.WeightScaleClass.SEND_NG,
              errorMessage);
            // add FNSI-条件送信がエラーの場合はord_mainに更新を行わないこと 徐 start
            ordMainDao.updateBeforeWeight(request.getOrdNo(), weightInfo, offWaterInfo, tareInfo,null, dw);
            // add FNSI-条件送信がエラーの場合はord_mainに更新を行わないこと 徐 end
            // #11987 2026.02.11 add スケールベッド状態書込み用 TDC片口 start
            scaleBedStateService.updateSendStatusError(request.getScaleBedBedCd(), true, weightScaleNo);
            // #11987 2026.02.11 add スケールベッド状態書込み用 TDC片口 end

            return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
          }
          // 治療条件下限MsgList
          if (resCheck.indCondInfoLowerLimitMsgList.size() > 0) {

            res.isSuccess = false;
            res.indCondInfoLowerLimitMsgList = resCheck.indCondInfoLowerLimitMsgList;

            String errorMessage = "";
            for (int i = 0; i < resCheck.indCondInfoLowerLimitMsgList.size(); i++) {
              if (i == resCheck.indCondInfoLowerLimitMsgList.size() - 1) {
                errorMessage = errorMessage + resCheck.indCondInfoLowerLimitMsgList.get(i) + "が下限を下回っているため条件送信できません。";
              } else {
                errorMessage = errorMessage + resCheck.indCondInfoLowerLimitMsgList.get(i) + "、";
              }
            }

            weightService.updateOrdWeightStatus(
              weightScaleNo,
              SendCondition.WeightScaleClass.SEND_NG,
              errorMessage);
            // add FNSI-条件送信がエラーの場合はord_mainに更新を行わないこと 徐 start
            ordMainDao.updateBeforeWeight(request.getOrdNo(), weightInfo, offWaterInfo, tareInfo,null, dw);
            // add FNSI-条件送信がエラーの場合はord_mainに更新を行わないこと 徐 end
            // #11987 2026.02.11 add スケールベッド状態書込み用 TDC片口 start
            scaleBedStateService.updateSendStatusError(request.getScaleBedBedCd(), true, weightScaleNo);
            // #11987 2026.02.11 add スケールベッド状態書込み用 TDC片口 end

            return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
          }
          // IHDF治療条件不整合MsgList
          if (resCheck.indCondInfoUseIHDFMsgList.size() > 0) {

            res.isSuccess = false;
            res.indCondInfoUseIHDFMsgList = resCheck.indCondInfoUseIHDFMsgList;

            String errorMessage = "";
            for (int i = 0; i < resCheck.indCondInfoUseIHDFMsgList.size(); i++) {
              if (i == resCheck.indCondInfoUseIHDFMsgList.size() - 1) {
                errorMessage = "I-HDF治療では、" + errorMessage + resCheck.indCondInfoUseIHDFMsgList.get(i) + "を使用できません。";
              } else {
                errorMessage = errorMessage + resCheck.indCondInfoUseIHDFMsgList.get(i) + "、";
              }
            }

            weightService.updateOrdWeightStatus(
              weightScaleNo,
              SendCondition.WeightScaleClass.SEND_NG,
              errorMessage);
            // add FNSI-条件送信がエラーの場合はord_mainに更新を行わないこと 徐 start
            ordMainDao.updateBeforeWeight(request.getOrdNo(), weightInfo, offWaterInfo, tareInfo,null, dw);
            // add FNSI-条件送信がエラーの場合はord_mainに更新を行わないこと 徐 end
            // #11987 2026.02.11 add スケールベッド状態書込み用 TDC片口 start
            scaleBedStateService.updateSendStatusError(request.getScaleBedBedCd(), true, weightScaleNo);
            // #11987 2026.02.11 add スケールベッド状態書込み用 TDC片口 end

            return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
          }
          // AFBF治療条件不整合MsgList
          if (resCheck.indCondInfoUseAFBFMsgList.size() > 0) {

            res.isSuccess = false;
            res.indCondInfoUseAFBFMsgList = resCheck.indCondInfoUseAFBFMsgList;

            String errorMessage = "";
            for (int i = 0; i < resCheck.indCondInfoUseAFBFMsgList.size(); i++) {
              if (i == resCheck.indCondInfoUseAFBFMsgList.size() - 1) {
                errorMessage = "AFBF治療では、" + errorMessage + resCheck.indCondInfoUseAFBFMsgList.get(i) + "を使用できません。";
              } else {
                errorMessage = errorMessage + resCheck.indCondInfoUseAFBFMsgList.get(i) + "、";
              }
            }

            weightService.updateOrdWeightStatus(
              weightScaleNo,
              SendCondition.WeightScaleClass.SEND_NG,
              errorMessage);
            // add FNSI-条件送信がエラーの場合はord_mainに更新を行わないこと 徐 start
            ordMainDao.updateBeforeWeight(request.getOrdNo(), weightInfo, offWaterInfo, tareInfo,null, dw);
            // add FNSI-条件送信がエラーの場合はord_mainに更新を行わないこと 徐 end
            // #11987 2026.02.11 add スケールベッド状態書込み用 TDC片口 start
            scaleBedStateService.updateSendStatusError(request.getScaleBedBedCd(), true, weightScaleNo);
            // #11987 2026.02.11 add スケールベッド状態書込み用 TDC片口 end

            return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
          }
          // SN治療条件不整合MsgList
          if (resCheck.indCondInfoUseSNMsgList.size() > 0) {

            res.isSuccess = false;
            res.indCondInfoUseSNMsgList = resCheck.indCondInfoUseSNMsgList;

            String errorMessage = "";
            for (int i = 0; i < resCheck.indCondInfoUseSNMsgList.size(); i++) {
              if (i == resCheck.indCondInfoUseSNMsgList.size() - 1) {
                errorMessage = "シングルニードルを使用する場合、" + errorMessage + resCheck.indCondInfoUseSNMsgList.get(i) + "は使用できません。";
              } else {
                errorMessage = errorMessage + resCheck.indCondInfoUseSNMsgList.get(i) + "、";
              }
            }

            weightService.updateOrdWeightStatus(
              weightScaleNo,
              SendCondition.WeightScaleClass.SEND_NG,
              errorMessage);
            // add FNSI-条件送信がエラーの場合はord_mainに更新を行わないこと 徐 start
            ordMainDao.updateBeforeWeight(request.getOrdNo(), weightInfo, offWaterInfo, tareInfo,null, dw);
            // add FNSI-条件送信がエラーの場合はord_mainに更新を行わないこと 徐 end
            // #11987 2026.02.11 add スケールベッド状態書込み用 TDC片口 start
            scaleBedStateService.updateSendStatusError(request.getScaleBedBedCd(), true, weightScaleNo);
            // #11987 2026.02.11 add スケールベッド状態書込み用 TDC片口 end

            return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
          }
        }
        // add FNSI-分類不一致判断の追加 徐 end
        Map<String, Object> resChkCond = webAPICheckConditionSend.checkSendCond(request.getOrdNo());
        if ((boolean) resChkCond.get("ret") == false) {
          String resMsgJson = (String) resChkCond.get("msg");
          res.isSuccess = false;
          JsonNode node = mapper.readTree(resMsgJson);
          res.errorMessage = node.get("retMsg").asText("");
          String logMsg = node.get("retLogMsg").asText("");

          weightService.updateOrdWeightStatus(
            weightScaleNo,
            SendCondition.WeightScaleClass.SEND_NG,
            res.errorMessage);
          eventLogMessage.setLogMessage("条件送信データ生成失敗 facilityCd:[" + ntssUser.getFacilityCd() + "], " + logMsg);
          eventLogMessage.setPatId(String.valueOf(request.getPatId()));
          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
          // add FNSI-条件送信がエラーの場合はord_mainに更新を行わないこと 徐 start
          ordMainDao.updateBeforeWeight(request.getOrdNo(), weightInfo, offWaterInfo, tareInfo,null, dw);
          // add FNSI-条件送信がエラーの場合はord_mainに更新を行わないこと 徐 end
          // #11987 2026.02.11 add スケールベッド状態書込み用 TDC片口 start
          scaleBedStateService.updateSendStatusError(request.getScaleBedBedCd(), true, weightScaleNo);
          // #11987 2026.02.11 add スケールベッド状態書込み用 TDC片口 end

          return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
        }
      } catch (Exception e) {
        eventLogMessage.setLogMessage("条件送信データ生成エラー " + e.getMessage());
        logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
        res.errorMessage = "条件送信データ生成エラー";
        weightService.updateOrdWeightStatus(
          weightScaleNo,
          SendCondition.WeightScaleClass.SEND_NG,
          "条件送信データ生成エラー");
        // add FNSI-条件送信がエラーの場合はord_mainに更新を行わないこと 徐 start
        ordMainDao.updateBeforeWeight(request.getOrdNo(), weightInfo, offWaterInfo, tareInfo,null, dw);
        // add FNSI-条件送信がエラーの場合はord_mainに更新を行わないこと 徐 end
        // #11987 2026.02.11 add スケールベッド状態書込み用 TDC片口 start
        scaleBedStateService.updateSendStatusError(request.getScaleBedBedCd(), true, weightScaleNo);
        // #11987 2026.02.11 add スケールベッド状態書込み用 TDC片口 end
        return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
      }
      // add #7660 2022/08/24 【デグレ】実績確定するまでの間は治療記録用紙に表示されない項目がある。 王永吉 start
      if (ordMainAll.getRstBedCd() == null){
        // mod #7977 2022/10/13【デグレ】仮想端末の投与薬剤が表示されなくなった dou start
//        ordMainDao.updateIndInfoToRstInfo(request.getOrdNo(), ordMainAll.getIndBedCd(), ordMainAll.getIndCondInfo(), ordMainAll.getIndMediInfo()
//          , ordMainAll.getIndEquipInfo(), ordMainAll.getIndIndCommentInfo(), ordMainAll.getIndDeviceSetInfo());
//        ordMainAll = ordMainDao.selectByOrdNo(request.getOrdNo());
		//mod 8347【デグレ】????患者治療割り当てができない zhao start
        //ordMainAll.setRstBedCd(ordMainAll.getIndBedCd());
        ordMainAll.setRstBedCd(ordMainAll.getIndBedCd().longValue());
		//mod 8347【デグレ】????患者治療割り当てができない zhao end
        ordMainAll.setRstCondInfo(ordMainAll.getIndCondInfo());
        ordMainAll.setRstMediInfo(ordMainAll.getIndMediInfo());
        ordMainAll.setRstEquipInfo(ordMainAll.getIndEquipInfo());
        ordMainAll.setRstIndCommentInfo(ordMainAll.getIndIndCommentInfo());
//        ordMainAll.setRstDeviceSetInfo(ordMainAll.getIndDeviceSetInfo()); // del by shiyw 2024-01-31 [#10196]ord_mainのデータ定義の修正
        // mod #7977 2022/10/13【デグレ】仮想端末の投与薬剤が表示されなくなった dou end
      }
      treatmentStatusListService.middleCheck(ordMainAll);
      // add #7660 2022/08/24 【デグレ】実績確定するまでの間は治療記録用紙に表示されない項目がある。 王永吉 end
      // del #7641 自動印刷で値が入らない項目がある 鄭爽 start
      // 前体重測定時自動印刷
      // try {
      //  AutoPrintResult printR = autoPrintService.reportAutoPrint(request.getPatId(), request.getOrdNo(),
      //    request.getTreatmentCd(), request.getBedCd(), TimingEnum.beforeWeight, ntssUser.getUserId(),
      //    ntssUser.getUsername(), true);
      //  res.isAutoPrint = printR.isAutoPrint;
      //  res.isSuccessAutoPrint = printR.isSuccessAutoPrint;
      //  res.autoPrintErrorMessage = printR.autoPrintErrorMessage;
      //} catch (Exception ex) {
      //  res.isAutoPrint = true;
      //  res.isSuccessAutoPrint = false;
      //  res.autoPrintErrorMessage = "帳票印刷に失敗しました。";
      //}
      // del #7641 自動印刷で値が入らない項目がある 鄭爽 end
      // add 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 start
      // add 8140 【デグレ】ベッドマスタにて自動印刷を「印刷しない」にしていた場合、印刷失敗通知が発生する 吉 start
      MstBed mstBed = mstBedDao.selectByBedCd(request.getBedCd(), AdminWebConstant.FlagType.FLAG_ON, AdminWebConstant.FlagType.FLAG_OFF);
      if (Objects.isNull(mstBed)) {
        // ベッド取得失敗
        eventLogMessage.setLogMessage("ベッド取得失敗 bed_cd=[" + request.getBedCd() + "]");
        eventLogMessage.setSqlIdentification("(bedCd = "+ request.getBedCd()  +", FLAG_ON = "+ AdminWebConstant.FlagType.FLAG_ON +", FLAG_OFF = "+ AdminWebConstant.FlagType.FLAG_OFF +")");
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, "MstBedDao/selectByBedCd");
        res.autoPrintErrorMessage = "ベッド情報なし";
      }else{
        if (AdminWebConstant.FlagType.FLAG_ON.equals(mstBed.getIsAutoprintBefore())) {
          // add 8140 【デグレ】ベッドマスタにて自動印刷を「印刷しない」にしていた場合、印刷失敗通知が発生する 吉 end
          String finalRstDialysisStateBefore = rstDialysisStateBefore;
          Thread t1 = new Thread(finalRstDialysisStateBefore){
            @Override
            public void run() {
              String rstTreatmentCd = null;
              MstReport mr = new MstReport();
              // add #9616 帳票印刷失敗通知がされない 高 2024/01/25　start
              String reportName = "";
              // add #9616 帳票印刷失敗通知がされない 高 2024/01/25　end
              try {
                int count = 0;
                String rstDialysisStateAfter = finalRstDialysisStateBefore;
                while(finalRstDialysisStateBefore == rstDialysisStateAfter || rstTreatmentCd == null){
                  count++;
                  OrdMain ordmainRst = ordMainDao.selectRstDialysisState(request.getOrdNo());
                  if (ordmainRst != null) {
                    if (ordmainRst.getRstTreatmentCd() != null) {
                      rstTreatmentCd = String.valueOf(ordmainRst.getRstTreatmentCd());
                    }
                    rstDialysisStateAfter = ordmainRst.getRstDialysisState();
                  }
                  sleep(1000);
                  if(count>20){
                    break;
                  }
                }
                // add #9616 帳票印刷失敗通知がされない 高 2024/01/17　start
                // del #9616 帳票印刷失敗通知がされない 高 2024/01/25　start
//                try {
//                  // add #9616 帳票印刷失敗通知がされない 高 2024/01/17　end
//                  if(null != rstTreatmentCd){
//                    MstTreatment mstTreatment = mstTreatmentDao.selectByCd(Integer.valueOf(rstTreatmentCd));
//
//                    // add #9616 帳票印刷失敗通知がされない 高　start
//                    if (!StringUtils.isEmpty(mstTreatment.getReportIdBw())) {
//                      mr = mstReportDao.selectByCd((long) mstTreatment.getReportIdBw());
//                    } else {
//                      FacilitySettingInfo facilitySettingInfo = mstFacilitySettingDao.getBySettingNoAndCd(ntssUser.getFacilityCd(), CoreConstant.FacilitySettingNo.DEFAULT_REPORT_TEMPLATE);
//                      // add #9616 帳票印刷失敗通知がされない 高 2024/01/17　start
//                      if (!StringUtils.isEmpty(facilitySettingInfo.getValue())) {
//                        // add #9616 帳票印刷失敗通知がされない 高 2024/01/17　end
//                        Long reportCd = Long.parseLong(facilitySettingInfo.getValue());
//                        if (reportCd != 0) {
//                          mr = mstReportDao.selectByCd(reportCd);
//                          // add #9616 帳票印刷失敗通知がされない 高 2024/01/17　start
//                        }
//                        // add #9616 帳票印刷失敗通知がされない 高 2024/01/17　end
//                      }
//                    }
//                    // add #9616 帳票印刷失敗通知がされない 高　end
//                    // del #9616 帳票印刷失敗通知がされない 高　start
////                  mr = mstReportDao.selectByCd((long) mstTreatment.getReportId());
//                    // del #9616 帳票印刷失敗通知がされない 高　end
//                  }
//                  // add #9616 帳票印刷失敗通知がされない 高 2024/01/17　start
//                } catch (Exception ex) {
//                  SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
//                  JSONObject replaceData = new JSONObject();
//                  replaceData.put("REPORTTYPE", "治療経過表");
//                  replaceData.put("REPORTNAME", "テンプレートがない");
//                  replaceData.put("UP_DATE", sdf.format(new Date()));
//                  JSONObject jsonBody = new JSONObject();
//                  jsonBody.put("notificationNo", CoreConstant.NotificationDefinition.PRINT_FAIL);
//                  jsonBody.put("facilityCd", ntssUser.getFacilityCd());
//                  // 変換用文字列のエンコード処理(UTF-8)
//                  String base64replaceData = new String(Base64.getEncoder().encode(replaceData.toString().getBytes(StandardCharsets.UTF_8)), StandardCharsets.UTF_8);
//                  jsonBody.put("replaceData", base64replaceData);
//                  saveNotiMessage(jsonBody);
//                }
                // del #9616 帳票印刷失敗通知がされない 高 2024/01/25　end
                // add #9616 帳票印刷失敗通知がされない 高 2024/01/25　start
                reportName = autoPrintGetReportName(rstTreatmentCd,mr,ntssUser,TimingEnum.beforeWeight);
                // add #9616 帳票印刷失敗通知がされない 高 2024/01/25　end
                // add #9616 帳票印刷失敗通知がされない 高 2024/01/17　end

                // add #9616 帳票印刷失敗通知がされない 高　start
                // del #9616 帳票印刷失敗通知がされない 高 2024/01/25　start
//                if (mr!= null && !StringUtils.isEmpty(mr.getReportName())) {
                // del #9616 帳票印刷失敗通知がされない 高 2024/01/25　end
                  // add #9616 帳票印刷失敗通知がされない 高　end
                  if(count>20){
                    // del #9616 帳票印刷失敗通知がされない 高 2024/01/25　start
//                    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
//                    JSONObject replaceData = new JSONObject();
//                    replaceData.put("REPORTTYPE", "治療経過表");
//                    replaceData.put("REPORTNAME", mr.getReportName());
//                    replaceData.put("UP_DATE", sdf.format(new Date()));
//                    JSONObject jsonBody = new JSONObject();
//                    jsonBody.put("notificationNo", CoreConstant.NotificationDefinition.PRINT_FAIL);
//                    jsonBody.put("facilityCd", ntssUser.getFacilityCd());
//                    // 変換用文字列のエンコード処理(UTF-8)
//                    String base64replaceData = new String(Base64.getEncoder().encode(replaceData.toString().getBytes(StandardCharsets.UTF_8)), StandardCharsets.UTF_8);
//                    jsonBody.put("replaceData", base64replaceData);
//                    saveNotiMessage(jsonBody);
                    // del #9616 帳票印刷失敗通知がされない 高 2024/01/25　end
                    // add #9616 帳票印刷失敗通知がされない 高 2024/01/25　start
                    sendFailureNotification(reportName,ntssUser);
                    // add #9616 帳票印刷失敗通知がされない 高 2024/01/25　end
                  }else{
                    AutoPrintResult printR = autoPrintService.reportAutoPrint(request.getPatId(), request.getOrdNo(),
                      request.getTreatmentCd(), request.getBedCd(), TimingEnum.beforeWeight, ntssUser.getUserId(),
                      ntssUser.getUsername(), true);
                    if(!printR.isSuccessAutoPrint){
                      // del #9616 帳票印刷失敗通知がされない 高 2024/01/25　start
//                      SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
//                      JSONObject replaceData = new JSONObject();
//                      replaceData.put("REPORTTYPE", "治療経過表");
//                      replaceData.put("REPORTNAME", mr.getReportName());
//                      replaceData.put("UP_DATE", sdf.format(new Date()));
//                      JSONObject jsonBody = new JSONObject();
//                      jsonBody.put("notificationNo", CoreConstant.NotificationDefinition.PRINT_FAIL);
//                      jsonBody.put("facilityCd", ntssUser.getFacilityCd());
//                      // 変換用文字列のエンコード処理(UTF-8)
//                      String base64replaceData = new String(Base64.getEncoder().encode(replaceData.toString().getBytes(StandardCharsets.UTF_8)), StandardCharsets.UTF_8);
//                      jsonBody.put("replaceData", base64replaceData);
//                      saveNotiMessage(jsonBody);
                      // del #9616 帳票印刷失敗通知がされない 高 2024/01/25　end
                      // add #9616 帳票印刷失敗通知がされない 高 2024/01/25　start
                      sendFailureNotification(reportName,ntssUser);
                      // add #9616 帳票印刷失敗通知がされない 高 2024/01/25　end
                    }
                    // add #9616 帳票印刷失敗通知がされない 高　start
                  }
                  // add #9616 帳票印刷失敗通知がされない 高　end
                // del #9616 帳票印刷失敗通知がされない 高 2024/01/25　start
//                }
                // del #9616 帳票印刷失敗通知がされない 高 2024/01/25　end
              } catch (Exception ex) {
                // add #9616 帳票印刷失敗通知がされない 高　start
                // del #9616 帳票印刷失敗通知がされない 高 2024/01/25　start
//                if (mr!= null && !StringUtils.isEmpty(mr.getReportName())) {
//                  // add #9616 帳票印刷失敗通知がされない 高　end
//                  SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
//                  JSONObject replaceData = new JSONObject();
//                  replaceData.put("REPORTTYPE", "治療経過表");
//                  replaceData.put("REPORTNAME", mr.getReportName());
//                  replaceData.put("UP_DATE", sdf.format(new Date()));
//                  JSONObject jsonBody = new JSONObject();
//                  jsonBody.put("notificationNo", CoreConstant.NotificationDefinition.PRINT_FAIL);
//                  jsonBody.put("facilityCd", ntssUser.getFacilityCd());
//                  // 変換用文字列のエンコード処理(UTF-8)
//                  String base64replaceData = new String(Base64.getEncoder().encode(replaceData.toString().getBytes(StandardCharsets.UTF_8)), StandardCharsets.UTF_8);
//                  jsonBody.put("replaceData", base64replaceData);
//                  saveNotiMessage(jsonBody);
//                  // add #9616 帳票印刷失敗通知がされない 高　start
//                }
                // del #9616 帳票印刷失敗通知がされない 高 2024/01/25　end
                // add #9616 帳票印刷失敗通知がされない 高 2024/01/25　start
                sendFailureNotification(reportName,ntssUser);
                // add #9616 帳票印刷失敗通知がされない 高 2024/01/25　end
                // add #9616 帳票印刷失敗通知がされない 高　end
              }
            }
          };
          t1.start();
          // add 8140 【デグレ】ベッドマスタにて自動印刷を「印刷しない」にしていた場合、印刷失敗通知が発生する 吉 start
        }
      }
      // add 8140 【デグレ】ベッドマスタにて自動印刷を「印刷しない」にしていた場合、印刷失敗通知が発生する 吉 end
      // add 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 end
      SendConditionResponse wsRes = postSendConditionWs(request.getOrdNo(), weightScaleNo,
        ntssUser.getFacilityCd());
      if (!wsRes.isSuccess) {
        weightService.updateOrdWeightStatus(
          weightScaleNo,
          SendCondition.WeightScaleClass.SEND_NG,
          wsRes.errorMessage);
        // add FNSI-条件送信がエラーの場合はord_mainに更新を行わないこと 徐 start
        ordMainDao.updateBeforeWeight(request.getOrdNo(), weightInfo, offWaterInfo, tareInfo,null, dw);
        // add FNSI-条件送信がエラーの場合はord_mainに更新を行わないこと 徐 end
        // #11987 2026.02.11 add スケールベッド状態書込み用 TDC片口 start
        scaleBedStateService.updateSendStatusError(request.getScaleBedBedCd(), true, weightScaleNo);
        // #11987 2026.02.11 add スケールベッド状態書込み用 TDC片口 end

        return new ResponseEntity<>(wsRes, HttpStatus.BAD_REQUEST);
        // add #7641 自動印刷で値が入らない項目がある 鄭爽 start
        // del 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 start
//    } else {
//      String rstTreatmentCd = null;
//      String rstDialysisStateAfter = rstDialysisStateBefore;
//      while(rstDialysisStateBefore == rstDialysisStateAfter || rstTreatmentCd == null){
//        OrdMain ordmainRst = ordMainDao.selectRstDialysisState(request.getOrdNo());
//        if (ordmainRst != null) {
//          if (ordmainRst.getRstTreatmentCd() != null) {
//            rstTreatmentCd = String.valueOf(ordmainRst.getRstTreatmentCd());
//          }
//          rstDialysisStateAfter = ordmainRst.getRstDialysisState();
//        }
//        Thread.sleep(100);
//      }
//      // 前体重測定時自動印刷
//      try {
//        AutoPrintResult printR = autoPrintService.reportAutoPrint(request.getPatId(), request.getOrdNo(),
//          request.getTreatmentCd(), request.getBedCd(), TimingEnum.beforeWeight, ntssUser.getUserId(),
//          ntssUser.getUsername(), true);
//        res.isAutoPrint = printR.isAutoPrint;
//        res.isSuccessAutoPrint = printR.isSuccessAutoPrint;
//        res.autoPrintErrorMessage = printR.autoPrintErrorMessage;
//      } catch (Exception ex) {
//        res.isAutoPrint = true;
//        res.isSuccessAutoPrint = false;
//        res.autoPrintErrorMessage = "帳票印刷に失敗しました。";
//      }
        // del 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 end
        // add #7641 自動印刷で値が入らない項目がある 鄭爽 end
      }

      // 体重測定履歴の測定履歴をステータス：条件送信指示中に更新する
      weightService.updateOrdWeightStatus(weightScaleNo,
        SendCondition.WeightScaleClass.ORDER,
        "");
      res.isSuccess = true;
      res.weightScaleNo = weightScaleNo;
      // del 11613 by shiyw 20250307 start
//      // add FNSI-確定フラグを”1”に更新 徐 start
//      // 確定フラグを”1”に更新
//      weightService.updateIsConfirm(request.getOrdNo(), request.getPatId());
//      // add FNSI-確定フラグを”1”に更新 徐 end
      // del 11613 by shiyw 20250307 end
      //    del 8074 【デグレ】ログに誤った利用者が記録される 関 start
      //    add 8074 【デグレ】ログに誤った利用者が記録される 関 start
//      ordMainService.updateUseId(request.getOrdNo(),ntssUser.getUserId());
      //    add 8074 【デグレ】ログに誤った利用者が記録される 関  end
      //    del 8074 【デグレ】ログに誤った利用者が記録される 関  end
      // #11987 2026.03.19 add スケールベッド状態書込み用 TDC片口 start
      scaleBedStateService.updateSendStatusNormalize(request.getScaleBedBedCd(), true, weightScaleNo);
      // #11987 2026.03.19 add スケールベッド状態書込み用 TDC片口 end
      return new ResponseEntity<>(res, HttpStatus.OK);

    } catch (UniqueConstraintException e) {
      eventLogMessage.setLogMessage("条件送信データ書き込みエラー " + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
      res.errorMessage = "データ書き込み失敗";
      // #11987 2026.02.11 add スケールベッド状態書込み用 TDC片口 start
      scaleBedStateService.updateSendStatusError(request.getScaleBedBedCd(), true, request.getWeightScaleNo());
      // #11987 2026.02.11 add スケールベッド状態書込み用 TDC片口 end
      return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
    } catch (Exception e) {
      eventLogMessage.setLogMessage("条件送信処理でエラー " + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
      res.errorMessage = "条件送信処理でエラー";
      // #11987 2026.02.11 add スケールベッド状態書込み用 TDC片口 start
      scaleBedStateService.updateSendStatusError(request.getScaleBedBedCd(), true, request.getWeightScaleNo());
      // #11987 2026.02.11 add スケールベッド状態書込み用 TDC片口 end
      return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 条件送信せず実績登録と測定記録のみを行う
   *
   * @param
   * @return
   */
  @PostMapping("/no_send_condition")
  public ResponseEntity<?> postNoSendCondition(
    @RequestBody SendConditionRequest request,
    @AuthenticationPrincipal NtssUser ntssUser) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.WEIGHT + "/no_send_condition";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    SendConditionResponse res = new SendConditionResponse();
    try {

      // 体重測定履歴に測定履歴を\nステータス：測定済みで記録する
      request.setFacilityCd(ntssUser.getFacilityCd());
      res = weightService.saveSendConditionOrdWeightScale(request, SendCondition.WeightScaleClass.MEASURED);
      if (res.isSuccess == false) {

        // wp アプリケーションログの適正化 Add Start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
          null);
        // wp アプリケーションログの適正化 Add End
        return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
      }
      Long weightScaleNo = res.printWeightScaleNo;

      // 体重値、目標除水量等を\n治療予定「ord_main」に記録する
      SendConditionResponse res2 = weightService.saveBeforeWeight(request);
      if (res2.isSuccess == false) {
        weightService.updateOrdWeightStatus(
          weightScaleNo,
          SendCondition.WeightScaleClass.SEND_NG,
          res2.errorMessage);

        // wp アプリケーションログの適正化 Add Start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
          null);
        // wp アプリケーションログの適正化 Add End
        return new ResponseEntity<>(res2, HttpStatus.BAD_REQUEST);
      }
      // 条件送信しない
      res.isSuccess = true;
      // #10833 2024.08.08 mod 体重測定番号をセットする TDC米沢 start
      // res.weightScaleNo = null;
      res.weightScaleNo = weightScaleNo;
      // #10833 2024.08.08 mod 体重測定番号をセットする TDC米沢 end

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.OK);

    } catch (UniqueConstraintException e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (ntssUser != null && ntssUser.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
      res.errorMessage = "データ書き込み失敗";
      return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (ntssUser != null && ntssUser.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
      res.errorMessage = e.getMessage();
      return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 測定記録を行い、コードを返す
   *
   * @param
   * @return
   */
  @PostMapping("/save_measure")
  public ResponseEntity<?> postSaveMeasure(
    @RequestBody SendConditionRequest request,
    @AuthenticationPrincipal NtssUser ntssUser) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.WEIGHT + "/save_measure";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    SendConditionResponse res = new SendConditionResponse();
    try {

      // 体重値、目標除水量等を\n治療予定「ord_main」に記録する
      // 体重測定履歴に測定履歴を\nステータス：測定済みで記録する
      request.setFacilityCd(ntssUser.getFacilityCd());
      OrdWeightScale scale = weightService.insertOrdWeight(request, SendCondition.WeightScaleClass.MEASURED);
      if (scale == null) {
        res.errorMessage = "測定記録書き込み失敗";

        // wp アプリケーションログの適正化 Add Start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
          null);
        // wp アプリケーションログの適正化 Add End
        return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
      }
      // 条件送信しない
      res.isSuccess = true;
      res.weightScaleNo = scale.getWeightScaleNo();

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.OK);

    } catch (UniqueConstraintException e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (ntssUser != null && ntssUser.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
      res.errorMessage = "データ書き込み失敗";
      return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (ntssUser != null && ntssUser.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
      res.errorMessage = e.getMessage();
      return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 条件送信をデバイスエッジにリクエストする
   *
   * @param ordNo
   * @return
   */
  private SendConditionResponse postSendConditionWs(Long ordNo, Long weightScaleNo, String facilityCd) {

    SendConditionResponse res = new SendConditionResponse();
    try {
      // 条件からベッドコードを取得し、ベッドコードから装置を取得し、デバイスエッジ番号を取得
      MstMachine machine = weightService.getMachineByOrderInd(ordNo);
      if (machine == null) {
        res.isSuccess = false;
        res.errorMessage = "通知先装置の特定失敗";
        return res;
      }
      // ord_no + 条件でSHA256作成
      String deviceInfo = weightService.getTmpDeviceSetInfo(machine);
      String hash = DigestUtils.sha256Hex(ordNo.toString() + deviceInfo);

      String topic = PayloadBuilder.BuildWeightTopic(WebSocketTopic.ComSv.SEND_CONDITION, facilityCd,
        machine.getDeviceEdgeNo());

      String machineInfo = machine.getMachineNo().toString();

      String payload = PayloadBuilder.BuildSendConditionPayload(machineInfo, ordNo, weightScaleNo, hash);

      // EdgeあてにWebsocket通知
      if (sendWsMsg.sendMsg(SendTarget.main, facilityCd, machine.getDeviceEdgeNo(), topic, payload)) {
        res.isSuccess = true;
      } else {
        res.isSuccess = false;
        res.errorMessage = "通信サーバーへの通知失敗";
      }
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (facilityCd != null) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
      res.isSuccess = false;
      res.errorMessage = e.getMessage();
    }
    return res;
  }

  /**
   * 後体重送信を行う
   *
   * @param
   * @return
   */
  @PostMapping("/send_afterweight")
  public ResponseEntity<?> postSendAfterWEight(
    @RequestBody SendConditionRequest request,
    @AuthenticationPrincipal NtssUser ntssUser) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.WEIGHT + "/send_afterweight";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    // add #9616 帳票印刷失敗通知がされない 高　start
    String rstTreatmentCd = null;
    MstReport mr = new MstReport();
    OrdMain ordmainRst = ordMainDao.selectRstDialysisState(request.getOrdNo());
    if (ordmainRst != null) {
      if (ordmainRst.getRstTreatmentCd() != null) {
        rstTreatmentCd = String.valueOf(ordmainRst.getRstTreatmentCd());
      }
    }
    // add #9616 帳票印刷失敗通知がされない 高 2024/01/17　start
    String reportName = "";
    // add #9616 帳票印刷失敗通知がされない 高 2024/01/25　start
    reportName = autoPrintGetReportName(rstTreatmentCd,mr,ntssUser,TimingEnum.afterWeight);
    // add #9616 帳票印刷失敗通知がされない 高 2024/01/25　end
    // del #9616 帳票印刷失敗通知がされない 高 2024/01/25　start
//    try {
//      // add #9616 帳票印刷失敗通知がされない 高 2024/01/17　end
//      if(null != rstTreatmentCd){
//        MstTreatment mstTreatment = mstTreatmentDao.selectByCd(Integer.valueOf(rstTreatmentCd));
//        if (mstTreatment.getReportIdAw() != null && mstTreatment.getReportIdAw() != 0) {
//          mr = mstReportDao.selectByCd((long) mstTreatment.getReportIdAw());
//        } else {
//          FacilitySettingInfo facilitySettingInfo = mstFacilitySettingDao.getBySettingNoAndCd(ntssUser.getFacilityCd(), CoreConstant.FacilitySettingNo.DEFAULT_REPORT_TEMPLATE);
//          // add #9616 帳票印刷失敗通知がされない 高 2024/01/17　start
//          if (!StringUtils.isEmpty(facilitySettingInfo.getValue())) {
//            // add #9616 帳票印刷失敗通知がされない 高 2024/01/17　end
//            Long reportCd = Long.parseLong(facilitySettingInfo.getValue());
//            if (reportCd != 0) {
//              mr = mstReportDao.selectByCd(reportCd);
//            }
//            // add #9616 帳票印刷失敗通知がされない 高 2024/01/17　start
//          }
//          // add #9616 帳票印刷失敗通知がされない 高 2024/01/17　end
//        }
//      }
//      reportName = mr.getReportName();
//      // add #9616 帳票印刷失敗通知がされない 高 2024/01/17　start
//    } catch (Exception ex) {
//      SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
//      JSONObject replaceData = new JSONObject();
//      replaceData.put("REPORTTYPE", "治療経過表");
//      replaceData.put("REPORTNAME", "テンプレートがない");
//      replaceData.put("UP_DATE", sdf.format(new Date()));
//      JSONObject jsonBody = new JSONObject();
//      jsonBody.put("notificationNo", CoreConstant.NotificationDefinition.PRINT_FAIL);
//      jsonBody.put("facilityCd", ntssUser.getFacilityCd());
//      // 変換用文字列のエンコード処理(UTF-8)
//      String base64replaceData = new String(Base64.getEncoder().encode(replaceData.toString().getBytes(StandardCharsets.UTF_8)), StandardCharsets.UTF_8);
//      jsonBody.put("replaceData", base64replaceData);
//      saveNotiMessage(jsonBody);
//    }
    // del #9616 帳票印刷失敗通知がされない 高 2024/01/25　end
    // add #9616 帳票印刷失敗通知がされない 高 2024/01/17　end

    // add #9616 帳票印刷失敗通知がされない 高　end

    //add 9616 帳票印刷失敗通知がされない 李 start
    // mod #9616 帳票印刷失敗通知がされない 高　start
//    String reportType = "透析レポート";
//    String reportName = "後体重印刷に失敗しました";
    // del #9616 帳票印刷失敗通知がされない 高 2024/01/25　start
//    String reportType = "治療経過表";
    // del #9616 帳票印刷失敗通知がされない 高 2024/01/25　end
//    String reportName = mr.getReportName();

    // mod #9616 帳票印刷失敗通知がされない 高　end

    //add 9616 帳票印刷失敗通知がされない 李 start

    SendConditionResponse res = new SendConditionResponse();
    try {
      String baseDialysisState = weightService.getCurrentDialysisState(request.getOrdNo());
      // 体重値、目標除水量等を\n治療予定「ord_main」に記録する
      request.setFacilityCd(ntssUser.getFacilityCd());
      OrdWeightScale scale = weightService.insertSendAfterWeightInfo(request, SendCondition.WeightScaleClass.MEASURED);
      if (scale == null) {
        res.errorMessage = "条件データ書き込み失敗";

        // wp アプリケーションログの適正化 Add Start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
          null);
        // wp アプリケーションログの適正化 Add End
        // #11987 2026.03.19 add スケールベッド状態書込み用 TDC片口 start
        scaleBedStateService.updateSendStatusError(request.getScaleBedBedCd(), false, request.getWeightScaleNo());
        // #11987 2026.03.19 add スケールベッド状態書込み用 TDC片口 end
        return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
      }
      res.printWeightScaleNo = scale.getWeightScaleNo(); // 印刷対象(この次で例外発生した場合対策)

      // #10833 2024.08.08 del static変数削除 TDC米沢 start
      // // add #7189 【デグレ】条件送信時、サーマルプリンターで印字されない 王永吉 start
      // // 送信処理時測定済みで記録番号取得
      // boolean getWeightScaleNoFalg = true;
      // if (request.getWeightScaleNo() != null ){
      //   getWeightScaleNo = request.getWeightScaleNo().toString();
      //   getWeightScaleNoFalg = false;
      // }
      // if (getWeightScaleNoFalg){
      //   getWeightScaleNo = res.printWeightScaleNo.toString();
      // }
      // // add #7189 【デグレ】条件送信時、サーマルプリンターで印字されない 王永吉 end
      // #10833 2024.08.08 del static変数削除 TDC米沢 end

      if (rstDialysisState.AFTER_WEIGHT.equals(baseDialysisState)
        || rstDialysisState.AFTER_PAST_RECORD.equals(baseDialysisState)) {
        // 後体重測定済みならば一度通信サーバーに通知した後なのでもう通知しない
        res.isSuccess = true;
      } else {
        MachineCurrentOrdDataSet machineResp = weightService.findMachineStateByBed(request.getFacilityCd(),
          request.getBedCd());
        if (Objects.equals(machineResp.targetMachineCurrentOrdNo, request.getOrdNo())) {
          // 現患者が後体重測定した患者と同じオーダーならば、通信サーバーに後体重測定信号を通知
          res = postSendAfterWeightWs(request.getOrdNo(), request.getFacilityCd());
        } else {
          // 装置状態の現患者が別のオーダーならば、次の治療が始まっているので通知しない
          res.isSuccess = true;
        }
      }
      //    del 8074 【デグレ】ログに誤った利用者が記録される 関 start
      //    add 8074 【デグレ】ログに誤った利用者が記録される 関 start
//      ordMainService.updateUseId(request.getOrdNo(),ntssUser.getUserId());
//    add 8074 【デグレ】ログに誤った利用者が記録される 関  end
//    del 8074 【デグレ】ログに誤った利用者が記録される 関  end
      res.printWeightScaleNo = scale.getWeightScaleNo(); // 印刷対象再設定
      // add #7660 2022/08/24 【デグレ】実績確定するまでの間は治療記録用紙に表示されない項目がある。 王永吉 start
      OrdMain ordMainAll = ordMainDao.selectByOrdNo(request.getOrdNo());
      treatmentStatusListService.middleCheck(ordMainAll);
      // add #7660 2022/08/24 【デグレ】実績確定するまでの間は治療記録用紙に表示されない項目がある。 王永吉 end
      // 後体重測定時自動印刷
      try {
        //add #9616 帳票印刷失敗通知がされない 李 start
//        AutoPrintResult printR = autoPrintService.reportAutoPrint(request.getPatId(), request.getOrdNo(),
//          request.getTreatmentCd(), request.getBedCd(), TimingEnum.afterWeight, ntssUser.getUserId(),
//          ntssUser.getUsername(), true);
        AutoPrintResult printR = autoPrintService.reportAutoPrint(request.getPatId(), request.getOrdNo(),
          request.getTreatmentCd(), request.getBedCd(), TimingEnum.afterWeight, ntssUser.getUserId(),
          ntssUser.getUsername(), true);
        //add #9616 帳票印刷失敗通知がされない 李 start

        res.isAutoPrint = printR.isAutoPrint;
        res.isSuccessAutoPrint = printR.isSuccessAutoPrint;
        res.autoPrintErrorMessage = printR.autoPrintErrorMessage;
      } catch (Exception ex) {
        res.isAutoPrint = true;
        res.isSuccessAutoPrint = false;
        res.autoPrintErrorMessage = "帳票自動印刷失敗";
      }
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End

      // add #9616 帳票印刷失敗通知がされない 高 2024/01/12　start
      MstBed mstBed = mstBedDao.selectByBedCd(request.getBedCd(), AdminWebConstant.FlagType.FLAG_ON, AdminWebConstant.FlagType.FLAG_OFF);
      if (!Objects.isNull(mstBed)) {
        if (AdminWebConstant.FlagType.FLAG_ON.equals(mstBed.getIsAutoprintAfter())) {
          // add #9616 帳票印刷失敗通知がされない 高 2024/01/12　end
      //add #9616 帳票印刷失敗通知がされない 李 start
      // add #9616 帳票印刷失敗通知がされない 高　start
          // del #9616 帳票印刷失敗通知がされない 高 2024/01/25　start
//      if (!StringUtils.isEmpty(reportName)) {
          // del #9616 帳票印刷失敗通知がされない 高 2024/01/25　end
        // add #9616 帳票印刷失敗通知がされない 高　end
        if(!res.isSuccessAutoPrint){
          // del #9616 帳票印刷失敗通知がされない 高 2024/01/25　start
//          SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
//          JSONObject replaceData = new JSONObject();
//          replaceData.put("REPORTTYPE", reportType);
//          replaceData.put("REPORTNAME", reportName);
//          replaceData.put("UP_DATE", sdf.format(new Date()));
//          JSONObject jsonBody = new JSONObject();
//          jsonBody.put("notificationNo", CoreConstant.NotificationDefinition.PRINT_FAIL);
//          jsonBody.put("facilityCd", ntssUser.getFacilityCd());
//          // 変換用文字列のエンコード処理(UTF-8)
//          String base64replaceData = new String(Base64.getEncoder().encode(replaceData.toString().getBytes(StandardCharsets.UTF_8)), StandardCharsets.UTF_8);
//          jsonBody.put("replaceData", base64replaceData);
//          saveNotiMessage(jsonBody);
          // del #9616 帳票印刷失敗通知がされない 高 2024/01/25　end
          // add #9616 帳票印刷失敗通知がされない 高 2024/01/25　start
          sendFailureNotification(reportName,ntssUser);
          // add #9616 帳票印刷失敗通知がされない 高 2024/01/25　end
        }
        // add #9616 帳票印刷失敗通知がされない 高　start
          // del #9616 帳票印刷失敗通知がされない 高 2024/01/25　start
//      }
          // del #9616 帳票印刷失敗通知がされない 高 2024/01/25　end
      // add #9616 帳票印刷失敗通知がされない 高　end
      //add #9616 帳票印刷失敗通知がされない 李 end
          // add #9616 帳票印刷失敗通知がされない 高 2024/01/12　start
        }
      }
      // add #9616 帳票印刷失敗通知がされない 高 2024/01/12　end

      // #11987 2026.03.19 add スケールベッド状態書込み用 TDC片口 start
      scaleBedStateService.updateSendStatusNormalize(request.getScaleBedBedCd(), false, scale.getWeightScaleNo());
      // #11987 2026.03.19 add スケールベッド状態書込み用 TDC片口 end
      return new ResponseEntity<>(res, HttpStatus.OK);

    } catch (UniqueConstraintException e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (ntssUser != null && ntssUser.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
      res.errorMessage = "データ書き込み失敗";
      // #11987 2026.03.19 add スケールベッド状態書込み用 TDC片口 start
      scaleBedStateService.updateSendStatusError(request.getScaleBedBedCd(), false, request.getWeightScaleNo());
      // #11987 2026.03.19 add スケールベッド状態書込み用 TDC片口 end
      return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (ntssUser != null && ntssUser.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
      res.errorMessage = e.getMessage();
      // #11987 2026.03.19 add スケールベッド状態書込み用 TDC片口 start
      scaleBedStateService.updateSendStatusError(request.getScaleBedBedCd(), false, request.getWeightScaleNo());
      // #11987 2026.03.19 add スケールベッド状態書込み用 TDC片口 end
      return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 後体重送信済み状態へのデータ更新を行う
   *
   * @param
   * @return
   */
  @PutMapping("/saved-after-weight")
  public ResponseEntity<?> puSavedAfterWEight(
    @RequestBody SendConditionRequest request,
    @AuthenticationPrincipal NtssUser ntssUser) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.WEIGHT + "/saved-after-weight";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    SendConditionResponse res = new SendConditionResponse();
    try {
      // 体重値、目標除水量等を\n治療予定「ord_main」に記録する
      OrdWeightScaleBuildInfo scale = weightService.updateStateAfterWeight(request.getOrdNo(),
        ntssUser.getFacilityCd());
      if (scale == null) {
        res.errorMessage = "更新失敗";
        // wp アプリケーションログの適正化 Add Start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
          null);
        // wp アプリケーションログの適正化 Add End
        return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
      }

      MachineCurrentOrdDataSet machineResp = weightService.findMachineStateByBed(ntssUser.getFacilityCd(),
        scale.getRstBedCd());
      if (Objects.equals(machineResp.targetMachineCurrentOrdNo, request.getOrdNo())) {
        // 現患者が後体重測定した患者と同じオーダーならば、通信サーバーに後体重測定信号を通知
        res = postSendAfterWeightWs(request.getOrdNo(), ntssUser.getFacilityCd());
      } else {
        // 装置状態の現患者が別のオーダーならば、次の治療が始まっているので通知しない
        res.isSuccess = true;
      }

      // 後体重測定時自動印刷
      try {
        AutoPrintResult printR = autoPrintService.reportAutoPrint(request.getOrdNo(), TimingEnum.afterWeight,
          ntssUser.getUserId(), ntssUser.getUsername());
        res.isAutoPrint = printR.isAutoPrint;
        res.isSuccessAutoPrint = printR.isSuccessAutoPrint;
        res.autoPrintErrorMessage = printR.autoPrintErrorMessage;
      } catch (Exception ex) {
        res.isAutoPrint = true;
        res.isSuccessAutoPrint = false;
        res.autoPrintErrorMessage = "帳票自動印刷失敗";
      }
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.OK);

    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (ntssUser != null && ntssUser.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
      res.errorMessage = e.getMessage();
      return new ResponseEntity<>(res, HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 後体重測定をデバイスエッジにリクエストする
   *
   * @param ordNo
   * @return
   */
  private SendConditionResponse postSendAfterWeightWs(Long ordNo, String facilityCd) {

    SendConditionResponse res = new SendConditionResponse();
    try {
      // #10457 2024.06.18 mod デバイスエッジに通知タイミングで現患者クリアを実施 TDC高村 start
      // // 条件からベッドコードを取得し、ベッドコードから装置を取得し、デバイスエッジ番号を取得
      // MstMachine machine = weightService.getMachineByOrderRst(ordNo);
      // if (machine == null) {
      //   res.isSuccess = false;
      //   res.errorMessage = "通知先装置の特定失敗";
      //  return res;
      // }
      //
      // String topic = PayloadBuilder.BuildWeightTopic(WebSocketTopic.ComSv.AFTER_WEIGHT, facilityCd,
      //   machine.getDeviceEdgeNo());
      //
      // String payload = machine.getMachineNo().toString();
      //
      // // EdgeあてにWebsocket通知
      // if (sendWsMsg.sendMsg(SendTarget.main, facilityCd, machine.getDeviceEdgeNo(), topic, payload)) {
      //   res.isSuccess = true;
      // } else {
      //   res.isSuccess = false;
      //   res.errorMessage = "通信サーバーへの通知失敗";
      // }
      //　施設コード及びオーダ番号に該当する装置状態管理を取得
      List<MntMachineState> mntMachineStateList = mntMachineStateDao.selectByOrdNo(facilityCd, ordNo);
      // 装置状態管理がない場合
      if (mntMachineStateList.isEmpty()) {
        res.isSuccess = false;
        res.errorMessage = "通知先装置の特定失敗";
        return res;
      }

      // デバイスエッジ番号を取得する為のリクエスト情報を作成
      DeviceEdgeOrderRequest deviceEdgeOrderRequest = new DeviceEdgeOrderRequest();
      deviceEdgeOrderRequest.setDeviceEdgeNo(null);
      deviceEdgeOrderRequest.setOrdNo(ordNo);
      deviceEdgeOrderRequest.setMachineNo(null);
      deviceEdgeOrderRequest.setFacilityCd(facilityCd);

      // 不足している情報を補填
      DeviceEdgeOrderRequest targetInfo = deviceEdgeOrderService.findMissingData(deviceEdgeOrderRequest);

      MstMachine mstMachine = mstMachineDao.selectByMachineNo(targetInfo.getMachineNo());
      MstComsvSetting mstComsv = mstComsvSettingDao.selectByCd(facilityCd, mstMachine.getDeviceEdgeNo());
      if (mstComsv.getPatTiming().equals("0")) {
        // 現患者クリア処理実施
        Timestamp upDate = new Timestamp(System.currentTimeMillis());
        int retCnt = mntMachineStateDao.updateCurrentPatClear(facilityCd, mstMachine.getMachineTypeCd(), mstMachine.getMachineSerial(), upDate);
        if (1 != retCnt) {
          // 処理件数が1件でない場合は失敗
          res.isSuccess = false;
          res.errorMessage = "現患者クリア処理失敗";
          return res;
        }
      }
      DeviceEdgeOrderResponse afterWeightResponse =
        deviceEdgeOrderService.orderAfterWeight(facilityCd, mstMachine.getDeviceEdgeNo(), mstMachine.getMachineNo());
      res.isSuccess = false;
      if (!Objects.isNull(afterWeightResponse)) {
        res.isSuccess = afterWeightResponse.isSuccess;
      }
      if (!res.isSuccess) {
        res.errorMessage = "通信サーバーへの通知失敗";
      }
      // #10457 2024.06.18 mod デバイスエッジに通知タイミングで現患者クリアを実施 TDC高村 end
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (facilityCd != null) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
      res.isSuccess = false;
      res.errorMessage = e.getMessage();
    }
    return res;
  }

  /**
   * 指定したpat_idの体重履歴モーダル情報を取得
   *
   * @param facilityCd
   * @param patId
   * @param previousWeightSourceClass
   * @return
   */
  @GetMapping("history/{facilityCd}/{patId}/{treatDate}/{previousWeightSourceClass}")
  public ResponseEntity<?> getWeighthistoryInfo(
    @PathVariable String facilityCd,
    @PathVariable Long patId,
    @PathVariable String treatDate,
    @PathVariable Integer previousWeightSourceClass) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.WEIGHT + "/history";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, facilityCd,
      patId);
    // wp アプリケーションログの適正化 Add End

    try {
      // マーカー情報取得
      List<WeighthistoryResponse> weighthistoryinfo = weightService.getWeighthistoryInfo(facilityCd, patId, treatDate,
        previousWeightSourceClass);
      // エラーがない場合、得られた情報を返す
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(weighthistoryinfo, HttpStatus.OK);
    } catch (Exception e) {
      // エラーの場合
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("REST request error by get getWeighthistoryInfo : " + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(e.getMessage(), HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * レシート印刷用の検査結果を取得する
   *
   * @param ntssUser   サインインユーザー情報
   * @param patId      患者ID
   * @param baseDate   透析日YYYYMMDD
   * @param itemCdList 取得検査項目コードリスト
   * @return
   */
  // FNSI-add redmine4656 徐 start
//  @GetMapping("/pat-exam/print/{patId}/{baseDate}/{itemCdList}")
//  public ResponseEntity<?> fetchExamInfoForPrinter(
//    @AuthenticationPrincipal NtssUser ntssUser,
//    @PathVariable Long patId,
//    @PathVariable String baseDate,
  //    @PathVariable List<String> itemCdList) {
  @PostMapping("/pat-exam/print")
  public ResponseEntity<?> fetchExamInfoForPrinter(
    @RequestBody PatExamPrintRequest request,
    @AuthenticationPrincipal NtssUser ntssUser) {
    // FNSI-add redmine4656 徐 end
    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.WEIGHT + "/pat-exam/print";
//    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
//      patId);
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      request.getPatId());
    // wp アプリケーションログの適正化 Add End

    EventLogMessage eventLogMessage = new EventLogMessage();
    try {
//      eventLogMessage.setLogMessage("REST request by get fetchExamInfoForPrinter : " + patId);
//      eventLogMessage.setPatId(String.valueOf(patId));
//      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);

      // FNSI-add redmine4656 徐 start
//      List<PatExamMainWeightPrint> res = weightService.fetchExamForPrint(ntssUser.getFacilityCd(), patId, baseDate,
//        itemCdList);
      List<PatExamMainWeightPrint> res = weightService.fetchExamForPrint(ntssUser.getFacilityCd(), request.getPatId(), request.getBaseDate(),
        request.getItemCdList());
      // FNSI-add redmine4656 徐 end

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(res, HttpStatus.OK);

    } catch (Exception e) {
      // エラーの場合
      eventLogMessage.setLogMessage("REST request error by get fetchExamInfoForPrinter : " + e.getMessage());
      // FNSI-add redmine4656 徐 start
//      eventLogMessage.setPatId(String.valueOf(patId));
      eventLogMessage.setPatId(String.valueOf(request.getPatId()));
      // FNSI-add redmine4656 徐 end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(e.getMessage(), HttpStatus.BAD_REQUEST);
    }
  }

  // add 2020-08-08 FNSI-仕様追加 カード読み込み時にIdmでカード有効無効なチェック処理 夏 start

  /**
   * カードIDM取得取得
   *
   * @param facilityCd 施設コード
   * @param hospPatId  患者ID
   * @return
   */
  @GetMapping("/card_idm/{facilityCd}/{hospPatId}")
  public ResponseEntity<?> getCardIdm(@PathVariable String facilityCd, @PathVariable String hospPatId) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.WEIGHT + "/card_idm";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      hospPatId);
    // wp アプリケーションログの適正化 Add End
    try {
      HashMap<String, String> data = new HashMap<>();
      Long patId = patPersonalMainDao.selectPatIdByHospPatId(facilityCd, hospPatId);
      String cardIdm = "";
      if (patId != null) {
        cardIdm = weightService.getCardIdm(patId);
      }
      data.put("cardIdmValue", cardIdm);
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(data, HttpStatus.OK);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("REST request error by get getCardIdm : " + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(e.getMessage(), HttpStatus.BAD_REQUEST);
    }
  }
  // add 2020-08-08 FNSI-仕様追加 カード読み込み時にIdmでカード有効無効なチェック処理 夏 end


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
  // add 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 start
  private void saveNotiMessage(JSONObject jsonBody){
    try {
      URI uri = new URI(webApi);
      RestTemplate rt = new RestTemplate();
      RequestEntity<String> request = RequestEntity
        .post(uri)
        .contentType(MediaType.APPLICATION_JSON)
        // .header(SEC_HEADER_NAME, SEC_HEADER_VALUE)
        .header("SSECCAYEK", "NTSS-NKK-ESM-TDC-YSK")
        .body(jsonBody.toString());
	  // #9698 アプリケーションログの内容修正 20260328 mod yangxuewang start
      long start = System.currentTimeMillis();
      // リクエスト処理
      ResponseEntity<String> response = rt.exchange(request, String.class);
      long cost = System.currentTimeMillis() - start;
      Map<String, Object> map = new HashMap<>();
      map.put("logType", "RESTTEMPLATE-LOG");
      map.put("className", "jp.co.nikkiso.ntss.admin_web.web.rest.TreatmentRecordResource");
      map.put("methodName", "saveNotiMessage");
      map.put("method", request.getMethod());
      map.put("url", request.getUrl());
      map.put("headers", request.getHeaders().toSingleValueMap());
      map.put("requestParameter", request.getBody());
      map.put("status",response.getStatusCode());
      map.put("cost", cost);
      map.put("result",response.getBody());
      EventLogMessage restTemplateEventLogMessage = new EventLogMessage();
      restTemplateEventLogMessage.setLogMessage(toJson(map));
      logService.log(LogLevel.INFO, restTemplateEventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9698 アプリケーションログの内容修正 20260328 mod yangxuewang end
    }catch (URISyntaxException ureE){
      EventLogMessage eventLogMessage = new EventLogMessage();
      logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
    }

  }
  // add 5622 条件送信の送信ボタン押下後に画面が戻るまでに10秒以上かかる。 吉 end

  // add #7524 2022/11/10 同日同クールで同時に透析治療が実施できてしまう dou start
  /**
   * 同一患者同一治療日同一クールのチェック判断
   *
   * @param ordNo
   * @return
   */
  @GetMapping("order/hasSameOrd/{ordNo}")
  public ResponseEntity<?> hasSameOrd(@PathVariable Long ordNo) {
    // 同患者，同日，同クールでの治療は，透析＋特殊浄化または特殊浄化＋特殊浄化のみ許可している。透析＋透析は許可していない。
    String mappingUrl = Uri.WEIGHT + "/order/hasSameOrd";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      ordNo);

    Boolean response = false;
    OrdMain ordMain = ordMainDao.selectByOrdNo(ordNo);
    Integer ordCount = ordMainDao.checkSameOrd(ordMain.getPatId(), ordMain.getTreatDate(), ordMain.getIndKurCd());
    if (ordCount > 1) {
      response = true;
    }

    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      ordNo);
    return new ResponseEntity<>(response, HttpStatus.OK);
  }
  // add #7524 2022/11/10 同日同クールで同時に透析治療が実施できてしまう dou end

  // add #9616 帳票印刷失敗通知がされない 高 2024/01/25　start
  /**
   * 400および117からReportCdでReportNameを取ります。(前体重、後体重)
   *
   * @param rstTreatmentCd
   * @param mr
   * @param ntssUser
   * @return 帳票名です.
   *
   * */
  private String autoPrintGetReportName(String rstTreatmentCd,MstReport mr,NtssUser ntssUser,  TimingEnum timing){
    boolean getReportNameFlag = true;
    String reportName = "";
    try {
      if(!StringUtils.isEmpty(rstTreatmentCd)){
        getReportNameFlag = true;
        MstTreatment mstTreatment = mstTreatmentDao.selectByCd(Integer.valueOf(rstTreatmentCd));
        if (!StringUtils.isEmpty(mstTreatment.getReportIdBw()) || !StringUtils.isEmpty(mstTreatment.getReportIdAw())) {
          // 400
          // 前体重ReportName取得します。
          if (timing.equals(TimingEnum.beforeWeight)) {
            mr = mstReportDao.selectByCd((long) mstTreatment.getReportIdBw());
          }
          // 後体重ReportName取得します。
          else if (timing.equals(TimingEnum.afterWeight)) {
            mr = mstReportDao.selectByCd((long) mstTreatment.getReportIdAw());
          }
        } else {
          // 117
          getReportNameFlag = false;
          FacilitySettingInfo facilitySettingInfo = mstFacilitySettingDao.getBySettingNoAndCd(ntssUser.getFacilityCd(), CoreConstant.FacilitySettingNo.DEFAULT_REPORT_TEMPLATE);
          if (!StringUtils.isEmpty(facilitySettingInfo.getValue())) {
            Long reportCd = Long.parseLong(facilitySettingInfo.getValue());
            if (reportCd != 0) {
              mr = mstReportDao.selectByCd(reportCd);
            }
          }
        }
      }
    } catch (Exception ex) {
      // 400 -> errorの場合
      if (getReportNameFlag) {
        try {
          // 117
          FacilitySettingInfo facilitySettingInfo = mstFacilitySettingDao.getBySettingNoAndCd(ntssUser.getFacilityCd(), CoreConstant.FacilitySettingNo.DEFAULT_REPORT_TEMPLATE);
          if (!StringUtils.isEmpty(facilitySettingInfo.getValue())) {
            Long reportCd = Long.parseLong(facilitySettingInfo.getValue());
            if (reportCd != 0) {
              mr = mstReportDao.selectByCd(reportCd);
            }
          }
        } catch (Exception ex1){
        }
      }
    } finally {
      if (!StringUtils.isEmpty(mr) && !StringUtils.isEmpty(mr.getReportName())) {
        reportName = mr.getReportName();
      }
    }
    return reportName;
  }

  /**
   * 失敗通知を送ります.
   *
   * @param reportName
   * @param ntssUser
   *
   * */
  private void sendFailureNotification(String reportName,NtssUser ntssUser){
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
    JSONObject replaceData = new JSONObject();
    replaceData.put("REPORTTYPE", "治療経過表");
    replaceData.put("REPORTNAME", reportName);
    replaceData.put("UP_DATE", sdf.format(new Date()));
    JSONObject jsonBody = new JSONObject();
    jsonBody.put("notificationNo", CoreConstant.NotificationDefinition.PRINT_FAIL);
    jsonBody.put("facilityCd", ntssUser.getFacilityCd());
    // 変換用文字列のエンコード処理(UTF-8)
    String base64replaceData = new String(Base64.getEncoder().encode(replaceData.toString().getBytes(StandardCharsets.UTF_8)), StandardCharsets.UTF_8);
    jsonBody.put("replaceData", base64replaceData);
    saveNotiMessage(jsonBody);
  }
  // add #9616 帳票印刷失敗通知がされない 高 2024/01/25　end
}
