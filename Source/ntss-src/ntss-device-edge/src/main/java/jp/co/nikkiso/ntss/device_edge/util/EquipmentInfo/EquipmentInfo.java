package jp.co.nikkiso.ntss.device_edge.util.EquipmentInfo;

import lombok.Getter;
import lombok.Setter;

/**
 *  医療材料情報クラス.
 */
@Getter
@Setter
public class EquipmentInfo {
  /** 医療材料分類コード **/
  private Integer classCd;
  /** 医療材料分類名 **/
  private String className;
  /** 分類区分 **/
  private String classType;
  /** 医療材料コード **/
  private Integer cd;
  /** 医療材料名 **/
  private String name;
  /** 省略医療材料名 **/
  private String shortName;
  // del 10310 needle _ typeの使用を削除するには gjn start
  /** 穿刺針区分 **/
//  private String needleType;
  // del 10310 needle _ typeの使用を削除するには gjn end
  /** 数量 **/
  private String amount;
  /** 単位 **/
  private String unit;
  /** 指示者コード **/
  private Integer indUserId;
  /** 指示者名(姓) **/
  private String indUserLastName;
  /** 指示者名(名) **/
  private String indUserFirstName;
  /** 更新者コード **/
  private Integer updUserId;
  /** 更新者名(姓) **/
  private String updUserLastName;
  /** 更新者名(名) **/
  private String updUserFirstName;
  /** 登録区分 **/
  private Integer inputClass;
  /** 編集可否フラグ **/
  private Integer isEditable;
  /** 連携オーダー番号 **/
  private Long copOrderNo;

}
