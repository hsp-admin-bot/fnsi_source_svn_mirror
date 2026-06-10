package jp.co.nikkiso.ntss.core.entity;

import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.entityListener.MstEquipmentSetEntityListener;
import lombok.Getter;
import lombok.Setter;

import java.sql.Timestamp;
/**
 * 医療材料セットクラス
 */
@Entity(listener = MstEquipmentSetEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_equipment_set")
@Getter
@Setter
public class MstEquipmentSet extends BaseBlankEntity {
  /**
   * 医療材料セットコード
   */
  @Id
  private Integer equipmentSetCd;
  /**
   * 施設コード
   */
  private String facilityCd;
  /**
   * 医療材料セット名
   */
  private String equipmentSetName;
  /**
   * 省略医療材料セット名
   */
  private String equipmentSetShortName;
  /**
   * セット情報
   */
  private String setInfo;
  /**
   * 連携コード1
   */
  private String inHospitalCd_1;
  /**
   * 連携コード2
   */
  private String inHospitalCd_2;
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
