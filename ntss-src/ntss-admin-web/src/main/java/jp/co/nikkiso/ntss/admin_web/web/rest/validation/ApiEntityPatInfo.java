package jp.co.nikkiso.ntss.admin_web.web.rest.validation;

import javax.validation.constraints.Pattern;

import javax.validation.constraints.NotBlank;

import lombok.Getter;
import lombok.Setter;

public class ApiEntityPatInfo {

  /**
   * 風袋・除水データの更新
   */
  @Getter
  @Setter
  public static class ValiRemovalWater {
    @NotBlank(message="値がありません")
    @Pattern(regexp = "^[0-9]+",message="数値ではありません。")
    private String pat_id;
    @NotBlank(message="値がありません")
    private String off_water_info;
    @NotBlank(message="値がありません")
    private String info_cd;
    @NotBlank(message="値がありません")
    private String json_value;
    @NotBlank(message="値がありません")
    private String tare_info;
  }
  /**
   * 装置設定・次患者情報の更新
   */
  @Getter
  @Setter
  public static class ValiDeviceSetInfo {
    @NotBlank(message="値がありません")
    @Pattern(regexp = "^[0-9]+",message="数値ではありません。")
    private String pat_id;
    @NotBlank(message="値がありません")
    private String update_data;
  }
}
