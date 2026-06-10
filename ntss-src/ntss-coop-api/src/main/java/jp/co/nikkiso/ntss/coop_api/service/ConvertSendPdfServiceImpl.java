package jp.co.nikkiso.ntss.coop_api.service;

import java.util.Map;

import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import jp.co.nikkiso.ntss.coop_api.service.ConvertSendCommonServiceImpl.FileNames;
import jp.co.nikkiso.ntss.coop_api.utils.FileUtil;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.entity.SysCoopJournal;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;

@Service
public class ConvertSendPdfServiceImpl implements ConvertSendByFormatService {

  @Autowired
  ConvertSendCommonService convertSendCommonService;

  @Autowired
  private FileUtil fileUtil;

  @Autowired
  private LogService logService;

// add 2022-11-08 bug #7113 rep_dial連携の処理タイミングがずれる 孫 start
  @Autowired
  private JournalService journalService;
// add 2022-11-08 bug #7113 rep_dial連携の処理タイミングがずれる 孫 end

  /** レポートファイル一時出力フォルダ */
  @Value("${ntss.report.createJournalTmp}")
  private String createJournalTmp;

  @Override
  public void createTelegram(SysCoopJournal journal) {
// add 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
    String coopVersion = StringUtils.isEmpty(journal.getCoopVersion()) ? "" : journal.getCoopVersion();
// add 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

    // 電文種別にレポート設定がされていない場合エラー
    if (!convertSendCommonService.isReport(journal)) {
// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//      String error = String.format("対象の電文種別はレポート対象ではありません。coop_cd:[%s]", journal.getCoopCd());
      String error = String.format("対象の電文種別はレポート対象ではありません。coop_cd:[%s], coop_version:[%s]",
        journal.getCoopCd(), coopVersion);
// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
      outputErrorLog(journal.getFacilityCd(), error);
      throw new NtssException(error);
    }

// add 2022-11-08 bug #7113 rep_dial連携の処理タイミングがずれる 孫 start
    // 帳票作成待ちデータか
    //Long reportCd = journal.getReportCd();
    String dumpPath = journal.getDumpPath();
    // mod #12299 【因島】NKK連携 rep_dial pdfのana_resuletがタイムアウトによりE1でエラーとなりPDFの送信ができないことがある 吉 start
    // if (reportCd == null && StringUtils.isEmpty(dumpPath)) {
    if (StringUtils.isEmpty(dumpPath)) {
      // mod #12299 【因島】NKK連携 rep_dial pdfのana_resuletがタイムアウトによりE1でエラーとなりPDFの送信ができないことがある 吉 end
      // 帳票作成待ちデータの場合、帳票データを作成する
      journal = journalService.createJournalReportDump(journal);
    }
// add 2022-11-08 bug #7113 rep_dial連携の処理タイミングがずれる 孫 end

    if (!StringUtils.isEmpty(journal.getDumpPath())) {
      // ファイル名を取得
      Map<String, String> fileNames = convertSendCommonService.getFileNames(journal);

      String pdfName = fileNames.get(FileNames.PDF_NAME.getKey());
      if (StringUtils.isEmpty(pdfName)) {
        String error = "ファイル名が取得できませんでした。";
        outputErrorLog(journal.getFacilityCd(), error);
        throw new NtssException(error);
      }

      // PDFファイル名を変更
      String journalCtlNo = String.valueOf(journal.getCtlNo()) + "_";
      fileUtil.renameFile(journal.getFacilityCd(), createJournalTmp, journalCtlNo + journal.getDumpPath(), journalCtlNo + pdfName);

      // PDFファイルを配信用フォルダに移動
      String deliveryJournalTmp = fileUtil.getDistFolderPath();
      fileUtil.moveFile(journal.getFacilityCd(), createJournalTmp, deliveryJournalTmp, journalCtlNo + pdfName);

      // 電文パスに設定
      journal.setDumpPath(pdfName);

      // 配信時に取得させるため、dumpにnullにする
      journal.setDump(null);
    }
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
   * エラーログ出力
   *
   * @param facilityCd 施設コード
   * @param message ログメッセージ
   */
  private void outputErrorLog(String facilityCd, String message) {
    outputLog(LogLevel.ERROR, facilityCd, message);
  }
}
