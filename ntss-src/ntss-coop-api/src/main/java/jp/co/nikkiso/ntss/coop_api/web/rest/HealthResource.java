package jp.co.nikkiso.ntss.coop_api.web.rest;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.coop_api.request.HealthUpdateRequest;
import jp.co.nikkiso.ntss.coop_api.response.ErrorMessage;
import jp.co.nikkiso.ntss.coop_api.response.HealthUpdateResult;
import jp.co.nikkiso.ntss.coop_api.service.HealthService;
import jp.co.nikkiso.ntss.coop_api.service.LogService;
import jp.co.nikkiso.ntss.core.entity.MntIfEdgeHealthmon;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;

@RestController
@RequestMapping("/health")
public class HealthResource {
  @Autowired
  private HealthService healthService;

  @Autowired
  private LogService logService;

  /**
   * エッジヘルスモニタ更新(/health/update)
   * @param request : {@link HealthUpdateRequest}
   * @return {@link ResponseEntity}
   */
  @PostMapping("/update")
  public ResponseEntity<?> update(@RequestBody HealthUpdateRequest request) {
    if (!request.validate()) {
      ErrorMessage error = new ErrorMessage(HttpStatus.BAD_REQUEST, "リクエストパラメータが不正または不足しています。"
          + "facility_cd:[" + request.getFacilityCd() + "],"
// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
          + "coop_version:[" + request.getCoopVersion() + "],"
// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
          + "if_edge_no:[" + request.getIfEdgeNo() + "],"
          + "healthmon_facility_conn:[" + request.getHealthmonFacilityConn() + "],"
          + "healthmon_server_conn:[" + request.getHealthmonServerConn() + "]"
      );
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
      // ログメッセージ出力
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setFacilityCd(request.getFacilityCd());
      eventLogMessage.setDeviceEdgeNo((request.getIfEdgeNo()==null?"":request.getIfEdgeNo().toString()));
      eventLogMessage.setLogMessage(error.getMessage());
      eventLogMessage.setInvokeClass(this.getClass().getName());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
      return new ResponseEntity<>(error, HttpStatus.BAD_REQUEST);
    }

    try {
      MntIfEdgeHealthmon ifEdgeHealthmon = healthService.update(request);
      // 更新レコードが存在しない場合は、エラーを返す
      if (ifEdgeHealthmon == null) {
        // mod 2021-05-19 [JSON parse error:データ無し場合、NOT_FOUNDを返す]の対応 孫 start
//        ErrorMessage error = new ErrorMessage(HttpStatus.NO_CONTENT, "マスタデータに更新対象となるレコードが存在しません。");
        ErrorMessage error = new ErrorMessage(HttpStatus.NOT_FOUND, "マスタデータに更新対象となるレコードが存在しません。");
        // mod 2021-05-19 [JSON parse error:データ無し場合、NOT_FOUNDを返す]の対応 孫 end
        // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
        // ログメッセージ出力
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setFacilityCd(request.getFacilityCd());
        eventLogMessage.setDeviceEdgeNo((request.getIfEdgeNo()==null?"":request.getIfEdgeNo().toString()));
        eventLogMessage.setLogMessage(error.getMessage());
        eventLogMessage.setInvokeClass(this.getClass().getName());
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
        // mod 2021-05-19 [JSON parse error:データ無し場合、NOT_FOUNDを返す]の対応 孫 start
//        return new ResponseEntity<>(error, HttpStatus.NO_CONTENT);
        return new ResponseEntity<>(error, HttpStatus.NOT_FOUND);
        // mod 2021-05-19 [JSON parse error:データ無し場合、NOT_FOUNDを返す]の対応 孫 end
      }

      HealthUpdateResult result = new HealthUpdateResult(HttpStatus.OK, ifEdgeHealthmon);
      return new ResponseEntity<>(result, HttpStatus.OK);
    } catch (NtssException e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("エッジヘルスモニタ更新APIにて例外が発生しました。");
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
      eventLogMessage.setFacilityCd(request.getFacilityCd());
      eventLogMessage.setDeviceEdgeNo((request.getIfEdgeNo()==null?"":request.getIfEdgeNo().toString()));
      eventLogMessage.setInvokeClass(this.getClass().getName());
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
      logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI, null);

      ErrorMessage error = new ErrorMessage(HttpStatus.INTERNAL_SERVER_ERROR,
          "エッジヘルスモニタ更新APIにて例外が発生しました。");
      return new ResponseEntity<>(error, HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }
}
