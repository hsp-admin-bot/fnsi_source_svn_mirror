package jp.co.nikkiso.ntss.core.entity;

import jp.co.nikkiso.ntss.core.entity.entityListener.CommonEntityListener;
import org.seasar.doma.Entity;
import org.seasar.doma.GeneratedValue;
import org.seasar.doma.GenerationType;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

import java.io.Serializable;
import java.sql.Timestamp;
import java.util.Date;
import java.util.Objects;

/**
 * pat_exam_main(患者検査結果)のエンティティクラス
 */
@Entity(listener = CommonEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "pat_exam_main")
@Getter
@Setter
//upd #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 20240425 ztc start
//public class PatExamMain extends BaseEntity  {
public class PatExamMain extends BaseEntity implements Serializable {
//upd #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 20240425 ztc end

  /**
   * システムで管理する一意な検査結果ID.
   */
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long examMainCd;

  /**
   * システムで管理する一意な検査結果ID.
   */
  private Long patId;

  /**
   * 施設コード.
   */
  private String facilityCd;

  /**
   * オーダ番号.
   */
  private Long ordNo;

  /**
   * FNW+で管理する施設内の一意な患者ID.
   */
  private String fnPatId;

  /**
   * 登録時検査日時.
   */
  private Timestamp regExamDate;

  /**
   * 登録時検査区分.
   */
  private String regOrderClass;

  /**
   * 状況区分.
   */
  private String examStatus;

  /**
   * 依頼時コメント.
   */
  private String orderComment;

  /**
   * 検査依頼情報.
   */
  private String orderExamSetInfo;

  /**
   * 検査依頼情報.
   */
  private String examOrderInfo;

  /**
   * ラベル情報.
   */
  private String orderLabelInfo;

  /**
   * データ登録区分.
   */
  private String dataGenClass;

  /**
   * 結果時検査日時.
   */
  private Timestamp resultExamDate;

  /**
   * 結果時コメント.
   */
  private String resultComment;

  /**
   * 検査結果情報.
   */
  private String examResultInfo;

  /**
   * 連携オーダ番号1.
   */
  private String copOrderNo1;
  /**
   * 連携オーダ番号2.
   */
  private String copOrderNo2;
  /**
   * 依頼変更可否フラグ.
   * 0 ：  変更可(依頼締切前)、1 ： 変更不可(依頼締切後)
   */
  private String isLock;

  /**
   * 指示者.
   */
  private Long indUserId;

  /**
   * 削除フラグ.
   * 0 : 通常、1 : 削除
   */
  private String isDel;

  /**
   * 登録スタッフ.
   */
  private Long regStaff;

  /**
   * 最終更新スタッフ.
   */
  private Long upStaff;

  /**
   * 検査依頼登録フラグ.
   * 0 : 検査結果から登録、1 : 検査依頼から登録
   */
  private String isOrder;
  //add 检查 張岩 start
  /**
   * 検査パターン.
   */
  private Integer examPattern;

  /**
   * 指定曜日.
   */
  private Integer examWeek;

  /**
   * 指定期間開始日.
   */
  private Date examFrom;

  /**
   * 指定期間終了日.
   */
  private Date examTo;
  //add 检查 張岩 end

  /**
   * 血液検査/心電図.
   */
  private String phyOrdClass;

  //add 10553 連携イベント発生部分不正【最優先】zhao start
  @Override
  public boolean equals(Object obj) {
    if (this == obj) return true;
    if (obj == null || getClass() != obj.getClass()) return false;
    PatExamMain patExamMain = (PatExamMain) obj;
    return Objects.equals(facilityCd, patExamMain.facilityCd)&&Objects.equals(examMainCd, patExamMain.examMainCd)
      &&Objects.equals(patId, patExamMain.patId)&&Objects.equals(regExamDate, patExamMain.regExamDate)
      &&Objects.equals(isDel, patExamMain.isDel)&&Objects.equals(phyOrdClass, patExamMain.phyOrdClass);
  }

  @Override
  public int hashCode() {
    return Objects.hash(facilityCd,examMainCd,patId,regExamDate,isDel,phyOrdClass);
  }
  //add 10553 連携イベント発生部分不正【最優先】zhao end

}
