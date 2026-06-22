package jp.co.nikkiso.ntss.core.entity.custom;

import java.sql.Timestamp;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * クラスには、受信した患者情報が含まれます。.
 * @author QuanTS
 *
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class ReceivedPatientInfo{
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
     * 開いた
     */
    private String isOpen;

    /**
     * 受理
     */
    private String receive;

    /**
     * 登録
     */
    private String signUp;

    /**
     * 更新日時
     */
    private Timestamp upDate;
    
	/** 開示元の表示患者ID */
	private String hosp_pat_id_src;
	
	/** 開示元の表示患者名 */
	private String pat_name_src;
	/**新規患者ID*/
	private long new_pat_id;
	/**新規病院患者ID*/
	private String new_hosp_pat_id;
	/**新規患者名*/
	private String new_pat_name;
}
