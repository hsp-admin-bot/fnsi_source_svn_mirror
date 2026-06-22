package jp.co.nikkiso.ntss.m_notice.service;

import tools.jackson.core.type.TypeReference;
import tools.jackson.databind.JsonNode;
import tools.jackson.databind.ObjectMapper;
import com.google.common.base.Strings;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.MotionRecordDataType;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.UserType;
import jp.co.nikkiso.ntss.core.dao.MstAlarmNotificationDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilityHashDao;
import jp.co.nikkiso.ntss.core.dao.MstMachineRecordControlDao;
import jp.co.nikkiso.ntss.core.dao.MstMachineRecordDao;
import jp.co.nikkiso.ntss.core.dao.MstPersonalUserDao;
import jp.co.nikkiso.ntss.core.dao.SysSystemDefineDao;
import jp.co.nikkiso.ntss.core.entity.MntDeviceEdgeState;
import jp.co.nikkiso.ntss.core.entity.MntMachineState;
import jp.co.nikkiso.ntss.core.entity.MntMotionRecord;
import jp.co.nikkiso.ntss.core.entity.MstAlarmNotification;
import jp.co.nikkiso.ntss.core.entity.MstDeviceEdge;
import jp.co.nikkiso.ntss.core.entity.MstFacility;
import jp.co.nikkiso.ntss.core.entity.MstFacilityHash;
import jp.co.nikkiso.ntss.core.entity.MstMNotice;
import jp.co.nikkiso.ntss.core.entity.MstMachine;
import jp.co.nikkiso.ntss.core.entity.MstMachineRecord;
import jp.co.nikkiso.ntss.core.entity.MstMachineType;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.entity.SysSystemDefine;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.utils.NtssUtils;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.m_notice.NtssMNoticeProperties;
import jp.co.nikkiso.ntss.m_notice.constant.MNoticeConstant.CorrectionStatus;
import jp.co.nikkiso.ntss.m_notice.constant.MNoticeConstant.FlagType;
import jp.co.nikkiso.ntss.m_notice.constant.MNoticeConstant.MailSetting;
import jp.co.nikkiso.ntss.m_notice.constant.MNoticeConstant.ServiceSupportType;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.AliveMoniDeviceEdgeAlarmCode;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.AliveMoniSendMailStatus;
import jp.co.nikkiso.ntss.m_notice.constant.MNoticeMessageConstant.MNoticeError;
import jp.co.nikkiso.ntss.m_notice.constant.MNoticeMessageConstant.MNoticeStatus;
import jp.co.nikkiso.ntss.m_notice.constant.MNoticeMessageConstant.Remarks;
import jp.co.nikkiso.ntss.m_notice.constant.TelegramConstant.TelegramElement;
import jp.co.nikkiso.ntss.m_notice.constant.TelegramConstant.TelegramLength;
import jp.co.nikkiso.ntss.m_notice.packet.AliveMoniTelegram;
import jp.co.nikkiso.ntss.m_notice.packet.IkikoMNoticeTelegram;
import jp.co.nikkiso.ntss.m_notice.packet.InvalidAlertFormatException;
import jp.co.nikkiso.ntss.m_notice.packet.MNoticeTelegram;
import jp.co.nikkiso.ntss.m_notice.packet.NikkisoMNoticeTelegram;
import jp.co.nikkiso.ntss.m_notice.packet.NxMNoticeTelegram;
import jp.co.nikkiso.ntss.m_notice.service.MstAlarmNotificationService.EmailAddressAndName;

import org.apache.commons.codec.binary.Hex;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.util.ObjectUtils;
import org.springframework.util.StringUtils;

import tools.jackson.core.JacksonException;
import java.nio.charset.StandardCharsets;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;

import static java.util.stream.Collectors.joining;

/**
 * 緊急発報のサービスクラス.
 */
@Service
public class MNotice {

  /**
   * 装置動作記録サービス.
   */
  @Autowired
  private MntMotionRecordService mntMotionRecordService;

  /**
   * システム設定クラス.
   */
  @Autowired
  private SysSystemDefineService sysSystemDefineService;

  /**
   * 緊急発報マスタサービス.
   */
  @Autowired
  private MstMNoticeService mstMNoticeService;

  /**
   * 施設マスタサービス.
   */
  @Autowired
  private MstFacilityService mstFacilityService;

  /**
   * 型式マスタサービス.
   */
  @Autowired
  private MstMachineTypeService mstMachineTypeService;

  /**
   * 装置マスタサービス.
   */
  @Autowired
  private MstMachineService mstMachineService;

  /**
   * メール送信サービス.
   */
  @Autowired
  private MailSenderService mailSenderService;

  /**
   * デバイスエッジサービス.
   */
  @Autowired
  private MstDeviceEdgeService mstDeviceEdgeService;

  /**
   * 装置状態管理サービス
   */
  @Autowired
  private MntMachineStateService mntMachineStateService;

  /**
   * 施設コードハッシュDao
   */
  @Autowired
  private MstFacilityHashDao mstFacilityHashDao;

  /**
   * 緊急発報に関する設定クラス
   */
  @Autowired
  private NtssMNoticeProperties ntssMNoticeProperties;

  /**
   * 警報通知マスタに関するサービス
   */
  @Autowired
  private MstAlarmNotificationService mstAlarmNotificationService;

  /**
   * 警報通知マスタのDaoインタフェース.
   */
  @Autowired
  private MstAlarmNotificationDao mstAlarmNotificationDao;

  /**
   * デバイスエッジ状態のDaoインタフェース.
   */
  @Autowired
  private MntDeviceEdgeStateService mntDeviceEdgeStateService;

  /**
   *  システム設定のDaoインタフェース
   */
  @Autowired
  private SysSystemDefineDao sysSystemDefineDao;

  /**
   * Logger.
   */
  @Autowired
  LogService logService;

  //add 外部警報メッセージ変換修正 劉 start
  /**
   * 装置記録マスタのDaoインタフェース.
   */
  @Autowired
  private MstMachineRecordDao mstMachineRecordDao;
  //add 外部警報メッセージ変換修正 劉 end

  /**
   * 装置記録マスタ(編集)のDaoインタフェース.
   */
  @Autowired
  private MstMachineRecordControlDao mstMachineRecordControlDao;

  /**
   * 利用者マスタのDaoインタフェース.
   */
  @Autowired
  private MstPersonalUserDao mstPersonalUserDao;

  /**
   * 緊急発報処理.
   * 「@Async」によりスレッド化
   *
   * @param buffer
   */
  @Async
  public void run(byte[] buffer) {
    // 登録用エンティティクラス作成
    MntMotionRecord mntMotionRecord = new MntMotionRecord();
    try {
      mntMotionRecord = createMntMotionRecordFrom(buffer);
      // ステータスが-1(異常)のときは、DBに保存し、処理を終了する
      // ステータスが2(メール送信対象なし)のときは、DBに保存せず、処理を終了する
      if (MNoticeStatus.FAULT.equals(mntMotionRecord.getMNoticeStatus())
          || MNoticeStatus.NO_MAIL.equals(mntMotionRecord.getMNoticeStatus())) {
        return;
      }
    } finally {
      if (MNoticeStatus.FAULT.equals(mntMotionRecord.getMNoticeStatus())) {
        // ここでDB保存したメールアドレスは他処理で使用しないため、セキュリティ観点からDB保存しないようにnullで更新する
        mntMotionRecord.setEmailAddress(null);
      }
      if (!MNoticeStatus.NO_MAIL.equals(mntMotionRecord.getMNoticeStatus())) {
        mntMotionRecordService.create(mntMotionRecord);
      }
    }

    if (checkIsOnPremises()) {
      // オンプレミス環境はメール送信しない

      // ステータスを 9：メール送信スキップに設定
      mntMotionRecord.setMNoticeStatus(MNoticeStatus.SKIP);
      // 送信日時をnullに設定
      mntMotionRecord.setEmailSendDate(null);
      // メールアドレスは他処理で使用しないため、セキュリティ観点からDB保存しないようにnullで更新する
      mntMotionRecord.setEmailAddress(null);
      mntMotionRecordService.update(mntMotionRecord);

    } else {
      // クラウド環境ではAmazon SESを使用してメール通知する

      // メールの送信
      // ⑩AWSのSESクラスを呼び出しする
      // Exception投げられ、メール送信に失敗したとき、ステータス-1(異常)
      try {
        // 既存のメール送信対象アドレス取得処理は、検索処理に時間がかかり、検索回数も多い為、暗号化状態のまま検索を実施し、利用者の判定をプログラム上で実施するように修正
        List<MstPersonalUser> destUserList = new ArrayList<>();
        List<String> encAddressList = new ArrayList<>();
        int strLen = 0;
        for (String decStr : mntMotionRecord.getEmailAddresses()) {
          // 共通処理により、DBと同様の暗号化を実施
          String encStr = NtssUtils.Encrypt(decStr);
          encAddressList.add(encStr);
          strLen += encStr.length();
          // 検索文字列の制限(in句に使用する文字の長さ上限が2KB)の為、文字数により処理を区切る
          if (strLen > 1500) {
            List<MstPersonalUser> res = mstPersonalUserDao.selectByNoDecryptEmailAddressList(encAddressList);
            if (destUserList.size() > 0) {
              // 既に取得済みのリストに、同じ利用者IDが存在するかを確認してリストを合算する
              List<MstPersonalUser> tmpRes = new ArrayList<>();
              res.forEach(pUser -> {
                if (destUserList.stream().filter(p -> p.getUserId() == pUser.getUserId()).collect(Collectors.toList()).size() == 0) {
                  tmpRes.add(pUser);
                }
              });
              destUserList.addAll(tmpRes);
            } else {
              destUserList.addAll(res);
            }
            // 初期化
            encAddressList = new ArrayList<>();
            strLen = 0;
          }
        }
        // 最終合算処理
        List<MstPersonalUser> lastRes = mstPersonalUserDao.selectByNoDecryptEmailAddressList(encAddressList);
        if (destUserList.size() > 0) {
          List<MstPersonalUser> tmpLastRes = new ArrayList<>();
          lastRes.forEach(pUser -> {
            if (destUserList.stream().filter(p -> p.getUserId() == pUser.getUserId()).collect(Collectors.toList()).size() == 0) {
              tmpLastRes.add(pUser);
            }
          });
          destUserList.addAll(tmpLastRes);
        } else {
          destUserList.addAll(lastRes);
        }
        // 日機装ユーザー用、一般ユーザー用にメールアドレスを分配
        List<String> tmpNkkAddressList = new ArrayList<>();
        List<String> tmpGenAddressList = new ArrayList<>();
        for (String mailStr : mntMotionRecord.getEmailAddresses()) {
          destUserList.stream()
          .filter(pUser -> mailStr.equals(pUser.getUserEmailAddress1()) || mailStr.equals(pUser.getUserEmailAddress2()))
          .forEach(pUser -> {
            if (UserType.NIKKISO.equals(pUser.getUserType().toString())) {
              tmpNkkAddressList.add(mailStr);
            } else if (UserType.GENERAL.equals(pUser.getUserType().toString())) {
              tmpGenAddressList.add(mailStr);
            }
          });
        }
        // 重複を削除
        List<String> nkkAddressList = tmpNkkAddressList.stream().distinct().collect(Collectors.toList());
        List<String> genAddressList = tmpGenAddressList.stream().distinct().collect(Collectors.toList());
        // 顧客メール送信対象が1以上の場合に日機装メール用アドレスに sys‗system_define.ctl_no：6 のアドレスを追加
        nkkAddressList = addAddress(nkkAddressList, genAddressList, mntMotionRecord);

        // 日機装ユーザーにメール送信
        sendMail(mntMotionRecord, nkkAddressList, true);

        // 一般ユーザーにメール送信
        sendMail(mntMotionRecord, genAddressList, false);

        mntMotionRecord.setEmailSendDate(new Timestamp(System.currentTimeMillis()));
      } catch (Exception e) {
        mntMotionRecord.setMNoticeStatus(MNoticeStatus.FAULT);
        // ここでDB保存したメールアドレスは他処理で使用しないため、セキュリティ観点からDB保存しないようにnullで更新する
        mntMotionRecord.setEmailAddress(null);
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("例外発生：" + e.getMessage());
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
        mntMotionRecordService.update(mntMotionRecord);
        return;
      }
      // ステータスを 1：メール送信済みに設定
      mntMotionRecord.setMNoticeStatus(MNoticeStatus.SEND_MAIL);
      // ここでDB保存したメールアドレスは他処理で使用しないため、セキュリティ観点からDB保存しないようにnullで更新する
      mntMotionRecord.setEmailAddress(null);
      mntMotionRecordService.update(mntMotionRecord);
    }

    // デバイスエッジ通信系のメールの場合はデバイスエッジ状態の更新
    mntDeviceEdgeStateService.updateSendMailFinish(mntMotionRecord);
  }

  /**
   * メール送信.
   * @param mntMotionRecord 装置動作記録のEntity
   * @param targets 送信先メールアドレスのリスト
   * @param isNikkisoUser {@code true}:日機装社員、{@code false}:顧客
   */
  private void sendMail(MntMotionRecord mntMotionRecord, List<String> targets, boolean isNikkisoUser) {

    if (ObjectUtils.isEmpty(targets)) {
      return;
    }

    // メール件名生成
    String subject = createSubject(
      mntMotionRecord.getFacilityCd(),
      mntMotionRecord.getMachineRecordMessage(),
      isNikkisoUser);

    // URL生成
    String url = createFilteredUrl(
      mntMotionRecord.getFacilityCd(),
      mntMotionRecord.getMachineTypeCd(),
      mntMotionRecord.getMachineSerial().trim(),
      isNikkisoUser,
      mntMotionRecord.getFacilityUrlSetting());

    // 送信メール本文を取得
    String mailText = mntMotionRecord.getSendEmailText();

    // メール送信
    // 宛先が50件以上の場合は送信グループを分ける
    List<String> sendAddress = new ArrayList<>();
    for (int i = 0; i < targets.size(); i++) {
      sendAddress.add(targets.get(i));
      if (sendAddress.size() == MailSetting.MAX_ADDRESS || i == targets.size() - 1) {
        mailSenderService.sendMessage(sendAddress, subject, mailText.replace("[URL]", url));
        sendAddress = new ArrayList<>();
      }
    }

  }

  /**
   * メール件名を生成する.
   * @param facilityCd 施設コード
   * @param machineRecordMessage 装置記録メッセージ
   * @param isNikkisoUser {@code true}の場合、日機装ユーザー用の件名を生成する
   * @return メール件名
   */
  private String createSubject(String facilityCd, String machineRecordMessage, boolean isNikkisoUser) {
    final String template = "【警報通知%s】%s";
    final String facilityName = isNikkisoUser ?
      "：" + mstFacilityService.findByCd(facilityCd).getFacilityName() :
      "";

    return String.format(template, facilityName, machineRecordMessage);
  }

  /**
   * 装置動作記録エンティティ生成.
   * 与えられたバイト配列(電文)から装置動作記録エンティティを作成します.
   *
   * @param buffer 電文
   * @return 装置動作記録エンティティ
   */
  private MntMotionRecord createMntMotionRecordFrom(final byte[] buffer) {
    // エンティティインスタンス
    final MntMotionRecord mntMotionRecord = new MntMotionRecord();
    try {
      // 対処を0(未対処)に設定
      mntMotionRecord.setIsCorrection(CorrectionStatus.UN_HANDLED);
      // サービス対応種別を"0"(未受付)に設定
      mntMotionRecord.setServiceSupportType(ServiceSupportType.NOT_ACCEPTED);
      // 緊急発報ステータスを0(送信待ち)に設定
      mntMotionRecord.setMNoticeStatus(MNoticeStatus.WAIT_SEND_MAIL);
      // 受信電文の分解処理
      final MNoticeTelegram telegram = createMntMotionRecordTelegram(mntMotionRecord, buffer);

      if (Objects.equals(mntMotionRecord.getMachineRecordCd(), AliveMoniDeviceEdgeAlarmCode.RECONNECT)) {
        // コードがG005: デバイスエッジ復旧の場合
        List<MntDeviceEdgeState> state = mntDeviceEdgeStateService.selectByKey(mntMotionRecord.getFacilityCd(), mntMotionRecord.getDeviceEdgeNo());
        if (state == null || state.size() == 0) {
          // 対象デバイスエッジなしなので処理を終了する
          mntMotionRecord.setMNoticeStatus(MNoticeStatus.NO_MAIL);
          return mntMotionRecord;
        }
        if (!Objects.equals(state.get(0).getSendMailStatus(), AliveMoniSendMailStatus.SEND_RECONNECT)) {
          // コードがG005で要送信以外の状態の場合、処理を終了する
          mntMotionRecord.setMNoticeStatus(MNoticeStatus.NO_MAIL);
          return mntMotionRecord;
        }
        List<MstAlarmNotification> notifySetting = mstAlarmNotificationDao.selectDevEdgeReconnectAlarmByDestinationFacilityCd(mntMotionRecord.getFacilityCd());
        if (notifySetting == null || notifySetting.size() == 0) {
          // 施設内でどの時間帯でもG005を通知する設定がないならば、メール送信済みと更新して処理を終了する
          MntDeviceEdgeState newState = state.get(0);
          newState.setSendMailStatus(AliveMoniSendMailStatus.NO_SEND);
          mntDeviceEdgeStateService.updateSendMailStatus(newState);

          mntMotionRecord.setMNoticeStatus(MNoticeStatus.NO_MAIL);
          return mntMotionRecord;
        }
      } else if (
          Objects.equals(mntMotionRecord.getMachineRecordCd(), AliveMoniDeviceEdgeAlarmCode.CONNECT_ERROR) ||
          Objects.equals(mntMotionRecord.getMachineRecordCd(), AliveMoniDeviceEdgeAlarmCode.DEVICE_ERROR)) {
        // コードがG000, G001 : デバイスエッジ異常の場合
        List<MntDeviceEdgeState> state = mntDeviceEdgeStateService.selectByKey(mntMotionRecord.getFacilityCd(), mntMotionRecord.getDeviceEdgeNo());
        if (state == null || state.size() == 0) {
          // 対象デバイスエッジなしなので処理を終了する
          mntMotionRecord.setMNoticeStatus(MNoticeStatus.NO_MAIL);
          return mntMotionRecord;
        }
        if (!Objects.equals(state.get(0).getSendMailStatus(), AliveMoniSendMailStatus.SEND_FAIL_CONNECT)) {
          // 要送信以外の状態の場合、処理を終了する
          mntMotionRecord.setMNoticeStatus(MNoticeStatus.NO_MAIL);
          return mntMotionRecord;
        }
        // 送信スケジュールに該当する警報通知マスタを取得し、対象がなければ処理を終了
        boolean isNotificationMatch = mstAlarmNotificationDao
            .getAlarmNotificationByMNoticeTelegram(mntMotionRecord.getEventRegDate(), mntMotionRecord.getFacilityCd(),
                mntMotionRecord.getMachineRecordCd())
            .stream().anyMatch(e -> e.getIsDel().equals(FlagType.FLAG_OFF) && e.getIsDisp().equals(FlagType.FLAG_ON));
        if (!isNotificationMatch) {
          mntMotionRecord.setMNoticeStatus(MNoticeStatus.NO_MAIL);
          return mntMotionRecord;
        }

      } else {
        // 送信スケジュールに該当する警報通知マスタを取得し、対象がなければ処理を終了
        boolean isNotificationMatch = mstAlarmNotificationDao
            .getAlarmNotificationByMNoticeTelegram(mntMotionRecord.getEventRegDate(), mntMotionRecord.getFacilityCd(),
                mntMotionRecord.getMachineRecordCd())
            .stream().anyMatch(e -> e.getIsDel().equals(FlagType.FLAG_OFF) && e.getIsDisp().equals(FlagType.FLAG_ON));
        if (!isNotificationMatch) {
          mntMotionRecord.setMNoticeStatus(MNoticeStatus.NO_MAIL);
          return mntMotionRecord;
        }
      }

      // data_typeを設定
      mntMotionRecord.setDataType(MotionRecordDataType.M_NOTICE);
      // MotionRecordにメール送信用のデータを設定
      setupMotionRecord(mntMotionRecord, telegram, buffer);
      return mntMotionRecord;
    } catch (Exception e) {
      // 例外時でも極力DBに永続化したいという要件(要望)があるため、
      // このような例外発生時にはログに情報を出力してDBへの永続化は行いないのが通常だが
      // この時点で永続化を行う。
      return mntMotionRecord;
    }
  }

  /**
   * 電文データの分解を行います。
   *
   * @param mntMotionRecord　装置動作記録エンティティ
   * @param buffer　電文
   * @return 電文を分解した構造体
   */
  MNoticeTelegram createMntMotionRecordTelegram(MntMotionRecord mntMotionRecord, byte[] buffer) {

    // 電文のデータ分解
    try {
      if (buffer.length == TelegramLength.NIKKISO) {
        // 電文の長さが38のとき、日機装装置
        NikkisoMNoticeTelegram telegram = new NikkisoMNoticeTelegram(buffer);
        nikkiso(mntMotionRecord, telegram);
        return telegram;

      } else if (buffer.length == TelegramLength.IKIKO) {
        // 電文の長さが80のとき、医器工装置
        IkikoMNoticeTelegram telegram = new IkikoMNoticeTelegram(buffer);
        ikiko(mntMotionRecord, telegram);
        return telegram;

      } else if (buffer.length == TelegramLength.NX) {
        // 電文の長さが64のとき、NX通信
        NxMNoticeTelegram telegram = new NxMNoticeTelegram(buffer);
        nx(mntMotionRecord, telegram);
        return telegram;

      } else if (buffer.length == TelegramLength.ALIVE_MONI) {
        // 死活監視アプリ
        AliveMoniTelegram telegram = new AliveMoniTelegram(buffer);
        aliveMoni(mntMotionRecord, telegram);
        return telegram;

      } else {
        throw new IllegalArgumentException(String.format("%dは有効な電文長ではありません。", buffer.length));
      }

    } catch (InvalidAlertFormatException e) {
      // チェックサム及びNull・空文字エラー出力
      mntMotionRecord.setMNoticeStatus(MNoticeStatus.FAULT);
      String digitRemarks = String.format(Remarks.TELEGRAM, e.getMessage(), Hex.encodeHexString(buffer));
      mntMotionRecord.setRemarks(digitRemarks);
      String bufString = new String(buffer, StandardCharsets.US_ASCII);
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("例外発生：" + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      eventLogMessage.setLogMessage("例外発生：" + bufString);
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      throw e;

    } catch (IllegalArgumentException e) {
      // 電文長エラー出力
      mntMotionRecord.setMNoticeStatus(MNoticeStatus.FAULT);
      String telegramRemarks = String.format(Remarks.TELEGRAM_LENGTH, Hex.encodeHexString(buffer));
      mntMotionRecord.appendRemarks(telegramRemarks);
      String bufString = new String(buffer, StandardCharsets.US_ASCII);
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("例外発生：" + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      eventLogMessage.setLogMessage("例外発生：" + bufString);
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      throw e;
    }
  }

  /**
   * 分解した日機装装置電文データを装置動作記録エンティティに設定します。
   *
   * @param mntMotionRecord　緊急発報管理エンティティ
   * @param telegram　日機装装置の構造体
   */
  private void nikkiso(MntMotionRecord mntMotionRecord, NikkisoMNoticeTelegram telegram) {
    // 緊急発報管理エンティティに値を詰め込む
    // イベント発生日時
    mntMotionRecord.setEventRegDate(telegram.getOccurrenceDateTime());
    mntMotionRecord.setMachineTypeCd(telegram.getFV(TelegramElement.MODEL_CODE).toString());
    mntMotionRecord.setComFormatCd(telegram.getFV(TelegramElement.COM_FORMAT_CD).toString());
    // mntMotionRecord.setMachineSerial(telegram.getFV(TelegramElement.SERIAL_NUMBER).toString().trim());
    mntMotionRecord.setMachineSerial(telegram.getFV(TelegramElement.SERIAL_NUMBER).toString());
    mntMotionRecord.setFacilityCd(telegram.getFV(TelegramElement.FACILITY_CODE).toString());
    mntMotionRecord.setMachineRecordCd(telegram.getFV(TelegramElement.RECORDING_CODE).toString());
    mntMotionRecord.setMachineRecordAuxData(telegram.getRecordingDatasAsHexString().stream().collect(joining(",")));
  }

  /**
   * 分解した医器工装置電文データを装置動作記録エンティティに設定します。
   *
   * @param mntMotionRecord　緊急発報管理エンティティ
   * @param telegram　医器工装置の構造体
   */
  private void ikiko(MntMotionRecord mntMotionRecord, IkikoMNoticeTelegram telegram) {
    // 緊急発報管理エンティティに値を詰め込む
    // イベント発生日時
    mntMotionRecord.setEventRegDate(telegram.getOccurrenceDateTime());
    mntMotionRecord.setMachineTypeCd(telegram.getFV(TelegramElement.MODEL_CODE).toString());
    mntMotionRecord.setComFormatCd(telegram.getFV(TelegramElement.COM_FORMAT_CD).toString());
    // mntMotionRecord.setMachineSerial(telegram.getFV(TelegramElement.SERIAL_NUMBER).toString().trim());
    mntMotionRecord.setMachineSerial(telegram.getFV(TelegramElement.SERIAL_NUMBER).toString());
    mntMotionRecord.setFacilityCd(telegram.getFV(TelegramElement.FACILITY_CODE).toString());
    mntMotionRecord.setMachineRecordCd(telegram.getFV(TelegramElement.RECORDING_CODE).toString());
    mntMotionRecord.setMachineRecordMessage(telegram.getFV(TelegramElement.RECORDING_MESSAGE).toString());
  }

  /**
   * 分解したNX通信電文データを装置動作記録エンティティに設定します。
   *
   * @param mntMotionRecord　装置動作記録エンティティ
   * @param telegram　NX通信の構造体
   */
  private void nx(MntMotionRecord mntMotionRecord, NxMNoticeTelegram telegram) {
    // 緊急発報管理エンティティに値を詰め込む
    // イベント発生日時
    mntMotionRecord.setEventRegDate(telegram.getOccurrenceDateTime());
    mntMotionRecord.setMachineTypeCd(telegram.getFV(TelegramElement.MODEL_CODE).toString());
    mntMotionRecord.setComFormatCd(telegram.getFV(TelegramElement.COM_FORMAT_CD).toString());
    // mntMotionRecord.setMachineSerial(telegram.getFV(TelegramElement.SERIAL_NUMBER).toString().trim());
    mntMotionRecord.setMachineSerial(telegram.getFV(TelegramElement.SERIAL_NUMBER).toString());
    mntMotionRecord.setFacilityCd(telegram.getFV(TelegramElement.FACILITY_CODE).toString());
    mntMotionRecord.setMachineRecordCd(telegram.getFV(TelegramElement.RECORDING_CODE).toString());
    mntMotionRecord.setMachineRecordAuxData(telegram.getAddressDatasAsHexString().stream().collect(joining(",")));
  }

  /**
   * 分解した死活監視アプリの電文データを装置記録エンティティに設定.
   *
   * @param mntMotionRecord 装置動作記録エンティティ
   * @param telegram 死活監視アプリの構造体
   */
  private void aliveMoni(MntMotionRecord mntMotionRecord, AliveMoniTelegram telegram) {
    mntMotionRecord.setFacilityCd(telegram.getFV(TelegramElement.FACILITY_CODE).toString());
    mntMotionRecord.setDeviceEdgeNo(Integer.parseInt(telegram.getFV(TelegramElement.DEVICE_EDGE_NUMBER).toString()));
    mntMotionRecord.setEventRegDate(telegram.getOccurrenceDateTime(telegram.getFV(TelegramElement.OCCURRENCE_DATETIME).toString()));
    mntMotionRecord.setMachineRecordCd(telegram.getFV(TelegramElement.RECORDING_CODE).toString());
  }

  /**
   * 外部警報メッセージ変換.
   *
   * @param machineRecordCd 装置記録コード
   * @param facilityCd 施設コード
   * @param message 変換前のメッセージ
   * @return mst_machine_record_control に編集されたメッセージあれば、そのメッセージで応答する
   *         なければ、mst_machine_record のメッセージを応答として返す
   */
  private String convertExternalAlarmMessage(String machineRecordCd, String facilityCd, String message) {
    String rtnMessage = mstMachineRecordControlDao.selectMachineRecordMessage(machineRecordCd, facilityCd);
    if (Strings.isNullOrEmpty(rtnMessage)) {
      MstMachineRecord mstMachineRecord = mstMachineRecordDao.selectByCd(machineRecordCd);
      if (null != mstMachineRecord) {
        rtnMessage = mstMachineRecord.getMachineRecordMessage();
      }
      // リストに存在しない場合は変換前のメッセージを返す
      return message;
    }
    return rtnMessage;
  }

  /**
   * 装置動作記録エンティティ生成.
   * 与えられた情報よりマスタ検索を行い、装置動作記録エンティティにデータを設定する.
   *
   * @param mntMotionRecord　装置動作記録エンティティ
   * @param telegram　構造体
   * @param buffer　電文
   */
  private void setupMotionRecord(MntMotionRecord mntMotionRecord, MNoticeTelegram telegram, byte[] buffer) {
    // 構造体（受信データ）、緊急発報マスタ、施設マスタより、緊急発報管理テーブルに登録するデータの作成
    // ・イベント発生日時 構造体
    // ・緊急発報ステータス 0: メール送信待ちをセット
    // ・型式コード 構造体
    // ・製造番号 構造体
    // ・施設コード 構造体
    // ・メール送信日時 システム日時
    // ・メール本文 施設マスタ
    // ・装置記録コード 構造体
    // ・装置記録メッセージ 構造体
    // ・メールアドレス 緊急発報マスタ
    // ・宛先名称 緊急発報マスタ

    // 施設コード
    String facilityCd = mntMotionRecord.getFacilityCd();
    // 装置記録コード
    String machineRecordCd = mntMotionRecord.getMachineRecordCd();
    // 型式コード
    String machineTypeCd = mntMotionRecord.getMachineTypeCd();
    // 製造番号
    String machineSerial = mntMotionRecord.getMachineSerial();

    // 製造番号はtrim
    // mnt_motion_record には受信したそのままの値を設定するため
    if (machineSerial != null) {
      machineSerial = machineSerial.trim();
    }

    // 通信種別
    Integer comType = null;
    // 装置マスタの取得
    MstMachine mstMachine = null;
    // 死活監視の以外の場合に装置マスタ検索を行う
    // mod FNSI-バグ 通信サーバ #8427 高 start
    mstMachine = mstMachineService.findByCd(machineTypeCd, machineSerial, facilityCd);
    if (!(telegram instanceof AliveMoniTelegram)) {
      // mstMachine = mstMachineService.findByCd(machineTypeCd, machineSerial, facilityCd);
      if (mstMachine == null) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("例外発生：" + MNoticeError.GET_MST_MACHINE);
        eventLogMessage.setSqlIdentification("(machineTypeCd = " + machineTypeCd + ", machineSerial = " + machineSerial + ",facilityCd=" + facilityCd + ")");
        eventLogMessage.setFacilityCd(facilityCd);
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,"mstMachineService/findByCd");
        String mstMNoticeRemarks = String.format(Remarks.MST_MACHINE_RECORD, machineTypeCd, machineSerial, facilityCd);
        mntMotionRecord.appendRemarks(mstMNoticeRemarks);
      }
    }
    if (mstMachine != null) {
      comType = mstMachine.getComType();
    }
    // mod FNSI-バグ 通信サーバ #8427 高 end
    // 通信種別の確認を行う
    validateComType(mntMotionRecord, buffer, comType);
    // 緊急発報マスタの取得
    MstMNotice mstMNotice = mstMNoticeService.findByCd(facilityCd, machineRecordCd);
    if (mstMNotice == null) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("例外発生：" + MNoticeError.GET_MST_M_NOTICE);
      eventLogMessage.setSqlIdentification("( machineRecordCd = " + machineRecordCd + ",facilityCd=" + facilityCd + ")");
      eventLogMessage.setFacilityCd(facilityCd);
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,"mstMNoticeService/findByCd");
      mntMotionRecord.setMNoticeStatus(MNoticeStatus.FAULT);
      String mstMNoticeRemarks = String.format(Remarks.MST_M_NOTICE_RECORD, facilityCd, machineRecordCd);
      mntMotionRecord.appendRemarks(mstMNoticeRemarks);
    }
    // 施設マスタの取得
    MstFacility mstFacility = mstFacilityService.findByCd(facilityCd);
    if (mstFacility == null) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("例外発生：" + MNoticeError.GET_MST_FACILITY);
      eventLogMessage.setSqlIdentification("(facilityCd=" + facilityCd + ")");
      eventLogMessage.setFacilityCd(facilityCd);
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,"mstFacilityService/findByCd");
      mntMotionRecord.setMNoticeStatus(MNoticeStatus.FAULT);
      String mstMNoticeRemarks = String.format(Remarks.MST_FACILITY_RECORD, facilityCd);
      mntMotionRecord.appendRemarks(mstMNoticeRemarks);
    }
    // 型式マスタの取得
    MstMachineType mstMachineType = null;
    if (!(telegram instanceof AliveMoniTelegram)) {
      mstMachineType = mstMachineTypeService.findByTypeCd(machineTypeCd);
      if (mstMachineType == null) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("例外発生：" + MNoticeError.GET_MST_MACHINE_TYPE);
        eventLogMessage.setSqlIdentification("(machineTypeCd=" + machineTypeCd + ")");
        eventLogMessage.setFacilityCd(facilityCd);
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,"mstMachineTypeService/findByTypeCd");
        String mstMNoticeRemarks = String.format(Remarks.MST_MACHINE_TYPE_RECORD, machineTypeCd);
        mntMotionRecord.appendRemarks(mstMNoticeRemarks);
      }
    }
    // デバイスエッジマスタ
    MstDeviceEdge mstDeviceEdge = null;
    if (telegram instanceof AliveMoniTelegram) {
      // デバイスエッジ番号
      Integer deviceEdgeNo = mntMotionRecord.getDeviceEdgeNo();
      mstDeviceEdge = mstDeviceEdgeService.findByEdgeNoAndFacilityCd(deviceEdgeNo, facilityCd);
      if (mstDeviceEdge == null) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("例外発生：" + MNoticeError.GET_MST_DEVICE_EDGE);
        eventLogMessage.setSqlIdentification("(machineTypeCd=" + machineTypeCd + ",deviceEdgeNo = " + deviceEdgeNo + ")");
        eventLogMessage.setFacilityCd(facilityCd);
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,"mstDeviceEdgeService/findByEdgeNoAndFacilityCd");
        String mstMNoticeRemarks = String.format(Remarks.MST_DEVICE_EDGE_RECORD, deviceEdgeNo, facilityCd);
        mntMotionRecord.appendRemarks(mstMNoticeRemarks);
      }
    }
    // 緊急発報マスタから装置記録メッセージ、メールアドレス、宛先名称を取得する
    if (mstMNotice != null) {
      // 電文長
      int bufferLength = buffer.length;
      // 電文が日機装装置、NX通信のとき、緊急発報マスタから装置記録メッセージを取得する
      String machineMessage = mstMNotice.getMachineRecordMessage();
      if (bufferLength == TelegramLength.NIKKISO) {
        String message = "";
        if (machineMessage == null) {
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage("例外発生：" + MNoticeError.GET_MACHINE_RECORD_MESSAGE);
          eventLogMessage.setFacilityCd(facilityCd);
          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
          mntMotionRecord.setMNoticeStatus(MNoticeStatus.FAULT);
          String machineRecordMessageRemarks = String.format(Remarks.MST_M_NOTICE_VALUE, facilityCd, machineRecordCd);
          mntMotionRecord.appendRemarks(machineRecordMessageRemarks);
        } else {
          ArrayList<String> messageList = new ArrayList<>();
          messageList.add(machineMessage);
          messageList.addAll(((NikkisoMNoticeTelegram) telegram).getRecordingDatasAsHexString());
          message = getMessage(messageList);
        }
        // 装置記録メッセージを設定
        // 装置記録コードに外部警報が指定されていた場合、施設設定マスタを参照して装置記録メッセージを変更する
        mntMotionRecord.setMachineRecordMessage(convertExternalAlarmMessage(machineRecordCd, facilityCd, message));
      } else if (bufferLength == TelegramLength.NX || bufferLength == TelegramLength.ALIVE_MONI) {
        if (machineMessage == null) {
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage("例外発生：" + MNoticeError.GET_MACHINE_RECORD_MESSAGE);
          eventLogMessage.setFacilityCd(facilityCd);
          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
          mntMotionRecord.setMNoticeStatus(MNoticeStatus.FAULT);
          String machineRecordMessageRemarks = String.format(Remarks.MST_M_NOTICE_VALUE, facilityCd, machineRecordCd);
          mntMotionRecord.appendRemarks(machineRecordMessageRemarks);
          machineMessage = "";
        }
        // 装置記録メッセージを設定
        // 装置記録コードに外部警報が指定されていた場合、施設設定マスタを参照して装置記録メッセージを変更する
        mntMotionRecord.setMachineRecordMessage(convertExternalAlarmMessage(machineRecordCd, facilityCd, machineMessage));
      }
    }

    //add アラーム通知の場合、【再循環率測定】ログはフォーマット変換されていません 劉 start
    String machineRecordMessage = mntMotionRecordService.buildMachineRecordMessage(mntMotionRecord.getMachineRecordMessage(),
                                                                                   mntMotionRecord.getMachineRecordCd(),
                                                                                   mntMotionRecord.getMachineRecordAuxData());
    mntMotionRecord.setMachineRecordMessage(machineRecordMessage);
    //add アラーム通知の場合、【再循環率測定】ログはフォーマット変換されていません 劉 end

    // 装置状態管理情報の取得
    MntMachineState mntMachineState = mntMachineStateService.selectByKey(facilityCd, machineTypeCd, machineSerial);
    if (!(telegram instanceof AliveMoniTelegram)) {
      if (mntMachineState == null) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("例外発生：" + MNoticeError.GET_MNT_MACHINE_STATE);
        eventLogMessage.setSqlIdentification("(machineTypeCd=" + machineTypeCd + ",machineSerial = " + machineSerial + ",facilityCd=" + facilityCd +")");
        eventLogMessage.setFacilityCd(facilityCd);
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,"mntMachineStateService/selectByKey");
        mntMotionRecord.setMNoticeStatus(MNoticeStatus.FAULT);
        String mstMNoticeRemarks = String.format(Remarks.MNT_MACHINE_STATE_RECORD, facilityCd, machineTypeCd, machineSerial);
        mntMotionRecord.appendRemarks(mstMNoticeRemarks);
      }
    }

    EmailAddressAndName emailAddressAndName = mstAlarmNotificationService.getEmailAddressAndName(mntMotionRecord);
    // メールアドレスの取得
    mntMotionRecord.setEmailAddress(emailAddressAndName.getEmailAddress());
    // 宛先名称の取得
    mntMotionRecord.setEmailName(emailAddressAndName.getEmailName());

    // メールテンプレートの取得
    final String mailTemplate = getMailTemplate(mntMotionRecord, telegram, mstFacility);

    // [URL]変数を取り除いたメールテンプレートに対して取得したデータ値を埋め込む
    final String mailText = getMailBody(mailTemplate, mntMotionRecord, mstFacility, mstMachineType, mstMachine, mstDeviceEdge, mntMachineState);

    // メール本文格納（データベース登録用 "[URL]"除去）
    mntMotionRecord.setEmailText(mailText.replace("[URL]", ""));

    // メール本文格納（メール送信用 メール送信時に"[URL]"の置換が必要）
    mntMotionRecord.setSendEmailText(mailText);

    // メールに本文内のURL生成用に施設マスタのVPNセット設定を保持する
    mntMotionRecord.setFacilityUrlSetting(mstFacility.getVpnSet());
  }

  /**
   * 電文データと通信種別の整合性を確認します。
   *
   * @param mntMotionRecord 装置動作記録エンティティ
   * @param buffer 電文
   * @param comType 通信種別
   */
  private void validateComType(MntMotionRecord mntMotionRecord, byte[] buffer, Integer comType) {

    int bufferLength = buffer.length;

    switch (bufferLength) {
      case TelegramLength.NIKKISO:
        if (!Integer.valueOf(1).equals(comType)) {
          String mstMNoticeRemarks = String.format(Remarks.COM_TYPE, Hex.encodeHexString(buffer));
          mntMotionRecord.appendRemarks(mstMNoticeRemarks);
          mntMotionRecord.setMNoticeStatus(MNoticeStatus.FAULT);
          InvalidAlertFormatException e = new InvalidAlertFormatException(
            MNoticeError.COM_TYPE_NOT_MATCH_DATA + "電文データ:日機装装置, 通信種別:" + comType);
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage("例外発生：" + e.getMessage());
          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
          throw e;
        }
        break;

      case TelegramLength.NX:
        if (!Integer.valueOf(2).equals(comType)) {
          String mstMNoticeRemarks = String.format(Remarks.COM_TYPE, Hex.encodeHexString(buffer));
          mntMotionRecord.appendRemarks(mstMNoticeRemarks);
          mntMotionRecord.setMNoticeStatus(MNoticeStatus.FAULT);
          InvalidAlertFormatException e = new InvalidAlertFormatException(
            MNoticeError.COM_TYPE_NOT_MATCH_DATA + "電文データ:NX通信, 通信種別:" + comType);
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage("例外発生：" + e.getMessage());
          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
          throw e;
        }
        break;

      case TelegramLength.IKIKO:
        if (!Integer.valueOf(3).equals(comType)) {
          String mstMNoticeRemarks = String.format(Remarks.COM_TYPE, Hex.encodeHexString(buffer));
          mntMotionRecord.appendRemarks(mstMNoticeRemarks);
          mntMotionRecord.setMNoticeStatus(MNoticeStatus.FAULT);
          InvalidAlertFormatException e = new InvalidAlertFormatException(
            MNoticeError.COM_TYPE_NOT_MATCH_DATA + "電文データ:医器工通信, 通信種別:" + comType);
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage("例外発生：" + e.getMessage());
          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
          throw e;
        }
        break;
    }
  }

  /**
   * 補助データより、装置記録メッセージを作成します。
   *
   * @param paramList 補助データを保持した配列
   * @return 装置記録補助データより作成した装置記録メッセージ
   */
  private String getMessage(ArrayList<String> paramList) {

    int paramSize = 0;
    for (String param : paramList) {
      if (!isEmpty(param)) {
        paramSize++;
      }
    }
    boolean convertFlag = false;
    String[] type = new String[paramSize - 1];
    Object[] value = new Object[paramSize - 1];

    int i = 0;
    int n = 0;
    char[] charArray = paramList.get(0).toCharArray();
    // 装置記録メッセージの%~dを%~fに変換
    for (char ch : charArray) {
      if (ch == '.') {
        convertFlag = true;
      }
      if (ch == 'd') {
        type[n] = "D";
        if (convertFlag) {
          type[n] = "F";
          charArray[i] = 'f';
          convertFlag = false;
        }
        n++;
      }
      i++;
    }

    String message = new String();

    switch (paramSize - 1) {
      case 1:
        value[0] = getValue(type[0], paramList.get(1));
        message = String.format(String.valueOf(charArray), value[0]);
        break;
      case 2:
        value[0] = getValue(type[0], paramList.get(1));
        value[1] = getValue(type[1], paramList.get(2));
        message = String.format(String.valueOf(charArray), value[0], value[1]);
        break;
      case 3:
        value[0] = getValue(type[0], paramList.get(1));
        value[1] = getValue(type[1], paramList.get(2));
        value[2] = getValue(type[2], paramList.get(3));
        message = String.format(String.valueOf(charArray), value[0], value[1], value[2]);
        break;
      case 4:
        value[0] = getValue(type[0], paramList.get(1));
        value[1] = getValue(type[1], paramList.get(2));
        value[2] = getValue(type[2], paramList.get(3));
        value[3] = getValue(type[3], paramList.get(4));
        message = String.format(String.valueOf(charArray), value[0], value[1], value[2], value[3]);
        break;
    }
    return message;
  }

  private Object getValue(String type, String value) {
    if ("D".equals(type)) {
      return Integer.valueOf(value);
    } else {
      return Double.valueOf(value);
    }
  }

  /**
   * 施設マスタ、もしくはシステム設定より、メールテンプレートを取得します。
   *
   * @param mntMotionRecord 緊急発報管理エンティティ
   * @param telegram 構造体
   * @param mstFacility 施設マスタ
   * @return メールテンプレート
   */
  private String getMailTemplate(MntMotionRecord mntMotionRecord, MNoticeTelegram telegram, MstFacility mstFacility) {

    String mailTemplate = "";

    // 死活監視電文の場合
    if (telegram instanceof AliveMoniTelegram) {
      SysSystemDefine systemDefine = sysSystemDefineService.selectDefaultMail();
      if (systemDefine == null) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("例外発生：" + MNoticeError.GET_DEFAULT_MAIL_TEMPLATE);
        eventLogMessage.setFacilityCd(mstFacility.getFacilityCd());
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,"sysSystemDefineService/selectDefaultMail");
        mntMotionRecord.appendRemarks(Remarks.SYS_SYSTEM_DEFINE_RECORD);
        mntMotionRecord.setMNoticeStatus(MNoticeStatus.FAULT);
      } else {
        String jsonValue = systemDefine.getValue();
        mailTemplate = getAliveMoniMailTemplate(jsonValue);
        return mailTemplate;
      }
    }

    // 施設マスタよりメールテンプレートを取得
    if (mstFacility != null) {
      if (!isEmpty(mstFacility.getMNoticeMailTemplate())) {
        mailTemplate = mstFacility.getMNoticeMailTemplate();
        return mailTemplate;
      }
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("例外発生：" + MNoticeError.GET_MST_FACILITY);
      eventLogMessage.setFacilityCd(mstFacility.getFacilityCd());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      String facilityRemarks = String.format(Remarks.MST_FACILITY_VALUE, mntMotionRecord.getFacilityCd());
      mntMotionRecord.appendRemarks(facilityRemarks);
    }

    // メールテンプレートを取得できない場合、デフォルトメールテンプレートを取得
    SysSystemDefine systemDefine = sysSystemDefineService.selectDefaultMail();
    if (systemDefine == null) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("例外発生：" + MNoticeError.GET_DEFAULT_MAIL_TEMPLATE);
      eventLogMessage.setFacilityCd(mstFacility.getFacilityCd());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,"sysSystemDefineService/selectDefaultMail");
      mntMotionRecord.appendRemarks(Remarks.SYS_SYSTEM_DEFINE_RECORD);
      mntMotionRecord.setMNoticeStatus(MNoticeStatus.FAULT);
    } else {
      String jsonValue = systemDefine.getValue();
      mailTemplate = getDefaultMailTemplate(jsonValue);
    }
    return mailTemplate;
  }

  /**
   * デフォルトメールテンプレートを取得します。
   *
   * @param json Json形式のString型のメールテンプレート
   * @return デフォルトメールテンプレート
   */
  private String getDefaultMailTemplate(String json) {

    String mailTemplate = null;

    try {
      ObjectMapper mapper = new ObjectMapper();
      JsonNode root = mapper.readTree(json);
      mailTemplate = root.get("mail_template").asText();
    } catch (JacksonException ioe) {
      throw new IllegalStateException(ioe);
    }

    return mailTemplate;
  }

  /**
   * 死活監視アプリ用メールテンプレートを取得.
   *
   * @param json json形式のメールテンプレート
   * @return 死活監視アプリ用メールテンプレート
   */
  private String getAliveMoniMailTemplate(String json) {

    String mailTemplate = null;

    try {
      ObjectMapper mapper = new ObjectMapper();
      JsonNode root = mapper.readTree(json);
      mailTemplate = root.get("mail_alive_template").asText();
    } catch (JacksonException e) {
      throw new IllegalStateException(e);
    }

    return mailTemplate;
  }


  /**
   * メールテンプレートの変数に値を代入し、メール本文を作成します。
   *
   * @param mailText メールテンプレート
   * @param mntMotionRecord 装置動作記録エンティティ
   * @param mstFacility 施設マスタ
   * @param mstMachineType 型式マスタ
   * @param mstMachine 装置マスタ
   * @param mstDeviceEdge デバイスエッジマスタ
   * @param mntMachineState 装置状態管理エンティティ
   * @return メール本文
   */
  private String getMailBody(String mailText,
                             MntMotionRecord mntMotionRecord,
                             MstFacility mstFacility,
                             MstMachineType mstMachineType,
                             MstMachine mstMachine,
                             MstDeviceEdge mstDeviceEdge,
                             MntMachineState mntMachineState) {
    // 施設名の取得
    String facilityName = "";
    if (mstFacility != null) {
      facilityName = mstFacility.getFacilityName();
    }
    // 発生日時の取得
    String eventDate = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss").format(mntMotionRecord.getEventRegDate());
    // 装置記録コードの取得
    String machineRecordCd = mntMotionRecord.getMachineRecordCd();
    // 装置記録メッセージの取得
    String machineRecordMessage = mntMotionRecord.getMachineRecordMessage();
    // 形式の取得
    String machineType = "";
    if (mstMachineType != null) {
      machineType = mstMachineType.getMachineType();
    }
    // 装置名の取得
    String machineName = "";
    if (mstMachine != null) {
      if (mstMachine.getMachineName() == null) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("例外発生：" + MNoticeError.GET_MACHINE_NAME);
        eventLogMessage.setFacilityCd(mstFacility.getFacilityCd());
  	    logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
        String mstMachineValueRemarks = String.format(Remarks.MST_MACHINE_VALUE,
          mntMotionRecord.getMachineTypeCd(), mntMotionRecord.getMachineSerial(),
          mntMotionRecord.getFacilityCd());
        mntMotionRecord.appendRemarks(mstMachineValueRemarks);
      } else {
        machineName = mstMachine.getMachineName();
      }
    }
    // 製造番号の取得
    String machienSerial = mntMotionRecord.getMachineSerial();
    // 発報対象者名
    String emailName = mntMotionRecord.getEmailName();
    // メール本文を格納
    String mailbody = mailText;
    if (facilityName != null) {
      mailbody = mailText.replace("[施設名]", facilityName);
    }
    if (eventDate != null) {
      mailbody = mailbody.replace("[発生日時]", eventDate);
    }
    if (machineRecordCd != null) {
      mailbody = mailbody.replace("[装置記録コード]", machineRecordCd);
    }
    if (machineRecordMessage != null) {
      mailbody = mailbody.replace("[装置記録メッセージ]", machineRecordMessage);
    }
    if (machineType != null) {
      mailbody = mailbody.replace("[型式]", machineType);
    }
    if (machineName != null) {
      mailbody = mailbody.replace("[装置名]", machineName);
    }
    if (machienSerial != null) {
      mailbody = mailbody.replace("[製造番号]", machienSerial);
    }
    if (emailName != null) {
      mailbody = mailbody.replace("[発報対象者名]", emailName);
    }
    // デバイスエッジ番号
    String deviceEdgeNo = "";
    // デバイスエッジ名
    String deviceName = "";
    if (mstDeviceEdge != null) {
      // デバイスエッジマスタからデバイスエッジ番号取得
      deviceEdgeNo = mstDeviceEdge.getDeviceEdgeNo().toString();
      // デバイスエッジマスタからデバイスエッジ名称取得
      deviceName = mstDeviceEdge.getDeviceName();

      // "[URL]"不要のため除去する
      mailbody = mailbody.replace("[URL]", "");
    }
    // デバイスエッジ番号
    if (deviceEdgeNo != null) {
      mailbody = mailbody.replace("[デバイスエッジ番号]", deviceEdgeNo);
    }
    // デバイスエッジ名
    if (deviceName != null) {
      mailbody = mailbody.replace("[デバイスエッジ名]", deviceName);
    }
    // ベッド名
    if (mntMachineState != null) {
      String bedName = mntMachineState.getBedName();
      if (bedName != null) {
        mailbody = mailbody.replace("[ベッド名]", bedName);
      }
    }
    return mailbody;
  }

  /**
   * 引数のnullチェックを行います。
   *
   * @param value
   * @return 引数がnull、または文字列の大きさが0のときtrueを返す、それ以外のときfalseを返す。
   */
  private boolean isEmpty(String value) {
    return StringUtils.isEmpty(value);
  }

  /**
   * フィルタリングされた一覧画面へのURLを作成し返す.
   *
   * @param facilityCd 施設コード
   * @param machineTypeCd 型式コード
   * @param machineSerial 製造番号
   * @param isNikkisoUser {@code true}の場合、日機装施設コードのハッシュ値とする
   * @param facilityUrlSetting 施設設定のVPNセット設定
   * @return 画面へのURL
   */
  private String createFilteredUrl(String facilityCd, String machineTypeCd, String machineSerial, boolean isNikkisoUser, String facilityUrlSetting) {
    // 施設コードから施設コードハッシュ値を取得

    // URL情報のパラメータ
    final String nkkUrlPram = "%s&FUNC=00103&FACILITYCD=%s&MACHINETYPECD=%s&MACHINESERIAL=%s";
    final String urlPram = "%s&FUNC=00103&MACHINETYPECD=%s&MACHINESERIAL=%s";

    if (isNikkisoUser) {
      // 日機装ユーザーの場合はapplication.ymlに定義した施設コードを使用する
      String signInFacilityCd = ntssMNoticeProperties.getNikkisoFacilityCd();
      MstFacilityHash mstFacilityHash = mstFacilityHashDao.selectByFacilityCd(signInFacilityCd);
      if (mstFacilityHash == null) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("例外発生：" + "施設コードに紐付くハッシュ値が取得できません。");
        logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI,"mstFacilityHashDao/selectByFacilityCd");
        return "";
      }

      // システム設定 に定義されているURLと、パラメータを連結する
      List<String> urlList = getBaseUrl(facilityUrlSetting);
      String tmpUrl = urlList.get(0) + nkkUrlPram;
      // 必要なパラメータを埋め込む
      String formatUrl = String.format(tmpUrl, mstFacilityHash.getHashValue(), facilityCd, machineTypeCd, machineSerial);
      // 施設設定のVPNセット設定が 「CL証明書URLおよびVPN用URLを表示」の場合、改行して2つめのURLを表示する
      if (!isEmpty(urlList.get(1))) {
        String tmpUrl2 = String.format(urlList.get(1) + nkkUrlPram, mstFacilityHash.getHashValue(), facilityCd, machineTypeCd, machineSerial);
        formatUrl = formatUrl + "\r\n" + tmpUrl2;
      }
      return formatUrl;
    } else {
      String signInFacilityCd = facilityCd;
      MstFacilityHash mstFacilityHash = mstFacilityHashDao.selectByFacilityCd(signInFacilityCd);
      if (mstFacilityHash == null) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("例外発生：" + "施設コードに紐付くハッシュ値が取得できません。");
        logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI,"mstFacilityHashDao/selectByFacilityCd");
        return "";
      }

      // システム設定 に定義されているURLと、パラメータを連結する
      List<String> urlList = getBaseUrl(facilityUrlSetting);
      String tmpUrl = urlList.get(0) + urlPram;
      // 必要なパラメータを埋め込む
      String formatUrl = String.format(tmpUrl, mstFacilityHash.getHashValue(), machineTypeCd, machineSerial);
      // 施設設定のVPNセット設定が 「CL証明書URLおよびVPN用URLを表示」の場合、改行して2つめのURLを表示する
      if (!isEmpty(urlList.get(1))) {
        String tmpUrl2 = String.format(urlList.get(1) + urlPram, mstFacilityHash.getHashValue(), machineTypeCd, machineSerial);
        formatUrl = formatUrl + "\r\n" + tmpUrl2;
      }
      return formatUrl;
    }
  }

  /**
   * システム設定 の ログインURL設定から、施設設定のVPNセット設定に応じたURLを取得します。
   *
   * @param facilityUrlSetting 施設設定のVPNセット設定
   * @return 取得URLのリスト
   */
  private List<String> getBaseUrl(String facilityUrlSetting) {
    String urlKey1 = "";
    String urlKey2 = "";
    if ("1".equals(facilityUrlSetting)) {
      // 1：VPN用URLを表示
      urlKey1 = "urlVpn";
    } else if ("2".equals(facilityUrlSetting)) {
      // 2：CL証明書URLおよびVPN用URLを表示
      urlKey1 = "urlCL";
      urlKey2 = "urlVpn";
    } else if ("3".equals(facilityUrlSetting)) {
      // 3：CL証明書URLを表示
      urlKey1 = "urlCL";
    } else {
      // 初期値の「0」、又は空だった場合、0：CL証明書不要URLを表示
      urlKey1 = "url";
    }

    List<SysSystemDefine> loginUrl = sysSystemDefineDao.selectByCtlNo(4);
    String url1 = "";
    String url2 = "";
    if (loginUrl.size() >= 1) {
      String strJson = loginUrl.get(0).getValue();
      JSONObject objJson = new JSONObject(strJson);
      url1 = objJson.getString(urlKey1);
      if (!isEmpty(urlKey2)) {
        url2 = objJson.getString(urlKey2);
      }
    }
    List<String> rtnList = new ArrayList<>();
    rtnList.add(url1);
    rtnList.add(url2);
    return rtnList;
  }

  /**
   * 顧客側にメールが送られる場合、宛先に指定のアドレスを追加します。
   *
   * @param addressList アドレスリスト
   * @param mntMotionRecord 装置動作記録のEntity
   * @return 引数がnull、または文字列の大きさが0のときtrueを返す、それ以外のときfalseを返す。
   */
  private List<String> addAddress(List<String> nkkAddressList, List<String> genAddressList, MntMotionRecord mntMotionRecord) {
    if (!ObjectUtils.isEmpty(genAddressList)) {
      // 緊急発報送信先メーリングリストを取得
      String systemDefineAddress = sysSystemDefineService.selectNoticeMailAddress();
      if (systemDefineAddress == null) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("例外発生：" + MNoticeError.GET_DEFAULT_MAIL_TEMPLATE);
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,"sysSystemDefineService/selectNoticeMailAddress");
        return nkkAddressList;
      }
      boolean addFlg = true;
      // 宛先に指定のアドレスが設定されているか確認
      for (String address : nkkAddressList) {
        if (address.equals(systemDefineAddress)) {
          addFlg = false;
        }
      }
      if (addFlg) {
        nkkAddressList.add(systemDefineAddress);
      }
    }
    return nkkAddressList;
  }

  /**
   * システム設定でSESが有効でなければTrueを返す
   * @return true: SESを送らない  false: SESを送る
   */
  private boolean checkIsOnPremises() {

    String ses = null;
    try {
      Map<String, String> map = getLocalStoreAndStatus();
      ses = map.get("ses");

      return !ses.equals("on");
    } catch (Exception e) {
      // システム設定が取得できなかった場合はとりあえずクラウドとしてメール送信を試行してみる
      return false;
    }
  }


  /**
   * オンプレミス設定の取得
   * @return
   * @throws Exception
   */
  private Map<String, String> getLocalStoreAndStatus() throws Exception {
    String localStore = null;
    String status = null;
    String ses = null;
    SysSystemDefine data = sysSystemDefineDao.selectOnPremise(CoreConstant.SysSystemDefine.CTL_NO_ON_PREMISE);
    ObjectMapper objectMapper = new ObjectMapper();
    HashMap<String, String> onPremise = objectMapper.readValue(data.getValue(),
        new TypeReference<HashMap<String, String>>() {
        });
    localStore = onPremise.get("path");
    status = onPremise.get("status");
    ses = onPremise.get("ses");
    Map<String, String> mapResult = new HashMap<>();
    mapResult.put("localStore", localStore);
    mapResult.put("status", status);
    mapResult.put("ses", ses);
    return mapResult;
  }
}
