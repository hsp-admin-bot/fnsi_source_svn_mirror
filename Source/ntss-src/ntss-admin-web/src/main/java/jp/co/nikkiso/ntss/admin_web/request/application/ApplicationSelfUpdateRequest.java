package jp.co.nikkiso.ntss.admin_web.request.application;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

import lombok.Data;

/**
 * 単体アプリの自己アップデートAPIのRequestクラス.
 */
@Data
public class ApplicationSelfUpdateRequest {

  /**
   * システム定義の管理番号.
   */
  @NotNull(message = "値がありません")
  @Min(value = 1, message = "数値ではありません。")
  private Integer ctl_no;

}
