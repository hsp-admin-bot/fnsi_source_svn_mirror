package jp.co.nikkiso.ntss.core.dto.OrdMain;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@AllArgsConstructor
public class OrdNoTreatDateCopyDto {
  private Long ordNo;
  private String treatDate;
  private Integer bedCd;
}
