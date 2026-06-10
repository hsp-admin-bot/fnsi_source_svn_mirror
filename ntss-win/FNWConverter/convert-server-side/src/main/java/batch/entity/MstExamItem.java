package batch.entity;

import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_exam_item")
@Getter
@Setter
public class MstExamItem extends BaseBlankEntity {
  @Id
  private Long exam_item_cd;
  private String exam_class;
  private String fn_exam_item_cd;
}
