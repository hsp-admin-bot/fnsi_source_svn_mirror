package jp.co.nikkiso.ntss.admin_web.response.bvms.dto.bv;

import jp.co.nikkiso.ntss.admin_web.response.bvms.dto.BVMSGraphInfoDTO;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class BVGraphDTO extends BVMSGraphInfoDTO {
    BVGraph1CoordinateDTO graph1Coordinates;
    BVGraph2CoordinateDTO graph2Coordinates;
}
