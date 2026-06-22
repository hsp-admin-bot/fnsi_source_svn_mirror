package jp.co.nikkiso.ntss.core.entity;

import java.sql.Timestamp;

import org.seasar.doma.Entity;
import org.seasar.doma.Transient;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * Entity基底クラス.
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public abstract class BaseEntity {

  /**
   * 登録日時.
   */
  private Timestamp regDate;

  /**
   * 更新日時.
   */
  private Timestamp upDate;

  /**
   * 操作者ID(ログ出力用)
   * ログ出力時にこの変数に格納されている利用者IDをログファイルに出力する.
   */
  @Transient
  private Long operatorId;

  /**
   * 処理対象の施設コード(ログ出力用)
   * ログ出力時にこの変数に格納されている施設コードを元にロガーを取得する.
   * ※継承先のエンティティクラスに既に"facilityCd"がある場合にはこの変数への
   * 　設定は不要です.
   */
  @Transient
  private String targetFacilityCd;

  /**
   * クライアントIP
   * ログ出力時にこの変数に格納されている施設コードを元にロガーを取得する.
   * ※継承先のエンティティクラスに既に"facilityCd"がある場合にはこの変数への
   * 　設定は不要です.
   */
  @Transient
  private String clientIp;
//  add 8074 【デグレ】ログに誤った利用者が記録される 関 start
  /**
   * 利用者ID
   * ログ出力時にこの変数に格納されている施設コードを元にロガーを取得する.
   * ※継承先のエンティティクラスに既に"facilityCd"がある場合にはこの変数への
   * 　設定は不要です.
   */
  @Transient
  private String logUserId;
//  add 8074 【デグレ】ログに誤った利用者が記録される 関  end
}
