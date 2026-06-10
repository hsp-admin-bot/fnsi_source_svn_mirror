package web.config;

import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.AuthenticationServiceException;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.stereotype.Component;
import web.authentication.BaseUser;
import web.exception.InvalidTokenException;
import web.service.TokenService;

import java.util.ArrayList;
import java.util.List;

@Component
public class TokenAuthenticationManager implements AuthenticationManager {

    private TokenService tokenService;

    public TokenAuthenticationManager(TokenService tokenService) {
        this.tokenService = tokenService;
    }

    /**
     * アクセス権チェック
     *
     * @param authentication
     * @return
     */
    @Override
    public Authentication authenticate(Authentication authentication) {
        if (authentication instanceof TokenAuthentication) {
            return processAuthentication((TokenAuthentication) authentication);
        } else {
            authentication.setAuthenticated(false);
            return authentication;
        }
    }

    /**
     * 検証トークン（検証失敗後のAuthenticationServiceException例外のスロー）
     *
     * @param authentication
     * @return
     */
    private TokenAuthentication processAuthentication(TokenAuthentication authentication) {
        String token = authentication.getToken();
        try {
            BaseUser baseUser = tokenService.retrieveBaseUser(token);
            return buildFullTokenAuthentication(authentication, baseUser);
        } catch (InvalidTokenException e) {
            throw new AuthenticationServiceException("無効なトークン");
        }
    }

    /**
     * 既存のアルゴリズムを使用してカスタム権限オブジェクトをカプセル化する
     *
     * @param authentication
     * @param baseUser
     * @return
     */
    private TokenAuthentication buildFullTokenAuthentication(TokenAuthentication authentication, BaseUser baseUser) {
        authentication.setAuthenticated(true);
        authentication.setAuthorities(getAuthorities());
        authentication.setUserEntity(baseUser);
        return authentication;
    }

    /**
     * デフォルト権限プロパティの取得
     *
     * @return
     */
    private List<? extends GrantedAuthority> getAuthorities() {
        List<GrantedAuthority> defaultAuthorities = new ArrayList<>();
        SimpleGrantedAuthority simpleGrantedAuthority = new SimpleGrantedAuthority("USER");
        defaultAuthorities.add(simpleGrantedAuthority);
        return defaultAuthorities;
    }
}
