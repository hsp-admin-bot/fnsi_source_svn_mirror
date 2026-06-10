package jp.co.nikkiso.ntss.admin_web.service.treatmentRecord;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;
import com.google.common.base.Strings;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.FlagType;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Treatment;
import jp.co.nikkiso.ntss.admin_web.constant.Week;
import jp.co.nikkiso.ntss.admin_web.response.PastOrderNoResponse;
import jp.co.nikkiso.ntss.admin_web.response.checkList.dto.ReceiveRstEquipInfoDto;
import jp.co.nikkiso.ntss.admin_web.response.checkList.dto.ReceiveRstMediInfoDto;
import jp.co.nikkiso.ntss.admin_web.response.checkList.dto.RstMediInfoDto;
import jp.co.nikkiso.ntss.admin_web.response.treatmentRecord.RecirculationRate;
import jp.co.nikkiso.ntss.admin_web.response.treatmentRecord.TreatmentRecordSummary;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.OrdMainService;
import jp.co.nikkiso.ntss.admin_web.service.SelectHistoryUtils;
import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.master.MasterEditService;
import jp.co.nikkiso.ntss.admin_web.service.master.ReferenceComboService;
import jp.co.nikkiso.ntss.admin_web.service.statusList.TreatmentStatusListService;
import jp.co.nikkiso.ntss.admin_web.service.utils.MasterCacheHandler;
import jp.co.nikkiso.ntss.admin_web.web.rest.util.WebApiCallCommonUtil;
import jp.co.nikkiso.ntss.api.utils.DateTimeFormatUtil;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.FUNCTION_CODE;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.ComsvSetDao;
import jp.co.nikkiso.ntss.core.dao.DBAppWebAPIDao;
import jp.co.nikkiso.ntss.core.dao.MniMonitorDao;
import jp.co.nikkiso.ntss.core.dao.MntMachineStateDao;
import jp.co.nikkiso.ntss.core.dao.MstBedDao;
import jp.co.nikkiso.ntss.core.dao.MstChecklistDao;
import jp.co.nikkiso.ntss.core.dao.MstCoopIniDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilitySettingDao;
import jp.co.nikkiso.ntss.core.dao.MstMachineDao;
import jp.co.nikkiso.ntss.core.dao.MstMedicateTimingDao;
import jp.co.nikkiso.ntss.core.dao.MstMedicineDao;
import jp.co.nikkiso.ntss.core.dao.MstPatViewerLayoutDao;
import jp.co.nikkiso.ntss.core.dao.MstPersonalUserDao;
import jp.co.nikkiso.ntss.core.dao.MstTreatmentDao;
import jp.co.nikkiso.ntss.core.dao.OrdChecklistDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.PatMainDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.dao.TreatmentRecordDao;
import jp.co.nikkiso.ntss.core.entity.MniMonitor;
import jp.co.nikkiso.ntss.core.entity.MntMachineState;
import jp.co.nikkiso.ntss.core.entity.MstBed;
import jp.co.nikkiso.ntss.core.entity.MstCoopIni;
import jp.co.nikkiso.ntss.core.entity.MstMachine;
import jp.co.nikkiso.ntss.core.entity.MstMedicateTiming;
import jp.co.nikkiso.ntss.core.entity.MstMedicine;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.entity.MstTreatment;
import jp.co.nikkiso.ntss.core.entity.OrdChecklist;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordAddition;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordCondition;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordConditionKeyAnalyze;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordConditionSubInfo;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordEquipInfo;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordMediInfo;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordResult;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordVitalMonitor;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordWeight;
import jp.co.nikkiso.ntss.core.entity.custom.ComsvSet;
import jp.co.nikkiso.ntss.core.entity.custom.FacilitySettingInfo;
import jp.co.nikkiso.ntss.core.entity.custom.MstPatViewerLayoutMonitorItem;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainOrdNoAndRstStartDate;
import jp.co.nikkiso.ntss.core.entity.custom.ReferenceCombo;
import jp.co.nikkiso.ntss.core.entity.custom.ReferenceComboTargetTable;
import jp.co.nikkiso.ntss.core.entity.custom.ReportCds;
import jp.co.nikkiso.ntss.core.entity.custom.TreatmentRecordReportInfo;
import jp.co.nikkiso.ntss.core.exception.NotExistException;
import jp.co.nikkiso.ntss.core.logevent.DataUpdateLogCommonNew;
import jp.co.nikkiso.ntss.core.logevent.LogServiceCore;
import jp.co.nikkiso.ntss.core.logevent.OrdMainHisMongo;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.service.ordMaterialSaveService.OrdMaterialSaveService;
import lombok.AllArgsConstructor;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.extern.slf4j.Slf4j;
import org.json.JSONArray;
import org.json.JSONObject;
import org.seasar.doma.jdbc.Config;
import org.seasar.doma.jdbc.SelectOptions;
import org.springframework.aop.framework.AopProxyUtils;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.http.HttpStatus;
import org.springframework.http.RequestEntity;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.ObjectUtils;
import org.springframework.util.StringUtils;
import org.springframework.web.client.RestTemplate;

import java.io.IOException;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.math.BigDecimal;
import java.net.URI;
import java.net.URISyntaxException;
import java.sql.Timestamp;
import java.text.DecimalFormat;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.time.format.ResolverStyle;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.stream.Collectors;

import static jp.co.nikkiso.ntss.admin_web.service.master.ReferenceComboTargetDefinition.BED;
import static jp.co.nikkiso.ntss.admin_web.service.master.ReferenceComboTargetDefinition.KUR;
import static jp.co.nikkiso.ntss.admin_web.service.master.ReferenceComboTargetDefinition.TREATMENT;
import static jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils.toJson;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

/**
 * 治療記録画面のService実装クラス.
 */
@Service
@Slf4j
public class TreatmentRecordServiceImpl implements TreatmentRecordService {
  /**
   * 患者経過総合ビューアレイアウトマスタ
   * {@link MstPatViewerLayoutDao}
   */
  @Autowired
  private MstPatViewerLayoutDao mstPatViewerLayoutDao;
  /**
   * モニタデータ種別（モニタ）.
   */
  private static final Short MONITOR_DATA_TYPE_MONITOR = 1;

  /**
   * モニタデータ種別（再循環率）.
   */
  private static final Short MONITOR_DATA_TYPE_RECIRCULATION_RATE = 3;

  /**
   * モニタデータキー（血流量）.
   */
  private static final String MONITOR_DATA_BLOOD_FLOW = "8";

  /**
   * モニタデータキー（再循環率）.
   */
  private static final String MONITOR_DATA_RECIRCULATION_RATE = "89";

  /**
   * 体重データキー（前体重測定日時）.
   */
  private static final String WEIGHT_BEFORE_DATE = "weight_before_date";

  /**
   * 体重データキー（後体重測定日時）.
   */
  private static final String WEIGHT_AFTER_DATE = "weight_after_date";

  /**
   * 治療日が未指定のときの文字列.
   */
  private static final String TREATMENT_DATE_UNDEFINED = "透析日未定";

  /**
   * マスタ名称およびコードが空の場合の文字列.
   */
  private static final String MASTER_NAME_UNDEFINED = "未登録";

  /**
   * mst_selectorにコードに該当するマスタデータが存在しない場合に、マスタ名のプレフィックス.
   */
  private static final String MASTER_NAME_DELETED = "【削除】";

  /**
   * コード値が未設定の値.
   */
  private static final Integer CD_ZERO = Integer.valueOf(0);

  /**
   * 治療状況：後体重確認済み(過去実績)
   */
  private static final String CONFIRMED_WEIGHT_MEASURING = "6";

  /**
   * 治療方法変更時の処理区分
   */
  private enum ChangeTreatmentProcessType {
    /**
     * 何もしない
     */
    PROCESS_TYPE_NONE,
    /**
     * 補液に透析液を設定
     */
    PROCESS_TYPE_1,
    /**
     * 治療方法マスタの条件設定に応じて対象外の項目をnullにする
     */
    PROCESS_TYPE_2,
    /**
     * 補液関連を全てnullにする
     */
    PROCESS_TYPE_3,
    /**
     * 補液、補液量、補液使用数、補液速度をnullにする
     * (補液温度と補液選択は設定もクリアする。)
     */
    PROCESS_TYPE_4,
    /**
     * 補液、補液量、補液使用数、補液速度をnullにする
     * (補液温度と補液選択は設定されているままとする。)
     */
    PROCESS_TYPE_5
  }

  /**
   * 血流量取得用内部クラス.
   */
  @AllArgsConstructor
  @Getter
  private static class BloodFlow {
    /**
     * 測定日時.
     */
    private Timestamp occurDate;

    /**
     * 血流量.
     */
    private Integer value;
  }

  /**
   * 治療情報のDaoインタフェース.
   */
  @Autowired
  private TreatmentRecordDao recordDao;

  // add 薬剤マスターだけではない、調剤も検索範囲　劉祥霖 start
  @Autowired
  private DBAppWebAPIDao dBAppWebAPIDao;
  // add 薬剤マスターだけではない、調剤も検索範囲　劉祥霖 end

  //add FNSI内容修正 外部Api調用 房 start
  @Autowired
  ComsvSetDao comsvSetDao;
  //add FNSI内容修正 外部Api調用 房 end

  // add FNSI-改修内容追加OrdMain履歴 付 start
  @Autowired
  private SelectHistoryUtils selectHistoryUtils;
  // add FNSI-改修内容追加OrdMain履歴 付 end

  /**
   * 参照型コンボService.
   */
  @Autowired
  private ReferenceComboService referenceComboService;

  /**
   * モニタデータのDaoインタフェース.
   */
  @Autowired
  private MniMonitorDao mniMonitorDao;

  /**
   * 装置マスタのDaoインタフェース
   */
  @Autowired
  private MstMachineDao mstMachineDao;

  /**
   * 装置マスタのDaoインタフェース
   */
  @Autowired
  private MstBedDao mstBedDao;

  /**
   * オーダメインのDaoインタフェース
   */
  @Autowired
  private OrdMainDao ordMainDao;

  /**
   * 利用者マスタ（個人情報DB）のDaoインタフェース
   */
  @Autowired
  private MstPersonalUserDao mstPersonalUserDao;

  /**
   * 装置状態管理のDaoインタフェース
   */
  @Autowired
  private MntMachineStateDao mntMachineStateDao;

  /**
   * 治療方法マスタのDaoインタフェース
   */
  @Autowired
  private MstTreatmentDao mstTreatmentDao;

  /**
  * ロギングのServiceインタフェース.
  */
  @Autowired
  private LogService logService;

  //add FNSI修正401対応 房 start
  @Autowired
  private OrdChecklistDao ordChecklistDao;

  @Autowired
  private MstChecklistDao mstChecklistDao;
  //add FNSI修正401対応 房 end

  // DB更新ログ出力ロジック wangzuo Start
  @Autowired
  private EventLoggerFactory eventLoggerFactory;

  @Autowired
  private LogServiceCore logServiceCore;
  // DB更新ログ出力ロジック wangzuo End

  // add redmain #4822 鄧シン start
  @Autowired
  private MasterEditService masterEditService;
  // add redmain #4822 鄧シン end

  /**
   * add FNSI No.396 治療記録 -- Sanjingye Sun 20210126
   */
  @Autowired
  private TreatmentStatusListService treatmentStatusListService;

  //add FNSI-投薬最新識別番号の設定 房 start
  @Autowired
  private OrdMainService ordMainService;

  @Autowired
  private MstMedicineDao mstMedicineDao;

  @Autowired
  private MstFacilitySettingDao mstFacilitySettingDao;
  //add FNSI-投薬最新識別番号の設定 房 end

  //add FNSI-redmine5640 fang start
  @Autowired
  private MstMedicateTimingDao mstMedicateTimingDao;

  @Autowired
  private WebApiCallCommonUtil webApiCallCommonUtil;

  @Autowired
  private PatPersonalMainDao patPersonalMainDao;
  //add FNSI-redmine5640 fang end
  //add FNSI-7528 劉全航 start
  @Autowired
  private MstCoopIniDao mstCoopIniDao;
  //add FNSI-7528 劉全航 end

  /* add by songqingyang  2023-02-01 [CodeOptimization]  start */
  @Value("${ntss.admin-web.device-edge.url}")
  private String deviceEdgeUrl;

  @Autowired
  private PatMainDao patMainDao;
  /* add by songqingyang  2023-02-01 [CodeOptimization]  end */
  // add #9845 愁訴処置に入力した薬剤がord_material_saveに登録されない start
  @Autowired
  private OrdMaterialSaveService ordMaterialSaveService;
  // add #9845 愁訴処置に入力した薬剤がord_material_saveに登録されない end
  /**
   * {@inheritDoc}
   */
  @Override
  public TreatmentRecordSummary getTreatmentRecordSummary(Long ordNo) throws NotExistException {
    OrdMain ordMain = getOrdMain(ordNo);

    String displayDate = formatTreatmentDate(ordMain.getTreatDate());
    if (!StringUtils.isEmpty(ordMain.getTreatDate())) {
      // 治療日が設定されている場合、治療曜日を設定する
      displayDate = displayDate + formatTreatmentWeek(ordMain.getTreatWeek());
    }

    String bedName = null;
    String kurName = null;
    String treatmentName = null;

    if (CONFIRMED_WEIGHT_MEASURING.equals(ordMain.getRstDialysisState())) {
      // 過去実績の場合
      //add FNSI-6777 ljx start
      //治療画面のベット名称は実績のベット名称より取得。
      //bedName = formatPastResultMasterName(ordMain.getRstBedCd(), ordMain.getRstBedName());
      bedName = ordMain.getRstBedName();
      //add FNSI-6777 ljx end
      kurName = formatPastResultMasterName(ordMain.getRstKurCd(), ordMain.getRstKurName());
      treatmentName = formatPastResultMasterName(ordMain.getRstTreatmentCd(), ordMain.getRstTreatmentName());
      // add redmain #4822 鄧シン start
      // del redmine-6351　「治療実績の治療方法が未登録の場合のパンくずリスト下の表示HDと表示され不一致となる」 房 start
//      if (ordMain.getRstTreatmentCd() == null || "".equals(treatmentName) || MASTER_NAME_UNDEFINED.equals(treatmentName)){
//        // レスポンス生成
//        MasterDataResponse masterDataResponse = masterEditService.getMasterData("mst_treatment", ordMain.getFacilityCd());
//        for (int i = 0; i < masterDataResponse.localDataSource.data.size(); i++){
//          Integer isDisp = new Integer(masterDataResponse.localDataSource.data.get(i).get("isDisp").toString());
//          Integer isDel = new Integer(masterDataResponse.localDataSource.data.get(i).get("isDel").toString());
//          if (isDisp == 1 && isDel == 0){
//            treatmentName = formatPastResultMasterName(
//              new Integer(masterDataResponse.localDataSource.data.get(i).get("code").toString()),
//              masterDataResponse.localDataSource.data.get(i).get("name").toString());
//            break;
//          }
//        }
//      }
      // del redmine-6351　「治療実績の治療方法が未登録の場合のパンくずリスト下の表示HDと表示され不一致となる」 房 end
      // add redmain #4822 鄧シン end
    } else {
      String facilityCd = ordMain.getFacilityCd();
      bedName = formatNotPastResultMasterName(facilityCd, BED.getValue(), ordMain.getRstBedCd(), ordMain.getRstBedName());
      //add FNSI-6777 ljx start
      //治療画面のベット名称は実績のベット名称より取得。
      bedName = ordMain.getRstBedName();
      //add FNSI-6777 ljx end
	    //mod 8347【デグレ】????患者治療割り当てができない zhao start
	    //kurName = formatNotPastResultMasterName(facilityCd, KUR.getValue(), ordMain.getRstKurCd(), ordMain.getRstKurName());
      //treatmentName = formatNotPastResultMasterName(facilityCd, TREATMENT.getValue(), ordMain.getRstTreatmentCd(), ordMain.getRstTreatmentName());
      kurName = formatNotPastResultMasterName(facilityCd, KUR.getValue(), ordMain.getRstKurCd() != null ? ordMain.getRstKurCd().longValue() : null, ordMain.getRstKurName());
      //mod 8528 ljx start
      //？？？患者の場合、rstTreatmentCdがnullのため、判断処理を追加する。
      //treatmentName = formatNotPastResultMasterName(facilityCd, TREATMENT.getValue(), ordMain.getRstTreatmentCd().longValue(), ordMain.getRstTreatmentName());
      treatmentName = formatNotPastResultMasterName(facilityCd, TREATMENT.getValue(), ordMain.getRstTreatmentCd() !=null?ordMain.getRstTreatmentCd().longValue():null, ordMain.getRstTreatmentName());
      //mod 8528 ljx end
	    //mod 8347【デグレ】????患者治療割り当てができない zhao end
      // add redmain #4822 鄧シン start
      // del redmine-6351　「治療実績の治療方法が未登録の場合のパンくずリスト下の表示HDと表示され不一致となる」 房 start
//      if (ordMain.getRstTreatmentCd() == null || ordMain.getRstTreatmentCd().toString().equals(treatmentName) ||
//        "".equals(treatmentName) || MASTER_NAME_UNDEFINED.equals(treatmentName)){
//        // レスポンス生成
//        MasterDataResponse masterDataResponse = masterEditService.getMasterData("mst_treatment", ordMain.getFacilityCd());
//        for (int i = 0; i < masterDataResponse.localDataSource.data.size(); i++){
//          Integer isDisp = new Integer(masterDataResponse.localDataSource.data.get(i).get("isDisp").toString());
//          Integer isDel = new Integer(masterDataResponse.localDataSource.data.get(i).get("isDel").toString());
//          if (isDisp == 1 && isDel == 0){
//            treatmentName = formatNotPastResultMasterName(facilityCd,
//              TREATMENT.getValue(),
//              new Integer(masterDataResponse.localDataSource.data.get(i).get("code").toString()),
//              masterDataResponse.localDataSource.data.get(i).get("name").toString());
//            break;
//          }
//        }
//      }
      // del redmine-6351　「治療実績の治療方法が未登録の場合のパンくずリスト下の表示HDと表示され不一致となる」 房 end
      // add redmain #4822 鄧シン end
    }

    return new TreatmentRecordSummary(displayDate, bedName, kurName, treatmentName);
  }

  /**
   * オーダ番号に該当する治療記録レコードを取得.
   * @param ordNo オーダ番号
   * @return 治療記録レコードのEntity
   */
  private OrdMain getOrdMain(Long ordNo) {
    try {
      return recordDao.selectByOrdNoForSummary(ordNo);
    } catch (EmptyResultDataAccessException e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("There is no TreatmentRecord.");
      eventLogMessage.setSqlIdentification("(ordNo = "+ ordNo +")");
      logService.log(LogLevel.DEBUG, eventLogMessage,FUNCTION_CODE.FUNC_TREATMENT_RECORD,SERVICE_NAME.REMS, "RecordDao/selectByOrdNoForSummary");
      throw new NotExistException("存在しない治療情報のオーダ番号を指定されています。");
    }
  }

  /**
   * 指定された治療日をフォーマットする.
   *
   * @param treatDate 治療日
   * @return フォーマットされた治療日
   */
  private String formatTreatmentDate(String treatDate) {

    // 空文字もしくはnull値の場合は固定文字を返す.
    if (StringUtils.isEmpty(treatDate)) {
      return TREATMENT_DATE_UNDEFINED;
    }
    try {
      LocalDate d = LocalDate.parse(treatDate, DateTimeFormatter.ofPattern("uuuuMMdd").withResolverStyle(ResolverStyle.STRICT));
      return d.format(DateTimeFormatter.ofPattern("uuuu/MM/dd"));
    } catch (DateTimeParseException e) {
      return treatDate;
    }
  }

  /**
   * 指定された治療曜日をフォーマットする.
   *
   * @param treatWeek 治療曜日
   * @return フォーマットされた治療曜日
   */
  private String formatTreatmentWeek(Short treatWeek) {
    // 値がnullの場合は空文字列を返す
    if (treatWeek == null) {
      return "";
    }

    // 曜日のフォーマット
    final String WEEK_FORMAT = "(%s)";

    Optional<Week> week = Week.valueOf(treatWeek);
    if (week.isPresent()) {
      return String.format(WEEK_FORMAT, week.get().getText());
    }
    return String.format(WEEK_FORMAT, treatWeek);
  }

  /**
   * 過去実績のマスタ名称をフォーマットする.
   *
   * @param cd コード
   * @param name 名称
   * @return フォーマットされた名称
   */
  private String formatPastResultMasterName(Integer cd, String name) {
    // 名称が設定されている場合、そのまま返却する
    if (!StringUtils.isEmpty(name)) {
      return name;
    }

    // コードが未設定(null or 0)の場合は「未登録」を返す
    if (ObjectUtils.isEmpty(cd) || CD_ZERO.equals(cd)) {
      return MASTER_NAME_UNDEFINED;
    }

    // 上記に該当しない場合は空文字列を返す
    return "";
  }

  /**
   * 過去実績以外のマスタ名称をフォーマットする.
   *
   * @param facilityCd 施設コード
   * @param referenceComboTargetTable マスタを定義するクラス
   * @param cd コード
   * @param name 名称
   * @return フォーマットされた名称
   */
  private String formatNotPastResultMasterName(String facilityCd, ReferenceComboTargetTable referenceComboTargetTable, Long cd, String name) {
    // コードが未設定の場合、「未登録」を返す.
    if (ObjectUtils.isEmpty(cd) || CD_ZERO.equals(cd)) {
      return MASTER_NAME_UNDEFINED;
    }

    List<ReferenceCombo> records = referenceComboService.build(facilityCd, referenceComboTargetTable);
    Optional<ReferenceCombo> record = records.stream().filter(referenceCombo -> referenceCombo.getIdentifierValue().equals(cd.longValue())).findFirst();
    if (record.isPresent()) {
      // mst_selectorにcdに該当するマスタデータが存在する場合、表示名を返す.
      // ただし、表示名が null である場合は、空文字を返す.
      return (String) Optional.ofNullable(record.get().getDisplayValue()).orElse("");
    }

    if (!StringUtils.isEmpty(name)) {
      // mst_selectorにcdに該当するマスタデータが存在しない場合、かつ、name が設定されている場合
      return MASTER_NAME_DELETED + name;
    }

    // 上記以外の場合
    return cd.toString();
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public TreatmentRecordResult getTreatmentRecordResult(Long ordNo) throws NotExistException {
    try {
      TreatmentRecordResult treatmentRecordResult = recordDao.selectTreatmentRecordResultByOrdNo(ordNo);
     //add FNSI-6777 ljx start
      if(treatmentRecordResult !=null){
        //実績のベッド名称がマスタと不一致の場合、しばらく該当ベッドのコードをある方で変更する。
        //目的は治療画面に、同じベットを選択し、コードが一致ですが、名称が不一致でも、保存ボタンがクリックできる。
        Long rstBedCd = treatmentRecordResult.getRstBedCd();
        MstBed mstBed = mstBedDao.selectByBedCd(rstBedCd,"1","0");
        //add 6004 バイタル、モニタ画面のグラフの緑線不正、グラフ生成不正 赵 start
        MstTreatment mstTreatment = mstTreatmentDao.selectByCd(treatmentRecordResult.getRstTreatmentCd());
        if(mstTreatment!=null){
          treatmentRecordResult.setGraphTimeScale(mstTreatment.getGraphTimeScale());
        }
        //add 6004 バイタル、モニタ画面のグラフの緑線不正、グラフ生成不正 赵 end
        //del FNSI-8347 ljx start
         //マスタのベット名が変更された場合、新名を使う(元の「0で補足する方法」を破棄)
        /*if(mstBed !=null){
          if(!treatmentRecordResult.getRstBedName().equals(mstBed.getBedName())){
            //ベッドのコードの特別処理
            String convertBedCd = rstBedCd.toString()+"000000000";
            rstBedCd = Long.valueOf(convertBedCd);
            treatmentRecordResult.setRstBedCd(rstBedCd);
          }
        }*/
        //del FNSI-8347 ljx end
      }
      //add FNSI-6777 ljx end
      return treatmentRecordResult;
    } catch (EmptyResultDataAccessException e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("There is no TreatmentRecordResult.");
      eventLogMessage.setSqlIdentification("(ordNo = "+ ordNo +")");
      logService.log(LogLevel.DEBUG, eventLogMessage,FUNCTION_CODE.FUNC_TREATMENT_RECORD,SERVICE_NAME.REMS, "RecordDao/selectTreatmentRecordResultByOrdNo");
      throw new NotExistException("存在しない治療情報のオーダ番号を指定されています。");
    }
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public String getmonistatus(String facilityCd, Long deviceEdgeNo) throws NotExistException {
    try {
      return recordDao.selectMonistatus(facilityCd,deviceEdgeNo);
    } catch (EmptyResultDataAccessException e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("There is no String.");
      logService.log(LogLevel.DEBUG, eventLogMessage,FUNCTION_CODE.FUNC_TREATMENT_RECORD,SERVICE_NAME.REMS, "RecordDao/selectMonistatus");
      throw new NotExistException("存在しない治療情報のオーダ番号を指定されています。");
    }
  }


  /**
   * {@inheritDoc}
   */

    @Override
      public void updateTreatmentRecordResult(Long ordNo, TreatmentRecordResult treatmentRecordResult) throws NotExistException {

    // add FNSI-改修内容追加OrdMain履歴 付 start
    selectHistoryUtils.insertMangoDbHistory(10, ordNo, null, new ArrayList<>(), new ArrayList<>(), null, null,
      null, null, null, new ArrayList<>(), new ArrayList<>(), null, null, null,
      new ArrayList<>(), null, null);
    // mangoDb-updateTreatmentRecordForResult-insertSuccess
    // add FNSI-改修内容追加OrdMain履歴 付 end
    // add FNSI redmine 6122 劉祥霖 治療記録の更新を行ったスタッフではない人で変更履歴が表示される再修正 start
    TreatmentRecordResult oldTreatmentRecordResult=recordDao.selectTreatmentRecordResultByOrdNo(ordNo);
    /* modify by chamaojia 2025-02-25 [11471] 【rst_device_mode】 value change supplement --start */
    Integer rstDeviceMode = null;
    if(oldTreatmentRecordResult!=null){
      if(oldTreatmentRecordResult.getRstStartDate()!=null&&oldTreatmentRecordResult.getRstEndDate()!=null){
        Timestamp oldRstStartDate=new Timestamp(oldTreatmentRecordResult.getRstStartDate().getTime());
        Timestamp oldRstEndDate=new Timestamp(oldTreatmentRecordResult.getRstEndDate().getTime());
        oldRstStartDate.setSeconds(0);
        oldRstEndDate.setSeconds(0);
        Timestamp newRstStartDate=treatmentRecordResult.getRstStartDate();
        Timestamp newRstEndDate=treatmentRecordResult.getRstEndDate();
        if(oldRstStartDate!=null&&newRstStartDate!=null&&oldRstStartDate.getTime()==newRstStartDate.getTime()){
          treatmentRecordResult.setRstStartDate(oldTreatmentRecordResult.getRstStartDate());
        }
        if(oldRstEndDate!=null&&newRstEndDate!=null&&oldRstEndDate.getTime()==newRstEndDate.getTime()){
          treatmentRecordResult.setRstEndDate(oldTreatmentRecordResult.getRstEndDate());
        }
      }

      if (!Objects.equals(oldTreatmentRecordResult.getRstTreatmentCd(),treatmentRecordResult.getRstTreatmentCd())) {
        MstTreatment mstTreatment = mstTreatmentDao.selectByCd(treatmentRecordResult.getRstTreatmentCd());
        if (mstTreatment != null) {
          rstDeviceMode = mstTreatment.getDeviceMode();
        }
      }
    }
    treatmentRecordResult.setRstDeviceMode(rstDeviceMode);
    /* modify by chamaojia 2025-02-25 [11471] 【rst_device_mode】 value change supplement --end */
    //add FNSI redmine 6122 劉祥霖 治療記録の更新を行ったスタッフではない人で変更履歴が表示される再修正 end
    treatmentRecordResult.setOrdNo(ordNo);
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
      LogEventUtils.setOperatorId(treatmentRecordResult,logService);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
    // add 8277 周安寧 start
    NtssUser user = (NtssUser) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
    treatmentRecordResult.setLogUserId(user.getUserId().toString());
    // add 8277 周安寧 end
    final int updatedResultCount = recordDao.updateTreatmentRecordForResult(ordNo, treatmentRecordResult);
    if(updatedResultCount <= 0) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("There is no TreatmentRecordResult.");
      eventLogMessage.setSqlIdentification("(ordNo = "+ ordNo +", treatmentRecordResult = "+ treatmentRecordResult +")");
      logService.log(LogLevel.DEBUG, eventLogMessage,FUNCTION_CODE.FUNC_TREATMENT_RECORD,SERVICE_NAME.REMS, "RecordDao/updateTreatmentRecordForResult");
      throw new NotExistException("存在しない治療情報のオーダ番号を指定されています。");
    }
      //del 9480 治療記録（実績情報）の更新削除 guan start
      //add FNSI-redmine6060 fang start
      //webApiCallCommonUtil.doAutoCalculation(ordNo);
      // add FNSI-redmine6060 fang end
      // del 9480 治療記録（実績情報）の更新削除 guan end
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public void updateTreatmentRecordResultWithCondition(Long ordNo, TreatmentRecordResult treatmentRecordResult, int processType, Long userId) throws NotExistException {
    // 実績情報の保存
    updateTreatmentRecordResult(ordNo, treatmentRecordResult);
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("治療記録[実績情報保存]:処理区分を受信:" + processType);
    logService.log(LogLevel.INFO, eventLogMessage,FUNCTION_CODE.FUNC_TREATMENT_RECORD,SERVICE_NAME.REMS, null);
    // 処理区分(processType)==0 の場合、何もしないのでリターン
    if (processType == ChangeTreatmentProcessType.PROCESS_TYPE_NONE.ordinal()) {
      return;
    }
    // 処理区分に応じて治療条件を更新
    // 治療条件を取得
    TreatmentRecordCondition condition = getTreatmentRecordCondition(ordNo);
    // 治療条件がnullの場合は何もしない
    if (condition == null || condition.getRstCondInfo() == null) {
      eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("治療記録[実績情報保存]:治療条件が登録されていません");
      logService.log(LogLevel.INFO, eventLogMessage,FUNCTION_CODE.FUNC_TREATMENT_RECORD,SERVICE_NAME.REMS, null);
      return;
    }

    // 治療条件のJSON文字列をMapに変換
    Map<String, RstCondInfo> rstCondInfoMap = getRstCondInfoMap(condition.getRstCondInfo());
    // 治療条件のJSON文字列の変換結果がnullの場合
    if (rstCondInfoMap == null) {
      return;
    }

    // 処理区分に応じた処理
    // TODO:補液関連をJSONに出力しない場合、rstConfInfoMapから補液関連を削除する
    // TODO:治療条件項目番号の定数化
    if (processType == ChangeTreatmentProcessType.PROCESS_TYPE_1.ordinal()) {
      eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("透析液を補液に設定");
      logService.log(LogLevel.DEBUG, eventLogMessage,FUNCTION_CODE.FUNC_TREATMENT_RECORD,SERVICE_NAME.REMS, null);
      // 補液の情報を取得
      RstCondInfo rstReplenishLiquid = rstCondInfoMap.containsKey("19") ? rstCondInfoMap.get("19") : null;
      // 透析液の情報を取得
      RstCondInfo rstDialyzeLiquid = rstCondInfoMap.containsKey("15") ? rstCondInfoMap.get("15") : null;
      // 透析液の情報が存在しない場合
      if (rstDialyzeLiquid == null) {
        eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("治療記録[実績情報保存]:治療条件に透析液情報が存在しません");
        logService.log(LogLevel.WARN, eventLogMessage,FUNCTION_CODE.FUNC_TREATMENT_RECORD,SERVICE_NAME.REMS, null);
        return;
      }
      // 補液情報がない場合
      if (rstReplenishLiquid == null) {
        rstReplenishLiquid = rstDialyzeLiquid;
      } else {
        // 透析液を補液に設定
        BeanUtils.copyProperties(rstDialyzeLiquid, rstReplenishLiquid);
      }
      rstReplenishLiquid.setUpd_user_id(userId);
      MstPersonalUser user = getMstPersonalUser(userId);
      // 更新者氏名を反映
      rstReplenishLiquid.setUpd_user_last_name(user != null ? user.getUserLastName() : null);
      rstReplenishLiquid.setUpd_user_first_name(user != null ? user.getUserFirstName() : null);
      rstCondInfoMap.put("19", rstReplenishLiquid);
    } else if (processType == ChangeTreatmentProcessType.PROCESS_TYPE_2.ordinal()) {
      eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("治療記録[実績情報保存]:療方法マスタの条件設定に応じて対象外のものをnulｌにする");
      logService.log(LogLevel.DEBUG, eventLogMessage,FUNCTION_CODE.FUNC_TREATMENT_RECORD,SERVICE_NAME.REMS, null);
      // 変更後の治療方法コード
      Integer treatmentCd = treatmentRecordResult.getRstTreatmentCd();
      // 治療方法コードが未設定の場合、何もしない
      if (treatmentCd == null) {
        eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("治療記録[実績情報保存]:治療方法コードが未設定の為、治療方法コード変更に伴う治療条件の変更は行いません。");
        logService.log(LogLevel.INFO, eventLogMessage,FUNCTION_CODE.FUNC_TREATMENT_RECORD,SERVICE_NAME.REMS, null);
        return;
      }
      // 治療方法コードに該当する治療方法マスタ取得
      MstTreatment mstTreatment = mstTreatmentDao.selectByCd(treatmentCd);
      // 治療方法コードに該当する治療方法マスタが取得できない場合、何もしない
      if (mstTreatment == null) {
        eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("治療記録[実績情報保存]:治療方法コードに該当する治療方法マスタが見つからない為、治療方法コード変更に伴う治療条件の変更は行いません。治療方法コード:" + treatmentCd);
        logService.log(LogLevel.INFO, eventLogMessage,FUNCTION_CODE.FUNC_TREATMENT_RECORD,SERVICE_NAME.REMS, null);
        return;
      }
      // 治療方法マスタから治療条件のJSON文字列を取得
      String strCondInfo = mstTreatment.getTreatmentConditionSetting();
      // 未設定
      if (strCondInfo == null) {
        eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("治療記録[実績情報保存]:治療方法マスタの治療条件設定が未設定の為、治療方法コード変更に伴う治療条件の変更は行いません。");
        logService.log(LogLevel.INFO, eventLogMessage,FUNCTION_CODE.FUNC_TREATMENT_RECORD,SERVICE_NAME.REMS, null);
        return;
      }
      // 治療方法マスタに登録されている治療項目設定で使用する項目のみを取得する.
      Map<String, String> useCondInfo = getMstTreatmentCondInfo(strCondInfo);
      // 実績の治療条件のマップから使用しない治療方法（useCondInfo に存在しない）情報を削除
      Map<String, RstCondInfo> newRstCondInfoMap = new HashMap<String, RstCondInfo>();
      // いったん退避
      Map<String, RstCondInfo> finalRstCondInfoMap = rstCondInfoMap;
      rstCondInfoMap.keySet().forEach(key -> {
        // 治療項目管理番号が1の場合は、治療方法マスタの治療条件設定有無に関わらず設定
        if (key.equals("1") && finalRstCondInfoMap.containsKey(key)) {
          newRstCondInfoMap.put(key, finalRstCondInfoMap.get(key));
          return;
        }
        // 治療方法マスタの治療条件に存在していない場合
        if (!useCondInfo.containsKey(key)) {
          return;
        }
        // 治療方法マスタの治療条件で「使用する」となっている場合
        if (useCondInfo.get(key).equals("1") && finalRstCondInfoMap.containsKey(key)) {
          newRstCondInfoMap.put(key, finalRstCondInfoMap.get(key));
        }
      });
      // 新しい治療条件マップを設定
      rstCondInfoMap = newRstCondInfoMap;
    } else if (processType == ChangeTreatmentProcessType.PROCESS_TYPE_3.ordinal() ||
               processType == ChangeTreatmentProcessType.PROCESS_TYPE_4.ordinal()) {
      eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("治療記録[実績情報保存]:補液、補液量、補液使用数、補液速度をnullにする");
      logService.log(LogLevel.DEBUG, eventLogMessage,FUNCTION_CODE.FUNC_TREATMENT_RECORD,SERVICE_NAME.REMS, null);
      // 対象の治療条件項目番号の配列
      String[] targetCondInfoKey = {"19", "20", "21", "22", "23", "24"};
      // クリア処理
      rstCondInfoMap = clearRstCondInfoByKey(rstCondInfoMap, targetCondInfoKey, userId);
    } else if (processType == ChangeTreatmentProcessType.PROCESS_TYPE_5.ordinal()) {
      eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("治療記録[実績情報保存]:補液、補液量、補液使用数、補液速度をnullにする.補液温度と補液選択は設定されているままとする.");
      logService.log(LogLevel.DEBUG, eventLogMessage,FUNCTION_CODE.FUNC_TREATMENT_RECORD,SERVICE_NAME.REMS, null);
      // 対象：補液(19),補液量(20),補液使用数(22),補液速度(24)
      // 対象外：補液温度(23),補液選択(21)
      String[] targetCondInfoKey = {"19", "20", "22", "24"};
      // クリア処理
      rstCondInfoMap = clearRstCondInfoByKey(rstCondInfoMap, targetCondInfoKey, userId);
    } else {
      eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("治療記録[実績情報保存]:想定外の処理区分：" + processType);
      logService.log(LogLevel.DEBUG, eventLogMessage,FUNCTION_CODE.FUNC_TREATMENT_RECORD,SERVICE_NAME.REMS, null);
      return;
    }

    try {
      ObjectMapper mapper = new ObjectMapper();
      // Map -> JSON文字列
      String rstCondInfoJson = mapper.writeValueAsString(rstCondInfoMap);
      // 治療条件に設定
      condition.setRstCondInfo(rstCondInfoJson);
      // 治療条件の保存
      updateTreatmentRecordCondition(ordNo, condition);
      // ログ
      eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("治療記録[実績情報保存]:治療方法の変更に伴い、治療条件の保存完了");
      logService.log(LogLevel.INFO, eventLogMessage,FUNCTION_CODE.FUNC_TREATMENT_RECORD,SERVICE_NAME.REMS, null);
    } catch (IOException e) {
      eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("治療記録[実績情報保存]:治療条件の更新に失敗しました。" + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage,FUNCTION_CODE.FUNC_TREATMENT_RECORD,SERVICE_NAME.REMS, null);
      return;
    }
    //del 9480 治療記録（実績情報）の更新削除 gjn start
    //add FNSI-redmine6060 fang start
    //webApiCallCommonUtil.doAutoCalculation(ordNo);
    // add FNSI-redmine6060 fang end
    //del 9480 治療記録（実績情報）の更新削除 gjn end
  }

  /**
   * 指定した治療条件項目番号（配列）の情報をクリアする.
   * クリアは{@link RstCondInfo#clear()}にて行う.
   *
   * @param rstCondInfoMap 治療条件の{@link Map}
   * @param targetCondInfoKey クリア対象の治療条件項目の配列
   * @param userId 更新者情報に登録する利用者ID
   * @return クリア後の治療条件の{@link Map}
   */
  private Map<String, RstCondInfo> clearRstCondInfoByKey(Map<String, RstCondInfo> rstCondInfoMap, String[] targetCondInfoKey, Long userId) {
    // 利用者マスタ取得
    MstPersonalUser user = getMstPersonalUser(userId);
    Arrays.stream(targetCondInfoKey).forEach((key) -> {
      if (!rstCondInfoMap.containsKey(key)) {
        return;
      }
      RstCondInfo targetRstCondInfo = rstCondInfoMap.get(key);
      // クリア
      targetRstCondInfo.clear();
      // 更新者ID及び名前を反映
      targetRstCondInfo.setUpd_user_id(userId);
      targetRstCondInfo.setUpd_user_last_name(user != null ? user.getUserLastName() : null);
      targetRstCondInfo.setUpd_user_first_name(user != null ? user.getUserFirstName() : null);
      rstCondInfoMap.put(key, targetRstCondInfo);
    });
    return rstCondInfoMap;
  }

  /**
   * userIdに該当する利用者マスタを取得
   * 該当する情報がない場合にはnullを返す.
   * @param userId 利用者ID
   * @return 利用者IDに該当する利用者マスタ
   */
  private MstPersonalUser getMstPersonalUser(Long userId) {
    return mstPersonalUserDao.selectById(userId);
  }

  /**
   * 治療条件のJSON文字列を{@link Map}に変換
   * 内部で例外が発生した場合は{@code null}を返す.
   * 　key：治療条件項目番号
   * 　value：{@link RstCondInfo}
   *
   * @param rstCondInfo 治療条件のJSON文字列
   * @return 治療条件のJSON文字列を治療条件項目番号毎に格納されたMap
   */
  private Map<String, RstCondInfo> getRstCondInfoMap(String rstCondInfo) {
    try {
      ObjectMapper mapper = new ObjectMapper();
      JSONObject obj = new JSONObject(rstCondInfo);
      Map<String, RstCondInfo> map = new HashMap<>();
      for(Object key : obj.keySet()) {
        Object val =  obj.get((String) key);
        RstCondInfo info =  mapper.readValue(val.toString(), RstCondInfo.class);
        map.put((String) key, info);
      }
      return map;
    } catch (IOException e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("治療条件のJSON文字列->Mapへの変換に失敗" + e);
      logService.log(LogLevel.ERROR, eventLogMessage,FUNCTION_CODE.FUNC_TREATMENT_RECORD,SERVICE_NAME.REMS, null);
      return null;
    }
  }

  /**
   * 治療条件（JSON)のエンティティ
   */
  @Getter
  @Setter
  @NoArgsConstructor
  @EqualsAndHashCode(callSuper = false)
  public static class RstCondInfo {
    /**
     * 単位
     */
    private String unit;
    /**
     * 設定値
     */
    private Integer value;
    /**
     * 翻訳1
     */
    private String value_name_1;
    /**
     * 翻訳2
     */
    private String value_name_2;
    /**
     * 翻訳3
     */
    private String value_name_3;
    /**
     * 翻訳4
     */
    private String value_name_4;
    /**
     * 翻訳5
     */
    private String value_name_5;
    /**
     * 翻訳6
     */
    private String value_name_6;
    /**
     * 翻訳7
     */
    private String value_name_7;
    /**
     * 翻訳8
     */
    private String value_name_8;
    /**
     * 翻訳9
     */
    private String value_name_9;
    /**
     * 翻訳10
     */
    private String value_name_10;
    /**
     * 登録区分
     */
    private String input_class;
    /**
     * 編集可否フラグ
     */
    private String is_editable;
    /**
     * 連携可否フラグ
     */
    private Long cop_order_no;
    /**
     * 薬剤区分
     */
    private Integer medicine_type;
    /**
     * 指示者コード
     */
    private Long ind_user_id;
    /**
     * 指示者名_姓
     */
    private String ind_user_last_name;
    /**
     * 指示者名_名
     */
    private String ind_user_first_name;
    /**
     * 更新者コード
     */
    private Long upd_user_id;
    /**
     * 更新者名_姓
     */
    private String upd_user_last_name;
    /**
     * 更新者名_名
     */
    private String upd_user_first_name;

    /**
     * 登録内容をクリアする.
     */
    public void clear() {
      // 単位
      unit = null;
      // 設定値
      value = null;
      // 翻訳1
      value_name_1 = null;
      // 薬剤登録区分
      medicine_type = null;
      // 登録区分
      input_class = null;
    }
  }

  /**
   * 治療方法マスタの治療条件設定をkey：治療条件項目番号、value:使用有無(文字列)の{@link Map}を取得する.
   * @param condInfo 治療方法マスタの治療条件設定のJSON文字列
   * @return 治療方法マスタに登録された治療条件設定を保持するMap
   */
  private Map<String, String> getMstTreatmentCondInfo(String condInfo) {
    ObjectMapper objectMapper = new ObjectMapper();
    JSONArray jsonArray = new JSONArray(condInfo);
    Map<String, String> map = new HashMap<String, String>();
    jsonArray.forEach(data -> {
      JSONArray itemsJsonArray = (JSONArray) ((JSONObject)data).get("items");
      itemsJsonArray.forEach(item -> {
        try {
          MstTreatmentCondInfo info =objectMapper.readValue(item.toString(), MstTreatmentCondInfo.class);
          map.put(info.ctl_no, info.is_use);
        } catch (IOException e) {
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage("治療方法マスタから治療条件設定の取得に失敗しました。");
          logService.log(LogLevel.ERROR, eventLogMessage,FUNCTION_CODE.FUNC_TREATMENT_RECORD,SERVICE_NAME.REMS, null);
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
        }
      });
    });
    return map;
  }

  /**
   * 治療方法マスタの治療条件使用有無
   * ※実際のJSON文字列はcategory_no毎に管理されているが、治療記録では未使用の為取得しない.
   */
  @Getter
  @Setter
  @NoArgsConstructor
  public static class MstTreatmentCondInfo {
    /**
     * 治療項目管理番号
     */
    private String ctl_no;
    /**
     * 使用有無
     * 0:使用しない
     * 1:使用する
     */
    private String is_use ;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public TreatmentRecordMediInfo getTreatmentRecordMediInfo(Long ordNo) throws NotExistException {
    try {
      return recordDao.selectTreatmentRecordMediInfoByOrdNo(ordNo);
    } catch (EmptyResultDataAccessException e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("There is no TreatmentRecordMediInfo.");
      eventLogMessage.setSqlIdentification("(ordNo = "+ ordNo +")");
      logService.log(LogLevel.DEBUG, eventLogMessage,FUNCTION_CODE.FUNC_TREATMENT_RECORD,SERVICE_NAME.REMS, "RecordDao/selectTreatmentRecordMediInfoByOrdNo");
      throw new NotExistException("存在しない治療情報のオーダ番号を指定されています。");
    }
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public void updateTreatmentRecordMediInfo(Long ordNo, TreatmentRecordMediInfo treatmentRecordMediInfo) throws NotExistException {

    // add FNSI-改修内容追加OrdMain履歴 付 start
    selectHistoryUtils.insertMangoDbHistory(10, ordNo, null, new ArrayList<>(), new ArrayList<>(), null, null,
      null, null, null, new ArrayList<>(), new ArrayList<>(), null, null, null,
      new ArrayList<>(), null, null);
    // mangoDb-updateTreatmentRecordForMediInfo-insertSuccess
    // add FNSI-改修内容追加OrdMain履歴 付 end

    treatmentRecordMediInfo.setOrdNo(ordNo);
    final int updatedMediInfoCount = recordDao.updateTreatmentRecordForMediInfo(ordNo, treatmentRecordMediInfo);
    if (updatedMediInfoCount <= 0) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("There is no TreatmentRecordMediInfo.");
      eventLogMessage.setSqlIdentification("(ordNo = "+ ordNo +", treatmentRecordMediInfo = "+ treatmentRecordMediInfo +")");
      logService.log(LogLevel.DEBUG, eventLogMessage,FUNCTION_CODE.FUNC_TREATMENT_RECORD,SERVICE_NAME.REMS, "RecordDao/updateTreatmentRecordForMediInfo");
      throw new NotExistException("存在しない治療情報のオーダ番号を指定されています。");
    }
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public TreatmentRecordCondition getTreatmentRecordCondition(Long ordNo) throws NotExistException {
    try {
      //mod FNSI修正 OHDF修正 房 start
      TreatmentRecordCondition treatmentRecordCondition = recordDao.selectTreatmentRecordConditionByOrdNo(ordNo);
      /* del by chamaojia 2025-02-28 [11471] no need for translation --start */
//      if (treatmentRecordCondition.getRstTreatmentCd() != null) {
//        MstTreatment mstTreatment = mstTreatmentDao.selectByCd(treatmentRecordCondition.getRstTreatmentCd());
//        if (mstTreatment != null) {
//          treatmentRecordCondition.setDeviceMode(mstTreatment.getDeviceMode());
//        }
//      }
      /* del by chamaojia 2025-02-28 [11471] no need for translation --end */
      return treatmentRecordCondition;
      //mod FNSI修正 OHDF修正 房 end
    } catch (EmptyResultDataAccessException e) {
    	EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("There is no TreatmentRecordCondition.");
      eventLogMessage.setSqlIdentification("(ordNo = "+ ordNo +")");
      logService.log(LogLevel.DEBUG, eventLogMessage,FUNCTION_CODE.FUNC_TREATMENT_RECORD,SERVICE_NAME.REMS, "RecordDao/selectTreatmentRecordConditionByOrdNo");
      throw new NotExistException("存在しない治療情報のオーダ番号を指定されています。");
    }
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public void updateTreatmentRecordCondition(Long ordNo, TreatmentRecordCondition treatmentRecordCondition) throws NotExistException {
    treatmentRecordCondition.setOrdNo(ordNo);

    // add FNSI-改修内容追加OrdMain履歴 付 start
    selectHistoryUtils.insertMangoDbHistory(10, ordNo, null, new ArrayList<>(), new ArrayList<>(), null, null,
      null, null, null, new ArrayList<>(), new ArrayList<>(), null, null, null,
      new ArrayList<>(), null, null);
    // mangoDb-updateTreatmentRecordForCondition-insertSuccess
    // add FNSI-改修内容追加OrdMain履歴 付 end

    /* add by zhaohan 2022-11-08 [6067] ログに利用者が表示されていない。 --start */
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
    LogEventUtils.setOperatorId(treatmentRecordCondition,logService);
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
    /* add by zhaohan 2022-11-08 [6067] ログに利用者が表示されていない。 --end */
    // add 8277 周安寧 start
    NtssUser user = (NtssUser) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
    treatmentRecordCondition.setLogUserId(user.getUserId().toString());
    // add 8277 周安寧 end
    final int updatedConditionCount = recordDao.updateTreatmentRecordForCondition(ordNo, treatmentRecordCondition);
    if(updatedConditionCount <= 0) {
    	EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("There is no TreatmentRecordCondition.");
      eventLogMessage.setSqlIdentification("(ordNo = "+ ordNo +", treatmentRecordCondition = "+ treatmentRecordCondition +")");
      logService.log(LogLevel.DEBUG, eventLogMessage,FUNCTION_CODE.FUNC_TREATMENT_RECORD,SERVICE_NAME.REMS, "RecordDao/updateTreatmentRecordForCondition");
      throw new NotExistException("存在しない治療情報のオーダ番号を指定されています。");
    }
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<RecirculationRate> getRecirculationRate(Long ordNo) {
    List<MniMonitor> recirculationRates = recordDao.selectMniMonitorForRecirculationRate(ordNo, MONITOR_DATA_TYPE_RECIRCULATION_RATE);
    List<BloodFlow> bloodFlows = recordDao.selectMniMonitorForRecirculationRate(ordNo, MONITOR_DATA_TYPE_MONITOR).stream()
        .map(e -> new BloodFlow(e.getOccurDate(), getMonitorDataValue(e.getMonitorData(), MONITOR_DATA_BLOOD_FLOW)))
        .collect(Collectors.toList());

    return recirculationRates.stream()
        .limit(5)
        .map(rate -> {
          // 直近の血流量を求める
          Integer bloodFlow = bloodFlows.stream()
              .filter(e -> e.getOccurDate().compareTo(rate.getOccurDate()) <= 0)
              .reduce((first, second) -> second)
              .map(e -> e.getValue())
              .orElse(null);

          return new RecirculationRate(
              rate.getBioMoniCtlNo(),
              ZonedDateTime.of(rate.getOccurDate().toLocalDateTime(), ZoneId.systemDefault()),
              getMonitorDataValue(rate.getMonitorData(), MONITOR_DATA_RECIRCULATION_RATE),
              bloodFlow);
        })
        .collect(Collectors.toList());
  }

  /**
   * 装置モニタデータJSONから値(Integer型)を取得する.
   * @param json JSON文字列
   * @param key 装置モニタデータのキー
   * @return 装置モニタデータの値
   */
  private Integer getMonitorDataValue(String json, String key) {
    String value = getDataValue(json, key);
    if (value == null) {
      return null;
    }
    return Integer.parseInt(getDataValue(json, key));
  }

  /**
   * JSONから指定したキーに該当する値を取得する.
   * @param json JSON文字列
   * @param key キー
   * @return キーに該当する値
   */
  private String getDataValue(String json, String key) {
    ObjectMapper mapper = new ObjectMapper();
    TypeReference<Map<String, Object>> reference = new TypeReference<Map<String, Object>>() {};
    String value = null;

    try {
      Map<String, Object> values = mapper.readValue(json, reference);
      value = values.get(key).toString();
    } catch (Exception e) {
      // JSONパース失敗時はnullを返す
    }
    return value;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public TreatmentRecordWeight getTreatmentRecordWeight(Long ordNo) throws NotExistException {
    try {
      return recordDao.selectTreatmentRecordWeightByOrdNo(ordNo);
    } catch (EmptyResultDataAccessException e) {
    	EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("There is no TreatmentRecordWeight.");
      eventLogMessage.setSqlIdentification("(ordNo = "+ ordNo +")");
      logService.log(LogLevel.DEBUG, eventLogMessage,FUNCTION_CODE.FUNC_TREATMENT_RECORD,SERVICE_NAME.REMS, "RecordDao/selectTreatmentRecordWeightByOrdNo");
      throw new NotExistException("存在しない治療情報のオーダ番号を指定されています。");
    }
  }

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  public void updateTreatmentRecordWeight(Long ordNo, TreatmentRecordWeight treatmentRecordWeight)
    throws NotExistException, JsonProcessingException {

    // add FNSI-改修内容追加OrdMain履歴 付 start
    selectHistoryUtils.insertMangoDbHistory(10, ordNo, null, new ArrayList<>(), new ArrayList<>(), null, null,
      null, null, null, new ArrayList<>(), new ArrayList<>(), null, null, null,
      new ArrayList<>(), null, null);
    // mangoDb-updateTreatmentRecordForWeight-insertSuccess
    // add FNSI-改修内容追加OrdMain履歴 付 end
    // add FNSI-redmine#5170 付 房 start
    OrdMain ordMain = ordMainDao.selectByOrdNo(ordNo);
    // add 8277 周安寧 start
    NtssUser user = (NtssUser) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
    treatmentRecordWeight.setLogUserId(user.getUserId().toString());
    // add 8277 周安寧 end
    MstMachine mstMachine = mstMachineDao.selectByMachineNo(ordMain.getRstMachineNo());
    // add FNSI-redmine#5170 付 房 end
    treatmentRecordWeight.setOrdNo(ordNo);

    /* add by chamaojia 2024-07-05 [10774] Add data formatting for the 【 rst_weight_info 】 JSON content --start */
    /**
     * データ型変換が必要なアイテム   String -> Double
     * weight_before  透析前体重
     * ctr  CTR
     * ctr_weight  測定時体重
     * water_removal_target  目標除水量
     * water_removal_rst  実績除水量
     * add_water_total  実績補液量
     * ihdf_pll  I-HDF引き残し
     * weight_after  透析後体重
     * kt_v_measure  Kt/V測定値
     * URR  urr
     * iap_rt  IAP Ratio
     * weight_measure_before  透析前体重測定値
     * weight_measure_after  透析後体重測定値
     * weight_decreased  減少量
     */
    String[] changeItemKeys = new String[] {"weight_before", "ctr", "ctr_weight"
            , "water_removal_target", "water_removal_rst", "add_water_total"
            , "ihdf_pll", "weight_after"
            , "kt_v_measure", "urr", "iap_rt"
            , "weight_measure_before", "weight_measure_after", "weight_decreased"};
    String rstWeightInfo = treatmentRecordWeight.getRstWeightInfo();
    if (!ObjectUtils.isEmpty(rstWeightInfo)) {
      ObjectMapper mapper = new ObjectMapper();
      JsonNode rstWeightInfoJN = mapper.readTree(rstWeightInfo);
      ObjectNode objectNode = (ObjectNode) rstWeightInfoJN;
      for(String itemKey : changeItemKeys) {
        if (rstWeightInfoJN.has(itemKey)) {
          JsonNode ctrJN = rstWeightInfoJN.get(itemKey);
          // To determine if it is not empty and not a number, a type conversion is required
          if (!ctrJN.isNull() && !ctrJN.isNumber()) {
            objectNode.put(itemKey, ctrJN.asDouble());
          }
        }
      }
      // sttc_vns_prssr  静的静脈圧
      JsonNode svpJN = rstWeightInfoJN.get("sttc_vns_prssr");
      if (!svpJN.isNull() && !svpJN.isNumber()) {
        objectNode.put("sttc_vns_prssr", svpJN.asLong());
      }

      treatmentRecordWeight.setRstWeightInfo(mapper.writeValueAsString(rstWeightInfoJN));
    }
    /* add by chamaojia 2024-07-05 [10774] Add data formatting for the 【 rst_weight_info 】 JSON content --end */

    // add FNSI-redmine#5170 付 房 start
    final int updatedWeightCount = recordDao.updateTreatmentRecordForWeight(ordNo, treatmentRecordWeight);
    // add FNSI-redmine#5170 付 房 end
    if (updatedWeightCount <= 0) {
    	EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("There is no TreatmentRecordWeight.");
      eventLogMessage.setSqlIdentification("(ordNo = "+ ordNo +", treatmentRecordWeight = "+ treatmentRecordWeight +")");
      logService.log(LogLevel.DEBUG, eventLogMessage,FUNCTION_CODE.FUNC_TREATMENT_RECORD,SERVICE_NAME.REMS, "RecordDao/updateTreatmentRecordForWeight");
      throw new NotExistException("存在しない治療情報のオーダ番号を指定されています。");
    }
    //del FNSI-redmine6060 再修正 劉祥霖 start
    //webApiCallCommonUtil.doAutoCalculation(ordNo);
    //del FNSI-redmine6060 再修正 劉祥霖 end
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public TreatmentRecordEquipInfo getTreatmentRecordEquipInfo(Long ordNo) throws NotExistException {
    try {
      return recordDao.selectTreatmentRecordEquipInfoByOrdNo(ordNo);
    } catch (EmptyResultDataAccessException e) {
    	EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("There is no TreatmentRecordEquipInfo.");
      eventLogMessage.setSqlIdentification("(ordNo = "+ ordNo +")");
      logService.log(LogLevel.DEBUG, eventLogMessage,FUNCTION_CODE.FUNC_TREATMENT_RECORD,SERVICE_NAME.REMS, "RecordDao/selectTreatmentRecordEquipInfoByOrdNo");
      throw new NotExistException("存在しない治療情報のオーダ番号を指定されています。");
    }
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public void updateTreatmentRecordEquipInfo(Long ordNo, TreatmentRecordEquipInfo treatmentRecordEquipInfo) throws NotExistException {

    // add FNSI-改修内容追加OrdMain履歴 付 start
    selectHistoryUtils.insertMangoDbHistory(10, ordNo, null, new ArrayList<>(), new ArrayList<>(), null, null,
      null, null, null, new ArrayList<>(), new ArrayList<>(), null, null, null,
      new ArrayList<>(), null, null);
    // mangoDb-updateTreatmentRecordForEquipInfo-insertSuccess
    // add FNSI-改修内容追加OrdMain履歴 付 end

    treatmentRecordEquipInfo.setOrdNo(ordNo);
    final int updatedEquipInfoCount = recordDao.updateTreatmentRecordForEquipInfo(ordNo, treatmentRecordEquipInfo);
    if (updatedEquipInfoCount <= 0) {
    	EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("There is no TreatmentRecordEquipInfo.");
      eventLogMessage.setSqlIdentification("(ordNo = "+ ordNo +", treatmentRecordEquipInfo = "+ treatmentRecordEquipInfo +")");
      logService.log(LogLevel.DEBUG, eventLogMessage,FUNCTION_CODE.FUNC_TREATMENT_RECORD,SERVICE_NAME.REMS, "RecordDao/updateTreatmentRecordForEquipInfo");
      throw new NotExistException("存在しない治療情報のオーダ番号を指定されています。");
    }
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public Long getLatestOrdNo(Long patId, String facilityCd) {
    return recordDao.selectLatestOrdNoByPatIdAndFacilityCd(patId, facilityCd);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public TreatmentRecordAddition getTreatmentRecordAddition(Long ordNo) throws NotExistException {
    try {
      return recordDao.selectTreatmentRecordAdditionByOrdNo(ordNo);
    } catch (EmptyResultDataAccessException e) {
    	EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("There is no TreatmentRecordAddition.");
      eventLogMessage.setSqlIdentification("(ordNo = "+ ordNo +")");
      logService.log(LogLevel.DEBUG, eventLogMessage,FUNCTION_CODE.FUNC_TREATMENT_RECORD,SERVICE_NAME.REMS, "RecordDao/selectTreatmentRecordAdditionByOrdNo");
      throw new NotExistException("存在しない治療情報のオーダ番号を指定されています。");
    }
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public void updateTreatmentRecordAddition(Long ordNo, TreatmentRecordAddition treatmentRecordAddition)
      throws NotExistException {

    // add FNSI-改修内容追加OrdMain履歴 付 start
    selectHistoryUtils.insertMangoDbHistory(10, ordNo, null, new ArrayList<>(), new ArrayList<>(), null, null,
      null, null, null, new ArrayList<>(), new ArrayList<>(), null, null, null,
      new ArrayList<>(), null, null);
    // mangoDb-updateTreatmentRecordForAddition-insertSuccess
    // add FNSI-改修内容追加OrdMain履歴 付 end

    treatmentRecordAddition.setOrdNo(ordNo);
    // add 8277 周安寧 start
    NtssUser user = (NtssUser) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
    treatmentRecordAddition.setLogUserId(user.getUserId().toString());
    // add 8277 周安寧 end
    final int updatedAdditionCount = recordDao.updateTreatmentRecordForAddition(ordNo, treatmentRecordAddition);
    if (updatedAdditionCount <= 0) {
    	EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("There is no TreatmentRecordAddition.");
      eventLogMessage.setSqlIdentification("(ordNo = "+ ordNo +", treatmentRecordAddition = "+ treatmentRecordAddition +")");
      logService.log(LogLevel.DEBUG, eventLogMessage,FUNCTION_CODE.FUNC_TREATMENT_RECORD,SERVICE_NAME.REMS, "RecordDao/updateTreatmentRecordForAddition");
      throw new NotExistException("存在しない治療情報のオーダ番号を指定されています。");
    }
    //9480 治療記録（指示コメント情報）の更新,実際の治療値パラメータの変更をトリガせず、計算インタフェースを注釈呼び出し、性能の浪費を避ける gjn end
    //add FNSI-redmine6060 fang start
    //webApiCallCommonUtil.doAutoCalculation(ordNo);
    // add FNSI-redmine6060 fang end
    //9480 治療記録（指示コメント情報）の更新,実際の治療値パラメータの変更をトリガせず、計算インタフェースを注釈呼び出し、性能の浪費を避ける gjn end
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<TreatmentRecordVitalMonitor> getTreatmentRecordVitalMonitors(String facilityCd, Long ordNo) {
    // mni_monitorからバイタル情報を取得
    List<TreatmentRecordVitalMonitor> vitalList = recordDao.selectTreatmentRecordVitalMonitors(facilityCd, ordNo);
    // 更新者IDの姓名を設定
    for (TreatmentRecordVitalMonitor vital : vitalList) {
      // 更新者IDが未設定
      if (vital.getUpdStaffId() == null) {
        continue;
      }
      // 利用者情報（個人情報DB）取得
      MstPersonalUser mstPersonalUser = this.mstPersonalUserDao.selectById(vital.getUpdStaffId());
      if (mstPersonalUser != null) {
        vital.setUserLastName(mstPersonalUser.getUserLastName());
        vital.setUserFirstName(mstPersonalUser.getUserFirstName());
      }
    }
    return vitalList;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public void insertOrUpdateTreatmentRecordForMniMonitor(Long ordNo, List<MniMonitor> mniMonitorList, Long updStaffId) throws NotExistException {

    for (MniMonitor monitor : mniMonitorList) {
      // 新規登録（生体モニタリング番号が0の場合）
      if (monitor.getBioMoniCtlNo() == 0) {

        // オーダ番号から実績情報を取得
        OrdMain ordMain = this.ordMainDao.selectByOrdNo(ordNo);
        if (ordMain == null) {
          throw new NotExistException("存在しない治療情報のオーダ番号を指定されています。");
        }
        // 装置番号に該当する装置マスタを取得
        Long machineNo = ordMain.getRstMachineNo();
        MstMachine mstMachine = null;
        if (machineNo != null) {
          // オーダ番号に紐づく装置マスタを取得
          mstMachine = mstMachineDao.selectByMachineNo(machineNo);
        } else {
        	EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage("装置番号に該当する装置マスタが見つかりませんでした。");
          eventLogMessage.setSqlIdentification("(ordNo = "+ ordNo +")");
          logService.log(LogLevel.DEBUG, eventLogMessage,FUNCTION_CODE.FUNC_TREATMENT_RECORD,SERVICE_NAME.REMS, "OrdMainDao/selectByOrdN");
        }
        monitor.setBioMoniCtlNo(null);

        // 施設コード
        monitor.setFacilityCd(ordMain.getFacilityCd());
        // 型式コード
        // 装置マスタが取得できない場合にはnullとする。
        monitor.setMachineTypeCd(mstMachine != null ? mstMachine.getMachineTypeCd() : null);
        // 製造番号
        // 装置マスタが取得できない場合にはnullとする。
        monitor.setMachineSerial(mstMachine != null ? mstMachine.getMachineSerial() : null);
        // データ種別
        monitor.setDataType(monitor.getDataType() == 0 ? 2 : monitor.getDataType());
        // 登録日時
        monitor.setRegDate(new java.sql.Timestamp(System.currentTimeMillis()));
        // 更新日時
        monitor.setUpDate(new java.sql.Timestamp(System.currentTimeMillis()));
        // 更新者ID
        monitor.setUpdStaffId(updStaffId);
        // 登録処理
        mniMonitorDao.insert(monitor);

        //add FNSI-6127 ljx start
        //変更履歴へ登録
        makeRstHistoryForMonitor(new MniMonitor(),monitor,"add");
        //add FNSI-6127 ljx end


      } else {

        // DB更新ログ出力ロジック wangzuo Start
        String tableName = "mni_monitor";
        // SQL検索条件
        StringBuffer wheres = new StringBuffer("");
        wheres.append(" WHERE\n");
        wheres.append(" bio_moni_ctl_no = " + monitor.getBioMoniCtlNo() + "\n");

        // logCommon設定
        DataUpdateLogCommonNew logCommon = getLogCommon(mniMonitorDao, tableName, wheres, getEventLogMessage());
        // ログ出力カラム情報及び更新前データ情報取得
        boolean setResult = logCommon.setInfo();
        // DB更新ログ出力ロジック wangzuo End

        //add FNSI-6127 ljx start
        //変更前のモニタデータを取得。
        MniMonitor oldMniMonitor = mniMonitorDao.selectByBioMoniCtlNoOne(monitor.getBioMoniCtlNo());
        //add FNSI-6127 ljx end

        // 更新処理
        int updateCount = mniMonitorDao.updateMonitorData(
          // 更新する生体モニタリング番号
          monitor.getBioMoniCtlNo(),
          // データ種別
          monitor.getDataType(),
          // モニタデータ
          monitor.getMonitorData(),
          // 削除フラグ
          monitor.getIsDel(),
          // 発生日時
          monitor.getOccurDate(),
          // 更新日時
          new java.sql.Timestamp(System.currentTimeMillis()),
          // 更新者ID
          updStaffId
        );

        // DB更新ログ出力ロジック wangzuo Start
        // 更新後データ取得、差分あれば、log出力
        if (setResult && updateCount > 0) {
          logCommon.updateLog();
        }
        // DB更新ログ出力ロジック wangzuo End

        //add FNSI-6127 ljx start
        //ここの処理では二つがあります：変更、削除
        if(oldMniMonitor != null){
          //8499テストで発見されたエラー(NullPointerException)の追加修正 ljx start
          monitor.setUpdStaffId(updStaffId);
          //8499テストで発見されたエラー(NullPointerException)の追加修正 ljx end
          //変更の場合
          if("0".equals(monitor.getIsDel())){
            makeRstHistoryForMonitor(oldMniMonitor,monitor,"upd");
          }else{//削除の場合
            makeRstHistoryForMonitor(oldMniMonitor,new MniMonitor(),"del");
          }
        }
        //add FNSI-6127 ljx end
      }
    }

    // add FNSI-改修内容追加OrdMain履歴 付 start
    getHistory(ordNo);
    // mangoDb-updateTreatmentRecordForConfirm-insertSuccess
    // add FNSI-改修内容追加OrdMain履歴 付 end

    // 確定フラグを未確定に更新
    // mod #8163 2022/12/13 後体重測定時、初版確定時に up_user_id, up_ind_user_id がその操作者に更新される dou start
    //mod FNSI-7531 劉全航 start
    // recordDao.updateTreatmentRecordForConfirm(ordNo, "0", updStaffId);
    recordDao.updateTreatmentRecordForConfirm(ordNo, "0");
    //mod FNSI-7531 劉全航 end
    // mod #8163 2022/12/13 後体重測定時、初版確定時に up_user_id, up_ind_user_id がその操作者に更新される dou end

    //9480 モニタデータ情報の登録更新,実際の治療値パラメータの変更をトリガせず、計算インタフェースを注釈呼び出し、性能の浪費を避ける gjn start
    //add FNSI-redmine6060 fang start
    //webApiCallCommonUtil.doAutoCalculation(ordNo);
    // add FNSI-redmine6060 fang end
    //9480 モニタデータ情報の登録更新,実際の治療値パラメータの変更をトリガせず、計算インタフェースを注釈呼び出し、性能の浪費を避ける gjn end
  }

  // add FNSI-改修内容追加OrdMain履歴 付 start
  private void getHistory(Long ordNo){
    selectHistoryUtils.insertMangoDbHistory(1, ordNo, null, new ArrayList<>(), new ArrayList<>(), null, null,
      null, null, null, new ArrayList<>(), new ArrayList<>(), null, null, null,
      new ArrayList<>(), null, null);
  }
  // add FNSI-改修内容追加OrdMain履歴 付 end

  /**
   * {@inheritDoc}
   */
  @Override
  public TreatmentRecordReportInfo getTreatmentRecordReportInfoByOrdNo(Long ordNo) {
    return recordDao.selectTreatmentRecordReportInfoByOrdNo(ordNo);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<MstMachine> getMstMachineByOrdNoRst(Long ordNo) {
    return mstMachineDao.selectByOrdNoRst(ordNo);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  // mod #8163 2022/12/13 後体重測定時、初版確定時に up_user_id, up_ind_user_id がその操作者に更新される dou start
  // public void updateTreatmentRecordForConfirm(Long ordNo, String confirm, Long updStaffId) {
  public void updateTreatmentRecordForConfirm(Long ordNo, String confirm) {
    // mod #8163 2022/12/13 後体重測定時、初版確定時に up_user_id, up_ind_user_id がその操作者に更新される dou end

    // add FNSI-改修内容追加OrdMain履歴 付 start
    getHistory(ordNo);
    // mangoDb-updateTreatmentRecordForConfirm-insertSuccess
    // add FNSI-改修内容追加OrdMain履歴 付 end

    // mod FNSI NO.396 治療記録 版確定 start -- Sanjingye Sun 20210126
    //add FNSI-redmine5512 fang start
    boolean setResult = false;
    DataUpdateLogCommonNew logCommon = null;
    try {
      String tableName = "ord_main";
      // SQL検索条件
      StringBuffer wheres = new StringBuffer("");
      wheres.append(" WHERE\n");
      wheres.append(" ord_no = '" + ordNo + "'\n");
      // logCommon設定
      logCommon = getLogCommon(recordDao, tableName, wheres, getEventLogMessage());
      // ログ出力カラム情報及び更新前データ情報取得
      setResult = logCommon.setInfo();
    } catch(Exception e) {
      setResult = false;
    }
    //add FNSI-redmine5512 fang end
    //mod FNSI-redmine5512 fang start
    // mod #8163 2022/12/13 後体重測定時、初版確定時に up_user_id, up_ind_user_id がその操作者に更新される dou start
    //mod FNSI-7531 劉全航 start
    // int updateCnt = recordDao.updateTreatmentRecordForConfirm(ordNo, confirm, updStaffId);
    int updateCnt = recordDao.updateTreatmentRecordForConfirm(ordNo, confirm);
    //mod FNSI-7531 劉全航 end
    // mod #8163 2022/12/13 後体重測定時、初版確定時に up_user_id, up_ind_user_id がその操作者に更新される dou end
    //mod FNSI-redmine5512 fang end

    //add FNSI-redmine5512 fang start
    if (setResult && updateCnt > 0) {
     logCommon.updateLog();
    }
    //add FNSI-redmine5512 fang end

    // del 11613 by shiyw 20250307 start
//    if ("1".equals(confirm)) {
//      treatmentStatusListService.resultReconfirm2Oms(ordNo, null);
//    }
    // del 11613 by shiyw 20250307 end

    // Who Coded these bullshits ?
//    final int updateConfirmCount = recordDao.updateTreatmentRecordForConfirm(ordNo, confirm);

//    if (updateConfirmCount <= 0) {
//      // 該当するオーダ番号に該当するord_mainが存在しない場合でもエラーにはしない
//    }
//    return;

    // mod FNSI NO.396 治療記録 版確定 end -- Sanjingye Sun 20210126
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<MntMachineState> getMntMachineState(String facilityCd, Long ordNo) {
    return mntMachineStateDao.selectByOrdNo(facilityCd, ordNo);
  }


  /**
   * {@inheritDoc}
   */
  @Override
  public String getIsPurification(Integer treatmentCd) throws NotExistException {

    MstTreatment mt = mstTreatmentDao.selectByCd(treatmentCd);
    if (mt != null && Objects.equals(mt.getDeviceMode(), Treatment.DeviceMode.PURIFICATION)) {
      return FlagType.FLAG_ON;
    }
    return FlagType.FLAG_OFF;
  }

  //add 帳票コード取得修正 房 start
  /**
   * レポートコードリスト取得
   * @param facilitySettingNo　施設設定番号
   * @param facilityCd 施設番号
   * @return レポートコードリスト
   */
  @Override
  public List<ReportCds> getReportCds(String facilitySettingNo, String facilityCd) {
    List<ReportCds> reportCds = recordDao.selectReportCds(facilitySettingNo, facilityCd);
    return reportCds;
  }
  //add 帳票コード取得修正 end

  //add FNSI内容修正 外部Api調用 房 start
  /**
   * 投与薬剤情報チェック
   * @param ordNo
   * @param facilityCd
   * @return
   */
  @Override
  public Integer getCheckIsHave(Long ordNo, String facilityCd){
    return mstTreatmentDao.getCheckIsHave(ordNo, facilityCd);
  }

  /**
   * 治療中ordNo取得
   * @param patId
   * @param stateList
   * @return
   */
  @Override
  public List<OrdMain> selectTreatingOrdno(Long patId, List<String> stateList){
    return mstTreatmentDao.selectTreatingOrdno(patId, stateList);
  }

  /**
   * お知らせ取得
   * @param facilityCd
   * @param deviceEdgeNo
   * @return
   */
  @Override
  public ComsvSet selectComsvSet(String facilityCd, Integer deviceEdgeNo) {
    ComsvSet comsvSet = comsvSetDao.selectComsvSet(facilityCd, deviceEdgeNo);
    return comsvSet;
  }
  //add FNSI内容修正 外部Api調用 房 end

  //add FNSI内容修正 ベッド切り替え 房 start
  /**
   * ベッド切替処理
   * @param ordNo
   * @param facilityCd
   * @return
   */
  @Override
  public List<Long> bedChangeHandle(Long ordNo, Long bedNo, String facilityCd){
    List<MstMachine> mstMachines = mstMachineDao.selectByOrdNoRst(ordNo);
    List<MntMachineState> mntMachineStates = mntMachineStateDao.selectByBedCd(bedNo);
    List<MntMachineState> nowMachineStates = mntMachineStates.stream().filter(x->x.getFacilityCd().equals(facilityCd))
      .collect(Collectors.toList());
    if (nowMachineStates != null && nowMachineStates.size() > 0) {
      if (nowMachineStates.get(0).getOrdNo() != null && nowMachineStates.get(0).getOrdNo().equals(ordNo)) {
        OrdMain ordMain = this.ordMainDao.selectByOrdNo(ordNo);
        Integer deviceEdgeNo = null;
        if (mstMachines != null && mstMachines.size() > 0) {
          deviceEdgeNo = mstMachines.get(0).getDeviceEdgeNo();
          ComsvSet comsvSet = selectComsvSet(facilityCd, deviceEdgeNo);
          boolean handleFlag = false;
          if (comsvSet != null && "0".equals(comsvSet.getPatTiming()) && "4".equals(ordMain.getRstDialysisState())) {
            handleFlag = true;
          } else if (comsvSet != null && "1".equals(comsvSet.getPatTiming()) && ("4".equals(ordMain.getRstDialysisState())
            || "5".equals(ordMain.getRstDialysisState()))) {
            handleFlag = true;
          }
          if (handleFlag && deviceEdgeNo != null) {
            mntMachineStateDao.updateClearOrdNo(facilityCd, mstMachines.get(0).getMachineTypeCd(),
              mstMachines.get(0).getMachineSerial(), ordNo,
              new Timestamp(System.currentTimeMillis()));
            List<Long> resultList = new ArrayList<Long>();
            resultList.add(Long.valueOf(mstMachines.get(0).getDeviceEdgeNo()));
            resultList.add(mstMachines.get(0).getMachineNo());
            return resultList;
          }
        }
      }
    }
    return null;
  }
  //add FNSI内容修正 ベッド切り替え 房 end

  //add FNSI修正401対応 房 start
  private void ordChecklistMediInfoUpdate(Long ordNo, TreatmentRecordMediInfo treatmentRecordMediInfo, String facilityCd) throws IOException {
    ObjectMapper mapper = new ObjectMapper();
    List<OrdChecklist> resultChecklists = ordChecklistDao.selectByOrdNo(SelectOptions.get(), ordNo);
    if (resultChecklists != null && resultChecklists.size() > 0) {
      final List<OrdChecklist> ordChecklists = resultChecklists.stream().filter(x->x.getFuncClass() == 3).collect(Collectors.toList());
      if (ordChecklists != null && ordChecklists.size() > 0) {
        List<ReceiveRstMediInfoDto> receiveRstMediInfoDtos = new ArrayList<ReceiveRstMediInfoDto>();
        /* modify by chamaojia 2024-04-02 [10196] add null judgment processing  --start */
//        if (!treatmentRecordMediInfo.getRstMediInfo().equals("[]")) {
        if (!ObjectUtils.isEmpty(treatmentRecordMediInfo.getRstMediInfo()) && !("[]").equals(treatmentRecordMediInfo.getRstMediInfo())) {
        /* modify by chamaojia 2024-04-02 [10196] add null judgment processing  --end */
          //classCdとcdにより、amountを集計する。
          List<ReceiveRstMediInfoDto> tempReceiveRstMediInfoDtos = mapper.readValue(treatmentRecordMediInfo.getRstMediInfo(), new TypeReference<List<ReceiveRstMediInfoDto>>(){});
          for (ReceiveRstMediInfoDto temp : tempReceiveRstMediInfoDtos) {
            if (receiveRstMediInfoDtos.size() == 0) {
              receiveRstMediInfoDtos.add(temp);
            } else {
              List<ReceiveRstMediInfoDto> editReceiveRstMediInfoDtos = receiveRstMediInfoDtos.stream().filter(x->x.getClassCd().equals(temp.getClassCd()) && x.getCd().equals(temp.getCd())).collect(Collectors.toList());
              if (editReceiveRstMediInfoDtos.size() > 0) {
                ReceiveRstMediInfoDto infoDto = editReceiveRstMediInfoDtos.get(0);
                infoDto.setAmount(String.valueOf(Integer.parseInt(infoDto.getAmount()) + Integer.parseInt(temp.getAmount())));
              } else {
                receiveRstMediInfoDtos.add(temp);
              }
            }
          }
        }
        if (receiveRstMediInfoDtos != null && receiveRstMediInfoDtos.size() > 0) {
          //データ更新
          receiveRstMediInfoDtos.stream().forEach(element->{
            List<OrdChecklist> tempList = ordChecklists.stream().filter(x->{
              if (x.getRstChecklistInfo().getClassCd() != null
                && element.getClassCd() != null
                && x.getRstChecklistInfo().getCode() != null
                && element.getCd() != null
                && x.getRstChecklistInfo().getMedicineType() != null
                && element.getMedicineType() != null) {
                if (element.getClassCd().equals(x.getRstChecklistInfo().getClassCd())
                  && element.getCd().equals(x.getRstChecklistInfo().getCode())
                  && element.getMedicineType().equals(x.getRstChecklistInfo().getMedicineType())) {
                  return true;
                }
              }
              return false;
            }).collect(Collectors.toList());
            //ClassCdとCodeが完全一致の場合
            if (tempList != null && tempList.size() > 0) {
              //実績区分が9以外の場合
              if (tempList.get(0).getRstClass() != 9) {
                for (OrdChecklist ordChecklist : tempList) {
                  if ((ordChecklist.getRstChecklistInfo().getAmount() != null && !element.getAmount().equals(ordChecklist.getRstChecklistInfo().getAmount()))
                    || (ordChecklist.getRstChecklistInfo().getAmount() == null && element.getAmount() != null)) {
                    ordChecklist.setIsCheck("0");
                    ordChecklist.getRstChecklistInfo().setAmount(element.getAmount());
                    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
                    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
                    LogEventUtils.setOperatorId(ordChecklist,logService);
                    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
                    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
                    //del 9324 ord_checklist共通之外的dao方法删除 gjn start
                    //ordChecklistDao.update(ordChecklist);
                    //del 9324 ord_checklist共通之外的dao方法删除 gjn end
                  }
                }
                tempList = null;
              } else {
                //実績区分が９の場合
                for (OrdChecklist ordChecklist : tempList) {
                  //実績区分が9のデータを削除する。
                  //del 9324 ord_checklist共通之外的dao方法删除 gjn start
                  //ordChecklistDao.deleteByCheckListCtlNo(ordChecklist.getChecklistCtlNo());
                  //del 9324 ord_checklist共通之外的dao方法删除 gjn end
                }
              }
            } else {
              //ClassCd一致だけの場合
              tempList = ordChecklists.stream().filter(x->{
                if (x.getRstChecklistInfo().getClassCd() != null
                  && element.getClassCd() != null
                  && x.getRstChecklistInfo().getClassCd().equals(element.getClassCd())) {
                  return true;
                }
                return false;
              }).collect(Collectors.toList());
              if (tempList != null && tempList.size() > 0) {
                if (tempList.get(0).getRstClass() != 9) {
                  Integer classCd = tempList.get(0).getRstChecklistInfo().getClassCd();
                  Integer code = tempList.get(0).getRstChecklistInfo().getCode();
                  tempList = tempList.stream().filter(x->{
                    if (x.getRstChecklistInfo().getClassCd().equals(classCd)) {
                      if (x.getRstChecklistInfo().getCode() == null && code == null) {
                        return true;
                      }
                      if (x.getRstChecklistInfo().getCode() != null && code != null
                        && x.getRstChecklistInfo().getCode().equals(code)) {
                        return true;
                      }
                    }
                    return false;
                  }).collect(Collectors.toList());
                } else {
                  for (OrdChecklist ordChecklist : tempList) {
                    //del 9324 ord_checklist共通之外的dao方法删除 gjn start
                    //ordChecklistDao.deleteByCheckListCtlNo(ordChecklist.getChecklistCtlNo());
                    //del 9324 ord_checklist共通之外的dao方法删除 gjn end
                  }
                }
              }
            }
            if (tempList != null && tempList.size() > 0) {
              for (OrdChecklist ordChecklist : tempList) {
                OrdChecklist insertOrdChecklist = new OrdChecklist();
                insertOrdChecklist.setOrdNo(ordChecklist.getOrdNo());
                insertOrdChecklist.setRstClass((short) 1);
                insertOrdChecklist.setIsCheck("0");
                insertOrdChecklist.setListCd(ordChecklist.getListCd());
                insertOrdChecklist.setFuncClass(ordChecklist.getFuncClass());
                insertOrdChecklist.setRegStaffInfo(ordChecklist.getRegStaffInfo());
                insertOrdChecklist.setIsDisp(ordChecklist.getIsDisp());
                insertOrdChecklist.setIsDel(ordChecklist.getIsDel());
                Timestamp timestamp = new Timestamp(System.currentTimeMillis());
                insertOrdChecklist.setOccurDate(timestamp);
                insertOrdChecklist.setRegDate(timestamp);
                insertOrdChecklist.setUpDate(timestamp);
                insertOrdChecklist.setFacilityCd(facilityCd);
                OrdChecklist.OrdChecklistRegCheckInfo regCheckInfo = new OrdChecklist.OrdChecklistRegCheckInfo();
                regCheckInfo.setChecklistCd(ordChecklist.getRstChecklistInfo().getChecklistCd());
                regCheckInfo.setItemNumber(ordChecklist.getRstChecklistInfo().getItemNumber());
                regCheckInfo.setClassCd(element.getClassCd());
                regCheckInfo.setCode(element.getCd());
                regCheckInfo.setCodeUpdate(null);
                regCheckInfo.setName(element.getName());
                // del 10310 needle _ typeの使用を削除するには gjn start
                //regCheckInfo.setNeedleType(null);
                // del 10310 needle _ typeの使用を削除するには gjn end
                regCheckInfo.setMedicineType(element.getMedicineType());
                regCheckInfo.setAmount(element.getAmount());
                regCheckInfo.setUnit(element.getUnit());
                insertOrdChecklist.setRstChecklistInfo(regCheckInfo);
                //del 9324 ord_checklist共通之外的dao方法删除 gjn start
                //ordChecklistDao.insert(insertOrdChecklist);
                //del 9324 ord_checklist共通之外的dao方法删除 gjn end
              }
            }
          });
        }
        //データ削除
        for (int i = ordChecklists.size() - 1; i >= 0; i--) {
          OrdChecklist element = ordChecklists.get(i);
          if (element.getRstClass() != 9) {
            List<ReceiveRstMediInfoDto> tempList = receiveRstMediInfoDtos.stream().filter(x->{
              if (x.getClassCd() != null && element.getRstChecklistInfo().getClassCd() != null
                && x.getClassCd().equals(element.getRstChecklistInfo().getClassCd())) {
                if (x.getCd() == null && element.getRstChecklistInfo().getCode() == null) {
                  return true;
                }
                if (x.getCd() != null && element.getRstChecklistInfo().getCode() != null
                  && x.getCd().equals(element.getRstChecklistInfo().getCode())) {
                  return true;
                }
              }
              return false;
            }).collect(Collectors.toList());
            if (tempList == null || tempList.size() == 0) {
              //del 9324 ord_checklist共通之外的dao方法删除 gjn start
              //ordChecklistDao.deleteByCheckListCtlNo(element.getChecklistCtlNo());
              //del 9324 ord_checklist共通之外的dao方法删除 gjn end
            } else {
              continue;
            }
            ordChecklists.remove(element);
            List<OrdChecklist> countList = ordChecklists.stream().filter(x->x.getRstChecklistInfo().getClassCd() != null
              && element.getRstChecklistInfo().getClassCd() != null
              && x.getRstChecklistInfo().getClassCd().equals(element.getRstChecklistInfo().getClassCd())
              && x.getListCd() == element.getListCd()).collect(Collectors.toList());
            if (countList == null || countList.size() == 0) {
              OrdChecklist insertOrdChecklist = new OrdChecklist();
              insertOrdChecklist.setOrdNo(element.getOrdNo());
              insertOrdChecklist.setRstClass((short) 9);
              insertOrdChecklist.setIsCheck("0");
              insertOrdChecklist.setListCd(element.getListCd());
              insertOrdChecklist.setFuncClass(element.getFuncClass());
              insertOrdChecklist.setRegStaffInfo(element.getRegStaffInfo());
              insertOrdChecklist.setIsDisp(element.getIsDisp());
              insertOrdChecklist.setIsDel(element.getIsDel());
              Timestamp timestamp = new Timestamp(System.currentTimeMillis());
              insertOrdChecklist.setOccurDate(timestamp);
              insertOrdChecklist.setRegDate(timestamp);
              insertOrdChecklist.setUpDate(timestamp);
              insertOrdChecklist.setFacilityCd(facilityCd);
              OrdChecklist.OrdChecklistRegCheckInfo regCheckInfo = new OrdChecklist.OrdChecklistRegCheckInfo();
              regCheckInfo.setChecklistCd(element.getRstChecklistInfo().getChecklistCd());
              regCheckInfo.setItemNumber(element.getRstChecklistInfo().getItemNumber());
              regCheckInfo.setClassCd(element.getRstChecklistInfo().getClassCd());
              regCheckInfo.setCode(null);
              regCheckInfo.setCodeUpdate(element.getRstChecklistInfo().getCodeUpdate());
              regCheckInfo.setName(null);
              // del 10310 needle _ typeの使用を削除するには gjn start
              //regCheckInfo.setNeedleType(element.getRstChecklistInfo().getNeedleType());
              // del 10310 needle _ typeの使用を削除するには gjn end
              regCheckInfo.setMedicineType(element.getRstChecklistInfo().getMedicineType());
              regCheckInfo.setAmount(element.getRstChecklistInfo().getAmount());
              regCheckInfo.setUnit(element.getRstChecklistInfo().getUnit());
              insertOrdChecklist.setRstChecklistInfo(regCheckInfo);
              //del 9324 ord_checklist共通之外的dao方法删除 gjn start
              //ordChecklistDao.insert(insertOrdChecklist);
              //del 9324 ord_checklist共通之外的dao方法删除 gjn end
            }
          }
        }
      }
    }
  }

  private void ordChecklistEquipmentUpdate(Long ordNo, TreatmentRecordEquipInfo treatmentRecordEquipInfo, String facilityCd) throws IOException {
    ObjectMapper mapper = new ObjectMapper();
    List<OrdChecklist> resultChecklists = ordChecklistDao.selectByOrdNo(SelectOptions.get(), ordNo);
    if (resultChecklists != null && resultChecklists.size() > 0) {
      final List<OrdChecklist> ordChecklists = resultChecklists.stream().filter(x->x.getFuncClass() == 2).collect(Collectors.toList());
      if (ordChecklists != null && ordChecklists.size() > 0) {
        List<ReceiveRstEquipInfoDto> receiveRstEquipInInfoDtos = new ArrayList<ReceiveRstEquipInfoDto>();
        if (!treatmentRecordEquipInfo.getRstEquipInfo().equals("[]")) {
          //classCdとcdにより、amountを集計する。
          List<ReceiveRstEquipInfoDto> tempReceiveRstEquipInInfoDtos = mapper.readValue(treatmentRecordEquipInfo.getRstEquipInfo(), new TypeReference<List<ReceiveRstEquipInfoDto>>(){});
          for (ReceiveRstEquipInfoDto temp : tempReceiveRstEquipInInfoDtos) {
            if (receiveRstEquipInInfoDtos.size() == 0) {
              receiveRstEquipInInfoDtos.add(temp);
            } else {
              // #10196 Fix By Zhou.tao Start
//              List<ReceiveRstEquipInfoDto> editReceiveRstEquipInInfoDtos = receiveRstEquipInInfoDtos.stream().filter(x->x.getClassCd().equals(temp.getClassCd()) && x.getCd().equals(temp.getCd())).collect(Collectors.toList());
              List<ReceiveRstEquipInfoDto> editReceiveRstEquipInInfoDtos = receiveRstEquipInInfoDtos.stream()
                .filter(x ->
                  ObjectUtils.nullSafeEquals(x.getCd(), temp.getCd())
                    &&
                  ObjectUtils.nullSafeEquals(x.getClassCd(), temp.getClassCd())
                ).toList();
              // #10196 Fix By Zhou.tao End
              if (editReceiveRstEquipInInfoDtos.size() > 0) {
                ReceiveRstEquipInfoDto infoDto = editReceiveRstEquipInInfoDtos.get(0);
                infoDto.setAmount(String.valueOf(Integer.parseInt(infoDto.getAmount()) + Integer.parseInt(temp.getAmount())));
              } else {
                receiveRstEquipInInfoDtos.add(temp);
              }
            }
          }
        }
        if (receiveRstEquipInInfoDtos != null && receiveRstEquipInInfoDtos.size() > 0) {
          //データ更新
          receiveRstEquipInInfoDtos.stream().forEach(element->{
            List<OrdChecklist> tempList = ordChecklists.stream().filter(x->{
              if (x.getRstChecklistInfo().getClassCd() != null
                && element.getClassCd() != null
                && x.getRstChecklistInfo().getCode() != null
                && element.getCd() != null) {
                if (element.getClassCd().equals(x.getRstChecklistInfo().getClassCd())
                  && element.getCd().equals(x.getRstChecklistInfo().getCode())) {
                  return true;
                }
              }
              return false;
            }).collect(Collectors.toList());
            //ClassCdとCodeが完全一致の場合
            if (tempList != null && tempList.size() > 0) {
              //実績区分が9以外の場合
              if (tempList.get(0).getRstClass() != 9) {
                for (OrdChecklist ordChecklist : tempList) {
                  if ((ordChecklist.getRstChecklistInfo().getAmount() != null && !element.getAmount().equals(ordChecklist.getRstChecklistInfo().getAmount()))
                    || (ordChecklist.getRstChecklistInfo().getAmount() == null && element.getAmount() != null)) {
                    ordChecklist.setIsCheck("0");
                    ordChecklist.getRstChecklistInfo().setAmount(element.getAmount());
                    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
                    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
                    LogEventUtils.setOperatorId(ordChecklist,logService);
                    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
                    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
                    //del 9324 ord_checklist共通之外的dao方法删除 gjn start
                    //ordChecklistDao.update(ordChecklist);
                    //del 9324 ord_checklist共通之外的dao方法删除 gjn end
                  }
                }
                tempList = null;
              } else {
                //実績区分が９の場合
                for (OrdChecklist ordChecklist : tempList) {
                  //実績区分が9のデータを削除する。
                  //ordChecklistDao.deleteByCheckListCtlNo(ordChecklist.getChecklistCtlNo());
                }
              }
            } else {
              //ClassCd一致だけの場合
              tempList = ordChecklists.stream().filter(x->{
                if (x.getRstChecklistInfo().getClassCd() != null
                    && element.getClassCd() != null
                    && x.getRstChecklistInfo().getClassCd().equals(element.getClassCd())) {
                  return true;
                }
                return false;
              }).collect(Collectors.toList());
              if (tempList != null && tempList.size() > 0) {
                if (tempList.get(0).getRstClass() != 9) {
                  Integer classCd = tempList.get(0).getRstChecklistInfo().getClassCd();
                  Integer code = tempList.get(0).getRstChecklistInfo().getCode();
                  tempList = tempList.stream().filter(x->{
                    if (x.getRstChecklistInfo().getClassCd().equals(classCd)) {
                      if (x.getRstChecklistInfo().getCode() == null && code == null) {
                        return true;
                      }
                      if (x.getRstChecklistInfo().getCode() != null && code != null
                        && x.getRstChecklistInfo().getCode().equals(code)) {
                        return true;
                      }
                    }
                    return false;
                  }).collect(Collectors.toList());
                } else {
                  for (OrdChecklist ordChecklist : tempList) {
                    //del 9324 ord_checklist共通之外的dao方法删除 gjn start
                    //ordChecklistDao.deleteByCheckListCtlNo(ordChecklist.getChecklistCtlNo());
                    //del 9324 ord_checklist共通之外的dao方法删除 gjn end
                  }
                }
              }
            }
            if (tempList != null && tempList.size() > 0) {
              for (OrdChecklist ordChecklist : tempList) {
                OrdChecklist insertOrdChecklist = new OrdChecklist();
                insertOrdChecklist.setOrdNo(ordChecklist.getOrdNo());
                insertOrdChecklist.setRstClass((short) 1);
                insertOrdChecklist.setIsCheck("0");
                insertOrdChecklist.setListCd(ordChecklist.getListCd());
                insertOrdChecklist.setFuncClass(ordChecklist.getFuncClass());
                insertOrdChecklist.setRegStaffInfo(ordChecklist.getRegStaffInfo());
                insertOrdChecklist.setIsDisp(ordChecklist.getIsDisp());
                insertOrdChecklist.setIsDel(ordChecklist.getIsDel());
                Timestamp timestamp = new Timestamp(System.currentTimeMillis());
                insertOrdChecklist.setOccurDate(timestamp);
                insertOrdChecklist.setRegDate(timestamp);
                insertOrdChecklist.setUpDate(timestamp);
                insertOrdChecklist.setFacilityCd(facilityCd);
                OrdChecklist.OrdChecklistRegCheckInfo regCheckInfo = new OrdChecklist.OrdChecklistRegCheckInfo();
                regCheckInfo.setChecklistCd(ordChecklist.getRstChecklistInfo().getChecklistCd());
                regCheckInfo.setItemNumber(ordChecklist.getRstChecklistInfo().getItemNumber());
                regCheckInfo.setClassCd(element.getClassCd());
                regCheckInfo.setCode(element.getCd());
                regCheckInfo.setCodeUpdate(null);
                regCheckInfo.setName(element.getName());
                // del 10310 needle _ typeの使用を削除するには gjn start
//                if (element.getClassCd() != null && element.getClassCd() == 0) {
//                  regCheckInfo.setNeedleType(null);
//                } else {
//                  regCheckInfo.setNeedleType(element.getNeedleType());
//                }
                // del 10310 needle _ typeの使用を削除するには gjn end
                regCheckInfo.setMedicineType(null);
                regCheckInfo.setAmount(element.getAmount());
                if (element.getClassCd() != null && element.getClassCd() == 0) {
                  regCheckInfo.setUnit("本");
                } else {
                  regCheckInfo.setUnit(element.getUnit());
                }
                insertOrdChecklist.setRstChecklistInfo(regCheckInfo);
                //del 9324 ord_checklist共通之外的dao方法删除 gjn start
                //ordChecklistDao.insert(insertOrdChecklist);
                //del 9324 ord_checklist共通之外的dao方法删除 gjn end
              }
            }
          });
        }
        //データ削除
        for (int i = ordChecklists.size() - 1; i >= 0; i--) {
          OrdChecklist element = ordChecklists.get(i);
          if (element.getRstClass() != 9) {
            List<ReceiveRstEquipInfoDto> tempList = receiveRstEquipInInfoDtos.stream().filter(x->{
              if (x.getClassCd() != null && element.getRstChecklistInfo().getClassCd() != null
                && x.getClassCd().equals(element.getRstChecklistInfo().getClassCd())) {
                if (x.getCd() == null && element.getRstChecklistInfo().getCode() == null) {
                  return true;
                }
                if (x.getCd() != null && element.getRstChecklistInfo().getCode() != null
                  && x.getCd().equals(element.getRstChecklistInfo().getCode())) {
                  return true;
                }
              }
              return false;
            }).collect(Collectors.toList());
            if (tempList == null || tempList.size() == 0) {
              //del 9324 ord_checklist共通之外的dao方法删除 gjn start
              //ordChecklistDao.deleteByCheckListCtlNo(element.getChecklistCtlNo());
              //del 9324 ord_checklist共通之外的dao方法删除 gjn start
            } else {
              continue;
            }
            ordChecklists.remove(element);
            List<OrdChecklist> countList = ordChecklists.stream().filter(x->x.getRstChecklistInfo().getClassCd() != null
              && element.getRstChecklistInfo().getClassCd() != null
              && x.getRstChecklistInfo().getClassCd().equals(element.getRstChecklistInfo().getClassCd())
              && x.getListCd() == element.getListCd()).collect(Collectors.toList());
            if (countList == null || countList.size() == 0) {
              OrdChecklist insertOrdChecklist = new OrdChecklist();
              insertOrdChecklist.setOrdNo(element.getOrdNo());
              insertOrdChecklist.setRstClass((short) 9);
              insertOrdChecklist.setIsCheck("0");
              insertOrdChecklist.setListCd(element.getListCd());
              insertOrdChecklist.setFuncClass(element.getFuncClass());
              insertOrdChecklist.setRegStaffInfo(element.getRegStaffInfo());
              insertOrdChecklist.setIsDisp(element.getIsDisp());
              insertOrdChecklist.setIsDel(element.getIsDel());
              Timestamp timestamp = new Timestamp(System.currentTimeMillis());
              insertOrdChecklist.setOccurDate(timestamp);
              insertOrdChecklist.setRegDate(timestamp);
              insertOrdChecklist.setUpDate(timestamp);
              insertOrdChecklist.setFacilityCd(facilityCd);
              OrdChecklist.OrdChecklistRegCheckInfo regCheckInfo = new OrdChecklist.OrdChecklistRegCheckInfo();
              regCheckInfo.setChecklistCd(element.getRstChecklistInfo().getChecklistCd());
              regCheckInfo.setItemNumber(element.getRstChecklistInfo().getItemNumber());
              regCheckInfo.setClassCd(element.getRstChecklistInfo().getClassCd());
              regCheckInfo.setCode(null);
              regCheckInfo.setCodeUpdate(element.getRstChecklistInfo().getCodeUpdate());
              regCheckInfo.setName(null);
              // del 10310 needle _ typeの使用を削除するには gjn start
              //regCheckInfo.setNeedleType(element.getRstChecklistInfo().getNeedleType());
              // del 10310 needle _ typeの使用を削除するには gjn end
              regCheckInfo.setMedicineType(element.getRstChecklistInfo().getMedicineType());
              regCheckInfo.setAmount(element.getRstChecklistInfo().getAmount());
              regCheckInfo.setUnit(element.getRstChecklistInfo().getUnit());
              insertOrdChecklist.setRstChecklistInfo(regCheckInfo);
              //del 9324 ord_checklist共通之外的dao方法删除 gjn start
              //ordChecklistDao.insert(insertOrdChecklist);
              //del 9324 ord_checklist共通之外的dao方法删除 gjn end
            }
          }
        }
      }
    }
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public void updateCheckListEquipInfo(Long ordNo, TreatmentRecordEquipInfo treatmentRecordEquipInfo, String facilityCd) throws NotExistException, IOException {

    // add FNSI-改修内容追加OrdMain履歴 付 start
    selectHistoryUtils.insertMangoDbHistory(10, ordNo, null, new ArrayList<>(), new ArrayList<>(), null, null,
      null, null, null, new ArrayList<>(), new ArrayList<>(), null, null, null,
      new ArrayList<>(), null, null);
    // mangoDb-updateTreatmentRecordForEquipInfo-insertSuccess
    // add FNSI-改修内容追加OrdMain履歴 付 end

    treatmentRecordEquipInfo.setOrdNo(ordNo);
    // add 8277 周安寧 start
    NtssUser user = (NtssUser) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
    treatmentRecordEquipInfo.setLogUserId(user.getUserId().toString());
    // add 8277 周安寧 end
    // add FNSI-医療材料最新識別番号の設定 start
    if (!ObjectUtils.isEmpty(treatmentRecordEquipInfo.getRstEquipInfo()) && !("[]").equals(treatmentRecordEquipInfo.getRstEquipInfo())) {
      OrdMain ordMain = ordMainDao.selectByOrdNo(ordNo);
      ObjectMapper mapper = new ObjectMapper();
      mapper.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);
      long equipInfoNo = 1;
      List<ReceiveRstEquipInfoDto> tempRstEquipInfoDtos = mapper.readValue(treatmentRecordEquipInfo.getRstEquipInfo(), new TypeReference<List<ReceiveRstEquipInfoDto>>(){});
      for (ReceiveRstEquipInfoDto element : tempRstEquipInfoDtos) {
        String patId = null;
        if (ordMain.getPatId() != null) {
          patId = String.valueOf(ordMain.getPatId());
          if (element.getNo() == null || element.getNo().equals(0L)) {
            element.setNo(ordMainService.selectMaxEquipInfoNo(ordMain.getFacilityCd(), patId));
          }
        } else {
          element.setNo(equipInfoNo);
          equipInfoNo++;
        }
      }
      treatmentRecordEquipInfo.setRstEquipInfo(mapper.writeValueAsString(tempRstEquipInfoDtos));
    }
    // add FNSI-医療材料最新識別番号の設定 end
    final int updatedEquipInfoCount = recordDao.updateTreatmentRecordForEquipInfo(ordNo, treatmentRecordEquipInfo);
    //del 9324 治療記録-医療材料変更、既存の寄託論理コード削除 gjn start
    //ordChecklistEquipmentUpdate(ordNo, treatmentRecordEquipInfo, facilityCd);
    //del 9324 治療記録-医療材料変更、既存の寄託論理コード削除 gjn end
    if (updatedEquipInfoCount <= 0) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("There is no TreatmentRecordEquipInfo.");
      eventLogMessage.setSqlIdentification("(ordNo = "+ ordNo +", treatmentRecordEquipInfo = "+ treatmentRecordEquipInfo +")");
      logService.log(LogLevel.DEBUG, eventLogMessage,FUNCTION_CODE.FUNC_TREATMENT_RECORD,SERVICE_NAME.REMS, "RecordDao/updateTreatmentRecordForEquipInfo");
      throw new NotExistException("存在しない治療情報のオーダ番号を指定されています。");
    }
    //9480 治療記録（医療材料情報）の更新,実際の治療値パラメータの変更をトリガせず、計算インタフェースを注釈呼び出し、性能の浪費を避ける gjn start
    //add FNSI-redmine6060 fang start
    //webApiCallCommonUtil.doAutoCalculation(ordNo);
    // add FNSI-redmine6060 fang end
    //9480 治療記録（医療材料情報）の更新,実際の治療値パラメータの変更をトリガせず、計算インタフェースを注釈呼び出し、性能の浪費を避ける gjn end
    //9480 治療記録（医療材料情報）の更新,実際の治療値パラメータの変更をトリガせず、計算インタフェースを注釈呼び出し、性能の浪費を避ける gjn end
    //add #10196 Ord_Material_Save operation 20240126 ztc start
    // del 12250 ord_material_saveの処理を2回重複実行している zkm start
//    List<MaterialSaveCacheHandler.DiffResultContainer> diffMaterialSaveRstList = new ArrayList<>();
    // del 12250 ord_material_saveの処理を2回重複実行している zkm end
    //add #10196 Ord_Material_Save operation 20240126 ztc end
    // add #9845 愁訴処置に入力した薬剤がord_material_saveに登録されない start
    //mod #10196 Ord_Material_Save operation 20240126 ztc start
//    ordMaterialSaveService.updateOrdMaterialSave(new OrdMaterialSaveDto(
    // mod 12250 ord_material_saveの処理を2回重複実行している zkm start
//    MaterialSaveCacheHandler.DiffResultContainer diffMaterialSaveRst = ordMaterialSaveService.updateOrdMaterialSaveByDiff(new OrdMaterialSaveDto(
//      ordNo,
//      false,
//      false,
//      true,
//      false,
//      "2"
//    ));
//    // add #9845 愁訴処置に入力した薬剤がord_material_saveに登録されない end
//    diffMaterialSaveRstList.add(diffMaterialSaveRst);
//    if(diffMaterialSaveRstList.size() > 0){
//      ordMaterialSaveService.batchProcessingData(diffMaterialSaveRstList);
//    }
    ordMaterialSaveService.bulkUpdateByOrdNoInCondMediEquip(Collections.singletonList(ordNo));
    // mod 12250 ord_material_saveの処理を2回重複実行している zkm end
    //mod #10196 Ord_Material_Save operation 20240126 ztc end
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public void updateCheckListMediInfo(Long ordNo, TreatmentRecordMediInfo treatmentRecordMediInfo, String facilityCd) throws NotExistException, IOException {
    // add FNSI-改修内容追加OrdMain履歴 付 start
    selectHistoryUtils.insertMangoDbHistory(10, ordNo, null, new ArrayList<>(), new ArrayList<>(), null, null,
      null, null, null, new ArrayList<>(), new ArrayList<>(), null, null, null,
      new ArrayList<>(), null, null);
    // mangoDb-updateTreatmentRecordForMediInfo-insertSuccess
    // add FNSI-改修内容追加OrdMain履歴 付 end

    treatmentRecordMediInfo.setOrdNo(ordNo);
    // add 8277 周安寧 start
    NtssUser user = (NtssUser) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
    treatmentRecordMediInfo.setLogUserId(user.getUserId().toString());
    // add 8277 周安寧 end
    //add FNSI-投薬最新識別番号の設定 房 start
    /* modify by chamaojia 2024-04-02 [10196] add null judgment processing  --start */
//    if (!treatmentRecordMediInfo.getRstMediInfo().equals("[]")) {
    if (!ObjectUtils.isEmpty(treatmentRecordMediInfo.getRstMediInfo()) && !("[]").equals(treatmentRecordMediInfo.getRstMediInfo())) {
    /* modify by chamaojia 2024-04-02 [10196] add null judgment processing  --end */
      OrdMain ordMain = ordMainDao.selectByOrdNo(ordNo);
      /* modify by chamaojia 2024-01-31 [10196] Data object replacement, database storage to remove unnecessary content --start */
      ObjectMapper mapper = new ObjectMapper();
      mapper.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);
      long mediInfoNo = 1;
      List<RstMediInfoDto> tempRstMediInfoDtos = mapper.readValue(treatmentRecordMediInfo.getRstMediInfo(), new TypeReference<List<RstMediInfoDto>>(){});
      for (RstMediInfoDto element : tempRstMediInfoDtos) {
        String patId = null;
        if (ordMain.getPatId() != null) {
          patId = String.valueOf(ordMain.getPatId());
          if (element.getNo() == null || element.getNo().equals(0L)) {
            element.setNo(ordMainService.selectMaxMediInfoNo(ordMain.getFacilityCd(), patId));
          }
        } else {
          element.setNo(mediInfoNo);
          mediInfoNo++;
        }

        // FNSI-修正 #6443 実施済みの薬剤を未投与にすることができない、xugj del start
        //if (ordMain.getRstDialysisState().equals("3")) {
        // FNSI-修正 #6443 実施済みの薬剤を未投与にすることができない、xugj del end
        List<Integer> params = new ArrayList<>(Arrays.asList(new Integer[]{element.getCd()}));

        List<MstMedicine> mstMedicines = mstMedicineDao.selectAllByCdList(SelectOptions.get(), params);

        // FNSI-修正 #7650 画面バッグ発見、優先対応、xugj mod start
        List<MstMedicine> mstMedicineList = mstMedicines.stream().filter(el->(el.getClassCd() != null && el.getClassCd().equals(element.getClassCd()))).collect(Collectors.toList());
        // FNSI-修正 #7650 画面バッグ発見、優先対応、xugj mod end

        if (mstMedicineList != null && mstMedicineList.size() > 0) {
          //add 10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhao start
          StringBuilder sb = new StringBuilder("0");
          Integer decimalPoint = mstMedicineList.get(0).getUnitDecimalPoint();
          if(decimalPoint > 0) {
            sb.append(".");
            for(int i = 0; i < decimalPoint; i++) {
              sb.append(0);
            }
          }
          DecimalFormat df = new DecimalFormat(sb.toString());
          String amount = df.format(Double.parseDouble(element.getAmount()));
          element.setAmount(amount);
          //add 10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhao end
        }
        // FNSI-修正 #6443 実施済みの薬剤を未投与にすることができない、xugj del start
        //}
        // FNSI-修正 #6443 実施済みの薬剤を未投与にすることができない、xugj del end
        //add FNSI-redmine5640 fang start
        if ("3".equals(ordMain.getRstDialysisState())) {
          if (element.getEffectFlg() == null || (element.getEffectFlg() != null && "0".equals(element.getEffectFlg()))) {
            MstMedicateTiming mstMedicateTiming = mstMedicateTimingDao.selectByCd(facilityCd, element.getTimingCd());
            if (mstMedicateTiming != null && "1".equals(mstMedicateTiming.getIsAlert())) {
              if (mstMedicateTiming.getDialysisProgressCd() != null && "001".equals(mstMedicateTiming.getDialysisProgressCd())) {
                PatPersonalMain patPersonalMain = patPersonalMainDao.selectById(ordMain.getPatId());
                //mod 薬剤マスターだけではない、調剤も検索範囲 劉祥霖 start
                String medicineName=element.getName();
                if("".equals(medicineName)||medicineName==null||"null".equals(medicineName)){
                  Integer cd = element.getCd();
                  Integer medicineType = element.getMedicineType().intValue();
                    //取得したコードを元に薬剤情報から名称を取得(DBから)
                    if (cd != null && medicineType != null) {
                      Map<String, Object> mediMap = dBAppWebAPIDao.selectMedicineInfo(
                        facilityCd,
                        medicineType,
                        cd
                      );
                      medicineName = mediMap.containsKey("name") ? mediMap.get("name").toString() : "";
                  }
                }
//                MstMedicine mstMedicine = mstMedicineDao.selectByCd(facilityCd, element.getCd());
                //mod 薬剤マスターだけではない、調剤も検索範囲 劉祥霖 end
                JSONObject replaceData = new JSONObject();
                replaceData.put("BEDNAME", ordMain.getRstBedName());
                replaceData.put("LASTNAME", patPersonalMain.getPat_last_name());
                replaceData.put("FIRSTNAME", patPersonalMain.getPat_first_name());
                replaceData.put("ORDNO", String.valueOf(ordNo));
                //mod FNSI redmine 6706 劉祥霖　start
                replaceData.put("PATID",  ordMain.getPatId().toString());
//              replaceData.put("PATID",  ordMain.getPatId());
                //mod FNSI redmine 6706 劉祥霖　end
                replaceData.put("FACILITYCD", facilityCd);
                //mod 薬剤マスターだけではない、調剤も検索範囲 劉祥霖 start
                replaceData.put("MEDICINENAME", medicineName);
//              replaceData.put("MEDICINENAME", mstMedicine.getMedicineName());
                //mod 薬剤マスターだけではない、調剤も検索範囲 劉祥霖 end
                try {
                  webApiCallCommonUtil.registerNotification(CoreConstant.NotificationDefinition.MEDICINE_TYMING, facilityCd, replaceData);
                } catch (URISyntaxException e) {
                  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
                  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
                  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
                  EventLogMessage eventLogMessage = new EventLogMessage();
                  eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
                  if (!StringUtils.isEmpty(facilityCd)) {
                    eventLogMessage.setFacilityCd(facilityCd);
                  }
                  logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
                  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
                }
              } else if (mstMedicateTiming.getDialysisProgressCd() != null && "002".equals(mstMedicateTiming.getDialysisProgressCd())) {
                if (mstMedicateTiming.getAlertTime() != null) {
                  if (ordMain.getRstStartDate() != null) {
                    long addAlertTime = mstMedicateTiming.getAlertTime() * 60 * 1000;
                    long compareTime = ordMain.getRstStartDate().getTime() + addAlertTime;
                    if (System.currentTimeMillis() > compareTime) {
                      PatPersonalMain patPersonalMain = patPersonalMainDao.selectById(ordMain.getPatId());
                      //mod 薬剤マスターだけではない、調剤も検索範囲 劉祥霖 start
                      String medicineName=element.getName();
                      if("".equals(medicineName)||medicineName==null||"null".equals(medicineName)){
                        Integer cd = element.getCd();
                        Integer medicineType = element.getMedicineType().intValue();
                        //取得したコードを元に薬剤情報から名称を取得(DBから)
                        if (cd != null && medicineType != null) {
                          Map<String, Object> mediMap = dBAppWebAPIDao.selectMedicineInfo(
                            facilityCd,
                            medicineType,
                            cd
                          );
                          medicineName = mediMap.containsKey("name") ? mediMap.get("name").toString() : "";
                        }
                      }
//                MstMedicine mstMedicine = mstMedicineDao.selectByCd(facilityCd, element.getCd());
                      //mod 薬剤マスターだけではない、調剤も検索範囲 劉祥霖　end
                      JSONObject replaceData = new JSONObject();
                      replaceData.put("BEDNAME", ordMain.getRstBedName());
                      replaceData.put("LASTNAME", patPersonalMain.getPat_last_name());
                      replaceData.put("FIRSTNAME", patPersonalMain.getPat_first_name());
                      replaceData.put("ORDNO", String.valueOf(ordNo));
                      //mod FNSI redmine 6706 劉祥霖　start
                      replaceData.put("PATID",  ordMain.getPatId().toString());
//              replaceData.put("PATID",  ordMain.getPatId());
                      //mod FNSI redmine 6706 劉祥霖　end
                      replaceData.put("FACILITYCD", facilityCd);
                      //mod 薬剤マスターだけではない、調剤も検索範囲 劉祥霖 start
                      replaceData.put("MEDICINENAME", medicineName);
//              replaceData.put("MEDICINENAME", mstMedicine.getMedicineName());
                      //mod 薬剤マスターだけではない、調剤も検索範囲 劉祥霖 end
                      try {
                        webApiCallCommonUtil.registerNotification(CoreConstant.NotificationDefinition.MEDICINE_TYMING, facilityCd, replaceData);
                      } catch (URISyntaxException e) {
                        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
                        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
                        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
                        EventLogMessage eventLogMessage = new EventLogMessage();
                        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
                        if (!StringUtils.isEmpty(facilityCd)) {
                          eventLogMessage.setFacilityCd(facilityCd);
                        }
                        logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
                        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
                      }
                    }
                  }
                }
              }
            }
          }
        }
        //add FNSI-redmine5640 fang end
      }
      treatmentRecordMediInfo.setRstMediInfo(mapper.writeValueAsString(tempRstMediInfoDtos));
      /* modify by chamaojia 2024-01-31 [10196] Data object replacement, database storage to remove unnecessary content --end */
    }
    //add FNSI-投薬最新識別番号の設定 房 end
    final int updatedMediInfoCount = recordDao.updateTreatmentRecordForMediInfo(ordNo, treatmentRecordMediInfo);

    //del 9324 治療記録投与と薬剤変更元の変更ord_checklistコードを削除 gjn start
    //ordChecklistMediInfoUpdate(ordNo, treatmentRecordMediInfo, facilityCd);
    //del 9324 治療記録投与と薬剤変更元の変更ord_checklistコードを削除 gjn end

    if (updatedMediInfoCount <= 0) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("There is no TreatmentRecordMediInfo.");
      eventLogMessage.setSqlIdentification("(ordNo = "+ ordNo +", treatmentRecordMediInfo = "+ treatmentRecordMediInfo +")");
      logService.log(LogLevel.DEBUG, eventLogMessage,FUNCTION_CODE.FUNC_TREATMENT_RECORD,SERVICE_NAME.REMS, "RecordDao/updateTreatmentRecordForMediInfo");
      throw new NotExistException("存在しない治療情報のオーダ番号を指定されています。");
    }
    //9480 治療記録（投与薬剤情報）の更新,実際の治療値パラメータの変更をトリガせず、計算インタフェースを注釈呼び出し、性能の浪費を避ける gjn start
    //add FNSI-redmine6060 fang start
    //webApiCallCommonUtil.doAutoCalculation(ordNo);
    // add FNSI-redmine6060 fang end
    //9480 治療記録（投与薬剤情報）の更新,実際の治療値パラメータの変更をトリガせず、計算インタフェースを注釈呼び出し、性能の浪費を避ける gjn end
    // add #9845 愁訴処置に入力した薬剤がord_material_saveに登録されない start
    //mod #10196 Ord_Material_Save operation 20240126 ztc start
    // add #9845 愁訴処置に入力した薬剤がord_material_saveに登録されない end
    // mod #12250 ord_material_saveの処理を2回重複実行している zkm start
//    ordMaterialSaveService.batchProcessingData(
//      Collections.singletonList(
//        ordMaterialSaveService.updateOrdMaterialSaveByDiff(
//          new OrdMaterialSaveDto(
//            ordNo, false, true, false, false,
//            OrdMaterialSaveDto.RST_CLASS)
//        )
//      )
//    );
    ordMaterialSaveService.bulkUpdateByOrdNoInCondMediEquip(Collections.singletonList(ordNo));
    // mod #12250 ord_material_saveの処理を2回重複実行している zkm end
    //mod #10196 Ord_Material_Save operation 20240126 ztc end
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public void updateTreatmentRecordCondition(Long ordNo, TreatmentRecordCondition treatmentRecordCondition, String facilityCd) throws NotExistException, InvocationTargetException, NoSuchMethodException, IllegalAccessException, IOException {
    treatmentRecordCondition.setOrdNo(ordNo);
//    add 8074 【デグレ】ログに誤った利用者が記録される 関 start
    NtssUser user = (NtssUser) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
    treatmentRecordCondition.setLogUserId(user.getUserId().toString());
//    add 8074 【デグレ】ログに誤った利用者が記録される 関  end
    // add FNSI-改修内容追加OrdMain履歴 付 start
    selectHistoryUtils.insertMangoDbHistory(10, ordNo, null, new ArrayList<>(), new ArrayList<>(), null, null,
      null, null, null, new ArrayList<>(), new ArrayList<>(), null, null, null,
      new ArrayList<>(), null, null);
    // mangoDb-updateTreatmentRecordForCondition-insertSuccess
    // add FNSI-改修内容追加OrdMain履歴 付 end

    /* modify by shiyw 2024-03-19 [10196] Name and unit supplement and modification --start */
    // Treatment conditions JSON content processing
    JSONObject rstCondInfoJsonObject = new JSONObject(treatmentRecordCondition.getRstCondInfo());
    // del 10824 治療記録>治療条件を編集するとord_mainのrst_cond_infの一部がnullになる 関 start
    /* for(String key: rstCondInfoJsonObject.keySet()) {
      JSONObject currentNodeObj = rstCondInfoJsonObject.getJSONObject(key);
      if (currentNodeObj.isNull("value")) {
        int itemCode = Integer.parseInt(key);
        Optional.ofNullable(TreatmentItemsDef.getTreatmentItemByCode(key)).ifPresent(item->{
          String realName = item.getRealName(key,
                  facilityCd,
                  currentNodeObj.isNull("value")?null:currentNodeObj.get("value").toString(),
                  currentNodeObj.isNull("medicine_type")?null: currentNodeObj.getInt("medicine_type"));
          currentNodeObj.put("value_name_1",realName);
          int dataSourceItemCode = itemCode;
          switch (itemCode) {
            case 17: // 透析液使用数,unitはkey 15に由来する
              dataSourceItemCode = 15;
            break;
            case 22: // 補液使用数,unitはkey 19に由来する
              dataSourceItemCode = 19;
            break;
            case 26: // ワンショット量,unitはkey 25に由来する
            case 27: // 持続速度,unitはkey 25に由来する
            case 28: // 持続総量,unitはkey 25に由来する
              dataSourceItemCode = 25;
            break;
          default:
            break;
        }
          if (dataSourceItemCode == itemCode) {
            String realUnit = item.getRealUnit(String.valueOf(dataSourceItemCode),
                    facilityCd,
                    currentNodeObj.isNull("value")?null:currentNodeObj.get("value").toString(),
                    currentNodeObj.isNull("medicine_type")?null: currentNodeObj.getInt("medicine_type"));
            currentNodeObj.put("unit",realUnit);
          } else {
            if (rstCondInfoJsonObject.has(String.valueOf(dataSourceItemCode))) {
              JSONObject dataSourceJObj = rstCondInfoJsonObject.getJSONObject(String.valueOf(dataSourceItemCode));
              String realUnit = item.getRealUnit(String.valueOf(dataSourceItemCode),
                      facilityCd,
                      dataSourceJObj.isNull("value")?null:dataSourceJObj.get("value").toString(),
                      dataSourceJObj.isNull("medicine_type")?null: dataSourceJObj.getInt("medicine_type"));
              currentNodeObj.put("unit",realUnit);
            } else {
              currentNodeObj.remove("unit");
        }
      }
        });
      }
    }*/
    // del 10824 治療記録>治療条件を編集するとord_mainのrst_cond_infの一部がnullになる 関 end
    // Reset the processed data
    treatmentRecordCondition.setRstCondInfo(rstCondInfoJsonObject.toString());
    /* modify by shiyw 2024-03-19 [10196] Name and unit supplement and modification --end */

    //del 9324 治疗记录-治疗条件变更，原有变更ord_checklist寄存代码删除 gjn start
    //treatmentRecordConditionHandle(ordNo, treatmentRecordCondition, facilityCd);
    //del 9324 治疗记录-治疗条件变更，原有变更ord_checklist寄存代码删除 gjn end

    final int updatedConditionCount = recordDao.updateTreatmentRecordForCondition(ordNo, treatmentRecordCondition);

    if(updatedConditionCount <= 0) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("There is no TreatmentRecordCondition.");
      eventLogMessage.setSqlIdentification("(ordNo = "+ ordNo +", treatmentRecordCondition = "+ treatmentRecordCondition +")");
      logService.log(LogLevel.DEBUG, eventLogMessage,FUNCTION_CODE.FUNC_TREATMENT_RECORD,SERVICE_NAME.REMS, "RecordDao/updateTreatmentRecordForCondition");
      throw new NotExistException("存在しない治療情報のオーダ番号を指定されています。");
    }
    //del 9480 治療記録（治療条件）の更新,実際の治療値パラメータの変更をトリガせず、計算インタフェースを注釈呼び出し、性能の浪費を避ける gjn start
    //add FNSI-redmine6060 fang start
    //webApiCallCommonUtil.doAutoCalculation(ordNo);
    // add FNSI-redmine6060 fang end
    //del 9480 治療記録（治療条件）の更新,実際の治療値パラメータの変更をトリガせず、計算インタフェースを注釈呼び出し、性能の浪費を避ける gjn end
    // add #7660 2022/08/22 【デグレ】実績確定するまでの間は治療記録用紙に表示されない項目がある。 王永吉 start
    OrdMain ordMain = ordMainDao.selectByOrdNo(ordNo);
    // mod #7660 2022/08/24 【デグレ】実績確定するまでの間は治療記録用紙に表示されない項目がある。 王永吉 start
    // treatmentStatusListService.MiddleCheck(ordMain);
    treatmentStatusListService.middleCheck(ordMain);
    // mod #7660 2022/08/24 【デグレ】実績確定するまでの間は治療記録用紙に表示されない項目がある。 王永吉 end
    // add #7660 2022/08/22 【デグレ】実績確定するまでの間は治療記録用紙に表示されない項目がある。 王永吉 end
  }

  private void  treatmentRecordConditionHandle(Long ordNo, TreatmentRecordCondition treatmentRecordCondition, String facilityCd) throws NoSuchMethodException, IOException, IllegalAccessException, InvocationTargetException {
    OrdMain ordMain = ordMainDao.selectByOrdNo(ordNo);
    List<TreatmentRecordConditionSubInfo> dataBaseInfo = editTreatmentRecordConditionInfo(ordMain.getRstCondInfo());
    List<TreatmentRecordConditionSubInfo> browserInfo = editTreatmentRecordConditionInfo(treatmentRecordCondition.getRstCondInfo());
    boolean mediFlag1 = false;
    boolean mediFlag2 = false;
    boolean mediFlag3 = false;
    for (int i = 1; i <= 38; i++) {
      boolean editFlag = false;
      // add #9973 Resolve null exception for key 20240110 ztc start
      if(dataBaseInfo != null){
      // add #9973 Resolve null exception for key 20240110 ztc end
        if (dataBaseInfo.get(i-1) != null
          && browserInfo.get(i-1) != null
          && dataBaseInfo.get(i-1).getValue() != null && browserInfo.get(i-1).getValue() != null
          && !dataBaseInfo.get(i-1).getValue().equals(browserInfo.get(i-1).getValue())) {
          editFlag = true;
        } else if ((dataBaseInfo.get(i-1) != null && dataBaseInfo.get(i-1).getValue() != null
          /* modify by chamaojia 2023-11-23 [9973] 判定順序エラー修正  --start */
          && (browserInfo.get(i-1) == null || browserInfo.get(i-1).getValue() == null))
          /* modify by chamaojia 2023-11-23 [9973] 判定順序エラー修正  --end */
          || ((dataBaseInfo.get(i-1) == null || dataBaseInfo.get(i-1).getValue() == null)
          && browserInfo.get(i-1) != null && browserInfo.get(i-1).getValue() != null)) {
          editFlag = true;
        }
      }
      if ((i == 5 || i == 7 || i == 8) && editFlag) {
        //editOrdCheckList(browserInfo.get(i-1), ordNo, facilityCd, "1", i, "");
      }
      if ((i == 13 || i == 9 || i == 10 || i == 11 || i == 6) && editFlag) {
        //editOrdCheckList(browserInfo.get(i-1),ordNo, facilityCd,"2", i, "");
      }
      if (i >= 15 && i <= 18 && editFlag) {
        mediFlag1 = true;
      } else if (i >= 19 && i <= 24 && editFlag) {
        mediFlag2 = true;
      } else if (i >= 25 && i <= 38 && editFlag) {
        mediFlag3 = true;
      }
    }
    if (mediFlag1) {
      String value = "";
      // mod 9342 治療記録の治療条件で無効項目が編集不可となった。　吉 start
      // if (browserInfo.get(17).getValue() != null) {
      if (null != browserInfo.get(17) && browserInfo.get(17).getValue() != null) {
        // mod 9342 治療記録の治療条件で無効項目が編集不可となった。　吉 end
        value = String.valueOf(browserInfo.get(17).getValue());
      }
      //editOrdCheckList(browserInfo.get(15), ordNo, facilityCd,"3", 15, value);
    }
    if (mediFlag2) {
      String value = "";
      //mod 8315 ord_material_save.supplies_cd, supplies_class_medicine_mix_cdの登録・更新不正 周安寧 start
      //if (browserInfo.get(17).getValue() != null) {
      // mod 9342 治療記録の治療条件で無効項目が編集不可となった。　吉 start
      // if (browserInfo.get(17).getValue() != null && browserInfo.get(22) != null) {
      if (null != browserInfo.get(17) &&  browserInfo.get(17).getValue() != null && browserInfo.get(22) != null) {
        // mod 9342 治療記録の治療条件で無効項目が編集不可となった。　吉 end
      //mod 8315 ord_material_save.supplies_cd, supplies_class_medicine_mix_cdの登録・更新不正 周安寧 end
        value = String.valueOf(browserInfo.get(22).getValue());
      }
      //editOrdCheckList(browserInfo.get(19), ordNo, facilityCd,"3", 19, value);
    }
    if (mediFlag3) {
      BigDecimal value1 = new BigDecimal("0");
      BigDecimal value2 = new BigDecimal("0");
      // 抗凝固剤ワンショット量
      // mod 9342 治療記録の治療条件で無効項目が編集不可となった。　吉 start
      // if (browserInfo.get(25).getValue() != null) {
      if (null != browserInfo.get(25) && browserInfo.get(25).getValue() != null) {
        // mod 9342 治療記録の治療条件で無効項目が編集不可となった。　吉 end
        value1 = browserInfo.get(25).getValue();
      }
      // 抗凝固剤持続総量
      // mod 9342 治療記録の治療条件で無効項目が編集不可となった。　吉 start
      // if (browserInfo.get(27).getValue() != null) {
      if (null != browserInfo.get(27) && browserInfo.get(27).getValue() != null) {
        // mod 9342 治療記録の治療条件で無効項目が編集不可となった。　吉 end
        value2 = browserInfo.get(27).getValue();
      }
      // 抗凝固剤
      if (value1.add(value2).compareTo(BigDecimal.ZERO) != 0) {
        //editOrdCheckList(browserInfo.get(24), ordNo, facilityCd,"3", 25, String.valueOf(value1.add(value2)));
      }
    }
    Map<Integer, TreatmentRecordConditionSubInfo> deleteMap = new HashMap<>();
    deleteMap.put(5, browserInfo.get(4));
    deleteMap.put(7, browserInfo.get(6));
    deleteMap.put(8, browserInfo.get(7));
    deleteMap.put(6, browserInfo.get(5));
    deleteMap.put(9, browserInfo.get(8));
    deleteMap.put(10, browserInfo.get(9));
    deleteMap.put(11, browserInfo.get(10));
    deleteMap.put(13, browserInfo.get(12));
    deleteMap.put(15, browserInfo.get(14));
    deleteMap.put(19, browserInfo.get(18));
    deleteMap.put(25, browserInfo.get(24));
    //deleteOrdCheckListByCondition(ordNo, deleteMap, facilityCd);
  }

  private void deleteOrdCheckListByCondition(Long ordNo, Map<Integer, TreatmentRecordConditionSubInfo> mergeMap, String facilityCd){
    List<OrdChecklist> resultChecklists = ordChecklistDao.selectByOrdNo(SelectOptions.get(), ordNo);
    if (resultChecklists != null && resultChecklists.size() > 0) {
      final List<OrdChecklist> ordChecklists = resultChecklists.stream().filter(x->x.getFuncClass() == 1).collect(Collectors.toList());
      if (ordChecklists != null && ordChecklists.size() > 0) {
        //データ削除
        for (int i = ordChecklists.size() - 1; i >= 0; i--) {
          boolean haveFlag = false;
          OrdChecklist element = ordChecklists.get(i);
          if (element.getRstClass() != 9) {
            for (Map.Entry<Integer, TreatmentRecordConditionSubInfo> entity : mergeMap.entrySet()) {
              /* modify by chamaojia 2023-10-27 [9973] NULL値が存在する場合は、判断条件を追加する必要がある --start */
              if (entity.getKey().equals(element.getRstChecklistInfo().getClassCd()) && entity.getValue() != null) {
              /* modify by chamaojia 2023-10-27 [9973] NULL値が存在する場合は、判断条件を追加する必要がある --end */
                if (element.getRstChecklistInfo().getCode() == null && entity.getValue().getValue() == null) {
                  haveFlag = true;
                }
                if (element.getRstChecklistInfo().getCode() != null && entity.getValue().getValue() != null
                  && element.getRstChecklistInfo().getCode().equals(entity.getValue().getValue().intValue())) {
                  haveFlag = true;
                }
              }
            }
            if (haveFlag) {
              continue;
            } else {
              //del 9324 ord_checklist共通之外的dao方法删除 gjn start
              //ordChecklistDao.deleteByCheckListCtlNo(element.getChecklistCtlNo());
              //del 9324 ord_checklist共通之外的dao方法删除 gjn end
            }
            ordChecklists.remove(element);
            List<OrdChecklist> countList = ordChecklists.stream().filter(x->x.getRstChecklistInfo().getClassCd() != null
              && element.getRstChecklistInfo().getClassCd() != null
              && x.getRstChecklistInfo().getClassCd().equals(element.getRstChecklistInfo().getClassCd())
              && x.getListCd() == element.getListCd()).collect(Collectors.toList());
            if (countList == null || countList.size() == 0) {
              OrdChecklist insertOrdChecklist = new OrdChecklist();
              insertOrdChecklist.setOrdNo(element.getOrdNo());
              insertOrdChecklist.setRstClass((short) 9);
              insertOrdChecklist.setIsCheck("0");
              insertOrdChecklist.setListCd(element.getListCd());
              insertOrdChecklist.setFuncClass(element.getFuncClass());
              insertOrdChecklist.setRegStaffInfo(element.getRegStaffInfo());
              insertOrdChecklist.setIsDisp(element.getIsDisp());
              insertOrdChecklist.setIsDel(element.getIsDel());
              Timestamp timestamp = new Timestamp(System.currentTimeMillis());
              insertOrdChecklist.setOccurDate(timestamp);
              insertOrdChecklist.setRegDate(timestamp);
              insertOrdChecklist.setUpDate(timestamp);
              insertOrdChecklist.setFacilityCd(facilityCd);
              OrdChecklist.OrdChecklistRegCheckInfo regCheckInfo = new OrdChecklist.OrdChecklistRegCheckInfo();
              regCheckInfo.setChecklistCd(element.getRstChecklistInfo().getChecklistCd());
              regCheckInfo.setItemNumber(element.getRstChecklistInfo().getItemNumber());
              regCheckInfo.setClassCd(element.getRstChecklistInfo().getClassCd());
              regCheckInfo.setCode(null);
              regCheckInfo.setCodeUpdate(element.getRstChecklistInfo().getCodeUpdate());
              regCheckInfo.setName(null);
              // del 10310 needle _ typeの使用を削除するには gjn start
              //regCheckInfo.setNeedleType(element.getRstChecklistInfo().getNeedleType());
              // del 10310 needle _ typeの使用を削除するには gjn end
              regCheckInfo.setMedicineType(element.getRstChecklistInfo().getMedicineType());
              regCheckInfo.setAmount(element.getRstChecklistInfo().getAmount());
              regCheckInfo.setUnit(element.getRstChecklistInfo().getUnit());
              insertOrdChecklist.setRstChecklistInfo(regCheckInfo);
              //del 9324 ord_checklist共通之外的dao方法删除 gjn start
              //ordChecklistDao.insert(insertOrdChecklist);
              //del 9324 ord_checklist共通之外的dao方法删除 gjn end
            }
          }
        }
      }
    }
  }

  private void editOrdCheckList(TreatmentRecordConditionSubInfo treatmentRecordCondition, Long ordNo, String facilityCd, String flag, Integer classCd, String amount){
    //mod 8315 ord_material_save.supplies_cd, supplies_class_medicine_mix_cdの登録・更新不正 周安寧 start
    //if (treatmentRecordCondition.getValue() != null) {
    if (treatmentRecordCondition != null && treatmentRecordCondition.getValue() != null) {
    //mod 8315 ord_material_save.supplies_cd, supplies_class_medicine_mix_cdの登録・更新不正 周安寧 end
      List<OrdChecklist> resultChecklists = ordChecklistDao.selectByOrdNo(SelectOptions.get(), ordNo);
      if (resultChecklists != null && resultChecklists.size() > 0) {
        final List<OrdChecklist> ordChecklists = resultChecklists.stream().filter(x->x.getFuncClass() == 1).collect(Collectors.toList());
        if (ordChecklists != null && ordChecklists.size() > 0) {
          List<OrdChecklist> tempList = ordChecklists.stream().filter(x->{
            if (x.getRstChecklistInfo().getClassCd() != null
              && x.getRstChecklistInfo().getClassCd().equals(classCd)
              && x.getRstChecklistInfo().getCode() != null
              && x.getRstChecklistInfo().getCode().equals(treatmentRecordCondition.getValue().intValue())) {
              if (flag.equals("3")) {
                if (x.getRstChecklistInfo().getMedicineType() != null
                  && x.getRstChecklistInfo().getMedicineType().equals(treatmentRecordCondition.getMedicineType())) {
                  return true;
                }
              } else {
                return true;
              }
            }
            return false;
          }).collect(Collectors.toList());
          if (tempList != null && tempList.size() > 0) {
            //実績区分が9以外の場合
            if (tempList.get(0).getRstClass() != 9) {
              for (OrdChecklist ordChecklist : tempList) {
                ordChecklist.setIsCheck("0");
                ordChecklist.getRstChecklistInfo().setCode(treatmentRecordCondition.getValue().intValue());
                ordChecklist.getRstChecklistInfo().setCodeUpdate(null);
                ordChecklist.getRstChecklistInfo().setName(treatmentRecordCondition.getValueName1());
                // del 10310 needle _ typeの使用を削除するには gjn start
//                if (classCd == 9) {
//                  ordChecklist.getRstChecklistInfo().setNeedleType((short) 1);
//                } else if (classCd == 10) {
//                  ordChecklist.getRstChecklistInfo().setNeedleType((short) 2);
//                } else if (classCd == 11) {
//                  ordChecklist.getRstChecklistInfo().setNeedleType((short) 3);
//                } else {
//                  ordChecklist.getRstChecklistInfo().setNeedleType(null);
//                }
                // del 10310 needle _ typeの使用を削除するには gjn end
                if ("3".equals(flag)) {
                  ordChecklist.getRstChecklistInfo().setMedicineType(treatmentRecordCondition.getMedicineType());
                  ordChecklist.getRstChecklistInfo().setAmount(amount);
                } else {
                  ordChecklist.getRstChecklistInfo().setMedicineType(null);
                  ordChecklist.getRstChecklistInfo().setAmount("1");
                }
                if ("1".equals(flag)) {
                  ordChecklist.getRstChecklistInfo().setUnit("本");
                } else {
                  ordChecklist.getRstChecklistInfo().setUnit(treatmentRecordCondition.getUnit());
                }
                // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
                // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
                LogEventUtils.setOperatorId(ordChecklist,logService);
                // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
                // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
                //del 9324 ord_checklist共通之外的dao方法删除 gjn start
                //ordChecklistDao.update(ordChecklist);
                //del 9324 ord_checklist共通之外的dao方法删除 gjn end
              }
              tempList = null;
            } else {
              //実績区分が９の場合
              for (OrdChecklist ordChecklist : tempList) {
                //実績区分が9のデータを削除する。
                //del 9324 ord_checklist共通之外的dao方法删除 gjn start
                //ordChecklistDao.deleteByCheckListCtlNo(ordChecklist.getChecklistCtlNo());
                //del 9324 ord_checklist共通之外的dao方法删除 gjn end
              }
            }
          } else {
            //ClassCd一致だけの場合
            tempList = ordChecklists.stream().filter(x->{
              if (x.getRstChecklistInfo().getClassCd() != null
                && x.getRstChecklistInfo().getClassCd().equals(classCd)) {
                return true;
              }
              return false;
            }).collect(Collectors.toList());
            if (tempList != null && tempList.size() > 0) {
              if (tempList.get(0).getRstClass() != 9) {
                Integer otherClassCd = tempList.get(0).getRstChecklistInfo().getClassCd();
                Integer code = tempList.get(0).getRstChecklistInfo().getCode();
                tempList = tempList.stream().filter(x->{
                  if (x.getRstChecklistInfo().getClassCd().equals(otherClassCd)) {
                    if (x.getRstChecklistInfo().getCode() == null && code == null) {
                      return true;
                    }
                    if (x.getRstChecklistInfo().getCode() != null && code != null
                      && x.getRstChecklistInfo().getCode().equals(code)) {
                      return true;
                    }
                  }
                  return false;
                }).collect(Collectors.toList());
              } else {
                for (OrdChecklist ordChecklist : tempList) {
                  //del 9324 ord_checklist共通之外的dao方法删除 gjn start
                  //ordChecklistDao.deleteByCheckListCtlNo(ordChecklist.getChecklistCtlNo());
                  //del 9324 ord_checklist共通之外的dao方法删除 gjn end
                }
              }
            }
          }
          if (tempList != null && tempList.size() > 0) {
            for (OrdChecklist ordChecklist : tempList) {
              OrdChecklist insertOrdChecklist = new OrdChecklist();
              insertOrdChecklist.setOrdNo(ordChecklist.getOrdNo());
              insertOrdChecklist.setRstClass((short) 1);
              insertOrdChecklist.setIsCheck("0");
              insertOrdChecklist.setListCd(ordChecklist.getListCd());
              insertOrdChecklist.setFuncClass(ordChecklist.getFuncClass());
              insertOrdChecklist.setRegStaffInfo(ordChecklist.getRegStaffInfo());
              insertOrdChecklist.setIsDisp(ordChecklist.getIsDisp());
              insertOrdChecklist.setIsDel(ordChecklist.getIsDel());
              Timestamp timestamp = new Timestamp(System.currentTimeMillis());
              insertOrdChecklist.setOccurDate(timestamp);
              insertOrdChecklist.setRegDate(timestamp);
              insertOrdChecklist.setUpDate(timestamp);
              insertOrdChecklist.setFacilityCd(facilityCd);
              OrdChecklist.OrdChecklistRegCheckInfo regCheckInfo = new OrdChecklist.OrdChecklistRegCheckInfo();
              regCheckInfo.setChecklistCd(ordChecklist.getRstChecklistInfo().getChecklistCd());
              regCheckInfo.setItemNumber(ordChecklist.getRstChecklistInfo().getItemNumber());
              regCheckInfo.setClassCd(classCd);
              regCheckInfo.setCode(treatmentRecordCondition.getValue().intValue());
              regCheckInfo.setCodeUpdate(null);
              regCheckInfo.setName(treatmentRecordCondition.getValueName1());
              // del 10310 needle _ typeの使用を削除するには gjn start
//              if (classCd == 9) {
//                regCheckInfo.setNeedleType((short) 1);
//              } else if (classCd == 10) {
//                regCheckInfo.setNeedleType((short) 2);
//              } else if (classCd == 11) {
//                regCheckInfo.setNeedleType((short) 3);
//              } else {
//                regCheckInfo.setNeedleType(null);
//              }
              // del 10310 needle _ typeの使用を削除するには gjn end
              if ("3".equals(flag)) {
                regCheckInfo.setMedicineType(treatmentRecordCondition.getMedicineType());
                regCheckInfo.setAmount(amount);
              } else {
                regCheckInfo.setMedicineType(null);
                regCheckInfo.setAmount("1");
              }
              if ("1".equals(flag)) {
                regCheckInfo.setUnit("本");
              } else {
                regCheckInfo.setUnit(treatmentRecordCondition.getUnit());
              }
              insertOrdChecklist.setRstChecklistInfo(regCheckInfo);
              //del 9324 ord_checklist共通之外的dao方法删除 gjn start
              //ordChecklistDao.insert(insertOrdChecklist);
              //del 9324 ord_checklist共通之外的dao方法删除 gjn end
            }
          }
        }
      }
    }
  }

  private List<TreatmentRecordConditionSubInfo> editTreatmentRecordConditionInfo(String info) throws InvocationTargetException, NoSuchMethodException, IllegalAccessException, IOException {
    ObjectMapper mapper = new ObjectMapper();
    List<TreatmentRecordConditionSubInfo> treatmentRecordConditionSubInfos = null;
    try {
      TreatmentRecordConditionKeyAnalyze treatmentRecordConditionKeyAnalyze = null;
      if (info != null) {
        treatmentRecordConditionKeyAnalyze = mapper.readValue(info, new TypeReference<TreatmentRecordConditionKeyAnalyze>(){});
      } else {
        treatmentRecordConditionKeyAnalyze = new TreatmentRecordConditionKeyAnalyze();
      }

      Class<?> treatmentClass = TreatmentRecordConditionKeyAnalyze.class;
      treatmentRecordConditionSubInfos = new ArrayList<TreatmentRecordConditionSubInfo>();
      for (int i = 1; i <= 38; i++) {
        Method method = treatmentClass.getDeclaredMethod("getKey" + i);
        method.setAccessible(true);
        TreatmentRecordConditionSubInfo tempTreatmentRecordConditionSubInfo = (TreatmentRecordConditionSubInfo)method.invoke(treatmentRecordConditionKeyAnalyze);
        treatmentRecordConditionSubInfos.add(tempTreatmentRecordConditionSubInfo);
      }
    } catch (Exception e) {
      throw e;
    }
    return treatmentRecordConditionSubInfos;
  }
  //add FNSI修正401対応 房 end

  // DB更新ログ出力ロジック wangzuo Start
  /**
   * ログ情報設定
   * @return eventLogMessage
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

    // サービス名
    eventLogMessage.setServiceName(LoggingConstant.MODULE_NAME.ADMIN_WEB + "," + SERVICE_NAME.FNSI);
    return   eventLogMessage;
  }

  /**
   * ログ出力共通クラス設定、取得
   * @return logCommon ログ出力共通クラス
   */
  private DataUpdateLogCommonNew getLogCommon(Object dao, String tableName, StringBuffer whereStr, EventLogMessage eventLogMessage) {
    DataUpdateLogCommonNew logCommon = new DataUpdateLogCommonNew();
    logCommon.setEventLoggerFactory(eventLoggerFactory);
    logCommon.setLogServiceCore(logServiceCore);
    logCommon.setConfig(Config.get(dao));
    logCommon.setTableName(tableName);
    logCommon.setWhereStr(whereStr);
    logCommon.setCommonEventLogMessage(eventLogMessage);
    return logCommon;
  }
  // DB更新ログ出力ロジック wangzuo End

  /**
   * イベント作成の切り替えスイッチ取得
   * @return settingValue MODIFY_SEND_CLASSの設定値
   *         0：削除・新規イベントの切り替えはしない（変更イベントのまま）現状の動作
   *         1：スケジュールの変更（クール・ベッド・治療開始時刻）を削除・新規イベントに切り替える
   *         2：治療開始時刻・治療条件・医材・投薬の変更を含めてすべて削除・新規イベントに切り替える
   *           （FNWのイベント作成スイッチ切り替えに合わせる）
   *         ※MODIFY_SEND_CLASSが存在しない場合は、0を返す
   */
  @Override
  public Integer getCoopIniSchModifySendClass(String facilityCd) {

    List<MstCoopIni> mstCoopInis = mstCoopIniDao.selectByFacilityCd(facilityCd);
    MstCoopIni mstCoopIni = mstCoopInis.get(0);
    String coopIniInfo = mstCoopIni.getCoopIniInfo();
    JSONArray iniJsonArray = new JSONArray(coopIniInfo);
    String settingValue = "0";
    for (int i = 0; i < iniJsonArray.length(); i ++) {
      JSONObject jsonObject = iniJsonArray.getJSONObject(i);
      if (jsonObject.get("key1").equals("DIALYSISSCHESEND") && jsonObject.get("key2").equals("MODIFY_SEND_CLASS")) {
        String value = jsonObject.get("value").toString();
        String default_v = jsonObject.get("default_v").toString();
        settingValue = value.equals("") ? default_v : value;
        break;
      }
    }

    return Integer.parseInt(settingValue);
  }

  //add FNSI-7528 劉全航 start
  @Override
  public boolean getTreatmentRecordCondition(Long ordNo, String facilityCd) {
    OrdMain ordMain = ordMainDao.selectByOrdNo(ordNo);
    Integer rstEdition = ordMain.getRstEdition();
    List<MstCoopIni> mstCoopInis = mstCoopIniDao.selectByFacilityCd(facilityCd);
    // ADD FNSI-8304 劉全航 start
    if(mstCoopInis.isEmpty()){
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("mst_coop_iniレコードが見つかりませんでした");
      eventLogMessage.setFacilityCd(facilityCd);
      logService.log(LogLevel.DEBUG, eventLogMessage,FUNCTION_CODE.FUNC_TREATMENT_RECORD,SERVICE_NAME.REMS, "");
      return false;
    }
    // ADD FNSI-8304 劉全航 end
    MstCoopIni mstCoopIni = mstCoopInis.get(0);
    String coopIniInfo = mstCoopIni.getCoopIniInfo();
    JSONArray iniJsonArray = new JSONArray(coopIniInfo);
    String settingValue = null;
    for (int i = 0; i < iniJsonArray.length(); i ++) {
      JSONObject jsonObject = iniJsonArray.getJSONObject(i);
      if (jsonObject.get("key1").equals("DIALYSISSEND") && jsonObject.get("key2").equals("MODIFY_SEND_CLASS")) {
        String value = jsonObject.get("value").toString();
        String default_v = jsonObject.get("default_v").toString();
        settingValue = value.equals("") ? default_v : value;
        break;
      }
    }
    return rstEdition > 1 && Objects.equals(settingValue, "1");
  }
  //add FNSI-7528 劉全航 end

  /* add by songqingyang  2023-02-01 [CodeOptimization]  start */
  @Override
  public ResponseEntity<TreatmentRecordReportInfo> getTreatmentRecordReportInfoByOrdNoAndNtssUser(Long ordNo, NtssUser ntssUser) {
    // 治療記録の透析レポート情報取得
    TreatmentRecordReportInfo response = getTreatmentRecordReportInfoByOrdNo(ordNo);
    //add FNSI-redmine4746 房 start
    OrdMain ordMain = ordMainService.selectByOrdNo(ordNo);
    // mod 7007【デグレ】患者リストで患者を切り替えてもヘッダーの患者名が切り替わらない 赵 start
    //if (ordMain.getPatId() == null && response == null) {
    if (ordMain.getPatId() == null || response == null) {
      // mod 7007【デグレ】患者リストで患者を切り替えてもヘッダーの患者名が切り替わらない 赵 end
      response = new TreatmentRecordReportInfo();
    }
    //add FNSI-redmine4746 房 end

    // add redmain #4822 鄧シン start
    if (response.getReportId() == 0){
      // mod redmine-6352 ljx start
      /*
       * responseからReportIdを取得しなかったのパターンは二つがある；
       * ①治療方法未登録（???患者の場合）②治療方法が設定されるが、該当治療方法配下に帳票が未設定
       * よって、治療方法が登録されるかどうかの判断を追加する。
       * */
      //治療方法未登録の場合、仕様として、該当施設の治療方法の表示順1番目の帳票でレポート表示する。
      if(ordMain != null && ordMain.getRstTreatmentCd() == null){
        MstTreatment mstTreatment = new MstTreatment();
        mstTreatment.setFacilityCd(ntssUser.getFacilityCd());
        //該当施設の治療方法を取得
        List<MstTreatment> mstTreatments = mstTreatmentDao.selectAll(SelectOptions.get(),mstTreatment);
        if(mstTreatments != null && mstTreatments.size()>0){
          //治療方法の表示順1番目の帳票を取得
          mstTreatment = mstTreatments.get(0);
          if(mstTreatment.getReportId() != null &&mstTreatment.getReportId() != 0){
            response.setReportId(mstTreatment.getReportId());
          }
        }
      }
      if (response.getReportId() == 0){//治療方法が設定されるが、該当治療方法配下に帳票が未設定の場合、施設設定マスタの「117」番のデフォルト帳票を取得。
        FacilitySettingInfo facilitySettingInfo = mstFacilitySettingDao.getBySettingNoAndCd(ordMain.getFacilityCd(), CoreConstant.FacilitySettingNo.DEFAULT_REPORT_TEMPLATE);
        // mod redmine-6352 治療実績の治療方法が未登録の場合に治療記録のレポート表示がされない 房 start
        if (facilitySettingInfo != null) {
          long reportCd = Long.parseLong(facilitySettingInfo.getValue());
          response.setReportId(reportCd);
        }
        // mod redmine-6352 ljx end
      }
      // mod redmine-6352 治療実績の治療方法が未登録の場合に治療記録のレポート表示がされない 房 end
    }
    // add redmain #4822 鄧シン end

    //add 帳票コード取得修正 房 start
    // fix FNSI-修正 バーグ 单体 障害票 治療記録 No.19 孫灝 20201204 start
    if (response != null && response.getReportId() == 0) {
      // fix FNSI-修正 バーグ 单体 障害票 治療記録 No.19 孫灝 20201204 end
      //mod FNSI修正redmine4746 房 start
      List<ReportCds> reportCds = getReportCds("3004", ntssUser.getFacilityCd());
      //mod FNSI修正redmine4746 房 end
      long reportCd = 0;
      List<ReportCds> tempReportCds = reportCds.stream().filter(x->x.vkey == 1).collect(Collectors.toList());
      if (tempReportCds != null && tempReportCds.size() > 0) {
        reportCd = tempReportCds.get(0).getValue();
      } else {
        tempReportCds = reportCds.stream().filter(x->x.vkey == 2).collect(Collectors.toList());
        if (tempReportCds != null && tempReportCds.size() > 0) {
          reportCd = tempReportCds.get(0).getValue();
        }
      }
      if (reportCd != 0) {
        response.setReportId(reportCd);
      }
    }
    //add 帳票コード取得修正 房 end

    // レスポンス生成
    return new ResponseEntity<>(response, HttpStatus.OK);
  }

  @Override
  public ResponseEntity<String> getTreatingOrdNo(NtssUser ntssUser, Long ordNo) {
    boolean resultFlag = false;
    try {
      List<String> stateList = new ArrayList<String>(Arrays.asList(new String[]{"1", "2", "3", "4"}));
      final List<MstMachine> response = getMstMachineByOrdNoRst(ordNo);
      Integer deviceEdgeNo = 0;
      if (response != null && response.size() > 0) {
        deviceEdgeNo = response.get(0).getDeviceEdgeNo();
        ComsvSet comsvSet = selectComsvSet(ntssUser.getFacilityCd(), deviceEdgeNo);
        if (comsvSet != null && "1".equals(comsvSet.getPatTiming())){
          stateList.add("5");
        }
        Long patId = ordMainService.selectByOrdNo(ordNo).getPatId();
        List<OrdMain> ordMains = selectTreatingOrdno(patId, stateList);
        if (ordMains != null && ordMains.size() > 0) {
          PastOrderNoResponse res = callWebApi(ordMains.get(0).getOrdNo());
          for (OrdMainOrdNoAndRstStartDate element : res.getLatestOrdList()) {
            if (com.google.common.base.Objects.equal(element.getOrdNo(),ordNo)) {
              resultFlag = true;
              break;
            }
          }
          if (!resultFlag) {
            for (OrdMainOrdNoAndRstStartDate element : res.getSameDayOfTheWeekOrdList()) {
              if (com.google.common.base.Objects.equal(element.getOrdNo(),ordNo)) {
                resultFlag = true;
                break;
              }
            }
          }
        }
      }
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("オーダー番号から直近と同一曜日で過去の3回分オーダー番号の取得に失敗しました。");
      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
    if (resultFlag) {
      return new ResponseEntity<>("true", HttpStatus.OK);
    } else {
      return new ResponseEntity<>("false", HttpStatus.OK);
    }
  }

  private PastOrderNoResponse callWebApi(Long ordNo)
    throws URISyntaxException, IOException {
    // 送信URI TODO: ymlから取得するようにする
    URI uri = new URI(deviceEdgeUrl + "/api/past_ordinfo/" + ordNo);
    RequestEntity<Void> request = RequestEntity.get(uri).header("SSECCAYEK", "NTSS-NKK-ESM-TDC-YSK").build();
    RestTemplate restTemplate = new RestTemplate();
// #9698 アプリケーションログの内容修正 20260328 mod yangxuewang start
    long start = System.currentTimeMillis();
    ResponseEntity<PastOrderNoResponse> response = restTemplate.exchange(request, PastOrderNoResponse.class);
    long cost = System.currentTimeMillis() - start;
    Map<String, Object> map = new HashMap<>();
    map.put("logType", "RESTTEMPLATE-LOG");
    map.put("className", "jp.co.nikkiso.ntss.admin_web.service.treatmentRecord.TreatmentRecordServiceImpl");
    map.put("methodName", "callWebApi");
    map.put("method", request.getMethod());
    map.put("url", uri.getPath());
    map.put("headers", request.getHeaders());
    map.put("requestParameter", request.getBody());
    map.put("status",response.getStatusCode());
    map.put("cost", cost);
    map.put("result",response.getBody());
    EventLogMessage restTemplateEventLogMessage = new EventLogMessage();
    restTemplateEventLogMessage.setLogMessage(toJson(map));
    logService.log(LogLevel.INFO, restTemplateEventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
    return response.getBody();
// #9698 アプリケーションログの内容修正 20260328 mod yangxuewang end
  }

  @Override
  @Transactional
  public ResponseEntity<?> updateTreatmentRecordResult(Long ordNo, TreatmentRecordResult request, NtssUser ntssUser) {
    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to put treatment record result : "+ ordNo);
    logService.log(LogLevel.DEBUG, eventLogMessage,"",SERVICE_NAME.FNSI, "");

    // 治療記録（実績情報）の更新
    // add FNSI-redmine6122 fang start
    request.setUpUserId(ntssUser.getUserId());
    // add FNSI-redmine6122 fang end
    updateTreatmentRecordResult(ordNo, request);
    //del 6832 【デグレ】治療記録における特殊血液浄化回数が不正 周安寧　start
    //add 6832 デグレ】治療記録における特殊血液浄化回数が不正 赵 start
//    TreatmentRecordResult treatmentRecordResult1 = recordDao.selectTreatmentRecordResultByOrdNo(ordNo);
//    try {
//      PatMain pat = patMainDao.selectById(treatmentRecordResult1.getPatId());
//      MedicalCareInfo medicalCareInfo = new MedicalCareInfo();
//      ObjectMapper mapper1 = new ObjectMapper();
//      try {
//        if (!Strings.isNullOrEmpty(pat.getMedical_care_info())) {
//          medicalCareInfo = mapper1.readValue(pat.getMedical_care_info(), MedicalCareInfo.class);
//        }
//      } catch (IOException e) {
//        e.printStackTrace();
//      }
//      medicalCareInfo.purification_count = request.getRstPurificationCnt().toString();
//      //浄化治療回数の更新(特殊浄化の場合は更新します)
//      ObjectMapper mapper = new ObjectMapper();
//      patMainDao.updateMedicalCareInfo(treatmentRecordResult1.getPatId(), mapper.writeValueAsString(medicalCareInfo));
//    }catch (Exception ex) {
//      eventLogMessage.setLogMessage("患者基本情報[pat_main]の治療進捗状態[acceptance_status_info]更新 patId:" + treatmentRecordResult1.getPatId() + " 更新失敗 " + ex.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
//    }
    //add 6832 デグレ】治療記録における特殊血液浄化回数が不正 赵 end
    //del 6832 【デグレ】治療記録における特殊血液浄化回数が不正 周安寧　end
    // レスポンス生成
    return new ResponseEntity<>(null, HttpStatus.OK);
  }

  /* add by songqingyang  2023-02-01 [CodeOptimization]  end */

  //add 6127　ljx start
  /**
   * モニタデータの変更を変更履歴に登録
   * @param oldMniMonitor 変更前のデータ
   * @param newMniMonitor　変更後のデータ
   * @param flag　変更フラグ（add:新規　upd:変更　del:削除）
   */
  public void makeRstHistoryForMonitor(MniMonitor oldMniMonitor,MniMonitor newMniMonitor,String flag){
    Long ordNo = newMniMonitor.getOrdNo() == null?oldMniMonitor.getOrdNo():newMniMonitor.getOrdNo();
    //変更前後の製造番号、型式コード、更新者ID、データ種別、発生日時の定義
    String oldMachineSerial,oldMachineTypeCd,oldUpdStaffId,oldDataType,oldOccurDate;
    oldMachineSerial=oldMachineTypeCd=oldUpdStaffId=oldDataType=oldOccurDate="";
    String newMachineSerial,newMachineTypeCd,newUpdStaffId,newDataType,newOccurDate;
    newMachineSerial=newMachineTypeCd=newUpdStaffId=newDataType=newOccurDate="";
    if(oldMniMonitor.getBioMoniCtlNo() !=null){
      // mod FNSI-8577 LJX start
      if(!"upd".equals(flag)){
        oldMachineSerial = oldMniMonitor.getMachineSerial()==null?null:oldMniMonitor.getMachineSerial();
        oldMachineTypeCd = oldMniMonitor.getMachineTypeCd()==null?null:oldMniMonitor.getMachineTypeCd();
        oldUpdStaffId = oldMniMonitor.getUpdStaffId()==null?"":oldMniMonitor.getUpdStaffId().toString();
      }
      oldDataType = oldMniMonitor.getDataType() == null?"":oldMniMonitor.getDataType().toString();
      oldOccurDate = oldMniMonitor.getOccurDate() == null?"":oldMniMonitor.getOccurDate().toString();
    }
    if(newMniMonitor.getBioMoniCtlNo() !=null){
      if(!"upd".equals(flag)){
        newMachineSerial = newMniMonitor.getMachineSerial()==null?null:newMniMonitor.getMachineSerial();;
        newMachineTypeCd = newMniMonitor.getMachineTypeCd()==null?null:newMniMonitor.getMachineTypeCd();
        newUpdStaffId = newMniMonitor.getUpdStaffId()==null?"":newMniMonitor.getUpdStaffId().toString();
      }
        newDataType = newMniMonitor.getDataType() == null?"":newMniMonitor.getDataType().toString();
        newOccurDate = newMniMonitor.getOccurDate() == null?"":newMniMonitor.getOccurDate().toString();
    }
    // mod FNSI-8577 LJX end
    //版番号取得。
    OrdMain ordMain = ordMainDao.selectEdition(ordNo);
    ordMain.setOrdNo(newMniMonitor.getOrdNo()==null?oldMniMonitor.getOrdNo():newMniMonitor.getOrdNo());
    NtssUser user = (NtssUser) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
    ordMain.setUpUserId(user.getUserId());
    ordMain.setUpDate(new Timestamp(System.currentTimeMillis()));
    //変更履歴作成実行、rst_historyへ登録。
    if(!oldMachineSerial.equals(newMachineSerial)){
      doMakeRstHistoryForMonitor("製造番号",formatValue(oldMachineSerial),formatValue(newMachineSerial),"",ordMain);
    }
    if(!oldMachineTypeCd.equals(newMachineTypeCd)){
      doMakeRstHistoryForMonitor("型式コード",formatValue(oldMachineTypeCd),formatValue(newMachineTypeCd),"",ordMain);
    }
    if(!oldUpdStaffId.equals(newUpdStaffId)){
      doMakeRstHistoryForMonitor("更新者ID",formatValue(oldUpdStaffId),formatValue(newUpdStaffId),"",ordMain);
    }
    if(!oldDataType.equals(newDataType)){
      doMakeRstHistoryForMonitor("データ種別",formatValue(oldDataType),formatValue(newDataType),"",ordMain);
    }
    if(!oldOccurDate.equals(newOccurDate)){
      doMakeRstHistoryForMonitor("発生日時",formatValue(oldOccurDate),formatValue(newOccurDate),"",ordMain);
    }
    //jsonであるコラムのmonitor_dataの処理
    String newMonitorData = newMniMonitor.getMonitorData()==null?"{}":newMniMonitor.getMonitorData();
    String oldMonitorData = oldMniMonitor.getMonitorData()==null?"{}":oldMniMonitor.getMonitorData();
    JSONObject oldJsonObject = new JSONObject(oldMonitorData);
    JSONObject newJsonObject = new JSONObject(newMonitorData);

    Map<String,String> newMap= new HashMap<String,String>();
    Map<String,String> oldMap= new HashMap<String,String>();

    /* modify by chamaojia 2023-06-05 モニタレイアウトマスタ下拉框可以选择バイタル的项目  --start */
    //モニタデータの各keyの文字を取得。例：最高血圧
    //8499テストで発見された施設コード取得不正の修正 ljx start
    //List<MstPatViewerLayoutMonitorItem> result = mstPatViewerLayoutDao.selectMonitorItem("999998");
    List<MstPatViewerLayoutMonitorItem> result = mstPatViewerLayoutDao.selectMonitorItem(ordMain.getFacilityCd(), null, null);
    //8499テストで発見された施設コード取得不正の修正 ljx end
    /* modify by chamaojia 2023-06-05 モニタレイアウトマスタ下拉框可以选择バイタル的项目  --end */
    //取得された文字はkeyとして、新マップを作成（変更前後両者とも）
    for(MstPatViewerLayoutMonitorItem item:result){
      if(oldJsonObject.keySet().contains(item.getMoniDataNo())){
        oldMap.put(item.getVitalMonitorItemName(),oldJsonObject.get(item.getMoniDataNo()).toString());
      }
      if(newJsonObject.keySet().contains(item.getMoniDataNo())){
        newMap.put(item.getVitalMonitorItemName(),newJsonObject.get(item.getMoniDataNo()).toString());
      }
    }
    //変更前後のモニタデータを比較、差異を取得。
    Map<String,String> totalMap= new HashMap<String,String>();
    Iterator<Map.Entry<String, String>> iterator = oldMap.entrySet().iterator();
    while (iterator.hasNext()){
      Map.Entry<String, String> next = iterator.next();
      totalMap.put(next.getKey(),next.getValue());
    }
    iterator = newMap.entrySet().iterator();
    while (iterator.hasNext()){
      Map.Entry<String, String> next = iterator.next();
      totalMap.put(next.getKey(),next.getValue());
    }
    iterator = totalMap.entrySet().iterator();
    while (iterator.hasNext()){
      Map.Entry<String, String> next = iterator.next();
      if(!formatValue(oldMap.get(next.getKey())).equals(formatValue(newMap.get(next.getKey())))){
        //モニタデータに各項目の変更履歴を作成実行、rst_historyへ登録。
        doMakeRstHistoryForMonitor("モニタデータ",formatValue(oldMap.get(next.getKey())),formatValue(newMap.get(next.getKey())),next.getKey(),ordMain);
      }
    }
  }

  /**
   *
   * @param column コラム名
   * @param oldValue　変更前のデータ
   * @param newValue　変更後のデータ
   * @param key　項目名
   * @param ordMain　
   */
  public void doMakeRstHistoryForMonitor(String column,String oldValue,String newValue,String key,OrdMain ordMain){
    String LOG_MESSAGE_ORD_MAIN_HIS = "%s [%s]⇒[%s]";
    String fieldComment = column+"の"+key;
    if("".equals(key)){
      //項目がないの場合、コラム名のみをメッセージとして登録。
      fieldComment = column;
    }
    //メッセージ作成：コラム名（項目名）　変更前のデータ⇒変更後のデータ
    String ordMainHisMessage = String.format(LOG_MESSAGE_ORD_MAIN_HIS, fieldComment,
      oldValue,
      newValue);
    OrdMainHisMongo ordMainHisMongo = new OrdMainHisMongo();
    ordMainHisMongo.setMessage(ordMainHisMessage);
    ordMainHisMongo.setOrdNo(ordMain.getOrdNo().toString());
    ordMainHisMongo.setRstEdition(ordMain.getRstEdition().toString());
    ordMainHisMongo.setUpDate(new SimpleDateFormat("yyyy/MM/dd HH:mm:ss.SSS").format(ordMain.getUpDate()));
    //mod #10077 by zhangruixue 2023-11-28  start
    ordMainHisMongo.setUpUserId(ordMain.getUpUserId() != null ? ordMain.getUpUserId().toString() : "");
    //mod #10077 by zhangruixue 2023-11-28  end
    //rst_historyへ登録。
    logServiceCore.createOrdMainHis(ordMainHisMongo);
  }
  public String formatValue(Object value){
    if (StringUtils.isEmpty(value)) {
      return "";
    }else{
      return value.toString();
    }
  }
  //add 6127　ljx end


  @Override
  public String getRstDialysisState(Long ordNo) {
    OrdMain o = ordMainDao.selectRstDialysisState(ordNo);
    return o.getRstDialysisState();
  }
  // add #11471 ord_mian操作時の治療モードデータの登録 関 start
  @Override
  public ResponseEntity<TreatmentRecordReportInfo> getRstCondInfoSettingByOrdNo(Long ordNo) {
    TreatmentRecordReportInfo response = recordDao.selectRstCondInfoSettingByOrdNo(ordNo);

    return new ResponseEntity<>(response, HttpStatus.OK);
  }
  // add #11471 ord_mian操作時の治療モードデータの登録 関 end
}
