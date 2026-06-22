package batch.entity;

import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.Table;
/**
 * 日常・定期点検項目グループマスタ
 */
@Table(name = "mst_mainte_category")
@Getter
@Setter
@Entity()
public class MstMainteCategory extends BaseEntity {

  private Long mainteCategoryCd;

  private String fnMainteType;

  private String fnMainteCategoryCd;

  private Long convertId;
}
