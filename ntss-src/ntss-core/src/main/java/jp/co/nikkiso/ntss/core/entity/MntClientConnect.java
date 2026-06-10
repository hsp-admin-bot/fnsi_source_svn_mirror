package jp.co.nikkiso.ntss.core.entity;

import java.sql.Timestamp;

import jp.co.nikkiso.ntss.core.entity.entityListener.CommonEntityListener;
import org.seasar.doma.Entity;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;
import org.seasar.doma.Id;

import lombok.Getter;
import lombok.Setter;

/**
 * WebSocketクライアント接続状態
 */
@Entity(listener = CommonEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mnt_client_connect")
@Getter
@Setter
public class MntClientConnect extends BaseBlankEntity {
  /**
   * サービス稼働サーバのIPアドレス
   */
  @Id
  private String ipAddress;

  /**
   * 施設コード
   */
  @Id
  private String facilityCd;

  /**
   * サーバ種別[0：DeviceSrv/1:WebAppSrv]
   */
  private Integer serverType;

  /**
   * 登録日時
   */
  private Timestamp regDate;

  /**
   * 更新日時
   */
  private Timestamp upDate;
}
