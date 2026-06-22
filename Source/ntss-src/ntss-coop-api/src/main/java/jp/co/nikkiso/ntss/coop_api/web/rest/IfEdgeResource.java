package jp.co.nikkiso.ntss.coop_api.web.rest;

import java.util.List;
import java.util.Map;

import jp.co.nikkiso.ntss.coop_api.utils.IfEdgeConstants;
import jp.co.nikkiso.ntss.coop_api.web.websocket.IfEdgeMntSessionManager;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.MntIfEdgeManageDao;
import jp.co.nikkiso.ntss.core.entity.MntIfEdgeManage;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.coop_api.service.LogService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.coop_api.request.IfEdgeWebsocketRequest;
import jp.co.nikkiso.ntss.coop_api.response.ErrorMessage;
import jp.co.nikkiso.ntss.coop_api.response.IfEdgeRestResult;
import jp.co.nikkiso.ntss.coop_api.service.IfEdgeService;
import lombok.extern.slf4j.Slf4j;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

@RestController
@RequestMapping("/ifedge")
@Slf4j
public class IfEdgeResource {

  @Autowired
  IfEdgeService ifEdgeService;

  // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
  @Autowired
  private LogService logService;
  // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
  // add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 start
  @Autowired
  private IfEdgeMntSessionManager sessionManager;
  // add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 end

  //add FNSI-7806 mnt_if_edge_manageにresponse_statusが0のレコードが存在すると配信処理が行われない 劉全航 start
  @Autowired
  private MntIfEdgeManageDao mntIfEdgeManageDao;
  //add FNSI-7806 mnt_if_edge_manageにresponse_statusが0のレコードが存在すると配信処理が行われない 劉全航 end

  /**
   * 連携エッジ処理実行指示(/ifedge/maintenance)
   * @param request : {@link IfEdgeWebsocketRequest}
   * @return {@link ResponseEntity}
   */
  @PostMapping("/maintenance")
  public ResponseEntity<?> execute(@RequestBody IfEdgeWebsocketRequest request) {
    if (!request.validate()) {
      ErrorMessage error = new ErrorMessage(HttpStatus.BAD_REQUEST, "リクエストパラメータが不正または不足しています。"
          + "facility_cd:[" + request.getFacilityCd() + "],"
// add 2021-06-04 #5271:エッジのシリアルチェックがされていない 孫 start
          + "serial_no:[" + request.getSerialNo() + "],"
// add 2021-06-04 #5271:エッジのシリアルチェックがされていない 孫 end
          + "type:[" + request.getType() + "],"
          + "command:[" + request.getCommand() + "],"
          + "dirPath:[" + request.getDirPath() + "]"
      );
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
      // ログメッセージ出力
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setFacilityCd(request.getFacilityCd());
      eventLogMessage.setLogMessage(error.getMessage());
      eventLogMessage.setInvokeClass(this.getClass().getName());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
      return new ResponseEntity<>(error, HttpStatus.BAD_REQUEST);
    }

    // 処理実行指示
    //mod FNSI-7806 mnt_if_edge_manageにresponse_statusが0のレコードが存在すると配信処理が行われない 劉全航 start
//    IfEdgeRestResult result = ifEdgeService.devide(request);
    IfEdgeRestResult result = new IfEdgeRestResult();
    try{
      result = ifEdgeService.devide(request);
    }catch (Exception e){
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setFacilityCd(request.getFacilityCd());
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      eventLogMessage.setInvokeClass(this.getClass().getName());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      MntIfEdgeManage mntIfEdgeManage
        = mntIfEdgeManageDao.selectByFacilityCdAndStatus(request.getFacilityCd(), IfEdgeConstants.ResponseStatus.RUNNING.getStatus());
      if(mntIfEdgeManage != null){
        mntIfEdgeManage.setResponseStatus(IfEdgeConstants.ResponseStatus.ERROR.getStatus());
        mntIfEdgeManage.setEdgeResult(new MntIfEdgeManage.EdgeResult());
        mntIfEdgeManage.getEdgeResult().setResult(new MntIfEdgeManage.InnerEdgeResult());
        mntIfEdgeManage.getEdgeResult().getResult().setMessage(e.toString());
        mntIfEdgeManageDao.update(mntIfEdgeManage);
        result.setStatus(String.valueOf(HttpStatus.INTERNAL_SERVER_ERROR.value()));
        result.setResult(mntIfEdgeManage.getEdgeResult());
        return new ResponseEntity<>(result, HttpStatus.OK);
      }
    }
    //mod FNSI-7806 mnt_if_edge_manageにresponse_statusが0のレコードが存在すると配信処理が行われない 劉全航 end

    // サーバ側エラー制御時連携エッジ制御指示管理更新
    ifEdgeService.clearData(request.getFacilityCd(), result);
    // add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 start
    if("start".equals(request.getCommand()) || "restart".equals(request.getCommand())){
      //#10453 mod 死活監視が動作していない 2024-04-30 卓 start
      sessionManager.updateIfEdgeHealthmon(request.getFacilityCd(),"01","01",IfEdgeConstants.IF_EDGE_TYPE_ALL);
      //#10453 mod 死活監視が動作していない 2024-04-30 卓 end
     }
    // add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 end
    return new ResponseEntity<>(result, HttpStatus.OK);
  }
  // add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 start
  @PostMapping("/clientCount")
  public ResponseEntity<?> clientCount(@RequestBody IfEdgeWebsocketRequest request) {
    int clienCount = sessionManager.clientSessionCountByFacilityCd(request.getFacilityCd());
    return new ResponseEntity<>(clienCount, HttpStatus.OK);
  }
  // add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 end

  /**
   * 連携エッジ制御指示管理をリセット(/ifedge/resetStatusByFacilityCds)
   * @param request : {@link Map<String,Object>}
   * @return {@link ResponseEntity}
   */
  @PostMapping("/resetStatusByFacilityCds")
  public ResponseEntity<?> resetStatusByFacilityCds(@RequestBody Map<String,Object> request) {
    List<String> facilityCds = (List<String>) request.get("facility_cds");
    int result = 0;
    try{
      result = mntIfEdgeManageDao.updateStatusByFacilityCdsAndStatus(facilityCds, 0, -2);
    }catch (Exception e){
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      eventLogMessage.setInvokeClass(this.getClass().getName());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);

      ErrorMessage error = new ErrorMessage(HttpStatus.INTERNAL_SERVER_ERROR, "連携エッジ制御指示管理をリセットAPIにて例外が発生しました。");
      return new ResponseEntity<>(error, HttpStatus.INTERNAL_SERVER_ERROR);
    }
    return new ResponseEntity<>(result, HttpStatus.OK);
  }
  // add 6912 エッジの連携処理を停止しても稼働ビューア画面では正常と表示される 吉 start
  @PostMapping("/resetIfEdgeStatusByFacilityCd")
  public ResponseEntity<?> resetIfEdgeStatusByFacilityCd(@RequestBody Map<String,Object> request) {
//    String facilityCd = request.get("facilityCd").toString();
//    try{
//      sessionManager.updateIfEdgeHealthmon(facilityCd,"F1","F1");
//      sessionManager.deleteConnectByFacilityCd(facilityCd);
//    }catch (Exception e){
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage(e.getMessage());
//      eventLogMessage.setInvokeClass(this.getClass().getName());
//      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
//
//      ErrorMessage error = new ErrorMessage(HttpStatus.INTERNAL_SERVER_ERROR, "IF_EDGE更新失敗");
//      return new ResponseEntity<>(error, HttpStatus.INTERNAL_SERVER_ERROR);
//    }
    return new ResponseEntity<>(HttpStatus.OK);
  }
  // add 6912 エッジの連携処理を停止しても稼働ビューア画面では正常と表示される 吉 end
}

