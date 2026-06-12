package jp.co.nikkiso.ntss.admin_web.service.bvms;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.zip.ZipEntry;

import tools.jackson.core.type.TypeReference;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.SysSystemDefineDao;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.SysSystemDefine;
import org.json.JSONObject;
import org.springframework.transaction.annotation.Transactional;
import org.apache.commons.compress.archivers.zip.ZipArchiveEntry;
import org.apache.commons.compress.archivers.zip.ZipFile;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.multipart.MultipartFile;

import tools.jackson.databind.ObjectMapper;

import jp.co.nikkiso.ntss.admin_web.response.bvms.dto.BVMSGraphDTO;
import jp.co.nikkiso.ntss.admin_web.response.bvms.dto.BVMSRowDTO;
import jp.co.nikkiso.ntss.admin_web.response.bvms.dto.BVMSZipFileStructureDTO;
import jp.co.nikkiso.ntss.admin_web.response.bvms.dto.ErrorCellDTO;
import jp.co.nikkiso.ntss.admin_web.service.bvms.converter.BVMSRowConverter;
import jp.co.nikkiso.ntss.admin_web.service.bvms.converter.CSVParserService;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import software.amazon.awssdk.core.ResponseInputStream;
import software.amazon.awssdk.core.sync.RequestBody;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.DeleteObjectRequest;
import software.amazon.awssdk.services.s3.model.GetObjectRequest;
import software.amazon.awssdk.services.s3.model.GetObjectResponse;
import software.amazon.awssdk.services.s3.model.ListObjectsV2Request;
import software.amazon.awssdk.services.s3.model.PutObjectRequest;
import software.amazon.awssdk.services.s3.model.S3Object;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.apache.commons.lang3.StringUtils;

public abstract class AbstractBVMSService<I, O> implements BVMSService<I, O> {

    private static final int LENGHT_OF_DATE = 8;

  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
  @Autowired
  private LogService logService;
  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end

    @Autowired
    private S3Client s3;

    @Value("${ntss.report.cache-dir}")
    private String cacheDir;

    @Value("${ntss.report.s3-bucket}")
    private String bucket;

    @Autowired
    private BVMSZipFileService bvmsZipFileService;

    @Autowired
    protected BVMSApdapterService apdapterService;

    //add FNSI-8360 ljx start
    @Value("${ntss.bvms.s3-bucket:#{null}}")
    private String bvmsBucket;

    @Autowired
    private SysSystemDefineDao sysSystemDefineDao;

    @Autowired
    private OrdMainDao ordMainDao;
    //add FNSI-8360 ljx end

    //mod FNSI-8360 ljx start
    //protected BVMSGraphDTO getBVMSGraphDTO(Long ordNo) {
    protected BVMSGraphDTO getBVMSGraphDTO(Long ordNo,String facilityCd) {
      //        BVMSZipFileStructureDTO zipFileDTO = bvmsZipFileService.buildZipFileStructureDTO(ordNo);
      //
      //        String partOfZipFileName = buildPartOfZipFileName(zipFileDTO);
      //        String partOfCSVFileName = zipFileDTO.getMachineSerial() + "_" + zipFileDTO.getTreatDate();
      //        BVMSGraphDTO bvmsGraphDTO = getBVMSGraphDTO(partOfZipFileName, partOfCSVFileName, zipFileDTO);
      byte[] content = new byte[0];
      Reader reader;
      InputStream inputStream = null;
      //ord_mainから保存されたパスを取得。
      Map<String,String> pathMap = this.getBvmsPath(ordNo);
      String bvmsPath = "";
      try {
        if(pathMap.keySet().size()>0){
          content = this.getFileAttachment(pathMap.get("bucket"),pathMap.get("csv_filename"),facilityCd);
          inputStream= new ByteArrayInputStream(content);
          bvmsPath = pathMap.get("bucket")+"/"+pathMap.get("csv_filename");
        }
      } catch (Exception e) {
        throw new NtssException("ファイルが見つかりません :" + bvmsPath, e);
      }
      reader = new InputStreamReader(inputStream);
      BVMSGraphDTO bvmsGraphDTO = buildBVMSGraphDTO(unmarshall(reader));
      if (bvmsGraphDTO == null) {
        throw new NtssException("ファイルが見つかりません : " + bvmsPath);
      }
      //mod FNSI-8360 ljx end
      return bvmsGraphDTO;
    }

    protected BVMSGraphDTO getBVMSGraphDTOFromUploadFile(MultipartFile files) {
        Reader reader;
        try {
            reader = new InputStreamReader(files.getInputStream());
            return  buildBVMSGraphDTO(unmarshall(reader));
        } catch (IOException e) {
            throw new NtssException("I/O exception occurs during reading upload file", e);
        }
    }

    private BVMSGraphDTO buildBVMSGraphDTO(List<BVMSRowDTO> rowDTOs) {
        BVMSGraphDTO bvmsGraph = new BVMSGraphDTO();
        List<ErrorCellDTO> allErrorCells = new ArrayList<>();
        List<BVMSRowDTO> rows = new ArrayList<>();

        for (BVMSRowDTO rowDTO : rowDTOs) {
            List<ErrorCellDTO> errorCells = rowDTO.getErrorColumns();
            if (errorCells != null && errorCells.size() > 0) {
                allErrorCells.addAll(errorCells);
            } else {
                rows.add(rowDTO);
            }
        }
        if (!allErrorCells.isEmpty()) {
            bvmsGraph.setErrorCells(allErrorCells);
        } else {
            bvmsGraph.setRows(rows);
        }

        return bvmsGraph;
    }

    private List<BVMSRowDTO> unmarshall(Reader is) {
        return new CSVParserService<BVMSRowDTO>(new BVMSRowConverter()).parse(is);
    }

    private BVMSGraphDTO getBVMSGraphDTO(String partOfZipFileName, String partOfCSVFileName,
            BVMSZipFileStructureDTO zipFileDTO) {
        BVMSGraphDTO bvmsGraphDTO = null;
        try {
            File file = findZipFileFromS3(bucket, partOfZipFileName, zipFileDTO);
            final ZipFile zipFile = new ZipFile(file.getPath());
            try {
                Enumeration<ZipArchiveEntry> entries = zipFile.getEntries();
                while (entries.hasMoreElements()) {
                    ZipArchiveEntry entry = entries.nextElement();
                    if (matchesDesiredFile(partOfCSVFileName, entry)) {
                        Reader reader = new InputStreamReader(zipFile.getInputStream(entry));
                        bvmsGraphDTO = buildBVMSGraphDTO(unmarshall(reader));
                        break;
                    }
                }
            } finally {
                zipFile.close();
            }
        } catch (FileNotFoundException e) {
            throw new NtssException("ファイルが見つかりません :" + partOfZipFileName, e);
        } catch (IOException e) {
            throw new NtssException("I/O exception occurs during reading zip file", e);
        }
        if (bvmsGraphDTO == null) {
            throw new NtssException("ファイルが見つかりません : " + partOfCSVFileName);
        }
        return bvmsGraphDTO;
    }

    private File getCacheFile(String baseName) {
        Path cacheDirPath = Paths.get(this.cacheDir);
        if (!Files.exists(cacheDirPath)) {
            try {
                Files.createDirectories(cacheDirPath);
            } catch (IOException e) {
                throw new NtssException("I/O exception occurs during creating the cache direction", e);
            }
        }
        return new File(this.cacheDir, baseName);
    }

    private boolean matchesDesiredFile(final String pFileName, final ZipEntry pZipEntry) {
        return !pZipEntry.isDirectory() && pZipEntry.getName().contains(pFileName);
    }

    private File findZipFileFromS3(String bucket, String partOfzipFilePath, BVMSZipFileStructureDTO zipFileNameDTO) {

        bucket = bucket.replace("s3://", "");

        String zipFilePath = "";
        boolean zipFileExsit = false;
        boolean isInRangeTime = false;
        for (S3Object s3ObjectSummary : listObjects(bucket)) {
            String fileName = s3ObjectSummary.key();
            if (fileName.contains(partOfzipFilePath)) {
                zipFileExsit = true;
                String timeFromPath = findTimeInZipFileName(fileName, zipFileNameDTO.getTreatDate());
                if (timeFromPath.compareTo(zipFileNameDTO.getStartTime()) >= 0
                        && timeFromPath.compareTo(zipFileNameDTO.getEndTime()) <= 0) {
                    zipFilePath = fileName;
                    isInRangeTime = true;
                    break;
                }
            }
        }
        if (!zipFileExsit) {
            throw new NtssException("Can not found any zip file that matching with " + partOfzipFilePath);
        }

        if (!isInRangeTime) {
            throw new NtssException(partOfzipFilePath + " is not in (" + zipFileNameDTO.getStartTime() + ","
                    + zipFileNameDTO.getEndTime() + ")");
        }
        String baseName = zipFilePath.replace("/", "_");
        File cacheFile = getCacheFile(baseName);
        try (ResponseInputStream<GetObjectResponse> inputStream = getObjectStream(bucket, zipFilePath);
             ByteArrayOutputStream outputStream = new ByteArrayOutputStream()) {
            byte[] buffer = new byte[1024];
            while (true) {
                int len = inputStream.read(buffer);
                if (len < 0) {
                    break;
                }
                outputStream.write(buffer, 0, len);
            }
            Files.write(cacheFile.toPath(), outputStream.toByteArray());
            return cacheFile;
        } catch (Exception e) {
            throw new NtssException(e.getMessage());
        }
    }

    /**
     * Finds the time in the zip file name.
     *
     * @param fileName
     *            (format:
     *            {データ収集管理番号[可変長]}_{型式コード[3桁]}_{製造番号[7～8桁]}_{データ収集開始年月日[8桁]時分秒[6桁]}_FTP.zip)
     * @param treatDate
     * @return the time in the file name
     */
    private String findTimeInZipFileName(String fileName, String treatDate) {
        int indexOfTreatDate = fileName.indexOf(treatDate);
        return fileName.substring(indexOfTreatDate + LENGHT_OF_DATE, fileName.indexOf("_", indexOfTreatDate));
    }

    private String buildPartOfZipFileName(BVMSZipFileStructureDTO zipFileDTO) {
        return zipFileDTO.getMachineTypeCd() //
                + "_" + zipFileDTO.getComFormatCd() //
                + zipFileDTO.getMachineSerial() //
                + "_" + zipFileDTO.getTreatDate();
    }
  //add FNSI-8360 ljx start
  /**
   * ファイルアップロード
   * @param file　アップロードするファイル
   * @param path　ファイルパス
   * @param ordNo　オーダ番号
   * @param facilityCd　施設コード
   * @throws Exception
   */
  @Transactional
  protected void uploadFileAttachment(MultipartFile file, String path,Long ordNo,String facilityCd) throws Exception {
    String localStore = null;
    String status = null;
    try {
      //sys_system_defineから設定を取得。
      Map<String, String> map = getLocalStoreAndStatus();
      localStore = map.get("localStore");
      status = map.get("status");
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (!StringUtils.isEmpty(facilityCd)) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
      throw e;
    }
    //application.ymlの設定でpathを作成
    String s3BucketInFcd = bvmsBucket + "/" + facilityCd;
    String bvmsPath="";
    if (status.equals("on")) {//ローカルへアップロードするの場合
      String fileLocation = localStore + "/" + s3BucketInFcd + "/" + path;
      bvmsPath = s3BucketInFcd + "/" + path;
      Path filePath = Paths.get(fileLocation);
      byte[] bytes = file.getBytes();
      if (!Files.exists(filePath)) {
        //ローカルへアップロード処理
        Files.createDirectories(filePath.getParent());
        File newFile = new File(filePath.toString());
        newFile.createNewFile();
      }
      Files.write(filePath, bytes);
    } else {//S3へアップロードするの場合

      //新たなファイルに差し替え可能とするのため、古いファイルは削除する
      deleteObject(s3BucketInFcd, path);
      putMultipartObject(s3BucketInFcd, path, file);
    }
    // DB更新（保存したcsvファイルの絶対パスをord_mainに保存）
    this.updateBvmsPath(ordNo,path,facilityCd);


  }
  /**
   * オンプレミス設定の取得
   * @return
   * @throws Exception
   */
  private Map<String, String> getLocalStoreAndStatus() throws Exception {
    String localStore = null;
    String status = null;
    SysSystemDefine data = sysSystemDefineDao.selectOnPremise(CoreConstant.SysSystemDefine.CTL_NO_ON_PREMISE);
    ObjectMapper objectMapper = new ObjectMapper();
    HashMap<String, String> onPremise = objectMapper.readValue(data.getValue(),
      new TypeReference<HashMap<String, String>>() {
      });
    localStore = onPremise.get("path");
    status = onPremise.get("status");
    Map<String, String> mapResult = new HashMap<>();
    mapResult.put("localStore", localStore);
    mapResult.put("status", status);
    return mapResult;
  }

  /**
   *
   * @param filepath　ファイルパス
   * @param filename　ファイル名
   * @param facilityCd　施設コード
   * @return
   * @throws Exception
   */
  private byte[] getFileAttachment(String filepath, String filename,String facilityCd) throws Exception {
    String localStore = null;
    String status = null;
    //DBから取得パスの転換処理。
    String s3BucketInFcd = filepath.replaceFirst("s3://", "");
    try {
      Map<String, String> map = getLocalStoreAndStatus();
      localStore = map.get("localStore");
      status = map.get("status");
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (!StringUtils.isEmpty(facilityCd)) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
      throw e;
    }
    if (status.equals("on")) {//ローカルへアップロードするの場合
      String fileLocation = localStore + "/" + s3BucketInFcd + "/" + filename;
      Path path = Paths.get(fileLocation);
      byte[] content = null;
      content = Files.readAllBytes(path);
      return content;
    } else {//S3へアップロードするの場合

      // レスポンス用データ生成
      try (ResponseInputStream<GetObjectResponse> is = getObjectStream(s3BucketInFcd, filename);
           ByteArrayOutputStream os = new ByteArrayOutputStream();) {
        byte[] buffer = new byte[1024];
        while (true) {
          int len = is.read(buffer);
          if (len < 0) {
            break;
          }
          os.write(buffer, 0, len);
        }
        byte[] content = os.toByteArray();
        return content;
      } catch (Exception e) {
        throw e;
      }
    }
  }

  private List<S3Object> listObjects(String bucket) {
    return s3.listObjectsV2Paginator(ListObjectsV2Request.builder()
        .bucket(bucket)
        .build())
      .contents()
      .stream()
      .toList();
  }

  private ResponseInputStream<GetObjectResponse> getObjectStream(String bucket, String path) {
    return s3.getObject(GetObjectRequest.builder()
        .bucket(bucket)
        .key(path)
        .build());
  }

  private void deleteObject(String bucket, String path) {
    s3.deleteObject(DeleteObjectRequest.builder()
        .bucket(bucket)
        .key(path)
        .build());
  }

  private void putMultipartObject(String bucket, String path, MultipartFile file) throws IOException {
    try (InputStream inputStream = file.getInputStream()) {
      s3.putObject(PutObjectRequest.builder()
          .bucket(bucket)
          .key(path)
          .contentLength(file.getSize())
          .build(),
        RequestBody.fromInputStream(inputStream, file.getSize()));
    }
  }

  /**
   * ord_mainから保存されたパスを取得。
   * @param ordNo オーダ番号
   * @return
   */
  private  Map<String,String> getBvmsPath(Long ordNo){
    //DBからデータを取得。
    OrdMain ordMain = ordMainDao.selectByOrdNo(ordNo);
    Map<String,String> map = new HashMap<String,String>();
    String bvmsPathJsonStr  = "";
    //マップに転換
    if(ordMain != null){
      bvmsPathJsonStr = ordMain.getBvmsPath();
      JSONObject bvmsPathJson = new JSONObject(bvmsPathJsonStr);
      map.put("bucket",bvmsPathJson.get("bucket").toString());
      map.put("csv_filename",bvmsPathJson.get("csv_filename").toString());
    }
    return map;
  }

  /**
   * アップロードファイルのパスを更新(ord_main)
   * @param ordNo オーダ番号
   * @param fileName ファイル名
   * @param facilityCd　施設コード
   */
  private void updateBvmsPath(Long ordNo,String fileName,String facilityCd){

    JSONObject bvmsPathJson = new JSONObject();
    //application.ymlの設定でpathを作成
    bvmsPathJson.put("bucket","s3://"+bvmsBucket+"/"+facilityCd);
    bvmsPathJson.put("csv_filename",fileName);
    String bvmsPathJsonStr = bvmsPathJson.toString();
    //DB更新(ord_main.bvms_path)
    ordMainDao.updateBvmsPath(ordNo,bvmsPathJsonStr);

  }

  /**
   * オーダ番号より施設コード取得
   * @param ordNo　オーダ番号
   * @return
   */
  protected String getFacilityCdByOrdNo(Long ordNo){
    String facilityCd = "0";
    OrdMain ordMain = ordMainDao.selectByOrdNo(ordNo);
    if(ordMain != null){
      facilityCd = ordMain.getFacilityCd();
    }
    return facilityCd;
  }
  //add FNSI-8360 ljx end
}
