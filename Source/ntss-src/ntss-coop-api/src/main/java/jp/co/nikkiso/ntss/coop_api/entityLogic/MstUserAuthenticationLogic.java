package jp.co.nikkiso.ntss.coop_api.entityLogic;

import java.util.Map;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

import jp.co.nikkiso.ntss.coop_api.utils.EntityCreatorUtil;
import jp.co.nikkiso.ntss.core.entity.MstUserAuthentication;

@Component
public class MstUserAuthenticationLogic implements EntityLogic {

  /** レイアウトでパスワードを指定するキー */
  private static final String PARAM_KEY_USER_PASSWORD = "user_password";
  /** サインイン失敗回数 */
  private static final String KEY_FAILURE_CNT = "failure_cnt";

  /**
   * マップからエンティティを作成
   *
   * @param paramMap カラム名とカラム値のマップ
   * @return エンティティ
   */
  @Override
  public Object createEntity(Map<String, Object> paramMap) {
    return EntityCreatorUtil.createEntity(MstUserAuthentication.class, paramMap);
  }

  /**
   * 電文から抽出した項目をチェックおよび編集（新規登録時用）
   *
   * @param facilityCd 施設コード
   * @param paramMap 電文から抽出した項目のマップ
   */
  @Override
  public void check(String facilityCd, Map<String, Object> paramMap) {

    // パスワード暗号化
    encodePassword(paramMap);

    // デフォルト値設定
    // サインイン失敗回数
    paramMap.putIfAbsent(KEY_FAILURE_CNT, 0);

  }

  /**
   * 電文から抽出した項目をチェックおよび編集（更新時用）
   *
   * @param facilityCd 施設コード
   * @param paramMap 電文から抽出した項目のマップ
   * @param entity 対象テーブルから取得したエンティティ（更新の場合に使用）
   */
  @Override
  public void check(String facilityCd, Map<String, Object> paramMap, Object entity) {
    // パスワード暗号化
    encodePassword(paramMap);
  }

  /**
   * パスワードの暗号化
   * @param paramMap 電文から抽出した項目のマップ
   */
  private void encodePassword(Map<String, Object> paramMap) {

    String password = (String) paramMap.get(PARAM_KEY_USER_PASSWORD);

    // パスワードエンコーダを作成する。
    // FIXME ntss-admin-webプロジェクトに倣い、BCryptPasswordEncoderを使用する。
    // ただし、ntss-admin-webで定義されたコンポーネントはntss-coop-apiで使用できない。
    // コンポーネント単位で共通化する場合、パスワードエンコーダコンポーネントをntss-admin-webから
    // ntss-coreに移動し、ntss-admin-webとntss-coop-apiから参照するよう変更する。
    PasswordEncoder encoder = new BCryptPasswordEncoder();

    // パスワードが指定されている場合は暗号化する。
    String encoded = StringUtils.isEmpty(password) ? null : encoder.encode(password);
    paramMap.put(PARAM_KEY_USER_PASSWORD, encoded);

  }
}
