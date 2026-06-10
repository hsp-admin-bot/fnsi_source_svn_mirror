package batch.listener;

import batch.ApplicationConst;
import batch.ApplicationConst.JobParameterKeys;
import batch.ApplicationConst.StopReason;
import batch.config.ConvertPriorityConfig;
import batch.config.ZipFileConfig;
import batch.entity.MstMachine;
import batch.entity.MstMachineRecord;
import batch.entity.MstMachineType;
import batch.entity.MstTreatmentStatusDispItem;
import batch.entity.OrdMain;
import batch.entity.OrdMainHst;
import batch.entity.PatEvent;
import batch.entity.SysMonitorItem;
import batch.part.FileVisitor;
import batch.part.ProgressManagement;
import batch.part.PsqlCopyUtils;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.math.BigDecimal;
import java.net.URI;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.sql.Types;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.temporal.TemporalAdjusters;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.CompletableFuture;
import java.util.regex.Pattern;
import java.util.stream.Collectors;
import javax.sql.DataSource;
import lombok.SneakyThrows;
import net.lingala.zip4j.ZipFile;
import org.apache.tomcat.util.http.fileupload.FileUtils;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.batch.core.ExitStatus;
import org.springframework.batch.core.JobExecution;
import org.springframework.batch.core.JobParameters;
import org.springframework.batch.core.launch.JobLauncher;
import org.springframework.batch.core.listener.JobExecutionListenerSupport;
import org.springframework.batch.item.ExecutionContext;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.ApplicationContext;
import org.springframework.context.annotation.Scope;
import org.springframework.core.env.Environment;
import org.springframework.dao.DataAccessException;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.RequestEntity;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.BatchPreparedStatementSetter;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.CollectionUtils;
import org.springframework.web.client.RestTemplate;
import utils.GlobalContext;
import utils.MasterDataService;
import utils.Utils;
import web.config.EventLoggerUtil;
import web.logger.EventLogMessage;
import web.logger.LogLevel;

/**
 * ジョブの開始終了を通知するlistener
 * zip4jライセンス条文
 * This software includes the work that is distributed in the Apache License 2.0.
 */
@Scope("prototype")
@Component
public class JobStartEndLIstener extends JobExecutionListenerSupport {


  @Autowired
  ProgressManagement progressManagement;

  @Autowired
  ConvertPriorityConfig convertPriorityConfig;

  @Autowired
  ZipFileConfig zipFileConfig;

  @Autowired
  @Qualifier("parallelJobLauncher")
  JobLauncher parallelJobLauncher;

    //ANALYZE実行待ち時間120，時間単位：秒
    private static final Integer AWAIT = 120;

  @Autowired
  Utils utils;

  /**
   * ロギング ツール クラスの導入
   */
  @Autowired
  private EventLoggerUtil eventLoggerUtil;

  private StopReason stopReason;

  @Autowired
  private ApplicationContext appContext;

  @Autowired
  private Environment environment;
  @Autowired
  private static  String filePatDel;

  //add #10675 & #10676 djy start
  @Autowired(required = false)
  MongoTemplate mongoTemplate;
  //add #10675 & #10676 djy end

  //add #10568 djy start
  @Value("${ntss.web-api.set-next-pat-url}")
  private String setNextPatUrl;

  @Value("${ntss.web-api.header-name}")
  private String headerName;

  @Value("${ntss.web-api.header-value}")
  private String headerValue;
  //add #10568 djy end

  @Autowired
  @Qualifier("jdbcTemplateNkk5")
  private JdbcTemplate jdbcTemplateNkk5;

  @Autowired
  @Qualifier("jdbcTemplateConvert")
  private JdbcTemplate jdbcTemplateConvert;

  @Autowired
  @Qualifier("namedParameterJdbcTemplateNkk4")
  private NamedParameterJdbcTemplate namedParameterJdbcTemplateNkk4;

  @Autowired
  @Qualifier("namedParameterJdbcTemplateNkk5")
  private NamedParameterJdbcTemplate namedParameterJdbcTemplateNkk5;

  @Autowired
  @Qualifier("namedParameterJdbcTemplateConvert")
  private NamedParameterJdbcTemplate namedParameterJdbcTemplateConvert;

    public List<String> sysTableNameList = new ArrayList<String>(
            Arrays.asList(
                    "sys_monitor_item",
                    "mst_treatment_status_disp_item",
                    "mst_machine_type",
                    "mst_machine_record"
            )
    );

    //add #12229 ord_weight_scale start
    @Autowired
    private MasterDataService masterDataService;
    //add #12229 ord_weight_scale end

    private static final ThreadLocal<GlobalContext> localGlobal = ThreadLocal.withInitial(GlobalContext::new);

  // ジョブの開始前に実行
  @SneakyThrows
  @Override
  public void beforeJob(JobExecution jobExecution) {
    super.beforeJob(jobExecution);
    JobParameters jobParameters = jobExecution.getJobParameters();
    String facilityCd = jobParameters.getString(JobParameterKeys.FACILITY_CD);
    GlobalContext globalContext = initGlobalContext(facilityCd);

    long jobInstanceId = jobExecution.getJobInstance().getInstanceId();
    String jobName = jobExecution.getJobInstance().getJobName();
    String inputFilePath = jobParameters.getString(JobParameterKeys.INPUT_FILE_PATH).toString();
    // add #7339 AWS側アプリが起動しない途中から開始されない yangmj start
    String isRestart = jobParameters.getString(JobParameterKeys.RESTART);

    sysTable();
    /**
     * job起動前に10個のトリガを無効にする
     */

    // 起動中のジョブがないか確認
    if (isRestart == null || isRestart.isEmpty())
    {
      // add #7339 AWS側アプリが起動しない途中から開始されない yangmj end
      // 起動中のジョブがないか確認
      if (progressManagement.isRunning(facilityCd)) {
        jobExecution.stop();
        //ログ
        EventLogMessage eventLogMessage = eventLoggerUtil.getEventLogMessage("ジョブ起動中のため停止",
                facilityCd, "JobStartEndLIstener.beforeJob(JobExecution jobExecution)");
        eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.INFO);
        //log.info("ジョブ起動中のため停止");
        stopReason = StopReason.MULTIPLE_ACTIVATION;
        return;
      }
      // add #10859-6 djy start
      if(globalContext.AlreadyImportedTableSet == null || globalContext.AlreadyImportedTableSet.isEmpty()){
        try {
          DataSource machineDsConvert = (DataSource) appContext.getBean(ApplicationConst.DbType.CONVERT);
          JdbcTemplate jdbcTemplateConvert = new JdbcTemplate(machineDsConvert);
          String sql = "SELECT distinct table_name FROM batch_convert_table_status WHERE  facility_cd = ? AND type_name is not null";
          globalContext.AlreadyImportedTableSet = jdbcTemplateConvert.queryForList(sql, new Object[] {facilityCd}, String.class).stream().collect(Collectors.toSet());
        }catch (Exception ex){
          EventLogMessage eventLogMessageSql = eventLoggerUtil.getEventLogMessage(ex.getMessage(),
                  facilityCd, "JobStartEndLIstener.beforeJob(JobExecution jobExecution)");
          eventLoggerUtil.recordLog(facilityCd, eventLogMessageSql, LogLevel.WARN);
        }
      }
      // add #10859-6 djy end
      // ジョブ進捗登録
      progressManagement.insertBatchStatus(facilityCd, progressManagement.STARTED, jobInstanceId, jobName);
      // add #7339 AWS側アプリが起動しない途中から開始されない yangmj start
    }
    // add #7339 AWS側アプリが起動しない途中から開始されない yangmj end
    // ステータス更新用のIDを取得
    int convertProcId = progressManagement.getConvertProcId(facilityCd);
    ExecutionContext cxt = jobExecution.getExecutionContext();
    cxt.put(ApplicationConst.PromotionKeys.CONVERT_PROC_ID,convertProcId);
    progressManagement.createConvertTableStatus(jobExecution, "ジョブ開始");
    //ログ
    EventLogMessage eventLogMessage1 = eventLoggerUtil.getEventLogMessage("ジョブ開始",
            facilityCd, "JobStartEndLIstener.beforeJob(JobExecution jobExecution)");
    eventLoggerUtil.recordLog(facilityCd, eventLogMessage1, LogLevel.INFO);
    //log.info("ジョブ開始");
    globalContext.tmpCopyCsvDir = "/tmpCopyCsvDir/";
    String tmpCopyCopyFilePath = inputFilePath + globalContext.tmpCopyCsvDir;
    Utils.deleteRecursively(tmpCopyCopyFilePath);
    // add #7339 AWS側アプリが起動しない途中から開始されない yangmj start
    // 処理対象のパス内のフォルダ構成を完了ファイル置き場にコピー

    if (isRestart == null || isRestart.isEmpty()) {
      // add #7339 AWS側アプリが起動しない途中から開始されない yangmj end
      // Zipファイルを検索し、見つかったら解凍する
      List<String> zipFileList;
      try {
        zipFileList = searchZipFile(inputFilePath);
      } catch (Exception e) {
        progressManagement.createConvertTableStatus(jobExecution, "Zipファイル検索中にエラー");
        //ログ
        EventLogMessage eventLogMessage2 = eventLoggerUtil.getEventLogMessage("Zipファイル検索中にエラー：" + e.getMessage(),
                facilityCd, "JobStartEndLIstener.beforeJob(JobExecution jobExecution)");
        eventLoggerUtil.recordLog(facilityCd, eventLogMessage2, LogLevel.INFO);
        //log.info("Zipファイル検索中にエラー：" + e.getMessage());
        stopReason = StopReason.ERROR;
        return;
      }

      // フォルダ内のZipファイルを解凍する
      for (String zipFilePath : zipFileList) {
        //ログ
        EventLogMessage eventLogMessage3 = eventLoggerUtil.getEventLogMessage("Zipファイル解凍中：" + zipFilePath,
                facilityCd, "JobStartEndLIstener.beforeJob(JobExecution jobExecution)");
        eventLoggerUtil.recordLog(facilityCd, eventLogMessage3, LogLevel.INFO);
        //log.info("Zipファイル解凍中：" + zipFilePath);
        progressManagement.createConvertTableStatus(jobExecution, "Zipファイル解凍中：" + zipFilePath);
        ZipFile targetZipFile = new ZipFile(zipFilePath,zipFileConfig.getPassword().toCharArray());
        try {
          targetZipFile.extractAll(inputFilePath);
          // add 2020-11-20 解凍成功状態出力を追加する  う start
          progressManagement.createConvertTableStatus(jobExecution, "Zipファイル解凍成功!");
          File dir= new File(targetZipFile.toString());
          String archiveBaseName = dir.getName();
          Path dirPath = Paths.get(dir.getParent());
          if (!Files.exists(dirPath) || !Files.isDirectory(dirPath)) {
            throw new IllegalArgumentException("設定のパスは無効です。");
          }
          // ボリューム ファイルに一致する式を構築する
          String baseName = archiveBaseName.substring(0,archiveBaseName.lastIndexOf('.'));
          baseName = fileNameToMatch(baseName);
          Pattern volumePattern = Pattern.compile(baseName + "\\.(z\\d+)?");
          // ディレクトリ内のすべてのファイルを取得する
          File[] files = dirPath.toFile().listFiles();
          if(files != null){
            for (File file : files) {
              //チェックファイル
              if (file.isFile() && (fileNameToMatch(file.getName()).startsWith(baseName) && volumePattern.matcher(file.getName()).matches())) {
                file.delete();
              }
            }
          }
          dir.delete();
          // add 2020-11-20 解凍成功状態出力を追加する  う end
        } catch (Exception e) {
          progressManagement.createConvertTableStatus(jobExecution, "Zipファイル解凍中にエラー");
          //ログ
          EventLogMessage eventLogMessage4 = eventLoggerUtil.getEventLogMessage("Zipファイル解凍中にエラー：" + e.getMessage(),
                  facilityCd, "JobStartEndLIstener.beforeJob(JobExecution jobExecution)");
          eventLoggerUtil.recordLog(facilityCd, eventLogMessage4, LogLevel.INFO);
          //log.info("Zipファイル解凍中にエラー：" + e.getMessage());
          stopReason = StopReason.ERROR;
          return;
        }
      }

      //add 11162 start
      processIsThreadForMntMotionRecord(facilityCd, globalContext);
      //add 11162 end

      // add #11210 djy start
      processDelMstTreatmentStatusLayout(inputFilePath,facilityCd);
      processDelTrendGraphMonitorSet(inputFilePath,facilityCd);
      processDelExam(inputFilePath,facilityCd);
      // add #11210 djy end

      //add #10675 & #10676 djy start
      processDelOrdMainRst(inputFilePath,facilityCd);
      //add #10675 & #10676 djy end

            //7997
            try {
                File dir = new File(inputFilePath);
                filePatDel = null;
                findFileRecursively("SYS_PAT_SERIES_FACILITY.txt", dir, false);
                if (filePatDel != null) {
                    DataSource machineDsNkk5 = (DataSource) appContext.getBean(ApplicationConst.DbType.NKK5);
                    DataSource machineDsConvert = (DataSource) appContext.getBean(ApplicationConst.DbType.CONVERT);
                    JdbcTemplate jdbcTemplateConvert = new JdbcTemplate(machineDsConvert);
                    JdbcTemplate jdbcTemplateNkk5= new JdbcTemplate(machineDsNkk5);
                    File f = new File(filePatDel);
                    if (f.exists()) {
                        try (FileInputStream fin = new FileInputStream(filePatDel);
                             InputStreamReader reader = new InputStreamReader(fin);
                             BufferedReader buffReader = new BufferedReader(reader)) {
                            String line;
                            boolean isHeader = true;
                            while ((line = buffReader.readLine()) != null) {
                                if (isHeader) {
                                    isHeader = false;
                                    continue;
                                }

                                String[] cols = line.split(",", -1);

                                String patId = cols[0];
                                String facilityCdLoop = cols[1];
                                String procDate = cols[2];

                                List<OrdMain> ordMainList = new ArrayList<>();
                                String sql = "SELECT * FROM ord_main WHERE  facility_cd = :facility_cd and rst_dialysis_state='0' and fn_pat_id =:fn_pat_id and treat_date >=:treat_date";

                                MapSqlParameterSource params = new MapSqlParameterSource();
                                params.addValue("facility_cd", facilityCdLoop);
                                params.addValue("fn_pat_id", patId);
                                params.addValue("treat_date", procDate);
                                ordMainList = batchQuery(jdbcTemplateNkk5, sql, params, OrdMain.class);
                                EventLogMessage eventLogMessage = eventLoggerUtil.getEventLogMessage(patId+"=================患者転院指示削除処理Start=============="+ordMainList.size() +"行目",
                                        facilityCd, "delOrdMains");
                                eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.INFO);
                                upPatExamMain(patId, facilityCdLoop, procDate, jdbcTemplateConvert, jdbcTemplateNkk5);
                                if (!ordMainList.isEmpty()){
                                    delOrdMains(ordMainList, false, jdbcTemplateConvert, jdbcTemplateNkk5, facilityCd);
                                }
                                eventLogMessage = eventLoggerUtil.getEventLogMessage(patId+"=================患者転院指示削除処理End=============="+ordMainList.size() +"行目",
                                        facilityCd, "delOrdMains");
                                eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.INFO);
                            }
                        } catch (Exception e) {
                            eventLoggerUtil.recordLog(
                                    facilityCd,
                                    eventLoggerUtil.getEventLogMessage(
                                            "beforeJob(JobExecution jobExecution) ジョブの開始前に実行：" + EventLoggerUtil.excetionStackTraceToString(e),
                                            facilityCd,
                                            e.getClass().getName() + ".beforeJob()"),
                                    LogLevel.ERROR);
                        }
                        f.delete();
                    }
                }
            } catch (Exception e) {
                //ログ
                eventLoggerUtil.recordLog(
                        facilityCd,
                        eventLoggerUtil.getEventLogMessage(
                                "JobStartEndLIstener.afterJob(JobExecution jobExecution) 患者転院 ord_main 削除失敗：" + EventLoggerUtil.excetionStackTraceToString(e),
                                facilityCd,
                                e.getClass().getName() + ".beforeJob()"),
                        LogLevel.ERROR);
            }
            //7997

            // mod 10378-24-4 PatTreatmentPattern再構築対応 zkm start
      // patient_treatment_pattern 削除処理
      processDelPatientTreatmentPattern(inputFilePath, facilityCd, globalContext);
      // mod 10378-24-4 PatTreatmentPattern再構築対応 zkm end

      // add #7339 AWS側アプリが起動しない途中から開始されない yangmj start
    }
    // add #7339 AWS側アプリが起動しない途中から開始されない yangmj end

    // 処理対象のSQLファイルを検索し、カンマ区切りでジョブ実行情報へ格納
    List<String> sqlFileList;
    try {
      sqlFileList = searchSqlFile(inputFilePath);

      //add  ZC 7339 START
      File fileProductionDbToConvertDbStep = new File(inputFilePath + "/Filelength.txt");
      if(!fileProductionDbToConvertDbStep.exists() && !sqlFileList.isEmpty()){
        long allFileSize=0;
        for (String filePath : sqlFileList) {
          File file = new File(filePath);
          allFileSize = new BigDecimal(allFileSize).add(new BigDecimal(file.length())).longValue();
        }
        utils.writeFile(inputFilePath + "/Filelength.txt", String.valueOf(allFileSize), facilityCd);
      }
      //add ZC 7339 END
      // 本番DBからコンバートDBにcopyCommandファイルを削除 一行目：テープル、二～四行目：sqlCommand

      // add 2022-11-15 bug #7882 患者イベントのVA画像がコンバートされていない 孫 start
      // 患者イベントの参照ファイル参照ファイル(.sql)を除去する
      String checkKey = File.separator + "AddedFiles" + File.separator;
      int sqlFileCnt = sqlFileList.size()-1;
      for (int i=sqlFileCnt; i>=0; i--) {
        String checkFileName = sqlFileList.get(i);
        if (checkFileName.contains(checkKey)) {
          sqlFileList.remove(i);
        }
      }
      // add 2022-11-15 bug #7882 患者イベントのVA画像がコンバートされていない 孫 end
    } catch (Exception e) {
      progressManagement.createConvertTableStatus(jobExecution, "SQLファイル検索中にエラー");
      //ログ
      EventLogMessage eventLogMessage10 = eventLoggerUtil.getEventLogMessage("SQLファイル検索中にエラー：" + e.getMessage(),
              facilityCd, "JobStartEndLIstener.beforeJob(JobExecution jobExecution)");
      eventLoggerUtil.recordLog(facilityCd, eventLogMessage10, LogLevel.INFO);
      //log.info("SQLファイル検索中にエラー：" + e.getMessage());
      stopReason = StopReason.ERROR;
      return;
    }
    if (sqlFileList.isEmpty() && isRestart == null) {
      jobExecution.stop();
      progressManagement.createConvertTableStatus(jobExecution, "処理対象のSQLファイルなし");
      //ログ
      EventLogMessage eventLogMessage11 = eventLoggerUtil.getEventLogMessage("処理対象のSQLファイルなし",
              facilityCd, "JobStartEndLIstener.beforeJob(JobExecution jobExecution)");
      eventLoggerUtil.recordLog(facilityCd, eventLogMessage11, LogLevel.INFO);
      //log.info("処理対象のSQLファイルなし");
      stopReason = StopReason.NO_TARGET;
      return;
    }

    // sqlFileListを優先度順にソート
    sqlFileList = convertPriorityConfig.sortSqlFileList(sqlFileList);
    String sqlFiles = String.join(",", sqlFileList);
    // カンマ区切りにしてジョブ実行情報に格納
    cxt.put(ApplicationConst.PromotionKeys.SQL_FILE_LIST, sqlFiles);
    // add #10859-6 djy start
    List<String> tableCountList =new ArrayList<>();
    for (String s : sqlFileList) {
      String tableName = PsqlCopyUtils.getTableName(s);
      long count = sqlFileList.stream().filter(c -> tableName.equals(PsqlCopyUtils.getTableName(c))).count();
      tableCountList.add(s+count);
    }
    String sqlCountFiles = String.join(",", tableCountList);
    cxt.put(ApplicationConst.PromotionKeys.SQL_FILE_TABLE_COUNT_LIST, sqlCountFiles);
    // add #10859-6 djy end
    Utils.createDirectory(tmpCopyCopyFilePath);
    localGlobal.set(globalContext);
  }

    private static GlobalContext initGlobalContext(String facilityCd) {
        GlobalContext globalContext = localGlobal.get();
        globalContext.facilityCd = facilityCd;
        globalContext.materialStatus = "初回";
        globalContext.keepKeys = new ArrayList<>();
        globalContext.updateKeyList = new ArrayList<>();
        globalContext.MstMachineList = new ArrayList<>();
        globalContext.convertComsvList = new ArrayList<>();
        globalContext.sqlNewKeys = "";
        globalContext.seq = 0;
        globalContext.seqRegist = 0;
        globalContext.seqKey = "0";
        globalContext.insFnKey = "";
        globalContext.insFnValue = "";
        globalContext.hasFacilityCd = false;
        globalContext.befKeyList = "";
        globalContext.sqlDisNoKeys = "";
        globalContext.insFnDisKey = "";
        globalContext.picPath = "";
        globalContext.isThread = false;
        return globalContext;
    }

  /**
   * mnt_motion_record を copy する際に、AUTOVACUUM の実行時間を確保する。
   */
  private void processIsThreadForMntMotionRecord(String facilityCd, GlobalContext globalContext) {
    try {
      String sqlps="select  count(*) from  mst_facility where facility_cd not in (select facility_cd from mnt_facility_cancel_manage)";
      Integer facilityCount = jdbcTemplateNkk5.queryForObject(sqlps, Integer.class);
      if(facilityCount > 2){
        globalContext.isThread=true;
      }else{
        globalContext.isThread=false;
      }
    }catch (Exception ex) {
      EventLogMessage eventLogMessagex = eventLoggerUtil.getEventLogMessage("詳細なエラー情報：" + ex.toString(),
              facilityCd, "BatchCsvWriterDb.isThread()");
      eventLoggerUtil.recordLog(facilityCd, eventLogMessagex, LogLevel.ERROR);
      globalContext.isThread=true;
    }
  }

  /**
   * mst_treatment_status_layout 削除処理
   * @param inputFilePath
   * @param facilityCd
   */
  private void processDelMstTreatmentStatusLayout(String inputFilePath, String facilityCd) {
    try {
      File dir = new File(inputFilePath);
      filePatDel = null;
      findFileRecursively("DelTreatement.txt", dir, false);
      if (filePatDel != null) {
        File f = new File(filePatDel);
        if (f.exists()) {
          try (FileInputStream fin = new FileInputStream(filePatDel);
               InputStreamReader reader = new InputStreamReader(fin);
               BufferedReader buffReader = new BufferedReader(reader)) {
            String strTmp = "";
            List<String> layoutNoList = new ArrayList<>();
            while ((strTmp = buffReader.readLine()) != null) {
              layoutNoList.addAll(Arrays.stream(strTmp.split(",")).collect(Collectors.toList()));
            }
            String sql = "delete from mst_treatment_status_layout where facility_cd = :facility_cd and fn_layout_no in (:fn_layout_no)";
            MapSqlParameterSource params = new MapSqlParameterSource();
            params.addValue("facility_cd", facilityCd);
            params.addValue("fn_layout_no", layoutNoList);
            batchUpdate(jdbcTemplateConvert, sql, params);
            batchUpdate(jdbcTemplateNkk5, sql, params);
          } catch (Exception e) {
            eventLoggerUtil.recordLog(
                    facilityCd,
                    eventLoggerUtil.getEventLogMessage(
                            "processDelMstTreatmentStatusLayout(String inputFilePath, String facilityCd) mst_treatment_status_layout 削除処理：" + EventLoggerUtil.excetionStackTraceToString(e),
                            facilityCd,
                            e.getClass().getName() + ".processDelMstTreatmentStatusLayout()"),
                    LogLevel.ERROR);
          }
          f.delete();
        }
      }
    } catch (Exception e) {
      //ログ
      eventLoggerUtil.recordLog(
              facilityCd,
              eventLoggerUtil.getEventLogMessage(
                      "JobStartEndLIstener.processDelMstTreatmentStatusLayout(String inputFilePath, String facilityCd) mst_treatment_status_layout 削除処理：" + EventLoggerUtil.excetionStackTraceToString(e),
                      facilityCd,
                      e.getClass().getName() + ".processDelMstTreatmentStatusLayout()"),
              LogLevel.ERROR);
    }
  }

  /**
   * mst_trend_graph_monitor_set 削除処理
   * @param inputFilePath
   * @param facilityCd
   */
  private void processDelTrendGraphMonitorSet(String inputFilePath,String facilityCd) {
    try {
      File dir = new File(inputFilePath);
      filePatDel = null;
      // add #11546 hyl start
      findFileRecursively("DelTrendGraphMonitorSet.txt", dir, false);
      if (filePatDel != null) {
        DataSource machineDsNkk5 = (DataSource) appContext.getBean(ApplicationConst.DbType.NKK5);
        DataSource machineDsConvert = (DataSource) appContext.getBean(ApplicationConst.DbType.CONVERT);
        JdbcTemplate jdbcTemplateConvert = new JdbcTemplate(machineDsConvert);
        JdbcTemplate jdbcTemplateNkk5= new JdbcTemplate(machineDsNkk5);
        File f = new File(filePatDel);
        if (f.exists()) {
          try (FileInputStream fin = new FileInputStream(filePatDel);
               InputStreamReader reader = new InputStreamReader(fin);
               BufferedReader buffReader = new BufferedReader(reader)) {
            String strTmp = "";
            List<String> layoutNoList = new ArrayList<>();
            while ((strTmp = buffReader.readLine()) != null) {
              layoutNoList.addAll(Arrays.stream(strTmp.split(",")).collect(Collectors.toList()));
            }
            String sql = "delete from mst_trend_graph_monitor_set where facility_cd = :facility_cd and fn_monitor_set_cd||model in (:fn_monitor_set_cd)";
            MapSqlParameterSource params = new MapSqlParameterSource();
            params.addValue("facility_cd", facilityCd);
            params.addValue("fn_monitor_set_cd", layoutNoList);
            batchUpdate(jdbcTemplateConvert, sql, params);
            batchUpdate(jdbcTemplateNkk5, sql, params);
          } catch (Exception e) {
            eventLoggerUtil.recordLog(
                    facilityCd,
                    eventLoggerUtil.getEventLogMessage(
                            "processDelTrendGraphMonitorSet(String inputFilePath,String facilityCd) mst_trend_graph_monitor_set 削除処理：" + EventLoggerUtil.excetionStackTraceToString(e),
                            facilityCd,
                            e.getClass().getName() + ".processDelTrendGraphMonitorSet()"),
                    LogLevel.ERROR);
            throw e;
          }
          f.delete();
        }
      }
    } catch (Exception e) {
      //ログ
      eventLoggerUtil.recordLog(
              facilityCd,
              eventLoggerUtil.getEventLogMessage(
                      "JobStartEndLIstener.processDelTrendGraphMonitorSet(String inputFilePath,String facilityCd) mst_trend_graph_monitor_set 削除失敗：" + EventLoggerUtil.excetionStackTraceToString(e),
                      facilityCd,
                      e.getClass().getName() + ".processDelTrendGraphMonitorSet()"),
              LogLevel.ERROR);
    }
  }

  /**
   * pat_exam_main 削除処理
   * @param inputFilePath
   * @param facilityCd
   */
  private void processDelExam(String inputFilePath,String facilityCd) {
    try {
      File dir = new File(inputFilePath);
      filePatDel = null;
      // add #11546 hyl end
      findFileRecursively("DelExam.txt", dir, false);
      if (filePatDel != null) {
        DataSource machineDsNkk5 = (DataSource) appContext.getBean(ApplicationConst.DbType.NKK5);
        DataSource machineDsConvert = (DataSource) appContext.getBean(ApplicationConst.DbType.CONVERT);
        JdbcTemplate jdbcTemplateConvert = new JdbcTemplate(machineDsConvert);
        JdbcTemplate jdbcTemplateNkk5= new JdbcTemplate(machineDsNkk5);
        File f = new File(filePatDel);
        if (f.exists()) {
          try (FileInputStream fin = new FileInputStream(filePatDel);
               InputStreamReader reader = new InputStreamReader(fin);
               BufferedReader buffReader = new BufferedReader(reader)) {
            String strTmp = "";
            List<String> delExamList = new ArrayList<>();
            while ((strTmp = buffReader.readLine()) != null) {
              delExamList.addAll(Arrays.stream(strTmp.split(",")).collect(Collectors.toList()));
            }
            String sql = "update pat_exam_main set is_del = '1' , up_date = CURRENT_TIMESTAMP where facility_cd = :facility_cd and "+
                    "fn_pat_id||TO_CHAR(reg_date,'yyyy-mm-dd hh24:mi:ss')||TO_CHAR(reg_exam_date,'yyyy-mm-dd hh24:mi:ss')||reg_order_class in (:delExamList)";
            MapSqlParameterSource params = new MapSqlParameterSource();
            params.addValue("facility_cd", facilityCd);
            params.addValue("delExamList", delExamList);
            batchUpdate(jdbcTemplateConvert, sql, params);
            batchUpdate(jdbcTemplateNkk5, sql, params);
          } catch (Exception e) {
            eventLoggerUtil.recordLog(
                    facilityCd,
                    eventLoggerUtil.getEventLogMessage(
                            "processDelExam(String inputFilePath,String facilityCd) pat_exam_main 削除処理：" + EventLoggerUtil.excetionStackTraceToString(e),
                            facilityCd,
                            e.getClass().getName() + ".processDelExam()"),
                    LogLevel.ERROR);
            throw e;
          }
          f.delete();
        }
      }
    } catch (Exception e) {
      //ログ
      eventLoggerUtil.recordLog(
              facilityCd,
              eventLoggerUtil.getEventLogMessage(
                      "JobStartEndLIstener.processDelExam(String inputFilePath,String facilityCd) pat_exam_main 削除処理：" + EventLoggerUtil.excetionStackTraceToString(e),
                      facilityCd,
                      e.getClass().getName() + ".processDelExam()"),
              LogLevel.ERROR);
    }
  }

  /**
   * ord_main 実績削除処理
   * @param inputFilePath
   * @param facilityCd
   */
  private void processDelOrdMainRst(String inputFilePath,String facilityCd) {
    try {
      File dir = new File(inputFilePath);
      filePatDel = null;
      findFileRecursively("DelOrdMainRst.txt", dir, false);
      if (filePatDel != null) {
        DataSource machineDsNkk5 = (DataSource) appContext.getBean(ApplicationConst.DbType.NKK5);
        DataSource machineDsConvert = (DataSource) appContext.getBean(ApplicationConst.DbType.CONVERT);
        JdbcTemplate jdbcTemplateConvert = new JdbcTemplate(machineDsConvert);
        JdbcTemplate jdbcTemplateNkk5= new JdbcTemplate(machineDsNkk5);
        File f = new File(filePatDel);
        if (f.exists()) {
          try (FileInputStream fin = new FileInputStream(filePatDel);
               InputStreamReader reader = new InputStreamReader(fin);
               BufferedReader buffReader = new BufferedReader(reader)) {
            String strTmp = "";
            int rowNo = 1;
            while ((strTmp = buffReader.readLine()) != null) {
              List<OrdMain> ordMainList = new ArrayList<>();
              String sql = "SELECT * FROM ord_main WHERE  facility_cd = :facility_cd and rst_dialysis_state = '6' and rst_fn_dialysis_no in (:dialysis_no)";
              List<Long> dialysisNoList = Arrays.stream(strTmp.split(",")).map(m->Long.parseLong(m)).collect(Collectors.toList());
              MapSqlParameterSource params = new MapSqlParameterSource();
              params.addValue("facility_cd", facilityCd);
              params.addValue("dialysis_no", dialysisNoList);
              ordMainList = batchQuery(jdbcTemplateNkk5, sql, params, OrdMain.class);
              if (!ordMainList.isEmpty() && ordMainList.size() <= 1000) {
                EventLogMessage eventLogMessage = eventLoggerUtil.getEventLogMessage("=================実績削除処理Start=============="+rowNo+"行目",
                        facilityCd, "delOrdMains");
                eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.INFO);
                delOrdMains(ordMainList, true, jdbcTemplateConvert, jdbcTemplateNkk5, facilityCd);
                eventLogMessage = eventLoggerUtil.getEventLogMessage("=================実績削除処理End=============="+rowNo+"行目",
                        facilityCd, "delOrdMains");
                eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.INFO);
              }
              rowNo++;
            }
          } catch (Exception e) {
            eventLoggerUtil.recordLog(
                    facilityCd,
                    eventLoggerUtil.getEventLogMessage(
                            "processDelOrdMainRst(String inputFilePath,String facilityCd)：" + EventLoggerUtil.excetionStackTraceToString(e),
                            facilityCd,
                            e.getClass().getName() + ".processDelMstTreatmentStatusLayout()"),
                    LogLevel.ERROR);
            throw e;
          }
          f.delete();
        }
      }
    } catch (Exception e) {
      //ログ
      eventLoggerUtil.recordLog(
              facilityCd,
              eventLoggerUtil.getEventLogMessage(
                      "processDelOrdMainRst.processDelOrdMainRst(String inputFilePath,String facilityCd) ord_main 実績削除処理失敗：" + EventLoggerUtil.excetionStackTraceToString(e),
                      facilityCd,
                      e.getClass().getName() + ".processDelOrdMainRst()"),
              LogLevel.ERROR);
    }
  }

  /**
   * patient_treatment_pattern 削除処理
   * @param inputFilePath
   * @param facilityCd
   */
  private void processDelPatientTreatmentPattern(String inputFilePath,String facilityCd, GlobalContext globalContext) {
    File dir = new File(inputFilePath);
    filePatDel = null;
    findFileRecursively("DelPatientTreatmentPattern.txt", dir, false);
    if (filePatDel != null) {
      File f = new File(filePatDel);
      if (f.exists()) {
        try(BufferedReader buffReader = new BufferedReader(new InputStreamReader(new FileInputStream(filePatDel)))) {
          String strTmp = "";
          while((strTmp = buffReader.readLine())!=null){
            globalContext.patIds = Arrays.asList(strTmp.split(","));
          }
        } catch (Exception e){
          eventLoggerUtil.recordLog(
                  facilityCd,
                  eventLoggerUtil.getEventLogMessage(
                          "JobStartEndLIstener.processDelPatientTreatmentPattern(String inputFilePath,String facilityCd) patient_treatment_pattern 削除処理：" + EventLoggerUtil.excetionStackTraceToString(e),
                          facilityCd,
                          e.getClass().getName() + ".processDelPatientTreatmentPattern()"),
                  LogLevel.ERROR);
        }
        if (!CollectionUtils.isEmpty(globalContext.patIds)) {
          List<Long> patIds = getPatIdsByFnPatIds(globalContext.patIds, facilityCd);
          if (patIds != null){
            deletePatTreatmentPatternByPatIds(patIds, facilityCd);
          }
        }
        f.delete();
      }
    }
  }


  private String fileNameToMatch(String fileName){
    if(fileName==null) {
      return null;
    }
    else {
      return fileName.replace("[", "\\[").replace("]", "\\]").replace("(", "\\(").replace(")", "\\)");
    }
  }

  // mod #10418 SQL注入対策：IN句を使用してパラメータバインディング start
  private List<Long> getPatIdsByFnPatIds(List<String> fnPatId, String facilityCd){
    String sql = "SELECT pat_id FROM pat_personal_main WHERE fn_pat_id IN (:fnPatIds) AND is_del = '0' AND facility_cd = :facilityCd";
    DataSource ds = (DataSource) appContext.getBean(ApplicationConst.DbType.CONVERT);
    NamedParameterJdbcTemplate namedJdbcTemplate = new NamedParameterJdbcTemplate(ds);

    MapSqlParameterSource params = new MapSqlParameterSource();
    params.addValue("fnPatIds", fnPatId);
    params.addValue("facilityCd", facilityCd);

    List<Long> patIdList = namedJdbcTemplate.queryForList(sql, params, Long.class);
    if (patIdList.isEmpty()) {
      return null;
    }
    return patIdList;
  }
  // mod #10418 SQL注入対策：IN句を使用してパラメータバインディング end

  // mod #10418 SQL注入対策：IN句を使用してパラメータバインディング start
  private void deletePatTreatmentPatternByPatIds(List<Long> patIds, String facilityCd){

    String sql = "DELETE FROM pat_treatment_pattern WHERE facility_cd = :facilityCd AND pat_id IN (:patIds)";

    MapSqlParameterSource params = new MapSqlParameterSource();
    params.addValue("facilityCd", facilityCd);
    params.addValue("patIds", patIds);

    DataSource patTreatPatternDsC = (DataSource) appContext.getBean(ApplicationConst.DbType.CONVERT);
    NamedParameterJdbcTemplate machineJdbcTemplateC = new NamedParameterJdbcTemplate(patTreatPatternDsC);
    try{
      machineJdbcTemplateC.update(sql, params);
    }catch (Exception e){
      EventLogMessage eventLogMessage = eventLoggerUtil.getEventLogMessage("Failed to delete the old pat_treatment_pattern,"+e.getMessage(),
              facilityCd, "deletePatTreatmentPatternByPatIds_CONV");
      eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.ERROR);
    }

    DataSource patTreatPatternDs = (DataSource) appContext.getBean(ApplicationConst.DbType.NKK5);
    NamedParameterJdbcTemplate machineJdbcTemplate = new NamedParameterJdbcTemplate(patTreatPatternDs);
    try{
      machineJdbcTemplate.update(sql, params);
    }catch (Exception e){
      EventLogMessage eventLogMessage = eventLoggerUtil.getEventLogMessage("Failed to delete the old pat_treatment_pattern,"+e.getMessage(),
              facilityCd, "deletePatTreatmentPatternByPatIds_NKK5");
      eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.ERROR);
    }
  }
  // mod #10418 SQL注入対策：IN句を使用してパラメータバインディング end

  private List<String> searchZipFile(String inputFilePath) throws IOException {

    List<String> zipFileList = new ArrayList<String>();
    zipFileList = FileVisitor.getZipFileList(inputFilePath);
    return zipFileList;
  }

  private List<String> searchSqlFile(String inputFilePath) throws IOException {

    List<String> sqlFileList = new ArrayList<String>();
    sqlFileList = FileVisitor.getSqlFileList(inputFilePath);
    return sqlFileList;
  }
  /**
   * 指定されたディレクトリ内でファイルを再帰的に検索する
   *
   * @param filename 検索対象のファイル名
   * @param dir 検索を開始するディレクトリ
   * @param flag 検索状態フラグ（見つかった場合はtrueに設定される）
   */
  static void findFileRecursively(String filename,File dir,boolean flag)
  {
    File[]files=dir.listFiles();
    for(File file:files)
    {
      if(file.isDirectory())
      {
        findFileRecursively(filename,file.getAbsoluteFile(),flag);
      }
      if(file.isFile() && filename.equals(file.getName()))
      {
        flag=true;
        filePatDel =file.getAbsolutePath();
        break;
      }
    }
    if(flag)
      return;
    else
    {
      return;
    }
  }
  // ジョブの終了後に実行
  @Override
  public void afterJob(JobExecution jobExecution) {
        GlobalContext globalContext = localGlobal.get();

        //add #12229 start
        masterDataService.reset(globalContext);
        //add #12229 end
        try {
            localGlobal.remove();
        } catch (Exception e) {
            System.out.println("localGlobal-del-ERROR");
        }
        JobParameters jobParameters = jobExecution.getJobParameters();
        String facilityCd = jobParameters.getString(JobParameterKeys.FACILITY_CD);
    eventLoggerUtil.recordLog(facilityCd, eventLoggerUtil.getEventLogMessage("====== afterJob  start ======",
            facilityCd, "afterJob"), LogLevel.INFO);
    if (globalContext.MstMachineList != null) {
        globalContext.MstMachineList.clear();
    }
    super.afterJob(jobExecution);
    String facility_cd = jobExecution.getJobParameters().getString(JobParameterKeys.FACILITY_CD);
    long jobInstanceId = jobExecution.getJobInstance().getInstanceId();
    String jobName = jobExecution.getJobInstance().getJobName();
    int convertProcId = progressManagement.getConvertProcId(facility_cd);
    String exitCode = jobExecution.getExitStatus().getExitCode();
    String inputFilePath = jobExecution.getJobParameters().getString(JobParameterKeys.INPUT_FILE_PATH).toString();

    //#12548 コンバートツールでコンバート後に実行計画の更新を強制すること。 start
    File folder = new File(inputFilePath);
    boolean containsDiffFolder = folder.exists() && folder.isDirectory()
            && Arrays.stream(folder.listFiles())
            .anyMatch(f -> f.isDirectory() && f.getName().contains("[diff]"));
    //#12548 コンバートツールでコンバート後に実行計画の更新を強制すること。 start
    String selectSql = "SELECT 'TS' || SUBSTR(fn_set_medicine_cd, 3) " +
            "FROM mst_medicine_mix " +
            "WHERE facility_cd = ? " +
            "AND class_cd NOT IN (SELECT class_cd FROM mst_medicine_class WHERE fn_class_cd IN ('302', '303') AND facility_cd = ?)";

    eventLoggerUtil.recordLog(facilityCd, eventLoggerUtil.getEventLogMessage("====== afterJob  mst_medicine 削除 start ======",
            facilityCd, "afterJob"), LogLevel.INFO);

    try {
      List<String> fn_set_medicine_cd_list = jdbcTemplateConvert.queryForList(selectSql, new Object[]{facilityCd, facilityCd}, String.class);
      String deleteSql = "DELETE FROM mst_medicine WHERE facility_cd = ? AND fn_medicine_cd IN (?)";
      executeBatchUpdate(deleteSql, fn_set_medicine_cd_list, facilityCd, jdbcTemplateConvert);
      executeBatchUpdate(deleteSql, fn_set_medicine_cd_list, facilityCd, jdbcTemplateNkk5);
    } catch (DataAccessException e) {

      eventLoggerUtil.recordLog(
              facility_cd,
              eventLoggerUtil.getEventLogMessage(
                      "JobStartEndLIstener.afterJob(JobExecution jobExecution) ジョブの終了後に実行：" + EventLoggerUtil.excetionStackTraceToString(e),
                      facility_cd,
                      e.getClass().getName() + ".afterJob()"),
              LogLevel.ERROR);
    }

    // pat_group_detail 削除処理
    processDelPatGroupDetail(inputFilePath,facility_cd);

    //10093 start
    // ord_main 削除処理
    processDelOrdMain(inputFilePath,facility_cd);
    //10093 end

    // mst_user_authentication 削除処理
    processDelMstUserAuthentication(facility_cd);

    //10205 mst_comsv_setting

    // mst_holiday 削除処理
    processDelMstHoliday(facility_cd);

    //10159 start
    // mnt_weight_state 追加処理
    processAddMntWeightState(facility_cd);
    //10159 end

    // sch_ext_end_date 更新処理
    processUpdateSchExtEndDate(inputFilePath,facility_cd);

    //add 9862 zc
    /**
     * 患者イベントが一部コンバートされていない,8585に対して行った性能最適化は、もともとCOPYから今回以降に実行され、移植全体の導入が終了した後に統一的に実行された
     */

    // ord_main登録の場合、pat_eventには、項目「ord_no」を更新
    processUpdateOrdNoInPatEvent(facility_cd);

    //9778  start
    //差分ord_main登録の場合、ord_treat_condition、項目「ord_no」を更新
    processUpdateOrdNoInOrdTreatCondition(inputFilePath,facility_cd);
    //9778  end

    // add #10859-6 djy start
    eventLoggerUtil.recordLog(facilityCd, eventLoggerUtil.getEventLogMessage("====== 次患者更新 start ======",
            facilityCd, "afterJob"), LogLevel.INFO);
    progressManagement.createConvertTableStatus(jobExecution, "次患者更新 開始");
    setNextPatInfoAllBed(jdbcTemplateNkk5, facilityCd);
    progressManagement.createConvertTableStatus(jobExecution, "次患者更新 終了");
    eventLoggerUtil.recordLog(facilityCd, eventLoggerUtil.getEventLogMessage("====== 次患者更新 end ======",
            facilityCd, "afterJob"), LogLevel.INFO);
    // add #10859-6 djy end
    if (exitCode.equals(ExitStatus.COMPLETED.getExitCode())) {

      eventLoggerUtil.recordLog(facilityCd, eventLoggerUtil.getEventLogMessage("====== ExitStatus.COMPLETED start ======",
              facilityCd, "afterJob"), LogLevel.INFO);

      // 正常終了
      // add 2022-11-15 bug #7882 患者イベントのVA画像がコンバートされていない 孫 start
      // 患者イベントのファイルを移動する
      //ログ
      EventLogMessage eventLogMessageS3_1 = eventLoggerUtil.getEventLogMessage("S3ファイル移動実行",
              facility_cd, "afterJob(JobExecution jobExecution)");
      eventLoggerUtil.recordLog(facility_cd, eventLogMessageS3_1, LogLevel.DEBUG);
      String resultMessage = "S3ファイル移動正常終了";
      if (!globalContext.picPath.isEmpty()) {
        File deFile = new File(globalContext.picPath);
        try {
          if (deFile.exists()) {
            FileUtils.cleanDirectory(deFile);
          }
        } catch (IOException e) {
          throw new RuntimeException(e);
        }
      }
      EventLogMessage eventLogMessageS3_2 = eventLoggerUtil.getEventLogMessage(resultMessage,
              facility_cd, "afterJob(JobExecution jobExecution)");
      eventLoggerUtil.recordLog(facility_cd, eventLogMessageS3_2, LogLevel.DEBUG);
      // add 2022-11-15 bug #7882 患者イベントのVA画像がコンバートされていない 孫 end

      //ログ
      EventLogMessage eventLogMessage12 = eventLoggerUtil.getEventLogMessage("ジョブ正常終了",
              facility_cd, "JobStartEndLIstener.afterJob(JobExecution jobExecution)");
      eventLoggerUtil.recordLog(facility_cd, eventLogMessage12, LogLevel.INFO);
      progressManagement.updateBatchStatus(convertProcId, facility_cd, progressManagement.COMPLETED, jobInstanceId, jobName);
      progressManagement.createConvertTableStatus(jobExecution, "ジョブ正常終了");
      // ディレクトリ削除
      try {
        String tmpCopyCopyFilePath = inputFilePath + globalContext.tmpCopyCsvDir;
        Utils.deleteRecursively(tmpCopyCopyFilePath);
        FileVisitor.deleteDirectoryIfEmpty(inputFilePath, "");
        //add  ZC 7339 START
        File fileDbStep = new File(inputFilePath + "/Filelength.txt");
        //add  ZC 7339 end
        fileDbStep.delete();
      } catch (Exception e) {
        eventLoggerUtil.recordLog(
                facility_cd,
                eventLoggerUtil.getEventLogMessage(
                        "JobStartEndLIstener.afterJob(JobExecution jobExecution) ジョブの終了後に実行：" + EventLoggerUtil.excetionStackTraceToString(e),
                        facility_cd,
                        e.getClass().getName() + ".afterJob()"),
                LogLevel.ERROR);
      }
      // add zl start
      // 差分パターンのキーリストをクリア
      globalContext.updateKeyList = new ArrayList<>();
      globalContext.maxPrimaryForConvert = 0;
      globalContext.maxPrimaryForDB5 = 0;
      // add #11162 mnt_motion_recordのパフォーマンス最適化 djy start
      globalContext.ordDeviceMap = null;
      // add #11162 mnt_motion_recordのパフォーマンス最適化 djy end
      // add #10859-6 djy start
      globalContext.AlreadyImportedTableSet = null;
      // add #10859-6 djy end
      // add zl end

      // add #12229 zc start
      globalContext.deviceEdgeNo = null;
      // add #12229 zc end

      //add #12229->12380 end
      globalContext.mstTreatmentSet.clear();
        //add #12229->12380 end

      eventLoggerUtil.recordLog(facilityCd, eventLoggerUtil.getEventLogMessage("====== ExitStatus.COMPLETED end ======",
              facilityCd, "afterJob"), LogLevel.INFO);

      //#12548 コンバートツールでコンバート後に実行計画の更新を強制すること。 start
      if(!containsDiffFolder){
        CompletableFuture.runAsync(() -> AnalyzeExample(facility_cd));
      }
      //#12548 コンバートツールでコンバート後に実行計画の更新を強制すること。 end

    } else if (exitCode.equals(ExitStatus.FAILED.getExitCode())) {

      eventLoggerUtil.recordLog(facilityCd, eventLoggerUtil.getEventLogMessage("====== ExitStatus.FAILED start ======",
              facilityCd, "afterJob"), LogLevel.INFO);

      // 異常終了
      //ログ
      EventLogMessage eventLogMessage17 = eventLoggerUtil.getEventLogMessage("ジョブ異常終了",
              facility_cd, "JobStartEndLIstener.afterJob(JobExecution jobExecution)");
      eventLoggerUtil.recordLog(facility_cd, eventLogMessage17, LogLevel.INFO);
      progressManagement.updateBatchStatus(convertProcId, facility_cd, progressManagement.FAILED, jobInstanceId, jobName);
      progressManagement.createConvertTableStatus(jobExecution, "ジョブ異常終了");
      // add FNSI-FNSI-ジョブ実行修正 楊 end

      eventLoggerUtil.recordLog(facilityCd, eventLoggerUtil.getEventLogMessage("====== ExitStatus.FAILED end ======",
              facilityCd, "afterJob"), LogLevel.INFO);

    } else if (exitCode.equals(ExitStatus.STOPPED.getExitCode())) {

      eventLoggerUtil.recordLog(facilityCd, eventLoggerUtil.getEventLogMessage("====== ExitStatus.STOPPED start ======",
              facilityCd, "afterJob"), LogLevel.INFO);

      if (stopReason == StopReason.MULTIPLE_ACTIVATION) {
        // ２重チェック時でジョブ停止時はステータスを更新しない
        //ログ
        EventLogMessage eventLogMessage21 = eventLoggerUtil.getEventLogMessage("ジョブ停止（２重起動チェック）",
                facility_cd, "JobStartEndLIstener.afterJob(JobExecution jobExecution)");
        eventLoggerUtil.recordLog(facility_cd, eventLogMessage21, LogLevel.INFO);
      } else if (stopReason == StopReason.NO_TARGET) {
        //ログ
        EventLogMessage eventLogMessage22 = eventLoggerUtil.getEventLogMessage("ジョブ停止（処理対象SQLファイルなし）",
                facility_cd, "JobStartEndLIstener.afterJob(JobExecution jobExecution)");
        eventLoggerUtil.recordLog(facility_cd, eventLogMessage22, LogLevel.INFO);
        progressManagement.updateBatchStatus(convertProcId, facility_cd, progressManagement.STOPPED, jobInstanceId, jobName);
        progressManagement.createConvertTableStatus(jobExecution, "ジョブ停止（処理対象SQLファイルなし）");
      } else {
        //ログ
        EventLogMessage eventLogMessage23 = eventLoggerUtil.getEventLogMessage("ジョブ停止（停止命令）",
                facility_cd, "JobStartEndLIstener.afterJob(JobExecution jobExecution)");
        eventLoggerUtil.recordLog(facility_cd, eventLogMessage23, LogLevel.INFO);
        progressManagement.updateBatchStatus(convertProcId, facility_cd, progressManagement.STOPPED, jobInstanceId, jobName);
        progressManagement.createConvertTableStatus(jobExecution, "ジョブ停止（停止命令）");

            }
      eventLoggerUtil.recordLog(facilityCd, eventLoggerUtil.getEventLogMessage("====== ExitStatus.STOPPED end ======",
              facilityCd, "afterJob"), LogLevel.INFO);

    }
  }
  //#12548 コンバートツールでコンバート後に実行計画の更新を強制すること。 start
  private void AnalyzeExample(String  facility_cd) {

    try {
            Thread.sleep(1000L * AWAIT);
            boolean ready = Optional.ofNullable(jdbcTemplateConvert.queryForObject(
                    "SELECT COUNT(*) = 0 FROM batch_convert_status WHERE status IN ('STARTED','STOPPING') AND job_name='ConvertJob'",
                    Boolean.class
            )).orElse(true);
            boolean dbReady = Optional.ofNullable(jdbcTemplateNkk5.queryForObject(
                    "SELECT COUNT(*) = 0 FROM pg_stat_activity WHERE state = 'active'  AND query LIKE 'ANALYZE%'  AND query LIKE '%mnt_motion_record%'",
                    Boolean.class)
            ).orElse(true);
            if(ready && dbReady){
                eventLoggerUtil.recordLog(facility_cd, eventLoggerUtil.getEventLogMessage("====== ANALYZE start ======",
                facility_cd, "afterJob"), LogLevel.INFO);

        jdbcTemplateNkk5.execute("ANALYZE");

        EventLogMessage eventLogMessage27 = eventLoggerUtil.getEventLogMessage("====== ANALYZE end ======",
                facility_cd, "JAnalyzeExample");
        eventLoggerUtil.recordLog(facility_cd, eventLogMessage27, LogLevel.INFO);
      }
    } catch (Exception e) {
      EventLogMessage eventLogMessage27 = eventLoggerUtil.getEventLogMessage("====== ANALYZE ERROR ======"+e.getMessage(),
              facility_cd, "JAnalyzeExample");
      eventLoggerUtil.recordLog(facility_cd, eventLogMessage27, LogLevel.ERROR);
    }
    //#12548 コンバートツールでコンバート後に実行計画の更新を強制すること。 end
  }
  /**
   * pat_group_detail 削除処理
   * @param inputFilePath
   * @param facilityCd
   */
  private void processDelPatGroupDetail(String inputFilePath,String facilityCd) {
    eventLoggerUtil.recordLog(facilityCd, eventLoggerUtil.getEventLogMessage("====== afterJob  pat_group_detail 削除 start ======",
            facilityCd, "afterJob"), LogLevel.INFO);
    try {
      Map<String, String> patIDMap = new HashMap<>();
      Map<String, String> patGroupMap = new HashMap<>();
      String pat_group_cd = "";
      String pat_id = "";
      // mod #10418 SQL注入対策：batchUpdateを使用してパラメータバインディング start
      List<Object[]> deleteParams = new ArrayList<>();
      // mod #10418 SQL注入対策：batchUpdateを使用してパラメータバインディング end
      filePatDel = null;
      File dir = new File(inputFilePath);
      findFileRecursively("Mst_DEL.txt", dir, false);
      if (filePatDel != null) {
        File f = new File(filePatDel);
        if (f.exists()) {
          try (FileInputStream fin = new FileInputStream(filePatDel);
               InputStreamReader reader = new InputStreamReader(fin);
               BufferedReader buffReader = new BufferedReader(reader)) {
            String strTmp = "";
            while ((strTmp = buffReader.readLine()) != null) {
              // mod #10418 SQL注入対策：パラメータバインディングを使用 start
              if (!patGroupMap.containsKey(strTmp.split("/")[0])) {
                String sql = "SELECT pat_group_cd FROM pat_group WHERE fn_pat_group_cd = ? and facility_cd = ?";
                List<String> pat_group_cd_list = jdbcTemplateConvert.queryForList(sql, new Object[]{strTmp.split("/")[0], facilityCd}, String.class);
                if (!pat_group_cd_list.isEmpty()) {
                  pat_group_cd = pat_group_cd_list.get(0);
                  //JVMキャッシュへの書き込み
                  patGroupMap.put(strTmp.split("/")[0], pat_group_cd);
                } else {
                  continue;
                }
              } else {
                pat_group_cd = patGroupMap.get(strTmp.split("/")[0]);
              }
              // mod #10418 SQL注入対策：パラメータバインディングを使用 end

              // mod #10418 SQL注入対策：パラメータバインディングを使用 start
              if (!patIDMap.containsKey(strTmp.split("/")[1])) {
                String sql = "SELECT pat_id FROM pat_personal_main WHERE fn_pat_id = ? and facility_cd = ?";
                List<String> pat_id_list = jdbcTemplateConvert.queryForList(sql, new Object[]{strTmp.split("/")[1], facilityCd}, String.class);
                if (!pat_id_list.isEmpty()) {
                  pat_id = pat_id_list.get(0);
                  //JVMキャッシュへの書き込み
                  patIDMap.put(strTmp.split("/")[1], pat_id);
                } else {
                  continue;
                }
              } else {
                pat_id = patIDMap.get(strTmp.split("/")[1]);
              }
              // mod #10418 SQL注入対策：パラメータバインディングを使用 end
              // mod #10418 SQL注入対策：batchUpdateを使用してパラメータバインディング start
              deleteParams.add(new Object[]{facilityCd, pat_group_cd, pat_id});
              // mod #10418 SQL注入対策：batchUpdateを使用してパラメータバインディング end
            }
            // mod #10418 SQL注入対策：batchUpdateを使用してパラメータバインディング start
            if (!deleteParams.isEmpty()) {
              String sql = "DELETE FROM pat_group_detail WHERE facility_cd = ? AND pat_group_cd = ? AND pat_id = ?";
              jdbcTemplateConvert.batchUpdate(sql, deleteParams);
              jdbcTemplateNkk5.batchUpdate(sql, deleteParams);
            }
            // mod #10418 SQL注入対策：batchUpdateを使用してパラメータバインディング end
          } catch (Exception e) {
            eventLoggerUtil.recordLog(
                    facilityCd,
                    eventLoggerUtil.getEventLogMessage(
                            "JobStartEndLIstener.processDelPatGroupDetail(String inputFilePath,String facilityCd) pat_group_detail 削除処理：" + EventLoggerUtil.excetionStackTraceToString(e),
                            facilityCd,
                            e.getClass().getName() + ".processDelPatGroupDetail()"),
                    LogLevel.ERROR);
          }
          f.delete();
        }
      }
    } catch (Exception e) {
      //ログ
      eventLoggerUtil.recordLog(
              facilityCd,
              eventLoggerUtil.getEventLogMessage(
                      "JobStartEndLIstener.processDelPatGroupDetail(String inputFilePath,String facilityCd) pat_group_detail 削除処理：" + EventLoggerUtil.excetionStackTraceToString(e),
                      facilityCd,
                      e.getClass().getName() + ".processDelPatGroupDetail()"),
              LogLevel.ERROR);
    }
  }

  /**
   * ord_main 削除処理
   * @param inputFilePath
   * @param facilityCd
   */
  private void processDelOrdMain(String inputFilePath,String facilityCd) {
    eventLoggerUtil.recordLog(facilityCd, eventLoggerUtil.getEventLogMessage("====== afterJob  ord_main 削除 start ======",
            facilityCd, "afterJob"), LogLevel.INFO);
    try {
      File dir = new File(inputFilePath);
      filePatDel = null;
      findFileRecursively("DelOrdMain.txt", dir, false);
      if (filePatDel != null) {
        File f = new File(filePatDel);
        if (f.exists()) {
          try (FileInputStream fin = new FileInputStream(filePatDel);
               InputStreamReader reader = new InputStreamReader(fin);
               BufferedReader buffReader = new BufferedReader(reader)) {

            //mod  #10675 & #10676 djy start
            String strTmp = "";
            int rowNo = 1;
            while ((strTmp = buffReader.readLine()) != null) {
              List<OrdMain> ordMainList = new ArrayList<>();
              String sql = "SELECT * FROM ord_main WHERE  facility_cd = :facility_cd and rst_dialysis_state = '0' and fn_pat_id ||treat_date ||fn_plural in (:ind_no)";
              List<String> indNoList = Arrays.stream(strTmp.split(",")).collect(Collectors.toList());
              MapSqlParameterSource params = new MapSqlParameterSource();
              params.addValue("facility_cd", facilityCd);
              params.addValue("ind_no", indNoList);
              ordMainList = batchQuery(jdbcTemplateNkk5, sql, params, OrdMain.class);
              if (!ordMainList.isEmpty() && ordMainList.size() <= 1000) {
                EventLogMessage eventLogMessage = eventLoggerUtil.getEventLogMessage("=================予定中止処理Start=============="+rowNo+"行目",
                        facilityCd, "delOrdMains");
                eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.INFO);
                delOrdMains(ordMainList, false, jdbcTemplateConvert, jdbcTemplateNkk5, facilityCd);
                eventLogMessage = eventLoggerUtil.getEventLogMessage("=================予定中止処理End=============="+rowNo+"行目",
                        facilityCd, "delOrdMains");
                eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.INFO);
                rowNo++;
              }
            }
            //mod  #10675 & #10676 djy end
          } catch (Exception e) {
            eventLoggerUtil.recordLog(
                    facilityCd,
                    eventLoggerUtil.getEventLogMessage(
                            "JobStartEndLIstener.processDelPatGroupDetail(String inputFilePath,String facilityCd) pat_group_detail 削除処理：" + EventLoggerUtil.excetionStackTraceToString(e),
                            facilityCd,
                            e.getClass().getName() + ".processDelPatGroupDetail()"),
                    LogLevel.ERROR);
          }
          f.delete();
        }
      }
    } catch (Exception e) {
      //ログ

      eventLoggerUtil.recordLog(
              facilityCd,
              eventLoggerUtil.getEventLogMessage(
                      "JobStartEndLIstener.processDelPatGroupDetail(String inputFilePath,String facilityCd) pat_group_detail 削除処理：" + EventLoggerUtil.excetionStackTraceToString(e),
                      facilityCd,
                      e.getClass().getName() + ".processDelPatGroupDetail()"),
              LogLevel.ERROR);
    }
  }

  /**
   * mst_user_authentication 削除処理
   * @param facilityCd
   */
  private void processDelMstUserAuthentication(String facilityCd) {
    eventLoggerUtil.recordLog(facilityCd, eventLoggerUtil.getEventLogMessage("====== afterJob  mst_user_authentication 削除 start ======",
            facilityCd, "afterJob"), LogLevel.INFO);
    try {
      // mod #10418 SQL注入対策：パラメータバインディングを使用 start
      String sql = "SELECT user_id FROM mst_personal_user WHERE is_disp = '0' and is_del = '1' and facility_cd = ?";
      List<String> pat_group_cd_list = jdbcTemplateConvert.queryForList(sql, new Object[]{facilityCd}, String.class);
      // mod #10418 SQL注入対策：パラメータバインディングを使用 end
      // mod #10418 SQL注入対策：IN句を使用してパラメータバインディング start
      if (!pat_group_cd_list.isEmpty()) {
        String sqlDel = "DELETE FROM mst_user_authentication WHERE facility_cd = :facilityCd AND user_id IN (:userIds)";

        MapSqlParameterSource params = new MapSqlParameterSource();
        params.addValue("facilityCd", facilityCd);
        // user_idはint8型なのでLongに変換
        params.addValue("userIds", pat_group_cd_list.stream().map(Long::parseLong).collect(Collectors.toList()));

        namedParameterJdbcTemplateConvert.update(sqlDel, params);
        namedParameterJdbcTemplateNkk4.update(sqlDel, params);
      }
      // mod #10418 SQL注入対策：IN句を使用してパラメータバインディング end
    } catch (Exception e) {
      //ログ
      EventLogMessage eventLogMessage15 = eventLoggerUtil.getEventLogMessage(Arrays.toString(e.getStackTrace()),
              facilityCd, "JobStartEndLIstener.afterJob(JobExecution jobExecution) mst_user_authentication 削除失敗");
      eventLoggerUtil.recordLog(facilityCd, eventLogMessage15, LogLevel.ERROR);
    }
  }

  /**
   * mst_holiday 削除処理
   * @param facilityCd
   */
  private void processDelMstHoliday(String facilityCd) {
    eventLoggerUtil.recordLog(facilityCd, eventLoggerUtil.getEventLogMessage("====== afterJob  mst_holiday 削除 start ======",
            facilityCd, "afterJob"), LogLevel.INFO);
    //10205 mst_holiday
    try {
      String sql = "delete  FROM  mst_holiday WHERE  is_disp ='0' and  facility_cd = ?";
      jdbcTemplateConvert.update(sql, new Object[]{facilityCd});
      jdbcTemplateNkk5.update(sql, new Object[]{facilityCd});
    } catch (Exception e) {
      //ログ
      EventLogMessage eventLogMessage15 = eventLoggerUtil.getEventLogMessage(Arrays.toString(e.getStackTrace()),
              facilityCd, "JobStartEndLIstener.afterJob(JobExecution jobExecution) mst_holiday 削除失敗:" + e.getMessage());
      eventLoggerUtil.recordLog(facilityCd, eventLogMessage15, LogLevel.ERROR);
    }
  }

  /**
   * mnt_weight_state 追加処理
   * @param facilityCd
   */
  private void processAddMntWeightState(String facilityCd) {
    eventLoggerUtil.recordLog(facilityCd, eventLoggerUtil.getEventLogMessage("====== afterJob  mnt_weight_state 追加 start ======",
            facilityCd, "afterJob"), LogLevel.INFO);
    try {
      // mod #10418 SQL注入対策：パラメータバインディングを使用 start
      String sql = "SELECT weight_cd FROM mst_weight WHERE facility_cd = ? AND weight_cd NOT IN(SELECT weight_cd FROM mnt_weight_state WHERE facility_cd = ?)";
      List<Integer> weight_cd_list = jdbcTemplateNkk5.queryForList(sql, new Object[]{facilityCd, facilityCd}, Integer.class);
      // mod #10418 SQL注入対策：パラメータバインディングを使用 end
      // mod #10418 SQL注入対策：batchUpdateを使用してパラメータバインディング start
      if (!weight_cd_list.isEmpty()) {
        String sqlIns = "INSERT INTO mnt_weight_state (facility_cd,weight_cd,is_connect,card_read_value,write_result,reg_date,up_date) " +
                "VALUES(?, ?, '0', '{\"id\": \"\", \"idm\": \"\"}', '0', now(), now())";

        List<Object[]> batchArgs = new ArrayList<>();
        for (Integer weight_cd : weight_cd_list) {
          batchArgs.add(new Object[]{facilityCd, weight_cd});
        }

        jdbcTemplateNkk5.batchUpdate(sqlIns, batchArgs);
      }
      // mod #10418 SQL注入対策：batchUpdateを使用してパラメータバインディング end
    } catch (Exception e) {
      //ログ
      EventLogMessage eventLogMessage15 = eventLoggerUtil.getEventLogMessage(Arrays.toString(e.getStackTrace()),
              facilityCd, "JobStartEndLIstener.afterJob(JobExecution jobExecution) mnt_weight_state 追加失敗");
      eventLoggerUtil.recordLog(facilityCd, eventLogMessage15, LogLevel.ERROR);
    }
  }

  /**
   * sch_ext_end_date 更新処理
   * @param inputFilePath
   * @param facilityCd
   */
  private void processUpdateSchExtEndDate(String inputFilePath,String facilityCd) {
    String[] arr = new File(inputFilePath).list();
    List<String> arrlist = (arr != null) ? Arrays.asList(arr) : Collections.emptyList();
    List<String> patIdList = jdbcTemplateConvert.queryForList("SELECT pat_id FROM pat_personal_main WHERE facility_cd = ? and is_die = '0' and is_del = '0' GROUP BY pat_id", new Object[]{facilityCd}, String.class);

    eventLoggerUtil.recordLog(facilityCd, eventLoggerUtil.getEventLogMessage("====== afterJob  patIdList.size = " + patIdList.size(),
            facilityCd, "afterJob"), LogLevel.INFO);

    if (!patIdList.isEmpty()) {

      List<String> fileList = arrlist.stream()
              .filter(s -> s.contains("ExportData") && !s.endsWith(".zip"))
              .toList();

      if (fileList != null && !fileList.isEmpty()
              && fileList.get(0) != null
              && fileList.get(0).split("_").length>1
              && fileList.get(0).split("_")[1].length() >= 8){
        String convertDate = fileList.get(0).split("_")[1].substring(0, 8);
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyyMMdd");
        LocalDate endDate = LocalDate.parse(convertDate, formatter).plusYears(1).with(TemporalAdjusters.lastDayOfMonth());

        MapSqlParameterSource parameters = new MapSqlParameterSource();
        parameters.addValue("facility_cd", facilityCd);

        // mod #10418 SQL注入対策：IN句を使用してパラメータバインディング start
        if (patIdList != null && !patIdList.isEmpty()) {
          eventLoggerUtil.recordLog(facilityCd, eventLoggerUtil.getEventLogMessage("====== afterJob  sch_ext_end_date is null 更新 start ======",
                  facilityCd, "afterJob"), LogLevel.INFO);

          try {
            String sql = "UPDATE pat_main SET sch_ext_end_date = null WHERE facility_cd = :facility_cd AND pat_id IN (:patIds)";
            MapSqlParameterSource params = new MapSqlParameterSource();
            params.addValue("facility_cd", facilityCd);
            params.addValue("patIds", patIdList.stream().map(Long::parseLong).collect(Collectors.toList()));
            namedParameterJdbcTemplateNkk5.update(sql, params);
          }catch (Exception e){
            //ログ
            EventLogMessage eventLogMessage = eventLoggerUtil.getEventLogMessage(Arrays.toString(e.getStackTrace()),
                    facilityCd, "JobStartEndLIstener.afterJob(JobExecution jobExecution) sch_ext_end_date is null 更新失敗");
            eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.ERROR);
          }

          eventLoggerUtil.recordLog(facilityCd, eventLoggerUtil.getEventLogMessage("====== afterJob  sch_ext_end_date is null 更新 end ======",
                  facilityCd, "afterJob"), LogLevel.INFO);
        }
        // mod #10418 SQL注入対策：IN句を使用してパラメータバインディング end

        parameters.addValue("pat_id",patIdList.stream().map(m->Long.parseLong(m)).collect(Collectors.toList()));
        StringBuilder s=new StringBuilder();
        s.append("SELECT A.pat_id AS pat_id from (");
        s.append("SELECT distinct pat_id from ord_main where facility_cd = :facility_cd and pat_id in (:pat_id) and is_del = '0' UNION ");
        s.append("SELECT distinct pat_id from pat_rad_main where facility_cd = :facility_cd and pat_id in (:pat_id) and is_del = '0' UNION ");
        s.append("SELECT distinct pat_id from pat_exam_main where facility_cd = :facility_cd and pat_id in (:pat_id) and is_del = '0' UNION ");
        s.append("SELECT distinct pat_id from pat_treatment_pattern where facility_cd = :facility_cd and pat_id in (:pat_id) ) A");
        RowMapper<String> rowMapper = (ResultSet rs, int rowNum) -> rs.getString("pat_id");
        List<String> patIdsNotNull = namedParameterJdbcTemplateNkk5.query(s.toString(), parameters, rowMapper);

        // mod #10418 SQLインジェクション対策：OR連結の代わりにIN句を使用
        if (patIdsNotNull != null && !patIdsNotNull.isEmpty()) {
          eventLoggerUtil.recordLog(facilityCd, eventLoggerUtil.getEventLogMessage("====== afterJob  sch_ext_end_date 更新 start ======",
                  facilityCd, "afterJob"), LogLevel.INFO);

          try {
            // 将pat_id列表转换为Long类型并添加到参数中
            List<Long> patIdLongList = patIdsNotNull.stream().map(Long::parseLong).collect(Collectors.toList());
            parameters.addValue("sch_ext_end_date", endDate.format(formatter));
            parameters.addValue("pat_id_list", patIdLongList);

            // IN句を使用してパラメータ化クエリを実行
            namedParameterJdbcTemplateNkk5.update("UPDATE pat_main SET sch_ext_end_date = :sch_ext_end_date WHERE facility_cd = :facility_cd AND pat_id IN (:pat_id_list)", parameters);
          }catch (Exception e){
            //ログ
            EventLogMessage eventLogMessage = eventLoggerUtil.getEventLogMessage(Arrays.toString(e.getStackTrace()),
                    facilityCd, "JobStartEndLIstener.afterJob(JobExecution jobExecution) sch_ext_end_date 更新失敗");
            eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.ERROR);
          }

          eventLoggerUtil.recordLog(facilityCd, eventLoggerUtil.getEventLogMessage("====== afterJob  sch_ext_end_date 更新 end ======",
                  facilityCd, "afterJob"), LogLevel.INFO);

        }
      }
    }
  }

  /**
   * ord_main登録の場合、pat_eventには、項目「ord_no」を更新
   * @param facilityCd
   */
  private void processUpdateOrdNoInPatEvent(String facilityCd) {
    String fromDb_table_prefix_nkk5 = environment.getProperty("datasource." + ApplicationConst.DbType.NKK5 + ".table_prefix");
    String fromDb_table_prefix_convert = environment.getProperty("datasource." + ApplicationConst.DbType.NKK5 + ".table_prefix");
    StringBuffer updSqlBufferTonkk5 = new StringBuffer();
    updSqlBufferTonkk5.append(" WITH ord AS(SELECT DISTINCT ");
    updSqlBufferTonkk5.append(" ord.facility_cd, min(ord.ord_no) as ord_no, ord.pat_id, ord.treat_date ");
    updSqlBufferTonkk5.append(" FROM ");
    updSqlBufferTonkk5.append(fromDb_table_prefix_nkk5);
    updSqlBufferTonkk5.append("ord_main ord  ");
    updSqlBufferTonkk5.append(" WHERE");
    updSqlBufferTonkk5.append("  ord.facility_cd = '");
    updSqlBufferTonkk5.append(facilityCd);
    updSqlBufferTonkk5.append("'  GROUP BY  facility_cd,pat_id,treat_date)");
    updSqlBufferTonkk5.append(" update ");
    updSqlBufferTonkk5.append(fromDb_table_prefix_nkk5);
    updSqlBufferTonkk5.append("pat_event set ord_no = (");
    updSqlBufferTonkk5.append(" select ord_no from ord o ");
    updSqlBufferTonkk5.append(" where pat_event.pat_id = o.pat_id ");
    updSqlBufferTonkk5.append(" and pat_event.event_start_date = o.treat_date ");
    updSqlBufferTonkk5.append(" and pat_event.facility_cd = o.facility_cd) ");
    updSqlBufferTonkk5.append(" where pat_event.ord_no is null ");
    updSqlBufferTonkk5.append(" and pat_event.facility_cd = '");
    updSqlBufferTonkk5.append(facilityCd);
    updSqlBufferTonkk5.append("'");
    System.err.println("UPDATE PATEVENT SQL:" + updSqlBufferTonkk5.toString());
    // 本番DB を更新

    eventLoggerUtil.recordLog(facilityCd, eventLoggerUtil.getEventLogMessage("====== afterJob  jdbcTemplateNkk5.execute(updSqlBufferTonkk5.toString()) start ======",
            facilityCd, "afterJob"), LogLevel.INFO);

    jdbcTemplateNkk5.execute(updSqlBufferTonkk5.toString());

    eventLoggerUtil.recordLog(facilityCd, eventLoggerUtil.getEventLogMessage("====== afterJob  jdbcTemplateNkk5.execute(updSqlBufferTonkk5.toString()) end ======",
            facilityCd, "afterJob"), LogLevel.INFO);

    StringBuffer updSqlBufferConvert = new StringBuffer();
    updSqlBufferConvert.append(" WITH ord AS(SELECT DISTINCT ");
    updSqlBufferConvert.append(" ord.facility_cd, min(ord.ord_no) as ord_no, ord.pat_id, ord.treat_date ");
    updSqlBufferConvert.append(" FROM ");
    updSqlBufferConvert.append(fromDb_table_prefix_convert);
    updSqlBufferConvert.append("ord_main ord  ");
    updSqlBufferConvert.append(" WHERE");
    updSqlBufferConvert.append("  ord.facility_cd = '");
    updSqlBufferConvert.append(facilityCd);
    updSqlBufferConvert.append("'  GROUP BY  facility_cd,pat_id,treat_date)");
    updSqlBufferConvert.append(" update ");
    updSqlBufferConvert.append(fromDb_table_prefix_convert);
    updSqlBufferConvert.append("pat_event set ord_no = (");
    updSqlBufferConvert.append(" select ord_no from ord o ");
    updSqlBufferConvert.append(" where pat_event.pat_id = o.pat_id ");
    updSqlBufferConvert.append(" and pat_event.event_start_date = o.treat_date ");
    updSqlBufferConvert.append(" and pat_event.facility_cd = o.facility_cd) ");
    updSqlBufferConvert.append(" where pat_event.ord_no is null ");
    updSqlBufferConvert.append(" and pat_event.facility_cd = '");
    updSqlBufferConvert.append(facilityCd);
    updSqlBufferConvert.append("'");
    // コンバートDB を更新

    eventLoggerUtil.recordLog(facilityCd, eventLoggerUtil.getEventLogMessage("====== afterJob  jdbcTemplateConvert.execute(updSqlBufferConvert.toString()) start ======",
            facilityCd, "afterJob"), LogLevel.INFO);

    jdbcTemplateConvert.execute(updSqlBufferConvert.toString());

    eventLoggerUtil.recordLog(facilityCd, eventLoggerUtil.getEventLogMessage("====== afterJob  jdbcTemplateConvert.execute(updSqlBufferConvert.toString()) end ======",
            facilityCd, "afterJob"), LogLevel.INFO);
  }

  /**
   * 差分ord_main登録の場合、ord_treat_condition、項目「ord_no」を更新
   * @param inputFilePath
   * @param facilityCd
   */
  private void processUpdateOrdNoInOrdTreatCondition(String inputFilePath,String facilityCd) {
    eventLoggerUtil.recordLog(facilityCd, eventLoggerUtil.getEventLogMessage("====== afterJob  ord_no 差分更新 start ======",
            facilityCd, "afterJob"), LogLevel.INFO);
    try {
      String fromDb_table_prefix_nkk5 = environment.getProperty("datasource." + ApplicationConst.DbType.NKK5 + ".table_prefix");
      String[] arr = new File(inputFilePath).list();
      List<String> arrlist = (arr != null) ? Arrays.asList(arr) : Collections.emptyList();
      if (arrlist.stream().anyMatch(s -> s.contains("_dialysis[diff]")) && !arrlist.contains(".zip")) {
        StringBuffer updOrdSqlBufferTonkk5 = new StringBuffer();
        updOrdSqlBufferTonkk5.append(" WITH ord AS(SELECT DISTINCT ");
        updOrdSqlBufferTonkk5.append(" ord.facility_cd,  ord.ord_no, ord.rst_machine_no, ord.rst_cond_send_date , ord.rst_return_home_date ");
        updOrdSqlBufferTonkk5.append(" FROM ");
        updOrdSqlBufferTonkk5.append(fromDb_table_prefix_nkk5);
        updOrdSqlBufferTonkk5.append("ord_main ord  ");
        updOrdSqlBufferTonkk5.append(" WHERE");
        updOrdSqlBufferTonkk5.append("  ord.facility_cd = ? AND rst_dialysis_state='6')");
        updOrdSqlBufferTonkk5.append(" update ");
        updOrdSqlBufferTonkk5.append(fromDb_table_prefix_nkk5);
        updOrdSqlBufferTonkk5.append("ord_treat_condition set ord_no = o.ord_no");
        updOrdSqlBufferTonkk5.append(" from ord o ");
        updOrdSqlBufferTonkk5.append(" where ord_treat_condition.machine_no = o.rst_machine_no ");
        updOrdSqlBufferTonkk5.append(" and ord_treat_condition.receive_date >=o.rst_cond_send_date ");
        updOrdSqlBufferTonkk5.append(" and ord_treat_condition.receive_date <=o.rst_return_home_date ");
        updOrdSqlBufferTonkk5.append(" and ord_treat_condition.facility_cd = o.facility_cd ");
        updOrdSqlBufferTonkk5.append(" and ord_treat_condition.ord_no is null ");
        updOrdSqlBufferTonkk5.append(" and ord_treat_condition.facility_cd = ?");
        System.err.println("UPDATE ord_treat_condition SQL:" + updOrdSqlBufferTonkk5.toString());
        // 本番DB を更新
        jdbcTemplateNkk5.update(updOrdSqlBufferTonkk5.toString(), new Object[]{facilityCd, facilityCd});
      }
    } catch (Exception e) {
      EventLogMessage eventLogMessage15 = eventLoggerUtil.getEventLogMessage(Arrays.toString(e.getStackTrace()),
              facilityCd, "JobStartEndLIstener.afterJob(JobExecution jobExecution)ord_no 差分更新失敗:" + e.getMessage());
      eventLoggerUtil.recordLog(facilityCd, eventLogMessage15, LogLevel.ERROR);
    }
    eventLoggerUtil.recordLog(facilityCd, eventLoggerUtil.getEventLogMessage("====== afterJob  ord_no 差分更新 end ======",
            facilityCd, "afterJob"), LogLevel.INFO);
  }

  @Transactional
  public void executeBatchUpdate(String sql, List<String> parameters, String facilityCdParam, JdbcTemplate jdbcTemplate) {
    jdbcTemplate.batchUpdate(sql, new BatchPreparedStatementSetter() {
      @Override
      public void setValues(PreparedStatement ps, int i) throws SQLException {
        ps.setString(1, facilityCdParam);
        ps.setString(2, parameters.get(i));
      }
      @Override
      public int getBatchSize() {
        return parameters.size();
      }
    });
  }

  //add #10675 & #10676 djy start
  /**
   * batchUpdate
   * @param jdbcTemplate
   * @param sql
   * @param params
   */
  public void batchUpdate(JdbcTemplate jdbcTemplate, String sql, MapSqlParameterSource params) {
    NamedParameterJdbcTemplate namedParameterJdbcTemplate = new NamedParameterJdbcTemplate(jdbcTemplate);
    namedParameterJdbcTemplate.update(sql, params);
  }

    /**
     * upPatExamMain
     *
     * @param patId
     * @param facilityCd
     * @param procDate
     */
    public void upPatExamMain(String patId, String facilityCd,String procDate, JdbcTemplate jdbcTemplateConvert, JdbcTemplate jdbcTemplateNkk5){
        EventLogMessage eventLogMessage = new EventLogMessage();
        try {
            String sql =
                    "UPDATE pat_exam_main " +
                            "SET is_del = '1' " +
                            "WHERE facility_cd = :facility_cd " +
                            "  AND is_del = '0' " +
                            "  AND fn_pat_id = :fn_pat_id " +
                            "  AND reg_exam_date >= :reg_exam_date";

            LocalDateTime ldt = LocalDate
                    .parse(procDate, DateTimeFormatter.ofPattern("yyyyMMdd"))
                    .atStartOfDay();
            MapSqlParameterSource params = new MapSqlParameterSource();
            params.addValue("facility_cd", facilityCd);
            params.addValue("fn_pat_id", patId);
            params.addValue("reg_exam_date", Timestamp.valueOf(ldt));

            batchUpdate(jdbcTemplateNkk5, sql, params);
            batchUpdate(jdbcTemplateConvert, sql, params);
            eventLogMessage = eventLoggerUtil.getEventLogMessage("=================pat_exam_main修正==============",
                    facilityCd, "upPatExamMain.pat_exam_main処理完了");
            eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.INFO);

            String sql_pat_rad_main =
                    "UPDATE pat_rad_main " +
                            "SET is_del = '1' " +
                            "WHERE facility_cd = :facility_cd " +
                            "  AND is_del = '0' " +
                            "  AND fn_pat_id = :fn_pat_id " +
                            "  AND reg_rad_date >= :reg_exam_date";

            batchUpdate(jdbcTemplateNkk5, sql_pat_rad_main, params);
            batchUpdate(jdbcTemplateConvert, sql_pat_rad_main, params);
            eventLogMessage = eventLoggerUtil.getEventLogMessage("=================pat_rad_main修正==============",
                    facilityCd, "upPatExamMain.pat_rad_main修正処理完了");
            eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.INFO);
        }catch (Exception e) {
            eventLogMessage = eventLoggerUtil.getEventLogMessage(e.getMessage(),
                    facilityCd, "upPatExamMain処理失敗了");
            eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.ERROR);
            throw e;
        }
    }
  /**
   * delOrdMains
   *
   * @param ordMainList
   * @param isRst
   * @param jdbcTemplateConvert
   * @param jdbcTemplateNkk5
   */
  public void delOrdMains(List<OrdMain> ordMainList, Boolean isRst, JdbcTemplate jdbcTemplateConvert, JdbcTemplate jdbcTemplateNkk5, String facilityCd) {
    EventLogMessage eventLogMessage = new EventLogMessage();
    try {
      List<Long> ordNoList = ordMainList.stream().map(m -> m.getOrdNo()).collect(Collectors.toList());
      if (isRst) {
        List<OrdMain> ordMainDelList = ordMainList.stream().filter(o -> 0 == o.getFnPlural()).collect(Collectors.toList());
        List<OrdMain> ordMainUpdList = ordMainList.stream().filter(o -> 0 != o.getFnPlural()).collect(Collectors.toList());
        //ord_checklist
        delOrdChecklist(jdbcTemplateConvert, jdbcTemplateNkk5, ordNoList, facilityCd);
        eventLogMessage = eventLoggerUtil.getEventLogMessage("=================実績削除==============",
                facilityCd, "delOrdChecklist処理完了");
        eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.INFO);
        //ord_main_restore ord_main_hst
        insertOrdMainRestore(jdbcTemplateConvert,jdbcTemplateNkk5,ordMainList, facilityCd);
        eventLogMessage = eventLoggerUtil.getEventLogMessage("=================実績削除==============",
                facilityCd, "insertOrdMainRestore処理完了");
        eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.INFO);
        //mnt_motion_record mni_monitor
        updMniMonitorAndMotionRecord(jdbcTemplateConvert,jdbcTemplateNkk5,ordMainList, facilityCd);
        eventLogMessage = eventLoggerUtil.getEventLogMessage("=================実績削除==============",
                facilityCd, "updMniMonitorAndMotionRecord処理完了");
        eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.INFO);
        //ord_treat_condition
        updOrdTreatCondition(jdbcTemplateConvert,jdbcTemplateNkk5,ordNoList, facilityCd);
        eventLogMessage = eventLoggerUtil.getEventLogMessage("=================実績削除==============",
                facilityCd, "updOrdTreatCondition処理完了");
        eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.INFO);
        //ord_material_save
        delOrdMaterialSave(jdbcTemplateNkk5,ordNoList,"2", facilityCd);
        eventLogMessage = eventLoggerUtil.getEventLogMessage("=================実績削除==============",
                facilityCd, "delOrdMaterialSave処理完了");
        eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.INFO);

        if (!ordMainUpdList.isEmpty()) {
          List<Long> ordNoUpdList = ordMainUpdList.stream().map(m -> m.getOrdNo()).collect(Collectors.toList());
          //ord_material_save
          updOrdMaterialSave(jdbcTemplateNkk5,ordNoUpdList, facilityCd);
          eventLogMessage = eventLoggerUtil.getEventLogMessage("=================実績削除==============",
                  facilityCd, "updOrdMaterialSave処理完了");
          eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.INFO);
          //ord_main
          delOrdMainRst(jdbcTemplateConvert, jdbcTemplateNkk5, ordMainUpdList);
          eventLogMessage = eventLoggerUtil.getEventLogMessage("=================実績削除==============",
                  facilityCd, "delOrdMainRst処理完了");
          eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.INFO);
        }
        if (!ordMainDelList.isEmpty()) {
          List<Long> ordNoDelList = ordMainDelList.stream().map(m -> m.getOrdNo()).collect(Collectors.toList());
          //ord_main
          delOrdMain(jdbcTemplateConvert, jdbcTemplateNkk5, ordNoDelList, facilityCd);
          eventLogMessage = eventLoggerUtil.getEventLogMessage("=================実績削除==============",
                  facilityCd, "delOrdMain処理完了");
          eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.INFO);
        }
      } else {
        //pat_event bbs_info
        delPatEvent(jdbcTemplateConvert, jdbcTemplateNkk5, ordMainList, facilityCd);
        eventLogMessage = eventLoggerUtil.getEventLogMessage("=================予定中止==============",
                facilityCd, "delPatEvent処理完了");
        eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.INFO);
        //ord_checklist
        delOrdChecklist(jdbcTemplateConvert, jdbcTemplateNkk5, ordNoList, facilityCd);
        eventLogMessage = eventLoggerUtil.getEventLogMessage("=================予定中止==============",
                facilityCd, "delOrdChecklist処理完了");
        eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.INFO);
        //ord_main_restore ord_main_hst
        insertOrdMainRestore(jdbcTemplateConvert,jdbcTemplateNkk5,ordMainList, facilityCd);
        eventLogMessage = eventLoggerUtil.getEventLogMessage("=================予定中止==============",
                facilityCd, "insertOrdMainRestore処理完了");
        eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.INFO);
        //ord_material_save
        delOrdMaterialSave(jdbcTemplateNkk5,ordNoList,"1", facilityCd);
        eventLogMessage = eventLoggerUtil.getEventLogMessage("=================予定中止==============",
                facilityCd, "delOrdMaterialSave処理完了");
        eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.INFO);
        //ord_schedule
        delOrdSchedule(jdbcTemplateNkk5,ordNoList, facilityCd);
        eventLogMessage = eventLoggerUtil.getEventLogMessage("=================予定中止==============",
                facilityCd, "delOrdSchedule処理完了");
        eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.INFO);
        //pat_ind_approve
        delPatIndApprove(jdbcTemplateConvert,jdbcTemplateNkk5,ordNoList, facilityCd);
        eventLogMessage = eventLoggerUtil.getEventLogMessage("=================予定中止==============",
                facilityCd, "delPatIndApprove処理完了");
        eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.INFO);
        //ord_main
        delOrdMain(jdbcTemplateConvert, jdbcTemplateNkk5, ordNoList, facilityCd);
        eventLogMessage = eventLoggerUtil.getEventLogMessage("=================予定中止==============",
                facilityCd, "delOrdMain処理完了");
        eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.INFO);
      }
    } catch (Exception e) {
      eventLoggerUtil.recordLog(
              facilityCd,
              eventLoggerUtil.getEventLogMessage(
                      "delOrdMains(List<OrdMain> ordMainList, Boolean isRst, JdbcTemplate jdbcTemplateConvert, JdbcTemplate jdbcTemplateNkk5) ：" + EventLoggerUtil.excetionStackTraceToString(e),
                      facilityCd,
                      e.getClass().getName() + ".delOrdMains()"),
              LogLevel.ERROR);
      throw e;
    }
  }

  /**
   * getFacilitySettingValue
   * @param jdbcTemplate
   * @param settingNo
   * @return
   */
  private String getFacilitySettingValue(JdbcTemplate jdbcTemplate, String settingNo, String facilityCd) {
    StringBuilder stringBuilder = new StringBuilder();
    stringBuilder.append("SELECT CASE  WHEN A.facility_setting_no IS NULL THEN B.default_value  ELSE A.value END As value ");
    stringBuilder.append("FROM mst_facility_setting A RIGHT OUTER JOIN sys_facility_setting B ");
    stringBuilder.append("ON A.facility_setting_no = B.facility_setting_no AND A.facility_cd = ? WHERE B.facility_setting_no = ?");
    String getFacilitySettingValueSql = stringBuilder.toString();
    List<String> settingValues = jdbcTemplate.query(getFacilitySettingValueSql, new RowMapper<String>() {
      @Override
      public String mapRow(ResultSet rs, int rowNum) throws SQLException {
        return rs.getString("value");
      }
    }, facilityCd, settingNo);
    if (!settingValues.isEmpty())
      return settingValues.get(0);
    return "";
  }

  /**
   * delPatEvent
   * @param jdbcTemplateConvert
   * @param jdbcTemplateNkk5
   * @param ordMainList
   */
  private void delPatEvent(JdbcTemplate jdbcTemplateConvert,JdbcTemplate jdbcTemplateNkk5,List<OrdMain> ordMainList, String facilityCd) {
    String settingValue=getFacilitySettingValue(jdbcTemplateNkk5,"3005", facilityCd);
    if ("1".equals(settingValue)||"2".equals(settingValue)){
      deleteEvent(jdbcTemplateConvert,jdbcTemplateNkk5,ordMainList, facilityCd);
    }
  }

  /**
   * deleteEvent
   * @param jdbcTemplateConvert
   * @param jdbcTemplateNkk5
   * @param ordMainList
   */
  private void deleteEvent(JdbcTemplate jdbcTemplateConvert, JdbcTemplate jdbcTemplateNkk5, List<OrdMain> ordMainList, String facilityCd) {
    String getpatEventByOrdNoSql = "select pat_event_cd,bbs_ctl_no from pat_event where facility_cd= :facility_cd and ord_no in (:ordNoList) and is_del = '0'";
    List<Long> ordNoList = ordMainList.stream().map(c -> c.getOrdNo()).collect(Collectors.toList());
    MapSqlParameterSource params = new MapSqlParameterSource();
    params.addValue("facility_cd", facilityCd);
    params.addValue("ordNoList", ordNoList);
    List<PatEvent> patEventsOrd = batchQuery(jdbcTemplateNkk5, getpatEventByOrdNoSql, params, PatEvent.class);
    List<Long> patEventCdList = new ArrayList<>();
    List<Long> bbsCtlNoList = new ArrayList<>();
    if (patEventsOrd != null && !patEventsOrd.isEmpty()) {
      patEventCdList = patEventsOrd.stream().map(p -> p.getPatEventCd()).collect(Collectors.toList());
      bbsCtlNoList = patEventsOrd.stream().filter(c -> c.getBbsCtlNo() != null && c.getBbsCtlNo() != 0).map(m -> m.getBbsCtlNo()).collect(Collectors.toList());
    }

    if (!patEventCdList.isEmpty()) {
      String delPatEventSql = "update pat_event set ord_no = NULL ,up_date = CURRENT_TIMESTAMP where facility_cd = :facility_cd and pat_event_cd in(:pat_event_cd)";
      MapSqlParameterSource delPatEventparams = new MapSqlParameterSource();
      delPatEventparams.addValue("facility_cd", facilityCd);
      delPatEventparams.addValue("pat_event_cd", patEventCdList);
      batchUpdate(jdbcTemplateNkk5, delPatEventSql, delPatEventparams);
      batchUpdate(jdbcTemplateConvert, delPatEventSql, delPatEventparams);
    }

    if (!bbsCtlNoList.isEmpty()) {
      String delBbsInfoSql = "update bbs_info set is_disp = '0' ,up_date = CURRENT_TIMESTAMP where facility_cd = :facility_cd and bbs_ctl_no in(:bbs_ctl_no)";
      MapSqlParameterSource delBbsInfoparams = new MapSqlParameterSource();
      delBbsInfoparams.addValue("facility_cd", facilityCd);
      delBbsInfoparams.addValue("bbs_ctl_no", bbsCtlNoList);
      batchUpdate(jdbcTemplateNkk5, delBbsInfoSql, delBbsInfoparams);
      batchUpdate(jdbcTemplateConvert, delBbsInfoSql, delBbsInfoparams);
    }
  }

  /**
   * delOrdMain
   * @param jdbcTemplateConvert
   * @param jdbcTemplateNkk5
   * @param ordNoList
   */
  private void delOrdMain(JdbcTemplate jdbcTemplateConvert, JdbcTemplate jdbcTemplateNkk5,List<Long> ordNoList, String facilityCd) {
    String delOrdMainSql = "DELETE  FROM ord_main  WHERE facility_cd = :facility_cd AND ord_no in (:ord_no)";
    MapSqlParameterSource params = new MapSqlParameterSource();
    params.addValue("facility_cd", facilityCd);
    params.addValue("ord_no", ordNoList);
    batchUpdate(jdbcTemplateNkk5, delOrdMainSql, params);
    batchUpdate(jdbcTemplateConvert, delOrdMainSql, params);
  }

  /**
   * delOrdMainRst
   * @param jdbcTemplateConvert
   * @param jdbcTemplateNkk5
   * @param ordMainList
   */
  private void delOrdMainRst(JdbcTemplate jdbcTemplateConvert, JdbcTemplate jdbcTemplateNkk5,List<OrdMain> ordMainList) {
    StringBuilder stringBuilder = new StringBuilder();
    stringBuilder.append("UPDATE ord_main ");
    stringBuilder.append("SET ind_treatment_name = NULL, ");
    stringBuilder.append("ind_kur_name = NULL, ");
    stringBuilder.append("ind_bed_name = NULL, " );
    stringBuilder.append("rst_fn_dialysis_no = NULL, ");
    stringBuilder.append("rst_relation_dialysis_no = NULL, ");
    stringBuilder.append("rst_is_update_edition = NULL, ");
    stringBuilder.append("rst_input_class = NULL, ");
    stringBuilder.append("rst_dialysis_state = '0', ");
    stringBuilder.append("rst_edition = 0, ");
    stringBuilder.append("rst_treatment_cd = NULL, ");
    stringBuilder.append("rst_treatment_name = NULL, ");
    stringBuilder.append("rst_kur_cd = NULL, ");
    stringBuilder.append("rst_kur_name = NULL, ");
    stringBuilder.append("rst_bed_cd = NULL, ");
    stringBuilder.append("rst_bed_name = NULL, ");
    stringBuilder.append("rst_machine_no = NULL, ");
    stringBuilder.append("rst_machine_name = NULL, ");
    stringBuilder.append("rst_cond_send_date = NULL, ");
    stringBuilder.append("rst_accept_date = NULL, ");
    stringBuilder.append("rst_start_date = NULL, ");
    stringBuilder.append("rst_end_date = NULL, ");
    stringBuilder.append("rst_return_home_date = NULL, ");
    stringBuilder.append("rst_in_out_class = NULL, ");
    stringBuilder.append("rst_dialysis_cnt = NULL, ");
    stringBuilder.append("rst_ward_cd = NULL, ");
    stringBuilder.append("rst_ward_name = NULL, ");
    stringBuilder.append("rst_course_cd = NULL, ");
    stringBuilder.append("rst_course_name = NULL, ");
    stringBuilder.append("rst_puncture_user_info = NULL, ");
    stringBuilder.append("rst_return_user_info = NULL, ");
    stringBuilder.append("rst_charge_user_info = NULL, ");
    stringBuilder.append("rst_blood_circulate_total = NULL, ");
    stringBuilder.append("rst_running_time = NULL, ");
    stringBuilder.append("rst_kt_v = NULL, ");
    stringBuilder.append("rec_set_date = NULL, ");
    stringBuilder.append("send_ctl_no = NULL, ");
    stringBuilder.append("blood_purifier_name = NULL, ");
    stringBuilder.append("pull_leave_amount = NULL, ");
    stringBuilder.append("rst_cond_info = NULL, ");
    stringBuilder.append("rst_medi_info = NULL, ");
    stringBuilder.append("rst_equip_info = NULL, ");
    stringBuilder.append("rst_ind_comment_info = NULL, ");
    stringBuilder.append("rst_tare_info = NULL, ");
    stringBuilder.append("rst_off_water_info = NULL, ");
    stringBuilder.append("rst_weight_info = NULL, ");
    stringBuilder.append("rst_complaint_info = NULL, ");
    stringBuilder.append("rst_treatment_info = NULL, ");
    stringBuilder.append("rst_treat_staff_info = NULL, ");
    stringBuilder.append("rst_rounds_info = NULL, ");
    stringBuilder.append("rst_dw = NULL, ");
    stringBuilder.append("weight_scale_no = NULL, ");
    stringBuilder.append("is_confirm = '0', ");
    stringBuilder.append("rst_purification_cnt = NULL, ");
    stringBuilder.append("addition_info = NULL, ");
    stringBuilder.append("ind_device_mode = NULL, ");
    stringBuilder.append("ind_cond_info = ?, ");
    stringBuilder.append("ind_medi_info = ?, ");
    stringBuilder.append("ind_equip_info = ?, ");
    stringBuilder.append("up_date = ? ");
    stringBuilder.append("WHERE ");
    stringBuilder.append("ord_no = ? ");
    stringBuilder.append("and facility_cd = ?");
    String updOrdMainSql = stringBuilder.toString();
    String[] mediAndEquipDeleteKeys = {"class_cd", "class_name",
            "class_type", "name", "short_name", "unit"};
    Timestamp timestamp = new Timestamp(System.currentTimeMillis());
    List<OrdMain> ordMains = new ArrayList<>(ordMainList);
    for (OrdMain ordMain : ordMains) {
      ordMain.setUpDate(timestamp);
      // 指示：投与薬剤情報
      if (ordMain.getIndMediInfo() != null && !"[]".equals(ordMain.getIndMediInfo())) {
        JSONArray indMediInfoArray = new JSONArray(ordMain.getIndMediInfo());
        for (int i = 0; i < indMediInfoArray.length(); i++) {
          JSONObject indMediInfo = indMediInfoArray.getJSONObject(i);
          for (String deleteKey : mediAndEquipDeleteKeys) {
            indMediInfo.remove(deleteKey);
          }
          indMediInfo.remove("timing_name");
          indMediInfo.remove("procedure_name");
        }
        ordMain.setIndMediInfo(indMediInfoArray.toString());
      }

      // 指示：医療材料情報
      if (ordMain.getIndEquipInfo() != null && !"[]".equals(ordMain.getIndEquipInfo())) {
        JSONArray indEquipInfoArray = new JSONArray(ordMain.getIndEquipInfo());
        for (int i = 0; i < indEquipInfoArray.length(); i++) {
          JSONObject indEquipInfo = indEquipInfoArray.getJSONObject(i);
          for (String deleteKey : mediAndEquipDeleteKeys) {
            indEquipInfo.remove(deleteKey);
          }
        }
        ordMain.setIndEquipInfo(indEquipInfoArray.toString());
      }

      // 指示：治療条件情報
      if (ordMain.getIndCondInfo() != null) {
        JSONObject indCondInfo = new JSONObject(ordMain.getIndCondInfo());
        for (String indCondKey : indCondInfo.keySet()) {
          JSONObject item = (JSONObject) indCondInfo.get(indCondKey);
          item.remove("unit");
          item.remove("value_name_1");
          // "5:ダイアライザ" exist 'value_name_2'
          if ("5".equals(indCondKey)) {
            item.remove("value_name_2");
          }
        }
        ordMain.setIndCondInfo(indCondInfo.toString());
      }
    }
    updOrdMain(jdbcTemplateNkk5, updOrdMainSql, ordMains);
    updOrdMain(jdbcTemplateConvert, updOrdMainSql, ordMains);
  }

  /**
   * updOrdMain
   * @param jdbcTemplate
   * @param sql
   * @param ordMainList
   */

  public void updOrdMain(JdbcTemplate jdbcTemplate, String sql, List<OrdMain> ordMainList) {
    jdbcTemplate.batchUpdate(sql, new BatchPreparedStatementSetter() {
      @Override
      public void setValues(PreparedStatement ps, int i) throws SQLException {
        OrdMain ordMain = ordMainList.get(i);
        ps.setObject(1, ordMain.getIndCondInfo(), Types.OTHER);
        ps.setObject(2, ordMain.getIndMediInfo(), Types.OTHER);
        ps.setObject(3, ordMain.getIndEquipInfo(), Types.OTHER);
        ps.setTimestamp(4, ordMain.getUpDate());
        ps.setLong(5, ordMain.getOrdNo());
        ps.setString(6, ordMain.getFacilityCd());
      }
      @Override
      public int getBatchSize() {
        return ordMainList.size();
      }
    });
  }

  /**
   * insertOrdMainHst
   * @param params
   * @return
   */
  private OrdMainHst insertOrdMainHst(OrdMainHst params, String facilityCd) {
    try {
      if (mongoTemplate != null)
        mongoTemplate.insert(params);
    } catch (Exception e) {
      eventLoggerUtil.recordLog(
              facilityCd,
              eventLoggerUtil.getEventLogMessage(
                      "JobStartEndLIstener.insertOrdMainHst(OrdMainHst params) ：" + EventLoggerUtil.excetionStackTraceToString(e),
                      facilityCd,
                      e.getClass().getName() + ".insertOrdMainHst()"),
              LogLevel.ERROR);
    }
    return params;
  }

  /**
   * getOrdMainHstData
   *
   * @param ordMain
   * @return
   */
  private OrdMainHst getOrdMainHstData(OrdMain ordMain) {
    OrdMainHst ordMainHst = new OrdMainHst();

    ordMainHst.setOrdNo(toStringOrNull(ordMain.getOrdNo()));
    ordMainHst.setPatId(toStringOrNull(ordMain.getPatId()));
    ordMainHst.setFnPatId(valueOrNull(ordMain.getFnPatId()));
    ordMainHst.setTreatDate(valueOrNull(ordMain.getTreatDate()));
    ordMainHst.setTreatWeek(toStringOrNull(ordMain.getTreatWeek()));
    ordMainHst.setFacilityCd(valueOrNull(ordMain.getFacilityCd()));
    ordMainHst.setFacilityName(valueOrNull(ordMain.getFacilityName()));

    ordMainHst.setIndVaCd(toStringOrNull(ordMain.getIndVaCd()));
    ordMainHst.setIndTreatmentCd(toStringOrNull(ordMain.getIndTreatmentCd()));
    ordMainHst.setIndTreatmentName(valueOrNull(ordMain.getIndTreatmentName()));
    ordMainHst.setIndKurCd(toStringOrNull(ordMain.getIndKurCd()));
    ordMainHst.setIndKurName(valueOrNull(ordMain.getIndKurName()));
    ordMainHst.setIndTreatStartTime(valueOrNull(ordMain.getIndTreatStartTime()));
    ordMainHst.setIndBedCd(toStringOrNull(ordMain.getIndBedCd()));
    ordMainHst.setIndBedName(valueOrNull(ordMain.getIndBedName()));
    ordMainHst.setIndScheduleUserInfo(valueOrNull(ordMain.getIndScheduleUserInfo()));
    ordMainHst.setIndCondInfo(valueOrNull(ordMain.getIndCondInfo()));
    ordMainHst.setIndMediInfo(valueOrNull(ordMain.getIndMediInfo()));
    ordMainHst.setIndEquipInfo(valueOrNull(ordMain.getIndEquipInfo()));
    ordMainHst.setIndIndCommentInfo(valueOrNull(ordMain.getIndIndCommentInfo()));
    ordMainHst.setIndTareInfo(valueOrNull(ordMain.getIndTareInfo()));
    ordMainHst.setIndOffWaterInfo(valueOrNull(ordMain.getIndOffWaterInfo()));
    ordMainHst.setIndDeviceSetInfo(valueOrNull(ordMain.getIndDeviceSetInfo()));

    ordMainHst.setRstFnDialysisNo(toStringOrNull(ordMain.getRstFnDialysisNo()));
    ordMainHst.setRstRelationDialysisNo(toStringOrNull(ordMain.getRstRelationDialysisNo()));
    ordMainHst.setRstEdition(toStringOrNull(ordMain.getRstEdition()));
    ordMainHst.setRstIsUpdateEdition(valueOrNull(ordMain.getRstIsUpdateEdition()));
    ordMainHst.setRstInputClass(toStringOrNull(ordMain.getRstInputClass()));
    ordMainHst.setRstDialysisState(valueOrNull(ordMain.getRstDialysisState()));
    ordMainHst.setRstTreatmentCd(toStringOrNull(ordMain.getRstTreatmentCd()));
    ordMainHst.setRstTreatmentName(valueOrNull(ordMain.getRstTreatmentName()));
    ordMainHst.setRstKurCd(toStringOrNull(ordMain.getRstKurCd()));
    ordMainHst.setRstKurName(valueOrNull(ordMain.getRstKurName()));
    ordMainHst.setRstBedCd(toStringOrNull(ordMain.getRstBedCd()));
    ordMainHst.setRstBedName(valueOrNull(ordMain.getRstBedName()));
    ordMainHst.setRstMachineNo(toStringOrNull(ordMain.getRstMachineNo()));
    ordMainHst.setRstMachineName(valueOrNull(ordMain.getRstMachineName()));

    ordMainHst.setRstCondSendDate(toStringOrNull(ordMain.getRstCondSendDate()));
    ordMainHst.setRstAcceptDate(toStringOrNull(ordMain.getRstAcceptDate()));
    ordMainHst.setRstStartDate(toStringOrNull(ordMain.getRstStartDate()));
    ordMainHst.setRstEndDate(toStringOrNull(ordMain.getRstEndDate()));
    ordMainHst.setRstReturnHomeDate(toStringOrNull(ordMain.getRstReturnHomeDate()));
    ordMainHst.setRstInOutClass(toStringOrNull(ordMain.getRstInOutClass()));
    ordMainHst.setRstDialysisCnt(toStringOrNull(ordMain.getRstDialysisCnt()));
    ordMainHst.setRstWardCd(toStringOrNull(ordMain.getRstWardCd()));
    ordMainHst.setRstWardName(valueOrNull(ordMain.getRstWardName()));
    ordMainHst.setRstCourseCd(toStringOrNull(ordMain.getRstCourseCd()));
    ordMainHst.setRstCourseName(valueOrNull(ordMain.getRstCourseName()));
    ordMainHst.setRstDw(toStringOrNull(ordMain.getRstDw()));
    ordMainHst.setRstPunctureUserInfo(valueOrNull(ordMain.getRstPunctureUserInfo()));
    ordMainHst.setRstReturnUserInfo(valueOrNull(ordMain.getRstReturnUserInfo()));
    ordMainHst.setRstChargeUserInfo(valueOrNull(ordMain.getRstChargeUserInfo()));
    ordMainHst.setRstBloodCirculateTotal(toStringOrNull(ordMain.getRstBloodCirculateTotal()));
    ordMainHst.setRstRunningTime(toStringOrNull(ordMain.getRstRunningTime()));
    ordMainHst.setRstKtV(toStringOrNull(ordMain.getRstKtV()));

    ordMainHst.setRecSetDate(toStringOrNull(ordMain.getRecSetDate()));
    ordMainHst.setSendCtlNo(toStringOrNull(ordMain.getSendCtlNo()));
    ordMainHst.setBloodPurifierName(valueOrNull(ordMain.getBloodPurifierName()));
    ordMainHst.setPullLeaveAmount(toStringOrNull(ordMain.getPullLeaveAmount()));
    ordMainHst.setRstCondInfo(valueOrNull(ordMain.getRstCondInfo()));
    ordMainHst.setRstMediInfo(valueOrNull(ordMain.getRstMediInfo()));
    ordMainHst.setRstEquipInfo(valueOrNull(ordMain.getRstEquipInfo()));
    ordMainHst.setRstIndCommentInfo(valueOrNull(ordMain.getRstIndCommentInfo()));
    ordMainHst.setRstTareInfo(valueOrNull(ordMain.getRstTareInfo()));
    ordMainHst.setRstOffWaterInfo(valueOrNull(ordMain.getRstOffWaterInfo()));
    ordMainHst.setWeightScaleNo(toStringOrNull(ordMain.getWeightScaleNo()));
    ordMainHst.setRstWeightInfo(valueOrNull(ordMain.getRstWeightInfo()));
    ordMainHst.setRstComplaintInfo(valueOrNull(ordMain.getRstComplaintInfo()));
    ordMainHst.setRstTreatmentInfo(valueOrNull(ordMain.getRstTreatmentInfo()));
    ordMainHst.setRstTreatStaffInfo(valueOrNull(ordMain.getRstTreatStaffInfo()));
    ordMainHst.setRstRoundsInfo(valueOrNull(ordMain.getRstRoundsInfo()));

    ordMainHst.setIsDel("1");
    ordMainHst.setUpDate(toStringOrNull(ordMain.getUpDate()));
    ordMainHst.setRegDate(toStringOrNull(ordMain.getRegDate()));
    ordMainHst.setFnPlural(null);
    ordMainHst.setTreatType(toStringOrNull(ordMain.getTreatType()));
    ordMainHst.setIsConfirm(valueOrNull(ordMain.getIsConfirm()));
    ordMainHst.setIndDw(toStringOrNull(ordMain.getIndDw()));
    ordMainHst.setRstPurificationCnt(toStringOrNull(ordMain.getRstPurificationCnt()));
    ordMainHst.setAdditionInfo(valueOrNull(ordMain.getAdditionInfo()));

    ordMainHst.setInsDate(
            new SimpleDateFormat("yyyyMMddHHmmssSSS").format(new Date())
    );
    return ordMainHst;
  }


  private String toStringOrNull(Object value) {
    return org.springframework.util.ObjectUtils.isEmpty(value)
            ? null
            : String.valueOf(value);
  }

  private <T> T valueOrNull(T value) {
    return org.springframework.util.ObjectUtils.isEmpty(value)
            ? null
            : value;
  }



  /**
   * insertOrdMainRestore
   * @param ordMainList
   * @param jdbcTemplateNkk5
   */
  private void insertOrdMainRestore(JdbcTemplate jdbcTemplateConvert,JdbcTemplate jdbcTemplateNkk5,List<OrdMain> ordMainList, String facilityCd) {
    List<OrdMain> ordMains = new ArrayList<>(ordMainList);
    StringBuilder stringBuilder = new StringBuilder();
    stringBuilder.append("INSERT INTO ord_main_restore (ord_no,del_date,pat_id,fn_pat_id,treat_date,treat_week,facility_cd,facility_name,ind_va_cd,ind_treatment_cd,ind_treatment_name,");
    stringBuilder.append("ind_kur_cd,ind_kur_name,ind_treat_start_time,ind_bed_cd,ind_bed_name,ind_schedule_user_info,ind_cond_info,ind_medi_info,ind_equip_info,ind_ind_comment_info,");
    stringBuilder.append("ind_tare_info,ind_off_water_info,rst_fn_dialysis_no,rst_relation_dialysis_no,rst_edition,rst_is_update_edition,rst_input_class,rst_dialysis_state,");
    stringBuilder.append("rst_treatment_cd,rst_treatment_name,rst_kur_cd,rst_kur_name,rst_bed_cd,rst_bed_name,rst_machine_no,rst_machine_name,rst_cond_send_date,rst_accept_date,");
    stringBuilder.append("rst_start_date,rst_end_date,rst_return_home_date,rst_in_out_class,rst_dialysis_cnt,rst_ward_cd,rst_ward_name,rst_course_cd,rst_course_name,");
    stringBuilder.append("rst_puncture_user_info,rst_return_user_info,rst_charge_user_info,rst_blood_circulate_total,rst_running_time,rst_kt_v,rec_set_date,send_ctl_no,blood_purifier_name,");
    stringBuilder.append("pull_leave_amount,rst_cond_info,rst_medi_info,rst_equip_info,rst_ind_comment_info,rst_tare_info,rst_off_water_info,rst_weight_info,rst_complaint_info,");
    stringBuilder.append("rst_treatment_info,rst_treat_staff_info,rst_rounds_info,is_del,up_date,reg_date,ind_device_set_info,treat_type,rst_purification_cnt,");
    stringBuilder.append("up_ind_user_id,up_user_id,rst_dw,weight_scale_no,fn_plural,is_confirm,ind_dw,addition_info,bvms_path) ");
    stringBuilder.append("select ord_no,CURRENT_TIMESTAMP,pat_id,fn_pat_id,treat_date,treat_week,facility_cd,facility_name,ind_va_cd,ind_treatment_cd,ind_treatment_name,");
    stringBuilder.append("ind_kur_cd,ind_kur_name,ind_treat_start_time,ind_bed_cd,ind_bed_name,ind_schedule_user_info,ind_cond_info,ind_medi_info,ind_equip_info,ind_ind_comment_info,");
    stringBuilder.append("ind_tare_info,ind_off_water_info,rst_fn_dialysis_no,rst_relation_dialysis_no,rst_edition,rst_is_update_edition,rst_input_class,rst_dialysis_state,");
    stringBuilder.append("rst_treatment_cd,rst_treatment_name,rst_kur_cd,rst_kur_name,rst_bed_cd,rst_bed_name,rst_machine_no,rst_machine_name,rst_cond_send_date,rst_accept_date,");
    stringBuilder.append("rst_start_date,rst_end_date,rst_return_home_date,rst_in_out_class,rst_dialysis_cnt,rst_ward_cd,rst_ward_name,rst_course_cd,rst_course_name,");
    stringBuilder.append("rst_puncture_user_info,rst_return_user_info,rst_charge_user_info,rst_blood_circulate_total,rst_running_time,rst_kt_v,rec_set_date,send_ctl_no,blood_purifier_name,");
    stringBuilder.append("pull_leave_amount,rst_cond_info,rst_medi_info,rst_equip_info,rst_ind_comment_info,rst_tare_info,rst_off_water_info,rst_weight_info,rst_complaint_info,");
    stringBuilder.append("rst_treatment_info,rst_treat_staff_info,rst_rounds_info,is_del,up_date,reg_date,ind_device_set_info,treat_type,rst_purification_cnt,");
    stringBuilder.append("up_ind_user_id,up_user_id,rst_dw,weight_scale_no,fn_plural,is_confirm,ind_dw,addition_info,bvms_path  from  ord_main ");
    stringBuilder.append("WHERE  facility_cd = :facility_cd and ord_no in (:ord_no) ");
    String insertOrdMainRestoreSql = stringBuilder.toString();
    List<Long> ordNoList = ordMains.stream().map(m -> m.getOrdNo()).collect(Collectors.toList());
    MapSqlParameterSource params = new MapSqlParameterSource();
    params.addValue("facility_cd", facilityCd);
    params.addValue("ord_no", ordNoList);
    batchUpdate(jdbcTemplateNkk5, insertOrdMainRestoreSql, params);
    batchUpdate(jdbcTemplateConvert, insertOrdMainRestoreSql, params);
    for (OrdMain ordMain : ordMains) {
      OrdMainHst ordMainHstData = getOrdMainHstData(ordMain);
      insertOrdMainHst(ordMainHstData, facilityCd);
    }
  }

  /**
   * delOrdChecklist
   * @param jdbcTemplateConvert
   * @param jdbcTemplateNkk5
   * @param ordNoList
   */

  public void delOrdChecklist(JdbcTemplate jdbcTemplateConvert, JdbcTemplate jdbcTemplateNkk5, List<Long> ordNoList, String facilityCd) {
    String delOrdChecklistSql = "DELETE FROM ord_checklist  WHERE facility_cd = :facility_cd AND ord_no in (:ord_no)";
    MapSqlParameterSource params = new MapSqlParameterSource();
    params.addValue("facility_cd", facilityCd);
    params.addValue("ord_no", ordNoList);
    batchUpdate(jdbcTemplateNkk5, delOrdChecklistSql, params);
    batchUpdate(jdbcTemplateConvert, delOrdChecklistSql, params);
  }

  /**
   * delOrdMaterialSave
   * @param jdbcTemplateNkk5
   * @param ordNoList
   * @param rstClass
   */
  public void delOrdMaterialSave(JdbcTemplate jdbcTemplateNkk5, List<Long> ordNoList, String rstClass, String facilityCd) {
    String delOrdMaterialSaveSql = "DELETE  FROM ord_material_save  WHERE facility_cd = :facility_cd AND supplies_base_no in (:supplies_base_no) AND supplies_source_class != '4' AND ind_rst_class = :ind_rst_class";
    MapSqlParameterSource params = new MapSqlParameterSource();
    params.addValue("facility_cd", facilityCd);
    params.addValue("supplies_base_no", ordNoList);
    params.addValue("ind_rst_class", rstClass);
    batchUpdate(jdbcTemplateNkk5, delOrdMaterialSaveSql, params);
  }

  /**
   * updOrdMaterialSave
   * @param jdbcTemplateNkk5
   * @param ordNoList
   */
  public void updOrdMaterialSave(JdbcTemplate jdbcTemplateNkk5, List<Long> ordNoList, String facilityCd) {
    String updOrdMaterialSaveSql = "UPDATE ord_material_save SET is_confirm = '0' , up_date = CURRENT_TIMESTAMP WHERE facility_cd = :facility_cd AND supplies_base_no in (:supplies_base_no) AND supplies_source_class != '4' AND ind_rst_class = '1'";
    MapSqlParameterSource params = new MapSqlParameterSource();
    params.addValue("facility_cd", facilityCd);
    params.addValue("supplies_base_no", ordNoList);
    batchUpdate(jdbcTemplateNkk5, updOrdMaterialSaveSql, params);
  }

  /**
   * delOrdSchedule
   * @param jdbcTemplateNkk5
   * @param ordNoList
   */
  public void delOrdSchedule(JdbcTemplate jdbcTemplateNkk5, List<Long> ordNoList, String facilityCd) {
    String delOrdChecklistSql = "DELETE  FROM ord_schedule  WHERE facility_cd = :facility_cd AND ord_no in (:ord_no)";
    MapSqlParameterSource params = new MapSqlParameterSource();
    params.addValue("facility_cd", facilityCd);
    params.addValue("ord_no", ordNoList);
    batchUpdate(jdbcTemplateNkk5, delOrdChecklistSql, params);
  }

  /**
   * delPatIndApprove
   * @param jdbcTemplateConvert
   * @param jdbcTemplateNkk5
   * @param ordNoList
   */
  public void delPatIndApprove(JdbcTemplate jdbcTemplateConvert, JdbcTemplate jdbcTemplateNkk5, List<Long> ordNoList, String facilityCd) {
    String delPatIndApproveSql = "DELETE  FROM pat_ind_approve  WHERE facility_cd = :facility_cd AND ord_no in (:ord_no);";
    delPatIndApproveSql += "DELETE  FROM pat_ind_approve_history  WHERE facility_cd = :facility_cd AND ord_no in (:ord_no);";
    MapSqlParameterSource params = new MapSqlParameterSource();
    params.addValue("facility_cd", facilityCd);
    params.addValue("ord_no", ordNoList);
    batchUpdate(jdbcTemplateNkk5, delPatIndApproveSql, params);
    batchUpdate(jdbcTemplateConvert, delPatIndApproveSql, params);
  }


  /**
   * updOrdTreatCondition
   * @param jdbcTemplateConvert
   * @param jdbcTemplateNkk5
   * @param ordNoList
   */
  public void updOrdTreatCondition(JdbcTemplate jdbcTemplateConvert, JdbcTemplate jdbcTemplateNkk5, List<Long> ordNoList, String facilityCd) {
    String delOrdTreatConditionSql = "UPDATE ord_treat_condition SET is_del = '1', is_disp = '0', up_date = CURRENT_TIMESTAMP  WHERE facility_cd = :facility_cd and ord_no in(:ord_no) and is_del = '0' and is_disp = '1'" ;
    MapSqlParameterSource params = new MapSqlParameterSource();
    params.addValue("facility_cd", facilityCd);
    params.addValue("ord_no", ordNoList);
    batchUpdate(jdbcTemplateNkk5, delOrdTreatConditionSql, params);
    batchUpdate(jdbcTemplateConvert, delOrdTreatConditionSql, params);
  }

  /**
   * updMniMonitorAndMotionRecord
   *
   * @param jdbcTemplateConvert
   * @param jdbcTemplateNkk5
   * @param ordMainList
   */
  public void updMniMonitorAndMotionRecord(JdbcTemplate jdbcTemplateConvert, JdbcTemplate jdbcTemplateNkk5, List<OrdMain> ordMainList, String facilityCd) {
    List<OrdMain> ordMains = ordMainList.stream().filter(o -> o.getRstBedCd() != null).collect(Collectors.toList());
    String getMachinesSql = "select MM.* from mst_bed MB inner join mst_machine MM  ON MB.machine_no = MM.machine_no and MM.facility_cd = MB.facility_cd  where MM.facility_cd = ? and MB.bed_cd = ? and MM.is_del = '0'" ;
    if (!ordMains.isEmpty()) {
      for (OrdMain ordMain : ordMains) {
        List<MstMachine> machines = jdbcTemplateNkk5.query(getMachinesSql, new BeanPropertyRowMapper<>(MstMachine.class), ordMain.getFacilityCd(), ordMain.getRstBedCd());
        if (!machines.isEmpty()) {
          MstMachine mstMachine = machines.get(0);
          resetMotionRecord(jdbcTemplateConvert,jdbcTemplateNkk5, mstMachine, ordMain.getOrdNo(), facilityCd);
          resetMniMonitor(jdbcTemplateConvert,jdbcTemplateNkk5, ordMain.getOrdNo(), facilityCd);
        }
      }
    }
  }

  /**
   * resetMniMonitor
   * @param jdbcTemplateConvert
   * @param jdbcTemplateNkk5
   * @param ordNo
   */
  private void resetMniMonitor(JdbcTemplate jdbcTemplateConvert,JdbcTemplate jdbcTemplateNkk5, Long ordNo, String facilityCd) {
    String sql = "update mni_monitor set ord_no = null,up_date = CURRENT_TIMESTAMP where  facility_cd = :facility_cd and ord_no = :ord_no" ;
    MapSqlParameterSource params = new MapSqlParameterSource();
    params.addValue("facility_cd", facilityCd);
    params.addValue("ord_no", ordNo);
    batchUpdate(jdbcTemplateNkk5,sql,params);
    batchUpdate(jdbcTemplateConvert,sql,params);
  }

  /**
   * resetMotionRecord
   * @param jdbcTemplateConvert
   * @param jdbcTemplateNkk5
   * @param mstMachine
   * @param ordNo
   */
  private void resetMotionRecord(JdbcTemplate jdbcTemplateConvert,JdbcTemplate jdbcTemplateNkk5, MstMachine mstMachine, Long ordNo, String facilityCd) {
    String sql = "update mnt_motion_record set ord_no = null, up_date = CURRENT_TIMESTAMP where  facility_cd = :facility_cd and machine_type_cd = :machine_type_cd and machine_serial = :machine_serial and ord_no = :ord_no" ;
    MapSqlParameterSource params = new MapSqlParameterSource();
    params.addValue("facility_cd", facilityCd);
    params.addValue("machine_type_cd", mstMachine.getMachineTypeCd());
    params.addValue("machine_serial", mstMachine.getMachineSerial());
    params.addValue("ord_no", ordNo);
    batchUpdate(jdbcTemplateNkk5,sql,params);
    batchUpdate(jdbcTemplateConvert,sql,params);
  }
  //add #10675 & #10676 djy end

  //add #10568 djy start
  /**
   * batchQuery
   * @param jdbcTemplate
   * @param sql
   * @param params
   * @param classz
   * @return
   * @param <T>
   */
  public <T>List<T> batchQuery(JdbcTemplate jdbcTemplate, String sql, MapSqlParameterSource params,Class<T> classz) {
    NamedParameterJdbcTemplate namedParameterJdbcTemplate = new NamedParameterJdbcTemplate(jdbcTemplate);
    return namedParameterJdbcTemplate.query(sql, params,new BeanPropertyRowMapper<>(classz));
  }

  /**
   * setNextPatInfoByBedCd
   * @param jdbcTemplate
   */
  public void setNextPatInfoAllBed(JdbcTemplate jdbcTemplate, String facilityCd) {
    EventLogMessage eventLogMessage = new EventLogMessage();
    String getMachinesSql = "select DISTINCT MM.facility_cd,MM.machine_type_cd,MM.machine_serial from mst_bed MB inner join mst_machine MM  ON MB.machine_no = MM.machine_no and MM.facility_cd = MB.facility_cd  where MM.facility_cd = :facility_cd and MM.is_del = '0'";
    MapSqlParameterSource params = new MapSqlParameterSource();
    params.addValue("facility_cd", facilityCd);
    List<MstMachine> machineList = batchQuery(jdbcTemplate, getMachinesSql, params, MstMachine.class);
    if (machineList != null && !machineList.isEmpty()) {
      eventLogMessage = eventLoggerUtil.getEventLogMessage("=================次患者更新==============",
              facilityCd, "setNextPatInfoAllBed処理開始");
      eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.INFO);
      for (MstMachine machine : machineList) {
        setNextPatInfo(machine, false, false, null);
      }
      eventLogMessage = eventLoggerUtil.getEventLogMessage("=================次患者更新==============",
              facilityCd, "setNextPatInfoAllBed処理終了");
      eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.INFO);
    }
  }

  /**
   * setNextPatInfo
   * @param mstMachine
   * @param isIndChange
   * @param isSendCondition
   * @param ordNo
   * @return
   */
  public Integer setNextPatInfo(MstMachine mstMachine, Boolean isIndChange, Boolean isSendCondition, Long ordNo) {
    int retrunValue = 0;
	String facilityCd = mstMachine.getFacilityCd();
    EventLogMessage eventLogMessage = new EventLogMessage();
    JSONObject jsonBody = new JSONObject();
    jsonBody.put("facility_cd", mstMachine.getFacilityCd());
    jsonBody.put("machine_type_cd", mstMachine.getMachineTypeCd());
    jsonBody.put("machine_serial", mstMachine.getMachineSerial());
    jsonBody.put("is_ind_change", isIndChange);
    jsonBody.put("up_date", new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date()));
    jsonBody.put("is_send_condition", isSendCondition);
    if (isSendCondition) {
      jsonBody.put("send_condition_ord_no", ordNo);
    } else {
      jsonBody.put("send_condition_ord_no", "");
    }
    RestTemplate rt = new RestTemplate();
    HttpStatus status = null;
    try {
      // 送信URI
      URI uri = new URI(setNextPatUrl);
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
        retrunValue = 9;
        eventLogMessage = eventLoggerUtil.getEventLogMessage("次患者更新API接続成功、内部処理に失敗"+response.getBody(),
                facilityCd, "JobStartEndLIstener.setNextPatInfo: MachineTypeCd:" + mstMachine.getMachineTypeCd() + ",MachineSerial:" + mstMachine.getMachineSerial());
        eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.ERROR);
      }
    } catch (Exception ex) {
      retrunValue = 9;
      eventLogMessage = eventLoggerUtil.getEventLogMessage("次患者更新APIの接続失敗:"+ex.getMessage(),
              facilityCd, "JobStartEndLIstener.setNextPatInfo: MachineTypeCd:" + mstMachine.getMachineTypeCd() + ",MachineSerial:" + mstMachine.getMachineSerial());
      eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.ERROR);
    }
    return retrunValue;
  }
  //add #10568 djy end

    public void sysTable() {
        DataSource convertDs = (DataSource) appContext.getBean(ApplicationConst.DbType.CONVERT);
        DataSource nkk5Ds = (DataSource) appContext.getBean(ApplicationConst.DbType.NKK5);
        NamedParameterJdbcTemplate convertJdbcTemplate = new NamedParameterJdbcTemplate(convertDs);
        NamedParameterJdbcTemplate nkk5JdbcTemplate = new NamedParameterJdbcTemplate(nkk5Ds);
        for (String tableName : sysTableNameList) {
            if (tableName.equals("sys_monitor_item")) {
                String sql = "SELECT * FROM sys_monitor_item";
                List<SysMonitorItem> nkk5EntityList = nkk5JdbcTemplate.getJdbcOperations().query(sql, new Object[]{}, new BeanPropertyRowMapper<>(SysMonitorItem.class));
                List<SysMonitorItem> convertEntityList = convertJdbcTemplate.getJdbcOperations().query(sql, new Object[]{}, new BeanPropertyRowMapper<>(SysMonitorItem.class));
                HashMap<String, SysMonitorItem> nkk5EntityMap = new HashMap();
                for (SysMonitorItem nkk5Entity : nkk5EntityList) {
                    nkk5EntityMap.put(nkk5Entity.getMoniDataNo(), nkk5Entity);
                }
                HashMap<String, SysMonitorItem> convertEntityMap = new HashMap();
                for (SysMonitorItem convertEntity : convertEntityList) {
                    convertEntityMap.put(convertEntity.getMoniDataNo(), convertEntity);
                }
                for (SysMonitorItem nkk5Entity : nkk5EntityList) {
                    if (!convertEntityMap.containsKey(nkk5Entity.getMoniDataNo())) {
                        sql = "INSERT INTO sys_monitor_item " +
                                "(moni_data_no, moni_data_type, moni_data_name, moni_data_short_name, data_type, decimal_figure, unit, upper, lower, is_disp, vital_monitor_class, conv_item, reg_date, up_date) " +
                                "VALUES (:moni_data_no, :moni_data_type, :moni_data_name, :moni_data_short_name, :data_type, :decimal_figure, :unit, :upper, :lower, :is_disp, :vital_monitor_class, :conv_item, :reg_date, :up_date )  ON CONFLICT DO NOTHING;";
                        MapSqlParameterSource params = new MapSqlParameterSource();
                        params.addValue("moni_data_no", nkk5Entity.getMoniDataNo());
                        params.addValue("moni_data_type", nkk5Entity.getMoniDataType());
                        params.addValue("moni_data_name", nkk5Entity.getMoniDataName());
                        params.addValue("moni_data_short_name", nkk5Entity.getMoniDataShortName());
                        params.addValue("data_type", nkk5Entity.getDataType());
                        params.addValue("decimal_figure", nkk5Entity.getDecimalFigure());
                        params.addValue("unit", nkk5Entity.getUnit());
                        params.addValue("upper", nkk5Entity.getUpper());
                        params.addValue("lower", nkk5Entity.getLower());
                        params.addValue("is_disp", nkk5Entity.getIsDisp());
                        params.addValue("vital_monitor_class", nkk5Entity.getVitalMonitorClass());
                        params.addValue("conv_item", nkk5Entity.getConvItem(), Types.OTHER);
                        params.addValue("reg_date", nkk5Entity.getRegDate());
                        params.addValue("up_date", nkk5Entity.getUpDate());
                        batchUpdate(convertJdbcTemplate.getJdbcTemplate(), sql, params);
                    }
                }
                for (SysMonitorItem convertEntity : convertEntityList) {
                    // exist in nkk5, exist in convert --> update convert
                    if (nkk5EntityMap.containsKey(convertEntity.getMoniDataNo())) {
                        SysMonitorItem nkk5Entity = nkk5EntityMap.get(convertEntity.getMoniDataNo());
                        if (!convertEntity.equals(nkk5Entity)) {
                            sql = "UPDATE  sys_monitor_item SET " +
                                    "moni_data_type = :moni_data_type, " +
                                    "moni_data_name = :moni_data_name, " +
                                    "moni_data_short_name = :moni_data_short_name, " +
                                    "data_type = :data_type, " +
                                    "decimal_figure = :decimal_figure, " +
                                    "unit = :unit, " +
                                    "upper = :upper, " +
                                    "lower = :lower, " +
                                    "is_disp = :is_disp, " +
                                    "vital_monitor_class = :vital_monitor_class, " +
                                    "conv_item = :conv_item, " +
                                    "reg_date = :reg_date, " +
                                    "up_date = :up_date  WHERE moni_data_no = :moni_data_no";
                            MapSqlParameterSource params = new MapSqlParameterSource();
                            params.addValue("moni_data_type", nkk5Entity.getMoniDataType());
                            params.addValue("moni_data_name", nkk5Entity.getMoniDataName());
                            params.addValue("moni_data_short_name", nkk5Entity.getMoniDataShortName());
                            params.addValue("data_type", nkk5Entity.getDataType());
                            params.addValue("decimal_figure", nkk5Entity.getDecimalFigure());
                            params.addValue("unit", nkk5Entity.getUnit());
                            params.addValue("upper", nkk5Entity.getUpper());
                            params.addValue("lower", nkk5Entity.getLower());
                            params.addValue("is_disp", nkk5Entity.getIsDisp());
                            params.addValue("vital_monitor_class", nkk5Entity.getVitalMonitorClass());
                            params.addValue("conv_item", nkk5Entity.getConvItem(), Types.OTHER);
                            params.addValue("reg_date", nkk5Entity.getRegDate());
                            params.addValue("up_date", nkk5Entity.getUpDate());
                            params.addValue("moni_data_no", nkk5Entity.getMoniDataNo());
                            batchUpdate(convertJdbcTemplate.getJdbcTemplate(), sql, params);
                        }
                    }
                    // not exist in nkk5, exist in convert --> del from convert
                    if (!nkk5EntityMap.containsKey(convertEntity.getMoniDataNo())) {
                        sql = "delete from sys_monitor_item  where moni_data_no= :moni_data_no";
                        MapSqlParameterSource params = new MapSqlParameterSource();
                        params.addValue("moni_data_no", convertEntity.getMoniDataNo());
                        batchUpdate(convertJdbcTemplate.getJdbcTemplate(), sql, params);
                    }
                }
            } else if (tableName.equals("mst_treatment_status_disp_item")) {

                String sql = "SELECT * FROM mst_treatment_status_disp_item";
                List<MstTreatmentStatusDispItem> nkk5EntityList = nkk5JdbcTemplate.getJdbcOperations().query(sql, new Object[]{}, new BeanPropertyRowMapper<>(MstTreatmentStatusDispItem.class));
                List<MstTreatmentStatusDispItem> convertEntityList = convertJdbcTemplate.getJdbcOperations().query(sql, new Object[]{}, new BeanPropertyRowMapper<>(MstTreatmentStatusDispItem.class));
                HashMap<Integer, MstTreatmentStatusDispItem> nkk5EntityMap = new HashMap();
                for (MstTreatmentStatusDispItem nkk5Entity : nkk5EntityList) {
                    nkk5EntityMap.put(nkk5Entity.getItemCd(), nkk5Entity);
                }
                HashMap<Integer, MstTreatmentStatusDispItem> convertEntityMap = new HashMap();
                for (MstTreatmentStatusDispItem convertEntity : convertEntityList) {
                    convertEntityMap.put(convertEntity.getItemCd(), convertEntity);
                }
                for (MstTreatmentStatusDispItem nkk5Entity : nkk5EntityList) {
                    if (!convertEntityMap.containsKey(nkk5Entity.getItemCd())) {
                        sql = "INSERT INTO mst_treatment_status_disp_item " +
                                "(item_cd, data_class, machine_class, item_name, table_name, field_name, json_key_name, disp_order, is_disp, is_del, reg_date, up_date, unit) " +
                                "VALUES (:item_cd, :data_class, :machine_class, :item_name, :table_name, :field_name, :json_key_name, :disp_order,:is_disp, :is_del, :reg_date, :up_date, :unit )  ON CONFLICT DO NOTHING;";
                        MapSqlParameterSource params = new MapSqlParameterSource();
                        params.addValue("item_cd", nkk5Entity.getItemCd());
                        params.addValue("data_class", nkk5Entity.getDataClass());
                        params.addValue("machine_class", nkk5Entity.getMachineClass());
                        params.addValue("item_name", nkk5Entity.getItemName());
                        params.addValue("table_name", nkk5Entity.getTableName());
                        params.addValue("field_name", nkk5Entity.getFieldName());
                        params.addValue("json_key_name", nkk5Entity.getJsonKeyName());
                        params.addValue("disp_order", nkk5Entity.getDispOrder());
                        params.addValue("is_disp", nkk5Entity.getIsDisp());
                        params.addValue("is_del", nkk5Entity.getIsDel());
                        params.addValue("reg_date", nkk5Entity.getRegDate());
                        params.addValue("up_date", nkk5Entity.getUpDate());
                        params.addValue("unit", nkk5Entity.getUnit());
                        batchUpdate(convertJdbcTemplate.getJdbcTemplate(), sql, params);
                    }
                }
                for (MstTreatmentStatusDispItem convertEntity : convertEntityList) {
                    // exist in nkk5, exist in convert --> update convert
                    if (nkk5EntityMap.containsKey(convertEntity.getItemCd())) {
                        MstTreatmentStatusDispItem nkk5Entity = nkk5EntityMap.get(convertEntity.getItemCd());
                        if (!convertEntity.equals(nkk5Entity)) {
                            sql = "UPDATE  sys_monitor_item SET " +
                                    "data_class = :data_class, " +
                                    "machine_class = :machine_class, " +
                                    "item_name = :item_name, " +
                                    "table_name = :table_name, " +
                                    "field_name = :field_name, " +
                                    "json_key_name = :json_key_name, " +
                                    "disp_order = :disp_order, " +
                                    "is_disp = :is_disp, " +
                                    "is_del = :is_del, " +
                                    "reg_date = :reg_date, " +
                                    "up_date = :up_date, " +
                                    "unit = :unit, WHERE item_cd = :item_cd";
                            MapSqlParameterSource params = new MapSqlParameterSource();
                            params.addValue("data_class", nkk5Entity.getDataClass());
                            params.addValue("machine_class", nkk5Entity.getMachineClass());
                            params.addValue("item_name", nkk5Entity.getItemName());
                            params.addValue("table_name", nkk5Entity.getTableName());
                            params.addValue("field_name", nkk5Entity.getFieldName());
                            params.addValue("json_key_name", nkk5Entity.getJsonKeyName());
                            params.addValue("disp_order", nkk5Entity.getDispOrder());
                            params.addValue("is_disp", nkk5Entity.getIsDisp());
                            params.addValue("is_del", nkk5Entity.getIsDel());
                            params.addValue("reg_date", nkk5Entity.getRegDate());
                            params.addValue("up_date", nkk5Entity.getUpDate());
                            params.addValue("unit", nkk5Entity.getUnit());
                            params.addValue("item_cd", nkk5Entity.getItemCd());
                            batchUpdate(convertJdbcTemplate.getJdbcTemplate(), sql, params);
                        }
                    }
                    // not exist in nkk5, exist in convert --> del from convert
                    if (!nkk5EntityMap.containsKey(convertEntity.getItemCd())) {
                        sql = "delete from mst_treatment_status_disp_item  where item_cd= :item_cd";
                        MapSqlParameterSource params = new MapSqlParameterSource();
                        params.addValue("item_cd", convertEntity.getItemCd());
                        batchUpdate(convertJdbcTemplate.getJdbcTemplate(), sql, params);
                    }
                }
            } else if (tableName.equals("mst_machine_type")) {

                String sql = "SELECT * FROM mst_machine_type";
                List<MstMachineType> nkk5EntityList = nkk5JdbcTemplate.getJdbcOperations().query(sql, new Object[]{}, new BeanPropertyRowMapper<>(MstMachineType.class));
                List<MstMachineType> convertEntityList = convertJdbcTemplate.getJdbcOperations().query(sql, new Object[]{}, new BeanPropertyRowMapper<>(MstMachineType.class));
                HashMap<String, MstMachineType> nkk5EntityMap = new HashMap();
                for (MstMachineType nkk5Entity : nkk5EntityList) {
                    nkk5EntityMap.put(nkk5Entity.getMachineTypeCd(), nkk5Entity);
                }
                HashMap<String, MstMachineType> convertEntityMap = new HashMap();
                for (MstMachineType convertEntity : convertEntityList) {
                    convertEntityMap.put(convertEntity.getMachineTypeCd(), convertEntity);
                }
                for (MstMachineType nkk5Entity : nkk5EntityList) {
                    if (!convertEntityMap.containsKey(nkk5Entity.getMachineTypeCd())) {
                        sql = "INSERT INTO mst_machine_type " +
                                "(machine_type_cd, machine_type, model, maker, reg_date, up_date, com_type, treat_mode,over_nxseries) " +
                                "VALUES (:machine_type_cd, :machine_type, :model, :maker, :reg_date, :up_date, :com_type, :treat_mode,:over_nxseries)  ON CONFLICT DO NOTHING;";
                        MapSqlParameterSource params = new MapSqlParameterSource();
                        params.addValue("machine_type_cd", nkk5Entity.getMachineTypeCd());
                        params.addValue("machine_type", nkk5Entity.getMachineType());
                        params.addValue("model", nkk5Entity.getModel());
                        params.addValue("maker", nkk5Entity.getMaker());
                        params.addValue("reg_date", nkk5Entity.getRegDate());
                        params.addValue("up_date", nkk5Entity.getUpDate());
                        params.addValue("com_type", nkk5Entity.getComType(), Types.OTHER);
                        params.addValue("treat_mode", nkk5Entity.getTreatMode());
                        params.addValue("over_nxseries", nkk5Entity.getOperatorId());
                        batchUpdate(convertJdbcTemplate.getJdbcTemplate(), sql, params);
                    }
                }
                for (MstMachineType convertEntity : convertEntityList) {
                    // exist in nkk5, exist in convert --> update convert
                    if (nkk5EntityMap.containsKey(convertEntity.getMachineTypeCd())) {
                        MstMachineType nkk5Entity = nkk5EntityMap.get(convertEntity.getMachineTypeCd());
                        if (!convertEntity.equals(nkk5Entity)) { // 需要重写equals() 和hashCode()
                            sql = "UPDATE  mst_machine_type SET " +
                                    "machine_type = :machine_type, " +
                                    "model = :model, " +
                                    "maker = :maker, " +
                                    "reg_date = :reg_date, " +
                                    "up_date = :up_date, " +
                                    "com_type = :com_type, " +
                                    "treat_mode = :treat_mode, " +
                                    "over_nxseries = :over_nxseries  WHERE machine_type_cd = :machine_type_cd";
                            MapSqlParameterSource params = new MapSqlParameterSource();
                            params.addValue("machine_type", nkk5Entity.getMachineType());
                            params.addValue("model", nkk5Entity.getModel());
                            params.addValue("maker", nkk5Entity.getMaker());
                            params.addValue("reg_date", nkk5Entity.getRegDate());
                            params.addValue("up_date", nkk5Entity.getUpDate());
                            params.addValue("com_type", nkk5Entity.getComType(), Types.OTHER);
                            params.addValue("treat_mode", nkk5Entity.getTreatMode());
                            params.addValue("over_nxseries", nkk5Entity.getOperatorId());
                            params.addValue("machine_type_cd", nkk5Entity.getMachineTypeCd());
                            batchUpdate(convertJdbcTemplate.getJdbcTemplate(), sql, params);
                        }
                    }
                    // not exist in nkk5, exist in convert --> del from convert
                    if (!nkk5EntityMap.containsKey(convertEntity.getMachineTypeCd())) {
                        sql = "delete from mst_machine_type  where machine_type_cd= :machine_type_cd";
                        MapSqlParameterSource params = new MapSqlParameterSource();
                        params.addValue("machine_type_cd", convertEntity.getMachineTypeCd());
                        batchUpdate(convertJdbcTemplate.getJdbcTemplate(), sql, params);
                    }
                }
            } else if (tableName.equals("mst_machine_record")) {

                String sql = "SELECT * FROM mst_machine_record";
                List<MstMachineRecord> nkk5EntityList = nkk5JdbcTemplate.getJdbcOperations().query(sql, new Object[]{}, new BeanPropertyRowMapper<>(MstMachineRecord.class));
                List<MstMachineRecord> convertEntityList = convertJdbcTemplate.getJdbcOperations().query(sql, new Object[]{}, new BeanPropertyRowMapper<>(MstMachineRecord.class));
                HashMap<String, MstMachineRecord> nkk5EntityMap = new HashMap();
                for (MstMachineRecord nkk5Entity : nkk5EntityList) {
                    nkk5EntityMap.put(nkk5Entity.getMachineRecordCd(), nkk5Entity);
                }
                HashMap<String, MstMachineRecord> convertEntityMap = new HashMap();
                for (MstMachineRecord convertEntity : convertEntityList) {
                    convertEntityMap.put(convertEntity.getMachineRecordCd(), convertEntity);
                }
                for (MstMachineRecord nkk5Entity : nkk5EntityList) {
                    if (!convertEntityMap.containsKey(nkk5Entity.getMachineRecordCd())) {
                        sql = "INSERT INTO mst_machine_record " +
                                "(machine_record_cd, machine_record_message, reg_date, up_date, is_default, log_class, target_model, disp_flg) " +
                                "VALUES (:machine_record_cd, :machine_record_message, :reg_date, :up_date, :is_default, :log_class, :target_model, :disp_flg)  ON CONFLICT DO NOTHING;";
                        MapSqlParameterSource params = new MapSqlParameterSource();
                        params.addValue("machine_record_cd", nkk5Entity.getMachineRecordCd());
                        params.addValue("machine_record_message", nkk5Entity.getMachineRecordMessage());
                        params.addValue("reg_date", nkk5Entity.getRegDate());
                        params.addValue("up_date", nkk5Entity.getUpDate());
                        params.addValue("is_default", nkk5Entity.getIsDefault());
                        params.addValue("log_class", nkk5Entity.getLogClass());
                        params.addValue("target_model", nkk5Entity.getTargetModel());
                        params.addValue("disp_flg", nkk5Entity.getDispFlg());
                        batchUpdate(convertJdbcTemplate.getJdbcTemplate(), sql, params);
                    }
                }
                for (MstMachineRecord convertEntity : convertEntityList) {
                    // exist in nkk5, exist in convert --> update convert
                    if (nkk5EntityMap.containsKey(convertEntity.getMachineRecordCd())) {
                        MstMachineRecord nkk5Entity = nkk5EntityMap.get(convertEntity.getMachineRecordCd());
                        if (!convertEntity.equals(nkk5Entity)) { // 需要重写equals() 和hashCode()
                            sql = "UPDATE  mst_machine_record SET " +
                                    "machine_record_message = :machine_record_message, " +
                                    "reg_date = :reg_date, " +
                                    "up_date = :up_date, " +
                                    "is_default = :is_default, " +
                                    "log_class = :log_class, " +
                                    "target_model = :target_model, " +
                                    "disp_flg = :disp_flgWHERE machine_record_cd = :machine_record_cd ";
                            MapSqlParameterSource params = new MapSqlParameterSource();
                            params.addValue("machine_record_message", nkk5Entity.getMachineRecordMessage());
                            params.addValue("reg_date", nkk5Entity.getRegDate());
                            params.addValue("up_date", nkk5Entity.getUpDate());
                            params.addValue("is_default", nkk5Entity.getIsDefault());
                            params.addValue("log_class", nkk5Entity.getLogClass());
                            params.addValue("target_model", nkk5Entity.getTargetModel());
                            params.addValue("disp_flg", nkk5Entity.getDispFlg());
                            params.addValue("machine_record_cd", nkk5Entity.getMachineRecordCd());
                            batchUpdate(convertJdbcTemplate.getJdbcTemplate(), sql, params);
                        }
                    }
                    // not exist in nkk5, exist in convert --> del from convert
                    if (!nkk5EntityMap.containsKey(convertEntity.getMachineRecordCd())) {
                        sql = "delete from mst_machine_record  where machine_record_cd= :machine_record_cd";
                        MapSqlParameterSource params = new MapSqlParameterSource();
                        params.addValue("machine_record_cd", convertEntity.getMachineRecordCd());
                        batchUpdate(convertJdbcTemplate.getJdbcTemplate(), sql, params);
                    }
                }
            }
        }
    }

    public static GlobalContext getGlobalContext() {
        return localGlobal.get();
    }
}