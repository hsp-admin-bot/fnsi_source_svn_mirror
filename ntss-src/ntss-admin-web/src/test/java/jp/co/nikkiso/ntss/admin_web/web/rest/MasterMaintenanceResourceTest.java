package jp.co.nikkiso.ntss.admin_web.web.rest;

import static java.util.Collections.emptyList;
import static java.util.Collections.emptyMap;
import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.notNullValue;
import static org.hamcrest.Matchers.nullValue;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.anyList;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import jp.co.nikkiso.ntss.core.entity.SysMasterDefine;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.web.servlet.ResultActions;
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders;

import com.fasterxml.jackson.databind.ObjectMapper;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebMessage;
import jp.co.nikkiso.ntss.admin_web.request.masterMaintenance.MasterUpdateRequest;
import jp.co.nikkiso.ntss.admin_web.response.masterMaintenance.MasterColumn;
import jp.co.nikkiso.ntss.admin_web.response.masterMaintenance.MasterDataResponse;
import jp.co.nikkiso.ntss.admin_web.response.masterMaintenance.MasterInfo;
import jp.co.nikkiso.ntss.admin_web.response.masterMaintenance.MasterListResponse;
import jp.co.nikkiso.ntss.admin_web.response.masterMaintenance.MasterUpdateResponse;
import jp.co.nikkiso.ntss.admin_web.service.master.MasterEditService;
import jp.co.nikkiso.ntss.admin_web.service.master.MasterListService;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;

/**
 * MasterMaintenanceResourceのテストクラス
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@AutoConfigureMockMvc
public class MasterMaintenanceResourceTest extends AbstractResourceTest {

  /**
   * ObjectMapper.
   */
  @Autowired
  private ObjectMapper mapper;

  /**
   * マスタ一覧のService.
   */
  @MockBean
  private MasterListService masterListService;

  /**
   * マスタ編集のService.
   */
  @MockBean
  private MasterEditService masterEditService;

  /**
   * 検証用のマスタ一覧データ(レスポンス)
   */
  private List<MasterInfo> getMasterInfos() {
    List<MasterInfo> masterInfo = Arrays.asList(new MasterInfo("000001", "マスタ名称１", "1", "1", 1, "1"),
        new MasterInfo("000002", "マスタ名称２", "2", "1", 2, "1"));
    return masterInfo;
  }

  /**
   * 検証用のマスタデータ(レスポンス)
   */
  private MasterDataResponse getMasterData() {

    MasterDataResponse masterDataResponse = new MasterDataResponse();

    // カラム情報
    List<MasterColumn> masterColumns = new ArrayList<MasterColumn>();

    MasterColumn masterColumn = new MasterColumn("facilityCd", "施設コード", true, false, null, null, true, "");
    masterColumns.add(masterColumn);
    masterDataResponse.columns = masterColumns;

    // スキーマ情報
    Map<String, Object> fieldsMap = new HashMap<>();
    fieldsMap.put("facilityCd", "type=STRING");

    masterDataResponse.localDataSource.schema.model.fields = fieldsMap;

    // 取得マスタデータ
    Map<String, Object> dataMap1 = new HashMap<>();
    dataMap1.put("facilityCd", "10001");
    dataMap1.put("facilityName", "施設名");
    dataMap1.put("facilityNameKana", "施設カナ名");
    dataMap1.put("prefecturesCd", "01");
    dataMap1.put("departmentCd", "A1");
    dataMap1.put("aliveMoniInterval", 1);
    Map<String, Object> dataMap2 = new HashMap<>();
    dataMap2.put("facilityCd", "10002");
    dataMap2.put("facilityName", "施設名2");
    dataMap2.put("facilityNameKana", "施設カナ名2");
    dataMap2.put("prefecturesCd", "02");
    dataMap2.put("departmentCd", "A2");
    dataMap2.put("aliveMoniInterval", 2);
    List<Map<String, Object>> data = Arrays.asList(dataMap1, dataMap2);
    masterDataResponse.localDataSource.data = data;

    return masterDataResponse;
  }

  /**
   * getMasterList()の検証.
   * <p>
   * 条件：成功 結果：成功レスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser(facilityCd = "facilityCd", userType = 1)
  public void test_getMasterList_成功_取得複数件() throws Exception {

    MasterListResponse res = new MasterListResponse() {
      {
        masterList = getMasterInfos();
      }
    };

    // Mock化
    given(masterListService.getMasterList(anyInt())).willReturn(res);

    // API実行
    Integer userType = Integer.parseInt(CoreConstant.UserType.NIKKISO);
    ResultActions result = mockMvc.perform(MockMvcRequestBuilders.get("/api/master_maintenance/master_list")
        .contentType(MediaType.APPLICATION_JSON_UTF8));

    // 検証
    verify(masterListService, times(1)).getMasterList(userType);
    result.andExpect(status().isOk()).andExpect(jsonPath("$.masterList", hasSize(res.masterList.size())));
    for (int i = 0; i < res.masterList.size(); i++) {
      result.andExpect(
          jsonPath("$.masterList[" + i + "].masterPhysicalName", is(res.masterList.get(i).masterPhysicalName)));
      result.andExpect(jsonPath("$.masterList[" + i + "].masterName", is(res.masterList.get(i).masterName)));
      result.andExpect(jsonPath("$.masterList[" + i + "].mode", is(res.masterList.get(i).mode)));
      result.andExpect(jsonPath("$.masterList[" + i + "].editLevel", is(res.masterList.get(i).editLevel)));
    }
  }

  /**
   * getMasterList()の検証.
   * <p>
   * 条件：成功 結果：成功レスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser(facilityCd = "facilityCd")
  public void test_getMasterList_成功_取得ゼロ件() throws Exception {

    MasterListResponse res = new MasterListResponse() {
      {
        masterList = emptyList();
      }
    };

    // Mock化
    given(masterListService.getMasterList(anyInt())).willReturn(res);

    // API実行
    Integer userType = Integer.parseInt(CoreConstant.UserType.GENERAL);
    ResultActions result = mockMvc.perform(MockMvcRequestBuilders.get("/api/master_maintenance/master_list")
        .contentType(MediaType.APPLICATION_JSON_UTF8));

    // 検証
    verify(masterListService, times(1)).getMasterList(userType);
    result.andExpect(status().isOk()).andExpect(jsonPath("$.masterList", hasSize(res.masterList.size())));
  }

  /**
   * getMasterData()の検証.
   * <p>
   * 条件：成功 結果：成功レスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser(facilityCd = "facilityCd")
  public void test_getMasterData_成功_取得複数件() throws Exception {
    // arrange
    final MasterDataResponse res = getMasterData();

    // Mock化
    given(masterEditService.getMasterData(anyString(), anyString())).willReturn(res);

    final String masterName = "anyMaster";
    final String facilityCd = "facilityCd";

    // action
    final ResultActions result = mockMvc
        .perform(MockMvcRequestBuilders.get("/api/master_maintenance/{masterName}/data", masterName)
          .contentType(MediaType.APPLICATION_JSON_UTF8));

    // assert
    result
      .andExpect(status().isOk())
      .andExpect(jsonPath("$.columns", hasSize(1)))
      .andExpect(jsonPath("$.columns[0].field", is("facilityCd")))
      .andExpect(jsonPath("$.columns[0].title", is("施設コード")))
      .andExpect(jsonPath("$.columns[0].hidden", is(true)))
      .andExpect(jsonPath("$.columns[0].format", nullValue()))
      .andExpect(jsonPath("$.columns[0].values", nullValue()))
      .andExpect(jsonPath("$.columns[0].editable", is(true)))
      .andExpect(jsonPath("$.localDataSource.schema.model.id", is("")))
      .andExpect(jsonPath("$.localDataSource.schema.model.fields.facilityCd", is("type=STRING")))
      .andExpect(jsonPath("$.localDataSource.data", hasSize(2)))
      .andExpect(jsonPath("$.localDataSource.data[0].facilityCd", is("10001")))
      .andExpect(jsonPath("$.localDataSource.data[0].facilityName", is("施設名")))
      .andExpect(jsonPath("$.localDataSource.data[0].facilityNameKana", is("施設カナ名")))
      .andExpect(jsonPath("$.localDataSource.data[0].prefecturesCd", is("01")))
      .andExpect(jsonPath("$.localDataSource.data[0].departmentCd", is("A1")))
      .andExpect(jsonPath("$.localDataSource.data[0].aliveMoniInterval", is(1)))
      .andExpect(jsonPath("$.localDataSource.data[1].facilityCd", is("10002")))
      .andExpect(jsonPath("$.localDataSource.data[1].facilityName", is("施設名2")))
      .andExpect(jsonPath("$.localDataSource.data[1].facilityNameKana", is("施設カナ名2")))
      .andExpect(jsonPath("$.localDataSource.data[1].prefecturesCd", is("02")))
      .andExpect(jsonPath("$.localDataSource.data[1].departmentCd", is("A2")))
      .andExpect(jsonPath("$.localDataSource.data[1].aliveMoniInterval", is(2)))
    ;

    verify(masterEditService, times(1)).getMasterData(masterName, facilityCd);
  }

  /**
   * getMasterData()の検証.
   * <p>
   * 条件：成功 結果：成功レスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser(facilityCd = "facilityCd")
  public void test_getMasterData_成功_取得ゼロ件() throws Exception {

    // arrange
    MasterDataResponse res = new MasterDataResponse() {
      {
        localDataSource.data = emptyList();
      }
    };

    // Mock化
    given(masterEditService.getMasterData(anyString(), anyString())).willReturn(res);

    String masterName = "anyMaster";
    String facilityCd = "facilityCd";

    // action
    ResultActions result = mockMvc
      .perform(MockMvcRequestBuilders.get("/api/master_maintenance/{masterName}/data", masterName)
        .contentType(MediaType.APPLICATION_JSON_UTF8));

    // assert
    verify(masterEditService, times(1)).getMasterData(masterName, facilityCd);
    result.andExpect(status().isOk())
      .andExpect(jsonPath("$.columns", hasSize(0)))
      .andExpect(jsonPath("$.localDataSource.schema.model.id", is("")))
      .andExpect(jsonPath("$.localDataSource.schema.model.fields", is(emptyMap())))
      .andExpect(jsonPath("$.localDataSource.data", hasSize(0)))
    ;
  }

  /**
   * updateMasterData()の検証.
   * <p>
   * 条件：成功
   * 結果：成功レスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser(facilityCd = "facilityCd")
  public void test_updateMasterData_成功() throws Exception {

    // 事前準備
    @SuppressWarnings("serial")
    Map<String, Object> dataMap1 = new HashMap<String, Object>() {
      {
        put("code", "10001");
        put("name", "施設名");
        put("facilityNameKana", "施設カナ名");
        put("prefecturesCd", "01");
        put("departmentCd", "A1");
        put("aliveMoniInterval", 1);
        put("operation", AdminWebConstant.MasterOperationType.INSERT);
      }
    };
    @SuppressWarnings("serial")
    Map<String, Object> dataMap2 = new HashMap<String, Object>() {
      {
        put("code", "10002");
        put("name", "施設名2");
        put("facilityNameKana", "施設カナ名2");
        put("prefecturesCd", "02");
        put("departmentCd", "A2");
        put("operation", AdminWebConstant.MasterOperationType.UPDATE);
      }
    };
    List<Map<String, Object>> data = Arrays.asList(dataMap1, dataMap2);

    MasterUpdateRequest request = new MasterUpdateRequest() {
      {
        setData(data);
      }
    };

    String requestBody = mapper.writeValueAsString(request);
    String masterPhysicalName = "someMasterName";
    String facilityCd = "facilityCd";

    // Mock化
    given(masterEditService.updateMasterData(anyString(), anyString(), anyList()))
        .willReturn(new MasterUpdateResponse());

    // API実行
    ResultActions result = mockMvc
        .perform(MockMvcRequestBuilders.put("/api/master_maintenance/{masterPhysicalName}/data", masterPhysicalName)
            .contentType(MediaType.APPLICATION_JSON_UTF8).content(requestBody).with(csrf()));

    // 検証
    verify(masterEditService, times(1)).updateMasterData(masterPhysicalName, facilityCd, data);
    result.andExpect(status().isOk()).andExpect(jsonPath("$.isSuccess", is(true)))
        .andExpect(jsonPath("$.errorMessage", nullValue()));
  }

  /**
   * updateMasterData()の検証.
   * <p>
   * 条件：DB更新失敗
   * 結果：エラーメッセージの設定されたレスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser(facilityCd = "facilityCd")
  public void test_updateMasterData_失敗() throws Exception {

    // 事前準備
    @SuppressWarnings("serial")
    Map<String, Object> dataMap1 = new HashMap<String, Object>() {
      {
        put("code", "10001");
        put("name", "施設名");
        put("facilityNameKana", "施設カナ名");
        put("prefecturesCd", "01");
        put("departmentCd", "A1");
        put("aliveMoniInterval", 1);
        put("operation", AdminWebConstant.MasterOperationType.INSERT);
      }
    };
    List<Map<String, Object>> data = Arrays.asList(dataMap1);

    MasterUpdateRequest request = new MasterUpdateRequest() {
      {
        setData(data);
      }
    };
    String requestBody = mapper.writeValueAsString(request);
    String masterPhysicalName = "someMasterName";
    String facilityCd = "facilityCd";

    // Mock化
    given(masterEditService.updateMasterData(anyString(), anyString(), anyList())).willAnswer(invocation -> {
      throw new RuntimeException("例外が発生しました");
    });

    // API実行
    ResultActions result = mockMvc
        .perform(MockMvcRequestBuilders.put("/api/master_maintenance/{masterName}/data", masterPhysicalName)
            .contentType(MediaType.APPLICATION_JSON_UTF8).content(requestBody).with(csrf()));

    // 検証
    verify(masterEditService, times(1)).updateMasterData(masterPhysicalName, facilityCd, data);
    result.andExpect(status().isBadRequest()).andExpect(jsonPath("$.isSuccess", is(false)))
        .andExpect(jsonPath("$.errorMessage", notNullValue()))
        .andExpect(jsonPath("$.errorMessage", is(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage())));
  }

  /**
   * getColumnInfo()の検証.
   * <p>
   * 条件：成功 結果：成功レスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser
  public void test_getColumnInfo_成功_カラム情報あり() throws Exception {
    // arrange
    final SysMasterDefine.ColumnInfo res = new SysMasterDefine.ColumnInfo("{\"fields\": [{\"type\": \"number\", \"alias\": \"code\", \"title\": \"治療方法コード\", \"format\": null, \"hidden\": \"true\", \"editable\": \"false\", \"validation\": {\"max\": null, \"min\": null, \"required\": \"true\", \"maxlength\": null}, \"physical_name\": \"treatment_cd\"}]}");

    // Mock化
    given(masterEditService.getColumnInfo(anyString())).willReturn(res);

    final String masterName = "anyMaster";

    // action
    final ResultActions result = mockMvc
      .perform(MockMvcRequestBuilders.get("/api/master_maintenance/{masterName}/column_info", masterName)
        .contentType(MediaType.APPLICATION_JSON_UTF8));

    // assert
    result
      .andExpect(status().isOk())
      .andExpect(jsonPath("$.fields", hasSize(1)))
      .andExpect(jsonPath("$.fields[0].physical_name", is("treatment_cd")))
      .andExpect(jsonPath("$.fields[0].title", is("治療方法コード")))
      .andExpect(jsonPath("$.fields[0].type", is("number")))
      .andExpect(jsonPath("$.fields[0].selectable", nullValue()))
      .andExpect(jsonPath("$.fields[0].editable", is(false)))
      .andExpect(jsonPath("$.fields[0].validation.maxlength", nullValue()))
      .andExpect(jsonPath("$.fields[0].validation.min", nullValue()))
      .andExpect(jsonPath("$.fields[0].validation.max", nullValue()))
      .andExpect(jsonPath("$.fields[0].validation.required", is(true)))
      .andExpect(jsonPath("$.fields[0].format", nullValue()))
      .andExpect(jsonPath("$.fields[0].alias", is("code")))
      .andExpect(jsonPath("$.fields[0].hidden", is(true)))
      .andExpect(jsonPath("$.fields[0].defaultValue", nullValue()))
    ;

    verify(masterEditService, times(1)).getColumnInfo(masterName);
  }

  /**
   * getColumnInfo()の検証.
   * <p>
   * 条件：成功 結果：成功レスポンスが返されること
   * </p>
   */
  @Test
  @NtssMockUser
  public void test_getColumnInfo_成功_カラム情報なし() throws Exception {
    // arrange
    final SysMasterDefine.ColumnInfo res = new SysMasterDefine.ColumnInfo("{\"fields\": []}");

    // Mock化
    given(masterEditService.getColumnInfo(anyString())).willReturn(res);

    final String masterName = "anyMaster";

    // action
    final ResultActions result = mockMvc
      .perform(MockMvcRequestBuilders.get("/api/master_maintenance/{masterName}/column_info", masterName)
        .contentType(MediaType.APPLICATION_JSON_UTF8));

    // assert
    result
      .andExpect(status().isOk())
      .andExpect(jsonPath("$.fields", hasSize(0)))
    ;

    verify(masterEditService, times(1)).getColumnInfo(masterName);
  }

}
