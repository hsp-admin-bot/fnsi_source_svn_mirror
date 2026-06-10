package jp.co.nikkiso.ntss.core.entity.custom;

import jp.co.nikkiso.ntss.core.entity.entityListener.CommonEntityListener;
import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;
import lombok.Getter;
import lombok.Setter;
import java.sql.Timestamp;

/**
 * pat_exam_main(患者検査結果)の検査結果一覧画面用エンティティクラス
 */
@Entity(listener = CommonEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "pat_exam_main")
@Getter
@Setter
public class PatExamMainForRecord {

  /**
   * システムで管理する一意な検査結果ID.
   */
  @Id
  private long examMainCd;

  /**
   * システムで管理する一意な患者ID.
   */
  private long patId;

  /**
   * 施設コード.
   */
  private String facilityCd;

  /**
   * 登録時検査区分
   */
  private String regOrderClass;

  /**
   * 登録時検査区分名称
   */
  private String regOrderClassName;

  /**
   * 状況区分.
   */
  private String examStatus;

  /**
   * データ登録区分
   */
  private String dataGenClass;

  /**
   * 結果時検査日時.
   */
  private Timestamp resultExamDate;

  /**
   * 結果時検査時刻(YYYYMMDDHH24MISS)
   */
  private String resultExamDateName;

  /**
   * 削除フラグ.
   */
  private String isDel;

  /**
   * 検査結果-検査項目コード.
   */
  private String itemCd;

  /**
   * 検査結果-結果値.
   */
  private String result;

  /**
   * 検査結果-結果判定
   */
  private String hl;

  /**
   * 検査結果-表示順
   */
  // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
  //private String dispOrder;
  private Integer dispOrder;
  // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
  /**
   * 受理した患者ID
   */
  private Long patIdDst;
  /**
   * JLAC10コード
   */
  private String jlac10Cd;
}
