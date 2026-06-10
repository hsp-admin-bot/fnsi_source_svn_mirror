package web.service;


import web.authentication.BaseUser;
import web.exception.InvalidTokenException;

public interface TokenService {

    /**
     * 暗号化された基本的なユーザー情報の取得
     *
     * @param jwtToken
     * @return
     * @throws InvalidTokenException
     */
    BaseUser retrieveBaseUser(String jwtToken) throws InvalidTokenException;

    /**
     * 発行トークン
     *
     * @param baseUser
     * @return
     */
    String generateToken(BaseUser baseUser);

    /**
     * 指定されたビット長のJWT鍵を生成する
     *
     * @param keyLength
     * @return
     */
    String jwtKeyGenerator(int keyLength);

}
