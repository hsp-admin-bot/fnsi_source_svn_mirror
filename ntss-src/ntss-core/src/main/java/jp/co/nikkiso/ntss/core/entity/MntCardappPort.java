package jp.co.nikkiso.ntss.core.entity;

import jp.co.nikkiso.ntss.core.entity.entityListener.CommonEntityListener;
import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

import java.sql.Timestamp;

/**
 * カードアプリポート管理
 */
@Entity(listener = CommonEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mnt_cardapp_port")
@Getter
@Setter
public class MntCardappPort extends BaseBlankEntity {
  @Id
  /**
   * カードアプリのGUID
   */
  private String guid;

  /**
   * 施設コード
   */
  private String facilityCd;

  /**
   * クライアント識別子
   */
  private String clientKey;

  /**
   * ポート
   */
  private Integer port;

  /**
   * 登録日時
   */
  private Timestamp regDate;

  /**
   * 更新日時
   */
  private Timestamp upDate;
}
