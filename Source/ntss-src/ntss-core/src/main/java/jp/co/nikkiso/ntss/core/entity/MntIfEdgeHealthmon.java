package jp.co.nikkiso.ntss.core.entity;

import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * 連携エッジヘルスモニタEntity
 *
 */
/* modify by chamaojia 2024-09-25 [10574] delete object listening --start */
//@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
/* modify by chamaojia 2024-09-25 [10574] delete object listening --end */
@Table(name = "mnt_if_edge_healthmon")
@Getter
@Setter
public class MntIfEdgeHealthmon extends BaseEntity {
  /** 管理番号 */
  @Id
  private Long ctlNo;
  /** 施設コード */
  private String facilityCd;
  /** IFエッジ番号 */
  private Integer ifEdgeNo;
  /** エッジステータス */
  private String healthmonFacilityConn;
  /** サーバステータス */
  private String healthmonServerConn;

  /* delete by chamaojia 2024-10-11 [11140] 【mnt_if_edge_healthmon】 coop_version delete --start */
//// add 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//  /** 連携版番号 */
//  private String coopVersion;
//// add 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
  /* delete by chamaojia 2024-10-11 [11140] 【mnt_if_edge_healthmon】 coop_version delete --end */
 }
