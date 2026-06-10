package jp.co.nikkiso.ntss.core.entity;

import java.sql.Timestamp;

import jp.co.nikkiso.ntss.core.entity.entityListener.CommonEntityListener;
import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * 処方情報(個人情報DB)のEntity.
 */
@Entity(listener = CommonEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "ord_personal_prescription")
@Getter
@Setter
public class OrdPersonalPrescription extends BaseBlankEntity {
    /**
     * 処方オーダー番号
     */
    @Id
    private Long ordPrescriptionNo;

    /**
     * 施設CD
     */
    private String facilityCd;

    /**
     * 患者ID
     */
    private Long patId;

    /**
     * 保険情報コード
     */
    private Long insuranceCd;

    /**
     * 公費負担者番号
     */
    private String insuPubNo;

    /**
     * 公費負担医療の受給者番号
     */
    private String insuPubPatNo;

    /**
     * 保険者番号
     */
    private String insuNo;

    /**
     * 被保険者証・被保険者手帳記号
     */
    private String insuPatMark;

    /**
     * 被保険者証・被保険者手帳番号
     */
    private String insuPatNo;

    /**
     * 被保険者
     */
    private String isInsured;

    /**
     * 被扶養者
     */
    private String isDependent;

    /**
     * 保険区分
     */
    private String insuKbn;

    /**
     * 保険医ID
     */
    private Long insuDrId;

    /**
     * 保険医氏名
     */
    private String insuDrName;

    /**
     * 保険医署名
     */
    private String insuDrSign;

    /**
     * 疑義照会
     */
    private String isDoubt;

    /**
     * 情報提供
     */
    private String isInformation;

    /**
     * 高一
     */
    private String isElderly;

    /**
     * 高７
     */
    private String isElderly7;

    /**
     * ６歳未満
     */
    private String isChild;

    /**
     * 備考情報
     */
    private String remarks;

    /**
     * 麻薬処方フラグ
     */
    private String isAnesthesia;

    /**
     * 麻薬備考情報
     */
    private String remarksAnesthesia;

    /**
     * 備考フリーコメント
     */
    private String remarksFree;

    /**
     * 表示フラグ
     */
    private String isDisp;

    /**
     * 削除フラグ
     */
    private String isDel;

    /**
     * 登録日時.
     */
    private Timestamp regDate;

    /**
     * 更新日時.
     */
    private Timestamp upDate;
    
    /**
     * 名前
     */
    private String insuranceName;
    
    /**
     * 略称
     */    
    private String insuNameShort;

    /**
     * 保険情報
     */
    private String insuInfo;

    /**
     * 公費情報
     */
    private String insuPubInfo;

    /**
     * セット情報
     */
    private String insuSetInfo;

    /**
     * 自費情報
     */
    private String insuSelfInfo;

    /**
     * 保険メモ1
     */
    private String memo1;

    /**
     * 保険メモ2
     */
    private String memo2;

    /**
     * リフィル可
     */
    private String isRefill;

    /**
     * リフィル回数
     */
    private Integer refillNum;

}
