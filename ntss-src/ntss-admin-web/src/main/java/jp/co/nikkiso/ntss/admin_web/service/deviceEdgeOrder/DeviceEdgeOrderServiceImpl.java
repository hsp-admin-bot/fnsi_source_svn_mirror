package jp.co.nikkiso.ntss.admin_web.service.deviceEdgeOrder;

import java.net.URISyntaxException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.Collections;
import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.statusList.dto.condInfo.CondInfo;
import jp.co.nikkiso.ntss.admin_web.service.statusList.dto.condInfo.CondInfoItem;
import jp.co.nikkiso.ntss.admin_web.service.statusList.dto.condInfo.CondInfoService;
import jp.co.nikkiso.ntss.admin_web.web.rest.util.WebApiCallCommonUtil;
import jp.co.nikkiso.ntss.api.service.PatMainAcceptanceStatusInfo.PatMainAcceptanceStatusInfoService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.ComsvOrdMainDao;
import jp.co.nikkiso.ntss.core.dao.MntMachineStateDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.entity.MntMachineState;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.custom.ComsvOrdMain;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainOrdNoAndRstStartDate;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.utils.TriggerUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.WebSocketTopic;
import jp.co.nikkiso.ntss.admin_web.request.deviceEdgeOrder.DeviceEdgeOrderRequest;
import jp.co.nikkiso.ntss.admin_web.response.deviceEdgeOrder.DeviceEdgeOrderResponse;
import jp.co.nikkiso.ntss.admin_web.service.webSocketNotify.PayloadBuilder;
import jp.co.nikkiso.ntss.admin_web.service.webSocketNotify.WebSocketNotifyService;
import jp.co.nikkiso.ntss.admin_web.service.webSocketNotify.WebSocketNotifyService.SendTarget;
import jp.co.nikkiso.ntss.core.dao.MstDeviceEdgeDao;
import jp.co.nikkiso.ntss.core.dao.MstMachineDao;
import jp.co.nikkiso.ntss.core.entity.MstDeviceEdge;
import jp.co.nikkiso.ntss.core.entity.MstMachine;
import org.springframework.transaction.annotation.Transactional;

@Service
public class DeviceEdgeOrderServiceImpl implements DeviceEdgeOrderService {

  @Autowired
  private MstMachineDao mstMachineDao;

  @Autowired
  private MstDeviceEdgeDao mstDeviceEdgeDao;

  @Autowired
  WebSocketNotifyService sendWsMsg;

  //add ？？？？患者発生時の次患者情報送信#1437 --趙-- start
  @Autowired
  MntMachineStateDao mntMachineStateDao;

  @Autowired
  ComsvOrdMainDao comsvOrdMainDao;
  //add ？？？？患者発生時の次患者情報送信#1437 --趙-- end

  // add FNSI-redime5618 fang start
  @Autowired
  OrdMainDao ordMainDao;

  @Autowired
  WebApiCallCommonUtil webApiCallCommonUtil;
  // add FNSI-redime5618 fang end

  @Autowired
  private TriggerUtil triggerUtil;

  // #10518 2024.04.23 add ログ強化 TDC米沢 start
  /**
   * ロギングのServiceインタフェース.
   */
  @Autowired
  private LogService logService;
  // #10518 2024.04.23 add ログ強化 TDC米沢 end

  // #10889 2024.09.05 add 治療終了処理を修正 TDC片口 start
  @Autowired
  private PatMainAcceptanceStatusInfoService patMainAcceptanceStatusInfoService;

  @Autowired
  private CondInfoService condInfoService;

  // #10889 2024.09.05 add 治療終了処理を修正 TDC片口 end

  /**
   * {@inheritDoc}
   */
  @Override
  public DeviceEdgeOrderRequest findMissingData(DeviceEdgeOrderRequest request) {
    if (request.getMachineNo() == null) {
      // 装置番号の取得
      List<MstMachine> machines = null;
      if (request.getOrdNo() != null) {
        // オーダー番号が指定されていればmst_machineを取得して施設コードを取得
        machines = mstMachineDao.selectByOrdNoRst(request.getOrdNo());
        if (machines.size() == 0) {
          machines = mstMachineDao.selectByOrdNoAndRstBedCd(request.getOrdNo());
        }
      }
      if (machines.size() > 0) {
        MstMachine machine = machines.get(0);
        request.setMachineNo(machine.getMachineNo());
        if (request.getFacilityCd() == null || Objects.equals(request.getFacilityCd(), "")) {
          request.setFacilityCd(machine.getFacilityCd());
        }
        if (request.getDeviceEdgeNo() == null) {
          request.setDeviceEdgeNo(machine.getDeviceEdgeNo());
        }
      }
    }
    if (request.getFacilityCd() == null || Objects.equals(request.getFacilityCd(), "")
      || request.getDeviceEdgeNo() == null) {
      // 施設コードの取得
      List<MstMachine> machines = null;
      MstMachine machine = null;
      if (request.getMachineNo() != null) {
        // 装置番号が指定されていればmst_machineから施設コードを取得
        machine = mstMachineDao.selectByMachineNo(request.getMachineNo());
      } else if (request.getOrdNo() != null) {
        // オーダー番号が指定されていればmst_machineを取得して施設コードを取得
        machines = mstMachineDao.selectByOrdNoRst(request.getOrdNo());
        if (machines.size() == 0) {
          machines = mstMachineDao.selectByOrdNoAndRstBedCd(request.getOrdNo());
        }
        if (machines.size() > 0) {
          machine = machines.get(0);
        }
      }
      if (machine != null) {
        if (request.getFacilityCd() == null || Objects.equals(request.getFacilityCd(), "")) {
          request.setFacilityCd(machine.getFacilityCd());
        }
        if (request.getDeviceEdgeNo() == null) {
          request.setDeviceEdgeNo(machine.getDeviceEdgeNo());
        }
      }
    }
    return request;
  }

  /**
   * {@inheritDoc}
   */
  public List<MstDeviceEdge> findMstDeviceEdgeNo(String facilityCd) {
    List<MstDeviceEdge> deList = mstDeviceEdgeDao.selectByFacilityCd(facilityCd);
    List<MstDeviceEdge> ret = deList.stream().filter(de -> Objects.isNull(de.getDeleteDate())).collect(Collectors.toList());

    return ret;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public DeviceEdgeOrderResponse sendMessageToComServer(String facilityCd, Integer deviceEdgeNo, String topicKey,
                                                        String payload) {

    String topic = PayloadBuilder.BuildTopic(topicKey, facilityCd, deviceEdgeNo);
    return sendMessage(facilityCd, deviceEdgeNo, topic, payload);
  }

  public DeviceEdgeOrderResponse sendMessageToComServer(String facilityCd, Integer deviceEdgeNo, String topicKey) {
    return sendMessageToComServer(facilityCd, deviceEdgeNo, topicKey, "");
  }

  private DeviceEdgeOrderResponse sendMessage(String facilityCd, Integer deviceEdgeNo, String topic, String payload) {
    DeviceEdgeOrderResponse res = new DeviceEdgeOrderResponse();
    // EdgeあてにWebsocket通知
    if (sendWsMsg.sendMsg(SendTarget.main, facilityCd, deviceEdgeNo, topic, payload)) {
      res.isSuccess = true;
    } else {
      res.isSuccess = false;
      res.errorMessage = "通信サーバーへの通知失敗";
    }
    return res;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public DeviceEdgeOrderResponse orderReadOption(String facilityCd, Integer deviceEdgeNo, Long machineNo) {
    String machineInfo = machineNo.toString();

    return sendMessageToComServer(facilityCd, deviceEdgeNo, WebSocketTopic.ComSv.READ_OPTION, machineInfo);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public DeviceEdgeOrderResponse orderReadSettingValue(String facilityCd, Integer deviceEdgeNo, Long machineNo,
                                                       Long ordNo) {
    String machineInfo = PayloadBuilder.BuildMachineAndOrdNoPayload(machineNo, ordNo);

    return sendMessageToComServer(facilityCd, deviceEdgeNo, WebSocketTopic.ComSv.READ_SETTING_VALUE, machineInfo);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public DeviceEdgeOrderResponse orderSendNextPat(String facilityCd, Integer deviceEdgeNo, Long machineNo, Long ordNo) {
    String machineInfo = PayloadBuilder.BuildMachineAndOrdNoPayload(machineNo, ordNo);

    return sendMessageToComServer(facilityCd, deviceEdgeNo, WebSocketTopic.ComSv.SEND_NEXT_PAT, machineInfo);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public DeviceEdgeOrderResponse orderReloadComsvSetting(String facilityCd, Integer deviceEdgeNo) {
    return sendMessageToComServer(facilityCd, deviceEdgeNo, WebSocketTopic.ComSv.RELOAD_COMSV_SETTING);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public DeviceEdgeOrderResponse orderReloadTreatMaster(String facilityCd, Integer deviceEdgeNo) {
    return sendMessageToComServer(facilityCd, deviceEdgeNo, WebSocketTopic.ComSv.RELOAD_TREAT_MASTER);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public DeviceEdgeOrderResponse orderReloadStaffMaster(String facilityCd, Integer deviceEdgeNo) {
    return sendMessageToComServer(facilityCd, deviceEdgeNo, WebSocketTopic.ComSv.RELOAD_STAFF_MASTER);
  }

  //mod ？？？？患者発生時の次患者情報送信#1437 --趙-- start

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  public DeviceEdgeOrderResponse orderSetUnknownPat(String facilityCd, Integer deviceEdgeNo, Long machineNo,
                                                    Long ordNo) {
    //String machineInfo = PayloadBuilder.BuildMachineAndOrdNoPayload(machineNo, ordNo);

    //return sendMessageToComServer(facilityCd, deviceEdgeNo, WebSocketTopic.ComSv.SET_UNKNOWN_PAT, machineInfo);
    /*
     MNT_MACHINE_STATEのord_noで当患者のrst_dialysis_stateをチェック
		「3」以外の場合：
		  MNT_MACHINE_STATEのnext_ord_noで次患者のrst_dialysis_stateをチェック：
       ・「0」である場合、デバイスエッジ側に「COMSV/8」にて「装置番号」と「オーダ番号」をDEへ通知する。
       ・「0」以外である場合、デバイスエッジ側に通知しない。
		「3」の場合：
		  ・デバイスエッジ側に「COMSV/8」にて「装置番号」と「オーダ番号」をDEへ通知する。
		*/
    DeviceEdgeOrderResponse res = new DeviceEdgeOrderResponse();
    try {
      String machineInfo = PayloadBuilder.BuildMachineAndOrdNoPayload(machineNo, ordNo);
      // オーダ番号を取得
      ComsvOrdMain ordMain = comsvOrdMainDao.selectByNo(ordNo);
      List<MntMachineState> list = null;
      MntMachineState mms = null;
      list = mntMachineStateDao.selectByOrdNo(facilityCd, ordNo);
      mms = list.get(0);
      if (mms != null) {
        ordMain.setStartDate(mms.getStartDate());
        comsvOrdMainDao.updateStartDate(ordMain);
        String state = ordMain.getRstDialysisState();
        if (state.equals(AdminWebConstant.OrdMainConst.DialysisState.DIALYSIS) == true) {
          res = sendMessageToComServer(facilityCd, deviceEdgeNo, WebSocketTopic.ComSv.SET_UNKNOWN_PAT, machineInfo);
        } else {
          Long nextordno = mms.getNextOrdNo();
          if (nextordno != null) {
            ordMain = comsvOrdMainDao.selectByNo(nextordno);
            state = ordMain.getRstDialysisState();
            if (state.equals(AdminWebConstant.OrdMainConst.DialysisState.BEFORE_SEND) == true) {
              res = sendMessageToComServer(facilityCd, deviceEdgeNo, WebSocketTopic.ComSv.SET_UNKNOWN_PAT, machineInfo);
            } else {
              res.isSuccess = true;
            }
          } else {
            res.isSuccess = false;
            res.errorMessage = "When send msg comsv/8, nextOrdNo is null.";
          }
        }
      } else {
        res.isSuccess = false;
        res.errorMessage = "When send msg comsv/8, mntMachineState is null.";
      }
    } catch (Exception e) {
      res.isSuccess = false;
      res.errorMessage = e.getMessage();
    }
    return res;
  }
  //mod ？？？？患者発生時の次患者情報送信#1437 --趙-- end

  /**
   * {@inheritDoc}
   */
  @Override
  public DeviceEdgeOrderResponse orderCancelCondition(String facilityCd, Integer deviceEdgeNo, Long machineNo) {
    String machineInfo = machineNo.toString();

    return sendMessageToComServer(facilityCd, deviceEdgeNo, WebSocketTopic.ComSv.CANCEL_CONDITION, machineInfo);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public DeviceEdgeOrderResponse orderChangeIndMedi(String facilityCd, Integer deviceEdgeNo, Long machineNo,
                                                    Long ordNo) {
    String machineInfo = PayloadBuilder.BuildMachineAndOrdNoPayload(machineNo, ordNo);

    return sendMessageToComServer(facilityCd, deviceEdgeNo, WebSocketTopic.ComSv.CHANGE_IND_MEDI, machineInfo);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public DeviceEdgeOrderResponse orderChangeTreatTime(String facilityCd, Integer deviceEdgeNo, Long machineNo,
                                                      Long ordNo) {
    // #10518 2024.04.22 mod 現患者で対象の治療状態が1～3、オフラインまたは強制オフラインを含む装置の場合に「オフライン運転タイマー更新」通知を行う判定処理を変更 TDC米沢 start
    // String machineInfo = PayloadBuilder.BuildMachineAndOrdNoPayload(machineNo, ordNo);
    // return sendMessageToComServer(facilityCd, deviceEdgeNo, WebSocketTopic.ComSv.SEND_TREAT_TIME, machineInfo);

    DeviceEdgeOrderResponse ret = new DeviceEdgeOrderResponse();
    ret.isSuccess = true;

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();

    try {

      // 現患者判定
      List<MntMachineState> list = mntMachineStateDao.selectByOrdNo(facilityCd, ordNo);

      // 件数判定
      if(list.isEmpty()) {
        // 通知なし
        eventLogMessage.setLogMessage("オフライン運転タイマー更新通知未実施[現患者以外] ordNo:"+ ordNo);
        logService.log(LogLevel.INFO, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, LoggingConstant.SERVICE_NAME.FNSI, "");
      } else {
        // 該当する装置全て
        for(MntMachineState item: list) {

          // 指定された治療記録番号の治療状態を取得する
          OrdMain ord = ordMainDao.selectRstDialysisState(item.getOrdNo());

          // 治療状態判定
          String state = ord.getRstDialysisState();
          if(state.equals(AdminWebConstant.OrdMainConst.DialysisState.AFTER_SEND)
            || state.equals(AdminWebConstant.OrdMainConst.DialysisState.CHECKED_SEND)
            || state.equals(AdminWebConstant.OrdMainConst.DialysisState.DIALYSIS)) {
            // 治療状態：治療中(1：条件送信済み～3：治療中)

            // オフライン装置、または強制オフライン判定
            if(item.getIsOffline().equals(AdminWebConstant.FlagType.FLAG_ON) || ordMainDao.checkSpecialPurification(item.getOrdNo())) {
              // オフライン装置、または強制オフライン(特殊浄化治療)

              // 通知あり
              eventLogMessage.setLogMessage("オフライン運転タイマー更新通知実施 ordNo:"+ ordNo + " => " + WebSocketTopic.ComSv.SEND_TREAT_TIME);
              logService.log(LogLevel.INFO, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, LoggingConstant.SERVICE_NAME.FNSI, "");

              // 装置番号取得
              MstMachine machine = mstMachineDao.selectByCd(item.getMachineTypeCd(), item.getMachineSerial(), item.getFacilityCd());
              if (machine != null) {
                String machineInfo = PayloadBuilder.BuildMachineAndOrdNoPayload(machine.getMachineNo(), ordNo);
                DeviceEdgeOrderResponse res =  sendMessageToComServer(facilityCd, machine.getDeviceEdgeNo(), WebSocketTopic.ComSv.SEND_TREAT_TIME, machineInfo);
                if (!res.isSuccess) {
                  ret = res;
                }
              }
            } else {
              // 通知なし
              eventLogMessage.setLogMessage("オフライン運転タイマー更新通知未実施[オフライン装置、強制オフライン以外] ordNo:"+ ordNo);
              logService.log(LogLevel.INFO, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, LoggingConstant.SERVICE_NAME.FNSI, "");
            }
          } else {
            // 通知なし
            eventLogMessage.setLogMessage("オフライン運転タイマー更新通知未実施[治療中以外] ordNo:"+ ordNo);
            logService.log(LogLevel.INFO, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, LoggingConstant.SERVICE_NAME.FNSI, "");
          }
        }
      }
    } catch (Exception e) {
      ret.isSuccess = false;
      ret.errorMessage = e.getMessage();
    }
    return ret;
    // #10518 2024.04.22 mod 現患者で対象の治療状態が1～3、オフラインまたは強制オフラインを含む装置の場合に「オフライン運転タイマー更新」通知を行う判定処理を変更 TDC米沢 end
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public DeviceEdgeOrderResponse orderAfterWeight(String facilityCd, Integer deviceEdgeNo, Long machineNo) {
    String machineInfo = machineNo.toString();

    return sendMessageToComServer(facilityCd, deviceEdgeNo, WebSocketTopic.ComSv.AFTER_WEIGHT, machineInfo);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public DeviceEdgeOrderResponse orderCheckStatus(String facilityCd, Integer deviceEdgeNo, Long machineNo) {
    String machineInfo = machineNo.toString();

    return sendMessageToComServer(facilityCd, deviceEdgeNo, WebSocketTopic.ComSv.CHECK_STATUS, machineInfo);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public DeviceEdgeOrderResponse orderReloadChecklistMaster(String facilityCd, Integer deviceEdgeNo) {
    return sendMessageToComServer(facilityCd, deviceEdgeNo, WebSocketTopic.ComSv.RELOAD_CHECKLIST_MASTER);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public DeviceEdgeOrderResponse orderCacheClear(String facilityCd, Integer deviceEdgeNo, Long machineNo) {
    String machineInfo = machineNo.toString();

    return sendMessageToComServer(facilityCd, deviceEdgeNo, WebSocketTopic.ComSv.CHACE_CLEAR, machineInfo);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public DeviceEdgeOrderResponse orderReloadExamMaster(String facilityCd, Integer deviceEdgeNo) {
    return sendMessageToComServer(facilityCd, deviceEdgeNo, WebSocketTopic.ComSv.RELOAD_EXAM_MASTER);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public DeviceEdgeOrderResponse orderStartTreatOffline(String facilityCd, Integer deviceEdgeNo, Long machineNo) {
    String machineInfo = machineNo.toString();

    return sendMessageToComServer(facilityCd, deviceEdgeNo, WebSocketTopic.ComSv.START_TREAT_OFFLINE, machineInfo);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  // #11192 2025.03.26 mod 治療終了指示にオーダー番号を含める TDC片口 start
//  public DeviceEdgeOrderResponse orderEndTreatOffline(String facilityCd, Integer deviceEdgeNo, Long machineNo) {
//    String machineInfo = machineNo.toString();
//
//    return sendMessageToComServer(facilityCd, deviceEdgeNo, WebSocketTopic.ComSv.END_TREAT_OFFLINE, machineInfo);
//  }
  public DeviceEdgeOrderResponse orderEndTreatOffline(String facilityCd, Integer deviceEdgeNo, Long machineNo, Long ordNo) {
    String machineInfo = PayloadBuilder.BuildMachineAndOrdNoPayload(machineNo, ordNo);

    return sendMessageToComServer(facilityCd, deviceEdgeNo, WebSocketTopic.ComSv.END_TREAT_OFFLINE, machineInfo);
  }
  // #11192 2025.03.26 mod 治療終了指示にオーダー番号を含める TDC片口 end

  // add 通信サーバー通信追加 房 start
  /**
   * {@inheritDoc}
   */
  @Override
  // #10518 2024.04.19 mod 実績確定時に現患者で装置表示レポート対象であった実績の場合のみ「実績版確定時装置レポート画像更新」通知を行う判定処理を変更 TDC米沢 start
  //public DeviceEdgeOrderResponse orderReportUpdate(Long ordNo, String facilityCd, Integer deviceEdgeNo, Long machineNo) {
  // String machineInfo = PayloadBuilder.BuildMachineAndOrdNoPayload(machineNo, ordNo);
  //
  // return sendMessageToComServer(facilityCd, deviceEdgeNo, WebSocketTopic.ComSv.SEND_REPORT_WHEN_CONFIRM, machineInfo);
  //}
  public DeviceEdgeOrderResponse orderReportUpdate(Long patId, Long ordNo, String facilityCd) {
    DeviceEdgeOrderResponse ret = new DeviceEdgeOrderResponse();
    ret.isSuccess = true;

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();

    try {

      // 指定された患者Idが現患者となっている装置ステータスが99以外の装置ステータス一覧を取得する
      List<MntMachineState> list = mntMachineStateDao.selectByPatId(patId);

      // 件数判定
      if(list.isEmpty()) {
        // 通知なし
        eventLogMessage.setLogMessage("実績版確定時装置レポート画像更新通知未実施[現患者以外] patId:"+ patId);
        logService.log(LogLevel.INFO, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, LoggingConstant.SERVICE_NAME.FNSI, "");
      } else {
        // 該当する装置全て
        for (MntMachineState item : list) {
          // 装置で表示されるレポートのOrdNoを取得して指定されたOrdNoが含まれているかどうか
          boolean resultFlag = false;

          // 直近3回分
          for (OrdMainOrdNoAndRstStartDate element : comsvOrdMainDao.selectByOrdNoToPastOrdNo(item.getOrdNo(), 0, 3L)) {
            if (Objects.equals(element.getOrdNo(), ordNo)) {
              resultFlag = true;
              break;
            }
          }

          if (!resultFlag) {
            // 同一曜日3回分
            for (OrdMainOrdNoAndRstStartDate element : comsvOrdMainDao.selectByOrdNoToPastOrdNo(item.getOrdNo(), 1, 3L)) {
              if (Objects.equals(element.getOrdNo(), ordNo)) {
                resultFlag = true;
                break;
              }
            }
          }

          // 含まれている場合は通知
          if (resultFlag) {
            // 施設コードチェック
            if (item.getFacilityCd().equals(facilityCd)) {

              // 通知あり
              eventLogMessage.setLogMessage("実績版確定時装置レポート画像更新通知実施 ordNo:" + ordNo + " => " + WebSocketTopic.ComSv.SEND_REPORT_WHEN_CONFIRM);
              logService.log(LogLevel.INFO, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, LoggingConstant.SERVICE_NAME.FNSI, "");

              // 装置番号取得
              MstMachine machine = mstMachineDao.selectByCd(item.getMachineTypeCd(), item.getMachineSerial(), item.getFacilityCd());
              if (machine != null) {
                String machineInfo = PayloadBuilder.BuildMachineAndOrdNoPayload(machine.getMachineNo(), ordNo);
                DeviceEdgeOrderResponse res = sendMessageToComServer(facilityCd, machine.getDeviceEdgeNo(), WebSocketTopic.ComSv.SEND_REPORT_WHEN_CONFIRM, machineInfo);
                if (!res.isSuccess) {
                  ret = res;
                }
              }
            }
          } else {
            // 通知なし
            eventLogMessage.setLogMessage("実績版確定時装置レポート画像更新通知未実施[直近以外] ordNo:" + ordNo);
            logService.log(LogLevel.INFO, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, LoggingConstant.SERVICE_NAME.FNSI, "");
          }
        }
      }
    } catch (Exception e) {
      ret.isSuccess = false;
      ret.errorMessage = e.getMessage();
    }
    return ret;
    // #10518 2024.04.19 mod 実績確定時に現患者で装置表示レポート対象であった実績の場合のみ「実績版確定時装置レポート画像更新」通知を行う判定処理を変更 TDC米沢 end
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public DeviceEdgeOrderResponse orderEndDateUpdate(String facilityCd, Integer deviceEdgeNo, Long machineNo) {
    String machineInfo = machineNo.toString();
    return sendMessageToComServer(facilityCd, deviceEdgeNo, WebSocketTopic.ComSv.SEND_END_DATE_UPDATE_CONFIRM, machineInfo);
  }
  // #10518 2024.04.19 add 対象患者が現患者のベッドに対して「実績確定・削除時装置レポート画像更新」通知を行うメソッドを追加 TDC米沢 start
  /**
   * {@inheritDoc}
   */
  @Override
  public DeviceEdgeOrderResponse orderAllReportUpdateByPatId(String facilityCd, Long patId) {
    DeviceEdgeOrderResponse ret = new DeviceEdgeOrderResponse();
    ret.isSuccess = true;

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();

    try {
      // 指定された患者Idが現患者となっている装置ステータスが99以外の装置ステータス一覧を取得する
      List<MntMachineState> list = mntMachineStateDao.selectByPatId(patId);

      // 件数判定
      if(list.isEmpty()) {
        // 通知なし
        eventLogMessage.setLogMessage("実績確定・削除時装置レポート画像更新通知未実施[現患者以外] patId:"+ patId);
        logService.log(LogLevel.INFO, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, LoggingConstant.SERVICE_NAME.FNSI, "");
      } else {
        // 該当する装置全てに通知
        for (MntMachineState item : list) {
          // 施設コードチェック
          if (item.getFacilityCd().equals(facilityCd)) {

            // 通知あり
            eventLogMessage.setLogMessage("実績確定・削除時装置レポート画像更新通知実施 patId:" + patId + " => " + WebSocketTopic.ComSv.SEND_END_DATE_UPDATE_CONFIRM);
            logService.log(LogLevel.INFO, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, LoggingConstant.SERVICE_NAME.FNSI, "");

            // 装置番号取得
            MstMachine machine = mstMachineDao.selectByCd(item.getMachineTypeCd(), item.getMachineSerial(), item.getFacilityCd());
            if (machine != null) {
              DeviceEdgeOrderResponse res = this.orderEndDateUpdate(facilityCd, machine.getDeviceEdgeNo(), machine.getMachineNo());
              if (!res.isSuccess) {
                ret = res;
              }
            }
          }
        }
      }
    } catch (Exception e) {
      ret.isSuccess = false;
      ret.errorMessage = e.getMessage();
    }
    return ret;
  }
  // #10518 2024.04.19 add 対象患者が現患者のベッドに対して「実績確定・削除時装置レポート画像更新」通知を行うメソッドを追加 TDC米沢 end

  // #10889 2024.09.05 del 治療終了処理を修正 TDC片口 start
//  // add 通信サーバー通信追加 房 end
//  // add FNSI-redime5618 fang start
//  @Override
//  public boolean updateOrdmainAndNextPat(Long ordNo) throws URISyntaxException {
//
//    OrdMain ordMain = ordMainDao.selectByOrdNo(ordNo);
//
//    List<MstMachine> mstMachines = mstMachineDao.selectByBedCd(ordMain.getFacilityCd(), Long.valueOf(ordMain.getRstBedCd()));
//    //add #9872  by zhangruixue 2024-2-5 --start
//    //com_type 0：通信なし(オフライン運用)、1：新通信、2：NX通信、3：医器工V4
//    Integer comType = null;
//    //add #9872  by zhangruixue 2024-2-5 --end
//
//    if (mstMachines != null && mstMachines.size() > 0) {
//      MntMachineState mntMachineState = mntMachineStateDao.selectByKey(ordMain.getFacilityCd(),
//        mstMachines.get(0).getMachineTypeCd(), mstMachines.get(0).getMachineSerial());
//      mntMachineState.setEndDate(new Timestamp(System.currentTimeMillis()));
//      mntMachineStateDao.updateDialEnd(mntMachineState);
//      //add #9872  by zhangruixue 2024-2-5 --start
//      comType = mstMachines.get(0).getComType();
//      //add #9872  by zhangruixue 2024-2-5 --end
//    }
//
//    if (ordMain != null) {
//
//      List<MntMachineState> mntMachineStates = mntMachineStateDao.selectByOrdNo(ordMain.getFacilityCd(), ordNo);
//
//      boolean flag = false;
//
//      if (mntMachineStates != null && mntMachineStates.size() > 0) {
//        MntMachineState tempMntMachineState = mntMachineStates.get(0);
//        tempMntMachineState.setMachineStatus(0);
//        mntMachineStateDao.updateMachineState(tempMntMachineState);
//        //mod #9872  by zhangruixue 2024-2-5 --start
//        if (mntMachineStates.get(0).getProcessState() != null && mntMachineStates.get(0).getProcessState().equals("99") && comType != 0) {
////          if (mntMachineStates.get(0).getProcessState() != null && mntMachineStates.get(0).getProcessState().equals("99")) {
//          //mod #9872  by zhangruixue 2024-2-5 --start
//          flag = true;
//        }
//      }
//
//      if (flag && ordMain.getRstDialysisState() != null && "3".equals(ordMain.getRstDialysisState())) {
//        ordMain.setRstDialysisState("4");
//        ordMain.setRstEndDate(new Timestamp(System.currentTimeMillis()));
//        OrdMain oldOrdMain = ordMainDao.selectByOrdNo(ordMain.getOrdNo());
//        ordMainDao.update(ordMain);
//        OrdMain newOrdMain = ordMainDao.selectByOrdNo(ordMain.getOrdNo());
//        triggerUtil.updateTriggerOrdMain(Collections.singletonList(oldOrdMain),
//          Collections.singletonList(newOrdMain));
//        LocalDateTime update = LocalDateTime.now();
//        //upd FNSI-redime5618 ljx start
//        //？？？？患者の場合、Long.valueOfのNullPointerExceptionを抑止するために転換処理。
//        Integer indBedCd = 0;
//        if(ordMain.getIndBedCd() != null){
//          indBedCd = ordMain.getIndBedCd();
//        }
//        webApiCallCommonUtil.SetNextPatInfo(Long.valueOf(indBedCd), false, update);
//        //webApiCallCommonUtil.SetNextPatInfo(Long.valueOf(ordMain.getIndBedCd()), false, update);
//        //upd FNSI-redime5618 ljx end
//        return true;
//      }
//    }
//
//    return false;
//  }
//  // add FNSI-redime5618 fang end
  // #10889 2024.09.05 del 治療終了処理を修正 TDC片口 end

  // #10889 2024.09.05 add 治療終了処理を修正 TDC片口 start
  /** {@inheritDoc} */
  @Override
  public EndTreatResponse endTreat(String facilityCd, Long ordNo) {
    OrdMain ordMain = ordMainDao.selectByOrdNo(ordNo);
    List<MntMachineState> machineStates = mntMachineStateDao.selectByOrdNo(facilityCd, ordNo);

    if (machineStates.isEmpty()) {
      // 現患者ではない場合； ord_main を治療終了状態に更新する。次患者更新は不要
      boolean isUpdatedOrdMain = this.updateOrdMainEndTreat(ordMain);
      if (!isUpdatedOrdMain) {
        // 既に治療終了状態に更新されていた
        return EndTreatResponse.ALREADY;
      }
      return EndTreatResponse.SUCCESS;
    }

    // 現患者の場合は通信異常かどうかをチェック
    if (!machineStates.get(0).getProcessState().equals("99")) {
      // 通信正常の場合：DEに通知を送ってそっちに処理を任せる
      return EndTreatResponse.MUST_NOTIFY;
    }

    // 現患者で通信異常：サーバーサイドでデータ更新
    MntMachineState tempMntMachineState = machineStates.get(0);
    tempMntMachineState.setMachineStatus(0);
    // #10889 2024.09.05 mod 治療終了処理を修正 TDC片口 start
//    mntMachineStateDao.updateMachineState(tempMntMachineState);
    tempMntMachineState.setEndDate(new Timestamp(System.currentTimeMillis()));
    tempMntMachineState.setUpDate(new Timestamp(System.currentTimeMillis()));
    mntMachineStateDao.updateDialEnd(tempMntMachineState);
    // #10889 2024.09.05 mod 治療終了処理を修正 TDC片口 end
    boolean isUpdatedOrdMain = this.updateOrdMainEndTreat(ordMain);
    if (!isUpdatedOrdMain) {
      return EndTreatResponse.ALREADY;
    }

    // 次患者更新
    LocalDateTime update = LocalDateTime.now();
    int indBedCd;
    if (ordMain.getIndBedCd() != null) {
      indBedCd = ordMain.getIndBedCd();
    } else {
      indBedCd = 0;
    }
    try {
      webApiCallCommonUtil.SetNextPatInfo((long) indBedCd, false, update);
    } catch (URISyntaxException ex) {
      return EndTreatResponse.FAILED;
    }
    return EndTreatResponse.SUCCESS;
  }


  /**
   * ordMainの内容を治療終了にする処理
   * @param ordMain ord_mainレコード
   * @return true:更新 false:更新対象無し
   */
  private boolean updateOrdMainEndTreat(OrdMain ordMain) {

    if (ordMain != null && ordMain.getRstDialysisState() != null && "3".equals(ordMain.getRstDialysisState())) {
      ordMain.setRstDialysisState("4");
      ordMain.setRstEndDate(new Timestamp(System.currentTimeMillis()));
      OrdMain oldOrdMain = ordMainDao.selectByOrdNo(ordMain.getOrdNo());
      ordMainDao.update(ordMain);
      OrdMain newOrdMain = ordMainDao.selectByOrdNo(ordMain.getOrdNo());
      triggerUtil.updateTriggerOrdMain(Collections.singletonList(oldOrdMain),
        Collections.singletonList(newOrdMain));

      // 患者の治療進捗を更新
      if (ordMain.getPatId() != null) {
        // 治療時間
        String treatmentTime = null;
        String condInfoText = ordMain.getRstCondInfo();
        if (null != condInfoText) {
          CondInfo condInfo = condInfoService.createCondInfo(condInfoText);
          CondInfoItem condItem = condInfo.getTreatTime();
          treatmentTime = condItem.getValue();
        }
        // 割り当て対象の患者基本情報(pat_main)更新
        patMainAcceptanceStatusInfoService.update(ordMain.getPatId(), ordMain.getOrdNo(), ordMain.getRstDialysisState(), ordMain.getRstStartDate(), treatmentTime);
      }
      return true;
    }
    return false;
  }

  // #10889 2024.09.05 add 治療終了処理を修正 TDC片口 end

  //FNSI-修正 #5525 横展開対応、xugj add
  /**
   * {@inheritDoc}
   */
  @Override
  public boolean getIsNextPatInfo(Long ordNo) {

    OrdMain ordMain = ordMainDao.selectByOrdNo(ordNo);

    List<MstMachine> mstMachines = mstMachineDao.selectByBedCd(ordMain.getFacilityCd(), Long.valueOf(ordMain.getRstBedCd()));

    if (mstMachines != null && mstMachines.size() > 0) {
      MntMachineState mntMachineState = mntMachineStateDao.selectByKey(ordMain.getFacilityCd(),
        mstMachines.get(0).getMachineTypeCd(), mstMachines.get(0).getMachineSerial());
      if(ordMain.getPatId().equals(mntMachineState.getNextPatid())) {
        return true;
      }
    }

    return false;
  }

  //add FNSI-redmine6535 fang start
  @Override
  public DeviceEdgeOrderResponse orderSetUnknownPat(String facilityCd, Integer deviceEdgeNo, Long machineNo,
                                                    Long ordNo, Timestamp rstStartDate) {
    DeviceEdgeOrderResponse res = new DeviceEdgeOrderResponse();
    try {
      String machineInfo = PayloadBuilder.BuildMachineAndOrdNoPayload(machineNo, ordNo);
      // オーダ番号を取得
      ComsvOrdMain ordMain = comsvOrdMainDao.selectByNo(ordNo);
      List<MntMachineState> list = null;
      MntMachineState mms = null;
      list = mntMachineStateDao.selectByOrdNo(facilityCd,ordNo);
      mms = list.get(0);
      if(mms != null) {
        ordMain.setStartDate(rstStartDate);
        ordMain.setEndDate(null);
        comsvOrdMainDao.updateStartDate(ordMain);
        String state = ordMain.getRstDialysisState();
        if (state.equals(AdminWebConstant.OrdMainConst.DialysisState.DIALYSIS) == true) {
          res = sendMessageToComServer(facilityCd, deviceEdgeNo, WebSocketTopic.ComSv.SET_UNKNOWN_PAT, machineInfo);
        } else {
          Long nextordno = mms.getNextOrdNo();
          if (nextordno != null) {
            ordMain = comsvOrdMainDao.selectByNo(nextordno);
            state = ordMain.getRstDialysisState();
            if (state.equals(AdminWebConstant.OrdMainConst.DialysisState.BEFORE_SEND) == true) {
              res = sendMessageToComServer(facilityCd, deviceEdgeNo, WebSocketTopic.ComSv.SET_UNKNOWN_PAT, machineInfo);
            }else{
              res.isSuccess = true;
            }
          } else {
            res.isSuccess = false;
            res.errorMessage = "When send msg comsv/8, nextOrdNo is null.";
          }
        }
      } else {
        res.isSuccess = false;
        res.errorMessage = "When send msg comsv/8, mntMachineState is null.";
      }
    } catch (Exception e) {
      res.isSuccess = false;
      res.errorMessage = e.getMessage();
    }
    return res;
  }
  //add FNSI-redmine6535 fang end
  //    add 7074 2022-12-02 設定していないホスト報知が通知される 張 start
  /**
   * ホスト報知定義更新指示
   */
  @Override
  public DeviceEdgeOrderResponse sendHostNotificationDefinition(String facilityCd, Integer deviceEdgeNo, Long machineNo,Long ordNo) {
    String machineInfo = PayloadBuilder.BuildMachineAndOrdNoPayload(machineNo, ordNo);
    return sendMessageToComServer(facilityCd, deviceEdgeNo, WebSocketTopic.ComSv.HOST_NOTIFICATION_DEFINITION, machineInfo);
  }
  //    add 7074 2022-12-02 設定していないホスト報知が通知される 張 end
}
