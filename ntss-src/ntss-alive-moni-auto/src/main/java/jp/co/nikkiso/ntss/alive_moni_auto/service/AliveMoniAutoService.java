package jp.co.nikkiso.ntss.alive_moni_auto.service;

import java.net.URI;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.Base64;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils;
import org.springframework.aop.framework.AopProxyUtils;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.env.Environment;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.RequestEntity;
import org.springframework.http.ResponseEntity;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import com.fasterxml.jackson.databind.ObjectMapper;

import jp.co.nikkiso.ntss.alive_moni_auto.entity.MstFacilityCustom;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.entity.MntDeviceEdgeState;
import jp.co.nikkiso.ntss.core.entity.MstDeviceEdge;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import static jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils.toJson;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end
@Service
public class AliveMoniAutoService {
  @Autowired
  private MstDeviceEdgeService mstDeviceEdgeSv;

  @Autowired
  private MntDeviceEdgeStateService mntDeviceEdgeStateSv;

  @Autowired
  private Environment environment;

  @Autowired
  private LogService logService;

  /**
   * REST API側へ渡す情報の格納用クラス
   */
  public static class AliveMoniTarget {
    /**
     * 施設コード
     */
    String facilityCd;

    /**
     * デバイスエッジ番号
     */
    Integer deviceEdgeNo;

    /**
     * 施設コードGetter
     */
    public String getFacilityCd() {
      return this.facilityCd;
    }

    /**
     * 施設コードSetter
     */
    public void setFacilityCd(String facilityCd) {
      this.facilityCd = facilityCd;
    }

    /**
     * デバイスエッジ番号Getter
     */
    public Integer getDeviceEdgeNo() {
      return this.deviceEdgeNo;
    }

    /**
     * デバイスエッジ番号Setter
     */
    public void setDeviceEdgeNo(Integer deviceEdgeNo) {
      this.deviceEdgeNo = deviceEdgeNo;
    }
  }

  /**
   * 死活監視確認実施中の情報を格納するクラス
   */
  public static class ProcInfo {
    /**
     * 施設コード
     */
    String facilityCd;

    /**
     * デバイスエッジ番号
     */
    Integer deviceEdgeNo;

    /**
     * 監視要求実施日時
     */
    Date procDate;

    /**
     * 施設コードGetter
     */
    public String getFacilityCd() {
      return this.facilityCd;
    }

    /**
     * 施設コードSetter
     */
    public void setFacilityCd(String facilityCd) {
      this.facilityCd = facilityCd;
    }

    /**
     * デバイスエッジ番号Getter
     */
    public Integer getDeviceEdgeNo() {
      return this.deviceEdgeNo;
    }

    /**
     * デバイスエッジ番号Setter
     */
    public void setDeviceEdgeNo(Integer deviceEdgeNo) {
      this.deviceEdgeNo = deviceEdgeNo;
    }

    /**
     * 監視要求実施日時Getter
     */
    public Date getProcDate() {
      return this.procDate;
    }

    /**
     * 監視要求実施日時Getter
     */
    public void setProcDate(Date procDate) {
      this.procDate = procDate;
    }
  }

  /**
   * 起動要求の応答確認関数の戻り値
   */
  public enum RetTimeout {
    /** エラー */
    ERROR,
    /** 待ち時間内 */
    LESS,
    /** 待ち時間超過 */
    OVER,
  }

  /* upd by chamaojia 2026-04-24 [10959] システム内でstatic変数を使っている箇所の洗い出し  --start */
  /**
   * 死活監視実施確認
   *
   * @param facilityData
   * @param procInfoMap
   */
  @Async
  public void Schedule(MstFacilityCustom facilityData, Map<String, ProcInfo> procInfoMap, int timeoutNum) {
    if (null == facilityData) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("死活監視：施設マスタデータ[facilityData]がnull");
      eventLogMessage.setFacilityCd(facilityData.getFacilityCd());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
      return;
    }

    if (false == facilityData.getIsStart()) {
      return;
    }

    // 系列施設コード
    String facilityCd = facilityData.getFacilityCd();

    // 死活監視間隔
    Integer aliveMoniInterval = facilityData.getAliveMoniInterval();

    // ログ用に施設情報の文字列を作成
    String logFacilityInfo = "対象施設[" + facilityCd + "：" + facilityData.getFacilityName() + "]";

    // デバイスエッジマスタ情報取得
    List<MstDeviceEdge> lstMstDeviceEdge = this.mstDeviceEdgeSv.findById(facilityCd);

    // デバイスエッジ状態管理情報取得
    List<MntDeviceEdgeState> lstMntDeviceEdgeState = this.mntDeviceEdgeStateSv.findById(facilityCd, -1);

    // 現在日時
    Date nowDate = new Date();

    // デバイスエッジマスタ分ループ
    for (int i = 0; i < lstMstDeviceEdge.size(); i++) {
      MstDeviceEdge edgeInfo = lstMstDeviceEdge.get(i);

      // 死活状況確認中かどうかのチェック
      // 施設コード＋デバイスエッジ番号を一意キーとして確認中情報を管理する。
      String procKey = this.createProcInfoKey(facilityCd, edgeInfo.getDeviceEdgeNo());
      ProcInfo procInfo = procInfoMap.get(procKey);
      if (null != procInfo) {
        // 確認中からがどのくらい時間が経過しているかの確認
        // 一定時間経過している場合、異常と判断し強制的に登録
        RetTimeout ret = CheckTimeout(procInfo.getFacilityCd(), procInfo.getDeviceEdgeNo(),
            procInfo.getProcDate(), timeoutNum);
        if (true == RetTimeout.OVER.equals(ret)) {
          // 確認中リストから削除
          procInfoMap.remove(procKey, procInfo);
        }
        continue;
      }

      // 取得したデバイスエッジ状態管理情報の中から対象のデバイスエッジ情報を取得
      List<MntDeviceEdgeState> edgeStateInfo = lstMntDeviceEdgeState.stream()
          .filter(ele -> ele.getDeviceEdgeNo().equals(edgeInfo.getDeviceEdgeNo())).collect(Collectors.toList());

      // 以下条件を満たす場合、起動確認処理を実施
      // ・デバイスエッジ状態管理に対象デバイスエッジのレコードが存在しない場合
      // ・「死活監視間隔 ＜ 現在日時 － 最終確認日時」の場合
      if (0 != edgeStateInfo.size()) {
        // 最終確認日時
        Timestamp lastMoniTime = edgeStateInfo.get(0).getLastMoniTime();

        if (null != lastMoniTime) {
          // 「現在日時」「最終確認日時」の差
          long diff = nowDate.getTime() - lastMoniTime.getTime();

          // 差が「死活監視間隔」以下の場合、起動確認処理を実施しない
          Long aliveMoniIntervalLong = (long) (aliveMoniInterval * 1000);
          if (Long.valueOf(diff).compareTo(aliveMoniIntervalLong) <= 0) {
            continue;
          }
        }
      }

      // ※起動確認処理を実施

      // REST APIへ渡すパラメータの作成
      AliveMoniTarget target = new AliveMoniTarget();
      // 施設コード
      target.setFacilityCd(facilityCd);
      // デバイスエッジ番号
      target.setDeviceEdgeNo(edgeInfo.getDeviceEdgeNo());

      try {
        // パラメータをJson形式(文字列)に変換
        ObjectMapper mapper = new ObjectMapper();

        // 変換
        String json = mapper.writeValueAsString(target);

        // URL取得
        String urlRequest = this.environment.getProperty("aliveMoni.request.uri");

        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setDeviceEdgeNo(String.valueOf(target.getDeviceEdgeNo()));
        eventLogMessage.setLogMessage("死活監視：REST API側に渡す情報[" + json + "]、URL[" + urlRequest + "]　" + logFacilityInfo);
        eventLogMessage.setFacilityCd(facilityData.getFacilityCd());
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);

        // 送信URI
        URI uri = new URI(urlRequest);
        RestTemplate rt = new RestTemplate();

        // リクエスト作成
        RequestEntity<String> request = RequestEntity.post(uri).contentType(MediaType.APPLICATION_JSON)
            .header("SSECCAYEK", "NTSS-NKK-ESM-TDC-YSK").body(json);
		// #9698 アプリケーションログの内容修正 20260328 mod yangxuewang start
        long start = System.currentTimeMillis();
        // リクエスト処理
        ResponseEntity<HttpStatus> response = rt.exchange(request, HttpStatus.class);
        HttpStatus status = response.getStatusCode();
        long cost = System.currentTimeMillis() - start;
        Map<String, Object> map = new HashMap<>();
        map.put("logType", "RESTTEMPLATE-LOG");
        map.put("className", "jp.co.nikkiso.ntss.alive_moni_auto.service.AliveMoniAutoService");
        map.put("methodName", "Schedule");
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
        logService.log(LogLevel.INFO, restTemplateEventLogMessage, null, SERVICE_NAME.REMS, null);
        // #9698 アプリケーションログの内容修正 20260328 mod yangxuewang end
        if (HttpStatus.OK != status) {

        eventLogMessage.setLogMessage("死活監視：REST API側で異常発生　" + logFacilityInfo);
        eventLogMessage.setFacilityCd(facilityData.getFacilityCd());
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
          continue;
        }
      } catch (Exception e) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("死活監視：REST API呼び出し時に例外発生[" + e.getMessage() + "]　" + logFacilityInfo);
        eventLogMessage.setDeviceEdgeNo(String.valueOf(target.getDeviceEdgeNo()));
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
        continue;
      }

      // 処理中情報の作成・追加
      ProcInfo newProcInfo = new ProcInfo();
      newProcInfo.setFacilityCd(facilityCd);
      newProcInfo.setDeviceEdgeNo(edgeInfo.getDeviceEdgeNo());
      newProcInfo.setProcDate(new Date());
      procInfoMap.put(procKey, newProcInfo);
    }
  }

  // 確認中情報(Map)のキー生成規約を一箇所に集約する。
  public String createProcInfoKey(String facilityCd, Integer deviceEdgeNo) {
    return facilityCd + "_" + deviceEdgeNo;
  }
  /* upd by chamaojia 2026-04-24 [10959] システム内でstatic変数を使っている箇所の洗い出し  --end */

  /**
   * 起動要求の応答確認 ・一定時間応答がなかった場合、異常と判断し処理
   *
   * @param facilityCd
   * @param deviceEdgeNo
   * @param procDate
   * @param timeoutNum
   * @return
   */
  public RetTimeout CheckTimeout(String facilityCd, int deviceEdgeNo, Date procDate, int timeoutNum) {
    // 現在日時
    Date nowDate = new Date();

    // 日時差分確認用変数
    long diff = 0;

    // デバイスエッジ状態管理の最終確認日時(DB情報)が監視要求実施日時(キャッシュ情報)
    // 以上であればデバイスエッジから応答があったと判断
    List<MntDeviceEdgeState> lstMntDeviceEdgeState = this.mntDeviceEdgeStateSv.findById(facilityCd, deviceEdgeNo);
    if (1 == lstMntDeviceEdgeState.size()) {
      Timestamp lastMoniTime = lstMntDeviceEdgeState.get(0).getLastMoniTime();
      if (null != lastMoniTime) {
        diff = lastMoniTime.getTime() - procDate.getTime();
        if (0 <= diff) {
          // 最終確認日時が更新されていると判断し、死活監視確認実施中のリストから削除
          return RetTimeout.OVER;
        }
      }
    }

    // 一定時間応答がないかを確認
    diff = nowDate.getTime() - procDate.getTime();
    if (diff < timeoutNum) {
      // 待ち時間を超えていないので、デバイスエッジからの応答を待つ
      return RetTimeout.LESS;
    }

    // ログ
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss.SSS");

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setDeviceEdgeNo(String.valueOf(deviceEdgeNo));
    eventLogMessage.setLogMessage("死活監視：デバイスエッジ起動確認中で一定時間応答がなかった為、異常と判断　起動確認要求日時[" + sdf.format(procDate)
    + "]、施設コード[" + facilityCd + "]、デバイスエッジ番号[" + deviceEdgeNo + "]");
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.REMS, null);

    // 待ち時間を超えているので、強制的にステータスを更新し、死活監視確認実施中のリストから削除
    String deviceStatus = "F2";
    // if (1 == lstMntDeviceEdgeState.size() &&
    // "F1".equals(lstMntDeviceEdgeState.get(0).getAliveMoniStatus()))
    // {
    // // 元々のステータスが「F1：通信異常」の場合、そのまま通信以上とする
    // // 「F1：通信異常」は、デバイスエッジ⇔AWSの通信が切断された際に自動的に登録される(MQTTプロトコルの遺言機能)
    // deviceStatus = "F1";
    // }
    if (1 == lstMntDeviceEdgeState.size()) {
      // 元々のステータスが「F0：手動停止」「F1：通信異常」の場合、そのままとする
      switch (lstMntDeviceEdgeState.get(0).getAliveMoniStatus()) {
      case "F0":
      case "F1":
        // 手動停止 or 通信異常
        deviceStatus = lstMntDeviceEdgeState.get(0).getAliveMoniStatus();
        break;

      default:
        break;
      }
    }

    // RestApiへ送る情報の作成
    String data = facilityCd + "_" + deviceEdgeNo + "_" + deviceStatus;
    data = "{\"content\": " + "\"" + Base64.getEncoder().encodeToString(data.getBytes()) + "\"}";

    // RestApi呼び出し
    try {
      // URL取得
      String urlResponse = this.environment.getProperty("aliveMoni.response.uri");

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
      HttpStatus status = response.getStatusCode();
      long cost = System.currentTimeMillis() - start;
      Map<String, Object> map = new HashMap<>();
      map.put("logType", "RESTTEMPLATE-LOG");
      map.put("className", "jp.co.nikkiso.ntss.alive_moni_auto.service.AliveMoniAutoService");
      map.put("methodName", "CheckTimeout");
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
      logService.log(LogLevel.INFO, restTemplateEventLogMessage, null, SERVICE_NAME.REMS, null);
      // #9698 アプリケーションログの内容修正 20260328 mod yangxuewang end
      if (HttpStatus.OK != status) {
        eventLogMessage.setLogMessage("死活監視：REST API側で異常発生　施設コード[" + facilityCd + "]、デバイスエッジ番号[" + deviceEdgeNo + "]");
        eventLogMessage.setFacilityCd(facilityCd);
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
        return RetTimeout.ERROR;
      }
    } catch (Exception e) {
      eventLogMessage.setLogMessage( "死活監視：REST API呼び出し時に例外発生[" + e.getMessage() + "]　施設コード[" + facilityCd + "]、デバイスエッジ番号[" + deviceEdgeNo + "]");
      eventLogMessage.setFacilityCd(facilityCd);
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
      return RetTimeout.ERROR;
    }
    return RetTimeout.OVER;
  }
}
