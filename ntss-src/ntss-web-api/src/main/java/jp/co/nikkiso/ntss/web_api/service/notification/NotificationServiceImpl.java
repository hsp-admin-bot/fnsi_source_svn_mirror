package jp.co.nikkiso.ntss.web_api.service.notification;

import java.io.BufferedOutputStream;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.UnsupportedEncodingException;
import java.math.BigInteger;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.nio.ByteBuffer;
import java.security.GeneralSecurityException;
import java.security.InvalidAlgorithmParameterException;
import java.security.InvalidKeyException;
import java.security.KeyFactory;
import java.security.KeyPair;
import java.security.KeyPairGenerator;
import java.security.NoSuchAlgorithmException;
import java.security.NoSuchProviderException;
import java.security.SecureRandom;
import java.security.Security;
import java.security.Signature;
import java.security.spec.InvalidKeySpecException;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Base64;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;

import javax.crypto.BadPaddingException;
import javax.crypto.Cipher;
import javax.crypto.IllegalBlockSizeException;
import javax.crypto.KeyAgreement;
import javax.crypto.Mac;
import javax.crypto.NoSuchPaddingException;
import javax.crypto.SecretKey;
import javax.crypto.ShortBufferException;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import javax.sql.DataSource;

import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.MntNotificationMessageDao;
import jp.co.nikkiso.ntss.core.dao.MntNotificationStatusDao;
import jp.co.nikkiso.ntss.core.dao.MstPersonalUserDao;
import jp.co.nikkiso.ntss.core.dao.MstUserAuthenticationDao;
import jp.co.nikkiso.ntss.core.dao.MstUserDao;
import jp.co.nikkiso.ntss.core.dao.SysNotificationListDao;
import jp.co.nikkiso.ntss.core.dao.SysSystemDefineDao;
import org.bouncycastle.jce.ECNamedCurveTable;
import org.bouncycastle.jce.interfaces.ECPrivateKey;
import org.bouncycastle.jce.interfaces.ECPublicKey;
import org.bouncycastle.jce.provider.BouncyCastleProvider;
import org.bouncycastle.jce.spec.ECParameterSpec;
import org.bouncycastle.jce.spec.ECPrivateKeySpec;
import org.bouncycastle.jce.spec.ECPublicKeySpec;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.BatchPreparedStatementSetter;
import org.springframework.jdbc.core.PreparedStatementCallback;
import org.springframework.jdbc.support.JdbcUtils;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.entity.MntNotificationMessage;
import jp.co.nikkiso.ntss.core.entity.MntNotificationStatus;
import jp.co.nikkiso.ntss.core.entity.MstUser;
import jp.co.nikkiso.ntss.core.entity.SysSystemDefine;
import jp.co.nikkiso.ntss.core.exception.NotExistException;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.web_api.constant.WebApiConstant;
import jp.co.nikkiso.ntss.web_api.request.NotificationRequest;
import jp.co.nikkiso.ntss.web_api.request.RecipientsRequest;
import jp.co.nikkiso.ntss.web_api.service.LogService;
import jp.co.nikkiso.ntss.web_api.service.webSocketNotify.WebSocketNotifyService;
import jp.co.nikkiso.ntss.web_api.service.webSocketNotify.WebSocketNotifyService.SendTarget;
//add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
import org.springframework.stereotype.Component;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;
//add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end

/**
 * 通知系Serviceの実装クラス.
 */
//add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
@Component
//add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
@Service
public class NotificationServiceImpl implements NotificationService {

  private static final String KEY_ALGORITHM = "ECDSA";
  // 暗号プロバイダ(bouncy castle)
  private static final String PROVIDER = "BC";
  // 楕円曲線暗号(ECC)で使用する楕円曲線名 (証明書発行機関でも使われているprime256v1を指定)
  private static final String ECC_NAME = "prime256v1";
  // 安全でない通信経路を用いて匿名鍵共有を行うプロトコル(楕円曲線Diffie–Hellman鍵共有：ECDH）
  private static final String KEY_SHARE_PROTOCOL = "ECDH";
  private static final String ENCRYPTION_ALGORITHM = "AES";
  private static final String HASH_ALGORITHM = "hmacSHA256";
  private static final String INFO_AUTH = "WebPush: info";
  public static final int VAPID_DRAFT_IETF_WEBPUSH_VAPID_01 = 0;
  public static final int VAPID_RFC8292 = 1;

  /* del by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
//  // 秘密鍵
//  private static ECPrivateKey privateKey = null;
//  // 公開鍵
//  private static ECPublicKey publicKey = null;
  /* del by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */

  /**
   * WebSocket通知Service.
   */
  @Autowired
  private WebSocketNotifyService webSocketNofityService;

  /**
   * 利用者マスタのDaoインタフェース.
   */
  @Autowired
  private MstUserDao mstUserDao;

  @Autowired
  private MstPersonalUserDao mstPersonalUserDao;

  /**
   * 通知メッセージのDaoインタフェース.
   */
  @Autowired
  private MntNotificationMessageDao mntNotificationMessageDao;

  /**
   * 通知状態管理のDaoインタフェース.
   */
  @Autowired
  private MntNotificationStatusDao mntNotificationStatusDao;

  /**
   * 利用者マスタ(認証DB)のDaoインタフェース.
   */
  @Autowired
  private MstUserAuthenticationDao mstUserAuthenticationDao;

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

  @Autowired
  private LogService logService;

  @Autowired
  private DataSource dataSource;


  /**
   * コンストラクタ.
   */
  public NotificationServiceImpl() {
    // BouncyCastleProviderのプロバイダを追加する
    if (Security.getProvider(BouncyCastleProvider.PROVIDER_NAME) == null) {
      Security.addProvider(new BouncyCastleProvider());
    }
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<MstUser.SettingValue> getPersonalSettings(Long userId, Integer tabDefineCd) {
    // ユーザー情報取得Dao呼び出し
    MstUser user = mstUserDao.selectById(userId);

    if (user == null) {

      // mod 7631 修正 chen start
      // ログ出力
      // EventLogMessage eventLogMessage = new EventLogMessage();
      // eventLogMessage.setLogMessage("There is no MstUser.");
      // eventLogMessage.setSqlIdentification("(userId = " + userId);
      // logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, "mstUserDao/selectById");
      // throw new NotExistException("存在しない利用者マスタのユーザーIDを指定されています。");
      return new ArrayList<MstUser.SettingValue>();
      // mod 7631 修正 chen end
    }

    // 指定の共通設定タブコードの設定値情報をフィルタリング
    MstUser.PersonalSetting personalSetting =
      user.getUserSettings().getPersonalSettings().stream()
        .filter(e -> e.getTabDefineCd().equals(tabDefineCd))
        .findFirst()
        .orElse(new MstUser.PersonalSetting());
    return personalSetting.getValues();
  }

  @Override
  public Map<Long, List<MstUser.SettingValue>> getPersonalSettingsByUserIds(List<Long> userIds, Integer tabDefineCd) throws NotExistException {
    return toUserIdSettingValueMap(mstUserDao.selectByListId(userIds), tabDefineCd);
  }

  @Override
  public Map<Long, List<MstUser.SettingValue>> getPersonalSettingsByFacilityCdList(List<String> facilityCdList, Integer tabDefineCd) throws NotExistException {
    return toUserIdSettingValueMap(mstUserDao.selectByFacilityCdList(facilityCdList), tabDefineCd);
  }

  @Override
  public Map<Long, List<MstUser.SettingValue>> getAllPersonalSettings(Integer tabDefineCd) throws NotExistException {
    return toUserIdSettingValueMap(mstUserDao.selectAll(), tabDefineCd);
  }

  private Map<Long, List<MstUser.SettingValue>> toUserIdSettingValueMap(List<MstUser> users, Integer tabDefineCd) {
    Map<Long, List<MstUser.SettingValue>> result = new HashMap<>();
    users.forEach(user -> result.put(
      user.getUserId(),
      user.getUserSettings()
        .getPersonalSettings()
        .stream()
        .filter(e -> e.getTabDefineCd().equals(tabDefineCd))
        .findFirst()
        .orElse(new MstUser.PersonalSetting())
        .getValues()
    ));
    return result;
  }

// mod FNSI-重要通知設定の追加 江 start
//  /**
//   * {@inheritDoc}
//   */
//  @Override
//  @Transactional
//  public Long registerNotificationMessage(String content, List<RecipientsRequest> recipients, String additionalInfo, String facilityCd) {
//
//    // 通知メッセージを登録する
//    Long notificationMessageNo = registerNotificationMessage(content, additionalInfo, facilityCd);
//
//    // 通知状態を登録する
//    registerNotificationStatus(notificationMessageNo, recipients);
//
//    // 通知メッセージを削除する
//    deleteNotificationMessage();
//
//    return notificationMessageNo;
//  }

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  public Long registerNotificationMessage(String content, List<RecipientsRequest> recipients, String additionalInfo, String facilityCd, Long notificationNo) {

    // 通知メッセージを登録する
    Long notificationMessageNo = registerNotificationMessage(content, additionalInfo, facilityCd, notificationNo);

    // 通知状態を登録する
    registerNotificationStatus(notificationMessageNo, recipients);

    // 通知メッセージを削除する
    deleteNotificationMessage();

    return notificationMessageNo;
  }

  @Override
  public List<Long> registerNotificationMessages(List<NotificationMessage> messages) {
    // 通知メッセージを登録する
    List<Long> notificationMessageNo = registerNotificationMessage(messages);


    // 通知状態を登録する
    List<NotificationStatus> statusList = new ArrayList<>();
    for (int i = 0; i < messages.size(); i++) {
      NotificationStatus status = new NotificationStatus();
      status.setNotificationMessageNo(notificationMessageNo.get(i));
      status.setRecipients(messages.get(i).getRecipients());
      statusList.add(status);
    }
    registerNotificationStatus(statusList);

    // 通知メッセージを削除する
    deleteNotificationMessage();
    return notificationMessageNo;
  }
// mod FNSI-重要通知設定の追加 江 end

  //add FNSi6531通知が重複して行われる 周 start
  /**
   * {@inheritDoc}
   */
   @Override
   public List<MntNotificationMessage> getNotificationMessage(String facilityCd, Long notificationNo) {

     List<MntNotificationMessage> notificationMessageList =
       mntNotificationMessageDao.selectMntNotificationMessageByNotificationNo(facilityCd, notificationNo);

     return notificationMessageList;
   }
  //add FNSi6531通知が重複して行われる 周 end

  // add bug 6522 修正 chen start
  /**
   * {@inheritDoc}
   */
  // @Override
  // @Transactional
  // public List<MntNotificationMessage> hasNotificationMessage(String content, Long userId, String additionalInfo, String facilityCd, Long notificationNo) {
  //
  //   MntNotificationMessage entity = new MntNotificationMessage() {
  //     {
  //       setNotificationMessageNo(userId);
  //       setContent(content);
  //       setAdditionalInfo(additionalInfo);
  //       setFacilityCd(facilityCd);
  //       setNotificationNo(notificationNo);
  //     }
  //   };
  //   List<MntNotificationMessage> notificationMessage = mntNotificationMessageDao.selectMntNotificationMessageForFly(entity);
  //
  //   return notificationMessage;
  // }
  // add bug 6522 修正 chen end

// mod FNSI-重要通知設定の追加 江 start
//  /**
//   * 通知メッセージを登録します.
//   *
//   * @param content        メッセージ本文
//   * @param additionalInfo 付加情報
//   * @param facilityCd     施設コード
//   * @return 通知メッセージ番号
//   */
//  private Long registerNotificationMessage(String content, String additionalInfo, String facilityCd) {
//    // 通知メッセージを登録する
//    MntNotificationMessage entity = new MntNotificationMessage() {
//      {
//        setContent(content);
//        setAdditionalInfo(additionalInfo);
//        setFacilityCd(facilityCd);
//      }
//    };
//    mntNotificationMessageDao.insert(entity);
//
//    // 通知メッセージ番号を返却する
//    return entity.getNotificationMessageNo();
//  }
  /**
   * 通知メッセージを登録します.
   *
   * @param content        メッセージ本文
   * @param additionalInfo 付加情報
   * @param facilityCd     施設コード
   * @return 通知メッセージ番号
   */
  private Long registerNotificationMessage(String content, String additionalInfo, String facilityCd, Long notificationNo) {
    // 通知メッセージを登録する
    MntNotificationMessage entity = new MntNotificationMessage() {
      {
        setContent(content);
        setAdditionalInfo(additionalInfo);
        setFacilityCd(facilityCd);
        setNotificationNo(notificationNo);
      }
    };
    // mod FNSi7119サインイン時クール・ベッド未登録通知の内容が最新でない 周 start
    // mod FNSi6531通知が重複して行われる 周 start
    mntNotificationMessageDao.insert(entity);
//    if(notificationNo.equals(CoreConstant.NotificationDefinition.NOTIFY_KUR_NOT_SET) ||
//      notificationNo.equals(CoreConstant.NotificationDefinition.NOTIFY_BED_NOT_SET)) {
//      List<MntNotificationMessage> mntNotificationMessageList = getNotificationMessage(facilityCd, notificationNo);
//      if(mntNotificationMessageList.isEmpty()) {
//        mntNotificationMessageDao.insert(entity);
//      } else {
//        return mntNotificationMessageList.get(0).getNotificationMessageNo();
//      }
//    } else {
//      mntNotificationMessageDao.insert(entity);
//    }
    // mod FNSi6531通知が重複して行われる 周 end
    // mod FNSi7119サインイン時クール・ベッド未登録通知の内容が最新でない 周 end

    // 通知メッセージ番号を返却する
    return entity.getNotificationMessageNo();
  }
// mod FNSI-重要通知設定の追加 江 end

  private List<Long> registerNotificationMessage(List<NotificationService.NotificationMessage> messages) {
    class JdbcTemplate extends org.springframework.jdbc.core.JdbcTemplate {

      public JdbcTemplate(DataSource dataSource) {
        super(dataSource);
      }

      public List<Long> batchInsert(String sql, BatchPreparedStatementSetter setter) throws DataAccessException {
        return this.execute(con -> con.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS),
          (PreparedStatementCallback<List<Long>>) ps -> {
            for (int i = 0; i < setter.getBatchSize(); i++) {
              setter.setValues(ps, i);
              ps.addBatch();
            }
            ps.executeBatch();
            List<Long> keys = new ArrayList<>();
            ResultSet rs = ps.getGeneratedKeys();
            while (rs.next()) {
              keys.add(rs.getLong(1));
            }
            JdbcUtils.closeResultSet(rs);
            return keys;
          });
      }
    }

    // 通知メッセージを登録する
    List<MntNotificationMessage> entities = messages.stream().map(m -> {
      MntNotificationMessage message = new MntNotificationMessage();
      message.setContent(m.getContent());
      message.setAdditionalInfo(m.getAdditionalInfo());
      message.setFacilityCd(m.getFacilityCd());
      message.setNotificationNo(m.getNotificationNo());
      return message;
    }).collect(Collectors.toList());
    // mod FNSi7119サインイン時クール・ベッド未登録通知の内容が最新でない 周 start
    // mod FNSi6531通知が重複して行われる 周 start

    JdbcTemplate template = new JdbcTemplate(dataSource);
    return template.batchInsert("insert into mnt_notification_message (content, additional_info, " +
      " reg_date, up_date, facility_cd, notification_no) values(?,?,?,?,?,?)", new BatchPreparedStatementSetter() {
      @Override
      public void setValues(PreparedStatement ps, int i) throws SQLException {
        MntNotificationMessage entity = entities.get(i);
        ps.setString(1, entity.getContent());
        ps.setString(2, entity.getAdditionalInfo());
        ps.setTimestamp(3, new Timestamp(System.currentTimeMillis()));
        ps.setTimestamp(4, new Timestamp(System.currentTimeMillis()));
        ps.setString(5, entity.getFacilityCd());
        ps.setLong(6, entity.getNotificationNo());
      }

      @Override
      public int getBatchSize() {
        return entities.size();
      }
    });
  }

  /**
   * 通知状態管理を登録します.
   *
   * @param notificationMessageNo 通知メッセージ番号
   * @param recipients            ユーザーIDのリスト
   */
  private void registerNotificationStatus(Long notificationMessageNo, List<RecipientsRequest> recipients) {
    // mod FNSi6531通知が重複して行われる 周 start
    // 通知状態管理を登録する
//    List<MntNotificationStatus> entities = recipients.stream()
//      .map(recipient -> new MntNotificationStatus() {
//        {
//          setNotificationMessageNo(notificationMessageNo);
//          setUserId(recipient.getUserId());
//          setFacilityCd(recipient.getFacilityCd());
//        }
//      })
//      .collect(Collectors.toList());

    List<MntNotificationStatus> statusList = mntNotificationStatusDao.selectByNotificationMessageNo(notificationMessageNo);
    List<MntNotificationStatus> entities = new ArrayList<>();
    recipients.stream().forEach(recipient -> {
//      int notificationStatusCount =
//        mntNotificationStatusDao.selectCountByUserIdAndFacilityCd(notificationMessageNo, recipient.getUserId(), recipient.getFacilityCd());
      boolean existStatus = statusList
        .stream()
        .anyMatch(s ->
          Objects.equals(s.getUserId(), recipient.getUserId()) &&
          Objects.equals(s.getFacilityCd(), recipient.getFacilityCd())
        );

      if(!existStatus) {
        MntNotificationStatus statusEntity = new MntNotificationStatus() {
          {
            setNotificationMessageNo(notificationMessageNo);
            setUserId(recipient.getUserId());
            setFacilityCd(recipient.getFacilityCd());
          }
        };
        entities.add(statusEntity);
      }
    });
    // mod FNSi6531通知が重複して行われる 周 end
    mntNotificationStatusDao.insert(entities);
  }

  private void registerNotificationStatus(List<NotificationStatus> notificationStatuses) {
    // mod FNSi6531通知が重複して行われる 周 start
    // 通知状態管理を登録する
//    List<MntNotificationStatus> entities = recipients.stream()
//      .map(recipient -> new MntNotificationStatus() {
//        {
//          setNotificationMessageNo(notificationMessageNo);
//          setUserId(recipient.getUserId());
//          setFacilityCd(recipient.getFacilityCd());
//        }
//      })
//      .collect(Collectors.toList());

    List<MntNotificationStatus> entities = new ArrayList<>();
    for (NotificationStatus notificationStatus : notificationStatuses) {
      // TODO: To HandsomeLin
      List<MntNotificationStatus> statusList = mntNotificationStatusDao
        .selectByNotificationMessageNo(notificationStatus.getNotificationMessageNo());
      notificationStatus.getRecipients().forEach(recipient -> {
//      int notificationStatusCount =
//        mntNotificationStatusDao.selectCountByUserIdAndFacilityCd(notificationMessageNo, recipient.getUserId(), recipient.getFacilityCd());
        boolean existStatus = statusList
          .stream()
          .anyMatch(s ->
            Objects.equals(s.getUserId(), recipient.getUserId()) &&
              Objects.equals(s.getFacilityCd(), recipient.getFacilityCd())
          );

        if(!existStatus) {
          MntNotificationStatus statusEntity = new MntNotificationStatus() {
            {
              setNotificationMessageNo(notificationStatus.getNotificationMessageNo());
              setUserId(recipient.getUserId());
              setFacilityCd(recipient.getFacilityCd());
            }
          };
          entities.add(statusEntity);
        }
      });
      // mod FNSi6531通知が重複して行われる 周 end
    }

    mntNotificationStatusDao.insert(entities);
  }

  /**
   * 通知メッセージを削除します.
   */
  private void deleteNotificationMessage() {
    // 通知メッセージを削除する
    LocalDate localDate = LocalDate.now().plusMonths(-3L);
    Timestamp timestamp = Timestamp.valueOf(localDate.atStartOfDay());
    mntNotificationMessageDao.delete(timestamp);
  }


  /**
   * {@inheritDoc}
   */
  @Override
  public void notifyNotificationMessage(Long notificationMessageNo, List<Long> recipients) {
    mstUserAuthenticationDao.selectFacilityCdByUserId(recipients).stream()
      .forEach(facilityCd -> {
        final String topic = String.format("%s/%s", WebApiConstant.WebSocketTopic.NOTIFICATION_MESSAGE, facilityCd);
        webSocketNofityService.sendMsg(SendTarget.browser, facilityCd, null, topic, notificationMessageNo.toString());
      });
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public int sendPushMessage(List<RecipientsRequest> recipientsReqList, String message) {
    // 通知先リストを取得
    List<NotificationRequest> notificationList = new ArrayList<NotificationRequest>();
    recipientsReqList.stream()
      .forEach(recipientsReq -> {
        sysNotificationListDao.selectByFacilityAnduserId(recipientsReq.getFacilityCd(), recipientsReq.getUserId()).stream()
          .forEach(notificationData -> {
            NotificationRequest addData = new NotificationRequest();
            addData.setTerminalUniqueString(notificationData.getTerminalUniqueString());
            addData.setFacilityCd(notificationData.getFacilityCd());
            addData.setUserId(notificationData.getUserId());
            addData.setNotificationData(notificationData.getNotificationData());
            addData.setSystemUseSetting(recipientsReq.getSystemUseSetting());
            notificationList.add(addData);
          });
      });

    /* upd by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
    // 秘密鍵・公開鍵を取得する（送信処理ごとに局所変数へ保持し、static 共有を避ける）
    List<SysSystemDefine> publicKeyDefine = sysSystemDefineDao.selectByCtlNo(16);
    List<SysSystemDefine> privateKeyDefine = sysSystemDefineDao.selectByCtlNo(17);
    final ECPrivateKey vapidPrivateKey;
    final ECPublicKey vapidPublicKey;
    try {
      JSONObject publicKeyObj = new JSONObject(publicKeyDefine.get(0).getValue());
      JSONObject privateKeyObj = new JSONObject(privateKeyDefine.get(0).getValue());
      vapidPublicKey = convertPublicKey(KEY_ALGORITHM, publicKeyObj.getString("publicKey_AffineX"), publicKeyObj.getString("publicKey_AffineY"));
      vapidPrivateKey = convertPrivateKey(KEY_ALGORITHM, privateKeyObj.getString("privateKey"));
    } catch (Exception e) {
      return 0;
    }
    /* upd by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */

    Integer sendCount = 0;
    for (NotificationRequest paramData : notificationList) {
      JSONObject param = new JSONObject(paramData.getNotificationData());
      // JSON形式で表示データを送信
      JSONObject payload = new JSONObject();
      payload.put("title", getNotificatonTitle(paramData.getSystemUseSetting()));
      payload.put("message", message);
      payload.put("icon", getNotificatonIcon(paramData.getSystemUseSetting()));
      // 通知先リスト分送信処理を実施
      //mod FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
//      JSONObject result = sendWebPush(
//        param.getString("key"),
//        param.getString("auth"),
//        param.getString("endpoint"),
//        payload.toString(),
//        param.getString("contentEncoding"),
//        new JSONObject(param.getString("jwt")),
//        param.getInt("vapidVersion"));
      /* upd by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
      JSONObject result = sendWebPush(
          param.getString("key"),
          param.getString("auth"),
          param.getString("endpoint"),
          payload.toString(),
          param.getString("contentEncoding"),
          new JSONObject(param.getString("jwt")),
          param.getInt("vapidVersion"),
          vapidPrivateKey,
          vapidPublicKey,
          logService);
      /* upd by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */
      //mod FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
      // 戻り値のオブジェクトで送信成功/失敗を判別
      // 成功時の結果例: {"response":"","status":201}
      // 410エラー時の結果例: {"response":"push subscription has unsubscribed or expired.","status":410}
      // 内部エラー時の結果例: {"error":"internal server error"}
      String terminalUniqueStringInfo = "[端末固有ID: " +  paramData.getTerminalUniqueString() + "] ";
      // ログ改善対応 毛 Add
      EventLogMessage eventLogMessage = new EventLogMessage();
      if (result.has("status")) {
         if (result.getInt("status") == 201) {
           // 成功時: 件数加算
           sendCount += 1;
           // ログ改善対応 毛 Del
           //EventLogMessage eventLogMessage = new EventLogMessage();
           eventLogMessage.setLogMessage(terminalUniqueStringInfo + "送信に成功しました。");
           logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
         } else if (result.getInt("status") == 410) {
           // 410エラー時: 通知先削除
           sysNotificationListDao.deleteByTerminalUniqueString(paramData.getTerminalUniqueString());
           // ログ改善対応 毛 Del
           //EventLogMessage eventLogMessage = new EventLogMessage();
           eventLogMessage.setLogMessage("例外発生：" + terminalUniqueStringInfo + "410エラーが発生したため、送信に失敗しました。");
           logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI, null);
         } else {
           // その他のステータス
           // ログ改善対応 毛 Del
           //EventLogMessage eventLogMessage = new EventLogMessage();
           eventLogMessage.setLogMessage(terminalUniqueStringInfo + "HTTP Status: " + result.getInt("status"));
           logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
         }
      } else if (result.has("error")) {
            // エラー発生
            // ログ改善対応 毛 Del
            //EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage("例外発生：" + terminalUniqueStringInfo + "エラーが発生したため、送信に失敗しました。(エラーメッセージ：\"" + result.getString("error") + "\")");
            logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      }
    }
    return sendCount;
  };

  /**
   * プッシュ通知用のタイトルを返します.
   *
   * @param systemUseSetting システム利用設定
   * @return ユーザーIDのリスト
   */
  private String getNotificatonTitle(String systemUseSetting) {
    if (systemUseSetting.equals("1")) {
      return WebApiConstant.WebPushOptions.TITLE_1;
    } else if (systemUseSetting.equals("2")) {
      return WebApiConstant.WebPushOptions.TITLE_2;
    } else if (systemUseSetting.equals("3")) {
      return WebApiConstant.WebPushOptions.TITLE_3;
    } else {
      return "";
    }
  }

  /**
   * プッシュ通知用のアイコンURLを返します.
   *
   * @param systemUseSetting システム利用設定
   * @return アイコンの相対URL
   */
  private String getNotificatonIcon(String systemUseSetting) {
    if (systemUseSetting.equals("1")) {
      return WebApiConstant.WebPushOptions.ICON_1;
    } else if (systemUseSetting.equals("2")) {
      return WebApiConstant.WebPushOptions.ICON_2;
    } else if (systemUseSetting.equals("3")) {
      return WebApiConstant.WebPushOptions.ICON_3;
    } else {
      return "";
    }
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

  // 保存した文字列からECPrivateKeyに変換
  private static ECPrivateKey convertPrivateKey(String type, String d) throws NoSuchAlgorithmException, NoSuchProviderException, InvalidKeySpecException {
    ECParameterSpec param = ECNamedCurveTable.getParameterSpec(ECC_NAME);
    ECPrivateKeySpec keySpec = new ECPrivateKeySpec(
        new BigInteger(1, (Base64.getUrlDecoder().decode(d))),
        param);
    KeyFactory keyFactory = KeyFactory.getInstance(type, PROVIDER);
    return (ECPrivateKey) keyFactory.generatePrivate(keySpec);
  }

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

  // 送信先リスト - key から、ECPublicKey を生成する
  public static ECPublicKey importPublicKey(String type, String q) throws NoSuchAlgorithmException, NoSuchProviderException, InvalidKeySpecException {
    ECParameterSpec param = ECNamedCurveTable.getParameterSpec(ECC_NAME);
    ECPublicKeySpec keySpec = new ECPublicKeySpec(
        param.getCurve().decodePoint(Base64.getUrlDecoder().decode(q)),
        param);
    KeyFactory keyFactory = KeyFactory.getInstance(type, PROVIDER);
    return (ECPublicKey) keyFactory.generatePublic(keySpec);
  }

  private static SecretKey generateSharedKey(ECPublicKey publicKey, ECPrivateKey privateKey) throws GeneralSecurityException {
    KeyAgreement keyAgree = KeyAgreement.getInstance(KEY_SHARE_PROTOCOL, PROVIDER);
    keyAgree.init(privateKey);
    keyAgree.doPhase(publicKey, true);
    return keyAgree.generateSecret(ENCRYPTION_ALGORITHM);
  }

  // 鍵クラス
  private static class Keys {
    private SecretKey secretKey = null;
    private ECPublicKey localPublicKey = null;
    private ECPublicKey userPublicKey = null;

    Keys(String key) throws GeneralSecurityException {
      // local key pair
      KeyPair localKeys = generateKeyPair(KEY_SHARE_PROTOCOL);
      localPublicKey = (ECPublicKey)localKeys.getPublic();

      // user public key
      userPublicKey = importPublicKey(KEY_SHARE_PROTOCOL, key);

      // key agreement
      secretKey = generateSharedKey(userPublicKey, (ECPrivateKey) localKeys.getPrivate());
    }

    public SecretKey getSecretKey() { return secretKey; };
    public ECPublicKey getLocalPublicKey() { return localPublicKey; };
    public ECPublicKey getUserPublicKey() { return userPublicKey; };
  }
  // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
  private static byte[] generateSalt( LogService logService) {
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
    SecureRandom random;
    try {
      random = SecureRandom.getInstanceStrong();
    } catch (NoSuchAlgorithmException e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      if (logService != null) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      return null;
    }

    byte[] salt = new byte[16];
    // http://java-code.jp/288
    // 指定されたバイト配列にランダムのバイト値を設定
    // ランダムバイトを生成し、ユーザー指定のバイト配列に配置します。

    // https://docs.oracle.com/javase/jp/8/docs/api/java/security/SecureRandom.html
    random.nextBytes(salt);
    return salt;
  }

  private static byte[] extractHKDF(byte[] salt, byte[] key) throws GeneralSecurityException {
    Mac mac = Mac.getInstance(HASH_ALGORITHM);
    SecretKeySpec spec = new SecretKeySpec(salt, HASH_ALGORITHM);
    mac.init(spec);
    return mac.doFinal(key);
  }

  private static byte[] expandHKDF(byte[] prk, ByteBuffer info, int length) throws GeneralSecurityException {
    Mac mac = Mac.getInstance(HASH_ALGORITHM);
    SecretKeySpec spec = new SecretKeySpec(prk, HASH_ALGORITHM);
    mac.init(spec);
    ByteBuffer input = ByteBuffer.allocate(info.capacity() + 1);
    input.put(info);
    info.rewind();
    input.put((byte)1);
    input.rewind();
    ByteBuffer result = ByteBuffer.allocate(length);
    result.put(mac.doFinal(input.array()), 0, length);
    return result.array();
  }

  private static byte[] generateCEK(String info, byte[] prk) throws GeneralSecurityException {
    ByteBuffer context = ByteBuffer.allocate(0);
    int contextLength = (context != null) ? (context.capacity() + 1) : 0;
    ByteBuffer cekInfo = ByteBuffer.allocate(info.length() + contextLength).put(info.getBytes());
    if(context != null) {
      cekInfo.put((byte)0);
      cekInfo.put(context);
      context.rewind();
    }
    cekInfo.rewind();
    return expandHKDF(prk, cekInfo, 16);
  }

  private static byte[] generateNonce(byte[] prk) throws GeneralSecurityException {
    ByteBuffer context = ByteBuffer.allocate(0);
    int contextLength = (context != null) ? (context.capacity() + 1) : 0;
    String infoNonce = "Content-Encoding: nonce";
    ByteBuffer info = ByteBuffer.allocate(infoNonce.length() + contextLength).put(infoNonce.getBytes());
    if(context != null) {
      info.put((byte)0);
      info.put(context);
      context.rewind();
    }
    info.rewind();
    return expandHKDF(prk, info, 12);
  }
  private static byte[] generateNonce(byte[] base, long c) {
    ByteBuffer buf = ByteBuffer.wrap(base);
    ByteBuffer counter = ByteBuffer.allocate(8);
    counter.putLong(c);
    counter.position(2);
    for(int i = base.length - 6 ; i < base.length ; i++) {
      byte b = (byte)(buf.get(i) ^ counter.get());
      buf.position(i);
      buf.put(b);
    }
    return buf.array();
  }

  // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
  private static byte[] encryptRecordWithDelimiter(byte[] k, byte[] n, ByteBuffer buf, byte delimiter, long counter, LogService logService) {
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
    byte[] nonce = generateNonce(n, counter);

    try {
      IvParameterSpec iv = new IvParameterSpec(nonce);
      Cipher cipher = Cipher.getInstance("AES/GCM/NoPadding", PROVIDER);
      cipher.init(Cipher.ENCRYPT_MODE, new SecretKeySpec(k, ENCRYPTION_ALGORITHM), iv);

      final int size = buf.limit() - buf.position();
      ByteBuffer input = ByteBuffer.allocate(size + 2);
      input.put(buf);
      input.put(delimiter);
      input.put((byte)0);
      byte[] buffer = new byte[cipher.getOutputSize(input.capacity())];
      int l = cipher.update(input.array(), 0, input.capacity(), buffer);
      byte[] remaining = cipher.doFinal();
      ByteBuffer result = ByteBuffer.allocate(buffer.length);
      result.put(buffer, 0, l);
      result.put(remaining);
      return result.array();
    } catch (NoSuchAlgorithmException
        | NoSuchProviderException
        | NoSuchPaddingException
        | InvalidKeyException
        | InvalidAlgorithmParameterException
        | IllegalBlockSizeException
        | BadPaddingException
        | ShortBufferException e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      if (logService != null) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      return null;
    }
  }

  // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
  private static ByteBuffer encrypt(String info, byte[] prk, String payload, LogService logService) throws GeneralSecurityException {
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
    byte[] hashInfoKey = generateCEK(info, prk);
    byte[] hashInfoNonce = generateNonce(prk);
    final int overhead = 18; // tag length (=16) + delimiter (=1) + padding (one or more bytes of 0x00)
    final int recordSize = 4096;

    try {
      ByteBuffer input = ByteBuffer.wrap(payload.getBytes("UTF-8"));
      int blocks = input.capacity() / (recordSize - overhead);
      int remaining = input.capacity() - blocks * (recordSize - overhead);
      ByteBuffer output = ByteBuffer.allocate(blocks * (recordSize + overhead) + remaining + overhead);
      long counter = 0;
      boolean isLast = false;
      while(!isLast) {
        int length = recordSize - overhead;
        if(input.position() + length >= input.capacity()) {
          length = input.capacity() - input.position();
          isLast = true;
        }
        input.limit(input.position() + length);
        output.limit(output.position() + length + overhead);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
        output.put(encryptRecordWithDelimiter(hashInfoKey, hashInfoNonce, input, (byte)(isLast ? 2 : 1), counter,logService));
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
        input.position(input.limit());
        counter++;
      }
      output.rewind();
      return output;
    } catch (UnsupportedEncodingException e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      if (logService != null) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      return null;
    }
  }

  // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
  /* upd by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
  private static String generateJWT(JSONObject info, LogService logService, ECPrivateKey vapidPrivateKey) {
  /* upd by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
    // JWT Header
    JSONObject h = new JSONObject();
    h.put("typ", "JWT");
    h.put("alg", "ES256");
    // JWT Payload
    JSONObject p = new JSONObject();
    String aud = info.optString("aud");
    String sub = info.optString("sub");
    if(aud != null)
      p.put("aud", aud);
    if(sub != null)
      p.put("sub", sub);
    long cur = System.currentTimeMillis() / 1000;
    p.put("exp", cur + 12*60*60); // 12 hours
    // p.put("iat", cur);
    String claim = Base64.getUrlEncoder().encodeToString(h.toString().getBytes()).replaceAll("=+$", "")
        + "." + Base64.getUrlEncoder().encodeToString(p.toString().getBytes()).replaceAll("=+$", "");

    try {
      Signature signer = Signature.getInstance("SHA256withECDSA", PROVIDER);
      /* upd by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
      signer.initSign(vapidPrivateKey);
      /* upd by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */
      signer.update(claim.getBytes());

      // convert ASN.1 to JWS (i.e. concatenated R and S raw bytes)
      int pos;
      ByteBuffer asn1 = ByteBuffer.wrap(signer.sign());
      ByteBuffer signature = ByteBuffer.allocate(64);

      asn1.position(3);
      int l1 = (int) asn1.get();

      pos = 4 + l1 - 32;
      asn1.limit(pos + 32);
      asn1.position(pos);
      signature.put(asn1);
      pos += 33;
      asn1.limit(asn1.capacity());
      asn1.position(pos);
      int l2 = (int) asn1.get();
      pos += 1 + l2 - 32;
      asn1.limit(pos + 32);
      asn1.position(pos);
      signature.put(asn1);

      return claim + "." + Base64.getUrlEncoder().encodeToString(signature.array()).replaceAll("=+$", "");
    } catch (GeneralSecurityException e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      if (logService != null) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      return null;
    }
  }

  // Push通知処理
  /* upd by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
  private static JSONObject sendWebPush(
      String key,
      String auth,
      String endpoint,
      String payload,
      String contentEncoding,
      JSONObject info,
      int vapidVersion,
      ECPrivateKey vapidPrivateKey,
      ECPublicKey vapidPublicKey,
      LogService logService) {
  /* upd by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */
    ByteBuffer header = ByteBuffer.allocate(16 + 4 + 1 + 65);
    ByteBuffer output = null;
    Keys keys = null;
    final int rs = 4096;
    //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
    EventLogMessage eventLogMessage = new EventLogMessage();
    //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
    if(key == null) {
        eventLogMessage.setLogMessage("user public key is not specified");
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        return new JSONObject().put("error", "user public key is not specified");
    }

    // the maximum payload length supported by push services is 3992 bytes
    // (= 4096 - 86 (header) - 2 (padding) - 16 (expansion of AEAD_AES_128_GCM))
    if(payload.length() > 3992) {
        eventLogMessage.setLogMessage("payload is too long (> 3992 bytes)");
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      return new JSONObject().put("error", "payload is too long (> 3992 bytes)");
    }

    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
    byte[] salt = generateSalt(logService);
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
    if(salt == null) {
        eventLogMessage.setLogMessage("cannot initialize SecureRandom");
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        return new JSONObject().put("error", "cannot initialize SecureRandom");
    }

    // create a shared secret key for AES encryption
    try {
      keys = new Keys(key);
    } catch (GeneralSecurityException e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang end
      eventLogMessage.setLogMessage("failed to initialize keys");
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      return new JSONObject().put("error", "failed to initialize keys");
    }

    // Encryption Content Coding Header
    // Note: In "aes128gcm" encoding, keyid must be the ECDH public key of
    // the application server (draft-ietf-webpush-encryption-08)
    header.put(salt);
    header.putInt(rs);
    header.put((byte)65);
    header.put(keys.getLocalPublicKey().getQ().getEncoded(false));
    header.rewind();

    // generate CEK and nonce, and encrypt the given payload
    if(auth == null) {
        eventLogMessage.setLogMessage("auth parameter from UA is not speficied");
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        return new JSONObject().put("error", "auth parameter from UA is not speficied");
    }
    try {
      byte[] prkKey = extractHKDF(Base64.getUrlDecoder().decode(auth), keys.getSecretKey().getEncoded());
      ByteBuffer keyInfo = ByteBuffer.allocate(INFO_AUTH.length() + 1 + 65 + 65)
          .put(INFO_AUTH.getBytes())
          .put((byte)0)
          .put(keys.getUserPublicKey().getQ().getEncoded(false))
          .put(keys.getLocalPublicKey().getQ().getEncoded(false));
      keyInfo.rewind();
      byte[] ikm = expandHKDF(prkKey, keyInfo, 32);
      byte[] prk = extractHKDF(salt, ikm);
      String infoCEK = "Content-Encoding: aes128gcm"; // draft-ietf-httpbis-encryption-encoding-09
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
      output = encrypt(infoCEK, prk, payload != null ? payload : "",logService);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
    } catch (GeneralSecurityException e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang end
      eventLogMessage.setLogMessage("failed to generate content encryption key");
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      return new JSONObject().put("error", "failed to generate content encryption key");
    }

    // post the push message (with the encrypted payload, if any)
    HttpURLConnection conn = null;
    URL url;
    try {
      url = new URL(endpoint);
      conn = (HttpURLConnection)url.openConnection();
      conn.setRequestMethod("POST");
      conn.setDoOutput(true);

      conn.setRequestProperty("Content-Type", "application/octet-stream");
      conn.setRequestProperty("Content-Length", String.format("%d", header.capacity() + output.capacity()));
      conn.setRequestProperty("Content-Encoding", "aes128gcm");
      conn.setRequestProperty("TTL",  String.format("%d",  2*24*60*60)); // 2 days in second

      if(info != null) {
        // VAPID: create a signature by SHA-256 with ECDSA
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
        /* upd by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
        String jwt = generateJWT(info, logService, vapidPrivateKey);
        /* upd by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end

        switch (vapidVersion) {
        case VAPID_RFC8292:
          /* upd by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
          conn.setRequestProperty(
              "Authorization",
              "vapid t=" + jwt + ", k=" + Base64.getUrlEncoder().encodeToString(vapidPublicKey.getQ().getEncoded(false)).replaceAll("=+$", ""));
          /* upd by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */
          break;
        case VAPID_DRAFT_IETF_WEBPUSH_VAPID_01:
          /* upd by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
          conn.setRequestProperty(
              "Crypto-Key",
              "p256ecdsa=" + Base64.getUrlEncoder().encodeToString(vapidPublicKey.getQ().getEncoded(false)).replaceAll("=+$", ""));
          /* upd by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */
          conn.setRequestProperty("Authorization", "WebPush " + jwt);
          break;
        }
      }

      BufferedOutputStream out = new BufferedOutputStream(conn.getOutputStream());
      out.write(header.array());
      out.write(output.array());
      out.flush();
      out.close();

      int status = conn.getResponseCode();
      StringBuffer response = new StringBuffer();
      JSONObject result = new JSONObject().put("status", status);

      try {
        BufferedReader reader = new BufferedReader(new InputStreamReader(conn.getInputStream(), "UTF-8"));
        String buf;
        while((buf = reader.readLine()) != null) {
          response.append(buf);
        }
        reader.close();
        //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
        eventLogMessage.setLogMessage("======= Web Push Sent =======");
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        eventLogMessage.setLogMessage(response.toString());
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
      }
      catch(IOException e) {
        InputStream in = conn.getErrorStream();
        if(in != null) {
          BufferedReader reader = new BufferedReader(new InputStreamReader(in, "UTF-8"));
          String buf;
          while((buf = reader.readLine()) != null) {
            response.append(buf);
          }
          reader.close();
        }
        else {
          response.append("");
        }
        //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
        eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("======= Web Push Failed =======");
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(conn.getHeaderField(null));
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
        for(String i : conn.getHeaderFields().keySet()) {
          if (i != null) {
            //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
            eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage(i + ": " + conn.getHeaderField(i));
            logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
            //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
          }
        }
        //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
        eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(response.toString());
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
      }
      conn.disconnect();
      result.put("response", response.toString());
      return result;
    } catch (MalformedURLException e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      if (logService != null) {
        EventLogMessage eventLogMessageNew = new EventLogMessage();
        eventLogMessageNew.setLogMessage(ExcetionStackTraceToString(e));
        logService.log(LogLevel.ERROR, eventLogMessageNew, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
    } catch (IOException e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      if (logService != null) {
        EventLogMessage eventLogMessageNew = new EventLogMessage();
        eventLogMessageNew.setLogMessage(ExcetionStackTraceToString(e));
        logService.log(LogLevel.ERROR, eventLogMessageNew, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      if (conn != null) {
        conn.disconnect();
      }
    }
    // ログ改善対応 毛 Add
    eventLogMessage.setLogMessage("Push通知処理失敗");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    return new JSONObject().put("error", "internal server error");
 }
}
