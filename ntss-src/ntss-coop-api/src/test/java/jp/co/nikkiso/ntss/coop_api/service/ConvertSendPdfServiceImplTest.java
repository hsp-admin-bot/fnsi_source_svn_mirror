package jp.co.nikkiso.ntss.coop_api.service;

import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.CoreMatchers.nullValue;
import static org.junit.Assert.assertThat;
import static org.junit.Assert.fail;
import static org.mockito.BDDMockito.doReturn;

import java.util.HashMap;
import java.util.Map;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.bean.override.mockito.MockitoSpyBean;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.coop_api.utils.FileUtil;
import jp.co.nikkiso.ntss.core.dao.SysCoopJournalDao;
import jp.co.nikkiso.ntss.core.entity.SysCoopJournal;
import jp.co.nikkiso.ntss.core.exception.NtssException;

@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
@Sql("classpath:resource.script/ConvertSendPdfServiceImplTest/ConvertSendPdfServiceImplTest.db5.before.sql")
public class ConvertSendPdfServiceImplTest extends BaseServiceTest {
  @MockitoSpyBean
  ConvertSendPdfServiceImpl service;
  @MockitoSpyBean
  ConvertSendCommonServiceImpl commonServiceImpl;
  @Autowired
  SysCoopJournalDao sysCoopJournalDao;
  @MockitoSpyBean
  FileUtil fileUtil;

  /**
   * 送信変換のPDF処理
   * レポート対象の設定がされていない場合エラー
   * */
  @Test
  public void 異常系_PDFなのにレポート対象でない場合はエラー() {
    String facilityCd = "TEST01";
    String coopCd = "rep_dial";
    String coopCdIndex = "pdf";
    SysCoopJournal journal = sysCoopJournalDao.select(facilityCd, coopCd, coopCdIndex, "C", "S");

    // レポート対象外とする
    doReturn(false).when(commonServiceImpl).isReport(journal);

    try {
      service.createTelegram(journal);
      fail("エラー想定のためここには到達しない");
    } catch (NtssException e) {
      assertThat(e.getMessage(), is("対象の電文種別はレポート対象ではありません。coop_cd:[rep_dial]"));
    }
  }

  /**
   * 送信変換のPDF処理
   * レポート対象の設定がされていない場合エラー
   * */
  @Test
  public void 異常系_PDFファイル名が取得できない場合はエラー() {
    String facilityCd = "TEST01";
    String coopCd = "rep_dial";
    String coopCdIndex = "pdf";
    SysCoopJournal journal = sysCoopJournalDao.select(facilityCd, coopCd, coopCdIndex, "C", "S");

    // レポート対象外とする
    doReturn(true).when(commonServiceImpl).isReport(journal);
    // ファイル名の返却
    doReturn(fileErrorName()).when(commonServiceImpl).getFileNames(journal);

    try {
      service.createTelegram(journal);
      fail("エラー想定のためここには到達しない");
    } catch (NtssException e) {
      assertThat(e.getMessage(), is("ファイル名が取得できませんでした。"));
    }
  }

  /**
   * 送信変換のPDF処理
   * dumpPathのファイル名が更新されること
   * */
  @Test
  public void 正常系_ジャーナルの値が更新されること() {
    String facilityCd = "TEST01";
    String coopCd = "rep_dial";
    String coopCdIndex = "pdf";
    SysCoopJournal journal = sysCoopJournalDao.select(facilityCd, coopCd, coopCdIndex, "C", "S");

    // レポート対象とする
//    doReturn(true).when(commonServiceImpl).isReport(any());
    // ファイル名の返却
    doReturn(fileName()).when(commonServiceImpl).getFileNames(journal);

    try {
      service.createTelegram(journal);
      assertThat(journal.getDumpPath(), is("pdfname.pdf"));
      assertThat(journal.getDump(), nullValue());
    } catch (NtssException e) {
      fail("エラー想定のためここには到達しない");
    }
  }

  /** ファイル名(エラー) */
  private Map<String, String> fileErrorName() {
    Map<String, String> map = new HashMap<>();
    map.put("pdfName", "");
    map.put("dumpName", "");
    map.put("compressionName", "");
    return map;
  }

  /** ファイル名 */
  private Map<String, String> fileName() {
    Map<String, String> map = new HashMap<>();
    map.put("pdfName", "pdfname.pdf");
    map.put("dumpName", "");
    map.put("compressionName", "");
    return map;
  }
}
