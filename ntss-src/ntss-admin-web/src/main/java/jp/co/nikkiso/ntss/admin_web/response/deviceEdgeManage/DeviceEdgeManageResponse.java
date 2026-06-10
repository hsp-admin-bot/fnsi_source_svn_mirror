package jp.co.nikkiso.ntss.admin_web.response.deviceEdgeManage;

import jp.co.nikkiso.ntss.admin_web.response.FlagAndMessageBaseResponse;
import jp.co.nikkiso.ntss.core.entity.MntDeviceEdgeManage;
import lombok.NoArgsConstructor;

/**
 * 条件送信キャンセルのResponse.
 */
@NoArgsConstructor
public class DeviceEdgeManageResponse extends FlagAndMessageBaseResponse {

  /**
   * コンストラクタ.
   * @param errorMessage エラーメッセージ
   */
  public DeviceEdgeManageResponse(String errorMessage) {
    super(errorMessage);
  }

  public MntDeviceEdgeManage manageParam;
}
