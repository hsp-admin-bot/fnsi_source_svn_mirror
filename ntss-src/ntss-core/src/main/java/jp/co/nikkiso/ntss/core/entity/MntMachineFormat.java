package jp.co.nikkiso.ntss.core.entity;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import java.sql.Timestamp;

/**
 * 装置状態管理のEntity.
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mnt_machine_state")
@Getter
@Setter
public class MntMachineFormat extends BaseEntity{

  /**
   * 施設コード.
   */
  private String facilityCd;

  /**
   * 型式コード.
   */
  private String machineTypeCd;

  /**
   * 製造番号.
   */
  private String machineSerial;
  //スペースを削除する 6901 関 start
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
  //スペースを削除する 6901 end
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
   * 透析開始日時.
   */
  private Timestamp startDate;

  /**
   * 透析終了日時.
   */
  private Timestamp endDate;

  /**
   * 前体重測定日時.
   */
  private Timestamp weighBeforeDate;

  /**
   * 後体重測定日時.
   */
  private Timestamp weighAfterDate;

  /**
   * 条件送信日時.
   */
  private Timestamp condSendDate;

  /**
   * 条件確認日時.
   */
  private Timestamp condSetDate;

  /**
   * 次回透析オーダ番号.
   */
  private Long nextOrdNo;

  /**
   * 警報リスト
   */
  private String alarmList;

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
  /**
   * 通信フォーマット
   */
  private String  comFormatCd;
}

