package jp.co.nikkiso.ntss.core.entity;

import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.entityListener.MstVaEntityListener;
import lombok.Getter;
import lombok.Setter;

import java.sql.Timestamp;
/**
 * VAクラス
 */
@Entity(listener = MstVaEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_va")
@Getter
@Setter
public class MstVa extends BaseBlankEntity {
  /**
   * VAコード
   */
  @Id
  private Integer vaCd;
  /**
   * 施設コード
   */
  private String facilityCd;
  /**
   * FNW+で管理する施設内の一意なVAコード
   */
  private String fnVaCd;
  /**
   * VA名
   */
  private String vaName;
  /**
   * VA方向
   */
  private String vaDirect;
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
