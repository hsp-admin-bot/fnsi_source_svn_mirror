package jp.co.nikkiso.ntss.core.entity;

import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.entityListener.MstEquipmentEntityListener;
import lombok.Getter;
import lombok.Setter;

import java.sql.Timestamp;

/**
 * 医療材料クラス
 */
@Entity(listener = MstEquipmentEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_equipment")
@Getter
@Setter
public class MstEquipment extends BaseBlankEntity {

  /**
   * 医療材料コード
   */
  @Id
  private Integer equipmentCd;
  /**
   * 施設コード
   */
  private String facilityCd;
  /**
   * FNW+で管理する施設内の一意な医療材料コード
   */
  private String fnEquipmentCd;
  /**
   * 標準医療材料コード
   */
  private String standardEquipmentCd;
  /**
   * 治験フラグ
   */
  private String isTrial;
  /**
   * 医療材料名
   */
  private String equipmentName;
  /**
   * 省略医療材料名
   */
  private String equipmentShortName;
  /**
   * 医療材料分類コード
   */
  private Integer classCd;
  /**
   * 単位
   */
  private String unit;
  /**
   * 使用開始日
   */
  private String useStartDate;
  /**
   * 使用終了日
   */
  private String useEndDate;
  /**
   * 連携コード1
   */
  private String inHospitalCd_1;
  /**
   * 連携コード2
   */
  private String inHospitalCd_2;
  /**
   * 連携コード3
   */
  private String inHospitalCd_3;
  /**
   * 連携コード4
   */
  private String inHospitalCd_4;
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
