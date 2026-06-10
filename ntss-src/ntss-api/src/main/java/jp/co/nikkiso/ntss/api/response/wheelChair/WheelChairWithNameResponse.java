package jp.co.nikkiso.ntss.api.response.wheelChair;

import lombok.AllArgsConstructor;
import lombok.Data;

import java.sql.Timestamp;

//add #10632 装置設定画面の更新時にpat_main_historyがインサートされない 20240530 ztc start

/**
 * 車いす情報取得APIのResponseクラス.
 */
@AllArgsConstructor
@Data
public class WheelChairWithNameResponse {

  /**
   * 車いす管理コード
   */
  private Long wheelChairCd;
  /**
   * 施設コード
   */
  private String facilityCd;

  /**
   * FNW+で管理する施設内で一意な車いす管理コード
   */
  private String fnWheelChairCd;
  /**
   * 車いす名称
   */
  private String wheelChairName;

  /**
   * 車いす重量(g)
   */
  private Integer wheelChairWeight;
  /**
   * 車いす校正日
   */
  private Timestamp scaleDate;

  /**
   * 車いす校正者ID
   */
  private Long scaleUserId;
  /**
   * 個人所有フラグ
   */
  private String isPersonal;
  /**
   * 所有患者ID
   */
  private Long patId;
  /**
   * 表示フラグ
   */
  private String isDisp;
  /**
   *    削除フラグ
   */
  private String isDel;

  /**
   * 患者姓
   */
  private String patLastName;
  /**
   * 患者名
   */
  private String patFirstName;
}
//add #10632 装置設定画面の更新時にpat_main_historyがインサートされない 20240530 ztc end