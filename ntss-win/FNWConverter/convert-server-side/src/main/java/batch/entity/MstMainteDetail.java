package batch.entity;

import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.Table;
import java.util.List;

/**
 * 日常・定期点検項目マスタ
 */
@Table(name = "mst_mainte_detail")
@Getter
@Setter
@Entity()
public class MstMainteDetail extends BaseEntity {

  private Long mainteDetailCd;

  private String fnMainteType;

  private String fnMainteDetailCd;

  private List<String> fnMainteDetailCdList;

  private String mainteContent1;

  private String iniText;

}
