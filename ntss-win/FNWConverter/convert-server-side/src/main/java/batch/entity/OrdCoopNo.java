package batch.entity;

import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import lombok.Getter;
import lombok.Setter;

import java.sql.Timestamp;

@Entity
@Table(name = "ord_coop_no")
@Getter
@Setter
public class OrdCoopNo extends BaseEntity {

  /** 管理番号 */
  @Id
  private Long ctlNo;
  /** 施設コード */
  private String facilityCd;
  /** 患者番号 */
  private Long patId;
  /** オーダ番号 */
  private Long ordNo;
  /** 連携種別 */
  private String coopCd;
  /** 連携オーダ番号 */
  private String coopOrdNo;
  /** 表示フラグ */
  private String isDisp;
  /** 削除フラグ */
  private String isDel;
  /** 操作者ID */
  private Long userId;
  /** 登録日時  */
  private Timestamp regDate;
  /** 更新日時 */
  private Timestamp upDate;
  /** ステータス */
  private String status;
  /** 患者番号(連携用) */
  private String hospPatId;
  /** 付帯情報（電文） */
  private String coopCdIndex;
  /** 連携版番号 */
  private String coopVersion;


  @Override
  public String toString() {
    StringBuffer stringBuffer = new StringBuffer();
    stringBuffer.append(facilityCd==null ? "" : facilityCd).append(",")
            .append(patId==null ? "" : patId).append(",")
            .append(ordNo==null ? "" : ordNo).append(",")
            .append(coopCd==null ? "" : coopCd).append(",")
            .append(coopOrdNo==null ? "" : coopOrdNo).append(",")
            .append(isDisp==null ? "" : isDisp).append(",")
            .append(isDel==null ? "" : isDel).append(",")
            .append(userId==null ? "" : userId).append(",")
            .append(regDate==null ? "" : regDate).append(",")
            .append(upDate==null ? "" : upDate).append(",")
            .append(status==null ? "" : status).append(",")
            .append(hospPatId==null ? "" : hospPatId).append(",")
           .append(coopVersion==null ? "" : coopVersion).append(",");
    return stringBuffer.toString();
  }
}
