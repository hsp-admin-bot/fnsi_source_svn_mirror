package jp.co.nikkiso.ntss.core.entity;

import org.seasar.doma.Column;
import org.seasar.doma.Entity;
import org.seasar.doma.GeneratedValue;
import org.seasar.doma.GenerationType;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.Getter;
import lombok.Setter;

/**
 * 患者連携情報クラス
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "pat_coop_detail")
@Getter
@Setter
public class PatCoopDetail extends BaseEntity {
  /**
   * 管理番号
   */
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long coopSaveNo;

  /**
   * 施設コード
   */
  private String facilityCd;

  /**
   * 患者番号
   */
  private Long patId;

  /**
   * 連携情報カラム1
   */
  @Column(name="save_1")
  private String save1;

  /**
   * 連携情報カラム2
   */
  @Column(name="save_2")
  private String save2;

  /**
   * 連携情報カラム3
   */
  @Column(name="save_3")
  private String save3;

  /**
   * 連携情報カラム4
   */
  @Column(name="save_4")
  private String save4;

  /**
   * 連携情報カラム5
   */
  @Column(name="save_5")
  private String save5;

  /**
   * 連携情報カラム6
   */
  @Column(name="save_6")
  private String save6;

  /**
   * 連携情報カラム7
   */
  @Column(name="save_7")
  private String save7;

  /**
   * 連携情報カラム8
   */
  @Column(name="save_8")
  private String save8;

  /**
   * 連携情報カラム9
   */
  @Column(name="save_9")
  private String save9;

  /**
   * 連携情報カラム10
   */
  @Column(name="save_10")
  private String save10;

  /**
   * 表示フラグ
   */
  private String isDisp;

  /**
   * 削除フラグ
   */
  private String isDel;

  /**
   * 操作者ID
   */
  private Long userId;

// add 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
  /** 連携版番号 */
  private String coopVersion;
// add 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
}
