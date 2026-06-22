package jp.co.nikkiso.ntss.device_edge.service.sms;

import java.util.ArrayList;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import jp.co.nikkiso.ntss.core.dao.MstAlarmNotificationDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilityDao;
import jp.co.nikkiso.ntss.core.entity.MstAlarmNotification;
import jp.co.nikkiso.ntss.device_edge.service.Utility.UtilityService;

/**
 * SMSサービス
 */
@Service
public class SmsServiceImpl implements SmsService {

  @Autowired
  private MstAlarmNotificationDao mstAlarmNotificationDao;
  @Autowired
  private MstFacilityDao mstFacilityDao;
  @Autowired
  private UtilityService utilityService;

  /**
   * {@inheritDoc}
   */
  @Override
  public String buildNotificationCdList(String destinationFacilityCd, String separator) {
    List<String> cdList = new ArrayList<>();
    // 警報通知マスタ主キーのリスト（通知先施設が一致し、かつ電話番号が設定済みのもの）
    for (MstAlarmNotification mst : mstAlarmNotificationDao.selectByDestinationFacilityCd(destinationFacilityCd)) {
      if (mst.getSmsTel() != null && mst.getSmsTel().length() > 0) {
        cdList.add(mst.getAlarmNotificationCd().toString());
      }
    }
    // セパレータで文字列連結して返す
    return String.join(separator, cdList);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public String buildNotificationConfig(Long alarmNotificationCd) {
    MstAlarmNotification mst = mstAlarmNotificationDao.selectByAlarmNotificationCd(alarmNotificationCd);
    if (mst == null) {
      return null;
    } else {
      StringBuilder sb = new StringBuilder();
      // 1行目：設定した施設コード[6桁] + 対象となる施設名[最大32文字] + LF
      // 施設コードは、送信先施設コードではなく施設コードなので、日機装施設の場合はnkknkk
      // 送信先施設名称はLFを除外、32文字まで。それ以上あるばあいは3点リーダー（…）を32文字目に使用して32文字
      sb.append(mst.getFacilityCd());
      int maxFacilityNameLength = 32;
      String facilityName = mstFacilityDao.selectNameByCd(mst.getDestinationFacilityCd());
      if (facilityName != null) {
        // 改行除外
        facilityName = facilityName.replaceAll("\r", "").replaceAll("\n", "");
        if (facilityName.length() > maxFacilityNameLength) {
          facilityName = facilityName.substring(0, maxFacilityNameLength - 1);
          facilityName += "…";
        }
        sb.append(facilityName);
      }
      sb.append("\n");

      // 2行目：日設定 + 月設定 + 火設定 + ... + 電話番号 + LF
      // ※曜日設定：　通知有無[0/1] + 終了日時翌日有無[0/1] + 開始時刻[HHmm] + 終了時刻[HHmm]
      // 時刻設定がNULLの場合は空白詰めとする
      String timeFormat = "%4s";
      sb
          .append(mst.getIsNoticeSun())
          .append(mst.getIsNextDaySun())
          .append(
              String.format(timeFormat, mst.getStartTimeSun() == null ? "" : mst.getStartTimeSun().replaceAll(":", "")))
          .append(String.format(timeFormat, mst.getEndTimeSun() == null ? "" : mst.getEndTimeSun().replaceAll(":", "")))
          .append(mst.getIsNoticeMon())
          .append(mst.getIsNextDayMon())
          .append(
              String.format(timeFormat, mst.getStartTimeMon() == null ? "" : mst.getStartTimeMon().replaceAll(":", "")))
          .append(String.format(timeFormat, mst.getEndTimeMon() == null ? "" : mst.getEndTimeMon().replaceAll(":", "")))
          .append(mst.getIsNoticeTue())
          .append(mst.getIsNextDayTue())
          .append(
              String.format(timeFormat, mst.getStartTimeTue() == null ? "" : mst.getStartTimeTue().replaceAll(":", "")))
          .append(String.format(timeFormat, mst.getEndTimeTue() == null ? "" : mst.getEndTimeTue().replaceAll(":", "")))
          .append(mst.getIsNoticeWed())
          .append(mst.getIsNextDayWed())
          .append(
              String.format(timeFormat, mst.getStartTimeWed() == null ? "" : mst.getStartTimeWed().replaceAll(":", "")))
          .append(String.format(timeFormat, mst.getEndTimeWed() == null ? "" : mst.getEndTimeWed().replaceAll(":", "")))
          .append(mst.getIsNoticeThu())
          .append(mst.getIsNextDayThu())
          .append(
              String.format(timeFormat, mst.getStartTimeThu() == null ? "" : mst.getStartTimeThu().replaceAll(":", "")))
          .append(String.format(timeFormat, mst.getEndTimeThu() == null ? "" : mst.getEndTimeThu().replaceAll(":", "")))
          .append(mst.getIsNoticeFri())
          .append(mst.getIsNextDayFri())
          .append(
              String.format(timeFormat, mst.getStartTimeFri() == null ? "" : mst.getStartTimeFri().replaceAll(":", "")))
          .append(String.format(timeFormat, mst.getEndTimeFri() == null ? "" : mst.getEndTimeFri().replaceAll(":", "")))
          .append(mst.getIsNoticeSat())
          .append(mst.getIsNextDaySat())
          .append(
              String.format(timeFormat, mst.getStartTimeSat() == null ? "" : mst.getStartTimeSat().replaceAll(":", "")))
          .append(String.format(timeFormat, mst.getEndTimeSat() == null ? "" : mst.getEndTimeSat().replaceAll(":", "")));

      // SMS通知先電話番号(国際番号付き)[12桁以上]は、設定電話番号の先頭1桁を削除して81を接頭付与する（国内限定）
      String smsTel = utilityService.personalInfoDecrypto(mst.getSmsTel());
      smsTel = smsTel.substring(1);
      sb.append("81").append(smsTel).append("\n");

      // 3行目以降：装置記録コード + LF
      if (mst.getTargetMachineRecord().getValue() != null && mst.getTargetMachineRecord().getValue().length() > 0) {
        for (MstAlarmNotification.TargetMachineRecordCd machineRecordCd : mst.getTargetMachineRecord().getCds()) {
          sb.append(machineRecordCd.getMachineRecordCd()).append("\n");
        }
      }

      return sb.toString();
    }
  }

}
