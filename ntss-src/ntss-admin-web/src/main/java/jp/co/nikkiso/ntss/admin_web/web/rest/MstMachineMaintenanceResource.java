package jp.co.nikkiso.ntss.admin_web.web.rest;

import java.util.List;

import jp.co.nikkiso.ntss.core.entity.MntFindMachine;
import jp.co.nikkiso.ntss.core.entity.MstDeviceEdge;
import jp.co.nikkiso.ntss.core.entity.MstMachine;
import jp.co.nikkiso.ntss.core.entity.MstMachineType;
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
import jp.co.nikkiso.ntss.admin_web.request.masterMaintenance.machine.MstMachineChangeMachineRequest;
import jp.co.nikkiso.ntss.admin_web.request.masterMaintenance.machine.MstMachineSwitchOfflineRequest;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.master.machine.MntFindMachineService;
import jp.co.nikkiso.ntss.admin_web.service.master.machine.MstMachineService;
import jp.co.nikkiso.ntss.admin_web.service.mstSynchro.MstSynchroService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.FUNCTION_CODE;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;


/**
 * 装置マスタマンテナンス画面のResourceクラス.
 */
@RestController
@RequestMapping(Uri.MASTER_MAINTENANCE)
public class MstMachineMaintenanceResource {

  @Autowired
  MstMachineService mstMachineService;

  @Autowired
  MntFindMachineService mntFindMachineService;

  @Autowired
  private MstSynchroService mstSynchroService;

	@Autowired
	LogService logService;

  /**
   * 装置マスタのレスポンス
   */
  public class MstMachineResponse {
    /**
     * 装置型式マスタ情報リスト
     */
    public List<MstMachineType> machineTypeList;

    /**
     * デバイスエッジマスタ情報リスト
     */
    public List<MstDeviceEdge> deviceEdgeList;
  }

  /**
  * 型式マスタ、デバイスエッジマスタのデータ取得.
  *
  * @return マスタデータのResponse
  *
  */
 @GetMapping("/mst_machine/combos")
 public ResponseEntity<?> getCombosData(@AuthenticationPrincipal NtssUser ntssUser) {

  // ログ出力
  EventLogMessage eventLogMessage = new EventLogMessage();
  eventLogMessage.setLogMessage( "REST request to get combo data for mst_machine maintenance. facilityCd:["+ntssUser.getFacilityCd()+"]");
  logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_DETAIL_MACHINES_LIST, SERVICE_NAME.FNSI, null);

   try {
     // 型式マスタのレスポンス生成
     List<MstMachineType> res_machine_type = mstMachineService.selectMachineTypeAll();

     // デバイスエッジマスタのレスポンス生成
     List<MstDeviceEdge> res_device_edge = mstMachineService.selectDeviceEdgeByFacilityCd(ntssUser.getFacilityCd());

     // レスポンス作成
     MstMachineResponse response = new MstMachineResponse();
     response.machineTypeList = res_machine_type;
     response.deviceEdgeList = res_device_edge;

     return new ResponseEntity<>(response, HttpStatus.OK);

   } catch (Exception e) {

     // マスタが取得できなかった場合
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
     if (ntssUser != null && ntssUser.getFacilityCd() != null) {
       eventLogMessage.setFacilityCd(ntssUser.getFacilityCd());
     }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_DETAIL_MACHINES_LIST, SERVICE_NAME.FNSI, null);
     return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
   }

 }

 /**
 * 型式マスタ、デバイスエッジマスタのデータ取得(施設コード指定).
 *
 * @return マスタデータのResponse
 *
 */
@GetMapping("/mst_machine/combos/{facilityCd}")
public ResponseEntity<?> getCombosData(@PathVariable String facilityCd) {

  // ログ出力
  EventLogMessage eventLogMessage = new EventLogMessage();
  eventLogMessage.setLogMessage( "REST request to get combo data for mst_machine maintenance by facilityCd. facilityCd:["+facilityCd+"]");
  logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_DETAIL_MACHINES_LIST, SERVICE_NAME.FNSI, null);

  try {
    // 型式マスタのレスポンス生成
    List<MstMachineType> res_machine_type = mstMachineService.selectMachineTypeAll();

    // デバイスエッジマスタのレスポンス生成
    // mod #11015 デバイスエッジマスタで項目を削除した際に関連マスタで表示不正 zkm start
//    List<MstDeviceEdge> res_device_edge = mstMachineService.selectDeviceEdgeByFacilityCd(facilityCd);
    List<MstDeviceEdge> res_device_edge = mstMachineService.selectAllDeviceEdgeByFacilityCd(facilityCd);
    // mod #11015 デバイスエッジマスタで項目を削除した際に関連マスタで表示不正 zkm end

    // レスポンス作成
    MstMachineResponse response = new MstMachineResponse();
    response.machineTypeList = res_machine_type;
    response.deviceEdgeList = res_device_edge;

    return new ResponseEntity<>(response, HttpStatus.OK);

  } catch (Exception e) {

    // マスタが取得できなかった場合
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
    if (facilityCd != null) {
      eventLogMessage.setFacilityCd(facilityCd);
    }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_DETAIL_MACHINES_LIST, SERVICE_NAME.FNSI, null);
    return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
  }

}
  //add 9871デバイスエッジが並び順の通りに表示しない zhao start
  @GetMapping("/mst_machine/combos1/{facilityCd}")
  public ResponseEntity<?> getCombosData1(@PathVariable String facilityCd) {

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage( "REST request to get combo data for mst_machine maintenance by facilityCd. facilityCd:["+facilityCd+"]");
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_DETAIL_MACHINES_LIST, SERVICE_NAME.FNSI, null);

    try {
      // 型式マスタのレスポンス生成
      List<MstMachineType> res_machine_type = mstMachineService.selectMachineTypeAll();

      // デバイスエッジマスタのレスポンス生成
      // mod #11015 デバイスエッジマスタで項目を削除した際に関連マスタで表示不正 zkm start
//      List<MstDeviceEdge> res_device_edge = mstMachineService.selectDeviceEdgeByFacilityCd(facilityCd);
      List<MstDeviceEdge> res_device_edge = mstMachineService.selectAllDeviceEdgeByFacilityCd(facilityCd);
      // mod #11015 デバイスエッジマスタで項目を削除した際に関連マスタで表示不正 zkm end

      //9871 addデバイスエッジが並び順の通りに表示しない zhao start
      List<MstDeviceEdge> res_device_edgeReturn = mstMachineService.selectByOrderItem(facilityCd,res_device_edge);
      //9871 addデバイスエッジが並び順の通りに表示しない zhao end
      // レスポンス作成
      MstMachineResponse response = new MstMachineResponse();
      response.machineTypeList = res_machine_type;
      //9871 modデバイスエッジが並び順の通りに表示しない zhao start
      //response.deviceEdgeList = res_device_edge;
      response.deviceEdgeList = res_device_edgeReturn;
      //9871 modデバイスエッジが並び順の通りに表示しない zhao end

      return new ResponseEntity<>(response, HttpStatus.OK);

    } catch (Exception e) {

      // マスタが取得できなかった場合
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (facilityCd != null) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_DETAIL_MACHINES_LIST, SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }

  }
  //add 9871デバイスエッジが並び順の通りに表示しない zhao end
  /**
   * 型式マスタデータ取得.
   *
   * @return マスタデータのResponse
   */
  @GetMapping("/mst_machine/mst_machine_type")
  public ResponseEntity<?> getMasterData() {

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get mst_machine_type records for mst_machine maintenance");
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_DETAIL_MACHINES_LIST, SERVICE_NAME.FNSI, null);

    try {
      // レスポンス生成
      List<MstMachineType> response = mstMachineService.selectMachineTypeAll();
      return new ResponseEntity<>(response, HttpStatus.OK);

    } catch (Exception e) {

      // マスタ定義が取得できなかった場合
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_DETAIL_MACHINES_LIST, SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }

  }

  /**
   * 対象施設のデバイスエッジ情報を取得.
   *
   * @return デバイスエッジマスタ情報のresponse
   */
  @GetMapping("/mst_machine/mst_device_edge")
  public ResponseEntity<?> getMstDeviceEdge(@AuthenticationPrincipal NtssUser ntssUser) {

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage( "REST request to get mst_device_edge records for mst_machine maintenance. facilityCd:["+ntssUser.getFacilityCd()+"]");
    logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_DETAIL_MACHINES_LIST, SERVICE_NAME.FNSI, null);

    // レスポンス生成
    List<MstDeviceEdge> response = mstMachineService.selectDeviceEdgeByFacilityCd(ntssUser.getFacilityCd());

    return new ResponseEntity<>(response, HttpStatus.OK);
  }

  /**
   * 装置マスタ同期
   *
   * @param deviceEdgeNo 対象デバイスエッジ番号
   * @param facilityCd 施設コード
   * @return
   */
  @PostMapping("/mst_machine/synchro/{deviceEdgeNo}/{facilityCd}")
  public ResponseEntity<?> synchroMstMachine(
      @PathVariable(name = "deviceEdgeNo", required = true) Integer deviceEdgeNo,
      @PathVariable(name = "facilityCd", required = true) String facilityCd) {
    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage( "REST request to post synchro mst_machine records for mst_machine maintenance. facilityCd:["+facilityCd+"]");
    logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_DETAIL_MACHINES_LIST, SERVICE_NAME.FNSI,
    null);

    try {
      // マスタ同期開始処理[装置マスタのみ、指定デバイスエッジを対象]
      HttpStatus res = HttpStatus.OK;
      if( this.mstSynchroService.startMstSynchro(facilityCd, "mst_machine", deviceEdgeNo) == false )
      {
        // 通知失敗
        res = HttpStatus.BAD_REQUEST;
      }
      return new ResponseEntity<>(res);
    } catch(Exception e) {

      // 処理ができなかった場合
    	// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (facilityCd != null) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
    	logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_DETAIL_MACHINES_LIST, SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * オンラインからオフライン装置に切り替えられた装置のステータスを準備状態にする
   * @param facilityCd 施設コード
   * @param codeList 装置番号
   * @return
   */
  @PutMapping("/mst_machine/state/offline")
  public ResponseEntity<?> updateStateOffline(
      @RequestBody MstMachineSwitchOfflineRequest request
      ) {
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage( "REST request to put update mnt_machine_state at offline for mst_machine maintenance. facilityCd:["+request.getFacilityCd()+"]");
    logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_DETAIL_MACHINES_LIST, SERVICE_NAME.FNSI,
    null);

    try {
      /* del by zhouyingying  2023-02-01 [Transaction] start */
//      if (request.getNewOfflineCodeList() != null && request.getNewOfflineCodeList().size() > 0) {
//        // オフライン更新対象がない場合は何もしないで返す
//        mstMachineService.updateStateOfflineMachines(request.getFacilityCd(), request.getNewOfflineCodeList());
//      }
//      if (request.getNewOnlineCodeList() != null && request.getNewOnlineCodeList().size() > 0) {
//        // オンライン更新対象がない場合は何もしないで返す
//        mstMachineService.updateStateOnlineMachines(request.getFacilityCd(), request.getNewOnlineCodeList());
//      }
      /* del by zhouyingying  2023-02-01 [Transaction] end */

      /* add by zhouyingying  2023-02-01 [Transaction] start */
      mstMachineService.updateStateOffline(request);
      /* add by zhouyingying  2023-02-01 [Transaction] end */

    return new ResponseEntity<>(HttpStatus.OK);
    } catch (Exception e) {
      // 更新できなかった場合
     eventLogMessage.setLogMessage( e.getMessage());
     logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_DETAIL_MACHINES_LIST, SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }


  /**
   * （装置自動登録）通知指示
   *
   * @param facilityCd 施設コード
   * @return
   */
  @PostMapping("/mst_machine/notification/{procMode}/{facilityCd}")
  public ResponseEntity<?> notificationMstFindMachine(
      @PathVariable(name = "procMode", required = true) Integer procMode,
      @PathVariable(name = "facilityCd", required = true) String facilityCd) {
    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage( "REST request to post mst_find_machine records for mst_machine maintenance. facilityCd:["+facilityCd+"]");
    logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_DETAIL_MACHINES_LIST, SERVICE_NAME.FNSI,
    null);

    try {
      // 装置検索処理
      HttpStatus res = HttpStatus.OK;
      /* del by zhouyingying  2023-02-01 [Transaction] start */
//      if(procMode.equals(1)) {
//          this.mntFindMachineService.deleteByFacilityCd(facilityCd);
//      }
//      // 装置検索指示を同一施設のDEに通知
//      List<MstDeviceEdge> res_device_edge = mstMachineService.selectDeviceEdgeByFacilityCd(facilityCd);
//      for (MstDeviceEdge mstDeviceEdge : res_device_edge) {
//          if(mntFindMachineService.deviceSearch(facilityCd,procMode, mstDeviceEdge.getDeviceEdgeNo()) == false)
//          {
//            // 通知失敗
//            res = HttpStatus.BAD_REQUEST;
//          }
//      }
      /* del by zhouyingying  2023-02-01 [Transaction] end */

      /* add by zhouyingying  2023-02-01 [Transaction] start */
      if (!mstMachineService.notificationMstFindMachine(procMode, facilityCd)){
        res = HttpStatus.BAD_REQUEST;
      }
      /* add by zhouyingying  2023-02-01 [Transaction] end */
      return new ResponseEntity<>(res);
    } catch(Exception e) {
    	// 処理ができなかった場合
    	// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (facilityCd != null) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
    	logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_DETAIL_MACHINES_LIST, SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }


  /**
   * (装置自動登録)情報取得
   *
   * @return 装置自動登録処理用ワークテーブル情報のresponse
   */
  @GetMapping("/mst_machine/list/{facilityCd}")
  public ResponseEntity<?> getMstFindMachineByFacilityCd(@PathVariable String facilityCd) {
    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage( "REST request to get mst_find_machine records for mst_machine maintenance. facilityCd:["+facilityCd+"]");
    logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_DETAIL_MACHINES_LIST, SERVICE_NAME.FNSI, null);

    // レスポンス生成
    List<MntFindMachine> response = mntFindMachineService.selectByFacilityCd(facilityCd);

    return new ResponseEntity<>(response, HttpStatus.OK);
  }


  /**
   * 装置治療状態情報取得
   *
   * @return mnt_machine_state情報のresponse
   */
  @GetMapping("/mst_machine/dialysis-entry/{facilityCd}")
  public ResponseEntity<?> getMachineDyalysisState(@PathVariable String facilityCd) {
    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage( "REST request to get mst_machine by dialysis entry records for mst_machine maintenance. facilityCd:["+facilityCd+"]");
    logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_DETAIL_MACHINES_LIST, SERVICE_NAME.FNSI, null);

    // レスポンス生成
    List<MstMachine> response = mstMachineService.selectEntryMachineList(facilityCd);

    return new ResponseEntity<>(response, HttpStatus.OK);
  }

  /**
   * 型式や通信フォーマットを切り替えた装置のステータスを初期値状態にする
   * @param facilityCd 施設コード
   * @param codeList 装置番号
   * @return
   */
  @PutMapping("/mst_machine/change-machine")
  public ResponseEntity<?> updateChangeMachine(
      @RequestBody MstMachineChangeMachineRequest request
      ) {
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage( "REST request to put update mnt_machine_state at change key for mst_machine maintenance. facilityCd:["+request.getFacilityCd()+"]");
    logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_DETAIL_MACHINES_LIST, SERVICE_NAME.FNSI,
    null);

    try {
      /* del by zhouyingying  2023-02-01 [Transaction] start */
//      if (request.getNewOfflineAndCommonCodeList() != null && request.getNewOfflineAndCommonCodeList().size() > 0) {
//        // 工程更新対象がない場合は何もしないで返す
//        mstMachineService.updateProcStateToDefault(request.getFacilityCd(), request.getNewOfflineAndCommonCodeList());
//      }
//      if (request.getChangeMachineCodeList() != null && request.getChangeMachineCodeList().size() > 0) {
//        // 主キー更新対象がない場合は何もしないで返す
//        mstMachineService.updateMachineStatusToDefault(request.getFacilityCd(), request.getChangeMachineCodeList());
//      }
      /* del by zhouyingying  2023-02-01 [Transaction] end */

      /* add by zhouyingying  2023-02-01 [Transaction] start */
      mstMachineService.updateChangeMachine(request);
      /* add by zhouyingying  2023-02-01 [Transaction] end */

    return new ResponseEntity<>(HttpStatus.OK);
    } catch (Exception e) {
      // 更新できなかった場合
     eventLogMessage.setLogMessage( e.getMessage());
     logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_DETAIL_MACHINES_LIST, SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  // #11124 2025.08.26 add 酸素飽和度対応 TDC高村 start
  /**
   * 該当施設からΔSO2を使用する装置件数を取得します。
   *
   * @param facilityCd 施設コード
   * @return ΔSO2を使用する装置件数
   */
  @GetMapping("/mst_machine/So2OptCount/{facilityCd}")
  public ResponseEntity<?> getMachineSo2OptCount(@PathVariable String facilityCd) {
    try {
      // ログ出力
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("REST request to get MachineSo2OptCount : " + facilityCd);
      logService.log(LogLevel.DEBUG, eventLogMessage, "", SERVICE_NAME.REMS,
          null);
      // サービスの呼び出し
      Long res = mstMachineService.getMachineSo2OptCount(facilityCd);
      // 返却
      return new ResponseEntity<>(res, HttpStatus.OK);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("ΔSO2を使用する装置件数取得に失敗しました。" + e);
      logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.REMS,
          null);
    }
    return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
  }
  // #11124 2025.08.26 add 酸素飽和度対応 TDC高村 end
}
