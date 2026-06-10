package jp.co.nikkiso.ntss.coop_api.config;

import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;

import jp.co.nikkiso.ntss.core.exception.NtssException;

/**
 * ntss-coop-apiで認証を無効化するクラス。
 */
@EnableWebSecurity
public class SecurityConfig extends WebSecurityConfigurerAdapter {
  // 設定Beanを定義しないため、@Configureアノテーションは不要。

  @Override
  protected void configure(HttpSecurity http) throws Exception {
    http.authorizeRequests().anyRequest().permitAll();
    http.csrf().disable();
  }

  @Override
  protected void configure(AuthenticationManagerBuilder auth) {
    try {
      auth.inMemoryAuthentication();
    } catch (Exception e) {
      throw new NtssException("", e);
    }
  }
}
