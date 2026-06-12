package jp.co.nikkiso.ntss.admin_web.request.mstMaster;

import lombok.Data;

import java.util.List;

@Data
public class MstMasterRequest {

  private List<Long> patIds;

  private Boolean delFlag;
}
