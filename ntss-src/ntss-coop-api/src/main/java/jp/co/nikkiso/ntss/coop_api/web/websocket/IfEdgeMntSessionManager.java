package jp.co.nikkiso.ntss.coop_api.web.websocket;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.api.utils.ObjectMapperUtil;
import jp.co.nikkiso.ntss.coop_api.config.IfEdgeConfigulation;
import jp.co.nikkiso.ntss.coop_api.mapping.HealthmonFacility;
import jp.co.nikkiso.ntss.coop_api.mapping.HealthmonServer;
import jp.co.nikkiso.ntss.coop_api.request.IfEdgeWebsocketRequest;
import jp.co.nikkiso.ntss.coop_api.request.MntIfEdgeClientConnectRequest;
import jp.co.nikkiso.ntss.coop_api.response.IfEdgeRestResult;
import jp.co.nikkiso.ntss.coop_api.service.LogService;
import jp.co.nikkiso.ntss.coop_api.utils.ClockWrapper;
import jp.co.nikkiso.ntss.coop_api.utils.IfEdgeConstants;
import jp.co.nikkiso.ntss.coop_api.utils.IfEdgeConstants.IfedgeFixedResult;
import jp.co.nikkiso.ntss.coop_api.utils.IfEdgeConstants.ResponseStatus;
import jp.co.nikkiso.ntss.coop_api.utils.IfEdgeConstants.ResultStatus;
import jp.co.nikkiso.ntss.coop_api.utils.NtssCoopApiConstants;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.MntIfEdgeClientConnectDao;
import jp.co.nikkiso.ntss.core.dao.MntIfEdgeHealthmonDao;
import jp.co.nikkiso.ntss.core.dao.MntIfEdgeManageDao;
import jp.co.nikkiso.ntss.core.dao.MstCoopFacilityDao;
import jp.co.nikkiso.ntss.core.entity.MntIfEdgeClientConnect;
import jp.co.nikkiso.ntss.core.entity.MntIfEdgeHealthmon;
import jp.co.nikkiso.ntss.core.entity.MntIfEdgeManage;
import jp.co.nikkiso.ntss.core.entity.MntIfEdgeManage.EdgeResult;
import jp.co.nikkiso.ntss.core.entity.MstCoopFacility;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils;
import lombok.AllArgsConstructor;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import lombok.Data;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import org.springframework.aop.framework.AopProxyUtils;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.RequestEntity;
import org.springframework.http.ResponseEntity;
import org.springframework.http.client.HttpComponentsClientHttpRequestFactory;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.socket.BinaryMessage;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;

import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import java.util.stream.Collectors;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import static jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils.toJson;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end

@Component
public class IfEdgeMntSessionManager {

  // add 2020-11-16 各API間の呼び出しフローの修正（エッジ主体からAWS主体へ）→負荷増加回避策が必要 孫 start
  @Value("${websocket.if-edge-journal.path}")
  private String ifEdgejournalPath;
  // add 2020-11-16 各API間の呼び出しフローの修正（エッジ主体からAWS主体へ）→負荷増加回避策が必要 孫 end
  // add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 start
  @Value("${websocket.if-edge-mnt.wsPath}")
  private String wsPath;
  // add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 end
  @Value("${server.port:#{8080}}")
  private String port;

  /* add by chamaojia 2024-06-21 [10574] communication security related additions --start */
  @Value("${ntss.coop-api.header-name}")
  private String headerKey;
  @Value("${ntss.coop-api.header-value}")
  private String headerValue;
  /* add by chamaojia 2024-06-21 [10574] communication security related additions --end */

  /**
   * 連携エッジクライアント接続状態のDao
   */
  @Autowired
  MntIfEdgeClientConnectDao mntIfEdgeClientConnectDao;

  /**
   * 連携エッジ制御指示管理のDAO
   */
  @Autowired
  MntIfEdgeManageDao mntIfEdgeManageDao;
  //#9490  add 電子カルテアイコンの連携先情報について 2024-07-19 卓 start
  @Autowired
  MstCoopFacilityDao mstCoopFacilityDao;
  //#9490  add 電子カルテアイコンの連携先情報について 2024-07-19 卓 end
  /**
   * clockWrapper
   */
  @Autowired
  ClockWrapper clockWrapper;

  /**
   * If Edge Configulation
   */
  @Autowired
  IfEdgeConfigulation ifEdgeConfigulation;

  @Autowired
  private LogService logService;
  // add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 start
  @Autowired
  MntIfEdgeHealthmonDao mntIfEdgeHealthmonDao;

  @Autowired
  private IfEdgeMntSessionManager sessionManager;
  // add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 end
  /**
   * RestTemplate
   */
  private RestTemplate restTemplate;

  /**
   * 接続クライアント情報
   */
  @Data
  class WSClientInfo {

    public WSClientInfo(WebSocketSession session, String facilityCd, String serialNo) {
      this.session = session;
      this.facilityCd = facilityCd;
      this.serialNo = serialNo;
    }

    public WSClientInfo(WebSocketSession session, LocalDateTime connectTime) {
      this.session = session;
      this.connectTime = connectTime;
    }

    /**
     * WebSocketセッション情報
     */
    public WebSocketSession session;

    /**
     * 施設コード
     */
    public String facilityCd;

    // add 2021-06-04 #5271:エッジのシリアルチェックがされていない 孫 start
    /**
     * シリアル番号
     */
    public String serialNo;
    // add 2021-06-04 #5271:エッジのシリアルチェックがされていない 孫 end

    public LocalDateTime connectTime;
  }

  /**
   *   The created websocket connection will be saved
   *   (those that have completed verification (pass or fail)
   *        and have not sent a message within the timeout will be deleted)
   */
  private Map<String, WSClientInfo> connectedWSMap = new ConcurrentHashMap<>();

  // Timed Task Tool
  private ScheduledExecutorService scheduledExecutorService;

  /* add by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
  /** startTimer / stopTimer / executor 代入の競合を避ける専用ロック */
  private final Object wsConnectTimerLock = new Object();
  /* add by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */

  /**
   * websocket接続リスト
   */
  // add 9490 電子カルテアイコンの連携先情報について 孟堅 start
  //private List<WSClientInfo> clientList = new ArrayList<WSClientInfo>();
  private List<WSClientInfo> clientList = new CopyOnWriteArrayList<WSClientInfo>();
  // add 9490 電子カルテアイコンの連携先情報について 孟堅 end
  /**
   * 自端末情報[IPアドレス]
   */
  private String localIP;

  /**
   * 自端末IPアドレス文字列設定
   *
   * @param ip
   */
  public void setLocalIp(String ip) {
    this.localIP = ip;
  }

  /**
   * 自端末IPアドレス文字列取得
   *
   * @return IPアドレス文字列
   */
  public String getLocalIp() {
    return this.localIP;
  }


  /**
   * コンストラクタ
   */
  public IfEdgeMntSessionManager() {
    HttpComponentsClientHttpRequestFactory clientHttpRequestFactory = new HttpComponentsClientHttpRequestFactory();
    clientHttpRequestFactory.setReadTimeout(0);
    clientHttpRequestFactory.setConnectTimeout(0);
    restTemplate = new RestTemplate(clientHttpRequestFactory);
  }
  //#10453 mod 死活監視が動作していない 2024-04-30 卓 start
  private Integer getIfEdgeType(WebSocketSession session) {
    if (session.getUri().getPath().contains(IfEdgeConstants.IF_EDGE_MAINTENANCE)) {
      return IfEdgeConstants.IF_EDGE_TYPE_MAINTENANCE;//manager
    }
    return IfEdgeConstants.IF_EDGE_TYPE_JOURNAL;//journal
  }
  //#10453 mod 死活監視が動作していない 2024-04-30 卓 end

  /* add by chamaojia 2024-06-24 [10574] communication security related additions --start */
  public void addConnectClient(WebSocketSession session) {
    if (!connectedWSMap.containsKey(session.getId())) {
      connectedWSMap.put(session.getId(), new WSClientInfo(session, LocalDateTime.now()));
      startTimer();
    }
  }
  public void removeConnectClient(WebSocketSession session) {
    if (connectedWSMap.containsKey(session.getId())) {
      connectedWSMap.remove(session.getId());
      stopTimer();
    }
  }
  /* add by chamaojia 2024-06-24 [10574] communication security related additions --end */

  /**
   * 渡されたセッションと施設を紐づけて保存する。
   *
   * @param session    Websocketセッション
   * @param edgeResult 連携エッジ制御指示管理データ
   */
// mod 2023-02-22 bug #6912 エッジの連携処理を停止しても稼働ビューア画面では正常と表示される 孫 start
//  // mod 2021-06-04 #5271:エッジのシリアルチェックがされていない 孫 start
////  public void addClient(WebSocketSession session, String facilityCd) {
//    public void addClient(WebSocketSession session, String facilityCd, String serialNo) {
//      // mod 2021-06-04 #5271:エッジのシリアルチェックがされていない 孫 end
  public void addClient(WebSocketSession session, EdgeResult edgeResult) {
    /* add by chamaojia 2024-06-24 [10574] communication security related additions --start */
    removeConnectClient(session);
    /* add by chamaojia 2024-06-24 [10574] communication security related additions --end */
    // 施設コード
    String facilityCd = edgeResult.getFacilityCd();
    // シリアル番号
    String serialNo = edgeResult.getSerialNo();
    // 接続状態チェック間隔(送信)
    String journalInterval = edgeResult.getJournalInterval();
    // 接続状態チェック間隔(メンテンス)
    String mainInterval = edgeResult.getMainInterval();
// mod 2023-02-22 bug #6912 エッジの連携処理を停止しても稼働ビューア画面では正常と表示される 孫 end
    // 連携エッジクライアント接続状態取得
    // 連携負荷分散対応 20230714 mod start
//    MntIfEdgeClientConnect mntIfEdgeClientConnect = mntIfEdgeClientConnectDao.selectByFacilityCd(facilityCd);
    // 連携負荷分散対応 20230714 mod end

    // クライアント情報に連携エッジクライアント接続状態と対応する情報があるかどうか確認
    boolean existClient = false;
    for (WSClientInfo clientInfo : clientList) {
      // mod 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 start
      // if (clientInfo.getSession().getId().equals(session.getId())) {
      // mod 6912 エッジの連携処理を停止しても稼働ビューア画面では正常と表示される 吉 start
      // if (clientInfo.getSession().getId().equals(session.getId()) || (clientInfo.getFacilityCd().equals(facilityCd) && clientInfo.getSession().getUri().toString().equals(session.getUri().toString()))) {
      if (clientInfo.getSession().getId().equals(session.getId())) {
        // mod 6912 エッジの連携処理を停止しても稼働ビューア画面では正常と表示される 吉 end
        // mod 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 end
        existClient = true;
      }
      // add 6912 エッジの連携処理を停止しても稼働ビューア画面では正常と表示される 吉 start
      else {
        if (facilityCd.equals(clientInfo.getFacilityCd())
                && clientInfo.getSession().getUri().toString().equals(session.getUri().toString())) {
          clientList.remove(clientInfo);
          WSClientInfo newClientInfo = new WSClientInfo(session, facilityCd, serialNo);
          clientList.add(newClientInfo);
          existClient = true;
        }
      }
      // add 6912 エッジの連携処理を停止しても稼働ビューア画面では正常と表示される 吉 end
    }
    // 連携負荷分散対応 20230714 mod start
//     if (mntIfEdgeClientConnect != null) {
//       // 連携エッジクライアント接続状態にデータあり
//       if (existClient) {
//         // クライアント情報に連携エッジクライアント接続状態と対応する情報がある
//         mntIfEdgeClientConnectDao.update(mntIfEdgeClientConnect);
//         EventLogMessage eventLogMessage = new EventLogMessage();
//         String errMsg = "IFエッジ→AWSへの死活監視電文が送信されなくなった:"+session.getUri().toString()+"-----"+"/ntss-coop-api/ifedge/journal".equals(session.getUri().toString());
//         eventLogMessage.setLogMessage(errMsg);
//         eventLogMessage.setInvokeClass(this.getClass().getName());
//         logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
//         // add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 start
//         if(session.getUri().toString().contains("journal") && session.getUri().toString().contains("ifedge")){
//// mod 2023-02-22 bug #6912 エッジの連携処理を停止しても稼働ビューア画面では正常と表示される 孫 start
////          sessionManager.updateIfEdgeHealthmon(facilityCd,"01","01");
//           sessionManager.updateIfEdgeHealthmonForInterval(facilityCd,"01","01", journalInterval, mainInterval);
//// mod 2023-02-22 bug #6912 エッジの連携処理を停止しても稼働ビューア画面では正常と表示される 孫 end
//         }
//         // add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 end
//       } else {
//         // 対象エッジの連携エッジ制御指示管理の更新
//         updateIfEdgeManage(facilityCd, IfedgeFixedResult.SERVER_DISCONNECT);
//
//         // クライアント情報に連携エッジクライアント接続状態と対応する情報がない
//         mntIfEdgeClientConnectDao.delete(mntIfEdgeClientConnect);
//
//         // 連携エッジクライアント接続状態を登録
//         int cnt = mntIfEdgeClientConnectDao.insert(createMntIfEdgeClientConnect(facilityCd));
//         // 正常に登録されたらメモリ上にWebsocket保持
//         if (cnt == 1) {
//           // mod 2021-06-04 #5271:エッジのシリアルチェックがされていない 孫 start
////          WSClientInfo clientInfo = new WSClientInfo(session, facilityCd);
//           WSClientInfo clientInfo = new WSClientInfo(session, facilityCd, serialNo);
//           // mod 2021-06-04 #5271:エッジのシリアルチェックがされていない 孫 end
//           clientList.add(clientInfo);
//           // add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 start
//           if(session.getUri().toString().contains("journal") && session.getUri().toString().contains("ifedge")){
//// mod 2023-02-22 bug #6912 エッジの連携処理を停止しても稼働ビューア画面では正常と表示される 孫 start
////            sessionManager.updateIfEdgeHealthmon(facilityCd,"01","01");
//             sessionManager.updateIfEdgeHealthmonForInterval(facilityCd,"01","01", journalInterval, mainInterval);
//// mod 2023-02-22 bug #6912 エッジの連携処理を停止しても稼働ビューア画面では正常と表示される 孫 end
//           }else{
//// mod 2023-02-22 bug #6912 エッジの連携処理を停止しても稼働ビューア画面では正常と表示される 孫 start
////            sessionManager.updateIfEdgeHealthmon(facilityCd,"F0","01");
//             sessionManager.updateIfEdgeHealthmonForInterval(facilityCd,"F0","01", journalInterval, mainInterval);
//// mod 2023-02-22 bug #6912 エッジの連携処理を停止しても稼働ビューア画面では正常と表示される 孫 end
//           }
//           // add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 end
//         }
//       }
//     } else {
//
//       // 連携エッジクライアント接続状態を登録
//       int cnt = mntIfEdgeClientConnectDao.insert(createMntIfEdgeClientConnect(facilityCd));
//       // add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 start
//       // del 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 start
//       // sessionManager.updateIfEdgeHealthmon(facilityCd,"F0","F0");
//       // del 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 end
//       // add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 end
//       // 正常に登録され、かつメモリ上に存在しなかったらクライアント情報追加
//       if (cnt == 1 && !existClient) {
//         // mod 2021-06-04 #5271:エッジのシリアルチェックがされていない 孫 start
////        WSClientInfo clientInfo = new WSClientInfo(session, facilityCd);
//         WSClientInfo clientInfo = new WSClientInfo(session, facilityCd, serialNo);
//         // mod 2021-06-04 #5271:エッジのシリアルチェックがされていない 孫 end
//         clientList.add(clientInfo);
//         // add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 start
//// mod 2023-02-22 bug #6912 エッジの連携処理を停止しても稼働ビューア画面では正常と表示される 孫 start
////        sessionManager.updateIfEdgeHealthmon(facilityCd,"F0","F0");
//         sessionManager.updateIfEdgeHealthmonForInterval(facilityCd,"F0","F0", journalInterval, mainInterval);
//// mod 2023-02-22 bug #6912 エッジの連携処理を停止しても稼働ビューア画面では正常と表示される 孫 end
//         // add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 end
//       }
//     }
//     // add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 start
//     // del 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 start
////    if(null != clientList && clientList.size()>0){
////      for(WSClientInfo ws :clientList){
////        if(facilityCd == ws.getFacilityCd() && null != ws.getSession().getUri() && "/ntss-coop-api/ifedge/journal".equals(ws.getSession().getUri().toString())){
////          sessionManager.updateIfEdgeHealthmon(facilityCd,"01","01");
////        }
////      }
////    }
//     // del 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 end
//     // add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 end
//     if (mntIfEdgeClientConnect != null) {
    // 連携エッジクライアント接続状態にデータあり
    int updateCount = 0;
    Integer ifedgeType=this.getIfEdgeType(session);
    if (existClient) {
      List<MntIfEdgeClientConnect> mntIfEdgeClientConnectList = mntIfEdgeClientConnectDao.selectListByIfEdgeType(facilityCd, ifedgeType);
      if (mntIfEdgeClientConnectList != null && mntIfEdgeClientConnectList.size() > 0) {
        // クライアント情報に連携エッジクライアント接続状態と対応する情報がある
        MntIfEdgeClientConnect mntIfEdgeClientConnect = mntIfEdgeClientConnectList.get(0);
        mntIfEdgeClientConnect.setIpAddress(this.getLocalIp());
        updateCount = mntIfEdgeClientConnectDao.update(mntIfEdgeClientConnect);
      } else {
        // 連携エッジクライアント接続状態を登録
        updateCount = mntIfEdgeClientConnectDao.insert(createMntIfEdgeClientConnect(facilityCd, this.getIfEdgeType(session)));
      }
      EventLogMessage eventLogMessage = new EventLogMessage();
      String errMsg = "IFエッジ→AWSへの死活監視電文が送信されなくなった:" + session.getUri().toString() + "-----" + "/ntss-coop-api/ifedge/journal".equals(session.getUri().toString());
      eventLogMessage.setLogMessage(errMsg);
      eventLogMessage.setInvokeClass(this.getClass().getName());
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);

      //#10453 mod 死活監視が動作していない 2024-04-30 卓 start
      if (session.getUri().toString().contains("journal") && session.getUri().toString().contains("ifedge")) {
        sessionManager.updateIfEdgeHealthmonForInterval(facilityCd, "01", "01", journalInterval, mainInterval,IfEdgeConstants.IF_EDGE_TYPE_JOURNAL);
      }else {
        sessionManager.updateIfEdgeHealthmonForInterval(facilityCd, "01", "01", journalInterval, mainInterval,IfEdgeConstants.IF_EDGE_TYPE_MAINTENANCE);
      }
      //#10453 mod 死活監視が動作していない 2024-04-30 卓 end
    } else {
      // 対象エッジの連携エッジ制御指示管理の更新
      updateIfEdgeManage(facilityCd, IfedgeFixedResult.SERVER_DISCONNECT);
      List<MntIfEdgeClientConnect> mntIfEdgeClientConnectList = mntIfEdgeClientConnectDao.selectListByIfEdgeType(facilityCd, this.getIfEdgeType(session));
      if (mntIfEdgeClientConnectList != null && mntIfEdgeClientConnectList.size() > 0) {
        // クライアント情報に連携エッジクライアント接続状態と対応する情報がある
        MntIfEdgeClientConnect mntIfEdgeClientConnect = mntIfEdgeClientConnectList.get(0);
        mntIfEdgeClientConnect.setIpAddress(this.getLocalIp());
        updateCount = mntIfEdgeClientConnectDao.update(mntIfEdgeClientConnect);
      } else {
        // 連携エッジクライアント接続状態を登録
        updateCount = mntIfEdgeClientConnectDao.insert(createMntIfEdgeClientConnect(facilityCd, this.getIfEdgeType(session)));
      }
    }
    // 正常に登録されたらメモリ上にWebsocket保持
    if (updateCount > 0) {
      WSClientInfo clientInfo = new WSClientInfo(session, facilityCd, serialNo);
      if (!existClient) {
        clientList.add(clientInfo);
      }
      //#10453 mod 死活監視が動作していない 2024-04-30 卓 start
      if (session.getUri().toString().contains("journal") && session.getUri().toString().contains("ifedge")) {
        if (!existClient) {
          /* add by chamaojia 2024-10-11 [11140] update mnt_if_edge_healthmon --start */
          // insert mnt_if_edge_healthmon or update mnt_if_edge_healthmon
          // processing after successful websocket connection
          sessionManager.insertOrUpdateIfEdgeHealthmonToFc(facilityCd);
          /* add by chamaojia 2024-10-11 [11140] update mnt_if_edge_healthmon --end */
        }
        sessionManager.updateIfEdgeHealthmonForInterval(facilityCd, "01", "01", journalInterval, mainInterval,IfEdgeConstants.IF_EDGE_TYPE_JOURNAL);
      } else {
        sessionManager.updateIfEdgeHealthmonForInterval(facilityCd, "01", "01", journalInterval, mainInterval,IfEdgeConstants.IF_EDGE_TYPE_MAINTENANCE);
      }
      //#10453 mod 死活監視が動作していない 2024-04-30 卓 end

    }
    // 連携負荷分散対応 20230714 mod end
  }

  /**
   * 指定したセッションのWebsocket切断と連携エッジクライアント接続状態の削除、対象エッジの連携エッジ制御指示管理のステータス更新を行う。
   *
   * @param session           Websocketセッション
   * @param status            クローズステータス
   * @param ifedgeFixedResult 連携エッジ固定結果定義
   */
  public void removeClient(WebSocketSession session, CloseStatus status, IfedgeFixedResult ifedgeFixedResult, boolean clientFlag) {
    /* add by chamaojia 2024-06-24 [10574] communication security related additions --start */
    removeConnectClient(session);
    /* add by chamaojia 2024-06-24 [10574] communication security related additions --end */
    // mod 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 start
    // for (WSClientInfo wsClientInfo : clientList) {
    for (int i = clientList.size(); i > 0; i--) {
      WSClientInfo wsClientInfo = clientList.get(i - 1);
      // mod 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 end
      if (wsClientInfo.getSession().getId().equals(session.getId())) {

        // 対象エッジの連携エッジ制御指示管理の更新
        updateIfEdgeManage(wsClientInfo.getFacilityCd(), ifedgeFixedResult);
        // クライアント情報削除
        // mod 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 start
        // clearClientData(wsClientInfo.getFacilityCd(), status);
        clearClientData(session, wsClientInfo.getFacilityCd(), status, clientFlag);
        // mod 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 end
        break;
      }
      // add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 start
      // del 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 start
//      else{
//        if(session.getUri().toString().contains(ifEdgejournalPath)){
//          updateIfEdgeHealthmon(wsClientInfo.getFacilityCd(),"F0","01");
//        }
//      }
      // del 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 end
      // add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 end
    }
  }

  /**
   * エッジの実行結果を反映する。
   *
   * @param result 連携エッジ制御指示管理データ
   * @throws NtssException
   */
  public void saveResult(EdgeResult result) throws NtssException {
    // 連携エッジ制御指示管理データを取得
    MntIfEdgeManage mntIfEdgeManage = mntIfEdgeManageDao.selectByCtlNo(result.getResult().getCtlNo());
    if (mntIfEdgeManage == null) {
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
      // ログメッセージ出力
      EventLogMessage eventLogMessage = new EventLogMessage();
      String errMsg = "該当の連携エッジ制御指示管理データがありません。ctlNo:" + result.getResult().getCtlNo();
      eventLogMessage.setLogMessage(errMsg);
      eventLogMessage.setInvokeClass(this.getClass().getName());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
      throw new NtssException("該当の連携エッジ制御指示管理データがありません。ctlNo:" + result.getResult().getCtlNo());
    }
    int responseStatus = (HttpStatus.OK.value() == result.getResult().getStatus()) ? ResponseStatus.DONE.getStatus() : ResponseStatus.ERROR.getStatus();
    mntIfEdgeManage.setResponseStatus(responseStatus);
    mntIfEdgeManage.setEdgeResult(result);
    mntIfEdgeManageDao.update(mntIfEdgeManage);
  }

  /**
   * 指定した施設コードのWebsocket切断とクライアント情報の削除を行う。
   *
   * @param facilityCd 施設コード
   * @param status     クローズステータス
   */
  // mod 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 start
//  public void clearClientData(String facilityCd, CloseStatus status) {
  public void clearClientData(WebSocketSession session, String facilityCd, CloseStatus status, boolean clientFlag) {
    // mod 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 end
    //連携エッジクライアント接続状態の削除
    // mod 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 start
    // deleteConnectByFacilityCd(facilityCd);
    // 連携負荷分散対応 20230714 mod start
//    if (!clientFlag) {
//      //連携負荷分散対応 20230714 mod start
//      deleteConnectByFacilityCd(facilityCd);
//    }
    if(clientFlag){
      deleteConnectByFacilityCdAndifEdgeType(facilityCd, 2);
    }else {
      deleteConnectByFacilityCdAndifEdgeType(facilityCd, 1);
    }
    // 連携負荷分散対応 20230714 mod end
    // mod 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 end
    // Websocketの切断とメモリのクライアント情報の削除
    for (WSClientInfo wsClientInfo : clientList) {
      // mod 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 start
      // if (wsClientInfo.getFacilityCd().equals(facilityCd)) {
      if (session.getId() == wsClientInfo.getSession().getId()) {
        // mod 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 end
        try {
          // Websocketセッションクローズ
          wsClientInfo.getSession().close(status);
        } catch (IOException ioe) {
          EventLogMessage eventLogMessage = new EventLogMessage();
          String errMsg = "IfEdgeMntSessionManager#removeClientWebsocketセッションクローズ失敗　施設コード：[" + wsClientInfo.getFacilityCd() + "]";
          eventLogMessage.setLogMessage(errMsg);
          eventLogMessage.setFacilityCd(facilityCd);
          // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
          eventLogMessage.setInvokeClass(this.getClass().getName());
          // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        }
        clientList.remove(wsClientInfo);
        break;
      }
    }
    // add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 start

    //#10453 mod 死活監視が動作していない 2024-04-30 卓 start
    if (clientList.size() > 0) {
      // mod 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 start
      // int count = 0;
      int count = 0;
      int countMaintenance = 0;
      // mod 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 end
      for (WSClientInfo wsClientInfo : clientList) {
        if (facilityCd.equals(wsClientInfo.getFacilityCd())) {
          // mod 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 start
          // count++;
          count++;
//          if ("/ntss-coop-api/ifedge/maintenance/ws".equals(wsClientInfo.getSession().getUri().toString())) {
          if (wsClientInfo.getSession().getUri().toString().contains("maintenance")) {
            countMaintenance++;
          }
          // mod 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 end
        }
      }
      // mod 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 start
      // if(count>0){
      //    updateIfEdgeHealthmon(facilityCd,"F0","01");
      // }
      if (count > 0) {
        if (countMaintenance == 0) {
          updateIfEdgeHealthmon(facilityCd, "F1", "F1", IfEdgeConstants.IF_EDGE_TYPE_ALL);
        } else {
          updateIfEdgeHealthmon(facilityCd, "F0", "01", IfEdgeConstants.IF_EDGE_TYPE_JOURNAL);
        }
      } else {
        updateIfEdgeHealthmon(facilityCd, "F1", "F1", IfEdgeConstants.IF_EDGE_TYPE_ALL);
      }
      // mod 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 end
    } else {
      updateIfEdgeHealthmon(facilityCd, "F1", "F1", IfEdgeConstants.IF_EDGE_TYPE_ALL);
    }
    //#10453 mod 死活監視が動作していない 2024-04-30 卓 end
    // add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 end
  }

  /**
   * デバイスエッジへ送信
   *
   * @param facilityCd 施設コード
   * @param payload    送信メッセージ
   * @return 送信実行結果
   */
  public boolean sendFile(String facilityCd, byte[] payload) throws IOException {
    boolean ret = false;
    for (WSClientInfo client : clientList) {
      // add 2020-11-16 各API間の呼び出しフローの修正（エッジ主体からAWS主体へ）→負荷増加回避策が必要 孫 start
      //if (!facilityCd.equals(client.getFacilityCd())) {
      if (!facilityCd.equals(client.getFacilityCd())
        || !client.session.getUri().toString().endsWith(ifEdgeConfigulation.getWsPath())) {
        // add 2020-11-16 各API間の呼び出しフローの修正（エッジ主体からAWS主体へ）→負荷増加回避策が必要 孫 end
        continue;
      }

      client.getSession().sendMessage(new BinaryMessage(payload, true));
      ret = true;

      break;
    }
    return ret;
  }

  // 連携負荷分散対応 20230714 add start

  /**
   * websocket送信
   *
   * @param request {@link MntIfEdgeClientConnectRequest}
   * @return 送信実行結果
   */
  public Boolean wsClientSend(MntIfEdgeClientConnectRequest request) throws IOException {
    // #10574 mod 連携の死活監視処理でDBが高負荷になる。start
    //if (request.getNgIpList() == null || request.getNgIpList().size() == 0) {
    //  request.setNgIpList(new ArrayList<>());
    //}

    // ifEdgeTypeの設定
    if (request.getIfEdgeType() == null) {
      Integer ifEdgeType = 2;
      //if (ifEdgeConfigulation.getWsPath().contains(IfEdgeConstants.IF_EDGE_MAINTENANCE)) {
      //  ifEdgeType = 1;
      //}
      request.setIfEdgeType(ifEdgeType);
    }
    // 閉じた状態のソケットクライアントを削除する
    this.removeClosedClient(request.getFacilityCd());

    //List<MntIfEdgeClientConnect> unCheckedList = new ArrayList<>();
    //List<MntIfEdgeClientConnect> checkedList = new ArrayList<>();
    List<MntIfEdgeClientConnect> connectList = mntIfEdgeClientConnectDao.selectListByIfEdgeType(request.getFacilityCd(), request.getIfEdgeType());
    if (connectList.isEmpty()) {
      return false;
    }
    //for (MntIfEdgeClientConnect mntIfEdgeClientConnect : connectList) {
    //  if (!request.getNgIpList().contains(mntIfEdgeClientConnect.getIpAddress())) {
    //    unCheckedList.add(mntIfEdgeClientConnect);
    //  } else {
    //    checkedList.add(mntIfEdgeClientConnect);
    //  }
    //}
    // メッセージを送信
    //Boolean sendSucceed=false;
    //List<WSClientInfo> invalidClientList = new ArrayList<>();
    //for (WSClientInfo client : clientList) {
    //  if (!request.getFacilityCd().equals(client.getFacilityCd()) || !client.session.getUri().toString().endsWith(ifEdgejournalPath)) {
    //    continue;
    //  }
    //  // 接続クライアント情報が無効か？
    //  if (!client.getSession().isOpen()) {
    //    // 無効のwebsocket接続リストを追加
    //    invalidClientList.add(client);
    //    continue;
    //  }
    //  URI uri = client.getSession().getUri();
    //  String clientAddress = uri.getHost();
    //  for (MntIfEdgeClientConnect mntIfEdgeClientConnect : unCheckedList) {
    //    if (mntIfEdgeClientConnect.getIpAddress().equals(clientAddress)) {
    //      client.getSession().sendMessage(new TextMessage(request.getMessage()));
    //      sendSucceed=true;
    //      break;
    //    }
    //  }
    //}
    // メモリの無効のクライアント情報のを削除
    //for (WSClientInfo client : invalidClientList) {
    //  clientList.remove(client);

    //  EventLogMessage eventLogMessage = new EventLogMessage();
    //  String errMsg = String.format("%s%s%s"
    //    , "ャーナル作成時デバイスエッジへ送信失敗の接続クライアント情報を削除しました."
    //    , " 施設コード：[" + client.getFacilityCd() + "]"
    //    , " session ID：[" + client.session.getId() + "]"
    //    , " URL：[" + client.session.getUri().toString() + "]");
    //  eventLogMessage.setLogMessage(errMsg);
    //  eventLogMessage.setFacilityCd(request.getFacilityCd());
    //  // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
    //  eventLogMessage.setInvokeClass(this.getClass().getName());
    //  // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
    //  logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    //}

    //if (sendSucceed){
    //  return true;
    //}

    //unCheckedList = unCheckedList.stream().filter(connect -> !connect.getIpAddress().equals(this.getLocalIp())).collect(Collectors.toList());
    //request.getNgIpList().add(this.getLocalIp());

    // coopApi負荷分散、ifedgeと正しいcoopipをリンクしてメッセージを送信
    //if (unCheckedList.size() <= 0) {
    //  return false;

    // 連携エッジクライアントのIPはローカルIP
    MntIfEdgeClientConnect mntIfEdgeClientConnect = connectList.get(0);
    if (mntIfEdgeClientConnect.getIpAddress().equals(this.getLocalIp())) {
      for (WSClientInfo client : clientList) {
        if (request.getFacilityCd().equals(client.getFacilityCd())
                && client.session.getUri().toString().endsWith(ifEdgejournalPath)
        ) {
          // 接続クライアントがメッセージを送信
          client.getSession().sendMessage(new TextMessage(request.getMessage()));
          return true;
        }
      }
    }
    // リモート呼び出し 正しいIPを探してソケットメッセージを送信する
    else {
      URI uri = null;
      try {
        StringBuilder uriBuilder = new StringBuilder();
        uriBuilder.append(ifEdgeConfigulation.getRequestHTTP())
          //.append(unCheckedList.get(0).getIpAddress())
          .append(mntIfEdgeClientConnect.getIpAddress())
          .append(":")
          .append(port)
          .append("/ntss-coop-api/journal/wsClientSend");
        String url = uriBuilder.toString();
        // String url = "http://" + unCheckedList.get(0).getIpAddress() + ":" + port + "/ntss-coop-api/journal/wsClientSend";
        uri = new URI(url);
      } catch (URISyntaxException e) {
        return false;
      }
      Map<String, Object> payloadMap = new HashMap<>();
      payloadMap.put("facility_cd", request.getFacilityCd());
      payloadMap.put("if_edge_type", request.getIfEdgeType());
      //payloadMap.put("ng_ip_list", request.getNgIpList());
      payloadMap.put("message", request.getMessage());
      try {
        HttpHeaders headers = new HttpHeaders();
        headers.setAccept(Arrays.asList(MediaType.APPLICATION_JSON));
        headers.set(headerKey, headerValue);
        HttpEntity<Object> httpEntity = new HttpEntity<>(payloadMap, headers);
		// #9698 アプリケーションログの内容修正 20260328 mod yangxuewang start
        long start = System.currentTimeMillis();
        ResponseEntity<String> response = restTemplate.exchange(uri, HttpMethod.POST, httpEntity, String.class);
        long cost = System.currentTimeMillis() - start;
        Map<String, Object> map = new HashMap<>();
        map.put("logType", "RESTTEMPLATE-LOG");
        map.put("className", "jp.co.nikkiso.ntss.coop_api.web.websocket.IfEdgeMntSessionManager");
        map.put("methodName", "wsClientSend");
        map.put("method", HttpMethod.POST);
        map.put("url", uri);
        map.put("headers", headers.toSingleValueMap());
        map.put("requestParameter", payloadMap);
        map.put("status",response.getStatusCode());
        map.put("cost", cost);
        map.put("result",response.getBody());
        EventLogMessage restTemplateEventLogMessage = new EventLogMessage();
        restTemplateEventLogMessage.setLogMessage(toJson(map));
        if (response != null && !StringUtils.isEmpty(request.getFacilityCd())) {
          restTemplateEventLogMessage.setFacilityCd(request.getFacilityCd());
        }
        logService.log(LogLevel.INFO, restTemplateEventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
        return Boolean.valueOf(response.getBody());
		// #9698 アプリケーションログの内容修正 20260328 mod yangxuewang end
      } catch (RestClientException e) {
        return false;
      }
    }
    return false;
    // #10574 mod 連携の死活監視処理でDBが高負荷になる。end
  }
  // #10574 add 連携の死活監視処理でDBが高負荷になる。start
  /**
   * 閉じた状態のソケットクライアントを削除する
   *
   * @param facilityCd 施設コード
   */
  private void removeClosedClient(String facilityCd) {
    for (WSClientInfo client : clientList) {
      if (!client.getSession().isOpen()) {
        clientList.remove(client);

        EventLogMessage eventLogMessage = new EventLogMessage();
        String errMsg = String.format("%s%s%s"
                , "ャーナル作成時デバイスエッジへ送信失敗の接続クライアント情報を削除しました."
                , " 施設コード：[" + client.getFacilityCd() + "]"
                , " session ID：[" + client.session.getId() + "]"
                , " URL：[" + client.session.getUri().toString() + "]");
        eventLogMessage.setLogMessage(errMsg);
        eventLogMessage.setFacilityCd(facilityCd);
        eventLogMessage.setInvokeClass(this.getClass().getName());
        logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      }
    }
  }
  // #10574 add 連携の死活監視処理でDBが高負荷になる。end
  // 連携負荷分散対応 20230714 add end
  // add 2020-11-16 各API間の呼び出しフローの修正（エッジ主体からAWS主体へ）→負荷増加回避策が必要 孫 start

  /**
   * ャーナル作成時デバイスエッジへ送信
   *
   * @param facilityCd 施設コード
   * @param message    送信メッセージ
   * @return 送信実行結果
   */
  public boolean sendJournalRequest(String facilityCd, String message) throws IOException {
    // 連携負荷分散対応 20230714 mod start
//    boolean ret = false;

//    // 無効のwebsocket接続リスト
//    List<WSClientInfo> invalidClientList = new ArrayList<WSClientInfo>();
    // #10574 mod 連携の死活監視処理でDBが高負荷になる。start
    // websocket送信
    Integer ifEdgeType = 2;
    //if (ifEdgeConfigulation.getWsPath().contains(IfEdgeConstants.IF_EDGE_MAINTENANCE)) {
    //  ifEdgeType = 1;
    //}
    MntIfEdgeClientConnectRequest request = new MntIfEdgeClientConnectRequest();
    request.setMessage(message);
    request.setFacilityCd(facilityCd);
    request.setIfEdgeType(ifEdgeType);
    //request.setNgIpList(new ArrayList<>());
    Boolean ret = this.wsClientSend(request);
    // #10574 mod 連携の死活監視処理でDBが高負荷になる。end
    //    for (WSClientInfo client : clientList) {
    //      if (!facilityCd.equals(client.getFacilityCd())
    //        || !client.session.getUri().toString().endsWith(ifEdgejournalPath)) {
    //        continue;
    //      }
    //
    //      // 接続クライアント情報が無効か？
    //      if (!client.getSession().isOpen()) {
    //        // 無効のwebsocket接続リストを追加
    //        invalidClientList.add(client);
    //        continue;
    //      }
    //
    //      client.getSession().sendMessage(new TextMessage(message));
    //      ret = true;
    //      break;
    //    }
//    // メモリの無効のクライアント情報のを削除
//    for (WSClientInfo client : invalidClientList) {
//      clientList.remove(client);
//
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      String errMsg = String.format("%s%s%s"
//        ,"ャーナル作成時デバイスエッジへ送信失敗の接続クライアント情報を削除しました."
//        ," 施設コード：["+client.getFacilityCd()+"]"
//        ," session ID：["+client.session.getId()+"]"
//        ," URL：["+client.session.getUri().toString()+"]");
//      eventLogMessage.setLogMessage(errMsg);
//      eventLogMessage.setFacilityCd(facilityCd);
//      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
//      eventLogMessage.setInvokeClass(this.getClass().getName());
//      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
//      logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI, null);
//    }
    // 連携負荷分散対応 20230714 mod end

    return ret;
  }
  // add 2020-11-16 各API間の呼び出しフローの修正（エッジ主体からAWS主体へ）→負荷増加回避策が必要 孫 end

  /**
   * 指定先へサーバ間通信
   *
   * @param uri     通信先URI
   * @param headers ヘッダー
   * @param request リクエスト
   * @return 連携エッジ指示レスポンス
   */
  public IfEdgeRestResult transfer(URI uri, HttpHeaders headers, IfEdgeWebsocketRequest request) {

    // リクエスト作成
    RequestEntity<?> req = new RequestEntity<>(request, headers, HttpMethod.POST, uri);
	// #9698 アプリケーションログの内容修正 20260328 mod yangxuewang start
    RequestEntity<IfEdgeWebsocketRequest> logRequest = RequestEntity
      .post(uri)
      .contentType(MediaType.APPLICATION_JSON)
      .headers(headers)
      .body(request);
    long start = System.currentTimeMillis();
    // リクエスト処理
    ResponseEntity<IfEdgeRestResult> response = restTemplate.exchange(req, IfEdgeRestResult.class);
    // log start
    long cost = System.currentTimeMillis() - start;
    Map<String, Object> map = new HashMap<>();
    map.put("logType", "RESTTEMPLATE-LOG");
    map.put("className", "jp.co.nikkiso.ntss.coop_api.web.websocket.IfEdgeMntSessionManager");
    map.put("methodName", "transfer");
    map.put("method", logRequest.getMethod());
    map.put("url", logRequest.getUrl());
    map.put("headers", logRequest.getHeaders().toSingleValueMap());
    map.put("requestParameter", logRequest.getBody());
    map.put("status",response.getStatusCode());
    map.put("cost", cost);
    map.put("result",response.getBody());
    EventLogMessage restTemplateEventLogMessage = new EventLogMessage();
    restTemplateEventLogMessage.setLogMessage(toJson(map));
    logService.log(LogLevel.INFO, restTemplateEventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
    // log end
    return response.getBody();
	// #9698 アプリケーションログの内容修正 20260328 mod yangxuewang end
  }

  /**
   * 指定の施設のWebsocketクライアントセッションを保持しているかどうか
   *
   * @param facilityCd 施設コード
   * @return Websocketクライアントセッション保持状態 true:存在する false:存在しない
   */
  public boolean existsClientSessionByFacilityCd(String facilityCd) {
    for (WSClientInfo clientInfo : clientList) {
      if (clientInfo.getFacilityCd().equals(facilityCd)) {
        return true;
      }
    }
    return false;
  }

  /**
   * 連携エッジクライアント接続状態の新規登録データを作成する
   *
   * @param facilityCd
   * @return 連携エッジクライアント接続状態
   */
  // 連携負荷分散対応 20230714 mod start
//  private MntIfEdgeClientConnect createMntIfEdgeClientConnect(String facilityCd) {
  // 連携負荷分散対応 20230714 mod end
  private MntIfEdgeClientConnect createMntIfEdgeClientConnect(String facilityCd, Integer ifEdgeType) {
    Timestamp now = new Timestamp(clockWrapper.getClockMillis());
    MntIfEdgeClientConnect mntIfEdgeClientConnect = new MntIfEdgeClientConnect();
    mntIfEdgeClientConnect.setFacilityCd(facilityCd);
    mntIfEdgeClientConnect.setIpAddress(this.getLocalIp());
    mntIfEdgeClientConnect.setUpDate(now);
    mntIfEdgeClientConnect.setRegDate(now);
    // 連携負荷分散対応 20230714 mod start
    mntIfEdgeClientConnect.setIfEdgeType(ifEdgeType);
    // 連携負荷分散対応 20230714 mod end
    return mntIfEdgeClientConnect;
  }

  /**
   * 施設コードをキーに連携エッジ制御指示管理エラー更新
   *
   * @param facilityCd        施設コード
   * @param ifedgeFixedResult 連携エッジ制御指示管理更新内容
   */
  private void updateIfEdgeManage(String facilityCd, IfedgeFixedResult ifedgeFixedResult) {

    // 対象エッジの連携エッジ制御指示管理のステータス更新
    MntIfEdgeManage mntIfEdgeManage = mntIfEdgeManageDao.selectByFacilityCdAndStatus(facilityCd, ResponseStatus.RUNNING.getStatus());
    if (mntIfEdgeManage != null) {
      mntIfEdgeManage.setResponseStatus(ResponseStatus.ERROR.getStatus());
      EdgeResult edgeResult = mntIfEdgeManage.getEdgeResult();
      if (edgeResult == null) {
        edgeResult = new EdgeResult();
        edgeResult.setSystem(IfEdgeConstants.IF_EDGE_CONNECT_SYSTEM_NAME);
        edgeResult.setFacilityCd(facilityCd);
        edgeResult.setStatus(ResultStatus.RESULT.getReceiveName());
        edgeResult.setResult(new MntIfEdgeManage.InnerEdgeResult());
        mntIfEdgeManage.setEdgeResult(edgeResult);
      }
      mntIfEdgeManage.getEdgeResult().getResult().setStatus(ifedgeFixedResult.getStatus());
      mntIfEdgeManage.getEdgeResult().getResult().setMessage(ifedgeFixedResult.getMessage());
      mntIfEdgeManageDao.update(mntIfEdgeManage);
    }
  }

  /**
   * 施設コードをキーに連携エッジクライアント接続状態削除
   *
   * @param facilityCd 施設コード
   */
  // mod 6912 エッジの連携処理を停止しても稼働ビューア画面では正常と表示される 吉 start
  // private void deleteConnectByFacilityCd(String facilityCd) {
  public void deleteConnectByFacilityCd(String facilityCd) {
    // mod 6912 エッジの連携処理を停止しても稼働ビューア画面では正常と表示される 吉 end
    // 連携エッジクライアント接続状態の削除
    MntIfEdgeClientConnect mntIfEdgeClientConnect = mntIfEdgeClientConnectDao.selectByFacilityCd(facilityCd);
    if (mntIfEdgeClientConnect != null) {
      mntIfEdgeClientConnectDao.delete(mntIfEdgeClientConnect);
    }
  }

  // 連携負荷分散対応 20230714 add start
  public void deleteConnectByFacilityCdAndifEdgeType(String facilityCd, int ifEdgeType) {
    // mod 6912 エッジの連携処理を停止しても稼働ビューア画面では正常と表示される 吉 end
    // 連携エッジクライアント接続状態の削除
//    List<MntIfEdgeClientConnect> mntIfEdgeClientConnects = mntIfEdgeClientConnectDao.selectListByIfEdgeType(facilityCd , ifEdgeType);
//    if (mntIfEdgeClientConnects != null || mntIfEdgeClientConnects.size()>0 ) {
    mntIfEdgeClientConnectDao.deleteByIfEdgeType(facilityCd, ifEdgeType);
//    }
  }
  // 連携負荷分散対応 20230714 add end

  // add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 start
  //#10453 mod 死活監視が動作していない 2024-04-30 卓 start
  public void updateIfEdgeHealthmon(String facilityCd, String edgeStates, String clientState,Integer ifEdgeType) {
// add 2023-02-22 bug #6912 エッジの連携処理を停止しても稼働ビューア画面では正常と表示される 孫 start
    updateIfEdgeHealthmonForInterval(facilityCd, edgeStates, clientState, null, null,ifEdgeType);
  }
  //#10453 mod 死活監視が動作していない 2024-04-30 卓 end

  public void updateIfEdgeHealthmonForInterval(String facilityCd, String edgeStates, String clientState,
                                               String journalInterval, String mainInterval,Integer ifEdgeType) {
// add 2023-02-22 bug #6912 エッジの連携処理を停止しても稼働ビューア画面では正常と表示される 孫 end
    List<MntIfEdgeHealthmon> mntIfEdgeHealthmonList = mntIfEdgeHealthmonDao.selectByFacilityCd(facilityCd);
// mod 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//    MntIfEdgeHealthmon mntIfEdgeHealthmon = new MntIfEdgeHealthmon();
//    if(null != mntIfEdgeHealthmonList && mntIfEdgeHealthmonList.size()>0){
//      mntIfEdgeHealthmon=mntIfEdgeHealthmonList.get(0);
//    }
    if (mntIfEdgeHealthmonList == null || (mntIfEdgeHealthmonList != null && mntIfEdgeHealthmonList.size() == 0)) {
      return;
    }

    for (MntIfEdgeHealthmon mntIfEdgeHealthmon : mntIfEdgeHealthmonList) {
// mod 2023-02-22 bug #6912 エッジの連携処理を停止しても稼働ビューア画面では正常と表示される 孫 start
//      updateIfEdgeHealthmonByCoopVersion(edgeStates, clientState, mntIfEdgeHealthmon);
      updateIfEdgeHealthmonByCoopVersion(edgeStates, clientState, mntIfEdgeHealthmon, journalInterval, mainInterval,ifEdgeType);
// mod 2023-02-22 bug #6912 エッジの連携処理を停止しても稼働ビューア画面では正常と表示される 孫 end
    }
  }

  // mod 2023-02-22 bug #6912 エッジの連携処理を停止しても稼働ビューア画面では正常と表示される 孫 start
//  private void updateIfEdgeHealthmonByCoopVersion(String edgeStates, String clientState,
//                                                MntIfEdgeHealthmon mntIfEdgeHealthmon) {
  private void updateIfEdgeHealthmonByCoopVersion(String edgeStates, String clientState,
                                                  MntIfEdgeHealthmon mntIfEdgeHealthmon, String journalInterval, String mainInterval,Integer ifEdgeType) {
// mod 2023-02-22 bug #6912 エッジの連携処理を停止しても稼働ビューア画面では正常と表示される 孫 end
// mod 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
    EventLogMessage eventLogMessage = new EventLogMessage();
    try {
      //#9918 mod updateHealthmonFacilityConnの空ポインタ ljg start
      if(mntIfEdgeHealthmon.getHealthmonFacilityConn() == null){
        mntIfEdgeHealthmon.setHealthmonFacilityConn("{}");
      }
      /* modify by chamaojia 2024-10-11 [11140] 【Healthmon_facility_conn】 JSON structure change --start */
      Map<String, Map<String, HealthmonFacility>> updateHealthmonFacilityConn = new HashMap<>();
      //#9918 mod updateHealthmonFacilityConnの空ポインタ ljg end
      //#10453 mod 死活監視が動作していない 2024-04-30 卓 start
      HealthmonFacility healthmonFacility = new HealthmonFacility();
      healthmonFacility.setStatus(edgeStates);
      healthmonFacility.setMoniTime(new Timestamp(clockWrapper.getClockMillis()));
      updateHealthmonFacilityConn.put("edge", new HashMap<>());
      if (ifEdgeType.equals(IfEdgeConstants.IF_EDGE_TYPE_MAINTENANCE)) {
        updateHealthmonFacilityConn.get("edge").put(CoreConstant.HealthmonFctJson.MANAGER_HEADER, healthmonFacility);
      }else if (ifEdgeType.equals(IfEdgeConstants.IF_EDGE_TYPE_JOURNAL)) {
        updateHealthmonFacilityConn.get("edge").put(CoreConstant.HealthmonFctJson.BUSINESS_HEADER, healthmonFacility);
      }else {
        updateHealthmonFacilityConn.get("edge").put(CoreConstant.HealthmonFctJson.MANAGER_HEADER, healthmonFacility);
        updateHealthmonFacilityConn.get("edge").put(CoreConstant.HealthmonFctJson.BUSINESS_HEADER, healthmonFacility);
      }
      /* modify by chamaojia 2024-10-11 [11140] 【Healthmon_facility_conn】 JSON structure change --end */
      //#10453 mod 死活監視が動作していない 2024-04-30 卓 end

      /* delete by chamaojia 2024-10-11 [11140] delete incorrect handling logic --start */
      //#10453 mod 死活監視が動作していない 2024-07-01 卓 start
//      HealthmonFacility healthmonFacilityAccept = new HealthmonFacility();
//      //#9918 add  ljg start
//      if(updateHealthmonFacilityConn.get("accept") !=null){
//        healthmonFacilityAccept = updateHealthmonFacilityConn.get("accept");
//      }
//      //#9918 add  ljg end
//      healthmonFacilityAccept.setStatus(edgeStates);
//      healthmonFacilityAccept.setMoniTime(new Timestamp(clockWrapper.getClockMillis()));
//      updateHealthmonFacilityConn.put("accept", healthmonFacilityAccept);
      // mod 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 start
//      Set set = updateHealthmonFacilityConn.keySet();
//      Iterator iterator = set.iterator();
//      while (iterator.hasNext()){
//        Object next = iterator.next();
//        if(!"accept".equals(next) && !"edge".equals(next)){
//          HealthmonFacility healthmonFacilityNoEdge = updateHealthmonFacilityConn.get(next.toString());
//          healthmonFacilityNoEdge.setStatus(edgeStates);
//          updateHealthmonFacilityConn.put(next.toString(),healthmonFacilityNoEdge);
//        }
//      }
      //#10453 del 死活監視が動作していない 2024-05-13 卓 end
//      if (edgeStates != "01") {
//        Set set = updateHealthmonFacilityConn.keySet();
//        Iterator iterator = set.iterator();
//        while (iterator.hasNext()) {
//          Object next = iterator.next();
//          if (!"accept".equals(next) && !"edge".equals(next)) {
//            HealthmonFacility healthmonFacilityNoEdge = updateHealthmonFacilityConn.get(next.toString());
//            healthmonFacilityNoEdge.setStatus(edgeStates);
//            healthmonFacilityNoEdge.setMoniTime(new Timestamp(clockWrapper.getClockMillis()));
//            updateHealthmonFacilityConn.put(next.toString(), healthmonFacilityNoEdge);
//          }
//        }
//      }
      //#10453 del 死活監視が動作していない 2024-05-13 卓 end
//      HealthmonFacility updatedHealthmonFacilityEdge = updateHealthmonFacilityConn.get("edge");
//      String updatedEdgeStatus = updatedHealthmonFacilityEdge.getStatus();
//      if (updatedEdgeStatus.equals("01")) {
//        if (mntIfEdgeHealthmon.getHealthmonFacilityConn() == null) {
//          mntIfEdgeHealthmon.setHealthmonFacilityConn("{}");
//        }
//        Map<String, HealthmonFacility> healthEdgeCoopCdMap = ObjectMapperUtil.readTypeReference(mntIfEdgeHealthmon.getHealthmonFacilityConn(),
//          new TypeReference<Map<String, HealthmonFacility>>() {
//          });
//        HealthmonFacility healthmonFacilityEdge = healthEdgeCoopCdMap.get("edge");
//        String originalEdgeStatus = null;
//        if (healthmonFacilityEdge != null) {
//          originalEdgeStatus = healthmonFacilityEdge.getStatus();
//        }
//        if (originalEdgeStatus == null || !originalEdgeStatus.equals("01")) {
//          Set set = healthEdgeCoopCdMap.keySet();
//          Iterator iterator = set.iterator();
//          while (iterator.hasNext()) {
//            String coopCd = iterator.next().toString();
//            if (!Arrays.asList("edge", "edge_m").contains(coopCd)) {
//              HealthmonFacility healthmonFacilityEdgeCoop = updateHealthmonFacilityConn.get(coopCd);
//              healthmonFacilityEdgeCoop.setStatus(edgeStates);
//              healthmonFacilityEdgeCoop.setMoniTime(new Timestamp(clockWrapper.getClockMillis()));
//              updateHealthmonFacilityConn.put(coopCd, healthmonFacilityEdgeCoop);
//            }
//          }
//        }
//      }
      //#10453 mod 死活監視が動作していない 2024-07-01 卓 end
      /* delete by chamaojia 2024-10-11 [11140] delete incorrect handling logic --end */
      // mod 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 end
      HealthmonServer updateHealthmonServerConn = new HealthmonServer();
// add 2023-02-22 bug #6912 エッジの連携処理を停止しても稼働ビューア画面では正常と表示される 孫 start
      String serverConnString = mntIfEdgeHealthmon.getHealthmonServerConn();
      if (!StringUtils.isEmpty(serverConnString)) {
        updateHealthmonServerConn = ObjectMapperUtil.read(serverConnString, HealthmonServer.class);
      }
      // 接続状態チェック間隔(送信)を設定する
      if (org.apache.commons.lang3.StringUtils.isNumeric(journalInterval)) {
        updateHealthmonServerConn.setJournalInterval(journalInterval);
      }
      // 接続状態チェック間隔(メンテンス)を設定する
      if (org.apache.commons.lang3.StringUtils.isNumeric(mainInterval)) {
        updateHealthmonServerConn.setMainInterval(mainInterval);
      }
// add 2023-02-22 bug #6912 エッジの連携処理を停止しても稼働ビューア画面では正常と表示される 孫 end
      updateHealthmonServerConn.setStatus(clientState);
      updateHealthmonServerConn.setMoniTime(new Timestamp(clockWrapper.getClockMillis()));
      mntIfEdgeHealthmon.setHealthmonServerConn(null);
      if (updateHealthmonServerConn != null) {
        String healthmonServerConnStr = ObjectMapperUtil.write(updateHealthmonServerConn);
        mntIfEdgeHealthmon.setHealthmonServerConn(healthmonServerConnStr);
      }
      // 値がない場合は、更新対象にならないように null をセットする
      mntIfEdgeHealthmon.setHealthmonFacilityConn(null);
      if (!updateHealthmonFacilityConn.isEmpty()) {
        String healthmonFacilityConnStr = ObjectMapperUtil.write(updateHealthmonFacilityConn);
        mntIfEdgeHealthmon.setHealthmonFacilityConn(healthmonFacilityConnStr);
      }
    } catch (IOException e) {
      eventLogMessage.setLogMessage("エッジステータスの更新用データ作成処理で、データをJSONとして変換する際にエラーが発生しました。");
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
      logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      throw new NtssException("JSONとしてのデータ変換でエラーが発生しました。", e);
    }
    //#9490  mod 電子カルテアイコンの連携先情報について 2024-07-19 卓 start
    mntIfEdgeHealthmonDao.updateHealthmonFacilityConn(mntIfEdgeHealthmon);
    //#9490  mod 電子カルテアイコンの連携先情報について 2024-07-19 卓 end
  }

  /* add by chamaojia 2024-10-11 [11140] add method --start */

  /**
   * insert or update mnt_if_edge_healthmon
   * need to synchronize mst_coop_facility
   * @param facilityCd
   */
  public void insertOrUpdateIfEdgeHealthmonToFc(String facilityCd) {
    EventLogMessage eventLogMessage = new EventLogMessage();

    try {
      MntIfEdgeHealthmon mntIfEdgeHealthmon = mntIfEdgeHealthmonDao
              .selectByFacilityAndIfEdgeNo(facilityCd, NtssCoopApiConstants.IF_EDGE_NO_DEFAULT);
      if (mntIfEdgeHealthmon == null) {  // insert

        Timestamp now = new Timestamp(clockWrapper.getClockMillis());
        MntIfEdgeHealthmon ifEdgeHToSave = new MntIfEdgeHealthmon();
        ifEdgeHToSave.setFacilityCd(facilityCd);
        ifEdgeHToSave.setIfEdgeNo(NtssCoopApiConstants.IF_EDGE_NO_DEFAULT);
        ifEdgeHToSave.setUpDate(now);
        ifEdgeHToSave.setRegDate(now);

        Map<String, Map<String, HealthmonFacility>> hFacilityCMap = getCoopFacilitySettingToHFMap(facilityCd);
        if (!hFacilityCMap.isEmpty()) {
          ifEdgeHToSave.setHealthmonFacilityConn(ObjectMapperUtil.write(hFacilityCMap));
        }

        mntIfEdgeHealthmonDao.insert(ifEdgeHToSave);
      } else {  // update

        Map<String, Map<String, HealthmonFacility>> oldHealthmonFacilityConn
                = ObjectMapperUtil.readTypeReference(mntIfEdgeHealthmon.getHealthmonFacilityConn()
                , new TypeReference<>() {});
        // 存在しない coopCd を追加する
        List<MstCoopFacility.CoopOrdCd> coopVersionAndCoopCdList = getCoopVersionAndCoopCdAllByFacilityCd(facilityCd);
        Map<String, Map<String, HealthmonFacility>> addHFCItemMap = new HashMap<>();
        for (MstCoopFacility.CoopOrdCd coopOrdCd : coopVersionAndCoopCdList) {
          String coopVersion = coopOrdCd.getCoopVersion();
          String coopCd = coopOrdCd.getCoopCd();
          Map<String, HealthmonFacility> coopCdMap = oldHealthmonFacilityConn.get(coopVersion);
          if (coopCdMap == null || coopCdMap.isEmpty() || !coopCdMap.containsKey(coopCd)) {
            if (!addHFCItemMap.containsKey(coopVersion)) {
              addHFCItemMap.put(coopVersion, new HashMap<>());
            }

            HealthmonFacility healthmonFacilityEdgeCoop = new HealthmonFacility();
            healthmonFacilityEdgeCoop.setStatus("F0");
            healthmonFacilityEdgeCoop.setMoniTime(new Timestamp(clockWrapper.getClockMillis()));
            addHFCItemMap.get(coopVersion).put(coopCd, healthmonFacilityEdgeCoop);
          }
        }

        if (!addHFCItemMap.isEmpty()) {
          mntIfEdgeHealthmon.setUpDate(new Timestamp(clockWrapper.getClockMillis()));
          //
          mntIfEdgeHealthmon.setHealthmonServerConn(null);
          mntIfEdgeHealthmon.setHealthmonFacilityConn(ObjectMapperUtil.write(addHFCItemMap));
          mntIfEdgeHealthmonDao.updateHealthmonFacilityConn(mntIfEdgeHealthmon);
        }


        // coopCd を削除する
        List<String> delItemStrList = new ArrayList<>();
        for (String coopVersion : oldHealthmonFacilityConn.keySet()) {
          if ("edge".equals(coopVersion)) {
            continue;
          }
          Map<String, HealthmonFacility> healthEdgeCoopCdMap = oldHealthmonFacilityConn.get(coopVersion);
          List<String> delCoopCdItemStrList = new ArrayList<>();
          for (String coopCd : healthEdgeCoopCdMap.keySet()) {
            List<MstCoopFacility.CoopOrdCd> coopOrdCdList = coopVersionAndCoopCdList.stream().filter(
                    c -> c.getCoopVersion().equals(coopVersion) && c.getCoopCd().equals(coopCd))
                    .collect(Collectors.toList());
            if (coopOrdCdList == null || coopOrdCdList.size() == 0) {
              delCoopCdItemStrList.add("{\"" + coopVersion + "\",\"" + coopCd + "\"}" );
            }
          }

          if (healthEdgeCoopCdMap.size() == delCoopCdItemStrList.size()) {
            delItemStrList.add("{\"" + coopVersion + "\"}" );
          } else {
            delItemStrList.addAll(delCoopCdItemStrList);
          }
        }
        if (!delItemStrList.isEmpty()) {
          mntIfEdgeHealthmonDao.delHealthmonFacilityConnItemToCoopCd(mntIfEdgeHealthmon.getCtlNo()
                  , delItemStrList);
        }
      }
    } catch (IOException e) {
      eventLogMessage.setLogMessage("JSONとしてのデータ変換でエラーが発生しました。");
      eventLogMessage.setInvokeClass(this.getClass().getName());
      logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      throw new NtssException("JSONとしてのデータ変換でエラーが発生しました。", e);
    }

  }

  /**
   * processing data for querying mst_coop_facility
   *
   * @param facilityCd
   * @return  {coopVersion : {coopCd : HealthmonFacility}}
   */
  public Map<String, Map<String, HealthmonFacility>> getCoopFacilitySettingToHFMap(String facilityCd) {
    Map<String, Map<String, HealthmonFacility>> healthmonFacilityConnMap = new HashMap<>();
    List<MstCoopFacility.CoopOrdCd> coopVersionAndCoopCdList = getCoopVersionAndCoopCdAllByFacilityCd(facilityCd);

    if (!coopVersionAndCoopCdList.isEmpty()) {
      Map<String, List<String>> coopVersionMap = coopVersionAndCoopCdList.stream().collect(
              Collectors.groupingBy(MstCoopFacility.CoopOrdCd::getCoopVersion
                      , Collectors.mapping(MstCoopFacility.CoopOrdCd::getCoopCd, Collectors.toList())));

      HealthmonFacility healthmonFacilityEdgeCoop = new HealthmonFacility();
      healthmonFacilityEdgeCoop.setStatus("F0");
      healthmonFacilityEdgeCoop.setMoniTime(new Timestamp(clockWrapper.getClockMillis()));
      for(String coopVersionStr : coopVersionMap.keySet()) {
        healthmonFacilityConnMap.put(coopVersionStr, new HashMap<>());
        for (String coopCdStr : coopVersionMap.get(coopVersionStr)) {
          healthmonFacilityConnMap.get(coopVersionStr).put(coopCdStr, healthmonFacilityEdgeCoop);
        }
      }
    }

    return healthmonFacilityConnMap;
  }

  /**
   * query mst_cop_facility and retrieve the information of the opened services
   * @param facilityCd
   * @return
   */
  private List<MstCoopFacility.CoopOrdCd> getCoopVersionAndCoopCdAllByFacilityCd(String facilityCd) {
    //  coopCd のデフォルト値を設定する
    List<MstCoopFacility.CoopOrdCd> coopVersionAndCoopCdList = new ArrayList<>();
    MstCoopFacility mstCoopFacility = mstCoopFacilityDao.select(facilityCd);
    if (mstCoopFacility != null) {
      MstCoopFacility.CommonSetting commonSetting = mstCoopFacility.getCommonSetting();
      if (commonSetting != null) {
        MstCoopFacility.CoopOpeCd coopOpeCd = commonSetting.getCoopOpeCd();
        List<MstCoopFacility.CoopOrdCd> coopOrdCds = commonSetting.getCoopOrdCds();
        if (coopOpeCd != null) {
          // オペコード
          List<MstCoopFacility.OpeCdStatus> opeCdSends = coopOpeCd.getOpeCdSends();
          if (opeCdSends != null && opeCdSends.size() != 0) {
            // オペコードをループ
            for (MstCoopFacility.OpeCdStatus opeStatus : opeCdSends) {
              if (!"on".equals(opeStatus.getStatus())) {
                continue;
              }
              // 「on:有効」の場合
              for (MstCoopFacility.CoopOrdCd coopOrdCd : coopOrdCds) {
                List<String> opeCds = coopOrdCd.getOpeCds();
                if (opeCds != null && opeCds.size() != 0 && opeCds.contains(opeStatus.getOpeCd())) {
                  if (!StringUtils.isEmpty(coopOrdCd.getCoopCd())) {
                    long existsCount =
                            coopVersionAndCoopCdList.stream().filter(c -> c.getCoopCd().equals(coopOrdCd.getCoopCd())
                                    && c.getCoopVersion().equals(coopOrdCd.getCoopVersion())).count();
                    if (existsCount == 0) {
                      coopVersionAndCoopCdList.add(coopOrdCd);
                    }
                  }
                }
              }
            }
          }
        }
      }
    }

    return coopVersionAndCoopCdList;
  }
  /* add by chamaojia 2024-10-11 [11140] add method --end */

  public int clientSessionCountByFacilityCd(String facilityCd) {
    int i = 0;
    for (WSClientInfo clientInfo : clientList) {
      if (clientInfo.getFacilityCd().equals(facilityCd)) {
        i++;
      }
    }
    return i;
  }
  // add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 end

  /* add by chamaojia 2024-06-24 [10574] communication security related additions --start */
  /* upd by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
  private void startTimer() {
    synchronized (wsConnectTimerLock) {
      if (scheduledExecutorService == null || scheduledExecutorService.isShutdown()) {
        scheduledExecutorService = Executors.newSingleThreadScheduledExecutor();
        scheduledExecutorService.scheduleAtFixedRate(
                () -> checkWSConnect(), 0, 1, TimeUnit.SECONDS);
      }
    }
  }

  /**
   * Check if a valid message has been received within 5 seconds.
   * If not received, close the connection
   */
  private void checkWSConnect() {
    LocalDateTime nowLdt = LocalDateTime.now();
    for (String key : connectedWSMap.keySet()) {
      WSClientInfo info = connectedWSMap.get(key);
      if (info == null) {
        continue;
      }
      LocalDateTime connectTime = info.getConnectTime();
      if (connectTime.plusSeconds(5).compareTo(nowLdt) <= 0) {
        try {
          info.getSession().close();
        } catch (IOException e) {
//          e.printStackTrace();
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage("WS close IOException");
          logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        }
        connectedWSMap.remove(key);
      }
    }
  }

  private void stopTimer() {
    ScheduledExecutorService toShutdown = null;
    synchronized (wsConnectTimerLock) {
      if (connectedWSMap.isEmpty()
              && scheduledExecutorService != null && !scheduledExecutorService.isShutdown()) {
        toShutdown = scheduledExecutorService;
        scheduledExecutorService = null;
      }
    }
    if (toShutdown != null) {
      toShutdown.shutdownNow();
    }
  }
  /* upd by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */
  /* add by chamaojia 2024-06-24 [10574] communication security related additions --end */
}
