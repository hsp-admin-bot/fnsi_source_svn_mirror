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
public class BbsInfoCount extends BbsInfo {
  /**
   * 掲示板件数
   */
  private Long count;
  /**
   * 掲載期間
   */
  private String notice_date;

  /* add by chamaojia 2026-02-05 [11893] キャッシュ軽減対応 --start */
  /**
   * 種別名
   */
  private String kind_name;
  /* add by chamaojia 2026-02-05 [11893] キャッシュ軽減対応 --end */
}
