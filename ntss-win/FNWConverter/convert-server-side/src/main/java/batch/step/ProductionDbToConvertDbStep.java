package batch.step;

import batch.ApplicationConst;
import batch.ApplicationConst.JobParameterKeys;
import batch.config.ConvertKeyConfig;
import batch.listener.JobStartEndLIstener;
import batch.listener.PromotionListener;
import batch.listener.StepStartEndListener;
import batch.part.InfomationSchemaControl;
import batch.part.ProgressManagement;
import batch.part.PsqlCopyUtils;
import batch.part.StreamThread;
import batch.part.TableNameToDbType;
import java.io.File;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.springframework.batch.core.step.Step;
import org.springframework.batch.core.step.StepContribution;
import org.springframework.batch.core.step.StepExecution;
import org.springframework.batch.core.repository.JobRepository;
import org.springframework.batch.core.step.builder.StepBuilder;
import org.springframework.batch.core.scope.context.ChunkContext;
import org.springframework.batch.core.step.tasklet.Tasklet;
import org.springframework.batch.infrastructure.repeat.RepeatStatus;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.context.ApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Component;
import org.springframework.util.ObjectUtils;
import utils.BbsInfoService;
import utils.GlobalContext;
import utils.Utils;
import web.config.EventLoggerUtil;
import web.logger.EventLogMessage;
import web.logger.LogLevel;

/**
 * 本番DBからコンバートDBにコード変換用のテーブルデータを登録するTaskletStep
 */
@Component
public class ProductionDbToConvertDbStep extends StepStartEndListener implements Tasklet {

    public static final String STEP_NAME = "ProductionDbToConvertDbStep";


    @Autowired
    private ApplicationContext appContext;

    @Autowired
    private JobRepository jobRepository;

    @Autowired
	ProgressManagement progressManagement;

    @Autowired
    private PsqlCopyUtils psqlCopyUtils;

    /**
     * ロギング ツール クラスの導入
     */
    @Autowired
    private EventLoggerUtil eventLoggerUtil;

    // add 7853-差分コンバートで更新/削除ができない 楊  start
    @Autowired
    private ConvertKeyConfig convertKeyConfig;

    // add #9801 zl start
    @Autowired
    private BbsInfoService bbsInfoService;
    // add #9801 zl end


    @Autowired
    Utils utils;
    // add 7853-差分コンバートで更新/削除ができない 楊 end

    @Autowired
    @Qualifier("jdbcTemplateConvert")
    private JdbcTemplate jdbcTemplateConvert;

    @Autowired
    @Qualifier("namedParameterJdbcTemplateConvert")
    private NamedParameterJdbcTemplate namedParameterJdbcTemplateConvert;

    @Autowired
    @Qualifier(ApplicationConst.JdbcTempleteName.NAMED_PARAMETER_JDBCTEMPLATE_NKK5)
    private NamedParameterJdbcTemplate namedParameterJdbcTemplateNkk5;


    @Override
    public RepeatStatus execute(StepContribution contribution, ChunkContext chunkContext) throws Exception {

        GlobalContext globalContext = JobStartEndLIstener.getGlobalContext();
        StepExecution se = chunkContext.getStepContext().getStepExecution();
        // 施設コードを取得
        String facilityCd = chunkContext.getStepContext().getJobParameters().get(JobParameterKeys.FACILITY_CD).toString();
        // 処理対象ファイル名からテーブル名の取得
        String nextProcessingFile = chunkContext.getStepContext().getJobExecutionContext().get(ApplicationConst.PromotionKeys.NEXT_PROCESSING_FILE).toString();
        String inputFilePath = chunkContext.getStepContext().getJobParameters().get(JobParameterKeys.INPUT_FILE_PATH).toString();
        //7341 mni _monitorテーブルとmnt_motion_recordテーブ
        RepeatStatus earlyExitStatus = executeCheckEarlyExit(nextProcessingFile);
        if (earlyExitStatus != null) {
            return earlyExitStatus;
        }
        // add 7853-差分コンバートで更新/削除ができない 楊 start
        int diff = nextProcessingFile.indexOf("[diff]");

        executeUploadBbsInfoIfNeeded(nextProcessingFile, inputFilePath, facilityCd, chunkContext, globalContext);

        //mod 2022-04-01   判断条件の修正  鄭  start
        int indexFile = nextProcessingFile.indexOf("indicatorShoe");
        //mod 2022-04-01   判断条件の修正  鄭  end
        if (indexFile != -1) {
            return RepeatStatus.FINISHED;
        } else {
            return executeMainTableConvert(se, nextProcessingFile, inputFilePath, facilityCd, chunkContext, diff);
        }
    }

    // mnt_motion_record等の早期終了判定
    private RepeatStatus executeCheckEarlyExit(String nextProcessingFile) {
        if (!ObjectUtils.isEmpty(nextProcessingFile)) {
            if (nextProcessingFile.contains("mnt_motion_record")) {
                return RepeatStatus.FINISHED;
            }
        }
        return null;
    }

    // bbs_infoテーブルのS3ファイルアップロード処理
    private void executeUploadBbsInfoIfNeeded(String nextProcessingFile, String inputFilePath, String facilityCd,
                                              ChunkContext chunkContext, GlobalContext globalContext) {
        //add #9801 zl start
        if ("bbs_info".equals(psqlCopyUtils.getTableName(nextProcessingFile))) {
            //ログ
            EventLogMessage eventLogMessageS3_1 = eventLoggerUtil.getEventLogMessage("S3ファイルアップロード実行",
                    facilityCd, "execute(StepContribution contribution, ChunkContext chunkContext)");
            eventLoggerUtil.recordLog(facilityCd, eventLogMessageS3_1, LogLevel.INFO);

            Path basePath = Paths.get(chunkContext.getStepContext().getJobParameters().get(JobParameterKeys.INPUT_FILE_PATH).toString());
            String upResult = bbsInfoService.UploadEventAddedFiles(facilityCd,
                    Paths.get(nextProcessingFile).toString(), basePath.toString(), "AddedFiles", globalContext.sqlKeys, globalContext.sqlNewKeys);

            //ログ
            String upResultMessage = "S3ファイルアップロード正常終了";
            if (!BbsInfoService.STOP_STATUS.NORMAL.equals(upResult)) {
                upResultMessage = "S3ファイルアップロード異常終了";
            }
            EventLogMessage eventLogMessageS3_2 = eventLoggerUtil.getEventLogMessage(upResultMessage,
                    facilityCd, "execute(StepContribution contribution, ChunkContext chunkContext)");
            eventLoggerUtil.recordLog(facilityCd, eventLogMessageS3_2, LogLevel.INFO);
        }
        //add #9801 zl end

    }

    // テーブル毎の初回/差分コンバート本処理
    private RepeatStatus executeMainTableConvert(StepExecution se, String nextProcessingFile, String inputFilePath,
                                                 String facilityCd, ChunkContext chunkContext, int diff) throws Exception {
            // mod 7853-差分コンバートで更新/削除ができない 楊 start
            String tableName = PsqlCopyUtils.getTableName(nextProcessingFile);
            // mod 10378-24-4 PatTreatmentPattern再構築対応 zkm start
            if(utils.DiffNotCopyDbToConvert.contains(tableName) || utils.ConvertNotData.contains(tableName) ){
                return RepeatStatus.FINISHED;
            }
            // mod 10378-24-4 PatTreatmentPattern再構築対応 zkm end

            // 本番DBのDBTypeの取得（テーブルが存在するDBを検索して取得）
            TableNameToDbType tableNameToDbType = new TableNameToDbType(appContext);
            String productionDbType = tableNameToDbType.getDbTypeByTableName(tableName);
            // mod  7853-差分コンバートで更新/削除ができない 楊 start
            // 初回コンバートの場合
            if (diff == -1) {
                RepeatStatus repeatStatus = firstConvert(tableName,facilityCd,chunkContext);
                if (repeatStatus != null) {
                    return repeatStatus;
                }
            } else { // 差分コンバートの場合
                RepeatStatus repeatStatus = diffConvert(inputFilePath, tableName, facilityCd, chunkContext, productionDbType);
                if (repeatStatus != null) {
                    return repeatStatus;
                }
            }
            //ログ
            EventLogMessage eventLogMessage = eventLoggerUtil.getEventLogMessage("Copyコマンド(本番-convert_db)正常終了：処理テーブル：" + tableName,
                    facilityCd, "execute(StepContribution contribution, ChunkContext chunkContext)");
            eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.INFO);
            // テーブル毎の進捗更新
            progressManagement.createConvertTableStatus(se, "Copyコマンド正常終了：処理テーブル：" + tableName);
            return RepeatStatus.FINISHED;
        }

    /**
     * 初回コンバートの場合
     * @param tableName
     * @param facilityCd
     * @param chunkContext
     * @return RepeatStatus
     * @throws Exception
     */
    private RepeatStatus firstConvert(String tableName, String facilityCd, ChunkContext chunkContext) throws Exception {
        GlobalContext globalContext = JobStartEndLIstener.getGlobalContext();
        RepeatStatus skipStatus = firstConvertCheckSkip(tableName, globalContext);
        if (skipStatus != null) {
            return skipStatus;
        }
        String inputePath = chunkContext.getStepContext().getJobParameters().get(ApplicationConst.JobParameterKeys.INPUT_FILE_PATH)
                .toString();
        // sqlファイルから、コピーsqlを取得する
        File fileProductionDbToConvertDb = new File(inputePath + "/ProductionDbToConvertDbStep.txt");
        // 本番DBからコンバートDBにcopyCommandファイルを削除 一行目：テープル、二～四行目：sqlCommand
        if (fileProductionDbToConvertDb.exists() && 0 != fileProductionDbToConvertDb.length()) {
            firstConvertRunCopyCommands(fileProductionDbToConvertDb, chunkContext, tableName, facilityCd);
            firstConvertUpdateComsvSetting(globalContext, facilityCd);

        } else {
            return RepeatStatus.FINISHED;
        }
        return null;
    }

    // 初回コンバートのスキップ条件判定
    private RepeatStatus firstConvertCheckSkip(String tableName, GlobalContext globalContext) {
        String cols = convertKeyConfig.getConvertKey(tableName);
        if (cols == null || cols.trim().isEmpty()) {
            cols = convertKeyConfig.getConvertbKey(tableName);
        }
        String[] names = cols.split(",");
        // mod 8309 【デグレ】FNWデモ環境からコンバートするツールがエラーで停止する 楊 start
        if (names != null && names.length > 0 && (!names[0].isEmpty()) && "facility_cd".equals(names[1].trim())) {
            // mod 8309 【デグレ】FNWデモ環境からコンバートするツールがエラーで停止する 楊 end
            return RepeatStatus.FINISHED;
        }
        if (globalContext.insFnValue.isEmpty() && globalContext.seqRegist == -1) {
            return RepeatStatus.FINISHED;
        }
        return null;
    }

    // 初回コンバートのコピーコマンド実行
    private void firstConvertRunCopyCommands(File fileProductionDbToConvertDb, ChunkContext chunkContext,
                                             String tableName, String facilityCd) throws Exception {
            List<String> sqlProductionDbToConvertDb = utils.readFile(fileProductionDbToConvertDb);
            String[] command = new String[3];
            if( "\\".equals(System.getProperty("file.separator")) ) {
                command[0] = "cmd.exe";
                command[1] = "/c";
            } else {
                command[0] = "sh";
                command[1] = "-c";
            }
            for(int i = 1; i < sqlProductionDbToConvertDb.size(); i++) {
                command[2] = sqlProductionDbToConvertDb.get(i);
                this.runCommand(command, chunkContext, tableName, facilityCd);
            }
            // copyCommandファイルを削除
            fileProductionDbToConvertDb.delete();
    }

    // 初回コンバート後のmst_comsv_setting更新
    private void firstConvertUpdateComsvSetting(GlobalContext globalContext, String facilityCd) {
            // add #12230 差分コンバートにより元に戻ってしまう項目がある limingzhe start
            if (!globalContext.convertComsvList.isEmpty()) {
                String comsv_setting_sql = "select convert_id,device_edge_no from mst_comsv_setting where facility_cd= ? order by device_edge_no";
                List<Map<String, Object>> comsv_setting_info = jdbcTemplateConvert.queryForList(comsv_setting_sql, new Object[]{facilityCd});
                if (comsv_setting_info != null && !comsv_setting_info.isEmpty()) {
                    for (String key : globalContext.convertComsvList) {
                        String[] keyArr = key.split(",");
                        if(keyArr.length > 1){
                            List<Map<String, Object>> update_setting_info = comsv_setting_info.stream()
                                    .filter(p -> String.valueOf(p.get("device_edge_no")).equals(keyArr[0]))
                                    .collect(Collectors.toList());
                            for (Map<String, Object> map : update_setting_info){
                                // mod #10418 SQL Injection protection by shiyw 2025-12-17 start
                                // 文字列の連結を回避するには、パラメータ プレースホルダ (?) を使用します。
                                String updateSql = "UPDATE mst_comsv_setting " +
                                        "SET fn_comsv_no = ? " +
                                        "WHERE facility_cd = ? AND convert_id = ?";

                                // fn_comsv_no :（numeric(10,0) → Java Long）
                                Object fnComsvNoObj = keyArr[1];
                                Long fnComsvNo;
                                try {
                                    fnComsvNo = ( fnComsvNoObj == null || "null".equals(fnComsvNoObj) ) ? null : Long.valueOf(fnComsvNoObj.toString());
                                } catch (NumberFormatException e) {
                                    throw new IllegalArgumentException("fn_comsv_no は有効な数値である必要があります: " + fnComsvNoObj, e);
                                }

                                // convert_id : (int8 → Java Long)
                                Object comsvCdObj = map.get("convert_id");
                                Long comsvCd;
                                try {
                                    comsvCd = ( comsvCdObj == null || "null".equals(comsvCdObj) ) ? null : Long.valueOf(comsvCdObj.toString());
                                } catch (NumberFormatException | NullPointerException e) {
                                    throw new IllegalArgumentException("convert_id は有効な整数である必要があります。: " + comsvCdObj, e);
                                }

                                // 安全なパラメータ化された更新を実行する
                                jdbcTemplateConvert.update(updateSql, fnComsvNo, facilityCd, comsvCd);
                                // mod #10418 SQL Injection protection by shiyw 2025-12-17 end
                            }
                        }
                    }
                }
            }
            // add #12230 差分コンバートにより元に戻ってしまう項目がある limingzhe end
    }

    /**
     * 差分コンバートの場合
     * @param tableName
     * @param facilityCd
     * @param chunkContext
     * @param productionDbType
     * @return
     * @throws Exception
     */
    private RepeatStatus diffConvert(String inputFilePath, String tableName, String facilityCd, ChunkContext chunkContext, String productionDbType) throws Exception {
        GlobalContext globalContext = JobStartEndLIstener.getGlobalContext();
        // 取得テーブルの列を取得
        InfomationSchemaControl isc = new InfomationSchemaControl(appContext);
        List<String> columnNameList = isc.getColumnNamesForCodeConversion(tableName);
        String cols = convertKeyConfig.getConvertKey(tableName);
        if (cols == null || cols.trim().isEmpty()) {
            cols = convertKeyConfig.getConvertbKey(tableName);
        }
        String[] names = cols.split(",");
        RepeatStatus skipStatus = diffConvertCheckSkipTable(tableName);
        if (skipStatus != null) {
            return skipStatus;
        }
        diffConvertCopyNewKeys(inputFilePath, tableName, facilityCd, chunkContext, productionDbType, columnNameList, names, globalContext);
        diffConvertCopyDisNoKeys(inputFilePath, tableName, facilityCd, chunkContext, productionDbType, columnNameList, globalContext);
        RepeatStatus updateSkipStatus = diffConvertCopyUpdateKeys(inputFilePath, tableName, facilityCd, chunkContext, productionDbType, columnNameList, names, globalContext);
        if (updateSkipStatus != null) {
            return updateSkipStatus;
        }
        diffConvertAllDeleteAllInsert(inputFilePath, tableName, facilityCd, chunkContext, productionDbType, columnNameList, globalContext);
        return null;
    }

    // 差分コンバート対象外テーブルの判定
    private RepeatStatus diffConvertCheckSkipTable(String tableName) {
        if("mst_user_authentication".equals(tableName)){
            return RepeatStatus.FINISHED;
        }
        if("mst_user".equals(tableName)){
            return RepeatStatus.FINISHED;
        }
        return null;
    }

    // 差分コンバートの新規キー（sqlNewKeys）コピー処理
    private void diffConvertCopyNewKeys(String inputFilePath, String tableName, String facilityCd,
                                        ChunkContext chunkContext, String productionDbType, List<String> columnNameList, String[] names,
                                        GlobalContext globalContext) throws Exception {
        if (!globalContext.sqlNewKeys.isEmpty()) {
            String key = "";
            if ("B".equals(globalContext.plan)) {
                key = names[1];
            } else {
                key = globalContext.insFnKey;
            }
            // 新規レコードを削除
            String condSql = key + " in (" + globalContext.sqlNewKeys + ") ";
            //10378 add start
            if ("pat_coop_detail".equals(tableName)) {
                condSql = key + ">" + globalContext.sqlNewKeys;
            }
            //10378 add end
            // 実行するコピーコマンドの組み立て
            String[] command = psqlCopyUtils.createCopyCommandByCond(inputFilePath, tableName,
                    productionDbType,
                    ApplicationConst.DbType.CONVERT,
                    columnNameList,
                    facilityCd, condSql, "", false);
            if (command[2].length() > 5000) {
                int num = "ord_main".equals(tableName) || "pat_unique".equals(tableName) ? 50 : 200;
                List<String> sqlNewKeyList = Arrays.asList(globalContext.sqlNewKeys.split(","));
                List<List<String>> resList = Utils.sqlSplit(sqlNewKeyList, num);
                for (List<String> res : resList) {
                    String fnValue = String.join(",", res);
                    String condSqlSub = key + " in (" + fnValue + ") ";
                    String[] commandSub = psqlCopyUtils.createCopyCommandByCond(inputFilePath, tableName,
                            productionDbType,
                            ApplicationConst.DbType.CONVERT,
                            columnNameList,
                            facilityCd, condSqlSub, "", false);
                    this.runCommand(commandSub, chunkContext, tableName, facilityCd);
                }
            } else {
                this.runCommand(command, chunkContext, tableName, facilityCd);
            }
        }
    }

    // 差分コンバートの透析番号キー（sqlDisNoKeys）コピー処理
    private void diffConvertCopyDisNoKeys(String inputFilePath, String tableName, String facilityCd,
                                          ChunkContext chunkContext, String productionDbType, List<String> columnNameList,
                                          GlobalContext globalContext) throws Exception {
        if (!globalContext.sqlDisNoKeys.isEmpty()) {
            // 新規レコードを削除
            String condSql = " rst_fn_dialysis_no in (" + globalContext.sqlDisNoKeys + ") "; // #11998 mod
            // 実行するコピーコマンドの組み立て
            String[] command = psqlCopyUtils.createCopyCommandByCond(inputFilePath, tableName,
                    productionDbType,
                    ApplicationConst.DbType.CONVERT,
                    columnNameList,
                    facilityCd, condSql, "", false);
            if (command[2].length() > 5000) {
                int num = "ord_main".equals(tableName) ? 50 : 200;
                List<String> sqlNewKeyList = Arrays.asList(globalContext.sqlDisNoKeys.split(","));
                List<List<String>> resList = Utils.sqlSplit(sqlNewKeyList, num);
                for (List<String> res : resList) {
                    String fnValue = String.join(",", res);
                    String condSqlSub = " rst_fn_dialysis_no in (" + fnValue + ") "; // #11998 mod
                    String[] commandSub = psqlCopyUtils.createCopyCommandByCond(inputFilePath, tableName,
                            productionDbType,
                            ApplicationConst.DbType.CONVERT,
                            columnNameList,
                            facilityCd, condSqlSub, "", false);
                    this.runCommand(commandSub, chunkContext, tableName, facilityCd);
                }
            } else {
                this.runCommand(command, chunkContext, tableName, facilityCd);
            }
        }
    }

    // 差分コンバートの更新キー（sqlKeys）コピー処理
    private RepeatStatus diffConvertCopyUpdateKeys(String inputFilePath, String tableName, String facilityCd,
                                                   ChunkContext chunkContext, String productionDbType, List<String> columnNameList, String[] names,
                                                   GlobalContext globalContext) throws Exception {
        // mod zl start
        // 更新レコードを削除
        if (!globalContext.sqlKeys.isEmpty() && !utils.allDeleteAllInsertList.contains(tableName)) {
            // mod zl end
            // 関連テーブル利用のみ
            if ("B".equals(globalContext.plan)) {
                // 新規レコードを削除
                String condSql = names[1] + " in (" + globalContext.sqlKeys + ") ";

                // 実行するコピーコマンドの組み立て
                String[] command = psqlCopyUtils.createCopyCommandByCond(inputFilePath, tableName,
                        productionDbType,
                        ApplicationConst.DbType.CONVERT,
                        columnNameList,
                        facilityCd, condSql, "", false);

                if (command[2].length() > 5000) {
                    int num = "pat_unique".equals(tableName) ? 50 : 200;
                    List<String> sqlKeyList = Arrays.asList(globalContext.sqlKeys.split(","));
                    List<List<String>> resList = Utils.sqlSplit(sqlKeyList, num);
                    for (List<String> res : resList) {
                        String fnValue = String.join(",", res);
                        String condSqlSub = names[1] + " in (" + fnValue + ") ";
                        String[] commandSub = psqlCopyUtils.createCopyCommandByCond(inputFilePath, tableName,
                                productionDbType,
                                ApplicationConst.DbType.CONVERT,
                                columnNameList,
                                facilityCd, condSqlSub, "", false);
                        this.runCommand(commandSub, chunkContext, tableName, facilityCd);
                    }
                } else {
                    this.runCommand(command, chunkContext, tableName, facilityCd);
                }
            } else {
                // 自分テープル差分の場合、削除しない
                return RepeatStatus.FINISHED;
            }
        }
        return null;
    }

    // 差分コンバートの全削除全挿入リスト対象テーブル処理
    private void diffConvertAllDeleteAllInsert(String inputFilePath, String tableName, String facilityCd,
                                               ChunkContext chunkContext, String productionDbType, List<String> columnNameList,
                                               GlobalContext globalContext) throws Exception {
        // add zl start
        if (utils.allDeleteAllInsertList.contains(tableName)) {
            String tableKey = convertKeyConfig.getTableKey(tableName); // #11998 add
            String condSql = tableKey + " > " + globalContext.maxPrimaryForDB5; // #11998 add
            // add #10739 zc end
            String[] command = psqlCopyUtils.createCopyCommandByCond(inputFilePath, tableName,
                    productionDbType,
                    ApplicationConst.DbType.CONVERT,
                    columnNameList,
                    facilityCd, condSql, "", false);
            this.runCommand(command, chunkContext, tableName, facilityCd);
        }

        // add zl end
    }

    // add 7853-差分コンバートで更新/削除ができない 楊 start
    /**
     * 前回コピーコマンド実行
     *
     * @param command      　command文
     * @param chunkContext 　chunkContext
     * @param tableName    　テープル
     * @param facilityCd   　facilityCd
     * @return
     */
    public void runCommand(String[] command, ChunkContext chunkContext, String tableName, String facilityCd)throws Exception{
        StepExecution se = chunkContext.getStepContext().getStepExecution();
        Runtime runtime = Runtime.getRuntime();
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
            progressManagement.createConvertTableStatus(se, "Copyコマンド異常終了：処理テーブル：" + tableName);
            String errorMsg = "Copyコマンド異常終了\n" + ",「command」:" + String.join(" ", command) + ",「ERROR」:" + et.getOutputString();
            EventLogMessage eventLogMessageErr = eventLoggerUtil.getEventLogMessage(errorMsg,
                    facilityCd, "DeleteTableInConvertDbStep->runCommand");
            eventLoggerUtil.recordLog(facilityCd, eventLogMessageErr, LogLevel.ERROR);
            throw new RuntimeException(errorMsg);
        } else {
            //ログ
            eventLogMessage4 = eventLoggerUtil.getEventLogMessage("コピーコマンド実行：" + command[2],
                    facilityCd, "execute(StepContribution contribution, ChunkContext chunkContext)");
            eventLoggerUtil.recordLog(facilityCd, eventLogMessage4, LogLevel.INFO);
            // テーブル毎の進捗更新
            progressManagement.createConvertTableStatus(se, "Copyコマンド正常終了：処理テーブル：" + tableName );
        }
    }
    // add 7853-差分コンバートで更新/削除ができない 楊 end

    @Bean(name=STEP_NAME)
    public Step step() {
        return new StepBuilder(STEP_NAME, jobRepository)
            .tasklet(this)
            .listener(new PromotionListener())
            .build();
    }

}