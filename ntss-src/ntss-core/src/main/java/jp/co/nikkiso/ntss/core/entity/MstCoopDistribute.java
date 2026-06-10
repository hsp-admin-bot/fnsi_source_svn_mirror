package jp.co.nikkiso.ntss.core.entity;

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
 * 連携電文配信マスタEntity
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_coop_distribute")
@Getter
@Setter
public class MstCoopDistribute extends BaseEntity {
  /** 管理番号 */
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long ctlNo;

  /** 施設コード */
  private String facilityCd;

  /** 電文種別 */
  private String coopCd;

  /** 付帯情報（電文） */
  private String coopCdIndex;

  /** 向き（送受信） */
  private String direction;

  /** 対応ベンダー名 */
  private String coopVender;

  /** 説明 */
  private String description;

  /** 編集可否フラグ */
  private String isEditable;

  /** 配信設定 */
  private String distributeSetting;

  /** 表示フラグ */
  private String isDisp;

  /** 削除フラグ */
  private String isDel;

  /** 操作者ID */
  private Integer userId;

// add 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
  /** 連携版番号 */
  private String coopVersion;
// add 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
}
