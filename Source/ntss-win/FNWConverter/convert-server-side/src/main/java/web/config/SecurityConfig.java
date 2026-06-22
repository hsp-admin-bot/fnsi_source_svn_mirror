package web.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import web.constant.TokenConstant;
import web.service.TokenService;

import jakarta.annotation.PostConstruct;
import jakarta.annotation.Resource;

/**
 * Spring Security構成クラス
 */
@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Resource
    private TokenAuthenticationManager tokenAuthenticationManager;

    @Resource
    TokenService tokenService;

    @Bean
    SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http.headers(headers -> headers
                        .frameOptions(frame -> frame.sameOrigin())
                        .contentSecurityPolicy(csp -> csp.policyDirectives("frame-ancestors 'self'")))
                .authorizeHttpRequests(authorize -> authorize
                        .requestMatchers("/login", "/job/convert/health/check").permitAll() // オープン/loginインタフェースのみ
                        .anyRequest().authenticated())
                .exceptionHandling(exceptions -> exceptions
                        .accessDeniedHandler(new CustomAccessDeniedHandler()) // カスタムアクセス拒否されたプロセッサ
                        .authenticationEntryPoint(new CustomAuthenticationEntryPoint())) // カスタム認証失敗プロセッサ
                .addFilterBefore(tokenAuthenticationFilter(), UsernamePasswordAuthenticationFilter.class)
                .csrf(csrf -> csrf.disable());
        return http.build();
    }

    /**
     * TokenAuthenticationFilterフィルタ処理情報を優先的に使用する
     *
     * @return
     */
    public TokenAuthenticationFilter tokenAuthenticationFilter() {
        return new TokenAuthenticationFilter(tokenAuthenticationManager);
    }

    /**
     * パスワードエンコーダを返す.
     */
    @Bean
    PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    /**
     * プログラム起動時にトークン署名鍵文字列を作成する(既定の長さ：256)
     */
    @PostConstruct
    public void init() {
        TokenConstant.SECRET_KEY = tokenService.jwtKeyGenerator(TokenConstant.SECRET_LENGTH);
    }
}