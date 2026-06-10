package jp.co.nikkiso.ntss.api.service.utils;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

import jp.co.nikkiso.ntss.api.service.LogService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

/**
 * 一時ファイル作成サービス
 */
@Service
public class TmpFileServiceImpl implements TmpFileService {

  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
  @Autowired
  private LogService logService;
// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end

  /**
   * {@inheritDoc}
   */
  @Override
  public Path createTmpDirectoryAndFile(String dir, String prefix, String suffix) throws Exception {
    try {
      // ディレクトリの指定がなかった場合
      if (StringUtils.isEmpty(dir)) {
        return Files.createTempFile(prefix, suffix);
      }
      Path tempDir = Paths.get(dir);
      if (!Files.exists(tempDir)) {
        // キャッシュディレクトリがなければ作成
        Files.createDirectories(tempDir);
      }
      return Files.createTempFile(tempDir, prefix, suffix);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
      throw e;
    }
  }
}
