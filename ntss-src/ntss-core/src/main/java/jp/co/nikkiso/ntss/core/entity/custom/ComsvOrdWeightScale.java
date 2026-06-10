package jp.co.nikkiso.ntss.core.entity.custom;

import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.BaseEntity;
import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.Getter;
import lombok.Setter;

/**
 * 通信サーバ用体重計測定実績クラス
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class ComsvOrdWeightScale extends BaseEntity {

  @Id
  /**
   * 測定管理番号
   */
  private Long weightScaleNo;

  /**
   * 体重測定状況
   */
  private int weightScaleStatus;

  /**
   * メッセージ
   */
  private String message;

}