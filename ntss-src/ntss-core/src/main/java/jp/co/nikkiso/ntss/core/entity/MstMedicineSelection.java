package jp.co.nikkiso.ntss.core.entity;

import java.math.BigDecimal;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 *  薬剤選択.
 *
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class MstMedicineSelection extends BaseBlankEntity {
    /**
     * 薬剤コード
     */
    private Integer medicineCd;
    /**
     * 薬剤名
     */
    private String medicineName;
    /**
     * 区分
     */
    private String standardMedicineCd;
    /**
     * 薬剤禁忌アレルギータイプ
     */
    private String medicineTabooType;

    /**
     * 指示単位
     */
    private String unit;
    /**
     * レセ単位
     */
    private String unitSecond;
    /**
     * 指示単位換算量
     */
    private BigDecimal unitDecimalPoint;
    /**
     * 薬剤分類コード
     */
    private Integer classCd;

}
