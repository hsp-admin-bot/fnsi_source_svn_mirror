package batch.entity;

import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.Table;

import java.sql.Timestamp;

/**
 * 点検結果マスタ
 */
@Table(name = "mnt_mainte_main")
@Getter
@Setter
@Entity()
public class MntMainteMain extends BaseEntity {

  private Long mainteNo;

  private Long mainteLayoutCd;

  private Timestamp upDate;

  private Long convertId;
}
