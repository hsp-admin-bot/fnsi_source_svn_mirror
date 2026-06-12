package jp.co.nikkiso.ntss.admin_web.web.rest;

import tools.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebMessage;
import jp.co.nikkiso.ntss.admin_web.constant.MstToMongoEnum;
import jp.co.nikkiso.ntss.admin_web.request.masterMaintenance.MasterUpdateRequest;
import jp.co.nikkiso.ntss.admin_web.response.masterMaintenance.MasterDataResponse;
import jp.co.nikkiso.ntss.admin_web.response.masterMaintenance.MasterListResponse;
import jp.co.nikkiso.ntss.admin_web.response.masterMaintenance.MasterUpdateResponse;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.MongoService;
import jp.co.nikkiso.ntss.admin_web.service.OrdMainService;
import jp.co.nikkiso.ntss.admin_web.service.bloodPurify.MntMachineStateService;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.master.MasterEditService;
import jp.co.nikkiso.ntss.admin_web.service.master.MasterListService;
import jp.co.nikkiso.ntss.admin_web.service.nextpat.NextPatService;
import jp.co.nikkiso.ntss.admin_web.service.access.FacilityAccessService;
import jp.co.nikkiso.ntss.admin_web.web.rest.util.WebApiCallCommonUtil;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.FUNCTION_CODE;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.NextPatDao;
import jp.co.nikkiso.ntss.core.entity.MntMachineState;
import jp.co.nikkiso.ntss.core.entity.SysFacility;
import jp.co.nikkiso.ntss.core.entity.SysMasterDefine;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.OptimisticLockingFailureException;
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
//mod 6742 ダイアライザマスタにてKoAを編集して保存したところシステムエラー発生 関俊楠 start
import java.io.IOException;
//mod 6742 ダイアライザマスタにてKoAを編集して保存したところシステムエラー発生 関俊楠 end
import java.net.URISyntaxException;
import java.time.LocalDateTime;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.atomic.AtomicBoolean;

import static jp.co.nikkiso.ntss.core.dao.MasterMaintenanceGenericDao.OPERATION;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;
import jp.co.nikkiso.ntss.core.utils.InvestigateLogUtils;


/**
 * マスタマンテナンス画面のResourceクラス.
 */
@RestController
@Slf4j
@RequestMapping(Uri.MASTER_MAINTENANCE)
public class MasterMaintenanceResource {
  @Autowired
  private FacilityAccessService facilityAccessService;


  /**
   * マスタ一覧Service.
   */
  @Autowired
  private MasterListService masterListService;

  /**
   * マスタ編集Service.
   */
  @Autowired
  private MasterEditService masterEditService;

  @Autowired
  LogService logService;

  /**
   * 次患者Service.
   */
  @Autowired
  WebApiCallCommonUtil webApiCallCommonUtil;

  /**
   * 装置状態管理Service.
   */
  @Autowired
  MntMachineStateService mntMachineStateService;

  @Autowired
  OrdMainService ordMainService;

  //add #10412 次患者更新関連全体見直し対応 朴 start
  /**
   * 次患者更新関連
   */
  @Autowired
  private NextPatService nextPatService;

  //add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 zhaoqi 20240228 start
  @Autowired
  MongoService mongoService;
  //add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 zhaoqi 20240228 end

  @Autowired
  private NextPatDao nextPatDao;
  //add #10412 次患者更新関連全体見直し対応 朴 end

  /**
   * マスタ一覧取得.
   *
   * @param ntssUser NTSS認証ユーザー
   * @return マスタ一覧のResponse
   */
  @GetMapping("/master_list")
  public ResponseEntity<?> getMasterList(@AuthenticationPrincipal NtssUser ntssUser) {

    // レスポンス生成
    MasterListResponse response = masterListService.getMasterList(ntssUser.getUserType());
    return new ResponseEntity<>(response, HttpStatus.OK);

  }

  /**
   * マスタデータ取得.
   *
   * @param masterName マスタ名称(物理名)
   * @param ntssUser   NTSS認証ユーザー
   * @return マスタデータのResponse
  */
  @GetMapping("/{masterName}/data")
  public ResponseEntity<?> getMasterData(@PathVariable String masterName,
                                         @RequestParam(required = false) Long selectedPatId,
                                         @AuthenticationPrincipal NtssUser ntssUser) {
    if (!facilityAccessService.hasFacilityOrSelectedPatShareAccess(ntssUser, ntssUser.getFacilityCd(), selectedPatId)) {
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
    }



    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get master by facilityCd : " + masterName);
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI,
      null);

    try {
      // レスポンス生成
      MasterDataResponse response = masterEditService.getMasterData(masterName, ntssUser.getFacilityCd());
      return new ResponseEntity<>(response, HttpStatus.OK);

    } catch (Exception e) {


      // マスタ定義が取得できなかった場合
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (ntssUser != null && ntssUser.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI,
        null);
      return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.MASTER_RECORD_ERROR.getMessage()),
        HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  // #11205 -ペンテスト2－4認可制御の不備  add 20260420 start
  // クライアントから /{masterName}/data/nkknkk を叩かせず本URLのみで標準休日マスタを返す（セッション施設≠nkknkk時のIDB/誤検知対策）。
  /**
   * 休日マスタ（日機装標準施設）取得。施設コードはサーバ側で固定し、クロスファシリティ用のパスパラメータを挟まない.
   * (#11205: getMasterDataByFacilityCd でのパスfacilityCd とセッション施設の突合とは別経路.)
   *
   * @param ntssUser NTSS認証ユーザー
   * @return マスタデータのResponse
   */
  @GetMapping("/mst_holiday/data/nikkiso-corporate")
  public ResponseEntity<?> getMstHolidayNikkisoCorporateData(@AuthenticationPrincipal NtssUser ntssUser) {

    final String corporateFacilityCd = "nkknkk"; // #11205 日機装標準施設コード（サーバ固定・リクエスト不可）

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get mst_holiday (nikkiso corporate fixed facilityCd)");
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI,
      null);

    try {
      MasterDataResponse response =
        masterEditService.getMasterData("mst_holiday", corporateFacilityCd);
      return new ResponseEntity<>(response, HttpStatus.OK);

    } catch (Exception e) {
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (ntssUser != null && ntssUser.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
      }
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI,
        null);
      return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.MASTER_RECORD_ERROR.getMessage()),
        HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }
  // #11205 -ペンテスト2－4認可制御の不備  add 20260420 end

  /**
   * マスタデータ取得.
   *
   * @param masterName マスタ名称(物理名)
   * @param facilityCd NTSS認証ユーザー
   * @return マスタデータのResponse
  */
  @GetMapping("/{masterName}/data/{facilityCd}")
  public ResponseEntity<?> getMasterDataByFacilityCd(@PathVariable String masterName,
                                                     @PathVariable String facilityCd,
                                                     @RequestParam(required = false) Long selectedPatId,
                                                     // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
                                                     @AuthenticationPrincipal NtssUser ntssUser
                                                     // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
  ) {
    if (!facilityAccessService.hasFacilityOrSelectedPatShareAccess(ntssUser, facilityCd, selectedPatId)) {
      return new ResponseEntity<>(HttpStatus.FORBIDDEN);
    }

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get master : " + masterName + " , facilityCd : " + facilityCd);
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI,
      null);

    try {
      // レスポンス生成
      MasterDataResponse response = masterEditService.getMasterData(masterName, facilityCd);
      return new ResponseEntity<>(response, HttpStatus.OK);

    } catch (Exception e) {

      // マスタ定義が取得できなかった場合
      eventLogMessage.setLogMessage("Exception message : " + e.getMessage());
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI,
        null);

      return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.MASTER_RECORD_ERROR.getMessage()),
        HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * マスタデータ取得(SQL指定).
   *
   * @param masterName マスタ名称(物理名)
   * @param facilityCd NTSS認証ユーザー
   * @return マスタデータのResponse
   */
  @GetMapping("/{masterName}/data/sql/{facilityCd}")
  public ResponseEntity<?> getMasterDataByFacilityCdWithSql(@PathVariable String masterName, @PathVariable String facilityCd,
                                                            // #11205 -ペンテスト2－4認可制御の不備  add 20260326 zhangYingJie start
                                                            @AuthenticationPrincipal NtssUser ntssUser
                                                            // #11205 -ペンテスト2－4認可制御の不備  add 20260326 zhangYingJie end
) {
      // #11205 -ペンテスト2－4認可制御の不備  add 20260326 zhangYingJie start
          if(!ntssUser.isNkkAdminUser()) {
              if (facilityCd != null && !facilityCd.isEmpty() &&
                  !facilityCd.equals(ntssUser.getFacilityCd())) {
                  String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + facilityCd + " " + "masterName=" + masterName + " ";
                  InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
                  return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
              }
          }
      // #11205 -ペンテスト2－4認可制御の不備  add 20260326 zhangYingJie end


    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get master : " + masterName + " , facilityCd : " + facilityCd);
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI,
      null);
    try {
      // レスポンス生成
      MasterDataResponse response = masterEditService.getMasterDataWithSql(masterName, facilityCd);
      return new ResponseEntity<>(response, HttpStatus.OK);

    } catch (Exception e) {

      // マスタ定義が取得できなかった場合
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (facilityCd != null) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI,
        null);
      return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.MASTER_RECORD_ERROR.getMessage()),
        HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * マスタデータ取得(施設コードでフィルタしない)
   *
   * @param masterName マスタ名称(物理名)
   * @return マスタデータのResponse
   */
  @GetMapping("/getAllMasterData/{masterName}")
  public ResponseEntity<?> getAllMasterData(@PathVariable String masterName) {
    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get master : " + masterName);
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI,
      null);

    try {
      // レスポンス生成
      MasterDataResponse response = masterEditService.getMasterData(masterName, null);
      return new ResponseEntity<>(response, HttpStatus.OK);

    } catch (Exception e) {

      // マスタ定義が取得できなかった場合
      eventLogMessage.setLogMessage("Exception message : " + e.getMessage());
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI,
        null);
      return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.MASTER_RECORD_ERROR.getMessage()),
        HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  // add #6217 全施設マスタ画面が遅い guanhao start
  /**
   * マスタを全件取得する.分頁
   */
  @PostMapping("/getSysFacilityByLimitAndOffset")
  public ResponseEntity<?> getSysMedicineByLimitAndOffset(@RequestBody Map<String, Object> params) throws IOException {
    // ログ出力
    Integer limit = 100;
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("マスタ取得のRestAPI実行");
    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);

    String recordName = null;
    if (!String.valueOf(params.get("keywordName")).equals("null")) {

      recordName = params.get("keywordName").toString();
    }

    int offset = Integer.valueOf(String.valueOf(params.get("offset")));

    ObjectMapper mapper = new ObjectMapper();
    List<String> insertRecordList = (List)params.get("insertRecord");
    if (insertRecordList != null) {

      offset = offset - insertRecordList.size();
    }

    // レスポンス生成
    List<SysFacility> response = masterEditService.getSysFacilityByLimitAndOffset(limit, offset, recordName);
    // ログ出力

    eventLogMessage.setLogMessage("マスタ取得:取得件数[" + response.size() + "]");
    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    return new ResponseEntity<>(response, HttpStatus.OK);
  }

  @PostMapping("/getSysFacilityAfterSaveByLimit")
  public ResponseEntity<?> getSysFacilityAfterSaveByLimit(@RequestBody Map<String, Object> params) throws IOException {
    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("マスタ取得のRestAPI実行");
    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);

    String recordName = null;
    if (!String.valueOf(params.get("keywordName")).equals("null")) {

      recordName = params.get("keywordName").toString();
    }

    List<String> medicalInstitutionCds = new ArrayList<>();
    ObjectMapper mapper = new ObjectMapper();
    List<String> insertRecordList = (List)params.get("insertRecord");
    for (int i = 0; insertRecordList.size() > i; i++) {
      SysFacility sysFacility = mapper.readValue(insertRecordList.get(i), SysFacility.class);
      medicalInstitutionCds.add(sysFacility.getMedicalInstitutionCd());
    }

    int limit = Integer.valueOf(String.valueOf(params.get("limit"))) - insertRecordList.size();
    // レスポンス生成
    List<SysFacility> response = masterEditService.getSysFacilityAfterSaveByLimit(limit, recordName, medicalInstitutionCds);
    // ログ出力
    eventLogMessage.setLogMessage("マスタ取得:取得件数[" + response.size() + "]");
    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    return new ResponseEntity<>(response, HttpStatus.OK);
  }

  /**
   * マスタを件数取得する
   */
  @GetMapping("/getTotal")
  public ResponseEntity<?> getTotal() {
    String Total = masterEditService.getTotal();
    return new ResponseEntity<>(Total, HttpStatus.OK);
  }
  // add #6217 全施設マスタ画面が遅い guanhao end

  /**
   * マスタデータ更新.
   *
   * @param masterPhysicalName マスタ物理名称
   * @param request            マスタデータ更新のrequest
   * @param ntssUser           NTSS認証ユーザー
   * @return
   */
  @PutMapping("/{masterName}/data")
  public ResponseEntity<?> updateMasterData(@PathVariable("masterName") String masterPhysicalName,
                                            @RequestBody MasterUpdateRequest request, @AuthenticationPrincipal NtssUser ntssUser) {

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to update records : " + masterPhysicalName);
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI,
      null);
    try {
      // 更新処理
      MasterUpdateResponse response = masterEditService.updateMasterData(masterPhysicalName, ntssUser.getFacilityCd(),
        request.getData());

      if (masterPhysicalName.equals("mst_bed")) {
        // 次患者更新処理
        LocalDateTime update = LocalDateTime.now();
        for (Map<String, Object> data : request.getData()) {
          String machineNo = data.get("machineNo") == null ? "" : data.get("machineNo").toString();
          String bedCd = data.get("code").toString();
          Long indBedCd = Long.parseLong(bedCd);
          if (indBedCd != 0 && !machineNo.isEmpty()) {
            // 登録されているベッド
            webApiCallCommonUtil.SetNextPatInfo(indBedCd, false, update);
          }
        }
      }

      return new ResponseEntity<>(response, HttpStatus.OK);
    } catch (OptimisticLockingFailureException e) {
      // 楽観排他エラーの場合は共通の例外ハンドラに任せる
      throw e;
    } catch (Exception e) {
      // 更新処理ができなかった場合
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (ntssUser != null && ntssUser.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI,
        null);
      return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage()),
        HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * マスタデータ更新.
   *
   * @param masterPhysicalName マスタ物理名称
   * @param facilityCd         施設コード
   * @param request            マスタデータ更新のrequest
   * @return
   */
  @PutMapping("/{masterName}/data/{facilityCd}")
  public ResponseEntity<?> updateMasterData(@PathVariable("masterName") String masterPhysicalName, @PathVariable String facilityCd,
                                            @RequestBody MasterUpdateRequest request,
                                                     // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
                                                     @AuthenticationPrincipal NtssUser ntssUser
                                                     // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
) {
    // #11205 -ペンテスト2－4認可制御の不備  add 20260420 start
    if(!ntssUser.isNkkAdminUser()) {
      if (facilityCd != null && !facilityCd.isEmpty() && !facilityCd.equals(ntssUser.getFacilityCd())) {
        String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " facilityCd=" + facilityCd + " masterPhysicalName=" + masterPhysicalName + " ";
        InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
        return new ResponseEntity<>("セキュリティチェックの例外!", HttpStatus.FORBIDDEN);
      }
    }
    // #11205 -ペンテスト2－4認可制御の不備  add 20260420 end

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to update records : " + masterPhysicalName);
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI,
      null);
    MasterDataResponse initData = null;

    //add #10412 次患者更新関連全体見直し対応 朴 start
    List<Object> beforeMstList = new ArrayList<>();
    List<Object> afterMstList = new ArrayList<>();
    // 次患者送信が必要なマスタ変更
    // ※クールマスタ、ベッドマスタ、装置マスタ、VAマスタ、装置通信・仮想端末マスタ、ダイアライザマスタ、治療方法マスタ、医療材料マスタ、病棟マスタ、診療科マスタ、利用者マスタ、薬剤マスタ、調製薬剤マスタ
    List<String> callNextPatMasterPhysicalNameList = new ArrayList<>(Arrays.asList("mst_kur", "mst_bed", "mst_machine", "mst_va", "mst_comsv_setting", "mst_dialyzer", "mst_treatment", "mst_equipment", "mst_ward", "mst_course", "mst_personal_user", "mst_medicine", "mst_medicine_mix"));
    if (callNextPatMasterPhysicalNameList.contains(masterPhysicalName)){
      // 変更前のマスタデータ取得
      beforeMstList =  nextPatService.getTableDataBymasterPhysicalName(facilityCd, masterPhysicalName);
    }
    //add #10412 次患者更新関連全体見直し対応 朴 end

    try {
      if (masterPhysicalName.equals("mst_bed")) {
        initData = masterEditService.getMasterDataWithSql("mst_bed", facilityCd);
      }
      if (masterPhysicalName.equals("mst_comsv_setting")) {
        initData = masterEditService.getMasterDataWithSql("mst_comsv_setting", facilityCd);
      }
      // 更新処理
      MasterUpdateResponse response = masterEditService.updateMasterData(masterPhysicalName, facilityCd,
        request.getData());
      //del 6742 ダイアライザマスタにてKoAを編集して保存したところシステムエラー発生 関俊楠 start
      // add 4693 鞠 start
//      if ("mst_dialyzer".equals(masterPhysicalName)) {
//        List<Map<String, Object>> updateData = request.getData();
//
//        // PK項目の型変換
//        updateData.forEach(e -> {
//          Optional<Object> codeOpt = Optional.ofNullable(e.get(ALIAS_CODE));
//          codeOpt.ifPresent(code -> e.put(ALIAS_CODE, Long.parseLong(code.toString())));
//        });
//        // 更新データの抽出
//        List<Map<String, Object>> data = Optional.ofNullable(updateData).orElse(Collections.emptyList()).stream()
//          .filter(e -> e.get(OPERATION) != null).collect(Collectors.toList());
//
//        data.stream().filter(e -> e.get(OPERATION).equals(AdminWebConstant.MasterOperationType.UPDATE)).forEach(e -> {
//          // mst_dialyzer更新データ の　 dialyzerCdと使用終了日
//          Long dialyzerCd = new Long(e.get("code").toString());
//          String useEndDate = e.get("useEndDate").toString();
//
//          List<OrdMain> ordMainList = ordMainService.selectOrdMainByFacilityCd(facilityCd,useEndDate);
//          ordMainList.forEach(ord -> {
//            Optional.of(ord.getIndCondInfo()).ifPresent(buf -> {
//              String indCondInfo5Value = "";
//              try {
//                indCondInfo5Value = new JSONObject(buf).getJSONObject("5").get("value").toString();
//              } catch (Exception ignored) {
//              }
//              if (!indCondInfo5Value.isEmpty() && indCondInfo5Value.equals(dialyzerCd.toString())) {
//                // 期限切りの時、update指示：治療条件情報key5
//                ordMainService.updateOrdMainByOrdNo(ord.getOrdNo());
//                // 指示履歴の更新
//              }
//            });
//          });
//        });
//      }
      //  add 4693 鞠 end
      //del 6742 ダイアライザマスタにてKoAを編集して保存したところシステムエラー発生 関俊楠 end
      //del #10412 次患者更新関連全体見直し対応 朴 start
//      if (masterPhysicalName.equals("mst_bed")) {
//        //mod 6846 ベッドマスタを変更すると全ベッドに次患者情報（コメントデータ）、次患者情報2が再送される 関俊楠 start
//        List<Map<String, Object>> operationData = new ArrayList<>();
//        request.getData().forEach(e ->
//          Optional.ofNullable(e.get("operation")).ifPresent(data -> operationData.add(e))
//        );
//        if (isChangeBedName(operationData, initData.localDataSource.data)) {
//          // 次患者更新処理
//          LocalDateTime update = LocalDateTime.now();
//          //for (Map<String, Object> data : request.getData()) {
//          for (Map<String, Object> data : operationData) {
//            String machineNo = data.get("machineNo") == null ? "" : data.get("machineNo").toString();
//            String bedCd = data.get("code").toString();
//            Long indBedCd = Long.parseLong(bedCd);
//            if (indBedCd != 0 && !machineNo.isEmpty()) {
//              // 登録されているベッド
//              webApiCallCommonUtil.SetNextPatInfo(indBedCd, false, update);
//            }
//          }
//          //mod 6846 ベッドマスタを変更すると全ベッドに次患者情報（コメントデータ）、次患者情報2が再送される 関俊楠 end
//        }
//      }
//
//      if (masterPhysicalName.equals("mst_comsv_setting")) {
//        // add 8838 装置通信・仮想端末マスタの並び順がNG 修正 20230613 ztc start
//        List<Map<String, Object>> filteredList = request.getData().stream()
//                .filter(es -> es.get("operation") != null && (int) es.get("operation") > 0)
//                .collect(Collectors.toList());
//        // mod 7686 修正 chen start
//        // this.setPatInfo(initData.localDataSource.data, facilityCd);
////        this.setPatInfo(request.getData(), facilityCd);
//        if(!filteredList.isEmpty()){
//          this.setPatInfo(filteredList, facilityCd);
//        }
//        // upd 8838 装置通信・仮想端末マスタの並び順がNG 修正 20230613 ztc end
//        // mod 7686 修正 chen end
//      }
      //del #10412 次患者更新関連全体見直し対応 朴 end

      //add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 zhaoqi 20240228 start
      // 更新データの抽出
      List<Map<String, Object>> data = Optional.ofNullable(request.getData()).orElse(Collections.emptyList()).stream()
        .filter(e -> (e.get(OPERATION) != null && !"1".equals(e.get(OPERATION).toString()))).toList();
      boolean insertOrNot = false;
      for (MstToMongoEnum e : MstToMongoEnum.values()) {
        if (e.strKey.equals(masterPhysicalName)) {
          insertOrNot = true;
          break;
        }
      }
      if(!data.isEmpty() && insertOrNot){
        mongoService.savePatDataToMongo(data, masterPhysicalName, facilityCd);
      }
      //add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 zhaoqi 20240228 end

      //add #10412 次患者更新関連全体見直し対応 朴 start
      if (callNextPatMasterPhysicalNameList.contains(masterPhysicalName)){
        // 変更後のマスタデータ取得
        afterMstList =  nextPatService.getTableDataBymasterPhysicalName(facilityCd, masterPhysicalName);

        // 次患者情報１、次患者情報２にたいして変更が発生しているかをチェックし、次患者情報呼び出し統合処理を呼び出す
        nextPatService.CallNextPatChange(facilityCd, nextPatService.FilterNextPatInfo1or2ChangedForMst(facilityCd, masterPhysicalName, beforeMstList, afterMstList));
      }
      //add #10412 次患者更新関連全体見直し対応 朴 end

      return new ResponseEntity<>(response, HttpStatus.OK);
    } catch (OptimisticLockingFailureException e) {
      // 楽観排他エラーの場合は共通の例外ハンドラに任せる
      throw e;
    } catch (Exception e) {
      // 更新処理ができなかった場合
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (facilityCd != null) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI,
        null);
      return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage()),
        HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * マスタ定義情報を取得.
   *
   * @param masterName マスタ名称(物理名)
   * @param ntssUser   NTSS認証ユーザー
   * @return マスタ定義情報のResponse
   */
  @GetMapping("/{masterName}/column_info")
  public ResponseEntity<?> getColumnInfo(@PathVariable String masterName, @AuthenticationPrincipal NtssUser ntssUser) {

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get master column info by master name : " + masterName);
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI,
      null);

    // レスポンス生成
    SysMasterDefine.ColumnInfo response = masterEditService.getColumnInfo(masterName);
    return new ResponseEntity<>(response, HttpStatus.OK);
  }

  /**
   * 装置状態管理情報を取得.
   *
   * @param facilityCd 施設コード
   * @return 装置状態管理情報のResponse
   */
  @GetMapping("/mnt_machine_state/{facilityCd}")
  public ResponseEntity<List<MntMachineState>> getMntMachineStateByFacilityCd(@PathVariable String facilityCd,
                                                                              // #11205 -ペンテスト2－4認可制御の不備  add 20260326 zhangYingJie start
                                                                              @AuthenticationPrincipal NtssUser ntssUser
                                                                              // #11205 -ペンテスト2－4認可制御の不備  add 20260326 zhangYingJie end
) {
      // #11205 -ペンテスト2－4認可制御の不備  add 20260326 zhangYingJie start
          if(!ntssUser.isNkkAdminUser()) {
              if (facilityCd != null && !facilityCd.isEmpty() &&
                  !facilityCd.equals(ntssUser.getFacilityCd())) {
                  String msg_11205_FORBIDDEN = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + "facilityCd=" + facilityCd + " ";
                  InvestigateLogUtils.info("11205", msg_11205_FORBIDDEN, "11205-FORBIDDEN");
                  return new ResponseEntity<>(HttpStatus.FORBIDDEN);
              }
          }
      // #11205 -ペンテスト2－4認可制御の不備  add 20260326 zhangYingJie end


    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get master : " + "mnt_machine_state" + " , facilityCd : " + facilityCd);
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI,
      null);
    try {
      // レスポンス生成
      List<MntMachineState> response = mntMachineStateService.selectAll();
      if (response.size() < 0) {
        // 異常扱い
        return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.INTERNAL_SERVER_ERROR);
      }
      return new ResponseEntity<>(response, HttpStatus.OK);
    } catch (Exception e) {

      // マスタ定義が取得できなかった場合
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (facilityCd != null) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI,
        null);
      return new ResponseEntity<>((org.springframework.http.HttpHeaders) null, HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }


  /***
   * ベッド名以外の内容に変化はないか
   * @param requestData マスタデータ更新のrequest
   * @param oldLists 初期データ
   * @return ベッド名以外の内容に変化はないか
   */
  //mod 6846 ベッドマスタを変更すると全ベッドに次患者情報（コメントデータ）、次患者情報2が再送される 関俊楠 start
//  public boolean isChangeBedName(List<Map<String, Object>> requestData, List<Map<String, Object>> oldLists){
//    List<Map<String, Object>> operationData = new ArrayList<>();
//    requestData.forEach(e ->
//      Optional.ofNullable(e.get("operation")).ifPresent(data -> operationData.add(e))
//    );
//    List<Integer> flagList = new ArrayList<>();
//    operationData.forEach(newData -> {
//      Optional<Map<String, Object>> data = oldLists.stream().filter(old -> old.get("code").toString().equals(newData.get("code").toString())).findFirst();
//      data.ifPresent(e -> {
//        String[] arts = {"bedNo", "shuntPosition", "isInfection", "emergencyClass", "machineNo", "outputPrinter", "isAutoprintBefore", "isAutoprintAfter", "isAutoprintCommit", "fnBedNo", "isHospitalCd1", "isHospitalCd2", "sorkRank", "sortInputTime"};
//        Arrays.asList(arts).forEach(s -> {
//          e.putIfAbsent(s, "");
//          newData.putIfAbsent(s, "");
//          if (!e.get(s).toString().equals(newData.get(s).toString())) {
//            flagList.add(1);
//          }
//        });
//      });
//    });
//    return flagList.size() != 0;
//  }
  public boolean isChangeBedName(List<Map<String, Object>> requestData
    , List<Map<String, Object>> oldLists) {
    //mod 6846 ベッドマスタを変更すると全ベッドに次患者情報（コメントデータ）、次患者情報2が再送される 関俊楠 start
//    List<Map<String, Object>> operationData = new ArrayList<>();
//    requestData.forEach(e ->
//      Optional.ofNullable(e.get("operation")).ifPresent(data -> operationData.add(e))
//    );
    List<Integer> flagList = new ArrayList<>();
    //operationData.forEach(newData -> {
    requestData.forEach(newData -> {
      //mod 6846 ベッドマスタを変更すると全ベッドに次患者情報（コメントデータ）、次患者情報2が再送される 関俊楠 end
      Optional<Map<String, Object>> data = oldLists.stream().filter(
        old -> old.get("code").toString().equals(newData.get("code").toString())).findFirst();
      data.ifPresent(e -> {
        String[] arts = {
          "bedNo",
          "machineNo",
          "fnBedNo",
          "sorkRank",
          "sortInputTime"
        };
        Arrays.asList(arts).forEach(s -> {
          e.putIfAbsent(s, "");
          newData.putIfAbsent(s, "");
          if (!e.get(s).toString().equals(newData.get(s).toString())) {
            flagList.add(1);
          }
        });
      });
    });
    return flagList.size() != 0;
  }

  /***
   * 装置通信・仮想端末マスタの患者情報が変更されたかどうかを判断し、次患者更新処理を行う。
   * @param oldLists
   * @param facilityCd 施設コード
   */
  public void setPatInfo(List<Map<String, Object>> oldLists, String facilityCd) throws URISyntaxException {
    // ベッドマスタのデータ
    MasterDataResponse bedData = masterEditService.getMasterDataWithSql("mst_bed", facilityCd);
    // 装置通信・仮想端末マスタのデータ
    MasterDataResponse comsvSettingData = masterEditService.getMasterDataWithSql("mst_comsv_setting", facilityCd);
    AtomicBoolean flag = new AtomicBoolean(false);
    // 患者情報は変更されましたか
    oldLists.forEach(old -> {
      comsvSettingData.localDataSource.data.forEach(latest -> {
        if (old.get("code").toString().equals(latest.get("code").toString()) && !old.get("lcdNpat").equals(latest.get("lcdNpat"))) {
          flag.set(true);
        }
      });
    });
    if (flag.get()) {
      // mod 7686 修正 chen start
      List<String> deviceEdgeNoList = new ArrayList<String>();
      for (Map<String, Object> oldList : oldLists) {
        deviceEdgeNoList.add(oldList.get("deviceEdgeNo").toString());
      }
      List<String> mstComsvBedList = masterEditService.getMstComsvBed(deviceEdgeNoList, facilityCd);
      // 次患者更新処理
      LocalDateTime update = LocalDateTime.now();
      for (Map<String, Object> data : bedData.localDataSource.data) {
        String machineNo = data.get("machineNo") == null ? "" : data.get("machineNo").toString();
        String bedCd = data.get("code").toString();
        Long indBedCd = Long.parseLong(bedCd);
        if (!mstComsvBedList.contains(indBedCd.toString())) {
          continue;
        }
        // mod 7686 修正 chen end
        if (indBedCd != 0 && !machineNo.isEmpty()) {
          // 登録されているベッド
          webApiCallCommonUtil.SetNextPatInfo(indBedCd, false, update);
        }
      }
    }
  }

}
