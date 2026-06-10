package jp.co.nikkiso.ntss.admin_web.security;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.config.annotation.method.configuration.EnableGlobalMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;
import org.springframework.security.core.session.SessionRegistry;
import org.springframework.security.core.session.SessionRegistryImpl;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.AuthenticationEntryPoint;
import org.springframework.security.web.authentication.AuthenticationFailureHandler;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.security.web.authentication.logout.HttpStatusReturningLogoutSuccessHandler;
import org.springframework.security.web.authentication.logout.LogoutSuccessHandler;
import org.springframework.security.web.authentication.session.CompositeSessionAuthenticationStrategy;
import org.springframework.security.web.authentication.session.ConcurrentSessionControlAuthenticationStrategy;
import org.springframework.security.web.authentication.session.RegisterSessionAuthenticationStrategy;
import org.springframework.security.web.authentication.session.SessionAuthenticationStrategy;
import org.springframework.security.web.authentication.session.SessionFixationProtectionStrategy;
import org.springframework.security.web.session.HttpSessionEventPublisher;

import java.util.ArrayList;
import java.util.List;

/**
 * Spring Security Configuration(テスト用).
 */
@Configuration
@EnableWebSecurity
@EnableGlobalMethodSecurity(prePostEnabled = false)
public class SecurityConfig extends WebSecurityConfigurerAdapter {

  /**
   * {@inheritDoc}
   */
  @Override
  protected void configure(HttpSecurity http) throws Exception {

    // 認可の設定
    http
      .authorizeRequests()
      .antMatchers(Uri.LOGIN).permitAll()
      .anyRequest().authenticated()
      .and()
      .exceptionHandling()
      .authenticationEntryPoint(authenticationEntryPoint());

  }

  /**
   * 認証エントリーポイントを返す.
   */
  @Bean
  AuthenticationEntryPoint authenticationEntryPoint() {
    return new NtssAuthenticationEntryPoint();
  }

  /**
   * 認証成功ハンドラーを返す.
   */
  @Bean
  AuthenticationSuccessHandler authenticationSuccessHandler() {
    return new NtssAuthenticationSuccessHandler();
  }

  /**
   * 認証失敗ハンドラーを返す.
   */
  @Bean
  AuthenticationFailureHandler authenticationFailureHandler() {
    return new NtssAuthenticationFailureHandler();
  }

  /**
   * ログアウト成功ハンドラーを返す.
   */
  @Bean
  LogoutSuccessHandler logoutSuccessHandler() {
    return new HttpStatusReturningLogoutSuccessHandler();
  }

  /**
   * 認証プロバイダーを返す.
   */
  @Bean
  AuthenticationProvider authenticationProvider() {
    return new NtssAuthenticationProvider();
  }

  /**
   * 認証フィルターを返す.
   * @throws Exception
   */
  @Bean
  UsernamePasswordAuthenticationFilter authenticationFilter() throws Exception {
    NtssAuthenticationFilter filter = new NtssAuthenticationFilter();
    filter.setAuthenticationManager(authenticationManager());
    filter.setFilterProcessesUrl(Uri.LOGIN);
    filter.setAuthenticationSuccessHandler(authenticationSuccessHandler());
    filter.setAuthenticationFailureHandler(authenticationFailureHandler());
    filter.setSessionAuthenticationStrategy(concurrentSessionControlAuthenticationStrategy());
    return filter;
  }

  /**
   * パスワードエンコーダを返す.
   */
  @Bean
  PasswordEncoder passwordEncoder() {
    return new BCryptPasswordEncoder();
  }

  /**
   * {@link SessionRegistry} Bean定義.
   * @return {@link SessionRegistry}
   */
  @Bean
  SessionRegistry sessionRegistry() {
    return new SessionRegistryImpl();
  }

  /**
   * {@link CompositeSessionAuthenticationStrategy} Bean定義.
   * @return {@link CompositeSessionAuthenticationStrategy}
   */
  @Bean
  CompositeSessionAuthenticationStrategy concurrentSessionControlAuthenticationStrategy() {
    ConcurrentSessionControlAuthenticationStrategy concurrentAuthenticationStrategy = new ConcurrentSessionControlAuthenticationStrategy(sessionRegistry());
    concurrentAuthenticationStrategy.setMaximumSessions(1);
    concurrentAuthenticationStrategy.setExceptionIfMaximumExceeded(false);
    List<SessionAuthenticationStrategy> delegateStrategies = new ArrayList<>();
    delegateStrategies.add(concurrentAuthenticationStrategy);
    delegateStrategies.add(new SessionFixationProtectionStrategy());
    delegateStrategies.add(new RegisterSessionAuthenticationStrategy(sessionRegistry()));

    return new CompositeSessionAuthenticationStrategy(delegateStrategies);
  }

  /**
   * {@link HttpSessionEventPublisher} Bean定義.
   * @return {@link HttpSessionEventPublisher}
   */
  @Bean
  public HttpSessionEventPublisher httpSessionEventPublisher() {
    return new HttpSessionEventPublisher();
  }

  /**
   * {@link NtssSessionFilter} Bean定義.
   * @return {@link NtssSessionFilter}
   */
  @Bean
  public NtssSessionFilter ntssSessionFilter() {
    return new NtssSessionFilter(sessionRegistry());
  }
}
