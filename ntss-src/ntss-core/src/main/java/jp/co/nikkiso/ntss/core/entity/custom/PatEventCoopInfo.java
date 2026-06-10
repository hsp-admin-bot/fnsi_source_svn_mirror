package jp.co.nikkiso.ntss.core.entity.custom;

import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

/**
 * 連携イベント作成・中止ツールクラス
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class PatEventCoopInfo {

  /**
   * システムで管理する一意な患者名
   */
  private String pat_name;
  /**
   * システムで管理する一意な患者ID
   */
  private Long pat_id;

  /**
   * 指示：システムで管理する一意なオーダ番号
   */
  private String ord_no;

  /**
   * 指示：治療日
   */
  private String treat_date;

  /**
   * 指示：患者番号（連携用）
   */
  private String hosp_pat_id;
  // add 9409 検出された患者が全て同姓同名表示がされてしまっている　吉 start
  /**
   * 同姓同名
   */
  private String is_same;
  // add 9409 検出された患者が全て同姓同名表示がされてしまっている　吉 end

  private String ind_user_id;
}
