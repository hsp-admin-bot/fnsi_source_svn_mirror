package jp.co.nikkiso.ntss.admin_web.service.bvms;

import java.util.List;

import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import jp.co.nikkiso.ntss.admin_web.response.bvms.dto.BVMSFilterDTO;
import jp.co.nikkiso.ntss.admin_web.response.bvms.dto.BVMSGraphDTO;
import jp.co.nikkiso.ntss.admin_web.response.bvms.dto.ErrorCellDTO;
import jp.co.nikkiso.ntss.admin_web.response.bvms.dto.ht.HtGraphDTO;
import jp.co.nikkiso.ntss.core.exception.NotExistException;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

@Service
public class HtGraphService extends AbstractBVMSService<BVMSFilterDTO, HtGraphDTO> {

  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
  @Autowired
  private LogService logService;
  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end

    @Override
    public HtGraphDTO getGraph(Long ordNo, BVMSFilterDTO inputDTO) throws NotExistException {
      //mod FNSI-8360 ljx start
      String facilityCd = getFacilityCdByOrdNo(ordNo);
      //return getGraph(ordNo, getBVMSGraphDTO(ordNo), inputDTO);
      return getGraph(ordNo, getBVMSGraphDTO(ordNo,facilityCd), inputDTO);
      //mod FNSI-8360 ljx end
    }

    @Override
    public HtGraphDTO getGraphByUploadFile(Long ordNo, MultipartFile file, BVMSFilterDTO filter) {
      //add FNSI-8360 ljx start
      try {
        String facilityCd = getFacilityCdByOrdNo(ordNo);
        //ファイル読み込みしたあと、読み込みされたファイルをローカル或はS3にアップロードする。
        this.uploadFileAttachment(file,ordNo+".csv",ordNo,facilityCd);
      } catch (Exception e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
      }
      //add FNSI-8360 ljx end
      return getGraph(ordNo, getBVMSGraphDTOFromUploadFile(file), filter);
    }

    private HtGraphDTO getGraph(Long ordNo, BVMSGraphDTO rawDataDTO, BVMSFilterDTO filter) {
        HtGraphDTO graph = new HtGraphDTO();
        List<ErrorCellDTO> errorCellDTOs = rawDataDTO.getErrorCells();
        if (errorCellDTOs != null && !errorCellDTOs.isEmpty()) {
            graph.setErrorCells(errorCellDTOs);
            return graph;
        }
        HtGraphDTO filterHtGraphDTO = apdapterService.adaptHtGraphDTO(rawDataDTO, filter);
        return filterHtGraphDTO;
    }

}
