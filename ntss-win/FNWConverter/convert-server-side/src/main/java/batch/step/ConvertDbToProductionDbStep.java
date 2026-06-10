package batch.step;

import batch.ApplicationConst;
import batch.ApplicationConst.JobParameterKeys;
import batch.config.ConvertKeyConfig;
import batch.entity.MstBed;
import batch.entity.MstKur;
import batch.entity.MstMachine;
import batch.entity.MstMachineType;
import batch.entity.OrdMain;
import batch.entity.OrdSchedule;
import batch.entity.PatGroupDetailHistoryEntity;
import batch.entity.PatInsuranceHistoryEntity;
import batch.entity.PatMainHistoryEntity;
import batch.entity.PatPersonalMainHistoryEntity;
import batch.entity.PatUniqueHistoryEntity;
import batch.entity.mongo.AdditionInfo;
import batch.entity.mongo.ChargeStaffInfo;
import batch.entity.mongo.DialDiffComInfo;
import batch.entity.mongo.ImplantInfo;
import batch.entity.mongo.InfectInfo;
import batch.entity.mongo.MedicalCareInfo;
import batch.entity.mongo.OtherContactInfo;
import batch.entity.mongo.PatGroupInfo;
import batch.entity.mongo.PatMemoInfo;
import batch.entity.mongo.TabooAllergyInfo;
import batch.listener.JobStartEndLIstener;
import batch.listener.PromotionListener;
import batch.listener.StepStartEndListener;
import batch.part.FileVisitor;
import batch.part.InfomationSchemaControl;
import batch.part.PsqlCopyUtils;
import batch.part.StreamThread;
import batch.part.TableNameToDbType;
import com.amazonaws.util.CollectionUtils;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.Getter;
import lombok.Setter;
import org.postgresql.util.PGobject;
import org.springframework.batch.core.Step;
import org.springframework.batch.core.StepContribution;
import org.springframework.batch.core.configuration.annotation.StepBuilderFactory;
import org.springframework.batch.core.scope.context.ChunkContext;
import org.springframework.batch.core.step.tasklet.Tasklet;
import org.springframework.batch.repeat.RepeatStatus;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.context.ApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.core.env.Environment;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.core.query.Update;
import org.springframework.jdbc.core.BatchPreparedStatementSetter;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.jdbc.core.namedparam.SqlParameterSourceUtils;
import org.springframework.stereotype.Component;
import org.springframework.util.ObjectUtils;
import org.thymeleaf.util.StringUtils;
import utils.GlobalContext;
import utils.PatEventService;
import utils.Utils;
import web.config.EventLoggerUtil;
import web.logger.EventLogMessage;
import web.logger.LogLevel;
import java.io.File;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

/**
 * コンバートDBから本番DBにテーブルデータを登録するTaskletStep
 */
@Component
public class ConvertDbToProductionDbStep extends StepStartEndListener implements Tasklet {

    public static final String STEP_NAME = "ConvertDbToProductionDbStep";

    @Autowired
    private ApplicationContext appContext;

    @Autowired
    private StepBuilderFactory stepBuilderFactory;

    @Autowired
    private ConvertKeyConfig convertKeyConfig;

    @Autowired
    Utils utils;

    @Autowired
    private Environment environment;

    @Autowired
    private PsqlCopyUtils psqlCopyUtils;
    //add 6886
    @Autowired(required = false)
    MongoTemplate mongoTemplate;

    /**
     * ロギング ツール クラスの導入
     */
    @Autowired
    private EventLoggerUtil eventLoggerUtil;

    // add 2022-11-15 bug #7882 患者イベントのVA画像がコンバートされていない 孫 start
    @Autowired
    private PatEventService patEventService;
    // add 2022-11-15 bug #7882 患者イベントのVA画像がコンバートされていない 孫 end

    private static final List<String> latestFlagTableList = List.of("pat_personal_main_history", "pat_main_history", "pat_unique_history");


    @Autowired
    @Qualifier(ApplicationConst.JdbcTempleteName.JDBC_TEMPLATE_NKK5)
    private JdbcTemplate jdbcTemplateNkk5;


    @Autowired
    @Qualifier(ApplicationConst.JdbcTempleteName.JDBC_TEMPLATE_CONVERT)
    private JdbcTemplate jdbcTemplateConvert;

    @Autowired
    @Qualifier(ApplicationConst.JdbcTempleteName.NAMED_PARAMETER_JDBCTEMPLATE_NKK5)
    private NamedParameterJdbcTemplate namedParameterJdbcTemplateNkk5;

    @Autowired
    @Qualifier(ApplicationConst.JdbcTempleteName.NAMED_PARAMETER_JDBCTEMPLATE_CONVERT)
    private NamedParameterJdbcTemplate namedParameterJdbcTemplateConvert;

    @Override
    public RepeatStatus execute(StepContribution contribution, ChunkContext chunkContext) throws Exception {
        GlobalContext globalContext = JobStartEndLIstener.getGlobalContext();
        // 施設コードを取得
        String facilityCd = chunkContext.getStepContext().getJobParameters().get(JobParameterKeys.FACILITY_CD).toString();

        // 処理対象ファイル名からテーブル名の取得
        String nextProcessingFile = chunkContext.getStepContext().getJobExecutionContext().get(ApplicationConst.PromotionKeys.NEXT_PROCESSING_FILE).toString();
        String inputFilePath = chunkContext.getStepContext().getJobParameters().get(JobParameterKeys.INPUT_FILE_PATH).toString();

        // add 2022-11-15 bug #7882 患者イベントのVA画像がコンバートされていない 孫 start
        // pat_eventのデータをCopyしましたの場合、S3にファイルをアップロードする
        if ("pat_event".equals(PsqlCopyUtils.getTableName(nextProcessingFile))) {
            //ログ
            EventLogMessage eventLogMessageS3_1 = eventLoggerUtil.getEventLogMessage("S3ファイルアップロード実行",
                    facilityCd, "execute(StepContribution contribution, ChunkContext chunkContext)");
            eventLoggerUtil.recordLog(facilityCd, eventLogMessageS3_1, LogLevel.INFO);

            Path basePath = Paths.get(chunkContext.getStepContext().getJobParameters().get(JobParameterKeys.INPUT_FILE_PATH).toString());
            String upResult = patEventService.UploadEventAddedFiles(facilityCd,
                    Paths.get(nextProcessingFile).toString(), basePath.toString(), "AddedFiles", globalContext.maxPrimaryForConvert);

            //ログ
            String upResultMessage = "S3ファイルアップロード正常終了";
            if (!PatEventService.STOP_STATUS.NORMAL.equals(upResult)) {
                upResultMessage = "S3ファイルアップロード異常終了";
            }
            EventLogMessage eventLogMessageS3_2 = eventLoggerUtil.getEventLogMessage(upResultMessage,
                    facilityCd, "execute(StepContribution contribution, ChunkContext chunkContext)");
            eventLoggerUtil.recordLog(facilityCd, eventLogMessageS3_2, LogLevel.INFO);
        }
        // add 2022-11-15 bug #7882 患者イベントのVA画像がコンバートされていない 孫 end

        //mod 2022-04-01   判断条件の修正  鄭  start
        int indexFile = nextProcessingFile.indexOf("indicatorShoe");
        //mod 2022-04-01   判断条件の修正  鄭  end
        //add 2022-05-07  #6886 判断条件の修正  鄭  start
        int patmongo = nextProcessingFile.indexOf("pat(mongo)");
        //add 2022-05-07 #6886  判断条件の修正  鄭  END

        if (indexFile != -1 || patmongo != -1) {
            //ログ
            EventLogMessage eventLogMessage = eventLoggerUtil.getEventLogMessage("Copyコマンド正常終了",
                    facilityCd, "execute(StepContribution contribution, ChunkContext chunkContext)");
            eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.INFO);
            FileVisitor fv = new FileVisitor();
            boolean checkState = fv.readFileLineAndCheckAnnotation(nextProcessingFile);
            if (!checkState) {
                try {
                    File deFile = new File(nextProcessingFile);
                    deFile.delete();
                } catch (Exception e) {
                    throw new RuntimeException(e);
                }
            }
            return RepeatStatus.FINISHED;
        } else {
            String tableName = PsqlCopyUtils.getTableName(nextProcessingFile);
            //add 6886 zc start
            if (Set.of("pat_personal_main_history",
                    "pat_insurance_history",
                    "pat_main_history",
                    "pat_group_detail_history").contains(tableName)) {
                setMongoDate(nextProcessingFile, facilityCd, tableName);
                return RepeatStatus.FINISHED;
            }
            //8585最適化によりpat _unique_historyはCSV形式に変更され、ここでは成功に直接戻り、スキップ
            if (tableName.equals("pat_unique_history")) {
                return RepeatStatus.FINISHED;
            }
            //add 6886 zc end

            // 登録先テーブルの列を取得
            InfomationSchemaControl isc = new InfomationSchemaControl(appContext);
            List<String> columnNameList = isc.getColumnNamesExclusiveSeqColumn(tableName);
            //add  #7576  鄭  start
            if (tableName.equals("ord_material_save")) {
                columnNameList.add("supplies_base_no");
            }
            //add  #7576  鄭  end

            /**
             * 初回新規と差分新規の前の表の最大番号を取る
             */
            Integer currSeq = 0;
            Integer getSeqValue = getSeqOfEachTable(tableName,facilityCd);
            if (getSeqValue != null) {
                currSeq = getSeqValue;
            }
            try {
                // 初回コンバートの場合
                if (!nextProcessingFile.contains("[diff]")) {
                    firstConvert(tableName, currSeq, nextProcessingFile, facilityCd, chunkContext);
                    return RepeatStatus.FINISHED;
                } else { // 差分コンバートの場合
                    diffConvert(tableName, columnNameList, currSeq, nextProcessingFile, inputFilePath, facilityCd);
                    return RepeatStatus.FINISHED;
                }
            } catch (Exception e) {
                if (tableName.equals("ord_main")) {
                    globalContext.ErrorOrdNo = currSeq;
                }
                EventLogMessage eventLogMessage = eventLoggerUtil.getEventLogMessage("初回コンバートの場合&差分コンバートの場合実行：" + e.getMessage(),
                        facilityCd, "ConvertDbToProductionDbStep");
                eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.ERROR);
                throw e;
            }
        }
        // add 7853-差分コンバートで更新/削除ができない 楊 end
        // del 7853-差分コンバートで更新/削除ができない 楊 start
    }

    /**
     * 初回コンバートの場合
     * @param tableName
     * @param currSeq
     * @param nextProcessingFile
     * @param facilityCd
     * @param chunkContext
     * @throws Exception
     */
    private void firstConvert(String tableName, Integer currSeq,String nextProcessingFile, String facilityCd, ChunkContext chunkContext) throws Exception {
        GlobalContext globalContext = JobStartEndLIstener.getGlobalContext();
        String inputPath = chunkContext.getStepContext().getJobParameters().get(JobParameterKeys.INPUT_FILE_PATH).toString();
        String fromDb_table_prefix = environment.getProperty("datasource." + ApplicationConst.DbType.NKK5 + ".table_prefix");
        // add #10143 djy start
        // mod #10418 SQL注入対策：パラメータバインディング start
        if (globalContext.ErrorOrdNo != null) {
            namedParameterJdbcTemplateNkk5.getJdbcOperations().update("delete from ord_main where ord_no > ? and facility_cd = ?", globalContext.ErrorOrdNo, facilityCd);
            namedParameterJdbcTemplateNkk5.getJdbcOperations().update("delete from ord_schedule where ord_no > ? and facility_cd = ?", globalContext.ErrorOrdNo, facilityCd);
            globalContext.ErrorOrdNo = null;
        }
        // mod #10418 SQL注入対策：パラメータバインディング end
        // add #10143 djy end
        // sqlファイルから、コピーsqlを取得する
        File fileConvertDbToProductionDbStep = new File(inputPath + "/ConvertDbToProductionDbStep.txt");
        // コンバートDBから本番DBにテーブルデータを登録ファイル 一行目：テープル、二～四行目：sqlCommand
        if (fileConvertDbToProductionDbStep.exists() && 0 != fileConvertDbToProductionDbStep.length()) {
            String[] command = new String[3];
            List<String> sqlConvertDbToProductionDbStep = utils.readFile(fileConvertDbToProductionDbStep);
            if ("\\".equals(System.getProperty("file.separator"))) {
                command[0] = "cmd.exe";
                command[1] = "/c";
            } else {
                command[0] = "sh";
                command[1] = "-c";
            }
            for (int i = 1; i < sqlConvertDbToProductionDbStep.size(); i++) {
                command[2] = sqlConvertDbToProductionDbStep.get(i);
                EventLogMessage eventLogMessagetodo1 = eventLoggerUtil.getEventLogMessage("初回コピーコマンド実行：" + command[2],
                        facilityCd, "ConvertDbToProductionDbStep");
                eventLoggerUtil.recordLog(facilityCd, eventLogMessagetodo1, LogLevel.INFO);
                this.runCommand(command, tableName, facilityCd);
            }
            //ord_mainトリガの置換
            if (tableName.equals("ord_main")) {
                // add #9839 wzy start
                // mod #10418 SQL注入対策：パラメータバインディング start
                String update_ord_main_sql = "select facility_cd, ord_no, treat_date, ind_kur_cd, ind_bed_cd, pat_id, treat_week, ind_cond_info, rst_weight_info from " + fromDb_table_prefix + tableName
                        + " where facility_cd = ? and ord_no > ?";
                List<OrdMain> ordNoList1 = namedParameterJdbcTemplateNkk5.getJdbcOperations().query(update_ord_main_sql, new Object[]{facilityCd, currSeq}, new BeanPropertyRowMapper<>(OrdMain.class));
                String mst_kur_sql = "select A.kur_cd, A.kur_start_time, A.kur_end_time, A.kur_standard_start_time from mst_kur A where A.is_del = '0' AND facility_cd = ? order by A.kur_cd";
                List<MstKur> mstKur = namedParameterJdbcTemplateNkk5.getJdbcOperations().query(mst_kur_sql, new Object[]{facilityCd}, new BeanPropertyRowMapper<>(MstKur.class));
                // mod #10418 SQL注入対策：パラメータバインディング end
                List<OrdSchedule> osParamList = new LinkedList<>();
                String insertOrdScheduleSQL = "INSERT INTO ord_schedule (facility_cd, ord_no, treat_date, kur_cd, bed_cd, pat_id, is_dummy, up_date, reg_date, treat_week)"
                        + "VALUES(:facilityCd, :ordNo, :treatDate, :kurCd, :bedCd, :patId, :isDummy, now(), now(), :treatWeek);";
                for (OrdMain om : ordNoList1) {

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
                    if (0 != mstKur.size()) {
                        List<OrdSchedule> dummyScheduleList = this.insertOrdSchedule1(om, mstKur);
                        // add #8805 【デグレ】ツール出力時にエラーが検出されていないがエラーメッセージが表示され進まない ZS end
                        if (!CollectionUtils.isNullOrEmpty(dummyScheduleList))
                            osParamList.addAll(dummyScheduleList);
                    }
                }

                // 治療スケジュール一括挿入のParams
                namedParameterJdbcTemplateNkk5.batchUpdate(insertOrdScheduleSQL, SqlParameterSourceUtils.createBatch(osParamList));
                // add #9839 wzy end
            }else if (tableName.equals("mst_bed")) {
                //add mst _bedが新しく挿入したデータのリスト start
                // mod #10418 SQL注入対策：パラメータバインディング start
                String update_mnt_machine_state="WITH mac AS ( \n" +
                        "SELECT b.facility_cd,bed_cd, bed_name, b.machine_no,m.machine_type_cd,m.machine_serial FROM  " + fromDb_table_prefix + tableName +"  b "+
                        "LEFT JOIN "  + fromDb_table_prefix +"mst_machine m on  b.machine_no=m.machine_no  " +
                        "  WHERE b.facility_cd = ? and m.facility_cd = ?    and  b.is_disp='1' AND b.bed_cd > ?) " +
                        "UPDATE "+ fromDb_table_prefix +"mnt_machine_state " +
                        "SET bed_cd = (" +
                        "SELECT bed_cd FROM mac o WHERE " +
                        "mnt_machine_state.machine_type_cd = o.machine_type_cd " +
                        "AND mnt_machine_state.machine_serial = o.machine_serial " +
                        "AND mnt_machine_state.facility_cd = o.facility_cd )," +
                        "bed_name= (" +
                        "SELECT bed_name FROM mac o WHERE " +
                        "mnt_machine_state.machine_type_cd = o.machine_type_cd " +
                        "AND mnt_machine_state.machine_serial = o.machine_serial " +
                        "AND mnt_machine_state.facility_cd = o.facility_cd ) " +
                        "WHERE   mnt_machine_state.facility_cd = ? ";
                namedParameterJdbcTemplateNkk5.getJdbcOperations().update(update_mnt_machine_state, facilityCd, facilityCd, currSeq, facilityCd);
                // mod #10418 SQL注入対策：パラメータバインディング end
                //add mst _bedが新しく挿入したデータのリスト end
            }
            // #8753 旧通信項目がDBに登録されていないこと ADD by Zhoutao START
            else if ("mst_machine_record_control".equals(tableName)) {
                // 旧通信項目を削除する
                // mod #10418 SQL注入対策：パラメータバインディング start
                String delMstMachineRecordControl = "delete from mst_machine_record_control where facility_cd = ?"
                        + " and machine_record_cd not in (select machine_record_cd from mst_machine_record)";
                // LOG
                EventLogMessage eventLogMessagetodo1 = eventLoggerUtil.getEventLogMessage("初回コピーコマンド実行：" + delMstMachineRecordControl,
                        facilityCd, "ConvertDbToProductionDbStep");
                eventLoggerUtil.recordLog(facilityCd, eventLogMessagetodo1, LogLevel.INFO);
                namedParameterJdbcTemplateNkk5.getJdbcOperations().update(delMstMachineRecordControl, facilityCd);
                // mod #10418 SQL注入対策：パラメータバインディング end
            }
            // #8753 ADD by Zhoutao END

            // 処理完了したファイルを完了フォルダへ移動
            this.moveInputFile(nextProcessingFile);
            //　Copyコマンド正常終了場合、ファイル削除
            if (fileConvertDbToProductionDbStep.exists()) fileConvertDbToProductionDbStep.delete();

            EventLogMessage eventLogMessagetodo1 = eventLoggerUtil.getEventLogMessage("Copyコマンド(convert_db-本番)正常終了" + tableName,
                    facilityCd, "ConvertDbToProductionDbStep");
            eventLoggerUtil.recordLog(facilityCd, eventLogMessagetodo1, LogLevel.INFO);
        }
    }

    // 差分コンバートの場合
    private void diffConvert(String tableName, List<String> columnNameList, Integer currSeq, String nextProcessingFile,String inputFilePath, String facilityCd) throws Exception {
        GlobalContext globalContext = JobStartEndLIstener.getGlobalContext();
        String tableKey = convertKeyConfig.getTableKey(tableName);
        InfomationSchemaControl isc = new InfomationSchemaControl(appContext);
        List<String> columnNameListUpd = isc.getColumnNamesForCodeConversion(tableName);
        String cols = convertKeyConfig.getConvertKey(tableName);
        if (StringUtils.isEmptyOrWhitespace(cols)) {
            cols = convertKeyConfig.getConvertbKey(tableName);
        }
        // mod zl start
        String pKey = "";
        if (!cols.isEmpty()) {
            String[] names = cols.split(",");
            pKey = names[1];
        }
        // mod zl end

        // 登録先DBTypeの取得
        TableNameToDbType tableNameToDbType = new TableNameToDbType(appContext);
        String registDbType = tableNameToDbType.getDbTypeByTableName(tableName);

        // add #8400 LL start
        boolean processMstSelector = false;

        // add #8400 LL end


        String delSql = "delete from " + tableName + " where " + pKey + " in (" + globalContext.sqlKeys + ")";
        // SQL Injection protection: escape single quotes for psql script context
        if (globalContext.hasFacilityCd) {
            delSql += " and facility_cd = '" + facilityCd + "'";
        }
        //add #12229  convert ->本番DB  start
        if (utils.ConvertNotData.contains(tableName)) {
            if (globalContext.sqlKeys.isEmpty() || utils.onlyInsertList.contains(tableName)) {
                delSql = "";
            }
            String[] commandUpd = psqlCopyUtils.createCopyCommandUpdDiff(inputFilePath, tableName, ApplicationConst.DbType.CONVERT,
                    registDbType, columnNameListUpd, facilityCd, "", delSql, true);
            this.runCommand(commandUpd, tableName, facilityCd);
            processMstSelector = true;
        }
        //add #12229  end
        // 更新部分Copyコマンドを作成（本番キー含む）
        //add #11998 start
        List<Integer> updatedConvertIds = new ArrayList<>();
        //add #11998 end
        if (!StringUtils.isEmpty(globalContext.sqlKeys) && !processMstSelector && !utils.allDeleteAllInsertList.contains(tableName)) {
            String sqlCnd = " and " + pKey + " in (" + globalContext.sqlKeys + ")";
            String[] commandUpd = psqlCopyUtils.createCopyCommandUpdDiff(inputFilePath, tableName, ApplicationConst.DbType.CONVERT,
                    registDbType, columnNameListUpd, facilityCd, sqlCnd, delSql, true);

            EventLogMessage eventLogMessage = eventLoggerUtil.getEventLogMessage("差分コピーコマンド実行：" + commandUpd[2],
                    facilityCd, "ConvertDbToProductionDbStep");
            eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.INFO);
            if (commandUpd[2].length() > 8000) {
                String userName = environment.getProperty("datasource." + ApplicationConst.DbType.CONVERT + ".username");
                String table_prefix = environment.getProperty(userName + "_prefix");
                table_prefix = table_prefix == null ? "" : table_prefix;
                int num = "ord_main".equals(tableName) ? 50 : 200;
                List<String> result = Arrays.asList(globalContext.sqlKeys.split(","));
                List<List<String>> resList = Utils.sqlSplit(result, num);
                for (List<String> res : resList) {
                    String fnValueSub = String.join(",", res);
                    delSql = " delete from " + table_prefix + tableName + " where " + pKey + " in (" + fnValueSub + ")";
                    delSql += globalContext.hasFacilityCd ? " and facility_cd='" + facilityCd + "'" : "";
                    delSql += "; ";
                    String[] commandSub = psqlCopyUtils.createCopyCommandUpdDiff(inputFilePath, tableName, ApplicationConst.DbType.CONVERT,
                            registDbType, columnNameListUpd, facilityCd, " and " + pKey + " in (" + fnValueSub + ")", delSql, true);

                    eventLogMessage = eventLoggerUtil.getEventLogMessage("差分コピーコマンド実行：" + commandSub[2],
                            facilityCd, "ConvertDbToProductionDbStep");
                    eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.INFO);
                    this.runCommand(commandSub, tableName, facilityCd);
                }
            } else {
                this.runCommand(commandUpd, tableName, facilityCd);
            }
            //トリガの代わりに、差分変更データの削除今回操作、削除操作をトリガする
            if (tableName.equals("ord_main")) {
                // ord_main update Triggerの代替処理
                processDeleteOrdMainTrigger(facilityCd);
            } else if (tableName.equals("mst_machine")) {
                //mst_machine DELETEトリガの置き換え
                //削除するデータセットの取得に基づいて、他のテーブルのアクションmnt _machine_stateテーブルとmst _bed
                // mst_machine Delete Triggerの代替処理
                processDeleteMstMachineTrigger(pKey,facilityCd);
            } else if (tableName.equals("mst_bed")) {
                //add  mst_bed UPDATEトリガの置き換え start
                // mst_bed update Triggerの代替処理
                processUpdateMstBedTrigger(facilityCd);
            }//add  mst_bed UPDATEトリガの置き換え end
            else if (tableName.equals("mst_comsv_setting")) {
                String sqlSelectConvertId = "SELECT convert_id from mst_comsv_setting where facility_cd = ? and comsv_cd in (" + globalContext.sqlKeys + ") order by convert_id";;
                updatedConvertIds = namedParameterJdbcTemplateConvert.getJdbcOperations().queryForList(sqlSelectConvertId, new Object[]{facilityCd}, Integer.class);
            }
        }

        // 新規部分Copyコマンドを作成（本番キーなし）
        // mod #8400 LL start
        // mod zl start ord_main差分
        if ((!StringUtils.isEmpty(globalContext.sqlNewKeys) || !StringUtils.isEmpty(globalContext.sqlDisNoKeys)) && !processMstSelector) {
            // add #10143 djy start
            if (globalContext.ErrorOrdNo != null) {
                namedParameterJdbcTemplateNkk5.getJdbcOperations().update("delete from ord_main where ord_no > ? and facility_cd = ?", globalContext.ErrorOrdNo, facilityCd);
                namedParameterJdbcTemplateNkk5.getJdbcOperations().update("delete from ord_schedule where ord_no > ? and facility_cd = ?", globalContext.ErrorOrdNo, facilityCd);
                globalContext.ErrorOrdNo = null;
            }
            // add #10143 djy end
            // mod #8400 LL end
            String key = "";
            if ("B".equals(globalContext.plan)) {
                key = pKey;
            } else {
                key = globalContext.insFnKey;
            }
            String sqlCnd = " and " + key + " in (" + globalContext.sqlNewKeys + ")";
            if (!StringUtils.isEmpty(globalContext.sqlNewKeys)) {
                //add #11998 start
                if (tableName.equals("mst_comsv_setting")) {
                    sqlCnd = " and convert_id in (" + globalContext.sqlNewKeys + ")";
                }
                //add #11998 end
                //add 10378_23 start
                if ("pat_coop_detail".equals(tableName)) {
                    //add 11998 start
                    sqlCnd = " and coop_save_no is null";
                    //add 11998 end
                }
                //add 10378_23 end
                String[] commandins = psqlCopyUtils.createCopyCommandUpd(inputFilePath, tableName, columnNameList,
                        facilityCd, sqlCnd, registDbType, 0,true);

                EventLogMessage eventLogMessagetodo1 = eventLoggerUtil.getEventLogMessage("差分コピーコマンド実行：" + commandins[2],
                        facilityCd, "ConvertDbToProductionDbStep");
                eventLoggerUtil.recordLog(facilityCd, eventLogMessagetodo1, LogLevel.INFO);
                if (commandins[2].length() > 8000) {
                    int num = "ord_main".equals(tableName) ? 50 : 200;
                    List<String> result = Arrays.asList(globalContext.sqlNewKeys.split(","));
                    List<List<String>> resList = Utils.sqlSplit(result, num);
                    for (List<String> res : resList) {
                        String fnValueSub = String.join(",", res);
                        String[] commandinsSub = psqlCopyUtils.createCopyCommandUpd(inputFilePath, tableName, columnNameList,
                                facilityCd, " and " + key + " in (" + fnValueSub + ")", registDbType, 0,true);

                        EventLogMessage eventLogMessage = eventLoggerUtil.getEventLogMessage("差分コピーコマンド実行：" + commandinsSub[2],
                                facilityCd, "ConvertDbToProductionDbStep");
                        eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.INFO);
                        this.runCommand(commandinsSub, tableName, facilityCd);
                    }
                } else {
                    this.runCommand(commandins, tableName, facilityCd);
                }
            }

            if (!StringUtils.isEmpty(globalContext.sqlDisNoKeys)) { // sqlDisNoKeys: ord_main差分 新規キー（rst_fn_dialysis_no）
                processOrdMainDiffNewRstFnDialysisNos(inputFilePath, facilityCd, columnNameList);
            }

            //差分新規部分データトリガ処理
            if (tableName.equals("ord_main")) {
                processInsertOrdMainTrigger(currSeq,facilityCd);
            } else if (tableName.equals("mst_machine")) { // mst_machine Insert Triggerの代替処理
                processInsertMstMachineTrigger(currSeq,facilityCd);
            } else if (tableName.equals("mst_bed")) { // mst_bed Insert Triggerの代替処理
                processInsertMstBedTrigger(currSeq,facilityCd);
            }
            // add #12230 差分コンバートにより元に戻ってしまう項目がある limingzhe start
            else if (tableName.equals("mst_comsv_setting")) {
                String comsvSelSql = "SELECT comsv_cd FROM ntss.mst_comsv_setting where facility_cd = ? and comsv_cd > ? order by comsv_cd asc";
                List<Integer> setting_comsv_cd = namedParameterJdbcTemplateNkk5.getJdbcOperations().queryForList(comsvSelSql, new Object[]{facilityCd, currSeq}, Integer.class);
                if (setting_comsv_cd != null && setting_comsv_cd.size() > 0) {
                    List<Integer> insertConvertIds = Arrays.stream(
                                    globalContext.sqlNewKeys.replace("'", "").replace(" ", "").split(",")
                            )
                            .map(Integer::parseInt)
                            .collect(Collectors.toList());
                    List<Integer> allConvertIds = new ArrayList<>();
                    allConvertIds.addAll(updatedConvertIds);
                    allConvertIds.addAll(insertConvertIds);
                    for (int i = 0; i < setting_comsv_cd.size(); i++) {
                        if (allConvertIds.size() <= i) break;
                        String upd_mst_comsv_setting_sql = "update mst_comsv_setting set comsv_cd = ? where facility_cd = ? and convert_id = ?";
                        namedParameterJdbcTemplateConvert.getJdbcOperations().update(upd_mst_comsv_setting_sql, setting_comsv_cd.get(i), facilityCd, allConvertIds.get(i));
                    }
                    globalContext.sqlNewKeys = "";
                }
            }
            // add #12230 差分コンバートにより元に戻ってしまう項目がある limingzhe end
        }
        // add #11399 djy start

        // #8753 旧通信項目がDBに登録されていないこと ADD by Zhoutao START
        else if ("mst_machine_record_control".equals(tableName)) {
            // 旧通信項目を削除する
            String delMstMachineRecordControl = "delete from mst_machine_record_control where facility_cd = ?"
                    + " and machine_record_cd not in (select machine_record_cd from mst_machine_record)";
            // LOG
            EventLogMessage eventLogMessagetodo1 = eventLoggerUtil.getEventLogMessage("差分DELETEコマンド実行：" + delMstMachineRecordControl,
                    facilityCd, "ConvertDbToProductionDbStep");
            eventLoggerUtil.recordLog(facilityCd, eventLogMessagetodo1, LogLevel.INFO);
            namedParameterJdbcTemplateNkk5.getJdbcOperations().update(delMstMachineRecordControl, facilityCd);
        }
        // #8753 ADD by Zhoutao END
        // add #8992-4 pat_event zs start
        // mod zl start
        else if (utils.allDeleteAllInsertList.contains(tableName)) {
            if (globalContext.sqlKeys.isEmpty()) {
                delSql = "";
            }
            String condSql = "";
            condSql = " and " + tableKey + " is null "; // #11998 add
            // add #10739 zc end
            String[] commandUpd = psqlCopyUtils.createCopyCommandUpdDiff(inputFilePath, tableName, ApplicationConst.DbType.CONVERT,
                    registDbType, columnNameList, facilityCd, condSql, delSql, true);

            EventLogMessage eventLogMessage = eventLoggerUtil.getEventLogMessage("差分コピーコマンド実行：" + commandUpd[2],
                    facilityCd, "ConvertDbToProductionDbStep");
            eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.INFO);
            this.runCommand(commandUpd, tableName, facilityCd);
        }
        // mod zl end
        // add #8992-4 pat_event zs end
        // MongoＤＢ更新
        //6886 zc start
        setMongoDate(nextProcessingFile, facilityCd, tableName);
        //6886 zc end
        // 処理完了したファイルを完了フォルダへ移動
        this.moveInputFile(nextProcessingFile);
        EventLogMessage eventLogMessage = eventLoggerUtil.getEventLogMessage("差分コンバートCopyコマンド正常終了" + tableName,
                facilityCd, "ConvertDbToProductionDbStep");
        eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.INFO);
    }

    /**
     * ord_main差分 新規キー（rst_fn_dialysis_no）処理
     */
    private void processOrdMainDiffNewRstFnDialysisNos(String inputFilePath,String facilityCd, List<String> columnNameList) throws Exception {
        GlobalContext globalContext = JobStartEndLIstener.getGlobalContext();
        String tableName = "ord_main";
        String[] commandins2 = psqlCopyUtils.createCopyCommandUpd(inputFilePath, tableName, columnNameList,
                facilityCd, " and rst_fn_dialysis_no in (" + globalContext.sqlDisNoKeys + ")", ApplicationConst.DbType.NKK5, 0,true);

        EventLogMessage eventLogMessagetodo2 = eventLoggerUtil.getEventLogMessage("差分コピーコマンド実行：" + commandins2[2],
                facilityCd, "ConvertDbToProductionDbStep");
        eventLoggerUtil.recordLog(facilityCd, eventLogMessagetodo2, LogLevel.INFO);
        if (commandins2[2].length() > 8000) {
            int num = 50;
            List<String> result = Arrays.asList(globalContext.sqlDisNoKeys.split(","));
            List<List<String>> resList = Utils.sqlSplit(result, num);
            for (List<String> res : resList) {
                String fnValueSub = String.join(",", res);
                String[] commandinsSub2 = psqlCopyUtils.createCopyCommandUpd(inputFilePath, tableName, columnNameList,
                        facilityCd, " and " + globalContext.insFnDisKey + " in (" + fnValueSub + ")", ApplicationConst.DbType.NKK5, 0,true);

                EventLogMessage eventLogMessage = eventLoggerUtil.getEventLogMessage("差分コピーコマンド実行：" + commandinsSub2[2],
                        facilityCd, "ConvertDbToProductionDbStep");
                eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.INFO);
                this.runCommand(commandinsSub2, tableName, facilityCd);
            }
        } else {
            this.runCommand(commandins2, tableName, facilityCd);
        }
    }

    /**
     * ord_main update Triggerの代替処理
     */
    private void processDeleteOrdMainTrigger(String facilityCd) {
        GlobalContext globalContext = JobStartEndLIstener.getGlobalContext();
        String fromDb_table_prefix = environment.getProperty("datasource." + ApplicationConst.DbType.NKK5 + ".table_prefix");
        // mod #10472 delete lsn start
        String del = "DELETE FROM ord_schedule WHERE ord_no IN (:ordNoList) AND facility_cd = :facilityCd";
        Map<String, Object> params = new HashMap<>();
        List<Long> delOrdNoList = Arrays.stream(globalContext.sqlKeys.replace(" ", "").split(","))
                .filter(k -> !k.isEmpty())
                .map(Long::valueOf)
                .collect(Collectors.toList());
        params.put("ordNoList", delOrdNoList);  // List<Long>
        params.put("facilityCd", facilityCd);
        namedParameterJdbcTemplateNkk5.update(del, params);
        //mod #10472 delete lsn end
        //変更されたsqlKeysに基づいてord _scheduleデータ
        // mod #8805 【デグレ】ツール出力時にエラーが検出されていないがエラーメッセージが表示され進まない ZS start
        // mod #10418 SQL注入対策：パラメータバインディング（facility_cdのみ） start
        String update_ord_main_sql = "SELECT facility_cd, ord_no, treat_date, ind_kur_cd, ind_bed_cd, pat_id, treat_week, ind_cond_info, rst_weight_info " +
                "FROM " + fromDb_table_prefix + "ord_main " +
                "WHERE facility_cd = :facilityCd AND ord_no IN (:ordNoList)";
        // mod #10418 SQL注入対策：パラメータバインディング（facility_cdのみ） end
        // mod #8805 【デグレ】ツール出力時にエラーが検出されていないがエラーメッセージが表示され進まない ZS end
        List<OrdMain> ordNoList = namedParameterJdbcTemplateNkk5.query(
                update_ord_main_sql,
                params,
                new BeanPropertyRowMapper<>(OrdMain.class)
        );
        // #8942 DB負荷を低減する為に、一括挿入に処理を修正する Mod by Zhoutao Start
        List<OrdSchedule> osParamList = new LinkedList<>();
        String insertOrdScheduleSQL = "INSERT INTO ord_schedule (facility_cd, ord_no, treat_date, kur_cd, bed_cd, pat_id, is_dummy, up_date, reg_date, treat_week)"
                + "VALUES(:facilityCd, :ordNo, :treatDate, :kurCd, :bedCd, :patId, :isDummy, now(), now(), :treatWeek);";
        for (OrdMain om : ordNoList) {

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

            // add #8805 【デグレ】ツール出力時にエラーが検出されていないがエラーメッセージが表示され進まない ZS start
            List<OrdSchedule> dummyScheduleList = this.insertOrdSchedule(om);
            // add #8805 【デグレ】ツール出力時にエラーが検出されていないがエラーメッセージが表示され進まない ZS end
            if (!CollectionUtils.isNullOrEmpty(dummyScheduleList)) osParamList.addAll(dummyScheduleList);
        }

        // 治療スケジュール一括挿入のParams
        namedParameterJdbcTemplateNkk5.batchUpdate(insertOrdScheduleSQL, SqlParameterSourceUtils.createBatch(osParamList));
        // #8942 DB負荷を低減する為に、一括挿入に処理を修正する Mod by Zhoutao END

        // 9778 差分ord_main登録の場合、mnt_motion_record、項目「ord_no」を更新 start
        String[] ordNumberArray = globalContext.sqlKeys.split(",");
        StringBuilder upOrdSqlBufferTonkk5 = new StringBuilder();
        upOrdSqlBufferTonkk5.append(" WITH ord AS(SELECT DISTINCT ");
        upOrdSqlBufferTonkk5.append(" ord.facility_cd,  ord.ord_no, b.machine_type_cd,b.machine_serial, ord.rst_cond_send_date , ord.rst_return_home_date ");
        upOrdSqlBufferTonkk5.append(" FROM ");
        upOrdSqlBufferTonkk5.append(fromDb_table_prefix);
        upOrdSqlBufferTonkk5.append("ord_main ord  INNER JOIN ");
        upOrdSqlBufferTonkk5.append(fromDb_table_prefix);
        upOrdSqlBufferTonkk5.append(" mst_machine  b on  b.machine_no=ord.rst_machine_no ");
        upOrdSqlBufferTonkk5.append(" WHERE");
        upOrdSqlBufferTonkk5.append("  ord.facility_cd = ? AND rst_dialysis_state='6' and  b.facility_cd = ? AND ord_no in (" + IntStream.range(0, ordNumberArray.length).mapToObj(i -> "?").collect(Collectors.joining(", ")) + ")  )");
        upOrdSqlBufferTonkk5.append(" update ");
        upOrdSqlBufferTonkk5.append(fromDb_table_prefix);
        upOrdSqlBufferTonkk5.append("mnt_motion_record set ord_no = o.ord_no ");
        upOrdSqlBufferTonkk5.append(" from ord o ");
        upOrdSqlBufferTonkk5.append(" where mnt_motion_record.machine_type_cd = o.machine_type_cd ");
        upOrdSqlBufferTonkk5.append(" and  mnt_motion_record.machine_serial = o.machine_serial ");
        upOrdSqlBufferTonkk5.append(" and mnt_motion_record.event_reg_date >=o.rst_cond_send_date ");
        upOrdSqlBufferTonkk5.append(" and mnt_motion_record.event_reg_date <=o.rst_return_home_date ");
        upOrdSqlBufferTonkk5.append(" and mnt_motion_record.facility_cd = o.facility_cd");
        upOrdSqlBufferTonkk5.append(" and mnt_motion_record.data_type = '1'");
        upOrdSqlBufferTonkk5.append(" and mnt_motion_record.ord_no IS NULL");
        upOrdSqlBufferTonkk5.append(" and mnt_motion_record.facility_cd = ?");
        System.err.println("UPDATE mnt_motion_record SQL:" + upOrdSqlBufferTonkk5.toString());
        // 本番DB を更新
        jdbcTemplateNkk5.batchUpdate(upOrdSqlBufferTonkk5.toString(), new BatchPreparedStatementSetter() {
            @Override
            public void setValues(PreparedStatement ps, int i) throws SQLException {
                ps.setString(1, facilityCd);
                ps.setString(2, facilityCd);
                for (int o = 0; o < ordNumberArray.length; o++) {
                    String ord_no = ordNumberArray[o].trim();
                    ps.setInt(o + 3, Integer.parseInt(ord_no));
                }
                ps.setString(3 + ordNumberArray.length, facilityCd);
            }

            @Override
            public int getBatchSize() {
                return 1;
            }
        });
        // 9778 差分ord_main登録の場合、mnt_motion_record、項目「ord_no」を更新 end
        // add #10835 体重計測定記録の一部がFNWからコンバートされていない zkm start
        // 実際作成中の体重測定履歴の空欄項目をord_mianから再設定する
        StringBuilder updOrdWeightScaleToNkk5 = new StringBuilder();
        updOrdWeightScaleToNkk5.append("""
                            WITH ord AS (
                              SELECT DISTINCT
                                ord.facility_cd
                                ,ord.ord_no
                                ,ord.rst_bed_cd
                                ,ord.rst_kur_cd
                                ,ord.rst_kur_name
                                ,ord.rst_machine_no
                                ,ord.rst_machine_name
                                ,ord.rst_treatment_cd
                                ,ord.rst_treatment_name
                                ,ord.rst_device_mode
                                ,ord.rst_accept_date
                                ,ord.rst_return_home_date
                                ,ord.pat_id
                              FROM      
                            """);
        updOrdWeightScaleToNkk5.append("ord_main ord WHERE ord.facility_cd = ? and  ord_no in ("+ IntStream.range(0, ordNumberArray.length) .mapToObj(i -> "?").collect(Collectors.joining(", "))+")) update ");
        updOrdWeightScaleToNkk5.append("""
                        ord_weight_scale
                        set
                          ord_no = o.ord_no
                          ,bed_cd = rst_bed_cd
                          ,kur_cd = rst_kur_cd
                          ,kur_name = rst_kur_name
                          ,machine_no = rst_machine_no
                          ,machine_name = rst_machine_name
                          ,treatment_cd = rst_treatment_cd
                          ,treatment_name = rst_treatment_name
                          ,device_mode = rst_device_mode
                        from ord o
                        where ord_weight_scale.facility_cd = ?
                          and ord_weight_scale.facility_cd = o.facility_cd
                          and ord_weight_scale.pat_id = o.pat_id
                          and ord_weight_scale.measure_date >=o.rst_accept_date
                          and ord_weight_scale.measure_date <=o.rst_return_home_date
                        """);
        jdbcTemplateNkk5.batchUpdate(updOrdWeightScaleToNkk5.toString(), new BatchPreparedStatementSetter() {
            @Override
            public void setValues(PreparedStatement ps, int i) throws SQLException {
                ps.setString(1, facilityCd);
                for (int o = 0; o < ordNumberArray.length; o++) {
                    String ord_no = ordNumberArray[o].trim();
                    ps.setInt(o + 2, Integer.parseInt(ord_no));
                }
                ps.setString(2 + ordNumberArray.length, facilityCd);
            }

            @Override
            public int getBatchSize() {
                return 1;
            }
        });
        // add #10835 体重計測定記録の一部がFNWからコンバートされていない zkm end
    }

    /**
     * 差分新規部分データトリガ処理
     * ord_main update Triggerの代替処理
     */
    private void processInsertOrdMainTrigger(Integer currSeq,String facilityCd) {

        String fromDb_table_prefix = environment.getProperty("datasource." + ApplicationConst.DbType.NKK5 + ".table_prefix");
        //取得したord _mainテーブルの現在の最大シーケンス新規に挿入された新しいデータ番号を取得する
        // mod #8805 【デグレ】ツール出力時にエラーが検出されていないがエラーメッセージが表示され進まない ZS start
        String ord_main_sql = "select facility_cd, ord_no, treat_date, ind_kur_cd, ind_bed_cd, pat_id, treat_week, ind_cond_info, rst_weight_info from " + fromDb_table_prefix + "ord_main"
                + " where facility_cd = ? and ord_no > ?";
        // mod #8805 【デグレ】ツール出力時にエラーが検出されていないがエラーメッセージが表示され進まない ZS end
        List<OrdMain> ordNoList = namedParameterJdbcTemplateNkk5.getJdbcOperations().query(ord_main_sql, new Object[]{facilityCd, currSeq}, new BeanPropertyRowMapper<>(OrdMain.class));

        // #8942 DB負荷を低減する為に、一括挿入に処理を修正する Mod by Zhoutao Start
        List<OrdSchedule> osParamList = new LinkedList<>();
        String insertOrdScheduleSQL = "INSERT INTO ord_schedule (facility_cd, ord_no, treat_date, kur_cd, bed_cd, pat_id, is_dummy, up_date, reg_date, treat_week)"
                + "VALUES(:facilityCd, :ordNo, :treatDate, :kurCd, :bedCd, :patId, :isDummy, now(), now(), :treatWeek);";

        for (OrdMain om : ordNoList) {
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

            // add #8805 【デグレ】ツール出力時にエラーが検出されていないがエラーメッセージが表示され進まない ZS start
            List<OrdSchedule> dummyScheduleList = this.insertOrdSchedule(om);
            // add #8805 【デグレ】ツール出力時にエラーが検出されていないがエラーメッセージが表示され進まない ZS end
            if (!CollectionUtils.isNullOrEmpty(dummyScheduleList)) osParamList.addAll(dummyScheduleList);
        }
        // 治療スケジュール一括挿入のParams
        namedParameterJdbcTemplateNkk5.batchUpdate(insertOrdScheduleSQL, SqlParameterSourceUtils.createBatch(osParamList));
        //  #8942 DB負荷を低減する為に、一括挿入に処理を修正する Mod by Zhoutao Start

        // 9778 差分ord_main登録の場合、mnt_motion_record、項目「ord_no」を更新 start
        StringBuilder upOrdSqlBufferTonkk5 = new StringBuilder();
        upOrdSqlBufferTonkk5.append(" WITH ord AS(SELECT DISTINCT ");
        upOrdSqlBufferTonkk5.append(" ord.facility_cd,  ord.ord_no, b.machine_type_cd,b.machine_serial, ord.rst_cond_send_date , ord.rst_return_home_date ");
        upOrdSqlBufferTonkk5.append(" FROM ");
        upOrdSqlBufferTonkk5.append(fromDb_table_prefix);
        upOrdSqlBufferTonkk5.append("ord_main ord  INNER JOIN ");
        upOrdSqlBufferTonkk5.append(fromDb_table_prefix);
        upOrdSqlBufferTonkk5.append(" mst_machine  b on  b.machine_no=ord.rst_machine_no ");
        upOrdSqlBufferTonkk5.append(" WHERE");
        upOrdSqlBufferTonkk5.append("  ord.facility_cd = ? AND rst_dialysis_state='6' and  b.facility_cd = ? AND ord_no >?");
        upOrdSqlBufferTonkk5.append(") update ");
        upOrdSqlBufferTonkk5.append(fromDb_table_prefix);
        upOrdSqlBufferTonkk5.append("mnt_motion_record set ord_no = o.ord_no ");
        upOrdSqlBufferTonkk5.append(" from ord o ");
        upOrdSqlBufferTonkk5.append(" where mnt_motion_record.machine_type_cd = o.machine_type_cd ");
        upOrdSqlBufferTonkk5.append(" and  mnt_motion_record.machine_serial = o.machine_serial ");
        upOrdSqlBufferTonkk5.append(" and mnt_motion_record.event_reg_date >=o.rst_cond_send_date ");
        upOrdSqlBufferTonkk5.append(" and mnt_motion_record.event_reg_date <=o.rst_return_home_date ");
        upOrdSqlBufferTonkk5.append(" and mnt_motion_record.facility_cd = o.facility_cd");
        upOrdSqlBufferTonkk5.append(" and mnt_motion_record.data_type = '1'");
        upOrdSqlBufferTonkk5.append(" and mnt_motion_record.ord_no IS NULL");
        upOrdSqlBufferTonkk5.append(" and mnt_motion_record.facility_cd = ?");
        System.err.println("UPDATE mnt_motion_record SQL:" + upOrdSqlBufferTonkk5.toString());
        // 本番DB を更新
        Integer IntcurrSeq = currSeq;
        jdbcTemplateNkk5.batchUpdate(upOrdSqlBufferTonkk5.toString(), new BatchPreparedStatementSetter() {
            @Override
            public void setValues(PreparedStatement ps, int i) throws SQLException {
                ps.setString(1, facilityCd);
                ps.setString(2, facilityCd);
                ps.setInt(3, Integer.parseInt(String.valueOf(IntcurrSeq)));
                ps.setString(4, facilityCd);
            }

            @Override
            public int getBatchSize() {
                return 1;
            }
        });
        // 9778 差分ord_main登録の場合、mnt_motion_record、項目「ord_no」を更新 end

        // add #10835 体重計測定記録の一部がFNWからコンバートされていない zkm start
        StringBuilder updOrdWeightScaleToNkk5 = new StringBuilder();
        updOrdWeightScaleToNkk5.append("""
                                WITH ord AS (
                                  SELECT DISTINCT
                                    ord.facility_cd
                                    ,ord.ord_no
                                    ,ord.rst_bed_cd
                                    ,ord.rst_kur_cd
                                    ,ord.rst_kur_name
                                    ,ord.rst_machine_no
                                    ,ord.rst_machine_name
                                    ,ord.rst_treatment_cd
                                    ,ord.rst_treatment_name
                                    ,ord.rst_device_mode
                                    ,ord.rst_accept_date
                                    ,ord.rst_return_home_date
                                    ,ord.pat_id
                                  FROM     ord_main ord WHERE ord.facility_cd = ?  AND ord_no >?) update  
                                """);
        updOrdWeightScaleToNkk5.append("""
                            ord_weight_scale
                            set
                              ord_no = o.ord_no
                              ,bed_cd = rst_bed_cd
                              ,kur_cd = rst_kur_cd
                              ,kur_name = rst_kur_name
                              ,machine_no = rst_machine_no
                              ,machine_name = rst_machine_name
                              ,treatment_cd = rst_treatment_cd
                              ,treatment_name = rst_treatment_name
                              ,device_mode = rst_device_mode
                            from ord o
                            where ord_weight_scale.facility_cd = ?
                              and ord_weight_scale.facility_cd = o.facility_cd
                              and ord_weight_scale.pat_id = o.pat_id
                              and ord_weight_scale.measure_date >=o.rst_accept_date
                              and ord_weight_scale.measure_date <=o.rst_return_home_date
                            """);
        jdbcTemplateNkk5.batchUpdate(updOrdWeightScaleToNkk5.toString(), new BatchPreparedStatementSetter() {
            @Override
            public void setValues(PreparedStatement ps, int i) throws SQLException {
                ps.setString(1, facilityCd);
                ps.setInt(2, Integer.parseInt(String.valueOf(IntcurrSeq)));
                ps.setString(3, facilityCd);
            }

            @Override
            public int getBatchSize() {
                return 1;
            }
        });
        // add #10835 体重計測定記録の一部がFNWからコンバートされていない zkm end
    }

    /**
     * mst_machine Delete Triggerの代替処理
     */
    private void processDeleteMstMachineTrigger(String pKey,String facilityCd) {
        GlobalContext globalContext = JobStartEndLIstener.getGlobalContext();
        if (org.springframework.util.ObjectUtils.isEmpty(globalContext.sqlKeys)) {
            return;
        }

        // utils.sqlKeys を解析
        List<String> keyList = Arrays.stream(globalContext.sqlKeys.replace("'", "").replace(" ", "").split(",")).toList();
        // 動的カラム名 pKey = facility_cd||fn_device_no||fn_class_cd
        // IN(:keys) は NamedParameterJdbcTemplate により自動展開される（?,?,?...）
        String mst_machine_del = "SELECT facility_cd, machine_type_cd, machine_serial, machine_no, machine_name, "
                + "is_disp, is_del, fn_device_no, fn_class_cd "
                + "FROM mst_machine "
                + "WHERE " + pKey + " IN (:keys) "   // 主キーリストでの抽出
                + "AND facility_cd = :facilityCd";    // テナント制御（★必須）

        // SQL パラメータを作成
        Map<String, Object> sqlParams = new HashMap<>();
        sqlParams.put("keys", keyList);             // IN 句に使用するリスト
        sqlParams.put("facilityCd", facilityCd); // テナントコード
        //add #11333 djy start
        List<MstMachine> mstMachineListDb5 = namedParameterJdbcTemplateNkk5.query(mst_machine_del, sqlParams, new BeanPropertyRowMapper<>(MstMachine.class));
        //add #11333 djy end
        List<MstMachine> mstMachineList = namedParameterJdbcTemplateConvert.query(mst_machine_del, sqlParams, new BeanPropertyRowMapper<>(MstMachine.class));
        // mod #9689 コンバート施設で次患者情報か更新されない zs end

        Map<String, List<MstMachine>> MstMedicineMapDb5 = mstMachineListDb5.stream().collect(Collectors.groupingBy(c -> c.getFnDeviceNo() + c.getFnClassCd()));
        //mod #11333 djy end
        for (MstMachine mm : mstMachineList) {
            //add #11333 djy start
            List<MstMachine> mstMachinesDb5 = MstMedicineMapDb5.get(mm.getFnDeviceNo() + mm.getFnClassCd());
            if (mstMachinesDb5 == null || mstMachinesDb5.isEmpty()) {
                continue;
            }
            //add #11333 djy end
            // add #9689 コンバート施設で次患者情報か更新されない zs start
            if ("0".equals(mm.getIsDisp())) {
                // add #9689 コンバート施設で次患者情報か更新されない zs end
                //mnt _を削除machine_stateテーブル関連データ
                // SQLインジェクション対策：文字列連結の代わりにパラメータ化クエリを使用
                String deleteSql = "DELETE FROM mnt_machine_state WHERE facility_cd = ? AND machine_type_cd = ? AND TRIM(machine_serial) = TRIM(?)";
                String updateSql = "UPDATE mst_bed SET machine_no = NULL WHERE machine_no = ? AND facility_cd = ?";

                namedParameterJdbcTemplateNkk5.getJdbcOperations().update(deleteSql,
                        mm.getFacilityCd(),
                        mstMachinesDb5.get(0).getMachineTypeCd(),
                        mstMachinesDb5.get(0).getMachineSerial());
                namedParameterJdbcTemplateNkk5.getJdbcOperations().update(updateSql,
                        mm.getMachineNo(),
                        mm.getFacilityCd());
                //add  end
                //mnt _を削除machine_stateテーブルトリガの論理実行（mnt _ machine _ stateにdeleteトリガはありません）
                // add #9689 コンバート施設で次患者情報か更新されない zs start
            } else if ("1".equals(mm.getIsDisp())) {
                //mod #11333 djy start
                // SQLインジェクション対策：StringBuilder連結の代わりにパラメータ化クエリを使用
                StringBuilder sqlBuilder = new StringBuilder();
                List<Object> params = new ArrayList<>();

                sqlBuilder.append("UPDATE mnt_machine_state SET up_date = now()");

                if (!mm.getMachineTypeCd().equals(mstMachinesDb5.get(0).getMachineTypeCd())) {
                    sqlBuilder.append(", machine_type_cd = ?");
                    params.add(mm.getMachineTypeCd());

                    // SQLインジェクション対策：モデル照会時にパラメータ化クエリを使用
                    String selectModelSql = "SELECT model FROM mst_machine_type WHERE machine_type_cd = ?";
                    List<MstMachineType> modelList = namedParameterJdbcTemplateNkk5.getJdbcOperations().query(
                            selectModelSql,
                            new Object[]{mm.getMachineTypeCd()},
                            new BeanPropertyRowMapper<>(MstMachineType.class));

                    if (modelList.size() == 1) {
                        sqlBuilder.append(", model = ?");
                        params.add(modelList.get(0).getModel());
                    }
                }

                if (!mm.getMachineSerial().equals(mstMachinesDb5.get(0).getMachineSerial())) {
                    sqlBuilder.append(", machine_serial = ?");
                    params.add(mm.getMachineSerial());
                }

                if (!mm.getMachineName().equals(mstMachinesDb5.get(0).getMachineName())) {
                    sqlBuilder.append(", machine_name = ?");
                    params.add(mm.getMachineName());
                }

                if (!params.isEmpty()) {
                    sqlBuilder.append(" WHERE facility_cd = ? AND machine_type_cd = ? AND TRIM(machine_serial) = TRIM(?)");
                    params.add(mstMachinesDb5.get(0).getFacilityCd());
                    params.add(mstMachinesDb5.get(0).getMachineTypeCd());
                    params.add(mstMachinesDb5.get(0).getMachineSerial());

                    namedParameterJdbcTemplateNkk5.getJdbcOperations().update(sqlBuilder.toString(), params.toArray());
                }
                //mod #11333 djy end
            }
            // add #9689 コンバート施設で次患者情報か更新されない zs end
        }
    }

    /**
     * mst_machine Insert Triggerの代替処理
     */
    private void processInsertMstMachineTrigger(Integer currSeq,String facilityCd) {

        String fromDb_table_prefix = environment.getProperty("datasource." + ApplicationConst.DbType.NKK5 + ".table_prefix");
        String mst_machine_sql = "select facility_cd, machine_type_cd, machine_serial, machine_no, machine_name, is_del, is_disp, reg_date, up_date from " + fromDb_table_prefix + "mst_machine"
                + " where facility_cd = ? and  is_disp='1' and  machine_no > ?";
        List<MstMachine> MstMachineList2 = namedParameterJdbcTemplateNkk5.getJdbcOperations().query(mst_machine_sql, new Object[]{facilityCd, currSeq}, new BeanPropertyRowMapper<>(MstMachine.class));
        for (MstMachine om : MstMachineList2) {
            //新規mst _machineデータはmnt _machine_stateテーブル
            //if ("0".equals(om.getIsDel()) && "1".equals(om.getIsDisp())) {
            String s = "SELECT model FROM mst_machine_type WHERE machine_type_cd = ?";
            List<MstMachineType> modelList = namedParameterJdbcTemplateNkk5.getJdbcOperations().query(s, new Object[]{om.getMachineTypeCd()}, new BeanPropertyRowMapper<>(MstMachineType.class));
            String model = null;
            if (modelList.size() == 1) {
                model = modelList.get(0).getModel();
            }
            String b = "SELECT bed_cd, bed_name FROM mst_bed WHERE machine_no = ?";
            //Map<String, Object> bedMap = machineJdbcTemplate.getJdbcOperations().queryForMap(b);
            List<MstBed> bedList = namedParameterJdbcTemplateNkk5.getJdbcOperations().query(b, new Object[]{om.getMachineNo()}, new BeanPropertyRowMapper<>(MstBed.class));
            Long bed_cd = null;
            String bed_name = null;
            if (bedList.size() == 1) {
                MstBed bedMap = bedList.get(0);
                bed_cd = bedMap.getBedCd();
                bed_name = bedMap.getBedName();
            }
            String sql = "INSERT INTO mnt_machine_state( facility_cd, machine_type_cd, machine_serial, model, machine_name, bed_cd, bed_name, reg_date, up_date )" +
                    " VALUES(?, ?, ?, ?, ?, ?, ?, now(), now())";
            // mod #10153,#10191,#10249 djy start
            namedParameterJdbcTemplateNkk5.getJdbcOperations().update(sql, om.getFacilityCd(), om.getMachineTypeCd(), om.getMachineSerial(), model, om.getMachineName(), bed_cd, bed_name);
            // mod #10153,#10191,#10249 djy end
        }
    }


    /**
     * mst_bed Insert Triggerの代替処理
     */
    private void processInsertMstBedTrigger(Integer currSeq,String facilityCd) {

        String fromDb_table_prefix = environment.getProperty("datasource." + ApplicationConst.DbType.NKK5 + ".table_prefix");
        String mst_bed_sql = "select bed_cd, bed_name, is_disp, is_del, machine_no from " + fromDb_table_prefix + "mst_bed"
                + " where facility_cd = ? and  is_disp='1' and bed_cd > ?";
        List<MstBed> newbedList = namedParameterJdbcTemplateNkk5.getJdbcOperations().query(mst_bed_sql, new Object[]{facilityCd, currSeq}, new BeanPropertyRowMapper<>(MstBed.class));
        for (MstBed mb : newbedList) {
            //machine _noクエリmst _machineデータ
            String get_mst_machine = "SELECT facility_cd, machine_type_cd, machine_serial FROM mst_machine WHERE machine_no = ?";
            List<MstMachine> MstMachineList2 = namedParameterJdbcTemplateNkk5.getJdbcOperations().query(get_mst_machine, new Object[]{mb.getMachineNo()}, new BeanPropertyRowMapper<>(MstMachine.class));
            String facility_cd = null;
            String machine_type_cd = null;
            String machine_serial = null;
            if (MstMachineList2.size() == 1) {
                MstMachine modelMap = MstMachineList2.get(0);
                facility_cd = String.valueOf(modelMap.getFacilityCd());
                machine_type_cd = String.valueOf(modelMap.getMachineTypeCd());
                machine_serial = String.valueOf(modelMap.getMachineSerial());
                String update_mnt_machine_state = "UPDATE mnt_machine_state SET bed_cd = :bed_cd, bed_name = :bed_name WHERE facility_cd = :facility_cd"
                        + " AND machine_type_cd = :machine_type_cd AND machine_serial = :machine_serial;";
                // mod #10153,#10191,#10249 djy end
                MapSqlParameterSource parameters = new MapSqlParameterSource()
                        .addValue("bed_cd", mb.getBedCd())
                        .addValue("bed_name", mb.getBedName())
                        .addValue("machine_type_cd", machine_type_cd)
                        .addValue("machine_serial", machine_serial)
                        .addValue("facility_cd", facility_cd);
                namedParameterJdbcTemplateNkk5.update(update_mnt_machine_state, parameters);
            }
        }
    }

    /**
     * mst_bed update Triggerの代替処理
     */
    private void processUpdateMstBedTrigger(String facilityCd) {
        GlobalContext globalContext = JobStartEndLIstener.getGlobalContext();
        String fromDb_table_prefix = environment.getProperty("datasource." + ApplicationConst.DbType.NKK5 + ".table_prefix");
        // SQL Injection protection: parameterize IN clause
        List<Integer> keyList = Arrays.stream(globalContext.sqlKeys.replace("'", "").replace(" ", "").split(","))
                .filter(k -> !k.isEmpty())
                .map(Integer::valueOf)
                .collect(Collectors.toList());
        // SQL（変数名でパラメータ化）
        String mst_bed_sql =
                "SELECT bed_cd, bed_name, is_disp, is_del, machine_no " +
                        "FROM " + fromDb_table_prefix + "mst_bed" +
                        " WHERE facility_cd = :facilityCd " +
                        "   AND is_disp = '1' " +
                        "   AND bed_cd IN (:keys)";
        Map<String, Object> params = new HashMap<>();
        params.put("facilityCd", facilityCd);
        params.put("keys", keyList);
        List<MstBed> newbedList = namedParameterJdbcTemplateNkk5.query(mst_bed_sql, params, new BeanPropertyRowMapper<>(MstBed.class));
        for (MstBed mb : newbedList) {
            //machine _noクエリmst _machineデータ
            // mod #10418 SQL注入対策：パラメータバインディング start
            String get_mst_machine = "SELECT facility_cd, machine_type_cd, machine_serial FROM mst_machine WHERE machine_no = ?";
            List<MstMachine> MstMachineList2 = namedParameterJdbcTemplateNkk5.getJdbcOperations().query(get_mst_machine, new Object[]{mb.getMachineNo()}, new BeanPropertyRowMapper<>(MstMachine.class));
            // mod #10418 SQL注入対策：パラメータバインディング end
            String facility_cd = null;
            String machine_type_cd = null;
            String machine_serial = null;
            if (MstMachineList2.size() == 1) {
                MstMachine modelMap = MstMachineList2.get(0);
                facility_cd = String.valueOf(modelMap.getFacilityCd());
                machine_type_cd = String.valueOf(modelMap.getMachineTypeCd());
                machine_serial = String.valueOf(modelMap.getMachineSerial());
                String update_mnt_machine_state = "UPDATE mnt_machine_state SET bed_cd = :bed_cd, bed_name = :bed_name WHERE facility_cd = :facility_cd"
                        + " AND machine_type_cd = :machine_type_cd AND machine_serial = :machine_serial;";
                // mod #10153,#10191,#10249 djy end
                MapSqlParameterSource parameters = new MapSqlParameterSource()
                        .addValue("bed_cd", mb.getBedCd())
                        .addValue("bed_name", mb.getBedName())
                        .addValue("machine_type_cd", machine_type_cd)
                        .addValue("machine_serial", machine_serial)
                        .addValue("facility_cd", facility_cd);
                namedParameterJdbcTemplateNkk5.update(update_mnt_machine_state, parameters);
            }
            // mod #10153,#10191,#10249 djy start

        }
        // mod #10418 SQL注入対策：パラメータバインディング start
        String mst_machine_sql = "select facility_cd, machine_type_cd, machine_serial from " + fromDb_table_prefix + "mst_machine"
                + " where facility_cd = ?  and is_disp='1' and machine_no not in (SELECT machine_no FROM mst_bed WHERE facility_cd = ? AND machine_no IS NOT NULL )";
        List<MstMachine> upMachineNo = namedParameterJdbcTemplateNkk5.getJdbcOperations().query(mst_machine_sql, new Object[]{facilityCd, facilityCd}, new BeanPropertyRowMapper<>(MstMachine.class));
        // mod #10418 SQL注入対策：パラメータバインディング end
        if (!upMachineNo.isEmpty()) {
            StringBuilder sqlString = new StringBuilder();
            List<Object> updateParams = new ArrayList<>();
            updateParams.add(facilityCd); // for WHERE facility_cd = ?
            for (MstMachine mn : upMachineNo) {
                // mod #10153,#10191,#10249 djy start
                //sqlString.append(" (machine_type_cd='"+ mn.getMachineTypeCd() +"' AND machine_serial = '"+ mn.getMachineSerial() +"')  OR");
                sqlString.append(" (machine_type_cd=? AND machine_serial = ?) OR");
                updateParams.add(mn.getMachineTypeCd());
                updateParams.add(mn.getMachineSerial());
                // mod #10153,#10191,#10249 djy end
            }
            String sWhere = sqlString.substring(0, sqlString.toString().lastIndexOf("OR"));
            String update_mnt_machine_state = "UPDATE mnt_machine_state SET bed_cd = null, bed_name = null WHERE facility_cd = ?" +
                    " AND " + sWhere;
            namedParameterJdbcTemplateNkk5.getJdbcOperations().update(update_mnt_machine_state, updateParams.toArray());
        }
    }


    /**
     * copyのsql文が最大長を超え場合、部分コピー
     *
     * @param command    　command文
     * @param tableName  　テーブル名
     * @param facilityCd 　本番の施設コード
     * @return
     */
    public void runCommand(String[] command, String tableName, String facilityCd) throws Exception {
        Runtime runtime = Runtime.getRuntime();
        EventLogMessage eventLogMessagetodo1 = eventLoggerUtil.getEventLogMessage("コピーコマンド実行：" + command[2],
                facilityCd, "ConvertDbToProductionDbStep");
        eventLoggerUtil.recordLog(facilityCd, eventLogMessagetodo1, LogLevel.INFO);
        Process p = runtime.exec(command);
        // 子プロセスの標準出力および標準エラー出力を入力するスレッドを起動
        StreamThread it = new StreamThread(p.getInputStream());
        StreamThread et = new StreamThread(p.getErrorStream());
        it.start();
        et.start();
        int returnCode = p.waitFor(); // 子プロセスの終了を待つ
        // スレッドの終了を待つ
        it.join();
        et.join();
        // ストリームを一応明示的にクローズしておく
        p.getInputStream().close();
        p.getOutputStream().close();
        p.getErrorStream().close();
        p.destroy(); // 子プロセスを明示的に終了
        if (returnCode != 0) {
            String errorMsg = "Copyコマンド異常終了\n" + et.getOutputString();
            EventLogMessage eventLogMessageErr = eventLoggerUtil.getEventLogMessage(errorMsg,
                    facilityCd, "ConvertDbToProductionDbStep");
            eventLoggerUtil.recordLog(facilityCd, eventLogMessageErr, LogLevel.ERROR);
            throw new RuntimeException(errorMsg);
        } else {
            EventLogMessage eventLogMessageErr = eventLoggerUtil.getEventLogMessage("コピーコマンド実行終わる：" + it.getOutputString(),
                    facilityCd, "ConvertDbToProductionDbStep");
            eventLoggerUtil.recordLog(facilityCd, eventLogMessageErr, LogLevel.INFO);
        }
    }

    /**
     * テンポラリ・テーブルから本番ＤＢ更新
     *
     * @param inputFilePath 入力ファイル
     * @return なし
     */
    private void moveInputFile(String inputFilePath) {
        FileVisitor fv = new FileVisitor();
        boolean checkState = fv.readFileLineAndCheckAnnotation(inputFilePath);
        if (!checkState) {
            try {
                File fileDbStep = new File(inputFilePath);
                fileDbStep.delete();

            } catch (Exception e) {
                throw new RuntimeException(e);
            }
        }

    }

    // add #11268 limingyang start
    public <T> List<T> getResList(String facilityCd, Object item, Class<T> clazz) {

        ObjectMapper objectMapper = new ObjectMapper();
        List<T> resInfo = null;
        if (item != null) {
            try {
                Object resInfoObj = item;
                if (resInfoObj instanceof PGobject pgObject) {
                    String patMemoInfoStr = pgObject.getValue();
                    resInfo = objectMapper.readValue(patMemoInfoStr, objectMapper.getTypeFactory().constructCollectionType(List.class, clazz));
                } else if (resInfoObj instanceof String patMemoInfoStr) {
                    resInfo = objectMapper.readValue(patMemoInfoStr, objectMapper.getTypeFactory().constructCollectionType(List.class, clazz));
                } else {
                    throw new IllegalArgumentException("Unsupported type for item: " + resInfoObj.getClass());
                }
            } catch (Exception e) {
                eventLoggerUtil.recordLog(facilityCd,
                        eventLoggerUtil.getEventLogMessage("「item」:" + item + ",「ERROR」:" + EventLoggerUtil.excetionStackTraceToString(e),
                                facilityCd, "mongo List<T> convert error"), LogLevel.ERROR);
            }
        }
        return resInfo;
    }

    public <T> T getResObject(String facilityCd, Object item, Class<T> clazz) {

        ObjectMapper objectMapper = new ObjectMapper();
        T resInfo = null;
        if (item != null) {
            try {
                Object resInfoObj = item;
                if (resInfoObj instanceof PGobject pgObject) {
                    String patMemoInfoStr = pgObject.getValue();
                    resInfo = objectMapper.readValue(patMemoInfoStr, clazz);
                } else if (resInfoObj instanceof String patMemoInfoStr) {
                    resInfo = objectMapper.readValue(patMemoInfoStr, clazz);
                } else {
                    throw new IllegalArgumentException("Unsupported type for item: " + resInfoObj.getClass());
                }
            } catch (Exception e) {
                eventLoggerUtil.recordLog(facilityCd,
                        eventLoggerUtil.getEventLogMessage("「item」:" + item + ",「ERROR」:" + EventLoggerUtil.excetionStackTraceToString(e),
                                facilityCd, "mongo T convert error"), LogLevel.ERROR);
            }
        }
        return resInfo;
    }
    // add #11268 limingyang end

    /**
     * MongoＤＢ更新
     *
     * @param inputFilePath 入力ファイル
     * @param facilityCd    本番の施設コード
     * @param tableName     テープル
     * @return なし
     */
    private void setMongoDate(String inputFilePath, String facilityCd, String tableName) {

        if (Set.of("pat_personal_main_history",
                "pat_insurance_history",
                "pat_main_history",
                "pat_unique_history",
                "pat_group_detail_history").contains(tableName)) {
            List<PatGroupDetailHistoryEntity> patgroupdetailhistorylist = new ArrayList<>();
            List<PatUniqueHistoryEntity> patUniqueHistoryEntityList = new ArrayList<>();
            String sql = "select * from " + tableName + " where facility_cd = ?";
            // mod #10661 limingyang start
            if (tableName.equals("pat_insurance_history")) {
                updatePatInsuranceHistory(facilityCd);
            }
            // mod #10661 limingyang end
            List<Map<String, Object>> rs = jdbcTemplateConvert.queryForList(sql, facilityCd);
            Date date = new Date();

            // add #10534 pat_main_history, pat_unique_history, pat_personal_main_historyのcollectionにlatest_flagを追加する。 zkm start
            Map<String, String> maxUpdateMap = new HashMap<>();
            if (latestFlagTableList.contains(tableName)) {
                List<String> patIds = rs.stream().map(data -> data.get("pat_id")).filter(Objects::nonNull).distinct().map(Object::toString).toList();
                // 指定患者id範囲の履歴データを全て「latest_flag=off」を設定する
                Query query = new Query();
                Update update = new Update();
                query
                        .addCriteria(Criteria.where("pat_id").in(patIds))
                        .addCriteria(Criteria.where("facility_cd").is(facilityCd));
                update.set(ApplicationConst.LatestFlag.LATEST_FLAG, ApplicationConst.LatestFlag.OFF);
                if ("pat_personal_main_history".equals(tableName)) {
                    mongoTemplate.updateMulti(query, update, PatPersonalMainHistoryEntity.class);
                } else if ("pat_main_history".equals(tableName)) {
                    mongoTemplate.updateMulti(query, update, PatMainHistoryEntity.class);
                } else {
                    mongoTemplate.updateMulti(query, update, PatUniqueHistoryEntity.class);
                }

                Map<Object, List<Map<String, Object>>> patIdGroups = rs.stream().filter(r -> null != r.get("pat_id") && null != r.get("up_date")).collect(Collectors.groupingBy(r -> r.get("pat_id")));

                patIdGroups.forEach((key, values) -> {
                    values.sort((v1, v2) -> v2.get("up_date").toString().compareTo(v1.get("up_date").toString()));
                    maxUpdateMap.put(key.toString(), values.get(0).get("up_date").toString());
                });
            }
            // add #10534 pat_main_history, pat_unique_history, pat_personal_main_historyのcollectionにlatest_flagを追加する。 zkm end

            rs.forEach(r -> {
                Map<String, Object> item = r;
                if (tableName.equals("pat_personal_main_history")) {
                    PatPersonalMainHistoryEntity patpersonalmainhistory = new PatPersonalMainHistoryEntity();
                    patpersonalmainhistory.setPatId(parseStringOrNull(item,"pat_id"));
                    patpersonalmainhistory.setFnPatId(parseStringOrNull(item,"fn_pat_id"));
                    patpersonalmainhistory.setHospPatId(parseStringOrNull(item,"hosp_pat_id"));
                    patpersonalmainhistory.setNkkPatId(parseStringOrNull(item,"nkk_pat_id"));
                    patpersonalmainhistory.setFacilityCd(parseStringOrNull(item,"facility_cd"));
                    patpersonalmainhistory.setFacilityName(parseStringOrNull(item,"facility_name"));
                    patpersonalmainhistory.setPatLastName(parseStringOrNull(item,"pat_last_name"));
                    patpersonalmainhistory.setPatFirstName(parseStringOrNull(item,"pat_first_name"));
                    patpersonalmainhistory.setPatLastNameKana(parseStringOrNull(item,"pat_last_name_kana"));
                    patpersonalmainhistory.setPatFirstNameKana(parseStringOrNull(item,"pat_first_name_kana"));
                    patpersonalmainhistory.setPatLastNameAlpha(parseStringOrNull(item,"pat_last_name_alpha"));
                    patpersonalmainhistory.setPatFirstNameAlpha(parseStringOrNull(item,"pat_first_name_alpha"));
                    patpersonalmainhistory.setPatBirthName(parseStringOrNull(item,"pat_birth_name"));
                    patpersonalmainhistory.setPatBirthNameKana(parseStringOrNull(item,"pat_birth_name_kana"));
                    patpersonalmainhistory.setPatBirthNameAlpha(parseStringOrNull(item,"pat_birth_name_alpha"));
                    patpersonalmainhistory.setPatBirthday(parseStringOrNull(item,"pat_birthday"));
                    patpersonalmainhistory.setPatSex(parseStringOrNull(item,"pat_sex"));
                    patpersonalmainhistory.setNationality(parseStringOrNull(item,"nationality"));
                    patpersonalmainhistory.setPatBloodTypeAbo(parseStringOrNull(item,"pat_blood_type_abo"));
                    patpersonalmainhistory.setPatBloodTypeRh(parseStringOrNull(item,"pat_blood_type_rh"));
                    patpersonalmainhistory.setPatBloodTypeSerovar(parseStringOrNull(item,"pat_blood_type_serovar"));
                    patpersonalmainhistory.setInOutClass(parseStringOrNull(item,"in_out_class"));
                    patpersonalmainhistory.setIsDie(parseStringOrNull(item,"is_die"));
                    patpersonalmainhistory.setDieCd(parseStringOrNull(item,"die_cd"));
                    patpersonalmainhistory.setDieName(parseStringOrNull(item,"die_name"));
                    patpersonalmainhistory.setDieDate(parseStringOrNull(item,"die_date"));
                    // mod #11268 limingyang start
                    List<DialDiffComInfo> dialDiffComInfo = this.getResList(facilityCd, item.get("dial_diff_com_info"), DialDiffComInfo.class);
                    patpersonalmainhistory.setDialDiffComInfo(dialDiffComInfo);
                    List<OtherContactInfo> otherContactInfo = this.getResList(facilityCd, item.get("other_contact_info"), OtherContactInfo.class);
                    patpersonalmainhistory.setOtherContactInfo(otherContactInfo);
                    // mod #11268 limingyang end
                    patpersonalmainhistory.setSeverityCd(parseStringOrNull(item,"severity_cd"));
                    patpersonalmainhistory.setSeverityName(parseStringOrNull(item,"severity_name"));
                    patpersonalmainhistory.setTransportCd(parseStringOrNull(item,"transport_cd"));
                    patpersonalmainhistory.setTransportName(parseStringOrNull(item,"transport_name"));
                    patpersonalmainhistory.setPatContactInfo(parseStringOrNull(item,"pat_contact_info"));
                    patpersonalmainhistory.setVendorContactInfo(parseStringOrNull(item,"vendor_contact_info"));
                    patpersonalmainhistory.setInsuranceInfo(parseStringOrNull(item,"insurance_info"));
                    patpersonalmainhistory.setIsDel(parseStringOrNull(item,"is_del"));
                    patpersonalmainhistory.setUpDate(parseStringOrNull(item,"up_date"));
                    patpersonalmainhistory.setRegDate(parseStringOrNull(item,"reg_date"));
                    patpersonalmainhistory.setPrimaryDiseaseCd(parseStringOrNull(item,"primary_disease_cd"));
                    patpersonalmainhistory.setPrimaryDiseaseName(parseStringOrNull(item,"primary_disease_name"));
                    patpersonalmainhistory.setRemoteMonitorService(parseStringOrNull(item,"remote_monitor_service"));
                    patpersonalmainhistory.setRemoteMonitorUserId(parseStringOrNull(item,"remote_monitor_user_id"));
                    patpersonalmainhistory.setRemoteMonitorUserPw(parseStringOrNull(item,"remote_monitor_user_pw"));
                    patpersonalmainhistory.setOldUpDatePersonal(parseStringOrNull(item,"old_up_date_personal"));
                    patpersonalmainhistory.setInsDate(date);
                    // add #10534 pat_main_history, pat_unique_history, pat_personal_main_historyのcollectionにlatest_flagを追加する。 zkm start
                    if (!ObjectUtils.isEmpty(patpersonalmainhistory.getPatId()) && maxUpdateMap.containsKey(patpersonalmainhistory.getPatId())
                            && !ObjectUtils.isEmpty(patpersonalmainhistory.getUpDate()) && patpersonalmainhistory.getUpDate().equals(maxUpdateMap.get(patpersonalmainhistory.getPatId()))
                    ) {
                        patpersonalmainhistory.setLatestFlag(ApplicationConst.LatestFlag.ON);
                        maxUpdateMap.remove(patpersonalmainhistory.getPatId());
                    } else {
                        patpersonalmainhistory.setLatestFlag(ApplicationConst.LatestFlag.OFF);
                    }
                    // add #10534 pat_main_history, pat_unique_history, pat_personal_main_historyのcollectionにlatest_flagを追加する。 zkm end
                    try {
                        mongoTemplate.insert(patpersonalmainhistory);
                    } catch (Exception er) {
                        //ログ
                        EventLogMessage eventLogMessage9 = eventLoggerUtil.getEventLogMessage("「SQL文ミス」" + item.toString(),
                                facilityCd, "JdbcBatchSqlItemWriter.write(final List<? extends T> items)");
                        eventLoggerUtil.recordLog(facilityCd, eventLogMessage9, LogLevel.DEBUG);
                    }
                } else if (tableName.equals("pat_insurance_history")) {
                    PatInsuranceHistoryEntity patinsurancehistory = new PatInsuranceHistoryEntity();
                    patinsurancehistory.setInsuranceCd(parseStringOrNull(item,"insurance_cd"));
                    patinsurancehistory.setPatId(parseStringOrNull(item,"pat_id"));
                    patinsurancehistory.setFacilityCd(parseStringOrNull(item,"facility_cd"));
                    patinsurancehistory.setCtlNo(parseStringOrNull(item,"ctl_no"));
                    patinsurancehistory.setFnPatId(parseStringOrNull(item,"fn_pat_id"));
                    patinsurancehistory.setInsuClass(parseStringOrNull(item,"insu_class"));
                    patinsurancehistory.setInsuName(parseStringOrNull(item,"insu_name"));
                    patinsurancehistory.setInsuNameShort(parseStringOrNull(item,"insu_name_short"));
                    patinsurancehistory.setInsuInfo(parseStringOrNull(item,"insu_info"));
                    patinsurancehistory.setInsuPubInfo(parseStringOrNull(item,"insu_pub_info"));
                    patinsurancehistory.setInsuSetInfo(parseStringOrNull(item,"insu_set_info"));
                    patinsurancehistory.setInsuSelfInfo(parseStringOrNull(item,"insu_self_info"));
                    patinsurancehistory.setIsSelected(parseStringOrNull(item,"is_selected"));
                    patinsurancehistory.setIsDisp(parseStringOrNull(item,"is_disp"));
                    patinsurancehistory.setIsDel(parseStringOrNull(item,"is_del"));
                    patinsurancehistory.setCoopCode(parseStringOrNull(item,"coop_code"));
                    patinsurancehistory.setIsCoop(parseStringOrNull(item,"is_coop"));
                    patinsurancehistory.setRegDate(parseStringOrNull(item,"reg_date"));
                    patinsurancehistory.setUpDate(parseStringOrNull(item,"up_date"));
                    patinsurancehistory.setStartDate(parseStringOrNull(item,"start_date"));
                    patinsurancehistory.setEndDate(parseStringOrNull(item,"end_date"));
                    patinsurancehistory.setCheckDate(parseStringOrNull(item,"check_date"));
                    patinsurancehistory.setOldUpDate(parseStringOrNull(item,"old_up_date"));
                    patinsurancehistory.setMemo1(parseStringOrNull(item,"memo1"));
                    patinsurancehistory.setMemo2(parseStringOrNull(item,"memo2"));
                    patinsurancehistory.setFnCtlNo(parseStringOrNull(item,"fn_ctl_no"));
                    patinsurancehistory.setInsDate(date);
                    try {
                        mongoTemplate.insert(patinsurancehistory);
                    } catch (Exception er) {
                        //ログ
                        EventLogMessage eventLogMessage9 = eventLoggerUtil.getEventLogMessage("「SQL文ミス」" + item.toString(),
                                facilityCd, "JdbcBatchSqlItemWriter.write(final List<? extends T> items)");
                        eventLoggerUtil.recordLog(facilityCd, eventLogMessage9, LogLevel.DEBUG);
                    }
                } else if (tableName.equals("pat_main_history")) {
                    PatMainHistoryEntity patmainhistory = new PatMainHistoryEntity();
                    patmainhistory.setPatId(parseStringOrNull(item,"pat_id"));
                    patmainhistory.setFacilityCd(parseStringOrNull(item,"facility_cd"));
                    patmainhistory.setFacilityName(parseStringOrNull(item,"facility_name"));
                    patmainhistory.setIsSame(parseStringOrNull(item,"is_same"));
                    patmainhistory.setIsImplant(parseStringOrNull(item,"is_implant"));
                    patmainhistory.setIsInfect(parseStringOrNull(item,"is_infect"));
                    patmainhistory.setIsDiabetes(parseStringOrNull(item,"is_diabetes"));
                    patmainhistory.setIsBloodSugerExam(parseStringOrNull(item,"is_blood_suger_exam"));
                    patmainhistory.setInOutCurrentState(parseStringOrNull(item,"in_out_current_state"));
                    patmainhistory.setInOutPlanState(parseStringOrNull(item,"in_out_plan_state"));
                    patmainhistory.setInOutPlanDate(item.get("in_out_plan_date") != null ? (Date)item.get("in_out_plan_date")  : null);
                    // mod #11268 limingyang start
                    List<PatMemoInfo> patMemoInfo = this.getResList(facilityCd, item.get("pat_memo_info"), PatMemoInfo.class);
                    patmainhistory.setPatMemoInfo(patMemoInfo);
                    List<AdditionInfo> additionInfo = this.getResList(facilityCd, item.get("addition_info"), AdditionInfo.class);
                    patmainhistory.setAdditionInfo(additionInfo);
                    List<ChargeStaffInfo> chargeStaffInfo = this.getResList(facilityCd, item.get("charge_staff_info"), ChargeStaffInfo.class);
                    patmainhistory.setChargeStaffInfo(chargeStaffInfo);
                    List<PatGroupInfo> patGroupInfo = this.getResList(facilityCd, item.get("pat_group_info"), PatGroupInfo.class);
                    patmainhistory.setPatGroupInfo(patGroupInfo);
                    List<TabooAllergyInfo> tabooAllergyInfo = this.getResList(facilityCd, item.get("taboo_allergy_info"), TabooAllergyInfo.class);
                    patmainhistory.setTabooAllergyInfo(tabooAllergyInfo);
                    List<InfectInfo> infectInfo = this.getResList(facilityCd, item.get("infect_info"), InfectInfo.class);
                    patmainhistory.setInfectInfo(infectInfo);
                    List<ImplantInfo> implantInfo = this.getResList(facilityCd, item.get("implant_info"), ImplantInfo.class);
                    patmainhistory.setImplantInfo(implantInfo);
                    MedicalCareInfo medicalCareInfo = this.getResObject(facilityCd, item.get("medical_care_info"), MedicalCareInfo.class);
                    patmainhistory.setMedicalCareInfo(medicalCareInfo);
                    // mod #11268 limingyang end
                    patmainhistory.setTareInfo(parseStringOrNull(item,"tare_info"));
                    patmainhistory.setOffWaterInfo(parseStringOrNull(item,"off_water_info"));
                    patmainhistory.setDeviceSetInfo(parseStringOrNull(item,"device_set_info"));
                    patmainhistory.setAcceptanceStatusInfo(parseStringOrNull(item,"acceptance_status_info"));
                    patmainhistory.setIsDel(parseStringOrNull(item,"is_del"));
                    patmainhistory.setUpDate(parseStringOrNull(item,"up_date"));
                    patmainhistory.setRegDate(parseStringOrNull(item,"reg_date"));
                    patmainhistory.setIsWheelChair(parseStringOrNull(item,"is_wheel_chair"));
                    patmainhistory.setSchExtEndDate(parseStringOrNull(item,"sch_ext_end_date"));
                    patmainhistory.setSchExtStatus(parseStringOrNull(item,"sch_ext_status"));
                    patmainhistory.setCardIdm(parseStringOrNull(item,"card_idm"));
                    patmainhistory.setOldUpDate(parseStringOrNull(item,"old_up_date"));
                    patmainhistory.setHostNotificationInfo(parseStringOrNull(item,"host_notification_info"));
                    // add #10735 djy start
                    patmainhistory.setWheelChairCd(item.get("wheel_chair_cd") != null ? Long.parseLong(item.get("wheel_chair_cd").toString()) : null);
                    patmainhistory.setWheelChairName(parseStringOrNull(item,"wheel_chair_name"));
                    patmainhistory.setWheelChairWeight(item.get("wheel_chair_weight") != null ? Integer.parseInt(item.get("wheel_chair_weight").toString()) : null);
                    patmainhistory.setDialysisUnderlyingDisease(parseStringOrNull(item,"dialysis_underlying_disease"));
                    // add #10735 djy end
                    patmainhistory.setInsDate(date);
                    // add #10534 pat_main_history, pat_unique_history, pat_personal_main_historyのcollectionにlatest_flagを追加する。 zkm start
                    if (!ObjectUtils.isEmpty(patmainhistory.getPatId()) && maxUpdateMap.containsKey(patmainhistory.getPatId())
                            && !ObjectUtils.isEmpty(patmainhistory.getUpDate()) && patmainhistory.getUpDate().equals(maxUpdateMap.get(patmainhistory.getPatId()))
                    ) {
                        patmainhistory.setLatestFlag(ApplicationConst.LatestFlag.ON);
                        maxUpdateMap.remove(patmainhistory.getPatId());
                    } else {
                        patmainhistory.setLatestFlag(ApplicationConst.LatestFlag.OFF);
                    }
                    // add #10534 pat_main_history, pat_unique_history, pat_personal_main_historyのcollectionにlatest_flagを追加する。 zkm end
                    try {
                        mongoTemplate.insert(patmainhistory);
                    } catch (Exception er) {
                        //ログ
                        EventLogMessage eventLogMessage9 = eventLoggerUtil.getEventLogMessage("「SQL文ミス」" + item.toString(),
                                facilityCd, "JdbcBatchSqlItemWriter.write(final List<? extends T> items)");
                        eventLoggerUtil.recordLog(facilityCd, eventLogMessage9, LogLevel.DEBUG);
                    }
                } else if (tableName.equals("pat_group_detail_history")) {
                    PatGroupDetailHistoryEntity patgroupdetailhistory = new PatGroupDetailHistoryEntity();
                    patgroupdetailhistory.setPatId(parseStringOrNull(item,"pat_id"));
                    patgroupdetailhistory.setFacilityCd(parseStringOrNull(item,"facility_cd"));
                    patgroupdetailhistory.setUpDate(parseStringOrNull(item,"up_date"));
                    patgroupdetailhistory.setRegDate(parseStringOrNull(item,"reg_date"));
                    patgroupdetailhistory.setInsDate(date);
                    patgroupdetailhistory.setPatGroupCd(parseStringOrNull(item,"pat_group_cd"));
                    // add #10735 djy start
                    patgroupdetailhistory.setPatGroupName(parseStringOrNull(item,"pat_group_name"));
                    // add #10735 djy end
                    patgroupdetailhistorylist.add(patgroupdetailhistory);
                    try {
                        mongoTemplate.insert(patgroupdetailhistory);
                    } catch (Exception er) {
                        //ログ
                        EventLogMessage eventLogMessage9 = eventLoggerUtil.getEventLogMessage("「SQL文ミス」" + item.toString(),
                                facilityCd, "JdbcBatchSqlItemWriter.write(final List<? extends T> items)");
                        eventLoggerUtil.recordLog(facilityCd, eventLogMessage9, LogLevel.DEBUG);
                    }
                }
            });
            //pat_unique_history一括mongodb挿入
            if (tableName.equals("pat_unique_history") && patUniqueHistoryEntityList.size() > 0) {
                try {
                    mongoTemplate.insertAll(patUniqueHistoryEntityList);
                } catch (Exception er) {
                    //ログ
                    EventLogMessage eventLogMessage9 = eventLoggerUtil.getEventLogMessage("pat_unique_history一括mongodb挿入に失敗しました！",
                            facilityCd, "setMongoDate()");
                    eventLoggerUtil.recordLog(facilityCd, eventLogMessage9, LogLevel.ERROR);
                }
            }
            String delsql = "delete from " + tableName + " where facility_cd = ?";
            jdbcTemplateConvert.update(delsql, facilityCd);
            File fileDbStep = new File(inputFilePath);
            fileDbStep.delete();
        }
    }

    @Bean(name = STEP_NAME)
    public Step step() {
        return stepBuilderFactory.get(STEP_NAME)
                .tasklet(this)
                .listener(new PromotionListener())
                .build();
    }

    /**
     * ord_scheduleのis_dummy ='1'データを追加
     *
     * @return
     */
    private List<OrdSchedule> insertOrdSchedule(OrdMain om) {

        // メインスケジュールの治療予定情報取得
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

        // ベッドとクールが未登録でなければダミースケジュール登録情報リスト作成処理実施
        if ((0 != indKurCd) && (0 != indBedCd)) {
            Long treatTime = null;
            // 治療時間(指示:治療条件情報)設定
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

            // メインスケジュールの治療日、クール(クール内標準治療開始時刻)、治療時間から治療終了予定日時の日時を算出
            List<MstKur> mstKur = null;
            if (null == mstKur) {
                String mst_kur_sql = "select A.kur_cd, A.kur_start_time, A.kur_end_time, A.kur_standard_start_time from mst_kur A ,(select mss.facility_cd, ms.*, row_number() over() as index from mst_selector mss " +
                        "cross join lateral jsonb_to_recordset(mss.order_settings->'items') as ms (code bigint,name text) where facility_cd = ? " +
                        "and master_physical_name = 'mst_kur') ms where A.facility_cd = ms.facility_cd and A.kur_cd = ms.code and A.is_del = '0' order by ms.index";
                mstKur = namedParameterJdbcTemplateNkk5.getJdbcOperations().query(mst_kur_sql, new Object[]{facilityCdRet}, new BeanPropertyRowMapper<>(MstKur.class));
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
            // ダミースケジュールが治療終了予定日時を超えていなければ、ダミースケジュール登録情報リストに追加
            while (!dummyDate.isAfter(treatEndDate)) {
                // 次クール情報取得
                MstKurEx nextKurInfo = this.calcNextKurInfo(mstKur, dummyKur);
                if (null == nextKurInfo) {
                    return null;
                } else {
                    // 次クールの最初のクールフラグがtrueの場合は日付を翌日に更新
                    if (nextKurInfo.getIsFirstKur()) {
                        dummyDate = dummyDate.plusDays(1);
                    }
                    // ダミースケジュール更新(クールの期間すべてを含んでいるかをチェックするため、ダミースケジュールの時刻はクール終了時刻を設定)
                    String dummyTreatDate = dummyDate.format(dayFormat);
                    dummyDate = LocalDateTime.parse(dummyTreatDate + nextKurInfo.getKurEndTime(), dateFormat);
                    dummyKur = nextKurInfo.getKurCd().longValue();
                    // ダミースケジュールが治療終了予定日時を超えていなければ、ダミースケジュール登録情報リストに追加
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
     * ord_scheduleのis_dummy ='1'データを追加
     * wzy
     * @return
     */
    private List<OrdSchedule> insertOrdSchedule1(OrdMain om, List<MstKur> mstKur) {
        // メインスケジュールの治療予定情報取得
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

        // ベッドとクールが未登録でなければダミースケジュール登録情報リスト作成処理実施
        if ((0 != indKurCd) && (0 != indBedCd)) {
            Long treatTime = null;
            // 治療時間(指示:治療条件情報)設定
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

            // メインスケジュールの治療日、クール(クール内標準治療開始時刻)、治療時間から治療終了予定日時の日時を算出
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
            // ダミースケジュールが治療終了予定日時を超えていなければ、ダミースケジュール登録情報リストに追加
            while (!dummyDate.isAfter(treatEndDate)) {
                // 次クール情報取得
                MstKurEx nextKurInfo = this.calcNextKurInfo(mstKur, dummyKur);
                if (null == nextKurInfo) {
                    return null;
                } else {
                    // 次クールの最初のクールフラグがtrueの場合は日付を翌日に更新
                    if (nextKurInfo.getIsFirstKur()) {
                        dummyDate = dummyDate.plusDays(1);
                    }
                    // ダミースケジュール更新(クールの期間すべてを含んでいるかをチェックするため、ダミースケジュールの時刻はクール終了時刻を設定)
                    String dummyTreatDate = dummyDate.format(dayFormat);
                    dummyDate = LocalDateTime.parse(dummyTreatDate + nextKurInfo.getKurEndTime(), dateFormat);
                    dummyKur = nextKurInfo.getKurCd().longValue();
                    // ダミースケジュールが治療終了予定日時を超えていなければ、ダミースケジュール登録情報リストに追加
                    if (dummyDate.isAfter(treatEndDate)) break;

                    OrdSchedule dummySchedule = new OrdSchedule();
                    dummySchedule.setFacilityCd(facilityCdRet);
                    dummySchedule.setOrdNo(ordNo);
                    dummySchedule.setTreatDate(dummyTreatDate);
                    dummySchedule.setTreatWeek(Short.parseShort(String.valueOf(dummyDate.getDayOfWeek().getValue())));
                    dummySchedule.setKurCd(Integer.parseInt(String.valueOf(dummyKur)));
                    dummySchedule.setBedCd(Integer.parseInt(String.valueOf(indBedCd)));
                    dummySchedule.setPatId(patId);
                    dummySchedule.setIsDummy("1");
                    result.add(dummySchedule);
                }
            }
            return result;
        }
        return null;
    }

    /**
     * 初回新規と差分新規の前の表の最大番号を取る
     *
     * @param tableName
     * @return
     */
    private Integer getSeqOfEachTable(String tableName,String facilityCd) {
        GlobalContext globalContext = JobStartEndLIstener.getGlobalContext();
        Integer currSeq = null;
        if (tableName.equals("ord_main")) {
            Map<String, Object> currSeqMap = namedParameterJdbcTemplateNkk5.getJdbcOperations().queryForMap("SELECT last_value as currSeq FROM ntss.ord_main_ord_no_seq;");
            currSeq = Integer.parseInt(String.valueOf(currSeqMap.get("currSeq")));
        } else if (tableName.equals("mst_machine")) {
            Map<String, Object> currSeqMap = namedParameterJdbcTemplateNkk5.getJdbcOperations().queryForMap("SELECT last_value as currSeq FROM ntss.mst_machine_machine_no_seq;");
            currSeq = Integer.parseInt(String.valueOf(currSeqMap.get("currSeq")));
        } else if (tableName.equals("mst_bed")) {
            Map<String, Object> currSeqMap = namedParameterJdbcTemplateNkk5.getJdbcOperations().queryForMap("SELECT last_value as currSeq FROM ntss.mst_bed_bed_cd_seq;");
            currSeq = Integer.parseInt(String.valueOf(currSeqMap.get("currSeq")));
        }//add 8644 zc start
        else if (tableName.equals("mst_comsv_setting")) {
            // mod #12230 差分コンバートにより元に戻ってしまう項目がある limingzhe start
            String sqlM = "SELECT COALESCE(max(comsv_cd),0) as currSeq FROM mst_comsv_setting where facility_cd = ?";
            currSeq = Integer.parseInt(namedParameterJdbcTemplateNkk5.getJdbcOperations().queryForObject(
                    sqlM, new Object[]{facilityCd}, String.class));
            // mod #12230 差分コンバートにより元に戻ってしまう項目がある limingzhe end
        }//add 8644 zc end
        // add #8992-4 pat_event zs start
        // mod zl start
        // mod #10418 SQL注入対策：パラメータバインディング start
        else if (tableName.equals("pat_event")) {
            //mod #11998 start
            Integer pat_event_currSeq =
                    namedParameterJdbcTemplateNkk5
                            .getJdbcOperations()
                            .query(
                                    "SELECT pat_event_cd " +
                                            "FROM pat_event " +
                                            "WHERE facility_cd = ? " +
                                            "ORDER BY pat_event_cd DESC " +
                                            "LIMIT 1",
                                    rs -> rs.next() ? rs.getInt(1) : null,
                                    facilityCd
                            );
            globalContext.maxPrimaryForDB5 = (pat_event_currSeq != null) ? pat_event_currSeq : 0;
            //mod #11998 start
        }
        // mod #10418 SQL注入対策：パラメータバインディング end
        // mod zl end
        // add #8992-4 pat_event zs end
        // add zl start

        // add #10739 start
        // mod #10418 SQL注入対策：パラメータバインディング start
        else if (tableName.equals("pat_ind_approve_history")) {
            Map<String, Object> currSeqMap = namedParameterJdbcTemplateNkk5.getJdbcOperations().queryForMap("SELECT COALESCE(max(ind_approve_history_no),0) as currSeq FROM pat_ind_approve_history where facility_cd = ?", facilityCd);
            globalContext.maxPrimaryForDB5 = Integer.parseInt(String.valueOf(currSeqMap.get("currSeq")));
        }
        // mod #10418 SQL注入対策：パラメータバインディング end
        // add #10739 end
        // add zl end
        return currSeq;
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
                // 次クール判定
                if (true == isCurrentKur) {
                    // 次クールを返す
                    targetKur = MstKurEx.parse(mstKur.get(i));
                    break;
                }
                // 現在クール判定(最後のクールは除外)
                if ((i != mstKur.size() - 1) && (currentKurCd == mstKur.get(i).getKurCd().longValue())) {
                    isCurrentKur = true;
                }
            }
            // 次クールが見つからなかった場合は最初のクールを返す
            if (false == isCurrentKur) {
                targetKur = MstKurEx.parse(mstKur.get(0));
                targetKur.setIsFirstKur(true);
            }
        }

        return targetKur;
    }
    // add #8805 【デグレ】ツール出力時にエラーが検出されていないがエラーメッセージが表示され進まない ZS end

    // add #10661 limingyang start
    private void updatePatInsuranceHistory(String facilityCd) {

        EventLogMessage eventLogMessage = new EventLogMessage();
        MapSqlParameterSource parameters = new MapSqlParameterSource()
                .addValue("facility_cd", facilityCd);
        try {
            // SQL
                String update_pat_insurance_history = """
                WITH A AS (
                    SELECT
                        pat_id,reg_date,
                        jsonb_set (
                            jsonb_set (
                                jsonb_set ( jsonb_set ( insu_info, '{insu_class}', '"0"' :: JSONB, TRUE ), '{insu_cd}', to_jsonb ( insurance_cd :: TEXT ), TRUE ),
                                '{insu_info_name}',
                            ( CASE WHEN insu_name IS NULL THEN 'null' :: JSONB ELSE to_jsonb ( insu_name ) END ) :: JSONB,
                    TRUE
                    ),
                    '{insu_info_name_short}',
                    ( CASE WHEN insu_name_short IS NULL THEN 'null' :: JSONB ELSE to_jsonb ( insu_name_short ) END ) :: JSONB,
                TRUE
                    ) AS info
                FROM
                    pat_insurance_history
                WHERE
                    insu_class = 0
                    AND facility_cd = :facility_cd 
                    ),
                    BB AS (
                    SELECT
                        pat_id,reg_date,
                        jsonb_set (
                            jsonb_set (
                                jsonb_set ( jsonb_set ( insu_pub_info, '{insu_class}', '"1"' :: JSONB, TRUE ), '{insu_pub1_cd}', to_jsonb ( insurance_cd :: TEXT ), TRUE ),
                                '{insu_pub1_info_name}',
                            ( CASE WHEN insu_name IS NULL THEN 'null' :: JSONB ELSE to_jsonb ( insu_name ) END ) :: JSONB,
                    TRUE
                    ),
                    '{insu_pub1_info_name_short}',
                    ( CASE WHEN insu_name_short IS NULL THEN 'null' :: JSONB ELSE to_jsonb ( insu_name_short ) END ) :: JSONB,
                TRUE
                    ) AS info
                FROM
                    pat_insurance_history
                WHERE
                    insu_class = 1
                    AND facility_cd = :facility_cd 
                    AND fn_ctl_no = '2'
                    ),
                    B AS (
                    SELECT
                        pat_id,reg_date,
                        jsonb_build_object (
                            'insu_class',
                            info -> 'insu_class',
                            'insu_pub1_cd',
                            info -> 'insu_pub1_cd',
                            'insu_pub1_info_name',
                            info -> 'insu_pub1_info_name',
                            'insu_pub1_info_name_short',
                            info -> 'insu_pub1_info_name_short',
                            'insu_pub1_no',
                            info -> 'insu_pub_no',
                            'insu_pub1_passbook_no',
                            info -> 'passbook_no',
                            'insu_pub1_name',
                            info -> 'insu_pub_name',
                            'insu_pub1_pat_no',
                            info -> 'insu_pub_pat_no'
                        ) AS info
                    FROM
                        BB
                    ),
                    CC AS (
                    SELECT
                        pat_id,reg_date,
                        jsonb_set (
                            jsonb_set (
                                jsonb_set ( jsonb_set ( insu_pub_info, '{insu_class}', '"1"' :: JSONB, TRUE ), '{insu_pub2_cd}', to_jsonb ( insurance_cd :: TEXT ), TRUE ),
                                '{insu_pub2_info_name}',
                            ( CASE WHEN insu_name IS NULL THEN 'null' :: JSONB ELSE to_jsonb ( insu_name ) END ) :: JSONB,
                    TRUE
                    ),
                    '{insu_pub2_info_name_short}',
                    ( CASE WHEN insu_name_short IS NULL THEN 'null' :: JSONB ELSE to_jsonb ( insu_name_short ) END ) :: JSONB,
                TRUE
                    ) AS info
                FROM
                    pat_insurance_history
                WHERE
                    insu_class = 1
                    AND facility_cd = :facility_cd 
                    AND fn_ctl_no = '3'
                    ),
                    C AS (
                    SELECT
                        pat_id,reg_date,
                        jsonb_build_object (
                            'insu_class',
                            info -> 'insu_class',
                            'insu_pub2_cd',
                            info -> 'insu_pub2_cd',
                            'insu_pub2_info_name',
                            info -> 'insu_pub2_info_name',
                            'insu_pub2_info_name_short',
                            info -> 'insu_pub2_info_name_short',
                            'insu_pub2_no',
                            info -> 'insu_pub_no',
                            'insu_pub2_passbook_no',
                            info -> 'passbook_no',
                            'insu_pub2_name',
                            info -> 'insu_pub_name',
                            'insu_pub2_pat_no',
                            info -> 'insu_pub_pat_no'
                        ) AS info
                    FROM
                        CC
                    ),
                    D AS ( SELECT A.* FROM A UNION ALL SELECT B.* FROM B UNION ALL SELECT C.* FROM C ),
                    E AS ( SELECT pat_id, reg_date, jsonb_agg ( info ) AS info_array FROM D GROUP BY pat_id,reg_date) 
                    UPDATE pat_insurance_history
                    SET insu_set_info = E.info_array
                FROM
                    E
                WHERE
                    pat_insurance_history.pat_id = E.pat_id
                    AND  pat_insurance_history.reg_date=E.reg_date
                    AND facility_cd = :facility_cd
                    AND insu_class = 2;
                """;

            int count = namedParameterJdbcTemplateConvert.update(update_pat_insurance_history, parameters);
            //ログ
            eventLogMessage = eventLoggerUtil.getEventLogMessage(String.format("pat_insurance_history.insu_set_info更新成功%d件", count),
                    facilityCd, "updatePatInsuranceHistory()");
            eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.INFO);
        } catch (Exception e) {
            //ログ
            eventLogMessage = eventLoggerUtil.getEventLogMessage("pat_insurance_history.insu_set_info更新に失敗しました！,「ERROR」:" + EventLoggerUtil.excetionStackTraceToString(e),
                    facilityCd, "updatePatInsuranceHistory()");
            eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.ERROR);
        }
    }
    // add #10661 limingyang end

    /**
     * Map から指定されたキーに対応する値を取得し、文字列に変換します。
     * キーが存在しない、または値が null の場合は、null を返します。
     *
     * @param row データを格納した Map オブジェクト（通常はデータベースの1行を表す）
     * @param key 取得したいフィールド名（Map のキー）
     * @return 値が存在し、かつ null でない場合は toString() の結果を返す。そうでなければ null を返す
     */
    private String parseStringOrNull(Map<String, Object> row, String key) {
        return row.get(key) != null ? row.get(key).toString() : null;
    }

}