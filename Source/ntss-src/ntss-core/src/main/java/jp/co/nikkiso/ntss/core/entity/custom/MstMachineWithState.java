package jp.co.nikkiso.ntss.core.entity.custom;

import java.sql.Timestamp;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * 装置一覧取得用.
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class MstMachineWithState {
  /**
   * 型式コード
   */
  private String machineTypeCd;

  /**
   * 製造番号
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
   * 施設コード
   */
  private String facilityCd;

  /**
   * 装置名
   */
  private String machineName;

  /**
   * ベッドコード
   */
  private String bedCd;
  /**
   * ベッド名
   */
  private String bedName;

  /**
   * 工程状態
   */
  public String processState;
  /**
   * 装置ステータス
   */
  public int machineStatus;
  /**
   * システムで管理する一意なオーダー番号
   */
  public long ordNo;
  /**
   * システムで管理する一意な患者ID
   */
  public String patId;
  /**
   * 前体重測定日時
   */
  private Timestamp weighBeforeDate;
  /**
   * 条件送信日時
   */
  private Timestamp condSendDate;
  /**
   * 条件確認日時
   */
  private Timestamp condSetDate;
  /**
   * 透析開始予定日時
   */
  private Timestamp startPlanDate;
  /**
   * 透析終了予定日時
   */
  private Timestamp endPlanDate;
  /**
   * 透析開始日時
   */
  private Timestamp startDate;
  /**
   * 透析終了日時
   */
  private Timestamp endDate;
  /**
   * 後体重測定日時
   */
  private Timestamp weighAfterDate;
  /**
   * 警報リスト
   */
  private String alarmList;

  /**
   * 院内表示患者ID
   */
  private String hospPatId;
  /**
   * 患者名
   */
  private String patName;
  /**
   * 患者名カナ
   */
  private String patNameKana;
  /**
   * 患者名アルファベット
   */
  private String patNameAlpha;
  /**
   * 患者性別
   */
  private int patSex;
  /**
   * 生年月日(YYYYMMDD)
   */
  private String patBirthday;
  /**
   * 血液型ABO
   */
  private int patBloodTypeAbo;
  /**
   * 血液型RH
   */
  private int patBloodTypeRh;
  /**
   * 入外区分
   */
  private int inOutClass;
  /**
   * 同姓同名
   */
  private String isSame;
  /**
   * 禁忌
   */
  private String tabooInfo;
  /**
   * 感染症有無
   */
  private String isInfect;
  /**
   * インプラント有無
   */
  private String isImplant;
  /**
   * 患者担当スタッフ情報
   */
  private String patChargeStaffInfo;

}
