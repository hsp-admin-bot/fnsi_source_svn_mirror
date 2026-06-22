package jp.co.nikkiso.ntss.core.entity;

import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;
import java.math.BigDecimal;


import jp.co.nikkiso.ntss.core.entity.entityListener.MstMedicineMixEntityListener;
import lombok.Getter;
import lombok.Setter;

import java.sql.Timestamp;
/**
 * 調製薬剤マスタクラス
 */
@Entity(listener = MstMedicineMixEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_medicine_mix")
@Getter
@Setter
public class MstMedicineMix extends BaseBlankEntity {

  /**
   * 調製薬剤コード
   */
  @Id
  private Integer medicineMixCd;
  /**
   * 施設コード
   */
  private String facilityCd;
  /**
   * 調製薬剤名
   */
  private String medicineMixName;
  /**
   * 省略調製薬剤名
   */
  private String medicineMixShortName;
  /**
   * 薬剤分類コード
   */
  private Integer classCd;
  /**
   * 指示単位
   */
  private String unit;
  /**
   * 指示単位基準量
   */
  private BigDecimal amountUnit;
  /**
   * ml単位基準量
   */
  private BigDecimal amountMl;
  /**
   * 調整薬剤情報
   */
  private String mixInfo;
  /**
   * 注射
   */
  private String isShot;
  /**
   * 投薬実施フラグ
   */
  private String isMedicated;
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
  /**
   * 投与タイミングコード
   */
  private Integer medicateTimingCd;
  /**
   * 手技コード
   */
  private Integer procedureCd;
   /**
   * 指示単位小数部桁数
   */
  private Integer unitDecimalPoint;
  // add #11801 治療条件.抗凝固剤に調整薬剤をセットしたときに配布リストの出力が不適切 sunsy start
  /**
   * 薬剤セット数
   */
  private Integer medicineSetNum;
  /**
   * レせ単位
   */
  private String unitSecond;
  // add #11801 治療条件.抗凝固剤に調整薬剤をセットしたときに配布リストの出力が不適切 sunsy end
  //add #10412 次患者更新関連全体見直し対応 朴 start
  /**
   * FNW+で管理する施設内の一意なセット薬剤名称コード
   */
  private String fn_set_medicine_cd;
  //add #10412 次患者更新関連全体見直し対応 朴 end

}
