package web.config;

import org.json.JSONObject;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.AuthenticationEntryPoint;
import org.springframework.security.web.access.AccessDeniedHandler;
import org.springframework.stereotype.Component;
import web.constant.TokenConstant;
import web.utils.DateTimeFormatterUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;

@Component
public class CustomAccessDeniedHandler implements AccessDeniedHandler {
    /**
     * アクセス権の無効化
     *
     * @param request
     * @param response
     * @param e
     * @throws IOException
     * @throws ServletException
     */
    @Override
    public void handle(HttpServletRequest request, HttpServletResponse response, AccessDeniedException e) throws IOException, ServletException {
        // アクセス拒否時の例外処理ロジック
        JSONObject errorMessageson = new JSONObject();
        errorMessageson.put("code", HttpStatus.UNAUTHORIZED.value());
        errorMessageson.put("Message", TokenConstant.MESSAGE_UNAUTHORIZED);
        errorMessageson.put("timeStamp", DateTimeFormatterUtil.dateTimeFormatter(LocalDateTime.now(), "yyyy-MM-dd HH:mm:ss"));
        response.setStatus(HttpStatus.UNAUTHORIZED.value());
        response.setCharacterEncoding(StandardCharsets.UTF_8.toString()); // 文字エンコードをUTF-8に設定する
        response.getWriter().write(errorMessageson.toString());
    }
}

@Component
class CustomAuthenticationEntryPoint implements AuthenticationEntryPoint {

    /**
     * springSecurity例外プロセッサが結果を返す
     *
     * @param request
     * @param response
     * @param e
     * @throws IOException
     * @throws ServletException
     */
    @Override
    public void commence(HttpServletRequest request, HttpServletResponse response, AuthenticationException e) throws IOException, ServletException {
        // 認証失敗時の例外処理ロジック
        JSONObject errorMessageson = new JSONObject();
        errorMessageson.put("code", HttpStatus.UNAUTHORIZED.value());
        errorMessageson.put("Message", TokenConstant.MESSAGE_FORBIDDEN);
        errorMessageson.put("timeStamp", DateTimeFormatterUtil.dateTimeFormatter(LocalDateTime.now(), "yyyy-MM-dd HH:mm:ss"));
        response.setStatus(HttpStatus.UNAUTHORIZED.value());
        response.setCharacterEncoding(StandardCharsets.UTF_8.toString()); // 文字エンコードをUTF-8に設定する
        response.getWriter().write(errorMessageson.toString());
    }
}
