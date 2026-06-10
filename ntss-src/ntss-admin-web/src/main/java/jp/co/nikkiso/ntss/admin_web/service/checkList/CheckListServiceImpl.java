package jp.co.nikkiso.ntss.admin_web.service.checkList;

// add #7857-【デグレ】チェックリストマスタとチェックリストが正しくコンバートされなくなっている 徐博 start
import java.beans.BeanInfo;
import java.beans.Introspector;
import java.beans.PropertyDescriptor;
// add #7857-【デグレ】チェックリストマスタとチェックリストが正しくコンバートされなくなっている 徐博 end
import java.io.IOException;
// add #7857-【デグレ】チェックリストマスタとチェックリストが正しくコンバートされなくなっている 徐博 start
import java.lang.reflect.Method;
// add #7857-【デグレ】チェックリストマスタとチェックリストが正しくコンバートされなくなっている 徐博 end
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.text.DecimalFormat;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.node.ArrayNode;
import jp.co.nikkiso.ntss.admin_web.response.patIndApprove.ItemInfo;
import jp.co.nikkiso.ntss.admin_web.response.patIndApprove.PatIndApproveDto;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.SelectHistoryUtils;
import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.statusList.TreatmentStatusListService;
import jp.co.nikkiso.ntss.admin_web.service.utils.MasterCacheHandler;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.MstChecklistDao;
import jp.co.nikkiso.ntss.core.dao.MstDialyzerDao;
import jp.co.nikkiso.ntss.core.dao.MstEquipmentDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilitySettingDao;
import jp.co.nikkiso.ntss.core.dao.MstMedicateTimingDao;
import jp.co.nikkiso.ntss.core.dao.MstMedicineDao;
import jp.co.nikkiso.ntss.core.dao.MstMedicineMixDao;
import jp.co.nikkiso.ntss.core.dao.MstPersonalUserDao;
import jp.co.nikkiso.ntss.core.dao.MstProcedureDao;
import jp.co.nikkiso.ntss.core.dao.MstSelectorDao;
import jp.co.nikkiso.ntss.core.dao.OrdChecklistDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.OrdMaterialSaveDao;
import jp.co.nikkiso.ntss.core.dao.PatIndApproveDao;
import jp.co.nikkiso.ntss.core.dao.PatMainDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.dao.PatUniqueDao;
import jp.co.nikkiso.ntss.core.dao.TreatmentStatusListDao;
import jp.co.nikkiso.ntss.core.entity.ChecklistSettings;
import jp.co.nikkiso.ntss.core.entity.FuncList;
import jp.co.nikkiso.ntss.core.entity.MstChecklist;
import jp.co.nikkiso.ntss.core.entity.MstDialyzer;
import jp.co.nikkiso.ntss.core.entity.MstEquipment;
import jp.co.nikkiso.ntss.core.entity.MstMedicateTiming;
import jp.co.nikkiso.ntss.core.entity.MstMedicine;
import jp.co.nikkiso.ntss.core.entity.MstMedicineMix;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.entity.MstProcedure;
import jp.co.nikkiso.ntss.core.entity.MstSelector;
import jp.co.nikkiso.ntss.core.entity.OrdCheckListParams;
import jp.co.nikkiso.ntss.core.entity.OrdChecklist;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.PatIndApprove;
import jp.co.nikkiso.ntss.core.entity.PatMain;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.custom.PatUniquePhysicalInfo;
import jp.co.nikkiso.ntss.core.logevent.DataUpdateLogCommonNew;
import jp.co.nikkiso.ntss.core.logevent.LogServiceCore;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.utils.TriggerUtil;
import lombok.Data;
import org.apache.commons.collections4.CollectionUtils;
import org.json.JSONArray;
import org.json.JSONObject;
import org.modelmapper.ModelMapper;
import org.seasar.doma.Domain;
import org.seasar.doma.jdbc.Config;
import org.seasar.doma.jdbc.SelectOptions;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.FlagType;
import jp.co.nikkiso.ntss.admin_web.response.checkList.CheckListScheduleResponse;
import jp.co.nikkiso.ntss.admin_web.response.checkList.ChecklistUpdateResponse;
import jp.co.nikkiso.ntss.admin_web.response.checkList.MediUpdateResponse;
import jp.co.nikkiso.ntss.admin_web.response.checkList.OrdChecklistWithUserNameResponse;
import jp.co.nikkiso.ntss.admin_web.response.checkList.dto.IndMediInfoDto;
import jp.co.nikkiso.ntss.admin_web.response.checkList.dto.ReceiveRstMediInfoDto;
import jp.co.nikkiso.ntss.admin_web.response.checkList.dto.RstMediInfoDto;
import jp.co.nikkiso.ntss.admin_web.service.utils.DateTimeUtils;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.FacilitySettingNo;
import jp.co.nikkiso.ntss.core.entity.OrdChecklist.OrdChecklistRegCheckInfo;
import jp.co.nikkiso.ntss.core.entity.OrdChecklist.OrdChecklistRegStaffInfo;
import jp.co.nikkiso.ntss.core.entity.custom.FacilitySettingInfo;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainForCheckListSchedule;
import jp.co.nikkiso.ntss.core.entity.custom.TreatmentStatusList;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.springframework.util.ObjectUtils;
import org.springframework.util.StringUtils;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

@Service
public class CheckListServiceImpl implements CheckListService {

  @Autowired
  private OrdMainDao ordMainDao;
  // add 11613 by shiyw 20250303 start
  @Autowired
  private OrdMaterialSaveDao ordMaterialSaveDao;
  // add 11613 by shiyw 20250303 end
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
  private TreatmentStatusListDao treatmentStatusListDao;
  @Autowired
  private PatMainDao patMainDao;
  @Autowired
  private MstMedicineMixDao mstMedicineMixDao;
  @Autowired
  private MstFacilitySettingDao mstFacilitySettingDao;

  // add FNSI-改修内容追加OrdMain履歴 付 start
  @Autowired
  private SelectHistoryUtils selectHistoryUtils;
  // add FNSI-改修内容追加OrdMain履歴 付 end

  @Autowired
  private TriggerUtil triggerUtil;

  @Autowired
  PatIndApproveDao patIndApproveDao;

  @Autowired
  LogService logService;

  /**
   * データなし時のテキスト
   */
  final String NO_DATA = "未登録";
  /**
   * JSONキー名 指示者姓
   */
  final String IND_USER_LAST_NAME = "ind_user_last_name";
  /**
   * JSONキー名 指示者名
   */
  final String IND_USER_FIRST_NAME = "ind_user_first_name";
  /**
   * JSONキー名 更新者姓
   */
  final String UPD_USER_LAST_NAME = "upd_user_last_name";
  /**
   * JSONキー名 更新者名
   */
  final String UPD_USER_FIRST_NAME = "upd_user_first_name";

  /**
   * ObjectMapper.
   */
  @Autowired
  private ObjectMapper mapper;

  // DB更新ログ出力ロジック wangzuo Start
  @Autowired
  private EventLoggerFactory eventLoggerFactory;
  @Autowired
  private LogServiceCore logServiceCore;
  // DB更新ログ出力ロジック wangzuo End

  @Autowired
  private TreatmentStatusListService treatmentStatusListService;


  // #11589 2025.02.28 add 各アイテムについてマスタの並び順で表示を行う TDC米沢 start
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
  // #11589 2025.02.28 add 各アイテムについてマスタの並び順で表示を行う TDC米沢 end

  //add #9507 一括指示受けに時間がかかる zrx start
  @Autowired
  private PatUniqueDao patUniqueDao;
  //add #9507 一括指示受けに時間がかかる zrx end

  // add FNSI-チェックリスト仕様変更対応#401、#439_チェックリスト機能分。 周 start
  /**
   * 治療中のord_main情報取得
   * {@inheritDoc}
   */
  @Override
  public List<CheckListScheduleResponse> getOrdMainChiryouchuu(String facilityCd, Short nextPat) {
    List<CheckListScheduleResponse> res = new ArrayList<>();

    /* modify by chamaojia 2024-04-24 [10456] the patient inquiry is consistent with the treatment status --start */
//    // ①治療中「machine_entry = 2：現患者」「装置状態のord_noと一致する治療記録を取得」
//    //    ❶装置状態管理テーブル「オーダー番号（ord_no） の値があるもの」
//    //    ❷治療情報テーブル「実績：治療状況（rst_dialysis_state） = 0：条件送信前」
//    //    ❷治療情報テーブル「実績：治療状況（rst_dialysis_state） = 1：条件送信済」
//    //    ❷治療情報テーブル「実績：治療状況（rst_dialysis_state） = 2：条件送信確認済み」
//    //    ❷治療情報テーブル「実績：治療状況（rst_dialysis_state） = 4：排液済」「前体重入力待ち、または版確定まちで次患者がいない場合」
//    //    ❷治療情報テーブル「実績：治療状況（rst_dialysis_state） = 5：後体重測定済み(実績未確定)」「前体重入力待ち、または版確定まちで次患者がいない場合」
//    // ②治療中「machine_entry = 1：次患者」「装置状態のnext_ord_noと一致する治療記録を取得」
//    //    ❶「next_ord_noがord_noと一致しないものとord_noが空でnext_ord_noがあるもの」
//    //    ❷治療情報テーブル「削除フラグ（is_del） = 0：通常」
//    List<TreatmentStatusList> ordListChiryouchuu = treatmentStatusListDao.selectAll(facilityCd);
//    // ①版未確定分「machine_entry = 0：治療済み」
//    //    ❶治療情報テーブル「実績：治療状況（rst_dialysis_state） = 4：排液済」
//    //    ❶治療情報テーブル「実績：治療状況（rst_dialysis_state） = 5：後体重測定済み(実績未確定)」
//    //    ❷治療情報テーブル「削除フラグ（is_del） = 0：通常」
//    //    ❸治療情報テーブル「実績：版番号（rst_edition） = 0：デフォルト」
//    List<TreatmentStatusList> ordListChiryouzumi = treatmentStatusListDao.selectOrdMainUnedition(facilityCd);
//    // 情報の追加登録「治療済み⇒治療中」
//    ordListChiryouzumi.forEach(item -> {
//      // 同一情報の重複チェック
//      TreatmentStatusList state = ordListChiryouchuu.stream()
//        .filter(list -> Objects.equals(list.getOrdNo(), item.getOrdNo()))
//        .findFirst()
//        .orElse(null);
//      if (state == null) {
//        // 存在しない場合は追加
//        ordListChiryouchuu.add(item);
//      }
//    });

    List emptyList = new ArrayList();
    // query the current patient list（status1-5）
    List<TreatmentStatusList> ordListChiryouchuu = treatmentStatusListDao.selectTreatStatusListToOrd(facilityCd, emptyList, emptyList);
    // Short -> String
    String nextPatStr = nextPat.toString();
    if (!"0".equals(nextPatStr)) {
      // query secondary patients and organize data based on query criteria
      List<TreatmentStatusList> treatmentStatusListToNext = treatmentStatusListService.getNextPatTreatmentStatusInfo(facilityCd, nextPatStr, emptyList, emptyList);
      ordListChiryouchuu.addAll(treatmentStatusListToNext);
    }
    /* modify by chamaojia 2024-04-24 [10456] the patient inquiry is consistent with the treatment status --end */

    // 患者名取得用
    List<Long> patIdList = ordListChiryouchuu.stream()
      // add FNSI-一覧情報の表示条件を修正 周 start
      .filter(ord -> {
        String rstDialysisState = ord.getRstDialysisState();
        // 条件送信以降フラグ（０：false）
        boolean isIcouFlag = (rstDialysisState == null || "".equals(rstDialysisState) || "0".equals(rstDialysisState)) ? false : true;
        if (isIcouFlag) {
          // 以降場合⇒実績情報
          return !(
            (jsonNodeIsNull(ord.getRstKurName()) || "".equals(ord.getRstKurName())) &&
              (jsonNodeIsNull(ord.getRstBedName()) || "".equals(ord.getRstBedName()))
          );
        } else {
          // 前場合⇒予定情報
          return !(
            (jsonNodeIsNull(ord.getIndMstKurName()) || "".equals(ord.getIndMstKurName())) &&
              (jsonNodeIsNull(ord.getIndMstBedName()) || "".equals(ord.getIndMstBedName()))
          );
        }
      })
      // add FNSI-一覧情報の表示条件を修正 周 end
      .map(s -> s.getPatId())
      .collect(Collectors.toList());
    // null削除
    patIdList.removeAll(Collections.singleton(null));

    List<PatPersonalMain> pats = patPersonalMainDao.selectByIdListFacilityCd(patIdList, facilityCd);
    List<PatPersonalMain> pat;
    List<PatMain> patMains = patMainDao.selectByIdListFacilityCd(patIdList, facilityCd);
    List<PatMain> patMain;
    String patLastName = "";
    String patFirstName = "";
    String patName = "";
    String isSame = "0";
    Integer inOutClass = 0;
    // add FNSI-横展開 入院患者名の配布_チェックリスト機能分 周 start
    // 患者ID(院内表示用).
    String hospPatId = "";
    // add FNSI-横展開 入院患者名の配布_チェックリスト機能分 周 end
    // add FNSI-横展開 患者名ソート改善_チェックリスト機能分 周 start
    String patLastNameKana = "";
    String patFirstNameKana = "";
    String patNameKana = "";
    // add FNSI-横展開 患者名ソート改善_チェックリスト機能分 周 end

    for (TreatmentStatusList ord : ordListChiryouchuu) {
      // 治療状況取得
      // 治療情報テーブル「実績：治療状況（rst_dialysis_state）」
      // ※治療状況が空の場合は条件送信前扱い
      String rstDialysisState = ord.getRstDialysisState() == null ? "0"
        : ord.getRstDialysisState().isEmpty() ? "0" : ord.getRstDialysisState();
      // add FNSI-一覧情報の表示条件を修正 周 start
      // 条件送信以降フラグ（０：false）
      boolean isIcouFlag = (rstDialysisState == null || "".equals(rstDialysisState) || "0".equals(rstDialysisState)) ? false : true;
      if (isIcouFlag) {
        // 以降場合⇒実績情報
        if (
          (jsonNodeIsNull(ord.getRstKurName()) || "".equals(ord.getRstKurName())) &&
            (jsonNodeIsNull(ord.getRstBedName()) || "".equals(ord.getRstBedName()))
        ) {
          continue;
        }
      } else {
        // 前場合⇒予定情報
        if (
          (jsonNodeIsNull(ord.getIndMstKurName()) || "".equals(ord.getIndMstKurName())) &&
            (jsonNodeIsNull(ord.getIndMstBedName()) || "".equals(ord.getIndMstBedName()))
        ) {
          continue;
        }
      }
      // add FNSI-一覧情報の表示条件を修正 周 end
      // 追加フラグ
      boolean addflg = false;
      // 治療中の場合
      // 治療情報テーブル「実績：治療状況（rst_dialysis_state） = 1：条件送信済」
      // 治療情報テーブル「実績：治療状況（rst_dialysis_state） = 2：条件送信確認済み」
      // 治療情報テーブル「実績：治療状況（rst_dialysis_state） = 3：治療中」
      // 治療情報テーブル「実績：治療状況（rst_dialysis_state） = 4：排液済」
      // 治療情報テーブル「実績：治療状況（rst_dialysis_state） = 5：後体重測定済み(実績未確定)」
      if (!rstDialysisState.equals("0") && !rstDialysisState.equals("6")) {
        // 追加
        addflg = true;
      }
      // 次患者の場合
      // 「machine_entry = 1：次患者」 治療情報テーブル「実績：治療状況（rst_dialysis_state） = 0：条件送信前」
      if (rstDialysisState.equals("0") && ord.getMachineEntry().equals(1)) {
        // 追加
        addflg = true;
      }

      if (addflg) {
        // 患者情報取得
        Long patId = ord.getPatId() == null ? null : ord.getPatId();
        if (patId == null) {
          // ？？？？患者の場合
          patName = "？？？？";
          // add FNSI-横展開 入院患者名の配布_チェックリスト機能分 周 start
          isSame = "0";
          inOutClass = 0;
          // 患者ID(院内表示用).
          hospPatId = "";
          // add FNSI-横展開 入院患者名の配布_チェックリスト機能分 周 end
          // add FNSI-横展開 患者名ソート改善_チェックリスト機能分 周 start
          patLastName = "";
          patFirstName = "";
          patLastNameKana = "";
          patFirstNameKana = "";
          patNameKana = "";
          // add FNSI-横展開 患者名ソート改善_チェックリスト機能分 周 end
        } else {
          // 患者名取得
          pat = pats.stream().filter(p -> Objects.equals(p.getPat_id(), patId))
            .collect(Collectors.toList());
          patLastName = "";
          patFirstName = "";
          patName = "";
          // add FNSI-横展開 患者名ソート改善_チェックリスト機能分 周 start
          patLastNameKana = "";
          patFirstNameKana = "";
          patNameKana = "";
          // add FNSI-横展開 患者名ソート改善_チェックリスト機能分 周 end
          if (pat.size() > 0) {
            patLastName = pat.get(0).getPat_last_name() == null ? "" : pat.get(0).getPat_last_name();
            patFirstName = pat.get(0).getPat_first_name() == null ? "" : pat.get(0).getPat_first_name();
            patName = patLastName + " " + patFirstName;
            inOutClass = pat.get(0).getIn_out_class();
            // add FNSI-横展開 入院患者名の配布_チェックリスト機能分 周 start
            // 患者ID(院内表示用).
            hospPatId = pat.get(0).getHosp_pat_id();
            // add FNSI-横展開 入院患者名の配布_チェックリスト機能分 周 end
            // add FNSI-横展開 患者名ソート改善_チェックリスト機能分 周 start
            patLastNameKana = jsonNodeIsNull(pat.get(0).getPat_last_name_kana()) ? "" : pat.get(0).getPat_last_name_kana();
            patFirstNameKana = jsonNodeIsNull(pat.get(0).getPat_first_name_kana()) ? "" : pat.get(0).getPat_first_name_kana();
            patNameKana = patLastNameKana + " " + patFirstNameKana;
            // add FNSI-横展開 患者名ソート改善_チェックリスト機能分 周 end
            // 同姓同名取得
            patMain = patMains.stream().filter(p -> Objects.equals(p.getPat_id(), patId))
              .collect(Collectors.toList());
            if (patMain.size() > 0) {
              isSame = patMain.get(0).getIs_same();
            }
          }
        }

        // 応答用スケジュール情報作成
        CheckListScheduleResponse r = new CheckListScheduleResponse();
        r.setFacilityCd(facilityCd);
        r.setOrdNo(ord.getOrdNo());
        r.setPatId(patId);
        r.setPatName(patName);
        r.setPatFirstName(patFirstName);
        r.setPatLastName(patLastName);
        r.setIsSame(isSame);
        r.setTreatDate(ord.getTreatDate());
        r.setTreatWeek(ord.getTreatWeek().shortValue());
        r.setRstDialysisState(rstDialysisState);
        r.setIndMediInfo(ord.getIndMediInfo());
        r.setIndCondInfo(ord.getIndCondInfo());
        r.setIndEquipInfo(ord.getIndEquipInfo());
        r.setRstMediInfo(ord.getRstMediInfo());
        r.setRstCondInfo(ord.getRstCondInfo());
        r.setRstEquipInfo(ord.getRstEquipInfo());
        r.setMachineEntry(ord.getMachineEntry());
        r.setInOutClass(inOutClass);
        // add FNSI-横展開 入院患者名の配布_チェックリスト機能分 周 start
        // 患者ID(院内表示用).
        r.setHospPatId(hospPatId);
        // add FNSI-横展開 入院患者名の配布_チェックリスト機能分 周 end
        // add FNSI-横展開 患者名ソート改善_チェックリスト機能分 周 start
        r.setPatNameKana(patNameKana);
        r.setPatFirstNameKana(patFirstNameKana);
        r.setPatLastNameKana(patLastNameKana);
        // add FNSI-横展開 患者名ソート改善_チェックリスト機能分 周 end

        // 画面ソートで使用
        r.setBedOrderIndex(ord.getOrdIndex());   // ベッドマスタ表示順
        r.setKurStartTime(ord.getKurStartTime());// クール開始時刻

        // 治療状態判定
        // 治療情報テーブル「実績：治療状況（rst_dialysis_state） = 0：条件送信前」
        if (rstDialysisState.equals("0")) {
          // 条件送信前の場合
          r.setKurCd(ord.getIndKurCd());
          r.setKurName(ord.getIndMstKurName());
          r.setBedCd(ord.getIndBedCd());
          r.setBedName(ord.getIndMstBedName());
          r.setDeviceMode(ord.getIndTreatmentDeviceMode());
        } else {
          // 条件送信後の場合
          r.setKurCd(ord.getRstKurCd());
          // mod FNSI-一覧情報の表示条件を修正 周 start
          // r.setKurName(ord.getRsedCd());
          // r.setBedName(ord.getRstKurName());
          // r.setBedCd(ord.getRstBtBedName());
          r.setKurName(ord.getRstKurName());
          r.setBedCd(ord.getRstBedCd());
          r.setBedName(ord.getRstBedName());
          // mod FNSI-一覧情報の表示条件を修正 周 end
          r.setDeviceMode(ord.getRstTreatmentDeviceMode());

          // 治療状況判定
          LocalDateTime dt = null;
          if (rstDialysisState.equals("1") || rstDialysisState.equals("2")) {
            // 治療情報テーブル「実績：治療状況（rst_dialysis_state） = 1：条件送信済」
            // 治療情報テーブル「実績：治療状況（rst_dialysis_state） = 2：条件送信確認済み」
            // 条件送信日時
            dt = ord.getRstCondSendDate() == null ? null : ord.getRstCondSendDate().toLocalDateTime();
          } else {
            // 治療情報テーブル「実績：治療状況（rst_dialysis_state） = 3：治療中」
            // 治療情報テーブル「実績：治療状況（rst_dialysis_state） = 4：排液済」
            // 治療情報テーブル「実績：治療状況（rst_dialysis_state） = 5：後体重測定済み(実績未確定)」
            // 治療開始日時
            dt = ord.getRstStartDate() == null ? null : ord.getRstStartDate().toLocalDateTime();
          }

          // 治療日を更新
          if (dt != null) {
            r.setTreatDate(dt.format(DateTimeFormatter.ofPattern("yyyyMMdd")));
            r.setTreatWeek((short) dt.getDayOfWeek().getValue());
          }
        }

        res.add(r);
      }
    }

    return res;
  }

  /**
   * 指定日のord_main情報取得
   * {@inheritDoc}
   */
  @Override
  public List<CheckListScheduleResponse> getOrdMainShiteibi(String facilityCd, String treatDate) {
    List<CheckListScheduleResponse> res = new ArrayList<>();

    List<OrdMainForCheckListSchedule> ordListShiteibi = ordMainDao.selectByTreatDate(facilityCd, treatDate);
    // 患者名取得用
    List<Long> patIdList = ordListShiteibi.stream()
      // add FNSI-一覧情報の表示条件を修正 周 start
      .filter(ord -> {
        String rstDialysisState = ord.getRstDialysisState();
        // 条件送信以降フラグ（０：false）
        boolean isIcouFlag = (rstDialysisState == null || "".equals(rstDialysisState) || "0".equals(rstDialysisState)) ? false : true;
        if (isIcouFlag) {
          // 以降場合⇒実績情報
          return !(
            (jsonNodeIsNull(ord.getRstKurName()) || "".equals(ord.getRstKurName())) &&
              (jsonNodeIsNull(ord.getRstBedName()) || "".equals(ord.getRstBedName()))
          );
        } else {
          // 前場合⇒予定情報
          return !(
            (jsonNodeIsNull(ord.getIndKurName()) || "".equals(ord.getIndKurName())) &&
              (jsonNodeIsNull(ord.getIndBedName()) || "".equals(ord.getIndBedName()))
          );
        }
      })
      // add FNSI-一覧情報の表示条件を修正 周 end
      .map(s -> s.getPatId())
      .distinct()
      .collect(Collectors.toList());
    // null削除
    patIdList.removeAll(Collections.singleton(null));

    List<PatPersonalMain> pats = patPersonalMainDao.selectByIdListFacilityCd(patIdList, facilityCd);
    List<PatPersonalMain> pat;
    List<PatMain> patMains = patMainDao.selectByIdListFacilityCd(patIdList, facilityCd);
    List<PatMain> patMain;
    String patLastName = "";
    String patFirstName = "";
    String patName = "";
    String isSame = "0";
    Integer inOutClass = 0;
    // add FNSI-横展開 入院患者名の配布_チェックリスト機能分 周 start
    // 患者ID(院内表示用).
    String hospPatId = "";
    // add FNSI-横展開 入院患者名の配布_チェックリスト機能分 周 end
    // add FNSI-横展開 患者名ソート改善_チェックリスト機能分 周 start
    String patLastNameKana = "";
    String patFirstNameKana = "";
    String patNameKana = "";
    // add FNSI-横展開 患者名ソート改善_チェックリスト機能分 周 end

    for (OrdMainForCheckListSchedule ord : ordListShiteibi) {
      // 治療状態取得
      // 治療情報テーブル「実績：治療状況（rst_dialysis_state）」
      // ※治療状況が空の場合は条件送信前扱い
      String rstDialysisState = ord.getRstDialysisState() == null ? "0"
        : ord.getRstDialysisState().isEmpty() ? "0" : ord.getRstDialysisState();
      // add FNSI-一覧情報の表示条件を修正 周 start
      // 条件送信以降フラグ（０：false）
      boolean isIcouFlag = (rstDialysisState == null || "".equals(rstDialysisState) || "0".equals(rstDialysisState)) ? false : true;
      if (isIcouFlag) {
        // 以降場合⇒実績情報
        if (
          (jsonNodeIsNull(ord.getRstKurName()) || "".equals(ord.getRstKurName())) &&
            (jsonNodeIsNull(ord.getRstBedName()) || "".equals(ord.getRstBedName()))
        ) {
          continue;
        }
      } else {
        // 前場合⇒予定情報
        if (
          (jsonNodeIsNull(ord.getIndKurName()) || "".equals(ord.getIndKurName())) &&
            (jsonNodeIsNull(ord.getIndBedName()) || "".equals(ord.getIndBedName()))
        ) {
          continue;
        }
      }
      // add FNSI-一覧情報の表示条件を修正 周 end
      // 患者情報取得
      Long patId = ord.getPatId() == null ? null : ord.getPatId();
      if (patId == null) {
        // ？？？？患者の場合
        patName = "？？？？";
        // add FNSI-横展開 入院患者名の配布_チェックリスト機能分 周 start
        isSame = "0";
        inOutClass = 0;
        // 患者ID(院内表示用).
        hospPatId = "";
        // add FNSI-横展開 入院患者名の配布_チェックリスト機能分 周 end
        // add FNSI-横展開 患者名ソート改善_チェックリスト機能分 周 start
        patLastName = "";
        patFirstName = "";
        patLastNameKana = "";
        patFirstNameKana = "";
        patNameKana = "";
        // add FNSI-横展開 患者名ソート改善_チェックリスト機能分 周 end
      } else {
        // 患者名取得
        pat = pats.stream().filter(p -> Objects.equals(p.getPat_id(), patId))
          .collect(Collectors.toList());
        patLastName = "";
        patFirstName = "";
        patName = "";
        // add FNSI-横展開 患者名ソート改善_チェックリスト機能分 周 start
        patLastNameKana = "";
        patFirstNameKana = "";
        patNameKana = "";
        // add FNSI-横展開 患者名ソート改善_チェックリスト機能分 周 end
        if (pat.size() > 0) {
          patLastName = pat.get(0).getPat_last_name() == null ? "" : pat.get(0).getPat_last_name();
          patFirstName = pat.get(0).getPat_first_name() == null ? "" : pat.get(0).getPat_first_name();
          patName = patLastName + " " + patFirstName;
          inOutClass = pat.get(0).getIn_out_class();
          // add FNSI-横展開 入院患者名の配布_チェックリスト機能分 周 start
          // 患者ID(院内表示用).
          hospPatId = pat.get(0).getHosp_pat_id();
          // add FNSI-横展開 入院患者名の配布_チェックリスト機能分 周 end
          // add FNSI-横展開 患者名ソート改善_チェックリスト機能分 周 start
          patLastNameKana = jsonNodeIsNull(pat.get(0).getPat_last_name_kana()) ? "" : pat.get(0).getPat_last_name_kana();
          patFirstNameKana = jsonNodeIsNull(pat.get(0).getPat_first_name_kana()) ? "" : pat.get(0).getPat_first_name_kana();
          patNameKana = patLastNameKana + " " + patFirstNameKana;
          // add FNSI-横展開 患者名ソート改善_チェックリスト機能分 周 end
          // 同姓同名取得
          patMain = patMains.stream().filter(p -> Objects.equals(p.getPat_id(), patId))
            .collect(Collectors.toList());
          if (patMain.size() > 0) {
            isSame = patMain.get(0).getIs_same();
          }
        }
      }

      // 応答用スケジュール情報作成
      CheckListScheduleResponse r = new CheckListScheduleResponse();
      r.setFacilityCd(facilityCd);
      r.setOrdNo(ord.getOrdNo());
      r.setPatId(patId);
      r.setPatName(patName);
      r.setPatFirstName(patFirstName);
      r.setPatLastName(patLastName);
      r.setIsSame(isSame);
      r.setTreatDate(treatDate);
      r.setTreatWeek(ord.getTreatWeek());
      r.setRstDialysisState(ord.getRstDialysisState());
      r.setIndMediInfo(ord.getIndMediInfo());
      r.setIndCondInfo(ord.getIndCondInfo());
      r.setIndEquipInfo(ord.getIndEquipInfo());
      r.setRstMediInfo(ord.getRstMediInfo());
      r.setRstCondInfo(ord.getRstCondInfo());
      r.setRstEquipInfo(ord.getRstEquipInfo());
      r.setInOutClass(inOutClass);
      // add FNSI-横展開 入院患者名の配布_チェックリスト機能分 周 start
      // 患者ID(院内表示用).
      r.setHospPatId(hospPatId);
      // add FNSI-横展開 入院患者名の配布_チェックリスト機能分 周 end
      // add FNSI-横展開 患者名ソート改善_チェックリスト機能分 周 start
      r.setPatNameKana(patNameKana);
      r.setPatFirstNameKana(patFirstNameKana);
      r.setPatLastNameKana(patLastNameKana);
      // add FNSI-横展開 患者名ソート改善_チェックリスト機能分 周 end

      // 治療状態判定
      // 治療情報テーブル「実績：治療状況（rst_dialysis_state） = 0：条件送信前」
      if (rstDialysisState.equals("0")) {
        // 条件送信前の場合
        r.setKurCd(ord.getIndKurCd());
        r.setKurName(ord.getIndKurName());
        r.setBedCd(ord.getIndBedCd());
        r.setBedName(ord.getIndBedName());
        r.setDeviceMode(ord.getIndDeviceMode());
        r.setKurStartTime(ord.getIndKurStartTime());
        r.setBedOrderIndex(ord.getIndBedOrderIndex());
      } else {
        // 条件送信後の場合
        r.setKurCd(ord.getRstKurCd());
        r.setKurName(ord.getRstKurName());
        r.setBedCd(ord.getRstBedCd());
        r.setBedName(ord.getRstBedName());
        r.setDeviceMode(ord.getRstDeviceMode());
        r.setKurStartTime(ord.getRstKurStartTime());
        r.setBedOrderIndex(ord.getRstBedOrderIndex());
      }

      res.add(r);
    }

    return res;
  }

  /**
   * オーダー番号からチェックリスト進度(チェック済み項目数, 項目数)情報を取得する「条件送信前」
   * {@inheritDoc}
   */
  @Override
  public List<List<Long>> getOrdCheckListShindoZen(Long ordNo) throws IOException {
    List<List<Long>> res = new ArrayList<>();
    // チェックリストマスタ.チェックリストコード
    Long checklistCd = null;
    // ord_mainの情報取得
    OrdMainForCheckListSchedule ordMain = ordMainDao.selectByOrdNoChecklist(ordNo);
    // ord_mainに情報がない場合
    if (ordMain == null) {
      return res;
    }

    // 最新のチェックリストマスタを取得
    List<MstChecklist> mstChecklist = mstChecklistDao.selectByFacilityCd(SelectOptions.get(), ordMain.getFacilityCd(), "0");
    MstChecklist nowMstChecklist = mstChecklist.get(0);
    String strSetting = nowMstChecklist.getChecklistSettings();
    ObjectMapper map = new ObjectMapper();
    JsonNode node = map.readTree(strSetting);

    // mod 9324 gjn start
    //治療情報から指示治療条件、投与薬剤、医療材料のMstデータを取得
    // 0, dializer, 1, equipment, 2, medicine, 3, medicineMix
    List<OrdMainForCheckListSchedule> ordMains = new ArrayList<>();
    ordMains.add(ordMain);
    List<Object> mstData = getMstData(ordMains);
    // 登録用チェックリストデータを作成
    List<OrdChecklist> regList = getRegisterChecklist(ordMain, node, (long)nowMstChecklist.getChecklistCd(), false, mstData);
    // mod 9324 gjn end
    //add FNSI-パフォーマンス 房 start
    List<OrdChecklist> ordCheckListCheckedAll = ordChecklistDao.selectByOrdNoListCdMasterExist(SelectOptions.get(), ordNo, null);
    //add FNSI-パフォーマンス 房 end
    for (int i = 1; i <= 8; i++) {
      // チェックリストマスタ.チェックリスト設定.リストコード「1～8で固定で使用」
      Short listCd = Short.parseShort(Integer.toString(i));
      // 登録用チェックリストデータ（リストコード別）
      List<OrdChecklist> ordCheckListUnchecked = regList.stream()
        .filter(s -> s.getListCd() == listCd)
        .collect(Collectors.toList());
      // チェックリスト実績情報を取得（リストコード別）
      // mod FNSI-横展開 マスタ削除_チェックリスト機能分 周 start
      // List<OrdChecklist> ordCheckListChecked = ordChecklistDao.selectByOrdNoListCd(SelectOptions.get(), ordNo, listCd);
      //mod FNSI-パフォーマンス 房 start
//      List<OrdChecklist> ordCheckListChecked = ordChecklistDao.selectByOrdNoListCdMasterExist(SelectOptions.get(), ordNo, listCd);
      List<OrdChecklist> ordCheckListChecked = ordCheckListCheckedAll.stream().filter(el->el.getListCd() == listCd).collect(Collectors.toList());
      //mod FNSI-パフォーマンス 房 end
      // mod FNSI-横展開 マスタ削除_チェックリスト機能分 周 end

      if (ordCheckListUnchecked.size() > 0) {
        // チェックリスト実績.チェックリスト項目情報.チェックリストコード
        // オーダー番号とリストコードが同じ場合、チェックリストコードが一致する
        checklistCd = ordCheckListUnchecked.get(0).getRstChecklistInfo().getChecklistCd();
      }

      List<Long> listres = new ArrayList<>();
      // チェック済み項目数「チェックリスト実績情報」
      listres.add((long)ordCheckListChecked.stream()
        .filter(s -> s.getIsCheck().equals(FlagType.FLAG_ON))
        .collect(Collectors.toList())
        .size());
      // 全項目数セット「チェックリストマスタ情報と治療指示情報」
      listres.add((long)ordCheckListUnchecked.size());
      res.add(listres);
    }
    // 先頭にチェックリストコードを追記
    List<Long> listres = new ArrayList<>();
    listres.add(checklistCd);
    res.add(0, listres);
    return res;
  }

  /**
   * オーダー番号からチェックリスト一覧情報を取得する「条件送信前」
   * {@inheritDoc}
   */
  @Override
  public List<OrdChecklistWithUserNameResponse> getOrdCheckListIchiranZen(Long ordNo, Short listCd) throws IOException {
    List<OrdChecklistWithUserNameResponse> res = new ArrayList<>();
    List<OrdChecklist> ordCheckList = new ArrayList<>();
    // ord_mainの情報取得
    OrdMainForCheckListSchedule ordMain = ordMainDao.selectByOrdNoChecklist(ordNo);
    // ord_mainに情報がない場合
    if (ordMain == null) {
      return res;
    }

    // 最新のチェックリストマスタを取得
    List<MstChecklist> mstChecklist = mstChecklistDao.selectByFacilityCd(SelectOptions.get(), ordMain.getFacilityCd(), "0");
    MstChecklist nowMstChecklist = mstChecklist.get(0);
    String strSetting = nowMstChecklist.getChecklistSettings();
    ObjectMapper map = new ObjectMapper();
    JsonNode node = map.readTree(strSetting);

    // mod 9324 gjn start
    //治療情報から指示治療条件、投与薬剤、医療材料のMstデータを取得
    // 0, dializer, 1, equipment, 2, medicine, 3, medicineMix
    List<OrdMainForCheckListSchedule> ordMains = new ArrayList<>();
    ordMains.add(ordMain);
    List<Object> mstData = getMstData(ordMains);
    // 登録用チェックリストデータを作成
    List<OrdChecklist> regList = getRegisterChecklist(ordMain, node, (long)nowMstChecklist.getChecklistCd(), false, mstData);
    // mod 9324 gjn end

    if (regList != null) {
      // 登録用チェックリストデータ（リストコード別）
      ordCheckList = regList.stream()
        .filter(s -> s.getListCd() == listCd)
        .collect(Collectors.toList());

      // チェックリスト実績情報を取得（リストコード別）
      // mod FNSI-横展開 マスタ削除_チェックリスト機能分 周 start
      // List<OrdChecklist> ordCheckListChecked = ordChecklistDao.selectByOrdNoListCd(SelectOptions.get(), ordNo, listCd);
      List<OrdChecklist> ordCheckListChecked = ordChecklistDao.selectByOrdNoListCdMasterExist(SelectOptions.get(), ordNo, listCd);
      // mod FNSI-横展開 マスタ削除_チェックリスト機能分 周 end

      //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
      ordCheckList.forEach(item -> {
        OrdChecklistRegCheckInfo itemCheckInfo = (OrdChecklistRegCheckInfo)item.getRstChecklistInfo();
        OrdChecklist checked = null;
        // 実績情報をマージ
        // if (itemCheckInfo.getCode() == null && itemCheckInfo.getClassCd() == null) {
        if (item.getFuncClass() == 0) {
          // 通常リストの場合
          checked = ordCheckListChecked.stream()
            .filter(p -> Objects.equals(item.getRstChecklistInfo().getItemNumber(), p.getRstChecklistInfo().getItemNumber())
              &&
              Objects.equals(item.getRstChecklistInfo().getName(), p.getRstChecklistInfo().getName())
              &&
              Objects.equals(item.getRstClass(), p.getRstClass())
              &&
              Objects.equals(item.getListCd(), p.getListCd())
              &&
              Objects.equals(item.getFuncClass(), p.getFuncClass()))
            .findFirst()
            .orElse(null);
        } else {
          // その他の場合
          checked = ordCheckListChecked.stream()
            // mod FNSI-フリーワード表示エラー対応 周 start
            // .filter(p -> p.getRstChecklistInfo().getCode().equals(itemCheckInfo.getCode()) &&
            //   p.getRstChecklistInfo().getClassCd().equals(itemCheckInfo.getClassCd()))
            .filter(p -> Objects.equals(item.getListCd(), p.getListCd()) &&
              Objects.equals(item.getFuncClass(), p.getFuncClass()) &&
              Objects.equals(item.getRstChecklistInfo().getItemNumber(), p.getRstChecklistInfo().getItemNumber())
              &&
              Objects.equals(item.getRstChecklistInfo().getClassCd(), p.getRstChecklistInfo().getClassCd())
              &&
              Objects.equals(item.getRstChecklistInfo().getCode(), p.getRstChecklistInfo().getCode())
              // del 10310 needle _ typeの使用を削除するには gjn start
//              &&
//              Objects.equals(item.getRstChecklistInfo().getNeedleType(), p.getRstChecklistInfo().getNeedleType())
              // del 10310 needle _ typeの使用を削除するには gjn end
              &&
              Objects.equals(item.getRstClass(), p.getRstClass())
              &&
              Objects.equals(item.getRstChecklistInfo().getMedicineType(), p.getRstChecklistInfo().getMedicineType())
              &&
              Objects.equals(item.getRstChecklistInfo().getMedicineNo(), p.getRstChecklistInfo().getMedicineNo())
              &&
              Objects.equals(item.getRstChecklistInfo().getEquipType(), p.getRstChecklistInfo().getEquipType())
              &&
              // mod #12235【因島】チェックリストの治療条件：抗凝固剤での小数点桁数の扱いが不正 関 start
              equalsAsNumber(item.getRstChecklistInfo().getAmount(),  p.getRstChecklistInfo().getAmount()))
              // mod #12235【因島】チェックリストの治療条件：抗凝固剤での小数点桁数の扱いが不正 関 end
            // mod FNSI-フリーワード表示エラー対応 周 end
            .findFirst()
            .orElse(null);
        }

        if (checked != null) {
          // チェックリスト管理番号
          item.setChecklistCtlNo(checked.getChecklistCtlNo());
          // システムで管理する一意なオーダ番号
          // item.setOrdNo(checked.getOrdNo());
          // 実施状態
          item.setIsCheck(checked.getIsCheck());
          // 実績区分
          // item.setRstClass(checked.getRstClass());
          // リストコード
          // item.setListCd(checked.getListCd());
          // 機能フラグ
          // item.setFuncClass(checked.getFuncClass());
          // チェックリスト情報
          // item.setRstChecklistInfo(checked.getRstChecklistInfo());
          // 実施者情報
          item.setRegStaffInfo(checked.getRegStaffInfo());
          // 表示フラグ
          // item.setIsDisp(checked.getIsDisp());
          // 削除フラグ
          // item.setIsDel(checked.getIsDel());
          // 発生日時
          item.setOccurDate(checked.getOccurDate());
          // 登録日時
          item.setRegDate(checked.getRegDate());
          // 更新日時
          // item.setUpDate(checked.getUpDate());
          // 施設コード
          // item.setFacilityCd(checked.getFacilityCd());
        }
      });
      //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end
    }

    for (OrdChecklist ordCheck : ordCheckList) {
      // ダミーデータを削除
      if (ordCheck.getRstClass().equals("9")) {
        continue;
      }
      // 応答用スケジュール情報作成
      OrdChecklistWithUserNameResponse r = new OrdChecklistWithUserNameResponse();
      r.setOrdChecklist(ordCheck);

      // 実施者名取得
      String userName = null;
      Long staffcd = ordCheck.getRegStaffInfo().getRegStaffCd();
      if (staffcd != null) {
        userName = mstPersonalUserDao.selectUserNameById(staffcd);
      }
      r.setUserName(userName);

      res.add(r);
    }

    return res;
  }

  /**
   * オーダー番号からチェックリスト進度(チェック済み項目数, 項目数)情報を取得する「条件送信以降」
   * {@inheritDoc}
   */
  @Override
  public List<List<Long>> getOrdCheckListShindoIcou(Long ordNo) {
    List<List<Long>> res = new ArrayList<>();
    // チェックリストマスタ.チェックリストコード
    Long checklistCd = null;
    //add FNSI-パフォーマンス 房 start
    List<OrdChecklist> ordCheckListAll =
      ordChecklistDao.selectByOrdNoListCd(SelectOptions.get(), ordNo, null);
    //add FNSI-パフォーマンス 房 end
    for (int i = 1; i <= 8; i++) {
      // チェックリストマスタ.チェックリスト設定.リストコード「1～8で固定で使用」
      Short listCd = Short.parseShort(Integer.toString(i));
      List<OrdChecklist> ordCheckList =
        //mod FNSI-パフォーマンス 房 start
        ordCheckListAll.stream().filter(el->el.getListCd() == listCd).collect(Collectors.toList())
//        ordChecklistDao.selectByOrdNoListCd(SelectOptions.get(), ordNo, listCd)
          //mod FNSI-パフォーマンス 房 end
          .stream()
          // チェックリスト実績「実績区分」（９：ダミーデータ）以外
          .filter(p -> !p.getRstClass().equals(Short.parseShort("9")))
          .collect(Collectors.toList());

      if (ordCheckList.size() > 0) {
        // チェックリスト実績.チェックリスト項目情報.チェックリストコード
        // オーダー番号とリストコードが同じ場合、チェックリストコードが一致する
        checklistCd = ordCheckList.get(0).getRstChecklistInfo().getChecklistCd();
      }
      List<Long> listres = new ArrayList<>();
      // チェック済み項目数
      listres.add((long)ordCheckList.stream()
        .filter(s -> s.getIsCheck().equals(FlagType.FLAG_ON))
        .collect(Collectors.toList())
        .size());
      // 全項目数セット
      listres.add((long)ordCheckList.size());
      res.add(listres);
    }
    // 先頭にチェックリストコードを追記
    List<Long> listres = new ArrayList<>();
    listres.add(checklistCd);
    res.add(0, listres);

    return res;
  }

  // add #7857-【デグレ】チェックリストマスタとチェックリストが正しくコンバートされなくなっている 徐博 start
  public static Map<String, Object> objectToMap(Object obj) throws Exception {
    if (obj == null) {
      return null;
    }
    Map<String, Object> map = new HashMap<String, Object>();
    BeanInfo beanInfo = Introspector.getBeanInfo(obj.getClass());
    PropertyDescriptor[] propertyDescriptors = beanInfo.getPropertyDescriptors();
    for (PropertyDescriptor property : propertyDescriptors) {
      String key = property.getName();
      //默认PropertyDescriptor会有一个class对象，剔除之
      if (key.compareToIgnoreCase("class") == 0) {
        continue;
      }
      Method getter = property.getReadMethod();
      Object value = getter != null ? getter.invoke(obj) : null;
      map.put(key, value);
    }
    return map;
  }
  // add #7857-【デグレ】チェックリストマスタとチェックリストが正しくコンバートされなくなっている 徐博 end

  /**
   * オーダー番号からチェックリスト一覧情報を取得する「条件送信以降」
   * {@inheritDoc}
   */
  @Override
  public List<OrdChecklistWithUserNameResponse> getOrdCheckListIchiranIcou(Long ordNo, Short listCd) {
    List<OrdChecklistWithUserNameResponse> res = new ArrayList<>();
    List<OrdChecklist> ordCheckList =
      ordChecklistDao.selectByOrdNoListCd(SelectOptions.get(), ordNo, listCd)
        .stream()
        // チェックリスト実績「実績区分」（７８９：ダミーデータ）以外
        //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
        // .filter(p -> !p.getRstClass().equals(Short.parseShort("9")))
        .filter(p -> p.getRstClass() != null && !p.getRstClass().equals(Short.parseShort("9"))
          &&!p.getRstClass().equals(Short.parseShort("8"))&&!p.getRstClass().equals(Short.parseShort("7")))
        //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end
        .collect(Collectors.toList());

    // #11589 2025.03.03 mod 各アイテムについてマスタの並び順で表示を行う TDC米沢 start
    //for (OrdChecklist ordCheck : ordCheckList) {

    List<OrdChecklist> sortedOrdCheckList = new ArrayList<>();
    try {
      // チェックリスト項目がある場合
      if (0 < ordCheckList.size()) {

        // 施設コード
        String facilityCd = ordCheckList.get(0).getFacilityCd();

        // 使用する各マスタの並び順を取得
        List<MstSelector> selectors = mstSelectorDao.selectByNameList(facilityCd, Arrays.asList(
          MST_DIALYZER_PHYSICAL_NAME,
          MST_EQUIPMENT_PHYSICAL_NAME,
          MST_MEDICINE_PHYSICAL_NAME,
          MST_MEDICINE_MIX_PHYSICAL_NAME
        ));

        // 最新のチェックリストマスタを取得
        List<MstChecklist> mstChecklist = mstChecklistDao.selectByFacilityCd(SelectOptions.get(), facilityCd, "0");
        MstChecklist nowMstChecklist = mstChecklist.get(0);
        String strSetting = nowMstChecklist.getChecklistSettings();
        ObjectMapper map = new ObjectMapper();
        JsonNode root = map.readTree(strSetting);
        if (!root.isNull() && root.isArray()) {
          for (JsonNode setting : root) {
            // リストコード（list_cd）「１～８」
            Short listcd = Short.parseShort(setting.get("list_cd").asText());
            // 指定されたリストコードの場合
            if (listCd.equals(listcd)) {
              // 機能リスト（funclist）「１～１０」
              JsonNode funclist = setting.get("funclist");
              // 機能リスト分繰り返し
              if (!funclist.isNull() && funclist.isArray()) {

                for (JsonNode item : funclist) {
                  // 項目番号
                  Integer  itemNo = item.get("item_number").asInt();

                  // チェックリスト実績情報を取得（項目番号に合致したものを抽出）
                  List<OrdChecklist> ordCheckListChecked = ordCheckList.stream().filter(x -> itemNo.equals(x.getRstChecklistInfo().getItemNumber().intValue())).toList();
                  if (0 < ordCheckListChecked.size()) {

                    // マスタの並び順とチェックリスト実績の格納先
                    Map<Long, OrdChecklist> checklistOrder = new HashMap<>();
                    Map<Long, OrdChecklist> checklistOrder2 = new HashMap<>();
                    List<Long> sortedCodes;
                    List<Long> sortedCodes2;
                    Object[] orderedKeys;
                    Long noKeyValue = Long.MAX_VALUE - 1000L;
                    Long sortKeyValue;

                    // mst_checklist.func_classが2：医療材料、3：薬剤・調整薬剤の場合にソートを実施
                    switch(ordCheckListChecked.get(0).getFuncClass()) {
                      case 2: // 医療材料

                        // 分類種別を判定
                        Integer classCd = ordCheckListChecked.get(0).getRstChecklistInfo().getClassCd().intValue();
                        if(classCd.equals(0)) {
                          // ダイアライザ

                          // マスタの並び順を取得
                          sortedCodes = selectors.stream()
                            .filter(selector-> selector.getMasterPhysicalName().equals(MST_DIALYZER_PHYSICAL_NAME))
                            .findFirst().get().getOrderSettings().getItems().stream().map(MstSelector.Item::getCode).toList();

                        } else {
                          // 以外

                          // マスタの並び順を取得
                          sortedCodes = selectors.stream()
                            .filter(selector-> selector.getMasterPhysicalName().equals(MST_EQUIPMENT_PHYSICAL_NAME))
                            .findFirst().get().getOrderSettings().getItems().stream().map(MstSelector.Item::getCode).toList();
                        }
                        for(OrdChecklist info : ordCheckListChecked ) {
                          // マスタのキー値とチェックリスト情報を保持
                          sortKeyValue = (long)sortedCodes.indexOf(info.getRstChecklistInfo().getCode().longValue());
                          checklistOrder.put(sortKeyValue.equals((long)-1) ? noKeyValue : sortKeyValue, info);
                          noKeyValue++;
                        }

                        // 表示順でソート
                        orderedKeys = checklistOrder.keySet().toArray();
                        Arrays.sort(orderedKeys);
                        for (Object orderedKey : orderedKeys) {
                          // ソート結果からチェックリスト実績を取得する
                          sortedOrdCheckList.add(checklistOrder.get((Long)orderedKey));
                        }

                        break;
                      case 3: // 薬剤・調整薬剤

                        // マスタの並び順を取得
                        sortedCodes = selectors.stream()
                          .filter(selector-> selector.getMasterPhysicalName().equals(MST_MEDICINE_PHYSICAL_NAME))
                          .findFirst().get().getOrderSettings().getItems().stream().map(MstSelector.Item::getCode).toList();

                        sortedCodes2 = selectors.stream()
                          .filter(selector-> selector.getMasterPhysicalName().equals(MST_MEDICINE_MIX_PHYSICAL_NAME))
                          .findFirst().get().getOrderSettings().getItems().stream().map(MstSelector.Item::getCode).toList();

                        // 薬剤種別を判定
                        for(OrdChecklist info : ordCheckListChecked) {
                          Integer medicineType = info.getRstChecklistInfo().getMedicineType().intValue();
                          if( medicineType.equals(2)) {
                            // 調整薬剤
                            sortKeyValue = (long)sortedCodes2.indexOf(info.getRstChecklistInfo().getCode().longValue());
                            checklistOrder2.put(sortKeyValue.equals((long)-1) ? noKeyValue : sortKeyValue, info);
                          } else {
                            // 薬剤
                            sortKeyValue = (long)sortedCodes.indexOf(info.getRstChecklistInfo().getCode().longValue());
                            checklistOrder.put(sortKeyValue.equals((long)-1) ? noKeyValue : sortKeyValue, info);
                          }
                          noKeyValue++;
                        }

                        // 表示順でソート：薬剤
                        orderedKeys = checklistOrder.keySet().toArray();
                        Arrays.sort(orderedKeys);
                        for (Object orderedKey : orderedKeys) {
                          // ソート結果からチェックリスト実績を取得する
                          sortedOrdCheckList.add(checklistOrder.get((Long)orderedKey));
                        }
                        // 表示順でソート：調整薬剤
                        orderedKeys = checklistOrder2.keySet().toArray();
                        Arrays.sort(orderedKeys);
                        for (Object orderedKey : orderedKeys) {
                          // ソート結果からチェックリスト実績を取得する
                          sortedOrdCheckList.add(checklistOrder2.get((Long)orderedKey));
                        }

                        break;

                      default:  // 通常・透析条件
                        sortedOrdCheckList.addAll(ordCheckListChecked);
                        break;
                    }
                  }
                }
              }
            }
          }
        }
      }
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));

      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
    }

    for (OrdChecklist ordCheck : sortedOrdCheckList) {
      // #11589 2025.03.03 mod 各アイテムについてマスタの並び順で表示を行う TDC米沢 end

      // ダミーデータを削除
      if (ordCheck.getRstClass().equals("9")) {
        continue;
      }
      // 応答用スケジュール情報作成
      OrdChecklistWithUserNameResponse r = new OrdChecklistWithUserNameResponse();
      r.setOrdChecklist(ordCheck);
      // add #7857-【デグレ】チェックリストマスタとチェックリストが正しくコンバートされなくなっている 徐博 start
      Map checkListMap = new HashMap();
      try {
        // reg_staff_infoの内容はobj=>map
        checkListMap = objectToMap(ordCheck.getRegStaffInfo());
      } catch (Exception e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
      }
      // add #7857-【デグレ】チェックリストマスタとチェックリストが正しくコンバートされなくなっている 徐博 end
      // 実施者名取得
      String userName = null;
      // mod #7857-【デグレ】チェックリストマスタとチェックリストが正しくコンバートされなくなっている 徐博 start
      //　reg_staff_infoの中でreg_staff_nameというkeyがあるかどうかを判断する
      if (checkListMap.containsKey("regStaffName")) {
        // もしあったら、reg_staff_nameを取る
        userName = ordCheck.getRegStaffInfo().getRegStaffName();
      } else {
        // もしないなら、前のロジックを実行する
        Long staffcd = ordCheck.getRegStaffInfo().getRegStaffCd();
        if (staffcd != null) {
          userName = mstPersonalUserDao.selectUserNameById(staffcd);
        }
      }
      // Long staffcd = ordCheck.getRegStaffInfo().getRegStaffCd();
      // if (staffcd != null) {
      //   userName = mstPersonalUserDao.selectUserNameById(staffcd);
      // }
      r.setUserName(userName);
      // mod #7857-【デグレ】チェックリストマスタとチェックリストが正しくコンバートされなくなっている 徐博 end
      res.add(r);
    }

    return res;
  }

  /**
   * 登録用チェックリストデータを取得「0：通常リスト」
   * @param regdata
   * @param checkinfo
   * @param list
   * @return
   */
  private List<OrdChecklist> getRegisterChecklistTsuujourisuto(OrdChecklist regdata,
                                                               OrdChecklistRegCheckInfo checkinfo,
                                                               JsonNode list) {
    List<OrdChecklist> reglist = new ArrayList<>();
    // 既存ソース
    checkinfo = settingNormalCheckList(checkinfo, list);

    // チェックリスト項目情報を設定（rst_checklist_info）
    regdata.setRstChecklistInfo(checkinfo);
    reglist.add(regdata);

    return reglist;
  }


  //add 9324 gjn start
  @Override
  public List<Object> getMstData(List<OrdMainForCheckListSchedule> ordMains) {
    try {
      List<Object> mstList = new ArrayList<>();
      // 治療条件指示リスト
      ObjectMapper map = new ObjectMapper();
      //頻繁にDBを呼び出さないように事前にMstデータを取り出す
      List<Integer> condDializerSet = new ArrayList<>(); //ダイアライザ
      List<Integer> condEquipmentSet = new ArrayList<>(); //医療材料
      List<Integer> condMedicineSet = new ArrayList<>(); //通常薬剤
      List<Integer> condMedicineMixSet = new ArrayList<>(); //調製薬剤

      Map<Integer, MstDialyzer> condDializer = new HashMap<>();
      Map<Integer, MstEquipment> condEquipment = new HashMap<>();
      Map<Integer, MstMedicine> condMedicine = new HashMap<>();
      Map<Integer, MstMedicineMix> condMedicineMix = new HashMap<>();

      // #11589 2025.02.28 add 各アイテムについてマスタの並び順で表示を行う TDC米沢 start
      // 各マスタの並び順
      Map<Long, Long> condDializerOrder = new HashMap<>();    // ダイアライザマスタ
      Map<Long, Long> condEquipmentOrder = new HashMap<>();   // 医療材料
      Map<Long, Long> condMedicineOrder = new HashMap<>();    // 通常薬剤
      Map<Long, Long> condMedicineMixOrder = new HashMap<>(); // 調整薬剤
      // #11589 2025.02.28 add 各アイテムについてマスタの並び順で表示を行う TDC米沢 end

      String facilityCd = "";
      for (OrdMainForCheckListSchedule ordMain : ordMains) {
        // 対象の治療条件取得
        JsonNode condlist = map.readTree(ordMain.getIndCondInfo());

        facilityCd = ordMain.getFacilityCd();
        //TODO 治疗条件

        // ダイアライザの場合「5：ダイアライザ」
        // mod 10310 チェックリストの動作が不正 関 start
        // if (!StringUtils.isEmpty(condlist.get("5"))) {
        if (condlist.has("5") && !condlist.get("5").isNull()) {
          // mod 10310 チェックリストの動作が不正 関 end
          JsonNode diazy = map.readTree(condlist.get("5").toString());
          // mod 10310 チェックリストの動作が不正 関 start
          // if (diazy.has("value") && !diazy.get("value").isEmpty() && !"null".equals(diazy.get("value").asText())) {
          if (diazy.has("value") && !diazy.get("value").isNull() && !"null".equals(diazy.get("value").asText())) {
            // mod 10310 チェックリストの動作が不正 関 end
            condDializerSet.add(Integer.parseInt(diazy.get("value").asText()));
          }
        }
        // 薬剤の場合「15：透析液」「19：補液」「25：抗凝固剤」
        // mod 10310 チェックリストの動作が不正 関 start
        // if (!StringUtils.isEmpty(condlist.get("15"))) {
        if (condlist.has("15") && !condlist.get("15").isNull()) { //「15：透析液」
          // mod 10310 チェックリストの動作が不正 関 end
          // 「薬剤区分：medicine_type」
          // 「1：通常薬剤」「2：調製薬剤」
          JsonNode medi = map.readTree(condlist.get("15").toString());
          // mod 10310 チェックリストの動作が不正 関 start
          // if (medi.has("medicine_type") && !medi.get("medicine_type").isEmpty()
          //   && medi.has("medicine_type") && !medi.get("value").isEmpty()
          //   && !"null".equals(medi.get("value").asText()) && !"null".equals(medi.get("medicine_type").asText())) {
          if (medi.has("medicine_type") && !medi.get("medicine_type").isNull()
            && medi.has("value") && !medi.get("value").isNull()
            && !"null".equals(medi.get("value").asText()) && !"null".equals(medi.get("medicine_type").asText())) {
            // mod 10310 チェックリストの動作が不正 関 end
            String meditype = medi.get("medicine_type").toString();
            if (meditype.equals("2")) {
              // 調製薬剤の場合
              condMedicineMixSet.add(Integer.parseInt(medi.get("value").asText()));
            } else if (meditype.equals("1")) {
              // 通常薬剤の場合
              condMedicineSet.add(Integer.parseInt(medi.get("value").asText()));
            } else {
              // 薬剤区分が異常値の場合はとりあえず薬剤とする
              condMedicineSet.add(Integer.parseInt(medi.get("value").asText()));
            }
          }
        }
        // mod 10310 チェックリストの動作が不正 関 start
        // if (!StringUtils.isEmpty(condlist.get("19"))) {
        if (condlist.has("19") && !condlist.get("19").isNull()) { //「19：補液」
          // mod 10310 チェックリストの動作が不正 関 end
          // 「薬剤区分：medicine_type」
          // 「1：通常薬剤」「2：調製薬剤」
          JsonNode medi = map.readTree(condlist.get("19").toString());
          // mod 10310 チェックリストの動作が不正 関 start
          // if (medi.has("medicine_type") && !medi.get("medicine_type").isEmpty()
          //   && medi.has("medicine_type") && !medi.get("value").isEmpty()
          //   && !"null".equals(medi.get("value").asText()) && !"null".equals(medi.get("medicine_type").asText())) {
          if (medi.has("medicine_type") && !medi.get("medicine_type").isNull()
            && medi.has("value") && !medi.get("value").isNull()
            && !"null".equals(medi.get("value").asText()) && !"null".equals(medi.get("medicine_type").asText())) {
            // mod 10310 チェックリストの動作が不正 関 end
            String meditype = medi.get("medicine_type").toString();
            if (meditype.equals("2")) {
              // 調製薬剤の場合
              condMedicineMixSet.add(Integer.parseInt(medi.get("value").asText()));
            } else if (meditype.equals("1")) {
              // 通常薬剤の場合
              condMedicineSet.add(Integer.parseInt(medi.get("value").asText()));
            } else {
              // 薬剤区分が異常値の場合はとりあえず薬剤とする
              condMedicineSet.add(Integer.parseInt(medi.get("value").asText()));
            }
          }
        }
        // mod 10310 チェックリストの動作が不正 関 start
        // if (!StringUtils.isEmpty(condlist.get("25"))) {
        if (condlist.has("25") && !condlist.get("25").isNull()) { //25：抗凝固剤」
          // mod 10310 チェックリストの動作が不正 関 end
          // 「薬剤区分：medicine_type」
          // 「1：通常薬剤」「2：調製薬剤」
          JsonNode medi = map.readTree(condlist.get("25").toString());
          // mod 10310 チェックリストの動作が不正 関 start
          // if (medi.has("medicine_type") && !medi.get("medicine_type").isEmpty()
          //   && medi.has("medicine_type") && !medi.get("value").isEmpty()
          //   && !"null".equals(medi.get("value").asText()) && !"null".equals(medi.get("medicine_type").asText())) {
          if (medi.has("medicine_type") && !medi.get("medicine_type").isNull()
            && medi.has("value") && !medi.get("value").isNull()
            && !"null".equals(medi.get("value").asText()) && !"null".equals(medi.get("medicine_type").asText())) {
            // mod 10310 チェックリストの動作が不正 関 end
            String meditype = medi.get("medicine_type").asText();
            if (meditype.equals("2")) {
              // 調製薬剤の場合
              condMedicineMixSet.add(Integer.parseInt(medi.get("value").asText()));
            } else if (meditype.equals("1")) {
              // 通常薬剤の場合
              condMedicineSet.add(Integer.parseInt(medi.get("value").asText()));
            } else {
              // 薬剤区分が異常値の場合はとりあえず薬剤とする
              condMedicineSet.add(Integer.parseInt(medi.get("value").asText()));
            }
          }
        }
        // 医療材料の場合
        // mod 10310 チェックリストの動作が不正 関 start
        // if (!StringUtils.isEmpty(condlist.get("6"))) {
        if (condlist.has("6") && !condlist.get("6").isNull()) { //6 吸着カラム
          // mod 10310 チェックリストの動作が不正 関 end
          JsonNode diazy = map.readTree(condlist.get("6").toString());
          // mod 10310 チェックリストの動作が不正 関 start
          // if (diazy.has("value") && !diazy.get("value").isEmpty() && !"null".equals(diazy.get("value").asText())) {
          if (diazy.has("value") && !diazy.get("value").isNull() && !"null".equals(diazy.get("value").asText())) {
            // mod 10310 チェックリストの動作が不正 関 end
            condEquipmentSet.add(Integer.parseInt(diazy.get("value").asText()));
          }
        }
        // mod 10310 チェックリストの動作が不正 関 start
        // if (!StringUtils.isEmpty(condlist.get("7"))) {
        if (condlist.has("7") && !condlist.get("7").isNull()) { //7 1次膜
          // mod 10310 チェックリストの動作が不正 関 end
          JsonNode diazy = map.readTree(condlist.get("7").toString());
          // mod 10310 チェックリストの動作が不正 関 start
          // if (diazy.has("value") && !diazy.get("value").isEmpty() && !"null".equals(diazy.get("value").asText())) {
          if (diazy.has("value") && !diazy.get("value").isNull() && !"null".equals(diazy.get("value").asText())) {
            // mod 10310 チェックリストの動作が不正 関 end
            condEquipmentSet.add(Integer.parseInt(diazy.get("value").asText()));
          }
        }
        // mod 10310 チェックリストの動作が不正 関 start
        // if (!StringUtils.isEmpty(condlist.get("8"))) {
        if (condlist.has("8") && !condlist.get("8").isNull()) { //8 2次膜
          // mod 10310 チェックリストの動作が不正 関 end
          JsonNode diazy = map.readTree(condlist.get("8").toString());
          // mod 10310 チェックリストの動作が不正 関 start
          // if (diazy.has("value") && !diazy.get("value").isEmpty() && !"null".equals(diazy.get("value").asText())) {
          if (diazy.has("value") && !diazy.get("value").isNull() && !"null".equals(diazy.get("value").asText())) {
            // mod 10310 チェックリストの動作が不正 関 end
            condEquipmentSet.add(Integer.parseInt(diazy.get("value").asText()));
          }
        }
        // mod 10310 チェックリストの動作が不正 関 start
        // if (!StringUtils.isEmpty(condlist.get("9"))) {
        if (condlist.has("9") && !condlist.get("9").isNull()) { //9 穿刺針(A針)
          // mod 10310 チェックリストの動作が不正 関 end
          JsonNode diazy = map.readTree(condlist.get("9").toString());
          // mod 10310 チェックリストの動作が不正 関 start
          // if (diazy.has("value") && !diazy.get("value").isEmpty() && !"null".equals(diazy.get("value").asText())) {
          if (diazy.has("value") && !diazy.get("value").isNull() && !"null".equals(diazy.get("value").asText())) {
            // mod 10310 チェックリストの動作が不正 関 end
            condEquipmentSet.add(Integer.parseInt(diazy.get("value").asText()));
          }
        }
        // mod 10310 チェックリストの動作が不正 関 start
        // if (!StringUtils.isEmpty(condlist.get("10"))) {
        if (condlist.has("10") && !condlist.get("10").isNull()) { //10 穿刺針(V針)
          // mod 10310 チェックリストの動作が不正 関 end
          JsonNode diazy = map.readTree(condlist.get("10").toString());
          // mod 10310 チェックリストの動作が不正 関 start
          // if (diazy.has("value") && !diazy.get("value").isEmpty() && !"null".equals(diazy.get("value").asText())) {
          if (diazy.has("value") && !diazy.get("value").isNull() && !"null".equals(diazy.get("value").asText())) {
            // mod 10310 チェックリストの動作が不正 関 end
            condEquipmentSet.add(Integer.parseInt(diazy.get("value").asText()));
          }
        }
        // mod 10310 チェックリストの動作が不正 関 start
        // if (!StringUtils.isEmpty(condlist.get("11"))) {
        if (condlist.has("11") && !condlist.get("11").isNull()) { //11 穿刺針(SN)
          // mod 10310 チェックリストの動作が不正 関 end
          JsonNode diazy = map.readTree(condlist.get("11").toString());
          // mod 10310 チェックリストの動作が不正 関 start
          // if (diazy.has("value") && !diazy.get("value").isEmpty() && !"null".equals(diazy.get("value").asText())) {
          if (diazy.has("value") && !diazy.get("value").isNull() && !"null".equals(diazy.get("value").asText())) {
            // mod 10310 チェックリストの動作が不正 関 end
            condEquipmentSet.add(Integer.parseInt(diazy.get("value").asText()));
          }
        }
        // mod 10310 チェックリストの動作が不正 関 start
        // if (!StringUtils.isEmpty(condlist.get("13"))) {
        if (condlist.has("13") && !condlist.get("13").isNull()) { //13 血液回路
          // mod 10310 チェックリストの動作が不正 関 end
          JsonNode diazy = map.readTree(condlist.get("13").toString());
          // mod 10310 チェックリストの動作が不正 関 start
          // if (diazy.has("value") && !diazy.get("value").isEmpty() && !"null".equals(diazy.get("value").asText())) {
          if (diazy.has("value") && !diazy.get("value").isNull() && !"null".equals(diazy.get("value").asText())) {
            // mod 10310 チェックリストの動作が不正 関 end
            condEquipmentSet.add(Integer.parseInt(diazy.get("value").asText()));
          }
        }
        //TODO 投与药剂

        // 対象の投与药剂取得
        /* modify by chamaojia 2024-04-03 [10196] add null judgment processing  --start */
        JsonNode medilist = map.readTree(ObjectUtils.isEmpty(ordMain.getIndMediInfo()) ? "[]" : ordMain.getIndMediInfo());
        /* modify by chamaojia 2024-04-03 [10196] add null judgment processing  --end */

        for (JsonNode medilistDel : medilist) {
          // 「薬剤区分：medicine_type」
          // 「1：通常薬剤」「2：調製薬剤」
          // mod 10310 チェックリストの動作が不正 関 start
          // if (medilistDel.has("medicine_type") && !medilistDel.get("medicine_type").isEmpty()
          //   && medilistDel.has("cd") && !medilistDel.get("cd").isEmpty()
          //   && !"null".equals(medilistDel.get("cd").asText()) && !"null".equals(medilistDel.get("medicine_type").asText())) {
          if (medilistDel.has("medicine_type") && !medilistDel.get("medicine_type").isNull()
            && medilistDel.has("cd") && !medilistDel.get("cd").isNull()
            && !"null".equals(medilistDel.get("cd").asText()) && !"null".equals(medilistDel.get("medicine_type").asText())) {
            // mod 10310 チェックリストの動作が不正 関 end
            String meditype = medilistDel.get("medicine_type").asText();
            if (meditype.equals("2")) {
              // 調製薬剤の場合
              condMedicineMixSet.add(Integer.parseInt(medilistDel.get("cd").asText()));
            } else if (meditype.equals("1")) {
              // 通常薬剤の場合
              condMedicineSet.add(Integer.parseInt(medilistDel.get("cd").asText()));
            } else {
              // 薬剤区分が異常値の場合はとりあえず薬剤とする
              condMedicineSet.add(Integer.parseInt(medilistDel.get("cd").asText()));
            }
          }
        }

        //TODO 医疗材料

        // 対象の医疗材料取得
        /* modify by chamaojia 2024-04-03 [10196] add null judgment processing  --start */
        JsonNode equiplist = map.readTree(ObjectUtils.isEmpty(ordMain.getIndEquipInfo()) ? "[]" : ordMain.getIndEquipInfo());
        /* modify by chamaojia 2024-04-03 [10196] add null judgment processing  --end */
        for (JsonNode equiplistDel : equiplist) {
          // mod 10310 チェックリストの動作が不正 関 start
          // if (equiplistDel.has("cd") && !equiplistDel.get("cd").isEmpty()
          //   && !"null".equals(equiplistDel.get("cd").asText())) {
          //   String equipCd = equiplistDel.get("cd").asText();
          //   if (!equiplistDel.get("equip_type").isEmpty() && "1".equals(equiplistDel.get("equip_type").asText())) {
          if (equiplistDel.has("cd") && !equiplistDel.get("cd").isNull()
            && !"null".equals(equiplistDel.get("cd").asText())) {
            String equipCd = equiplistDel.get("cd").asText();
            if (equiplistDel.has("equip_type") && !equiplistDel.get("equip_type").isNull() && "1".equals(equiplistDel.get("equip_type").asText())) {
              // mod 10310 チェックリストの動作が不正 関 end
              condDializerSet.add(Integer.parseInt(equipCd));
            }
            condEquipmentSet.add(Integer.parseInt(equipCd));
          }
        }
      }

      // #11589 2025.02.28 add 各アイテムについてマスタの並び順で表示を行う TDC米沢 start
      // 使用する各マスタの並び順を取得
      List<MstSelector> selectors = mstSelectorDao.selectByNameList(facilityCd, Arrays.asList(
        MST_DIALYZER_PHYSICAL_NAME,
        MST_EQUIPMENT_PHYSICAL_NAME,
        MST_MEDICINE_PHYSICAL_NAME,
        MST_MEDICINE_MIX_PHYSICAL_NAME
      ));
      // #11589 2025.02.28 add 各アイテムについてマスタの並び順で表示を行う TDC米沢 end

      //薬剤、調製薬剤、医療材料、ダイ・アライザのコード集合に基づいて、それぞれ対応するMstデータを取り出し、Mapに入れる
      // ダイアライザマスタから情報取得
      List<Integer> condDializerSets = condDializerSet.stream().distinct().collect(Collectors.toList());
      if (condDializerSets.size() > 0) {
        // #11589 2025.02.28 add 各アイテムについてマスタの並び順で表示を行う TDC米沢 start
        // マスタの並び順を取得
        List<Long> sortedCodes = selectors.stream()
          .filter(selector-> selector.getMasterPhysicalName().equals(MST_DIALYZER_PHYSICAL_NAME))
          .findFirst().get().getOrderSettings().getItems().stream().map(MstSelector.Item::getCode).toList();
        // #11589 2025.02.28 add 各アイテムについてマスタの並び順で表示を行う TDC米沢 end
        List<MstDialyzer> dialdataList = mstDialyzerDao.selectAllByCdListCheckList(SelectOptions.get(), condDializerSets, facilityCd);
        dialdataList.forEach(f -> {
          condDializer.put(f.getDialyzerCd(), f);
          // #11589 2025.02.28 add 各アイテムについてマスタの並び順で表示を行う TDC米沢 start
          // マスタのキー値と表示順を保持
          condDializerOrder.put(f.getDialyzerCd().longValue(), (long)sortedCodes.indexOf(f.getDialyzerCd().longValue()));
          // #11589 2025.02.28 add 各アイテムについてマスタの並び順で表示を行う TDC米沢 start
        });
      }
      // 医療材料マスタから情報取得
      List<Integer> condEquipmentSets = condEquipmentSet.stream().distinct().collect(Collectors.toList());
      if (condEquipmentSets.size() > 0) {
        // #11589 2025.02.28 add 各アイテムについてマスタの並び順で表示を行う TDC米沢 start
        // マスタ並び順を取得
        List<Long> sortedCodes = selectors.stream()
          .filter(selector-> selector.getMasterPhysicalName().equals(MST_EQUIPMENT_PHYSICAL_NAME))
          .findFirst().get().getOrderSettings().getItems().stream().map(MstSelector.Item::getCode).toList();
        // #11589 2025.02.28 add 各アイテムについてマスタの並び順で表示を行う TDC米沢 end
        List<MstEquipment> equipdataList = mstEquipDao.selectByCdListCheckList(SelectOptions.get(), condEquipmentSets, facilityCd);
        equipdataList.forEach(f -> {
          condEquipment.put(f.getEquipmentCd(), f);
          // #11589 2025.02.28 add 各アイテムについてマスタの並び順で表示を行う TDC米沢 start
          // マスタのキー値と表示順を保持
          condEquipmentOrder.put(f.getEquipmentCd().longValue(), (long)sortedCodes.indexOf(f.getEquipmentCd().longValue()));
          // #11589 2025.02.28 add 各アイテムについてマスタの並び順で表示を行う TDC米沢 start
        });
      }
      // 調整薬剤マスタから情報取得
      List<Integer> condMedicineMixSets = condMedicineMixSet.stream().distinct().collect(Collectors.toList());
      if (condMedicineMixSets.size() > 0) {
        // #11589 2025.02.28 add 各アイテムについてマスタの並び順で表示を行う TDC米沢 start
        // マスタ並び順を取得
        List<Long> sortedCodes = selectors.stream()
          // #12275 2025.10.29 mod 指定するマスタが違う TDC米沢 start
          // .filter(selector-> selector.getMasterPhysicalName().equals(MST_MEDICINE_PHYSICAL_NAME))
          .filter(selector-> selector.getMasterPhysicalName().equals(MST_MEDICINE_MIX_PHYSICAL_NAME))
          // #12275 2025.10.29 mod 指定するマスタが違う TDC米沢 end
          .findFirst().get().getOrderSettings().getItems().stream().map(MstSelector.Item::getCode).toList();
        // #11589 2025.02.28 add 各アイテムについてマスタの並び順で表示を行う TDC米沢 end
        List<MstMedicineMix> medidataMixList = mstMedicineMixDao.selectAllByCdListCheckList(SelectOptions.get(), condMedicineMixSets, facilityCd);
        medidataMixList.forEach(f -> {
          condMedicineMix.put(f.getMedicineMixCd(), f);
          // #11589 2025.02.28 add 各アイテムについてマスタの並び順で表示を行う TDC米沢 start
          // マスタのキー値と表示順を保持
          condMedicineMixOrder.put(f.getMedicineMixCd().longValue(), (long)sortedCodes.indexOf(f.getMedicineMixCd().longValue()));
          // #11589 2025.02.28 add 各アイテムについてマスタの並び順で表示を行う TDC米沢 start
        });
      }
      // 薬剤マスタから情報取得
      List<Integer> condMedicineSets = condMedicineSet.stream().distinct().collect(Collectors.toList());
      if (condMedicineSets.size() > 0) {
        // #11589 2025.02.28 add 各アイテムについてマスタの並び順で表示を行う TDC米沢 start
        // マスタ並び順を取得
        List<Long> sortedCodes = selectors.stream()
          // #12275 2025.10.29 mod 指定するマスタが違う TDC米沢 start
          // .filter(selector-> selector.getMasterPhysicalName().equals(MST_MEDICINE_MIX_PHYSICAL_NAME))
          .filter(selector-> selector.getMasterPhysicalName().equals(MST_MEDICINE_PHYSICAL_NAME))
          // #12275 2025.10.29 mod 指定するマスタが違う TDC米沢 end
          .findFirst().get().getOrderSettings().getItems().stream().map(MstSelector.Item::getCode).toList();
        // #11589 2025.02.28 add 各アイテムについてマスタの並び順で表示を行う TDC米沢 end
        List<MstMedicine> medidataList = mstMedicineDao.selectAllByCdListCheckList(SelectOptions.get(), condMedicineSets, facilityCd);
        medidataList.forEach(f -> {
          condMedicine.put(f.getMedicineCd(), f);
          // #11589 2025.02.28 add 各アイテムについてマスタの並び順で表示を行う TDC米沢 start
          // マスタのキー値と表示順を保持
          condMedicineOrder.put(f.getMedicineCd().longValue(), (long)sortedCodes.indexOf(f.getMedicineCd().longValue()));
          // #11589 2025.02.28 add 各アイテムについてマスタの並び順で表示を行う TDC米沢 start
        });
      }
      mstList.add(0, condDializer);
      mstList.add(1, condEquipment);
      mstList.add(2, condMedicine);
      mstList.add(3, condMedicineMix);
      // #11589 2025.02.28 add 各アイテムについてマスタの並び順で表示を行う TDC米沢 start
      mstList.add(4, condDializerOrder);
      mstList.add(5, condEquipmentOrder);
      mstList.add(6, condMedicineOrder);
      mstList.add(7, condMedicineMixOrder);
      // #11589 2025.02.28 add 各アイテムについてマスタの並び順で表示を行う TDC米沢 end
      return mstList;
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
    }
    return null;
  }
  //add 9324 gjn end



  /**
   * 登録用チェックリストデータを取得「1：治療条件」
   * @param regdata
   * @param checkinfo
   * @param ordMain
   * @param classcd
   * @param list
   * @return
   */
  private List<OrdChecklist> getRegisterChecklistChiryoujouken(OrdChecklist regdata,
                                                               OrdChecklistRegCheckInfo checkinfo,
                                                               OrdMainForCheckListSchedule ordMain,
                                                               Integer classcd,
                                                               JsonNode list, List<Object> mstData) {
    List<OrdChecklist> reglist = new ArrayList<>();
    if (classcd == null) {
      return reglist;
    }

    // class_cd
    List<Integer> condclasscd = new ArrayList<>();
    condclasscd.add(classcd);

    // ダイアライザの場合「5：ダイアライザまたは吸着カラム(6),一次膜(7),二次膜(8)」
    if (Objects.equals(classcd, 5)) {
      // 吸着カラムも追加
      condclasscd.add(6);
      // 一次膜
      condclasscd.add(7);
      // 二次膜
      condclasscd.add(8);
    }
    // 吸着カラムはダイアライザと同時設定にしたので除外
    // ※仕様変更後,既存データ保守用コード「吸着カラム(6)⇒チェックリストマスタは破棄」
    if (Objects.equals(classcd, 6)) {
      return reglist;
    }
    // 穿刺針の場合「9:穿刺針(10,11含む)」
    if (Objects.equals(classcd, 9)) {
      // 穿刺針(V針)
      condclasscd.add(10);
      // 穿刺針(SN)
      condclasscd.add(11);
    }
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

    // 対象の治療条件取得
    List<JSONObject> condList = getCondInfo(ordMain.getIndCondInfo(), condclasscd);

    // 対象の治療条件取得「再作成」「薬剤場合用」
    List<JSONObject> res = new ArrayList<>();
    // 「17：透析液使用数」
    BigDecimal amount15 = BigDecimal.ZERO;
    // 「22：補液使用数」
    BigDecimal amount19 = BigDecimal.ZERO;
    // 「26：抗凝固剤ワンショット量」＋「28：抗凝固剤持続総量」
    BigDecimal amount25 = BigDecimal.ZERO;
    for (JSONObject cond : condList) {
      // add #9973 Resolve null exception for key 20240117 ztc start
      if(!cond.has("code") || cond.isNull("code")){
        continue;
      }
      // add #9973 Resolve null exception for key 20240117 ztc end
      // code「設定値：value」
      String strcode = cond.get("code").toString();
      BigDecimal regcode = BigDecimal.ZERO;
      // mod 9324 gjn start
      if (!strcode.equals("null") && !"".equals(strcode)) {
        // mod FutreNetWeb+SI課題管理No7165 趙 start
        // regcode = new BigDecimal(cond.get("code").toString());
        String regexp = "\"";
        if (cond.get("code").toString().indexOf(regexp) > - 1) {
          regcode = new BigDecimal(cond.get("code").toString().replaceAll(regexp, ""));
        } else {
          regcode = new BigDecimal(cond.get("code").toString());
        }
        // mod FutreNetWeb+SI課題管理No7165 趙 end
      }
      // mod 9324 gjn end
      // mod #9973 Resolve null exception for key 20240117 ztc start
      if (cond.has("class_cd") && !cond.isNull("class_cd") && Objects.equals(cond.get("class_cd").toString(), "17")) {
        amount15 = amount15.add(regcode);
      } else if (cond.has("class_cd") && !cond.isNull("class_cd") && Objects.equals(cond.get("class_cd").toString(), "22")) {
        amount19 = amount19.add(regcode);
      } else if (cond.has("class_cd") && !cond.isNull("class_cd") && Objects.equals(cond.get("class_cd").toString(), "26")) {
        amount25 = amount25.add(regcode);
      } else if (cond.has("class_cd") && !cond.isNull("class_cd") && Objects.equals(cond.get("class_cd").toString(), "28")) {
        amount25 = amount25.add(regcode);
        // mod #9973 Resolve null exception for key 20240117 ztc end
      } else {
        res.add(cond);
      }
    }

    //add 9324 治療条件検索性能の最適化 gjn start
    Map<Integer, MstDialyzer> dialyzerMap = new HashMap<>();
    Map<Integer, MstEquipment> equipmentMap = new HashMap<>();
    Map<Integer, MstMedicine> medicineMap = new HashMap<>();
    Map<Integer, MstMedicineMix> medicineMixMap = new HashMap<>();
    if (!StringUtils.isEmpty(mstData) && mstData.get(0) instanceof Map && mstData.get(1) instanceof Map
      && mstData.get(2) instanceof Map && mstData.get(3) instanceof Map) {
      dialyzerMap = (Map<Integer, MstDialyzer>) mstData.get(0);
      equipmentMap = (Map<Integer, MstEquipment>) mstData.get(1);
      medicineMap = (Map<Integer, MstMedicine>) mstData.get(2);
      medicineMixMap = (Map<Integer, MstMedicineMix>) mstData.get(3);
    }

    for (JSONObject cond : res) {
      // add #9973 Resolve null exception for key 20240117 ztc start
      if(!cond.has("code") || cond.isNull("code")){
        continue;
      }
      // add #9973 Resolve null exception for key 20240117 ztc start
      // チェックリスト項目情報作成用
      OrdChecklistRegCheckInfo condcheckinfo = checkinfo.clone();
      // code「設定値：value」
      String strcode = cond.get("code").toString();
      Integer regcode = null;
      // mod 9324 gjn start
      if (!strcode.equals("null") && !"".equals(strcode)) {
        regcode = Integer.parseInt(cond.get("code").toString());
        condcheckinfo.setCode(regcode);
      }
      // mod 9324 gjn end
      // code_update
      condcheckinfo.setCodeUpdate(null);
      // name
      condcheckinfo.setName(null);
      // class_cd
      // add #9973 Resolve null exception for key 20240117 ztc start
      if (cond.has("class_cd") && !cond.isNull("class_cd")) {
        // add #9973 Resolve null exception for key 20240117 ztc end
        String strClassCd = cond.get("class_cd").toString();
        Integer regClassCd = null;
        if (!strClassCd.equals("null")) {
          regClassCd = Integer.valueOf(cond.get("class_cd").toString());
          condcheckinfo.setClassCd(regClassCd);
        }
      }
      // ダイアライザの場合「5：ダイアライザ」
      if (Objects.equals(classcd, 5)) {
        if (Objects.equals(condcheckinfo.getClassCd(), 5)) {
          // ダイアライザマスタから情報取得
          condcheckinfo = settingCondDializerCheckInfoInd(condcheckinfo, dialyzerMap.get(regcode));
          //condcheckinfo = settingCondDializerCheckInfo(condcheckinfo, regcode);
        } else {
          // 吸着カラム・1次膜・2次膜：医療材料から情報取得
          condcheckinfo = settingCondEquipCheckInfoInd(condcheckinfo, equipmentMap.get(regcode), condcheckinfo.getClassCd());
          //condcheckinfo = settingCondEquipCheckInfo(condcheckinfo, regcode, condcheckinfo.getClassCd());
        }
      }
      // 薬剤の場合「15：透析液」「19：補液」「25：抗凝固剤」
      else if (Objects.equals(classcd, 15) || Objects.equals(classcd, 19) || Objects.equals(classcd, 25)) {
        // 「薬剤区分：medicine_type」
        // 「登録が必要な治療条件項目の場合に設定」
        // 「1：通常薬剤」「2：調製薬剤」
        // add #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
        // mod #9973 Resolve null exception for key 20240117 ztc start
//        if (cond.has("medicine_type")) {
        if (cond.has("medicine_type") && !cond.isNull("medicine_type")) {
          // mod #9973 Resolve null exception for key 20240117 ztc end
          // add #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
          String meditype = cond.get("medicine_type").toString();
          if (meditype.equals("2")) {
            // 調製薬剤の場合
            //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
            //  condcheckinfo = settingCondMixMedicineCheckInfo(condcheckinfo, ordMain.getFacilityCd(), regcode,
            //    condcheckinfo.getClassCd());
            condcheckinfo = settingCondMixMedicineCheckInfoInd(condcheckinfo, ordMain.getFacilityCd(), medicineMixMap.get(regcode),
              condcheckinfo.getClassCd(), null);
//            condcheckinfo = settingCondMixMedicineCheckInfo(condcheckinfo, ordMain.getFacilityCd(), regcode,
//              condcheckinfo.getClassCd(), null);
            //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end
          } else if (meditype.equals("1")) {
            // 通常薬剤の場合
            //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
            //  condcheckinfo = settingCondNormalMedicineCheckInfo(condcheckinfo, ordMain.getFacilityCd(), regcode,
            //    condcheckinfo.getClassCd());
            condcheckinfo = settingCondNormalMedicineCheckInfoInd(condcheckinfo, ordMain.getFacilityCd(), medicineMap.get(regcode),
              condcheckinfo.getClassCd(), null);
//            condcheckinfo = settingCondNormalMedicineCheckInfo(condcheckinfo, ordMain.getFacilityCd(), regcode,
//              condcheckinfo.getClassCd(), null);
            //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end
          } else {
            // 薬剤区分が異常値の場合はとりあえず薬剤とする
            //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
            //  condcheckinfo = settingCondNormalMedicineCheckInfo(condcheckinfo, ordMain.getFacilityCd(), regcode,
            //    condcheckinfo.getClassCd());
            condcheckinfo = settingCondNormalMedicineCheckInfoInd(condcheckinfo, ordMain.getFacilityCd(), medicineMap.get(regcode),
              condcheckinfo.getClassCd(), null);
//            condcheckinfo = settingCondNormalMedicineCheckInfo(condcheckinfo, ordMain.getFacilityCd(), regcode,
//              condcheckinfo.getClassCd(), null);
            //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end
          }
        }
        // 薬剤場合「数量設定」
        if (Objects.equals(classcd, 15)) {
          condcheckinfo.setAmount(amount15.toString());
        } else if (Objects.equals(classcd, 19)) {
          condcheckinfo.setAmount(amount19.toString());
        } else if (Objects.equals(classcd, 25)) {
          condcheckinfo.setAmount(amount25.toString());
      }
      }
      // 医療材料の場合
      else {
        condcheckinfo = settingCondEquipCheckInfoInd(condcheckinfo, equipmentMap.get(regcode), classcd);
//        condcheckinfo = settingCondEquipCheckInfo(condcheckinfo, regcode, classcd);
      }
      //add 9324 治療条件検索性能の最適化 gjn end

      // needle_type「穿刺針種別」
      // 「9：穿刺針(A針)⇒1」
      // 「10：穿刺針(V針)⇒2」
      // 「11：穿刺針(SN)⇒3」
      // 「その他：空白」
      // add #9973 Resolve null exception for key 20240117 ztc start

      // del 10310 needle _ typeの使用を削除するには gjn start
//      if (cond.has("needle_type") && !cond.isNull("needle_type")) {
//        // add #9973 Resolve null exception for key 20240117 ztc end
//        String strntype = cond.get("needle_type").toString();
//        if (!strntype.equals("") && !strntype.equals("null")) {
//          Short ntype = Short.parseShort(strntype);
//          condcheckinfo.setNeedleType(ntype);
//        }
//      }
      // del 10310 needle _ typeの使用を削除するには gjn end
      if (condcheckinfo != null) {
        // 登録用
        OrdChecklist condregdata = regdata.clone();
        // rst_checklist_info「チェックリスト項目情報」
        condregdata.setRstChecklistInfo(condcheckinfo);
        // チェックリスト実績登録
        reglist.add(condregdata);
      }
    }
    return reglist;
  }

  /**
   * 登録用チェックリストデータを取得「2：医療材料」
   * @param regdata
   * @param checkinfo
   * @param ordMain
   * @param classcd
   * @return
   */
  private List<OrdChecklist> getRegisterChecklistIryouzairyou(OrdChecklist regdata,
                                                              OrdChecklistRegCheckInfo checkinfo,
                                                              OrdMainForCheckListSchedule ordMain,
                                                              Integer classcd, List<Object> mstData) {
    List<OrdChecklist> reglist = new ArrayList<>();
    if (classcd == null) {
      return reglist;
    }

    //add 9324 パフォーマンスの最適化 gjn start
    Map<Integer, MstDialyzer> dialyzerMap = new HashMap<>();
    Map<Integer, MstEquipment> equipmentMap = new HashMap<>();
    // #11589 2025.02.28 add 各アイテムについてマスタの並び順で表示を行う TDC米沢 start
    Map<Long, Long> dializerOrderMap = new HashMap<>();
    Map<Long, Long> equipmentOrderMap = new HashMap<>();
    // #11589 2025.02.28 add 各アイテムについてマスタの並び順で表示を行う TDC米沢 end
    if (!StringUtils.isEmpty(mstData) && mstData.get(0) instanceof Map && mstData.get(1) instanceof Map) {
      dialyzerMap = (Map<Integer, MstDialyzer>) mstData.get(0);
      equipmentMap = (Map<Integer, MstEquipment>) mstData.get(1);
      // #11589 2025.02.28 add 各アイテムについてマスタの並び順で表示を行う TDC米沢 start
      dializerOrderMap = (Map<Long, Long>) mstData.get(4);
      equipmentOrderMap = (Map<Long, Long>) mstData.get(5);
      // #11589 2025.02.28 add 各アイテムについてマスタの並び順で表示を行う TDC米沢 end
    }
    // 対象の医療材料を取得
    List<OrdChecklistRegEquipInfo> equipList;
    // ダイアライザの場合
    if (Objects.equals(classcd, 0)) {
      // 対象のダイアライザ取得
      equipList = getEquipDailyzerInfoInd(ordMain.getIndEquipInfo(), classcd, dialyzerMap);
    } else {
      // 対象の医療材料取得
      equipList = getEquipInfoInd(ordMain.getIndEquipInfo(), classcd, equipmentMap);
    }
    //add 9324 パフォーマンスの最適化 gjn end

    // #11589 2025.02.28 add 各アイテムについてマスタの並び順で表示を行う TDC米沢 start
    // for (OrdChecklistRegEquipInfo equip : equipList) {
    //   // チェックリスト項目情報作成用
    //   OrdChecklistRegCheckInfo equipcheckinfo = settingEquipCheckInfo(checkinfo, equip);
    //   // 登録用
    //   OrdChecklist equipregdata = regdata.clone();
    //   // rst_checklist_info「チェックリスト項目情報」
    //   equipregdata.setRstChecklistInfo(equipcheckinfo);
    //   // チェックリスト実績登録
    //   reglist.add(equipregdata);
    // }

    Map<Long, OrdChecklistRegEquipInfo> sortEquipList = new HashMap<>();
    Long noKeyValue = Long.MAX_VALUE - 1000L;
    Long sortKeyValue;

    // 表示順とチェックリスト項目を登録
    for (OrdChecklistRegEquipInfo equip : equipList) {
      // 分類判定
      if (Objects.equals(classcd, 0)) {
        // ダイアライザの場合
        sortKeyValue = dializerOrderMap.get(equip.getCode().longValue());
      } else {
        // 医療材料の場合
        sortKeyValue =equipmentOrderMap.get(equip.getCode().longValue());
      }
      // #12275 2025.10.29 mod ソート値が未指定の場合の初期値が-1の場合の対策がされていない TDC米沢 start
      // sortEquipList.put(sortKeyValue == null ? noKeyValue : sortKeyValue, equip);
      sortEquipList.put(sortKeyValue == -1 || sortKeyValue == null ? noKeyValue : sortKeyValue, equip);
      // #12275 2025.10.29 mod ソート値が未指定の場合の初期値が-1の場合の対策がされていない TDC米沢 end
      noKeyValue++;
    }
    if(0 < sortEquipList.size()) {
      // 表示順でソート
      Object[] orderedKeys = sortEquipList.keySet().toArray();
      Arrays.sort(orderedKeys);
      for (Object orderedKey : orderedKeys) {
        // ソート結果からチェックリスト項目を取得する
        OrdChecklistRegEquipInfo equip = sortEquipList.get((Long)orderedKey);

        // チェックリスト項目情報作成用
        OrdChecklistRegCheckInfo equipcheckinfo = settingEquipCheckInfo(checkinfo, equip);
        // 登録用
        OrdChecklist equipregdata = regdata.clone();
        // rst_checklist_info「チェックリスト項目情報」
        equipregdata.setRstChecklistInfo(equipcheckinfo);
        // チェックリスト実績登録
        reglist.add(equipregdata);
      }
    }
    // #11589 2025.02.28 add 各アイテムについてマスタの並び順で表示を行う TDC米沢 end
    return reglist;
  }

  /**
   * 登録用チェックリストデータを取得「3：投与薬剤」
   * @param regdata
   * @param checkinfo
   * @param ordMain
   * @param classcd
   * @param list
   * @return
   */
  private List<OrdChecklist> getRegisterChecklistTouyoyakuzai(OrdChecklist regdata,
                                                              OrdChecklistRegCheckInfo checkinfo,
                                                              OrdMainForCheckListSchedule ordMain,
                                                              Integer classcd,
                                                              JsonNode list, List<Object> mstData) {
    List<OrdChecklist> reglist = new ArrayList<>();
    if (classcd == null) {
      return reglist;
    }
    // mod 9324 gjn start
    // 対象の投与薬剤を取得
    List<OrdChecklistRegMediInfo> medicineList = getMediInfo(ordMain.getIndMediInfo(), classcd, mstData);
    // mod 9324 gjn end

    //add 9324 投与薬剤検索性能の最適化 gjn start
    //頻繁にDBを呼び出さないように事前にMstデータを取り出す
    Map<Integer, MstMedicine> medicineMap = new HashMap<>();
    Map<Integer, MstMedicineMix> medicineMixMap = new HashMap<>();
    // #11589 2025.02.28 add 各アイテムについてマスタの並び順で表示を行う TDC米沢 start
    Map<Long, Long> medicineOrderMap = new HashMap<>();
    Map<Long, Long> medicineMixOrderMap = new HashMap<>();
    // #11589 2025.02.28 add 各アイテムについてマスタの並び順で表示を行う TDC米沢 end
    if (!StringUtils.isEmpty(mstData) && mstData.get(2) instanceof Map && mstData.get(3) instanceof Map) {
      medicineMap = (Map<Integer, MstMedicine>) mstData.get(2);
      medicineMixMap = (Map<Integer, MstMedicineMix>) mstData.get(3);
      // #11589 2025.02.28 add 各アイテムについてマスタの並び順で表示を行う TDC米沢 start
      medicineOrderMap = (Map<Long, Long>) mstData.get(6);
      medicineMixOrderMap = (Map<Long, Long>) mstData.get(7);
      // #11589 2025.02.28 add 各アイテムについてマスタの並び順で表示を行う TDC米沢 end
    }

    // #11589 2025.02.28 add 各アイテムについてマスタの並び順で表示を行う TDC米沢 start
    Map<Long, OrdChecklistRegCheckInfo> sortMedicineList = new HashMap<>();
    Map<Long, OrdChecklistRegCheckInfo> sortMedicineMixList = new HashMap<>();
    Long noKeyValue = Long.MAX_VALUE - 1000L;
    // #11589 2025.02.28 add 各アイテムについてマスタの並び順で表示を行う TDC米沢 end

    for (OrdChecklistRegMediInfo medicine : medicineList) {
      // チェックリスト項目情報作成用
      OrdChecklistRegCheckInfo medicinecheckinfo = checkinfo.clone();
      // 「薬剤区分：medicine_type」
      // 「登録が必要な治療条件項目の場合に設定」
      // 「1：通常薬剤」「2：調製薬剤」
      String meditype = medicine.medicineType.toString();
      //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
      String medicineNo = medicine.getMedicineNo();
      //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end

      if (meditype.equals("2")) {
        // 調製薬剤の場合
        //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
        //  medicinecheckinfo = settingCondMixMedicineCheckInfo(medicinecheckinfo, ordMain.getFacilityCd(), medicine.getCode(), 0);
        medicinecheckinfo = settingCondMixMedicineCheckInfoInd(medicinecheckinfo, ordMain.getFacilityCd(), medicineMixMap.get(medicine.getCode()), 0, medicineNo);
        //medicinecheckinfo = settingCondMixMedicineCheckInfo(medicinecheckinfo, ordMain.getFacilityCd(), medicine.getCode(), 0, medicineNo);
        //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end
      } else if (meditype.equals("1")) {
        // 通常薬剤の場合
        //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
        // medicinecheckinfo = settingCondNormalMedicineCheckInfo(medicinecheckinfo, ordMain.getFacilityCd(), medicine.getCode(), 0);
        medicinecheckinfo = settingCondNormalMedicineCheckInfoInd(medicinecheckinfo, ordMain.getFacilityCd(), medicineMap.get(medicine.getCode()), 0, medicineNo);
        //medicinecheckinfo = settingCondNormalMedicineCheckInfo(medicinecheckinfo, ordMain.getFacilityCd(), medicine.getCode(), 0, medicineNo);
        //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end
      } else {
        // 薬剤区分が異常値の場合はとりあえず薬剤とする
        //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
        //  medicinecheckinfo = settingCondNormalMedicineCheckInfo(medicinecheckinfo, ordMain.getFacilityCd(), medicine.getCode(), 0);
        medicinecheckinfo = settingCondNormalMedicineCheckInfoInd(medicinecheckinfo, ordMain.getFacilityCd(), medicineMap.get(medicine.getCode()), 0, medicineNo);
        //medicinecheckinfo = settingCondNormalMedicineCheckInfo(medicinecheckinfo, ordMain.getFacilityCd(), medicine.getCode(), 0, medicineNo);
        //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end
      }
      //add 9324 投与薬剤検索性能の最適化 gjn end
      // code「マスタコード」
      medicinecheckinfo.setCode(medicine.getCode());
      // amount
      medicinecheckinfo.setAmount(medicine.getAmount());
      // del 9324 gjn start
      // unit
      // medicinecheckinfo.setUnit(medicine.getUnit());
      // del 9324 gjn end

      // #11589 2025.02.28 add 各アイテムについてマスタの並び順で表示を行う TDC米沢 start
      //   // 登録用
      //   OrdChecklist medicinedata = regdata.clone();
      //   // rst_checklist_info「チェックリスト項目情報」
      //   medicinedata.setRstChecklistInfo(medicinecheckinfo);
      //   // チェックリスト実績登録
      //   reglist.add(medicinedata);
      // }
      // // add 9324 gjn start
      // reglist.sort(Comparator.comparing(obj -> obj.getRstChecklistInfo() != null
      //   && obj.getRstChecklistInfo().getName() != null ? obj.getRstChecklistInfo().getName() : ""));
      // // add 9324 gjn end

      Long sortKeyValue;

      // 薬剤分類判定
      if (meditype.equals("2")) {
        // 表示順とチェックリスト項目(調整薬剤)を登録
        sortKeyValue = medicineMixOrderMap.get(medicine.getCode().longValue());
        // #12275 2025.10.29 mod ソート値が未指定の場合の初期値が-1の場合の対策がされていない TDC米沢 start
        // sortMedicineMixList.put(sortKeyValue == null ? noKeyValue : sortKeyValue, medicinecheckinfo);
        sortMedicineMixList.put(sortKeyValue == -1 || sortKeyValue == null ? noKeyValue : sortKeyValue, medicinecheckinfo);
        // #12275 2025.10.29 mod ソート値が未指定の場合の初期値が-1の場合の対策がされていない TDC米沢 end
      } else {
        // 表示順とチェックリスト項目(通常薬剤)を登録
        sortKeyValue = medicineOrderMap.get(medicine.getCode().longValue());
        // #12275 2025.10.29 mod ソート値が未指定の場合の初期値が-1の場合の対策がされていない TDC米沢 start
        // sortMedicineList.put(sortKeyValue == null ? noKeyValue : sortKeyValue, medicinecheckinfo);
        sortMedicineList.put(sortKeyValue == -1 || sortKeyValue == null ? noKeyValue : sortKeyValue, medicinecheckinfo);
        // #12275 2025.10.29 mod ソート値が未指定の場合の初期値が-1の場合の対策がされていない TDC米沢 end
      }
      noKeyValue++;
    }

    if(0 < sortMedicineList.size()) {
      // 表示順でソート：通常薬剤
      Object[] orderedKeys = sortMedicineList.keySet().toArray();
      Arrays.sort(orderedKeys);
      for (Object orderedKey : orderedKeys) {
        // ソート結果からチェックリスト項目を取得する
        OrdChecklistRegCheckInfo check = sortMedicineList.get((Long)orderedKey);
        // 登録用
        OrdChecklist medicinedata = regdata.clone();
        // rst_checklist_info「チェックリスト項目情報」
        medicinedata.setRstChecklistInfo(check);
        // チェックリスト実績登録
        reglist.add(medicinedata);
      }
    }
    if(0< sortMedicineMixList.size()) {
      // 表示順でソート：調整薬剤
      Object[] orderedKeys = sortMedicineMixList.keySet().toArray();
      Arrays.sort(orderedKeys);
      for (Object orderedKey : orderedKeys) {
        // ソート結果からチェックリスト項目を取得する
        OrdChecklistRegCheckInfo check = sortMedicineMixList.get((Long)orderedKey);
        // 登録用
        OrdChecklist medicinedata = regdata.clone();
        // rst_checklist_info「チェックリスト項目情報」
        medicinedata.setRstChecklistInfo(check);
        // チェックリスト実績登録
        reglist.add(medicinedata);
      }
    }
    // #11589 2025.02.28 add 各アイテムについてマスタの並び順で表示を行う TDC米沢 end

    return reglist;
  }

  // mod 9324 gjn start
  /**
   * 登録用チェックリストデータを作成
   * {@inheritDoc}
   */
  @Override
  public List<OrdChecklist> getRegisterChecklist(OrdMainForCheckListSchedule ordMain,
                                                 JsonNode mstChecklist,
                                                 Long checklistCd,
                                                 boolean hasDummyData,
                                                 List<Object> mstData) throws IOException {

    // mod 9324 gjn end
    List<OrdChecklist> regList = new ArrayList<>();
//    ObjectMapper map = new ObjectMapper();
    // リストコード分繰り返し
    if (!mstChecklist.isNull() && mstChecklist.isArray()) {
      for (int i = 0; i < mstChecklist.size(); i++) {
//        JsonNode setting = map.readTree(mstChecklist.get(i).toString());
        JsonNode setting = mstChecklist.get(i);
        // リストコード（list_cd）「１～８」
        Short listcd = Short.parseShort(setting.get("list_cd").asText());

        // 機能リスト（funclist）「１～１０」
//        JsonNode funclist = map.readTree(setting.get("funclist").toString());
        JsonNode funclist = setting.get("funclist");
        //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
        JsonNode dPCd = setting.get("dialysis_prog_cd");
        String dialysisProgCd = dPCd.asText();
        //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end
        // 機能リスト分繰り返し
        if (!funclist.isNull() && funclist.isArray()) {
          for (int j = 0; j < funclist.size(); j++) {
//            JsonNode list = map.readTree(funclist.get(j).toString());
            JsonNode list = funclist.get(j);

            // 機能種別（func_class）「0：通常リスト」「1：治療条件」「2：医療材料」「3：投与薬剤」
//            String strfuncclass = list.get("func_class").toString();
            String strfuncclass = list.get("func_class").asText();
            Short funcClass = null;
            if (!strfuncclass.equals("null")) {
              funcClass = Short.parseShort(list.get("func_class").asText());
            }

            // 機能種別未登録の場合
            if (funcClass == null) {
              continue;
            }

            // 登録用
            OrdChecklist regdata = new OrdChecklist();
            regdata.setOrdNo(ordMain.getOrdNo());
            regdata.setIsCheck(FlagType.FLAG_OFF);
            //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
            //  regdata.setRstClass(Short.parseShort("1"));
            regdata.setRstClass(Short.parseShort(dialysisProgCd));
            //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end
            regdata.setListCd(listcd);
            regdata.setFuncClass(funcClass);
            regdata.setIsDisp(FlagType.FLAG_ON);
            regdata.setIsDel(FlagType.FLAG_OFF);
            regdata.setFacilityCd(ordMain.getFacilityCd());

            OrdChecklistRegStaffInfo regStaffInfo = new OrdChecklistRegStaffInfo();
            regdata.setRegStaffInfo(regStaffInfo);

            // チェックリスト項目情報作成用
            OrdChecklistRegCheckInfo checkinfo = new OrdChecklistRegCheckInfo();
            // checklist_cd
            checkinfo.setChecklistCd(checklistCd);
            // item_number
            checkinfo.setItemNumber(Short.parseShort(list.get("item_number").asText()));
            // class_cd
            String classcode = list.get("class_cd").asText();
            // 患者経過総合ビューアレイアウトマスタの項目定義⇒治療条件No
            Integer classcd = null;
            if (!classcode.equals("null")) {
              // add 9539 チェックリストマスタの設定を変更して保存しても保存できない。 関 start
              classcd = Integer.parseInt(list.get("class_cd").toString());
              // add 9539 チェックリストマスタの設定を変更して保存しても保存できない。 関 end
              checkinfo.setClassCd(Integer.parseInt(classcode));
            }

            List<OrdChecklist> registerChecklist = null;

            switch (funcClass) {
              // 機能種別（func_class）「0：通常リスト」
              case (short)0:
                registerChecklist = getRegisterChecklistTsuujourisuto(regdata, checkinfo, list);
                break;
              // 機能種別（func_class）「1：治療条件」
              case (short)1:
                // 「5：ダイアライザ」「6：吸着カラム」「7：1次膜」「8：2次膜」「9：穿刺針(A針)」「10：穿刺針(V針)」「11：穿刺針(SN)」
                registerChecklist = getRegisterChecklistChiryoujouken(regdata, checkinfo, ordMain, classcd, list, mstData);
                break;
              // 機能種別（func_class）「2：医療材料」
              case (short)2:
                registerChecklist = getRegisterChecklistIryouzairyou(regdata, checkinfo, ordMain, classcd, mstData);
                break;
              // 機能種別（func_class）「3：投与薬剤」
              case (short)3:
                registerChecklist = getRegisterChecklistTouyoyakuzai(regdata, checkinfo, ordMain, classcd, list, mstData);
                break;
              default:
                break;
            }

            if (registerChecklist != null && registerChecklist.size() > 0) {
              regList.addAll(registerChecklist);
            } else {
              // ダミーデータを作成
              if (hasDummyData) {
                OrdChecklist dummy = regdata.clone();
                // チェックリスト実績「実施状態」（０：未実施）
                dummy.setIsCheck(FlagType.FLAG_OFF);
                //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
                // チェックリスト実績「実績区分」（７８９：ダミーデータ）
                // 透析開始前工程
                if (dialysisProgCd == "0"){
                  dummy.setRstClass(Short.parseShort("7"));
                  // 透析中工程
                } else if(dialysisProgCd == "1"){
                  dummy.setRstClass(Short.parseShort("8"));
                  // 透析終了後工程
                } else if (dialysisProgCd == "2"){
                  dummy.setRstClass(Short.parseShort("9"));
                }
                //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end
                // チェックリスト実績「表示フラグ」（０：非表示）
                dummy.setIsDisp(FlagType.FLAG_OFF);
                // チェックリスト実績「チェックリスト項目情報」
                //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
                checkinfo = settingNormalCheckList(checkinfo, list);
                //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end

                dummy.setRstChecklistInfo(checkinfo);

                regList.add(dummy);
              }
            }
          }
        }
      }
    }
    return regList;
  }


//  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
  /**
   * 登録用チェックリストデータを作成
   * {@inheritDoc}
   */
  @Override
  public List<OrdChecklist> getRegisterChecklistRst(OrdMainForCheckListSchedule ordMain,
                                                    JsonNode mstChecklist,
                                                    Long checklistCd,
                                                    boolean hasDummyData) throws IOException {
    List<OrdChecklist> regList = new ArrayList<>();
    // リストコード分繰り返し
    if (!mstChecklist.isNull() && mstChecklist.isArray()) {
      for (int i = 0; i < mstChecklist.size(); i++) {
        JsonNode setting = mstChecklist.get(i);
        // リストコード（list_cd）「１～８」
        Short listcd = Short.parseShort(setting.get("list_cd").asText());

        // 機能リスト（funclist）「１～１０」
        JsonNode funclist = setting.get("funclist");
        JsonNode dPCd = setting.get("dialysis_prog_cd");
        String dialysisProgCd = dPCd.asText();
        // 機能リスト分繰り返し
        if (!funclist.isNull() && funclist.isArray() && !"3".equals(dialysisProgCd)) {
          for (int j = 0; j < funclist.size(); j++) {
            JsonNode list = funclist.get(j);

            // 機能種別（func_class）「0：通常リスト」「1：治療条件」「2：医療材料」「3：投与薬剤」
            String strfuncclass = list.get("func_class").asText();
            Short funcClass = null;
            if (!strfuncclass.equals("null")) {
              funcClass = Short.parseShort(list.get("func_class").asText());
            }

            // 機能種別未登録の場合
            if (funcClass == null) {
              continue;
            }

            // 登録用
            OrdChecklist regdata = new OrdChecklist();
            regdata.setOrdNo(ordMain.getOrdNo());
            regdata.setIsCheck(FlagType.FLAG_OFF);
            regdata.setRstClass(Short.parseShort(dialysisProgCd));
            regdata.setListCd(listcd);
            regdata.setFuncClass(funcClass);
            regdata.setIsDisp(FlagType.FLAG_ON);
            regdata.setIsDel(FlagType.FLAG_OFF);
            regdata.setFacilityCd(ordMain.getFacilityCd());

            OrdChecklistRegStaffInfo regStaffInfo = new OrdChecklistRegStaffInfo();
            regdata.setRegStaffInfo(regStaffInfo);

            // チェックリスト項目情報作成用
            OrdChecklistRegCheckInfo checkinfo = new OrdChecklistRegCheckInfo();
            // checklist_cd
            checkinfo.setChecklistCd(checklistCd);
            // item_number
            checkinfo.setItemNumber(Short.parseShort(list.get("item_number").asText()));
            // class_cd
            String classcode = list.get("class_cd").asText();
            // 患者経過総合ビューアレイアウトマスタの項目定義⇒治療条件No
            Integer classcd = null;
            if (!classcode.equals("null")) {
              classcd = Integer.parseInt(list.get("class_cd").toString());
              checkinfo.setClassCd(Integer.parseInt(classcode));
            }

            List<OrdChecklist> registerChecklist = null;

            switch (funcClass) {
              // 機能種別（func_class）「0：通常リスト」
              case (short)0:
                registerChecklist = getRegisterChecklistTsuujourisuto(regdata, checkinfo, list);
                break;
              // 機能種別（func_class）「1：治療条件」
              case (short)1:
                // 「5：ダイアライザ」「6：吸着カラム」「7：1次膜」「8：2次膜」「9：穿刺針(A針)」「10：穿刺針(V針)」「11：穿刺針(SN)」
                registerChecklist = getRegisterChecklistChiryoujoukenRst(regdata, checkinfo, ordMain, classcd, list);
                break;
              // 機能種別（func_class）「2：医療材料」
              case (short)2:
                registerChecklist = getRegisterChecklistIryouzairyouRst(regdata, checkinfo, ordMain, classcd);
                break;
              // 機能種別（func_class）「3：投与薬剤」
              case (short)3:
                registerChecklist = getRegisterChecklistTouyoyakuzaiRst(regdata, checkinfo, ordMain, classcd, list);
                break;
              default:
                break;
            }

            if (registerChecklist != null && registerChecklist.size() > 0) {
              regList.addAll(registerChecklist);
            } else {
              // ダミーデータを作成
              if (hasDummyData) {
                OrdChecklist dummy = regdata.clone();
                // チェックリスト実績「実施状態」（０：未実施）
                dummy.setIsCheck(FlagType.FLAG_OFF);
                // チェックリスト実績「実績区分」（７８９：ダミーデータ）
                // 透析開始前工程
                if ("0".equals(dialysisProgCd)){
                  dummy.setRstClass(Short.parseShort("7"));
                  // 透析中工程
                } else if("1".equals(dialysisProgCd)){
                  dummy.setRstClass(Short.parseShort("8"));
                  // 透析終了後工程
                } else if ("2".equals(dialysisProgCd)){
                  dummy.setRstClass(Short.parseShort("9"));
                }
                // チェックリスト実績「表示フラグ」
                dummy.setIsDisp(FlagType.FLAG_ON);

                dummy.setIsDel(FlagType.FLAG_OFF);
                // チェックリスト実績「チェックリスト項目情報」
                checkinfo = settingNormalCheckList(checkinfo, list);

                dummy.setRstChecklistInfo(checkinfo);

                regList.add(dummy);
              }
            }
          }
        }
      }
    }
    return regList;
  }
  //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end



  //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
  /**
   * 登録用チェックリストデータを取得「3：投与薬剤」
   * @param regdata
   * @param checkinfo
   * @param ordMain
   * @param classcd
   * @param list
   * @return
   */
  private List<OrdChecklist> getRegisterChecklistTouyoyakuzaiRst(OrdChecklist regdata,
                                                                 OrdChecklistRegCheckInfo checkinfo,
                                                                 OrdMainForCheckListSchedule ordMain,
                                                                 Integer classcd,
                                                                 JsonNode list) {

    List<OrdChecklist> reglist = new ArrayList<>();
    if (classcd == null) {
      return reglist;
    }
    /* modify by chamaojia 2024-04-02 [10196] add null judgment processing  --start */
//    JSONArray mediInfo = new JSONArray(ordMain.getRstMediInfo());
    JSONArray mediInfo = new JSONArray(ObjectUtils.isEmpty(ordMain.getRstMediInfo()) ? "[]" : ordMain.getRstMediInfo());
    /* modify by chamaojia 2024-04-02 [10196] add null judgment processing  --end */
    for (Object jsonItem : mediInfo) {
      JSONObject jsonObjectItem = (JSONObject) jsonItem;
      OrdChecklistRegCheckInfo medicinecheckinfo = checkinfo.clone();
      if (!jsonObjectItem.isNull("class_cd")) {
        Integer rstClassCd = Integer.parseInt(jsonObjectItem.get("class_cd").toString());
        if (rstClassCd.equals(classcd)) {
          medicinecheckinfo.setMedicineType(jsonObjectItem.get("medicine_type") != null ?
            Integer.parseInt(jsonObjectItem.get("medicine_type").toString()) : null);

          medicinecheckinfo.setCode(jsonObjectItem.get("cd") != null ?
            Integer.parseInt(jsonObjectItem.get("cd").toString()) : null);

          medicinecheckinfo.setName(jsonObjectItem.get("name") != null ?
            jsonObjectItem.get("name").toString() : null);

          medicinecheckinfo.setUnit(jsonObjectItem.get("unit") != null ?
            jsonObjectItem.get("unit").toString() : null);

          medicinecheckinfo.setAmount(jsonObjectItem.get("amount") != null ?
            jsonObjectItem.get("amount").toString() : null);

          medicinecheckinfo.setMedicineNo(jsonObjectItem.get("no") != null ?
            jsonObjectItem.get("no").toString() : null);

          // 登録用
          OrdChecklist medicinedata = regdata.clone();
          // rst_checklist_info「チェックリスト項目情報」
          medicinedata.setRstChecklistInfo(medicinecheckinfo);
          // チェックリスト実績登録
          reglist.add(medicinedata);
        }
      }
    }
    return reglist;
  }
  //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end


  //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
  /**
   * 登録用チェックリストデータを取得「2：医療材料」
   * @param regdata
   * @param checkinfo
   * @param ordMain
   * @param classcd
   * @return
   */
  private List<OrdChecklist> getRegisterChecklistIryouzairyouRst(OrdChecklist regdata,
                                                                 OrdChecklistRegCheckInfo checkinfo,
                                                                 OrdMainForCheckListSchedule ordMain,
                                                                 Integer classcd) {
    List<OrdChecklist> reglist = new ArrayList<>();
    if (classcd == null) {
      return reglist;
    }
    JSONArray equipInfo = new JSONArray(ordMain.getRstEquipInfo());
    for (Object jsonItem : equipInfo) {
      JSONObject jsonObjectItem = (JSONObject) jsonItem;
      OrdChecklistRegCheckInfo equipcheckinfo = checkinfo.clone();
      Integer equipType = jsonObjectItem.get("equip_type") != null ?
        Integer.parseInt(jsonObjectItem.get("equip_type").toString()) : null;
      // ダイアライザ
      if (equipType.equals(1) && classcd.equals(0)) {
        equipcheckinfo.setEquipType(jsonObjectItem.get("equip_type") != null ?
          Integer.parseInt(jsonObjectItem.get("equip_type").toString()) : null);

        equipcheckinfo.setCode(jsonObjectItem.get("cd") != null ?
          Integer.parseInt(jsonObjectItem.get("cd").toString()) : null);

        equipcheckinfo.setName(jsonObjectItem.get("name") != null ?
          jsonObjectItem.get("name").toString() : null);

        equipcheckinfo.setAmount(jsonObjectItem.get("amount") != null ?
          jsonObjectItem.get("amount").toString() : null);


        // 登録用
        OrdChecklist equipdata = regdata.clone();
        // rst_checklist_info「チェックリスト項目情報」
        equipdata.setRstChecklistInfo(equipcheckinfo);
        // チェックリスト実績登録
        reglist.add(equipdata);
      } else {
        //  その他 医療材料
        if ( equipType.equals(0) && jsonObjectItem.get("class_cd") != null) {
          Integer rstClassCd = Integer.parseInt(jsonObjectItem.get("class_cd").toString());
          if (rstClassCd.equals(classcd)) {
            equipcheckinfo.setEquipType(jsonObjectItem.get("equip_type") != null ?
              Integer.parseInt(jsonObjectItem.get("equip_type").toString()) : null);

            equipcheckinfo.setCode(jsonObjectItem.get("cd") != null ?
              Integer.parseInt(jsonObjectItem.get("cd").toString()) : null);

            equipcheckinfo.setName(jsonObjectItem.get("name") != null ?
              jsonObjectItem.get("name").toString() : null);

            equipcheckinfo.setUnit(jsonObjectItem.has("unit") && jsonObjectItem.get("unit") != null ?
              jsonObjectItem.get("unit").toString() : null);

            equipcheckinfo.setAmount(jsonObjectItem.get("amount") != null ?
              jsonObjectItem.get("amount").toString() : null);


            // 登録用
            OrdChecklist equipdata = regdata.clone();
            // rst_checklist_info「チェックリスト項目情報」
            equipdata.setRstChecklistInfo(equipcheckinfo);
            // チェックリスト実績登録
            reglist.add(equipdata);
          }
        }
      }
    }
    return reglist;
  }
  //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end



  //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
  /**
   * 登録用チェックリストデータを取得「1：治療条件」
   * @param regdata
   * @param checkinfo
   * @param ordMain
   * @param classcd
   * @param list
   * @return
   */
  private List<OrdChecklist> getRegisterChecklistChiryoujoukenRst(OrdChecklist regdata,
                                                                  OrdChecklistRegCheckInfo checkinfo,
                                                                  OrdMainForCheckListSchedule ordMain,
                                                                  Integer classcd,
                                                                  JsonNode list) {
    List<OrdChecklist> reglist = new ArrayList<>();
    if (classcd == null) {
      return reglist;
    }

    // class_cd
    List<Integer> condclasscd = new ArrayList<>();
    condclasscd.add(classcd);

    // ダイアライザの場合「5：ダイアライザまたは吸着カラム(6),一次膜(7),二次膜(8)」
    if (Objects.equals(classcd, 5)) {
      // 吸着カラムも追加
      condclasscd.add(6);
      // 一次膜
      condclasscd.add(7);
      // 二次膜
      condclasscd.add(8);
    }
    // 吸着カラムはダイアライザと同時設定にしたので除外
    // ※仕様変更後,既存データ保守用コード「吸着カラム(6)⇒チェックリストマスタは破棄」
    if (Objects.equals(classcd, 6)) {
      return reglist;
    }
    // 穿刺針の場合「9:穿刺針(10,11含む)」
    if (Objects.equals(classcd, 9)) {
      // 穿刺針(V針)
      condclasscd.add(10);
      // 穿刺針(SN)
      condclasscd.add(11);
    }
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

    // 対象の治療条件取得
    List<JSONObject> condList = getCondInfo(ordMain.getRstCondInfo(), condclasscd);

    // 対象の治療条件取得「再作成」「薬剤場合用」
    List<JSONObject> res = new ArrayList<>();
    // 「17：透析液使用数」
    BigDecimal amount15 = BigDecimal.ZERO;
    // 「22：補液使用数」
    BigDecimal amount19 = BigDecimal.ZERO;
    // 「26：抗凝固剤ワンショット量」＋「28：抗凝固剤持続総量」
    BigDecimal amount25 = BigDecimal.ZERO;

    String unit15 = null;

    String unit19 = null;

    String unit25 = null;

    for (JSONObject cond : condList) {
      if(!cond.has("code") || cond.isNull("code")){
        continue;
      }
      String strcode = cond.get("code").toString();
      BigDecimal regcode = BigDecimal.ZERO;
      // mod 9324 gjn start
      if (!strcode.equals("null") && !"".equals(strcode)) {
        String regexp = "\"";
        if(cond.get("code").toString().indexOf(regexp) > -1) {
          regcode = new BigDecimal(cond.get("code").toString().replaceAll(regexp, ""));
        }else{
          regcode = new BigDecimal(cond.get("code").toString());
        }
      }
      // mod 9324 gjn end
      String  unit = cond.has("unit") && !cond.isNull("unit") ? cond.get("unit").toString() : null;

      if (cond.has("class_cd") && !cond.isNull("class_cd") && Objects.equals(cond.get("class_cd").toString(), "17")) {
        amount15 = amount15.add(regcode);
        unit15  = unit;
      } else if (cond.has("class_cd") && !cond.isNull("class_cd") && Objects.equals(cond.get("class_cd").toString(), "22")) {
        amount19 = amount19.add(regcode);
        unit19  = unit;
      } else if (cond.has("class_cd") && !cond.isNull("class_cd") && Objects.equals(cond.get("class_cd").toString(), "26")) {
        amount25 = amount25.add(regcode);
        unit25  = unit;
      } else if (cond.has("class_cd") && !cond.isNull("class_cd") && Objects.equals(cond.get("class_cd").toString(), "28")) {
        amount25 = amount25.add(regcode);
        unit25  = unit;
      } else {
        res.add(cond);
      }
    }

    for (JSONObject cond : res) {
      if(!cond.has("code") || cond.isNull("code")){
        continue;
      }
      // チェックリスト項目情報作成用
      OrdChecklistRegCheckInfo condcheckinfo = checkinfo.clone();

      // code「設定値：value」
      String strcode = cond.get("code").toString();
      Integer regcode = null;
      // mod 9324 gjn start
      if (!strcode.equals("null") && !"".equals(strcode)) {
        regcode = Integer.parseInt(cond.get("code").toString());
        condcheckinfo.setCode(regcode);
      }
      // mod 9324 gjn end

      // code_update
      condcheckinfo.setCodeUpdate(null);
      // name
      condcheckinfo.setName(null);
      // class_cd
      if (cond.has("class_cd") && !cond.isNull("class_cd")) {
        String strClassCd = cond.get("class_cd").toString();
        Integer regClassCd = null;
        if (!strClassCd.equals("null")) {
          regClassCd = Integer.valueOf(cond.get("class_cd").toString());
          condcheckinfo.setClassCd(regClassCd);
        }
      }

      // ダイアライザの場合「5：ダイアライザ」
      if (Objects.equals(classcd, 5)) {
        if (Objects.equals(condcheckinfo.getClassCd(), 5)) {
          // ダイアライザマスタから情報取得
          condcheckinfo = settingCondEquipCheckInfoRst(condcheckinfo, ordMain, condcheckinfo.getClassCd());
          // equiptype
          condcheckinfo.setEquipType(1);
        } else {
          // 吸着カラム・1次膜・2次膜：医療材料から情報取得
          condcheckinfo = settingCondEquipCheckInfoRst(condcheckinfo, ordMain, condcheckinfo.getClassCd());
          // equiptype
          condcheckinfo.setEquipType(0);
        }
      }
      // 薬剤の場合「15：透析液」「19：補液」「25：抗凝固剤」
      else if (Objects.equals(classcd, 15) || Objects.equals(classcd, 19) || Objects.equals(classcd, 25)) {

        condcheckinfo = settingCondMedicineCheckInfoRst(condcheckinfo, ordMain, condcheckinfo.getClassCd(), null);
        // 薬剤場合「数量設定」
        if (Objects.equals(classcd, 15)) {
          condcheckinfo.setAmount(amount15.toString());
          condcheckinfo.setUnit(unit15);
        } else if (Objects.equals(classcd, 19)) {
          condcheckinfo.setAmount(amount19.toString());
          condcheckinfo.setUnit(unit19);
        } else if (Objects.equals(classcd, 25)) {
          condcheckinfo.setAmount(amount25.toString());
          condcheckinfo.setUnit(unit25);
        }
      }
      // 医療材料の場合
      else {
        condcheckinfo = settingCondEquipCheckInfoRst(condcheckinfo, ordMain, condcheckinfo.getClassCd());
        // equiptype
        condcheckinfo.setEquipType(0);
      }
// del 10310 needle _ typeの使用を削除するには gjn start
      // needle_type「穿刺針種別」
      // 「9：穿刺針(A針)⇒1」
      // 「10：穿刺針(V針)⇒2」
      // 「11：穿刺針(SN)⇒3」
      // 「その他：空白」
//      if (cond.has("needle_type") && !cond.isNull("needle_type")) {
//        String strntype = cond.get("needle_type").toString();
//        if (!strntype.equals("") && !strntype.equals("null")) {
//          Short ntype = Short.parseShort(strntype);
//          condcheckinfo.setNeedleType(ntype);
//        }
//      }
// del 10310 needle _ typeの使用を削除するには gjn end
      if (condcheckinfo != null) {
        // 登録用
        OrdChecklist condregdata = regdata.clone();
        // rst_checklist_info「チェックリスト項目情報」
        condregdata.setRstChecklistInfo(condcheckinfo);
        // チェックリスト実績登録
        reglist.add(condregdata);
      }
    }
    return reglist;
  }
  //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end



  //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
  private OrdChecklistRegCheckInfo settingCondEquipCheckInfoRst(OrdChecklistRegCheckInfo condcheckinfo, OrdMainForCheckListSchedule ordMain, Integer classCd) {

    JSONObject rstCondInfo = new JSONObject(ordMain.getRstCondInfo());
    if (rstCondInfo.has(classCd.toString())) {
      JSONObject condJsonObj = rstCondInfo.getJSONObject(classCd.toString());
      // name
      condcheckinfo.setName(condJsonObj.isNull("value_name_1") ? null :condJsonObj.get("value_name_1").toString());
      // amount
      condcheckinfo.setAmount("1");
      // medicine_type
      condcheckinfo.setMedicineType(null);
      // unit
      condcheckinfo.setUnit(condJsonObj.isNull("unit") ? null :condJsonObj.get("unit").toString());
      // medicineno
      condcheckinfo.setMedicineNo(null);
    }
    return condcheckinfo;
  }
  //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end


  //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
  private OrdChecklistRegCheckInfo settingCondMedicineCheckInfoRst(OrdChecklistRegCheckInfo condcheckinfo,
                                                                   OrdMainForCheckListSchedule ordMain, Integer classcd, String medicineNo) {
    JSONObject rstCondInfo = new JSONObject(ordMain.getRstCondInfo());
    if (rstCondInfo.has(classcd.toString())) {
      JSONObject condJsonObj = rstCondInfo.getJSONObject(classcd.toString());
      // name
      condcheckinfo.setName(condJsonObj.isNull("value_name_1") ? null :condJsonObj.get("value_name_1").toString());
      // amount
      condcheckinfo.setAmount(null);
      // equiptype
      condcheckinfo.setEquipType(null);
      // medicineno
      condcheckinfo.setMedicineNo(medicineNo);
      // medicinetype
      condcheckinfo.setMedicineType(condJsonObj.isNull("medicine_type") ? null : Integer.parseInt(condJsonObj.get("medicine_type").toString()));
    }
    return condcheckinfo;
  }
  //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end


  // mod 9324 gjn start
  /**
   * 対象の投与薬剤情報を取得する
   * {@inheritDoc}
   */
  private List<OrdChecklistRegMediInfo> getMediInfo(String info, Integer code, List<Object> mstData) {
    // 応答用
    List<OrdChecklistRegMediInfo> res = new ArrayList<>();

    // 投与薬剤指示がない場合
    if (info == null) {
      return res;
    }

    try {
      // 投与薬剤指示リスト
      ObjectMapper map = new ObjectMapper();
      JsonNode medilist = map.readTree(info);
      // del FNSI-重複チェック項目対応 周 start
      // OrdChecklistRegMediInfo regmedi = new OrdChecklistRegMediInfo();
      // del FNSI-重複チェック項目対応 周 end

      // 指示・実績がある場合
      if (! Objects.isNull(medilist) && ! Objects.isNull(code)) {
        for (int i = 0; i < medilist.size(); i++) {
          // add FNSI-重複チェック項目対応 周 start
          OrdChecklistRegMediInfo regmedi = new OrdChecklistRegMediInfo();
          // add FNSI-重複チェック項目対応 周 end
          JsonNode mediInfo = medilist.get(i);
          // code
          String strcode = mediInfo.get("cd").toString();
          Integer setcode = null;
          // codeが登録されているかつ医療材料区分が医療材料の場合
          if (! strcode.equals("null") && ! "".equals(strcode)) {
            setcode = Integer.parseInt(strcode);
            // medicine_type
            // add #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
            if (mediInfo.has("medicine_type")) {
              String strMedicineType = mediInfo.get("medicine_type").toString().replaceAll("\"", "");
              if (! strMedicineType.equals("")) {
                // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
                //Short medicineType = Short.parseShort(strMedicineType);
                Integer medicineType = Integer.parseInt(strMedicineType);
                // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
                regmedi.setMedicineType(medicineType);
              }
            }
            if (regmedi.getMedicineType() == null) {
              continue;
            }
            // add #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
            // 投与薬剤マスタから情報取得
            Integer eclasscd = null;
            Map<Integer, MstMedicine> medicineMap = (Map<Integer, MstMedicine>) mstData.get(2);
            Map<Integer, MstMedicineMix> medicineMixMap = (Map<Integer, MstMedicineMix>) mstData.get(3);
            if (regmedi.getMedicineType() == 1) {
              MstMedicine medidata = medicineMap.get(setcode);
              if (medidata != null) {
                eclasscd = medidata.getClassCd();
              }
            } else if (regmedi.getMedicineType() == 2) {
              MstMedicineMix mediMixdata = medicineMixMap.get(setcode);
              if (mediMixdata != null) {
                eclasscd = mediMixdata.getClassCd();
              }
            } else {
              MstMedicine medidata = medicineMap.get(setcode);
              if (medidata != null) {
                eclasscd = medidata.getClassCd();
              }
            }

            // 投与薬剤マスタに登録されている場合
            if (eclasscd != null) {

              // 対象の投与薬剤がある場合
              if (Objects.equals(eclasscd, code)) {

                regmedi.setCode(setcode);
                // del 10310 needle _ typeの使用を削除するには gjn start
                // needle_type
//                regmedi.setNeedleType(null);
                // del 10310 needle _ typeの使用を削除するには gjn end
                //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
                if (mediInfo.has("no")) {
                  String no = mediInfo.get("no").toString();
                  regmedi.setMedicineNo(no);
                }
                //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end
                // // code_update
                // regmedi.setCodeUpdate(medidata.getUpDate());
                // // name
                // regmedi.setName(medidata.getMedicineName());
                // amount
                String amount = mediInfo.get("amount").toString().replaceAll("\"", "");
                regmedi.setAmount(amount);
                // // unit
                // regmedi.setUnit(medidata.getUnit());

                res.add(regmedi);
              }
            }
          }
        }
      }
    } catch (IOException e) {
      // TODO 自動生成された catch ブロック
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
    }
    // res.sort(Comparator.comparing(OrdChecklistRegMediInfo::getName));
    // mod 9324 gjn end
    return res;
  }

  private boolean jsonNodeIsNull(Object obj) {
    return Objects.isNull(obj) || "null".equals(obj.toString());
  }
  // add FNSI-チェックリスト仕様変更対応#401、#439_チェックリスト機能分。 周 end
  /**
   * 治療中のord_main情報取得
   * {@inheritDoc}
   */
  @Override
  public List<CheckListScheduleResponse> getOrderTreatment(String facilityCd, Short nextPat) {
    List<CheckListScheduleResponse> res = new ArrayList<>();

    // 治療中
    List<TreatmentStatusList> ordList = treatmentStatusListDao.selectAll(facilityCd);
    // 版未確定分
    List<TreatmentStatusList> ordList2 = treatmentStatusListDao.selectOrdMainUnedition(facilityCd);
    // 情報の追加登録
    ordList2.forEach(item -> {
      // 同一情報の重複チェック
      TreatmentStatusList state = ordList.stream()
        .filter(list -> Objects.equals(list.getOrdNo(), item.getOrdNo()))
        .findFirst()
        .orElse(null);
      if (state == null) {
        // 存在しない場合は追加
        ordList.add(item);
      }
    });

    // 患者名取得用
    List<Long> patIdList = ordList.stream()
      .map(s -> s.getPatId())
      .collect(Collectors.toList());
    patIdList.removeAll(Collections.singleton(null)); // null削除
    List<PatPersonalMain> pats = patPersonalMainDao.selectByIdListFacilityCd(patIdList, facilityCd);
    List<PatPersonalMain> pat;
    List<PatMain> patMains = patMainDao.selectByIdListFacilityCd(patIdList, facilityCd);
    List<PatMain> patMain;
    String patLastName = "";
    String patFirstName = "";
    String patName = "";
    String isSame = "0";
    Integer inOutClass = 0;

    for (TreatmentStatusList ord : ordList) {

      // 治療状況取得
      // ※治療状況が空の場合は条件送信前扱い
      String rstDialysisState = ord.getRstDialysisState() == null ? "0"
        : ord.getRstDialysisState().isEmpty() ? "0" : ord.getRstDialysisState();

      // 追加フラグ
      boolean addflg = false;

      // 治療中の場合
      if (!rstDialysisState.equals("0") && !rstDialysisState.equals("6")) {
        // 追加
        addflg = true;
      }

      // 次患者の場合
      if (rstDialysisState.equals("0") && ord.getMachineEntry().equals(1)) {
        // 追加
        addflg = true;
      }

      //
      if (addflg == true) {

        // 患者情報取得
        Long patId = ord.getPatId();

        // 患者判定
        if (ord.getPatId() == null) {
          // ？？？？患者の場合
          patName = "？？？？";
        } else {

          // 患者名取得
          pat = pats.stream().filter(p -> Objects.equals(p.getPat_id(), patId))
            .collect(Collectors.toList());
          patLastName = "";
          patFirstName = "";
          patName = "";
          if (pat.size() > 0) {
            patLastName = pat.get(0).getPat_last_name() == null ? "" : pat.get(0).getPat_last_name();
            patFirstName = pat.get(0).getPat_first_name() == null ? "" : pat.get(0).getPat_first_name();
            patName = patLastName + " " + patFirstName;
            inOutClass = pat.get(0).getIn_out_class();
          }
          // 同姓同名取得
          patMain = patMains.stream().filter(p -> Objects.equals(p.getPat_id(), patId))
            .collect(Collectors.toList());
          if (patMain.size() > 0) {
            isSame = patMain.get(0).getIs_same();
          }
        }

        // 応答用スケジュール情報作成
        CheckListScheduleResponse r = new CheckListScheduleResponse();
        r.setFacilityCd(facilityCd);
        r.setOrdNo(ord.getOrdNo());
        r.setPatId(patId);
        r.setPatName(patName);
        r.setPatFirstName(patFirstName);
        r.setPatLastName(patLastName);
        r.setIsSame(isSame);
        r.setTreatDate(ord.getTreatDate());
        r.setTreatWeek(ord.getTreatWeek().shortValue());
        r.setRstDialysisState(rstDialysisState);
        r.setIndMediInfo(ord.getIndMediInfo());
        r.setIndCondInfo(ord.getIndCondInfo());
        r.setIndEquipInfo(ord.getIndEquipInfo());
        r.setRstMediInfo(ord.getRstMediInfo());
        r.setRstCondInfo(ord.getRstCondInfo());
        r.setRstEquipInfo(ord.getRstEquipInfo());
        r.setMachineEntry(ord.getMachineEntry());
        r.setInOutClass(inOutClass);

        // 治療状態判定
        if (rstDialysisState.equals("0")) {
          // 条件送信前の場合
          r.setKurCd(ord.getIndKurCd());
          r.setKurName(ord.getIndMstKurName());
          r.setBedCd(ord.getIndBedCd());
          r.setBedName(ord.getIndMstBedName());

          r.setDeviceMode(ord.getIndTreatmentDeviceMode());
        } else {
          // 条件送信後の場合
          r.setKurCd(ord.getRstKurCd());
          r.setKurName(ord.getRstKurName());
          r.setBedCd(ord.getRstBedCd());
          r.setBedName(ord.getRstBedName());

          r.setDeviceMode(ord.getRstTreatmentDeviceMode());

          // 治療状況判定
          LocalDateTime dt = null;
          if (rstDialysisState.equals("1") || rstDialysisState.equals("2")) {
            // 条件送信済み～確認済み

            // 条件送信日時
            dt = ord.getRstCondSendDate() == null ? null : ord.getRstCondSendDate().toLocalDateTime();
          } else {
            // 治療中以降

            // 治療開始日時
            dt = ord.getRstStartDate() == null ? null : ord.getRstStartDate().toLocalDateTime();
          }

          // 治療日を更新
          if (dt != null) {
            r.setTreatDate(dt.format(DateTimeFormatter.ofPattern("yyyyMMdd")));
            r.setTreatWeek((short) dt.getDayOfWeek().getValue());
          }
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
    List<PatMain> patMains = patMainDao.selectByIdListFacilityCd(patIdList, facilityCd);
    List<PatMain> patMain;
    String patLastName = "";
    String patFirstName = "";
    String patName = "";
    String isSame = "0";
    Integer inOutClass = 0;

    for (OrdMainForCheckListSchedule ordMainTreat : ordList) {

      // 治療状態取得
      String rstDialysisState = ordMainTreat.getRstDialysisState() == null ? "0"
        : ordMainTreat.getRstDialysisState().isEmpty() ? "0" : ordMainTreat.getRstDialysisState();

      // 患者情報取得
      Long patId = ordMainTreat.getPatId() == null ? null : ordMainTreat.getPatId();
      if (patId == null) {
        // ？？？？患者の場合
        patName = "？？？？";
      } else {
        // 患者名取得
        pat = pats.stream().filter(p -> Objects.equals(p.getPat_id(), ordMainTreat.getPatId()))
          .collect(Collectors.toList());
        patLastName = "";
        patFirstName = "";
        patName = "";
        if (pat.size() > 0) {
          patLastName = pat.get(0).getPat_last_name() == null ? "" : pat.get(0).getPat_last_name();
          patFirstName = pat.get(0).getPat_first_name() == null ? "" : pat.get(0).getPat_first_name();
          patName = patLastName + " " + patFirstName;
          inOutClass = pat.get(0).getIn_out_class();
          // 同姓同名取得
          patMain = patMains.stream().filter(p -> Objects.equals(p.getPat_id(), patId))
            .collect(Collectors.toList());
          if (patMain.size() > 0) {
            isSame = patMain.get(0).getIs_same();
          }
        }
      }

      // 応答用スケジュール情報作成
      CheckListScheduleResponse r = new CheckListScheduleResponse();
      r.setFacilityCd(facilityCd);
      r.setOrdNo(ordMainTreat.getOrdNo());
      r.setPatId(ordMainTreat.getPatId());
      r.setPatName(patName);
      r.setPatFirstName(patFirstName);
      r.setPatLastName(patLastName);
      r.setIsSame(isSame);
      r.setTreatDate(treatDate);
      r.setTreatWeek(ordMainTreat.getTreatWeek());
      r.setRstDialysisState(ordMainTreat.getRstDialysisState());
      r.setIndMediInfo(ordMainTreat.getIndMediInfo());
      r.setIndCondInfo(ordMainTreat.getIndCondInfo());
      r.setIndEquipInfo(ordMainTreat.getIndEquipInfo());
      r.setRstMediInfo(ordMainTreat.getRstMediInfo());
      r.setRstCondInfo(ordMainTreat.getRstCondInfo());
      r.setRstEquipInfo(ordMainTreat.getRstEquipInfo());
      r.setInOutClass(inOutClass);

      // 治療状態判定
      if (rstDialysisState.equals("0")) {
        // 条件送信前の場合
        r.setKurCd(ordMainTreat.getIndKurCd());
        r.setKurName(ordMainTreat.getIndKurName());
        r.setBedCd(ordMainTreat.getIndBedCd());
        r.setBedName(ordMainTreat.getIndBedName());
        r.setDeviceMode(ordMainTreat.getIndDeviceMode());
      } else {
        // 条件送信後の場合
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
    res.setFacilityCd(ordList.getFacilityCd());
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

        // TODO: 調整薬剤・薬剤の区分がmedicine_typeだけではわからないので要修正
        if (Objects.equals(dto.getMedicineType(), MedicineType.CONTROL_MEDICINE)) {
          // 調整薬剤の場合
          MstMedicineMix medicineMix = mstMedicineMixDao.selectByCdWithDeletedRecord(ordList.getFacilityCd(), dto.getCd());
          if (medicineMix != null) {
            dto.setName(medicineMix.getMedicineMixName());
            dto.setUnit(medicineMix.getUnit());
          }
        } else {
          // 薬剤の場合 とする
          // 薬剤名
          MstMedicine medicine = mstMedicineDao.selectByCd(ordList.getFacilityCd(), dto.getCd());
          if (medicine != null) {
            dto.setName(medicine.getMedicineName());
            dto.setUnit(medicine.getUnit());
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
  public List<MstMedicineMix> getMedicineMixList(String facilityCd, List<Integer> medicineMixList) {
    // 調整薬剤リスト情報作成
    List<MstMedicineMix> list = mstMedicineMixDao.selectByMedicineMixCdList(facilityCd, medicineMixList);
    return list;
  }

  /**
   * 医療材料マスタ情報取得
   * {@inheritDoc}
   */
  @Override
  public List<MstEquipment> getEquipList(List<Integer> equipList) {
    // 医療材料リスト情報作成
    List<Integer> filterList = new ArrayList<>();
    //    modify by maxueqiang,bug:5564
    if(CollectionUtils.isNotEmpty(equipList)){
      filterList = equipList.stream().filter(item -> {
        return item != null;
      }).collect(Collectors.toList());
    }
    //    modify by maxueqiang,bug:5564
    List<MstEquipment> list = mstEquipDao.selectByCdList(SelectOptions.get(), filterList);
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
  public ChecklistUpdateResponse ordChecklistUpdate(List<OrdChecklist> param, String facilityCd) throws IOException {

    // 応答用
    ChecklistUpdateResponse res = new ChecklistUpdateResponse();
    // 登録失敗用
    StringBuilder errsb = new StringBuilder();

    // 最新のチェックリストマスタのチェックリストコード取得
    List<MstChecklist> mstChecklist = mstChecklistDao.selectByFacilityCd(SelectOptions.get(), facilityCd, "0");
    Long nowChecklistCd = mstChecklist.get(0).getChecklistCd();

    //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
    OrdMain ordMain = new OrdMain();
    if (param.size() > 0) {
      ordMain = ordMainDao.selectByOrdNo(param.get(0).getOrdNo());
    }
    // add #12270 【因島】ord_checklist.reg_date、up_dateを登録していない処理がある。 関 start
    Timestamp upDate = new Timestamp(System.currentTimeMillis());
    // add #12270 【因島】ord_checklist.reg_date、up_dateを登録していない処理がある。 関 end

    for (OrdChecklist ordCheck : param) {

      // 最新の実績取得
      OrdChecklist nowdata = null;
      if (ordCheck.getFuncClass() == 0) {
        nowdata = ordChecklistDao.selectUpdateInfoForFuncClass0(ordCheck);
      } else {
        nowdata = ordChecklistDao.selectUpdateInfo(ordCheck);
      }

      // mod FNSI-チェックリスト仕様変更対応#401、#439_チェックリスト機能分。 周 start
      // // 条件送信前でチェックリストコードが最新のチェックリストコードと一致しないまたは
      // // 最新の実績情報が存在しないまたは
      // // 最新の実績情報のチェックリスト管理番号と登録データのチェックリスト管理番号が一致するかつ更新日時が同じ場合
      // if ((ordCheck.getChecklistCtlNo() == null
      //     && !Objects.equals(ordCheck.getRstChecklistInfo().getChecklistCd(), nowChecklistCd)) ||
      //     nowdata == null ||
      //     (ordCheck.getChecklistCtlNo().equals(nowdata.getChecklistCtlNo())
      //         && ordCheck.getUpDate().equals(nowdata.getUpDate()))) {

      //   // 条件送信前の新規登録
      //   if (ordCheck.getChecklistCtlNo() == null) {
      //     // 新規登録の場合(ここでfacility_cdをセットする)
      //     ordCheck.setFacilityCd(facilityCd);
      //     ordChecklistDao.insert(ordCheck);

      //   } else {

      //     // 更新前のデータがある場合
      //     if (nowdata != null) {
      //       // 更新前の表示フラグと削除フラグを更新
      //       OrdChecklist deldata = nowdata;
      //       deldata.setIsDel(FlagType.FLAG_ON);
      //      deldata.setIsDisp(FlagType.FLAG_OFF);
      //       ordChecklistDao.update(deldata);
      //     }

      //     // 条件送信前のチェックOFF以外の場合
      //     if (!(ordCheck.getRstClass() == 0 && ordCheck.getIsCheck().equals("0"))) {
      //       // 更新データを新規登録
      //       ordCheck.setChecklistCtlNo(null);
      //       ordChecklistDao.insert(ordCheck);
      //     }
      //   }

      //   // オーダー番号判定
      //   if (ordCheck.getOrdNo() != null) {

      //     // add FNSI-改修内容追加OrdMain履歴 付 start
      //     selectHistoryUtils.insertMangoDbHistory(7, ordCheck.getOrdNo(), null, new ArrayList<>(), new ArrayList<>(), null, null,
      //       null, null, null, new ArrayList<>(), new ArrayList<>(), null, null, null,
      //       new ArrayList<>(), null, null);
      //     // mangoDb-updateIsConfirm-insertSuccess
      //     // add FNSI-改修内容追加OrdMain履歴 付 end

      //     //治療情報の確定フラグが「1：確定」の場合に「0：未確定」に更新する
      //     ordMainDao.updateIsConfirm(ordCheck.getOrdNo(), "1", "0");
      //   }
      // } else {
      //  // 登録できない場合
      //   // エラー情報作成
      //   if (errsb.length() > 0) {
      //     errsb.append(",");
      //   }
      //   errsb.append(mapper.writeValueAsString(ordCheck));
      // }

      // 条件送信前の場合
      // 更新前データのチェックリスト管理番号が存在しない場合
      // 実績データが存在しない場合
      // 更新前データ「実施状態：（１：実施済み）」
      if ("0".equals(ordMain.getRstDialysisState()) &&
        ordCheck.getChecklistCtlNo() == null &&
        nowdata == null &&
        ordCheck.getIsCheck().equals("1")) {

        // 新規登録の場合(ここでfacility_cdをセットする)
        ordCheck.setFacilityCd(facilityCd);
        // add #12270 【因島】ord_checklist.reg_date、up_dateを登録していない処理がある。 関 start
        ordCheck.setUpDate(upDate);
        ordCheck.setRegDate(upDate);
        // add #12270 【因島】ord_checklist.reg_date、up_dateを登録していない処理がある。 関 end
        ordChecklistDao.insert(ordCheck);

        // 治療情報履歴を登録
        selectHistoryUtils.insertMangoDbHistory(7, ordCheck.getOrdNo(), null, new ArrayList<>(), new ArrayList<>(), null, null,
          null, null, null, new ArrayList<>(), new ArrayList<>(), null, null, null,
          new ArrayList<>(), null, null);

        // DB更新ログ出力ロジック wangzuo Start
        String tableName = "ord_main";
        // SQL検索条件
        StringBuffer wheres = new StringBuffer("");
        wheres.append(" WHERE\n");
        wheres.append(" ord_no = " + ordCheck.getOrdNo() + "\n");
        wheres.append(" AND\n");
        wheres.append(" is_confirm = '1'\n");
        // logCommon設定
        DataUpdateLogCommonNew logCommon = getLogCommon(ordMainDao, tableName, wheres, getEventLogMessage());
        // ログ出力カラム情報及び更新前データ情報取得
        boolean setResult = logCommon.setInfo();
        // DB更新ログ出力ロジック wangzuo End

        //mod FNSI-redmine4715 房 start
        // OrdMain ordMain = ordMainDao.selectByOrdNo(ordCheck.getOrdNo());
        List<FacilitySettingInfo> facilitySettingInfos = mstFacilitySettingDao.selectFacilitySetting(ordMain.getFacilityCd(),"3002");
        if (facilitySettingInfos != null && facilitySettingInfos.size() > 0) {
          if (facilitySettingInfos.get(0).getValue() != null && "1".equals(facilitySettingInfos.get(0).getValue())) {
            // 治療情報の確定フラグが「1：確定」の場合に「0：未確定」に更新する
            int updateCount = ordMainDao.updateIsConfirm(ordCheck.getOrdNo(), "1", "0");

            // DB更新ログ出力ロジック wangzuo Start
            // 更新後データ取得、差分あれば、log出力
            if (setResult && updateCount > 0) {
              logCommon.updateLog();
            }
            // DB更新ログ出力ロジック wangzuo End
          }
        }
        //mod FNSI-redmine4715 房 end
      }

      // 条件送信前の場合
      // 更新前データのチェックリスト管理番号が存在する場合
      // 実績データが存在する場合
      // 実績データ「実施状態：（１：実施済み）」
      // 更新前データ「実施状態：（０：未実施）」
      if ("0".equals(ordMain.getRstDialysisState()) &&
        ordCheck.getChecklistCtlNo() != null &&
        nowdata != null &&
        nowdata.getIsCheck().equals("1") &&
        ordCheck.getIsCheck().equals("0")) {

        OrdChecklist deleteData = nowdata.clone();
        // チェックリスト実績を削除
        ordChecklistDao.delete(deleteData);

        // 治療情報履歴を登録
        selectHistoryUtils.insertMangoDbHistory(7, ordCheck.getOrdNo(), null, new ArrayList<>(), new ArrayList<>(), null, null,
          null, null, null, new ArrayList<>(), new ArrayList<>(), null, null, null,
          new ArrayList<>(), null, null);

        // DB更新ログ出力ロジック wangzuo Start
        String tableName = "ord_main";
        // SQL検索条件
        StringBuffer wheres = new StringBuffer("");
        wheres.append(" WHERE\n");
        wheres.append(" ord_no = " + ordCheck.getOrdNo() + "\n");
        wheres.append(" AND\n");
        wheres.append(" is_confirm = '1'\n");
        // logCommon設定
        DataUpdateLogCommonNew logCommon = getLogCommon(ordMainDao, tableName, wheres, getEventLogMessage());
        // ログ出力カラム情報及び更新前データ情報取得
        boolean setResult = logCommon.setInfo();
        // DB更新ログ出力ロジック wangzuo End

        //mod FNSI-redmine4715 房 start
        // OrdMain ordMain = ordMainDao.selectByOrdNo(ordCheck.getOrdNo());
        List<FacilitySettingInfo> facilitySettingInfos = mstFacilitySettingDao.selectFacilitySetting(ordMain.getFacilityCd(),"3002");
        if (facilitySettingInfos != null && facilitySettingInfos.size() > 0) {
          if (facilitySettingInfos.get(0).getValue() != null && "1".equals(facilitySettingInfos.get(0).getValue())) {
            // 治療情報の確定フラグが「1：確定」の場合に「0：未確定」に更新する
            int updateCount = ordMainDao.updateIsConfirm(ordCheck.getOrdNo(), "1", "0");
            // DB更新ログ出力ロジック wangzuo Start
            // 更新後データ取得、差分あれば、log出力
            if (setResult && updateCount > 0) {
              logCommon.updateLog();
            }
            // DB更新ログ出力ロジック wangzuo End
          }
        }
        //mod FNSI-redmine4715 房 end
      }

      // 条件送信前の場合
      // 更新前データのチェックリスト管理番号が存在する場合
      // 実績データが存在する場合
      // 実績データ「実施状態：（１：実施済み）」
      // 更新前データ「実施状態：（１：実施済み）」
      // 更新の場合「実施者更新のみ」
      if ("0".equals(ordMain.getRstDialysisState()) &&
        ordCheck.getChecklistCtlNo() != null &&
        nowdata != null &&
        nowdata.getIsCheck().equals("1") &&
        ordCheck.getIsCheck().equals("1") &&
        (ordCheck.getRegStaffInfo() != nowdata.getRegStaffInfo())) {

        OrdChecklist updateData = nowdata.clone();
        // 更新前の実施者情報を設定
        updateData.setRegStaffInfo(ordCheck.getRegStaffInfo());
        if (ordCheck.getOccurDate() != null && !ordCheck.getOccurDate().equals(nowdata.getOccurDate())) {
          // 更新前の発生日時情報を設定
          updateData.setOccurDate(ordCheck.getOccurDate());
        }
        // add #12270 【因島】ord_checklist.reg_date、up_dateを登録していない処理がある。 関 start
        // del #12691 チェックリストが済みに出来ない fang start
//        updateData.setUpDate(upDate);
        // del #12691 チェックリストが済みに出来ない fang end
        // add #12270 【因島】ord_checklist.reg_date、up_dateを登録していない処理がある。 関 end
        // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
        LogEventUtils.setOperatorId(updateData,logService);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
        // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
        // チェックリスト実績を更新
        ordChecklistDao.update(updateData);

        // 治療情報履歴を登録
        selectHistoryUtils.insertMangoDbHistory(7, ordCheck.getOrdNo(), null, new ArrayList<>(), new ArrayList<>(), null, null,
          null, null, null, new ArrayList<>(), new ArrayList<>(), null, null, null,
          new ArrayList<>(), null, null);

        // DB更新ログ出力ロジック wangzuo Start
        String tableName = "ord_main";
        // SQL検索条件
        StringBuffer wheres = new StringBuffer("");
        wheres.append(" WHERE\n");
        wheres.append(" ord_no = " + ordCheck.getOrdNo() + "\n");
        wheres.append(" AND\n");
        wheres.append(" is_confirm = '1'\n");
        // logCommon設定
        DataUpdateLogCommonNew logCommon = getLogCommon(ordMainDao, tableName, wheres, getEventLogMessage());
        // ログ出力カラム情報及び更新前データ情報取得
        boolean setResult = logCommon.setInfo();
        // DB更新ログ出力ロジック wangzuo End

        //mod FNSI-redmine4715 房 start
        // OrdMain ordMain = ordMainDao.selectByOrdNo(ordCheck.getOrdNo());
        List<FacilitySettingInfo> facilitySettingInfos = mstFacilitySettingDao.selectFacilitySetting(ordMain.getFacilityCd(),"3002");
        if (facilitySettingInfos != null && facilitySettingInfos.size() > 0) {
          if (facilitySettingInfos.get(0).getValue() != null && "1".equals(facilitySettingInfos.get(0).getValue())) {
            // 治療情報の確定フラグが「1：確定」の場合に「0：未確定」に更新する
            int updateCount = ordMainDao.updateIsConfirm(ordCheck.getOrdNo(), "1", "0");

            // DB更新ログ出力ロジック wangzuo Start
            // 更新後データ取得、差分あれば、log出力
            if (setResult && updateCount > 0) {
              logCommon.updateLog();
            }
          }
        }
        //mod FNSI-redmine4715 房 end
        // DB更新ログ出力ロジック wangzuo End
      }

      // 条件送信以降の場合
      // 更新前データのチェックリスト管理番号が存在する場合
      // 実績データが存在する場合
      if (!"0".equals(ordMain.getRstDialysisState()) &&
        ordCheck.getChecklistCtlNo() != null &&
        nowdata != null) {

        OrdChecklist updateData = nowdata.clone();
        if (ordCheck.getIsCheck() != nowdata.getIsCheck()) {
          // 更新前の実施状態情報を設定
          updateData.setIsCheck(ordCheck.getIsCheck());
        }
        if (ordCheck.getRegStaffInfo() != nowdata.getRegStaffInfo()) {
          // 更新前の実施者情報を設定
          updateData.setRegStaffInfo(ordCheck.getRegStaffInfo());
        }
        if (ordCheck.getOccurDate() != nowdata.getOccurDate()) {
          // 更新前の発生日時情報を設定
          updateData.setOccurDate(ordCheck.getOccurDate());
        }
        // add #12270 【因島】ord_checklist.reg_date、up_dateを登録していない処理がある。 関 start
        // del #12691 チェックリストが済みに出来ない fang start
//        updateData.setUpDate(upDate);
        // del #12691 チェックリストが済みに出来ない fang end
        // add #12270 【因島】ord_checklist.reg_date、up_dateを登録していない処理がある。 関 end

        // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
        LogEventUtils.setOperatorId(updateData,logService);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
        // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
        // チェックリスト実績を更新
        ordChecklistDao.update(updateData);

        // 治療情報履歴を登録
        selectHistoryUtils.insertMangoDbHistory(7, ordCheck.getOrdNo(), null, new ArrayList<>(), new ArrayList<>(), null, null,
          null, null, null, new ArrayList<>(), new ArrayList<>(), null, null, null,
          new ArrayList<>(), null, null);

        // DB更新ログ出力ロジック wangzuo Start
        String tableName = "ord_main";
        // SQL検索条件
        StringBuffer wheres = new StringBuffer("");
        wheres.append(" WHERE\n");
        wheres.append(" ord_no = " + ordCheck.getOrdNo() + "\n");
        wheres.append(" AND\n");
        wheres.append(" is_confirm = '1'\n");
        // logCommon設定
        DataUpdateLogCommonNew logCommon = getLogCommon(ordMainDao, tableName, wheres, getEventLogMessage());
        // ログ出力カラム情報及び更新前データ情報取得
        boolean setResult = logCommon.setInfo();
        // DB更新ログ出力ロジック wangzuo End

        //mod FNSI-redmine4715 房 start
        // OrdMain ordMain = ordMainDao.selectByOrdNo(ordCheck.getOrdNo());
        List<FacilitySettingInfo> facilitySettingInfos = mstFacilitySettingDao.selectFacilitySetting(ordMain.getFacilityCd(),"3002");
        if (facilitySettingInfos != null && facilitySettingInfos.size() > 0) {
          if (facilitySettingInfos.get(0).getValue() != null && "1".equals(facilitySettingInfos.get(0).getValue())) {
            // 治療情報の確定フラグが「1：確定」の場合に「0：未確定」に更新する
            int updateCount = ordMainDao.updateIsConfirm(ordCheck.getOrdNo(), "1", "0");

            // DB更新ログ出力ロジック wangzuo Start
            // 更新後データ取得、差分あれば、log出力
            if (setResult && updateCount > 0) {
              logCommon.updateLog();
            }
            // DB更新ログ出力ロジック wangzuo End
          }
        }
        //mod FNSI-redmine4715 房 end
      }

      // mod FNSI-チェックリスト仕様変更対応#401、#439_チェックリスト機能分。 周 end
    }
    //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end

    // 登録失敗情報がある場合
    if (errsb.length() > 0) {
      errsb.insert(0, "[");
      errsb.append("]");
      res.errorDataList = new String(errsb);
    }

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

    // 最新の投薬情報
    String mediInfo = ordList.getRstMediInfo();
    /* modify by chamaojia 2024-01-31 [10196]  Add ignore JSON mismatch conversion--start */
    ObjectMapper mapper = new ObjectMapper();
    mapper.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);

    List<RstMediInfoDto> rstMedilist = mediInfo == null || mediInfo.isEmpty() ? new ArrayList<>()
            : mapper.readValue(mediInfo, new TypeReference<List<RstMediInfoDto>>() {
    });
    /* modify by chamaojia 2024-01-31 [10196]  Add ignore JSON mismatch conversion--end */

    // 登録内容の投薬情報
    String regMediInfo = param.getRstMediInfo();
    List<ReceiveRstMediInfoDto> regMedilist = regMediInfo == null || regMediInfo.isEmpty() ? new ArrayList<>()
      : new ObjectMapper().readValue(regMediInfo, new TypeReference<List<ReceiveRstMediInfoDto>>() {
    });

    // 最新の投薬情報
    // #10046：チェックリストの投与薬剤の実施で500エラー Start
//    String effect_date_str = null;
    // #10046：チェックリストの投与薬剤の実施で500エラー End
    for (RstMediInfoDto nowdata : rstMedilist) {
      // 登録内容の投薬情報
      /* delete by chamaojia 2024-01-31 [10196] No need to convert data types --start */
      // #9733 チェックリスト画面で投与薬剤の実施変更に失敗する。Start
      // #10046：チェックリストの投与薬剤の実施で500エラー Start
//      if (nowdata.getEffectDate() != null ) {
//          TimeZone timezone = TimeZone.getTimeZone("UTC");
//          Date dt = nowdata.getEffectDate();
//          SimpleDateFormat sf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS+00:00");
//          sf.setTimeZone(timezone);
//          effect_date_str = sf.format(dt);
//      } else effect_date_str = null;
      // #10046：チェックリストの投与薬剤の実施で500エラー End
      //  #9733 チェックリスト画面で投与薬剤の実施変更に失敗する。End
      /* delete by chamaojia 2024-01-31 [10196] No need to convert data types --end */
      for (ReceiveRstMediInfoDto regdata : regMedilist) {
        // mod FutreNetWeb+SI課題管理No7157 趙 start
        Long no = nowdata.getNo().longValue();
        // 登録内容のデータと最新のデータを比較する
        // if (regdata.getNo().equals(nowdata.getNo())) {
        if (regdata.getNo().equals(no)) {
          // mod FutreNetWeb+SI課題管理No7157 趙 end
          // 編集前と最新データに変更がなければ登録
          /* modify by chamaojia 2024-01-31 [10196] Comparison and assignment modification of "EffectDate" --start */
          if (regdata.getEffectFlg().equals(nowdata.getEffectFlg())
            // #9733 チェックリスト画面で投与薬剤の実施変更に失敗する。Start
            && Objects.equals(regdata.getEffectDate(), nowdata.getEffectDate())// regdata.getEffectDate().equals(nowdata.getEffectDate()))
//            && Objects.equals(regdata.getEffectDate(), effect_date_str)
            // #9733 チェックリスト画面で投与薬剤の実施変更に失敗する。End
            && Objects.equals(regdata.getEffectUserId(), nowdata.getEffectUserId())) {
            // 登録情報セット
            nowdata.setEffectFlg(regdata.getRegEffectFlg());
            // 投与実施日時 ※ISO8601形式
            nowdata.setEffectDate(regdata.getRegEffectDate());
            nowdata.setEffectUserId(regdata.getRegEffectUserId());
//            nowdata.setEffectUserUpDate(regdata.getRegEffectUserUpDate());
            // userId に紐づく利用者情報を取得
            if (!Objects.isNull(regdata.getRegEffectUserId())) {
              MstPersonalUser userInfo = mstPersonalUserDao.selectById(regdata.getRegEffectUserId());
              if (userInfo != null) {
                nowdata.setEffectUserFirstName(userInfo.getUserFirstName());
                nowdata.setEffectUserLastName(userInfo.getUserLastName());
              }
              //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
            } else {
              nowdata.setEffectUserFirstName(null);
              nowdata.setEffectUserLastName(null);
            }
            //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end
          } else {
            // 登録できない場合
            // エラー情報作成
            if (errsb.length() > 0) {
              errsb.append(",");
            }
            errsb.append(mapper.writeValueAsString(regdata));
          }
          /* modify by chamaojia 2024-01-31 [10196] Comparison and assignment modification of "EffectDate" --end */
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

    // add FNSI-改修内容追加OrdMain履歴 付 start
    getHistory(param.getOrdNo());
    // mangoDb-updateMediInfo-insertSuccess
    // add FNSI-改修内容追加OrdMain履歴 付 end

    // DB更新ログ出力ロジック wangzuo Start
    String tableNameMedi = "ord_main";
    // SQL検索条件
    StringBuffer wheresMedi = new StringBuffer("");
    wheresMedi.append(" WHERE\n");
    wheresMedi.append(" ord_no = " + param.getOrdNo() + "\n");
    // logCommon設定
    DataUpdateLogCommonNew logCommonMedi = getLogCommon(ordMainDao, tableNameMedi, wheresMedi, getEventLogMessage());
    // ログ出力カラム情報及び更新前データ情報取得
    boolean setResultMedi = logCommonMedi.setInfo();
    // DB更新ログ出力ロジック wangzuo End

    // 投与薬剤実績更新
    OrdMain oldOrdMain = ordMainDao.selectByOrdNo(param.getOrdNo());
    int updateCountMedi = ordMainDao.updateMediInfo(param.getOrdNo(), param.getRstMediInfo());
    OrdMain newOrdMain = ordMainDao.selectByOrdNo(param.getOrdNo());
    triggerUtil.updateTriggerOrdMain(Collections.singletonList(oldOrdMain),
      Collections.singletonList(newOrdMain));

    // DB更新ログ出力ロジック wangzuo Start
    // 更新後データ取得、差分あれば、log出力
    if (setResultMedi && updateCountMedi > 0) {
      logCommonMedi.updateLog();
    }
    // DB更新ログ出力ロジック wangzuo End

    // add 11613 by shiyw 20250303 start
    if(!regMedilist.isEmpty()) {
      // mod 11624 by shiyw 20250415 start
//      List<String> medicineNoList = new ArrayList<>();
//      for(ReceiveRstMediInfoDto dto : regMedilist){
//        medicineNoList.add(String.valueOf(dto.getNo()));
//      }
//      ordMaterialSaveDao.updateEffectFlgByMedicineNo(param.getOrdNo(),medicineNoList);
      List<String> medicineNoListEffected = new ArrayList<>();
      List<String> medicineNoListNotEffected = new ArrayList<>();
      for(ReceiveRstMediInfoDto dto : regMedilist){
        if (dto.getRegEffectFlg() != null && dto.getRegEffectFlg().equals(1) ) {
          medicineNoListEffected.add(String.valueOf(dto.getNo()));
        }else {
          medicineNoListNotEffected.add(String.valueOf(dto.getNo()));
        }
      }
      if(!medicineNoListEffected.isEmpty()){
        ordMaterialSaveDao.updateEffectFlgByMedicineNo(param.getOrdNo(),medicineNoListEffected,"1");
      }
      if(!medicineNoListNotEffected.isEmpty()){
        ordMaterialSaveDao.updateEffectFlgByMedicineNo(param.getOrdNo(),medicineNoListNotEffected,"0");
      }
      // mod 11624 by shiyw 20250415 end
    }
    // add 11613 by shiyw 20250303 end

    // オーダー番号判定
    if (param.getOrdNo() != null) {

      // add FNSI-改修内容追加OrdMain履歴 付 start
      selectHistoryUtils.insertMangoDbHistory(7, param.getOrdNo(), null, new ArrayList<>(), new ArrayList<>(), null, null,
        null, null, null, new ArrayList<>(), new ArrayList<>(), null, null, null,
        new ArrayList<>(), null, null);
      // mangoDb-updateIsConfirm-insertSuccess
      // add FNSI-改修内容追加OrdMain履歴 付 end

      // DB更新ログ出力ロジック wangzuo Start
      String tableNameIs = "ord_main";
      // SQL検索条件
      StringBuffer wheresIs = new StringBuffer("");
      wheresIs.append(" WHERE\n");
      wheresIs.append(" ord_no = " + param.getOrdNo() + "\n");
      wheresIs.append(" AND\n");
      wheresIs.append(" is_confirm = '1'\n");
      // logCommon設定
      DataUpdateLogCommonNew logCommonIs = getLogCommon(ordMainDao, tableNameIs, wheresIs, getEventLogMessage());
      // ログ出力カラム情報及び更新前データ情報取得
      boolean setResultIs = logCommonIs.setInfo();
      // DB更新ログ出力ロジック wangzuo End
      // mod #10783 チェックリスト画面から投与薬剤の実施状況を変更しても実績確定済みのまま zhaoqi 20240628 start
      //mod FNSI-redmine4715 房 start
//      OrdMain ordMain = ordMainDao.selectByOrdNo(param.getOrdNo());
//      List<FacilitySettingInfo> facilitySettingInfos = mstFacilitySettingDao.selectFacilitySetting(ordMain.getFacilityCd(),"3002");
//      if (facilitySettingInfos != null && facilitySettingInfos.size() > 0) {
//        if (facilitySettingInfos.get(0).getValue() != null && "1".equals(facilitySettingInfos.get(0).getValue())) {
      // del 11613 by shiyw 20250307 start
//      //治療情報の確定フラグが「1：確定」の場合に「0：未確定」に更新する
//      int updateCountIs = ordMainDao.updateIsConfirm(param.getOrdNo(), "1", "0");
      // del 11613 by shiyw 20250307 end
      // DB更新ログ出力ロジック wangzuo Start
      // 更新後データ取得、差分あれば、log出力
      // mod 11613 by shiyw 20250307 start
//    if (setResultIs && updateCountIs > 0) {
      if (setResultIs) {
      // mod 11613 by shiyw 20250307 end
        logCommonIs.updateLog();
      }
      // DB更新ログ出力ロジック wangzuo End
//        }
//      }
      //mod FNSI-redmine4715 房 end
      // mod #10783 チェックリスト画面から投与薬剤の実施状況を変更しても実績確定済みのまま zhaoqi 20240628 end
    }

    // 登録失敗情報がある場合
    if (errsb.length() > 0) {
      errsb.insert(0, "[");
      errsb.append("]");
      res.errorDataList = new String(errsb);
    }

    return res;
  }

  // add FNSI-改修内容追加OrdMain履歴 付 start
  private void getHistory(Long ordNo){
    selectHistoryUtils.insertMangoDbHistory(1, ordNo, null, new ArrayList<>(), new ArrayList<>(), null, null,
      null, null, null, new ArrayList<>(), new ArrayList<>(), null, null, null,
      new ArrayList<>(), null, null);
  }
  // add FNSI-改修内容追加OrdMain履歴 付 end

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
      for (int j = 0; j < funclist.size(); j++) {
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

        // 登録用
        OrdChecklist regdata = new OrdChecklist();
        regdata.setOrdNo(ordNo);
        regdata.setListCd(listcd);
        regdata.setFacilityCd(facilityCd);
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
            // add #9973 Resolve null exception for key 20240117 ztc start
            if(!cond.has("code") || cond.isNull("code")){
              continue;
            }
            // add #9973 Resolve null exception for key 20240117 ztc end
            // チェックリスト項目情報作成用
            OrdChecklistRegCheckInfo condcheckinfo = checkinfo.clone();

            // code
            String strcode = cond.get("code").toString();
            Integer regcode = null;
            // mod 9324 gjn start
            if (!strcode.equals("null") && !"".equals(strcode)) {
              regcode = Integer.parseInt(cond.get("code").toString());
              condcheckinfo.setCode(regcode);
            }
            // mod 9324 gjn end
            // needle_type
            // add #9973 Resolve null exception for key 20240117 ztc start

            // del 10310 needle _ typeの使用を削除するには gjn start
//            if (cond.has("needle_type") && !cond.isNull("needle_type")) {
//            // add #9973 Resolve null exception for key 20240117 ztc end
//              String strntype = cond.get("needle_type").toString();
//              if (!strntype.equals("")) {
//                Short ntype = Short.parseShort(strntype);
//                condcheckinfo.setNeedleType(ntype);
//              }
//            }
            // del 10310 needle _ typeの使用を削除するには gjn end
            // code_update
            condcheckinfo.setCodeUpdate(null);
            // name
            condcheckinfo.setName(null);

            // class_cd
            // add #9973 Resolve null exception for key 20240117 ztc start
            if (cond.has("class_cd") && !cond.isNull("class_cd")) {
              condcheckinfo.setClassCd(Integer.valueOf(cond.get("class_cd").toString()));
            }
            // add #9973 Resolve null exception for key 20240117 ztc end

            // ダイアライザの場合
            if (Objects.equals(classcd, 5)) {
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
              // add #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
              // mod #9973 Resolve null exception for key 20240117 ztc start
//              if (cond.has("medicine_type")) {
              if (cond.has("medicine_type") && !cond.isNull("medicine_type")) {
              // mod #9973 Resolve null exception for key 20240117 ztc end
                // add #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
                String meditype = cond.get("medicine_type").toString();
                // mod FNSI-チェックリスト仕様変更対応#401、#439_チェックリスト機能分。 周 start
                // if (meditype.equals("2")) {
                //   // 調整薬剤場合
                //   condcheckinfo = settingCondMixMedicineCheckInfo(condcheckinfo, facilityCd, regcode,
                //       list.get("list_name").toString());
                // } else if (meditype.equals("1")) {
                //   // 薬剤
                //   condcheckinfo = settingCondNormalMedicineCheckInfo(condcheckinfo, facilityCd, regcode);
                // } else {
                //   // NOTE: 薬剤種別が異常値の場合はとりあえず薬剤とする
                //   condcheckinfo = settingCondNormalMedicineCheckInfo(condcheckinfo, facilityCd, regcode);
                // }

                if (meditype.equals("2")) {
                  // 調整薬剤場合
                  //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
                  //  condcheckinfo = settingCondMixMedicineCheckInfo(condcheckinfo, facilityCd, regcode,
                  //    condcheckinfo.getClassCd());
                  condcheckinfo = settingCondMixMedicineCheckInfo(condcheckinfo, facilityCd, regcode,
                    condcheckinfo.getClassCd(), null);
                  //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end
                } else if (meditype.equals("1")) {
                  // 薬剤
                  //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
                  //  condcheckinfo = settingCondNormalMedicineCheckInfo(condcheckinfo, facilityCd, regcode,
                  //    condcheckinfo.getClassCd());
                  condcheckinfo = settingCondNormalMedicineCheckInfo(condcheckinfo, facilityCd, regcode,
                    condcheckinfo.getClassCd(), null);
                  //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end
                } else {
                  // NOTE: 薬剤種別が異常値の場合はとりあえず薬剤とする
                  //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
                  //  condcheckinfo = settingCondNormalMedicineCheckInfo(condcheckinfo, facilityCd, regcode,
                  //    condcheckinfo.getClassCd());
                  condcheckinfo = settingCondNormalMedicineCheckInfo(condcheckinfo, facilityCd, regcode,
                    condcheckinfo.getClassCd(), null);
                  //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end
                }
              }
              // mod FNSI-チェックリスト仕様変更対応#401、#439_チェックリスト機能分。 周 end
            }
            // 医療材料の場合
            else {
              condcheckinfo = settingCondEquipCheckInfo(condcheckinfo, regcode, classcd);
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
            equipList = getEquipDailyzerInfo(ordList.getIndEquipInfo(), classcd);

          } else {
            // 対象の医療材料取得
            equipList = getEquipInfo(ordList.getIndEquipInfo(), classcd);
          }

          for (OrdChecklistRegEquipInfo equip : equipList) {

            // チェックリスト項目情報作成用
            OrdChecklistRegCheckInfo equipcheckinfo = settingEquipCheckInfo(checkinfo, equip);

            // 登録用
            OrdChecklist equipregdata = regdata.clone();
            // rst_checklist_info
            equipregdata.setRstChecklistInfo(equipcheckinfo);
            // チェックリスト実績登録
            reglist.add(equipregdata);
          }
        }
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

    // DB更新ログ出力ロジック wangzuo Start
    String tableName = "ord_checklist";
    // SQL検索条件
    StringBuffer wheres = new StringBuffer("");
    wheres.append(" WHERE\n");
    wheres.append(" ord_no = " + ordNo + "\n");
    wheres.append(" AND\n");
    wheres.append(" rst_class = 0\n");
    wheres.append(" AND\n");
    wheres.append(" is_del = '0'\n");
    wheres.append(" AND\n");
    wheres.append(" is_disp = '1'\n");
    // logCommon設定
    DataUpdateLogCommonNew logCommon = getLogCommon(ordChecklistDao, tableName, wheres, getEventLogMessage());
    // ログ出力カラム情報及び更新前データ情報取得
    boolean setResult = logCommon.setInfo();
    // DB更新ログ出力ロジック wangzuo End

    //  del 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
    // 実績区分に条件送信済みをセット
    // int updateCount = ordChecklistDao.updateSendConditionByRstClass(ordNo);

    // DB更新ログ出力ロジック wangzuo Start
    // 更新後データ取得、差分あれば、log出力
    //    if (setResult && updateCount > 0) {
    //      logCommon.updateLog();
    //    }
    // DB更新ログ出力ロジック wangzuo End
    //  del 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end

    res.isSuccess = true;
    return res;

  }

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
   * ダイアライザー用チェックリスト項目作成 Ind
   * @param condcheckinfo
   * @param dialdata
   * @return
   */
  private OrdChecklistRegCheckInfo settingCondDializerCheckInfoInd(OrdChecklistRegCheckInfo condcheckinfo,
                                                                   MstDialyzer dialdata) {
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
  // mod FNSI-チェックリスト仕様変更対応#401、#439_チェックリスト機能分。 周 start
  // private OrdChecklistRegCheckInfo settingCondNormalMedicineCheckInfo(OrdChecklistRegCheckInfo condcheckinfo,
  //     String facilityCd, Integer regcode) {
  //  private OrdChecklistRegCheckInfo settingCondNormalMedicineCheckInfo(OrdChecklistRegCheckInfo condcheckinfo,
  //                                                                      String facilityCd, Integer regcode, Integer classcd) {
  private OrdChecklistRegCheckInfo settingCondNormalMedicineCheckInfo(OrdChecklistRegCheckInfo condcheckinfo,
                                                                      String facilityCd, Integer regcode, Integer classcd, String medicineNo) {
    // mod FNSI-チェックリスト仕様変更対応#401、#439_チェックリスト機能分。 周 end
    //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end

    // 薬剤マスタから情報取得
    MstMedicine medidata = mstMedicineDao.selectByCd(facilityCd, regcode);

    if (medidata != null) {
      // code_update
      String strdate = DateTimeUtils.getDateString_iso8601(medidata.getUpDate());
      condcheckinfo.setCodeUpdate(strdate);
      // name
      condcheckinfo.setName(medidata.getMedicineName());
      // add FNSI-チェックリスト仕様変更対応#401、#439_チェックリスト機能分。 周 start
      // medicine_type「薬剤区分」（1: 通常薬剤）
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
      //condcheckinfo.setMedicineType(Short.parseShort("1"));
      condcheckinfo.setMedicineType(1);
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
      //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
      condcheckinfo.setMedicineNo(null);
      //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end
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
      // add FNSI-チェックリスト仕様変更対応#401、#439_チェックリスト機能分。 周 end
      //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
      if (medicineNo != null) {
        condcheckinfo.setMedicineNo(medicineNo);
      }
      //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end
    }
    return condcheckinfo;
  }


  /**
   * 通常薬剤用チェックリスト項目作成 Ind
   * @param condcheckinfo
   * @param facilityCd
   * @param medidata
   * @return
   */
  private OrdChecklistRegCheckInfo settingCondNormalMedicineCheckInfoInd(OrdChecklistRegCheckInfo condcheckinfo,
                                                                         String facilityCd, MstMedicine medidata, Integer classcd, String medicineNo) {
    if (medidata != null) {
      // code_update
      String strdate = DateTimeUtils.getDateString_iso8601(medidata.getUpDate());
      condcheckinfo.setCodeUpdate(strdate);
      // name
      condcheckinfo.setName(medidata.getMedicineName());
      // add FNSI-チェックリスト仕様変更対応#401、#439_チェックリスト機能分。 周 start
      // medicine_type「薬剤区分」（1: 通常薬剤）
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
      //condcheckinfo.setMedicineType(Short.parseShort("1"));
      condcheckinfo.setMedicineType(1);
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
      //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
      condcheckinfo.setMedicineNo(null);
      //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end
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
      // add FNSI-チェックリスト仕様変更対応#401、#439_チェックリスト機能分。 周 end
      //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
      if (medicineNo != null) {
        condcheckinfo.setMedicineNo(medicineNo);
      }
      //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end
    }
    return condcheckinfo;
  }


  /**
   * 調製薬剤用のチェックリスト項目構築
   * @param condcheckinfo
   * @param regcode
   * @param regcode
   * @return
   */
  //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
  // mod FNSI-チェックリスト仕様変更対応#401、#439_チェックリスト機能分。 周 start
  // private OrdChecklistRegCheckInfo settingCondMixMedicineCheckInfo(OrdChecklistRegCheckInfo condcheckinfo,
  //     String facilityCd, Integer regcode, String listName) {
  //  private OrdChecklistRegCheckInfo settingCondMixMedicineCheckInfo(OrdChecklistRegCheckInfo condcheckinfo,
  //                                                                   String facilityCd, Integer regcode, Integer classcd) {
  // mod FNSI-チェックリスト仕様変更対応#401、#439_チェックリスト機能分。 周 end
  private OrdChecklistRegCheckInfo settingCondMixMedicineCheckInfo(OrdChecklistRegCheckInfo condcheckinfo,
                                                                   String facilityCd, Integer regcode, Integer classcd, String medicineNo) {
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
      // add FNSI-チェックリスト仕様変更対応#401、#439_チェックリスト機能分。 周 start
      // medicine_type「薬剤区分」（2: 調製薬剤「投与薬剤、調製薬剤の場合」）
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
      //condcheckinfo.setMedicineType(Short.parseShort("2"));
      condcheckinfo.setMedicineType(2);
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
      //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
      condcheckinfo.setMedicineNo(null);
      //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end
      // 治療条件の場合
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
      // add FNSI-チェックリスト仕様変更対応#401、#439_チェックリスト機能分。 周 end
      //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
      if (medicineNo != null) {
        condcheckinfo.setMedicineNo(medicineNo);
      }
      //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end
    }
    return condcheckinfo;
  }

  /**
   * 調製薬剤用のチェックリスト項目構築 Ind
   *
   * @param condcheckinfo
   * @param facilityCd
   * @param medidata
   * @param classcd
   * @param medicineNo
   * @return OrdChecklistRegCheckInfo
   */
  private OrdChecklistRegCheckInfo settingCondMixMedicineCheckInfoInd(OrdChecklistRegCheckInfo condcheckinfo,
                                                                      String facilityCd, MstMedicineMix medidata, Integer classcd, String medicineNo) {
    if (medidata != null) {
      // code_update
      String strdate = DateTimeUtils.getDateString_iso8601(medidata.getUpDate());
      condcheckinfo.setCodeUpdate(strdate);
      // name
      //      condcheckinfo.setName(listName);
      condcheckinfo.setName(medidata.getMedicineMixName());
      // add FNSI-チェックリスト仕様変更対応#401、#439_チェックリスト機能分。 周 start
      // medicine_type「薬剤区分」（2: 調製薬剤「投与薬剤、調製薬剤の場合」）
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
      //condcheckinfo.setMedicineType(Short.parseShort("2"));
      condcheckinfo.setMedicineType(2);
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
      //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
      condcheckinfo.setMedicineNo(null);
      //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end
      // 治療条件の場合
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
      // add FNSI-チェックリスト仕様変更対応#401、#439_チェックリスト機能分。 周 end
      //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
      if (medicineNo != null) {
        condcheckinfo.setMedicineNo(medicineNo);
      }
      //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end
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

      // mod FNSI-チェックリスト仕様変更対応#401、#439_チェックリスト機能分。 周 start
      // // 穿刺針の場合
      //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
      if (Objects.equals(classcd, 9) || Objects.equals(classcd, 10) || Objects.equals(classcd, 11)) {
        // amount
        condcheckinfo.setAmount("1");
        // unit
        condcheckinfo.setUnit("本");
      }
      //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end

      // medicine_type
      condcheckinfo.setMedicineType(null);
      // amount
      condcheckinfo.setAmount("1");
      // unit
      condcheckinfo.setUnit(equipdata.getUnit());
      // mod FNSI-チェックリスト仕様変更対応#401、#439_チェックリスト機能分。 周 end
      //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
      condcheckinfo.setEquipType(0);
      //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end
    }

    return condcheckinfo;
  }


  /**
   * 治療条件の医療材料チェックリスト構築 Ind
   *
   * @param condcheckinfo
   * @param equipdata
   * @param classcd
   * @return
   */
  private OrdChecklistRegCheckInfo settingCondEquipCheckInfoInd(OrdChecklistRegCheckInfo condcheckinfo, MstEquipment equipdata,
                                                                Integer classcd) {
    if (equipdata != null) {
      // code_update
      String strdate = DateTimeUtils.getDateString_iso8601(equipdata.getUpDate());
      condcheckinfo.setCodeUpdate(strdate);
      // name
      condcheckinfo.setName(equipdata.getEquipmentName());

      // mod FNSI-チェックリスト仕様変更対応#401、#439_チェックリスト機能分。 周 start
      // // 穿刺針の場合
      //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
      if (Objects.equals(classcd, 9) || Objects.equals(classcd, 10) || Objects.equals(classcd, 11)) {
        // amount
        condcheckinfo.setAmount("1");
        // unit
        condcheckinfo.setUnit("本");
      }
      //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end

      // medicine_type
      condcheckinfo.setMedicineType(null);
      // amount
      condcheckinfo.setAmount("1");
      // unit
      condcheckinfo.setUnit(equipdata.getUnit());
      // mod FNSI-チェックリスト仕様変更対応#401、#439_チェックリスト機能分。 周 end
      //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
      condcheckinfo.setEquipType(0);
      //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end
    }

    return condcheckinfo;
  }


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
//    equipcheckinfo.setNeedleType(equip.getNeedleType());
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
    equipcheckinfo.setEquipType(equip.getEquipType());
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
//    checkinfo.setNeedleType(null);
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

      for (int condlp = 0; condlp < codelist.size(); condlp++) {

        JSONObject obj = new JSONObject();

        // class_cdがある場合
        if (!Objects.isNull(codelist.get(condlp))) {

          // 対象の治療条件
          String code = codelist.get(condlp).toString();
          JsonNode condinfo = condlist.has(code) ? condlist.get(code) : null;
          // mod #9973 Resolve null exception for key 20240117 ztc start
//          JsonNode value = Objects.isNull(condinfo) ? null : condinfo.get("value");
          JsonNode value = Objects.isNull(condinfo) || !condinfo.has("value") ? null : condinfo.get("value");
          // mod #9973 Resolve null exception for key 20240117 ztc end
          // #9973 Mod by Zhou.tao Fix the way for getting value Start
//          String strval = Objects.isNull(value) ? "null" : value.toString();
          String strval = Objects.isNull(value) ? "null" : value.asText();
          // #9973 Mod by Zhou.tao Fix the way for getting value End
          // 対象の治療条件がある場合
          if (!Objects.isNull(condinfo) && !strval.equals("null")) {
// del 10310 needle _ typeの使用を削除するには gjn start
            // 穿刺針種別
            //String ntype = "";
            // 穿刺針の場合
//            if (!Objects.isNull(needleType_cond.get(codelist.get(condlp)))) {
//              ntype = needleType_cond.get(codelist.get(condlp)).toString();
//            }
// del 10310 needle _ typeの使用を削除するには gjn end

            // #9973 Mod by Zhou.tao Fix the way for getting value Start
//            obj.put("code", condinfo.get("value"));
            obj.put("code", condinfo.get("value").asText());
            // #9973 Mod by Zhou.tao Fix the way for getting value End
            // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
            if (condinfo.has("medicine_type")) {
              // #9973 Mod by Zhou.tao Fix the way for getting value from jsonNode Start
//              String strmtype = condinfo.get("medicine_type").toString().replaceAll("\"", "");
              String strmtype = condinfo.get("medicine_type").asText();
              // #9973 Mod by Zhou.tao Fix the way for getting value End
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
            //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
            if (condinfo.has("unit")) {
              String unit = condinfo.get("unit").asText();
              obj.put("unit", unit);
            }
            //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end
            // del 10310 needle _ typeの使用を削除するには gjn start
            //obj.put("needle_type", ntype);
            // del 10310 needle _ typeの使用を削除するには gjn end
            obj.put("class_cd", codelist.get(condlp));

            res.add(obj);
          }
        }
      }

    } catch (IOException e) {
      // TODO 自動生成された catch ブロック
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
    }
    return res;

  }

  //対象の医療材料情報取得
  List<OrdChecklistRegEquipInfo> getEquipInfo(String info, Integer code) {

    // 応答用
    List<OrdChecklistRegEquipInfo> res = new ArrayList<>();

    // 医療材料指示がない場合
    if (info == null) {
      return res;
    }

    try {
      // 医療材料指示リスト
      ObjectMapper map = new ObjectMapper();
      JsonNode equiplist = map.readTree(info);
      // del FNSI-重複チェック項目対応 周 start
      // OrdChecklistRegEquipInfo regequip = new OrdChecklistRegEquipInfo();
      // del FNSI-重複チェック項目対応 周 end

      // 指示・実績がある場合
      if (!Objects.isNull(equiplist) && !Objects.isNull(code)) {
        for (int equiplp = 0; equiplp < equiplist.size(); equiplp++) {
          // add FNSI-重複チェック項目対応 周 start
          OrdChecklistRegEquipInfo regequip = new OrdChecklistRegEquipInfo();
          // add FNSI-重複チェック項目対応 周 end
          JsonNode equipInfo = equiplist.get(equiplp);

          // #9973 Mod by Zhou.tao Fix the way for getting value from jsonNode Start
          // code
//          if (equipInfo.get("cd") == null) {
          if (!equipInfo.hasNonNull("cd")) {
            continue;
          }
//          String strcode = equipInfo.get("cd").toString();
//          Integer setcode = null;
          // equip_type
          // equip_type
//          String strtype = "0";
//          if (equipInfo.get("equip_type") != null) {
//            strtype = equipInfo.get("equip_type").toString();
//          }
          //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
          // Integer setcode = equipInfo.get("cd").isValueNode() ? equipInfo.get("equip_type").asInt() : null;
          Integer setcode = equipInfo.get("cd").isValueNode() ? equipInfo.get("cd").asInt() : null;
          //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end

          Integer equipType = equipInfo.hasNonNull("equip_type") && equipInfo.get("equip_type").isValueNode()
            ? equipInfo.get("equip_type").asInt() : null;
          // codeが登録されているかつ医療材料区分が医療材料の場合
//          if (!strcode.equals("null") && strtype.equals("0")) {
          if (setcode != null && equipType != null && equipType == 0) {
//            setcode = Integer.parseInt(strcode);
            // 医療材料マスタから情報取得
            MstEquipment equipdata = mstEquipDao.selectByEquipmentCd(setcode);

            // 医療材料マスタに登録されている場合
            if (equipdata != null) {
              Integer eclasscd = equipdata.getClassCd();

              // 対象の医療材料がある場合
              if (Objects.equals(eclasscd, code)) {

                regequip.setCode(setcode);
                // needle_type
//                String strntype = equipInfo.get("needle_type").toString().replaceAll("\"", "");
//                Short ntype = null;
//                if (!strntype.equals("null")) {
//                  ntype = Short.parseShort(strntype);
//                  regequip.setNeedleType(ntype);
//                }
                //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
                //  regequip.setNeedleType(
                //    equipInfo.has("needle_type")
                //      && !equipInfo.get("needle_type").isNull()
                //      && equipInfo.get("needle_type").isValueNode() ?
                //      Short.parseShort(equipInfo.get("needle_type").asText()) : null
                //  );
                // del 10310 needle _ typeの使用を削除するには gjn start
                //regequip.setNeedleType(null);
                // del 10310 needle _ typeの使用を削除するには gjn end

                //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end

                // code_update
                regequip.setCodeUpdate(equipdata.getUpDate());
                // name
                regequip.setName(equipdata.getEquipmentName());
                // amount
//                String amount = equipInfo.get("amount").toString().replaceAll("\"", "");
//                regequip.setAmount(amount);
                // mod #9973 Resolve null exception for key 20240117 ztc start
//                regequip.setAmount(equipInfo.get("amount").asText());
                regequip.setAmount(
                        equipInfo.has("amount")
                                && !equipInfo.get("amount").isNull()
                                ? equipInfo.get("amount").asText() : null
                );
                // mod #9973 Resolve null exception for key 20240117 ztc end
                // #9973 Mod by Zhou.tao Fix the way for getting value from jsonNode End
                // unit
                regequip.setUnit(equipdata.getUnit());
                //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
                regequip.setEquipType(0);
                //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end

                res.add(regequip);
              }
            }
          }
        }
      }

    } catch (IOException e) {
      // TODO 自動生成された catch ブロック
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
    }
    res.sort(Comparator.comparing(OrdChecklistRegEquipInfo::getName));
    return res;

  }

  //add 9324 医療材料マスタ検索性能の最適化 gjn start
  //対象の医療材料情報取得
  List<OrdChecklistRegEquipInfo> getEquipInfoInd(String info, Integer code, Map<Integer, MstEquipment> equipmentMap) {
    // 応答用
    List<OrdChecklistRegEquipInfo> res = new ArrayList<>();
    // 医療材料指示がない場合
    if (info == null) {
      return res;
    }
    try {
      // 医療材料指示リスト
      ObjectMapper map = new ObjectMapper();
      JsonNode equiplist = map.readTree(info);
      // del FNSI-重複チェック項目対応 周 start
      // OrdChecklistRegEquipInfo regequip = new OrdChecklistRegEquipInfo();
      // del FNSI-重複チェック項目対応 周 end

      // 指示・実績がある場合
      if (!Objects.isNull(equiplist) && !Objects.isNull(code)) {
        for (int equiplp = 0; equiplp < equiplist.size(); equiplp++) {
          // add FNSI-重複チェック項目対応 周 start
          OrdChecklistRegEquipInfo regequip = new OrdChecklistRegEquipInfo();
          // add FNSI-重複チェック項目対応 周 end
          JsonNode equipInfo = equiplist.get(equiplp);
          // code
          if (!equipInfo.hasNonNull("cd")) {
            continue;
          }
          Integer setcode = equipInfo.get("cd").isValueNode() ? equipInfo.get("cd").asInt() : null;
          Integer equipType = equipInfo.hasNonNull("equip_type") && equipInfo.get("equip_type").isValueNode()
            ? equipInfo.get("equip_type").asInt() : null;
          // codeが登録されているかつ医療材料区分が医療材料の場合
          if (setcode != null && equipType != null && equipType == 0) {
            // 医療材料マスタから情報取得
            //MstEquipment equipdata = mstEquipDao.selectByEquipmentCd(setcode);
            MstEquipment equipdata = equipmentMap.get(setcode);
            // 医療材料マスタに登録されている場合
            if (equipdata != null) {
              Integer eclasscd = equipdata.getClassCd();
              // 対象の医療材料がある場合
              if (Objects.equals(eclasscd, code)) {
                regequip.setCode(setcode);
                // del 10310 needle _ typeの使用を削除するには gjn start
                // needle_type
                //regequip.setNeedleType(null);
                // del 10310 needle _ typeの使用を削除するには gjn end

                //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end

                // code_update
                regequip.setCodeUpdate(equipdata.getUpDate());
                // name
                regequip.setName(equipdata.getEquipmentName());
                // amount
                regequip.setAmount(
                  equipInfo.has("amount")
                    && !equipInfo.get("amount").isNull()
                    ? equipInfo.get("amount").asText() : null
                );
                // unit
                regequip.setUnit(equipdata.getUnit());
                //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
                regequip.setEquipType(0);
                //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end
                res.add(regequip);
              }
            }
          }
        }
      }
    } catch (IOException e) {
      // TODO 自動生成された catch ブロック
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
    }
    res.sort(Comparator.comparing(OrdChecklistRegEquipInfo::getName));
    return res;
  }
//add 9324 医療材料マスタ検索性能の最適化 gjn end

  //対象のダイアライザ情報取得
  List<OrdChecklistRegEquipInfo> getEquipDailyzerInfo(String info, Integer code) {

    // 応答用
    List<OrdChecklistRegEquipInfo> res = new ArrayList<>();

    // 医療材料指示がない場合
    if (info == null) {
      return res;
    }

    try {
      // 医療材料指示リスト
      ObjectMapper map = new ObjectMapper();
      JsonNode equiplist = map.readTree(info);
      // del FNSI-重複チェック項目対応 周 start
      // OrdChecklistRegEquipInfo regequip = new OrdChecklistRegEquipInfo();
      // del FNSI-重複チェック項目対応 周 end

      // 指示・実績がある場合
      if (!Objects.isNull(equiplist) && !Objects.isNull(code)) {
        for (int equiplp = 0; equiplp < equiplist.size(); equiplp++) {
          // add FNSI-重複チェック項目対応 周 start
          OrdChecklistRegEquipInfo regequip = new OrdChecklistRegEquipInfo();
          // add FNSI-重複チェック項目対応 周 end
          JsonNode equipInfo = equiplist.get(equiplp);

          // #9973 Mod by Zhou.tao Fix the way for getting value from jsonNode Start
          // code
//          if (equipInfo.get("cd") == null) {
//            continue;
//          }
//          String strcode = equipInfo.get("cd").toString();
//          if ("null".equals(strcode)) {
//            continue;
//          }
          if (!equipInfo.hasNonNull("cd")) {
            continue;
          }
          Integer setcode = equipInfo.get("cd").isValueNode() ? equipInfo.get("cd").asInt() : null;
          // equip_type
          String equip_type = "0";
          if (equipInfo.hasNonNull("equip_type")) {
            equip_type = equipInfo.get("equip_type").asText();
          }
          // ダイアライザの場合
          if ("1".equals(equip_type) && setcode != null) {
//            setcode = Integer.parseInt(strcode);
            // ダイアライザマスタから情報取得
            MstDialyzer dialdata = mstDialyzerDao.selectByDialyzerCd(SelectOptions.get(), setcode);

            // 対象のダイアライザがある場合
            if (dialdata != null) {

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
//              String amount = equipInfo.get("amount").toString().replaceAll("\"", "");
//              regequip.setAmount(amount);
              // mod #9973 Resolve null exception for key 20240117 ztc start
//              regequip.setAmount(equipInfo.get("amount").asText());
              regequip.setAmount(
                      equipInfo.has("amount")
                              && !equipInfo.get("amount").isNull()
                              ? equipInfo.get("amount").asText() : null
              );
              // mod #9973 Resolve null exception for key 20240117 ztc end
              // #9973 Mod by Zhou.tao Fix the way for getting value from jsonNode Start
              // unit
              regequip.setUnit("本");
              //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
              regequip.setEquipType(1);
              //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end
              res.add(regequip);
            }
          }
        }
      }

    } catch (IOException e) {
      // TODO 自動生成された catch ブロック
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
    }
    return res;

  }

  //add 9324 医療材料指示検索性能の最適化 gjn start
  //対象のダイアライザ情報取得
  List<OrdChecklistRegEquipInfo> getEquipDailyzerInfoInd(String info, Integer code, Map<Integer, MstDialyzer> dialyzerMap) {
    // 応答用
    List<OrdChecklistRegEquipInfo> res = new ArrayList<>();
    // 医療材料指示がない場合
    if (info == null) {
      return res;
    }
    try {
      // 医療材料指示リスト
      ObjectMapper map = new ObjectMapper();
      JsonNode equiplist = map.readTree(info);
      // 指示・実績がある場合
      if (!Objects.isNull(equiplist) && !Objects.isNull(code)) {
        for (int equiplp = 0; equiplp < equiplist.size(); equiplp++) {
          // add FNSI-重複チェック項目対応 周 start
          OrdChecklistRegEquipInfo regequip = new OrdChecklistRegEquipInfo();
          // add FNSI-重複チェック項目対応 周 end
          JsonNode equipInfo = equiplist.get(equiplp);
          if (!equipInfo.hasNonNull("cd")) {
            continue;
          }
          Integer setcode = equipInfo.get("cd").isValueNode() ? equipInfo.get("cd").asInt() : null;
          // equip_type
          String equip_type = "0";
          if (equipInfo.hasNonNull("equip_type")) {
            equip_type = equipInfo.get("equip_type").asText();
          }
          // ダイアライザの場合
          if ("1".equals(equip_type) && setcode != null) {
//            setcode = Integer.parseInt(strcode);
            // ダイアライザマスタから情報取得
            //MstDialyzer dialdata = mstDialyzerDao.selectByDialyzerCd(SelectOptions.get(), setcode);
            MstDialyzer dialdata = dialyzerMap.get(setcode);
            // 対象のダイアライザがある場合
            if (dialdata != null) {

              regequip.setCode(setcode);
              // del 10310 needle _ typeの使用を削除するには gjn start
              // needle_type
              //regequip.setNeedleType(null);
              // del 10310 needle _ typeの使用を削除するには gjn end

              // code_update
              regequip.setCodeUpdate(dialdata.getUpDate());
              // name
              regequip.setName(dialdata.getModelNumber());
              // amount
              regequip.setAmount(
                equipInfo.has("amount")
                  && !equipInfo.get("amount").isNull()
                  ? equipInfo.get("amount").asText() : null
              );
              // unit
              regequip.setUnit("本");
              //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
              regequip.setEquipType(1);
              //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end
              res.add(regequip);
            }
          }
        }
      }
    } catch (IOException e) {
      // TODO 自動生成された catch ブロック
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
    }
    return res;
  }
  //add 9324 医療材料指示検索性能の最適化 gjn end


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
    private Integer equipType;
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
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
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

  }
  // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
  //public class MedicineType {
    //public static final String MEDICINE = "1";
    //public static final String CONTROL_MEDICINE = "2";
  public static class MedicineType {
    public static final Integer MEDICINE = 1;
    public static final Integer CONTROL_MEDICINE = 2;
  // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
  }

  // add FNSI-チェックリスト仕様変更対応#401、#439_チェックリスト機能分。 周 start
  // チェックリスト実績作成用投与薬剤情報クラス
  @Domain(valueType = String.class)
  @Getter
  @Setter
  @NoArgsConstructor
  public static class OrdChecklistRegMediInfo {
    /** ObjectMapper */
    private static ObjectMapper objectMapper = new ObjectMapper();

    /** ModelMapper */
    private static ModelMapper modelMapper = new ModelMapper();

    /**
     * 投与薬剤コード
     */
    @JsonProperty("code")
    private Integer code;
// del 10310 needle _ typeの使用を削除するには gjn start
    /**
     * 穿刺針区分(null)
     */
//    @JsonProperty("needle_type")
//    private Short needleType;
// del 10310 needle _ typeの使用を削除するには gjn end
    /**
     * 薬剤区分(1: 通常薬剤、2: 調製薬剤)
     */
    @JsonProperty("medicine_type")
    // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
    //private Short medicineType;
    private Integer medicineType;
    // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end

    /**
     * 投与薬剤更新日時
     */
    @JsonProperty("code_update")
    private Timestamp codeUpdate;

    /**
     * 投与薬剤名
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
     * 薬剤識別番号
     */
    @JsonProperty("medicine_no")
    private String medicineNo;
    //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end

    /**
     * コンストラクタ.
     * @param value JSON文字列
     */
    public OrdChecklistRegMediInfo(String value) {
      try {
        OrdChecklistRegMediInfo obj = objectMapper.readValue(value, OrdChecklistRegMediInfo.class);
        modelMapper.map(obj, this);
      } catch (IOException e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
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

  }
  // add FNSI-チェックリスト仕様変更対応#401、#439_チェックリスト機能分。 周 end

  @Override
  public Short getAutoReloadInterval(String facilityCd) {
    FacilitySettingInfo infoCheckListReloadInterval = mstFacilitySettingDao.getBySettingNoAndCd(facilityCd,
      FacilitySettingNo.CHECK_LIST_RELOAD_INTERVAL);
    return Short.valueOf(infoCheckListReloadInterval.getValue());
  }

  // add チェックリストマスタ 指示変更、実績変更に伴うチェックリストの反映 孔 start
  /**
   * チェックリスト実績削除
   */
  @Override
  @Transactional
  public Integer deleteOrdChecklist(List<OrdChecklist> param) {
    Integer r = 0;
//del 9324 ord_checklist共通之外的dao方法删除 gjn start
//    for (OrdChecklist ordChecklist : param) {
//      r += ordChecklistDao.deleteByOrdChecklist(ordChecklist);
//    }
    //del 9324 ord_checklist共通之外的dao方法删除 gjn end
    return r;
  }
  // add チェックリストマスタ 指示変更、実績変更に伴うチェックリストの反映 孔 end

  // add FNSI-チェックリスト仕様変更対応#401、#439_患者経過総合ビューア機能分。 周 start
  /**
   * チェックリスト実績削除
   */
  @Override
  @Transactional
  public Integer deleteByOrdNo(long ordNo, String facilityCd) {
//del 9324 ord_checklist共通之外的dao方法删除 gjn start
//    return ordChecklistDao.deleteByOrdNo(ordNo, facilityCd);
    return 0;
  }
  // add FNSI-チェックリスト仕様変更対応#401、#439_患者経過総合ビューア機能分。 周 end

  // add FNSI-障害票一覧_患者経過総合ビューアNo.29 李 start
  /**
   * チェックリスト実績を追加する
   * @param latestOrdNo
   * @param oldOrdNo
   * @return 追加結果
   */
  @Override
  @Transactional
  public Integer insertOrdChecklist(String latestOrdNo, String oldOrdNo) {
    //del 9324 ord_checklist共通之外的dao方法删除 gjn start
    //return ordChecklistDao.insertOrdChecklistByOrdNo(latestOrdNo, oldOrdNo);
    return 1;
    //del 9324 ord_checklist共通之外的dao方法删除 gjn end
  }
  // add FNSI-障害票一覧_患者経過総合ビューアNo.29 李 end

  // DB更新ログ出力ロジック wangzuo Start
  /**
   * ログ情報設定
   *
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
    eventLogMessage.setServiceName(LoggingConstant.MODULE_NAME.ADMIN_WEB + "," + LoggingConstant.SERVICE_NAME.FNSI);
    return eventLogMessage;
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
   * オーダー番号からチェックリスト進度(チェック済み項目数, 項目数)情報を取得する「条件送信前」
   * {@inheritDoc}
   */
  @Override
  public List<List<List<Long>>> getOrdCheckListShindoZen(List<OrdCheckListParams> ordCheckListParamsList, String facilityCd) throws IOException {

    List<List<List<Long>>> resultList = new ArrayList<>();

    // 最新のチェックリストマスタを取得
    List<MstChecklist> mstChecklist = mstChecklistDao.selectByFacilityCd(SelectOptions.get(), facilityCd, "0");
    MstChecklist nowMstChecklist = mstChecklist.get(0);
    String strSetting = nowMstChecklist.getChecklistSettings();
    ObjectMapper map = new ObjectMapper();
    JsonNode node = map.readTree(strSetting);
    List<Long> ordNos = ordCheckListParamsList.stream().map(el -> el.getOrdNo()).collect(Collectors.toList());
    //add FNSI-パフォーマンス 房 start
    List<OrdChecklist> ordCheckListCheckedAllForAllOrdNo = ordChecklistDao.selectByOrdNoListCdMasterExistAll(SelectOptions.get(), ordNos);

    // mod 9324 gjn start
    List<OrdMainForCheckListSchedule> ordMainList = ordMainDao.selectByOrdNoListChecklist(ordNos);

    //治療情報から指示治療条件、投与薬剤、医療材料のMstデータを取得
    // 0, dializer, 1, equipment, 2, medicine, 3, medicineMix
    List<Object> mstData = getMstData(ordMainList);
    for (Long ordNo : ordNos) {
      List<List<Long>> res = new ArrayList<>();
      // チェックリストマスタ.チェックリストコード
      Long checklistCd = null;
      // ord_mainの情報取得
      Optional<OrdMainForCheckListSchedule> ordMainForCheckListSchedule = ordMainList.stream().filter(a -> a.getOrdNo().equals(ordNo)).findFirst();
      if (ordMainForCheckListSchedule.isEmpty()) {
        continue;
      }
      OrdMainForCheckListSchedule ordMain = ordMainForCheckListSchedule.get();
      // mod 9324 gjn end
      // ord_mainに情報がない場合
      if (ordMain == null) {
        //FNSI-修正 #6079 チェックリスト画面が開けない対応、xugj add start
        List<Long> listres = new ArrayList<>();
        listres.add(checklistCd);
        res.add(0, listres);
        resultList.add(res);
        //FNSI-修正 #6079 チェックリスト画面が開けない対応、xugj add end
        continue;
      }

      // 登録用チェックリストデータを作成
      // mod 9324 gjn start
      List<OrdChecklist> regList = getRegisterChecklist(ordMain, node, (long) nowMstChecklist.getChecklistCd(), false, mstData);
      // mod 9324 gjn end
      List<OrdChecklist> ordCheckListCheckedAll = ordCheckListCheckedAllForAllOrdNo.stream().filter(el -> el.getOrdNo().equals(ordNo)).collect(Collectors.toList());

      for (int i = 1; i <= 8; i++) {
        // チェックリストマスタ.チェックリスト設定.リストコード「1～8で固定で使用」
        Short listCd = Short.parseShort(Integer.toString(i));
        // 登録用チェックリストデータ（リストコード別）
        List<OrdChecklist> ordCheckListUnchecked = regList.stream()
          .filter(s -> s.getListCd() == listCd)
          .collect(Collectors.toList());
        List<OrdChecklist> ordCheckListChecked = ordCheckListCheckedAll.stream().filter(el -> el.getListCd() == listCd).collect(Collectors.toList());

        if (ordCheckListUnchecked.size() > 0) {
          // チェックリスト実績.チェックリスト項目情報.チェックリストコード
          // オーダー番号とリストコードが同じ場合、チェックリストコードが一致する
          //FNSI-修正 #6079 チェックリスト画面が開けない対応、xugj add start
          if (ordCheckListUnchecked.get(0).getRstChecklistInfo() != null) {
            //FNSI-修正 #6079 チェックリスト画面が開けない対応、xugj add end
            checklistCd = ordCheckListUnchecked.get(0).getRstChecklistInfo().getChecklistCd();
          }
        }

        List<Long> listres = new ArrayList<>();
        // チェック済み項目数「チェックリスト実績情報」
        listres.add((long) ordCheckListChecked.stream()
          .filter(s -> s.getIsCheck().equals(FlagType.FLAG_ON))
          .collect(Collectors.toList())
          .size());
        // 全項目数セット「チェックリストマスタ情報と治療指示情報」
        listres.add((long) ordCheckListUnchecked.size());
        res.add(listres);
      }
      // 先頭にチェックリストコードを追記
      List<Long> listres = new ArrayList<>();
      listres.add(checklistCd);
      res.add(0, listres);

      resultList.add(res);
    }

    return resultList;
  }

  /**
   * オーダー番号からチェックリスト進度(チェック済み項目数, 項目数)情報を取得する「条件送信以降」
   * {@inheritDoc}
   */
  @Override
  public List<List<List<Long>>> getOrdCheckListShindoIcou(List<OrdCheckListParams> ordCheckListParamsList) {

    List<List<List<Long>>> resultList = new ArrayList<>();

    List<Long> ordNos = ordCheckListParamsList.stream().map(el->el.getOrdNo()).collect(Collectors.toList());

    List<OrdChecklist> ordCheckListAllOfAllOrdNos =
      ordChecklistDao.selectByOrdNoListCdAll(SelectOptions.get(), ordNos);

    for (Long ordNo : ordNos) {
      List<List<Long>> res = new ArrayList<>();
      // チェックリストマスタ.チェックリストコード
      Long checklistCd = null;
      //add FNSI-パフォーマンス 房 start
      List<OrdChecklist> ordCheckListAll =
        ordCheckListAllOfAllOrdNos.stream().filter(el->el.getOrdNo().equals(ordNo)).collect(Collectors.toList());
      for (int i = 1; i <= 8; i++) {
        Short listCd = Short.parseShort(Integer.toString(i));
        List<OrdChecklist> ordCheckList =
          //mod FNSI-パフォーマンス 房 start
          // mod FutreNetWeb+SI課題管理No5613 趙 start
          // ordCheckListAll.stream().filter(el->el.getListCd() == listCd).collect(Collectors.toList()).stream()
          // .filter(p -> !p.getRstClass().equals(Short.parseShort("9")))
          // .collect(Collectors.toList());
          ordCheckListAll.stream().filter(el->el.getListCd() == listCd).collect(Collectors.toList()).stream()
            //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
            //  .filter(p -> p.getRstClass() != null && !p.getRstClass().equals(Short.parseShort("9")))
            .filter(p -> p.getRstClass() != null && !p.getRstClass().equals(Short.parseShort("9"))
              &&!p.getRstClass().equals(Short.parseShort("8"))&&!p.getRstClass().equals(Short.parseShort("7")))
            //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end
            .collect(Collectors.toList());
        // mod FutreNetWeb+SI課題管理No5613 趙 end
        if (ordCheckList.size() > 0) {
          // チェックリスト実績.チェックリスト項目情報.チェックリストコード
          // オーダー番号とリストコードが同じ場合、チェックリストコードが一致する
          //FNSI-修正 #6079 チェックリスト画面が開けない対応、xugj add start
          if (ordCheckList.get(0).getRstChecklistInfo() != null) {
            //FNSI-修正 #6079 チェックリスト画面が開けない対応、xugj add end
            checklistCd = ordCheckList.get(0).getRstChecklistInfo().getChecklistCd();
          }
        }
        List<Long> listres = new ArrayList<>();
        // チェック済み項目数
        listres.add((long)ordCheckList.stream()
          .filter(s -> s.getIsCheck().equals(FlagType.FLAG_ON))
          .collect(Collectors.toList())
          .size());
        // 全項目数セット
        listres.add((long)ordCheckList.size());
        res.add(listres);
      }
      // 先頭にチェックリストコードを追記
      List<Long> listres = new ArrayList<>();
      listres.add(checklistCd);
      res.add(0, listres);
      resultList.add(res);
    }

    return resultList;
  }

  //mod #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi start
  /* add #8535 by zhangruixue 2023-04-27 --start */
  @Override
  public void indApprovedForStatusMap(Long ordNo) throws Exception {
    String logMsg = String.format("指示変更検知用の指示情報保存処理開始 ord_no: %d", ordNo);
    // TODO: 共通ログ出力に切り替える
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(logMsg);
    logService.log(LogLevel.INFO, eventLogMessage,null, LoggingConstant.SERVICE_NAME.FNSI, null);
    OrdMain ordMain = ordMainDao.selectByOrdNo(ordNo);
    IndScheduleUser user = getIndScheduleUser(ordMain);

    String content = getJsonStr(ordMain, user);

    // 更新
    PatIndApprove patIndApprove = new PatIndApprove();
    patIndApprove.setOrd_no(ordNo);
    patIndApprove.setIs_content_changed_for_map(FlagType.FLAG_OFF);

    patIndApprove.setContent_for_map(content);

    patIndApproveDao.updateForMap(patIndApprove);

    logMsg = String.format("指示変更検知用の指示情報保存処理完了 ord_no: %d", ordNo);
    eventLogMessage.setLogMessage(logMsg);
    // TODO: 共通ログ出力に切り替える
    logService.log(LogLevel.INFO, eventLogMessage,null, LoggingConstant.SERVICE_NAME.FNSI, null);
  }
  //mod #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi end

  @Data
  private class IndScheduleUser {
    private String instructorName;
    private String updaterName;

    public IndScheduleUser(String instructorName, String updaterName) {
      this.instructorName = instructorName;
      this.updaterName = updaterName;
    }
  }

  /**
   * 指示者、更新者の取得
   * @param ordMain 指示
   * @return
   */
  private IndScheduleUser getIndScheduleUser(OrdMain ordMain) {
    try {
      JsonNode node = mapper.readTree(ordMain.getIndScheduleUserInfo());
      String instructorName = "";
      String updaterName = "";
      if (node.has(IND_USER_LAST_NAME) && node.has(IND_USER_FIRST_NAME)) {
        instructorName = node.get(IND_USER_LAST_NAME).asText("") + " " + node.get(IND_USER_FIRST_NAME).asText("");
      }
      if (node.has(UPD_USER_LAST_NAME) && node.has(UPD_USER_FIRST_NAME)) {
        updaterName = node.get(UPD_USER_LAST_NAME).asText("") + " " + node.get(UPD_USER_FIRST_NAME).asText("");
      }
      IndScheduleUser user = new IndScheduleUser(instructorName, updaterName);
      return user;
    } catch (IOException e) {
      return new IndScheduleUser("", "");
    }
  }

  //mod #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi start
  /**
   * 治療方法のセット
   * @param ordMain 指示
   * @param user 指示者情報
   * @return
   */
  private PatIndApproveDto buildTreatMethod(OrdMain ordMain, IndScheduleUser user) {
    PatIndApproveDto patIndApproveDto = new PatIndApproveDto();

    // デフォルト項目
    patIndApproveDto.setComponent("treat-method");
    patIndApproveDto.setSubCategoryNo(2);
    patIndApproveDto.setSubCategoryName("治療方法");
    List<ItemInfo> itemInfoList = new ArrayList<>();
    patIndApproveDto.setSubCategoryItem(itemInfoList);
    ItemInfo.Item item = new ItemInfo.Item();
    item.setItemNo(1);
    String treatMentName = "";
    if (!Objects.isNull(ordMain.getIndTreatmentCd())) {
      item.setItemCd(ordMain.getIndTreatmentCd());
      //mod #9507 一括指示受けに時間がかかる zrx start
//      treatMentName = ordMain.getIndTreatmentName();
      treatMentName = ordMain.getIndTreatmentName() != null ? ordMain.getIndTreatmentName() : "";
      //mod #9507 一括指示受けに時間がかかる zrx end
    }
    ItemInfo.ItemData itemData = new ItemInfo.ItemData();
    itemData.setInstructor(user.getInstructorName());
    itemData.setUpdater(user.getUpdaterName());
    ItemInfo.ValueData value = new ItemInfo.ValueData();
    itemData.setValue(value);
    value.setUnit(null);
    value.setDispVal(getPrefixStr(treatMentName).get("value").isEmpty() ? null : getPrefixStr(treatMentName).get("value"));
    value.setPrefix(getPrefixStr(treatMentName).get("prefix").isEmpty() ? null : getPrefixStr(treatMentName).get("prefix"));
    item.setData(itemData);
    patIndApproveDto.setItemInfo(item);

    return patIndApproveDto;
  }
  //mod #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi end

  //mod #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi start
  /**
   * スケジュール情報取得
   * @param ordMain 指示
   * @param user 指示者情報
   * @return
   */
  private PatIndApproveDto buildSchedule(OrdMain ordMain, IndScheduleUser user) {
    PatIndApproveDto patIndApproveDto = new PatIndApproveDto();

    // デフォルト項目
    patIndApproveDto.setComponent("schedule");
    patIndApproveDto.setSubCategoryNo(3);
    patIndApproveDto.setSubCategoryName("スケジュール");
    List<ItemInfo> itemInfoList = new ArrayList<>();
    // 1:クール
    itemInfoList.add(buildScheduleInfo(1, ordMain, user));
    // 2:治療開始時刻
    itemInfoList.add(buildScheduleInfo(2, ordMain, user));
    // 3:ベッド
    itemInfoList.add(buildScheduleInfo(3, ordMain, user));
    patIndApproveDto.setSubCategoryItem(itemInfoList);

    return patIndApproveDto;
  }
  //mod #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi end

  //mod #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi start
  /**
   * 治療条件情報取得
   * @param ordMain 指示
   * @return
   */
  private PatIndApproveDto buildCondInfo(OrdMain ordMain) {
    PatIndApproveDto patIndApproveDto = new PatIndApproveDto();

    // デフォルト項目
    patIndApproveDto.setComponent("treat-cond");
    patIndApproveDto.setSubCategoryNo(4);
    patIndApproveDto.setSubCategoryName("治療条件");
    List<ItemInfo> itemInfo = new ArrayList<>();
    JsonNode indCondInfo;
    try {
      indCondInfo = mapper.readTree(ordMain.getIndCondInfo());
    } catch (Exception e) {
      indCondInfo = null;
    }
    // 1～38: indCondInfo
    for (int i = 1; i <= 38; i++) {
      if (indCondInfo != null) {
        // add #10739 コンバート施設で指示受け(治療単位)が表示されない 関 start
        if (i == 3) {
          itemInfo.add(buildDwInfo(indCondInfo, ordMain));
        }
        // add #10739 コンバート施設で指示受け(治療単位)が表示されない 関 end
        itemInfo.add(buildCondInfoItem(indCondInfo, ordMain, i));
      }
    }
    // -1:DW
    // del #10739 コンバート施設で指示受け(治療単位)が表示されない 関 start
    //    if (indCondInfo != null) {
    //      itemInfo.add(buildDwInfo(indCondInfo, ordMain));
    //    }
    // del #10739 コンバート施設で指示受け(治療単位)が表示されない 関 end
    patIndApproveDto.setSubCategoryItem(itemInfo);

    return patIndApproveDto;
  }
  //mod #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi end

  //mod #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi start
  /**
   * 薬剤情報取得
   * @param ordMain 指示
   * @return
   */
  private PatIndApproveDto buildMedicine(OrdMain ordMain) {
    PatIndApproveDto patIndApproveDto = new PatIndApproveDto();

    // デフォルト項目
    patIndApproveDto.setComponent("medicine");
    patIndApproveDto.setSubCategoryNo(5);
    patIndApproveDto.setSubCategoryName("投与薬剤");
    /* add by shiyw 2024-03-28 #10196 ord_mainのデータ定義の修正:OrdMain.equipInfo/mediInfo/IndCommentInfoがnullの場合を考える --start */
    if(ObjectUtils.isEmpty(ordMain.getIndMediInfo())) {
      return patIndApproveDto;
    }
    /* add by shiyw 2024-03-28 #10196 ord_mainのデータ定義の修正:OrdMain.equipInfo/mediInfo/IndCommentInfoがnullの場合を考える --end */
    JsonNode indMediInfo;
    try {
      indMediInfo = mapper.readTree(ordMain.getIndMediInfo());
    } catch (Exception e) {
      indMediInfo = null;
    }
    // データから取得
    List<ItemInfo> subCatItems = new ArrayList<>();
    // indMediInfo
    if (indMediInfo != null) {
      for (int i = 0; i < indMediInfo.size(); i++) {
        subCatItems.add(buildMediInfoItem(indMediInfo, i));
      }
    }
    //add #9507 一括指示受けに時間がかかる zrx start
    if (Objects.equals("0", ordMain.getRstDialysisState())) {
      for (ItemInfo itemInfo : subCatItems) {
        if (itemInfo.getItemInfo() != null && itemInfo.getItemInfo().getItemName().equals(NO_DATA)) {
          itemInfo.getItemInfo().setItemName(null);
        }
      }
    }
    //add #9507 一括指示受けに時間がかかる zrx end

    patIndApproveDto.setSubCategoryItem(subCatItems);

    return patIndApproveDto;
  }
  //mod #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi end

  //mod #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi start
  /**
   * 医材情報取得
   * @param ordMain 指示
   * @return
   */
  private PatIndApproveDto buildEquip(OrdMain ordMain) {
    PatIndApproveDto patIndApproveDto = new PatIndApproveDto();

    // デフォルト項目
    patIndApproveDto.setComponent("equipment");
    patIndApproveDto.setSubCategoryNo(6);
    patIndApproveDto.setSubCategoryName("医療材料");
    /* add by shiyw 2024-03-28 #10196 ord_mainのデータ定義の修正:OrdMain.equipInfo/mediInfo/IndCommentInfoがnullの場合を考える --start */
    if(ObjectUtils.isEmpty(ordMain.getIndEquipInfo())) {
      return patIndApproveDto;
    }
    /* add by shiyw 2024-03-28 #10196 ord_mainのデータ定義の修正:OrdMain.equipInfo/mediInfo/IndCommentInfoがnullの場合を考える --end */
    JsonNode indEquipInfo;
    try {
      indEquipInfo = mapper.readTree(ordMain.getIndEquipInfo());
    } catch (Exception e) {
      indEquipInfo = null;
    }
    // データから取得
    List<ItemInfo> subCatItems = new ArrayList<>();
    // indEquipInfo
    for (int i = 0; i < indEquipInfo.size(); i++) {
      subCatItems.add(buildEquipInfoItem(indEquipInfo, i));
    }
    //add #9507 一括指示受けに時間がかかる zrx start
    if (Objects.equals("0", ordMain.getRstDialysisState())) {
      for (ItemInfo itemInfo : subCatItems) {
        if (itemInfo.getItemInfo() != null && itemInfo.getItemInfo().getItemName().equals(NO_DATA)) {
          itemInfo.getItemInfo().setItemName(null);
        }
      }
    }
    //add #9507 一括指示受けに時間がかかる zrx end

    patIndApproveDto.setSubCategoryItem(subCatItems);

    return patIndApproveDto;
  }
  //mod #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi end

  //mod #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi start
  /**
   * コメント情報取得
   * @param ordMain 指示
   * @return
   */
  private PatIndApproveDto buildComment(OrdMain ordMain) {
    PatIndApproveDto patIndApproveDto = new PatIndApproveDto();

    // デフォルト項目
    patIndApproveDto.setComponent("ind-comment");
    patIndApproveDto.setSubCategoryNo(7);
    patIndApproveDto.setSubCategoryName("指示コメント");
    /* add by shiyw 2024-03-28 #10196 ord_mainのデータ定義の修正:OrdMain.equipInfo/mediInfo/IndCommentInfoがnullの場合を考える --start */
    if(ObjectUtils.isEmpty(ordMain.getIndIndCommentInfo())) {
      return patIndApproveDto;
    }
    /* add by shiyw 2024-03-28 #10196 ord_mainのデータ定義の修正:OrdMain.equipInfo/mediInfo/IndCommentInfoがnullの場合を考える --end */
    JsonNode indIndCommentInfo;
    try {
      indIndCommentInfo = mapper.readTree(ordMain.getIndIndCommentInfo());
    } catch (Exception e) {
      indIndCommentInfo = null;
    }
    // データから取得
    List<ItemInfo> subCatItems = new ArrayList<>();
    // indIndCommentInfo
    for (int i = 0; i < indIndCommentInfo.size(); i++) {
      subCatItems.add(buildIndIndCommentInfoItem(indIndCommentInfo, i));
    }

    patIndApproveDto.setSubCategoryItem(subCatItems);

    return patIndApproveDto;
  }
  //mod #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi end

  //add #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi start
  /**
   * @param n       2-1 クールの取得 2-2 治療開始時刻の取得 2-3 ベッドの取得
   * @param ordMain 指示
   * @param user    指示者情報
   */
  private ItemInfo buildScheduleInfo(int n, OrdMain ordMain, IndScheduleUser user) {
    ItemInfo indItem = new ItemInfo();
    ItemInfo.Item itemInfo = new ItemInfo.Item();
    String itemName = switch (n) {
      case 1 -> "クール";
      case 2 -> "治療開始時刻";
      case 3 -> "ベッド";
      default -> "";
    };
    // mod #10739 コンバート施設で指示受け(治療単位)が表示されない 関 start
    Integer itemCd = switch (n) {
      case 1 -> ordMain.getIndKurCd();
      case 2 -> null;
      case 3 -> ordMain.getIndBedCd();
      default -> null;
    };

    itemInfo.setItemName(itemName);
    itemInfo.setItemNo(n);
    //add #9507 一括指示受けに時間がかかる zrx start
    if(Objects.equals("0", ordMain.getRstDialysisState())) {
      if(n == 1 && ordMain.getIndKurCd() == 0) {
        itemCd = null;
      }
    }
    //add #9507 一括指示受けに時間がかかる zrx end
    itemInfo.setItemCd(itemCd);
    // mod #10739 コンバート施設で指示受け(治療単位)が表示されない 関 end
    ItemInfo.ItemData itemData = new ItemInfo.ItemData();
    itemData.setInstructor(user.getInstructorName());
    itemData.setUpdater(user.getUpdaterName());
    ItemInfo.ValueData value = getValueData(n, ordMain);
    itemData.setValue(value);
    itemInfo.setData(itemData);
    indItem.setItemInfo(itemInfo);

    return indItem;
  }
  //add #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi end

  //add #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi start
  /**
   * @param n       2-1 クールの取得 2-2 治療開始時刻の取得 2-3 ベッドの取得
   * @param ordMain 指示
   * @return
   */
  private ItemInfo.ValueData getValueData(int n, OrdMain ordMain) {
    ItemInfo.ValueData value = new ItemInfo.ValueData();
    // mod #10739 コンバート施設で指示受け(治療単位)が表示されない 関 start
    String dispVal = "";
    String prefix = null;
    switch (n) {
      case 1:
        dispVal = ordMain.getIndKurName();
        if (Objects.isNull(dispVal) || dispVal.isEmpty()) {
          dispVal = NO_DATA;
        }
        break;
      case 2:
        dispVal = ordMain.getIndTreatStartTime();
        if (Objects.isNull(dispVal) || dispVal.isEmpty()) {
          dispVal = NO_DATA;
        } else {
          LocalDate date = LocalDate.parse(ordMain.getTreatDate(), DateTimeFormatter.ofPattern("yyyyMMdd"));
          dispVal = dispVal.substring(0, 2) + ":" + dispVal.substring(2);
          prefix = date.format(DateTimeFormatter.ofPattern("yyyy/MM/dd")) + " ";
        }
        break;
      case 3:
        dispVal = ordMain.getIndBedName();
        if (Objects.isNull(dispVal) || dispVal.isEmpty()) {
          dispVal = NO_DATA;
        }
        break;
    }
    //add #9507 一括指示受けに時間がかかる zrx start
    if(Objects.equals("0", ordMain.getRstDialysisState())) {
      if((n == 1 || n == 3) && (ordMain.getIndBedCd() > 0 || ordMain.getIndKurCd() > 0)) {
        dispVal = null;
      }
    }
    //add #9507 一括指示受けに時間がかかる zrx end
    value.setDispVal(dispVal);
    value.setPrefix(prefix);
    // mod #10739 コンバート施設で指示受け(治療単位)が表示されない 関 end
    value.setUnit(null);
    return value;
  }
  //add #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi end

  //mod #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi start
  /**
   * 3-1～3-38 治療条件の取得
   * @param indCondInfo 指示条件
   * @param idx 指示番号
   * @return
   */
  private ItemInfo buildCondInfoItem(JsonNode indCondInfo, OrdMain ordMain, int idx) {
    String valKey = "value";
    String itemIdx = String.valueOf(idx);
    String indValue = NO_DATA, indUser = "", updUser = "", unit = null;
    boolean hasValue = false;
    boolean hasIdx = false;
    // add #10739 コンバート施設で指示受け(治療単位)が表示されない 関 start
    LocalDate date = LocalDate.parse(ordMain.getTreatDate(), DateTimeFormatter.ofPattern("yyyyMMdd"));
    String treatDate = date.format(DateTimeFormatter.ofPattern("yyyy/MM/dd"));
    // add #10739 コンバート施設で指示受け(治療単位)が表示されない 関 end

    if (indCondInfo.has(itemIdx)) {
      hasIdx = true;
      JsonNode node = indCondInfo.get(itemIdx);
      if (node.has(IND_USER_LAST_NAME) && node.has(IND_USER_FIRST_NAME)) {
        indUser = node.get(IND_USER_LAST_NAME).asText("") + " " + node.get(IND_USER_FIRST_NAME).asText("");
      }
      if (node.has(UPD_USER_LAST_NAME) && node.has(UPD_USER_FIRST_NAME)) {
        updUser = node.get(UPD_USER_LAST_NAME).asText("") + " " + node.get(UPD_USER_FIRST_NAME).asText("");
      }
      if (node.has(valKey) && !Objects.isNull(node.get(valKey))) {
        // 値あり
        String v = node.get(valKey).asText();
        if (!"null".equals(v)) {
          hasValue = true;
        }
      }
    }

    if (indUser.isEmpty()) {
      MstPersonalUser user = MasterCacheHandler.get().getMstPersonalUser(ordMain.getUpUserId());
      if (user != null) {
        indUser = user.getUserLastName() + " " + user.getUserFirstName();
      }
    }
    if (updUser.isEmpty()) {
      MstPersonalUser user = MasterCacheHandler.get().getMstPersonalUser(ordMain.getUpIndUserId());
      if (user != null) {
        updUser = user.getUserLastName() + " " + user.getUserFirstName();
      }
    }


    ItemInfo itemInfo = new ItemInfo();
    ItemInfo.Item indItem = new ItemInfo.Item();
    indItem.setItemNo(idx);
    switch (idx) {
      case 1:
        // 治療時間
        indItem.setItemName("治療時間");
        if (hasValue) {
          try {
            // Mod #9973 By Tao.zhou fix the type of JSON value node. Start Since 2023-10-27
//            int minuteTotal = indCondInfo.get(itemIdx).get(valKey).intValue();
            int minuteTotal = indCondInfo.get(itemIdx).get(valKey).asInt();
            // Mod #9973 By Tao.zhou fix the type of JSON value node. End Since 2023-10-27
            int hours = minuteTotal / 60;
            int minutes = minuteTotal % 60;
            indValue = String.format("%02d:%02d", hours, minutes);
          } catch (Exception e) {
            String errMsg = String.format("治療条件：%sの設定値取得に失敗しました.[%s]", "治療時間", e.getMessage());
            // TODO: 共通ログ出力に切り替える
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage(errMsg);
            logService.log(LogLevel.INFO, eventLogMessage,null, LoggingConstant.SERVICE_NAME.FNSI, null);
          }
        }
        break;
      case 2:
        // VA
        indItem.setItemName("VA");
        // mod #10739 コンバート施設で指示受け(治療単位)が表示されない 関 start
        indItem.setItemCd(Optional.ofNullable(indCondInfo.get(itemIdx))
          .map(node -> node.get(valKey))
          .filter(node -> !node.isNull())
          .map(JsonNode::asInt)
          .orElse(null));
        // mod #10739 コンバート施設で指示受け(治療単位)が表示されない 関 end
        if (hasValue) {
          indValue = getValueName1(indCondInfo, itemIdx, "VA");
        }
        break;
      case 3:
          // 目標体重
        indItem.setItemName("目標体重");
        if (hasValue) {
          try {
            String value = indCondInfo.get(itemIdx).get(valKey).asText();
            BigDecimal bdVal = new BigDecimal(value);
            if ("-1".equals(value) || bdVal.compareTo(new BigDecimal(-1)) == 0) {
              indValue = "DWと同じ";
            } else {
              DecimalFormat df = new DecimalFormat("0.00");
              indValue = df.format(bdVal);
              unit = "kg";
            }
          } catch (Exception e) {
            String errMsg = String.format("治療条件：%sの設定値取得に失敗しました.[%s]", "目標体重", e.getMessage());
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage(errMsg);
            logService.log(LogLevel.INFO, eventLogMessage,null, LoggingConstant.SERVICE_NAME.FNSI, null);
          }
        }
        break;
      case 4:
        // 除水量制限
        indItem.setItemName("除水量制限");
        if (hasValue) {
          try {
            indValue = indCondInfo.get(itemIdx).get(valKey).asText();
            unit = "L";
          } catch (Exception e) {
            String errMsg = String.format("治療条件：%sの設定値取得に失敗しました.[%s]", "除水量制限", e.getMessage());
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage(errMsg);
            logService.log(LogLevel.INFO, eventLogMessage,null, LoggingConstant.SERVICE_NAME.FNSI, null);
          }
        }
        break;
      case 5:
        // ダイアライザ
        indItem.setItemName("ダイアライザ");
        indItem.setItemType(null);// 医療材料区分 0:医療材料、1:ダイアライザ
        // mod #10739 コンバート施設で指示受け(治療単位)が表示されない 関 start
        indItem.setItemCd(Optional.ofNullable(indCondInfo.get(itemIdx))
          .map(node -> node.get(valKey))
          .filter(node -> !node.isNull())
          .map(JsonNode::asInt)
          .orElse(null));
        // mod #10739 コンバート施設で指示受け(治療単位)が表示されない 関 end
        if (hasValue) {
          try {
            String name1 = "";
            if (indCondInfo.get(itemIdx).has("value_name_1") && !Objects.isNull(indCondInfo.get(itemIdx).get("value_name_1"))) {
              name1 = indCondInfo.get(itemIdx).get("value_name_1").asText();
            }
            indValue = "[" + name1 + "]";
            unit = "本";
          } catch (Exception e) {
            String errMsg = String.format("治療条件：%sの設定値取得に失敗しました.[%s]", "ダイアライザ", e.getMessage());
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage(errMsg);
            logService.log(LogLevel.INFO, eventLogMessage,null, LoggingConstant.SERVICE_NAME.FNSI, null);
          }
        }
        break;
      case 6:
        // 吸着カラム
        indItem.setItemName("吸着カラム");
        // mod #10739 コンバート施設で指示受け(治療単位)が表示されない 関 start
        indItem.setItemCd(Optional.ofNullable(indCondInfo.get(itemIdx))
          .map(node -> node.get(valKey))
          .filter(node -> !node.isNull())
          .map(JsonNode::asInt)
          .orElse(null));
        // mod #10739 コンバート施設で指示受け(治療単位)が表示されない 関 end
        if (hasValue) {
          indValue = getValueName1(indCondInfo, itemIdx, "吸着カラム");
          Map<String, String> res = getValueMedicineAmount(indCondInfo, itemIdx, "吸着カラム");
          unit = res.get("unit");
        }
        break;
      case 7:
        // 1次膜
        indItem.setItemName("1次膜");
        // mod #10739 コンバート施設で指示受け(治療単位)が表示されない 関 start
        indItem.setItemCd(Optional.ofNullable(indCondInfo.get(itemIdx))
          .map(node -> node.get(valKey))
          .filter(node -> !node.isNull())
          .map(JsonNode::asInt)
          .orElse(null));
        // mod #10739 コンバート施設で指示受け(治療単位)が表示されない 関 end
        if (hasValue) {
          indValue = getValueName1(indCondInfo, itemIdx, "1次膜");
          Map<String, String> res = getValueMedicineAmount(indCondInfo, itemIdx, "1次膜");
          unit = res.get("unit");
        }
        break;
      case 8:
        // 2次膜
        indItem.setItemName("2次膜");
        // mod #10739 コンバート施設で指示受け(治療単位)が表示されない 関 start
        indItem.setItemCd(Optional.ofNullable(indCondInfo.get(itemIdx))
          .map(node -> node.get(valKey))
          .filter(node -> !node.isNull())
          .map(JsonNode::asInt)
          .orElse(null));
        // mod #10739 コンバート施設で指示受け(治療単位)が表示されない 関 end
        if (hasValue) {
          indValue = getValueName1(indCondInfo, itemIdx, "2次膜");
          Map<String, String> res = getValueMedicineAmount(indCondInfo, itemIdx, "2次膜");
          unit = res.get("unit");
        }
        break;
      case 9:
        // 穿刺針(A針)
        indItem.setItemName("穿刺針(A針)");
        // mod #10739 コンバート施設で指示受け(治療単位)が表示されない 関 start
        indItem.setItemCd(Optional.ofNullable(indCondInfo.get(itemIdx))
          .map(node -> node.get(valKey))
          .filter(node -> !node.isNull())
          .map(JsonNode::asInt)
          .orElse(null));
        // mod #10739 コンバート施設で指示受け(治療単位)が表示されない 関 end
        if (hasValue) {
          indValue = getValueName1(indCondInfo, itemIdx, "穿刺針(A針)");
          Map<String, String> res = getValueMedicineAmount(indCondInfo, itemIdx, "穿刺針(A針)");
          unit = res.get("unit");
        }
        break;
      case 10:
        // 穿刺針(V針)
        indItem.setItemName("穿刺針(V針)");
        // mod #10739 コンバート施設で指示受け(治療単位)が表示されない 関 start
        indItem.setItemCd(Optional.ofNullable(indCondInfo.get(itemIdx))
          .map(node -> node.get(valKey))
          .filter(node -> !node.isNull())
          .map(JsonNode::asInt)
          .orElse(null));
        // mod #10739 コンバート施設で指示受け(治療単位)が表示されない 関 end
        if (hasValue) {
          indValue = getValueName1(indCondInfo, itemIdx, "穿刺針(V針)");
          Map<String, String> res = getValueMedicineAmount(indCondInfo, itemIdx, "穿刺針(V針)");
          unit = res.get("unit");
        }
        break;
      case 11:
        // 穿刺針(SN)
        indItem.setItemName("穿刺針(SN)");
        // mod #10739 コンバート施設で指示受け(治療単位)が表示されない 関 start
        indItem.setItemCd(Optional.ofNullable(indCondInfo.get(itemIdx))
          .map(node -> node.get(valKey))
          .filter(node -> !node.isNull())
          .map(JsonNode::asInt)
          .orElse(null));
        // mod #10739 コンバート施設で指示受け(治療単位)が表示されない 関 end
        if (hasValue) {
          indValue = getValueName1(indCondInfo, itemIdx, "穿刺針(SN)");
          Map<String, String> res = getValueMedicineAmount(indCondInfo, itemIdx, "穿刺針(SN)");
          unit = res.get("unit");
        }
        break;
      case 12:
        // シングルニードル使用
        indItem.setItemName("シングルニードル使用");
        if (hasValue) {
          indValue = getStrIsEnable(indCondInfo, itemIdx, "シングルニードル使用");
        }
        break;
      case 13:
        // 血液回路
        indItem.setItemName("血液回路");
        // mod #10739 コンバート施設で指示受け(治療単位)が表示されない 関 start
        indItem.setItemCd(Optional.ofNullable(indCondInfo.get(itemIdx))
          .map(node -> node.get(valKey))
          .filter(node -> !node.isNull())
          .map(JsonNode::asInt)
          .orElse(null));
        // mod #10739 コンバート施設で指示受け(治療単位)が表示されない 関 end
        if (hasValue) {
          indValue = getValueName1(indCondInfo, itemIdx, "血液回路");
          Map<String, String> res = getValueMedicineAmount(indCondInfo, itemIdx, "血液回路");
          unit = res.get("unit");
        }
        break;
      case 14:
        // 血流量
        indItem.setItemName("血流量");
        if (hasValue) {
          try {
            indValue = indCondInfo.get(itemIdx).get(valKey).asText();
            unit = "mL/min";
          } catch (Exception e) {
            String errMsg = String.format("治療条件：%sの設定値取得に失敗しました.[%s]", "血流量", e.getMessage());
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage(errMsg);
            logService.log(LogLevel.INFO, eventLogMessage,null, LoggingConstant.SERVICE_NAME.FNSI, null);
          }
        }
        break;
      case 15:
        // 透析液
        indItem.setItemName("透析液");
        if(indCondInfo.has(itemIdx)){
          JsonNode medicineTypeNode = indCondInfo.get(itemIdx).get("medicine_type");
          Integer medicine_type = (medicineTypeNode != null && !medicineTypeNode.isNull())
            ? medicineTypeNode.asInt()
            : null;
          indItem.setItemType(medicine_type);
          indItem.setItemCd(Optional.ofNullable(indCondInfo.get(itemIdx))
            .map(node -> node.get(valKey))
            .filter(node -> !node.isNull())
            .map(JsonNode::asInt)
            .orElse(null));
        }
        if (hasValue) {
          indValue = getValueName1(indCondInfo, itemIdx, "透析液");
          Map<String, String> res = getValueMedicineAmount(indCondInfo, itemIdx, "透析液");
          unit = res.get("unit");
        }
        break;
      case 16:
        // 透析液流量
        indItem.setItemName("透析液流量");
        if (hasValue) {
          try {
            indValue = indCondInfo.get(itemIdx).get(valKey).asText();
            unit = "mL/min";
          } catch (Exception e) {
            String errMsg = String.format("治療条件：%sの設定値取得に失敗しました.[%s]", "透析液流量", e.getMessage());
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage(errMsg);
            logService.log(LogLevel.INFO, eventLogMessage,null, LoggingConstant.SERVICE_NAME.FNSI, null);
          }
        }
        break;
      case 17:
        // 透析液使用数
        indItem.setItemName("透析液使用数");
        if (hasValue) {
          Map<String, String> res = getValueMedicineAmount(indCondInfo, itemIdx, "透析液使用数");
          indValue = res.get("value");
          unit = res.get("unit");
        }
        break;
      case 18:
        // 透析液温度
        indItem.setItemName("透析液温度");
        if (hasValue) {
          try {
            indValue = indCondInfo.get(itemIdx).get(valKey).asText();
            unit = "℃";
          } catch (Exception e) {
            String errMsg = String.format("治療条件：%sの設定値取得に失敗しました.[%s]", "透析液温度", e.getMessage());
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage(errMsg);
            logService.log(LogLevel.INFO, eventLogMessage,null, LoggingConstant.SERVICE_NAME.FNSI, null);
          }
        }
        break;
      case 19:
        // 補液
        indItem.setItemName("補液");
        if(indCondInfo.has(itemIdx)){
          JsonNode medicineTypeNode = indCondInfo.get(itemIdx).get("medicine_type");
          Integer medicine_type = (medicineTypeNode != null && !medicineTypeNode.isNull())
            ? medicineTypeNode.asInt()
            : null;
          indItem.setItemType(medicine_type);
          indItem.setItemCd(Optional.ofNullable(indCondInfo.get(itemIdx).get(valKey))
          .filter(node -> !node.isNull())
          .map(JsonNode::asInt)
          .orElse(null));
        }
        if (hasValue) {
          indValue = getValueName1(indCondInfo, itemIdx, "補液");
          Map<String, String> res = getValueMedicineAmount(indCondInfo, itemIdx, "補液");
          unit = res.get("unit");
        }
        break;
      case 20:
        // 補液量
        indItem.setItemName("補液量");
        if (hasValue) {
          try {
            indValue = indCondInfo.get(itemIdx).get(valKey).asText();
            unit = "L";
          } catch (Exception e) {
            String errMsg = String.format("治療条件：%sの設定値取得に失敗しました.[%s]", "補液量", e.getMessage());
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage(errMsg);
            logService.log(LogLevel.INFO, eventLogMessage,null, LoggingConstant.SERVICE_NAME.FNSI, null);
          }
        }
        break;
      case 21:
        // 補液選択
        indItem.setItemName("補液選択");
        // add #9973 Resolve null exception for key 20240117 ztc start
        if (hasValue) {
        // add #9973 Resolve null exception for key 20240117 ztc end
          try {
            String v = indCondInfo.get(itemIdx).get(valKey).asText();
            if (Objects.equals(v, FlagType.FLAG_ON)) {
              indValue = "前補液";
            } else if (Objects.equals(v, FlagType.FLAG_OFF)) {
              indValue = "後補液";
            }
          } catch (Exception e) {
            String errMsg = String.format("治療条件：%sの設定値取得に失敗しました.[%s]", "補液選択", e.getMessage());
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage(errMsg);
            logService.log(LogLevel.INFO, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
          }
        }
        break;
      case 22:
        // 補液使用数
        indItem.setItemName("補液使用数");
        if (hasValue) {
          Map<String, String> res = getValueMedicineAmount(indCondInfo, itemIdx, "補液使用数");
          indValue = res.get("value");
          unit = res.get("unit");
        }
        break;
      case 23:
        // 補液温度
        indItem.setItemName("補液温度");
        if (hasValue) {
          try {
            indValue = indCondInfo.get(itemIdx).get(valKey).asText();
            unit = "℃";
          } catch (Exception e) {
            String errMsg = String.format("治療条件：%sの設定値取得に失敗しました.[%s]", "補液温度", e.getMessage());
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage(errMsg);
            logService.log(LogLevel.INFO, eventLogMessage,null, LoggingConstant.SERVICE_NAME.FNSI, null);
          }
        }
        break;
      case 24:
        // 補液速度
        indItem.setItemName("補液速度");
        if (hasValue) {
          try {
            indValue = indCondInfo.get(itemIdx).get(valKey).asText();
            unit = "L/h";
          } catch (Exception e) {
            String errMsg = String.format("治療条件：%sの設定値取得に失敗しました.[%s]", "補液速度", e.getMessage());
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage(errMsg);
            logService.log(LogLevel.INFO, eventLogMessage,null, LoggingConstant.SERVICE_NAME.FNSI, null);
          }
        }
        break;
      case 25:
        // 抗凝固剤
        indItem.setItemName("抗凝固剤");
        if(indCondInfo.has(itemIdx)){
          JsonNode medicineTypeNode = indCondInfo.get(itemIdx).get("medicine_type");
          Integer medicine_type = (medicineTypeNode != null && !medicineTypeNode.isNull())
            ? medicineTypeNode.asInt()
            : null;
          indItem.setItemType(medicine_type);
          indItem.setItemCd(Optional.ofNullable(indCondInfo.get(itemIdx).get(valKey))
          .filter(node -> !node.isNull())
          .map(JsonNode::asInt)
          .orElse(null));
        }
        if (hasValue) {
          indValue = getValueName1(indCondInfo, itemIdx, "抗凝固剤");
          Map<String, String> res = getValueMedicineAmount(indCondInfo, itemIdx, "抗凝固剤");
          unit = res.get("unit");
        }
        break;
      case 26:
        // 抗凝固剤ワンショット量
        indItem.setItemName("抗凝固剤ワンショット量");
        if (hasValue) {
          Map<String, String> res = getValueMedicineAmount(indCondInfo, itemIdx, "抗凝固剤ワンショット量");
          indValue = res.get("value");
          unit = res.get("unit");
        }
        break;
      case 27:
        // 抗凝固剤持続速度
        indItem.setItemName("抗凝固剤持続速度");
        if (hasValue) {
          Map<String, String> res = getValueMedicineAmount(indCondInfo, itemIdx, "抗凝固剤持続速度");
          indValue = res.get("value");
          unit = res.get("unit");
        }
        break;
      case 28:
        // 抗凝固剤持続総量
        indItem.setItemName("抗凝固剤持続総量");
        if (hasValue) {
          Map<String, String> res = getValueMedicineAmount(indCondInfo, itemIdx, "抗凝固剤持続総量");
          indValue = res.get("value");
          unit = res.get("unit");
        }
        break;
      case 29:
        // IP使用選択
        indItem.setItemName("IP使用選択");
        if (hasValue) {
          indValue = getStrIsEnable(indCondInfo, itemIdx, "IP使用選択");
        }
        break;
      case 30:
        // IPスタート
        indItem.setItemName("IPスタート");
        // add #9973 Resolve null exception for key 20240117 ztc start
        if (hasValue) {
        // add #9973 Resolve null exception for key 20240117 ztc end
          try {
            String v = indCondInfo.get(itemIdx).get(valKey).asText();
            if (Objects.equals(v, FlagType.FLAG_ON)) {
              indValue = "自動";
            } else if (Objects.equals(v, FlagType.FLAG_OFF)) {
              indValue = "手動";
            }
          } catch (Exception e) {
            String errMsg = String.format("治療条件：%sの設定値取得に失敗しました.[%s]", "IPスタート", e.getMessage());
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage(errMsg);
            logService.log(LogLevel.INFO, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
          }
        }
        break;
      case 31:
        // IPワンショット量
        indItem.setItemName("IPワンショット量");
        if (hasValue) {
          try {
            indValue = indCondInfo.get(itemIdx).get(valKey).asText();
            unit = "mL";
          } catch (Exception e) {
            String errMsg = String.format("治療条件：%sの設定値取得に失敗しました.[%s]", "IPワンショット量", e.getMessage());
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage(errMsg);
            logService.log(LogLevel.INFO, eventLogMessage,null, LoggingConstant.SERVICE_NAME.FNSI, null);
          }
        }
        break;
      case 32:
        // IP速度
        indItem.setItemName("IP速度");
        if (hasValue) {
          try {
            indValue = indCondInfo.get(itemIdx).get(valKey).asText();
            unit = "mL/h";
          } catch (Exception e) {
            String errMsg = String.format("治療条件：%sの設定値取得に失敗しました.[%s]", "IP速度", e.getMessage());
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage(errMsg);
            logService.log(LogLevel.INFO, eventLogMessage,null, LoggingConstant.SERVICE_NAME.FNSI, null);
          }
        }
        break;
      case 33:
        // IP速度最大値
        indItem.setItemName("IP速度最大値");
        if (hasValue) {
          try {
            indValue = indCondInfo.get(itemIdx).get(valKey).asText();
            unit = "mL/h";
          } catch (Exception e) {
            String errMsg = String.format("治療条件：%sの設定値取得に失敗しました.[%s]", "IP速度最大値", e.getMessage());
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage(errMsg);
            logService.log(LogLevel.INFO, eventLogMessage,null, LoggingConstant.SERVICE_NAME.FNSI, null);
          }
        }
        break;
      case 34:
        // IPワンショットスタート
        indItem.setItemName("IPワンショットスタート");
        if (hasValue) {
          try {
            String v = indCondInfo.get(itemIdx).get(valKey).asText();
            if (Objects.equals(v, FlagType.FLAG_ON)) {
              indValue = "自動";
            } else if (Objects.equals(v, FlagType.FLAG_OFF)) {
              indValue = "手動";
            }
          } catch (Exception e) {
            String errMsg = String.format("治療条件：%sの設定値取得に失敗しました.[%s]", "IPワンショットスタート", e.getMessage());
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage(errMsg);
            logService.log(LogLevel.INFO, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
          }
        }
        break;
      case 35:
        // IP電源自動切り
        indItem.setItemName("IP電源自動切り");
        // add #9973 Resolve null exception for key 20240117 ztc start
        if (hasValue) {
        // add #9973 Resolve null exception for key 20240117 ztc end
          try {
            String v = indCondInfo.get(itemIdx).get(valKey).asText();
            if (Objects.equals(v, FlagType.FLAG_ON)) {
              indValue = "入";
            } else if (Objects.equals(v, FlagType.FLAG_OFF)) {
              indValue = "切";
            }
          } catch (Exception e) {
            String errMsg = String.format("治療条件：%sの設定値取得に失敗しました.[%s]", "IP電源自動切り", e.getMessage());
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage(errMsg);
            logService.log(LogLevel.INFO, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
          }
        }
        break;
      case 36:
        // IP電源自動切り時間
        indItem.setItemName("IP電源自動切り時間");
        if (hasValue) {
          try {
            indValue = indCondInfo.get(itemIdx).get(valKey).asText();
            unit = "分";
          } catch (Exception e) {
            String errMsg = String.format("治療条件：%sの設定値取得に失敗しました.[%s]", "IP電源自動切り時間", e.getMessage());
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage(errMsg);
            logService.log(LogLevel.INFO, eventLogMessage,null, LoggingConstant.SERVICE_NAME.FNSI, null);
          }
        }
        break;
      case 37:
        // IP電源OKモニタ切り
        indItem.setItemName("IP電源OKモニタ切り");
        // add #9973 Resolve null exception for key 20240117 ztc start
        if (hasValue) {
        // add #9973 Resolve null exception for key 20240117 ztc end
          try {
            String v = indCondInfo.get(itemIdx).get(valKey).asText();
            if (Objects.equals(v, FlagType.FLAG_ON)) {
              indValue = "入";
            } else if (Objects.equals(v, FlagType.FLAG_OFF)) {
              indValue = "切";
            }
          } catch (Exception e) {
            String errMsg = String.format("治療条件：%sの設定値取得に失敗しました.[%s]", "IP電源OKモニタ切り", e.getMessage());
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage(errMsg);
            logService.log(LogLevel.INFO, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
          }
        }
        break;
      case 38:
        // IP電源OKモニタ切り時間
        indItem.setItemName("IP電源OKモニタ切り時間");
        if (hasValue) {
          try {
            indValue = indCondInfo.get(itemIdx).get(valKey).asText();
            unit = "分";
          } catch (Exception e) {
            String errMsg = String.format("治療条件：%sの設定値取得に失敗しました.[%s]", "IP電源OKモニタ切り時間", e.getMessage());
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage(errMsg);
            logService.log(LogLevel.INFO, eventLogMessage,null, LoggingConstant.SERVICE_NAME.FNSI, null);
          }
        }
        break;

      default:
        break;
    }

    ItemInfo.ItemData itemData = new ItemInfo.ItemData();
    if (!hasIdx) {
      itemData.setIsDisable(true);
    }else {
      itemData.setInstructor(indUser);
      itemData.setUpdater(updUser);
    }
    ItemInfo.ValueData valueData = new ItemInfo.ValueData();
    valueData.setDispVal(getPrefixStr(indValue).get("value").isEmpty() ? NO_DATA : getPrefixStr(indValue).get("value"));
    valueData.setPrefix(getPrefixStr(indValue).get("prefix").isEmpty() ? null : getPrefixStr(indValue).get("prefix"));
    valueData.setUnit(unit);
    itemData.setValue(valueData);
    //add #9507 一括指示受けに時間がかかる zrx start
    if(Objects.equals("0", ordMain.getRstDialysisState())) {
      Integer[] itemNoArray = {
        1,3,4,12,14,16,17,18,20,21,22,23,24,
        26,27,28,29,30,31,32,33,34,35,36,37,38
      };
      if (!Arrays.asList(itemNoArray).contains(idx)) {
        valueData.setDispVal(null);
      }
      valueData.setUnit(null);
    }
    //add #9507 一括指示受けに時間がかかる zrx end
    indItem.setData(itemData);
    itemInfo.setItemInfo(indItem);

    return itemInfo;
  }
  //mod #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi end

  //mod #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi start
  /**
   * get prefix
   * @param value original value
   */
  private Map<String, String> getPrefixStr(String value) {
    Map<String, String> res = new HashMap<>();
    final String[] prefixes = {
      "【禁忌】",
      "【ｱﾚﾙｷﾞｰ】",
      "【禁忌・ｱﾚﾙｷﾞｰ】",
      "【分類不一致】",
      "【期限切れ】",
      "【削除済み】",
      "【削除済み含む】"
    };
    StringBuilder prefixBuilder = new StringBuilder();
    for (String prefix : prefixes) {
      if (value.contains(prefix)) {
        prefixBuilder.append(prefix);
      }
    }
    res.put("prefix", prefixBuilder.toString());

    String regexPattern = String.join("|", Arrays.stream(prefixes).map(Pattern::quote).toArray(String[]::new));
    value = value.replaceAll(regexPattern, "");
    res.put("value", value);

    return res;
  }
  //mod #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi end

  //mod #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi start
  /**
   * 3--1 DWの取得
   * @param ordMain 指示
   * @return
   */
  private ItemInfo buildDwInfo(JsonNode indCondInfo, OrdMain ordMain) {
    ItemInfo indItemInfo = new ItemInfo();
    ItemInfo.Item itemInfo = new ItemInfo.Item();
    indItemInfo.setItemInfo(itemInfo);
    itemInfo.setItemName("DW");
    itemInfo.setItemNo(-1);
    ItemInfo.ItemData itemData = new ItemInfo.ItemData();
    String indUser = "", updUser = "";
    JsonNode indDwUserInfo;
    try {
      indDwUserInfo = mapper.readTree(ordMain.getIndDwUserInfo());
    } catch (Exception e) {
      indDwUserInfo = null;
    }

    //mod #9507 一括指示受けに時間がかかる zrx start
    BigDecimal patUniquePhysicalInfoDw = null;
    if(indDwUserInfo != null) {
      if (indDwUserInfo.has(IND_USER_LAST_NAME) && indDwUserInfo.has(IND_USER_FIRST_NAME)) {
        indUser = indDwUserInfo.get(IND_USER_LAST_NAME).asText("") + " " + indDwUserInfo.get(IND_USER_FIRST_NAME).asText("");
      }
      if (indDwUserInfo.has(UPD_USER_LAST_NAME) && indDwUserInfo.has(UPD_USER_FIRST_NAME)) {
        updUser = indDwUserInfo.get(UPD_USER_LAST_NAME).asText("") + " " + indDwUserInfo.get(UPD_USER_FIRST_NAME).asText("");
      }
    } else {//rst_dialysis_state 0：条件送信前
      PatUniquePhysicalInfo patUniquePhysicalInfo =
        patUniqueDao.selectPhysicalInfoByTreatDate(ordMain.getPatId(), ordMain.getFacilityCd(), ordMain.getTreatDate());
      if(patUniquePhysicalInfo != null) {
        patUniquePhysicalInfoDw = new BigDecimal(patUniquePhysicalInfo.getDw());
        if(patUniquePhysicalInfo.getChanger_cd() != null) {
          updUser = mstPersonalUserDao.selectUserNameById(patUniquePhysicalInfo.getChanger_cd().longValue());
        }
        if(patUniquePhysicalInfo.getIndicator_cd() != null) {
          indUser= mstPersonalUserDao.selectUserNameById(patUniquePhysicalInfo.getIndicator_cd().longValue());
        }
      }
    }
    //mod #9507 一括指示受けに時間がかかる zrx end
    itemData.setInstructor(indUser);
    itemData.setUpdater(updUser);
    ItemInfo.ValueData valueData = new ItemInfo.ValueData();

    if (!indCondInfo.has("3")) {
      valueData.setPrefix(null);
      valueData.setUnit(null);
      valueData.setDispVal(NO_DATA);
      itemData.setValue(valueData);
      itemData.setIsDisable(true);
      itemInfo.setData(itemData);
      return indItemInfo;
    }

    BigDecimal dw = ordMain.getIndDw();
    valueData.setPrefix(null);
    if (Objects.isNull(dw)) {
      valueData.setUnit(null);
      //mod #9507 一括指示受けに時間がかかる zrx start
      if(Objects.isNull(patUniquePhysicalInfoDw)) {
        valueData.setDispVal(NO_DATA);
      } else {
        valueData.setDispVal(patUniquePhysicalInfoDw.toString());
      }
      //mod #9507 一括指示受けに時間がかかる zrx end
    } else {
      valueData.setUnit("kg");
      valueData.setDispVal(dw.toString());
    }
    itemData.setValue(valueData);
    itemInfo.setData(itemData);

    return indItemInfo;
  }
  //mod #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi end

  /**
   * JSONから value_name_1 の値を取得
   * @param indCondInfo
   * @param itemIdx
   * @param paramName
   * @return
   */
  private String getValueName1(JsonNode indCondInfo, String itemIdx, String paramName) {
    String indValue = NO_DATA;
    try {
      indValue = indCondInfo.get(itemIdx).get("value_name_1").asText();
    } catch (Exception e) {
      String errMsg = String.format("治療条件：%sの設定値取得に失敗しました.[%s]", paramName, e.getMessage());
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(errMsg);
      logService.log(LogLevel.INFO, eventLogMessage,null, LoggingConstant.SERVICE_NAME.FNSI, null);
    }
    return indValue;
  }

  //mod #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi start
  /**
   * JSONから薬剤の value + unit の値を取得（小数点桁数そろえ）
   * @param indCondInfo
   * @param itemIdx
   * @param paramName
   */
  private Map<String, String> getValueMedicineAmount(JsonNode indCondInfo, String itemIdx, String paramName) {
    Map<String, String> res = new HashMap<>();
    String indValue = NO_DATA;
    try {
      indValue = indCondInfo.get(itemIdx).get("value").asText();
      String unit = null;
      if (indCondInfo.get(itemIdx).has("unit") && !Objects.isNull(indCondInfo.get(itemIdx).get("unit"))
        && !Objects.equals(indCondInfo.get(itemIdx).get("unit").asText(), "null")) {
        unit = indCondInfo.get(itemIdx).get("unit").asText();
      }
      res.put("value", indValue);
      res.put("unit", unit);
    } catch (Exception e) {
      String errMsg = String.format("治療条件：%sの設定値取得に失敗しました.[%s]", paramName, e.getMessage());
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(errMsg);
      logService.log(LogLevel.INFO, eventLogMessage,null, LoggingConstant.SERVICE_NAME.FNSI, null);
    }
    return res;
  }
  //mod #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi end

  /**
   * JSONから 仕様有無を取得
   * @param indCondInfo
   * @param itemIdx
   * @param paramName
   * @return
   */
  private String getStrIsEnable(JsonNode indCondInfo, String itemIdx, String paramName) {
    String indValue = NO_DATA;
    try {
      String v = indCondInfo.get(itemIdx).get("value").asText();
      if (Objects.equals(v, FlagType.FLAG_ON)) {
        indValue = "使用する";
      } else if (Objects.equals(v, FlagType.FLAG_OFF)) {
        indValue = "使用しない";
      }
    } catch (Exception e) {
      String errMsg = String.format("治療条件：%sの設定値取得に失敗しました.[%s]", paramName, e.getMessage());
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(errMsg);
      logService.log(LogLevel.INFO, eventLogMessage,null, LoggingConstant.SERVICE_NAME.FNSI, null);
    }
    return indValue;
  }

  //mod #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi start
  /**
   * 5-1～5-n 投与薬剤の取得
   * @param indMediInfo 指示条件
   * @param idx インデックス
   * @return
   */
  private ItemInfo buildMediInfoItem(JsonNode indMediInfo, int idx) {
    String indValue = NO_DATA, indUser = "", updUser = "";
    JsonNode node = indMediInfo.get(idx);
    if (node.has(IND_USER_LAST_NAME) && node.has(IND_USER_FIRST_NAME)) {
      indUser = node.get(IND_USER_LAST_NAME).asText("") + " " + node.get(IND_USER_FIRST_NAME).asText("");
    }
    if (node.has(UPD_USER_LAST_NAME) && node.has(UPD_USER_FIRST_NAME)) {
      updUser = node.get(UPD_USER_LAST_NAME).asText("") + " " + node.get(UPD_USER_FIRST_NAME).asText("");
    }
    String indName = NO_DATA, nameKey = "name";
    if (node.has(nameKey) && !Objects.isNull(node.get(nameKey))) {
      // 値あり
      indName = node.get(nameKey).asText();
    }
    String unitValue = null, unitKey = "unit";
    if (node.has(unitKey) && !node.get(unitKey).isNull()) {
      // 値あり
      unitValue = node.get(unitKey).asText();
    }

    if (node.has("amount") && !node.get("amount").isNull()) {
      try {
        indValue = node.get("amount").asText();
      } catch (Exception e) {
        String errMsg = String.format("調製薬剤：%d項目目の設定値取得に失敗しました.[%s]", idx + 1, e.getMessage());
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(errMsg);
        logService.log(LogLevel.INFO, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
      }
    }

    ItemInfo itemInfoRes = new ItemInfo();
    ItemInfo.Item itemInfo = new ItemInfo.Item();
    itemInfo.setItemName(getPrefixStr(indName).get("value").isEmpty() ? null : getPrefixStr(indName).get("value"));
    itemInfo.setItemNo(node.has("no") ? node.get("no").asInt() : idx + 1);
    itemInfo.setItemCd(node.has("cd") ? node.get("cd").asInt() : null);
    itemInfo.setItemType(node.has("medicine_type") ? node.get("medicine_type").asInt() : null);
    ItemInfo.ItemData itemData = new ItemInfo.ItemData();
    itemData.setInstructor(indUser);
    itemData.setUpdater(updUser);
    ItemInfo.ValueData valueData = new ItemInfo.ValueData();
    valueData.setDispVal(getPrefixStr(indValue).get("value").isEmpty() ? null : getPrefixStr(indValue).get("value"));
    valueData.setPrefix(getPrefixStr(indName).get("prefix").isEmpty() ? null : getPrefixStr(indName).get("prefix"));
    valueData.setUnit(unitValue);
    itemData.setValue(valueData);
    itemInfo.setData(itemData);
    itemInfoRes.setItemInfo(itemInfo);

    return itemInfoRes;
  }
  //mod #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi end

  //mod #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi start
  /**
   * 6-1～6-n 医療材料の取得
   * @param indEquipInfo 指示条件
   * @param idx インデックス
   * @return
   */
  private ItemInfo buildEquipInfoItem(JsonNode indEquipInfo, int idx) {
    String indValue = NO_DATA, indUser = "", updUser = "";
    JsonNode node = indEquipInfo.get(idx);
    if (node.has(IND_USER_LAST_NAME) && node.has(IND_USER_FIRST_NAME)) {
      indUser = node.get(IND_USER_LAST_NAME).asText("") + " " + node.get(IND_USER_FIRST_NAME).asText("");
    }
    if (node.has(UPD_USER_LAST_NAME) && node.has(UPD_USER_FIRST_NAME)) {
      updUser = node.get(UPD_USER_LAST_NAME).asText("") + " " + node.get(UPD_USER_FIRST_NAME).asText("");
    }

    String indName = NO_DATA, nameKey = "name";
    if (node.has(nameKey) && !Objects.isNull(node.get(nameKey))) {
      // 値あり
      indName = node.get(nameKey).asText();
    }
    String unitValue = null, unitKey = "unit";
    if (node.has(unitKey) && !node.get(unitKey).isNull()) {
      // 値あり
      unitValue = node.get(unitKey).asText();
    }
    if (node.has("amount") && !node.get("amount").isNull()) {
      try {
        indValue = node.get("amount").asText();
      } catch (Exception e) {
        String errMsg = String.format("医療材料：%d項目目の設定値数量取得に失敗しました.[%s]", idx + 1, e.getMessage());
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(errMsg);
        logService.log(LogLevel.INFO, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
      }
    }

    ItemInfo itemInfoRes = new ItemInfo();
    ItemInfo.Item itemInfo = new ItemInfo.Item();
    itemInfo.setItemNo(null);
    itemInfo.setItemName(getPrefixStr(indName).get("value").isEmpty() ? null : getPrefixStr(indName).get("value"));
    itemInfo.setItemCd(node.has("cd") ? node.get("cd").asInt() : null);
    itemInfo.setItemType(node.has("equip_type") ? node.get("equip_type").asInt() : null);
    ItemInfo.ItemData itemData = new ItemInfo.ItemData();
    itemData.setInstructor(indUser);
    itemData.setUpdater(updUser);
    ItemInfo.ValueData valueData = new ItemInfo.ValueData();
    valueData.setDispVal(getPrefixStr(indValue).get("value").isEmpty() ? null : getPrefixStr(indValue).get("value"));
    valueData.setPrefix(getPrefixStr(indName).get("prefix").isEmpty() ? null : getPrefixStr(indName).get("prefix"));
    valueData.setUnit(unitValue);
    itemData.setValue(valueData);
    itemInfo.setData(itemData);
    itemInfoRes.setItemInfo(itemInfo);

    return itemInfoRes;
  }
  //mod #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi end

  //mod #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi start
  /**
   * 7-1～7-n 指示コメントの取得
   * @param indIndCommentInfo 指示条件
   * @param idx インデックス
   * @return
   */
  private ItemInfo buildIndIndCommentInfoItem(JsonNode indIndCommentInfo, int idx) {
    String indValue = NO_DATA, indUser = "", updUser = "";
    JsonNode node = indIndCommentInfo.get(idx);

    if (node.has(IND_USER_LAST_NAME) && node.has(IND_USER_FIRST_NAME)) {
      indUser = node.get(IND_USER_LAST_NAME).asText("") + " " + node.get(IND_USER_FIRST_NAME).asText("");
    }
    if (node.has(UPD_USER_LAST_NAME) && node.has(UPD_USER_FIRST_NAME)) {
      updUser = node.get(UPD_USER_LAST_NAME).asText("") + " " + node.get(UPD_USER_FIRST_NAME).asText("");
    }
    // add #9973 Resolve null exception for key 20240117 ztc start
    if (node.has("content") && !node.get("content").isNull()) {
      // add #9973 Resolve null exception for key 20240117 ztc end
      try {
        indValue = node.get("content").asText();
      } catch (Exception e) {
        String errMsg = String.format("コメント：%d項目目の設定値数量取得に失敗しました.[%s]", idx + 1, e.getMessage());
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(errMsg);
        logService.log(LogLevel.INFO, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
      }
    }

    ItemInfo itemInfoRes = new ItemInfo();
    ItemInfo.Item itemInfo = new ItemInfo.Item();
    itemInfo.setItemName("コメント" + (node.has("no") ? node.get("no").asInt() : idx + 1));
    itemInfo.setItemNo(node.has("no") ? node.get("no").asInt() : idx + 1);
    itemInfo.setItemCd(null);
    itemInfo.setItemType(null);
    ItemInfo.ItemData itemData = new ItemInfo.ItemData();
    itemData.setInstructor(indUser);
    itemData.setUpdater(updUser);
    ItemInfo.ValueData valueData = new ItemInfo.ValueData();
    valueData.setDispVal(indValue);
    valueData.setPrefix(null);
    valueData.setUnit(null);
    itemData.setValue(valueData);
    itemInfo.setData(itemData);
    itemInfoRes.setItemInfo(itemInfo);

    return itemInfoRes;
  }
  //mod #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi end

  //add 9324 治療情報を異なる状態で変更した後のord_checklistの再編成共通方法 gjn start

  /**
   * ord _ noからord _ checklistのデータを取得する
   *
   * @param orderNo
   * @return
   */
  public List<OrdChecklist> getOrdCheckListByOrdNO(Long orderNo) {
    List<OrdChecklist> ordChecklists = ordChecklistDao.selectByOrdNo(SelectOptions.get(), orderNo);
    return ordChecklists;
  }

  /**
   * ord _ checklistからMst _ checklistを逆プッシュ
   *
   * @param ordChecklistList
   * @return
   */
  public Map<String, JsonNode> makeMstChecklistByOrdChecklist(List<OrdChecklist> ordChecklistList) {
    Map<String, JsonNode> JsonNodeMap = new HashMap<>();
    Long checklistCd = null;
    try {
      JSONArray jsonArrayMst = new JSONArray();
      String dialysis_prog_name = "";
      ObjectMapper map = new ObjectMapper();
      Map<Object, List<OrdChecklist>> groupedByListCd = ordChecklistList.stream().collect(Collectors.groupingBy(OrdChecklist::getListCd));

      for (Map.Entry<Object, List<OrdChecklist>> entry : groupedByListCd.entrySet()) {
        String checklistSettingStr = "";
        short key = (short) entry.getKey();
        List<OrdChecklist> value = entry.getValue();
        //item _ noでソート
        value = value.stream().sorted(Comparator.comparing(OrdChecklist::getFuncClass)).collect(Collectors.toList());
        ChecklistSettings checklistSettings = new ChecklistSettings();
        //list_cd
        checklistSettings.setList_cd(key);
        JSONArray jsonArray = new JSONArray();
        //キャッシュの照合、次のlist _ cdをトラバースするときに初期化されます
        List<FuncList> funcLists = new ArrayList<>();
        for (OrdChecklist ordChecklist : value) {
          //dialysis_prog_cd -> rst_class
          short rstClass;
          switch (ordChecklist.getRstClass()) {
            case 0:
            case 7:
              rstClass = 0;
              dialysis_prog_name = "透析開始前";
              break;
            case 1:
            case 8:
              rstClass = 1;
              dialysis_prog_name = "透析中";
              break;
            case 2:
            case 9:
              rstClass = 2;
              dialysis_prog_name = "透析終了後";
              break;
            default:
              rstClass = -1;
          }
          checklistSettings.setDialysis_prog_cd(rstClass);
          FuncList funcList = new FuncList();
          OrdChecklistRegCheckInfo ordChecklistRegCheckInfo = ordChecklist.getRstChecklistInfo();
          if (checklistCd == null) {
            checklistCd = ordChecklistRegCheckInfo.getChecklistCd();
          }

          if (ordChecklistRegCheckInfo.getClassCd() == null) {
            funcList.setClass_cd(StringUtils.isEmpty(ordChecklistRegCheckInfo.getClassCd()) ? null : ordChecklistRegCheckInfo.getClassCd());
            funcList.setList_name(StringUtils.isEmpty(ordChecklistRegCheckInfo.getName()) ? null : ordChecklistRegCheckInfo.getName());
            funcList.setFunc_class(StringUtils.isEmpty(ordChecklist.getFuncClass()) ? null : ordChecklist.getFuncClass());
            funcList.setItem_number(StringUtils.isEmpty(ordChecklistRegCheckInfo.getItemNumber()) ? null : ordChecklistRegCheckInfo.getItemNumber());
          } else {
            //TODO 治療条件
            if (ordChecklist.getFuncClass() == 1) {
              //5.6.7.8 ダイアライザ・吸着カラム・1次膜・2次膜
              if (ordChecklistRegCheckInfo.getClassCd() == 5 || ordChecklistRegCheckInfo.getClassCd() == 6
                || ordChecklistRegCheckInfo.getClassCd() == 7 || ordChecklistRegCheckInfo.getClassCd() == 8
              ) {
                //funcListsに入れたデータが今回funcListに入れたデータと同じかどうかをフィルタリングし、class _ cdはitem _ cdと同じで、同じものがあればスキップし、逆に入れて作成する（5.6.7.8はすべてchass _ cd=5として入れるため）
                funcLists = funcLists.stream().filter(f -> (f.getClass_cd() != null)).distinct().collect(Collectors.toList()); //Class _ cd()=nullのデータをフィルタして、比較時にエラーが発生しないようにします
                List<FuncList> funcListsCheck = funcLists.stream().filter(f -> (f.getClass_cd() == 5 && f.getItem_number() == ordChecklistRegCheckInfo.getItemNumber())).distinct().collect(Collectors.toList());
                if (funcListsCheck == null || funcListsCheck.size() < 1) { //ClassCd=5のデータが作成されていない場合（list _ cdごとに1回作成）
                  funcList.setClass_cd(5);
                  funcList.setList_name("ダイアライザ・吸着カラム・1次膜・2次膜");
                  funcList.setFunc_class(StringUtils.isEmpty(ordChecklist.getFuncClass()) ? null : ordChecklist.getFuncClass());
                  funcList.setItem_number(StringUtils.isEmpty(ordChecklistRegCheckInfo.getItemNumber()) ? null : ordChecklistRegCheckInfo.getItemNumber());
                }
                //9.10.11 穿刺针（A，V，SN）
              } else if (ordChecklistRegCheckInfo.getClassCd() == 9 || ordChecklistRegCheckInfo.getClassCd() == 10
                || ordChecklistRegCheckInfo.getClassCd() == 11) {
                //funcListsに入れたデータが今回funcListに入れたデータと同じかどうかをフィルタリングし、class _ cdはitem _ cdと同じで、同じものがあればスキップし、逆に入れて作成する（9.10.11はすべてchass _ cd=9として入れるため）
                funcLists = funcLists.stream().filter(f -> (f.getClass_cd() != null)).distinct().collect(Collectors.toList()); //Class _ cd()=nullのデータをフィルタして、比較時にエラーが発生しないようにします
                List<FuncList> funcListsCheck = funcLists.stream().filter(f -> (f.getClass_cd() == 9 && f.getItem_number() == ordChecklistRegCheckInfo.getItemNumber())).distinct().collect(Collectors.toList());
                if (funcListsCheck == null || funcListsCheck.size() < 1) { //ClassCd=9のデータが作成されていない場合（list _ cdごとに1回作成）
                  funcList.setClass_cd(9);
                  funcList.setList_name("穿刺針");
                  funcList.setFunc_class(StringUtils.isEmpty(ordChecklist.getFuncClass()) ? null : ordChecklist.getFuncClass());
                  funcList.setItem_number(StringUtils.isEmpty(ordChecklistRegCheckInfo.getItemNumber()) ? null : ordChecklistRegCheckInfo.getItemNumber());
                }
                //治療条件のその他の正常項目
              } else {
                funcList.setClass_cd(StringUtils.isEmpty(ordChecklistRegCheckInfo.getClassCd()) ? null : ordChecklistRegCheckInfo.getClassCd());
                funcList.setList_name(StringUtils.isEmpty(ordChecklistRegCheckInfo.getName()) ? null : ordChecklistRegCheckInfo.getName());
                funcList.setFunc_class(StringUtils.isEmpty(ordChecklist.getFuncClass()) ? null : ordChecklist.getFuncClass());
                funcList.setItem_number(StringUtils.isEmpty(ordChecklistRegCheckInfo.getItemNumber()) ? null : ordChecklistRegCheckInfo.getItemNumber());
              }
              //TODO 投与药剂，医療材料
            } else {
              //薬剤を投与するには、医療材料は、ord _ checklistに同じ分類の薬剤または医療材料が使用されるので、func _ classとclass _ cdとitem _ nubmerを判定することによって重量除去する必要があります
              funcLists = funcLists.stream().filter(f -> (f.getClass_cd() != null)).distinct().collect(Collectors.toList()); //Class _ cd()=nullのデータをフィルタして、比較時にエラーが発生しないようにします
              List<FuncList> funcListsCheck = funcLists.stream().filter(f -> (f.getFunc_class() == ordChecklist.getFuncClass() && f.getClass_cd().equals(ordChecklistRegCheckInfo.getClassCd()) && f.getItem_number() == ordChecklistRegCheckInfo.getItemNumber())).distinct().collect(Collectors.toList());
              if (funcListsCheck == null || funcListsCheck.size() < 1) { //同じlist _ cdでfunc _ classとclass _ cdとitem _ nubmerのデータが作成されていない場合（list _ cdごとに1回作成）
                funcList.setClass_cd(StringUtils.isEmpty(ordChecklistRegCheckInfo.getClassCd()) ? null : ordChecklistRegCheckInfo.getClassCd());
                funcList.setList_name(StringUtils.isEmpty(ordChecklistRegCheckInfo.getName()) ? null : ordChecklistRegCheckInfo.getName());
                funcList.setFunc_class(StringUtils.isEmpty(ordChecklist.getFuncClass()) ? null : ordChecklist.getFuncClass());
                funcList.setItem_number(StringUtils.isEmpty(ordChecklistRegCheckInfo.getItemNumber()) ? null : ordChecklistRegCheckInfo.getItemNumber());
              }
            }
          }
          //まずfuncListをキャッシュし、funcListを作成するたびに照合検証を行う
          if (!StringUtils.isEmpty(funcList.getItem_number())) { //Item _ numberがnullである不作為正常データ転送
            funcLists.add(funcList);
            jsonArray.put(funcList.makeJsonStr());
          }
        }
        checklistSettings.setFunclist(makeJsonStr(jsonArray));
        checklistSettings.setOperation(2); //固定给2
        checklistSettings.setList_name(null); // 默认给空
        checklistSettings.setDialysis_prog_name(dialysis_prog_name);
        checklistSettingStr = checklistSettings.makeJsonStr();
        JSONObject mstJson = new JSONObject(checklistSettingStr);
        jsonArrayMst.put(mstJson);
      }
      JsonNode node = map.readTree(makeJsonStr(jsonArrayMst));
      JsonNodeMap.put(String.valueOf(checklistCd), node);
      return JsonNodeMap;
    } catch (Exception exception) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//            exception.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(exception));
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
      return null;
    }
  }

  /**
   * jsonエスケープ文字と外側二重引用符の除去
   *
   * @param jsonArray
   * @return
   */
  private String makeJsonStr(JSONArray jsonArray) {
    // JSONArrayの要素を文字列に結合する
    StringBuilder sb = new StringBuilder();
    sb.append("[");
    for (int i = 0; i < jsonArray.length(); i++) {
      sb.append(jsonArray.get(i));
      if (i < jsonArray.length() - 1) {
        sb.append(", ");
      }
    }
    sb.append("]");
    return sb.toString();
  }

  /**
   * marge OrdCheckList left
   *
   * @param ordChecklistListOfMarge
   * @param ordChecklistListForMarge
   * @return
   */
  public void margeOrdCheckListInsCheckLeft(List<OrdChecklist> ordChecklistListOfMarge, List<OrdChecklist> ordChecklistListForMarge) {
    //margeのOrdChecklistに実装されているデータをフィルタリングする
    List<Long> checklistCtlNosDel = new ArrayList<>();
    if (ordChecklistListOfMarge != null) {
      List<OrdChecklist> coincideOf = new ArrayList<>();
      List<OrdChecklist> coincideFor = new ArrayList<>();
      //isCheckステータスを挿入して更新する必要があるアイテム
      List<OrdChecklist> coincideForIsCheck = new ArrayList<>();
      if (ordChecklistListForMarge.size() > 0) {
        for (OrdChecklist ordChecklist : ordChecklistListForMarge) {
          for (OrdChecklist ordChecklist1 : ordChecklistListOfMarge) {
            if (ordChecklist1.getFuncClass() != 0) {
              if (Objects.equals(ordChecklist.getRstClass(), ordChecklist1.getRstClass())
                && Objects.equals(ordChecklist.getListCd(), ordChecklist1.getListCd())
                && Objects.equals(ordChecklist.getFuncClass(), ordChecklist1.getFuncClass())
                && Objects.equals(ordChecklist.getRstChecklistInfo().getItemNumber(), ordChecklist1.getRstChecklistInfo().getItemNumber())
                && Objects.equals(ordChecklist.getRstChecklistInfo().getClassCd(), ordChecklist1.getRstChecklistInfo().getClassCd())
                && Objects.equals(ordChecklist.getRstChecklistInfo().getCode(), ordChecklist1.getRstChecklistInfo().getCode())
                && Objects.equals(ordChecklist.getRstChecklistInfo().getMedicineType(), ordChecklist1.getRstChecklistInfo().getMedicineType())
                && Objects.equals(ordChecklist.getRstChecklistInfo().getEquipType(), ordChecklist1.getRstChecklistInfo().getEquipType())
                && Objects.equals(ordChecklist.getRstChecklistInfo().getMedicineNo(), ordChecklist1.getRstChecklistInfo().getMedicineNo())
                && Objects.equals(ordChecklist.getRstChecklistInfo().getAmount(), ordChecklist1.getRstChecklistInfo().getAmount())
                ) {
                if ("1".equals(ordChecklist1.getIsCheck())) {
                  coincideForIsCheck.add(ordChecklist);
                }
                coincideOf.add(ordChecklist1);
                coincideFor.add(ordChecklist);
              }
            } else {
              if (Objects.equals(ordChecklist.getRstClass(), ordChecklist1.getRstClass())
                && Objects.equals(ordChecklist.getListCd(), ordChecklist1.getListCd())
                && Objects.equals(ordChecklist.getFuncClass(), ordChecklist1.getFuncClass())
                && Objects.equals(ordChecklist.getRstChecklistInfo().getItemNumber(), ordChecklist1.getRstChecklistInfo().getItemNumber())
                && Objects.equals(ordChecklist.getRstChecklistInfo().getName(), ordChecklist1.getRstChecklistInfo().getName())
              ) {
                if ("1".equals(ordChecklist1.getIsCheck())) {
                  coincideForIsCheck.add(ordChecklist);
                }
                coincideOf.add(ordChecklist1);
                coincideFor.add(ordChecklist);
              }
            }
          }
        }
      }
      //ordChecklistListOfMargeとcoincideOfが異なるアイテムをフィルタし、ord _ checklistから削除する
      List<OrdChecklist> differentOf = new ArrayList<>();
      differentOf = ordChecklistListOfMarge.stream()
        .filter(obj -> !coincideOf.contains(obj)).collect(Collectors.toList());
      if (differentOf.size() > 0) {
        differentOf.forEach(f -> {
          checklistCtlNosDel.add(f.getChecklistCtlNo());
        });
        //ord _ checklistから削除（物理的削除）
        ordChecklistDao.deleteChecklistByCtlNo(checklistCtlNosDel);
      }
      //ordChecklistListForMargeとcoincideForが異なるアイテムをフィルタし、ord _ checklistに挿入
      List<OrdChecklist> differentForAdd = new ArrayList<>();
      differentForAdd = ordChecklistListForMarge.stream()
        .filter(obj -> !coincideFor.contains(obj)).collect(Collectors.toList());
      if (differentForAdd.size() > 0) {
        //ord _ checklistに挿入
        ordChecklistDao.insertByList(differentForAdd);
      }
    }
  }

  /**
   * marge OrdCheckList del
   *
   * @param ordChecklistListOfMarge
   * @param ordChecklistListForMarge
   * @return
   */
  public void margeOrdCheckListInsDel(List<OrdChecklist> ordChecklistListOfMarge, List<OrdChecklist> ordChecklistListForMarge) {
    List<Long> checklistCtlNosDel = new ArrayList<>();
    if (ordChecklistListOfMarge != null) {
      List<OrdChecklist> coincide = new ArrayList<>();
      List<OrdChecklist> coincidelete = new ArrayList<>();
      if (ordChecklistListForMarge.size() > 0) {
        for (OrdChecklist ordChecklist : ordChecklistListOfMarge) { //old data
          if ("1".equals(ordChecklist.getIsCheck())) { //元のord _ checklistデータはcheckされたものだけが照合する必要があると優先的に判定し、残りのcheckされていないデータはすべて削除する
            boolean isDel = false;
            for (OrdChecklist ordChecklist1 : ordChecklistListForMarge) { //new data
              if (ordChecklist1.getFuncClass() != 0) {
                if (Objects.equals(ordChecklist.getRstClass(), ordChecklist1.getRstClass())
                  && Objects.equals(ordChecklist.getListCd(), ordChecklist1.getListCd())
                  && Objects.equals(ordChecklist.getFuncClass(), ordChecklist1.getFuncClass())
                  && Objects.equals(ordChecklist.getRstChecklistInfo().getItemNumber(), ordChecklist1.getRstChecklistInfo().getItemNumber())
                  && Objects.equals(ordChecklist.getRstChecklistInfo().getClassCd(), ordChecklist1.getRstChecklistInfo().getClassCd())
                  && Objects.equals(ordChecklist.getRstChecklistInfo().getCode(), ordChecklist1.getRstChecklistInfo().getCode())
                  && Objects.equals(ordChecklist.getRstChecklistInfo().getMedicineType(), ordChecklist1.getRstChecklistInfo().getMedicineType())
                  && Objects.equals(ordChecklist.getRstChecklistInfo().getEquipType(), ordChecklist1.getRstChecklistInfo().getEquipType())
                  && Objects.equals(ordChecklist.getRstChecklistInfo().getMedicineNo(), ordChecklist1.getRstChecklistInfo().getMedicineNo())
                  && equalsAsNumber(ordChecklist.getRstChecklistInfo().getAmount(), ordChecklist1.getRstChecklistInfo().getAmount())
                  ) {
                  isDel = true;
                  coincide.add(ordChecklist);
                }
              } else {
                if (Objects.equals(ordChecklist.getRstClass(), ordChecklist1.getRstClass())
                  && Objects.equals(ordChecklist.getListCd(), ordChecklist1.getListCd())
                  && Objects.equals(ordChecklist.getFuncClass(), ordChecklist1.getFuncClass())
                  && Objects.equals(ordChecklist.getRstChecklistInfo().getItemNumber(), ordChecklist1.getRstChecklistInfo().getItemNumber())
                  && Objects.equals(ordChecklist.getRstChecklistInfo().getName(), ordChecklist1.getRstChecklistInfo().getName())
                ) {
                  isDel = true;
                  coincide.add(ordChecklist);
                }
              }
            }
            if (!isDel) {
              coincidelete.add(ordChecklist);
            }
          } else {
            //チェックされていない項目はそのまま削除
            coincidelete.add(ordChecklist);
          }
        }
      }
      //ordChecklistListOfMargeとcoincideが異なるアイテムをフィルタし、ord _ checklistから削除する
      if (coincidelete.size() > 0) {
        coincidelete.forEach(f -> {
          checklistCtlNosDel.add(f.getChecklistCtlNo());
        });
        //ord _ checklistから削除（物理的削除）
        ordChecklistDao.deleteChecklistByCtlNo(checklistCtlNosDel);
      }
    }
  }

  /**
   * marge OrdCheckList ???患者marge
   *
   * @param ordChecklistListOfMarge
   * @param ordChecklistListForMarge
   * @return
   */
  public List<OrdChecklist> margeOrdCheckListInsCheckRight(List<OrdChecklist> ordChecklistListOfMarge, List<OrdChecklist> ordChecklistListForMarge, boolean isDelete) {
    //保持のみ？？？患者がチェックされた項目
    ordChecklistListOfMarge = ordChecklistListOfMarge.stream().filter(f -> ("1".equals(f.getIsCheck()))).distinct().collect(Collectors.toList());
    //コピー、判定は？？？患者後、最終的に削除する必要がありますか？？？患者のord _ checklistデータ
    List<OrdChecklist> copy = new ArrayList<>(ordChecklistListOfMarge);
    //？？？患者は1回目のmarge後のchecklistと比較した
    Map<Long, OrdChecklist> upd = new HashMap<>();
    if (ordChecklistListOfMarge.size() > 0) {
      if (ordChecklistListForMarge.size() > 0) {
        for (OrdChecklist ordChecklist : ordChecklistListOfMarge) {
          for (OrdChecklist ordChecklist1 : ordChecklistListForMarge) {
            if (ordChecklist1.getFuncClass() != 0) {
              if (Objects.equals(ordChecklist.getRstClass(), ordChecklist1.getRstClass())
                && Objects.equals(ordChecklist.getListCd(), ordChecklist1.getListCd())
                && Objects.equals(ordChecklist.getFuncClass(), ordChecklist1.getFuncClass())
                && Objects.equals(ordChecklist.getRstChecklistInfo().getItemNumber(), ordChecklist1.getRstChecklistInfo().getItemNumber())
                && Objects.equals(ordChecklist.getRstChecklistInfo().getClassCd(), ordChecklist1.getRstChecklistInfo().getClassCd())
                && Objects.equals(ordChecklist.getRstChecklistInfo().getCode(), ordChecklist1.getRstChecklistInfo().getCode())
                && Objects.equals(ordChecklist.getRstChecklistInfo().getMedicineType(), ordChecklist1.getRstChecklistInfo().getMedicineType())
                && Objects.equals(ordChecklist.getRstChecklistInfo().getEquipType(), ordChecklist1.getRstChecklistInfo().getEquipType())
                && Objects.equals(ordChecklist.getRstChecklistInfo().getMedicineNo(), ordChecklist1.getRstChecklistInfo().getMedicineNo())
                && equalsAsNumber(ordChecklist.getRstChecklistInfo().getAmount(), ordChecklist1.getRstChecklistInfo().getAmount())
                ) {
                //は？？？患者がチェックされた項目とmargeされた項目は対応する集合に保存される
                upd.put(ordChecklist1.getChecklistCtlNo(), ordChecklist);
              }
            } else { //FuncClass==0通常は1 name多い判定
              if (Objects.equals(ordChecklist.getRstClass(), ordChecklist1.getRstClass())
                && Objects.equals(ordChecklist.getListCd(), ordChecklist1.getListCd())
                && Objects.equals(ordChecklist.getFuncClass(), ordChecklist1.getFuncClass())
                && Objects.equals(ordChecklist.getRstChecklistInfo().getItemNumber(), ordChecklist1.getRstChecklistInfo().getItemNumber())
                && Objects.equals(ordChecklist.getRstChecklistInfo().getName(), ordChecklist1.getRstChecklistInfo().getName())
              ) {
                //は？？？患者がチェックされた項目とmargeされた項目は対応する集合に保存される
                upd.put(ordChecklist1.getChecklistCtlNo(), ordChecklist);
              }
            }
          }
        }
      }
    }
    ObjectMapper objectMapper = new ObjectMapper();
    //Mapを巡回して、更新するord _ checklistエントリを取得します
    try {
      for (Map.Entry<Long, OrdChecklist> entry : upd.entrySet()) {
        Long checklistCtlNo = entry.getKey();
        OrdChecklist ordChecklist = entry.getValue();
        OrdChecklistRegStaffInfo ordChecklistRegStaffInfo = ordChecklist.getRegStaffInfo();
        // カスタムオブジェクトをJSON文字列に変換する
        String jsonString = objectMapper.writeValueAsString(ordChecklistRegStaffInfo);
        ordChecklistDao.updateIscheckByOrdNo(ordChecklist.getIsCheck(), jsonString, ordChecklist.getOccurDate(), ordChecklist.getRegDate(), checklistCtlNo);
      }
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
    }

    //削除しますか？？？患者または現在の患者の他の実際の治療のord _ checklistデータ
    if (isDelete) {
      List<Long> checklistCtlNosDel = new ArrayList<>();
      copy.forEach(f -> {
        checklistCtlNosDel.add(f.getChecklistCtlNo());
      });
      ordChecklistDao.delOrdCheckListByOrdNos(checklistCtlNosDel);
    }
    return ordChecklistListForMarge;
  }

//add 9324 治療情報を異なる状態で変更した後のord_checklistの再編成共通方法 gjn end

  // add #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240529 start
  @Override
  public void indApprovedForContent(Long ordNo) {
    try{
      String logMsg = String.format("治療単位指示受け時指示内容、治療単位指示承認時指示内容，保存処理開始 ord_no: %d", ordNo);
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(logMsg);
      logService.log(LogLevel.INFO, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);

      List<PatIndApprove> patIndApproves = patIndApproveDao.selectPatIndApproveByOrdNo(ordNo);
      if (patIndApproves.isEmpty()) {
        return;
      }
      PatIndApprove patIndApprove = patIndApproves.get(0);
      String checkContent = patIndApprove.getCheck_content();
      String approveContent = patIndApprove.getApprove_content();
      boolean hasCheckContent = false;
      boolean hasApproveContent = false;
      if(StringUtils.hasText(checkContent) && !"{}".equals(checkContent)) {
        hasCheckContent = true;
      }
      if(StringUtils.hasText(approveContent) && !"{}".equals(approveContent)) {
        hasApproveContent = true;
      }

      if(!hasCheckContent && !hasApproveContent) {
        return;
      }

      OrdMain ordMain = ordMainDao.selectByOrdNo(ordNo);
      IndScheduleUser user = getIndScheduleUser(ordMain);
      //mod #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi start
      String content = getJsonStr(ordMain, user);
      //mod #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi end
      // 更新
      if (hasCheckContent) {
        patIndApprove.setCheck_content(content);
      }
      if (hasApproveContent) {
        patIndApprove.setApprove_content(content);
      }
      if(hasCheckContent || hasApproveContent){
        patIndApproveDao.updateContent(patIndApprove);
      }
      logMsg = String.format("治療単位指示受け時指示内容、治療単位指示承認時指示内容，保存処理完了 ord_no: %d", ordNo);
      eventLogMessage.setLogMessage(logMsg);
      logService.log(LogLevel.INFO, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
    }catch(Exception e){
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
    }
  }
  //mod #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi end

  //add #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi start
  /**
   *
   * @param ordMain 指示
   * @param user 指示者情報
   */
  private String getJsonStr(OrdMain ordMain, IndScheduleUser user) throws Exception {
    ObjectMapper objectMapper = new ObjectMapper();
    ArrayNode arrayNode = objectMapper.createArrayNode();

    // 治療方法
    PatIndApproveDto treatMethod = buildTreatMethod(ordMain, user);
    JsonNode treatMethodJson = objectMapper.valueToTree(treatMethod);
    arrayNode.add(treatMethodJson);
    // スケジュール
    PatIndApproveDto schedule = buildSchedule(ordMain, user);
    JsonNode scheduleJson = objectMapper.valueToTree(schedule);
    arrayNode.add(scheduleJson);
    // 治療条件
    PatIndApproveDto condInfo = buildCondInfo(ordMain);
    JsonNode condInfoJson = objectMapper.valueToTree(condInfo);
    arrayNode.add(condInfoJson);
    // 薬剤
    PatIndApproveDto medicine = buildMedicine(ordMain);
    JsonNode medicineJson = objectMapper.valueToTree(medicine);
    arrayNode.add(medicineJson);
    // 医材
    PatIndApproveDto equipment = buildEquip(ordMain);
    JsonNode equipmentJson = objectMapper.valueToTree(equipment);
    arrayNode.add(equipmentJson);
    // 指示コメント
    PatIndApproveDto comment = buildComment(ordMain);
    JsonNode commentJson = objectMapper.valueToTree(comment);
    arrayNode.add(commentJson);
    return objectMapper.writeValueAsString(arrayNode);
  }
  //add #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi end
  // add #12235【因島】チェックリストの治療条件：抗凝固剤での小数点桁数の扱いが不正 関 start
  public static boolean equalsAsNumber(String a, String b) {
    if (a == null || b == null || a.trim().isEmpty() || b.trim().isEmpty()) {
      return false;
    }
    try {
      return new BigDecimal(a.trim()).compareTo(new BigDecimal(b.trim())) == 0;
    } catch (NumberFormatException e) {
      return false;
    }
  }
  // add #12235【因島】チェックリストの治療条件：抗凝固剤での小数点桁数の扱いが不正 関 end

  // add #9507 一括指示受けに時間がかかる zrx start
  @Override
  public String getIndApprovedForContent(Long ordNo) {
    String content = null;
    try{
      String logMsg = String.format("治療単位指示受け時指示内容、治療単位指示承認時指示内容 ord_no: %d", ordNo);
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(logMsg);
      logService.log(LogLevel.INFO, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);

      OrdMain ordMain = ordMainDao.selectByOrdNo(ordNo);
      IndScheduleUser user = getIndScheduleUser(ordMain);
      content = getJsonStr(ordMain, user);
      logMsg = String.format("治療単位指示受け時指示内容、治療単位指示承認時指示内容 ord_no: %d", ordNo);
      eventLogMessage.setLogMessage(logMsg);
      logService.log(LogLevel.INFO, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
    }catch(Exception e){
      e.printStackTrace();
    }
    return content;
  }
  //add #9507 一括指示受けに時間がかかる zrx end
}
