package batch.step;

import batch.ApplicationConst;
import batch.config.ConvertKeyConfig;
import batch.listener.JobStartEndLIstener;
import batch.listener.StepStartEndListener;
import batch.part.InfomationSchemaControl;
import batch.part.PsqlCopyUtils;
import batch.part.TableNameToDbType;
import com.zaxxer.hikari.HikariDataSource;
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
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;
import utils.GlobalContext;
import utils.Utils;
import web.config.EventLoggerUtil;
import web.logger.EventLogMessage;
import web.logger.LogLevel;

import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

/**
 * コピーと削除のsqlを作成ステップ
 */
@Component
public class MakeSqlStep extends StepStartEndListener implements Tasklet {

    public static final String STEP_NAME = "MakeSqlStep";

    @Autowired
    private StepBuilderFactory stepBuilderFactory;

    @Autowired
    private ApplicationContext appContext;

    @Autowired
    Utils utils;

    @Autowired
    private PsqlCopyUtils psqlCopyUtils;

    @Autowired
    private ConvertKeyConfig convertKeyConfig;

    @Autowired
    private Environment environment;

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
        String inputFilePath = chunkContext.getStepContext().getJobParameters().get(ApplicationConst.JobParameterKeys.INPUT_FILE_PATH)
                .toString();
        String processingFile = chunkContext.getStepContext().getJobExecutionContext()
                .get(ApplicationConst.PromotionKeys.NEXT_PROCESSING_FILE).toString();
        // 指示履歴の場合、sql作成不要
        int indexFile = processingFile.indexOf("indicatorShoe");
        int isDiff = processingFile.indexOf("[diff]");
       //mod 6886 zc start
        int inhistory = processingFile.indexOf("pat_personal_main_history");
        int ingrouphistory = processingFile.indexOf("pat_group_detail_history");
        int ininhistory = processingFile.indexOf("pat_insurance_history");
        int inmainhistory = processingFile.indexOf("pat_main_history");
        int inunhistory = processingFile.indexOf("pat_unique_history");
        //mod 6886 zc end
        if(indexFile != -1 || isDiff != -1 || inhistory != -1 || ingrouphistory != -1 || ininhistory != -1 || inmainhistory != -1 || inunhistory != -1
        ){
            return RepeatStatus.FINISHED;
        }
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
        // コンバートDBから本番DBに登録のsqlファイルを作成
        if (fileConvertDbToProductionDbStep.exists())
        {
            fileConvertDbToProductionDbStep.delete();
            fileConvertDbToProductionDbStep.createNewFile();
        }
        // コンバートDBから削除のsqlファイルを作成
        if (fileTruncateTableStep.exists())
        {
            fileTruncateTableStep.delete();
            fileTruncateTableStep.createNewFile();
        }
        // 本番DBからコンバートDBに登録のsqlファイルを作成
        if (fileProductionDbToConvertDbStep.exists())
        {
            fileProductionDbToConvertDbStep.delete();
            fileProductionDbToConvertDbStep.createNewFile();
        }

        // コンバートDBから本番DBにテーブルデータのsqlファイルを書き
        String tableName = PsqlCopyUtils.getTableName(processingFile);
        // 登録先DBTypeの取得
        TableNameToDbType tableNameToDbType = new TableNameToDbType(appContext);
        String registDbType = tableNameToDbType.getDbTypeByTableName(tableName);

        // コンバート一時DBに対応するデータソースの取得
        HikariDataSource convertDbDs = (HikariDataSource) appContext.getBean(ApplicationConst.DbType.CONVERT);

        // 登録先テーブルの列を取得
        InfomationSchemaControl isc = new InfomationSchemaControl(appContext);
        List<String> columnNameList = isc.getColumnNamesExclusiveSeqColumn(tableName);
        List<String> columnNameProductionList= isc.getColumnNamesForCodeConversion(tableName);

        // コンバートDBから本番DBにテーブルデータのsqlファイルを書き
        this.writeConvertDbToProductionDbFile(convertDbDs, tableName, facilityCd,
                inputFilePath, registDbType, columnNameList,fileConvertDbToProductionDbStep);

        boolean isNoseq = convertKeyConfig.getNoseq(tableName);

        if (!isNoseq)
        {
            // コンバートDB削除ファイルを書き
            this.writeTruncateTableFile(tableName, facilityCd, chunkContext,fileTruncateTableStep);
            // #12229 本番DB -> convert　なし　 start
            if (!utils.ConvertNotData.contains(tableName)){
                // #12229 add end
                // 本番DBからコンバートDBにテーブルデータのsqlファイルを書き
                this.writeProductionDbToConvertDbFile(tableName, facilityCd, chunkContext, registDbType,
                        columnNameProductionList, fileProductionDbToConvertDbStep);
            }
        }
        return RepeatStatus.FINISHED;
    }

    /**
     * コンバートDBから本番DBに登録のsqlをファイルに書き
     * @param convertDbDs　コンバートDs
     * @param tableName　テープル
     * @param facilityCd　施設コード
     * @param inputFilePath　ファイルパス
     * @param registDbType　本番DbType
     * @param columnNameList　テープルcolumn名
     * @param fileConvertDbToProductionDbStep　コンバートDBから本番DBにテーブルデータを登録ファイル
     *
     */
    public void writeConvertDbToProductionDbFile(HikariDataSource convertDbDs,
                                                 String tableName,
                                                 String facilityCd,
                                                 String inputFilePath,
                                                 String registDbType,
                                                 List<String> columnNameList,
                                                 File fileConvertDbToProductionDbStep
    ) throws Exception {

        GlobalContext globalContext = JobStartEndLIstener.getGlobalContext();
        String condSql = " 1 = 1 ";
        // 初回の場合、本番DBを削除
        String delSql = "";
        List<String> fnValueList = new ArrayList<String>();
        String userName = environment.getProperty("datasource." + ApplicationConst.DbType.CONVERT + ".username");
        String table_prefix = environment.getProperty(userName+ "_prefix");
        table_prefix = table_prefix == null ? "" : table_prefix;
        String[] names = setUtilSqlKeys(convertDbDs, tableName, facilityCd, fnValueList,table_prefix);

        // #Mod #8127 コンバータ施設の指示受け指示承認が指示検索中のまま Start
        String tableKey = convertKeyConfig.getTableKey(tableName); // #11998 add
        if (!"".equals(tableKey)) // #11998 add
        // #Mod #8127 コンバータ施設の指示受け指示承認が指示検索中のまま End
        {
            // シーケンスの場合：`seqKey is null` を使用すると、このファイルに書き込まれたばかりのバッチのみをコピーできます（プライマリキーの競​​合を回避します）。
            condSql = tableKey + " is null"; // #11998 add
        }
        // #11998 modify 複数の施設が並行して稼働している場合の主キーの競合回避: seqKey is null を使用して、順序付きリスト内で「このファイルに書き込まれたばかりのバッチ」を識別します (convert_id は自動インクリメントされ、書き込み時には本番側の主キーは null になります)。
        else {
            if ("pat_ind_approve".equals(tableName)) {
                String input = globalContext.insFnValue;
                String[] values = input.split(",");
                String sql = names[1].replace("ord_no", "pat_ind_approve.ord_no");
                condSql = sql + "INNER JOIN ord_main  ( SELECT ord_no from ord_main  WHERE  fn_pat_id || treat_date || fn_plural in('" + String.join("','", values) + "') and facility_cd='" + facilityCd + "' ) ord " +
                        " on ord.ord_no=pat_ind_approve.ord_no";
            } else {
                condSql = names[1] + " INNER JOIN (SELECT regexp_split_to_table('" + globalContext.insFnValue + "', ',') AS ids) tmp ON trim("
                        + globalContext.insFnKey + ") = trim(tmp.ids) ";
            }
        }
        // add 7406 ReMS利用施設をコンバートすると送信先グループマスタや警報通知マスタなどのデータが消えている 楊 start
        // mst_user_authenticationの場合、更新データを含むので、施設コードより、全てコピー
        if ("mst_user_authentication".equals(tableName)) {
            // 本番データを削除
            delSql = "delete from " + tableName + " where facility_cd='" + facilityCd + "'";
            // 施設コードより、全てコピー
            condSql = " 1 = 1 ";
        }
        if ("mst_comsv_setting".equals(tableName)) {
            // 本番データを削除
            delSql = "delete from " + tableName + " where facility_cd='" + facilityCd + "'";
            // 施設コードより、全てコピー
            condSql = " 1 = 1 ";
            columnNameList.remove("convert_id");
        }
        // add 7406 ReMS利用施設をコンバートすると送信先グループマスタや警報通知マスタなどのデータが消えている 楊 end

        // add zl start
        if ("pat_ind_approve".equals(tableName)) {
            condSql = "ord_no in(" + globalContext.insFnValue + ") ";
        }

        if ("mst_user".equals(tableName) || "pat_group_detail".equals(tableName) || "medicine_latest_no".equals(tableName)) {
            condSql = " INNER JOIN (SELECT regexp_split_to_table('" + globalContext.insFnValue + "', ',') AS ids) tmp ON trim("
                    + globalContext.insFnKey + ") = trim(tmp.ids) ";
        }
        // add zl end
        String[] command = psqlCopyUtils.createCopyCommandByCond(inputFilePath, tableName, ApplicationConst.DbType.CONVERT, registDbType, columnNameList,
                facilityCd, condSql, delSql, true);

        // ファイルが存在しないの場合、ファイルを作成
        if (!fileConvertDbToProductionDbStep.exists())
        {
            fileConvertDbToProductionDbStep.createNewFile();
        }
        // コンバートDBから本番DBにテーブルデータを登録ファイル 一行目：テープル、二～四行目：sqlCommand
        StringBuffer stringBuffer = new StringBuffer();
        stringBuffer.append(tableName);
        stringBuffer.append("\n");
        stringBuffer.append(command[2]);
        if (command[2].length() > 8000) {
            // コンバートDBから本番DBにテーブルデータを登録ファイル 一行目：テープル、二行目から：sqlCommand
            stringBuffer = new StringBuffer();
            stringBuffer.append(tableName);
            int num = "ord_main".equals(tableName) ? 50 : 200;
            List<String> result = Arrays.asList(globalContext.insFnValue.split(","));
            List<List<String>> resList = Utils.sqlSplit(result, num);
            for (List<String> res : resList) {
                String fnValueSub = String.join(",", res);
                String condSqlSub = " INNER JOIN (SELECT regexp_split_to_table('" + fnValueSub + "', ',') AS ids) tmp ON trim("
                        + globalContext.insFnKey + ") = trim(tmp.ids) ";
                String[] commandSub = psqlCopyUtils.createCopyCommandByCond(inputFilePath, tableName, ApplicationConst.DbType.CONVERT, registDbType, columnNameList,
                        facilityCd, condSqlSub, delSql, true);
                // コンバートDBから本番DBにテーブルデータを登録ファイル 一行目：テープル、二行目から：sqlCommand
                stringBuffer.append("\n");
                stringBuffer.append(commandSub[2]);
            }
        }
        // コンバートDBから本番DBにテーブルデータを登録ファイルを書き
        utils.writeFile(inputFilePath + "/ConvertDbToProductionDbStep.txt", stringBuffer.toString(), facilityCd);

    }

    /**
     * テンポラリ・テーブルから本番ＤＢ更新
     * @param convertDbDs 本番の施設Ds
     * @param facilityCd　本番の施設コード　
     * @param tableName　本番ＤＢテーブル
     * @param fnValueList　入力ファイル
     * @return なし
     */
    private String[] setUtilSqlKeys(HikariDataSource convertDbDs, String tableName, String facilityCd,
                                    List<String> fnValueList, String table_prefix) throws Exception {
        GlobalContext globalContext = JobStartEndLIstener.getGlobalContext();
        // convertKeyから、fn keyを取得
        String cols = convertKeyConfig.getConvertKey(tableName);
        String[] names = cols.split(",");
        // fn key
        String realData = "";
        if (cols == null || cols.trim().isEmpty()){
            // キーがその他テープルから場合
            cols = convertKeyConfig.getConvertbKey(tableName);
            names = cols.split(",");
            if (names.length > 1){
                realData = " COALESCE(trim(cast(" + names[1]+ " as char(20)),''))";
            }
        } else {
            names = cols.split(",");
            if (names.length > 2){
                for (int i = 2 ;i < names.length;i++) {
                    realData = realData + names[i].substring(0, names[i].length() - 2) + " ,";
                }
                if (!realData.isEmpty()) {
                    realData = realData.substring(0, realData.length() - 1);
                }
                realData = " concat_ws(''," + realData + ")";
            }
            if (realData.isEmpty()) {
                realData = "facility_cd";
            }
        }
        // 本番dbからコピー用fnkey
        globalContext.insFnKey = realData;
        // 新規レコードのfnkeyを取得
        String sql = "";
        // mod 8309 【デグレ】FNWデモ環境からコンバートするツールがエラーで停止する 楊 start
        String tableKey = convertKeyConfig.getTableKey(tableName); // #11998 add
        if (!"".equals(tableKey)) { // #11998 add
            // add 12229
            if (utils.ConvertNotData.contains(tableName)) {
                // 本番DBのseq
                globalContext.seqRegist = 0;
            } else {
                // mod 8309 【デグレ】FNWデモ環境からコンバートするツールがエラーで停止する 楊 end
                // シーケンスなしテーブルの場合、facility_cdとシーケンスを検索条件とする。
                TableNameToDbType tableNameToDbType = new TableNameToDbType(appContext);
                String registDbType =tableNameToDbType.getDbTypeByTableName(tableName);
                // 本番DBのTypeに対応するデータソースの取得
                HikariDataSource ds = (HikariDataSource) appContext.getBean(registDbType);
                JdbcTemplate jdbcTemplateRegist = new JdbcTemplate(ds);
                // このテーブルのシーケンス取得
                String seqSql = " SELECT  CASE WHEN  (" +
                        "        SELECT count(*) FROM " + table_prefix + tableName + " WHERE facility_cd = '" + facilityCd + "' " +
                        "    )>0" +
                        "    THEN (SELECT MAX(" + tableKey + ") from " + table_prefix + tableName + " where facility_cd = '" + facilityCd + "')" +
                        "    ELSE 0 " +
                        "    END AS currSeq"; // #11998 add
                long seq = jdbcTemplateRegist.queryForObject(seqSql, Long.class).longValue();
                // 本番DBのseq
                globalContext.seqRegist = seq;
            }

        } else {
        // mod 8309 【デグレ】FNWデモ環境からコンバートするツールがエラーで停止する 楊 start
            if (names != null && names.length > 0 && (!names[0].isEmpty()) && "facility_cd".equals(names[1].trim())) {
        // mod 8309 【デグレ】FNWデモ環境からコンバートするツールがエラーで停止する 楊 end
                // キーが「"facility_cd"」の場合、facility_cdを検索条件とする。
                sql = "select " + realData + " from " + table_prefix + tableName
                        + " where " + names[1] + " not in ('" + globalContext.befKeyList + "')";
                EventLogMessage eventLogMessagetodo1 = eventLoggerUtil.getEventLogMessage("=================本番dbからコピー用fnvalue==============" + sql,
                        facilityCd, "ConvertDbToProductionDbStep");
                eventLoggerUtil.recordLog(facilityCd, eventLogMessagetodo1, LogLevel.INFO);
                fnValueList = jdbcTemplateConvert.queryForList(sql, String.class);
            } else if (!globalContext.befKeyList.isEmpty()) {
                // シーケンスなしテーブルの場合、facility_cdと登録前テーブルのキーを検索条件とする。
                sql = "select " + realData + " from " + table_prefix + tableName;
                sql += " where " + names[1] + " not in ('" + globalContext.befKeyList + "')";
                sql += globalContext.hasFacilityCd ? " and facility_cd = ?" : "";
                EventLogMessage eventLogMessagetodo1 = eventLoggerUtil.getEventLogMessage("=================本番dbからコピー用fnvalue==============" + sql,
                        facilityCd, "ConvertDbToProductionDbStep");
                eventLoggerUtil.recordLog(facilityCd, eventLogMessagetodo1, LogLevel.INFO);
                fnValueList = globalContext.hasFacilityCd ? jdbcTemplateConvert.queryForList(sql, new Object[]{facilityCd}, String.class) : jdbcTemplateConvert.queryForList(sql, String.class);
            } else {
                sql = "select " + realData + " from " + table_prefix + tableName;
                sql += globalContext.hasFacilityCd ? " where facility_cd = ?" : "";
                EventLogMessage eventLogMessagetodo1 = eventLoggerUtil.getEventLogMessage("=================本番dbからコピー用fnvalue==============" + sql,
                        facilityCd, "ConvertDbToProductionDbStep");
                eventLoggerUtil.recordLog(facilityCd, eventLogMessagetodo1, LogLevel.INFO);
                fnValueList = globalContext.hasFacilityCd ? jdbcTemplateConvert.queryForList(sql, new Object[]{facilityCd}, String.class) : jdbcTemplateConvert.queryForList(sql, String.class);
            }

            // 新規レコードのfnkey
            fnValueList = fnValueList.stream().distinct().collect(Collectors.toList());
            String fnValue = String.join(",", fnValueList);
            if ("pat_ind_approve".equals(tableName)) {
                String[] values = fnValue.split(",");
                String noSql = " SELECT ord_no from ord_main  WHERE  fn_pat_id || treat_date || fn_plural in('" + String.join("','", values) + "') and facility_cd='" + facilityCd + "'";
                List<String> fnValueListno = jdbcTemplateConvert.queryForList(noSql, String.class);
                fnValue = String.join(",", fnValueListno);
            }
            // 本番dbからコピー用fnvalue
            globalContext.insFnValue = fnValue;
        }
        return names;
    }

    /**
     * コンバートDB削除のsqlをファイルに書き
     * @param tableName　テープル
     * @param facilityCd　施設コード
     * @param chunkContext　chunkContext
     * @param fileTruncateTableStep　コンバートDB削除ファイル
     *
     */
    public void writeTruncateTableFile(String tableName, String facilityCd, ChunkContext chunkContext,
                                       File fileTruncateTableStep) throws Exception {
        String tableKey = convertKeyConfig.getTableKey(tableName);
        String userName = environment.getProperty("datasource." + ApplicationConst.DbType.CONVERT + ".username");
        String table_prefix = environment.getProperty(userName + "_prefix");
        table_prefix = table_prefix == null ? "" : table_prefix;

        // 施設コードを保持しているテーブルを削除する
        String sql = "delete from " + table_prefix + tableName + " where 1=1 and facility_cd='" + facilityCd + "' and " + tableKey + " is null "; // #11998 add
        String inputPath = chunkContext.getStepContext().getJobParameters().get(ApplicationConst.JobParameterKeys.INPUT_FILE_PATH)
                .toString();
        // ファイルが存在しないの場合、ファイルを作成
        if (!fileTruncateTableStep.exists()) {
            fileTruncateTableStep.createNewFile();
        }
        // コンバートDBから本番DBにテーブルデータを登録ファイル 一行目：sqlCommand
        StringBuffer stringBuffer = new StringBuffer();
        stringBuffer.append(sql);
        utils.writeFile(inputPath + "/TruncateTableStep.txt", stringBuffer.toString(), facilityCd);
    }

    /**
     * 本番DBからコンバートDBに登録のsqlをファイルに書き
     * @param tableName　テープル
     * @param facilityCd　施設コード
     * @param chunkContext　chunkContext
     * @param productionDbType　本番DbType
     * @param columnNameList　テープルcolumn名
     * @param fileProductionDbToConvertDbStep　本番DBからコンバートDBにテーブルデータを登録ファイル
     *
     */
    public void writeProductionDbToConvertDbFile(String tableName,
                                                 String facilityCd,
                                                 ChunkContext chunkContext,
                                                 String productionDbType,
                                                 List<String> columnNameList,
                                                 File fileProductionDbToConvertDbStep) throws Exception {
        String inputFilePath = chunkContext.getStepContext().getJobParameters().get(ApplicationConst.JobParameterKeys.INPUT_FILE_PATH)
                .toString();
        GlobalContext globalContext = JobStartEndLIstener.getGlobalContext();
        String cols = convertKeyConfig.getConvertKey(tableName);

        if (cols == null || cols.trim().isEmpty()) {
            cols = convertKeyConfig.getConvertbKey(tableName);
        }
        // 本番DBから、レコードをコピー条件
        String condSql = "";
        if (!globalContext.insFnValue.isEmpty() || globalContext.seqRegist != -1) {
            if (globalContext.seqRegist > -1) {
                condSql = globalContext.seqKey + " > " + globalContext.seqRegist;
            }
        }
        // 実行するコピーコマンドの組み立て
        String[] command = psqlCopyUtils.createCopyCommandByCond(inputFilePath, tableName,
                productionDbType,
                ApplicationConst.DbType.CONVERT,
                columnNameList,
                facilityCd, condSql, "", false);
        String inputPath = chunkContext.getStepContext().getJobParameters().get(ApplicationConst.JobParameterKeys.INPUT_FILE_PATH).toString();
        // ファイルが存在しないの場合、ファイルを作成
        if (!fileProductionDbToConvertDbStep.exists()) {
            fileProductionDbToConvertDbStep.createNewFile();
        }
        // コンバートDBから本番DBにテーブルデータを登録ファイル 一行目：テープル、二行目から：sqlCommand
        StringBuffer stringBuffer = new StringBuffer();
        stringBuffer.append(tableName);
        stringBuffer.append("\n");
        stringBuffer.append(command[2]);
        if (command[2].length() > 5000) {
            // ファイルが存在する場合、ファイルをクリア
            fileProductionDbToConvertDbStep.delete();
            fileProductionDbToConvertDbStep.createNewFile();
            // コンバートDBから本番DBにテーブルデータを登録ファイル 一行目：テープル、二行目から：sqlCommand
            stringBuffer = new StringBuffer();
            stringBuffer.append(tableName);
            int num = "ord_main".equals(tableName) || "pat_unique".equals(tableName) ? 50 : 200;
            List<String> result = Arrays.asList(globalContext.insFnValue.split(","));
            List<List<String>> resList = Utils.sqlSplit(result, num);
            List<String[]> commandSubList = new ArrayList<String[]>();
            for (List<String> res : resList) {
                String fnValue = String.join(",", res);
                String condSqlSub = " INNER JOIN (SELECT regexp_split_to_table('" + fnValue + "', ',') AS ids) tmp ON trim("
                        + globalContext.insFnKey + ") = trim(tmp.ids) ";
                String[] commandSub = psqlCopyUtils.createCopyCommandByCond(inputFilePath, tableName,
                        productionDbType,
                        ApplicationConst.DbType.CONVERT,
                        columnNameList,
                        facilityCd, condSqlSub, "", false);
                // コンバートDBから本番DBにテーブルデータを登録ファイル 一行目：テープル、二行目から：sqlCommand
                stringBuffer.append("\n");
                stringBuffer.append(commandSub[2]);
                commandSubList.add(commandSub);
            }
        }

        // mod #9448 mst_mainte_category.detail再設定 zkm start
        if(utils.mainteHistCopySourceList.contains(tableName)){
        // mod #9448 mst_mainte_category.detail再設定 zkm end

            String[] command1 = psqlCopyUtils.createCopyCommandByCond(inputFilePath, tableName + "_hst",
                    productionDbType,
                    ApplicationConst.DbType.NKK5,
                    columnNameList,
                    facilityCd, condSql, "", false);
            stringBuffer.append("\n");
            stringBuffer.append(command1[2]);
            utils.writeFile(inputPath + "/ProductionDbToConvertDbStep.txt", stringBuffer.toString(), facilityCd);
        } else {
            utils.writeFile(inputPath + "/ProductionDbToConvertDbStep.txt", stringBuffer.toString(), facilityCd);
        }
        // コンバートDBから本番DBにテーブルデータを登録ファイルを書き

    }

    @Bean(name=STEP_NAME)
    public Step step() {
        return stepBuilderFactory.get(STEP_NAME)
            .tasklet(this)
            .build();
    }
}