package com.fnsi.cloudconverter.auth;

import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * 在線本番 DB の mst_user_authentication テーブルで認証する UserDetailsService
 *
 * username 規約: "{facilityCd}:{dispUserId}"
 *   例) "11166:user01"
 *
 * 参照: ntss-admin-web NtssUserDetailsServiceImpl（認証方式の流用）
 */
@Service
public class ConverterUserDetailsService implements UserDetailsService {

    private final JdbcTemplate onlineProdJdbc;

    public ConverterUserDetailsService(
            @Qualifier("onlineAuthJdbc") JdbcTemplate onlineProdJdbc) {
        this.onlineProdJdbc = onlineProdJdbc;
    }

    /**
     * @param username "{facilityCd}:{dispUserId}" 形式の複合キー
     */
    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        String[] parts = username.split(":", 2);
        if (parts.length != 2) {
            throw new UsernameNotFoundException("username の形式が不正です: " + username);
        }
        String facilityCd = parts[0];
        String dispUserId = parts[1];

        String sql = """
                SELECT user_password
                FROM mst_user_authentication
                WHERE facility_cd = ? AND disp_user_id = ?
                """;

        String hashedPassword;
        try {
            hashedPassword = onlineProdJdbc.queryForObject(sql, String.class, facilityCd, dispUserId);
        } catch (org.springframework.dao.EmptyResultDataAccessException e) {
            throw new UsernameNotFoundException(
                    "ユーザーが見つかりません: facility_cd=" + facilityCd + ", disp_user_id=" + dispUserId);
        }

        if (hashedPassword == null) {
            throw new UsernameNotFoundException("パスワードが未設定です: " + username);
        }

        return User.builder()
                .username(username)
                .password(hashedPassword)
                .authorities(List.of(new SimpleGrantedAuthority("ROLE_USER")))
                .build();
    }
}
