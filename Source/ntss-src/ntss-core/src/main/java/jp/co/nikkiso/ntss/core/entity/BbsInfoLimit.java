package jp.co.nikkiso.ntss.core.entity;

import jp.co.nikkiso.ntss.core.entity.entityListener.CommonEntityListener;
import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

/**
 * 掲示板登録情報クラス_追加
 */
@Entity(listener = CommonEntityListener.class, naming = NamingType.NONE)
@Getter
@Setter
public class BbsInfoLimit extends BbsInfo {
  /**
   * 対象スタッフ_sort
   */
  private int staff_info_sort;
  /**
   * 掲載期間
   */
  private String notice_date;
  /**
   * 施設イベントカテゴリマスタ表示順
   */
  private Long bbs_kind_ord_index;
  /**
   * 画面遷移_sort
   */
  private int transition_path_sort;

  /* add by chamaojia 2026-02-05 [11893] キャッシュ軽減対応 --start */
  /**
   * 種別名
   */
  private String kind_name;
  /* add by chamaojia 2026-02-05 [11893] キャッシュ軽減対応 --end */
}
