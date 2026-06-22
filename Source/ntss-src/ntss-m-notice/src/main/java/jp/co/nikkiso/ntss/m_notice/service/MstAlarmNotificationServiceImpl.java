package jp.co.nikkiso.ntss.m_notice.service;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.dao.MstAlarmNotificationDao;
import jp.co.nikkiso.ntss.core.dao.MstDestinationGroupDao;
import jp.co.nikkiso.ntss.core.dao.MstPersonalUserDao;
import jp.co.nikkiso.ntss.core.entity.MntMotionRecord;
import jp.co.nikkiso.ntss.core.entity.MstAlarmNotification;
import jp.co.nikkiso.ntss.core.entity.MstDestinationGroup;
import jp.co.nikkiso.ntss.m_notice.constant.MNoticeConstant.FlagType;

/**
 * 緊急発報マスタのService実装クラス.
 */
@Service
public class MstAlarmNotificationServiceImpl implements MstAlarmNotificationService {

  /**
   * 警報通知マスタのDaoインタフェース.
   */
  @Autowired
  private MstAlarmNotificationDao mstAlarmNotificationDao;

  /**
   * 送信先グループマスタのDaoインタフェース.
   */
  @Autowired
  private MstDestinationGroupDao mstDestinationGroupDao;

  /**
   * 利用者マスタのDaoインタフェース.
   */
  @Autowired
  private MstPersonalUserDao mstPersonalUserDao;

  /**
   * {@inheritDoc}
   */
  public EmailAddressAndName getEmailAddressAndName(MntMotionRecord mntMotionRecord) {

    // 送信スケジュールに該当する警報通知マスタを取得 (削除済み・非表示は除外)
    List<MstAlarmNotification> mstAlarmNotifications = mstAlarmNotificationDao
        .getAlarmNotificationByMNoticeTelegram(mntMotionRecord.getEventRegDate(), mntMotionRecord.getFacilityCd(),
            mntMotionRecord.getMachineRecordCd())
        .stream()
        .filter(e -> e.getIsDel().equals(FlagType.FLAG_OFF) && e.getIsDisp().equals(FlagType.FLAG_ON))
        .collect(Collectors.toList());

    // 送信先グループ一覧を取得 (削除済み・非表示は除外)
    List<MstDestinationGroup> mstDestinationGroups = mstDestinationGroupDao.selectAll().stream()
        .filter(e -> e.getIsDel().equals(FlagType.FLAG_OFF) && e.getIsDisp().equals(FlagType.FLAG_ON))
        .collect(Collectors.toList());

    List<String> mailAddresses = new ArrayList<>();
    List<String> mailNames = new ArrayList<>();

    // 該当する送信先グループマスタから対象者を抽出し、対象のメールアドレスを取得してリストを作成
    createSendAddressList(mailAddresses, mailNames, mntMotionRecord.getMachineRecordCd(), mstAlarmNotifications,
        mstDestinationGroups);

    // 戻り値にメールアドレスと送信先名を設定
    EmailAddressAndName returnValue = new EmailAddressAndName(
        String.join(",", mailAddresses.stream().distinct().collect(Collectors.toList())),
        String.join("、", mailNames.stream().distinct().collect(Collectors.toList())));

    return returnValue;

  }

  /**
   * 送信対象アドレスの作成.
   *
   * @param mailAddresses 送信先アドレスリスト
   * @param mailNames 送信者名リスト
   * @param machineRecord 対象装置記録
   * @param mstAlarmNotifications 警報通知マスタ
   * @param mstDestinationGroups 送信先グループマスタ
   *
   */
  private void createSendAddressList(List<String> mailAddresses, List<String> mailNames, String machineRecord,
      List<MstAlarmNotification> mstAlarmNotifications, List<MstDestinationGroup> mstDestinationGroups) {

    // 対象メールアドレスチェック用フォーマット
    String mailFormat = "^[A-Za-z0-9]{1}[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@{1}[a-zA-Z0-9-]+(?:\\.[a-zA-Z0-9-]+)*$";

    // 対象の装置記録レコードを含まれる送信先グループを抽出
    List<Long> destinationGroupCds = mstAlarmNotifications.stream().map(MstAlarmNotification::getDestinationGroupCd)
        .collect(Collectors.toList());

    // 該当するレコードの送信対象からアドレスを取得して対象リストを作成
    destinationGroupCds.forEach(destinationGroupCd -> {
      Optional<MstDestinationGroup> mstDestinationGroup = mstDestinationGroups.stream()
          .filter(m -> m.getDestinationGroupCd().equals(destinationGroupCd)).findFirst();

      if (!mstDestinationGroup.isPresent()) {
        return;
      }

      // 送信先が有効の場合は送信先を取得
      MstDestinationGroup.DestinationTarget destinationTarget = mstDestinationGroup.get().getDestinationTarget();

      final List<String> mailAddress1List = destinationTarget.getUsers().stream()
          .filter(user -> user.isAddress1Send())
          .filter(user -> {
            String addr = mstPersonalUserDao.selectById(user.getUserId()).getUserEmailAddress1();
            if (StringUtils.isEmpty(addr)) {
              return false;
            } else {
              return addr.matches(mailFormat);
            }
          })
          .map(user -> {
            return mstPersonalUserDao.selectById(user.getUserId()).getUserEmailAddress1();
          })
          .collect(Collectors.toList());

      final List<String> mailAddress2List = destinationTarget.getUsers().stream()
          .filter(user -> user.isAddress2Send())
          .filter(user -> {
            String addr = mstPersonalUserDao.selectById(user.getUserId()).getUserEmailAddress2();
            if (StringUtils.isEmpty(addr)) {
              return false;
            } else {
              return addr.matches(mailFormat);
            }
          })
          .map(user -> {
            return mstPersonalUserDao.selectById(user.getUserId()).getUserEmailAddress2();
          })
          .collect(Collectors.toList());

      final List<String> mailAddresses2 = Stream.concat(
          mailAddress1List.stream(),
          mailAddress2List.stream())
          .collect(Collectors.toList());
      mailAddresses.addAll(mailAddresses2);

      destinationTarget.getUsers().stream()
          .map(user -> mstPersonalUserDao.selectById(user.getUserId()).getUserType())
          .filter(UserType -> !UserType.toString().equals(CoreConstant.UserType.NIKKISO))
          .findAny()
          .ifPresent(userType -> mailNames.add(mstDestinationGroup.get().getDestinationGroupName()));
    });
  }

}
