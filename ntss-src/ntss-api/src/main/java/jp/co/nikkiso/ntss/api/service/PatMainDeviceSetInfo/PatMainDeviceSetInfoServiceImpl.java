package jp.co.nikkiso.ntss.api.service.PatMainDeviceSetInfo;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.api.response.wheelChair.WheelChairWithNameResponse;
import jp.co.nikkiso.ntss.api.service.LogService;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.MstAdditionDao;
import jp.co.nikkiso.ntss.core.dao.MstCourseDao;
import jp.co.nikkiso.ntss.core.dao.MstDeviceSetInfoDefaultDao;
import jp.co.nikkiso.ntss.core.dao.MstDialysisDifficultyDao;
import jp.co.nikkiso.ntss.core.dao.MstDiseaseDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilityDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilitySettingDao;
import jp.co.nikkiso.ntss.core.dao.MstFavoriteFacilityDao;
import jp.co.nikkiso.ntss.core.dao.MstImplantDao;
import jp.co.nikkiso.ntss.core.dao.MstInfectionDao;
import jp.co.nikkiso.ntss.core.dao.MstPersonalUserDao;
import jp.co.nikkiso.ntss.core.dao.MstSeverityDao;
import jp.co.nikkiso.ntss.core.dao.MstTransportDao;
import jp.co.nikkiso.ntss.core.dao.MstUserAuthenticationDao;
import jp.co.nikkiso.ntss.core.dao.MstWardDao;
import jp.co.nikkiso.ntss.core.dao.MstWheelChairDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.PatExamMainDao;
import jp.co.nikkiso.ntss.core.dao.PatGroupDao;
import jp.co.nikkiso.ntss.core.dao.PatMainDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.dao.PatUniqueDao;
import jp.co.nikkiso.ntss.core.dao.SysFacilityDao;
import jp.co.nikkiso.ntss.core.entity.MstAddition;
import jp.co.nikkiso.ntss.core.entity.MstCourse;
import jp.co.nikkiso.ntss.core.entity.MstDialysisDifficulty;
import jp.co.nikkiso.ntss.core.entity.MstDisease;
import jp.co.nikkiso.ntss.core.entity.MstFacility;
import jp.co.nikkiso.ntss.core.entity.MstImplant;
import jp.co.nikkiso.ntss.core.entity.MstInfection;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.entity.MstSeverity;
import jp.co.nikkiso.ntss.core.entity.MstTransport;
import jp.co.nikkiso.ntss.core.entity.MstUserAuthentication;
import jp.co.nikkiso.ntss.core.entity.MstWard;
import jp.co.nikkiso.ntss.core.entity.MstWheelChair;
import jp.co.nikkiso.ntss.core.entity.PatExamMainForAllExamResultInfo;
import jp.co.nikkiso.ntss.core.entity.PatGroup;
import jp.co.nikkiso.ntss.core.entity.PatMain;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.PatUnique;
import jp.co.nikkiso.ntss.core.entity.SysFacility;
import jp.co.nikkiso.ntss.core.entity.custom.AdditionInfoOrdMain;
import jp.co.nikkiso.ntss.core.entity.custom.FacilitySettingInfo;
import jp.co.nikkiso.ntss.core.entity.custom.MstFavoriteFacilityData;
import jp.co.nikkiso.ntss.core.entity.custom.PatGroupCustomForPg;
import jp.co.nikkiso.ntss.core.entity.patHistory.PatMainHistory;
import jp.co.nikkiso.ntss.core.entity.patHistory.PatPersonalMainHistory;
import jp.co.nikkiso.ntss.core.entity.patHistory.PatUniqueHistory;
import jp.co.nikkiso.ntss.core.entity.patHistory.patMainHistoryDetail.AdditionInfo;
import jp.co.nikkiso.ntss.core.entity.patHistory.patMainHistoryDetail.ChargeStaffInfo;
import jp.co.nikkiso.ntss.core.entity.patHistory.patMainHistoryDetail.ImplantInfo;
import jp.co.nikkiso.ntss.core.entity.patHistory.patMainHistoryDetail.InfectInfo;
import jp.co.nikkiso.ntss.core.entity.patHistory.patMainHistoryDetail.MedicalCareInfo;
import jp.co.nikkiso.ntss.core.entity.patHistory.patMainHistoryDetail.PatGroupInfo;
import jp.co.nikkiso.ntss.core.entity.patHistory.patMainHistoryDetail.PatMemoInfo;
import jp.co.nikkiso.ntss.core.entity.patHistory.patMainHistoryDetail.TabooAllergyInfo;
import jp.co.nikkiso.ntss.core.logevent.DataUpdateLogCommonNew;
import jp.co.nikkiso.ntss.core.logevent.LogServiceCore;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.utils.MongoHealthCheckService;
import org.apache.commons.collections.CollectionUtils;
import org.json.JSONArray;
import org.json.JSONObject;
import org.seasar.doma.jdbc.Config;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessResourceFailureException;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.core.query.Update;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
// add #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 start
import java.util.concurrent.atomic.AtomicInteger;
// add #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 end
import java.util.stream.Collectors;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;


// add #9811 装置設定>操作範囲>ヘマトクリットと総タンパクの検査値が不正 修正 20231113 ztc start
@Service
public class PatMainDeviceSetInfoServiceImpl implements PatMainDeviceSetInfoService {

    /**
     * ロガー生成コンポーネント
     */
    @Autowired
    private EventLoggerFactory eventLoggerFactory;

    /**
     * ロギングのServiceインタフェース.
     */
    @Autowired
    private LogServiceCore logServiceCore;
    @Autowired
    private LogService logService;

    /**
     * 患者検査結果のDaoインタフェース.
     */
    @Autowired
    private PatExamMainDao patExamMainDao;

    @Autowired
    private MstDeviceSetInfoDefaultDao mstDeviceSetInfoDefaultDao;

    @Autowired
    private MstFacilitySettingDao mstFacilitySettingDao;

    /**
     * 患者情報Daoインタフェース.
     */
    @Autowired
    private PatMainDao patMainDao;

    @Autowired(required = false)
    private MongoTemplate mongoTemplate;

    //add #10632 装置設定画面の更新時にpat_main_historyがインサートされない 20240530 ztc start
    @Autowired
    private PatPersonalMainDao patPersonalMainDao;

    @Autowired
    private PatUniqueDao patUniqueDao;

    @Autowired
    private MstUserAuthenticationDao mstUserAuthenticationDao;

    @Autowired
    private MstCourseDao mstCourseDao;

    @Autowired
    private MstWardDao mstWardDao;

    @Autowired
    private SysFacilityDao sysFacilityDao;

    @Autowired
    private MstFacilityDao mstFacilityDao;

    @Autowired
    private MstDiseaseDao mstDiseaseDao;

    @Autowired
    MstInfectionDao mstInfectionDao;

    @Autowired
    private MstImplantDao mstImplantDao;

    @Autowired
    private MstPersonalUserDao mstPersonalUserDao;

    @Autowired
    private MstSeverityDao mstSeverityDao;

    @Autowired
    private MstTransportDao mstTransportDao;

    @Autowired
    MstDialysisDifficultyDao mstDialysisDifficultyDao;

    @Autowired
    private MstFavoriteFacilityDao mstFavoriteFacilityDao;

    @Autowired
    private MstAdditionDao mstAdditionDao;

    @Autowired
    private OrdMainDao ordMainDao;

    @Autowired
    private MstWheelChairDao mstWheelChairDao;

    // add #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 start
    @Autowired
    private PatGroupDao patGroupDao;
    // add #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 end

    /**
     * 検査結果に関する操作 更新 装置設定 補液設定  ヘマトクリット(Ht) / 検査日時,総タンパク(TP) / 検査日時
     * 呼び出し元：
     * 1.検査結果登録
     * 2.検査結果更新
     * 3.検査結果一括取込
     * 4.連携登録
     * 5.連携更新
     * If HT data exists, set keyAvailable to 1.
     * If TP data exists, set keyAvailable to 2.
     * If both HT and TP data exist, set keyAvailable to 3.
     */
    @Override
    public void updDeviceSetInfo(String facilityCd, Long patId, Map<String, String> userAuthInfo, int isTpHTDataAvailableFlag) throws Exception {
        if (facilityCd == null || patId == null) {
            return;
        }
        String deviceSetInfo = null;
        String mstDeviceSetInfo = null;
        String aJSON_91 = null;
        String aJSON_92 = null;
        String cJSON_91 = null;
        String cJSON_92 = null;
        List<PatExamMainForAllExamResultInfo> patExamMainHt = patExamMainDao.selectExamResultInfoByCalcExamItemCd(facilityCd, patId, "7");
        List<PatExamMainForAllExamResultInfo> patExamMainTp = patExamMainDao.selectExamResultInfoByCalcExamItemCd(facilityCd, patId, "14");
        if((isTpHTDataAvailableFlag != 2 && patExamMainHt.isEmpty()) || (isTpHTDataAvailableFlag != 1 && patExamMainTp.isEmpty())){
            mstDeviceSetInfo = mstDeviceSetInfoDefaultDao.selectDeviceSetInfo(facilityCd);
            JSONObject mstDeviceSetInfoJson = new JSONObject(mstDeviceSetInfo);
            JSONObject ord = this.extractJSONObject(mstDeviceSetInfoJson, "pat");
            aJSON_91 = this.extractStringFromNestedJSON(ord, "ope", "dev", "A", "91");
            cJSON_91 = this.extractStringFromNestedJSON(ord, "ope", "dev", "C", "91");
            aJSON_92 = this.extractStringFromNestedJSON(ord, "ope", "dev", "A", "92");
            cJSON_92 = this.extractStringFromNestedJSON(ord, "ope", "dev", "C", "92");
        }
        ObjectMapper objectMapper = new ObjectMapper();
        deviceSetInfo = patMainDao.selectDeviceSetInfo(patId);
        Map<String, Map<String, Map<String, Map<String, Object>>>> mapDeviceSetInfo = new HashMap<String, Map<String, Map<String, Map<String, Object>>>>();
        mapDeviceSetInfo = objectMapper.readValue(deviceSetInfo, mapDeviceSetInfo.getClass());
        Map<String, Map<String, Map<String, Object>>> mapOpe = mapDeviceSetInfo.get("ope");
        Map<String, Map<String, Object>> mapDev = mapOpe.get("dev");
        Map<String, Object> mapA = mapDev.get("A");
        Map<String, Object> mapC = mapDev.get("C");
        if(isTpHTDataAvailableFlag != 2){
            if (patExamMainHt.size() > 0) {
                JsonNode examResultInfoHtJN = objectMapper.readTree(patExamMainHt.get(0).getExamResultInfo());
                for (JsonNode htNode : examResultInfoHtJN) {
                    if (htNode.has("item_cd") && htNode.get("item_cd").asText().equals(patExamMainHt.get(0).getExamItemCd().toString())) {
                        JsonNode resultNode = htNode.get("result");
                        if (resultNode != null) {
                            Double result = Double.valueOf(this.trimNumByFullNum(resultNode.asText()));
                            if (!Double.isNaN(result)) {
                                //mod #9811 Htは小数点以下四捨五入で設定する事 20240328 ztc start
                                //mapA.put("91", result);
                                mapA.put("91", new BigDecimal(this.trimNumByFullNum(resultNode.asText())).setScale(0, BigDecimal.ROUND_HALF_UP).doubleValue());
                                //mod #9811 Htは小数点以下四捨五入で設定する事 20240328 ztc end
                                //mod #10632 装置設定画面の更新時にpat_main_historyがインサートされない 20240610 ztc start
//                                mapC.put("91", Long.parseLong(patExamMainHt.get(0).getResultExamDate().toString().replaceAll("[^0-9]", "")));
                                mapC.put("91", Long.parseLong(patExamMainHt.get(0).getResultExamDate().toString().replaceAll("[^0-9]", "").substring(0,12)));
                                //mod #10632 装置設定画面の更新時にpat_main_historyがインサートされない 20240610 ztc end
                                break;
                            }
                        }
                    }
                }
            }else{
                if(mstDeviceSetInfo != null){
                    mapA.put("91", Double.valueOf(this.trimNumByFullNum(aJSON_91)));
                    mapC.put("91", cJSON_91);
                }
            }
        }
        if(isTpHTDataAvailableFlag != 1) {
            if (patExamMainTp.size() > 0) {
                JsonNode examResultInfoTPJN = objectMapper.readTree(patExamMainTp.get(0).getExamResultInfo());
                for (JsonNode tpNode : examResultInfoTPJN) {
                    if (tpNode.has("item_cd") && tpNode.get("item_cd").asText().equals(patExamMainTp.get(0).getExamItemCd().toString())) {
                        JsonNode resultNode = tpNode.get("result");
                        if (resultNode != null) {
                            Double result = Double.valueOf(this.trimNumByFullNum(resultNode.asText()));
                            if (!Double.isNaN(result)) {
                                mapA.put("92", result);
                                mapC.put("92", Long.parseLong(patExamMainTp.get(0).getResultExamDate().toString().replaceAll("[^0-9]", "").substring(0,12)));
                                break;
                            }
                        }
                    }
                }
            } else {
                if (mstDeviceSetInfo != null) {
                    mapA.put("92", Double.valueOf(this.trimNumByFullNum(aJSON_92)));
                    mapC.put("92", cJSON_92);
                }
            }
        }
        deviceSetInfo = new JSONObject(mapDeviceSetInfo).toString();
        this.updateDeviceSetInfoPat(patId, facilityCd, deviceSetInfo, userAuthInfo);
    }

    /**
     *
     * @param facilityCd
     * @param examMainCd
     * @return  If neither HT(default_calc_exam_item_cd = "7") nor TP(default_calc_exam_item_cd = "14") data exists, set keyAvailable to 0.
     *          If HT(default_calc_exam_item_cd = "7")  data exists, set keyAvailable to 1.
     *          If TP(default_calc_exam_item_cd = "14") data exists, set keyAvailable to 2.
     *          If both HT(default_calc_exam_item_cd = "7") and TP(default_calc_exam_item_cd = "14") data exist, set keyAvailable to 3.
     * @throws Exception
     */
    public int isTpHTDataAvailable(String facilityCd, Long examMainCd) throws Exception{
        List<FacilitySettingInfo> setting_114 = mstFacilitySettingDao
                .selectFacilitySetting(facilityCd, CoreConstant.FacilitySettingNo.REPLENISHER_FILTRATION_SETTING);
        int keyAvailable = 0;
        if(setting_114.size() > 0 && "1".equals(setting_114.get(0).getValue())){
            Boolean isHTDataAvailable = patExamMainDao.selectTpHTDataAvailable(facilityCd, examMainCd, "7");
            Boolean isTpDataAvailable = patExamMainDao.selectTpHTDataAvailable(facilityCd, examMainCd, "14");
            keyAvailable = (isHTDataAvailable ? 1 : 0) + (isTpDataAvailable ? 2 : 0);
        }
        return keyAvailable;
    };

    private String trimNumByFullNum(String fullWidth) throws Exception {
        StringBuilder trimNum = new StringBuilder();
        for (char c : fullWidth.toCharArray()) {
            if (Character.isDigit(c)) {
                trimNum.append(Character.getNumericValue(c));
            } else if (c == '．') {
                trimNum.append('.');
            } else {
                trimNum.append(c);
            }
        }
        return trimNum.toString();
    }

    @Transactional
    public void updateDeviceSetInfoPat(Long patId, String facilityCd, String deviceSetInfoJson, Map<String, String> userAuthInfo) {
        boolean setResult = false;
        DataUpdateLogCommonNew logCommon = null;
        try {
            String tableName = "pat_main";
            // SQL検索条件
            StringBuffer wheres = new StringBuffer("");
            wheres.append(" WHERE\n");
            wheres.append(" pat_id = '" + patId + "' and \n");
            wheres.append(" facility_cd = '" + facilityCd + "' \n");
            // logCommon設定
            logCommon = getLogCommon(patMainDao, tableName, wheres, getEventLogMessage(userAuthInfo));
            // ログ出力カラム情報及び更新前データ情報取得
            setResult = logCommon.setInfo();
        } catch(Exception e) {
            setResult = false;
        }
        int updateCount = patMainDao.updateDeviceSetInfo(patId, facilityCd, deviceSetInfoJson);
        // 更新後データ取得、差分あれば、log出力
        if (setResult && updateCount > 0) {
            logCommon.updateLog();
            //add #10632 装置設定画面の更新時にpat_main_historyがインサートされない 20240530 ztc start
            try {
                this.insertPatMainHistoryByPatIdFacilityCd(facilityCd, patId);
            } catch (Exception e) {
// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
              EventLogMessage eventLogMessageNew = new EventLogMessage();
              eventLogMessageNew.setLogMessage(ExcetionStackTraceToString(e));
              logService.log(LogLevel.ERROR, eventLogMessageNew, "", LoggingConstant.SERVICE_NAME.FNSI, null);
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
            }
            //add #10632 装置設定画面の更新時にpat_main_historyがインサートされない 20240530 ztc end
        }
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

    /**
     * ログ情報設定
     *
     * @return eventLogMessage
     */
    private EventLogMessage getEventLogMessage(Map<String, String> userAuthInfo) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        if (userAuthInfo != null) {
            // 利用者ID
            eventLogMessage.setUserId(userAuthInfo.get("userId"));
            // 施設コード
            eventLogMessage.setFacilityCd(userAuthInfo.get("facilityCd"));
            // 接続先IPアドレス
            eventLogMessage.setClientIp(userAuthInfo.get("clientIpAddress"));
            // セッションID
            eventLogMessage.setSessionId(userAuthInfo.get("sessionId"));
        }
        // サービス名
        eventLogMessage.setServiceName(LoggingConstant.MODULE_NAME.ADMIN_WEB + "," + LoggingConstant.SERVICE_NAME.FNSI);
        return eventLogMessage;
    }

    /**
     * Extracts the value of the specified key from the given JSONObject.
     * Returns an empty JSONObject if the key does not exist.
     *
     * @param parent The given JSONObject
     * @param key    The key whose value is to be extracted
     * @return The value of the specified key, or an empty JSONObject if the key does not exist
     */
    private JSONObject extractJSONObject(JSONObject parent, String key) {
        return parent.has(key) ? parent.getJSONObject(key) : new JSONObject();
    }

    /**
     * Extracts nested string values from the given JSONObject.
     *
     * @param parent The given JSONObject
     * @param keys   The array of keys to traverse
     * @return The nested string value, or null if extraction fails
     */
    private String extractStringFromNestedJSON(JSONObject parent, String... keys) {
        JSONObject nestedObj = parent;
        for (String key : keys) {
            if (nestedObj.has(key) && nestedObj.get(key) instanceof JSONObject) {
                nestedObj = nestedObj.getJSONObject(key);
            } else if (nestedObj.has(key)) {
                return nestedObj.get(key).toString();
            } else {
                return null;
            }
        }
        return nestedObj != null ? nestedObj.toString() : null;
    }

    //add #10632 装置設定画面の更新時にpat_main_historyがインサートされない 20240530 ztc start
    public void insertPatMainHistoryByPatIdFacilityCd(String facilityCd, Long patId) throws Exception {
        try {
            if (StringUtils.isEmpty(facilityCd) || StringUtils.isEmpty(patId)) {
                return;
            }
            try {
                if (MongoHealthCheckService.getMongoDBConnected()) {
                    // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 start
                    ObjectMapper mapper = new ObjectMapper();
                    // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 end
                    // add #11159 特定の患者だけ患者情報編集時にエラーが発生する ztc 20241003 start
                    mapper.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);
                    // add #11159 特定の患者だけ患者情報編集時にエラーが発生する ztc 20241003 end
                    String patIdStr = patId.toString();
                    List<PatMain> patMainList = patMainDao.selectByFacilityCdPatId(facilityCd, patId);
                    jp.co.nikkiso.ntss.core.entity.patHistory.PatMainHistory patMainHistory = new jp.co.nikkiso.ntss.core.entity.patHistory.PatMainHistory();
                    if (CollectionUtils.isNotEmpty(patMainList)) {
                        BeanUtils.copyProperties(patMainList.get(0), patMainHistory, "_id");
                    } else {
                        return;
                    }

                    Timestamp now = new Timestamp(new Date().getTime());
                    patMainHistory.setIns_date(now);
                    patMainHistory.setPat_id(patIdStr);
                    patMainHistory.setLatest_flag("on");
                    LocalDateTime currentTime = LocalDateTime.now();
                    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
                    patMainHistory.setUp_date(currentTime.format(formatter));

                    PatPersonalMain patPersonalMain = patPersonalMainDao.selectById(patId);
                    PatPersonalMainHistory patPersonalMainHistory = new PatPersonalMainHistory();
                    BeanUtils.copyProperties(patPersonalMain, patPersonalMainHistory);
                    PatUnique patUnique = patUniqueDao.selectById(patId);
                    PatUniqueHistory patUniqueHistory = new PatUniqueHistory();
                    BeanUtils.copyProperties(patUnique, patUniqueHistory);
                    // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 start
//                    Map<String, Map<String, String>> getMstNames = this.getMstNames(patPersonalMainHistory, patMainHistory, patUniqueHistory);
                    Map<String, Map<String, String>> getMstNames = this.getMstNames(patPersonalMain, patMainList.get(0), patUnique);
                    // 登録施設名
                    patMainHistory.setFacility_name(this.getCodeName(getMstNames, "facilityNames", patMainHistory.getFacility_cd()));
                    // 担当スタッフ情報を取得する。
//                    JSONArray chargeStaffInfoJson = this.getJSONArray(patMainHistory.getCharge_staff_info());
                    JSONArray chargeStaffInfoJson = this.getJSONArray(patMainList.get(0).getCharge_staff_info());
                    // 担当スタッフ情報
                    for (int i = 0; i < chargeStaffInfoJson.length(); i++) {
                        JSONObject jsonObj = chargeStaffInfoJson.getJSONObject(i);
                        // スタッフ
                        jsonObj.put("staff_name", this.getCodeName(getMstNames, "personalUserNames", jsonObj.get("staff_cd")));
                        // スタッフ表示用コード
                        String dispUserId = "";
                        if (!StringUtils.isEmpty(jsonObj.get("staff_cd").toString()) && !"null".equals(jsonObj.get("staff_cd").toString())) {
                            MstUserAuthentication mstUserAuthentication = mstUserAuthenticationDao.selectById(Long.parseLong(jsonObj.get("staff_cd").toString()));
                            dispUserId = mstUserAuthentication.getDispUserId() != null ? mstUserAuthentication.getDispUserId() : "";
                        }
                        jsonObj.put("staff_disp_cd", dispUserId);
                    }
//                    patMainHistory.setCharge_staff_info(chargeStaffInfoJson.toString());
                    List<ChargeStaffInfo> chargeStaffInfos = mapper.readValue(chargeStaffInfoJson.toString(), new TypeReference<List<ChargeStaffInfo>>() {});
                    patMainHistory.setCharge_staff_info(chargeStaffInfos);

                    // 感染症情報を取得する。
//                    JSONArray infectInfoJson = this.getJSONArray(patMainHistory.getInfect_info());
                    JSONArray infectInfoJson = this.getJSONArray(patMainList.get(0).getInfect_info());
                    // 感染症情報
                    for (int i = 0; i < infectInfoJson.length(); i++) {
                        JSONObject jsonObj = infectInfoJson.getJSONObject(i);
                        // 感染症名
                        jsonObj.put("infection_name", this.getCodeName(getMstNames, "infectionNames", jsonObj.get("infection_cd")));
                    }
//                    patMainHistory.setInfect_info(infectInfoJson.toString());
                    List<InfectInfo> infectInfos = mapper.readValue(infectInfoJson.toString(), new TypeReference<List<InfectInfo>>() {});
                    patMainHistory.setInfect_info(infectInfos);

                    // インプラント情報を取得する。
//                    JSONArray implantInfoJson = this.getJSONArray(patMainHistory.getImplant_info());
                    JSONArray implantInfoJson = this.getJSONArray(patMainList.get(0).getImplant_info());
                    // インプラント情報
                    for (int i = 0; i < implantInfoJson.length(); i++) {
                        JSONObject jsonObj = implantInfoJson.getJSONObject(i);
                        // インプラント名
                        jsonObj.put("implant_name", this.getCodeName(getMstNames, "implantNames", jsonObj.get("implant_cd")));
                    }
//                    patMainHistory.setImplant_info(implantInfoJson.toString());
                    List<ImplantInfo> implantInfos = mapper.readValue(implantInfoJson.toString(), new TypeReference<List<ImplantInfo>>() {});
                    patMainHistory.setImplant_info(implantInfos);

                    // 共通診療情報を取得する。
//                    JSONObject medicalCareInfoJson = new JSONObject(patMainHistory.getMedical_care_info());
                    JSONObject medicalCareInfoJson = new JSONObject(patMainList.get(0).getMedical_care_info());
                    // 共通診療情報
                    // 主科名
                    medicalCareInfoJson.put("main_course_name", this.getCodeName(getMstNames, "courseNames", medicalCareInfoJson.get("main_course_cd")));
                    // 透析実施科名
                    medicalCareInfoJson.put("dialysis_course_name", this.getCodeName(getMstNames, "courseNames", medicalCareInfoJson.get("dialysis_course_cd")));
                    // 診療科連携コード
                    String courseHospitalCd = "";
                    if (!StringUtils.isEmpty(medicalCareInfoJson.get("main_course_cd").toString()) && !"null".equals(medicalCareInfoJson.get("main_course_cd").toString())) {
                        MstCourse mstCourse = mstCourseDao.selectByCd(Integer.parseInt(medicalCareInfoJson.get("main_course_cd").toString()));
                        courseHospitalCd = mstCourse.getInHospitalCd_1() != null ? mstCourse.getInHospitalCd_1() : "";
                    }
                    medicalCareInfoJson.put("main_in_hospital_cd_1", courseHospitalCd);
                    // 病棟名
                    medicalCareInfoJson.put("ward_name", this.getCodeName(getMstNames, "wardNames", medicalCareInfoJson.get("ward_cd")));
                    // 病棟名連携コード
                    String wardHospitalCd = "";
                    if (!StringUtils.isEmpty(medicalCareInfoJson.get("ward_cd").toString()) && !"null".equals(medicalCareInfoJson.get("ward_cd").toString())) {
                        MstWard mstWard = mstWardDao.selectByCd(Integer.parseInt(medicalCareInfoJson.get("ward_cd").toString()));
                        wardHospitalCd = mstWard.getInHospitalCd_1() != null ? mstWard.getInHospitalCd_1() : "";
                    }
                    medicalCareInfoJson.put("ward_in_hospital_cd_1", wardHospitalCd);
                    // 導入施設名
                    medicalCareInfoJson.put("facility_name", this.getCodeName(getMstNames, "sysFacilityNames", medicalCareInfoJson.get("facility_cd")));

//                    patMainHistory.setMedical_care_info(medicalCareInfoJson.toString());
                    MedicalCareInfo medicalCareInfos = mapper.readValue(medicalCareInfoJson.toString(), new TypeReference<MedicalCareInfo>() {});
                    patMainHistory.setMedical_care_info(medicalCareInfos);
                    List<WheelChairWithNameResponse> chair = this.createWheelChairListResponse(mstWheelChairDao.selectByPatId(patId, "1", "0"), facilityCd);
                    if (chair.size() > 0) {
                        // 個人所有車いす割当あり
                        patMainHistory.setWheel_chair_cd(chair.get(0).getWheelChairCd());
                        patMainHistory.setWheel_chair_name(chair.get(0).getWheelChairName());
                        patMainHistory.setWheel_chair_weight(chair.get(0).getWheelChairWeight());
                    }else if(patMainList.get(0).getWheel_chair_cd() != null){
                      // 共用車いす割当あり
                      MstWheelChair sharingChair = mstWheelChairDao.selectByWheelChairCd(patMainList.get(0).getWheel_chair_cd(), null, null);
                      if(sharingChair != null) {
                        patMainHistory.setWheel_chair_cd(sharingChair.getWheelChairCd());
                        patMainHistory.setWheel_chair_name(sharingChair.getWheelChairName());
                        patMainHistory.setWheel_chair_weight(sharingChair.getWheelChairWeight());
                      }
                    }
                    // 加算情報を取得する。
//                    JSONArray additionInfoJson = this.getJSONArray(patMainHistory.getAddition_info());
                    JSONArray additionInfoJson = this.getJSONArray(patMainList.get(0).getAddition_info());
                    // 加算情報
                    for (int i = 0; i < additionInfoJson.length(); i++) {
                        JSONObject jsonObj = additionInfoJson.getJSONObject(i);
                        // 加算・管理料コード名称
                        jsonObj.put("name", this.getCodeName(getMstNames, "additionNames", jsonObj.get("cd")));
                        // 加算形式
                        jsonObj.put("kind", this.getCodeName(getMstNames, "additionKinds", jsonObj.get("cd")));
                        // 最終算定日
                        jsonObj.put("last_date", this.getCodeName(getMstNames, "additionLastDates", jsonObj.get("cd")));
                    }
//                    patMainHistory.setAddition_info(additionInfoJson.toString());
                    List<AdditionInfo> additionInfos = mapper.readValue(additionInfoJson.toString(), new TypeReference<List<AdditionInfo>>() {});
                    patMainHistory.setAddition_info(additionInfos);

                    // 既往歴情報を取得する。
//                    JSONArray medicalHstInfoJson = this.getJSONArray(patUniqueHistory.getMedical_hst_info());
                    JSONArray medicalHstInfoJson = this.getJSONArray(patUnique.getMedical_hst_info());
                    String dialysisUnderlyingDisease = null;
                    // 既往歴情報
                    for (int i = 0; i < medicalHstInfoJson.length(); i++) {
                        JSONObject jsonObj = medicalHstInfoJson.getJSONObject(i);
                        if ("1".equals(jsonObj.get("is_dialysis_underlying_disease").toString()))
                            dialysisUnderlyingDisease = this.getCodeName(getMstNames, "diseaseNames", jsonObj.get("disease_cd"));
                    }
                    patMainHistory.setDialysis_underlying_disease(dialysisUnderlyingDisease);

                    // mod #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 start
//                    List<PatGroupInfo> patGroupInfos = mapper.readValue(patMainList.get(0).getPat_group_info(), new TypeReference<List<PatGroupInfo>>() {});
                    List<PatGroupCustomForPg> patGroupCustomForPgs = new ArrayList<>();
                    List<PatGroupInfo> patGroupInfos = new ArrayList<>();
                    if(StringUtils.hasLength(patMainList.get(0).getPat_group_info())){
                      patGroupCustomForPgs = mapper.readValue(patMainList.get(0).getPat_group_info(), new TypeReference<>() {});
                    }
                    for (int i = 0; i < patGroupCustomForPgs.size(); i++) {
                      AtomicInteger atomicInteger = new AtomicInteger(1);
                      PatGroupInfo patGroupInfo = new PatGroupInfo();
                      patGroupInfo.setCtl_no(atomicInteger.getAndIncrement());
                      patGroupInfo.setPat_group_cd(patGroupCustomForPgs.get(i).getPatGroupCd());
                      PatGroup patGroupOrg = patGroupDao.selectById(Long.valueOf(patGroupCustomForPgs.get(i).getPatGroupCd()), facilityCd);
                      patGroupInfo.setPat_group_name(patGroupOrg.getPatGroupName());
                      patGroupInfos.add(patGroupInfo);
                    }
                    // mod #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 end
                    patMainHistory.setPat_group_info(patGroupInfos);
                    List<PatMemoInfo> patMemoInfos = mapper.readValue(patMainList.get(0).getPat_memo_info(), new TypeReference<List<PatMemoInfo>>() {});
                    patMainHistory.setPat_memo_info(patMemoInfos);
                    List<TabooAllergyInfo> tabooAllergyInfos = mapper.readValue(patMainList.get(0).getTaboo_allergy_info(), new TypeReference<List<TabooAllergyInfo>>() {});
                    patMainHistory.setTaboo_allergy_info(tabooAllergyInfos);
                    // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 end
                    Query query = new Query();
                    Update update = new Update();
                    query.addCriteria(Criteria.where("pat_id").is(patIdStr));
                    query.addCriteria(Criteria.where("latest_flag").ne("off"));
                    update.set("latest_flag", "off");
                    mongoTemplate.updateMulti(query, update, PatMainHistory.class);
                    mongoTemplate.insert(patMainHistory);
                }
            } catch (DataAccessResourceFailureException exception) {
                MongoHealthCheckService.setMongoDBConnected(false);
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
              EventLogMessage eventLogMessageNew = new EventLogMessage();
              eventLogMessageNew.setLogMessage(ExcetionStackTraceToString(exception));
              logService.log(LogLevel.ERROR, eventLogMessageNew, "", LoggingConstant.SERVICE_NAME.FNSI, null);
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
            }
        } catch (Exception e) {
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
          EventLogMessage eventLogMessageNew = new EventLogMessage();
          eventLogMessageNew.setLogMessage(ExcetionStackTraceToString(e));
          logService.log(LogLevel.ERROR, eventLogMessageNew, "", LoggingConstant.SERVICE_NAME.FNSI, null);
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
        }
    }

    // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 start
    /**
     *
     * @param patPersonalMain
     * @param patMain
     * @param patUnique
     * @return Map<String MstName, Map<String MstKey, String MstName>>
     */
//    public Map<String, Map<String, String>> getMstNames(PatPersonalMainHistory patPersonalMainHistory,
//                                                        PatMainHistory patMainHistory,
//                                                        PatUniqueHistory patUniqueHistory){
    public Map<String, Map<String, String>> getMstNames(PatPersonalMain patPersonalMain,
                                                        PatMain patMain,
                                                        PatUnique patUnique){

        // 共通診療情報を取得する。
//        JSONObject medicalCareInfoJson = new JSONObject(patMainHistory.getMedical_care_info());
        JSONObject medicalCareInfoJson = new JSONObject(patMain.getMedical_care_info());

        // 既往歴情報を取得する。
//        JSONArray medicalHstInfoJson = this.getJSONArray(patUniqueHistory.getMedical_hst_info());
        JSONArray medicalHstInfoJson = this.getJSONArray(patUnique.getMedical_hst_info());

        // 入外・転入出情報を取得する。
//        JSONArray inoutVisitHistoryInfoJson = this.getJSONArray(patUniqueHistory.getIn_out_visit_history_info());
        JSONArray inoutVisitHistoryInfoJson = this.getJSONArray(patUnique.getIn_out_visit_history_info());

        // 身体情報を取得する。
//        JSONArray physicalInfoJson = this.getJSONArray(patUniqueHistory.getPhysical_info());
        JSONArray physicalInfoJson = this.getJSONArray(patUnique.getPhysical_info());

        // 感染症情報を取得する。
//        JSONArray infectInfoJson = this.getJSONArray(patMainHistory.getInfect_info());
        JSONArray infectInfoJson = this.getJSONArray(patMain.getInfect_info());

        // インプラント情報を取得する。
//        JSONArray implantInfoJson = this.getJSONArray(patMainHistory.getImplant_info());
        JSONArray implantInfoJson = this.getJSONArray(patMain.getImplant_info());

        // 担当スタッフ情報を取得する。
//        JSONArray chargeStaffInfoJson = this.getJSONArray(patMainHistory.getCharge_staff_info());
        JSONArray chargeStaffInfoJson = this.getJSONArray(patMain.getCharge_staff_info());

        // 透析困難情報を取得する。
//        JSONArray dialDiffComInfoJson = this.getJSONArray(patPersonalMainHistory.getDial_diff_com_info());
        JSONArray dialDiffComInfoJson = this.getJSONArray(patPersonalMain.getDial_diff_com_info());
        // add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe start
        // 加算
//        JSONArray additionInfoJson = this.getJSONArray(patMainHistory.getAddition_info());
        JSONArray additionInfoJson = this.getJSONArray(patMain.getAddition_info());
        // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 end
        // add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe end
        // 施設
        List<String> facilitys = new ArrayList<>();

        // 施設施設
        List<String> favoriteFacilitys = new ArrayList<>();

        // 病名マス
        List<Integer> diseases = new ArrayList<>();

        // 診療科
        List<Integer> courses = new ArrayList<>();

        // 感染症
        List<Integer> infections = new ArrayList<>();

        // インプラント
        List<Integer> implants = new ArrayList<>();

        // 病棟
        List<Integer> wards = new ArrayList<>();

        // 利用者
        List<Integer> personalUsers = new ArrayList<>();

        // 重症度
//        List<String> severitys = new ArrayList<>();
        List<Integer> severitys = new ArrayList<>();

        // 搬送区分
//        List<String> transports = new ArrayList<>();
        List<Integer> transports = new ArrayList<>();

        // 透析困難情報
        List<Integer> mstDialysisDifficulties = new ArrayList<>();
        // add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe start
        // 加算
        List<Integer> additions = new ArrayList<>();
        // add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe end
        // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 start
        // 登録施設名
//        facilitys.add(patPersonalMainHistory.getFacility_cd());
        facilitys.add(patPersonalMain.getFacility_cd());

        // 登録施設名
//        facilitys.add(patMainHistory.getFacility_cd());
        facilitys.add(patMain.getFacility_cd());
        // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 end

        // 導入施設名
        favoriteFacilitys.add(this.getCode(medicalCareInfoJson, "facility_cd", String.class));

        // 登録施設名
        facilitys.addAll(this.getJsonObjCodeStr(medicalHstInfoJson, "facility_cd"));

        // 施設施設名
        favoriteFacilitys.addAll(this.getJsonObjCodeStr(medicalHstInfoJson, "diagnosis_facility_cd"));

        // 登録施設名
        facilitys.addAll(this.getJsonObjCodeStr(inoutVisitHistoryInfoJson, "facility_cd"));

        // 施設名
        facilitys.addAll(this.getJsonObjCodeStr(physicalInfoJson, "facility_cd"));

        // 死因
        Integer dieCd = null;
        // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 start
//        if (patPersonalMainHistory.getDie_cd() != null && !"".equals(patPersonalMainHistory.getDie_cd())) {
        if (patPersonalMain.getDie_cd() != null && !"".equals(patPersonalMain.getDie_cd())) {
//            dieCd = Integer.valueOf(patPersonalMainHistory.getDie_cd());
            dieCd = Integer.valueOf(patPersonalMain.getDie_cd());
        }
        diseases.add(this.getCode(dieCd, Integer.class));

        // 原疾患
//        diseases.add(this.getCode(patPersonalMainHistory.getPrimary_disease_cd(), Integer.class));
        diseases.add(this.getCode(patPersonalMain.getPrimary_disease_cd(), Integer.class));
        // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 end

        // 病名マスタ.病名
        diseases.addAll(this.getJsonObjCodeInt(medicalHstInfoJson, "disease_cd"));

        // 主科名
        courses.add(this.getCode(medicalCareInfoJson, "main_course_cd", Integer.class));

        // 透析実施科名
        courses.add(this.getCode(medicalCareInfoJson, "dialysis_course_cd", Integer.class));

        // 診療科名
        courses.addAll(this.getJsonObjCodeInt(medicalHstInfoJson, "course_cd"));

        // 感染症名
        infections.addAll(this.getJsonObjCodeInt(infectInfoJson, "infection_cd"));

        // インプラント名
        implants.addAll(this.getJsonObjCodeInt(implantInfoJson, "implant_cd"));

        // 病棟名
        wards.add(this.getCode(medicalCareInfoJson, "ward_cd", Integer.class));

        // 指示者
        personalUsers.addAll(this.getJsonObjCodeInt(physicalInfoJson, "indicator_cd"));

        // スタッフ
        personalUsers.addAll(this.getJsonObjCodeInt(chargeStaffInfoJson, "staff_cd"));

        // 診断医名
        personalUsers.addAll(this.getJsonObjCodeInt(medicalHstInfoJson, "diagnostician_cd"));

        // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 start
        // 重症度名
//        severitys.add(this.getCode(patPersonalMainHistory.getSeverity_cd(), String.class));
        severitys.add(this.getCode(patPersonalMain.getSeverity_cd(), Integer.class));

        // 搬送区分
//        transports.add(this.getCode(patPersonalMainHistory.getTransport_cd(), String.class));
        transports.add(this.getCode(patPersonalMain.getTransport_cd(), Integer.class));
        // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 end

        // 透析困難名
        mstDialysisDifficulties.addAll(this.getJsonObjCodeInt(dialDiffComInfoJson, "dial_diff_cd"));

        // add #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen start
        if (inoutVisitHistoryInfoJson != null && inoutVisitHistoryInfoJson.length() != 0) {
            for (int i = 0; i < inoutVisitHistoryInfoJson.length(); i++) {
                String moveInOut = this.getCode(inoutVisitHistoryInfoJson.getJSONObject(i), "move_in_out", String.class);
                // 元施設
                String fromFacility = this.getCode(inoutVisitHistoryInfoJson.getJSONObject(i), "from_facility", String.class);
                // 先施設
                String toFacility = this.getCode(inoutVisitHistoryInfoJson.getJSONObject(i), "to_facility", String.class);

                switch (moveInOut) {
                    case "3":
                    case "4":
                    case "5":
                    case "9":
                        // 元施設
                        facilitys.add(fromFacility);
                        // 先施設
                        favoriteFacilitys.add(toFacility);
                        break;
                    case "1":
                    case "2":
                    case "6":
                    case "7":
                    case "8":
                    case "10":
                        // 元施設
                        favoriteFacilitys.add(fromFacility);
                        // 先施設
                        facilitys.add(toFacility);
                        break;
                }
            }
        }

        // 元科
        courses.addAll(this.getJsonObjCodeInt(inoutVisitHistoryInfoJson, "from_course"));

        // 元施設医
        personalUsers.addAll(this.getJsonObjCodeInt(inoutVisitHistoryInfoJson, "from_doctor"));

        // 元医療機関
        List<String> medicalInstitutionCds = new ArrayList<>();
        medicalInstitutionCds.addAll(this.getJsonObjCodeStr(inoutVisitHistoryInfoJson, "from_medicalInstitutionCd"));

        // 先科
        courses.addAll(this.getJsonObjCodeInt(inoutVisitHistoryInfoJson, "to_course"));

        // 先施設医
        personalUsers.addAll(this.getJsonObjCodeInt(inoutVisitHistoryInfoJson, "to_doctor"));

        // 先医療機関
        medicalInstitutionCds.addAll(this.getJsonObjCodeStr(inoutVisitHistoryInfoJson, "to_medicalInstitutionCd"));
        // add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe start
        //加算
        additions.addAll(getJsonObjCodeInt(additionInfoJson, "cd"));
        // add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe end
        // 全施設マスタ情報を取得する。→→→→→→　Map<String MedicalInstitutionCd, String FacilityName>
        Map<String, String> medicalInstitutionNames = new HashMap<>();
        medicalInstitutionCds = this.cleanStrLst(medicalInstitutionCds);
        if (diseases.size() > 0) {
            sysFacilityDao.selectAllName(medicalInstitutionCds).stream()
                    .collect(Collectors.toMap(SysFacility::getMedicalInstitutionCd, SysFacility::getFacilityName))
                    .forEach((key, value) -> medicalInstitutionNames.put(String.valueOf(key), value));
        }
        // add #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen end

        // 施設マスタ情報を取得する。→→→→→→　Map<String FacilityCd, String FacilityName>
        Map<String, String> facilityNames = mstFacilityDao.selectNamesByCd(this.cleanStrLst(facilitys)).stream()
                .collect(Collectors.toMap(MstFacility::getFacilityCd, MstFacility::getFacilityName));

        // 病名マスタ情報を取得する。→→→→→→　Map<String DiseaseCd, String DiseaseName>
        Map<String, String> diseaseNames = new HashMap<>();
        diseases = this.cleanIntLst(diseases);
        if (diseases.size() > 0) {
            mstDiseaseDao.selectAllName(diseases).stream()
                    .collect(Collectors.toMap(MstDisease::getDiseaseCd, MstDisease::getDiseaseName))
                    .forEach((key, value) -> diseaseNames.put(String.valueOf(key), value));
        }

        // 診療科マスタ情報を取得する。→→→→→→　Map<String CourseCd, String CourseName>
        Map<String, String> courseNames = new HashMap<String, String>();
        courses = this.cleanIntLst(courses);
        if (courses.size() > 0) {
            mstCourseDao.selectAllName(courses).stream()
                    .collect(Collectors.toMap(MstCourse::getCourseCd, MstCourse::getCourseName))
                    .forEach((key, value) -> courseNames.put(String.valueOf(key), value));
        }

        // 感染症マスタ情報を取得する。→→→→→→　Map<String InfectionCd, String InfectionName>
        Map<String, String> infectionNames = new HashMap<String, String>();
        infections = this.cleanIntLst(infections);
        if (infections.size() > 0) {
            mstInfectionDao.selectAllName(infections).stream()
                    .collect(Collectors.toMap(MstInfection::getInfectionCd, MstInfection::getInfectionName))
                    .forEach((key, value) -> infectionNames.put(String.valueOf(key), value));
        }

        // インプラント情報を取得する。→→→→→→　Map<String InfectionCd, String InfectionName>
        Map<String, String> implantNames = new HashMap<String, String>();
        implants = this.cleanIntLst(implants);
        if (implants.size() > 0) {
            mstImplantDao.selectAllName(implants).stream()
                    .collect(Collectors.toMap(MstImplant::getImplantCd, MstImplant::getImplantName))
                    .forEach((key, value) -> implantNames.put(String.valueOf(key), value));
        }

        // 病棟マスタ情報を取得する。→→→→→→　Map<String WardCd, String WardName>
        Map<String, String> wardNames = new HashMap<String, String>();
        wards = this.cleanIntLst(wards);
        if (wards.size() > 0) {
            mstWardDao.selectAllName(wards).stream()
                    .collect(Collectors.toMap(MstWard::getWardCd, MstWard::getWardName))
                    .forEach((key, value) -> wardNames.put(String.valueOf(key), value));
        }

        // 利用者マスタ情報を取得する。→→→→→→　Map<String UserId, String UserFirstName+UserLastName>
        Map<String, String> personalUserNames = new HashMap<>();
        personalUsers = this.cleanIntLst(personalUsers);
        if (personalUsers.size() > 0) {
            mstPersonalUserDao.selectAllName(personalUsers).stream()
                    .collect(Collectors.toMap(MstPersonalUser::getUserId, MstPersonalUser::getUserName))
                    .forEach((key, value) -> personalUserNames.put(String.valueOf(key), value));
        }

        // 重症度マスタ情報を取得する。→→→→→→　Map<String SeverityCd, String SeverityName>
        Map<String, String> severityNames = new HashMap<String, String>();
        List<Integer> severitysInt = new ArrayList<>();
        severitys.stream().distinct().filter(Objects::nonNull).collect(Collectors.toList())
                .forEach(item -> severitysInt.add(Integer.valueOf(item)));
        if (severitys.size() > 0) {
            mstSeverityDao.selectAllName(severitysInt).stream()
                    .collect(Collectors.toMap(MstSeverity::getSeverityCd, MstSeverity::getSeverityName))
                    .forEach((key, value) -> severityNames.put(String.valueOf(key), value));
        }

        // 搬送区分マスタ情報を取得する。→→→→→→　Map<String TransportCd, String TransportName>
        Map<String, String> transportNames = new HashMap<String, String>();
        List<Integer> transportsInt = new ArrayList<>();
        transports.stream().distinct().filter(Objects::nonNull).collect(Collectors.toList())
                .forEach(item -> transportsInt.add(Integer.valueOf(item)));
        if (transports.size() > 0) {
            mstTransportDao.selectAllName(transportsInt).stream()
                    .collect(Collectors.toMap(MstTransport::getTransportCd, MstTransport::getTransportName))
                    .forEach((key, value) -> transportNames.put(String.valueOf(key), value));
        }

        // 透析困難情報を取得する。→→→→→→　Map<String TransportCd, String TransportName>
        Map<String, String> mstDialysisDifficultyNames = new HashMap<String, String>();
        mstDialysisDifficulties = this.cleanIntLst(mstDialysisDifficulties);
        if (mstDialysisDifficulties.size() > 0) {
            mstDialysisDifficultyDao.selectAllName(mstDialysisDifficulties).stream()
                    .collect(Collectors.toMap(MstDialysisDifficulty::getDialysisDifficultyCd, MstDialysisDifficulty::getDialysisDifficultyName))
                    .forEach((key, value) -> mstDialysisDifficultyNames.put(String.valueOf(key), value));
        }

        // 施設施設を取得する。→→→→→→　Map<String MedicalInstitutionCd, String MedicalInstitutionName>
        Map<String, String> sysFacilityNames = new HashMap<String, String>();
        favoriteFacilitys = this.cleanStrLst(favoriteFacilitys);
        if (favoriteFacilitys.size() > 0) {
            mstFavoriteFacilityDao.selectAllName(favoriteFacilitys).stream()
                    .collect(Collectors.toMap(MstFavoriteFacilityData::getMedicalInstitutionCd, MstFavoriteFacilityData::getFavoriteFacilityName))
                    .forEach((key, value) -> sysFacilityNames.put(key, value));
        }
        // add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe start
        // 加算マスタ情報を取得する。→→→→→→　Map<String AdditionCd, String AdditionName>
        Map<String, String> additionNames = new HashMap<String, String>();
        Map<String, String> additionKinds = new HashMap<String, String>();
        Map<String, String> additionLastDates = new HashMap<String, String>();
        additions = this.cleanIntLst(additions);
        if (additions.size() > 0) {
            mstAdditionDao.selectAllName(additions).stream()
                    .collect(Collectors.toMap(MstAddition::getAdditionCd, MstAddition::getAdditionName))
                    .forEach((key, value) -> additionNames.put(String.valueOf(key), value));
            mstAdditionDao.selectAllName(additions).stream()
                    .collect(Collectors.toMap(MstAddition::getAdditionCd, MstAddition::getAdditionKind))
                    .forEach((key, value) -> additionKinds.put(String.valueOf(key), value));
            String date = null;
            // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 start
//            ordMainDao.selectCalculationDateList(null, patMainHistory.getFacility_cd(), Long.parseLong(patMainHistory.getPat_id()), date).stream()
            ordMainDao.selectCalculationDateList(null, patMain.getFacility_cd(), patMain.getPat_id(), date).stream()
                    .collect(Collectors.toMap(AdditionInfoOrdMain::getCd, AdditionInfoOrdMain::getLast_date))
                    .forEach((key, value) -> additionLastDates.put(String.valueOf(key), value));
            // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 end
        }
        // add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe end
        Map<String, Map<String, String>> names = new HashMap<>();
        names.put("facilityNames", facilityNames);
        names.put("diseaseNames", diseaseNames);
        names.put("courseNames", courseNames);
        names.put("infectionNames", infectionNames);
        names.put("implantNames", implantNames);
        names.put("wardNames", wardNames);
        names.put("personalUserNames", personalUserNames);
        names.put("severityNames", severityNames);
        names.put("transportNames", transportNames);
        names.put("mstDialysisDifficultyNames", mstDialysisDifficultyNames);
        names.put("sysFacilityNames", sysFacilityNames);

        // add #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen start
        names.put("medicalInstitutionNames", medicalInstitutionNames);
        // add #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen end
        // add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe start
        names.put("additionNames", additionNames);
        names.put("additionKinds", additionKinds);
        names.put("additionLastDates", additionLastDates);
        // add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe end
        return names;
    }

    public String getCodeName(Map<String, Map<String, String>> codeMap, String mstName, Object code) {
        String name = "";
        String codeStr = code != null ? code.toString() : "";
        if (codeMap.get(mstName).get(codeStr) != null) {
            name = codeMap.get(mstName).get(codeStr);
        }
        return name;
    }

    public JSONArray getJSONArray(String json) {
        JSONArray jsonArray = new JSONArray();
        if (json != null) {
            jsonArray = new JSONArray(json);
        }
        return jsonArray;
    }

    public <T> T getCode(Object code, Class<T> clazz){
        if (code == null) {
            return null;
        } else if (Integer.class.equals(clazz)) {
            return clazz.cast((Integer) code);
        } else if (String.class.equals(clazz)) {
            return clazz.cast((String) code);
        } else {
            return null;
        }
    }

    public <T> T getCode(JSONObject obj, String code, Class<T> clazz){
        // add #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen start
        try {
            // add #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen end
            Object value = obj.get(code);
            if (value == null || value.equals(null)) {
                return null;
            } else if (Integer.class.equals(clazz)) {
                return clazz.cast((Integer) value);
            } else if (String.class.equals(clazz)) {
                return clazz.cast((String) value);
            } else {
                return null;
            }
            // add #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen start
        } catch (Exception e) {
            return null;
        }
        // add #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen end
    }

    public List<String> getJsonObjCodeStr(JSONArray jsonArray, String code){
        List<String> codeValue = new ArrayList<>();
        if (jsonArray != null && jsonArray.length() != 0) {
            for (int i = 0; i < jsonArray.length(); i++) {
                codeValue.add(this.getCode(jsonArray.getJSONObject(i), code, String.class));
            }
        }
        return codeValue;
    }

    public static List<Integer> getJsonObjCodeInt(JSONArray jsonArray, String code){
        List<Integer> codeValue = new ArrayList<>();
        if (jsonArray != null && jsonArray.length() != 0) {
            for (int i = 0; i < jsonArray.length(); i++) {
                JSONObject jsonObject = jsonArray.getJSONObject(i);
                Object value = jsonObject.get(code);
                if (value instanceof String) {
                    String valueStr = (String) value;
                    if(StringUtils.hasText(valueStr)){
                        if(org.apache.commons.lang3.StringUtils.isNumeric(valueStr)){
                            codeValue.add(Integer.valueOf(valueStr));
                        }else{
                            continue;
                        }
                    }
                } else if (value instanceof Integer) {
                    codeValue.add((Integer) value);
                } else {
                    continue;
                }
            }
        }
        return codeValue;
    }

    public List<String> cleanStrLst (List<String> lst) {
        return lst.stream().distinct().filter(Objects::nonNull).collect(Collectors.toList());
    }

    public List<Integer> cleanIntLst (List<Integer> lst) {
        return lst.stream().distinct().filter(Objects::nonNull).collect(Collectors.toList());
    }

    private List<WheelChairWithNameResponse> createWheelChairListResponse(List<MstWheelChair> chairs, String facilityCd) {

        List<Long> patIdList = chairs.stream().map(s -> s.getPatId()).distinct().collect(Collectors.toList());
        patIdList.removeAll(Collections.singleton(null)); // null削除
        // patIdListが0件の場合に患者ID条件なしでSQLが実行されることを回避する
        List<PatPersonalMain> pats = (patIdList.size() > 0)
                ? patPersonalMainDao.selectByIdListFacilityCd(patIdList, facilityCd)
                : new ArrayList<PatPersonalMain>();
        List<PatPersonalMain> pat;
        String patLastName = "";
        String patFirstName = "";
        List<WheelChairWithNameResponse> res = new ArrayList<>();
        for (MstWheelChair chair : chairs) {
            if (chair.getIsPersonal().equals("1")) {
                // 患者名取得
                pat = pats.stream().filter(p -> Objects.equals(p.getPat_id(), chair.getPatId())).collect(Collectors.toList());
                patLastName = "";
                patFirstName = "";
                if (pat.size() > 0) {
                    patLastName = pat.get(0).getPat_last_name();
                    patFirstName = pat.get(0).getPat_first_name();
                }
            }

            // 応答用構造体情報作成
            WheelChairWithNameResponse r = new WheelChairWithNameResponse(
                    chair.getWheelChairCd(), chair.getFacilityCd(), chair.getFnWheelChairCd(),
                    chair.getWheelChairName(), chair.getWheelChairWeight(), chair.getScaleDate(),
                    chair.getScaleUserId(), chair.getIsPersonal(), chair.getPatId(),
                    chair.getIsDisp(), chair.getIsDel(), patLastName, patFirstName);

            res.add(r);
        }
        return res;
    }
    //add #10632 装置設定画面の更新時にpat_main_historyがインサートされない 20240530 ztc end
}
// add #9811 装置設定>操作範囲>ヘマトクリットと総タンパクの検査値が不正 修正 20231113 ztc end
