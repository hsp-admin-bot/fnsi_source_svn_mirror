package jp.co.nikkiso.ntss.admin_web.service;

import jp.co.nikkiso.ntss.admin_web.constant.MstToMongoEnum;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.patHistory.PatMainHistory;
import jp.co.nikkiso.ntss.admin_web.service.patHistory.PatPersonalMainHistory;
import jp.co.nikkiso.ntss.admin_web.service.patHistory.PatUniqueHistory;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.MstUserAuthenticationDao;
import jp.co.nikkiso.ntss.core.dao.PatGroupDao;
import jp.co.nikkiso.ntss.core.dao.PatInsuranceDao;
import jp.co.nikkiso.ntss.core.dao.PatMainDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.entity.PatMain;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.utils.MongoHealthCheckService;
import org.apache.commons.lang3.StringUtils;
import org.bson.Document;
import org.json.JSONArray;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessResourceFailureException;
import org.springframework.data.mongodb.core.BulkOperations;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.core.query.Update;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.CollectionUtils;

import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;
import java.util.stream.StreamSupport;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

//add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 zhaoqi 20240228 start
// mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 start
@Service
public class MongoServiceImpl implements MongoService {

    @Autowired(required = false)
    MongoTemplate mongoTemplate;

    @Autowired
    PatMainDao patMainDao;

    @Autowired
    PatInsuranceDao patInsuranceDao;

    @Autowired
    PatPersonalMainDao patPersonalMainDao;

    @Autowired
    private PatGroupDao patGroupDao;

    @Autowired
    private LogService logService;

    @Autowired
    private MstUserAuthenticationDao mstUserAuthenticationDao;

    //add #11489 アカウント編集で保存しても処理中のまま zrx start
    private static final String[] strArryType = {
      "physical_info.indicator_cd",
      "medical_hst_info.facility_cd",
      "in_out_visit_history_info.facility_cd",
      "physical_info.facility_cd",
      "medical_hst_info.diagnosis_facility_cd",
      "in_out_visit_history_info.from_medicalInstitutionCd",
      "in_out_visit_history_info.to_medicalInstitutionCd",
      "in_out_visit_history_info.from_facility",
      "in_out_visit_history_info.to_facility",
      "die_cd"
    };
    //add #11489 アカウント編集で保存しても処理中のまま zrx end

    /**
     * mongodbに最新の患者情報を保存する。
     *
     * @param data               更新データ
     * @param masterPhysicalName マスタ物理名称
     * @param facilityCd         施設コード
     */
    @Override
    @Async
    @Transactional
    public void savePatDataToMongo(List<Map<String, Object>> data, String masterPhysicalName, String facilityCd) {
        MstToMongoEnum tableName = MstToMongoEnum.fromName(masterPhysicalName);

        Map<MstToMongoEnum, Runnable> mongoTasksMap = new HashMap<>();
        // 感染症マスタ
        mongoTasksMap.put(MstToMongoEnum.MSTINFECTION,
                () -> updateAndInsertPatMain(facilityCd, null, false, data, MstToMongoEnum.MSTINFECTION));
        // インプラントマスタ
        mongoTasksMap.put(MstToMongoEnum.MSTIMPLANT,
                () -> updateAndInsertPatMain(facilityCd, null, false, data, MstToMongoEnum.MSTIMPLANT));
        // 禁忌・アレルギーマスタ
        mongoTasksMap.put(MstToMongoEnum.MSTTABOOALLERY,
                () -> updateAndInsertPatMain(facilityCd, null, false, data, MstToMongoEnum.MSTTABOOALLERY));
        // 加算・管理料マスタ
        mongoTasksMap.put(MstToMongoEnum.MSTADDITION,
                () -> handleAdditionTasks(facilityCd, data));
//                () -> updateAndInsertPatMain(facilityCd, null, false, data, MstToMongoEnum.MSTADDITION));
        // 診療科マスタ
        mongoTasksMap.put(MstToMongoEnum.MSTCOURSE,
                () -> {
                    updateAndInsertPatMain(facilityCd, null, false, data, MstToMongoEnum.MSTCOURSE);
                    updateAndInsertPatUnique(facilityCd, data, MstToMongoEnum.MSTCOURSE);
                });
        // 病棟マスタ
        mongoTasksMap.put(MstToMongoEnum.MSTWARD,
                () -> updateAndInsertPatMain(facilityCd, null, false, data, MstToMongoEnum.MSTWARD));
        // 透析困難マスタ
        mongoTasksMap.put(MstToMongoEnum.MSTDIALYSISDIFFCULTY,
                () -> updateAndInsertPatPersonalMain(facilityCd, data, MstToMongoEnum.MSTDIALYSISDIFFCULTY));
        // 続柄マスタ
        mongoTasksMap.put(MstToMongoEnum.MSTRELATIONSHIP,
                () -> updateAndInsertPatPersonalMain(facilityCd, data, MstToMongoEnum.MSTRELATIONSHIP));
        // 搬送区分マスタ
        mongoTasksMap.put(MstToMongoEnum.MSTTRANSPORT,
                () -> updateAndInsertPatPersonalMain(facilityCd, data, MstToMongoEnum.MSTTRANSPORT));
        // 重症度マスタ
        mongoTasksMap.put(MstToMongoEnum.MSTSEVERITY,
                () -> updateAndInsertPatPersonalMain(facilityCd, data, MstToMongoEnum.MSTSEVERITY));
        // 病名マスタ
        mongoTasksMap.put(MstToMongoEnum.MSTDISEASE,
                () -> handleDiseaseTasks(facilityCd, data));
        // 全施設マスタ
        mongoTasksMap.put(MstToMongoEnum.SYSFACILITY,
                () -> handleSysfacilityTasks(data));

        if (mongoTasksMap.containsKey(tableName)) {
            mongoTasksMap.get(tableName).run();
        }
    }

    // 加算・管理料マスタ
    private void handleAdditionTasks(String facilityCd, List<Map<String, Object>> datas) {
        if (!CollectionUtils.isEmpty(datas)) {
            for(Map<String, Object> data : datas) {
                data.put("name",data.get("additionName"));
            }
            updateAndInsertPatMain(facilityCd, null, false, datas, MstToMongoEnum.MSTADDITION);
        }

    }
    // 病名マスタ
    private void handleDiseaseTasks(String facilityCd, List<Map<String, Object>> data) {
        updateAndInsertPatUnique(facilityCd, data, MstToMongoEnum.MSTDISEASE);
        updateAndInsertPatPersonalMain(facilityCd, data, MstToMongoEnum.MSTDISEASE);
        List<PatPersonalMain> patPersonalMainList = new ArrayList<>();
        List<Integer> diseaseCdList = new ArrayList<>();
        for (Map<String, Object> dataMap : data) {
            Integer diseaseCd = Integer.parseInt(dataMap.get("code").toString());
            diseaseCdList.add(diseaseCd);
        }
        if (!diseaseCdList.isEmpty()) {
            patPersonalMainList = patPersonalMainDao.selectAllByDieCdOrPrimaryDiseaseCd(facilityCd, diseaseCdList);
            if (!patPersonalMainList.isEmpty()) {
                Map<Long, List<Long>> patIdsAndMasterCds = patPersonalMainList.stream()
                        .collect(Collectors.groupingBy(
                                patPersonalMain -> Long.valueOf(patPersonalMain.getPrimary_disease_cd()),
                                Collectors.mapping(PatPersonalMain::getPat_id, Collectors.toList())
                        ));
                updateAndInsertPatMain(facilityCd, patIdsAndMasterCds, true, data, MstToMongoEnum.MSTDISEASE);
            }
        }
    }
    // 全施設マスタ
    private void handleSysfacilityTasks(List<Map<String, Object>> datas) {
        if (!CollectionUtils.isEmpty(datas)) {
            for(Map<String, Object> data : datas) {
                data.put("code",data.get("medicalInstitutionCd"));
                data.put("name",data.get("facilityName"));
            }
            updateAndInsertPatUnique(null, datas, MstToMongoEnum.SYSFACILITY);
            updateAndInsertPatMain(null, null, false, datas, MstToMongoEnum.SYSFACILITY);
        }
    }

    /**
     * mongoデータを更新し、pat_unique_historyに新しいデータを挿入する
     *
     * @param facilityCd     施設コード
     * @param updMasterInfos 更新データ
     * @param tableName      master table
     */
    //mod #11489 アカウント編集で保存しても処理中のまま zrx start
    public void updateAndInsertPatUnique(String facilityCd, List<Map<String, Object>> updMasterInfos, MstToMongoEnum tableName) {
        // Add #10532 MongoDBがダウン中の操作について（新患登録） zhao start
        try {
            if (MongoHealthCheckService.getMongoDBConnected()) {
                //add #10532 mongoDBがダウン中の操作について（新患登録） zhao end
                try {

                    long startTime = System.currentTimeMillis();
                    EventLogMessage eventLogMessageTemp = new EventLogMessage();

                    List<PatUniqueHistory> queryLastPatUniqueHistorys = new ArrayList<>();
                    List<PatUniqueHistory> insertPatUniqueHistorys = new ArrayList<>();
                    for (Map<String, Object> updMasterInfo : updMasterInfos) {
                        String masterCode = updMasterInfo.get("code").toString();
                        String codeToName = updMasterInfo.get("name").toString();
                        switch (tableName.get()) {
                            // 診療科マスタ
                            case "mst_course":
//                                queryLastPatUniqueHistorys.addAll(updateField(facilityCd, "in_out_visit_history_info.from_course",
//                                        "in_out_visit_history_info.$[elem].from_course_name", "pat_unique_history", Integer.parseInt(masterCode), codeToName, PatUniqueHistory.class));
//                                queryLastPatUniqueHistorys.addAll(updateField(facilityCd, "in_out_visit_history_info.to_course",
//                                        "in_out_visit_history_info.$[elem].to_course_name", "pat_unique_history", Integer.parseInt(masterCode), codeToName, PatUniqueHistory.class));
//                                queryLastPatUniqueHistorys.addAll(updateField(facilityCd, "medical_hst_info.course_cd",
//                                        "medical_hst_info.$[elem].course_name", "pat_unique_history", Integer.parseInt(masterCode), codeToName, PatUniqueHistory.class));
                              Map<String, String> msTCourseFieldsMap = new HashMap<>();
                              msTCourseFieldsMap.put("in_out_visit_history_info.from_course", "in_out_visit_history_info.$[elem].from_course_name");
                              msTCourseFieldsMap.put("in_out_visit_history_info.to_course", "in_out_visit_history_info.$[elem].to_course_name");
                              msTCourseFieldsMap.put("medical_hst_info.course_cd", "medical_hst_info.$[elem].course_name");
                              queryLastPatUniqueHistorys.addAll(queryField(facilityCd, msTCourseFieldsMap, Integer.parseInt(masterCode), PatUniqueHistory.class));
                              updateMultipleFields(facilityCd, msTCourseFieldsMap, "pat_unique_history", Integer.parseInt(masterCode), codeToName);
                                break;
                            // 病名マスタ
                            case "mst_disease":
                                queryLastPatUniqueHistorys.addAll(updateField(facilityCd, "medical_hst_info.disease_cd",
                                        "medical_hst_info.$[elem].disease_name", "pat_unique_history", Integer.parseInt(masterCode), codeToName, PatUniqueHistory.class));
                                break;
                            // 全施設マスタ
                            case "sys_facility":
//                                queryLastPatUniqueHistorys.addAll(updateField(null, "medical_hst_info.diagnosis_facility_cd",
//                                        "medical_hst_info.$[elem].diagnosis_facility_name", "pat_unique_history", masterCode, codeToName, PatUniqueHistory.class));
//                                queryLastPatUniqueHistorys.addAll(updateField(null, "in_out_visit_history_info.from_medicalInstitutionCd",
//                                        "in_out_visit_history_info.$[elem].from_medicalInstitution_name", "pat_unique_history", masterCode, codeToName, PatUniqueHistory.class));
//                                queryLastPatUniqueHistorys.addAll(updateField(null, "in_out_visit_history_info.to_medicalInstitutionCd",
//                                        "in_out_visit_history_info.$[elem].to_medicalInstitution_name", "pat_unique_history", masterCode, codeToName, PatUniqueHistory.class));
//                                queryLastPatUniqueHistorys.addAll(updateField(null, "in_out_visit_history_info.from_facility",
//                                        "in_out_visit_history_info.$[elem].from_facility_name", "pat_unique_history", masterCode, codeToName, PatUniqueHistory.class));
//                                queryLastPatUniqueHistorys.addAll(updateField(null, "in_out_visit_history_info.to_facility",
//                                        "in_out_visit_history_info.$[elem].to_facility_name", "pat_unique_history", masterCode, codeToName, PatUniqueHistory.class));
                                Map<String, String> sysFacilityFieldsMap = new HashMap<>();
                                sysFacilityFieldsMap.put("medical_hst_info.diagnosis_facility_cd", "medical_hst_info.$[elem].diagnosis_facility_name");
                                sysFacilityFieldsMap.put("in_out_visit_history_info.from_medicalInstitutionCd", "in_out_visit_history_info.$[elem].from_medicalInstitution_name");
                                sysFacilityFieldsMap.put("in_out_visit_history_info.to_medicalInstitutionCd", "in_out_visit_history_info.$[elem].to_medicalInstitution_name");
                                sysFacilityFieldsMap.put("in_out_visit_history_info.from_facility", "in_out_visit_history_info.$[elem].from_facility_name");
                                sysFacilityFieldsMap.put("in_out_visit_history_info.to_facility", "in_out_visit_history_info.$[elem].to_facility_name");
                                queryLastPatUniqueHistorys.addAll(queryField(null, sysFacilityFieldsMap, masterCode, PatUniqueHistory.class));
                                updateMultipleFields(null, sysFacilityFieldsMap, "pat_unique_history", masterCode, codeToName);
                                break;
                            // 利用者マスタ
//                          case "mst_user":
//                            queryLastPatUniqueHistorys.addAll(updateField(facilityCd, "medical_hst_info.diagnostician_cd",
//                              "medical_hst_info.$[elem].diagnostician_name", "pat_unique_history", Integer.parseInt(masterCode), codeToName, PatUniqueHistory.class));
//                            queryLastPatUniqueHistorys.addAll(updateField(facilityCd, "in_out_visit_history_info.from_doctor",
//                              "in_out_visit_history_info.$[elem].from_doctor_name", "pat_unique_history", Integer.parseInt(masterCode), codeToName, PatUniqueHistory.class));
//                            queryLastPatUniqueHistorys.addAll(updateField(facilityCd, "in_out_visit_history_info.to_doctor",
//                              "in_out_visit_history_info.$[elem].to_doctor_name", "pat_unique_history", Integer.parseInt(masterCode), codeToName, PatUniqueHistory.class));
//                            queryLastPatUniqueHistorys.addAll(updateField(facilityCd, "physical_info.indicator_cd",
//                              "physical_info.$[elem].indicator_name", "pat_unique_history", masterCode, codeToName, PatUniqueHistory.class));
//                            break;
                            case "mst_user":
                              Map<String, String> mstUserFieldsMap = new HashMap<>();
                              mstUserFieldsMap.put("medical_hst_info.diagnostician_cd", "medical_hst_info.$[elem].diagnostician_name");
                              mstUserFieldsMap.put("in_out_visit_history_info.from_doctor", "in_out_visit_history_info.$[elem].from_doctor_name");
                              mstUserFieldsMap.put("in_out_visit_history_info.to_doctor", "in_out_visit_history_info.$[elem].to_doctor_name");
                              mstUserFieldsMap.put("physical_info.indicator_cd", "physical_info.$[elem].indicator_name");
                              queryLastPatUniqueHistorys.addAll(queryField(facilityCd, mstUserFieldsMap, Integer.parseInt(masterCode),  PatUniqueHistory.class));
                              updateMultipleFields(facilityCd, mstUserFieldsMap, "pat_unique_history", Integer.parseInt(masterCode), codeToName);
                              break;
                            // 施設マスタ
                            case "mst_facility":
//                                queryLastPatUniqueHistorys.addAll(updateField(null, "medical_hst_info.facility_cd",
//                                        "medical_hst_info.$[elem].facility_name", "pat_unique_history", masterCode, codeToName, PatUniqueHistory.class));
//                                queryLastPatUniqueHistorys.addAll(updateField(null, "in_out_visit_history_info.facility_cd",
//                                        "in_out_visit_history_info.$[elem].facility_name", "pat_unique_history", masterCode, codeToName, PatUniqueHistory.class));
//                                queryLastPatUniqueHistorys.addAll(updateField(null, "physical_info.facility_cd",
//                                        "physical_info.$[elem].facility_name", "pat_unique_history", masterCode, codeToName, PatUniqueHistory.class));
                                Map<String, String> mstFacilityFieldsMap = new HashMap<>();
                                mstFacilityFieldsMap.put("medical_hst_info.facility_cd", "medical_hst_info.$[elem].facility_name");
                                mstFacilityFieldsMap.put("in_out_visit_history_info.facility_cd", "in_out_visit_history_info.$[elem].facility_name");
                                mstFacilityFieldsMap.put("physical_info.facility_cd", "physical_info.$[elem].facility_name");
                                queryLastPatUniqueHistorys.addAll(queryField(null, mstFacilityFieldsMap, masterCode, PatUniqueHistory.class));
                                updateMultipleFields(null, mstFacilityFieldsMap, "pat_unique_history", masterCode, codeToName);
                                break;

                            default:
                                break;
                        }
                    }

                    eventLogMessageTemp.setLogMessage( "$$$$$$ update " + tableName.get() + " master used time: " + (System.currentTimeMillis() - startTime) / 1000.0 + "秒");
                    logService.log(LogLevel.INFO, eventLogMessageTemp, null, LoggingConstant.MODULE_NAME.ADMIN_WEB, null);
                    startTime = System.currentTimeMillis();

                    if (!CollectionUtils.isEmpty(queryLastPatUniqueHistorys)) {
                        for (PatUniqueHistory source : queryLastPatUniqueHistorys) {
                            PatUniqueHistory target = new PatUniqueHistory();
                            BeanUtils.copyProperties(source, target, "_id");
                            target.setLatest_flag("off");
                            insertPatUniqueHistorys.add(target);
                        }
                        mongoTemplate.insertAll(insertPatUniqueHistorys);
                    }

                    eventLogMessageTemp.setLogMessage( "###### insert " + tableName.get() + " master used time: " + (System.currentTimeMillis() - startTime) / 1000.0 + "秒");
                    logService.log(LogLevel.INFO, eventLogMessageTemp, null, LoggingConstant.MODULE_NAME.ADMIN_WEB, null);

                } catch (Exception e) {
                    EventLogMessage eventLogMessage = new EventLogMessage();
                  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
                  eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
                  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
                    eventLogMessage.setFacilityCd(facilityCd);
                    logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.MODULE_NAME.ADMIN_WEB, null);
                }
                //add #10532 mongoDBがダウン中の操作について（新患登録） zhao start
            }
        } catch (DataAccessResourceFailureException exception) {
            MongoHealthCheckService.setMongoDBConnected(false);
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//            exception.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(exception));
          if (!StringUtils.isEmpty(facilityCd)) {
            eventLogMessage.setFacilityCd(facilityCd);
          }
          logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
        }
        //add #10532 mongoDBがダウン中の操作について（新患登録） zhao end
    }
    //mod #11489 アカウント編集で保存しても処理中のまま zrx end

    /**
     * データを更新し、pat_main_historyに新しいデータを挿入する
     *
     * @param facilityCd         施設コード
     * @param patIdsAndMasterCds 患者関連病名コード関係
     * @param changeNameOrNot    単一フィールド名フラグの更新
     * @param updMasterInfos     更新データ
     * @param tableName          master table
     */
    @Override
//    @Async
    @Transactional
    public void updateAndInsertPatMain(String facilityCd, Map<Long, List<Long>> patIdsAndMasterCds, Boolean changeNameOrNot,
                                       List<Map<String, Object>> updMasterInfos, MstToMongoEnum tableName) {
        //add #10532 mongoDBがダウン中の操作について（新患登録） zhao start
        try {
            if (MongoHealthCheckService.getMongoDBConnected()) {
                //add #10532 mongoDBがダウン中の操作について（新患登録） zhao end
                try {
                    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                    Timestamp now = new Timestamp(new Date().getTime());

                    Update update = new Update();
                    update.set("ins_date", now);
                    update.set("reg_date", sdf.format(now));
                    update.set("up_date", sdf.format(now));

                    List<PatMainHistory> queryLastPatMainHistorys  = new ArrayList<>();
                    if (changeNameOrNot) {

                        long startTime = System.currentTimeMillis();
                        EventLogMessage eventLogMessageTemp = new EventLogMessage();

                        // 病名マスタ
                        if ("mst_disease".equals(tableName.get())) {
                            patIdsAndMasterCds.forEach((diseaseCds, patIdList) -> {
                                Long diseaseCodeLong = diseaseCds;
                                Optional<Map<String, Object>> updMasterInfo = updMasterInfos.stream().filter(
                                        mInfo -> mInfo.get("code").equals(diseaseCodeLong)
                                ).findFirst();
                                if (updMasterInfo.isPresent()) {
                                    Query query = new Query();
                                    query.addCriteria(Criteria.where("facility_cd").is(facilityCd)
                                            .and("pat_id").in(patIdList.stream()
                                                    .map(String::valueOf)
                                                    .collect(Collectors.toList()))
                                            .and("latest_flag").is("on"));
                                    queryLastPatMainHistorys.addAll(mongoTemplate.find(query, PatMainHistory.class));
                                    update.set("dialysis_underlying_disease", updMasterInfo.get().get("name").toString());
                                    mongoTemplate.updateMulti(query, update, "pat_main_history");
                                }
                            });
                        }
                        // 患者メモマスタ
                        if ("mst_pat_memo".equals(tableName.get())) {
                            List<PatMain> patMainList = patMainDao.selectByFacilityCd(facilityCd);
                            for (PatMain patMain : patMainList) {
                                String patMemoInfo = patMain.getPat_memo_info();
                                if (patMemoInfo != null && !patMemoInfo.isEmpty()) {
                                    JSONArray patMemoInfoJsonArray = new JSONArray(patMemoInfo);
                                    List<Document> patMemoInfoDocuments = StreamSupport.stream(patMemoInfoJsonArray.spliterator(), false)
                                            .map(Object::toString)
                                            .map(Document::parse)
                                            .collect(Collectors.toList());
                                    Query query = new Query();
                                    query.addCriteria(Criteria.where("facility_cd").is(facilityCd)
                                            .and("pat_id").is(patMain.getPat_id().toString())
                                            .and("latest_flag").is("on"));
                                    queryLastPatMainHistorys.addAll(mongoTemplate.find(query, PatMainHistory.class));
                                    update.set("pat_memo_info", patMemoInfoDocuments);
                                    // 执行更新操作
                                    mongoTemplate.updateMulti(query, update, "pat_main_history");
                                }
                            }
                        }

                        eventLogMessageTemp.setLogMessage( "$$$$$$ update " + tableName.get() + " master used time: " + (System.currentTimeMillis() - startTime) / 1000.0 + "秒");
                        logService.log(LogLevel.INFO, eventLogMessageTemp, null, LoggingConstant.MODULE_NAME.ADMIN_WEB, null);
                        startTime = System.currentTimeMillis();

                        insertPatMainHistorysTasks(queryLastPatMainHistorys);

                        eventLogMessageTemp.setLogMessage( "###### insert " + tableName.get() + " master used time: " + (System.currentTimeMillis() - startTime) / 1000.0 + "秒");
                        logService.log(LogLevel.INFO, eventLogMessageTemp, null, LoggingConstant.MODULE_NAME.ADMIN_WEB, null);

                    }
                    else {

                        long startTime = System.currentTimeMillis();
                        EventLogMessage eventLogMessageTemp = new EventLogMessage();

                        for (Map<String, Object> updMasterInfo : updMasterInfos) {
                            String masterCode = updMasterInfo.get("code").toString();
                            String codeToName = updMasterInfo.get("name").toString();

                            switch (tableName.get()) {
                                // 感染症マスタ
                                case "mst_infection":
                                    queryLastPatMainHistorys.addAll(updateField(facilityCd, "infect_info.infection_cd", "infect_info.$[elem].infection_name",
                                            "pat_main_history", Integer.parseInt(masterCode), codeToName, PatMainHistory.class));
                                    break;
                                // インプラントマスタ
                                case "mst_implant":
                                    queryLastPatMainHistorys.addAll(updateField(facilityCd, "implant_info.implant_cd", "implant_info.$[elem].implant_name",
                                            "pat_main_history", Integer.parseInt(masterCode), codeToName, PatMainHistory.class));
                                    break;
                                // 禁忌・アレルギーマスタ
                                case "mst_taboo_allergy":
                                    queryLastPatMainHistorys.addAll(updateField(facilityCd, "taboo_allergy_info.taboo_allergy_cd", "taboo_allergy_info.$[elem].content",
                                            "pat_main_history", masterCode, codeToName, PatMainHistory.class));
                                    break;
                                // 加算・管理料マスタ
                                case "mst_addition":
                                    queryLastPatMainHistorys.addAll(updateField(facilityCd, "addition_info.cd", "addition_info.$[elem].name",
                                            "pat_main_history", Integer.parseInt(masterCode), codeToName, PatMainHistory.class));
                                    break;
                                // 診療科マスタ
                                case "mst_course":
                                    //mod #11489 アカウント編集で保存しても処理中のまま zrx start
//                                    queryLastPatMainHistorys.addAll(updateField(facilityCd, "medical_care_info.main_course_cd", "medical_care_info.main_course_name",
//                                            "pat_main_history", Integer.parseInt(masterCode), codeToName, PatMainHistory.class));
//                                    queryLastPatMainHistorys.addAll(updateField(facilityCd, "medical_care_info.dialysis_course_cd", "medical_care_info.dialysis_course_name",
//                                            "pat_main_history", Integer.parseInt(masterCode), codeToName, PatMainHistory.class));
                                    Map<String, String> mstCourseFieldsMap = new HashMap<>();
                                    mstCourseFieldsMap.put("medical_care_info.main_course_cd", "medical_care_info.main_course_name");
                                    mstCourseFieldsMap.put("medical_care_info.dialysis_course_cd", "medical_care_info.dialysis_course_name");
                                    queryLastPatMainHistorys.addAll(queryField(facilityCd, mstCourseFieldsMap, Integer.parseInt(masterCode), PatMainHistory.class));
                                    updateMultipleFields(facilityCd, mstCourseFieldsMap, "pat_main_history", Integer.parseInt(masterCode), codeToName);
                                    //mod #11489 アカウント編集で保存しても処理中のまま zrx end
                                    break;
                                // 病棟マスタ
                                case "mst_ward":
                                    queryLastPatMainHistorys.addAll(updateField(facilityCd, "medical_care_info.ward_cd", "medical_care_info.ward_name",
                                            "pat_main_history", Integer.parseInt(masterCode), codeToName, PatMainHistory.class));
                                    break;
                                // 利用者マスタ
                                case "mst_user":
                                    queryLastPatMainHistorys.addAll(updateField(facilityCd, "charge_staff_info.staff_cd", "charge_staff_info.$[elem].staff_name",
                                            "pat_main_history", Integer.parseInt(masterCode), codeToName, PatMainHistory.class));
                                    break;
                                // 施設マスタ
                                case "mst_facility":
                                    queryLastPatMainHistorys.addAll(updateField(null, "facility_cd", "facility_name",
                                            "pat_main_history", masterCode, codeToName, PatMainHistory.class));
                                    break;
                                case "sys_facility":
                                    queryLastPatMainHistorys.addAll(updateField(null, "medical_care_info.facility_cd", "medical_care_info.facility_name",
                                            "pat_main_history", masterCode, codeToName, PatMainHistory.class));
                                    break;

                                default:
                                    break;
                            }
                        }

                        eventLogMessageTemp.setLogMessage( "$$$$$$ update " + tableName.get() + " master used time: " + (System.currentTimeMillis() - startTime) / 1000.0 + "秒");
                        logService.log(LogLevel.INFO, eventLogMessageTemp, null, LoggingConstant.MODULE_NAME.ADMIN_WEB, null);
                        startTime = System.currentTimeMillis();

                        insertPatMainHistorysTasks(queryLastPatMainHistorys);

                        eventLogMessageTemp.setLogMessage( "###### insert " + tableName.get() + " master used time: " + (System.currentTimeMillis() - startTime) / 1000.0 + "秒");
                        logService.log(LogLevel.INFO, eventLogMessageTemp, null, LoggingConstant.MODULE_NAME.ADMIN_WEB, null);

                    }
                } catch (Exception e) {
                    EventLogMessage eventLogMessage = new EventLogMessage();
                  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
                  eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
                  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
                    eventLogMessage.setFacilityCd(facilityCd);
                    logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.MODULE_NAME.ADMIN_WEB, null);
                }
                //add #10532 mongoDBがダウン中の操作について（新患登録） zhao start
            }
        } catch (DataAccessResourceFailureException exception) {
            MongoHealthCheckService.setMongoDBConnected(false);
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//            exception.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(exception));
          if (!StringUtils.isEmpty(facilityCd)) {
            eventLogMessage.setFacilityCd(facilityCd);
          }
          logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
        }
        //add #10532 mongoDBがダウン中の操作について（新患登録） zhao end
    }

    public void insertPatMainHistorysTasks(List<PatMainHistory> queryLastPatMainHistorys) {
        List<PatMainHistory> insertPatMainHistorys  = new ArrayList<>();
        if (!CollectionUtils.isEmpty(queryLastPatMainHistorys)) {
            for (PatMainHistory source : queryLastPatMainHistorys) {
                PatMainHistory target = new PatMainHistory();
                BeanUtils.copyProperties(source, target, "_id");
                target.setLatest_flag("off");
                insertPatMainHistorys.add(target);
            }
            mongoTemplate.insertAll(insertPatMainHistorys);
        }
    }

    /**
     * データを更新し、pat_personal_main_historyに新しいデータを挿入する
     *
     * @param facilityCd     施設コード
     * @param updMasterInfos 更新データ
     * @param tableName      master table
     */
    @Override
//    @Async
    @Transactional
    public void updateAndInsertPatPersonalMain(String facilityCd, List<Map<String, Object>> updMasterInfos, MstToMongoEnum tableName) {
        //add #10532 mongoDBがダウン中の操作について（新患登録） zhao start
        try {
            if (MongoHealthCheckService.getMongoDBConnected()) {
                //add #10532 mongoDBがダウン中の操作について（新患登録） zhao end
                try {

                    long startTime = System.currentTimeMillis();
                    EventLogMessage eventLogMessageTemp = new EventLogMessage();

                    List<PatPersonalMainHistory> queryLastPatPersonalMainHistorys  = new ArrayList<>();
                    List<PatPersonalMainHistory> insertPatPersonalMainHistorys  = new ArrayList<>();
                    for (Map<String, Object> updMasterInfo : updMasterInfos) {
                        String masterCode = updMasterInfo.get("code").toString();
                        String codeToName = updMasterInfo.get("name").toString();
                        switch (tableName.get()) {
                            // 続柄マスタ
                            case "mst_relationship":
                                queryLastPatPersonalMainHistorys.addAll(updateField(facilityCd, "other_contact_info.relation_cd", "other_contact_info.$[elem].relation_name",
                                        "pat_personal_main_history", Integer.parseInt(masterCode), codeToName, PatPersonalMainHistory.class));
                                break;
                            // 透析困難マスタ
                            case "mst_dialysis_difficulty":
                                queryLastPatPersonalMainHistorys.addAll(updateField(facilityCd, "dial_diff_com_info.dial_diff_cd", "dial_diff_com_info.$[elem].dial_diff_name",
                                        "pat_personal_main_history", Integer.parseInt(masterCode), codeToName, PatPersonalMainHistory.class));
                                break;
                            // 重症度マスタ
                            case "mst_severity":
                                queryLastPatPersonalMainHistorys.addAll(updateField(facilityCd, "severity_cd", "severity_name",
                                        "pat_personal_main_history", masterCode, codeToName, PatPersonalMainHistory.class));
                                break;
                            // 搬送区分マスタ
                            case "mst_transport":
                                queryLastPatPersonalMainHistorys.addAll(updateField(facilityCd, "transport_cd", "transport_name",
                                        "pat_personal_main_history", masterCode, codeToName, PatPersonalMainHistory.class));
                                break;
                            // 病名マスタ
                            case "mst_disease":
                                //mod #11489 アカウント編集で保存しても処理中のまま zrx start
//                                queryLastPatPersonalMainHistorys.addAll(updateField(facilityCd, "die_cd", "die_name",
//                                        "pat_personal_main_history", masterCode, codeToName, PatPersonalMainHistory.class));
//                                queryLastPatPersonalMainHistorys.addAll(updateField(facilityCd, "primary_disease_cd", "primary_disease_name",
//                                        "pat_personal_main_history", Integer.parseInt(masterCode), codeToName, PatPersonalMainHistory.class));
                                Map<String, String> mstDiseaseFieldsMap = new HashMap<>();
                                mstDiseaseFieldsMap.put("die_cd", "die_name");
                                mstDiseaseFieldsMap.put("primary_disease_cd", "primary_disease_name");
                                queryLastPatPersonalMainHistorys.addAll(queryField(facilityCd, mstDiseaseFieldsMap, Integer.parseInt(masterCode), PatPersonalMainHistory.class));
                                updateMultipleFields(facilityCd, mstDiseaseFieldsMap, "pat_personal_main_history", Integer.parseInt(masterCode), codeToName);
                                //mod #11489 アカウント編集で保存しても処理中のまま zrx end
                                break;
                            // 施設マスタ
                            case "mst_facility":
                                queryLastPatPersonalMainHistorys.addAll(updateField(null, "facility_cd", "facility_name",
                                        "pat_personal_main_history", masterCode, codeToName, PatPersonalMainHistory.class));
                                break;

                            default:
                                break;
                        }
                    }

                    eventLogMessageTemp.setLogMessage( "$$$$$$ update " + tableName.get() + " master used time: " + (System.currentTimeMillis() - startTime) / 1000.0 + "秒");
                    logService.log(LogLevel.INFO, eventLogMessageTemp, null, LoggingConstant.MODULE_NAME.ADMIN_WEB, null);
                    startTime = System.currentTimeMillis();

                    if (!CollectionUtils.isEmpty(queryLastPatPersonalMainHistorys)) {
                        for (PatPersonalMainHistory source : queryLastPatPersonalMainHistorys) {
                            PatPersonalMainHistory target = new PatPersonalMainHistory();
                            BeanUtils.copyProperties(source, target, "_id");
                            target.setLatest_flag("off");
                            insertPatPersonalMainHistorys.add(target);
                        }
                        mongoTemplate.insertAll(insertPatPersonalMainHistorys);
                    }

                    eventLogMessageTemp.setLogMessage( "###### insert " + tableName.get() + " master used time: " + (System.currentTimeMillis() - startTime) / 1000.0 + "秒");
                    logService.log(LogLevel.INFO, eventLogMessageTemp, null, LoggingConstant.MODULE_NAME.ADMIN_WEB, null);

                } catch (Exception e) {
                    EventLogMessage eventLogMessage = new EventLogMessage();
                  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
                  eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
                  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
                    eventLogMessage.setFacilityCd(facilityCd);
                    logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.MODULE_NAME.ADMIN_WEB, null);
                }
                //add #10532 mongoDBがダウン中の操作について（新患登録） zhao start
            }
        } catch (DataAccessResourceFailureException exception) {
            MongoHealthCheckService.setMongoDBConnected(false);
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//            exception.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(exception));
          if (!StringUtils.isEmpty(facilityCd)) {
            eventLogMessage.setFacilityCd(facilityCd);
          }
          logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
        }
        //add #10532 mongoDBがダウン中の操作について（新患登録） zhao end
    }

    /**
     * mongo update
     *
     * @param facilityCd        施設コード
     * @param criteriaField     cd表示名
     * @param updateField       フィールド名
     * @param collectionName    データベーステーブル
     * @param masterCode        master code
     * @param codeToName        変更後の表示名
     * @param entityClass       class
     */
    private <T> List<T> updateField(String facilityCd, String criteriaField, String updateField, String collectionName,
                                    Object masterCode, String codeToName, Class<T> entityClass) {
        List<T> result = new ArrayList<>();
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        Timestamp now = new Timestamp(new Date().getTime());
        Update update = new Update();
        update.set("ins_date", now);
        update.set("reg_date", sdf.format(now));
        update.set("up_date", sdf.format(now));
        Query query = new Query();
        if (facilityCd != null && !facilityCd.isEmpty()) {
            query.addCriteria(Criteria.where("facility_cd").is(facilityCd));
        }
        query.addCriteria(Criteria.where("latest_flag").is("on")
                .and(criteriaField).is(masterCode));
        result = mongoTemplate.find(query, entityClass);
        update.set(updateField, codeToName);
        if (updateField.contains(".$[elem].")) {
            update.filterArray(Criteria.where("elem." + criteriaField.split("\\.")[1])
                    .is(masterCode));
        }
        mongoTemplate.updateMulti(query, update, collectionName);
        return result;
    }

  //add #11489 アカウント編集で保存しても処理中のまま zrx start
  private <T> List<T> queryField(String facilityCd, Map<String, String> criteriaFieldsAndUpdateFields, Object masterCode, Class<T> entityClass) {
    List<T> result = new ArrayList<>();

    Query query = new Query();
    if (facilityCd != null && !facilityCd.isEmpty()) {
      query.addCriteria(Criteria.where("facility_cd").is(facilityCd));
    }
    query.addCriteria(Criteria.where("latest_flag").is("on"));

    // OR condition
    List<Criteria> orCriteria = new ArrayList<>();
    for (Map.Entry<String, String> entry : criteriaFieldsAndUpdateFields.entrySet()) {
      String criteriaField = entry.getKey();
      String typeField = entry.getValue();
      // add OR condition
      if(Arrays.asList(strArryType).contains(criteriaField)) {
        orCriteria.add(Criteria.where(criteriaField).is(masterCode.toString()));
      } else {
        orCriteria.add(Criteria.where(criteriaField).is(masterCode));
      }
    }
    //use OR
    if (!orCriteria.isEmpty()) {
      query.addCriteria(new Criteria().orOperator(orCriteria.toArray(new Criteria[0])));
    }
    result = mongoTemplate.find(query, entityClass);
    return result;
  }

  private void updateMultipleFields(String facilityCd, Map<String, String> fieldMap, String collectionName, Object masterCode, String codeToName) {
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
    Timestamp now = new Timestamp(new Date().getTime());

    BulkOperations bulkOps = mongoTemplate.bulkOps(BulkOperations.BulkMode.UNORDERED, collectionName);
    Query query = new Query();

    if (facilityCd != null && !facilityCd.isEmpty()) {
      query.addCriteria(Criteria.where("facility_cd").is(facilityCd));
    }
    query.addCriteria(Criteria.where("latest_flag").is("on"));


    // OR condition
    List<Criteria> orCriteria = new ArrayList<>();
    for (Map.Entry<String, String> entry : fieldMap.entrySet()) {
      String criteriaField = entry.getKey();
      if (Arrays.asList(strArryType).contains(criteriaField)) {
        orCriteria.add(Criteria.where(criteriaField).is(masterCode.toString()));
      } else {
        orCriteria.add(Criteria.where(criteriaField).is(masterCode));
      }
    }
    if (!orCriteria.isEmpty()) {
      query.addCriteria(new Criteria().orOperator(orCriteria.toArray(new Criteria[0])));
    }

    for (Map.Entry<String, String> entry : fieldMap.entrySet()) {
      String criteriaField = entry.getKey();
      String updateField = entry.getValue();

      Update update = new Update();
      update.set("ins_date", now);
      update.set("reg_date", sdf.format(now));
      update.set("up_date", sdf.format(now));
      update.set(updateField, codeToName);
      if (updateField.contains(".$[elem].")) {
        if (Arrays.asList(strArryType).contains(criteriaField)) {
          update.filterArray(Criteria.where("elem." + criteriaField.split("\\.")[1]).is(masterCode.toString()));
        } else {
          update.filterArray(Criteria.where("elem." + criteriaField.split("\\.")[1]).is(masterCode));
        }

      }
      bulkOps.updateMulti(query, update);
    }
    bulkOps.execute();
  }
  //add #11489 アカウント編集で保存しても処理中のまま zrx end
}
// mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 end
//add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 zhaoqi 20240228 end
