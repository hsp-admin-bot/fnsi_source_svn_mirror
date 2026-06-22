package jp.co.nikkiso.ntss.core.entity;

import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.entityListener.MstSeverityEntityListener;
import lombok.Getter;
import lombok.Setter;

import java.sql.Timestamp;
/**
 * 重症度クラス
 */
@Entity(listener = MstSeverityEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_severity")
@Getter
@Setter
public class MstSeverity extends BaseBlankEntity {
  /**
   * 重症度コード
   */
  @Id
  private Integer severityCd;
  /**
   * 施設コード
   */
  private String facilityCd;
  /**
   * FNW+で管理する施設内の一意な重症度コード
   */
  private String fnSeverityCd;
  /**
   * 重症度名
   */
  private String severityName;
  /**
   * 連携コード
   */
  private String inHospitalCd_1;
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
