package jp.co.nikkiso.ntss.admin_web.request.motionRecord;

import lombok.Data;

import javax.validation.constraints.Digits;
import javax.validation.constraints.Pattern;

/**
 * 対処者更新APIのRequestクラス.
 */
@Data
public class UpdateCorrectionRequest {

  //mod #12659 securify SQLインジェクション(High) まとめ zrx start
  /**
   * ユーザID.
   */
  @Digits(integer = 19, fraction = 0, message = "userIdは数字のみ指定可能です。")
  private Long userId;

  /**
   * 装置動作記録番号.
   */
  @Pattern(regexp = "^[0-9]+$", message = "motionRecordNoは数字のみ指定可能です。")
  private String motionRecordNo;

  /**
   * 対処フラグ.
   * <p>
   * 0: 未済
   * 1: 済
   * </p>
   */
  @Pattern(regexp = "^[0-9]$", message = "isCorrectionは0～9の1文字のみ指定可能です。")
  //mod #12659 securify SQLインジェクション(High) まとめ zrx end
  private String isCorrection;

}
