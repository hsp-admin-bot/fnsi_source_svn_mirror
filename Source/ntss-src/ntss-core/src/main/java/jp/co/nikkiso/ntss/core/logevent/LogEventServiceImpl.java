package jp.co.nikkiso.ntss.core.logevent;

import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.MstFacilityDao;
import jp.co.nikkiso.ntss.core.dao.MstPersonalUserDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.dao.SysFunctionDao;
import jp.co.nikkiso.ntss.core.dao.MstUserAuthenticationDao;
import jp.co.nikkiso.ntss.core.entity.MstFacility;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.SysFunction;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.utils.MongoHealthCheckService;
import org.seasar.doma.MapKeyNamingType;
import jp.co.nikkiso.ntss.core.config.PersonalDb;
import org.seasar.doma.jdbc.Config;
import org.seasar.doma.jdbc.builder.SelectBuilder;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessResourceFailureException;
import org.springframework.data.domain.Page;
import org.springframework.data.mongodb.core.BulkOperations;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static jp.co.nikkiso.ntss.core.logevent.DataUpdateLogInfoUtil.convertString;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

@Service
public class LogEventServiceImpl implements ILogEventService {

  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
  @Autowired
  private LogServiceCore logServiceCore;
// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end

  /**
   * ロットinsert数量制限
   */
  private static final int BATCH_LIMIT_NUM = 2000;

  @Autowired(required = false)
  MongoTemplate mongoTemplate;

  @Autowired
  PatPersonalMainDao patPersonalMainDao;

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
   * 機能一覧
   */
  @Autowired
  private SysFunctionDao sysFunctionDao;
//  add 8074 【デグレ】ログに誤った利用者が記録される 関 start
  /**
   * 利用者マスタ
   */
  @Autowired
  private MstUserAuthenticationDao mstUserAuthenticationDao;
//  add 8074 【デグレ】ログに誤った利用者が記録される 関  end

  @Autowired
  @PersonalDb
  private Config personalDbConfig;
  /**
   * mongoDB検索
   *
   * @param params 抽出条件
   * @return
   */
  @Override
  public Page<LogEvent> findAll(LogEvent params) {
    //Query query = new Query();
    //query.addCriteria(Criteria.where("pat_id").nin(listExpPatId));

    return null;
  }

  /**
   * decryptデータ取得
   *
   * @param inData 抽出条件
   * @return
   */
  @Override
  public String getPersonalInfoDecrypt(String inData) {
    if (StringUtils.isEmpty(inData)) {
      return "";
    }

    String returnValue = "";
    Config config = personalDbConfig;
    SelectBuilder selectBuilder = SelectBuilder.newInstance(config);
    selectBuilder.sql("select personal_info_decrypt('" + inData +"') as decrypt_value");
    List<Map<String, Object>> results = selectBuilder.getMapResultList(MapKeyNamingType.NONE);

    if (results.isEmpty()) {
      return "";
    }

    for (Map<String, Object> result : results) {
      returnValue = convertString(result.get("decrypt_value"));
      break;
    }

    return returnValue;
  }

  /**
   * Encryptデータ取得
   *
   * @param inData 抽出条件
   * @return
   */
  public String getPersonalInfoEncrypt(String inData) {
    if (StringUtils.isEmpty(inData)) {
      return "";
    }
    String returnValue = "";
    Config config = personalDbConfig;
    SelectBuilder selectBuilder = SelectBuilder.newInstance(config);
    selectBuilder.sql("select personal_info_encrypt('" + inData +"') as encrypt_value");
    List<Map<String, Object>> results = selectBuilder.getMapResultList(MapKeyNamingType.NONE);

    if (results.isEmpty()) {
      return "";
    }

    for (Map<String, Object> result : results) {
      returnValue = convertString(result.get("encrypt_value"));
      break;
    }

    return returnValue;
  }

  /**
   * mongoDB登録
   *
   * @param params
   * @return
   */
  public void create(LogLevel logType, LogEvent params) {
    if (logType == LogLevel.DEBUG) {
      return;
    }
    // ログ出力タイムスタンプ
    params.setLogDate(new SimpleDateFormat("yyyyMMddHHmmssSSS").format(new Date()));
    initLogEvent(params);

    try {
      // 患者IDと患者名取得
      if (!StringUtils.isEmpty(params.getPatId())) {
        PatPersonalMain pat = getPatName(params.getPatId());
        if (pat != null) {
          params.setPatName(getPersonalInfoEncrypt(nullToSpace(pat.getPat_last_name()) + " " + nullToSpace(pat.getPat_first_name())));
          params.setHospPatId(nullToSpace(pat.getHosp_pat_id()));
        }
      }

      // ユーザ名取得
//      mod 8074 【デグレ】ログに誤った利用者が記録される 関 start
//      if (!StringUtils.isEmpty(params.getUserId())) {
//        params.setUsername(getPersonalInfoEncrypt(getUsername(params.getUserId())));
//      }
      if ("-1".equals(params.getUserId())) {
        String dispUserId = "ScalApp4";
        String userAuthenticationUserId =  mstUserAuthenticationDao.selectUserIdByFacilityCd(dispUserId, params.getFacilityCd());
        params.setUsername(getPersonalInfoEncrypt(getUsername(userAuthenticationUserId)));
        params.setUserId(userAuthenticationUserId);
        if (!"".equals(userAuthenticationUserId)) {
          params.setUsername(getPersonalInfoEncrypt("体重計App ユーザー"));
        } else {
          params.setUsername(getPersonalInfoEncrypt(getUsername(userAuthenticationUserId)));
          params.setUserId(userAuthenticationUserId);
        }
      }
      else if (!StringUtils.isEmpty(params.getUserId())) {
        params.setUsername(getPersonalInfoEncrypt(getUsername(params.getUserId())));
      }
//      mod 8074 【デグレ】ログに誤った利用者が記録される 関  end

      // ユーザ名取得
      if (!StringUtils.isEmpty(params.getFacilityCd())) {
        params.setFacilityName(getPersonalInfoEncrypt(getFacilityName(params.getFacilityCd())));
      }

      // 機能名取得
      if (!StringUtils.isEmpty(params.getFuncCd())) {
        params.setFunctionName(getPersonalInfoEncrypt(getFunctionName(params.getFuncCd())));
      }

      if (!StringUtils.isEmpty(params.getFunctionName()) && StringUtils.isEmpty(params.getFuncCd())) {
        SysFunction sysFunction = sysFunctionDao.selectByFunctionName(params.getFunctionName());
        if (sysFunction != null) {
          params.setFuncCd(sysFunction.getFunctionCd());
        }
      }
    } catch (Exception e) {
      //add 10248 mongodbリンク可能状態による関連操作の処理 gjn start
      try {
        if (MongoHealthCheckService.getMongoDBConnected())
          mongoTemplate.insert(params);
      } catch (DataAccessResourceFailureException exception) {
        MongoHealthCheckService.setMongoDBConnected(false);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        if (params != null && params.getFacilityCd() != null) {
          eventLogMessage.setFacilityCd(params.getFacilityCd());
        }
        logServiceCore.log(LogLevel.ERROR, eventLogMessage, "", null, LoggingConstant.SERVICE_NAME.FNSI, null);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
      }
      //add 10248 mongodbリンク可能状態による関連操作の処理 gjn end
    }

    //add 10248 mongodbリンク可能状態による関連操作の処理 gjn start
    try {
      if (MongoHealthCheckService.getMongoDBConnected())
        mongoTemplate.insert(params);
    } catch (DataAccessResourceFailureException exception) {
      MongoHealthCheckService.setMongoDBConnected(false);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(exception));
      if (params != null && params.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(params.getFacilityCd());
      }
      logServiceCore.log(LogLevel.ERROR, eventLogMessage, "", null, LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
    }
    //add 10248 mongodbリンク可能状態による関連操作の処理 gjn end
  }

  /* add by chamaojia 2023-03-14 新しい一括ログ記録方法の追加  --start */
  /**
   * mongoDB登録
   *
   * @param params
   * @return
   */
  public void createToBatch(LogLevel logType, List<LogEvent> logEventList) {
    if (logType == LogLevel.DEBUG) {
      return;
    }

    Map<String, PatPersonalMain> patPersonalMainMap = new HashMap<>();
    Map<String, String> userMap = new HashMap<>();
    Map<String, String> facilityCdMap = new HashMap<>();
    Map<String, String> functionNameMap = new HashMap<>();
    Map<String, String> functionCdMap = new HashMap<>();
    List<LogEvent> logEventSaveList = new ArrayList<>();
    for (LogEvent params : logEventList) {
      // ログ出力タイムスタンプ
      params.setLogDate(new SimpleDateFormat("yyyyMMddHHmmssSSS").format(new Date()));
      initLogEvent(params);

      try {
        // 患者IDと患者名取得
        if (!StringUtils.isEmpty(params.getPatId())) {
          if (patPersonalMainMap.containsKey(params.getPatId())) {
            if (patPersonalMainMap.get(params.getPatId()) != null) {
              params.setPatName(patPersonalMainMap.get(params.getPatId()).getPat_last_name());
              params.setHospPatId(patPersonalMainMap.get(params.getPatId()).getHosp_pat_id());
            }
          } else {
            PatPersonalMain pat = getPatName(params.getPatId());
            if (pat != null) {
              params.setPatName(getPersonalInfoEncrypt(nullToSpace(pat.getPat_last_name()) + " " + nullToSpace(pat.getPat_first_name())));
              params.setHospPatId(nullToSpace(pat.getHosp_pat_id()));

              pat.setPat_last_name(params.getPatName());
              pat.setHosp_pat_id(params.getHospPatId());
              patPersonalMainMap.put(params.getPatId(), pat);
            } else {
              patPersonalMainMap.put(params.getPatId(), null);
            }
          }
        }

        // ユーザ名取得
//      mod 8074 【デグレ】ログに誤った利用者が記録される 関 start
//      if (!StringUtils.isEmpty(params.getUserId())) {
//        params.setUsername(getPersonalInfoEncrypt(getUsername(params.getUserId())));
//      }
        if ("-1".equals(params.getUserId())) {
          String dispUserId = "ScalApp4";
          String userAuthenticationUserId =  mstUserAuthenticationDao.selectUserIdByFacilityCd(dispUserId, params.getFacilityCd());
          params.setUsername(getPersonalInfoEncrypt(getUsername(userAuthenticationUserId)));
          params.setUserId(userAuthenticationUserId);
          if (!"".equals(userAuthenticationUserId)) {
            params.setUsername(getPersonalInfoEncrypt("体重計App ユーザー"));
          } else {
            params.setUsername(getPersonalInfoEncrypt(getUsername(userAuthenticationUserId)));
            params.setUserId(userAuthenticationUserId);
          }
        }
        else if (!StringUtils.isEmpty(params.getUserId())) {
          if (userMap.containsKey(params.getUserId())) {
            params.setUsername(userMap.get(params.getUserId()));
          } else {
            params.setUsername(getPersonalInfoEncrypt(getUsername(params.getUserId())));
            userMap.put(params.getUserId(), params.getUsername());
          }
        }
//      mod 8074 【デグレ】ログに誤った利用者が記録される 関  end

        // ユーザ名取得
        if (!StringUtils.isEmpty(params.getFacilityCd())) {
          if (facilityCdMap.containsKey(params.getFacilityCd())) {
            params.setFacilityName(facilityCdMap.get(params.getFacilityCd()));
          } else {
            params.setFacilityName(getPersonalInfoEncrypt(getFacilityName(params.getFacilityCd())));
            facilityCdMap.put(params.getFacilityCd(), params.getFacilityName());
          }
        }

        // 機能名取得
        if (!StringUtils.isEmpty(params.getFuncCd())) {
          if (functionCdMap.containsKey(params.getFuncCd())) {
            params.setFunctionName(functionCdMap.get(params.getFuncCd()));
          } else {
            params.setFunctionName(getPersonalInfoEncrypt(getFunctionName(params.getFuncCd())));
            functionCdMap.put(params.getFuncCd(), params.getFunctionName());
          }
        }

        if (!StringUtils.isEmpty(params.getFunctionName()) && StringUtils.isEmpty(params.getFuncCd())) {
          if (functionNameMap.containsKey(params.getFunctionName())) {
            if (functionNameMap.get(params.getFunctionName()) != null) {
              params.setFuncCd(functionNameMap.get(params.getFunctionName()));
            }
          } else {
            SysFunction sysFunction = sysFunctionDao.selectByFunctionName(params.getFunctionName());
            if (sysFunction != null) {
              params.setFuncCd(sysFunction.getFunctionCd());
              functionNameMap.put(params.getFunctionName(), params.getFuncCd());
            } else {
              functionNameMap.put(params.getFunctionName(), null);
            }
          }
        }
      } catch (Exception e) {
//        mongoTemplate.insert(params);
      }

//      mongoTemplate.insert(params);
      logEventSaveList.add(params);
    }

    int loopCount = logEventSaveList.size() / BATCH_LIMIT_NUM;
    for (int i = 0; i <= loopCount; i++) {
      List<LogEvent> saveList;
      if (i == loopCount) {
        saveList = logEventSaveList.subList(i * BATCH_LIMIT_NUM, logEventSaveList.size());
      } else {
        saveList = logEventSaveList.subList(i * BATCH_LIMIT_NUM, (i + 1) * BATCH_LIMIT_NUM);
      }
      if (!saveList.isEmpty()) {
        //add 10248 mongodbリンク可能状態による関連操作の処理 gjn start
        try {
          if (MongoHealthCheckService.getMongoDBConnected())
            mongoTemplate.bulkOps(BulkOperations.BulkMode.ORDERED, LogEvent.class).insert(saveList).execute();
        } catch (DataAccessResourceFailureException exception) {
          MongoHealthCheckService.setMongoDBConnected(false);
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(exception));
          logServiceCore.log(LogLevel.ERROR, eventLogMessage, "", null, LoggingConstant.SERVICE_NAME.FNSI, null);
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
        }
        //add 10248 mongodbリンク可能状態による関連操作の処理 gjn end
      }
    }
  }
  /* add by chamaojia 2023-03-14 新しい一括ログ記録方法の追加  --end */

  /**
   * ユーザ名を取得する
   * @param userId
   * @return
   */
  public String getPersonalUserName(Long userId) {
    String username = getUsername(convertString(userId));
    return username;
  }

  /**
   * 内部患者IDによって、患者IDを取得する
   * @return
   */
  private void initLogEvent(LogEvent event) {
    if (event.getHospPatId() == null) {
      event.setHospPatId("");
    }

    if (event.getFunctionName() == null) {
      event.setFunctionName("");
    }

    if (event.getFacilityName() == null) {
      event.setFacilityName("");
    }

    if (event.getUsername() == null) {
      event.setUsername("");
    }

    if (event.getPatName() == null) {
      event.setPatName("");
    }
  }

  /**
   * 施設名取得する
   * @param facilityCd
   */
  private String getFacilityName(String facilityCd) {
    if (!StringUtils.isEmpty(facilityCd)) {
      List listFacilityCds = new ArrayList();
      listFacilityCds.add(facilityCd);
      List<MstFacility> listFacility = mstFacilityDao.selectByFacilityCds(listFacilityCds);
      if (listFacility != null && listFacility.size() > 0) {
        MstFacility mstFacility = listFacility.get(0);
        if (mstFacility != null) {
          return nullToSpace(mstFacility.getFacilityName());
        }
      }
    }

    return "";
  }

  /**
   * ユーザ名取得する
   * @param userId
   */
  private String getUsername(String userId) {
    if (!StringUtils.isEmpty(userId)) {
      List userList = new ArrayList();
      userList.add(userId);
      List<MstPersonalUser> listPersonalUser = mstPersonalUserDao.selectByIdList(userList);
      if (listPersonalUser != null && listPersonalUser.size() > 0) {
        MstPersonalUser person = listPersonalUser.get(0);
        if (person != null) {
          return nullToSpace(person.getUserLastName()) + " " + nullToSpace(person.getUserFirstName());
        }
      }
    }
    return "";
  }

  /**
   * 患者名取得する
   * @param patId
   */
  private PatPersonalMain getPatName(String patId) {
    if (!StringUtils.isEmpty(patId)) {
      List patIdList = new ArrayList();
      patIdList.add(patId);
      List<PatPersonalMain> listPatPersonal = patPersonalMainDao.selectByIdList(patIdList);
      if (listPatPersonal != null && listPatPersonal.size() > 0) {
        PatPersonalMain pat = listPatPersonal.get(0);
        return pat;
      }
    }
    return null;
  }

  /**
   * 機能名取得
   * @param funCd 機能コード
   * @return 機能名
   */
  private String getFunctionName(String funCd) {
    if (!StringUtils.isEmpty(funCd)) {
      SysFunction function = sysFunctionDao.selectByFunctionCd(funCd);
      if (function != null) {
        return nullToSpace(function.getFunctionName());
      }
    }
    return "";
  }

  /**
   * 文字列変換する
   * @param obj 文字列
   * @return 変換した文字列
   */
  private static String nullToSpace(String obj) {
    if (obj == null) {
      return "";
    }
    return obj;
  }
}
