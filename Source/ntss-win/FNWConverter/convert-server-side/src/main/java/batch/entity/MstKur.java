package batch.entity;

import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;


import lombok.Getter;
import lombok.Setter;

import java.sql.Timestamp;
/**
 * クールクラス
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_kur")
@Getter
@Setter
public class MstKur extends BaseBlankEntity {
  /**
   * クールコード
   */
  @Id
  private Integer kurCd;
  /**
   * 施設コード
   */
  private String facilityCd;
  /**
   * FNW+で管理する施設内の一意なクールコード
   */
  private String fnKurCd;
  /**
   * クール名
   */
  private String kurName;
  /**
   * クール開始時刻
   */
  private String kurStartTime;
  /**
   * クール終了時刻
   */
  private String kurEndTime;
  /**
   * クール内標準治療開始時刻
   */
  private String kurStandardStartTime;
  /**
   * 連携コード1
   */
  private String inHospitalCd_1;
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
   * 担当医情報
   */
  private String mstUserAuthentication;

}
