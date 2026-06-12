package jp.co.nikkiso.ntss.admin_web.request.prescription;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import jakarta.validation.constraints.Digits;

import jp.co.nikkiso.ntss.admin_web.request.validator.NtssFlexibleDateTime;
import jp.co.nikkiso.ntss.admin_web.request.validator.NtssFlexibleDateTimeParseMode;
import lombok.Data;

@Data
public class OrdPrescriptionRequest {

  //mod #12666 #12667 securify】SQLインジェクション(High) まとめ zrx start
    /**
     * 患者ID
     */
    @NotNull
    @Digits(integer = 19, fraction = 0, message = "patIdは数字のみ指定可能です。")
    private Long patId;

    /**
     * 施設CD
     */
    // del FNSI-改修内容 他施設の場合、浅黄色背景にする dou start
    // @NotNull
    // del FNSI-改修内容 他施設の場合、浅黄色背景にする dou end
    @Pattern(regexp = "^[A-Za-z0-9]{6}$", message = "facilityCdは英数字6桁で指定してください。")
    @Size(min = 6, max = 6, message = "facilityCdは6桁で指定してください。")
    private String facilityCd;

    /**
     * 処方種別
     */
    private String prescriptionType;

    /**
     * 交付日From
     */
    @NtssFlexibleDateTime(mode = NtssFlexibleDateTimeParseMode.DATE_ONLY, allowEmpty = true)
    private String issueDateFrom;

    /**
     * 交付日To
     */
    @NtssFlexibleDateTime(mode = NtssFlexibleDateTimeParseMode.DATE_ONLY, allowEmpty = true)

    private String issueDateTo;

    /**
     * 交付状態
     */
    private String issueState;

    /**
     * 処方オーダー番号
     */
    @Digits(integer = 19, fraction = 0, message = "ordPrescriptionNoは数字のみ指定可能です。")
    private Long ordPrescriptionNo;
    //mod #12666 #12667 securify】SQLインジェクション(High) まとめ zrx end
    /**
     * 患者共有モデル
     */
    private String patientShareMode;
}
