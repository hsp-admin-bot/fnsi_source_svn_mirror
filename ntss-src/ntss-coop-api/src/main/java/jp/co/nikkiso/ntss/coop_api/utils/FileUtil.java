package jp.co.nikkiso.ntss.coop_api.utils;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.file.FileVisitResult;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.SimpleFileVisitor;
import java.nio.file.StandardCopyOption;
import java.nio.file.attribute.BasicFileAttributes;
import java.util.HashMap;
import java.util.List;
import org.apache.commons.compress.archivers.tar.TarArchiveEntry;
import org.apache.commons.compress.archivers.tar.TarArchiveOutputStream;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.coop_api.service.LogService;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.SysSystemDefineDao;
import jp.co.nikkiso.ntss.core.entity.SysSystemDefine;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;

/**
 * ファイル操作処理をまとめたユーティリティクラス
 */
@Component
public class FileUtil {

  /** システム設定のDaoインタフェース */
  @Autowired
  private SysSystemDefineDao sysSystemDefineDao;

  @Autowired
  private LogService logService;

  /**
   * システム設定のcoop-api配信ファイル保持フォルダパスを取得
   *
   * @return 配信ファイル保持フォルダパス
   */
  public String getDistFolderPath() {
    SysSystemDefine systemDefine = sysSystemDefineDao.selectOnPremise(CoreConstant.SysSystemDefine.COOPAPI_DIST_FOLDER_PATH);
    String distFolderPath = null;
    try {
      ObjectMapper objectMapper = new ObjectMapper();
      HashMap<String, String> distFolder = objectMapper.readValue(systemDefine.getValue(), new TypeReference<HashMap<String, String>>(){});
      distFolderPath = distFolder.get("path");
    } catch (IOException e) {
      outputDebugLog(null, "parse error -- distFolder : " + systemDefine.getValue());
      throw new NtssException("システム設定のオンプレミス設定のパースに失敗しました。");
    }
    return distFolderPath;
  }

  /**
   * ファイル名変更 (作業ディレクトリ内の指定ファイルのファイル名を変更する)
   *
   * @param facilityCd 施設コード
   * @param tmpDir 作業ディレクトリ
   * @param srcName 変更前ファイル名
   * @param destName 変更後ファイル名
   * @return 変更結果 (正常終了：true)
   */
  public boolean renameFile(String facilityCd, String tmpDir, String srcName, String destName) {

    Path srcFilePath = Paths.get(tmpDir, srcName);
    Path destFilePath = Paths.get(tmpDir, destName);
    outputDebugLog(facilityCd, String.format("file.rename -- src:[%s] => dest:[%s]", srcFilePath.toString(), destFilePath.toString()));

    // 変更前のファイルの存在チェック
    if (!Files.exists(srcFilePath)) {
      // 作業対象のファイルが存在しない
      outputDebugLog(facilityCd, "file not exists. path:" + srcFilePath.toString());
      throw new NtssException("ファイルが存在しません。path:[" + srcFilePath.toString() + "]");
    }

    // ファイル名変更
    File srcFile = srcFilePath.toFile();
    File destFile = destFilePath.toFile();
    srcFile.renameTo(destFile);
    return true;
  }

  /**
   * ファイル移動
   *
   * @param facilityCd 施設コード
   * @param srcDir 移動前ディレクトリ
   * @param destDir 移動先ディレクトリ
   * @param targetFile 移動するファイル名
   * @return 移動結果 (正常終了：true)
   */
  public boolean moveFile(String facilityCd, String srcDir, String destDir, String targetFile) {

    Path srcFilePath = Paths.get(srcDir, targetFile);
    Path destFilePath = Paths.get(destDir, targetFile);
    outputDebugLog(facilityCd, String.format("file.move -- srcFilePath:[%s] => destFilePath:[%s]", srcFilePath.toString(), destFilePath.toString()));

    // 移動前のファイルの存在チェック
    if (!Files.exists(srcFilePath)) {
      outputDebugLog(facilityCd, "file not exists. path:" + srcFilePath.toString());
      throw new NtssException("ファイルが存在しません。path:[" + srcFilePath.toString() + "]");
    }

    try {
      // 移動先ディレクトリの存在チェック
      if (!Files.exists(destFilePath.getParent())) {
        // 移動先ディレクトリを作成
        Files.createDirectories(destFilePath.getParent());
      }
      // ファイル移動
      Files.move(srcFilePath, destFilePath, StandardCopyOption.REPLACE_EXISTING);
    } catch (IOException e) {
      // ファイル移動失敗
      outputDebugLog(facilityCd, "file.move failure. from:" + srcFilePath.toString() + " to:" + destFilePath.toString());
      throw new NtssException("ファイル移動に失敗しました。");
    }
    return true;
  }

  /**
   * ファイルの作成
   *
   * @param facilityCd 施設コード
   * @param outPutDir 出力先ディレクトリパス
   * @param fileName 作成ファイル名
   * @param value 出力対象
   * @param encording エンコード
   * @return 移動結果 (正常終了：true)
   */
  public boolean writeFile(String facilityCd, String outPutDir, String fileName, String value, String encording) {

    Path path = Paths.get(outPutDir, fileName);
    try {
      // ファイル作成先ディレクトリの存在チェック
      if (!Files.exists(path.getParent())) {
        // ファイル作成先ディレクトリを作成
        Files.createDirectories(path.getParent());
      }
      Files.write(path, value.getBytes(encording));
    } catch (IOException e) {
      outputDebugLog(facilityCd, "file write failure. path:" + path.toString());
      throw new NtssException("ファイル作成に失敗しました。");
    }
    return false;
  }

  /**
   * フォルダの作成
   *
   * @param facilityCd 施設コード
   * @param outPutDir 出力先ディレクトリパス
   * @return 作成結果 (正常終了：true)
   */
  public boolean createTempDirectorie(String facilityCd, String outPutDir) {

    Path path = Paths.get(outPutDir);
    try {
      // ファイル作成先ディレクトリの存在チェック
      if (!Files.exists(path)) {
        Files.createDirectories(path);
      }
    } catch (IOException e) {
      outputDebugLog(facilityCd, "create directories failure. path:" + path.toString());
      throw new NtssException("フォルダ作成に失敗しました。");
    }
    return true;
  }

  /**
   * 拡張子の削除
   *
   * @param path      ディレクトリパス
   * @return ディレクトリパスから拡張子を除いたString
   */
  public String removeExtension(String path) {
    if (path == null || path.isEmpty()) {
      return path; // null または空文字の場合はそのまま返す
    }

    int lastSeparatorIndex = path.lastIndexOf("/");
    int lastDotIndex = path.lastIndexOf(".");

    // ドットがスラッシュ以降に存在する場合のみ拡張子を削除
    if (lastDotIndex > lastSeparatorIndex) {
      return path.substring(0, lastDotIndex);
    }

    // 拡張子がない場合はそのまま返す
    return path;
  }

  /**
   * tar にまとめる
   *
   * @param facilityCd 施設コード
   * @param outPutDir 出力先ディレクトリパス
   * @param fileName ファイル名
   * @param fileList 対象ファイル
   */
  public void compressTar(String facilityCd, String outPutDir, String compressName, List<String> fileList) {
    String archive = Paths.get(outPutDir, compressName).toString();
    // アーカイブの作成
    try (
      FileOutputStream fos = new FileOutputStream(archive);
      TarArchiveOutputStream taos = new TarArchiveOutputStream(fos)) {

      // 入力ファイル数だけエントリーを追加
      for (String fileName : fileList) {

        // 入力ファイルを取得
        File file = Paths.get(outPutDir, fileName).toFile();
        TarArchiveEntry entry = new TarArchiveEntry(file, fileName);
        taos.setLongFileMode(TarArchiveOutputStream.LONGFILE_POSIX);
        taos.putArchiveEntry(entry);

        try (
          FileInputStream fis = new FileInputStream(file);
          BufferedInputStream bis = new BufferedInputStream(fis)) {

          // エントリーの中身を出力
          int size = 0;
          byte[] buf = new byte[1024];
          while ((size = bis.read(buf)) > 0) {
            taos.write(buf, 0, size);
          }
        }
        // エントリー１つ分を出力終了
        taos.closeArchiveEntry();
      }
    } catch (FileNotFoundException e) {
      outputDebugLog(facilityCd, "file not found!");
      throw new NtssException("ファイルが存在しません。", e);
    } catch (IOException e) {
      outputDebugLog(facilityCd, "compress tar failure");
      throw new NtssException("tarへの変換に失敗しました。", e);
    }
    // 一時ファイルを削除する
    for (String fileName : fileList) {
      File tempFile = Paths.get(outPutDir, fileName).toFile();
      tempFile.delete();
    }
  }

  public void deleteDirectoryRecursively(String directory) throws IOException {
    // ファイルとディレクトリを再帰的に処理
    Path path = Paths.get(directory);

    Files.walkFileTree(path, new SimpleFileVisitor<>() {
      @Override
      public FileVisitResult visitFile(Path file, BasicFileAttributes attrs) throws IOException {
        // ファイルを削除
        Files.delete(file);
        return FileVisitResult.CONTINUE;
    }

      @Override
      public FileVisitResult postVisitDirectory(Path dir, IOException exc) throws IOException {
        // ディレクトリを削除
        Files.delete(dir);
        return FileVisitResult.CONTINUE;
      }
    });
  }

  /**
   * ログ出力
   *
   * @param level {@link LogLevel} ログレベル
   * @param facilityCd 施設コード
   * @param message ログメッセージ
   */
  private void outputLog(LogLevel level, String facilityCd, String message) {
    EventLogMessage elm = new EventLogMessage();
    elm.setFacilityCd(facilityCd);
    elm.setLogMessage(message);
    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
    elm.setInvokeClass(this.getClass().getName());
    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
    logService.log(level, elm, null, SERVICE_NAME.FNSI, null);
  }

  /**
   * デバッグログ出力
   *
   * @param facilityCd 施設コード
   * @param message ログメッセージ
   * */
  private void outputDebugLog(String facilityCd, String message) {
    outputLog(LogLevel.DEBUG, facilityCd, message);
  }

}
