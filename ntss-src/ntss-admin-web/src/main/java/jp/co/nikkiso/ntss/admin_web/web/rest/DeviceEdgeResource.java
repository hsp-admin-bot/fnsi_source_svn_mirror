package jp.co.nikkiso.ntss.admin_web.web.rest;

import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.response.DeviceEdgesResponse;
import jp.co.nikkiso.ntss.admin_web.service.deviceEdges.DeviceEdgesService;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.FUNCTION_CODE;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;

/**
 * デバイスエッジ稼働監視のResourceクラス.
 */
@RestController
@RequestMapping(Uri.DEVICE_EDGE)
public class DeviceEdgeResource {

  /**
   * デバイスエッジService.
   */
  @Autowired
  DeviceEdgesService deviceEdgesService;

	@Autowired
	LogService logService;

  // wp アプリケーションログの適正化 Add Start
  @Autowired
  LogEventUtils logEventUtils;
  // wp アプリケーションログの適正化 Add End

  /**
   * 顧客・デバイスエッジ一覧を取得.
   *
   * @param userId ユーザID
   * @return デバイスエッジ稼働監視のResponse
   */
  @GetMapping("/{userId}")
  public ResponseEntity<?> getDeviceEdges(@PathVariable Long userId) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.DEVICE_EDGE ;
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      userId);
    // wp アプリケーションログの適正化 Add End

//    // ログ出力
//    EventLogMessage eventLogMessage = new EventLogMessage();
//    eventLogMessage.setLogMessage("REST request to get DeviceEdges : "+ userId);
//    logService.log(LogLevel.DEBUG, eventLogMessage,FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, SERVICE_NAME.REMS,
//    null);
//    // レスポンス生成

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, AFTER_LOG_FLG_INFO, mappingUrl, null,
      userId);
    // wp アプリケーションログの適正化 Add End
    DeviceEdgesResponse response = deviceEdgesService.createDeviceEdgesResponse(userId);

    return new ResponseEntity<>(response, HttpStatus.OK);
  }

  /**
   * クラス名取得
   */
  private String getClassName() {
    return this.getClass().getName();
  }

  /**
   * メソッド名取得
   */
  private String getMethodName() {
    return Thread.currentThread().getStackTrace()[2].getMethodName();
  }

}
