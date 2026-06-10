package jp.co.nikkiso.ntss.admin_web.response.bvms.dto.rr;

import jp.co.nikkiso.ntss.admin_web.response.bvms.dto.BVMSGraphInfoDTO;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class RRGraphDTO extends BVMSGraphInfoDTO {
    RRGraphCoordinateDTO graphCoordinates;
}
