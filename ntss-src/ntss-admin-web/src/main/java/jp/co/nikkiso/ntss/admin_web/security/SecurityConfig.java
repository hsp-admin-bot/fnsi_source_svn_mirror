package jp.co.nikkiso.ntss.admin_web.security;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.web.SessionTimeoutManageFilter;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
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
import org.springframework.security.web.DefaultRedirectStrategy;
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
import org.springframework.security.web.session.ConcurrentSessionFilter;
import org.springframework.security.web.session.HttpSessionEventPublisher;
import org.springframework.security.web.session.SessionInformationExpiredEvent;
import org.springframework.security.web.session.SessionInformationExpiredStrategy;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;

/**
 * Spring Security Configuration
 */
@Configuration
@EnableWebSecurity
@EnableGlobalMethodSecurity(prePostEnabled = true)
public class SecurityConfig extends WebSecurityConfigurerAdapter {

  /**
   * {@inheritDoc}
   */
  @Override
  public void configure(WebSecurity web) throws Exception {
    // 以下のリクエストについてはセキュリティ設定を無視する
    web.ignoring().antMatchers(
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
    );
  }

  /**
   * {@inheritDoc}
   */
  @Override
  protected void configure(HttpSecurity http) throws Exception {

    //HTTPヘッダの認可の設定
    http
    .headers(headers -> headers
      .frameOptions(frame -> frame.sameOrigin())
      .contentSecurityPolicy(csp ->
        csp.policyDirectives("frame-ancestors 'self'")
      )
    );

    // 認可の設定
    http
        .authorizeRequests()
        .antMatchers(HttpMethod.OPTIONS, "/**").denyAll()
        .antMatchers(
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
            LoggingConstant.LOGGER_RESET.REQUEST_MAPPING + LoggingConstant.LOGGER_RESET.ACCESS_URI)
        .permitAll()
        .antMatchers("/*.msi").authenticated()
        .anyRequest().authenticated()
        .and()
        .exceptionHandling()
        .authenticationEntryPoint(authenticationEntryPoint());

    // ログアウト設定
    http
        .logout()
        .logoutUrl(Uri.LOGOUT)
        .invalidateHttpSession(true)
        .clearAuthentication(true)
        .deleteCookies(NtssAuthenticationConstants.COOKIE_NAME)
        .logoutSuccessHandler(logoutSuccessHandler())
        .permitAll();

    // 認証フィルター設定
    http.addFilterBefore(sessionTimeoutManageFilter(), UsernamePasswordAuthenticationFilter.class);
    http.addFilterAt(authenticationFilter(), UsernamePasswordAuthenticationFilter.class);

    // セッションタイムアウトさせたクライアントからのアクセス処理
    http.addFilterBefore(concurrentSessionFilter(), ConcurrentSessionFilter.class);

    // CSRF設定
    http
        .csrf()
        .csrfTokenRepository(CookieCsrfTokenRepository.withHttpOnlyFalse())
        .ignoringAntMatchers(Uri.LOGIN);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  protected void configure(AuthenticationManagerBuilder auth) throws Exception {
    auth.authenticationProvider(authenticationProvider());
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
    ConcurrentSessionControlAuthenticationStrategy concurrentAuthenticationStrategy = new ConcurrentSessionControlAuthenticationStrategy(
        sessionRegistry());
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
    ConcurrentSessionFilter c = new ConcurrentSessionFilter(sessionRegistry(), new SessionInformationExpiredStrategy() {
      @Override
      public void onExpiredSessionDetected(SessionInformationExpiredEvent event) throws IOException, ServletException {

        HttpServletRequest request = event.getRequest();
        // セッション切断処理によりエラー応答が戻り、ServiceWorker上の処理でメンテナンス画面が表示されてしまう為、もう一度同じ画面にリダイレクトさせて回避する
        DefaultRedirectStrategy redirectStrategy = new DefaultRedirectStrategy();
        redirectStrategy.sendRedirect(event.getRequest(), event.getResponse(), request.getRequestURL().toString());
      }
    });
    return c;
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
