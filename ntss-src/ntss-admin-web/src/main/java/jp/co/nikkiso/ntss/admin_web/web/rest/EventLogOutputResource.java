package jp.co.nikkiso.ntss.admin_web.web.rest;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.logevent.ILogEventService;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.logger.LogObjectUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping(AdminWebConstant.Uri.LOGS)
public class EventLogOutputResource {

  /** ログメッセージフォーマット */
  private final static String PAGE_ACCESS_LOG_MESSAGE = "%sが%sの%sボタンを押下しました。";

  /** ログメッセージフォーマット */
  private final static String CONDITION_LOG_MESSAGE = "%sに検索条件：「%s」で検索しました。";

  // ##9698 アプリケーションログの内容修正 20260327 add shiyw start
  /** データの変更 */
  private final static String DATA_CHANGED_LOG_MESSAGE = "データの変更: 「%s」は「%s」の「%s」ボタンをクリックし、情報を「%s」に変更しました。";

  /** 画面移行ログ */
  private final static String PAGE_ROUTER_LOG_MESSAGE = "「%s」 が画面 「%s」 を開きました";
  // ##9698 アプリケーションログの内容修正 20260327 add shiyw end

  /**
   * ロギングのServiceインタフェース.
   */
  @Autowired
  private LogService logService;

  @Autowired
  ILogEventService logEventService;

  /**
   * ログ出力.
   *
   * @param param パラメータ
   * @return 検査セットマスタデータのResponse
   *
   */
  @PutMapping("/event/accesslog")
  public ResponseEntity<?> outputAccessLog(@RequestBody Map param) {
    try {
      if (param != null && param.size() > 0) {
        String functionName = convertString(param.get("functionName"));
        String pageName = convertString(param.get("pageName"));
        String btnName = convertString(param.get("btnName"));
        String patId = convertString(param.get("patId"));
        if (!StringUtils.isEmpty(pageName) && !StringUtils.isEmpty(btnName)) {
          String userId = "";
          String userName = "";
          NtssUser user = (NtssUser) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
          if (user != null) {
            userId = user.getUsername();
            userName = logEventService.getPersonalUserName(user.getUserId());
          }

          // %sが%sの%sボタンを押下しました。
          //FNSI-修正 8164 ljx mod start
          outputLogNew(LogLevel.MONGO, String.format(PAGE_ACCESS_LOG_MESSAGE, userName, pageName, btnName), patId,functionName);
          //FNSI-修正 8164 ljx mod end
        }
      }

      return new ResponseEntity<>(HttpStatus.OK);
    } catch (Exception e) {
      return new ResponseEntity<>(HttpStatus.OK);
    }
  }

  /**
   * ログ出力.
   *
   * @param param パラメータ
   * @return 検査セットマスタデータのResponse
   *
   */
  @PutMapping("/event/conditionlog")
  public ResponseEntity<?> outputConditionLog(@RequestBody Map param) {
    try {
      if (param != null && param.size() > 0) {
        String functionName = convertString(param.get("functionName"));
        String message = convertString(param.get("message"));
        if (!StringUtils.isEmpty(message)) {
          // %sに検索条件：「%s」で検索しました。
          String msg = getConditionMessage(message);
          outputLog(LogLevel.MONGO, String.format(CONDITION_LOG_MESSAGE, convertString(functionName), msg), functionName);
        }
      }
      return new ResponseEntity<>(HttpStatus.OK);
    } catch (Exception e) {
      return new ResponseEntity<>(HttpStatus.OK);
    }
  }

  // #9700 サーバ各画面のデータ変更ログ 20260407 add shiyw start
  /**
   * ログ出力.
   *  データの変更: 「Zhang San」は「pageName」の「保存」ボタンをクリックし、情報を「777」に変更しました。
   *  データの変更: 「%s」は「%s」の「%s」ボタンをクリックし、情報を「%s」に変更しました。dataId=「%s」
   * @param param パラメータ
   * @return 検査セットマスタデータのResponse
   */
  @PutMapping("/event/dataChanged")
  public ResponseEntity<?> outputDataChangedLog(@RequestBody Map param) {
    try {
      if (param != null && param.size() > 0) {
        String functionName = convertString(param.get("functionName"));
        String pageName = convertString(param.get("pageName"));
        String btnName = convertString(param.get("btnName"));
        String message = convertString(param.get("message"));
        if (!StringUtils.isEmpty(pageName) && !StringUtils.isEmpty(btnName)) {
          String userName = "";
          NtssUser user = (NtssUser) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
          if (user != null) {
            userName = logEventService.getPersonalUserName(user.getUserId());
          }
          outputLog(LogLevel.MONGO, String.format(DATA_CHANGED_LOG_MESSAGE, userName,pageName, btnName, message),functionName + "->" + pageName);
        }
      }
      return new ResponseEntity<>(HttpStatus.OK);
    } catch (Exception e) {
      return new ResponseEntity<>(HttpStatus.OK);
    }
  }
  // #9700 サーバ各画面のデータ変更ログ 20260407 add shiyw end

  // #9700 サーバ各画面へのアクセスログ 20260407 add shiyw start
  @PutMapping("/event/pageRouterLog")
  public ResponseEntity<?> pageRouterLog(@RequestBody Map<String, Object> param) {
    try {
      if (param != null && param.size() > 0) {
        String destPageName = convertString(param.get("destPageName"));
        String userName = "";
        NtssUser user = (NtssUser) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        if (user != null) {
          userName = logEventService.getPersonalUserName(user.getUserId());
        }
        if (!StringUtils.isEmpty(destPageName)) {
          String logMessage = String.format(PAGE_ROUTER_LOG_MESSAGE, userName, destPageName);
          outputLog(LogLevel.MONGO, logMessage, destPageName);
        }
      }
      return new ResponseEntity<>(HttpStatus.OK);
    } catch (Exception e) {
      return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }
  // #9700 サーバ各画面へのアクセスログ 20260407 add shiyw end

  /**
   * 検索条件のメッセージを取得する
   * @param message
   * @return
   */
  private String getConditionMessage(String message) {
    String msg = message;
    if (StringUtils.isEmpty(msg)) {
      return "";
    }
    if (msg.indexOf("[") >= 0 && msg.indexOf("]") >= 0) {
      int start = msg.indexOf("[");
      int end = msg.indexOf("]");
      msg = msg.substring(start + 1, end);
      return msg;
    }

    return msg;
  }

  /**
   * ログ出力する
   * @param message 出力メッセージ
   */
  private void outputLog(LogLevel level, String message, String functionName) {
    if (StringUtils.isEmpty(message)) {
      return;
    }
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setEc2Identification(LogObjectUtils.getHostAddress());
    eventLogMessage.setLogMessage(message);
    eventLogMessage.setInvokeClass(this.getClass().getName());
    eventLogMessage.setFunctionName(convertString(functionName));
    logService.log(level, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
  }
  //FNSI-修正 8164 ljx add start
  /**
   * ログ出力する
   * @param message 出力メッセージ
   */
  private void outputLogNew(LogLevel level, String message,String patId,  String functionName) {
    if (StringUtils.isEmpty(message)) {
      return;
    }
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setPatId(patId);
    eventLogMessage.setEc2Identification(LogObjectUtils.getHostAddress());
    eventLogMessage.setLogMessage(message);
    eventLogMessage.setInvokeClass(this.getClass().getName());
    eventLogMessage.setFunctionName(convertString(functionName));
    logService.log(level, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
  }
  //FNSI-修正 8164 ljx add end

  /**
   * String変換
   * @param obj 変換用オブジェクト
   * @return 変換したデータ
   */
  public String convertString(Object obj) {
    if (obj == null) {
      return "";
    }

    return obj.toString();
  }
}
