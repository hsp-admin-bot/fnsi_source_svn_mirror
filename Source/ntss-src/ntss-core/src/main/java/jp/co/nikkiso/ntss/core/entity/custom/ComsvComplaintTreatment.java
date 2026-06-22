package jp.co.nikkiso.ntss.core.entity.custom;

import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.jdbc.entity.NamingType;

/**
 * 通信サーバ用愁訴処置クラス
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class ComsvComplaintTreatment {

  @Id
  /**
   * システムで管理する一意なオーダ番号
   */
  private Long ordNo;

  /**
   * 愁訴情報
   */
  private String rstComplaintInfo;

  /**
   * 愁訴処置情報
   */
  private String rstTreatmentInfo;

  /**
   * 愁訴処置者情報
   */
  private String rstTreatStaffInfo;

}
