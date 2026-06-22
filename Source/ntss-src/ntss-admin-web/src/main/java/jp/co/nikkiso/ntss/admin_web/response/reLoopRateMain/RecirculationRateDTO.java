package jp.co.nikkiso.ntss.admin_web.response.reLoopRateMain;

import java.util.List;

import jp.co.nikkiso.ntss.core.entity.custom.OrdMainRstWeightInfo;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class RecirculationRateDTO {
    private List<RecirculationRateComment> comments;
    private OrdMainRstWeightInfo weightInfo;
}
