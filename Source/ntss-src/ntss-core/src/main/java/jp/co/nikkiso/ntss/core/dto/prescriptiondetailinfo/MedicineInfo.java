package jp.co.nikkiso.ntss.core.dto.prescriptiondetailinfo;

import lombok.Data;

/**
 * add no.396処方薬 張岩
 */
@Data
public class MedicineInfo {
  private String Rp;
  private String type;
  private String unchg;
  private String F1;
  private String F2;
  private String F3;
  private String F4;
  private String F5;
  private String F6;
//  add 6725 処方画面でord_material_saveには正しく登録されない 関 start
  private String F7;
//  add 6725 処方画面でord_material_saveには正しく登録されない 関 end
  private String medicine_type;
  private String medicine_cd;
  private String medicine_unit1;
  private String medicine_unit2;
  private String R;
}
