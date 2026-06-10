package jp.co.nikkiso.ntss.admin_web.service.treatmentRecord;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant;
import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.admin_web.service.sendConditionCancel.SendConditionCancelService;
import jp.co.nikkiso.ntss.admin_web.web.rest.OrdMainResource;
import jp.co.nikkiso.ntss.admin_web.service.SelectHistoryUtils;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.FUNCTION_CODE;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.admin_web.request.deviceEdgeOrder.DeviceEdgeOrderRequest;
import jp.co.nikkiso.ntss.admin_web.response.deviceEdgeOrder.DeviceEdgeOrderResponse;
import jp.co.nikkiso.ntss.admin_web.service.deviceEdgeOrder.DeviceEdgeOrderService;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.webSocketNotify.WebSocketNotifyService;
import jp.co.nikkiso.ntss.api.service.PatMainAcceptanceStatusInfo.PatMainAcceptanceStatusInfoService;
import jp.co.nikkiso.ntss.core.dao.MniMonitorDao;
import jp.co.nikkiso.ntss.core.dao.MntMachineStateDao;
import jp.co.nikkiso.ntss.core.dao.MntMotionRecordDao;
import jp.co.nikkiso.ntss.core.dao.MstMachineDao;
import jp.co.nikkiso.ntss.core.dao.OrdChecklistDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainRestoreDao;
import jp.co.nikkiso.ntss.core.dao.OrdMaterialSaveDao;
import jp.co.nikkiso.ntss.core.dao.OrdTreatConditionDao;
import jp.co.nikkiso.ntss.core.dao.PatMainDao;
import jp.co.nikkiso.ntss.core.entity.MstMachine;
import jp.co.nikkiso.ntss.core.entity.OrdMainRestore;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.entity.MntMachineState;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.exception.NotExistException;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.service.ordMaterialSaveService.OrdMaterialSaveService;
import jp.co.nikkiso.ntss.core.utils.TriggerUtil;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.StringUtils;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.annotation.Resource;
import java.lang.reflect.Field;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Objects;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

/**
 * 治療記録画面（削除機能）のService実装クラス.
 */
@Service
@Slf4j
public class TreatmentRecordDeleteServiceImpl implements TreatmentRecordDeleteService {

  /**
   * {@link OrdMainDao}インタフェース
   */
  @Autowired
  private OrdMainDao ordMainDao;

  /**
   * {@link PatMainDao}インタフェース.
   */
  @Autowired
  private PatMainDao patMainDao;

  /**
   * {@link MntMachineStateDao}インタフェース.
   */
  @Autowired
  private MntMachineStateDao mntMachineStateDao;

  /**
   * {@link DeviceEdgeOrderService}インタフェース.
   */
  @Autowired
  private DeviceEdgeOrderService deviceEdgeOrderService;

  /**
   * {@link WebSocketNotifyService}インタフェース.
   */
  @Autowired
  private WebSocketNotifyService webSocketNotifyService;

  /**
   	* ロギングのServiceインタフェース.
    */
  @Autowired
  private LogService logService;

  /**
   * {@link PatMainAcceptanceStatusInfoService}インタフェース.
   */
  @Autowired
  PatMainAcceptanceStatusInfoService patMainAcceptanceStatusInfoService;

  //mod FNSI修正401対応 房 start
  @Resource
  private OrdChecklistDao ordChecklistDao;
  //mod FNSI修正401対応 房 start

  // add FNSI-改修内容追加OrdMain履歴 付 start
  @Autowired
  private SelectHistoryUtils selectHistoryUtils;
  // add FNSI-改修内容追加OrdMain履歴 付 end

  /**
   * add FNSI No.396 治療記録 実績削除 -- Sanjingye Sun 20210127
   */
  @Autowired
  private OrdMaterialSaveDao ordMaterialSaveDao;

  /**
   * add FNSI No.396 治療記録 実績削除 -- Sanjingye Sun 20210127
   */
  @Autowired
  private OrdMaterialSaveService ordMaterialSaveService;

  @Autowired
  private OrdMainRestoreDao ordMainRestoreDao;

  //add FNSI-修正、#6305 fang start
  @Autowired
  MntMotionRecordDao mntMotionRecordDao;

  @Autowired
  MstMachineDao mstMachineDao;

  @Autowired
  MniMonitorDao mniMonitorDao;

  @Autowired
  OrdTreatConditionDao ordTreatConditionDao;
  //add FNSI-修正、#6305 fang end
  // add #6848 2022-08-26 透析実績を削除しても次患者は戻らない。 dou start
  @Autowired
  OrdMainResource ordMainResource;
  // add #6848 2022-08-26 透析実績を削除しても次患者は戻らない。 dou end

  @Autowired
  private TriggerUtil triggerUtil;

  // add #10739 コンバート施設で指示受け(治療単位)が表示されない 関 start
  @Autowired
  private SendConditionCancelService sendConditionCancelService;
  // add #10739 コンバート施設で指示受け(治療単位)が表示されない 関 end

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  public void deleteTreatmentRecordByOrdNo(Long ordNo) throws NotExistException {
    // #11266 2024.11.27 mod 未使用なので処理全てをコメントアウト TDC高村 start
    /*

    // オーダ番号に該当するord_mainを取得する.
    OrdMain targetOrdMain = ordMainDao.selectByOrdNo(ordNo);
    if (Objects.isNull(targetOrdMain)) {
      throw new NotExistException(String.format("治療記録削除:オーダ番号に該当する情報が存在しません。オーダ番号[%d]", ordNo));
    }
    // 取得したord_mainをコピーする.
//    OrdMain deleteOrdMain = new OrdMain();
//    BeanUtils.copyProperties(targetOrdMain, deleteOrdMain);

    // add FNSI-改修内容追加OrdMain履歴 付 start
    //----------------------------------------
    // オーダの削除（論理削除）
    // ・透析予定部をクリア
    //----------------------------------------
    // 予定部分をクリアする.
//    clearInstructionsPart(deleteOrdMain);
    //　コピーしたord_mainを登録する.
//    ordMainDao.insert(deleteOrdMain);

    // #11266 2024.11.27 mod 通信サーバへ通知を行ってから透析実績部をクリアする TDC高村 start
    //  //----------------------------------------
    //  // オーダの更新
    //  // ・透析実績部をクリア
    //  // ・通信サーバへの通知
    //  // ・患者の治療進捗状態の更新
    //  //----------------------------------------
    //  // 実績部分をクリアする.
    //  clearResultPart(targetOrdMain);
    //  // 更新日時を更新
    //  targetOrdMain.setUpDate(new Timestamp(System.currentTimeMillis()));

    //  getHistory(ordNo);
    //  // mangoDb-update
    //  // add FNSI-改修内容追加OrdMain履歴 付 end

    //  // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
    //  LogEventUtils.setOperatorId(targetOrdMain);
    //  // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
    //  // 更新する.

    //  OrdMain oldOrdMain = ordMainDao.selectByOrdNo(targetOrdMain.getOrdNo());
    //  ordMainDao.update(targetOrdMain);
    //  OrdMain newOrdMain = ordMainDao.selectByOrdNo(targetOrdMain.getOrdNo());
    //  triggerUtil.updateTriggerOrdMain(Collections.singletonList(oldOrdMain),
    //    Collections.singletonList(newOrdMain));

    //  // 通信サーバへの通知処理

    //  EventLogMessage eventLogMessage = new EventLogMessage();
    //  eventLogMessage.setLogMessage("治療記録削除:通信サーバへの通知：対象オーダ番号[" + ordNo + "]");
    //  logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_TREATMENT_RECORD, SERVICE_NAME.FNSI, null);
    //  if (!notificationToComServer(targetOrdMain.getFacilityCd(), ordNo)) {

    //    eventLogMessage.setLogMessage("治療記録削除:通信サーバへの通知に失敗しました.");
    //    logService.log(LogLevel.WARN, eventLogMessage, FUNCTION_CODE.FUNC_TREATMENT_RECORD, SERVICE_NAME.FNSI, null);
    //  }

    //----------------------------------------
    // オーダの更新
    // ・通信サーバへの通知
    // ・透析実績部をクリア
    // ・患者の治療進捗状態の更新
    //----------------------------------------
    // 通信サーバへの通知処理
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("治療記録削除:通信サーバへの通知：対象オーダ番号[" + ordNo + "]");
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_TREATMENT_RECORD, SERVICE_NAME.FNSI, null);
    if (!notificationToComServer(targetOrdMain.getFacilityCd(), ordNo)) {
      eventLogMessage.setLogMessage("治療記録削除:通信サーバへの通知に失敗しました.");
      logService.log(LogLevel.WARN, eventLogMessage, FUNCTION_CODE.FUNC_TREATMENT_RECORD, SERVICE_NAME.FNSI, null);
    }

    // 実績部分をクリアする.
    clearResultPart(targetOrdMain);
    // 更新日時を更新
    targetOrdMain.setUpDate(new Timestamp(System.currentTimeMillis()));

    getHistory(ordNo);
    // mangoDb-update
    // add FNSI-改修内容追加OrdMain履歴 付 end

    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
    LogEventUtils.setOperatorId(targetOrdMain);
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end

    // 更新する.
    OrdMain oldOrdMain = ordMainDao.selectByOrdNo(targetOrdMain.getOrdNo());
    ordMainDao.update(targetOrdMain);
    OrdMain newOrdMain = ordMainDao.selectByOrdNo(targetOrdMain.getOrdNo());
    triggerUtil.updateTriggerOrdMain(Collections.singletonList(oldOrdMain),
      Collections.singletonList(newOrdMain));
    // #11266 2024.11.27 mod 通信サーバへ通知を行ってから透析実績部をクリアする TDC高村 end


    // 患者の治療進捗状態の更新
    Long patId = targetOrdMain.getPatId();
    eventLogMessage.setLogMessage("治療記録削除:患者の治療進捗状態を更新：対象患者番号[" +  patId + "]");
    eventLogMessage.setPatId(String.valueOf(patId));
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_TREATMENT_RECORD, SERVICE_NAME.FNSI, null);
    patMainAcceptanceStatusInfoService.update(patId, ordNo, rstDialysisState.BEFORE_SEND_CONDITIOM, null, null);

    // add FNSI No.396 治療記録 実績削除 start -- Sanjingye Sun 20210127
    ordMaterialSaveDao.deleteRstDataByOrdNo(ordNo);

    // 「確定フラグ」を 1 → 0 に変更
    ordMaterialSaveService.cancelSendCondition(ordNo);

    // add FNSI No.396 治療記録 実績削除 end -- Sanjingye Sun 20210127

    */
    // #11266 2024.11.27 mod 未使用なので処理全てをコメントアウト TDC高村 end
  }

  // add FNSI-改修内容追加OrdMain履歴 付 start
  private void getHistory(Long ordNo){
    selectHistoryUtils.insertMangoDbHistory(1, ordNo, null, new ArrayList<>(), new ArrayList<>(), null, null,
      null, null, null, new ArrayList<>(), new ArrayList<>(), null, null, null,
      new ArrayList<>(), null, null, 1);
  }
  // add FNSI-改修内容追加OrdMain履歴 付 end

  /**
   * 通信サーバに通知する.
   * ※施設コード及びオーダ番号に該当する装置状態管理が存在する場合、
   * ※デバイスエッジ番号を特定し、通信サーバへ通知する.
   *
   * @param facilityCd 施設コード
   * @param ordNo オーダ番号
   * @return true:通信サーバへの通知成功、false:通知失敗
   */
  private boolean notificationToComServer(String facilityCd, Long ordNo) {
    // 通知成功可否フラグ(戻り値としても使用)
    boolean isSuccess = false;
    // #10457 2024.06.18 mod デバイスエッジに通知タイミングで現患者クリアを実施 TDC高村 start
    //
    // //　施設コード及びオーダ番号に該当する装置状態管理を取得
    // List<MntMachineState> mntMachineStateList = mntMachineStateDao.selectByOrdNo(facilityCd, ordNo);
    // // 装置状態管理がない場合
    // if (mntMachineStateList.isEmpty()) {
    //   EventLogMessage eventLogMessage = new EventLogMessage();
    //   eventLogMessage.setLogMessage("治療記録削除:装置状態管理情報なし:施設コード[ " + facilityCd + "] オーダ番号[" + ordNo + "]");
    //   logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_TREATMENT_RECORD, SERVICE_NAME.FNSI, null);
    //   return true;
    // }
    //
    // // デバイスエッジ番号を取得する為のリクエスト情報を作成
    // DeviceEdgeOrderRequest deviceEdgeOrderRequest = new DeviceEdgeOrderRequest();
    // deviceEdgeOrderRequest.setDeviceEdgeNo(null);
    // deviceEdgeOrderRequest.setOrdNo(ordNo);
    // deviceEdgeOrderRequest.setMachineNo(null);
    // deviceEdgeOrderRequest.setFacilityCd(facilityCd);
    //
    // try {
    //   // 不足している情報を補填
    //   DeviceEdgeOrderRequest targetInfo = deviceEdgeOrderService.findMissingData(deviceEdgeOrderRequest);
    try {
      //　施設コード及びオーダ番号に該当する装置状態管理を取得
      List<MntMachineState> mntMachineStateList = mntMachineStateDao.selectByOrdNo(facilityCd, ordNo);
      // 装置状態管理がない場合
      if (mntMachineStateList.isEmpty()) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("治療記録削除:装置状態管理情報なし:施設コード[ " + facilityCd + "] オーダ番号[" + ordNo + "]");
        logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_TREATMENT_RECORD, SERVICE_NAME.FNSI, null);
        return true;
      }

      // デバイスエッジ番号を取得する為のリクエスト情報を作成
      DeviceEdgeOrderRequest deviceEdgeOrderRequest = new DeviceEdgeOrderRequest();
      deviceEdgeOrderRequest.setDeviceEdgeNo(null);
      deviceEdgeOrderRequest.setOrdNo(ordNo);
      deviceEdgeOrderRequest.setMachineNo(null);
      deviceEdgeOrderRequest.setFacilityCd(facilityCd);

      // 不足している情報を補填
      DeviceEdgeOrderRequest targetInfo = deviceEdgeOrderService.findMissingData(deviceEdgeOrderRequest);

      // 現患者クリア処理実施
      MstMachine mstMachine = mstMachineDao.selectByMachineNo(targetInfo.getMachineNo());
      Timestamp upDate = new Timestamp(System.currentTimeMillis());
      int retCnt = mntMachineStateDao.updateCurrentPatClear(mstMachine.getFacilityCd(), mstMachine.getMachineTypeCd(), mstMachine.getMachineSerial(), upDate);
      if (1 != retCnt) {
        // 処理件数が1件でない場合は失敗
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("対象装置(" + "facility_cd=" + mstMachine.getFacilityCd() + "、machine_type_cd=" + mstMachine.getMachineTypeCd() +
          "、machine_serial=" + mstMachine.getMachineSerial() + ")に対して現患者クリア処理に失敗しました(処理件数:" + retCnt + ")");
        eventLogMessage.setDeviceEdgeNo(String.valueOf(targetInfo.getDeviceEdgeNo()));
        logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_TREATMENT_RECORD, SERVICE_NAME.FNSI, null);
        return false;
      }
      // #10457 2024.06.18 mod デバイスエッジに通知タイミングで現患者クリアを実施 TDC高村 end

      // 後体重測定指示(後体重測定)を通知
      DeviceEdgeOrderResponse afterWeightResponse =
        deviceEdgeOrderService.orderAfterWeight(targetInfo.getFacilityCd(), targetInfo.getDeviceEdgeNo(), targetInfo.getMachineNo());
      if (!Objects.isNull(afterWeightResponse)) {
        isSuccess = afterWeightResponse.isSuccess;
      }
      if (!isSuccess) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("治療記録削除:通信サーバへの通知失敗[{}]:施設コード[" + targetInfo.getFacilityCd() +
            "] デバイスエッジ番号[" + targetInfo.getDeviceEdgeNo() + "] 装置番号:[" + targetInfo.getMachineNo() + "]" +  "後体重測定指示");
        eventLogMessage.setDeviceEdgeNo(String.valueOf(targetInfo.getDeviceEdgeNo()));
        logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_TREATMENT_RECORD, SERVICE_NAME.FNSI,
                null);
      }
      // 治療状況確認指示(後体重確認)を通知
      DeviceEdgeOrderResponse checkStatusResponse =
        deviceEdgeOrderService.orderCheckStatus(targetInfo.getFacilityCd(), targetInfo.getDeviceEdgeNo(), targetInfo.getMachineNo());
      if (!Objects.isNull(checkStatusResponse)) {
        isSuccess = checkStatusResponse.isSuccess;
      }
      if (!isSuccess) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("治療記録削除:通信サーバへの通知失敗[{}]:施設コード[" + targetInfo.getFacilityCd() +
            "] デバイスエッジ番号[" + targetInfo.getDeviceEdgeNo() + "] 装置番号:[" + targetInfo.getMachineNo() + "]" +  "治療状況確認指示");
        eventLogMessage.setDeviceEdgeNo(String.valueOf(targetInfo.getDeviceEdgeNo()));
        logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_TREATMENT_RECORD, SERVICE_NAME.FNSI, null);
      }

    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (facilityCd != null) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_TREATMENT_RECORD, SERVICE_NAME.FNSI, null);
      isSuccess = false;
    }
    return isSuccess;
  }

  /**
   * 与えられたオーダの実績部分をクリアする.
   *
   * @param ordMain オーダ番号
   * @return 実績部分をクリアした{@link OrdMain}
   */
  private OrdMain clearResultPart(OrdMain ordMain) {
    // 実績：FNW+透析番号
    ordMain.setRstFnDialysisNo(null);
    // 実績：関連透析番号
    ordMain.setRstRelationDialysisNo(null);
    // 実績：版番号
    ordMain.setRstEdition(0);
    // 実績：版番号更新フラグ
    ordMain.setRstIsUpdateEdition(null);
    // 実績：登録区分
    ordMain.setRstInputClass(null);
    // 実績：治療状況
    ordMain.setRstDialysisState(AdminWebConstant.OrdMainConst.DialysisState.BEFORE_SEND);
    // 実績：治療方法コード
    ordMain.setRstTreatmentCd(null);
    // 実績：治療方法名
    ordMain.setRstTreatmentName(null);
    // 実績：クールコード
    ordMain.setRstKurCd(null);
    // 実績：クール名
    ordMain.setRstKurName(null);
    // 実績：ベッドコード
    ordMain.setRstBedCd(null);
    // 実績：ベッド名
    ordMain.setRstBedName(null);
    // 実績：装置番号
    ordMain.setRstMachineNo(null);
    // 実績：装置名
    ordMain.setRstMachineName(null);
    // 実績：条件送信日時
    ordMain.setRstCondSendDate(null);
    // 実績：受付日時
    ordMain.setRstAcceptDate(null);
    // 実績：治療開始日時
    ordMain.setRstStartDate(null);
    // 実績：治療終了日時
    ordMain.setRstEndDate(null);
    // 実績：帰宅日時
    ordMain.setRstReturnHomeDate(null);
    // 実績：入外区分
    ordMain.setRstInOutClass(null);
    // 実績：透析回数
    ordMain.setRstDialysisCnt(null);
    // 実績：病棟コード
    ordMain.setRstWardCd(null);
    // 実績：病棟名
    ordMain.setRstWardName(null);
    // 実績：診療科コード
    ordMain.setRstCourseCd(null);
    // 実績：診療科名
    ordMain.setRstCourseName(null);
    // 実績：DW
    ordMain.setRstDw(null);
    // 実績：穿刺者情報
    ordMain.setRstPunctureUserInfo(null);
    // 実績：返血者情報
    ordMain.setRstReturnUserInfo(null);
    // 実績：担当者情報
    ordMain.setRstChargeUserInfo(null);
    // 実績：血液循環積算値
    ordMain.setRstBloodCirculateTotal(null);
    // 実績：透析運転時間
    ordMain.setRstRunningTime(null);
    // 実績：Kt/V
    ordMain.setRstKtV(null);
    // 実績：透析記録確認日時
    ordMain.setRecSetDate(null);
    // 実績：送信管理番号
    ordMain.setSendCtlNo(null);
    // 実績：血液浄化装置名称
    ordMain.setBloodPurifierName(null);
    // 実績：プログラム補液引き残し量
    ordMain.setPullLeaveAmount(null);
    // 実績：治療条件情報
    ordMain.setRstCondInfo(null);
    // 実績：投与薬剤情報
    ordMain.setRstMediInfo(null);
    // 実績：医療材料情報
    ordMain.setRstEquipInfo(null);
    // 実績：指示コメント情報
    ordMain.setRstIndCommentInfo(null);
    // 実績：風袋補正
    ordMain.setRstTareInfo(null);
    // 実績：除水補正
    ordMain.setRstOffWaterInfo(null);
    /* del by shiyw 2024-01-31 [#10196]ord_mainのデータ定義の修正 --start */
//    // 実績：装置設定情報
//    ordMain.setRstDeviceSetInfo(null);
    /* del by shiyw 2024-01-31 [#10196]ord_mainのデータ定義の修正 --end */
    // 実績：体重測定記録番号
    ordMain.setWeightScaleNo(null);
    // 実績：体重情報
    ordMain.setRstWeightInfo(null);
    /* del by shiyw 2024-01-31 [#10196]ord_mainのデータ定義の修正 --start */
//    // 実績：バイタル情報
//    ordMain.setRstVitalInfo(null);
    /* del by shiyw 2024-01-31 [#10196]ord_mainのデータ定義の修正 --end */
    // 実績：愁訴情報
    ordMain.setRstComplaintInfo(null);
    // 実績：愁訴処置情報
    ordMain.setRstTreatmentInfo(null);
    // 実績：愁訴処置者情報
    ordMain.setRstTreatStaffInfo(null);
    // 実績：回診記録情報
    ordMain.setRstRoundsInfo(null);
    // 実績：確定フラグ
    ordMain.setIsConfirm(AdminWebConstant.FlagType.FLAG_OFF);
    // 実績：特殊浄化回数
    ordMain.setRstPurificationCnt(null);

    /* add by chamaojia 2024-01-22 [10196] When the data is restored to [rst_dialys_state='0'] --start */
    ordMain.setIndTreatmentName(null);
    ordMain.setIndKurName(null);
    ordMain.setIndBedName(null);
    ordMain.setIndDeviceMode(null);
    ordMain.setAdditionInfo(null);
    // add 10443 身体情報・DW・目標体重バグ 関  start
    ordMain.setIndDwUserInfo(null);
    ordMain.setIndDw(null);
    // add 10443 身体情報・DW・目標体重バグ 関  end

    String[] mediAndEquipDeleteKeys = {"class_cd", "class_name",
            "class_type", "name", "short_name", "unit"};
    // 指示：投与薬剤情報
    if (ordMain.getIndMediInfo() != null && !"[]".equals(ordMain.getIndMediInfo())) {
      JSONArray indMediInfoArray = new JSONArray(ordMain.getIndMediInfo());
      for (int i = 0; i < indMediInfoArray.length(); i++) {
        JSONObject indMediInfo = indMediInfoArray.getJSONObject(i);
        for (String deleteKey : mediAndEquipDeleteKeys) {
          indMediInfo.remove(deleteKey);
        }
        indMediInfo.remove("timing_name");
        indMediInfo.remove("procedure_name");
      }
      ordMain.setIndMediInfo(indMediInfoArray.toString());
    }

    // 指示：医療材料情報
    if (ordMain.getIndEquipInfo() != null && !"[]".equals(ordMain.getIndEquipInfo())) {
      JSONArray indEquipInfoArray = new JSONArray(ordMain.getIndEquipInfo());
      for (int i = 0; i < indEquipInfoArray.length(); i++) {
        JSONObject indEquipInfo = indEquipInfoArray.getJSONObject(i);
        for (String deleteKey : mediAndEquipDeleteKeys) {
          indEquipInfo.remove(deleteKey);
        }
      }
      ordMain.setIndEquipInfo(indEquipInfoArray.toString());
    }

    // 指示：治療条件情報
    if (ordMain.getIndCondInfo() != null) {
      JSONObject indCondInfo = new JSONObject(ordMain.getIndCondInfo());
//      indCondInfo.remove(TreatmentItemsDef.T_I_DW.getItemCode());
      for (String indCondKey : indCondInfo.keySet()) {
        JSONObject item = (JSONObject)indCondInfo.get(indCondKey);
        item.remove("unit");
        item.remove("value_name_1");
        // "5:ダイアライザ" exist 'value_name_2'
        if ("5".equals(indCondKey)) {
          item.remove("value_name_2");
        }
      }
      ordMain.setIndCondInfo(indCondInfo.toString());
    }
    /* add by chamaojia 2024-01-22 [10196] When the data is restored to [rst_dialys_state='0'] --end */

    /* add by chamaojia 2025-01-16 [11467] add null value content --start */
    ordMain.setRstEditionDate(null);
    ordMain.setCurEditionDate(null);
    ordMain.setBvmsPath(null);
    ordMain.setRstDeviceMode(null);
    /* add by chamaojia 2025-01-16 [11467] add null value content --end */

    return ordMain;
  }

  /**
   * 与えられたオーダの予定部分をクリアする.
   * ※この関数を呼び出す事で削除フラグもオンになる.
   * ※また、この関数は削除する側の{@link OrdMain}が対象
   *
   * @param ordMain オーダ番号
   * @return 予定部分をクリアした{@link OrdMain}
   */
  private OrdMain clearInstructionsPart(OrdMain ordMain) {
    // オーダ番号
    ordMain.setOrdNo(null);
    // 指示：VAコード
    ordMain.setIndVaCd(null);
    // 指示：治療方法コード
    ordMain.setIndTreatmentCd(null);
    // 指示：治療方法名
    ordMain.setIndTreatmentName(null);
    // 指示：クールコード
    ordMain.setIndKurCd(null);
    // 指示：クール名
    ordMain.setIndKurName(null);
    // 指示：治療開始時刻
    ordMain.setIndTreatStartTime(null);
    // 指示：ベッドコード
    ordMain.setIndBedCd(null);
    // 指示：ベッド名
    ordMain.setIndBedName(null);
    // 指示：治療予定指示者情報
    ordMain.setIndScheduleUserInfo("{}");
    // 指示：治療条件情報
    ordMain.setIndCondInfo("{}");
    // 指示：投与薬剤情報
    ordMain.setIndMediInfo("[]");
    // 指示：医療材料情報
    ordMain.setIndEquipInfo("[]");
    // 指示：指示コメント情報
    ordMain.setIndIndCommentInfo("[]");
    // 指示：風袋補正
    ordMain.setIndTareInfo("{}");
    // 指示：除水補正
    ordMain.setIndOffWaterInfo("{}");
    // 指示：装置設定情報
    ordMain.setIndDeviceSetInfo("{}");
    // 治療種別
    ordMain.setTreatType(null);
    // 指示：DW
    ordMain.setIndDw(null);
    // 削除フラグ
    ordMain.setIsDel(AdminWebConstant.FlagType.FLAG_ON);

    /* add by chamaojia 2024-01-22 [10196] When the data is restored to [rst_dialys_state='0'] --start */
    String[] mediAndEquipDeleteKeys = {"class_cd", "class_name",
            "class_type", "name", "short_name", "unit"};
    // 指示：投与薬剤情報
    if (ordMain.getIndMediInfo() != null && !"[]".equals(ordMain.getIndMediInfo())) {
      JSONArray indMediInfoArray = new JSONArray(ordMain.getIndMediInfo());
      for (int i = 0; i < indMediInfoArray.length(); i++) {
        JSONObject indMediInfo = indMediInfoArray.getJSONObject(i);
        for (String deleteKey : mediAndEquipDeleteKeys) {
          indMediInfo.remove(deleteKey);
        }
        indMediInfo.remove("timing_name");
        indMediInfo.remove("procedure_name");
      }
      ordMain.setIndMediInfo(indMediInfoArray.toString());
    }

    // 指示：医療材料情報
    if (ordMain.getIndEquipInfo() != null && !"[]".equals(ordMain.getIndEquipInfo())) {
      JSONArray indEquipInfoArray = new JSONArray(ordMain.getIndEquipInfo());
      for (int i = 0; i < indEquipInfoArray.length(); i++) {
        JSONObject indEquipInfo = indEquipInfoArray.getJSONObject(i);
        for (String deleteKey : mediAndEquipDeleteKeys) {
          indEquipInfo.remove(deleteKey);
        }
      }
      ordMain.setIndEquipInfo(indEquipInfoArray.toString());
    }

    // 指示：治療条件情報
    if (ordMain.getIndCondInfo() != null) {
      JSONObject indCondInfo = new JSONObject(ordMain.getIndCondInfo());
//      indCondInfo.remove(TreatmentItemsDef.T_I_DW.getItemCode());
      for (String indCondKey : indCondInfo.keySet()) {
        JSONObject item = (JSONObject)indCondInfo.get(indCondKey);
        item.remove("unit");
        item.remove("value_name_1");
        // "5:ダイアライザ" exist 'value_name_2'
        if ("5".equals(indCondKey)) {
          item.remove("value_name_2");
        }
      }
      ordMain.setIndCondInfo(indCondInfo.toString());
    }
    /* add by chamaojia 2024-01-22 [10196] When the data is restored to [rst_dialys_state='0'] --end */

    return ordMain;
  }

  //add FNSI修正401対応 房 start
  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  // mod #6848 2022-08-26 透析実績を削除しても次患者は戻らない。 dou start
//  public void deleteTreatmentRecordByOrdNo(Long ordNo, String facilityCd) throws NotExistException {
  public OrdMain deleteTreatmentRecordByOrdNo(Long ordNo, String facilityCd) throws NotExistException {
    OrdMain returnValue = new OrdMain();
    returnValue.setOrdNo(ordNo);
    returnValue.setFacilityCd(facilityCd);
    // mod #6848 2022-08-26 透析実績を削除しても次患者は戻らない。 dou end
    // オーダ番号に該当するord_mainを取得する.
    OrdMain targetOrdMain = ordMainDao.selectByOrdNo(ordNo);
    //add FNSI-修正、#6305 fang start
    Long delBedCd = null;
    if (targetOrdMain.getRstBedCd() != null) {
      delBedCd = Long.valueOf(targetOrdMain.getRstBedCd());
      // add #6848 2022-08-26 透析実績を削除しても次患者は戻らない。 dou start
      returnValue.setRstBedCd(targetOrdMain.getRstBedCd());
      returnValue.setTreatDate(targetOrdMain.getTreatDate());
      // add #6848 2022-08-26 透析実績を削除しても次患者は戻らない。 dou end
    }
    //add FNSI-修正、#6305 fang end
    if (Objects.isNull(targetOrdMain)) {
      throw new NotExistException(String.format("治療記録削除:オーダ番号に該当する情報が存在しません。オーダ番号[%d]", ordNo));
    }

    if (AdminWebConstant.OrdMainConst.DialysisState.AFTER_DIALYSIS.equals(targetOrdMain.getRstDialysisState())
      || AdminWebConstant.OrdMainConst.DialysisState.AFTER_WEIGHT.equals(targetOrdMain.getRstDialysisState())
      || AdminWebConstant.OrdMainConst.DialysisState.PAST_RECORD.equals(targetOrdMain.getRstDialysisState())) {
      //del 9324 ord_checklist共通之外的dao方法删除 gjn start
      //ordChecklistDao.deleteByOrdNo(ordNo, facilityCd);
      //del 9324 ord_checklist共通之外的dao方法删除 gjn end
    }

    OrdMainRestore ordMainRestore = new OrdMainRestore();
    Class<?> ordMainClass = targetOrdMain.getClass();
    Class<?> ordMainRestoreClass = ordMainRestore.getClass();
    Field[] ordMainFields = ordMainClass.getDeclaredFields();
    for (Field f : ordMainFields) {
      Field tempFileld = null;
      try {
        tempFileld = ordMainRestoreClass.getDeclaredField(f.getName());
        tempFileld.setAccessible(true);
        f.setAccessible(true);
        tempFileld.set(ordMainRestore, f.get(targetOrdMain));
      } catch (NoSuchFieldException | IllegalAccessException e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        if (!StringUtils.isEmpty(facilityCd)) {
          eventLogMessage.setFacilityCd(facilityCd);
        }
        logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
      }
    }
    ordMainRestore.setDelDate(new Timestamp(System.currentTimeMillis()));
    ordMainRestoreDao.insert(ordMainRestore);
    // 取得したord_mainをコピーする.
//    OrdMain deleteOrdMain = new OrdMain();
//    BeanUtils.copyProperties(targetOrdMain, deleteOrdMain);

    // add FNSI-改修内容追加OrdMain履歴 付 start
    //----------------------------------------
    // オーダの削除（論理削除）
    // ・透析予定部をクリア
    //----------------------------------------
    // 予定部分をクリアする.
//    clearInstructionsPart(deleteOrdMain);
    //　コピーしたord_mainを登録する.
//    ordMainDao.insert(deleteOrdMain);

    // #11266 2024.11.27 mod 通信サーバへ通知を行ってから透析実績部をクリアする TDC高村 start
    /*
    //----------------------------------------
    // オーダの更新
    // ・透析実績部をクリア
    // ・通信サーバへの通知
    // ・患者の治療進捗状態の更新
    //----------------------------------------
    // 実績部分をクリアする.
    clearResultPart(targetOrdMain);
    // 更新日時を更新
    targetOrdMain.setUpDate(new Timestamp(System.currentTimeMillis()));

    getHistory(ordNo);
    // mangoDb-update
    // add FNSI-改修内容追加OrdMain履歴 付 end

    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
    LogEventUtils.setOperatorId(targetOrdMain);
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
    // 更新する.
    //add FNSI-修正、#6305 fang start
    if (delBedCd != null) {
      List<MstMachine> machines = mstMachineDao.selectByBedCd(facilityCd, delBedCd);
      if (machines != null && machines.size() > 0) {
        MstMachine mstMachine = machines.get(0);
        resetMotionRecord(mstMachine.getFacilityCd(), mstMachine.getMachineTypeCd(), mstMachine.getMachineSerial(), ordNo);
        resetMniMonitor(ordNo);
      }
    }
    ordTreatConditionDao.deleteByOrdNo(ordNo, new Timestamp(System.currentTimeMillis()));
    //add FNSI-修正、#6305 fang end
    OrdMain oldOrdMain = ordMainDao.selectByOrdNo(targetOrdMain.getOrdNo());
    ordMainDao.update(targetOrdMain);
    OrdMain newOrdMain = ordMainDao.selectByOrdNo(targetOrdMain.getOrdNo());
    triggerUtil.updateTriggerOrdMain(Collections.singletonList(oldOrdMain),
      Collections.singletonList(newOrdMain));

    // 通信サーバへの通知処理

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("治療記録削除:通信サーバへの通知：対象オーダ番号[" + ordNo + "]");
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_TREATMENT_RECORD, SERVICE_NAME.FNSI, null);
    if (!notificationToComServer(targetOrdMain.getFacilityCd(), ordNo)) {

      eventLogMessage.setLogMessage("治療記録削除:通信サーバへの通知に失敗しました.");
      logService.log(LogLevel.WARN, eventLogMessage, FUNCTION_CODE.FUNC_TREATMENT_RECORD, SERVICE_NAME.FNSI, null);
    }
    */

    //----------------------------------------
    // オーダの更新
    // ・通信サーバへの通知
    // ・透析実績部をクリア
    // ・患者の治療進捗状態の更新
    //----------------------------------------
    // 通信サーバへの通知処理
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("治療記録削除:通信サーバへの通知：対象オーダ番号[" + ordNo + "]");
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_TREATMENT_RECORD, SERVICE_NAME.FNSI, null);
    if (!notificationToComServer(targetOrdMain.getFacilityCd(), ordNo)) {
      eventLogMessage.setLogMessage("治療記録削除:通信サーバへの通知に失敗しました.");
      logService.log(LogLevel.WARN, eventLogMessage, FUNCTION_CODE.FUNC_TREATMENT_RECORD, SERVICE_NAME.FNSI, null);
    }

    // 実績部分をクリアする.
    clearResultPart(targetOrdMain);
    // 更新日時を更新
    targetOrdMain.setUpDate(new Timestamp(System.currentTimeMillis()));

    getHistory(ordNo);
    // mangoDb-update
    // add FNSI-改修内容追加OrdMain履歴 付 end

    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
    LogEventUtils.setOperatorId(targetOrdMain,logService);
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end

    // 更新する.
    //add FNSI-修正、#6305 fang start
    if (delBedCd != null) {
      List<MstMachine> machines = mstMachineDao.selectByBedCd(facilityCd, delBedCd);
      if (machines != null && machines.size() > 0) {
        MstMachine mstMachine = machines.get(0);
        resetMotionRecord(mstMachine.getFacilityCd(), mstMachine.getMachineTypeCd(), mstMachine.getMachineSerial(), ordNo);
        resetMniMonitor(ordNo);
      }
    }
    ordTreatConditionDao.deleteByOrdNo(ordNo, new Timestamp(System.currentTimeMillis()));
    //add FNSI-修正、#6305 fang end
    OrdMain oldOrdMain = ordMainDao.selectByOrdNo(targetOrdMain.getOrdNo());
    ordMainDao.update(targetOrdMain);
    OrdMain newOrdMain = ordMainDao.selectByOrdNo(targetOrdMain.getOrdNo());
    triggerUtil.updateTriggerOrdMain(Collections.singletonList(oldOrdMain),
      Collections.singletonList(newOrdMain));
    // #11266 2024.11.27 mod 通信サーバへ通知を行ってから透析実績部をクリアする TDC高村 end

    // 患者の治療進捗状態の更新
    Long patId = targetOrdMain.getPatId();
    eventLogMessage.setLogMessage("治療記録削除:患者の治療進捗状態を更新：対象患者番号[" +  patId + "]");
    eventLogMessage.setPatId(String.valueOf(patId));
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_TREATMENT_RECORD, SERVICE_NAME.FNSI, null);
    patMainDao.updateResetAcceptanceStatus(patId, new Timestamp(System.currentTimeMillis()));

    // add FNSI No.396 治療記録 実績削除 start -- Sanjingye Sun 20210127
    // mod 12250 ord_material_saveの処理を2回重複実行している zkm start
//    ordMaterialSaveDao.deleteRstDataByOrdNo(ordNo);
    ordMaterialSaveService.bulkUpdateByOrdNoInCondMediEquipTreatment(Collections.singletonList(ordNo));
    // mod 12250 ord_material_saveの処理を2回重複実行している zkm end

    // add #10739 コンバート施設で指示受け(治療単位)が表示されない 関 start
    List <Long> ordNos = new ArrayList();
    ordNos.add(ordNo);
    sendConditionCancelService.resetPatIndApprove(ordNos);
    // add #10739 コンバート施設で指示受け(治療単位)が表示されない 関 end
    // del 11613 by shiyw 20250307 start
    // 「確定フラグ」を 1 → 0 に変更
    // ordMaterialSaveService.cancelSendCondition(ordNo);
    // del 11613 by shiyw 20250307 end

    // add FNSI No.396 治療記録 実績削除 end -- Sanjingye Sun 20210127
    // add #6848 2022-08-26 透析実績を削除しても次患者は戻らない。 dou start
    return returnValue;
    // add #6848 2022-08-26 透析実績を削除しても次患者は戻らない。 dou end
  }
  //add FNSI修正401対応 房 end
  // add #6848 2022-08-26 透析実績を削除しても次患者は戻らない。 dou start
  /**
   * 次患者更新
   *
   * @param ordMain 透析情報
   * @throws NotExistException
   */
  @Override
  @Transactional
  public void setNextPat(OrdMain ordMain) throws NotExistException {
    // 本日の日付け取得
    LocalDateTime nowDate = LocalDateTime.now();
    DateTimeFormatter dateTimeFormatter = DateTimeFormatter.ofPattern("yyyyMMdd");
    String today = nowDate.format(dateTimeFormatter);
    if (today.equals(ordMain.getTreatDate())) {
      List<MntMachineState> mntMachineStates = mntMachineStateDao.selectByBedCd(ordMain.getRstBedCd().longValue());
      if (mntMachineStates.size() > 0) {
        MntMachineState mntMachineState = mntMachineStates.get(0);
        Integer machineStatus = mntMachineState.getMachineStatus();
        // mod 8069 治療実績の削除を行うと送信失敗・治療記録削除失敗のダイアログが表示される 周安寧 start
        //if (0 == machineStatus) {
        if (machineStatus != null && 0 == machineStatus) {
        // mod 8069 治療実績の削除を行うと送信失敗・治療記録削除失敗のダイアログが表示される 周安寧 end
          try {
            // 次患者更新処理
            /* mod #5482 by zhangruixue 2023-03-02 スケジュール --start */
//            ordMainResource.callDoCancelSetNextPatInfo(ordMain.getFacilityCd(), ordMain.getRstBedCd().longValue(),
//              ordMain.getRstBedCd().longValue(), ordMain.getOrdNo(), false, nowDate);
            ordMainResource.callDoCancelSetNextPatInfo(ordMain.getFacilityCd(), ordMain.getRstBedCd().longValue(),
              ordMain.getRstBedCd().longValue(), ordMain, false, nowDate);
            /* mod #5482 by zhangruixue 2023-03-02 スケジュール --end */
          } catch (RuntimeException e) {
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage("「条件送信キャンセル」「次患者更新」処理失敗");
            logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_TREATMENT_RECORD, SERVICE_NAME.FNSI, null);
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 mod yangxuewang start
            eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
            if (ordMain != null && ordMain.getFacilityCd() != null) {
              eventLogMessage.setFacilityCd(ordMain.getFacilityCd());
            }
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 mod yangxuewang end
            logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_TREATMENT_RECORD, SERVICE_NAME.FNSI, null);
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
          }
        }
      }
    }
  }
  // add #6848 2022-08-26 透析実績を削除しても次患者は戻らない。 dou end
  //add FNSI-修正、#6305 fang start
  /**
   * {@inheritDoc}
   */
  public void resetMotionRecord(String facilityCd, String machineTypeCd, String machineSerial,
                                                       Long ordNo) {

    try {

      // SQL検索条件
      StringBuffer wheres = new StringBuffer("");
      wheres.append(" WHERE\n");
      wheres.append(" facility_cd = '" + facilityCd + "'" +"\n");
      wheres.append(" AND\n");
      wheres.append(" machine_type_cd = '" + machineTypeCd + "'" +"\n");
      wheres.append(" AND\n");
      wheres.append(" trim(machine_serial) = trim('" + machineSerial  + "')" +"\n");
      wheres.append(" AND\n");
      wheres.append(" ord_no = " + ordNo  + "\n");

       mntMotionRecordDao.updateClearOrdNo(facilityCd, machineTypeCd, machineSerial, ordNo,
        new Timestamp(System.currentTimeMillis()));
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (facilityCd != null) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_TREATMENT_RECORD, SERVICE_NAME.FNSI, null);
    }
  }

  /**
   * {@inheritDoc}
   */
  public void resetMniMonitor(Long ordNo) {

    try {
      // SQL検索条件
      StringBuffer wheres = new StringBuffer("");
      wheres.append(" WHERE\n");
      wheres.append(" ord_no = " + ordNo + "\n");
      // FNSI-修正、#6305、バイタルデータ未削除の対応、xugj del start
      // wheres.append(" AND\n");
      // wheres.append(" data_type = 1" + "\n");
      // FNSI-修正、#6305、バイタルデータ未削除の対応、xugj del end
      mniMonitorDao.updateClearOrdNo(ordNo, new Timestamp(System.currentTimeMillis()));
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_TREATMENT_RECORD, SERVICE_NAME.FNSI, null);
    }
  }
  //add FNSI-修正、#6305 fang end
}
