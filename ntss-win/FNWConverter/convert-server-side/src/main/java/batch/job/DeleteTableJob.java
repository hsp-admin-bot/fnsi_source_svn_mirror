package batch.job;

import batch.ApplicationConst;
import batch.ApplicationConst.JobParameterKeys;
import batch.config.ConvertPriorityConfig;
import batch.part.InfomationSchemaControl;
import batch.part.ProgressManagement;
import batch.part.TableNameToDbType;
import batch.step.DeleteTableInConvertDbStep;
import com.zaxxer.hikari.HikariDataSource;
import org.apache.tomcat.util.http.fileupload.FileUtils;
import org.springframework.batch.core.job.Job;
import org.springframework.batch.core.step.Step;
import org.springframework.batch.core.configuration.annotation.EnableBatchProcessing;
import org.springframework.batch.core.job.builder.JobBuilder;
import org.springframework.batch.core.repository.JobRepository;
import org.springframework.batch.core.step.builder.StepBuilder;
import org.springframework.batch.core.job.parameters.RunIdIncrementer;
import org.springframework.batch.core.scope.context.ChunkContext;
import org.springframework.batch.infrastructure.item.ExecutionContext;
import org.springframework.batch.infrastructure.repeat.RepeatStatus;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.env.Environment;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.transaction.annotation.Transactional;
import utils.Utils;
import web.config.EventLoggerUtil;
import web.logger.EventLogMessage;
import web.logger.LogLevel;

import java.io.File;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * 開発時のテスト用、コンバートDB、本番DBの処理対象テーブルデータを削除するジョブ
 */
@Configuration
@EnableBatchProcessing
public class DeleteTableJob {

    private final String JOB_NAME = "DeleteTableJob";

    @Autowired
    private JobRepository jobRepository;

    @Autowired
    ConvertPriorityConfig convertPriorityConfig;

    @Autowired
    ApplicationContext appContext;

    @Autowired
    ProgressManagement progressManagement;
    
    @Autowired
    DeleteTableInConvertDbStep deleteTableInConvertDbStep;

    /**
     * ロギング ツール クラスの導入
     */
    @Autowired
    private EventLoggerUtil eventLoggerUtil;

    @Autowired
    private Environment environment;

    @Autowired
    Utils utils;

    @Bean
    Step initialStep() {
        return new StepBuilder("initialStep", jobRepository)
        .tasklet((contribution, chunkContext) -> {
            // 削除対象の施設コードの取得
            String facilityCd = chunkContext.getStepContext().getJobParameters()
            .get(JobParameterKeys.FACILITY_CD).toString();
            // 進捗更新
            long jobInstanceId = chunkContext.getStepContext().getStepExecution().getJobExecution().getJobInstance().getInstanceId();
            progressManagement.insertBatchStatus(facilityCd, progressManagement.STARTED, jobInstanceId, JOB_NAME);
            
            // コンバート処理IDの取得
            int convertProcId = progressManagement.getConvertProcId(facilityCd);
            // コンバート処理IDをを取得し、コンテキストへ保存する
            ExecutionContext cxt = chunkContext.getStepContext().getStepExecution().getJobExecution().getExecutionContext();
            cxt.put(ApplicationConst.PromotionKeys.CONVERT_PROC_ID,convertProcId);
            return RepeatStatus.FINISHED;
        }).build();
    }

    @Bean
    public Step getTargetTableNamesStep() {
 
        return new StepBuilder("getTargetTableNamesStep", jobRepository)
        .tasklet((contribution, chunkContext) -> {
            // 削除対象の施設コードの取得
            String facilityCd = chunkContext.getStepContext().getJobParameters()
            .get(JobParameterKeys.FACILITY_CD).toString();

            // 進捗更新
            long jobInstanceId = chunkContext.getStepContext().getStepExecution().getJobExecution().getJobInstance().getInstanceId();
            progressManagement.insertBatchStatus(facilityCd, progressManagement.STARTED, jobInstanceId, JOB_NAME);
            return RepeatStatus.FINISHED;
        }).build();
    }


    @Bean
    public Step deleteTableInProductionDbStep() {
 
        return new StepBuilder("deleteTableInProductionDbStep", jobRepository)
                .tasklet((contribution, chunkContext) -> executeDeleteTableInProductionDbTasklet(chunkContext))
                .build();
    }

    /**
     * 本番DBテーブル削除ステップのタスクレット処理を実行する
     */
    private RepeatStatus executeDeleteTableInProductionDbTasklet(ChunkContext chunkContext) throws Exception {
        String facilityCd = resolveFacilityCdFromChunkContext(chunkContext);
        List<String> deleteTableNameList = buildProductionDeleteTableNameList();
        List<Long> userIds = fetchPersonalUserIdsForSpecialDelete(facilityCd);
        cleanupResidualFilesAndPatMongo(chunkContext, facilityCd);
        removeExcludedProductionTables(deleteTableNameList);
        int deleteTableCount = deleteAllProductionTables(facilityCd, deleteTableNameList, userIds);
        completeProductionDbDeletionStep(chunkContext, facilityCd, deleteTableCount);
        return RepeatStatus.FINISHED;
    }

    /**
     * ジョブパラメータから施設コードを取得する
     */
    private String resolveFacilityCdFromChunkContext(ChunkContext chunkContext) {
        return chunkContext.getStepContext().getJobParameters()
            .get(JobParameterKeys.FACILITY_CD).toString();
    }

    /**
     * 本番DB削除対象テーブル名リストを構築する
     */
    private List<String> buildProductionDeleteTableNameList() {
            List<String> deleteTableNameList = convertPriorityConfig.getTableNames();
            //mod 12193 start
            deleteTableNameList.addAll(utils.deleteProductionDbTable);

            //mod 12193 end
        return deleteTableNameList;
    }

    /**
     * 特殊削除条件用にmst_personal_userのuser_id一覧を取得する
     */
    private List<Long> fetchPersonalUserIdsForSpecialDelete(String facilityCd) throws Exception {

            // add　削除条件変更　李　start
            TableNameToDbType tableNameToDbType2 = new TableNameToDbType(appContext);
            String registDbType2 =tableNameToDbType2.getDbTypeByTableName("mst_personal_user");
            HikariDataSource ds2 = (HikariDataSource) appContext.getBean(registDbType2);
                    String table_prefix2 = environment.getProperty(registDbType2 + "_prefix");
                    table_prefix2 = table_prefix2 == null ? "" : table_prefix2;
                    JdbcTemplate jdbcTemplate2 = new JdbcTemplate(ds2);
                    String sql2 = "select user_id  from " + table_prefix2 + "mst_personal_user" + " where facility_cd= ?" + " and fn_staff_cd is null";
                    return jdbcTemplate2.queryForList(sql2, new Object[]{facilityCd}, Long.class);
                    // mod #10418 SQL注入対策：文字列連結を削除し、NamedParameterJdbcTemplateを使用 start
                    // add　削除条件変更　李　end
    }

    /**
     * 残存ファイル削除およびPatMongoジョブオペレータ削除を実行する
     */
    private void cleanupResidualFilesAndPatMongo(ChunkContext chunkContext, String facilityCd) throws Exception {
                    // add #8471 削除ボタンの動きが異常 limingyang start
                    // マルチファシリテーション同時実行：IPアドレスはGlobalContext.ipAddressを使用する代わりに、JobParametersから読み取られます。 #11998 add
                    Object ipParam = chunkContext.getStepContext().getJobParameters().get(JobParameterKeys.IP_ADDRESS); // #11998 add
                    String ipAddress = (ipParam != null) ? ipParam.toString() : ""; // #11998 add
                    File file = new File(ipAddress + "/" + facilityCd); // #11998 modify (原 globalContext.ipAddress + "/" + facilityCd)
                    EventLogMessage eventLogMessagefile;
                    if (file.exists()) {
                        FileUtils.deleteDirectory(file);
                        eventLogMessagefile = eventLoggerUtil.getEventLogMessage("残ったファイル削除実行：残ったファイルの削除に成功しました",
                                facilityCd, "DeleteTableJob.deleteTableInProductionDbStep()");
                    } else {
                        eventLogMessagefile = eventLoggerUtil.getEventLogMessage("残ったファイル削除実行：ファイルが存在しません",
                                facilityCd, "DeleteTableJob.deleteTableInProductionDbStep()");
                    }
                    eventLoggerUtil.recordLog(facilityCd, eventLogMessagefile, LogLevel.INFO);
                    progressManagement.DelPatMongoJobOperator(facilityCd);
                    // add #8471 削除ボタンの動きが異常 limingyang end
    }

    /**
     * 削除対象から固定除外テーブルを除外する
     */
    private void removeExcludedProductionTables(List<String> deleteTableNameList) {
        Set<String> toRemove = new HashSet<>(Arrays.asList("mst_facility", "mst_report"));
        deleteTableNameList.removeAll(toRemove);
    }

    /**
     * 本番DBの全削除対象テーブルを順次削除処理する
     */
    private int deleteAllProductionTables(String facilityCd, List<String> deleteTableNameList, List<Long> userIds) throws Exception {
        int deleteTableCount = 0;
        List<String> noDeleteTableNameList = Arrays.asList(
                "mst_user_authentication",
                "mst_user",
                "mst_personal_user");
        for (String deleteTableName : deleteTableNameList) {
            deleteTableCount += processOneProductionTableDeletion(
                    facilityCd, deleteTableName, deleteTableNameList, userIds, noDeleteTableNameList);
        }
        return deleteTableCount;
    }

    /**
     * 1テーブル分の本番DB削除処理を実行する（削除カウント増分値を返す）
     */
    private int processOneProductionTableDeletion(
            String facilityCd,
            String deleteTableName,
            List<String> deleteTableNameList,
            List<Long> userIds,
            List<String> noDeleteTableNameList) throws Exception {
                TableNameToDbType tableNameToDbType = new TableNameToDbType(appContext);
                String registDbType =tableNameToDbType.getDbTypeByTableName(deleteTableName);

                // 削除する本番DBのTypeに対応するデータソースの取得
                HikariDataSource ds = (HikariDataSource) appContext.getBean(registDbType);

                // add 2020-12-21 テーブルプレフィックス【ntss.】取得 う start
                String table_prefix = environment.getProperty(registDbType + "_prefix");
                table_prefix = table_prefix == null ? "" : table_prefix;
                // add 2020-12-21 テーブルプレフィックス【ntss.】取得 う end

                JdbcTemplate jdbcTemplate = new JdbcTemplate(ds);

                InfomationSchemaControl isc = new InfomationSchemaControl(appContext);

                if ("mnt_motion_record".equals(deleteTableName)) {
            return deleteMntMotionRecordTable(facilityCd, deleteTableName, jdbcTemplate, registDbType);
        }
        if (noDeleteTableNameList.contains(deleteTableName) && !userIds.isEmpty()) {
            return deleteNoDeleteTableWithExcludedUserIds(
                    facilityCd, deleteTableName, registDbType, table_prefix, ds, userIds);
        }
        if (noDeleteTableNameList.contains(deleteTableName) && userIds.isEmpty()) {
            return 0;
        }
        return deleteStandardProductionTable(
                facilityCd, deleteTableName, deleteTableNameList, registDbType,
                table_prefix, jdbcTemplate, isc, noDeleteTableNameList);
    }

    /**
     * mnt_motion_recordテーブルのバッチ削除を実行する
     */
    private int deleteMntMotionRecordTable(
            String facilityCd, String deleteTableName, JdbcTemplate jdbcTemplate, String registDbType) {
                    try{
                        performBatchDelete(deleteTableName,facilityCd,jdbcTemplate,registDbType);
                    }catch (Exception e){
                        EventLogMessage eventLogMessage = eventLoggerUtil.getEventLogMessage("本番DBテーブル削除実行：mnt_motion_record 失敗",
                                facilityCd, "DeleteTableJob.deleteTableInProductionDbStep()");
                        eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.ERROR);
                    }
        return 0;
                }

    /**
     * 特殊処理テーブルをuser_id除外条件付きで削除する
     */
    private int deleteNoDeleteTableWithExcludedUserIds(
            String facilityCd,
            String deleteTableName,
            String registDbType,
            String table_prefix,
            HikariDataSource ds,
            List<Long> userIds) {
                // mod　削除条件変更　李　start
                // mod #10418 SQL注入対策：NamedParameterJdbcTemplateを使用してIN句を安全に処理 start

                    String sql3 = "delete from " + table_prefix + deleteTableName + " where facility_cd = :facilityCd and user_id not in (:userIds)";
                    //ログ
                    EventLogMessage eventLogMessage = eventLoggerUtil.getEventLogMessage("本番DBテーブル削除実行：" + registDbType + "：" + facilityCd + ":"+ sql3,
                            facilityCd, "DeleteTableJob.deleteTableInProductionDbStep()");
                    eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.INFO);

                    // mod #11302 コンバートの削除処理で処理が進まなくなることがある limingyang start
                    try{
                        // NamedParameterJdbcTemplateを使用してパラメータバインディング
                        NamedParameterJdbcTemplate namedJdbcTemplate = new NamedParameterJdbcTemplate(ds);
                        org.springframework.jdbc.core.namedparam.MapSqlParameterSource params =
                            new org.springframework.jdbc.core.namedparam.MapSqlParameterSource();
                        params.addValue("facilityCd", facilityCd);
                        params.addValue("userIds", userIds);
                        namedJdbcTemplate.update(sql3, params);
                    }catch (Exception e){
                        eventLoggerUtil.recordLog(facilityCd, eventLoggerUtil.getEventLogMessage("本番DBテーブル削除実行："
                                        + deleteTableName + " 失敗,Error:" + e,
                                facilityCd, "DeleteTableJob.deleteTableInProductionDbStep()"), LogLevel.ERROR);
                    }
                    // mod #11302 コンバートの削除処理で処理が進まなくなることがある limingyang end
                    // mod #10418 SQL注入対策：NamedParameterJdbcTemplateを使用してIN句を安全に処理 end
        return 1;
                }
                // add 7406  ReMS利用施設をコンバートすると送信先グループマスタや警報通知マスタなどのデータが消えている start
    /**
     * 通常の本番DBテーブル削除またはtruncate中止ログを処理する
     */
    private int deleteStandardProductionTable(
            String facilityCd,
            String deleteTableName,
            List<String> deleteTableNameList,
            String registDbType,
            String table_prefix,
            JdbcTemplate jdbcTemplate,
            InfomationSchemaControl isc,
            List<String> noDeleteTableNameList) throws Exception {
                String sql;
                if(isc.hasFacilityCd(deleteTableName)){
            sql = buildFacilityCdDeleteSql(deleteTableName, table_prefix, deleteTableNameList, noDeleteTableNameList);
                    EventLogMessage eventLogMessage1 = eventLoggerUtil.getEventLogMessage("本番DBテーブル削除実行：" + registDbType + "：" + facilityCd + ":"+ sql,
                            facilityCd, "DeleteTableJob.deleteTableInProductionDbStep()");
                    eventLoggerUtil.recordLog(facilityCd, eventLogMessage1, LogLevel.INFO);
                }else{
                    // Truncateは実施しない方針
                    // mod 2020-11-27 FNSI-改修内容 ntss.テーブルプレフィックスを追加 う start
                    sql = "truncate table " + table_prefix + deleteTableName + " cascade";
                    // mod 2020-11-27 FNSI-改修内容 ntss.テーブルプレフィックスを追加 う end
                    //ログ
                    EventLogMessage eventLogMessage2 = eventLoggerUtil.getEventLogMessage("本番DBテーブル削除中止：" + registDbType + "：" + facilityCd + ":"+ deleteTableName,
                            facilityCd, "DeleteTableJob.deleteTableInProductionDbStep()");
                    eventLoggerUtil.recordLog(facilityCd, eventLogMessage2, LogLevel.INFO);
            return 0;
        }
        executeFacilityCdDeleteSql(facilityCd, deleteTableName, jdbcTemplate, sql);
        return 1;
    }

    /**
     * facility_cd条件付き削除SQLを組み立てる
     */
    private String buildFacilityCdDeleteSql(
            String deleteTableName,
            String table_prefix,
            List<String> deleteTableNameList,
            List<String> noDeleteTableNameList) {
        String sql = "delete from " + table_prefix + deleteTableName
                + " where facility_cd =?";
        if (deleteTableName.equals("mst_selector")) {
            List<String> deleteTableNameListU = deleteTableNameList.stream().filter(e -> !noDeleteTableNameList.contains(e)).collect(Collectors.toList());
            String deleteTableNameListStr = String.join("','", deleteTableNameListU);
            sql = sql.concat(" and master_physical_name in ('" + deleteTableNameListStr + "')");
        }
        return sql;
    }

    /**
     * facility_cd条件付き削除SQLを実行する
     */
    private void executeFacilityCdDeleteSql(
            String facilityCd, String deleteTableName, JdbcTemplate jdbcTemplate, String sql) {
                // mod #11302 コンバートの削除処理で処理が進まなくなることがある limingyang start
                try{
                    jdbcTemplate.update(sql, new Object[]{facilityCd});
                }catch (Exception e){
                    eventLoggerUtil.recordLog(facilityCd, eventLoggerUtil.getEventLogMessage("本番DBテーブル削除実行："
                                    + deleteTableName + " 失敗,Error:" + e,
                            facilityCd, "DeleteTableJob.deleteTableInProductionDbStep()"), LogLevel.ERROR);
                }
                // mod #11302 コンバートの削除処理で処理が進まなくなることがある limingyang end
            }
            // 進捗更新
    /**
     * 本番DB削除ステップ完了時の進捗更新を行う
     */
    private void completeProductionDbDeletionStep(ChunkContext chunkContext, String facilityCd, int deleteTableCount) {
            long jobInstanceId = chunkContext.getStepContext().getStepExecution().getJobExecution().getJobInstance().getInstanceId();
            int convertProcId = progressManagement.getConvertProcId(facilityCd);
            progressManagement.updateBatchStatus(convertProcId,facilityCd, progressManagement.COMPLETED, jobInstanceId, JOB_NAME);
            // 進捗情報をジョブ実行情報に設定
            String progress = String.valueOf(deleteTableCount);
            progress = String.valueOf(deleteTableCount) + "/" + String.valueOf(deleteTableCount);
            ExecutionContext cxt = chunkContext.getStepContext().getStepExecution().getJobExecution().getExecutionContext();
            cxt.put(ApplicationConst.PromotionKeys.CONVERT_PROC_ID,convertProcId);
            cxt.put(ApplicationConst.PromotionKeys.CONVERT_PROGRESS, progress);
            progressManagement.createConvertTableStatus(chunkContext, "本番DBテーブル削除");
    }

    @Transactional
    public void performBatchDelete(String deleteTableName,String facilityCd,JdbcTemplate jdbcTemplate,String registDbType) {
        int batchSize = 500000;
        int deletedCount = 0;
        do {
            // mod #10472 limingyang 20240329 start
            String batchSql = "DELETE FROM :tableName WHERE motion_record_no IN (" +
                    "SELECT motion_record_no FROM :tableName WHERE facility_cd = :facilityCd LIMIT :batchSize)";

            String sqlWithTableName = batchSql.replace(":tableName", deleteTableName);
            Map<String, Object> parameters = new HashMap<>();
            parameters.put("facilityCd", facilityCd);
            parameters.put("batchSize", batchSize);

            NamedParameterJdbcTemplate namedParameterJdbcTemplate = new NamedParameterJdbcTemplate(jdbcTemplate.getDataSource());
            deletedCount = namedParameterJdbcTemplate.update(sqlWithTableName, parameters);
            // mod #10472 limingyang 20240329 en
            EventLogMessage eventLogMessage5 = eventLoggerUtil.getEventLogMessage("本番DBテーブル削除実行：" + registDbType + "：" + facilityCd + ":" + batchSql,
                    facilityCd, "DeleteTableJob.deleteTableInProductionDbStep()");
            eventLoggerUtil.recordLog(facilityCd, eventLogMessage5, LogLevel.INFO);
        } while (deletedCount > 0);
    }


    /**
     * ジョブの作成
     * 
     * @throws Exception
     */
    @Bean(name = JOB_NAME)
    public Job job() throws Exception {
        return new JobBuilder(JOB_NAME, jobRepository).incrementer(new RunIdIncrementer())
                .start(initialStep())
                .next(getTargetTableNamesStep())
                .next(deleteTableInConvertDbStep.step())
                .next(deleteTableInProductionDbStep())
                .build();
    }

}