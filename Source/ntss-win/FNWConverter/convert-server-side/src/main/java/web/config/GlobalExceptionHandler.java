package web.config;

import org.json.JSONObject;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import web.constant.TokenConstant;
import web.exception.AccountNotFoundException;
import web.exception.WrongCredentialsException;
import web.utils.DateTimeFormatterUtil;

import java.time.LocalDateTime;

@ControllerAdvice
public class GlobalExceptionHandler {

    /**
     * ログイン失敗異常ブロック、統一エラーフォーマットに戻る
     *
     * @param ex
     * @return
     */
    @ExceptionHandler(WrongCredentialsException.class)
    public ResponseEntity<String> handleLoginException(Exception ex) {
        JSONObject errorJson = new JSONObject();
        errorJson.put("Message", TokenConstant.LOGIN_ERROR);
        errorJson.put("code", HttpStatus.UNAUTHORIZED.value());
        errorJson.put("timeStamp", DateTimeFormatterUtil.dateTimeFormatter(LocalDateTime.now(), "yyyy-MM-dd HH:mm:ss"));
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(errorJson.toString());
    }

    /**
     * ログインアカウントに異常な返信メッセージはありません
     *
     * @param ex
     * @return
     */
    @ExceptionHandler(AccountNotFoundException.class)
    public ResponseEntity<String> handleAccountNotFoundException(Exception ex) {
        JSONObject errorJson = new JSONObject();
        errorJson.put("Message", TokenConstant.ACCOUNTNOTFOUNF_ERROR);
        errorJson.put("code", HttpStatus.UNAUTHORIZED.value());
        errorJson.put("timeStamp", DateTimeFormatterUtil.dateTimeFormatter(LocalDateTime.now(), "yyyy-MM-dd HH:mm:ss"));
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(errorJson.toString());
    }


}
