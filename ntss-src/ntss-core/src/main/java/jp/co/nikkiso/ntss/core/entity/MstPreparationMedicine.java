package jp.co.nikkiso.ntss.core.entity;

import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.entityListener.MstPreparationMedicineEntityListener;
import lombok.Getter;
import lombok.Setter;

import java.sql.Timestamp;
/**
 * 調製薬剤マスタクラス
 */
@Entity(listener = MstPreparationMedicineEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_preparation_medicine")
@Getter
@Setter
public class MstPreparationMedicine extends BaseBlankEntity {

  /**
   * 調製薬剤コード
   */
  @Id
  private long preparationMedicineCd;
  /**
   * 施設コード
   */
  private String facilityCd;
  /**
   * 調製薬剤名
   */
  private String preparationMedicineName;
  /**
   * 省略調製薬剤名
   */
  private String preparationMedicineShortName;
  /**
   * 薬剤分類コード
   */
  private String classCd;
  /**
   * 単位
   */
  private String unit;
  /**
   * 指示単位
   */
  private String indUnit;
  /**
   * 薬剤セット数
   */
  private Short mediSetNum;
  /**
   * 有効成分
   */
  private Integer activeIngredient;
  /**
   * 容量
   */
  private Short capacity;
  /**
   * 投薬実施フラグ
   */
  private String mediAchFlg;
  /**
   * 薬剤情報
   */
  private String medicineInfo;
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
