package jp.co.nikkiso.ntss.admin_web.service.filterLog;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.net.URI;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.Files;
import java.nio.file.attribute.BasicFileAttributes;
import java.text.DateFormat;
import java.text.MessageFormat;
import java.text.ParseException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Stack;
import java.util.UUID;
import java.util.regex.Pattern;
import java.util.stream.Collectors;
import java.text.SimpleDateFormat;
import java.util.stream.Stream;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

import jp.co.nikkiso.ntss.core.constant.LogTypeEnum;
import jp.co.nikkiso.ntss.core.logger.ChangeConditionLogAPI;
import jp.co.nikkiso.ntss.core.logger.ChangeEventLogAPI;
import jp.co.nikkiso.ntss.core.logger.EventLogAPI;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import jp.co.nikkiso.ntss.core.logger.FileInfoLog;
import jp.co.nikkiso.ntss.core.logger.FileInfoModelLog;
import jp.co.nikkiso.ntss.core.logger.FilterConditionLogAPI;
import jp.co.nikkiso.ntss.core.logger.FilterLogAPI;
import jp.co.nikkiso.ntss.core.logger.LogClass;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.logger.MongoChangeLogAPI;
import jp.co.nikkiso.ntss.core.logger.MongoLogAPI;
import jp.co.nikkiso.ntss.core.logger.ReadLogAPI;
import jp.co.nikkiso.ntss.core.utils.MongoHealthCheckService;
import org.apache.commons.lang3.tuple.Pair;

import com.mongodb.BasicDBList;
import com.mongodb.BasicDBObject;
import com.mongodb.DBObject;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.core.logevent.DataUpdateLogCommonNew;
import jp.co.nikkiso.ntss.core.logevent.LogServiceCore;

import jp.co.nikkiso.ntss.core.utils.NtssUtils;
import org.json.JSONArray;
import org.json.JSONObject;
import org.seasar.doma.jdbc.Config;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import org.springframework.aop.framework.AopProxyUtils;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end
import org.springframework.beans.factory.annotation.Autowired;
//add FNSI-mongoDBに挿入、検索できることの対応 start
import org.springframework.dao.DataAccessResourceFailureException;
import org.springframework.data.domain.Sort;
//add FNSI-mongoDBに挿入、検索できることの対応 end
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.aggregation.Aggregation;
import org.springframework.data.mongodb.core.aggregation.AggregationOperation;
import org.springframework.data.mongodb.core.query.BasicQuery;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.http.HttpStatus;
import org.springframework.http.RequestEntity;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.common.base.Strings;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.MstUserDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilityDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.dao.SysSystemDefineDao;
import jp.co.nikkiso.ntss.core.dao.MstPersonalUserDao;
import jp.co.nikkiso.ntss.core.entity.MstUser;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.MstFacility;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.entity.SysSystemDefine;
import org.springframework.util.CollectionUtils;
import org.springframework.util.StringUtils;
//import org.springframework.web.client.ResponseErrorHandler;
import org.springframework.web.client.RestTemplate;

// add LOG message 明文化 chen start
import jp.co.nikkiso.ntss.core.logevent.ILogEventService;
// add LOG message 明文化 chen end
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
//import jp.co.nikkiso.ntss.admin_web.web.rest.util.WebApiCallCommonUtil.NoProcResponseErrorHandler;
import jp.co.nikkiso.ntss.admin_web.service.utils.AggregationUtils;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import static jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils.toJson;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end

@Service
public class FilterLogServiceImpl implements FilterLogService {

	// 利用者マスタのDaoインタフェース.
	@Autowired
	MstUserDao mstUserDao;

	@Autowired
	PatPersonalMainDao patPersonalMainDao;
	/**
	 * システム設定マスタのDaoインタフェース
	 */
	@Autowired
	private SysSystemDefineDao sysSystemDefineDao;

	/**
	* 施設マスタのDaoインタフェース.
	*/
	@Autowired
	private MstFacilityDao mstFacilityDao;

	/**
	* 利用者マスタ(個人情報DB)Daoインタフェース.
	*/
	@Autowired
	private MstPersonalUserDao mstPersonalUserDao;

    /**
    * 治療情報Daoインタフェース.
    */
	@Autowired
	private OrdMainDao ordMainDao;

  //FNSI-修正 ログ対応 xiebzh add start
  @Autowired(required = false)
  MongoTemplate mongoTemplate;
  //FNSI-修正 ログ対応 xiebzh add end

  // DB更新ログ出力ロジック wangzuo Start
  @Autowired
  private EventLoggerFactory eventLoggerFactory;

  @Autowired
  private LogServiceCore logServiceCore;
  // DB更新ログ出力ロジック wangzuo End

  // add LOG message 明文化 chen start
  @Autowired
  private ILogEventService logEventService;
  // add LOG message 明文化 chen end

  // xietest start
  @Autowired
  private LogService logService;
  // xietest end
	/**
	 * フィルターリスト
	 * @throws Exception
	 */
	@Override
	public List<EventLogAPI> filterLog(FilterConditionLogAPI api) throws Exception {
		String folderNameEvent = "";
		String folderNameApp = "";
		FilterLogAPI filterLogAPI = new FilterLogAPI();
		List<EventLogAPI> logAPIs = new ArrayList<EventLogAPI>();
    List<String> facilityCd = api.getFacilityCd();
    for (String folderName: facilityCd) {
      if (api.getClassification().contains(String.valueOf(LogClass.EVENT.getLogClass()))) {
        folderNameEvent = MessageFormat.format(getPathOutput(CoreConstant.SysSystemDefine.EVENT_LOGGING), folderName);
        String[] arrEvent = folderNameEvent.split("/");
        folderNameEvent = String.join("/", Arrays.copyOf(arrEvent, arrEvent.length-1));
        List<EventLogAPI> logEventAPIs = filterLogAPI.Fillter(folderNameEvent, api);
        logAPIs.addAll(logEventAPIs);
      }
      if (api.getClassification().contains(String.valueOf(LogClass.APP.getLogClass()))) {
        folderNameApp = MessageFormat.format(getPathOutput(CoreConstant.SysSystemDefine.APPLICATION_LOGGING), folderName);
        String[] arrApp = folderNameApp.split("/");
        folderNameApp = String.join("/", Arrays.copyOf(arrApp, arrApp.length-1));
        List<EventLogAPI> logAppAPIs = filterLogAPI.Fillter(folderNameApp, api);
        logAPIs.addAll(logAppAPIs);
      }
    }

		logAPIs.sort((o1, o2) -> o1.getDate().compareTo(o2.getDate()));
		if (logAPIs.size() > 0) {
			List<String> listPatId = logAPIs.stream().filter(i -> !Strings.isNullOrEmpty(i.getPatId()))
					.map(EventLogAPI::getPatId).collect(Collectors.toList());
			if (listPatId != null) {
				List<Long> listPatIdParse = listPatId.stream().filter(i -> isNumeric(i)).map(Long::parseLong).distinct().collect(Collectors.toList());
				List<PatPersonalMain> listPatPersonal = patPersonalMainDao.selectByIdList(listPatIdParse);
				if (listPatPersonal.size() > 0) {
					logAPIs.forEach(i -> {
						if (!Strings.isNullOrEmpty(i.getPatId())) {
							PatPersonalMain pat = listPatPersonal.stream()
									.filter(p -> p.getPat_id().equals(Long.valueOf(i.getPatId()))).findAny().orElse(null);
							if (pat != null) {
                                // mod #9485  shiyw start
                                String pat_last_name = pat.getPat_last_name() == null?"":pat.getPat_last_name();
                                String pat_first_name = pat.getPat_first_name() == null?"":pat.getPat_first_name();
                                i.setPatName(pat_last_name + " " + pat_first_name);
                                // mod #9485  shiyw end
								i.setHospPatId(pat.getHosp_pat_id());
							}
						}
					});
				}
			}

			List<String> listUserId = logAPIs.stream().filter(i -> !Strings.isNullOrEmpty(i.getUserId()))
					.map(EventLogAPI::getUserId).collect(Collectors.toList());
			if (listUserId != null) {
				List<Long> listUserIdParse = listUserId.stream().filter(i -> isNumeric(i)).map(Long::parseLong).distinct().collect(Collectors.toList());
				List<MstPersonalUser> listPersonalUser = mstPersonalUserDao.selectByIdList(listUserIdParse);
				if (listPersonalUser.size() > 0) {
					logAPIs.forEach(i -> {
						if (!Strings.isNullOrEmpty(i.getUserId())) {
							MstPersonalUser person = listPersonalUser.stream()
									.filter(p -> p.getUserId().equals(Long.valueOf(i.getUserId()))).findAny().orElse(null);
							if (person != null) {
								//update FNSI-mongoDBに挿入、検索できることの対応 start
								i.setUser(person.getUserLastName() + " " + person.getUserFirstName());
								//update FNSI-mongoDBに挿入、検索できることの対応 end
							}
						}
					});
				}
			}

			List<String> listFacilityCds = logAPIs.stream().filter(i -> !Strings.isNullOrEmpty(i.getFacilityCd()))
					.map(EventLogAPI::getFacilityCd).distinct().collect(Collectors.toList());
			List<MstFacility> listFacility = mstFacilityDao.selectByFacilityCds(listFacilityCds);
			if (listFacility.size() > 0) {
				logAPIs.forEach(i -> {
					if (!Strings.isNullOrEmpty(i.getFacilityCd())) {
						MstFacility facility = listFacility.stream()
								.filter(p -> p.getFacilityCd().equals(i.getFacilityCd())).findAny().orElse(null);
						if (facility != null) {
							i.setFacilityName(facility.getFacilityName());
						}

					}
				});
			}

			return logAPIs;
		}
		return null;
	}

  /**
   * フィルターリスト
   * @throws Exception
   */
  @Override
  public List<EventLogAPI> filterMongoLog(FilterConditionLogAPI api) throws Exception {
    String collection = "log_event";
    Map<String,String> columnsKey = new HashMap<String,String>();
    columnsKey.put("date","log_date");
    columnsKey.put("clientIp","client_ip");
    columnsKey.put("functionName","function_name");
    columnsKey.put("patId","pat_id");
    columnsKey.put("facilityCd","facility_cd");
    columnsKey.put("hospPatId","hosp_pat_id");
    columnsKey.put("sessionId","session_id");
    columnsKey.put("logType","log_type");
    columnsKey.put("facilityName","facility_name");
    columnsKey.put("serviceName","svc_name");
    columnsKey.put("userId","user_id");

    columnsKey.put("deviceEdgeNo","de_no");
    columnsKey.put("deviceEdgeSerialNo","de_serial");
    columnsKey.put("machineType","mcn_type");
    columnsKey.put("machineTypeCd","mcn_type_cd");
    columnsKey.put("ec2Identification","ec2_ip");

    //add  #6547 ログ表示不正の修正。start
    long skipCount = api.getFilterTimes()*api.getPageSize();
    //add  #6547 ログ表示不正の修正。end

    ArrayList<DBObject> list = new ArrayList<DBObject>();
    getFilterContition(list, "log_date", getStrDate(api.getStrFromDate(), 0), "$gte");
    getFilterContition(list, "log_date", getStrDate(api.getStrToDate(), 1), "$lte");
    /* modify by chamaojia 2023-04-06 [7186] documentDB in文はインデックスを使用できません、変更orはインデックスを使用できます --start */
    /**
     * awsで使用されているデータベースはdocumentDBであり、mongodbとはまだいくつかの違いがあります。
     * 現在、in文はdocumentDB上でインデックスを使用できないことがわかりました。orは可能です
     */
//    getFilterContition(list, "facility_cd", api.getFacilityCd(), "$in");
    ArrayList<DBObject> facilityCdOrDataList = new ArrayList<>();
    List<String> facilityCdList = api.getFacilityCd();
    // #9698すべての施設が、OS、Tomcat、Jar、War の起動および停止ログを閲覧できるようにする。 start
    facilityCdOrDataList.add(new BasicDBObject("facility_cd", "system"));
    String additional = Stream.of(
        LogTypeEnum.TOMCAT_BOOT,
        LogTypeEnum.TOMCAT_DOWN,
        LogTypeEnum.JAR_BOOT,
        LogTypeEnum.JAR_DOWN,
        LogTypeEnum.WAR_BOOT,
        LogTypeEnum.WAR_DOWN,
        LogTypeEnum.OS_BOOT,
        LogTypeEnum.OS_DOWN
      ).map(Enum::name)
      .collect(Collectors.joining(","));
    api.setLogType(api.getLogType() + "," + additional);
    // #9698 すべての施設が、OS、Tomcat、Jar、War の起動および停止ログを閲覧できるようにする。 start
    for (String facilityCd : facilityCdList) {
      facilityCdOrDataList.add(new BasicDBObject("facility_cd", facilityCd));
    }
    list.add(new BasicDBObject("$or", facilityCdOrDataList));
    /* modify by chamaojia 2023-04-06 [7186] documentDB in文はインデックスを使用できません、変更orはインデックスを使用できます --end */
    getFilterContition(list, "log_type", convertString(api.getLogType()).toUpperCase(), "$eq");
    getFilterContition(list, "user_id", api.getUserId(), "$eq");
    getFilterContition(list, "pat_id", api.getPatId(), "$eq");
    getFilterContition(list, "func_cd", api.getServiceName(), "$eq");
    // add #6775 ログの抽出が正しく行われない 鄭爽 start
    if (api.getKeySearch() != null && (api.getTypeSearch() == 1 || api.getTypeSearch() == 5)) {
      // mod 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zhou start
      //getKeySearchAndCondition(list, convertString(api.getTypeSearch()), api.getKeySearch(), api.getDisplayItems());
      getKeySearchAndCondition(list, convertString(api.getTypeSearch()), api.getKeySearch(), api.getDisplayItems(),api.getFacilityCd());
      // mod 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zhou end
    }
    // add #10016 ログ参照画面でフィルタ検索で追加読みで検索条件が破棄されている fang start
    if(!CollectionUtils.isEmpty(api.getDisplayItems())) {
      createDisplayItemsCondition(list, api.getDisplayItems(), api.getFacilityCd());
    }
    // add #10016 ログ参照画面でフィルタ検索で追加読みで検索条件が破棄されている fang end
    // add #6775 ログの抽出が正しく行われない 鄭爽 end
    DBObject obj = new BasicDBObject();
    obj.put("$and",list);
    // add #6775 ログの抽出が正しく行われない 鄭爽 start
    if (api.getKeySearch() != null && api.getTypeSearch() != 1 && api.getTypeSearch() != 5) {
      ArrayList<DBObject> keyList = new ArrayList<DBObject>();
      // mod 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zhou start
      //getKeySearchOrCondition(keyList, convertString(api.getTypeSearch()), api.getKeySearch(), api.getDisplayItems());
      getKeySearchOrCondition(keyList, convertString(api.getTypeSearch()), api.getKeySearch(), api.getDisplayItems(),api.getFacilityCd());
      // mod 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zhou end
      obj.put("$or", keyList);
    }
    // add #6775 ログの抽出が正しく行われない 鄭爽 end

    /**
     * MongoDB event_log検索
     */

    // 並び順決定
    Sort.Direction direction = api.getSortOrder() ? Sort.Direction.ASC : Sort.Direction.DESC;
    // ソートキーを取得
    String uiSortKey = api.getSortKey();
    String sortField  = columnsKey.get(uiSortKey);

    // 数値としてソートするフィールドを判定
    boolean numericSort =
        "patId".equals(uiSortKey) ||
        "userId".equals(uiSortKey) ||
        "hospPatId".equals(uiSortKey);

    List<AggregationOperation> ops = new ArrayList<>();

    // 抽出条件セット
    ops.add(new AggregationUtils.DbObjectMatchOperation(obj));
    // ソート要件セット
    if (numericSort) {
  	  // 数値としてソート（患者IDシステム共通ソート）
      String baseAlias = sortField;
      ops.addAll(AggregationUtils.buildNumericSortOps(sortField, baseAlias, direction));
  	} else {
      // 通常のソート
      ops.add(Aggregation.sort(direction, sortField));
  	}

    // ページング
  	ops.add(Aggregation.skip(skipCount));
    if (api.getPageSize() > 0) {
      ops.add(Aggregation.limit(api.getPageSize()));
    }

    Aggregation aggregation = Aggregation.newAggregation(ops);
    List<MongoLogAPI> result = Collections.emptyList();
    try {
      if (MongoHealthCheckService.getMongoDBConnected()) {
        result = mongoTemplate.aggregate(aggregation, collection, MongoLogAPI.class).getMappedResults();
      }
    } catch (DataAccessResourceFailureException e) {
      MongoHealthCheckService.setMongoDBConnected(false);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("log_eventデータ取得失敗：" + ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessage, "", SERVICE_NAME.FNSI, null);
    }

    result = changeMongoList(result);
    return toEventLogAPI(result);
  }


  /**
   * EventLogAPI変換する
   * @param mongoList
   * @return
   */
  private List<EventLogAPI> toEventLogAPI(List<MongoLogAPI> mongoList) {
    EventLogAPI eventLogAPI = null;
    List<EventLogAPI> apiList = new ArrayList<EventLogAPI>();
    for (MongoLogAPI mongoApi : mongoList) {
      eventLogAPI = new EventLogAPI();
      SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yyyyMMddHHmmssSSS");
      try {
        eventLogAPI.setDate(simpleDateFormat.parse(mongoApi.getLog_date()));
      } catch (ParseException e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
      }

      eventLogAPI.setLogType(mongoApi.getLog_type());
      eventLogAPI.setFacilityCd(mongoApi.getFacility_cd());
      eventLogAPI.setUserId(mongoApi.getUser_id());
      eventLogAPI.setClientIp(mongoApi.getClient_ip());
      eventLogAPI.setSessionId(mongoApi.getSession_id());
      eventLogAPI.setDeviceEdgeNo(mongoApi.getDe_no());
      eventLogAPI.setDeviceEdgeSerialNo(mongoApi.getDe_serial());
      eventLogAPI.setMachineType(mongoApi.getMcn_type());
      eventLogAPI.setMachineTypeCd(mongoApi.getMcn_type_cd());
      eventLogAPI.setEc2Identification(mongoApi.getEc2_ip());
      // mod 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zkm start
      // eventLogAPI.setServiceName(mongoApi.getFunc_cd());
      eventLogAPI.setServiceName(mongoApi.getSvc_name());
      // mod 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zkm end
      eventLogAPI.setFunctionName(mongoApi.getFunction_name());
      eventLogAPI.setFunctionCd(mongoApi.getFunc_cd());
      eventLogAPI.setPatId(mongoApi.getPat_id());
      eventLogAPI.setHospPatId(mongoApi.getHosp_pat_id());
      eventLogAPI.setLogMessage(mongoApi.getMessage());
      eventLogAPI.setSupportMessage(mongoApi.getTodo());
      eventLogAPI.setPatName(mongoApi.getPat_name());
      eventLogAPI.setUser(mongoApi.getUser_name());
      eventLogAPI.setFacilityName(mongoApi.getFacility_name());

      // add 問題解決ログが正常にソートされませんた 周炜博 start
      eventLogAPI.setHospPatId(mongoApi.getHosp_pat_id());
      eventLogAPI.setLogType( mongoApi.getLog_type());
      // add 問題解決ログが正常にソートされませんた 周炜博 end
      apiList.add(eventLogAPI);
    }
    return apiList;
  }

// add LOG 明文化 chen start
private List<MongoLogAPI> changeMongoList(List<MongoLogAPI> mongoList) {
  for (MongoLogAPI mongoApi : mongoList) {
    mongoApi.setMessage(changeDecrypt(mongoApi.getMessage()));
    mongoApi.setPat_name(logEventService.getPersonalInfoDecrypt(mongoApi.getPat_name()));
    mongoApi.setUser_name(logEventService.getPersonalInfoDecrypt(mongoApi.getUser_name()));
    mongoApi.setFacility_name(logEventService.getPersonalInfoDecrypt(mongoApi.getFacility_name()));
  }
  return mongoList;
}
private String changeDecrypt(String strOld) {
    String strNew = "";
    if (strOld != null) {
      String[] messageArray = strOld.split(DataUpdateLogCommonNew.CUT_STR);
      strNew = strNew + messageArray[0];
      for (int i = 1; i < messageArray.length; i = i + 2) {
        strNew = strNew + logEventService.getPersonalInfoDecrypt(messageArray[i]);
        strNew = strNew + messageArray[i + 1];
      }
    }
    return strNew;
  }
// add LOGage 明文化 chen end
// add 変更履歴画面追加 陳 start
  /**
   * フィルターリスト
   * @throws Exception
   */
  @Override
  public List<ChangeEventLogAPI> changeMongoLog(ChangeConditionLogAPI api) throws Exception {
    String collection = "rst_history";
    if (api == null) {
      return new ArrayList<ChangeEventLogAPI>();
    }

    String rstEditionMax = "0";

    // 版最大値取得の為、治療情報取得
    OrdMain ord = ordMainDao.selectByOrdNo(Long.valueOf(api.getOrdNo()));
    if (ord != null) {
      rstEditionMax = Integer.toString(ord.getRstEdition());
    }
    ArrayList<DBObject> list = new ArrayList<DBObject>();
    getFilterContition(list, "ord_no", api.getOrdNo(), "$eq");
    getFilterContition(list, "rst_edition", api.getRstEdition(), "$eq");
    DBObject obj = new BasicDBObject();
    obj.put("$and", list);
    Query query = new BasicQuery(obj.toString());
    List<MongoChangeLogAPI> result = new ArrayList<>();

    //add 10248 mongodbリンク可能状態による関連操作の処理 gjn start
    try {
      if (MongoHealthCheckService.getMongoDBConnected()) {
        result = mongoTemplate.find(
          query.with(Sort.by(Sort.Direction.ASC, "up_date")), MongoChangeLogAPI.class, collection
        );
      }
    } catch (DataAccessResourceFailureException exception) {
      MongoHealthCheckService.setMongoDBConnected(false);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//            exception.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(exception));
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
    }
    //add 10248 mongodbリンク可能状態による関連操作の処理 gjn end
    return toChangeEventLogAPI(result, rstEditionMax);
  }


  /**
   * EventLogAPI変換する
   * @param mongoList
   * @return
   */
  private List<ChangeEventLogAPI> toChangeEventLogAPI(List<MongoChangeLogAPI> mongoList, String rstEditionMax) {
    ChangeEventLogAPI eventLogAPI = null;
    List<ChangeEventLogAPI> apiList = new ArrayList<ChangeEventLogAPI>();
    HashMap<String, ChangeEventLogAPI> apiMap = new HashMap<String, ChangeEventLogAPI>();
    List<String> sortKey = new ArrayList<String>();
    for (MongoChangeLogAPI mongoApi : mongoList) {
      String key = mongoApi.getUp_date() + "," + mongoApi.getUp_user_id();
      if (apiMap.containsKey(key)) {
        eventLogAPI = apiMap.get(key);
        eventLogAPI.setMessage(eventLogAPI.getMessage() + "<br>" + mongoApi.getMessage());
      } else {
        sortKey.add(key);
        eventLogAPI = new ChangeEventLogAPI();
        eventLogAPI.setOrdNo(mongoApi.getOrd_no());
        eventLogAPI.setRstEdition(mongoApi.getRst_edition());
        eventLogAPI.setUpDate(mongoApi.getUp_date());
        eventLogAPI.setUpUserId(mongoApi.getUp_user_id());
        eventLogAPI.setUpUserName(logEventService.getPersonalInfoDecrypt(mongoApi.getUp_user_name()));
        eventLogAPI.setMessage(changeDecrypt(mongoApi.getMessage()));
        eventLogAPI.setRstEditionMax(rstEditionMax);
        apiMap.put(key, eventLogAPI);
      }
    }
    Collections.sort(sortKey);
    Collections.reverse(sortKey);
    for (String key : sortKey) {
      eventLogAPI = apiMap.get(key);
      apiList.add(eventLogAPI);
    }
    return apiList;
  }
// add 変更履歴画面追加 陳 end

  /**
   * ログ設定再読み込み処理
   */
  @Override
  public String loggerSetFlgUpdate() {
    // 応答データ格納用
    JSONObject resultObj = new JSONObject("{}");
    JSONArray errList = new JSONArray();

    // 対応を行うサーバーIP、モジュール名のリスト
    HashMap<String, List<String>> targetList = new HashMap<>();
    // sys_system_define の設定を読み込む
    List<SysSystemDefine> systemData = sysSystemDefineDao.selectByCtlNo(CoreConstant.SysSystemDefine.LOGGER_UPDATE_TARGET_LIST);
    if (systemData.size() > 0) {
      String strJson = systemData.get(0).getValue();
      try {
        JSONObject objJson = new JSONObject(strJson);
        Iterator<String> keys = objJson.keys();
        while(keys.hasNext()){
          String ipAddr = keys.next();
          JSONArray value = objJson.getJSONArray(ipAddr);
          List<String> mdList = new ArrayList<String>();
          for (int i = 0; i < value.length(); i++) {
            mdList.add(value.getString(i));
          }
          // 対象モジュールが存在する場合は、リストに含める
          if (mdList.size() > 0) {
            targetList.put(ipAddr, mdList);
          }
        }
      } catch (Exception e) {
        // sys_system_define の設定展開エラー
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
      }
    }
    // 対応を行うサーバーが存在する場合は処理を実施
    if (targetList.size() > 0) {
      resultObj.put("readSetting", true);
      for (String ipAddr2 : targetList.keySet()) {
        List<String> mdList2 = targetList.get(ipAddr2);
        for (String mdName : mdList2) {
          try {
            // 送信URI
            URI uri = new URI("http://" + ipAddr2 + "/" + mdName + LoggingConstant.LOGGER_RESET.REQUEST_MAPPING + LoggingConstant.LOGGER_RESET.ACCESS_URI);
            // リクエスト作成
            RequestEntity<Void> request = RequestEntity.get(uri).header("SSECCAYEK", "NTSS-NKK-ESM-TDC-YSK").build();
            // リクエスト処理
            RestTemplate restTemplate = new RestTemplate();
// #9698 アプリケーションログの内容修正 20260328 mod yangxuewang start
            long start = System.currentTimeMillis();
            ResponseEntity<Object> response = restTemplate.exchange(request, Object.class);
            HttpStatus status = response.getStatusCode();
            long cost = System.currentTimeMillis() - start;
            Map<String, Object> map = new HashMap<>();
            map.put("logType", "RESTTEMPLATE-LOG");
            map.put("className", "jp.co.nikkiso.ntss.admin_web.service.filterLog.FilterLogServiceImpl");
            map.put("methodName", "loggerSetFlgUpdate");
            map.put("method", request.getMethod());
            map.put("url", uri.getPath());
            map.put("headers", request.getHeaders());
            map.put("requestParameter", request.getBody());
            map.put("status",response.getStatusCode());
            map.put("cost", cost);
            map.put("result",response.getBody());
            EventLogMessage restTemplateEventLogMessage = new EventLogMessage();
            restTemplateEventLogMessage.setLogMessage(toJson(map));
            logService.log(LogLevel.INFO, restTemplateEventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
// #9698 アプリケーションログの内容修正 20260328 mod yangxuewang end
            if (HttpStatus.OK != status) {
              // 処理エラーリストに追加
              errList.put(ipAddr2 + "/" + mdName);
            }
          } catch (Exception ex) {
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//            ex.printStackTrace();
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage(ExcetionStackTraceToString(ex));
            logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
            // 処理エラーリストに追加
            errList.put(ipAddr2 + "/" + mdName);
          }
        }
      }
      // 処理エラーリストを応答に含める
      resultObj.put("errorList", errList.toString());
    } else {
      // 対応を行うサーバーが存在しない為、処理を終了
      resultObj.put("readSetting", false);
      resultObj.put("errorList", errList.toString());
    }
    return resultObj.toString();
  };

  /**
   * 日付変換
   * @param strDate 日付文字列
   * @param type 0:開始日付 1:終了日付
   * @return
   */
  private String getStrDate(String strDate, int type) {
    if (StringUtils.isEmpty(strDate)) {
      return "";
    }
    String tmpDate = strDate;
    tmpDate = tmpDate.replaceAll("/","");
    tmpDate = tmpDate.replaceAll(":","");
    tmpDate = tmpDate.replaceAll(" ","");
    tmpDate = tmpDate.substring(0, 12);
    if (type == 0) {
      tmpDate = tmpDate + "00000";
    } else {
      tmpDate = tmpDate + "99999";
    }

    return tmpDate;
  }

  /**
   * ログリスト取得する
   * @param resultList 検索した結果
   * @param typeSearch 検索タイプ
   * @param key キーワード検索
   * @return ログリスト
   */
  private List<MongoLogAPI> getSearchList(List<MongoLogAPI> resultList, int typeSearch, String key) {
    if (StringUtils.isEmpty(key)) {
      return resultList;
    }
    List<MongoLogAPI> list = new ArrayList<MongoLogAPI>();
    for (MongoLogAPI api : resultList) {
      switch (typeSearch) {
        // 等しい
        case 0:
          typeSearch_0(list, api, key);
          break;
        // 等しくない
        case 1:
          typeSearch_1(list, api, key);
          break;
        // 始まる
        case 2:
          typeSearch_2(list, api, key);
          break;
          // 終わる
        case 3:
          typeSearch_3(list, api, key);
          break;
          // 含む
        case 4:
          typeSearch_4(list, api, key);
          break;
          // 含まない
        case 5:
          typeSearch_5(list, api, key);
          break;
      }
    }

    return list;
  }

  /**
   * 等しい
   * @param list 検索した結果
   * @param api データ
   * @param key キーワード検索
   */
  private void typeSearch_0(List<MongoLogAPI> list, MongoLogAPI api, String key) {
    if (convertString(api.getLog_type()).equals(key)
    || convertString(api.getFacility_cd()).equals(key)
    || convertString(api.getUser_id()).equals(key)
    || convertString(api.getClient_ip()).equals(key)
    || convertString(api.getSession_id()).equals(key)
    || convertString(api.getDe_no()).equals(key)
    || convertString(api.getDe_serial()).equals(key)
    || convertString(api.getMcn_type()).equals(key)
    || convertString(api.getMcn_type_cd()).equals(key)
    || convertString(api.getEc2_ip()).equals(key)
    || convertString(api.getSvc_name()).equals(key)
    || convertString(api.getFunc_cd()).equals(key)
    || convertString(api.getPat_id()).equals(key)
    || convertString(api.getMessage()).equals(key)
    || convertString(api.getInvoke_class()).equals(key)
    || convertString(api.getTodo()).equals(key)
    || convertString(api.getFacility_name()).equals(key)
    || convertString(api.getPat_name()).equals(key)
    || convertString(api.getUser_name()).equals(key)
    || convertString(api.getFunction_name()).equals(key)
      // add 問題解決ログが正常にソートされませんた 周炜博 start
      || convertString(api.getHosp_pat_id()).equals(key)
      || convertString(api.getLog_type()).equals(key)
      // add 問題解決ログが正常にソートされませんた 周炜博 end
    ) {
      list.add(api);
    }
  }

  /**
   * 等しくない
   * @param list 検索した結果
   * @param api データ
   * @param key キーワード検索
   */
  private void typeSearch_1(List<MongoLogAPI> list, MongoLogAPI api, String key) {
    if (convertString(api.getLog_type()).equals(key)
      || convertString(api.getFacility_cd()).equals(key)
      || convertString(api.getUser_id()).equals(key)
      || convertString(api.getClient_ip()).equals(key)
      || convertString(api.getSession_id()).equals(key)
      || convertString(api.getDe_no()).equals(key)
      || convertString(api.getDe_serial()).equals(key)
      || convertString(api.getMcn_type()).equals(key)
      || convertString(api.getMcn_type_cd()).equals(key)
      || convertString(api.getEc2_ip()).equals(key)
      || convertString(api.getSvc_name()).equals(key)
      || convertString(api.getFunc_cd()).equals(key)
      || convertString(api.getPat_id()).equals(key)
      || convertString(api.getMessage()).equals(key)
      || convertString(api.getInvoke_class()).equals(key)
      || convertString(api.getTodo()).equals(key)
      || convertString(api.getPat_name()).equals(key)
      || convertString(api.getUser_name()).equals(key)
      || convertString(api.getFacility_name()).equals(key)
      || convertString(api.getFunction_name()).equals(key)
      // add 問題解決ログが正常にソートされませんた 周炜博 start
      || convertString(api.getHosp_pat_id()).equals(key)
      || convertString(api.getLog_type()).equals(key)
      // add 問題解決ログが正常にソートされませんた 周炜博 end
    ) {

    } else {
      list.add(api);
    }
  }

  /**
   * 始まる
   * @param list 検索した結果
   * @param api データ
   * @param key キーワード検索
   */
  private void typeSearch_2(List<MongoLogAPI> list, MongoLogAPI api, String key) {
    if (convertString(api.getLog_type()).indexOf(key) == 0
      || convertString(api.getFacility_cd()).indexOf(key) == 0
      || convertString(api.getUser_id()).indexOf(key) == 0
      || convertString(api.getClient_ip()).indexOf(key) == 0
      || convertString(api.getSession_id()).indexOf(key) == 0
      || convertString(api.getDe_no()).indexOf(key) == 0
      || convertString(api.getDe_serial()).indexOf(key) == 0
      || convertString(api.getMcn_type()).indexOf(key) == 0
      || convertString(api.getMcn_type_cd()).indexOf(key) == 0
      || convertString(api.getEc2_ip()).indexOf(key) == 0
      || convertString(api.getSvc_name()).indexOf(key) == 0
      || convertString(api.getFunc_cd()).indexOf(key) == 0
      || convertString(api.getPat_id()).indexOf(key) == 0
      || convertString(api.getMessage()).indexOf(key) == 0
      || convertString(api.getInvoke_class()).indexOf(key) == 0
      || convertString(api.getTodo()).indexOf(key) == 0
      || convertString(api.getUser_name()).indexOf(key) == 0
      || convertString(api.getFacility_name()).indexOf(key) == 0
      || convertString(api.getPat_name()).indexOf(key) == 0
      || convertString(api.getFunction_name()).indexOf(key) == 0
      // add 問題解決ログが正常にソートされませんた 周炜博 start
      || convertString(api.getHosp_pat_id()).indexOf(key)==0
      || convertString(api.getLog_type()).indexOf(key)==0
    // add 問題解決ログが正常にソートされませんた 周炜博 end
    ) {
      list.add(api);
    }
  }

  /**
   * 終わる
   * @param list 検索した結果
   * @param api データ
   * @param key キーワード検索
   */
  private void typeSearch_3(List<MongoLogAPI> list, MongoLogAPI api, String key) {
    if (checkLastValue(convertString(api.getLog_type()), key)
      || checkLastValue(convertString(api.getFacility_cd()), key)
      || checkLastValue(convertString(api.getUser_id()), key)
      || checkLastValue(convertString(api.getClient_ip()), key)
      || checkLastValue(convertString(api.getSession_id()), key)
      || checkLastValue(convertString(api.getDe_no()), key)
      || checkLastValue(convertString(api.getDe_serial()), key)
      || checkLastValue(convertString(api.getMcn_type()), key)
      || checkLastValue(convertString(api.getMcn_type_cd()),key)
      || checkLastValue(convertString(api.getEc2_ip()), key)
      || checkLastValue(convertString(api.getSvc_name()), key)
      || checkLastValue(convertString(api.getFunc_cd()), key)
      || checkLastValue(convertString(api.getPat_id()), key)
      || checkLastValue(convertString(api.getMessage()), key)
      || checkLastValue(convertString(api.getInvoke_class()), key)
      || checkLastValue(convertString(api.getTodo()), key)
      || checkLastValue(convertString(api.getFacility_name()), key)
      || checkLastValue(convertString(api.getPat_name()), key)
      || checkLastValue(convertString(api.getUser_name()), key)
      || checkLastValue(convertString(api.getFunction_name()), key)
      // add 問題解決ログが正常にソートされませんた 周炜博 start
      || checkLastValue(convertString(api.getHosp_pat_id()),key)
      || checkLastValue(convertString(api.getLog_type()),key)
      // add 問題解決ログが正常にソートされませんた 周炜博 end
    ) {
      list.add(api);
    }
  }

  /**
   * 含む
   * @param list 検索した結果
   * @param api データ
   * @param key キーワード検索
   */
  private void typeSearch_4(List<MongoLogAPI> list, MongoLogAPI api, String key) {
    if (convertString(api.getLog_type()).toUpperCase().contains(key.toUpperCase())
      || convertString(api.getFacility_cd()).toUpperCase().contains(key.toUpperCase())
      || convertString(api.getUser_id()).toUpperCase().contains(key.toUpperCase())
      || convertString(api.getClient_ip()).toUpperCase().contains(key.toUpperCase())
      || convertString(api.getSession_id()).toUpperCase().contains(key.toUpperCase())
      || convertString(api.getDe_no()).toUpperCase().contains(key.toUpperCase())
      || convertString(api.getDe_serial()).toUpperCase().contains(key.toUpperCase())
      || convertString(api.getMcn_type()).toUpperCase().contains(key.toUpperCase())
      || convertString(api.getMcn_type_cd()).toUpperCase().contains(key.toUpperCase())
      || convertString(api.getEc2_ip()).toUpperCase().contains(key.toUpperCase())
      || convertString(api.getSvc_name()).toUpperCase().contains(key.toUpperCase())
      || convertString(api.getFunc_cd()).toUpperCase().contains(key.toUpperCase())
      || convertString(api.getPat_id()).toUpperCase().contains(key.toUpperCase())
      || convertString(api.getMessage()).toUpperCase().contains(key.toUpperCase())
      || convertString(api.getInvoke_class()).toUpperCase().contains(key.toUpperCase())
      || convertString(api.getTodo()).toUpperCase().contains(key.toUpperCase())
      || convertString(api.getUser_name()).toUpperCase().contains(key.toUpperCase())
      || convertString(api.getPat_name()).toUpperCase().contains(key.toUpperCase())
      || convertString(api.getFacility_name()).toUpperCase().contains(key.toUpperCase())
      || convertString(api.getFunction_name()).toUpperCase().contains(key.toUpperCase())
      // add 問題解決ログが正常にソートされませんた 周炜博 start
      || convertString(api.getHosp_pat_id()).toUpperCase().contains(key.toUpperCase())
      || convertString(api.getLog_type()).toUpperCase().contains(key.toUpperCase())
      // add 問題解決ログが正常にソートされませんた 周炜博 end
    ) {
      list.add(api);
    }
  }

  /**
   * 含まない
   * @param list 検索した結果
   * @param api データ
   * @param key キーワード検索
   */
  private void typeSearch_5(List<MongoLogAPI> list, MongoLogAPI api, String key) {
    if (convertString(api.getLog_type()).toUpperCase().contains(key.toUpperCase())
      || convertString(api.getFacility_cd()).toUpperCase().contains(key.toUpperCase())
      || convertString(api.getUser_id()).toUpperCase().contains(key.toUpperCase())
      || convertString(api.getClient_ip()).toUpperCase().contains(key.toUpperCase())
      || convertString(api.getSession_id()).toUpperCase().contains(key.toUpperCase())
      || convertString(api.getDe_no()).toUpperCase().contains(key.toUpperCase())
      || convertString(api.getDe_serial()).toUpperCase().contains(key.toUpperCase())
      || convertString(api.getMcn_type()).toUpperCase().contains(key.toUpperCase())
      || convertString(api.getMcn_type_cd()).toUpperCase().contains(key.toUpperCase())
      || convertString(api.getEc2_ip()).toUpperCase().contains(key.toUpperCase())
      || convertString(api.getSvc_name()).toUpperCase().contains(key.toUpperCase())
      || convertString(api.getFunc_cd()).toUpperCase().contains(key.toUpperCase())
      || convertString(api.getPat_id()).toUpperCase().contains(key.toUpperCase())
      || convertString(api.getMessage()).toUpperCase().contains(key.toUpperCase())
      || convertString(api.getInvoke_class()).toUpperCase().contains(key.toUpperCase())
      || convertString(api.getTodo()).toUpperCase().contains(key.toUpperCase())
      || convertString(api.getPat_name()).toUpperCase().contains(key.toUpperCase())
      || convertString(api.getFacility_name()).toUpperCase().contains(key.toUpperCase())
      || convertString(api.getUser_name()).toUpperCase().contains(key.toUpperCase())
      || convertString(api.getFunction_name()).toUpperCase().contains(key.toUpperCase())
      // add 問題解決ログが正常にソートされませんた 周炜博 start
      || convertString(api.getHosp_pat_id()).toUpperCase().contains(key.toUpperCase())
      || convertString(api.getLog_type()).toUpperCase().contains(key.toUpperCase())
      // add 問題解決ログが正常にソートされませんた 周炜博 end
    ) {

    } else {
      list.add(api);
    }
  }

  /**
   * MongoDB検索条件作成
   * @param conditionlist 条件リスト
   * @param key コラム
   * @param value データ
   * @param operator 条件演算子
   */
  private void getFilterContition(ArrayList<DBObject> conditionlist, String key, Object value, String operator) {
    if (value != null) {
      DBObject logConditionList = new BasicDBObject();
      if (value instanceof String) {
        String strValue = (String)value;
        if (StringUtils.isEmpty(strValue)) {
          return;
        }
        if (strValue.indexOf(",") >= 0) {
          String[] strArray = ((String) value).split(",");
          List list = Arrays.asList(strArray);
          logConditionList.put(key, new BasicDBObject("$in", list));
        } else {
          logConditionList.put(key, new BasicDBObject(operator, value));
        }
      } else if (value instanceof List) {
        if (((List)value).size() == 0) {
          return;
        }
        logConditionList.put(key, new BasicDBObject(operator, value));
      }
      conditionlist.add(logConditionList);
    }
  }

  /**
   * 最後の文字を確認する
   *
   * @param Name
   * @param keyFInd
   * @return
   */
  private boolean checkLastValue(String Name, String keyFInd) {
    int lengthName = Name.length();
    int lengthkeyFInd = keyFInd.length();
    if (lengthName > lengthkeyFInd) {
      String Namecompare = Name.substring(lengthName - lengthkeyFInd, lengthName);
      if (Namecompare.equals(keyFInd)) {
        return true;
      }
      return false;
    }
    if (lengthName == lengthkeyFInd) {
      if (Name.equals(keyFInd)) {
        return true;
      }
      return false;
    }
    return false;
  }

  /**
   * String変換
   * @param obj 変換用オブジェクト
   * @return 変換したデータ
   */
  public static String convertString(Object obj) {
    if (obj == null) {
      return "";
    }

    return obj.toString();
  }

	public boolean isNumeric(String strNum) {
		try {
			Long d = Long.valueOf(strNum);
		} catch (NumberFormatException e) {
			return false;
		}
		return true;
	}

	/**
	 * 検索条件を保存する
	 */
	@Override
	public void saveSearchCondition(long userId, String conditions) {

    // DB更新ログ出力ロジック wangzuo Start
    String tableName = "mst_user";
    // SQL検索条件
    StringBuffer wheres = new StringBuffer("");
    wheres.append(" WHERE\n");
    wheres.append(" user_id = " + userId + "\n");
    // logCommon設定
    DataUpdateLogCommonNew logCommon = getLogCommon(mstUserDao, tableName, wheres, getEventLogMessage());
    // ログ出力カラム情報及び更新前データ情報取得
    boolean setResult = logCommon.setInfo();
    // DB更新ログ出力ロジック wangzuo End

    int updateCount = mstUserDao.saveSearchCondition(userId, conditions);

    // DB更新ログ出力ロジック wangzuo Start
    // 更新後データ取得、差分あれば、log出力
    if (setResult && updateCount > 0) {
      logCommon.updateLog();
    }
    // DB更新ログ出力ロジック wangzuo End

	}

	/**
	 * ログファイルを読む
	 */
	@Override
	public List<EventLogAPI> ReadLog(String folderName, String fileName) {
		ReadLogAPI readlog = new ReadLogAPI();
		try {
			List<EventLogAPI> listLog = readlog.ReadLog(folderName, fileName);
			if (listLog.size() > 0) {
				return listLog;
			}
		} catch (ParseException e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
		}
		return null;
	}

	/**
	 * 検索条件
	 *
	 * @param userId
	 * @return SearchCondition
	 */
	@Override
	public String searchCondition(long userId) {
		MstUser user = mstUserDao.selectById(userId);
		String tmpLog = user.getTmpLogSearchCondition();
		return tmpLog;
	}

	/**
	 * パス出力を取得する
	 *
	 * @param typeLog
	 * @return String
	 */
	private String getPathOutput(int typeLog) {
		SysSystemDefine systemDefine = sysSystemDefineDao.selectOnPremise(typeLog);
		ObjectMapper objectMapper = new ObjectMapper();
		try {
			Map<String, String> infoLogger = objectMapper.readValue(systemDefine.getValue(), new TypeReference<Map<String, String>>() {});
			return infoLogger.get("path_output");
		} catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang ende.printStackTrace();
		}
		return null;
	}

	public FileInfoModelLog getFileSysLog(String path, String filter) {
		Boolean isRoot = false;
		String pathOutput;
		try {
			SysSystemDefine systemDefine = sysSystemDefineDao.selectByCtlNoAndServiceCd(1000, "003");
			ObjectMapper objectMapper = new ObjectMapper();
			HashMap<String, String> setting = objectMapper.readValue(systemDefine.getValue(), new TypeReference<HashMap<String, String>>(){});
			pathOutput = setting.get("path_output") + "/";
			String findPath = path;
			if (path == null || path == "" || path.trim() == "") {
				findPath = pathOutput;
				isRoot = true;
			} else {
				findPath = pathOutput + path;
			}
			File folder = new File(findPath);
			if (folder.isFile()) {
				return null;
			}
			File[] fileList = folder.listFiles();
			if (filter != null) {
				fileList = Arrays.stream(fileList).filter(x -> x.getName().contains(filter)).toArray(File[]::new);
			}
			if (fileList == null) {
				return null;
			}
			List<FileInfoLog> lst = new ArrayList<>();
			for (final File file: fileList) {
				if (file.isDirectory()
          || (!file.isDirectory() && file.getName().toLowerCase().endsWith(".log"))
          || (!file.isDirectory() && file.getName().toLowerCase().endsWith(".gz"))
          || (!file.isDirectory() && file.getName().toLowerCase().endsWith(".zip"))
        ) {
					Path pathF = Paths.get(file.getPath());
					FileInfoLog item = new FileInfoLog(
											file.isDirectory(),
											file.isHidden(),
											file.getName(),
											file.getUsableSpace(),
											FileTimeToDate(pathF)
										);
					lst.add(item);
				}
			}
			FileInfoModelLog res = new FileInfoModelLog();
			res.setLstFile(lst);
			res.setCurrentPath(isRoot ? "/" : path);
			res.setRoot("/");
			return res;
		} catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
		}
		return null;
	}

	public FileInfoModelLog getFileSysLog(String path) {
		Boolean isRoot = false;
		String pathOutput;
		try {
			SysSystemDefine systemDefine = sysSystemDefineDao.selectByCtlNoAndServiceCd(1000, "003");
			ObjectMapper objectMapper = new ObjectMapper();
			HashMap<String, String> setting = objectMapper.readValue(systemDefine.getValue(), new TypeReference<HashMap<String, String>>(){});
			String findPath = path;
			pathOutput = setting.get("path_output") + "/";
			if (path == null || path == "" || path.trim() == "") {
				findPath = pathOutput;
				isRoot = true;
			} else {
				findPath = pathOutput + path;
			}
			File folder = new File(findPath);
			if (folder.isFile()) {
				return null;
			}
			File[] fileList = folder.listFiles();
			if (fileList == null) {
				return null;
			}

			List<FileInfoLog> lst = new ArrayList<>();
			for (final File file: fileList) {
				if (file.isDirectory() || (!file.isDirectory() && file.getName().endsWith(".log"))) {
					Path pathF = Paths.get(file.getPath());
					FileInfoLog item = new FileInfoLog(
											file.isDirectory(),
											file.isHidden(),
											file.getName(),
											file.getUsableSpace(),
											FileTimeToDate(pathF)
										);
					lst.add(item);
				}
			}
			FileInfoModelLog res = new FileInfoModelLog();
			res.setLstFile(lst);
			res.setCurrentPath(isRoot ? "\\" : path);
			res.setRoot("\\");
			return res;
		} catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
		}
		return null;
	}

	private Date FileTimeToDate(Path pathF) {
		try {
			if (pathF == null) return null;
			BasicFileAttributes attr = Files.readAttributes(pathF, BasicFileAttributes.class);
			DateFormat df = new SimpleDateFormat("yyyy/MM/dd");
			Date d = df.parse(df.format(attr.creationTime().toMillis()));
			return d;
		} catch (IOException e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
		} catch (ParseException pe) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      pe.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(pe));
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
		}
		return null;
	}

  /**
   * ファイルダウンロードメイン処理
   */
	public File downloadFileLog(String path) throws Exception {
      SysSystemDefine systemDefine = sysSystemDefineDao.selectByCtlNoAndServiceCd(1000, "003");
      ObjectMapper objectMapper = new ObjectMapper();
      HashMap<String, String> setting = objectMapper.readValue(systemDefine.getValue(), new TypeReference<HashMap<String, String>>(){});
      String pathOutput = setting.get("path_output");
      if (path == null || path == "" || path.trim() == "") {
        path = pathOutput;
      } else {
        path = pathOutput + path;
      }

      File file = new File(path);

      if (file.exists()) {
        // Zipファイルを作成する
        String pathTempZip = setting.get("path_temp_zip");
        File zipFile = new File(pathTempZip + generateRandomFileName("zip"));
        if(!zipFile.getParentFile().exists()) {
          zipFile.getParentFile().mkdirs();
        }
        zipFile.createNewFile();

        // Zipファイルに各ファイルを圧縮する
        try (FileOutputStream fileOutputStream = new FileOutputStream(zipFile);
          ZipOutputStream zipOutputStream = new ZipOutputStream(fileOutputStream)) {
          zipFiles(file, zipOutputStream, "");
        }

        return zipFile;
      }

      return null;
	}

  /**
   * ファイルを圧縮する
   */
  private void zipFiles(File directory, ZipOutputStream zipOutputStream, String parentPath) throws IOException {
    Stack<Pair<File, String>> stack = new Stack<>();
    stack.push(Pair.of(directory, parentPath));

    while (!stack.isEmpty()) {
      Pair<File, String> currentItem = stack.pop();
      String currentPath = currentItem.getRight();
      File currentFile = currentItem.getLeft();
      String entryName = currentPath + currentFile.getName();

      if (currentFile.isDirectory()) {
          zipOutputStream.putNextEntry(new ZipEntry(entryName + "/"));

          File[] files = currentFile.listFiles();
          if (files != null) {
              for (File file : files) {
                  stack.push(Pair.of(file, entryName + "/"));
              }
          }
      } else {
          zipOutputStream.putNextEntry(new ZipEntry(entryName));
          try (FileInputStream fileInputStream = new FileInputStream(currentFile)) {

              byte[] buffer = new byte[4096];
              int bytesRead;
              while ((bytesRead = fileInputStream.read(buffer)) > 0) {
                zipOutputStream.write(buffer, 0, bytesRead);
              }
          }
          zipOutputStream.closeEntry();
      }
    }
  }

  /**
   * ファイル名を作成する
   */
  public static String generateRandomFileName(String fileExtension) {
    String uuid = UUID.randomUUID().toString();
    String fileName = uuid.replace("-", "");
    fileName += "." + fileExtension;

    return fileName;
  }

  // DB更新ログ出力ロジック wangzuo Start
  /**
   * ログ情報設定
   * @return eventLogMessage
   */
  private EventLogMessage getEventLogMessage() {
    EventLogMessage eventLogMessage = new EventLogMessage();
    NtssUser user = (NtssUser) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
    if (user != null) {
      // 利用者ID
      eventLogMessage.setUserId(user.getUserId().toString());
      // 施設コード
      eventLogMessage.setFacilityCd(user.getFacilityCd());
      // 接続先IPアドレス
      eventLogMessage.setClientIp(user.getClientIpAddress());
      // セッションID
      eventLogMessage.setSessionId(user.getSessionId());
    }
    // サービス名
    eventLogMessage.setServiceName(LoggingConstant.MODULE_NAME.ADMIN_WEB + "," + LoggingConstant.SERVICE_NAME.FNSI);
    return   eventLogMessage;
  }

  /**
   * ログ出力共通クラス設定、取得
   * @return logCommon ログ出力共通クラス
   */
  private DataUpdateLogCommonNew getLogCommon(Object dao, String tableName, StringBuffer whereStr, EventLogMessage eventLogMessage) {
    DataUpdateLogCommonNew logCommon = new DataUpdateLogCommonNew();
    logCommon.setEventLoggerFactory(eventLoggerFactory);
    logCommon.setLogServiceCore(logServiceCore);
    logCommon.setConfig(Config.get(dao));
    logCommon.setTableName(tableName);
    logCommon.setWhereStr(whereStr);
    logCommon.setCommonEventLogMessage(eventLogMessage);
    return logCommon;
  }
  // DB更新ログ出力ロジック wangzuo End

  private void getKeyWordSearchCondition(ArrayList<DBObject> list, String keyType, String keyword){
    String [] columns = {"log_type","message","facility_cd","user_id","client_ip","session_id","de_no","de_serial",
      "mcn_type","mcn_type_cd","ec2_ip","svc_name","func_cd",
      "pat_id","message","invoke_class","todo","serviceName",
      "pat_name","user_name","facility_name","function_name","hosp_pat_id"};
    BasicDBObject dbObj = new BasicDBObject();
    BasicDBList condList = new BasicDBList();
    if(!"0".equals(keyType) && !"1".equals(keyType) ){ //等しいや等しくない以外の場合
      Pattern pattern=null;
      String option="$or";
      switch (keyType) {
        // 始まる
        case "2":
          pattern = Pattern.compile("^"+keyword+".*$",Pattern.CASE_INSENSITIVE);
          break;
        // 終わる
        case "3":
          pattern = Pattern.compile("^.*"+keyword+"$",Pattern.CASE_INSENSITIVE);
          break;
        // 含む
        case "4":
          pattern = Pattern.compile("^.*"+keyword+".*$",Pattern.CASE_INSENSITIVE);
          break;
        // 含まない
        case "5":
          pattern = Pattern.compile("^((?!"+keyword+").)*$",Pattern.CASE_INSENSITIVE);
          option = "$and";
          break;
      }
      for(int i = 0;i<columns.length;i++){
        BasicDBObject condObj= new BasicDBObject();
        condObj.put(columns[i],pattern);
        condList.add(condObj);
      }
      dbObj.put(option, condList);
      list.add(dbObj);
    }else{
      String operator="";
      String option="$or";
      switch (keyType) {
        // 等しい
        case "0":
          operator = "$eq";
          break;
        // 等しくない
        case "1":
          operator = "$ne";
          option = "$and";
          break;
      }
      for(int i = 0;i<columns.length;i++){
        DBObject condObj = new BasicDBObject();
        condObj.put(columns[i], new BasicDBObject(operator, keyword));
        condList.add(condObj);
      }
      dbObj.put(option, condList);
      list.add(dbObj);
    }
  }
  // add #6775 ログの抽出が正しく行われない 鄭爽 start
  // mod 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zhou start
  //private void getKeySearchAndCondition(ArrayList<DBObject> list, String keyType, String keyword, List<Map<String, Object>> displayItems){
  private void getKeySearchAndCondition(ArrayList<DBObject> list, String keyType, String keyword, List<Map<String, Object>> displayItems,List<String> facilityCdList){
  // mod 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zhou end
    // 等しくない
    if ("1".equals(keyType)) {
      getKeySearchList(list, keyword, "$ne", displayItems);
      //add 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zhou start
      getKeySearchPatternListForDate(list, Pattern.compile("^((?!" + escapeExprSpecialWord(keyword) + ").)*$", Pattern.CASE_INSENSITIVE));
      getKeySearchPatternEncryptList(list, keyword,"$in", displayItems,facilityCdList, false );
      // add 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zhou end
      // 含まない
    } else if ("5".equals(keyType)) {
      // mod 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zhou start
      //Pattern pattern = Pattern.compile("^((?!" + keyword + ").)*$", Pattern.CASE_INSENSITIVE);
      Pattern pattern = Pattern.compile("^((?!" + escapeExprSpecialWord(keyword) + ").)*$", Pattern.CASE_INSENSITIVE);
      // mod 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zhou end
      getKeySearchPatternList(list, pattern, displayItems);
      // add 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zhou start
      getKeySearchPatternListForDate(list, Pattern.compile("^((?!" + escapeExprSpecialWord(keyword) + ").)*$", Pattern.CASE_INSENSITIVE));
      getKeySearchPatternEncryptList(list, '%'+ keyword +'%',"$in", displayItems,facilityCdList,false);
      // add 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zhou end
      // del 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zhou start
      //for (int i = 0; i < 2; i++) {
        //String keySearch = NtssUtils.EncryptKeySearch(keyword, String.valueOf(i));
        //Pattern patternEncrypt = Pattern.compile("^((?!" + keySearch + ").)*$", Pattern.CASE_INSENSITIVE);
        //getKeySearchPatternEncryptList(list, patternEncrypt, displayItems);
      //}
      // del 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zhou end
    }
  }

  private void getKeySearchOrCondition(ArrayList<DBObject> keyList, String keyType, String keyword, List<Map<String, Object>> displayItems,List<String> facilityCdList){
    // 等しい
    if ("0".equals(keyType)) {
      getKeySearchList(keyList, keyword, "$eq", displayItems);
      //add 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zhou start
      getKeySearchPatternListForDate(keyList, Pattern.compile("^" + escapeExprSpecialWord(keyword) + ".*$", Pattern.CASE_INSENSITIVE));
      getKeySearchPatternEncryptList(keyList, keyword,"$in", displayItems,facilityCdList, true );
      // add 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zhou end
      // 始まる
    } else if ("2".equals(keyType)) {
      // mod 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zhou start
      //Pattern pattern = Pattern.compile("^" + keyword + ".*$", Pattern.CASE_INSENSITIVE);
      Pattern pattern = Pattern.compile("^" + escapeExprSpecialWord(keyword) + ".*$", Pattern.CASE_INSENSITIVE);
      // mod 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zhou end
      getKeySearchPatternList(keyList, pattern, displayItems);
      // add 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zhou start
      getKeySearchPatternListForDate(keyList, Pattern.compile("^" + escapeExprSpecialWord(keyword) + ".*$", Pattern.CASE_INSENSITIVE));
      getKeySearchPatternEncryptList(keyList, keyword + '%',"$in", displayItems,facilityCdList, true );
      // add 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zhou end
      // del 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zhou start
      //for (int i = 0; i < 2; i++) {
        //String keySearch = NtssUtils.EncryptKeySearch(keyword, String.valueOf(i));
        //Pattern patternEncrypt = Pattern.compile("^" + keySearch + ".*$", Pattern.CASE_INSENSITIVE);
        //getKeySearchPatternEncryptList(keyList, patternEncrypt, displayItems);
      //}
      // del 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zhou end
      // 終わる
    } else if ("3".equals(keyType)) {
      // mod 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zhou start
      //Pattern pattern = Pattern.compile("^.*" + keyword + "$", Pattern.CASE_INSENSITIVE);
      Pattern pattern = Pattern.compile("^.*" + escapeExprSpecialWord(keyword) + "$", Pattern.CASE_INSENSITIVE);
      // mod 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zhou end
      getKeySearchPatternList(keyList, pattern,displayItems);
      // add 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zhou start
      getKeySearchPatternListForDate(keyList, Pattern.compile("^" + escapeExprSpecialWord(keyword) + ".*$", Pattern.CASE_INSENSITIVE));
      getKeySearchPatternEncryptList(keyList, '%'+ keyword  ,"$in", displayItems,facilityCdList, true );
      // add 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zhou end
      // del 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zhou start
      //for (int i = 0; i < 2; i++) {
        //String keySearch = NtssUtils.EncryptKeySearch(keyword, String.valueOf(i));
        //Pattern patternEncrypt = Pattern.compile("^.*" + keySearch + "$", Pattern.CASE_INSENSITIVE);
        //getKeySearchPatternEncryptList(keyList, patternEncrypt, displayItems);
      //}
      // del 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zhou end
      // 含む
    } else if ("4".equals(keyType)) {
      // mod 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zhou start
      //Pattern pattern = Pattern.compile("^.*" + keyword +".*$", Pattern.CASE_INSENSITIVE);
      Pattern pattern = Pattern.compile("^.*" + escapeExprSpecialWord(keyword) +".*$", Pattern.CASE_INSENSITIVE);
      // mod 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zhou end
      getKeySearchPatternList(keyList, pattern,displayItems);
      // add 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zhou start
      getKeySearchPatternListForDate(keyList, Pattern.compile("^" + escapeExprSpecialWord(keyword) + ".*$", Pattern.CASE_INSENSITIVE));
      getKeySearchPatternEncryptList(keyList, '%'+ keyword +'%',"$in", displayItems,facilityCdList, true );
      // add 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zhou end
      // del 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zhou start
      //for (int i = 0; i < 2; i++) {
        //String keySearch = NtssUtils.EncryptKeySearch(keyword, String.valueOf(i));
        //Pattern patternEncrypt = Pattern.compile("^.*" + keySearch + ".*$", Pattern.CASE_INSENSITIVE);
        //getKeySearchPatternEncryptList(keyList, patternEncrypt, displayItems);
      //}
      // del 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zhou end
    }
  }

  /**
   * MongoDB検索条件作成
   * @param conditionList 条件リスト
   * @param keySearch コラム
   * @param operator 条件演算子
   */
  private void getKeySearchList(ArrayList<DBObject> conditionList, String keySearch, String operator, List<Map<String, Object>> displayItems) {
    for (int i = 0; i < displayItems.size(); i++) {
      String keyItem = displayItems.get(i).get("key").toString();
      switch (keyItem) {
        case "clientIp":
          getFilterContition(conditionList, "client_ip", keySearch, operator);
          break;
        case "functionName":
          getFilterContition(conditionList, "function_name", keySearch, operator);
          break;
        // del 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zhou start
        //case "user":
          //getFilterContition(conditionList, "user_name", keySearch, operator);
          //getFilterContition(conditionList, "user_name", NtssUtils.Encrypt(keySearch), operator);
          //break;;
        // del 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zhou end
        case "hospPatId":
          getFilterContition(conditionList, "hosp_pat_id", keySearch, operator);
          break;
        // del 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zhou start
        //case "patName":
          //getFilterContition(conditionList, "pat_name", keySearch, operator);
          //getFilterContition(conditionList, "pat_name", NtssUtils.Encrypt(keySearch), operator);
          //break;
        // del 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zhou end
        case "logMessage":
          getFilterContition(conditionList, "message", keySearch, operator);
          // del 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zhou start
         //getFilterContition(conditionList, "message", NtssUtils.Encrypt(keySearch), operator);
          // del 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zhou end
          break;
        case "supportMessage":
          getFilterContition(conditionList, "todo", keySearch, operator);
          break;
        case "sessionId":
          getFilterContition(conditionList, "session_id", keySearch, operator);
          break;
        case "patId":
          getFilterContition(conditionList, "pat_id", keySearch, operator);
          break;
        case "logType":
          getFilterContition(conditionList, "log_type", keySearch, operator);
          break;
        // del 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zhou start
        //case "facilityName":
          //getFilterContition(conditionList, "facility_name", keySearch, operator);
          //getFilterContition(conditionList, "facility_name", NtssUtils.Encrypt(keySearch), operator);
          //break;
        // del 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zhou end
        // mod 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zkm start
        //case "username":
        case "userId":
        // mod 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zkm end
          getFilterContition(conditionList, "user_id", keySearch, operator);
          break;
        case "deviceEdgeNo":
          getFilterContition(conditionList, "de_no", keySearch, operator);
          break;
        case "deviceEdgeSerialNo":
          getFilterContition(conditionList, "de_serial", keySearch, operator);
          break;
        case "machineType":
          getFilterContition(conditionList, "mcn_type", keySearch, operator);
          break;
        case "machineTypeCd":
          getFilterContition(conditionList, "mcn_type_cd", keySearch, operator);
          break;
        case "ec2Identification":
          getFilterContition(conditionList, "ec2_ip", keySearch, operator);
          break;
        // add 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zhou start
        case "serviceName":
          getFilterContition(conditionList, "svc_name",  keySearch, operator);
          break;
        // add 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zhou end
      }
    }
    // del 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zhou start
//    getFilterContition(conditionList, "facility_cd", keySearch, operator);
//    getFilterContition(conditionList, "svc_name", keySearch, operator);
//    getFilterContition(conditionList, "func_cd", keySearch, operator);
//    getFilterContition(conditionList, "invoke_class", keySearch, operator);
    // del 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zhou end
  }
  /**
   * MongoDB検索条件作成
   * @param conditionList 条件リスト
   * @param pattern データ
   */
  private void getKeySearchPatternList(ArrayList<DBObject> conditionList, Pattern pattern, List<Map<String, Object>> displayItems) {
    for (int i = 0; i < displayItems.size(); i++) {
      String keyItem = displayItems.get(i).get("key").toString();
      switch (keyItem) {
        case "clientIp":
          getFilterContitionKey(conditionList, "client_ip", pattern);
          break;
        case "functionName":
          getFilterContitionKey(conditionList, "function_name", pattern);
          break;
        // del 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zhou start
//        case "user":
//          getFilterContitionKey(conditionList, "user_name", pattern);
//          break;
        // del 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zhou end
        case "hospPatId":
          getFilterContitionKey(conditionList, "hosp_pat_id", pattern);
          break;
        // del 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zhou start
//        case "patName":
//          getFilterContitionKey(conditionList, "pat_name", pattern);
//          break;
        // del 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zhou end
        case "logMessage":
          getFilterContitionKey(conditionList, "message", pattern);
          break;
        case "supportMessage":
          getFilterContitionKey(conditionList, "todo", pattern);
          break;
        case "sessionId":
          getFilterContitionKey(conditionList, "session_id", pattern);
          break;
        case "patId":
          getFilterContitionKey(conditionList, "pat_id", pattern);
          break;
        case "logType":
          getFilterContitionKey(conditionList, "log_type", pattern);
          break;
        // del 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zhou start
//        case "facilityName":
//          getFilterContitionKey(conditionList, "facility_name", pattern);
//          break;
        // del 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zhou end
        // mod 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zkm start
        // case "user_name":
        case "userId":
        // mod 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zkm end
        getFilterContitionKey(conditionList, "user_id", pattern);
          break;
        case "deviceEdgeNo":
          getFilterContitionKey(conditionList, "de_no", pattern);
          break;
        case "deviceEdgeSerialNo":
          getFilterContitionKey(conditionList, "de_serial", pattern);
          break;
        case "machineType":
          getFilterContitionKey(conditionList, "mcn_type", pattern);
          break;
        case "machineTypeCd":
          getFilterContitionKey(conditionList, "mcn_type_cd", pattern);
          break;
        case "ec2Identification":
          getFilterContitionKey(conditionList, "ec2_ip", pattern);
          break;
        // add 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zhou start
        case "serviceName":
          getFilterContitionKey(conditionList, "svc_name", pattern);
          break;
        // add 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zhou end
      }
    }
    // del 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zhou start
//    getFilterContitionKey(conditionList, "facility_cd", pattern);
//    getFilterContitionKey(conditionList, "svc_name", pattern);
//    getFilterContitionKey(conditionList, "func_cd", pattern);
//    getFilterContitionKey(conditionList, "invoke_class", pattern);
    // del 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zhou end
  }
  /**
   * MongoDB検索条件作成
   * @param conditionList 条件リスト
   * @param pattern データ
   */
  // mod 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zhou start
  //private void getKeySearchPatternEncryptList(ArrayList<DBObject> conditionList, Pattern pattern, List<Map<String, Object>> displayItems) {
  private void getKeySearchPatternEncryptList(ArrayList<DBObject> conditionList, String keyword,String operator , List<Map<String, Object>> displayItems,List<String> facilityCdList , boolean searchFlag) {
    // mod 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zhou end
    for (int i = 0; i < displayItems.size(); i++) {
      String keyItem = displayItems.get(i).get("key").toString();
      switch (keyItem) {
        case "user":
          // mod 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zhou start
          //getFilterContitionKey(conditionList, "user_name", pattern);
          List<String> listUserId = mstPersonalUserDao.selectByName(keyword,facilityCdList,searchFlag);
          if (!searchFlag) {
            listUserId.add("");
          }
          getFilterContition(conditionList, "user_id", listUserId, operator);
          // mod 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zhou end
          break;
        case "patName":
          // mod 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zhou start
          List<String> listPatId = patPersonalMainDao.selectByName(keyword,facilityCdList,searchFlag);
          if (!searchFlag) {
            listPatId.add("");
          }
            getFilterContition(conditionList, "pat_id", listPatId, operator);
          //getFilterContitionKey(conditionList, "pat_name", pattern);
         // mod 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zhou end
          break;
         // del 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zhou start
         //case "logMessage":
           //getFilterContitionKey(conditionList, "message", pattern);
          //break;
         // del 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zhou end
          // add 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zhou start
        case "facilityName":
          List<String> listfacilityCd = mstFacilityDao.selectByName(keyword,searchFlag);
          if (!searchFlag) {
            listfacilityCd.add("");
          }
          getFilterContition(conditionList, "facility_cd", listfacilityCd, operator);
          break;
         // add 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zhou end
      }
    }
    // del 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zhou start
    //getFilterContitionKey(conditionList, "facility_name", pattern);
    // del 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zhou end
  }

  /**
   * MongoDB検索条件作成
   * @param conditionList 条件リスト
   * @param key コラム
   * @param value データ
   */
  private void getFilterContitionKey(ArrayList<DBObject> conditionList, String key, Object value) {
    if (value != null) {
      DBObject logConditionList = new BasicDBObject();
      logConditionList.put(key, value);
      conditionList.add(logConditionList);
    }
  }
  // add #6775 ログの抽出が正しく行われない 鄭爽 end
// add 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zhou start
  /**
   * MongoDB検索条件作成
   * @param keyList 条件リスト
   * @param keyword データ
   */
  private void getKeySearchPatternListForDate(ArrayList<DBObject> keyList, Pattern datePattern) {

    getFilterContitionKey(keyList, "log_date", datePattern);
  }
  /**
   * "\\","(",")",".","*","+","?","|","^","$","/","[","]",":","：","{","}","="
   *
   * @param keyword
   * @return
   */
  public static String escapeExprSpecialWord(String keyword) {
    if (!StringUtils.isEmpty(keyword)) {
      String[] fbsArr = { "\\","(",")",".","*","+","?","|","^","$","/","[","]",":","：","{","}","="};
      for (String key : fbsArr) {
        if (keyword.contains(key)) {
          keyword = keyword.replace(key, "\\" + key);
        }
      }
    }
    return keyword;
  }
  // add 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zhou end

  // add #10016 ログ参照画面でフィルタ検索で追加読みで検索条件が破棄されている fang start
  private void createDisplayItemsCondition(ArrayList<DBObject> conditionList, List<Map<String, Object>> displayItems, List<String> facilityCdList) {
    if(!CollectionUtils.isEmpty(displayItems)) {
      for(Map<String, Object> itemMap : displayItems) {
        if(itemMap != null && itemMap.containsKey("freeWord")) {
          if(itemMap.get("freeWord") != null && itemMap.get("key") != null) {
            String freeWord = itemMap.get("freeWord").toString();
            String key = itemMap.get("key").toString();
            List<Map<String, Object>> keyItems = new ArrayList<>();
            keyItems.add(itemMap);
            if(!"".equals(freeWord)) {
              if("user".equals(key) || "patName".equals(key)) {
                getKeySearchPatternEncryptList(conditionList, '%'+ freeWord +'%',"$in", keyItems, facilityCdList, true);
              } else if("date".equals(key)) {
                freeWord = freeWord.replace("/", "");
                getKeySearchPatternListForDate(conditionList, Pattern.compile("^" + escapeExprSpecialWord(freeWord) + ".*$", Pattern.CASE_INSENSITIVE));
              } else {
                Pattern pattern = Pattern.compile("^.*" + escapeExprSpecialWord(freeWord) +".*$", Pattern.CASE_INSENSITIVE);
                getKeySearchPatternList(conditionList, pattern, keyItems);
              }
            }
          }
        }
      }
    }
  }
  // add #10016 ログ参照画面でフィルタ検索で追加読みで検索条件が破棄されている fang end
}
