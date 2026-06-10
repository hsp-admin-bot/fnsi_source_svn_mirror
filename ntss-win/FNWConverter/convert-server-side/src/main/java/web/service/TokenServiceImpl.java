package web.service;

import io.jsonwebtoken.JwtBuilder;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.impl.DefaultClaims;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import web.authentication.BaseUser;
import web.config.EventLoggerUtil;
import web.constant.LoggingConstant;
import web.exception.InvalidTokenException;
import web.constant.TokenConstant;
import web.logger.LogLevel;

import javax.crypto.KeyGenerator;
import javax.crypto.SecretKey;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.util.*;

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
        DefaultClaims claims = retrieveDefaultClaims(jwtToken);
        Object tokenExpirationDateLong = claims.get(TokenConstant.TOKEN_EXPIRATION_DATE);
        Object userIdNumber = claims.get(TokenConstant.USER_ID);
        if (tokenExpirationDateLong == null || userIdNumber == null) {
            throw new InvalidTokenException("無効なトークン");
        }
        if (new Date((Long) tokenExpirationDateLong).before(new Date())) {
            throw new InvalidTokenException("トークン有効期限エラー");
        }
        return new BaseUser(((Number) userIdNumber).longValue());
    }

    private DefaultClaims retrieveDefaultClaims(String token) throws InvalidTokenException {
        try {
            return (DefaultClaims) Jwts.parser().setSigningKey(TokenConstant.SECRET_KEY).parse(token).getBody();
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
        tokenData.put(TokenConstant.TOKEN_CREATE_DATE, calendar.getTime());
        calendar.add(Calendar.MINUTE, tokenTimeOut);
        tokenData.put(TokenConstant.TOKEN_EXPIRATION_DATE, calendar.getTime());
        JwtBuilder jwtBuilder = Jwts.builder();
        jwtBuilder.setExpiration(calendar.getTime());
        jwtBuilder.setClaims(tokenData);
        jwtBuilder.signWith(SignatureAlgorithm.HS512, TokenConstant.SECRET_KEY);
        return jwtBuilder.compact();
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
            // KeyGeneratorオブジェクトを作成し、HMACSHA 256としてアルゴリズムを指定します
            KeyGenerator keyGen = KeyGenerator.getInstance("HmacSHA256");
            // SecureRandomによるランダムシードの取得
            SecureRandom secureRandom = new SecureRandom();
            keyGen.init(keyLength, secureRandom);
            // ランダム鍵の生成
            SecretKey secretKey = keyGen.generateKey();
            if (secretKey != null) {
                byte[] encodedKey = secretKey.getEncoded();
                // あるいは16進表現を直接印刷することもできます
                StringBuilder hexKey = new StringBuilder();
                for (byte b : encodedKey) {
                    hexKey.append(String.format("%02x", b));
                }
                return hexKey.toString();
            } else {
                System.out.println("鍵を生成できませんでした。");
                return null;
            }
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
}
