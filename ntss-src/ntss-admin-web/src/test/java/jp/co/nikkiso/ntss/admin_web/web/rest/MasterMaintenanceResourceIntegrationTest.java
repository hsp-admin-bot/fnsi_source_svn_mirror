package jp.co.nikkiso.ntss.admin_web.web.rest;

import static java.util.Collections.singletonMap;
import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.nullValue;
import static org.junit.Assert.assertThat;
import static org.springframework.restdocs.mockmvc.MockMvcRestDocumentation.document;
import static org.springframework.restdocs.payload.PayloadDocumentation.fieldWithPath;
import static org.springframework.restdocs.payload.PayloadDocumentation.requestFields;
import static org.springframework.restdocs.payload.PayloadDocumentation.responseFields;
import static org.springframework.restdocs.request.RequestDocumentation.parameterWithName;
import static org.springframework.restdocs.request.RequestDocumentation.pathParameters;
import static org.springframework.restdocs.snippet.Attributes.attributes;
import static org.springframework.restdocs.snippet.Attributes.key;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.restdocs.mockmvc.RestDocumentationRequestBuilders;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.web.servlet.ResultActions;
import org.springframework.transaction.annotation.Transactional;

import tools.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant;
import jp.co.nikkiso.ntss.admin_web.request.masterMaintenance.MasterUpdateRequest;
import jp.co.nikkiso.ntss.admin_web.response.masterMaintenance.MasterColumn;
import jp.co.nikkiso.ntss.admin_web.response.masterMaintenance.MasterInfo;
import jp.co.nikkiso.ntss.core.dao.MntMotionRecordDao;
import jp.co.nikkiso.ntss.core.dao.MstSelectorDao;
import jp.co.nikkiso.ntss.core.entity.MntMotionRecord;
import jp.co.nikkiso.ntss.core.entity.MstSelector;

/**
 * MasterMaintenanceの結合用テストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@AutoConfigureMockMvc
@Transactional
@NtssMockUser(facilityCd = "000001")
@Sql("classpath:resource.script/MasterMaintenanceResourceIntegrationTest.before.sql")
public class MasterMaintenanceResourceIntegrationTest extends AbstractResourceIntegrationTest {

  /**
   * ObjectMapper.
   */
  @Autowired
  private ObjectMapper mapper;

  /**
   * 装置動作記録のDaoインターフェイス.
   */
  @Autowired
  private MntMotionRecordDao mntMotionRecordDao;

  /**
   * マスタセレクタDaoインターフェイス.
   */
  @Autowired
  private MstSelectorDao mstSelectorDao;

  /**
   * 検証用のマスタ一覧データ(レスポンス)
   */
  private List<MasterInfo> getMasterInfo() {
    List<MasterInfo> masterInfo = Arrays.asList(
        new MasterInfo("mst_user", "マスタ名称2", "2", "2", 1, "1"),
        new MasterInfo("mst_facility", "マスタ名称1", "1", "1", 2, "1"),
        new MasterInfo("mnt_motion_record", "マスタ名称3", "3", "3", 3, "1"));
    return masterInfo;
  }

  /**
   * 検証用のマスタデータ(レスポンス)
   */
  private List<Map<String, Object>> getMasterData() {
    // 施設マスタ１件目データ
    Map<String, Object> dataMap1 = new HashMap<>();
    dataMap1.put("facilityName", "施設名１");
    dataMap1.put("facilityNameKana", "シセツカナメイ１");
    dataMap1.put("prefecturesCd", "01");
    dataMap1.put("departmentCd", "S1A1");
    dataMap1.put("aliveMoniInterval", 1);
    dataMap1.put("useFunction", "{\"func_cds\": [{\"func_cd\": \"001\"}]}");

    List<Map<String, Object>> data = Arrays.asList(dataMap1);
    return data;
  }

  /**
   * 検証用のカラム情報(レスポンス)
   */
  private List<MasterColumn> getColumns() {

    MasterColumn column1 = new MasterColumn("sortRank", "並び順", false, false, "{0:n0}", null, false, "");
    MasterColumn column2 = new MasterColumn("sortInputTime", "sortInputTime", true, false, null, null, true, "");
    MasterColumn column3 = new MasterColumn("facilityName", "施設名", false, false, null, null, true, "");
    MasterColumn column4 = new MasterColumn("facilityNameKana", "施設カナ名", false, false, null, null, true, "");
    MasterColumn column5 = new MasterColumn("prefecturesCd", "都道府県コード", false, false, null, null, true, "");
    MasterColumn column6 = new MasterColumn("departmentCd", "部署符号", true, false, null, null, true, "");
    MasterColumn column7 = new MasterColumn("aliveMoniInterval", "死活監視間隔", false, false, "{0:n0}", null, true, "");
    MasterColumn column8 = new MasterColumn("$modalType", "詳細", false, false, null, null, true, "");
    MasterColumn column9 = new MasterColumn("useFunction", "使用可能機能", false, false, null, null, true, "");
    MasterColumn column10 = new MasterColumn("certificationKey", "認証キー", false, false, null, null, true, "");
    MasterColumn column11 = new MasterColumn("operation", "operation", true, false, null, null, true, "");
    MasterColumn column12 = new MasterColumn("allowAddRecord", "allowAddRecord", true, false, null, null, true, "");

    List<MasterColumn> columns = Arrays.asList(column1, column2, column3, column4, column5, column6, column7, column8, column9, column10, column11, column12);

    return columns;

  }

  /**
   * getMasterList()の検証.
   * <p>
   * 条件：成功 結果：成功レスポンスが返されること
   * </p>
   */
  @Test
  public void test_getMasterList_成功() throws Exception {

    // API実行
    ResultActions result = mockMvc
        .perform(get("/api/master_maintenance/master_list").contentType(MediaType.APPLICATION_JSON));

    // 検証
    result.andExpect(status().isOk()).andExpect(jsonPath("$.masterList", hasSize(3)))
        .andDo(document("master_maintenance/master_list/ok",
            responseFields(
              attributes(
                key("description").value(""),
                key("operationTargetTable").value("")
              ),
              fieldWithPath("masterList[]").description("[必須]マスタ一覧リスト"),
              fieldWithPath("masterList[].masterPhysicalName").description("マスタ物理名称"),
              fieldWithPath("masterList[].masterName").description("マスタ名"),
              fieldWithPath("masterList[].mode").description("マスタ編集画面の起動方法"),
              fieldWithPath("masterList[].editLevel").description("マスタ画面の権限"),
              fieldWithPath("masterList[].dispOrder").description("表示順"),
              fieldWithPath("masterList[].systemUseDisp").description("システム利用設定表示") 
              )));

    // 取得されたマスタ定義の検証
    List<MasterInfo> masterList = getMasterInfo();
    for (int i = 0; i < masterList.size(); i++) {
      String common = String.format("$.masterList[%d].", i);
      result.andExpect(jsonPath(common + "masterPhysicalName", is(masterList.get(i).masterPhysicalName)))
          .andExpect(jsonPath(common + "masterName", is(masterList.get(i).masterName)))
          .andExpect(jsonPath(common + "mode", is(masterList.get(i).mode)))
          .andExpect(jsonPath(common + "editLevel", is(masterList.get(i).editLevel)))
          .andExpect(jsonPath(common + "dispOrder", is(masterList.get(i).dispOrder)));
    }

  }

  /**
   * getMasterData()の検証.
   * <p>
   * 条件：成功 結果：成功レスポンスが返されること
   * </p>
   */
  @SuppressWarnings("serial")
  @Test
  public void test_getMasterData_成功() throws Exception {

    String masterName = "mst_facility";

    // API実行
    ResultActions result = mockMvc.perform(RestDocumentationRequestBuilders
        .get("/api/master_maintenance/{masterName}/data", masterName).contentType(MediaType.APPLICATION_JSON));

    // 検証
    result.andExpect(status().isOk()).andExpect(jsonPath("$.columns", hasSize(12)))
        .andExpect(jsonPath("$.localDataSource.schema.model.id", is("")))
        .andExpect(jsonPath("$.localDataSource.data", hasSize(1)))
        .andDo(document("master_maintenance/data/get/ok",
            pathParameters(parameterWithName("masterName").description("[必須]マスタ名称(物理名)")),
            responseFields(
              attributes(
                key("description").value(""),
                key("operationTargetTable").value("")
              ),
              fieldWithPath("columns[]").description("[必須]カラム情報(項目は取得マスタ毎に異なる)"),
                fieldWithPath("columns[].field").description("[必須]カラム名(物理名)"),
                fieldWithPath("columns[].title").description("[必須]カラム名(表示用)"),
                fieldWithPath("columns[].hidden").description("[必須]表示項目か否か"),
                fieldWithPath("columns[].locked").description("[必須]固定列か否か"),
                fieldWithPath("columns[].format").description("表示書式").optional(),
                fieldWithPath("columns[].values").description("コンボデータ").optional(),
                fieldWithPath("columns[].values[].value").description("コンボ値").optional(),
                fieldWithPath("columns[].values[].text").description("コンボテキスト").optional(),
                fieldWithPath("columns[].editable").description("編集可否"),
                fieldWithPath("columns[].dataType").description("データ型"),

                fieldWithPath("localDataSource.schema.model").description("[必須]KendoUIで使用するスキーマ情報"),
                fieldWithPath("localDataSource.schema.model.id").description("[必須]ID"),
                fieldWithPath("localDataSource.schema.model.fields").description("[必須]フィールド情報(項目は取得マスタ毎に異なる)"),
                fieldWithPath("localDataSource.schema.model.fields.facilityName").description("施設名"),
                fieldWithPath("localDataSource.schema.model.fields.facilityName.type").description("項目の型"),
                fieldWithPath("localDataSource.schema.model.fields.facilityName.validation").description("項目の入力チェック定義"),
                fieldWithPath("localDataSource.schema.model.fields.facilityName.validation.maxlength").description(
                    "最大桁数"),
                fieldWithPath("localDataSource.schema.model.fields.facilityNameKana").description("施設カナ名"),
                fieldWithPath("localDataSource.schema.model.fields.facilityNameKana.type").description("項目の型"),
                fieldWithPath("localDataSource.schema.model.fields.facilityNameKana.validation")
                    .description("項目の入力チェック定義"),
                fieldWithPath("localDataSource.schema.model.fields.facilityNameKana.validation.maxlength").description(
                    "最大桁数"),
                fieldWithPath("localDataSource.schema.model.fields.departmentCd").description("部署符号"),
                fieldWithPath("localDataSource.schema.model.fields.departmentCd.type").description("項目の型"),
                fieldWithPath("localDataSource.schema.model.fields.departmentCd.validation").description("項目の入力チェック定義"),
                fieldWithPath("localDataSource.schema.model.fields.departmentCd.validation.maxlength").description(
                    "最大桁数"),
                fieldWithPath("localDataSource.schema.model.fields.prefecturesCd").description("都道府県コード"),
                fieldWithPath("localDataSource.schema.model.fields.prefecturesCd.type").description("項目の型"),
                fieldWithPath("localDataSource.schema.model.fields.prefecturesCd.validation")
                    .description("項目の入力チェック定義"),
                fieldWithPath("localDataSource.schema.model.fields.prefecturesCd.validation.maxlength")
                    .description("最大桁数"),
                fieldWithPath("localDataSource.schema.model.fields.aliveMoniInterval").description("死活監視間隔"),
                fieldWithPath("localDataSource.schema.model.fields.aliveMoniInterval.type").description("項目の型"),
                fieldWithPath("localDataSource.schema.model.fields.aliveMoniInterval.validation")
                    .description("項目の入力チェック定義"),
                fieldWithPath("localDataSource.schema.model.fields.aliveMoniInterval.validation.min")
                    .description("最小値"),
                fieldWithPath("localDataSource.schema.model.fields.aliveMoniInterval.validation.max")
                    .description("最大値"),
                fieldWithPath("localDataSource.schema.model.fields.$modalType").description("モーダル"),
                fieldWithPath("localDataSource.schema.model.fields.$modalType.type").description("項目の型"),
                fieldWithPath("localDataSource.schema.model.fields.useFunction").description("使用可能機能"),
                fieldWithPath("localDataSource.schema.model.fields.useFunction.type").description("項目の型"),
                fieldWithPath("localDataSource.schema.model.fields.certificationKey").description("認証キー"),
                fieldWithPath("localDataSource.schema.model.fields.certificationKey.type").description("項目の型"),
                fieldWithPath("localDataSource.schema.model.fields.sortRank").description("第1ソートキー"),
                fieldWithPath("localDataSource.schema.model.fields.sortRank.type").description("項目の型"),
                fieldWithPath("localDataSource.schema.model.fields.sortRank.defaultValue").description("既定値"),
                fieldWithPath("localDataSource.schema.model.fields.sortRank.validation.min").description("最小値"),
                fieldWithPath("localDataSource.schema.model.fields.sortInputTime").description("第2ソートキー"),
                fieldWithPath("localDataSource.schema.model.fields.sortInputTime.type").description("項目の型"),

                fieldWithPath("localDataSource.data[]").description("[必須]マスタデータリスト(項目は取得マスタ毎に異なる)"),
                fieldWithPath("localDataSource.data[].facilityName").description("施設名"),
                fieldWithPath("localDataSource.data[].facilityNameKana").description("施設カナ名"),
                fieldWithPath("localDataSource.data[].prefecturesCd").description("都道府県コード"),
                fieldWithPath("localDataSource.data[].departmentCd").description("部署符号"),
                fieldWithPath("localDataSource.data[].aliveMoniInterval").description("死活監視間隔"),
                fieldWithPath("localDataSource.data[].useFunction").description("使用可能機能"),
                fieldWithPath("localDataSource.data[].certificationKey").description("認証キー"),
                fieldWithPath("localDataSource.data[].sortRank").description("第1ソートキー"),
                fieldWithPath("localDataSource.data[].sortInputTime").description("第2ソートキー"),
                fieldWithPath("localDataSource.data[].upDate").description("更新日時(排他制御用)")
              )));

    // 取得されたデータの検証
    List<Map<String, Object>> data = getMasterData();
    for (int i = 0; i < data.size(); i++) {
      String common = String.format("$.localDataSource.data[%d].", i);
      result.andExpect(jsonPath(common + "facilityName", is(data.get(i).get("facilityName"))))
          .andExpect(jsonPath(common + "facilityNameKana", is(data.get(i).get("facilityNameKana"))))
          .andExpect(jsonPath(common + "prefecturesCd", is(data.get(i).get("prefecturesCd"))))
          .andExpect(jsonPath(common + "departmentCd", is(data.get(i).get("departmentCd"))))
          .andExpect(jsonPath(common + "aliveMoniInterval", is(data.get(i).get("aliveMoniInterval"))))
          .andExpect(jsonPath(common + "useFunction", is(data.get(i).get("useFunction"))));
    }

    /**
     * レスポンスのスキーマ情報の検証
     * schemaにはtype, validation, sortRank, sortInputTimeしか設定されないこと
     * comboやjsonは、typeがstringに変換されること（SysMasterDefine.getSchemaType参照）
     */
    result
      .andExpect(jsonPath("$.localDataSource.schema.model.fields.facilityName", is(new HashMap<String, Object>() {
        {
          put("type", "string");
          put("validation", new HashMap<String, Object>() {{put("maxlength", 40);}});
        }
      })))
      .andExpect(jsonPath("$.localDataSource.schema.model.fields.facilityNameKana", is(new HashMap<String, Object>() {
        {
          put("type", "string");
          put("validation", new HashMap<String, Object>() {{put("maxlength", 50);}});
        }
      })))
      .andExpect(jsonPath("$.localDataSource.schema.model.fields.prefecturesCd", is(new HashMap<String, Object>() {
        {
          put("type", "string");
          put("validation", new HashMap<String, Object>() {{put("maxlength", 2);}});
        }
      })))
      .andExpect(jsonPath("$.localDataSource.schema.model.fields.departmentCd", is(new HashMap<String, Object>() {
        {
          put("type", "string");
          put("validation", new HashMap<String, Object>() {{put("maxlength", 4);}});
        }
      })))
      .andExpect(jsonPath("$.localDataSource.schema.model.fields.aliveMoniInterval", is(new HashMap<String, Object>() {
        {
          put("type", "number");
          put("validation", new HashMap<String, Object>() {{put("min", 1); put("max", 10);}});
        }
      })))
      .andExpect(jsonPath("$.localDataSource.schema.model.fields.useFunction", is(new HashMap<String, Object>() {
        {
          put("type", "string");
        }
      })))
      .andExpect(jsonPath("$.localDataSource.schema.model.fields.certificationKey", is(new HashMap<String, Object>() {
        {
          put("type", "string");
        }
      })))
      .andExpect(jsonPath("$.localDataSource.schema.model.fields.sortRank", is(new HashMap<String, Object>() {
        {
          put("type", "number");
          put("validation", new HashMap<String, Object>() {{put("min", 0);}});
          put("defaultValue", 0);
        }
      })))
      .andExpect(jsonPath("$.localDataSource.schema.model.fields.sortInputTime", is(new HashMap<String, Object>() {
        {
          put("type", "number");
        }
      })))
      .andExpect(jsonPath("$.localDataSource.schema.model.fields.$modalType", is(singletonMap("type", "modal"))))
    ;

    // 取得されたカラム情報の検証
    List<MasterColumn> columns = getColumns();
    for (int i = 0; i < columns.size(); i++) {
      String common = String.format("$.columns[%d].", i);
      if(i != 9) {
        result.andExpect(jsonPath(common + "field", is(columns.get(i).field)))
        .andExpect(jsonPath(common + "title", is(columns.get(i).title)))
        .andExpect(jsonPath(common + "hidden", is(columns.get(i).hidden)))
        .andExpect(jsonPath(common + "format", is(columns.get(i).format)))
        .andExpect(jsonPath(common + "values", is(columns.get(i).values)))
        .andExpect(jsonPath(common + "editable", is(columns.get(i).editable)));
      } else {
        result.andExpect(jsonPath(common + "field", is(columns.get(i).field)))
        .andExpect(jsonPath(common + "title", is(columns.get(i).title)))
        .andExpect(jsonPath(common + "hidden", is(columns.get(i).hidden)))
        .andExpect(jsonPath(common + "format", is(columns.get(i).format)))
        .andExpect(jsonPath(common + "values[0].value", is("")))
        .andExpect(jsonPath(common + "values[0].text", is(" ")))
        .andExpect(jsonPath(common + "values[1].value", is("902")))
        .andExpect(jsonPath(common + "values[1].text", is("90000052")))
        .andExpect(jsonPath(common + "values[2].value", is("901")))
        .andExpect(jsonPath(common + "values[2].text", is("90000021")))
        .andExpect(jsonPath(common + "editable", is(columns.get(i).editable)));
      }
    }
  }

  /**
   * updateMasterData()の検証.
   * <p>
   * 条件：成功(データ挿入、データ更新)
   * 結果：成功レスポンスが返されること
   * </p>
   */
   @Test
  public void test_updateMasterData_成功() throws Exception {

    // 事前準備
     @SuppressWarnings("serial")
     Map<String, Object> dataMap1 = new HashMap<String, Object>() {
       {
         put("code", 0);
         put("name", "name1");
         put("dataType", "0");
         put("machineTypeCd", "A1");
         put("contents", "{\"key\": \"value1\"}");
         put("operation", AdminWebConstant.MasterOperationType.INSERT);
         put("sortRank", 2);
         put("sortInputTime", 0);
       }
     };
     @SuppressWarnings("serial")
     Map<String, Object> dataMap2 = new HashMap<String, Object>() {
       {
         put("code", 21);
         put("name", "name21");
         put("dataType", "2");
         put("machineTypeCd", "A2");
         put("contents", "{\"key\": \"value21\"}");
         put("operation", AdminWebConstant.MasterOperationType.UPDATE);
         put("sortRank", 1);
         put("sortInputTime", 1402111112);
         put("upDate", "2019-09-13T14:00:00.000+09:00");
       }
     };
     @SuppressWarnings("serial")
     Map<String, Object> dataMap3 = new HashMap<String, Object>() {
       {
         put("code", 22);
         put("name", "name22");
         put("dataType", "2");
         put("machineTypeCd", "A2");
         put("contents", "");
         put("operation", 0);
         put("sortRank", 1);
         put("sortInputTime", 1402034304);
       }
     };
     @SuppressWarnings("serial")
     Map<String, Object> dataMap4 = new HashMap<String, Object>() {
       {
         put("code", 23);
         put("name", "name23");
         put("dataType", "2");
         put("machineTypeCd", "A2");
         put("contents", "");
         put("operation", 0);
         put("sortRank", 1);
         put("sortInputTime", 0);
         put("upDate", "2019-09-13T14:00:00.000+09:00");
       }
     };
     @SuppressWarnings("serial")
     Map<String, Object> dataMap5 = new HashMap<String, Object>() {
       {
         put("code", 934);
         put("name", "name3");
         put("dataType", "2");
         put("machineTypeCd", "A2");
         put("contents", "");
         put("operation", AdminWebConstant.MasterOperationType.UPDATE);
         put("sortRank", 3);
         put("sortInputTime", 0);
         put("upDate", "2019-09-13T14:02:00.000+09:00");
       }
     };
     @SuppressWarnings("serial")
     Map<String, Object> dataMap6 = new HashMap<String, Object>() {
       {
         put("code", 90009);
         put("name", "name3");
         put("dataType", "2");
         put("machineTypeCd", "A2");
         put("contents", "");
         put("operation", 0);
         put("sortRank", 0);
         put("sortInputTime", 0);
       }
     };
     @SuppressWarnings("serial")
     Map<String, Object> dataMap7 = new HashMap<String, Object>() {
       {
         put("code", 90008);
         put("name", "name3");
         put("dataType", "2");
         put("machineTypeCd", "A2");
         put("contents", "");
         put("operation", 0);
         put("sortRank", null);
         put("sortInputTime", 0);
       }
     };
    List<Map<String, Object>> data = Arrays.asList(dataMap1, dataMap2, dataMap3, dataMap4, dataMap5, dataMap6, dataMap7);
    MasterUpdateRequest request = new MasterUpdateRequest() {
      {
        setData(data);
      }
    };
    String masterPhysicalName = "mnt_motion_record";
    String requestBody = mapper.writeValueAsString(request);
    List<MntMotionRecord> before = mntMotionRecordDao.selectAll();

    // API実行
    ResultActions result = mockMvc
        .perform(RestDocumentationRequestBuilders.put("/api/master_maintenance/{masterName}/data", masterPhysicalName)
            .contentType(MediaType.APPLICATION_JSON).content(requestBody));

    // 検証
    result.andExpect(status().isOk()).andExpect(jsonPath("$.isSuccess", is(true)))
        .andExpect(jsonPath("$.errorMessage", nullValue()))
        .andDo(document("master_maintenance/data/put/ok",
            pathParameters(parameterWithName("masterName").description("[必須]マスタ名称(物理名)")),
            requestFields(
              attributes(
                key("description").value(""),
                key("operationTargetTable").value("")
              ),
              fieldWithPath("data[]").description("[必須]更新用マスタデータリスト(項目は更新マスタ毎に異なる)"),
                fieldWithPath("data[].code").description("コード"),
                fieldWithPath("data[].name").description("名称"),
                fieldWithPath("data[].dataType").description("データ種別"),
                fieldWithPath("data[].machineTypeCd").description("型式コード"),
                fieldWithPath("data[].contents").description("内容"),
                fieldWithPath("data[].operation").description("データ操作タイプ"),
                fieldWithPath("data[].sortRank").description("第1ソート順").optional(),
                fieldWithPath("data[].sortInputTime").description("第2ソート順"),
                fieldWithPath("data[].upDate").description("更新日時(排他制御用)").optional()
              )));

    // 追加後の施設マスタの検証
    List<MntMotionRecord> after = mntMotionRecordDao.selectAll();
    assertThat(before.size(), is(4)); // 追加前件数
    assertThat(after.size(), is(5));  // 1件追加
    // 追加されたデータの確認
    MntMotionRecord insertEntity = mntMotionRecordDao.selectByMotionRecordNo(2L);
    assertThat(insertEntity.getDataType(), is(0));
    assertThat(insertEntity.getMachineTypeCd(), is("A1"));
    assertThat(insertEntity.getMNoticeStatus(), is(nullValue()));
    assertThat(insertEntity.getContents(), is("{\"key\": \"value1\"}"));
    // 更新されたデータの確認
    MntMotionRecord updateEntity = mntMotionRecordDao.selectByMotionRecordNo(21L);
    assertThat(updateEntity.getDataType(), is(2));
    assertThat(updateEntity.getMachineTypeCd(), is("A2"));
    assertThat(updateEntity.getMNoticeStatus(), is(1));
    assertThat(updateEntity.getContents(), is("{\"key\": \"value21\"}"));
    // 追加後のマスタセレクタの検証
    MstSelector mstSelector = mstSelectorDao.selectByName("000001", masterPhysicalName);
    assertThat(mstSelector.getOrderSettings().getItems().get(2).getCode(), is(Long.parseLong(dataMap4.get("code").toString())));
    assertThat(mstSelector.getOrderSettings().getItems().get(2).getName(), is(dataMap4.get("name")));
    assertThat(mstSelector.getOrderSettings().getItems().get(3).getCode(), is(Long.parseLong(dataMap3.get("code").toString())));
    assertThat(mstSelector.getOrderSettings().getItems().get(3).getName(), is(dataMap3.get("name")));
    assertThat(mstSelector.getOrderSettings().getItems().get(4).getCode(), is(Long.parseLong(dataMap2.get("code").toString())));
    assertThat(mstSelector.getOrderSettings().getItems().get(4).getName(), is(dataMap2.get("name")));
    assertThat(mstSelector.getOrderSettings().getItems().get(5).getCode(), is(2L));
    assertThat(mstSelector.getOrderSettings().getItems().get(5).getName(), is(dataMap1.get("name")));
    assertThat(mstSelector.getOrderSettings().getItems().get(6).getCode(), is(Long.parseLong(dataMap5.get("code").toString())));
    assertThat(mstSelector.getOrderSettings().getItems().get(6).getName(), is(dataMap5.get("name")));
    assertThat(mstSelector.getOrderSettings().getItems().get(1).getCode(), is(Long.parseLong(dataMap7.get("code").toString())));
    assertThat(mstSelector.getOrderSettings().getItems().get(1).getName(), is(dataMap7.get("name")));
    assertThat(mstSelector.getOrderSettings().getItems().get(0).getCode(), is(Long.parseLong(dataMap6.get("code").toString())));
    assertThat(mstSelector.getOrderSettings().getItems().get(0).getName(), is(dataMap6.get("name")));


   }

  /**
   * getColumnInfo()の検証.
   * <p>
   * 条件：成功 結果：成功レスポンスが返されること
   * </p>
   */
  @SuppressWarnings("serial")
  @Test
  public void test_getColumnInfo_成功() throws Exception {

    String masterName = "test_master";

    // API実行
    ResultActions result = mockMvc.perform(RestDocumentationRequestBuilders
      .get("/api/master_maintenance/{masterName}/column_info", masterName).contentType(MediaType.APPLICATION_JSON));

    // 検証
    result.andExpect(status().isOk())
      .andExpect(jsonPath("$.fields", hasSize(1)))
      .andExpect(jsonPath("$.fields[0].physical_name", is("facility_name")))
      .andExpect(jsonPath("$.fields[0].title", is("施設名")))
      .andExpect(jsonPath("$.fields[0].type", is("string")))
      .andExpect(jsonPath("$.fields[0].selectable", is(true)))
      .andExpect(jsonPath("$.fields[0].editable", is(true)))
      .andExpect(jsonPath("$.fields[0].validation.maxlength", is(40)))
      .andExpect(jsonPath("$.fields[0].validation.min", is(1)))
      .andExpect(jsonPath("$.fields[0].validation.max", is(100)))
      .andExpect(jsonPath("$.fields[0].validation.required", is(true)))
      .andExpect(jsonPath("$.fields[0].format", is("string")))
      .andExpect(jsonPath("$.fields[0].alias", is("name")))
      .andExpect(jsonPath("$.fields[0].hidden", is(false)))
      .andExpect(jsonPath("$.fields[0].defaultValue", is("1")))
      .andDo(document("master_maintenance/column_info/get/ok",
        pathParameters(parameterWithName("masterName").description("[必須]マスタ名称(物理名)")),
        responseFields(
          attributes(
            key("description").value("概要：指定されたマスタに該当するカラム定義情報を取得するAPI"),
            key("operationTargetTable").value("操作対象テーブル：マスタ定義 (sys_master_define)")
          ),
          fieldWithPath("fields[]").description("カラム名(物理名)"),
          fieldWithPath("fields[].physical_name").description("マスタ名称(物理名)"),
          fieldWithPath("fields[].title").description("カラム名(表示用)"),
          fieldWithPath("fields[].type").description("データ型"),
          fieldWithPath("fields[].selectable").description("選択可否").optional(),
          fieldWithPath("fields[].editable").description("編集可否").optional(),
          fieldWithPath("fields[].validation").description("項目の入力チェック定義").optional(),
          fieldWithPath("fields[].validation.maxlength").description("最大桁数").optional(),
          fieldWithPath("fields[].validation.min").description("最小値").optional(),
          fieldWithPath("fields[].validation.max").description("最大値").optional(),
          fieldWithPath("fields[].validation.required").description("必須項目か否か"),
          fieldWithPath("fields[].format").description("表示書式").optional(),
          fieldWithPath("fields[].alias").description("別名指定").optional(),
          fieldWithPath("fields[].hidden").description("表示項目か否か").optional(),
          fieldWithPath("fields[].locked").description("グリッド上の固定列制御").optional(),
          fieldWithPath("fields[].defaultValue").description("既定値").optional(),
          fieldWithPath("fields[].schemaType").ignored(),
          fieldWithPath("fields[].fieldName").ignored(),
          fieldWithPath("fields[].camelFieldName").ignored(),
          fieldWithPath("fields[].sqlColumnName").ignored(),
          fieldWithPath("fields[].aliasCodeColumn").ignored(),
          fieldWithPath("fields[].hiddenColumn").ignored(),
          fieldWithPath("fields[].comboColumn").ignored(),
          fieldWithPath("fields[].lockedColumn").ignored()
        )));
  }

}
