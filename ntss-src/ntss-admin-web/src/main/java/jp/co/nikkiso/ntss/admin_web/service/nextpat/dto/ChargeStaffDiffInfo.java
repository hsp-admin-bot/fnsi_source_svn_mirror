package jp.co.nikkiso.ntss.admin_web.service.nextpat.dto;

import lombok.Data;

/**
 * pat_main  charge_staff_info
 */
@Data
public class ChargeStaffDiffInfo {
  private String ctl_no;
  private String is_main;
  private String staff_cd;
  private String is_charge;
  private String disp_order;
  private String is_puncture;
}
