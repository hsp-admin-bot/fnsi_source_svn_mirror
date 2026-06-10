package jp.co.nikkiso.ntss.admin_web.response.mstMedicineMix;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class MstMedicineMixDto extends MstMedicineMixResponse {
  private Boolean isIncludeDel;

  private String classType;

  private Boolean isTaboo;

  private Boolean isAllergy;
}
