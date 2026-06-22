package jp.co.nikkiso.ntss.admin_web.response.bvms.dto.ddm;

import jp.co.nikkiso.ntss.admin_web.response.bvms.dto.BVMSGraphInfoDTO;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class DDMGraphDTO extends BVMSGraphInfoDTO{
    DDMGraph1CoordinateDTO graph1Coordinates;
    DDMGraph2CoordinateDTO graph2Coordinates;
}
