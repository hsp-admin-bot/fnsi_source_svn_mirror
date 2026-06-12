package jp.co.nikkiso.ntss.admin_web.service.webSocketCertification;

import java.sql.Timestamp;
import java.time.Clock;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

import jp.co.nikkiso.ntss.admin_web.WebSocketNotifyProperties;
import jp.co.nikkiso.ntss.admin_web.request.webSocketCertification.WSCertificationDTO;
import jp.co.nikkiso.ntss.admin_web.security.NtssAuthenticationConstants;
import jp.co.nikkiso.ntss.admin_web.service.webSocketNotify.WebSocketNotifyService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.MstFacilityDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilityHashDao;
import jp.co.nikkiso.ntss.core.entity.MstFacility;
import jp.co.nikkiso.ntss.core.entity.MstFacilityHash;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.core.entity.MntWebsocketCertification;
import jp.co.nikkiso.ntss.core.dao.MntWebsocketCertificationDao;

import jakarta.servlet.http.HttpServletRequest;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import org.springframework.util.StringUtils;


/**
 * WebSocket認証コードサービス
 */
@Service
public class MntWebsocketCertificationServiceImpl implements MntWebsocketCertificationService{

  @Autowired
  private MntWebsocketCertificationDao mntWebsocketCertificationDao;

  @Autowired
  private Clock time;

  @Autowired
  LogService logService;

  @Autowired
  private WebSocketNotifyProperties webSocketNotifyProperties;


  /**
   * WebSocket通知Service.
   */
  @Autowired
  private WebSocketNotifyService webSocketNofityService;


  /**
   * 施設設定Daoインターフェース.
   */
  @Autowired
  private MstFacilityHashDao mstFacilityHashDao;

  @Autowired
  private MstFacilityDao mstFacilityDao;


  /**
   * 指定した認証コードの情報を取得する
   *
   * @param certificationCd　認証コード
   *
   * @return 認証コード情報
   */
  @Override
  public List<MntWebsocketCertification> findByCertification(String certificationCd) {
    List<MntWebsocketCertification> mntWebsocketCertification = mntWebsocketCertificationDao.selectByCertification(certificationCd);
    return mntWebsocketCertification;
  }


  /**
   * 指定した認証コード、施設コードで認証コード情報を登録する
   *
   * @param certificationCd　認証コード
   * @param facilityCd 施設コード
   *
   * @return 登録件数
   */
  @Override
  @Transactional
  public int insert(String certificationCd, String facilityCd) {
    // 接続情報作成
    MntWebsocketCertification mntWebsocketCertification = new MntWebsocketCertification();
    mntWebsocketCertification.setCertificationCd(certificationCd);
    mntWebsocketCertification.setFacilityCd(facilityCd);

    return mntWebsocketCertificationDao.insert(mntWebsocketCertification);
  }

  /**
   * 指定した認証コード情報を削除する
   *
   * @param certificationCd 認証コード
   *
   * @return 削除件数
   */
  @Override
  @Transactional
  public int delete(String certificationCd) {
    // 接続情報作成
    MntWebsocketCertification mntWebsocketCertification = new MntWebsocketCertification();
    mntWebsocketCertification.setCertificationCd(certificationCd);

    return mntWebsocketCertificationDao.delete(mntWebsocketCertification);
  }

  /**
   * 現在日時から指定分より前の認証コード情報を削除する
   *
   * @param addMinute 加算分数
   *
   * @return 削除件数
   */
  @Override
  @Transactional
  public int deleteAfterMinute(int addMinite) {
    int ret = 0;
    LocalDateTime now = LocalDateTime.now(time);
    Timestamp regDate = Timestamp.valueOf(now.plusMinutes(addMinite));

    // 接続情報作成
    MntWebsocketCertification mntWebsocketCertification = new MntWebsocketCertification();
    mntWebsocketCertification.setRegDate( regDate );

    // 削除対象件数判定
    if( 0 < mntWebsocketCertificationDao.selectCountByRegDate(mntWebsocketCertification)) {
      // 削除対象がある場合は削除
      ret = mntWebsocketCertificationDao.deleteRegDate(mntWebsocketCertification);
    }

    return ret;
  }

  /**
   * システム日時を取得.
   *
   * @return システム日時
   */
  public Clock getTime() {
    return time;
  }

  /* add by renxiaohao  2023-02-01 CodeOptimization  start */
  @Override
  public ResponseEntity<String> getStringResponseEntity(HttpServletRequest request, WSCertificationDTO WSCertification) {
    // 施設コード取得
    String facilityCd = WSCertification.getFacilityCd();

    StringBuilder sb = new StringBuilder();
    sb.append("API websocketcertification CALLED IP : " + request.getRemoteAddr());
    sb.append(", facility_cd : " + facilityCd);
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(sb.toString());
    logService.log(LogLevel.INFO, eventLogMessage,"", LoggingConstant.SERVICE_NAME.FNSI, null);

    // 作成日時が現在日時より2分以前の認証情報を削除する
    int cnt = deleteAfterMinute( -2 );


    ResponseEntity<String> ret;
    String key = "";

    //　UUID(認証キー)が重複した場合の対応
    UUID uuid;
    String uuid_str = "";
    for( int intlop = 0; intlop < 100; intlop++ ) {

      //　UUIDキー生成(ハイフン除去)
      uuid = UUID.randomUUID();
      uuid_str = uuid.toString().replaceAll("-", "");

      // UUIDキーの存在チェック
      List<MntWebsocketCertification> list = findByCertification(uuid_str);
      if(list.isEmpty()) {
        // 該当情報なし

        // 認証情報(UUIDと施設コード)を登録
        if( 0 < insert(uuid_str, facilityCd)) {

          // 登録成功時
          key = uuid_str;

          break;
        }
      }
    }


    // 結果判定
    if(0 < key.length()) {
      // 成功
      ret = new ResponseEntity<>(key, HttpStatus.OK);
    } else {
      //　失敗
      ret = new ResponseEntity<>("", HttpStatus.BAD_REQUEST);
    }

    //
    sb.setLength(0);
    sb.append("API websocketcertification CALLED IP : " + request.getRemoteAddr());
    sb.append(", facility_cd : " + facilityCd);
    sb.append(", key : " + key);
    sb.append(", status : " + ret.getStatusCode());
    eventLogMessage.setLogMessage(sb.toString());
    logService.log(LogLevel.INFO, eventLogMessage,"", LoggingConstant.SERVICE_NAME.FNSI, null);
    return ret;
  }
  /* add by renxiaohao  2023-02-01 CodeOptimization  end */

  /* add by renxiaohao  2023-02-01 CodeOptimization  start */
  @Override
  public String getUrlString(HttpServletRequest request, String facilityCd) {
    String tmpFacilityCd = "";
    String facilityCdRequest = getAdjustedValue(request.getParameter(NtssAuthenticationConstants.Params.FACILITY_CD)).trim();
    if (!StringUtils.isEmpty(facilityCdRequest)) {
      tmpFacilityCd = facilityCdRequest;
    } else {
      tmpFacilityCd = facilityCd;
    }
    String url = webSocketNotifyProperties.getAppConnectUrl();
    // vpnを利用する場合
    if (getVpnFlg(tmpFacilityCd)) {
      url = webSocketNotifyProperties.getVpnAppConnectUrl();
    }
    // add ログ改善対応 劉 start
    StringBuilder sb = new StringBuilder();
    sb.append("getWSConnectTargetUrl : /target_url " + request.getRemoteAddr() +
      "facilityCd: " + tmpFacilityCd + "url: " + url);
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(sb.toString());
    logService.log(LogLevel.INFO, eventLogMessage,"", LoggingConstant.SERVICE_NAME.FNSI, null);
    return url;
  }

  private String getAdjustedValue(String value) {
    return Optional.ofNullable(value).orElse("");
  }

  private boolean getVpnFlg(String facilityCd) {
    Boolean vpnFlag = false;
    if (!StringUtils.isEmpty(facilityCd)) {
      MstFacilityHash mstFacilityHash = mstFacilityHashDao.selectByHashValue(facilityCd);
      if (mstFacilityHash != null){
        MstFacility mstFacility = mstFacilityDao.selectByCd(mstFacilityHash.getFacilityCd());
        if ("1".equals(mstFacility.getVpnSet())) {
          return true;
        }
      }
    }

    return false;
  }
  /* add by renxiaohao  2023-02-01 CodeOptimization  end */

  /* add by renxiaohao  2023-02-01 CodeOptimization  start */
  @Override
  public boolean isResponseRet(HttpServletRequest request, Map<String, Object> req) {
    String hashValue = req.get("hashValue").toString();
    String localHashValue = req.get("localHashValue").toString();
    List<String> hashList = new ArrayList<String>();
    hashList.add(hashValue);
    if (!StringUtils.isEmpty(localHashValue) && !hashValue.equals(localHashValue) ) {
      // 別の施設にアクセスした場合は、その施設と、以前開いていた施設にチェック処理を行う必要がある
      hashList.add(localHashValue);
    }
    List<String> facilityCdList = mstFacilityHashDao.findByHashValueList(hashList);
    String terminalUniqueString = req.get("terminalUniqueString").toString();

    StringBuilder sb = new StringBuilder();
    sb.append("API websocketcertification CALLED IP : " + request.getRemoteAddr());
    for (String facilityCd : facilityCdList) {
      sb.append(", facility_cd : " + facilityCd);
    }
    sb.append(", terminalUniqueString : " + terminalUniqueString);
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(sb.toString());
    logService.log(LogLevel.INFO, eventLogMessage,"", LoggingConstant.SERVICE_NAME.FNSI, null);

    boolean ret = webSocketNofityService.chkClientConnect(facilityCdList, terminalUniqueString);
    return ret;
  }
  /* add by renxiaohao  2023-02-01 CodeOptimization  end */
}
