package jp.co.nikkiso.ntss.core.entity;

import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.Getter;
import lombok.Setter;

/**
 * WebSocket認証コードのEntity.
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mnt_websocket_certification")
@Getter
@Setter
public class MntWebsocketCertification extends BaseEntity {

  /**
   * 認証コード
   */
  @Id
  private String certificationCd;

  /**
   * 施設コード.
   */
  private String facilityCd;
}
