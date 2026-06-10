package jp.co.nikkiso.ntss.core.entity;

import jp.co.nikkiso.ntss.core.entity.entityListener.CommonEntityListener;
import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

import java.sql.Timestamp;
import java.math.BigDecimal;

/**
 * 薬剤セットクラス
 */
@Entity(listener = CommonEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_medicine_group")
@Getter
@Setter
public class MstMedicineGroup extends BaseBlankEntity {
  /**
   * 薬剤グループコード
   */
  @Id
  private Long medicineGroupCd;

  /**
   * 施設コード
   */
  private String facilityCd;

  /**
   * 薬剤グループ名
   */
  private String medicineGroupName;

  /**
   * 登録薬剤情報
   */
  private String regMedicineInfo;

  /**
   * 単位
   */
  private String medicineGroupUnit;

  /**
   * 週間投与フラグ
   */
  private String weekFlg;

  /**
   * グラフ上限
   */
  private BigDecimal graphUpper;

  /**
   * グラフ下限
   */
  private BigDecimal graphLower;

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
