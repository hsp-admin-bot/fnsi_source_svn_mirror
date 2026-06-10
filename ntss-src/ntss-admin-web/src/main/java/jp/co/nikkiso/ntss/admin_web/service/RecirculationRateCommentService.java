package jp.co.nikkiso.ntss.admin_web.service;

import jp.co.nikkiso.ntss.admin_web.response.reLoopRateMain.RecirculationRateDTO;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainRstWeightInfo;

public interface RecirculationRateCommentService {

    public RecirculationRateDTO get(Long ordNo);

    public void update(Long ordNo, OrdMainRstWeightInfo dto);
}
