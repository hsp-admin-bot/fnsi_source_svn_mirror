package jp.co.nikkiso.ntss.device_edge.util.VitalInfo;

import java.util.Date;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 *  バイタル項目クラス.
 */
@NoArgsConstructor
@Getter
@Setter
public class VitalInfoItem {

  /** 管理番号 */
  int ctlNo;
  /** 入力区分 */
  int inputClass;
  /** 血圧区分 */
  int BPCLASS;
  /** 発生日時 */
  Date occurDate;
  /** 血圧区分 */
  // String bpClass;
  /** 最高血圧 */
  String bpMax;
  /** 最低血圧 */
  String bpMin;
  /** 平均血圧 */
  String bpAve;
  /** 血糖値 */
  String bloodSugarLevel;
  /** 脈拍 */
  String pulse;
  /** 体温 */
  String temperature;

}
