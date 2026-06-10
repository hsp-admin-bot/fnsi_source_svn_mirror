package jp.co.nikkiso.ntss.core.entity;

import java.sql.Timestamp;
import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.entityListener.OrdVitalEntityListener;
import lombok.Getter;
import lombok.Setter;

/**
 * 透析バイタル情報クラス
 */
@Entity(listener = OrdVitalEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "ord_vital")
@Getter
@Setter
public class OrdVital extends BaseBlankEntity {
  @Id
  /**
   * システムで管理する一意なオーダ番号
   */
  private Long ordNo;

  /**
   * 版番号
   */
  private Integer edition;
  @Id
  /**
   * 管理番号
   */
  private Short ctlNo;

  /**
   * 入力区分
   */
  // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
  //private Short inputClass;
  private Integer inputClass;
  // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end

  /**
   * 血圧区分
   */
  private Short bpClass;

  /**
   * 最高血圧
   */
  private Short bpMax;

  /**
   * 最低血圧
   */
  private Short bpMin;

  /**
   * 平均血圧
   */
  private Short bpAve;

  /**
   * 血糖値
   */
  private Short bloodSugarLevel;

  /**
   * 脈拍
   */
  private Short pulse;

  /**
   * 体温
   */
  private Double temperature;

  /**
   * 削除フラグ
   */
  private String isDel;

  /**
   * 発生日時
   */
  private Timestamp occurDate;

  /**
   * 更新日時
   */
  private Timestamp upDate;

  /**
   * 透析日
   */
  private String dialysisDate;
}
