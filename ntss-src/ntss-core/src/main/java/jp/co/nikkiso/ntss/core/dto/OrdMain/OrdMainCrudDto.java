package jp.co.nikkiso.ntss.core.dto.OrdMain;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class OrdMainCrudDto {
  private Long patId;
  private String facilityCd;
  private String treatmentSetCd;
  private String treatMethodFlag;
  private String startDate;
  private Integer indKurCd;
  private Integer indBedCd;
  private String indTreatStartTime;
  private Long upIndUserId;
  private Long upUserId;
  private String treatType;
  private String fnPatId;
  private String treatDays;
}
