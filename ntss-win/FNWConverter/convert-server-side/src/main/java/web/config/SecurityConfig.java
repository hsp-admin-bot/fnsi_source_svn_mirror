package web.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import web.constant.TokenConstant;
import web.service.TokenService;

import javax.annotation.PostConstruct;
import javax.annotation.Resource;

/**
 * Spring Security構成クラス
 */
@Configuration
@EnableWebSecurity
public class SecurityConfig extends WebSecurityConfigurerAdapter {

    @Resource
    private TokenAuthenticationManager tokenAuthenticationManager;

    @Resource
    TokenService tokenService;

    @Override
    public void configure(HttpSecurity http) throws Exception {
        http.authorizeRequests()
                .antMatchers("/login","/job/convert/health/check").permitAll() // オープン/loginインタフェースのみ
                .anyRequest().authenticated()
                .and()
                .exceptionHandling()
                .accessDeniedHandler(new CustomAccessDeniedHandler()) // カスタムアクセス拒否されたプロセッサ
                .authenticationEntryPoint(new CustomAuthenticationEntryPoint()); // カスタム認証失敗プロセッサ
        http.addFilterBefore(tokenAuthenticationFilter(), UsernamePasswordAuthenticationFilter.class);
        http.csrf().disable();
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