package jp.co.nikkiso.ntss.admin_web.service.nextpat.dto;

import lombok.Data;

/**
 * ord_main  ind_medi_info  ind_equip_info
 */
@Data
public class IndMediEquipDiffInfo {
  private String medicineType;
  private String no;
  private String cd;
  private String amount;
  private String equipType;
}
