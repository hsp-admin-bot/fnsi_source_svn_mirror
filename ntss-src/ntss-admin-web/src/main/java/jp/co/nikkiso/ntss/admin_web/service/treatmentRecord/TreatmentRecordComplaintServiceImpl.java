package jp.co.nikkiso.ntss.admin_web.service.treatmentRecord;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.google.gson.reflect.TypeToken;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.ComplaintService;
import jp.co.nikkiso.ntss.admin_web.service.SelectHistoryUtils;
import jp.co.nikkiso.ntss.admin_web.web.rest.util.WebApiCallCommonUtil;
import jp.co.nikkiso.ntss.core.dto.complaint.ComplaintItem;
import jp.co.nikkiso.ntss.core.dto.complaint.TreatStaffItem;
import jp.co.nikkiso.ntss.core.dto.complaint.TreatmentComplaintUpdateItem;
import jp.co.nikkiso.ntss.core.dto.complaint.TreatmentItem;
import jp.co.nikkiso.ntss.core.entity.MntMonitorMsgRecord;
import jp.co.nikkiso.ntss.core.entity.MstCompTreatment;
import jp.co.nikkiso.ntss.core.entity.MstComplaint;
import org.apache.commons.collections4.CollectionUtils;
import org.apache.commons.lang3.StringUtils;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import jp.co.nikkiso.ntss.core.constant.LoggingConstant.FUNCTION_CODE;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.dao.TreatmentRecordComplaintDao;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordComplaint;
import jp.co.nikkiso.ntss.core.exception.NotExistException;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import lombok.extern.slf4j.Slf4j;
import org.springframework.transaction.annotation.Transactional;

import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.Set;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.function.BiConsumer;
import java.util.function.Consumer;
import java.util.function.Function;
import java.util.function.Predicate;
import java.util.stream.Collectors;

/**
 * 治療記録画面（愁訴処置機能）のService実装クラス.
 */
@Service
@Slf4j
public class TreatmentRecordComplaintServiceImpl implements TreatmentRecordComplaintService {

  /**
   * 治療記録用愁訴処置のDaoインタフェース.
   */
  @Autowired
  private TreatmentRecordComplaintDao complaintDao;

  /**
  * ロギングのServiceインタフェース.
  */
  @Autowired
  private LogService logService;

  // add FNSI-改修内容追加OrdMain履歴 付 start
  @Autowired
  private SelectHistoryUtils selectHistoryUtils;
  // add FNSI-改修内容追加OrdMain履歴 付 end
  // add FNSI-redmine6060 fang start
  @Autowired
  private WebApiCallCommonUtil webApiCallCommonUtil;
  // add FNSI-redmine6060 fang end
  // add #9321 患者経過総合ビューアの長期間表示で、治療記録集計と愁訴処置がデータ表示しない。 zy start
  @Autowired
  private ComplaintService complaintService;
  // add #9321 患者経過総合ビューアの長期間表示で、治療記録集計と愁訴処置がデータ表示しない。 zy end
  /**
   * {@inheritDoc}
   */
  @Override
  public TreatmentRecordComplaint getTreatmentRecordComplaint(Long ordNo) throws NotExistException {
    try {
      return complaintDao.selectTreatmentRecordComplaintByOrdNo(ordNo);
    } catch (EmptyResultDataAccessException e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("There is no TreatmentRecordComplaint.");
      eventLogMessage.setSqlIdentification("(ordNo = "+ ordNo +")");
      logService.log(LogLevel.DEBUG, eventLogMessage,FUNCTION_CODE.FUNC_TREATMENT_RECORD,SERVICE_NAME.REMS, "ComplaintDao/selectTreatmentRecordComplaintByOrdNo");
      throw new NotExistException("存在しない治療情報のオーダ番号を指定されています。");
    }
  }
  // add 11420 【たくしん会】H9愁訴処置の表示が壊れる、データが倍増する、データが登録されない 関 start
  /**
   * {@inheritDoc}
   */
  @Override
  public String updateTreatmentRecordComplaint2(Long ordNo, TreatmentRecordComplaint treatmentRecordComplaint, Boolean forcedChangeFlag) {

    CHECK_RESULT checkState = null;
    String msgExist = "";
    TreatmentRecordComplaint updateBeforeData = complaintDao.selectTreatmentRecordComplaintByOrdNo(ordNo);

    Type treatmentType = new TypeToken<List<TreatmentItem>>() {}.getType();
    List<TreatmentItem> afterTreatmentList = parseJsonFromSource(
      treatmentRecordComplaint,
      TreatmentRecordComplaint::getRstTreatmentInfo,
      treatmentType
    );
    afterTreatmentList.sort(Comparator.comparing(TreatmentItem::getIndex, Comparator.nullsLast(Integer::compareTo)));
    boolean treatClassFlag = !CollectionUtils.isEmpty(afterTreatmentList) && afterTreatmentList.stream()
      .filter(item -> item.getTreat_class() != null)
      .anyMatch(item -> item.getTreat_class() == 3 || item.getTreat_class() == 4);

    if (!forcedChangeFlag) {
      checkState = this.checkTreatmentComplaintForUpdate(treatmentRecordComplaint, updateBeforeData, treatClassFlag);
    }
    if (CHECK_RESULT.MSG_RELOAD == checkState) {
      msgExist = "12000343";
      return msgExist;
    }
    if(CHECK_RESULT.MSG_TOBE_DEL == checkState) {
      msgExist = "12000344";
      return msgExist;
    }
    if (CHECK_RESULT.MSG_TOBE_NEW == checkState) {
      msgExist = "12000345";
      return msgExist;
    }
    if (CHECK_RESULT.MSG_TOBE_UPD == checkState) {
      msgExist = "12000346";
      return msgExist;
    }
    if (CHECK_RESULT.MSG_SKIP == checkState) {
      return msgExist;
    }
    selectHistoryUtils.insertMangoDbHistory(10, ordNo, null, new ArrayList<>(), new ArrayList<>(), null, null,
      null, null, null, new ArrayList<>(), new ArrayList<>(), null, null, null,
      new ArrayList<>(), null, null);

    NtssUser user = (NtssUser) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
    List<MstComplaint> mstComplaintList = complaintService.getAllMstComplaints(user.getFacilityCd());
    List<MstCompTreatment> mstCompTreatmentList = complaintService.getAllMstCompTreatments(user.getFacilityCd());

    Type complaintType = new TypeToken<List<ComplaintItem>>() {}.getType();
    Type treatStaffType = new TypeToken<List<TreatStaffItem>>() {}.getType();

    // 更新前データ作成
    List<ComplaintItem> beforeComplaintList = parseJsonFromSource(
      updateBeforeData,
      TreatmentRecordComplaint::getRstComplaintInfo,
      complaintType
    );
    List<TreatmentItem> beforeTreatmentList = parseJsonFromSource(
      updateBeforeData,
      TreatmentRecordComplaint::getRstTreatmentInfo,
      treatmentType
    );
    List<TreatStaffItem> beforeTreatStaffList = parseJsonFromSource(
      updateBeforeData,
      TreatmentRecordComplaint::getRstTreatStaffInfo,
      treatStaffType
    );

    // 更新后データ作成
    List<ComplaintItem> afterComplaintList = parseJsonFromSource(
      treatmentRecordComplaint,
      TreatmentRecordComplaint::getRstComplaintInfo,
      complaintType
    );
    List<TreatStaffItem> afterTreatStaffList = parseJsonFromSource(
      treatmentRecordComplaint,
      TreatmentRecordComplaint::getRstTreatStaffInfo,
      treatStaffType
    );
    afterTreatStaffList.sort(Comparator.comparing(TreatStaffItem::getIndex, Comparator.nullsLast(Integer::compareTo)));

    List<ComplaintItem> checkForUpdateComplaintList = parseJsonFromSource(
      treatmentRecordComplaint,
      TreatmentRecordComplaint::getBeforeRstComplaintInfo,
      complaintType
    );
    List<TreatmentItem> checkForUpdateTreatmentList = parseJsonFromSource(
      treatmentRecordComplaint,
      TreatmentRecordComplaint::getBeforeRstTreatmentInfo,
      treatmentType
    );
    List<TreatStaffItem> checkForUpdateTreatStaffList = parseJsonFromSource(
      treatmentRecordComplaint,
      TreatmentRecordComplaint::getBeforeRstTreatStaffInfo,
      treatStaffType
    );

    // 3つのリストの中で最大のctlnoを取り出します
    int ctl_no_max = this.getMaxCtlNo(beforeComplaintList, beforeTreatmentList, beforeTreatStaffList);

    List<ComplaintItem> finalBeforeComplaintList = new ArrayList<>(beforeComplaintList);
    List<TreatmentItem> finalBeforeTreatmentList = new ArrayList<>(beforeTreatmentList);
    List<TreatStaffItem> finalBeforeTreatStaffList = new ArrayList<>(beforeTreatStaffList);

    // 愁訴
    AtomicInteger complaintCounter = new AtomicInteger(ctl_no_max);
    int ctlNo = ctl_no_max + 1;
    processList(
      afterComplaintList,
      finalBeforeComplaintList,
      info -> info.getCtl_no(),
      info -> info.getIs_del() != null && info.getIs_del(),
      info -> {
        MstComplaint mstComplaint = mstComplaintList.stream()
          .filter(item -> item.getComplaintName() != null && !"".equals(item.getComplaintName()))
          .filter(item -> item.getComplaintName().equals(info.getComplaint()))
          .findFirst()
          .orElse(null);
        if (mstComplaint != null) {
          info.setComp_cd(mstComplaint.getComplaintCd());
        }
      },
      info -> info.getCtl_no() == null,
      info -> info.setCtl_no(complaintCounter.incrementAndGet()),
      treatClassFlag,
      (info, newCtlNo) -> info.setCtl_no(newCtlNo),
      ctlNo,
      checkForUpdateComplaintList
    );

    // 処置・酸素吸入・心電図
    AtomicInteger treatmentCounter = new AtomicInteger(ctl_no_max);
    processList(
      afterTreatmentList,
      finalBeforeTreatmentList,
      info -> info.getCtl_no(),
      info -> info.getIs_del() != null && info.getIs_del(),
      info -> {
        MstCompTreatment mstCompTreatment = mstCompTreatmentList.stream()
          .filter(item -> item.getTreatment() != null && !"".equals(item.getTreatment()))
          .filter(item -> item.getTreatment().equals(info.getTreat_name()))
          .findFirst()
          .orElse(null);
        if (mstCompTreatment != null) {
          info.setTreat_cd(mstCompTreatment.getCompTreatmentCd());
        }
      },
      info -> info.getCtl_no() == null,
      info -> info.setCtl_no(treatmentCounter.incrementAndGet()),
      treatClassFlag,
      (info, newCtlNo) -> info.setCtl_no(newCtlNo),
      ctlNo,
      checkForUpdateTreatmentList
    );

    // 処置者
    AtomicInteger treatStaffCounter = new AtomicInteger(ctl_no_max);
    processList(
      afterTreatStaffList,
      finalBeforeTreatStaffList,
      info -> info.getCtl_no(),
      info -> info.getIs_del() != null && info.getIs_del(),
      info -> {},
      info -> info.getCtl_no() == null,
      info -> info.setCtl_no(treatStaffCounter.incrementAndGet()),
      treatClassFlag,
      (info, newCtlNo) -> info.setCtl_no(ctlNo),
      ctlNo,
      checkForUpdateTreatStaffList
    );

    treatmentRecordComplaint.setRstComplaintInfo(
      listToJsonWithoutField(finalBeforeComplaintList, "is_del", "index")
    );

    treatmentRecordComplaint.setRstTreatmentInfo(
      listToJsonWithoutField(finalBeforeTreatmentList, "is_del", "index")
    );

    treatmentRecordComplaint.setRstTreatStaffInfo(
      listToJsonWithoutField(finalBeforeTreatStaffList, "is_del", "index")
    );
    treatmentRecordComplaint.setOrdNo(ordNo);
    final int updateRowCount = complaintDao.updateTreatmentRecordComplaint(ordNo, treatmentRecordComplaint);
    if (updateRowCount <= 0) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("There is no TreatmentRecordComplaint.");
      eventLogMessage.setSqlIdentification("(ordNo = "+ ordNo +"; treatmentRecordComplaint = "+ treatmentRecordComplaint +")");
      logService.log(LogLevel.DEBUG, eventLogMessage,FUNCTION_CODE.FUNC_TREATMENT_RECORD,SERVICE_NAME.REMS, "ComplaintDao/updateTreatmentRecordComplaint");
      throw new NotExistException("存在しない治療情報のオーダ番号を指定されています。");
    }
    return msgExist;
  }

  private <T> void processList(
    List<T> afterList,
    List<T> finalBeforeList,
    Function<T, Integer> getCtlNo,
    Predicate<T> isDeleted,
    Consumer<T> updateItem,
    Predicate<T> isNewItem,
    Consumer<T> addNewItem,
    Boolean treatClass,
    BiConsumer<T, Integer> setCtlNoFunction,
    int maxCtlNo,
    List<T> checkForUpdateList) {

    if (CollectionUtils.isEmpty(afterList) && CollectionUtils.isEmpty(checkForUpdateList)) {
      return;
    }
    if (CollectionUtils.isEmpty(afterList)) {
      checkForUpdateList.forEach(info -> {
        Integer ctlNo = getCtlNo.apply(info);
        finalBeforeList.removeIf(item -> ctlNo.equals(getCtlNo.apply(item)));
      });
      return;
    }

    List<Integer> ctlNoList = new ArrayList<>();
    Set<Integer> validValues = Set.of(3, 4);
    String[] linkCtlNoTmp = {null, null};
    afterList.forEach(info -> {
      Integer ctlNo = getCtlNo.apply(info);

      // 削除
      if (isDeleted.test(info) && finalBeforeList != null && !finalBeforeList.isEmpty()) {
        finalBeforeList.removeIf(item -> ctlNo.equals(getCtlNo.apply(item)));
      }
      // 編集
      else if (ctlNo != null && !isDeleted.test(info)) {
        if (!ctlNoList.contains(ctlNo)) {
          finalBeforeList.removeIf(item -> ctlNo.equals(getCtlNo.apply(item)));
        }
        ctlNoList.add(ctlNo);
        updateItem.accept(info);
        finalBeforeList.add(info);
      }
      // 新規
      else if (isNewItem.test(info)) {
        if (treatClass) {
          addNewItem.accept(info);
          if (info instanceof TreatmentItem) {
            TreatmentItem treatmentItem = (TreatmentItem) info;
            if (treatmentItem.getTreat_class() == 3) {
              if (treatmentItem.getOxygen_start() != null) {
                linkCtlNoTmp[0] = treatmentItem.getCtl_no().toString();
              } else {
                if (linkCtlNoTmp[0] != null) {
                  treatmentItem.setLinkStartDate(linkCtlNoTmp[0]);
                  linkCtlNoTmp[0] = null;
                }
              }
            } else {
              if (treatmentItem.getElectrocardiogram_start() != null) {
                linkCtlNoTmp[1] = treatmentItem.getCtl_no().toString();
              } else {
                if (linkCtlNoTmp[1] != null) {
                  treatmentItem.setLinkStartDate(linkCtlNoTmp[1]);
                  linkCtlNoTmp[1] = null;
                }
              }
            }
          }
          finalBeforeList.add(info);
        }else{
          setCtlNoFunction.accept(info, maxCtlNo);
          finalBeforeList.add(info);
        }
      }
    });
  }
  private String listToJsonWithoutField(List<?> list, String isDel, String index) {
    Gson gson= new GsonBuilder().serializeNulls().create();
    if (list == null || list.isEmpty()) {
      return gson.toJson(list);
    }
    String json = gson.toJson(list);
    JsonArray jsonArray = JsonParser.parseString(json).getAsJsonArray();
    for (JsonElement element : jsonArray) {
      JsonObject jsonObject = element.getAsJsonObject();
      jsonObject.remove(isDel);
      jsonObject.remove(index);
    }
    return gson.toJson(jsonArray);
  }

  private <T, S> List<T> parseJsonFromSource(
    S source,
    Function<S, String> jsonExtractor,
    Type type
  ) {
    if (source != null) {
      String json = jsonExtractor.apply(source);
      if (StringUtils.isNotBlank(json)) {
        return parseJsonToList(json, type);
      }
    }
    return Collections.emptyList();
  }
  private <T> List<T> parseJsonToList(String jsonString, Type type) {
    Gson gson= new GsonBuilder().serializeNulls().create();
    if (StringUtils.isNotBlank(jsonString)) {
      return gson.fromJson(jsonString, type);
    }
    return Collections.emptyList();
  }
  private <T> int findMaxCtlNo(List<T> list, Function<T, Integer> ctlNoExtractor) {
    if (list == null || list.isEmpty()) {
      return 0;
    }
    return list.stream()
      .map(ctlNoExtractor)
      .filter(Objects::nonNull)
      .max(Integer::compareTo)
      .orElse(0);
  }

  private int getMaxCtlNo(List<ComplaintItem> beforeComplaintList, List<TreatmentItem> beforeTreatmentList, List<TreatStaffItem> beforeTreatStaffList) {

    int ctl_no_complaint = findMaxCtlNo(beforeComplaintList, item -> item.getCtl_no());
    int ctl_no_treat = findMaxCtlNo(beforeTreatmentList, item -> item.getCtl_no());
    int ctl_no_staff = findMaxCtlNo(beforeTreatStaffList, item -> item.getCtl_no());

    return Math.max(ctl_no_complaint, Math.max(ctl_no_treat, ctl_no_staff));
  }
  // add 11420 【たくしん会】H9愁訴処置の表示が壊れる、データが倍増する、データが登録されない 関 end

  /**
   * {@inheritDoc}
   */
  @Override
  public int updateTreatmentRecordComplaint(Long ordNo, TreatmentRecordComplaint treatmentRecordComplaint) {

    // add FNSI-改修内容追加OrdMain履歴 付 start
    selectHistoryUtils.insertMangoDbHistory(10, ordNo, null, new ArrayList<>(), new ArrayList<>(), null, null,
      null, null, null, new ArrayList<>(), new ArrayList<>(), null, null, null,
      new ArrayList<>(), null, null);
    // mangoDb-updateTreatmentRecordComplaint-insertSuccess
    // add FNSI-改修内容追加OrdMain履歴 付 end
    // add #9321 患者経過総合ビューアの長期間表示で、治療記録集計と愁訴処置がデータ表示しない。 zy start
    String rstComplaintInfo = treatmentRecordComplaint.getRstComplaintInfo();
    Gson gson= new GsonBuilder().setDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSXXX").serializeNulls().create();
    Type listInfoType = new TypeToken<List<ComplaintItem>>() {}.getType();
    List<ComplaintItem> complaintList = gson.fromJson(rstComplaintInfo,listInfoType);
    NtssUser user = (NtssUser) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
    List<MstComplaint> mstComplaintList = complaintService.getAllMstComplaints(user.getFacilityCd());
    complaintList.forEach(info -> {
      if (info.getComplaint()!=null&&!"".equals(info.getComplaint())) {
        MstComplaint mstComplaint = mstComplaintList.stream().filter(item -> item.getComplaintName() != null && !"".equals(item.getComplaintName()))
          .filter(item -> item.getComplaintName().equals(info.getComplaint())).findFirst().orElse(null);
        if (mstComplaint != null) {
          info.setComp_cd(mstComplaint.getComplaintCd());
        }
      }
    });
    String rstTreatmentInfo = treatmentRecordComplaint.getRstTreatmentInfo();
    Type listType = new TypeToken<List<TreatmentItem>>() { }.getType();
    List<TreatmentItem> treatmentList = gson.fromJson(rstTreatmentInfo,listType);
    List<MstCompTreatment> mstCompTreatmentList = complaintService.getAllMstCompTreatments(user.getFacilityCd());
    treatmentList.forEach(info -> {
      if (info.getTreat_name()!=null&&!"".equals(info.getTreat_name())) {
        MstCompTreatment mstCompTreatment = mstCompTreatmentList.stream().filter(item -> item.getTreatment() != null && !"".equals(item.getTreatment()))
          .filter(item -> item.getTreatment().equals(info.getTreat_name())).findFirst().orElse(null);
        if (mstCompTreatment != null) {
          info.setTreat_cd(mstCompTreatment.getCompTreatmentCd());
        }
      }
    });

    treatmentRecordComplaint.setRstComplaintInfo(gson.toJson(complaintList));
    treatmentRecordComplaint.setRstTreatmentInfo(gson.toJson(treatmentList));
    //add #9321 患者経過総合ビューアの長期間表示で、治療記録集計と愁訴処置がデータ表示しない。 zy end
    treatmentRecordComplaint.setOrdNo(ordNo);
    final int updateRowCount = complaintDao.updateTreatmentRecordComplaint(ordNo, treatmentRecordComplaint);
    if (updateRowCount <= 0) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("There is no TreatmentRecordComplaint.");
      eventLogMessage.setSqlIdentification("(ordNo = "+ ordNo +"; treatmentRecordComplaint = "+ treatmentRecordComplaint +")");
      logService.log(LogLevel.DEBUG, eventLogMessage,FUNCTION_CODE.FUNC_TREATMENT_RECORD,SERVICE_NAME.REMS, "ComplaintDao/updateTreatmentRecordComplaint");
      throw new NotExistException("存在しない治療情報のオーダ番号を指定されています。");
    }
    //9480 治療記録（愁訴処置情報）の更新，実際の治療値パラメータの変更をトリガせず、計算インタフェースを注釈呼び出し、性能の浪費を避ける gjn start
    //add FNSI-redmine6060 fang start
    //webApiCallCommonUtil.doAutoCalculation(ordNo);
    // add FNSI-redmine6060 fang end
    //9480 治療記録（愁訴処置情報）の更新，実際の治療値パラメータの変更をトリガせず、計算インタフェースを注釈呼び出し、性能の浪費を避ける gjn end
    return updateRowCount;
  }

  // add #11420 【たくしん会】H9愁訴処置の表示が壊れる、データが倍増する、データが登録されない。　V1.0B zkm start
  /** 戻り値 */
  public enum CHECK_RESULT
  {
    /** 正常終了 */
    OK,
    /** 削除したいレコードが既に他の人で削除された */
    MSG_SKIP,
    /** 分類(処置区分、酸素吸入と心電図の開始と終了状態)不一致 */
    MSG_RELOAD,
    /** 削除したいレコードが既に他の人で更新された */
    MSG_TOBE_DEL,
    /** 更新したいレコードが既に他の人で削除された */
    MSG_TOBE_NEW,
    /** 変更したいレコードが既に他の人で更新された */
    MSG_TOBE_UPD,
  }

  /**
   * 愁訴処置更新(削除を含む)の排他チェック
   *
   * @param updateData 更新する前後のレコード
   * @param dbData 更新する前のDBレコード
   * @param treatOther 酸素吸入、心電図区分フラグ(true: 酸素吸入、心電図, false: 愁訴)
   *
   * @return ctl_no単位のチェック結果マップ
   */
  private CHECK_RESULT checkTreatmentComplaintForUpdate(TreatmentRecordComplaint updateData, TreatmentRecordComplaint dbData, boolean treatOther) {

    // 実績：愁訴情報(rst_complaint_info)、実績：愁訴処置情報(rst_treatment_info)、実績：愁訴処置者情報(rst_treat_staff_info)からをJSONObjectリストに整理する
    List<JSONObject> beforeJSONObjects = getJsonObjectFromUpdateItem(Arrays.asList(
      updateData.getBeforeRstTreatmentInfo(), updateData.getBeforeRstTreatStaffInfo(), updateData.getBeforeRstComplaintInfo()
    ), new HashSet<>());
    // 更新前のctlNoをまとめ(処置区分単位に)
    Set<String> beforeCtlNoSet = getValueByKeyFromItem(beforeJSONObjects, "ctl_no");

    List<JSONObject> dbJSONObjects = getJsonObjectFromUpdateItem(Arrays.asList(
      dbData.getRstTreatmentInfo(), dbData.getRstTreatStaffInfo(), dbData.getRstComplaintInfo()
    ), treatOther ? new HashSet<>() : beforeCtlNoSet);

    // 更新したいレコードの操作種類を取得する(追加や、変更や、削除など)
    List<JSONObject> afterJSONObjects = getJsonObjectFromUpdateItem(Arrays.asList(
        updateData.getRstTreatmentInfo(), updateData.getRstTreatStaffInfo(), updateData.getRstComplaintInfo()),
      new HashSet<>());

    Set<String> loopSet = beforeCtlNoSet;

    // 酸素吸入、心電図の場合、更新前のレコード数がdbと不一致であれば、画面をリフレッシュする
    Integer minAddObjIndex = null;
    String afterTreatClass;
    if (treatOther) {
      // 酸素吸入と心電図を区別する
      afterTreatClass = getValueByKeyFromItem(afterJSONObjects, "treat_class").iterator().next();
      Set<String> dbCtlNoSet = getValueByKeyFromItem(dbJSONObjects, "ctl_no", "treat_class", afterTreatClass);
      if (beforeCtlNoSet.size() != dbCtlNoSet.size()){
        return CHECK_RESULT.MSG_RELOAD;
      }
      Optional<JSONObject> minIndexAddObj = afterJSONObjects.stream()
        .filter(item -> item.has("ctl_no") && item.get("ctl_no").equals(JSONObject.NULL)
          && item.has("index") && !item.get("index").equals(JSONObject.NULL))
        .min(Comparator.comparing(item -> (Integer) item.get("index")));
      minAddObjIndex = minIndexAddObj.map(jsonObject -> Integer.valueOf(jsonObject.get("index").toString())).orElse(-1);
      loopSet = getValueByKeyFromItem(afterJSONObjects, "ctl_no");
    } else {
      afterTreatClass = StringUtils.EMPTY;
    }

    // 更新前のctl_noリストをループしてチェックを行う
    for(String ctlNo : loopSet) {
      // 更新前レコードに指定ctl_noレコードを取得する
      List<JSONObject> beforeItemsByCtlNo = getJsonObjectsByCtlNo(ctlNo, "ctl_no", beforeJSONObjects);
      // 更新したいレコードに指定ctl_noレコードを取得する
      List<JSONObject> afterUpdateItemsByCtlNo = getJsonObjectsByCtlNo(ctlNo, "ctl_no", afterJSONObjects);
      Set<String> delFlgSet = getValueByKeyFromItem(afterUpdateItemsByCtlNo, "is_del");
      // 指定ctl_noのレコードをTreatmentComplaintUpdateItemモデルにまとめ
      Set<TreatmentComplaintUpdateItem> beforeUpdateItems = getCheckForUpdateItemMap(beforeItemsByCtlNo, treatOther);
      Set<TreatmentComplaintUpdateItem> dbUpdateItems;

      if (treatOther) {
        // 酸素吸入と心電図新規追加の場合
        List<JSONObject> afterUpdateItemsByIndex = getJsonObjectsByCtlNo(minAddObjIndex.toString(), "index", afterJSONObjects);
        // dbの全て酸素吸入或いは心電図を取得する
        dbUpdateItems = getCheckForUpdateItemMap(dbJSONObjects, true);
        dbUpdateItems = dbUpdateItems.stream()
          .filter(db -> StringUtils.isNotEmpty(db.getTreat_class()) && db.getTreat_class().equals(afterTreatClass))
          .collect(Collectors.toSet());
        if (CollectionUtils.isNotEmpty(afterUpdateItemsByIndex)) {
          // 指定ctl_noのレコードをTreatmentComplaintUpdateItemモデルにまとめ
          Set<TreatmentComplaintUpdateItem> updateItems = getCheckForUpdateItemMap(afterUpdateItemsByIndex, true);
          TreatmentComplaintUpdateItem updateItem = updateItems.iterator().next();
          TreatmentComplaintUpdateItem dbMaxCtlNoItem = dbUpdateItems.stream()
            .max(Comparator.comparing(TreatmentComplaintUpdateItem::getCtl_no))
            .orElse(new TreatmentComplaintUpdateItem());
          // 新規追加の処置が開始である
          if (StringUtils.isNotEmpty(updateItem.getLinkStartDate()) && StringUtils.isNotEmpty(dbMaxCtlNoItem.getLinkStartDate())) {
            if ("null".equals(updateItem.getLinkStartDate())) {
              if ("null".equals(dbMaxCtlNoItem.getLinkStartDate())) {
                return CHECK_RESULT.MSG_RELOAD;
              }
            } else {
              if (!"null".equals(dbMaxCtlNoItem.getLinkStartDate()) || !updateItem.getLinkStartDate().equals(dbMaxCtlNoItem.getCtl_no())) {
                return CHECK_RESULT.MSG_RELOAD;
              }
            }
          }
        }
        dbUpdateItems = dbUpdateItems.stream().filter(db -> db.getCtl_no().equals(ctlNo)).collect(Collectors.toSet());
      } else {
        // dbレコードに指定ctl_noレコードを取得する
        List<JSONObject> dbItemsByCtlNo = getJsonObjectsByCtlNo(ctlNo, "ctl_no", dbJSONObjects);
        // 更新前のctlNoが存在しない
        if (StringUtils.isNotEmpty(ctlNo) && dbItemsByCtlNo.isEmpty()) {
          return delFlgSet.isEmpty() || !delFlgSet.contains(Boolean.TRUE.toString())
            ? CHECK_RESULT.MSG_TOBE_NEW : CHECK_RESULT.MSG_SKIP;
        }

        // 処置区分を取得する
        Set<String> beforeUpdateTreatClass = getValueByKeyFromItem(beforeItemsByCtlNo, "treat_class");
        Set<String> dbTreatClass = getValueByKeyFromItem(dbItemsByCtlNo, "treat_class");

        // 処置区分が一致するかをチェックする
        if (CollectionUtils.isNotEmpty(dbTreatClass) && !beforeUpdateTreatClass.equals(dbTreatClass)) {
          return CHECK_RESULT.MSG_RELOAD;
        }

        dbUpdateItems = getCheckForUpdateItemMap(dbItemsByCtlNo, false);

        // レコード数を確認する
        if (beforeUpdateItems.size() != dbUpdateItems.size()) {
          return CHECK_RESULT.MSG_TOBE_UPD;
        }
      }

      // 画面の見えているものが一致するかをチェックする
      if (!dbUpdateItems.isEmpty() || !treatOther) {
        Set<TreatmentComplaintUpdateItem> finalDbUpdateItems = dbUpdateItems;
        List<String> idxList = new ArrayList<>();
        long updateCount = beforeUpdateItems.stream()
          .filter(beforeItem -> {
            List<TreatmentComplaintUpdateItem> dbItems = finalDbUpdateItems.stream()
              .filter(db -> db.equals(beforeItem) && !idxList.contains(db.getItemIdx())).toList();
            if (CollectionUtils.isNotEmpty(dbItems)) {
              idxList.add(dbItems.get(0).getItemIdx());
            }
            return CollectionUtils.isEmpty(dbItems);
          }).count();

        if (updateCount > 0) {
          return delFlgSet.isEmpty() || !delFlgSet.contains(Boolean.TRUE.toString())
            ? CHECK_RESULT.MSG_TOBE_UPD : CHECK_RESULT.MSG_TOBE_DEL;
        }
      }
    }
    return CHECK_RESULT.OK;
  }

  private List<JSONObject> getJsonObjectFromUpdateItem(List<String> itemList, Set<String> ctlNoList) {
    List<JSONObject> objects = new ArrayList<>();
    itemList.forEach(item -> {
      if (StringUtils.isNotBlank(item)) {
        JSONArray itemArray = new JSONArray(item);
        for (int i = 0; i < itemArray.length(); i++) {
          JSONObject jsonObject = (JSONObject) itemArray.get(i);
          if (ctlNoList.isEmpty()) {
            objects.add(jsonObject);
          } else {
            if (jsonObject.has("ctl_no") && ctlNoList.contains(String.valueOf(jsonObject.get("ctl_no")))) {
              objects.add(jsonObject);
            }
          }
        }
      }
    });
    return objects;
  }

  private List<JSONObject> getJsonObjectsByCtlNo(String keyVal, String key, List<JSONObject> updateItems) {
    return updateItems.stream()
      .filter(item -> item.has(key)
        && keyVal.equals(Objects.isNull(item.get(key)) ? "" : String.valueOf(item.get(key))))
      .toList();
  }

  private String getTempTreatClass(JSONObject item) {
    return "4".equals(String.valueOf(item.get("treat_class")))
      ? "2" : "3".equals(String.valueOf(item.get("treat_class")))
      ? "1" : "0";
  }

  private Set<String> getValueByKeyFromItem(List<JSONObject> items, String key) {
    return getValueByKeyFromItem(items, key, StringUtils.EMPTY, StringUtils.EMPTY);
  }

  private Set<String> getValueByKeyFromItem(List<JSONObject> items, String key, String filterKey, String filterVal) {
    return items.stream()
      .filter(item -> {
        boolean res = item.has(key);
        if (StringUtils.isNotEmpty(filterKey)) {
          if (item.has(filterKey)) {
            if ("treat_class".equals(filterKey)) {
              return res && filterVal.equals(getTempTreatClass(item));
            } else {
              return res && filterVal.equals(String.valueOf(item.get(filterKey)));
            }
          } else {
            return false;
          }
        }
        return res;
      })
      .map(item -> {
        if ("treat_class".equals(key)) {
          // 愁訴処置：0、酸素吸入：1、心電図：2
          return getTempTreatClass(item);
        } else {
          return String.valueOf(Objects.isNull(item.get(key)) ? "" : item.get(key));
        }
      }).collect(Collectors.toSet());
  }

  private Set<TreatmentComplaintUpdateItem> getCheckForUpdateItemMap(List<JSONObject> jsonObjects, boolean isSetInRowNo) {
    Map<String, TreatmentComplaintUpdateItem> resMap = new HashMap<>();
    AtomicInteger index = new AtomicInteger(1);
    jsonObjects.forEach(obj -> {
      String ctlNo = String.valueOf(obj.get("ctl_no"));
      String rowNo = String.valueOf(obj.get("row_no"));
      String mapKey = String.join("-", ctlNo, rowNo);
      TreatmentComplaintUpdateItem updateCheckItem = new TreatmentComplaintUpdateItem();
      if (isSetInRowNo) {
        if (resMap.containsKey(mapKey)) {
          updateCheckItem = resMap.get(mapKey);
        }
      }
      setUpdateCheckItem(obj, updateCheckItem);
      resMap.put(isSetInRowNo ? mapKey : String.valueOf(index.getAndIncrement()), updateCheckItem);
    });
    resMap.forEach((k, v) -> v.setItemIdx(k));
    return new HashSet<>(resMap.values());
  }

  private void setUpdateCheckItem(JSONObject obj, TreatmentComplaintUpdateItem updateCheckItem) {
    updateCheckItem.setCtl_no(String.valueOf(obj.get("ctl_no")));
    updateCheckItem.setOccur_date(String.valueOf(obj.get("occur_date")));
    if (obj.has("treat_class")) {
      updateCheckItem.setTreat_class(getTempTreatClass(obj));
    }
    if (obj.has("complaint")) {
      updateCheckItem.setComplaint(String.valueOf(obj.get("complaint")));
    }
    if (obj.has("treat_name")) {
      updateCheckItem.setTreat_name(String.valueOf(obj.get("treat_name")));
    }
    if (obj.has("medicine_cd")) {
      updateCheckItem.setMedicine_cd(String.valueOf(obj.get("medicine_cd")));
    }
    if (obj.has("amount")) {
      updateCheckItem.setAmount(String.valueOf(obj.get("amount")));
    }
    if (obj.has("procedure_cd")) {
      updateCheckItem.setProcedure_cd(String.valueOf(obj.get("procedure_cd")));
    }
    if (obj.has("medicine_type")) {
      updateCheckItem.setMedicine_type(String.valueOf(obj.get("medicine_type")));
    }
    if (obj.has("treat_staff_cd")) {
      updateCheckItem.setTreat_staff_cd(String.valueOf(obj.get("treat_staff_cd")));
    }
    if (obj.has("oxygen_start")) {
      updateCheckItem.setOxygen_start(String.valueOf(obj.get("oxygen_start")));
    }
    if (obj.has("oxygen_time")) {
      updateCheckItem.setOxygen_time(String.valueOf(obj.get("oxygen_time")));
    }
    if (obj.has("oxygen_amount")) {
      updateCheckItem.setOxygen_amount(String.valueOf(obj.get("oxygen_amount")));
    }
    if (obj.has("oxygen_speed")) {
      updateCheckItem.setOxygen_speed(String.valueOf(obj.get("oxygen_speed")));
    }
    if (obj.has("linkStartDate")) {
      updateCheckItem.setLinkStartDate(String.valueOf(obj.get("linkStartDate")));
    }
  }
  // add #11420 【たくしん会】H9愁訴処置の表示が壊れる、データが倍増する、データが登録されない。　V1.0B zkm end

  //add FNSI修正401改修 房 start

  /**
   * 装置動作記録情報取得
   * @param facilityCd
   * @param ordNo
   * @return
   */
  @Override
  public List<MntMonitorMsgRecord> getMntMonitorMsgRecord(String facilityCd, Long ordNo){
    List<MntMonitorMsgRecord> mntMonitorMsgRecords = null;
    try {
      mntMonitorMsgRecords = complaintDao.selectMonitorMsgRecord(facilityCd, ordNo);
    } catch (EmptyResultDataAccessException e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("There is no TreatmentRecordComplaint.");
      eventLogMessage.setSqlIdentification("(ordNo = "+ ordNo +")");
      logService.log(LogLevel.DEBUG, eventLogMessage,FUNCTION_CODE.FUNC_TREATMENT_RECORD,SERVICE_NAME.REMS, "ComplaintDao/selectTreatmentRecordComplaintByOrdNo");
      throw new NotExistException("モニタ情報取得失敗");
    }
    return mntMonitorMsgRecords;
  }

  /**
   * 装置動作記録情報更新
   * @param mntMonitorMsgRecord
   */
  @Override
  @Transactional
  public void updateMntMonitorMsgRecord (MntMonitorMsgRecord mntMonitorMsgRecord){
    complaintDao.updatetMonitorMsgRecord(mntMonitorMsgRecord);
  }
  //add FNSI修正401改修 房 end
}
