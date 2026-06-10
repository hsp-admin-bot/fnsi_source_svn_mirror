package jp.co.nikkiso.ntss.core.dto.ordMaterialSave;

import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
public class DeleteByConditionsAllDTO {

  // 施設コード
  private String facilityCd;
  // 患者ID
  private String patId;
  // データ基準番号
  private String suppliesBaseNo;
  // データ基準日
  private String baseDate;
  // データ発生元区分
  private String suppliesSourceClass;

  private List<String> suppliesClass;

  private List<String> indRstClassList;

  private List<String> suppliesCdListTc;

  private List<String> medicineMixCdListTj;

  private String medicineType;
}
