package jp.co.nikkiso.ntss.core.entity;

import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import java.sql.Timestamp;

/**
 * 機能帳票設定
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "sys_report_setting")
@Getter
@Setter
public class SysReportSetting extends BaseBlankEntity {

  /**
   * 機能コード
   */
  @Id
  private String functionCd;

  /**
   * 機能名
   */
  private String functionName;

  private String reportSettingNo;

  /**
   * 機能帳票種別設定
   */
  private String printReportClass;

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
