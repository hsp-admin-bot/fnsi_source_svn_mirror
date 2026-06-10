package batch.entity;
import java.sql.Timestamp;

import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * 装置状態管理のEntity.
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mnt_machine_state")
@Getter
@Setter
public class MntMachineState extends BaseEntity{
  /**
   * 施設コード.
   */
  @Id
  private String facilityCd;
  /**
   * 型式コード.
   */
  @Id
  private String machineTypeCd;

  /**
   * 製造番号.
   */
  @Id
  private String machineSerial;

  public String getMachineSerial() {
    if (machineSerial != null) {
      return machineSerial.trim();
    }
    return machineSerial;
  }

  public void setMachineSerial(String machineSerial) {
    if (machineSerial != null) {
      this.machineSerial = machineSerial.trim();
    }
  }

  /**
   * 機種.
   */
  private String model;
  /**
   * 装置名.
   */
  private String machineName;
  /**
   * ベッドコード.
   */
  private Long bedCd;
  /**
   * ベッド名.
   */
  private String bedName;
  /**
   * 工程状態.
   */
  private String processState;
  /**
   * 緊急発報件数.
   */
  private Integer mNoticeCnt;
  /**
   * 予防保守件数.
   */
  private Integer preventiveMainteCnt;
  /**
   * 通信不良有無.
   */
  private Integer isPreventiveMainte;
  /**
   * 部品運転時間.
   */
  private String useTime;
  /**
   * 装置ステータス.
   */
  private Integer machineStatus;
  /**
   * 警報監視状態.
   */
  private String alarmMoni;
  /**
   * オンラインフラグ.
   */
  private String isOffline;
  /**
   * システムで管理する一意なオーダ番号.
   */
  private Long ordNo;
  /**
   * 次回透析オーダ番号.
   */
  private Long nextOrdNo;
  /**
   * システムで管理する一意な患者ID.
   */
  private Long patId;
  /**
   * 次患者ID.
   */
  private Long nextPatid;
  /**
   * 次患者クールCD.
   */
  private Long nextKurCd;
  /**
   * 透析開始予定日時.
   */
  private Timestamp startPlanDate;
  /**
   * 透析終了予定日時.
   */
  private Timestamp endPlanDate;
  /**
   * 前体重測定日時.
   */
  private Timestamp weighBeforeDate;
  /**
   * 条件送信日時.
   */
  private Timestamp condSendDate;
  /**
   * 条件確認日時.
   */
  private Timestamp condSetDate;
  /**
   * 透析開始日時.
   */
  private Timestamp startDate;
  /**
   * 透析終了日時.
   */
  private Timestamp endDate;

  /**
   * 後体重測定日時.
   */
  private Timestamp weighAfterDate;
  /**
   * 警報リスト
   */
  private String alarmList;
  /**
   * 登録日時
   */
  private Timestamp regDate;
  /**
   * 更新日時
   */
  private Timestamp upDate;
  /**
   * 患者確認済みフラグ.
   */
  private String isPatVerified;
  /**
   * 装置設定一時データ.
   */
  private String tmpDeviceSetInfo;
  /**
   * サービス対応件数.
   */
  private Integer serviceSupportCnt;
  /**
   * モニタデータ
   */
  private String  monitorData;

  @Override
  public String toString() {
    StringBuffer sb = new StringBuffer();
               sb.append(facilityCd==null ? "" : facilityCd).append(",")
                 .append(machineTypeCd==null ? "" : machineTypeCd).append(",")
                 // mod #10153,#10191,#10249 djy start
                 .append(machineSerial==null ? "" : machineSerial.replace(",","||@#$~%^&*||")).append(",")
                 // mod #10153,#10191,#10249 djy end
                 .append(model==null ? "" : model).append(",")
                 // mod #10153,#10191,#10249 djy start
                 .append(machineName==null ? "" : machineName.replace(",","||@#$~%^&*||")).append(",")
                 // mod #10153,#10191,#10249 djy end
                 .append(bedCd==null ? "" : bedCd).append(",")
                 // mod #10153,#10191,#10249 djy start
                 .append(bedName==null ? "" : bedName.replace(",","||@#$~%^&*||")).append(",")
                 // mod #10153,#10191,#10249 djy end
                       .append(regDate==null ? "" : regDate).append(",")
                       .append(upDate==null ? "" : upDate);
    return sb.toString();
  }
}

