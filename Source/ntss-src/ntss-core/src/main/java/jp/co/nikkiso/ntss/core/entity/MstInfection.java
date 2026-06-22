package jp.co.nikkiso.ntss.core.entity;

import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.entityListener.MstInfectionEntityListener;
import lombok.Getter;
import lombok.Setter;

import java.sql.Timestamp;
/**
 * 感染症クラス
 */
@Entity(listener = MstInfectionEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_infection")
@Getter
@Setter
public class MstInfection extends BaseBlankEntity {
  /**
   * 感染症コード
   */
  @Id
  private Integer infectionCd;
  /**
   * 施設コード
   */
  private String facilityCd;
  /**
   * FNW+で管理する施設内の一意な感染症コード
   */
  private String fnInfectionCd;
  /**
   * 感染症名
   */
  private String infectionName;
  /**
   * 標準感染症コード
   */
  private String standardInfectionCd;
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
  private Timestamp regDate;
  /**
   * 更新日時
   */
  private Timestamp upDate;
}
