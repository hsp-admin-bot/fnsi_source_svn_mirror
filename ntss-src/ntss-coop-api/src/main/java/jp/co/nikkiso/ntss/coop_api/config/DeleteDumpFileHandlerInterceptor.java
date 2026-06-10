package jp.co.nikkiso.ntss.coop_api.config;

import java.io.File;
import java.io.FilenameFilter;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.servlet.HandlerInterceptor;

import jp.co.nikkiso.ntss.coop_api.service.LogService;
import jp.co.nikkiso.ntss.coop_api.utils.FileUtil;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;

@Component
public class DeleteDumpFileHandlerInterceptor implements HandlerInterceptor {

  // 配信ファイル一時保存フォルダパス取得
  @Autowired
  private FileUtil fileUtil;

  @Autowired
  private LogService logService;

  @Override
  public void afterCompletion (HttpServletRequest request, HttpServletResponse response, Object Handler, Exception ex) throws Exception {
    // 配信処理(/journal/delivery)後の後続処理 (処理が正常終了していたら処理対象ファイルを削除する)
    String ctlNoListStr = response.getHeader("Title");
    if(response.getStatus() == HttpStatus.OK.value() && !StringUtils.isEmpty(ctlNoListStr)) {

      // 配信ファイル一時保存フォルダを取得
      String deliveryJournalTmp = fileUtil.getDistFolderPath();
      Path deliveryJournalTmpPath = Paths.get(deliveryJournalTmp);
      if (Files.exists(deliveryJournalTmpPath)) {
        // 処理ログ出力
        EventLogMessage elm = new EventLogMessage();
        elm.setLogMessage("sys_coop_journal : Delete sent file : Target no : " + ctlNoListStr);
        elm.setInvokeClass(this.getClass().getName());
        logService.log(LogLevel.DEBUG, elm, null, SERVICE_NAME.FNSI, null);

        String[] ctlNoList = ctlNoListStr.split("_");
        for (int i = 0; i < ctlNoList.length; i++) {
          try {
            Integer.parseInt(ctlNoList[i]);
          } catch (NumberFormatException x) {
            // 数値変換できない文字列の場合は処理をスキップ
            continue;
          }
          // 先頭が ctlNoList[i] + "_" のファイルを検索し、削除する
          String ctlNo = ctlNoList[i] + "_";
          FilenameFilter filter = new FilenameFilter() {
            public boolean accept(File file, String str) {
              return str.startsWith(ctlNo);
            }
          };
          // ファイルリスト取得
          File filepath = new File(deliveryJournalTmp);
          File[] listFile = filepath.listFiles(filter);
          for (File fl : listFile) {
            // ファイル削除
            fl.delete();
          }
        }
      }
    }
  }
}