package jp.co.nikkiso.ntss.core.entity;

import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.entityListener.MstPatListLayoutEntityListener;
import lombok.Getter;
import lombok.Setter;

import java.sql.Timestamp;
/**
 * 患者治療パターンクラス
 */
@Entity(listener = MstPatListLayoutEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_pat_list_layout")
@Getter
@Setter
public class MstPatListLayout extends BaseBlankEntity {
  /**
   * マルチ患者一覧レイアウトコード
   */
  @Id
  private long patListLayoutCd;
  /**
   * 施設コード
   */
  @Id
  private String facilityCd;
  /**
   * マルチ患者一覧レイアウト名
   */
  private String patListLayoutName;
  /**
   * 表示項目
   */
  private String dispItemInfo;
  /**
   * 職種
   */
  private String occupations;
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
  /**
   * テンプレートコード
   */
  private Integer templateCd;
}
