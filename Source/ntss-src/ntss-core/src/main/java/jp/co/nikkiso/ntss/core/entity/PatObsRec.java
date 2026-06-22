package jp.co.nikkiso.ntss.core.entity;

import org.seasar.doma.Entity;
import org.seasar.doma.GeneratedValue;
import org.seasar.doma.GenerationType;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;
import java.sql.Timestamp;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.Getter;
import lombok.Setter;


/**
 * 観察記録情報クラス
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "pat_obs_rec")
@Getter
@Setter
public class PatObsRec extends BaseEntity{

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  /**
   * 管理番号
   */
  private Long obsRecNo;

  /**
   * システムで管理する一意な患者id
   */
  private Long patId;

  /**
   * 登録施設コード
   */
  private String facilityCd;

  /**
   * 起票日時
   */
  private Timestamp recDate;

  /**
   * 更新回数
   */
  private Short upCnt;

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
   * fnw+で管理する施設内の一意な観察記録用シーケンス番号
   */
  private Long fnSeqId;
}
