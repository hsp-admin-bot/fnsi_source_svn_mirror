package utils;

import batch.ApplicationConst;
import batch.part.ProgressManagement;
import com.zaxxer.hikari.HikariDataSource;
import org.springframework.batch.core.job.Job;
import org.springframework.batch.core.job.parameters.JobParameters;
import org.springframework.batch.core.job.parameters.JobParametersBuilder;
import org.springframework.batch.core.launch.JobLauncher;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.ApplicationContext;
import org.springframework.core.env.Environment;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;
import web.config.EventLoggerUtil;
import web.logger.EventLogMessage;
import web.logger.LogLevel;

import javax.sql.DataSource;
import java.io.*;
import java.nio.charset.StandardCharsets;
import java.nio.file.DirectoryStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.*;

@Component
public class Utils {

    @Autowired
    private EventLoggerUtil eventLoggerUtil;

    @Autowired
    private ApplicationContext appContext;
    // add #7405 ReMS利用施設をコンバートするとモニターデータが追加となる 歴程 start
    @Autowired
    private Environment environment;
    // add #7405 ReMS利用施設をコンバートするとモニターデータが追加となる 歴程 end
    @Value("${csv_path}")
    public String outPutPath;

    /**
     * コンバートジョブ
     */
    @Autowired
    @Qualifier("ConvertJob")
    Job convertJob;

    public boolean deleteJobRunStatus = false;

    public String deleteJobFacilityCd;

    public String ipAddress;

    public List<String> byFacilityCdList = new ArrayList<String>(
            Arrays.asList(
                    "mst_device_set_info_default",
                    "mst_checklist",
                    "mst_weight_scale",
                    "mst_weight",
                    "mst_comsv_setting"
            )
    );
    // add zl start
    public List<String> allDeleteAllInsertList = new ArrayList<String>(
            Arrays.asList(
                    "pat_event",
                    "pat_ind_approve_history"
            )
    );

    // add #9448 mst_mainte_category.detail再設定 zkm start
    public List<String> mainteHistCopySourceList = new ArrayList<>(
            Arrays.asList(
                    "mst_mainte_detail",
                    "mst_mainte_category",
                    "mst_mainte_layout",
                    "mst_mainte_layout_group"
            )
    );
    // add #9448 mst_mainte_category.detail再設定 zkm end

    public List<String> onlyInsertList = new ArrayList<String>(
            Arrays.asList(
                    "mnt_motion_record",
                    "ord_treat_condition",
                    "ord_weight_scale",
                    "mst_favorite_facility",
                    "ord_coop_no"
            )
    );
    // add zl end

    //add  9688 差分を実行する場合、本番DBデータがコンバートDBにコピーしない  start
    public List<String> DiffNotCopyDbToConvert = new ArrayList<String>(
            Arrays.asList(
                    "mst_user",
                    "mst_user_authentication",
                    "pat_group_detail",
                    "medicine_latest_no",
                    "pat_personal_main_history",
                    "pat_insurance_history",
                    "pat_main_history",
                    "pat_unique_history",
                    "pat_group_detail_history",
                    "mst_graph_setting",
                    "pat_treatment_pattern"

            )
    );
    //add #12229  CONVERT　初回,差分データを保持しない
    public List<String> ConvertNotData = new ArrayList<String>(
            Arrays.asList(
                    "mnt_motion_record",
                    "mni_monitor",
                    "ord_checklist",
                    "ord_treat_condition",
                    "ord_weight_scale",
                    "mst_favorite_facility",
                    "ord_coop_no"
            )
    );

   //add 12193
    public final List<String>  deleteProductionDbTable = new ArrayList<String>(
            Arrays.asList(
                    "mst_mainte_layout_hst",
                    "mst_mainte_detail_hst",
                    "mst_mainte_category_hst",
                    "mst_mainte_layout_group_hst",
                    "mnt_weight_state",
                    "ord_main_restore",
                    "sys_coop_journal"

            )
    );
    //add 12193

    //add 12173 「先行文字」 start
    public final List<String>  peliminaryDocumentList = new ArrayList<String>(
            Arrays.asList(
                    "一般財団法人",
                    "公益財団法人",
                    "公立学校共済組合",
                    "医療型障害児入所施設",
                    "医療法人",
                    "医療生協",
                    "医療生活協同組合",
                    "医療福祉センター",
                    "医療福祉生活協同組合",
                    "地方独立行政法人",
                    "地方職員共済組合",
                    "特別養護老人ホーム",
                    "特定医療法人",
                    "独立行政法人",
                    "社会保険",
                    "社会医療法人",
                    "社会福祉法人",
                    "社団医療法人",
                    "社団法人"
            )
    );
    //add 12173 「先行文字」 start

    /**
     *
     * @param ds
     * @param tableName
     * @param facility_cd
     * @return
     */
    private Integer getCountsByTableName(DataSource ds, String tableName, String facility_cd) {
        Integer count = 0;
        String sql = null;
        List<Integer> list = null;
        JdbcTemplate jdbcTemplate = new JdbcTemplate(ds);
        try {
            if ("all".equals(facility_cd)) {
                sql = "select count(*) from " + tableName;
                list = jdbcTemplate.queryForList(sql, Integer.class);
            } else {
                sql = "select count(*) from " + tableName + " where facility_cd = ?";
                list = jdbcTemplate.queryForList(sql, Integer.class, facility_cd);
            }
        } catch(Exception e) {
            sql = "select count(*) from " + tableName;
            list = jdbcTemplate.queryForList(sql, Integer.class);
        }
        if (null != list && !list.isEmpty()) {
            count = list.get(0);
        }
        return count;
    }

    /**
     *
     * @param ds
     * @param facility_cd
     * @return
     */
    private List<TableDTO> getCsvData(DataSource ds, String facility_cd) {
        String sql = null;
        JdbcTemplate jdbcTemplate = new JdbcTemplate(ds);
        List<TableDTO> eachTableCounts = new ArrayList<TableDTO>();
        try {
            sql = "select relname as tabname,cast(obj_description(relfilenode,'pg_class') as varchar) as comment from pg_class c \n" +
                    "where  relkind = 'r' and relname not like 'pg_%' and relname not like 'sql_%' order by relname";
            List tabNameslist = jdbcTemplate.queryForList(sql);
            if (null != tabNameslist) {
                System.out.println("テーブル数：" + tabNameslist.size());
                Iterator ite = tabNameslist.iterator();
                while (ite.hasNext()){
                    Map map = (Map)ite.next();
                    String tabname = (String)map.get("tabname");
                    if (tabname.startsWith("batch")) {
                        continue;
                    }
                    String comment = "";
                    if (null != map.get("comment")) {
                        comment = (String)map.get("comment");
                    }
                    Integer count = getCountsByTableName(ds, tabname, facility_cd);
                    TableDTO tableDTO = new TableDTO();
                    tableDTO.setTabName(tabname);
                    tableDTO.setComment(comment);
                    tableDTO.setCount(count);
                    eachTableCounts.add(tableDTO);
                    Collections.sort(eachTableCounts, Collections.reverseOrder());
                }
            }
        } catch (Exception e) {
            eventLoggerUtil.recordLog(
                    facility_cd,
                eventLoggerUtil.getEventLogMessage(
                        "getCsvData(DataSource ds, String facility_cd)："  + EventLoggerUtil.excetionStackTraceToString(e),
                        facility_cd,
                        e.getClass().getName() + ".getCsvData()"),
                LogLevel.ERROR);
        }
        return eachTableCounts;
    }

    /**
     *
     * @param facility_cd
     */
    public void writeJson(String facility_cd) {
        try {
            HikariDataSource convertDS = (HikariDataSource) appContext.getBean(ApplicationConst.DbType.CONVERT);
            System.out.println("------------- CONVERT COUNT START --------------");
            List<TableDTO> exportData = getCsvData(convertDS, facility_cd);
            createCSVFile(exportData, ApplicationConst.DbType.CONVERT, facility_cd);

            exportData = null;
            HikariDataSource nkk4DS = (HikariDataSource) appContext.getBean(ApplicationConst.DbType.NKK4);
            System.out.println("------------- NKK4 COUNT START --------------");
            exportData = getCsvData(nkk4DS, facility_cd);
            createCSVFile(exportData, ApplicationConst.DbType.NKK4, facility_cd);

            exportData = null;
            HikariDataSource nkk5DS = (HikariDataSource) appContext.getBean(ApplicationConst.DbType.NKK5);
            System.out.println("------------- NKK5 COUNT START --------------");
            exportData = getCsvData(nkk5DS, facility_cd);
            createCSVFile(exportData, ApplicationConst.DbType.NKK5, facility_cd);

            exportData = null;
            HikariDataSource nkk6DS = (HikariDataSource) appContext.getBean(ApplicationConst.DbType.NKK6);
            System.out.println("------------- NKK6 COUNT START --------------");
            exportData = getCsvData(nkk6DS, facility_cd);
            createCSVFile(exportData, ApplicationConst.DbType.NKK6, facility_cd);
            System.out.println("------------- success over --------------");

        } catch (Exception e) {
            eventLoggerUtil.recordLog(
                facility_cd,
                eventLoggerUtil.getEventLogMessage(
                        "writeJson(String facility_cd)："  + EventLoggerUtil.excetionStackTraceToString(e),
                        facility_cd,
                        e.getClass().getName() + ".writeJson(String facility_cd)"),
                LogLevel.ERROR);
        }
    }

    /**
     *
     * @param exportData
     * @param DbType
     */
    private void createCSVFile(List<TableDTO> exportData, String DbType,String facility_cd) {

        File csvFile = null;
        String fileName = DbType + "_" + new Date().getTime();
        System.out.println("fileName = " + fileName);
        BufferedWriter csvFileOutputStream = null;
        try {
            File file = new File(outPutPath);
            if (!file.exists()) {
                if (file.mkdirs()) {
                    System.out.println("ファイルを作成成功");
                } else {
                    System.out.println("ファイルを作成失敗");
                }
            }
            //定义文件名格式并创建
            String url = outPutPath + "\\" + fileName + ".csv";
            csvFile = new File(url);
            csvFileOutputStream = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(csvFile), "Shift-JIS"), 1024);
            for (TableDTO tableDTO : exportData) {
                csvFileOutputStream.write(tableDTO.toString());
                csvFileOutputStream.newLine();
            }
        } catch (Exception e) {
            eventLoggerUtil.recordLog(
                facility_cd,
                eventLoggerUtil.getEventLogMessage(
                        "createCSVFile(List<TableDTO> exportData, String DbType)："  + EventLoggerUtil.excetionStackTraceToString(e),
                        facility_cd,
                        e.getClass().getName() + ".createCSVFile(List<TableDTO> exportData, String DbType)"),
                LogLevel.ERROR);
        } finally {
            try {
                if (csvFileOutputStream != null) {
                    csvFileOutputStream.close();
                }
            } catch (IOException e) {
                eventLoggerUtil.recordLog(
                    facility_cd,
                    eventLoggerUtil.getEventLogMessage(
                            "createCSVFile(List<TableDTO> exportData, String DbType)："  + EventLoggerUtil.excetionStackTraceToString(e),
                            facility_cd,
                            e.getClass().getName() + ".createCSVFile(List<TableDTO> exportData, String DbType)"),
                    LogLevel.ERROR);
            }
        }
    }

    private void createFieldCSVFile(List<String> exportData, String DbType,String facility_cd) {

        File csvFile = null;
        String fileName = DbType + "_" + new Date().getTime();
        BufferedWriter csvFileOutputStream = null;
        try {
            File file = new File(outPutPath);
            if (!file.exists()) {
                if (file.mkdirs()) {
                    System.out.println("ファイルを作成成功");
                } else {
                    System.out.println("ファイルを作成失敗");
                }
            }
            //定义文件名格式并创建
            csvFile = new File(outPutPath + "\\" + fileName + ".csv");
            csvFileOutputStream = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(csvFile), "Shift-JIS"), 1024);
            for (String s : exportData) {
                csvFileOutputStream.write(s.toString());
                csvFileOutputStream.newLine();
            }
        } catch (Exception e) {
            eventLoggerUtil.recordLog(
                facility_cd,
                eventLoggerUtil.getEventLogMessage(
                        "createFieldCSVFile(List<String> exportData, String DbType)："  + EventLoggerUtil.excetionStackTraceToString(e),
                        facility_cd,
                        e.getClass().getName() + ".createFieldCSVFile(List<String> exportData, String DbType)"),
                LogLevel.ERROR);
        } finally {
            try {
                if (csvFileOutputStream != null) {
                    csvFileOutputStream.close();
                }
            } catch (IOException e) {
                eventLoggerUtil.recordLog(
                        facility_cd,
                    eventLoggerUtil.getEventLogMessage(
                            "createFieldCSVFile(List<String> exportData, String DbType)："  + EventLoggerUtil.excetionStackTraceToString(e),
                            facility_cd,
                            e.getClass().getName() + ".createFieldCSVFile(List<String> exportData, String DbType)"),
                    LogLevel.ERROR);
            }
        }
    }

    private List<String> getFieldData(DataSource ds,String facility_cd) {

        JdbcTemplate jdbcTemplate = new JdbcTemplate(ds);
        List<String> list = new ArrayList<String>();
        try {
            String sql = "select relname as tabname,cast(obj_description(relfilenode,'pg_class') as varchar) as comment from pg_class c \n" +
                    "where  relkind = 'r' and relname not like 'pg_%' and relname not like 'sql_%' order by relname";
            List tabNameslist = jdbcTemplate.queryForList(sql);
            if (null != tabNameslist) {
                System.out.println("テーブル数：" + tabNameslist.size());
                Iterator ite = tabNameslist.iterator();
                while (ite.hasNext()) {
                    Map map = (Map) ite.next();
                    String tabname = (String) map.get("tabname");
                    if (tabname.startsWith("batch")) {
                        continue;
                    }

                    // SQLインジェクション対策：テーブル名が安全な文字のみを含むことを検証（英数字とアンダースコア）
                    if (!tabname.matches("^[a-zA-Z0-9_]+$")) {
                        System.err.println("警告：跳过不安全的表名: " + tabname);
                        continue;
                    }

                    sql = "SELECT (SELECT description FROM pg_catalog.pg_description WHERE objoid = A.attrelid AND" +
                            " objsubid = A.attnum) AS comment, A.attname FROM pg_catalog.pg_attribute A WHERE 1 = 1 AND " +
                            "A.attrelid = (SELECT max(oid) FROM pg_class WHERE relname = ?) AND A.attnum > 0 AND " +
                            "NOT A.attisdropped AND A.atttypid = 3802 ORDER BY A.attnum";
                    List fieldsList = jdbcTemplate.queryForList(sql, tabname);
                    if (!fieldsList.isEmpty()) {
                        list.add("---------" + tabname + "---------");
                        Iterator it = fieldsList.iterator();
                        while (it.hasNext()) {

                            Map field = (Map) it.next();
                            String fieldName = (String) field.get("attname");

                            // SQLインジェクション対策：フィールド名が安全な文字のみを含むことを検証（英数字とアンダースコア）
                            if (!fieldName.matches("^[a-zA-Z0-9_]+$")) {
                                System.err.println("警告: 安全でないフィールド名をスキップしてください:" + fieldName);
                                continue;
                            }

                            // 注意：テーブル名とフィールド名は?プレースホルダーでパラメータ化できないが、正規表現で検証済み
                            sql = "select " + fieldName + " from " + tabname;
                            String jsonData = null;
                            List contexts = jdbcTemplate.queryForList(sql);
                            if (!contexts.isEmpty()) {
                                Iterator iterator = contexts.iterator();
                                while (iterator.hasNext()) {
                                    Map m = (Map) iterator.next();
                                    if (null == m.get(fieldName)) {
                                        continue;
                                    }
                                    jsonData = m.get(fieldName).toString();
                                    if (jsonData.length() < 4) {
                                        jsonData = null;
                                        continue;
                                    } else {
                                        break;
                                    }
                                }
                            }
                            if (null != jsonData) {
                                Set<String> set = formatJson(jsonData.toString());
                                for (String tmp : set) {
                                    String csvData = (String) field.get("comment") + "," + fieldName;
                                    csvData = csvData + "," + tmp;
                                    list.add(csvData);
                                }

                            }
                        }
                    }
                }
            }
        } catch (Exception e) {
            eventLoggerUtil.recordLog(
                facility_cd,
                eventLoggerUtil.getEventLogMessage(
                        "getFieldData(DataSource ds)："  + EventLoggerUtil.excetionStackTraceToString(e),
                        facility_cd,
                        e.getClass().getName() + ".getFieldData(DataSource ds)"),
                LogLevel.ERROR);
        }
        return list;
    }

    public Set<String> formatJson(String jsonData) {
        Set<String> set = new HashSet<String>();
        String s = jsonData.replace("{", "").replace("}", "");
        String[] arr = s.split(",");
        for(String i : arr) {
            if (null == i || i.isEmpty()) {
                continue;
            }
            set.add(i.split(":")[0].replace("\"", "").replace("{", "").trim());
        }
        return set;
    }

    public void writeJsonField(String facility_cd) {

        try {
            HikariDataSource convertDS = (HikariDataSource) appContext.getBean(ApplicationConst.DbType.CONVERT);
            System.out.println("------------- CONVERT COUNT START --------------");
            List<String> exportData = getFieldData(convertDS, facility_cd);
            createFieldCSVFile(exportData, ApplicationConst.DbType.CONVERT, facility_cd);

            exportData = null;
            HikariDataSource nkk4DS = (HikariDataSource) appContext.getBean(ApplicationConst.DbType.NKK4);
            System.out.println("------------- NKK4 COUNT START --------------");
            exportData = getFieldData(nkk4DS, facility_cd);
            createFieldCSVFile(exportData, ApplicationConst.DbType.NKK4, facility_cd);

            exportData = null;
            HikariDataSource nkk5DS = (HikariDataSource) appContext.getBean(ApplicationConst.DbType.NKK5);
            System.out.println("------------- NKK5 COUNT START --------------");
            exportData = getFieldData(nkk5DS, facility_cd);
            createFieldCSVFile(exportData, ApplicationConst.DbType.NKK5, facility_cd);

            exportData = null;
            HikariDataSource nkk6DS = (HikariDataSource) appContext.getBean(ApplicationConst.DbType.NKK6);
            System.out.println("------------- NKK6 COUNT START --------------");
            exportData = getFieldData(nkk6DS, facility_cd);
            createFieldCSVFile(exportData, ApplicationConst.DbType.NKK6, facility_cd);
            System.out.println("------------- success over --------------");

        } catch (Exception e) {
            eventLoggerUtil.recordLog(
                    facility_cd,
                eventLoggerUtil.getEventLogMessage(
                        "writeJsonField()："  + EventLoggerUtil.excetionStackTraceToString(e),
                        facility_cd,
                        e.getClass().getName() + ".writeJsonField()"),
                LogLevel.ERROR);
        }
    }

    /**
     * convert_queueテーブルにデータを挿入します
     * @param facility_cd
     * @param status
     * @return
     */
    public boolean insertConvertQueue(String facility_cd, Integer status, String inputFilePath) {
        try {
            HikariDataSource convertDS = (HikariDataSource) appContext.getBean(ApplicationConst.DbType.CONVERT);
            JdbcTemplate jdbcTemplate = new JdbcTemplate(convertDS);
            String sql = "insert into convert_queue (facility_cd, status, inputFilePath, reg_date) values(?, ?, ?, ?)";
            Object[] obj = {facility_cd, status, inputFilePath, new Date()};
            return jdbcTemplate.update(sql, obj) > 0;
        } catch (Exception e) {
            EventLogMessage eventLogMessage = eventLoggerUtil.getEventLogMessage(e.getMessage(), facility_cd, "insertConvertQueue");
            eventLoggerUtil.recordLog(facility_cd, eventLogMessage, LogLevel.ERROR);
        }
        return false;
    }
    // add FNSI-ジョブ実行修正 楊 start
    /**
     * convert_queue異常テーブルにデータを挿入します
     * @param facility_cd
     * @return
     */
    public boolean insertErrConvertQueue(String facility_cd) {
        List<Map<String,Object>> list = null;
        try {
            HikariDataSource convertDS = (HikariDataSource) appContext.getBean(ApplicationConst.DbType.CONVERT);
            JdbcTemplate jdbcTemplate = new JdbcTemplate(convertDS);
            String sql = "select reg_date, status, facility_cd, inputFilePath from convert_queue order by reg_date asc";
            list = jdbcTemplate.queryForList(sql);
            Timestamp reg_date;
            long status;
            String inputFilePath;
            // 該当データが削除して、最後に挿入
            if (null != list && list.size() > 1) {
                this.deleteByfacilityCd(facility_cd);
                reg_date = (Timestamp)list.get(list.size()-1).get("reg_date");
                long time = reg_date.getTime();
                long nexttime=time+1;
                Timestamp reg_date_new = new Timestamp(nexttime);
                status = (long)list.get(0).get("status");
                inputFilePath = (String)list.get(0).get("inputFilePath");
                String sqlErr = "insert into convert_queue (facility_cd, status, inputFilePath, reg_date) values(?, ?, ?, ?)";
                Object[] obj = {facility_cd, status, inputFilePath, reg_date_new};
                return jdbcTemplate.update(sqlErr, obj) > 0;
            }
        } catch (Exception e) {
            eventLoggerUtil.recordLog(
                facility_cd,
                eventLoggerUtil.getEventLogMessage(
                        "insertErrConvertQueue(String facility_cd) convert_queue異常テーブルにデータを挿入します："  + EventLoggerUtil.excetionStackTraceToString(e),
                        facility_cd,
                        e.getClass().getName() + ".insertErrConvertQueue(String facility_cd)"),
                LogLevel.ERROR);
        }
        return false;
    }
    // add FNSI-ジョブ実行修正 楊 end

    /**
     * status状態のレコード数をカウントします
     * @param status
     * @return
     */
    public int getCountOfStatus(String status,String facilityCd) {

        int count = 0;
        try {
            HikariDataSource convertDS = (HikariDataSource) appContext.getBean(ApplicationConst.DbType.CONVERT);
            JdbcTemplate jdbcTemplate = new JdbcTemplate(convertDS);
            //String sql = "select count(facility_cd) from convert_queue where status = ?";
            String sql = "select count(facility_cd) from batch_convert_status where status = ? and facility_cd = ?";
            count = jdbcTemplate.queryForObject(sql, new Object[]{status, facilityCd}, Integer.class);
        } catch (Exception e) {
            eventLoggerUtil.recordLog(
                facilityCd,
                eventLoggerUtil.getEventLogMessage(
                        "getCountOfStatus(Integer status) status状態のレコード数をカウントします："  + EventLoggerUtil.excetionStackTraceToString(e),
                        facilityCd,
                        e.getClass().getName() + ".getCountOfStatus(Integer status)"),
                LogLevel.ERROR);
        }
        return count;
    }

    /**
     * ジョブ起動
     * @param facility_cd
     * @param inputFilePath
     * @param progressManagement
     * @param parallelJobLauncher
     * @return
     */
    public String jobStart(String facility_cd,
                           String inputFilePath,
                           ProgressManagement progressManagement,
                           JobLauncher parallelJobLauncher) {
        String msg = null;
        try {
            // 実行中のジョブなし、ジョブ起動
            JobParametersBuilder builder = new JobParametersBuilder();
            builder.addString(ApplicationConst.JobParameterKeys.JOB, ApplicationConst.JobParameterKeys.JOB);
            builder.addString(ApplicationConst.JobParameterKeys.FACILITY_CD, facility_cd);
            builder.addString(ApplicationConst.JobParameterKeys.INPUT_FILE_PATH, inputFilePath);
            builder.addString(ApplicationConst.JobParameterKeys.TIME_STAMP, LocalDateTime.now().toString());
            JobParameters jobParameters = builder.toJobParameters();

            if (!progressManagement.isRunning(facility_cd)) {
                parallelJobLauncher.run(convertJob, jobParameters);
                msg = "facilityCd=" + facility_cd + " コンバートジョブの起動に成功しました。";
            } else {
                msg = "facilityCd=" + facility_cd + " コンバートジョブは起動中です。";
            }
        } catch (Exception e) {
            EventLogMessage eventLogMessage = eventLoggerUtil.getEventLogMessage(e.getMessage(), facility_cd, "jobStart");
            eventLoggerUtil.recordLog(facility_cd, eventLogMessage, LogLevel.ERROR);
        }
        return msg;
    }

    /**
     * 成功終了したジョブを削除する
     * @param facility_cd
     * @return
     */
    public int deleteByfacilityCd(String facility_cd) {
        HikariDataSource convertDS = (HikariDataSource) appContext.getBean(ApplicationConst.DbType.CONVERT);
        JdbcTemplate jdbcTemplate = new JdbcTemplate(convertDS);
        String sql = "delete from convert_queue where facility_cd = ?";
        return jdbcTemplate.update(sql, new Object[]{facility_cd});
    }

    /**
     * 未実行ジョブチェック
     * @return
     */
    public ConvertQueue getNextJob() {
        String facility_cd = "";
        List<Map<String,Object>> list = null;
        try {
            HikariDataSource convertDS = (HikariDataSource) appContext.getBean(ApplicationConst.DbType.CONVERT);
            JdbcTemplate jdbcTemplate = new JdbcTemplate(convertDS);
            String sql = "select facility_cd, inputFilePath from convert_queue order by reg_date asc";
            list = jdbcTemplate.queryForList(sql);
            if (null != list && !list.isEmpty()) {
                facility_cd = (String)list.get(0).get("facility_cd");
                String inputFilePath = (String)list.get(0).get("inputFilePath");
                ConvertQueue convertQueue = new ConvertQueue(facility_cd, inputFilePath);
                return convertQueue;
            }
        } catch (Exception e) {
            eventLoggerUtil.recordLog(
                facility_cd,
                eventLoggerUtil.getEventLogMessage(
                        "getNextJob() 未実行ジョブチェック："  + EventLoggerUtil.excetionStackTraceToString(e),
                        facility_cd,
                        e.getClass().getName() + ".getNextJob()"),
                LogLevel.ERROR);
        }
        return null;
    }

    /**
     * statusは実行中に変更する
     * @param facility_cd
     * @return
     */
    public int updateStatus(String facility_cd, String status) {
        int result = 0;
        try {
            HikariDataSource convertDS = (HikariDataSource) appContext.getBean(ApplicationConst.DbType.CONVERT);
            JdbcTemplate jdbcTemplate = new JdbcTemplate(convertDS);
            String sql = "update convert_queue set status = ? where facility_cd = ?";
            result = jdbcTemplate.update(sql, new Object[]{status, facility_cd});
        } catch (Exception e) {
            EventLogMessage eventLogMessage = eventLoggerUtil.getEventLogMessage(e.getMessage(), facility_cd, "updateStatus");
            eventLoggerUtil.recordLog(facility_cd, eventLogMessage, LogLevel.ERROR);
        }
        return result;
    }

    public boolean facilityCdIsExists(String facility_cd) {
        HikariDataSource convertDS = (HikariDataSource) appContext.getBean(ApplicationConst.DbType.CONVERT);
        JdbcTemplate jdbcTemplate = new JdbcTemplate(convertDS);
        String sql = "select count(facility_cd) from convert_queue where facility_cd = ?";
        Integer result = jdbcTemplate.queryForObject(sql, new Object[]{facility_cd}, Integer.class);
        if (result > 0) {
            return true;
        } else {
            return false;
        }
    }

    public boolean isCurrentJobStarted(String facilityCd) {
        try {
            HikariDataSource convertDS = (HikariDataSource) appContext.getBean(ApplicationConst.DbType.CONVERT);
            JdbcTemplate jdbcTemplate = new JdbcTemplate(convertDS);
            String sql = "select count(facility_cd) from convert_queue where facility_cd = ? and status = 1";
            int result = jdbcTemplate.queryForObject(sql, new Object[]{facilityCd}, Integer.class);
            if (result > 0) {
                return true;
            }
        } catch (Exception e) {
            EventLogMessage eventLogMessage = eventLoggerUtil.getEventLogMessage(e.getMessage(), facilityCd, "isCurrentJobStarted");
            eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.ERROR);
        }
        return false;
    }
    // add #7339 AWS側アプリが起動しない途中から開始されない yangmj start
    public static<T> List<List<T>> sqlSplit(List<T> list, int size){
        if(list==null || list.isEmpty()){
            return null;
        }
        int count = list.size();
        int pageCount = (count / size) + (count % size == 0 ? 0 : 1);
        List<List<T>> temp = new ArrayList<>(pageCount);
        for (int i = 0, from = 0,to = 0; i < pageCount; i++) {
            from = i*size;
            to = from+size;
            to = to>count?count:to;
            List<T> list1 = list.subList(from, to);
            temp.add(list1);
        }
        return temp;
    }

    /**
     * ジョブ起動
     * @param facility_cd
     * @param inputFilePath
     * @param progressManagement
     * @param parallelJobLauncher
     * @return
     */
    public String jobReStart(String facility_cd,
                             String inputFilePath,
                             ProgressManagement progressManagement,
                             JobLauncher parallelJobLauncher) {
        String msg = null;
        try {
            // ジョブ起動
            JobParametersBuilder builder = new JobParametersBuilder();
            builder.addString(ApplicationConst.JobParameterKeys.JOB, ApplicationConst.JobParameterKeys.JOB);
            builder.addString(ApplicationConst.JobParameterKeys.FACILITY_CD, facility_cd);
            builder.addString(ApplicationConst.JobParameterKeys.INPUT_FILE_PATH, inputFilePath);
            builder.addString(ApplicationConst.JobParameterKeys.TIME_STAMP, LocalDateTime.now().toString());

            if (!progressManagement.isRunning(facility_cd)) {
                JobParameters jobParameters = builder.toJobParameters();
                parallelJobLauncher.run(convertJob, jobParameters);
                msg = "facilityCd=" + facility_cd + " コンバートジョブの起動に成功しました。";
            } else {
                builder.addString(ApplicationConst.JobParameterKeys.RESTART, ApplicationConst.JobParameterKeys.RESTART);
                JobParameters jobParameters = builder.toJobParameters();
                parallelJobLauncher.run(convertJob, jobParameters);
                msg = "facilityCd=" + facility_cd + " コンバートジョブは再開しました。";
            }
        } catch (Exception e) {
            eventLoggerUtil.recordLog(
                facility_cd,
                eventLoggerUtil.getEventLogMessage(
                        "jobReStart() ジョブ起動："  + EventLoggerUtil.excetionStackTraceToString(e),
                        facility_cd,
                        e.getClass().getName() + ".jobReStart()"),
                LogLevel.ERROR);
        }
        return msg;
    }

    // ファイルに書き込む
    public boolean writeFile(String filePath, String content,String facility_cd) {

        BufferedWriter bw = null;
        try {
            bw = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(filePath), StandardCharsets.UTF_8));
            bw.write(content);
            bw.flush();
        } catch (Exception e) {
            eventLoggerUtil.recordLog(
                facility_cd,
                eventLoggerUtil.getEventLogMessage(
                        "writeFile(String filePath, String content)："  + EventLoggerUtil.excetionStackTraceToString(e),
                        facility_cd,
                        e.getClass().getName() + ".writeFile(String filePath, String content)"),
                LogLevel.ERROR);
            return false;
        } finally {
            if (bw != null) {
                try {
                    bw.close();
                } catch (IOException e) {
                    bw = null;
                }
            }
        }
        return true;
    }
    /**
     * 前回ファイル内容を読み
     * @param file　command文
     * @return　前回sql
     */
    public List<String> readFile(File file)throws Exception{
        FileReader fr = new FileReader(file);
        BufferedReader br = new BufferedReader(fr);
        List<String> sqlList = new ArrayList<String>();
        String line = br.readLine();
        sqlList.add(line);
        while(line!=null){
            line=br.readLine();
            if (line!=null) sqlList.add(line);
        }
        br.close();
        fr.close();
        return sqlList;
    }
    // add #7339 AWS側アプリが起動しない途中から開始されない yangmj end
    // add #7405 ReMS利用施設をコンバートするとモニターデータが追加となる 歴程 start
    public void delData(String facility_cd) {
        try{
            DataSource convds = (DataSource) appContext.getBean(ApplicationConst.DbType.CONVERT);
            JdbcTemplate jconv = new JdbcTemplate(convds);
            String selsql = "select COUNT(*) as count from mst_facility where facility_cd = ?";
            int count = jconv.queryForObject(selsql, Integer.class, facility_cd);
            if (count == 0) {
                String table_prefix = environment.getProperty("nkk5_prefix");
                table_prefix = table_prefix == null ? "" : table_prefix;
                DataSource delds5 = (DataSource) appContext.getBean(ApplicationConst.DbType.NKK5);
                JdbcTemplate jd5 = new JdbcTemplate(delds5);
                // SQLインジェクション対策：独立したパラメータ化クエリに分割
                String[] deleteTables = {
                    "mst_device_set_info_default", "mst_job", "mst_checklist",
                    "mni_monitor", "mnt_motion_record", "mst_vital_graph", "mst_take_medicine"
                };
                for (String table : deleteTables) {
                    String sql = "delete from " + table_prefix + table + " where facility_cd = ?";
                    jd5.update(sql, facility_cd);
                }
                // mst_selector特殊処理（有額外的master_physical_name条件）
                String selectorSql = "delete from " + table_prefix + "mst_selector where facility_cd = ? and master_physical_name = ?";
                jd5.update(selectorSql, facility_cd, "mst_job");
                // 初回コンバートする時、CONVERT側のsys_monitor_itemテーブルを削除する
                String sql = "delete from sys_monitor_item;";
                sql += "delete from mst_treatment_status_disp_item;";
                sql += "delete from mst_machine_type;";
                sql += "delete from mst_machine_record;";

                jconv.execute(sql);
            }
        }catch (Exception e){
            EventLogMessage eventLogMessage = eventLoggerUtil.getEventLogMessage(e.getMessage(), facility_cd, "delData");
            eventLoggerUtil.recordLog(facility_cd, eventLogMessage, LogLevel.ERROR);
        }
    }
    // add #7405 ReMS利用施設をコンバートするとモニターデータが追加となる 歴程 end

    /**
     * 指定されたパスにディレクトリを作成します。
     *
     * <p>引数が null または空文字列の場合は何も処理を行いません。
     * 指定されたパスが既に存在する場合も、新たにディレクトリは作成されません。</p>
     *
     * @param dirPath 作成するディレクトリのパス
     */
    public static void createDirectory(String dirPath) {
        if (dirPath == null || dirPath.isEmpty()) {
            return;
        }
        Path path = Paths.get(dirPath);
        try {
            if (!Files.exists(path)) {
                Files.createDirectory(path);
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    /**
     * 指定されたパスのファイルまたはディレクトリを再帰的に削除します。
     *
     * <p>引数が null または空文字列の場合は何も処理を行いません。
     * 指定されたパスが存在しない場合も処理は行われません。
     * ディレクトリの場合は、その中のすべてのファイルおよびサブディレクトリを
     * 再帰的に削除した後、自身のディレクトリを削除します。</p>
     *
     * @param dirPath 削除対象のファイルまたはディレクトリのパス
     * @throws IOException ファイル削除中にI/Oエラーが発生した場合
     */
    public static void deleteRecursively(String dirPath) throws IOException {
        if (dirPath == null || dirPath.isEmpty()) {
            return;
        }
        Path path = Paths.get(dirPath);
        if (Files.notExists(path)) {
            return;
        }
        if (Files.isDirectory(path)) {
            try (DirectoryStream<Path> entries = Files.newDirectoryStream(path)) {
                for (Path entry : entries) {
                    deleteRecursively(entry.toString());
                }
            }
        }
        Files.delete(path);
    }
}
