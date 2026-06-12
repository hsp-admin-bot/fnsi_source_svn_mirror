package jp.co.nikkiso.ntss.core.entity;

import jp.co.nikkiso.ntss.core.entity.entityListener.SysApplicationEntityListener;
import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import java.sql.Timestamp;


/**
 * sys_application(アプリケーションダウンロード)のエンティティクラス
 */
@Entity(listener = SysApplicationEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "sys_application")
@Getter
@Setter
public class SysApplication extends BaseBlankEntity {

  /**
   * アプリケーション名
   */
  private String applicationName;

  /**
   * バージョン
   */
  private String version;

  /**
   * パス
   */
  private String path;

  /**
   * 表示順
   */
  private Long dispOrder;

  /**
   * 登録日時
   */
  private Timestamp regDate;

  /**
   * 更新日時
   */
  private Timestamp upDate;

  /**
   * 表示フラグ
   */
  private String isDisp;

  /**
   * 削除フラグ
   */
  private String isDel;
}
