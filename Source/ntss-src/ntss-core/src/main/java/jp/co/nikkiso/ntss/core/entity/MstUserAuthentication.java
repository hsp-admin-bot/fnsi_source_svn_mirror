package jp.co.nikkiso.ntss.core.entity;

import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.Getter;
import lombok.Setter;

/**
 * 利用者マスタ(認証DB)のEntity.
 */
@Entity(listener = BaseEntityListener.class , naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_user_authentication")
@Getter
@Setter
public class MstUserAuthentication extends BaseEntity {

  /**
   * 利用者ID(内部用ID).
   */
  @Id
  private Long userId;

  /**
   * 施設コード.
   */
  private String facilityCd;

  /**
   * 表示ユーザ名.
   */
  private String dispUserId;

  /**
   * パスワード.
   */
  private String userPassword;

  /**
   * サインイン失敗回数.
   */
  private Integer failureCnt;

  /**
   * パスワード履歴.
   */
  private String userPasswordHistory;

  //add 9437 利用者カードを登録しても利用者マスタのカード無効化列にボタンが表示しない。関俊楠 start
  /**
   * アクセスカード番号
   */
  private String cardIdm;
  //add 9437 利用者カードを登録しても利用者マスタのカード無効化列にボタンが表示しない。関俊楠 start
}
