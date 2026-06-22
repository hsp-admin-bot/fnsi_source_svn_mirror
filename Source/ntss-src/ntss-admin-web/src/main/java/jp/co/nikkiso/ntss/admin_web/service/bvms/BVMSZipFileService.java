package jp.co.nikkiso.ntss.admin_web.service.bvms;

import jp.co.nikkiso.ntss.admin_web.response.bvms.dto.BVMSZipFileStructureDTO;

public interface BVMSZipFileService {
    public BVMSZipFileStructureDTO buildZipFileStructureDTO(Long ordNo);
}
