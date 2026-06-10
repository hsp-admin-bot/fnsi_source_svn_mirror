package jp.co.nikkiso.ntss.coop_api.service;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.URI;
import java.net.URISyntaxException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.Stream;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import com.fasterxml.jackson.databind.ObjectMapper;

import jp.co.nikkiso.ntss.coop_api.config.IfEdgeConfigulation;
import jp.co.nikkiso.ntss.coop_api.request.IfEdgeWebsocketRequest;
import jp.co.nikkiso.ntss.coop_api.request.JournalDeliveryRequest;
import jp.co.nikkiso.ntss.coop_api.response.IfEdgeRestResult;
import jp.co.nikkiso.ntss.coop_api.utils.ClockWrapper;
import jp.co.nikkiso.ntss.coop_api.utils.IfEdgeConstants;
import jp.co.nikkiso.ntss.coop_api.utils.IfEdgeConstants.AddSetting;
import jp.co.nikkiso.ntss.coop_api.utils.IfEdgeConstants.ExeType;
import jp.co.nikkiso.ntss.coop_api.utils.IfEdgeConstants.IfedgeFixedResult;
import jp.co.nikkiso.ntss.coop_api.utils.IfEdgeConstants.ResponseStatus;
import jp.co.nikkiso.ntss.coop_api.utils.IfEdgeConstants.ResultStatus;
import jp.co.nikkiso.ntss.coop_api.web.websocket.IfEdgeMntSessionManager;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.MntIfEdgeClientConnectDao;
import jp.co.nikkiso.ntss.core.dao.MntIfEdgeManageDao;
import jp.co.nikkiso.ntss.core.dao.MstCoopFacilityDao;
import jp.co.nikkiso.ntss.core.dao.MstIfEdgeCommandDao;
import jp.co.nikkiso.ntss.core.entity.MntIfEdgeClientConnect;
import jp.co.nikkiso.ntss.core.entity.MntIfEdgeManage;
import jp.co.nikkiso.ntss.core.entity.MntIfEdgeManage.EdgeResult;
import jp.co.nikkiso.ntss.core.entity.MstCoopFacility;
import jp.co.nikkiso.ntss.core.entity.MstIfEdgeCommand;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;

@Service
public class IfEdgeServiceImpl implements IfEdgeService {

  @Autowired
  MntIfEdgeClientConnectDao mntIfEdgeClientConnectDao;

  @Autowired
  MntIfEdgeManageDao mntIfEdgeManageDao;

  @Autowired
  MstIfEdgeCommandDao mstIfEdgeCommandDao;

  @Autowired
  MstCoopFacilityDao mstCoopFacilityDao;

  @Autowired
  IfEdgeMntSessionManager ifEdgeMntSessionManager;

  @Autowired
  IfEdgeConfigulation ifEdgeConfigulation;

  @Autowired
  ClockWrapper clockWrapper;

  @Autowired
  private LogService logService;

  /* add by chamaojia 2024-06-21 [10574] communication security related additions --start */
  @Value("${ntss.coop-api.header-name}")
  private String headerKey;
  @Value("${ntss.coop-api.header-value}")
  private String headerValue;
  /* add by chamaojia 2024-06-21 [10574] communication security related additions --end */

  /* del by chamaojia 2026-04-28 [10959] システム内でstatic変数を使っている箇所の洗い出し  --start */
  // // add 2021-05-26 外部連携API:ログを改善 孫 start
  // // 追加log情報
  // String additionalMessage = "";
  // // add 2021-05-26 外部連携API:ログを改善 孫 end
  /* del by chamaojia 2026-04-28 [10959] システム内でstatic変数を使っている箇所の洗い出し  --end */
  /**
   * RESTリクエスト振り分け
   *
   * @param request 連携エッジwebsocket通信リクエスト
   * @return 連携エッジ指示レスポンス
   * @see jp.co.nikkiso.ntss.coop_api.service.IfEdgeService#devide(IfEdgeWebsocketRequest)
   */
  public IfEdgeRestResult devide(IfEdgeWebsocketRequest request) {

    IfEdgeRestResult ret;
    EventLogMessage eventLogMessage = new EventLogMessage();

    // 連携エッジクライアント接続状態を確認する。
    // #10453 mod 死活監視が動作していない 荘 2024-07-04 start
//    MntIfEdgeClientConnect mntIfEdgeClientConnect = mntIfEdgeClientConnectDao.selectByFacilityCd(request.getFacilityCd());
    List<MntIfEdgeClientConnect> mntIfEdgeClientConnectList = mntIfEdgeClientConnectDao.selectListByIfEdgeType(request.getFacilityCd(), 1);
    MntIfEdgeClientConnect mntIfEdgeClientConnect;
    if (mntIfEdgeClientConnectList == null || mntIfEdgeClientConnectList.isEmpty()) {
      mntIfEdgeClientConnect = null;
    } else {
      mntIfEdgeClientConnect = mntIfEdgeClientConnectList.get(0);
    }
    // #10453 mod 死活監視が動作していない 荘 2024-07-04 end
    if (mntIfEdgeClientConnect == null) {
      // 指定した施設の連携エッジクライアント接続がない場合、接続なしで返却
      return createFixedReqponse(request.getFacilityCd(), IfedgeFixedResult.DISCONNECT, null);
    }
    // #10453 del 死活監視が動作していない 荘 2024-07-03 start
//    else {
//      boolean existsClient = ifEdgeMntSessionManager.existsClientSessionByFacilityCd(request.getFacilityCd());
//      if (!existsClient) {
//        // 指定した施設の連携エッジクライアント接続がない場合、接続なしで返却
//        return createFixedReqponse(request.getFacilityCd(), IfedgeFixedResult.DISCONNECT, null);
//      }
//    }
    // #10453 del 死活監視が動作していない 荘 2024-07-03 end

    if (mntIfEdgeClientConnect.getIpAddress() == null
        || mntIfEdgeClientConnect.getIpAddress().equals(ifEdgeMntSessionManager.getLocalIp()) == true) {
      // 自サーバーの場合
      ret = execute(request);

    } else {
      // 他サーバーの場合

      // URI作成
      URI uri;
      StringBuilder builder = new StringBuilder();
      builder.append(ifEdgeConfigulation.getRequestHTTP())
             .append(mntIfEdgeClientConnect.getIpAddress())
             .append(ifEdgeConfigulation.getPostMsgAPI());

      try {
        uri = new URI(builder.toString());
      } catch(URISyntaxException use) {
        /* upd by chamaojia 2026-04-28 [10959] システム内でstatic変数を使っている箇所の洗い出し  --start */
        // // add 2021-05-26 外部連携API:ログを改善 孫 start
        // additionalMessage = use.toString();
        // // add 2021-05-26 外部連携API:ログを改善 孫 end
        eventLogMessage.setLogMessage(IfedgeFixedResult.URI_SYNTAX_ERR.getMessage());;
        // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
        eventLogMessage.setInvokeClass(this.getClass().getName());
        // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        return createFixedReqponse(request.getFacilityCd(), IfedgeFixedResult.URI_SYNTAX_ERR, null, use.toString());
        /* upd by chamaojia 2026-04-28 [10959] システム内でstatic変数を使っている箇所の洗い出し  --end */
      }

      // ヘッダ作成
      HttpHeaders headers = new HttpHeaders();
      headers.setContentType(MediaType.APPLICATION_JSON_UTF8);
      /* add by chamaojia 2024-06-21 [10574] communication security related additions --start */
      headers.set(headerKey, headerValue);
      /* add by chamaojia 2024-06-21 [10574] communication security related additions --end */

      ret = ifEdgeMntSessionManager.transfer(uri, headers, request);
    }

    return ret;
  }

  /**
   * データクリア制御
   *
   * @param facilityCd 施設コード
   * @param result 連携エッジ指示レスポンス
   * @see jp.co.nikkiso.ntss.coop_api.service.IfEdgeService#clearData(String, IfEdgeRestResult)
   */
  public void clearData(String facilityCd, IfEdgeRestResult result) {

    // メッセージが取得できない場合は何もしない
    if (result.getResult() == null
        ||result.getResult().getResult() == null
        || StringUtils.isEmpty(result.getResult().getResult().getMessage())) {
      return;
    }

    for (IfedgeFixedResult ifedgeFixedResult : IfedgeFixedResult.values()) {
      if (!ifedgeFixedResult.getMessage().equals(result.getResult().getResult().getMessage())) {
        continue;
      }
      //
      switch(ifedgeFixedResult.getDataClearFlg()) {
        case IfEdgeConstants.DATA_CLEAR_UNNECESSARY:
          // データクリア必要なし
          break;
        case IfEdgeConstants.DATA_CLEAR_ONLY_MANAGE:
          // 連携エッジ制御指示管理のみデータクリア
          /* upd by chamaojia 2026-04-28 [10959] システム内でstatic変数を使っている箇所の洗い出し  --start */
          // clearIfEdgeManage(facilityCd, ifedgeFixedResult);
          clearIfEdgeManage(facilityCd, ifedgeFixedResult, result.getAdditionalMessage());
          /* upd by chamaojia 2026-04-28 [10959] システム内でstatic変数を使っている箇所の洗い出し  --end */
          break;
        case IfEdgeConstants.DATA_CLEAR_ALL:
          // 連携エッジ制御指示管理クリア
          /* upd by chamaojia 2026-04-28 [10959] システム内でstatic変数を使っている箇所の洗い出し  --start */
          // clearIfEdgeManage(facilityCd, ifedgeFixedResult);
          clearIfEdgeManage(facilityCd, ifedgeFixedResult, result.getAdditionalMessage());
          /* upd by chamaojia 2026-04-28 [10959] システム内でstatic変数を使っている箇所の洗い出し  --end */
          // クライアント情報クリア
          // del 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 start
//          ifEdgeMntSessionManager.clearClientData(facilityCd, CloseStatus.SERVER_ERROR);
          // del 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 end
          break;
        default:
          break;
      }
    }
  }

  // add 2020-11-16 各API間の呼び出しフローの修正（エッジ主体からAWS主体へ）→負荷増加回避策が必要 孫 start
  /**
   * IFエッジ(サーバへの電文リクエスト)通知
   *
   * @param request ジャーナル作成APIリクエスト
   * @see jp.co.nikkiso.ntss.coop_api.service.IfEdgeService#SendJournal(JournalDeliveryRequest request)
   */
  public boolean SendJournal(JournalDeliveryRequest request) {

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(String.format("%s (%s)","IFエッジ(サーバへの電文リクエスト)通知 start", request.getFacilityCd()));
    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
    eventLogMessage.setInvokeClass(this.getClass().getName());
    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);

    // 連携エッジ制御指示管理の状態を確認する。
    MntIfEdgeManage existingMntIfEdgeManage
      = mntIfEdgeManageDao.selectByFacilityCdAndStatus(request.getFacilityCd(), ResponseStatus.RUNNING.getStatus());
    if (existingMntIfEdgeManage !=null) {
      // 依頼中の連携エッジ制御が存在した場合、BUSYで返却
      eventLogMessage =  new EventLogMessage();
      eventLogMessage.setLogMessage(String.format("%s (%s)",IfedgeFixedResult.JOURNAL_BUSY.getMessage(), request.getFacilityCd()));
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
      logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      return false;
    }

    // 連携送信実行
    boolean sendResult = false;
    try {
      // パラメータをJson形式(文字列)に変換
      ObjectMapper mapper = new ObjectMapper();
      // 変換
      String message = mapper.writeValueAsString(request);
      sendResult = ifEdgeMntSessionManager.sendJournalRequest(request.getFacilityCd(), message);
    } catch(IOException ioe) {
      /* del by chamaojia 2026-04-28 [10959] システム内でstatic変数を使っている箇所の洗い出し  --start */
      // // add 2021-05-26 外部連携API:ログを改善 孫 start
      // additionalMessage = ioe.toString();
      // // add 2021-05-26 外部連携API:ログを改善 孫 end
      /* del by chamaojia 2026-04-28 [10959] システム内でstatic変数を使っている箇所の洗い出し  --end */
      eventLogMessage =  new EventLogMessage();
      eventLogMessage.setLogMessage(String.format("%s (%s)",IfedgeFixedResult.SEND_JOURNAL_ERR.getMessage(), request.getFacilityCd()));
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
      logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI, null);

      eventLogMessage =  new EventLogMessage();
      eventLogMessage.setLogMessage(ioe.getMessage());
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
      logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      return false;
    }

    // 連携送信が実行されなかった場合
    if (!sendResult) {
      eventLogMessage =  new EventLogMessage();
      eventLogMessage.setLogMessage(String.format("%s (%s)",IfedgeFixedResult.JOURNAL_DISCONNECT.getMessage(), request.getFacilityCd()));
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
      logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      return false;
    }

    eventLogMessage =  new EventLogMessage();
    eventLogMessage.setLogMessage(String.format("%s (%s)","IFエッジ(サーバへの電文リクエスト)通知 end", request.getFacilityCd()));
    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
    eventLogMessage.setInvokeClass(this.getClass().getName());
    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    return true;
  }
  // add 2020-11-16 各API間の呼び出しフローの修正（エッジ主体からAWS主体へ）→負荷増加回避策が必要 孫 end

  /**
   * 連携エッジメンテナンス実行指示
   *
   * @param request 連携エッジwebsocket通信リクエスト
   * @return 連携エッジ指示レスポンス
   */
  private IfEdgeRestResult execute(IfEdgeWebsocketRequest request) {

    EventLogMessage eventLogMessage = new EventLogMessage();

    // 連携エッジ制御指示管理の状態を確認する。
    MntIfEdgeManage existingMntIfEdgeManage
            = mntIfEdgeManageDao.selectByFacilityCdAndStatus(request.getFacilityCd(), ResponseStatus.RUNNING.getStatus());
    if (existingMntIfEdgeManage !=null) {
      // 依頼中の連携エッジ制御が存在した場合、BUSYで返却
      return createFixedReqponse(request.getFacilityCd(),IfedgeFixedResult.BUSY, existingMntIfEdgeManage.getCtlNo());
    }

    // 連携エッジ制御指示管理に0(依頼中)で登録して管理Noを取得
    MntIfEdgeManage insMntIfEdgeManage = new MntIfEdgeManage();
    insMntIfEdgeManage.setFacilityCd(request.getFacilityCd());
    insMntIfEdgeManage.setResponseStatus(ResponseStatus.RUNNING.getStatus());
    insMntIfEdgeManage.setEdgeResult(null);
    insMntIfEdgeManage.setIsDel(IfEdgeConstants.FLAG_FALSE);
    mntIfEdgeManageDao.insert(insMntIfEdgeManage);
    MntIfEdgeManage mntIfEdgeManage
      = mntIfEdgeManageDao.selectByFacilityCdAndStatus(request.getFacilityCd(), ResponseStatus.RUNNING.getStatus());

    // YYYYMMddsss文字列作成
    SimpleDateFormat sdf = new SimpleDateFormat(IfEdgeConstants.COMMAND_DIR_DATE_FORMAT);
    String dateDir = sdf.format(new Timestamp(clockWrapper.getClockMillis()));

    // ディレクトリを取得
    String targetDir = getTargetDir(request, dateDir);
	Path commandDirPath = Paths.get(targetDir);

	IfEdgeRestResult result = new IfEdgeRestResult();
    try {
    	if (ExeType.COMMAND.getType().equals(request.getType())) {
    		// 指示種別がコマンドの場合
    		
    		MstIfEdgeCommand mstIfEdgeCommand;
    		// コマンドマスタ取得
    		try {
    			mstIfEdgeCommand = mstIfEdgeCommandDao.selectByKey(request.getCommand());
    		} catch(Exception e) {
              /* upd by chamaojia 2026-04-28 [10959] システム内でstatic変数を使っている箇所の洗い出し  --start */
                // // add 2021-05-26 外部連携API:ログを改善 孫 start
                // additionalMessage = e.toString();
                // // add 2021-05-26 外部連携API:ログを改善 孫 end
    			// コマンドマスタを取得できない場合、BAD_REQUESTで返却（コマンドキーが複数ある場合もこちらになる）
    			return createFixedReqponse(request.getFacilityCd(),IfedgeFixedResult.COMMAND_MASTER_ERR, null, e.toString());
              /* upd by chamaojia 2026-04-28 [10959] システム内でstatic変数を使っている箇所の洗い出し  --end */
    			
    		}
    		
    		if (mstIfEdgeCommand != null) {
    			try {
    				// ディレクトリを作成
    				Files.createDirectories(commandDirPath);
    				// 設定ファイルのディレクトリにコマンドファイルを作成
    				createCommandFile(request.getCommand(), targetDir, mstIfEdgeCommand);
    				
    				// 設定ファイル追加が１の場合、施設マスタから設定を取得してファイル作成
    				if (AddSetting.FACILITY_SETTING.getAddSetting().equals(mstIfEdgeCommand.getAddSetting())) {
    					createFacilitySetting(request.getFacilityCd(), targetDir);
    				}
    				// add bug 6920 IFエッジ設定更新時に再起動が行われない 張 start
    				if ("versionup".equals(request.getCommand())) {
    					// mod 2022-09-29 bug 6920 IFエッジ設定更新時に再起動が行われない 孫 start
//            try {
//              createFile(request, targetDir,IfEdgeConstants.NTSS_IF_FILE);
//            } catch (IOException e) {
//              e.printStackTrace();
//            }
//            try {
//              createFile(request, targetDir,IfEdgeConstants.NTSS_MAINT_FILE);
//            } catch (IOException e) {
//              e.printStackTrace();
//            }
//            try {
//              createFile(request, targetDir,IfEdgeConstants.SETTING_CONFIG);
//            } catch (IOException e) {
//              e.printStackTrace();
//            }
//            try {
//              createFile(request, targetDir,IfEdgeConstants.NTSS_IF_ENV);
//            } catch (IOException e) {
//              e.printStackTrace();
//            }
    					try {
    						createFile(request, targetDir);
    					} catch (IOException e) {
                          /* upd by chamaojia 2026-04-28 [10959] システム内でstatic変数を使っている箇所の洗い出し  --start */
                            // additionalMessage = e.toString();
    						// コマンドマスタを取得できない場合、BAD_REQUESTで返却（コマンドキーが複数ある場合もこちらになる）
    						return createFixedReqponse(request.getFacilityCd(),IfedgeFixedResult.COPY_VERSION_UP_FILE_ERR, null, e.toString());
                          /* upd by chamaojia 2026-04-28 [10959] システム内でstatic変数を使っている箇所の洗い出し  --end */
    					}
    					// mod 2022-09-29 bug 6920 IFエッジ設定更新時に再起動が行われない 孫 end
    				}
    				// add bug 6920 IFエッジ設定更新時に再起動が行われない 張 end
    			} catch(Exception e) {
    				// コマンドファイル作成に失敗した場合
                  /* upd by chamaojia 2026-04-28 [10959] システム内でstatic変数を使っている箇所の洗い出し  --start */
                    // // add 2021-05-26 外部連携API:ログを改善 孫 start
                    // additionalMessage = e.toString();
                    // // add 2021-05-26 外部連携API:ログを改善 孫 end
    				eventLogMessage.setLogMessage(IfedgeFixedResult.COMMAND_FILE_ERR.getMessage());
    				// add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
    				eventLogMessage.setInvokeClass(this.getClass().getName());
    				// add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
    				logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    				return createFixedReqponse(request.getFacilityCd(),IfedgeFixedResult.COMMAND_FILE_ERR, mntIfEdgeManage.getCtlNo(), e.toString());
                  /* upd by chamaojia 2026-04-28 [10959] システム内でstatic変数を使っている箇所の洗い出し  --end */
    			}
    		} else {
    			// コマンドが設定ファイルにない場合、BAD_REQUESTで返却
    			return createFixedReqponse(request.getFacilityCd(),IfedgeFixedResult.COMMANDNOTFOUND, mntIfEdgeManage.getCtlNo());
    		}
    	}
    	
    	// 管理NOファイル作成
    	IfEdgeRestResult createCtlNFileResult = createCtlNoFile(request.getFacilityCd(), targetDir, mntIfEdgeManage.getCtlNo());
    	if (createCtlNFileResult != null) {
    		return createCtlNFileResult;
    	}
    	
    	try {
    		// maintenance.sh内部のDATA_PATHを置換
    		String replaceDir = ExeType.COMMAND.getType().equals(request.getType()) ? dateDir : request.getDirPath() ;
    		replaceDataPathString(Paths.get(targetDir, IfEdgeConstants.COMMAND_FILE), replaceDir);
    	} catch(IOException ioe) {
          /* upd by chamaojia 2026-04-28 [10959] システム内でstatic変数を使っている箇所の洗い出し  --start */
    		// // add 2021-05-26 外部連携API:ログを改善 孫 start
    		// additionalMessage = ioe.toString();
    		// // add 2021-05-26 外部連携API:ログを改善 孫 end
    		// add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
    		eventLogMessage.setInvokeClass(this.getClass().getName());
    		// add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
    		eventLogMessage.setLogMessage(IfedgeFixedResult.REPLACE_ERR.getMessage());
    		logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    		eventLogMessage.setLogMessage(ioe.getStackTrace().toString());
    		logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    		return createFixedReqponse(request.getFacilityCd(),IfedgeFixedResult.REPLACE_ERR, mntIfEdgeManage.getCtlNo(), ioe.toString());
          /* upd by chamaojia 2026-04-28 [10959] システム内でstatic変数を使っている箇所の洗い出し  --end */
    	}
    	
    	// 連携ファイルZIP化
    	byte[] sendFileData = null;
    	try {
    		sendFileData = createSendZip(request, targetDir);
    	} catch(IOException ioe) {
          /* upd by chamaojia 2026-04-28 [10959] システム内でstatic変数を使っている箇所の洗い出し  --start */
    		// // add 2021-05-26 外部連携API:ログを改善 孫 start
    		// additionalMessage = ioe.toString();
    		// // add 2021-05-26 外部連携API:ログを改善 孫 end
    		eventLogMessage.setLogMessage(IfedgeFixedResult.CREATE_FILE_ERR.getMessage());
    		// add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
    		eventLogMessage.setInvokeClass(this.getClass().getName());
    		// add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
    		logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    		return createFixedReqponse(request.getFacilityCd(),IfedgeFixedResult.CREATE_FILE_ERR, mntIfEdgeManage.getCtlNo(), ioe.toString());
          /* upd by chamaojia 2026-04-28 [10959] システム内でstatic変数を使っている箇所の洗い出し  --end */
    	}
    	
    	// 連携ファイル送信実行
    	boolean sendResult = false;
    	try {
    		sendResult = ifEdgeMntSessionManager.sendFile(request.getFacilityCd(),sendFileData);
    	} catch(IOException ioe) {
          /* upd by chamaojia 2026-04-28 [10959] システム内でstatic変数を使っている箇所の洗い出し  --start */
    		// // add 2021-05-26 外部連携API:ログを改善 孫 start
    		// additionalMessage = ioe.toString();
    		// // add 2021-05-26 外部連携API:ログを改善 孫 end
    		eventLogMessage.setLogMessage(IfedgeFixedResult.SEND_FILE_ERR.getMessage());
    		// add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
    		eventLogMessage.setInvokeClass(this.getClass().getName());
    		// add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
    		logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    		return createFixedReqponse(request.getFacilityCd(),IfedgeFixedResult.SEND_FILE_ERR, mntIfEdgeManage.getCtlNo(), ioe.toString());
          /* upd by chamaojia 2026-04-28 [10959] システム内でstatic変数を使っている箇所の洗い出し  --end */
    	}
    	
    	// 連携ファイル送信が実行されなかった場合
    	if (!sendResult) {
    		return createFixedReqponse(request.getFacilityCd(),IfedgeFixedResult.DISCONNECT, mntIfEdgeManage.getCtlNo());
    	}
    	
    	MntIfEdgeManage resultMntIfEdgeManage = null;
    	
    	boolean running = true;
    	// 指定秒ごとに指定回数分だけ連携エッジ制御指示管理が依頼中以外のステータスになるのを待つ。
    	for (int i = 0; i < ifEdgeConfigulation.getWaitcount(); i++) {
    		try {
    			Thread.sleep(ifEdgeConfigulation.getWaitMills()); // 指定秒間だけ処理を止める
    		} catch (InterruptedException e) {
              /* upd by chamaojia 2026-04-28 [10959] システム内でstatic変数を使っている箇所の洗い出し  --start */
                // // add 2021-05-26 外部連携API:ログを改善 孫 start
                // additionalMessage = e.toString();
                // // add 2021-05-26 外部連携API:ログを改善 孫 end
    			result.setAdditionalMessage(e.toString());
              /* upd by chamaojia 2026-04-28 [10959] システム内でstatic変数を使っている箇所の洗い出し  --end */
    		}
    		resultMntIfEdgeManage = mntIfEdgeManageDao.selectByCtlNo(mntIfEdgeManage.getCtlNo());
    		if (ResponseStatus.RUNNING.getStatus() != resultMntIfEdgeManage.getResponseStatus()) {
    			running = false;
    			break;
    		}
    	}
    	
    	if (running) {
    		// 待ち時間経過しても処理が終わらなかった場合、タイムアウトで返却
    		mntIfEdgeManage.setResponseStatus(ResponseStatus.TIMEOUT.getStatus());
    		if (mntIfEdgeManage.getEdgeResult() == null) {
    			mntIfEdgeManage.setEdgeResult(new EdgeResult());
    			mntIfEdgeManage.getEdgeResult().setResult(new MntIfEdgeManage.InnerEdgeResult());
    		}
    		mntIfEdgeManage.getEdgeResult().getResult().setStatus(IfedgeFixedResult.TIMEOUT.getStatus());
    		mntIfEdgeManage.getEdgeResult().getResult().setMessage(IfedgeFixedResult.TIMEOUT.getMessage());
    		mntIfEdgeManageDao.update(mntIfEdgeManage);
          /* upd by chamaojia 2026-04-28 [10959] システム内でstatic変数を使っている箇所の洗い出し  --start */
    		return createFixedReqponse(request.getFacilityCd(),IfedgeFixedResult.TIMEOUT, mntIfEdgeManage.getCtlNo(), result.getAdditionalMessage());
          /* upd by chamaojia 2026-04-28 [10959] システム内でstatic変数を使っている箇所の洗い出し  --end */
    	}
    	result.setStatus(String.valueOf(HttpStatus.OK.value()));
    	result.setResult(resultMntIfEdgeManage.getEdgeResult());
    }finally {
        deleteDirectory(commandDirPath);
    }
    return result;
  }

  /**
   * サーバ側エラー制御時連携エッジ制御指示管理更新
   *
   * @param facilityCd 施設コード
   * @param ifedgeFixedResult 連携エッジ固定結果定義
   */
  /* upd by chamaojia 2026-04-28 [10959] システム内でstatic変数を使っている箇所の洗い出し  --start */
  // private void clearIfEdgeManage(String facilityCd, IfedgeFixedResult ifedgeFixedResult) {
  private void clearIfEdgeManage(String facilityCd, IfedgeFixedResult ifedgeFixedResult, String additionalMessage) {
  /* upd by chamaojia 2026-04-28 [10959] システム内でstatic変数を使っている箇所の洗い出し  --end */

    // 対象エッジの連携エッジ制御指示管理のステータス更新
    MntIfEdgeManage mntIfEdgeManage = mntIfEdgeManageDao.selectByFacilityCdAndStatus(facilityCd, ResponseStatus.RUNNING.getStatus());
    if (mntIfEdgeManage != null) {
      mntIfEdgeManage.setResponseStatus(ResponseStatus.ERROR.getStatus());

      EdgeResult edgeResult = mntIfEdgeManage.getEdgeResult();
      if (edgeResult == null) {
        edgeResult = new EdgeResult();
        edgeResult.setSystem(IfEdgeConstants.IF_EDGE_CONNECT_SYSTEM_NAME);
        edgeResult.setFacilityCd(facilityCd);
        edgeResult.setStatus(ResultStatus.RESULT.getReceiveName());
        edgeResult.setResult(new MntIfEdgeManage.InnerEdgeResult());
        mntIfEdgeManage.setEdgeResult(edgeResult);
      }
      mntIfEdgeManage.getEdgeResult().getResult().setStatus(ifedgeFixedResult.getStatus());
      // mod 2021-05-26 外部連携API:ログを改善 孫 start
//      mntIfEdgeManage.getEdgeResult().getResult().setMessage(ifedgeFixedResult.getMessage());
      String resultMessage = ifedgeFixedResult.getMessage();
      if (!StringUtils.isEmpty(additionalMessage)) {
        resultMessage = String.format("%s (%s)", ifedgeFixedResult.getMessage(), additionalMessage);
      }
      mntIfEdgeManage.getEdgeResult().getResult().setMessage(resultMessage);
      /* del by chamaojia 2026-04-28 [10959] システム内でstatic変数を使っている箇所の洗い出し  --start */
      // additionalMessage = "";
      /* del by chamaojia 2026-04-28 [10959] システム内でstatic変数を使っている箇所の洗い出し  --end */
      // mod 2021-05-26 外部連携API:ログを改善 孫 end
      mntIfEdgeManageDao.update(mntIfEdgeManage);
    }
  }

  /**
   * 固定の結果を持つ連携エッジ指示レスポンスを作成して返却する。
   *
   * @param facilityCd 施設コード
   * @param ifEdgeResultDefaultResult 連携エッジ固定結果定義
   * @param ctlNo 管理NO
   * @return 連携エッジ指示レスポンス
   */
  /* upd by chamaojia 2026-04-28 [10959] システム内でstatic変数を使っている箇所の洗い出し  --start */
  private IfEdgeRestResult createFixedReqponse(String facilityCd, IfedgeFixedResult ifEdgeResultDefaultResult, Long ctlNo) {
    return createFixedReqponse(facilityCd, ifEdgeResultDefaultResult, ctlNo, null);
  }

  private IfEdgeRestResult createFixedReqponse(String facilityCd, IfedgeFixedResult ifEdgeResultDefaultResult, Long ctlNo,
      String additionalMessage) {
    IfEdgeRestResult result = new IfEdgeRestResult();
    result.setStatus(String.valueOf(HttpStatus.OK.value()));
    MntIfEdgeManage.EdgeResult ifEdgeResult = new MntIfEdgeManage.EdgeResult();
    ifEdgeResult.setSystem(IfEdgeConstants.IF_EDGE_CONNECT_SYSTEM_NAME);
    ifEdgeResult.setStatus(ResultStatus.RESULT.getReceiveName());
    ifEdgeResult.setFacilityCd(facilityCd);
    MntIfEdgeManage.InnerEdgeResult innerResult = new MntIfEdgeManage.InnerEdgeResult();
    innerResult.setStatus(ifEdgeResultDefaultResult.getStatus());
    innerResult.setMessage(ifEdgeResultDefaultResult.getMessage());
    innerResult.setCtlNo(ctlNo);
    ifEdgeResult.setResult(innerResult);
    result.setResult(ifEdgeResult);
    result.setAdditionalMessage(additionalMessage);

    return result;
  }
  /* upd by chamaojia 2026-04-28 [10959] システム内でstatic変数を使っている箇所の洗い出し  --end */

  /**
   * エッジに送信するZIPファイルを作成する。
   *
   * @param request 連携エッジwebsocket通信リクエスト
   * @param targetDir ZIP対象ディレクトリ名
   * @return zipファイル（Byte形式）
   */
  private byte[] createSendZip(IfEdgeWebsocketRequest request, String targetDir) throws IOException {

    // ディレクトリをファイル化
    File dir = new File(targetDir);
    ZipOutputStream zipOutputStream = null;
    ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
    zipOutputStream = new ZipOutputStream(new BufferedOutputStream(byteArrayOutputStream));
    List<File> files = new ArrayList<File>();
    getFiles(dir, files);

    // ファイルをZIPに格納
    for (File file : files) {
      // ZIP化実施ファイルの情報をオブジェクトに設定
      StringBuilder zipEntryPath = new StringBuilder();
      if (file.compareTo(dir) == 0) {
        zipEntryPath.append(dir.getName());
      } else {
        // mod 2021-06-07 #5235:エッジの設定を自動で取り込むことができない 孫 start
//        // mod 2021-05-24 ifedgeメンテンス：ファイル名の取得モデルを変更すう 孫 start
////        String entryName = file.getAbsolutePath().substring(targetDir.length() + 1);
//        String entryName = file.getName();
//        // mod 2021-05-24 ifedgeメンテンス：ファイル名の取得モデルを変更すう 孫 end
        String entryName = file.getPath().substring(targetDir.length() + 1);
        // mod 2021-06-07 #5235:エッジの設定を自動で取り込むことができない 孫 end
        zipEntryPath.append(dir.getName()).append(IfEdgeConstants.FILE_SEPARATOR).append(entryName);
      }
      if (file.isDirectory()) {
        zipEntryPath.append(IfEdgeConstants.FILE_SEPARATOR);
      }

      ZipEntry entry = new ZipEntry(zipEntryPath.toString());
      zipOutputStream.putNextEntry(entry);
      if (file.isFile()) {
        // ZIPファイルに情報を書き込む
        InputStream inputStream = new BufferedInputStream(new FileInputStream(file));
        int len = 0;
        byte[] buf = new byte[1024];
        while ((len = inputStream.read(buf)) != -1) {
          zipOutputStream.write(buf, 0, len);
        }
        // ストリームを閉じる
        inputStream.close();
      }
    }
    zipOutputStream.closeEntry();
    zipOutputStream.close();

    return byteArrayOutputStream.toByteArray();
  }

  /**
   * 指定ディレクトリ配下のファイルをサブディレクトリ含めてList<File>に集める。
   *
   * @param parentDir 親ディレクトリ
   * @param files ファイルリスト
   */
  private static void getFiles(final File parentDir, final List<File> files) {

    // ZIPルートディレクトリ追加
    files.add(parentDir);

    // ファイル取得対象フォルダ直下のファイル,ディレクトリを走査
    for (File f : parentDir.listFiles()) {
      if (f.isFile()) {
        // ファイルの場合はファイル一覧に追加
        files.add(f);
      } else if (f.isDirectory()) {
        // ディレクトリの場合は再帰処理
        getFiles(f, files);
      }
    }
  }

  /**
   * コマンドファイル作成
   *
   *@param command コマンドキー
   *@param dir 作成ディレクトリ
   */
  private void createCommandFile(String command, String dir, MstIfEdgeCommand mstIfEdgeCommand) throws IOException {

    // コマンド本文取得
    List<String> commandList = new ArrayList<String>();
    commandList.add(mstIfEdgeCommand.getCommand());

    // コマンドファイル作成
    Path commandFilePath = Paths.get(dir, IfEdgeConstants.COMMAND_FILE);
    Files.createFile(commandFilePath);
    Files.write(commandFilePath, commandList, StandardCharsets.UTF_8, StandardOpenOption.TRUNCATE_EXISTING);
  }
  // mod 2022-09-29  6920 IFエッジ設定更新時に再起動が行われない 孫 start
//  // add 6920 IFエッジ設定更新時に再起動が行われない 張 start
//  /**
//   * ファイル作成
//   *
//   *@param dir 作成ファイル
//   */
//  private void createFile(IfEdgeWebsocketRequest request,String dir,String fileName) throws IOException {
//   String filePath=ifEdgeConfigulation.getResourcePath()+File.separator+request.getFacilityCd()+File.separator+fileName;
//    List<String> lines = Files.readAllLines(Paths.get(filePath),
//            StandardCharsets.UTF_8);
//    // コマンドファイル作成
//    Path settingFileDir =  Paths.get(dir + ifEdgeConfigulation.getCommandSettingDir());
//    Files.createDirectories(settingFileDir);
//    Path commandFilePath = Paths.get(settingFileDir.toString(), fileName);
//    Files.createFile(commandFilePath);
//    Files.write(commandFilePath, lines, StandardCharsets.UTF_8, StandardOpenOption.TRUNCATE_EXISTING);
//  }
//  // add 6920 IFエッジ設定更新時に再起動が行われない 張 end
  /**
   * ファイル作成
   *
   *@param dir 作成ファイル
   */
  private void createFile(IfEdgeWebsocketRequest request,String dir) throws IOException {
    String dirTmp = ifEdgeConfigulation.getResourcePath() + File.separator + request.getCommand();
    String srcDirString = Paths.get(dirTmp).toString();

    String destDirString = dir + ifEdgeConfigulation.getCommandSettingDir();
    Path destDirPath =  Paths.get(destDirString);
    destDirString = destDirPath.toString();
    Files.createDirectories(destDirPath);

    List<String> srcFiles = listFiles(srcDirString, new ArrayList<>());
    // コマンドファイル作成
    for (String srcFile : srcFiles) {
      byte[] srdData = Files.readAllBytes(Paths.get(srcFile));

      Path commandFilePath = Paths.get(srcFile.replace(srcDirString, destDirString));
      Files.createDirectories(commandFilePath.getParent());
      Files.createFile(commandFilePath);
      Files.write(commandFilePath, srdData, StandardOpenOption.TRUNCATE_EXISTING);
    }
  }

  public List<String> listFiles(String filePath, List<String> fileArr) {
    File[] files = new File(filePath).listFiles();
    for (int k = 0; k < files.length; k++) {
      if (files[k].isDirectory()) {
        listFiles(files[k].getPath(), fileArr);
      } else if (!files[k].isDirectory()) {
        fileArr.add(files[k].getAbsolutePath());
      }
    }
    return fileArr;
  }
  // mod 2022-09-29  6920 IFエッジ設定更新時に再起動が行われない 孫 start
  /**
   * 施設ごと設定ファイル作成
   *
   *@param command コマンドキー
   *@param parentDir 作成ディレクトリ
   *@throws IOException
   */
  private void createFacilitySetting(String facilityCd, String parentDir) throws IOException {

    // 連携設定マスタから設定内容を取得
    MstCoopFacility mstCoopFacility = mstCoopFacilityDao.select(facilityCd);
    // add 2021-06-07 #5235:エッジの設定を自動で取り込むことができない 孫 start
    if (mstCoopFacility == null || StringUtils.isEmpty(mstCoopFacility.getIfEdgeSetting())) {
      throw new IOException("連携設定マスタの施設コード[" + facilityCd+ "]のIFエッジ設定が無し。");
    }
    // add 2021-06-07 #5235:エッジの設定を自動で取り込むことができない 孫 end
    List<String> settingList = new ArrayList<String>();
    settingList.add(mstCoopFacility.getIfEdgeSetting());

    // コマンドファイル作成
    Path settingFileDir =  Paths.get(parentDir + ifEdgeConfigulation.getCommandSettingDir());
    Files.createDirectories(settingFileDir);
    Path settingFilePath = Paths.get(settingFileDir.toString(), ifEdgeConfigulation.getCommandSettingFile());
    Files.createFile(settingFilePath);
    Files.write(settingFilePath, settingList, StandardCharsets.UTF_8, StandardOpenOption.TRUNCATE_EXISTING);
  }

  /**
   * 管理NOファイル作成
   *
   * @param facilityCd 施設コード
   * @param targetDir 作成先ディレクトリ名
   * @param ctlNo 管理NO
   * @return 連携エッジ指示レスポンス
   */
  private IfEdgeRestResult createCtlNoFile(String facilityCd, String targetDir, long ctlNo) {

    IfEdgeRestResult ret = null;
    EventLogMessage eventLogMessage = new EventLogMessage();

    try {
      // 以前の管理NOファイルを削除
      Path startDir = Paths.get(targetDir);
      Stream<Path> ctlNoStreamPaths = Files.walk(startDir).filter(file -> file.getFileName().toString().startsWith(IfEdgeConstants.CTL_NO_FILE_PREFIX));
      List<Path> ctlNoList = ctlNoStreamPaths.collect(Collectors.toList());
      for (Path ctlNoFile : ctlNoList) {
        Files.delete(ctlNoFile);
      }

      // 管理NOファイル作成
      StringBuilder ctlNoFileName = new StringBuilder();
      ctlNoFileName.append(targetDir)
                   .append(IfEdgeConstants.FILE_SEPARATOR)
                   .append(IfEdgeConstants.CTL_NO_FILE_PREFIX)
                   .append(String.valueOf(ctlNo));

      File ctlNoFile = new File(ctlNoFileName.toString());
      ctlNoFile.createNewFile();
    } catch(IOException ioe) {
      /* upd by chamaojia 2026-04-28 [10959] システム内でstatic変数を使っている箇所の洗い出し  --start */
      // // add 2021-05-26 外部連携API:ログを改善 孫 start
      // additionalMessage = ioe.toString();
      // // add 2021-05-26 外部連携API:ログを改善 孫 end
      // 管理NOファイル作成失敗
      eventLogMessage.setLogMessage(IfedgeFixedResult.CTLNO_FILE_ERR.getMessage());
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      ret = createFixedReqponse(facilityCd, IfedgeFixedResult.CTLNO_FILE_ERR, ctlNo, ioe.toString());
      /* upd by chamaojia 2026-04-28 [10959] システム内でstatic変数を使っている箇所の洗い出し  --end */
    }

    return ret;
  }

  /**
   * コマンド／ファイル指定によって適切なディレクトリパスを取得
   * @param request HTTPリクエスト
   * @return ディレクトリパス
   */
  private String getTargetDir(IfEdgeWebsocketRequest request, String dateDir) {
    StringBuffer targetDirBuffer = new StringBuffer(ifEdgeConfigulation.getResourcePath());
    // 「mod 6920 IFエッジ設定更新時に再起動が行われない 張」の対応を削除する。
    if (ExeType.COMMAND.getType().equals(request.getType())) {
      // 指示種別がコマンド
      targetDirBuffer.append(IfEdgeConstants.FILE_SEPARATOR)
                     .append(request.getFacilityCd())
                     .append(ifEdgeConfigulation.getCommandSaveDir())
                     .append(IfEdgeConstants.FILE_SEPARATOR)
                     .append(dateDir);
    } else {
      // 指示種別がファイル
      if (request.getDirPath().startsWith(IfEdgeConstants.FILE_SEPARATOR)) {
        targetDirBuffer.append(request.getDirPath());
      } else {
        targetDirBuffer.append(IfEdgeConstants.FILE_SEPARATOR).append(request.getDirPath());
      }
    }
    return targetDirBuffer.toString();
  }

  /**
   * ファイル内の"DATA_PATH"文字列を置換する。
   *
   * @param targetFilePath 置換対象ファイル
   * @param dataPath 置換文字列
   * @throws IOException
   */
  private void replaceDataPathString(Path targetFilePath, String dataPath) throws IOException {

    if (!Files.exists(targetFilePath)) {
      return;
    }

    List<String> processingLines = Files.readAllLines(targetFilePath);
    List<String> replacedLines = new ArrayList<String>();

    for (String processingLine : processingLines) {
      String replacedLine = processingLine.replace(IfEdgeConstants.REPLACE_STRING_DIR_PATH, dataPath);
      replacedLines.add(replacedLine);
    }
    Files.write(targetFilePath, replacedLines, StandardCharsets.UTF_8, StandardOpenOption.TRUNCATE_EXISTING);
  }


  /**
   * 指定されたディレクトリを内部のファイルも含めて削除する。
   *
   * @param dir 削除対象パス
   * @throws IOException
   */
  private void deleteDirectory(Path dir) {
	  EventLogMessage eventLogMessage = new EventLogMessage();
	  if (Files.notExists(dir)) {
		  return; // 存在しないなら何もしない
	  }
	  try {
		  Files.walk(dir)
		  .sorted(Comparator.reverseOrder())
		  .forEach(path -> {
			  try {
				  Files.deleteIfExists(path);
			  } catch (IOException e) {
				  // ログだけ出して続行
  				eventLogMessage.setLogMessage("ファイル削除失敗: path= " + path.toString());
  				eventLogMessage.setInvokeClass(this.getClass().getName());
  				logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI, null);
			  }
		  });
	  } catch (IOException e) {
		  // walk 自体が失敗した場合のログ
		  eventLogMessage.setLogMessage("ディレクトリ走査に失敗しました: path= " + dir.toString());
		  eventLogMessage.setInvokeClass(this.getClass().getName());
		  logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI, null);
	  }
  }
}
