package jp.co.nikkiso.ntss.admin_web.response.facilities;

import lombok.AllArgsConstructor;

import java.sql.Timestamp;

/**
 * 稼働ビューア施設一覧の施設1件を表すクラス.
 */
@AllArgsConstructor
public class Facility {

  /**
   * 施設コード.
   */
  public String facilityCd;

  /**
   * 部署符号.
   */
  public String departmentCd;

  /**
   * 都道府県コード.
   */
  public String prefecturesCd;

  /**
   * 都道府県名.
   */
  public String prefecuturesName;

  /**
   * 施設名.
   */
  public String facilityName;

  /**
   * 緊急発報件数.
   */
  public int mNoticeCnt;

  /**
   * 予防保守件数.
   */
  public int preventiveCnt;

  /**
   * 通信不良件数.
   */
  public int comProblemCnt;

  /**
   * 施設カナ名
   */
  public String facilityNameKana;

  /**
   * サービス対応件数.
   */
  public int serviceSupportCnt;

  /**
   * 最大イベント発生日時.
   */
  public Timestamp maxEventRegDate;
}
