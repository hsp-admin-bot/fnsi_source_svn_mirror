package jp.co.nikkiso.ntss.core.entity;

import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.Getter;
import lombok.Setter;

/**
 * 連携エッジクライアント接続状態Entity
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mnt_if_edge_client_connect")
@Getter
@Setter
public class MntIfEdgeClientConnect extends BaseEntity {

  @Id
  /** 施設コード */
  private String facilityCd;

  /** 通信サービス稼働IPアドレス */
  private String ipAddress;

  private Integer  ifEdgeType;

}
