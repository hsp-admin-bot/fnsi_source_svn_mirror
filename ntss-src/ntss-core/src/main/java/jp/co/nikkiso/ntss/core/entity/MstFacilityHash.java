package jp.co.nikkiso.ntss.core.entity;

import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.Getter;
import lombok.Setter;

/**
 * 施設マスタのEntity.
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_facility_hash")
@Getter
@Setter
public class MstFacilityHash extends BaseEntity {

  /**
   * 施設コード.
   */
  @Id
  private String facilityCd;

  /**
   * ハッシュ値.
   */
  private String hashValue;

  /**
   * システム利用設定.
   */
  private String systemUseSetting;

  /**
   * アカウントロック設定.
   */
  private String accountLockSetting;

  /**
   * サインイン失敗回数.
   */
  private int failureCnt;

  /**
   * 2要素認証失敗回数.
   */
  private int otpFailureCnt;

  /**
   * URLサインイン設定.
   */
  private String urlSignin;

  /**
   * URLサインイン秘密鍵.
   */
  private String urlSigninSecretkey;
//add 7328 IDｍが医療情報DBにて管理されている 関俊楠 start
  /**
   * 値
   */
  private String value;
  //add 7328 IDｍが医療情報DBにて管理されている 関俊楠 end
  
  /**
   * サインインIF表示設定.
   */
  private String isSigninDisp;
}

