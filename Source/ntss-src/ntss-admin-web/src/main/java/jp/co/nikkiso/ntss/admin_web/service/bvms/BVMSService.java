package jp.co.nikkiso.ntss.admin_web.service.bvms;

import org.springframework.web.multipart.MultipartFile;

import jp.co.nikkiso.ntss.core.exception.NotExistException;

public interface BVMSService<I, O> {

    public O getGraph(Long ordNo, I inputDTO) throws NotExistException;

    public O getGraphByUploadFile(Long ordNo, MultipartFile file, I filter);

}
