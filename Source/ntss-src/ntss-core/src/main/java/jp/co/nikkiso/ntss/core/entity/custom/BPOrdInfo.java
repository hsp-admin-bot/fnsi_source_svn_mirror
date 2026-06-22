package jp.co.nikkiso.ntss.core.entity.custom;

import jp.co.nikkiso.ntss.core.entity.entityListener.CommonEntityListener;
import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.BaseEntity;
import lombok.Getter;
import lombok.Setter;

/**
 * 浄化装置通信アプリ用の透析情報エンティティ.
 */
@Entity(listener = CommonEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class BPOrdInfo extends BaseEntity {
  @Id
  /**
   * システムで管理する一意なオーダ番号.
   */
  private Long ordNo;

  /**
   * システムで管理する一意な患者ID.
   */
  private Long patId;

  /**
   * 治療日.
   */
  private String treatDate;

  /**
   * 実績：治療方法コード.
   */
  private Integer rstTreatmentCd;

  /**
   * 実績：クールコード.
   */
  private Long rstKurCd;

  /**
   * 実績：ベッド名.
   */
  private String rstBedName;

  /**
   * 実績：治療状況.
   */
  private String rstDialysisState;

  /**
   * 同姓同名.
   */
  private Boolean isSame;

  /**
   * クール名.
   */
  private String kurName;

  /**
   * クール開始時刻.
   */
  private String kurStartTime;

  /**
   * クール終了時刻.
   */
  private String kurEndTime;

  /**
   * 装置モード.
   */
  private Integer deviceMode;

  // add 2020-08-04 FNSI-仕様追加 モニタ詳細画面に患者情報を表示する 李 start
  /**
   * 治療方法名.
   */
  private String rst_treatment_name;
  // add 2020-08-04 FNSI-仕様追加 モニタ詳細画面に患者情報を表示する 李 end
}
