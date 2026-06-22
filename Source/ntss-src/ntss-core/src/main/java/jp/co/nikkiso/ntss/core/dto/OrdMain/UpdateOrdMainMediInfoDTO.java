package jp.co.nikkiso.ntss.core.dto.OrdMain;

import jp.co.nikkiso.ntss.core.entity.OrdMain;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class UpdateOrdMainMediInfoDTO {

  private OrdMain ordMain;
  // 最終更新指示者ID
  private Long upIndUseId;
  // 最終更新者ID
  private Long upUseId;

  private String ordInfo;

  private String rstInfo;
}
