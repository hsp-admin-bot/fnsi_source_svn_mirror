package jp.co.nikkiso.ntss.admin_web.request.waterSurvey;

import java.util.List;

import jp.co.nikkiso.ntss.admin_web.request.validator.NtssFlexibleDateTime;
import jp.co.nikkiso.ntss.admin_web.request.validator.NtssFlexibleDateTimeParseMode;
import lombok.Data;
import jakarta.validation.constraints.Digits;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;

/**
 * 水質調査の検索リクエスト
 */
@Data
public class WaterSurveySearchRequest {
  //mod #12668 #12669 securify】SQLインジェクション(High) まとめ zrx start
	/**
	 * 開始日（未指定時は null または空。値がある場合は {@link NtssFlexibleDateTime} に従う）
	 */
	@NtssFlexibleDateTime(mode = NtssFlexibleDateTimeParseMode.DATE_ONLY, allowEmpty = true)
	private String startDate;

	/**
	 * 終了日（未指定時は null または空。値がある場合は {@link NtssFlexibleDateTime} に従う）
	 */
	@NtssFlexibleDateTime(mode = NtssFlexibleDateTimeParseMode.DATE_ONLY, allowEmpty = true)
	private String endDate;

	/**
	 *
	 * リスト調査タイプコード
	 * */
	private List<@NotNull(message = "listSurveytypeCdにnullは指定できません。")
    @Digits(integer = 19, fraction = 0, message = "listSurveytypeCdは数字のみ指定可能です。") Long> listSurveytypeCd;
  //mod #12668 #12669 securify】SQLインジェクション(High) まとめ zrx end

	/**
	 *
	 * リストベッドグループコード
	 * */
  @Pattern(regexp = "^[0-9]+$", message="数値ではありません。")
	private String bedGroupCd;

}
