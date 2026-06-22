package jp.co.nikkiso.ntss.core.entity;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class MstDialyzerDto extends MstDialyzer {
  private Boolean isTaboo;

  private Boolean isAllergy;
}
