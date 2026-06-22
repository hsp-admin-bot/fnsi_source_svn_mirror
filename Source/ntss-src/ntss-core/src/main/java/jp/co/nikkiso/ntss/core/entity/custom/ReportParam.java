package jp.co.nikkiso.ntss.core.entity.custom;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * 透析または検査を特定するためのキーのEntity.
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class ReportParam {

  /**
   * システムで管理する一意なオーダ番号
   */
  private Long ordNo;

  /**
   * 日付 透析日または検査日
   */
  private String treatDate;

}
