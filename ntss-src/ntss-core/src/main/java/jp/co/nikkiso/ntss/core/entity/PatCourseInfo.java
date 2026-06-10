package jp.co.nikkiso.ntss.core.entity;

import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

/**
 * #12462 患者情報共有 zrx
 * 診療科マスタ
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class PatCourseInfo {

  /**
   * 診療科コード
   */
  private Integer courseCd;
  /**
   * 診療科名
   */
  private String courseName ;
}
