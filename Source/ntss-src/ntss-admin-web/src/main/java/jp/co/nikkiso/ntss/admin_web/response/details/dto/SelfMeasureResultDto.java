package jp.co.nikkiso.ntss.admin_web.response.details.dto;

import lombok.Data;
/* add #9241 by zhangruixue 2023-08-01 --start */
/**
 * 自己診断結果の設定
 */
@Data
public class SelfMeasureResultDto {

  private String key;

  private String judge;

  private String caution_up;
  private String caution_low;

  private String failure_low;
  private String failure_up;
  /* add #9241 by zhangruixue 2023-08-01 --end */
}
