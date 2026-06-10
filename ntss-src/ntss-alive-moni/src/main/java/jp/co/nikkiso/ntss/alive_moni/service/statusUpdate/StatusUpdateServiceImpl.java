package jp.co.nikkiso.ntss.alive_moni.service.statusUpdate;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;

import jp.co.nikkiso.ntss.alive_moni.service.AliveMoniService;
import jp.co.nikkiso.ntss.core.dao.MntMachineStateDao;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import jp.co.nikkiso.ntss.alive_moni.constant.AliveMoniConstant.CheckByteNum;
import jp.co.nikkiso.ntss.alive_moni.service.LogService;
import jp.co.nikkiso.ntss.alive_moni.service.MntDeviceEdgeStateService;
import jp.co.nikkiso.ntss.alive_moni.service.MntMachineStateService;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.entity.MntDeviceEdgeState;
import jp.co.nikkiso.ntss.core.entity.MntMachineState;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;

@Service
public class StatusUpdateServiceImpl implements StatusUpdateService {

  @Autowired
  private MntDeviceEdgeStateService mntDeviceEdgeStateSv;
  @Autowired
  private MntMachineStateService mntMachineStateSv;
  @Autowired
  private LogService logService;
  // add FNSI-バグ #7480 通信サーバ 高 start
  @Autowired
  private AliveMoniService aliveMoniSv;
  // add FNSI-バグ #7480 通信サーバ 高 end
  // #9243 2023.07.31 add 複数装置の 工程状態 と 通信不良有無 の更新を1つのSQL文で実施 TDC山崎 start
  @Autowired
  private MntMachineStateDao mntMachineStateDao;
  // #9243 2023.07.31 add 複数装置の 工程状態 と 通信不良有無 の更新を1つのSQL文で実施 TDC山崎 end
  /**
   * {@inheritDoc}
   */
  @Override
  // #9160 2023.07.14 del トランザクション処理を行わないようにする TDC米沢 start
  //@Transactional(rollbackFor = Exception.class)
  // #9160 2023.07.14 del トランザクション処理を行わないようにする TDC米沢 end
  public DoUpdateStatusResponse DoUpdateOfDeviceEdgeStatus(String facilityCd, Integer deviceEdgeNo, String edgeStatus,
      Timestamp nowDate) throws Exception {
    DoUpdateStatusResponse ret = new DoUpdateStatusResponse();
    // 対象デバイスエッジがデバイスエッジ状態管理上に存在しない場合はInsert、存在する場合はUpdate
    List<MntDeviceEdgeState> targetEdgeState = SelectMntDeviceEdgeState(facilityCd, deviceEdgeNo);
    if (null == targetEdgeState) {
      return ret;
    }

    if (0 == targetEdgeState.size()) {
      // 新規登録
     if (!InsertMntDeviceEdgeState(facilityCd, deviceEdgeNo, edgeStatus, null, nowDate, nowDate, nowDate)) {
       throw new RuntimeException("デバイスエッジの新規登録に失敗");
     };
    } else {
      // 更新
      ret.isNotice = CheckMustNotice(targetEdgeState.get(0), edgeStatus);
      if(!UpdateMntDeviceEdgeState(facilityCd, deviceEdgeNo, edgeStatus, nowDate)) {
        throw new RuntimeException("デバイスエッジの更新に失敗");
      };
    }

    // 通信断ステータス
    String[] disconnectParams = {
        CoreConstant.AliveMoniStatus.STOP,
        CoreConstant.AliveMoniStatus.CONNECTION_ERROR,
        CoreConstant.AliveMoniStatus.DEVICE_ERROR
    };

    if (Arrays.asList(disconnectParams).contains(edgeStatus)) {
      // デバイスエッジが通信断の場合、紐づく装置の工程を"99"にする
      if(!UpdateMntMachineStateEdge(facilityCd, deviceEdgeNo, "99", 1)){
        throw new RuntimeException("装置状態の更新に失敗");
      };
    }

    return ret;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  // #9160 2023.07.14 del トランザクション処理を行わないようにする TDC米沢 start
  //@Transactional(rollbackFor = Exception.class)
  // #9160 2023.07.14 del トランザクション処理を行わないようにする TDC米沢 end
  public DoUpdateStatusResponse DoUpdateOfDeviceEdgeWithMachineStatus(String facilityCd, Integer deviceEdgeNo,
      String edgeStatus, String machineInfo, Timestamp nowDate) throws Exception {
    DoUpdateStatusResponse ret = new DoUpdateStatusResponse();
    // 対象デバイスエッジがデバイスエッジ状態管理上に存在しない場合はInsert、存在する場合はUpdate
    List<MntDeviceEdgeState> targetEdgeState = SelectMntDeviceEdgeState(facilityCd, deviceEdgeNo);
    if (null == targetEdgeState) {
      return ret;
    }
    if (0 == targetEdgeState.size()) {
      // 新規登録
      if(!InsertMntDeviceEdgeState(facilityCd, deviceEdgeNo, edgeStatus, null, nowDate, nowDate, nowDate)) {
        throw new RuntimeException("デバイスエッジの新規登録に失敗");
      };
    } else {
      // 更新
      ret.isNotice = CheckMustNotice(targetEdgeState.get(0), edgeStatus);
      if(!UpdateMntDeviceEdgeState(facilityCd, deviceEdgeNo, edgeStatus, nowDate)) {
        throw new RuntimeException("デバイスエッジの更新に失敗");
      }
    }

    // 装置状態管理情報取得
    List<MntMachineState> targetMachineState = SelectMntMachineState(facilityCd);
    if (null == targetMachineState) {
      throw new RuntimeException("装置状態の取得に失敗");
    }

    // 装置情報の分割に使用
    int sIndex = 0;
    // 装置情報分ループし登録
    int cntDeviceInfo = machineInfo.length() / CheckByteNum.MachineInfoByteNum;

    // #9243 2023.07.31 chg 複数装置の 工程状態 と 通信不良有無 の更新を1つのSQL文で実施 TDC山崎 start
//    for (int i = 0; i < cntDeviceInfo; i++) {
//      Integer isPreventiveMainte = 0;
//      // 型式コード
//      String machineTypeCd = machineInfo.substring(sIndex, sIndex + CheckByteNum.MachineTypeCdByteNum);
//      sIndex += CheckByteNum.MachineTypeCdByteNum;
//
//      // 通信フォーマット
//      String machineComFormatCd = machineInfo.substring(sIndex, sIndex + CheckByteNum.ComFormatCdByteNum);
//      sIndex += CheckByteNum.ComFormatCdByteNum;
//
//      // 製造番号
//      String machineSerial = machineInfo.substring(sIndex, sIndex + CheckByteNum.MachineSerialByteNum).trim();
//      sIndex += CheckByteNum.MachineSerialByteNum;
//
//      // 工程状態
//      String processState = machineInfo.substring(sIndex, sIndex + CheckByteNum.ProcessStateByteNum);
//      sIndex += CheckByteNum.ProcessStateByteNum;
//
//      // 通信不良有無(工程状態が'99'の場合は「1:あり」、それ以外は「0:なし」)
//      isPreventiveMainte = ("99".equals(processState)) ? 1 : 0;
//
//      // 抽出用に別変数に格納(これをしないと以下filter処理でエラーが発生)
//      String compTypeCd = machineTypeCd;
//      String compSerial = machineSerial;
//
//      // 対象レコードが存在するか抽出
//      int cnt = targetMachineState.stream()
//          .filter(
//              ele -> compTypeCd.equals(ele.getMachineTypeCd()) && compSerial.equals(ele.getMachineSerial().trim()))
//          .collect(Collectors.toList()).size();
//
//      // 対象装置が装置状態管理上に存在しない場合はInsert、存在する場合はUpdate
//      if (0 == cnt) {
//        // ※装置状態管理テーブル上に存在することが前提なので存在しない場合はスルー
//        EventLogMessage eventLogMessage = new EventLogMessage();
//        eventLogMessage.setLogMessage("死活監視API：受信データの装置が装置状態管理テーブルに存在しない(登録せず処理継続)　施設コード[" + facilityCd
//            + "]、型式コード[" + machineTypeCd + "]、製造番号[" + machineSerial + "]");
//        eventLogMessage.setDeviceEdgeNo(deviceEdgeNo.toString());
//        eventLogMessage.setMachineTypeCd(machineTypeCd);
//        eventLogMessage.setFacilityCd(facilityCd);
//        //FNSI-修正 ログ対応 xiebzh add start
//        eventLogMessage.setInvokeClass(this.getClass().getName());
//        //FNSI-修正 ログ対応 xiebzh add end
//        logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.REMS, null);
//      } else {
//        // 更新
//        if(!UpdateMntMachineState(facilityCd, machineTypeCd, machineSerial, processState, isPreventiveMainte)) {
//          throw new RuntimeException("装置状態の更新に失敗");
//        }
//      }
//    }

    List<MntMachineState> mmsList = new ArrayList<MntMachineState>();

    for (int i = 0; i < cntDeviceInfo; i++) {
      Integer isPreventiveMainte = 0;
      // 型式コード
      String machineTypeCd = machineInfo.substring(sIndex, sIndex + CheckByteNum.MachineTypeCdByteNum);
      sIndex += CheckByteNum.MachineTypeCdByteNum;

      // 通信フォーマット
      String machineComFormatCd = machineInfo.substring(sIndex, sIndex + CheckByteNum.ComFormatCdByteNum);
      sIndex += CheckByteNum.ComFormatCdByteNum;

      // 製造番号
      String machineSerial = machineInfo.substring(sIndex, sIndex + CheckByteNum.MachineSerialByteNum).trim();
      sIndex += CheckByteNum.MachineSerialByteNum;

      // 工程状態
      String processState = machineInfo.substring(sIndex, sIndex + CheckByteNum.ProcessStateByteNum);
      sIndex += CheckByteNum.ProcessStateByteNum;

      // 通信不良有無(工程状態が'99'の場合は「1:あり」、それ以外は「0:なし」)
      isPreventiveMainte = ("99".equals(processState)) ? 1 : 0;

      // 抽出用に別変数に格納(これをしないと以下filter処理でエラーが発生)
      String compTypeCd = machineTypeCd;
      String compSerial = machineSerial;

      // 対象レコードが存在するか抽出
      int cnt = targetMachineState.stream()
          .filter(
              ele -> compTypeCd.equals(ele.getMachineTypeCd()) && compSerial.equals(ele.getMachineSerial().trim()))
          .collect(Collectors.toList()).size();

      // 対象装置が装置状態管理上に存在しない場合はその旨をログ出力、存在する場合はUpdate
      if (0 == cnt) {
        // ※装置状態管理テーブル上に存在することが前提なので存在しない場合はスルー
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("死活監視API：受信データの装置が装置状態管理テーブルに存在しない(登録せず処理継続)　施設コード[" + facilityCd
            + "]、型式コード[" + machineTypeCd + "]、製造番号[" + machineSerial + "]");
        eventLogMessage.setDeviceEdgeNo(deviceEdgeNo.toString());
        eventLogMessage.setMachineTypeCd(machineTypeCd);
        eventLogMessage.setFacilityCd(facilityCd);
        //FNSI-修正 ログ対応 xiebzh add start
        eventLogMessage.setInvokeClass(this.getClass().getName());
        //FNSI-修正 ログ対応 xiebzh add end
        logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.REMS, null);
      } else {
        MntMachineState one = new MntMachineState();

        one.setFacilityCd(facilityCd);
        one.setMachineTypeCd(machineTypeCd);
        one.setMachineSerial(machineSerial.trim()); // trimはSQL文側でやるよりjava側でやるほうが早い
        one.setProcessState(processState);
        one.setIsPreventiveMainte(isPreventiveMainte);

        mmsList.add(one);
      }
    }

    // 後からまとめて更新
    if (!mmsList.isEmpty()) {
      if (0 == mntMachineStateDao.updateProcessStateAndIsPreventiveMainteMultiple(mmsList)) {
        throw new RuntimeException("装置状態の更新に失敗");
      }
    }
    // #9243 2023.07.31 chg 複数装置の 工程状態 と 通信不良有無 の更新を1つのSQL文で実施 TDC山崎 end

    return ret;
  }



  /**
   * デバイスエッジ状態管理情報取得処理
   *
   * @param facilityCd
   * @param deviceEdgeNo
   * @return
   */
  private List<MntDeviceEdgeState> SelectMntDeviceEdgeState(String facilityCd, Integer deviceEdgeNo) {
    List<MntDeviceEdgeState> lst = mntDeviceEdgeStateSv.findById(facilityCd, deviceEdgeNo);
    if (null == lst) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage
          .setLogMessage("死活監視API：デバイスエッジ状態管理情報の取得に失敗　施設コード[" + facilityCd + "]、デバイスエッジ番号[" + deviceEdgeNo + "]");
      eventLogMessage.setDeviceEdgeNo(String.valueOf(deviceEdgeNo));
      eventLogMessage.setFacilityCd(facilityCd);
      //FNSI-修正 ログ対応 xiebzh add start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      //FNSI-修正 ログ対応 xiebzh add end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
    }
    return lst;
  }

  /**
   * 装置状態管理情報取得処理
   *
   * @param facilityCd
   * @return
   */
  private List<MntMachineState> SelectMntMachineState(String facilityCd) {
    List<MntMachineState> lst = this.mntMachineStateSv.findById(facilityCd);
    if (null == lst) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("死活監視API：装置状態管理情報の取得に失敗　施設コード[" + facilityCd + "]");
      eventLogMessage.setFacilityCd(facilityCd);
      //FNSI-修正 ログ対応 xiebzh add start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      //FNSI-修正 ログ対応 xiebzh add end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
    }

    return lst;
  }

  /**
   * デバイスエッジ状態の異常・正常メール通知が必要ならばtrueを返す
   * @param edgeState もともとのデバイスエッジ状態レコード
   * @param status 新しいデバイスエッジの通信状態
   * @return 正常←→異常の変化ならばTrue そうでないならばFalse
   */
  private boolean CheckMustNotice(MntDeviceEdgeState edgeState, String status) {
    String lastStatus = edgeState.getAliveMoniStatus();
    Short lastMailStatus = edgeState.getSendMailStatus();

    if (Objects.equals(lastStatus, CoreConstant.AliveMoniStatus.CONNECTION_ERROR)
        || Objects.equals(lastStatus, CoreConstant.AliveMoniStatus.DEVICE_ERROR)) {
      // 前回状態がエラー
      if (Objects.equals(status, CoreConstant.AliveMoniStatus.RUNNING)) {
        // 通信異常→通信中
        if (lastMailStatus == null || Objects.equals(lastMailStatus, CoreConstant.AliveMoniSendMailStatus.NO_SEND)) {
          // ①INFO=0ならばINFO=2に更新してメール発報API呼び出し。初回（null)の場合も同様。
          MntDeviceEdgeState newEdgeState = edgeState;
          newEdgeState.setSendMailStatus(CoreConstant.AliveMoniSendMailStatus.SEND_RECONNECT);
          mntDeviceEdgeStateSv.updateSendMailStatus(newEdgeState);
          return true;
        } else if (Objects.equals(lastMailStatus, CoreConstant.AliveMoniSendMailStatus.SEND_FAIL_CONNECT)) {
          // ②INFO=1ならば異常メールを送っていないことになるので、INFO=0に戻してメール発報APIを呼び出さない
          MntDeviceEdgeState newEdgeState = edgeState;
          newEdgeState.setSendMailStatus(CoreConstant.AliveMoniSendMailStatus.NO_SEND);
          mntDeviceEdgeStateSv.updateSendMailStatus(newEdgeState);
          return false;
        } else {
          // ③INFO=2ならばそのままメール発報API呼び出し
          return true;
        }
      } else {
        // 通信異常→通信異常
        if (Objects.equals(lastMailStatus, CoreConstant.AliveMoniSendMailStatus.NO_SEND)) {
          // ①INFO=0ならばメール発報済みなのでメール発報APIを呼び出さない
          return false;
        } else if (Objects.equals(lastMailStatus, CoreConstant.AliveMoniSendMailStatus.SEND_FAIL_CONNECT)) {
          // ②INFO=1ならばそのままメール発報API呼び出し
          return true;
        } else {
          // ③INFO=2ならば復旧メールを送っていないことになるので、INFO=0に更新してメール発報APIを呼び出さない。初回（null)の場合も同様。
          MntDeviceEdgeState newEdgeState = edgeState;
          newEdgeState.setSendMailStatus(CoreConstant.AliveMoniSendMailStatus.NO_SEND);
          mntDeviceEdgeStateSv.updateSendMailStatus(newEdgeState);
          return false;
        }
      }
    } else {
      // 前回状態が正常
      if (Objects.equals(status, CoreConstant.AliveMoniStatus.CONNECTION_ERROR)
          || Objects.equals(status, CoreConstant.AliveMoniStatus.DEVICE_ERROR)) {
        // 正常→通信異常
        if (lastMailStatus == null || Objects.equals(lastMailStatus, CoreConstant.AliveMoniSendMailStatus.NO_SEND)) {
          // ①INFO=0ならばINFO = 1 に更新してメール発報API呼び出し。初回（null)の場合も同様。
          MntDeviceEdgeState newEdgeState = edgeState;
          newEdgeState.setSendMailStatus(CoreConstant.AliveMoniSendMailStatus.SEND_FAIL_CONNECT);
          mntDeviceEdgeStateSv.updateSendMailStatus(newEdgeState);
          return true;
        } else if (Objects.equals(lastMailStatus, CoreConstant.AliveMoniSendMailStatus.SEND_FAIL_CONNECT)) {
          // ②INFO=1ならばそのままメール発報API呼び出し
          return true;
        } else {
          // ③INFO=2ならば復旧メールを送っていないことになるので、INFO=0に更新してメール発報APIを呼び出さない。
          MntDeviceEdgeState newEdgeState = edgeState;
          newEdgeState.setSendMailStatus(CoreConstant.AliveMoniSendMailStatus.NO_SEND);
          mntDeviceEdgeStateSv.updateSendMailStatus(newEdgeState);
          return false;
        }
      } else {
        // 正常→正常（通信中、正常終了）
        if (Objects.equals(lastMailStatus, CoreConstant.AliveMoniSendMailStatus.NO_SEND)) {
          // ①INFO=0ならばメール発報済みなのでメール発報APIを呼び出さない
          return false;
        } else if (lastMailStatus == null || Objects.equals(lastMailStatus, CoreConstant.AliveMoniSendMailStatus.SEND_FAIL_CONNECT)) {
          // ②INFO=1ならば異常メールを送っていないことになるので、INFO=0に戻してメール発報APIを呼び出さない。初回（null)の場合も同様。
          MntDeviceEdgeState newEdgeState = edgeState;
          newEdgeState.setSendMailStatus(CoreConstant.AliveMoniSendMailStatus.NO_SEND);
          mntDeviceEdgeStateSv.updateSendMailStatus(newEdgeState);
          return false;
        } else {
          // ③INFO=2ならばそのままメール発報API呼び出し
          return true;
        }
      }
    }
  }

  // #9243 2023.07.31 del 複数装置の 工程状態 と 通信不良有無 の更新を1つのSQL文で実施 TDC山崎 start
//  /**
//   * 装置状態管理更新処理
//   *
//   * @param facilityCd
//   * @param machineTypeCd
//   * @param machineSerial
//   * @param processState
//   * @param isPreventiveMainte
//   * @param regDate
//   * @param upDate
//   * @return
//   */
//  private boolean UpdateMntMachineState(String facilityCd, String machineTypeCd, String machineSerial,
//      String processState, Integer isPreventiveMainte) {
//
//    MntMachineState machineState = new MntMachineState();
//
//    machineState.setFacilityCd(facilityCd);
//    machineState.setMachineTypeCd(machineTypeCd);
//    machineState.setMachineSerial(machineSerial);
//    machineState.setProcessState(processState);
//    machineState.setIsPreventiveMainte(isPreventiveMainte);
//
//    EventLogMessage eventLogMessage = new EventLogMessage();
//    eventLogMessage.setLogMessage("死活監視API：Update情報　" + machineStateToString(machineState));
//    eventLogMessage.setMachineTypeCd(machineTypeCd);
//    eventLogMessage.setFacilityCd(facilityCd);
//    //FNSI-修正 ログ対応 xiebzh add start
//    eventLogMessage.setInvokeClass(this.getClass().getName());
//    //FNSI-修正 ログ対応 xiebzh add end
//    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
//
//    int ret = mntMachineStateSv.update(machineState);
//    if (-1 == ret) {
//      eventLogMessage.setLogMessage("死活監視API：装置状態管理情報の更新処理に失敗　施設コード[" + facilityCd + "]、型式コード["
//          + machineTypeCd + "]、製造番号[" + machineSerial + "]");
//      eventLogMessage.setMachineTypeCd(machineTypeCd);
//      eventLogMessage.setFacilityCd(facilityCd);
//      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
//      return false;
//    }
//
//    return true;
//  }
  // #9243 2023.07.31 del 複数装置の 工程状態 と 通信不良有無 の更新を1つのSQL文で実施 TDC山崎 end

  /**
   * 対象のデバイスエッジに紐づく装置の状態を更新する
   * @param facilityCd 施設コード
   * @param deviceEdgeNo デバイスエッジ番号
   * @param processState 工程
   * @param isPreventiveMainte 通信異常有無
   * @return
   */
  private boolean UpdateMntMachineStateEdge(String facilityCd, Integer deviceEdgeNo, String processState,
      Integer isPreventiveMainte) {

    MntMachineState machineState = new MntMachineState();

    machineState.setFacilityCd(facilityCd);
    machineState.setProcessState(processState);
    machineState.setIsPreventiveMainte(isPreventiveMainte);

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("死活監視API：Update情報　施設コード:[" + facilityCd + "] デバイスエッジ番号:[" + deviceEdgeNo + "]");
    eventLogMessage.setFacilityCd(facilityCd);
    eventLogMessage.setDeviceEdgeNo(String.valueOf(deviceEdgeNo));
    //FNSI-修正 ログ対応 xiebzh add start
    eventLogMessage.setInvokeClass(this.getClass().getName());
    //FNSI-修正 ログ対応 xiebzh add end
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);

    int ret = mntMachineStateSv.updateAllMachine(machineState, deviceEdgeNo);
    if (-1 == ret) {
      eventLogMessage.setLogMessage("死活監視API：装置状態管理情報の更新処理に失敗　施設コード[" + facilityCd + "]、デバイスエッジ番号["
          + deviceEdgeNo + "]");
      eventLogMessage.setFacilityCd(facilityCd);
      eventLogMessage.setDeviceEdgeNo(String.valueOf(deviceEdgeNo));
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
      return false;
    }

    return true;
  }

  /**
   * デバイスエッジ状態管理登録処理.
   *
   * @param facilityCd
   * @param deviceEdgeNo
   * @param aliveMoniStatus
   * @param versionInformation
   * @param lastMoniTime
   * @param regDate
   * @param upDate
   * @return
   */
  private boolean InsertMntDeviceEdgeState(String facilityCd, Integer deviceEdgeNo, String aliveMoniStatus,
      String versionInformation, Timestamp lastMoniTime, Timestamp regDate, Timestamp upDate) {

    MntDeviceEdgeState deviceEdgeState = new MntDeviceEdgeState();
    deviceEdgeState.setDeviceEdgeNo(deviceEdgeNo);
    deviceEdgeState.setFacilityCd(facilityCd);
    deviceEdgeState.setAliveMoniStatus(aliveMoniStatus);
    deviceEdgeState.setVersionInformation(versionInformation);
    deviceEdgeState.setLastMoniTime(lastMoniTime);
    deviceEdgeState.setRegDate(regDate);
    deviceEdgeState.setUpDate(upDate);

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("死活監視API：Insert情報　" + deviceEdgeStateParamToString(deviceEdgeState));
    eventLogMessage.setDeviceEdgeNo(String.valueOf(deviceEdgeNo));
    eventLogMessage.setFacilityCd(facilityCd);
    //FNSI-修正 ログ対応 xiebzh add start
    eventLogMessage.setInvokeClass(this.getClass().getName());
    //FNSI-修正 ログ対応 xiebzh add end
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);

    int ret = mntDeviceEdgeStateSv.insert(deviceEdgeState);
    if (-1 == ret) {
      eventLogMessage
          .setLogMessage("死活監視API：デバイスエッジ状態管理情報の登録処理に失敗　施設コード[" + facilityCd + "]、デバイスエッジ番号[" + deviceEdgeNo + "]");
      eventLogMessage.setDeviceEdgeNo(String.valueOf(deviceEdgeNo));
      eventLogMessage.setFacilityCd(facilityCd);
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
      return false;
    }

    return true;
  }

  /**
   * デバイスエッジ状態管理更新処理
   *
   * @param facilityCd
   * @param deviceEdgeNo
   * @param aliveMoniStatus
   * @param lastMoniTime
   * @return
   */
  private boolean UpdateMntDeviceEdgeState(String facilityCd, Integer deviceEdgeNo, String aliveMoniStatus,
      Timestamp lastMoniTime) {

    MntDeviceEdgeState deviceEdgeState = new MntDeviceEdgeState();
    deviceEdgeState.setDeviceEdgeNo(deviceEdgeNo);
    deviceEdgeState.setFacilityCd(facilityCd);
    deviceEdgeState.setAliveMoniStatus(aliveMoniStatus);
    deviceEdgeState.setLastMoniTime(lastMoniTime);

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("死活監視API：Update情報　" + deviceEdgeStateParamToString(deviceEdgeState));
    eventLogMessage.setDeviceEdgeNo(String.valueOf(deviceEdgeNo));
    eventLogMessage.setFacilityCd(facilityCd);
    //FNSI-修正 ログ対応 xiebzh add start
    eventLogMessage.setInvokeClass(this.getClass().getName());
    //FNSI-修正 ログ対応 xiebzh add end
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);

    // add FNSI-バグ #7480 通信サーバ 高 start
    List<MntDeviceEdgeState> targetEdgeState = SelectMntDeviceEdgeState(facilityCd, deviceEdgeNo);
    if (null != targetEdgeState && 0 != targetEdgeState.size()) {
      if(("F1".equals(targetEdgeState.get(0).getAliveMoniStatus()) || "F2".equals(targetEdgeState.get(0).getAliveMoniStatus()))
         && "01".equals(aliveMoniStatus)) {

        AliveMoniService.AliveMoniTarget targetData = new AliveMoniService.AliveMoniTarget();
        // 施設コード
        targetData.setFacilityCd(facilityCd);
        // デバイスエッジ番号
        targetData.setDeviceEdgeNo(deviceEdgeNo);
        // 死活監視要求
        AliveMoniService.PublishInfo publishInfo = this.aliveMoniSv.ProcessAliveMoni(targetData);
        if (false == publishInfo.Result) {
          eventLogMessage.setLogMessage("死活監視PROCESS API：要求失敗　対象施設コード[" + targetData.getFacilityCd() + "]、対象デバイスエッジ番号 [" + targetData.getDeviceEdgeNo() + "]");
          eventLogMessage.setDeviceEdgeNo(String.valueOf(targetData.getDeviceEdgeNo()));
          eventLogMessage.setFacilityCd(targetData.getFacilityCd());
          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
        }
      }
    }
    // add FNSI-バグ #7480 通信サーバ 高 end

    int ret = mntDeviceEdgeStateSv.update(deviceEdgeState);
    if (-1 == ret) {
      eventLogMessage
          .setLogMessage("死活監視API：デバイスエッジ状態管理情報の更新処理に失敗　施設コード[" + facilityCd + "]、デバイスエッジ番号[" + deviceEdgeNo + "]");
      eventLogMessage.setDeviceEdgeNo(String.valueOf(deviceEdgeNo));
      eventLogMessage.setFacilityCd(facilityCd);
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
      return false;
    }

    return true;
  }

  /**
   * 装置状態ログ用
   */
  private static String machineStateToString(MntMachineState machineState) {
    String msg = "";
    try {
      msg += "facility_cd:[" + machineState.getFacilityCd() + "]、";
      msg += "machine_type_cd:[" + machineState.getMachineTypeCd() + "]、";
      msg += "machine_serial:[" + machineState.getMachineSerial() + "]、";
      msg += "model:[" + machineState.getModel() + "]、";
      msg += "machineName:[" + machineState.getMachineName() + "]、";
      msg += "processState:[" + machineState.getProcessState() + "]、";
      msg += "mNoticeCnt:[" + machineState.getMNoticeCnt() + "]、";
      msg += "preventiveMainteCnt:[" + machineState.getPreventiveMainteCnt() + "]、";
      msg += "isPreventiveMainte:[" + machineState.getIsPreventiveMainte() + "]、";
      msg += "reg_date:[" + machineState.getRegDate() + "]、";
      msg += "up_date:[" + machineState.getUpDate() + "]";
    } catch (Exception e) {
    }

    return msg;
  }

  /**
   * ログ用 デバイスエッジ状態レコード情報
   * @param deviceEdgeState
   * @return
   */
  private static String deviceEdgeStateParamToString(MntDeviceEdgeState deviceEdgeState) {
    String msg = "";
    try {
      msg += "device_edge_no:[" + deviceEdgeState.getDeviceEdgeNo() + "]、";
      msg += "facility_cd:[" + deviceEdgeState.getFacilityCd() + "]、";
      msg += "alive_moni_status:[" + deviceEdgeState.getAliveMoniStatus() + "]、";
      msg += "version_information:[" + deviceEdgeState.getVersionInformation() + "]、";
      msg += "last_moni_time:[" + deviceEdgeState.getLastMoniTime() + "]、";
      msg += "reg_date:[" + deviceEdgeState.getRegDate() + "]、";
      msg += "up_date:[" + deviceEdgeState.getUpDate() + "]";
    } catch (Exception e) {
    }

    return msg;
  }
}
