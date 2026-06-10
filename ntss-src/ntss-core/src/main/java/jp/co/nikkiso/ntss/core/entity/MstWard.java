package jp.co.nikkiso.ntss.core.entity;

import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.entityListener.MstWardEntityListener;
import lombok.Getter;
import lombok.Setter;

/**
 * 病棟クラス
 */
@Entity(listener = MstWardEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_ward")
@Getter
@Setter
public class MstWard extends BaseBlankEntity {

  /**
   * 病棟コード
   */
  @Id
  private Integer wardCd;

  /**
   * 施設コード
   */
  private String facilityCd;

  /**
   * FNW+で管理する施設内の一意な病棟コード
   */
  private String fnWardCd;

  /**
   * 病棟名
   */
  private String wardName;
  /**
   * 連携コード
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
  private String regDate;
  /**
   * 更新日時
   */
  private String upDate;
}
