package jp.co.nikkiso.ntss.core.entity;

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
public class SysGenericMedicineSelection extends BaseBlankEntity {
    /**
     * 区分
     */
    private String medicineType;
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
     * レセ単位
     */
    private String unitSecond;
    /**
     * 第一単位
     */
    private String unitFirst;
    /**
     * 第一単位
     */
    private String searchCodeList;
}
