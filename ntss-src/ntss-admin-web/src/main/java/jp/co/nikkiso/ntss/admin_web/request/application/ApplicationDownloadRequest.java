package jp.co.nikkiso.ntss.admin_web.request.application;

import jakarta.validation.constraints.Pattern;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

import lombok.Data;

/**
 * 単体アプリのダウンロードAPIのRequestクラス.
 */
@Data
public class ApplicationDownloadRequest {

  /**
   * ファイル名.
   */
  @NotBlank(message = "値がありません")
  @Size(max = 255, message = "長さが不正です。")
  @Pattern(regexp = "^[\\w\\-]+\\.[\\w\\-]+$", message = "形式が不正です。")
  private String filename;

}
