package jp.co.nikkiso.ntss.certificate_management.security;

import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UsernameNotFoundException;

/**
 * NTSSユーザー詳細サービスインターフェイス.
 */
public interface NtssUserDetailsService {

  /**
   * NTSS認証ユーザーを読み込む.
   * @param userId ユーザーID
   * @return ユーザー詳細情報
   * @throws UsernameNotFoundException
   */
  UserDetails loadUserByUserId(String userId) throws UsernameNotFoundException;
  
   /**
   * NTSS認証ユーザーを読み込む.
   * @param facilityCd 施設コード
   * @return ユーザー詳細情報
   * @throws UsernameNotFoundException
   */
  UserDetails loadUserByFacilityCd(String facilityCd) throws UsernameNotFoundException;
 }
