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
 * pat_exam_main(患者検査結果)の個別入力用エンティティ
 */
@Entity(listener = CommonEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "pat_exam_main")
@Getter
@Setter
public class PatExamMainForOneOrder {

  /**
   * システムで管理する一意な検査結果ID.
   */
  @Id
  private long examMainCd;

  /**
   * システムで管理する一意な患者ID.
   */
  @Id
  private long patId;

  /**
   * 施設コード.
   */
  private String facilityCd;

  /**
   * オーダ番号
   */
  private String ordNo;

  /**
   * 登録時検査区分
   */
  private String regOrderClass;

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
   * 連携オーダー番号1
   */
  private String copOrderNo1;

  /**
   * 更新日時
   */
  private Timestamp upDate;

  /**
   * 検査結果-検査項目コード.
   */
  @Id
  private String itemCd;

  /**
   * 検査結果-検査項目名.
   */
  private String itemName;

  /**
   * 検査結果-結果値.
   */
  private String result;

  /**
   * 検査結果-検査時データ形式
   */
  private String type;

  /**
   * 検査結果-検査時単位
   */
  private String unit;

  /**
   * 検査結果-検査時正常値上限
   */
  private String upper;

  /**
   * 検査結果-検査時正常値下限
   */
  private String lower;

  /**
   * 検査結果-検査時入力整数部桁数
   */
  private String inputIntegerFigure;

  /**
   * 検査結果-検査時入力小数部桁数
   */
  private String inputDecimalFigure;

  /**
   * 検査結果-検査時入力上限値
   */
  private String inputUpper;

  /**
   * 検査結果-検査時入力下限値
   */
  private String inputLower;

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
   * 検査結果-コメントコード
   */
  private String comCd;

  /**
   * 検査結果-フリーコメント
   */
  private String freememo;

  /**
   * 検査結果-検査時検査使用区分
   */
  private String examClass;
  /**
   * JLAC10コード
   */
  private String jlac10Cd;

  /**
   * 検査項目-表示フラグ
   */
  private String isDisp;
}
