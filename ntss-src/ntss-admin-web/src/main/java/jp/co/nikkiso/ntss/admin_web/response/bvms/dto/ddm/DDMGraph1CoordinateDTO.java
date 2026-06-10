package jp.co.nikkiso.ntss.admin_web.response.bvms.dto.ddm;

import java.util.List;

import jp.co.nikkiso.ntss.admin_web.response.bvms.dto.CoordinateDTO;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class DDMGraph1CoordinateDTO {

    /**
     * Kt/V*100
     */
    private List<CoordinateDTO> ktVs;
    /**
     * URR(%)*10
     */
    private List<CoordinateDTO> uRRs;

    /**
     * イベントID
     */
    private List<CoordinateDTO> events;
}
