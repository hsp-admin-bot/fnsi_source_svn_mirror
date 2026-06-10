package jp.co.nikkiso.ntss.core.entity;

import lombok.Getter;
import lombok.Setter;

/**
 * {@inheritDoc}
 */
public class MstUserOTP {

    /**
     * ユーザーの秘密キー
     */
    @Getter
    @Setter
    private String MtsUserSecretKey;

    /**
     * ユーザーのQR画像
     */
    @Getter
    @Setter
    private String MstUserQR64;

    /**
     * 2要素認証
     *
     * @param MtsUserSecretKey  ユーザーの秘密キー
     * @param MstUserQR64    ユーザーのQR画像
     */
    public MstUserOTP(String MtsUserSecretKey, String MstUserQR64) {

        this.MtsUserSecretKey = MtsUserSecretKey;
        this.MstUserQR64 = MstUserQR64;
    }

}
