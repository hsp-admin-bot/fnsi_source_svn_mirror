package jp.co.nikkiso.ntss.admin_web.service.mstSynchro;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import jp.co.nikkiso.ntss.admin_web.response.mstSynchro.MstDeviceEdge;
import jp.co.nikkiso.ntss.admin_web.response.mstSynchro.MstDeviceEdgeResponse;
import jp.co.nikkiso.ntss.admin_web.response.mstSynchro.MstFacility;
import jp.co.nikkiso.ntss.admin_web.response.mstSynchro.MstFacilityResponse;
import jp.co.nikkiso.ntss.admin_web.response.mstSynchro.SynchroMstMNoticeResponse;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.dao.MstDeviceEdgeDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilityDao;
import jp.co.nikkiso.ntss.core.dao.MstMNoticeDao;
import jp.co.nikkiso.ntss.core.dao.MstMachineDao;
import jp.co.nikkiso.ntss.core.entity.MstMNotice;
import jp.co.nikkiso.ntss.core.entity.MstMachine;
import lombok.extern.slf4j.Slf4j;


/**
 * マスタ同期のService実装クラス.
 */
@Slf4j
@Service
public class MstSynchroServiceImpl implements MstSynchroService {

  @Autowired
  private MstFacilityDao mstFacilityDao;

  @Autowired
  private MstDeviceEdgeDao mstDeviceEdgeDao;

  @Autowired
  private MstMachineDao mstMachineDao;

  @Autowired
  private MstMNoticeDao mstMNoticeDao;

  @Autowired
  private DeviceEdgeConnectService deviceEdgeConnectService;

  /**
  * ロギングのServiceインタフェース.
  */
  @Autowired
  private LogService logService;
  /**
   * topicの共通部分
   */
  private final String topicBase = "NTSS/MST_SYNCHRO";

  /**
   * {@inheritDoc}
   */
  @Override
  public MstFacilityResponse getMstFacilityList() {

    // 施設マスタ情報取得
    // 取得後、responseに入れ直し
    List<MstFacility> facilityList = this.mstFacilityDao.selectAllOrderBy("order by facility_name")
        .stream()
        .map(e -> new MstFacility(
          e.getFacilityCd(),
          e.getFacilityName()))
        .collect(Collectors.toList());

    return new MstFacilityResponse(facilityList);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public MstDeviceEdgeResponse getMstDeviceEdgeList(String facilityCd) {

    // デバイスエッジマスタ情報取得
    // 取得後、responseに入れ直し
    List<MstDeviceEdge> deviceEdgeList = this.mstDeviceEdgeDao.selectByFacilityCd(facilityCd)
        .stream()
        .map(e -> new MstDeviceEdge(
          e.getFacilityCd(),
          e.getDeviceEdgeNo(),
          e.getDeviceName(),
          e.getRegDate(),
          e.getUpDate()))
        .collect(Collectors.toList());

    return new MstDeviceEdgeResponse(deviceEdgeList);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public boolean startMstSynchro(String facilityCd, String mstTable, Integer deviceEdgeNo) {

    // 同期結果格納用
    boolean ret = true;

    switch (mstTable) {
      case "mst_machine":
        // 装置マスタ
        //
        if (-1 == deviceEdgeNo) {
          // デバイスエッジが指定されていない場合("すべて"を指定されている場合)
          // デバイスエッジマスタ情報を取得し、取得したすべてのデバイスエッジを対象にマスタ同期を行う
          MstDeviceEdgeResponse deviceEdgeResponse = getMstDeviceEdgeList(facilityCd);
          if (null  == deviceEdgeResponse || null == deviceEdgeResponse.deviceEdgeList) {
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage("[マスタ同期]デバイスエッジマスタの取得失敗 ： 施設コード["+ facilityCd + "]、デバイスエッジ番号[" + deviceEdgeNo +"]");
            logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
            return false;
          }
          if (0 == deviceEdgeResponse.deviceEdgeList.size()) {
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage("[マスタ同期]デバイスエッジマスタの取得件数0件 ： 施設コード[" + facilityCd +"]、デバイスエッジ番号[" + deviceEdgeNo + "]");
            logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
            return false;
          }

          // デバイスエッジ分、マスタ同期を行う
          for (int i = 0; i < deviceEdgeResponse.deviceEdgeList.size(); i++) {
            if (false == synchroMstMachine(facilityCd, deviceEdgeResponse.deviceEdgeList.get(i).deviceEdgeNo)) {
              // 複数デバイスエッジに対してマスタ同期を行う場合、途中にエラーが発生していても、すべてのデバイスエッジに対して同期を行う
              ret = false;
            }
          }
        }
        else {
          // デバイスエッジが指定されている場合、指定デバイスエッジのみマスタ同期を行う
          ret = synchroMstMachine(facilityCd, deviceEdgeNo);
        }
        break;

      case "mst_m_notice":
        // 緊急発報マスタ
        ret = synchroMstMNoticeProc(facilityCd);
        break;

      default:
        EventLogMessage eventLogMessage = new EventLogMessage();
    		eventLogMessage.setLogMessage("[マスタ同期]対象外のマスタテーブルが指定された ： [" + mstTable + "]");
    		logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        ret = false;
        break;
    }

    return ret;
  }

  /**
   * 装置マスタ同期処理.
   *
   * @param facilityCd 施設コード
   * @param deviceEdgeNo デバイスエッジ番号
   * @return
   */
  private boolean synchroMstMachine(String facilityCd, Integer deviceEdgeNo) {

    // 対象施設・デバイスエッジの装置マスタ情報を取得
    List<MstMachine> lstMstMachine = this.mstMachineDao.selectByFacilityAndDeviceEdgeNo(facilityCd, deviceEdgeNo);
    if (null == lstMstMachine) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("[マスタ同期]装置マスタの取得失敗 ： 施設コード[" + facilityCd + "]、デバイスエッジ番号[" + deviceEdgeNo +"]");
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      return false;
    }
//    if (0 == lstMstMachine.size()) {
//      log.error("[マスタ同期]装置マスタの取得件数0件 ： 施設コード[{}]、デバイスエッジ番号[{}]", facilityCd, deviceEdgeNo);
//      return true;
//    }

    // すべてのデバイスエッジが対象の場合

    // デバイスエッジへ送信するデータ格納用
    String payload = "";

    for (int i = 0; i < lstMstMachine.size(); i++) {

      // 1件ずつ処理
      MstMachine data = lstMstMachine.get(i);

      try {
        // 型式コード
        payload += StringPadding(data.getMachineTypeCd(), 3);
        // 通信フォーマット
        payload += StringPadding(data.getComFormatCd(), 1);
        // 製造番号
        payload += StringPadding(data.getMachineSerial(), 8);

        // IPアドレス
        // IPアドレスを'.'で区切って頭0埋め(各3byteの合計15byte)
        String ipAdress = "";
        String[] lstIpAdress = data.getIpAddress().toString().split("\\.");
        for (int j = 0; j < lstIpAdress.length; j++) {
          if ("".compareTo(ipAdress) != 0) {
            ipAdress += ".";
          }

          // 文字列に対してはいきなり0埋めは出来ないので、まずは空白詰めを実施し、空白を0に置換している
          ipAdress += String.format("%3s", lstIpAdress[j]).replace(' ', '0');
        }
        payload += ipAdress;

        // ポート番号
        payload += StringPadding(data.getPort(), 5);
        // FTP収集
        payload += StringPadding(data.getIsFtp(), 1);
        // 通信種別
        payload += (null == data.getComType()) ? " " : data.getComType();
      } catch (Exception e) {

        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("[マスタ同期]ペイロードのbyte精査処理で異常 ： 型式コード[" +  data.getMachineTypeCd() + "]、通信フォーマット["
            + data.getComFormatCd() + "]、製造番号[" + data.getMachineSerial() + "]、IPアドレス[" + data.getIpAddress().toString() + "]、ポート番号["
            + data.getPort() + "]、FTP収集[" + data.getIsFtp() + "]、通信種別[" + data.getComType() + "]");
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);

        return false;
      }
    }

    // 同期依頼
    String topic = this.topicBase + "/" + facilityCd + "/" + deviceEdgeNo;
    if (false == this.deviceEdgeConnectService.sendToDeviceEdge(facilityCd, deviceEdgeNo, topic, payload)) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("[マスタ同期]DE通知API処理で失敗 ： 施設コード[" + facilityCd +"]、デバイスエッジ番号[" + deviceEdgeNo +"]");
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      return false;
    }

    return true;
  }

  /**
   * 緊急発報マスタ同期処理.
   *
   * @param facilityCd
   * @return
   */
  public SynchroMstMNoticeResponse synchroMstMNotice(String facilityCd) {
    
    SynchroMstMNoticeResponse ret = new SynchroMstMNoticeResponse(new ArrayList<MstDeviceEdge>(), true);

    // 対象施設の緊急発報マスタ情報を取得
    List<MstMNotice> lstMstMNotice = this.mstMNoticeDao.selectByFacilityCd(facilityCd);
    if (null == lstMstMNotice) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("[マスタ同期]緊急発報マスタの取得失敗 ： 施設コード[" + facilityCd + "]");
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      ret.isSuccess = false;
      return ret;
    }
    // if (0 == lstMstMNotice.size()) {
    //   log.error("[マスタ同期]緊急発報マスタの取得件数0件 ： 施設コード[{}]", facilityCd);
    //   return false;
    // }

    // 通信共通V4に絞る
    List<MstMNotice> lstV4 = lstMstMNotice
        .stream()
        .filter(ele -> null != ele.getMachineRecordCd() && true == ele.getMachineRecordCd().startsWith("V"))
        .collect(Collectors.toList());

    // 通信共通V4を除外したリストも作成
    List<MstMNotice> lstNonV4 = new ArrayList<>(lstMstMNotice);
    lstNonV4.removeAll(lstV4);

    // デバイスエッジへ送信するデータ格納用
    String payload = "";

    // 通信共通V4を除いたリストでPayloadを作成
    for (int i = 0; i < lstNonV4.size(); i++) {
      payload += lstNonV4.get(i).getMachineRecordCd();
    }

    // 通信共通V4のリストでPayloadを作成
    // ※[装置記録コード]＋[装置記録メッセージ]のPayloadを作成
    // ※[装置記録メッセージ]は50byteとする
    for (int i = 0; i < lstV4.size(); i++) {
      // 通信共通V4との区切りの為、'_'を付与
      // ※通信共通V4は存在するが、通信共通V4以外のメッセージが存在しない場合でも付与
      // ※通信共通V4のメッセージが存在しない場合は不要
      if (0 == i) {
        payload += "_";
      }

      MstMNotice data = lstV4.get(i);

      // Payloadの装置記録コード格納用
      String resultCode = data.getMachineRecordCd();

      // Payloadの装置記録メッセージ格納用
      String resultMsg = "";

      try {
        // 装置記録メッセージが50byteになるように精査
        resultMsg = StringPadding(data.getMachineRecordMessage(), 50);
      } catch (Exception e) {
        EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage("[マスタ同期]装置記録メッセージのbyte精査処理で異常 ： 装記録コード["+ data.getMachineRecordCd() + "]、メッセージ[" + data.getMachineRecordMessage() + "]");
            logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        ret.isSuccess = false;
        return ret;
      }

      // Payload作成
      payload += resultCode + resultMsg;
    }
    
    // デバイスエッジマスタ情報を取得し、取得したすべてのデバイスエッジを対象にマスタ同期を行う
    MstDeviceEdgeResponse deviceEdgeResponse = getMstDeviceEdgeList(facilityCd);
    if (null  == deviceEdgeResponse || null == deviceEdgeResponse.deviceEdgeList) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("[マスタ同期]デバイスエッジマスタの取得失敗 ： 施設コード[" + facilityCd + "]");
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      ret.isSuccess = false;
      return ret;
    }
    if (0 == deviceEdgeResponse.deviceEdgeList.size()) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("[マスタ同期]デバイスエッジマスタの取得件数0件 ： 施設コード[" + facilityCd +"]");
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      ret.isSuccess = false;
      return ret;
    }

    // 同期依頼
    // デバイスエッジ分、マスタ同期を行う
    String topic = this.topicBase + "/" + facilityCd;
    for (int i = 0; i < deviceEdgeResponse.deviceEdgeList.size(); i++) {
      if (false == this.deviceEdgeConnectService.sendToDeviceEdge(facilityCd, deviceEdgeResponse.deviceEdgeList.get(i).deviceEdgeNo, topic, payload)) {
        EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage("[マスタ同期]DE通知API処理で失敗 ： 施設コード[" + facilityCd + "]");
            logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        ret.isSuccess = false;
        ret.failedDeviceEdgeList.add(deviceEdgeResponse.deviceEdgeList.get(i));
      }
    }
    
    return ret;
  }

  /**
   * 緊急発報マスタ同期処理(マスタ同期(隠し画面)).
   *
   * @param facilityCd
   * @return
   */
  private boolean synchroMstMNoticeProc(String facilityCd) {

    // 対象施設の緊急発報マスタ情報を取得
    List<MstMNotice> lstMstMNotice = this.mstMNoticeDao.selectByFacilityCd(facilityCd);
    if (null == lstMstMNotice) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("[マスタ同期]緊急発報マスタの取得失敗 ： 施設コード[" + facilityCd + "]");
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      return false;
    }
    // 通信共通V4に絞る
    List<MstMNotice> lstV4 = lstMstMNotice
        .stream()
        .filter(ele -> null != ele.getMachineRecordCd() && true == ele.getMachineRecordCd().startsWith("V"))
        .collect(Collectors.toList());

    // 通信共通V4を除外したリストも作成
    List<MstMNotice> lstNonV4 = new ArrayList<>(lstMstMNotice);
    lstNonV4.removeAll(lstV4);

    // デバイスエッジへ送信するデータ格納用
    String payload = "";

    // 通信共通V4を除いたリストでPayloadを作成
    for (int i = 0; i < lstNonV4.size(); i++) {
      payload += lstNonV4.get(i).getMachineRecordCd();
    }

    // 通信共通V4のリストでPayloadを作成
    // ※[装置記録コード]＋[装置記録メッセージ]のPayloadを作成
    // ※[装置記録メッセージ]は50byteとする
    for (int i = 0; i < lstV4.size(); i++) {
      // 通信共通V4との区切りの為、'_'を付与
      // ※通信共通V4は存在するが、通信共通V4以外のメッセージが存在しない場合でも付与
      // ※通信共通V4のメッセージが存在しない場合は不要
      if (0 == i) {
        payload += "_";
      }

      MstMNotice data = lstV4.get(i);

      // Payloadの装置記録コード格納用
      String resultCode = data.getMachineRecordCd();

      // Payloadの装置記録メッセージ格納用
      String resultMsg = "";

      try {
        // 装置記録メッセージが50byteになるように精査
        resultMsg = StringPadding(data.getMachineRecordMessage(), 50);
      } catch (Exception e) {
        EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage("[マスタ同期]装置記録メッセージのbyte精査処理で異常 ： 装記録コード["+ data.getMachineRecordCd() + "]、メッセージ[" + data.getMachineRecordMessage() + "]");
            logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        return false;
      }

      // Payload作成
      payload += resultCode + resultMsg;
    }

    // 同期依頼
    String topic = this.topicBase + "/" + facilityCd;
    if (false == this.deviceEdgeConnectService.sendToDeviceEdge(facilityCd, null, topic, payload)) {
      EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage("[マスタ同期]DE通知API処理で失敗 ： 施設コード[" + facilityCd + "]");
          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      return false;
    }

    return true;
  }

  /**
   * 指定文字列のPadding処理 ・指定文字列のbyte数が指定byte数より少ない場合：50byte以降を切り捨て.
   * ・指定文字列のbyte数が指定byte数より多い場合：50byte以降になるまで右側に半角スペース埋め.
   *
   * @param target 対象文字列
   * @param byteNum 指定byte数
   * @return 処理後の文字列
   * @throws Exception
   */
  private String StringPadding(String target, int byteNum) throws Exception {
    // 戻り値用変数
    String resultMsg = "";

    if (false == StringUtils.isEmpty(target)) {
      // 対象文字列を1文字ずつ分割しbyte数チェックをしながら結合
      String[] arrayMsg = target.split("");

      for (int i = 0; i < arrayMsg.length; i++) {
        if (byteNum < (resultMsg + arrayMsg[i]).getBytes("SJIS").length) {
          // 対象文字列が指定byte数を超える場合は終了
          break;
        }

        // 1文字を結合
        resultMsg += arrayMsg[i];
      }
    }

    // 指定byte数になるまで右側に半角スペースを付与
    // ※String.format("%-" + byteNum + "s", resultMsg)で実施すると指定バイト数分の文字列数となるのでNG
    for (int i = byteNum; resultMsg.getBytes("SJIS").length < i;) {
      resultMsg += " ";
    }

    return resultMsg;
  }
 //8104   心電図スイッチ      ljd Start
  public Integer selectAllSysFunctionAdvanceds( String func_advcd ,String facilityCd){
   if(mstFacilityDao.selectByAddvancedSettingCodeAndFacilityCd(func_advcd,facilityCd)==null){
     return 0;
   }else{
     return 1;
   }

  }
   //8104   心電図スイッチ      ljd end
}
