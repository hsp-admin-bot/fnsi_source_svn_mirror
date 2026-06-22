package jp.co.nikkiso.ntss.admin_web.service.nextpat.dto;

import lombok.Data;

/**
 * pat_unique  physical_info
 */
@Data
public class PatPhysicalInfo {
  private String dw;
  private String ctr;
  private String ctl_no;
  private String exam_date;
  private String indicator_start_date;
  private String inspect_date;
}
