package jp.co.nikkiso.ntss.device_edge.service;

import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;

import io.micrometer.core.instrument.util.StringUtils;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.constant.TreatmentItemsDef;
import jp.co.nikkiso.ntss.core.dao.MstChecklistDao;
import jp.co.nikkiso.ntss.core.dao.MstDialyzerDao;
import jp.co.nikkiso.ntss.core.dao.MstEquipmentDao;
import jp.co.nikkiso.ntss.core.dao.MstMedicateTimingDao;
import jp.co.nikkiso.ntss.core.dao.MstMedicineDao;
import jp.co.nikkiso.ntss.core.dao.MstMedicineMixDao;
import jp.co.nikkiso.ntss.core.dao.MstPersonalUserDao;
import jp.co.nikkiso.ntss.core.dao.MstProcedureDao;
import jp.co.nikkiso.ntss.core.dao.MstSelectorDao;
import jp.co.nikkiso.ntss.core.dao.MstUserDao;
import jp.co.nikkiso.ntss.core.dao.OrdChecklistDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.entity.MstChecklist;
import jp.co.nikkiso.ntss.core.entity.MstDialyzer;
import jp.co.nikkiso.ntss.core.entity.MstEquipment;
import jp.co.nikkiso.ntss.core.entity.MstMedicateTiming;
import jp.co.nikkiso.ntss.core.entity.MstMedicine;
import jp.co.nikkiso.ntss.core.entity.MstMedicineMix;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.entity.MstProcedure;
import jp.co.nikkiso.ntss.core.entity.MstSelector;
import jp.co.nikkiso.ntss.core.entity.MstUser;
import jp.co.nikkiso.ntss.core.entity.OrdChecklist;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import org.json.JSONObject;
import org.modelmapper.ModelMapper;
import org.seasar.doma.Domain;
import org.seasar.doma.jdbc.SelectOptions;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;

import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.entity.OrdChecklist.OrdChecklistRegCheckInfo;
import jp.co.nikkiso.ntss.core.entity.OrdChecklist.OrdChecklistRegStaffInfo;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainForCheckListSchedule;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.device_edge.response.checkList.CheckListScheduleResponse;
import jp.co.nikkiso.ntss.device_edge.response.checkList.ChecklistUpdateResponse;
import jp.co.nikkiso.ntss.device_edge.response.checkList.ComsvChecklistResponse;
import jp.co.nikkiso.ntss.device_edge.response.checkList.MediUpdateResponse;
import jp.co.nikkiso.ntss.device_edge.response.checkList.OrdChecklistWithUserNameResponse;
import jp.co.nikkiso.ntss.device_edge.response.checkList.dto.IndMediInfoDto;
import jp.co.nikkiso.ntss.device_edge.response.checkList.dto.ReceiveRstMediInfoDto;
import jp.co.nikkiso.ntss.device_edge.response.checkList.dto.RstMediInfoDto;
import jp.co.nikkiso.ntss.device_edge.util.DateTimeUtils;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

@Service
public class ComsvOrdCheckListServiceImpl implements ComsvOrdCheckListService {

  @Autowired
  private MstUserDao mstUserDao;
  @Autowired
  private OrdMainDao ordMainDao;
  @Autowired
  private PatPersonalMainDao patPersonalMainDao;
  @Autowired
  private MstEquipmentDao mstEquipDao;
  @Autowired
  private MstChecklistDao mstChecklistDao;
  @Autowired
  private MstDialyzerDao mstDialyzerDao;
  @Autowired
  private OrdChecklistDao ordChecklistDao;
  @Autowired
  private MstPersonalUserDao mstPersonalUserDao;
  @Autowired
  private MstMedicineDao mstMedicineDao;
  @Autowired
  private MstMedicateTimingDao mstMedicateTimingDao;
  @Autowired
  private MstProcedureDao mstProcedureDao;

  @Autowired
  private MstMedicineMixDao mstMedicineMixDao;

  /**
   * ObjectMapper.
   */
  @Autowired
  private ObjectMapper mapper;

  @Autowired
  private LogService logService;
  /**
   * ON/OFFフラグ
   */
  public static class FlagType {

    /**
     * OFF.
     */
    public static final String FLAG_OFF = "0";

    /**
     * ON.
     */
    public static final String FLAG_ON = "1";
  }


  // #11589 2025.03.10 add 各アイテムについてマスタの並び順で表示を行う TDC米沢 start
  // ダイアライザマスタ
  static final String MST_DIALYZER_PHYSICAL_NAME = "mst_dialyzer";
  // 医療材料マスタ
  static final String MST_EQUIPMENT_PHYSICAL_NAME = "mst_equipment";
  // 薬剤マスタ
  static final String MST_MEDICINE_PHYSICAL_NAME = "mst_medicine";
  // 調整薬剤マスタ
  static final String MST_MEDICINE_MIX_PHYSICAL_NAME = "mst_medicine_mix";
  @Autowired
  // マスタデータの並び順取得用DAO
  private MstSelectorDao mstSelectorDao;
  // #11589 2025.02.10 add 各アイテムについてマスタの並び順で表示を行う TDC米沢 end


  /**
   * 治療中のord_main情報取得
   * {@inheritDoc}
   */
  @Override
  public List<CheckListScheduleResponse> getOrderTreatment(String facilityCd, Short nextPat) {

    /***** 実装途中 *****/
    // 本日の日付
    Date date = new Date();
    String today = new SimpleDateFormat("yyyyMMdd").format(date);
    List<CheckListScheduleResponse> res = new ArrayList<>();

    // 現在のクールコード

    // 治療中と本日以降の直近スケジュール5つ分取得
    List<OrdMainForCheckListSchedule> ordList = ordMainDao.selectTreatmentByTreatDate(facilityCd, today);

    // 患者名取得用
    List<Long> patIdList = ordList.stream().map(s -> s.getPatId()).distinct().collect(Collectors.toList());
    patIdList.removeAll(Collections.singleton(null)); // null削除
    List<PatPersonalMain> pats = patPersonalMainDao.selectByIdListFacilityCd(patIdList, facilityCd);
    List<PatPersonalMain> pat;
    String patLastName = "";
    String patFirstName = "";
    String patName = "";

    // ベッドコード
    Long bedCd = null;
    // 表示スケジュール数
    int schCount = 0;

    for (OrdMainForCheckListSchedule ordMainTreat : ordList) {

      // ベッド
      if (!Objects.equals(bedCd, ordMainTreat.getIndBedCd())) {
        // ベッドコード
        bedCd = ordMainTreat.getIndBedCd();
        // 表示数
        schCount = 0;
      }

      // 追加フラグ
      boolean addflg = false;

      // 治療中の場合
      if (!(ordMainTreat.getRstDialysisState().equals("0")) && !(ordMainTreat.getRstDialysisState().equals("6"))) {
        // 追加
        addflg = true;
      } else {

        // 次患者の場合
        // 次患者  次クール
        if (nextPat == 0) {

        }
        // 次患者  当日
        else if (nextPat == 1) {

        }
        // 次患者  次クール以降
        else if (nextPat == 2) {

        }
      }

      if (addflg == true) {

        // 表示数カウント
        schCount++;

        // 治療状況が空の場合は条件送信前扱い
        if (Objects.equals(ordMainTreat.getRstDialysisState(), "") || ordMainTreat.getRstDialysisState() == null) {
          ordMainTreat.setRstDialysisState("0");
        }

        // ？？？？患者の場合
        if (ordMainTreat.getPatId() == null) {
          patName = "？？？？";
        } else {
          // 患者名取得
          pat = pats.stream().filter(p -> Objects.equals(p.getPat_id(), ordMainTreat.getPatId()))
              .collect(Collectors.toList());
          patLastName = "";
          patFirstName = "";
          patName = "";
          if (pat.size() > 0) {
            patLastName = pat.get(0).getPat_last_name();
            patFirstName = pat.get(0).getPat_first_name();
            patName = patLastName + " " + patFirstName;
          }
        }

        // 応答用スケジュール情報作成
        CheckListScheduleResponse r = new CheckListScheduleResponse();
        r.setOrdNo(ordMainTreat.getOrdNo());
        r.setPatId(ordMainTreat.getPatId());
        r.setPatName(patName);
        r.setFacilityCd(facilityCd);
        r.setTreatDate(ordMainTreat.getTreatDate());
        r.setTreatWeek(ordMainTreat.getTreatWeek());
        r.setRstDialysisState(ordMainTreat.getRstDialysisState());
        r.setIndMediInfo(ordMainTreat.getIndMediInfo());
        r.setIndCondInfo(ordMainTreat.getIndCondInfo());
        r.setIndEquipInfo(ordMainTreat.getIndEquipInfo());
        r.setRstMediInfo(ordMainTreat.getRstMediInfo());
        r.setRstCondInfo(ordMainTreat.getRstCondInfo());
        r.setRstEquipInfo(ordMainTreat.getRstEquipInfo());

        // 条件送信前の場合
        if (ordMainTreat.getRstDialysisState().equals("0")) {
          r.setKurCd(ordMainTreat.getIndKurCd());
          r.setKurName(ordMainTreat.getIndKurName());
          r.setBedCd(ordMainTreat.getIndBedCd());
          r.setBedName(ordMainTreat.getIndBedName());
          r.setDeviceMode(ordMainTreat.getIndDeviceMode());
        }
        // 条件送信後の場合
        else {
          r.setKurCd(ordMainTreat.getRstKurCd());
          r.setKurName(ordMainTreat.getRstKurName());
          r.setBedCd(ordMainTreat.getRstBedCd());
          r.setBedName(ordMainTreat.getRstBedName());
          r.setDeviceMode(ordMainTreat.getRstDeviceMode());
        }

        res.add(r);
      }
    }

    return res;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<CheckListScheduleResponse> getOrderByTreatDate(String facilityCd, String treatDate) {
    List<CheckListScheduleResponse> res = new ArrayList<>();
    List<OrdMainForCheckListSchedule> ordList = ordMainDao.selectByTreatDate(facilityCd, treatDate);
    List<Long> patIdList = ordList.stream().map(s -> s.getPatId()).distinct().collect(Collectors.toList());
    patIdList.removeAll(Collections.singleton(null)); // null削除
    List<PatPersonalMain> pats = patPersonalMainDao.selectByIdListFacilityCd(patIdList, facilityCd);
    List<PatPersonalMain> pat;
    String patLastName = "";
    String patFirstName = "";
    String patName = "";
    for (OrdMainForCheckListSchedule ordMainTreat : ordList) {

      // 治療状況が空の場合は条件送信前扱い
      if (ordMainTreat.getRstDialysisState().equals("") || ordMainTreat.getRstDialysisState() == null) {
        ordMainTreat.setRstDialysisState("0");
      }

      // ？？？？患者の場合
      if (ordMainTreat.getPatId() == null) {
        patName = "？？？？";
      } else {
        // 患者名取得
        pat = pats.stream().filter(p -> Objects.equals(p.getPat_id(), ordMainTreat.getPatId()))
            .collect(Collectors.toList());
        patLastName = "";
        patFirstName = "";
        patName = "";
        if (pat.size() > 0) {
          patLastName = pat.get(0).getPat_last_name();
          patFirstName = pat.get(0).getPat_first_name();
          patName = patLastName + " " + patFirstName;
        }
      }

      // 応答用スケジュール情報作成
      CheckListScheduleResponse r = new CheckListScheduleResponse();
      r.setOrdNo(ordMainTreat.getOrdNo());
      r.setPatId(ordMainTreat.getPatId());
      r.setPatName(patName);
      r.setFacilityCd(facilityCd);
      r.setTreatDate(treatDate);
      r.setTreatWeek(ordMainTreat.getTreatWeek());
      r.setRstDialysisState(ordMainTreat.getRstDialysisState());
      r.setIndMediInfo(ordMainTreat.getIndMediInfo());
      r.setIndCondInfo(ordMainTreat.getIndCondInfo());
      r.setIndEquipInfo(ordMainTreat.getIndEquipInfo());
      r.setRstMediInfo(ordMainTreat.getRstMediInfo());
      r.setRstCondInfo(ordMainTreat.getRstCondInfo());
      r.setRstEquipInfo(ordMainTreat.getRstEquipInfo());

      // 条件送信前の場合
      if (ordMainTreat.getRstDialysisState().equals("0")) {
        r.setKurCd(ordMainTreat.getIndKurCd());
        r.setKurName(ordMainTreat.getIndKurName());
        r.setBedCd(ordMainTreat.getIndBedCd());
        r.setBedName(ordMainTreat.getIndBedName());
        r.setDeviceMode(ordMainTreat.getIndDeviceMode());
      }
      // 条件送信後の場合
      else {
        r.setKurCd(ordMainTreat.getRstKurCd());
        r.setKurName(ordMainTreat.getRstKurName());
        r.setBedCd(ordMainTreat.getRstBedCd());
        r.setBedName(ordMainTreat.getRstBedName());
        r.setDeviceMode(ordMainTreat.getRstDeviceMode());
      }

      res.add(r);
    }

    return res;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  public CheckListScheduleResponse getOrderByOrderNo(Long ordNo) throws IOException {
    OrdMainForCheckListSchedule ordList = ordMainDao.selectByOrdNoChecklist(ordNo);
    PatPersonalMain pat = patPersonalMainDao.selectById(ordList.getPatId());
    String patName = "";

    // 患者名取得
    if (pat != null) {
      // mod #9485  shiyw start
      String pat_last_name = pat.getPat_last_name() == null?"":pat.getPat_last_name();
      String pat_first_name = pat.getPat_first_name() == null?"":pat.getPat_first_name();
      patName = pat_last_name + " " + pat_first_name;
      // mod #9485  shiyw end
    }

    // 応答用スケジュール情報作成
    CheckListScheduleResponse res = new CheckListScheduleResponse();
    res.setOrdNo(ordList.getOrdNo());
    res.setPatId(ordList.getPatId());
    res.setPatName(patName);
    //res.setFacilityCd(ordList.getFacilityCd());
    res.setTreatDate(ordList.getTreatDate());
    res.setTreatWeek(ordList.getTreatWeek());
    res.setRstDialysisState(ordList.getRstDialysisState());
    res.setIndMediInfo(ordList.getIndMediInfo());
    res.setIndCondInfo(ordList.getIndCondInfo());
    res.setIndEquipInfo(ordList.getIndEquipInfo());
    res.setRstMediInfo(ordList.getRstMediInfo());
    res.setRstCondInfo(ordList.getRstCondInfo());
    res.setRstEquipInfo(ordList.getRstEquipInfo());

    // 治療状況が空の場合は条件送信前扱い
    if (ordList.getRstDialysisState().equals("") || ordList.getRstDialysisState() == null) {
      ordList.setRstDialysisState("0");
    }

    // 条件送信前の場合
    if (ordList.getRstDialysisState().equals("0")) {
      res.setKurCd(ordList.getIndKurCd());
      res.setKurName(ordList.getIndKurName());
      res.setBedCd(ordList.getIndBedCd());
      res.setBedName(ordList.getIndBedName());
      res.setDeviceMode(ordList.getIndDeviceMode());

      // 投与薬剤情報
      String mediInfo = ordList.getIndMediInfo();
      StringBuilder sb = new StringBuilder();
      String resMediInfo = null;

      List<IndMediInfoDto> dtolist = mediInfo == null || mediInfo.isEmpty() ? new ArrayList<>()
          : new ObjectMapper().readValue(mediInfo, new TypeReference<List<IndMediInfoDto>>() {
          });

      for (IndMediInfoDto dto : dtolist) {

        // 調整薬剤・薬剤の区分
        if (Objects.equals(dto.getMedicineType(), MedicineType.CONTROL_MEDICINE)) {
          // 調整薬剤の場合
          MstMedicineMix medicineMix = mstMedicineMixDao.selectByCd(ordList.getFacilityCd(), dto.getCd());
          if (medicineMix != null) {
            dto.setName(medicineMix.getMedicineMixName());
          }
        } else {
          // 薬剤の場合 とする
          // 薬剤名
          MstMedicine medicine = mstMedicineDao.selectByCd(ordList.getFacilityCd(), dto.getCd());
          if (medicine != null) {
            dto.setName(medicine.getMedicineName());
          }
        }

        // タイミング名
        MstMedicateTiming mediTiming = mstMedicateTimingDao.selectByCd(ordList.getFacilityCd(), dto.getTimingCd());
        if (mediTiming != null) {
          dto.setTimingName(mediTiming.getMedicateTimingName());
        }

        // 手技名 mstProcedureDao
        MstProcedure procedure = mstProcedureDao.selectByCd(ordList.getFacilityCd(), dto.getProcedureCd());
        if (procedure != null) {
          dto.setProcedureName(procedure.getPricedureName());
        }

        // 文字列化
        if (sb.length() > 0) {
          sb.append(",");
        }
        sb.append(mapper.writeValueAsString(dto));

      }

      // 投薬指示情報がある場合
      if (sb.length() > 0) {
        sb.insert(0, "[");
        sb.append("]");

        resMediInfo = new String(sb);
      }

      res.setIndMediInfo(resMediInfo);

    }
    // 条件送信後の場合
    else {
      res.setKurCd(ordList.getRstKurCd());
      res.setKurName(ordList.getRstKurName());
      res.setBedCd(ordList.getRstBedCd());
      res.setBedName(ordList.getRstBedName());
      res.setDeviceMode(ordList.getRstDeviceMode());
    }

    return res;
  }

  /**
   * チェックリストマスタ情報取得
   * {@inheritDoc}
   */
  @Override
  public MstChecklist getMstChecklistByChecklistCd(Long checklistCd) {
    // チェックリストマスタ情報作成
    MstChecklist list = mstChecklistDao.selectByChecklistCd(SelectOptions.get(), checklistCd);
    return list;
  }

  /**
   * ダイアライザマスタ情報取得
   * {@inheritDoc}
   */
  @Override
  public List<MstDialyzer> getDialyzerList(List<Integer> dialyzerList) {
    // ダイアライザリスト情報作成
    List<MstDialyzer> list = mstDialyzerDao.selectAllByCdList(SelectOptions.get(), dialyzerList);
    return list;
  }

  /**
   * 薬剤マスタ情報取得
   * {@inheritDoc}
   */
  @Override
  public List<MstMedicine> getMedicineList(List<Integer> medicineList) {
    // 薬剤リスト情報作成
    List<MstMedicine> list = mstMedicineDao.selectAllByCdList(SelectOptions.get(), medicineList);
    return list;
  }

  /**
   * 調整薬剤マスタ情報取得
   * {@inheritDoc}
   */
  //  @Override
  //  public List<MstModifier> getModifierList(List<Long> modifierList) {
  //    // 調整薬剤リスト情報作成
  //    List<MstMedicine> list = mstModifierDao.selectAllByCdList(SelectOptions.get(), modifierList);
  //    return list;
  //  }

  /**
   * 医療材料マスタ情報取得
   * {@inheritDoc}
   */
  @Override
  public List<MstEquipment> getEquipList(List<Integer> equipList) {
    // 医療材料リスト情報作成
    List<MstEquipment> list = mstEquipDao.selectByCdList(SelectOptions.get(), equipList);
    return list;
  }

  /**
   * オーダー番号とリストコードからチェックリスト実績情報を取得する
   * {@inheritDoc}
   */
  @Override
  public List<OrdChecklistWithUserNameResponse> getOrdCheckListByListCd(Long ordNo, Short listCd) {

    List<OrdChecklist> ordCheckList = ordChecklistDao.selectByOrdNoListCd(SelectOptions.get(), ordNo, listCd);

    List<OrdChecklistWithUserNameResponse> res = new ArrayList<>();
    for (OrdChecklist ordCheck : ordCheckList) {

      // 応答用スケジュール情報作成
      OrdChecklistWithUserNameResponse r = new OrdChecklistWithUserNameResponse();
      r.setOrdChecklist(ordCheck);

      // 実施者名取得
      String userName = null;
      Long staffcd = ordCheck.getRegStaffInfo().getRegStaffCd();
      if (staffcd != null) {
        userName = mstPersonalUserDao.selectUserNameById(ordCheck.getRegStaffInfo().getRegStaffCd());
      }
      r.setUserName(userName);

      res.add(r);
    }
    return res;
  }

  /**
   * オーダー番号からチェックリスト実績(チェック済み項目数, 項目数)情報を取得する
   * {@inheritDoc}
   */
  @Override
  public List<List<Long>> getOrdCheckListByOrdNo(Long ordNo) {

    List<List<Long>> res = new ArrayList<>();
    Long checklistCd = null;
    for (int i = 1; i <= 8; i++) {
      Short listCd = Short.parseShort(Integer.toString(i));
      List<OrdChecklist> ordCheckList = ordChecklistDao.selectByOrdNoListCd(SelectOptions.get(), ordNo, listCd);

      if (ordCheckList.size() > 0) {
        checklistCd = ordCheckList.get(0).getRstChecklistInfo().getChecklistCd();
      }
      Long count = 0l;
      Long countall = 0l;
      for (OrdChecklist ordCheck : ordCheckList) {
        countall++;
        if (ordCheck.getIsCheck().equals(FlagType.FLAG_ON)) {
          count++;
        }

      }
      List<Long> listres = new ArrayList<>();
      // チェック済み項目数
      listres.add(count);
      // 全項目数セット
      listres.add(countall);
      res.add(listres);
    }
    // 先頭にチェックリストコードを追記
    List<Long> listres = new ArrayList<>();
    listres.add(checklistCd);
    res.add(0, listres);
    return res;
  }

  /**
   * チェックリスト実績更新
   */
  @Override
  @Transactional
  //mod #283:仮想端末チェックリストを操作すると通信が切れる 劉 start
  //public ChecklistUpdateResponse ordChecklistUpdate(List<OrdChecklist> param, String facilityCd) throws IOException {
  public ChecklistUpdateResponse ordChecklistUpdate(Short send_flg, List<OrdChecklist> param, String facilityCd) throws IOException {
  //mod #283:仮想端末チェックリストを操作すると通信が切れる 劉 end

    // 応答用
    ChecklistUpdateResponse res = new ChecklistUpdateResponse();
    //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
    //    // 登録失敗用
    //    StringBuilder errsb = new StringBuilder();
    //
    //    // 最新のチェックリストマスタのチェックリストコード取得
    //    List<MstChecklist> mstChecklist = mstChecklistDao.selectByFacilityCd(SelectOptions.get(), facilityCd, "0");
    //    Long nowChecklistCd = mstChecklist.get(0).getChecklistCd();
    //
    //    for (OrdChecklist ordCheck : param) {
    //
    //      // 最新の実績取得
    //      OrdChecklist nowdata = ordChecklistDao.selectUpdateInfo(ordCheck);
    //
    //      // 条件送信前でチェックリストコードが最新のチェックリストコードと一致しないまたは
    //      // 最新の実績情報が存在しないまたは
    //      // 最新の実績情報のチェックリスト管理番号と登録データのチェックリスト管理番号が一致するかつ更新日時が同じ場合
    //      if ((ordCheck.getChecklistCtlNo() == null
    //        && !Objects.equals(ordCheck.getRstChecklistInfo().getChecklistCd(), nowChecklistCd)) ||
    //        nowdata == null ||
    //        (ordCheck.getChecklistCtlNo().equals(nowdata.getChecklistCtlNo())
    //          && ordCheck.getUpDate().equals(nowdata.getUpDate()))) {
    //
    //        // 条件送信前の新規登録
    //        if (ordCheck.getChecklistCtlNo() == null) {
    //          // 新規登録の場合(ここでfacility_cdをセットする)
    //          //add #283:仮想端末チェックリストを操作すると通信が切れる 劉 start
    //          ordCheck.setRstClass((short) 0);
    //          //add #283:仮想端末チェックリストを操作すると通信が切れる 劉 end
    //          ordCheck.setFacilityCd(facilityCd);
    //          ordChecklistDao.insert(ordCheck);
    //
    //        } else {
    //
    //          // 更新前のデータがある場合
    //          if (nowdata != null) {
    //            // 更新前の表示フラグと削除フラグを更新
    //            //mod #283:仮想端末チェックリストを操作すると通信が切れる 劉 start
    //            //OrdChecklist deldata = nowdata;
    //            //deldata.setIsDel(FlagType.FLAG_ON);
    //            //deldata.setIsDisp(FlagType.FLAG_OFF);
    //            //ordChecklistDao.update(deldata);
    //            if (0 == send_flg) {
    //              // 条件送信前
    //              ordChecklistDao.delete(nowdata);
    //            } else {
    //              // 条件送信後
    //              OrdChecklist moddata = ordCheck;
    //              moddata.setRstClass((short) 1);
    //              ordChecklistDao.update(moddata);
    //            }
    //            //mod #283:仮想端末チェックリストを操作すると通信が切れる 劉 end
    //          }
    //
    //          // 条件送信前のチェックOFF以外の場合
    //          if (!(ordCheck.getRstClass() == 0 && ordCheck.getIsCheck().equals("0"))) {
    //            // 更新データを新規登録
    //            //mod #283:仮想端末チェックリストを操作すると通信が切れる 劉 start
    //            if (0 == send_flg) {
    //              ordCheck.setRstClass((short) 0);
    //              ordCheck.setChecklistCtlNo(null);
    //              ordChecklistDao.insert(ordCheck);
    //            }
    //            //mod #283:仮想端末チェックリストを操作すると通信が切れる 劉 end
    //          }
    //        }
    //      } else {
    //        // 登録できない場合
    //        // エラー情報作成
    //        if (errsb.length() > 0) {
    //          errsb.append(",");
    //        }
    //        errsb.append(mapper.writeValueAsString(ordCheck));
    //      }
    //
    //    }
    //
    //    // 登録失敗情報がある場合
    //    if (errsb.length() > 0) {
    //      errsb.insert(0, "[");
    //      errsb.append("]");
    //      res.errorDataList = new String(errsb);
    //    }

    // 最新のチェックリストマスタのチェックリストコード取得
    List<MstChecklist> mstChecklist = mstChecklistDao.selectByFacilityCd(SelectOptions.get(), facilityCd, "0");

    for (OrdChecklist ordCheck : param) {

      // 最新の実績取得
      OrdChecklist nowdata = null;
      if (ordCheck.getFuncClass() == 0) {
        nowdata = ordChecklistDao.selectUpdateInfoForFuncClass0(ordCheck);
      } else {
        nowdata = ordChecklistDao.selectUpdateInfo(ordCheck);
      }

      // add #12270 【因島】ord_checklist.reg_date、up_dateを登録していない処理がある。 関 start
      // mod #12691 チェックリストが済みに出来ない fang start
      Timestamp upDate = new Timestamp(System.currentTimeMillis());
      // mod #12691 チェックリストが済みに出来ない fang end
      // add #12270 【因島】ord_checklist.reg_date、up_dateを登録していない処理がある。 関 end

      // 条件送信前の場合
      // 更新前データのチェックリスト管理番号が存在しない場合
      // 実績データが存在しない場合
      // 更新前データ「実施状態：（１：実施済み）」
      if (0 == send_flg &&
        ordCheck.getChecklistCtlNo() == null &&
        nowdata == null &&
        ordCheck.getIsCheck().equals("1")) {

        // add #12270 【因島】ord_checklist.reg_date、up_dateを登録していない処理がある。 関 start
        ordCheck.setRegDate(new Timestamp(System.currentTimeMillis()));
        // add #12691 チェックリストが済みに出来ない fang start
        ordCheck.setUpDate(upDate);
        // add #12691 チェックリストが済みに出来ない fang end
        // add #12270 【因島】ord_checklist.reg_date、up_dateを登録していない処理がある。 関 end
        ordCheck.setRstClass((short) 0);
        ordCheck.setFacilityCd(facilityCd);
        ordChecklistDao.insert(ordCheck);
      }

      // 条件送信前の場合
      // 更新前データのチェックリスト管理番号が存在する場合
      // 実績データが存在する場合
      // 実績データ「実施状態：（１：実施済み）」
      // 更新前データ「実施状態：（０：未実施）」
      if (0 == send_flg &&
        ordCheck.getChecklistCtlNo() != null &&
        nowdata != null &&
        nowdata.getIsCheck().equals("1") &&
        ordCheck.getIsCheck().equals("0")) {

        ordChecklistDao.delete(nowdata);
      }
      // 条件送信以降の場合
      // 更新前データのチェックリスト管理番号が存在する場合
      // 実績データが存在する場合
      //  mod 9324 ????患者のチェックリストが不正 関  start
      // if (1 == send_flg &&
      //  ordCheck.getChecklistCtlNo() == null &&
      //  nowdata != null) {
      if (1 == send_flg &&
        ordCheck.getChecklistCtlNo() != null &&
        nowdata != null) {

        ordChecklistDao.update(ordCheck);
      }
      //  mod 9324 ????患者のチェックリストが不正 関  end

      // 条件送信前の場合
      // 更新前データのチェックリスト管理番号が存在する場合
      if (0 == send_flg &&
        ordCheck.getChecklistCtlNo() != null &&
        nowdata != null) {

        ordChecklistDao.update(ordCheck);
      }
    }
    //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end
    return res;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<MstPersonalUser> getMstPersonalUser(String facilityCd) {
    // スタッフリスト情報作成
    List<MstPersonalUser> list = mstPersonalUserDao.selectAll(SelectOptions.get(), facilityCd, "0");
    return list;
  }

  /**
   * 投与薬剤実績更新
   */
  @Override
  @Transactional
  public MediUpdateResponse ordMainMediInfoUpdate(OrdMain param) throws IOException {

    // 応答用
    MediUpdateResponse res = new MediUpdateResponse();

    // 最新のord_main rst_medi_info取得
    OrdMainForCheckListSchedule ordList = ordMainDao.selectByOrdNoChecklist(param.getOrdNo());
    // 登録内容作成用
    StringBuilder sb = new StringBuilder();
    // 登録失敗用
    StringBuilder errsb = new StringBuilder();
    String resErrInfo = null;

    // 最新の投薬情報
    String mediInfo = ordList.getRstMediInfo();
    List<RstMediInfoDto> rstMedilist = mediInfo == null || mediInfo.isEmpty() ? new ArrayList<>()
        : new ObjectMapper().readValue(mediInfo, new TypeReference<List<RstMediInfoDto>>() {
        });

    // 登録内容の投薬情報
    String regMediInfo = param.getRstMediInfo();
    List<ReceiveRstMediInfoDto> regMedilist = regMediInfo == null || regMediInfo.isEmpty() ? new ArrayList<>()
        : new ObjectMapper().readValue(regMediInfo, new TypeReference<List<ReceiveRstMediInfoDto>>() {
        });

    // 最新の投薬情報
    for (RstMediInfoDto nowdata : rstMedilist) {
      // 登録内容の投薬情報
      for (ReceiveRstMediInfoDto regdata : regMedilist) {

        // 登録内容のデータと最新のデータを比較する
        if (regdata.getNo().equals(nowdata.getNo())) {
          // 編集前と最新データに変更がなければ登録
          if (regdata.getEffectFlg().equals(nowdata.getEffectFlg())
              && Objects.equals(regdata.getEffectDate(), nowdata.getEffectDate())// regdata.getEffectDate().equals(nowdata.getEffectDate()))
              && Objects.equals(regdata.getEffectUserId(), nowdata.getEffectUserId())) {
            // 登録情報セット
            nowdata.setEffectFlg(regdata.getRegEffectFlg());
            nowdata.setEffectDate(regdata.getRegEffectDate());
            nowdata.setEffectUserId(regdata.getRegEffectUserId());
            nowdata.setEffectUserUpDate(regdata.getRegEffectUserUpDate());
            if (!Objects.isNull(regdata.getRegEffectUserId())) {
              MstPersonalUser userInfo = mstPersonalUserDao.selectById(regdata.getRegEffectUserId());
              if (userInfo != null) {
                nowdata.setEffectUserFirstName(userInfo.getUserFirstName());
                nowdata.setEffectUserLastName(userInfo.getUserLastName());
              }
            }
          } else {
            // 登録できない場合
            // エラー情報作成
            if (errsb.length() > 0) {
              errsb.append(",");
            }
            errsb.append(mapper.writeValueAsString(regdata));
          }
        }
      }

      // 登録内容文字列化
      if (sb.length() > 0) {
        sb.append(",");
      }
      sb.append(mapper.writeValueAsString(nowdata));
    }

    // 登録内容がある場合
    if (sb.length() > 0) {
      sb.insert(0, "[");
      sb.append("]");

      param.setRstMediInfo(new String(sb));
    }

    // 投与薬剤実績更新
    ordMainDao.updateMediInfo(param.getOrdNo(), param.getRstMediInfo());

    // 登録失敗情報がある場合
    if (errsb.length() > 0) {
      errsb.insert(0, "[");
      errsb.append("]");
      res.errorDataList = new String(errsb);
    }

    return res;
  }

  /**
   * 条件送信時
   * チェックリスト実績作成・更新処理
   */
  @Override
  @Transactional
  public ChecklistUpdateResponse createOrdChecklistSendCondition(String facilityCd, Long ordNo) throws IOException {

    // 応答用
    ChecklistUpdateResponse res = new ChecklistUpdateResponse();
    // 登録失敗用
    StringBuilder errsb = new StringBuilder();

    // 最新のチェックリストマスタ取得
    List<MstChecklist> mstChecklist = mstChecklistDao.selectByFacilityCd(SelectOptions.get(), facilityCd, "0");
    MstChecklist nowMstChecklist = mstChecklist.get(0);
    String strSetting = nowMstChecklist.getChecklistSettings();
    ObjectMapper map = new ObjectMapper();
    JsonNode node = map.readTree(strSetting);
    // ord_mainの情報取得
    OrdMainForCheckListSchedule ordList = ordMainDao.selectByOrdNoChecklist(ordNo);
    // 登録用
    List<OrdChecklist> reglist = new ArrayList<>();

    // ord_mainに情報がない場合
    if (ordList == null) {
      res.isSuccess = false;
      res.errorMessage = ordNo.toString() + "の実績が存在しません";
      return res;
    }

    // リストコード分繰り返し
    for (int i = 0; i < node.size(); i++) {
      JsonNode setting = map.readTree(node.get(i).toString());

      // リストコード
      Short listcd = Short.parseShort(setting.get("list_cd").toString());

      JsonNode funclist = map.readTree(setting.get("funclist").toString());

      // funclist分繰り返し
      // add FNSI-条件送信特別処理 徐 start
//      for (int j = 0; j < funclist.size(); j++) {
      for (int j = funclist.size() - 1; j >= 0; j--) {
      // add FNSI-条件送信特別処理 徐 end
        JsonNode list = map.readTree(funclist.get(j).toString());

        // 機能種別(func_class)
        String strfuncclass = list.get("func_class").toString();
        Short funcClass = null;
        if (!strfuncclass.equals("null")) {
          funcClass = Short.parseShort(list.get("func_class").toString());
        }
        // 未登録の場合
        if (funcClass == null) {
          continue;
        }
        // add FNSI-条件送信特別処理 徐 start
        // 分類コード
        String strClassCode = list.get("class_cd").toString();
        if (!"null".equals(strClassCode)) {
          boolean repeatFlg = false;
          for (int k = j - 1; k >= 0; k--) {
            JsonNode listk = map.readTree(funclist.get(k).toString());
            // 機能種別
            String strfuncclassk = listk.get("func_class").toString();
            // 分類コード
            String strClassCodek = listk.get("class_cd").toString();
            if (Objects.equals(strfuncclassk, strfuncclass)
              && Objects.equals(strClassCodek, strClassCode)) {
              repeatFlg = true;
              break;
            }
          }
          if (repeatFlg) {
            continue;
          }
        }
        // add FNSI-条件送信特別処理 徐 end

        // 登録用
        OrdChecklist regdata = new OrdChecklist();
        regdata.setOrdNo(ordNo);
        regdata.setFacilityCd(facilityCd);
        regdata.setListCd(listcd);
        regdata.setFuncClass(funcClass);
        regdata.setIsCheck("0");
        regdata.setRstClass((short) 1);
        regdata.setIsDisp(FlagType.FLAG_ON);
        regdata.setIsDel(FlagType.FLAG_OFF);
        OrdChecklistRegStaffInfo regStaffInfo = new OrdChecklistRegStaffInfo();
        regdata.setRegStaffInfo(regStaffInfo);
        // チェックリスト項目情報作成用
        OrdChecklistRegCheckInfo checkinfo = new OrdChecklistRegCheckInfo();
        // checklist_cd
        checkinfo.setChecklistCd(nowMstChecklist.getChecklistCd());
        // item_number
        checkinfo.setItemNumber(Short.parseShort(list.get("item_number").toString()));
        // class_cd
        String classcode = list.get("class_cd").toString();
        Integer classcd = null;
        if (!classcode.equals("null")) {
          classcd = Integer.parseInt(list.get("class_cd").toString());
          checkinfo.setClassCd(classcd);
        }

        // 通常リストの場合
        if (Objects.equals(funcClass, (short) 0)) {

          checkinfo = settingNormalCheckList(checkinfo, list);

          // rst_checklist_info
          regdata.setRstChecklistInfo(checkinfo);

          // チェックリスト実績登録
          reglist.add(regdata);
        }
        // 治療条件の場合
        else if (Objects.equals(funcClass, (short) 1)) {

          if (classcd == null) {
            continue;
          }

          // class_cd
          List<Integer> condclasscd = new ArrayList<>();
          condclasscd.add(classcd);

          // ダイアライザの場合
          if (Objects.equals(classcd, 5)) {
            // 吸着カラムも追加
            condclasscd.add(6);

            // 一次膜・二次膜
            condclasscd.add(7);
            condclasscd.add(8);
          }
          // 吸着カラムはダイアライザと同時設定にしたので除外
          if (Objects.equals(classcd, 6)) {
            continue;
          }
          // 穿刺針の場合
          if (Objects.equals(classcd, 9)) {
            condclasscd.add(10);
            condclasscd.add(11);
          }

          // 対象の治療条件取得
          List<JSONObject> condList = getCondInfo(ordList.getIndCondInfo(), condclasscd);

          for (JSONObject cond : condList) {

            // チェックリスト項目情報作成用
            OrdChecklistRegCheckInfo condcheckinfo = checkinfo.clone();

            // code
            String strcode = cond.get("code").toString();
            Integer regcode = null;
            if (!strcode.equals("null")) {
              regcode = Integer.parseInt(cond.get("code").toString());
              condcheckinfo.setCode(regcode);
            }
            // del 10310 needle _ typeの使用を削除するには gjn start
            // needle_type
//            String strntype = cond.get("needle_type").toString();
//            if (!strntype.equals("")) {
//              Short ntype = Short.parseShort(strntype);
//              condcheckinfo.setNeedleType(ntype);
//            }
            // del 10310 needle _ typeの使用を削除するには gjn end
            // code_update
            condcheckinfo.setCodeUpdate(null);
            // name
            condcheckinfo.setName(null);

            // class_cd
            condcheckinfo.setClassCd(Integer.valueOf(cond.get("class_cd").toString()));

            // ダイアライザの場合
            if (Objects.equals(classcd, 5)) {
              if (Objects.equals(condcheckinfo.getClassCd(), 5)) {
                // ダイアライザマスタから情報取得
                condcheckinfo = settingCondDializerCheckInfo(condcheckinfo, regcode);
              } else {
                // 吸着カラム・1次膜・2次膜：医療材料から情報取得
                //mod 5556 条件送信を行った患者の数量に「NaN」と表示される zhao start
                //condcheckinfo = settingCondEquipCheckInfo(condcheckinfo, regcode, condcheckinfo.getClassCd());
                condcheckinfo = settingCondEquipCheckInfoC(condcheckinfo, regcode, condcheckinfo.getClassCd());
                //mod 5556 条件送信を行った患者の数量に「NaN」と表示される zhao end
              }
            }
            // 薬剤の場合
            else if (Objects.equals(classcd, 15) || Objects.equals(classcd, 19) || Objects.equals(classcd, 25)) {

              // 薬剤の場合
              String meditype = cond.get("medicine_type").toString();
              //add 5556 条件送信を行った患者の数量に「NaN」と表示される zhao start
                // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
                //condcheckinfo.setMedicineType(Short.parseShort(meditype));
                condcheckinfo.setMedicineType(Integer.parseInt(meditype));
                // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
                condcheckinfo.setAmount(cond.get("amount").toString());
              //add 5556 条件送信を行った患者の数量に「NaN」と表示される zhao end

              if (meditype.equals("2")) {
                // 調整薬剤場合
                //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
                //  condcheckinfo = settingCondMixMedicineCheckInfo(condcheckinfo, facilityCd, regcode,
                //     list.get("list_name").toString());
                condcheckinfo = settingCondMixMedicineCheckInfo(condcheckinfo, facilityCd, classcd, regcode,
                  list.get("list_name").toString());
                //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end
              } else if (meditype.equals("1")) {
                // 薬剤
                //mod 5556 条件送信を行った患者の数量に「NaN」と表示される zhao start
                //condcheckinfo = settingCondNormalMedicineCheckInfo(condcheckinfo, facilityCd, regcode);
                condcheckinfo = settingCondNormalMedicineCheckInfoC(condcheckinfo, facilityCd, regcode);
                //mod 5556 条件送信を行った患者の数量に「NaN」と表示される zhao end
              } else {
                // NOTE: 薬剤種別の値が異常のやつはとりあえず薬剤
                //mod 5556 条件送信を行った患者の数量に「NaN」と表示される zhao start
                //condcheckinfo = settingCondNormalMedicineCheckInfo(condcheckinfo, facilityCd, regcode);
                condcheckinfo = settingCondNormalMedicineCheckInfoC(condcheckinfo, facilityCd, regcode);
                //mod 5556 条件送信を行った患者の数量に「NaN」と表示される zhao end
              }
            }
            // 医療材料の場合
            else {
              //mod 5556 条件送信を行った患者の数量に「NaN」と表示される zhao start
              //condcheckinfo = settingCondEquipCheckInfo(condcheckinfo, regcode, classcd);
              condcheckinfo = settingCondEquipCheckInfoC(condcheckinfo, regcode, classcd);
              //mod 5556 条件送信を行った患者の数量に「NaN」と表示される zhao end
            }

            // 登録用
            OrdChecklist condregdata = regdata.clone();
            // rst_checklist_info
            condregdata.setRstChecklistInfo(condcheckinfo);
            // チェックリスト実績登録
            reglist.add(condregdata);
          }
        }
        // 医療材料の場合
        else if (Objects.equals(funcClass, (short) 2)) {

          if (classcd == null) {
            continue;
          }

          // 対象の医療材料取得
          List<OrdChecklistRegEquipInfo> equipList;

          // ダイアライザの場合
          if (Objects.equals(classcd, 0)) {


            // 対象のダイアライザ取得
            // #11589 2025.03.10 mod 引数に施設コードを追加 TDC米沢 start
            // // add FNSI-条件送信特別処理 徐 start
            // // equipList = getEquipDailyzerInfo(ordList.getIndEquipInfo(), classcd);
            // equipList = getEquipDailyzerInfo(ordList.getIndEquipInfo(), classcd, 0);
            // // add FNSI-条件送信特別処理 徐 end
            equipList = getEquipDailyzerInfo(ordList.getIndEquipInfo(), classcd, 0, facilityCd);
            // #11589 2025.03.10 mod 引数に施設コードを追加 TDC米沢 end

          } else {
            // 対象の医療材料取得
            // #11589 2025.03.10 mod 引数に施設コードを追加 TDC米沢 start
            // // add FNSI-条件送信特別処理 徐 start
            // // equipList = getEquipInfo(ordList.getIndEquipInfo(), classcd);
            // equipList = getEquipInfo(ordList.getIndEquipInfo(), classcd, 0);
            // // add FNSI-条件送信特別処理 徐 end
             equipList = getEquipInfo(ordList.getIndEquipInfo(), classcd, 0, facilityCd);
            // #11589 2025.03.10 mod 引数に施設コードを追加 TDC米沢 end
          }

          for (OrdChecklistRegEquipInfo equip : equipList) {

            // チェックリスト項目情報作成用
            OrdChecklistRegCheckInfo equipcheckinfo = settingEquipCheckInfo(checkinfo, equip);

            // 登録用
            OrdChecklist equipregdata = regdata.clone();
            // rst_checklist_info
            equipregdata.setRstChecklistInfo(equipcheckinfo);
            // add FNSI-条件送信特別処理 徐 start
            if (equip.getRstClassFlg() == 9) {
              Short setRstClass = 9;
              equipregdata.setRstClass(setRstClass);
            }
            // add FNSI-条件送信特別処理 徐 end
            // チェックリスト実績登録
            reglist.add(equipregdata);
          }
        }
        // add FNSI-条件送信特別処理 徐 start
        // 投与薬剤の場合
        else if (Objects.equals(funcClass, (short) 3)) {
          if (classcd == null) {
            continue;
          }
          // 対象の薬剤取得
          List<OrdChecklistRegEquipInfo> equipList = getIndMediInfo(ordList.getIndMediInfo(), classcd, facilityCd);

          for (OrdChecklistRegEquipInfo equip : equipList) {
            // チェックリスト項目情報作成用
            OrdChecklistRegCheckInfo equipcheckinfo = settingEquipCheckInfo(checkinfo, equip);
            // 登録用
            OrdChecklist equipregdata = regdata.clone();
            // rst_checklist_info
            equipregdata.setRstChecklistInfo(equipcheckinfo);
            if (equip.getRstClassFlg() == 9) {
              Short setRstClass = 9;
              equipregdata.setRstClass(setRstClass);
            }
            // チェックリスト実績登録
            reglist.add(equipregdata);
          }
        }
        // add FNSI-条件送信特別処理 徐 end
      }

    }
    // 指定ordNoのチェックリスト実績取得
    List<OrdChecklist> nowdata = ordChecklistDao.selectByOrdNo(SelectOptions.get(), ordNo);

    for (int i = 0; i < reglist.size(); i++) {
      Boolean regflg = true;
      for (int j = 0; j < nowdata.size(); j++) {
        // 既に登録されている場合
        if (Objects.equals(reglist.get(i).getListCd(), nowdata.get(j).getListCd()) &&
            Objects.equals(reglist.get(i).getFuncClass(), nowdata.get(j).getFuncClass()) &&
            Objects.equals(reglist.get(i).getRstChecklistInfo().getItemNumber(),
                nowdata.get(j).getRstChecklistInfo().getItemNumber())
            &&
            Objects.equals(reglist.get(i).getRstChecklistInfo().getClassCd(),
                nowdata.get(j).getRstChecklistInfo().getClassCd())
            &&
            Objects.equals(reglist.get(i).getRstChecklistInfo().getCode(),
                nowdata.get(j).getRstChecklistInfo().getCode())
          // del 10310 needle _ typeの使用を削除するには gjn start
//            &&
//            Objects.equals(reglist.get(i).getRstChecklistInfo().getNeedleType(),
//                nowdata.get(j).getRstChecklistInfo().getNeedleType())
          // del 10310 needle _ typeの使用を削除するには gjn end
        ) {
          // 登録しない
          regflg = false;
        }
      }

      // 未登録の実績のみ
      if (regflg) {
        // 実績作成
        ordChecklistDao.insert(reglist.get(i));
      }
    }

    // 実績区分に条件送信済みをセット
    ordChecklistDao.updateSendConditionByRstClass(ordNo);

    res.isSuccess = true;
    return res;

  }

  // add FNSI-バグ 通信サーバ 劉 start
  /**
   * ????患者生成
   * チェックリスト実績作成・更新処理
   */
  @Override
  @Transactional
  public ChecklistUpdateResponse createOrdChecklistUnregistered(String facilityCd, Long ordNo) throws IOException {

    // 応答用
    ChecklistUpdateResponse res = new ChecklistUpdateResponse();

    // 最新のチェックリストマスタ取得
    List<MstChecklist> mstChecklist = mstChecklistDao.selectByFacilityCd(SelectOptions.get(), facilityCd, "0");
    MstChecklist nowMstChecklist = mstChecklist.get(0);
    String strSetting = nowMstChecklist.getChecklistSettings();
    ObjectMapper map = new ObjectMapper();
    JsonNode node = map.readTree(strSetting);
    // 登録用
    List<OrdChecklist> reglist = new ArrayList<>();

    // リストコード分繰り返し
    for (int i = 0; i < node.size(); i++) {
      JsonNode setting = map.readTree(node.get(i).toString());

      // リストコード
      Short listcd = Short.parseShort(setting.get("list_cd").toString());

      JsonNode funclist = map.readTree(setting.get("funclist").toString());

      // funclist分繰り返し
      for (int j = funclist.size() - 1; j >= 0; j--) {
        JsonNode list = map.readTree(funclist.get(j).toString());

        // 機能種別(func_class)
        String strfuncclass = list.get("func_class").toString();
        Short funcClass = null;
        if (!strfuncclass.equals("null")) {
          funcClass = Short.parseShort(list.get("func_class").toString());
        }
        // 未登録の場合
        if (funcClass == null) {
          continue;
        }
        // 分類コード
        String strClassCode = list.get("class_cd").toString();

        boolean repeatFlg = false;
        for (int k = j - 1; k >= 0; k--) {
          JsonNode listk = map.readTree(funclist.get(k).toString());
          // 機能種別
          String strfuncclassk = listk.get("func_class").toString();
          // 分類コード
          String strClassCodek = listk.get("class_cd").toString();
          if (Objects.equals(strfuncclassk, strfuncclass)
            && Objects.equals(strClassCodek, strClassCode)) {
            repeatFlg = true;
            break;
          }
        }
        if (repeatFlg) {
          continue;
        }

        // 登録用
        OrdChecklist regdata = new OrdChecklist();
        regdata.setOrdNo(ordNo);
        regdata.setFacilityCd(facilityCd);
        regdata.setListCd(listcd);
        regdata.setFuncClass(funcClass);
        regdata.setIsCheck("0");
        regdata.setRstClass((short) 9);
        regdata.setIsDisp(FlagType.FLAG_ON);
        regdata.setIsDel(FlagType.FLAG_OFF);
        OrdChecklistRegStaffInfo regStaffInfo = new OrdChecklistRegStaffInfo();
        regdata.setRegStaffInfo(regStaffInfo);
        // チェックリスト項目情報作成用
        OrdChecklistRegCheckInfo checkinfo = new OrdChecklistRegCheckInfo();
        // checklist_cd
        checkinfo.setChecklistCd(nowMstChecklist.getChecklistCd());
        // item_number
        checkinfo.setItemNumber(Short.parseShort(list.get("item_number").toString()));
        // class_cd
        Integer classcd = null;
        if (!strClassCode.equals("null")) {
          classcd = Integer.parseInt(strClassCode);
          checkinfo.setClassCd(classcd);
        }
        // name
        String listname = list.get("list_name").toString().replaceAll("\"", "");
        checkinfo.setName(listname);
        // rst_checklist_info
        regdata.setRstChecklistInfo(checkinfo);
        // チェックリスト実績登録
        reglist.add(regdata);
      }
    }
    // 指定ordNoのチェックリスト実績取得
    List<OrdChecklist> nowdata = ordChecklistDao.selectByOrdNo(SelectOptions.get(), ordNo);

    for (int i = 0; i < reglist.size(); i++) {
      Boolean regflg = true;
      for (int j = 0; j < nowdata.size(); j++) {
        // 既に登録されている場合
        if (Objects.equals(reglist.get(i).getListCd(), nowdata.get(j).getListCd()) &&
          Objects.equals(reglist.get(i).getFuncClass(), nowdata.get(j).getFuncClass()) &&
          Objects.equals(reglist.get(i).getRstChecklistInfo().getItemNumber(),
            nowdata.get(j).getRstChecklistInfo().getItemNumber())
          &&
          Objects.equals(reglist.get(i).getRstChecklistInfo().getClassCd(),
            nowdata.get(j).getRstChecklistInfo().getClassCd())
          &&
          Objects.equals(reglist.get(i).getRstChecklistInfo().getCode(),
            nowdata.get(j).getRstChecklistInfo().getCode())
          // del 10310 needle _ typeの使用を削除するには gjn start
//          &&
//          Objects.equals(reglist.get(i).getRstChecklistInfo().getNeedleType(),
//            nowdata.get(j).getRstChecklistInfo().getNeedleType())
          // del 10310 needle _ typeの使用を削除するには gjn end
        ) {
          // 登録しない
          regflg = false;
        }
      }

      // 未登録の実績のみ
      if (regflg) {
        // 実績作成
        ordChecklistDao.insert(reglist.get(i));
      }
    }

    // 実績区分に条件送信済みをセット
    ordChecklistDao.updateSendConditionByRstClass(ordNo);

    res.isSuccess = true;
    return res;
  }
  // add FNSI-バグ 通信サーバ 劉 end

  /**
   * ダイアライザー用チェックリスト項目作成
   * @param condcheckinfo
   * @param regcode
   * @return
   */
  private OrdChecklistRegCheckInfo settingCondDializerCheckInfo(OrdChecklistRegCheckInfo condcheckinfo,
      Integer regcode) {
    // ダイアライザマスタから情報取得
    MstDialyzer dialdata = mstDialyzerDao.selectByDialyzerCd(SelectOptions.get(), regcode);

    if (dialdata != null) {
      // code_update
      String strdate = DateTimeUtils.getDateString_iso8601(dialdata.getUpDate());
      condcheckinfo.setCodeUpdate(strdate);
      // name
      condcheckinfo.setName(dialdata.getModelNumber());
      // amount
      condcheckinfo.setAmount("1");
      // unit
      condcheckinfo.setUnit("本");
      //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
      condcheckinfo.setEquipType(1);
      //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end
    }
    return condcheckinfo;
  }

  /**
   * 通常薬剤用チェックリスト項目作成
   * @param condcheckinfo
   * @param facilityCd
   * @param regcode
   * @return
   */
  //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
  //  private OrdChecklistRegCheckInfo settingCondNormalMedicineCheckInfo(OrdChecklistRegCheckInfo condcheckinfo,
  //                                                                      String facilityCd, Integer regcode) {
  private OrdChecklistRegCheckInfo settingCondNormalMedicineCheckInfo(OrdChecklistRegCheckInfo condcheckinfo,
      String facilityCd, Integer classcd, Integer regcode) {
    //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end
    // 薬剤マスタから情報取得
    MstMedicine medidata = mstMedicineDao.selectByCd(facilityCd, regcode);

    if (medidata != null) {
      // code_update
      String strdate = DateTimeUtils.getDateString_iso8601(medidata.getUpDate());
      condcheckinfo.setCodeUpdate(strdate);
      // name
      condcheckinfo.setName(medidata.getMedicineName());
      //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
      condcheckinfo.setMedicineType(1);
      // 治療条件の場合
      if (Objects.equals(classcd, 15) || Objects.equals(classcd, 19)) {
        // 透析液、補液：薬剤マスタ.レセ単位
        // unit
        condcheckinfo.setUnit(medidata.getUnitSecond());
      } else if (Objects.equals(classcd, 25)) {
        // 抗凝固剤：薬剤マスタ.指示単位
        // unit
        condcheckinfo.setUnit(medidata.getUnit());
      } else {
        // その他薬剤：薬剤マスタ.指示単位
        // unit
        condcheckinfo.setUnit(medidata.getUnit());
      }
      //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end
    }
    return condcheckinfo;
  }
  private OrdChecklistRegCheckInfo settingIndCondNormalMedicineCheckInfo(OrdChecklistRegCheckInfo condcheckinfo,
                                                                      String facilityCd, Integer classcd, Integer regcode, BigDecimal amount) {
    // 薬剤マスタから情報取得
    MstMedicine medidata = mstMedicineDao.selectByCd(facilityCd, regcode);

    if (medidata != null) {
      // code_update
      String strdate = DateTimeUtils.getDateString_iso8601(medidata.getUpDate());
      condcheckinfo.setCodeUpdate(strdate);
      // name
      condcheckinfo.setName(medidata.getMedicineName());
      condcheckinfo.setMedicineType(1);
      int unitDecimalPoint = 0;
      if (medidata.getUnitDecimalPoint() != null) {
        unitDecimalPoint = medidata.getUnitDecimalPoint();
      }

      condcheckinfo.setAmount(amount == null
        ? null
        : amount.setScale(unitDecimalPoint, RoundingMode.HALF_UP).toPlainString());
      // 治療条件の場合
      if (Objects.equals(classcd, 15) || Objects.equals(classcd, 19)) {
        // 透析液、補液：薬剤マスタ.レセ単位
        // unit
        condcheckinfo.setUnit(medidata.getUnitSecond());
      } else if (Objects.equals(classcd, 25)) {
        // 抗凝固剤：薬剤マスタ.指示単位
        // unit
        condcheckinfo.setUnit(medidata.getUnit());
      } else {
        // その他薬剤：薬剤マスタ.指示単位
        // unit
        condcheckinfo.setUnit(medidata.getUnit());
      }
    }
    return condcheckinfo;
  }
  //add 5556 条件送信を行った患者の数量に「NaN」と表示される zhao start
  private OrdChecklistRegCheckInfo settingCondNormalMedicineCheckInfoC(OrdChecklistRegCheckInfo condcheckinfo,
                                                                      String facilityCd, Integer regcode) {
    // 薬剤マスタから情報取得
    MstMedicine medidata = mstMedicineDao.selectByCd(facilityCd, regcode);

    if (medidata != null) {
      // code_update
      String strdate = DateTimeUtils.getDateString_iso8601(medidata.getUpDate());
      condcheckinfo.setCodeUpdate(strdate);
      // name
      condcheckinfo.setName(medidata.getMedicineName());
      //add 5556 条件送信を行った患者の数量に「NaN」と表示される zhao start
      if(Objects.equals(condcheckinfo.getClassCd(), 15) || Objects.equals(condcheckinfo.getClassCd(), 19)){
        condcheckinfo.setUnit(medidata.getUnitSecond());
      }else if(Objects.equals(condcheckinfo.getClassCd(), 25)){
        condcheckinfo.setUnit(medidata.getUnit());
      }else{
        condcheckinfo.setUnit(medidata.getUnit());
      }

      //add 5556 条件送信を行った患者の数量に「NaN」と表示される zhao end
    }
    return condcheckinfo;
  }
  //add 5556 条件送信を行った患者の数量に「NaN」と表示される zhao end
  /**
   * 調製薬剤用のチェックリスト項目構築
   * @param condcheckinfo
   * @param regcode
   * @param listName
   * @return
   */
  //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
  //  private OrdChecklistRegCheckInfo settingCondMixMedicineCheckInfo(OrdChecklistRegCheckInfo condcheckinfo,
  //                                                                   String facilityCd, Integer regcode, String listName) {
  private OrdChecklistRegCheckInfo settingCondMixMedicineCheckInfo(OrdChecklistRegCheckInfo condcheckinfo,
      String facilityCd, Integer classcd, Integer regcode, String listName) {
    //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end
    // 調整薬剤マスタから情報取得
    MstMedicineMix medidata = mstMedicineMixDao.selectByCd(facilityCd, regcode);
    if (medidata != null) {
      // code_update
      //      condcheckinfo.setCodeUpdate(null);
      String strdate = DateTimeUtils.getDateString_iso8601(medidata.getUpDate());
      condcheckinfo.setCodeUpdate(strdate);
      // name
      //      condcheckinfo.setName(listName);
      condcheckinfo.setName(medidata.getMedicineMixName());
      //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
      condcheckinfo.setMedicineType(2);
      if (Objects.equals(classcd, 15) || Objects.equals(classcd, 19)) {
        // 透析液、補液：ml（固定）
        // unit
        condcheckinfo.setUnit("ml");
      } else if (Objects.equals(classcd, 25)) {
        // 抗凝固剤：調製薬剤マスタ.指示単位
        // unit
        condcheckinfo.setUnit(medidata.getUnit());
      } else {
        // その他薬剤：調製薬剤マスタ.指示単位
        // unit
        condcheckinfo.setUnit(medidata.getUnit());
      }
      //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end
    }
    return condcheckinfo;
  }
  /**
   * 調製薬剤用のチェックリスト項目構築
   * @param condcheckinfo
   * @param regcode
   * @return
   */
  private OrdChecklistRegCheckInfo settingIndCondMixMedicineCheckInfo(OrdChecklistRegCheckInfo condcheckinfo,
                                                                   String facilityCd, Integer classcd, Integer regcode, BigDecimal amount) {
    // 調整薬剤マスタから情報取得
    MstMedicineMix medidata = mstMedicineMixDao.selectByCd(facilityCd, regcode);
    if (medidata != null) {
      // code_update
      String strdate = DateTimeUtils.getDateString_iso8601(medidata.getUpDate());
      condcheckinfo.setCodeUpdate(strdate);
      // name
      condcheckinfo.setName(medidata.getMedicineMixName());

      int unitDecimalPoint = 0;
      if (medidata.getUnitDecimalPoint() != null) {
        unitDecimalPoint = medidata.getUnitDecimalPoint();
      }

      condcheckinfo.setAmount(amount == null
        ? null
        : amount.setScale(unitDecimalPoint, RoundingMode.HALF_UP).toPlainString());

      condcheckinfo.setMedicineType(2);
      if (Objects.equals(classcd, 15) || Objects.equals(classcd, 19)) {
        // 透析液、補液：ml（固定）
        // unit
        condcheckinfo.setUnit("ml");
      } else if (Objects.equals(classcd, 25)) {
        // 抗凝固剤：調製薬剤マスタ.指示単位
        // unit
        condcheckinfo.setUnit(medidata.getUnit());
      } else {
        // その他薬剤：調製薬剤マスタ.指示単位
        // unit
        condcheckinfo.setUnit(medidata.getUnit());
      }
    }
    return condcheckinfo;
  }

  /**
   * 治療条件の医療材料チェックリスト構築
   * @param condcheckinfo
   * @param regcode
   * @param classcd
   * @return
   */
  private OrdChecklistRegCheckInfo settingCondEquipCheckInfo(OrdChecklistRegCheckInfo condcheckinfo, Integer regcode,
      Integer classcd) {

    // 医療材料マスタから情報取得
    MstEquipment equipdata = mstEquipDao.selectByEquipmentCd(regcode);

    if (equipdata != null) {
      // code_update
      String strdate = DateTimeUtils.getDateString_iso8601(equipdata.getUpDate());
      condcheckinfo.setCodeUpdate(strdate);
      // name
      condcheckinfo.setName(equipdata.getEquipmentName());

      // 穿刺針の場合
      if (Objects.equals(classcd, 9) || Objects.equals(classcd, 10) || Objects.equals(classcd, 11)) {
        // amount
        condcheckinfo.setAmount("1");
        // unit
        condcheckinfo.setUnit("本");
      }
      //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
      // amount
      condcheckinfo.setAmount("1");
      // unit
      condcheckinfo.setUnit(equipdata.getUnit());

      condcheckinfo.setEquipType(0);
      //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end
    }

    return condcheckinfo;
  }

  //add 5556 条件送信を行った患者の数量に「NaN」と表示される zhao start
  private OrdChecklistRegCheckInfo settingCondEquipCheckInfoC(OrdChecklistRegCheckInfo condcheckinfo, Integer regcode,
                                                              Integer classcd) {

    // 医療材料マスタから情報取得
    MstEquipment equipdata = mstEquipDao.selectByEquipmentCd(regcode);

    if (equipdata != null) {
      // code_update
      String strdate = DateTimeUtils.getDateString_iso8601(equipdata.getUpDate());
      condcheckinfo.setCodeUpdate(strdate);
      // name
      condcheckinfo.setName(equipdata.getEquipmentName());
      condcheckinfo.setAmount("1");
      condcheckinfo.setUnit(equipdata.getUnit());
      // 穿刺針の場合
      if (Objects.equals(classcd, 9) || Objects.equals(classcd, 10) || Objects.equals(classcd, 11)) {
        // amount
        condcheckinfo.setAmount("1");
        // unit
        condcheckinfo.setUnit("本");
      }
    }

    return condcheckinfo;
  }
  //add 5556 条件送信を行った患者の数量に「NaN」と表示される zhao end

  /**
   * 医療材料のチェックリスト項目作成
   * @param checkinfo
   * @param equip
   * @return
   */
  private OrdChecklistRegCheckInfo settingEquipCheckInfo(OrdChecklistRegCheckInfo checkinfo,
      OrdChecklistRegEquipInfo equip) {

    OrdChecklistRegCheckInfo equipcheckinfo = checkinfo.clone();

    // code
    Integer regcode = equip.getCode();
    equipcheckinfo.setCode(regcode);
    // del 10310 needle _ typeの使用を削除するには gjn start
    // needle_type
    //equipcheckinfo.setNeedleType(equip.getNeedleType());
    // del 10310 needle _ typeの使用を削除するには gjn end

    // code_update
    String strdate = DateTimeUtils.getDateString_iso8601(equip.getCodeUpdate());
    equipcheckinfo.setCodeUpdate(strdate);
    // name
    equipcheckinfo.setName(equip.getName());
    // amount
    equipcheckinfo.setAmount(equip.getAmount());
    // unit
    equipcheckinfo.setUnit(equip.getUnit());

    //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
    equipcheckinfo.setEquipType(equip.getEquipEype());

    equipcheckinfo.setMedicineNo(equip.getMedicineNo() != null ? equip.getMedicineNo().toString() : null);

    equipcheckinfo.setMedicineType(equip.getMedicineEype());
    //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end

    return equipcheckinfo;
  }

  /**
   * 通常リスト用のチェックリスト作成
   * @param checkinfo
   * @param list
   * @return
   */
  private OrdChecklistRegCheckInfo settingNormalCheckList(OrdChecklistRegCheckInfo checkinfo, JsonNode list) {

    // code
    checkinfo.setCode(null);
    // code_update
    checkinfo.setCodeUpdate(null);
    // name
    String listname = list.get("list_name").asText();
    checkinfo.setName(listname);
    // del 10310 needle _ typeの使用を削除するには gjn start
    // needle_type
    //checkinfo.setNeedleType(null);
    // del 10310 needle _ typeの使用を削除するには gjn end
    // amount
    checkinfo.setAmount(null);
    // unit
    checkinfo.setUnit(null);

    return checkinfo;
  }

  // 対象の治療条件情報取得
  List<JSONObject> getCondInfo(String info, List<Integer> codelist) {

    // 応答用
    List<JSONObject> res = new ArrayList<>();

    // 治療条件指示がない場合
    if (info == null) {
      return res;
    }
// del 10310 needle _ typeの使用を削除するには gjn start
    // 穿刺針種類
//    HashMap<Integer, Integer> needleType_cond = new HashMap<Integer, Integer>();
//    needleType_cond.put(9, 1);
//    needleType_cond.put(10, 2);
//    needleType_cond.put(11, 3);
// del 10310 needle _ typeの使用を削除するには gjn end
    try {
      // 治療条件指示リスト
      ObjectMapper map = new ObjectMapper();
      JsonNode condlist = map.readTree(info);

      for (Integer code : codelist) {

        JSONObject obj = new JSONObject();

        // class_cdがある場合
        if (!Objects.isNull(code)) {

          // 対象の治療条件
          JsonNode condinfo = condlist.has(code.toString()) ? condlist.get(code.toString()) : null;
          JsonNode value = Objects.isNull(condinfo) ? null : condinfo.get("value");
          // mod #10101 条件送信後にチェックリストが0件になる dou start
          // String strval = Objects.isNull(value) ? "null" : value.toString();
          String strval = Objects.isNull(value) ? "null" : value.asText();
          // mod #10101 条件送信後にチェックリストが0件になる dou end
          // 対象の治療条件がある場合
          if (!Objects.isNull(condinfo) && !strval.equals("null")) {
// del 10310 needle _ typeの使用を削除するには gjn start
            // 穿刺針種別
//            String ntype = "";
//            // 穿刺針の場合
//            if (!Objects.isNull(needleType_cond.get(code))) {
//              ntype = needleType_cond.get(code).toString();
//            }
// del 10310 needle _ typeの使用を削除するには gjn end

            // mod #10101 条件送信後にチェックリストが0件になる dou start
            // obj.put("code", condinfo.get("value"));
            obj.put("code", condinfo.get("value").asText());
            // mod #10101 条件送信後にチェックリストが0件になる dou end

            // add #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
            if (condinfo.has("medicine_type")) {
              // add #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
              String strmtype = condinfo.get("medicine_type").asText();
              // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
              //Short mtype = null;
              Integer mtype = null;
              // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
              if (!strmtype.equals("null")) {
                // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
                //mtype = Short.parseShort(strmtype);
                mtype = Integer.parseInt(strmtype);
                // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
                obj.put("medicine_type", mtype);
              } else {
                // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
                //obj.put("medicine_type", strmtype);
                obj.put("medicine_type", JSONObject.NULL);
                // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
              }
            }
            // del 10310 needle _ typeの使用を削除するには gjn start
            //obj.put("needle_type", ntype);
            // del 10310 needle _ typeの使用を削除するには gjn end
            obj.put("class_cd", code);
            //add 5556 条件送信を行った患者の数量に「NaN」と表示される zhao start
            if(25==code){
//              JsonNode condinfoCount = condlist.has("26") ? condlist.get("26") : null;
//              JsonNode amount = Objects.isNull(condinfoCount) ? null : condinfoCount.get("value");
//              String amountRe = amount.toString().replace("\"","");
              //JsonNode unit = Objects.isNull(condinfoCount) ? null : condinfoCount.get("unit");
              obj.put("amount", (
                condlist.hasNonNull(TreatmentItemsDef.T_I_ANTICOAGULANT_ONESHOT_AMOUNT.getItemCode())
                && condlist.get(TreatmentItemsDef.T_I_ANTICOAGULANT_ONESHOT_AMOUNT.getItemCode()).hasNonNull("value")
              ) ? condlist.get(TreatmentItemsDef.T_I_ANTICOAGULANT_ONESHOT_AMOUNT.getItemCode()).get("value").asText()
                : TreatmentItemsDef.getDefaultValue(TreatmentItemsDef.T_I_ANTICOAGULANT_ONESHOT_AMOUNT.getItemCode()));
            }
            if(15==code){
//              JsonNode condinfoCount = condlist.has("17") ? condlist.get("17") : null;
//              JsonNode amount = Objects.isNull(condinfoCount) ? null : condinfoCount.get("value");
//              String amountRe = amount.toString().replace("\"","");
              //JsonNode unit = Objects.isNull(condinfoCount) ? null : condinfoCount.get("unit");
              obj.put("amount", (
                condlist.hasNonNull(TreatmentItemsDef.T_I_DIALYSES_AMOUNT.getItemCode())
                && condlist.get(TreatmentItemsDef.T_I_DIALYSES_AMOUNT.getItemCode()).hasNonNull("value")
              ) ? condlist.get(TreatmentItemsDef.T_I_DIALYSES_AMOUNT.getItemCode()).get("value").asText()
                : TreatmentItemsDef.getDefaultValue(TreatmentItemsDef.T_I_DIALYSES_AMOUNT.getItemCode()));
            }
            if(19==code){
//              JsonNode condinfoCount = condlist.has("22") ? condlist.get("22") : null;
//              JsonNode amount = Objects.isNull(condinfoCount) ? null : condinfoCount.get("value");
//              String amountRe = amount.toString().replace("\"","");
              //JsonNode unit = Objects.isNull(condinfoCount) ? null : condinfoCount.get("unit");
              obj.put("amount", (
                condlist.hasNonNull(TreatmentItemsDef.T_I_IV_COUNT.getItemCode())
                && condlist.get(TreatmentItemsDef.T_I_IV_COUNT.getItemCode()).hasNonNull("value")
              ) ? condlist.get(TreatmentItemsDef.T_I_IV_COUNT.getItemCode()).get("value").asText()
                : TreatmentItemsDef.getDefaultValue(TreatmentItemsDef.T_I_IV_COUNT.getItemCode()));
            }
            //add 5556 条件送信を行った患者の数量に「NaN」と表示される zhao end
            res.add(obj);
          }
        }
      }

    } catch (IOException e) {
      // TODO 自動生成された catch ブロック
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
    }
    return res;

  }
  // add FNSI-条件送信特別処理 徐 start
  List<OrdChecklistRegEquipInfo> getIndMediInfo(String info, Integer code, String facilityCd) {
    // 応答用
    List<OrdChecklistRegEquipInfo> res = new ArrayList<>();

    // 医療材料指示がない場合
    if (info == null) {
      return res;
    }

    try {
      // #11589 2025.03.10 add アイテムについてマスタの並び順で表示を行う TDC米沢 start
      // 使用する各マスタの並び順を取得
      List<MstSelector> selectors = mstSelectorDao.selectByNameList(facilityCd, Arrays.asList(
        MST_MEDICINE_PHYSICAL_NAME,
        MST_MEDICINE_MIX_PHYSICAL_NAME
      ));
      // マスタの並び順を取得
      List<Long> sortedCodes = selectors.stream()
        .filter(selector-> selector.getMasterPhysicalName().equals(MST_MEDICINE_PHYSICAL_NAME))
        .findFirst().get().getOrderSettings().getItems().stream().map(MstSelector.Item::getCode).toList();
      List<Long> sortedCodes2 = selectors.stream()
        .filter(selector-> selector.getMasterPhysicalName().equals(MST_MEDICINE_MIX_PHYSICAL_NAME))
        .findFirst().get().getOrderSettings().getItems().stream().map(MstSelector.Item::getCode).toList();
      // ソート用配列
      HashMap<Long, OrdChecklistRegEquipInfo> sortList = new HashMap<>();
      HashMap<Long, OrdChecklistRegEquipInfo> sortList2 = new HashMap<>();
      // マスタの並び順に登録されていない場合は後ろに表示する
      Long noKeyValueMin = Long.MAX_VALUE - 1000L;
      Long sortKeyValue;
      // #11589 2025.03.10 add アイテムについてマスタの並び順で表示を行う TDC米沢 end

      // 投与薬剤指示リスト
      ObjectMapper map = new ObjectMapper();
      JsonNode equiplist = map.readTree(info);
      OrdChecklistRegEquipInfo regequip;

      int indexCnt = 0;

      // 指示・実績がある場合
      if (!Objects.isNull(equiplist) && !Objects.isNull(code)) {
        for (int equiplp = 0; equiplp < equiplist.size(); equiplp++) {
          regequip = new OrdChecklistRegEquipInfo();
          JsonNode equipInfo = equiplist.get(equiplp);
          // code
          if (equipInfo.hasNonNull("cd")) {
            Integer setcode = equipInfo.get("cd").asInt();
            //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
            // 薬剤マスタから情報取得
//            MstMedicine medidata = mstMedicineDao.selectByCd(facilityCd, setcode);
//
//            // 薬剤マスタに登録されている場合
//            if (medidata != null) {
//              Integer eclasscd = medidata.getClassCd();
//
//              // 対象の医療材料がある場合
//              if (Objects.equals(eclasscd, code)) {
//                indexCnt = indexCnt + 1;
//
//                regequip.setCode(setcode);
//                // needle_type
//                regequip.setNeedleType(null);
//                // code_update
//                regequip.setCodeUpdate(medidata.getUpDate());
//                // name
//                regequip.setName(medidata.getMedicineName());
//                // amount
//                regequip.setAmount(equipInfo.get("amount").asText());
//                // unit
//                regequip.setUnit(medidata.getUnit());
//
//                res.add(regequip);
//              }
//            }
//          }
//          // add FNSI-条件送信特別処理 徐 start
//          if (equiplp == equiplist.size() - 1 && indexCnt == 0) {
//            regequip.setCode(null);
//            // needle_type
//            regequip.setNeedleType(null);
//            // code_update
//            regequip.setCodeUpdate(null);
//            // name
//            regequip.setName(null);
//            // amount
//            regequip.setAmount(null);
//            // unit
//            regequip.setUnit(null);
//            regequip.setRstClassFlg(9);
//
//            res.add(regequip);
//          }
//          // add FNSI-条件送信特別処理 徐 end
            if (equipInfo.hasNonNull("medicine_type")) {
              Integer medicineType = equipInfo.get("medicine_type").asInt();
              if (medicineType.equals(1)) {
                // 薬剤マスタから情報取得
                MstMedicine medidata = mstMedicineDao.selectByCd(facilityCd, setcode);

                // 薬剤マスタに登録されている場合
                if (medidata != null) {
                  Integer eclasscd = medidata.getClassCd();

                  // 対象の薬剤分類がある場合
                  if (Objects.equals(eclasscd, code)) {

                    // mod #12235【因島】チェックリストの治療条件：抗凝固剤での小数点桁数の扱いが不正 関 start
                    int unitDecimalPoint = 0;
                    if (medidata.getUnitDecimalPoint() != null) {
                      unitDecimalPoint = medidata.getUnitDecimalPoint();
                    }
                    String amount = equipInfo.hasNonNull("amount")
                      ? equipInfo.get("amount").asText()
                      : null;

                    regequip.setCode(setcode);
                    // del 10310 needle _ typeの使用を削除するには gjn start
                    // needle_type
                    //regequip.setNeedleType(null);
                    // del 10310 needle _ typeの使用を削除するには gjn end
                    // code_update
                    regequip.setCodeUpdate(medidata.getUpDate());
                    // name
                    regequip.setName(medidata.getMedicineName());
                    // amount
                    regequip.setAmount(amount == null ? null : new BigDecimal(amount).setScale(unitDecimalPoint, RoundingMode.HALF_UP).toPlainString());
                    // mod #12235【因島】チェックリストの治療条件：抗凝固剤での小数点桁数の扱いが不正 関 end
                    // unit
                    regequip.setUnit(medidata.getUnit());

                    regequip.setMedicineNo(equipInfo.hasNonNull("no") ? equipInfo.get("no").asInt() : null);

                    regequip.setMedicineEype(equipInfo.hasNonNull("medicine_type") ? equipInfo.get("medicine_type").asInt() : null);

                    // #11589 2025.03.10 mod アイテムについてマスタの並び順で表示を行う TDC米沢 start
                    //res.add(regequip);
                    // マスタの並び順を取得、キー値として対応情報を登録する
                    sortKeyValue = (long)sortedCodes.indexOf((long)setcode);
                    sortList.put(sortKeyValue.equals((long)-1) ? noKeyValueMin : sortKeyValue, regequip);
                    // #11589 2025.03.10 mod アイテムについてマスタの並び順で表示を行う TDC米沢 end
                  }
                }
              } else if (medicineType.equals(2)){
                MstMedicineMix medidata = mstMedicineMixDao.selectByCd(facilityCd, setcode);

                // mod #12235【因島】チェックリストの治療条件：抗凝固剤での小数点桁数の扱いが不正 関 start
                int unitDecimalPoint = 0;
                if (medidata.getUnitDecimalPoint() != null) {
                  unitDecimalPoint = medidata.getUnitDecimalPoint();
                }
                String amount = equipInfo.hasNonNull("amount")
                  ? equipInfo.get("amount").asText()
                  : null;

                // #11589 2025.03.10 mod アイテムについてマスタの並び順で表示を行う TDC米沢 start
                // regequip.setCode(setcode);
                // // del 10310 needle _ typeの使用を削除するには gjn start
                // // needle_type
                // //regequip.setNeedleType(null);
                // // del 10310 needle _ typeの使用を削除するには gjn end
                // // code_update
                // regequip.setCodeUpdate(medidata.getUpDate());
                // // name
                // regequip.setName(medidata.getMedicineMixName());
                // // amount
                // regequip.setAmount(equipInfo.hasNonNull("amount") ? equipInfo.get("amount").asText() : null);
                // // unit
                // regequip.setUnit(medidata.getUnit());
                //
                // regequip.setMedicineNo(equipInfo.hasNonNull("no") ? equipInfo.get("no").asInt() : null);
                //
                // regequip.setMedicineEype(equipInfo.hasNonNull("medicine_type") ? equipInfo.get("medicine_type").asInt() : null);
                //
                //res.add(regequip);

                // 調整薬剤マスタに登録されている場合
                if (medidata != null) {
                  Integer eclasscd = medidata.getClassCd();

                  // 対象の薬剤分類がある場合
                  if (Objects.equals(eclasscd, code)) {
                    regequip.setCode(setcode);
                    // code_update
                    regequip.setCodeUpdate(medidata.getUpDate());
                    // name
                    regequip.setName(medidata.getMedicineMixName());
                    // amount
                    regequip.setAmount(amount == null ? null : new BigDecimal(amount).setScale(unitDecimalPoint, RoundingMode.HALF_UP).toPlainString());
                    // mod #12235【因島】チェックリストの治療条件：抗凝固剤での小数点桁数の扱いが不正 関 end
                    // unit
                    regequip.setUnit(medidata.getUnit());

                    regequip.setMedicineNo(equipInfo.hasNonNull("no") ? equipInfo.get("no").asInt() : null);

                    regequip.setMedicineEype(equipInfo.hasNonNull("medicine_type") ? equipInfo.get("medicine_type").asInt() : null);

                    // マスタの並び順を取得、キー値として対応情報を登録する
                    sortKeyValue = (long) sortedCodes2.indexOf((long) setcode);
                    sortList2.put(sortKeyValue.equals((long) -1) ? noKeyValueMin : sortKeyValue, regequip);
                  }
                }
                // #11589 2025.03.10 mod アイテムについてマスタの並び順で表示を行う TDC米沢 end
              }
            }
          }
          //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end

          // #11589 2025.03.10 add アイテムについてマスタの並び順で表示を行う TDC米沢 start
          noKeyValueMin++;
          // #11589 2025.03.10 add アイテムについてマスタの並び順で表示を行う TDC米沢 end
        }
      }

      // #11589 2025.03.10 add アイテムについてマスタの並び順で表示を行う TDC米沢 start
      // 通常薬剤
      // 表示順でソート
      Object[] orderedKeys = sortList.keySet().toArray();
      Arrays.sort(orderedKeys);
      for (Object orderedKey : orderedKeys) {
        // ソート結果からチェックリストを作成する
        res.add(sortList.get((Long)orderedKey));
      }
      // 調整薬剤
      // 表示順でソート
      orderedKeys = sortList2.keySet().toArray();
      Arrays.sort(orderedKeys);
      for (Object orderedKey : orderedKeys) {
        // ソート結果からチェックリストを作成する
        res.add(sortList2.get((Long)orderedKey));
      }
      // #11589 2025.03.10 add アイテムについてマスタの並び順で表示を行う TDC米沢 end

    } catch (IOException e) {
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
    // #11589 2025.03.10 del アイテムについてマスタの並び順で表示を行う TDC米沢 start
    //res.sort(Comparator.comparing(OrdChecklistRegEquipInfo::getName));
    // #11589 2025.03.10 del アイテムについてマスタの並び順で表示を行う TDC米沢 end
    return res;

  }
  // add FNSI-条件送信特別処理 徐 end
  //対象の医療材料情報取得
  // #11589 2025.03.10 mod 引数に施設コードを追加 TDC米沢 start
  // // add FNSI-条件送信特別処理 徐 start
  // // List<OrdChecklistRegEquipInfo> getEquipInfo(String info, Integer code) {
  // List<OrdChecklistRegEquipInfo> getEquipInfo(String info, Integer code, int index) {
  // // add FNSI-条件送信特別処理 徐 end
  List<OrdChecklistRegEquipInfo> getEquipInfo(String info, Integer code, int index, String facilityCd) {
  // #11589 2025.03.10 mod 引数に施設コードを追加 TDC米沢 end

    // 応答用
    List<OrdChecklistRegEquipInfo> res = new ArrayList<>();

    // 医療材料指示がない場合
    if (info == null) {
      return res;
    }

    try {
      // #11589 2025.03.10 add アイテムについてマスタの並び順で表示を行う TDC米沢 start
      // 使用する各マスタの並び順を取得
      List<MstSelector> selectors = mstSelectorDao.selectByNameList(facilityCd, Arrays.asList(
        MST_EQUIPMENT_PHYSICAL_NAME
      ));
      // マスタの並び順を取得
      List<Long> sortedCodes = selectors.stream()
        .filter(selector-> selector.getMasterPhysicalName().equals(MST_EQUIPMENT_PHYSICAL_NAME))
        .findFirst().get().getOrderSettings().getItems().stream().map(MstSelector.Item::getCode).toList();
      // ソート用配列
      HashMap<Long, OrdChecklistRegEquipInfo> sortList = new HashMap<>();
      // マスタの並び順に登録されていない場合は後ろに表示する
      Long noKeyValueMin = Long.MAX_VALUE - 1000L;
      Long sortKeyValue;
      // #11589 2025.03.10 add アイテムについてマスタの並び順で表示を行う TDC米沢 end

      // 医療材料指示リスト
      ObjectMapper map = new ObjectMapper();
      JsonNode equiplist = map.readTree(info);
      // add FNSI-条件送信特別処理 徐 start
      // OrdChecklistRegEquipInfo regequip = new OrdChecklistRegEquipInfo();
      int indexCnt = 0;
      // add FNSI-条件送信特別処理 徐 end
      // 指示・実績がある場合
      if (!Objects.isNull(equiplist) && !Objects.isNull(code)) {
        for (int equiplp = 0; equiplp < equiplist.size(); equiplp++) {
          // add FNSI-条件送信特別処理 徐 start
          OrdChecklistRegEquipInfo regequip = new OrdChecklistRegEquipInfo();
          // add FNSI-条件送信特別処理 徐 end
          JsonNode equipInfo = equiplist.get(equiplp);
          // code
          if (equipInfo.hasNonNull("cd")) {
//            String strcode = equipInfo.get("cd").toString();
            int setcode = equipInfo.get("cd").asInt();
            // equip_type
            String strtype = "0";
            if (equipInfo.hasNonNull("equip_type")) {
              strtype = equipInfo.get("equip_type").asText();
            }
            // codeが登録されているかつ医療材料区分が医療材料の場合
            if ("0".equals(strtype)) {
              // 医療材料マスタから情報取得
              MstEquipment equipdata = mstEquipDao.selectByEquipmentCd(setcode);

              // 医療材料マスタに登録されている場合
              if (equipdata != null) {
                Integer eclasscd = equipdata.getClassCd();

                // 対象の医療材料がある場合
                if (Objects.equals(eclasscd, code)) {
                  // add FNSI-条件送信特別処理 徐 start
                  indexCnt = indexCnt + 1;
                  // add FNSI-条件送信特別処理 徐 end

                  regequip.setCode(setcode);
                  // del 10310 needle _ typeの使用を削除するには gjn start
                  // needle_type
//                  if (equipInfo.hasNonNull("needle_type")) {
//                    regequip.setNeedleType(Short.parseShort(equipInfo.get("needle_type").asText()));
//                  }
                  // del 10310 needle _ typeの使用を削除するには gjn end
                  // code_update
                  regequip.setCodeUpdate(equipdata.getUpDate());
                  // name
                  regequip.setName(equipdata.getEquipmentName());
                  // amount
                  regequip.setAmount(equipInfo.get("amount").asText());
                  // unit
                  regequip.setUnit(equipdata.getUnit());

                  //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
                  regequip.setEquipEype(0);
                  //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end

                  // #11589 2025.03.10 mod アイテムについてマスタの並び順で表示を行う TDC米沢 start
                  //res.add(regequip);
                  // マスタの並び順を取得、キー値として対応情報を登録する
                  sortKeyValue = (long)sortedCodes.indexOf((long)setcode);
                  sortList.put(sortKeyValue.equals((long)-1) ? noKeyValueMin : sortKeyValue, regequip);
                  // #11589 2025.03.10 mod アイテムについてマスタの並び順で表示を行う TDC米沢 end
                }
              }
            }
          }
          // add FNSI-条件送信特別処理 徐 start
          if (equiplp == equiplist.size() - 1 && indexCnt == 0 && index == 0) {
            regequip.setCode(null);
            // del 10310 needle _ typeの使用を削除するには gjn start
            // needle_type
            //regequip.setNeedleType(null);
            // del 10310 needle _ typeの使用を削除するには gjn end
            // code_update
            regequip.setCodeUpdate(null);
            // name
            regequip.setName(null);
            // amount
            regequip.setAmount(null);
            // unit
            regequip.setUnit(null);
            regequip.setRstClassFlg(9);

            //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
            regequip.setEquipEype(0);
            //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end

            // #11589 2025.03.10 mod アイテムについてマスタの並び順で表示を行う TDC米沢 start
            //res.add(regequip);
            sortList.put(noKeyValueMin, regequip);
            // #11589 2025.03.10 mod アイテムについてマスタの並び順で表示を行う TDC米沢 end
          }
          // add FNSI-条件送信特別処理 徐 end

          // #11589 2025.03.10 add アイテムについてマスタの並び順で表示を行う TDC米沢 start
          noKeyValueMin++;
          // #11589 2025.03.10 add アイテムについてマスタの並び順で表示を行う TDC米沢 end
        }
      }

      // #11589 2025.03.10 add アイテムについてマスタの並び順で表示を行う TDC米沢 start
      // 表示順でソート
      Object[] orderedKeys = sortList.keySet().toArray();
      Arrays.sort(orderedKeys);
      for (Object orderedKey : orderedKeys) {
        // ソート結果からチェックリストを作成する
        res.add(sortList.get((Long)orderedKey));
      }
      // #11589 2025.03.10 add アイテムについてマスタの並び順で表示を行う TDC米沢 end

    } catch (IOException e) {
      // TODO 自動生成された catch ブロック
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
    // #11589 2025.03.10 del アイテムについてマスタの並び順で表示を行う TDC米沢 start
    //res.sort(Comparator.comparing(OrdChecklistRegEquipInfo::getName));
    // #11589 2025.03.10 del アイテムについてマスタの並び順で表示を行う TDC米沢 end
    return res;

  }

  //対象のダイアライザ情報取得
  // #11589 2025.03.10 mod 引数に施設コードを追加 TDC米沢 start
  // // add FNSI-条件送信特別処理 徐 start
  // // List<OrdChecklistRegEquipInfo> getEquipDailyzerInfo(String info, Integer code) {
  // List<OrdChecklistRegEquipInfo> getEquipDailyzerInfo(String info, Integer code, int index) {
  // // add FNSI-条件送信特別処理 徐 end
  List<OrdChecklistRegEquipInfo> getEquipDailyzerInfo(String info, Integer code, int index, String facilityCd) {
  // #11589 2025.03.10 mod 引数に施設コードを追加 TDC米沢 start

    // 応答用
    List<OrdChecklistRegEquipInfo> res = new ArrayList<>();

    // 医療材料指示がない場合
    if (info == null) {
      return res;
    }

    try {
      // #11589 2025.03.10 add アイテムについてマスタの並び順で表示を行う TDC米沢 start
      // 使用する各マスタの並び順を取得
      List<MstSelector> selectors = mstSelectorDao.selectByNameList(facilityCd, Arrays.asList(
        MST_DIALYZER_PHYSICAL_NAME
      ));
      // マスタの並び順を取得
      List<Long> sortedCodes = selectors.stream()
        .filter(selector-> selector.getMasterPhysicalName().equals(MST_DIALYZER_PHYSICAL_NAME))
        .findFirst().get().getOrderSettings().getItems().stream().map(MstSelector.Item::getCode).toList();
      // ソート用配列
      HashMap<Long, OrdChecklistRegEquipInfo> sortList = new HashMap<>();
      // マスタの並び順に登録されていない場合は後ろに表示する
      Long noKeyValueMin = Long.MAX_VALUE - 1000L;
      Long sortKeyValue;
      // #11589 2025.03.10 add アイテムについてマスタの並び順で表示を行う TDC米沢 end

      // 医療材料指示リスト
      ObjectMapper map = new ObjectMapper();
      JsonNode equiplist = map.readTree(info);
      // add FNSI-条件送信特別処理 徐 start
      // OrdChecklistRegEquipInfo regequip = new OrdChecklistRegEquipInfo();
      int indexCnt = 0;
      // add FNSI-条件送信特別処理 徐 end

      // 指示・実績がある場合
      if (!Objects.isNull(equiplist) && !Objects.isNull(code)) {
        for (int equiplp = 0; equiplp < equiplist.size(); equiplp++) {
          // add FNSI-条件送信特別処理 徐 start
          OrdChecklistRegEquipInfo regequip = new OrdChecklistRegEquipInfo();
          // add FNSI-条件送信特別処理 徐 end

          JsonNode equipInfo = equiplist.get(equiplp);
          // code
          if (equipInfo.hasNonNull("cd")) {
            // equip_type
            String equip_type = "0";
            if (equipInfo.hasNonNull("equip_type")) {
              equip_type = equipInfo.get("equip_type").asText();
            }
            // ダイアライザの場合
            if ("1".equals(equip_type)) {
              int setcode = equipInfo.get("cd").asInt();
              // ダイアライザマスタから情報取得
              MstDialyzer dialdata = mstDialyzerDao.selectByDialyzerCd(SelectOptions.get(), setcode);

              // 対象のダイアライザがある場合
              if (dialdata != null) {
                // add FNSI-条件送信特別処理 徐 start
                indexCnt = indexCnt + 1;
                // add FNSI-条件送信特別処理 徐 end

                regequip.setCode(setcode);
                // del 10310 needle _ typeの使用を削除するには gjn start
                // needle_type
                //regequip.setNeedleType(null);
                // del 10310 needle _ typeの使用を削除するには gjn end
                // code_update
                //String strdate = DateTimeUtils.getDateString_iso8601(dialdata.getUpDate());
                regequip.setCodeUpdate(dialdata.getUpDate());
                // name
                regequip.setName(dialdata.getModelNumber());
                // amount
                regequip.setAmount(equipInfo.get("amount").asText());
                // unit
                regequip.setUnit("本");

                //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
                regequip.setEquipEype(1);
                //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end

                // #11589 2025.03.10 mod アイテムについてマスタの並び順で表示を行う TDC米沢 start
                //res.add(regequip);
                // マスタの並び順を取得、キー値として対応情報を登録する
                sortKeyValue = (long)sortedCodes.indexOf((long)setcode);
                sortList.put(sortKeyValue.equals((long)-1) ? noKeyValueMin : sortKeyValue, regequip);
                // #11589 2025.03.10 mod アイテムについてマスタの並び順で表示を行う TDC米沢 end
              }
            }
          }
          // add FNSI-条件送信特別処理 徐 start
          if (equiplp == equiplist.size() - 1 && indexCnt == 0 && index == 0) {
            regequip.setCode(null);
            // del 10310 needle _ typeの使用を削除するには gjn start
            // needle_type
            //regequip.setNeedleType(null);
            // del 10310 needle _ typeの使用を削除するには gjn end
            // code_update
            regequip.setCodeUpdate(null);
            // name
            regequip.setName(null);
            // amount
            regequip.setAmount(null);
            // unit
            regequip.setUnit("本");
            regequip.setRstClassFlg(9);

            //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
            regequip.setEquipEype(0);
            //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end

            // #11589 2025.03.10 mod アイテムについてマスタの並び順で表示を行う TDC米沢 start
            //res.add(regequip);
            sortList.put(noKeyValueMin, regequip);
            // #11589 2025.03.10 mod アイテムについてマスタの並び順で表示を行う TDC米沢 end
          }
          // add FNSI-条件送信特別処理 徐 end

          // #11589 2025.03.10 add アイテムについてマスタの並び順で表示を行う TDC米沢 start
          noKeyValueMin++;
          // #11589 2025.03.10 add アイテムについてマスタの並び順で表示を行う TDC米沢 end
        }
      }

      // #11589 2025.03.10 add アイテムについてマスタの並び順で表示を行う TDC米沢 start
      // 表示順でソート
      Object[] orderedKeys = sortList.keySet().toArray();
      Arrays.sort(orderedKeys);
      for (Object orderedKey : orderedKeys) {
        // ソート結果からチェックリストを作成する
        res.add(sortList.get((Long)orderedKey));
      }
      // #11589 2025.03.10 add アイテムについてマスタの並び順で表示を行う TDC米沢 end

    } catch (IOException e) {
      // TODO 自動生成された catch ブロック
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
    return res;

  }

  // チェックリスト実績作成用医療材料情報クラス
  @Domain(valueType = String.class)
  @Getter
  @Setter
  @NoArgsConstructor
  public static class OrdChecklistRegEquipInfo {
    /** ObjectMapper */
    private static ObjectMapper objectMapper = new ObjectMapper();

    /** ModelMapper */
    private static ModelMapper modelMapper = new ModelMapper();

    /**
    * 医療材料コード
    */
    @JsonProperty("code")
    private Integer code;
// del 10310 needle _ typeの使用を削除するには gjn start
    /**
    * 穿刺針区分(0: 未指定、1: A針、2: V針、3: SN)
    */
//    @JsonProperty("needle_type")
//    private Short needleType;
// del 10310 needle _ typeの使用を削除するには gjn end
    /**
    * 医療材料更新日時
    */
    @JsonProperty("code_update")
    private Timestamp codeUpdate;

    /**
    * 医療材料名
    */
    @JsonProperty("name")
    private String name;

    /**
     * 数量
     */
    @JsonProperty("amount")
    private String amount;

    /**
     * 単位
     */
    @JsonProperty("unit")
    private String unit;

    //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
    /**
     * 医療材料区分
     */
    @JsonProperty("equip_type")
    private Integer equipEype;

    /**
     * 薬剤識別番号
     */
    @JsonProperty("medicine_no")
    private Integer medicineNo;

    /**
     * 薬剤区分
     */
    @JsonProperty("medicine_type")
    private Integer medicineEype;
    //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end

    /**
    * コンストラクタ.
    * @param value JSON文字列
    */
    public OrdChecklistRegEquipInfo(String value) {
      try {
        OrdChecklistRegEquipInfo obj = objectMapper.readValue(value, OrdChecklistRegEquipInfo.class);
        modelMapper.map(obj, this);
      } catch (IOException e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang end
      }
    }

    /**
    * 基本型の値を返す.
    * @return 基本型の値
    */
    @JsonIgnore
    public String getValue() {
      try {
        return objectMapper.writeValueAsString(this);
      } catch (JsonProcessingException e) {
        return null;
      }
    }
    // add FNSI-条件送信特別処理 徐 start
    // 実績区分フラグ
    private int rstClassFlg;
    // add FNSI-条件送信特別処理 徐 end
  }

  public class MedicineType {
    public static final int MEDICINE = 1;
    public static final int CONTROL_MEDICINE = 2;
  }

  /**
   * 条件送信前のチェックリスト情報を取得する
   * {@inheritDoc}
   */
    @Override
  public List<OrdChecklist> getBeforeCheckListByListCd(Long ordNo, Short listCd, String facilityCd) throws IOException {

    // 最新のチェックリストマスタ取得
    List<MstChecklist> mstChecklist = mstChecklistDao.selectByFacilityCd(SelectOptions.get(), facilityCd, "0");
    MstChecklist nowMstChecklist = mstChecklist.get(0);
    String strSetting = nowMstChecklist.getChecklistSettings();
    ObjectMapper map = new ObjectMapper();
    JsonNode node = map.readTree(strSetting);
    // ord_mainの情報取得
    OrdMainForCheckListSchedule ordList = ordMainDao.selectByOrdNoChecklist(ordNo);
    // 取得用
    List<OrdChecklist> getList = new ArrayList<>();

    // ord_mainに情報がない場合
    if (ordList == null) {
      getList = null;
      return getList;
    }

    // リストコード分繰り返し
    for (int i = 0; i < node.size(); i++) {
      JsonNode setting = map.readTree(node.get(i).toString());

      // リストコード
      Short listcd = Short.parseShort(setting.get("list_cd").toString());
      if (!Objects.equals(listcd, listCd)) {
        // 収集対象のリストコードと異なっているならば次へ行く
        continue;
      }

//      JsonNode funclist = map.readTree(setting.get("funclist").toString());
      JsonNode funclist = setting.get("funclist");

      // funclist分繰り返し
      for (int j = 0; j < funclist.size(); j++) {
//        JsonNode list = map.readTree(funclist.get(j).toString());
        JsonNode list = funclist.get(j);

        // 機能種別(func_class)
//        String strfuncclass = list.get("func_class").toString();
//        Short funcClass = null;
//        if (!strfuncclass.equals("null")) {
//          funcClass = Short.parseShort(list.get("func_class").toString());
//        }
        Short funcClass = list.hasNonNull("func_class")
          ? Short.parseShort(list.get("func_class").asText()) : null;
        // 未登録の場合
        if (funcClass == null) {
          continue;
        }

        // 取得用
        OrdChecklist getdata = new OrdChecklist();
        getdata.setOrdNo(ordNo);
        getdata.setListCd(listcd);
        getdata.setFuncClass(funcClass);
        getdata.setIsCheck("0");
        getdata.setRstClass((short) 1);
        getdata.setIsDisp(FlagType.FLAG_ON);
        getdata.setIsDel(FlagType.FLAG_OFF);
        OrdChecklistRegStaffInfo regStaffInfo = new OrdChecklistRegStaffInfo();
        getdata.setRegStaffInfo(regStaffInfo);
        // チェックリスト項目情報作成用
        OrdChecklistRegCheckInfo checkinfo = new OrdChecklistRegCheckInfo();
        // checklist_cd
        checkinfo.setChecklistCd(nowMstChecklist.getChecklistCd());
        // item_number
        checkinfo.setItemNumber(Short.parseShort(list.get("item_number").toString()));
        // class_cd
//        String classcode = list.get("class_cd").toString();
        Integer classcd = list.hasNonNull("class_cd") ? list.get("class_cd").asInt() : null;
//        if (!classcode.equals("null")) {
//          classcd = Integer.parseInt(list.get("class_cd").toString());
//          checkinfo.setClassCd(classcd);
//        }

        //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
        checkinfo.setClassCd(classcd);
        //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end

        // 通常リストの場合
        if (Objects.equals(funcClass, (short) 0)) {

          checkinfo = settingNormalCheckList(checkinfo, list);

          // rst_checklist_info
          getdata.setRstChecklistInfo(checkinfo);

          // チェックリスト登録
          getList.add(getdata);
        }
        // 治療条件の場合
        else if (Objects.equals(funcClass, (short) 1)) {

          if (classcd == null) {
            continue;
          }

          // class_cd
          List<Integer> condclasscd = new ArrayList<>();
          condclasscd.add(classcd);

          // ダイアライザの場合
          if (Objects.equals(classcd, 5)) {
            // 吸着カラムも追加
            condclasscd.add(6);
            // 一次膜・二次膜
            condclasscd.add(7);
            condclasscd.add(8);
          }
          // 吸着カラムはダイアライザと同時設定にしたので除外
          if (Objects.equals(classcd, 6)) {
            continue;
          }
          // 穿刺針の場合
          if (Objects.equals(classcd, 9)) {
            condclasscd.add(10);
            condclasscd.add(11);
          }
          //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
          // 透析液の場合「15：透析液」
          if (Objects.equals(classcd, 15)) {
            // 「17：透析液使用数」
            condclasscd.add(17);
          }
          // 補液の場合「19：補液」
          if (Objects.equals(classcd, 19)) {
            // 「22：補液使用数」
            condclasscd.add(22);
          }
          // 抗凝固剤の場合「25：抗凝固剤」
          if (Objects.equals(classcd, 25)) {
            // 「26：抗凝固剤ワンショット量」
            condclasscd.add(26);
            // 「28：抗凝固剤持続総量」
            condclasscd.add(28);
          }
          //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end

          // 対象の治療条件取得
          List<JSONObject> condList = getCondInfo(ordList.getIndCondInfo(), condclasscd);
          //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
//          for (JSONObject cond : condList) {
//
//            // チェックリスト項目情報作成用
//            OrdChecklistRegCheckInfo condcheckinfo = checkinfo.clone();
//
//            // code
//            String strcode = cond.get("code").toString();
//            Integer regcode = null;
//            if (!strcode.equals("null")) {
//              regcode = Integer.parseInt(cond.get("code").toString());
//              condcheckinfo.setCode(regcode);
//            }
//            // needle_type
//            String strntype = cond.get("needle_type").toString();
//            Short ntype = null;
//            if (!strntype.equals("")) {
//              ntype = Short.parseShort(strntype);
//              condcheckinfo.setNeedleType(ntype);
//            }
//            // code_update
//            condcheckinfo.setCodeUpdate(null);
//            // name
//            condcheckinfo.setName(null);
//
//            // class_cd
//            condcheckinfo.setClassCd(Integer.valueOf(cond.get("class_cd").toString()));
//
//            // ダイアライザの場合
//            if (Objects.equals(classcd, 5)) {
//              // ダイアライザマスタから情報取得
//              if (Objects.equals(condcheckinfo.getClassCd(), 5)) {
//                // ダイアライザマスタから情報取得
//                condcheckinfo = settingCondDializerCheckInfo(condcheckinfo, regcode);
//              } else {
//                // 吸着カラム・1次膜・2次膜：医療材料から情報取得
//                condcheckinfo = settingCondEquipCheckInfo(condcheckinfo, regcode, condcheckinfo.getClassCd());
//              }
//            }
//            // 薬剤の場合
//            else if (Objects.equals(classcd, 15) || Objects.equals(classcd, 19) || Objects.equals(classcd, 25)) {
//
//              // 薬剤の場合
//              String meditype = cond.get("medicine_type").toString();
//
//              // 調整薬剤場合
//              if (meditype.equals("2")) {
//                condcheckinfo = settingCondMixMedicineCheckInfo(condcheckinfo, facilityCd, regcode,
//                  list.get("list_name").toString());
//              } else if (meditype.equals("1")) {
//                // 薬剤
//                condcheckinfo = settingCondNormalMedicineCheckInfo(condcheckinfo, facilityCd, regcode);
//              } else {
//                // NOTE: 薬剤なのに薬剤種別が入っていないデータの場合はとりあえず薬剤とする
//                condcheckinfo = settingCondNormalMedicineCheckInfo(condcheckinfo, facilityCd, regcode);
//              }
//            }
          // 対象の治療条件取得「再作成」「薬剤場合用」
          List<JSONObject> res = new ArrayList<>();
          // 「17：透析液使用数」
          BigDecimal amount15 = BigDecimal.ZERO;
          // 「22：補液使用数」
          BigDecimal amount19 = BigDecimal.ZERO;
          // 「26：抗凝固剤ワンショット量」＋「28：抗凝固剤持続総量」
          BigDecimal amount25 = BigDecimal.ZERO;
          for (JSONObject cond : condList) {
            if(!cond.has("code") || cond.isNull("code")){
              continue;
            }
            // code「設定値：value」
            String strcode = cond.get("code").toString();
            BigDecimal regcode = BigDecimal.ZERO;
            // mod 9324 gjn start
            if (!strcode.equals("null") && !"".equals(strcode)) {
              // mod FutreNetWeb+SI課題管理No7165 趙 start
              String regexp = "\"";
              if (cond.get("code").toString().indexOf(regexp) > - 1) {
                regcode = new BigDecimal(cond.get("code").toString().replaceAll(regexp, ""));
              } else {
                regcode = new BigDecimal(cond.get("code").toString());
              }
            }
            if (cond.has("class_cd") && !cond.isNull("class_cd") && Objects.equals(cond.get("class_cd").toString(), "17")) {
              amount15 = amount15.add(regcode);
            } else if (cond.has("class_cd") && !cond.isNull("class_cd") && Objects.equals(cond.get("class_cd").toString(), "22")) {
              amount19 = amount19.add(regcode);
            } else if (cond.has("class_cd") && !cond.isNull("class_cd") && Objects.equals(cond.get("class_cd").toString(), "26")) {
              amount25 = amount25.add(regcode);
            } else if (cond.has("class_cd") && !cond.isNull("class_cd") && Objects.equals(cond.get("class_cd").toString(), "28")) {
              amount25 = amount25.add(regcode);
            } else {
              res.add(cond);
            }
          }

          for (JSONObject cond : res) {
            //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end

            // チェックリスト項目情報作成用
            OrdChecklistRegCheckInfo condcheckinfo = checkinfo.clone();

            // code
            String strcode = cond.get("code").toString();
            Integer regcode = null;
            if (!strcode.equals("null")) {
              regcode = Integer.parseInt(cond.get("code").toString());
              condcheckinfo.setCode(regcode);
            }
            // del 10310 needle _ typeの使用を削除するには gjn start
            // needle_type
//            String strntype = cond.get("needle_type").toString();
//            Short ntype = null;
//            if (!strntype.equals("")) {
//              ntype = Short.parseShort(strntype);
//              condcheckinfo.setNeedleType(ntype);
//            }
            // del 10310 needle _ typeの使用を削除するには gjn end
            // code_update
            condcheckinfo.setCodeUpdate(null);
            // name
            condcheckinfo.setName(null);

            // class_cd
            condcheckinfo.setClassCd(Integer.valueOf(cond.get("class_cd").toString()));

            // ダイアライザの場合
            if (Objects.equals(classcd, 5)) {
              // ダイアライザマスタから情報取得
              if (Objects.equals(condcheckinfo.getClassCd(), 5)) {
                // ダイアライザマスタから情報取得
                condcheckinfo = settingCondDializerCheckInfo(condcheckinfo, regcode);
              } else {
                // 吸着カラム・1次膜・2次膜：医療材料から情報取得
                condcheckinfo = settingCondEquipCheckInfo(condcheckinfo, regcode, condcheckinfo.getClassCd());
              }
            }
            // 薬剤の場合
            else if (Objects.equals(classcd, 15) || Objects.equals(classcd, 19) || Objects.equals(classcd, 25)) {

              // 薬剤の場合
              String meditype = cond.get("medicine_type").toString();

              // 調整薬剤場合
              //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
//              if (meditype.equals("2")) {
//                condcheckinfo = settingCondMixMedicineCheckInfo(condcheckinfo, facilityCd, regcode,
//                  list.get("list_name").toString());
//              } else if (meditype.equals("1")) {
//                // 薬剤
//                condcheckinfo = settingCondNormalMedicineCheckInfo(condcheckinfo, facilityCd, regcode);
//              } else {
//                // NOTE: 薬剤なのに薬剤種別が入っていないデータの場合はとりあえず薬剤とする
//                condcheckinfo = settingCondNormalMedicineCheckInfo(condcheckinfo, facilityCd, regcode);
//              }
              // mod #12235【因島】チェックリストの治療条件：抗凝固剤での小数点桁数の扱いが不正 関 start
              Map<Integer, BigDecimal> amountMap = Map.of(
                15, amount15,
                19, amount19,
                25, amount25
              );
              if (meditype.equals("2")) {

                condcheckinfo = settingIndCondMixMedicineCheckInfo(condcheckinfo, facilityCd, classcd, regcode,
                  amountMap.get(classcd));
              } else if (meditype.equals("1")) {
                // 薬剤
                condcheckinfo = settingIndCondNormalMedicineCheckInfo(condcheckinfo, facilityCd, classcd, regcode, amountMap.get(classcd));
              } else {
                // NOTE: 薬剤なのに薬剤種別が入っていないデータの場合はとりあえず薬剤とする
                condcheckinfo = settingIndCondNormalMedicineCheckInfo(condcheckinfo, facilityCd, classcd, regcode, amountMap.get(classcd));
              }
              // 薬剤場合「数量設定」
//              if (Objects.equals(classcd, 15)) {
//                condcheckinfo.setAmount(amount15.toString());
//              } else if (Objects.equals(classcd, 19)) {
//                condcheckinfo.setAmount(amount19.toString());
//              } else if (Objects.equals(classcd, 25)) {
//                condcheckinfo.setAmount(amount25.toString());
//              }
              // mod #12235【因島】チェックリストの治療条件：抗凝固剤での小数点桁数の扱いが不正 関 end
            }
            // 医療材料の場合
            else {
              condcheckinfo = settingCondEquipCheckInfo(condcheckinfo, regcode, classcd);
            }

            // 登録用
            OrdChecklist condregdata = getdata.clone();
            // rst_checklist_info
            condregdata.setRstChecklistInfo(condcheckinfo);
            // チェックリスト登録
            getList.add(condregdata);
          }
        }
        // 医療材料の場合
        else if (Objects.equals(funcClass, (short) 2)) {

          if (classcd == null) {
            continue;
          }

          // 対象の医療材料取得
          List<OrdChecklistRegEquipInfo> equipList;

          // ダイアライザの場合
          if (Objects.equals(classcd, 0)) {

            // 対象のダイアライザ取得
            // #11589 2025.03.10 mod 引数に施設コードを追加 TDC米沢 start
            // // add FNSI-条件送信特別処理 徐 start
            // // equipList = getEquipDailyzerInfo(ordList.getIndEquipInfo(), classcd);
            // equipList = getEquipDailyzerInfo(ordList.getIndEquipInfo(), classcd, 1);
            // // add FNSI-条件送信特別処理 徐 end
            equipList = getEquipDailyzerInfo(ordList.getIndEquipInfo(), classcd, 1, facilityCd);
            // #11589 2025.03.10 mod 引数に施設コードを追加 TDC米沢 end

          } else {
            // 対象の医療材料取得
            // #11589 2025.03.10 mod 引数に施設コードを追加 TDC米沢 start
            // // add FNSI-条件送信特別処理 徐 start
            // // equipList = getEquipInfo(ordList.getIndEquipInfo(), classcd);
            // equipList = getEquipInfo(ordList.getIndEquipInfo(), classcd, 1);
            // // add FNSI-条件送信特別処理 徐 end
            equipList = getEquipInfo(ordList.getIndEquipInfo(), classcd, 1, facilityCd);
            // #11589 2025.03.10 mod 引数に施設コードを追加 TDC米沢 end
          }
          for (OrdChecklistRegEquipInfo equip : equipList) {
            // ダミーデータを削除
            if (9 == equip.getRstClassFlg()) {
              continue;
            }
            // チェックリスト項目情報作成用
            OrdChecklistRegCheckInfo equipcheckinfo = settingEquipCheckInfo(checkinfo, equip);

            // 登録用
            OrdChecklist equipregdata = getdata.clone();
            // rst_checklist_info
            equipregdata.setRstChecklistInfo(equipcheckinfo);
            // チェックリスト実績登録
            getList.add(equipregdata);
          }
        }
        // add #283:仮想端末チェックリストを操作すると通信が切れる 劉 start
        // 投与薬剤の場合
        else if (Objects.equals(funcClass, (short) 3)) {
          if (classcd == null) {
            continue;
          }
          // 対象の薬剤取得
          List<OrdChecklistRegEquipInfo> equipList = getIndMediInfo(ordList.getIndMediInfo(), classcd, facilityCd);

          for (OrdChecklistRegEquipInfo equip : equipList) {
            // ダミーデータを削除
            if (9 == equip.getRstClassFlg()) {
              continue;
            }
            // チェックリスト項目情報作成用
            OrdChecklistRegCheckInfo equipcheckinfo = settingEquipCheckInfo(checkinfo, equip);
            // 登録用
            OrdChecklist equipregdata = getdata.clone();
            // rst_checklist_info
            equipregdata.setRstChecklistInfo(equipcheckinfo);
            // チェックリスト実績登録
            getList.add(equipregdata);
          }
        }
        // add #283:仮想端末チェックリストを操作すると通信が切れる 劉 end
      }
      break;

    }

    // 指定ordNoのチェックリスト実績取得
    List<OrdChecklist> nowdata = ordChecklistDao.selectByOrdNo(SelectOptions.get(), ordNo);

    for (int i = 0; i < getList.size(); i++) {
      for (int j = 0; j < nowdata.size(); j++) {
        // 既に登録されている場合
        if (Objects.equals(getList.get(i).getListCd(), nowdata.get(j).getListCd()) &&
            Objects.equals(getList.get(i).getFuncClass(), nowdata.get(j).getFuncClass()) &&
            Objects.equals(getList.get(i).getRstChecklistInfo().getItemNumber(),
                nowdata.get(j).getRstChecklistInfo().getItemNumber())
            &&
            Objects.equals(getList.get(i).getRstChecklistInfo().getClassCd(),
                nowdata.get(j).getRstChecklistInfo().getClassCd())
            &&
            Objects.equals(getList.get(i).getRstChecklistInfo().getCode(),
                nowdata.get(j).getRstChecklistInfo().getCode())
          // del 10310 needle _ typeの使用を削除するには gjn start
//            &&
//            Objects.equals(getList.get(i).getRstChecklistInfo().getNeedleType(),
//                nowdata.get(j).getRstChecklistInfo().getNeedleType())
          // del 10310 needle _ typeの使用を削除するには gjn end
        ) {
          getList.set(i, nowdata.get(j));
        }
      }

    }

    return getList;
  }

  /**
   * チェックリスト実績情報を取得する
   * {@inheritDoc}
   */
  @Override
  public List<OrdChecklist> getAfterCheckListByListCd(Long ordNo, Short listCd) {

    List<OrdChecklist> ordCheckList = ordChecklistDao.selectByOrdNoListCd(SelectOptions.get(), ordNo, listCd);

    Long checklistCd = null;
    if (ordCheckList.size() > 0) {
      checklistCd = ordCheckList.get(0).getRstChecklistInfo().getChecklistCd();
    }
    if (Objects.isNull(checklistCd)) {
      // マスタ情報取得できない
      return ordCheckList;
    }
    MstChecklist mstCheckList = mstChecklistDao.selectByChecklistCd(SelectOptions.get(), checklistCd);
    if (Objects.isNull(mstCheckList)) {
      // マスタ情報取得できない
      return ordCheckList;
    }
    String strSetting = mstCheckList.getChecklistSettings();
    ObjectMapper map = new ObjectMapper();
    JsonNode node = null;
    try {
      node = map.readTree(strSetting);
    } catch (IOException e) {
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
      // マスタ情報解析できない
      return ordCheckList;
    }

    // #11589 2025.03.10 add アイテムについてマスタの並び順で表示を行う TDC米沢 start
    // 施設コード
    String facilityCd = ordCheckList.get(0).getFacilityCd();

    // 使用する各マスタの並び順を取得
    List<MstSelector> selectors = mstSelectorDao.selectByNameList(facilityCd, Arrays.asList(
      MST_DIALYZER_PHYSICAL_NAME,
      MST_EQUIPMENT_PHYSICAL_NAME,
      MST_MEDICINE_PHYSICAL_NAME,
      MST_MEDICINE_MIX_PHYSICAL_NAME
    ));
    // マスタの並び順とチェックリスト実績の格納先
    Map<Long, OrdChecklist> checklistOrder = new HashMap<>();
    Map<Long, OrdChecklist> checklistOrder2 = new HashMap<>();
    List<Long> sortedCodes;
    List<Long> sortedCodes2;
    Object[] orderedKeys;
    Long noKeyValue;
    Long sortKeyValue;
    // #11589 2025.03.10 add アイテムについてマスタの並び順で表示を行う TDC米沢 end

    List<OrdChecklist> retOrdCheckList = new ArrayList<>();

    // リストコード分繰り返し
    for (int i = 0; i < node.size(); i++) {
      JsonNode setting = null;
      try {
        setting = map.readTree(node.get(i).toString());
      } catch (IOException e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
        EventLogMessage eventLogMessage = new EventLogMessage();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
        // マスタ情報解析できない
        continue;
      }

      // リストコード
      Short listcd = Short.parseShort(setting.get("list_cd").asText());
      if (!Objects.equals(listcd, listCd)) {
        // 収集対象のリストコードと異なっているならば次へ行く
        continue;
      }

      JsonNode funclist = null;
      try {
        funclist = map.readTree(setting.get("funclist").toString());
      } catch (IOException e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
        EventLogMessage eventLogMessage = new EventLogMessage();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
        // マスタ情報解析できない
        continue;
      }

      // funclist分繰り返し
      for (int j = 0; j < funclist.size(); j++) {
        JsonNode list = null;
        try {
          list = map.readTree(funclist.get(j).toString());
        } catch (IOException e) {
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
          EventLogMessage eventLogMessage = new EventLogMessage();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
          // マスタ情報解析できない
          continue;
        }

        // 機能種別(func_class)
        String strfuncclass = list.get("func_class").toString();
        Short funcclass = null;
        if (!strfuncclass.equals("null")) {
          funcclass = Short.parseShort(list.get("func_class").toString());
        }
        // 未登録の場合
        if (funcclass == null) {
          continue;
        }
        // itemNo
        Integer itemNo = list.has("item_number") ? list.get("item_number").asInt() : null;
        // class_cd
        String classcode = list.get("class_cd").toString();
        Integer classcd = null;
        if (!classcode.equals("null")) {
          classcd = list.get("class_cd").asInt();
        }

        if (Objects.equals(funcclass, (short) 0)) {
          // 通常リストの場合
          for (OrdChecklist ord : ordCheckList) {
            // 実績分繰り返す
            if (Objects.isNull(ord.getRstChecklistInfo())
                || Objects.isNull(ord.getRstChecklistInfo().getItemNumber())) {
              // 実績情報なし
              continue;
            }
            // item_numberが一致する
            if (itemNo != null
              && itemNo == ord.getRstChecklistInfo().getItemNumber().intValue()) {
              // 返り値用配列に追加
              retOrdCheckList.add(ord);
            }
          }
        } else if (Objects.equals(funcclass, (short) 1)) {
          // 治療条件の場合
          if (classcd == null) {
            continue;
          }
          List<OrdChecklist> tmpOrdCheckList = new ArrayList<>();
          for (OrdChecklist ord : ordCheckList) {
            // 実績分繰り返す
            if (Objects.isNull(ord.getRstChecklistInfo())
                || Objects.isNull(ord.getRstChecklistInfo().getItemNumber())) {
              // 実績情報なし
              continue;
            }
            // item_numberが一致する
            if (itemNo != null && itemNo == ord.getRstChecklistInfo().getItemNumber().intValue()) {
              // 返り値用配列に追加
              tmpOrdCheckList.add(ord);
            }
          }

          if (Objects.equals(classcd, 5)) {
            // ダイアライザの場合
            for (int cd : Arrays.asList(5, 6, 7, 8)) {
              for (OrdChecklist ord : tmpOrdCheckList) {
                //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
                //  if (ord.getRstChecklistInfo().getClassCd() != null
                //    && ord.getRstChecklistInfo().getClassCd() == cd) {
                if (ord.getRstChecklistInfo().getClassCd() != null
                    && ord.getRstChecklistInfo().getClassCd() == cd && ord.getRstClass() != 9
                  && ord.getRstClass() != 8 && ord.getRstClass() != 7) {
                  //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end
                  // 返り値用配列に追加
                  retOrdCheckList.add(ord);
                }
              }
            }
            // 吸着カラムはダイアライザと同時設定にしたので除外
          } else if (Objects.equals(classcd, 6)) {
            continue;
          } else if (Objects.equals(classcd, 9)) {
            // 穿刺針の場合
            for (int cd : Arrays.asList(9, 10, 11)) {
              for (OrdChecklist ord : tmpOrdCheckList) {
              //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
              //  if (ord.getRstChecklistInfo().getClassCd() != null
              //    && ord.getRstChecklistInfo().getClassCd() == cd) {
                if (ord.getRstChecklistInfo().getClassCd() != null
                    && ord.getRstChecklistInfo().getClassCd() == cd && ord.getRstClass() != 9
                  && ord.getRstClass() != 8 && ord.getRstClass() != 7) {
                  //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end
                  // 返り値用配列に追加
                  retOrdCheckList.add(ord);
                }
              }
            }
          } else {
            //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
            //  retOrdCheckList.addAll(tmpOrdCheckList);
            for (OrdChecklist ord : tmpOrdCheckList) {
              // 返り値用配列に追加
              if (ord.getRstClass() != 9 && ord.getRstClass() != 8 && ord.getRstClass() != 7) {
                retOrdCheckList.add(ord);
              }
            }
            //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end
          }
        } else if (Objects.equals(funcclass, (short) 2)) {
          // 医療材料の場合

          if (classcd == null) {
            continue;
          }
          // #11589 2025.03.10 add アイテムについてマスタの並び順で表示を行う TDC米沢 start
//           List<OrdChecklist> tmpOrdCheckList = new ArrayList<>();
//           for (OrdChecklist ord : ordCheckList) {
//             // ダミーデータを削除
//             //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
//             //  if (9 == ord.getRstClass()) {
//             if (9 == ord.getRstClass()|| 8 == ord.getRstClass() || 7 == ord.getRstClass()) {
//               //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end
//               continue;
//             }
//
//             // 実績分繰り返す
//             if (Objects.isNull(ord.getRstChecklistInfo())
//                 || Objects.isNull(ord.getRstChecklistInfo().getItemNumber())) {
//               // 実績情報なし
//               continue;
//             }
//             // item_numberが一致する
//             if (itemNo != null && itemNo == ord.getRstChecklistInfo().getItemNumber().intValue()) {
//               // 返り値用配列に追加
//               tmpOrdCheckList.add(ord);
//             }
//           }
//           tmpOrdCheckList.sort((s1, s2) -> {
//             if (s1.getRstChecklistInfo().getName() == null) {
//               return 1;
//             } else if (s2.getRstChecklistInfo().getName() == null) {
//               return -1;
//             }
//             return s1.getRstChecklistInfo().getName().compareTo(s2.getRstChecklistInfo().getName());
//           });
//
// //          for (OrdChecklist ord : tmpOrdCheckList) {
// //            // 返り値用配列に追加
// //            retOrdCheckList.add(ord);
// //          }
//           retOrdCheckList.addAll(tmpOrdCheckList);

          // ダイアライザマスタの並び順を取得
          sortedCodes = selectors.stream()
            .filter(selector-> selector.getMasterPhysicalName().equals(MST_DIALYZER_PHYSICAL_NAME))
            .findFirst().get().getOrderSettings().getItems().stream().map(MstSelector.Item::getCode).toList();

          // 医療材料マスタの並び順を取得
          sortedCodes2 = selectors.stream()
            .filter(selector-> selector.getMasterPhysicalName().equals(MST_EQUIPMENT_PHYSICAL_NAME))
            .findFirst().get().getOrderSettings().getItems().stream().map(MstSelector.Item::getCode).toList();

          noKeyValue = Long.MAX_VALUE - 1000L;

          checklistOrder.clear();
          for (OrdChecklist ord : ordCheckList) {
            // ダミーデータを削除
            //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
            //  if (9 == ord.getRstClass()) {
            if (9 == ord.getRstClass()|| 8 == ord.getRstClass() || 7 == ord.getRstClass()) {
              //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end
              continue;
            }

            // 実績分繰り返す
            if (Objects.isNull(ord.getRstChecklistInfo())
              || Objects.isNull(ord.getRstChecklistInfo().getItemNumber())) {
              // 実績情報なし
              continue;
            }

            // item_numberが一致する
            if (itemNo != null && itemNo == ord.getRstChecklistInfo().getItemNumber().intValue()) {
              Long code = ord.getRstChecklistInfo().getCode().longValue();
              // 分類種別を判定して表示順を取得
              Integer classCd = ord.getRstChecklistInfo().getClassCd().intValue();
              if(classCd.equals(0)) {
                // ダイアライザ

                // マスタ並び順を取得
                sortKeyValue = (long)sortedCodes.indexOf(code);
              } else {
                // その他

                // マスタ並び順を取得
                sortKeyValue = (long)sortedCodes2.indexOf(code);
              }

              // 並び順をキー値としてチェックリスト情報を保持
              checklistOrder.put(sortKeyValue.equals((long)-1) ? noKeyValue : sortKeyValue, ord);
              noKeyValue++;
            }
          }

          // 表示順でソート
          orderedKeys = checklistOrder.keySet().toArray();
          Arrays.sort(orderedKeys);
          for (Object orderedKey : orderedKeys) {
            // ソート結果からチェックリスト実績を取得する
            retOrdCheckList.add(checklistOrder.get((Long)orderedKey));
          }
          // #11589 2025.03.10 add アイテムについてマスタの並び順で表示を行う TDC米沢 end

        } else if (Objects.equals(funcclass, (short) 3)) {
          // 投与薬剤の場合

          if (classcd == null) {
            continue;
          }

          // #11589 2025.03.10 add アイテムについてマスタの並び順で表示を行う TDC米沢 start
//           List<OrdChecklist> tmpOrdCheckList = new ArrayList<>();
//           for (OrdChecklist ord : ordCheckList) {
//             // ダミーデータを削除
//             //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
//             //  if (9 == ord.getRstClass()) {
//             if (9 == ord.getRstClass()|| 8 == ord.getRstClass() || 7 == ord.getRstClass()) {
//               //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end
//               continue;
//             }
//
//             // 実績分繰り返す
//             if (Objects.isNull(ord.getRstChecklistInfo())
//               || Objects.isNull(ord.getRstChecklistInfo().getItemNumber())) {
//               // 実績情報なし
//               continue;
//             }
//             // item_numberが一致する
//             if (itemNo != null && itemNo == ord.getRstChecklistInfo().getItemNumber().intValue()) {
//               // 返り値用配列に追加
//               tmpOrdCheckList.add(ord);
//             }
//           }
//           Collections.sort(tmpOrdCheckList, (s1, s2) -> {
//             if (s1.getRstChecklistInfo().getName() == null) {
//               return 1;
//             } else if (s2.getRstChecklistInfo().getName() == null) {
//               return -1;
//             }
//             return s1.getRstChecklistInfo().getName().compareTo(s2.getRstChecklistInfo().getName());
//           });
//
// //          for (OrdChecklist ord : tmpOrdCheckList) {
// //            // 返り値用配列に追加
// //            retOrdCheckList.add(ord);
// //          }
//           retOrdCheckList.addAll(tmpOrdCheckList);

          // 薬剤マスタの並び順を取得
          sortedCodes = selectors.stream()
            .filter(selector-> selector.getMasterPhysicalName().equals(MST_MEDICINE_PHYSICAL_NAME))
            .findFirst().get().getOrderSettings().getItems().stream().map(MstSelector.Item::getCode).toList();

          // 調整薬剤マスタの並び順を取得
          sortedCodes2 = selectors.stream()
            .filter(selector-> selector.getMasterPhysicalName().equals(MST_MEDICINE_MIX_PHYSICAL_NAME))
            .findFirst().get().getOrderSettings().getItems().stream().map(MstSelector.Item::getCode).toList();

          noKeyValue = Long.MAX_VALUE - 1000L;

          checklistOrder.clear();
          checklistOrder2.clear();
          for(OrdChecklist ord : ordCheckList) {
            // ダミーデータを削除
            //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
            //  if (9 == ord.getRstClass()) {
            if (9 == ord.getRstClass()|| 8 == ord.getRstClass() || 7 == ord.getRstClass()) {
              //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end
              continue;
            }

            // 実績分繰り返す
            if (Objects.isNull(ord.getRstChecklistInfo())
              || Objects.isNull(ord.getRstChecklistInfo().getItemNumber())) {
              // 実績情報なし
              continue;
            }

            // item_numberが一致する
            if (itemNo != null && itemNo == ord.getRstChecklistInfo().getItemNumber().intValue()) {
              // 薬剤種別を判定
              Integer medicineType = ord.getRstChecklistInfo().getMedicineType().intValue();
              if( medicineType.equals(2)) {
                // 調整薬剤

                // マスタ並び順を取得
                sortKeyValue = (long)sortedCodes2.indexOf(ord.getRstChecklistInfo().getCode().longValue());
                // 並び順をキー値としてチェックリスト情報を保持
                checklistOrder2.put(sortKeyValue.equals((long)-1) ? noKeyValue : sortKeyValue, ord);
              } else {
                // 薬剤

                // マスタ並び順を取得
                sortKeyValue = (long)sortedCodes.indexOf(ord.getRstChecklistInfo().getCode().longValue());
                // 並び順をキー値としてチェックリスト情報を保持
                checklistOrder.put(sortKeyValue.equals((long)-1) ? noKeyValue : sortKeyValue, ord);
              }
              noKeyValue++;
            }
          }

          // 表示順でソート：薬剤
          orderedKeys = checklistOrder.keySet().toArray();
          Arrays.sort(orderedKeys);
          for (Object orderedKey : orderedKeys) {
            // ソート結果からチェックリスト実績を取得する
            retOrdCheckList.add(checklistOrder.get((Long)orderedKey));
          }
          // 表示順でソート：調整薬剤
          orderedKeys = checklistOrder2.keySet().toArray();
          Arrays.sort(orderedKeys);
          for (Object orderedKey : orderedKeys) {
            // ソート結果からチェックリスト実績を取得する
            retOrdCheckList.add(checklistOrder2.get((Long)orderedKey));
          }

          // #11589 2025.03.10 add アイテムについてマスタの並び順で表示を行う TDC米沢 end
        }
      }
    }
    for (OrdChecklist ord : ordCheckList) {
      // ダミーデータを削除
      //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
      //  if (9 == ord.getRstClass()) {
      if (9 == ord.getRstClass() || 8 == ord.getRstClass() || 7 == ord.getRstClass()) {
        //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end
        continue;
      }

      if (!retOrdCheckList.contains(ord)) {
        // マスタ順整列で追加されていない実績があったら追加する
        retOrdCheckList.add(ord);
      }
    }
    return retOrdCheckList;
  }

  /**
   * 条件送信前のチェックリスト情報（仮想端末用データ）を取得する
   * {@inheritDoc}
  * @throws IOException
   */
  @Override
  public List<ComsvChecklistResponse> getBeforeCheckList(Long ordNo, Short listCd, String facilityCd)
      throws IOException {

    List<OrdChecklist> ordCheckList = getBeforeCheckListByListCd(ordNo, listCd, facilityCd);

    List<ComsvChecklistResponse> res = ComsvChecklistResponseMake(ordCheckList);

    return res;
  }

  /**
   * チェックリスト実績情報（仮想端末用データ）を取得する
   * {@inheritDoc}
   */
  @Override
  public List<ComsvChecklistResponse> getAfterCheckList(Long ordNo, Short listCd) {

    List<OrdChecklist> ordCheckList = getAfterCheckListByListCd(ordNo, listCd);

    List<ComsvChecklistResponse> res = ComsvChecklistResponseMake(ordCheckList);

    return res;
  }

  /**
  * チェックリスト実績情報から仮想端末用データ作成
  * @param ordCheckList チェックリスト実績情報
  */
  public List<ComsvChecklistResponse> ComsvChecklistResponseMake(List<OrdChecklist> ordCheckListArray) {

    List<ComsvChecklistResponse> res = new ArrayList<>();
    int dispNo = 0;

    for (OrdChecklist ordCheckList : ordCheckListArray) {
      ComsvChecklistResponse r = new ComsvChecklistResponse();
      //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
      // r.setClassCd(ordCheckList.getRstChecklistInfo().getClassCd());
      r.setClassCd(ordCheckList.getRstChecklistInfo().getClassCd() != null?ordCheckList.getRstChecklistInfo().getClassCd().toString() : "null");
      //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end
      r.setCode(ordCheckList.getRstChecklistInfo().getCode());
      r.setIsCheck(ordCheckList.getIsCheck());
      r.setItemNumber(ordCheckList.getRstChecklistInfo().getItemNumber());
      r.setName(ordCheckList.getRstChecklistInfo().getName());
      String upStr = null;
      Timestamp upTime = null;
      if (ordCheckList.getOccurDate() != null) {
        upStr = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSXXX").format(ordCheckList.getOccurDate());
      }
      r.setRegStaffUpDate(upStr); // 互換性のために残す。
      r.setOccurDate(upStr);
      upStr = null;
      upTime = ordCheckList.getUpDate();
      if (upTime != null) {
        upStr = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSXXX").format(upTime);
      }
      r.setUpDate(upStr);
      r.setDispNo(++dispNo);
      res.add(r);
    }
    return res;
  }

  @Getter
  @Setter
  private class recvCheckListParam {
    /**
     * チェックリストマスタ.チェックリスト設定.機能リスト.分類コード,
     */
    private Integer classCd;
    /**
     * 各マスタの主キー
     */
    private Integer code;
    /**
     * チェックリストマスタ.チェックリスト設定.機能リスト.項目番号
     */
    private Short itemNumber;
  }

  /**
   * チェックリスト実績情報（仮想端末用データ）を更新する
   * @param facilityCd 施設コード
   * @param noJson 配列（json） { "classCd": number, "code": number, "itemNumber": number, "cd": number, date: string }
   * @param ordCheckList チェックリスト実績情報
   * @return
   */
  @Override
  @Transactional
  //mod #283:仮想端末チェックリストを操作すると通信が切れる 劉 start
  //public int updateOrdChecklist(String facilityCd, String noJson, List<OrdChecklist> ordCheckListArray) {
  public int updateOrdChecklist(Short send_flg, String facilityCd, String noJson, List<OrdChecklist> ordCheckListArray) {
  //mod #283:仮想端末チェックリストを操作すると通信が切れる 劉 end
    int rtn = 0;
    Long staff_cd = 0l;
    String regStr = null;
    Timestamp regDate = null;

    // JSON処理
    List<recvCheckListParam> paramList = new ArrayList<recvCheckListParam>();
    ObjectMapper mapper = new ObjectMapper();
    try {
      JsonNode jsonNode_array = mapper.readTree(noJson);
      for (int lop = 0; lop < jsonNode_array.size(); lop++) {
        JsonNode jsonNode = jsonNode_array.get(lop);
        recvCheckListParam param = new recvCheckListParam();
        // jsonNodeは読み取り専用のため、ObjectNodeに変換
        ObjectNode objectNode = jsonNode.deepCopy();

        int no = objectNode.get("itemNumber").asInt();
        param.setItemNumber((short) no);
        // #12275 mod 2025.09.17 classCdで未分類[-1]が処理できない TDC米沢 start
        // int classCd = objectNode.get("classCd").asInt(-1);
        // //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
        // // param.setClassCd(classCd <= 0 ? null : classCd);
        // param.setClassCd(classCd < 0 ? null : classCd);
        // // mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end
        int classCd = objectNode.get("classCd").asInt(Integer.MIN_VALUE);
        param.setClassCd(classCd == Integer.MIN_VALUE ? null : classCd);
        // #12275 mod 2025.09.17 classCdで未分類[-1]が処理できない TDC米沢 end
        int code = objectNode.get("code").asInt(-1);
        param.setCode(code <= 0 ? null : code);
        paramList.add(param);

        // 実施者情報あり
        staff_cd = objectNode.get("cd").asLong();
        regStr = objectNode.get("date").asText();
        if (!(regStr.equals("null"))) {
          DateTimeFormatter dtf = DateTimeFormatter.ofPattern("uuuuMMddHHmmss");
          regDate = Timestamp.valueOf(LocalDateTime.parse(regStr, dtf));
          regStr = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSXXX").format(regDate);
          regDate = new Timestamp(new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSXXX").parse(regStr).getTime());
        }
      }
    } catch (IOException e) {
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
      return rtn;
    } catch (ParseException e) {
      // TODO 自動生成された catch ブロック
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

    int count = 0;
    List<OrdChecklist> upCheckList = new ArrayList<>();
    for (OrdChecklist ordCheckList : ordCheckListArray) {
      short itemNo = ordCheckList.getRstChecklistInfo().getItemNumber();
      for (recvCheckListParam param : paramList) {
        if (itemNo == param.getItemNumber().shortValue()) {
          Short funcClass = ordCheckList.getFuncClass();
          if (funcClass == null) {
            continue;
          } else if (funcClass.shortValue() == (short) 0) {
            // 通常リスト
            // 特筆すべきことなし
          } else {
            // 治療条件/医療材料
            Integer classCd = ordCheckList.getRstChecklistInfo().getClassCd();
            Integer code = ordCheckList.getRstChecklistInfo().getCode();
            if (!(classCd != null &&
                Objects.equals(classCd, param.getClassCd()) &&
                Objects.equals(code, param.getCode()))) {
              // 分類コードと識別コードが同じもの以外はスキップ
              continue;
            }
          }

          // 値の変更
          ordCheckList.setIsCheck("1");
          if (staff_cd != 0) {
            // 実施者情報あり
            ordCheckList.getRegStaffInfo().setRegStaffCd(staff_cd);
            /* add #IES_6779 チェックリスト画面：在透析机执行check时，チェックリスト页面中不显示实施者 by zhangruixue 2023-07-03 --start */
            ordCheckList.getRegStaffInfo().setRegStaffName(mstPersonalUserDao.selectUserNameById(staff_cd));
            /* add #IES_6779  by zhangruixue 2023-07-03 --end */
            // スタッフマスタから更新日を取得してそれをセットする
            MstUser mstUser = mstUserDao.selectById(staff_cd);
            if (mstUser != null) {
              Timestamp upDate = mstUser.getUpDate();
              ordCheckList.getRegStaffInfo().setRegStaffUpdate(DateTimeUtils.getDateString_iso8601(upDate));
            }
          }
          // #12271 2025.10.08 mod 処置項目選択時に実施時刻を記録し、処置者入力のときには記録しない TDC片口 start
          // ordCheckList.setOccurDate(regDate);
          if (regDate != null){
          ordCheckList.setOccurDate(regDate);
          }
          // #12271 2025.10.08 mod 処置項目選択時に実施時刻を記録し、処置者入力のときには記録しない TDC片口 end
          upCheckList.add(ordCheckList);
          count++;
        }
      }
    }

    if (count > 0) {
      // 更新有なら
      try {
        // チェックリスト実績更新
        //mod #283:仮想端末チェックリストを操作すると通信が切れる 劉 start
        //ordChecklistUpdate(upCheckList, facilityCd);
        ordChecklistUpdate(send_flg, upCheckList, facilityCd);
        //mod #283:仮想端末チェックリストを操作すると通信が切れる 劉 end
        rtn = 1;
      } catch (Exception e) {
        rtn = -1;
      }
    }

    return rtn;
  }

}
