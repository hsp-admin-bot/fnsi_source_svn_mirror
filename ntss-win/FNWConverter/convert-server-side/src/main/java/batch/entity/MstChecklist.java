package batch.entity;

import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;

/**
 * チェックリストマスタクラス
 */
@Entity
@Table(name = "mst_checklist")
@Getter
@Setter
public class MstChecklist extends BaseEntity {
  /**
   * チェックリストマスタコード
   */
  @Id
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
