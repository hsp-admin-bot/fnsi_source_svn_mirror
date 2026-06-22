package batch.entity;

import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;

import java.sql.Timestamp;

/**
 * 医療材料分類マスタクラス
 */
@Entity
@Table(name = "mst_equipment_class")
@Getter
@Setter
public class MstEquipmentClass extends BaseBlankEntity {

  /**
   * 医療材料分類コード
   */
  @Id
  private Integer classCd;
  /**
   * 施設コード
   */
  private String facilityCd;
  /**
   * FNW+で管理する施設内の一意な分類コード
   */
  private String fnClassCd;
  /**
   * 分類名称
   */
  private String className;
  /**
   * 分類区分
   */
  private Integer classType;
  /**
   * 院内コード1
   */
  private String inHospitalCd_1;
  /**
   * 表示フラグ
   */
  private String isDisp;
  /**
   * 削除フラグ
   */
  private String isDel;
  /**
   * 登録日時
   */
  private Timestamp regDate;
  /**
   * 更新日時
   */
  private Timestamp upDate;
}
