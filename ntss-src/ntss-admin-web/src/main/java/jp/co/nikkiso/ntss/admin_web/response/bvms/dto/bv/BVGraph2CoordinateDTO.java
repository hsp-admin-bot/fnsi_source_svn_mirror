package jp.co.nikkiso.ntss.admin_web.response.bvms.dto.bv;

import java.util.List;

import jp.co.nikkiso.ntss.admin_web.response.bvms.dto.CoordinateDTO;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class BVGraph2CoordinateDTO{
    /**
     * 除水速度(L/h)*100
     */
    private List<CoordinateDTO> uFPSpeeds;

    private List<CoordinateDTO> pRRs;

    /**
     * 透析液濃度(mS/cm)*10
     */
    private List<CoordinateDTO> totalConds;
}
