package jp.co.nikkiso.ntss.admin_web.response.mstMaster;

import jp.co.nikkiso.ntss.admin_web.response.mstMedicineMix.MstMedicineMixDto;
import jp.co.nikkiso.ntss.core.entity.MstDialyzerDto;
import jp.co.nikkiso.ntss.core.entity.MstEquipmentDto;
import jp.co.nikkiso.ntss.core.entity.MstMedicineDto;
import lombok.Data;

import java.util.List;

@Data
public class MstMasterResponse {

  private Long patId;

  private List<MstEquipmentDto> mstEquipmentDtoList;

  private List<MstDialyzerDto> mstDialyzerDtoList;

  private List<MstMedicineDto> mstMedicineDtoList;

  private List<MstMedicineMixDto> mstMedicineMixDtoList;
}
