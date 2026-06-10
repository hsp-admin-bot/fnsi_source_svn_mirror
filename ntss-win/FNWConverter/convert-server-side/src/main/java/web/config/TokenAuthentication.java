package web.config;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import web.authentication.BaseUser;
import java.util.Collection;
import java.util.List;

/**
 * カスタム権限処理クラス
 */
public class TokenAuthentication implements Authentication {

    private String token;
    private List<? extends GrantedAuthority> authorities;
    private boolean isAuthenticated;
    private BaseUser userEntity;

    public TokenAuthentication(String token) {
        this.token = token;
    }


    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return authorities;
    }

    public void setAuthorities(List<? extends GrantedAuthority> authorities) {
        this.authorities = authorities;
    }

    public String getToken() {
        return token;
    }

    public void setUserEntity(BaseUser userEntity) {
        this.userEntity = userEntity;
    }

    @Override
    public boolean isAuthenticated() {
        return isAuthenticated;
    }

    @Override
    public void setAuthenticated(boolean authenticated) {
        isAuthenticated = authenticated;
    }

    @Override
    public Object getCredentials() {
        return "N/A";
    }

    @Override
    public Object getDetails() {
        return null;
    }

    @Override
    public BaseUser getPrincipal() {
        return userEntity;
    }

    @Override
    public String getName() {
        return userEntity.getId().toString();
    }
}