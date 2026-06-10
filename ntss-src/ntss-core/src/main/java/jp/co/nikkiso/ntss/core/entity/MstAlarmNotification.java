package jp.co.nikkiso.ntss.core.entity;

import java.io.IOException;
import java.util.List;

import org.modelmapper.ModelMapper;
import org.seasar.doma.Domain;
import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_alarm_notification")
@Getter
@Setter
public class MstAlarmNotification extends BaseEntity {

  /**
   * 装置記録コード1件を表すクラス
   */
  @Getter
  @Setter
  public static class TargetMachineRecordCd {
    @JsonProperty("machine_record_cd")
    private String machineRecordCd;
  }

  /**
   * 対象装置記録
   */
  @Domain(valueType = String.class)
  @Getter
  @Setter
  @NoArgsConstructor
  public static class TargetMachineRecord {
    /** ObjectMapper */
    private static ObjectMapper objectMapper = new ObjectMapper();

    /** ModelMapper */
    private static ModelMapper modelMapper = new ModelMapper();

    /**
     * 対象装置記録コード
     */
    @JsonProperty("cds")
    private List<TargetMachineRecordCd> cds;

    /**
     * コンストラクタ.
     *
     * @param value JSON文字列
     */
    @SuppressWarnings("serial")
    public TargetMachineRecord(String value) {
      try {
        TargetMachineRecord obj
          = objectMapper.readValue(value, TargetMachineRecord.class);
        modelMapper.map(obj, this);
      } catch (IOException e) {
        throw new NtssException("対象装置記録の設定内容が不正です") {
        };
      }
    }

    /**
     * 基本型の値を返す.
     *
     * @return 基本型の値
     */
    @JsonIgnore
    public String getValue() {
      try {
        return objectMapper.writeValueAsString(this);
      } catch (JsonProcessingException e) {
        return null;
      }
    }
  }

  /**
   * 警報通知コード
   */
  @Id
  private Long alarmNotificationCd;

  /**
   * 施設コード（この警報通知を作成した施設のコード）
   */
  private String facilityCd;

  /**
   * 警報通知名
   */
  private String alarmNotificationName;

  /**
   * 送信先施設コード
   */
  private String destinationFacilityCd;

  /**
   * 送信先グループコード
   */
  private Long destinationGroupCd;

  /**
   * 対象装置記録
   */
  private TargetMachineRecord targetMachineRecord;

  /**
   * 表示フラグ（0: 非表示 1: 表示）
   */
  private String isDisp;

  /**
   * 削除フラグ（0:通常 1:削除）
   */
  private String isDel;

  /**
   * 通知フラグ(月)（0:通知しない 1:通知する）
   */
  private String isNoticeMon;

  /**
   * 開始時間(月)
   */
  private String startTimeMon;

  /**
   * 終了時間(月)
   */
  private String endTimeMon;

  /**
   * 翌日フラグ(月)（0:当日 1:翌日）
   */
  private String isNextDayMon;

  /**
   * 通知フラグ(火)（0:通知しない 1:通知する）
   */
  private String isNoticeTue;

  /**
   * 開始時間(火)
   */
  private String startTimeTue;

  /**
   * 終了時間(火)
   */
  private String endTimeTue;

  /**
   * 翌日フラグ(火)（0:当日 1:翌日）
   */
  private String isNextDayTue;

  /**
   * 通知フラグ(水)（0:通知しない 1:通知する）
   */
  private String isNoticeWed;

  /**
   * 開始時間(水)
   */
  private String startTimeWed;

  /**
   * 終了時間(水)
   */
  private String endTimeWed;

  /**
   * 翌日フラグ(水)（0:当日 1:翌日）
   */
  private String isNextDayWed;

  /**
   * 通知フラグ(木)（0:通知しない 1:通知する）
   */
  private String isNoticeThu;

  /**
   * 開始時間(木)
   */
  private String startTimeThu;

  /**
   * 終了時間(木)
   */
  private String endTimeThu;

  /**
   * 翌日フラグ(木)（0:当日 1:翌日）
   */
  private String isNextDayThu;

  /**
   * 通知フラグ(金)（0:通知しない 1:通知する）
   */
  private String isNoticeFri;

  /**
   * 開始時間(金)
   */
  private String startTimeFri;

  /**
   * 終了時間(金)
   */
  private String endTimeFri;

  /**
   * 翌日フラグ(金)（0:当日 1:翌日）
   */
  private String isNextDayFri;

  /**
   * 通知フラグ(土)（0:通知しない 1:通知する）
   */
  private String isNoticeSat;

  /**
   * 開始時間(土)
   */
  private String startTimeSat;

  /**
   * 終了時間(土)
   */
  private String endTimeSat;

  /**
   * 翌日フラグ(土)（0:当日 1:翌日）
   */
  private String isNextDaySat;

  /**
   * 通知フラグ(日)（0:通知しない 1:通知する）
   */
  private String isNoticeSun;

  /**
   * 開始時間(日)
   */
  private String startTimeSun;

  /**
   * 終了時間(日)
   */
  private String endTimeSun;

  /**
   * 翌日フラグ(日)（0:当日 1:翌日）
   */
  private String isNextDaySun;

  /**
   * SMS通知先電話番号
   */
  private String smsTel;
}
