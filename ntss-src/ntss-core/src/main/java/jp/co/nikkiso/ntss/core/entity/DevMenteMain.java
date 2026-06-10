package jp.co.nikkiso.ntss.core.entity;

import java.sql.Date;
import java.sql.Timestamp;

import jp.co.nikkiso.ntss.core.entity.entityListener.CommonEntityListener;
import org.seasar.doma.Column;
import org.seasar.doma.Entity;
import org.seasar.doma.GeneratedValue;
import org.seasar.doma.GenerationType;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * 検査結果Entity
 */
@Entity(listener = CommonEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE, immutable = true)
@Table(name = "mnt_mainte_main")
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class DevMenteMain extends BaseBlankEntity {
  /**
   * 検査結果コード
   */
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)

  @Column(name = "mainte_no")
  private Long devMenteNo;
  /**
   * 施設コード
   */
  private String facilityCd;
  /**
   * 型式検査
   */
  @Column(name = "mainte_class")
  private String menteClass;
  /**
   * 装置番号
   */
  private Long machineNo;
  // mod #11131 定期点検で使用する記録番号のデータ型がFNWと相違している 20231218 ztc start
  /**
   * 記録番号
   */
  @Column(name = "rec_no")
//  private Integer recNo;
  private String recNo;
  // mod #11131 定期点検で使用する記録番号のデータ型がFNWと相違している 20231218 ztc end
  /**
   * 点検日
   */
  @Column(name = "mainte_date")
  private Date menteDate;
  /**
   * 点検レイアウトグループコード
   */
  @Column(name = "mainte_layout_group_cd")
  private Long menteLayoutGroupCd;
  /**
   * 点検レイアウトグループコード版数
   */
  private Integer mainteLayoutGroupEdition;
  /**
   * 点検レイアウトコード
   */
  @Column(name = "mainte_layout_cd")
  private Long menteLayoutCd;
  /**
   * 点検レイアウトコード版数
   */
  private Integer mainteLayoutEdition;
  /**
   * 点検カテゴリコード版数
   */
  private String mainteCategoryCd;
  /**
   * 点検実施者
   */
  @Column(name = "checker_id_1")
  private Long checkerId1;
  /**
   * 確認者
   */
  @Column(name = "checker_id_2")
  private Long checkerId2;
  /**
   * 結果入力パターン
   */
  @Column(name = "mainte_ans_1")
  private String menteAns1;
  /**
   * 定期検査記録のコメント
   */
  @Column(name = "mainte_comment_1")
  private String menteComment1;
  /**
   * 内容
   */
  private String detail;
  /**
   * 表示フラグ
   */
  private String isDisp;
  /**
   * 削除フラグ
   */
  private String isDel;
  /**
   * 更新日時
   */
  private Timestamp upDate;
  /**
   * 登録日時
   */
  private Timestamp regDate;
}
