package jp.co.nikkiso.ntss.core.dao;

import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;
import org.seasar.doma.jdbc.Config;
import org.seasar.doma.jdbc.builder.SelectBuilder;

import jp.co.nikkiso.ntss.core.entity.MstAlarmNotification;

/**
 * マスタ定義のDaoインタフェース.
 */
@ConfigAutowireable
@Dao
public interface MstAlarmNotificationDao {

  /**
   * 警報通知マスタの情報を全件取得.
   *
   * @return 警報通知マスタのエンティティリスト
   */
  @Select
  List<MstAlarmNotification> selectAll();

  /**
   * 警報通知マスタの情報を取得.
   *
   * @param facilityCd 施設コード
   * @return 警報通知マスタのエンティティリスト
   */
  @Select
  List<MstAlarmNotification> selectByFacilityCd(String facilityCd);

  /**
   * 特定の警報通知マスタの情報を取得.
   *
   * @param alarmNotificationCd 警報通知コード
   * @return 警報通知マスタのエンティティ
   */
  @Select
  MstAlarmNotification selectByAlarmNotificationCd(Long alarmNotificationCd);

  /**
   * 特定の警報通知マスタの情報を取得(警報通知マスタ編集用).
   *
   * @param alarmNotificationCd 警報通知コード
   * @return 警報通知マスタのエンティティ
   */
  @Select
  MstAlarmNotification selectByAlarmNotificationCdForMstEdit(Long alarmNotificationCd);

  /**
   * 警報通知マスタの情報を取得.
   *
   * @param destinationFacilityCd 送信先施設コード
   * @return 警報通知マスタのエンティティリスト
   */
  @Select
  List<MstAlarmNotification> selectByDestinationFacilityCd(String destinationFacilityCd);

  /**
   * デバイスエッジ再接続(G005)がいずれかの時間に発報対象となっている警報通知マスタの情報を取得.
   *
   * @param destinationFacilityCd 送信先施設コード
   * @return 警報通知マスタのエンティティリスト
   */
  @Select
  List<MstAlarmNotification> selectDevEdgeReconnectAlarmByDestinationFacilityCd(String destinationFacilityCd);

  /**
   * 警報通知マスタからスケジュールに合致するレコードを取得.
   * @param eventRegDate イベント発生日時
   * @param facilityCd 施設コード
   * @param machineRecordCd 装置記録コード
   * @return 警報通知マスタのエンティティリスト
   */
  public default List<MstAlarmNotification> getAlarmNotificationByMNoticeTelegram(Timestamp eventRegDate,
      String facilityCd, String machineRecordCd) {

    // 曜日の定義
    String dayOfWeekDefine[][] = { { "mon", "sun" }, { "tue", "mon" }, { "wed", "tue" }, { "thu", "wed" },
        { "fri", "thu" }, { "sat", "fri" }, { "sun", "sat" } };

    int eventDateOfWeek = eventRegDate.toLocalDateTime().getDayOfWeek().getValue();
    String today = dayOfWeekDefine[eventDateOfWeek - 1][0];
    String yesterday = dayOfWeekDefine[eventDateOfWeek - 1][1];

    String eventRegTime = new SimpleDateFormat("HH:mm").format(eventRegDate);

    SelectBuilder builder = SelectBuilder.newInstance(Config.get(this));
    builder.sql("select ")
        .sql("alarm_notification_cd").sql(",")
        .sql("facility_cd").sql(",")
        .sql("alarm_notification_name").sql(",")
        .sql("destination_facility_cd").sql(",")
        .sql("destination_group_cd").sql(",")
        .sql("target_machine_record").sql(",")
        .sql("is_disp").sql(",")
        .sql("is_del").sql(",")
        .sql("reg_date").sql(",")
        .sql("up_date").sql(",")
        .sql("is_notice_mon").sql(",")
        .sql("start_time_mon").sql(",")
        .sql("end_time_mon").sql(",")
        .sql("is_next_day_mon").sql(",")
        .sql("is_notice_tue").sql(",")
        .sql("start_time_tue").sql(",")
        .sql("end_time_tue").sql(",")
        .sql("is_next_day_tue").sql(",")
        .sql("is_notice_wed").sql(",")
        .sql("start_time_wed").sql(",")
        .sql("end_time_wed").sql(",")
        .sql("is_next_day_wed").sql(",")
        .sql("is_notice_thu").sql(",")
        .sql("start_time_thu").sql(",")
        .sql("end_time_thu").sql(",")
        .sql("is_next_day_thu").sql(",")
        .sql("is_notice_fri").sql(",")
        .sql("start_time_fri").sql(",")
        .sql("end_time_fri").sql(",")
        .sql("is_next_day_fri").sql(",")
        .sql("is_notice_sat").sql(",")
        .sql("start_time_sat").sql(",")
        .sql("end_time_sat").sql(",")
        .sql("is_next_day_sat").sql(",")
        .sql("is_notice_sun").sql(",")
        .sql("start_time_sun").sql(",")
        .sql("end_time_sun").sql(",")
        .sql("is_next_day_sun").sql(",")
        .sql("sms_tel ")
        .sql("from ")
        .sql("mst_alarm_notification ")
        .sql("where ")
        .sql("destination_facility_cd= ").param(String.class, facilityCd)
        .sql(" and target_machine_record @> ")
        .param(String.class, "{\"cds\": [{\"machine_record_cd\": \"" + machineRecordCd + "\"}]}")
        .sql(" and ")
        .sql("( ")
        .sql("  ( ")
        .sql("    is_notice_" + today + " = '1' and ")
        .sql("    ( ")
        .sql("      (start_time_" + today + " is null) or ")
        .sql("      (start_time_" + today + " <= ").param(String.class, eventRegTime)
        .sql("        and end_time_" + today + " >= ").param(String.class, eventRegTime)
        .sql("        and is_next_day_" + today + " = '0') or ")
        .sql("      (start_time_" + today + " <= ").param(String.class, eventRegTime)
        .sql("        and is_next_day_" + today + " = '1') ")
        .sql("    ) ")
        .sql("  ) or")
        .sql("  ( ")
        .sql("    is_notice_" + yesterday + " = '1' and ")
        .sql("    is_next_day_" + yesterday + " = '1' and ")
        .sql("    end_time_" + yesterday + " >= ").param(String.class, eventRegTime)
        .sql("  ) ")
        .sql(") ")
        .sql("order by ")
        .sql("  alarm_notification_cd ");

    return builder.getEntityResultList(MstAlarmNotification.class);
  }
}
