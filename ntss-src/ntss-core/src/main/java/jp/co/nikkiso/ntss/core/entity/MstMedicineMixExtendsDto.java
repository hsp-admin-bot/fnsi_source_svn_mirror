package jp.co.nikkiso.ntss.core.entity;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class MstMedicineMixExtendsDto extends MstMedicineMix{
  private Boolean isIncludeDel;
}
