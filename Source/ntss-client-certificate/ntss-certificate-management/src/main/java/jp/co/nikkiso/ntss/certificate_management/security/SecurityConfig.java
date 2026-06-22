package jp.co.nikkiso.ntss.certificate_management.security;

import jp.co.nikkiso.ntss.certificate_management.constant.ClientCertificateConstant.Uri;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnExpression;
import org.springframework.boot.autoconfigure.condition.ConditionalOnMissingBean;
import org.springframework.http.converter.json.JacksonJsonHttpMessageConverter;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityCustomizer;
import org.springframework.security.core.session.SessionRegistry;
import org.springframework.security.core.session.SessionRegistryImpl;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.AuthenticationEntryPoint;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.AuthenticationFailureHandler;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.security.web.authentication.logout.LogoutSuccessHandler;
import org.springframework.security.web.authentication.session.CompositeSessionAuthenticationStrategy;
import org.springframework.security.web.authentication.session.ConcurrentSessionControlAuthenticationStrategy;
import org.springframework.security.web.authentication.session.RegisterSessionAuthenticationStrategy;
import org.springframework.security.web.authentication.session.SessionAuthenticationStrategy;
import org.springframework.security.web.authentication.session.SessionFixationProtectionStrategy;
import org.springframework.security.web.csrf.CookieCsrfTokenRepository;
import org.springframework.security.web.csrf.CsrfTokenRequestAttributeHandler;
import org.springframework.security.web.session.HttpSessionEventPublisher;

import java.util.ArrayList;
import java.util.List;

/**
 * Spring Security Configuration
 */
@Configuration
@EnableWebSecurity
@EnableMethodSecurity(prePostEnabled = true)
public class SecurityConfig {

  /**
   * サインイン後勝ち有効設定
   */
  @Value("${ntss.certificate.sign-in.restriction}")
  private Boolean signInRestriction;

  /**
   * Boot 4 では MappingJackson2HttpMessageConverter が削除されたため、
   * 認証ハンドラが注入する JSON 変換用 Bean を明示登録する（応答 JSON の挙動は従来と同じ）.
   */
  @Bean
  @ConditionalOnMissingBean
  JacksonJsonHttpMessageConverter jacksonJsonHttpMessageConverter() {
    return new JacksonJsonHttpMessageConverter();
  }

  @Bean
  WebSecurityCustomizer webSecurityCustomizer() {
    return web -> web.ignoring().requestMatchers(publicPaths(
        "/assets/**", "/css/**", "/fonts/**", "/img/**", "/js/**", "/local/**", "/manifest.json",
        "/service-worker.js", "/precache-manifest**", "/index.html"));
  }

  @Bean
  SecurityFilterChain securityFilterChain(HttpSecurity http, AuthenticationManager authenticationManager) throws Exception {
    http
        .authenticationManager(authenticationManager)
        // Spring Security 6 以降は SecurityContext の HttpSession への自動保存がデフォルトで無効。
        // ログイン直後は Vuex のみ成功し、要認証 API が 401 になるため、従来（SS5）と同じ挙動に戻す。
        .securityContext(securityContext -> securityContext.requireExplicitSave(false))
        .headers(headers -> headers
            .frameOptions(frame -> frame.sameOrigin())
            .contentSecurityPolicy(csp -> csp.policyDirectives("frame-ancestors 'self'")))
        .authorizeHttpRequests(authorize -> authorize
            .requestMatchers(publicPaths("/", "/index", "/error", Uri.LOGIN, Uri.LOGOUT, Uri.CLUSERSETTING, Uri.CLFACILITYSETTING))
            .permitAll()
            .requestMatchers(publicPaths(Uri.CLDETAILS + "/selectByFacilityCdWithNameOnly"))
            .hasAnyRole(
                NtssAuthenticationConstants.Authority.CL_GENERAL_ROLE,
                NtssAuthenticationConstants.Authority.CL_ADMIN_ROLE,
                NtssAuthenticationConstants.Authority.CL_FACILITY_ROLE)
            .requestMatchers(publicPaths(
                Uri.CLDETAILS + "/**",
                Uri.CLFACILITY + "/getAllFacilities",
                Uri.CLFACILITY + "/getFacilitiesByCd",
                Uri.CLFACILITY + "/updateFacility",
                Uri.CLFACILITY + "/insertFacility",
                Uri.CLFACILITY + "/getFacilityByLikeName"))
            .hasAnyRole(
                NtssAuthenticationConstants.Authority.CL_GENERAL_ROLE,
                NtssAuthenticationConstants.Authority.CL_ADMIN_ROLE)
            .requestMatchers(publicPaths(Uri.CLUSER + "/**", Uri.CLFACILITY + "/**"))
            .hasRole(NtssAuthenticationConstants.Authority.CL_ADMIN_ROLE)
            .anyRequest()
            .authenticated())
        .exceptionHandling(exceptionHandling -> exceptionHandling
            .authenticationEntryPoint(authenticationEntryPoint()))
        .logout(logout -> logout
            .logoutUrl(Uri.LOGOUT)
            .invalidateHttpSession(true)
            .clearAuthentication(true)
            .deleteCookies(NtssAuthenticationConstants.COOKIE_NAME)
            .logoutSuccessHandler(logoutSuccessHandler())
            .permitAll())
        .csrf(csrf -> csrf
            .csrfTokenRepository(CookieCsrfTokenRepository.withHttpOnlyFalse())
            // SS6 既定の Xor 検証は Cookie 平文トークン（Boot2 時の挙動）と不一致になるため、ヘッダー検証のみ従来どおりに戻す
            .csrfTokenRequestHandler(new CsrfTokenRequestAttributeHandler())
            .ignoringRequestMatchers(Uri.LOGIN));

    http.addFilterAt(authenticationFilter(authenticationManager), UsernamePasswordAuthenticationFilter.class);

    return http.build();
  }

  @Bean
  AuthenticationManager authenticationManager(AuthenticationConfiguration authenticationConfiguration) throws Exception {
    return authenticationConfiguration.getAuthenticationManager();
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
   */
  @Bean
  UsernamePasswordAuthenticationFilter authenticationFilter(AuthenticationManager authenticationManager) {
    NtssAuthenticationFilter filter = new NtssAuthenticationFilter();
    filter.setAuthenticationManager(authenticationManager);
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

  private String[] publicPaths(String... patterns) {
    return patterns;
  }
}
