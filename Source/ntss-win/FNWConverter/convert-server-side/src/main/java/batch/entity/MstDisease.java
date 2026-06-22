package batch.entity;

import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import java.sql.Timestamp;

/**
 * 病名クラス
 */
@Entity
@Table(name = "mst_disease")
@Getter
@Setter
public class MstDisease extends BaseBlankEntity {
  /**
   * 病名コード
   */
  @Id
  private Integer diseaseCd;
  /**
   * 施設コード
   */
  private String facilityCd;
  /**
   * FNW+で管理する施設内の一意な病名コード
   */
  private String fnDiseaseCd;
  /**
   * 病名
   */
  private String diseaseName;
  /**
   * 省略病名
   */
  private String diseaseShortName;
  /**
   * 標準病名コード
   */
  private Integer standardDiseaseCd;
  /**
   * 原疾患生検なしコード
   */
  private String pDiseaseBiopsyNoneCd;
  /**
   * 原疾患生検ありコード
   */
  private String pDiseaseBiopsyExistCd;
  /**
   * 死因確診なしコード
   */
  private String dieConfirmedDiagnosisNoneCd;
  /**
   * 死因確診ありコード
   */
  private String dieConfirmedDiagnosisExistCd;
  /**
   * 連携コード1
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
  private Timestamp regDate;
  /**
   * 更新日時
   */
  private Timestamp upDate;
}
