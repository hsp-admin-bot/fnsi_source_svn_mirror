package batch.step;

import batch.ApplicationConst;
import batch.entity.MstSelector;
import batch.listener.ConvertDeleteMstSelectorListener;
import batch.listener.JobStartEndLIstener;
import batch.listener.StepStartEndListener;
import batch.part.InfomationSchemaControl;
import batch.part.StreamThread;
import de.siegmar.fastcsv.writer.CsvWriter;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.batch.core.step.Step;
import org.springframework.batch.core.step.StepContribution;
import org.springframework.batch.core.repository.JobRepository;
import org.springframework.batch.core.step.builder.StepBuilder;
import org.springframework.batch.core.scope.context.ChunkContext;
import org.springframework.batch.core.step.tasklet.Tasklet;
import org.springframework.batch.infrastructure.repeat.RepeatStatus;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.core.env.Environment;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcOperations;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Component;
import org.springframework.util.ObjectUtils;
import utils.GlobalContext;
import utils.Utils;
import web.config.EventLoggerUtil;
import web.logger.EventLogMessage;
import web.logger.LogLevel;

import javax.sql.DataSource;
import java.io.*;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

/**
 * mst_selectorテーブルの関連処理
 */
@Component
public class MstSelectorStep extends StepStartEndListener implements Tasklet {

    public static final String STEP_NAME = "MstSelectorStep";

    public static final String TABLENAME = "mst_selector";

    public static final String[] TABLEARRAY = {
            "mst_add_monitor",
            "mst_addition",
            "mst_bbs_kind",
            "mst_bed",
            "mst_com_fixed_phrase",
            "mst_comp_treatment",
            "mst_complaint",
            "mst_comsv_setting",
            "mst_course",
            "mst_dialysis_difficulty",
            "mst_dialyzer",
            "mst_disease",
            "mst_equipment",
            "mst_equipment_class",
            "mst_exam_item",
            "mst_exam_set",
            "mst_holiday",
            "mst_infection",
            "mst_job",
            "mst_kur",
            "mst_machine",
            "mst_medicate_timing",
            "mst_medicine",
            "mst_medicine_class",
            "mst_medicine_group",
            "mst_medicine_mix",
            "mst_medicine_support",
            "mst_monitor_graph",
            "mst_obs_kind",
            "mst_pat_event_category",
            "mst_pat_event_data_template",
            "mst_pat_event_sub_category",
            "mst_pat_viewer_layout",
            "mst_procedure",
            "mst_rad_set",
            "mst_room_bed_group",
            "mst_self_measure_result",
            "mst_severity",
            "mst_taboo_allergy",
            "mst_take_medicine",
            "mst_transport",
            "mst_treatment",
            "mst_treatment_set",
            "mst_treatment_status_layout",
            "mst_trend_graph_template",
            "mst_user",
            "mst_va",
            "mst_vital_graph",
            "mst_ward",
            "mst_water_survey_point",
            "mst_water_survey_type",
            "mst_weight",
            "mst_wheel_chair",
            "pat_group",
            "mst_mainte_detail",
            "mst_mainte_category",
            "mst_mainte_layout",
            "mst_mainte_layout_group",
            "mst_trend_graph_monitor_set",
            "mst_pat_list_layout",
            "mst_pat_calendar_layout"
    };

    public static final String[] DIFFTABLEARRAY = {
            "mst_infection",
            "mst_pat_event_sub_category",
            "mst_addition",
            "mst_taboo_allergy",
            "mst_water_survey_point",
            "mst_medicine",
            "mst_medicine_mix",
            "mst_equipment",
            "mst_dialyzer",
            "mst_procedure",
            "mst_medicate_timing",
            "mst_treatment",
            "mst_com_fixed_phrase",
            "mst_complaint",
            "mst_comp_treatment",
            "mst_user_authentication",
            "mst_personal_user",
            "mst_user",
            "mst_ward",
            "mst_course",
            "mst_job",
            "mst_exam_item",
            "mst_exam_set",
            "pat_group",
            "mst_trend_graph_monitor_set",
            "mst_pat_event_category",
            "mst_pat_event_data_template",
            "mst_bbs_kind"

    };
    // convert
    private NamedParameterJdbcOperations machineJdbcTemplate;

    private static final String MSTSELECTORTHEAD = "facility_cd,master_physical_name,order_settings,reg_date,up_date";

    @Autowired
    private JobRepository jobRepository;

    @Autowired
    Utils utils;

    @Autowired
    private Environment environment;

    @Autowired
    private EventLoggerUtil eventLoggerUtil;

    @Autowired
    private ApplicationContext appContext;

    @Autowired
    private ConvertDeleteMstSelectorListener convertDeleteMstSelectorListener;
    @Autowired
    private static  String fileMstSelect;

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
                fileMstSelect =file.getAbsolutePath();
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
    @Override
    public RepeatStatus execute(StepContribution contribution, ChunkContext chunkContext) throws Exception {
        // 処理対象ファイル名からテーブル名の取得
        Map<String,String> mstSel= new HashMap<>();
        String inputFilePath = chunkContext.getStepContext().getJobParameters().get(ApplicationConst.JobParameterKeys.INPUT_FILE_PATH).toString();
        String facilityCd = chunkContext.getStepContext().getJobParameters().get(ApplicationConst.JobParameterKeys.FACILITY_CD).toString();

        //add zc
        File dir=new File(inputFilePath);
        findFileRecursively("Mst_select.txt",dir,false);
        if(fileMstSelect!=null){
            File f = new File(fileMstSelect);
            // delete patList.txt
            if (f.exists()){
                //mod #9862 close stream 2023-10-27 liushengnan start
                try(BufferedReader buffReader = new BufferedReader(new InputStreamReader(new FileInputStream(fileMstSelect)))){
                    String strTmp = "";
                    while((strTmp = buffReader.readLine())!=null){
                        mstSel.put(strTmp.split("/")[0],strTmp.split("/")[1]);
                    }
                }catch (Exception e){
                    eventLoggerUtil.recordLog(
                            facilityCd,
                        eventLoggerUtil.getEventLogMessage(
                                "execute：" + EventLoggerUtil.excetionStackTraceToString(e),
                                facilityCd,
                                e.getClass().getName() + ".execute()"),
                        LogLevel.ERROR);

                }
                f.delete();
                //mod #9862 close stream 2023-10-27 liushengnan end
            }
         }
        //add zc

        String csvFilePath = inputFilePath + "/mst_selector.csv";
        Map<String, JSONObject> mstJsonMap = new HashMap<>();
        int t = 1;
        StringBuffer sb = new StringBuffer();

        for (String tableName : TABLEARRAY) {
            String cdAndName = environment.getProperty("selector." + tableName);
            String[] cdAndNameArray = ObjectUtils.isEmpty(cdAndName) ? null : cdAndName.split(",");
            //add zc
            JSONObject orderSettingJson=new JSONObject();
            if (!mstSel.isEmpty() && mstSel.containsKey(tableName)) {
                orderSettingJson = this.makeJsonSqlQueryDiff(facilityCd, tableName, cdAndNameArray[0], cdAndNameArray[1],cdAndNameArray[2], mstSel.get(tableName));
            } else {
                if(inputFilePath.indexOf("[diff]") >0 && Arrays.asList(DIFFTABLEARRAY).contains(tableName)){
                    t++;
                    continue;
                }
                orderSettingJson = this.makeJsonSqlQuery(facilityCd, tableName, cdAndNameArray[0], cdAndNameArray[1]);
            }
            //add zc
            if (!ObjectUtils.isEmpty(orderSettingJson) && !orderSettingJson.isEmpty()) {
                mstJsonMap.put(tableName, orderSettingJson);
            }
            sb.append("'").append(tableName).append("'");

            if (t < TABLEARRAY.length) {
                sb.append(",");
            }
            t++;
        }
        // コンマで終わっているかどうかを確認し、かつ長さが0より大きい場合、最後の文字（コンマ）を削除
        if (!sb.isEmpty() && sb.charAt(sb.length() - 1) == ',') {
            sb.deleteCharAt(sb.length() - 1);
        }
        String db_table_prefix = environment.getProperty("datasource." + ApplicationConst.DbType.NKK5 + ".table_prefix");
        DataSource nkk5 = (DataSource) appContext.getBean(ApplicationConst.DbType.NKK5);
        machineJdbcTemplate = new NamedParameterJdbcTemplate(nkk5);
        String sql = "DELETE FROM " + db_table_prefix + TABLENAME + " WHERE facility_cd = ? AND master_physical_name in (" + sb.toString() + ")";
        machineJdbcTemplate.getJdbcOperations().update(sql, facilityCd);
        this.createCsvFileAndToProduction(facilityCd, csvFilePath, mstJsonMap);
        InfomationSchemaControl isc = new InfomationSchemaControl(appContext);
        List<String> columnNameList = isc.getColumnNamesForCodeConversion(TABLENAME);
        String[] command = this.createCopyCommandToConvertDb(inputFilePath, TABLENAME, columnNameList, facilityCd, ApplicationConst.DbType.NKK5, 1);
        boolean c = this.processCmdSql(command, true, facilityCd);
        if (!c) {
            EventLogMessage eventLogMessageTable = eventLoggerUtil.getEventLogMessage(TABLENAME + "COPYからConvertDBに失敗！",
                    facilityCd, "MstSelectorStep");
            eventLoggerUtil.recordLog(facilityCd, eventLogMessageTable, LogLevel.ERROR);
        }
        return RepeatStatus.FINISHED;
    }




    /**
     * ProductionToConvertDb
     *
     * @param tableName
     * @param registColumnNameList
     * @param facilityCd
     * @param registDbType
     * @param status
     * @return
     * @throws IOException
     * @throws SQLException
     */
    public String[] createCopyCommandToConvertDb(String inputFilePath,String tableName, List<String> registColumnNameList, String facilityCd,
                                      String registDbType,
                                      int status) throws IOException, SQLException {
        String jdbcUrl = environment.getProperty("datasource." + registDbType + ".jdbc-url");
        String userName = environment.getProperty("datasource." + registDbType + ".username");
        String jdbcUrlConvert = environment.getProperty("datasource." + ApplicationConst.DbType.CONVERT + ".jdbc-url");
        String userNameConvert = environment.getProperty("datasource." + ApplicationConst.DbType.CONVERT + ".username");
        String fromHostIp = "";
        String fromDbUser = "";
        String fromDbName = "";
        if (status == 0) {
            fromHostIp = jdbcUrlConvert.split("/")[2].split(":")[0];
            fromDbUser = userNameConvert;
            fromDbName = jdbcUrlConvert.split("/")[3];
        } else {
            fromHostIp = jdbcUrl.split("/")[2].split(":")[0];
            fromDbUser = userName;
            fromDbName = jdbcUrl.split("/")[3];
        }
        String fromDb_table_prefix = environment.getProperty(fromDbUser + "_prefix");
        fromDb_table_prefix = fromDb_table_prefix == null ? "" : fromDb_table_prefix;
        String toHostIp = "";
        String toDbUser = "";
        String toDbName = "";
        if (status == 1) {
            toHostIp = jdbcUrlConvert.split("/")[2].split(":")[0];
            toDbUser = userNameConvert;
            toDbName = jdbcUrlConvert.split("/")[3];
        } else {
            toHostIp = jdbcUrl.split("/")[2].split(":")[0];
            toDbUser = userName;
            toDbName = jdbcUrl.split("/")[3];
        }
        String toDb_table_prefix = environment.getProperty(toDbUser + "_prefix");
        toDb_table_prefix = toDb_table_prefix == null ? "" : toDb_table_prefix;
        boolean hasFacilityCd = registColumnNameList.stream().anyMatch(x -> x.equals("facility_cd"));
        String registColumnNames = String.join(",", registColumnNameList);
        String sql = "select " + registColumnNames + " from " + fromDb_table_prefix + tableName;
        if(hasFacilityCd){
            sql += " where facility_cd='" + facilityCd + "'";
        }
        GlobalContext globalContext = JobStartEndLIstener.getGlobalContext();
        String tmpCopyCsvFile = inputFilePath + globalContext.tmpCopyCsvDir + tableName + ".csv";
        String copyCommand = "psql"
                + " -h "
                + fromHostIp
                + " -U "
                + fromDbUser
                + " -d "
                + fromDbName
                + " -c \"\\copy "
                + "("
                + sql
                + ") TO " + tmpCopyCsvFile + " WITH CSV HEADER\""
                + " && "
                + "psql"
                + " -h "
                + toHostIp
                + " -U "
                + toDbUser
                + " -d "
                + toDbName
                + " -c \"\\copy " + toDb_table_prefix
                + tableName
                + "("
                + registColumnNames
                + ") FROM " + tmpCopyCsvFile + " WITH CSV HEADER\"";
        String[] command = new String[3];
        if ( "\\".equals(System.getProperty("file.separator")) ) {
            command[0] = "cmd.exe";
            command[1] = "/c";
        } else {
            command[0] = "sh";
            command[1] = "-c";
        }
        command[2] = copyCommand;
        return command;
    }

    /**
     * csv作成
     *
     * @param facilityCd
     * @param csvfileName
     * @param mstJsonMap
     * @throws IOException
     */
    private void createCsvFileAndToProduction(String facilityCd, String csvfileName, Map<String, JSONObject> mstJsonMap) throws IOException {
        String nkk5JdbcUrl = environment.getProperty("datasource." + ApplicationConst.DbType.NKK5 + ".jdbc-url");
        String nkk5UserName = environment.getProperty("datasource." + ApplicationConst.DbType.NKK5 + ".username");
        String to_Db_table_prefix = environment.getProperty("datasource." + ApplicationConst.DbType.NKK5 + ".table_prefix");
        String fromHostIp = nkk5JdbcUrl.split("/")[2].split(":")[0];
        String fromDbUser = nkk5UserName;
        String fromDbName = nkk5JdbcUrl.split("/")[3];
        Collection<String[]> resultDataList = new ArrayList<String[]>(Collections.EMPTY_LIST);
        if (resultDataList.isEmpty()) {
            resultDataList.add(MSTSELECTORTHEAD.split(","));
        }

        Set<String> setTableName = mstJsonMap.keySet();
        setTableName.stream().forEach(st -> {
            MstSelector mstSelector = new MstSelector();
            mstSelector.setFacilityCd(facilityCd);
            mstSelector.setMasterPhysicalName(st);
            mstSelector.setOrderSettings(mstJsonMap.get(st));
            mstSelector.setRegDate(Timestamp.valueOf(LocalDateTime.now()));
            mstSelector.setUpDate(Timestamp.valueOf(LocalDateTime.now()));
            String mstSelectorStr = mstSelector.toString();
            String[] mstSelectorArray = mstSelectorStr.split(",");
            if (mstSelectorArray[2].contains("|")) {
                mstSelectorArray[2] = mstSelectorArray[2].replace("|", ",");
            }
            resultDataList.add(mstSelectorArray);
        });

        try {
            File fileNew = new File(csvfileName);
            writeCsv(fileNew.toPath(), resultDataList);
            String registColumnNames = MSTSELECTORTHEAD;
            String copyCommand = "psql"
                    + " -h "
                    + fromHostIp
                    + " -U "
                    + fromDbUser
                    + " -d "
                    + fromDbName
                    + " -c \"\\copy " + to_Db_table_prefix
                    + "mst_selector"
                    + "("
                    + registColumnNames
                    + ") FROM "+ csvfileName +" WITH CSV HEADER\"";
            System.err.println("执行mst_selector.csv文件的COPY命令：" + copyCommand);
            String[] command = new String[3];
            if ("\\".equals(System.getProperty("file.separator"))) {
                command[0] = "cmd.exe";
                command[1] = "/c";
            } else {
                command[0] = "sh";
                command[1] = "-c";
            }
            command[2] = copyCommand;
            boolean c = this.processCmdSql(command, true, facilityCd);
            if (!c) {
                EventLogMessage eventLogMessageTable = eventLoggerUtil.getEventLogMessage(fileNew + "CSVインポート中にエラーが発生しました！",
                        facilityCd, "JdbcBatchSqlItemWriter.write(final List<? extends T> items)");
                eventLoggerUtil.recordLog(facilityCd, eventLogMessageTable, LogLevel.ERROR);
            }
            Path path = Paths.get(csvfileName);
            Files.deleteIfExists(path);

        } catch (Exception exception) {
            System.err.println(exception.toString());
        }
    }


    /**
     * mstテーブルに基づいて、order _settingsのjsonデータを作成
     *
     * @param facilityCd
     * @param tableName
     * @param code
     * @param name
     * @return
     */
    public JSONObject makeJsonSqlQuery(String facilityCd, String tableName, String code, String name) {
        JSONObject zz = new JSONObject();
        JSONArray mstJsonArray = new JSONArray();
        String to_Db_table_prefix = environment.getProperty("datasource." + ApplicationConst.DbType.NKK5 + ".table_prefix");
        DataSource convert = (DataSource) appContext.getBean(ApplicationConst.DbType.NKK5);
        machineJdbcTemplate = new NamedParameterJdbcTemplate(convert);
        String sql = "";
        if ("mst_kur".equals(tableName) ||tableName.equals("mst_user")) {
           sql = "SELECT json_build_object('code'," + code + ",'name'," + name + ",'jlac10Cd',NULL) AS mst_add_monitor FROM "
                    + to_Db_table_prefix + tableName + " WHERE facility_cd = ? AND is_del = '0'"
                    + " order by " + code;
        } else {
            sql = "SELECT json_build_object('code'," + code + ",'name'," + name + ",'jlac10Cd',NULL) AS mst_add_monitor FROM "
                    + to_Db_table_prefix + tableName + " WHERE facility_cd = ? AND is_disp = '1' and is_del = '0'"
                    + " order by " + code;
        }

        List<String> mstJsonStr = machineJdbcTemplate.getJdbcOperations().queryForList(sql, new Object[]{facilityCd}, String.class);
        if (!mstJsonStr.isEmpty()) {
            mstJsonStr.stream().forEach(mj -> {
                JSONObject mstJson = new JSONObject(mj);
                zz.put("items", mstJsonArray.put(mstJson));
            });
        }
        return zz;
    }
    /**
     * mstテーブルに基づいて、order _settingsのjsonデータを作成
     *
     * @param facilityCd
     * @param tableName
     * @param code
     * @param name
     * @return
     */
    public JSONObject makeJsonSqlQueryDiff(String facilityCd, String tableName, String code, String name, String fncode, String key) {
        JSONObject zz = new JSONObject();
        JSONArray mstJsonArray = new JSONArray();
        String to_Db_table_prefix = environment.getProperty("datasource." + ApplicationConst.DbType.NKK5 + ".table_prefix");
        DataSource convert = (DataSource) appContext.getBean(ApplicationConst.DbType.NKK5);
        machineJdbcTemplate = new NamedParameterJdbcTemplate(convert);
        String sql = "";
        // add #11546 limingyang start
        key = key.substring(1, key.length() - 1);
        key = Arrays.stream(key.split(","))
                .map(s -> "'" + s + "'")
                .collect(Collectors.joining(","));
        // add #11546 limingyang end
        if (tableName.equals("mst_user")) {

          to_Db_table_prefix = environment.getProperty("datasource." + ApplicationConst.DbType.NKK6 + ".table_prefix");
            // mod #11546 limingyang start
            sql = "SELECT json_build_object('code'," + code + ",'name'," + name + ",'jlac10Cd',NULL) FROM "
                    + to_Db_table_prefix + "mst_personal_user" + " WHERE facility_cd = ? AND is_del = '0'"
                    + " order by NULLIF(array_position(ARRAY["+key+"], fn_staff_cd::text), 0) NULLS FIRST";
            // mod #11546 limingyang end

            convert = (DataSource) appContext.getBean(ApplicationConst.DbType.NKK6);
            machineJdbcTemplate = new NamedParameterJdbcTemplate(convert);
        }
        else {
            // mod #11546 limingyang start
            sql = "SELECT json_build_object('code'," + code + ",'name'," + name + ",'jlac10Cd',NULL) FROM "
                    + to_Db_table_prefix + tableName + " WHERE facility_cd = ? AND is_disp = '1' and is_del = '0'"
                    + " order by NULLIF(array_position(ARRAY["+key+"],"+fncode+"::text), 0) NULLS FIRST";
            // mod #11546 limingyang end
        }

        List<String> mstJsonStr = machineJdbcTemplate.getJdbcOperations().queryForList(sql, new Object[]{facilityCd}, String.class);
        if (!mstJsonStr.isEmpty()) {
            mstJsonStr.stream().forEach(mj -> {
                JSONObject mstJson = new JSONObject(mj);
                zz.put("items", mstJsonArray.put(mstJson));
            });
        }
        return zz;
    }


    /**
     * Java呼び出しProcess実行CMDコマンド共通メソッド
     *
     * @param cmd
     * @param status
     * @return
     * @throws RuntimeException
     */
    private boolean processCmdSql (String[] cmd, boolean status,String facilityCd) throws RuntimeException {
        
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
            int exitCode = process.waitFor(); // 子プロセスの終了コードを取得
            process.destroy(); // 子プロセスを明示的に終了
            if (!org.springframework.util.ObjectUtils.isEmpty(et.getOutputString())) {
                EventLogMessage elm = eventLoggerUtil.getEventLogMessage(et.getOutputString(),
                        facilityCd, "processCmdSql(String[] cmd, boolean status)");
                eventLoggerUtil.recordLog(facilityCd, elm, LogLevel.WARN);
            }
            if (exitCode != 0) {
                exSuccess = false;
                EventLogMessage elm = eventLoggerUtil.getEventLogMessage(et.getOutputString(),
                        facilityCd, "processCmdSql(String[] cmd, boolean status)");
                eventLoggerUtil.recordLog(facilityCd, elm, LogLevel.ERROR);
            }
        } catch (IOException | InterruptedException e) {
            // TODO Auto-generated catch block
            eventLoggerUtil.recordLog(
                facilityCd,
                eventLoggerUtil.getEventLogMessage(
                        "processCmdSql (String[] cmd, boolean status) Java呼び出しProcess実行CMDコマンド共通メソッド：" + EventLoggerUtil.excetionStackTraceToString(e),
                        facilityCd,
                        e.getClass().getName() + ".processCmdSql()"),
                LogLevel.ERROR);
        }
        return exSuccess;
    }
    private void writeCsv(Path path, Collection<String[]> rows) throws IOException {
        try (CsvWriter csvWriter = CsvWriter.builder().build(path, StandardCharsets.UTF_8)) {
            for (String[] row : rows) {
                csvWriter.writeRecord(row);
            }
        }
    }

    @Bean(name=STEP_NAME)
    public Step step() {
        return new StepBuilder(STEP_NAME, jobRepository).listener(convertDeleteMstSelectorListener)
            .tasklet(this)
            .build();
    }
}