package batch.writer;

import batch.ApplicationConst;
import batch.entity.MniMonitor;
import batch.entity.MntMotionRecord;
import batch.entity.MstChecklist;
import batch.entity.MstDeviceEdge;
import batch.entity.MstDialyzer;
import batch.entity.MstDisease;
import batch.entity.MstEquipment;
import batch.entity.MstEquipmentClass;
import batch.entity.MstExamItem;
import batch.entity.MstExamSet;
import batch.entity.MstFavoriteFacility;
import batch.entity.MstMachine;
import batch.entity.MstPersonalUser;
import batch.entity.OrdChecklist;
import batch.entity.OrdCoopNo;
import batch.entity.OrdDevice;
import batch.entity.OrdMain;
import batch.entity.OrdTreatCondition;
import batch.entity.PatExamMain;
import batch.entity.PatPersonalMain;
import batch.entity.PatUniqueHistoryEntity;
import batch.entity.SysFacility;
import batch.entity.mongo.InOutVisitHistoryInfo;
import batch.entity.mongo.MedicalHstInfo;
import batch.entity.mongo.PhysicalInfo;
import batch.part.InfomationSchemaControl;
import batch.part.StreamThread;
import tools.jackson.databind.ObjectMapper;
import de.siegmar.fastcsv.reader.CsvReader;
import de.siegmar.fastcsv.reader.NamedCsvRecord;
import de.siegmar.fastcsv.writer.CsvWriter;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;
import java.util.stream.IntStream;
import javax.sql.DataSource;
import lombok.Data;
import lombok.Getter;
import lombok.Setter;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.batch.infrastructure.item.Chunk;
import org.springframework.batch.infrastructure.item.ItemWriter;
import org.springframework.beans.factory.InitializingBean;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.context.ApplicationContext;
import org.springframework.core.env.Environment;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.core.query.Update;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcOperations;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.jdbc.datasource.DataSourceTransactionManager;
import org.springframework.util.Assert;
import org.springframework.util.CollectionUtils;
import org.springframework.util.ObjectUtils;
import utils.GlobalContext;
import utils.Utils;
import web.config.EventLoggerUtil;
import web.logger.EventLogMessage;
import web.logger.LogLevel;
import static web.constant.CommonConstants.motionSleepMillis;


/**
 * ProcessorからCSVの文字列を受け取り実行するWriter
 */
public class BatchCsvWriterDb<T> implements ItemWriter<T>, InitializingBean {

    private NamedParameterJdbcOperations namedParameterJdbcTemplate;

    @Autowired
    @Qualifier("namedParameterJdbcTemplateNkk5")
    private NamedParameterJdbcTemplate namedParameterJdbcTemplateNkk5;

    @Autowired
    @Qualifier("namedParameterJdbcTemplateConvert")
    private NamedParameterJdbcTemplate namedParameterJdbcTemplateConvert;

    @Autowired
    private ApplicationContext appContext;

    @Autowired
    Utils utils;

    @Autowired
    private Environment environment;

    @Autowired(required = false)
    MongoTemplate mongoTemplate;

    /**
     * jsonの外部キー取得checklist _cdはcode条件を施すだけで、他の条件はないので、グローバル変数として格納
     */
    Map<String, MstChecklist> checklistCdMap = new HashMap<>();

    /**
     * パッチord _checklistのフィールド配列（csvファイル内の配列と一致）
     */
    private final String[] ordCheckListColumnNames = {"reg_date", "facility_cd", "ord_no", "list_cd", "occur_date", "up_date", "is_check", "func_class", "rst_class", "rst_checklist_info", "reg_staff_info"};

    /**
     * ord_treat_condition
     */
    private final String[] ordTreatConditionListColumnNames = {"up_date", "reg_date", "facility_cd", "machine_no", "receive_date", "treat_class", "is_disp", "is_del", "ord_no", "treat_condition"};

    /**
     * ord_coop_no
     */
    private final String[] ordCoopNoListColumnNames = {"facility_cd", "pat_id", "ord_no", "coop_cd", "coop_ord_no", "is_disp", "is_del", "user_id", "reg_date", "up_date", "status", "hosp_pat_id","coop_version"};
    // add #10930 zkm start
    /**
     * パッチpat_exam_mainのフィールド配列（csvファイル内の配列と一致）
     */
    private final String[] patExamMainSchColumnNames = {"facility_cd", "pat_id", "fn_pat_id", "order_label_info", "reg_exam_date", "reg_order_class", "ind_user_id", "reg_staff", "up_staff", "exam_status", "is_order", "data_gen_class", "up_date", "reg_date", "order_exam_set_info", "exam_order_info"};
    private final String[] patExamMainColumnNames = {"facility_cd", "pat_id", "fn_pat_id","order_exam_set_info","exam_order_info","order_label_info","result_exam_date", "reg_exam_date", "reg_order_class", "data_gen_class", "is_del", "exam_status","is_order", "up_date", "reg_date", "exam_result_info"};
    /**
     * #12173
     * パッチord mst_favorite_facility（csvファイル内の配列と一致）
     */
    private final String[] mstFavoriteFacilityColumnNames = {"facility_cd", "medical_institution_cd", "reg_date", "up_date"};




    private Boolean isPatExamMainSch;
    // add #10930 zkm end

    private final String EMPTY = "";

    private String facilityCd;

    private final GlobalContext globalContext;

    

    /**
     * コンストラクタでデータソースを設定
     */
    public BatchCsvWriterDb(DataSource dataSource, String fileName, String facilityCd, GlobalContext globalContext) {
        this.namedParameterJdbcTemplate = new NamedParameterJdbcTemplate(dataSource);
        this.facilityCd = facilityCd;
        this.globalContext = globalContext;
        this.globalContext.fileName = fileName;
    }

    /**
     * 必須プロパティの確認
     * - namedParameterJdbcTemplate -
     */
    @Override
    public void afterPropertiesSet() {
        Assert.notNull(namedParameterJdbcTemplate, "DataSourceまたはNamedParameterJdbcTemplateが必要です。");
    }

    /**
     * TransactionManager取り出し
     * @return トランザクション管理インスタンス
     */
    @Getter
    @Setter
    DataSourceTransactionManager transactionManager;

    /**
     * ロギング ツール クラスの導入
     */
    @Autowired
    private EventLoggerUtil eventLoggerUtil;

    /**
     * Java呼び出しProcess実行CMDコマンド共通メソッド
     *
     * @param cmd
     * @param status
     * @return
     * @throws RuntimeException
     */
    private boolean processCmdSql(String[] cmd, boolean status) throws RuntimeException {
        Process process = null;
        boolean exSuccess = true;
        try {
            if (status) { //statusはtrueであるから実行される
                System.err.println("true CMDコマンドを実行するには：" + cmd[2]);
                //数组执行
                process = Runtime.getRuntime().exec(cmd);
            } else {
                System.err.println("false CMDコマンドを実行するには：" + cmd[0]);
                //字符串执行
                process = Runtime.getRuntime().exec(cmd[0]);
            }
            // 子プロセスの標準出力および標準エラー出力を入力するスレッドを起動
            StreamThread it = new StreamThread(process.getInputStream());
            StreamThread et = new StreamThread(process.getErrorStream());
            it.start();
            et.start();
            // スレッドの終了を待つ
            it.join();
            et.join();
            // ストリームを一応明示的にクローズしておく
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
                            "processCmdSql(String[] cmd, boolean status) Java呼び出しProcess実行CMDコマンド共通メソッド ：" + EventLoggerUtil.excetionStackTraceToString(e),
                            facilityCd,
                            e.getClass().getName() + ".processCmdSql()"),
                    LogLevel.ERROR);
        }
        return exSuccess;
    }

    /**
     * 日付変換
     *
     * @param dateStr
     * @return
     */
    private Timestamp checkDate(String dateStr) throws ParseException {
        Timestamp time = null;
        if (!ObjectUtils.isEmpty(dateStr)) {
            time = new Timestamp(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").parse(dateStr.replace("/", "-")).getTime());
        }
        return time;
    }

    /**
     * copy csvエラーファイル処理
     *
     * @param fileName
     * @return
     * @throws IOException
     */
    private boolean errorfile(String fileName) throws IOException {
        String p = System.getProperty("user.dir");
        String targetPath = p + "/errorSqlFile";
        File file = new File(targetPath);
        if (!file.exists()) {
            file.mkdirs();
        }
        Path path = Paths.get(fileName);//ソースファイル
        try {
            String filePath = "";
            if ("\\".equals(System.getProperty("file.separator"))) {
                filePath = fileName.substring(fileName.lastIndexOf("\\"));
            } else {
                filePath = fileName.substring(fileName.lastIndexOf("/"));
            }
            Files.copy(path, new FileOutputStream(new File(targetPath + filePath)));
        } catch (IOException e) {
            eventLoggerUtil.recordLog(
                    facilityCd,
                    eventLoggerUtil.getEventLogMessage(
                            "errorfile(String fileName) copy csvエラーファイル処理 ：" + EventLoggerUtil.excetionStackTraceToString(e),
                            facilityCd,
                            e.getClass().getName() + ".errorfile()"),
                    LogLevel.ERROR);
        }
        //csvファイルの削除
        Files.deleteIfExists(path);
        return true;
    }

    /**
     * テーブル名に基づいてテーブルの現在の最大番号値を取得し、グローバル変数に割り当てます
     *
     * @param tableName テーブル名
     * @param seqName   シーケンス名
     * @return
     */
    private Long getTableMaxSeq(String tableName, String seqName) {
        String to_Db_table_prefix = environment.getProperty("datasource." + ApplicationConst.DbType.CONVERT + ".table_prefix");
        String sql = "SELECT MAX(" + seqName + ") FROM " + to_Db_table_prefix + tableName;
        Long maxSeq = namedParameterJdbcTemplateConvert.getJdbcOperations().queryForObject(sql, Long.class);
        if (maxSeq == null) {
            maxSeq = 0L;
        }
        globalContext.seq = maxSeq;
        return maxSeq;
    }

    private String getValueFromJsonByKey(String jsonStr, String jsonKey) {
        JSONObject jsonObject = new JSONObject(jsonStr);
        String value = ObjectUtils.isEmpty(jsonObject.get(jsonKey)) ? null : String.valueOf(jsonObject.get(jsonKey));
        if (ObjectUtils.isEmpty(value) || "null".equals(value)) {
            return null;
        }
        return value;
    }

    // add #10930 zkm start
    private List<String> getValueFromJsonArrayByKey(String jsonStr, String jsonKey) {
        List<String> resList = new ArrayList<>();
        if (Objects.isNull(jsonStr) || "null".equals(jsonStr)) {
            return resList;
        }
        JSONArray jsonArray = new JSONArray(jsonStr);
        jsonArray.forEach(i -> {
            JSONObject obj = parseJsonOrNull(i);
            String value = ObjectUtils.isEmpty(obj.get(jsonKey)) ? null : String.valueOf(obj.get(jsonKey));
            if (!ObjectUtils.isEmpty(value) && !"null".equals(value)) {
                resList.add(value);
            }
        });
        return resList;
    }
    // add #10930 zkm end

    private JSONObject setNullToJsonObject(JSONObject json, String key, Object val, String valType) {
        if (Objects.isNull(val) || "null".equals(val.toString())) {
            json.put(key, JSONObject.NULL);
        } else {
            if (valType.equals("Number")) {
                json.put(key, Integer.parseInt(val.toString()));
            } else {
                json.put(key, val.toString());
            }

        }
        return json;
    }

    private Integer getIntValue(Object obj) {
        if (Objects.isNull(obj) || "null".equals(obj.toString())) {
            return -1;
        }
        return Integer.valueOf(obj.toString());
    }

    private void processMntMotionRecord(Collection<String[]> resultDataList,
                                        List<NamedCsvRecord> rowList) throws IOException {
        String tableName = "mnt_motion_record";
        initMntMotionRecordOrdDeviceMap();
        globalContext.seq = 0;
        try {
            addMntMotionRecordHeaderIfEmpty(resultDataList, tableName);
            loadMntMotionRecordDeviceEdgeNo();
            Map<String, String> machineTypeCdTrastMap = getMachineTypeCdTrastMap(rowList);
            Map<String, String> machineSerialTrastMap = getMachineSerialTrastMap(rowList);
            Map<String, String> comFormatCdTrastMap = getComFormatCdTrastMap(rowList);
            Integer finalDeviceEdgeNo = globalContext.deviceEdgeNo;
            appendMntMotionRecordRows(resultDataList, rowList, machineTypeCdTrastMap, machineSerialTrastMap,
                    comFormatCdTrastMap, finalDeviceEdgeNo);
        } catch (Exception e) {
            handleMntMotionRecordException(e);
        }
    }

    /**
     * mnt_motion_record用ordDeviceMapを初期化する
     */
    private void initMntMotionRecordOrdDeviceMap() {
        // add #11162 mnt_motion_recordのパフォーマンス最適化 djy start
        if (globalContext.ordDeviceMap == null) {
            StringBuilder stringBuilder = new StringBuilder();
            stringBuilder.append("select om.ord_no,om.rst_accept_date,om.rst_end_date,mm.fn_device_no,om.rst_fn_dialysis_no ");
            stringBuilder.append(" from ord_main om inner join mst_machine mm ");
            stringBuilder.append(" on om.rst_machine_no = mm.machine_no and om.facility_cd=mm.facility_cd");
            stringBuilder.append(" where om.facility_cd = :facility_cd and om.rst_accept_date is not null " +
                    "and om.rst_end_date is not null and mm.fn_device_no is not null and om.rst_fn_dialysis_no is not null");
            String deviceOrdSql = stringBuilder.toString();
            MapSqlParameterSource params = new MapSqlParameterSource();
            params.addValue("facility_cd", facilityCd);
            List<OrdDevice> ordDeviceList = namedParameterJdbcTemplateNkk5.query(deviceOrdSql, params, new BeanPropertyRowMapper<>(OrdDevice.class));
            globalContext.ordDeviceMap = ordDeviceList.stream().collect(Collectors.groupingBy(OrdDevice::getRstFnDialysisNo));
        }
        // add #11162 mnt_motion_recordのパフォーマンス最適化 djy end
    }

    /**
     * resultDataListが空の場合にヘッダ行を追加する
     */
    private void addMntMotionRecordHeaderIfEmpty(Collection<String[]> resultDataList, String tableName) {
            if (resultDataList.isEmpty()) {
                // 取得テーブルの列を取得
                InfomationSchemaControl isc = new InfomationSchemaControl(appContext);
                List<String> columnNameList = null;
                try {
                columnNameList = isc.getColumnNamesForCodeConversion(tableName);
                } catch (Exception exception) {
                    eventLoggerUtil.recordLog(
                            facilityCd,
                            eventLoggerUtil.getEventLogMessage(
                                    "processMntMotionRecord(Collection<String[]> resultDataList, List<NamedCsvRecord> rowList)："  + EventLoggerUtil.excetionStackTraceToString(exception),
                                    facilityCd,
                                    exception.getClass().getName() + ".processMntMotionRecord()"),
                            LogLevel.ERROR);
                }
                // 登録列名リストをカンマ区切りに変換
                String registColumnNames = String.join(",", columnNameList);
                //最初の番号を削除し、最初のデータ、以降のデータを切り取る
                registColumnNames = registColumnNames.substring(registColumnNames.indexOf(",") + 1);
                resultDataList.add(registColumnNames.split(","));
            }
    }

    /**
     * mst_device_edgeのdevice_edge_noを読み込む
     */
    private void loadMntMotionRecordDeviceEdgeNo() {
            //mod #12229 start
            if (ObjectUtils.isEmpty(globalContext.deviceEdgeNo)) {
                String exSql = "SELECT MIN(device_edge_no) AS deviceEdgeNo FROM mst_device_edge WHERE facility_cd = ?";
                List<MstDeviceEdge> deviceEdgeNoList = namedParameterJdbcTemplateNkk5.getJdbcOperations().query(exSql, new Object[]{facilityCd}, new BeanPropertyRowMapper<>(MstDeviceEdge.class));
                if (deviceEdgeNoList.size() == 1) {
                    globalContext.deviceEdgeNo = deviceEdgeNoList.get(0).getDeviceEdgeNo();
                }
            }
            //mod #12229 end
    }

    /**
     * CSV各行をmnt_motion_recordとしてresultDataListに追加する
     */
    private void appendMntMotionRecordRows(Collection<String[]> resultDataList, List<NamedCsvRecord> rowList,
                                           Map<String, String> machineTypeCdTrastMap,
                                           Map<String, String> machineSerialTrastMap,
                                           Map<String, String> comFormatCdTrastMap,
                                           Integer finalDeviceEdgeNo) {
            rowList.forEach(row -> {

                //取得した各行をMntMotionRecordオブジェクトに入れる
                MntMotionRecord mntMotionRecord = new MntMotionRecord();

                try {
                    mntMotionRecord.setEventRegDate(ObjectUtils.isEmpty(row.getField("event_reg_date")) ? null : this.checkDate(row.getField("event_reg_date")));
                } catch (ParseException e) {
                    eventLoggerUtil.recordLog(facilityCd, eventLoggerUtil.getEventLogMessage("CSVファイル中の event_reg_date 列のデータで解析エラーが発生しました。該当する行はスキップされました:" + globalContext.fileName,
                            facilityCd, "BatchCsvWriterDb.write()"), LogLevel.ERROR);
                }
                mntMotionRecord.setMNoticeStatus(parseIntOrNull(row.getField("m_notice_status")));
                mntMotionRecord.setFacilityCd(valueOrNull(row.getField("facility_cd")));
                mntMotionRecord.setDataType(parseIntOrNull(row.getField("data_type")));
                mntMotionRecord.setTestType(parseIntOrNull(row.getField("test_type")));
                mntMotionRecord.setGatheringManageNo(parseLongOrNull(row.getField("gathering_manage_no")));
                try {
                    mntMotionRecord.setEmailSendDate(ObjectUtils.isEmpty(row.getField("email_send_date")) ? null : this.checkDate(row.getField("email_send_date")));
                } catch (ParseException e) {
                    eventLoggerUtil.recordLog(facilityCd, eventLoggerUtil.getEventLogMessage("CSVファイル中の email_send_date 列のデータで解析エラーが発生しました。該当する行はスキップされました:" + globalContext.fileName,
                            facilityCd, "BatchCsvWriterDb.write()"), LogLevel.ERROR);
                }
                mntMotionRecord.setEmailText(valueOrNull(row.getField("email_text")));
                mntMotionRecord.setMachineRecordCd(valueOrNull(row.getField("machine_record_cd")));
                try {
                    mntMotionRecord.setMachineRecordMessage(ObjectUtils.isEmpty(row.getField("machine_record_message")) ? null : trimNull(row.getField("machine_record_message")));
                } catch (UnsupportedEncodingException e) {
                    eventLoggerUtil.recordLog(facilityCd, eventLoggerUtil.getEventLogMessage("CSVファイル中の machine_record_message 列のデータで解析エラーが発生しました。文字コードが不正です。該当する行はスキップされました:" + e.getMessage(),
                            facilityCd, "BatchCsvWriterDb.write()"), LogLevel.ERROR);
                }
                //jsonフォーマット特殊処理
                mntMotionRecord.setContents(ObjectUtils.isEmpty(row.getField("contents")) ? null : row.getField("contents").replace(",", "|"));
                mntMotionRecord.setMachineRecordMessage(ObjectUtils.isEmpty(row.getField("machine_record_message")) ? null : row.getField("machine_record_message").replace(",", "|"));
                //カンマを含む値を特殊な置換処理を行い、分割の最後に置換します。
                mntMotionRecord.setMachineRecordAuxData(ObjectUtils.isEmpty(row.getField("machine_record_aux_data")) ? null : row.getField("machine_record_aux_data").replace(",", "|"));

                mntMotionRecord.setEmailAddress(valueOrNull(row.getField("email_address")));
                mntMotionRecord.setEmailName(valueOrNull(row.getField("email_name")));
                mntMotionRecord.setRemarks(valueOrNull(row.getField("remarks")));
                mntMotionRecord.setIsCorrection(valueOrNull(row.getField("is_correction")));
                //user_idデフォルトcsvには値がありません。デフォルトはnullに与えられます（つまり、set値を入れる必要はありません）
                mntMotionRecord.setLogType(ObjectUtils.isEmpty(row.getField("log_type")) ? null : Short.parseShort(row.getField("log_type")));
                try {
                    mntMotionRecord.setRegDate(ObjectUtils.isEmpty(row.getField("reg_date")) ? null : this.checkDate(row.getField("reg_date")));
                } catch (ParseException e) {
                    eventLoggerUtil.recordLog(facilityCd, eventLoggerUtil.getEventLogMessage("CSVファイル中の reg_date 列のデータで解析エラーが発生しました。該当する行はスキップされました:" + globalContext.fileName,
                            facilityCd, "BatchCsvWriterDb.write()"), LogLevel.ERROR);
                }
                try {
                    mntMotionRecord.setUpDate(ObjectUtils.isEmpty(row.getField("up_date")) ? null : this.checkDate(row.getField("up_date")));
                } catch (ParseException e) {
                    eventLoggerUtil.recordLog(facilityCd, eventLoggerUtil.getEventLogMessage("CSVファイル中の up_date 列のデータで解析エラーが発生しました。該当する行はスキップされました:" + globalContext.fileName,
                            facilityCd, "BatchCsvWriterDb.write()"), LogLevel.ERROR);
                }
                try {
                    mntMotionRecord.setIsCorrectionUpDate(ObjectUtils.isEmpty(row.getField("is_correction_up_date")) ? null : this.checkDate(row.getField("is_correction_up_date")));
                } catch (ParseException e) {
                    eventLoggerUtil.recordLog(facilityCd, eventLoggerUtil.getEventLogMessage("CSVファイル中の is_correction_up_date 列のデータで解析エラーが発生しました。該当する行はスキップされました:" + globalContext.fileName,
                            facilityCd, "BatchCsvWriterDb.write()"), LogLevel.ERROR);
                }
                mntMotionRecord.setServiceSupportType(valueOrNull(row.getField("service_support_type")));
                mntMotionRecord.setServiceSupportUserId(parseLongOrNull(row.getField("service_support_user_id")));
                try {
                    mntMotionRecord.setServiceSupportUpDate(ObjectUtils.isEmpty(row.getField("service_support_up_date")) ? null : this.checkDate(row.getField("service_support_up_date")));
                } catch (ParseException e) {
                    eventLoggerUtil.recordLog(facilityCd, eventLoggerUtil.getEventLogMessage("CSVファイル中の service_support_up_date 列のデータで解析エラーが発生しました。該当する行はスキップされました:" + globalContext.fileName,
                            facilityCd, "BatchCsvWriterDb.write()"), LogLevel.ERROR);
                }
                mntMotionRecord.setReportDispFlg(valueOrNull(row.getField("report_disp_flg")));
                //追加されたカラムは、条件としてのみ使用され、csvファイルに書き直す必要はありません
                String device_type = ObjectUtils.isEmpty(row.getField("device_type")) ? null : row.getField("device_type"); //com_format_cd的クエリー条件

                /**
                 * 対応する属性をヘッダから取得するには
                 */
                mntMotionRecord.setDeviceEdgeNo(finalDeviceEdgeNo);

                //外部キーcom_format_cd
                String com_format_cd = row.getField("com_format_cd");
                if (!ObjectUtils.isEmpty(com_format_cd)) {
                    String cdkey = com_format_cd + "-" + device_type;
                    if (comFormatCdTrastMap.containsKey(cdkey)) {
                        mntMotionRecord.setComFormatCd(comFormatCdTrastMap.get(cdkey));
                    }
                }
                //外部キーmachine_serial
                String machine_serial = row.getField("machine_serial");
                if (!ObjectUtils.isEmpty(machine_serial)) {
                    String mskey = machine_serial + "-" + device_type;
                    if (machineSerialTrastMap.containsKey(mskey)) {
                        mntMotionRecord.setMachineSerial(machineSerialTrastMap.get(mskey));
                    }
                }
                //外部キーmachine_type_cd
                String machine_type_cd = row.getField("machine_type_cd");
                if (!ObjectUtils.isEmpty(machine_type_cd)) {
                    String mdkey = machine_type_cd + "-" + device_type;
                    if (machineTypeCdTrastMap.containsKey(mdkey)) {
                        mntMotionRecord.setMachineTypeCd(machineTypeCdTrastMap.get(mdkey));
                    }
                }
                //外部キーord_no
                String ord_no = row.getField("ord_no");
                if (!ObjectUtils.isEmpty(ord_no)) {
                    String[] split = ord_no.split(",");
                    if (split != null && globalContext.ordDeviceMap != null) {
                        if (globalContext.ordDeviceMap.containsKey(Long.parseLong(split[0]))) {
                            try {
                                SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");//设置日期格式
                                Date date = df.parse(split[1]);
                                List<OrdDevice> ordDevices = globalContext.ordDeviceMap.get(Long.parseLong(split[0]));
                                List<OrdDevice> collect = ordDevices.stream()
                                        .filter(o -> date.compareTo(o.getRstAcceptDate()) >= 0 && date.compareTo(o.getRstEndDate()) <= 0)
                                        .collect(Collectors.toList());
                                if(collect!= null &&!collect.isEmpty()){
                                    mntMotionRecord.setOrdNo(collect.get(0).getOrdNo());
                                }
                            } catch (ParseException e) {
                                eventLoggerUtil.recordLog(facilityCd, eventLoggerUtil.getEventLogMessage("CSVファイル中の ord_no 列のデータで解析エラーが発生しました。該当する行はスキップされました:" + globalContext.fileName,
                                        facilityCd, "BatchCsvWriterDb.write()"), LogLevel.ERROR);

                            }
                        }
                    }
                }
                //mntのjson列の置換｜は、（index=14、つまり15番目の要素として知られている）であり、rdlのnullフィールドがすべて「」に置換され、最後のデータが切り取られた場合（device _ typeは表のフィールドに属していない）
                String mntMotionRecordStr = mntMotionRecord.toString();
                String[] rdl = mntMotionRecordStr.split(",");
                if (rdl[14].contains("|")) {
                    rdl[14] = rdl[14].replace("|", ",");
                }
                if (rdl[15].contains("|")) {
                    rdl[15] = rdl[15].replace("|", ",");
                }
                if (rdl[13].contains("|")) {
                    rdl[13] = rdl[13].replace("|", ",");
                }
                //各行置換後の最終結果データセットの書き込み
                resultDataList.add(rdl);

                // ループで使うオブジェクトをnullにして、ガベージコレクションの対象にする
                mntMotionRecord = null;
            });
    }

    /**
     * mnt_motion_record処理の例外をログ出力する
     */
    private void handleMntMotionRecordException(Exception e) throws IOException {
            eventLoggerUtil.recordLog(facilityCd, eventLoggerUtil.getEventLogMessage("CSVファイルの処理に失敗しました：" + globalContext.fileName,
                    facilityCd, "BatchCsvWriterDb.write()"), LogLevel.ERROR);
            eventLoggerUtil.recordLog(facilityCd, eventLoggerUtil.getEventLogMessage("詳細なエラー情報：" + e.toString(),
                    facilityCd, "BatchCsvWriterDb.write()"), LogLevel.ERROR);
            this.errorfile(globalContext.fileName);
    }

    /**
     * csvはmachine _type_cdとdevice _typeパケット（machine _ type _ cdとdevice _ typeは並列条件として検索するため、この2つのフィールドで同時にグループ化するしかない）
     * @param rowList data
     * @return
     */
    private Map<String, String> getMachineTypeCdTrastMap(List<NamedCsvRecord> rowList){
        Map<String, String> machineTypeCdTrastMap = new HashMap<>();
        Map<Object, List<NamedCsvRecord>> machine_type_cd_group = rowList.stream().collect(Collectors.groupingBy(r -> {
            return r.getField("machine_type_cd") + "-" + r.getField("device_type");
        }));
        //machine _type_cd_groupのkey（key値はcsvのmachine _ type _ cdの値）、DB検索に使用される
        Set<Object> machine_type_cd_key = machine_type_cd_group.keySet();
        machine_type_cd_key.forEach(mach -> {
            String[] array = String.valueOf(mach).split("-");
            List<MstMachine> machineTypeCdList;
            if (array[1].equals("1")) {
                machineTypeCdList = globalContext.MstMachineList.stream().filter(aa -> aa.getFnDeviceNo().toString().equals(array[0]) && aa.getFnClassCd().equals("0")).toList();
            } else {
                machineTypeCdList = globalContext.MstMachineList.stream().filter(aa -> aa.getFnDeviceNo().toString().equals(array[0]) && aa.getFnClassCd().equals("1")).toList();
            }
            if (machineTypeCdList.size() == 1) {
                if (!ObjectUtils.isEmpty(machineTypeCdList.get(0).getMachineTypeCd())) {
                    String mtc = String.valueOf(machineTypeCdList.get(0).getMachineTypeCd());
                    machineTypeCdTrastMap.put(mach.toString(), mtc); //含まないときは入れる
                } else {
                    machineTypeCdTrastMap.put(mach.toString(), null);
                }
            } else {
                machineTypeCdTrastMap.put(mach.toString(), null);
            }
        });
        return machineTypeCdTrastMap;
    }

    /**
     * CSVの各行データを **`machine_serial + device_type`** でグループ化し、
     * マスタデータである **`globalContext.MstMachineList`** から一意に一致する機器を検索し、
     * **key = machine_serial-device_type、value = 機器の machineSerial（存在しない場合は null）**
     * という形式の Map を生成します。
     * @param rowList
     * @return
     */
    private Map<String, String> getMachineSerialTrastMap(List<NamedCsvRecord> rowList) {
        Map<String, String> machineSerialTrastMap = new HashMap<>();
        Map<Object, List<NamedCsvRecord>> machine_serial_group = rowList.stream().collect(Collectors.groupingBy(r -> {
            return r.getField("machine_serial") + "-" + r.getField("device_type");
        }));
        Set<Object> machine_serial_key = machine_serial_group.keySet();
        machine_serial_key.forEach(ma -> {
            String[] machineSerialArray = String.valueOf(ma).split("-");
            List<MstMachine> cmachineSerialList;
            if (machineSerialArray[1].equals("1")) {
                cmachineSerialList = globalContext.MstMachineList.stream().filter(aa -> aa.getFnDeviceNo().toString().equals(machineSerialArray[0]) && aa.getFnClassCd().equals("0")).toList();
            } else {
                cmachineSerialList = globalContext.MstMachineList.stream().filter(aa -> aa.getFnDeviceNo().toString().equals(machineSerialArray[0]) && aa.getFnClassCd().equals("1")).toList();
            }
            if (cmachineSerialList.size() == 1) {
                if (!ObjectUtils.isEmpty(cmachineSerialList.get(0).getMachineSerial())) {
                    String ms = String.valueOf(cmachineSerialList.get(0).getMachineSerial());
                    machineSerialTrastMap.put(ma.toString(), ms);
                } else {
                    machineSerialTrastMap.put(ma.toString(), null);
                }
            } else {
                machineSerialTrastMap.put(ma.toString(), null);
            }
        });
        return machineSerialTrastMap;
    }

    /**
     * 各行の **`com_format_cd` と `device_type` を組み合わせてグループ化**し、
     * その組み合わせ条件をもとに、機器マスタデータ（`MstMachineList`）から **一意に一致する機器情報** を検索します。
     * @param rowList
     * @return
     */
    private Map<String, String> getComFormatCdTrastMap(List<NamedCsvRecord> rowList) {
        Map<String, String> comFormatCdTrastMap = new HashMap<>();
        Map<Object, List<NamedCsvRecord>> com_format_cd_group = rowList.stream()
                .collect(Collectors.groupingBy(r -> {
                    return r.getField("com_format_cd") + "-" + r.getField("device_type");
                }));
        Set<Object> com_format_cd_key = com_format_cd_group.keySet();
        com_format_cd_key.forEach(com -> {
            String[] comFormatCdArray = String.valueOf(com).split("-");

            List<MstMachine> comFormatCdList;
            if (comFormatCdArray[1].equals("1")) {
                comFormatCdList = globalContext.MstMachineList.stream().filter(aa -> aa.getFnDeviceNo().toString().equals(comFormatCdArray[0]) && aa.getFnClassCd().equals("0")).toList();
            } else {
                comFormatCdList = globalContext.MstMachineList.stream().filter(aa -> aa.getFnDeviceNo().toString().equals(comFormatCdArray[0]) && aa.getFnClassCd().equals("1")).toList();
            }
            if (comFormatCdList.size() == 1) {
                if (!ObjectUtils.isEmpty(comFormatCdList.get(0).getComFormatCd())) {
                    String cfc = String.valueOf(comFormatCdList.get(0).getComFormatCd());
                    comFormatCdTrastMap.put(com.toString(), cfc);
                } else {
                    comFormatCdTrastMap.put(com.toString(), null);
                }
            } else {
                comFormatCdTrastMap.put(com.toString(), null);
            }
        });
        return comFormatCdTrastMap;
    }

    //add #12173 start
    //スペース削除
    public static String removeAllSpacesFast(String s) {
        if (s == null || s.isEmpty()) {
            return s;
        }
        int len = s.length();
        StringBuilder sb = new StringBuilder(len);

        for (int i = 0; i < len; i++) {
            char c = s.charAt(i);
            if (c != ' ' && c != '　') {
                sb.append(c);
            }
        }
        return sb.toString();
    }

    //スペース分割、一番右
    public static String getLastWord(String name) {
        if (name == null) {
            return null;
        }

        int end = name.length() - 1;

        while (end >= 0) {
            char c = name.charAt(end);
            if (c != ' ' && c != '　') {
                break;
            }
            end--;
        }

        if (end < 0) {
            return "";
        }

        int start = end;
        while (start >= 0) {
            char c = name.charAt(start);
            if (c == ' ' || c == '　') {
                break;
            }
            start--;
        }
        return name.substring(start + 1, end + 1);
    }
    //すべて「先行文字」の削除
    public static String removePeliminaryDocumentPrefix(
            String facilityName,
            List<String> peliminaryDocumentList) {

        if (facilityName == null || facilityName.isEmpty()) {
            return facilityName;
        }
        String result = facilityName;
        for (String prefix : peliminaryDocumentList) {
            if (result.startsWith(prefix)) {
                result = result.substring(prefix.length());
                break;
            }
        }
        return result;
    }
    //add #12173 end

    private void processMstFavoriteFacility(Collection<String[]> resultDataList,
                                            List<NamedCsvRecord> rowList) throws Exception {
        String tableName="mst_favorite_facility";
        List<SysFacility> resultList = loadMstFavoriteFacilitySysFacilityList();
        initMstFavoriteFacilityColumnFlags(tableName);
        List<String> facilityCdList = loadMstFavoriteFacilityDiffCdList();
        List<MstFavoriteFacility> mstFavoriteFacilitys = new ArrayList<>();
        rowList.forEach(row -> processMstFavoriteFacilityRow(resultDataList, row, resultList, facilityCdList, mstFavoriteFacilitys));
        appendMstFavoriteFacilityResultRows(resultDataList, mstFavoriteFacilitys);
    }

    /**
     * sys_facilityから表示対象施設一覧を取得する
     */
    private List<SysFacility> loadMstFavoriteFacilitySysFacilityList() {
        String miCdSql = "SELECT facility_name, prefectures_cd, medical_institution_cd " +
                " FROM sys_facility WHERE is_disp = '1'";
        return namedParameterJdbcTemplateNkk5.getJdbcOperations().query(miCdSql, new Object[]{}, new BeanPropertyRowMapper<>(SysFacility.class));
    }

    /**
     * mst_favorite_facilityの列情報からfacility_cd有無フラグを設定する
     */
    private void initMstFavoriteFacilityColumnFlags(String tableName) throws Exception {
        InfomationSchemaControl isc = new InfomationSchemaControl(appContext);
        List<String> columnNameList = isc.getColumnNamesForCodeConversion(tableName);
        globalContext.hasFacilityCd = columnNameList.stream().anyMatch(x -> x.equals("facility_cd"));
    }

    /**
     * 差分処理時の既存medical_institution_cd一覧を取得する
     */
    private List<String> loadMstFavoriteFacilityDiffCdList() {
        if (globalContext.fileName.contains("[diff]")) {
            globalContext.sqlKeys = "";
            globalContext.sqlNewKeys = "";
            String cdSql = "select medical_institution_cd from  mst_favorite_facility where  facility_cd= ? ";
            return namedParameterJdbcTemplateNkk5.getJdbcOperations().queryForList(
                    cdSql,
                    new Object[]{facilityCd},
                    String.class
            );
        }
        return new ArrayList<>();
    }

    /**
     * mst_favorite_facilityのCSV1行を処理する
     */
    private void processMstFavoriteFacilityRow(Collection<String[]> resultDataList,
                                               NamedCsvRecord row,
                                                 List<SysFacility> resultList,
                                                 List<String> facilityCdList,
                                                 List<MstFavoriteFacility> mstFavoriteFacilitys) {
            if (resultDataList.isEmpty()) {
                resultDataList.add(mstFavoriteFacilityColumnNames);
            }
            MstFavoriteFacility mstFavoriteFacility = new MstFavoriteFacility();

            String facility_cd = row.getField("facility_cd");
            if (!ObjectUtils.isEmpty(facility_cd)) {
                mstFavoriteFacility.setFacilityCd(facility_cd);
            }
            String facility_name = row.getField("facility_name");
            String prefectures_cd= row.getField("prefectures_cd");
            List<String>  cdList=new ArrayList<>();

            //県コード+名称　ヒットの施設全部追加
            if(!ObjectUtils.isEmpty(prefectures_cd)){
            collectMstFavoriteFacilityCdListWithPrefecture(facility_name, prefectures_cd, resultList, mstFavoriteFacilitys, cdList);
        } else {
            collectMstFavoriteFacilityCdListWithoutPrefecture(facility_name, resultList, mstFavoriteFacilitys, cdList);
        }
        if (cdList.size() == 0) {
            return;
        }
        addMstFavoriteFacilityRowsFromCdList(row, mstFavoriteFacility, cdList, facilityCdList, mstFavoriteFacilitys);
    }

    /**
     * 県コード指定時の施設名マッチングでmedical_institution_cdを収集する
     */
    private void collectMstFavoriteFacilityCdListWithPrefecture(String facility_name,
                                                                String prefectures_cd,
                                                                List<SysFacility> resultList,
                                                                List<MstFavoriteFacility> mstFavoriteFacilitys,
                                                                List<String> cdList) {
                String s1 = removeAllSpacesFast(facility_name);
                List<SysFacility> filteredList =
                        resultList.stream()
                                .filter(f -> prefectures_cd.equals(f.getPrefecturesCd()))
                                .filter(f -> {
                                    String fn = f.getFacilityName();
                                    return removeAllSpacesFast(fn).contains(s1);
                                })
                                .collect(Collectors.toList());

                for (SysFacility facility : filteredList) {
                    boolean matched = false;
                    //①完全一致
                    if (facility_name.equals(facility.getFacilityName())) {
                        matched = true;
            } else {
                        String s2 = removeAllSpacesFast(facility.getFacilityName());
                        //②スペース抜きで完全一致
                        if(s1.equals(s2)){
                            matched = true;
                        }else {
                            //③上記FNW+「先行文字」をつけて①②完全一致
                            for (String peliminaryDocument:utils.peliminaryDocumentList){
                                if((peliminaryDocument+s1).equals(s2)){
                                    matched = true;
                                    break;
                                }
                            }
                        }
                    }
                    //⑤スペース分割、一番右の単語と完全一致
                    if (!matched) {
                        String last = getLastWord(facility.getFacilityName());
                        if (s1.equals(last)) {
                            matched = true;
                        }
                    }
                    if (matched) {
                        String cd = facility.getMedicalInstitutionCd();
                        boolean exists = mstFavoriteFacilitys.stream()
                                .anyMatch(x -> cd.equals(x.getMedicalInstitutionCd()));
                        if (!exists) {
                            cdList.add(cd);
                        }
                    }
                }
    }

    /**
     * 県コード未指定時の施設名マッチングでmedical_institution_cdを収集する
     */
    private void collectMstFavoriteFacilityCdListWithoutPrefecture(String facility_name,
                                                                   List<SysFacility> resultList,
                                                                   List<MstFavoriteFacility> mstFavoriteFacilitys,
                                                                   List<String> cdList) {
                String s1NoCd = removeAllSpacesFast(facility_name);
                List<SysFacility> filteredList =
                        resultList.stream()
                                .filter(f -> {
                                    String fn = f.getFacilityName();
                                    return removeAllSpacesFast(fn).contains(s1NoCd);
                                })
                                .collect(Collectors.toList());
                for (SysFacility facility : filteredList) {
                    boolean matchedNoCd = false;
                    //①完全一致
                    if (facility_name.equals(facility.getFacilityName())) {
                        matchedNoCd = true;
                    }else{
                        String s2 = removeAllSpacesFast(facility.getFacilityName());
                        //②スペース抜きで完全一致
                        if(s1NoCd.equals(s2)){
                            matchedNoCd = true;
                        }else {
                            //③上記FNW+「先行文字」をつけて①②完全一致
                            for (String peliminaryDocument:utils.peliminaryDocumentList){
                                if((peliminaryDocument+s1NoCd).equals(s2)){
                                    matchedNoCd = true;
                                    break;
                                }
                            }
                        }
                    }
                    //④上記「先行文字」の場合、スペース分割、一番右の単語と完全一致
                    if (!matchedNoCd) {
                        String  fnsi_Name=removePeliminaryDocumentPrefix(facility.getFacilityName(),utils.peliminaryDocumentList);
                        String last = getLastWord(fnsi_Name);
                        if (s1NoCd.equals(last)) {
                            matchedNoCd = true;
                        }
                    }
                    if (matchedNoCd) {
                        String cd = facility.getMedicalInstitutionCd();
                        boolean exists = mstFavoriteFacilitys.stream()
                                .anyMatch(x -> cd.equals(x.getMedicalInstitutionCd()));
                        if (!exists) {
                            cdList.add(cd);
                        }
                    }
                }

            }

    /**
     * 収集したmedical_institution_cdからMstFavoriteFacility行を生成する
     */
    private void addMstFavoriteFacilityRowsFromCdList(NamedCsvRecord row,
                                                      MstFavoriteFacility mstFavoriteFacility,
                                                      List<String> cdList,
                                                      List<String> facilityCdList,
                                                      List<MstFavoriteFacility> mstFavoriteFacilitys) {
                if (globalContext.fileName.contains("[diff]")) {
                    cdList.removeAll(facilityCdList);
                }
                for (String value : cdList) {
                    mstFavoriteFacility.setMedicalInstitutionCd(value);
                    String regDate = row.getField("reg_date");
                    if (!ObjectUtils.isEmpty(regDate)) {
                        try {
                            mstFavoriteFacility.setRegDate(this.checkDate(regDate));
                        } catch (ParseException e) {
                            eventLoggerUtil.recordLog(
                                    facilityCd,
                                    eventLoggerUtil.getEventLogMessage(
                                            "processMstFavoriteFacility(Collection<String[]> resultDataList, List<NamedCsvRecord> rowList)："  + EventLoggerUtil.excetionStackTraceToString(e),
                                            facilityCd,
                                            e.getClass().getName() + ".processMstFavoriteFacility()"),
                                    LogLevel.ERROR);
                        }
                    }
                    String upDate = row.getField("up_date");
                    if (!ObjectUtils.isEmpty(upDate)) {
                        try {
                            mstFavoriteFacility.setUpDate(this.checkDate(upDate));
                        } catch (ParseException e) {
                            eventLoggerUtil.recordLog(
                                    facilityCd,
                                    eventLoggerUtil.getEventLogMessage(
                                            "processMstFavoriteFacility(Collection<String[]> resultDataList, List<NamedCsvRecord> rowList)："  + EventLoggerUtil.excetionStackTraceToString(e),
                                            facilityCd,
                                            e.getClass().getName() + ".processMstFavoriteFacility()"),
                                    LogLevel.ERROR);
                        }
                    }
                    mstFavoriteFacilitys.add(mstFavoriteFacility);
                }
            }

    /**
     * 生成したMstFavoriteFacility一覧をresultDataListに追加する
     */
    private void appendMstFavoriteFacilityResultRows(Collection<String[]> resultDataList,
                                                     List<MstFavoriteFacility> mstFavoriteFacilitys) {
        for (MstFavoriteFacility mstFavorite : mstFavoriteFacilitys){
            String[] rdl = mstFavorite.toString().split(",");
            resultDataList.add(rdl);
        }
    }

    private void processMniMonitor(Collection<String[]> resultDataList,
                                   List<NamedCsvRecord> rowList) throws IOException {
        String tableName = "mni_monitor";
        String csvfileName = globalContext.fileName;
        //convertテーブルの最大番号を取る
        globalContext.seq = 0;
        try {
            //重複クエリDBの役割を比較するためのMapの宣言
            Map<String, String> ordNoTrastMap_mni = new HashMap<>();
            Map<String, String> machineTypeCdTrastMap_mni = new HashMap<>();
            Map<String, String> machineSerialTrastMap_mni = new HashMap<>();
            Map<String, String> patIdTrastMap_mni = new HashMap<>();
            addMniMonitorHeaderIfEmpty(resultDataList, tableName);
            loadMniMonitorMachineSerialMap(rowList, machineSerialTrastMap_mni);
            loadMniMonitorOrdNoMap(rowList, ordNoTrastMap_mni);
            loadMniMonitorPatIdMap(rowList, patIdTrastMap_mni);
            List<String> ordNoList = new ArrayList<String>();
            appendMniMonitorRows(resultDataList, rowList, machineTypeCdTrastMap_mni, machineSerialTrastMap_mni,
                    ordNoTrastMap_mni, patIdTrastMap_mni);
            updateMniMonitorDiffSqlKeys(ordNoList);
        } catch (Exception ex) {
            handleProcessMniMonitorException(ex, csvfileName);
        }
    }

    /**
     * resultDataListが空の場合にmni_monitorヘッダ行を追加する
     */
    private void addMniMonitorHeaderIfEmpty(Collection<String[]> resultDataList, String tableName) throws Exception {
            if (resultDataList.isEmpty()) {
                // 取得テーブルの列を取得
                InfomationSchemaControl isc = new InfomationSchemaControl(appContext);
                List<String> columnNameList = isc.getColumnNamesForCodeConversion(tableName);
                // 登録列名リストをカンマ区切りに変換
                String registColumnNames = String.join(",", columnNameList);
                //最初の番号を削除し、最初のデータ、以降のデータを切り取る
                registColumnNames = registColumnNames.substring(registColumnNames.indexOf(",") + 1);
                resultDataList.add(registColumnNames.split(","));
            }
    }

    /**
     * machine_serial外部キーの変換Mapを読み込む
     */
    private void loadMniMonitorMachineSerialMap(List<NamedCsvRecord> rowList, Map<String, String> machineSerialTrastMap_mni) {
            //machine_serial group
            Map<Object, List<NamedCsvRecord>> machine_serial_group = rowList.stream()
                    .filter(f -> !ObjectUtils.isEmpty(f.getField("machine_serial")))
                    .collect(Collectors.groupingBy(r -> {
                        return r.getField("machine_serial");
                    }));
            Set<Object> machine_serial_key = machine_serial_group.keySet();


            List<Long> serialKey = machine_serial_key.stream()
                    .map(o -> Long.valueOf(o.toString()))
                    .collect(Collectors.toList());
            MapSqlParameterSource params2 = new MapSqlParameterSource();
            params2.addValue("facilityCd", facilityCd);
            params2.addValue("serials", serialKey);
            String machineSerialSql = "SELECT fn_device_no,machine_serial FROM mst_machine WHERE facility_cd = :facilityCd AND fn_device_no in(:serials ) AND com_type != 2";
            List<MstMachine> serialList =
                    namedParameterJdbcTemplateConvert.query(
                            machineSerialSql,
                            params2,
                            new BeanPropertyRowMapper<>(MstMachine.class)
                    );
            for (MstMachine item : serialList) {
                machineSerialTrastMap_mni.put(
                        String.valueOf(item.getFnDeviceNo()),
                        String.valueOf(item.getMachineSerial())
                );
            }
    }

    /**
     * ord_no外部キーの変換Mapを読み込む
     */
    private void loadMniMonitorOrdNoMap(List<NamedCsvRecord> rowList, Map<String, String> ordNoTrastMap_mni) {
            Map<Object, List<NamedCsvRecord>> ord_no_group = rowList.stream()
                    .filter(f -> !ObjectUtils.isEmpty(f.getField("ord_no")))
                    .collect(Collectors.groupingBy(r -> {
                        return r.getField("ord_no");
                    }));
            Set<Object> ord_no_key = ord_no_group.keySet();
            String exSql = "SELECT rst_fn_dialysis_no,ord_no FROM ord_main WHERE facility_cd =:facilityCd AND rst_fn_dialysis_no in (:ordNos)";

            List<Long> ordNoKey = ord_no_key.stream()
                    .map(o -> Long.valueOf(o.toString()))
                    .collect(Collectors.toList());
            int batchSize = 1000;
            for (int i = 0; i < ordNoKey.size(); i += batchSize) {
                List<Long> subList =
                        ordNoKey.subList(i, Math.min(i + batchSize, ordNoKey.size()));

                MapSqlParameterSource params = new MapSqlParameterSource();
                params.addValue("facilityCd", facilityCd);
                params.addValue("ordNos", subList);

                List<OrdMain> ordMainList =
                        namedParameterJdbcTemplateConvert.query(
                                exSql,
                                params,
                                new BeanPropertyRowMapper<>(OrdMain.class)
                        );

                for (OrdMain item : ordMainList) {
                    ordNoTrastMap_mni.put(
                            String.valueOf(item.getRstFnDialysisNo()),
                            String.valueOf(item.getOrdNo())
                    );
                }
            }
    }

    /**
     * pat_id外部キーの変換Mapを読み込む
     */
    private void loadMniMonitorPatIdMap(List<NamedCsvRecord> rowList, Map<String, String> patIdTrastMap_mni) {
            Map<Object, List<NamedCsvRecord>> pat_id_group = rowList.stream()
                    .filter(f -> !ObjectUtils.isEmpty(f.getField("pat_id")))
                    .collect(Collectors.groupingBy(r -> {
                        return r.getField("pat_id");
                    }));
            Set<Object> pat_id_key = pat_id_group.keySet();

            List<String> patIdKey = pat_id_key.stream()
                    .map(o -> o.toString())
                    .collect(Collectors.toList());
            MapSqlParameterSource params1 = new MapSqlParameterSource();
            params1.addValue("facilityCd", facilityCd);
            params1.addValue("patIds", patIdKey);
            String comFormatCdSql = "SELECT fn_pat_id,pat_id FROM pat_personal_main WHERE facility_cd = :facilityCd AND fn_pat_id :: CHARACTER VARYING IN(:patIds)";
            List<PatPersonalMain> patIdList =
                    namedParameterJdbcTemplateConvert.query(
                            comFormatCdSql,
                            params1,
                            new BeanPropertyRowMapper<>(PatPersonalMain.class)
                    );

            for (PatPersonalMain item : patIdList) {
                patIdTrastMap_mni.put(
                        String.valueOf(item.getFn_pat_id()),
                        String.valueOf(item.getPat_id())
                );
            }
    }

    /**
     * CSV各行をMniMonitorとしてresultDataListに追加する
     */
    private void appendMniMonitorRows(Collection<String[]> resultDataList,
                                      List<NamedCsvRecord> rowList,
                                      Map<String, String> machineTypeCdTrastMap_mni,
                                      Map<String, String> machineSerialTrastMap_mni,
                                      Map<String, String> ordNoTrastMap_mni,
                                      Map<String, String> patIdTrastMap_mni) {
            rowList.forEach(row -> {
                //取得した各行をMntMotionRecordオブジェクトに入れる
                MniMonitor mniMonitor = new MniMonitor();
            applyMniMonitorBasicFields(mniMonitor, row);
            applyMniMonitorForeignKeys(mniMonitor, row, machineTypeCdTrastMap_mni, machineSerialTrastMap_mni,
                    ordNoTrastMap_mni, patIdTrastMap_mni);
            addMniMonitorRowToResultDataList(resultDataList, mniMonitor);
        });
    }

    /**
     * MniMonitorの基本フィールドをCSV行から設定する
     */
    private void applyMniMonitorBasicFields(MniMonitor mniMonitor, NamedCsvRecord row) {
                String facility_cd = row.getField("facility_cd");
                if (!ObjectUtils.isEmpty(facility_cd)) {
                    mniMonitor.setFacilityCd(facility_cd);
                }
                String data_type = row.getField("data_type");
                if (!ObjectUtils.isEmpty(data_type)) {
                    mniMonitor.setDataType(Short.parseShort(data_type));
                }
                String monitor_data = row.getField("monitor_data");
                if (!ObjectUtils.isEmpty(monitor_data)) {
                    //monitor_dataはjson文字列で、まずカンマを｜に置き換えて、次のカンマで文字列をカットするときに問題が発生しないようにします
                    mniMonitor.setMonitorData(monitor_data.replace(",", "|"));
                }
                String is_del = row.getField("is_del");
                if (!ObjectUtils.isEmpty(is_del)) {
                    mniMonitor.setIsDel(is_del);
                }
                String occurDate = row.getField("occur_date");
                if (!ObjectUtils.isEmpty(occurDate)) {
                    try {
                        mniMonitor.setOccurDate(this.checkDate(occurDate));
                    } catch (ParseException e) {
                        eventLoggerUtil.recordLog(
                                facilityCd,
                                eventLoggerUtil.getEventLogMessage(
                                        "processMniMonitor(Collection<String[]> resultDataList, List<NamedCsvRecord> rowList)："  + EventLoggerUtil.excetionStackTraceToString(e),
                                        facilityCd,
                                        e.getClass().getName() + ".processMniMonitor()"),
                                LogLevel.ERROR);
                    }
                }
                String regDate = row.getField("reg_date");
                if (!ObjectUtils.isEmpty(regDate)) {
                    try {
                        mniMonitor.setRegDate(this.checkDate(regDate));
                    } catch (ParseException e) {
                        eventLoggerUtil.recordLog(
                                facilityCd,
                                eventLoggerUtil.getEventLogMessage(
                                        "processMniMonitor(Collection<String[]> resultDataList, List<NamedCsvRecord> rowList)："  + EventLoggerUtil.excetionStackTraceToString(e),
                                        facilityCd,
                                        e.getClass().getName() + ".processMniMonitor()"),
                                LogLevel.ERROR);
                    }
                }
                String upDate = row.getField("up_date");
                if (!ObjectUtils.isEmpty(upDate)) {
                    try {
                        mniMonitor.setUpDate(this.checkDate(upDate));
                    } catch (ParseException e) {
                        eventLoggerUtil.recordLog(
                                facilityCd,
                                eventLoggerUtil.getEventLogMessage(
                                        "processMniMonitor(Collection<String[]> resultDataList, List<NamedCsvRecord> rowList)："  + EventLoggerUtil.excetionStackTraceToString(e),
                                        facilityCd,
                                        e.getClass().getName() + ".processMniMonitor()"),
                                LogLevel.ERROR);
                    }
                }
    }

    /**
     * MniMonitorの外部キーフィールドを変換Mapから設定する
     */
    private void applyMniMonitorForeignKeys(MniMonitor mniMonitor,
                                            NamedCsvRecord row,
                                            Map<String, String> machineTypeCdTrastMap_mni,
                                            Map<String, String> machineSerialTrastMap_mni,
                                            Map<String, String> ordNoTrastMap_mni,
                                            Map<String, String> patIdTrastMap_mni) {
                String machine_type_cd = row.getField("machine_type_cd");
                if (!ObjectUtils.isEmpty(machine_type_cd)) {
                    mniMonitor.setMachineTypeCd(machineTypeCdTrastMap_mni.getOrDefault(machine_type_cd, null));
                } else {
                    mniMonitor.setMachineTypeCd(null);
                }
                //外部キー machine_serial
                String machine_serial = row.getField("machine_serial");
                if (!ObjectUtils.isEmpty(machine_serial)) {
                    mniMonitor.setMachineSerial(machineSerialTrastMap_mni.getOrDefault(machine_serial, null));
                } else {
                    mniMonitor.setMachineSerial(null);
                }
                //外部キー ord_no
                String ord_no = row.getField("ord_no");
                if (!ObjectUtils.isEmpty(ord_no)) {
                    if (ordNoTrastMap_mni.containsKey(ord_no)) {
                        if (ObjectUtils.isEmpty(ordNoTrastMap_mni.get(ord_no))) {
                            mniMonitor.setOrdNo(null);
                        } else {
                            mniMonitor.setOrdNo(Long.parseLong(ordNoTrastMap_mni.get(ord_no)));
                        }
                    } else {
                        mniMonitor.setOrdNo(null);
                    }
                } else {
                    mniMonitor.setOrdNo(null);
                }
                //外部キーpat_id
                String pat_id = row.getField("pat_id");
                if (!ObjectUtils.isEmpty(pat_id)) {
                    if (ObjectUtils.isEmpty(patIdTrastMap_mni.get(pat_id))) {
                        mniMonitor.setPatId(null);
                    } else {
                        mniMonitor.setPatId(Long.parseLong(patIdTrastMap_mni.get(pat_id)));
                    }
                } else {
                    mniMonitor.setPatId(null);
                }
    }

    /**
     * MniMonitor行をresultDataListに追加する
     */
    private void addMniMonitorRowToResultDataList(Collection<String[]> resultDataList, MniMonitor mniMonitor) {
        String[] rdl = mniMonitor.toString().split(",");
        if (rdl[6].contains("|")) {
            rdl[6] = rdl[6].replace("|", ",");
        }
        resultDataList.add(rdl);
    }

    /**
     * 差分処理時のsqlKeysを更新する
     */
    private void updateMniMonitorDiffSqlKeys(List<String> ordNoList) {
            if (globalContext.fileName.contains("[diff]") && !ordNoList.isEmpty()) {
                globalContext.sqlNewKeys = "";
                List<String> distinctList = ordNoList.stream()
                        .distinct()
                        .collect(Collectors.toList());
                globalContext.sqlKeys = String.join(",", distinctList);
            }
    }

    /**
     * mni_monitor処理の例外をログ出力する
     */
    private void handleProcessMniMonitorException(Exception ex, String csvfileName) throws IOException {
            System.err.println("実行" + csvfileName + "ファイル中にエラーが発生しました！\n");
            //出力詳細エラー情報

            //ログ
            EventLogMessage eventLogMessage = eventLoggerUtil.getEventLogMessage("CSVファイルの処理に失敗しました：" + csvfileName,
                    facilityCd, "BatchCsvWriterDb.write()");
            eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.ERROR);
            //ログ
            EventLogMessage eventLogMessagex = eventLoggerUtil.getEventLogMessage("詳細なエラー情報：" + ex.toString(),
                    facilityCd, "BatchCsvWriterDb.write()");
            eventLoggerUtil.recordLog(facilityCd, eventLogMessagex, LogLevel.ERROR);

            eventLoggerUtil.recordLog(
                    facilityCd,
                    eventLoggerUtil.getEventLogMessage(
                            "processMniMonitor(Collection<String[]> resultDataList, List<NamedCsvRecord> rowList)："  + EventLoggerUtil.excetionStackTraceToString(ex),
                            facilityCd,
                            ex.getClass().getName() + ".processMniMonitor()"),
                    LogLevel.ERROR);
            this.errorfile(csvfileName);
    }

    private void processOrdChecklist(Collection<String[]> resultDataList,
                                     List<NamedCsvRecord> rowList) throws IOException {
        String csvfileName = globalContext.fileName;
        //convertテーブルの最大番号を取る
        globalContext.seq=0;

        try {

            //resultDataListが空の場合は、Headセクションを先に挿入する必要があります
            if (resultDataList.isEmpty()) {
                resultDataList.add(ordCheckListColumnNames);
            }
            List<OrdMain> ordMainList = loadOrdChecklistOrdMainList(rowList);
            deleteOrdChecklistForDiff(ordMainList);
            rowList = rowList.stream().filter(row -> !EMPTY.equals(row.getField("list_cd"))).toList();
            Map<String, Map<String, String>> userIdTrastMap = new HashMap<>();
            ResultOfMstCdToMstDto resultOfMstCdToMstDto = mstCdToMstDto(rowList, userIdTrastMap);
            ensureOrdChecklistCdCached();
            appendOrdChecklistRows(resultDataList, rowList, ordMainList, userIdTrastMap,
                    resultOfMstCdToMstDto.getMstEquipmentList(),
                    resultOfMstCdToMstDto.getMstEquipmentClassList(),
                    resultOfMstCdToMstDto.getMstDialyzerList());
        } catch (Exception ex) {
            handleProcessOrdChecklistException(ex, csvfileName);
        }
    }

    /**
     * ord_checklist用のord_main一覧を読み込む
     */
    private List<OrdMain> loadOrdChecklistOrdMainList(List<NamedCsvRecord> rowList) {
            Map<Boolean, List<String>> ordNoKeyMap = rowList.stream().map(row -> row.getField("ord_no"))
                    .filter(Objects::nonNull).distinct().collect(Collectors.groupingBy(r -> r.length() > 12));
            List<String> indIdList = ordNoKeyMap.get(true);
            List<String> dialysisNoList = ordNoKeyMap.get(false);
            List<OrdMain> ordMainList = new ArrayList<>();
            if (null != indIdList && !indIdList.isEmpty()) {
                Map<Integer, List<String>> indIdMap =
                        IntStream.range(0, (int) Math.ceil((double) indIdList.size() / 1000)).boxed()
                                .collect(Collectors.toMap(i -> i, i -> indIdList.stream().skip(i * 1000).limit(1000).collect(Collectors.toList())));

                indIdMap.values().forEach(subList -> {
                    String ordNoSql = """
                                    SELECT
                                      ord_no,
                                      fn_pat_id,
                                      treat_date,
                                      fn_plural,
                                      case when ind_cond_info is null then '{}' else ind_cond_info end ind_cond_info,
                                      case when ind_equip_info is null then '[]' else ind_equip_info end ind_equip_info
                                    FROM ord_main
                                    WHERE facility_cd = ?
                                      AND (fn_pat_id || treat_date || fn_plural) in (%s)""".formatted(IntStream.range(0, subList.size()).mapToObj(i -> "?").collect(Collectors.joining(", ")));
                    List<Object> params = new ArrayList<>();
                    params.add(facilityCd);
                    params.addAll(subList);
                    ordMainList.addAll(namedParameterJdbcTemplateConvert.getJdbcOperations().query(ordNoSql, params.toArray(), new BeanPropertyRowMapper<>(OrdMain.class)));
                });
            }
            if (null != dialysisNoList && !dialysisNoList.isEmpty()) {
                Map<Integer, List<String>> dialysisNoMap =
                        IntStream.range(0, (int) Math.ceil((double) dialysisNoList.size() / 1000)).boxed()
                                .collect(Collectors.toMap(i -> i, i -> dialysisNoList.stream().skip(i * 1000).limit(1000).collect(Collectors.toList())));
                dialysisNoMap.values().forEach(subList -> {
                    String ordNoSql = """
                                    SELECT
                                      ord_no,
                                      rst_fn_dialysis_no,
                                      case when rst_cond_info is null then '{}' else rst_cond_info end rst_cond_info,
                                      case when rst_equip_info is null then '[]' else rst_equip_info end rst_equip_info
                                      FROM ord_main
                                    WHERE facility_cd = ?
                                    AND rst_fn_dialysis_no :: CHARACTER VARYING in (%s)""".formatted(IntStream.range(0, subList.size()).mapToObj(i -> "?").collect(Collectors.joining(", ")));
                    List<Object> params = new ArrayList<>();
                    params.add(facilityCd);
                    params.addAll(subList);
                    ordMainList.addAll(namedParameterJdbcTemplateConvert.getJdbcOperations().query(ordNoSql, params.toArray(), new BeanPropertyRowMapper<>(OrdMain.class)));
                });
            }
        return ordMainList;
    }

    /**
     * 差分処理時にord_checklistの既存レコードを削除する
     */
    private void deleteOrdChecklistForDiff(List<OrdMain> ordMainList) {
            if (globalContext.fileName.contains("[diff]") && !ordMainList.isEmpty()) {
                List<String> ordNoList = ordMainList.stream().map(OrdMain::getOrdNo).map(String::valueOf).toList();
                globalContext.sqlKeys = String.join(",", ordNoList);
                DataSource dsc = (DataSource) appContext.getBean(ApplicationConst.DbType.CONVERT);
                JdbcTemplate jdbcTemplatec = new JdbcTemplate(dsc);
                Map<Integer, List<String>> ordNoMap =
                        IntStream.range(0, (int) Math.ceil((double) ordNoList.size() / 1000)).boxed()
                                .collect(Collectors.toMap(i -> i, i -> ordNoList.stream().skip(i * 1000).limit(1000).collect(Collectors.toList())));
                ordNoMap.values().forEach(subList -> {
                    String delSql = "delete from ord_checklist where facility_cd = ? and ord_no :: CHARACTER VARYING in (%s)".formatted(IntStream.range(0, subList.size()).mapToObj(i -> "?").collect(Collectors.joining(", ")));
                    List<Object> params = new ArrayList<>();
                    params.add(facilityCd);
                    params.addAll(subList);
                    jdbcTemplatec.update(delSql, params.toArray());
                });
            }
    }

    /**
     * mst_checklistのchecklist_cdをキャッシュする
     */
    private void ensureOrdChecklistCdCached() {
        if (!checklistCdMap.containsKey(facilityCd)) {
            String checklistCdSql = "SELECT checklist_cd, checklist_settings FROM mst_checklist WHERE facility_cd = ? ORDER BY up_date DESC LIMIT 1";
                List<MstChecklist> checklistCdList = namedParameterJdbcTemplateConvert.getJdbcOperations().query(checklistCdSql, new Object[]{facilityCd}, new BeanPropertyRowMapper<>(MstChecklist.class));
                if (checklistCdList.size() == 1) {
                    checklistCdMap.put(facilityCd, checklistCdList.get(0));
                }
            }
    }

    /**
     * ord_checklistのCSV行を再構築してresultDataListに追加する
     */
    private void appendOrdChecklistRows(Collection<String[]> resultDataList,
                                        List<NamedCsvRecord> rowList,
                                        List<OrdMain> ordMainList,
                                        Map<String, Map<String, String>> userIdTrastMap,
                                        List<MstEquipment> mstEquipmentList,
                                        List<MstEquipmentClass> mstEquipmentClassList,
                                        List<MstDialyzer> mstDialyzerList) {
            Map<String, List<NamedCsvRecord>> csvRowByOrdNoMap = rowList.stream().collect(Collectors.groupingBy(r -> r.getField("ord_no")));
            csvRowByOrdNoMap.forEach((ordNoKey, csvRows) -> {
                // ord_no
                List<OrdMain> targetOrdMainList = ordMainList.stream().filter(ord -> ordNoKey.equals(ord.getFnOrdNo())).toList();
                Long ordNo;
            OrdMain ordMain;
                if (!targetOrdMainList.isEmpty()) {
                    ordMain = targetOrdMainList.get(0);
                    ordNo = ordMain.getOrdNo();
                } else {
                    return;
                }

                Map<String, List<NamedCsvRecord>> csvRowByListCdMap = csvRows.stream().collect(Collectors.groupingBy(r -> r.getField("list_cd")));
                OrdMain finalOrdMain = ordMain;
                csvRowByListCdMap.forEach((listCd, rows) -> {
                    // 医材が治療条件に移動するレコードを格納する(穿刺針、血液回路)
                    List<String> equipToCondClassCdList = new ArrayList<>();
                    // 穿刺針重複を防ぐ
                    List<Integer> needleList = new ArrayList<>();
                rows.forEach(r -> processOrdChecklistCsvRow(resultDataList, r, ordNo, finalOrdMain, userIdTrastMap,
                        mstEquipmentList, mstEquipmentClassList, mstDialyzerList, equipToCondClassCdList, needleList));
            });
        });
    }

    /**
     * ord_checklistのCSV1行をOrdChecklistに変換してresultDataListに追加する
     */
    private void processOrdChecklistCsvRow(Collection<String[]> resultDataList,
                                           NamedCsvRecord r,
                                           Long ordNo,
                                           OrdMain finalOrdMain,
                                           Map<String, Map<String, String>> userIdTrastMap,
                                           List<MstEquipment> mstEquipmentList,
                                           List<MstEquipmentClass> mstEquipmentClassList,
                                           List<MstDialyzer> mstDialyzerList,
                                           List<String> equipToCondClassCdList,
                                           List<Integer> needleList) {
                        OrdChecklist ordChecklist = new OrdChecklist();
                        // facility_cd
                        ordChecklist.setFacilityCd(r.getField("facility_cd"));
                        // ord_no
                        ordChecklist.setOrdNo(ordNo);
                        //is_check
                        ordChecklist.setIsCheck(r.getField("is_check"));
                        //rst_class
                        ordChecklist.setRstClass(parseShortOrNull(r.getField("rst_class")));
                        //list_cd
                        ordChecklist.setListCd(parseShortOrNull(r.getField("list_cd")));
                        //func_class
                        ordChecklist.setFuncClass(parseShortOrNull(r.getField("func_class")));
                        // rst_checklist_info
                        String rstChecklistInfoStr = r.getField("rst_checklist_info");
                        if (!ObjectUtils.isEmpty(rstChecklistInfoStr)) {
                            // rst_checklist_info
                            JSONObject rstChecklistInfo = new JSONObject(rstChecklistInfoStr);
                            boolean isSkip = processRstChecklistInfo(r,ordChecklist,finalOrdMain,mstEquipmentList,mstEquipmentClassList,mstDialyzerList,equipToCondClassCdList,needleList,rstChecklistInfo);
                            if (isSkip) {
                                return;
                            }
                        } else {
                            ordChecklist.setRstChecklistInfo(null);
                        }
        applyOrdChecklistRegStaffInfo(ordChecklist, r, userIdTrastMap);
        applyOrdChecklistDates(ordChecklist, r);
        String[] ordChecklistArray = ordChecklist.toString().split(",");
        if (ordChecklistArray.length > 0) {
            int staffInfo = ordChecklistArray.length - 1;
            int checklistInfo = ordChecklistArray.length - 2;
            if (ordChecklistArray[checklistInfo].contains("|")) {
                ordChecklistArray[checklistInfo] = ordChecklistArray[checklistInfo].replace("|", ",");
            }
            if (ordChecklistArray[staffInfo].contains("|")) {
                ordChecklistArray[staffInfo] = ordChecklistArray[staffInfo].replace("|", ",");
            }
        }
        resultDataList.add(ordChecklistArray);
    }

    /**
     * ord_checklistのreg_staff_infoを外部キー置換する
     */
    private void applyOrdChecklistRegStaffInfo(OrdChecklist ordChecklist,
                                               NamedCsvRecord r,
                                               Map<String, Map<String, String>> userIdTrastMap) {
                        String regStaffInfoStr = r.getField("reg_staff_info");
                        if (!ObjectUtils.isEmpty(regStaffInfoStr)) {
                            JSONObject regStaffInfoStrJson = new JSONObject(regStaffInfoStr);
                            //reg _staff_infoでreg _staff_cdのvalue値
                            String reg_staff_cd_value = ObjectUtils.isEmpty(regStaffInfoStrJson.get("reg_staff_cd")) ? null : String.valueOf(regStaffInfoStrJson.get("reg_staff_cd"));
                            //reg _staff_cdに対応するvalue値（reg _ staff _ cd _ value）自体がnullであればキャッシュコレクションで値を取る必要はありません。下の書き込みをスキップしてjson値に戻す
                            if (!ObjectUtils.isEmpty(reg_staff_cd_value) && !"null".equals(reg_staff_cd_value)) {
                                String user_id = null;
                                String reg_staff_name = null;
                                String up_date = null;
                                if (userIdTrastMap.containsKey(reg_staff_cd_value) && !ObjectUtils.isEmpty(userIdTrastMap.get(reg_staff_cd_value))) {
                                    user_id = userIdTrastMap.get(reg_staff_cd_value).get("userId");
                                    reg_staff_name = userIdTrastMap.get(reg_staff_cd_value).get("regStaffName");
                                    up_date = userIdTrastMap.get(reg_staff_cd_value).get("upDate");
                                }
                                regStaffInfoStrJson.put("reg_staff_cd", user_id);
                                regStaffInfoStrJson.put("reg_staff_name", reg_staff_name);
                                regStaffInfoStrJson.put("reg_staff_update", up_date);
                            }
                            //置換後のjson列をOrdChecklist DTOに戻す
                            ordChecklist.setRegStaffInfo(regStaffInfoStrJson);
                        } else {
                            ordChecklist.setRegStaffInfo(null);
                        }
    }
                        //occur_date
    /**
     * ord_checklistの日付列を設定する
     */
    private void applyOrdChecklistDates(OrdChecklist ordChecklist, NamedCsvRecord r) {
                        try {
                            ordChecklist.setOccurDate(ObjectUtils.isEmpty(r.getField("occur_date")) ? null : this.checkDate(r.getField("occur_date")));
                        } catch (ParseException e) {
                            eventLoggerUtil.recordLog(
                                    facilityCd,
                                    eventLoggerUtil.getEventLogMessage(
                                            "processOrdChecklist(Collection<String[]> resultDataList, List<NamedCsvRecord> rowList)："  + EventLoggerUtil.excetionStackTraceToString(e),
                                            facilityCd,
                                            e.getClass().getName() + ".processOrdChecklist()"),
                                    LogLevel.ERROR);
                        }
                        //reg_date
                        try {
                            ordChecklist.setRegDate(ObjectUtils.isEmpty(r.getField("reg_date")) ? null : this.checkDate(r.getField("reg_date")));
                        } catch (ParseException e) {
                            eventLoggerUtil.recordLog(
                                    facilityCd,
                                    eventLoggerUtil.getEventLogMessage(
                                            "processOrdChecklist(Collection<String[]> resultDataList, List<NamedCsvRecord> rowList)："  + EventLoggerUtil.excetionStackTraceToString(e),
                                            facilityCd,
                                            e.getClass().getName() + ".processOrdChecklist()"),
                                    LogLevel.ERROR);
                        }
                        //up_date
                        try {
                            ordChecklist.setUpDate(ObjectUtils.isEmpty(r.getField("up_date")) ? null : this.checkDate(r.getField("up_date")));
                        } catch (ParseException e) {
                            eventLoggerUtil.recordLog(
                                    facilityCd,
                                    eventLoggerUtil.getEventLogMessage(
                                            "processOrdChecklist(Collection<String[]> resultDataList, List<NamedCsvRecord> rowList)："  + EventLoggerUtil.excetionStackTraceToString(e),
                                            facilityCd,
                                            e.getClass().getName() + ".processOrdChecklist()"),
                                    LogLevel.ERROR);
                        }
    }

    /**
     * ord_checklist処理の例外をログ出力する
     */
    private void handleProcessOrdChecklistException(Exception ex, String csvfileName) throws IOException {
            System.err.println("実行" + csvfileName + "ファイル中にエラーが発生しました！\n");
            //出力詳細エラー情報
            //ログ
            EventLogMessage eventLogMessage = eventLoggerUtil.getEventLogMessage("CSVファイルの処理に失敗しました：" + csvfileName,
                    facilityCd, "BatchCsvWriterDb.write()");
            eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.ERROR);
            //ログ
            EventLogMessage eventLogMessagex = eventLoggerUtil.getEventLogMessage("詳細なエラー情報：" + ex.toString(),
                    facilityCd, "BatchCsvWriterDb.write()");
            eventLoggerUtil.recordLog(facilityCd, eventLogMessagex, LogLevel.ERROR);

            eventLoggerUtil.recordLog(
                    facilityCd,
                    eventLoggerUtil.getEventLogMessage(
                            "processOrdChecklist(Collection<String[]> resultDataList, List<NamedCsvRecord> rowList)："  + EventLoggerUtil.excetionStackTraceToString(ex),
                            facilityCd,
                            ex.getClass().getName() + ".processOrdChecklist()"),
                    LogLevel.ERROR);
            this.errorfile(csvfileName);
        }

    private boolean processRstChecklistInfo(NamedCsvRecord r,OrdChecklist ordChecklist,OrdMain finalOrdMain,List<MstEquipment> mstEquipmentList,List<MstEquipmentClass> mstEquipmentClassList,List<MstDialyzer> mstDialyzerList,
                                            List<String> equipToCondClassCdList,List<Integer> needleList,JSONObject rstChecklistInfo) {
        //checklist _cd対応のvalue（1回調べて、固定値を取ればよい）
        MstChecklist ac = checklistCdMap.getOrDefault(facilityCd, null);
        if (null != ac && null != ac.getChecklistCd()) {
            rstChecklistInfo.put("checklist_cd", ac.getChecklistCd());
        }

        String codeKey = stringValueOfOrNull(rstChecklistInfo.get("code"));
        String classCdKey = stringValueOfOrNull(rstChecklistInfo.get("class_cd"));
        String funcClass = r.getField("func_class"); // 機能種別（func_class）「0：通常リスト」「1：治療条件」「2：医療材料」「3：投与薬剤」

        Optional<MstEquipment> mstEquipmentOpt = mstEquipmentList.stream().filter(e -> e.getFnEquipmentCd().equals(codeKey)).findAny();
        MstEquipment mstEquipment = null;
        if (mstEquipmentOpt.isPresent()) {
            mstEquipment = mstEquipmentOpt.get();
        }
        // key自身がnullであれば、コレクションから値を取る必要はないと判断し、次の書き込みをスキップしてjson値に戻す
        if (!(ObjectUtils.isEmpty(classCdKey) || "null".equals(classCdKey))) {
            if ("2".equals(funcClass)) {
                if (processRstChecklistInfoFuncClass2(ordChecklist, finalOrdMain, mstEquipmentClassList,
                        equipToCondClassCdList, needleList, rstChecklistInfo, classCdKey, mstEquipmentOpt, mstEquipment)) {
                    return true;
                }
            } else if ("1".equals(funcClass)) {
                if (processRstChecklistInfoFuncClass1(ordChecklist, finalOrdMain, mstDialyzerList, rstChecklistInfo,
                        classCdKey, codeKey, mstEquipmentOpt, mstEquipment)) {
                    return true;
                }
            } else {
                rstChecklistInfo.put("code", JSONObject.NULL);
            }
        }
        applyRstChecklistInfoItemNumber(ordChecklist, rstChecklistInfo, ac, funcClass);
        rstChecklistInfo.remove("join_item_number");
        ordChecklist.setRstChecklistInfo(rstChecklistInfo);
        return false;
    }

    /**
     * rst_checklist_infoのfunc_class=2（医療材料）を処理する
     */
    private boolean processRstChecklistInfoFuncClass2(OrdChecklist ordChecklist,
                                                      OrdMain finalOrdMain,
                                                      List<MstEquipmentClass> mstEquipmentClassList,
                                                      List<String> equipToCondClassCdList,
                                                      List<Integer> needleList,
                                                      JSONObject rstChecklistInfo,
                                                      String classCdKey,
                                                      Optional<MstEquipment> mstEquipmentOpt,
                                                      MstEquipment mstEquipment) {
                setNullToJsonObject(rstChecklistInfo, "name", null, "String");
                rstChecklistInfo.put("equip_type", 0);
                JSONObject condInfoJson;
                // 指示の場合
                if (finalOrdMain.getFnOrdNo().length() > 12) {
                    condInfoJson = new JSONObject(finalOrdMain.getIndCondInfo());
                } else {
                    condInfoJson = new JSONObject(finalOrdMain.getRstCondInfo());
                }
                JSONObject needleJson = new JSONObject();
                boolean needleConvertFlg = true;
                if (List.of("9", "10", "11", "202").contains(classCdKey)) {
                    if (condInfoJson.has("12")) {
                        needleJson = parseJsonOrNull(condInfoJson.get("12"));
                    } else {
                        needleConvertFlg = false;
                    }
                }
                if (mstEquipmentOpt.isPresent()) {
                    classCdKey = getNeedleClassCdKey(classCdKey,needleConvertFlg,condInfoJson,needleJson,equipToCondClassCdList,mstEquipment);
                }
                // 治療条件(医療材料)
                // 医材を再転換を防ぐ  防止医疗材料再转化
                boolean equipFlg = true;
                String finalClassCdKey = classCdKey;
                if (needleConvertFlg && List.of("9", "10", "11", "13").contains(classCdKey) && equipToCondClassCdList.stream().noneMatch(cd -> cd.equals(finalClassCdKey))) {
                    boolean validEquip = true;
                    if (List.of("9", "10", "11").contains(classCdKey)) {
                        if ("0".equals(needleJson.get("value").toString())) {
                            if ("11".equals(classCdKey)) {
                                validEquip = false;
                            }
                        } else {
                            if (List.of("9", "10").contains(classCdKey)) {
                                validEquip = false;
                            }
                        }
                    }
                    if (validEquip && mstEquipmentOpt.isPresent()) {
                        JSONObject cond = parseJsonOrNull(condInfoJson.get(classCdKey));
                        if (mstEquipment.getEquipmentCd().equals(getIntValue(cond.get("value")))) {
                            ordChecklist.setFuncClass(Short.parseShort("1"));
                            rstChecklistInfo.put("class_cd", classCdKey);
                            rstChecklistInfo.put("amount", "1");
                            setNullToJsonObject(rstChecklistInfo, "unit", mstEquipment.getUnit(), "String");
                            setNullToJsonObject(rstChecklistInfo, "name", finalOrdMain.getFnOrdNo().length() > 12 ? mstEquipment.getEquipmentName() : cond.get("value_name_1"), "String");
                            setNullToJsonObject(rstChecklistInfo, "code", cond.get("value"), "Number");
                            equipToCondClassCdList.add(classCdKey);
                            equipFlg = false;
                        }
                    }
                }

                // ord_mainにて、医材の場合、同じ穿刺針コード数量合計の仕様と一致で、重複導入しない
                if (equipFlg && List.of("9", "10", "11", "202").contains(classCdKey) && needleList.contains(mstEquipment.getEquipmentCd())) {
                    return true; // skip outter rows.forEach
                }
                // 医療材料(ダイアライザ以外)
                if (equipFlg) {
                    processFuncClass2(finalOrdMain,mstEquipmentClassList,needleList,rstChecklistInfo,mstEquipment);
                }
        return false;
            }

    /**
     * rst_checklist_infoのfunc_class=1（治療条件）を処理する
     */
    private boolean processRstChecklistInfoFuncClass1(OrdChecklist ordChecklist,
                                                      OrdMain finalOrdMain,
                                                      List<MstDialyzer> mstDialyzerList,
                                                      JSONObject rstChecklistInfo,
                                                      String classCdKey,
                                                      String codeKey,
                                                      Optional<MstEquipment> mstEquipmentOpt,
                                                      MstEquipment mstEquipment) {
                if ("5".equals(classCdKey)) { // ダイアライザ
                    rstChecklistInfo.put("class_cd", Integer.parseInt(classCdKey));
                    rstChecklistInfo.put("amount", "1");
                    rstChecklistInfo.put("unit", "本");
                    rstChecklistInfo.put("equip_type", 1);
                    Optional<MstDialyzer> mstDialyzerOpt = mstDialyzerList.stream().filter(e -> e.getFnDialyzerCd().equals(codeKey)).findAny();
                    if (mstDialyzerOpt.isPresent()) {
                        MstDialyzer dialyzer = mstDialyzerOpt.get();
                        // 指示の場合
                        if (finalOrdMain.getFnOrdNo().length() > 12) {
                            JSONObject condInfoJson = new JSONObject(finalOrdMain.getIndCondInfo());
                            JSONObject ordMainCondInfoJson = parseJsonOrNull(condInfoJson.get(classCdKey));
                            setNullToJsonObject(rstChecklistInfo, "code", ordMainCondInfoJson.get("value"), "Number");
                            setNullToJsonObject(rstChecklistInfo, "name", dialyzer.getModelNumber(), "String");
                        } else {
                            JSONObject condInfoJson = new JSONObject(finalOrdMain.getRstCondInfo());
                            JSONObject ordMainCondInfoJson = parseJsonOrNull(condInfoJson.get(classCdKey));
                            setNullToJsonObject(rstChecklistInfo, "code", ordMainCondInfoJson.get("value"), "Number");
                            setNullToJsonObject(rstChecklistInfo, "name", ordMainCondInfoJson.get("value_name_1"), "String");
                        }
                    } else if (mstEquipmentOpt.isPresent()) {
                        if (finalOrdMain.getFnOrdNo().length() > 12) {
                            MstEquipment finalEquipment = mstEquipment;
                            JSONObject condInfoJson = new JSONObject(finalOrdMain.getIndCondInfo());
                            List<String> keys = new ArrayList<>();
                            if (condInfoJson.has("6")) {
                                keys.add("6");
                            }
                            if (condInfoJson.has("7")) {
                                keys.add("7");
                            }
                            if (condInfoJson.has("8")) {
                                keys.add("8");
                            }
                            Map<String, JSONObject> condInfoMap = keys.stream().collect(Collectors.toMap(k -> k, k -> parseJsonOrNull(condInfoJson.get(k))));
                            Map<String, JSONObject> condInfo = condInfoMap.entrySet().stream()
                                    .filter(entry -> entry.getValue().get("value").equals(String.valueOf(finalEquipment.getEquipmentCd())))
                                    .collect(Collectors.toMap(Map.Entry::getKey, Map.Entry::getValue));
                            if (!condInfo.isEmpty()) {
                                condInfo.forEach((k, v) -> {
                                    rstChecklistInfo.put("class_cd", Integer.parseInt(k));
                                    setNullToJsonObject(rstChecklistInfo, "code", v.get("value"), "Number");
                                    setNullToJsonObject(rstChecklistInfo, "name", finalEquipment.getEquipmentName(), "String");
                                });
                            } else {
                                return true; // skip outter rows.forEach
                            }
                        }
                    }
                } else {
                    // 「1：治療条件」处理
                    processFuncClass1(finalOrdMain,rstChecklistInfo,mstEquipment);
                }
        return false;
            }

    /**
     * rst_checklist_infoのitem_numberをマスタ設定から取得する
     */
    private void applyRstChecklistInfoItemNumber(OrdChecklist ordChecklist,
                                                 JSONObject rstChecklistInfo,
                                                 MstChecklist ac,
                                                 String funcClass) {
        // 治療条件の場合、医材転換を発生するかもしれないので、item_numberがマスタから取得する
        if ("1".equals(funcClass) && rstChecklistInfo.get("join_item_number").toString().contains(",")) {
            int classCd = rstChecklistInfo.optInt("class_cd");
            JSONArray checklistSettingsJson = new JSONArray(ac.getChecklistSettings());
            checklistSettingsJson.forEach(c -> {
                JSONObject obj = parseJsonOrNull(c);
                if (ordChecklist.getListCd() == Short.parseShort(obj.get("list_cd").toString())) {
                    JSONArray funclistJson = new JSONArray(obj.get("funclist").toString());
                    funclistJson.forEach(func -> {
                        JSONObject funcObj = parseJsonOrNull(func);

                        if (null != funcObj.get("func_class") && !"null".equals(funcObj.get("func_class").toString())
                                && null != funcObj.get("class_cd") && !"null".equals(funcObj.get("class_cd").toString())
                                && 1 == Short.parseShort(funcObj.get("func_class").toString())
                                && classCd == Integer.parseInt(funcObj.get("class_cd").toString())) {
                            int itemNumber = Integer.parseInt(funcObj.get("item_number").toString());
                            rstChecklistInfo.put("item_number", itemNumber);
                        }
                    });
                }
            });
        }
    }

    private String getNeedleClassCdKey(String classCdKey,boolean needleConvertFlg,JSONObject condInfoJson,JSONObject needleJson,List<String> equipToCondClassCdList,MstEquipment mstEquipment){
        if ("202".equals(classCdKey) && needleConvertFlg) {
            if ("0".equals(needleJson.get("value").toString())) {
                JSONObject aCond = parseJsonOrNull(condInfoJson.get("9"));
                JSONObject vCond = parseJsonOrNull(condInfoJson.get("10"));
                if (equipToCondClassCdList.stream().noneMatch(cd -> cd.equals("9")) && mstEquipment.getEquipmentCd().equals(getIntValue(aCond.get("value")))) {
                    classCdKey = "9";
                } else if (equipToCondClassCdList.stream().noneMatch(cd -> cd.equals("10")) && mstEquipment.getEquipmentCd().equals(getIntValue(vCond.get("value")))) {
                    classCdKey = "10";
                }
            } else {
                JSONObject vCond = parseJsonOrNull(condInfoJson.get("11"));
                if (mstEquipment.getEquipmentCd().equals(getIntValue(vCond.get("value")))) {
                    classCdKey = "11";
                }
            }
        }
        if ("203".equals(classCdKey)) {
            JSONObject vCond = parseJsonOrNull(condInfoJson.get("13"));
            if (mstEquipment.getEquipmentCd().equals(getIntValue(vCond.get("value")))) {
                classCdKey = "13";
            }
        }
        return classCdKey;
    }

    /**
     * 「2：医療材料」处理
     */
    private void processFuncClass2(OrdMain finalOrdMain,List<MstEquipmentClass> mstEquipmentClassList,List<Integer> needleList,JSONObject rstChecklistInfo,MstEquipment mstEquipment){
        String classCdKey = stringValueOfOrNull(rstChecklistInfo.get("class_cd"));
        String fnClassCd = switch (classCdKey) {
            case "9", "11", "10" -> "202";
            case "13" -> "203";
            default -> classCdKey;
        };
        Optional<MstEquipmentClass> mstEquipmentClassOpt = mstEquipmentClassList.stream().filter(e -> e.getFnClassCd().equals(fnClassCd)).findFirst();
        if (mstEquipmentClassOpt.isPresent()) {
            rstChecklistInfo.put("class_cd", mstEquipmentClassOpt.get().getClassCd());
        } else {
            rstChecklistInfo.put("class_cd", JSONObject.NULL);
        }
        if (mstEquipment != null) {
            setNullToJsonObject(rstChecklistInfo, "code", mstEquipment.getEquipmentCd(), "Number");
            MstEquipment finalMstEquipment = mstEquipment;
            // 指示の場合
            if (finalOrdMain.getFnOrdNo().length() > 12) {
                JSONArray equipInfoJson = new JSONArray(finalOrdMain.getIndEquipInfo());
                equipInfoJson.forEach(equip -> {
                    JSONObject obj = parseJsonOrNull(equip);
                    if (String.valueOf(finalMstEquipment.getEquipmentCd()).equals(obj.get("cd").toString())) {
                        setNullToJsonObject(rstChecklistInfo, "class_cd", finalMstEquipment.getClassCd(), "Number");
                        setNullToJsonObject(rstChecklistInfo, "name", finalMstEquipment.getEquipmentName(), "String");
                        setNullToJsonObject(rstChecklistInfo, "amount", obj.get("amount"), "String");
                        setNullToJsonObject(rstChecklistInfo, "unit", finalMstEquipment.getUnit(), "String");
                        needleList.add(finalMstEquipment.getEquipmentCd());
                    }
                });
            } else {
                JSONArray equipInfoJson = new JSONArray(finalOrdMain.getRstEquipInfo());
                equipInfoJson.forEach(equip -> {
                    JSONObject obj = parseJsonOrNull(equip);
                    if (finalMstEquipment.getEquipmentCd().equals(obj.get("cd"))) {
                        setNullToJsonObject(rstChecklistInfo, "class_cd", obj.get("class_cd"), "Number");
                        setNullToJsonObject(rstChecklistInfo, "name", obj.get("name"), "String");
                        setNullToJsonObject(rstChecklistInfo, "amount", obj.get("amount"), "String");
                        setNullToJsonObject(rstChecklistInfo, "unit", obj.get("unit"), "String");
                        needleList.add(finalMstEquipment.getEquipmentCd());
                    }
                });
            }
        }
    }

    /**
     * 「1：治療条件」处理
     */
    private void processFuncClass1(OrdMain finalOrdMain,JSONObject rstChecklistInfo,MstEquipment mstEquipment){
        String classCdKey = stringValueOfOrNull(rstChecklistInfo.get("class_cd"));
        rstChecklistInfo.put("class_cd", classCdKey);
        rstChecklistInfo.put("amount", "1");
        rstChecklistInfo.put("equip_type", 0);
        if (mstEquipment != null) {
            if ("6".equals(classCdKey)) {
                // 吸着カラム：6
                setNullToJsonObject(rstChecklistInfo, "unit", mstEquipment.getUnit(), "String");
            } else {
                // 特殊浄化の場合 一次膜、二次膜：7, 8
                rstChecklistInfo.put("unit", "本");
            }
            // 指示の場合
            if (finalOrdMain.getFnOrdNo().length() > 12) {
                JSONObject condInfoJson = new JSONObject(finalOrdMain.getIndCondInfo());
                JSONObject ordMainCondInfoJson = parseJsonOrNull(condInfoJson.get(classCdKey));
                setNullToJsonObject(rstChecklistInfo, "code", ordMainCondInfoJson.get("value"), "Number");
                setNullToJsonObject(rstChecklistInfo, "name", mstEquipment.getEquipmentName(), "String");
            } else {
                JSONObject condInfoJson = new JSONObject(finalOrdMain.getRstCondInfo());
                JSONObject ordMainCondInfoJson = parseJsonOrNull(condInfoJson.get(classCdKey));
                setNullToJsonObject(rstChecklistInfo, "code", ordMainCondInfoJson.get("value"), "Number");
                setNullToJsonObject(rstChecklistInfo, "name", ordMainCondInfoJson.get("value_name_1"), "String");
            }
        }
    }

    @Data
    public static class ResultOfMstCdToMstDto {
        List<MstEquipment> mstEquipmentList;
        List<MstEquipmentClass> mstEquipmentClassList;
        List<MstDialyzer> mstDialyzerList;
    }
    /**
     * 取得されたrst _checklist_infoはjsonタイプであり、外部キーを置換する必要がある
     * 従って、1つずつ取り出してコレクションに入れる必要があります（重複クエリDBを回避）
     */
    private ResultOfMstCdToMstDto mstCdToMstDto(List<NamedCsvRecord> rowList,Map<String, Map<String, String>> userIdTrastMap) {
        ResultOfMstCdToMstDto resultOfMstCdToMstDto = new ResultOfMstCdToMstDto();
        //setデデューティ機能を利用する
        Set<String> setCode = new HashSet<>();
        Set<String> setClassCode = new HashSet<>();
        Set<String> setDialyzerCode = new HashSet<>();
        Set<String> setRegStaffCd = new HashSet<>();
        collectMstCdToMstDtoKeys(rowList, setCode, setClassCode, setDialyzerCode, setRegStaffCd);
        resultOfMstCdToMstDto.setMstEquipmentList(loadMstEquipmentListByFnCodes(setCode));
        resultOfMstCdToMstDto.setMstEquipmentClassList(loadMstEquipmentClassListByFnCodes(setClassCode));
        resultOfMstCdToMstDto.setMstDialyzerList(loadMstDialyzerListByFnCodes(setDialyzerCode));
        loadMstCdToMstDtoUserIdTrastMap(setRegStaffCd, userIdTrastMap);
        return resultOfMstCdToMstDto;
    }

    /**
     * mstCdToMstDto用の外部キーコード集合をCSV行から収集する
     */
    private void collectMstCdToMstDtoKeys(List<NamedCsvRecord> rowList,
                                          Set<String> setCode,
                                          Set<String> setClassCode,
                                          Set<String> setDialyzerCode,
                                          Set<String> setRegStaffCd) {
        rowList.forEach(r -> {
            String funcClass = r.getField("func_class");
            // 医療材料
            if ("2".equals(funcClass)) {
                // rst_checklist_info
                String codeValue = getValueFromJsonByKey(r.getField("rst_checklist_info"), "code");
                if (!ObjectUtils.isEmpty(codeValue) && !"null".equals(codeValue)) {
                    setCode.add(codeValue);
                }
                // rst_checklist_info
                String classCodeValue = getValueFromJsonByKey(r.getField("rst_checklist_info"), "class_cd");
                if (!ObjectUtils.isEmpty(classCodeValue) && !"null".equals(classCodeValue)) {
                    String fnClassCd = switch (classCodeValue) {
                        case "9", "10", "11" -> "202";
                        case "13" -> "203";
                        default -> classCodeValue;
                    };
                    setClassCode.add(fnClassCd);
                }
            }
            // 治療条件
            if ("1".equals(funcClass)) {
                String codeValue = getValueFromJsonByKey(r.getField("rst_checklist_info"), "code");
                if (!ObjectUtils.isEmpty(codeValue) && !"null".equals(codeValue)) {
                    setDialyzerCode.add(codeValue);
                    setCode.add(codeValue);
                }
            }
            // reg_staff_info
            String regStaffCdValue = getValueFromJsonByKey(r.getField("reg_staff_info"), "reg_staff_cd");
            if (!ObjectUtils.isEmpty(regStaffCdValue)) {
                setRegStaffCd.add(regStaffCdValue);
            }
        });
    }

    /**
     * fn_equipment_cd集合からmst_equipment一覧を読み込む
     */
    private List<MstEquipment> loadMstEquipmentListByFnCodes(Set<String> setCode) {
        StringBuilder codeSql = new StringBuilder(EMPTY);
        Iterator<String> equipmentIterator = setCode.iterator();
        String DELIMITER_SEMICOLON = ";";
        List<Object> equipmentParams = new ArrayList<>();
        while (equipmentIterator.hasNext()) {
            String text = equipmentIterator.next();
            codeSql.append("""
                                SELECT
                                  mst.equipment_cd,
                                  fn_equipment_cd,
                                  equipment_name,
                                  class_cd,
                                  unit
                                FROM mst_equipment mst
                                WHERE mst.facility_cd = ? AND mst.fn_equipment_cd :: CHARACTER VARYING = ?""");
            if (equipmentIterator.hasNext()) {
                codeSql.append(" UNION ALL \n");
            } else {
                codeSql.append(DELIMITER_SEMICOLON);
            }
            equipmentParams.add(facilityCd);
            equipmentParams.add(text);
        }
        if (!ObjectUtils.isEmpty(codeSql.toString())) {
            return namedParameterJdbcTemplateConvert.getJdbcOperations().query(codeSql.toString(), equipmentParams.toArray(), new BeanPropertyRowMapper<>(MstEquipment.class));
        }
        return new ArrayList<>();
    }

    /**
     * fn_class_cd集合からmst_equipment_class一覧を読み込む
     */
    private List<MstEquipmentClass> loadMstEquipmentClassListByFnCodes(Set<String> setClassCode) {
        StringBuilder classCodeSql = new StringBuilder(EMPTY);
        Iterator<String> equipmentClassIterator = setClassCode.iterator();
        String DELIMITER_SEMICOLON = ";";
        List<Object> equipmentClassParams = new ArrayList<>();
        while (equipmentClassIterator.hasNext()) {
            String text = equipmentClassIterator.next();
            classCodeSql.append("""
                                SELECT
                                  class_cd,
                                  fn_class_cd
                                FROM mst_equipment_class
                                WHERE facility_cd = ? AND fn_class_cd :: CHARACTER VARYING = ? """);
            if (equipmentClassIterator.hasNext()) {
                classCodeSql.append(" UNION ALL \n");
            } else {
                classCodeSql.append(DELIMITER_SEMICOLON);
            }
            equipmentClassParams.add(facilityCd);
            equipmentClassParams.add(text);
        }
        if (!ObjectUtils.isEmpty(classCodeSql.toString())) {
            return namedParameterJdbcTemplateConvert.getJdbcOperations().query(classCodeSql.toString(), equipmentClassParams.toArray(), new BeanPropertyRowMapper<>(MstEquipmentClass.class));
        }
        return new ArrayList<>();
    }

    /**
     * fn_dialyzer_cd集合からmst_dialyzer一覧を読み込む
     */
    private List<MstDialyzer> loadMstDialyzerListByFnCodes(Set<String> setDialyzerCode) {
        StringBuilder codeSqlDialyzer = new StringBuilder(EMPTY);
        Iterator<String> dialyzerIterator = setDialyzerCode.iterator();
        String DELIMITER_SEMICOLON = ";";
        List<Object> dialyzerParams = new ArrayList<>();
        while (dialyzerIterator.hasNext()) {
            String text = dialyzerIterator.next();
            codeSqlDialyzer.append("""
                                SELECT
                                  dialyzer_cd,
                                  fn_dialyzer_cd,
                                  model_number
                                FROM mst_dialyzer
                                WHERE facility_cd = ? AND fn_dialyzer_cd :: CHARACTER VARYING = ?""");
            if (dialyzerIterator.hasNext()) {
                codeSqlDialyzer.append(" UNION ALL \n");
            } else {
                codeSqlDialyzer.append(DELIMITER_SEMICOLON);
            }
            dialyzerParams.add(facilityCd);
            dialyzerParams.add(text);
        }
        if (!ObjectUtils.isEmpty(codeSqlDialyzer.toString())) {
            return namedParameterJdbcTemplateConvert.getJdbcOperations().query(codeSqlDialyzer.toString(), dialyzerParams.toArray(), new BeanPropertyRowMapper<>(MstDialyzer.class));
        }
        return new ArrayList<>();
    }

    /**
     * fn_staff_cd集合からuserIdTrastMapを読み込む
     */
    private void loadMstCdToMstDtoUserIdTrastMap(Set<String> setRegStaffCd,
                                                 Map<String, Map<String, String>> userIdTrastMap) {
        StringBuilder userIdSql = new StringBuilder(EMPTY);
        Iterator<String> userIdIterator = setRegStaffCd.iterator();
        String DELIMITER_SEMICOLON = ";";
        List<Object> userIdParams = new ArrayList<>();
        while (userIdIterator.hasNext()) {
            String text = userIdIterator.next();
            userIdSql.append("""
                                SELECT
                                  user_id,
                                  personal_info_decrypt(user_last_name) as user_last_name,
                                  personal_info_decrypt(user_first_name) as user_first_name,
                                  up_date,
                                  fn_staff_cd AS fnStaffCd
                                FROM mst_personal_user
                                WHERE facility_cd = ? AND fn_staff_cd :: CHARACTER VARYING = ?
                                """);
            if (userIdIterator.hasNext()) {
                userIdSql.append(" UNION ALL \n");
            } else {
                userIdSql.append(DELIMITER_SEMICOLON);
            }
            userIdParams.add(facilityCd);
            userIdParams.add(text);
        }

        if (!ObjectUtils.isEmpty(userIdSql.toString())) {
            List<MstPersonalUser> userIdList = namedParameterJdbcTemplateConvert.getJdbcOperations().query(userIdSql.toString(), userIdParams.toArray(), new BeanPropertyRowMapper<>(MstPersonalUser.class));
            userIdList.forEach(user -> userIdTrastMap.put(user.getFnStaffCd(),
                    user.getUserId() == null ? null : Map.of(
                            "userId", String.valueOf(user.getUserId()),
                            "upDate", String.valueOf(user.getUpDate()),
                            "regStaffName", user.getUserLastName() + user.getUserFirstName())));
        }
    }

    private void processOrdTreatCondition(Collection<String[]> resultDataList,
                                          List<NamedCsvRecord> rowList) throws IOException {
        String csvfileName = globalContext.fileName;
        //convertテーブルの最大番号を取る
        globalContext.seq=0;
        try {
            //重複クエリDBの役割を比較するためのMapの宣言
            Map<String, String> machineNoTrastMap_otc = new HashMap<>();
            Map<String, String> ordNoTrastMap_otc = new HashMap<>();
            //resultDataListが空の場合は、Headセクションを先に挿入する必要があります
            if (resultDataList.isEmpty()) {
                //最初の番号を削除し、最初のデータ、以降のデータを切り取る
                resultDataList.add(ordTreatConditionListColumnNames);
            }
            loadOrdTreatConditionMachineNoMap(rowList, machineNoTrastMap_otc);
            loadOrdTreatConditionOrdNoMap(rowList, ordNoTrastMap_otc);
            appendOrdTreatConditionRows(resultDataList, rowList, machineNoTrastMap_otc, ordNoTrastMap_otc);
        } catch (Exception ex) {
            handleProcessOrdTreatConditionException(ex, csvfileName);
        }
    }

    /**
     * machine_no外部キーの変換Mapを読み込む
     */
    private void loadOrdTreatConditionMachineNoMap(List<NamedCsvRecord> rowList, Map<String, String> machineNoTrastMap_otc) {
            Map<Object, List<NamedCsvRecord>> machine_no_group = rowList.stream()
                    .filter(f -> !ObjectUtils.isEmpty(f.getField("machine_no")))
                    .collect(Collectors.groupingBy(r -> {
                        return r.getField("machine_no");
                    }));
            Set<Object> machine_no_key = machine_no_group.keySet();
            machine_no_key.forEach(mac -> {
                String machineNoSql = "SELECT machine_no :: int8 FROM mst_machine WHERE facility_cd = ? AND fn_device_no :: CHARACTER VARYING = ? AND com_type != 2";
                List<MstMachine> mstMachineList = namedParameterJdbcTemplateConvert.getJdbcOperations().query(machineNoSql, new Object[]{facilityCd, mac.toString()}, new BeanPropertyRowMapper<>(MstMachine.class));
                if (mstMachineList.size() == 1) {
                    Long machineNo = mstMachineList.get(0).getMachineNo();
                    if (!ObjectUtils.isEmpty(machineNo)) {
                        machineNoTrastMap_otc.put(mac.toString(), String.valueOf(machineNo));
                    } else {
                        machineNoTrastMap_otc.put(mac.toString(), null);
                    }
                } else {
                    machineNoTrastMap_otc.put(mac.toString(), null);
                }
            });
    }
            //ord_no group
    /**
     * ord_no外部キーの変換Mapを読み込む
     */
    private void loadOrdTreatConditionOrdNoMap(List<NamedCsvRecord> rowList, Map<String, String> ordNoTrastMap_otc) {
            Map<Object, List<NamedCsvRecord>> ord_no_group = rowList.stream()
                    .filter(f -> !ObjectUtils.isEmpty(f.getField("ord_no")))
                    .collect(Collectors.groupingBy(r -> {
                        return r.getField("ord_no");
                    }));
            Set<Object> ord_no_key = ord_no_group.keySet();
            ord_no_key.forEach(ord -> {
                String ordNoSql = "SELECT ord_no FROM ord_main WHERE facility_cd = ? AND rst_fn_dialysis_no :: CHARACTER VARYING = ?";
                List<OrdMain> ordMainList = namedParameterJdbcTemplateConvert.getJdbcOperations().query(ordNoSql, new Object[]{facilityCd, ord.toString()}, new BeanPropertyRowMapper<>(OrdMain.class));
                if (ordMainList.size() == 1) {
                    Long ordNo = ordMainList.get(0).getOrdNo();
                    if (!ObjectUtils.isEmpty(ordNo)) {
                        ordNoTrastMap_otc.put(ord.toString(), String.valueOf(ordNo));
                    } else {
                        ordNoTrastMap_otc.put(ord.toString(), null);
                    }
                } else {
                    ordNoTrastMap_otc.put(ord.toString(), null);
                }
            });
    }
    /**
     * CSV各行をOrdTreatConditionとしてresultDataListに追加する
     */
    private void appendOrdTreatConditionRows(Collection<String[]> resultDataList,
                                             List<NamedCsvRecord> rowList,
                                             Map<String, String> machineNoTrastMap_otc,
                                             Map<String, String> ordNoTrastMap_otc) {
        rowList.forEach(r -> {
            OrdTreatCondition ordTreatCondition = buildOrdTreatConditionFromCsvRow(r, machineNoTrastMap_otc, ordNoTrastMap_otc);
            resultDataList.add(convertOrdTreatConditionToResultArray(ordTreatCondition));
        });
    }

    /**
     * ord_treat_conditionのCSV1行からOrdTreatConditionを構築する
     */
    private OrdTreatCondition buildOrdTreatConditionFromCsvRow(NamedCsvRecord r,
                                                               Map<String, String> machineNoTrastMap_otc,
                                                               Map<String, String> ordNoTrastMap_otc) {
                OrdTreatCondition ordTreatCondition = new OrdTreatCondition();
                //facility_cd
                ordTreatCondition.setFacilityCd(ObjectUtils.isEmpty(r.getField("facility_cd")) ? null : r.getField("facility_cd"));
                //reg_date
                try {
                    ordTreatCondition.setRegDate(ObjectUtils.isEmpty(r.getField("reg_date")) ? null : this.checkDate(r.getField("reg_date")));
                } catch (ParseException e) {
                    eventLoggerUtil.recordLog(
                            facilityCd,
                            eventLoggerUtil.getEventLogMessage(
                                    "processOrdTreatCondition(Collection<String[]> resultDataList, List<NamedCsvRecord> rowList)："  + EventLoggerUtil.excetionStackTraceToString(e),
                                    facilityCd,
                                    e.getClass().getName() + ".processOrdTreatCondition()"),
                            LogLevel.ERROR);
                }
                //up_date
                try {
                    ordTreatCondition.setUpDate(ObjectUtils.isEmpty(r.getField("up_date")) ? null : this.checkDate(r.getField("up_date")));
                } catch (ParseException e) {
                    eventLoggerUtil.recordLog(
                            facilityCd,
                            eventLoggerUtil.getEventLogMessage(
                                    "processOrdTreatCondition(Collection<String[]> resultDataList, List<NamedCsvRecord> rowList)："  + EventLoggerUtil.excetionStackTraceToString(e),
                                    facilityCd,
                                    e.getClass().getName() + ".processOrdTreatCondition()"),
                            LogLevel.ERROR);
                }
                //is_del
                ordTreatCondition.setIsDel(ObjectUtils.isEmpty(r.getField("is_del")) ? null : r.getField("is_del"));
                //is_disp
                ordTreatCondition.setIsDisp(ObjectUtils.isEmpty(r.getField("is_disp")) ? null : r.getField("is_disp"));
                //treat_class
                ordTreatCondition.setTreatClass(ObjectUtils.isEmpty(r.getField("treat_class")) ? null : Long.parseLong(r.getField("treat_class")));
                //receive_date
                try {
                    ordTreatCondition.setReceiveDate(ObjectUtils.isEmpty(r.getField("receive_date")) ? null : this.checkDate(r.getField("receive_date")));
                } catch (ParseException e) {
                    eventLoggerUtil.recordLog(
                            facilityCd,
                            eventLoggerUtil.getEventLogMessage(
                                    "processOrdTreatCondition(Collection<String[]> resultDataList, List<NamedCsvRecord> rowList)："  + EventLoggerUtil.excetionStackTraceToString(e),
                                    facilityCd,
                                    e.getClass().getName() + ".processOrdTreatCondition()"),
                            LogLevel.ERROR);
                }
                //machine_no
                String machine_no = ObjectUtils.isEmpty(r.getField("machine_no")) ? null : r.getField("machine_no");
                if (!ObjectUtils.isEmpty(machine_no)) {
                    if (machineNoTrastMap_otc.containsKey(machine_no)) {
                        ordTreatCondition.setMachineNo(ObjectUtils.isEmpty(machineNoTrastMap_otc.get(machine_no)) ? null : Long.parseLong(machineNoTrastMap_otc.get(machine_no)));
                    } else {
                        ordTreatCondition.setMachineNo(null);
                    }
                } else {
                    ordTreatCondition.setMachineNo(null);
                }
                //ord_no
                String ord_no = ObjectUtils.isEmpty(r.getField("ord_no")) ? null : r.getField("ord_no");
                if (!ObjectUtils.isEmpty(ord_no)) {
                    if (ordNoTrastMap_otc.containsKey(ord_no)) {
                        ordTreatCondition.setOrdNo(ObjectUtils.isEmpty(ordNoTrastMap_otc.get(ord_no)) ? null : Long.parseLong(ordNoTrastMap_otc.get(ord_no)));
                    } else {
                        ordTreatCondition.setOrdNo(null);
                    }
                } else {
                    ordTreatCondition.setOrdNo(null);
                }
                //treat_condition
                String treat_condition = ObjectUtils.isEmpty(r.getField("treat_condition")) ? null : r.getField("treat_condition");
                if (!ObjectUtils.isEmpty(treat_condition)) {
                    JSONObject jsonObject = new JSONObject(treat_condition);
                    ordTreatCondition.setTreatCondition(jsonObject);
                } else {
                    ordTreatCondition.setTreatCondition(null);
                }
        return ordTreatCondition;
    }
                //文字列配列への変換（ToStringメソッド内でカンマが｜に置換されており、配列への切断後に正しいjsonフォーマットを保証するために、｜をカンマに置換する必要があります）
    private String[] convertOrdTreatConditionToResultArray(OrdTreatCondition ordTreatCondition) {
                String[] ordTreatConditionArray = ordTreatCondition.toString().split(",");
                if (ordTreatConditionArray.length > 0) {
                    int treatConditionJson = ordTreatConditionArray.length - 1;
                    //データグループの最後の2つの要素、つまり最後の2つのjsonを取ります
                    if (ordTreatConditionArray[treatConditionJson].contains("|")) {
                        ordTreatConditionArray[treatConditionJson] = ordTreatConditionArray[treatConditionJson].replace("|", ",");
                    }
                }
                //各行置換後の最終結果データセットの書き込み
        return ordTreatConditionArray;
    }

    /**
     * ord_treat_condition処理の例外をログ出力する
     */
    private void handleProcessOrdTreatConditionException(Exception ex, String csvfileName) throws IOException {
            System.err.println("実行" + csvfileName + "ファイル中にエラーが発生しました！\n");
            //出力詳細エラー情報
            //ログ
            EventLogMessage eventLogMessage = eventLoggerUtil.getEventLogMessage("CSVファイルの処理に失敗しました：" + csvfileName,
                    facilityCd, "BatchCsvWriterDb.write()");
            eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.ERROR);
            //ログ
            EventLogMessage eventLogMessagex = eventLoggerUtil.getEventLogMessage("詳細なエラー情報：" + ex.toString(),
                    facilityCd, "BatchCsvWriterDb.write()");
            eventLoggerUtil.recordLog(facilityCd, eventLogMessagex, LogLevel.ERROR);


            eventLoggerUtil.recordLog(
                    facilityCd,
                    eventLoggerUtil.getEventLogMessage(
                            "processOrdTreatCondition(Collection<String[]> resultDataList, List<NamedCsvRecord> rowList)："  + EventLoggerUtil.excetionStackTraceToString(ex),
                            facilityCd,
                            ex.getClass().getName() + ".processOrdTreatCondition()"),
                    LogLevel.ERROR);
            this.errorfile(csvfileName);
    }


    private void processOrdCoopNo(Collection<String[]> resultDataList,
                                  List<NamedCsvRecord> rowList) throws IOException {
        String csvfileName = globalContext.fileName;
        //convertテーブルの最大番号を取る
        globalContext.seq=0;
        try {
            //重複クエリDBの役割を比較するためのMapの宣言
            Map<String, String> patIdMap = new HashMap<>();
            Map<String, String> ordNoMap = new HashMap<>();
            //8321
            Map<String, String> userIdMap = new HashMap<>();
            //8321
            Map<String, String> hospPatIdMap = new HashMap<>();
            //resultDataListが空の場合は、Headセクションを先に挿入する必要があります
            if (resultDataList.isEmpty()) {
                // 取得テーブルの列を取得
                resultDataList.add(ordCoopNoListColumnNames);
            }
            loadOrdCoopNoPatIdCache(rowList, patIdMap, hospPatIdMap);
            loadOrdCoopNoOrdNoCache(rowList, ordNoMap, userIdMap);
            /**
             * CSVを巡回する行、データのパッケージング、CSVファイルの再編成
             */
            rowList.forEach(r -> {
                OrdCoopNo ordCoopNo = buildOrdCoopNoFromCsvRow(r, patIdMap, hospPatIdMap, ordNoMap, userIdMap);
                //DTOトランス文字列配列
                String[] ordCoopNoArray = ordCoopNo.toString().split(",");

                //各行置換後の最終結果データセットの書き込み
                resultDataList.add(ordCoopNoArray);
            });
        } catch (Exception exception) {
            handleProcessOrdCoopNoException(exception, csvfileName);
        }

    }

    /**
     * グループフィルタリング重複する外部キー条件をフィルタリングした後、キャッシュMapに外部キー値をクエリーします
     * pat_id groupとhosp _pat_idの出所は一致しており、いずれも古いシステムの患者idであるため、同じsql文として検索された
     */
    private void loadOrdCoopNoPatIdCache(List<NamedCsvRecord> rowList,
                                         Map<String, String> patIdMap,
                                         Map<String, String> hospPatIdMap) {
            Map<Object, List<NamedCsvRecord>> pat_id_group = rowList.stream()
                    .filter(f -> !ObjectUtils.isEmpty(f.getField("pat_id")))
                    .collect(Collectors.groupingBy(r -> {
                        return r.getField("pat_id");
                    }));
            Set<Object> pat_id_key = pat_id_group.keySet();
            pat_id_key.stream().forEach(pk -> {
                String patIdSql = "SELECT pat_id, hosp_pat_id FROM pat_personal_main WHERE facility_cd = ? AND fn_pat_id :: CHARACTER VARYING = ?";
                List<PatPersonalMain> patIdList = namedParameterJdbcTemplateConvert.getJdbcOperations().query(patIdSql, new Object[]{facilityCd, pk.toString()}, new BeanPropertyRowMapper<>(PatPersonalMain.class));
                if (patIdList.size() == 1) {
                    Long pat_id = patIdList.get(0).getPat_id();
                    //患者IDキャッシュを入れる
                    patIdMap.put(String.valueOf(pk), String.valueOf(pat_id));
                    String hosp_pat_id = patIdList.get(0).getHosp_pat_id();
                    //hosp _pat_idキャッシュ
                    hospPatIdMap.put(String.valueOf(pk), hosp_pat_id);
                } else {
                    patIdMap.put(String.valueOf(pk), null);
                    hospPatIdMap.put(String.valueOf(pk), null);
                }
            });
    }

    private void loadOrdCoopNoOrdNoCache(List<NamedCsvRecord> rowList,
                                         Map<String, String> ordNoMap,
                                         Map<String, String> userIdMap) {
        //ord_no group
            Map<Object, List<NamedCsvRecord>> ord_no_group = rowList.stream()
                    .filter(f -> !ObjectUtils.isEmpty(f.getField("ord_no")))
                    .collect(Collectors.groupingBy(r -> {
                        return r.getField("ord_no") + "&" + r.getField("coop_cd");
                    }));
            Set<Object> ord_no_key = ord_no_group.keySet();
        ord_no_key.stream().forEach(onk -> putOrdCoopNoOrdNoCacheEntry(onk, ordNoMap, userIdMap));
    }

    private void putOrdCoopNoOrdNoCacheEntry(Object onk,
                                             Map<String, String> ordNoMap,
                                             Map<String, String> userIdMap) {
                if (String.valueOf(onk).contains("&")) {
                    String[] ord_coop = onk.toString().split("&");
                    //add 8321
                    if (ord_coop[1].equals("profile")) {
                        ordNoMap.put(String.valueOf(onk), null);
                        userIdMap.put(String.valueOf(onk), null);
                    } else {
                        // #10418 SQLインジェクション対策：文字列連結の代わりに?プレースホルダーを使用
                        Map<String, Object> params = new HashMap<>();
                        params.put("facilityCd", facilityCd);
                        params.put("inputStr", ord_coop[0]);
                        String swhere = null;
                        String sUserId = null;
                        if (ord_coop[1].equals("ind_dial")) {
                            swhere = "\t AND treat_date = ( SELECT substr( :inputStr, 1, 8 ) ) \n" +
                                    "\t AND fn_pat_id :: CHARACTER VARYING = substr( :inputStr, 16, 12 ) \n" +
                                    "\t AND fn_plural :: TEXT = substr( :inputStr, 28, 1 ) :: TEXT \n";
                        } else {
                            swhere = "AND rst_fn_dialysis_no = ( SELECT substr( :inputStr, 0, 13 ) :: int8 )";
                        }
                        if (ord_coop[1].equals("rep_dial") || ord_coop[1].equals("rst_dial")) {
                            sUserId = "up_ind_user_id";
                        } else if (ord_coop[1].equals("ind_dial")) {
                            sUserId = "ind_schedule_user_info -> 'ind_user_id'";
                        }
                        String ord_no_sql = "SELECT " + sUserId + " AS up_ind_user_id, ord_no " +
                                "FROM ord_main " +
                                "WHERE facility_cd = :facilityCd " +
                                swhere +
                                "LIMIT 1";
                        List<OrdMain> ordNoList = namedParameterJdbcTemplateConvert.query(ord_no_sql, params, new BeanPropertyRowMapper<>(OrdMain.class));
                        if (ordNoList.size() == 1) {
                            Long ord_no = ordNoList.get(0).getOrdNo();
                            Long user_id = ordNoList.get(0).getUpIndUserId();
                            ordNoMap.put(String.valueOf(onk), String.valueOf(ord_no));
                            userIdMap.put(String.valueOf(onk), String.valueOf(user_id));
                        } else {
                            ordNoMap.put(String.valueOf(onk), null);
                            userIdMap.put(String.valueOf(onk), null);
                        }
                    }
                    //add  8321
                } else {
                    ordNoMap.put(String.valueOf(onk), null);
                    userIdMap.put(String.valueOf(onk), null);
                }
    }

    private OrdCoopNo buildOrdCoopNoFromCsvRow(NamedCsvRecord r,
                                               Map<String, String> patIdMap,
                                               Map<String, String> hospPatIdMap,
                                               Map<String, String> ordNoMap,
                                               Map<String, String> userIdMap) {
                OrdCoopNo ordCoopNo = new OrdCoopNo();
                //facility_cd
                ordCoopNo.setFacilityCd(ObjectUtils.isEmpty(r.getField("facility_cd")) || "null".equals(r.getField("facility_cd")) ? "" : r.getField("facility_cd"));
                //coop_cd
                ordCoopNo.setCoopCd(ObjectUtils.isEmpty(r.getField("coop_cd")) || "null".equals(r.getField("coop_cd")) ? "" : r.getField("coop_cd"));
                //hosp_pat_id
                String hospPatId = ObjectUtils.isEmpty(r.getField("hosp_pat_id")) || "null".equals(r.getField("hosp_pat_id")) ? "" : r.getField("hosp_pat_id");
                if (!"".equals(hospPatId)) {
                    if (hospPatIdMap.containsKey(hospPatId) && !"null".equals(hospPatIdMap.get(hospPatId))) {
                        ordCoopNo.setHospPatId(hospPatIdMap.get(hospPatId));
                    } else {
                        ordCoopNo.setHospPatId(null);
                    }
                }
                //pat_id
                String patId = ObjectUtils.isEmpty(r.getField("pat_id")) || "null".equals(r.getField("pat_id")) ? "" : r.getField("pat_id");
                if (!"".equals(patId)) {
                    if (patIdMap.containsKey(patId)) {
                        if (!ObjectUtils.isEmpty(patIdMap.get(patId)) && !"null".equals(patIdMap.get(patId))) {
                            ordCoopNo.setPatId(Long.parseLong(patIdMap.get(patId)));
                        }
                    }
                } else {
                    ordCoopNo.setPatId(null);
                }
                //ord_no取得ord _noで使用される条件は、coop _cdを取得する必要があるので、coop _cdの値を固定論理で結合して使用する
                String ord_no = ObjectUtils.isEmpty(r.getField("ord_no")) || "null".equals(r.getField("ord_no")) ? "" : r.getField("ord_no");
                String coop_cd = ObjectUtils.isEmpty(r.getField("coop_cd")) || "null".equals(r.getField("coop_cd")) ? "" : r.getField("coop_cd");
                ord_no = ord_no + "&" + coop_cd;
                if (ordNoMap.containsKey(ord_no)) {
                    if (!ObjectUtils.isEmpty(ordNoMap.get(ord_no)) && !"null".equals(ordNoMap.get(ord_no))) {
                        ordCoopNo.setOrdNo(Long.parseLong(ordNoMap.get(ord_no)));
                    }
                } else {
                    ordCoopNo.setOrdNo(null);
                }
                //add  8321
                String user_id = ObjectUtils.isEmpty(r.getField("user_id")) || "null".equals(r.getField("user_id")) ? "" : r.getField("user_id");
                user_id = user_id + "&" + coop_cd;
                if (userIdMap.containsKey(user_id)) {
                    if (!ObjectUtils.isEmpty(userIdMap.get(user_id)) && !"null".equals(userIdMap.get(user_id))) {
                        ordCoopNo.setUserId(Long.parseLong(userIdMap.get(user_id)));
                    }
                } else {
                    ordCoopNo.setUserId(null);
                }
                //add  8321
                //status
                String status = ObjectUtils.isEmpty(r.getField("status")) || "null".equals(r.getField("status")) ? "" : r.getField("status");
                ordCoopNo.setStatus(status);
                //coop_ord_no
                String coop_ord_no = ObjectUtils.isEmpty(r.getField("coop_ord_no")) || "null".equals(r.getField("coop_ord_no")) ? "" : r.getField("coop_ord_no");
                ordCoopNo.setCoopOrdNo(coop_ord_no);
                //is_del
                String is_del = ObjectUtils.isEmpty(r.getField("is_del")) || "null".equals(r.getField("is_del")) ? "" : r.getField("is_del");
                ordCoopNo.setIsDel(is_del);
                //is_disp
                String is_disp = ObjectUtils.isEmpty(r.getField("is_disp")) || "null".equals(r.getField("is_disp")) ? "" : r.getField("is_disp");
                ordCoopNo.setIsDisp(is_disp);
        applyOrdCoopNoRegDate(ordCoopNo, r);
        applyOrdCoopNoUpDate(ordCoopNo, r);
        //add 11806 ord_coop_no.coop_versionが空欄でコンバートされる hyl  start
        //coop_version
        String coop_version = ObjectUtils.isEmpty(r.getField("coop_version")) || "null".equals(r.getField("coop_version")) ? "" : r.getField("coop_version");
        ordCoopNo.setCoopVersion(coop_version);
        //add 11806 ord_coop_no.coop_versionが空欄でコンバートされる hyl  end
        return ordCoopNo;
    }

    private void applyOrdCoopNoRegDate(OrdCoopNo ordCoopNo, NamedCsvRecord r) {
                //reg_date
                try {
                    ordCoopNo.setRegDate(this.checkDate(r.getField("reg_date")));
                } catch (ParseException e) {
                    eventLoggerUtil.recordLog(
                            facilityCd,
                            eventLoggerUtil.getEventLogMessage(
                                    "processOrdCoopNo(Collection<String[]> resultDataList, List<NamedCsvRecord> rowList)："  + EventLoggerUtil.excetionStackTraceToString(e),
                                    facilityCd,
                                    e.getClass().getName() + ".processOrdCoopNo()"),
                            LogLevel.ERROR);
                }
    }

    private void applyOrdCoopNoUpDate(OrdCoopNo ordCoopNo, NamedCsvRecord r) {
                //up_date
                try {
                    ordCoopNo.setUpDate(this.checkDate(r.getField("up_date")));
                } catch (ParseException e) {
                    eventLoggerUtil.recordLog(
                            facilityCd,
                            eventLoggerUtil.getEventLogMessage(
                                    "processOrdCoopNo(Collection<String[]> resultDataList, List<NamedCsvRecord> rowList)："  + EventLoggerUtil.excetionStackTraceToString(e),
                                    facilityCd,
                                    e.getClass().getName() + ".processOrdCoopNo()"),
                            LogLevel.ERROR);
                }
    }

    private void handleProcessOrdCoopNoException(Exception exception, String csvfileName) {
            System.err.println("実行" + csvfileName + "ファイル中にエラーが発生しました！\n");
            //出力詳細エラー情報
            //ログ
            EventLogMessage eventLogMessage = eventLoggerUtil.getEventLogMessage("CSVファイルの処理に失敗しました：" + csvfileName,
                    facilityCd, "BatchCsvWriterDb.write()");
            eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.ERROR);

            eventLoggerUtil.recordLog(
                    facilityCd,
                    eventLoggerUtil.getEventLogMessage(
                            "processOrdCoopNo(Collection<String[]> resultDataList, List<NamedCsvRecord> rowList)："  + EventLoggerUtil.excetionStackTraceToString(exception),
                            facilityCd,
                            exception.getClass().getName() + ".processOrdCoopNo()"),
                    LogLevel.ERROR);
    }

    private void processPatUniqueHistory(List<NamedCsvRecord> rowList) throws IOException {
        String csvfileName = globalContext.fileName;
        try {
            loadPatUniqueHistoryFacilityName();
            Map<String, String> patIdHistoryMap = new HashMap<>();
            // mod #10735 djy start
            Map<String, Integer> diseaseCdHistoryMap = new HashMap<>();
            // mod #10735 djy end
            Map<String, String> indicatorCdHistoryMap = new HashMap<>();
            LocalDateTime dateTime = LocalDateTime.now();
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
            String date = dateTime.format(formatter);
            List<PatUniqueHistoryEntity> patUniqueHistoryEntityList = new ArrayList<>();
            rowList.forEach(rl -> patUniqueHistoryEntityList.add(
                    buildPatUniqueHistoryEntityFromRow(rl, patIdHistoryMap, diseaseCdHistoryMap, indicatorCdHistoryMap, date)));
            insertPatUniqueHistoryToMongoWithLatestFlags(patIdHistoryMap, patUniqueHistoryEntityList);
        } catch (Exception exception) {
            handleProcessPatUniqueHistoryException(exception);
        } finally {
            Path path = Paths.get(csvfileName);
            Files.deleteIfExists(path);
        }
    }

    /**
     * pat_unique_history処理用の施設名を読み込む
     */
    private void loadPatUniqueHistoryFacilityName() {
        String Fsql = "select facility_name from mst_facility where facility_cd = ?";
        if (globalContext.facilityName == null || globalContext.facilityName.isEmpty()) {
            globalContext.facilityName = namedParameterJdbcTemplateConvert.getJdbcOperations().queryForObject(Fsql, new Object[]{facilityCd}, String.class);
        }
    }

    /**
     * pat_unique_historyのCSV1行からEntityを生成する
     */
    private PatUniqueHistoryEntity buildPatUniqueHistoryEntityFromRow(NamedCsvRecord rl,
                                                                      Map<String, String> patIdHistoryMap,
                                                                      Map<String, Integer> diseaseCdHistoryMap,
                                                                      Map<String, String> indicatorCdHistoryMap,
                                                                      String date) {
                PatUniqueHistoryEntity patUniqueHistoryEntity = new PatUniqueHistoryEntity();
                //facility_cd
                patUniqueHistoryEntity.setFacilityCd(rl.getField("facility_cd"));
        applyPatUniqueHistoryPatId(patUniqueHistoryEntity, rl, patIdHistoryMap);
        patUniqueHistoryEntity.setUpDate(ObjectUtils.isEmpty(rl.getField("up_date")) ? null : rl.getField("up_date").toString());
        patUniqueHistoryEntity.setRegDate(ObjectUtils.isEmpty(rl.getField("reg_date")) ? null : rl.getField("reg_date").toString());
        try {
            patUniqueHistoryEntity.setInsDate(this.checkDate(date));
        } catch (ParseException e) {
            eventLoggerUtil.recordLog(
                    facilityCd,
                    eventLoggerUtil.getEventLogMessage(
                            "processOrdCoopNo(Collection<String[]> resultDataList, List<NamedCsvRecord> rowList)：" + EventLoggerUtil.excetionStackTraceToString(e),
                            facilityCd,
                            e.getClass().getName() + ".processOrdCoopNo()"),
                    LogLevel.ERROR);
        }
        patUniqueHistoryEntity.setIsDel("0");
        ObjectMapper objectMapper = new ObjectMapper();
        applyPatUniqueHistoryMedicalHstInfo(patUniqueHistoryEntity, rl, diseaseCdHistoryMap, objectMapper);
        applyPatUniqueHistoryInOutVisitInfo(patUniqueHistoryEntity, rl, objectMapper);
        applyPatUniqueHistoryPhysicalInfo(patUniqueHistoryEntity, rl, indicatorCdHistoryMap, objectMapper);
        return patUniqueHistoryEntity;
    }

    /**
     * pat_unique_historyのpat_id外部キーを置換する
     */
    private void applyPatUniqueHistoryPatId(PatUniqueHistoryEntity patUniqueHistoryEntity,
                                            NamedCsvRecord rl,
                                            Map<String, String> patIdHistoryMap) {
                String patId = rl.getField("pat_id");
                if (!ObjectUtils.isEmpty(patId) && !"null".equals(patId)) {
                    if (patIdHistoryMap.containsKey(patId)) {
                        //含めるとDTOに直接入れる
                        patUniqueHistoryEntity.setPatId(patIdHistoryMap.get(patId));
                    } else {
                        //含まない場合はDB検索
                        String sql = "SELECT pat_id FROM pat_personal_main WHERE facility_cd = ? AND fn_pat_id :: CHARACTER VARYING = ?";
                        List<PatPersonalMain> patList = namedParameterJdbcTemplateConvert.getJdbcOperations().query(sql, new Object[]{facilityCd, patId}, new BeanPropertyRowMapper<>(PatPersonalMain.class));
                        if (patList.size() == 1) {
                            Long pat_id = patList.get(0).getPat_id();
                            //含めるとDTOに直接入れる
                            patUniqueHistoryEntity.setPatId(pat_id == null ? null : pat_id.toString());
                            //キャッシュマップの配置
                            patIdHistoryMap.put(patId, pat_id.toString());
                        } else {
                            patUniqueHistoryEntity.setPatId(null);
                        }
                    }
                } else {
                    patUniqueHistoryEntity.setPatId(null);
                }
    }

    /**
     * pat_unique_historyのmedical_hst_infoを外部キー置換する
     */
    private void applyPatUniqueHistoryMedicalHstInfo(PatUniqueHistoryEntity patUniqueHistoryEntity,
                                                     NamedCsvRecord rl,
                                                     Map<String, Integer> diseaseCdHistoryMap,
                                                     ObjectMapper objectMapper) {
                String mhi = ObjectUtils.isEmpty(rl.getField("medical_hst_info")) || "null".equals(rl.getField("medical_hst_info")) ? "" : rl.getField("medical_hst_info");
                if (!"".equals(mhi)) {
                    JSONArray jsonArray = new JSONArray(mhi);
                    jsonArray.forEach(j -> {
                        JSONObject jsonObject = parseJsonOrNull(j);
                        String disease_cd = ObjectUtils.isEmpty(jsonObject.get("disease_cd")) ? "" : jsonObject.get("disease_cd").toString();
                        String[] diseaseArray = {};
                        if (disease_cd.contains("_")) {
                            if (!diseaseCdHistoryMap.containsKey(disease_cd)) {
                                diseaseArray = disease_cd.split("_");
                                //外部キー対応番号を調べる
                                String diseaseCdSql = "SELECT disease_cd FROM mst_disease WHERE fn_disease_cd = ? AND facility_cd = ? AND fn_class_cd = ?";
                                List<MstDisease> mpuList = namedParameterJdbcTemplateConvert.getJdbcOperations().query(diseaseCdSql, new Object[]{diseaseArray[0], facilityCd, diseaseArray[1]}, new BeanPropertyRowMapper<>(MstDisease.class));
                                if (mpuList.size() == 1) {
                                    Integer diseaseCd = mpuList.get(0).getDiseaseCd();
                                    jsonObject.put("disease_cd", diseaseCd);
                                    //キャッシュコレクションMapの配置
                                    // mod #10735 djy start
                                    diseaseCdHistoryMap.put(disease_cd, diseaseCd);
                                    // mod #10735 djy end
                                } else {
                                    diseaseCdHistoryMap.put(disease_cd, null);
                                    jsonObject.put("disease_cd",  diseaseCdHistoryMap.get(disease_cd));
                                }
                            } else {
                                // mod #10735 djy start
                                jsonObject.put("disease_cd", diseaseCdHistoryMap.get(disease_cd));
                                // mod #10735 djy end
                            }
                        }
                        jsonObject.put("facility_cd", facilityCd);
                        jsonObject.put("facility_name", globalContext.facilityName);
                    });
                    // mod #11268 limingyang start
                    List<MedicalHstInfo> medicalHstInfo = null;
                    try {
                        medicalHstInfo = objectMapper.readValue(jsonArray.toString(), objectMapper.getTypeFactory().constructCollectionType(List.class, MedicalHstInfo.class));
                    } catch (tools.jackson.core.JacksonException e) {
                        eventLoggerUtil.recordLog(facilityCd,
                                eventLoggerUtil.getEventLogMessage("「ERROR」" + jsonArray.toString(),
                                        facilityCd, "mongo List<T> convert error"), LogLevel.ERROR);
                    }
                    patUniqueHistoryEntity.setMedicalHstInfo(medicalHstInfo);
                    // mod #11268 limingyang end
                } else {
                    // mod #11268 limingyang start
                    patUniqueHistoryEntity.setMedicalHstInfo(null);
        }
                }
                //in_out_visit_history_info
    /**
     * pat_unique_historyのin_out_visit_history_infoを設定する
     */
    private void applyPatUniqueHistoryInOutVisitInfo(PatUniqueHistoryEntity patUniqueHistoryEntity,
                                                     NamedCsvRecord rl,
                                                     ObjectMapper objectMapper) {
                String inout = ObjectUtils.isEmpty(rl.getField("in_out_visit_history_info")) || "null".equals(rl.getField("in_out_visit_history_info")) ? "" : rl.getField("in_out_visit_history_info");
                if (!"".equals(inout)) {
                    JSONArray js = new JSONArray(inout);
                    js.forEach(jjs -> {
                        JSONObject jsonObjectjs = parseJsonOrNull(jjs);
                        jsonObjectjs.put("facility_cd", facilityCd);
                        jsonObjectjs.put("facility_name", globalContext.facilityName);
                    });
                    // mod #11268 limingyang start
                    List<InOutVisitHistoryInfo> inOutVisitHistoryInfo = null;
                    try {
                        inOutVisitHistoryInfo = objectMapper.readValue(js.toString(), objectMapper.getTypeFactory().constructCollectionType(List.class, InOutVisitHistoryInfo.class));
                    } catch (tools.jackson.core.JacksonException e) {
                        eventLoggerUtil.recordLog(facilityCd,
                                eventLoggerUtil.getEventLogMessage("「ERROR」" + js.toString(),
                                        facilityCd, "mongo List<T> convert error"), LogLevel.ERROR);
                    }
                    patUniqueHistoryEntity.setInOutVisitHistoryInfo(inOutVisitHistoryInfo);
                    // mod #11268 limingyang end
                } else {
                    // mod #11268 limingyang start
                    patUniqueHistoryEntity.setInOutVisitHistoryInfo(null);
        }
                }
                //physical_info
    /**
     * pat_unique_historyのphysical_infoを外部キー置換する
     */
    private void applyPatUniqueHistoryPhysicalInfo(PatUniqueHistoryEntity patUniqueHistoryEntity,
                NamedCsvRecord rl,
                                                   Map<String, String> indicatorCdHistoryMap,
                                                   ObjectMapper objectMapper) {
                String pi = ObjectUtils.isEmpty(rl.getField("physical_info")) || "null".equals(rl.getField("physical_info")) ? "" : rl.getField("physical_info");
                if (!"".equals(pi)) {
                    JSONArray jsonArraypi = new JSONArray(pi);
                    jsonArraypi.forEach(jpi -> {
                        JSONObject jsonObjectpi = parseJsonOrNull(jpi);
                        String indicator_cd = ObjectUtils.isEmpty(jsonObjectpi.get("indicator_cd")) || "null".equals(jsonObjectpi.get("indicator_cd")) ? "" : String.valueOf(jsonObjectpi.get("indicator_cd"));
                        if (!indicatorCdHistoryMap.containsKey(indicator_cd)) {
                            //外部キー対応番号を調べる
                            String indicatorCdSql = "SELECT user_id FROM mst_personal_user WHERE facility_cd = ? AND fn_staff_cd :: CHARACTER VARYING = ? ORDER BY user_id DESC LIMIT 1";
                            List<MstPersonalUser> userList = namedParameterJdbcTemplateConvert.getJdbcOperations().query(indicatorCdSql, new Object[]{facilityCd, indicator_cd}, new BeanPropertyRowMapper<>(MstPersonalUser.class));
                            if (userList.size() == 1) {
                                Long userId = userList.get(0).getUserId();
                                jsonObjectpi.put("indicator_cd", String.valueOf(userId));
                                //キャッシュコレクションMapの配置
                                indicatorCdHistoryMap.put(indicator_cd, String.valueOf(userId));
                            } else {
                                indicatorCdHistoryMap.put(indicator_cd, null);
                            }
                        } else {
                            // mod #10735 djy start
                            if(indicatorCdHistoryMap.get(indicator_cd) != null){
                                jsonObjectpi.put("indicator_cd", String.valueOf(indicatorCdHistoryMap.get(indicator_cd)));
                            }
                            // mod #10735 djy end
                        }

                        // add #10707 djy start
                        String changer_cd = ObjectUtils.isEmpty(jsonObjectpi.get("changer_cd")) || "null".equals(jsonObjectpi.get("changer_cd")) ? "" : String.valueOf(jsonObjectpi.get("changer_cd"));
                        if (!indicatorCdHistoryMap.containsKey(changer_cd)) {
                            //外部キー対応番号を調べる
                            String indicatorCdSql = "SELECT user_id FROM mst_personal_user WHERE facility_cd = :facility_cd AND fn_staff_cd :: CHARACTER VARYING = :fn_staff_cd ORDER BY user_id DESC LIMIT 1";
                            MapSqlParameterSource params = new MapSqlParameterSource();
                            params.addValue("facility_cd", facilityCd);
                            params.addValue("fn_staff_cd", changer_cd);
                            NamedParameterJdbcTemplate namedParameterJdbcTemplate = new NamedParameterJdbcTemplate(namedParameterJdbcTemplateConvert.getJdbcOperations());
                            List<MstPersonalUser> userList = namedParameterJdbcTemplate.query(indicatorCdSql, params,new BeanPropertyRowMapper<>(MstPersonalUser.class));
                            if (userList.size() == 1) {
                                Long userId = userList.get(0).getUserId();
                                jsonObjectpi.put("changer_cd", String.valueOf(userId));
                                //キャッシュコレクションMapの配置
                                indicatorCdHistoryMap.put(changer_cd, String.valueOf(userId));
                            } else {
                                indicatorCdHistoryMap.put(changer_cd, null);
                            }
                        } else {
                            // mod #10735 djy start
                            if(indicatorCdHistoryMap.get(changer_cd) != null){
                                jsonObjectpi.put("changer_cd", String.valueOf(indicatorCdHistoryMap.get(changer_cd)));
                            }
                            // mod #10735 djy end
                        }
                        // add #10707 djy end

                        jsonObjectpi.put("facility_cd", facilityCd);
                        jsonObjectpi.put("facility_name", globalContext.facilityName);
                    });
                    // mod #11268 limingyang start
                    List<PhysicalInfo> physicalInfo = null;
                    try {
                        physicalInfo = objectMapper.readValue(jsonArraypi.toString(), objectMapper.getTypeFactory().constructCollectionType(List.class, PhysicalInfo.class));
                    } catch (tools.jackson.core.JacksonException e) {
                        eventLoggerUtil.recordLog(facilityCd,
                                eventLoggerUtil.getEventLogMessage("「ERROR」" + jsonArraypi.toString(),
                                        facilityCd, "mongo List<T> convert error"), LogLevel.ERROR);
                    }
                    patUniqueHistoryEntity.setPhysicalInfo(physicalInfo);
                    // mod #11268 limingyang end
                } else {
                    // mod #11268 limingyang start
                    patUniqueHistoryEntity.setPhysicalInfo(null);
                    // mod #11268 limingyang end
                }
    }

    /**
     * pat_unique_historyをlatest_flag設定後にMongoDBへ一括挿入する
     */
    private void insertPatUniqueHistoryToMongoWithLatestFlags(Map<String, String> patIdHistoryMap,
                                                              List<PatUniqueHistoryEntity> patUniqueHistoryEntityList) {
            List<String> fnsiPatIds = patIdHistoryMap.values().stream().toList();
            // 指定患者id範囲の履歴データを全て「latest_flag=off」を設定する
            Query query = new Query();
            Update update = new Update();
            query
                    .addCriteria(Criteria.where("pat_id").in(fnsiPatIds))
                    .addCriteria(Criteria.where("facility_cd").is(facilityCd));
            update.set(ApplicationConst.LatestFlag.LATEST_FLAG, ApplicationConst.LatestFlag.OFF);
            mongoTemplate.updateMulti(query, update, PatUniqueHistoryEntity.class);

            Map<String, List<PatUniqueHistoryEntity>> patIdGroups = patUniqueHistoryEntityList.stream().filter(r -> null != r.getPatId()).collect(Collectors.groupingBy(PatUniqueHistoryEntity::getPatId));
            Map<String, String> maxUpdateMap = new HashMap<>();
            patIdGroups.forEach((patId, uniqueHistoryEntityList) -> {
                List<PatUniqueHistoryEntity> maxUpdateList = uniqueHistoryEntityList.stream().sorted(Comparator.comparing(PatUniqueHistoryEntity::getUpDate).reversed()).toList();
                maxUpdateMap.put(patId, maxUpdateList.get(0).getUpDate());
            });
            List<PatUniqueHistoryEntity> finalPatUniqueHistoryEntityList = patUniqueHistoryEntityList.stream().peek(e -> {
                if (!ObjectUtils.isEmpty(e.getPatId()) && maxUpdateMap.containsKey(e.getPatId())
                        && !ObjectUtils.isEmpty(e.getUpDate()) && e.getUpDate().equals(maxUpdateMap.get(e.getPatId()))
                ) {
                    e.setLatestFlag(ApplicationConst.LatestFlag.ON);
                    maxUpdateMap.remove(e.getPatId());
                } else {
                    e.setLatestFlag(ApplicationConst.LatestFlag.OFF);
                }
            }).toList();
            // add #10534 pat_main_history, pat_unique_history, pat_personal_main_historyのcollectionにlatest_flagを追加する。 zkm end
            //INSERT mongoDB
            mongoTemplate.insertAll(finalPatUniqueHistoryEntityList);
    }

    /**
     * pat_unique_history処理の例外をログ出力する
     */
    private void handleProcessPatUniqueHistoryException(Exception exception) {
            EventLogMessage eventLogMessage9 = eventLoggerUtil.getEventLogMessage("pat_unique_history一括mongodb挿入に失敗しました！",
                    facilityCd, "");
            eventLoggerUtil.recordLog(facilityCd, eventLogMessage9, LogLevel.ERROR);

            eventLoggerUtil.recordLog(
                    facilityCd,
                    eventLoggerUtil.getEventLogMessage(
                            "processOrdCoopNo(Collection<String[]> resultDataList, List<NamedCsvRecord> rowList)："  + EventLoggerUtil.excetionStackTraceToString(exception),
                            facilityCd,
                            exception.getClass().getName() + ".processOrdCoopNo()"),
                    LogLevel.ERROR);
    }

    private void processPatExamMain(Collection<String[]> resultDataList,
                                    List<NamedCsvRecord> rowList) throws IOException {
        String csvfileName = globalContext.fileName;
        try {
            initPatExamMainHeaderIfEmpty(resultDataList, rowList);
            Map<String, Map<String, String>> examSetMap = new HashMap<>();
            Map<String, Map<String, String>> examItemMap = new HashMap<>();
            Map<String, Long> userIdMap = new HashMap<>();
            Map<String, String> patPersonalMainMap = new HashMap<>();
            mstToCacheMapForPatExamMain(rowList, examSetMap, examItemMap, userIdMap, patPersonalMainMap);
            appendPatExamMainRows(resultDataList, rowList, examSetMap, examItemMap, userIdMap, patPersonalMainMap);
        } catch (Exception ex) {
            handleProcessPatExamMainException(ex, csvfileName);
        }
    }

    /**
     * resultDataListが空の場合にpat_exam_mainヘッダ行を追加する
     */
    private void initPatExamMainHeaderIfEmpty(Collection<String[]> resultDataList, List<NamedCsvRecord> rowList) {
            if (resultDataList.isEmpty()) {
                if (!rowList.isEmpty() && !ObjectUtils.isEmpty(rowList.get(0).getField("exam_status"))) {
                    if("0".equals(rowList.get(0).getField("exam_status"))) {
                        resultDataList.add(patExamMainSchColumnNames);
                        isPatExamMainSch = true;
                    } else {
                        resultDataList.add(patExamMainColumnNames);
                        isPatExamMainSch = false;
                    }
                } else {
                    isPatExamMainSch = null;
                }
            } else {
                isPatExamMainSch = null;
            }
    }
            /*
             * 取得されたrst _checklist_infoはjsonタイプであり、外部キーを置換する必要がある
             * 従って、1つずつ取り出してコレクションに入れる必要があります（重複クエリDBを回避）
             */
    private void appendPatExamMainRows(Collection<String[]> resultDataList,
                                       List<NamedCsvRecord> rowList,
                                       Map<String, Map<String, String>> examSetMap,
                                       Map<String, Map<String, String>> examItemMap,
                                       Map<String, Long> userIdMap,
                                       Map<String, String> patPersonalMainMap) {
            rowList.forEach(r -> {
            PatExamMain main = buildPatExamMainFromCsvRow(r, userIdMap, patPersonalMainMap);
            applyPatExamMainJsonInfoFields(main, r, examSetMap, examItemMap);
            resultDataList.add(convertPatExamMainToResultArray(main));
        });
    }

    /**
     * pat_exam_mainのCSV1行からPatExamMain基本フィールドを構築する
     */
    private PatExamMain buildPatExamMainFromCsvRow(NamedCsvRecord r,
                                                   Map<String, Long> userIdMap,
                                                   Map<String, String> patPersonalMainMap) {
                PatExamMain main = new PatExamMain();
                main.setFacility_cd(r.getField("facility_cd"));
                if (patPersonalMainMap.containsKey(r.getField("pat_id")) && !ObjectUtils.isEmpty(patPersonalMainMap.get(r.getField("pat_id")))) {
                    main.setPat_id(Long.valueOf(patPersonalMainMap.get(r.getField("pat_id"))));
                }
                main.setFn_pat_id(r.getField("pat_id"));
                try {
                    main.setReg_exam_date(ObjectUtils.isEmpty(r.getField("reg_exam_date")) ? null : this.checkDate(r.getField("reg_exam_date")));
                } catch (ParseException e) {
                    throw new RuntimeException(e);
                }
                main.setReg_order_class(r.getField("reg_order_class"));
                main.setExam_status(r.getField("exam_status"));
                main.setData_gen_class(r.getField("data_gen_class"));
                main.setIs_order(r.getField("is_order"));
                if (isPatExamMainSch) {
                    if (userIdMap.containsKey(r.getField("ind_user_id"))) {
                        main.setInd_user_id(userIdMap.get(r.getField("ind_user_id")));
                    }
                    if (userIdMap.containsKey(r.getField("reg_staff"))) {
                        main.setReg_staff(userIdMap.get(r.getField("reg_staff")));
                    }
                    if (userIdMap.containsKey(r.getField("up_staff"))) {
                        main.setUp_staff(userIdMap.get(r.getField("up_staff")));
                    }
                } else {
                    main.setIs_del(r.getField("is_del"));
                    try {
                        main.setResult_exam_date(ObjectUtils.isEmpty(r.getField("result_exam_date")) ? null : this.checkDate(r.getField("result_exam_date")));
                    } catch (ParseException e) {
                        throw new RuntimeException(e);
                    }
                }
                try {
                    main.setUp_date(ObjectUtils.isEmpty(r.getField("up_date")) ? null : this.checkDate(r.getField("up_date")));
                } catch (ParseException e) {
                    throw new RuntimeException(e);
                }
                try {
                    main.setReg_date(ObjectUtils.isEmpty(r.getField("reg_date")) ? null : this.checkDate(r.getField("reg_date")));
                } catch (ParseException e) {
                    throw new RuntimeException(e);
                }
        return main;
    }

    /**
     * pat_exam_mainのJSON情報列を外部キー置換する
     */
    private void applyPatExamMainJsonInfoFields(PatExamMain main,
                NamedCsvRecord r,
                                                Map<String, Map<String, String>> examSetMap,
                                                Map<String, Map<String, String>> examItemMap) {
                String orderExamSetInfoStr = r.getField("order_exam_set_info");
                if (!ObjectUtils.isEmpty(orderExamSetInfoStr) && !"null".equals(orderExamSetInfoStr)) {
                    JSONArray orderExamSetInfo = new JSONArray(orderExamSetInfoStr);
                    orderExamSetInfo.forEach(i -> {
                        JSONObject obj = parseJsonOrNull(i);
                        String setKey = String.valueOf(obj.get("set_cd"));
                        if (examSetMap.containsKey(setKey) && !CollectionUtils.isEmpty(examSetMap.get(setKey))) {
                            obj.put("set_name", examSetMap.get(setKey).get("set_name"));
                            obj.put("set_cd", Long.valueOf(examSetMap.get(setKey).get("set_cd")));
                        } else {
                            obj.put("set_name", JSONObject.NULL);
                            obj.put("set_cd", JSONObject.NULL);
                        }
                    });
                    main.setOrder_exam_set_info(orderExamSetInfo);
                } else {
                    main.setOrder_exam_set_info(null);
                }
                // exam_order_info
                String examOrderInfoStr = r.getField("exam_order_info");
                if (!ObjectUtils.isEmpty(examOrderInfoStr) && !"null".equals(examOrderInfoStr)) {
                    JSONArray examOrderInfo = new JSONArray(examOrderInfoStr);
                    examOrderInfo.forEach(i -> {
                        JSONObject obj = parseJsonOrNull(i);
                        String itemKey = String.valueOf(obj.get("item_cd"));
                        if (examItemMap.containsKey(itemKey) && !ObjectUtils.isEmpty(examItemMap.get(itemKey))) {
                            obj.put("item_cd", Long.valueOf(examItemMap.get(itemKey).get("exam_item_cd")));
                        } else {
                            obj.put("item_cd", JSONObject.NULL);
                        }
                        String setKey = String.valueOf(obj.get("set_cd"));
                        if (examSetMap.containsKey(setKey) && !CollectionUtils.isEmpty(examSetMap.get(setKey))) {
                            obj.put("set_cd", Long.valueOf(examSetMap.get(setKey).get("set_cd")));
                        } else {
                            obj.put("set_cd", JSONObject.NULL);
                        }
                    });
                    main.setExam_order_info(examOrderInfo);
                } else {
                    main.setExam_order_info(null);
                }
                // exam_result_info
                String examResultInfoStr = r.getField("exam_result_info");
                if (!ObjectUtils.isEmpty(examResultInfoStr) && !"null".equals(examResultInfoStr)) {
                    JSONArray examResultInfo = new JSONArray(examResultInfoStr);
                    examResultInfo.forEach(i -> {
                        JSONObject obj = parseJsonOrNull(i);
                        String examItemCd = String.valueOf(obj.get("item_cd"));
                        if (examItemMap.containsKey(examItemCd) && !CollectionUtils.isEmpty(examItemMap.get(examItemCd))) {
                            obj.put("item_cd", ObjectUtils.isEmpty(examItemMap.get(examItemCd).get("exam_item_cd")) ? null : Long.valueOf(examItemMap.get(examItemCd).get("exam_item_cd")));
                            obj.put("exam_class", examItemMap.get(examItemCd).get("exam_class"));
                        } else {
                            obj.put("item_cd", JSONObject.NULL);
                            obj.put("exam_class", JSONObject.NULL);
                        }
                    });
                    main.setExam_result_info(examResultInfo);
                } else {
                    main.setExam_result_info(null);
                }

                // order_label_info
                String orderLabelInfoStr = r.getField("order_label_info");
                if (!ObjectUtils.isEmpty(orderLabelInfoStr) && !"null".equals(orderLabelInfoStr)) {
                    JSONArray orderLabelInfo = new JSONArray(orderLabelInfoStr);
                    main.setOrder_label_info(orderLabelInfo);
                } else {
                    main.setOrder_label_info(null);
                }
    }

    /**
     * PatExamMainを文字列配列に変換する
     */
    private String[] convertPatExamMainToResultArray(PatExamMain main) {
                String[] mainArray;
                if (isPatExamMainSch) {
                    mainArray = main.schToString().split(",");
                } else {
                    mainArray = main.toString().split(",");
                }
                if (mainArray.length > 0) {
                    int jsonInfo1 = mainArray.length - 1;
                    int jsonInfo2 = mainArray.length - 2;
                    //データグループの最後の2つの要素、つまり最後の2つのjsonを取ります
                    if (isPatExamMainSch && mainArray[jsonInfo2].contains("|")) {
                        mainArray[jsonInfo2] = mainArray[jsonInfo2].replace("|", ",");
                    }
                    if (mainArray[jsonInfo1].contains("|")) {
                        mainArray[jsonInfo1] = mainArray[jsonInfo1].replace("|", ",");
                    }
                    if ("null".equals(mainArray[jsonInfo1])) {
                        mainArray[jsonInfo1] = null;
                    }
                    if (isPatExamMainSch && "null".equals(mainArray[jsonInfo2])) {
                        mainArray[jsonInfo2] = null;
                    }
                }
                //各行置換後の最終結果データセットの書き込み
        return mainArray;
    }

    /**
     * pat_exam_main処理の例外をログ出力する
     */
    private void handleProcessPatExamMainException(Exception ex, String csvfileName) throws IOException {
            System.err.println("実行" + csvfileName + "ファイル中にエラーが発生しました！\n");
            //出力詳細エラー情報
            //ログ
            EventLogMessage eventLogMessage = eventLoggerUtil.getEventLogMessage("CSVファイルの処理に失敗しました：" + csvfileName,
                    facilityCd, "BatchCsvWriterDb.write()");
            eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.ERROR);
            //ログ
            EventLogMessage eventLogMessagex = eventLoggerUtil.getEventLogMessage("詳細なエラー情報：" + ex.toString(),
                    facilityCd, "BatchCsvWriterDb.write()");
            eventLoggerUtil.recordLog(facilityCd, eventLogMessagex, LogLevel.ERROR);

            eventLoggerUtil.recordLog(
                    facilityCd,
                    eventLoggerUtil.getEventLogMessage(
                            "processPatExamMain(Collection<String[]> resultDataList, List<NamedCsvRecord> rowList)："  + EventLoggerUtil.excetionStackTraceToString(ex),
                            facilityCd,
                            ex.getClass().getName() + ".processPatExamMain()"),
                    LogLevel.ERROR);
            this.errorfile(csvfileName);
    }

    private void mstToCacheMapForPatExamMain(List<NamedCsvRecord> rowList,
                                             Map<String, Map<String, String>> examSetMap,
                                             Map<String, Map<String, String>> examItemMap,
                                             Map<String, Long> userIdMap,
                                             Map<String, String> patPersonalMainMap) {
        //setデデューティ機能を利用する
        Set<String> setStaffCd = new HashSet<>();
        Set<String> setPatPersonalMain = new HashSet<>();
        Set<String> setExamSet = new HashSet<>();
        Set<String> setExamItem = new HashSet<>();
        rowList.forEach(r -> {
            if (isPatExamMainSch) {
                List<String> setName = getValueFromJsonArrayByKey(r.getField("order_exam_set_info"), "set_name");
                if (!CollectionUtils.isEmpty(setName)) {
                    setExamSet.addAll(setName);
                }
                List<String> setCd = getValueFromJsonArrayByKey(r.getField("exam_order_info"), "set_cd");
                if (!CollectionUtils.isEmpty(setCd)) {
                    setExamSet.addAll(setCd);
                }
                List<String> itemCd = getValueFromJsonArrayByKey(r.getField("exam_order_info"), "item_cd");
                if (!CollectionUtils.isEmpty(itemCd)) {
                    setExamItem.addAll(itemCd);
                }
                setStaffCd.add(r.getField("ind_user_id"));
                setStaffCd.add(r.getField("reg_staff"));
                setStaffCd.add(r.getField("up_staff"));
            } else {
                List<String> itemCd = getValueFromJsonArrayByKey(r.getField("exam_result_info"), "item_cd");
                if (!CollectionUtils.isEmpty(itemCd)) {
                    setExamItem.addAll(itemCd);
                }
            }
            setPatPersonalMain.add(r.getField("pat_id"));
        });

        String DELIMITER_SEMICOLON = ";";

        /*
         * order_exam_set_info
         */
        Iterator<String> examSetIterator = setExamSet.iterator();
        List<Object> examSetParams = new ArrayList<>();
        StringBuilder examSetSql = new StringBuilder(EMPTY);
        while (examSetIterator.hasNext()) {
            String text = examSetIterator.next();
            examSetSql.append("SELECT exam_set_cd, exam_set_name, fn_exam_set_cd FROM mst_exam_set WHERE facility_cd = ? AND fn_exam_set_cd :: CHARACTER VARYING = ?");
            if (examSetIterator.hasNext()) {
                examSetSql.append(" UNION ALL \n");
            } else {
                examSetSql.append(DELIMITER_SEMICOLON);
            }
            examSetParams.add(facilityCd);
            examSetParams.add(text);
        }


        if (!ObjectUtils.isEmpty(examSetSql.toString())) {
            List<MstExamSet> entityList = namedParameterJdbcTemplateConvert.getJdbcOperations().query(examSetSql.toString()
                    , examSetParams.toArray(), new BeanPropertyRowMapper<>(MstExamSet.class));
            entityList.forEach(e -> examSetMap.put(e.getFn_exam_set_cd(),
                    Map.of("set_cd", String.valueOf(e.getExam_set_cd()),
                            "set_name", String.valueOf(e.getExam_set_name()))));
        }

        /*
         * exam_order_info
         */
        Iterator<String> examItemIterator = setExamItem.iterator();
        List<Object> examItemParams = new ArrayList<>();
        StringBuilder examItemSql = new StringBuilder(EMPTY);
        while (examItemIterator.hasNext()) {
            String text = examItemIterator.next();
            examItemSql.append("SELECT exam_item_cd, exam_class, fn_exam_item_cd FROM mst_exam_item WHERE facility_cd = ? AND fn_exam_item_cd :: CHARACTER VARYING = ?");
            if (examItemIterator.hasNext()) {
                examItemSql.append(" UNION ALL \n");
            } else {
                examItemSql.append(DELIMITER_SEMICOLON);
            }
            examItemParams.add(facilityCd);
            examItemParams.add(text);
        }


        if (!ObjectUtils.isEmpty(examItemSql.toString())) {
            List<MstExamItem> entityList = namedParameterJdbcTemplateConvert.getJdbcOperations().query(examItemSql.toString()
                    , examItemParams.toArray(), new BeanPropertyRowMapper<>(MstExamItem.class));
            entityList.forEach(e -> examItemMap.put(e.getFn_exam_item_cd(),
                    Map.of("exam_item_cd", String.valueOf(e.getExam_item_cd()),
                            "exam_class", e.getExam_class())));
        }

        /*
         * ind_user_id, reg_staff, up_staff
         */
        StringBuilder userIdSql = new StringBuilder(EMPTY);
        Iterator<String> userIdIterator = setStaffCd.iterator();
        List<Object> userIdParams = new ArrayList<>();
        while (userIdIterator.hasNext()) {
            String text = userIdIterator.next();
            userIdSql.append("SELECT user_id, fn_staff_cd FROM mst_personal_user WHERE facility_cd = ? AND fn_staff_cd :: CHARACTER VARYING = ?");
            if (userIdIterator.hasNext()) {
                userIdSql.append(" UNION ALL \n");
            } else {
                userIdSql.append(DELIMITER_SEMICOLON);
            }
            userIdParams.add(facilityCd);
            userIdParams.add(text);
        }


        if (!ObjectUtils.isEmpty(userIdSql.toString())) {
            List<MstPersonalUser> userIdList = namedParameterJdbcTemplateConvert.getJdbcOperations().query(userIdSql.toString()
                    , userIdParams.toArray(), new BeanPropertyRowMapper<>(MstPersonalUser.class));
            userIdList.forEach(user -> userIdMap.put(user.getFnStaffCd(),user.getUserId()));
        }

        /*
         * pat_id
         */
        Iterator<String> patPersonalMainIterator = setPatPersonalMain.iterator();
        List<Object> patPersonalMainParams = new ArrayList<>();
        StringBuilder patPersonalMainSql = new StringBuilder(EMPTY);
        while (patPersonalMainIterator.hasNext()) {
            String text = patPersonalMainIterator.next();
            patPersonalMainSql.append("SELECT pat_id, fn_pat_id FROM pat_personal_main WHERE facility_cd = ? AND fn_pat_id :: CHARACTER VARYING = ?");
            if (patPersonalMainIterator.hasNext()) {
                patPersonalMainSql.append(" UNION ALL \n");
            } else {
                patPersonalMainSql.append(DELIMITER_SEMICOLON);
            }
            patPersonalMainParams.add(facilityCd);
            patPersonalMainParams.add(text);
        }


        if (!ObjectUtils.isEmpty(patPersonalMainSql.toString())) {
            List<PatPersonalMain> entityList = namedParameterJdbcTemplateConvert.getJdbcOperations().query(patPersonalMainSql.toString()
                    , patPersonalMainParams.toArray(), new BeanPropertyRowMapper<>(PatPersonalMain.class));
            entityList.forEach(e -> patPersonalMainMap.put(e.getFn_pat_id(),
                    e.getPat_id() == null ? null : String.valueOf(e.getPat_id())));
        }
    }


    /**
     * Writerによって実行される処理
     */
    @Override
    public void write(final Chunk<? extends T> chunk) throws Exception {
        List<? extends T> items = chunk.getItems();
        //グローバル変数を空にする
        globalContext.befKeyList = "";
        //最終結果データセット
        Collection<String[]> resultDataList = new ArrayList<String[]>(Collections.EMPTY_LIST);
        if (!globalContext.fileName.contains(".csv") || items.isEmpty()) {
            return;
        }
        String convertJdbcUrl = environment.getProperty("datasource." + ApplicationConst.DbType.CONVERT + ".jdbc-url");
        String convertUserName = environment.getProperty("datasource." + ApplicationConst.DbType.CONVERT + ".username");
        String to_Db_table_prefix = environment.getProperty("datasource." + ApplicationConst.DbType.CONVERT + ".table_prefix");
        // 登録先DB接続情報を取得
        String fromHostIp = convertJdbcUrl.split("/")[2].split(":")[0];
        String fromDbUser = convertUserName;
        String fromDbName = convertJdbcUrl.split("/")[3];

            String csvfileName = globalContext.fileName;
        List<NamedCsvRecord> rowList = readCsvRowsForWrite(csvfileName);
        String tableName = dispatchCsvTableProcessing(resultDataList, rowList);
        if (tableName == null) {
            return;
        }
        if (!globalContext.fileName.contains("pat_unique_history")) {
            rewriteCsvAndExecuteCopy(resultDataList, tableName, csvfileName, fromHostIp, fromDbUser, fromDbName, to_Db_table_prefix);
        }
    }

    /**
     * write用にCSV行リストを読み込む
     */
    private List<NamedCsvRecord> readCsvRowsForWrite(String csvfileName) throws IOException {
            File file = new File(csvfileName);
            //csvファイルを読み込む
            List<NamedCsvRecord> rowList;
            try (CsvReader<NamedCsvRecord> csvReader = CsvReader.builder().ofNamedCsvRecord(file.toPath(), StandardCharsets.UTF_8)) {
                //csvのすべての行を取得
                rowList = csvReader.stream().collect(Collectors.toList());
            }
            // #9132 Add by 肖　Start　
            String mstMachineSql = "SELECT machine_type_cd, machine_serial, com_format_cd, fn_device_no, fn_class_cd FROM mst_machine WHERE facility_cd = ?";
            if(globalContext.MstMachineList.isEmpty()){
                globalContext.MstMachineList = namedParameterJdbcTemplateConvert.getJdbcOperations().query(mstMachineSql, new Object[]{facilityCd}, new BeanPropertyRowMapper<>(MstMachine.class));
            }
            // #9132 Add by 肖　End　
            //csvのすべての行を取得
        return rowList;
    }
    /**
     * ファイル名に応じてテーブル別処理を振り分ける（nullは早期return）
     */
    private String dispatchCsvTableProcessing(Collection<String[]> resultDataList, List<NamedCsvRecord> rowList) throws Exception {
            if (globalContext.fileName.contains("mnt_motion_record")) {
                globalContext.seqKey = "motion_record_no";
                processMntMotionRecord(resultDataList, rowList);
            return "mnt_motion_record";
        }
        if (globalContext.fileName.contains("mst_favorite_facility")) {
                globalContext.seqKey = "master_cd";
                processMstFavoriteFacility(resultDataList, rowList);
                if (resultDataList.size() <= 1) {
                return null;
                }
            return "mst_favorite_facility";
        }
        if (globalContext.fileName.contains("mni_monitor")) {
                globalContext.seqKey = "bio_moni_ctl_no";
                processMniMonitor(resultDataList, rowList);
            return "mni_monitor";
        }
        if (globalContext.fileName.contains("ord_checklist")) {
                globalContext.seqKey = "checklist_ctl_no";
            processOrdChecklist(resultDataList,rowList);
            return "ord_checklist";
        }
        if (globalContext.fileName.contains("ord_treat_condition")) {
            globalContext.seqKey = "condition_cd";
            processOrdTreatCondition(resultDataList,rowList);
            return "ord_treat_condition";
        }
        if (globalContext.fileName.contains("ord_coop_no")) {
            globalContext.seqKey = "ctl_no";
            processOrdCoopNo(resultDataList, rowList);
            return "ord_coop_no";
        }
        if (globalContext.fileName.contains("pat_unique_history")) {
            processPatUniqueHistory(rowList);
            return "pat_unique_history";
        }
        if (globalContext.fileName.contains("pat_exam_main")) {
            globalContext.seqKey = "exam_main_cd";
            processPatExamMain(resultDataList,rowList);
            return "pat_exam_main";
        }
        return "";
    }

    /**
     * CSVを書き戻しpsql copyを実行する
     */
    private void rewriteCsvAndExecuteCopy(Collection<String[]> resultDataList, String tableName, String csvfileName,
                                          String fromHostIp, String fromDbUser, String fromDbName, String to_Db_table_prefix) throws Exception {
                try {
                    WriteSQLAnnotation wqa = new WriteSQLAnnotation();
                    wqa.fileNioWrite(csvfileName, "", false); //ファイルの内容をクリア
                    //csvでクリアされたファイルを書き込みます
                    File fileNew = new File(csvfileName);
                    writeCsv(fileNew.toPath(), resultDataList);
            String registColumnNames = resolveWriteRegistColumnNames(tableName);
                    //csvインポートコマンドのスプライス（スーパー管理者専用、パフォーマンスが優れている）
                    String copyCommand = "psql"
                            + " -h "
                            + fromHostIp // 登録先DBホストIPアドレス
                            + " -U "
                            + fromDbUser // 登録先DBユーザー名
                            + " -d "
                            + fromDbName // 登録先DB名
                            + " -c \"\\copy " + to_Db_table_prefix
                            + tableName //テーブル名
                            + "("
                            + registColumnNames //カラム名（カンマ区きり）
                            + ") FROM " + csvfileName + " WITH CSV HEADER\"";
                    System.err.println(tableName + " CSV COPY：" + copyCommand);
                    // Windows、その他で実行方法を変更する
                    String[] command = new String[3];
                    if ("\\".equals(System.getProperty("file.separator"))) {
                        command[0] = "cmd.exe";
                        command[1] = "/c";
                    } else {
                        command[0] = "sh";
                        command[1] = "-c";
                    }
                    command[2] = copyCommand;
                    boolean c = this.processCmdSql(command, true);
                    if (!c) {
                        //CMD実行失敗（データのインポートなし）
                        //ログ テーブ
                        EventLogMessage eventLogMessageTable = eventLoggerUtil.getEventLogMessage(fileNew + "CSV ERROR！",
                                facilityCd, "JdbcBatchSqlItemWriter.write(final List<? extends T> items)");
                        eventLoggerUtil.recordLog(facilityCd, eventLogMessageTable, LogLevel.ERROR);
                    }

                    // add #9132 コンバート処理中にDBが高負荷となり停止 zkm start
                    //mod  11162  zc start
                    if (tableName.equals("mnt_motion_record") && globalContext.isThread) {
                        Thread.sleep(motionSleepMillis);
                    }
                    //mod  11162  zc end

                    // add #9132 コンバート処理中にDBが高負荷となり停止 zkm end

                    //CSVファイルの削除
                } catch (Exception exception) {
                    System.err.println(exception.toString());
                    this.errorfile(csvfileName);
                }
            }

    /**
     * write時の登録列名をテーブル別に解決する
     */
    private String resolveWriteRegistColumnNames(String tableName) throws Exception {
        InfomationSchemaControl isc = new InfomationSchemaControl(appContext);
        List<String> columnNameList = isc.getColumnNamesForCodeConversion(tableName);
        String registColumnNames = String.join(",", columnNameList);
        if ("mni_monitor".equals(tableName)) {
            registColumnNames = registColumnNames.substring(registColumnNames.indexOf(",") + 1, registColumnNames.lastIndexOf(","));
        } else if ("mnt_motion_record".equals(tableName)) {
            registColumnNames = String.join(",", columnNameList);
        } else if ("ord_checklist".equals(tableName)) {
            registColumnNames = String.join(",", ordCheckListColumnNames);
        } else if ("ord_treat_condition".equals(tableName)) {
            registColumnNames = String.join(",", ordTreatConditionListColumnNames);
        } else if ("ord_coop_no".equals(tableName)) {
            registColumnNames = String.join(",", ordCoopNoListColumnNames);
        } else if ("pat_exam_main".equals(tableName)) {
            registColumnNames = String.join(",", isPatExamMainSch ? patExamMainSchColumnNames : patExamMainColumnNames);
        }else if ("mst_favorite_facility".equals(tableName)) {
            registColumnNames = String.join(",", mstFavoriteFacilityColumnNames);
        }
        return registColumnNames;
    }

    /**
     * 文字列からnullドメインを除去するには
     * @param string
     * @return str 文字列
     * @throws UnsupportedEncodingException
     */
    private String trimNull(String string) throws UnsupportedEncodingException
    {
        ArrayList<Byte> list = new ArrayList<Byte>();
        byte[] bytes = string.getBytes(StandardCharsets.UTF_8);
        for (int i = 0; bytes != null && i < bytes.length; i++) {
            if (0 != bytes[i]) {
                list.add(bytes[i]);
            }
        }
        byte[] newBytes = new byte[list.size()];
        for (int i = 0; i < list.size(); i++) {
            newBytes[i] = (Byte) list.get(i);
        }
        String str = new String(newBytes, StandardCharsets.UTF_8);
        return str;
    }

    private Integer parseIntOrNull(String value) {
        return ObjectUtils.isEmpty(value) ? null : Integer.parseInt(value);
    }

    private Long parseLongOrNull(String value) {
        return ObjectUtils.isEmpty(value) ? null : Long.parseLong(value);
    }

    private Short parseShortOrNull(String value) {
        return ObjectUtils.isEmpty(value) ? null : Short.parseShort(value);
    }
    private JSONObject parseJsonOrNull(Object value) {
        return value instanceof JSONObject ? (JSONObject) value : new JSONObject(value);
    }

    private String valueOrNull(String value) {
        return ObjectUtils.isEmpty(value) ? null : value;
    }

    private String stringValueOfOrNull(Object value) {
        return ObjectUtils.isEmpty(value) ? null : String.valueOf(value);
    }

    private void writeCsv(Path path, Collection<String[]> rows) throws IOException {
        try (CsvWriter csvWriter = CsvWriter.builder().build(path, StandardCharsets.UTF_8)) {
            for (String[] row : rows) {
                csvWriter.writeRecord(row);
            }
        }
    }
}