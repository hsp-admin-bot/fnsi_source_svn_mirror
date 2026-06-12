package com.fnsi.cloudconverter.auth;

import com.fnsi.cloudconverter.auth.model.LoginRequest;
import com.fnsi.cloudconverter.auth.model.LoginResponse;
import com.fnsi.cloudconverter.auth.model.RefreshRequest;
import com.fnsi.cloudconverter.auth.model.RefreshResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.stereotype.Service;

/**
 * JWT 認証サービス実装
 * username = "{facilityCd}:{dispUserId}" の複合キーで Spring Security に委譲
 * パスワード検証は DaoAuthenticationProvider + BCryptPasswordEncoder が担う
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AuthServiceImpl implements AuthService {

    private final AuthenticationManager  authenticationManager;
    private final JwtTokenProvider       jwtTokenProvider;
    private final UserDetailsService     userDetailsService;

    @Override
    public LoginResponse login(LoginRequest request) {
        // "{facilityCd}:{dispUserId}" を username として Spring Security に認証委譲
        String compositeUsername = request.facilityCd() + ":" + request.dispUserId();

        Authentication auth = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(compositeUsername, request.password()));

        UserDetails userDetails = (UserDetails) auth.getPrincipal();
        String accessToken  = jwtTokenProvider.generateAccessToken(userDetails);
        String refreshToken = jwtTokenProvider.generateRefreshToken(userDetails);

        log.info("[AUTH] ログイン成功: facility={}, user={}", request.facilityCd(), request.dispUserId());
        return LoginResponse.of(accessToken, refreshToken, jwtTokenProvider.getExpirationSeconds());
    }

    @Override
    public RefreshResponse refresh(RefreshRequest request) {
        String refreshToken = request.refreshToken();
        if (!jwtTokenProvider.validateToken(refreshToken)) {
            throw new org.springframework.security.core.AuthenticationException(
                    "リフレッシュトークンが無効または期限切れです") {};
        }

        String compositeUsername = jwtTokenProvider.getUsernameFromToken(refreshToken);
        UserDetails userDetails  = userDetailsService.loadUserByUsername(compositeUsername);
        String newAccessToken    = jwtTokenProvider.generateAccessToken(userDetails);

        log.debug("[AUTH] トークン更新: user={}", compositeUsername);
        return RefreshResponse.of(newAccessToken, jwtTokenProvider.getExpirationSeconds());
    }
}
