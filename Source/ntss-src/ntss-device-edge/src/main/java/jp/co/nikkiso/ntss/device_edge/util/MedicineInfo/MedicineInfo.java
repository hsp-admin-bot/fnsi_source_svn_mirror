package jp.co.nikkiso.ntss.device_edge.util.MedicineInfo;

import java.util.Date;

import lombok.Getter;
import lombok.Setter;

/**
 *  薬剤情報クラス.
 */
@Getter
@Setter
public class MedicineInfo {
  /** 識別番号 **/
  private int no;
  /** 薬剤分類コード **/
  private int classCd;
  /** 薬剤分類名 **/
  private String className;
  /** 分類区分 **/
  private String classType;
  /** 薬剤コード **/
  private int cd;
  /** 薬剤名 **/
  private String name;
  /** 省略薬剤名 **/
  private String shortName;
  /** 数量 **/
  private String amount;
  /** 単位 **/
  private String unit;
  /** 投与タイミングコード **/
  private int timingCd;
  /** 投与タイミング名 **/
  private String timingName;
  /** 手技コード **/
  private int procedureCd;
  /** 手技名 **/
  private String procedureName;
  /** コメント **/
  private String comment;
  /** 指示者コード **/
  private int indUserId;
  /** 指示者名(姓) **/
  private String indUserLastName;
  /** 指示者名(名) **/
  private String indUserFirstName;
  /** 更新者コード **/
  private int updUserId;
  /** 更新者名(姓) **/
  private String updUserLastName;
  /** 更新者名(名) **/
  private String updUserFirstName;
  /** 登録区分 **/
  private int inputClass;
  /** 編集可否フラグ **/
  private int isEditable;
  /** 連携オーダー番号 **/
  private Long copOrderNo;
  /** 投与実施フラグ **/
  private int effectFlg;
  /** 投与実施日時 **/
  private Date effectDate;
  /** 投与実施者コード **/
  private int effectUserId;
  /** 投与実施者名(姓) **/
  private String effectUserLastName;
  /** 投与実施者名(名) **/
  private String effectUserFirstName;

}
