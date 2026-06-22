package jp.co.nikkiso.ntss.admin_web.web.rest;

import java.util.List;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant;
import jp.co.nikkiso.ntss.admin_web.request.weight.ChangedMstWeightNotifyRequest;
import jp.co.nikkiso.ntss.admin_web.request.weight.WeightStateRequest;
import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.admin_web.service.webSocketNotify.PayloadBuilder;
import jp.co.nikkiso.ntss.admin_web.service.webSocketNotify.WebSocketNotifyService;
import jp.co.nikkiso.ntss.core.dao.MstWeightDao;
import jp.co.nikkiso.ntss.core.dao.MstWeightScaleDao;
import jp.co.nikkiso.ntss.core.dao.MstWheelChairDao;
import jp.co.nikkiso.ntss.core.dao.PatMainDao;
import jp.co.nikkiso.ntss.core.entity.MstWheelChair;
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
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebMessage;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.FUNCTION_CODE;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.admin_web.request.masterMaintenance.MasterUpdateRequest;
import jp.co.nikkiso.ntss.admin_web.response.masterMaintenance.MasterDataResponse;
import jp.co.nikkiso.ntss.admin_web.response.masterMaintenance.MasterUpdateResponse;
import jp.co.nikkiso.ntss.admin_web.response.wheelChair.WheelChairWithNameResponse;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.PersonalUserService;
import jp.co.nikkiso.ntss.admin_web.service.master.weight.MstWeightService;
import jp.co.nikkiso.ntss.admin_web.service.master.wheelChair.MstWheelChairService;
import jp.co.nikkiso.ntss.admin_web.service.access.FacilityAccessService;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.entity.MstWeight;
import jp.co.nikkiso.ntss.core.entity.MstWeightScale;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import lombok.extern.slf4j.Slf4j;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_ERROR;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;
import jp.co.nikkiso.ntss.core.utils.InvestigateLogUtils;

@RestController
@Slf4j
@RequestMapping(Uri.WEIGHT_SETTING)
public class WeightSettingResource {

  @Autowired
  MstWeightService mstWeightService;
  @Autowired
  MstWheelChairService mstWheelChairSerive;
  @Autowired
  LogService logService;
  @Autowired
  PersonalUserService personalUserService;

  // wp アプリケーションログの適正化 Add Start
  @Autowired
  LogEventUtils logEventUtils;
  @Autowired
  private FacilityAccessService facilityAccessService;

  // wp アプリケーションログの適正化 Add End
  // #11987 2026.05.08 add 体重計マスタの変更をアプリに通知 TDC片口 start
  @Autowired
  WebSocketNotifyService sendWsMsg;
  // #11987 2026.05.08 add 体重計マスタの変更をアプリに通知 TDC片口 end
  // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
  @Autowired
  MstWeightScaleDao mstWeightScaleDao;
  @Autowired
  MstWheelChairDao mstWheelChairDao;
  @Autowired
  MstWeightDao mstWeightDao;
  @Autowired
  PatMainDao patMainDao;
  // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end


  @GetMapping("/users/{viewMode}")
  public ResponseEntity<?> getPersonalUsersInfo(
      @PathVariable short viewMode,
      @AuthenticationPrincipal NtssUser ntssUser) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.WEIGHT_SETTING + "/users";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      viewMode);
    // wp アプリケーションログの適正化 Add End

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      viewMode);
    // wp アプリケーションログの適正化 Add End

//    EventLogMessage eventLogMessage = new EventLogMessage();
//    eventLogMessage.setLogMessage("REST request to getPersonalUsersInfo");
//    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    return new ResponseEntity<>(personalUserService.getAllUserWithDel(ntssUser.getFacilityCd(), viewMode), HttpStatus.OK);
  }

  // add マスタ一覧 1･施設切替を可能とする 孔 start
  @GetMapping("/users/{viewMode}/{facilityCd}")
  public ResponseEntity<?> getPersonalUsersInfoByFacilityCd(
      @PathVariable short viewMode,
      @PathVariable String facilityCd) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.WEIGHT_SETTING + "/users";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, facilityCd,
      viewMode);
    // wp アプリケーションログの適正化 Add End

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, facilityCd,
      viewMode);
    // wp アプリケーションログの適正化 Add End

//    EventLogMessage eventLogMessage = new EventLogMessage();
//    eventLogMessage.setLogMessage("REST request to getPersonalUsersInfo");
//    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    return new ResponseEntity<>(personalUserService.getAllUserWithDel(facilityCd, viewMode), HttpStatus.OK);
  }
  // add マスタ一覧 1･施設切替を可能とする 孔 end


  @GetMapping("/wheel_chair/find/{facilityCd}")
  public ResponseEntity<?> getWheelChairByFacilityCd(
      @PathVariable String facilityCd) {
    // 施設の車いす情報を取得

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.WEIGHT_SETTING + "/wheel_chair/find";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, facilityCd,
      null);
    // wp アプリケーションログの適正化 Add End

    List<WheelChairWithNameResponse> chair = mstWheelChairSerive.getWheelChairList(facilityCd);

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, facilityCd,
      null);
    // wp アプリケーションログの適正化 Add End

    return new ResponseEntity<>(chair, HttpStatus.OK);
  }

  /**
   * 車いすマスタ取得(削除済み含む).
   *
   * @param facilityCd 施設コード
   * @return
   */
  @GetMapping("/wheel_chair/find_all/{facilityCd}")
  public ResponseEntity<?> getWheelChairAllByFacilityCd(
      @PathVariable String facilityCd,
      @RequestParam(required = false) Long selectedPatId,
    @AuthenticationPrincipal NtssUser ntssUser) {
    if (!facilityAccessService.hasFacilityOrSelectedPatShareAccess(ntssUser, facilityCd, selectedPatId)) {
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
    }


    // 施設の車いす情報を取得(削除済み含む)
    String mappingUrl = Uri.WEIGHT_SETTING + "/wheel_chair/find_all";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, facilityCd,
      null);

    List<WheelChairWithNameResponse> chair = mstWheelChairSerive.getWheelChairAllList(facilityCd);

    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, facilityCd,
      null);

    return new ResponseEntity<>(chair, HttpStatus.OK);
  }

  @GetMapping("/wheel_chair/get/{wheelChairCd}")
  public ResponseEntity<?> getWheelChairByCd(
      @PathVariable Long wheelChairCd) {
    // 車いす情報を取得

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.WEIGHT_SETTING + "/wheel_chair/get";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      wheelChairCd);
    // wp アプリケーションログの適正化 Add End

    WheelChairWithNameResponse chair = mstWheelChairSerive.getWheelChair(wheelChairCd);


    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      wheelChairCd);
    // wp アプリケーションログの適正化 Add End

    return new ResponseEntity<>(chair, HttpStatus.OK);
  }

  @GetMapping("/wheel_chair/personal/{patId}")
  public ResponseEntity<?> getWheelChairByPatId(
      @PathVariable Long patId,
      @AuthenticationPrincipal NtssUser ntssUser) {
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260512 start
    if (!hasPatAccess(ntssUser, patId)) {
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
    }
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260512 end
    // 車いす情報を取得

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.WEIGHT_SETTING + "/wheel_chair/personal";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      patId);
    // wp アプリケーションログの適正化 Add End

    List<WheelChairWithNameResponse> chair = mstWheelChairSerive.getWheelChairListByPatId(patId, ntssUser.getFacilityCd());


    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      patId);
    // wp アプリケーションログの適正化 Add End

    return new ResponseEntity<>(chair, HttpStatus.OK);
  }

  @GetMapping("/scale/get-edit-data")
  public ResponseEntity<?> getMasterData(@AuthenticationPrincipal NtssUser ntssUser) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.WEIGHT_SETTING + "/scale/get-edit-data";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

//    // ログ出力
//    EventLogMessage eventLogMessage = new EventLogMessage();
//    eventLogMessage.setLogMessage("REST request to get master : mst_weight_scale");
//    logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);

    try {
      // レスポンス生成
      MasterDataResponse response = mstWeightService.getMasterData("mst_weight_scale", ntssUser.getFacilityCd());

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
        null);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(response, HttpStatus.OK);

    } catch (Exception e) {

      // マスタ定義が取得できなかった場合
//      eventLogMessage.setLogMessage("Exception message : "+ e.getMessage());
//      logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, null, e.getMessage());
      // wp アプリケーションログの適正化 Add End

      return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.MASTER_RECORD_ERROR.getMessage()),
          HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  // add マスタ一覧 1･施設切替を可能とする 孔 start
  @GetMapping("/scale/get-edit-data/{facilityCd}")
  public ResponseEntity<?> getMasterDataByFacilityCd(@PathVariable String facilityCd,
                                                     @RequestParam(required = false) Long selectedPatId,
    @AuthenticationPrincipal NtssUser ntssUser) {
    if (!facilityAccessService.hasFacilityOrSelectedPatShareAccess(ntssUser, facilityCd, selectedPatId)) {
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
    }



    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get master : mst_weight_scale");
    logService.log(LogLevel.DEBUG, eventLogMessage, "", SERVICE_NAME.FNSI, null);

    try {
      // レスポンス生成
      MasterDataResponse response = mstWeightService.getMasterData("mst_weight_scale", facilityCd);
      return new ResponseEntity<>(response, HttpStatus.OK);

    } catch (Exception e) {

      // マスタ定義が取得できなかった場合
      eventLogMessage.setLogMessage("Exception message : " + e.getMessage());
      logService.log(LogLevel.DEBUG, eventLogMessage, "", SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.MASTER_RECORD_ERROR.getMessage()),
        HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }
  // add マスタ一覧 1･施設切替を可能とする 孔 end

  /**
   * 体重測定マスタデータ更新.
   *
   * @param request    マスタデータ更新のrequest
   * @param ntssUser   NTSS認証ユーザー
   * @return
   */
  @PutMapping("/scale/put-edit-data")
  public ResponseEntity<?> updateMasterData(
      @RequestBody MasterUpdateRequest request, @AuthenticationPrincipal NtssUser ntssUser) {

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to update records :  mst_weight_scale");
    logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);

    try {
      // 更新処理
      MasterUpdateResponse response = mstWeightService.updateMasterData("mst_weight_scale", ntssUser.getFacilityCd(),
          request.getData());
      return new ResponseEntity<>(response, HttpStatus.OK);

    } catch (Exception e) {

      // 更新処理ができなかった場合
      eventLogMessage.setLogMessage("Exception message : "+ e.getMessage());
      logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage()),
          HttpStatus.BAD_REQUEST);
    }
  }


  // add マスタ一覧 1･施設切替を可能とする 孔 start
  @PutMapping("/scale/put-edit-data/{facilityCd}")
  public ResponseEntity<?> updateMasterDataByFacilityCd(
      @RequestBody MasterUpdateRequest request, @PathVariable String facilityCd, @AuthenticationPrincipal NtssUser ntssUser) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    if(!ntssUser.isNkkAdminUser()) {
      if (!ntssUser.getFacilityCd().equals(facilityCd)) {
        // #11205 mod 20260421 start
        InvestigateLogUtils.info("WeightSettingResource.updateMasterDataByFacilityCd", "facilityCd=" + facilityCd + ", ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd());
        return new ResponseEntity<>(HttpStatus.FORBIDDEN);
        // #11205 mod 20260421 end
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to update records :  mst_weight_scale");
    logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);

    try {
      // 更新処理
      MasterUpdateResponse response = mstWeightService.updateMasterData("mst_weight_scale", facilityCd,
          request.getData());
      return new ResponseEntity<>(response, HttpStatus.OK);

    } catch (Exception e) {

      // 更新処理ができなかった場合
      eventLogMessage.setLogMessage("Exception message : "+ e.getMessage());
      logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage()),
          HttpStatus.BAD_REQUEST);
    }
  }
  // add マスタ一覧 1･施設切替を可能とする 孔 end


  @GetMapping("/scale/get/{facilityCd}")
  public ResponseEntity<?> getWeightScaleByFacilityCd(
      @PathVariable String facilityCd) {
    // 施設の体重計情報を取得

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.WEIGHT_SETTING + "/scale/get";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, facilityCd,
      null);
    // wp アプリケーションログの適正化 Add End

    MstWeightScale weight = mstWeightService.mstWeightScaleSelectByFacility(facilityCd);

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, facilityCd,
      null);
    // wp アプリケーションログの適正化 Add End

    return new ResponseEntity<>(weight, HttpStatus.OK);
  }

  /**
   * 項目更新
   * @param request
   * @return
   */
  @PutMapping("/scale/update")
  public ResponseEntity<?> postScaleUpdate(
    @RequestBody MstWeightScale request, @AuthenticationPrincipal NtssUser ntssUser) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    if(!ntssUser.isNkkAdminUser()) {
      MstWeightScale mstWeightScale = mstWeightScaleDao.selectByWeightScaleCd(request.getWeightScaleCd());
      if (mstWeightScale != null && !ntssUser.getFacilityCd().equals(mstWeightScale.getFacilityCd())) {
        // #11205 mod 20260421 start
        InvestigateLogUtils.info("WeightSettingResource.postScaleUpdate", "weightScaleCd=" + request.getWeightScaleCd() + ", mstWeightScale.getFacilityCd()=" + mstWeightScale.getFacilityCd() + ", ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd());
        return new ResponseEntity<>(HttpStatus.FORBIDDEN);
        // #11205 mod 20260421 end
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
    try {
      int r = mstWeightService.mstWeightScaleUpdate(request);
      if (r > 0) {
        return new ResponseEntity<>(request, HttpStatus.OK);
      } else {
        return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
      }
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (ntssUser != null && ntssUser.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * 項目追加
   * @param request
   * @return
   */
  @PostMapping("/scale/insert")
  public ResponseEntity<?> postScaleInsert(
      @RequestBody MstWeightScale request,
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
      @AuthenticationPrincipal NtssUser ntssUser
      // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
  ) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
    if(!ntssUser.isNkkAdminUser()) {
      if (request.getFacilityCd() != null && !request.getFacilityCd().equals(ntssUser.getFacilityCd())) {
        // #11205 mod 20260421 start
        InvestigateLogUtils.info("WeightSettingResource.postScaleInsert", "request.getFacilityCd()=" + request.getFacilityCd() + ", ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd());
        return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
        // #11205 mod 20260421 end
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
    try {
      int r = mstWeightService.mstWeightScaleInsert(request);
      if (r > 0) {
        return new ResponseEntity<>(request, HttpStatus.OK);
      } else {
        return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
      }
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (ntssUser != null && ntssUser.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  @GetMapping("/weight/find/{facilityCd}")
  public ResponseEntity<?> getWeightByFacility(
      @PathVariable String facilityCd) {
    // 施設の体重計情報を取得

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.WEIGHT_SETTING + "/weight/find";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, facilityCd,
      null);
    // wp アプリケーションログの適正化 Add End

    List<MstWeight> list = mstWeightService.mstWeightSelectByFacilityCd(facilityCd);


    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, facilityCd,
      null);
    // wp アプリケーションログの適正化 Add End

    return new ResponseEntity<>(list, HttpStatus.OK);
  }

  @GetMapping("/weight/get/{weightCd}")
  public ResponseEntity<?> getWeightByScaleCd(
      @PathVariable Long weightCd) {
    // 施設の体重計情報を取得

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.WEIGHT_SETTING + "/weight/get";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      weightCd);
    // wp アプリケーションログの適正化 Add End

    MstWeight weight = mstWeightService.mstWeightSelectByScaleCd(weightCd);


    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      weightCd);
    // wp アプリケーションログの適正化 Add End

    return new ResponseEntity<>(weight, HttpStatus.OK);
  }

  @GetMapping("/weight/get2/{facilityCd}/{weightNo}")
  public ResponseEntity<?> getWeightByFacilityWeightNo(
      @PathVariable String facilityCd,
      @PathVariable Integer weightNo) {
    // 施設の体重計情報を取得

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.WEIGHT_SETTING + "/weight/get";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, facilityCd,
      weightNo);
    // wp アプリケーションログの適正化 Add End



    MstWeight weight = mstWeightService.mstWeightSelectByFacilityCdWeightNo(facilityCd, weightNo);


    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, facilityCd,
      weightNo);
    // wp アプリケーションログの適正化 Add End

    return new ResponseEntity<>(weight, HttpStatus.OK);
  }

  @GetMapping("/exam/find")
  public ResponseEntity<?> getExamMaster(@AuthenticationPrincipal NtssUser ntssUser) {

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("CALL REST API find mst-exam-item :" + ntssUser.getFacilityCd());
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    return new ResponseEntity<>(mstWeightService.fetchMstExamItemList(ntssUser.getFacilityCd()), HttpStatus.OK);
  }

  // add マスタ一覧 1･施設切替を可能とする 孔s start
  @GetMapping("/exam/find/{facilityCd}")
  public ResponseEntity<?> getExamMasterByFacilityCd(@PathVariable String facilityCd) {

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("CALL REST API find mst-exam-item :" + facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    return new ResponseEntity<>(mstWeightService.fetchMstExamItemList(facilityCd), HttpStatus.OK);
  }
  // add マスタ一覧 1･施設切替を可能とする 孔s end

  // #11987 2025.12.16 add スケールベッド対応 ベッドマスター取得 TDC渡辺 start
  @GetMapping("/bed/find/{facilityCd}")
  public ResponseEntity<?> getBedMasterByFacilityCd(@PathVariable String facilityCd) {

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("CALL REST API find mst-bed-item :" + facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    return new ResponseEntity<>(mstWeightService.fetchMstBedList(facilityCd), HttpStatus.OK);
  }
  // #11987 2025.12.16 add スケールベッド対応 ベッドマスター取得 TDC渡辺 end

  // #11987 2026.05.08 add 体重計マスタの変更をアプリに通知 TDC片口 start
  /**
   * 体重計マスタの変更をwebsocketでアプリに通知する
   * @param facilityCd 施設コード
   * @param request { weightNoList:体重計番号 }
   * @return
   */
  @PostMapping("/notify-change/{facilityCd}")
  public ResponseEntity<?> postNotifyChange(@PathVariable String facilityCd, @RequestBody ChangedMstWeightNotifyRequest request) {

    String mappingUrl = Uri.WEIGHT_SETTING + "/notify-change";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, facilityCd,null);

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setFacilityCd(facilityCd);
    try {
      for(Integer weightNo : request.getWeightNoList()) {
        String topic = PayloadBuilder.BuildWeightTopic(AdminWebConstant.WebSocketTopic.WeightState.MST_CHANGED, facilityCd, weightNo);

        // 体重計アプリにWebsocket通知
        boolean bRes = sendWsMsg.sendMsg(WebSocketNotifyService.SendTarget.weightApp, facilityCd, weightNo, topic, "");
        eventLogMessage.setLogMessage("Notify weight master change to weightApp. topic: " + topic + ", sendResult: " + bRes);
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      }

      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, facilityCd,null);

      return new ResponseEntity<>(HttpStatus.OK);
    } catch (Exception e) {
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_ERROR, mappingUrl, facilityCd, e.getMessage());
      return new ResponseEntity<>(new MasterUpdateResponse("マスタ更新通知に失敗しました"), HttpStatus.BAD_REQUEST);
    }
  }
  // #11987 2026.05.08 add 体重計マスタの変更をアプリに通知 TDC片口 end

  @GetMapping("/wheel_chair/check/calibration/{facilityCd}/{wheelChairCd}")
  public ResponseEntity<?> checkCalibrationByCd(
      @PathVariable String facilityCd,
      @PathVariable Long wheelChairCd,
      @AuthenticationPrincipal NtssUser ntssUser
  ) {
    if (!hasFacilityAccess(ntssUser, facilityCd)) {
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
    }
    // 校正切れ判定
    String mappingUrl = Uri.WEIGHT_SETTING + "/wheel_chair/check/calibration";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, facilityCd, wheelChairCd);

    Boolean check = mstWheelChairSerive.WheelChairCalibrationCheck(facilityCd, wheelChairCd);

    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, facilityCd, wheelChairCd);
    return new ResponseEntity<>(check, HttpStatus.OK);
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
  private boolean hasFacilityAccess(NtssUser ntssUser, String facilityCd) {
    boolean hasAccess = ntssUser == null
      || ntssUser.isNkkAdminUser()
      || facilityCd == null
      || facilityCd.equals(ntssUser.getFacilityCd());
    // #11205 mod 20260421 start
    if (!hasAccess) {
      InvestigateLogUtils.info("WeightSettingResource.hasFacilityAccess", "facilityCd=" + facilityCd + ", ntssUser.getFacilityCd()=" + (ntssUser != null ? ntssUser.getFacilityCd() : "null"));
    }
    // #11205 mod 20260421 end
    return hasAccess;
  }

  private boolean hasPatAccess(NtssUser ntssUser, Long patId) {
    if (ntssUser == null || patId == null) {
      return false;
    }
    return ntssUser.isNkkAdminUser() || patMainDao.countByPatIdAndFacilityCd(patId, ntssUser.getFacilityCd()) > 0;
  }

  private boolean hasWheelChairAccess(NtssUser ntssUser, Long wheelChairCd) {
    if (ntssUser == null || ntssUser.isNkkAdminUser() || wheelChairCd == null) {
      return true;
    }
    MstWheelChair mstWheelChair = mstWheelChairDao.selectByWheelChairCd(wheelChairCd, "0", "0");
    boolean hasAccess = mstWheelChair == null || mstWheelChair.getFacilityCd() == null
      || mstWheelChair.getFacilityCd().equals(ntssUser.getFacilityCd());
    // #11205 mod 20260421 start
    if (!hasAccess) {
      String wheelchairFacilityCd = (mstWheelChair != null && mstWheelChair.getFacilityCd() != null) ? mstWheelChair.getFacilityCd() : "null";
      InvestigateLogUtils.info("WeightSettingResource.hasWheelChairAccess", "wheelChairCd=" + wheelChairCd + ", mstWheelChair.getFacilityCd()=" + wheelchairFacilityCd + ", ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd());
    }
    // #11205 mod 20260421 end
    return hasAccess;
  }

  private boolean hasWeightAccess(NtssUser ntssUser, Long weightCd) {
    if (ntssUser == null || ntssUser.isNkkAdminUser() || weightCd == null) {
      return true;
    }
    MstWeight mstWeight = mstWeightDao.selectByWeightCd(weightCd);
    boolean hasAccess = mstWeight == null || mstWeight.getFacilityCd() == null
      || mstWeight.getFacilityCd().equals(ntssUser.getFacilityCd());
    // #11205 mod 20260421 start
    if (!hasAccess) {
      String weightFacilityCd = (mstWeight != null && mstWeight.getFacilityCd() != null) ? mstWeight.getFacilityCd() : "null";
      InvestigateLogUtils.info("WeightSettingResource.hasWeightAccess", "weightCd=" + weightCd + ", mstWeight.getFacilityCd()=" + weightFacilityCd + ", ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd());
    }
    // #11205 mod 20260421 end
    return hasAccess;
  }
}
