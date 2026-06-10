package batch.step;

import java.util.Arrays;
import java.util.List;

import batch.ApplicationConst;
import batch.ApplicationConst.JobParameterKeys;
import batch.config.ConvertPriorityConfig;
import batch.listener.StepStartEndListener;
import batch.part.InfomationSchemaControl;
import batch.part.ProgressManagement;
import batch.part.PsqlCopyUtils;
import batch.part.StreamThread;
import batch.part.TableNameToDbType;
import com.zaxxer.hikari.HikariDataSource;
import org.springframework.batch.core.Step;
import org.springframework.batch.core.StepContribution;
import org.springframework.batch.core.StepExecution;
import org.springframework.batch.core.configuration.annotation.StepBuilderFactory;
import org.springframework.batch.core.scope.context.ChunkContext;
import org.springframework.batch.core.step.tasklet.Tasklet;
import org.springframework.batch.repeat.RepeatStatus;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.context.ApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.core.env.Environment;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

import utils.Utils;
import web.config.EventLoggerUtil;
import web.logger.EventLogMessage;
import web.logger.LogLevel;

/**
 * コンバートDBの処理対象テーブルを全削除するステップ
 */
@Component
public class DeleteTableInConvertDbStep extends StepStartEndListener implements Tasklet {

    public static final String STEP_NAME = "DeleteTableInConvertDbStep";

    @Autowired
    StepBuilderFactory stepBuilderFactory;

    @Autowired
    ConvertPriorityConfig convertPriorityConfig;

    @Autowired
    ApplicationContext appContext;

    @Autowired
    Utils utils;

    // add #7339 AWS側アプリが起動しない途中から開始されない yangmj start
    @Autowired
    ProgressManagement progressManagement;
    @Autowired
    private PsqlCopyUtils psqlCopyUtils;
    @Autowired
    private Environment environment;
    // add #7339 AWS側アプリが起動しない途中から開始されない yangmj end

    /**
     * ロギング ツール クラスの導入
     */
    @Autowired
    private EventLoggerUtil eventLoggerUtil;

    @Autowired
    @Qualifier("jdbcTemplateConvert")
    private JdbcTemplate jdbcTemplateConvert;

    @Override
    public RepeatStatus execute(StepContribution contribution,
                                ChunkContext chunkContext) throws Exception {
        // 削除対象の施設コードの取得
        String facilityCd = chunkContext.getStepContext().getJobParameters().get(JobParameterKeys.FACILITY_CD).toString();
        // 削除対象のテーブル名の取得
        List<String> deleteTableNameList = convertPriorityConfig.getTableNames();
        // 追加処理テーブル
        if (!deleteTableNameList.contains("mst_pat_event_data_template")) {
            deleteTableNameList.add("mst_pat_event_data_template");
		}
        // add FNSI_複数施設修正 楊 start
        InfomationSchemaControl isc = new InfomationSchemaControl(appContext);
        // add FNSI_複数施設修正 楊 end
        // add #7339 AWS側アプリが起動しない途中から開始されない yangmj start
        // 削除対象のjobの取得
        String job = chunkContext.getStepContext().getJobName();
        // 本番dbから或は、コンバートdb削除の場合
        if (job.equals("DeleteTableJob") || job.equals("DeleteConvertTableJob")) {
            // mst_device_edgeを追加
            if (!deleteTableNameList.contains("mst_device_edge")) {
                deleteTableNameList.add("mst_device_edge");
            }
            //6886 zc start
            if (!deleteTableNameList.contains("pat_personal_main_history")) {
                deleteTableNameList.add("pat_personal_main_history");
            }
            if (!deleteTableNameList.contains("pat_group_detail_history")) {
                deleteTableNameList.add("pat_group_detail_history");
            }
            if (!deleteTableNameList.contains("pat_insurance_history")) {
                deleteTableNameList.add("pat_insurance_history");
            }
            if (!deleteTableNameList.contains("pat_main_history")) {
                deleteTableNameList.add("pat_main_history");
            }
            if (!deleteTableNameList.contains("pat_unique_history")) {
                deleteTableNameList.add("pat_unique_history");
            }
            //6886 zc end
            //10676 zc start
            if(!deleteTableNameList.contains("ord_main_restore")) {
                deleteTableNameList.add("ord_main_restore");
            }
            //10676 zc end
            // add #10859-6 djy start
            if (!deleteTableNameList.contains("batch_convert_status")) {
                deleteTableNameList.add("batch_convert_status");
            }
            if (!deleteTableNameList.contains("batch_convert_table_status")) {
                deleteTableNameList.add("batch_convert_table_status");
            }
            // add #10859-6 djy end
            // add #7339 AWS側アプリが起動しない途中から開始されない yangmj end
            for (String deleteTableName : deleteTableNameList) {
                // mod FNSI_複数施設修正 楊 start
                // 施設マスタを削除対象から外す
                if ("mst_facility".equals(deleteTableName)) {
                    continue;
                }
                String sql;
                if (isc.hasFacilityCd(deleteTableName)) {
                    // 施設コードを保持しているテーブルを削除する
                    sql = "delete from " + deleteTableName + " where facility_cd=?";
                } else {
                    // Truncateは実施しない方針
                    sql = "truncate table " + deleteTableName + " cascade";
                }
                // mod FNSI_複数施設修正 楊 end
                // add #10859-6 djy start
                if("batch_convert_status".equals(deleteTableName)||"batch_convert_table_status".equals(deleteTableName)){
                    sql += " and job_instance_id <> "+ chunkContext.getStepContext().getStepExecution().getJobExecution().getJobInstance().getInstanceId();
                }
                // add #10859-6 djy end
                jdbcTemplateConvert.update(sql, new Object[]{facilityCd});
                //ログ
                EventLogMessage eventLogMessage5 = eventLoggerUtil.getEventLogMessage("コンバートDBテーブル削除実行：" + facilityCd + ":" + sql,
                        facilityCd, "execute(StepContribution contribution, ChunkContext chunkContext)");
                eventLoggerUtil.recordLog(facilityCd, eventLogMessage5, LogLevel.INFO);
            }
            // add FNSI_複数施設修正 楊 start
            // mod #10418 SQL注入対策：パラメータバインディング start
            if (deleteTableNameList.contains("mst_facility")) {
                String sql = "delete from mst_facility where facility_cd = ?";
                jdbcTemplateConvert.update(sql, new Object[]{facilityCd});
                //ログ
                EventLogMessage eventLogMessage5 = eventLoggerUtil.getEventLogMessage("コンバートDBテーブル削除実行：" + facilityCd + ":" + sql,
                        facilityCd, "execute(StepContribution contribution, ChunkContext chunkContext)");
                eventLoggerUtil.recordLog(facilityCd, eventLogMessage5, LogLevel.INFO);
            }
            // mod #10418 SQL注入対策：パラメータバインディング end
            // add FNSI_複数施設修正 楊 end
            // add #7339 AWS側アプリが起動しない途中から開始されない yangmj start
        } else {
            // 本番dbから、コンバートdbに変換用テーブルデータとコンバートテーブルをコピー
            // 施設コードより、mst_facilityからレコードを取得
            // mod #10418 SQL注入対策：パラメータバインディング start
            String sqlMstFacility = "select count(facility_cd) from mst_facility where facility_cd = ?";
            int count =  jdbcTemplateConvert.queryForObject(sqlMstFacility, new Object[]{facilityCd}, Integer.class);
            // mod #10418 SQL注入対策：パラメータバインディング end
            // 該当施設コードなしの場合、初回とする。
            if (count == 0) {
                // 本番dbから、コンバートdbに変換用テーブルデータとコンバートテーブルをコピー
                this.productionDbToConvertDb(deleteTableNameList, facilityCd, chunkContext);
            }
            // add #11399 djy start
            else{
                this.CopyMstToConvertDb(facilityCd, chunkContext);
            }
            // add #11399 djy end
        }
        return RepeatStatus.FINISHED;
    }

    @Bean(name=STEP_NAME)
    public Step step() {
        return stepBuilderFactory.get(STEP_NAME)
                .tasklet(this)
                .build();
    }

    /**
     * 本番DBからコンバートDBにコード変換用のテーブルデータを登録する
     * @param deleteTableNameList 変換用テーブルデータとコンバートテーブル
     * @param facilityCd 施設コード
     * @param chunkContext ChunkContext
     */
    private void productionDbToConvertDb(List<String> deleteTableNameList, String facilityCd, ChunkContext chunkContext) throws Exception {
        // 初回削除要テーブルリスト
        List<String> deleteTableList = Arrays.asList("mni_monitor", "mnt_motion_record");
        // mst_device_edgeを追加
        if (!deleteTableNameList.contains("mst_device_edge")) {
            deleteTableNameList.add("mst_device_edge");
        }

        // add #11302 コンバートの削除処理で処理が進まなくなることがある limingyang start
        deleteTableNameList.remove(ApplicationConst.TableName.MNT_NOTIFICATION_STATUS);
        deleteTableNameList.remove(ApplicationConst.TableName.MNT_NOTIFICATION_MESSAGE);
        // add #11302 コンバートの削除処理で処理が進まなくなることがある limingyang end
        for (String tableName : deleteTableNameList) {
            StepExecution se = chunkContext.getStepContext().getStepExecution();
            // 本番DBのDBTypeの取得（テーブルが存在するDBを検索して取得）
            TableNameToDbType tableNameToDbType = new TableNameToDbType(appContext);
            String productionDbType = tableNameToDbType.getDbTypeByTableName(tableName);
            // 本番DBのDBTypeに対応するデータソースの取得
            HikariDataSource productionDs = (HikariDataSource) appContext.getBean(productionDbType);
            // 取得テーブルの列を取得
            InfomationSchemaControl isc = new InfomationSchemaControl(appContext);
            List<String> columnNameList = isc.getColumnNamesForCodeConversion(tableName);
            // mni_monitorとmnt_motion_recordの場合、本番DBに該当テープルを削除
            // mod #10418 SQL注入対策：パラメータバインディング start
            if (deleteTableList.contains(tableName)) {
                String userName = environment.getProperty("datasource." + ApplicationConst.DbType.CONVERT + ".username");
                String table_prefix = environment.getProperty(userName + "_prefix");
                String sql = " delete from " + table_prefix + tableName;
                JdbcTemplate jdbcTemplate = new JdbcTemplate(productionDs);
                if (columnNameList.contains("facility_cd")) {
                    sql += " where facility_cd = ?";
                    jdbcTemplate.update(sql, new Object[]{facilityCd});
                } else {
                    jdbcTemplate.execute(sql);
                }
            }
            // #11998 add 新たに発見された問題の対応: fn_comsv_noフィールドはconvert_dbにのみ存在するため、copy from prod_db to convert_dbの際には、このフィールドの情報を削除する必要があります。 start
            if(tableName.equals("mst_comsv_setting")){
                columnNameList.remove("fn_comsv_no");
            }
            // #11998 add 新たに発見された問題の対応: fn_comsv_noフィールドはconvert_dbにのみ存在するため、copy from prod_db to convert_dbの際には、このフィールドの情報を削除する必要があります。 end
            // mod #10418 SQL注入対策：パラメータバインディング end
            // 実行するコピーコマンドの組み立て
            String inputFilePath = chunkContext.getStepContext().getJobParameters().get(JobParameterKeys.INPUT_FILE_PATH).toString();
            String[] command = psqlCopyUtils.createCopyCommand(inputFilePath,tableName, columnNameList, facilityCd, productionDbType, 1);
            // システムコール
            Runtime runtime = Runtime.getRuntime();
            EventLogMessage eventLogMessage = eventLoggerUtil.getEventLogMessage("初回コピーコマンド実行：" + command[2],
                    facilityCd, "execute(StepContribution contribution, ChunkContext chunkContext)");
            eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.INFO);
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
                // テーブル毎の進捗更新
                progressManagement.createConvertTableStatus(se, "初回Copyコマンド異常終了：処理テーブル：" + tableName);
                String errorMsg = "初回Copyコマンド異常終了\n" + ",「command」:" + String.join(" ", command) + ",「ERROR」:" + et.getOutputString();
                EventLogMessage eventLogMessageErr = eventLoggerUtil.getEventLogMessage(errorMsg,
                        facilityCd, "DeleteTableInConvertDbStep->ProductionDbToConvertDb");
                eventLoggerUtil.recordLog(facilityCd, eventLogMessageErr, LogLevel.ERROR);
                throw new RuntimeException(errorMsg);
            }
        }
    }

    // add #7339 AWS側アプリが起動しない途中から開始されない yangmj end
    // add #11399 djy start
    private void CopyMstToConvertDb(String facilityCd, ChunkContext chunkContext) throws Exception {
        String inputFilePath = chunkContext.getStepContext().getStepExecution().getJobExecution().getJobParameters().getString(JobParameterKeys.INPUT_FILE_PATH);
        List<String> deleteTableList = Arrays.asList("mst_device_edge");
        // mst_device_edgeを追加
        for (String tableName : deleteTableList) {
            StepExecution se = chunkContext.getStepContext().getStepExecution();
            // 本番DBのDBTypeの取得（テーブルが存在するDBを検索して取得）
            TableNameToDbType tableNameToDbType = new TableNameToDbType(appContext);
            String productionDbType = tableNameToDbType.getDbTypeByTableName(tableName);
            // 取得テーブルの列を取得
            InfomationSchemaControl isc = new InfomationSchemaControl(appContext);
            List<String> columnNameList = isc.getColumnNamesForCodeConversion(tableName);
            String userName = environment.getProperty("datasource." + ApplicationConst.DbType.CONVERT + ".username");
            String table_prefix = environment.getProperty(userName+ "_prefix");
            String delsql = " delete from " + table_prefix + tableName;
            // SQL Injection protection: escape single quotes for psql script context
            if (columnNameList.contains("facility_cd")) {
                String safeFacilityCd = facilityCd.replace("'", "''");
                delsql += " where facility_cd = '" + safeFacilityCd + "'";
            }


            String[] command = psqlCopyUtils.createDelCopyCommandByCond(inputFilePath, tableName, productionDbType,
                    ApplicationConst.DbType.CONVERT, isc.getColumnNamesForCodeConversion(tableName), facilityCd, "", delsql);


            // システムコール
            Runtime runtime = Runtime.getRuntime();
            EventLogMessage eventLogMessage = eventLoggerUtil.getEventLogMessage("初回コピーコマンド実行：" + String.join(" ", command),
                    facilityCd, "execute(StepContribution contribution, ChunkContext chunkContext)");
            eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.INFO);
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
                // テーブル毎の進捗更新
                progressManagement.createConvertTableStatus(se, "初回Copyコマンド異常終了：処理テーブル：" + tableName);
                String errorMsg = "初回Copyコマンド異常終了\n" + ",「command」:" + String.join(" ", command) + ",「ERROR」:" + et.getOutputString();
                EventLogMessage eventLogMessageErr = eventLoggerUtil.getEventLogMessage(errorMsg,
                        facilityCd, "DeleteTableInConvertDbStep->CopyMstToConvertDb");
                eventLoggerUtil.recordLog(facilityCd, eventLogMessageErr, LogLevel.ERROR);
                throw new RuntimeException(errorMsg);
            }
        }
    }
    // add #11399 djy end
}
