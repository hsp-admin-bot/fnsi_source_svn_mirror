package jp.co.nikkiso.ntss.core.entity;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class MstMedicineDto extends MstMedicine {

  private String classType;

  private Boolean isTaboo;

  private Boolean isAllergy;
}
