package jp.co.nikkiso.ntss.core.entity;

import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.Column;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.entityListener.MstProcedureEntityListener;
import lombok.Getter;
import lombok.Setter;

import java.sql.Timestamp;
/**
 * 手技クラス
 */
@Entity(listener = MstProcedureEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_procedure")
@Getter
@Setter
public class MstProcedure extends BaseBlankEntity {
  /**
   * 手技コード
   */
  @Id
  private Integer procedureCd;
  /**
   * 施設コード
   */
  private String facilityCd;
  /**
   * FNW+で管理する施設内の一意な手技コード
   */
  private String fnProcedureCd;
  /**
   * 手技名称
   */
  private String pricedureName;
  /**
   * 利用開始日A
   */
  @Column(name = "in_hosp_a_startdate")
  private String inHospAStartdate;
  /**
   * 利用開始日B
   */
  @Column(name = "in_hosp_b_startdate")
  private String inHospBStartdate;
  /**
   * 連携コードA-1
   */
  private String inHospitalCdA1;
  /**
   * 連携コードA-2
   */
  private String inHospitalCdA2;
  /**
   * 連携コードB-1
   */
  private String inHospitalCdB1;
  /**
   * 連携コードB-2
   */
  private String inHospitalCdB2;
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
