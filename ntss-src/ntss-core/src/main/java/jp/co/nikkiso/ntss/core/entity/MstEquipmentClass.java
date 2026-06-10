package jp.co.nikkiso.ntss.core.entity;

import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.entityListener.MstEquipmentClassEntityListener;
import lombok.Getter;
import lombok.Setter;

import java.sql.Timestamp;
/**
 * 医療材料分類クラス
 */
@Entity(listener = MstEquipmentClassEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_equipment_class")
@Getter
@Setter
public class MstEquipmentClass extends BaseBlankEntity {
  /**
   * 分類コード
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
  private Double classType;
  /**
   * 連携コード1
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
   * 編集可否フラグ
   */
  private String isEditable;
  /**
   * 登録日時
   */
  private Timestamp regDate;
  /**
   * 更新日時
   */
  private Timestamp upDate;
}
