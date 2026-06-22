package jp.co.nikkiso.ntss.admin_web.request.masterMaintenance.machine;

import lombok.Data;

import java.util.List;


/**
 * 指定装置削除のためのリクエスト
 */
@Data
public class MstMachineDeleteRequest {


  /**
   * 削除装置一覧
   */
  public List<MstMachineDeleteDetailRequest> machineList;
}

