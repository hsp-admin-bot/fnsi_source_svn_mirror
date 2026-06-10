package jp.co.nikkiso.ntss.certificate_management.security;

import jp.co.nikkiso.ntss.certificate_management.constant.ClientCertificateConstant.Uri;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnExpression;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder;
import org.springframework.security.config.annotation.method.configuration.EnableGlobalMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.builders.WebSecurity;
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
import org.springframework.security.web.csrf.CookieCsrfTokenRepository;
import org.springframework.security.web.session.HttpSessionEventPublisher;

import java.util.ArrayList;
import java.util.List;

/**
 * Spring Security Configuration
 */
@Configuration
@EnableWebSecurity
@EnableGlobalMethodSecurity(prePostEnabled = true)
public class SecurityConfig extends WebSecurityConfigurerAdapter {

  /**
   * サインイン後勝ち有効設定
   */
  @Value("${ntss.certificate.sign-in.restriction}")
  private Boolean signInRestriction;

  /**
   * {@inheritDoc}
   */
  @Override
  public void configure(WebSecurity web) throws Exception {
    // 以下のリクエストについてはセキュリティ設定を無視する
    web.ignoring().antMatchers("/css/**", "/fonts/**", "/img/**", "/js/**", "/local/**", "/manifest.json",
        "/service-worker.js", "/precache-manifest**", "/index.html");
  }

  /**
   * {@inheritDoc}
   */
  @Override
  protected void configure(HttpSecurity http) throws Exception {

    // 認可の設定
    http.authorizeRequests()
        .antMatchers("/", "/index", "/error", Uri.LOGIN, Uri.LOGOUT, Uri.CLUSERSETTING, Uri.CLFACILITYSETTING).permitAll()

        .antMatchers(Uri.CLDETAILS + "/selectByFacilityCdWithNameOnly")
        .hasAnyRole(NtssAuthenticationConstants.Authority.CL_GENERAL_ROLE,
            NtssAuthenticationConstants.Authority.CL_ADMIN_ROLE, NtssAuthenticationConstants.Authority.CL_FACILITY_ROLE)

        .antMatchers(Uri.CLDETAILS + "/**", Uri.CLFACILITY + "/getAllFacilities", Uri.CLFACILITY + "/getFacilitiesByCd",
        Uri.CLFACILITY + "/updateFacility", Uri.CLFACILITY + "/insertFacility", Uri.CLFACILITY + "/getFacilityByLikeName")
        .hasAnyRole(NtssAuthenticationConstants.Authority.CL_GENERAL_ROLE,
            NtssAuthenticationConstants.Authority.CL_ADMIN_ROLE)

        .antMatchers(Uri.CLUSER + "/**", Uri.CLFACILITY + "/**")
        .hasRole(NtssAuthenticationConstants.Authority.CL_ADMIN_ROLE)

        .anyRequest().authenticated().and().exceptionHandling().authenticationEntryPoint(authenticationEntryPoint());

    // ログアウト設定
    http.logout().logoutUrl(Uri.LOGOUT).invalidateHttpSession(true).clearAuthentication(true)
        .deleteCookies(NtssAuthenticationConstants.COOKIE_NAME).logoutSuccessHandler(logoutSuccessHandler())
        .permitAll();



    // 認証フィルター設定
    http.addFilterAt(authenticationFilter(), UsernamePasswordAuthenticationFilter.class);

    // CSRF設定
    http.csrf().csrfTokenRepository(CookieCsrfTokenRepository.withHttpOnlyFalse()).ignoringAntMatchers(Uri.LOGIN);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  protected void configure(AuthenticationManagerBuilder auth) throws Exception {
    auth.authenticationProvider(authenticationProvider());
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
    // //mod FNSI-【1006】最新の改修対象一覧.NO45を追加 周安寧 start
    // return new HttpStatusReturningLogoutSuccessHandler();
    return new NtssCustomLogoutSuccessHandler();
    // //mod FNSI-【1006】最新の改修対象一覧.NO45を追加 周安寧 end
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
   *
   * @throws Exception
   */
  @Bean
  UsernamePasswordAuthenticationFilter authenticationFilter() throws Exception {
    NtssAuthenticationFilter filter = new NtssAuthenticationFilter();
    filter.setAuthenticationManager(authenticationManager());
    filter.setFilterProcessesUrl(Uri.LOGIN);
    filter.setAuthenticationSuccessHandler(authenticationSuccessHandler());
    filter.setAuthenticationFailureHandler(authenticationFailureHandler());
    if (signInRestriction == true) {
      filter.setSessionAuthenticationStrategy(concurrentSessionControlAuthenticationStrategy());
    }
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
   *
   * @return {@link SessionRegistry}
   */
  @Bean
  SessionRegistry sessionRegistry() {
    return new SessionRegistryImpl();
  }

  /**
   * {@link CompositeSessionAuthenticationStrategy} Bean定義.
   *
   * @return {@link CompositeSessionAuthenticationStrategy}
   */
  @Bean
  CompositeSessionAuthenticationStrategy concurrentSessionControlAuthenticationStrategy() {
    ConcurrentSessionControlAuthenticationStrategy concurrentAuthenticationStrategy = new ConcurrentSessionControlAuthenticationStrategy(
        sessionRegistry());
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
   *
   * @return {@link HttpSessionEventPublisher}
   */
  @Bean
  public HttpSessionEventPublisher httpSessionEventPublisher() {
    return new HttpSessionEventPublisher();
  }

  /**
   * {@link NtssSessionFilter} Bean定義.
   *
   * @return {@link NtssSessionFilter}
   */
  @Bean
  @ConditionalOnExpression("${ntss.certificate.sign-in.restriction}")
  public NtssSessionFilter ntssSessionFilter() {
    return new NtssSessionFilter(sessionRegistry());
  }
}
