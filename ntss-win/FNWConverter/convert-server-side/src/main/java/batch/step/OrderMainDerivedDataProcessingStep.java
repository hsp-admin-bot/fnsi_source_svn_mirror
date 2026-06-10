package batch.step;

import batch.ApplicationConst;
import batch.entity.MntMachineState;
import batch.entity.MstKur;
import batch.entity.MstMachine;
import batch.entity.MstMachineType;
import batch.entity.OrdMain;
import batch.entity.OrdMaterialSave;
import batch.entity.OrdPrescription;
import batch.entity.OrdSchedule;
import batch.listener.JobStartEndLIstener;
import batch.listener.StepStartEndListener;
import batch.part.ProgressManagement;
import batch.part.PsqlCopyUtils;
import batch.part.StreamThread;
import com.amazonaws.util.CollectionUtils;
import com.google.gson.Gson;
import com.zaxxer.hikari.HikariDataSource;
import de.siegmar.fastcsv.writer.CsvWriter;
import lombok.Getter;
import lombok.Setter;
import org.json.JSONObject;
import org.springframework.batch.core.Step;
import org.springframework.batch.core.StepContribution;
import org.springframework.batch.core.configuration.annotation.StepBuilderFactory;
import org.springframework.batch.core.scope.context.ChunkContext;
import org.springframework.batch.core.step.tasklet.Tasklet;
import org.springframework.batch.repeat.RepeatStatus;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.ApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.core.env.Environment;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.RequestEntity;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Component;
import org.springframework.util.ObjectUtils;
import org.springframework.web.client.RestTemplate;
import utils.GlobalContext;
import utils.Utils;
import web.config.EventLoggerUtil;
import web.entity.OrdMaterialSaveRequest;
import web.logger.EventLogMessage;
import web.logger.LogLevel;
import javax.sql.DataSource;
import java.io.File;
import java.io.IOException;
import java.net.URI;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

/**
 * ord_main派生データ処理
 */
@Component
public class OrderMainDerivedDataProcessingStep extends StepStartEndListener implements Tasklet {

    public static final String STEP_NAME = "OrderMainDerivedDataProcessingStep";

    //ord_scheduleテーブルのヘッダ
    // mod #9839 ダミースケジュールがコンバートされていない zs start
    private static final String ORD_SCHEDULE_COM = "facility_cd,ord_no,treat_date,kur_cd,bed_cd,pat_id,is_dummy,treat_week,up_date,reg_date";
    // mod #9839 ダミースケジュールがコンバートされていない zs end
    //ord_material_saveテーブルのヘッダ
    private static final String ORD_MATERIAL_SAVE_COM = "facility_cd,pat_id,supplies_base_date,supplies_base_no,supplies_source_class," +
            // mod #10067 djy start
            "supplies_class,supplies_cd,medicine_mix_cd,class_cd,ind_rst_class,ind_rst_value,receipt_value,is_confirm,medicine_no,procedure_cd,timing_cd,receipt_conversion,reg_date,up_date";
            // mod #10067 djy add
    //mst_machine com
    private static final String MSTMACHINE_COM = "facility_cd,machine_type_cd,machine_serial,model,machine_name,bed_cd,bed_name,reg_date,up_date";


    /**
     * tableName
     */
    private static final String ORDSCHEDULE = "ord_schedule";
    private static final String ORDMATERIALSAVE = "ord_material_save";

    @Autowired
    private StepBuilderFactory stepBuilderFactory;

    @Autowired
    Utils utils;

    @Autowired
    private ApplicationContext appContext;

    @Autowired
    private Environment environment;

    // add #10859-6 djy start
    @Autowired
    ProgressManagement progressManagement;
    // add #10859-6 djy end
    /**
     * ロギング ツール クラスの導入
     */
    @Autowired
    private EventLoggerUtil eventLoggerUtil;
    // add #10067 ord_material_saveのコンバートが正しくない 20240522 孟堅 start
    @Value("${ntss.web-api.set-ord-material-save}")
    private String setOrdMaterialSaveUrl;

    @Value("${ntss.web-api.header-name}")
    private String headerName;

    @Value("${ntss.web-api.header-value}")
    private String headerValue;
    // add #10067 ord_material_saveのコンバートが正しくない 20240522 孟堅 end

    // add #10746 djy start
    @Value("${ntss.web-api.set-ord-rp-material-save}")
    private String setRPOrdMaterialSaveUrl;
    // add #10746 djy end

    @Autowired
    @Qualifier(ApplicationConst.JdbcTempleteName.NAMED_PARAMETER_JDBCTEMPLATE_NKK5)
    private NamedParameterJdbcTemplate namedParameterJdbcTemplateNkk5;

    @Override
    public RepeatStatus execute(StepContribution contribution, ChunkContext chunkContext) throws Exception {

        GlobalContext globalContext = JobStartEndLIstener.getGlobalContext();
        //String inputFilePath = chunkContext.getStepContext().getJobParameters().get(ApplicationConst.JobParameterKeys.INPUT_FILE_PATH).toString();
        String nextProcessingFile = chunkContext.getStepContext().getJobExecutionContext().get(ApplicationConst.PromotionKeys.NEXT_PROCESSING_FILE).toString();
        String inputPath = chunkContext.getStepContext().getJobParameters().get(ApplicationConst.JobParameterKeys.INPUT_FILE_PATH).toString();
        String facilityCd = chunkContext.getStepContext().getJobParameters().get(ApplicationConst.JobParameterKeys.FACILITY_CD).toString();
        String tableName = PsqlCopyUtils.getTableName(nextProcessingFile);
        DataSource machineDs = (DataSource) appContext.getBean(ApplicationConst.DbType.CONVERT);
        NamedParameterJdbcTemplate convertJdbcTemplate = new NamedParameterJdbcTemplate(machineDs);
        String fromDb_table_prefix = environment.getProperty("datasource." + ApplicationConst.DbType.CONVERT + ".table_prefix");

        if (!nextProcessingFile.contains("[diff]")) {
            // add #10859 houyulong start
            String impType = globalContext.materialStatus;
            if (impType.equals("初回")) {
                String SQL = "SELECT COUNT(1) " +
                        "FROM batch_convert_table_status " +
                        "WHERE facility_cd = ? " +
                        "AND type_name = ? " +
                        "AND table_name IN ('ord_main', 'ord_prescription')";

                    Object[] params = new Object[] {facilityCd, "追加"};
                    HikariDataSource convertDS = (HikariDataSource) appContext.getBean(ApplicationConst.DbType.CONVERT);
                    JdbcTemplate jdbcTemplate = new JdbcTemplate(convertDS);
                    Integer count = jdbcTemplate.queryForObject(SQL, params, Integer.class);

                impType = (count != null && count > 0) ? "追加" : "初回";
                globalContext.materialStatus = impType;
            }
            // add #10859 houyulong end

            if ("ord_main".equals(tableName)) {
                String ord_main_sql = "select facility_cd, ord_no, treat_date, ind_kur_cd, ind_bed_cd, pat_id, treat_week, " +
                        "ind_cond_info, ind_medi_info, ind_equip_info ,rst_cond_info,rst_medi_info,rst_equip_info,rst_treatment_info,is_confirm,rst_dialysis_state,fn_plural from "
                        + fromDb_table_prefix + tableName
                        + " where facility_cd = ? and ord_no > ?"
                        + " and is_del = '0'";
                List<OrdMain> ordNoList = convertJdbcTemplate.getJdbcOperations().query(ord_main_sql, new Object[]{facilityCd, globalContext.seqRegist}, new BeanPropertyRowMapper<>(OrdMain.class));
                if (ordNoList != null && !ordNoList.isEmpty()) {
                    // del #10067 ord_material_saveのコンバートが正しくない 20240522 孟堅 start
//                    mstMedicineMap = this.selectAllMedicineList();
//                    mstMedicineMixMap = this.selectAllMedicineMixList();
//                    mstEquipmentMap = this.selectAllEquipment();
                    // del #10067 ord_material_saveのコンバートが正しくない 20240522 孟堅 end
                    this.processOrdScheduleData(facilityCd, convertJdbcTemplate, ordNoList, inputPath, ORDSCHEDULE);
                    // mod #10067 ord_material_saveのコンバートが正しくない 20240522 孟堅 start
                    // mod #10843 djy start
                    // add #10859-6 djy start
                    progressManagement.createConvertTableStatus(chunkContext.getStepContext().getStepExecution().getJobExecution(),"ord_materail_save " + impType + " 移行開始");
                    // add #10859-6 djy end
                    this.sendOrdMaterialSaveProcess(facilityCd, ordNoList, false);
                    // add #10859-6 djy start
                    progressManagement.createConvertTableStatus(chunkContext.getStepContext().getStepExecution().getJobExecution(),"ord_materail_save " + impType + " 移行終了");
                    // add #10859-6 djy end
                    // mod #10843 djy end
                    // mod #10067 ord_material_saveのコンバートが正しくない 20240522 孟堅 end
                }
            } else if ("mst_machine".equals(tableName)) {
                Collection<String[]> resultDataList = new ArrayList<String[]>(Collections.EMPTY_LIST);
                String mst_machine_sql = "select facility_cd, machine_type_cd, machine_serial, machine_no, machine_name, is_del, is_disp, reg_date, up_date from " + fromDb_table_prefix + tableName
                        + " where facility_cd = ? and is_disp='1' and machine_no > ?";
                List<MstMachine> mstMachineList = convertJdbcTemplate.getJdbcOperations().query(mst_machine_sql, new Object[]{facilityCd, globalContext.seqRegist}, new BeanPropertyRowMapper<>(MstMachine.class));
                if (resultDataList.isEmpty()) {
                    resultDataList.add(MSTMACHINE_COM.split(","));
                }
                String csvfileName = inputPath + "/mnt_machine_state.csv";
                String s = "SELECT machine_type_cd,model FROM mst_machine_type";
                List<MstMachineType> mode = convertJdbcTemplate.getJdbcOperations().query(s, new Object[]{}, new BeanPropertyRowMapper<>(MstMachineType.class));
                for (MstMachine om : mstMachineList) {
                        List<MstMachineType>  modelList =mode.stream().filter(aa -> aa.getMachineTypeCd().equals(om.getMachineTypeCd())).toList();
                        String model = null;
                        if (modelList.size() == 1) {
                            model = modelList.get(0).getModel();
                        }

                        MntMachineState mntMachineState = new MntMachineState();
                        mntMachineState.setFacilityCd(om.getFacilityCd());
                        mntMachineState.setMachineTypeCd(om.getMachineTypeCd());
                        mntMachineState.setMachineSerial(om.getMachineSerial());
                        mntMachineState.setModel(model);
                        mntMachineState.setMachineName(om.getMachineName());
                        mntMachineState.setRegDate(Timestamp.valueOf(LocalDateTime.now()));
                        mntMachineState.setUpDate(Timestamp.valueOf(LocalDateTime.now()));
                        String[] mmsArray = mntMachineState.toString().split(",");
                        // add #10153,#10191,#10249 djy start
                        if (mmsArray[2].contains("||@#$~%^&*||")) {
                            mmsArray[2] = mmsArray[2].replace("||@#$~%^&*||", ",");
                        }
                        if (mmsArray[4].contains("||@#$~%^&*||")) {
                            mmsArray[4] = mmsArray[4].replace("||@#$~%^&*||", ",");
                        }
                        if (mmsArray[6].contains("||@#$~%^&*||")) {
                            mmsArray[6] = mmsArray[6].replace("||@#$~%^&*||", ",");
                        }
                        // add #10153,#10191,#10249 djy end
                        resultDataList.add(mmsArray);
                }
                try {
                    String nkk5JdbcUrl = environment.getProperty("datasource." + ApplicationConst.DbType.NKK5 + ".jdbc-url");
                    String nkk5UserName = environment.getProperty("datasource." + ApplicationConst.DbType.NKK5 + ".username");
                    String to_Db_table_prefix = environment.getProperty("datasource." + ApplicationConst.DbType.NKK5 + ".table_prefix");
                    String fromHostIp = nkk5JdbcUrl.split("/")[2].split(":")[0];
                    String fromDbUser = nkk5UserName;
                    String fromDbName = nkk5JdbcUrl.split("/")[3];
                    String registColumnNames = MSTMACHINE_COM;
                    File fileNew = new File(csvfileName);
                    CsvWriter cw = new CsvWriter();
                    cw.write(fileNew, StandardCharsets.UTF_8, resultDataList);
                    String copyCommand = "psql"
                            + " -h "
                            + fromHostIp
                            + " -U "
                            + fromDbUser
                            + " -d "
                            + fromDbName
                            + " -c \"\\copy " + to_Db_table_prefix
                            + "mnt_machine_state"
                            + "("
                            + registColumnNames
                            + ") FROM " + csvfileName + " WITH CSV HEADER\"";
                    System.err.println("执行mnt_machine_state.csv文件的COPY命令：" + copyCommand);
                    String[] command = new String[3];
                    if ("\\".equals(System.getProperty("file.separator"))) {
                        command[0] = "cmd.exe";
                        command[1] = "/c";
                    } else {
                        command[0] = "sh";
                        command[1] = "-c";
                    }
                    command[2] = copyCommand;
                    boolean c = this.processCmdSql(facilityCd, command, true);
                    if (!c) {
                        EventLogMessage eventLogMessageTable = eventLoggerUtil.getEventLogMessage(fileNew + "CSVインポート中にエラーが発生しました！",
                                facilityCd, "createCsvFileAndToProduction");
                        eventLoggerUtil.recordLog(facilityCd, eventLogMessageTable, LogLevel.ERROR);
                    }
                    Path path = Paths.get(csvfileName); //ソースファイル
                    Files.deleteIfExists(path);

                } catch (Exception exception) {
                    EventLogMessage eventLogMessageErr = eventLoggerUtil.getEventLogMessage(EventLoggerUtil.excetionStackTraceToString(exception)
                            , facilityCd
                            , "OrderMainDerivedDataProcessingStep.execute()");
                    eventLoggerUtil.recordLog(facilityCd, eventLogMessageErr, LogLevel.ERROR);
                }
            } else if ("ord_prescription".equals(tableName)) { //处方ord_prescription：ord_material_save add
                Collection<String[]> resultDataList = new ArrayList<String[]>(Collections.EMPTY_LIST);
                if (resultDataList.isEmpty()) {
                    resultDataList.add(ORD_MATERIAL_SAVE_COM.split(","));
                }
                String sql = "select \n" +
                        "* \n" +
                        "from \n" +
                        "ord_prescription  " +
                        "where ord_prescription_no > ? \n" +
                        "and facility_cd = ? " +
                        "and is_del = '0'";
                List<OrdPrescription> ordPrescriptionList = convertJdbcTemplate.getJdbcOperations().query(sql, new Object[]{globalContext.seqRegist, facilityCd}, new BeanPropertyRowMapper<>(OrdPrescription.class));
                if (ordPrescriptionList != null && !ordPrescriptionList.isEmpty()) {
                    // add #10746 djy start
                    // add #10859-6 djy start
                   progressManagement.createConvertTableStatus(chunkContext.getStepContext().getStepExecution().getJobExecution(),"ord_materail_save " + impType + " 移行開始");
                    // add #10859-6 djy end
                    this.sendOrdRPMaterialSaveProcess(facilityCd, ordPrescriptionList);
                    // add #10859-6 djy start
                    progressManagement.createConvertTableStatus(chunkContext.getStepContext().getStepExecution().getJobExecution(),"ord_materail_save " + impType + " 移行終了");
                    // add #10859-6 djy end
                    // add #10746 djy end
                }
            }
         }else {
            // add #10859 houyulong start
            String omsDiffStartLog = "ord_materail_save 差分 移行開始";
            String omsDiffEndLog = "ord_materail_save 差分 移行終了";
            // add #10859 houyulong end
            if (!"".equals(globalContext.sqlKeys) || globalContext.seq > -1) { // #12229 modify !"".equals(utils.seq) to utils.seq > -1
                if ("ord_main".equals(tableName)) {
                    String ord_main_sql = "select facility_cd, ord_no, treat_date, ind_kur_cd, ind_bed_cd, pat_id, treat_week, " +
                            // mod #10067 ord_material_saveのコンバートが正しくない 20240522 孟堅 start
                            "ind_cond_info, ind_medi_info, ind_equip_info ,rst_cond_info,rst_medi_info,rst_equip_info,rst_treatment_info,is_confirm,rst_dialysis_state,fn_plural from "
                            // mod #10067 ord_material_saveのコンバートが正しくない 20240522 孟堅 start
                            + fromDb_table_prefix + tableName
                            + " where facility_cd = :facilityCd"
                            + " and is_del = '0'";
                    // SQL Injection protection: parameterize IN clause and seq

                    Map<String, Object> params = new HashMap<>();
                    params.put("facilityCd", facilityCd);
                    boolean bothFlag = false;
                    if (!"".equals(globalContext.sqlKeys)) {
                        List<Long> keyList = Arrays.stream(globalContext.sqlKeys.replace(" ","").split(","))
                                .filter(k -> !k.isEmpty())
                                .map(Long::valueOf)
                                .collect(Collectors.toList());
                        ord_main_sql += " and (ord_no in (:pKeys)";
                        params.put("pKeys", keyList);
                        bothFlag = true;
                    }
                    if (bothFlag) {
                        if (globalContext.seq > -1) {   // #12229 modify !"".equals(utils.seq) to utils.seq > -1
                            ord_main_sql += " or ord_no > :seq)";
                            params.put("seq", globalContext.seq);
                        } else {
                            ord_main_sql += ")";
                        }
                    } else {
                        ord_main_sql += " and ord_no > :seq";
                        params.put("seq", globalContext.seq);
                    }
                    List<OrdMain> ordMainList = convertJdbcTemplate.query(ord_main_sql, params, new BeanPropertyRowMapper<>(OrdMain.class));
                    if (ordMainList != null && !ordMainList.isEmpty()) {
                        // add #10067 ord_material_saveのコンバートが正しくない 20240522 孟堅 start
                        // mod #10843 djy start
                        // add #10859-6 djy start
                        progressManagement.createConvertTableStatus(chunkContext.getStepContext().getStepExecution().getJobExecution(),omsDiffStartLog);
                        // add #10859-6 djy end
                        this.sendOrdMaterialSaveProcess(facilityCd, ordMainList,true);
                        // add #10859-6 djy start
                        progressManagement.createConvertTableStatus(chunkContext.getStepContext().getStepExecution().getJobExecution(),omsDiffEndLog);
                        // add #10859-6 djy end
                        // mod #10843 djy end
                        // add #10067 ord_material_saveのコンバートが正しくない 20240522 孟堅 end
                    }
                } else if ("ord_prescription".equals(tableName)) {
                    String sql = "select \n" +
                            "* \n" +
                            "from \n" +
                            "ord_prescription  " +
                            "where facility_cd = ?"
                            + " and is_del = '0'";
                    // SQL Injection protection: parameterize IN clause and seq
                    List<Object> params2 = new ArrayList<>();
                    params2.add(facilityCd);
                    boolean bothFlag = false;
                    if (!"".equals(globalContext.sqlKeys)) {
                        List<String> keyList = Arrays.stream(globalContext.sqlKeys.replace(" ","").split(","))
                                .map(k -> k.trim().replaceAll("^'|'$", ""))
                                .filter(k -> !k.isEmpty())
                                .collect(Collectors.toList());
                        String placeholders = keyList.stream().map(k -> "?").collect(Collectors.joining(","));
                        sql += " and (ord_prescription_no in ( " + placeholders + ") ";
                        List<Long> keyListLong = new ArrayList<>();
                        for (String key : keyList) {
                            keyListLong.add(Long.parseLong(key));
                        }
                        params2.addAll(keyList);
                        batchDeleteOrdMaterialSave(facilityCd, keyListLong);
                        bothFlag = true;
                    }
                    if (bothFlag) {
                        if (globalContext.seq > -1) {   // #12229 modify !"".equals(utils.seq) to utils.seq > -1
                            sql += " or ord_prescription_no > ?)";
                            params2.add(globalContext.seq);
                        } else {
                            sql += ")";
                        }
                    } else {
                        sql += " and ord_prescription_no > ?";
                        params2.add(globalContext.seq);
                    }
                    List<OrdPrescription> ordPrescriptionList = convertJdbcTemplate.getJdbcOperations().query(sql, params2.toArray(), new BeanPropertyRowMapper<>(OrdPrescription.class));
                    if (ordPrescriptionList != null && !ordPrescriptionList.isEmpty()) {
                        // add #10746 djy start
                        // add #10859-6 djy start
                        progressManagement.createConvertTableStatus(chunkContext.getStepContext().getStepExecution().getJobExecution(),omsDiffStartLog);

                        // add #10859-6 djy end
                        this.sendOrdRPMaterialSaveProcess(facilityCd,ordPrescriptionList);
                        // add #10859-6 djy start
                        progressManagement.createConvertTableStatus(chunkContext.getStepContext().getStepExecution().getJobExecution(),omsDiffEndLog);
                        // add #10859-6 djy end
                        // add #10746 djy end
                    }
                }
            }
        }
        return RepeatStatus.FINISHED;
    }

    /**
     * 差分論理から対応ord _material_saveのデータ
     *
     * @param ordNoList
     */
    private Integer batchDeleteOrdMaterialSave(String facilityCd, List<Long> ordNoList) {
        String fromDb_table_prefix = environment.getProperty("datasource." + ApplicationConst.DbType.NKK5 + ".table_prefix");
        String sql = "DELETE FROM \n" +
                fromDb_table_prefix +
                "ord_material_save  " +
                "where supplies_base_no in :ordNoList \n" +
                "and facility_cd = :facilityCd ";
        Map<String, Object> paramMap = new HashMap<>();
        paramMap.put("ordNoList", ordNoList);   // List<Long>
        paramMap.put("facilityCd", facilityCd);
        return namedParameterJdbcTemplateNkk5.update(sql, paramMap);
    }

    /**
     * ord_scheduleデータ生成
     *
     * @param machineJdbcTemplate
     * @param ordNoList
     * @param inputPath
     * @param tableName
     * @throws IOException
     */
    private void processOrdScheduleData(String facilityCd, NamedParameterJdbcTemplate machineJdbcTemplate, List<OrdMain> ordNoList, String inputPath,
                                        String tableName) throws IOException {
        List<OrdSchedule> osParamList = new LinkedList<>();
        for (OrdMain om : ordNoList) {
            if (om.getIndKurCd() != null && om.getIndBedCd() != null) {
                OrdSchedule schedule = new OrdSchedule();
                schedule.setFacilityCd(om.getFacilityCd());
                schedule.setOrdNo(om.getOrdNo());
                schedule.setTreatDate(om.getTreatDate());
                schedule.setKurCd(om.getIndKurCd());
                schedule.setBedCd(om.getIndBedCd());
                schedule.setPatId(om.getPatId());
                schedule.setTreatWeek(om.getTreatWeek());
                schedule.setIsDummy("0");
                osParamList.add(schedule);
            }
            List<OrdSchedule> dummyScheduleList = this.insertOrdSchedule(om, machineJdbcTemplate);
            if (!CollectionUtils.isNullOrEmpty(dummyScheduleList)) osParamList.addAll(dummyScheduleList);
        }
        String csvFilePath = inputPath + "/ord_schedule.csv";
        //##9839 wzy start
        this.createCsvFileAndToConvert(facilityCd, tableName, csvFilePath, osParamList, null);
        //##9839 wzy end
    }


    /**
     * ord_scheduleのis_dummy ='1'データを追加
     *
     * @return
     */
    private List<OrdSchedule> insertOrdSchedule(OrdMain om, NamedParameterJdbcTemplate machineJdbcTemplate) {
        OrdMain retInfo = om;
        Long ordNo = retInfo.getOrdNo();
        String facilityCdRet = retInfo.getFacilityCd();
        String treatDate = retInfo.getTreatDate();
        Integer indKurCdTemp = retInfo.getIndKurCd();
        long tmpKurCd = indKurCdTemp.longValue();
        Integer indBedCdTemp = retInfo.getIndBedCd();
        long indKurCd = tmpKurCd;
        Long patId = retInfo.getPatId();
        Long indBedCd = indBedCdTemp.longValue();
        List<OrdSchedule> result = new LinkedList<>();
        if ((0 != indKurCd) && (0 != indBedCd)) {
            Long treatTime = null;
            String indCondInfoTmp = retInfo.getIndCondInfo();
            if (indCondInfoTmp == null) {
                treatTime = 0L;
            } else {
                org.json.JSONObject indCondInfo = new org.json.JSONObject(indCondInfoTmp);
                if (indCondInfo.has("1")) {
                    String treatTimeStr = new org.json.JSONObject(indCondInfo.get("1").toString()).get("value").toString();
                    if (org.springframework.util.ObjectUtils.isEmpty(treatTimeStr) || "null".equals(treatTimeStr.toLowerCase())) {
                        treatTime = 0L;
                    } else {
                        treatTime = Long.parseLong((new org.json.JSONObject(indCondInfo.get("1").toString()).get("value").toString()));
                    }
                } else {
                    treatTime = 0L;
                }
            }
            List<MstKur> mstKur = null;
            if (null == mstKur) {
                // SQLインジェクション対策：文字列連結の代わりに?プレースホルダーを使用
                String mst_kur_sql = "select A.kur_cd, A.kur_start_time, A.kur_end_time, A.kur_standard_start_time from mst_kur A where A.is_del = '0' AND facility_cd = ? order by A.kur_cd";
                mstKur = machineJdbcTemplate.getJdbcOperations().query(mst_kur_sql, new Object[]{facilityCdRet}, new BeanPropertyRowMapper<>(MstKur.class));
            }
            if (mstKur.isEmpty()) {
                return null;
            }
            List<MstKur> currentKur = mstKur.stream().filter(info -> Long.parseLong(info.getKurCd().toString()) == indKurCd).collect(Collectors.toList());
            if (currentKur.isEmpty()) {
                return null;
            }
            DateTimeFormatter dateFormat = DateTimeFormatter.ofPattern("yyyyMMddHHmmss");
            DateTimeFormatter dayFormat = DateTimeFormatter.ofPattern("yyyyMMdd");
            LocalDateTime treatStartDay = LocalDateTime.parse(treatDate + "000000", dateFormat);

            String startTime = currentKur.get(0).getKurStandardStartTime();

            if (currentKur.get(0).getKurCd().equals(retInfo.getIndKurCd())) {
                if (!org.springframework.util.ObjectUtils.isEmpty(retInfo.getIndTreatStartTime())) {
                    startTime = retInfo.getIndTreatStartTime() + "00";
                }
            }

            LocalDateTime treatEndDate = LocalDateTime.parse(treatDate + startTime, dateFormat).plusMinutes(treatTime);

            LocalDateTime dummyDate = treatStartDay;
            Long dummyKur = indKurCd;
            while (!dummyDate.isAfter(treatEndDate)) {
                MstKurEx nextKurInfo = this.calcNextKurInfo(mstKur, dummyKur);
                if (null == nextKurInfo) {
                    return null;
                } else {
                    if (nextKurInfo.getIsFirstKur()) {
                        dummyDate = dummyDate.plusDays(1);
                    }
                    String dummyTreatDate = dummyDate.format(dayFormat);
                    dummyDate = LocalDateTime.parse(dummyTreatDate + nextKurInfo.getKurEndTime(), dateFormat);
                    dummyKur = nextKurInfo.getKurCd().longValue();
                    if (dummyDate.isAfter(treatEndDate)) break;
                    OrdSchedule dummySchedule = new OrdSchedule();
                    dummySchedule.setFacilityCd(facilityCdRet);
                    dummySchedule.setOrdNo(ordNo);
                    dummySchedule.setTreatDate(dummyTreatDate);
                    dummySchedule.setTreatWeek(Short.parseShort(String.valueOf(dummyDate.getDayOfWeek().getValue())));
                    dummySchedule.setKurCd(Integer.parseInt(String.valueOf(dummyKur)));
                    dummySchedule.setBedCd(Integer.parseInt(String.valueOf(indBedCd)));
                    // add #9839 ダミースケジュールがコンバートされていない zs start
                    dummySchedule.setPatId(patId);
                    // add #9839 ダミースケジュールがコンバートされていない zs end
                    dummySchedule.setIsDummy("1");
                    result.add(dummySchedule);
                }
            }
            return result;
        }
        return null;
    }

    /**
     * 次クール情報取得
     *
     * @param mstKur       クールマスタ情報
     * @param currentKurCd 現在クール
     * @return 正常終了:次クール情報、異常終了:null
     */
    private MstKurEx calcNextKurInfo(List<MstKur> mstKur, long currentKurCd) {
        MstKurEx targetKur = null;
        boolean isCurrentKur = false;
        if (!mstKur.isEmpty()) {
            for (int i = 0; i < mstKur.size(); i++) {
                if (true == isCurrentKur) {
                    targetKur = MstKurEx.parse(mstKur.get(i));
                    break;
                }
                if ((i != mstKur.size() - 1) && (currentKurCd == mstKur.get(i).getKurCd().longValue())) {
                    isCurrentKur = true;
                }
            }
            if (false == isCurrentKur) {
                targetKur = MstKurEx.parse(mstKur.get(0));
                targetKur.setIsFirstKur(true);
            }
        }
        return targetKur;
    }


    /**
     * クールマスタの拡張情報を格納するクラス
     */
    @Getter
    @Setter
    private static class MstKurEx extends MstKur {
        /**
         * 最初のクールフラグ(true:最初のクール、false:最後のクール以外)
         */
        private Boolean isFirstKur;

        private static MstKurEx parse(MstKur base) {
            MstKurEx ret = new MstKurEx();
            ret.setKurCd(base.getKurCd());
            ret.setKurStandardStartTime(base.getKurStandardStartTime());
            ret.setKurStartTime(base.getKurStartTime());
            ret.setKurEndTime(base.getKurEndTime());
            ret.setIsFirstKur(false);
            return ret;
        }
    }

    /**
     * csv作成
     *
     * @param tableName
     * @param csvfileName
     * @param ordScheduleList
     * @throws IOException
     */
    private void createCsvFileAndToConvert(String facilityCd, String tableName, String csvfileName, List<OrdSchedule> ordScheduleList,
                                           List<OrdMaterialSave> ordMaterialSaveList) throws IOException {
        String nkk5JdbcUrl = environment.getProperty("datasource." + ApplicationConst.DbType.CONVERT + ".jdbc-url");
        String nkk5UserName = environment.getProperty("datasource." + ApplicationConst.DbType.CONVERT + ".username");
        String to_Db_table_prefix = environment.getProperty("datasource." + ApplicationConst.DbType.CONVERT + ".table_prefix");
        String fromHostIp = nkk5JdbcUrl.split("/")[2].split(":")[0];
        String fromDbUser = nkk5UserName;
        String fromDbName = nkk5JdbcUrl.split("/")[3];
        Collection<String[]> resultDataList = new ArrayList<String[]>(Collections.EMPTY_LIST);
        String registColumnNames = "";
        if (ORDSCHEDULE.equals(tableName) && !ordScheduleList.isEmpty()) {
            registColumnNames = ORD_SCHEDULE_COM;
            if (resultDataList.isEmpty()) {
                resultDataList.add(ORD_SCHEDULE_COM.split(","));
            }
            for (OrdSchedule osl : ordScheduleList) {
                String ordScheduleStr = osl.toString();

                if (!ObjectUtils.isEmpty(osl)) {
                    String[] ordScheduleStrArray = ordScheduleStr.split(",");
                    if (ordScheduleStrArray.length > 0) resultDataList.add(ordScheduleStrArray);
                }
            }
        } else if (ORDMATERIALSAVE.equals(tableName) && !ordMaterialSaveList.isEmpty()) {
            registColumnNames = ORD_MATERIAL_SAVE_COM;
            if (resultDataList.isEmpty()) {
                resultDataList.add(ORD_MATERIAL_SAVE_COM.split(","));
            }
            for (OrdMaterialSave oms : ordMaterialSaveList) {
                String omSstr = oms.toString();

                if (!ObjectUtils.isEmpty(omSstr)) {
                    String[] omsArray = omSstr.split(",");
                    if (omsArray.length > 0) resultDataList.add(omsArray);
                }
            }
        } else {
            return;
        }

        try {
            File fileNew = new File(csvfileName);
            CsvWriter cw = new CsvWriter();
            cw.write(fileNew, StandardCharsets.UTF_8, resultDataList);
            String copyCommand = "psql"
                    + " -h "
                    + fromHostIp
                    + " -U "
                    + fromDbUser
                    + " -d "
                    + fromDbName
                    + " -c \"\\copy " + to_Db_table_prefix
                    + tableName
                    + "("
                    + registColumnNames
                    + ") FROM " + csvfileName + " WITH CSV HEADER\"";
            if (ORDSCHEDULE.equals(tableName)) {
                System.err.println("Copy command executing: ord_schedule.csv：" + copyCommand);
            } else if (ORDMATERIALSAVE.equals(tableName)) {
                System.err.println("Copy command executing: ord_material_save.csv：" + copyCommand);
            }
            String[] command = new String[3];
            if ("\\".equals(System.getProperty("file.separator"))) {
                command[0] = "cmd.exe";
                command[1] = "/c";
            } else {
                command[0] = "sh";
                command[1] = "-c";
            }
            command[2] = copyCommand;
            boolean c = this.processCmdSql(facilityCd, command, true);
            if (!c) {
                EventLogMessage eventLogMessageTable = eventLoggerUtil.getEventLogMessage(fileNew + "CSVインポート中にエラーが発生しました！",
                        facilityCd, "createCsvFileAndToProduction");
                eventLoggerUtil.recordLog(facilityCd, eventLogMessageTable, LogLevel.ERROR);
            }
            Path path = Paths.get(csvfileName); //ソースファイル
            Files.deleteIfExists(path);

        } catch (Exception exception) {
            System.err.println(exception.toString());
        }
    }

    /**
     * Java呼び出しProcess実行CMDコマンド共通メソッド
     *
     * @param cmd
     * @param status
     * @return
     * @throws RuntimeException
     */
    private boolean processCmdSql(String facilityCd, String[] cmd, boolean status) throws RuntimeException {

        Process process = null;
        boolean exSuccess = true;
        try {
            if (status) {
                System.err.println("true CMDコマンドを実行するには：" + cmd[2]);
                process = Runtime.getRuntime().exec(cmd);
            } else {
                System.err.println("false CMDコマンドを実行するには：" + cmd[0]);
                process = Runtime.getRuntime().exec(cmd[0]);
            }
            StreamThread it = new StreamThread(process.getInputStream());
            StreamThread et = new StreamThread(process.getErrorStream());
            it.start();
            et.start();
            it.join();
            et.join();
            process.getInputStream().close();
            process.getOutputStream().close();
            process.getErrorStream().close();
            process.destroy();
            if (!org.springframework.util.ObjectUtils.isEmpty(et.getOutputString())) {
                exSuccess = false;
                System.err.println("出力文字：" + et.getOutputString());
                EventLogMessage elm = eventLoggerUtil.getEventLogMessage(et.getOutputString(),
                        facilityCd, "processCmdSql(String[] cmd, boolean status)");
                eventLoggerUtil.recordLog(facilityCd, elm, LogLevel.ERROR);
            }
            System.out.println("psqlコマンドの実行が完了しました！");
        } catch (IOException | InterruptedException e) {
            // TODO Auto-generated catch block
            eventLoggerUtil.recordLog(
                    facilityCd,
                    eventLoggerUtil.getEventLogMessage(
                            "processCmdSql(String[] cmd, boolean status)  Java呼び出しProcess実行CMDコマンド共通メソッド：" + EventLoggerUtil.excetionStackTraceToString(e),
                            facilityCd,
                            e.getClass().getName() + ".processCmdSql()"),
                    LogLevel.ERROR);
        }
        return exSuccess;
    }

    @Bean(name = STEP_NAME)
    public Step step() {
        return stepBuilderFactory.get(STEP_NAME)
                .tasklet(this)
                .build();
    }
    // add #10067 ord_material_saveのコンバートが正しくない 20240522 孟堅 start
    /***
     * 「OrdMaterialSave」のテータ作成処理です
     * @param ordMainList 処理データ
     * @param diffFlag
     */
    // mod #10843 djy start
    private void sendOrdMaterialSaveProcess(String facilityCd, List<OrdMain> ordMainList, boolean diffFlag) {

        // mod #10843 djy end
        if (ordMainList.isEmpty()) return;
        EventLogMessage eventLogMessage = eventLoggerUtil.getEventLogMessage("「OrdMaterialSave」:処理中",
                facilityCd, "OrderMainDerivedDataProcessingStep.sendOrdMaterialSaveProcess,ordMainList.size()=" + ordMainList.size());
        eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.INFO);
        // 予約
        Map<String, List<OrdMain>> ordMainGroupList = ordMainList.stream().filter(c -> c.getRstDialysisState() != null).collect(Collectors.groupingBy(OrdMain::getRstDialysisState));
        List<OrdMain> indOrdMainList = ordMainGroupList.get("0");
        if (indOrdMainList != null) {
            // mod #10843 djy start
            this.sendOrdMaterialSaveLogic(indOrdMainList, false, false, diffFlag,facilityCd);
            // mod #10843 djy end
        }
        // 実績
        List<OrdMain> rstOrdMainList = ordMainGroupList.get("6");
        if (rstOrdMainList != null) {
            // 実績情報に紐づく予約情報がない場合
            List<OrdMain> ordMainNotIndList = rstOrdMainList.stream().filter(el -> 0 == el.getFnPlural()).toList();
            if (!ordMainNotIndList.isEmpty()) {
                // mod #10843 djy start
                this.sendOrdMaterialSaveLogic(ordMainNotIndList, true, false, diffFlag,facilityCd);
                // mod #10843 djy end
            }
            // 実績情報に紐づく予約情報がある場合
            List<OrdMain> ordMainRstAndIndList = rstOrdMainList.stream().filter(el -> 0 != el.getFnPlural()).toList();
            if (!ordMainRstAndIndList.isEmpty()) {
                // mod #10843 djy start
                this.sendOrdMaterialSaveLogic(ordMainRstAndIndList, true, true, diffFlag,facilityCd);
                // mod #10843 djy end
            }
        }
        eventLogMessage = eventLoggerUtil.getEventLogMessage("「OrdMaterialSave」処理完成",
                facilityCd, "OrderMainDerivedDataProcessingStep.sendOrdMaterialSaveProcess");
        eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.INFO);

    }

    /**
     * 「OrdMaterialSave」のデータの処理ロジックです
     *
     * @param ordMainList 処理データ
     * @param indRstFlag  実績または予約   TRUE:実績  FALSE:予約
     * @param rstUpdFlag  実績同時更新予約 TRUE:更新  FALSE:更新しない
     * @param diffFlag
     */
    // mod #10843 djy start
    private void sendOrdMaterialSaveLogic(List<OrdMain> ordMainList, boolean indRstFlag, boolean rstUpdFlag, boolean diffFlag,String facilityCd) {
        // mod #10843 djy end
        List<Long> ordMainGroupList = ordMainList.stream().map(OrdMain::getOrdNo).toList();
        OrdMaterialSaveRequest ordMaterialSaveRequest = new OrdMaterialSaveRequest();
        ordMaterialSaveRequest.ordMainCds = ordMainGroupList;
        ordMaterialSaveRequest.indRstFlag = indRstFlag;
        ordMaterialSaveRequest.rstUpdFlag = rstUpdFlag;
        // add #10843 djy start
        ordMaterialSaveRequest.diffFlag = diffFlag;
        // add #10843 djy end

        Integer result = sendOrdMaterialPostSaveRequest(ordMaterialSaveRequest,facilityCd);
        if (0 == result) {
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage = eventLoggerUtil.getEventLogMessage("「OrdMaterialSave」:処理中成功 処理データ:"
                            + new Gson().toJson(ordMainGroupList)
                            + " 実績または予約: "+ indRstFlag
                            + " 実績同時更新予約: "+ rstUpdFlag,
                    facilityCd
                    , "sendOrdMaterialSaveLogic");
            eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.INFO);

        }
    }

    /***
     * 「OrdMaterialSave」のテータAPIリクエストの送信です
     * @param ordMaterialSaveRequest 要求情報
     * @return 処理状態   0:成功　1: 失敗
     */
    private Integer sendOrdMaterialPostSaveRequest(OrdMaterialSaveRequest ordMaterialSaveRequest,String facilityCd) {

        int retrunValue = 0;
        EventLogMessage eventLogMessage = new EventLogMessage();
        RestTemplate rt = new RestTemplate();
        HttpStatus status = null;
        Gson gson = new Gson();
        String sendData = gson.toJson(ordMaterialSaveRequest);
        try {
            // 送信URI
            URI uri = new URI(setOrdMaterialSaveUrl);
            // リクエスト作成
            RequestEntity<String> request = RequestEntity
                    .post(uri)
                    .contentType(MediaType.APPLICATION_JSON)
                    .header(headerName, headerValue)
                    .body(sendData);

            // リクエスト処理
            ResponseEntity<String> response = rt.exchange(request, String.class);
            status = response.getStatusCode();
            if (HttpStatus.OK != status) {
                retrunValue = 1;
                eventLogMessage = eventLoggerUtil.getEventLogMessage("「OrdMaterialSave」API接続成功、内部処理に失敗: " + response.getBody()+"失敗メッセージ: "+sendData,
                        facilityCd, "OrderMainDerivedDataProcessingStep.sendOrdMaterialPostSaveRequest");
                eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.ERROR);
            }
        } catch (Exception ex) {
            retrunValue = 1;
            eventLogMessage = eventLoggerUtil.getEventLogMessage("「OrdMaterialSave」APIの接続失敗: " + ex.getMessage() +"失敗メッセージ: "+sendData,
                    facilityCd, "OrderMainDerivedDataProcessingStep.sendOrdMaterialPostSaveRequest" );
            eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.ERROR);
        }
        return retrunValue;
    }
  // add #10067 ord_material_saveのコンバートが正しくない 20240522 孟堅 end

    // add #10746 djy start
    /**
     * sendOrdRPMaterialSaveProcess
     * @param ordPrescriptionList
     */
    private void sendOrdRPMaterialSaveProcess(String facilityCd, List<OrdPrescription> ordPrescriptionList) {

        if (ordPrescriptionList.isEmpty()) return;
        EventLogMessage eventLogMessage = eventLoggerUtil.getEventLogMessage("「OrdRPMaterialSave」:処理中",
                facilityCd, "OrderMainDerivedDataProcessingStep.sendOrdRPMaterialSaveProcess");
        eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.INFO);
        List<Long> ordRpCdList = ordPrescriptionList.stream().map(m -> m.getOrdPrescriptionNo()).collect(Collectors.toList());
        Integer ret = this.sendOrdRPMaterialPostSaveRequest(ordRpCdList, facilityCd);
        eventLogMessage = eventLoggerUtil.getEventLogMessage("「OrdRPMaterialSave」処理完成(結果：" + ret + ")",
                facilityCd, "OrderMainDerivedDataProcessingStep.sendOrdRPMaterialSaveProcess");
        eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.INFO);
    }

    /***
     * sendOrdRPMaterialPostSaveRequest
     * @param ordRpCdList
     * @return 処理状態   0:成功　1: 失敗
     */
    private Integer sendOrdRPMaterialPostSaveRequest(List<Long> ordRpCdList, String facilityCd) {

        int retrunValue = 0;
        EventLogMessage eventLogMessage = new EventLogMessage();
        RestTemplate rt = new RestTemplate();
        HttpStatus status = null;
        JSONObject jsonBody = new JSONObject();
        jsonBody.put("ordRpCds", ordRpCdList);
        try {
            // 送信URI
            URI uri = new URI(setRPOrdMaterialSaveUrl);
            // リクエスト作成
            RequestEntity<String> request = RequestEntity
                    .post(uri)
                    .contentType(MediaType.APPLICATION_JSON)
                    .header(headerName, headerValue)
                    .body(jsonBody.toString());

            // リクエスト処理
            ResponseEntity<String> response = rt.exchange(request, String.class);
            status = response.getStatusCode();
            if (HttpStatus.OK != status) {
                retrunValue = 1;
                eventLogMessage = eventLoggerUtil.getEventLogMessage("「setOrdRPMaterialSave」API接続成功、内部処理に失敗: " + response.getBody()+"失敗メッセージ: "+ordRpCdList,
                        facilityCd, "OrderMainDerivedDataProcessingStep.sendOrdMaterialPostSaveRequest");
                eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.ERROR);
            }
        } catch (Exception ex) {
            retrunValue = 1;
            eventLogMessage = eventLoggerUtil.getEventLogMessage("「setOrdRPMaterialSave」APIの接続失敗: " + ex.getMessage() +"失敗メッセージ: "+ordRpCdList,
                    facilityCd, "OrderMainDerivedDataProcessingStep.sendOrdMaterialPostSaveRequest" );
            eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.ERROR);
        }
        return retrunValue;
    }
    // add #10746 djy end

}
