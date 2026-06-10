package jp.co.nikkiso.ntss.core.entity;

import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import jp.co.nikkiso.ntss.core.entity.json.LayoutExtSetting;
import jp.co.nikkiso.ntss.core.entity.xml.Root;
import lombok.Getter;
import lombok.Setter;

/**
 * 変換レイアウト詳細を表すエンティティクラス。
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_coop_layout_detail")
@Getter
@Setter
public class MstCoopLayoutDetail extends BaseEntity {

  /** 管理番号 */
  @Id
  private Long ctlNo;

  /** 施設コード */
  private String facilityCd;

  /** 電文種別 */
  private String coopCd;

  /** 向き（送受信） */
  private String direction;

  /** 電文種別詳細コード */
  private String coopCdDetail;

  /** 電文種別詳細補足コード */
  private String coopCdDetailSub;

  /** レイアウト名称 */
  private String coopName;

  /** 説明 */
  private String description;

  /** 編集可否フラグ */
  private String isEditable;

  /** 連携設定 */
  private String coopSetting;

  /** 拡張設定 */
  private LayoutExtSetting coopExtSetting;

  /** 表示フラグ */
  private String isDisp;

  /** 削除フラグ */
  private String isDel;

  /** 操作者ID */
  private Long userId;

// add 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
  /** 連携版番号 */
  private String coopVersion;
// add 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

  public Root getCoopSettingRoot() {
    return new Root(coopSetting);
  }
}
