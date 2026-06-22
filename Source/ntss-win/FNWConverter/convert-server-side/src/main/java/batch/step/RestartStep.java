package batch.step;

import batch.ApplicationConst;
import batch.listener.StepStartEndListener;
import batch.part.InfomationSchemaControl;
import batch.part.ProgressManagement;
import batch.part.StreamThread;
import com.zaxxer.hikari.HikariDataSource;
import org.springframework.batch.core.step.Step;
import org.springframework.batch.core.step.StepContribution;
import org.springframework.batch.core.step.StepExecution;
import org.springframework.batch.core.repository.JobRepository;
import org.springframework.batch.core.step.builder.StepBuilder;
import org.springframework.batch.core.scope.context.ChunkContext;
import org.springframework.batch.core.step.tasklet.Tasklet;
import org.springframework.batch.infrastructure.repeat.RepeatStatus;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

import java.io.File;
import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import utils.Utils;
import web.config.EventLoggerUtil;
import web.logger.EventLogMessage;
import web.logger.LogLevel;

import javax.sql.DataSource;

/**
 * 再開のみ、前回中断処理続きのステップ
 */
@Component
public class RestartStep extends StepStartEndListener implements Tasklet {

    public static final String STEP_NAME = "RestartStep";

    private static final Logger logger = LoggerFactory.getLogger(StepStartEndListener.class);

    @Autowired
    private JobRepository jobRepository;

    @Autowired
    ProgressManagement progressManagement;

    @Autowired
    private ApplicationContext appContext;

    @Autowired
    Utils utils;

    /**
     * ロギング ツール クラスの導入
     */
    @Autowired
    private EventLoggerUtil eventLoggerUtil;

    @Override
    public RepeatStatus execute(StepContribution contribution,
    ChunkContext chunkContext) throws Exception {
        // RESTART以外の場合、処理なし
        if (chunkContext.getStepContext().getJobParameters().get(ApplicationConst.JobParameterKeys.RESTART) == null)
        {
            return RepeatStatus.FINISHED;
        }

        String inputFilePath = chunkContext.getStepContext().getJobParameters().get(ApplicationConst.JobParameterKeys.INPUT_FILE_PATH)
                .toString();
        // 施設コードを取得
        String facilityCd = chunkContext.getStepContext().getJobParameters().get(ApplicationConst.JobParameterKeys.FACILITY_CD)
                .toString();
        // コンバートDBから本番DBにテーブルデータを登録ファイル
        File fileConvertDbToProductionDbStep = new File(inputFilePath + "/ConvertDbToProductionDbStep.txt");
        // FNWからコンバートDBに登録したテーブルデータを削除ファイル
        File fileTruncateTableStep = new File(inputFilePath + "/TruncateTableStep.txt");
        // 本番DBからコンバートDBにコード変換用のテーブルデータを登録ファイル
        File fileProductionDbToConvertDbStep = new File(inputFilePath + "/ProductionDbToConvertDbStep.txt");

        // 三つファイル全て空の場合、終了しました
        if ((!fileConvertDbToProductionDbStep.exists() ||fileConvertDbToProductionDbStep == null || 0 == fileConvertDbToProductionDbStep.length())
            && (!fileTruncateTableStep.exists() || fileTruncateTableStep == null || 0 == fileTruncateTableStep.length())
            && (!fileProductionDbToConvertDbStep.exists() || fileProductionDbToConvertDbStep == null || 0 == fileProductionDbToConvertDbStep.length())) {
            return RepeatStatus.FINISHED;
        } else {
            processConvertDbToProductionDbFile(fileConvertDbToProductionDbStep, chunkContext, facilityCd);
            processTruncateTableStepFile(fileTruncateTableStep, facilityCd);
            processProductionDbToConvertDbFile(fileProductionDbToConvertDbStep, chunkContext, facilityCd);
        }
        return RepeatStatus.FINISHED;
    }

    /**
     * コンバートDBから本番DBへの登録ファイルを処理する
     */
    private void processConvertDbToProductionDbFile(File fileConvertDbToProductionDbStep, ChunkContext chunkContext,
                                                    String facilityCd) throws Exception {
            // コンバートDBから本番DBにテーブルデータを登録ファイルを行う
            // コンバートDBから本番DBにテーブルデータを登録ファイル 一行目：テープル、二～四行目：sqlCommand
            if (fileConvertDbToProductionDbStep != null && 0 != fileConvertDbToProductionDbStep.length()) {
                List<String> sqlConvertDbToProductionDbStep = utils.readFile(fileConvertDbToProductionDbStep);
                String tableName = sqlConvertDbToProductionDbStep.get(0);
                String[] command = new String[3];
                if( "\\".equals(System.getProperty("file.separator")) ) {
                    command[0] = "cmd.exe";
                    command[1] = "/c";
                } else {
                    command[0] = "sh";
                    command[1] = "-c";
                }
                for (int i = 1; i < sqlConvertDbToProductionDbStep.size(); i++) {
                    command[2] = sqlConvertDbToProductionDbStep.get(i);
                    this.runCommand(command, chunkContext, tableName, facilityCd);
                }
                // ファイル削除
                fileConvertDbToProductionDbStep.delete();
            }
    }

    /**
     * TruncateTableStepファイルを処理する
     */
    private void processTruncateTableStepFile(File fileTruncateTableStep, String facilityCd) throws Exception {
            // コンバートDBから本番DBにテーブルデータを登録ファイルを行う
            // コンバートDBから本番DBにテーブルデータを登録ファイル 一行目：削除sql
            if (fileTruncateTableStep != null && 0 != fileTruncateTableStep.length()) {
                List<String> sqlfileTruncateTableStep = utils.readFile(fileTruncateTableStep);
                DataSource ds = (DataSource) appContext.getBean(ApplicationConst.DbType.CONVERT);
                JdbcTemplate jdbcTemplate = new JdbcTemplate(ds);
                jdbcTemplate.execute(sqlfileTruncateTableStep.get(0));
                logger.info("コンバートDB→本番DB登録後テーブルデータ削除実行：" + sqlfileTruncateTableStep.get(0));
                //ログ
                EventLogMessage eventLogMessage4 = eventLoggerUtil.getEventLogMessage("コンバートDB→本番DB登録後テーブルデータ削除実行：" + sqlfileTruncateTableStep.get(0),
                        facilityCd, "execute(StepContribution contribution, ChunkContext chunkContext)");
                eventLoggerUtil.recordLog(facilityCd, eventLogMessage4, LogLevel.INFO);
                // ファイル削除
                fileTruncateTableStep.delete();
            }
    }

    /**
     * 本番DBからコンバートDBへの登録ファイルを処理する
     */
    private void processProductionDbToConvertDbFile(File fileProductionDbToConvertDbStep, ChunkContext chunkContext,
                                                    String facilityCd) throws Exception {
            // コンバートDBから本番DBにテーブルデータを登録ファイルを行う
            // 本番DBからコンバートDBにテーブルデータを登録ファイル 一行目：テープル、二～四行目：sqlCommand
            if (fileProductionDbToConvertDbStep != null && 0 != fileProductionDbToConvertDbStep.length()) {
                List<String> sqlProductionDbToConvertDbStep = utils.readFile(fileProductionDbToConvertDbStep);
                String tableName = sqlProductionDbToConvertDbStep.get(0);
                String[] command = new String[3];
                if ("\\".equals(System.getProperty("file.separator")) ) {
                    command[0] = "cmd.exe";
                    command[1] = "/c";
                } else {
                    command[0] = "sh";
                    command[1] = "-c";
                }
                for(int i = 1; i < sqlProductionDbToConvertDbStep.size(); i++) {
                    command[2] = sqlProductionDbToConvertDbStep.get(i);
                    this.runCommand(command, chunkContext, tableName, facilityCd);
                }
            resetSequenceForTable(tableName);
            // ファイル削除
            fileProductionDbToConvertDbStep.delete();
        }
    }

    /**
     * テーブルのシーケンスをリセットする
     */
    private void resetSequenceForTable(String tableName) throws Exception {
                // コンバートDBに対応するデータソースの取得
                HikariDataSource convertDs = (HikariDataSource) appContext.getBean(ApplicationConst.DbType.CONVERT);
                // 取得テーブルの列を取得
                InfomationSchemaControl isc = new InfomationSchemaControl(appContext);
                List<String> columnNameList = isc.getColumnNamesForCodeConversion(tableName);
                // シーケンスのリセット
                JdbcTemplate jdbcTemplate = new JdbcTemplate(convertDs);

                // SQLインジェクション対策：tableNameが安全な文字のみを含むことを検証
                if (!tableName.matches("^[a-zA-Z0-9_]+$")) {
                    throw new IllegalArgumentException("安全でないtableName値: " + tableName);
                }

                // シーケンス名取得 - SQLインジェクション対策：パラメータ化クエリを使用
                String sql = "SELECT\n" +
                        "    column_default \n" +
                        "FROM\n" +
                        "    information_schema.columns \n" +
                        "WHERE\n" +
                        "    table_name = lower(?) \n" +
                        "    and column_default like 'nextval%'";
                List<String> list = jdbcTemplate.queryForList(sql, String.class, tableName);
                String seq_name = null;
                if (null != list && !list.isEmpty()) {
                    seq_name = list.get(0).split("\'")[1];

                    // SQLインジェクション対策：seq_nameが安全な文字のみを含むことを検証
                    if (!seq_name.matches("^[a-zA-Z0-9_]+$")) {
                        throw new IllegalArgumentException("安全でない seq_name 値: " + seq_name);
                    }

                    // シーケンス変更
                    String columnName;
                    if ("mst_machine".equals(tableName)) {
                        columnName = columnNameList.get(4);
                    } else {
                        columnName = columnNameList.get(0);
                    }

                    // SQLインジェクション対策：カラム名が安全な文字のみを含むことを検証
                    if (!columnName.matches("^[a-zA-Z0-9_]+$")) {
                        throw new IllegalArgumentException("安全でない列名: " + columnName);
                    }

                    // 注意：カラム名とテーブル名は?でパラメータ化できないため連結が必要だが、安全性は検証済み
                    sql = "select max(" + columnName + ") from " + tableName;
                    List<Long> seq_list = jdbcTemplate.queryForList(sql, Long.class);
                    if (null != seq_list && null != seq_list.get(0)) {
                        // 注意：シーケンス名は?でパラメータ化できないため連結が必要だが、安全性は検証済み
                        sql = "alter sequence " + seq_name + " restart with " + (seq_list.get(0).longValue() + 1);
                        jdbcTemplate.execute(sql);
            }
        }
    }

    /**
     * 前回コピーコマンド実行
     * @param command　command文
     * @param chunkContext　chunkContext
     * @param tableName　テープル
     * @param facilityCd　facilityCd
     *
     * @return
     */
    public void runCommand(String[] command, ChunkContext chunkContext, String tableName, String facilityCd)throws Exception{
        StepExecution se = chunkContext.getStepContext().getStepExecution();
        Runtime runtime = Runtime.getRuntime();
        logger.info("前回コピーコマンド実行：" + command[2]);
        //ログ
        EventLogMessage eventLogMessage4 = eventLoggerUtil.getEventLogMessage("コピーコマンド実行：" + command[2],
                facilityCd, "execute(StepContribution contribution, ChunkContext chunkContext)");
        eventLoggerUtil.recordLog(facilityCd, eventLogMessage4, LogLevel.INFO);
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
            progressManagement.createConvertTableStatus(se, "前回Copyコマンド異常終了：処理テーブル：" + tableName);
            String errorMsg = "前回Copyコマンド異常終了\n" + ",「command」:" + String.join(" ",command) + ",「ERROR」:" + et.getOutputString();
            EventLogMessage eventLogMessageErr = eventLoggerUtil.getEventLogMessage(errorMsg,
                    facilityCd, "RestartStep->runCommand");
            eventLoggerUtil.recordLog(facilityCd, eventLogMessageErr, LogLevel.ERROR);
            throw new RuntimeException(errorMsg);
        } else {
            //ログ
            eventLogMessage4 = eventLoggerUtil.getEventLogMessage("コピーコマンド実行：" + command[2],
                    facilityCd, "execute(StepContribution contribution, ChunkContext chunkContext)");
            eventLoggerUtil.recordLog(facilityCd, eventLogMessage4, LogLevel.INFO);
            logger.info("前回Copyコマンド正常終了");
            // テーブル毎の進捗更新
            progressManagement.createConvertTableStatus(se, "前回Copyコマンド正常終了：処理テーブル：" + tableName );
        }
    }
    @Bean(name=STEP_NAME)
    public Step step() {
        return new StepBuilder(STEP_NAME, jobRepository)
            .tasklet(this)
            .build();
    }
}