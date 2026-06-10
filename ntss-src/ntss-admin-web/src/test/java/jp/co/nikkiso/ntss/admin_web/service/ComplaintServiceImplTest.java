package jp.co.nikkiso.ntss.admin_web.service;

import static java.util.Collections.emptyList;
import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.BDDMockito.any;
import static org.mockito.BDDMockito.given;
import static org.mockito.BDDMockito.times;
import static org.mockito.BDDMockito.verify;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.Arrays;
import java.util.List;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.ArgumentCaptor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import com.fasterxml.jackson.core.JsonProcessingException;

import jp.co.nikkiso.ntss.core.dao.MstCompTreatmentDao;
import jp.co.nikkiso.ntss.core.dao.MstComplaintDao;
import jp.co.nikkiso.ntss.core.dao.MstSelectorDao;
import jp.co.nikkiso.ntss.core.entity.MstCompTreatment;
import jp.co.nikkiso.ntss.core.entity.MstComplaint;
import jp.co.nikkiso.ntss.core.entity.MstSelector;
import jp.co.nikkiso.ntss.core.entity.MstSelector.Item;
import jp.co.nikkiso.ntss.core.entity.MstSelector.OrderSettings;

@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
public class ComplaintServiceImplTest {

  /**
   * 愁訴処置マスタサービス.
   */
  @Autowired
  private ComplaintService complaintService;

  /**
   * 愁訴マスタDaoのMockBean.
   */
  @MockBean
  private MstComplaintDao mstComplaintDao;

  /**
   * 処置マスタDaoのMockBean.
   */
  @MockBean
  private MstCompTreatmentDao mstCompTreatmentDao;

  /**
   * MstSelectorのMockBean.
   */
  @MockBean
  private MstSelectorDao mstSelectorDao;

  /**
   * 愁訴マスタEntityの初期化.
   * @return 愁訴マスタのEntity
   */
  private List<MstComplaint> createComplaintEntity() {
    return Arrays.asList(
      new MstComplaint() {{
        setComplaintCd(1);
        setComplaintName("Name1");
        setFacilityCd("1001");
        setIsDel("0");
        setIsDisp("1");
      }},
      new MstComplaint() {{
        setComplaintCd(2);
        setComplaintName("Name2");
        setFacilityCd("1001");
        setIsDel("0");
        setIsDisp("0");
      }},
      new MstComplaint() {{
        setComplaintCd(3);
        setComplaintName("Name3");
        setFacilityCd("1001");
        setIsDel("0");
        setIsDisp("0");
      }},
      new MstComplaint() {{
        setComplaintCd(4);
        setComplaintName("Name4");
        setFacilityCd("1001");
        setIsDel("0");
        setIsDisp("1");
      }},
      new MstComplaint() {{
        setComplaintCd(5);
        setComplaintName("Name5");
        setFacilityCd("1001");
        setIsDel("0");
        setIsDisp("1");
      }}
    );
  }

  /**
   * MstSelectorの初期化（データあり）.
   * @param tableName テーブル物理名
   * @return
   * @throws JsonProcessingException
   */
  private MstSelector createMstSelectorContainsSelector(String tableName) throws JsonProcessingException {
   List<Item> items = Arrays.asList(
       new Item() {{
         setCode(1L);
         setName("Name1");
       }},
       new Item() {{
         setCode(5L);
         setName("Name5");
       }},
       new Item() {{
         setCode(4L);
         setName("Name4");
       }}
   );

   OrderSettings orderSettings = new OrderSettings();
   orderSettings.setItems(items);

    MstSelector mstSelector = new MstSelector();
    mstSelector.setFacilityCd("1001");
    mstSelector.setMasterPhysicalName(tableName);
    mstSelector.setOrderSettings(orderSettings);

    return mstSelector;
  }

  /**
   * MstSelectorの初期化（データなし）.
   * @param tableName テーブル物理名
   * @return
   * @throws JsonProcessingException
   */
  private MstSelector createMstSelectorNotContainsSelector(String tableName) throws JsonProcessingException {
    List<Item> items = emptyList();

    OrderSettings orderSettings = new OrderSettings();
    orderSettings.setItems(items);

     MstSelector mstSelector = new MstSelector();
     mstSelector.setFacilityCd("1001");
     mstSelector.setMasterPhysicalName(tableName);
     mstSelector.setOrderSettings(orderSettings);

     return mstSelector;
   }

  /**
   * MstSelectorの初期化（更新テスト前用）.
   * @param tableName テーブル物理名
   * @return
   * @throws JsonProcessingException
   */
  private MstSelector createMstSelectorForUpdateBefore(String tableName) throws JsonProcessingException {
   List<Item> items = Arrays.asList(
       new Item() {{
         setCode(1L);
         setName("Name1");
       }}
   );

   OrderSettings orderSettings = new OrderSettings();
   orderSettings.setItems(items);

    MstSelector mstSelector = new MstSelector();
    mstSelector.setFacilityCd("1001");
    mstSelector.setMasterPhysicalName(tableName);
    mstSelector.setOrderSettings(orderSettings);

    return mstSelector;
  }

  /**
   * getAllMstComplaintsの検証.
   *
   * 条件：愁訴マスタと並び順管理マスタに該当のデータがある
   * 結果：施設コードに該当する愁訴マスタが取得できること（mst_selector登録順+未登録データ）
   * @throws JsonProcessingException
   */
  @Test
  public void test_getAllMstComplaints_正常_愁訴マスタと並び順管理マスタに該当のデータがある() throws JsonProcessingException {
    // arrange
    List<MstComplaint> mstComplaints = createComplaintEntity();

    final String facilityCd = "1001";
    given(mstComplaintDao.selectAllByFacilityCd(facilityCd))
      .willReturn(mstComplaints);

    given(mstSelectorDao.selectByName(facilityCd, "mst_complaint"))
      .willReturn(createMstSelectorContainsSelector("mst_complaint"));

    // action
    final List<MstComplaint> result = complaintService.getAllMstComplaints(facilityCd);

    // assert
    assertThat(result).isNotNull();
    assertThat(result).hasSize(5);
    assertThat(result.get(0).getComplaintCd()).isEqualTo(mstComplaints.get(0).getComplaintCd());
    assertThat(result.get(0).getComplaintName()).isEqualTo(mstComplaints.get(0).getComplaintName());
    assertThat(result.get(0).getIsDel()).isEqualTo(mstComplaints.get(0).getIsDel());
    assertThat(result.get(0).getIsDisp()).isEqualTo(mstComplaints.get(0).getIsDisp());

    assertThat(result.get(1).getComplaintCd()).isEqualTo(mstComplaints.get(4).getComplaintCd());
    assertThat(result.get(1).getComplaintName()).isEqualTo(mstComplaints.get(4).getComplaintName());
    assertThat(result.get(1).getIsDel()).isEqualTo(mstComplaints.get(4).getIsDel());
    assertThat(result.get(1).getIsDisp()).isEqualTo(mstComplaints.get(4).getIsDisp());

    assertThat(result.get(2).getComplaintCd()).isEqualTo(mstComplaints.get(3).getComplaintCd());
    assertThat(result.get(2).getComplaintName()).isEqualTo(mstComplaints.get(3).getComplaintName());
    assertThat(result.get(2).getIsDel()).isEqualTo(mstComplaints.get(3).getIsDel());
    assertThat(result.get(2).getIsDisp()).isEqualTo(mstComplaints.get(3).getIsDisp());

    assertThat(result.get(3).getComplaintCd()).isEqualTo(mstComplaints.get(1).getComplaintCd());
    assertThat(result.get(3).getComplaintName()).isEqualTo(mstComplaints.get(1).getComplaintName());
    assertThat(result.get(3).getIsDel()).isEqualTo(mstComplaints.get(1).getIsDel());
    assertThat(result.get(3).getIsDisp()).isEqualTo(mstComplaints.get(1).getIsDisp());

    assertThat(result.get(4).getComplaintCd()).isEqualTo(mstComplaints.get(2).getComplaintCd());
    assertThat(result.get(4).getComplaintName()).isEqualTo(mstComplaints.get(2).getComplaintName());
    assertThat(result.get(4).getIsDel()).isEqualTo(mstComplaints.get(2).getIsDel());
    assertThat(result.get(4).getIsDisp()).isEqualTo(mstComplaints.get(2).getIsDisp());

    verify(mstComplaintDao, times(1)).selectAllByFacilityCd(facilityCd);
    verify(mstSelectorDao, times(1)).selectByName(facilityCd, "mst_complaint");
  }

  /**
   * getAllMstComplaintsの検証.
   *
   * 条件：愁訴マスタに該当のデータがあり並び順管理マスタに該当のデータがない
   * 結果：施設コードに該当する愁訴マスタが取得できること（mst_selector未登録データ）
   * @throws JsonProcessingException
   */
  @Test
  public void getAllMstComplaints_正常_愁訴マスタに該当のデータがあり並び順管理マスタに該当のデータがない() throws JsonProcessingException {
    // arrange
    List<MstComplaint> mstComplaints = createComplaintEntity();

    final String facilityCd = "1001";
    given(mstComplaintDao.selectAllByFacilityCd(facilityCd))
      .willReturn(mstComplaints);

    given(mstSelectorDao.selectByName(facilityCd, "mst_complaint"))
      .willReturn(createMstSelectorNotContainsSelector("mst_complaint"));

    // action
    final List<MstComplaint> result = complaintService.getAllMstComplaints(facilityCd);

    // assert
    assertThat(result).isNotNull();
    assertThat(result).hasSize(5);
    assertThat(result.get(0).getComplaintCd()).isEqualTo(mstComplaints.get(0).getComplaintCd());
    assertThat(result.get(0).getComplaintName()).isEqualTo(mstComplaints.get(0).getComplaintName());
    assertThat(result.get(0).getIsDel()).isEqualTo(mstComplaints.get(0).getIsDel());
    assertThat(result.get(0).getIsDisp()).isEqualTo(mstComplaints.get(0).getIsDisp());

    assertThat(result.get(1).getComplaintCd()).isEqualTo(mstComplaints.get(1).getComplaintCd());
    assertThat(result.get(1).getComplaintName()).isEqualTo(mstComplaints.get(1).getComplaintName());
    assertThat(result.get(1).getIsDel()).isEqualTo(mstComplaints.get(1).getIsDel());
    assertThat(result.get(1).getIsDisp()).isEqualTo(mstComplaints.get(1).getIsDisp());

    assertThat(result.get(2).getComplaintCd()).isEqualTo(mstComplaints.get(2).getComplaintCd());
    assertThat(result.get(2).getComplaintName()).isEqualTo(mstComplaints.get(2).getComplaintName());
    assertThat(result.get(2).getIsDel()).isEqualTo(mstComplaints.get(2).getIsDel());
    assertThat(result.get(2).getIsDisp()).isEqualTo(mstComplaints.get(2).getIsDisp());

    assertThat(result.get(3).getComplaintCd()).isEqualTo(mstComplaints.get(3).getComplaintCd());
    assertThat(result.get(3).getComplaintName()).isEqualTo(mstComplaints.get(3).getComplaintName());
    assertThat(result.get(3).getIsDel()).isEqualTo(mstComplaints.get(3).getIsDel());
    assertThat(result.get(3).getIsDisp()).isEqualTo(mstComplaints.get(3).getIsDisp());

    assertThat(result.get(4).getComplaintCd()).isEqualTo(mstComplaints.get(4).getComplaintCd());
    assertThat(result.get(4).getComplaintName()).isEqualTo(mstComplaints.get(4).getComplaintName());
    assertThat(result.get(4).getIsDel()).isEqualTo(mstComplaints.get(4).getIsDel());
    assertThat(result.get(4).getIsDisp()).isEqualTo(mstComplaints.get(4).getIsDisp());

    verify(mstComplaintDao, times(1)).selectAllByFacilityCd(facilityCd);
    verify(mstSelectorDao, times(1)).selectByName(facilityCd, "mst_complaint");
  }

  /**
   * getAllMstComplaintsの検証.
   *
   * 条件：愁訴マスタに該当のデータがなく並び順管理マスタにデータがある
   * 結果：空のリストが取得できること
   * @throws JsonProcessingException
   */
  @Test
  public void getAllMstComplaints_正常_愁訴マスタに該当のデータがなく並び順管理マスタにデータがある() throws JsonProcessingException {
    // arrange
    final String facilityCd = "1001";
    given(mstComplaintDao.selectAllByFacilityCd(facilityCd))
      .willReturn(emptyList());

    given(mstSelectorDao.selectByName(facilityCd, "mst_complaint"))
      .willReturn(createMstSelectorContainsSelector("mst_complaint"));

    // action
    final List<MstComplaint> result = complaintService.getAllMstComplaints(facilityCd);

    // assert
    assertThat(result).isNotNull();
    assertThat(result).hasSize(0);

    verify(mstComplaintDao, times(1)).selectAllByFacilityCd(facilityCd);
    verify(mstSelectorDao, times(0)).selectByName(facilityCd, "mst_complaint");
  }

  /**
   * getAllMstComplaintsの検証.
   *
   * 条件：愁訴マスタに該当のデータがない
   * 結果：空のリストが取得できること
   * @throws JsonProcessingException
   */
  @Test
  public void test_getAllMstComplaints_正常_愁訴マスタに該当のデータがない() throws JsonProcessingException {
    // arrange
    final String facilityCd = "9999";
    given(mstComplaintDao.selectAllByFacilityCd(facilityCd))
      .willReturn(emptyList());

    given(mstSelectorDao.selectByName(facilityCd, "mst_complaint"))
      .willReturn(createMstSelectorNotContainsSelector("mst_complaint"));

    // action
    final List<MstComplaint> result = complaintService.getAllMstComplaints(facilityCd);

    // assert
    assertThat(result).isNotNull();
    assertThat(result).hasSize(0);

    verify(mstComplaintDao, times(1)).selectAllByFacilityCd(facilityCd);
    verify(mstSelectorDao, times(0)).selectByName(facilityCd, "mst_complaint");
  }

  /**
   * 非表示のみの処置マスタのリストを指定の施設マスタで作成します.
   * @return 処置マスタのリスト
   */
  private List<MstCompTreatment> createNoDispMstCompTreatment(String facilityCd) {
    return Arrays.asList(
      new MstCompTreatment(){
        {
          setCompTreatmentCd(3);
          setFacilityCd(facilityCd);
          setTreatment("処置内容3");
          setTreatClass(0);
          setTreatMedicineCd(13);
          setAmount(BigDecimal.valueOf(1.3));
          setProcedureCd(23);
          setTakeMedicineCd(33);
          setIsDisp("0");
          setIsDel("0");
        }
      },
      new MstCompTreatment(){
        {
          setCompTreatmentCd(2);
          setFacilityCd(facilityCd);
          setTreatment("処置内容2");
          setTreatClass(2);
          setIsDisp("0");
          setIsDel("0");
        }});
  }

  /**
   * 非表示ありの処置マスタのリストを指定の施設マスタで作成します.
   * @param facilityCd 施設コード
   * @return 処置マスタのリスト
   */
  private List<MstCompTreatment> createMstCompTreatment(String facilityCd) {
    List<MstCompTreatment> noDisp = createNoDispMstCompTreatment(facilityCd);
    return Arrays.asList(
      // 0: 非表示データ
      noDisp.get(0),
      // 1: 表示データ
      new MstCompTreatment(){
        {
          setCompTreatmentCd(4);
          setFacilityCd(facilityCd);
          setTreatment("処置内容4");
          setTreatClass(1);
          setTreatMedicineCd(14);
          setAmount(BigDecimal.valueOf(1.4));
          setProcedureCd(24);
          setTakeMedicineCd(34);
          setIsDisp("1");
          setIsDel("0");
        }
      },
      // 2: 非表示データ
      noDisp.get(1),
      // 3: 表示データ
      new MstCompTreatment(){
        {
          setCompTreatmentCd(5);
          setFacilityCd(facilityCd);
          setTreatment("処置内容5");
          setTreatClass(0);
          setTreatMedicineCd(15);
          setAmount(BigDecimal.valueOf(1.5));
          setProcedureCd(25);
          setTakeMedicineCd(35);
          setIsDisp("1");
          setIsDel("0");
        }
      },
      // 4: 表示データ
      new MstCompTreatment(){
        {
          setCompTreatmentCd(1);
          setFacilityCd(facilityCd);
          setTreatment("処置内容1");
          setTreatClass(2);
          setIsDisp("1");
          setIsDel("0");
        }
      });
  }

  /**
   * getAllMstCompTreatmentsの検証.
   *
   * 条件：処置マスタに該当のデータがない
   * 結果：空のリストが取得できること
   */
  @Test
  public void test_getAllMstCompTreatments_処置マスタが空() {
    // arrange
    final String facilityCd = "009999";
    final String tableName = "mst_comp_treatment";
    given(mstCompTreatmentDao.selectAllByFacilityCd(facilityCd)).willReturn(emptyList());

    // action
    List<MstCompTreatment> actual = complaintService.getAllMstCompTreatments(facilityCd);

    // assert
    assertThat(actual).hasSize(0);
    // verify
    verify(mstCompTreatmentDao, times(1)).selectAllByFacilityCd(facilityCd);
    verify(mstSelectorDao, times(0)).selectByName(facilityCd, tableName);
  }

  /**
   * getAllMstCompTreatmentsの検証.
   *
   * 条件：処置マスタに該当のデータがあるが全て非表示
   * 結果：非表示のみのリストが処置コードの昇順で取得できること
   */
  @Test
  public void test_getAllMstCompTreatments_選択肢マスタが空() throws JsonProcessingException {
    // arrange
    final String facilityCd = "009999";
    final String tableName = "mst_comp_treatment";

    List<MstCompTreatment> expected = createNoDispMstCompTreatment(facilityCd);
    given(mstCompTreatmentDao.selectAllByFacilityCd(facilityCd)).willReturn(expected);
    given(mstSelectorDao.selectByName(facilityCd, tableName))
      .willReturn(createMstSelectorNotContainsSelector(tableName));

    // action
    List<MstCompTreatment> actual = complaintService.getAllMstCompTreatments(facilityCd);

    // assert
    assertThat(actual).hasSize(2);
    // 処置コードの昇順で取得される
    assertThat(actual.get(0).getCompTreatmentCd()).isEqualTo(expected.get(1).getCompTreatmentCd());
    assertThat(actual.get(0).getFacilityCd()).isEqualTo(expected.get(1).getFacilityCd());
    assertThat(actual.get(0).getTreatment()).isEqualTo(expected.get(1).getTreatment());
    assertThat(actual.get(0).getTreatClass()).isEqualTo(expected.get(1).getTreatClass());
    assertThat(actual.get(0).getTreatMedicineCd()).isEqualTo(expected.get(1).getTreatMedicineCd());
    assertThat(actual.get(0).getAmount()).isEqualTo(expected.get(1).getAmount());
    assertThat(actual.get(0).getProcedureCd()).isEqualTo(expected.get(1).getProcedureCd());
    assertThat(actual.get(0).getTakeMedicineCd()).isEqualTo(expected.get(1).getTakeMedicineCd());
    assertThat(actual.get(0).getIsDisp()).isEqualTo(expected.get(1).getIsDisp());
    assertThat(actual.get(0).getIsDel()).isEqualTo(expected.get(1).getIsDel());

    assertThat(actual.get(1).getCompTreatmentCd()).isEqualTo(expected.get(0).getCompTreatmentCd());
    assertThat(actual.get(1).getFacilityCd()).isEqualTo(expected.get(0).getFacilityCd());
    assertThat(actual.get(1).getTreatment()).isEqualTo(expected.get(0).getTreatment());
    assertThat(actual.get(1).getTreatClass()).isEqualTo(expected.get(0).getTreatClass());
    assertThat(actual.get(1).getTreatMedicineCd()).isEqualTo(expected.get(0).getTreatMedicineCd());
    assertThat(actual.get(1).getAmount()).isEqualTo(expected.get(0).getAmount());
    assertThat(actual.get(1).getProcedureCd()).isEqualTo(expected.get(0).getProcedureCd());
    assertThat(actual.get(1).getTakeMedicineCd()).isEqualTo(expected.get(0).getTakeMedicineCd());
    assertThat(actual.get(1).getIsDisp()).isEqualTo(expected.get(0).getIsDisp());
    assertThat(actual.get(1).getIsDel()).isEqualTo(expected.get(0).getIsDel());
    // verify
    verify(mstCompTreatmentDao, times(1)).selectAllByFacilityCd(facilityCd);
    verify(mstSelectorDao, times(1)).selectByName(facilityCd, tableName);
  }

  /**
   * getAllMstCompTreatmentsの検証.
   *
   * 条件：処置マスタおよび選択肢マスタあり
   * 結果：選択肢マスタに存在する処置マスタが選択肢マスタの設定順で取得できること
   *      そのあとに非表示の処置マスタが処置コードの昇順で取得できること
   *      選択肢マスタに存在しても処置マスタになければ対象外となること
   */
  @Test
  public void test_getAllMstCompTreatments_選択肢マスタがあり() throws JsonProcessingException {
    // arrange
    final String facilityCd = "009999";
    final String tableName = "mst_comp_treatment";

    List<MstCompTreatment> expected = createMstCompTreatment(facilityCd);
    given(mstCompTreatmentDao.selectAllByFacilityCd(facilityCd)).willReturn(expected);
    given(mstSelectorDao.selectByName(facilityCd, tableName))
      .willReturn(createMstSelectorContainsSelector(tableName));

    // action
    List<MstCompTreatment> actual = complaintService.getAllMstCompTreatments(facilityCd);

    // assert
    assertThat(actual).hasSize(5);

    // 処置コードの昇順で取得される
    assertThat(actual.get(0).getCompTreatmentCd()).isEqualTo(expected.get(4).getCompTreatmentCd());
    assertThat(actual.get(0).getFacilityCd()).isEqualTo(expected.get(4).getFacilityCd());
    assertThat(actual.get(0).getTreatment()).isEqualTo(expected.get(4).getTreatment());
    assertThat(actual.get(0).getTreatClass()).isEqualTo(expected.get(4).getTreatClass());
    assertThat(actual.get(0).getTreatMedicineCd()).isEqualTo(expected.get(4).getTreatMedicineCd());
    assertThat(actual.get(0).getAmount()).isEqualTo(expected.get(4).getAmount());
    assertThat(actual.get(0).getProcedureCd()).isEqualTo(expected.get(4).getProcedureCd());
    assertThat(actual.get(0).getTakeMedicineCd()).isEqualTo(expected.get(4).getTakeMedicineCd());
    assertThat(actual.get(0).getIsDisp()).isEqualTo(expected.get(4).getIsDisp());
    assertThat(actual.get(0).getIsDel()).isEqualTo(expected.get(4).getIsDel());

    assertThat(actual.get(1).getCompTreatmentCd()).isEqualTo(expected.get(3).getCompTreatmentCd());
    assertThat(actual.get(1).getFacilityCd()).isEqualTo(expected.get(3).getFacilityCd());
    assertThat(actual.get(1).getTreatment()).isEqualTo(expected.get(3).getTreatment());
    assertThat(actual.get(1).getTreatClass()).isEqualTo(expected.get(3).getTreatClass());
    assertThat(actual.get(1).getTreatMedicineCd()).isEqualTo(expected.get(3).getTreatMedicineCd());
    assertThat(actual.get(1).getAmount()).isEqualTo(expected.get(3).getAmount());
    assertThat(actual.get(1).getProcedureCd()).isEqualTo(expected.get(3).getProcedureCd());
    assertThat(actual.get(1).getTakeMedicineCd()).isEqualTo(expected.get(3).getTakeMedicineCd());
    assertThat(actual.get(1).getIsDisp()).isEqualTo(expected.get(3).getIsDisp());
    assertThat(actual.get(1).getIsDel()).isEqualTo(expected.get(3).getIsDel());

    assertThat(actual.get(2).getCompTreatmentCd()).isEqualTo(expected.get(1).getCompTreatmentCd());
    assertThat(actual.get(2).getFacilityCd()).isEqualTo(expected.get(1).getFacilityCd());
    assertThat(actual.get(2).getTreatment()).isEqualTo(expected.get(1).getTreatment());
    assertThat(actual.get(2).getTreatClass()).isEqualTo(expected.get(1).getTreatClass());
    assertThat(actual.get(2).getTreatMedicineCd()).isEqualTo(expected.get(1).getTreatMedicineCd());
    assertThat(actual.get(2).getAmount()).isEqualTo(expected.get(1).getAmount());
    assertThat(actual.get(2).getProcedureCd()).isEqualTo(expected.get(1).getProcedureCd());
    assertThat(actual.get(2).getTakeMedicineCd()).isEqualTo(expected.get(1).getTakeMedicineCd());
    assertThat(actual.get(2).getIsDisp()).isEqualTo(expected.get(1).getIsDisp());
    assertThat(actual.get(2).getIsDel()).isEqualTo(expected.get(1).getIsDel());

    assertThat(actual.get(3).getCompTreatmentCd()).isEqualTo(expected.get(2).getCompTreatmentCd());
    assertThat(actual.get(3).getFacilityCd()).isEqualTo(expected.get(2).getFacilityCd());
    assertThat(actual.get(3).getTreatment()).isEqualTo(expected.get(2).getTreatment());
    assertThat(actual.get(3).getTreatClass()).isEqualTo(expected.get(2).getTreatClass());
    assertThat(actual.get(3).getTreatMedicineCd()).isEqualTo(expected.get(2).getTreatMedicineCd());
    assertThat(actual.get(3).getAmount()).isEqualTo(expected.get(2).getAmount());
    assertThat(actual.get(3).getProcedureCd()).isEqualTo(expected.get(2).getProcedureCd());
    assertThat(actual.get(3).getTakeMedicineCd()).isEqualTo(expected.get(2).getTakeMedicineCd());
    assertThat(actual.get(3).getIsDisp()).isEqualTo(expected.get(2).getIsDisp());
    assertThat(actual.get(3).getIsDel()).isEqualTo(expected.get(2).getIsDel());

    assertThat(actual.get(4).getCompTreatmentCd()).isEqualTo(expected.get(0).getCompTreatmentCd());
    assertThat(actual.get(4).getFacilityCd()).isEqualTo(expected.get(0).getFacilityCd());
    assertThat(actual.get(4).getTreatment()).isEqualTo(expected.get(0).getTreatment());
    assertThat(actual.get(4).getTreatClass()).isEqualTo(expected.get(0).getTreatClass());
    assertThat(actual.get(4).getTreatMedicineCd()).isEqualTo(expected.get(0).getTreatMedicineCd());
    assertThat(actual.get(4).getAmount()).isEqualTo(expected.get(0).getAmount());
    assertThat(actual.get(4).getProcedureCd()).isEqualTo(expected.get(0).getProcedureCd());
    assertThat(actual.get(4).getTakeMedicineCd()).isEqualTo(expected.get(0).getTakeMedicineCd());
    assertThat(actual.get(4).getIsDisp()).isEqualTo(expected.get(0).getIsDisp());
    assertThat(actual.get(4).getIsDel()).isEqualTo(expected.get(0).getIsDel());
    // verify
    verify(mstCompTreatmentDao, times(1)).selectAllByFacilityCd(facilityCd);
    verify(mstSelectorDao, times(1)).selectByName(facilityCd, tableName);
  }

  /**
   * updateMstComplaints()の検証.
   *
   * 条件：選択肢マスタが存在している場合に更新できること
   * 結果：愁訴マスタと選択肢マスタの更新ができること
   * @throws JsonProcessingException
   */
  @Test
  public void test_updateMstComplaints_成功_選択肢マスタが存在している場合に更新できること() throws JsonProcessingException {
    // arrange
    final String facilityCd = "1001";
    final String tableName = "mst_complaint";
    MstComplaint updateComplaints = new MstComplaint() {{
      setComplaintCd(1);
      setComplaintName("Name1");
      setFacilityCd(facilityCd);
      setIsDel("0");
      setIsDisp("1");
      setRegDate(Timestamp.valueOf("2019-07-08 13:00:00"));
      setIsUpdate(true);
    }};
    MstComplaint insertComplaints = new MstComplaint() {{
      setComplaintName("Name2");
      setFacilityCd(facilityCd);
      setIsDel("0");
      setIsDisp("1");
      setIsUpdate(false);
    }};
    List<MstComplaint> mstComplaints = Arrays.asList(updateComplaints, insertComplaints);

    final ArgumentCaptor<MstComplaint> updateCaptor = ArgumentCaptor.forClass(MstComplaint.class);
    final ArgumentCaptor<MstSelector> mstSelectorCaptor = ArgumentCaptor.forClass(MstSelector.class);
    given(mstComplaintDao.insertComplaint(updateCaptor.capture())).willReturn(1);
    given(mstComplaintDao.updateComplaint(updateCaptor.capture())).willReturn(1);
    given(mstComplaintDao.selectCurrentSeq()).willReturn(2);
    given(mstSelectorDao.selectByName(facilityCd, tableName)).willReturn(createMstSelectorForUpdateBefore(tableName));
    given(mstSelectorDao.update(mstSelectorCaptor.capture())).willReturn(1);

    // action
    int[] result = complaintService.updateMstComplaints(facilityCd, mstComplaints);

    // assert
    assertThat(result[0]).isEqualTo(1);
    assertThat(result[1]).isEqualTo(1);

    verify(mstComplaintDao, times(1)).insertComplaint(insertComplaints);
    verify(mstComplaintDao, times(1)).updateComplaint(updateComplaints);
    verify(mstComplaintDao, times(1)).selectCurrentSeq();
    verify(mstSelectorDao, times(1)).selectByName(facilityCd, tableName);
  }

  /**
   * updateMstComplaints()の検証.
   *
   * 条件：選択肢マスタが存在していない場合に更新できること
   * 結果：愁訴マスタと選択肢マスタの更新ができること
   * @throws JsonProcessingException
   */
  @Test
  public void test_updateMstComplaints_成功_選択肢マスタが存在していない場合に更新できること() throws JsonProcessingException {
    // arrange
    final String facilityCd = "1001";
    final String tableName = "mst_complaint";
    MstComplaint updateComplaints = new MstComplaint() {{
      setComplaintCd(1);
      setComplaintName("Name1");
      setFacilityCd(facilityCd);
      setIsDel("0");
      setIsDisp("1");
      setRegDate(Timestamp.valueOf("2019-07-08 13:00:00"));
      setIsUpdate(true);
    }};
    MstComplaint insertComplaints = new MstComplaint() {{
      setComplaintName("Name2");
      setFacilityCd(facilityCd);
      setIsDel("0");
      setIsDisp("1");
      setIsUpdate(false);
    }};
    List<MstComplaint> mstComplaints = Arrays.asList(updateComplaints, insertComplaints);

    final ArgumentCaptor<MstComplaint> updateCaptor = ArgumentCaptor.forClass(MstComplaint.class);
    final ArgumentCaptor<MstSelector> mstSelectorCaptor = ArgumentCaptor.forClass(MstSelector.class);
    given(mstComplaintDao.insertComplaint(updateCaptor.capture())).willReturn(1);
    given(mstComplaintDao.updateComplaint(updateCaptor.capture())).willReturn(0);
    given(mstComplaintDao.selectCurrentSeq()).willReturn(2);
    given(mstSelectorDao.selectByName(facilityCd, tableName)).willReturn(null);
    given(mstSelectorDao.update(mstSelectorCaptor.capture())).willReturn(1);

    // action
    int[] result = complaintService.updateMstComplaints(facilityCd, mstComplaints);

    // assert
    assertThat(result[0]).isEqualTo(1);
    assertThat(result[1]).isEqualTo(0);

    verify(mstComplaintDao, times(1)).insertComplaint(insertComplaints);
    verify(mstComplaintDao, times(1)).updateComplaint(updateComplaints);
    verify(mstComplaintDao, times(1)).selectCurrentSeq();
    verify(mstSelectorDao, times(1)).selectByName(facilityCd, tableName);
  }

  /**
   * updateMstComplaints()の検証.
   *
   * 条件：愁訴マスタに追加のみできること
   * 結果：愁訴マスタと選択肢マスタの更新ができること
   * @throws JsonProcessingException
   */
  @Test
  public void test_updateMstComplaints_成功_愁訴マスタに追加のみできること() throws JsonProcessingException {
    // arrange
    final String facilityCd = "1001";
    final String tableName = "mst_complaint";
    MstComplaint insertComplaints = new MstComplaint() {{
      setComplaintName("Name1");
      setFacilityCd(facilityCd);
      setIsDel("0");
      setIsDisp("1");
      setIsUpdate(false);
    }};
    List<MstComplaint> mstComplaints = Arrays.asList(insertComplaints);

    final ArgumentCaptor<MstComplaint> updateCaptor = ArgumentCaptor.forClass(MstComplaint.class);
    final ArgumentCaptor<MstSelector> mstSelectorCaptor = ArgumentCaptor.forClass(MstSelector.class);
    given(mstComplaintDao.insertComplaint(updateCaptor.capture())).willReturn(1);
    given(mstComplaintDao.updateComplaint(updateCaptor.capture())).willReturn(0);
    given(mstComplaintDao.selectCurrentSeq()).willReturn(1);
    given(mstSelectorDao.selectByName(facilityCd, tableName)).willReturn(createMstSelectorForUpdateBefore(tableName));
    given(mstSelectorDao.update(mstSelectorCaptor.capture())).willReturn(1);

    // action
    int[] result = complaintService.updateMstComplaints(facilityCd, mstComplaints);

    // assert
    assertThat(result[0]).isEqualTo(1);
    assertThat(result[1]).isEqualTo(0);

    verify(mstComplaintDao, times(1)).insertComplaint(insertComplaints);
    verify(mstComplaintDao, times(0)).updateComplaint(any());
    verify(mstComplaintDao, times(1)).selectCurrentSeq();
    verify(mstSelectorDao, times(1)).selectByName(facilityCd, tableName);
  }

  /**
   * updateMstComplaints()の検証.
   *
   * 条件：愁訴マスタに更新のみできること
   * 結果：愁訴マスタと選択肢マスタの更新ができること
   * @throws JsonProcessingException
   */
  @Test
  public void test_updateMstComplaints_成功_愁訴マスタに更新のみできること() throws JsonProcessingException {
    // arrange
    final String facilityCd = "1001";
    final String tableName = "mst_complaint";
    MstComplaint updateComplaints = new MstComplaint() {{
      setComplaintCd(1);
      setComplaintName("Name1");
      setFacilityCd(facilityCd);
      setIsDel("0");
      setIsDisp("1");
      setRegDate(Timestamp.valueOf("2019-07-08 13:00:00"));
      setIsUpdate(true);
    }};
    List<MstComplaint> mstComplaints = Arrays.asList(updateComplaints);

    final ArgumentCaptor<MstComplaint> updateCaptor = ArgumentCaptor.forClass(MstComplaint.class);
    final ArgumentCaptor<MstSelector> mstSelectorCaptor = ArgumentCaptor.forClass(MstSelector.class);
    given(mstComplaintDao.insertComplaint(updateCaptor.capture())).willReturn(0);
    given(mstComplaintDao.updateComplaint(updateCaptor.capture())).willReturn(1);
    given(mstComplaintDao.selectCurrentSeq()).willReturn(1);
    given(mstSelectorDao.selectByName(facilityCd, tableName)).willReturn(createMstSelectorForUpdateBefore(tableName));
    given(mstSelectorDao.update(mstSelectorCaptor.capture())).willReturn(1);

    // action
    int[] result = complaintService.updateMstComplaints(facilityCd, mstComplaints);

    // assert
    assertThat(result[0]).isEqualTo(0);
    assertThat(result[1]).isEqualTo(1);

    verify(mstComplaintDao, times(0)).insertComplaint(any());
    verify(mstComplaintDao, times(1)).updateComplaint(updateComplaints);
    verify(mstComplaintDao, times(0)).selectCurrentSeq();
    verify(mstSelectorDao, times(1)).selectByName(facilityCd, tableName);
  }

  /**
   * updateMstComplaints()の検証.
   *
   * 条件：更新対象以外のデータは更新されないこと
   * 結果：愁訴マスタと選択肢マスタの更新ができること
   * @throws JsonProcessingException
   */
  @Test
  public void test_updateMstComplaints_成功_更新対象以外のデータは更新されないこと() throws JsonProcessingException {
    // arrange
    final String facilityCd = "1001";
    final String tableName = "mst_complaint";
    MstComplaint updateComplaints = new MstComplaint() {{
      setComplaintCd(1);
      setComplaintName("Name1");
      setFacilityCd(facilityCd);
      setIsDel("0");
      setIsDisp("1");
      setRegDate(Timestamp.valueOf("2019-07-08 13:00:00"));
      setUpDate(Timestamp.valueOf("2019-07-08 14:00:00"));
      setIsUpdate(false);
    }};
    List<MstComplaint> mstComplaints = Arrays.asList(updateComplaints);

    final ArgumentCaptor<MstComplaint> updateCaptor = ArgumentCaptor.forClass(MstComplaint.class);
    final ArgumentCaptor<MstSelector> mstSelectorCaptor = ArgumentCaptor.forClass(MstSelector.class);
    given(mstComplaintDao.insertComplaint(updateCaptor.capture())).willReturn(0);
    given(mstComplaintDao.updateComplaint(updateCaptor.capture())).willReturn(0);
    given(mstComplaintDao.selectCurrentSeq()).willReturn(1);
    given(mstSelectorDao.selectByName(facilityCd, tableName)).willReturn(createMstSelectorForUpdateBefore(tableName));
    given(mstSelectorDao.update(mstSelectorCaptor.capture())).willReturn(1);

    // action
    int[] result = complaintService.updateMstComplaints(facilityCd, mstComplaints);

    // assert
    assertThat(result[0]).isEqualTo(0);
    assertThat(result[1]).isEqualTo(0);

    verify(mstComplaintDao, times(0)).insertComplaint(any());
    verify(mstComplaintDao, times(0)).updateComplaint(any());
    verify(mstComplaintDao, times(0)).selectCurrentSeq();
    verify(mstSelectorDao, times(1)).selectByName(facilityCd, tableName);
  }

  /**
   * updateMstCompTreatments()の検証.
   *
   * 条件：選択肢マスタが存在している場合に更新できること
   * 結果：処置マスタと選択肢マスタの更新ができること
   * @throws JsonProcessingException
   */
  @Test
  public void test_updateMstCompTreatments_成功_選択肢マスタが存在している場合に更新できること() throws JsonProcessingException {
    // arrange
    final String facilityCd = "1001";
    final String tableName = "mst_comp_treatment";
    MstCompTreatment updateCompTreatment = new MstCompTreatment() {{
      setCompTreatmentCd(1);
      setFacilityCd(facilityCd);
      setTreatment("name1");
      setTreatClass(1);
      setTreatMedicineCd(1);
      setAmount(new BigDecimal("12.12"));
      setProcedureCd(1);
      setTakeMedicineCd(1);
      setIsDel("0");
      setIsDisp("1");
      setRegDate(Timestamp.valueOf("2019-07-08 13:00:00"));
      setIsUpdate(true);
    }};
    MstCompTreatment insertCompTreatment = new MstCompTreatment() {{
      setFacilityCd(facilityCd);
      setTreatment("name2");
      setTreatClass(1);
      setTreatMedicineCd(1);
      setAmount(new BigDecimal("12.12"));
      setProcedureCd(1);
      setTakeMedicineCd(1);
      setIsDel("0");
      setIsDisp("1");
      setIsUpdate(false);
    }};
    List<MstCompTreatment> mstCompTreatment = Arrays.asList(updateCompTreatment, insertCompTreatment);

    final ArgumentCaptor<MstCompTreatment> updateCaptor = ArgumentCaptor.forClass(MstCompTreatment.class);
    final ArgumentCaptor<MstSelector> mstSelectorCaptor = ArgumentCaptor.forClass(MstSelector.class);
    given(mstCompTreatmentDao.insertCompTreatment(updateCaptor.capture())).willReturn(1);
    given(mstCompTreatmentDao.updateCompTreatment(updateCaptor.capture())).willReturn(1);
    given(mstCompTreatmentDao.selectCurrentSeq()).willReturn(2);
    given(mstSelectorDao.selectByName(facilityCd, tableName)).willReturn(createMstSelectorForUpdateBefore(tableName));
    given(mstSelectorDao.update(mstSelectorCaptor.capture())).willReturn(1);

    // action
    int[] result = complaintService.updateMstCompTreatments(facilityCd, mstCompTreatment);

    // assert
    assertThat(result[0]).isEqualTo(1);
    assertThat(result[1]).isEqualTo(1);

    verify(mstCompTreatmentDao, times(1)).insertCompTreatment(insertCompTreatment);
    verify(mstCompTreatmentDao, times(1)).updateCompTreatment(updateCompTreatment);
    verify(mstCompTreatmentDao, times(1)).selectCurrentSeq();
    verify(mstSelectorDao, times(1)).selectByName(facilityCd, tableName);
  }

  /**
   * updateMstCompTreatments()の検証.
   *
   * 条件：選択肢マスタが存在していない場合に更新できること
   * 結果：処置マスタと選択肢マスタの更新ができること
   * @throws JsonProcessingException
   */
  @Test
  public void test_updateMstCompTreatments_成功_選択肢マスタが存在していない場合に更新できること() throws JsonProcessingException {
    // arrange
    final String facilityCd = "1001";
    final String tableName = "mst_comp_treatment";
    MstCompTreatment updateCompTreatment = new MstCompTreatment() {{
      setCompTreatmentCd(1);
      setFacilityCd(facilityCd);
      setTreatment("name1");
      setTreatClass(1);
      setTreatMedicineCd(1);
      setAmount(new BigDecimal("12.12"));
      setProcedureCd(1);
      setTakeMedicineCd(1);
      setIsDel("0");
      setIsDisp("1");
      setRegDate(Timestamp.valueOf("2019-07-08 13:00:00"));
      setIsUpdate(true);
    }};
    MstCompTreatment insertCompTreatment = new MstCompTreatment() {{
      setFacilityCd(facilityCd);
      setTreatment("name2");
      setTreatClass(1);
      setTreatMedicineCd(1);
      setAmount(new BigDecimal("12.12"));
      setProcedureCd(1);
      setTakeMedicineCd(1);
      setIsDel("0");
      setIsDisp("1");
      setIsUpdate(false);
    }};
    List<MstCompTreatment> mstCompTreatment = Arrays.asList(updateCompTreatment, insertCompTreatment);

    final ArgumentCaptor<MstCompTreatment> updateCaptor = ArgumentCaptor.forClass(MstCompTreatment.class);
    final ArgumentCaptor<MstSelector> mstSelectorCaptor = ArgumentCaptor.forClass(MstSelector.class);
    given(mstCompTreatmentDao.insertCompTreatment(updateCaptor.capture())).willReturn(1);
    given(mstCompTreatmentDao.updateCompTreatment(updateCaptor.capture())).willReturn(0);
    given(mstCompTreatmentDao.selectCurrentSeq()).willReturn(2);
    given(mstSelectorDao.selectByName(facilityCd, tableName)).willReturn(null);
    given(mstSelectorDao.update(mstSelectorCaptor.capture())).willReturn(1);

    // action
    int[] result = complaintService.updateMstCompTreatments(facilityCd, mstCompTreatment);

    // assert
    assertThat(result[0]).isEqualTo(1);
    assertThat(result[1]).isEqualTo(0);

    verify(mstCompTreatmentDao, times(1)).insertCompTreatment(insertCompTreatment);
    verify(mstCompTreatmentDao, times(1)).updateCompTreatment(updateCompTreatment);
    verify(mstCompTreatmentDao, times(1)).selectCurrentSeq();
    verify(mstSelectorDao, times(1)).selectByName(facilityCd, tableName);
  }

  /**
   * updateMstCompTreatments()の検証.
   *
   * 条件：処置マスタに追加のみできること
   * 結果：処置マスタと選択肢マスタの更新ができること
   * @throws JsonProcessingException
   */
  @Test
  public void test_updateMstCompTreatments_成功_処置マスタに追加のみできること() throws JsonProcessingException {
    // arrange
    final String facilityCd = "1001";
    final String tableName = "mst_comp_treatment";
    MstCompTreatment insertCompTreatment = new MstCompTreatment() {{
      setFacilityCd(facilityCd);
      setTreatment("name1");
      setTreatClass(1);
      setTreatMedicineCd(1);
      setAmount(new BigDecimal("12.12"));
      setProcedureCd(1);
      setTakeMedicineCd(1);
      setIsDel("0");
      setIsDisp("1");
      setIsUpdate(false);
    }};
    List<MstCompTreatment> mstCompTreatment = Arrays.asList(insertCompTreatment);

    final ArgumentCaptor<MstCompTreatment> updateCaptor = ArgumentCaptor.forClass(MstCompTreatment.class);
    final ArgumentCaptor<MstSelector> mstSelectorCaptor = ArgumentCaptor.forClass(MstSelector.class);
    given(mstCompTreatmentDao.insertCompTreatment(updateCaptor.capture())).willReturn(1);
    given(mstCompTreatmentDao.updateCompTreatment(updateCaptor.capture())).willReturn(0);
    given(mstCompTreatmentDao.selectCurrentSeq()).willReturn(1);
    given(mstSelectorDao.selectByName(facilityCd, tableName)).willReturn(createMstSelectorForUpdateBefore(tableName));
    given(mstSelectorDao.update(mstSelectorCaptor.capture())).willReturn(1);

    // action
    int[] result = complaintService.updateMstCompTreatments(facilityCd, mstCompTreatment);

    // assert
    assertThat(result[0]).isEqualTo(1);
    assertThat(result[1]).isEqualTo(0);

    verify(mstCompTreatmentDao, times(1)).insertCompTreatment(insertCompTreatment);
    verify(mstCompTreatmentDao, times(0)).updateCompTreatment(any());
    verify(mstCompTreatmentDao, times(1)).selectCurrentSeq();
    verify(mstSelectorDao, times(1)).selectByName(facilityCd, tableName);
  }

  /**
   * updateMstCompTreatments()の検証.
   *
   * 条件：処置マスタに更新のみできること
   * 結果：処置マスタと選択肢マスタの更新ができること
   * @throws JsonProcessingException
   */
  @Test
  public void test_updateMstCompTreatments_成功_処置マスタに更新のみできること() throws JsonProcessingException {
    // arrange
    final String facilityCd = "1001";
    final String tableName = "mst_comp_treatment";
    MstCompTreatment updateCompTreatment = new MstCompTreatment() {{
      setCompTreatmentCd(1);
      setFacilityCd(facilityCd);
      setTreatment("name1");
      setTreatClass(1);
      setTreatMedicineCd(1);
      setAmount(new BigDecimal("12.12"));
      setProcedureCd(1);
      setTakeMedicineCd(1);
      setIsDel("0");
      setIsDisp("1");
      setRegDate(Timestamp.valueOf("2019-07-08 13:00:00"));
      setIsUpdate(true);
    }};
    List<MstCompTreatment> mstCompTreatment = Arrays.asList(updateCompTreatment);

    final ArgumentCaptor<MstCompTreatment> updateCaptor = ArgumentCaptor.forClass(MstCompTreatment.class);
    final ArgumentCaptor<MstSelector> mstSelectorCaptor = ArgumentCaptor.forClass(MstSelector.class);
    given(mstCompTreatmentDao.insertCompTreatment(updateCaptor.capture())).willReturn(0);
    given(mstCompTreatmentDao.updateCompTreatment(updateCaptor.capture())).willReturn(1);
    given(mstCompTreatmentDao.selectCurrentSeq()).willReturn(1);
    given(mstSelectorDao.selectByName(facilityCd, tableName)).willReturn(createMstSelectorForUpdateBefore(tableName));
    given(mstSelectorDao.update(mstSelectorCaptor.capture())).willReturn(1);

    // action
    int[] result = complaintService.updateMstCompTreatments(facilityCd, mstCompTreatment);

    // assert
    assertThat(result[0]).isEqualTo(0);
    assertThat(result[1]).isEqualTo(1);

    verify(mstCompTreatmentDao, times(0)).insertCompTreatment(any());
    verify(mstCompTreatmentDao, times(1)).updateCompTreatment(updateCompTreatment);
    verify(mstCompTreatmentDao, times(0)).selectCurrentSeq();
    verify(mstSelectorDao, times(1)).selectByName(facilityCd, tableName);
  }

  /**
   * updateMstCompTreatments()の検証.
   *
   * 条件：更新対象以外のデータは更新されないこと
   * 結果：処置マスタと選択肢マスタの更新ができること
   * @throws JsonProcessingException
   */
  @Test
  public void test_updateMstCompTreatments_成功_更新対象以外のデータは更新されないこと() throws JsonProcessingException {
    // arrange
    final String facilityCd = "1001";
    final String tableName = "mst_comp_treatment";
    MstCompTreatment updateCompTreatment = new MstCompTreatment() {{
      setCompTreatmentCd(1);
      setFacilityCd(facilityCd);
      setTreatment("name1");
      setTreatClass(1);
      setTreatMedicineCd(1);
      setAmount(new BigDecimal("12.12"));
      setProcedureCd(1);
      setTakeMedicineCd(1);
      setIsDel("0");
      setIsDisp("1");
      setRegDate(Timestamp.valueOf("2019-07-08 13:00:00"));
      setUpDate(Timestamp.valueOf("2019-07-08 14:00:00"));
      setIsUpdate(false);

    }};
    List<MstCompTreatment> mstCompTreatment = Arrays.asList(updateCompTreatment);

    final ArgumentCaptor<MstCompTreatment> updateCaptor = ArgumentCaptor.forClass(MstCompTreatment.class);
    final ArgumentCaptor<MstSelector> mstSelectorCaptor = ArgumentCaptor.forClass(MstSelector.class);
    given(mstCompTreatmentDao.insertCompTreatment(updateCaptor.capture())).willReturn(0);
    given(mstCompTreatmentDao.updateCompTreatment(updateCaptor.capture())).willReturn(0);
    given(mstCompTreatmentDao.selectCurrentSeq()).willReturn(1);
    given(mstSelectorDao.selectByName(facilityCd, tableName)).willReturn(createMstSelectorForUpdateBefore(tableName));
    given(mstSelectorDao.update(mstSelectorCaptor.capture())).willReturn(1);

    // action
    int[] result = complaintService.updateMstCompTreatments(facilityCd, mstCompTreatment);

    // assert
    assertThat(result[0]).isEqualTo(0);
    assertThat(result[1]).isEqualTo(0);

    verify(mstCompTreatmentDao, times(0)).insertCompTreatment(any());
    verify(mstCompTreatmentDao, times(0)).updateCompTreatment(any());
    verify(mstCompTreatmentDao, times(0)).selectCurrentSeq();
    verify(mstSelectorDao, times(1)).selectByName(facilityCd, tableName);
  }
}
