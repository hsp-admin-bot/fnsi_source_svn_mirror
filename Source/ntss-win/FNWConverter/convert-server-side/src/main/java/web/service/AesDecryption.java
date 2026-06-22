package web.service;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ResponseStatusException;

import javax.crypto.Cipher;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.util.Base64;
@Component
public class AesDecryption {
    String key = "YX3HC3VMB724YTPM3KCKMJE64HMWXKMU";
    String iv = "L7CJ99TE9RBLR7HK";

    public  String decrypt(String encryptedText) throws Exception {
        //#12737 【securify】convert-server-sideが落ちる,ファイルのアップロードチェック start
        try {
            byte[] decodedEncryptedText = Base64.getDecoder().decode(encryptedText);
            SecretKeySpec secretKeySpec = new SecretKeySpec(key.getBytes(StandardCharsets.UTF_8), "AES");
            IvParameterSpec ivParameterSpec = new IvParameterSpec(iv.getBytes(StandardCharsets.UTF_8));

            Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
            cipher.init(Cipher.DECRYPT_MODE, secretKeySpec, ivParameterSpec);

            byte[] decryptedBytes = cipher.doFinal(decodedEncryptedText);
            return new String(decryptedBytes, StandardCharsets.UTF_8);
        }catch (Exception  e) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN);
        }
        //#12737 【securify】convert-server-sideが落ちる,ファイルのアップロードチェック end
    }
}
