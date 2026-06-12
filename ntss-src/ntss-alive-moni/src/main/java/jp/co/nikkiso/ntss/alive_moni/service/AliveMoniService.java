package jp.co.nikkiso.ntss.alive_moni.service;

import java.net.URI;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.Base64;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils;
import org.springframework.aop.framework.AopProxyUtils;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.env.Environment;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.RequestEntity;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.client.RestTemplate;

import tools.jackson.databind.ObjectMapper;

import jp.co.nikkiso.ntss.core.entity.MntClientConnect;
import jp.co.nikkiso.ntss.core.entity.MntDeviceEdgeState;
import jp.co.nikkiso.ntss.alive_moni.constant.AliveMoniConstant.CheckByteNum;
import jp.co.nikkiso.ntss.alive_moni.service.statusUpdate.StatusUpdateService;
import jp.co.nikkiso.ntss.alive_moni.service.util.NtssComIOService;

import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.MntClientConnectDao;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import lombok.Getter;
import lombok.Setter;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import static jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils.toJson;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end

@Service
public class AliveMoniService {

  @Autowired
  private MntDeviceEdgeStateService mntDeviceEdgeStateSv;

  @Autowired
  private Environment environment;

  @Autowired
  private LogService logService;

  @Autowired
  private NtssComIOService ntssComIOService;

  @Autowired
  private StatusUpdateService statusUpdateService;

  @Autowired
  private MntClientConnectDao mntClientConnectDao;

  /**
   * DE通知APIのURI
   */
  @Value("${commApi.uri}")
  private String commApiUri;

  /**
   * topicの共通部分
   */
  final private String _topicBase = "NTSS/ALIVE_MONI";
  // add FNSI-バグ #7480 通信サーバ 高 start
  /**
   * topicの共通部分
   */
  final private String _topicProBase = "NTSS/PROCESS_STATE";
  // add FNSI-バグ #7480 通信サーバ 高 end


  /**
   * Topic、Payload格納用クラス
   *
   */
  public static class PublishInfo {
    public String Topic;
    public String Payload;
    public int CommandResult = 999;
    public boolean Result = false;
  }

  /**
   * 受け取った情報の格納用クラス
   */
  @Getter
  @Setter
  public static class AliveMoniTarget {

    /**
     * 施設コード
     */
    String facilityCd;

    /**
     * デバイスエッジ番号
     */
    Integer deviceEdgeNo;
  }

  @Getter
  @Setter
  public static class NoticeAlert {
    String content;
  }

  /**
   * 死活監視要求
   *
   * @param targetData
   * @return
   */
  public PublishInfo AliveMoni(AliveMoniTarget targetData) {

    // 戻り値用のTopic、Payload格納用クラス
    PublishInfo publishInfo = new PublishInfo();

    // 監視対象情報が無い場合はここで終了
    if (null == targetData) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("死活監視API：引数[targetData]がnull");
      eventLogMessage.setFacilityCd("");
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
      return publishInfo;
    }

    // Topicの作成
    publishInfo.Topic = this._topicBase + "/" + targetData.getFacilityCd() + "/" + targetData.getDeviceEdgeNo();
    // Payloadはなし
    publishInfo.Payload = "";

    // mnt_client_connect から対象の施設のデバイスエッジが接続されている ntss-clietn-comm サーバーのIPアドレスを取得
    List<MntClientConnect> mntClientConnectList = this.mntClientConnectDao.selectByServerType(targetData.getFacilityCd(), 0);
    for (MntClientConnect con : mntClientConnectList) {
      // application.yml から取得した値の宛先IPを置換
      String uriTxt = this.commApiUri.replace("localhost", con.getIpAddress());

      // DE通知API呼び出し
      publishInfo.Result = ntssComIOService.SendToMessage(uriTxt, targetData.getFacilityCd(),
          targetData.getDeviceEdgeNo(), publishInfo.Topic, publishInfo.Payload);

      // 応答が正常であれば処理ループを抜ける
      if (true == publishInfo.Result) {
        break;
      }
    }

    if (false == publishInfo.Result) {
      // エラー
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("死活監視API：DE通知API呼び出しに失敗　対象施設コード[" + targetData.getFacilityCd()
          + "]、対象デバイスエッジ番号[" + targetData.getDeviceEdgeNo() + "]");
      eventLogMessage.setDeviceEdgeNo(String.valueOf(targetData.getDeviceEdgeNo()));
      eventLogMessage.setFacilityCd(targetData.getFacilityCd());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);

      // DE通知アプリで接続失敗した場合、デバイスステータスを「F1：通信異常」として登録する
      String deviceStatus = CoreConstant.AliveMoniStatus.CONNECTION_ERROR;

      // 元々のステータスが「F0：手動停止」の場合、そのままとする
      List<MntDeviceEdgeState> lstMntDeviceEdgeState = this.mntDeviceEdgeStateSv.findById(targetData.getFacilityCd(),
          targetData.getDeviceEdgeNo());
      if (null != lstMntDeviceEdgeState && 1 == lstMntDeviceEdgeState.size()) {
        switch (lstMntDeviceEdgeState.get(0).getAliveMoniStatus()) {
        case CoreConstant.AliveMoniStatus.STOP:
          // 手動停止
          deviceStatus = CoreConstant.AliveMoniStatus.STOP;
          break;

        default:
          break;
        }
      }

      // RestApiへ送る情報の作成
      String data = targetData.getFacilityCd() + "_" + targetData.getDeviceEdgeNo() + "_" + deviceStatus;
      data = "{\"content\": " + "\"" + Base64.getEncoder().encodeToString(data.getBytes()) + "\"}";

      // RestApi呼び出し
      try {
        // URL取得
        String urlResponse = this.GetProperty("aliveMoni.response.uri");

        // 送信URI
        URI uri = new URI(urlResponse);
        RestTemplate rt = new RestTemplate();

        // リクエスト作成
        RequestEntity<String> request = RequestEntity.post(uri).contentType(MediaType.APPLICATION_JSON)
            .header("SSECCAYEK", "NTSS-NKK-ESM-TDC-YSK").body(data);
		// #9698 アプリケーションログの内容修正 20260328 mod yangxuewang start
        long start = System.currentTimeMillis();
        // リクエスト処理
        ResponseEntity<HttpStatus> response = rt.exchange(request, HttpStatus.class);
        HttpStatus status = HttpStatus.valueOf(response.getStatusCode().value());
        long cost = System.currentTimeMillis() - start;
        Map<String, Object> map = new HashMap<>();
        map.put("logType", "RESTTEMPLATE-LOG");
        map.put("className", "jp.co.nikkiso.ntss.alive_moni.service.AliveMoniService");
        map.put("methodName", "AliveMoni");
        map.put("method", request.getMethod());
        map.put("url", request.getUrl());
        map.put("headers", request.getHeaders().toSingleValueMap());
        map.put("requestParameter", request.getBody());
        map.put("status",response.getStatusCode());
        map.put("cost", cost);
        map.put("result",response.getBody());
        EventLogMessage restTemplateEventLogMessage = new EventLogMessage();
        restTemplateEventLogMessage.setLogMessage(toJson(map));
        if (targetData != null && !StringUtils.isEmpty(targetData.getFacilityCd())) {
          restTemplateEventLogMessage.setFacilityCd(targetData.getFacilityCd());
        }
        logService.log(LogLevel.INFO, restTemplateEventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
        // #9698 アプリケーションログの内容修正 20260328 mod yangxuewang end
        if (HttpStatus.OK != status) {
          eventLogMessage.setLogMessage("死活監視API：REST API側で異常発生　施設コード[" + targetData.getFacilityCd()
              + "]、デバイスエッジ番号[" + targetData.getDeviceEdgeNo() + "]");
          eventLogMessage.setDeviceEdgeNo(String.valueOf(targetData.getDeviceEdgeNo()));
          eventLogMessage.setFacilityCd(targetData.getFacilityCd());
          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
          return publishInfo;
        }
      } catch (Exception e) {
        eventLogMessage.setLogMessage("死活監視API：REST API呼び出し時に例外発生[" + e.getMessage() + "]　施設コード["
            + targetData.getFacilityCd() + "]、デバイスエッジ番号[" + targetData.getDeviceEdgeNo() + "]");
        eventLogMessage.setDeviceEdgeNo(String.valueOf(targetData.getDeviceEdgeNo()));
        eventLogMessage.setFacilityCd(targetData.getFacilityCd());
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
        return publishInfo;
      }

      return publishInfo;
    }

    // 処理成功
    publishInfo.Result = true;

    return publishInfo;
  }

  /**
   * 死活監視受信
   *
   * @return
   */
  public boolean AliveMoniResponse(String strReceptData) {

    // 日付変換用
    SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddHHmmss");

    // 受信データを分解([施設コード]_[デバイスエッジ番号]_[デバイスエッジステータス]_{[型式コード][通信フォーマット][製造番号][工程状態]})
    // ※"_{}"部分は装置の場合のみ
    String[] lstReceptData = strReceptData.split("_");

    // Payload情報格納用変数
    String facilityCd = "";
    String edgeNo = "";
    String edgeStatus = "";
    String machineInfo = "";

    // 最終確認日時、登録・更新日時用の日時
    Timestamp nowDate = new Timestamp(System.currentTimeMillis());

    // デバイスエッジ番号格納用変数
    Integer deviceEdgeNo;

    // 緊急発報API呼び出しフラグ
    boolean isNotice = false;

    EventLogMessage eventLogMessage = new EventLogMessage();

    try {
      if (lstReceptData.length < 3) {
        // 想定の長さに足りていない場合は処理を中止
        eventLogMessage.setLogMessage("死活監視API：受信データが異常の為、受信処理を中止　受信データ[" + strReceptData + "]");
        eventLogMessage.setDeviceEdgeNo(edgeNo);
        eventLogMessage.setFacilityCd(facilityCd);
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);

        return false;
      }

      facilityCd = lstReceptData[0];
      edgeNo = lstReceptData[1];
      edgeStatus = lstReceptData[2];

      // デバイスエッジ情報の値チェック
      if (false == CheckPayloadEdge(facilityCd, edgeNo, edgeStatus)) {
        eventLogMessage.setLogMessage("死活監視API：受信データのデバイスエッジ情報が異常の為、受信処理を中止　受信データ[" + strReceptData + "]");
        eventLogMessage.setDeviceEdgeNo(edgeNo);
        eventLogMessage.setFacilityCd(facilityCd);
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);

        return false;
      }

      deviceEdgeNo = Integer.parseInt(edgeNo);

      if (lstReceptData.length == 3) {
        // デバイスエッジ

        // データの更新
        isNotice = statusUpdateService.DoUpdateOfDeviceEdgeStatus(facilityCd, deviceEdgeNo, edgeStatus, nowDate).isNotice;

      } else {
        // 装置
        machineInfo = "";
        // 基本的にはないことだが、装置製造番号に"_"が含まれていた場合は分割されてしまっているので連結する
        for (int i = 3; i < lstReceptData.length; i++) {
          if (!machineInfo.isEmpty()) {
            machineInfo += "_";
          }
          machineInfo += lstReceptData[i];
        }

        // 装置情報の値チェック
        if (false == CheckPayloadDevice(machineInfo)) {
          eventLogMessage.setLogMessage("死活監視API：受信データの装置情報が異常の為、受信処理を中止　受信データ[" + strReceptData + "]");
          eventLogMessage.setDeviceEdgeNo(edgeNo);
          eventLogMessage.setFacilityCd(facilityCd);
          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);

          return false;
        }

        // デバイスエッジ状態+装置状態を受け取った際の状態更新処理
        isNotice = statusUpdateService.DoUpdateOfDeviceEdgeWithMachineStatus(facilityCd, deviceEdgeNo, edgeStatus, machineInfo, nowDate).isNotice;

      }
    } catch (Exception ex) {
      // 例外発生（呼び出し先処理の@Transactionalによってロールバック済み）
      eventLogMessage.setLogMessage("死活監視API：登録・更新失敗(ロールバック)　施設コード[" + facilityCd + "]　例外[" + ex.getMessage() + "]");
      eventLogMessage.setDeviceEdgeNo(edgeNo);
      eventLogMessage.setFacilityCd(facilityCd);
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);

      return false;
    }

    eventLogMessage.setLogMessage("死活監視API：登録・更新成功(コミット)　施設コード[" + facilityCd + "]");
    eventLogMessage.setDeviceEdgeNo(edgeNo);
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.REMS, null);

    if (!isNotice) {
      // 緊急発報外
      eventLogMessage.setLogMessage("死活監視API：デバイスエッジステータスの正常・異常通知不要または通知済みなので緊急発報しない[" + edgeStatus + "]");
      eventLogMessage.setDeviceEdgeNo(edgeNo);
      eventLogMessage.setFacilityCd(facilityCd);
      logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.REMS, null);
      return true;
    }

    // メール発報
    // ・RestApiへ送る情報の作成(ペイロード文字列を作成し、Base64へ変換)
    // ・ペイロード：[施設コード][デバイスエッジ番号(左0埋め2桁)][発生日時(YYYYMMDDHH24MISS)][装置記録コード(G000：F1、G001：F2)]

    // デバイスエッジステータスから装置記録コードへ変換(DBへアクセスせずに固定で、「01」「F1」「F2」のみ)
    String code = this.GetMachineRecord(edgeStatus);
    if (StringUtils.isEmpty(code)) {
      // デバイスエッジの死活監視ステータスが発報対象外の場合に発生
      // 予期せぬコードの場合もここに来るが、発報対象外として正常で処理する
      eventLogMessage.setLogMessage("死活監視API：緊急発報対象外のデバイスエッジステータス[" + edgeStatus + "]");
      eventLogMessage.setDeviceEdgeNo(edgeNo);
      eventLogMessage.setFacilityCd(facilityCd);
      logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.REMS, null);
      return true;
    }

    // ペイロード作成
    String data = facilityCd + String.format("%2s", edgeNo).replace(" ", "0") + sdf.format(nowDate) + code;

    eventLogMessage.setLogMessage(
        "死活監視API：緊急発報メール送信APIに渡すデータ(Base64変換前)[" + data + "]　施設コード[" + facilityCd + "]、デバイスエッジ番号[" + edgeNo + "]");
    eventLogMessage.setDeviceEdgeNo(edgeNo);
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.REMS, null);

    // ペイロード部分をBase64に変換
    data = "{\"content\": " + "\"" + Base64.getEncoder().encodeToString(data.getBytes()) + "\"}";

    eventLogMessage.setLogMessage("死活監視API：緊急発報メール送信APIに渡すデータ(Base64変換後Json形式)[" + data + "]　施設コード["
        + facilityCd + "]、デバイスエッジ番号[" + edgeNo + "]");
    eventLogMessage.setDeviceEdgeNo(edgeNo);
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.REMS, null);
    // RestApi呼び出し
    try {
      ObjectMapper mapper = new ObjectMapper();
      NoticeAlert alert = mapper.readValue(data, NoticeAlert.class);

      // 送信URI
      URI uri = new URI(this.GetProperty("noticeAlert.uri"));
      RestTemplate rt = new RestTemplate();

      // リクエスト作成
      RequestEntity<NoticeAlert> request = RequestEntity.post(uri).contentType(MediaType.APPLICATION_JSON)
          .header("SSECCAYEK", "NTSS-NKK-ESM-TDC-YSK").body(alert);
	  // #9698 アプリケーションログの内容修正 20260328 mod yangxuewang start
      long start = System.currentTimeMillis();
      // リクエスト処理
      ResponseEntity<HttpStatus> response = rt.exchange(request, HttpStatus.class);
      long cost = System.currentTimeMillis() - start;
      Map<String, Object> map = new HashMap<>();
      map.put("logType", "RESTTEMPLATE-LOG");
      map.put("className", "jp.co.nikkiso.ntss.alive_moni.service.AliveMoniService");
      map.put("methodName", "AliveMoniResponse");
      map.put("method", request.getMethod());
      map.put("url", request.getUrl());
      map.put("headers", request.getHeaders().toSingleValueMap());
      map.put("requestParameter", request.getBody());
      map.put("status",response.getStatusCode());
      map.put("cost", cost);
      map.put("result",response.getBody());
      EventLogMessage restTemplateEventLogMessage = new EventLogMessage();
      restTemplateEventLogMessage.setLogMessage(toJson(map));
      restTemplateEventLogMessage.setFacilityCd(facilityCd);
      logService.log(LogLevel.INFO, restTemplateEventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
	  // #9698 アプリケーションログの内容修正 20260328 mod yangxuewang end
    } catch (Exception e) {
      eventLogMessage.setLogMessage(
          "死活監視API：緊急発報メール送信API呼び出し時に例外発生[" + e.getMessage() + "]　施設コード[" + facilityCd + "]、デバイスエッジ番号[" + edgeNo + "]");
      eventLogMessage.setDeviceEdgeNo(edgeNo);
      eventLogMessage.setFacilityCd(facilityCd);
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
      return false;
    }
    eventLogMessage.setLogMessage("死活監視API：緊急発報メール送信API呼び出しに成功");
    eventLogMessage.setDeviceEdgeNo(edgeNo);
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.REMS, null);
    return true;
  }


  /**
   * 装置記録コード
   */
  private String GetMachineRecord(String status) {
    switch (status) {
    case CoreConstant.AliveMoniStatus.RUNNING:
      return CoreConstant.AliveMoniDeviceEdgeAlarmCode.RECONNECT;
    case CoreConstant.AliveMoniStatus.CONNECTION_ERROR:
      return CoreConstant.AliveMoniDeviceEdgeAlarmCode.CONNECT_ERROR;
    case CoreConstant.AliveMoniStatus.DEVICE_ERROR:
      return CoreConstant.AliveMoniDeviceEdgeAlarmCode.DEVICE_ERROR;
    default:
      return null;
    }
  }

  /**
   * 設定ファイルから指定の情報を読込み
   *
   * @param property
   * @return
   */
  public String GetProperty(String property) {
    // 設定ファイルから指定の取得
    return this.environment.getProperty(property);
  }

  /**
   * デバイスエッジ情報のPayloadのチェック処理
   *
   * @param facilityCd
   * @param edgeNo
   * @param edgeStatus
   * @return
   */
  private boolean CheckPayloadEdge(String facilityCd, String edgeNo, String edgeStatus) {

    // 施設コードのバイト数チェック
    if (CheckByteNum.FacilityCdByteNum != GetByteNum(facilityCd)) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("死活監視API：Payload(施設コード)のバイト数が不正　施設コード[" + facilityCd + "]");
      eventLogMessage.setDeviceEdgeNo(edgeNo);
      eventLogMessage.setFacilityCd(facilityCd);
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
      return false;
    }

    // デバイスエッジ番号の数値チェック
    if (false == IsNumber(edgeNo)) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("死活監視API：Payload(デバイスエッジ番号)の値が不正　デバイスエッジ番号[" + edgeNo + "]");
      eventLogMessage.setDeviceEdgeNo(edgeNo);
      eventLogMessage.setFacilityCd(facilityCd);
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
      return false;
    }

    // デバイスエッジステータスのバイト数チェック
    if (CheckByteNum.DeviceEdgeStatusByteNum != GetByteNum(edgeStatus)) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("死活監視API：Payload(デバイスエッジステータス)のバイト数が不正　デバイスエッジステータス[" + edgeStatus + "]");
      eventLogMessage.setDeviceEdgeNo(edgeNo);
      eventLogMessage.setFacilityCd(facilityCd);
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
      return false;
    }

    return true;
  }

  /**
   * 装置情報のPayloadのバイト数チェック
   *
   * @param deviceInfo
   * @return
   */
  private boolean CheckPayloadDevice(String deviceInfo) {

    // 装置情報が各項目のバイト数を足した値で割り切れない場合はデータ不正
    if (0 != deviceInfo.length() % CheckByteNum.MachineInfoByteNum) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("死活監視API：Payload(装置情報)のバイト数が不正　装置情報[" + deviceInfo + "]");
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
      return false;
    }

    return true;
  }

  /**
   * 数値変換が可能かどうか
   *
   * @param val
   * @return
   */
  public static boolean IsNumber(String val) {
    try {
      Integer.parseInt(val);
      return true;
    } catch (NumberFormatException nfex) {
      return false;
    }
  }

  /**
   * 対象文字列のバイト数取得
   *
   * @param val
   * @return
   */
  private static int GetByteNum(String val) {
    try {
      // 文字コードをSJISとしてバイト数取得
      // ※UTF-8などでバイト数を取得すると、全角日本語を3バイトとして扱う可能性あり
      return val.getBytes("SJIS").length;
    } catch (Exception e) {
      return -1;
    }
  }
  // add FNSI-バグ #7480 通信サーバ 高 start
  /**
   * 死活監視要求
   *
   * @param targetData
   * @return
   */
  public PublishInfo ProcessAliveMoni(AliveMoniTarget targetData) {

    // 戻り値用のTopic、Payload格納用クラス
    PublishInfo publishInfo = new PublishInfo();

    // 監視対象情報が無い場合はここで終了
    if (null == targetData) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("死活監視PROCESS API：引数[targetData]がnull");
      eventLogMessage.setFacilityCd("");
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
      return publishInfo;
    }

    // Topicの作成
    publishInfo.Topic = this._topicProBase + "/" + targetData.getFacilityCd() + "/" + targetData.getDeviceEdgeNo();
    // Payloadはなし
    publishInfo.Payload = "";

    // mnt_client_connect から対象の施設のデバイスエッジが接続されている ntss-clietn-comm サーバーのIPアドレスを取得
    List<MntClientConnect> mntClientConnectList = this.mntClientConnectDao.selectByServerType(targetData.getFacilityCd(), 0);
    for (MntClientConnect con : mntClientConnectList) {
      // application.yml から取得した値の宛先IPを置換
      String uriTxt = this.commApiUri.replace("localhost", con.getIpAddress());

      // DE通知API呼び出し
      publishInfo.Result = ntssComIOService.SendToMessage(uriTxt, targetData.getFacilityCd(),
        targetData.getDeviceEdgeNo(), publishInfo.Topic, publishInfo.Payload);

      // 応答が正常であれば処理ループを抜ける
      if (true == publishInfo.Result) {
        break;
      }
    }

    if (false == publishInfo.Result) {
      // エラー
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("死活監視PROCESS API：DE通知API呼び出しに失敗　対象施設コード[" + targetData.getFacilityCd()
        + "]、対象デバイスエッジ番号[" + targetData.getDeviceEdgeNo() + "]");
      eventLogMessage.setDeviceEdgeNo(String.valueOf(targetData.getDeviceEdgeNo()));
      eventLogMessage.setFacilityCd(targetData.getFacilityCd());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);

      return publishInfo;
    }

    // 処理成功
    publishInfo.Result = true;

    return publishInfo;
  }
  // add FNSI-バグ #7480 通信サーバ 高 end
}
