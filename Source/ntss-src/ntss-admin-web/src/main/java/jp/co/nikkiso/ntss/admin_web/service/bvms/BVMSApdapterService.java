package jp.co.nikkiso.ntss.admin_web.service.bvms;

import jp.co.nikkiso.ntss.admin_web.response.bvms.dto.BVMSFilterDTO;
import jp.co.nikkiso.ntss.admin_web.response.bvms.dto.BVMSGraphDTO;
import jp.co.nikkiso.ntss.admin_web.response.bvms.dto.bv.BVGraphDTO;
import jp.co.nikkiso.ntss.admin_web.response.bvms.dto.ddm.DDMGraphDTO;
import jp.co.nikkiso.ntss.admin_web.response.bvms.dto.ht.HtGraphDTO;
import jp.co.nikkiso.ntss.admin_web.response.bvms.dto.rr.RRGraphDTO;
import jp.co.nikkiso.ntss.admin_web.response.bvms.dto.rr.RRGraphFilterDTO;

public interface BVMSApdapterService {

    public BVGraphDTO adaptBVGrapDTO(BVMSGraphDTO bvmsGraphDTO, BVMSFilterDTO inputDTO);

    public DDMGraphDTO adaptDDMGrapDTO(BVMSGraphDTO bvmsGraphDTO, BVMSFilterDTO filter);

    public HtGraphDTO adaptHtGraphDTO(BVMSGraphDTO bvmsGraphDTO, BVMSFilterDTO filter);

    public RRGraphDTO adaptRRGraphDTO(BVMSGraphDTO bvmsGraphDTO, RRGraphFilterDTO filter);
}
