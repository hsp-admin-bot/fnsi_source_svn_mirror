package jp.co.nikkiso.ntss.device_edge.service;

import java.util.Collections;
import java.util.List;

import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.TmpCommFailureRecoveryDao;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.TmpCommFailureRecovery;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.utils.TriggerUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import tools.jackson.databind.ObjectMapper;

import jp.co.nikkiso.ntss.core.dao.MniMonitorDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.entity.MniMonitor;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainRstWeightInfo;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

@Service
public class MniMonitorCommFailServiceImpl implements MniMonitorCommFailService {

  @Autowired
  MniMonitorDao mniMonitorDao;
  @Autowired
  TmpCommFailureRecoveryDao tmpCommFailureRecoveryDao;
  @Autowired
  OrdMainDao ordMainDao;

  @Autowired
  private TriggerUtil triggerUtil;

  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
  @Autowired
  private LogService logService;
// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end

  /**
   * モニタデータ登録
   * @param param
   * @param state
   * @return
   * @throws Exception
   */
  private int insertMonitorFunc(MniMonitor param, TmpCommFailureRecovery state) {
    try {
      // データ区分を取得
      Short dataType = param.getDataType();
//      //add #269:強制オフライン 劉 start
//      MniMonitor insertParam = new MniMonitor();
//      //add #269:強制オフライン 劉 end

      // mnt_machine_stateからord_noとpat_idを取得
      TmpCommFailureRecovery machineInfo = tmpCommFailureRecoveryDao.selectByKey(state.getFacilityCd(), state.getMachineTypeCd(),
        state.getMachineSerial());
      if (machineInfo != null) {
        // ord_no設定
        param.setOrdNo(machineInfo.getOrdNo());
        // pat_id設定
        param.setPatId(machineInfo.getPatId());

        // オーダー番号判定
//        if ( param.getOrdNo() != null ) {
          // オーダー番号が有効な場合

          //del 共通通信：サーバ上へ登録した前血圧、後血圧について 劉 start
//          // 前/後血圧判定
//          if (dataType.equals((short)5) || dataType.equals((short)6)) {
//            // 登録前に既に存在している前/後血圧のデータ種別を「2：透析中血圧」に変更する
//            mniMonitorDao.updateDataTypeByOrdNoDataType( param.getOrdNo(), dataType, (short)2);
//          }
          //del 共通通信：サーバ上へ登録した前血圧、後血圧について 劉 end
// add AWSとDEの通信断からの復旧 --趙-- start
//          // statusの下位1bit（治療中ビット）はDBの値を使用する
//          Integer treatState = machineInfo.getMachineStatus() & 0x01;
//          Integer targetState = state.getMachineStatus() & 0xFE;
//          // DBの治療中ビット + 受信値のその他ビット
//          // NOTE: 通信SVが書き換えた治療中ビットが、遅れて送信された装置受信データで上書きされる問題の対策
//          state.setMachineStatus(treatState + targetState);
// add AWSとDEの通信断からの復旧 --趙-- end
//        }
      }
// add AWSとDEの通信断からの復旧 --趙-- start
//      // データ登録
//      //add #269:強制オフライン 劉 start
//      insertParam = param;
//      if (null != machineInfo) {
//        String tmpDeviceSetInfo = machineInfo.getTmpDeviceSetInfo();
//        if (!Objects.isNull(tmpDeviceSetInfo)) {
//          ObjectMapper mapper = new ObjectMapper();
//          JsonNode node = mapper.readTree(tmpDeviceSetInfo);
//          if (!Objects.isNull(node)) {
//            JsonNode dev = mapper.readTree(node.get("dev").toString());
//            if (!Objects.isNull(dev)) {
//              String treatMode = dev.get("15").textValue();
//              if (!Objects.isNull(treatMode) && treatMode.equals("9")) {
//                insertParam.setOrdNo(null);
//                insertParam.setPatId(null);
//              }
//            }
//          }
//        }
//      }
//      //add #269:強制オフライン 劉 end
// add AWSとDEの通信断からの復旧 --趙-- end
      //mod #269:強制オフライン 劉 start
      mniMonitorDao.insert(param);
//      mniMonitorDao.insert(insertParam);
      //mod #269:強制オフライン 劉 end
// add AWSとDEの通信断からの復旧 --趙-- start
     // tmpCommFailureRecoveryDao.updateTmpCommFailureRecoveryCommFail(state);
// add AWSとDEの通信断からの復旧 --趙-- end
      // データ種別判定
      if (dataType.equals((short)3) && (param.getOrdNo() != null && 0 < param.getOrdNo())) {
        // 再循環率を登録した場合でord_noがある場合

        //        Integer reLoopRateMain = null;
        //        // モニタデータ取得
        //        ObjectMapper mapMonitor = new ObjectMapper();
        //        JsonNode node = mapMonitor.readTree(param.getMonitorData());
        //
        //        // 89:再循環率を取得
        //        JsonNode item = node.get("89");
        //        if (item != null) {
        //          reLoopRateMain = item.asInt();
        //        }
        // 生体モニタリング管理番号
        Long reLoopRateMain = param.getBioMoniCtlNo();

        // 指定したord_noのord_mainから実績：体重情報を取得
        ObjectMapper mapWeight = new ObjectMapper();
        String weight = ordMainDao.selectWeightInfo(param.getOrdNo());
        OrdMainRstWeightInfo dto = weight == null || weight.isEmpty() ? new OrdMainRstWeightInfo()
          : mapWeight.readValue(weight, OrdMainRstWeightInfo.class);
        // 再循環率を登録
        dto.setReLoopRateMain(reLoopRateMain);
        // 対象のord_noのord_mainに再循環率を登録
        OrdMain oldOrdMain = ordMainDao.selectByOrdNo(param.getOrdNo());
        ordMainDao.updateWeightInfo(param.getOrdNo(), mapWeight.writeValueAsString(dto));
        OrdMain newOrdMain = ordMainDao.selectByOrdNo(param.getOrdNo());
        triggerUtil.updateTriggerOrdMain(Collections.singletonList(oldOrdMain),
          Collections.singletonList(newOrdMain));
      }
    } catch (tools.jackson.core.JacksonException e) {
      // TODO 自動生成された catch ブロック
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (param != null && param.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(param.getFacilityCd());
      }
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
    }

    return 1;
  }

  @Override
  @Transactional
  public int insertMonitor(MniMonitor param, TmpCommFailureRecovery state) {
    //    try {
    //      mniMonitorDao.insertMonitor(param);
    //      mntMachineStateDao.updateMachineState(state);
    //    } catch (RuntimeException e) {
    //      e.printStackTrace();
    //      throw e;
    //    }
    //
    //  return 1;
    return this.insertMonitorFunc(param, state);
  }

  @Override
  public int insertMonitorDyalysisStart(MniMonitor param, TmpCommFailureRecovery state) {
    //    mniMonitorDao.insertMonitor(param);
    //    mntMachineStateDao.updateDialStart(state);
    //    return 1;
    return this.insertMonitorFunc(param, state);
  }

  @Override
  public int insertMonitorDyalysisFinish(MniMonitor param, TmpCommFailureRecovery state) {
    //    mniMonitorDao.insertMonitor(param);
    //    mntMachineStateDao.updateDialEnd(state);
    //    return 1;
    return this.insertMonitorFunc(param, state);
  }

  @Override
  public List<MniMonitor> selectByOrdNoVital(Long ordNo) {
    return mniMonitorDao.selectByOrdNoVital(ordNo);
  }

}
