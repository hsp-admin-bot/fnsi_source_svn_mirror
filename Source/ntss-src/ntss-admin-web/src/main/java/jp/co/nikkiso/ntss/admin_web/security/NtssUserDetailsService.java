package jp.co.nikkiso.ntss.admin_web.security;

import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UsernameNotFoundException;

/**
 * NTSSユーザー詳細サービスインターフェイス.
 */
public interface NtssUserDetailsService {

  /**
   * NTSS認証ユーザーを読み込む.
   *
   * @param username ユーザーID
   * @param facilityHashValue 施設コードハッシュ値
   * @param cardCd カードコード
   * @return ユーザー詳細情報
   * @throws UsernameNotFoundException
   */
  UserDetails loadUserByUsernameAndFacilityCd(String username, String facilityHashValue, String cardCd) throws UsernameNotFoundException;

}
