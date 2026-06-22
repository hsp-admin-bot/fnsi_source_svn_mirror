package jp.co.nikkiso.ntss.admin_web.service.webPush;

import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.entity.SysNotificationList;
import jp.co.nikkiso.ntss.core.entity.SysSystemDefine;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.dao.SysNotificationListDao;
import jp.co.nikkiso.ntss.core.dao.SysSystemDefineDao;

import org.bouncycastle.jce.ECNamedCurveTable;
import org.bouncycastle.jce.interfaces.ECPrivateKey;
import org.bouncycastle.jce.interfaces.ECPublicKey;
import org.bouncycastle.jce.provider.BouncyCastleProvider;
import org.bouncycastle.jce.spec.ECParameterSpec;
import org.bouncycastle.jce.spec.ECPublicKeySpec;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.BigInteger;
import java.security.InvalidAlgorithmParameterException;
import java.security.KeyFactory;
import java.security.KeyPair;
import java.security.KeyPairGenerator;
import java.security.NoSuchAlgorithmException;
import java.security.NoSuchProviderException;
import java.security.Security;
import java.security.spec.InvalidKeySpecException;
import java.sql.Timestamp;
import java.util.Base64;
import java.util.List;
import java.util.Map;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

/**
 * プッシュ通知のService実装クラス.
 */
@Service
public class WebPushServiceImpl implements WebPushService {

  private static final String KEY_ALGORITHM = "ECDSA";
  // 暗号プロバイダ(bouncy castle)
  private static final String PROVIDER = "BC";
  // 楕円曲線暗号(ECC)で使用する楕円曲線名 (証明書発行機関でも使われているprime256v1を指定)
  private static final String ECC_NAME = "prime256v1";
  public static final int VAPID_DRAFT_IETF_WEBPUSH_VAPID_01 = 0;
  public static final int VAPID_RFC8292 = 1;

  /**
   * システム設定
   */
  @Autowired
  private SysSystemDefineDao sysSystemDefineDao;

  /**
   * 通知先リスト
   */
  @Autowired
  private SysNotificationListDao sysNotificationListDao;

  /**
   * ロギングのServiceインタフェース.
   */
  @Autowired
  private LogService logService;

  /**
   * コンストラクタ.
   */
  public WebPushServiceImpl() {
    // BouncyCastleProviderのプロバイダを追加する
    if (Security.getProvider(BouncyCastleProvider.PROVIDER_NAME) == null) {
      Security.addProvider(new BouncyCastleProvider());
    }
  }

  @Override
  public String getKeyPair() {
    // 公開鍵、秘密鍵を sys_system_defineに保存しています。 (公開鍵 CtlNo:16、秘密鍵 CtlNo:17)
    List<SysSystemDefine> publicKeyDefine = sysSystemDefineDao.selectByCtlNo(16);
    List<SysSystemDefine> privateKeyDefine = sysSystemDefineDao.selectByCtlNo(17);

    // 両方のデータが既にあれば取得して応答
    if (privateKeyDefine.size() != 0 && publicKeyDefine.size() != 0) {
      JSONObject publicKeyObj = new JSONObject(publicKeyDefine.get(0).getValue());
      JSONObject privateKeyObj = new JSONObject(privateKeyDefine.get(0).getValue());

      // JSONに該当のキーがある場合のみ、取得処理を継続してreturnする
      if (publicKeyObj.has("publicKey_AffineX") && publicKeyObj.has("publicKey_AffineY") && privateKeyObj.has("privateKey")) {
        try {
          ECPublicKey publicKey = convertPublicKey(KEY_ALGORITHM, publicKeyObj.getString("publicKey_AffineX"), publicKeyObj.getString("publicKey_AffineY"));
          return Base64.getUrlEncoder().encodeToString(publicKey.getQ().getEncoded(false)).replaceAll("=+$", "");
        } catch (NoSuchAlgorithmException | NoSuchProviderException | InvalidKeySpecException e) {
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
          logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
          return "";
        }
      }
    }

    // 両方のデータがなければ鍵を生成
    try {
      // ECDSAで鍵を生成
      KeyPair keyPair = generateKeyPair(KEY_ALGORITHM);
      ECPublicKey publicKey = (ECPublicKey) keyPair.getPublic();
      ECPrivateKey privateKey = (ECPrivateKey) keyPair.getPrivate();;

      // 公開鍵保存処理
      JSONObject sysDefinePublicKeyValue = new JSONObject();
      // 公開鍵 AffineX
      sysDefinePublicKeyValue.put("publicKey_AffineX", Base64.getUrlEncoder().encodeToString(publicKey.getQ().getAffineXCoord().getEncoded()).replaceAll("=+$", ""));
      // 公開鍵 AffineY
      sysDefinePublicKeyValue.put("publicKey_AffineY", Base64.getUrlEncoder().encodeToString(publicKey.getQ().getAffineYCoord().getEncoded()).replaceAll("=+$", ""));

      // DBに保存
      SysSystemDefine insertPublicKeyData = new SysSystemDefine();
      insertPublicKeyData.setCtlNo(new BigDecimal("16"));
      insertPublicKeyData.setServiceCd("003");
      insertPublicKeyData.setName("プッシュ通知用公開鍵");
      insertPublicKeyData.setValue(sysDefinePublicKeyValue.toString());
      insertPublicKeyData.setDescription("プッシュ通知に使用する公開鍵を保存します。");
      insertPublicKeyData.setIsEnable("0");

      // レコードが0件の場合はINSERT、それ以外はUPDATE
      if (publicKeyDefine.size() == 0) {
        sysSystemDefineDao.insertDefine(insertPublicKeyData);
      } else {
        // insertメソッドでは日時が入らないため、現在時刻をセットする
        Timestamp publicUpDate = new Timestamp(System.currentTimeMillis());
        insertPublicKeyData.setUpDate(publicUpDate);
        // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
        LogEventUtils.setOperatorId(insertPublicKeyData,logService);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
        // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
        sysSystemDefineDao.update(insertPublicKeyData);
      }

      // 秘密鍵保存処理
      JSONObject sysDefinePrivateKeyValue = new JSONObject();
      // 秘密鍵
      sysDefinePrivateKeyValue.put("privateKey", Base64.getUrlEncoder().encodeToString(privateKey.getD().toByteArray()).replaceAll("=+$", ""));

      // DBに保存
      SysSystemDefine insertPrivateKeyData = new SysSystemDefine();
      insertPrivateKeyData.setCtlNo(new BigDecimal("17"));
      insertPrivateKeyData.setServiceCd("003");
      insertPrivateKeyData.setName("プッシュ通知用秘密鍵");
      insertPrivateKeyData.setValue(sysDefinePrivateKeyValue.toString());
      insertPrivateKeyData.setDescription("プッシュ通知に使用する秘密鍵を保存します。");
      insertPrivateKeyData.setIsEnable("0");

      // レコードが0件の場合はINSERT、それ以外はUPDATE
      if (privateKeyDefine.size() == 0) {
        sysSystemDefineDao.insertDefine(insertPrivateKeyData);
      } else {
        // insertメソッドでは日時が入らないため、現在時刻をセットする
        Timestamp privateUpDate = new Timestamp(System.currentTimeMillis());
        insertPrivateKeyData.setUpDate(privateUpDate);
        // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
        LogEventUtils.setOperatorId(insertPrivateKeyData,logService);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
        // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
        sysSystemDefineDao.update(insertPrivateKeyData);
      }

      return Base64.getUrlEncoder().encodeToString(publicKey.getQ().getEncoded(false)).replaceAll("=+$", "");
    } catch (NoSuchAlgorithmException | NoSuchProviderException
        | InvalidAlgorithmParameterException e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      return "";
    }
  }

  @Override
  public boolean saveNotificationDestination(Map<String, String> param) {
    SysNotificationList notification = new SysNotificationList();
    notification.setTerminalUniqueString(param.get("terminalUniqueString"));
    notification.setFacilityCd(param.get("facilityCd"));
    notification.setUserId(Long.parseLong(param.get("userId")));

    // 送信先
    JSONObject jsonObject = new JSONObject();
    jsonObject.put("endpoint", param.get("endpoint"));
    jsonObject.put("key", param.get("key"));
    jsonObject.put("auth", param.get("auth"));
    jsonObject.put("contentEncoding", param.get("contentEncoding"));
    jsonObject.put("jwt", param.get("jwt"));
    jsonObject.put("vapidVersion", param.get("vapidVersion"));
    notification.setNotificationData(jsonObject.toString());

    sysNotificationListDao.upsert(notification);
    return true;
  }

  @Override
  public int deleteNotificationDestination(String terminalUniqueString) {
    return sysNotificationListDao.deleteByTerminalUniqueString(terminalUniqueString);
  };

  @Override
  // mod FNSI-外結バッグを修正する 江 start
  //public List<SysNotificationList> searchNotificationDestination(String terminalUniqueString) {
  //  return sysNotificationListDao.selectByterminalUniqueString(terminalUniqueString);
  //};
  public List<SysNotificationList> searchNotificationDestination(String terminalUniqueString,String facilityCd, String userId) {
    return sysNotificationListDao.selectByterminalUniqueString(terminalUniqueString, facilityCd, userId);
  };
  // mod FNSI-外結バッグを修正する 江 end

  // 鍵生成処理
  private static KeyPair generateKeyPair(String type) throws NoSuchAlgorithmException, NoSuchProviderException, InvalidAlgorithmParameterException {
    // 引数に渡された名前付き曲線を表すパラメーター仕様を取得
    ECParameterSpec param = ECNamedCurveTable.getParameterSpec(ECC_NAME);
    // プロバイダ BC(ライブラリ) で、 引数のタイプ(ECDH) のインスタンスを作成
    KeyPairGenerator keyGen = KeyPairGenerator.getInstance(type, PROVIDER);
    // 作成したインスタンスを ECParameterSpec で初期化
    keyGen.initialize(param);
    // 公開鍵と非公開鍵のペアを生成して応答
    return keyGen.generateKeyPair();
  }

  // 保存した文字列からECPublicKeyに変換
  private static ECPublicKey convertPublicKey(String type, String x, String y) throws NoSuchAlgorithmException, NoSuchProviderException, InvalidKeySpecException {
    ECParameterSpec param = ECNamedCurveTable.getParameterSpec(ECC_NAME);
    ECPublicKeySpec keySpec = new ECPublicKeySpec(
        param.getCurve().validatePoint(
            new BigInteger(1, Base64.getUrlDecoder().decode(x)),
            new BigInteger(1, Base64.getUrlDecoder().decode(y))),
        param);
    KeyFactory keyFactory = KeyFactory.getInstance(type, PROVIDER);
    return (ECPublicKey) keyFactory.generatePublic(keySpec);
  }

  // 送信先リスト - key から、ECPublicKey を生成する
  public static ECPublicKey importPublicKey(String type, String q) throws NoSuchAlgorithmException, NoSuchProviderException, InvalidKeySpecException {
    ECParameterSpec param = ECNamedCurveTable.getParameterSpec(ECC_NAME);
    ECPublicKeySpec keySpec = new ECPublicKeySpec(
        param.getCurve().decodePoint(Base64.getUrlDecoder().decode(q)),
        param);
    KeyFactory keyFactory = KeyFactory.getInstance(type, PROVIDER);
    return (ECPublicKey) keyFactory.generatePublic(keySpec);
  }
}
