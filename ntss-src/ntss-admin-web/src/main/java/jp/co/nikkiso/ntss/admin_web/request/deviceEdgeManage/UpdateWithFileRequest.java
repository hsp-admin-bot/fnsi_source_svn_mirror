package jp.co.nikkiso.ntss.admin_web.request.deviceEdgeManage;

import jp.co.nikkiso.ntss.core.entity.MntDeviceEdgeManage;
import lombok.Data;

@Data
public class UpdateWithFileRequest {
  private MntDeviceEdgeManage manageParam;

  private String bucket;

  private String fileName;

}
