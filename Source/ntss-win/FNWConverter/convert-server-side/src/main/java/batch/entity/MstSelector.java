package batch.entity;

import lombok.Getter;
import lombok.Setter;
import org.json.JSONObject;
import org.seasar.doma.Entity;
import org.seasar.doma.Table;

import java.sql.Timestamp;

/**
 * 選択肢マスタ
 */
@Entity
@Table(name = "mst_selector")
@Getter
@Setter
public class MstSelector extends BaseEntity {

  /**
   * 施設コード
   */
  private String facilityCd;
  /**
   * マスタ物理名称
   */
  private String masterPhysicalName;
  /**
   * 並び順設定
   */
  private JSONObject orderSettings;
  /**
   * 登録日時
   */
  private Timestamp regDate;
  /**
   * 更新日時
   */
  private Timestamp upDate;

  @Override
  public String toString() {
          StringBuffer sb = new StringBuffer();
                  sb.append(facilityCd==null ? "" : facilityCd).append(",")
                  .append(masterPhysicalName==null ? "" : masterPhysicalName).append(",")
                  .append(orderSettings==null ? "" : orderSettings.toString().replace(",", "|")).append(",")
                  .append(regDate==null ? "" : regDate).append(",")
                  .append(upDate==null ? "" : upDate);
          return sb.toString();
  }
}
