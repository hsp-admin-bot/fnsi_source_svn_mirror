package jp.co.nikkiso.ntss.core.entity.custom;

import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.jdbc.entity.NamingType;
import java.sql.Timestamp;

import lombok.Getter;
import lombok.Setter;

/**
 * 患者イベント情報クラス
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class PatObsRecView {

  @Id
  /**
   * 管理番号
   */
  private Integer obsRecNo;

  /**
   * システムで管理する一意な患者id
   */
  private Long patId;

  /**
   * 施設コード
   */
  private String facilityCd;

  /**
   * 起票日時
   */
  private Timestamp recDate;

  /**
   * 起票日(表示用)
   */
  private String viewRecDate;

  /**
   * 起票時(表示用)
   */
  private String viewRecTime;
  /**
   * 更新回数
   */
  private Integer upCnt;

  /**
   * 種別情報
   */
  private String kindInfo;

  /**
   * 起票者情報
   */
  private String regStaffInfo;

  /**
   * 編集者情報
   */
  private String upStaffInfo;

  /**
   * 観察記録情報
   */
  private String obsRecInfo;

  /**
   * 掲示板との連動管理番号
   */
  private Long bbsCtlNo;

  /**
   * システムで管理する一意なオーダー番号
   */
  private Long ordNo;

  /**
   * 最新フラグ
   */
  private String isNewest;

  /**
   * 削除フラグ
   */
  private String isDel;

  /**
   * 更新日時(表示用)
   */
  private String viewUpDate;

  /**
   * fnw+で管理する施設内の一意な観察記録用シーケンス番号
   */
  private Long fnSeqId;

}
