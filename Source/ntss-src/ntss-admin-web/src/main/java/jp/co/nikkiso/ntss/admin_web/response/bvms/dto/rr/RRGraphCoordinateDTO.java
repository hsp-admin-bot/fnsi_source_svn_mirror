package jp.co.nikkiso.ntss.admin_web.response.bvms.dto.rr;

import java.util.List;

import jp.co.nikkiso.ntss.admin_web.response.bvms.dto.CoordinateDTO;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class RRGraphCoordinateDTO{
    /**
     * 再循環率(%)
     */
    private List<CoordinateDTO> recirculationRates;
}
