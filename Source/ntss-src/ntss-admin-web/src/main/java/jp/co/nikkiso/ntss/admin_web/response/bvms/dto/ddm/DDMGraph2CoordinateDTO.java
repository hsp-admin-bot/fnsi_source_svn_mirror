package jp.co.nikkiso.ntss.admin_web.response.bvms.dto.ddm;

import java.util.List;

import jp.co.nikkiso.ntss.admin_web.response.bvms.dto.CoordinateDTO;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class DDMGraph2CoordinateDTO{
    /**
     * 除水速度(L/h)*100
     */
    private List<CoordinateDTO> uFPSpeeds;
    /**
     * 血流量(mL/min)
     */
    private List<CoordinateDTO> bPSpeeds;
    /**
     * 透析液濃度(mS/cm)*10
     */
    private List<CoordinateDTO> totalConds;
    /**
     * 補液速度
     */
    private List<CoordinateDTO> qss;
}
