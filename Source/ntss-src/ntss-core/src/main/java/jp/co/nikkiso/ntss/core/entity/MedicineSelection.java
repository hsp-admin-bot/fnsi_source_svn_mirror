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
public class MedicineSelection extends BaseBlankEntity {
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
    // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
    //private String medicineType;
    private Integer medicineType;
    // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
    /**
     * 薬剤禁忌アレルギータイプ
     */
    private String medicineTabooType;

    /**
     * 一般名処方の標準的な記載
     */
    private String genericName;

    /**
     * 一般名コード
     */
    private String genericCd;
    /**
     * 一般名処方禁忌アレルギータイプ
     */
    private String genericTabooType;

    /**
     * 指示単位
     */
    private String unit;
    /**
     * レセ単位
     */
    private String unitSecond;

    /**
     * 第一単位
     */
    private String genUnitFirst;

    /**
     * 第二単位
     */
    private String genUnitSecond;

    /**
     * 指示単位換算量
     */
    private BigDecimal unitDecimalPoint;

    // add 10225 処方薬剤選択に一般名処方が表示しない。 関  start

    /**
     * 検索コードリスト
     */
    private String searchCodeList;

    /**
     * 分類コード
     */
    private Integer classCd;

    /**
     * 個別医薬品コード(YJコード)
     */
    private String standardMedicineCd;
    // add 10225 処方薬剤選択に一般名処方が表示しない。 関  end
}
