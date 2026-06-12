package web.controller;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.text.SimpleDateFormat;
import java.time.LocalDateTime;
import java.util.*;
import java.util.regex.Pattern;
import java.util.stream.Collectors;
import java.util.zip.ZipEntry;
import java.util.zip.ZipFile;
import java.util.zip.ZipOutputStream;
import javax.sql.DataSource;
import batch.ApplicationConst;
import batch.config.TestDBLinkStatus;
import batch.entity.MstFacility;
import batch.entity.PatIdLatestNo;
import org.json.JSONObject;
import org.springframework.batch.core.BatchStatus;
import org.springframework.batch.core.job.Job;
import org.springframework.batch.core.job.parameters.JobParameters;
import org.springframework.batch.core.job.parameters.JobParametersBuilder;
import tools.jackson.core.type.TypeReference;
import tools.jackson.databind.ObjectMapper;
import org.springframework.batch.core.launch.JobLauncher;
import org.springframework.batch.core.launch.JobOperator;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.context.ApplicationContext;
import org.springframework.core.env.Environment;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcOperations;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.util.ObjectUtils;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import batch.ApplicationConst.JobParameterKeys;
import batch.part.ProgressManagement;
import org.springframework.web.server.ResponseStatusException;
import utils.LogUploadService;
import utils.PatEventService;
import utils.Utils;
import web.config.EventLoggerUtil;
import web.constant.CoreConstant;
import web.constant.LoggingConstant;
import web.entity.*;
import web.logger.EventLogMessage;
import web.logger.LogLevel;
import web.utils.HashValueTOFacilityCd;

/**
 * JavaバッチREST起動用コントローラークラス
 */
@RestController
@RequestMapping("job/convert")
public class ConvertJobController {

    @Autowired
    TestDBLinkStatus testDBLinkStatus;
    @Autowired
    private LogUploadService logUploadService;
    @Autowired
    private ApplicationContext appContext;

    /**
     * 非同期実行用のJobLauncher
     */
    @Autowired
    @Qualifier("parallelJobLauncher")
    JobLauncher parallelJobLauncher;

    /**
     * Job操作オブジェクト
     */
    @Autowired
    @Qualifier("parallelJobOperator")
    JobOperator parallelJobOperator;


    @Autowired
    ProgressManagement progressManagement;

    /**
     * テーブルデータ削除ジョブ
     */
    @Autowired
    @Qualifier("DeleteTableJob")
    Job deleteTableJob;


    @Autowired
    Utils utils;

    // convert
    private NamedParameterJdbcOperations machineJdbcTemplate;

    @Autowired
    private Environment environment;

    // add #8600 ローカル保存設定で患者イベントなどの画像ファイルがコンバートされない limingyang start
    @Autowired
    private PatEventService patEventService;

    @Autowired
    private HashValueTOFacilityCd hshValueTOFacilityCd;
    // add #8600 ローカル保存設定で患者イベントなどの画像ファイルがコンバートされない limingyang end

    // add #7339 AWS側アプリが起動しない途中から開始されない yangmj start
    /**
     * テーブルデータ削除ジョブ
     */
    @Autowired
    @Qualifier("DeleteConvertTableJob")
    Job deleteConvertTableJob;
    // add #7339 AWS側アプリが起動しない途中から開始されない yangmj end
    @Autowired
    private EventLoggerUtil eventLoggerUtil;


    /**
     * ジョブの起動
     * 
     * @throws Exception
     */
    @PostMapping("/execute")
    public String executeJob(@RequestBody ExecuteJobStartRequest executeJobStartRequest) throws Exception {
        try{
        String msg = "";
        List<String> facilityCds = hshValueTOFacilityCd.getfacilitycd(executeJobStartRequest.getFacilityCd());
        if(facilityCds.isEmpty()){
            return  "コンバートジョブはキューに追加失敗しました。";
        }
        String  facilityCd=facilityCds.get(0);

        String inputFilePath = executeJobStartRequest.getInputFilePath();
        //add #12737 securify】convert-server-sideが落ちる start
        validateInputFilePathFacilityCd(inputFilePath, facilityCd);
        //add #12737 securify】convert-server-sideが落ちる end

        // add #7405 ReMS利用施設をコンバートするとモニターデータが追加となる 歴程 start
        utils.delData(facilityCd);
        // add #7405 ReMS利用施設をコンバートするとモニターデータが追加となる 歴程 end
        // add #8600 ローカル保存設定で患者イベントなどの画像ファイルがコンバートされない limingyang start
        patEventService.setStatus("");
        // add #8600 ローカル保存設定で患者イベントなどの画像ファイルがコンバートされない limingyang end

        // 実行中チェック
        msg = utils.jobStart(facilityCd, inputFilePath, progressManagement, parallelJobLauncher);
        return msg;
        }catch (ResponseStatusException e) {
            throw e;
        }
    }
    
    /**
     * ジョブのステータス確認
     * 
     * @throws Exception
     */
    @PostMapping("/status")
    public List<Map<String, Object>> status(@RequestBody CommonRequest commonRequest) throws Exception {
        //add #12737 securify】convert-server-sideが落ちる start
        try{
        List<String> facilityCds = hshValueTOFacilityCd.getfacilitycd(commonRequest.getFacilityCd());
        //#12737 【securify】convert-server-sideが落ちる start
        if (facilityCds.size() != 1) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN);
        }
        //#12737 【securify】convert-server-sideが落ちる start
        String  facilityCd=facilityCds.get(0);
        List<Map<String, Object>> statusList = progressManagement.getStatusList(facilityCd);
        return statusList;
        }catch (ResponseStatusException e) {
            throw e;
        }catch (Exception e) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Bad Request");
        }
        //add #12737 securify】convert-server-sideが落ちる start
    }

    /**
     * ジョブのステータス確認（テーブル単位）
     * 
     * @throws Exception
     */
    @PostMapping("/tableStatus")
    // mod ProgressBarの修正 楊 start
    public List<Map<String, Object>> tableStatus(@RequestBody TableStatusRequest tableStatusRequest) throws Exception {
        //add #12737 securify】convert-server-sideが落ちる start
        try{

        List<String> facilityCds = hshValueTOFacilityCd.getfacilitycd(tableStatusRequest.getFacilityCd());
        String  facilityCd=facilityCds.get(0);
        List<Map<String, Object>> statusList = progressManagement.getTableStatusList(facilityCd, tableStatusRequest.getOrderNo());
        // mod ProgressBarの修正 楊 end
        return statusList;
        }catch (ResponseStatusException e) {
            throw e;
        }catch (Exception e) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Bad Request");
        }
        //add #12737 securify】convert-server-sideが落ちる start
    }
    
    /**
     * ジョブのステータス確認（テーブル単位）
     * 
     * @throws Exception
     */
    @PostMapping("/tableStatusForLog")
    // mod ログ出力修正 楊 start
    public List<Map<String, Object>> tableStatusForLog(@RequestBody TableStatusRequest tableStatusRequest) throws Exception {
        //add #12737 securify】convert-server-sideが落ちる start
        try{

        List<String> facilityCds = hshValueTOFacilityCd.getfacilitycd(tableStatusRequest.getFacilityCd());
        String  facilityCd=facilityCds.get(0);
        List<Map<String, Object>> statusList = progressManagement.getTableStatusListForLog(facilityCd, tableStatusRequest.getOrderNo());
    // mod ログ出力修正 楊 end
        return statusList;
        }catch (ResponseStatusException e) {
            throw e;
        }catch (Exception e) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Bad Request");
        }
        //add #12737 securify】convert-server-sideが落ちる start
    }

    /**
     * ジョブの停止指示
     * 
     * @throws Exception
     */
    @PostMapping("/stop")
    public String stop(@RequestBody CommonRequest commonRequest) throws Exception {
        //add #12737 securify】convert-server-sideが落ちる start
        String msg;
        try{
        List<String> facilityCds = hshValueTOFacilityCd.getfacilitycd(commonRequest.getFacilityCd());
        //#12737 【securify】convert-server-sideが落ちる start
        if (facilityCds.size() != 1) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN);
        }
        //#12737 【securify】convert-server-sideが落ちる start
        String  facilityCd=facilityCds.get(0);
        // 現在のステータスの取得
        String status = progressManagement.getStatus(facilityCd);

        // ステータスが実行中のときのみ停止命令を受け付ける
        if (status.equals(progressManagement.STARTED)) {
            // 停止指示
            progressManagement.stopJob(facilityCd);
            msg = "facilityCd=" + facilityCd + " 停止命令を実行しました。";
        }else{
            // ステータスが実行中以外の場合、現在のステータスをメッセージで返す
            msg = "facilityCd=" + facilityCd + " 現在のステータスは " +
            progressManagement.StatusToJp.get(status) + " のため、停止命令を受け付けませんでした。";
        }
        }catch (ResponseStatusException e) {
            throw e;
        }catch (Exception e) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Bad Request");
        }
        return msg;
        //add #12737 securify】convert-server-sideが落ちる start
    }


   /**
     * ジョブの起動
     * @throws Exception
     */
    @PostMapping("/deleteTableJob")
    public String deleteTableJob(@RequestBody DeleteTableJobRequest deleteTableJobRequest) throws Exception {
        String msg;
        try {
            List<String> facilityCds = hshValueTOFacilityCd.getfacilitycd(deleteTableJobRequest.getFacilityCd());
            String  facilityCd=facilityCds.get(0);
            //deleteJobの起動時にグローバル変数に格納され、実行中の設定コードを表します
            // utils.deleteJobFacilityCd = facilityCd;
            // add #8471 削除ボタンの動きが異常 limingyang start
            JSONObject res = new JSONObject(testDBLinkStatus.DBActiveStatus());
            if (res.getString("status").equals("1")) {
                return "現在、Postgresqlに接続できません。時間をおいて再度お試しください。";
            }
            //DeleteTableJobを実行する前に、前のDeleteTableJobで実行したデータを消去します
            String tableName = "batch_convert_status";
            DataSource convert = (DataSource) appContext.getBean(ApplicationConst.DbType.CONVERT);
            machineJdbcTemplate = new NamedParameterJdbcTemplate(convert);
            String to_Db_table_prefix = environment.getProperty("datasource." + ApplicationConst.DbType.CONVERT + ".table_prefix");
            String deleteSql = "delete from " + to_Db_table_prefix + tableName + " where facility_cd = ? and job_name = 'DeleteTableJob'";
            machineJdbcTemplate.getJdbcOperations().update(deleteSql, facilityCd);

            // add #8471 削除ボタンの動きが異常 limingyang end
            JobParametersBuilder builder = new JobParametersBuilder();
            builder.addString("job", JobParameterKeys.JOB);
            builder.addString("facilityCd", facilityCd);
            builder.addString(JobParameterKeys.TIME_STAMP, LocalDateTime.now().toString());
            builder.addString(JobParameterKeys.IP_ADDRESS, deleteTableJobRequest.getIp() != null ? deleteTableJobRequest.getIp() : ""); // #11998 add
            JobParameters jobParameters = builder.toJobParameters();

            // utils.ipAddress = deleteTableJobRequest.getIp(); #11998 del
            parallelJobLauncher.run(deleteTableJob, jobParameters);
            msg = "facilityCd=" + facilityCd + " テーブルデータ削除ジョブの起動に成功しました。";
        }catch (ResponseStatusException e) {
            throw e;
        }catch(Exception e) {
            throw e;
        }
        return msg;
    }

    // #12451 コンバートツールで使用しているDotNetZipの脆弱性対策(CVE-2024-48510) mod Start
    /**
     * ファイルアップロードAPI
     *
     */
    @RequestMapping(value = "/uploadfile", method = RequestMethod.POST)
    public ResponseEntity uploadFile(
            @RequestPart(value="uploadFiles", required = true) MultipartFile[] uploadFiles,
            @RequestParam(value = "uploadServPath", required = true) String uploadServPath,
            @RequestParam(value = "originalFileName", required = false) String originalFileName,
            @RequestParam(value = "partIndex", required = false) Integer partIndex,
            @RequestParam(value = "totalParts", required = false) Integer totalParts) {

        try {
            
            //#12737 【securify】convert-server-sideが落ちる start
            if (uploadServPath == null
                    || uploadServPath.length() > 200) {

                throw new ResponseStatusException(HttpStatus.FORBIDDEN);
            }
            
            if (uploadServPath.contains("../")
                    || uploadServPath.contains("..\\")) {

                throw new ResponseStatusException(HttpStatus.FORBIDDEN);
            }
            //#12737 【securify】convert-server-sideが落ちる end
            File dir = new File(uploadServPath);
            if (!dir.exists()) {
                dir.mkdirs();
            }

            for (MultipartFile item : uploadFiles) {
               //#12737 【securify】convert-server-sideが落ちる start
                if (item == null || item.isEmpty()) {
                    throw new ResponseStatusException(HttpStatus.FORBIDDEN);
                }
                String fileName = item.getOriginalFilename();
                
                // zip形式のみ許可
                String lowerName = fileName.toLowerCase();

                boolean valid =
                        lowerName.endsWith(".zip")
                                || lowerName.matches(".*\\.zip\\.part\\d{3}$");

                if (!valid) {
                    throw new ResponseStatusException(HttpStatus.FORBIDDEN);
                }
                //#12737 【securify】convert-server-sideが落ちる start
                File file = new File(uploadServPath + "/" + item.getOriginalFilename());
                item.transferTo(file);
            }

            // 分割転送モードの場合
            if (originalFileName != null && partIndex != null && totalParts != null) {

                // 最後の part の場合が合併処理を実施
                if (partIndex.equals(totalParts)) {
                    mergeParts(uploadServPath, originalFileName, totalParts);
                }
            }

        } catch (ResponseStatusException e) {
            throw e;
        }
        catch (Exception e) {
            return new ResponseEntity<>("ファイル転送が失敗した。", HttpStatus.BAD_REQUEST);
        }

        return new ResponseEntity<>("ファイル転送が完了した。", HttpStatus.OK);
    }

    /**
     * 分割して転送されたファイルを合併する
     *
     */
    private void mergeParts(String dirPath, String originalFileName, int totalParts) throws IOException {
        // part ファイルリスト
        File outputFile = new File(dirPath, originalFileName);

        try (FileOutputStream fos = new FileOutputStream(outputFile)) {
            for (int i = 1; i <= totalParts; i++) {
                File partFile = new File(dirPath,
                        originalFileName + ".part" + String.format("%03d", i));
                if (!partFile.exists()) {
                    throw new RuntimeException("Part file missing: " + partFile.getName());
                }
                // part ファイルを連結
                Files.copy(partFile.toPath(), fos);
            }
        }
        // part ファイルを削除
        for (int i = 1; i <= totalParts; i++) {
            File partFile = new File(dirPath,
                    originalFileName + ".part" + String.format("%03d", i));
            partFile.delete();
        }
    }
    // #12451 コンバートツールで使用しているDotNetZipの脆弱性対策(CVE-2024-48510) mod End


    /**
     * ログファイルアップロード
     *
     */
    @RequestMapping(value = "/upload", method = RequestMethod.POST)
    public ResponseEntity upload(@RequestPart(value="logFiles", required = true)  MultipartFile[] uploadFiles, @RequestParam(value = "facilityCd", required = true) String facilityCd
            , @RequestParam(value = "uploadLogFileName", required = true) String uploadLogFileName){
        try {
           //#12737 【securify】convert-server-sideが落ちる,ファイルのアップロードチェック start
            if (facilityCd == null || facilityCd.length() > 110) {
                throw new ResponseStatusException(
                        HttpStatus.FORBIDDEN,
                        "Forbidden"
                );
            }
           
            if (uploadFiles == null || uploadFiles.length == 0) {
                throw new ResponseStatusException(HttpStatus.FORBIDDEN);
            }
            //#12737 【securify】convert-server-sideが落ちる,ファイルのアップロードチェック end

            List<String> facilityCds = hshValueTOFacilityCd.getfacilitycd(facilityCd);
            String  facility_Cd=facilityCds.get(0);
            String fileLocation = "";
            SysSystemDefine systemDefine = logUploadService.getSystemDefine(CoreConstant.SysSystemDefine.CONVERT_LOG_OUTPUT_PATH);

            if (!ObjectUtils.isEmpty(systemDefine.getValue())) {
                ObjectMapper objectMapper = new ObjectMapper();
                Map<String, String> onPremise = objectMapper.readValue(systemDefine.getValue(), new TypeReference<Map<String, String>>() {
                });
                fileLocation = onPremise.get("path");
            }
            if (fileLocation.equals("")){
                return new ResponseEntity<>("No log address specified", HttpStatus.BAD_REQUEST);
            }
            fileLocation = fileLocation.replace("{0}",facility_Cd).replace("{1}","today");
            File dir = new File(fileLocation);
            if(!dir.exists()) {
                dir.mkdirs();
            }
            for (MultipartFile item : uploadFiles) {

            //#12737 【securify】convert-server-sideが落ちる,ファイルのアップロードチェック start
                if (item == null || item.isEmpty()) {
                    throw new ResponseStatusException(HttpStatus.FORBIDDEN);
                }

                
                if (item.getSize() > 50 * 1024 * 1024) {
                    throw new ResponseStatusException(HttpStatus.FORBIDDEN);
                }
                String originalName = item.getOriginalFilename();

                if (originalName == null) {
                    throw new ResponseStatusException(HttpStatus.FORBIDDEN);
                }

                // パススルー防止
                originalName = Paths.get(originalName)
                        .getFileName()
                        .toString();

                if (originalName.length() > 200) {
                    throw new ResponseStatusException(HttpStatus.FORBIDDEN);
                }

                // zip形式のみ許可
                if (!originalName.toLowerCase().endsWith(".zip")) {
                    throw new ResponseStatusException(HttpStatus.FORBIDDEN);
                }
                // ZIPファイルヘッダーのチェック
                byte[] header = item.getBytes();

                if (header.length < 4
                        || header[0] != 0x50
                        || header[1] != 0x4B) {

                    throw new ResponseStatusException(HttpStatus.FORBIDDEN);
                }
               //#12737 【securify】convert-server-sideが落ちる,ファイルのアップロードチェック start
                File file = new File(fileLocation + originalName);
                item.transferTo(file);
                //add #9696 djy start
                if (!originalName.contains(facility_Cd)) {
                    if (reNameFileInZip(facility_Cd, fileLocation, originalName)){
                        file.delete();
                    }
                }
                //add #9696 djy end
            }
            File folder = new File(fileLocation);
            List<File> delFiles = new ArrayList<>();
            if (folder.isDirectory()) {
                File[] files = folder.listFiles();
                for (File file : files) {
                    String fileName = file.getName();
                    String fileDate = fileName.substring(fileName.length()-19, fileName.length()-11);
                    String pattern = "^[0-9]{8}$";
                    boolean isMatch = Pattern.matches(pattern, fileDate);
                    if (isMatch){
                        Date currentDate = new Date();
                        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyyMMdd");
                        String formattedDate = dateFormat.format(currentDate);
                        if (!fileDate.equals(formattedDate)){
                            Path sourcePath = Path.of(fileLocation + file.getName());
                            String targetPathStr = fileLocation.replace("today",fileDate);
                            Path targetPath = Path.of(targetPathStr);
                            File dirtar = new File(targetPathStr);
                            if(!dirtar.exists()) {
                                dirtar.mkdirs();
                            }
                            Files.copy(sourcePath, targetPath.resolve(sourcePath.getFileName()), StandardCopyOption.REPLACE_EXISTING);
                            delFiles.add(file);
                        }
                    }
                }
                for (File delFile:delFiles){
                    if (delFile.exists()) {
                        delFile.delete();
                    }
                }
            }
        }catch (ResponseStatusException e) {
            throw e;
        } catch (Exception ex) {
            eventLoggerUtil.recordLog(
                facilityCd,
                eventLoggerUtil.getEventLogMessage(
                        "upload(@RequestPart(value=\"logFiles\")  MultipartFile[] uploadFiles, @RequestParam(value = \"facilityCd\")："  + EventLoggerUtil.excetionStackTraceToString(ex),
                        facilityCd,
                        ex.getClass().getName() + ".upload(@RequestPart(value=\"logFiles\")  MultipartFile[] uploadFiles, @RequestParam(value = \"facilityCd\")"),
                LogLevel.ERROR);

            return new ResponseEntity<>("Log upload failed", HttpStatus.BAD_REQUEST);
        }
        return new ResponseEntity<>("Log uploaded successfully", HttpStatus.OK);
    }

    //add #9696 djy start
    /**
     * reNameFileInZip
     * @param facilityCd
     * @param fileLocation
     * @param fileName
     * @throws IOException
     */
    public boolean reNameFileInZip(String facilityCd, String fileLocation, String fileName) throws IOException {
        boolean result = false;
        try (ZipFile zipFile = new ZipFile(fileLocation + fileName);
             FileOutputStream fos = new FileOutputStream(fileLocation + facilityCd + "_" + fileName);
             ZipOutputStream zos = new ZipOutputStream(fos)) {
            Enumeration<? extends ZipEntry> entries = zipFile.entries();
            while (entries.hasMoreElements()) {
                ZipEntry entry = entries.nextElement();
                String newName = facilityCd + "_" + entry.getName();
                ZipEntry newEntry = new ZipEntry(newName);
                zos.putNextEntry(newEntry);
                try (InputStream is = zipFile.getInputStream(entry)) {
                    byte[] buffer = new byte[1024];
                    int len;
                    while ((len = is.read(buffer)) > 0) {
                        zos.write(buffer, 0, len);
                    }
                }
                zos.closeEntry();
            }
            zos.finish();
            result = true;
        } catch (IOException e) {
            eventLoggerUtil.recordLog(
                facilityCd,
                eventLoggerUtil.getEventLogMessage(
                        "reNameFileInZip(String facilityCd, String fileLocation, String fileName) reNameFileInZip：" + EventLoggerUtil.excetionStackTraceToString(e),
                        facilityCd,
                        e.getClass().getName() + ".reNameFileInZip()"),
                LogLevel.ERROR);
            return result;
        }
       return result;

    }
    //add #9696 djy end

    /*
     * DBの接続をチェック
     */
    @RequestMapping(value = "/checkDBConnection", method = RequestMethod.POST)
    public boolean isConnection() {
        // mod dataSource limingyang start
        JSONObject res = new JSONObject(testDBLinkStatus.DBActiveStatus());
        if (res.getString("status").equals("1")) {
            return false;
        }else{
            return true;
        }
        // mod dataSource limingyang end
    }


    /**
     *
     * @return
     */
    @RequestMapping(value = "/health/check")
    public boolean getHealth() {
       return true;
    }

    // add #7339 AWS側アプリが起動しない途中から開始されない yangmj start
    /**
     * コンバートdbを 削除
     * @param commonRequest
     * @return 削除状態
     */
    @RequestMapping(value = "/deleteConvertTableJob", method = RequestMethod.POST)
    public String deleteConvertTableJob(@RequestBody CommonRequest commonRequest) throws Exception {

        try{
            List<String> facilityCds = hshValueTOFacilityCd.getfacilitycd(commonRequest.getFacilityCd());
            //#12737 【securify】convert-server-sideが落ちる start
            if (facilityCds.size() != 1) {
                throw new ResponseStatusException(HttpStatus.FORBIDDEN);
            }
            //#12737 【securify】convert-server-sideが落ちる start
            String  facilityCd=facilityCds.get(0);
            JobParametersBuilder builder = new JobParametersBuilder();
            builder.addString("job", JobParameterKeys.JOB);
            builder.addString("facilityCd", facilityCd);
            builder.addString(JobParameterKeys.TIME_STAMP, LocalDateTime.now().toString());
            JobParameters jobParameters = builder.toJobParameters();

            String msg;
            parallelJobLauncher.run(deleteConvertTableJob, jobParameters);
            msg = "facilityCd=" + facilityCd+ " コンバートテーブルデータ削除ジョブの起動に成功しました。";

            return msg;
        }catch (ResponseStatusException e) {
            throw e;
        }

    }

    /**
     * ジョブの起動
     *
     * @throws Exception
     */
    @PostMapping("/executeRestart")
    public String executeRestartJob(@RequestBody ExecuteJobStartRequest executeJobStartRequest) throws Exception {
        try{
            String msg = null;
            List<String> facilityCds = hshValueTOFacilityCd.getfacilitycd(executeJobStartRequest.getFacilityCd());
            String  facilityCd=facilityCds.get(0);
            String inputFilePath = executeJobStartRequest.getInputFilePath();
            //add #12737 securify】convert-server-sideが落ちる start
            validateInputFilePathFacilityCd(inputFilePath, facilityCd);
            //add #12737 securify】convert-server-sideが落ちる end

            // 実行中チェック
            int countStarted = utils.getCountOfStatus(BatchStatus.STARTED.toString(), facilityCd);
            if (countStarted == 0) {
                // 未実行ジョブなし、このジョブ起動
                msg = utils.jobStart(facilityCd, inputFilePath, progressManagement, parallelJobLauncher);

            } else {
                // 未実行ジョブなし、このジョブ起動
                // ジョブを再開
                msg = utils.jobReStart(facilityCd, inputFilePath, progressManagement, parallelJobLauncher);

            }
            return msg;
        }catch (ResponseStatusException e) {
            throw e;
        }

    }
    // add #7339 AWS側アプリが起動しない途中から開始されない yangmj end


    @PostMapping("/getMstFacility")
    public ResponseEntity<?> getMstFacility(@RequestBody CommonRequest commonRequest) throws Exception {
        List<String> facilityCds = hshValueTOFacilityCd.getfacilitycd(commonRequest.getFacilityCd());

        DataSource db_5 = (DataSource) appContext.getBean(ApplicationConst.DbType.NKK5);
        try{
            String placeholders = String.join(",", Collections.nCopies(facilityCds.size(), "?"));
            String sql="SELECT ROW_NUMBER() OVER (ORDER BY facility_cd) AS No, facility_cd,facility_name,COALESCE(is_schext_exception, '0') as is_schext_exception FROM mst_facility where facility_cd IN (" + placeholders + ")";

            machineJdbcTemplate = new NamedParameterJdbcTemplate(db_5);
            List<MstFacility> mstFacilityList =  machineJdbcTemplate.getJdbcOperations().query(sql, facilityCds.toArray(), new BeanPropertyRowMapper<>(MstFacility.class));
            EventLogMessage eventLogMessagex = eventLoggerUtil.getEventLogMessage("詳細なエラー情報：" +sql,
                    String.join(",", facilityCds), "getMstFacility");
            eventLoggerUtil.recordLog(String.join(",", facilityCds), eventLogMessagex, LogLevel.INFO);
            return new ResponseEntity<>( mstFacilityList, HttpStatus.OK);
        }catch (ResponseStatusException e) {
            throw e;
        }catch(Exception e) {
            EventLogMessage eventLogMessagex = eventLoggerUtil.getEventLogMessage("詳細なエラー情報：" + e.toString(),
                    null, "getMstFacility");
            eventLoggerUtil.recordLog(String.join(",", facilityCds), eventLogMessagex, LogLevel.ERROR);
            return new ResponseEntity<>(e.getMessage(),HttpStatus.INTERNAL_SERVER_ERROR);
        }


    }

    @PostMapping("/updateMstFacility")
    public ResponseEntity<?> updateMstFacility(@RequestBody UpdateMstFacilityRequest updateMstFacilityRequest) throws Exception {
        List<String> facilityCds = hshValueTOFacilityCd.getfacilitycd(updateMstFacilityRequest.getFacilityCd());
        String  facilityCd=facilityCds.get(0);
        DataSource db_5 = (DataSource) appContext.getBean(ApplicationConst.DbType.NKK5);
        JdbcTemplate jdbcTemplateNkk5 = new JdbcTemplate(db_5);
        String  flag= null;
        String  Message= null;
        if(updateMstFacilityRequest.getFlag().equals("1")){
            flag= "0";
            Message= "「実行→停止」";
        }else{
            flag= "1";
            Message= "「停止→実行」";
        }
        String sql = "update mst_facility set is_schext_exception=?   where  facility_cd=?";
        try {
            jdbcTemplateNkk5.update(sql, new Object[]{flag,facilityCd});
            EventLogMessage eventLogMessagex = eventLoggerUtil.getEventLogMessage("詳細なエラー情報：" + Message,
                    facilityCd, "updateMstFacility");
            eventLoggerUtil.recordLog(facilityCd, eventLogMessagex, LogLevel.INFO);
            return new ResponseEntity<>("ok", HttpStatus.OK);
        }catch (ResponseStatusException e) {
            throw e;
        } catch (Exception e) {
            EventLogMessage eventLogMessagex = eventLoggerUtil.getEventLogMessage("詳細なエラー情報：" +Message+ e.toString(),
                    null, "updateMstFacility");
            eventLoggerUtil.recordLog(facilityCd, eventLogMessagex, LogLevel.ERROR);
            return new ResponseEntity<>(e.getMessage(),HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }


    /**
     *  #10859-9
     *
     */
    @PostMapping("/getOrdMain")
    public String getOrdMain(@RequestBody CommonRequest commonRequest) throws Exception {
        List<String> facilityCds = hshValueTOFacilityCd.getfacilitycd(commonRequest.getFacilityCd());
        DataSource db_5 = (DataSource) appContext.getBean(ApplicationConst.DbType.NKK5);
        try{
            String placeholders = String.join(",", Collections.nCopies(facilityCds.size(), "?"));
            String sql="SELECT  count(*)  FROM ord_main where  facility_cd IN (" + placeholders + ")";
            machineJdbcTemplate = new NamedParameterJdbcTemplate(db_5);
            String count = machineJdbcTemplate.getJdbcOperations().queryForObject(sql, Integer.class, facilityCds.toArray()).toString();
            EventLogMessage eventLogMessagex = eventLoggerUtil.getEventLogMessage("詳細なエラー情報：" +sql,
                    String.join(",", facilityCds), "getOrdMain");
            eventLoggerUtil.recordLog(String.join(",", facilityCds), eventLogMessagex, LogLevel.INFO);
            return count;
        }catch (ResponseStatusException e) {
            throw e;
        }
        catch(Exception e) {
            EventLogMessage eventLogMessagex = eventLoggerUtil.getEventLogMessage("詳細なエラー情報：" + e.toString(),
                    null, "getOrdMain");
            eventLoggerUtil.recordLog(String.join(",", facilityCds), eventLogMessagex, LogLevel.ERROR);
            return "0";
        }
    }

    @PostMapping("/getPatLatestNo")
    public List<PatIdLatestNo> getPatLatestNo(@RequestBody CommonRequest commonRequest) throws Exception {
        List<String> facilityCds = hshValueTOFacilityCd.getfacilitycd(commonRequest.getFacilityCd());
        //#12737 【securify】convert-server-sideが落ちる start
        if (facilityCds.size() != 1) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN);
        }
        //#12737 【securify】convert-server-sideが落ちる start
        String  facilityCd=facilityCds.get(0);
        DataSource machineDsNkk5 = (DataSource) appContext.getBean(ApplicationConst.DbType.NKK5);
        JdbcTemplate jdbc5 = new JdbcTemplate(machineDsNkk5);
        DataSource machineDsNkkcon = (DataSource) appContext.getBean(ApplicationConst.DbType.CONVERT);
        JdbcTemplate jdbccon = new JdbcTemplate(machineDsNkkcon);

        MapSqlParameterSource params = new MapSqlParameterSource();
        params.addValue("facility_cd", facilityCd);
        List<PatIdLatestNo> PatIdLatestNoResults = new ArrayList<>();
        try{

            String sql="SELECT  pat_id, medi_info_no FROM medicine_latest_no where  facility_cd= :facility_cd";
            NamedParameterJdbcTemplate namedParameterJdbcTemplate = new NamedParameterJdbcTemplate(jdbc5);
            List<PatIdLatestNo> patNo= namedParameterJdbcTemplate.query(sql, params,new BeanPropertyRowMapper<>(PatIdLatestNo.class));

            Map<String, String> patIdToMediInfoNoMap = patNo.stream()
                    .collect(Collectors.toMap(PatIdLatestNo::getPatId, PatIdLatestNo::getMediInfoNo));

            String sql6="SELECT  fn_pat_id, pat_id FROM pat_personal_main where  facility_cd= :facility_cd and fn_pat_id is not null";
            NamedParameterJdbcTemplate namedParameterJdbcTemplatecon = new NamedParameterJdbcTemplate(jdbccon);
            List<PatIdLatestNo> fnPatNo= namedParameterJdbcTemplatecon.query(sql6, params,new BeanPropertyRowMapper<>(PatIdLatestNo.class));

             PatIdLatestNoResults = fnPatNo.stream()
                    .map(patInfo -> {
                        PatIdLatestNo combinedResult = new PatIdLatestNo();
                        combinedResult.setFn_pat_id(patInfo.getFn_pat_id());
                        combinedResult.setMediInfoNo(patIdToMediInfoNoMap.get(patInfo.getPatId()));
                        return combinedResult;
                    })
                    .collect(Collectors.toList());

            EventLogMessage eventLogMessagex = eventLoggerUtil.getEventLogMessage("詳細情報：患者投薬最新識別番号成功する",
                    facilityCd, "getPatLatestNo");
            eventLoggerUtil.recordLog(facilityCd, eventLogMessagex, LogLevel.INFO);
            return PatIdLatestNoResults;
        }catch (ResponseStatusException e) {
            throw e;
        }catch(Exception e) {
            EventLogMessage eventLogMessagex = eventLoggerUtil.getEventLogMessage("詳細なエラー情報：" + e.toString(),
                    null, "getPatLatestNo");
            eventLoggerUtil.recordLog(facilityCd, eventLogMessagex, LogLevel.ERROR);
            return PatIdLatestNoResults;
        }
    }

    /**
     * #12737 securify】convert-server-sideが落ちる add
     * inputFilePathの最下層フォルダ名がfacilityCdと一致するか検証する
     */
    private void validateInputFilePathFacilityCd(String inputFilePath, String facilityCd) {
        Path path = Paths.get(inputFilePath).normalize();
        Path lastFolder = path.getFileName();
        if (lastFolder == null || !facilityCd.equals(lastFolder.toString())) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN);
        }
    }

}