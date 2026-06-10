package jp.co.nikkiso.ntss.admin_web.service;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.FlagType;
import jp.co.nikkiso.ntss.core.dao.MstAlarmNotificationDao;
import jp.co.nikkiso.ntss.core.dao.MstMNoticeDao;
import jp.co.nikkiso.ntss.core.dao.MstMachineRecordDao;
import jp.co.nikkiso.ntss.core.entity.MstAlarmNotification;
import jp.co.nikkiso.ntss.core.entity.MstMNotice;
import jp.co.nikkiso.ntss.core.entity.MstMachineRecord;

/**
 * 緊急発報マスタのService実装クラス.
 */
@Service
public class MaintenanceMNoticeServiceImpl implements MaintenanceMNoticeService {

  /**
   * 警報通知マスタのDaoインタフェース.
   */
  @Autowired
  private MstAlarmNotificationDao mstAlarmNotificationDao;

  /**
   * 装置記録マスタのDaoインタフェース.
   */
  @Autowired
  private MstMachineRecordDao mstMachineRecordDao;

  /**
   * 緊急発報マスタのDaoインタフェース.
   */
  @Autowired
  private MstMNoticeDao mstMNoticeDao;

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  public void createMstMNotice(List<String> targetFacilities) {

    // 対象施設分を作成
    targetFacilities.forEach(targetFacilityCd -> {

      // 担当施設に該当する一覧を取得 (削除済み・非表示は除外)
      List<MstAlarmNotification> mstAlarmNotifications = mstAlarmNotificationDao.selectAll().stream()
          .filter(e -> e.getDestinationFacilityCd() != null && e.getDestinationFacilityCd().equals(targetFacilityCd)
              && e.getIsDel().equals(FlagType.FLAG_OFF) && e.getIsDisp().equals(FlagType.FLAG_ON))
          .collect(Collectors.toList());

      List<MstMNotice> mstMNoticeRecords = new ArrayList<>();

      // 対象の警報通知マスタに含まれる装置記録を抽出
      List<String> machineRecords = getIncludeAlarmNotification(mstAlarmNotifications);

      machineRecords.forEach(machineRecord -> {
        // 追加する緊急発報マスタを作成
        mstMNoticeRecords.add(getMNoticeEntity(targetFacilityCd, machineRecord));
      });
      // 緊急発報マスタの作成
      insertToMstMNotice(mstMNoticeRecords, targetFacilityCd);

    });
  }

  /**
   * データ追加用の緊急発報マスタの作成.
   *
   * @param targetFacilityCd 対象施設コード
   * @param machineRecord 対象装置記録
   *
   */
  private MstMNotice getMNoticeEntity(String targetFacilityCd, String machineRecord) {

    MstMNotice addMNotice = new MstMNotice();

    addMNotice.setFacilityCd(targetFacilityCd);
    addMNotice.setMachineRecordCd(machineRecord);

    // 装置記録を取得
    Optional<MstMachineRecord> mstMachineRecord = Optional.ofNullable(mstMachineRecordDao.selectByFacilityCdAndCd(targetFacilityCd,machineRecord));
    if (mstMachineRecord.isPresent()) {
      addMNotice.setMachineRecordMessage(mstMachineRecord.get().getMachineRecordMessage());
    }

    return addMNotice;
  }

  /**
   * 指定された施設に含まれる装置記録を抽出.
   *
   * @param mstAlarmNotifications 警報通知マスタ
   * @return 処理対象の装置記録リスト
   */
  private List<String> getIncludeAlarmNotification(List<MstAlarmNotification> mstAlarmNotifications) {

    List<String> machineRecords = new ArrayList<>();

    // 対象施設に含まれる装置記録の一覧を作成
    mstAlarmNotifications.forEach(mstAlarmNotification -> {

      // 対象装置記録を取得
      MstAlarmNotification.TargetMachineRecord targetMachineRecord = mstAlarmNotification.getTargetMachineRecord();

      targetMachineRecord.getCds().forEach(cd -> {
        if (!machineRecords.contains(cd.getMachineRecordCd())) {
          machineRecords.add(cd.getMachineRecordCd());
        }
      });
    });

    return machineRecords;
  }

  /**
   * 緊急発報マスタの作成.
   *
   * @param mstMNoticeRecords マスタ定義データ
   * @param facilityCd 対象の施設コード
   */
  private void insertToMstMNotice(List<MstMNotice> mstMNoticeRecords, String facilityCd) {

    // 対象施設レコードを削除
    mstMNoticeDao.deleteByFacilityCd(facilityCd);

    // 作成したレコードを追加
    mstMNoticeRecords.forEach(e -> {
      mstMNoticeDao.insert(e);
    });
  }

}
