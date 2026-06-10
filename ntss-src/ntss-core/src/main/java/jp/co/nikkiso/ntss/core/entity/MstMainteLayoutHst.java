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
 * 定期点検レイアウト履歴マスタEntity
 */
@Entity(listener = BaseEntityListener.class, naming= NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_mainte_layout_hst")
@Getter
@Setter
public class MstMainteLayoutHst extends BaseEntity{
  /**
   * 検査コードのレイアウト
   */
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long mainteLayoutCd;
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
