package jp.co.nikkiso.ntss.admin_web.service.bvms;

import java.util.List;

import jp.co.nikkiso.ntss.admin_web.response.bvms.dto.BVMSFilterDTO;
import jp.co.nikkiso.ntss.admin_web.response.bvms.dto.bv.BVGraphDTO;
import jp.co.nikkiso.ntss.admin_web.response.bvms.dto.ddm.DDMGraphDTO;
import jp.co.nikkiso.ntss.admin_web.response.bvms.dto.ht.HtGraphDTO;
import jp.co.nikkiso.ntss.admin_web.response.bvms.dto.rr.RRGraphDTO;
import jp.co.nikkiso.ntss.admin_web.response.bvms.dto.rr.RRGraphFilterDTO;
import jp.co.nikkiso.ntss.api.service.report.ReportChartService.ChartImageType;

public interface BVMSReportChartService {

    List<byte[]> getBVChart(Long ordNo, ChartImageType type, BVGraphDTO dto, BVMSFilterDTO filter);
    
    List<byte[]> getDDMChart(Long ordNo, ChartImageType type, DDMGraphDTO dto, BVMSFilterDTO filter);
    
    List<byte[]> getHtChart(Long ordNo, ChartImageType type, HtGraphDTO dto, BVMSFilterDTO filter);
    
    List<byte[]> getRRChart(Long ordNo, ChartImageType type, RRGraphDTO dto, RRGraphFilterDTO filter);
}
