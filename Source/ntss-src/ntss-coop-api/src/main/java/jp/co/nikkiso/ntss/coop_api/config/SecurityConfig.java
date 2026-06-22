package jp.co.nikkiso.ntss.coop_api.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.web.SecurityFilterChain;

/**
 * ntss-coop-apiで認証を無効化するクラス。
 */
@Configuration
@EnableWebSecurity
public class SecurityConfig {
  // 設定Beanを定義しないため、@Configureアノテーションは不要。

  @Bean
  SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
    http
        .headers(headers -> headers
            .frameOptions(frame -> frame.sameOrigin())
            .contentSecurityPolicy(csp -> csp.policyDirectives("frame-ancestors 'self'")))
        .authorizeHttpRequests(authorize -> authorize.anyRequest().permitAll())
        .csrf(csrf -> csrf.disable());
    return http.build();
  }
}
