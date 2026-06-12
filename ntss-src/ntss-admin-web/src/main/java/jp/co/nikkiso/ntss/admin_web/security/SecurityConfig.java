package jp.co.nikkiso.ntss.admin_web.security;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.web.SessionTimeoutManageFilter;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.http.converter.json.JacksonJsonHttpMessageConverter;
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
import org.springframework.security.web.DefaultRedirectStrategy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.AuthenticationFailureHandler;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.security.web.authentication.www.BasicAuthenticationFilter;
import org.springframework.security.web.authentication.logout.LogoutSuccessHandler;
import org.springframework.security.web.authentication.session.CompositeSessionAuthenticationStrategy;
import org.springframework.security.web.authentication.session.ConcurrentSessionControlAuthenticationStrategy;
import org.springframework.security.web.authentication.session.RegisterSessionAuthenticationStrategy;
import org.springframework.security.web.authentication.session.SessionAuthenticationStrategy;
import org.springframework.security.web.authentication.session.SessionFixationProtectionStrategy;
import org.springframework.security.web.context.HttpSessionSecurityContextRepository;
import org.springframework.security.web.csrf.CookieCsrfTokenRepository;
import org.springframework.security.web.csrf.CsrfToken;
import org.springframework.security.web.csrf.CsrfTokenRequestAttributeHandler;
import org.springframework.security.web.session.ConcurrentSessionFilter;
import org.springframework.security.web.session.HttpSessionEventPublisher;
import org.springframework.security.web.session.SessionInformationExpiredEvent;
import org.springframework.security.web.session.SessionInformationExpiredStrategy;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Spring Security Configuration
 */
@Configuration
@EnableWebSecurity
@EnableMethodSecurity(prePostEnabled = true)
public class SecurityConfig {

  @Bean
  WebSecurityCustomizer webSecurityCustomizer() {
    return web -> web.ignoring().requestMatchers(publicPaths(
        "/css/**",
        "/fonts/**",
        "/img/**",
        "/js/**",
        "/*.js",
        "/local/**",
        "/manifest.json",
        "/service-worker.js",
        "/precache-manifest**",
        "/index.html",
        "/assets/**",    // Vite ビルド出力（hashed CSS/JS/画像）
        /* delete by #10977 2024-10-29 start */
        /* add by chamaojia 2023-08-30 [9599] service-workerによって生成されたtxtファイルが存在し、このファイルは認証を必要としない  --start */
        //"/*.txt",
        /* add by chamaojia 2023-08-30 [9599] service-workerによって生成されたtxtファイルが存在し、このファイルは認証を必要としない  --end */
        /* delete by #10977 2024-10-29 start */
        // #10977 DEL by Z.t. There's no needs to send a request which cross several services to visit S3 bucket.
//        Uri.GATHERING_DOWNLOAD,
        // add 9601 印刷サーバにて帳票の印刷が行われない　吉 start
        Uri.PRINT_DATA_DOWNLOAD_OTHER,
        // add 9601 印刷サーバにて帳票の印刷が行われない　吉 end
        // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dou start
        Uri.SIGN_OUT,
        // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dou end
        // add #10160 複数端末同時サインイン無効時の強制サインアウトが動作しない。 dou start
        Uri.SIGN_OUT_ANOTHER,
        // add #10160 複数端末同時サインイン無効時の強制サインアウトが動作しない。 dou end
        // add 10718 by kangjie 20240710 start
        "/devtools.html",
        // add 10718 by kangjie 20240710 end
        // add #9238 CL証明書を使用したサインインで、違う施設のCL証明書を使用して認証エラーになった際の画面が期待する画面になっていない 20260408 start
        "/error/404-certificate.html"
        // add #9238 CL証明書を使用したサインインで、違う施設のCL証明書を使用して認証エラーになった際の画面が期待する画面になっていない 20260408 end
        // del #10977 インジェクション対応 高 start
        //Uri.PRINT_DATA_DOWNLOAD
        // del #10977 インジェクション対応 高 end
    ));
  }

  @Bean
  SecurityFilterChain securityFilterChain(HttpSecurity http, AuthenticationManager authenticationManager) throws Exception {
    http
        .authenticationManager(authenticationManager)
        .headers(headers -> headers
            .frameOptions(frame -> frame.sameOrigin())
            .contentSecurityPolicy(csp -> csp.policyDirectives("frame-ancestors 'self'")))
        .authorizeHttpRequests(authorize -> authorize
            .requestMatchers(HttpMethod.OPTIONS, "/**").denyAll()
            .requestMatchers(publicPaths(
                "/",
                "/index",
                "/error",
                Uri.LOGIN,
                Uri.LOGOUT,
                Uri.FACILITY_LOGIN_METHOD,
                Uri.FACILITY_GET_USER_ID,
                Uri.USE_SYS_HASH,
                Uri.SIGN_IN_MANAGER_NO_AUTH_DELETE,
                Uri.SIGN_IN_MANAGER_NO_AUTH_SELECT,
                Uri.SIGN_IN_MANAGER_CHECK_SESSIONTIMEOUT,
                Uri.SIGN_IN_MANAGER_COLOR_CODE,
                Uri.CLIENT_CERTIFICATE,
                Uri.REGISTER_OTP_AT_SIGN_IN_NO_AUTH,
                Uri.WEBSOCKET_CONNECT_STATUS,
                Uri.OTP_FAILURE_CNT_HASH,
                Uri.URL_SIGNIN,
                Uri.IS_SIGNIN_DISP,
                LoggingConstant.LOGGER_RESET.REQUEST_MAPPING + LoggingConstant.LOGGER_RESET.ACCESS_URI))
            .permitAll()
            .requestMatchers(publicPaths("/*.msi")).authenticated()
            .anyRequest().authenticated())
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
            .csrfTokenRequestHandler(new CsrfTokenRequestAttributeHandler())
            .ignoringRequestMatchers(Uri.LOGIN));

    // 認証フィルター設定
    http.addFilterBefore(sessionTimeoutManageFilter(), UsernamePasswordAuthenticationFilter.class);
    http.addFilterAt(authenticationFilter(authenticationManager), UsernamePasswordAuthenticationFilter.class);

    // セッションタイムアウトさせたクライアントからのアクセス処理
    http.addFilterBefore(concurrentSessionFilter(), ConcurrentSessionFilter.class);

    http.addFilterAfter(new CsrfCookieFilter(), BasicAuthenticationFilter.class);

    return http.build();
  }

  @Bean
  AuthenticationManager authenticationManager(AuthenticationConfiguration authenticationConfiguration) throws Exception {
    return authenticationConfiguration.getAuthenticationManager();
  }

  @Bean
  SessionTimeoutManageFilter sessionTimeoutManageFilter() {
    return new SessionTimeoutManageFilter();
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

  @Bean
  JacksonJsonHttpMessageConverter jacksonJsonHttpMessageConverter() {
    return new JacksonJsonHttpMessageConverter();
  }

  /**
   * ログアウト成功ハンドラーを返す.
   */
  @Bean
  LogoutSuccessHandler logoutSuccessHandler() {
    return new NtssCustomLogoutSuccessHandler();
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
    filter.setSecurityContextRepository(new HttpSessionSecurityContextRepository());
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

  // 参照されるSESSION_REGISTRYを固定する
  private static final SessionRegistry SESSION_REGISTRY = new SessionRegistryImpl();

  /**
   * {@link SessionRegistry} Bean定義.
   * @return {@link SessionRegistry}
   */
  @Bean
  SessionRegistry sessionRegistry() {
    return SESSION_REGISTRY;
  }

  /**
   * {@link CompositeSessionAuthenticationStrategy} Bean定義.
   * @return {@link CompositeSessionAuthenticationStrategy}
   */
  @Bean
  CompositeSessionAuthenticationStrategy concurrentSessionControlAuthenticationStrategy() {
    ConcurrentSessionControlAuthenticationStrategy concurrentAuthenticationStrategy =
        new ConcurrentSessionControlAuthenticationStrategy(sessionRegistry());
    // n ： 最大セッション数、-1 ：  セッション無制限
    concurrentAuthenticationStrategy.setMaximumSessions(-1);
    concurrentAuthenticationStrategy.setExceptionIfMaximumExceeded(true);
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

  /**
   * {@link ConcurrentSessionFilter} Bean定義.
   * @return {@link ConcurrentSessionFilter}
   */
  @Bean
  public ConcurrentSessionFilter concurrentSessionFilter() {
    // タイムアウトされたセッションにアクセスが来た際のイベント処理
    return new ConcurrentSessionFilter(sessionRegistry(), new SessionInformationExpiredStrategy() {
      @Override
      public void onExpiredSessionDetected(SessionInformationExpiredEvent event) throws IOException, ServletException {
        HttpServletRequest request = event.getRequest();
        // セッション切断処理によりエラー応答が戻り、ServiceWorker上の処理でメンテナンス画面が表示されてしまう為、もう一度同じ画面にリダイレクトさせて回避する
        DefaultRedirectStrategy redirectStrategy = new DefaultRedirectStrategy();
        redirectStrategy.sendRedirect(event.getRequest(), event.getResponse(), request.getRequestURL().toString());
      }
    });
  }

  private String[] publicPaths(String... patterns) {
    return patterns;
  }

  private static class CsrfCookieFilter extends OncePerRequestFilter {
    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
        throws ServletException, IOException {
      CsrfToken csrfToken = (CsrfToken) request.getAttribute(CsrfToken.class.getName());
      if (csrfToken != null) {
        csrfToken.getToken();
      }
      filterChain.doFilter(request, response);
    }
  }

  // 施設毎にSessionの有効期限を設定している為、Cookieの有効期限は無効とする.
  //  /**
  //   * {@link ServletContextInitializer} Bean定義.
  //   * @return {@link ServletContextInitializer}
  //   */
  //  @Bean
  //  public ServletContextInitializer servletContextInitializer() {
  //    ServletContextInitializer servletContextInitializer = new ServletContextInitializer() {
  //      @Override
  //      public void onStartup(ServletContext servletContext) throws ServletException {
  //        servletContext.getSessionCookieConfig().setMaxAge(3600);
  //      }
  //    };
  //    return servletContextInitializer;
  //  }
}
