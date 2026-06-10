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
 * チェックリストマスタクラス
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_checklist")
@Getter
@Setter
public class MstChecklist extends BaseEntity {
  /**
   * チェックリストマスタコード
   */
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long checklistCd;
  /**
   * 施設コード
   */
  private String facilityCd;
  /**
   * チェックリスト設定
   */
  private String checklistSettings;
  /**
   * 表示フラグ
   */
  private String isDisp;
  /**
   * 削除フラグ
   */
  private String isDel;
}
