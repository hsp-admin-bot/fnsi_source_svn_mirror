package jp.co.nikkiso.ntss.web_api.web.rest.fileIO;

import java.util.ArrayList;
import java.util.Base64;
import java.util.List;

import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.env.Environment;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.SysSystemDefineDao;
import jp.co.nikkiso.ntss.core.entity.SysSystemDefine;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.web_api.service.LogService;
import jp.co.nikkiso.ntss.web_api.service.fileIO.FileIOService;
import jp.co.nikkiso.ntss.web_api.service.fileIO.FileIOService.OnPremiseInfo;
import jp.co.nikkiso.ntss.web_api.service.utils.NumberCtrl;


@RestController
@RequestMapping("")
public class FileIOResource {

  @Autowired
  private LogService logService;

  @Autowired
  private FileIOService fileIOSv;

  @Autowired
  private Environment environment;

  @Autowired
  SysSystemDefineDao sysSystemDefineDao;

  /**
   * ファイルアップロード
   * ・S3にアップロードまたはオンプレミスの指定フォルダ内対象
   *
   * @param multipartFile アップロードファイル
   * @param filePath アップロード先パス(ファイル名を含まない、末尾に"/"を含まない、Base64変換したもの)
   * @return
   */
  @PostMapping("/upload")
  public ResponseEntity<Void> Upload(@RequestParam("file") MultipartFile[] multipartFile, @RequestParam("filePath") String filePath) {

    HttpStatus status = HttpStatus.INTERNAL_SERVER_ERROR;
    EventLogMessage eventLogMessage = new EventLogMessage();

    eventLogMessage.setLogMessage("[ntss-web-api]ファイルアップロード: 受信データ filePath[" + filePath + "]");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);

    if (true == StringUtils.isEmpty(filePath)) {
      // 引数(filePath)が空の場合、処理を実施しない
      // ログ
      eventLogMessage.setLogMessage("[ntss-web-api]ファイルアップロード: アップロード先情報が空のため処理終了");
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
      return new ResponseEntity<>(status);
    }

    // Base64のデータをデコード
    filePath = new String(Base64.getDecoder().decode(filePath));
    eventLogMessage.setLogMessage("[ntss-web-api]ファイルアップロード: 受信データ filePath のBase64デコード結果[" + filePath + "]");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);

    boolean ret = true;
    for (int i = 0; i < multipartFile.length; i++) {

      // S3へファイル転送
      boolean subRet = this.fileIOSv.UploadToS3(multipartFile[i], filePath);
      if (false == subRet) {
        // 1つでも失敗した場合、エラーとしては返す(途中で終了はしない)
        ret = false;
      }
    }
    if (false == ret) {
      return new ResponseEntity<>(status);
    }

    status = HttpStatus.OK;
    return new ResponseEntity<>(status);
  }

  /**
   * ファイル結合
   * ・S3にアップロードされているファイルまたはオンプレミスの指定フォルダ内対象
   *
   * @param filePath 結合対象となる分割ファイルが保存されているフォルダパス(ファイル名を含まない、末尾に"/"を含まない、Base64変換したもの)
   * @param fileName　結合対象ファイル情報([ファイル数 *1][ファイル名 *2][LF(改行コード) *3]・・・ (Base64変換したもの)
   *                 *1：分割されているファイル数(3つの場合は"003"、必ず0埋め3桁)、*2：分割前のファイル名、*3：結合処理対象ファイルが複数ある場合はLF(改行コード)で繋げる)
   * @return
   */
  @PostMapping("/fileJoin")
  public ResponseEntity<Void> FileJoin(@RequestParam("filePath") String filePath, @RequestParam("fileName") String fileName) {

    HttpStatus status = HttpStatus.INTERNAL_SERVER_ERROR;
    EventLogMessage eventLogMessage = new EventLogMessage();

    if (true == StringUtils.isEmpty(filePath) || true == StringUtils.isEmpty(fileName)) {
      // 引数(filePath、fileName)が片方でも空の場合、処理を実施しない
      eventLogMessage.setLogMessage("[ntss-web-api]ファイル結合: 対象ファイル情報が空のため処理終了 filePath[" + filePath + "]、fileName[" + fileName + "]");
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
      return new ResponseEntity<>(status);
    }

    // Base64のデータをデコード
    eventLogMessage.setLogMessage("[ntss-web-api]ファイル結合: 受信データ filePath[" + filePath + "]");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
    eventLogMessage.setLogMessage("[ntss-web-api]ファイル結合: 受信データ fileName[" + fileName + "]");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);

    filePath = new String(Base64.getDecoder().decode(filePath));
    fileName = new String(Base64.getDecoder().decode(fileName));

    eventLogMessage.setLogMessage("[ntss-web-api]ファイル結合: 受信データ filePath のBase64デコード結果[" + filePath + "]");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
    eventLogMessage.setLogMessage("[ntss-web-api]ファイル結合: 受信データ fileName のBase64デコード結果[" + fileName + "]");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);

    // 分割ファイル保存Path
    String fileJoinDir = this.environment.getProperty("fileIO.upload.fileJoinDir");

    // ファイル名情報から結合対象ファイルのリストを作成
    // 区切り文字は"\n"(LF)
    String[] listFilenameData = {};
    if (!StringUtils.isEmpty(fileName)) {
      listFilenameData = fileName.split("\n");
    }

    // 結合対象のリストをDEログとそれ以外に分ける
    List<String> listLogFilenameData = new ArrayList<String>();
    List<String> listOtherFilenameData = new ArrayList<String>();
    for (String filenameData : listFilenameData) {
      // アップされたのがDEログファイルかどうか判定
      //mod #9696 アプリケーションログのパスとファイル名の修正。 zhaoqi 20240403 start
      // ファイル名: DE_施設コード(6桁)_デバイスエッジ番号(2桁)_製造番号(任意の長さ)_作成年月日(8桁).ZIP(分割の場合は末尾に.000～の番号付与)
      //mod 9696 ファイル名の書式変更 00*施設コード(6桁)_DE_製造番号(11桁)_デバイスエッジ番号(2桁)_作成年月日(8桁).ZIP ljg start
//      Boolean isLogFile = filenameData.substring(3).matches("^DE_.{6}_.{2}_.{11}_.{8}.+");
      Boolean isLogFile = filenameData.substring(3).matches("^.{6}_DE_.+_.{2}_.{8}.+");
      //mod 9696 ファイル名の書式変更 ljg end
      //mod #9696 アプリケーションログのパスとファイル名の修正。 zhaoqi 20240403 end
      if (isLogFile) {
        listLogFilenameData.add(filenameData);
      } else {
        listOtherFilenameData.add(filenameData);
      }
    }

    // 戻り値
    boolean isRet = true;

    // DEログファイルのアップロード先を取得
    String logFilepath = "";
    if (listLogFilenameData.size() > 0) {
      // ファイルパス関連情報
      String[] splittedFileName = listLogFilenameData.get(0).split("_");
      //mod 9696 施設の桁修正を取ります ljg start
      String facilityCd = splittedFileName[0].substring(3, 9);
      //String facilityCd = splittedFileName[1];
      //mod 9696 施設の桁修正を取ります ljg start
      // ファイルパス取得
      // 引数uploadPathは無視する
      List<SysSystemDefine> data = sysSystemDefineDao.selectByCtlNo(CoreConstant.SysSystemDefine.DEVICEEDGE_LOG_OUTPUT_PATH);
      if (data.size() > 0) {
        String strJson = data.get(0).getValue();
        JSONObject objJson = new JSONObject(strJson);
        //mod 9696 today差し替えです ljg start
        logFilepath = objJson.getString("path").replaceAll("\\{0\\}", facilityCd).replaceAll("\\{1\\}", "today");
        //mod 9696 today差し替えです ljg end
      }
    }

    // DEログのファイル結合
    // オンプレミス時と同様の処理 アップロード先が異なる
    for (String filenameData : listLogFilenameData) {
      if (filenameData.length() < 4) {
        // 3文字以下の場合はファイル名が存在しないと判断し次へ
        eventLogMessage.setLogMessage("[ntss-web-api]ファイル結合: 結合対象ファイル情報が不足しているので次のファイルへ [" + filenameData + "]");
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
        isRet = false;
        continue;
      }

      // ファイル数取得
      String fileNum = filenameData.substring(0, 3);
      // ファイル名取得
      String filename = filenameData.substring(3);

      eventLogMessage.setLogMessage("[ntss-web-api]ファイル結合: 結合対象ファイル数[" + fileNum + "]、結合対象の分割前ファイル名[" + filename + "]");
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);

      // ファイル数チェック
      int intFileNum = NumberCtrl.ParseNumber(fileNum, "-1", Integer.class);
      if (-1 == intFileNum) {
        // 頭3文字が数値変換できない場合、ファイル数が指定されていないと判断し次へ
        isRet = false;
        eventLogMessage.setLogMessage("[ntss-web-api]ファイル結合: 指定ファイル数が異常 指定ファイル数[" + intFileNum + "]");
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
        continue;
      } else if (intFileNum < 2) {
        // ファイル数が1以下の場合、結合不要と判断し次へ(エラーではない)
        continue;
      }

      // 分割ファイルの結合
      eventLogMessage.setLogMessage("[ntss-web-api]ファイル結合: 分割ファイルの結合実施");
      boolean isJoin = this.fileIOSv.FileJoin(logFilepath, filename, logFilepath);
      //mod 9696 todayフォルダは今日だけ残しておきます ljg start
      if(isJoin == true) {
      this.fileIOSv.UploadCopy(logFilepath);
      }
      //mod 9696 todayフォルダは今日だけ残しておきます ljg end
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
      if (false == isJoin) {
        // 結合に失敗(残分割ファイルは上記処理内で削除実施)
        isRet = false;
        eventLogMessage.setLogMessage("[ntss-web-api]ファイル結合: 分割ファイルの結合処理に失敗 ファイル名[" + filename + "]");
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
        continue;
      }

      // 結合に成功した場合、残っている分割ファイルを削除
      eventLogMessage.setLogMessage("[ntss-web-api]ファイル結合: アップロード先の分割ファイル削除実施");
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
      boolean isDelete = true;
      for (int j = 0; j < intFileNum; j++) {
        boolean isDeleteSub = this.fileIOSv.DeleteFromOnPremise(logFilepath + "/" + filename + "." + String.format("%03d", j));
        if (false == isDeleteSub) {
          // 格納先の分割ファイルの削除失敗
          isDelete = false;
          eventLogMessage.setLogMessage("[ntss-web-api]ファイル結合: 格納先の分割ファイルの削除に失敗 ファイル名[" + filename + "." + String.format("%03d", j) + "]、格納先[" + filePath + "]");
          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
          break;
        }
      }
      // 1つでも削除に失敗した場合
      if (false == isDelete) {
        isRet = false;
        continue;
      }
      // 分割ファイルの削除が完了した場合、分割ファイル情報を記載したファイル「ファイル名.list」を削除
      // この削除処理は失敗してもエラーとはしない(存在しない可能性がある為、以下の実行関数内ではエラーとはなるが)
      this.fileIOSv.DeleteFromOnPremise(logFilepath + "/" + filename + ".list");
    }

    // オンプレミスチェック
    OnPremiseInfo onpremise = fileIOSv.ChkOnPremise();

    // 分割ファイルPath = fileJoinDir + バケットからのパスの配下 (S3保存の場合は「s://」表記が必要になる為、別変数にコピーして処理をする)
    String splitTmpPath = filePath;
    if (splitTmpPath.startsWith("s3://")) {
      splitTmpPath = splitTmpPath.substring("s3://".length());
    }
    String splitFilePath = fileJoinDir + "/" + splitTmpPath;

    // DEログ以外のファイル結合
    if (onpremise.getIsOnPremise()) {
      // オンプレミス
      if (filePath.startsWith("s3://")) {
        filePath = filePath.substring("s3://".length());
      }
      filePath = onpremise.getLocalStore() + "/" + filePath;

      // 以下処理を実施
      // ・ファイル結合
      // ・分割ファイル削除
      for (String filenameData : listOtherFilenameData) {

        if (filenameData.length() < 4) {
          // 3文字以下の場合はファイル名が存在しないと判断し次へ
          eventLogMessage.setLogMessage("[ntss-web-api]ファイル結合: 結合対象ファイル情報が不足しているので次のファイルへ [" + filenameData + "]");
          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
          isRet = false;
          continue;
        }

        // ファイル数取得
        String fileNum = filenameData.substring(0, 3);
        // ファイル名取得
        String filename = filenameData.substring(3);

        eventLogMessage.setLogMessage("[ntss-web-api]ファイル結合: 結合対象ファイル数[" + fileNum + "]、結合対象の分割前ファイル名[" + filename + "]");
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);

        // ファイル数チェック
        int intFileNum = NumberCtrl.ParseNumber(fileNum, "-1", Integer.class);
        if (-1 == intFileNum) {
          // 頭3文字が数値変換できない場合、ファイル数が指定されていないと判断し次へ
          isRet = false;
          eventLogMessage.setLogMessage("[ntss-web-api]ファイル結合: 指定ファイル数が異常 指定ファイル数[" + intFileNum + "]");
          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
          continue;
        } else if (intFileNum < 2) {
          // ファイル数が1以下の場合、結合不要と判断し次へ(エラーではない)
          continue;
        }

        // 分割ファイルの結合
        eventLogMessage.setLogMessage("[ntss-web-api]ファイル結合: 分割ファイルの結合実施");
        boolean isJoin = this.fileIOSv.FileJoin(splitFilePath, filename, filePath);
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
        if (false == isJoin) {
          // 結合に失敗(残分割ファイルは上記処理内で削除実施)
          isRet = false;
          eventLogMessage.setLogMessage("[ntss-web-api]ファイル結合: 分割ファイルの結合処理に失敗 ファイル名[" + filename + "]");
          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
          continue;
        }

        // 結合に成功した場合、残っている分割ファイルを削除
        eventLogMessage.setLogMessage("[ntss-web-api]ファイル結合: 分割ファイル削除実施");
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
        boolean isDelete = true;
        for (int j = 0; j < intFileNum; j++) {
          boolean isDeleteSub = this.fileIOSv.DeleteFromOnPremise(splitFilePath + "/" + filename + "." + String.format("%03d", j));
          if (false == isDeleteSub) {
            // 格納先の分割ファイルの削除失敗
            isDelete = false;
            eventLogMessage.setLogMessage("[ntss-web-api]ファイル結合: 格納先の分割ファイルの削除に失敗 ファイル名[" + filename + "." + String.format("%03d", j) + "]、格納先[" + splitFilePath + "]");
            logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
            break;
          }
        }
        // 1つでも削除に失敗した場合
        if (false == isDelete) {
          isRet = false;
          continue;
        }
        // 分割ファイルの削除が完了した場合、分割ファイル情報を記載したファイル「ファイル名.list」を削除
        // この削除処理は失敗してもエラーとはしない(存在しない可能性がある為、以下の実行関数内ではエラーとはなるが)
        this.fileIOSv.DeleteFromOnPremise(splitFilePath + "/" + filename + ".list");
      }
      // 全部成功した場合のみOK(200)を返す
      if (true == isRet) {
        status = HttpStatus.OK;
      }
      return new ResponseEntity<>(status);

    } else {
      // s3使用

      // 以下処理を実施
      // ・対象ファイルのダウンロード
      // ・ファイル結合
      // ・結合ファイル再アップロード
      // ・分割ファイル削除
      for (int i = 0; i < listOtherFilenameData.size(); i++) {

        if (listOtherFilenameData.get(i).length() < 4) {
          // 3文字以下の場合はファイル名が存在しないと判断し次へ
          eventLogMessage.setLogMessage("[ntss-web-api]ファイル結合: 結合対象ファイル情報が不足しているので次のファイルへ [" + listOtherFilenameData.get(i) + "]");
          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
          isRet = false;
          continue;
        }

        // ファイル数取得
        String fileNum = listOtherFilenameData.get(i).substring(0, 3);
        // ファイル名取得
        String filename = listOtherFilenameData.get(i).substring(3);

        eventLogMessage.setLogMessage("[ntss-web-api]ファイル結合: 結合対象ファイル数[" + fileNum + "]、結合対象の分割前ファイル名[" + filename + "]");
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);

        // ファイル数チェック
        int intFileNum = NumberCtrl.ParseNumber(fileNum, "-1", Integer.class);
        if (-1 == intFileNum) {
          // 頭3文字が数値変換できない場合、ファイル数が指定されていないと判断し次へ
          isRet = false;
          eventLogMessage.setLogMessage("[ntss-web-api]ファイル結合: 指定ファイル数が異常 指定ファイル数[" + intFileNum + "]");
          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
          continue;
        } else if (intFileNum < 2) {
          // ファイル数が1以下の場合、結合不要と判断し次へ(エラーではない)
          continue;
        }

        // 分割ファイルの結合
        eventLogMessage.setLogMessage("[ntss-web-api]ファイル結合: 分割ファイルの結合実施");
        boolean isJoin = this.fileIOSv.FileJoin(splitFilePath, filename, splitFilePath);
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
        if (false == isJoin) {
          // 結合に失敗(残分割ファイルは上記処理内で削除実施)
          isRet = false;
          eventLogMessage.setLogMessage("[ntss-web-api]ファイル結合: 分割ファイルの結合処理に失敗 ファイル名[" + filename + "]");
          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
          continue;
        }

        // 結合完了後、ファイルをアップロード
        eventLogMessage.setLogMessage("[ntss-web-api]ファイル結合: 結合ファイルのアップロード実施");
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
        boolean isUpload = this.fileIOSv.UploadToS3(splitFilePath + "/" + filename, filePath + "/" + filename, true);
        if (false == isUpload) {
          // 再アップロード失敗
          isRet = false;
          eventLogMessage.setLogMessage("[ntss-web-api]ファイル結合: 結合ファイルの再アップロードに失敗 ファイル名[" + filename + "]、アップロード先[" + filePath + "]");
          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
          continue;
        }

        // 結合に成功した場合、残っている分割ファイルを削除
        eventLogMessage.setLogMessage("[ntss-web-api]ファイル結合: 分割ファイル削除実施");
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
        boolean isDelete = true;
        for (int j = 0; j < intFileNum; j++) {
          boolean isDeleteSub = this.fileIOSv.DeleteFromOnPremise(splitFilePath + "/" + filename + "." + String.format("%03d", j));
          if (false == isDeleteSub) {
            // 格納先の分割ファイルの削除失敗
            isDelete = false;
            eventLogMessage.setLogMessage("[ntss-web-api]ファイル結合: 格納先の分割ファイルの削除に失敗 ファイル名[" + filename + "." + String.format("%03d", j) + "]、格納先[" + splitFilePath + "]");
            logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
            break;
          }
        }
        // 1つでも削除に失敗した場合
        if (false == isDelete) {
          isRet = false;
          continue;
        }
        // 分割ファイルの削除が完了した場合、分割ファイル情報を記載したファイル「ファイル名.list」を削除
        // この削除処理は失敗してもエラーとはしない(存在しない可能性がある為、以下の実行関数内ではエラーとはなるが)
        this.fileIOSv.DeleteFromOnPremise(splitFilePath + "/" + filename + ".list");
      }
      // 全部成功した場合のみOK(200)を返す
      if (true == isRet) {
        status = HttpStatus.OK;
      }
      return new ResponseEntity<>(status);
    }
  }
}
