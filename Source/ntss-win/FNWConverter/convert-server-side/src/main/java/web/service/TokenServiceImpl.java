package web.service;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import web.authentication.BaseUser;
import web.config.EventLoggerUtil;
import web.constant.LoggingConstant;
import web.constant.TokenConstant;
import web.exception.InvalidTokenException;
import web.logger.LogLevel;

import javax.crypto.KeyGenerator;
import javax.crypto.SecretKey;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.HexFormat;
import java.util.Map;

@Service
public class TokenServiceImpl implements TokenService {

    @Value("${token.token_timeout}")
    private Integer tokenTimeOut;

    @Autowired
    private EventLoggerUtil eventLoggerUtil;

    /**
     * 暗号化された基本的なユーザー情報の取得
     *
     * @param jwtToken
     * @return
     * @throws InvalidTokenException
     */
    @Override
    public BaseUser retrieveBaseUser(String jwtToken) throws InvalidTokenException {
        Claims claims = retrieveClaims(jwtToken);
        Object tokenExpirationDateLong = claims.get(TokenConstant.TOKEN_EXPIRATION_DATE);
        Object userIdNumber = claims.get(TokenConstant.USER_ID);
        if (tokenExpirationDateLong == null || userIdNumber == null) {
            throw new InvalidTokenException("無効なトークン");
        }
        if (new Date(((Number) tokenExpirationDateLong).longValue()).before(new Date())) {
            throw new InvalidTokenException("トークン有効期限エラー");
        }
        return new BaseUser(((Number) userIdNumber).longValue());
    }

    private Claims retrieveClaims(String token) throws InvalidTokenException {
        try {
            return Jwts.parser()
                .verifyWith(resolveSigningKey())
                .build()
                .parseSignedClaims(token)
                .getPayload();
        } catch (JwtException ex) {
            throw new InvalidTokenException("無効なトークン", ex);
        }
    }

    /**
     * 発行トークン
     *
     * @param baseUser
     * @return
     */
    @Override
    public String generateToken(BaseUser baseUser) {
        Calendar calendar = Calendar.getInstance();
        Map<String, Object> tokenData = new HashMap<>();
        tokenData.put(TokenConstant.USER_ID, baseUser.getId());
        tokenData.put(TokenConstant.TOKEN_CREATE_DATE, calendar.getTimeInMillis());
        calendar.add(Calendar.MINUTE, tokenTimeOut);
        tokenData.put(TokenConstant.TOKEN_EXPIRATION_DATE, calendar.getTimeInMillis());
        return Jwts.builder()
            .expiration(calendar.getTime())
            .claims(tokenData)
            .signWith(resolveSigningKey(), Jwts.SIG.HS512)
            .compact();
    }

    /**
     * 指定されたビット長のJWT鍵を生成する
     *
     * @param keyLength
     * @return
     */
    @Override
    public String jwtKeyGenerator(int keyLength) {
        try {
            KeyGenerator keyGen = KeyGenerator.getInstance("HmacSHA512");
            SecureRandom secureRandom = new SecureRandom();
            keyGen.init(keyLength, secureRandom);
            SecretKey secretKey = keyGen.generateKey();
            if (secretKey != null) {
                return HexFormat.of().formatHex(secretKey.getEncoded());
            }
            System.out.println("鍵を生成できませんでした。");
            return null;
        } catch (NoSuchAlgorithmException e) {
            eventLoggerUtil.recordLog(
                    LoggingConstant.DEFAULT_FACILITYCD,
                eventLoggerUtil.getEventLogMessage(
                        "jwtKeyGenerator(int keyLength) 指定されたビット長のJWT鍵を生成する："  + EventLoggerUtil.excetionStackTraceToString(e),
                        LoggingConstant.DEFAULT_FACILITYCD,
                        e.getClass().getName() + ".jwtKeyGenerator(int keyLength) "),
                LogLevel.ERROR);
            return null;
        }
    }

    private SecretKey resolveSigningKey() {
        return Keys.hmacShaKeyFor(HexFormat.of().parseHex(TokenConstant.SECRET_KEY));
    }
}
