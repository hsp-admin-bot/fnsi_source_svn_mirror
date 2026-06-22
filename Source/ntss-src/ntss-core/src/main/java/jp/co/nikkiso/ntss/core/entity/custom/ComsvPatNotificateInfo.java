package jp.co.nikkiso.ntss.core.entity.custom;

import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * 通信サーバ用患者情報ホスト報知設定取得
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class ComsvPatNotificateInfo {

  @Id
  /**
   * システムで管理する一意な患者ID
   */
  private Long patId;

  /**
   * ホスト報知設定
   */
  private String hostNotificationInfo;

}