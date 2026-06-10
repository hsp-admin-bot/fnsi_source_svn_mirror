package jp.co.nikkiso.ntss.admin_web.request.exam;

import jp.co.nikkiso.ntss.admin_web.request.validator.NtssFlexibleDateTime;
import jp.co.nikkiso.ntss.admin_web.request.validator.NtssFlexibleDateTimeParseMode;
import lombok.Data;

import java.util.List;
import javax.validation.constraints.Digits;
import javax.validation.constraints.NotNull;

/**
 * 検査依頼APIのRequestクラス.
 */
@Data
public class ExamRequest {
  //mod #12663 #12665 securify】SQLインジェクション(High) まとめ zrx start
  /**
   * 患者IDリスト.
   */
  private List<@NotNull(message = "patIdListにnullは指定できません。")
    @Digits(integer = 19, fraction = 0, message = "patIdListは数字のみ指定可能です。") Long> patIdList;

  /**
   * 表示期間(開始日).
   */
  @NtssFlexibleDateTime(mode = NtssFlexibleDateTimeParseMode.DATE_ONLY, allowEmpty = true)
  private String startDate;

  /**
   * 表示期間(終了日).
   */
  @NtssFlexibleDateTime(mode = NtssFlexibleDateTimeParseMode.DATE_ONLY, allowEmpty = true)
  private String endDate;
  //mod #12663 #12665 securify】SQLインジェクション(High) まとめ zrx end
  //add #12462 患者共有情報 by zrx start
  /**
   * 自施設(1) or 他施設(0)
   */
  private Integer patientShareMode;
  //add #12462 患者共有情報 by zrx end

}
