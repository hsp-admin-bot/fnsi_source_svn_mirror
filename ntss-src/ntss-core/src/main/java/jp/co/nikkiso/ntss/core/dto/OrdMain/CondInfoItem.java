package jp.co.nikkiso.ntss.core.dto.OrdMain;

import lombok.Data;

@Data
public class CondInfoItem {
  /**
   * 設定値
   */
  private String value;
  /**
   * 翻訳1
   */
  private String valueName1;
  /**
   * 翻訳2
   */
  private String valueName2;
  /**
   * 翻訳3
   */
  private String valueName3;
  /**
   * 翻訳4
   */
  private String valueName4;
  /**
   * 翻訳5
   */
  private String valueName5;
  /**
   * 翻訳6
   */
  private String valueName6;
  /**
   * 翻訳7
   */
  private String valueName7;
  /**
   * 翻訳8
   */
  private String valueName8;
  /**
   * 翻訳9
   */
  private String valueName9;
  /**
   * 翻訳10
   */
  private String valueName10;
  /**
   * 単位
   */
  private String unit;
  /**
   * 薬剤区分
   */
  private Integer medicineType;
  /**
   * 指示者コード
   */
  private Long indUserId;
  /**
   * 指示者名_姓
   */
  private String indUserLastName;
  /**
   * 指示者名_名
   */
  private String indUserFirstName;
  /**
   * 更新者コード
   */
  private Long updUserId;
  /**
   * 更新者名_姓
   */
  private String updUserLastName;
  /**
   * 更新者名_名
   */
  private String updUserFirstName;
  /**
   * 登録区分
   */
  private Integer inputClass;
  /**
   * 編集可否フラグ
   */
  private String isEditable;
  /**
   * 連携オーダ番号
   */
  private String copOrderNo;

}
