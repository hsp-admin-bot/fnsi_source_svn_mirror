package jp.co.nikkiso.ntss.core.entity;

import org.seasar.doma.Column;
import org.seasar.doma.Entity;
import org.seasar.doma.GeneratedValue;
import org.seasar.doma.GenerationType;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.Getter;
import lombok.Setter;
/**
 * 定期点検機種別レイアウトマスタEntity
 */
@Entity(listener = BaseEntityListener.class, naming= NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_mainte_layout")
@Getter
@Setter
public class MstMenteLayout extends BaseEntity{
  /**
   * 点検レイアウトグループコード
   */
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  @Column(name = "mainte_layout_cd")
  private Long menteLayoutCd;
  /**
   * 版数
   */
  private Integer editionNo;
  /**
   * 施設コード
   */
  private String facilityCd;
  /**
   * レイアウトのクラス
   */
  private String layoutClass;
  /**
   * レイアウトの名前
   */
  private String layoutName;
  /**
   * マシンタイプリスト
   */
  private String typeInfo;
  /**
   * 詳細検査リスト1
   */
  @Column(name = "detail_info_1")
  private String detailInfo1;
  /**
   * 詳細検査リスト2
   */
  @Column(name = "detail_info_2")
  private String detailInfo2;
  /**
   * 表示フラグ
   */
  private String isDisp;
  /**
   * 削除フラグ
   */
  private String isDel;
  //add FNSI-No.694 レイアウトヘッダーを追加する 趙 start
  /**
   * 力ラム名
   */
  private String layoutHeader;
  //add FNSI-No.694 レイアウトヘッダーを追加する 趙 end
}
