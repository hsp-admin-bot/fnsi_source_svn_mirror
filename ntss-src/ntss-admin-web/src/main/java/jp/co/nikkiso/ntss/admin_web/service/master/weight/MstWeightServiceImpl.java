package jp.co.nikkiso.ntss.admin_web.service.master.weight;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import static jp.co.nikkiso.ntss.core.dao.MasterMaintenanceGenericDao.*;

import java.util.*;
import java.util.stream.Collectors;

import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.entity.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.google.common.base.CaseFormat;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.FlagType;
import jp.co.nikkiso.ntss.admin_web.response.masterMaintenance.MasterColumn;
import jp.co.nikkiso.ntss.admin_web.response.masterMaintenance.MasterDataResponse;
import jp.co.nikkiso.ntss.admin_web.response.masterMaintenance.MasterUpdateResponse;
import jp.co.nikkiso.ntss.admin_web.response.weight.MstWeightExamResponse;
import jp.co.nikkiso.ntss.core.dao.MasterMaintenanceGenericDao;
import jp.co.nikkiso.ntss.core.dao.MntWeightStateDao;
import jp.co.nikkiso.ntss.core.dao.MstExamItemDao;
import jp.co.nikkiso.ntss.core.dao.MstSelectorDao;
import jp.co.nikkiso.ntss.core.dao.MstWeightDao;
import jp.co.nikkiso.ntss.core.dao.MstWeightScaleDao;
import jp.co.nikkiso.ntss.core.entity.MntWeightState;
import jp.co.nikkiso.ntss.core.entity.MstExamItem;
import jp.co.nikkiso.ntss.core.entity.MstWeight;
import jp.co.nikkiso.ntss.core.entity.MstWeightScale;
import jp.co.nikkiso.ntss.core.entity.SysMasterDefine;
import jp.co.nikkiso.ntss.core.entity.SysMasterDefine.ColumnInfo;
import jp.co.nikkiso.ntss.core.entity.SysMasterDefine.Combo;
import jp.co.nikkiso.ntss.core.entity.SysMasterDefine.ComboData;
import jp.co.nikkiso.ntss.core.entity.SysMasterDefine.Field;
import jp.co.nikkiso.ntss.core.entity.SysMasterDefine.FieldType;

import static jp.co.nikkiso.ntss.core.dao.MasterMaintenanceGenericDao.ALIAS_CODE;
import static jp.co.nikkiso.ntss.core.dao.MasterMaintenanceGenericDao.MODAL;
import static jp.co.nikkiso.ntss.core.dao.MasterMaintenanceGenericDao.OPERATION;
import static jp.co.nikkiso.ntss.core.dao.MasterMaintenanceGenericDao.SORT_INPUT_TIME;
import static jp.co.nikkiso.ntss.core.dao.MasterMaintenanceGenericDao.SORT_RANK;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

@Service
public class MstWeightServiceImpl implements MstWeightService {

  @Autowired
  MstWeightDao mstWeightDao;

  @Autowired
  MstWeightScaleDao mstWeightScaleDao;

  @Autowired
  MntWeightStateDao mntWeightStateDao;

  @Autowired
  MstExamItemDao mstExamItemDao;
  @Autowired
  MstSelectorDao mstSelectorDao;

  @Autowired
  private LogService logService;

  // #11987 2025.12.10 add スケールベッド対応 ベッドマスター取得 TDC渡辺 start
  @Override
  public List<MstSelector.Item> fetchMstBedList(String facilityCd) {

    List<MstSelector.Item> res;
    // mstBedからデータ取得
    MstSelector mstBedSelector = mstSelectorDao.selectByName(facilityCd, "mst_bed");
    if (Objects.isNull(mstBedSelector) || mstBedSelector.getOrderSettings().getItems().isEmpty()) {
      res = new ArrayList<>();
    } else {
      res = mstBedSelector.getOrderSettings().getItems();
    }
    return res;
  }
  // #11987 2025.12.10 add スケールベッド対応 ベッドマスター取得 TDC渡辺 end

  @Override
  public List<MstWeightExamResponse> fetchMstExamItemList(String facilityCd) {

    List<MstWeightExamResponse> res = new ArrayList<MstWeightExamResponse>();
    // mstExamItemからデータ取得
    List<MstExamItem> mstExamItem = mstExamItemDao.selectByFacilityCdForWeight(facilityCd);

    // レスポンス用に抽出
    for (MstExamItem exam: mstExamItem) {
      MstWeightExamResponse obj = new MstWeightExamResponse();
      obj.cd = exam.getExamItemCd();
      obj.name = exam.getExamItemName();
      obj.unit = exam.getUnit();
      res.add(obj);
    }
    return res;
  }

  @Override
  public List<MstWeight> mstWeightSelectByFacilityCd(String facilityCd){
    return mstWeightDao.selectByFacility(facilityCd);
  }

  @Override
  public MstWeight mstWeightSelectByScaleCd(Long weightCd) {
    return mstWeightDao.selectByWeightCd(weightCd);
  }

  @Override
  public MstWeight mstWeightSelectByFacilityCdWeightNo(String facilityCd, int weightNo) {
    return mstWeightDao.selectByFacilityWeightNo(facilityCd, weightNo);
  }

  @Override
  @Transactional
  public int mstWeightInsert(MstWeight param) {
    int r = mstWeightDao.insert(param);
    if (r > 0) {
      MntWeightState mnt = new MntWeightState();
      mnt.setWeightCd(param.getWeightCd());
      mnt.setFacilityCd(param.getFacilityCd());
      mntWeightStateDao.insert(mnt);
    }
    return r;
  }

  @Override
  @Transactional
  public int mstWeightUpdate(MstWeight param) {
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
    LogEventUtils.setOperatorId(param,logService);
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
    return mstWeightDao.update(param);
  }

  @Override
  @Transactional
  public int mstWeightUpdateCheckContent(Long weightCd, String checkContent) {
    MstWeight param = mstWeightDao.selectByWeightCd(weightCd);
    param.setCheckContent(checkContent);
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
    LogEventUtils.setOperatorId(param,logService);
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
    return mstWeightDao.update(param);
  }

  @Override
  @Transactional
  public int mstWeightUpdatePrintSetting(Long weightCd, String printSetting) {
    MstWeight param = mstWeightDao.selectByWeightCd(weightCd);
    param.setPrintSetting(printSetting);
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
    LogEventUtils.setOperatorId(param,logService);
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
    return mstWeightDao.update(param);
  }

  @Override
  @Transactional
  public int mstWeightUpdateColorSetting(Long weightCd, String colorSetting) {
    MstWeight param = mstWeightDao.selectByWeightCd(weightCd);
    param.setColorSetting(colorSetting);
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
    LogEventUtils.setOperatorId(param,logService);
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
    return mstWeightDao.update(param);
  }

  @Override
  @Transactional
  public int mstWeightUpdateAudioSetting(Long weightCd, String audioSetting) {
    MstWeight param = mstWeightDao.selectByWeightCd(weightCd);
    param.setAudioSetting(audioSetting);
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
    LogEventUtils.setOperatorId(param,logService);
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
    return mstWeightDao.update(param);
  }

  @Override
  public MstWeightScale mstWeightScaleSelectByFacility(String facilityCd) {
    return mstWeightScaleDao.selectByFacility(facilityCd);
  }

  @Override
  @Transactional
  public int mstWeightScaleInsert(MstWeightScale param) {
    return mstWeightScaleDao.insert(param);
  }

  @Override
  @Transactional
  public int mstWeightScaleUpdate(MstWeightScale param) {
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
    LogEventUtils.setOperatorId(param,logService);
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
    return mstWeightScaleDao.update(param);
  }

  /**
   * マスタメンテナンス用の汎用的Daoインタフェース.
   */
  @Autowired
  private MasterMaintenanceGenericDao masterGenericDao;

  private SysMasterDefine getMstWeightScaleDefine() {
    // マスタ定義の取得
    StringBuilder columnInfoJsonStr = new StringBuilder();
    columnInfoJsonStr.append("{\"fields\": [")
    .append("{\"type\": \"number\",\"alias\": \"code\",\"title\": \"体重測定コード\",\"physical_name\": \"weight_scale_cd\"},")
//    .append("{\"type\": \"modal\",\"title\": \"共通設定\"},")
    .append("{\"type\": \"combo1\",\"alias\": \"name\",\"title\": \"ICカード種別\",\"hidden\": \"true\",\"editable\": \"true\",\"validation\": {\"required\": \"true\"},\"physical_name\": \"ic_card\"},")
    .append("{\"type\": \"number\",\"title\": \"患者バーコード有効桁\",\"hidden\": \"false\",\"editable\": \"true\",\"validation\": {\"max\": 99,\"min\": 0,\"required\": \"true\"},\"physical_name\": \"pat_id_digit\"},")
    .append("{\"type\": \"combo1\",\"title\": \"測定初期画面\",\"hidden\": \"false\",\"editable\": \"true\",\"validation\": {\"required\": \"true\"},\"physical_name\": \"default_screen_class\"},")
    // mod FNSI-体重測定設定マスタの制御 徐 start
    // .append("{\"type\": \"number\",\"title\": \"検査結果有効期間\",\"hidden\": \"false\",\"editable\": \"true\",\"validation\": {\"min\": 0,\"required\": \"true\"},\"physical_name\": \"exam_period\"},")
    // .append("{\"type\": \"number\",\"title\": \"車いす校正有効日数\",\"hidden\": \"false\",\"editable\": \"true\",\"validation\": {\"min\": 0,\"required\": \"true\"},\"physical_name\": \"wheel_chair_period\"},")
    // mod redmine 6240 体重計マスタで設定する単位が分かりにくい項目がある。宋qy start
    // .append("{\"type\": \"number\",\"title\": \"検査結果有効期間\",\"hidden\": \"false\",\"editable\": \"true\",\"validation\": {\"min\": 0,\"max\": 9999,\"required\": \"true\"},\"physical_name\": \"exam_period\"},")
    .append("{\"type\": \"number\",\"title\": \"検査結果有効期間(日)\",\"hidden\": \"false\",\"editable\": \"true\",\"validation\": {\"min\": 0,\"max\": 9999,\"required\": \"true\"},\"physical_name\": \"exam_period\"},")
    // mod redmine 6240 体重計マスタで設定する単位が分かりにくい項目がある。宋qy end
    .append("{\"type\": \"number\",\"title\": \"車いす校正有効日数\",\"hidden\": \"false\",\"editable\": \"true\",\"validation\": {\"min\": 0,\"max\": 9999,\"required\": \"true\"},\"physical_name\": \"wheel_chair_period\"},")
    // mod FNSI-体重測定設定マスタの制御 徐 end
    .append("{\"type\": \"combo1\",\"title\": \"風袋初期単位\",\"hidden\": \"false\",\"editable\": \"true\",\"validation\": {\"required\": \"true\"},\"physical_name\": \"tare_unit_class\"},")
    .append("{\"type\": \"combo1\",\"title\": \"除水初期単位\",\"hidden\": \"false\",\"editable\": \"true\",\"validation\": {\"required\": \"true\"},\"physical_name\": \"water_unit_class\"},")
    .append("{\"type\": \"combo1\",\"title\": \"２回測定チェック\",\"hidden\": \"false\",\"editable\": \"true\",\"validation\": {\"required\": \"true\"},\"physical_name\": \"is_double_check\"},")
    // mod FNSI-体重測定設定マスタの制御 徐 start
    // .append("{\"type\": \"number\",\"title\": \"２回測定チェック許容値(kg)\",\"hidden\": \"false\",\"editable\": \"true\",\"format\": \"n2\", \"validation\": {\"min\": 0,\"required\": \"true\"},\"physical_name\": \"double_check_tolerance\"},")
    .append("{\"type\": \"number\",\"title\": \"２回測定チェック許容値(kg)\",\"hidden\": \"false\",\"editable\": \"true\",\"format\": \"n2\", \"validation\": {\"min\": 0,\"max\": 300,\"required\": \"true\"},\"physical_name\": \"double_check_tolerance\"},")
    // mod FNSI-体重測定設定マスタの制御 徐 end
    .append("{\"type\": \"combo1\",\"title\": \"透析中条件送信画面表示\",\"hidden\": \"false\",\"editable\": \"true\",\"validation\": {\"required\": \"true\"},\"physical_name\": \"is_during_dialysis_view\"},")
    .append("{\"type\": \"combo1\",\"title\": \"前回後体重取得元\",\"hidden\": \"false\",\"editable\": \"true\",\"validation\": {\"required\": \"true\"},\"physical_name\": \"previous_weight_source_class\"}")
    .append("]}");
    ColumnInfo cInfo = new ColumnInfo(columnInfoJsonStr.toString());
    StringBuilder comboDataJsonStr = new StringBuilder();
    comboDataJsonStr.append("{\"combos\": [")
    .append("{\"values\": [{\"text\": \"カード無し\", \"value\": 0}, {\"text\": \"Felica\", \"value\": 1}], \"physical_name\": \"ic_card\"},")
    .append("{\"values\": [{\"text\": \"簡易\", \"value\": 0}, {\"text\": \"詳細\", \"value\": 1}], \"physical_name\": \"default_screen_class\"},")
    .append("{\"values\": [{\"text\": \"g\", \"value\": 0}, {\"text\": \"kg\", \"value\": 1}], \"physical_name\": \"tare_unit_class\"},")
    .append("{\"values\": [{\"text\": \"g\", \"value\": 0}, {\"text\": \"kg\", \"value\": 1}], \"physical_name\": \"water_unit_class\"},")
    .append("{\"values\": [{\"text\": \"無効\", \"value\": \"0\"}, {\"text\": \"有効\", \"value\": \"1\"}], \"physical_name\": \"is_double_check\"},")
    .append("{\"values\": [{\"text\": \"しない\", \"value\": \"0\"}, {\"text\": \"する\", \"value\": \"1\"}], \"physical_name\": \"is_during_dialysis_view\"},")
    .append("{\"values\": [{\"text\": \"治療別\", \"value\": 0}, {\"text\": \"共通\", \"value\": 1}], \"physical_name\": \"previous_weight_source_class\"}")
    .append("]}");
    ComboData cData = new ComboData(comboDataJsonStr.toString());
    SysMasterDefine sysMasterDefine = new SysMasterDefine();
    sysMasterDefine.setAllowAddRecord(FlagType.FLAG_OFF);
    sysMasterDefine.setAllowSort(FlagType.FLAG_OFF);
    sysMasterDefine.setMode("1");
    sysMasterDefine.setMasterPhysicalName("mst_weight_scale");
    sysMasterDefine.setMasterName("体重測定マスタ");
    sysMasterDefine.setDispClass("2");
    sysMasterDefine.setColumnInfo(cInfo);
    sysMasterDefine.setComboData(cData);

    return sysMasterDefine;
  }

  /**
   * データ更新.
   *
   * @param define     マスタ定義
   * @param data       画面で編集したデータ
   */
  private void updateData(SysMasterDefine define, List<Map<String, Object>> data) {
    data.stream().filter(e -> e.get(OPERATION).equals(AdminWebConstant.MasterOperationType.UPDATE)).forEach(e -> {
      // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
      LogEventUtils.setOperatorId(define,logService);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
      // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
      masterGenericDao.updateMasterData(e, define);
    });
  }

  /**
   * データ挿入.
   *
   * @param define     マスタ定義
   * @param facilityCd 施設コード
   * @param data       画面で編集したデータ
   */
  private void insertData(SysMasterDefine define, String facilityCd, List<Map<String, Object>> data) {

    data.stream().filter(e -> e.get(OPERATION).equals(AdminWebConstant.MasterOperationType.INSERT)).forEach(e -> {
      masterGenericDao.insertMasterData(e, define, facilityCd);
      if (e.containsKey(ALIAS_CODE)) {
        // 採番されたPK項目の値を取得(serial値)
        Long serialValue = masterGenericDao.selectCurrentSeq(masterGenericDao.getFieldName(ALIAS_CODE, define), define.getMasterPhysicalName());
        // PKを採番済のものに置換
        e.replace(ALIAS_CODE, serialValue);
      }
    });
  }

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  public MasterUpdateResponse updateMasterData(String masterPhysicalName, String facilityCd,
      List<Map<String, Object>> updateData) {

    // マスタ定義の取得
    SysMasterDefine define = getMstWeightScaleDefine();

    updateData.forEach(e -> {
      Optional<Object> codeOpt = Optional.ofNullable(e.get(ALIAS_CODE));
      codeOpt.ifPresent(code -> e.put(ALIAS_CODE, Long.parseLong(code.toString())));
    });

    // 更新データの抽出
    List<Map<String, Object>> data = Optional.ofNullable(updateData).orElse(Collections.emptyList()).stream()
        .filter(e -> e.get(OPERATION) != null).collect(Collectors.toList());

    // 追加
    insertData(define, facilityCd, data);
    // 更新
    updateData(define, data);

    return new MasterUpdateResponse();

  }
  /**
   * {@inheritDoc}
   */
  @Override
  public MasterDataResponse getMasterData(String masterName, String facilityCd) {

    MasterDataResponse masterResponse = new MasterDataResponse();
    SysMasterDefine sysMasterDefine = getMstWeightScaleDefine();

    // カラム情報が定義されている場合はカラム情報によりレスポンスデータを作成
    Optional.ofNullable(sysMasterDefine.getColumnInfo())
        .filter(e -> e != null)
        .filter(e -> e.getFields() != null && !e.getFields().isEmpty())
        .ifPresent(c -> {

          // カラム情報の作成
          masterResponse.columns = makeMasterColumn(sysMasterDefine, facilityCd);

          // スキーマのフィールド情報の作成
          masterResponse.localDataSource.schema.model.fields = makeMasterField(sysMasterDefine);

          // 対象データ取得
          masterResponse.localDataSource.data = setDefaultValue(
              masterGenericDao.getMasterData(sysMasterDefine, facilityCd), sysMasterDefine);
        });

    // 成功レスポンス返却
    return masterResponse;
  }

  /**
   * データ取得値の既定値設定.
   *
   * @param sysMasterDefine マスタ定義データ
   * @param data            取得データ
   * @return data 取得データ
   */
  private List<Map<String, Object>> setDefaultValue(List<Map<String, Object>> data, SysMasterDefine define) {

    // データタイプにより初期値を設定
    for (Map<String, Object> record : data) {
      for (Field field : define.getColumnInfo().getFields()) {

        // コンボ表示項目で値が未設定であれば空文字で作成
        if (field.isComboColumn() && record.get(field.getCamelFieldName()) == null) {
          record.put(field.getCamelFieldName(), "");
        }
        // JSON項目ではtypeとvalueが取得されるため、valueを返却
        if (field.getType() == FieldType.JSON && record.get(field.getCamelFieldName()) != null) {
          record.put(field.getCamelFieldName(), record.get(field.getCamelFieldName()).toString());
        }
        // INET項目ではtypeとvalueが取得されるため、valueを返却
        if (field.getType() == FieldType.INET && record.get(field.getCamelFieldName()) != null) {
          record.put(field.getCamelFieldName(), record.get(field.getCamelFieldName()).toString());
        }
      }
    }

    return data;
  }
  /**
   * フィールド情報の作成.
   *
   * @param sysMasterDefine マスタ定義データ
   * @return フィールド情報MAP
   */
  private Map<String, Object> makeMasterField(SysMasterDefine sysMasterDefine) {

    Map<String, Object> fieldsMap = new HashMap<>();
    Map<String, Object> fieldsList;

    for (Field field : sysMasterDefine.getColumnInfo().getFields()) {

      fieldsList = new HashMap<>();

      // タイプ
      if (field.getType() != null) {
        fieldsList.put("type", field.getSchemaType());
      }

      // バリデーション
      Map<String, Object> validationMap = new HashMap<>();
      if (field.getValidation() != null) {

        // Max
        if (field.getValidation().getMax() != null) {
          validationMap.put("max", field.getValidation().getMax());
        }

        // Min
        if (field.getValidation().getMin() != null) {
          validationMap.put("min", field.getValidation().getMin());
        }

        // Maxlength
        if (field.getValidation().getMaxlength() != null) {
          validationMap.put("maxlength", field.getValidation().getMaxlength());
        }

        // Required
        if (field.getValidation().isRequired() != false) {
          validationMap.put("required", field.getValidation().isRequired());
        }

        fieldsList.put("validation", validationMap);
      }

      // 表示カラムの規定値は 1:表示 として設定
      if (field.getType() == FieldType.DISP) {
        fieldsList.put("defaultValue", FlagType.FLAG_ON);
      }

      fieldsMap.put(field.getCamelFieldName(), fieldsList);
    }

    // ソート項目をNUMBER型として追加
    fieldsList = new HashMap<>();
    fieldsList.put("type", FieldType.NUMBER);
    fieldsMap.put(SORT_RANK, sortRankFields());
    fieldsMap.put(SORT_INPUT_TIME, fieldsList);

    return fieldsMap;
  }

  @SuppressWarnings("serial")
  private Map<String, Object> sortRankFields() {
    return new HashMap<String, Object>() {
      {
        put("type", FieldType.NUMBER);
        put("validation", new HashMap<String, Integer>() {{put("min", 1);}});
        put("defaultValue", 1);
      }
    };
  }

  /**
   * レコード並び替え許可項目名.
   */
  static final String ALLOW_SORT = "allowSort";

  /**
   * KendoUI 数値項目の標準フォーマット(整数部のみ少数なし).
   */
  static final String NUMBER_FORMAT = "n0";

  /**
   * ソート用表示項目名.
   */
  static final String SORT_RANK_TITLE = "並び順";

  /**
   * フォーマット文字列をKendoUI用に変換.
   *
   * @param String 対象文字列
   * @return 変換後文字列
   */
  private String getKendoFormatString(String formatString) {
    return "{0:" + formatString + "}";
  }

  /**
   * 文字列をスネークケースに変換.
   *
   * @param String 対象文字列
   * @return 変換後文字列
   */
  private String convertToSnake(String targetString) {
    return CaseFormat.LOWER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, targetString);
  }

  /**
   * カラム情報の作成.
   *
   * @param sysMasterDefine マスタ定義データ
   * @return カラム情報リスト
   */
  private List<MasterColumn> makeMasterColumn(SysMasterDefine sysMasterDefine, String facilityCd) {

    // カラム情報の作成
    List<MasterColumn> masterColumns = new ArrayList<MasterColumn>();

    MasterColumn masterColumn = null;

    // ソート順項目を追加
    masterColumn = new MasterColumn(SORT_RANK, SORT_RANK_TITLE, false, false, getKendoFormatString(NUMBER_FORMAT), null, false, "");
    masterColumns.add(masterColumn);

    // ソート順用追加時刻項目を追加
    masterColumn = new MasterColumn(SORT_INPUT_TIME, SORT_INPUT_TIME, true, true, null, null, true, "");
    masterColumns.add(masterColumn);

    for (Field field : sysMasterDefine.getColumnInfo().getFields()) {
      // 書式を設定
      // ただし日付型で書式指定がなければ既定値を設定
      // 数値型で書式指定がなければ少数なしを設定
      String formatString = null;
      if (field.getFormat() != null) {
        formatString = field.getFormat();
      } else {
        if (field.getType() == FieldType.DATE) {
          formatString = "yyyy/MM/dd";
        } else if (field.getType() == FieldType.NUMBER) {
          formatString = NUMBER_FORMAT;
        }
      }

      // コンボボックスリスト
      Combo combo = null;

      // 固定コンボの場合コンボ用データを作成
      if (field.getType() == FieldType.COMBO_SPECIFIC) {
        combo = sysMasterDefine.getComboData().getCombos()
            .stream().filter(m -> m.getPhysicalName().equals(field.getPhysicalName())).findFirst().orElse(null);
      }

      // 特定項目と非表示指定項目は非表示
      final boolean isHidden = field.getType() == FieldType.DEL || field.isAliasCodeColumn() || field.isHiddenColumn();

      // 編集可否定義
      final boolean isEdit = Optional.ofNullable(field.getEditable()).orElse(true);

      // modalタイプの場合、PhysicalNameにdefinedModalTypeMasterMaintenanceを設定
      if (field.getType() == FieldType.MODAL) {
        field.setPhysicalName(convertToSnake(MODAL));
      }

      masterColumn = new MasterColumn(field.getCamelFieldName(), field.getTitle(), isHidden, field.isLockedColumn(),
          formatString == null ? null : getKendoFormatString(formatString), (combo == null) ? null : combo.getValues(), isEdit, "");

      masterColumns.add(masterColumn);
    }

    // 付加情報としてoperationを追加
    masterColumn = new MasterColumn(OPERATION, OPERATION, true, false, null, null, true, "");
    masterColumns.add(masterColumn);

    return masterColumns;

  }
}
