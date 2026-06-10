package jp.co.nikkiso.ntss.core.entity;

import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import java.sql.Timestamp;

/**
 *    * 帳票種別定義サービス.
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "sys_report_class")
@Getter
@Setter
public class SysReportClass extends BaseBlankEntity {

  /**
   * 種別コード
   */
  @Id
  private String reportClassCd;

  /**
   * 種別名
   */
  private String reportClassName;

  private String reportType;


  /**
   * 表示フラグ
   */
  private String isDisp;

  /**
   * 削除フラグ
   */
  private String isDel;

  /**
   * 登録日時
   */
  private Timestamp regDate;

  /**
   * 更新日時
   */
  private Timestamp upDate;

}
