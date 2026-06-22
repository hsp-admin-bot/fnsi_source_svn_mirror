/**
 * add FNSI-「幹対応残課題一覧.xlsx」№10対応 田
 */
package jp.co.nikkiso.ntss.core.entity;

import jp.co.nikkiso.ntss.core.entity.entityListener.CommonEntityListener;
import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.GeneratedValue;
import org.seasar.doma.GenerationType;
import org.seasar.doma.Id;
import org.seasar.doma.SequenceGenerator;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import java.sql.Timestamp;

/**
 * pat_exam_main(患者検査結果)のエンティティクラス
 */
@Entity(listener = CommonEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "pat_exam_main_hst")
@Getter
@Setter
public class PatExamMainHst extends BaseEntity {
  //add检查予定 删除bug  張岩start
  /**
   * 患者検査結果記録コード.
   */
  @Id
  @GeneratedValue(strategy = GenerationType.SEQUENCE)
  @SequenceGenerator(sequence = "exam_main_hst_cd_seq")
  private Long examMainHstCd;
  //add检查予定 删除bug  張岩end
  /**
   * システムで管理する一意な検査結果ID.
   */
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

  /**
   * 血液検査/心電図.
   */
  private String phyOrdClass;

}
