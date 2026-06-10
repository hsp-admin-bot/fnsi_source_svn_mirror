package jp.co.nikkiso.ntss.admin_web.web.rest;

import java.io.File;
import java.io.InputStream;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.Arrays;
import java.util.List;

import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.core.logger.ChangeConditionLogAPI;
import jp.co.nikkiso.ntss.core.logger.ChangeEventLogAPI;
import jp.co.nikkiso.ntss.core.logger.EventLogAPI;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.FileInfoModelLog;
import jp.co.nikkiso.ntss.core.logger.FilterConditionLogAPI;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.FUNCTION_CODE;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.admin_web.service.filterLog.FilterLogService;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;


@RestController
@RequestMapping(Uri.LOGS)
public class FilterLogApiResource {

	@Autowired
	LogService logService;

  // add FNSi5712アプリケーションログが出力しない 周 start
  @Autowired
  LogEventUtils logEventUtils;
  // add FNSi5712アプリケーションログが出力しない 周 end

	@Autowired
	FilterLogService filterLogService;

	@PutMapping("/readLog/{folderName}/{fileName}")
	public ResponseEntity<?> readLog(@PathVariable String folderName, @PathVariable String fileName){
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.LOGS + "/readLog/";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_VIEW_LOG,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(folderName, fileName));
    // add FNSi5712アプリケーションログが出力しない 周 end
		try {
			List<EventLogAPI> eventLogAPIs = filterLogService.ReadLog(folderName, fileName);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_VIEW_LOG,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(folderName, fileName));
      // add FNSi5712アプリケーションログが出力しない 周 end
			return new ResponseEntity<>(eventLogAPIs, HttpStatus.OK);
		} catch (Exception e) {
			EventLogMessage eventLogMessage = new EventLogMessage();
			// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
			logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_VIEW_LOG, SERVICE_NAME.FNSI, null);
			// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_VIEW_LOG,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(e.getMessage()));
      // add FNSi5712アプリケーションログが出力しない 周 end
			return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
		}
	}

    /**
     * ログ設定再読み込み (テストページのボタン)
     * @return 成功/失敗(失敗したモジュールのリスト)
     */
	@PutMapping("/loggerSetFlg/update")
	public ResponseEntity<String> loggerSetFlgUpdate() {
	  String mappingUrl = Uri.LOGS + "/loggerSetFlg/update";
	  logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_VIEW_LOG,
	    BEFORE_LOG_FLG_INFO, mappingUrl, null, null);
	  String resultStr = filterLogService.loggerSetFlgUpdate();
	  logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_VIEW_LOG,
	    AFTER_LOG_FLG_INFO, mappingUrl, null, null);
	  return new ResponseEntity<String>(resultStr, null, HttpStatus.OK);
	}

	/**
	 * * フィルターログ
	 * @param folderName
	 * @param fileName
	 * @param searchCondition
	 * @return リストフィルター
	 */
  //FNSI-修正 ログ対応 baix update start
	@PutMapping("/getFilterLog/{folderName}")
	public ResponseEntity<?> getFilterLog(@RequestBody FilterConditionLogAPI searchCondition) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.LOGS + "/getFilterLog/";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_VIEW_LOG,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(searchCondition));
    // add FNSi5712アプリケーションログが出力しない 周 end
		try {
			List<EventLogAPI> eventLogAPI = filterLogService.filterMongoLog(searchCondition);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_VIEW_LOG,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(searchCondition));
      // add FNSi5712アプリケーションログが出力しない 周 end
			return new ResponseEntity<>(eventLogAPI, HttpStatus.OK);
      //FNSI-修正 ログ対応 baix update end
		} catch (Exception e) {
			EventLogMessage eventLogMessage = new EventLogMessage();
			// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
			logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_VIEW_LOG, SERVICE_NAME.FNSI, null);
			// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_VIEW_LOG,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(e.getMessage()));
      // add FNSi5712アプリケーションログが出力しない 周 end
			return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
		}
	}


// add 変更履歴画面追加 陳 start
  /**
   * * フィルターログ
   * @param searchCondition
   * @return リストフィルター
   */
  @PutMapping("/getChangeLog/{folderName}")
  public ResponseEntity<?> getChangeLog(@RequestBody ChangeConditionLogAPI searchCondition) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.LOGS + "/getChangeLog/";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_VIEW_LOG,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(searchCondition));
    // add FNSi5712アプリケーションログが出力しない 周 end
    try {
      List<ChangeEventLogAPI> eventLogAPI = filterLogService.changeMongoLog(searchCondition);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_VIEW_LOG,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(searchCondition));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(eventLogAPI, HttpStatus.OK);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_VIEW_LOG, SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_VIEW_LOG,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(e.getMessage()));
      // add FNSi5712アプリケーションログが出力しない 周 end
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }
// add 変更履歴画面追加 陳 end


	/**
	 * 検索条件
	 * @param userId
	 * @return 検索条件が保存されました
	 */
	@GetMapping("/searchCondition/{userId}")
	public ResponseEntity<?> searchCondition(@PathVariable long userId) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.LOGS + "/searchCondition/";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_VIEW_LOG,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(userId));
    // add FNSi5712アプリケーションログが出力しない 周 end
		try {
			String json = filterLogService.searchCondition(userId);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_VIEW_LOG,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(userId));
      // add FNSi5712アプリケーションログが出力しない 周 end
			return new ResponseEntity<>(json, HttpStatus.OK);
		} catch (Exception e) {
			EventLogMessage eventLogMessage = new EventLogMessage();
			// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
			logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_VIEW_LOG, SERVICE_NAME.FNSI, null);
			// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_VIEW_LOG,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(e.getMessage()));
      // add FNSi5712アプリケーションログが出力しない 周 end
			return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
		}
	}


	/**
	 *
	 * @param userId
	 * @param conditions
	 * @return
	 */
	@PutMapping("/updateSearchCondition/{userId}")
	public ResponseEntity<?> saveCondition(@PathVariable long userId, @RequestBody String conditions) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.LOGS + "/updateSearchCondition/";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_VIEW_LOG,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(userId, conditions));
    // add FNSi5712アプリケーションログが出力しない 周 end
		try {
			filterLogService.saveSearchCondition(userId, conditions);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_VIEW_LOG,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(userId, conditions));
      // add FNSi5712アプリケーションログが出力しない 周 end
			return new ResponseEntity<>(HttpStatus.OK);
		} catch (Exception e) {
			EventLogMessage eventLogMessage = new EventLogMessage();
			// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
			logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_VIEW_LOG, SERVICE_NAME.FNSI, null);
			// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_VIEW_LOG,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(e.getMessage()));
      // add FNSi5712アプリケーションログが出力しない 周 end
			return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
		}
	}

	@GetMapping("/get-directory")
	public ResponseEntity<?> getDirectory(
			@RequestParam(value = "path", required = false) String path,
			@RequestParam(value = "filter", required = false) String filter
	) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.LOGS + "/get-directory";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_VIEW_LOG,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(path, filter));
    // add FNSi5712アプリケーションログが出力しない 周 end
		try	{
			FileInfoModelLog fileInfoModel = filterLogService.getFileSysLog(path, filter);
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_VIEW_LOG,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(path, filter));
      // add FNSi5712アプリケーションログが出力しない 周 end
			return new ResponseEntity<>(fileInfoModel, HttpStatus.OK);
		} catch (Exception e) {
			EventLogMessage eventLogMessage = new EventLogMessage();
			// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
			logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_VIEW_LOG, SERVICE_NAME.FNSI, null);
			// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_VIEW_LOG,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(e.getMessage()));
      // add FNSi5712アプリケーションログが出力しない 周 end
			return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
		}
	}

	@GetMapping("/get-directory/download-log")
	public ResponseEntity<?> downloadFile(
		@RequestParam(value = "path", required = true) String path
	) {
    // add FNSi5712アプリケーションログが出力しない 周 start
    String mappingUrl = Uri.LOGS + "/get-directory/download-log";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_VIEW_LOG,
      BEFORE_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(path));
    // add FNSi5712アプリケーションログが出力しない 周 end
		try {
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_VIEW_LOG,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(path));
      // add FNSi5712アプリケーションログが出力しない 周 end

      //Zipファイルを作成する
      File zipFile = filterLogService.downloadFileLog(path);

      // レスポンスヘッダを作成する
      String contentType = "application/octet-stream";
      HttpHeaders headers = new HttpHeaders();
      headers.setContentType(MediaType.parseMediaType(contentType));
      headers.setContentDispositionFormData("attachment", zipFile.getName());

      // リソースを作成する
      Resource resource = new FileSystemResource(zipFile) {
        @Override
        public InputStream getInputStream() throws IOException {
            return new FileInputStream(zipFile) {
                @Override
                public void close() throws IOException {
                    super.close();
                    // 処理が終わったらZipファイルを削除する
                    zipFile.delete();
                }
            };
        }
      };

      ResponseEntity<Resource> responseEntity = ResponseEntity.ok()
            .headers(headers)
            .body(resource);

      // レスポンスを送信する
      return responseEntity;
		} catch (Exception e) {
			EventLogMessage eventLogMessage = new EventLogMessage();
			// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
			logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_VIEW_LOG, SERVICE_NAME.FNSI, null);
			// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // add FNSi5712アプリケーションログが出力しない 周 start
      logEventUtils.resourceLogOutput(getClassName(), getMethodName(), FUNCTION_CODE.FUNC_VIEW_LOG,
        AFTER_LOG_FLG_INFO, mappingUrl, null, Arrays.asList(e.getMessage()));
      // add FNSi5712アプリケーションログが出力しない 周 end
			return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
		}
	}

  // add FNSi5712アプリケーションログが出力しない 周 start
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
  // add FNSi5712アプリケーションログが出力しない 周 end
}
