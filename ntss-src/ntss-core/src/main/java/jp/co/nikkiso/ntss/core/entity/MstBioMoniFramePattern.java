package jp.co.nikkiso.ntss.core.entity;

import org.seasar.doma.Entity;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.Getter;
import lombok.Setter;

/**
 * 装置マスタクラス
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_bio_moni_frame_pattern")
@Getter
@Setter
public class MstBioMoniFramePattern extends BaseEntity {
  /**
   * 施設コード
   */
  private String facilityCd;
  /**
   * 管理番号
   */
  private Integer ctlNo;
  /**
   * テンプレート名
   */
  private String templateName;
  /**
   * フレーム種別 0：一覧、1：詳細
   */
  private short frameType;
  /**
   * フレーム番号
   */
  private short frameNo;
  /**
   * 定義情報
   */
  private String defineInfo;
}
