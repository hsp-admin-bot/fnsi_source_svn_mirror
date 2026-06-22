package jp.co.nikkiso.ntss.admin_web.response.bvms.dto.ht;

import jp.co.nikkiso.ntss.admin_web.response.bvms.dto.BVMSGraphInfoDTO;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class HtGraphDTO extends BVMSGraphInfoDTO {
    HtGraph1CoordinateDTO graph1Coordinates;
    HtGraph2CoordinateDTO graph2Coordinates;
}
