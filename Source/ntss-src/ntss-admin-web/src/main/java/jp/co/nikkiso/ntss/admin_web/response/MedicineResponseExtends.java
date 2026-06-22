package jp.co.nikkiso.ntss.admin_web.response;

import lombok.Getter;
import lombok.Setter;

@Setter
@Getter
public class MedicineResponseExtends extends MedicineResponse {
  private Boolean isTaboo;

  private Boolean isAllergy;

  public MedicineResponseExtends(int medicineType, Integer medicineCd, String medicineName, String unit,
                                 String unitSecond, String isDisp, Integer classCd, Integer unitDecimalPoint,
                                 Integer unitDecimalPointSecond, Boolean isTaboo, Boolean isAllergy) {
    super(medicineType, medicineCd, medicineName, unit, unitSecond, isDisp, classCd, unitDecimalPoint, unitDecimalPointSecond);
    this.isTaboo = isTaboo;
    this.isAllergy = isAllergy;
  }
}
