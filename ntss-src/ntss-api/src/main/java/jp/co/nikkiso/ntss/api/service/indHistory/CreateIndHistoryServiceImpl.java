package jp.co.nikkiso.ntss.api.service.indHistory;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.gson.Gson;
import com.mongodb.bulk.BulkWriteResult;
import jp.co.nikkiso.ntss.api.model.indHistory.TreatMethodChangeHelper;
import jp.co.nikkiso.ntss.api.model.indHistory.ValiCommentCreate;
import jp.co.nikkiso.ntss.api.model.indHistory.ValiCopyTreatPlan;
import jp.co.nikkiso.ntss.api.model.indHistory.ValiCreateTreatPlan;
import jp.co.nikkiso.ntss.api.model.indHistory.ValiDeleteIndPlanPatInfo;
import jp.co.nikkiso.ntss.api.model.indHistory.ValiDeviceSetInfo;
import jp.co.nikkiso.ntss.api.model.indHistory.ValiMoveTreatPlan;
import jp.co.nikkiso.ntss.api.model.indHistory.ValiOrdEquip;
import jp.co.nikkiso.ntss.api.model.indHistory.ValiOrdMedi;
import jp.co.nikkiso.ntss.api.model.indHistory.ValiUpdateIndCond;
import jp.co.nikkiso.ntss.api.model.indHistory.ValiUpdateIndSchedule;
import jp.co.nikkiso.ntss.api.model.indHistory.ValiWeekPattern;
import jp.co.nikkiso.ntss.api.service.LogService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.MstBedDao;
import jp.co.nikkiso.ntss.core.dao.MstDialyzerDao;
import jp.co.nikkiso.ntss.core.dao.MstEquipmentDao;
import jp.co.nikkiso.ntss.core.dao.MstKurDao;
import jp.co.nikkiso.ntss.core.dao.MstMedicateTimingDao;
import jp.co.nikkiso.ntss.core.dao.MstMedicineDao;
import jp.co.nikkiso.ntss.core.dao.MstMedicineMixDao;
import jp.co.nikkiso.ntss.core.dao.MstPersonalUserDao;
import jp.co.nikkiso.ntss.core.dao.MstProcedureDao;
import jp.co.nikkiso.ntss.core.dao.MstTreatmentDao;
import jp.co.nikkiso.ntss.core.dao.MstVaDao;
import jp.co.nikkiso.ntss.core.entity.MstBed;
import jp.co.nikkiso.ntss.core.entity.MstDialyzer;
import jp.co.nikkiso.ntss.core.entity.MstEquipment;
import jp.co.nikkiso.ntss.core.entity.MstKur;
import jp.co.nikkiso.ntss.core.entity.MstMedicateTiming;
import jp.co.nikkiso.ntss.core.entity.MstMedicine;
import jp.co.nikkiso.ntss.core.entity.MstMedicineMix;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.entity.MstProcedure;
import jp.co.nikkiso.ntss.core.entity.MstTreatment;
import jp.co.nikkiso.ntss.core.entity.MstVa;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.custom.TareOrOffWaterJson;
import jp.co.nikkiso.ntss.api.model.indHistory.IndHistory;
import jp.co.nikkiso.ntss.core.logevent.LogServiceCore;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.utils.MongoHealthCheckService;
import org.apache.commons.collections4.CollectionUtils;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.seasar.doma.jdbc.SelectOptions;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessResourceFailureException;
import org.springframework.data.mongodb.core.BulkOperations;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.stereotype.Service;
import org.springframework.util.ObjectUtils;
import org.springframework.util.StringUtils;

import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.text.DecimalFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;
import java.util.stream.IntStream;
import java.util.stream.Stream;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

@Service
public class CreateIndHistoryServiceImpl implements CreateIndHistoryService {

  @Autowired
  private MstKurDao mstKurDao;

  @Autowired
  private MstBedDao mstBedDao;

  @Autowired
  private MstTreatmentDao mstTreatmentDao;

  @Autowired
  private MstPersonalUserDao mstPersonalUserDao;

  @Autowired
  private LogServiceCore logServiceCore;

  @Autowired
  private MstDialyzerDao mstDialyzerDao;

  @Autowired
  private MstVaDao mstVaDao;

  @Autowired
  private MstMedicineDao mstMedicineDao;

  @Autowired
  private MstMedicineMixDao mstMedicineMixDao;

  @Autowired
  private MstEquipmentDao mstEquipmentDao;

  @Autowired
  private MstProcedureDao mstProcedureDao;

  @Autowired
  private MstMedicateTimingDao mstMedicateTimingDao;

  @Autowired(required = false)
  MongoTemplate mongoTemplate;

  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
  @Autowired
  private LogService logService;
 // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
  // 履歴ソート順MAP
  private static final Map<String, Integer> sortMap = initMapData();

  // 登録時刻フォーマット
  private static final String FORMAT_DATE = "yyyyMMddHHmmssSSS";
  // #10959 システム内でstatic変数を使っている箇所の洗い出し del yangxuewang start
//  // 投与薬剤有無(Default = true)
//  private Boolean isIncludingMedicine = true;
//
//  // 投与薬剤有無(Getter)
//  private Boolean getIsIncludingMedicine() {
//    return this.isIncludingMedicine;
//  }
//
//  // 投与薬剤有無(Setter)
//  private void setIsIncludingMedicine(Boolean isIncludingMedicine) {
//    this.isIncludingMedicine = isIncludingMedicine;
//  }
  // #10959 システム内でstatic変数を使っている箇所の洗い出し del yangxuewang end

  /* del by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
//  private HashMap<Long, String> ordAndNewDeviceMode = new HashMap<>();
//
//  public void getOrdAndNewDeviceModes (HashMap<Long, String> deviceModes){
//    ordAndNewDeviceMode = deviceModes;
//  }
  /* del by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */

  @Override
  public boolean isToMongo(){
    return mongoTemplate != null;
  }

  /**
   * 指示履歴登録処理(治療予定・予定中止)
   */
  @Override
  public void createDeleteHistoryByDeleteIndPlanPatInfo(ValiDeleteIndPlanPatInfo bodyData, List<OrdMain> ordMainList,
                                                        String dialysisDateFrom, String dialysisDateTo) throws ParseException {
    //指示履歴用パラメータ
    IndHistory indHistory;
    String setLogDate = new SimpleDateFormat(FORMAT_DATE).format(new Date());
    //曜日
    List<Integer> weeksArray = new ArrayList<>();
    if(StringUtils.hasText(dialysisDateFrom) && StringUtils.hasText(dialysisDateTo)) {
      for (int date = Integer.parseInt(dialysisDateFrom); date <= Integer.parseInt(dialysisDateTo); date++) {
        String dateStr = String.valueOf(date);
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyyMMdd");
        Date treatDay = dateFormat.parse(dateStr);
        Calendar cal = Calendar.getInstance();
        cal.setTime(treatDay);
        int dayOfWeek = cal.get(Calendar.DAY_OF_WEEK) - 1;
        if (0 == dayOfWeek) {
          dayOfWeek = 7;
        }
        weeksArray.add(dayOfWeek);
        if (7 == weeksArray.size()) {
          break;
        }
      }
      // 曜日リストの重複を削除
      if(!weeksArray.isEmpty()) {
        weeksArray = weeksArray.stream().distinct().collect(Collectors.toList());
      }
    }

    //中止する治療情報分、中止の指示履歴登録する。
    for (OrdMain ordMain : ordMainList) {
      //中止する各項目の値一覧を保持するマップ
      // #10959 システム内でstatic変数を使っている箇所の洗い出し mod yangxuewang start
      Map<String, String> ordMainMap = this.createKeyValues(ordMain, bodyData.getFacility_cd(), true);
      // #10959 システム内でstatic変数を使っている箇所の洗い出し mod yangxuewang end
      //中止する項目のキー名を取得
      List<String> keysList = this.gettingKeylist(ordMainMap);

      //対象項目毎に指示履歴を登録
      for (String key : keysList) {
        //指示履歴に登録するパラメータを作成
        indHistory = this.createDeleteHistoryParamsByDeleteIndPlanPatInfo(bodyData, key, ordMainMap.get(key), weeksArray, dialysisDateFrom, dialysisDateTo);

        //指示履歴時刻設定
        indHistory.setLogDate(setLogDate);
        indHistory.setOrdNo(ordMain.getOrdNo() == null ? null : ordMain.getOrdNo().toString());
        //指示履歴登録処理
        this.planCreateHistoryExecute(indHistory, key, "3");
      }
      //指示履歴を一度登録したら処理を終了
      break;
    }
  }


  /**
   * 指示履歴登録処理(治療予定・予定作成)
   *
   * @param bodyData   指示履歴作成に必要な値一覧
   * @param ordMain    登録する各項目の値一覧
   * @param weeksArray 編集対象曜日
   */
  @Override
  public void createPlanHistory(ValiCreateTreatPlan bodyData, OrdMain ordMain, List<Integer> weeksArray) {

    // 指示履歴用パラメータ
    IndHistory indHistory;
    // 登録データの統一時刻ログ
    String setLogDate = new SimpleDateFormat(FORMAT_DATE).format(new Date());

    //登録する各項目の値一覧を保持するマップ
    // #10959 システム内でstatic変数を使っている箇所の洗い出し mod yangxuewang start
    Map<String, String> ordMainMap = this.createKeyValues(ordMain, bodyData.getFacility_cd(), true);
    // #10959 システム内でstatic変数を使っている箇所の洗い出し mod yangxuewang end
    //登録する項目のキー名を取得
    List<String> keysList = this.gettingKeylist(ordMainMap);

    //治療方法コードを取得
    String indTreatmentCd = ordMain.getIndTreatmentCd().toString();
    //対象項目毎に指示履歴を登録
    for (String key : keysList) {
      //指示履歴に登録するパラメータを作成
      indHistory = this.createPlanHistoryParams(bodyData, key, ordMainMap.get(key), weeksArray, indTreatmentCd);
      //指示履歴時刻設定
      indHistory.setLogDate(setLogDate);
      indHistory.setOrdNo(ordMain.getOrdNo() == null ? null : ordMain.getOrdNo().toString());
      //指示履歴登録処理
      this.planCreateHistoryExecute(indHistory, key, "1");
    }
  }

  /**
   * 指示履歴登録処理(治療予定・治療日変更)
   *
   * @param bodyData   指示履歴作成に必要な値一覧
   * @param ordMain    変更元の各項目の値一覧
   * @param weeksArray 編集対象曜日
   */
  @Override
  public void createMoveHistory(ValiMoveTreatPlan bodyData, OrdMain ordMain, List<Integer> weeksArray) {

    //指示履歴用パラメータ
    IndHistory indHistory;
    // 登録データの統一時刻ログ
    String setLogDate = new SimpleDateFormat(FORMAT_DATE).format(new Date());

    //指示履歴に登録する各項目の値一覧を保持するマップ
    // #10959 システム内でstatic変数を使っている箇所の洗い出し mod yangxuewang start
    Map<String, String> ordMainMap = this.createKeyValues(ordMain, bodyData.getFacility_cd(), true);
    // #10959 システム内でstatic変数を使っている箇所の洗い出し mod yangxuewang end

    //指示履歴に登録する項目のキー名を取得
    List<String> keysList = this.gettingKeylist(ordMainMap);

    for (String key : keysList) {
      //治療予定とスケジュール変更のみ、履歴登録処理を行う
      if (key.equals("治療予定") || key.equals("スケジュール変更")) {
        //指示履歴に登録するパラメータを作成
        indHistory = this.createMoveHistoryParams(bodyData, ordMain, key, ordMainMap.get(key), weeksArray);
        //指示履歴時刻設定
        indHistory.setLogDate(setLogDate);
        indHistory.setOrdNo(ordMain.getOrdNo() == null ? null : ordMain.getOrdNo().toString());
        this.planCreateHistoryExecute(indHistory, key, "4");
      }
    }
  }

  /**
   * 指示履歴登録処理(治療予定・予定コピー)
   *
   * @param bodyData   指示履歴作成に必要な値一覧
   * @param ordMain    変更元の各項目の値一覧
   * @param weeksArray 編集対象曜日
   */
  @Override
  public void createCopyHistory(ValiCopyTreatPlan bodyData, OrdMain ordMain, List<Integer> weeksArray) {
    //指示履歴用パラメータ
    IndHistory indHistory;
    // 登録データの統一時刻ログ
    String setLogDate = new SimpleDateFormat(FORMAT_DATE).format(new Date());
    // #10959 システム内でstatic変数を使っている箇所の洗い出し mod yangxuewang start
//    // 投与薬剤有無の格納
//    this.setIsIncludingMedicine(bodyData.getIs_including_medicine());

    //登録する各項目の値一覧を保持するマップ
    Map<String, String> ordMainMap = this.createKeyValues(ordMain, bodyData.getFacility_cd(), bodyData.getIs_including_medicine());
    // #10959 システム内でstatic変数を使っている箇所の洗い出し mod yangxuewang end
    //登録する項目のキー名を取得
    List<String> keysList = this.gettingKeylist(ordMainMap);

    //対象項目毎に指示履歴を登録
    for (String key : keysList) {
      //指示履歴に登録するパラメータを作成
      indHistory = this.createCopyHistoryParams(bodyData, ordMain, key, ordMainMap.get(key), weeksArray);
      //指示履歴時刻設定
      indHistory.setLogDate(setLogDate);
      //指示履歴登録処理
      indHistory.setOrdNo(ordMain.getOrdNo() == null ? null : ordMain.getOrdNo().toString());
      this.planCreateHistoryExecute(indHistory, key, "1");
    }
  }

  /**
   * 指示履歴登録処理(治療条件)
   *
   * @param bodyData    (指示履歴作成に必要な値一覧)
   * @param flag        (1.新規、2.変更,3.削除)
   * @param weeksArray  編集対象曜日
   * @param ordMainList 更新対象となる治療情報
   */
  @Override
  public void createConditionHistory(ValiUpdateIndCond bodyData, String flag, List<Integer> weeksArray, List<OrdMain> ordMainList) {
    //指示履歴用パラメータ
    IndHistory indHistory = new IndHistory();
    String setLogDate = new SimpleDateFormat(FORMAT_DATE).format(new Date());

    //更新対象の治療情報分、指示履歴を登録
    for (OrdMain ordMain : ordMainList) {
      //指示履歴用パラメータに各値を入力
      indHistory = this.createConditionHistoryParams(bodyData, weeksArray, ordMain);

      //パラメータの対象、内容を文字列→配列に変換
      String[] paramTargetArray = Objects.isNull(indHistory.getLogTarget()) ? null : indHistory.getLogTarget().split(",");
      JSONArray paramContentArray = indHistory.getLogContent()==null
        ||Objects.isNull(new JSONArray(indHistory.getLogContent()))?null:new JSONArray(indHistory.getLogContent());
      if (Objects.isNull(paramTargetArray) || Objects.isNull(paramContentArray)) {
        break;
      }

      //指示履歴登録処理を実行
      for (int i = 0; i < paramTargetArray.length; i++) {
        //パラメータの対象、内容を設定
        indHistory.setLogTarget(paramTargetArray[i]);
        indHistory.setLogContent(paramContentArray.get(i).toString());

        if (paramContentArray.get(i).toString().equals("null")) {
          // nullが入っている場合は無効項目の為スキップする
          continue;
        }
        //指示履歴時刻設定
        indHistory.setLogDate(setLogDate);
        //指示履歴登録処理
        this.createHistoryExecute(indHistory, flag);
      }
      //指示履歴を一度登録したら、処理を終了する
      break;
    }
  }

  /**
   * 指示履歴登録処理(投与薬剤)
   *
   * @param bodyData   (指示履歴作成に必要な値一覧)
   * @param flag       (1.新規、2.変更,3.削除)
   * @param weeksArray 編集対象曜日
   * @param ordMains    更新対象となる治療情報
   */
  @Override
  public void createMedicineHistory(ValiOrdMedi bodyData, String flag, List<Integer> weeksArray, List<OrdMain> ordMains) {
    String setLogDate = new SimpleDateFormat(FORMAT_DATE).format(new Date());
    //指示履歴用パラメータに各値を入力
    // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm start
//    IndHistory indHistory = this.createMedicineHistoryParams(bodyData, flag, weeksArray, ordMain);
    IndHistory indHistory = this.createMedicineHistoryParams(bodyData, flag, weeksArray, ordMains);
    // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm end

    //指示履歴時刻設定
    indHistory.setLogDate(setLogDate);
    //指示履歴登録処理
    this.createHistoryExecute(indHistory, flag);
  }

  /**
   * 指示履歴登録処理(医療材料)
   *
   * @param bodyData    (指示履歴作成に必要な値一覧)
   * @param flag        (1.新規、2.変更,3.削除)
   * @param weeksArray  編集対象曜日
   * @param ordMainList 更新対象となる治療情報
   */
  @Override
  public void createEquipmentHistory(ValiOrdEquip bodyData, String flag, List<Integer> weeksArray,  List<OrdMain> ordMainList) {
    //指示履歴用パラメータ
    IndHistory indHistory = new IndHistory();
    //mod FNSI-5910 劉全航 start
    String setLogDate = new SimpleDateFormat(FORMAT_DATE).format(new Date());
    //mod FNSI-5910 劉全航 end
    //新規の場合
    if (flag.equals("1")) {
      //mod FNSI-5910 劉全航 start
      //指示履歴用パラメータに各値を入力
      // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm start
//      indHistory = this.createEquipmentHistoryParams(bodyData, flag, weeksArray, new OrdMain());
      indHistory = this.createEquipmentHistoryParams(bodyData, flag, weeksArray, new ArrayList<>());
      // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm end
      //指示履歴時刻設定
      indHistory.setLogDate(setLogDate);
      //指示履歴登録処理
      this.createHistoryExecute(indHistory, flag);
      // this.createEquipmentHistoryParams(bodyData, flag, weeksArray, new OrdMain());
      //mod FNSI-5910 劉全航 end
    }
    //変更・削除の場合
    else {
      // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm start
//      //更新対象の治療情報分、医療材料の存在有無を判定
//      registHistory:
//      for (OrdMain ordMain : ordMainList) {
//        //更新対象となる医療材料一覧
//        List<Map<String, String>> indInfoEquipmentList = changeListMap(ordMain.getIndEquipInfo());
//
//        //更新対象の治療情報に医療材料が存在するか判定
//        if (! indInfoEquipmentList.isEmpty()) {
//          //画面から取得した、編集対象の医療材料コード
//          String targetCd = bodyData.getTarget_equip_edit();
//
//          //更新対象の治療情報の医療材料に、編集する医療材料があれば指示履歴を登録
//          for (Map<String, String> indInfoEquipment : indInfoEquipmentList) {
//            //更新対象となる治療情報の医療材料コード
//            String cd = indInfoEquipment.get("cd");
//
//            if (targetCd.equals(cd)) {
//              //mod FNSI-5910 劉全航 start
//              //指示履歴用パラメータに各値を入力
//              indHistory = this.createEquipmentHistoryParams(bodyData, flag, weeksArray, ordMain);
//              //指示履歴時刻設定
//              indHistory.setLogDate(setLogDate);
//              //指示履歴登録処理
//              this.createHistoryExecute(indHistory, flag);
//              // this.createEquipmentHistoryParams(bodyData, flag ,weeksArray, ordMain);
//              //mod FNSI-5910 劉全航 end
//              //履歴を一度登録したら処理を終了
//              break registHistory;
//            }
//          }
//        }
//      }

      //画面から取得した、編集対象の医療材料コード
      String targetCd = bodyData.getTarget_equip_edit();
      List<Map<String, String>> indInfoEquipmentList = ordMainList.stream().map(o -> changeListMap(o.getIndEquipInfo())).flatMap(List::stream).filter(e -> targetCd.equals(e.get("cd"))).toList();
      if(CollectionUtils.isNotEmpty(indInfoEquipmentList)) {
        //指示履歴用パラメータに各値を入力
        indHistory = this.createEquipmentHistoryParams(bodyData, flag, weeksArray, indInfoEquipmentList);
        //指示履歴時刻設定
        indHistory.setLogDate(setLogDate);
        //指示履歴登録処理
        this.createHistoryExecute(indHistory, flag);
      }
      // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm end
    }
  }

  /**
   * 指示履歴登録処理(スケジュール変更)
   * @param bodyData       (指示履歴作成に必要な値一覧)
   * @param flag           (1.新規、2.変更,3.削除。ここでは2しか無い)
   * @param weeksArray     編集対象曜日
   * @param ordMainList    更新対象となる治療情報
   *  @param paramTarget   設定パラメータ   "ベッド Or"  "クール,治療開始時刻,ベッド"
   */
  @Override
  public List<IndHistory> createScheduleHistory(ValiUpdateIndSchedule bodyData, String flag, List<Integer> weeksArray, List<OrdMain> ordMainList, String paramTarget) {
    //指示履歴用パラメータを定義し、各値を入力
    IndHistory indHistory = new IndHistory();
    List<IndHistory> indHistoryList = new ArrayList<>();
    String setLogDate = new SimpleDateFormat(FORMAT_DATE).format(new Date());

    //スケジュール変更を行う治療情報分、指示履歴を登録
    for (OrdMain ordMain : ordMainList) {
      indHistory = this.createScheduleHistoryParams(bodyData, weeksArray, ordMain, paramTarget);

      //パラメータの対象、内容を文字列→配列に変換
      String[] paramTargetArray = indHistory.getLogTarget().split(",");
      JSONArray paramContentArray = new JSONArray(indHistory.getLogContent());

      //指示履歴登録処理を実行
      for (int i = 0; i < paramTargetArray.length; i++) {
        //履歴の内容に何も変更していない場合は履歴登録を行わない
        if (paramContentArray.get(i).toString().contains("→") && (paramContentArray.get(i).toString().split("→")[0].equals(paramContentArray.get(i).toString().split("→")[1]))) {
          continue;
        }
        //パラメータの対象、内容を設定
        indHistory.setLogTarget(paramTargetArray[i]);
        indHistory.setLogContent(paramContentArray.get(i).toString());
        //指示履歴時刻設定
        indHistory.setLogDate(setLogDate);
        indHistory.setOrdNo(ordMain.getOrdNo() == null ? null : ordMain.getOrdNo().toString());
        //指示履歴登録処理
        indHistory.setLogClass("変更");
        indHistory.setSortNo(sortMap.get(indHistory.getLogTarget()));

        IndHistory indHistoryResult = new IndHistory();
        BeanUtils.copyProperties(indHistory, indHistoryResult);
        indHistoryList.add(indHistoryResult);
      }
      //指示履歴を一度登録したら処理を終了
      return indHistoryList;
    }
    return indHistoryList;
  }

  /**
   * 指示履歴登録処理(風袋  除水補正)
   */
  @Override
  public void createIndTareInfoHistory(ValiCreateTreatPlan bodyData, OrdMain ordMain, String indTareInfo, List<Integer> weeksArray, String TareName, String flag) {
    //指示履歴用パラメータを定義し、各値を入力
    IndHistory indHistory = new IndHistory();
    String setLogDate = new SimpleDateFormat(FORMAT_DATE).format(new Date());
    //患者コード
    String patId = bodyData.getPat_id();
    //施設コード
    String facilityCd = bodyData.getFacility_cd();
    // 開始日
    String startDate = bodyData.getStart_date().replaceAll("-", "");
    // 終了日
    String endDate = "false".equals(bodyData.getIs_deadline()) ? "" : bodyData.getEnd_date().replaceAll("-", "");
    //mod 9864 患者経過総合ビューアの指示編集画面で翌年を指示開始日に設定すると、終了日が自動でセットされ無期限指示変更ができない。zy start
    //治療方法コード
    String indTreatmentCd = ordMain.getIndTreatmentCd().toString();
    //クールコード
    String indKurCd = bodyData.getInd_kur_cd();
    //指示者コード
    String indUserId = bodyData.getInd_user_id()==null?"null":bodyData.getInd_user_id().toString();
    //更新者コード
    String updUserId = bodyData.getUpd_user_id()==null?"null":bodyData.getUpd_user_id().toString();
    // 指示履歴用パラメータに各値を入力
    // 患者コード、開始日、終了日、曜日、治療方法、クール、指示者、更新者を設定
    indHistory = this.setBasicParams(patId, startDate, endDate, weeksArray, indTreatmentCd, indKurCd, indUserId, updUserId, facilityCd);
    // 対象
    indHistory.setLogTarget(TareName);
    // 内容を設定
    final String[] contentText = {""};
    List<String> listCongtent = new ArrayList<>();
    if("風袋".equals(TareName)){
      listCongtent = createIndTareInfoContent(ordMain.getIndTareInfo(),indTareInfo,flag);
    }else{
      listCongtent = createIndTareInfoContent(ordMain.getIndOffWaterInfo(),indTareInfo,flag);
    }
    listCongtent.forEach(item->{
      contentText[0] = contentText[0] +item;
    });
    indHistory.setLogContent(contentText[0]);

    //指示履歴時刻設定
    indHistory.setLogDate(setLogDate);
    //指示履歴登録処理
    this.createHistoryExecute(indHistory, flag);
  }

  /**
   * 指示履歴登録処理(指示コメント)
   *
   * @param bodyData   (指示履歴作成に必要な値一覧)
   * @param flag       (1.新規、2.変更,3.削除)
   * @param weeksArray 編集対象曜日
   */
  @Override
  public void createCommentHistory(ValiCommentCreate bodyData, String flag, List<Integer> weeksArray, List<String> oldIndContents) {
    //指示履歴用パラメータを定義し、各値を入力
    IndHistory indHistory = new IndHistory();
    String setLogDate = new SimpleDateFormat(FORMAT_DATE).format(new Date());
    indHistory = this.createCommentHistoryParams(bodyData, weeksArray, oldIndContents);
    //指示履歴時刻設定
    indHistory.setLogDate(setLogDate);
    //指示履歴登録処理
    this.createHistoryExecute(indHistory, flag);
  }

  /**
   * 指示履歴登録処理(装置設定)
   *
   * @param bodyData    (指示履歴作成に必要な値一覧)
   * @param flag        (1.新規、2.変更,3.削除)
   * @param weeksArray  編集対象曜日
   * @param ordMainList 更新対象となる治療情報
   */
  @Override
  public void createDeviceSetInfoHistory(ValiDeviceSetInfo bodyData, String flag, List<Integer> weeksArray, List<OrdMain> ordMainList) {
    //指示履歴用パラメータ
    IndHistory indHistory = new IndHistory();
    String setLogDate = new SimpleDateFormat(FORMAT_DATE).format(new Date());

    //更新対象の治療情報分、指示履歴を登録
    for (OrdMain ordMain : ordMainList) {
      //指示履歴用パラメータに各値を入力
      indHistory = this.createDeviceSetInfoHistoryParams(bodyData, weeksArray, ordMain);

      //パラメータの対象、内容を文字列→配列に変換
      String[] paramTargetArray = Objects.isNull(indHistory.getLogTarget()) ? null : indHistory.getLogTarget().split(",");
      JSONArray paramContentArray = !StringUtils.hasText(indHistory.getLogContent()) ? null : new JSONArray(indHistory.getLogContent());

      if (Objects.isNull(paramTargetArray) || Objects.isNull(paramContentArray)) {
        break;
      }
      //指示履歴登録処理を実行
      for (int i = 0; i < paramContentArray.length(); i++) {
        //パラメータの対象、内容を設定
        indHistory.setLogTarget(paramTargetArray[0]);
        indHistory.setLogContent(paramContentArray.get(i).toString());

        if (paramContentArray.get(i).toString().equals("null")) {
          // nullが入っている場合は無効項目の為スキップする
          continue;
        }
        //指示履歴時刻設定
        indHistory.setLogDate(setLogDate);
        //指示履歴登録処理
        this.createHistoryExecute(indHistory, flag);
      }
      //指示履歴を一度登録したら、処理を終了する
      break;
    }
  }

  /**
   * 指示履歴登録処理(治療方法)
   *
   * @param bodyData      指示履歴作成に必要な値一覧
   * @param ordMain       変更後の各項目の値一覧
   * @param targetOrdMain 変更対象となる、変更前の各項目の値一覧
   * @param weeksArray    編集対象曜日
   */
  @Override
  public void createMethodHistory(ValiCreateTreatPlan bodyData, OrdMain ordMain, OrdMain targetOrdMain, List<Integer> weeksArray) {

    //指示履歴用パラメータ
    IndHistory indHistory;
    // 登録データの統一時刻ログ
    String setLogDate = new SimpleDateFormat(FORMAT_DATE).format(new Date());
    //指示履歴用パラメータと操作区分
    Map<String, Object> indHistoryMap;
    //治療方法の編集方法を判定するフラグ(0:治療方法のみ 1:投与薬剤含めて変更 2:投与薬剤含めず変更)
    String treatMethodFlag = bodyData.getTreat_method_flag();

    //変更後の各項目の値一覧を保持するマップ
    // #10959 システム内でstatic変数を使っている箇所の洗い出し mod yangxuewang start
    Map<String, String> ordMainMap = this.createKeyValues(ordMain, bodyData.getFacility_cd(), true);
    // #10959 システム内でstatic変数を使っている箇所の洗い出し mod yangxuewang end
    //変更後項目のキー名を取得
    List<String> keysList = this.gettingKeylist(ordMainMap);

    //治療方法のみ変更する場合
    if (treatMethodFlag.equals("0")) {
      //指示履歴に登録するパラメータを作成
      indHistoryMap = this.createMethodHistoryParams(
        bodyData,
        "治療方法",
        ordMainMap.get("治療方法"),
// mod #11933 スケジュールのコピーでエラーコード500発生 関 start
// add 11555 指示履歴への記録の残り方が仕様と異なる zkm start
//          targetOrdMain,
        Stream.ofNullable(targetOrdMain)
          .collect(Collectors.toUnmodifiableList()),
// add 11555 指示履歴への記録の残り方が仕様と異なる zkm end
// mod #11933 スケジュールのコピーでエラーコード500発生 関 end
        treatMethodFlag,
        weeksArray);

      //パラメーターを取得
      indHistory = (IndHistory) indHistoryMap.get("パラメーター");

      //指示履歴時刻設定
      indHistory.setLogDate(setLogDate);
      //指示履歴登録処理
      //mod FNSI-6787 ljx start
      //履歴の内容に何も変更していない場合は履歴登録を行わない
      if (indHistory.getLogContent().contains("→") && (! indHistory.getLogContent().split("→")[0].equals(indHistory.getLogContent().split("→")[1]))) {
        this.createHistoryExecute(indHistory, "2");
      }
      //mod FNSI-6787 ljx end
      /* del by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
//      // add #7327 治療方法マスタ操作時の動作がおかしい 王永吉 start
//      // mod 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関  start
//      // if (ordAndNewDeviceMode != null && ordAndNewDeviceMode.containsKey(Long.parseLong(bodyData.getInd_treatment_cd()))){
//      if (ordAndNewDeviceMode != null && ordAndNewDeviceMode.containsKey(Long.parseLong(bodyData.getTreatment_set_cd()))){
//        // mod 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関  end
//        String changeDeviceMode = ordAndNewDeviceMode.get(Long.parseLong(bodyData.getInd_treatment_cd()));
//        // 治療方法モード変更
//        if (changeDeviceMode.contains("→") && (! changeDeviceMode.split("→")[0].equals(changeDeviceMode.split("→")[1]))) {
//          indHistory.setLogContent(changeDeviceMode);
//          indHistory.setLogTarget("治療方法モード");
//          indHistory.setTreatmentCourse("すべて");
//          indHistory.setSortNo(20);
//          this.createHistoryExecute(indHistory, "2");
//        }
//        // 治療方法モード削除
//        if (changeDeviceMode.contains("【削除済み】")){
//          indHistory.setLogContent(changeDeviceMode);
//          indHistory.setTreatmentMethod(bodyData.getTreatment_name());
//          indHistory.setTreatmentCourse("すべて");
//          indHistory.setSortNo(20);
//          this.createHistoryExecute(indHistory, "3");
//        }
//      }
//      // add #7327 治療方法マスタ操作時の動作がおかしい 王永吉 end
      /* del by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */
    } else {
      for (String key : keysList) {
        //keyが治療方法で、登録する治療情報が存在有無を判定
        if (key.equals("治療方法")) {
          if (ordMainMap.get("治療方法").isEmpty())
            //変更後の治療方法コードが格納がされてないので、格納しておく。
            ordMainMap.put("治療方法", bodyData.getInd_treatment_cd());
        }

        //指示履歴に登録するパラメータを作成
        indHistoryMap = this.createMethodHistoryParams(
          bodyData,
          key,
          ordMainMap.get(key),
// mod #11933 スケジュールのコピーでエラーコード500発生 関 start
// add 11555 指示履歴への記録の残り方が仕様と異なる zkm start
//          targetOrdMain,
          Stream.ofNullable(targetOrdMain)
            .collect(Collectors.toUnmodifiableList()),
// add 11555 指示履歴への記録の残り方が仕様と異なる zkm end
// mod #11933 スケジュールのコピーでエラーコード500発生 関 end
          treatMethodFlag,
          weeksArray);

        //パラメーターを取得
        indHistory = (IndHistory) indHistoryMap.get("パラメーター");
        //パラメータの対象、内容を文字列→配列に変換
        String[] paramTargetArray = indHistory.getLogTarget().split(",");
        //mod 8339 2023-02-06 名前に半角カンマが含まれる治療方法と紐づく治療方法セットを用いた際の動作不正 張 start
//        String[] paramContentArray = indHistory.getLogContent().split(",");
        JSONArray paramContentArray = new JSONArray(indHistory.getLogContent());
        //操作区分取得し、文字列→配列に変換
        String changeFlags = (String) indHistoryMap.get("操作区分");
        String[] changeFlagArray = changeFlags.split(",");

        switch (key) {
          //キーが"治療方法","スケジュール変更"の場合(操作区分が変更のみ、変更指示履歴に登録する対象と内容が1対1で対応)
          case "治療方法":
          case "スケジュール変更":
          case "治療条件":
            //指示履歴登録処理を実行
            for (int i = 0; i < paramTargetArray.length; i++) {
              //mod FNSI-6787 ljx start
              //履歴の内容に何も変更していない場合は履歴登録を行わない
//              if (paramContentArray[i].contains("→") && (paramContentArray[i].split("→")[0].equals(paramContentArray[i].split("→")[1]))) {
              if (paramContentArray.get(i).toString().contains("→") && (paramContentArray.get(i).toString().split("→")[0].equals(paramContentArray.get(i).toString().split("→")[1]))) {
                continue;
              }
              //mod FNSI-6787 ljx end
              //パラメータの内容を設定
              indHistory.setLogTarget(paramTargetArray[i]);
              //パラメータの内容を設定
              indHistory.setLogContent(paramContentArray.get(i).toString());
              //変更内容のフラグを作成(1.新規、2.変更,3.削除。)
              String changeFlag = "2";
              //変更有りの対象に関して、指示履歴の登録処理を行う(何も変更していない場合は履歴登録を行わない)
              if (! paramContentArray.get(i).toString().equals("未登録")) {
                //指示履歴時刻設定
                indHistory.setLogDate(setLogDate);
                //指示履歴登録処理
                this.createHistoryExecute(indHistory, changeFlag);
              }
            }
            break;
          //キーが"投与薬剤","医療材料","指示コメント"の場合(操作区分が新規と中止、対象1つに内容が新規と中止で1つずつ入る)
          case "投与薬剤":
          case "医療材料":
          case "指示コメント":
            //キーが投与薬剤で、投与薬剤を含めず登録する場合は、履歴を残さない
            if (treatMethodFlag.equals("2") && key.equals("投与薬剤")) break;

//            for (int j = 0; j < paramContentArray.length; j++) {
            for (int j = 0; j < paramContentArray.length(); j++) {
              //mod FNSI-6787 ljx start
              //履歴の内容に何も変更していない場合は履歴登録を行わない
//              if (paramContentArray[j].contains("→") && (paramContentArray[j].split("→")[0].equals(paramContentArray[j].split("→")[1]))) {
              if (paramContentArray.get(j).toString().contains("→") && (paramContentArray.get(j).toString().split("→")[0].equals(paramContentArray.get(j).toString().split("→")[1]))) {
                continue;
              }
              //mod FNSI-6787 ljx end
              //パラメータの内容を設定
//              indHistory.setLogContent(paramContentArray[j]);
              indHistory.setLogContent(paramContentArray.get(j).toString());
              //mod 8339 2023-02-06 名前に半角カンマが含まれる治療方法と紐づく治療方法セットを用いた際の動作不正 張 end
              //変更内容のフラグを作成(1.新規、2.変更,3.削除。)
              String changeFlag = changeFlagArray[j];
              //指示履歴時刻設定
              indHistory.setLogDate(setLogDate);
              //指示履歴登録処理
              this.createHistoryExecute(indHistory, changeFlag);
            }
            break;

          //キーが治療予定の場合(指示履歴は登録しない)
          default:
            break;
        }
      }
    }
  }

  /**
   * 指示履歴登録処理(治療方法Master変更)
   */
  @Override
  public void createMstTreatmentModifyHistory(String facilityCd, String patId, String indTreatmentName, Long indUserId, Long updUserId,
                                              TreatMethodChangeHelper treatCondSettingDiff) {
    if (mongoTemplate == null) return;

    String today = new SimpleDateFormat(FORMAT_DATE).format(new Date());
    //改行のための変数を取得
    String br = System.getProperty("line.separator");

    //  ---- ↓↓↓↓↓↓ 共有の項目を設定する処理 ↓↓↓↓↓↓ ---- start
    //クールコード
    IndHistory indHistoryBaseParams = new IndHistory();
    // 患者コード
    indHistoryBaseParams.setPatId(patId);
    // 施設コード
    indHistoryBaseParams.setFacilityCd(facilityCd);
    //指示履歴時刻設定
    indHistoryBaseParams.setLogDate(today);
    // 開始日
    indHistoryBaseParams.setTreatmentStartDate(today);
    // 終了日
    indHistoryBaseParams.setTreatmentEndDate("");
    // 曜日
    indHistoryBaseParams.setTreatmentWeekday("すべて");
    //治療方法名称をパラメータに設定
    indHistoryBaseParams.setTreatmentMethod(indTreatmentName);
    //クール名称をパラメータに設定
    indHistoryBaseParams.setTreatmentCourse("すべて");
    indHistoryBaseParams.setUpdatedUserId(updUserId);
    indHistoryBaseParams.setCreatedUserId(indUserId);
    //  ---- ↑↑↑↑↑↑ 共有の項目を設定する処理 ↑↑↑↑↑↑ ---- end

    List<IndHistory> indHistoryList = new ArrayList<>();

    //  ---- ↓↓↓↓↓↓ 治療条件 新規 る処理 ↓↓↓↓↓↓ ---- start
    if(treatCondSettingDiff.hasChangeToAdd()){
      IndHistory indHistory = new IndHistory();
      BeanUtils.copyProperties(indHistoryBaseParams,indHistory);
      indHistory.setLogClass("新規");

      indHistory.setLogTarget("治療条件");
      indHistory.setLogClass("新規");
      //治療条件内容
      StringBuilder logContent = new StringBuilder();
      for (TreatMethodChangeHelper.ItemAndValue itemAndValue : treatCondSettingDiff.getToAddCtlNoList()) {
        String treatCondItemName = this.gettingEditTarget(itemAndValue.getItem());
        String treatCondItemValue = itemAndValue.getValue();
        treatCondItemValue = StringUtils.hasLength(treatCondItemValue)? treatCondItemValue:"未登录";
        logContent.append(treatCondItemName);
        logContent.append(":");
        logContent.append(treatCondItemValue);
        logContent.append(br);
      }
      indHistory.setLogContent(logContent.toString());
      indHistoryList.add(indHistory);
    }
    //  ---- ↑↑↑↑↑↑ 治療条件 新規 る処理 ↑↑↑↑↑↑ ---- end

    //  ---- ↓↓↓↓↓↓ 治療条件 变更 る処理 ↓↓↓↓↓↓ ---- start
    if(treatCondSettingDiff.hasChangeToUpd()){
      IndHistory indHistory = new IndHistory();
      BeanUtils.copyProperties(indHistoryBaseParams,indHistory);
      indHistory.setLogTarget("治療条件");
      indHistory.setLogClass("变更");
      //治療条件内容
      StringBuilder logContent = new StringBuilder();
      for (TreatMethodChangeHelper.ItemAndValue itemAndValue : treatCondSettingDiff.getToUpdCtlNoList()) {
        String treatCondItemName = this.gettingEditTarget(itemAndValue.getItem());
        String treatCondItemValue = itemAndValue.getValue();
        treatCondItemValue = StringUtils.hasLength(treatCondItemValue)? treatCondItemValue:"未登录";
        logContent.append(treatCondItemName);
        logContent.append(":");
        logContent.append(treatCondItemValue);
        logContent.append(br);
      }
      indHistory.setLogContent(logContent.toString());
      indHistoryList.add(indHistory);
    }
    //  ---- ↑↑↑↑↑↑ 治療条件 变更 る処理 ↑↑↑↑↑↑ ---- end

    //  ---- ↓↓↓↓↓↓ 治療条件 中止 る処理 ↓↓↓↓↓↓ ---- start
    if(treatCondSettingDiff.hasChangeToDel()){
      IndHistory indHistory = new IndHistory();
      BeanUtils.copyProperties(indHistoryBaseParams,indHistory);
      indHistory.setLogClass("治療条件");
      indHistory.setLogClass("中止");
      //治療条件内容
      StringBuilder logContent = new StringBuilder();
      for (TreatMethodChangeHelper.ItemAndValue itemAndValue : treatCondSettingDiff.getToDelCtlNoList()) {
        String treatCondItemName = this.gettingEditTarget(itemAndValue.getItem());
        logContent.append(treatCondItemName);
        logContent.append(br);
      }
      //内容を設定
      indHistory.setLogContent(logContent.toString());
      indHistoryList.add(indHistory);
    }
    //  ---- ↑↑↑↑↑↑ 治療条件 中止 る処理 ↑↑↑↑↑↑ ---- end

    //  ---- ↓↓↓↓↓↓ 装置設定 変更 る処理 ↓↓↓↓↓↓ ---- end
    if(treatCondSettingDiff.isDeviceModelChanged()){
      IndHistory indHistory = new IndHistory();
      BeanUtils.copyProperties(indHistoryBaseParams,indHistory);
      indHistory.setLogTarget("装置設定");
      indHistory.setLogClass("变更");
      StringBuilder logContent = new StringBuilder();
      for(String changeContent: treatCondSettingDiff.getDeviceSetChangeContentList()){
        logContent.append(changeContent);
        logContent.append(br);
      }
      //内容を設定
      indHistory.setLogContent(logContent.toString());
      indHistoryList.add(indHistory);
    }
    //  ---- ↑↑↑↑↑↑ 治療条件 中止 る処理 ↑↑↑↑↑↑ ---- end

    if(!indHistoryList.isEmpty()) {
      this.createBatch(indHistoryList);
    }
  }

  /**
   * 指示履歴登録処理(治療予定・曜日パターン変更)
   *
   * @param bodyData       指示履歴作成に必要な値一覧
   * @param changWeekList  移動元→移動先曜日のリスト
   * @param srcDelWeekList 中止対象の曜日リスト
   */
  public void createWeekPatternHistory(ValiWeekPattern bodyData, HashMap<Short, List<Short>> changWeekList, List<Integer> srcDelWeekList) {
    //指示履歴用パラメータを定義し、各値を入力
    IndHistory indHistory;
    String setLogDate = new SimpleDateFormat(FORMAT_DATE).format(new Date());
    //患者コード
    String patId = bodyData.getPat_id();
    //施設コード
    String facilityCd = bodyData.getFacility_cd();
    // 開始日
    String startDate = bodyData.getInd_treat_start_date().replaceAll("-", "");
    // 終了日
    String endDate = !bodyData.getIs_deadline() ? "" : bodyData.getEnd_date().replaceAll("-", "");
    // 曜日
    List<Integer> srcWeekList = new ArrayList<>();
    for (Short weekKey : changWeekList.keySet()) {
      srcWeekList.add(weekKey.intValue());
    }
    List<Integer> weeksArray = new ArrayList<>();
    weeksArray.addAll(srcWeekList);
    weeksArray.addAll(srcDelWeekList);
    //治療方法コード
    String indTreatmentCd = bodyData.getInd_treatment_cd();
    //クールコード(処理上、指定がない為、「すべて」固定)
    String indKurCd = null;
    //指示者コード
    String indUserId = bodyData.getInd_user();
    //更新者コード
    String updUserId = bodyData.getUpd_user();
    // 指示履歴用パラメータに各値を入力
    // 患者コード、開始日、終了日、曜日、治療方法、クール、指示者、更新者を設定
    indHistory = this.setBasicParams(patId, startDate, endDate, weeksArray, indTreatmentCd, indKurCd, indUserId, updUserId, facilityCd);
    // 対象
    indHistory.setLogTarget("治療予定");
    // 内容を設定
    String contentText = "";
    for (int i = 1; i <= 7; i++) {
      // 移動元曜日に該当する
      if (srcWeekList.contains(i)) {
        String tmpStr = "、" + this.getWeekName(String.valueOf(i)) + "→";
        // 曜日番号リスト (1：月曜 ～ 7：日曜) / ソートしておく
        List<Short> toWeekList = changWeekList.get((short) i);
        Collections.sort(toWeekList);
        for (Short w : toWeekList) {
          // テキストを追加
          tmpStr += this.getWeekName(String.valueOf(w));
        }
        contentText += tmpStr;
      } else if (srcDelWeekList.contains(i)) {
        // 中止対象の曜日
        contentText += "、" + this.getWeekName(String.valueOf(i)) + "→中止";
      }
    }
    indHistory.setLogContent("曜日パターン変更" + System.getProperty("line.separator") + contentText.substring(1));
    //指示履歴時刻設定
    indHistory.setLogDate(setLogDate);
    //指示履歴登録処理
    this.createHistoryExecute(indHistory, "2");
  }

  /**
   * 治療予定用、指示履歴を登録する処理
   *
   * @param indHistory 登録する各項目一覧
   * @param key        登録対象のキー名
   * @param type       操作区分
   */
  private void planCreateHistoryExecute(IndHistory indHistory, String key, String type) {
    //対象、内容を文字列→配列に変換
    String[] paramTargetArray = indHistory.getLogTarget().split(",");
    JSONArray paramContentArray = new JSONArray(indHistory.getLogContent());
    //指示履歴登録処理を実行
    for (int i = 0; i < paramContentArray.length(); i++) {
      //パラメータの内容を設定
      indHistory.setLogContent(paramContentArray.get(i).toString());
      switch (key) {
        case "投与薬剤":
        case "医療材料":
        case "装置設定":
        case "指示コメント":
          //パラメータの対象を設定(対象1つに複数の内容が設定される)
          indHistory.setLogTarget(paramTargetArray[0]);
          //登録する値を設定しているか判定(投与薬剤、医療材料、指示コメントは設定値が無い場合、履歴登録を行わない)
          if (!paramContentArray.get(i).toString().equals("未登録")) {
            //指示履歴を登録
            this.createHistoryExecute(indHistory, type);
          }
          break;

        //治療予定、治療方法、スケジュール変更、治療条件の場合
        default:
          //パラメータの対象を設定(対象1つに内容1つが対応)
          indHistory.setLogTarget(paramTargetArray[i]);
          //指示履歴を登録
          this.createHistoryExecute(indHistory, type);
          break;
      }
    }
  }

  /**
   * 指示コメント用、履歴用パラメーター作成処理
   *
   * @param bodyData   必要パラメータの記載されたJson文字列
   * @param weeksArray 編集対象曜日
   * @return indHistory 指示履歴用パラメータ
   */
  private IndHistory createCommentHistoryParams(ValiCommentCreate bodyData, List<Integer> weeksArray, List<String> oldIndContents) {
    //指示履歴用パラメータ
    IndHistory indHistory = null;
    /**画面から取得した各値を取得*/
    //患者コード
    String patId = bodyData.getPat_id();
    //施設コード
    String facilityCd = bodyData.getFacility_cd();
    // 開始日
    String startDate = bodyData.getStart_date().replaceAll("-", "");
    // 終了日
    String endDate = "false".equals(bodyData.getIs_deadline()) ? "" : bodyData.getEnd_date().replaceAll("-", "");
    //治療方法コード
    String indTreatmentCd = bodyData.getInd_treatment_cd();
    //クールコード
    String indKurCd = bodyData.getInd_kur_cd();
    //コメント番号
    String contentNum = bodyData.getNum_comment();
    //指示コメント
    String indContent = bodyData.getComment();
    //指示者ID
    String indUserId = bodyData.getInd_user_id();
    //更新者ID
    String updUserId = bodyData.getUpd_user_id();
    //フラグ(1.新規、2.変更,3.削除)
    String flag = bodyData.getComment_flag();
    /**
     * 指示履歴用パラメータに各値を入力
     */
    /** 患者コード、開始日、終了日、曜日、治療方法、クール、指示者、更新者を設定*/
    indHistory = this.setBasicParams(patId, startDate, endDate, weeksArray, indTreatmentCd, indKurCd, indUserId, updUserId, facilityCd);
    /**対象 */
    indHistory.setLogTarget("指示コメント");
    /**内容 */
    //設定する内容を取得
    String paramContent = this.createCommentContent(flag, contentNum, indContent,oldIndContents);
    //内容を設定
    indHistory.setLogContent(paramContent);
    return indHistory;
  }

  /**
   * 履歴用パラメーター作成処理(治療予定(予定作成))
   *
   * @param bodyData       必要パラメータの記載されたJson文字列
   * @param key            Json文字列の、登録する各項目のキー名(治療予定、治療方法、治療条件、スケジュール変更、医療材料、投与薬剤、指示コメントのどれか)
   * @param ordMainValue   Json文字列の、登録する各項目の値(キー名に対応する値)
   * @param weeksArray     編集対象曜日
   * @param indTreatmentCd 治療方法コード
   * @return indHistory    指示履歴用パラメータ
   */
  public IndHistory createPlanHistoryParams(ValiCreateTreatPlan bodyData, String key, String ordMainValue,  List<Integer> weeksArray, String indTreatmentCd) {
    //指示履歴用パラメータ
    IndHistory indHistory = new IndHistory();

    /**画面から取得した各値を取得*/
    //施設コード
    String facilityCd = bodyData.getFacility_cd();
    //患者コード
    String patId = bodyData.getPat_id();
    //開始日
    String startDate = bodyData.getStart_date().replaceAll("-", "");
    //終了日
    String endDate = "false".equals(bodyData.getIs_deadline()) ? "" : bodyData.getEnd_date().replaceAll("-", "");
    String indKurCd = Objects.isNull(bodyData.getInd_kur_cd()) ? "" : bodyData.getInd_kur_cd();
    //指示者コード
    String indUserId = bodyData.getInd_user_id().toString();
    //更新者コード
    String updUserId = bodyData.getUpd_user_id().toString();

    /**指示履歴用パラメータに各値を入力*/
    /** 患者コード、開始日、終了日、曜日、治療方法、クール、指示者、更新者を設定*/
    indHistory = this.setBasicParams(patId, startDate, endDate, weeksArray, indTreatmentCd, indKurCd, indUserId, updUserId, facilityCd);

    /**対象 */
    //設定する対象
    // mod #10901 死亡患者受信時処理について fang start
//    String paramTarget = this.createPlanTarget(key);
    String paramTarget = this.createMethodTarget(key);
    // mod #10901 死亡患者受信時処理について fang end
    //対象を設定
    indHistory.setLogTarget(paramTarget);

    /**内容 */
    // mod #11933 スケジュールのコピーでエラーコード500発生 関 start
    // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm start
//    String paramContent = this.createplanContent(key, ordMainValue, facilityCd, "1");
    String paramContent = this.createplanContent(key, Stream.ofNullable(ordMainValue)
      .collect(Collectors.toUnmodifiableList()), facilityCd, "1");
    // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm end
    // mod #11933 スケジュールのコピーでエラーコード500発生 関 end
    //内容を設定
    indHistory.setLogContent(paramContent);

    return indHistory;
  }

  /**
   * 治療条件用、履歴用パラメーター作成処理
   *
   * @param bodyData   必要パラメータの記載されたJson文字列
   * @param weeksArray 編集対象曜日
   * @param ordMain    更新対象治療情報一覧
   * @return indHistory 指示履歴用パラメータ
   */
  private IndHistory createConditionHistoryParams(ValiUpdateIndCond bodyData, List<Integer> weeksArray, OrdMain ordMain) {

    //指示履歴用パラメータ
    IndHistory indHistory = new IndHistory();
    //治療条件内容
    JSONObject indInfo = new JSONObject(bodyData.getInd_cond_info());
    //入力内容(単位)
    JSONObject sendInfo = null;
    if (bodyData.getSend_condition_info() == null) {
      sendInfo = new JSONObject("{}");
    } else {
      sendInfo = new JSONObject(bodyData.getSend_condition_info());
    }
    // 数値及び単位をindInfoに反映
    for (int i = 1; i < 40; i++) {
      // mod FNSI-【1006】最新の改修対象一覧の411対応 韓 end
      if (indInfo.has(String.valueOf(i))) {
        if (sendInfo.has(String.valueOf(i))) {
          if (sendInfo.getJSONObject(String.valueOf(i)).has("unit")) {
            indInfo.getJSONObject(String.valueOf(i)).put("unit", sendInfo.getJSONObject(String.valueOf(i)).get("unit"));
          } else {
            indInfo.getJSONObject(String.valueOf(i)).put("unit", JSONObject.NULL);
          }
          if (sendInfo.getJSONObject(String.valueOf(i)).has("value_name_1")) {
            indInfo.getJSONObject(String.valueOf(i)).put("value_name_1", sendInfo.getJSONObject(String.valueOf(i)).get("value_name_1"));
          } else {
            indInfo.getJSONObject(String.valueOf(i)).put("value_name_1", JSONObject.NULL);
          }
        }
      }
    }

    //画面から取得した対象項目の項目番号の一覧を取得
    List<Integer> targetNumList = this.gettingTargetNum(indInfo);

    /**画面から取得した各値を取得*/
    //患者コード
    String patId = bodyData.getPat_id();
    //開始日
    String startDate = bodyData.getInd_start_date().replaceAll("-", "");
    //終了日
    String endDate = "false".equals(bodyData.getIs_deadline()) ? "" : bodyData.getInd_end_date().replaceAll("-", "");
    //施設コード
    String facilityCd = bodyData.getFacility_cd();
    //治療方法コード
    String indTreatmentCd = bodyData.getInd_treatment_cd();
    //クールコード
    String indKurCd = bodyData.getInd_kur_cd();
    //指示者ID
    String indUserId = null;
    //更新者ID
    String updUserId = null;

    /**指示履歴用パラメータに各値を入力*/

    /**指示者・更新者ID */
    //画面から取得した項目をJsonObjectで保持
    JSONObject jsonObjectTarget = indInfo.getJSONObject(String.valueOf(targetNumList.get(0)));
    //指示者・更新者IDを取得
    indUserId = jsonObjectTarget.has("ind_user_id") ? jsonObjectTarget.get("ind_user_id").toString() : "";
    updUserId = jsonObjectTarget.has("upd_user_id") ? jsonObjectTarget.get("upd_user_id").toString() : "";

    /** 患者コード、開始日、終了日、曜日、治療方法、クール、指示者、更新者を設定*/
    indHistory = this.setBasicParams(patId, startDate, endDate, weeksArray, indTreatmentCd, indKurCd, indUserId, updUserId, facilityCd);

    /**対象 */
    //設定する対象
    String paramTarget = this.createTreatCondTarget(targetNumList, indInfo);
    //対象を設定
    indHistory.setLogTarget(paramTarget);

    /**内容 */
    //設定する内容
    String paramContent = this.createTreatCondContent(indInfo, facilityCd, ordMain, targetNumList);
    //内容を設定
    indHistory.setLogContent(paramContent);
    indHistory.setOrdNo(ordMain.getOrdNo() == null ? null : ordMain.getOrdNo().toString());
    return indHistory;
  }

  /**
   * 医療材料用、履歴用パラメーター作成処理
   *
   * @param bodyData   必要パラメータの記載されたJson文字列
   * @param flag       判別フラグ(1.新規、2.変更,3.削除)
   * @param weeksArray 編集対象曜日
   * @param indInfoEquipmentList    更新対象治療情報
   * @return indHistory 指示履歴用パラメータ
   */
  public IndHistory createEquipmentHistoryParams(ValiOrdEquip bodyData, String flag, List<Integer> weeksArray, List<Map<String, String>> indInfoEquipmentList) {
    //指示履歴用パラメータ
    IndHistory indHistory = null;

    /**画面から取得した各値を取得*/
    //患者コード
    String patId = bodyData.getPat_id();
    //開始日
    String startDate = bodyData.getStart_date().replaceAll("-", "");
    //終了日
    String endDate = "false".equals(bodyData.getIs_deadline()) ?
      "" :
      bodyData.getEnd_date().replaceAll("-", "");
    //施設コード
    String facilityCd = bodyData.getFacility_cd();
    //治療方法コード
    String indTreatmentCd = bodyData.getInd_treatment_cd();
    //クールコード
    String indKurCd = bodyData.getInd_kur_cd();
    //医療材料内容
    JSONObject equipmentInfo = new JSONObject(bodyData.getInd_info());
    // mod bug 8128 修正 chen start
    //指示者ID
    String indUserId = equipmentInfo.has("ind_user_id") ? equipmentInfo.get("ind_user_id").toString() : "";
    //更新者ID
    String updUserId = equipmentInfo.has("upd_user_id") ? equipmentInfo.get("upd_user_id").toString() : "";
    // mod bug 8128 修正 chen end
    /* add #10196  by zhangruixue 2024-02-27 --start */
    //医療材料コード
    String equipmentCd = equipmentInfo.has("cd") ? equipmentInfo.get("cd").toString() : "";
    /* add #10196  by zhangruixue 2024-02-27 --end */
    //穴埋め有無
    String autoInsert = bodyData.getAuto_insert();
    //変更対象となる医療材料コード
    String targetEquipment = Objects.isNull(bodyData.getTarget_equip_edit()) ? "" : bodyData.getTarget_equip_edit();

    //削除の場合、数量を更新対象から取得(当日の治療情報の投与薬剤数量が自動的に格納されているため)
    if (flag.equals("3")) {
      //削除する投与薬剤一覧を取得
      // del 11555 指示履歴への記録の残り方が仕様と異なる zkm start
//      List<Map<String, String>> indInfoEquipmentList = this.changeListMap(ordMain.getIndEquipInfo());
      // del 11555 指示履歴への記録の残り方が仕様と異なる zkm end

      /* mod #10196  by zhangruixue 2024-02-27 --start */
//      //削除する投与薬剤の数量を取得
//      String amount = indInfoEquipmentList.get(0).get("amount");
//      equipmentInfo.put("amount", amount);
      for (Map<String, String> equipmentMap : indInfoEquipmentList) {
        for (Map.Entry<String, String> entry : equipmentMap.entrySet()) {
          if(entry.getKey().equals("cd") && entry.getValue().equals(equipmentCd)){
            String amount = equipmentMap.get("amount");
            equipmentInfo.put("amount", amount);
          }
        }
      }
      /* mod #10196  by zhangruixue 2024-02-27 --end */
    }


    /**指示履歴用パラメータに各値を入力*/
    /** 患者コード、開始日、終了日、曜日、治療方法、クール、指示者、更新者を設定*/
    indHistory = this.setBasicParams(
      patId,
      startDate,
      endDate,
      weeksArray,
      indTreatmentCd,
      indKurCd,
      indUserId,
      updUserId,
      facilityCd);

    /**対象 */
    indHistory.setLogTarget("医療材料");

    /**内容 */
    //設定する内容を取得
    String paramContent = this.createEquipmentContent(
      equipmentInfo,
      facilityCd,
      flag,
      autoInsert,
      targetEquipment,
      // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm start
//      ordMain);
      indInfoEquipmentList);
    // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm end
    //内容を設定
    indHistory.setLogContent(paramContent);

    return indHistory;
  }

  /**
   * 投与薬剤用、履歴用パラメーター作成処理
   *
   * @param bodyData      必要パラメータの記載されたJson文字列
   * @param flag          判別フラグ(1.新規、2.変更,3.削除)
   * @param weeksArray    編集対象曜日
   * @param targetOrdMains 更新対象治療情報
   * @return indHistory 指示履歴用パラメータ
   */
  public IndHistory createMedicineHistoryParams(ValiOrdMedi bodyData, String flag, List<Integer> weeksArray, List<OrdMain> targetOrdMains) {
    //指示履歴用パラメータ
    IndHistory indHistory = null;

    /**画面から取得した各値を取得*/
    //患者コード
    String patId = bodyData.getPat_id();
    //開始日
    String startDate = bodyData.getStart_date().replaceAll("-", "");
    //終了日
    String endDate = "false".equals(bodyData.getIs_deadline()) ?
      "" :
      bodyData.getEnd_date().replaceAll("-", "");
    //施設コード
    String facilityCd = bodyData.getFacility_cd();
    //治療方法コード
    String indTreatmentCd = bodyData.getInd_treatment_cd();
    //クールコード
    String indKurCd = bodyData.getInd_kur_cd();
    //投与薬剤内容
    JSONObject medicineInfo = new JSONObject(bodyData.getInd_info());
    //変更後回数
    // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm start
//    String nums = Objects.isNull(bodyData.getCount_after()) ? "" : bodyData.getCount_after();
    String nums = Boolean.FALSE.equals(bodyData.getNumber_of_doses()) || Objects.isNull(bodyData.getCount_after()) ? "" : bodyData.getCount_after();
    // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm end
    //初回投与日
    String indDayIntervalStartDate = bodyData.getInit_date();
    //投与間隔
    String indDayInterval = bodyData.getDate_interval();
    // mod bug 8128 修正 chen start
    //指示者ID
    String indUserId = medicineInfo.has("ind_user_id") ? medicineInfo.get("ind_user_id").toString() : "";
    //更新者ID
    String updUserId = medicineInfo.has("upd_user_id") ? medicineInfo.get("upd_user_id").toString() : "";
    // mod bug 8128 修正 chen end

    // add 11555 指示履歴への記録の残り方が仕様と異なる zkm start
    List<Map<String, String>> indInfoMedicineList = targetOrdMains.stream()
      .map(o -> changeListMap(o.getIndMediInfo()))
      .flatMap(List::stream)
      .filter(m -> m.get("no").equals(medicineInfo.get("no").toString()))
      .distinct().toList();
    // add 11555 指示履歴への記録の残り方が仕様と異なる zkm end

    //削除の場合、数量、初回投与日、投与間隔を更新対象から取得(当日の治療情報が自動的に格納されているため)
    if (flag.equals("3")) {
      //更新対象の治療情報にある投与薬剤一覧を取得
      // del 11555 指示履歴への記録の残り方が仕様と異なる zkm start
//      List<Map<String, String>> indInfoMedicineList = this.changeListMap(targetOrdMain.getIndMediInfo());
      // del 11555 指示履歴への記録の残り方が仕様と異なる zkm end

      for (Map<String, String> indInfoMedicine : indInfoMedicineList) {
        //削除する投与薬剤か判定
        if (indInfoMedicine.get("no").equals(medicineInfo.get("no").toString())) {
          //削除する投与薬剤の数量を取得
          String amount = indInfoMedicine.get("amount");
          medicineInfo.put("amount", amount);
          //削除する投与薬剤の初回投与日を取得
          indDayIntervalStartDate = indInfoMedicine.get("init_date");
          //削除する投与薬剤の投与間隔を取得
          indDayInterval = indInfoMedicine.get("date_interval");
        }
      }
    }

    /**指示履歴用パラメータに各値を入力*/
    /** 患者コード、開始日、終了日、曜日、治療方法、クール、指示者、更新者を設定*/
    indHistory = this.setBasicParams(
      patId,
      startDate,
      endDate,
      weeksArray,
      indTreatmentCd,
      indKurCd,
      indUserId,
      updUserId,
      facilityCd);

    // add 11555 指示履歴への記録の残り方が仕様と異なる zkm start
    if (!flag.equals("1")) {
      indHistory.setTreatmentWeekday("");
      if (Boolean.FALSE.equals(bodyData.getInterval_flg())) {
        indHistory.setTreatmentMethod("");
        indHistory.setTreatmentCourse("");
      }
    }
    // add 11555 指示履歴への記録の残り方が仕様と異なる zkm end

    /**対象 */
    indHistory.setLogTarget("投与薬剤");

    /**内容 */
    //設定する内容
    String paramContent = this.createMedicineContent(
      medicineInfo,
      facilityCd,
      flag,
      nums,
      indDayIntervalStartDate,
      indDayInterval,
      // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm start
//      targetOrdMain);
      indInfoMedicineList);
    // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm end
    //内容を設定
    indHistory.setLogContent(paramContent);

    return indHistory;
  }

  /**
   * 治療予定・治療日変更用、履歴用パラメーター作成処理
   *
   * @param bodyData     必要パラメータの記載されたJson文字列
   * @param preOrdMain   変更元の各項目の値一覧
   * @param key          Json文字列の、登録する各項目のキー名(治療予定、スケジュール変更のどちらか)
   * @param ordMainValue Json文字列の、登録する各項目の値(キー名に対応する値)
   * @param weeksArray   登録を行う曜日
   * @return indHistory    指示履歴用パラメータ
   */
  private IndHistory createMoveHistoryParams(ValiMoveTreatPlan bodyData, OrdMain preOrdMain, String key, String ordMainValue, List<Integer> weeksArray) {

    //指示履歴用パラメータ
    IndHistory indHistory = new IndHistory();

    /**画面から取得した各値を取得*/
    //施設コード
    String facilityCd = bodyData.getFacility_cd();
    //患者コード
    String patId = bodyData.getPat_id();
    //変更元開始日
    String startDate = preOrdMain.getTreatDate();
    //変更元終了日
    String endDate = preOrdMain.getTreatDate();
    //変更先日
    String dateTo = bodyData.getDialysis_date_to().replaceAll("-", "");
    //治療方法コード
    String indTreatmentCd = Objects.isNull(preOrdMain.getIndTreatmentCd()) ? "" : preOrdMain.getIndTreatmentCd().toString();
    //クールコード
    String indKurCd = Objects.isNull(preOrdMain.getIndKurCd()) ? "" : preOrdMain.getIndKurCd().toString();
    //指示者コード
    JSONObject indUserObject = new JSONObject(bodyData.getInd_schedule_user_info());
    String indUserId = indUserObject.has("ind_user_id") ? indUserObject.get("ind_user_id").toString() : "";
    //更新者コード
    String updUserId = bodyData.getUpd_user();

    /**指示履歴用パラメータに各値を入力*/
    /** 患者コード、開始日、終了日、曜日、治療方法、クール、指示者、更新者を設定*/
    indHistory = this.setBasicParams(patId, startDate, endDate, weeksArray, indTreatmentCd, indKurCd, indUserId, updUserId, facilityCd);

    /**対象 */
    //設定する対象(keyは治療予定かスケジュール変更の2種類)
    String paramTarget = key.equals("治療予定") ? "治療予定" : "クール,治療開始時刻,ベッド";
    //対象を設定
    indHistory.setLogTarget(paramTarget);

    //設定する内容
    String paramContent = this.createMoveContent(key, ordMainValue, startDate, dateTo,preOrdMain,bodyData);
    //内容を設定
    indHistory.setLogContent(paramContent);

    return indHistory;
  }

  /**
   * 治療予定・予定コピー用、履歴用パラメーター作成処理
   *
   * @param bodyData     必要パラメータの記載されたJson文字列
   * @param ordMain      コピー先の各項目の値一覧
   * @param key          Json文字列の、登録する各項目のキー名(治療予定、治療方法、治療条件、スケジュール変更、医療材料、投与薬剤、指示コメントのどれか)
   * @param ordMainValue Json文字列の、登録する各項目の値(キー名に対応する値)
   * @param weeksArray   コピー先の曜日
   * @return indHistory    指示履歴用パラメータ
   */
  private IndHistory createCopyHistoryParams(ValiCopyTreatPlan bodyData, OrdMain ordMain, String key, String ordMainValue, List<Integer> weeksArray) {

    //指示履歴用パラメータ
    IndHistory indHistory = new IndHistory();

    /**画面から取得した各値を取得*/
    //施設コード
    String facilityCd = bodyData.getFacility_cd();
    //患者コード
    String patId = bodyData.getPat_id();
    //コピー先開始日
    String startDate = bodyData.getDialysis_date_to().replaceAll("-", "");
    //コピー先終了日
    String endDate = bodyData.getDialysis_date_to().replaceAll("-", "");
    //治療方法コード
    String indTreatmentCd = Objects.isNull(ordMain.getIndTreatmentCd()) ? "" : ordMain.getIndTreatmentCd().toString();
    //クールコード
    String indKurCd = Objects.isNull(ordMain.getIndKurCd()) ? "" : ordMain.getIndKurCd().toString();
    //指示者コード
    String indUserId = bodyData.getInd_user();
    //更新者コード
    String updUserId = bodyData.getUpd_user();

    /**指示履歴用パラメータに各値を入力*/
    /** 患者コード、開始日、終了日、曜日、治療方法、クール、指示者、更新者を設定*/
    indHistory = this.setBasicParams(patId, startDate, endDate, weeksArray, indTreatmentCd, indKurCd, indUserId, updUserId, facilityCd);

    /**対象 */
    //設定する対象
    // mod #10901 死亡患者受信時処理について fang start
//    String paramTarget = this.createPlanTarget(key);
    String paramTarget = this.createMethodTarget(key);
    // mod #10901 死亡患者受信時処理について fang end
    //対象を設定
    indHistory.setLogTarget(paramTarget);

    /**内容 */
    //設定する内容
    // mod #11933 スケジュールのコピーでエラーコード500発生 関 start
    // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm start
//    String paramContent = this.createplanContent(key, ordMainValue, facilityCd, "1");
    String paramContent = this.createplanContent(key, Stream.ofNullable(ordMainValue)
      .collect(Collectors.toUnmodifiableList()), facilityCd, "1");
    // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm end
    // mod #11933 スケジュールのコピーでエラーコード500発生 関 end
    //内容を設定
    indHistory.setLogContent(paramContent);

    return indHistory;
  }

  /**
   * スケジュール変更用、履歴用パラメーター作成処理
   *
   * @param bodyData   必要パラメータの記載されたJson文字列
   * @param weeksArray 編集対象曜日
   * @param ordMain    更新対象治療情報
   * @return indHistory 指示履歴用パラメータ
   */
  private IndHistory createScheduleHistoryParams(ValiUpdateIndSchedule bodyData, List<Integer> weeksArray, OrdMain ordMain, String paramTarget) {
    //指示履歴用パラメータ
    IndHistory indHistory = new IndHistory();

    /**画面から取得した各値を取得*/
    //施設コード
    String facilityCd = bodyData.getFacility_cd();
    //患者コード
    String patId = bodyData.getPat_id();
    //開始日
    String startDate = bodyData.getInd_start_date().replaceAll("-", "");
    //終了日
    String endDate = "false".equals(bodyData.getIs_deadline()) ? "" : bodyData.getInd_end_date().replaceAll("-", "");
    //治療方法コード
    String selectTreatmentCd = bodyData.getInd_treatment_cd();
    //クールコード
    String selectKurCd = bodyData.getInd_kur_cd();
    //変更前クールコード(既存が未登録の場合は0、新たに登録する値が未登録の場合はnullが渡されている→"0"に変換)
    String indKurCd = Objects.isNull(ordMain.getIndKurCd()) || ordMain.getIndKurCd() == 0 ? "0" : String.valueOf(ordMain.getIndKurCd());
    //変更前治療開始時刻
    String indTreatStartTime = "未登録";
    //文字列→時刻表記に変換(取得した値がnullの場合は"未登録")
    if (! Objects.isNull(ordMain.getIndTreatStartTime())) {
      SimpleDateFormat TreatTimeFormat = new SimpleDateFormat("HHmm");
      Date treatTimeDate = null;
      try {
        treatTimeDate = TreatTimeFormat.parse(ordMain.getIndTreatStartTime());
      } catch (ParseException e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        if (!StringUtils.isEmpty(facilityCd)) {
          eventLogMessage.setFacilityCd(facilityCd);
        }
        logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
      }
      indTreatStartTime = new SimpleDateFormat("HH:mm").format(treatTimeDate);
    }
    //変更前ベッドコード
    String indBedCd = Objects.isNull(ordMain.getIndBedCd()) || ordMain.getIndBedCd() == 0 ? "0" : String.valueOf(ordMain.getIndBedCd());
    //変更後クールコード
    String editIndKurCd = bodyData.getEdit_ind_kur_cd();
    //変更後治療開始時刻
    String editIndTreatStartTime = Objects.isNull(bodyData.getEdit_ind_treat_start_time()) ? "未登録" : bodyData.getEdit_ind_treat_start_time();
    //変更後ベッドコード
    String editIndBedCd = bodyData.getEdit_ind_bed_cd();
    //指示者コード
    String indUserId = bodyData.getInd_user_id();
    //更新者コード
    String updUserId = bodyData.getUpd_user_id();

    /**指示履歴用パラメータに各値を入力*/
    /** 患者コード、開始日、終了日、曜日、治療方法、クール、指示者、更新者を設定*/
    indHistory = this.setBasicParams(patId, startDate, endDate, weeksArray, selectTreatmentCd, selectKurCd, indUserId, updUserId, facilityCd);

    /**対象 */
    //設定する対象
    indHistory.setLogTarget(paramTarget);

    /**内容 */
    //設定する内容
    String paramContent = this.createScheduleContent(facilityCd, indKurCd, indTreatStartTime, indBedCd, editIndKurCd, editIndTreatStartTime, editIndBedCd);
    //内容を設定
    indHistory.setLogContent(paramContent);
    return indHistory;
  }

  /**
   * 装置設定、履歴用パラメーター作成処理
   *
   * @param bodyData   必要パラメータの記載されたJson文字列
   * @param weeksArray 編集対象曜日
   * @param ordMain    更新対象治療情報一覧
   * @return indHistory 指示履歴用パラメータ
   */
  public IndHistory createDeviceSetInfoHistoryParams(ValiDeviceSetInfo bodyData, List<Integer> weeksArray, OrdMain ordMain) {

    //指示履歴用パラメータ
    IndHistory indHistory = new IndHistory();
    //装置設定内容
    JSONObject deviceSetInfo = new JSONObject(bodyData.getInd_device_set_info());

    /**画面から取得した各値を取得*/
    //患者コード
    String patId = bodyData.getPat_id();
    //開始日
    String startDate = bodyData.getStart_date().replaceAll("-", "");
    //終了日
    String endDate = "false".equals(bodyData.getIs_deadline()) ? "" : bodyData.getEnd_date().replaceAll("-", "");
    //施設コード
    String facilityCd = bodyData.getFacility_cd();
    //治療方法コード
    String indTreatmentCd = bodyData.getInd_treatment_cd();
    //クールコード
    String indKurCd = bodyData.getInd_kur_cd();
    //指示者ID
    String indUserId = null;
    //更新者ID
    String updUserId = null;

    /**指示者・更新者ID */
    //指示者・更新者IDを取得
    JSONObject userObject =  getJsonByImageFlag(deviceSetInfo,StringUtils.hasText(bodyData.getImage_flg()) ? bodyData.getImage_flg() : null);
    indUserId = userObject.has("ind_user_id") ? userObject.get("ind_user_id").toString() : "";
    updUserId = userObject.has("upd_user_id") ? userObject.get("upd_user_id").toString() : "";

    /** 患者コード、開始日、終了日、曜日、治療方法、クール、指示者、更新者を設定*/
    indHistory = this.setBasicParams(patId, startDate, endDate, weeksArray, indTreatmentCd, indKurCd, indUserId, updUserId, facilityCd);

    /**対象 */
    //対象を設定
    indHistory.setLogTarget("装置設定");

    /**内容 */
    //設定する内容
    String paramContent = this.createDeviceSetInfoContent(bodyData, ordMain);
    //内容を設定
    indHistory.setLogContent(paramContent);
    indHistory.setOrdNo(ordMain.getOrdNo().toString());
    return indHistory;
  }

  /**
   * 治療予定・予定中止用、履歴用パラメーター作成処理
   *
   * @param bodyData     必要パラメータの記載されたJson文字列
   * @param key          Json文字列の、登録する各項目のキー名(治療予定、治療方法、治療条件、スケジュール変更、医療材料、投与薬剤、指示コメントのどれか)
   * @param ordMainValue Json文字列の、登録する各項目の値(キー名に対応する値)
   * @param weeksArray   中止を行う曜日
   * @return indHistory    指示履歴用パラメータ
   */
  private IndHistory createDeleteHistoryParamsByDeleteIndPlanPatInfo(ValiDeleteIndPlanPatInfo bodyData,
                                                                     String key, String ordMainValue, List<Integer> weeksArray, String dialysisDateFrom, String dialysisDateTo) {

    //指示履歴用パラメータ
    IndHistory indHistory = new IndHistory();

    /**画面から取得した各値を取得*/
    //施設コード
    String facilityCd = bodyData.getFacility_cd();
    //患者コード
    String patId = bodyData.getPat_id();
    //治療方法コード
    String indTreatmentCd = Objects.isNull(bodyData.getTreatment_cd()) ? "" : bodyData.getTreatment_cd();
    //クールコード
    String indKurCd = Objects.isNull(bodyData.getKur_cd()) ? "" : bodyData.getKur_cd();
    //指示者コード
    String indUserId = bodyData.getInd_user_id();
    //更新者コード
    String updUserId = bodyData.getUpd_user_id();

    /**指示履歴用パラメータに各値を入力*/
    /** 患者コード、開始日、終了日、曜日、治療方法、クール、指示者、更新者を設定*/
    indHistory = this.setBasicParams(patId, dialysisDateFrom, dialysisDateTo, weeksArray, indTreatmentCd, indKurCd, indUserId, updUserId, facilityCd);

    /**対象 */
    //設定する対象
    // mod #10901 死亡患者受信時処理について fang start
//    String paramTarget = this.createPlanTarget(key);
    String paramTarget = this.createMethodTarget(key);
    // mod #10901 死亡患者受信時処理について fang end
    //対象を設定
    indHistory.setLogTarget(paramTarget);

    /**内容 */
    //設定する内容
    // mod #11933 スケジュールのコピーでエラーコード500発生 関 start
    // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm start
//    String paramContent = this.createplanContent(key, ordMainValue, facilityCd, "3");
    String paramContent = this.createplanContent(key, Stream.ofNullable(ordMainValue)
      .collect(Collectors.toUnmodifiableList()), facilityCd, "3");
    // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm end
    // mod #11933 スケジュールのコピーでエラーコード500発生 関 end
    //内容を設定
    indHistory.setLogContent(paramContent);

    return indHistory;
  }

  /**
   * 指示履歴に登録する、共有の項目を設定する処理
   *
   * @param patId          患者コード
   * @param startDate      開始日
   * @param endDate        終了日
   * @param weeksArray     曜日
   * @param indTreatmentCd 治療方法コード
   * @param indKurCd       クールコード
   * @param indUserId      指示者コード
   * @param updUserId      更新者コード
   * @param facilityCd     施設コード
   * @return 指示履歴用パラメータ
   */
  private IndHistory setBasicParams(String patId, String startDate, String endDate, List<Integer> weeksArray,
                                    String indTreatmentCd, String indKurCd, String indUserId, String updUserId, String facilityCd) {
    //指示履歴作成用のパラメータ
    IndHistory indHistory = new IndHistory();

    /** パラメータを設定*/
    /** 患者コード*/
    indHistory.setPatId(patId);
    /** 施設コード */
    indHistory.setFacilityCd(facilityCd);
    /**開始日 */
    indHistory.setTreatmentStartDate(String.valueOf(startDate));
    /**終了日 */
    indHistory.setTreatmentEndDate(String.valueOf(endDate));

    /**曜日 */
    //セットする曜日番号
    String paramWeeksArray = this.changeWeekday(weeksArray);
    //パラメータに設定
    indHistory.setTreatmentWeekday(paramWeeksArray);

    /**治療方法 */
    //セットする治療方法名称
    String paramTreatmentName = this.changeTreatment(indTreatmentCd, facilityCd);
    //治療方法名称をパラメータに設定
    indHistory.setTreatmentMethod(paramTreatmentName);

    /**クール */
    //セットするクール名称
    String paramKurName = this.changekur(indKurCd, facilityCd);
    //クール名称をパラメータに設定
    indHistory.setTreatmentCourse(paramKurName);

    /**指示者、更新者*/
    //セットする指示者氏名
    String paramIndUserName = null;
    // mod #10901 死亡患者受信時処理について fang start
    if("null".compareTo(indUserId) != 0 && !"0".equals(indUserId)){
      // mod #10901 死亡患者受信時処理について fang end
      paramIndUserName = this.changeUserName(indUserId, facilityCd);
    }

    //セットする更新者氏名
    String paramUpdUserName = null;
    // mod #10901 死亡患者受信時処理について fang start
    if("null".compareTo(updUserId) != 0 && !"0".equals(indUserId)) {
      // mod #10901 死亡患者受信時処理について fang end
      paramUpdUserName = this.changeUserName(updUserId, facilityCd);
    }    //指示者氏名をパラメータに設定
    indHistory.setCreatedBy(paramIndUserName);
    //更新者氏名をパラメータに設定
    indHistory.setUpdatedBy(paramUpdUserName);
    //指示者氏名をパラメータに設定
    Long userIdInd = null;
    if ("null".compareTo(indUserId) != 0) {
      userIdInd = Long.parseLong(indUserId);
    }
    indHistory.setCreatedUserId(userIdInd);
    //更新者氏名をパラメータに設定
    Long userIdUpd = null;
    if ("null".compareTo(updUserId) != 0) {
      userIdUpd = Long.parseLong(updUserId);
    }
    indHistory.setUpdatedUserId(userIdUpd);

    return indHistory;
  }

  /**
   * 指示履歴に登録する、治療条件対象を作成する処理
   *
   * @param targetNumList 画面から取得した対象項目の項目番号の一覧
   * @return 治療条件対象
   */
  private String createTreatCondTarget(List<Integer> targetNumList, JSONObject indInfo) {
    //設定する対象
    String paramTarget = null;
    //編集を行った対象項目一覧
    List<String> paramTargetList = new ArrayList<>();

    //編集を行った治療条件の項目分、対象をリストに追加
    for (int num : targetNumList) {
      //項目番号に該当する項目名称を取得
      String editTargrt = this.gettingEditTarget(String.valueOf(num));
      //該当の項目名称をリストに追加
      paramTargetList.add(editTargrt);
      // add #2856：DWの指示履歴登録対応 韓 start
      if (num == 3) {
        JSONObject condInfo = indInfo.getJSONObject(String.valueOf(num));
        if (condInfo.has("indicator_start_date") && condInfo.has("value_dw")) {
          // 身体情報画面上に「目標体重」が変更なしの場合、登録目標から外す
          if (condInfo.opt("init_value").equals(condInfo.opt("value")) ||
            (Objects.equals(condInfo.opt("indicator_start_date"), null) &&
              !Objects.equals(condInfo.opt("value_dw"), null))) {
            paramTargetList.remove(editTargrt);
          }
          if (!Objects.equals(condInfo.opt("value_dw"), null) &&
            !condInfo.opt("value_dw").equals(condInfo.opt("init_value_dw"))) {
            paramTargetList.add("DW");
          }
        }
      }
    }
    //リスト→文字列に変換
    paramTarget = paramTargetList.size() > 0 ? String.join(",", paramTargetList) : null;
    return paramTarget;
  }

  /**
   * 指示履歴に登録する、治療条件内容を作成する処理（画面編集）
   *
   * @param indInfo       画面から取得した治療条件詳細
   * @param facilityCd    施設コード
   * @param ordMain       編集前の値一覧
   * @param targetNumList 編集を行った対象項目の項目番号の一覧
   * @return 治療条件内容
   */
  private String createTreatCondContent(JSONObject indInfo, String facilityCd, OrdMain ordMain, List<Integer> targetNumList) {
    //設定する内容
    String paramContent = null;
    //編集を行った対象項目一覧
    List<String> paramContentList = new ArrayList<>();
    String indDw = ordMain.getIndDw() != null ? ordMain.getIndDw().toString() : null;

    //更新対象となる治療情報をJsonObjectで保持
    String indCondInfoTmp = ordMain.getIndCondInfo();
    if (indCondInfoTmp == null) {
      indCondInfoTmp = "{}";
    }
    JSONObject ordMainCond = new JSONObject(indCondInfoTmp);

    //治療条件の項目番号分、番号の比較を行う
    for (int num : targetNumList) {
      if (!ordMainCond.has(String.valueOf(num)) && !(num == 39)) {
        paramContentList.add(null);
        continue;
      }

      //画面から取得した項目をJsonObjectで保持
      JSONObject condInfo = indInfo.getJSONObject(String.valueOf(num));

      //変更前治療条件の単位取得のため、透析液・補液・抗凝固剤編集の場合は投与薬剤コードを取得
      Object preMedicineCd = null;
      Object preMedicineType = null;
      Object preMedicineUnit = null;
      try {
        //透析液編集の場合
        if (num >= 15 && num <= 18) {
          if (ordMainCond.optJSONObject("15") != null) {
            preMedicineCd = ordMainCond.getJSONObject("15").get("value");
            preMedicineType = ordMainCond.getJSONObject("15").get("medicine_type");
            preMedicineUnit = ordMainCond.getJSONObject(String.valueOf(num)).get("unit");
          }
          //補液編集の場合
        } else if (num >= 19 && num <= 24) {
          if (ordMainCond.optJSONObject("19") != null) {
            preMedicineCd = ordMainCond.getJSONObject("19").get("value");
            preMedicineType = ordMainCond.getJSONObject("19").get("medicine_type");
            preMedicineUnit = ordMainCond.getJSONObject(String.valueOf(num)).get("unit");
          }
          //抗凝固剤の場合
        } else if (num >= 25 && num <= 38) {
          if (ordMainCond.optJSONObject("25") != null) {
            preMedicineCd = ordMainCond.getJSONObject("25").get("value");
            preMedicineType = ordMainCond.getJSONObject("25").get("medicine_type");
            preMedicineUnit = ordMainCond.getJSONObject(String.valueOf(num)).get("unit");
          }
        }
      } catch (Exception e) {
        //薬剤が存在しない
        preMedicineCd = null;
        preMedicineType = null;
        preMedicineUnit = null;
      }

      //変更後治療条件の単位取得のため、透析液・補液・抗凝固剤編集の場合は投与薬剤コードを取得
      Object editMedicineCd = null;
      Object editMedicineType = null;
      Object editMedicineUnit = null;
      try {
        //透析液編集の場合
        if (num >= 15 && num <= 18) {
          if (indInfo.optJSONObject("15") != null) {
            editMedicineCd = indInfo.getJSONObject("15").get("value");
            editMedicineType = indInfo.getJSONObject("15").get("medicine_type");
            editMedicineUnit = indInfo.getJSONObject(String.valueOf(num)).get("unit");
          }
          //補液編集の場合
        } else if (num >= 19 && num <= 24) {
          if (indInfo.optJSONObject("19") != null) {
            editMedicineCd = indInfo.getJSONObject("19").get("value");
            editMedicineType = indInfo.getJSONObject("19").get("medicine_type");
            editMedicineUnit = indInfo.getJSONObject(String.valueOf(num)).get("unit");
          }
          //抗凝固剤の場合
        } else if (num >= 25 && num <= 38) {
          if (indInfo.optJSONObject("25") != null) {
            editMedicineCd = indInfo.getJSONObject("25").get("value");
            editMedicineType = indInfo.getJSONObject("25").get("medicine_type");
            editMedicineUnit = indInfo.getJSONObject(String.valueOf(num)).get("unit");
          }
        }
      } catch (Exception e) {
        editMedicineCd = preMedicineCd;
        editMedicineType = preMedicineType;
        editMedicineUnit = indInfo.getJSONObject(String.valueOf(num)).get("unit");
      }
      String content = "";
      String previousValue = num == 39 ? indDw
        : this.gettingValue(String.valueOf(num), ordMainCond.getJSONObject(String.valueOf(num)), facilityCd, preMedicineCd, preMedicineType);
      String preCondUnit =
        previousValue.equals("未登録") || previousValue.equals("DWと同じ")
          ? ""
          : this.gettingCondUnit(String.valueOf(num), facilityCd, preMedicineCd, preMedicineType, preMedicineUnit);
      //変更後の値を取得
      String editValue = this.gettingValue(String.valueOf(num), condInfo, facilityCd, editMedicineCd, editMedicineType);
      //変更後の治療条件の単位を取得
      String editCondUnit =
        editValue.equals("未登録") || editValue.equals("DWと同じ")
          ? ""
          : this.gettingCondUnit(String.valueOf(num), facilityCd, editMedicineCd, editMedicineType, editMedicineUnit);
      //内容に設定する文章を作成
      content = previousValue + preCondUnit + "→" + editValue + editCondUnit;
      if (! previousValue.equals(editValue)) {
        //変更後の値をリストに追加
        paramContentList.add(content);
      } else {
        paramContentList.add("null");
      }
    }
    //リスト→文字列に変換
    paramContent = paramContentList.size() > 0 ?JSONObject.valueToString(paramContentList): null;
    return paramContent;
  }


  /**
   * 治療予定(治療日変更)の内容作成処理
   *
   * @param key          Json文字列の、登録する各項目のキー名(治療方法、治療条件、スケジュール変更、医療材料、投与薬剤、指示コメントのどれか)
   * @param ordMainValue Json文字列の、登録する各項目の値(キー名に対応する値)
   * @param dateFrom     変更元治療日
   * @param dateTo       変更先治療日
   * @return 治療予定の対象
   */
  private String createMoveContent(String key, String ordMainValue, String dateFrom, String dateTo,OrdMain preOrdMain, ValiMoveTreatPlan bodyData) {
    //変更後クールコード
    String indKurCd = StringUtils.isEmpty(bodyData.getInd_kur_cd()) ? "0" : bodyData.getInd_kur_cd();
    //変更後ベッドコード
    String indBedCd = StringUtils.isEmpty(bodyData.getInd_bed_cd()) ? "0" : String.valueOf(bodyData.getInd_bed_cd());
    //変更後クールコードをクール名称に変換
    String indKurName = indKurCd.equals("0") ? "未登録" : this.changekur(indKurCd, preOrdMain.getFacilityCd());
    //変更後ベッドコードをベッド名称に変換
    String indBedName = indBedCd.equals("0") ? "未登録" : this.changeBed(indBedCd, preOrdMain.getFacilityCd());

    //設定する内容
    String paramContent = null;
    //内容に記載する文章のリスト
    List<String> paramContentList = new ArrayList<>();

    //変更元日と変更先日を年月日表記に変換
    String preChangeDate = null;
    String nextChangeDate = null;

    SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
    Date preDate = null;
    Date nextDate = null;
    try {
      preDate = sdf.parse(dateFrom);
      nextDate = sdf.parse(dateTo);
    } catch (ParseException e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (preOrdMain != null && !StringUtils.isEmpty(preOrdMain.getFacilityCd())) {
        eventLogMessage.setFacilityCd(preOrdMain.getFacilityCd());
      }
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
    }
    preChangeDate = new SimpleDateFormat("yyyy/MM/dd ").format(preDate);
    nextChangeDate = new SimpleDateFormat("yyyy/MM/dd ").format(nextDate);

    //項目毎に内容を作成
    switch (key) {
      //治療予定の場合
      case "治療予定":
        //内容を作成してリストに追加
        paramContentList.add(preChangeDate + "→" + nextChangeDate);
        break;
      //スケジュール変更の場合
      default:
        //クール、治療開始時刻、ベッドの値を配列で保持
        JSONArray valueArray = new JSONArray(ordMainValue);
        //各項目の内容をリストに追加
        for (int i = 0; i <valueArray.length() ; i++) {
          //内容を作成
          String value="";
          if (0==i) {
            value = valueArray.get(i).toString()+ "→" +   indKurName ;
          }else if(1==i){
            value = valueArray.get(i).toString() + "→" + valueArray.get(i).toString() ;
          }else if(2==i){
            value = valueArray.get(i).toString() + "→" + indBedName;
          }
          //内容をリストに追加
          paramContentList.add(value);
        }
        break;
    }
    //内容のリスト→文字列に変換
    paramContent = JSONObject.valueToString(paramContentList);

    return paramContent;
  }

  /**
   * 治療方法用、履歴用パラメーター作成処理
   *
   * @param bodyData        必要パラメータの記載されたJson文字列
   * @param key             Json文字列の、変更後の各項目のキー名(治療方法、治療条件、スケジュール変更、医療材料、投与薬剤、指示コメントのどれか)
   * @param ordMainValue    Json文字列の、変更後の各項目の値(キー名に対応する値)
   * @param changeOrdMainList   変更対象となる、変更前の各項目の値一覧
   * @param treatMethodFlag 治療方法の編集方法を判定するフラグ(0:治療方法のみ 1:投与薬剤含めて変更 2:投与薬剤含めず変更)
   * @param weeksArray      編集対象曜日
   * @return indHistoryMap    指示履歴用パラメータと操作区分
   */
  private Map<String, Object> createMethodHistoryParams(ValiCreateTreatPlan bodyData, String key, String ordMainValue,
                                                        List<OrdMain> changeOrdMainList, String treatMethodFlag, List<Integer> weeksArray) {
    //指示履歴用パラメータ
    IndHistory indHistory = new IndHistory();
    //指示履歴用パラメータと操作区分
    Map<String, Object> indHistoryMap = new HashMap<>();

    /**画面から取得した各値を取得*/
    //施設コード
    String facilityCd = bodyData.getFacility_cd();
    //患者コード
    String patId = bodyData.getPat_id();
    //開始日
    String startDate = bodyData.getStart_date().replaceAll("-", "");
    //終了日
    String endDate = "false".equals(bodyData.getIs_deadline()) ?
      "" :
      bodyData.getEnd_date().replaceAll("-", "");
    //変更対象となる治療方法コード
    // mod 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関  strat
    // String indTreatmentCd = bodyData.getTarget_treatment_cd();
    String indTreatmentCd = bodyData.getInd_treatment_cd();
    //クールコード
    // String indKurCd = bodyData.getTarget_kur_cd();
    String indKurCd = bodyData.getInd_kur_cd();
    // mod 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関  end
    //指示者コード
    String indUserId = bodyData.getInd_user_id().toString();
    //更新者コード
    String updUserId = bodyData.getUpd_user_id().toString();


    /**指示履歴用パラメータに各値を入力*/
    /** 患者コード、開始日、終了日、曜日、治療方法、クール、指示者、更新者を設定*/
    indHistory = this.setBasicParams(
      patId,
      startDate,
      endDate,
      weeksArray,
      indTreatmentCd,
      indKurCd,
      indUserId,
      updUserId,
      facilityCd);

    /**対象 */
    //設定する対象
    String paramTarget = this.createMethodTarget(key);
    //対象を設定
    indHistory.setLogTarget(paramTarget);

    /**内容 */
    //設定する内容と操作区分を取得
    // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm start
//    Map<String, List<String>> paramContentMap =
//      this.createMethodContent(targetOrdMain, key, ordMainValue, treatMethodFlag, facilityCd);
    Map<String, List<String>> paramContentMap = this.createMethodContent(changeOrdMainList, key, ordMainValue, treatMethodFlag, facilityCd);

    //内容のリスト→文字列に変換
//    String paramContent = String.join(",", paramContentMap.get("内容"));
    String paramContent = JSONObject.valueToString(paramContentMap.get("内容"));
    // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm end
    //内容の中身が何も設定されていない場合、"未登録"と設定
    if (paramContent.isEmpty()) paramContent = "未登録";
    //内容を設定
    indHistory.setLogContent(paramContent);

    /** 指示履歴用パラメータと操作区分の格納処理*/
    //操作区分のリスト→文字列に変換
    String changeFlag = String.join(",", paramContentMap.get("操作区分"));
    //指示履歴用パラメータと操作区分を格納
    indHistoryMap.put("パラメーター", indHistory);
    indHistoryMap.put("操作区分", changeFlag);

    return indHistoryMap;
  }

  /**
   * 指示履歴登録処理を実行
   *
   * @param indHistory 登録用指示履歴
   * @param flag       フラグ(1.新規、2.変更,3.削除、4.治療日変更)
   */
  @Override
  public void createHistoryExecute(IndHistory indHistory, String flag) {
    //操作区分の値を設定
    switch (flag) {
      //新規の場合
      case "1":
        indHistory.setLogClass("新規");
        break;
      //変更の場合
      case "2":
        indHistory.setLogClass("変更");
        break;
      //削除の場合
      case "3":
        indHistory.setLogClass("中止");
        break;
      //治療日変更の場合
      default:
        indHistory.setLogClass("治療日変更");
        break;
    }

    // log_targetに合わせたソート順をセット
    indHistory.setSortNo(sortMap.get(indHistory.getLogTarget()));

    //MongoDBに接続しているか判定
    if (mongoTemplate != null) {
      //指示履歴登録処理
      this.create(indHistory);
    }
  }

  /**
   * 指示履歴登録処理を実行
   * @param indHistoryList 登録用指示履歴
   * @param flag       フラグ(1.新規、2.変更,3.削除、4.治療日変更)
   */
  @Override
  public void createHistoryExecuteBatch(List<IndHistory> indHistoryList, String flag) {
    for (IndHistory indHistory:indHistoryList) {
      //操作区分の値を設定
      switch (flag) {
        //新規の場合
        case "1":
          indHistory.setLogClass("新規");
          break;
        //変更の場合
        case "2":
          indHistory.setLogClass("変更");
          break;
        //削除の場合
        case "3":
          indHistory.setLogClass("中止");
          break;
        //治療日変更の場合
        default:
          indHistory.setLogClass("治療日変更");
          break;
      }
      // log_targetに合わせたソート順をセット
      indHistory.setSortNo(sortMap.get(indHistory.getLogTarget()));
    }
    //MongoDBに接続しているか判定
    if (mongoTemplate != null)
      //指示履歴登録処理
      this.createBatch(indHistoryList);
  }


  /**
   * 指示履歴に登録する、スケジュール変更内容を作成する処理
   *
   * @param facilityCd            施設コード
   * @param indKurCd              変更前クールコード
   * @param indTreatStartTime     変更前治療開始時刻
   * @param indBedCd              変更前ベッドコード
   * @param editIndKurCd          変更後クールコード
   * @param editIndTreatStartTime 変更後治療開始時刻
   * @param editIndBedCd          変更後ベッドコード
   * @return スケジュール変更内容
   */
  public String createScheduleContent(String facilityCd, String indKurCd, String indTreatStartTime,String indBedCd,
    String editIndKurCd, String editIndTreatStartTime, String editIndBedCd) {

    //設定する内容
    String paramContent = null;
    //設定する内容一覧
    List<String> paramContentList = new ArrayList<>();

    //変更前クールコードをクール名称に変換
    String indKurName = indKurCd.equals("0") ? "未登録" : this.changekur(indKurCd, facilityCd);
    //変更後クールコードをクール名称に変換
    String editIndKurName = editIndKurCd.equals("0") ? "未登録" : this.changekur(editIndKurCd, facilityCd);
    //内容一覧に追加
    paramContentList.add(indKurName + "→" + editIndKurName);

    //値がnullの場合は"未登録"と表記を修正
    indTreatStartTime = Objects.isNull(indTreatStartTime) ? "未登録" : indTreatStartTime;
    editIndTreatStartTime = Objects.isNull(editIndTreatStartTime) ? "未登録" : editIndTreatStartTime;
    //内容一覧に追加
    paramContentList.add(indTreatStartTime + "→" + editIndTreatStartTime);

    //変更前ベッドコードをベッド名称に変換
    String indBedName = indBedCd.equals("0") ? "未登録" : this.changeBed(indBedCd, facilityCd);
    //変更後ベッドコードをベッド名称に変換
    String editIndBedName = editIndBedCd.equals("0") ? "未登録" : this.changeBed(editIndBedCd, facilityCd);
    //内容一覧に追加
    paramContentList.add(indBedName + "→" + editIndBedName);

    //リスト→文字列に変換
    paramContent = JSONObject.valueToString(paramContentList);
    return paramContent;
  }

  /**
   * 治療方法の対象作成処理
   *
   * @param key           項目
   * @return 治療方法の対象
   */
  public String createMethodTarget(String key) {
    //設定する対象
    String paramTarget = null;
    switch (key) {
      //治療方法の場合
      case "治療方法":
        paramTarget = "治療方法";
        break;
      //治療条件の場合
      case "治療条件":
        //治療条件の項目全てを格納するリスト
        List<String> paramTargetList = new ArrayList<>();
        //全部で39項目あるので、39回対象を取得する処理
        for (int i = 1; i < 40; i++) {
          paramTargetList.add(this.gettingEditTarget(String.valueOf(i)));
        }
        //リスト→文字列に変換して格納
        paramTarget = String.join(",", paramTargetList);
        break;
      //スケジュール変更の場合
      case "スケジュール変更":
        paramTarget = "クール,治療開始時刻,ベッド";
        break;
      //医療材料の場合
      case "医療材料":
        paramTarget = "医療材料";
        break;
      //投与薬剤の場合
      case "投与薬剤":
        paramTarget = "投与薬剤";
        break;
      //指示コメントの場合
      case "指示コメント":
        paramTarget = "指示コメント";
        break;
      //治療予定の場合(指示履歴に登録しないので空で設定)
      default:
        paramTarget = "";
        break;
    }
    return paramTarget;
  }

  /**
   * 治療方法の内容作成処理
   *
   * @param changeOrdMainList   変更前の治療方法詳細
   * @param key             Json文字列の、変更後の各項目のキー名(治療方法、治療条件、スケジュール変更、医療材料、投与薬剤、指示コメントのどれか)
   * @param ordMainValue    変更後の治療方法詳細
   * @param treatMethodFlag 治療方法の編集方法を判定するフラグ(0:治療方法のみ 1:投与薬剤含めて変更 2:投与薬剤含めず変更)
   * @param facilityCd      施設コード
   * @return 治療方法の内容
   */
  public Map<String, List<String>> createMethodContent(
    // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm start
//    OrdMain targetOrdMain, String key, String ordMainValue, String treatMethodFlag, String facilityCd) {
    List<OrdMain> changeOrdMainList, String key, String ordMainValue, String treatMethodFlag, String facilityCd) {
    // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm end

    //内容に記載する文章と操作区分のマップ
    Map<String, List<String>> paramContentMap = new HashMap<>();

    // add 11555 指示履歴への記録の残り方が仕様と異なる zkm start
    List<String> changeIndTreatmentCds = changeOrdMainList.stream().map(ord -> String.valueOf(ord.getIndTreatmentCd())).distinct().toList();
    // add 11555 指示履歴への記録の残り方が仕様と異なる zkm end

    //治療方法のみ変更の場合
    if (treatMethodFlag.equals("0")) {
      // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm start
//      paramContentMap = this.methodWayContent(String.valueOf(targetOrdMain.getIndTreatmentCd()), ordMainValue, facilityCd);
      paramContentMap = this.methodWayContent(changeIndTreatmentCds, ordMainValue, facilityCd);
      // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm end
    } else {
      switch (key) {
        //治療方法の場合
        case "治療方法":
          // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm start
//          paramContentMap = this.methodWayContent(String.valueOf(targetOrdMain.getIndTreatmentCd()), ordMainValue, facilityCd);
          paramContentMap = this.methodWayContent(changeIndTreatmentCds, ordMainValue, facilityCd);
          // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm end
          break;

        //治療条件の場合
        case "治療条件":
          // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm start
//          paramContentMap = this.methodConditionContent(targetOrdMain.getIndCondInfo(), ordMainValue, facilityCd);
          paramContentMap = this.methodConditionContent(changeOrdMainList.stream().map(OrdMain::getIndCondInfo).distinct().toList(), ordMainValue, facilityCd);
          // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm end
          break;

        //スケジュール変更の場合
        // del 11555 指示履歴への記録の残り方が仕様と異なる zkm start
//        case "スケジュール変更":
//          //内容を作成
//          paramContentMap = this.methodScheduleContent(targetOrdMain, ordMainValue, facilityCd);
//          break;
        // del 11555 指示履歴への記録の残り方が仕様と異なる zkm end

        //投与薬剤の場合
        case "投与薬剤":
          //内容を作成
          // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm start
//          paramContentMap = this.methodMedicineContent(targetOrdMain, ordMainValue, facilityCd);
          paramContentMap = this.methodMedicineContent(changeOrdMainList, ordMainValue, facilityCd);
          // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm end
          break;

        //医療材料の場合
        case "医療材料":
          //内容を作成
          // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm start
//          paramContentMap = this.methodEquipContent(targetOrdMain, ordMainValue, facilityCd);
          paramContentMap = this.methodEquipContent(changeOrdMainList, ordMainValue, facilityCd);
          // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm end
          break;

        //指示コメントの場合
        case "指示コメント":
          //内容を作成
          // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm start
//          paramContentMap = this.methodCommentContent(targetOrdMain, ordMainValue);
          paramContentMap = this.methodCommentContent(changeOrdMainList, ordMainValue);
          // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm end
          break;

        //治療予定の場合(指示履歴に登録しないので,マップには空文字のリストを入れておく)
        default:
          //格納する内容・操作区分のリストを作成
          List<String> contentList = new ArrayList<>();
          contentList.add("");
          List<String> flagList = new ArrayList<>();
          flagList.add("");

          paramContentMap.put("内容", contentList);
          paramContentMap.put("操作区分", flagList);
          break;
      }
    }

    // add 11555 指示履歴への記録の残り方が仕様と異なる zkm start
    Set<String> seen = new HashSet<>();
    Iterator<String> contents = paramContentMap.get("内容").iterator();
    Iterator<String> flags = paramContentMap.get("操作区分").iterator();

    while (contents.hasNext() && flags.hasNext()) {
      String item = contents.next();
      flags.next();
      if (!seen.add(item)) {
        contents.remove();
        flags.remove();
      }
    }
    // add 11555 指示履歴への記録の残り方が仕様と異なる zkm end
    return paramContentMap;
  }

  /**
   *  治療方法編集時、治療方法の内容作成処理
   * @param oldIndTreatmentCds 変更前の治療方法コード
   * @param newIndTreatmentCd 変更後の治療方法コード
   * @param facilityCd 施設コード
   * @return paramContentMap  治療方法の内容と操作区分のマップ
   */
  public Map<String, List<String>> methodWayContent(
    // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm start
//          String oldIndTreatmentCd, String newIndTreatmentCd, String facilityCd) {
    List<String> oldIndTreatmentCds, String newIndTreatmentCd, String facilityCd) {
    // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm end

    //内容を格納するリスト
    List<String> contentList = new ArrayList<>();
    //操作区分を格納するリスト
    List<String> flagList = new ArrayList<>();
    //治療方法の内容と操作区分のマップ
    Map<String, List<String>> paramContentMap = new HashMap<>();

    //変更前の治療方法コードを治療方法名称に変換
    // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm start
//    String treatmentName = this.changeTreatment(oldIndTreatmentCd, facilityCd);
    List<String> oldTreatments = oldIndTreatmentCds.stream().map(cd -> changeTreatment(cd, facilityCd)).toList();
    String treatmentName;
    if (oldTreatments.size() > 1) {
      treatmentName = oldTreatments.stream().filter(t -> !"すべて".equals(t)).collect(Collectors.joining(","));
    } else {
      treatmentName = oldTreatments.get(0);
    }
    // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm end
    //変更後の治療方法コードを治療方法名称に変換
    String editTreatmentName = this.changeTreatment(newIndTreatmentCd, facilityCd);
    //内容を作成してリストに追加
    contentList.add(treatmentName + "→" + editTreatmentName);
    //操作区分をリストに追加
    flagList.add("2");
    //指示履歴用のマップに内容と操作区分を保持
    paramContentMap.put("内容", contentList);
    paramContentMap.put("操作区分", flagList);

    return paramContentMap;
  }

  /**
   * 治療方法編集時、治療条件の内容作成処理
   *
   * @param preIndCondInfoValueList 変更前の治療条件詳細
   * @param ordMainValue  変更後の治療条件詳細
   * @param facilityCd    施設コード
   * @return 治療条件の内容と操作区分のマップ
   */
  public Map<String, List<String>> methodConditionContent(
    List<String> preIndCondInfoValueList, String ordMainValue, String facilityCd) {

    //治療条件の内容に記載する文章のリスト
    List<String> paramContentList = new ArrayList<>();
    //操作区分リスト
    List<String> changeFlagList = new ArrayList<>();
    //治療条件の内容と操作区分のマップ
    Map<String, List<String>> paramContentMap = new HashMap<>();

    for (int i = 1; i < 40; i++) {

      //変更後
      String postContent;
      //新たに登録する治療条件が存在するか判定
      if (!Objects.isNull(ordMainValue)) {
        //変更後の治療条件の詳細を取得
        JSONObject indCondInfo = new JSONObject(ordMainValue);
        postContent = getConditionValUnit(facilityCd, i, indCondInfo);
      } else {
        postContent = "未登録";
      }

      int finalI = i;
      List<String> preContents = preIndCondInfoValueList.stream().map(preIndCondInfoValue -> {
        //変更前の治療条件の詳細を取得
        JSONObject preIndCondInfo = null == preIndCondInfoValue ?
          new JSONObject() :
          new JSONObject(preIndCondInfoValue);
        //内容を作成
        return getConditionValUnit(facilityCd, finalI, preIndCondInfo);
      }).filter(content -> !content.isEmpty() && !content.equals(postContent)).distinct().toList();

      //値をリストに追加
      if (!preContents.isEmpty()) {
        paramContentList.add(String.join(",", preContents) + "→" + postContent);
      } else {
        // 変更前後一致するレコードが後ろの処理にてスキップできる
        paramContentList.add(postContent + "→" + postContent);
      }
    }

    //操作区分をリストに格納
    changeFlagList.add("2");

    //内容と操作区分をマップに格納
    paramContentMap.put("内容", paramContentList);
    paramContentMap.put("操作区分", changeFlagList);

    return paramContentMap;
  }

//  /**
//   * 治療方法編集時、スケジュール変更の内容作成処理
//   *
//   * @param targetOrdMain 変更前のスケジュール変更詳細
//   * @param ordMainValue  変更後のスケジュール変更詳細
//   * @param facilityCd    施設コード
//   * @return paramContentList スケジュール変更の内容と操作区分のマップ
//   */
//  public Map<String, List<String>> methodScheduleContent(OrdMain targetOrdMain, String ordMainValue, String facilityCd) {
//    //スケジュールの内容に記載する文章のリスト
//    List<String> paramContentList = new ArrayList<>();
//    //操作区分リスト
//    List<String> changeFlagList = new ArrayList<>();
//    //スケジュール変更の内容と操作区分のマップ
//    Map<String, List<String>> paramContentMap = new HashMap<>();
//    //スケジュール変更詳細を配列形式で保持(0:クール、1:治療開始時刻、2:ベッド)
//    JSONArray ordMainArray = new JSONArray(ordMainValue);
//
//    //変更前のクールコードを保持
//    String indKurCd = String.valueOf(targetOrdMain.getIndKurCd());
//    //変更前クールコードをクール名称に変換
//    String indKurName = indKurCd.equals("0") ? "未登録" : this.changekur(indKurCd, facilityCd);
//    //変更後のクール名称を保持(設定値がない場合は"未登録")
//    String editIndKurName = ordMainArray.get(0).toString();
//    //内容一覧に追加
//    paramContentList.add(indKurName + "→" + editIndKurName);
//
//    //変更前の治療開始時刻を保持
//    String indTreatStartTime = targetOrdMain.getIndTreatStartTime();
//    //値がnullの場合は"未登録"と表記を修正
//    if (Objects.isNull(indTreatStartTime)) {
//      indTreatStartTime = "未登録";
//    }
//    //文字列→時刻表記に変換して取得(nullの場合は"未登録"に変換)
//    else {
//      // 治療開始時刻 HHmm形式⇒HH:mm形式
//      SimpleDateFormat treatTimeFormat = new SimpleDateFormat("HHmm");
//      Date treatTimeDate = null;
//      try {
//        treatTimeDate = treatTimeFormat.parse(indTreatStartTime);
//      } catch (ParseException e) {
//        e.printStackTrace();
//      }
//      indTreatStartTime = new SimpleDateFormat("HH:mm").format(treatTimeDate);
//    }
//    //変更後の治療開始時刻の値を保持(設定値がない場合は"未登録")
//    String editIndTreatStartTime = ordMainArray.get(1).toString();
//    //内容一覧に追加
//    paramContentList.add(indTreatStartTime + "→" + editIndTreatStartTime);
//    //変更前のベッドコードを保持
//    String indBedCd = String.valueOf(targetOrdMain.getIndBedCd());
//    //変更前ベッドコードをベッド名称に変換
//    String indBedName = indBedCd.equals("0") ? "未登録" : this.changeBed(indBedCd, facilityCd);
//    //変更後のベッド名称を保持(設定値がない場合は"未登録")
//    String editIndBedName = ordMainArray.get(2).toString();
//    //内容一覧に追加
//    paramContentList.add(indBedName + "→" + editIndBedName);
//    //操作区分をリストに格納
//    changeFlagList.add("2");
//    //内容と操作区分をマップに格納
//    paramContentMap.put("内容", paramContentList);
//    paramContentMap.put("操作区分", changeFlagList);
//    return paramContentMap;
//  }

  /**
   * 治療方法編集時、投与薬剤の内容作成処理
   *
   * @param changeOrdMainList 変更前の投与薬剤詳細
   * @param ordMainValue  変更後の投与薬剤詳細
   * @param facilityCd    施設コード
   * @return paramContentMap 投与薬剤の内容と操作区分のマップ
   */
  // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm start
//  public Map<String, List<String>> methodMedicineContent(
//    OrdMain targetOrdMain, String ordMainValue, String facilityCd) {
  public Map<String, List<String>> methodMedicineContent(List<OrdMain> changeOrdMainList, String ordMainValue, String facilityCd) {
    // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm end
    //投与薬剤の内容に記載する文章のリスト
    List<String> paramContentList = new ArrayList<>();
    //操作区分リスト
    List<String> changeFlagList = new ArrayList<>();
    //医療材料の内容と操作区分のマップ
    Map<String, List<String>> paramContentMap = new HashMap<>();

    //変更前の投与薬剤詳細
    // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm start
//    List<Map<String, String>> previousIndMedicineList = this.changeListMap(targetOrdMain.getIndMediInfo());
    List<Map<String, String>> previousIndMedicineList = changeOrdMainList.stream()
      .map(ord -> changeListMap(ord.getIndMediInfo())).flatMap(List::stream).toList();
    // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm end
    //変更後の投与薬剤詳細
    List<Map<String, String>> indMedicineList =
      Objects.isNull(ordMainValue)
        ? new ArrayList<>()
        : this.changeListMap(ordMainValue);

    //変更前の投与薬剤詳細をそれぞれ取得し、中止とする指示履歴内容の文章を作成
    for (int i = 0; i < previousIndMedicineList.size(); i++) {
      //変更前の投与薬剤詳細
      JSONObject previousMedicineInfo = new JSONObject(previousIndMedicineList.get(i));
      // FNSI-修正、#6787、1/31Rel_NGの対応、xugj mod start
      //中止とする指示履歴有無フラグ
      boolean isStoppedHistoryFlg = true;
      for (int j = 0; j < indMedicineList.size(); j++) {
        //変更後の投与薬剤詳細
        JSONObject medicineInfo = new JSONObject(indMedicineList.get(j));
        if (previousMedicineInfo.get("cd")!=null && previousMedicineInfo.get("cd").equals(medicineInfo.get("cd"))) {
          // 変更前後の情報が同じ場合
          if (previousMedicineInfo.has("amount")
            && previousMedicineInfo.has("procedure_cd")
            && previousMedicineInfo.has("timing_cd")
            && previousMedicineInfo.get("amount").equals(medicineInfo.get("amount"))
            && previousMedicineInfo.get("procedure_cd").equals(medicineInfo.get("procedure_cd"))
            && previousMedicineInfo.get("timing_cd").equals(medicineInfo.get("timing_cd"))) {

            isStoppedHistoryFlg = false;
          }
        }
      }
      // FNSI-修正、#6787、1/31Rel_NGの対応、xugj mod end
      if (isStoppedHistoryFlg) {
        //変更後回数(中止処理では使用しないのでnullで定義)
        String nums = null;
        // mod bug 8128 修正 chen start
        //初回投与日
        String initDate = previousMedicineInfo.has("init_date") ? previousMedicineInfo.get("init_date").toString() : "";
        //投与間隔
        String dateInterval = previousMedicineInfo.has("date_interval") ? previousMedicineInfo.get("date_interval").toString() : "";
        // mod bug 8128 修正 chen end

        //既存の投与薬剤を中止する指示履歴内容を作成し、リストに格納
        // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm start
//        String comment = this.createMedicineContent(
//          previousMedicineInfo, facilityCd, "3", nums, initDate, dateInterval, targetOrdMain);
        String comment = this.createMedicineContent(
          previousMedicineInfo, facilityCd, "3", nums, initDate, dateInterval, previousIndMedicineList);
        // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm end
        paramContentList.add(comment);
        //操作区分をリストに格納
        changeFlagList.add("3");
      }
    }

    //変更後の投与薬剤が設定されているか判定
    if (! indMedicineList.isEmpty()) {
      //変更後の投与薬剤をそれぞれ取得し、新規登録とする指示履歴内容の文章を作成
      for (int i = 0; i < indMedicineList.size(); i++) {
        //変更後の投与薬剤詳細
        JSONObject medicineInfo = new JSONObject(indMedicineList.get(i));
        // FNSI-修正、#6787、1/31Rel_NGの対応、xugj mod start
        //新規とする指示履歴有無フラグ
        boolean isCreateHistoryFlg = true;
        //変更前の投与薬剤詳細をそれぞれ取得し、中止とする指示履歴内容の文章を作成
        for (int j = 0; j < previousIndMedicineList.size(); j++) {
          //変更前の投与薬剤詳細
          JSONObject previousMedicineInfo = new JSONObject(previousIndMedicineList.get(j));

          if (previousMedicineInfo.get("cd") !=null && previousMedicineInfo.get("cd").equals(medicineInfo.get("cd"))) {
            // 変更前後の情報が同じ場合
            if (previousMedicineInfo.has("amount")
              && previousMedicineInfo.has("procedure_cd")
              && previousMedicineInfo.has("timing_cd")
              && previousMedicineInfo.get("amount").equals(medicineInfo.get("amount"))
              && previousMedicineInfo.get("procedure_cd").equals(medicineInfo.get("procedure_cd"))
              && previousMedicineInfo.get("timing_cd").equals(medicineInfo.get("timing_cd"))) {

              isCreateHistoryFlg = false;
            }
          }
        }
        // FNSI-修正、#6787、1/31Rel_NGの対応、xugj mod end
        if (isCreateHistoryFlg) {
          //変更後回数(治療方法セットで新規登録する際、未登録となるのでnullで定義)
          String nums = null;
          // mod bug 8128 修正 chen start
          //初回投与日
          String initDate = medicineInfo.has("init_date") ? medicineInfo.get("init_date").toString() : "";
          //投与間隔
          String dateInterval = medicineInfo.has("date_interval") ? medicineInfo.get("date_interval").toString() : "";
          // mod bug 8128 修正 chen end

          //変更後の投与薬剤単位
          String unit = this.gettingMedicineUnit(
            medicineInfo.get("cd").toString(),
            facilityCd,
            medicineInfo.get("medicine_type").toString(),
            "1");
          //取得した投与薬剤単位を投与薬剤詳細に格納
          medicineInfo.put("unit", unit);

          //投与薬剤の内容の文章を作成し、リストに追加
          // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm start
//          String comment = this.createMedicineContent(
//            medicineInfo, facilityCd, "1", nums, initDate, dateInterval, targetOrdMain);
          String comment = this.createMedicineContent(
            medicineInfo, facilityCd, "1", nums, initDate, dateInterval, previousIndMedicineList);
          // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm end
          paramContentList.add(comment);

          //操作区分をリストに格納
          changeFlagList.add("1");
        }
      }
    }
    // FNSI-修正、#6787、1/31Rel_NGの対応、xugj mod start
    if (paramContentList.isEmpty()) {
      paramContentList.add("未登録→未登録");
      //操作区分をリストに格納
      changeFlagList.add("1");
    }
    // FNSI-修正、#6787、1/31Rel_NGの対応、xugj mod end
    //内容と操作区分をマップに格納
    paramContentMap.put("内容", paramContentList);
    paramContentMap.put("操作区分", changeFlagList);

    return paramContentMap;
  }

  /**
   * 治療方法編集時、医療材料の内容作成処理
   *
   * @param changeOrdMainList 変更前の医療材料詳細
   * @param ordMainValue  変更後の医療材料詳細
   * @param facilityCd    施設コード
   * @return paramContentMap 医療材料の内容と操作区分のマップ
   */
  public Map<String, List<String>> methodEquipContent(
    List<OrdMain> changeOrdMainList, String ordMainValue, String facilityCd) {
    // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm end
    //医療材料の内容に記載する文章のリスト
    List<String> paramContentList = new ArrayList<>();
    //操作区分リスト
    List<String> changeFlagList = new ArrayList<>();
    //医療材料の内容と操作区分のマップ
    Map<String, List<String>> paramContentMap = new HashMap<>();

    //変更前の医療材料詳細
    // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm start
//    List<Map<String, String>> previousIndEquipmentList = this.changeListMap(targetOrdMain.getIndEquipInfo());
    List<Map<String, String>> previousIndEquipmentList = changeOrdMainList.stream().map(ord -> changeListMap(ord.getIndEquipInfo())).flatMap(List::stream).toList();
    // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm end

    //変更後の医療材料詳細
    List<Map<String, String>> indEquipmentList =
      Objects.isNull(ordMainValue)
        ? new ArrayList<>()
        : this.changeListMap(ordMainValue);

    //変更前の医療材料詳細をそれぞれ取得し、中止とする指示履歴内容の文章を作成
    for (int i = 0; i < previousIndEquipmentList.size(); i++) {
      //変更前の医療材料詳細
      JSONObject previousEquipmentInfo = new JSONObject(previousIndEquipmentList.get(i));
      // FNSI-修正、#6787、1/31Rel_NGの対応、xugj mod start
      //中止とする指示履歴有無フラグ
      boolean isStoppedHistoryFlg = true;
      for (int j = 0; j < indEquipmentList.size(); j++) {
        //変更後の医療材料詳細
        JSONObject equipmentInfo = new JSONObject(indEquipmentList.get(j));
        // 変更前後の情報が同じ場合
        if (previousEquipmentInfo.get("cd").equals(equipmentInfo.get("cd"))
          && previousEquipmentInfo.get("amount").equals(equipmentInfo.get("amount"))) {
          isStoppedHistoryFlg = false;
        }
      }
      // FNSI-修正、#6787、1/31Rel_NGの対応、xugj mod end
      if (isStoppedHistoryFlg) {
        //既存の医療材料を中止する指示履歴内容を作成し、リストに格納
        // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm start
//        String comment = this.createEquipmentContent(
//          previousEquipmentInfo, facilityCd, "3", "2", "", targetOrdMain);
        String comment = this.createEquipmentContent(
          previousEquipmentInfo, facilityCd, "3", "2", "", previousIndEquipmentList);
        // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm end
        paramContentList.add(comment);
        //操作区分をリストに格納
        changeFlagList.add("3");
      }
    }

    //新規登録を行う医療材料の有無を判定
    if (! indEquipmentList.isEmpty()) {
      //変更後の医療材料をそれぞれ取得し、新規登録とする指示履歴内容の文章を作成
      for (int i = 0; i < indEquipmentList.size(); i++) {
        //変更後の医療材料詳細
        JSONObject equipmentInfo = new JSONObject(indEquipmentList.get(i));
        // FNSI-修正、#6787、1/31Rel_NGの対応、xugj mod start
        //新規とする指示履歴有無フラグ
        boolean isCreateHistoryFlg = true;
        for (int j = 0; j < previousIndEquipmentList.size(); j++) {
          //変更前の医療材料詳細
          JSONObject previousEquipmentInfo = new JSONObject(previousIndEquipmentList.get(j));
          // 変更前後の情報が同じ場合
          if (previousEquipmentInfo.get("cd").equals(equipmentInfo.get("cd"))
            && previousEquipmentInfo.get("amount").equals(equipmentInfo.get("amount"))) {
            isCreateHistoryFlg = false;
          }
        }
        // FNSI-修正、#6787、1/31Rel_NGの対応、xugj mod end
        if (isCreateHistoryFlg) {
          //医療材料の内容の文章を作成し、リストに追加
          // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm start
//          String comment = this.createEquipmentContent(
//            equipmentInfo, facilityCd, "1", "2", "", targetOrdMain);
          String comment = this.createEquipmentContent(
            equipmentInfo, facilityCd, "1", "2", "", previousIndEquipmentList);
          // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm end
          paramContentList.add(comment);
          //操作区分をリストに格納
          changeFlagList.add("1");
        }
      }
    }
    // FNSI-修正、#6787、1/31Rel_NGの対応、xugj mod start
    if (paramContentList.isEmpty()) {
      paramContentList.add("未登録→未登録");
      //操作区分をリストに格納
      changeFlagList.add("1");
    }
    // FNSI-修正、#6787、1/31Rel_NGの対応、xugj mod end
    //内容と操作区分をマップに格納
    paramContentMap.put("内容", paramContentList);
    paramContentMap.put("操作区分", changeFlagList);

    return paramContentMap;
  }

  /**
   * 治療方法編集時、指示コメントの内容作成処理
   *
   * @param changeOrdMainList 変更前の指示コメント詳細
   * @param ordMainValue  変更後の指示コメント詳細
   * @return paramContentMap 指示コメントの内容と操作区分のマップ
   */
  // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm start
//  public Map<String, List<String>> methodCommentContent(OrdMain targetOrdMain, String ordMainValue) {
  public Map<String, List<String>> methodCommentContent(List<OrdMain> changeOrdMainList, String ordMainValue) {
    // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm end
    //指示コメントの内容に記載する文章のリスト
    List<String> paramContentList = new ArrayList<>();
    //操作区分
    List<String> changeFlagList = new ArrayList<>();
    //指示コメントの内容と操作区分のマップ
    Map<String, List<String>> paramContentMap = new HashMap<>();

    //変更前の指示コメント詳細
    // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm start
//    List<Map<String, String>> previousIndCommentList = this.changeListMap(targetOrdMain.getIndIndCommentInfo());
    List<Map<String, String>> previousIndCommentList = new ArrayList<>();
    changeOrdMainList.forEach(ord -> {
      List<Map<String, String>> subIndCommentList = this.changeListMap(ord.getIndIndCommentInfo());
      previousIndCommentList.addAll(subIndCommentList);
    });
    // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm end

    //変更後の指示コメント詳細
    List<Map<String, String>> indCommentList =
      Objects.isNull(ordMainValue)
        ? new ArrayList<>()
        : this.changeListMap(ordMainValue);

    //変更前の指示コメント詳細をそれぞれ取得し、更新対象となる指示コメントに関する指示履歴内容を作成
    for (int i = 0; i < previousIndCommentList.size(); i++) {
      //変更前の指示コメント内容を取得
      String previousContent = previousIndCommentList.get(i).get("content");
      //変更前の指示コメント番号を取得
      String previousNum = previousIndCommentList.get(i).get("no");
      // FNSI-修正、#6787、1/31Rel_NGの対応、xugj mod start
      //中止とする指示履歴有無フラグ
      boolean isStoppedHistoryFlg = true;
      for (int j = 0; j < indCommentList.size(); j++) {
        //変更後指示コメント内容を取得
        String content = indCommentList.get(j).get("content");
        //変更後指示コメント番号を取得
        String num = indCommentList.get(j).get("no");
        // 変更前後の情報が同じ場合
        if (previousNum.equals(num) && previousContent.equals(content)) {
          isStoppedHistoryFlg = false;
        }
      }
      // FNSI-修正、#6787、1/31Rel_NGの対応、xugj mod end
      if (isStoppedHistoryFlg) {
        //既存の指示コメントを中止する指示履歴内容を作成し、リストに格納
        String comment = this.createCommentContent("3", previousNum, previousContent, new ArrayList<>());
        paramContentList.add(comment);
        //操作区分をリストに格納
        changeFlagList.add("3");
      }
    }

    if (! indCommentList.isEmpty()) {
      //変更後の指示コメント分、指示コメント内容の文章を作成
      for (int i = 0; i < indCommentList.size(); i++) {
        //指示コメント内容を取得
        String content = indCommentList.get(i).get("content");
        //指示コメント番号を取得
        String num = indCommentList.get(i).get("no");
        // FNSI-修正、#6787、1/31Rel_NGの対応、xugj mod start
        //新規とする指示履歴有無フラグ
        boolean isCreateHistoryFlg = true;
        //変更前の指示コメント詳細をそれぞれ取得し、更新対象となる指示コメントに関する指示履歴内容を作成
        for (int j = 0; j < previousIndCommentList.size(); j++) {
          //変更前の指示コメント内容を取得
          String previousContent = previousIndCommentList.get(j).get("content");
          //変更前の指示コメント番号を取得
          String previousNum = previousIndCommentList.get(j).get("no");
          if (previousNum.equals(num) && previousContent.equals(content)) {
            isCreateHistoryFlg = false;
          }
        }
        // FNSI-修正、#6787、1/31Rel_NGの対応、xugj mod end
        if (isCreateHistoryFlg) {
          //新たに設定する指示履歴内容を作成し、リストに格納
          String comment = this.createCommentContent("1", num, content, new ArrayList<>());
          paramContentList.add(comment);
          //操作区分をリストに格納
          changeFlagList.add("1");
        }
      }
    }
    // FNSI-修正、#6787、1/31Rel_NGの対応、xugj mod start
    if (paramContentList.isEmpty()) {
      paramContentList.add("未登録→未登録");
      //操作区分をリストに格納
      changeFlagList.add("1");
    }
    // FNSI-修正、#6787、1/31Rel_NGの対応、xugj mod end
    //内容と操作区分をマップに格納
    paramContentMap.put("内容", paramContentList);
    paramContentMap.put("操作区分", changeFlagList);

    return paramContentMap;
  }

  /**
   * MongoDBを使用POST(CREATE) API
   *
   * @param params 保存データ(Entity型)
   * @return
   */
  public IndHistory create(IndHistory params) {
    try {
      if (MongoHealthCheckService.getMongoDBConnected()) {
        mongoTemplate.insert(params);
      }
    } catch (DataAccessResourceFailureException exception) {
      MongoHealthCheckService.setMongoDBConnected(false);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(exception));
      if (params != null && !StringUtils.isEmpty(params.getFacilityCd())) {
        eventLogMessage.setFacilityCd(params.getFacilityCd());
      }
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
    }
    return params;
  }

  public int createBatch(List<IndHistory> paramsList) {
    try {
      if (MongoHealthCheckService.getMongoDBConnected()) {
        BulkWriteResult bulkWriteResult = mongoTemplate.bulkOps(BulkOperations.BulkMode.ORDERED, IndHistory.class).insert(paramsList).execute();
        return bulkWriteResult.getInsertedCount();
      }
    } catch (DataAccessResourceFailureException exception) {
      MongoHealthCheckService.setMongoDBConnected(false);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(exception));
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
    }
    return 0;
  }

  /**
   * 治療予定/治療方法用、登録する各項目の値一覧を格納する処理
   *
   * @param ordMain    登録する各項目一覧
   * @param facilityCd 施設コード
   * @return 各項目の値とkey名
   */
  // #10959 システム内でstatic変数を使っている箇所の洗い出し mod yangxuewang start
  private Map<String, String> createKeyValues(OrdMain ordMain, String facilityCd, Boolean isIncludingMedicine) {
    // #10959 システム内でstatic変数を使っている箇所の洗い出し mod yangxuewang end
    //登録する各項目の値一覧を格納するMap
    Map<String, String> ordMainMap = new LinkedHashMap<>();

    //登録する治療予定を設定
    ordMainMap.put("治療予定", "");

    //登録するの治療方法コードを文字列で取得(nullの場合は空文字に変換)
    String indTreatmentCd = Objects.isNull(ordMain.getIndTreatmentCd()) ? "" : String.valueOf(ordMain.getIndTreatmentCd());
    //治療方法コードをmapに追加
    ordMainMap.put("治療方法", indTreatmentCd);

    //スケジュール変更のクール名称を取得(登録する値が無い場合のコードは、治療予定の時に0・治療方法の時にnull)
    String indKurName = "未登録";
    int indKurCd = Objects.isNull(ordMain.getIndKurCd()) ? 0 : ordMain.getIndKurCd();

    if (indKurCd != 0) {
      indKurName = this.changekur(String.valueOf(indKurCd), facilityCd);
    }

    //スケジュール変更の治療開始時刻を文字列→時刻表記に変換して取得(nullの場合は"未登録"に変換)
    String indTreatStartTime = "未登録";
    //文字列→時刻への変換処理
    if (! Objects.isNull(ordMain.getIndTreatStartTime())) {
      // 治療開始時刻 HHmm形式⇒HH:mm形式
      SimpleDateFormat treatTimeFormat = new SimpleDateFormat("HHmm");
      Date treatTimeDate = null;
      try {
        treatTimeDate = treatTimeFormat.parse(String.valueOf(ordMain.getIndTreatStartTime()));
      } catch (ParseException e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        if (!StringUtils.isEmpty(facilityCd)) {
          eventLogMessage.setFacilityCd(facilityCd);
        }
        logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
      }
      indTreatStartTime = new SimpleDateFormat("HH:mm").format(treatTimeDate);
    }

    //スケジュール変更のベッド名称を取得(登録する値が無い場合のコードは、治療予定の時に0・治療方法の時にnull)
    String indBedName = "未登録";
    int indBedCd = Objects.isNull(ordMain.getIndBedCd()) ? 0 : ordMain.getIndBedCd();
    if (indBedCd != 0) {
      indBedName = this.changeBed(String.valueOf(indBedCd), facilityCd);
    }
    List<String> dataList= new ArrayList<String>();
    dataList.add(indKurName);
    dataList.add(indTreatStartTime);
    dataList.add(indBedName);
    ordMainMap.put("スケジュール変更", JSONObject.valueToString(dataList));
    //登録する治療条件を取得
    ordMainMap.put("治療条件", ordMain.getIndCondInfo());
    // 投与薬剤有無 = 有：含める場合
    // #10959 システム内でstatic変数を使っている箇所の洗い出し mod yangxuewang start
    if (Boolean.TRUE.equals(isIncludingMedicine)) {
      // #10959 システム内でstatic変数を使っている箇所の洗い出し mod yangxuewang end
      //投与薬剤をリストに追加
      ordMainMap.put("投与薬剤", ordMain.getIndMediInfo());
    }
    //医療材料をmapに追加
    ordMainMap.put("医療材料", ordMain.getIndEquipInfo());
    //指示コメントをmapに追加
    ordMainMap.put("指示コメント", ordMain.getIndIndCommentInfo());
//    //装置設定をmapに追加
//    ordMainMap.put("装置設定", ordMain.getIndDeviceSetInfo());

    return ordMainMap;
  }

  /**
   * クールコードから名称に変換する処理
   *
   * @param kurCd      画面から取得したクールコード
   * @param facilityCd 画面から取得した施設コード
   * @return クールコードに対応するクール名称
   */
  private String changekur(String kurCd, String facilityCd) {
    //クールコードに対応するクール名称を格納したリスト
    String paramKurName = null;
    //クールコードに対応するクール名称を格納したリスト
    List<String> kurNameList = new ArrayList<String>();

    //マスタ取得処理
    SelectOptions selectOptions = SelectOptions.get();
    List<MstKur> mstKurList = mstKurDao.selectByFacilityCd(selectOptions, facilityCd, "0");

    //画面から取得したクールコードを格納したリスト
    List<Integer> indKurCdlist = new ArrayList<>();
    //画面から取得したクールコードをリストに格納
    try {
      //Json文字列であれば変換してリストに格納。違うならcatch(JsonException)へ飛ぶ。
      indKurCdlist = this.getValueList(kurCd);
    } catch (JSONException e) {
      //リストに格納
      if (!kurCd.isEmpty())
        indKurCdlist.add(Integer.parseInt(kurCd));
    }

    // リストの内容が空の場合、「すべて」が選択されている
    if (indKurCdlist.isEmpty()) {
      return "すべて";
    }

    if (indKurCdlist.size() == 1 && indKurCdlist.get(0).equals(0)) {
      return "未登録";
    }

    //クールコードに対応するクール名称を取得
    for (int cd : indKurCdlist) {
      for (int i = 0; i < mstKurList.size(); i++) {
        //マスタのクールコードを文字列に変換し取得
        int mstKurCd = mstKurList.get(i).getKurCd();
        if (cd == mstKurCd) {
          kurNameList.add(mstKurList.get(i).getKurName());
        }
      }
    }
    //取得した治療方法名称があれば、格納して戻す。
    if (!kurNameList.isEmpty()) {
      paramKurName = String.join(",", kurNameList);
    }
    return paramKurName;
  }

  /**
   * ベッドコードからベッド名称に変換する処理
   *
   * @param bedCd      画面から取得したベッドコード
   * @param facilityCd 画面から取得した施設コード
   * @return ベッドコードに対応するベッド名称
   */
  private String changeBed(String bedCd, String facilityCd) {
    //ベッドコードに対応するベッド名
    String bedName = "";
    //ベッドコードの比較のため、nullの場合は空文字に変換
    String checkedBedCd = Objects.isNull(bedCd) ? "" : bedCd;

    //マスタ取得処理
    SelectOptions selectOptions = SelectOptions.get();
    List<MstBed> mstBedList = mstBedDao.selectByFacilityCd(selectOptions, facilityCd, "1", "0");

    //ベッドコードに対応するベッド名称を取得
    for (int i = 0; i < mstBedList.size(); i++) {
      //投与薬剤コードを数値→文字列に変換
      String mstBedCd = String.valueOf(mstBedList.get(i).getBedCd());
      //マスタ投与薬剤コードと比較し、投与薬剤コードに対応する投与薬剤名称を取得
      if (checkedBedCd.equals(mstBedCd)) {
        bedName = mstBedList.get(i).getBedName();
      }
    }
    return bedName;
  }

  /**
   * 曜日番号から曜日に変換する処理
   *
   * @param weeksArray 曜日番号リスト
   * @return 曜日番号に対応する曜日
   */
  private String changeWeekday(List<Integer> weeksArray) {
    //曜日番号に対応する曜日
    String weekDay = null;
    //対応する曜日を格納したリスト
    List<String> weekDayList = new ArrayList<String>();

    //String型のリストに変換
    List<String> stWeeksList = weeksArray.stream().map(item -> String.valueOf(item)).collect(Collectors.toList());
    //リストから配列に変換
    String[] stWeeksArray = stWeeksList.toArray(new String[stWeeksList.size()]);
    Arrays.sort(stWeeksArray);

    //[1]が月曜、[7]が日曜で変換処理
    for (String weekNum : stWeeksArray) {
      String weekName = this.getWeekName(weekNum.trim());
      if (! weekName.isEmpty()) {
        weekDayList.add(weekName);
      }
    }
    //リストから配列に変換
    String[] weekDayArray = weekDayList.toArray(new String[weekDayList.size()]);
    //配列から文字列に変換([曜日]の状態で文字列化しているため、[]を消去)
    weekDay = Arrays.toString(weekDayArray).replace("[", "").replace("]", "");
    return weekDay;
  }

  /**
   * 曜日Noを曜日名に変換する処理
   * ([1]が月曜、[7]が日曜で変換処理)
   *
   * @param strNo 曜日No
   * @return 変換した曜日名
   */
  private String getWeekName(String strNo) {
    String rtnName = "";
    switch (strNo.trim()) {
      case "1":
        rtnName = "月";
        break;
      case "2":
        rtnName = "火";
        break;
      case "3":
        rtnName = "水";
        break;
      case "4":
        rtnName = "木";
        break;
      case "5":
        rtnName = "金";
        break;
      case "6":
        rtnName = "土";
        break;
      case "7":
        rtnName = "日";
        break;
      default:
        break;
    }
    return rtnName;
  }

  /**
   * 治療方法コードから名称に変換する処理
   *
   * @param indTreatmentCd 画面から取得した治療方法コード
   * @param facilityCd     画面から取得した施設コード
   * @return 治療方法コードに対応する治療方法名称
   */
  private String changeTreatment(String indTreatmentCd, String facilityCd) {
    //画面から取得した治療方法コードに対応する治療方法名称
    String paramTreatmentName = null;
    //治療方法コードに対応する治療方法名称を格納したリスト
    List<String> treatNameList = new ArrayList<String>();

    //治療方法が設定されているか判定
    if (!indTreatmentCd.isEmpty()) {
      //マスタ取得用パラメータに施設コードを設定
      MstTreatment mstTreatment = new MstTreatment();
      mstTreatment.setFacilityCd(facilityCd);
//      //マスタ取得処理
      SelectOptions selectOptions = SelectOptions.get();
      List<MstTreatment> mstTreatmentList = mstTreatmentDao.selectAll(selectOptions, mstTreatment);

      //画面から取得した治療方法コードを格納したリスト
      List<Integer> indTreatmentCdlist = new ArrayList<>();
      //画面から取得した治療方法コードをリストに格納
      try {
        //Json文字列であれば変換してリストに格納。違うならcatch(JsonException)へ飛ぶ。
        indTreatmentCdlist = this.getValueList(indTreatmentCd);
      } catch (JSONException e) {
        //リストに格納
        indTreatmentCdlist.add(Integer.parseInt(indTreatmentCd));
      }

      // リストの内容が空の場合、「すべて」が選択されている
      if (indTreatmentCdlist.isEmpty()) {
        return "すべて";
      }

      //治療方法コードに対応する治療方法名称を取得
      for (int cd : indTreatmentCdlist) {
        for (int i = 0; i < mstTreatmentList.size(); i++) {
          //マスタの治療方法コードを文字列に変換し取得
          int mstCd = mstTreatmentList.get(i).getTreatmentCd();
          if (cd == mstCd) {
            treatNameList.add(mstTreatmentList.get(i).getTreatmentName());
          }
        }
      }
    }
    //取得した治療方法名称があれば、格納して戻す。
    if (! treatNameList.isEmpty()) {
      paramTreatmentName = String.join(",", treatNameList);
    }
    return paramTreatmentName;
  }

  /**
   * 指示者・更新者コードから名称に変換する処理
   *
   * @param userCd     画面から取得した指示者コード・更新者コード
   * @param facilityCd 画面から取得した施設コード
   * @return 指示者コード・更新者コードに対応する利用者氏名
   */
  private String changeUserName(String userCd, String facilityCd) {
    //指示者コード・更新者コードに対応する利用者氏名
    String paramIndUserName = null;

    if ("null".compareTo(userCd) != 0) {
      Long userId = Long.parseLong(userCd);
      MstPersonalUser mstPersonalUserList = mstPersonalUserDao.selectById(userId);
      paramIndUserName = mstPersonalUserList.getUserName();
    }
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("実行");
    logServiceCore.log(LogLevel.INFO, eventLogMessage, null, null, LoggingConstant.SERVICE_NAME.FNSI, null);
    eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(paramIndUserName);
    logServiceCore.log(LogLevel.INFO, eventLogMessage, null, null, LoggingConstant.SERVICE_NAME.FNSI, null);
    eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(userCd);
    logServiceCore.log(LogLevel.INFO, eventLogMessage, null, null, LoggingConstant.SERVICE_NAME.FNSI, null);

    return paramIndUserName;
  }

  /**
   * 治療予定編集時、治療予定の対象作成処理
   *
   * @param key          対象のkey名
   * @return 治療予定の対象
   */
  public String createPlanTarget(String key) {
    //治療予定の対象
    String paramTarget = null;

    switch (key) {
      //治療予定の場合
      case "治療予定":
        paramTarget = "治療予定";
        break;

      //治療方法の場合
      case "治療方法":
        paramTarget = "治療方法";
        break;

      //治療条件の場合
      // del 11555 指示履歴への記録の残り方が仕様と異なる zkm start
//      case "治療条件":
//        JSONObject indCondInfo = null;
//        if (ordMainValue == null) {
//          indCondInfo = new JSONObject("{}");
//        } else {
//          indCondInfo = new JSONObject(ordMainValue);
//        }
//        //治療条件の項目全てを格納するリスト
//        List<String> paramTargetList = new ArrayList<>();
//        // mod FNSI-【1006】最新の改修対象一覧の411対応 韓 start
//        //全部で39項目あるので、39回対象を取得する処理
//        // for(int i = 1; i< 39; i++){
//        for (int i = 1; i < 40; i++) {
//          // mod FNSI-【1006】最新の改修対象一覧の411対応 韓 end
//          if (! indCondInfo.has(String.valueOf(i))) continue;
//          paramTargetList.add(this.gettingEditTarget(String.valueOf(i)));
//        }
//        //リスト→文字列に変換して格納
//        paramTarget = String.join(",", paramTargetList);
//        break;
      // del 11555 指示履歴への記録の残り方が仕様と異なる zkm end

      //スケジュール変更の場合
      case "スケジュール変更":
        paramTarget = "クール,治療開始時刻,ベッド";
        break;

      //医療材料の場合
      case "医療材料":
        paramTarget = "医療材料";
        break;

      //投与薬剤の場合
      case "投与薬剤":
        paramTarget = "投与薬剤";
        break;
      // del 11555 指示履歴への記録の残り方が仕様と異なる zkm start
//      /* add #9355  by zhangruixue 2023-09-06 --start */
//      //装置設定の場合
//      case "装置設定":
//        paramTarget = "装置設定";
//        break;
//      /* add #9355  by zhangruixue 2023-09-06 --end */
      // del 11555 指示履歴への記録の残り方が仕様と異なる zkm end
      default:
        paramTarget = "指示コメント";
        break;
    }
    return paramTarget;
  }

  /**
   * 治療予定(予定作成, 予定コピー, 予定中止, 曜日パターン変更)の内容作成処理
   *
   * @param key          Json文字列の、登録する各項目のキー名(治療方法、治療条件、スケジュール変更、医療材料、投与薬剤、指示コメントのどれか)
   * @param ordMainValues Json文字列の、登録する各項目の値(キー名に対応する値)
   * @param facilityCd   施設コード
   * @param changeFlag   操作区分(1,新規 2,変更 3,削除)
   * @return 治療予定の対象
   */
  // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm start
//  public String createplanContent(String key, String ordMainValue, String facilityCd, String changeFlag) {
  public String createplanContent(String key, List<String> ordMainValues, String facilityCd, String changeFlag) {
    // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm end
    //設定する内容
    String paramContent = null;
    //内容に記載する文章のリスト
    List<String> paramContentList = new ArrayList<>();

    switch (key) {
      //治療予定の場合
      case "治療予定":
        //内容を作成してリストに追加
        String planContent = changeFlag.equals("1") ? "予定新規作成" : "予定中止";
        paramContentList.add(planContent);
        break;

      //治療方法の場合
      case "治療方法":
        //登録する治療方法コードを治療方法名称に変換
        // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm start
//        String editTreatmentName = this.changeTreatment(ordMainValue, facilityCd);
        String editTreatmentName = ordMainValues.stream().map(o -> changeTreatment(o, facilityCd)).distinct().collect(Collectors.joining(","));
        // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm end
        //内容を作成してリストに追加
        String methodContent = changeFlag.equals("1") ? editTreatmentName : editTreatmentName + "→ 中止";
        paramContentList.add(methodContent);
        break;

      //スケジュール変更の場合
      case "スケジュール変更":
        //クール、治療開始時刻、ベッドの順で値を取得
        //mod 8339 2023-02-05 名前に半角カンマが含まれる治療方法と紐づく治療方法セットを用いた際の動作不正 張 start
        // String[] scheduleValuesArray = ordMainValue.split(",");
        // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm start
//        JSONArray scheduleValuesArray = new JSONArray(ordMainValue);
        List<JSONArray> schList = ordMainValues.stream().map(JSONArray::new).distinct().toList();
        int maxSize = schList.stream().mapToInt(JSONArray::length).max().orElse(0);

        List<String> scheduleValueList = IntStream.range(0, maxSize)
          .mapToObj(i -> schList.stream().filter(arr -> arr.length() > i)
            .map(arr -> arr.get(i).toString()).distinct().collect(Collectors.joining(","))).toList();
        // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm end
        //リストに各内容を格納
//        for (String scheduleValues : scheduleValuesArray) {
//          String content = changeFlag.equals("1") ? scheduleValues : scheduleValues + "→ 中止";
        // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm start
//        for (Object scheduleValues : scheduleValuesArray) {
        for (Object scheduleValues : scheduleValueList) {
          // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm end
          String content = changeFlag.equals("1") ? scheduleValues.toString() : scheduleValues.toString() + "→ 中止";
          //mod 8339 2023-02-05 名前に半角カンマが含まれる治療方法と紐づく治療方法セットを用いた際の動作不正 張 end
          paramContentList.add(content);
        }
        break;

      //治療条件の場合
      case "治療条件":
        //治療条件詳細を取得
        // del 11555 指示履歴への記録の残り方が仕様と異なる zkm start
//        JSONObject indCondInfo = null;
//        if (ordMainValue == null) {
//          indCondInfo = new JSONObject("{}");
//        } else {
//          indCondInfo = new JSONObject(ordMainValue);
//        }
        // del 11555 指示履歴への記録の残り方が仕様と異なる zkm end
        //治療条件分、治療条件に登録する値を取得しリストに追加
        // mod FNSI-【1006】最新の改修対象一覧の411対応 韓 start
        // for(int i = 1; i < 39; i++){
        for (int i = 1; i < 40; i++) {
          // mod FNSI-【1006】最新の改修対象一覧の411対応 韓 end
          // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm start
//          if (! indCondInfo.has(String.valueOf(i))) continue;
//          //治療条件の単位取得のため、透析液・補液・抗凝固剤編集の場合は投与薬剤コードを取得
//          Object medicineCd = null;
//          Object medicineType = null;
//          Object medicineUnit = null;
//          try {
//            //透析液編集の場合
//            if (i >= 15 && i <= 18) {
//              // 透析液コード及び薬剤区分
//              // add #9973 Resolve null exception for key 20240117 ztc start
//              if(indCondInfo.optJSONObject("15") != null){
//              // add #9973 Resolve null exception for key 20240117 ztc end
//                medicineCd = indCondInfo.getJSONObject("15").get("value");
//                medicineType = indCondInfo.getJSONObject("15").get("medicine_type");
//                medicineUnit = indCondInfo.getJSONObject(String.valueOf(i)).get("unit");
//              }
//
//              //補液編集の場合
//            } else if (i >= 19 && i <= 24) {
//              // 補液コード
//              // add #9973 Resolve null exception for key 20240117 ztc start
//              if(indCondInfo.optJSONObject("19") != null) {
//              // add #9973 Resolve null exception for key 20240117 ztc end
//                medicineCd = indCondInfo.getJSONObject("19").get("value");
//                medicineType = indCondInfo.getJSONObject("19").get("medicine_type");
//                medicineUnit = indCondInfo.getJSONObject(String.valueOf(i)).get("unit");
//              }
//              //抗凝固剤の場合
//            } else if (i >= 25 && i <= 38) {
//              // 抗凝固剤コード
//              // add #9973 Resolve null exception for key 20240117 ztc start
//              if(indCondInfo.optJSONObject("25") != null) {
//              // add #9973 Resolve null exception for key 20240117 ztc end
//                medicineCd = indCondInfo.getJSONObject("25").get("value");
//                medicineType = indCondInfo.getJSONObject("25").get("medicine_type");
//                medicineUnit = indCondInfo.getJSONObject(String.valueOf(i)).get("unit");
//              }
//            }
//          } catch (Exception e) {
//            //薬剤が存在しない
//          }
//
//          JSONObject indCond = null;
//          try {
//            indCond = indCondInfo.getJSONObject(String.valueOf(i));
//          } catch (Exception e) {
//            //治療条件が存在しない
//            indCond = new JSONObject();
//          }
//
//          //治療条件に登録する値を取得
//          String condValue = this.gettingValue(String.valueOf(i), indCond, facilityCd, medicineCd, medicineType);
//
//          //治療条件の単位(TODO: 透析液、補液etc が選択されず、それに付随する条件が設定されている場合の処理。今後、判定処理不要の可能性が大)
//          String condUnit =
//            condValue.equals("未登録") || condValue.equals("DWと同じ")
//              // add #9914 補液計算優先項目を「濾過率から算出」に設定した時の補液速度と補液量の表示が不正 dengshen start
//              || condValue.equals("濾過率から算出")
//              // add #9914 補液計算優先項目を「濾過率から算出」に設定した時の補液速度と補液量の表示が不正 dengshen end
//              ? ""
//              : this.gettingCondUnit(String.valueOf(i), facilityCd, medicineCd, medicineType, medicineUnit);
//
//          //内容を作成
//          String content = changeFlag.equals("1") ? condValue + condUnit : condValue + condUnit + "→ 中止";

          int finalI = i;
          String contents = ordMainValues.stream().map(condInfoValue -> {
            //変更前の治療条件の詳細を取得
            JSONObject condInfo = null == condInfoValue ?
              new JSONObject() :
              new JSONObject(condInfoValue);
            if (!condInfo.has(String.valueOf(finalI))) return "dummy";
            //内容を作成
            return getConditionValUnit(facilityCd, finalI, condInfo);
          }).filter(content -> !content.isEmpty()).distinct().collect(Collectors.joining(","));

          if (StringUtils.hasText(contents)) {
            String content = changeFlag.equals("1") ? contents : contents + "→ 中止";
            //値をリストに追加
            paramContentList.add(content);
            // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm end
          }
        }
        break;

      //投与薬剤の場合
      case "投与薬剤":
        // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm start
//        //値が設定されているか判定
//        if (! Objects.isNull(ordMainValue)) {
//          //投与薬剤詳細リスト
//          List<Map<String, String>> indMedicineInfoList = this.changeListMap(ordMainValue);
//
//          for (int i = 0; i < indMedicineInfoList.size(); i++) {
//            //投与薬剤詳細を取得
//            JSONObject indMedicineInfo = new JSONObject(indMedicineInfoList.get(i));
        // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm
        List<Map<String, String>> indMediList = ordMainValues.stream().map(this::changeListMap).flatMap(List::stream).distinct().toList();
        Map<String, List<Map<String, String>>> mediMap = indMediList.stream().collect(Collectors.groupingBy(map -> map.get("no")));
        List<String> finalParamContentList2 = paramContentList;
        mediMap.forEach((k, subList) -> {
          //投与薬剤詳細を取得
          JSONObject indMedicineInfo = new JSONObject(subList.get(0));
          // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm end
          //編集後回数(治療予定では登録しないのでnullで定義)

          String nums = null;
          // mod bug 8128 修正 chen start
          //初回投与日
          String indDayIntervalStartDate = indMedicineInfo.has("init_date") ? indMedicineInfo.get("init_date").toString() : "";
          //投与間隔
          String indDayInterval = indMedicineInfo.has("date_interval") ? indMedicineInfo.get("date_interval").toString() : "";
          // mod bug 8128 修正 chen end
          //編集前の値一覧(使用しないので、nullで定義)
          // del 11555 指示履歴への記録の残り方が仕様と異なる zkm start
//            OrdMain ordMain = new OrdMain();
          // del 11555 指示履歴への記録の残り方が仕様と異なる zkm end

          //投与薬剤の内容を作成
          String medicineContent = this.createMedicineContent(
            indMedicineInfo,
            facilityCd,
            changeFlag,
            nums,
            indDayIntervalStartDate,
            indDayInterval,
            // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm start
//              ordMain);
            subList);
          // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm end

          //内容をリストに追加
          // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm start
          finalParamContentList2.add(medicineContent);
//          }
//        }
        });
        // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm end
        break;
      // del 11555 指示履歴への記録の残り方が仕様と異なる zkm start
//      /* add #9355  by zhangruixue 2023-09-06 --start */
//      //装置設定の場合
//      case "装置設定":
//        //値が設定されているか判定
//        if (! Objects.isNull(ordMainValue)) {
//          //内容をリストに追加
//          paramContentList = this.creatDeviceSetInfoContent(ordMainValue);
//          List<List<String>> deviceSetInfoListList = ordMainValues.stream().map(this::creatDeviceSetInfoContent).toList();
//          int maxSizeDeviceSet = deviceSetInfoListList.stream().mapToInt(List::size).max().orElse(0);
//
//          List<List<String>> deviceSetInfoList = IntStream.range(0, maxSizeDeviceSet)
//            .mapToObj(i -> deviceSetInfoListList.stream()
//              .filter(list -> list.size() > i)
//              .map(list -> list.get(i)).distinct().toList()).toList();
//
//          paramContentList = deviceSetInfoList.stream()
//            .map(infoList -> {
//              String value = String.join(":", infoList.get(0).split(":")[0], infoList.stream().map(d -> d.split(":")[1]).collect(Collectors.joining(",")));
//              return "3".equals(changeFlag) ? value + "→ 中止" : value;
//            }).toList();
//        }
//      break;
//      /* add #9355  by zhangruixue 2023-09-06 --end */
      // del 11555 指示履歴への記録の残り方が仕様と異なる zkm end
      //医療材料の場合
      case "医療材料":
        //値が設定されているか判定
        // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm start
//        if (! Objects.isNull(ordMainValue)) {
//          //医療材料詳細リスト
//          List<Map<String, String>> indEquipmentList = this.changeListMap(ordMainValue);
//        for (int i = 0; i < indEquipmentList.size(); i++) {
        //医療材料詳細を取得
//            JSONObject indEquipmentInfo = new JSONObject(indEquipmentList.get(i));
        List<Map<String, String>> indEquipList = ordMainValues.stream().map(this::changeListMap).flatMap(List::stream).distinct().toList();
        Map<String, List<Map<String, String>>> equipMap = indEquipList.stream()
          .collect(Collectors.groupingBy(map -> String.join("_", map.get("cd"), map.get("equip_type"))));
        List<String> finalParamContentList = paramContentList;
        equipMap.forEach((k, subList) -> {
          JSONObject indEquipmentInfo = new JSONObject(subList.get(0));
          // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm end

          //医療材料の内容を作成
          String equipmentContent = this.createEquipmentContent(
            indEquipmentInfo,
            facilityCd,
            changeFlag,
            "2",
            "",
            // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm start
//              new OrdMain());
            subList);
          // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm end

          //内容をリストに追加
          // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm start
          finalParamContentList.add(equipmentContent);
//          }
//        }
        });
        // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm end
        break;

      //指示コメントの場合
      default:
        //値が設定されているか判定
        // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm start
//        if (! Objects.isNull(ordMainValue)) {
//          //指示コメント詳細リスト
//          List<Map<String, String>> indCommentList = this.changeListMap(ordMainValue);
//          for (int i = 0; i < indCommentList.size(); i++) {
//            //指示コメント詳細を取得
//            JSONObject indCommentInfo = new JSONObject(indCommentList.get(i));
        List<Map<String, String>> indCommentList = ordMainValues.stream().map(this::changeListMap).flatMap(List::stream).distinct().toList();
        Map<String, List<Map<String, String>>> indCommentMap = indCommentList.stream().collect(Collectors.groupingBy(map -> map.get("no")));
        List<String> finalParamContentList1 = paramContentList;
        indCommentMap.forEach((k, subList) -> {
          JSONObject indCommentInfo = new JSONObject(subList.get(0));
          // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm end
          // mod bug 8128 修正 chen start
          //指示コメント番号
          String commentNum = indCommentInfo.has("no") ? indCommentInfo.get("no").toString() : "";
          // mod bug 8128 修正 chen end
          //指示コメント
          String comment =
            indCommentInfo.has("content")
              ? indCommentInfo.get("content").toString()
              : null;

          //指示コメントの内容を作成
          String commentContent = this.createCommentContent(
            changeFlag,
            commentNum,
            comment,
            // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm start
            subList.stream().filter(i -> i.containsKey("content")).map(i -> i.get("content")).distinct().toList());
          // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm end

          //内容をリストに追加
          // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm start
          finalParamContentList1.add(commentContent);
//          }
//        }
        });
        // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm end
        break;
    }
    //内容のリスト→文字列に変換
    // paramContent = String.join(",", paramContentList);
    paramContent = JSONObject.valueToString(paramContentList);
    //何も設定されていない場合、"未登録"と設定
    paramContent = paramContent.isEmpty() ? "未登録" : paramContent;

    return paramContent;
  }

  private String getConditionValUnit(String facilityCd, int i, JSONObject indCondInfo) {
    //治療条件の単位取得のため、透析液・補液・抗凝固剤編集の場合は投与薬剤コードを取得
    Object medicineCd = null;
    Object medicineType = null;
    Object medicineUnit = null;
    try {
      //透析液編集の場合
      if (i >= 15 && i <= 18) {
        if(indCondInfo.optJSONObject("15") != null) {
          medicineCd = indCondInfo.getJSONObject("15").get("value");
          medicineType = indCondInfo.getJSONObject("15").get("medicine_type");
          medicineUnit = indCondInfo.getJSONObject(String.valueOf(i)).get("unit");
        }
        //補液編集の場合
      } else if (i >= 19 && i <= 24) {
        if (indCondInfo.optJSONObject("19") != null) {
          medicineCd = indCondInfo.getJSONObject("19").get("value");
          medicineType = indCondInfo.getJSONObject("19").get("medicine_type");
          medicineUnit = indCondInfo.getJSONObject(String.valueOf(i)).get("unit");
        }
        //抗凝固剤の場合
      } else if (i >= 25 && i <= 38) {
        if (indCondInfo.optJSONObject("25") != null) {
          medicineCd = indCondInfo.getJSONObject("25").get("value");
          medicineType = indCondInfo.getJSONObject("25").get("medicine_type");
          medicineUnit = indCondInfo.getJSONObject(String.valueOf(i)).get("unit");
        }
      }
    } catch (Exception e) {
      //薬剤が存在しない
    }

    JSONObject indCond;
    try {
      indCond = indCondInfo.getJSONObject(String.valueOf(i));
    } catch (Exception e) {
      //治療条件が存在しない
      indCond = new JSONObject();
    }

    //変更後の治療条件の値を取得
    String condValue = this.gettingValue(String.valueOf(i), indCond, facilityCd, medicineCd, medicineType);
    //変更後の値の単位
    String condUnit =
      condValue.equals("未登録") || condValue.equals("DWと同じ")
        ? ""
        : this.gettingCondUnit(String.valueOf(i), facilityCd, medicineCd, medicineType, medicineUnit);
    return String.join("", condValue, condUnit);
  }

  /**
   * 指示履歴に登録する、医療材料内容を作成する処理
   *
   * @param equipmentInfo   画面から取得した医療材料の詳細
   * @param facilityCd      施設コード
   * @param flag            判別フラグ(1.新規、2.変更,3.削除)
   * @param autoInsert      穴埋め有無(0.穴埋めしない、1.穴埋めする) 治療方法編集から作成する際は2を受け取る。
   * @param targetEquipment 更新対象となる医療材料コード
   * @param indInfoEquipmentList  編集前の値一覧
   * @return 医療材料内容
   */
  public String createEquipmentContent(
    JSONObject equipmentInfo,
    String facilityCd,
    String flag,
    String autoInsert,
    String targetEquipment,
    // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm start
//    OrdMain ordMain) {
    List<Map<String, String>> indInfoEquipmentList) {
    // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm end

    //設定する内容
    String paramContent = null;
    //改行のための変数を取得
    String br = System.getProperty("line.separator");

    //医療材料コードを取得
    // mod bug 8128 修正 chen start
    String equipmentCd =
      !equipmentInfo.has("cd") || Objects.equals(equipmentInfo.get("cd"), null)
        ? ""
        : equipmentInfo.get("cd").toString();

    //医療材料コードから医療材料名称を取得
    String equipmentName = "";
    String equipmentType =
      !equipmentInfo.has("equip_type") || Objects.equals(equipmentInfo.get("equip_type"), null)
        ? ""
        : equipmentInfo.get("equip_type").toString();
    // mod bug 8128 修正 chen end

    if (! equipmentType.isEmpty()) {
      // 医療材料区分 0:医療材料、1:ダイアライザ で処理を分ける
      if (equipmentType.equals("0")) {
        equipmentName = this.changeEquipment(equipmentCd, facilityCd);
      } else if (equipmentType.equals("1")) {
        equipmentName = this.changeDialyzer(equipmentCd, facilityCd);
      }
    }

    //医療材料の数量を取得
    String equipmentAmount = "未登録";
    //keyに数量が設定されているか判定
    if (equipmentInfo.has("amount")) {
      //nullの場合は"未登録"と変換しておく
      if (! Objects.equals(equipmentInfo.get("amount"), null))
        equipmentAmount = equipmentInfo.get("amount").toString();
    }

    //治療予定・治療方法にて医療材料を登録した場合、単位が格納されていないので取得
    if (! equipmentInfo.has("unit")) {
      String unit = this.gettingEquipmentUnit(equipmentCd, facilityCd);
      //取得した医療材料単位を医療材料詳細に格納
      equipmentInfo.put("unit", unit);
    }
    //医療材料の単位を取得(単位が無い場合はnull→空文字に変換処理)
    String equipmentUnit = "";
    if (equipmentInfo.has("unit")) {
      if (! equipmentAmount.equals("未登録")) {
        if (! Objects.equals(equipmentInfo.get("unit"), null))
          equipmentUnit = equipmentInfo.get("unit").toString();
      }
    }

    //編集前の医療材料名称
    String previousEquipmentName = "未登録";
    // del 11555 指示履歴への記録の残り方が仕様と異なる zkm start
//    //編集前の医療材料の数量
//    String previousEquipmentAmount = "未登録";
    // del 11555 指示履歴への記録の残り方が仕様と異なる zkm end
    //編集前の医療材料の単位
    String previousEquipmentUnit = "";

    //画面上で選択した、編集前の医療材料一覧
    // del 11555 指示履歴への記録の残り方が仕様と異なる zkm start
//    List<Map<String, String>> indInfoEquipmentList = new ArrayList<>();
//    //配列型Json文字列で格納された医療材料一覧をList型に変換
//
//    if (Objects.isNull(ordMain.getIndEquipInfo())) {
//      indInfoEquipmentList.add(new HashMap<String, String>());
//    } else {
//      indInfoEquipmentList = this.changeListMap(ordMain.getIndEquipInfo());
//    }
    // del 11555 指示履歴への記録の残り方が仕様と異なる zkm end
    for (int i = 0; i < indInfoEquipmentList.size(); i++) {
      //編集前の医療材料コード
      String cd = indInfoEquipmentList.get(i).get("cd");

      //編集を行った医療材料の編集前の各値を保持
      if (targetEquipment.equals(cd)) {
        //編集前の医療材料名称
        if (! (targetEquipment.isEmpty() || equipmentType.isEmpty())) {
          // 医療材料区分 0:医療材料、1:ダイアライザ で処理を分ける
          if (equipmentType.equals("0")) {
            previousEquipmentName = this.changeEquipment(targetEquipment, facilityCd);
          } else if (equipmentType.equals("1")) {
            previousEquipmentName = this.changeDialyzer(targetEquipment, facilityCd);
          }
        }

        // del 11555 指示履歴への記録の残り方が仕様と異なる zkm start
//        //編集前の医療材料数量
//        String amount = indInfoEquipmentList.get(i).get("amount");
//        if (! Objects.isNull(amount)) previousEquipmentAmount = amount;
//
//        //単位(数量が設定されており、単位がある医療材料の場合に取得)
//        if (! previousEquipmentAmount.equals("未登録")) {
        // del 11555 指示履歴への記録の残り方が仕様と異なる zkm end
        String unit = this.gettingEquipmentUnit(cd, facilityCd);
        if (! Objects.isNull(unit)) previousEquipmentUnit = unit;
        // del 11555 指示履歴への記録の残り方が仕様と異なる zkm start
//        }
        // del 11555 指示履歴への記録の残り方が仕様と異なる zkm end
        break;
      }
    }

    //設定する内容を作成
    //新規の場合
    if (flag.equals("1")) {
      /* mod #10276  by zhangruixue 2024-02-26 --start */
      switch (autoInsert) {
        //穴埋めしない
        case "0":
          paramContent =
            equipmentName
              + br + "数量:" + equipmentAmount + equipmentUnit + "(全追加)";
//          + br + "医療材料存在時:合算";
          break;
        //穴埋めする
        case "1":
          paramContent =
            equipmentName
              + br + "数量:" + equipmentAmount + equipmentUnit + "(穴埋め追加)";
//              + br + "医療材料存在時:登録しない";
          break;
        //治療方法から内容を作成する場合
        default:
          paramContent =
            equipmentName
              + br + "数量:" + equipmentAmount + equipmentUnit;
          break;
      }
      /* mod #10276  by zhangruixue 2024-02-26 --end */
    }
    //変更の場合
    else if (flag.equals("2")) {

      // add 11555 指示履歴への記録の残り方が仕様と異なる zkm start
      //編集前の医療材料数量
      String finalPreviousEquipmentUnit = previousEquipmentUnit;
      List<String> equipmentAmounts = indInfoEquipmentList.stream()
        .map(e -> e.get("amount"))
        .filter(Objects::nonNull)
        .map(amount -> amount + finalPreviousEquipmentUnit).distinct().toList();
      // add 11555 指示履歴への記録の残り方が仕様と異なる zkm end
      //内容に記載する医療材料名称の文章を設定
      String equipmentContent = previousEquipmentName + "→" + equipmentName;
      //内容に記載する数量と単位の文章を設定
      // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm start
//      String amountContent = previousEquipmentAmount + previousEquipmentUnit + "→" + equipmentAmount + equipmentUnit;
      String amountContent = String.join(",", equipmentAmounts) + "→" + equipmentAmount + equipmentUnit;
      // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm end

      //医療材料に変更がなければ、矢印無しで表示。未登録のままなら"未登録"と表示
      if (previousEquipmentName.equals(equipmentName)) {
        equipmentContent =
          previousEquipmentName.equals("未登録") && equipmentName.equals("未登録")
            ? "未登録"
            : equipmentName;
      }

      //数量と単位に変更がなければ、矢印無しで表示。未登録のままなら"未登録"と表示
      // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm start
//      if (previousEquipmentAmount.equals(equipmentAmount)) {
//        amountContent =
//          previousEquipmentAmount.equals("未登録") && equipmentAmount.equals("未登録")
      if (equipmentAmounts.size() == 1 && equipmentAmounts.get(0).contains("未登録")) {
        amountContent = equipmentAmount.equals("未登録")
          // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm end
          ? "未登録"
          : equipmentAmount + equipmentUnit;
      }

      /* mod #10276  by zhangruixue 2024-02-26 --start */
      switch (autoInsert) {
        //穴埋めしない
        case "0":
          paramContent =
            equipmentContent
              + br + "数量:" + amountContent + "(補填なし編集)";
//          + br + "医療材料存在しない時:登録しない";
          break;
        //穴埋めする
        default:
          paramContent =
            equipmentContent
              + br + "数量:" + amountContent + "(補填あり編集)";
//          + br + "医療材料存在しない時:登録する";
          break;
      }
      /* mod #10276  by zhangruixue 2024-02-26 --end */
    }
    //削除の場合
    else {
      // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm start
//      paramContent = equipmentName + "→中止" + br + "数量:" + equipmentAmount + equipmentUnit;
      //編集前の医療材料数量
      String finalPreviousEquipmentUnit = previousEquipmentUnit;
      List<String> equipmentAmounts = indInfoEquipmentList.stream().map(e -> e.get("amount")).filter(Objects::nonNull).map(amount -> amount + finalPreviousEquipmentUnit).distinct().toList();
      paramContent = equipmentName + "→中止" + br + "数量:" + String.join(",", equipmentAmounts);
      // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm end
    }
    return paramContent;
  }

  /**
   * 医療材料コードから単位を取得する処理
   * TODO: 治療作成・治療方法のOrdMainResourceで医療材料単位を格納すべき。このメソッドが必要がなくなる。
   *
   * @param equipmentCd 画面から取得した医療材料コード
   * @param facilityCd  施設コード
   * @return 医療材料コードに対応する単位
   */
  private String gettingEquipmentUnit(String equipmentCd, String facilityCd) {
    //医療材料単位
    String unit = null;

    //マスタ取得用パラメータに施設コードを設定
    MstEquipment mstEquipmentParam = new MstEquipment();
    mstEquipmentParam.setFacilityCd(facilityCd);
    //投与薬剤マスタを取得
    SelectOptions selectOptions = SelectOptions.get();
    List<MstEquipment> mstEquipmentList = mstEquipmentDao.selectAll(selectOptions, mstEquipmentParam);

    //医療材料の単位を取得
    for (MstEquipment mstEquipment : mstEquipmentList) {
      //マスタ医療材料コード
      String mstCd = mstEquipment.getEquipmentCd().toString();
      //医療材料コードを比較し、該当する医療材料単位を取得
      if (mstCd.equals(equipmentCd)) {
        unit = mstEquipment.getUnit();
        break;
      }
    }
    return unit;
  }

  /**
   * 指示履歴に登録する、投与薬剤内容を作成する処理
   *
   * @param medicineInfo            画面から取得した投与薬剤の詳細
   * @param facilityCd              施設コード
   * @param flag                    判別フラグ(1.新規、2.変更,3.削除)
   * @param nums                    変更後回数
   * @param indDayIntervalStartDate 初回投与日
   * @param indDayInterval          投与間隔
   * @param indInfoMedicineList                 編集前の値一覧
   * @return 投与薬剤内容
   */
  public String createMedicineContent(
    JSONObject medicineInfo,
    String facilityCd,
    String flag,
    String nums,
    String indDayIntervalStartDate,
    String indDayInterval,
    // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm start
//    OrdMain ordMain) {
    List<Map<String, String>> indInfoMedicineList) {
    // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm end

    //設定する内容
    String paramContent = null;
    //改行のための変数を取得
    String br = System.getProperty("line.separator");

    //投与薬剤コードを取得
    // mod bug 8128 修正 chen start
    String medicineCd =
      !medicineInfo.has("cd") || Objects.equals(medicineInfo.get("cd"), null)
        ? ""
        : medicineInfo.get("cd").toString();
    //投与薬剤区分を取得
    String medicineType =
      !medicineInfo.has("medicine_type") || Objects.equals(medicineInfo.get("medicine_type"), null)
        ? ""
        : medicineInfo.get("medicine_type").toString();
    // mod bug 8128 修正 chen end
    //投与薬剤コードから投与薬剤名称を取得
    String medicineName =
      this.changeMedicine(medicineCd, medicineType, facilityCd);

    //手技コードを取得
    String procedureCd = "";
    if (medicineInfo.has("procedure_cd")) {
      if (! Objects.equals(medicineInfo.get("procedure_cd"), null))
        procedureCd = medicineInfo.get("procedure_cd").toString();
    }
    //手技コードから手技名称を取得
    String procedureName =
      procedureCd.isEmpty()
        ? "未登録"
        : this.changeProcedure(procedureCd, facilityCd);

    //投与タイミングコードを取得
    String timingCd = "";
    if (medicineInfo.has("timing_cd")) {
      if (! Objects.equals(medicineInfo.get("timing_cd"), null))
        timingCd = medicineInfo.get("timing_cd").toString();
    }
    //投与タイミングコードから投与タイミング名称を取得
    String timingName =
      timingCd.isEmpty()
        ? "未登録"
        : this.changeTiming(timingCd, facilityCd);

    //投与薬剤数量を取得
    String medicineAmount = "未登録";
    if (medicineInfo.has("amount")) {
      if (! Objects.equals(medicineInfo.get("amount"), null) && ! Objects.equals(medicineInfo.get("amount"), ""))
        medicineAmount = changeMedicineValue(medicineInfo.get("amount").toString(), medicineCd, medicineType, facilityCd, "1");
    }

    //治療予定・治療方法にて投与薬剤を登録した場合、単位が格納されていないので取得
    if (! medicineInfo.has("unit")) {
      String unit = this.gettingMedicineUnit(medicineCd, facilityCd, medicineType, "1");
      //取得した投与薬剤単位を投与薬剤詳細に格納
      medicineInfo.put("unit", unit);
    }
    //投与薬剤数量の単位を取得(数量の設定値が無い場合や単位が無い場合は空文字で保持)
    String medicineUnit = "";
    if (medicineInfo.has("unit")) {
      if (! medicineAmount.equals("未登録")) {
        if (! Objects.equals(medicineInfo.get("unit"), null))
          medicineUnit = medicineInfo.get("unit").toString();
      }
    }

    //コメントを取得
    String comment = "未登録";
    //コメントが設定されている場合は値を取得
    if (medicineInfo.has("comment")) {
      if (! Objects.equals(medicineInfo.get("comment"), null)) {
        if (! medicineInfo.get("comment").toString().isEmpty())
          comment = medicineInfo.get("comment").toString();
      }
    }

    //更新対象のシーケンス番号を取得
    String targetNo = "";
    if (medicineInfo.has("no")) targetNo = medicineInfo.get("no").toString();

    //初回投与日を取得
    String dayIntervalStartDate =
      Objects.isNull(indDayIntervalStartDate) || indDayIntervalStartDate.isEmpty()
        ? "未登録"
        : indDayIntervalStartDate.replaceAll("-", "");

    //投与間隔を取得
    String dayInterval = this.changeInterval(indDayInterval);

    // del 11555 指示履歴への記録の残り方が仕様と異なる zkm start
//    //編集前の投与薬剤一覧
//    List<Map<String, String>> indInfoMedicineList = new ArrayList<>();
//    //編集前の投与薬剤一覧を取得
//
//    if (Objects.isNull(ordMain.getIndMediInfo())) {
//      indInfoMedicineList.add(new HashMap<String, String>());
//    } else {
//      indInfoMedicineList = this.changeListMap(ordMain.getIndMediInfo());
//    }
    // del 11555 指示履歴への記録の残り方が仕様と異なる zkm end

    //編集前の投与薬剤コード
    String preMedicineCd = "";
    //編集前の投与薬剤区分
    String preMedicineType = "";
    //編集前の投与薬剤名称
    String preMedicineName = "未登録";
    // del 11555 指示履歴への記録の残り方が仕様と異なる zkm start
//    //編集前の投与薬剤数量
//    String preMedicineAmount = "未登録";
    // del 11555 指示履歴への記録の残り方が仕様と異なる zkm start
    //編集前の投与薬剤単位
    String preMedicineUnit = "";
    //編集前の手技コード
    String preProcedureCd = "";
    //編集前の手技
    String preProcedureName = "未登録";
    //編集前の投与タイミングコード
    String preTimingCd = "";
    //編集前の投与タイミング
    String preTiming = "未登録";

    for (Map<String, String> indInfoMedicine : indInfoMedicineList) {
      //編集前の投与薬剤シーケンス番号
      String no = indInfoMedicine.get("no");

      //編集を行った投与薬剤の編集前の各値を保持
      if (targetNo.equals(no)) {
        //編集前の投与薬剤コード
        if (! Objects.isNull(indInfoMedicine.get("cd"))) {
          preMedicineCd = indInfoMedicine.get("cd");
          preMedicineType = indInfoMedicine.get("medicine_type");
        }
        //編集前の投与薬剤名称
        preMedicineName = this.changeMedicine(preMedicineCd, preMedicineType, facilityCd);

        // del 11555 指示履歴への記録の残り方が仕様と異なる zkm start
//        //編集前の投与薬剤数量
//        String amount = indInfoMedicine.get("amount");
//        if (! Objects.isNull(amount) && ! Objects.equals(amount, ""))
//          preMedicineAmount = changeMedicineValue(amount, preMedicineCd, preMedicineType, facilityCd, "1");
//
//
//        //編集前の投与薬剤単位
//        if (! preMedicineAmount.equals("未登録")) {
        // del 11555 指示履歴への記録の残り方が仕様と異なる zkm end
        String unit = indInfoMedicine.get("unit");
        if (Objects.isNull(unit)) {
          preMedicineUnit = this.gettingMedicineUnit(preMedicineCd, facilityCd, preMedicineType, "1");
          //単位が無い投与薬剤の場合は、単位をnull→空文字に変換
          if (Objects.isNull(preMedicineUnit)) {
            preMedicineUnit = "";
          }
        } else {
          preMedicineUnit = unit;
        }
        // del 11555 指示履歴への記録の残り方が仕様と異なる zkm start
//        }
        // del 11555 指示履歴への記録の残り方が仕様と異なる zkm end

        //編集前の手技コード, 手技名称
        if (! Objects.isNull(indInfoMedicine.get("procedure_cd"))) {
          preProcedureCd = indInfoMedicine.get("procedure_cd");
          preProcedureName = this.changeProcedure(preProcedureCd, facilityCd);
        }

        //編集前の投与タイミングコード, 投与タイミング名称
        if (! Objects.isNull(indInfoMedicine.get("timing_cd"))) {
          preTimingCd = indInfoMedicine.get("timing_cd");
          preTiming = this.changeTiming(preTimingCd, facilityCd);
        }
        break;
      }
    }

    // add 11555 指示履歴への記録の残り方が仕様と異なる zkm start
    String finalPreMedicineUnit = preMedicineUnit;
    List<String> mediAmounts = indInfoMedicineList.stream()
      .map(e -> e.get("amount"))
      .filter(Objects::nonNull)
      .map(amount -> amount + finalPreMedicineUnit).distinct().toList();
    // add 11555 指示履歴への記録の残り方が仕様と異なる zkm end

    //設定する内容を作成
    switch (flag) {
      //新規の場合
      case "1":
        //登録する回数の文章を作成
        // del 11555 指示履歴への記録の残り方が仕様と異なる zkm start
//        String numsContent = Objects.isNull(nums) ? "未登録" : nums + "回";
        // del 11555 指示履歴への記録の残り方が仕様と異なる zkm end

        paramContent =
          medicineName
            + br + "数量:" + medicineAmount + medicineUnit
            + br + "初回投与日:" + dayIntervalStartDate
            + br + "投与間隔:" + dayInterval
            + br + "手技:" + procedureName
            + br + "投与タイミング:" + timingName
            + br + "コメント:" + comment;
        // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm start
//            + br + "回数:" + numsContent;
        paramContent = StringUtils.hasText(nums) ? paramContent + br + "回数:" + nums + "回" : paramContent;
        // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm end
        break;
      //変更の場合
      case "2":
        //登録する投与薬剤名称の文章を作成(変更が無い場合は登録する値のみ表示)
        String medicineNameContent = preMedicineName + "→" + medicineName;
        if (medicineCd.equals(preMedicineCd))
          medicineNameContent = medicineName;

        //登録する数量の文章を作成
        // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm start
//        String amountContent = preMedicineAmount + preMedicineUnit + "→" + medicineAmount + medicineUnit;
        String amountContent = String.join(",", mediAmounts) + "→" + medicineAmount + medicineUnit;
        // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm end
        //数量の変更有無を確認するため、小数点以下まで保持
        float fltAmount = - 1;
        float fltPreAmount = - 1;
        //数値の場合は型を変換、"未登録"の場合は0を保持
        try {
          fltAmount = Float.parseFloat(medicineAmount);
        } catch (Exception e) {
          fltAmount = 0;
        }
        // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm start
        List<String> mediAmountNoUnits = indInfoMedicineList.stream()
          .map(e -> e.get("amount"))
          .filter(Objects::nonNull).distinct().toList();
        if (mediAmountNoUnits.size() == 1) {
          try {
//            fltPreAmount = Float.parseFloat(preMedicineAmount);
            fltPreAmount = Float.parseFloat(mediAmountNoUnits.get(0));
            // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm end
          } catch (Exception e) {
            fltPreAmount = 0;
          }
          //変更有無を確認(変更が無い場合は登録する値のみ表示)
          if (Float.compare(fltPreAmount, fltAmount) == 0 && preMedicineUnit.equals(medicineUnit))
            amountContent = medicineAmount + medicineUnit;
        }

        //登録する手技の文章を作成(変更が無い場合は登録する値のみ表示)
        String procedureContent = preProcedureName + "→" + procedureName;
        if (preProcedureCd.equals(procedureCd))
          procedureContent = procedureName;

        //登録する投与タイミングの文章を作成(変更が無い場合は登録する値のみ表示)
        String timingContent = preTiming + "→" + timingName;
        if (preTimingCd.equals(timingCd)) timingContent = timingName;

        paramContent =
          medicineNameContent
            + br + "数量:" + amountContent
            + br + "手技:" + procedureContent
            + br + "投与タイミング:" + timingContent
            + br + "コメント:" + comment;
        // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm start
//            + br + "回数:" + nums + "回";
        paramContent = StringUtils.hasText(nums) ? paramContent + br + "回数:" + nums + "回" : paramContent;
        // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm end
        break;
      default:
        paramContent =
          medicineName + "→中止"
            // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm start
//            + br + "数量:" + medicineAmount + medicineUnit
            + br + "数量:" + String.join(",", mediAmounts)
            // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm end
            + br + "初回投与日:" + dayIntervalStartDate
            + br + "投与間隔:" + dayInterval;
        // add 11555 指示履歴への記録の残り方が仕様と異なる zkm start
        paramContent = StringUtils.hasText(nums) ? paramContent + br + "回数:" + nums + "回" : paramContent;
        // add 11555 指示履歴への記録の残り方が仕様と異なる zkm end
        break;
    }
    return paramContent;
  }

  /**
   * 手技コードから手技名称に変換する処理
   *
   * @param procedureCd 画面から取得した手技コード
   * @param facilityCd  画面から取得した施設コード
   * @return 手技コードに対応する手技名称
   */
  private String changeProcedure(String procedureCd, String facilityCd) {
    //手技コードに対応する手技名称
    String procedureName = "";
    //手技コードの比較のため、nullの場合は空文字に変換
    String checkedProcedureCd = Objects.isNull(procedureCd) ? "" : procedureCd;

    //マスタ取得用パラメータに施設コードを設定
    MstProcedure mstProcedure = new MstProcedure();
    mstProcedure.setFacilityCd(facilityCd);
    //マスタ取得処理
    SelectOptions selectOptions = SelectOptions.get();
    List<MstProcedure> mstProcedureList = mstProcedureDao.selectAll(selectOptions, mstProcedure);

    //投与薬剤コードに対応する投与薬剤名称を取得
    for (int i = 0; i < mstProcedureList.size(); i++) {
      //投与薬剤コードを数値→文字列に変換
      String mstProcedureCd = String.valueOf(mstProcedureList.get(i).getProcedureCd());
      //マスタ投与薬剤コードと比較し、投与薬剤コードに対応する投与薬剤名称を取得
      if (checkedProcedureCd.equals(mstProcedureCd)) {
        procedureName = mstProcedureList.get(i).getPricedureName();
      }
    }
    return procedureName;
  }

  /**
   * 投与タイミングコードから投与タイミング名称に変換する処理
   *
   * @param timingCd   画面から取得した投与タイミングコード
   * @param facilityCd 画面から取得した施設コード
   * @return 投与タイミングコードに対応する手技名称
   */
  private String changeTiming(String timingCd, String facilityCd) {
    //投与薬剤コードに対応する投与薬剤名
    String timingName = "";
    //投与タイミングコードの比較のため、nullの場合は空文字に変換
    String checkedTimingCd = Objects.isNull(timingCd) ? "" : timingCd;

    //マスタ取得用パラメータに施設コードを設定
    MstMedicateTiming mstMedicateTiming = new MstMedicateTiming();
    mstMedicateTiming.setFacilityCd(facilityCd);
    //マスタ取得処理
    SelectOptions selectOptions = SelectOptions.get();
    List<MstMedicateTiming> mstMedicateTimingList = mstMedicateTimingDao.selectAll(selectOptions, mstMedicateTiming);

    //投与薬剤コードに対応する投与薬剤名称を取得
    for (int i = 0; i < mstMedicateTimingList.size(); i++) {
      //投与薬剤コードを数値→文字列に変換
      String mstMedicateTimingCd = String.valueOf(mstMedicateTimingList.get(i).getMedicateTimingCd());
      //マスタ投与薬剤コードと比較し、投与薬剤コードに対応する投与薬剤名称を取得
      if (checkedTimingCd.equals(mstMedicateTimingCd)) {
        timingName = mstMedicateTimingList.get(i).getMedicateTimingName();
      }
    }
    return timingName;
  }

  /**
   * 治療条件の単位を返す処理
   * TODO: 治療情報データのind_cond_infoに単位格納していれば、この処理は不要になる。
   * TODO: →治療情報は実績データ作成後にunit値を持つため、unit値があればunit値優先→なければマスタ参照に変える必要がある？
   *
   * @param targetKey    画面にて編集した治療条件対象の項目番号
   * @param facilityCd   画面から取得した施設コード
   * @param medicineCd   投与薬剤コード(透析液、補液、抗凝固剤のいずれかの投与薬剤コード)
   * @param medicineType 画面から取得した薬剤区分
   * @param medicineUnit 画面から取得した単位値（貰っている場合のみ）
   * @return 治療条件の単位
   */
  private String gettingCondUnit(String targetKey, String facilityCd, Object medicineCd, Object medicineType, Object medicineUnit) {
    //治療条件の単位
    String unit = "";

    switch (targetKey) {
      //目標体重
      case "3":
        unit = "kg";
        break;

      //4:除水量制限、20:補液量
      case "4":
      case "20":
        unit = "L";
        break;

      //14:血流量、16:透析液流量
      case "14":
      case "16":
        unit = "mL/min";
        break;

      //17:透析液量、 22:補液使用数、26:抗凝固剤ワンショット量、27:抗凝固剤持続速度、28:抗凝固剤持続総量
      case "17":
      case "22":
      case "26":
      case "27":
      case "28":
        // 変更後unit値が貰える場合にはそれをそのまま使用（画面表示単位）
        if (! Objects.equals(medicineUnit, null)) {
          unit = medicineUnit.toString();
          break;
        }
        //貰えていないケース：投与薬剤コードから取得
        String strMedicineCd =
          Objects.equals(medicineCd, null)
            ? null
            : medicineCd.toString();

        //単位取得の元となる投与薬剤が設定されているか判定
        if (! Objects.isNull(strMedicineCd)) {
          // 薬剤区分(薬剤/調製薬剤:設定されていない場合はとりあえず薬剤マスタ参照)
          String strMedicineType =
            Objects.equals(medicineType, null)
              ? "1"
              : medicineType.toString();

          // 取得単位(指示単位)
          String strUnitType = "1";
          if (targetKey.equals("17") || targetKey.equals("22")) {
            // 透析液使用数及び補液使用数:レセ単位
            strUnitType = "0";
          }

          //選択した透析液の単位を取得
          unit = this.gettingMedicineUnit(strMedicineCd, facilityCd, strMedicineType, strUnitType);
          //単位が無い投与薬剤の場合は、単位をnull→空文字に変換
          if (Objects.isNull(unit)) unit = "";
          //抗凝固剤持続速度の場合、時間当たりの単位に変更
          if (targetKey.equals("27")) unit = unit + "/h";
        }
        break;

      //18:透析液温度,23:補液温度
      case "18":
      case "23":
        unit = "℃";
        break;

      //補液速度
      case "24":
        unit = "L/h";
        break;

      //IPワンショット量
      case "31":
        unit = "mL";
        break;

      //32:IP速度、33:IP速度最大値
      case "32":
      case "33":
        unit = "mL/h";
        break;

      // 36:IP電源自動切り時間、38:IP電源OK自動切り時間
      case "36":
      case "38":
        unit = "分前";
        break;
      //DW
      case "39":
        unit = "kg";
        break;

      default:
        break;
    }
    return unit;
  }

  /**
   * 投与薬剤コードから単位を取得する処理
   * TODO: 治療作成・治療方法のOrdMainResourceで投与薬剤単位を格納すべき。このメソッドが必要がなくなる。
   * TODO: 投与薬剤単位はord_mainの実績確定後はjson保持されるが、実績確定前はマスタ参照である必要があるため、必要と推測。
   *
   * @param medicineCd   画面から取得した投与薬剤コード ※null値と文字列としてのnullの両方のパターンがあるため留意
   * @param facilityCd   施設コード
   * @param medicineType 薬剤区分
   * @param unitType     　取得するユニットタイプ(薬剤マスタ時のみ：レセ単位(0)or指示単位(1))
   * @return 投与薬剤コードに対応する単位
   */
  private String gettingMedicineUnit(String medicineCd, String facilityCd, String medicineType, String unitType) {
    //投与薬剤単位
    String unit = null;
    //投与薬剤コードの比較のため、nullの場合は空文字に変換
    String checkedMedicineCd = Objects.isNull(medicineCd) ? "" : medicineCd;
    //投与薬剤区分の比較のため、nullの場合は空文字に変換
    String checkedMedicineType = Objects.isNull(medicineType) ? "" : medicineType;

    if (checkedMedicineType.equals("1") && Objects.nonNull(medicineCd) && ! (checkedMedicineCd.equals("null"))) {
      // 対象が薬剤マスタの場合
      MstMedicine medicine = mstMedicineDao.selectByCd(facilityCd, checkedMedicineCd==""?0:Integer.parseInt(checkedMedicineCd));
      if (medicine != null) {
        if (unitType.equals("0")) {
          // レセ単位
          unit = medicine.getUnitSecond();
        } else {
          // 指示単位
          unit = medicine.getUnit();
        }
      }
    } else if (checkedMedicineType.equals("2") && Objects.nonNull(medicineCd) && ! (checkedMedicineCd.equals("null"))) {
      // 調整薬剤の場合
      MstMedicineMix medicineMix = mstMedicineMixDao.selectByCd(facilityCd, checkedMedicineCd==""?0:Integer.parseInt(checkedMedicineCd));
      if (medicineMix != null) {
        unit = medicineMix.getUnit();
      }
    }
    return unit;
  }

  /**
   * 治療条件対象の値を返す処理
   *
   * @param targetKey    治療条件対象の項目番号
   * @param objectTarget 治療条件対象詳細
   * @param facilityCd   画面から取得した施設コード
   * @param medicineCd   対象詳細が紐づく薬剤コード（不要な場合はnull)
   * @param medicineType 対象詳細が紐づく薬剤区分（不要な場合はnull)
   * @return 治療条件対象の値
   */
  private String gettingValue(String targetKey, JSONObject objectTarget, String facilityCd, Object medicineCd, Object medicineType) {
    //治療条件対象の値
    String editValue = null;
    //治療条件対象詳細に格納されているvalue値(マスタが存在する場合はコード、無い場合は編集後の値)
    String targetValue =
      Objects.equals(objectTarget.opt("value"), null)
        ? null
        : objectTarget.opt("value").toString();
    //投与薬剤区分取得用
    String targetClass =
      Objects.equals(objectTarget.opt("medicine_type"), null)
        ? null
        : objectTarget.opt("medicine_type").toString();

    //治療条件対象の項目番号に応じて名称に変換
    switch (targetKey) {
      //治療時間の場合
      case "1":
        //値が設定されている場合は分形式→HH:mm形式に変更
        if (! Objects.isNull(targetValue)) {
          //HHを取得
          int hour = Integer.parseInt(targetValue) / 60;
          String strHour = String.format("%02d", hour);
          //mmを取得(分が一桁の場合はゼロパディング)
          int minutes = Integer.parseInt(targetValue) % 60;
          String strMinutes = String.format("%02d", minutes);

          //HH:mm形式に変換して格納
          editValue = strHour + ":" + strMinutes;
        }
        break;
      //VAの場合
      case "2":
        editValue = this.changeVA(targetValue, facilityCd);
        break;

      //目標体重の場合
      case "3":
        if (! Objects.isNull(targetValue))
          editValue =
            targetValue.equals("-1") ? "DWと同じ" : targetValue;
        break;

      // 降水量制限、補液速度の場合(固定小数点2桁)
      case "4":
      case "24":
        // add #9914 補液計算優先項目を「濾過率から算出」に設定した時の補液速度と補液量の表示が不正 dengshen start
        if ("24".equals(targetKey) && "-1".equals(targetValue)){
          editValue = "濾過率から算出";
          break;
        }
        // add #9914 補液計算優先項目を「濾過率から算出」に設定した時の補液速度と補液量の表示が不正 dengshen end
        editValue = this.changeMedicineValue(targetValue, 2);
        break;

      // 透析液温度、補液量、補液温度、IPワンショット、IP速度（固定小数点1桁）
      case "18":
      case "20":
      case "23":
      case "32":
      case "33":
        // add #9914 補液計算優先項目を「濾過率から算出」に設定した時の補液速度と補液量の表示が不正 dengshen start
        if ("20".equals(targetKey) && "-1".equals(targetValue)){
          editValue = "濾過率から算出";
          break;
        }
        // add #9914 補液計算優先項目を「濾過率から算出」に設定した時の補液速度と補液量の表示が不正 dengshen end
        editValue = this.changeMedicineValue(targetValue, 1);
        break;

      //ダイアライザの場合
      case "5":
        editValue = this.changeDialyzer(targetValue, facilityCd);
        break;

      //医療材料分類に該当する治療条件対象の場合
      case "6":
      case "7":
      case "8":
      case "9":
      case "10":
      case "11":
      case "13":
        editValue = this.changeEquipment(targetValue, facilityCd);
        break;

      //薬剤分類に該当する治療条件対象の場合
      case "15":
      case "19":
      case "25":
        editValue = this.changeMedicine(targetValue, targetClass, facilityCd);
        break;

      //薬剤分類に該当する治療条件対象の場合
      case "17":
      case "22":
        // レセ単位小数点桁数
        editValue = this.changeMedicineValue(targetValue, medicineCd, medicineType, facilityCd, "0");
        break;

      case "26":
      case "27":
      case "28":
        //指示単位小数点桁数
        editValue = this.changeMedicineValue(targetValue, medicineCd, medicineType, facilityCd, "1");
        break;

      //ラジオボタンで選択する項目の場合(シングルニードル使用、IP使用選択、自動ワンショット)
      case "12":
      case "29":
      case "34":
        if (! Objects.isNull(targetValue))
          editValue =
            targetValue.equals("1") ? "使用する" : "使用しない";
        break;
      //ラジオボタンで選択する項目の場合(補液選択)
      case "21":
        if (! Objects.isNull(targetValue))
          editValue =
            targetValue.equals("1") ? "前補液" : "後補液";
        break;
      //ラジオボタンで選択する項目の場合(IPスタート)
      case "30":
        if (! Objects.isNull(targetValue))
          editValue =
            targetValue.equals("0") ? "手動" : "自動";
        break;
      //ラジオボタンで選択する項目の場合(IP電源自動切り、IP電源OKモニタ切り)
      case "35":
      case "37":
        if (! Objects.isNull(targetValue))
          editValue =
            targetValue.equals("0") ? "切" : "入";
        break;

      //その他の治療条件対象の項目番号の場合
      default:
        editValue = targetValue;
        break;
    }
    //値が設定されていない場合は"未登録"と設定
    editValue = Objects.isNull(editValue) || editValue.isEmpty() ? "未登録" : editValue;
    return editValue;
  }

  /**
   * 医療材料コードから医療材料名称に変換する処理
   *
   * @param equipmentCd 画面から取得した医療材料コード
   * @param facilityCd  画面から取得した施設コード
   * @return 医療材料コードに対応する医療材料名称
   */
  private String changeEquipment(String equipmentCd, String facilityCd) {
    //医療材料コードに対応する医療材料名(画面表示のため、nullではなく空文字で初期化)
    String equipmentName = "";
    //医療材料コードの比較のため、nullの場合は空文字に変換
    String checkedEquipmentCd = Objects.isNull(equipmentCd) ? "" : equipmentCd;

    //マスタ取得用パラメータに施設コードを設定
    MstEquipment mstEquipment = new MstEquipment();
    mstEquipment.setFacilityCd(facilityCd);
    //マスタ取得処理
    SelectOptions selectOptions = SelectOptions.get();
    List<MstEquipment> mstEquipmentList = mstEquipmentDao.selectAll(selectOptions, mstEquipment);

    //医療材料コードに対応する医療材料名称を取得
    for (int i = 0; i < mstEquipmentList.size(); i++) {
      //医療材料コードを数値→文字列に変換
      String mstEquipmentCd = String.valueOf(mstEquipmentList.get(i).getEquipmentCd());
      //マスタ医療材料コードと比較し、医療材料コードに対応する医療材料名称を取得
      if (checkedEquipmentCd.equals(mstEquipmentCd)) {
        equipmentName = mstEquipmentList.get(i).getEquipmentName();
      }
    }
    return equipmentName;
  }

  /**
   * VAコードからVA名称に変換する処理
   *
   * @param vaCd       画面から取得したVAコード
   * @param facilityCd 画面から取得した施設コード
   * @return VAコードに対応するVA名称
   */
  private String changeVA(String vaCd, String facilityCd) {
    //VAコードに対応するVA名
    String vaName = "";
    //VAコードの比較のため、nullの場合は空文字に変換
    String checkedVaCd = Objects.isNull(vaCd) ? "" : vaCd;

    //マスタ取得用パラメータに施設コードを設定
    MstVa mstVa = new MstVa();
    mstVa.setFacilityCd(facilityCd);
    //マスタ取得処理
    SelectOptions selectOptions = SelectOptions.get();
    List<MstVa> mstVaList = mstVaDao.selectAll(selectOptions, mstVa);

    //VAコードに対応するVA名称を取得
    for (int i = 0; i < mstVaList.size(); i++) {
      //VAコードを数値→文字列に変換
      String mstVaCd = String.valueOf(mstVaList.get(i).getVaCd());
      //マスタVAコードと比較し、VAコードに対応するVA名称を取得
      if (checkedVaCd.equals(mstVaCd)) {
        vaName = mstVaList.get(i).getVaName();
      }
    }
    return vaName;
  }

  /**
   * ダイアライザコードからダイアライザ名称に変換する処理
   *
   * @param dialyzerCd 画面から取得したダイアライザコード
   * @param facilityCd 画面から取得した施設コード
   * @return ダイアライザコードに対応するダイアライザ名称
   */
  private String changeDialyzer(String dialyzerCd, String facilityCd) {
    //ダイアライザコードに対応するダイアライザ名
    String dialyzerName = "";
    //ダイアライザコードの比較のため、nullの場合は空文字に変換
    String checkedDialyzerCd = Objects.isNull(dialyzerCd) ? "" : dialyzerCd;

    //マスタ取得用パラメータに施設コードを設定
    MstDialyzer mstDialyzer = new MstDialyzer();
    mstDialyzer.setFacilityCd(facilityCd);
    //マスタ取得処理
    SelectOptions selectOptions = SelectOptions.get();
    List<MstDialyzer> mstDialyzerList = mstDialyzerDao.selectAll(selectOptions, mstDialyzer);

    //ダイアライザコードに対応するダイアライザ名称を取得
    for (int i = 0; i < mstDialyzerList.size(); i++) {
      //ダイアライザコードを数値→文字列に変換
      String mstDialyzerCd = String.valueOf(mstDialyzerList.get(i).getDialyzerCd());
      //マスタダイアライザコードと比較し、ダイアライザコードに対応するダイアライザ名称を取得
      if (checkedDialyzerCd.equals(mstDialyzerCd)) {
        dialyzerName = mstDialyzerList.get(i).getModelNumber();
      }
    }
    return dialyzerName;
  }

  /**
   * 薬剤数量値に対して薬剤小数点桁数を付加した結果を返却する処理
   *
   * @param targetValue  画面から取得した薬剤数量
   * @param medicineCd   画面から取得した薬剤コード
   * @param medicineType 画面から取得した薬剤区分
   * @param facilityCd   画面から取得した施設コード
   * @param unitType     小数点桁数の分類区分（0:レセ単位/1:指示単位) 薬剤マスタ参照時のみ
   * @return 薬剤数量(小数点桁数制御後)
   */
  private String changeMedicineValue(String targetValue, Object medicineCd, Object medicineType, String facilityCd, String unitType) {

    // 値無し時処理
    if (Objects.isNull(targetValue) || targetValue.equals("")) {
      return "未登録";
    }

    // 薬剤に対応する小数点対応後：薬剤数量
    String medicineValue = targetValue;
    // 薬剤に対応した小数点桁数
    Integer medicineDecPoint = 0;

    //薬剤コードの比較のため、nullの場合は空文字に変換
    String checkedMedicineCd = Objects.isNull(medicineCd) ? "" : medicineCd.toString();
    //薬剤区分の比較のため、nullの場合は空文字に変換
    String checkedMedicineType = Objects.isNull(medicineType) ? "" : medicineType.toString();

    if (checkedMedicineType.equals("1") && Objects.nonNull(medicineCd) && ! (checkedMedicineCd.equals("null"))) {
      // 対象が薬剤マスタの場合
      MstMedicine medicine = mstMedicineDao.selectByCd(facilityCd, Integer.parseInt(checkedMedicineCd));
      if (medicine != null) {
        if (unitType.equals("0")) {
          // レセ単位
          medicineDecPoint = medicine.getUnitDecimalPointSecond();
        } else {
          // 指示単位
          medicineDecPoint = Optional.ofNullable(medicine.getUnitDecimalPoint()).orElse(0);
        }
      }
    } else if (checkedMedicineType.equals("2") && Objects.nonNull(medicineCd) && ! (checkedMedicineCd.equals("null"))) {
      // 調整薬剤の場合
      MstMedicineMix medicineMix = mstMedicineMixDao.selectByCd(facilityCd, Integer.parseInt(checkedMedicineCd));
      if (medicineMix != null) {
        medicineDecPoint = medicineMix.getUnitDecimalPoint();
      }
    }

    //フォーマット設定
    return changeMedicineValue(targetValue, medicineDecPoint);
  }

  /**
   * 投与薬剤コードから投与薬剤名称に変換する処理
   *
   * @param medicineCd   画面から取得した投与薬剤コード
   * @param medicineType 画面から取得した投与薬剤区分
   * @param facilityCd   画面から取得した施設コード
   * @return 投与薬剤コードに対応する投与薬剤名称
   */
  private String changeMedicine(String medicineCd, String medicineType, String facilityCd) {
    //投与薬剤コードに対応する投与薬剤名
    String medicineName = "";
    //投与薬剤コードの比較のため、nullの場合は空文字に変換
    String checkedMedicineCd = Objects.isNull(medicineCd) ? "" : medicineCd;
    //投与薬剤区分の比較のため、nullの場合は空文字に変換
    String checkedMedicineType = Objects.isNull(medicineType) ? "" : medicineType;

    if (checkedMedicineType.equals("1")) {
      //マスタ取得用パラメータに施設コードを設定
      MstMedicine mstMedicine = new MstMedicine();
      mstMedicine.setFacilityCd(facilityCd);
      //マスタ取得処理
      SelectOptions selectOptions = SelectOptions.get();
      List<MstMedicine> mstMedicineList = mstMedicineDao.selectAll(selectOptions, mstMedicine);

      //投与薬剤コードに対応する投与薬剤名称を取得
      for (int i = 0; i < mstMedicineList.size(); i++) {
        //投与薬剤コードを数値→文字列に変換
        String mstMedicineCd = String.valueOf(mstMedicineList.get(i).getMedicineCd());
        //マスタ投与薬剤コードと比較し、投与薬剤コードに対応する投与薬剤名称を取得
        if (checkedMedicineCd.equals(mstMedicineCd)) {
          medicineName = mstMedicineList.get(i).getMedicineName();
        }
      }
    } else if (checkedMedicineType.equals("2")) {
      //マスタ取得用パラメータに施設コードを設定
      MstMedicineMix mstMedicineMix = new MstMedicineMix();
      mstMedicineMix.setFacilityCd(facilityCd);
      //マスタ取得処理
      SelectOptions selectOptions = SelectOptions.get();
      List<MstMedicineMix> mstMedicineMixList = mstMedicineMixDao.selectAll(selectOptions, mstMedicineMix);

      //調製薬剤コードに対応する調製薬剤名称を取得
      for (int i = 0; i < mstMedicineMixList.size(); i++) {
        //調製薬剤コードを数値→文字列に変換
        String mstMedicineMixCd = String.valueOf(mstMedicineMixList.get(i).getMedicineMixCd());
        //マスタ調製薬剤コードと比較し、調製薬剤コードに対応する調製薬剤名称を取得
        if (checkedMedicineCd.equals(mstMedicineMixCd)) {
          medicineName = mstMedicineMixList.get(i).getMedicineMixName();
        }
      }
    }
    return medicineName;
  }

  /**
   * 薬剤数量値に対して薬剤小数点桁数を付加した結果を返却する処理(固定小数点)
   *
   * @param targetValue 画面から取得した薬剤数量
   * @param decPoint    指定された小数点桁数
   * @return 薬剤数量(小数点桁数制御後)
   */
  private String changeMedicineValue(String targetValue, Integer decPoint) {

    // 値無し時処理
    if (Objects.isNull(targetValue) || targetValue.equals("")) {
      return "未登録";
    }
    //フォーマット設定
    DecimalFormat format = new DecimalFormat("#.#");
    format.setRoundingMode(RoundingMode.DOWN);
    // 小数点以下の最小値
    format.setMinimumFractionDigits(decPoint);
    // 小数点以下の最大値
    format.setMaximumFractionDigits(9);
    BigDecimal number = new BigDecimal(targetValue);
    return format.format(number);
  }

  /**
   * 治療方法コードから名称に変換する処理
   *
   * @param targetNum 画面から取得した、治療条件対象の項目番号
   * @return 治療条件対象番号に対応する治療条件名称
   */
  private String gettingEditTarget(String targetNum) {
    //対象項目名称
    String targetName = null;

    switch (targetNum) {
      case "1":
        targetName = "治療時間";
        break;
      case "2":
        targetName = "VA";
        break;
      case "3":
        targetName = "目標体重";
        break;
      case "4":
        targetName = "除水量制限";
        break;
      case "5":
        targetName = "ダイアライザ";
        break;
      case "6":
        targetName = "吸着カラム";
        break;
      case "7":
        targetName = "1次膜";
        break;
      case "8":
        targetName = "2次膜";
        break;
      case "9":
        targetName = "穿刺針(A針)";
        break;
      case "10":
        targetName = "穿刺針(V針)";
        break;
      case "11":
        targetName = "穿刺針(SN)";
        break;
      case "12":
        targetName = "シングルニードル使用";
        break;
      case "13":
        targetName = "血液回路";
        break;
      case "14":
        targetName = "血流量";
        break;
      case "15":
        targetName = "透析液";
        break;
      case "16":
        targetName = "透析液流量";
        break;
      case "17":
        targetName = "透析液使用数";
        break;
      case "18":
        targetName = "透析液温度";
        break;
      case "19":
        targetName = "補液";
        break;
      case "20":
        targetName = "補液量";
        break;
      case "21":
        targetName = "補液選択";
        break;
      case "22":
        targetName = "補液使用数";
        break;
      case "23":
        targetName = "補液温度";
        break;
      case "24":
        targetName = "補液速度";
        break;
      case "25":
        targetName = "抗凝固剤";
        break;
      case "26":
        targetName = "抗凝固剤ワンショット量";
        break;
      case "27":
        targetName = "抗凝固剤持続速度";
        break;
      case "28":
        targetName = "抗凝固剤持続総量";
        break;
      case "29":
        targetName = "IP使用選択";
        break;
      case "30":
        targetName = "IPスタート";
        break;
      case "31":
        targetName = "IPワンショット量";
        break;
      case "32":
        targetName = "IP速度";
        break;
      case "33":
        targetName = "IP速度最大値";
        break;
      case "34":
        targetName = "自動ワンショット";
        break;
      case "35":
        targetName = "IP電源自動切り";
        break;
      case "36":
        targetName = "IP電源自動切り時間";
        break;
      case "37":
        targetName = "IP電源OKモニタ切り";
        break;
      case "38":
        targetName = "IP電源OKモニタ切り時間";
        break;
      case "39":
        targetName = "DW";
        break;
      default:
        targetName = "";
        break;
    }
    return targetName;
  }

  /**
   * 指示履歴に登録する、装置設定内容を作成する処理（画面編集）
   *
   * @param bodyData       画面から取得した装置設定詳細
   * @param ordMain       編集前の値一覧
   * @return 治療条件内容
   */
  public String createDeviceSetInfoContent(ValiDeviceSetInfo bodyData, OrdMain ordMain) {
    //設定する内容
    String paramContent = null;
    //編集を行った対象項目一覧
    List<String> paramContentList = new ArrayList<>();

    if(bodyData != null && bodyData.getInd_device_set_info() != null && StringUtils.hasText(ordMain.getIndDeviceSetInfo())){

      String imagFlg = StringUtils.hasText(bodyData.getImage_flg()) ? bodyData.getImage_flg() : null;
      JSONObject indDeviceSetInfo = new JSONObject(bodyData.getInd_device_set_info());
      //Before modification json
      JSONObject deviceSetInfoJson = getJsonByImageFlag(indDeviceSetInfo,imagFlg);
      //After modification json
      JSONObject oldDeviceSetInfoJson = new JSONObject();
      if(StringUtils.hasText(imagFlg)){
        oldDeviceSetInfoJson =  getJsonByImageFlag(new JSONObject(ordMain.getIndDeviceSetInfo()),imagFlg);
      }
      else {
        List<String> keysList = new ArrayList<>(indDeviceSetInfo.keySet());
        oldDeviceSetInfoJson =  getJSONObject(new JSONObject(ordMain.getIndDeviceSetInfo()), keysList.get(0));
      }
      //編集後の装置設定です
      List<String> newDeviceSetInfoList = new ArrayList<>();
      //編集前の装置設定です
      List<String> oldDeviceSetInfoList = new ArrayList<>();
      if(StringUtils.hasText(imagFlg)){
        switch (imagFlg) {
          case "0":
            this.getNaContent(deviceSetInfoJson,newDeviceSetInfoList);
            this.getNaContent(oldDeviceSetInfoJson,oldDeviceSetInfoList);
            break;
          case "1":
            this.getDcContent(deviceSetInfoJson,newDeviceSetInfoList);
            this.getDcContent(oldDeviceSetInfoJson,oldDeviceSetInfoList);
            break;
          case "2":
            this.getUfrContent(deviceSetInfoJson,newDeviceSetInfoList);
            this.getUfrContent(oldDeviceSetInfoJson,oldDeviceSetInfoList);
            break;
          case "3":
            this.getQbqdContent(deviceSetInfoJson,newDeviceSetInfoList);
            this.getQbqdContent(oldDeviceSetInfoJson,oldDeviceSetInfoList);
            break;
          case "4":
            this.getBvUfcContent(deviceSetInfoJson,newDeviceSetInfoList);
            this.getBvUfcContent(oldDeviceSetInfoJson,oldDeviceSetInfoList);
            break;
          default:
            break;
        }
      }else{
        JSONObject dev = getJSONObject(deviceSetInfoJson,"dev");
        JSONObject aJson = getJSONObject(dev, "A");
        if(aJson != null){
          if(aJson.has("201")){
            this.getIhdfContent(deviceSetInfoJson,newDeviceSetInfoList);
            this.getIhdfContent(oldDeviceSetInfoJson,oldDeviceSetInfoList);
            String resultTile = newDeviceSetInfoList.size() > 0 ? newDeviceSetInfoList.get(0).split(System.getProperty("line.separator"))[0] : "";
            for(int i = 0; i < oldDeviceSetInfoList.size(); i++) {
              String title = oldDeviceSetInfoList.get(i);
              String[] oldTitle = title.split(System.getProperty("line.separator"));
              if(!resultTile.equals(oldTitle[0])){
                title = resultTile + System.getProperty("line.separator") + oldTitle[1];
                oldDeviceSetInfoList.set(i, title);
              }
            }
          }
          if(aJson.has("288")){
            this.getDiaContent(deviceSetInfoJson,newDeviceSetInfoList);
            this.getDiaContent(oldDeviceSetInfoJson,oldDeviceSetInfoList);
          }
        }
      }
      //Splice changing content
      if(oldDeviceSetInfoList.size() > 0 && newDeviceSetInfoList.size() > 0
        && newDeviceSetInfoList.size() == oldDeviceSetInfoList.size()){
        for(int i = 0; i < oldDeviceSetInfoList.size(); i++){
          if(!oldDeviceSetInfoList.get(i).equals(newDeviceSetInfoList.get(i))){
            String resultContent = null;
            String[] parts = newDeviceSetInfoList.get(i).split(":");
            if (parts.length > 1) {
              String[] keyValueParts = parts[1].trim().split("_");
              resultContent = switch (keyValueParts[0]) {
                case "196", "432", "282" -> getSelectString(oldDeviceSetInfoList.get(i),0) + "→" + getSelectString(keyValueParts[1].trim(),1);
                case "290", "315" -> getPowerString(oldDeviceSetInfoList.get(i),0) + "→" + getPowerString(keyValueParts[1].trim(),1);
                case "340" -> get340PowerString(oldDeviceSetInfoList.get(i),0) + "→" + get340PowerString(keyValueParts[1].trim(),1);
                case "327", "368" -> getOFF_ONString(oldDeviceSetInfoList.get(i),0) + "→" + getOFF_ONString(keyValueParts[1].trim(),1);
                case "430", "431" -> getQB_QDString(oldDeviceSetInfoList.get(i),0) + "→" + getQB_QDString(keyValueParts[1].trim(),1);
                case "291", "292", "293", "294", "295", "296", "297", "298", "299", "300" -> getHD_ECUMString(oldDeviceSetInfoList.get(i),0) + "→" + getHD_ECUMString(keyValueParts[1].trim(),1);
                default -> oldDeviceSetInfoList.get(i) + "→" +parts[1].trim();
              };
            }
            paramContentList.add(resultContent);
          }
        }
      }
    }
    //リスト→文字列に変換
    paramContent = paramContentList.size() > 0 ?JSONObject.valueToString(paramContentList): null;
    return paramContent;
  }

  /**
   * bvufc
   * @param bvufc
   * @param resultContentList
   */
  private void getBvUfcContent(JSONObject bvufc,List<String> resultContentList){
    JSONObject bvufcDev = getJSONObject(bvufc, "dev");
    JSONObject bvufcInfo = getJSONObject(bvufcDev, "A");

    if(bvufcInfo != null) {
      resultContentList.add(addResultContent(bvufcInfo, "BV-UFC","196", "BV-UFC使用選択:"));
      resultContentList.add(addResultContent(bvufcInfo,"BV-UFC" ,"197","UFC期間 除水速度上限:"));
      resultContentList.add(addResultContent(bvufcInfo,"BV-UFC", "198","UFC期間 除水速度下限:"));
      resultContentList.add(addResultContent(bvufcInfo,"BV-UFC", "199","開始期間 時間:"));
      resultContentList.add(addResultContent(bvufcInfo,"BV-UFC", "206","開始期間 除水速度倍率:"));
      resultContentList.add(addResultContent(bvufcInfo,"BV-UFC", "207","固定倍率除水期間 時間:"));
      resultContentList.add(addResultContent(bvufcInfo,"BV-UFC", "208","固定倍率除水期間 除水速度倍率:"));
      resultContentList.add(addResultContent(bvufcInfo,"BV-UFC", "209","固定倍率除水終了条件　最高血圧:"));
      resultContentList.add(addResultContent(bvufcInfo,"BV-UFC", "210","固定倍率除水終了条件　脈拍:"));
      resultContentList.add(addResultContent(bvufcInfo,"BV-UFC", "248","固定倍率除水終了条件　ΔBV:"));
      resultContentList.add(addResultContent(bvufcInfo,"BV-UFC", "249","終了前 時間:"));
      resultContentList.add(addResultContent(bvufcInfo,"BV-UFC", "271","開始時ΔBV:"));
      resultContentList.add(addResultContent(bvufcInfo,"BV-UFC", "272","指数1:"));
      resultContentList.add(addResultContent(bvufcInfo,"BV-UFC", "273","指数2:"));
      resultContentList.add(addResultContent(bvufcInfo,"BV-UFC", "274","指数3:"));
      resultContentList.add(addResultContent(bvufcInfo,"BV-UFC", "275","終了時ΔBV:"));
    }
  }

  /**
   * ufr
   * @param ufr
   * @param resultContentList
   */
  private void getUfrContent(JSONObject ufr,List<String> resultContentList){
    JSONObject ufrDev = getJSONObject(ufr,"dev");
    JSONObject ufrInfoA = getJSONObject(ufrDev, "A");
//    JSONObject ufrInfoB = getJSONObject(ufrDev, "B");
    if(ufrInfoA != null){
      resultContentList.add(addResultContent(ufrInfoA,"除水プログラム", "290","電源:"));
      resultContentList.add(addResultContent(ufrInfoA,"除水プログラム", "311","最終工程:"));
      resultContentList.add(addResultContent(ufrInfoA,"除水プログラム", "312","コース:"));
      resultContentList.add(addResultContent(ufrInfoA,"除水プログラム", "291","工程1:"));
      resultContentList.add(addResultContent(ufrInfoA,"除水プログラム", "292","工程2:"));
      resultContentList.add(addResultContent(ufrInfoA,"除水プログラム", "293","工程3:"));
      resultContentList.add(addResultContent(ufrInfoA,"除水プログラム", "294","工程4:"));
      resultContentList.add(addResultContent(ufrInfoA,"除水プログラム", "295","工程5:"));
      resultContentList.add(addResultContent(ufrInfoA,"除水プログラム", "296","工程6:"));
      resultContentList.add(addResultContent(ufrInfoA,"除水プログラム", "297","工程7:"));
      resultContentList.add(addResultContent(ufrInfoA,"除水プログラム", "298","工程8:"));
      resultContentList.add(addResultContent(ufrInfoA,"除水プログラム", "299","工程9:"));
      resultContentList.add(addResultContent(ufrInfoA,"除水プログラム", "300","工程10:"));
      resultContentList.add(addResultContent(ufrInfoA,"除水プログラム", "301","ステップ1:"));
      resultContentList.add(addResultContent(ufrInfoA,"除水プログラム", "302","ステップ2:"));
      resultContentList.add(addResultContent(ufrInfoA,"除水プログラム", "303","ステップ3:"));
      resultContentList.add(addResultContent(ufrInfoA,"除水プログラム", "304","ステップ4:"));
      resultContentList.add(addResultContent(ufrInfoA,"除水プログラム", "305","ステップ5:"));
      resultContentList.add(addResultContent(ufrInfoA,"除水プログラム", "306","ステップ6:"));
      resultContentList.add(addResultContent(ufrInfoA,"除水プログラム", "307","ステップ7:"));
      resultContentList.add(addResultContent(ufrInfoA,"除水プログラム", "308","ステップ8:"));
      resultContentList.add(addResultContent(ufrInfoA,"除水プログラム", "309","ステップ9:"));
      resultContentList.add(addResultContent(ufrInfoA,"除水プログラム", "310","ステップ10:"));
      resultContentList.add(addResultContent(ufrInfoA,"除水プログラム", "313","開始:"));
      resultContentList.add(addResultContent(ufrInfoA,"除水プログラム", "314","終了:"));

    }
  }

  /**
   * dc
   * @param dc
   * @param resultContentList
   */
  private void getDcContent(JSONObject dc,List<String> resultContentList){
    JSONObject dcDev = getJSONObject(dc,"dev");
    JSONObject dcInfoA = getJSONObject(dcDev, "A");
    if(dcInfoA != null){
      resultContentList.add(addResultContent(dcInfoA,"透析液濃度プログラム", "340","電源:"));
      resultContentList.add(addResultContent(dcInfoA,"透析液濃度プログラム", "368","UFRプロとの連動:"));
      resultContentList.add(addResultContent(dcInfoA,"透析液濃度プログラム", "367","工程切替時間:"));
      resultContentList.add(addResultContent(dcInfoA,"透析液濃度プログラム", "361","透析液濃度 コース:"));
      resultContentList.add(addResultContent(dcInfoA,"透析液濃度プログラム", "341","透析液濃度ステップ1:"));
      resultContentList.add(addResultContent(dcInfoA,"透析液濃度プログラム", "342","透析液濃度ステップ2:"));
      resultContentList.add(addResultContent(dcInfoA,"透析液濃度プログラム", "343","透析液濃度ステップ3:"));
      resultContentList.add(addResultContent(dcInfoA,"透析液濃度プログラム", "344","透析液濃度ステップ4:"));
      resultContentList.add(addResultContent(dcInfoA,"透析液濃度プログラム", "345","透析液濃度ステップ5:"));
      resultContentList.add(addResultContent(dcInfoA,"透析液濃度プログラム", "346","透析液濃度ステップ6:"));
      resultContentList.add(addResultContent(dcInfoA,"透析液濃度プログラム", "347","透析液濃度ステップ7:"));
      resultContentList.add(addResultContent(dcInfoA,"透析液濃度プログラム", "348","透析液濃度ステップ8:"));
      resultContentList.add(addResultContent(dcInfoA,"透析液濃度プログラム", "349","透析液濃度ステップ9:"));
      resultContentList.add(addResultContent(dcInfoA,"透析液濃度プログラム", "350","透析液濃度ステップ10:"));
      resultContentList.add(addResultContent(dcInfoA,"透析液濃度プログラム", "362","透析液濃度 開始:"));
      resultContentList.add(addResultContent(dcInfoA,"透析液濃度プログラム", "363","透析液濃度 終了:"));
      resultContentList.add(addResultContent(dcInfoA,"透析液濃度プログラム", "364","B液濃度 コース:"));
      resultContentList.add(addResultContent(dcInfoA,"透析液濃度プログラム", "351","B液濃度ステップ1:"));
      resultContentList.add(addResultContent(dcInfoA,"透析液濃度プログラム", "352","B液濃度ステップ2:"));
      resultContentList.add(addResultContent(dcInfoA,"透析液濃度プログラム", "353","B液濃度ステップ3:"));
      resultContentList.add(addResultContent(dcInfoA,"透析液濃度プログラム", "354","B液濃度ステップ4:"));
      resultContentList.add(addResultContent(dcInfoA,"透析液濃度プログラム", "355","B液濃度ステップ5:"));
      resultContentList.add(addResultContent(dcInfoA,"透析液濃度プログラム", "356","B液濃度ステップ6:"));
      resultContentList.add(addResultContent(dcInfoA,"透析液濃度プログラム", "357","B液濃度ステップ7:"));
      resultContentList.add(addResultContent(dcInfoA,"透析液濃度プログラム", "358","B液濃度ステップ8:"));
      resultContentList.add(addResultContent(dcInfoA,"透析液濃度プログラム", "359","B液濃度ステップ9:"));
      resultContentList.add(addResultContent(dcInfoA,"透析液濃度プログラム", "360","B液濃度ステップ10:"));
      resultContentList.add(addResultContent(dcInfoA,"透析液濃度プログラム", "365","B液濃度 開始:"));
      resultContentList.add(addResultContent(dcInfoA,"透析液濃度プログラム", "366","B液濃度 終了:"));
    }

  }

  /**
   * na
   * @param na
   * @param resultContentList
   */
  private void getNaContent(JSONObject na,List<String> resultContentList){
    JSONObject naDev = getJSONObject(na,"dev");
    JSONObject naA = getJSONObject(naDev, "A");
    if(naA != null){
      resultContentList.add(addResultContent(naA,"Na注入プログラム", "315","電源:"));
      resultContentList.add(addResultContent(naA,"Na注入プログラム", "326","工程切替時間:"));
      resultContentList.add(addResultContent(naA,"Na注入プログラム", "328","コース:"));
      resultContentList.add(addResultContent(naA,"Na注入プログラム", "327","ＵＦＲプロ連動:"));
      resultContentList.add(addResultContent(naA,"Na注入プログラム", "316","ステップ1:"));
      resultContentList.add(addResultContent(naA,"Na注入プログラム", "317","ステップ2:"));
      resultContentList.add(addResultContent(naA,"Na注入プログラム", "318","ステップ3:"));
      resultContentList.add(addResultContent(naA,"Na注入プログラム", "319","ステップ4:"));
      resultContentList.add(addResultContent(naA,"Na注入プログラム", "320","ステップ5:"));
      resultContentList.add(addResultContent(naA,"Na注入プログラム", "321","ステップ6:"));
      resultContentList.add(addResultContent(naA,"Na注入プログラム", "322","ステップ7:"));
      resultContentList.add(addResultContent(naA,"Na注入プログラム", "323","ステップ8:"));
      resultContentList.add(addResultContent(naA,"Na注入プログラム", "324","ステップ9:"));
      resultContentList.add(addResultContent(naA,"Na注入プログラム", "325","ステップ10:"));
      resultContentList.add(addResultContent(naA,"Na注入プログラム", "329","開始:"));
      resultContentList.add(addResultContent(naA,"Na注入プログラム", "330","終了:"));
      resultContentList.add(addResultContent(naA,"Na注入プログラム", "184","Na注入濃度最大値:"));

    }
  }

  /**
   * qbqd
   * @param qbqd
   * @param resultContentList
   */
  private void getQbqdContent(JSONObject qbqd,List<String> resultContentList){
    JSONObject qbqdDev = getJSONObject(qbqd,"dev");
    JSONObject qbqdA = getJSONObject(qbqdDev, "A");

    if(qbqdA != null){
      resultContentList.add(addResultContent(qbqdA,"QB・QDプログラム", "430","QBプログラム 電源:"));
      resultContentList.add(addResultContent(qbqdA,"QB・QDプログラム", "429","ステップ数:"));
      resultContentList.add(addResultContent(qbqdA,"QB・QDプログラム", "400","血流量1:"));
      resultContentList.add(addResultContent(qbqdA,"QB・QDプログラム", "401","血流量2:"));
      resultContentList.add(addResultContent(qbqdA,"QB・QDプログラム", "402","血流量3:"));
      resultContentList.add(addResultContent(qbqdA,"QB・QDプログラム", "403","血流量4:"));
      resultContentList.add(addResultContent(qbqdA,"QB・QDプログラム", "404","血流量5:"));
      resultContentList.add(addResultContent(qbqdA,"QB・QDプログラム", "405","血流量6:"));
      resultContentList.add(addResultContent(qbqdA,"QB・QDプログラム", "406","血流量7:"));
      resultContentList.add(addResultContent(qbqdA,"QB・QDプログラム", "407","血流量8:"));
      resultContentList.add(addResultContent(qbqdA,"QB・QDプログラム", "408","血流量9:"));
      resultContentList.add(addResultContent(qbqdA,"QB・QDプログラム", "409","血流量10:"));
      resultContentList.add(addResultContent(qbqdA,"QB・QDプログラム", "431","QDプログラム 電源:"));
      resultContentList.add(addResultContent(qbqdA,"QB・QDプログラム", "410","透析液流量1:"));
      resultContentList.add(addResultContent(qbqdA,"QB・QDプログラム", "411","透析液流量2:"));
      resultContentList.add(addResultContent(qbqdA,"QB・QDプログラム", "412","透析液流量3:"));
      resultContentList.add(addResultContent(qbqdA,"QB・QDプログラム", "413","透析液流量4:"));
      resultContentList.add(addResultContent(qbqdA,"QB・QDプログラム", "414","透析液流量5:"));
      resultContentList.add(addResultContent(qbqdA,"QB・QDプログラム", "415","透析液流量6:"));
      resultContentList.add(addResultContent(qbqdA,"QB・QDプログラム", "416","透析液流量7:"));
      resultContentList.add(addResultContent(qbqdA,"QB・QDプログラム", "417","透析液流量8:"));
      resultContentList.add(addResultContent(qbqdA,"QB・QDプログラム", "418","透析液流量9:"));
      resultContentList.add(addResultContent(qbqdA,"QB・QDプログラム", "419","透析液流量10:"));
      resultContentList.add(addResultContent(qbqdA,"QB・QDプログラム", "420","切替時間1:"));
      resultContentList.add(addResultContent(qbqdA,"QB・QDプログラム", "421","切替時間2:"));
      resultContentList.add(addResultContent(qbqdA,"QB・QDプログラム", "422","切替時間3:"));
      resultContentList.add(addResultContent(qbqdA,"QB・QDプログラム", "423","切替時間4:"));
      resultContentList.add(addResultContent(qbqdA,"QB・QDプログラム", "424","切替時間5:"));
      resultContentList.add(addResultContent(qbqdA,"QB・QDプログラム", "425","切替時間6:"));
      resultContentList.add(addResultContent(qbqdA,"QB・QDプログラム", "426","切替時間7:"));
      resultContentList.add(addResultContent(qbqdA,"QB・QDプログラム", "427","切替時間8:"));
      resultContentList.add(addResultContent(qbqdA,"QB・QDプログラム", "428","切替時間9:"));
    }

  }

  /**
   * ihdf
   * @param ihdf
   * @param resultContentList
   */
  private void getIhdfContent(JSONObject ihdf,List<String> resultContentList){
    JSONObject ihdfDev = getJSONObject(ihdf,"dev");
    JSONObject ihdfA = getJSONObject(ihdfDev, "A");
    if(ihdfA != null){
      resultContentList.add(addResultContent(ihdfA,"I-HDF", "201","補液速度:"));
      resultContentList.add(addResultContent(ihdfA,"I-HDF", "203","補液開始時間:"));
      resultContentList.add(addResultContent(ihdfA,"I-HDF", "200","補液量設定:"));
      resultContentList.add(addResultContent(ihdfA,"I-HDF", "204","除水再開時間:"));
      resultContentList.add(addResultContent(ihdfA,"I-HDF", "202","補液周期:"));
      resultContentList.add(addResultContent(ihdfA,"I-HDF", "205","総補液量上限:"));
      resultContentList.add(addResultContent(ihdfA,"I-HDF", "432","I-HDFプログラム使用選択:"));
      resultContentList.add(addResultContent(ihdfA,"I-HDF", "433","予定補液回数:"));
      resultContentList.add(addResultContent(ihdfA,"I-HDF", "434","補液バランス制限:"));
      resultContentList.add(addResultContent(ihdfA,"I-HDF", "435","補液量1:"));
      resultContentList.add(addResultContent(ihdfA,"I-HDF", "436","補液量2:"));
      resultContentList.add(addResultContent(ihdfA,"I-HDF", "437","補液量3:"));
      resultContentList.add(addResultContent(ihdfA,"I-HDF", "438","補液量4:"));
      resultContentList.add(addResultContent(ihdfA,"I-HDF", "439","補液量5:"));
      resultContentList.add(addResultContent(ihdfA,"I-HDF", "440","補液量6:"));
      resultContentList.add(addResultContent(ihdfA,"I-HDF", "441","補液量7:"));
      resultContentList.add(addResultContent(ihdfA,"I-HDF", "442","補液量8:"));
      resultContentList.add(addResultContent(ihdfA,"I-HDF", "443","補液量9:"));
      resultContentList.add(addResultContent(ihdfA,"I-HDF", "444","補液量10:"));
      resultContentList.add(addResultContent(ihdfA,"I-HDF", "445","補液量11:"));
      resultContentList.add(addResultContent(ihdfA,"I-HDF", "446","補液量12:"));
      resultContentList.add(addResultContent(ihdfA,"I-HDF", "447","補液量13:"));
      resultContentList.add(addResultContent(ihdfA,"I-HDF", "448","補液量14:"));
      resultContentList.add(addResultContent(ihdfA,"I-HDF", "449","補液量15:"));
      resultContentList.add(addResultContent(ihdfA,"I-HDF", "450","補液量16:"));
      resultContentList.add(addResultContent(ihdfA,"I-HDF", "451","回収量1:"));
      resultContentList.add(addResultContent(ihdfA,"I-HDF", "452","回収量2:"));
      resultContentList.add(addResultContent(ihdfA,"I-HDF", "453","回収量3:"));
      resultContentList.add(addResultContent(ihdfA,"I-HDF", "454","回収量4:"));
      resultContentList.add(addResultContent(ihdfA,"I-HDF", "455","回収量5:"));
      resultContentList.add(addResultContent(ihdfA,"I-HDF", "456","回収量6:"));
      resultContentList.add(addResultContent(ihdfA,"I-HDF", "457","回収量7:"));
      resultContentList.add(addResultContent(ihdfA,"I-HDF", "458","回収量8:"));
      resultContentList.add(addResultContent(ihdfA,"I-HDF", "459","回収量9:"));
      resultContentList.add(addResultContent(ihdfA,"I-HDF", "460","回収量10:"));
      resultContentList.add(addResultContent(ihdfA,"I-HDF", "461","回収量11:"));
      resultContentList.add(addResultContent(ihdfA,"I-HDF", "462","回収量12:"));
      resultContentList.add(addResultContent(ihdfA,"I-HDF", "463","回収量13:"));
      resultContentList.add(addResultContent(ihdfA,"I-HDF", "464","回収量14:"));
      resultContentList.add(addResultContent(ihdfA,"I-HDF", "465","回収量15:"));
      resultContentList.add(addResultContent(ihdfA,"I-HDF", "466","回収量16:"));
    }

  }

  /**
   * dia
   * @param dia
   * @param resultContentList
   */
  private void getDiaContent(JSONObject dia,List<String> resultContentList){
    JSONObject diaDev = getJSONObject(dia,"dev");
    JSONObject diaA = getJSONObject(diaDev, "A");
    if(diaA != null){
      resultContentList.add(addResultContent(diaA,"透析量プログラム", "282","透析量プログラム使用選択:"));
      resultContentList.add(addResultContent(diaA,"透析量プログラム", "288","目標Kt/V:"));
    }
  }


  private List<String> creatDeviceSetInfoContent(String jsonString){
    List<String> resultContentList = new ArrayList<>();
    JSONObject indDeviceSetInfoDefault = new JSONObject(jsonString);
    // BV-UFC
    JSONObject bvufc = getJSONObject(indDeviceSetInfoDefault, "bvufc");
    this.getBvUfcContent(bvufc,resultContentList);

    // 除水プログラム
    JSONObject ufr = getJSONObject(indDeviceSetInfoDefault, "ufr");
    this.getUfrContent(ufr,resultContentList);

    // 透析液濃度プログラム
    JSONObject dc = getJSONObject(indDeviceSetInfoDefault, "dc");
    this.getDcContent(dc,resultContentList);

    // Ｎａ注入プログラム
    JSONObject na = getJSONObject(indDeviceSetInfoDefault, "na");
    this.getNaContent(na,resultContentList);

    // 血流量・透析液流量プログラム
    JSONObject qbqd = getJSONObject(indDeviceSetInfoDefault, "qbqd");
    this.getQbqdContent(qbqd,resultContentList);
    // ihdf
    JSONObject ihdf = getJSONObject(indDeviceSetInfoDefault, "ihdf");
    this.getIhdfContent(ihdf,resultContentList);
    // dia
    JSONObject dia = getJSONObject(indDeviceSetInfoDefault, "dia");
    this.getDiaContent(dia,resultContentList);
    resultContentList.removeIf(item -> !StringUtils.hasText(item));

    List<String> convertResultContentList = new ArrayList<>();
    if(resultContentList.size() > 0){
      resultContentList.forEach(item -> {
        String[] parts = item.split(":");
        if (parts.length > 1) {
          String[] keyValueParts = parts[1].trim().split("_");
          if(keyValueParts.length > 1){
            item = switch (keyValueParts[0]) {
              case "196", "432", "282" -> parts[0] + ":" + getSelectString(keyValueParts[1].trim(),1);
              case "290", "315" -> parts[0] + ":" + getPowerString(keyValueParts[1].trim(),1);
              case "340" -> parts[0] + ":" + get340PowerString(keyValueParts[1].trim(),1);
              case "327", "368" -> parts[0] + ":" + getOFF_ONString(keyValueParts[1].trim(),1);
              case "430", "431" -> parts[0] + ":" + getQB_QDString(keyValueParts[1].trim(),1);
              case "291", "292", "293", "294", "295", "296", "297", "298", "299", "300" -> parts[0] + ":" + getHD_ECUMString(keyValueParts[1].trim(),1);
              default -> "";
            };
          }
          if(StringUtils.hasText(item)){
            convertResultContentList.add(item);
          }
        }
      });
    }
    return  convertResultContentList;
  }

  private JSONObject getJSONObject(JSONObject obj, String key) throws JSONException {
    return obj != null && obj.has(key) ? new JSONObject(obj.get(key).toString()) : null;
  }

  private String addResultContent(JSONObject obj, String title, String key, String message) throws JSONException {
    String resultContent = null;
    //改行のための変数を取得
    String br = System.getProperty("line.separator");
    if (obj != null && obj.has(key)) {
      resultContent = switch (key) {
        case "196", "432", "282","290", "315","340","327", "368","430", "431","291", "292",
          "293", "294", "295", "296", "297", "298", "299", "300" -> title + br + message + key + "_" + obj.get(key).toString();
        case "197","198" -> title + br + message + this.convertBigDecimal(obj.get(key).toString(),2) + "L/h";
        case "199","207","249","326","420","421","422","423","424","425","426","427","428","467" -> title + br + message + obj.get(key).toString() + "分";
        case "433" -> title + br + message + obj.get(key).toString() + "回";
        case "468" -> title + br + message + obj.get(key).toString() + "秒";
        case "400","401","402","403","404","405","406","407","408","409","410",
          "411","412","413","414","415","416","417","418","419","201" -> title + br + message + obj.get(key).toString() + "mL/min";
        case "184","316","317","318","319","320","321","322","323","324","325","329","330" -> title + br + message + obj.get(key).toString() + "mEq/L";
        case "209" -> title + br + message + obj.get(key).toString() + "mmHg";
        case "210" -> title + br + message + obj.get(key).toString() + "bpm";
        case "248" -> title + br + message + obj.get(key).toString() + "%";
        case "271","275" -> title + br + message + this.convertBigDecimal(obj.get(key).toString(),1) + "%";
        case "434","200","435","436","437","438","439","440","441","442","443","444",
          "445","446","447","448","449","450","451","452","453","454","455","456","457",
          "458","459","460","461","462","463","464","465","466" -> title + br + message + obj.get(key).toString() + "mL";
        case "203","204","202" -> title + br + message + obj.get(key).toString() + "min";
        case "205" -> title + br + message + this.convertBigDecimal(obj.get(key).toString(),2) + "L";
        case "328","312","364","361","341","342","343","344","345","346","347","348","349",
          "350","362","363" -> title + br + message + this.convertBigDecimal(obj.get(key).toString(),1) ;
        case "206","208","351","352","353","354","355","356","357","358","359",
          "360","365","366","288" -> title + br + message + this.convertBigDecimal(obj.get(key).toString(),2);
        default -> title + br + message + obj.get(key).toString();
      };
    }
    return resultContent;
  }

  /**
   * string Convert BigDecimal
   * @param bigDecimalStr
   * @param digit
   * @return
   */
  private String convertBigDecimal(String bigDecimalStr,int digit){
    if(StringUtils.hasText(bigDecimalStr)){
      return new BigDecimal(bigDecimalStr).setScale(digit, RoundingMode.HALF_UP).toString();
    }
    else{
      return "";
    }
  }

  /**
   * 使用しない : 0
   * 使用する :1
   * @param param
   * @return
   */
  private String getSelectString(String param,int flag){

    String resultString = "";
    if(flag == 0){
      String[] parts = param.split(":");
      if (parts.length > 1) {
        String[] keyValueParts = parts[1].trim().split("_");
        if("0".equals(keyValueParts[1])){
          resultString += parts[0] + ":" + "使用しない";
        }
        else {
          resultString += parts[0] + ":" + "使用する";
        }
      }
    }else {
      if("0".equals(param)){
        resultString += "使用しない";
      }
      else {
        resultString += "使用する";
      }
    }
    return resultString;

  }

  /**
   * 0 : 切り
   * 1 : 入り[ステップ]
   * 2 : 入り[コース]
   * @param param
   * @return
   */
  private String getPowerString(String param,int flag){
    String resultString = "";
    if(flag == 0){
      String[] parts = param.split(":");
      if (parts.length > 1) {
        String[] keyValueParts = parts[1].trim().split("_");
        if("0".equals(keyValueParts[1])){
          resultString += parts[0] + ":" + "切り";
        }
        else if("1".equals(keyValueParts[1])){
          resultString += parts[0] + ":" + "入り[ステップ]";
        }
        else {
          resultString += parts[0] + ":" + "入り[コース]";
        }
      }
    }else {
      if("0".equals(param)){
        resultString += "切り";
      }
      else if("1".equals(param)){
        resultString +=  "入り[ステップ]";
      }
      else {
        resultString += "入り[コース]";
      }
    }
    return resultString;
  }

  /**
   * 0 : 切り
   * 2 : 入り[ステップ]
   * 3 : 入り[コース]
   * @param param
   * @return
   */
  private String get340PowerString(String param,int flag){

    String resultString = "";
    if(flag == 0){
      String[] parts = param.split(":");
      if (parts.length > 1) {
        String[] keyValueParts = parts[1].trim().split("_");
        if("0".equals(keyValueParts[1])){
          resultString += parts[0] + ":" + "切り";
        }
        else if("2".equals(keyValueParts[1])){
          resultString += parts[0] + ":" + "入り[ステップ]";
        }
        else {
          resultString += parts[0] + ":" + "入り[コース]";
        }
      }
    }else {
      if("0".equals(param)){
        resultString += "切り";
      }
      else if("2".equals(param)){
        resultString +=  "入り[ステップ]";
      }
      else {
        resultString += "入り[コース]";
      }
    }
    return resultString;

  }

  /**
   *0： OFF   1： ON
   * @param param
   * @return
   */
  private String getOFF_ONString(String param,int flag){
    String resultString = "";
    if(flag == 0){
      String[] parts = param.split(":");
      if (parts.length > 1) {
        String[] keyValueParts = parts[1].trim().split("_");
        if("0".equals(keyValueParts[1])){
          resultString += parts[0] + ":" + "OFF";
        }
        else {
          resultString += parts[0] + ":" + "ON";
        }
      }
    }else {
      if("0".equals(param)){
        resultString += "OFF";
      }
      else {
        resultString += "ON";
      }
    }
    return resultString;

  }

  /**
   *切 ：0    入 ：1
   * @param param
   * @return
   */
  private String getQB_QDString(String param,int flag){
    String resultString = "";
    if(flag == 0){
      String[] parts = param.split(":");
      if (parts.length > 1) {
        String[] keyValueParts = parts[1].trim().split("_");
        if("0".equals(keyValueParts[1])){
          resultString += parts[0] + ":" + "切";
        }
        else {
          resultString += parts[0] + ":" + "入";
        }
      }
    }else {
      if("0".equals(param)){
        resultString += "切";
      }
      else {
        resultString += "入";
      }
    }
    return resultString;
  }

  /**
   *切 ：HD    入 ：ECUM
   * @param param
   * @return
   */
  private String getHD_ECUMString(String param,int flag){
    String resultString = "";
    if(flag == 0){
      String[] parts = param.split(":");
      if (parts.length > 1) {
        String[] keyValueParts = parts[1].trim().split("_");
        if("0".equals(keyValueParts[1])){
          resultString += parts[0] + ":" + "HD";
        }
        else {
          resultString += parts[0] + ":" + "ECUM";
        }
      }
    }else {
      if("0".equals(param)){
        resultString += "HD";
      }
      else {
        resultString += "ECUM";
      }
    }
    return resultString;
  }

  private JSONObject getJsonByImageFlag(JSONObject bodyData,String imagFlg){
    JSONObject resultObject = new JSONObject();
    String paramFlg = imagFlg;
    if(StringUtils.hasText(paramFlg)){
      switch (paramFlg) {
        case "0":
          resultObject = getJSONObject(bodyData, "na");
          break;
        case "1":
          resultObject = getJSONObject(bodyData, "dc");
          break;
        case "2":
          resultObject = getJSONObject(bodyData, "ufr");
          break;
        case "3":
          resultObject = getJSONObject(bodyData, "qbqd");
          break;
        case "4":
          resultObject = getJSONObject(bodyData, "bvufc");
          break;
        default:
          break;
      }
    }else {
      if(bodyData.has("ihdf")){
        resultObject = getJSONObject(bodyData, "ihdf");
      }
      if(bodyData.has("dia")){
        resultObject = getJSONObject(bodyData, "dia");
      }
    }
    return resultObject;
  }

  /**
   * 指示履歴に登録する、指示コメント内容を作成する処理
   *
   * @param flag       判別フラグ(1.新規、2.変更,3.削除)
   * @param contentNum 指示コメント番号
   * @param indContent 指示コメント内容
   * @param oldIndContents 更新前指示コメント内容
   * @return 指示コメント内容
   */
  // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm start
//  public String createCommentContent(String flag, String contentNum, String indContent) {
  public String createCommentContent(String flag, String contentNum, String indContent, List<String> oldIndContents) {
    // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm end
    //設定する内容
    String paramContent = null;
    //改行のための変数を取得
    String br = System.getProperty("line.separator");

    //指示コメント内容の記載が無い場合、"未登録"と記載(新規と変更・中止の場合で、nullの際のコメントを変更しておく)
    String content = Objects.isNull(indContent) ? "未登録" : indContent;
    content = Objects.equals(content, null) ? "" : content;

    //設定する内容を作成
    if (flag.equals("3")) {
      // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm start
//      paramContent = "指示コメント" + contentNum + "→中止";
      paramContent = "指示コメント" + contentNum + "→中止" + br + String.join(",", oldIndContents);
    } else if ("2".equals(flag)) {
      paramContent = "コメント番号" + contentNum + br + String.join(",", oldIndContents) + "→" + content;
      // mod 11555 指示履歴への記録の残り方が仕様と異なる zkm end
    } else {
      paramContent = "コメント番号" + contentNum + br + content;
    }
    return paramContent;
  }

  /**
   * Mapからkey一覧を返す処理
   *
   * @param keyMap
   * @return key一覧
   */
  private List<String> gettingKeylist(Map<String, String> keyMap) {
    //登録する項目のキー名を取得
    Set<String> keysSet = keyMap.keySet();
    //キー名をリスト形式で保持
    List<String> keysList = new ArrayList<String>(keysSet);
    return keysList;
  }

  /**
   * 投与間隔の番号から投与間隔の名称に変換する処理
   *
   * @param intervalNum 投与間隔の番号
   * @return 投与間隔の名称
   */
  private String changeInterval(String intervalNum) {
    //投与間隔の名称
    String intervalName = "未登録";

    if (!Objects.isNull(intervalNum)) {
      //投与間隔の番号から投与間隔の名称に変換
      switch (intervalNum) {
        case "0":
          intervalName = "毎回";
          break;
        case "1":
          intervalName = "毎週";
          break;
        case "2":
          intervalName = "1回／2週";
          break;
        case "3":
          intervalName = "1回／3週";
          break;
        case "4":
          intervalName = "1回／4週";
          break;
        case "5":
          intervalName = "1回／月：第1曜日";
          break;
        case "6":
          intervalName = "1回／月：第2曜日";
          break;
        case "7":
          intervalName = "1回／月：第3曜日";
          break;
        case "8":
          intervalName = "1回／月：第4曜日";
          break;
        case "9":
          intervalName = "1回／月：最終曜日";
          break;
        default:
          intervalName = "1回／月：最終治療日";
          break;
      }
    }
    return intervalName;
  }

  /**
   * JSon文字列をマップ型リストに変換する処理
   *
   * @param strJson JSon文字列
   * @return 変換したマップ型リスト
   */
  private List<Map<String, String>> changeListMap(String strJson) {
    //変換したマップ型リスト
    List<Map<String, String>> changedList = new ArrayList<>();
    if(ObjectUtils.isEmpty(strJson)) {
      return changedList;
    }
    //変換処理
    ObjectMapper mapper = new ObjectMapper();
    TypeReference<List<Map<String, String>>> type = new TypeReference<List<Map<String, String>>>() {
    };
    try {
      changedList = mapper.readValue(strJson, type);
    } catch (IOException e) {
      System.err.println(e.getMessage());
    }
    return changedList;
  }

  /***
   * JSON配列データから値を取得し、Integer配列データを返す
   * @param stringList
   * @return
   */
  private List<Integer> getValueList(String stringList) {
    JSONArray json;

    List<Integer> valueArry = new ArrayList<Integer>();

    if (null == stringList)
      return valueArry;

    json = new JSONArray(stringList);
    // 選択された値を配列に格納
    for (int i = 0; i < json.length(); i++) {
      valueArry.add((int) (json.get(i)));
    }
    return valueArry;
  }

  /***
   * ログ出力ソート順()
   * @return
   */
  private static Map<String, Integer> initMapData() {
    Map<String, Integer> hashMap = new HashMap<>();
    hashMap.put("治療予定", 10);
    hashMap.put("治療方法", 20);
    hashMap.put("治療日", 30);
    hashMap.put("クール", 40);
    hashMap.put("治療開始時刻", 50);
    hashMap.put("ベッド", 60);
    hashMap.put("治療時間", 70);
    hashMap.put("DW", 80);
    hashMap.put("VA", 90);
    hashMap.put("目標体重", 100);
    hashMap.put("除水量制限", 110);
    hashMap.put("ダイアライザ", 120);
    hashMap.put("吸着カラム", 130);
    hashMap.put("1次膜", 140);
    hashMap.put("2次膜", 150);
    hashMap.put("穿刺針(A針)", 160);
    hashMap.put("穿刺針(V針)", 170);
    hashMap.put("穿刺針(SN)", 180);
    hashMap.put("シングルニードル使用", 190);
    hashMap.put("血液回路", 200);
    hashMap.put("血流量", 210);
    hashMap.put("透析液", 220);
    hashMap.put("透析液流量", 230);
    hashMap.put("透析液使用数", 240);
    hashMap.put("透析液温度", 250);
    hashMap.put("補液", 260);
    hashMap.put("補液量", 270);
    hashMap.put("補液選択", 280);
    hashMap.put("補液使用数", 290);
    hashMap.put("補液温度", 300);
    hashMap.put("補液速度", 310);
    hashMap.put("抗凝固剤", 320);
    hashMap.put("抗凝固剤ワンショット量", 330);
    hashMap.put("抗凝固剤持続速度", 340);
    hashMap.put("抗凝固剤持続総量", 350);
    hashMap.put("IP使用選択", 360);
    hashMap.put("IPスタート", 370);
    hashMap.put("IPワンショット量", 380);
    hashMap.put("IP速度", 390);
    hashMap.put("IP速度最大値", 400);
    hashMap.put("自動ワンショット", 410);
    hashMap.put("IP電源自動切り", 420);
    hashMap.put("IP電源自動切り時間", 430);
    hashMap.put("IP電源OKモニタ切り", 440);
    hashMap.put("IP電源OKモニタ切り時間", 450);
    hashMap.put("投与薬剤", 460);
    hashMap.put("医療材料", 470);
    hashMap.put("指示コメント", 480);
    hashMap.put("風袋", 490);
    hashMap.put("除水補正", 500);
    hashMap.put("装置設定", 510);
    return hashMap;
  }

  /**
   *
   * @param oldIndTareInfo  変更前のスケジュール変更詳細
   * @param newIndTareInfo  変更後のスケジュール変更詳細
   * @return paramContentList スケジュール変更の内容
   */
  private List<String> createIndTareInfoContent(String oldIndTareInfo,String newIndTareInfo,String flag) {
    Gson gson =new Gson();
    List<String> paramContentList = new ArrayList<>();
    TareOrOffWaterJson oldTareOrOffWaterJson = gson.fromJson(oldIndTareInfo, TareOrOffWaterJson.class);
    TareOrOffWaterJson newTareOrOffWaterJson = gson.fromJson(newIndTareInfo, TareOrOffWaterJson.class);
    if(newTareOrOffWaterJson == null){
      return paramContentList;
    }
    switch (flag) {
      case "1":
        paramContentList.add("項目1：名称 未登録" + "→" +newTareOrOffWaterJson.getName_1() + System.getProperty("line.separator"));
        paramContentList.add("項目1：重さ 未登録" + "→" +newTareOrOffWaterJson.getWeight_1() + "g" + System.getProperty("line.separator"));
        paramContentList.add("項目2：名称 未登録" + "→" +newTareOrOffWaterJson.getName_2() + System.getProperty("line.separator"));
        paramContentList.add("項目2：重さ 未登録" + "→" +newTareOrOffWaterJson.getWeight_2() + "g" + System.getProperty("line.separator"));
        paramContentList.add("項目3：名称 未登録" + "→" +newTareOrOffWaterJson.getName_3() + System.getProperty("line.separator"));
        paramContentList.add("項目3：重さ 未登録" + "→" +newTareOrOffWaterJson.getWeight_3() + "g" + System.getProperty("line.separator"));
        paramContentList.add("項目4：名称 未登録" + "→" +newTareOrOffWaterJson.getName_4() + System.getProperty("line.separator"));
        paramContentList.add("項目4：重さ 未登録" + "→" +newTareOrOffWaterJson.getWeight_4() + "g" + System.getProperty("line.separator"));
        paramContentList.add("項目5：名称 未登録" + "→" +newTareOrOffWaterJson.getName_5() + System.getProperty("line.separator"));
        paramContentList.add("項目5：重さ 未登録" + "→" +newTareOrOffWaterJson.getWeight_5() + "g" + System.getProperty("line.separator"));
        break;
      case "2":
        if(newIndTareInfo.contains("name_1") && !oldTareOrOffWaterJson.getName_1().equals(newTareOrOffWaterJson.getName_1())){
          paramContentList.add("項目1：名称 "+oldTareOrOffWaterJson.getName_1() + "→" +newTareOrOffWaterJson.getName_1() + System.getProperty("line.separator"));
        }
        if(newIndTareInfo.contains("weight_1") && !oldTareOrOffWaterJson.getWeight_1().equals(newTareOrOffWaterJson.getWeight_1())){
          paramContentList.add("項目1：重さ "+oldTareOrOffWaterJson.getWeight_1() + "g→" +newTareOrOffWaterJson.getWeight_1() + "g" + System.getProperty("line.separator"));
        }
        if(newIndTareInfo.contains("name_2") && !oldTareOrOffWaterJson.getName_2().equals(newTareOrOffWaterJson.getName_2())){
          paramContentList.add("項目2：名称 "+oldTareOrOffWaterJson.getName_2() + "→" +newTareOrOffWaterJson.getName_2() + System.getProperty("line.separator"));
        }
        if(newIndTareInfo.contains("weight_2") && !oldTareOrOffWaterJson.getWeight_2().equals(newTareOrOffWaterJson.getWeight_2())){
          paramContentList.add("項目2：重さ "+oldTareOrOffWaterJson.getWeight_2() + "g→" +newTareOrOffWaterJson.getWeight_2() + "g"  + System.getProperty("line.separator"));
        }
        if(newIndTareInfo.contains("name_3") && !oldTareOrOffWaterJson.getName_3().equals(newTareOrOffWaterJson.getName_3())){
          paramContentList.add("項目3：名称 "+oldTareOrOffWaterJson.getName_3() + "→" +newTareOrOffWaterJson.getName_3() + System.getProperty("line.separator"));
        }
        if(newIndTareInfo.contains("weight_3") && !oldTareOrOffWaterJson.getWeight_3().equals(newTareOrOffWaterJson.getWeight_3())){
          paramContentList.add("項目3：重さ "+oldTareOrOffWaterJson.getWeight_3() + "g→" +newTareOrOffWaterJson.getWeight_3() + "g"  + System.getProperty("line.separator"));
        }
        if(newIndTareInfo.contains("name_4") &&!oldTareOrOffWaterJson.getName_4().equals(newTareOrOffWaterJson.getName_4())){
          paramContentList.add("項目4：名称 "+oldTareOrOffWaterJson.getName_4() + "→" +newTareOrOffWaterJson.getName_4() + System.getProperty("line.separator"));
        }
        if(newIndTareInfo.contains("weight_4") && !oldTareOrOffWaterJson.getWeight_4().equals(newTareOrOffWaterJson.getWeight_4())){
          paramContentList.add("項目4：重さ "+oldTareOrOffWaterJson.getWeight_4() + "g→" +newTareOrOffWaterJson.getWeight_4() + "g"  + System.getProperty("line.separator"));
        }
        if(newIndTareInfo.contains("name_5") && !oldTareOrOffWaterJson.getName_5().equals(newTareOrOffWaterJson.getName_5())){
          paramContentList.add("項目5：名称 "+oldTareOrOffWaterJson.getName_5() + "→" +newTareOrOffWaterJson.getName_5() + System.getProperty("line.separator"));
        }
        if(newIndTareInfo.contains("weight_5") && !oldTareOrOffWaterJson.getWeight_5().equals(newTareOrOffWaterJson.getWeight_5())){
          paramContentList.add("項目5：重さ "+oldTareOrOffWaterJson.getWeight_5() + "g→" +newTareOrOffWaterJson.getWeight_5() + "g"  + System.getProperty("line.separator"));
        }
        break;
      case "3":
        paramContentList.add("項目1：名称 "  +newTareOrOffWaterJson.getName_1() + "→"+"中止"+ System.getProperty("line.separator"));
        paramContentList.add("項目1：重さ "  +newTareOrOffWaterJson.getWeight_1() + "g→"+"中止"+ System.getProperty("line.separator"));
        paramContentList.add("項目2：名称 "  +newTareOrOffWaterJson.getName_2() + "→"+"中止"+ System.getProperty("line.separator"));
        paramContentList.add("項目2：重さ "  +newTareOrOffWaterJson.getWeight_2() + "g→"+"中止"+ System.getProperty("line.separator"));
        paramContentList.add("項目3：名称 "  +newTareOrOffWaterJson.getName_3() + "→"+"中止"+ System.getProperty("line.separator"));
        paramContentList.add("項目3：重さ "  +newTareOrOffWaterJson.getWeight_3() + "g→"+"中止"+ System.getProperty("line.separator"));
        paramContentList.add("項目4：名称 "  +newTareOrOffWaterJson.getName_4() + "→"+"中止"+ System.getProperty("line.separator"));
        paramContentList.add("項目4：重さ "  +newTareOrOffWaterJson.getWeight_4() + "g→"+"中止"+ System.getProperty("line.separator"));
        paramContentList.add("項目5：名称 "  +newTareOrOffWaterJson.getName_5() + "→"+"中止"+ System.getProperty("line.separator"));
        paramContentList.add("項目5：重さ "  +newTareOrOffWaterJson.getWeight_5() + "g→"+"中止"+ System.getProperty("line.separator"));
        break;
      default:
        break;
    }
    return paramContentList;
  }

  /***
   * 治療条件用、画面から取得した対象項目の項目番号一覧を返す処理
   * @param indInfo 画面から取得した治療条件の詳細
   * @return dispTargetNumList 画面から取得した対象項目番号一覧
   */
  private List<Integer> gettingTargetNum(JSONObject indInfo) {
    //画面から取得した、治療条件詳細のキー一覧をリスト形式で保持
    List<String> targetKeysList = new ArrayList<String>(indInfo.keySet());

    //治療条件詳細のキー一覧を変換して取得
    List<Integer> dispTargetNumList =
      targetKeysList.stream()
        .map(targetKey -> Integer.parseInt(targetKey))
        .collect(Collectors.toList());

    return dispTargetNumList;
  }
}
