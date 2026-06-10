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
import org.springframework.batch.core.Job;
import org.springframework.batch.core.Step;
import org.springframework.batch.core.configuration.annotation.EnableBatchProcessing;
import org.springframework.batch.core.configuration.annotation.JobBuilderFactory;
import org.springframework.batch.core.configuration.annotation.StepBuilderFactory;
import org.springframework.batch.core.launch.support.RunIdIncrementer;
import org.springframework.batch.item.ExecutionContext;
import org.springframework.batch.repeat.RepeatStatus;
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
    JobBuilderFactory jobBuilderFactory;

    @Autowired
    StepBuilderFactory stepBuilderFactory;

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
        return stepBuilderFactory.get("initialStep")
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
 
        return stepBuilderFactory.get("getTargetTableNamesStep")
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
 
        return stepBuilderFactory.get("deleteTableInProductionDbStep")
        .tasklet((contribution, chunkContext) -> {
            // 削除対象の施設コードの取得
            String facilityCd = chunkContext.getStepContext().getJobParameters()
            .get(JobParameterKeys.FACILITY_CD).toString();
            // 削除対象のテーブル名の取得
            List<String> deleteTableNameList = convertPriorityConfig.getTableNames();
            //mod 12193 start
            deleteTableNameList.addAll(utils.deleteProductionDbTable);

            //mod 12193 end
            //10159
            // 特殊処理テーブルリスト
            List<String> noDeleteTableNameList = Arrays.asList(
                "mst_user_authentication", 
                "mst_user", 
                "mst_personal_user");
            
            // 削除テーブル数カウント
            int deleteTableCount = 0;

            // add　削除条件変更　李　start
            TableNameToDbType tableNameToDbType2 = new TableNameToDbType(appContext);
            String registDbType2 =tableNameToDbType2.getDbTypeByTableName("mst_personal_user");
            HikariDataSource ds2 = (HikariDataSource) appContext.getBean(registDbType2);
                    String table_prefix2 = environment.getProperty(registDbType2 + "_prefix");
                    table_prefix2 = table_prefix2 == null ? "" : table_prefix2;
                    JdbcTemplate jdbcTemplate2 = new JdbcTemplate(ds2);
                    String sql2 = "select user_id  from " + table_prefix2 + "mst_personal_user" + " where facility_cd= ?" + " and fn_staff_cd is null";
                    List<Long> userIds = jdbcTemplate2.queryForList(sql2, new Object[]{facilityCd}, Long.class);
                    // mod #10418 SQL注入対策：文字列連結を削除し、NamedParameterJdbcTemplateを使用 start
                    // add　削除条件変更　李　end

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

            // 削除対象から外す
            Set<String> toRemove = new HashSet<>(Arrays.asList("mst_facility", "mst_report"));
            deleteTableNameList.removeAll(toRemove);
            for(String deleteTableName : deleteTableNameList){
                // 削除する本番DBのTypeの取得
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
                    try{
                        performBatchDelete(deleteTableName,facilityCd,jdbcTemplate,registDbType);
                    }catch (Exception e){
                        EventLogMessage eventLogMessage = eventLoggerUtil.getEventLogMessage("本番DBテーブル削除実行：mnt_motion_record 失敗",
                                facilityCd, "DeleteTableJob.deleteTableInProductionDbStep()");
                        eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.ERROR);
                    }
                    continue;
                }
                // 特殊処理テーブルリストの特殊処理
                // mod　削除条件変更　李　start
                // mod #10418 SQL注入対策：NamedParameterJdbcTemplateを使用してIN句を安全に処理 start
                if(noDeleteTableNameList.contains(deleteTableName) && !userIds.isEmpty()) {

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
                    deleteTableCount++;
                    continue;
                }
                // add 7406  ReMS利用施設をコンバートすると送信先グループマスタや警報通知マスタなどのデータが消えている start
                else if(noDeleteTableNameList.contains(deleteTableName) && userIds.isEmpty())
                {
                    continue;
                }
                // add 7406  ReMS利用施設をコンバートすると送信先グループマスタや警報通知マスタなどのデータが消えている end

                String sql;
                if(isc.hasFacilityCd(deleteTableName)){
                    // 施設コードを保持しているテーブルを削除する
                    // mod 2020-11-27 FNSI-改修内容 ntss.テーブルプレフィックスを追加 う start
                    sql = "delete from " + table_prefix + deleteTableName
                        + " where facility_cd =?";
                    // mod 2020-11-27 FNSI-改修内容 ntss.テーブルプレフィックスを追加 う end
                    // add mst_selectorの処理 limingyang start
                    if (deleteTableName.equals("mst_selector")){
                        List<String> deleteTableNameListU = deleteTableNameList.stream().filter(e -> !noDeleteTableNameList.contains(e)).collect(Collectors.toList());
                        String deleteTableNameListStr = String.join("','", deleteTableNameListU);
                        sql = sql.concat(" and master_physical_name in ('" + deleteTableNameListStr + "')");
                    }
                    // add mst_selectorの処理 limingyang end
                    //ログ
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
                    continue;
                }
                // mod #11302 コンバートの削除処理で処理が進まなくなることがある limingyang start
                try{
                    jdbcTemplate.update(sql, new Object[]{facilityCd});
                }catch (Exception e){
                    eventLoggerUtil.recordLog(facilityCd, eventLoggerUtil.getEventLogMessage("本番DBテーブル削除実行："
                                    + deleteTableName + " 失敗,Error:" + e,
                            facilityCd, "DeleteTableJob.deleteTableInProductionDbStep()"), LogLevel.ERROR);
                }
                // mod #11302 コンバートの削除処理で処理が進まなくなることがある limingyang end
                deleteTableCount++;         
            }
            // 進捗更新
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
            return RepeatStatus.FINISHED;
        }).build();
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
        return jobBuilderFactory.get(JOB_NAME).incrementer(new RunIdIncrementer())
                .start(initialStep())
                .next(getTargetTableNamesStep())
                .next(deleteTableInConvertDbStep.step())
                .next(deleteTableInProductionDbStep())
                .build();
    }

}