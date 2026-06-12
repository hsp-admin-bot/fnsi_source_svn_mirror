package com.fnsi.cloudconverter.auth;

import tools.jackson.databind.ObjectMapper;
import com.fnsi.cloudconverter.common.ErrorResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.AuthenticationEntryPoint;
import org.springframework.stereotype.Component;

import java.io.IOException;

/**
 * 未認証リクエストに 401 JSON を返すエントリーポイント
 * 参照: 06_reference_admin_web.md § 3.3（NtssAuthenticationEntryPoint の置換）
 */
@Component
@RequiredArgsConstructor
public class JwtAuthenticationEntryPoint implements AuthenticationEntryPoint {

    private final ObjectMapper objectMapper;

    @Override
    public void commence(HttpServletRequest request,
                         HttpServletResponse response,
                         AuthenticationException authException) throws IOException {
        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        response.setContentType(MediaType.APPLICATION_JSON_VALUE);
        response.setCharacterEncoding("UTF-8");

        ErrorResponse body = ErrorResponse.of(
                401, "Unauthorized",
                "認証が必要です。有効な JWT トークンを Authorization ヘッダーに指定してください。",
                request.getRequestURI());
        objectMapper.writeValue(response.getWriter(), body);
    }
}
