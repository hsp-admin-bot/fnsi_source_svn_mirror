package jp.co.nikkiso.ntss.core.entity.custom;

import java.sql.Timestamp;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * クラスには、公開患者情報が含まれています。.
 * @author QuanTS
 *
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class PublicPatientInfo {
    
    /**
     * 患者名ID
     */
    private Long patNameId;
    /**
     * 施設名.
     */
    private String facilityName;

    /**
     * 患者IDの宛先
     */
    private Long patId;

    /**
     * 施設コード宛先
     */
    private String facilityCd;

    /**
     * 承認
     */
    private String approve;

    /**
     * 開いた
     */
    private String isOpen;

    /**
     * 担当医
     */
    private String doctorInCharge;

    /**
     * 承認日
     */
    private Timestamp approveDate;

    /**
     * 登録
     */
    private String signUp;

    /**
     * 登録日時
     */
    private Timestamp regDate;

    /**
     * 更新日時
     */
    private Timestamp upDate;
}
