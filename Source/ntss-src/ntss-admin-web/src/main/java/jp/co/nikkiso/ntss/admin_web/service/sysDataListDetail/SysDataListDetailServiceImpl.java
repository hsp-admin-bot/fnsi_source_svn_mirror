package jp.co.nikkiso.ntss.admin_web.service.sysDataListDetail;

import jp.co.nikkiso.ntss.core.entity.DataListAggregationParam;
import jp.co.nikkiso.ntss.core.entity.custom.PatIdRstAnchor;
import org.springframework.util.CollectionUtils;
import tools.jackson.core.type.TypeReference;
import tools.jackson.databind.ObjectMapper;
import com.google.common.base.Strings;
import com.google.common.collect.Lists;
import jp.co.nikkiso.ntss.admin_web.response.sysDataListDetail.SysDataListDetailResponse;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.api.service.SysDataSetService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.FUNCTION_CODE;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.DevMenteMainDao;
import jp.co.nikkiso.ntss.core.dao.MniMonitorDao;
import jp.co.nikkiso.ntss.core.dao.MntMotionRecordDao;
import jp.co.nikkiso.ntss.core.dao.MstAdditionDao;
import jp.co.nikkiso.ntss.core.dao.MstCourseDao;
import jp.co.nikkiso.ntss.core.dao.MstDeviceSetInfoDefaultDao;
import jp.co.nikkiso.ntss.core.dao.MstDialyzerDao;
import jp.co.nikkiso.ntss.core.dao.MstDiseaseDao;
import jp.co.nikkiso.ntss.core.dao.MstEquipmentDao;
import jp.co.nikkiso.ntss.core.dao.MstExamItemDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilityDao;
import jp.co.nikkiso.ntss.core.dao.MstImplantDao;
import jp.co.nikkiso.ntss.core.dao.MstInfectionDao;
import jp.co.nikkiso.ntss.core.dao.MstInsuranceDao;
import jp.co.nikkiso.ntss.core.dao.MstMachineDao;
import jp.co.nikkiso.ntss.core.dao.MstMedicineDao;
import jp.co.nikkiso.ntss.core.dao.MstMedicineMixDao;
import jp.co.nikkiso.ntss.core.dao.MstPatListLayoutDao;
import jp.co.nikkiso.ntss.core.dao.MstPersonalUserDao;
import jp.co.nikkiso.ntss.core.dao.MstSelectorDao;
import jp.co.nikkiso.ntss.core.dao.MstTabooAllergyDao;
import jp.co.nikkiso.ntss.core.dao.MstWaterSurveyTypeDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.PatExamMainDao;
import jp.co.nikkiso.ntss.core.dao.PatGroupDao;
import jp.co.nikkiso.ntss.core.dao.PatInsuranceDao;
import jp.co.nikkiso.ntss.core.dao.PatMainDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.dao.PatUniqueDao;
import jp.co.nikkiso.ntss.core.dao.SysDataListCategoryDao;
import jp.co.nikkiso.ntss.core.dao.SysDataListDetailDao;
import jp.co.nikkiso.ntss.core.dao.SysFacilityDao;
import jp.co.nikkiso.ntss.core.dao.SysGenericMedicineDao;
import jp.co.nikkiso.ntss.core.entity.DevMenteMain;
import jp.co.nikkiso.ntss.core.entity.MniMonitor;
import jp.co.nikkiso.ntss.core.entity.MntMotionRecord;
import jp.co.nikkiso.ntss.core.entity.MstAddition;
import jp.co.nikkiso.ntss.core.entity.MstCourse;
import jp.co.nikkiso.ntss.core.entity.MstDialyzer;
import jp.co.nikkiso.ntss.core.entity.MstDisease;
import jp.co.nikkiso.ntss.core.entity.MstEquipment;
import jp.co.nikkiso.ntss.core.entity.MstExamItem;
import jp.co.nikkiso.ntss.core.entity.MstImplant;
import jp.co.nikkiso.ntss.core.entity.MstInfection;
import jp.co.nikkiso.ntss.core.entity.MstMachineDatalist;
import jp.co.nikkiso.ntss.core.entity.MstMachineDatalistInit;
import jp.co.nikkiso.ntss.core.entity.MstMachineDatalistMainte;
import jp.co.nikkiso.ntss.core.entity.MstMedicine;
import jp.co.nikkiso.ntss.core.entity.MstMedicineMix;
import jp.co.nikkiso.ntss.core.entity.MstObsKind;
import jp.co.nikkiso.ntss.core.entity.MstPatListLayout;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.entity.MstSelector;
import jp.co.nikkiso.ntss.core.entity.MstTabooAllergy;
import jp.co.nikkiso.ntss.core.entity.MstWaterSurveyPointType;
import jp.co.nikkiso.ntss.core.entity.MstWaterSurveyType;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.PatGroup;
import jp.co.nikkiso.ntss.core.entity.PatInsurance;
import jp.co.nikkiso.ntss.core.entity.PatMain;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.PatUnique;
import jp.co.nikkiso.ntss.core.entity.SysDataListCategory;
import jp.co.nikkiso.ntss.core.entity.SysDataListDetail;
import jp.co.nikkiso.ntss.core.entity.SysFacility;
import jp.co.nikkiso.ntss.core.entity.SysGenericMedicine;
import jp.co.nikkiso.ntss.core.entity.custom.AdditionInfoOrdMain;
import jp.co.nikkiso.ntss.core.entity.custom.PatNameId;
import jp.co.nikkiso.ntss.core.entity.custom.TemplateHospitalCd;
import jp.co.nikkiso.ntss.core.entity.custom.TemplateMachine;
import jp.co.nikkiso.ntss.core.entity.custom.TemplateMedicine;
import jp.co.nikkiso.ntss.core.entity.custom.TemplateMonitor;
import jp.co.nikkiso.ntss.core.entity.custom.TemplateOrdMain;
import jp.co.nikkiso.ntss.core.entity.custom.TemplatePatExamMain;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.json.JSONArray;
import org.json.JSONObject;
import org.seasar.doma.jdbc.Config;
import org.seasar.doma.jdbc.SelectOptions;
import org.seasar.doma.jdbc.builder.SelectBuilder;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.text.SimpleDateFormat;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.StringJoiner;
import java.util.stream.Collectors;

import static java.util.Map.Entry.comparingByKey;
import jp.co.nikkiso.ntss.core.config.DefaultDb;
/**
 * データリストカテゴリ詳細の実装インタフェース
 */
@Service
public class SysDataListDetailServiceImpl implements SysDataListDetailService {

  /**
  * データリストカテゴリのDAO
  */
  @Autowired
  private SysDataListCategoryDao sysDataListCategoryDao;

  /**
   * データリストカテゴリ詳細のDAO
   */
  @Autowired
  private SysDataListDetailDao sysDataListDetailDao;

  /**
   * 患者治療パターンクラスのDAO
   */
  @Autowired
  private MstPatListLayoutDao mstPatListLayoutDao;

  /**
   * データセットのDAO
   */
  @Autowired
  private SysDataSetService sysDataSetService;

  /**
   *ログ出力サービス
   */
  @Autowired
  private LogService logService;
// add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 dou start

  /**
   * 装置動作記録DaoのMockBean.
   */
  @Autowired
  private MntMotionRecordDao mntMotionRecordDao;

  /**
   * 機器保守のDaoインタフェース
   */
  @Autowired
  DevMenteMainDao devMenteMainDao;

  @Autowired
  private OrdMainDao ordMainDao;

  @Autowired
  private PatPersonalMainDao patPersonalMainDao;

  @Autowired
  private PatMainDao patMainDao;

  @Autowired
  private PatExamMainDao patExamMainDao;

  @Autowired
  private PatInsuranceDao patInsuranceDao;

  @Autowired
  private MstInsuranceDao mstInsuranceDao;

  @Autowired
  private MniMonitorDao mniMonitorDao;

  @Autowired
  private MstPersonalUserDao mstPersonalUserDao;

  @Autowired
  private PatUniqueDao patUniqueDao;

  @Autowired
  private MstFacilityDao mstFacilityDao;

  @Autowired
  private MstDiseaseDao mstDiseaseDao;

  @Autowired
  private MstCourseDao mstCourseDao;

  @Autowired
  private PatGroupDao patGroupDao;

  @Autowired
  private MstImplantDao mstImplantDao;

  @Autowired
  private MstTabooAllergyDao mstTabooAllergyDao;

  @Autowired
  private MstInfectionDao mstInfectionDao;

  @Autowired
  private MstMachineDao mstMachineDao;

  @Autowired
  MstDeviceSetInfoDefaultDao mstDeviceSetInfoDefaultDao;

  // add FNSI6516-テンプレート：検査結果の表示順不正 周 start
  @Autowired
  MstSelectorDao mstSelectorDao;
  // add FNSI6516-テンプレート：検査結果の表示順不正 周 end

  @Autowired
  private MstAdditionDao mstAdditionDao;
  //add 5222 施設、入外、コメントが表示されない 張 start
  @Autowired
  private SysFacilityDao sysFacilityDao;
  //add 5222 施設、入外、コメントが表示されない 張 end
// add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 dou end
  /*add FNSI-改修内容5237 任 start*/
  @Autowired
  private MstExamItemDao mstExamItemDao;

  @Autowired
  private MstWaterSurveyTypeDao mstWaterSurveyTypeDao;
  /*add FNSI-改修内容5237 任 end*/
  /**
   * マスタに表示用のデータリストカテゴリ詳細項目を取得
   * @param templateCd テンプレートコード
   * @return データリストカテゴリ詳細レスポンスリスト
   */
  @Override
  public List<SysDataListDetailResponse> getDataListItemDisplayMaster(Integer templateCd, String facilityCd) throws Exception {
	List<SysDataListDetailResponse> listItemData = new ArrayList<>();
    if (templateCd != null) {
      // データリストカテゴリ配列を取得し、変数に代入
      List<SysDataListCategory> listCategory = sysDataListCategoryDao.selectByTemplateCd(templateCd);

      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("データリストカテゴリ配列を取得し、変数に代入");
      eventLogMessage.setSqlIdentification("(template_cd = " + templateCd + ")");
      logService.log(LogLevel.INFO, eventLogMessage,FUNCTION_CODE.FUNC_MULTI_PAT_LIST ,SERVICE_NAME.FNSI, "SysDataListCategoryDao/selectByTemplateCd");

      List<Long> listCategoryCd = new ArrayList<Long>();
      if (listCategory.size() > 0) {
        listCategory.forEach(i -> {
          listCategoryCd.add(i.getCategoryCd());
        });
        // データリストカテゴリ詳細リスト
        List<SysDataListDetail> listDataListDetail = sysDataListDetailDao.selectByListCategory(listCategoryCd);

       eventLogMessage.setLogMessage("データリストカテゴリ詳細リスト");
       eventLogMessage.setSqlIdentification("(category_cd in " + listCategoryCd + ")");
       logService.log(LogLevel.INFO, eventLogMessage,FUNCTION_CODE.FUNC_MULTI_PAT_LIST ,SERVICE_NAME.FNSI, "SysDataListDetailDao/selectByListCategory");

       if (listDataListDetail.size() > 0) {

          listDataListDetail.stream().forEach(i -> {
            SysDataListDetailResponse rs = new SysDataListDetailResponse();
            List<Map<String, Object>> listItem = new ArrayList<>();
            rs.setDataListDetailCd(i.getDataListDetailCd());
            rs.setCategoryCd(i.getCategoryCd());
            rs.setDispOrder(i.getDispOrder());
            rs.setDisplayName(i.getMasterDisplayName());
            if (i.getMasterDisplayType().equals("1")) {
              Map<String, Object> dataKey = new HashMap<>();
              dataKey.put("facilityCd", facilityCd);
              // マスタ表示SQLによりデータリストを取得
              listItem = getDataList(i.getMasterDisplaySql(), dataKey);
              rs.setItems(listItem);
            } else {
              rs.setDisplayName(null);
              Map<String, Object> it = new HashMap<>();
              it.put("id", 0);
              it.put("name", i.getMasterDisplayName());
              listItem.add(it);
              rs.setItems(listItem);
            }
            listItemData.add(rs);
          });
        }
      }
    }

    return listItemData;
  }

  /**
   * 該当機能に表示用のデータリストカテゴリ詳細項目を取得
   * @param patListLayoutCd
   * @return データリストカテゴリ詳細レスポンスリスト
   */
  @Override
  public List<SysDataListDetailResponse> getDataListItemDisplayFuntion(Long patListLayoutCd, String facilityCd) throws Exception {
    ObjectMapper mapper = new ObjectMapper();
    // 患者治療パターンコードにより患者治療パターンを取得
    MstPatListLayout layout = mstPatListLayoutDao.selectByCd(patListLayoutCd);

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("患者治療パターンコードにより患者治療パターンを取得");
    eventLogMessage.setSqlIdentification("(pat_list_layout_cd = " + patListLayoutCd + ")");
    logService.log(LogLevel.INFO, eventLogMessage,FUNCTION_CODE.FUNC_MULTI_PAT_LIST ,SERVICE_NAME.FNSI, "MstPatListLayoutDao/selectByCd");

    List<SysDataListDetailResponse> listItemData = new ArrayList<>();
    if (layout != null) {
      List<Map<String, Object>> listItemInfo = mapper.readValue(layout.getDispItemInfo(),new TypeReference<List<Map<String, Object>>>() {});
      if (listItemInfo.size() > 0) {
        // add #11528 【たくしん会】データリスト並び順不正 房 start
        if(layout.getTemplateCd() == 10) {
          // 水質検査の場合、検査種別出力対象が必要です。
          SelectOptions selectOptions = SelectOptions.get();
          List<MstWaterSurveyType> listSurveyPoint = mstWaterSurveyTypeDao.getAll(selectOptions, facilityCd);
          Map<String, Object> survey = new HashMap<>();
          survey.put("data_list_detail_cd", 1361);
          if(!listSurveyPoint.isEmpty()) {
            survey.put("items", listSurveyPoint.stream().map(el -> Integer.valueOf(el.getSurveyTypeCd().toString())).toList());
          } else {
            survey.put("items", List.of(new int[]{0}));
          }
          listItemInfo.add(survey);
        }
        // add #11528 【たくしん会】データリスト並び順不正 房 end
        listItemInfo.stream().forEach(i -> {
          SysDataListDetailResponse rs = new SysDataListDetailResponse();
          List<Map<String, Object>> listItem = new ArrayList<>();

          SysDataListDetail detail = sysDataListDetailDao
              .selectByCd(Long.parseLong(String.valueOf(i.get("data_list_detail_cd"))));
          if (detail != null) {
            rs.setDataListDetailCd(detail.getDataListDetailCd());
            rs.setCategoryCd(detail.getCategoryCd());
            rs.setDispOrder(detail.getDispOrder());
            rs.setDisplayName(detail.getFunctionDisplayName());
            // mod #11528 【たくしん会】データリスト並び順不正 房 start
            List<Integer> itemCd = new ArrayList<>();
            List<Object> tempObjetList = (List<Object>) i.get("items");
            if(!tempObjetList.isEmpty()) {
              tempObjetList.forEach(el -> {
                if(el != null) {
                  String tempEl = String.valueOf(el);
                  tempEl = tempEl.replace("\"", "");
                  itemCd.add(Integer.parseInt(tempEl));
                }
              });
            }
            rs.setItemCds(itemCd);
            if (!itemCd.isEmpty()) {
              Map<String, Object> dataKey = new HashMap<>();
              dataKey.put("ids", i.get("items"));
              dataKey.put("facilityCd", facilityCd);
              if (detail.getFunctionDisplayType().equals("1")) {
                // 一覧表示SQLによりデータリストを取得
                listItem = getDataList(detail.getFunctionDisplaySql(), dataKey);
                rs.setItems(listItem);
              } else {
                rs.setDisplayName(null);
                Map<String, Object> it = new HashMap<>();
                it.put("id", 0);
                it.put("name", detail.getFunctionDisplayName());
                listItem.add(it);
                rs.setItems(listItem);
              }
            }
            // mod #11528 【たくしん会】データリスト並び順不正 房 end
            listItemData.add(rs);
          }
        });
      }
    }
    return listItemData;
  }

  /**
   * 各セルに表示するデータを取得
   * @param dataListDetailCd --データリスト詳細コード
   * @param dataKey データキー
   * @return
   */
  @Override
  public Object getCellData(Long dataListDetailCd, Map<String, Object> dataKey) throws Exception {
    ObjectMapper mapper = new ObjectMapper();
    SysDataListDetail detail = sysDataListDetailDao.selectByCd(dataListDetailCd);

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("データリスト詳細コードにデータリストカテゴリ詳細を取得");
    eventLogMessage.setSqlIdentification("(data_list_detail_cd = " + dataListDetailCd + ")");
    logService.log(LogLevel.INFO, eventLogMessage,FUNCTION_CODE.FUNC_MULTI_PAT_LIST ,SERVICE_NAME.FNSI, "SysDataListDetailDao/selectByCd");
    Map<String, Object> result = new HashMap<>();
    if (detail != null) {
      String cellData = detail.getCellDisplay();
      if (cellData != null) {
        if (detail.getDataSet() != null) {
          List<Map<String, Object>> dataSet = mapper.readValue(detail.getDataSet(),new TypeReference<List<Map<String, Object>>>() {});
          for(Map<String, Object> i: dataSet) {
            List<Map<String, Object>> resultQuery = sysDataSetService
                     .getDataList(Long.parseLong(String.valueOf(i.get("sql_cd"))), dataKey);
              String param = String.valueOf(i.get("param"));
              if (resultQuery.size() > 0 && param != null ) {
                result.put(param, resultQuery.get(0).get(param));
              }
          }
        }
      }
      result.put("cellDisplay", cellData);
      return result;
    }
    return null;
  }

  /* add by zhaohan 2022-11-16 [6543] 集計のテンプレートを表示すると、DBへの負荷がかかる。 --start */
  /**
   * 各行に表示するデータを取得
   * @param dataListDetailCd --データリスト詳細コード
   * @param dataKey データキー
   * @return
   */
  @Override
  public Object getRowData(Long dataListDetailCd, Map<String, Object> dataKey) throws Exception {
    ObjectMapper mapper = new ObjectMapper();
    SysDataListDetail detail = sysDataListDetailDao.selectByCd(dataListDetailCd);

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("データリスト詳細コードにデータリストカテゴリ詳細を取得");
    eventLogMessage.setSqlIdentification("(data_list_detail_cd = " + dataListDetailCd + ")");
    logService.log(LogLevel.INFO, eventLogMessage,FUNCTION_CODE.FUNC_MULTI_PAT_LIST ,SERVICE_NAME.FNSI, "SysDataListDetailDao/selectByCd");
    Map<String, Object> result = new HashMap<>();
    if (detail != null) {
      String rowData = detail.getCellDisplay();
      if (rowData != null) {
        if (detail.getDataSet() != null) {
          List<Map<String, Object>> dataSet = mapper.readValue(detail.getDataSet(),new TypeReference<List<Map<String, Object>>>() {});
          for(Map<String, Object> i: dataSet) {
            List<Map<String, Object>> resultQuery = sysDataSetService.getDataList(Long.parseLong(String.valueOf(i.get("sql_cd"))), dataKey);
            String param = String.valueOf(i.get("param"));
            if (resultQuery.size() > 0 && param != null ) {
              if ("count".equals(param)) {
                result.put(param, resultQuery);
              } else {
                result.put(param, resultQuery.get(0).get(param));
              }
            }
          }
        }
      }
      result.put("cellDisplay", rowData);
      return result;
    }
    return null;
  }
  /* add by zhaohan 2022-11-16 [6543] 集計のテンプレートを表示すると、DBへの負荷がかかる。 --end */

  /**
   * 引数のSQLでデータリストを取得
   * @param sql　Sql
   * @param dataKey　データキー
   * @return
   */
  private List<Map<String, Object>> getDataList(String sql, Map<String, Object> dataKey) {
    if (Strings.isNullOrEmpty(sql)) {
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("指定されたsqlCodeにSQLが登録されていません。sqlCd:" + sql);
      logService.log(LogLevel.INFO, eventLogMessage,FUNCTION_CODE.FUNC_MULTI_PAT_LIST ,SERVICE_NAME.FNSI, null);
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
      return new ArrayList<Map<String, Object>>();
    }
    List<Map<String, Object>> reportInfo;
    // SQL実行でエラーが発生しても、後続処理を継続する.
    try {

      Config config = defaultDbConfig;
      SelectBuilder selectBuilder = createSelectBuilder(config, sql, dataKey);
      reportInfo = sysDataListDetailDao.executeSql(selectBuilder);

      // 帳票出力情報を返却用に置き換える（フィールド名をデータ項目コードに置き換える）
      return reportInfo;
    } catch (Exception ex) {
      // 例外が発生した場合には、空のリストを返却する.
      return new ArrayList<Map<String, Object>>();
    }
  }

  /**
   * {@link SysDataSet}をもとに{@link SelectBuilder}を作成します.
   *
   * @param config  DB接続先情報
   * @param sql     SQL
   * @param dataKey データキー
   * @return {@link SelectBuilder}
   */
  private SelectBuilder createSelectBuilder(Config config, String sql, Map<String, Object> dataKey) {
    // 実行するSQLを生成する
    SelectBuilder selectBuilder = SelectBuilder.newInstance(config);

    // SQLのバインド変数にあわせて"@"を付与する
    if (dataKey != null) {
      Map<String, Object> sqlDataKey = dataKey.entrySet().stream()
          .collect(Collectors.toMap(d -> d.getKey().startsWith("@") ? d.getKey() : String.format("@%s", d.getKey()),
              d -> d.getValue() == null ? null : d.getValue()));

      // バインド変数毎にSQL内での出力件数からマップを作成.
      // key:バインド変数名(ex. @ordNos)
      // value:出力回数(ex. 2)
      Map<String, Integer> sqlDataKeyCount = new HashMap<>();
      sqlDataKey.forEach((key, value) -> {
        sqlDataKeyCount.put(key, StringUtils.countOccurrencesOf(sql, key));
      });

      // SQLでの出現位置順にデータキーの項目名を取得する
      Map<Integer, String> itemIndexMap = new HashMap<>();
      sqlDataKey.forEach((key, value) -> {
        if (sql.indexOf(key) >= 0) {
          itemIndexMap.put(sql.indexOf(key), key);
          // 同一パラメータ名（@XXX)が複数存在する場合
          // 次のパラメータの位置を取得する為、+1を行う
          int startIndex = sql.indexOf(key) + 1;
          if (sqlDataKeyCount.containsKey(key) && sqlDataKeyCount.get(key) > 1) {
            for (int index = 1; index <= sqlDataKeyCount.get(key); index++) {
              int matchIndex = sql.indexOf(key, startIndex);
              if (matchIndex < 0) {
                continue;
              }
              itemIndexMap.put(matchIndex, key);
              startIndex = matchIndex + 1;
            }
          }
        }
      });
      List<String> itemNames = itemIndexMap.entrySet().stream().sorted(comparingByKey()).map(e -> e.getValue())
          .collect(Collectors.toList());

      String tmpSql = sql;
      for (String itemName : itemNames) {
        // データキーの項目名でSQLを分割する
        String[] splitSqls = tmpSql.split(itemName);
        selectBuilder.sql(splitSqls[0]);

        // 項目名の箇所にパラメータを設定する
        Object itemValue = sqlDataKey.get(itemName);

        // itemValueがListではない場合
        List<Object> itemList = new ArrayList<Object>();
        if (itemValue instanceof List) {
          // リストの場合
          itemList.addAll((List<?>) itemValue);
        } else {
          // リスト以外
          itemList.add(itemValue);
        }

        // リストから展開
        String delimiter = "";
        for (Object obj : itemList) {
          if (!StringUtils.isEmpty(delimiter))
            selectBuilder.sql(delimiter);
          if (obj instanceof String) {
            selectBuilder.param(String.class, String.valueOf(obj));
          } else if (obj instanceof Long) {
            selectBuilder.param(Long.class, Long.valueOf(obj.toString()));
          } else if (obj instanceof Integer) {
            selectBuilder.param(Integer.class, Integer.valueOf(obj.toString()));
          } else {
            throw new NtssException("想定しないデータ型が指定されています。");
          }
          delimiter = ",";
        }
        // splitした結果を再結合する.
        StringJoiner sj = new StringJoiner(itemName);
        // 配列の1件目は既にselectBuilderに格納済みの為スキップする.
        Arrays.stream(splitSqls).skip(1).forEach(i -> sj.add(i));
        // split結果が1件以上の場合のみ再結合した文字列を設定する.
        tmpSql = splitSqls.length > 1 ? sj.toString() : "";
      }
      selectBuilder.sql(tmpSql);
    } else {
      selectBuilder.sql(sql);
    }
    return selectBuilder;
  }
// add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 dou start
  @Autowired
  MstMedicineDao mstMedicineDao;
  // add 9987 by kangjie 20231225 show 調製薬剤 start
  @Autowired
  MstMedicineMixDao mstMedicineMixDao;
  // add 9987 by kangjie 20231225 show 調製薬剤 end
  // add 9987 by kangjie 20240523 start 一般名処方マスタ
  @Autowired
  SysGenericMedicineDao sysGenericMedicineDao;
  // add 9987 by kangjie 20240523 end
  @Autowired
  private MstEquipmentDao mstEquipmentDao;
  @Autowired
  private MstDialyzerDao mstDialyzerDao;

  @Autowired
  @DefaultDb
  private Config defaultDbConfig;

  @Override
  public Map<String, Object> getTemplateValue(List<Long> patIdList, String facilityCd, String startDate, String endDate, Integer templateCd){
    Map<String, Object> map = new HashMap<String, Object>();
    List<PatNameId> patInfo = patPersonalMainDao.selectPatNameById(patIdList);
    map.put("patInfo", patInfo);
    switch (templateCd) {
      case 4:
        /*mod FNSI-改修内容5195 任 start*/
        /*List<PatMain> templatePatMains = patMainDao.selectByIdListFacilityCd(patIdList, facilityCd);*/
        List<PatMain> templatePatMains = patMainDao.selectByIdListFacilityCdMultiPatList(patIdList, facilityCd);
        /*mod FNSI-改修内容5195 任 end*/
        // add FNSI7519-profile連携（XML）で受信した詳細情報（患者フリーコメント） 周 start
        if(null != templatePatMains && !templatePatMains.isEmpty()) {
          List<PatMain> tempTemplatePatMains = new ArrayList<>();
          for(PatMain patMain : templatePatMains) {
            String patMemoInfo = patMain.getPat_memo_info();
            if(!StringUtils.isEmpty(patMemoInfo)
              && (patMemoInfo.contains("\"") || patMemoInfo.contains("\\") || patMemoInfo.contains("\\/"))) {
              String tempColVal = "";
              for(int idx = 0; idx < patMemoInfo.length(); idx++) {
                if(('\\' == patMemoInfo.charAt(idx) && '"' == patMemoInfo.charAt(idx+1))
                  || ('\\' == patMemoInfo.charAt(idx) && '\\' == patMemoInfo.charAt(idx+1))
                  || ('\\' == patMemoInfo.charAt(idx) && '/' == patMemoInfo.charAt(idx+1))) {
                  tempColVal = tempColVal + "\\\\" + patMemoInfo.charAt(idx);
                } else {
                  tempColVal = tempColVal + patMemoInfo.charAt(idx);
                }
              }
              patMemoInfo = tempColVal;
            }
            patMain.setPat_memo_info(patMemoInfo);
            tempTemplatePatMains.add(patMain);
          }
          templatePatMains = tempTemplatePatMains;
        }
        // add FNSI7519-profile連携（XML）で受信した詳細情報（患者フリーコメント） 周 end
        List<PatPersonalMain> patPersonalMains = patPersonalMainDao.selectByIdListFacilityCd(patIdList, facilityCd);
        List<PatInsurance> patInsurances = patInsuranceDao.selectByIdListFacilityCd(patIdList, facilityCd);
        //No.7167 upd Paging Optimization runtime by ztc start
//        List<MstInsurance> mstInsurances = mstInsuranceDao.selectAll();
        //No.7167 upd Paging Optimization runtime by ztc end
        List<MstPersonalUser> mstPersonalUsers = mstPersonalUserDao.selectAllUser(facilityCd, "0");
        List<PatUnique> patUniques = patUniqueDao.selectByIdListFacilityCd(patIdList, facilityCd);
        //No.7167 upd Paging Optimization runtime by ztc start
//        List<MstFacility> mstFacilities = mstFacilityDao.selectAll();
        // mod 9482 患者情報画面/新規患者登録の表示が遅い。 関  start
        // List<MstDisease> mstDiseases = mstDiseaseDao.getMstDiseaseInfoByFacilityCd(facilityCd);
        List<MstDisease> mstDiseases = new ArrayList<MstDisease>();
        if(patUniques != null && !patUniques.isEmpty()) {
          List<PatUnique> diagnosisFacilityCd = patUniques.stream().filter(item -> ! "[]".equals(item.getMedical_hst_info())).collect(Collectors.toList());
          List<Integer> diseasesCdList = new LinkedList<>();
          diagnosisFacilityCd.forEach(dia -> {
            JSONArray medicalhstinfoArr = new JSONArray(dia.getMedical_hst_info());
            medicalhstinfoArr.forEach(iarr ->{
              JSONObject medicalhstinfoObj = (JSONObject) iarr;
              if(medicalhstinfoObj.has("disease_cd") && !medicalhstinfoObj.isNull("disease_cd")){
                diseasesCdList.add(Integer.parseInt(medicalhstinfoObj.get("disease_cd").toString()));
              }
            });
          });
          if (diseasesCdList.size() > 0) {
            Integer[] diseasesCdArray = diseasesCdList.toArray(new Integer[diseasesCdList.size()]);
            mstDiseases = mstDiseaseDao.getMstDiseaseByCds(diseasesCdArray);
          }
        }
        // mod 9482 患者情報画面/新規患者登録の表示が遅い。 関  end
        List<MstCourse> mstCourses = mstCourseDao.getMstCourseInfoByFacilityCd(facilityCd);
        List<PatGroup> patGroups = patGroupDao.getPatGroupInfoByFacilityCd(facilityCd);
        List<MstImplant> mstImplants = mstImplantDao.getMstImplantInfoByFacilityCd(facilityCd);
        List<MstTabooAllergy> mstTabooAllergies = mstTabooAllergyDao.getMstTabooAllergyInfoByFacilityCd(facilityCd);
        List<MstInfection> mstInfections = mstInfectionDao.getMstInfectionInfoByFacilityCd(facilityCd);
        //No.7167 upd Paging Optimization runtime by ztc end
        List<MstAddition> mstAdditions = mstAdditionDao.selectByFacilityCd(facilityCd);
        //add 5222 施設、入外、コメントが表示されない 張 start
        //No.7167 upd Paging Optimization runtime by ztc start
        List<String> medicalInstitutionCds = new LinkedList<>();
        if(patUniques != null && !patUniques.isEmpty()){
          List<PatUnique> diagnosisFacilityCd = patUniques.stream().filter(item -> !"[]".equals(item.getMedical_hst_info())).collect(Collectors.toList());
          List<String> diaFacilityCds = new LinkedList<>();
          diagnosisFacilityCd.forEach(dia->{
            JSONArray medicalhstinfoArr =  new JSONArray(dia.getMedical_hst_info());
            medicalhstinfoArr.forEach(iarr ->{
              JSONObject medicalhstinfoObj = (JSONObject) iarr;
              if(medicalhstinfoObj.has("diagnosis_facility_cd") && !medicalhstinfoObj.isNull("diagnosis_facility_cd")){
                diaFacilityCds.add(medicalhstinfoObj.get("diagnosis_facility_cd").toString());
              }
            });
          });
          //add 9796データリスト画面で患者情報2のデータが表示されない。zhao start
          List<PatUnique> visFacilityCd = patUniques.stream().filter(item -> !"[]".equals(item.getIn_out_visit_history_info())).collect(Collectors.toList());
          List<String> visFacilityCds = new LinkedList<>();
          visFacilityCd.forEach(dia->{
            JSONArray medicalhstinfoArr =  new JSONArray(dia.getIn_out_visit_history_info());
            medicalhstinfoArr.forEach(iarr ->{
              JSONObject medicalhstinfoObj = (JSONObject) iarr;
              if(medicalhstinfoObj.has("from_medicalInstitutionCd") && !medicalhstinfoObj.isNull("from_medicalInstitutionCd")){
                visFacilityCds.add(medicalhstinfoObj.get("from_medicalInstitutionCd").toString());
              }
              if(medicalhstinfoObj.has("to_medicalInstitutionCd") && !medicalhstinfoObj.isNull("to_medicalInstitutionCd")){
                visFacilityCds.add(medicalhstinfoObj.get("to_medicalInstitutionCd").toString());
              }
            });
          });
          //add 9796データリスト画面で患者情報2のデータが表示されない。zhao end
          medicalInstitutionCds = diaFacilityCds.stream().distinct().collect(Collectors.toList());
          //add 9796データリスト画面で患者情報2のデータが表示されない。zhao start
          medicalInstitutionCds.addAll(visFacilityCds.stream().distinct().collect(Collectors.toList()));
          //add 9796データリスト画面で患者情報2のデータが表示されない。zhao end
        }
//        SelectOptions selectOptions = SelectOptions.get();
//        List<SysFacility> sysFacilitys = sysFacilityDao.selectAll(selectOptions);
        List<SysFacility> sysFacilitys = sysFacilityDao.getSysFacilityByMedicalInstitutionCd(medicalInstitutionCds);
        //No.7167 upd Paging Optimization runtime by ztc end
        map.put("sysFacilitys", sysFacilitys);
        // mod bug #5557 修正 chen start
        // String date = new SimpleDateFormat("yyyyMMdd").format(new Date());
        String date = null;
        // mod bug #5557 修正 chen end
        List<AdditionInfoOrdMain> additionList = new ArrayList<AdditionInfoOrdMain>();
        for (Long patId : patIdList) {
          List<AdditionInfoOrdMain> response = ordMainDao.selectCalculationDateList(null, facilityCd, patId, date);
          additionList.addAll(response);
        }
        //add 5222 施設、入外、コメントが表示されない 張 end

        MstMedicine paramMedicine = new MstMedicine();
        paramMedicine.setFacilityCd(facilityCd);
        List<MstMedicine> medicines = mstMedicineDao.selectAll(SelectOptions.get(), paramMedicine);
        List<MstMedicine> medicinesDel = mstMedicineDao.selectAllDel(SelectOptions.get(), paramMedicine);

        // add 9987 by kangjie 20231225 shwo 調製薬剤 start
        MstMedicineMix paramMedicineMix = new MstMedicineMix();
        paramMedicineMix.setFacilityCd(facilityCd);
        List<MstMedicineMix> mstMedicineMixes = mstMedicineMixDao.selectAll(SelectOptions.get(), paramMedicineMix);
        List<MstMedicineMix> mstMedicineMixesDel = mstMedicineMixDao.selectAllDel(SelectOptions.get(), paramMedicineMix);
        // add 9987 by kangjie 20231225 shwo 調製薬剤 end

        // add 9987 by kangjie 20240523 start
        List<SysGenericMedicine> sysGenericMedicines = sysGenericMedicineDao.selectAllIncludeDeleted(SelectOptions.get());
        // add 9987 by kangjie 20240523 end


        MstEquipment paramEquipment = new MstEquipment();
        paramEquipment.setFacilityCd(facilityCd);
        List<MstEquipment> mstEquipmentList = mstEquipmentDao.selectAll(SelectOptions.get(), paramEquipment);
        List<MstEquipment> mstEquipmentDelList = mstEquipmentDao.selectAllNoDel(SelectOptions.get(), paramEquipment);

        MstDialyzer paramDialyzer = new MstDialyzer();
        paramDialyzer.setFacilityCd(facilityCd);
        List<MstDialyzer> mstDialyzerList = mstDialyzerDao.selectAll(SelectOptions.get(), paramDialyzer);
        List<MstDialyzer> mstDialyzerDelList = mstDialyzerDao.selectAllNoDel(SelectOptions.get(), paramDialyzer);

        map.put("templatePatMains", templatePatMains);
        map.put("patPersonalMains", patPersonalMains);
        map.put("patInsurances", patInsurances);
        //No.7167 upd Paging Optimization runtime by ztc start
//        map.put("mstInsurances", mstInsurances);
        //No.7167 upd Paging Optimization runtime by ztc end
        map.put("mstPersonalUsers", mstPersonalUsers);
        map.put("patUniques", patUniques);
        //No.7167 upd Paging Optimization runtime by ztc start
//        map.put("mstFacilities", mstFacilities);
        //No.7167 upd Paging Optimization runtime by ztc end
        map.put("mstDiseases", mstDiseases);
        map.put("mstCourses", mstCourses);
        map.put("patGroups", patGroups);
        map.put("mstImplants", mstImplants);
        map.put("mstTabooAllergies", mstTabooAllergies);
        map.put("mstInfections", mstInfections);
        map.put("mstAdditions", mstAdditions);

        map.put("mstMedicine", medicines);
        map.put("mstMedicineDel", medicinesDel);
        // add 9987 by kangjie 20231225 shwo 調製薬剤 start
        map.put("mstMedicineMixes",mstMedicineMixes);
        map.put("mstMedicineMixesDel",mstMedicineMixesDel);
        // add 9987 by kangjie 20231225 shwo 調製薬剤 end

        // add 9987 by kangjie 20240523 start
        map.put("sysGenericMedicinesIncludeDel",sysGenericMedicines);
        // add 9987 by kangjie 20240523 end
        map.put("mstEquipment", mstEquipmentList);
        map.put("mstEquipmentDel", mstEquipmentDelList);
        map.put("mstDialyzer", mstDialyzerList);
        map.put("mstDialyzerDel", mstDialyzerDelList);
        map.put("additionList", additionList);
        break;
      case 5:
        List<OrdMain> ordMains = ordMainDao.selectByPatIdListFacilityCd(patIdList, facilityCd, startDate, endDate);
        List<PatMain> tpatMains = patMainDao.selectByIdListFacilityCdDate(patIdList, facilityCd, startDate, endDate);
        //mod #11034 データリストにてテンプレートに「治療予定・治療記録」をつかっているレイアウトでは最大50件までしか表示されない zrx start
//        List<MniMonitor> mniMonitors = mniMonitorDao.selectByIdListFacilityCd(patIdList, facilityCd, startDate, endDate);
        List<MniMonitor> mniMonitors = new ArrayList<>();
        if (patIdList != null && !patIdList.isEmpty()) {
          for(List<Long> subList : Lists.partition(patIdList, 100)) {
            List<MniMonitor> mniMonitorTemp = mniMonitorDao.selectByIdListFacilityCd(subList, facilityCd, startDate, endDate);
            if (mniMonitorTemp != null && !mniMonitorTemp.isEmpty()) {
              mniMonitors.addAll(mniMonitorTemp);
            }
          }
        }
        //mod #11034 データリストにてテンプレートに「治療予定・治療記録」をつかっているレイアウトでは最大50件までしか表示されない zrx end

        List<TemplateHospitalCd> templateHospitalCd = ordMainDao.selectCdByPatIdListFacilityCd(patIdList, facilityCd, startDate, endDate);
        /*add FNSI-改修内容5204 任 start*/
        List<PatUnique> patUniquesTem = patUniqueDao.selectByIdListFacilityCd(patIdList, facilityCd);
        /*add FNSI-改修内容5204 任 end*/
        // add bug 5358 修正 chen start
        //No.7167 upd Paging Optimization runtime by ztc start
        Map<Long, Timestamp> patStartDate = new LinkedHashMap<>();
        List<OrdMain> ordMainMin = new LinkedList<>();
        //No.7167 upd Paging Optimization runtime by ztc end
        for (OrdMain ordMain : ordMains) {
          // mod FNSI-7674【デグレ】データリストで処理中のままになる 劉全航 start
//          if (ordMain.getRstWeightInfo() != null) {
          if (!ordMain.getRstDialysisState().equals("0") && ordMain.getRstWeightInfo() != null) {
            // mod FNSI-7674【デグレ】データリストで処理中のままになる 劉全航 end
            ordMainMin.add(ordMain);
            if (patStartDate.containsKey(ordMain.getPatId())) {
              //mod #11034 データリストにてテンプレートに「治療予定・治療記録」をつかっているレイアウトでは最大50件までしか表示されない zrx start
//              if (ordMain.getRstStartDate().compareTo(patStartDate.get(ordMain.getPatId())) < 0) {
              if (patStartDate.get(ordMain.getPatId()) == null || ordMain.getRstStartDate().compareTo(patStartDate.get(ordMain.getPatId())) < 0) {
              //mod #11034 データリストにてテンプレートに「治療予定・治療記録」をつかっているレイアウトでは最大50件までしか表示されない zrx end
                patStartDate.put(ordMain.getPatId(), ordMain.getRstStartDate());
              }
            } else {
              patStartDate.put(ordMain.getPatId(), ordMain.getRstStartDate());
            }
          }
        }
        for(Long patId : patStartDate.keySet()) {
          List<OrdMain> ordMainTmp = ordMainDao.selectByPatIdFacilityCd(patId, facilityCd, patStartDate.get(patId));
          if (ordMainTmp.size() > 0) {
            ordMainMin.add(ordMainTmp.get(0));
          }
        }
        // mod #11895 データリスト「治療予定・実績」テンプレート恒久対応 fang start
        appendPriorRstWeightOrdMains(patStartDate, facilityCd, ordMainMin);
        // mod #11895 データリスト「治療予定・実績」テンプレート恒久対応 fang end
        map.put("ordMainMin", ordMainMin);
        // add bug 5358 修正 chen end
        map.put("ordMains", ordMains);
        map.put("tpatMains", tpatMains);
        map.put("mniMonitors", mniMonitors);
        map.put("templateHospitalCd", templateHospitalCd);
        /*add FNSI-改修内容5204 任 start*/
        map.put("patUniques", patUniquesTem);
        /*add FNSI-改修内容5204 任 end*/
        //No.7167 upd Paging Optimization runtime by ztc start
        break;
      case 6:
        List<TemplateOrdMain> templateOrdMains = ordMainDao.selectTemplateOrdMain(patIdList, facilityCd, startDate, endDate);
        List<TemplateMonitor> templateMonitors = ordMainDao.selectTemplateMonitor(patIdList, facilityCd, startDate, endDate);
        List<Long> patIdListFilter = templateMonitors.stream().map(TemplateMonitor::getPat_id).distinct().collect(Collectors.toList());
        List<TemplateMachine> templateMachines = ordMainDao.selectTemplateMachine(patIdListFilter, facilityCd, startDate, endDate);
        List<TemplateMedicine> templateMedicines = ordMainDao.selectTemplateMedicine(facilityCd);
        List<TemplateMedicine> templateMedicineMixs = ordMainDao.selectTemplateMedicineMix(facilityCd);
        map.put("templateOrdMains", templateOrdMains);
        map.put("templateMonitors", templateMonitors);
        map.put("templateMachines", templateMachines);
        map.put("templateMedicines", templateMedicines);
        map.put("templateMedicineMixs", templateMedicineMixs);
        break;
      case 7:
        // mod FNSI-7676 【デグレ】抽出期間の不正 劉全航 start
        //List<TemplatePatExamMain> templatePatExamMains = patExamMainDao.selectDatalistByPatIdListFacilityCd(patIdList, facilityCd, startDate, endDate);
        List<TemplatePatExamMain> templatePatExamMains = patExamMainDao.selectDatalistByPatIdListFacilityCd(patIdList, facilityCd, startDate, endDate + " 23:59:59");
        // mod FNSI-7676 【デグレ】抽出期間の不正 劉全航 end
        // add FNSI6516-テンプレート：検査結果の表示順不正 周 start
        List<TemplateOrdMain> tempOrdMains = ordMainDao.selectTemplateOrdMain(patIdList, facilityCd, startDate, endDate);
        MstSelector mstSelector = mstSelectorDao.selectByName(facilityCd, "mst_exam_item");
        List<Long> sortedCodes = new ArrayList<>();
        if (mstSelector != null) {
          // ソート用配列作成
          sortedCodes = mstSelector.getOrderSettings().getItems()
            .stream().map(e -> e.getCode()).collect(Collectors.toList());
        }
        List<Long> finalSortedCodes = sortedCodes;
        List<TemplatePatExamMain> templatePatExamMainsNew = new ArrayList();
        templatePatExamMains.forEach(elem1 -> {
          TemplatePatExamMain newElem = new TemplatePatExamMain();
          BeanUtils.copyProperties(elem1, newElem);
          if(null != elem1.getExam_result_info()) {
            JSONArray newJsonArr = new JSONArray();
            JSONArray ERIJArray = new JSONArray(elem1.getExam_result_info());
            ERIJArray.forEach(elem2 -> {
              for(int idx = 0; idx < finalSortedCodes.size(); idx++) {
                if(0 == finalSortedCodes.get(idx).toString().compareTo(((JSONObject)elem2).get("item_cd").toString())) {
                  ((JSONObject)elem2).remove("disp_order");
                  ((JSONObject)elem2).put("disp_order", idx);
                  newJsonArr.put(elem2);
                  break;
                }
              }
            });
            newElem.setExam_result_info(newJsonArr.toString());
          }
          templatePatExamMainsNew.add(newElem);
        });
        // add FNSI6516-テンプレート：検査結果の表示順不正 周 end
        //map.put("templatePatExamMains", templatePatExamMains);
        map.put("templatePatExamMains", templatePatExamMainsNew);
        map.put("templateOrdMains", tempOrdMains);
        break;
      case 8:
        List<PatMain> patMains = patMainDao.selectByIdListFacilityCd(patIdList, facilityCd);
        // add FNSI6062-装置情報で項目の不足 周 start
        String hostNotificationInfo = mstDeviceSetInfoDefaultDao.selectHostNotificationInfo(facilityCd);
        patMains.forEach(elem -> {
          if(null == elem.getHost_notification_info() || elem.getHost_notification_info().isEmpty()) {
            elem.setHost_notification_info(hostNotificationInfo);
          }
        });
        // add FNSI6062-装置情報で項目の不足 周 end
        map.put("patMains", patMains);
        break;
      default:
        break;
    }
    return map;
  }

  //No.7167 upd Paging Optimization runtime by ztc start
  @Override
  public Map<String, Object> getTemplateValue(List<Long> patIdList, String facilityCd, String startDate, String endDate,
                                              Integer templateCd, Integer offset, Boolean isOnlyRst){

    //del #11034 データリストにてテンプレートに「治療予定・治療記録」をつかっているレイアウトでは最大50件までしか表示されない start zrx
    //    Integer limit = 50;
    //del #11034 データリストにてテンプレートに「治療予定・治療記録」をつかっているレイアウトでは最大50件までしか表示されない start end
    Map<String, Object> map = new HashMap<String, Object>();
    List<PatNameId> patInfo = patPersonalMainDao.selectPatNameById(patIdList);
    map.put("patInfo", patInfo);
    switch (templateCd) {
      case 4:
        /*mod FNSI-改修内容5195 任 start*/
        /*List<PatMain> templatePatMains = patMainDao.selectByIdListFacilityCd(patIdList, facilityCd);*/
        List<PatMain> templatePatMains = patMainDao.selectByIdListFacilityCdMultiPatList(patIdList, facilityCd);
        /*mod FNSI-改修内容5195 任 end*/
        // add FNSI7519-profile連携（XML）で受信した詳細情報（患者フリーコメント） 周 start
        if(null != templatePatMains && !templatePatMains.isEmpty()) {
          List<PatMain> tempTemplatePatMains = new ArrayList<>();
          for(PatMain patMain : templatePatMains) {
            String patMemoInfo = patMain.getPat_memo_info();
            if(!StringUtils.isEmpty(patMemoInfo)
              && (patMemoInfo.contains("\"") || patMemoInfo.contains("\\") || patMemoInfo.contains("\\/"))) {
              String tempColVal = "";
              for(int idx = 0; idx < patMemoInfo.length(); idx++) {
                if(('\\' == patMemoInfo.charAt(idx) && '"' == patMemoInfo.charAt(idx+1))
                  || ('\\' == patMemoInfo.charAt(idx) && '\\' == patMemoInfo.charAt(idx+1))
                  || ('\\' == patMemoInfo.charAt(idx) && '/' == patMemoInfo.charAt(idx+1))) {
                  tempColVal = tempColVal + "\\\\" + patMemoInfo.charAt(idx);
                } else {
                  tempColVal = tempColVal + patMemoInfo.charAt(idx);
                }
              }
              patMemoInfo = tempColVal;
            }
            patMain.setPat_memo_info(patMemoInfo);
            tempTemplatePatMains.add(patMain);
          }
          templatePatMains = tempTemplatePatMains;
        }
        // add FNSI7519-profile連携（XML）で受信した詳細情報（患者フリーコメント） 周 end
        List<PatPersonalMain> patPersonalMains = patPersonalMainDao.selectByIdListFacilityCd(patIdList, facilityCd);
        List<PatInsurance> patInsurances = patInsuranceDao.selectByIdListFacilityCd(patIdList, facilityCd);
//        List<MstInsurance> mstInsurances = mstInsuranceDao.selectAll();
        List<MstPersonalUser> mstPersonalUsers = mstPersonalUserDao.selectAllUser(facilityCd, "0");
        List<PatUnique> patUniques = patUniqueDao.selectByIdListFacilityCd(patIdList, facilityCd);
//        List<MstFacility> mstFacilities = mstFacilityDao.selectAll();
        // mod 9482 患者情報画面/新規患者登録の表示が遅い。 関  start
        // List<MstDisease> mstDiseases = mstDiseaseDao.getMstDiseaseInfoByFacilityCd(facilityCd);
        List<MstDisease> mstDiseases = new ArrayList<MstDisease>();
        if(patUniques != null && !patUniques.isEmpty()) {
          List<PatUnique> diagnosisFacilityCd = patUniques.stream().filter(item -> ! "[]".equals(item.getMedical_hst_info())).collect(Collectors.toList());
          List<Integer> diseasesCdList = new LinkedList<>();
          diagnosisFacilityCd.forEach(dia -> {
            JSONArray medicalhstinfoArr = new JSONArray(dia.getMedical_hst_info());
            medicalhstinfoArr.forEach(iarr ->{
              JSONObject medicalhstinfoObj = (JSONObject) iarr;
              if(medicalhstinfoObj.has("disease_cd") && !medicalhstinfoObj.isNull("disease_cd")){
                diseasesCdList.add(Integer.parseInt(medicalhstinfoObj.get("disease_cd").toString()));
              }
            });
          });
          if (diseasesCdList.size() > 0) {
            Integer[] diseasesCdArray = diseasesCdList.toArray(new Integer[diseasesCdList.size()]);
            mstDiseases = mstDiseaseDao.getMstDiseaseByCds(diseasesCdArray);
          }
        }
        // mod 9482 患者情報画面/新規患者登録の表示が遅い。 関  end
        List<MstCourse> mstCourses = mstCourseDao.getMstCourseInfoByFacilityCd(facilityCd);
        List<PatGroup> patGroups = patGroupDao.getPatGroupInfoByFacilityCd(facilityCd);
        List<MstImplant> mstImplants = mstImplantDao.getMstImplantInfoByFacilityCd(facilityCd);
        List<MstTabooAllergy> mstTabooAllergies = mstTabooAllergyDao.getMstTabooAllergyInfoByFacilityCd(facilityCd);
        List<MstInfection> mstInfections = mstInfectionDao.getMstInfectionInfoByFacilityCd(facilityCd);
        List<MstAddition> mstAdditions = mstAdditionDao.selectByFacilityCd(facilityCd);
        //add 5222 施設、入外、コメントが表示されない 張 start
        List<String> medicalInstitutionCds = new LinkedList<>();
        if(patUniques != null && !patUniques.isEmpty()){
          List<PatUnique> diagnosisFacilityCd = patUniques.stream().filter(item -> !"[]".equals(item.getMedical_hst_info())).collect(Collectors.toList());
          List<String> diaFacilityCds = new LinkedList<>();
          diagnosisFacilityCd.forEach(dia->{
            JSONArray medicalhstinfoArr =  new JSONArray(dia.getMedical_hst_info());
            medicalhstinfoArr.forEach(iarr ->{
              JSONObject medicalhstinfoObj = (JSONObject) iarr;
              if(medicalhstinfoObj.has("diagnosis_facility_cd") && !medicalhstinfoObj.isNull("diagnosis_facility_cd")){
                diaFacilityCds.add(medicalhstinfoObj.get("diagnosis_facility_cd").toString());
              }
            });
          });
          medicalInstitutionCds = diaFacilityCds.stream().distinct().collect(Collectors.toList());
        }
//        SelectOptions selectOptions = SelectOptions.get();
//        List<SysFacility> sysFacilitys = sysFacilityDao.selectAll(selectOptions);
        List<SysFacility> sysFacilitys = sysFacilityDao.getSysFacilityByMedicalInstitutionCd(medicalInstitutionCds);
        map.put("sysFacilitys", sysFacilitys);
        // mod bug #5557 修正 chen start
        // String date = new SimpleDateFormat("yyyyMMdd").format(new Date());
        String date = null;
        // mod bug #5557 修正 chen end
        List<AdditionInfoOrdMain> additionList = new ArrayList<AdditionInfoOrdMain>();
        for (Long patId : patIdList) {
          List<AdditionInfoOrdMain> response = ordMainDao.selectCalculationDateList(null, facilityCd, patId, date);
          additionList.addAll(response);
        }
        //add 5222 施設、入外、コメントが表示されない 張 end

        MstMedicine paramMedicine = new MstMedicine();
        paramMedicine.setFacilityCd(facilityCd);
        List<MstMedicine> medicines = mstMedicineDao.selectAll(SelectOptions.get(), paramMedicine);
        List<MstMedicine> medicinesDel = mstMedicineDao.selectAllDel(SelectOptions.get(), paramMedicine);

        MstEquipment paramEquipment = new MstEquipment();
        paramEquipment.setFacilityCd(facilityCd);
        List<MstEquipment> mstEquipmentList = mstEquipmentDao.selectAll(SelectOptions.get(), paramEquipment);
        List<MstEquipment> mstEquipmentDelList = mstEquipmentDao.selectAllNoDel(SelectOptions.get(), paramEquipment);

        MstDialyzer paramDialyzer = new MstDialyzer();
        paramDialyzer.setFacilityCd(facilityCd);
        List<MstDialyzer> mstDialyzerList = mstDialyzerDao.selectAll(SelectOptions.get(), paramDialyzer);
        List<MstDialyzer> mstDialyzerDelList = mstDialyzerDao.selectAllNoDel(SelectOptions.get(), paramDialyzer);

        map.put("templatePatMains", templatePatMains);
        map.put("patPersonalMains", patPersonalMains);
        map.put("patInsurances", patInsurances);
//        map.put("mstInsurances", mstInsurances);
        map.put("mstPersonalUsers", mstPersonalUsers);
        map.put("patUniques", patUniques);
//        map.put("mstFacilities", mstFacilities);
        map.put("mstDiseases", mstDiseases);
        map.put("mstCourses", mstCourses);
        map.put("patGroups", patGroups);
        map.put("mstImplants", mstImplants);
        map.put("mstTabooAllergies", mstTabooAllergies);
        map.put("mstInfections", mstInfections);
        map.put("mstAdditions", mstAdditions);

        map.put("mstMedicine", medicines);
        map.put("mstMedicineDel", medicinesDel);
        map.put("mstEquipment", mstEquipmentList);
        map.put("mstEquipmentDel", mstEquipmentDelList);
        map.put("mstDialyzer", mstDialyzerList);
        map.put("mstDialyzerDel", mstDialyzerDelList);
        map.put("additionList", additionList);
        break;
      case 5:
        //mod #11034 データリストにてテンプレートに「治療予定・治療記録」をつかっているレイアウトでは最大50件までしか表示されない zrx start
//        List<OrdMain> ordMains = ordMainDao.selectByPatIdListFacilityCdByLimitAndOffset(patIdList, facilityCd, startDate, endDate, limit, offset, isOnlyRst);
//        List<OrdMain> ordMains = ordMainDao.selectByPatIdListFacilityCd(patIdList, facilityCd, startDate, endDate);
//        List<PatMain> tpatMains = patMainDao.selectByIdListFacilityCdDate(patIdList, facilityCd, startDate, endDate);
//        List<PatMain> tpatMains = patMainDao.selectByIdListFacilityCdDateByLimitAndOffset(patIdList, facilityCd, startDate, endDate, limit, offset, isOnlyRst);
//        List<MniMonitor> mniMonitors = mniMonitorDao.selectByIdListFacilityCd(patIdList, facilityCd, startDate, endDate);
        List<OrdMain> ordMains = ordMainDao.selectByPatIdListFacilityCdByLimitAndOffset(patIdList, facilityCd, startDate, endDate, isOnlyRst);
        List<PatMain> tpatMains = patMainDao.selectByIdListFacilityCdDateByLimitAndOffset(patIdList, facilityCd, startDate, endDate, isOnlyRst);
        List<MniMonitor> mniMonitors = new ArrayList<>();
        if (patIdList != null && !patIdList.isEmpty()) {
          for(List<Long> subList : Lists.partition(patIdList, 100)) {
            List<MniMonitor> mniMonitorTemp = mniMonitorDao.selectByIdListFacilityCd(subList, facilityCd, startDate, endDate);
            if (mniMonitorTemp != null && !mniMonitorTemp.isEmpty()) {
              mniMonitors.addAll(mniMonitorTemp);
            }
          }
        }
        //mod #11034 データリストにてテンプレートに「治療予定・治療記録」をつかっているレイアウトでは最大50件までしか表示されない zrx end
        List<Long> patIdListFilter = ordMains.stream().map(OrdMain::getPatId).distinct().collect(Collectors.toList());
        List<TemplateHospitalCd> templateHospitalCd = ordMainDao.selectCdByPatIdListFacilityCdByIsOnlyRst(patIdListFilter, facilityCd, startDate, endDate, isOnlyRst);
        /*add FNSI-改修内容5204 任 start*/
        List<PatUnique> patUniquesTem = patUniqueDao.selectByIdListFacilityCd(patIdList, facilityCd);
        /*add FNSI-改修内容5204 任 end*/
        // add bug 5358 修正 chen start
        Map<Long, Timestamp> patStartDate = new LinkedHashMap<>();
        List<OrdMain> ordMainMin = new LinkedList<>();
        List<OrdMain> ordMainFilters = ordMains.stream().filter(oItem->!("0").equals(oItem.getRstDialysisState())).collect(Collectors.toList());
        for (OrdMain ordMain : ordMainFilters) {
          // mod FNSI-7674【デグレ】データリストで処理中のままになる 劉全航 start
//          if (ordMain.getRstWeightInfo() != null) {
          if (ordMain.getRstWeightInfo() != null) {
            // mod FNSI-7674【デグレ】データリストで処理中のままになる 劉全航 end
            ordMainMin.add(ordMain);
            //mod #11034 データリストにてテンプレートに「治療予定・治療記録」をつかっているレイアウトでは最大50件までしか表示されない zrx start
            Timestamp rstStart = ordMain.getRstStartDate();
            Long patId = ordMain.getPatId();
            if (patStartDate.containsKey(ordMain.getPatId())) {
              Timestamp oldStart = patStartDate.get(patId);
//              if (!StringUtils.isEmpty(ordMain.getRstStartDate()) && ordMain.getRstStartDate().compareTo(patStartDate.get(ordMain.getPatId())) < 0) {
              if (!StringUtils.isEmpty(rstStart) && (oldStart == null || rstStart.compareTo(oldStart) < 0)) {
//                patStartDate.put(ordMain.getPatId(), ordMain.getRstStartDate());
                patStartDate.put(patId, rstStart);
                //mod #11034 データリストにてテンプレートに「治療予定・治療記録」をつかっているレイアウトでは最大50件までしか表示されない zrx end
              }
            } else {
              patStartDate.put(ordMain.getPatId(), ordMain.getRstStartDate());
            }
          }
        }
        for(Long patId : patStartDate.keySet()) {
          List<OrdMain> ordMainTmp = ordMainDao.selectByPatIdFacilityCd(patId, facilityCd, patStartDate.get(patId));
          if (ordMainTmp.size() > 0) {
            ordMainMin.add(ordMainTmp.get(0));
          }
        }
        // mod #11895 データリスト「治療予定・実績」テンプレート恒久対応 fang start
        appendPriorRstWeightOrdMains(patStartDate, facilityCd, ordMainMin);
        // mod #11895 データリスト「治療予定・実績」テンプレート恒久対応 fang end
        map.put("ordMainMin", ordMainMin);
        // add bug 5358 修正 chen end
        map.put("ordMains", ordMains);
        map.put("tpatMains", tpatMains);
        map.put("mniMonitors", mniMonitors);
        map.put("templateHospitalCd", templateHospitalCd);
        /*add FNSI-改修内容5204 任 start*/
        map.put("patUniques", patUniquesTem);
        /*add FNSI-改修内容5204 任 end*/
        break;
      case 6:
        List<TemplateOrdMain> templateOrdMains = ordMainDao.selectTemplateOrdMain(patIdList, facilityCd, startDate, endDate);
        List<TemplateMonitor> templateMonitors = ordMainDao.selectTemplateMonitor(patIdList, facilityCd, startDate, endDate);
        List<TemplateMachine> templateMachines = ordMainDao.selectTemplateMachine(patIdList, facilityCd, startDate, endDate);
        List<TemplateMedicine> templateMedicines = ordMainDao.selectTemplateMedicine(facilityCd);
        List<TemplateMedicine> templateMedicineMixs = ordMainDao.selectTemplateMedicineMix(facilityCd);
        map.put("templateOrdMains", templateOrdMains);
        map.put("templateMonitors", templateMonitors);
        map.put("templateMachines", templateMachines);
        map.put("templateMedicines", templateMedicines);
        map.put("templateMedicineMixs", templateMedicineMixs);
        break;
      case 7:
        // mod FNSI-7676 【デグレ】抽出期間の不正 劉全航 start
        //List<TemplatePatExamMain> templatePatExamMains = patExamMainDao.selectDatalistByPatIdListFacilityCd(patIdList, facilityCd, startDate, endDate);
        List<TemplatePatExamMain> templatePatExamMains = patExamMainDao.selectDatalistByPatIdListFacilityCd(patIdList, facilityCd, startDate, endDate + " 23:59:59");
        // mod FNSI-7676 【デグレ】抽出期間の不正 劉全航 end
        // add FNSI6516-テンプレート：検査結果の表示順不正 周 start
        MstSelector mstSelector = mstSelectorDao.selectByName(facilityCd, "mst_exam_item");
        List<Long> sortedCodes = new ArrayList<>();
        if (mstSelector != null) {
          // ソート後データ
          List<MstObsKind> sortedData = new ArrayList<>();
          // ソート用配列作成
          sortedCodes = mstSelector.getOrderSettings().getItems()
            .stream().map(e -> e.getCode()).collect(Collectors.toList());
        }
        List<Long> finalSortedCodes = sortedCodes;
        List<TemplatePatExamMain> templatePatExamMainsNew = new ArrayList();
        templatePatExamMains.forEach(elem1 -> {
          TemplatePatExamMain newElem = new TemplatePatExamMain();
          BeanUtils.copyProperties(elem1, newElem);
          if(null != elem1.getExam_result_info()) {
            JSONArray newJsonArr = new JSONArray();
            JSONArray ERIJArray = new JSONArray(elem1.getExam_result_info());
            ERIJArray.forEach(elem2 -> {
              for(int idx = 0; idx < finalSortedCodes.size(); idx++) {
                if(0 == finalSortedCodes.get(idx).toString().compareTo(((JSONObject)elem2).get("item_cd").toString())) {
                  ((JSONObject)elem2).remove("disp_order");
                  ((JSONObject)elem2).put("disp_order", idx);
                  newJsonArr.put(elem2);
                  break;
                }
              }
            });
            newElem.setExam_result_info(newJsonArr.toString());
          }
          templatePatExamMainsNew.add(newElem);
        });
        // add FNSI6516-テンプレート：検査結果の表示順不正 周 end
        //map.put("templatePatExamMains", templatePatExamMains);
        map.put("templatePatExamMains", templatePatExamMainsNew);
        break;
      case 8:
        List<PatMain> patMains = patMainDao.selectByIdListFacilityCd(patIdList, facilityCd);
        // add FNSI6062-装置情報で項目の不足 周 start
        String hostNotificationInfo = mstDeviceSetInfoDefaultDao.selectHostNotificationInfo(facilityCd);
        patMains.forEach(elem -> {
          if(null == elem.getHost_notification_info() || elem.getHost_notification_info().isEmpty()) {
            elem.setHost_notification_info(hostNotificationInfo);
          }
        });
        // add FNSI6062-装置情報で項目の不足 周 end
        map.put("patMains", patMains);
        break;
      default:
        break;
    }
    return map;
  }
  //No.7167 upd Paging Optimization runtime by ztc end

  @Override
  public List<SysDataListCategory> getTitleName(Integer templateCd){
    return sysDataListCategoryDao.selectByTemplateCd(templateCd);
  }

  @Override
  public Map<String, Object> getInitData(Integer templateCd, String facilityCd){
    Map<String, Object> map = new HashMap<String, Object>();
    switch (templateCd) {
      case 10:
        List<MstMachineDatalistInit> mstMachineDatalistInitsPoint = mstMachineDao.selectDatalistInit(facilityCd);
        map.put("mstMachineDatalistInits", mstMachineDatalistInitsPoint);
        break;
      case 11:
        List<MstMachineDatalistInit> mstMachineDatalistInits = mstMachineDao.selectDatalistInitSelf(facilityCd);
        // add #11528 【たくしん会】データリスト並び順不正 房 start
        MstSelector machineSelector = mstSelectorDao.selectByName(facilityCd, "mst_machine");
        if(machineSelector != null) {
          // ソート用配列作成
          List<Long> sortedCodes = machineSelector.getOrderSettings().getItems()
            .stream().map(MstSelector.Item::getCode).toList();
          if(!sortedCodes.isEmpty()) {
            mstMachineDatalistInits = mstMachineDatalistInits.stream().sorted((a, b) -> {
              int aIndex = sortedCodes.indexOf(a.getMachine_no());
              int bIndex = sortedCodes.indexOf(b.getMachine_no());
              return aIndex - bIndex;
            }).toList();
          }
        }
        // add #11528 【たくしん会】データリスト並び順不正 房 end
        map.put("mstMachineDatalistInits", mstMachineDatalistInits);
        break;
      default:
        break;
    }
    return map;
  }

  @Override
  public Map<String, Object> getListData(Integer templateCd, String facilityCd, String startDate, String endDate) throws Exception {
    Map<String, Object> map = new HashMap<String, Object>();
    switch (templateCd) {
      case 9:
        dateFormatCheck(startDate,endDate,"yyyyMMdd");
        List<DevMenteMain> devMenteMainDatalist = devMenteMainDao.selectDevMenteMainDatalist(facilityCd, startDate, endDate);
        List<DevMenteMain> devMenteMainlayoutans1List = devMenteMainDao.selectDevMenteMainlayoutans1list(facilityCd, startDate, endDate);
        List<DevMenteMain> devMenteMainlayoutans2List = devMenteMainDao.selectDevMenteMainlayoutans2list(facilityCd, startDate, endDate);
        List<DevMenteMain> devMenteMaingroupans1List = devMenteMainDao.selectDevMenteMaingroupans1list(facilityCd, startDate, endDate);
        List<DevMenteMain> devMenteMaingroupans2List = devMenteMainDao.selectDevMenteMaingroupans2list(facilityCd, startDate, endDate);
        // add bug 5866 修正 chen start
        List<DevMenteMain> devMenteMainDatalistByComType = devMenteMainDao.selectDevMenteMainDatalistByComType(facilityCd);
        // add bug 5866 修正 chen end
        map.put("devMenteMainDatalist", devMenteMainDatalist);
        map.put("devMenteMainlayoutans1List", devMenteMainlayoutans1List);
        map.put("devMenteMainlayoutans2List", devMenteMainlayoutans2List);
        map.put("devMenteMaingroupans1List", devMenteMaingroupans1List);
        map.put("devMenteMaingroupans2List", devMenteMaingroupans2List);
        // add bug 5866 修正 chen start
        map.put("devMenteMainDatalistByComType", devMenteMainDatalistByComType);
        // add bug 5866 修正 chen end
        break;
      case 10:
        dateFormatCheck(startDate,endDate,"yyyy-MM-dd");
        List<MstMachineDatalist> mstMachineDatalists = mstMachineDao.selectDatalist(startDate, endDate, facilityCd);
        map.put("mstMachineDatalists", mstMachineDatalists);
        List<MstPersonalUser> mstPersonalUsers = mstPersonalUserDao.selectAllUser(facilityCd, "0");
        map.put("mstPersonalUsers", mstPersonalUsers);
        break;
      case 11:
        dateFormatCheck(startDate,endDate,"yyyyMMdd");
        List<MntMotionRecord> mntMotionRecordList = mntMotionRecordDao.selectMotionRecordDatalist(facilityCd, startDate, endDate);
        map.put("mntMotionRecordList", mntMotionRecordList);
        break;
      case 12:
        dateFormatCheck(startDate,endDate,"yyyy-MM-dd");
        List<MstMachineDatalistMainte> mstMachineDatalistMainteInit = mstMachineDao.selectDatalistMainteInit(startDate, endDate, facilityCd);
        // add #11528 【たくしん会】データリスト並び順不正 房 start
        MstSelector mstSelector = mstSelectorDao.selectByName(facilityCd, "mst_machine");
        if(mstSelector != null) {
          // ソート用配列作成
          List<Long> sortedCodes = mstSelector.getOrderSettings().getItems()
            .stream().map(MstSelector.Item::getCode).toList();
          if(!sortedCodes.isEmpty()) {
            mstMachineDatalistMainteInit = mstMachineDatalistMainteInit.stream().sorted((a, b) -> {
              int aIndex = sortedCodes.indexOf(a.getMachine_no());
              int bIndex = sortedCodes.indexOf(b.getMachine_no());
              return aIndex - bIndex;
            }).toList();
          }
        }
        // add #11528 【たくしん会】データリスト並び順不正 房 end
        map.put("mstMachineDatalistMainteInit", mstMachineDatalistMainteInit);
        // mod #11718 【#11600持ち越し】データリスト画面不正② fang start
//        List<MstMachineDatalistMainte> mstMachineDatalistMainte = mstMachineDao.selectDatalistMainte(startDate, endDate, facilityCd);
        List<MstMachineDatalistMainte> mstMachineDatalistMainte = new ArrayList<>();
        List<MstMachineDatalistMainte> mstMachineDatalistMaintePart1 = mstMachineDao.selectDatalistMaintePart1(startDate, endDate, facilityCd);
        List<MstMachineDatalistMainte> mstMachineDatalistMaintePart2 = mstMachineDao.selectDatalistMaintePart2(startDate, endDate, facilityCd);
        List<MstMachineDatalistMainte> mstMachineDatalistMaintePart3 = mstMachineDao.selectDatalistMaintePart3(startDate, endDate, facilityCd);
        mstMachineDatalistMainte.addAll(mstMachineDatalistMaintePart1);
        mstMachineDatalistMainte.addAll(mstMachineDatalistMaintePart2);
        mstMachineDatalistMainte.addAll(mstMachineDatalistMaintePart3);
        // mod #11718 【#11600持ち越し】データリスト画面不正② fang end
        map.put("mstMachineDatalistMainte", mstMachineDatalistMainte);
        List<MstPersonalUser> personalUsers = mstPersonalUserDao.selectAllUser(facilityCd, "0");
        map.put("mstPersonalUsers", personalUsers);
        break;
      default:
        break;
    }
    return map;
  }

  /**
   * 期間指定開始、期間指定終了の日付フォーマットチェック
   *
   * @param startDate  期間指定開始
   * @param endDate    期間指定終了
   * @param dateFormat 日付フォーマット
   */
  private void dateFormatCheck(String startDate, String endDate, String dateFormat) throws Exception {
    SimpleDateFormat formatDate = new SimpleDateFormat(dateFormat);
    formatDate.setLenient(false);
    //期間指定開始の日付フォーマットチェック
    if(!StringUtils.isEmpty(startDate)){
      formatDate.parse(startDate);
    }
    //期間指定終了の日付フォーマットチェック
    if(!StringUtils.isEmpty(endDate)){
      formatDate.parse(endDate);
    }
  }

// add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 dou end
/*add FNSI-改修内容5237 任 start*/
  @Override
  public List<MstExamItem> getFigureValue(String facilityCd){
    return mstExamItemDao.selectExamItemFigure(facilityCd);
  }
  @Override
  public List<MstWaterSurveyPointType> getDecimalValue(String facilityCd){
    return mstWaterSurveyTypeDao.selectDecimal(facilityCd);
  }
  /*add FNSI-改修内容5237 任 end*/

  // add #11718 【#11600持ち越し】データリスト画面不正② fang start
  private void editDataKeys(Map<String, Object> dataKey, List<Map<String, Object>> ruleList) throws Exception {
    if(!CollectionUtils.isEmpty(ruleList)) {
      Map<String, Object> rule = ruleList.get(0);
      for(String key : rule.keySet()) {
        if(rule.get(key) != null) {
          Map<String, Object> ruleDetails = (Map<String, Object>)rule.get(key);
          if("in".equals(key)) {
            // 検索条件は「in」の場合
            String inKey = (String)ruleDetails.get("key");
            if(ruleDetails.get("type") != null && "text".equals(ruleDetails.get("type").toString())) {
              List<String> inValues = (List<String>)ruleDetails.get("values");
              dataKey.put(inKey, inValues);
            }
          }
        }
      }
    }
  }

  @Override
  public List<Object> getRowDataNew(String facilityCd, Map<String, List<DataListAggregationParam>> groupMap) throws Exception {
    ObjectMapper mapper = new ObjectMapper();
    List<Object> resultList = new ArrayList<>();
    String sqlCd = "";
    String detailCd = "";
    for(String key : groupMap.keySet()) {
      List<DataListAggregationParam> tempList = groupMap.get(key);
      Map<String, Object> dataKey = new HashMap<String, Object>();
      Long dataListDetailCd = tempList.get(0).getDataListDetailCd();
      detailCd = detailCd + dataListDetailCd + "\r\n";
      dataKey.put("ids", tempList.stream().map(DataListAggregationParam::getItemId).toList());
      dataKey.put("idStrArr", tempList.stream().map(el -> el.getItemId() != null ? el.getItemId().toString() : "").toList());
      dataKey.put("itemIds", tempList.stream().map(DataListAggregationParam::getItemId).toList());
      dataKey.put("facilityCd", facilityCd);
      if (tempList.get(0).getDateFrom() != null) {
        dataKey.put("dateFrom", tempList.get(0).getDateFrom());
      }
      if (tempList.get(0).getDateTo() != null) {
        dataKey.put("dateTo", tempList.get(0).getDateTo());
      }
      if (tempList.get(0).getType() != null) {
        dataKey.put("type", tempList.get(0).getType());
      }
      if(tempList.get(0).getKubun() != null){
        dataKey.put("kubun", tempList.get(0).getKubun());
      }
      SysDataListDetail detail = sysDataListDetailDao.selectByCd(dataListDetailCd);
      Map<String, Object> result = new HashMap<>();
      if (detail != null) {
        String rowData = detail.getCellDisplay();
        if (rowData != null) {
          if (detail.getDataSet() != null) {
            List<Map<String, Object>> dataSet = mapper.readValue(detail.getDataSet(),new TypeReference<List<Map<String, Object>>>() {});
            for(Map<String, Object> i: dataSet) {
              if(i.get("sql_cd") != null && !"".equals(String.valueOf(i.get("sql_cd")))) {
                sqlCd = sqlCd + i.get("sql_cd") + "\r\n";
              }
              if(i.get("sql_cd") != null && !"null".equals(i.get("sql_cd").toString())) {
                if(i.get("rules") != null) {
                  List<Map<String, Object>> ruleList = (List<Map<String, Object>>)i.get("rules");
                  editDataKeys(dataKey, ruleList);
                }
                List<Map<String, Object>> resultQuery = sysDataSetService.getDataList(Long.parseLong(String.valueOf(i.get("sql_cd"))), dataKey);
                String param = String.valueOf(i.get("param"));
                if (!resultQuery.isEmpty() && param != null ) {
                  result.put(param, resultQuery);
                }
              }
            }
          }
        }
        result.put("cellDisplay", rowData);
      }
      if(!result.isEmpty()) {
        for(DataListAggregationParam param : tempList) {
          Map<String, Object> tempMap = new HashMap<>();
          tempMap.put("cellDisplay", result.get("cellDisplay"));
          if(result.get("unit") != null) {
            List<Map<String, Object>> unitList = (List<Map<String, Object>>)result.get("unit");
            List<Map<String, Object>> tempResult = unitList.stream().filter(el
              -> el.get("cd") != null && el.get("cd").toString().equals(param.getItemId().toString())).collect(Collectors.toList());
            if(!CollectionUtils.isEmpty(tempResult)) {
              tempMap.put("unit", tempResult.get(0).get("unit"));
            } else if(tempList.size() == 1 && !CollectionUtils.isEmpty(unitList)) {
              // 単一検索結果の場合
              tempMap.put("unit", unitList.get(0).get("unit"));
            }
          }
          // 集計結果
          if(result.get("count") != null) {
            List<Map<String, Object>> countList = (List<Map<String, Object>>)result.get("count");
            List<Map<String, Object>> tempResult = countList.stream().filter(el
              -> el.get("cd") != null && el.get("cd").toString().equals(param.getItemId().toString())).collect(Collectors.toList());
            tempMap.put("id", param.getItemId());
            tempMap.put("detailCd", param.getDataListDetailCd());
            if(!CollectionUtils.isEmpty(tempResult)) {
              tempMap.put("count", tempResult);
            } else if(tempList.size() == 1) {
              // 単一検索結果の場合
              tempMap.put("count", countList);
            }
          } else {
            tempMap.put("count", new ArrayList<>());
          }
          resultList.add(tempMap);
        }
      }
    }
    return resultList;
  }
  // add #11718 【#11600持ち越し】データリスト画面不正② fang end

  // add #11895 データリスト「治療予定・実績」テンプレート恒久対応 fang start
  /**
   * {@link OrdMainDao#selectByPatIdFacilityCd} の逐次呼び出しを避け、同一キー順で {@code ordMainMin} に追加する。
   */
  private void appendPriorRstWeightOrdMains(Map<Long, Timestamp> patStartDate, String facilityCd, List<OrdMain> ordMainMin) {
    if (patStartDate == null || patStartDate.isEmpty()) {
      return;
    }
    List<PatIdRstAnchor> pairs = new ArrayList<>(patStartDate.size());
    for (Long patId : patStartDate.keySet()) {
      pairs.add(new PatIdRstAnchor(patId, patStartDate.get(patId)));
    }
    Map<Long, OrdMain> byPatId = new HashMap<>();
    final int chunkSize = 300;
    for (List<PatIdRstAnchor> chunk : Lists.partition(pairs, chunkSize)) {
      List<OrdMain> batch = ordMainDao.selectByPatIdFacilityCdBatch(chunk, facilityCd);
      if (batch != null) {
        for (OrdMain om : batch) {
          byPatId.put(om.getPatId(), om);
        }
      }
    }
    for (Long patId : patStartDate.keySet()) {
      OrdMain row = byPatId.get(patId);
      if (row != null) {
        ordMainMin.add(row);
      }
    }
  }
  // add #11895 データリスト「治療予定・実績」テンプレート恒久対応 fang end
}
