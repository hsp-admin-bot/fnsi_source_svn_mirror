package jp.co.nikkiso.ntss.core.dto.patUnique;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

/**
 *
 *
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
@NoArgsConstructor
public class OrdMainForUpdTargetWeightDTO {

  /** オーダ番号 */
  private Long ordNo;
  /** 施設コード */
  private String facilityCd;

  /** 患者ID */
  private Long patId;

  /** 治療日 */
  private String treatDate;

  /** 治療曜日 */
  private String treatWeek;

  /** 治療情報元目標体重 */
  private String originalWeight;

  /** 身体情報の設定目標体重 */
  private String targetWeight;

  /** 指示者Code */
  private String indicatorCd;

  /** 変更者Code */
  private String changerCd;

  /**　指示：治療方法コード　*/
  private Integer indTreatmentCd;

  /**指示：クールコード　*/
  private Integer indKurCd;

  //add #12096 データリストにてDWおよび目標体重を登録するとサーバダウン zrx start
  /** 指示者name */
  private String indUserLastName;
  private String indUserFirstName;

  /** 変更者name */
  private String updUserLastName;
  private String updUserFirstName;
  //add #12096 データリストにてDWおよび目標体重を登録するとサーバダウン zrx end

}
