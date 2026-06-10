package jp.co.nikkiso.ntss.core.entity.custom;

import java.sql.Timestamp;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.BaseEntity;
import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.Getter;
import lombok.Setter;

/**
 * 通信サーバ用設定値読み込みクラス
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class ComsvOrdTreatCondition extends BaseEntity {

  /**
   * オーダー番号
   */
  private Long ordNo;

  /**
   * 施設コード
   */
  private String facilityCd;

  /**
   * 装置番号
   */
  private Long machineNo;

  /**
   * 条件取得日時
   */
  private Timestamp receiveDate;

  /**
   * 治療条件
   */
  private String treatCondition;

  /**
   * 区分
   */
  private int treatClass;

}