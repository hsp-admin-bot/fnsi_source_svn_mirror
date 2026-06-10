package jp.co.nikkiso.ntss.admin_web.service.master;

// add FNSI-改修内容 薬剤マスタ、医療材料マスタの更新にて、ord_mainのjson内容も合わせて更新する。 周 start
import java.io.IOException;
// add FNSI-改修内容 薬剤マスタ、医療材料マスタの更新にて、ord_mainのjson内容も合わせて更新する。 周 end
import java.io.PrintWriter;
import java.io.StringWriter;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;

import org.json.JSONArray;
import org.json.JSONObject;
import org.seasar.doma.jdbc.Config;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Lazy;
import org.springframework.dao.DataAccessResourceFailureException;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.core.query.Update;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.CollectionUtils;
import org.springframework.util.ObjectUtils;
import org.springframework.util.StringUtils;

// add FNSI-改修内容 薬剤マスタ、医療材料マスタの更新にて、ord_mainのjson内容も合わせて更新する。 周 start
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;
import com.google.common.base.CaseFormat;

// add FNSI-改修内容 薬剤マスタ、医療材料マスタの更新にて、ord_mainのjson内容も合わせて更新する。 周 end
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.FlagType;
import jp.co.nikkiso.ntss.admin_web.request.BloodPurrify.constant.Constant;
import jp.co.nikkiso.ntss.admin_web.request.patientCapture.JournalCreateRequestPayload;
import jp.co.nikkiso.ntss.admin_web.response.masterMaintenance.MasterColumn;
import jp.co.nikkiso.ntss.admin_web.response.masterMaintenance.MasterDataResponse;
import jp.co.nikkiso.ntss.admin_web.response.masterMaintenance.MasterUpdateResponse;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.FacilitySettingService;
import jp.co.nikkiso.ntss.admin_web.service.IndHistoryMakeService;
import jp.co.nikkiso.ntss.admin_web.service.JournalService;
import jp.co.nikkiso.ntss.admin_web.service.MaintenanceMNoticeService;
import jp.co.nikkiso.ntss.admin_web.service.MongoServiceImpl;
import jp.co.nikkiso.ntss.admin_web.service.Utility.UtilityService;
import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.patHistory.PatMainHistory;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.MasterMaintenanceGenericDao;
import jp.co.nikkiso.ntss.core.dao.MstBedDao;
import jp.co.nikkiso.ntss.core.dao.MstEquipmentDao;
import jp.co.nikkiso.ntss.core.dao.MstExamSetDao;
import jp.co.nikkiso.ntss.core.dao.MstFavoriteFacilityDao;
import jp.co.nikkiso.ntss.core.dao.MstHolidayDao;
import jp.co.nikkiso.ntss.core.dao.MstMachineDao;
import jp.co.nikkiso.ntss.core.dao.MstMachineRecordControlDao;
import jp.co.nikkiso.ntss.core.dao.MstMachineTypeDao;
import jp.co.nikkiso.ntss.core.dao.MstMedicineDao;
import jp.co.nikkiso.ntss.core.dao.MstMedicineMixDao;
import jp.co.nikkiso.ntss.core.dao.MstSelectorDao;
import jp.co.nikkiso.ntss.core.dao.MstStatusMapBedLayoutDao;
import jp.co.nikkiso.ntss.core.dao.MstTreatmentDao;
import jp.co.nikkiso.ntss.core.dao.MstWheelChairDao;
import jp.co.nikkiso.ntss.core.dao.OrdChecklistDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.PatExamMainDao;
import jp.co.nikkiso.ntss.core.dao.PatExamPatternDao;
import jp.co.nikkiso.ntss.core.dao.PatMainDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.dao.PatRadMainDao;
import jp.co.nikkiso.ntss.core.dao.SysMasterDefineDao;
import jp.co.nikkiso.ntss.core.entity.MstEquipment;
import jp.co.nikkiso.ntss.core.entity.MstExamSet;
import jp.co.nikkiso.ntss.core.entity.MstMachineRecordControl;
import jp.co.nikkiso.ntss.core.entity.MstMachineType;
import jp.co.nikkiso.ntss.core.entity.MstMedicine;
import jp.co.nikkiso.ntss.core.entity.MstMedicineMix;
import jp.co.nikkiso.ntss.core.entity.MstSelector;
import jp.co.nikkiso.ntss.core.entity.MstSelector.Item;
import jp.co.nikkiso.ntss.core.entity.MstStatusMapBedLayout;
import jp.co.nikkiso.ntss.core.entity.MstTreatment;
import jp.co.nikkiso.ntss.core.entity.MstWheelChair;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.PatExamMain;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.PatRadMain;
import jp.co.nikkiso.ntss.core.entity.SysFacility;
import jp.co.nikkiso.ntss.core.entity.SysMasterDefine;
import jp.co.nikkiso.ntss.core.entity.SysMasterDefine.ColumnInfo;
import jp.co.nikkiso.ntss.core.entity.SysMasterDefine.Combo;
import jp.co.nikkiso.ntss.core.entity.SysMasterDefine.ComboValue;
import jp.co.nikkiso.ntss.core.entity.SysMasterDefine.Field;
import jp.co.nikkiso.ntss.core.entity.SysMasterDefine.FieldType;
import jp.co.nikkiso.ntss.core.entity.SysMasterDefine.ReferenceComboDef;
import jp.co.nikkiso.ntss.core.entity.custom.MachineKeyInfo;
import jp.co.nikkiso.ntss.core.entity.custom.MstFavoriteFacilityData;
import jp.co.nikkiso.ntss.core.entity.custom.ReferenceCombo;
import jp.co.nikkiso.ntss.core.entity.custom.ReferenceComboDefNode;
import jp.co.nikkiso.ntss.core.logevent.DataUpdateLogCommonNew;
import jp.co.nikkiso.ntss.core.logevent.LogServiceCore;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.trigger.MstBedTrigger;
import jp.co.nikkiso.ntss.core.trigger.MstDeviceEdgeTrigger;
import jp.co.nikkiso.ntss.core.trigger.MstMachineTrigger;
import jp.co.nikkiso.ntss.core.trigger.MstMainteHisTrigger;
import jp.co.nikkiso.ntss.core.utils.MongoHealthCheckService;
import lombok.Getter;
import lombok.Setter;

import static jp.co.nikkiso.ntss.core.dao.MasterMaintenanceGenericDao.ALIAS_CODE;
import static jp.co.nikkiso.ntss.core.dao.MasterMaintenanceGenericDao.ALIAS_NAME;
import static jp.co.nikkiso.ntss.core.dao.MasterMaintenanceGenericDao.IS_DEL;
import static jp.co.nikkiso.ntss.core.dao.MasterMaintenanceGenericDao.IS_DISP;
import static jp.co.nikkiso.ntss.core.dao.MasterMaintenanceGenericDao.MODAL;
import static jp.co.nikkiso.ntss.core.dao.MasterMaintenanceGenericDao.OPERATION;
import static jp.co.nikkiso.ntss.core.dao.MasterMaintenanceGenericDao.SORT_INPUT_TIME;
import static jp.co.nikkiso.ntss.core.dao.MasterMaintenanceGenericDao.SORT_RANK;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

/**
 * マスタ編集画面のService実装クラス.
 */
@Service
public class MasterEditServiceImpl implements MasterEditService {

  //add 10553 連携イベント発生部分不正【最優先】zhao start
  @Autowired
  @Lazy
  JournalService journalService;

  @Autowired
  PatPersonalMainDao patPersonalMainDao;
  //add 10553 連携イベント発生部分不正【最優先】zhao end

  /* del by chamaojia 2026-05-06 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
  // private static String IS_DEL_1 = "1";
  /* del by chamaojia 2026-05-06 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */

  /**
   * 表示フラグ用コンボ.
   */
  /* upd by chamaojia 2026-05-06 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
  // private static Combo comboDisp;
  private static final Combo comboDisp;
  /* upd by chamaojia 2026-05-06 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */

  /**
   * staticコンストラクタ.
   */
  static {
    // 表示カラム用コンボの作成
    List<ComboValue> comboValues = new ArrayList<ComboValue>();
    ComboValue isDisp = new ComboValue(FlagType.FLAG_ON, " ");
    comboValues.add(isDisp);

    ComboValue isNotDisp = new ComboValue(FlagType.FLAG_OFF, "削除");
    comboValues.add(isNotDisp);

    comboDisp = new Combo("is_disp", comboValues);
  }

  /**
   * 並び順の保存用内部クラス.
   */
  @Getter
  @Setter
  private class SortData {

    /**
     * 画面で設定された第1ソート順.
     */
    Long sortRank;

    /**
     * 画面で設定された第2ソート順.
     */
    Long sortInputTime;

    /**
     * コード項目値.
     */
    Long code;

    /**
     * 名称項目値.
     */
    String name;
    /**
     * JLAC10コード
     */
    String jlac10_cd;

  }

  /**
   * レコード追加許可項目名.
   */
  static final String ALLOW_ADD_RECORD = "allowAddRecord";

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

  // DB更新ログ出力ロジック xie Start
  @Autowired
  private LogServiceCore logServiceCore;

  @Autowired
  private EventLoggerFactory eventLoggerFactory;
  // DB更新ログ出力ロジック xie end

  /**
   * マスタ定義のDaoインタフェース.
   */
  @Autowired
  private SysMasterDefineDao sysMasterDefineDao;

  /**
   * セレクトマスタのDaoインタフェース.
   */
  @Autowired
  private MstSelectorDao mstSelectorDao;

  /**
   * マスタメンテナンス用の汎用的Daoインタフェース.
   */
  @Autowired
  private MasterMaintenanceGenericDao masterGenericDao;

  /**
   * よく使う施設マスタ用Daoインタフェース.
   */
  @Autowired
  private MstFavoriteFacilityDao mstFavoriteFacilityDao;

  /**
   * 参照型コンボのサービス.
   */
  @Autowired
  private ReferenceComboService referenceComboService;

  /**
   * 緊急発報マスタのサービス.
   */
  @Autowired
  private MaintenanceMNoticeService maintenanceMNoticeService;

  /**
   * 汎用関数サービス
   */
  @Autowired
  private UtilityService utilityService;

  /**
   * 装置記録マスタ用Daoインタフェース.
   */
  @Autowired
  private MstMachineRecordControlDao mstMachineRecordControlDao;

  /**
   * 休日マスタ用Daoインタフェース.
   */
  @Autowired
  private MstHolidayDao mstHolidayDao;

  // DB更新ログ出力ロジック xie Start
  @Autowired
  LogService logService;
  // DB更新ログ出力ロジック xie end

  //NO6822 2021-12-10 12:09:30 崔fc Start
  @Autowired
  MstMachineTypeDao mstMachineTypeDao;

  @Autowired
  MstStatusMapBedLayoutDao mstStatusMapBedLayoutDao;
  //NO6822 2021-12-10 12:09:30 崔fc end

  @Autowired
  MstMachineDao mstMachineDao;

  @Autowired
  MstMachineTrigger mstMachineTrigger;

  @Autowired
  MstBedTrigger mstBedTrigger;

  @Autowired
  MstDeviceEdgeTrigger mstDeviceEdgeTrigger;
  //add 10618検査セットマスタ、検査項目マスタ、一般撮影検査依頼マスタ編集時に関連データを補正する zhao start
  @Autowired
  MstExamSetDao mstExamSetDao;

  @Autowired
  PatExamMainDao patExamMainDao;

  @Autowired
  PatRadMainDao patRadMainDao;

  @Autowired
  PatExamPatternDao patExamPatternDao;

  @Autowired
  FacilitySettingService facilitySettingService;
  //add 10618検査セットマスタ、検査項目マスタ、一般撮影検査依頼マスタ編集時に関連データを補正する zhao end

  // add 7686 修正 chen start
  /**
   * ベッドマスタ
   */
  @Autowired
  private MstBedDao mstBedDao;
  // add 7686 修正 chen end

  // add #7327 治療方法マスタ操作時の動作がおかしい 王永吉 start
  // add 9539 チェックリストマスタの設定を変更して保存しても保存できない zy start
  @Autowired
  MstMedicineDao mstMedicineDao;
  @Autowired
  private MstMedicineMixDao mstMedicineMixDao;
  @Autowired
  private MstEquipmentDao mstEquipmentDao;
  @Autowired
  private OrdChecklistDao ordChecklistDao;
  @Autowired
  private OrdMainDao ordMainDao;
  // add 9539 チェックリストマスタの設定を変更して保存しても保存できない zy end
  @Autowired
  MstTreatmentDao mstTreatmentDao;
  @Autowired
  IndHistoryMakeService indHistoryMakeService;
  private HashMap<Integer, String> doGetDeviceMode (HashMap<Integer, String> deviceModeMap){
    deviceModeMap.put(-1, "不明");
    deviceModeMap.put(0, "HD");
    deviceModeMap.put(1, "ECUM");
    deviceModeMap.put(2, "HDF");
    deviceModeMap.put(3, "HF");
    deviceModeMap.put(4, "HD+補液");
    deviceModeMap.put(5, "ECUM+補液");
    deviceModeMap.put(6, "AFBF");
    deviceModeMap.put(7, "OHDF");
    deviceModeMap.put(8, "OHF");
    deviceModeMap.put(9, "特殊浄化");
    deviceModeMap.put(10, "I-HDF");
    return deviceModeMap;
  }
  // add #7327 治療方法マスタ操作時の動作がおかしい 王永吉 end

  @Autowired
  MstMainteHisTrigger mstMainteHisTrigger;
  @Autowired
  private PatMainDao patMainDao;
  @Autowired
  private MstWheelChairDao mstWheelChairDao;
  @Autowired(required = false)
  private MongoTemplate mongoTemplate;
  @Autowired(required = false)
  private MongoServiceImpl mongoServiceImpl;
  /**
   * {@inheritDoc}
   */
  @Override
  public MasterDataResponse getMasterData(String masterName, String facilityCd) {

    MasterDataResponse masterResponse = new MasterDataResponse();
    // マスタ定義の取得
    SysMasterDefine sysMasterDefine = sysMasterDefineDao.selectByName(masterName);

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

        // 取得したデータの並び替え
        masterResponse.localDataSource.data = sortData(masterResponse.localDataSource.data, sysMasterDefine,
          facilityCd);
      });

    // 成功レスポンス返却
    return masterResponse;
  }

  // add #6217 全施設マスタ画面が遅い guanhao start
  /**
   * {@inheritDoc}
   */
  @Override
  public List<SysFacility> getSysFacilityByLimitAndOffset(Integer limit, Integer offset, String keyword) {
    return sysMasterDefineDao.selectSysFacilityByLimitAndOffset(limit, offset, keyword);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<SysFacility> getSysFacilityAfterSaveByLimit(Integer limit, String keyword, List<String> medicalInstitutionCds) {
    return sysMasterDefineDao.selectSysFacilityAfterSaveByLimit(limit, keyword, medicalInstitutionCds);
  }

  /**
   * マスタを件数取得する
   */
  @Override
  public String getTotal() {
    return sysMasterDefineDao.getTotal();
  }
  // add #6217 全施設マスタ画面が遅い guanhao end

  /**
   * {@inheritDoc}
   */
  @Override
  public MasterDataResponse getMasterDataWithSql(String masterName, String facilityCd) {

    MasterDataResponse masterResponse = new MasterDataResponse();
    // マスタ定義の取得
    SysMasterDefine sysMasterDefine = sysMasterDefineDao.selectByName(masterName);

    // カラム情報が定義されている場合はカラム情報によりレスポンスデータを作成
    Optional.ofNullable(sysMasterDefine.getColumnInfo())
      .filter(e -> e != null)
      .filter(e -> e.getFields() != null && !e.getFields().isEmpty())
      .ifPresent(c -> {

        // カラム情報の作成
        masterResponse.columns = makeMasterColumn(sysMasterDefine, facilityCd);

        // スキーマのフィールド情報の作成
        masterResponse.localDataSource.schema.model.fields = makeMasterField(sysMasterDefine);

        List<Map<String, Object>> masterDataList = new ArrayList<Map<String, Object>>();

        switch (masterName) {
          case "mst_favorite_facility":
            List<MstFavoriteFacilityData> favoriteFacilityList = mstFavoriteFacilityDao.selectAllJoinSysFacility(facilityCd);
            for (MstFavoriteFacilityData favoriteFacility : favoriteFacilityList) {

              // オブジェクトをHashMapに変換
              Map<String, Object> hashData = new HashMap<>();
              hashData.put("code", favoriteFacility.getMasterCd());
              hashData.put("facilityCd", favoriteFacility.getFacilityCd());
              hashData.put("favoriteFacilityCd", favoriteFacility.getFavoriteFacilityCd());
              // mod よく使う施設の変更 （施設コードから医療機関コードに主キーを変更。） 杜 start
              hashData.put("medicalInstitutionCd", favoriteFacility.getMedicalInstitutionCd());
              // mod よく使う施設の変更 （施設コードから医療機関コードに主キーを変更。） 杜 end
              hashData.put("name", favoriteFacility.getFavoriteFacilityName());
              hashData.put("prefCd", favoriteFacility.getPrefCd());
              hashData.put("prefName", favoriteFacility.getPrefName());
              hashData.put("address", favoriteFacility.getAddress());
              hashData.put("phoneNo", favoriteFacility.getPhoneNo());
              hashData.put("faxNo", favoriteFacility.getFaxNo());
              hashData.put("isDisp", favoriteFacility.getIsDisp());
              hashData.put("isFavDel", favoriteFacility.getIsFavDel());
              hashData.put("isSysDel", favoriteFacility.getIsSysDel());
              masterDataList.add(hashData);
            }
            break;
          // add 装置記録マスタ新規 孔 start
          case "mst_machine_record_control":
            List<MstMachineRecordControl> mstMachineRecordControlList = mstMachineRecordControlDao.selectByFacility(facilityCd, null);
            for (MstMachineRecordControl mstMachineRecordControl : mstMachineRecordControlList) {
              // オブジェクトをHashMapに変換
              Map<String, Object> hashData = new HashMap<>();
              hashData.put("facilityCd", facilityCd);
              hashData.put("code", mstMachineRecordControl.getMachineRecordCd());
              hashData.put("machineRecordMessage", mstMachineRecordControl.getMachineRecordMessage());
              hashData.put("dispFlg", mstMachineRecordControl.getDispFlg());
              //del 装置記録マスタ 装置フラグを削除，警報フラグを削除 start
              //hashData.put("machineFlg", mstMachineRecordControl.getMachineFlg());
              //hashData.put("alarmFlg", mstMachineRecordControl.getAlarmFlg());
              //del 装置記録マスタ 装置フラグを削除，警報フラグを削除 end
              hashData.put("upDate", mstMachineRecordControl.getUpDate());
              masterDataList.add(hashData);
            }
            break;
          case "mst_complaint":
            // 愁訴処置マスタのカラム情報はvalidationの際に使用
            break;
          // add 装置記録マスタ新規 孔 start
          default:
            masterDataList = masterGenericDao.getMasterData(sysMasterDefine, facilityCd);
        }

        // 対象データ取得
        masterResponse.localDataSource.data = setDefaultValue(masterDataList, sysMasterDefine);

        // 取得したデータの並び替え
        masterResponse.localDataSource.data = sortData(masterResponse.localDataSource.data, sysMasterDefine,
          facilityCd);
      });

    // 成功レスポンス返却
    return masterResponse;
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
    masterColumn = new MasterColumn(SORT_RANK, SORT_RANK_TITLE, false, true, getKendoFormatString(NUMBER_FORMAT), null, false, "");
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

      // 表示フラグの場合専用コンボデータを作成
      if (field.getType() == FieldType.DISP) {
        combo = comboDisp;
      }
      // 固定コンボの場合コンボ用データを作成
      else if (field.getType() == FieldType.COMBO_SPECIFIC) {
        combo = sysMasterDefine.getComboData().getCombos()
          .stream().filter(m -> m.getPhysicalName().equals(field.getPhysicalName())).findFirst().orElse(null);
      }
      // 参照型コンボの場合コンボ用データを作成
      else if (field.getType() == FieldType.COMBO_REFERENCE) {
        Optional<ReferenceComboDef> defOptional = sysMasterDefine.getReferenceComboDef();
        Optional<Combo> comboOptional = def2Combo(field, defOptional, facilityCd, field.getValidation(), sysMasterDefine);
        // コンボ情報にセット
        combo = comboOptional.orElse(null);
      }

      // 特定項目と非表示指定項目は非表示
      final boolean isHidden = field.getType() == FieldType.DEL || field.isAliasCodeColumn() || field.isHiddenColumn();

      // 編集可否定義
      final boolean isEdit = Optional.ofNullable(field.getEditable()).orElse(true);

      // modalタイプの場合、PhysicalNameにdefinedModalTypeMasterMaintenanceを設定
      if (field.getType() == FieldType.MODAL) {
        field.setPhysicalName(convertToSnake(MODAL));
      }

      masterColumn = new MasterColumn(field.getAliasFieldName(), field.getTitle(), isHidden, field.isLockedColumn(),
        formatString == null ? null : getKendoFormatString(formatString), (combo == null) ? null : combo.getValues(), isEdit, field.getType().getValue());
      masterColumns.add(masterColumn);
    }

    // 付加情報としてoperationを追加
    masterColumn = new MasterColumn(OPERATION, OPERATION, true, false, null, null, true, "");
    masterColumns.add(masterColumn);

    // 付加情報として追加許可を追加
    boolean allowAddRecord = sysMasterDefine.getAllowAddRecord().equals("0") ? false : true;
    if (allowAddRecord) {
      masterColumn = new MasterColumn(ALLOW_ADD_RECORD, ALLOW_ADD_RECORD, true, false, null, null, true, "");
      masterColumns.add(masterColumn);
    }

    // 付加情報として並び替え許可を追加
    boolean allowSort = sysMasterDefine.getAllowSort().equals("0") ? false : true;
    if (allowSort) {
      masterColumn = new MasterColumn(ALLOW_SORT, ALLOW_SORT, true, false, null, null, true, "");
      masterColumns.add(masterColumn);
    }

    return masterColumns;

  }

  /**
   * フィールド情報の作成.
   *
   * @param sysMasterDefine マスタ定義データ
   * @return フィールド情報MAP
   */
  private Map<String, Object> makeMasterField(SysMasterDefine sysMasterDefine) {

    Map<String, Object> fieldsMap = new LinkedHashMap<>();
    Map<String, Object> fieldsList;

    for (Field field : sysMasterDefine.getColumnInfo().getFields()) {

      fieldsList = new HashMap<>();

      // タイプ
      if (field.getType() != null) {
        fieldsList.put("type", field.getSchemaType());
      }

      // 初期値
      if (field.getDefaultValue() != null) {
        fieldsList.put("defaultValue", field.getDefaultValue());
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


  /**
   * データ取得値の既定値設定.
   *
   * @param data   取得データ
   * @param define マスタ定義データ
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
        // CRYPTO項目ではtypeとvalueが取得されるため、valueを復号化して返却
        if (field.getType() == FieldType.CRYPTO && record.get(field.getCamelFieldName()) != null) {
          record.put(field.getCamelFieldName(), utilityService.personalInfoDecrypto(record.get(field.getCamelFieldName()).toString()));
        }
      }
    }

    return data;
  }

  /**
   * 文字列をスネークケースに変換.
   *
   * @param targetString 対象文字列
   * @return 変換後文字列
   */
  private String convertToSnake(String targetString) {
    return CaseFormat.LOWER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, targetString);
  }

  /**
   * フォーマット文字列をKendoUI用に変換.
   *
   * @param formatString 対象文字列
   * @return 変換後文字列
   */
  private String getKendoFormatString(String formatString) {
    return "{0:" + formatString + "}";
  }

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  public MasterUpdateResponse updateMasterData(String masterPhysicalName, String facilityCd,
                                               List<Map<String, Object>> updateData) {

    // マスタ定義の取得
    SysMasterDefine define = sysMasterDefineDao.selectByName(masterPhysicalName);

    // PK項目の型変換
    updateData.forEach(e -> {
      Optional<Object> codeOpt = Optional.ofNullable(e.get(ALIAS_CODE));
      codeOpt.ifPresent(code -> e.put(ALIAS_CODE, Long.parseLong(code.toString())));
    });

    // 更新データの抽出
    List<Map<String, Object>> data = Optional.ofNullable(updateData).orElse(Collections.emptyList()).stream()
      .filter(e -> e.get(OPERATION) != null).collect(Collectors.toList());

    // add FNSI-redMine #4569対応　陳 start
    if (data != null) {

      for (int i = 0; i < data.size(); i++) {

        Map<String, Object> insData = data.get(i);
        // 体重計機種が「A&D」場合
        if("0".equals(String.valueOf(insData.get("deviceClass")))) {
          data.get(i).put("telegramFormat", "{\"telegram_format\": \"ST,+{0:00000.00} kg[CR][LF]\"}");
        }

        // 体重計機種が「田中衛機」場合
        if("1".equals(String.valueOf(insData.get("deviceClass")))) {
          data.get(i).put("telegramFormat", "{\"telegram_format\": \"ST,GS,+{0:0000.00} kg[CR][LF]\"}");
        }

        // 体重計機種が「ヤマトハカリ」場合
        if("2".equals(String.valueOf(insData.get("deviceClass")))) {
          data.get(i).put("telegramFormat", "{\"telegram_format\": \"[SOH][SOH]17  [STX]CD000,DTDATE,NW{0:00000.00}kg,TW999.99Kg,GW999.99Kg,CT999,VH999kg,VL999Kg,[ETX][BCC][CR]\"}");
        }
      }
    }
    // add FNSI-redMine #4569対応　陳 end

    // 保存前に暗号化対象カラムを暗号化
    data = cryptoData(define, data);

    /* add by chamaojia 2023-10-27 [9973] 治療方法セットマスタmst _treatmentのis _use判定保存ノード  --start */
    // 治療方法セットマスタ
    if ("mst_treatment_set".equals(masterPhysicalName)){
      for (int i = 0; i < data.size(); i++){
        MstTreatment selectedTreat = mstTreatmentDao.selectByCd(Integer.parseInt(data.get(i).get("treatmentCd").toString()));
        Map<String, String> treatCondIsUseMap = splitTreatCondIsUse(selectedTreat.getTreatmentConditionSetting());
        JSONObject jsonObject = new JSONObject(data.get(i).get("indCondInfo").toString());
        for (int j = 1; j <= 38; j++) {
          String key = String.valueOf(j);
          // isUseに基づいてアイテムを除去するには
          if (treatCondIsUseMap.containsKey(key) && "0".equals(treatCondIsUseMap.get(key))) {
            jsonObject.remove(key);
          }
          // add 9664 by kangjie 20240110 start
          // シングルニードル
//          if (j == Constant.CondItemCd.USE_SINGLE_NEEDLE) {
//            JSONObject contentJSONObject = new JSONObject(jsonObject.get(key).toString());
//            if ("1".equals(contentJSONObject.get("value").toString())) {  // 使用する
//              // A針/V針は含まない
//              jsonObject.remove(String.valueOf(Constant.CondItemCd.NEEDLE_A));
//              jsonObject.remove(String.valueOf(Constant.CondItemCd.NEEDLE_V));
//            } else {  // 使用しない
//              // SN針は含まない
//              jsonObject.remove(String.valueOf(Constant.CondItemCd.NEEDLE_S));
//            }
//          }
          // add 9664 by kangjie 20240110 end
        }
        // add 9664 by kangjie 20240110 start
        // シングルニードル
        if (jsonObject.has("12")) {
          JSONObject contentJSONObject = new JSONObject(jsonObject.get("12").toString());
          if ("1".equals(contentJSONObject.get("value").toString())) {  // 使用する
            // A針/V針は含まない
            jsonObject.remove(String.valueOf(Constant.CondItemCd.NEEDLE_A));
            jsonObject.remove(String.valueOf(Constant.CondItemCd.NEEDLE_V));
          } else {  // 使用しない
            // SN針は含まない
            jsonObject.remove(String.valueOf(Constant.CondItemCd.NEEDLE_S));
          }
        }
        // add 9664 by kangjie 20240110 end
        // 値の再設定
        data.get(i).put("indCondInfo", jsonObject.toString());

      }
    }
    /* add by chamaojia 2023-10-27 [9973] 治療方法セットマスタmst _treatmentのis _use判定保存ノード  --end */

    // add #11047 水質検査種別マスタ 小数点以下の桁数を補う 20240927 ztc start
    if (masterPhysicalName.equals("mst_water_survey_type")) {
      if (data != null) {
        for (int i = 0; i < data.size(); i++) {
          if(data.get(i).get("decimalDigits") != null && data.get(i).get("initialValue") != null){
            String decimalDigits = data.get(i).get("decimalDigits").toString();
            String initialValue = data.get(i).get("initialValue").toString();
            BigDecimal bd = new BigDecimal(initialValue);
            bd = bd.setScale(Integer.parseInt(decimalDigits), RoundingMode.HALF_UP);
            String initialValueFormat = bd.toPlainString();  // 指数表記を避けて固定小数点表記を取得
            data.get(i).put("initialValue", initialValueFormat);
          }
        }
      }
    }
    // add #11047 水質検査種別マスタ 小数点以下の桁数を補う 20240927 ztc end

    // 追加
    insertData(define, facilityCd, data);
    // add #7327 治療方法マスタ操作時の動作がおかしい 王永吉 start
    if ("mst_treatment".equals(masterPhysicalName)){
      HashMap<Long, String> deviceModes = new HashMap<>();
      for (int i = 0; i < data.size(); i++){
        if (data.get(i).containsKey("code") && null != data.get(i).get("code") && !"".equals(data.get(i).get("code"))){
          Long treatmentCd = Long.parseLong(data.get(i).get("code").toString());
          MstTreatment treatmentLists = mstTreatmentDao.selectByCd(Integer.parseInt(treatmentCd.toString()));

          String ordTreatmentDeviceMode = "";
          HashMap<Integer, String> deviceModeMap = new HashMap<>();
          deviceModeMap = doGetDeviceMode (deviceModeMap);
          if (deviceModeMap.containsKey(treatmentLists.getDeviceMode())){
            ordTreatmentDeviceMode = deviceModeMap.get(treatmentLists.getDeviceMode());
          }

          String newTreatmentDeviceMode = "";
          //mod 治療法マイスターに新たに1行追加、力治療法名のみ入力した後に保存ボタンをクリックしてエラー 修正 2023/06/06 ztc start
          if (!StringUtils.isEmpty(data.get(i).get("deviceMode")) && deviceModeMap.containsKey(Integer.parseInt(data.get(i).get("deviceMode").toString()))){
            //mod 治療法マイスターに新たに1行追加、力治療法名のみ入力した後に保存ボタンをクリックしてエラー 修正 2023/06/06 ztc end
            newTreatmentDeviceMode = deviceModeMap.get(Integer.parseInt(data.get(i).get("deviceMode").toString()));
          }

          //
          if (!ordTreatmentDeviceMode.equals(newTreatmentDeviceMode)){
            String doChangeStr = ordTreatmentDeviceMode + "→" + newTreatmentDeviceMode;
            deviceModes.put(treatmentCd, doChangeStr);
          }

          if ("0".equals(data.get(i).get("isDisp"))){
            String doChangeStr = ordTreatmentDeviceMode + "【削除済み】";
            deviceModes.put(treatmentCd, doChangeStr);
          }
        }
      }
      if (deviceModes.size() > 0){
        indHistoryMakeService.getOrdAndNewDeviceModes(deviceModes);
      }
    }
    // add #7327 治療方法マスタ操作時の動作がおかしい 王永吉 end
// add 9539 チェックリストマスタの設定を変更して保存しても保存できない zy start
    if (masterPhysicalName.equals("mst_medicine")) {
      if (data != null) {
        List<Long> ordNoList = ordMainDao.selectOrdNoByRstDialysisState0(facilityCd);
        for (int i = 0; i < data.size(); i++) {
          Integer mediCd =  Integer.parseInt(data.get(i).get("code").toString());
          MstMedicine mstMedicine = mstMedicineDao.selectByMediCd(mediCd);
          if (mstMedicine != null) {
            /* mod by shiyw 2024-04-02 #10196 ord_mainのデータ定義の修正:classCd=nullと互換性あり --start */
            // if(!mstMedicine.getClassCd().equals(Integer.parseInt(data.get(i).get("classCd").toString()))){
            Integer editClassCd = ObjectUtils.isEmpty(data.get(i).get("classCd")) ? null : Integer.parseInt(data.get(i).get("classCd").toString());
            if (!ObjectUtils.nullSafeEquals(mstMedicine.getClassCd(), editClassCd)) {
              /* mod by shiyw 2024-04-02 #10196 ord_mainのデータ定義の修正:classCd=nullと互換性あり --end */
              Integer medicineType = 1;
              List<Integer> funcClassList = Arrays.asList(1, 3);
              Long code =  Long.parseLong(data.get(i).get("code").toString());
              ordChecklistDao.deleteByMedicineTypeAndCodeAndFuncClass(funcClassList, code, medicineType, facilityCd, ordNoList);
            }
          }
        }
      }
    }
    if (masterPhysicalName.equals("mst_medicine_mix")) {
      if (data != null) {
        List<Long> ordNoList = ordMainDao.selectOrdNoByRstDialysisState0(facilityCd);
        for (int i = 0; i < data.size(); i++) {
          Integer mstMedicineMixCd =  Integer.parseInt(data.get(i).get("code").toString());
          MstMedicineMix mstMedicineMix = mstMedicineMixDao.selectByMedicineMixCd(mstMedicineMixCd);
          if (mstMedicineMix != null) {
            /* mod by shiyw 2024-04-02 #10196 ord_mainのデータ定義の修正:classCd=nullと互換性あり --start */
            // if(!mstMedicineMix.getClassCd().equals(Integer.parseInt(data.get(i).get("classCd").toString()))){
            Integer editClassCd = ObjectUtils.isEmpty(data.get(i).get("classCd")) ? null : Integer.parseInt(data.get(i).get("classCd").toString());
            if (!ObjectUtils.nullSafeEquals(mstMedicineMix.getClassCd(), editClassCd)) {
              /* mod by shiyw 2024-04-02 #10196 ord_mainのデータ定義の修正:classCd=nullと互換性あり --end */
              Integer medicineType = 2;
              List<Integer> funcClassList = Arrays.asList(1, 3);
              Long code =  Long.parseLong(data.get(i).get("code").toString());
              ordChecklistDao.deleteByMedicineTypeAndCodeAndFuncClass(funcClassList, code, medicineType, facilityCd, ordNoList);
            }
          }
        }
      }
    }
    if (masterPhysicalName.equals("mst_equipment")) {
      if (data != null) {
        List<Long> ordNoList = ordMainDao.selectOrdNoByRstDialysisState0(facilityCd);
        for (int i = 0; i < data.size(); i++) {
          Integer mstEquipmentCd =  Integer.parseInt(data.get(i).get("code").toString());
          MstEquipment mstEquipment = mstEquipmentDao.selectByEquipmentCd(mstEquipmentCd);
          if (mstEquipment != null) {
            /* mod by shiyw 2024-04-02 #10196 ord_mainのデータ定義の修正:classCd=nullと互換性あり --start */
            // if(!mstEquipment.getClassCd().equals(Integer.parseInt(data.get(i).get("classCd").toString()))){
            Integer editClassCd = ObjectUtils.isEmpty(data.get(i).get("classCd")) ? null : Integer.parseInt(data.get(i).get("classCd").toString());
            if (!ObjectUtils.nullSafeEquals(mstEquipment.getClassCd(), editClassCd)) {
              /* mod by shiyw 2024-04-02 #10196 ord_mainのデータ定義の修正:classCd=nullと互換性あり --end */
              Integer equipType = 0;
              List<Integer> funcClassList = Arrays.asList(1, 2);
              Long code =  Long.parseLong(data.get(i).get("code").toString());
              ordChecklistDao.deleteByEquipTypeAndCodeAndFuncClass(funcClassList, code, equipType, facilityCd, ordNoList);
            }
          }
        }
      }
    }
    //add 10618検査セットマスタ、検査項目マスタ、一般撮影検査依頼マスタ編集時に関連データを補正する zhao start
    //add 10553 連携イベント発生部分不正【最優先】zhao start
    List<PatExamMain> patExamMainListAll = new ArrayList<>();
    List<PatRadMain> patRadMainListAll = new ArrayList<>();
    //add 10553 連携イベント発生部分不正【最優先】zhao end
    if (masterPhysicalName.equals("mst_exam_item")) {
      if (data != null) {
        JSONArray examItemInfoJSONArray = new JSONArray();
        for (int i = 0; i < data.size(); i++) {
          String examItemCd =  data.get(i).get("code").toString();
          String examItemName =  "\""+data.get(i).get("name").toString()+"\"";
          String isDisp = data.get(i).get("isDisp").toString();
          //add 10553 連携イベント発生部分不正【最優先】zhao start
          List<PatExamMain> patExamMainList = patExamMainDao.selectExamOrderInfoByItemCd(facilityCd,examItemCd,getDate(facilityCd,"exam"));
          List<MstExamSet> mstExamSetList = mstExamSetDao.selectExamSetByExamItemCd(facilityCd,examItemCd);
          for(PatExamMain patExamMain:patExamMainList){
            patExamMain.setIsDel("5");
            //mod 10125 ケース16 検査項目マスタ編集 zrx start
//          if(mstExamSetList.size()>0 && "3".equals(mstExamSetList.get(0).getExamSetClass())){
            if(mstExamSetList.size() > 0
              && mstExamSetList.stream().anyMatch(examSet -> "3".equals(examSet.getExamSetClass()))
              && "1".equals(patExamMain.getPhyOrdClass())) {
              //mod 10125 ケース16 検査項目マスタ編集 zrx end
              patExamMain.setPhyOrdClass("3");
            }
          }
          patExamMainListAll.addAll(patExamMainList);
          //add 10553 連携イベント発生部分不正【最優先】zhao end
          patExamMainDao.updateExamOrderInfoByItemCd(facilityCd,examItemName,examItemCd,isDisp,getDate(facilityCd,"exam"));
          patExamPatternDao.updateExamOrderInfoByItemCd(facilityCd,examItemName,examItemCd,isDisp);
          JSONObject examItemInfoJSONObject = new JSONObject();
          examItemInfoJSONObject.put("exam_item_cd",examItemCd);
          examItemInfoJSONObject.put("exam_item_name",data.get(i).get("name").toString());
          examItemInfoJSONObject.put("is_disp",isDisp);
          examItemInfoJSONArray.put(examItemInfoJSONObject);
        }
        mstExamSetDao.updateExamItemInfoByItemCd(facilityCd,examItemInfoJSONArray.toString());
      }
    }

    if (masterPhysicalName.equals("mst_exam_set")) {
      if (data != null) {
        for (int i = 0; i < data.size(); i++) {
          String setCd =  data.get(i).get("code").toString();
          String setName =  "\""+data.get(i).get("name").toString()+"\"";
          String isDisp = data.get(i).get("isDisp").toString();
          String examSetInfo =  data.get(i).get("iteminfo").toString();
          JSONArray examSetInfoJSONArray = new JSONArray(data.get(i).get("iteminfo").toString());
          JSONArray examSetInfoJSONArrayNew = new JSONArray();
          if(examSetInfoJSONArray.length()>0){
            for(int c=0;c<examSetInfoJSONArray.length();c++){
              examSetInfoJSONArrayNew.put(new JSONObject(examSetInfoJSONArray.get(c).toString()).put("set_cd",Integer.parseInt(setCd)));
            }
          }
          //add 10553 連携イベント発生部分不正【最優先】zhao start
          List<PatExamMain> patExamMainList = patExamMainDao.selectExamOrderInfoByItemCdAndSetCd(facilityCd,setCd,getDate(facilityCd,"exam"));
          for(PatExamMain patExamMain:patExamMainList){
            patExamMain.setIsDel(isDisp);
            patExamMain.setPhyOrdClass(data.get(i).get("examsetclass").toString());
          }
          patExamMainListAll.addAll(patExamMainList);
          //add 10553 連携イベント発生部分不正【最優先】zhao end
          //patExamMainDao.updateOrderExamSetInfoByItemCd(facilityCd,setName,setCd,isDisp,getDate(facilityCd));
          patExamMainDao.updateExamOrderInfoByItemCdAndSetCd(facilityCd,setCd,examSetInfoJSONArrayNew.toString()
            .replace("exam_item_cd","item_cd").replace("exam_item_name","item_name"),getDate(facilityCd,"exam"),setName,isDisp);
          patExamPatternDao.updateExamOrderInfoBySetCd(facilityCd,setCd,examSetInfo);
        }
      }
    }
    if (masterPhysicalName.equals("mst_rad_set")) {
      if (data != null) {
        for (int i = 0; i < data.size(); i++) {
          String setCd =  data.get(i).get("code").toString();
          String setName =  "\""+data.get(i).get("name").toString()+"\"";
          String isDisp = data.get(i).get("isDisp").toString();
          //add 10553 連携イベント発生部分不正【最優先】zhao start
          List<PatRadMain> patRadMainList = patRadMainDao.selectOrderRadSetInfoBySetCd(facilityCd,setCd,getDate(facilityCd,"rad"));
          for(PatRadMain patRadMain:patRadMainList){
            patRadMain.setIsDel(isDisp);
          }
          patRadMainListAll.addAll(patRadMainList);
          //add 10553 連携イベント発生部分不正【最優先】zhao end
          patRadMainDao.updateOrderRadSetInfoBySetCd(facilityCd,setName,setCd,isDisp,getDate(facilityCd,"rad"));
        }
      }
    }
    //add 10618検査セットマスタ、検査項目マスタ、一般撮影検査依頼マスタ編集時に関連データを補正する zhao end
    // add 9539 チェックリストマスタの設定を変更して保存しても保存できない zy end
    // 車いすマスタ
    if (masterPhysicalName.equals("mst_wheel_chair")) {
      // 個人所有変更時患者情報更新処理
      updatePatByIsPersonal(facilityCd, data);
    }

    // 更新
    //add 12643 帳票を参照しているマスタを削除してから当該帳票を削除しマスタを復活させると参照異常が発生する sun start
    for (Map<String, Object> e : data) {

      if ("mst_treatment".equals(masterPhysicalName) && "0".equals(String.valueOf(e.get("isDisp")))) {
        List<String> reportFields = Arrays.asList(
          "reportId", "reportIdHw", "reportIdBw", "reportIdAw", "reportIdDev", "reportIdAct"
        );
        for (String field : reportFields) {
          e.put(field, null);
        }
      }

      if ("mst_pat_event_sub_category".equals(masterPhysicalName) && "0".equals(String.valueOf(e.get("isDisp")))) {
        e.put("templateCd", null);

        String dispItemInfoStr = (String) e.get("dispItemInfo");
        if (dispItemInfoStr != null && !dispItemInfoStr.isEmpty()) {
          JSONArray dispItemInfoArr = new JSONArray(dispItemInfoStr);
          for (int i = 0; i < dispItemInfoArr.length(); i++) {
            JSONObject item = dispItemInfoArr.getJSONObject(i);
            if (item.has("reportCd")) {
              item.put("reportCd", JSONObject.NULL);
            }
          }
          e.put("dispItemInfo", dispItemInfoArr.toString());
        }
      }
    }
    //add 12643 帳票を参照しているマスタを削除してから当該帳票を削除しマスタを復活させると参照異常が発生する sun end
// 更新
    updateData(define, data,masterPhysicalName);
    // add FNSI-改修内容 薬剤マスタ、医療材料マスタの更新にて、ord_mainのjson内容も合わせて更新する。 周 start
    // 薬剤マスタと医療材料マスタ
//    del 5734 薬剤・医材マスタの修正による透析情報の反映しない。 関　start
//    if (masterPhysicalName.equals("mst_medicine") || masterPhysicalName.equals("mst_equipment")) {
//      updateOrdMain(define, facilityCd, data);
//    }
//    del 5734 薬剤・医材マスタの修正による透析情報の反映しない。 関　end
    // add FNSI-改修内容 薬剤マスタ、医療材料マスタの更新にて、ord_mainのjson内容も合わせて更新する。 周 end
    // マスタセレクタの作成
    createMstSelector(facilityCd, masterPhysicalName, updateData);
    // 緊急発報マスタの作成(送信先グループ、警報通知マスタを対象)
    createMstMNotice(masterPhysicalName, data);
    //add 10553 連携イベント発生部分不正【最優先】zhao start
    if(patExamMainListAll.size()>0 || patRadMainListAll.size()>0){
      callCreateJournalForCtrNo(patExamMainListAll,patRadMainListAll);
    }
    //add 10553 連携イベント発生部分不正【最優先】zhao end
    return new MasterUpdateResponse();

  }

  /**
   * 患者情報更新(車いすマスタ個人所有変更時)
   *
   * @param facilityCd 施設コード
   * @param data 変更データ
   */
  private void updatePatByIsPersonal(String facilityCd, List<Map<String, Object>> data) {
    if (data != null) {
      // 個人所有更新IDセット
      Set<Long> updatedIds = new HashSet<>();
      // mongoフィールド削除対象セット
      Set<Long> deleteMongoFieldIds = new HashSet<>();

      for (int i = 0; i < data.size(); i++) {
        Long patId = ObjectUtils.isEmpty(data.get(i).get("patId")) ? null : Long.parseLong(data.get(i).get("patId").toString());
        Long wheelChairCd = Long.parseLong(data.get(i).get("code").toString());

        // 更新前車いす情報検索
        MstWheelChair mstWheelChair = mstWheelChairDao.selectByWheelChairCd(wheelChairCd, null, null);
        // 更新前の車いす所有患者取得※新規登録後なので、新規登録された値も更新前として取れるので注意
        Long oldPatId = mstWheelChair != null ? mstWheelChair.getPatId() : null;

        // 個人所有ありの場合、かつ新規登録か個人所有変更の場合
        if (patId != null && ("1".equals(data.get(i).get(OPERATION).toString()) || !Objects.equals(patId, oldPatId))) {
          // 患者に紐づく共用所有車いす検索
          List<Long> patIdsWheelChairCdDel = patMainDao.selectPadIdListByWheelChairCd(facilityCd, wheelChairCd);
          if (!ObjectUtils.isEmpty(patIdsWheelChairCdDel)) {
            // 共用所有車いす解除
            patMainDao.updateWheelChairCdDel(wheelChairCd);
            // 解除した対象の患者IDを保持
            deleteMongoFieldIds.addAll(patIdsWheelChairCdDel.stream().collect(Collectors.toList()));
          }
          // 個人所有患者の車いす情報更新
          patMainDao.updateIsWheelChair(patId);
          // mongoの車いす情報フィールド更新
          updatePatMainHistoryByMstWheelChair(facilityCd, wheelChairCd, List.of(patId.toString()));

          // 更新ありの患者IDとして登録
          updatedIds.add(patId);
        }

        // 更新の場合かつ個人所有をなしor別の患者に変更の場合は変更前の患者IDを保持
        if (!"1".equals(data.get(i).get(OPERATION).toString()) && oldPatId != null && !Objects.equals(patId, oldPatId)) {
          deleteMongoFieldIds.add(oldPatId);
        }
      }

      // 車いすの割当がなくなった患者の、mongoの車いす情報フィールド更新※新たに個人所有にした物は除く
      updatePatMainHistoryByMstWheelChair(facilityCd, null, deleteMongoFieldIds.stream().filter(id -> !updatedIds.contains(id))
          .map(String::valueOf).collect(Collectors.toList()));
    }
  }

  /**
   * MongoDB更新(車いすマスタ変更時)
   *
   * @param facilityCd 施設コード
   * @param wheelChairCd 車いすコード ※nullの時は削除の動きになる
   * @param patIdList 患者IDリスト
   */
  private void updatePatMainHistoryByMstWheelChair(String facilityCd, Long wheelChairCd, List<String> patIdList) {
    try {
      if (MongoHealthCheckService.getMongoDBConnected()) {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        Timestamp now = new Timestamp(new Date().getTime());
        Update update = new Update();
        update.set("ins_date", now);
        update.set("reg_date", sdf.format(now));
        update.set("up_date", sdf.format(now));

        List<PatMainHistory> queryLastPatMainHistorys = new ArrayList<>();
        Query query = new Query();
        query.addCriteria(Criteria.where("facility_cd").is(facilityCd)
            .and("pat_id").in(patIdList)
            .and("latest_flag").is("on"));
        queryLastPatMainHistorys.addAll(mongoTemplate.find(query, PatMainHistory.class));
        if (wheelChairCd == null) {
          // 車いす系フィールドを削除
          update.unset("wheel_chair_cd");
          update.unset("wheel_chair_name");
          update.unset("wheel_chair_weight");
        } else {
          // 車いす系フィールドをセット
          MstWheelChair mstWheelChair = mstWheelChairDao.selectByWheelChairCd(wheelChairCd, null, null);
          update.set("is_wheel_chair", "1");
          update.set("wheel_chair_cd", wheelChairCd);
          update.set("wheel_chair_name", mstWheelChair.getWheelChairName());
          update.set("wheel_chair_weight", mstWheelChair.getWheelChairWeight());
        }

        // 更新
        mongoTemplate.updateMulti(query, update, "pat_main_history");

        // 既存の最新フラグを折ったものを追加
        if (!CollectionUtils.isEmpty(queryLastPatMainHistorys)) {
          mongoServiceImpl.insertPatMainHistorysTasks(queryLastPatMainHistorys);
        }
      }
    } catch (DataAccessResourceFailureException exception) {
      MongoHealthCheckService.setMongoDBConnected(false);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//            exception.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(exception));
      if (!StringUtils.isEmpty(facilityCd)) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
    }
  }

  //add 10553 連携イベント発生部分不正【最優先】zhao start
  private void callCreateJournalForCtrNo(List<PatExamMain> patExamMainList , List<PatRadMain> patRadMainList ){
    Set<PatExamMain> examSet = new HashSet<>(patExamMainList);
    patExamMainList = new ArrayList<>(examSet);
    Set<PatRadMain> radSet = new HashSet<>(patRadMainList);
    patRadMainList = new ArrayList<>(radSet);
    NtssUser user = (NtssUser) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
    List<String> facilityCdList = new ArrayList<>();
    if(patRadMainList.size()>0){
      facilityCdList.add(patRadMainList.get(0).getFacilityCd());
    }else{
      facilityCdList.add(patExamMainList.get(0).getFacilityCd());
    }
    List<PatPersonalMain> patPersonalMainList = patPersonalMainDao.selectAll(facilityCdList);
    List<JournalCreateRequestPayload> journalList = new ArrayList<>();
    for(PatExamMain patExamMain : patExamMainList){
      String hospPatId = "";
      if(patPersonalMainList.stream().filter(a -> a.getPat_id().equals(patExamMain.getPatId())).collect(Collectors.toList()).size()>0){
        hospPatId = patPersonalMainList.stream().filter(a -> a.getPat_id().equals(patExamMain.getPatId())).collect(Collectors.toList()).get(0).getHosp_pat_id();
      }
      SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
      JournalCreateRequestPayload payload = new JournalCreateRequestPayload();
      payload.setAnaResult("0");
      payload.setBaseDate(sdf.format(patExamMain.getRegExamDate()));
      if("3".equals(patExamMain.getPhyOrdClass())){
        payload.setCoopCd("phy_ord");
      }else{
        payload.setCoopCd("exam_ord");
      }
      payload.setCoopCdIndex("");
      payload.setCoopResult("0");
      payload.setCrud("U");
      payload.setDirection("S");
      payload.setFacilityCd(patExamMain.getFacilityCd());
      if("5".equals(patExamMain.getIsDel()) && "3".equals(patExamMain.getPhyOrdClass())){
        payload.setOpeCd("900017");
      }else if("0".equals(patExamMain.getIsDel()) && "3".equals(patExamMain.getPhyOrdClass())){
        payload.setCrud("D");
        payload.setOpeCd("900019");
      }else if("1".equals(patExamMain.getIsDel()) && "3".equals(patExamMain.getPhyOrdClass())){
        payload.setOpeCd("900018");
      }else if("0".equals(patExamMain.getIsDel())){
        PatExamMain pem = patExamMainDao.selectPatExamMain(patExamMain.getExamMainCd());
        if(new JSONArray(pem.getOrderExamSetInfo()).length() == 0|| "0".equals(patExamMain.getRegOrderClass())){
          payload.setCrud("D");
        }else{
          payload.setCrud("U");
        }
        payload.setOpeCd("900009");
      }else if("1".equals(patExamMain.getIsDel())){
        payload.setOpeCd("900008");
      }else if("5".equals(patExamMain.getIsDel())){
        payload.setOpeCd("900007");
      }
      payload.setOrdNo(patExamMain.getExamMainCd());
      payload.setPatId(patExamMain.getPatId());
      payload.setUserId(user.getUserId());
      payload.setHospPatId(hospPatId);
      journalList.add(payload);
    }

    for(PatRadMain patRadMain : patRadMainList){
      String hospPatId = "";
      if(patPersonalMainList.stream().filter(a -> a.getPat_id().equals(patRadMain.getPatId())).collect(Collectors.toList()).size()>0){
        hospPatId = patPersonalMainList.stream().filter(a -> a.getPat_id().equals(patRadMain.getPatId())).collect(Collectors.toList()).get(0).getHosp_pat_id();
      }
      SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
      JournalCreateRequestPayload payload = new JournalCreateRequestPayload();
      payload.setAnaResult("0");
      payload.setBaseDate(sdf.format(patRadMain.getRegRadDate()));
      payload.setCoopCd("rad_ord");
      payload.setCoopCdIndex("");
      payload.setCoopResult("0");
      payload.setCrud("U");
      payload.setDirection("S");
      payload.setFacilityCd(patRadMain.getFacilityCd());
      if("0".equals(patRadMain.getIsDel())){
        payload.setCrud("D");
        payload.setOpeCd("900021");
      }else if("1".equals(patRadMain.getIsDel())){
        payload.setOpeCd("900020");
      }
      payload.setOrdNo(patRadMain.getRadResultCd());
      payload.setPatId(patRadMain.getPatId());
      payload.setUserId(user.getUserId());
      payload.setHospPatId(hospPatId);
      journalList.add(payload);
    }
    journalService.callCreateJournalForCtrNo(journalList);
  }
  //add 10553 連携イベント発生部分不正【最優先】zhao end

  //add 10618検査セットマスタ、検査項目マスタ、一般撮影検査依頼マスタ編集時に関連データを補正する zhao start
  private Timestamp getDate(String facilityCd , String radOrExam){
    List<String> facilitySettingNos = new ArrayList<>();
    facilitySettingNos.add("1011");
    facilitySettingNos.add("1012");
    facilitySettingNos.add("1015");
    facilitySettingNos.add("1013");
    facilitySettingNos.add("1014");
    facilitySettingNos.add("1016");
    Map<String, String> facilityValue = facilitySettingService.getFacilitySettingValueMap(facilityCd, facilitySettingNos);
    String facilityValue1011 = "";
    String facilityValue1012 = "";
    String facilityValue1015 = "";
    if("exam".equals(radOrExam)){
      facilityValue1011 = facilityValue.get("1011");
      facilityValue1012 = facilityValue.get("1012");
      facilityValue1015 = facilityValue.get("1015");
    }else{
      facilityValue1011 = facilityValue.get("1013");
      facilityValue1012 = facilityValue.get("1014");
      facilityValue1015 = facilityValue.get("1016");
    }
    String hours = String.valueOf(new Date().getHours());
    String minutes = String.valueOf(new Date().getMinutes());
    Integer.parseInt(hours+minutes);
    Integer.parseInt(facilityValue1012.replace(":",""));
    Integer isAddOne = 0;
    if(Integer.parseInt(hours+minutes)>Integer.parseInt(facilityValue1012.replace(":",""))){
      isAddOne = 1;
    }
    LocalDate date = LocalDate.now();
    LocalDate newDate = date.plusDays(Integer.parseInt(facilityValue1011)+isAddOne);
    Timestamp dateOn = Timestamp.valueOf(LocalDateTime.of(newDate, LocalTime.MIDNIGHT));

    Date dateOff = new Date();
    Calendar calendar = new GregorianCalendar();
    calendar.setTime(dateOff);
    calendar.add(Calendar.DATE, -1);
    dateOff = calendar.getTime();
    if("0".equals(facilityValue1015)){
      return new Timestamp(dateOff.getTime());
    }else{
      return dateOn;
    }
  }
  //add 10618検査セットマスタ、検査項目マスタ、一般撮影検査依頼マスタ編集時に関連データを補正する zhao end

  /* add by chamaojia 2023-10-27 [9973] treatCondSettingから治療条件項目を分割する --start */
  /**
   * treatCondSettingから治療条件項目を分割する
   *
   * @param treatCondSetting 治療方法設定
   * @return 治療条件に対応する38項目が使用するMAPであるかどうか
   */
  private Map<String, String> splitTreatCondIsUse(String treatCondSetting) {
    Map<String, String> treatCondIsUseMap = new HashMap<>();
    JSONArray settingJSONArray = treatCondSetting == null ? new JSONArray() : new JSONArray(treatCondSetting);
    for (int i = 0; i < settingJSONArray.length(); i++) {
      JSONArray items = settingJSONArray.getJSONObject(i).getJSONArray("items");
      for (int j = 0; j < items.length(); j++) {
        treatCondIsUseMap.put(items.getJSONObject(j).get("ctl_no").toString(), items.getJSONObject(j).get("is_use").toString());
      }
    }
    return treatCondIsUseMap;
  }
  /* add by chamaojia 2023-10-27 [9973] treatCondSettingから治療条件項目を分割する --end */

  /**
   * データ暗号化
   *
   * @param define マスタ定義
   * @param data   画面で編集したデータ
   */
  private List<Map<String, Object>> cryptoData(SysMasterDefine define, List<Map<String, Object>> data) {
    List<Map<String, Object>> returnData = new ArrayList<>();
    List<String> cryptoColumnList = new ArrayList<>();
    define.getColumnInfo().getFields().forEach(act -> {
      if (act.getType() == (FieldType.CRYPTO)) {
        cryptoColumnList.add(act.getCamelFieldName());
      }
    });
    if (cryptoColumnList.size() == 0) {
      // 暗号化するカラムがない場合はそのまま返す
      return data;
    }
    data.stream().forEach(masterData -> {
      for (Map.Entry<String, Object> record : masterData.entrySet()) {
        for (String key : cryptoColumnList) {
          if (Objects.equals(key, record.getKey()) && record.getValue() != null) {
            // 暗号化対象のカラム
            record.setValue(utilityService.personalInfoEncrypto(record.getValue().toString()));
          }
        }
      }
      returnData.add(masterData);
    });

    return returnData;
  }

  /**
   * データ更新.
   *
   * @param define マスタ定義
   * @param data   画面で編集したデータ
   */
  private void updateData(SysMasterDefine define, List<Map<String, Object>> data, String masterPhysicalName) {
    data.stream().filter(e -> e.get(OPERATION).equals(AdminWebConstant.MasterOperationType.UPDATE)).forEach(e -> {
      // DB更新ログ出力ロジック xie Start
      DataUpdateLogCommonNew logCommon = new DataUpdateLogCommonNew();
      boolean hasData = false;
      try {
        hasData = getUpdateBeforeData(logCommon, define.getMasterPhysicalName(), getSelectSql(e, define));
      } catch (Exception ex) {
        outputErrorLog(ex);
      }
      // DB更新ログ出力ロジック xie end
      if ("mst_holiday".equals(masterPhysicalName) && "0".equals(e.get("isDisp"))) {
        mstHolidayDao.deleteById((Long) e.get("code"));
      } else {
        if ("mst_mainte_category".equals(masterPhysicalName) || "mst_mainte_detail".equals(masterPhysicalName)
          || "mst_mainte_layout".equals(masterPhysicalName) || "mst_mainte_layout_group".equals(masterPhysicalName)) {
          //upd by ztc 2023-02-23 [No.8525 日常・定期点検項目本体にデータを追加した場合、システムエラー発生を修正] --start /
          if (e.get("editionNo") instanceof Integer) {
            e.put("editionNo", (Integer) e.get("editionNo") + 1);
          } else {
            e.put("editionNo", Integer.parseInt((String) e.get("editionNo")) + 1);
          }
          //upd by ztc 2023-02-23 [No.8525 日常・定期点検項目本体にデータを追加した場合、システムエラー発生を修正] --end /
        }
        masterGenericDao.updateMasterData(e, define);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 mod shiyw start
      getAfterUpdatedResults(hasData, logCommon);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 mod shiyw start

      //NO6822 2021-12-10 12:09:30 崔fc Start
      if (masterPhysicalName.equals("mst_machine")) {
        this.updateBedLayout(e);
      } else if (masterPhysicalName.equals("mst_bed")) {
        this.updateBedLayoutByBedInfo(e);
      }
      //NO6822 2021-12-10 12:09:30 崔fc end

      // add by shiyw 2023-03-05: add trigger logic code  --start
      if (masterPhysicalName.equals("mst_machine")) {
        if(!logCommon.getAfterResults().isEmpty() && !logCommon.getBeforeResults().isEmpty()){
          Map<String, Object> beforeUpdateData = logCommon.getBeforeResults().get(0);
          Map<String, Object> afterUpdateData = logCommon.getAfterResults().get(0);
          mstMachineTrigger.triggerUpdate(beforeUpdateData,afterUpdateData);
        }
      }

      if (masterPhysicalName.equals("mst_bed")) {
        if(!logCommon.getAfterResults().isEmpty() && !logCommon.getBeforeResults().isEmpty()){
          Map<String, Object> beforeUpdateData = logCommon.getBeforeResults().get(0);
          Map<String, Object> afterUpdateData = logCommon.getAfterResults().get(0);
          mstBedTrigger.triggerUpdate(beforeUpdateData,afterUpdateData);
        }
      }
      // add by shiyw 2023-03-05: add trigger logic code   --end
      // add by ztc 2023-03-07: add trigger logic code  --start
      if (!logCommon.getAfterResults().isEmpty() && "mst_mainte_category".equals(masterPhysicalName)
        || "mst_mainte_detail".equals(masterPhysicalName) || "mst_mainte_layout".equals(masterPhysicalName)
        || "mst_mainte_layout_group".equals(masterPhysicalName)) {
        Map<String, Object> afterResultsData = logCommon.getAfterResults().get(0);
        mstMainteHisTrigger.triggerExecution( masterPhysicalName, "", afterResultsData);
      }
      // add by ztc 2023-03-07: add trigger logic code  --end
    });
  }

  // DB更新ログ出力ロジック xie Start

  /**
   * updateログを出力する
   *
   * @param hasData   データ有無フラグ
   * @param logCommon ログ出力共通オブジェクト
   */
  private void getAfterUpdatedResults(boolean hasData, DataUpdateLogCommonNew logCommon) {
  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 mod yangxuewang start
    try {
      if (hasData) {
        logCommon.getAfterUpdatedResults();
      }
    } catch (Exception ex) {
      outputErrorLog(ex);
    }
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 mod yangxuewang end
  }

  /**
   * updateログを出力する
   *
   * @param hasData   データ有無フラグ
   * @param logCommon ログ出力共通オブジェクト
   */
  private void outputUpdateLog(boolean hasData, DataUpdateLogCommonNew logCommon) {
    try {
      if (hasData) {
        logCommon.updateLog();
      }
    } catch (Exception ex) {
      outputErrorLog(ex);
    }
  }

  /**
   * エラー場合、ログを出力する
   *
   * @param e エラー情報
   */
  private void outputErrorLog(Exception e) {
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
    logService.log(LogLevel.ERROR, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI,
      null);
  }

  /**
   * エラーメッセージ取得
   *
   * @return
   */
  private String getErrorMessage(Exception e) {
    if (!StringUtils.isEmpty(e.getMessage())) {
      return e.getMessage();
    }
    StringWriter stringWriter = new StringWriter();
    PrintWriter writer = new PrintWriter(stringWriter);
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 del yangxuewang start
//      e.printStackTrace();
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 del yangxuewang end
    StringBuffer buffer = stringWriter.getBuffer();
    return buffer.toString();
  }

  /**
   * 更新前のデータ取得する。
   *
   * @param logCommon ログ出力共通オブジェクト
   * @param tableName テーブル名
   * @param whereSql  where条件
   * @return データ有無フラグ
   */
  private boolean getUpdateBeforeData(DataUpdateLogCommonNew logCommon, String tableName, StringBuffer whereSql) {
    logCommon.setEventLoggerFactory(eventLoggerFactory);
    logCommon.setLogServiceCore(logServiceCore);
    logCommon.setConfig(Config.get(masterGenericDao));
    logCommon.setDaoObject(masterGenericDao);
    logCommon.setTableName(tableName);
    logCommon.setWhereStr(whereSql);
    logCommon.setCommonEventLogMessage(getEventLogMessage());
    boolean setResult = logCommon.setInfo();
    return setResult;
  }
  // DB更新ログ出力ロジック xie end

  /**
   * メッセージ設定
   *
   * @return 設定したメッセージ
   */
  private EventLogMessage getEventLogMessage() {
    EventLogMessage eventLogMessage = new EventLogMessage();
    NtssUser user = (NtssUser) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
    if (user != null) {
      // 利用者ID
      eventLogMessage.setUserId(user.getUserId().toString());
      // 施設コード
      eventLogMessage.setFacilityCd(user.getFacilityCd());
      // 接続先IPアドレス
      eventLogMessage.setClientIp(user.getClientIpAddress());
      // セッションID
      eventLogMessage.setSessionId(user.getSessionId());
    }
    return eventLogMessage;
  }

  /**
   * 検索SQL作成
   *
   * @param masterData 　データ
   * @param define     　マスタ
   * @return 検索SQL
   */
  private StringBuffer getSelectSql(Map<String, Object> masterData, SysMasterDefine define) {
    // aliasにcodeが指定されている物理フィールド名
    String codeName = "";
    // 値
    Object codeValue = null;
    // 更新テーブル名
    String tableName = define.getMasterPhysicalName();
    StringBuffer selectBuilder = new StringBuffer("");
    for (Map.Entry<String, Object> record : masterData.entrySet()) {
      // operation と未入力を除外してSQLを作成
      if (masterGenericDao.isEntityColumn(record)) {
        // CODEはWhere句で使用し、それ以外は更新対象として作成
        if (record.getKey().equals(ALIAS_CODE)) {
          codeName = masterGenericDao.getFieldName(record.getKey(), define);
          codeValue = Long.parseLong(record.getValue().toString());
        }
      }
    }

    selectBuilder.append(" where ");
    selectBuilder.append(codeName);
    selectBuilder.append(" = ");
    if (tableName.equals("sys_medicine")) {
      selectBuilder.append("'" + codeValue.toString() + "'");
    } else {
      selectBuilder.append((Long) codeValue);
    }

    return selectBuilder;
  }
  // DB更新ログ出力ロジック xie end

  // add FNSI-改修内容 薬剤マスタ、医療材料マスタの更新にて、ord_mainのjson内容も合わせて更新する。 周 start

  /**
   * データ更新.
   *
   * @param define     マスタ定義
   * @param facilityCd 施設コード
   * @param data       画面で編集したデータ
   */
  private void updateOrdMain(SysMasterDefine define, String facilityCd, List<Map<String, Object>> data) {
    // 画面で編集したデータ「変更」
    data.stream().filter(e -> e.get(OPERATION).equals(AdminWebConstant.MasterOperationType.UPDATE)).forEach(e -> {
      // 更新データリストを取得
      List<OrdMain> ordMainList = masterGenericDao.getMasterDataByInfo(define, facilityCd, e);
      // 更新データを取得「OrdMain」
      ordMainList.forEach(ordMain -> {
        // DB更新ログ出力ロジック xie Start
        DataUpdateLogCommonNew logCommon = new DataUpdateLogCommonNew();
        boolean hasData = false;
        String tableName = "ord_main";
        // DB更新ログ出力ロジック xie end

        // 更新json対象を取得「RstMediInfo」
        if (define.getMasterPhysicalName().equals("mst_medicine")) {
          // 実績：投与薬剤情報
          String mediInfo = ordMain.getRstMediInfo();
          // 設定：投与薬剤情報
          String mediInfoUpdated = updateRstMediMasterInfo(mediInfo, getCodeByAlias(e, ALIAS_CODE).toString(), e);

          // DB更新ログ出力ロジック xie Start
          try {
            hasData = getUpdateBeforeData(logCommon, tableName, getUpdateOrdMainSelectSql(ordMain.getOrdNo().toString()));
          } catch (Exception ex) {
            outputErrorLog(ex);
          }
          // DB更新ログ出力ロジック xie end

          // ord_mainを更新
          masterGenericDao.updateOrderData(define, ordMain.getOrdNo().toString(), mediInfoUpdated);

          // DB更新ログ出力ロジック xie start
          outputUpdateLog(hasData, logCommon);
          // DB更新ログ出力ロジック xie end
        }
        // 更新json対象を取得「RstEquipInfo」
        else if (define.getMasterPhysicalName().equals("mst_equipment")) {
          // 実績：医療材料情報
          String equipInfo = ordMain.getRstEquipInfo();
          // 設定：医療材料情報
          String equipInfoUpdated = updateRstEquipMasterInfo(equipInfo, getCodeByAlias(e, ALIAS_CODE).toString(), e);

          // DB更新ログ出力ロジック xie Start
          try {
            hasData = getUpdateBeforeData(logCommon, tableName, getUpdateOrdMainSelectSql(ordMain.getOrdNo().toString()));
          } catch (Exception ex) {
            outputErrorLog(ex);
          }
          // DB更新ログ出力ロジック xie end

          // ord_mainを更新
          masterGenericDao.updateOrderData(define, ordMain.getOrdNo().toString(), equipInfoUpdated);

          // DB更新ログ出力ロジック xie start
          outputUpdateLog(hasData, logCommon);
          // DB更新ログ出力ロジック xie end
        }
      });
    });
  }

  // DB更新ログ出力ロジック xie Start

  /**
   * Where条件取得する。
   *
   * @param value
   * @return where条件
   */
  private StringBuffer getUpdateOrdMainSelectSql(String value) {
    StringBuffer selectBuilder = new StringBuffer("");
    selectBuilder.append(" where ");
    selectBuilder.append(" ord_no = '" + value + "'");
    return selectBuilder;
  }
  // DB更新ログ出力ロジック xie end

  /**
   * 投与薬剤情報を更新.
   *
   * @param mediInfo     実績：投与薬剤情報
   * @param medicineCode 薬剤コード
   * @param data         画面で編集したデータ
   */
  private String updateRstMediMasterInfo(String mediInfo, String medicineCode, Map<String, Object> data) {
    // 戻り値格納用StringBuilder
    StringBuilder rtnBuilder = new StringBuilder();
    rtnBuilder.append("[");
    /* add by shiyw 2024-03-28 #10196 ord_mainのデータ定義の修正:OrdMain.equipInfo/mediInfo/IndCommentInfoがnullの場合を考える --start */
    if(ObjectUtils.isEmpty(mediInfo)) {
      rtnBuilder.append("]");
      return rtnBuilder.toString();
    }
    /* add by shiyw 2024-03-28 #10196 ord_mainのデータ定義の修正:OrdMain.equipInfo/mediInfo/IndCommentInfoがnullの場合を考える --end */
    // 薬剤名 「medicine_name > name」
    Object medicineName = null;
    // 省略薬剤名 「medicine_short_name > short_name」
    Object medicineShortName = null;
    // 薬剤分類コード 「class_cd > class_cd」
    Object classCd = null;
    // 指示単位 「unit > unit」
    Object unit = null;

    for (Map.Entry<String, Object> item : data.entrySet()) {
      if (item.getKey().equals("name")) {
        medicineName = item.getValue();
      } else if (item.getKey().equals("medicineShortName")) {
        medicineShortName = item.getValue();
      } else if (item.getKey().equals("classCd")) {
        classCd = item.getValue();
      } else if (item.getKey().equals("unit")) {
        unit = item.getValue();
      }
    }

    // JSON処理
    ObjectMapper mapper = new ObjectMapper();
    try {
      JsonNode jsonNode_array = mapper.readTree(mediInfo);
      for (int lop = 0; lop < jsonNode_array.size(); lop++) {
        JsonNode jsonNode = jsonNode_array.get(lop);
        // jsonNodeは読み取り専用のため、ObjectNodeに変換
        ObjectNode objectNode = jsonNode.deepCopy();

        if (objectNode.get("cd").asText().equals(medicineCode)) {
          objectNode.put("name", medicineName == null ? "null" : medicineName.toString());
          objectNode.put("short_name", medicineShortName == null ? "null" : medicineShortName.toString());
          objectNode.put("class_cd", classCd == null ? "null" : classCd.toString());
          objectNode.put("unit", unit == null ? "null" : unit.toString());
        }

        // objectNodeの文字列化
        rtnBuilder.append(mapper.writeValueAsString(objectNode));
        // 最後以外は区切りのカンマを追加
        if (lop != jsonNode_array.size() - 1) {
          rtnBuilder.append(",");
        }
      }
    } catch (IOException e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
    }

    rtnBuilder.append("]");

    return rtnBuilder.toString();
  }

  /**
   * 医療材料情報を更新.
   *
   * @param equipInfo  実績：医療材料情報mediInfo
   * @param equipCode 医療材料コード
   * @param data      画面で編集したデータ
   */
  private String updateRstEquipMasterInfo(String equipInfo, String equipCode, Map<String, Object> data) {
    // 戻り値格納用StringBuilder
    StringBuilder rtnBuilder = new StringBuilder();
    rtnBuilder.append("[");
    // 医療材料名 「equipment_name > name」
    Object equipmentName = null;
    // 省略医療材料名 「equipment_short_name > short_name」
    Object equipmentShortName = null;
    // 医療材料分類コード 「class_cd > class_cd」
    Object classCd = null;
    // 単位 「unit > unit」
    Object unit = null;

    for (Map.Entry<String, Object> item : data.entrySet()) {
      if (item.getKey().equals("name")) {
        equipmentName = item.getValue();
      } else if (item.getKey().equals("equipmentShortName")) {
        equipmentShortName = item.getValue();
      } else if (item.getKey().equals("classCd")) {
        classCd = item.getValue();
      } else if (item.getKey().equals("unit")) {
        unit = item.getValue();
      }
    }

    // JSON処理
    ObjectMapper mapper = new ObjectMapper();
    try {
      JsonNode jsonNode_array = mapper.readTree(equipInfo);
      for (int lop = 0; lop < jsonNode_array.size(); lop++) {
        JsonNode jsonNode = jsonNode_array.get(lop);
        // jsonNodeは読み取り専用のため、ObjectNodeに変換
        ObjectNode objectNode = jsonNode.deepCopy();

        if (objectNode.get("cd").asText().equals(equipCode)) {
          objectNode.put("name", equipmentName == null ? "null" : equipmentName.toString());
          objectNode.put("short_name", equipmentShortName == null ? "null" : equipmentShortName.toString());
          objectNode.put("class_cd", classCd == null ? "null" : classCd.toString());
          objectNode.put("unit", unit == null ? "null" : unit.toString());
        }

        // objectNodeの文字列化
        rtnBuilder.append(mapper.writeValueAsString(objectNode));
        // 最後以外は区切りのカンマを追加
        if (lop != jsonNode_array.size() - 1) {
          rtnBuilder.append(",");
        }
      }
    } catch (IOException e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
    }

    rtnBuilder.append("]");

    return rtnBuilder.toString();
  }

  /**
   * マスタの主キーを取得.
   *
   * @param infoData  json情報(HashMap)
   * @param aliasCode code項目名
   * @return コード
   */
  private Long getCodeByAlias(Map<String, Object> infoData, String aliasCode) {
    // 値
    Long codeValue = null;

    for (Map.Entry<String, Object> record : infoData.entrySet()) {
      // CODEはWhere句で使用し、それ以外は更新対象として作成
      if (record.getKey().equals(aliasCode)) {
        codeValue = Long.parseLong(record.getValue().toString());
        break;
      }
    }

    return codeValue;
  }
  // add FNSI-改修内容 薬剤マスタ、医療材料マスタの更新にて、ord_mainのjson内容も合わせて更新する。 周 end

  /**
   * データ挿入.
   *
   * @param define     マスタ定義
   * @param facilityCd 施設コード
   * @param data       画面で編集したデータ
   */
  private void insertData(SysMasterDefine define, String facilityCd, List<Map<String, Object>> data) {
    // add by ztc 2023-03-07: add trigger logic code  --end
    String masterPhysicalName = define.getMasterPhysicalName();
    // add by ztc 2023-03-07: add trigger logic code  --end
    data.stream().filter(e -> e.get(OPERATION).equals(AdminWebConstant.MasterOperationType.INSERT)).forEach(e -> {
      if ("mst_mainte_category".equals(masterPhysicalName) || "mst_mainte_detail".equals(masterPhysicalName)
        || "mst_mainte_layout".equals(masterPhysicalName) || "mst_mainte_layout_group".equals(masterPhysicalName)) {
        //upd by ztc 2023-02-23 [No.8525 日常・定期点検項目本体にデータを追加した場合、システムエラー発生を修正] --start /
        if (e.get("editionNo") instanceof Integer) {
          e.put("editionNo", (Integer) e.get("editionNo") + 1);
        } else {
          e.put("editionNo", Integer.parseInt((String) e.get("editionNo")) + 1);
        }
        //upd by ztc 2023-02-23 [No.8525 日常・定期点検項目本体にデータを追加した場合、システムエラー発生を修正] --end /
      }
      // add #9337 休日マスタのコンバートで不足項目が存在する  id_delがnullでコンバートされている。  dengshen start
      if ("mst_holiday".equals(masterPhysicalName)) {
        e.put("isDel", "0");
      }
      // add #9337 休日マスタのコンバートで不足項目が存在する  id_delがnullでコンバートされている。  dengshen end
      masterGenericDao.insertMasterData(e, define, facilityCd);
      if (e.containsKey(ALIAS_CODE)) {
        // 採番されたPK項目の値を取得(serial値)
        if (!"sys_medicine".equals(define.getMasterPhysicalName())) {
          Long serialValue = masterGenericDao.selectCurrentSeq(masterGenericDao.getFieldName(ALIAS_CODE, define), define.getMasterPhysicalName());
          // PKを採番済のものに置換
          e.replace(ALIAS_CODE, serialValue);
        }

        // add by shiyw 2023-03-05: add trigger logic code  --start
        // upd by ztc 2023-03-07: add trigger logic code  --start
        if ("mst_machine".equals(masterPhysicalName)) {
          mstMachineTrigger.triggerInsert(e,facilityCd);
        }
        if ("mst_bed".equals(masterPhysicalName)) {
          mstBedTrigger.triggerInsert(e);
        }
        if ("mst_device_edge".equals(masterPhysicalName)) {
          mstDeviceEdgeTrigger.triggerInsert(e);
        }
        // upd by ztc 2023-03-07: add trigger logic code  --end
        // add by shiyw 2023-03-05: add trigger logic code  --end
        // add by ztc 2023-03-07: add trigger logic code  --start
        if ("mst_mainte_category".equals(masterPhysicalName) || "mst_mainte_detail".equals(masterPhysicalName)
          || "mst_mainte_layout".equals(masterPhysicalName) || "mst_mainte_layout_group".equals(masterPhysicalName)) {
          mstMainteHisTrigger.triggerExecution(masterPhysicalName, facilityCd, e);
        }
        // add by ztc 2023-03-07: add trigger logic code  --end
      }
    });
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public void createMstSelector(String facilityCd, String masterPhysicalName, List<Map<String, Object>> data) {

    List<SortData> sortList = new ArrayList<SortData>();

    // データより並び順を取得
    for (Map<String, Object> record : data) {
      // データからcode項目を取得、なければ処理終了
      SortData sortData = new SortData();

      // mod 4485施設マスタ,4490全施設マスタの並び順が変更 宋qy/鞠 start
      if (masterPhysicalName.equals("mst_facility")) {
        sortData.sortRank = 1L;
        sortData.code = 1L;
        sortData.sortInputTime = 0L;
        sortData.name = record.containsKey("facilityCd") && record.get("facilityCd") != null ? record.get("facilityCd").toString() : null;
        sortData.jlac10_cd = record.containsKey("jlac10Cd") && record.get("jlac10Cd") != null ? record.get("jlac10Cd").toString() : null;
        sortList.add(sortData);
      // mod 4485施設マスタ,4490全施設マスタの並び順が変更 宋qy/鞠 end
      } else if (masterPhysicalName.equals("sys_facility")) {
        sortData.sortRank = 1L;
        sortData.code = record.containsKey("medicalInstitutionCd") && record.get("medicalInstitutionCd") != null ? Long.valueOf(record.get("medicalInstitutionCd").toString()) : null;
        sortData.sortInputTime = 0L;
        sortData.name = record.containsKey("facilityName") && record.get("facilityName") != null ? record.get("facilityName").toString() : null;
        sortData.jlac10_cd = record.containsKey("jlac10Cd") && record.get("jlac10Cd") != null ? record.get("jlac10Cd").toString() : null;
        sortList.add(sortData);
      } else {
        if (record.containsKey(ALIAS_CODE)) {
          sortData.code = Long.parseLong(record.get(ALIAS_CODE).toString());
        } else {
          return;
        }

        sortData.sortRank = getNumberValue(record, SORT_RANK);
        sortData.sortInputTime = getNumberValue(record, SORT_INPUT_TIME);
        sortData.name = record.containsKey(ALIAS_NAME) && record.get(ALIAS_NAME) != null ? record.get(ALIAS_NAME).toString() : null;
        sortData.jlac10_cd = record.containsKey("jlac10Cd") && record.get("jlac10Cd") != null ? record.get("jlac10Cd").toString() : null;

        // 削除済みと非表示は除外してデータを作成
        if (!isTargetValue(record, "isDel", FlagType.FLAG_ON) && !isTargetValue(record, "isDisp", FlagType.FLAG_OFF)) {
          sortList.add(sortData);
        }
      }
    }

    // 保存する格納順を作成
    // ソート順が指定されている項目を並び替え
    List<Item> items = new ArrayList<Item>();
    sortList.stream().filter(e -> e.sortRank != null)
      .sorted(Comparator.comparing(SortData::getSortRank).thenComparing(SortData::getSortInputTime))
      .forEach(sortData -> {
        addItemList(items, sortData);
      });

    // ソート順が指定されていない項目は、後ろにコード順で追加

    sortList.stream().filter(e -> e.sortRank == null).sorted(Comparator.comparing(SortData::getCode)).forEach(sortData -> {
      addItemList(items, sortData);
    });

    MstSelector.OrderSettings orderSettings = new MstSelector.OrderSettings();
    orderSettings.setItems(items);

    // マスタセレクタを取得
    MstSelector mstSelector = mstSelectorDao.selectByName(facilityCd, masterPhysicalName);

    //　マスタセレクタを更新 (あれば更新なければ追加)
    if (mstSelector == null) {
      mstSelector = new MstSelector();
      mstSelector.setFacilityCd(facilityCd);
      mstSelector.setMasterPhysicalName(masterPhysicalName);
      mstSelector.setOrderSettings(orderSettings);
      if (masterPhysicalName.equals("mst_exam_item")) {
        mstSelectorDao.insertMstExamItemSelector(mstSelector);
      } else {
        mstSelectorDao.insert(mstSelector);
      }
    } else {
      mstSelector.setOrderSettings(orderSettings);
      // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
      LogEventUtils.setOperatorId(mstSelector,logService);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
      // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
      if (masterPhysicalName.equals("mst_exam_item")) {
        mstSelectorDao.updateMstExamItemSelector(mstSelector);
      } else {
        mstSelectorDao.update(mstSelector);
      }
    }
  }

  /**
   * 緊急発報マスタ作成.
   *
   * @param masterPhysicalName マスタ名
   * @param data               更新データ
   */
  private void createMstMNotice(String masterPhysicalName, List<Map<String, Object>> data) {
    // 警報通知マスタが対象の時は緊急発報マスタを作成
    if (masterPhysicalName.equals("mst_alarm_notification")) {
      // 担当施設コードのリストを作成
      List<String> targetFacilities = data.stream()
        .map(e -> e.get("destinationFacilityCd").toString())
        .distinct()
        .collect(Collectors.toList());

      maintenanceMNoticeService.createMstMNotice(targetFacilities);
    }
  }

  /**
   * レスポンスDataから指定された数値項目を取得.
   *
   * @param record   対象レコード
   * @param itemName 対象項目名
   * @return 取得値
   */
  private Long getNumberValue(Map<String, Object> record, String itemName) {

    Long retValue = 0L;

    // 対象項目が含まれ、値が設定されていれば値を返す
    if (record.containsKey(itemName) && record.get(itemName) != null) {
      retValue = Long.parseLong(record.get(itemName).toString());
    }
    return retValue;
  }

  /**
   * レスポンスDataから指定された値が期待値と同じかをチェックする.
   *
   * @param record      対象レコード
   * @param itemName    対象項目名
   * @param targetValue 期待値
   * @return boolean
   */
  private boolean isTargetValue(Map<String, Object> record, String itemName, String targetValue) {

    // 対象項目が含まれ、値が設定されていれば期待値との比較結果を返す
    if (record.getOrDefault(itemName, null) != null) {
      return record.get(itemName).toString().equals(targetValue);
    }
    return false;
  }

  /**
   * マスタセレクタItem追加.
   *
   * @param items    マスタセレクタItemリスト
   * @param sortData ソート使用項目
   */
  private void addItemList(List<Item> items, SortData sortData) {

    Item item = new Item();
    item.setCode(sortData.code);
    item.setName(sortData.name);
    item.setJlac10Cd(sortData.jlac10_cd);
    items.add(item);

  }

  // mod #12705 病名マスタの更新をすると更新完了アラート後も処理中画面が表示される fang start
  /**
   * 取得データの並び替え.
   *
   * @param data       取得したデータ
   * @param define     マスタ定義
   * @param facilityCd 施設コード
   * @return 並び替え後のデータ
   */
  private List<Map<String, Object>> sortData(List<Map<String, Object>> data,
                                             SysMasterDefine define, String facilityCd) {
    // data部にソート用のカラムを追加
    data.forEach(m -> {
      m.put(SORT_RANK, null);
      m.put(SORT_INPUT_TIME, null);
    });

    // mstSelectorから並び順を取得

    // mod redmine 4485 施設マスタの並び順が変更 宋qy start
    if (define.getMasterPhysicalName().equals("mst_facility") || define.getMasterPhysicalName().equals("sys_facility")) {
      facilityCd = "nkknkk";
    }

    MstSelector mstSelector = mstSelectorDao.selectByName(facilityCd, define.getMasterPhysicalName());

    if (mstSelector != null) {
      // データ順
      int sortIndex = 0;

      // ソート後データ
      List<Map<String, Object>> sortedData = new ArrayList<>(data.size());
      // add redmine 4490 全施設マスタの並び順 鞠 start
      if (define.getMasterPhysicalName().equals("mst_facility")) {
        String sortDataName = define.getMasterPhysicalName().equals("mst_facility")?"facilityCd":"medicalInstitutionCd";

        // ソート用配列
        List<String> sortedCodes = mstSelector.getOrderSettings().getItems()
          .stream().map(e -> e.getName()).collect(Collectors.toList());
        Set<String> sortedCodeSet = new HashSet<>(sortedCodes);
        Map<String, Map<String, Object>> dataByCode = new HashMap<>(data.size());
        data.forEach(e -> {
          Object code = e.get(sortDataName);
          String key = Objects.isNull(code) ? null : String.valueOf(code);
          dataByCode.putIfAbsent(key, e);
        });

        // ソートした配列
        Set<String> deletedCode = new HashSet<>();

        // ソート用配列順にデータを並び替え
        for (String sortedCode : sortedCodes) {
          Map<String, Object> pickupMap = dataByCode.get(sortedCode);

          if (pickupMap != null) {
            boolean isContainsDisp = pickupMap.containsKey(IS_DISP);
            boolean isContainsDel = pickupMap.containsKey(IS_DEL);
            boolean isDisp = StringUtils.isEmpty(pickupMap.get(IS_DISP)) ? true
              : FlagType.FLAG_ON.equals(pickupMap.getOrDefault(IS_DISP, FlagType.FLAG_OFF));
            boolean isDel = StringUtils.isEmpty(pickupMap.get(IS_DEL)) ? false
              : FlagType.FLAG_ON.equals(pickupMap.getOrDefault(IS_DEL, FlagType.FLAG_OFF));

            if ((isContainsDisp && !isDisp) || (isContainsDel && isDel)) {
              deletedCode.add(sortedCode);
            } else {
              // ソート順を設定
              pickupMap.put(SORT_RANK, ++sortIndex);
              // ソート順に付加
              sortedData.add(pickupMap);
            }
          }
        }

        // mstSelectorに登録されていないコード、もしくは登録されていてかつ削除されているコードを追加
        List<Map<String, Object>> pickupMaps = data.stream()
          .filter(e -> {
            Object code = e.get(sortDataName);
            String key = Objects.isNull(code) ? null : String.valueOf(code);
            return !sortedCodeSet.contains(key) || deletedCode.contains(key);
          })
          .collect(Collectors.toList());

        pickupMaps.forEach(e -> {
          e.put(SORT_RANK, 999999);
          sortedData.add(e);
        });

        return sortedData;
        // add redmine 4490 全施設マスタの並び順 鞠 end
      } else {

        // ソート用配列
        List<Long> sortedCodes = mstSelector.getOrderSettings().getItems()
          .stream().map(e -> e.getCode()).collect(Collectors.toList());
        Set<Long> sortedCodeSet = new HashSet<>(sortedCodes);
        boolean isSysFacility = define.getMasterPhysicalName().equals("sys_facility");
        Map<Object, Map<String, Object>> dataByCode = new HashMap<>(data.size());
        if (!isSysFacility) {
          data.forEach(e -> dataByCode.putIfAbsent(e.get(ALIAS_CODE), e));
        } else {
          data.forEach(e -> dataByCode.putIfAbsent(String.valueOf(e.get(ALIAS_CODE)), e));
        }

        // ソートした配列
        Set<Long> deletedCode = new HashSet<>();

        // ソート用配列順にデータを並び替え
        for (Long sortedCode : sortedCodes) {
          Map<String, Object> pickupMap = dataByCode.get(isSysFacility ? String.valueOf(sortedCode) : sortedCode);

          if (pickupMap != null) {
            boolean isContainsDisp = pickupMap.containsKey(IS_DISP);
            boolean isContainsDel = pickupMap.containsKey(IS_DEL);
            boolean isDisp = StringUtils.isEmpty(pickupMap.get(IS_DISP)) ? true
              : FlagType.FLAG_ON.equals(pickupMap.getOrDefault(IS_DISP, FlagType.FLAG_OFF));
            boolean isDel = StringUtils.isEmpty(pickupMap.get(IS_DEL)) ? false
              : FlagType.FLAG_ON.equals(pickupMap.getOrDefault(IS_DEL, FlagType.FLAG_OFF));

            if ((isContainsDisp && !isDisp) || (isContainsDel && isDel)) {
              deletedCode.add(sortedCode);
            } else {
              // ソート順を設定
              pickupMap.put(SORT_RANK, ++sortIndex);
              // ソート順に付加
              sortedData.add(pickupMap);
            }
          }
        }

        List<Map<String, Object>> pickupMaps = new ArrayList<>();
        if (!isSysFacility) {
          // mstSelectorに登録されていないコード、もしくは登録されていてかつ削除されているコードを追加
          pickupMaps = data.stream()
            .filter(e -> !sortedCodeSet.contains(e.get(ALIAS_CODE))
              || deletedCode.contains(e.get(ALIAS_CODE)))
            .collect(Collectors.toList());
        } else {
          pickupMaps = data.stream()
            .filter(e -> {
              Long code = Long.valueOf(String.valueOf(e.get(ALIAS_CODE)));
              return !sortedCodeSet.contains(code) || deletedCode.contains(code);
            })
            .collect(Collectors.toList());
        }

        pickupMaps.forEach(e -> {
          e.put(SORT_RANK, 999999);
          sortedData.add(e);
        });
        return sortedData;
      }
      // mod redmine 4485 施設マスタの並び順が変更 宋qy end
    }
    return data;
  }
  // mod #12705 病名マスタの更新をすると更新完了アラート後も処理中画面が表示される fang end

  private Optional<Combo> def2Combo(Field field
    , Optional<ReferenceComboDef> defOptional, String facilityCd, SysMasterDefine.Validation validation, SysMasterDefine sysMasterDefine) {
    if (!defOptional.isPresent()) {
      return Optional.empty();
    }
    Optional<ReferenceComboDefNode> nodeOptional = defOptional.get().getList()
      .stream()
      .filter(m -> m.getPhysicalName().equals(field.getPhysicalName()))
      .findFirst();
    if (!nodeOptional.isPresent()) {
      return Optional.empty();
    }

    // 参照型コンボのリストを取得
    List<ReferenceCombo> referenceCombos
      = referenceComboService.build(facilityCd, nodeOptional.get().getReferenceComboTargetTable());

    // コンボのvalues型に変換
    List<ComboValue> comboValues = referenceCombos.stream()
      .map(s -> {
        return new ComboValue(s.getReferencedValue(), s.getDisplayValue().toString());
      })
      .collect(Collectors.toList());

    /* add 空欄,save -1 楊 start*/
    String[] masterPhysicalName = {"mst_equipment", "mst_medicine"};
    String[] physicalName = {"class_cd"};
    /* add 空欄,save -1 楊 end*/

    // 必須でない場合は1番目は未選択用の空のデータを設定
    if (validation == null || validation.isRequired() == false) {
      ComboValue comboValue = new ComboValue("", " ");
      /* add 空欄,save -1 楊 start*/
      if (Arrays.asList(masterPhysicalName).contains(sysMasterDefine.getMasterPhysicalName()) &&
        Arrays.asList(physicalName).contains(field.getPhysicalName())) {
        comboValue = new ComboValue("-1", " ");
      }
      /* add 空欄,save -1 楊 end*/
      comboValues.add(0, comboValue);
    }

    // コンボ情報にセット
    return Optional.of(new Combo(field.getPhysicalName(), comboValues));
  }

  @SuppressWarnings("serial")
  private Map<String, Object> sortRankFields() {
    return new HashMap<String, Object>() {
      {
        put("type", FieldType.NUMBER);
        put("validation", new HashMap<String, Integer>() {{
          put("min", 0);
        }});
        put("defaultValue", 0);
      }
    };
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public SysMasterDefine.ColumnInfo getColumnInfo(String masterName) {

    // マスタ定義の取得
    SysMasterDefine sysMasterDefine = sysMasterDefineDao.selectByName(masterName);
    if (sysMasterDefine == null) {
      ColumnInfo columnInfo = new ColumnInfo() {
        {
          setFields(new ArrayList<>());
        }
      };
      sysMasterDefine = new SysMasterDefine() {
        {
          setColumnInfo(columnInfo);
        }
      };
    }

    // 成功レスポンス返却
    return sysMasterDefine.getColumnInfo();
  }

  /**
   * @title NO6822 装置マスタの情報により、同期mst_status_bed_layout表bed_layoutフィールドの更新
   * @param mstStatusMapBedLayoutMap 装置オブジェクト
   * @author 崔fc
   * @Date 2021-12-10 12:09:30
   * */
  private void updateBedLayout(Map<String, Object> mstStatusMapBedLayoutMap){
    String facilityCdStr = null;
    String codeStr = null;

    //登録施設コード
    if(mstStatusMapBedLayoutMap.get("facilityCd")!=null){
      facilityCdStr = mstStatusMapBedLayoutMap.get("facilityCd").toString();
    }
    //装置番号
    if(mstStatusMapBedLayoutMap.get("code")!=null){
      codeStr = mstStatusMapBedLayoutMap.get("code").toString();
    }
    //レイアウトを取得
    List<MstStatusMapBedLayout> MstStatusMapBedLayoutLists = mstStatusMapBedLayoutDao.selectByFacilityCdAndMachineNo(facilityCdStr, codeStr);

    String machineno = codeStr;
    MstStatusMapBedLayoutLists.stream().forEach(mstStatusMapBedLayout -> {
      String nameStr = null;
      String machineSerialStr = null;
      String machineTypeCdStr = null;

      //型式コード
      if(mstStatusMapBedLayoutMap.get("machineTypeCd")!=null){
        machineTypeCdStr  = mstStatusMapBedLayoutMap.get("machineTypeCd").toString();
      }
      //装置名
      if(mstStatusMapBedLayoutMap.get("name")!=null){
        nameStr = mstStatusMapBedLayoutMap.get("name").toString();
      }
      //機種を取得
      String modelStr = null;
      List<MstMachineType> machineTypeLists = mstMachineTypeDao.selectAll();
      if(machineTypeLists.size()>0){
        for(int i=0; i<machineTypeLists.size(); i++){
          MstMachineType mstMachineType = machineTypeLists.get(i);
          if(machineTypeCdStr.equals(mstMachineType.getMachineTypeCd())){
            modelStr = mstMachineType.getModel();
          }
        }
      }
      //製造番号
      if(mstStatusMapBedLayoutMap.get("machineSerial")!=null){
        machineSerialStr = mstStatusMapBedLayoutMap.get("machineSerial").toString();
      }

      //jsonデータを変更する
      String bedLayoutStr = mstStatusMapBedLayout.getBedLayout();
      JSONObject bedLayoutObj = new JSONObject(bedLayoutStr);
      JSONArray objListArray = new JSONArray(bedLayoutObj.get("obj_list").toString());

      for(int i=0; i<objListArray.length(); i++){
        JSONObject objListObj = (JSONObject) objListArray.get(i);

        // del #9880 装置マスタで型式を変更すると治療状況マップで表示されなくなる dengshen start
        // if(!"-1".equals(String.valueOf(objListObj.get("bed_cd")))){
        //   continue;
        // }
        // del #9880 装置マスタで型式を変更すると治療状況マップで表示されなくなる dengshen end

        if (machineno.equals(String.valueOf(objListObj.get("machine_no")))) {
          // mod #8118 2022/12/06 装置マスタから装置を削除すると治療状況ベッドレイアウトマスタが編集不可 dou start
          // objListObj.put("name", nameStr);
          // objListObj.put("model", modelStr);
          // objListObj.put("machine_serial", machineSerialStr);
          // objListObj.put("machine_type_cd", machineTypeCdStr);
          // del #8219 2023/01/06 装置マスタを編集すると治療状況レイアウトから削除される dou start
          // objListArray.remove(i);
          // del #8219 2023/01/06 装置マスタを編集すると治療状況レイアウトから削除される dou end
          // mod #8118 2022/12/06 装置マスタから装置を削除すると治療状況ベッドレイアウトマスタが編集不可 dou end
          // add #8219 2023/01/06 装置マスタを編集すると治療状況レイアウトから削除される dou start
          if ("0".equals(mstStatusMapBedLayoutMap.get("isDisp"))) {
            // mod #9880 装置マスタで型式を変更すると治療状況マップで表示されなくなる dengshen start
            // objListArray.remove(i);
            if("-1".equals(String.valueOf(objListObj.get("bed_cd")))){
              objListArray.remove(i);
            } else {
              //del #11392 【たくしん会】治療状況マップのベッド名称が装置名称になった 20241211 zhaoqi start
//              objListObj.put("name", nameStr);
              //del #11392 【たくしん会】治療状況マップのベッド名称が装置名称になった 20241211 zhaoqi end
              objListObj.put("model", modelStr);
              objListObj.put("machine_serial", machineSerialStr);
              objListObj.put("machine_type_cd", machineTypeCdStr);
            }
            // mod #9880 装置マスタで型式を変更すると治療状況マップで表示されなくなる dengshen end
          } else {
            //del #11392 【たくしん会】治療状況マップのベッド名称が装置名称になった 20241211 zhaoqi start
//            objListObj.put("name", nameStr);
            //del #11392 【たくしん会】治療状況マップのベッド名称が装置名称になった 20241211 zhaoqi end
            objListObj.put("model", modelStr);
            objListObj.put("machine_serial", machineSerialStr);
            objListObj.put("machine_type_cd", machineTypeCdStr);
          }
          // add #8219 2023/01/06 装置マスタを編集すると治療状況レイアウトから削除される dou end
        }
      }

      bedLayoutObj.put("obj_list", objListArray);

      Map<String, String> updataMstSMBLParam = new HashMap<String, String>();
      updataMstSMBLParam.put("bedLayoutBedLayout", bedLayoutObj.toString());
      updataMstSMBLParam.put("bedLayoutLayoutId", String.valueOf(mstStatusMapBedLayout.getLayoutId()));

      int res = mstStatusMapBedLayoutDao.updateByLayoutId(updataMstSMBLParam);
    });

  }

  /**
   * @title NO6606 ベッドマスタの情報により、同期mst_status_bed_layout表bed_layoutフィールドの更新
   * @param mstStatusMapBedLayoutMap 装置オブジェクト
   * @author 崔fc
   * @Date 2022-01-25 14:28:30
   * */
  private void updateBedLayoutByBedInfo(Map<String, Object> mstStatusMapBedLayoutMap){
    String codeStr = null;

    //ベッドコード
    if(mstStatusMapBedLayoutMap.get("code")!=null){
      codeStr = mstStatusMapBedLayoutMap.get("code").toString();
    }
    //レイアウトを取得
    List<MstStatusMapBedLayout> MstStatusMapBedLayoutLists = mstStatusMapBedLayoutDao.selectByBedCd(codeStr);

    for (MstStatusMapBedLayout mstStatusMapBedLayout : MstStatusMapBedLayoutLists) {
      String nameStr = null;
      String machineSerialStr = null;
      String machineTypeCdStr = null;
      String facilityCdStr = null;
      Long machineNoStr = null;
      String modelStr = null;

      //施設コード
      if (mstStatusMapBedLayout.getFacilityCd() != null) {
        facilityCdStr = mstStatusMapBedLayout.getFacilityCd();
      }
      //装置番号
      if (mstStatusMapBedLayoutMap.get("machineNo") != null &&
        mstStatusMapBedLayoutMap.get("machineNo") != "") {
        machineNoStr = Long.parseLong(mstStatusMapBedLayoutMap.get("machineNo").toString());
      }else{
        machineNoStr = -1l;
      }
      //関連する装置情報を取得する
      MachineKeyInfo machineKeyInfo = mstMachineDao.selectKeyWithModelByMachineNo(facilityCdStr, machineNoStr, "1", "0");

      //ベッド名
      if (mstStatusMapBedLayoutMap.get("name") != null) {
        nameStr = mstStatusMapBedLayoutMap.get("name").toString();
      }
      if(machineKeyInfo != null){
        //型式コード
        if (machineKeyInfo.getMachineTypeCd() != null) {
          machineTypeCdStr = machineKeyInfo.getMachineTypeCd();
        }
        //機種を取得
        List<MstMachineType> machineTypeLists = mstMachineTypeDao.selectAll();
        if(machineTypeLists.size()>0){
          for(int i=0; i<machineTypeLists.size(); i++){
            MstMachineType mstMachineType = machineTypeLists.get(i);
            if(machineTypeCdStr.equals(mstMachineType.getMachineTypeCd())){
              modelStr = mstMachineType.getModel();
            }
          }
        }
        //製造番号
        if(machineKeyInfo.getMachineSerial() != null) {
          machineSerialStr = machineKeyInfo.getMachineSerial();
        }
      }

      //jsonデータを変更する
      String bedLayoutStr = mstStatusMapBedLayout.getBedLayout();
      JSONObject bedLayoutObj = new JSONObject(bedLayoutStr);
      JSONArray objListArray = new JSONArray(bedLayoutObj.get("obj_list").toString());

      for(int i=0; i<objListArray.length(); i++){
        JSONObject objListObj = (JSONObject) objListArray.get(i);
        if(codeStr.equals(String.valueOf(objListObj.get("bed_cd")))){
          objListObj.put("machine_no", machineNoStr);
          objListObj.put("name", nameStr);
          if(machineKeyInfo != null){
            objListObj.put("model", modelStr);
            objListObj.put("machine_serial", machineSerialStr);
            objListObj.put("machine_type_cd", machineTypeCdStr);
          }
        }
      }

      bedLayoutObj.put("obj_list", objListArray);

      Map<String, String> updataMstSMBLParam = new HashMap<String, String>();
      updataMstSMBLParam.put("bedLayoutBedLayout", bedLayoutObj.toString());
      updataMstSMBLParam.put("bedLayoutLayoutId", String.valueOf(mstStatusMapBedLayout.getLayoutId()));

      int res = mstStatusMapBedLayoutDao.updateByLayoutId(updataMstSMBLParam);
    }
  }

  // add 7686 修正 chen start
  /**
   * {@inheritDoc}
   */
  @Override
  public List<String> getMstComsvBed(List<String> deviceEdgeNoList, String facilityCd) {
    return mstBedDao.selectMstComsvBed(deviceEdgeNoList, facilityCd);
  }
  // add 7686 修正 chen end
}
