package jp.co.nikkiso.ntss.core.entity;

import jp.co.nikkiso.ntss.core.entity.entityListener.CommonEntityListener;
import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * 処方情報(認証DB)のEntity.
 */
@Entity(listener = CommonEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "ord_prescription")
@Getter
@Setter
public class OrdPrescription extends BaseEntity {

    /**
     * 処方オーダー番号
     */
    @Id
    private Long ordPrescriptionNo;

    /**
     * 施設CD
     */
    private String facilityCd;

// add FNSI-改修内容 カテゴリ選択の上に施設名を表示する dou start
    /**
     * 施設名
     */
    private String facilityName;
// add FNSI-改修内容 カテゴリ選択の上に施設名を表示する dou end

    /**
     * 患者ID
     */
    private Long patId;

    /**
     * 処方種別
     */
    private String prescriptionType;

    /**
     * 交付日
     */
    private String issueDate;

    /**
     * 交付状態
     */
    private String issueState;
    /**
     * 使用期限
     */
    private String expirationDate;

    /**
     * 処方詳細
     */
    private String prescriptionDetail;

    /**
     * 表示フラグ
     */
    private String isDisp;

    /**
     * 削除フラグ
     */
    private String isDel;

    // add #10553 処方連携 piao start
    /**
     * fn_ord_prescription_no
     */
    private String fnOrdPrescriptionNo;
    // add #10553 処方連携 piao End
}
