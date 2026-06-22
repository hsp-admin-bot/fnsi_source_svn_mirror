package batch.entity;

import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;

import java.sql.Timestamp;

/**
 * チェックリストマスタクラス
 */
@Entity
@Table(name = "batch_convert_status")
@Getter
@Setter
public class BatchConvertStatus extends BaseEntity {

  @Id
  private Long convertProcId;
  /**
   * 施設コード
   */
  private String facilityCd;
  /**
   * job運転状態
   */
  private String status;
  /**
   * jobインスタンスid
   */
  private Long jobInstanceId;
  /**
   * job名
   */
  private String jobName;
  /**
   * job実行開始時間
   */
  private Timestamp regDate;
  /**
   * job実行終了時間
   */
  private Timestamp upDate;

}
