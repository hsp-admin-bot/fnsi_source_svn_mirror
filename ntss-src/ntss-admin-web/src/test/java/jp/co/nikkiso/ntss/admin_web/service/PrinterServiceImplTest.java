package jp.co.nikkiso.ntss.admin_web.service;

import tools.jackson.core.JacksonException;
import jp.co.nikkiso.ntss.admin_web.response.creatingReport.PrinterInfo;
import jp.co.nikkiso.ntss.admin_web.service.print.PrinterService;
import jp.co.nikkiso.ntss.admin_web.service.reportMenu.ReportMenuService;
import jp.co.nikkiso.ntss.api.constant.ReportConstant;
import jp.co.nikkiso.ntss.core.dao.MstPrinterDao;
import jp.co.nikkiso.ntss.core.dao.MstSelectorDao;
import jp.co.nikkiso.ntss.core.entity.MstPrinter;
import jp.co.nikkiso.ntss.core.entity.MstSelector;
import jp.co.nikkiso.ntss.core.entity.custom.ReportMenuSortContainer;
import org.junit.Ignore;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;

import static java.util.Collections.emptyList;
import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;

@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
public class PrinterServiceImplTest {

  /**
   * テスト対象クラス.
   */
  @Autowired
  private PrinterService target;

  /**
   * 処置マスタDaoのMockBean.
   */
  @MockitoBean
  private MstPrinterDao mstPrinterDao;

  /**
   * MstSelectorのMockBean.
   */
  @MockitoBean
  private MstSelectorDao mstSelectorDao;

  /**
   * プリンターマスタEntityの初期化.
   *
   * @return プリンターマスタのEntity
   */
  private List<MstPrinter> createPrinterEntity() {
    return Arrays.asList(
      new MstPrinter() {
        {
          setPrinterCd(1L);
          setFacilityCd("1001");
          setClientKey("clientKey1");
          setPrinterName("name1");
          setDispPrinterName("dispName1");
          setIsDisp("1");
        }
      },
      new MstPrinter() {
        {
          setPrinterCd(2L);
          setFacilityCd("1001");
          setClientKey("clientKey2");
          setPrinterName("name2");
          setDispPrinterName("dispName2");
          setIsDisp("1");
        }
      },
      new MstPrinter() {
        {
          setPrinterCd(3L);
          setFacilityCd("1001");
          setClientKey("clientKey3");
          setPrinterName("name3");
          setDispPrinterName("dispName3");
          setIsDisp("1");
        }
      }
    );
  }

  /**
   * MstSelectorの初期化.
   *
   * @return MstSelecorのitemリスト
   * @throws JacksonException
   */
  private MstSelector createMstSelector() throws JacksonException {
    List<MstSelector.Item> items = Arrays.asList(
      new MstSelector.Item() {{
        setCode(1L);
        setName("name1");
      }},
      new MstSelector.Item() {{
        setCode(3L);
        setName("name3");
      }},
      new MstSelector.Item() {{
        setCode(2L);
        setName("name2");
      }}
    );

    MstSelector.OrderSettings orderSettings = new MstSelector.OrderSettings();
    orderSettings.setItems(items);

    MstSelector mstSelector = new MstSelector();
    mstSelector.setFacilityCd("1001");
    mstSelector.setMasterPhysicalName("mst_printer");
    mstSelector.setOrderSettings(orderSettings);

    return mstSelector;
  }

  /**
   * MstSelectorの初期化（データなし）.
   * @return MstSelecorのitemリスト
   * @throws JacksonException
   */
  private MstSelector createMstSelectorNotData() throws JacksonException {
    List<MstSelector.Item> items = emptyList();

    MstSelector.OrderSettings orderSettings = new MstSelector.OrderSettings();
    orderSettings.setItems(items);

    MstSelector mstSelector = new MstSelector();
    mstSelector.setFacilityCd("9999");
    mstSelector.setMasterPhysicalName("mst_printer");
    mstSelector.setOrderSettings(orderSettings);

    return mstSelector;
  }

  /**
   * getPrinterInfos()の検証.
   *
   * 条件：施設コードに該当するプリンターマスタが存在する
   * 結果：プリンタ情報が返却されること
   * @throws JacksonException
   */
  @Test
  public void test_getPrinterInfos_成功_プリンターマスタが存在する() throws JacksonException {
    // 事前準備
    final String facilityCd = "1001";
    final String tableName = "mst_printer";

    List<MstPrinter> mstPrinters = createPrinterEntity();

    // Mock化
    given(mstPrinterDao.selectByFacilityCd(facilityCd)).willReturn(mstPrinters);
    given(mstSelectorDao.selectByName(facilityCd, tableName)).willReturn(createMstSelector());

    // 実行
    List<PrinterInfo> result = target.getPrinterInfos(facilityCd);

    // 検証
    verify(mstPrinterDao, times(1)).selectByFacilityCd(anyString());
    verify(mstSelectorDao, times(1)).selectByName(facilityCd, tableName);

    // assert
    assertThat(result).isNotNull();
    assertThat(result).hasSize(3);

    assertThat(result.get(0).getPrinterCd()).isEqualTo(mstPrinters.get(0).getPrinterCd());
    assertThat(result.get(0).getPrinterName()).isEqualTo(mstPrinters.get(0).getPrinterName());
    assertThat(result.get(0).getDispPrinterName()).isEqualTo(mstPrinters.get(0).getDispPrinterName());

    assertThat(result.get(1).getPrinterCd()).isEqualTo(mstPrinters.get(2).getPrinterCd());
    assertThat(result.get(1).getPrinterName()).isEqualTo(mstPrinters.get(2).getPrinterName());
    assertThat(result.get(1).getDispPrinterName()).isEqualTo(mstPrinters.get(2).getDispPrinterName());

    assertThat(result.get(2).getPrinterCd()).isEqualTo(mstPrinters.get(1).getPrinterCd());
    assertThat(result.get(2).getPrinterName()).isEqualTo(mstPrinters.get(1).getPrinterName());
    assertThat(result.get(2).getDispPrinterName()).isEqualTo(mstPrinters.get(1).getDispPrinterName());
  }

  /**
   * getPrinterInfos()の検証.
   *
   * 条件：施設コードに該当するプリンターマスタが存在しない
   * 結果：空のリストが返却されること
   * @throws JacksonException
   */
  @Test
  public void test_getPrinterInfos_成功_プリンターマスタが存在しない() throws JacksonException {
    // 事前準備
    final String facilityCd = "9999";
    final String tableName = "mst_printer";

    // Mock化
    given(mstPrinterDao.selectByFacilityCd(facilityCd)).willReturn(emptyList());
    given(mstSelectorDao.selectByName(facilityCd, tableName)).willReturn(createMstSelectorNotData());

    // 実行
    List<PrinterInfo> result = target.getPrinterInfos(facilityCd);

    // 検証
    assertThat(result).isNotNull();
    assertThat(result).hasSize(0);

    verify(mstPrinterDao, times(1)).selectByFacilityCd(anyString());
    verify(mstSelectorDao, times(0)).selectByName(facilityCd, tableName);
  }

  // 単患者帳票及び複数患者帳票のサーバサイドデバック用に作成
  // ※プログラム修正、動作確認を行う際に時間を要する為
  // testを実行する時に使用するapplication.ymlのDB接続先を変更する.
  @Autowired
  private ReportMenuService reportMenuService;

  /**
   * 複数患者帳票のデバック用関数
   * @throws Exception
   */
  @Test
  @Ignore
  public void test_複数患者帳票() throws Exception {
    // 事前準備
    Long reportCd = 14L;
    String facilityCd = "009999";
    Integer reportClass = ReportConstant.ReportClass.MULTIPLE_PATIENT_REPORT;
    List<Long> patIds = Arrays.asList(6L, 7L, 8L);
    // 帳票処理に渡すためのパラメータ生成
    ReportMenuSortContainer reportMenuSortContainer = new ReportMenuSortContainer();
    reportMenuSortContainer.setPatIds(patIds);
    reportMenuSortContainer.setFromDate("20010101");
    reportMenuSortContainer.setToDate("20200401");
    reportMenuSortContainer.setFacilityCd(facilityCd);
    reportMenuSortContainer.setReportCd(reportCd);
    reportMenuSortContainer.setReportClass(reportClass);
    reportMenuSortContainer.setSortCondition(Collections.EMPTY_LIST);
    reportMenuSortContainer.setRegOrderClassList(Collections.EMPTY_LIST);
    reportMenuSortContainer.setIsDialysisDate(true);
    // 実行
    String result = reportMenuService.getHtmlReportSorted(reportMenuSortContainer, 1L, "");
    System.out.println(result);
  }

  /**
   * 単患者帳票のデバック用関数
   * @throws Exception
   */
  @Test
  @Ignore
  public void test_単患者帳票() throws Exception {
    // 事前準備
    Long patId = 6L;
    Long reportCd = 8L;
    String facilityCd = "009999";
    Integer reportClass = ReportConstant.ReportClass.ONE_PATIENT_REPORT;
    List<Long> patIds = Arrays.asList(patId);
    // 帳票処理に渡すためのパラメータ生成
    ReportMenuSortContainer reportMenuSortContainer = new ReportMenuSortContainer();
    reportMenuSortContainer.setPatIds(patIds);
    reportMenuSortContainer.setFromDate("20010101");
    reportMenuSortContainer.setToDate("20200401");
    reportMenuSortContainer.setFacilityCd(facilityCd);
    reportMenuSortContainer.setReportCd(reportCd);
    reportMenuSortContainer.setReportClass(reportClass);
    reportMenuSortContainer.setSortCondition(Collections.EMPTY_LIST);
    reportMenuSortContainer.setRegOrderClassList(Collections.EMPTY_LIST);
    reportMenuSortContainer.setIsDialysisDate(true);
    // 実行
    String result = reportMenuService.getHtmlReportSorted(reportMenuSortContainer, 1L, "");
    System.out.println(result);
  }
}
