package jp.co.nikkiso.ntss.core.entity;

import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.Transient;
import org.seasar.doma.jdbc.entity.NamingType;

@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class BaseBlankEntity {
  /**
   * 操作者ID(ログ出力用)
   * ログ出力時にこの変数に格納されている利用者IDをログファイルに出力する.
   */
  @Transient
  private Long operatorId;

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
  // add #8642 「治療記録>変更履歴の内容が不正」について、対応する。 dengshen start
  @Transient
  private Boolean updateFlg = true; // デフォルトでは差分ログを処理します
  // add #8642 「治療記録>変更履歴の内容が不正」について、対応する。 dengshen end
}
