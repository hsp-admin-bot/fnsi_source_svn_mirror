package com.fnsi.cloudconverter.auth;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.lang.NonNull;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

/**
 * JWT 認証フィルター（全リクエストで動作）
 * トークン残り有効期限 < threshold の場合、新トークンを X-Renewed-Token ヘッダーで返す
 * 参照: 05_key_tech.md § 9 / 06_reference_admin_web.md § 3.3
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final JwtTokenProvider jwtTokenProvider;
    private final UserDetailsService userDetailsService;

    @Value("${security.jwt.renew-threshold-minutes:10}")
    private long renewThresholdMinutes;

    @Override
    protected void doFilterInternal(@NonNull HttpServletRequest request,
                                    @NonNull HttpServletResponse response,
                                    @NonNull FilterChain filterChain)
            throws ServletException, IOException {

        String token = extractToken(request);

        if (token != null && jwtTokenProvider.validateToken(token)) {
            String username = jwtTokenProvider.getUsernameFromToken(token);
            try {
                UserDetails userDetails = userDetailsService.loadUserByUsername(username);

                UsernamePasswordAuthenticationToken auth =
                        new UsernamePasswordAuthenticationToken(
                                userDetails, null, userDetails.getAuthorities());
                auth.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                SecurityContextHolder.getContext().setAuthentication(auth);

                // 残り有効期限チェック: threshold 以下なら新トークン発行
                long remainingMs = jwtTokenProvider.getRemainingMillis(token);
                long thresholdMs = renewThresholdMinutes * 60 * 1000L;
                if (remainingMs > 0 && remainingMs < thresholdMs) {
                    String newToken = jwtTokenProvider.generateAccessToken(userDetails);
                    response.setHeader("X-Renewed-Token", newToken);
                    log.debug("[JWT] トークン自動続約: user={}, 残り={}ms", username, remainingMs);
                }
            } catch (AuthenticationException ex) {
                SecurityContextHolder.clearContext();
                log.warn("[JWT] ユーザー解決失敗: user={}, reason={}", username, ex.getMessage());
            }
        }

        filterChain.doFilter(request, response);
    }

    private String extractToken(HttpServletRequest request) {
        String header = request.getHeader("Authorization");
        if (header != null && header.startsWith("Bearer ")) {
            return header.substring(7);
        }
        return null;
    }
}
