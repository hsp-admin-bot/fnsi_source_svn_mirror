package jp.co.nikkiso.ntss.client_comm.web.websocket;

import java.net.URI;
import java.net.URISyntaxException;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Base64;
import java.util.List;
import java.util.Map.Entry;
import java.util.Set;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CopyOnWriteArrayList;

import javax.annotation.PreDestroy;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.http.RequestEntity;
import org.springframework.http.ResponseEntity;
import org.springframework.http.client.HttpComponentsClientHttpRequestFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClientResponseException;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;

import jp.co.nikkiso.ntss.core.entity.MntClientConnect;
import jp.co.nikkiso.ntss.client_comm.service.LogService;
import jp.co.nikkiso.ntss.client_comm.service.MntClientConnectService;

import jp.co.nikkiso.ntss.core.entity.MntDeviceEdgeState;
import jp.co.nikkiso.ntss.client_comm.service.MntDeviceEdgeStateService;

import jp.co.nikkiso.ntss.core.constant.CoreConstant.AliveMoniStatus;

import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.entity.MstFacility;
import jp.co.nikkiso.ntss.core.entity.MstWeight;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.client_comm.service.MstFacilityService;
import jp.co.nikkiso.ntss.client_comm.service.MstWeightService;
import jp.co.nikkiso.ntss.client_comm.web.dto.SendClientMessageDTO;
import jp.co.nikkiso.ntss.core.entity.MntWebsocketCertification;
import jp.co.nikkiso.ntss.core.entity.MntWeightState;
import jp.co.nikkiso.ntss.client_comm.service.MntWebsocketCertificationService;
import jp.co.nikkiso.ntss.client_comm.service.MntWeightStateService;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

/**
 * クライアント種別
 */
enum Client_Classes {
  /**
   * その他
   */
  OTHER(""),
  /**
   * ブラウザ
   */
  BROWSER("BROWSER"),
  /**
   * デバイスエッジ
   */
  DEVICE_EDGE("EDGE"),
  /**
   * 体重計サービス
   */
  WEIGHT_SCALE("WSCALE"),
  /**
   * 印刷サービス
   */
  PRINT_SERVER("PRINTSV");

  private String name;

  private Client_Classes(String name) {
    this.name = name;
  }

  public String getName() {
    return this.name;
  }
}

/**
 * クライアント切断検出情報
 *
 */
class DisconnectionClient {

  /**
   * クライアント種別
   */
  public Client_Classes clientClass;
  /**
   * 最終更新日時
   */
  public Timestamp lastUpdate;

  /**
   * 切断検出日時
   */
  public LocalDateTime disconnDetected;


  /**
   * コンストラクタ
   * @
   * @param lastUpdate 最終更新日時
   */
  public DisconnectionClient( Client_Classes clientClass, Timestamp lastUpdate )
  {
    this.clientClass = clientClass;

    this.lastUpdate = lastUpdate;

    this.disconnDetected = LocalDateTime.now();
  }
}

/**
 * 接続クライアント情報
 *
 */
class WSClientInfo {

  /**
   * クライアント種別
   */
  public Client_Classes clientClass;

  /**
   * WebSocketセッション情報
   */
  public WebSocketSession session;

  /**
   * 端末固有ID情報
   */
  public String terminalUniqueStr;

  /**
   * 接続開始日時
   */
  public LocalDateTime connected;

  /**
   * 最終受信日時
   */
  public LocalDateTime lastRecieved;


  /**
   * コンストラクタ
   * @param session WebSocketセッション情報
   * @param clientClass クライアント種別
   */
  public WSClientInfo( WebSocketSession session, Client_Classes clientClass, String terminalUniqueStr )
  {
    this.clientClass = clientClass;

    this.session = session;

    this.terminalUniqueStr = terminalUniqueStr;

    this.connected = this.lastRecieved = LocalDateTime.now();
  }

  /**
   * 最終受信日時更新
   */
  public void updateRecieve()
  {
    this.lastRecieved = LocalDateTime.now();
  }
}


@Component
public class SessionManager implements WebSocketSessionControl {

  private RestTemplate rt;

  @Autowired
  private LogService logService;

  /**
   * ヘッダーパラメータ(セキュリティ項目)
   */
  private final String SecurityHeaderParam = "SSECCAYEK";
  /**
   * セキュリティキー
   */
  private final String SecurityKey = "NTSS-NKK-ESM-TDC-YSK";


  @Autowired
  private MntClientConnectService mntClientConnectService;

  @Autowired
  private MntDeviceEdgeStateService mntDeviceEdgeStateService;

  @Autowired
  private MstFacilityService mstFacilityService;

  @Autowired
  private MntWebsocketCertificationService mntWebsocketCertificationService;

  @Autowired
  private MstWeightService mstWeightService;

  @Autowired
  private MntWeightStateService mntWeightStateService;


  /**
   * 初回IPアドレス削除フラグ
   */
  private boolean isIPDeleted = false;


  /**
   * 自端末情報[IPアドレス]
   */
  private String localIP;

  /**
   * WSクライアント死活判定間隔[分]
   */
  private int aliveInterval;

  /**
   * アプリケーションが稼働しているサーバ種別[0：DeviceSrv/1：WebAppSrv]
   */
  private int serverType;

  /**
   * URI先頭部[http/https]
   */
  private String requestHTTP;

  /**
   * WebAppSrv用メッセージ通知URIAPI部[ポート番号/API]
   */
  private String postMsgAPI_WebAppSrv;

  /**
   * DeviceSrv用メッセージ通知URIAPI部[ポート番号/API]
   */
  private String postMsgAPI_DeviceSrv;


  /**
   * APIの呼び出し先ホスト名
   */
  private String hostName;

  /**
   * デバイスエッジ死活監視の通知APIを呼び出すためのAPI部分[ポート番号/API]
   */
  private String postDEStatusAPI;

  /**
   * デバイスエッジ死活監視の通知APIを呼び出すための遅延時間[分]
   */
  private int postDEStatusDilay;


  /**
   * セッションリスト
   */
  // mod #11524 【たくしん会】H13体重計の患者カード読み取り、体重値の連携、レシート印刷が動作しない。 by shiyw 20250328 start
  // private ArrayList<WebSocketSession> sessions = new ArrayList<>();
  private CopyOnWriteArrayList<WebSocketSession> sessions = new CopyOnWriteArrayList<>();
  // mod #11524 【たくしん会】H13体重計の患者カード読み取り、体重値の連携、レシート印刷が動作しない。 by shiyw 20250328 end
  /**
   * クライアントリスト
   */
  // mod #11524 【たくしん会】H13体重計の患者カード読み取り、体重値の連携、レシート印刷が動作しない。 by shiyw 20250328 start
  // private HashMap<String, WSClientInfo> clients = new HashMap<>();
  private ConcurrentHashMap<String, WSClientInfo> clients = new ConcurrentHashMap<>();
  // mod #11524 【たくしん会】H13体重計の患者カード読み取り、体重値の連携、レシート印刷が動作しない。 by shiyw 20250328 end

  /**
   * 通信異常デバイスエッジクライアントリスト
   */
  // mod #11524 【たくしん会】H13体重計の患者カード読み取り、体重値の連携、レシート印刷が動作しない。 by shiyw 20250328 start
  // private HashMap<String, DisconnectionClient> commErrorClients = new HashMap<>();
  private ConcurrentHashMap<String, DisconnectionClient> commErrorClients = new ConcurrentHashMap<>();
  // mod #11524 【たくしん会】H13体重計の患者カード読み取り、体重値の連携、レシート印刷が動作しない。 by shiyw 20250328 end

  /**
   * コンストラクタ
   */
  public SessionManager() {
    //
    HttpComponentsClientHttpRequestFactory clientHttpRequestFactory = new HttpComponentsClientHttpRequestFactory();
    clientHttpRequestFactory.setReadTimeout( 10 * 1000 );
    clientHttpRequestFactory.setConnectTimeout( 5 * 1000 );
    rt = new RestTemplate(clientHttpRequestFactory);
  }

  /**
   * 自端末IPアドレス文字列設定
   * @param ip
   */
  public void setLocalIp(String ip) {
    this.localIP = ip;
  }

  /**
   * 自端末IPアドレス文字列取得
   * @return IPアドレス文字列
   */
  public String getLocalIp() {
    return this.localIP;
  }

  /**
   * WSクライアント死活判定間隔用設定
   * @param aliveInterval
   */
  public void setAliveInterval( int aliveInterval ) {
    this.aliveInterval = aliveInterval;
  }

  /**
   * アプリケーションが稼働しているサーバ種別[0：DeviceSrv/1：WebAppSrv]
   * @param serverType
   */
  public void setServerType( int serverType ) {
    this.serverType = serverType;
  }

  /**
   * URI先頭部設定
   * @param requestURI
   */
  public void setRequestHTTP(String requestHTTP) {
    this.requestHTTP = requestHTTP;
  }

  /**
   * WebAppSrver用メッセージ通知API部設定
   * @param requestURIAPI
   */
  public void setPostMsgAPI_WebAppSrv(String postMsgAPI) {
    this.postMsgAPI_WebAppSrv = postMsgAPI;
  }

  /**
   * DeviceServer用メッセージ通知API部設定
   * @param requestURIAPI
   */
  public void setPostMsgAPI_DeviceSrv(String postMsgAPI) {
    this.postMsgAPI_DeviceSrv = postMsgAPI;
  }

  /**
   * EC2APIの呼び出し先ホスト名設定
   * @param hostName
   */
  public void setHostName(String hostName ) {
    this.hostName = hostName;
  }

  /**
   * デバイスエッジ死活監視通知用API設定
   * @param postDEStatusAPI
   */
  public void setPostDEStatusAPI(String postDEStatusAPI ) {
    this.postDEStatusAPI = postDEStatusAPI;
  }

  /**
   * デバイスエッジ死活監視の通知APIを呼び出すための遅延時間設定
   * @param postDEStatusDilay
   */
  public void setPostDEStatusDilay( int postDEStatusDilay ) {
    this.postDEStatusDilay = postDEStatusDilay;
  }


  /**
   * 初回IPアドレスをDBから削除したかどうか
   * @return
   */
  public boolean deleteIP() {

    try {
      // IPアドレスをDBから削除したかどうかを判定
      if( this.isIPDeleted == false ) {
        // 未削除の場合

        // WebSocket接続管理テーブルから同じIPを持つ情報を削除する
        mntClientConnectService.deleteByIp(this.getLocalIp());

        // 初回処理完了
        this.isIPDeleted = true;
      }
    }
    catch( Exception e ) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    }

    return this.isIPDeleted;
  }

  /**
   * メッセージ通知用URI作成
   * @param ip
   * @return
   */
  public String makePostMsgURI(String ip, int serverType) {
    //String uri = this.requestHTTP + "://" + ip + this.postMsgAPI;
    String uri = this.requestHTTP + "://" + ip;
    if( serverType == 1 ) {
      // WebAppServer用
      uri += this.postMsgAPI_WebAppSrv;

    } else {
      // DeviceServer用
      uri += this.postMsgAPI_DeviceSrv;

    }
    //log.info("makeURI : " + uri );

    return  uri;
  }

  /**
   * デバイスエッジ死活監視通知用URI作成
   * @param ip
   * @return
   */
  public String makePostDEStatusURI() {
    String uri = this.requestHTTP + "://" + this.hostName + this.postDEStatusAPI;
    //log.info("makeURI : " + uri );

    return  uri;
  }


  /**
   * セキュリティヘッダーパラメータ名を返す
   * @return
   */
  public String getSecurityHeaderParamName() {
    return SecurityHeaderParam;
  }

  /**
   * セキュリティキーを返す
   * @return
   */
  public String getSecurityKey() {
    return SecurityKey;
  }

  /**
   * クライアントキーから構成情報を取得する
   * @param key クライアントキー({施設コード[6桁]}{識別子} or {施設コード[6桁]}{識別子}_{セッション番号})
   * @return構成情報配列 [0：施設コード、1:識別子]
   */
  public List<String> getClientKeyParams( String key ) {
    List<String> ret = new ArrayList<>();

    // セッション番号の除去
    int idx = key.indexOf("_");
    if( 0 <= idx ) {
      key = key.substring( 0, idx );
    }

    // 施設コード、識別子の取得
    if( 6 < key.length() ) {
      ret.add( key.substring(0,  6));
      ret.add( key.substring(6));
    }

    return ret;
  }


  /**
   * クライアントリストを返す
   * @return
   */
  public String getClients() {

    ArrayList<String> list = new ArrayList<>();

    this.clients.forEach((key, cl) -> {
      String info = "{ \"Connect DateTime\":\"" + cl.connected.toString() + "\", \"Last Recieved DateTime\":\"" + cl.lastRecieved.toString() + "\", \"IP\":\"" + cl.session.getRemoteAddress().toString() + "\", \"Session ID\":\"" + cl.session.getId() + "\", \"Clienct Key\":\"" +  key + "\"}";
      list.add(info);
    });
    return list.toString();
  }


  /**
   * セッションの追加
   * @param session
   */
  public void addSession(WebSocketSession session)
  {
    // 同じセッションは追加しない
    if( this.sessions.stream().noneMatch(ses -> ses.getId().equals(session.getId()))) {
      this.sessions.add(session);
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("Connect Websocket. IP = " + session.getRemoteAddress().toString() + ", Session ID = " + session.getId() + ", connecting count = " + sessions.size());
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    }
  }
  /**
   * セッションの削除
   * @param session
   */
  public void removeSession(WebSocketSession session) {
    // 指定されたセッションを削除する
    this.sessions.stream()
    .filter(ses -> ses.getId().equals(session.getId()))
    .findFirst()
    .ifPresent(ses -> this.sessions.remove(ses));    // 一致するsessionを削除

    // クライアントの一覧からセッションが一致する情報を削除する
    removeClient(session);

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("Disconnect Websocket. IP = " + session.getRemoteAddress().toString() + ", Session ID = " + session.getId() + ", connecting count = " + sessions.size());
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
  }


  /**
   * WSクライアント情報の存在チェック
   * @param session
   * @return
   */
  public WSClientInfo existWSClientInfo(WebSocketSession session) {
    WSClientInfo ret = null;

    // クライアント内に同じセッションがあるかどうか
    for( Entry<String, WSClientInfo> entry : this.clients.entrySet()) {
      if( entry.getValue().session.equals( session ) == true ) {
        ret = entry.getValue();
        break;
      }
    }

    return ret;
  }


  /**
   * 指定セッションに登録されているキー情報を取得する
   * @param session
   * @return
   */
  public String getClientKey(WebSocketSession session) {
    String ret = "";

    // 確立したクライアントの一覧からセッションが一致する情報のキー情報を取得する
    for( Entry<String, WSClientInfo> entry : this.clients.entrySet()) {
      if( entry.getValue().session.getId().equals( session.getId() ) == true ) {
        ret = entry.getKey();
        break;
      }
    }

    return ret;
  }


  /**
   * クライアント登録
   * @param key クライアントID(施設コード[6桁]+識別子)
   * @param session
   */
  public void addClient(String key, WebSocketSession session, String terminalUniqueStr) {

    EventLogMessage eventLogMessage = new EventLogMessage();
    try {
      // クライアントキー
      String clientKey = key + "_" + session.getId();

      // IPアドレス取得
      String ip = this.getLocalIp();
      // 施設コード取得
      String facilityCd = key.substring(0, 6);

      // 同じセッションがある場合はクライアント管理リストから削除する
      String delkey = this.getClientKey(session);
      if(delkey.equals("") == false) {
        eventLogMessage.setLogMessage("Already connect client. IP = " + session.getRemoteAddress().toString() + ", Session ID = " + session.getId() + ", Update Clienct Key  = " +  clientKey);
        eventLogMessage.setFacilityCd(facilityCd);
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);

        //this.removeClient(session);
        this.clients.remove(delkey);
      }

      // データベースに施設コードとIPアドレスが同じ情報があるかどうかを確認
      List<MntClientConnect> mntClientConnectList = mntClientConnectService.findByIpFacility(ip, facilityCd);
      if( mntClientConnectList.size() == 0 ) {
        // 該当情報なし

        // 接続情報を登録
        int ret = mntClientConnectService.insert(ip, facilityCd, this.serverType);
        eventLogMessage.setLogMessage("mntClientConnectService.insert ret:" + ret);
        eventLogMessage.setFacilityCd(facilityCd);
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      } else {
        // 該当情報あり

        // 接続情報を更新
        int ret = mntClientConnectService.update(ip, facilityCd);
        eventLogMessage.setLogMessage("mntClientConnectService.update ret:" + ret);
        eventLogMessage.setFacilityCd(facilityCd);
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      }

      // クライアントの種別判定
      Client_Classes clientClass = this.checkClientClass(key);
      // 確立したクライアントを追加する
      this.clients.put(clientKey, new WSClientInfo( session, clientClass, terminalUniqueStr ));
      eventLogMessage.setLogMessage("Add client. IP = " + session.getRemoteAddress().toString() + ", Session ID = " + session.getId() + ", Clienct Key  = " +  clientKey + ", connection count = " + this.clients.size());
      eventLogMessage.setFacilityCd(facilityCd);
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);

      // 通信異常クライアントに該当するクライアント識別子があるかどうか
      if( this.commErrorClients.containsKey( key ) == true ) {
        // 同じ識別子がある場合は通信異常リストから破棄

        // 施設コード保持用
        String fCd[] = {"******"};
        ArrayList<String> delList = new ArrayList<>();

        // 通信異常クライアントの一覧からセッションが一致する情報を削除する
        this.commErrorClients.forEach((key2, value) -> {
          if(key2.equals(key)) {

            // 施設コード取得
            fCd[0] = key2.substring(0, 6);

            delList.add(key2);
            eventLogMessage.setLogMessage("Remove comm error client. Clienct Key  = " +  key2);
            eventLogMessage.setFacilityCd(facilityCd);
            logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
          }
        });
        delList.forEach(key2 -> this.commErrorClients.remove(key2));
      }
    }
    catch( Exception e ) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    }
  }

  /**
   * クライアント削除
   * @param session
   */
  public void removeClient(WebSocketSession session) {

    String keyinfo = "";
    EventLogMessage eventLogMessage = new EventLogMessage();
    try {
      // サービスが起動しているIPアドレス取得
      String ip = this.getLocalIp();

      // 施設コード保持用
      String facilityCd[] = {"******"};
      ArrayList<String> delList = new ArrayList<>();

      // クライアント種別
      Client_Classes clientClass[] = { Client_Classes.OTHER};

      // 確立したクライアントの一覧からセッションが一致する情報を削除する
      this.clients.forEach((key, info) -> {
        if(info.session.getId().equals(session.getId())) {

          // 施設コード取得
          facilityCd[0] = key.substring(0, 6);
          // クライアント種別取得
          clientClass[0] = info.clientClass;

          delList.add(key);
          eventLogMessage.setLogMessage("Remove client. IP = " + session.getRemoteAddress().toString() + ", Session ID = " + session.getId() + ", Clienct Key  = " +  key);
          eventLogMessage.setFacilityCd(facilityCd[0]);
          logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        }
      });
      delList.forEach(key -> this.clients.remove(key));

      // 削除したクライアントの識別子を取得する
      if( 0 < delList.size() ) {
        keyinfo = delList.get(0);
      }

      // クライアント一覧に同じ施設コードがあるかどうかを確認
      boolean bexist = false;
      for( Entry<String, WSClientInfo> entry : this.clients.entrySet()) {
        if( entry.getKey().startsWith(facilityCd[0]) == true ) {

          // 同じ施設コードのクライアントあり
          bexist = true;

          break;
        }
      }

      // 同じ施設コードのクライアントがない場合( + 施設コード != ****** )
      if(bexist == false && facilityCd[0].equals("******") == false ) {
        // データベースからサービス稼働IPと対象施設コードの情報を削除
        mntClientConnectService.deleteByIpFacility(ip, facilityCd[0]);
      }

      // クライアント種別判定
      if( clientClass[0] != Client_Classes.OTHER ) {

        // クライアントキー(施設コード+識別子)
        String clientKey = "";
        // 施設コード
        String fcd = "";
        // 識別子
        String deviceId = "";

        // クライアントキーから施設コード、識別子を取得
        List<String> param = this.getClientKeyParams( keyinfo );
        if( 0 < param.size() ) {
          // 施設コード取得
          fcd = param.get(0);
          // 識別子取得
          deviceId = param.get(1);

          // クライアントキー作成
          clientKey = fcd + deviceId;
        }

        // 種別による処理
        switch( clientClass[0] ) {

          case OTHER:   // その他
            break;

          case BROWSER: // ブラウザ
            break;

          case DEVICE_EDGE:     // デバイスエッジ

            // デバイスエッジ番号取得
            int deno = Integer.parseInt( deviceId.substring( clientClass[0].getName().length()));

            // データベースに施設コードとデバイスエッジ番号を条件としてデバイスエッジ接続状態を取得
            List<MntDeviceEdgeState> mntDeviceEdgeStateList = mntDeviceEdgeStateService.findByFacilityDeviceEdgeNo(fcd, deno);
            if( 0 < mntDeviceEdgeStateList.size() ) {
              // 接続状態判定
              MntDeviceEdgeState info = mntDeviceEdgeStateList.get(0);
              if( info.getAliveMoniStatus().equals(AliveMoniStatus.RUNNING /*"01"*/) == true ) {
                // 接続状態が「01」であった場合

                // 通信異常クライアント一覧に追加
                this.commErrorClients.put( clientKey, new DisconnectionClient(clientClass[0], info.getLastMoniTime()));
                eventLogMessage.setLogMessage("Add comm error client. Clienct Key  = " +  clientKey);
                eventLogMessage.setFacilityCd(facilityCd[0]);
                logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
              }
            }
            break;

          case WEIGHT_SCALE:    // 体重計サービス

            // 体重計番号取得
            int scaleNo = Integer.parseInt( deviceId.substring( clientClass[0].getName().length()));

            // データベースから施設コードと体重計番号を条件として体重計情報を取得
            MstWeight weight = mstWeightService.mstWeightSelectByFacilityCdWeightNo(fcd, scaleNo);
            if( weight != null ) {
              // 体重計管理番号を条件として接続状態を取得
              MntWeightState state = mntWeightStateService.selectByScaleCd(weight.getWeightCd());
              if( state != null ) {
                // 接続状態判定
                if( state.getIsConnect().equals("1") == true ) {
                  // 接続状態が「1」であった場合

                  // 通信異常クライアント一覧に追加
                  this.commErrorClients.put( clientKey, new DisconnectionClient(clientClass[0], state.getUpDate()));
                  eventLogMessage.setLogMessage("Add comm error client. Clienct Key  = " +  clientKey);
                  eventLogMessage.setFacilityCd(facilityCd[0]);
                  logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
                }
              }
            }
            break;

          case PRINT_SERVER:    // 印刷サービス
            break;
        }
      }
    }
    catch( Exception e ) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    }
  }


  /**
   * WSクライアントの最終受信日時を更新
   * @param session
   */
  public void updateWSClientInfoLastRecieved( WebSocketSession session ) {
    WSClientInfo info = existWSClientInfo( session );
    if( info != null ) {
      info.updateRecieve();
    }
  }

  /**
   * WS認証チェック
   * @param info 接続情報{NTSS以降文字列}
   *
   * @return 認証情報({施設コード[6桁]}{任意の識別子}、空の場合は認証失敗)
   */
  public String checkWSCertification( String info ) {
    String ret = "";
    String func = "checkWSCertification";

    EventLogMessage eventLogMessage = new EventLogMessage();
    // サーバー種別、接続情報判定
    if( this.serverType == 1 || info.startsWith("@") == true ) {
      // サーバー種類が1：WebAppServer、または接続情報の先頭が{@}の場合
      func += "[1] ";

      // 識別子のフォーマット:NTSS{@}{認証コード[32桁]}{任意の識別子[1桁以上]}
      String strcd = "";
      String strid = "";
      if( 34 <= info.length() ) {
        // 認証コード
        strcd = info.substring( 1 , 33 );
        // 任意の識別子
        strid = info.substring(33);

        // 認証コードの登録チェック
        List<MntWebsocketCertification> mntWebsocketCertificationList = mntWebsocketCertificationService.findByCertification(strcd);
        if( 0 < mntWebsocketCertificationList.size() ) {
          // 該当あり

          // 現在日時と認証情報作成日付の差算出
          LocalDateTime now = LocalDateTime.now(mntWebsocketCertificationService.getTime());
          long diff = Math.abs(( mntWebsocketCertificationList.get(0).getRegDate().getTime() - Timestamp.valueOf(now).getTime()) / ( 1000 * 60 ));
          if( diff <= 1 ) {
            // 1分以内かどうか

            // 認証情報作成(｛施設コード[6桁]｝{任意の識別子})
            ret = mntWebsocketCertificationList.get(0).getFacilityCd() + strid;

          } else {
            // 1分を超えている場合

            //
            eventLogMessage.setLogMessage(func + "timeout. info = " + info);
            logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
          }
        } else {
          // 該当なし

          //
          eventLogMessage.setLogMessage(func + "no data. info = " + info);
          logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        }

        // 認証情報を削除
        mntWebsocketCertificationService.delete(strcd);

      } else {
        // 接続情報不足

        eventLogMessage.setLogMessage(func + "format error. info = " + info);
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      }

    } else {
      // サーバー種類が0：DeviceSVで接続情報の先頭が{@}以外の場合
      func += "[0] ";

      // 識別子のフォーマット:NTSS{施設コード[6桁]}{任意の識別子[1桁以上]}

      // 施設コードチェック
      String strFacilityCd = info.substring( 0, 6 );
      MstFacility facilityRec = mstFacilityService.findByFacility( strFacilityCd );
      if( facilityRec != null ) {
        // 該当施設あり

        // 認証情報作成({施設コード[6桁]}{任意の識別子[1桁以上]})
        ret = info;
      } else {
        // 該当施設なし

        eventLogMessage.setLogMessage(func + "no data error. info = " + info);
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      }
    }

    return ret;
  }


  /**
   * WSクライアント接続状態監視処理
   */
  public void checkWSClientConnectionStatus() {
    EventLogMessage eventLogMessage = new EventLogMessage();
    try {

      ArrayList<String> delList = new ArrayList<>();

      // WSクライアント分
      this.clients.forEach((key, value)->{

        // 施設コード
        String fcd = "";
        // クライアントキーから施設コードを取得
        List<String> param = this.getClientKeyParams( key );
        if( 0 < param.size() ) {
          // 施設コード取得
          fcd = param.get(0);
        }

        // 現在日時取得
        LocalDateTime now = LocalDateTime.now();
        // 指定時間算出(最終受信日時+設定時間[分])
        LocalDateTime date = value.lastRecieved.plusMinutes( this.aliveInterval );

        // 指定時間経過判定
        if( date.isBefore( now ) == true ) {
          // 指定時間の経過を検出

          //
          eventLogMessage.setLogMessage("checkWSClientConnectionStatus() Timeout[" + this.aliveInterval + "min] detect. Clienct Key = " + key);
          eventLogMessage.setFacilityCd(fcd);
          logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);

          // 削除リストに追加
          delList.add(key);
        }
      });

      //
      for( int intlop = 0; intlop < delList.size(); intlop++ ) {

        // クライアントキー
        String key = delList.get(intlop);
        // 施設コード
        String fcd = "";
        // クライアントキーから施設コードを取得
        List<String> param = this.getClientKeyParams( key );
        if( 0 < param.size() ) {
          // 施設コード取得
          fcd = param.get(0);
        }

        // WebSocketSession
        WebSocketSession ws = this.clients.get( key ).session;

        // WSクライアント切断
        eventLogMessage.setLogMessage("Disconnect client for timeout detect. Clienct Key  = " +  key);
        eventLogMessage.setFacilityCd(fcd);
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        this.removeClient( ws );
        ws.close( CloseStatus.SESSION_NOT_RELIABLE );
      }
    }
    catch( Exception e ) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    }
  }

  /**
   * クライアント種別判定
   * @param clientKey クライアントキー情報
   * @return クライアント種別
   */
  public Client_Classes checkClientClass(String clientKey ) {
    Client_Classes ret = Client_Classes.OTHER;

    try {
      // クライアントがブラウザかどうかを判断
      if( ret == Client_Classes.OTHER ) {
        int idx = clientKey.indexOf(Client_Classes.BROWSER.getName());
        if( 1 <= idx ) {
          ret = Client_Classes.BROWSER;
        }
      }

      // クライアントがデバイスエッジかどうかを判定
      if( ret == Client_Classes.OTHER ) {
        int idx = clientKey.indexOf(Client_Classes.DEVICE_EDGE.getName());
        if( 1 <= idx ) {
          // クライアントがデバイスエッジであった場合

          // デバイスエッジ上のアップデータ用クライアント判定
          int idx2 = clientKey.indexOf("UPD" + Client_Classes.DEVICE_EDGE.getName());
          if( idx2 == -1 ) {
            ret = Client_Classes.DEVICE_EDGE;
          }
        }
      }

      // クライアントが体重計サービスかどうかを判断
      if( ret == Client_Classes.OTHER ) {
        int idx = clientKey.indexOf(Client_Classes.WEIGHT_SCALE.getName());
        if( 1 <= idx ) {
          ret = Client_Classes.WEIGHT_SCALE;
        }
      }

      // クライアントが印刷サービスかどうかを判断
      if( ret == Client_Classes.OTHER ) {
        int idx = clientKey.indexOf(Client_Classes.PRINT_SERVER.getName());
        if( 1 <= idx ) {
          ret = Client_Classes.PRINT_SERVER;
        }
      }
    }
    catch( Exception e ) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    }

    return ret;
  }

  /**
   * クライアント異常切断処理
   */
  public void checkErrorDisconnClient() {
    EventLogMessage eventLogMessage = new EventLogMessage();
    try {

      ArrayList<String> delList = new ArrayList<>();

      // 異常切断検出分
      this.commErrorClients.forEach((key,value)->{

        // 施設コード
        String fcd = "";
        // 識別子
        String deviceId = "";

        // クライアントキーから施設コード、識別子を取得
        List<String> param = this.getClientKeyParams( key );
        if( 0 < param.size() ) {
          // 施設コード取得
          fcd = param.get(0);
          // 識別子取得
          deviceId = param.get(1);
        }

        // 情報取得
        DisconnectionClient info = value;

        // 現在日時取得
        LocalDateTime now = LocalDateTime.now();
        // 指定時間算出
        LocalDateTime date = info.disconnDetected.plusMinutes( this.postDEStatusDilay );

        // 指定時間経過判定
        if( date.isBefore( now ) == true ) {
          // 指定時間の経過を検出

          //
          eventLogMessage.setLogMessage("checkErrorDisconnClient() Clienct Key = " + key);
          eventLogMessage.setFacilityCd(fcd);
          logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);


          // 種別による処理
          switch( info.clientClass ) {

            case OTHER:    // その他
              break;

            case BROWSER: // ブラウザ
              break;

            case DEVICE_EDGE:   // デバイスエッジ

              // デバイスエッジ番号取得
              int deno = Integer.parseInt( deviceId.substring( info.clientClass.getName().length() ));

              // データベースに施設コードとデバイスエッジ番号を条件としてデバイスエッジ接続状態を取得
              List<MntDeviceEdgeState> mntDeviceEdgeStateList = mntDeviceEdgeStateService.findByFacilityDeviceEdgeNo(fcd, deno);
              if( 0 < mntDeviceEdgeStateList.size() ) {
                // 接続状態、最終更新時刻判定
                MntDeviceEdgeState state = mntDeviceEdgeStateList.get(0);
                if( state.getAliveMoniStatus().equals(AliveMoniStatus.RUNNING /*"01"*/) == true
                 && ( state.getLastMoniTime() == null
                 || ( state.getLastMoniTime() != null && state.getLastMoniTime().equals( info.lastUpdate ) == true )))  {
                  // 接続状態が「01」で最終更新更新日時が切断検出時と同じであった場合

                  String content = fcd + "_" + deno + "_F1";
                  // 通信異常を通知
                  String responseCd = "";
                  try{

                    // URI作成
                    URI uri = new URI(this.makePostDEStatusURI());

                    //
                    eventLogMessage.setLogMessage("API moni_alive/response CALLED Clienct Key = " +  key + ", facility_Cd =" + fcd + ","
                        + " device_edge_no = " + deno + ", content = " + content + ", URI = " + uri);
                    eventLogMessage.setFacilityCd(fcd);
                    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);

                    // ヘッダ作成
                    HttpHeaders headers = new HttpHeaders();
                    headers.setContentType(MediaType.APPLICATION_JSON_UTF8);
                    headers.add( this.getSecurityHeaderParamName(), this.getSecurityKey() );

                    // ボディ作成
                    String body = "";
                    body += "{";
                    body += "\"content\":\"";
                    body += Base64.getEncoder().encodeToString(content.getBytes(StandardCharsets.UTF_8));
                    body += "\"}";

                    // リクエスト作成
                    RequestEntity<?> req = new RequestEntity<>(body, headers, HttpMethod.POST, uri);

                    // リクエスト処理
                    ResponseEntity<String> res = rt.exchange(req, String.class);
                    responseCd = res.getStatusCode().toString();
                  }catch( Exception e) {

                    // エラー
                    eventLogMessage.setLogMessage("API moni_alive/response CALLED Clienct Key = " +  key + ", error = " + e.toString());
                    eventLogMessage.setFacilityCd(fcd);
                    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
                  }

                  //
                  eventLogMessage.setLogMessage("API moni_alive/response CALLED finish. Clienct Key = " +  key + ", status = " + responseCd);
                  eventLogMessage.setFacilityCd(fcd);
                  logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
                }
                else {
                  // 切断検出時と情報が異なる場合

                  //
                  eventLogMessage.setLogMessage("checkErrorDisconnClient() change mnt_device_state info. Clienct Key  = " +  key);
                  eventLogMessage.setFacilityCd(fcd);
                  logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
                }
              }
              break;

            case WEIGHT_SCALE:  // 体重計サービス

              // 体重計番号取得
              int scaleNo = Integer.parseInt( deviceId.substring( info.clientClass.getName().length() ));

              // データベースから施設コードと体重計番号を条件として体重計情報を取得
              MstWeight weight = mstWeightService.mstWeightSelectByFacilityCdWeightNo(fcd, scaleNo);
              if( weight != null ) {

                // 体重計管理番号を条件として接続状態を取得
                MntWeightState state = mntWeightStateService.selectByScaleCd(weight.getWeightCd());
                if( state != null ) {
                  // 接続状態、最終更新時刻判定
                  if( state.getIsConnect().equals("1") == true
                      && ( state.getUpDate() == null
                      || ( state.getUpDate() != null && state.getUpDate().equals( info.lastUpdate ) == true ))) {

                      // 接続状態が「1」で最終更新更新日時が切断検出時と同じであった場合

                      // 体重計管理番号を条件として接続状態を切断に更新
                      mntWeightStateService.updateIsConnect(weight.getWeightCd(), "0" );

                      //
                      SendClientMessageDTO request = new SendClientMessageDTO();
                      // 通知先
                      request.setEncodeTargetId(String.format("%s%s", fcd, Client_Classes.BROWSER.getName()));
                      // メッセージ(トピック{TAB}ペイロード)
                      request.setEncodeMessage(String.format("WEIGHT/CONNECT/%s/%s\t%s", fcd, weight.getWeightCd(), weight.getWeightCd()));

                      // ブラウザへ体重計の接続状態が変化したことを通知
                      this.sendMessageToAllServer( this.localIP, fcd, request );
                  }
                  else {
                    // 切断検出時と情報が異なる場合

                    //
                    eventLogMessage.setLogMessage("checkErrorDisconnClient() change mnt_weight_state info. Clienct Key  = " +  key);
                    eventLogMessage.setFacilityCd(fcd);
                    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
                  }
                }
              }
              break;

            case PRINT_SERVER:  // 印刷サービス
              break;
          }

          // 削除リストに追加
          delList.add(key);
        }
      });

      //
      for( int intlop = 0; intlop < delList.size(); intlop++ ) {

        // クライアントキー
        String key = delList.get(intlop);

        // 施設コード
        String fcd = "";
        // クライアントキーから施設コードを取得
        List<String> param = this.getClientKeyParams( key );
        if( 0 < param.size() ) {
          // 施設コード取得
          fcd = param.get(0);
        }
        eventLogMessage.setLogMessage("Delete comm error client. Clienct Key  = " +  key);
        eventLogMessage.setFacilityCd(fcd);
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      }

      // 通信異常デバイスエッジクライアントリストから削除
      delList.forEach(key -> this.commErrorClients.remove(key));
    }
    catch( Exception e ) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    }
  }


  /**
   * 終了前処理
   */
  @PreDestroy
  public void cleanupBeforeExit() {
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("cleanupBeforeExit()");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);

    // 接続されているセッションをすべて切断する
    for(int intlop = this.sessions.size() - 1; 0 <= intlop; intlop-- ) {
      try {
        this.sessions.get(intlop).close();
      } catch ( Exception e ) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      }
    }
  }

  /**
   * デバイスエッジ状態のモニタ生存最終更新日時を更新
   * @param facilityCd
   * @param deviceEdgeNo
   * @return
   */
  public boolean updateAliveMoni(String facilityCd, int deviceEdgeNo ) {
    boolean ret = false;

    EventLogMessage eventLogMessage = new EventLogMessage();
    MntDeviceEdgeState rcd = new MntDeviceEdgeState();
    rcd.setFacilityCd(facilityCd);
    rcd.setDeviceEdgeNo(deviceEdgeNo);

    try {
      String logparam = String.format(" facility_cd:[%s] / device_edge_no:[%d]", facilityCd, deviceEdgeNo);
      if (mntDeviceEdgeStateService.updateAliveMoni(rcd) > 0) {
        eventLogMessage.setLogMessage("keep alive : success for update last_moni_time." + logparam);
        eventLogMessage.setFacilityCd(facilityCd);
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        ret = true;
      } else {
        eventLogMessage.setLogMessage("keep alive : error for update last_moni_time." + logparam);
        eventLogMessage.setFacilityCd(facilityCd);
        logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      }
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      eventLogMessage.setFacilityCd(facilityCd);
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    }
    return ret;
  }


  /**
   * クライアントへの送信
   *
   * @param targetId    通知先
   * @param message     送信メッセージ
   *
   */
  public boolean sendMessageToClient(String targetId, String message) {
    boolean ret[] = {false};
    EventLogMessage eventLogMessage = new EventLogMessage();
    try {
      String searchKey = targetId;
      eventLogMessage.setLogMessage("sendMessageToClient() searchKey = " + searchKey);
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);

      // クライアント一覧分
      clients.forEach((key, info) -> {
        if(key.startsWith(searchKey)) {
          // 該当ターゲットあり

          // 施設コード
          String fcd = "";
          // クライアントキーから施設コード、識別子を取得
          List<String> param = this.getClientKeyParams( key );
          if( 0 < param.size() ) {
            // 施設コード取得
            fcd = param.get(0);
          }

          try {

            // 送信処理
            eventLogMessage.setLogMessage("sendMessageToClient() send IP = " + info.session.getRemoteAddress().toString() + ", Session ID = " + info.session.getId() + ", Client Key = " + key +  ", Message = " + message);
            eventLogMessage.setFacilityCd(fcd);
            logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
            info.session.sendMessage( new TextMessage(message));
            eventLogMessage.setLogMessage("sendMessageToClient() send IP = " + info.session.getRemoteAddress().toString() + ", Session ID = " + info.session.getId() + ", Client Key = " + key + " success");
            eventLogMessage.setFacilityCd(fcd);
            logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);

            ret[0] = true;
          }
          catch (Exception ex) {

            // 送信失敗

            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(ex));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
            eventLogMessage.setFacilityCd(fcd);
            logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);

            try {
              // セッション切断
              info.session.close(CloseStatus.NOT_ACCEPTABLE);
            } catch (Exception e) {
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
              eventLogMessage.setFacilityCd(fcd);
              logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
            }
          }
        }
      });

      // 通知対象なし
      if( ret[0] == false )
      {
        eventLogMessage.setLogMessage("sendMessageToClient() not send. serchKey = " + searchKey);
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      }
    }
    catch( Exception e ) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    }

    return ret[0];
  }

  /**
   * クライアントへの送信(ログイン時、別タブでの接続確認用)
   * @param terminalUniqueString 端末固有ID
   * @return
   */
  public boolean sendChkMessageToClient(String terminalUniqueString) {
    boolean ret[] = {false};
    EventLogMessage eventLogMessage = new EventLogMessage();
    // クライアント一覧分
    Set<String> keysSet = clients.keySet();
    for (int i = 0; i < keysSet.size(); i++) {
      String key = keysSet.toArray(new String[0])[i];
      WSClientInfo info = clients.get(key);
      // サインイン前に実施する処理の為、施設番号等が不定、 端末固有IDで送信対象の絞り込みを行う
      if (info.terminalUniqueStr.equals(terminalUniqueString)) {
        try {
          // 接続確認用に空文字を送信 (null送信はエラーになる)
          info.session.sendMessage(new TextMessage(""));
          ret[0] = true;
          break;
        }
        catch (Exception ex) {
          // 送信失敗
          try {
            // セッション切断
            info.session.close(CloseStatus.NOT_ACCEPTABLE);
          } catch (Exception e) {
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
            logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
          }
        }
      }
    }
    return ret[0];
  }

  /**
   * 全サーバーに対して送信
   * @param remoteAddr  呼び出したリモートサーバーアドレス
   * @param facilityCd  施設コード
   * @param targetId    送信先ターゲットId
   * @param strPayload  送信メッセージ
   * @return
   */
  public boolean sendMessageToAllServer(String remoteAddr, String facilityCd, SendClientMessageDTO sendClientMessage  ) {
    boolean bflag[] = {false};
    StringBuilder sb = new StringBuilder();
    EventLogMessage eventLogMessage = new EventLogMessage();
    try {
      // WebSocketクライアント接続状態から対象施設コードの一覧を取得する
      List<MntClientConnect> mntClientConnectList = mntClientConnectService.findByFacility(facilityCd);
      mntClientConnectList.forEach( item -> {

        try{
          //
          eventLogMessage.setLogMessage("API sendMessageToAllServer() CALLED server IP :" + this.getLocalIp() + " -> forward IP : " + item.getIpAddress());
          eventLogMessage.setFacilityCd(facilityCd);
          logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);

          // 自サーバーかどうかを判定
          if(item.getIpAddress().equals(this.getLocalIp()) == true ) {
            // 自サーバー

            // 通知指示
            if( this.sendMessageToClient(sendClientMessage.getDecodeTargetId(), sendClientMessage.getDecodeMessage()) == true ) {
              // 通知成功
              bflag[0] = true;
            }
          } else {
            // 別サーバー

            // URI作成
            URI uri = new URI(this.makePostMsgURI(item.getIpAddress(), item.getServerType()));

            // ヘッダ作成
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON_UTF8);
            headers.add( this.getSecurityHeaderParamName(), this.getSecurityKey() );

            // リクエスト作成
            RequestEntity<?> req = new RequestEntity<>(sendClientMessage, headers, HttpMethod.POST, uri);

            sb.setLength(0);
            sb.append("API sendMessageToAllServer() CALLED IP : " + remoteAddr);
            sb.append(", targetId : " + sendClientMessage.getDecodeTargetId());
            sb.append(", URI : " + uri.toString());
            eventLogMessage.setLogMessage(sb.toString());
            eventLogMessage.setFacilityCd(facilityCd);
            logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);

            // リクエスト処理
            ResponseEntity<String> res =  rt.exchange(req, String.class);

            if( res.getStatusCode() == HttpStatus.OK ) {
              // 通知成功
              bflag[0] = true;
            }
          }
        }catch(URISyntaxException e) {

          // URIエラー
          sb.setLength(0);
          sb.append("API sendMessageToAllServer() CALLED IP : " + remoteAddr);
          sb.append(", targetId : " + sendClientMessage.getDecodeTargetId());
          sb.append(", URI error : " + e.toString());
          eventLogMessage.setLogMessage(sb.toString());
          eventLogMessage.setFacilityCd(facilityCd);
          logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);

        }catch(RestClientResponseException e){

          // レスポンスエラー

          // ステータスコードの取得
          sb.setLength(0);
          sb.append("API sendMessageToAllServer() CALLED IP       : " + remoteAddr);
          sb.append(", targetId : " + sendClientMessage.getDecodeTargetId());
          sb.append(", URI response error status  : " + e.getRawStatusCode());
          eventLogMessage.setLogMessage(sb.toString());
          eventLogMessage.setFacilityCd(facilityCd);
          logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        }
        catch( Exception e ) {
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
          eventLogMessage.setFacilityCd(facilityCd);
          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        }
      });
    }
    catch( Exception e ) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      eventLogMessage.setFacilityCd(facilityCd);
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    }

    return bflag[0];
  }
}
