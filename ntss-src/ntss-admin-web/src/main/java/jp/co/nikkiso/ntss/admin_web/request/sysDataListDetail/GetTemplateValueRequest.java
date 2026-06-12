package jp.co.nikkiso.ntss.admin_web.request.sysDataListDetail;

import java.util.List;
import lombok.Data;

/**
 * POST {@code /getTemplateValue} 用リクエスト.
 */
@Data
public class GetTemplateValueRequest {

  private List<Long> patIdList;

  private String startDate;

  private String endDate;

  private Integer templateCd;

  /** 治療予定・治療記録ページング時のみ指定 */
  private Integer offset;

  /** 治療予定・治療記録ページング時のみ指定 */
  private Boolean isOnlyRst;
}
