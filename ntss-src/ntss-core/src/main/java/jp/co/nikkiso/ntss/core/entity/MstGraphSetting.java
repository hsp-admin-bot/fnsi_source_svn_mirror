package jp.co.nikkiso.ntss.core.entity;

import org.seasar.doma.Entity;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;
import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;

import lombok.Getter;
import lombok.Setter;

/**
 * mst_graph_setting(P-Ca9分割グラフ設定マスタ)のエンティティクラス
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_graph_setting")
@Getter
@Setter
public class MstGraphSetting extends BaseEntity {
  /**
   * P-Ca9分割グラフ設定番号
   */
  private String graphSettingNo;

  /**
   * 施設コード
   */
  private String facilityCd;

  /**
   * 値
   */
  private String value;
}