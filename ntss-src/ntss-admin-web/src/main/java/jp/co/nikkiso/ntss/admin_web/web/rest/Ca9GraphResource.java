package jp.co.nikkiso.ntss.admin_web.web.rest;

import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;

import java.util.Map;
import java.util.List;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.admin_web.service.ca9Graph.Ca9GraphService;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_ERROR;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

@RestController
@RequestMapping(Uri.CA9_GRAPH)
public class Ca9GraphResource {
  @Autowired
  Ca9GraphService ca9GraphService;
  @Autowired
  private LogService logService;

  // wp アプリケーションログの適正化 Add Start
  @Autowired
  LogEventUtils logEventUtils;
  // wp アプリケーションログの適正化 Add End

  /**
   * グラフ設定を取得
   *
   * @param facilityCd
   * @return
   */
  @GetMapping("/setting/{facilityCd}")
  public ResponseEntity<?> getGraphSetting(@PathVariable String facilityCd){

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.CA9_GRAPH + "/setting";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_SPLIT_GRAPH, BEFORE_LOG_FLG_INFO, mappingUrl, facilityCd,
      null);
    // wp アプリケーションログの適正化 Add End

//    EventLogMessage eventLogMessage = new EventLogMessage();
//    eventLogMessage.setLogMessage("Rest request to get graph setting");
//    logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_SPLIT_GRAPH, SERVICE_NAME.FNSI, null);
    try {
      Map<String, String> response = ca9GraphService.getGraphSetting(facilityCd);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_SPLIT_GRAPH, AFTER_LOG_FLG_INFO, mappingUrl, facilityCd,
        null);
      // wp アプリケーションログの適正化 Add End

      return new ResponseEntity<>(response, HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
//      eventLogMessage.setLogMessage(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_SPLIT_GRAPH, SERVICE_NAME.FNSI, null);

      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 mod yangxuewang start
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_SPLIT_GRAPH, AFTER_LOG_FLG_ERROR, mappingUrl, facilityCd, ExcetionStackTraceToString(e));
      // wp アプリケーションログの適正化 Add End
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 mod yangxuewang end

      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 分布グラフのデータを取得する
   *
   * @param params
   * @return
   */
  @PostMapping("/distributionGraph")
  public ResponseEntity<?> getDataDistributionGraph(@RequestBody Map<String, String> params) {
//    EventLogMessage eventLogMessage = new EventLogMessage();
//    eventLogMessage.setLogMessage("Rest request to get data for distribution graph");
//    logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_SPLIT_GRAPH, SERVICE_NAME.FNSI, null);
    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.CA9_GRAPH + "/distributionGraph";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_SPLIT_GRAPH, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      params);
    // wp アプリケーションログの適正化 Add End
    try {
      List<Map<String, String>> response = ca9GraphService.getPatExamItemDistributionGraphData(params);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_SPLIT_GRAPH, AFTER_LOG_FLG_INFO, mappingUrl, null,
        params);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(response, HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
//      eventLogMessage.setLogMessage(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_SPLIT_GRAPH, SERVICE_NAME.FNSI, null);

      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_SPLIT_GRAPH, AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
      // wp アプリケーションログの適正化 Add End
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 患者IDで経過グラフデータを取得する
   *
   * @param params
   * @param patId
   * @return
   */
  @PostMapping("/progressGraph/{patId}")
  public ResponseEntity<?> getDataProgressGraph(@RequestBody Map<String, String> params, @PathVariable Long patId) {
//    EventLogMessage eventLogMessage = new EventLogMessage();
//    eventLogMessage.setLogMessage("Rest request to get data for progress graph");
//    logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_SPLIT_GRAPH, SERVICE_NAME.FNSI, null);
    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.CA9_GRAPH + "/progressGraph";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_SPLIT_GRAPH, BEFORE_LOG_FLG_INFO, mappingUrl, null,
      params);
    // wp アプリケーションログの適正化 Add End

    try {
      List<Map<String, String>> response = ca9GraphService.getPatExamItemProgressGraphData(params, patId);

      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_SPLIT_GRAPH, AFTER_LOG_FLG_INFO, mappingUrl, null,
        params);
      // wp アプリケーションログの適正化 Add End
      return new ResponseEntity<>(response, HttpStatus.OK);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
//      eventLogMessage.setLogMessage(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_SPLIT_GRAPH, SERVICE_NAME.FNSI, null);

      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_SPLIT_GRAPH, AFTER_LOG_FLG_ERROR, mappingUrl, null, ExcetionStackTraceToString(e));
      // wp アプリケーションログの適正化 Add End
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 患者グループを更新する
   *
   * @param payload
   * @param facilityCd
   * @return
   */
  @PutMapping("/update/patGroup/{facilityCd}")
  public ResponseEntity<?> updatePatGroup(@RequestBody List<Map<String, String>> payload, @PathVariable String facilityCd) {
//    EventLogMessage eventLogMessage = new EventLogMessage();
//    eventLogMessage.setLogMessage("Rest request to update pat group");
//    logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_SPLIT_GRAPH, SERVICE_NAME.FNSI, null);

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = Uri.CA9_GRAPH + "/update/patGroup";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_SPLIT_GRAPH, BEFORE_LOG_FLG_INFO, mappingUrl, facilityCd,
      payload);
    // wp アプリケーションログの適正化 Add End

    try {
      List<Map<String, Object>> result = ca9GraphService.updatePatGroup(payload, facilityCd);
      if (result.size() > 0) {
//        eventLogMessage.setLogMessage("Update pat group fail");
//        logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_SPLIT_GRAPH, SERVICE_NAME.FNSI, null);

        // wp アプリケーションログの適正化 Add Start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_SPLIT_GRAPH, AFTER_LOG_FLG_INFO, mappingUrl, facilityCd,
          payload);
        // wp アプリケーションログの適正化 Add End
        return new ResponseEntity<>(result, HttpStatus.BAD_REQUEST);
      } else {
//        eventLogMessage.setLogMessage("Update pat group success");
//        logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_SPLIT_GRAPH, SERVICE_NAME.FNSI, null);

        // wp アプリケーションログの適正化 Add Start
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_SPLIT_GRAPH, AFTER_LOG_FLG_INFO, mappingUrl, facilityCd,
          payload);
        // wp アプリケーションログの適正化 Add End
        return new ResponseEntity<>(HttpStatus.OK);
      }
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
//      eventLogMessage.setLogMessage(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_SPLIT_GRAPH, SERVICE_NAME.FNSI, null);

      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      // wp アプリケーションログの適正化 Add Start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_SPLIT_GRAPH, AFTER_LOG_FLG_ERROR, mappingUrl, facilityCd, ExcetionStackTraceToString(e));
      // wp アプリケーションログの適正化 Add End
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end

      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }
  // add bug 7940 修正 chen start
  /**
   * 患者グループを更新する
   *
   * @param payload
   * @param facilityCd
   * @param groupIdList
   * @return
   */
  @PutMapping("/update/patGroup/{facilityCd}/{groupIdList}")
  public ResponseEntity<?> updatePatGroupByGroupList(@RequestBody List<Map<String, String>> payload, @PathVariable String facilityCd, @PathVariable List<String> groupIdList) {

    String mappingUrl = Uri.CA9_GRAPH + "/update/patGroup";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_SPLIT_GRAPH, BEFORE_LOG_FLG_INFO, mappingUrl, facilityCd,
      payload);

    try {
      List<Map<String, Object>> result = ca9GraphService.updatePatGroupByGroupList(payload, facilityCd, groupIdList);
      if (result.size() > 0) {
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_SPLIT_GRAPH, AFTER_LOG_FLG_INFO, mappingUrl, facilityCd,
          payload);
        return new ResponseEntity<>(result, HttpStatus.BAD_REQUEST);
      } else {
        logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_SPLIT_GRAPH, AFTER_LOG_FLG_INFO, mappingUrl, facilityCd,
          payload);
        return new ResponseEntity<>(HttpStatus.OK);
      }
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), LoggingConstant.FUNCTION_CODE.FUNC_SPLIT_GRAPH, AFTER_LOG_FLG_ERROR, mappingUrl, facilityCd, ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }
  // add bug 7940 修正 chen end


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
