package jp.co.nikkiso.ntss.core.entity;

import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import java.sql.Timestamp;

// add #9811 装置設定>操作範囲>ヘマトクリットと総タンパクの検査値が不正 修正 20231113 ztc start
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class PatExamMainForAllExamResultInfo {

  /**
   * 検査結果ID
   */
  private Long examMainCd;

  /**
   * 検査日時.
   */
  private Timestamp resultExamDate;

  /**
   * 検査結果情報.
   */
  private String examResultInfo;

  /**
   * 検査結果コード
   */
  private Long examItemCd;

}
// add #9811 装置設定>操作範囲>ヘマトクリットと総タンパクの検査値が不正 修正 20231113 ztc end
