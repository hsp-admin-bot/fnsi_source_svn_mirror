package jp.co.nikkiso.ntss.core.entity;

import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.entityListener.MstMedicineSetEntityListener;
import lombok.Getter;
import lombok.Setter;

import java.sql.Timestamp;
/**
 * 薬剤セットクラス
 */
@Entity(listener = MstMedicineSetEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_medicine_set")
@Getter
@Setter
public class MstMedicineSet extends BaseBlankEntity {
  /**
   * 薬剤セットコード
   */
  @Id
  private Integer medicineSetCd;
  /**
   * 施設コード
   */
  private String facilityCd;
  /**
   * 薬剤セット名
   */
  private String medicineSetName;
  /**
   * 省略薬剤セット名
   */
  private String medicineSetShortName;
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
