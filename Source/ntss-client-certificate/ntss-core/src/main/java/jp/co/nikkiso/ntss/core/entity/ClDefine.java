package jp.co.nikkiso.ntss.core.entity;

import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.sql.Timestamp;
/**
 * クライアント証明書の設定
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "client_cer_define")
@Getter
@Setter
public class ClDefine {

  /**
   * 管理番号
   */
  @Id
  private BigDecimal ctlNo;

  /**
   * 名称
   */
  private String name;

  /**
   * 値
   */
  private String value;

  /**
   * 組織名
   */
  private String description;

  /**
   * 組織単位名
   */
  private String isEnable;

  /**
   * 更新日
   */
  private Timestamp upDate;

}
