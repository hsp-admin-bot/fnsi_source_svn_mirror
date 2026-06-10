package jp.co.nikkiso.ntss.device_edge_updater_front.request;

import jp.co.nikkiso.ntss.core.entity.MntDeviceEdgeUpdaterManage;
import lombok.Data;

@Data
public class UpdateWithFileRequest {
  private MntDeviceEdgeUpdaterManage manageParam;
  
  private String bucket;
  
  private String fileName;
}
