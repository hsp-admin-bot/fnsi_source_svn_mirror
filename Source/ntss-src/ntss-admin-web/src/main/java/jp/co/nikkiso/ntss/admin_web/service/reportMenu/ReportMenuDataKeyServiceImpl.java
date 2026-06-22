package jp.co.nikkiso.ntss.admin_web.service.reportMenu;

import jp.co.nikkiso.ntss.admin_web.request.creatingReport.ReportByCdRequest;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.api.constant.ReportConstant;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.MstBedDao;
import jp.co.nikkiso.ntss.core.dao.MstDialyzerDao;
import jp.co.nikkiso.ntss.core.dao.MstEquipmentClassDao;
import jp.co.nikkiso.ntss.core.dao.MstExamSetDao;
import jp.co.nikkiso.ntss.core.dao.MstKurDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilitySettingDao;
import jp.co.nikkiso.ntss.core.dao.MstMedicineClassDao;
import jp.co.nikkiso.ntss.core.dao.MstReportDao;
import jp.co.nikkiso.ntss.core.dao.MstRoomBedGroupDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.OrdPrescriptionDao;
import jp.co.nikkiso.ntss.core.entity.MstBed;
import jp.co.nikkiso.ntss.core.entity.MstDialyzer;
import jp.co.nikkiso.ntss.core.entity.MstEquipmentClass;
import jp.co.nikkiso.ntss.core.entity.MstExamSet;
import jp.co.nikkiso.ntss.core.entity.MstKur;
import jp.co.nikkiso.ntss.core.entity.MstMedicineClass;
import jp.co.nikkiso.ntss.core.entity.MstReport;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.OrdPrescription;
import jp.co.nikkiso.ntss.core.entity.custom.FacilitySettingInfo;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import lombok.extern.slf4j.Slf4j;
import org.json.JSONArray;
import org.json.JSONObject;
import org.seasar.doma.jdbc.SelectOptions;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.CollectionUtils;
import org.springframework.util.StringUtils;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;
import java.util.stream.Stream;

// add #9558 機能帳票で正しく変数が引き渡されていない 高 start
@Service
@Slf4j
public class ReportMenuDataKeyServiceImpl implements ReportMenuDataKeyService {
  @Autowired
  MstFacilitySettingDao mstFacilitySettingDao;

  @Autowired
  LogService logService;

  @Autowired
  private MstReportDao mstReportDao;

  @Autowired
  private OrdMainDao ordMainDao;

  // add #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe start
  @Autowired
  MstKurDao mstKurDao;
  // add #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe end

  @Autowired
  private MstBedDao mstBedDao;

  // add 11010 スケジュール表出力時の処理が不足している gjn start
  @Autowired
  MstRoomBedGroupDao mstRoomBedGroupDao;
  // add 11010 スケジュール表出力時の処理が不足している gjn end

  // add #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe start
  @Autowired
  private MstDialyzerDao mstDialyzerDao;

  @Autowired
  private MstEquipmentClassDao mstEquipmentClassDao;

  @Autowired
  private MstMedicineClassDao mstMedicineClassDao;

  @Autowired
  private MstExamSetDao mstExamSetDao;
  // add #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe end

  // add #11257 機能帳票の出力に帳票保存のソート条件を適用する 高 start
  @Autowired
  private ReportMenuDataKeySortCommonServiceImpl reportMenuDataKeySortCommonService;
  // add #11257 機能帳票の出力に帳票保存のソート条件を適用する 高 end

  // add #10526 クラス「処方情報」の「保険者番号」等に一桁づつ出力するデータセットを追加 sunsy start
  @Autowired
  private OrdPrescriptionDao ordPrescriptionDao;
  // add #10526 クラス「処方情報」の「保険者番号」等に一桁づつ出力するデータセットを追加 sunsy end

  @Override
  public Map<String, Object> setDataKeyMeth(Long reportCd, MstReport report, ReportByCdRequest request, NtssUser ntssUser, List<OrdMain> ordNosList) throws ParseException {
    Map<String, Object> dataKey = request.getDataKey();
    Map<String, Object> dataKeyNew = new HashMap<>();
    dataKeyNew.put("reportOneFlag", "0");
    // mod #11968 iPadで治療記録画面の機能帳票表示に失敗する 高　start
//    if (dataKey.containsKey("baseDate") && !StringUtils.isEmpty(dataKey.containsKey("baseDate"))) {
//      // 基準日
//      dataKey.put("baseDate", dataKey.get("baseDate").toString().replace("/", "").replace("-", ""));
//      dataKeyNew.put("baseDate", dataKey.get("baseDate").toString().replace("/", "").replace("-", ""));
//    }
//    if (dataKey.containsKey("treatDate") && !StringUtils.isEmpty(dataKey.containsKey("treatDate"))) {
//      // 透析日
//      dataKey.put("treatDate", dataKey.get("treatDate").toString().replace("/", "").replace("-", ""));
//      dataKeyNew.put("treatDate", dataKey.get("treatDate").toString().replace("/", "").replace("-", ""));
//    }
//    if (dataKey.containsKey("date") && !StringUtils.isEmpty(dataKey.containsKey("date"))) {
//      // 対象日
//      dataKey.put("date", dataKey.get("date").toString().replace("/", "").replace("-", ""));
//      dataKeyNew.put("date", dataKey.get("date").toString().replace("/", "").replace("-", ""));
//    }
//    if (dataKey.containsKey("fromDate") && !StringUtils.isEmpty(dataKey.containsKey("fromDate"))) {
//      // 対象期間始
//      dataKey.put("fromDate", dataKey.get("fromDate").toString().replace("/", "").replace("-", ""));
//      dataKeyNew.put("fromDate", dataKey.get("fromDate").toString().replace("/", "").replace("-", ""));
//    }
//    if (dataKey.containsKey("toDate") && !StringUtils.isEmpty(dataKey.containsKey("toDate"))) {
//      // 対象期間終
//      dataKey.put("toDate", dataKey.get("toDate").toString().replace("/", "").replace("-", ""));
//      dataKeyNew.put("toDate", dataKey.get("toDate").toString().replace("/", "").replace("-", ""));
//    }
//    // add #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe start
//    if (dataKey.containsKey("dialysisDate") && !StringUtils.isEmpty(dataKey.containsKey("dialysisDate"))) {
//      // 対象期間終
//      dataKey.put("dialysisDate", dataKey.get("dialysisDate").toString().replace("/", "").replace("-", ""));
//      dataKeyNew.put("dialysisDate", dataKey.get("dialysisDate").toString().replace("/", "").replace("-", ""));
//    }
//    // add #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe end
    if (dataKey.containsKey("baseDate") && !StringUtils.isEmpty(dataKey.get("baseDate"))) {
      // 基準日
      dataKey.put("baseDate", dataKey.get("baseDate").toString().replace("/", "").replace("-", ""));
      dataKeyNew.put("baseDate", dataKey.get("baseDate").toString().replace("/", "").replace("-", ""));
    }
    if (dataKey.containsKey("treatDate") && !StringUtils.isEmpty(dataKey.get("treatDate"))) {
      // 透析日
      dataKey.put("treatDate", dataKey.get("treatDate").toString().replace("/", "").replace("-", ""));
      dataKeyNew.put("treatDate", dataKey.get("treatDate").toString().replace("/", "").replace("-", ""));
    }
    if (dataKey.containsKey("date") && !StringUtils.isEmpty(dataKey.get("date"))) {
      // 対象日
      dataKey.put("date", dataKey.get("date").toString().replace("/", "").replace("-", ""));
      dataKeyNew.put("date", dataKey.get("date").toString().replace("/", "").replace("-", ""));
    }
    if (dataKey.containsKey("fromDate") && !StringUtils.isEmpty(dataKey.get("fromDate"))) {
      // 対象期間始
      dataKey.put("fromDate", dataKey.get("fromDate").toString().replace("/", "").replace("-", ""));
      dataKeyNew.put("fromDate", dataKey.get("fromDate").toString().replace("/", "").replace("-", ""));
    }
    if (dataKey.containsKey("toDate") && !StringUtils.isEmpty(dataKey.get("toDate"))) {
      // 対象期間終
      dataKey.put("toDate", dataKey.get("toDate").toString().replace("/", "").replace("-", ""));
      dataKeyNew.put("toDate", dataKey.get("toDate").toString().replace("/", "").replace("-", ""));
    }
    if (dataKey.containsKey("dialysisDate") && !StringUtils.isEmpty(dataKey.get("dialysisDate"))) {
      // 対象期間終
      dataKey.put("dialysisDate", dataKey.get("dialysisDate").toString().replace("/", "").replace("-", ""));
      dataKeyNew.put("dialysisDate", dataKey.get("dialysisDate").toString().replace("/", "").replace("-", ""));
    }
    // mod #11968 iPadで治療記録画面の機能帳票表示に失敗する 高　end
    dataKeyNew.put("reportClass", report.getReportClass());
    // del #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe start
    //if (!"00801".equals(dataKey.get("functionCd")) && !"00401".equals(dataKey.get("functionCd"))) {
    // del #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe end
    if (dataKey.get(ReportConstant.ReportDataKey.PAT_ID) != null) dataKeyNew.put(ReportConstant.ReportDataKey.PAT_ID, Long.parseLong(dataKey.get(ReportConstant.ReportDataKey.PAT_ID).toString()));
    // mod #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe start
//    if (dataKey.get("patIds") != null) {
//      List<Long> patIds = (List<Long>) dataKey.get("patIds");
//      List<Long> newPatIds = new ArrayList<>();
//      for (int i = 0; i < patIds.size(); i++) {
//        // mod #9558 機能帳票でパラメータが正しく渡されていない 高 start
////          newPatIds.add(Long.parseLong(String.valueOf(patIds.get(i))));
//        if (!StringUtils.isEmpty(patIds.get(i))) {
//          newPatIds.add(Long.parseLong(String.valueOf(patIds.get(i))));
//        } else {
//          newPatIds.add(patIds.get(i));
//        }
//        // mod #9558 機能帳票でパラメータが正しく渡されていない 高 end
//      }
//      dataKeyNew.put("patIds", newPatIds);
//    }
//   }
    if (dataKey.get(ReportConstant.ReportDataKey.PAT_IDS) != null) {
      List<Long> newOrdNos = changeTypeNumtoLong((List<Integer>)dataKey.get(ReportConstant.ReportDataKey.PAT_IDS));
      dataKeyNew.put(ReportConstant.ReportDataKey.PAT_IDS, newOrdNos);
    }
    if (dataKey.get(ReportConstant.ReportDataKey.ORD_NO) != null) dataKeyNew.put(ReportConstant.ReportDataKey.ORD_NO, Long.parseLong(dataKey.get(ReportConstant.ReportDataKey.ORD_NO).toString()));
    if (dataKey.get(ReportConstant.ReportDataKey.ORD_NOS) != null) {
      List<Long> newOrdNos = changeTypeNumtoLong((List<Integer>)dataKey.get(ReportConstant.ReportDataKey.ORD_NOS));
      dataKeyNew.put(ReportConstant.ReportDataKey.ORD_NOS, newOrdNos);
    }
    // mod #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe end
    // add #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe start
    if (dataKey.containsKey(ReportConstant.ReportDataKey.ORD_PRESCRIPTION_NO) && dataKey.get(ReportConstant.ReportDataKey.ORD_PRESCRIPTION_NO) != null) {
      dataKeyNew.put(ReportConstant.ReportDataKey.ORD_PRESCRIPTION_NO, Long.parseLong(dataKey.get(ReportConstant.ReportDataKey.ORD_PRESCRIPTION_NO).toString()));
    }
    if (dataKey.containsKey(ReportConstant.ReportDataKey.BED_CDS) && dataKey.get(ReportConstant.ReportDataKey.BED_CDS) != null) {
      List<Long> newbedCds = changeTypeNumtoLong((List<Integer>) dataKey.get(ReportConstant.ReportDataKey.BED_CDS));
      dataKeyNew.put(ReportConstant.ReportDataKey.BED_CDS, newbedCds);
    }
    if (dataKey.containsKey(ReportConstant.ReportDataKey.KUR_CDS) && dataKey.get(ReportConstant.ReportDataKey.KUR_CDS) != null) {
      List<Long> newKurCds = changeTypeNumtoLong((List<Integer>) dataKey.get(ReportConstant.ReportDataKey.KUR_CDS));
      dataKeyNew.put(ReportConstant.ReportDataKey.KUR_CDS, newKurCds);
    }
    else if (dataKey.containsKey("selectKurCd") && dataKey.get("selectKurCd") != null) {
      List<Long> newKurCds = changeTypeNumtoLong((List<Integer>) dataKey.get("selectKurCd"));
      dataKey.put(ReportConstant.ReportDataKey.KUR_CDS, newKurCds);
      dataKeyNew.put(ReportConstant.ReportDataKey.KUR_CDS, newKurCds);
    }
    // add #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe end

    if (null != dataKey.get("functionCd")) {
      // del #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe start
      // 患者経過総合ビューア
//      if (dataKey.get("functionCd").toString().equals("00401")) {
//        Map<String, Object> map = new HashMap<>();
//        String patId = "";
//        if (dataKey.get("patId") instanceof Map) {
//          map = (Map<String, Object>) dataKey.get("patId");
//          map = (Map<String, Object>) map.get("pat_personal_main");
//          patId = map.get("pat_id").toString();
//        } else {
//          patId = dataKey.get("patId").toString();
//        }
//
//        List<Long> patIds = new ArrayList<>();
//        patIds.add(Long.parseLong(patId));
//        dataKeyNew.put("patId", patId);
//        dataKeyNew.put("patIds", patIds);
//        dataKeyNew.put("facilityCd", ntssUser.getFacilityCd());
//        LocalDate beforeDate;
//        LocalDate afterDate;
//        LocalDate oldDate;
//        DateTimeFormatter formatter;
//        String minusDate = minusOneMonth(dataKey.get("baseDate").toString());
//        formatter = DateTimeFormatter.ofPattern("yyyyMMdd");
//        beforeDate = LocalDate.parse(dataKey.get("baseDate").toString(), formatter);
//        afterDate = LocalDate.parse(minusDate, formatter);
//        List<Long> ordNoList1 = new ArrayList<>();
//        List<List<Long>> ord = new ArrayList<>();
//        do {
//          oldDate = beforeDate;
//          beforeDate = beforeDate.minusDays(1);
//          ordNoList1 = ordMainDao.selectOrdnoByPatId(ntssUser.getFacilityCd()
//            , Long.parseLong(String.valueOf(dataKeyNew.get("patId")))
//            , oldDate.toString().replace("/", "").replace("-", "")
//            , oldDate.toString().replace("/", "").replace("-", "")
//            , "0");
//          if (ordNoList1.size() != 0) {
//            ord.add(ordNoList1);
//          }
//          if (ord != null && ord.size() != 0 && ord.stream().filter(p -> !p.isEmpty()).collect(Collectors.toList()).size() != 0) {
//            break;
//          }
//        } while (!beforeDate.isBefore(afterDate));
//        if (ord.size() != 0) {
//          List<Long> ordNoListNew = new ArrayList<>();
//          ordNoListNew.add(Long.parseLong(String.valueOf(ord.get(0).get(0))));
//          dataKeyNew.put("ordNos", ordNoListNew);
//          dataKeyNew.put("ordNo", Long.parseLong(String.valueOf(ord.get(0).get(0))));
//        }
//        dataKeyNew.put(ReportConstant.ReportDataKey.DATE_FROM, dataKey.get("date"));
//        dataKeyNew.put(ReportConstant.ReportDataKey.treatDate, dataKey.get("baseDate"));
//        String reStr = addOneMonth(dataKeyNew.get("date").toString(), dataKey.get("functionCd").toString());
//        dataKeyNew.put(ReportConstant.ReportDataKey.DATE_TO, reStr);
//      }
      // 治療記録
//      else if (dataKey.get("functionCd").toString().equals("00601")) {
//        List<Long> patIds = new ArrayList<>();
//        patIds.add(Long.parseLong(String.valueOf(dataKey.get("patId"))));
//        dataKeyNew.put("patIds", patIds);
//        dataKeyNew.put("facilityCd", ntssUser.getFacilityCd());
//        LocalDate beforeDate;
//        LocalDate afterDate;
//        LocalDate oldDate;
//        DateTimeFormatter formatter;
//        formatter = DateTimeFormatter.ofPattern("yyyyMMdd");
//        beforeDate = LocalDate.parse(dataKey.get("date").toString(), formatter);
//        afterDate = LocalDate.parse(dataKey.get("date").toString(), formatter);
//        List<Long> ordNoList1 = new ArrayList<>();
//        List<List<Long>> ord = new ArrayList<>();
//        do {
//          oldDate = beforeDate;
//          beforeDate = beforeDate.minusDays(1);
//          ordNoList1 = ordMainDao.selectOrdnoByPatId(ntssUser.getFacilityCd()
//            , Long.parseLong(String.valueOf(dataKey.get("patId")))
//            , oldDate.toString().replace("/", "").replace("-", "")
//            , oldDate.toString().replace("/", "").replace("-", "")
//            , "0");
//          if (ordNoList1.size() != 0) {
//            ord.add(ordNoList1);
//          }
//          if (ord != null && ord.size() != 0 && ord.stream().filter(p -> !p.isEmpty()).collect(Collectors.toList()).size() != 0) {
//            break;
//          }
//        } while (!beforeDate.isBefore(afterDate));
//        if (ord.size() != 0) {
//          List<Long> ordNoListNew = new ArrayList<>();
//          ordNoListNew.add(Long.parseLong(String.valueOf(ord.get(0).get(0))));
//          dataKeyNew.put("ordNos", ordNoListNew);
//          dataKeyNew.put("ordNo", Long.parseLong(String.valueOf(ord.get(0).get(0))));
//        }
//        dataKeyNew.put(ReportConstant.ReportDataKey.DATE_FROM, LocalDate.now().toString().replace("/", "").replace("-", ""));
//        dataKeyNew.put(ReportConstant.ReportDataKey.treatDate, dataKey.get("date"));
//        String reStr = addOneMonth(dataKeyNew.get("fromDate").toString(), dataKey.get("functionCd").toString());
//        dataKeyNew.put(ReportConstant.ReportDataKey.DATE_TO, reStr);
//      }
      // 患者情報
//      else if (dataKey.get("functionCd").toString().equals("00701")) {
//        List<Long> patIds = new ArrayList<>();
//        patIds.add(Long.parseLong(String.valueOf(dataKey.get("patId"))));
//        dataKeyNew.put("patIds", patIds);
//        dataKeyNew.put("facilityCd", ntssUser.getFacilityCd());
//        LocalDate beforeDate;
//        LocalDate afterDate;
//        LocalDate oldDate;
//        DateTimeFormatter formatter;
//        String minusDate = minusOneMonth(dataKey.get("date").toString());
//        formatter = DateTimeFormatter.ofPattern("yyyyMMdd");
//        beforeDate = LocalDate.parse(dataKey.get("date").toString(), formatter);
//        afterDate = LocalDate.parse(minusDate, formatter);
//        List<Long> ordNoList1 = new ArrayList<>();
//        List<List<Long>> ord = new ArrayList<>();
//        do {
//          oldDate = beforeDate;
//          beforeDate = beforeDate.minusDays(1);
//          ordNoList1 = ordMainDao.selectOrdnoByPatId(ntssUser.getFacilityCd()
//            , Long.parseLong(String.valueOf(dataKey.get("patId")))
//            , oldDate.toString().replace("/", "").replace("-", "")
//            , oldDate.toString().replace("/", "").replace("-", "")
//            , "0");
//          if (ordNoList1.size() != 0) {
//            ord.add(ordNoList1);
//          }
//          if (ord != null && ord.size() != 0 && ord.stream().filter(p -> !p.isEmpty()).collect(Collectors.toList()).size() != 0) {
//            break;
//          }
//        } while (!beforeDate.isBefore(afterDate));
//        if (ord.size() != 0) {
//          List<Long> ordNoListNew = new ArrayList<>();
//          ordNoListNew.add(Long.parseLong(String.valueOf(ord.get(0).get(0))));
//          dataKeyNew.put("ordNos", ordNoListNew);
//          dataKeyNew.put("ordNo", Long.parseLong(String.valueOf(ord.get(0).get(0))));
//        }
//        dataKeyNew.put(ReportConstant.ReportDataKey.DATE_FROM, LocalDate.now().toString().replace("/", "").replace("-", ""));
//        dataKeyNew.put(ReportConstant.ReportDataKey.DATE, LocalDate.now().toString().replace("/", "").replace("-", ""));
//        dataKeyNew.put(ReportConstant.ReportDataKey.treatDate, LocalDate.now().toString().replace("/", "").replace("-", ""));
//        String reStr = addOneMonth(dataKeyNew.get("date").toString(), dataKey.get("functionCd").toString());
//        dataKeyNew.put(ReportConstant.ReportDataKey.DATE_TO, reStr);
//      }
//      // add #9558 機能帳票で正しく変数が引き渡されていない 杜天成 start
//      else if (dataKey.get("functionCd").toString().equals("02101") || dataKey.get("functionCd").toString().equals("02201")
//        || dataKey.get("functionCd").toString().equals("02801")|| dataKey.get("functionCd").toString().equals("01801")) {
//        dataKeyNew.put("facilityCd", ntssUser.getFacilityCd());
//        if(dataKey.get("patId") != null) {
//          List<Long> patIdnew = new ArrayList<>();
//          patIdnew.add(Long.parseLong(String.valueOf(dataKey.get("patId"))));
//          dataKeyNew.put("patIds",patIdnew);
//        }
//      }
//      // add #9558 機能帳票で正しく変数が引き渡されていない 杜天成 end
      // 装置設定
//      else if (dataKey.get("functionCd").toString().equals("01001")) {
//        List<Long> patIds = new ArrayList<>();
//        patIds.add(Long.parseLong(String.valueOf(dataKey.get("patId"))));
//        dataKeyNew.put("patIds", patIds);
//        dataKeyNew.put("facilityCd", ntssUser.getFacilityCd());
//        LocalDate beforeDate;
//        LocalDate afterDate;
//        LocalDate oldDate;
//        DateTimeFormatter formatter;
//        String minusDate = minusOneMonth(dataKey.get("date").toString());
//        formatter = DateTimeFormatter.ofPattern("yyyyMMdd");
//        beforeDate = LocalDate.parse(dataKey.get("date").toString(), formatter);
//        afterDate = LocalDate.parse(minusDate, formatter);
//        List<Long> ordNoList1 = new ArrayList<>();
//        List<List<Long>> ord = new ArrayList<>();
//        do {
//          oldDate = beforeDate;
//          beforeDate = beforeDate.minusDays(1);
//          ordNoList1 = ordMainDao.selectOrdnoByPatId(ntssUser.getFacilityCd()
//            , Long.parseLong(String.valueOf(dataKey.get("patId")))
//            , oldDate.toString().replace("/", "").replace("-", "")
//            , oldDate.toString().replace("/", "").replace("-", "")
//            , "0");
//          if (ordNoList1.size() != 0) {
//            ord.add(ordNoList1);
//          }
//          if (ord != null && ord.size() != 0 && ord.stream().filter(p -> !p.isEmpty()).collect(Collectors.toList()).size() != 0) {
//            break;
//          }
//        } while (!beforeDate.isBefore(afterDate));
//        if (ord.size() != 0) {
//          List<Long> ordNoListNew = new ArrayList<>();
//          ordNoListNew.add(Long.parseLong(String.valueOf(ord.get(0).get(0))));
//          dataKeyNew.put("ordNos", ordNoListNew);
//          dataKeyNew.put("ordNo", Long.parseLong(String.valueOf(ord.get(0).get(0))));
//        }
//        dataKeyNew.put(ReportConstant.ReportDataKey.DATE_FROM, LocalDate.now().toString().replace("/", "").replace("-", ""));
//        dataKeyNew.put(ReportConstant.ReportDataKey.DATE, LocalDate.now().toString().replace("/", "").replace("-", ""));
//        dataKeyNew.put(ReportConstant.ReportDataKey.treatDate, LocalDate.now().toString().replace("/", "").replace("-", ""));
//        String reStr = addOneMonth(dataKeyNew.get("date").toString(), dataKey.get("functionCd").toString());
//        dataKeyNew.put(ReportConstant.ReportDataKey.DATE_TO, reStr);
//      }
      // データリスト
//      else if (dataKey.get("functionCd").toString().equals("00801")) {
//        String patId = null;
//        if (null != dataKey.get("patId")) {
//          patId = dataKey.get("patId").toString();
//        }
//        List<Long> hospPatId = dataKey.get("patIds") == null ? new ArrayList<>() : (ArrayList) dataKey.get("patIds");
//        List<Long> patIdsByHospPatId = new ArrayList<>();
//        for (int index = 0; index < hospPatId.size(); index++) {
//          if (!StringUtils.isEmpty(patPersonalMainDao.selectPatIdByHospPatId(ntssUser.getFacilityCd(), String.valueOf(hospPatId.get(index)))) &&
//            !patIdsByHospPatId.contains(patPersonalMainDao.selectPatIdByHospPatId(ntssUser.getFacilityCd(), String.valueOf(hospPatId.get(index))))) {
//            patIdsByHospPatId.add(patPersonalMainDao.selectPatIdByHospPatId(ntssUser.getFacilityCd(), String.valueOf(hospPatId.get(index))));
//          }
//        }
//        if (patIdsByHospPatId.stream().filter(p -> p != null).collect(Collectors.toList()).size() != 0) {
//          dataKeyNew.put("patIds", patIdsByHospPatId);
//        }
//        List<Long> patIds00801 = dataKeyNew.get("patIds") == null ? new ArrayList<>() : (ArrayList) dataKeyNew.get("patIds");
//        List<Long> patIds00801Tmp = new ArrayList<>();
//        for (int index = 0; index < patIds00801.size(); index++) {
//          if (!StringUtils.isEmpty(patIds00801.get(index))) {
//            patIds00801Tmp.add(Long.parseLong(String.valueOf(patIds00801.get(index))));
//          }
//        }
//        dataKeyNew.put("patIds", patIds00801Tmp);
//        dataKeyNew.put("machineNos", dataKey.get("machineNos"));
//        List<Integer> patIds = null != dataKeyNew.get("patIds") ? (List<Integer>) dataKeyNew.get("patIds") : new ArrayList<>();
//        List<Long> machineList = null != dataKeyNew.get("machineNos") ? (List<Long>) dataKeyNew.get("machineNos") : new ArrayList<>();
//        if (report.getReportClass().equals(ReportConstant.ReportClass.MACHINE_REPORT)) {
//          if (machineList.size() <= 0) {
//            dataKeyNew.put("mas","選択中のレイアウト用ではありません");
//            return dataKeyNew;
//          }
//        } else {
//          if (machineList.size() > 0 || (patId == null && patIds.size() <= 0)) {
//            dataKeyNew.put("mas","選択中のレイアウト用ではありません");
//            return dataKeyNew;
//          }
//        }
//        LocalDate nowDate = LocalDate.now();
//        String nowYYYYMMDD = nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd"));
//        dataKeyNew.put("date", nowYYYYMMDD);
//        dataKeyNew.put("fromDate", nowYYYYMMDD);
//        dataKeyNew.put("toDate", nowYYYYMMDD);
//        dataKeyNew.put("facilityCd", ntssUser.getFacilityCd());
//      }
//      else
      // del #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe end
      // del #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe start
      // スケジュール表
//      if (dataKey.get("functionCd").toString().equals("00901")) {
        // del #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe start
//        dataKeyNew.put("facilityCd", ntssUser.getFacilityCd());
//        dataKeyNew.put("treatDate", dataKey.get("baseDate"));
        // del #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe end
//        List<Long> ordNoSList = new ArrayList<>();
//        List<Long> patIdNum = new ArrayList<>();
//        List<Long> ordNoNum = new ArrayList<>();
//        String patId = null;
//        if (null != dataKey.get("patId")) {
//          patId = dataKey.get("patId").toString();
//        }
        // add 11010 スケジュール表出力時の処理が不足している gjn start
//        // 機能帳票転送のbedCdsをbedGroupCdに変換するにはbed _ cdに変換する必要がある
//        List<Long> bedCdLists = new ArrayList<>();
//        List<Integer> bedCds = null != dataKey.get("bedCds") ? (List<Integer>) dataKey.get("bedCds") : new ArrayList<>();
//        if (bedCds != null && bedCds.size() > 0) {
//          List<MstRoomBedGroup> mstRoomBedGroupList = mstRoomBedGroupDao.selectByListBedGroupCd(bedCds, (String) dataKey.get("facilityCd"));
//          List<Long> finalBedCdSelect = new ArrayList<>();
//          mstRoomBedGroupList.forEach(f -> {
//            System.err.println(f.getBedList());
//            String bedList = f.getBedList();
//            if (!StringUtils.isEmpty(bedList) && !"null".equals(bedList)) {
//              if (bedList.contains("[") && bedList.contains("]")) {
//                // 角括弧を除去
//                bedList = bedList.replaceAll("^\\[|\\]$", "");
//                if (bedList.contains(",")) {
//                  String [] blArray = bedList.split(",");
//                  for (String s : blArray) {
//                    finalBedCdSelect.add(Long.parseLong(s.trim()));
//                  }
//                }
//              }
//            }
//          });
//          // bed_cdデウェイト
//          bedCdLists = finalBedCdSelect.stream().distinct().collect(Collectors.toList());
//        }
//        dataKeyNew.put("bedCds", bedCdLists);
//        List<Integer> kurList = null != dataKey.get("selectKurCd") ? (List<Integer>) dataKey.get("selectKurCd") : new ArrayList<>();
        // add #11973 日常点検一覧帳票が正常に出せない limingzhe start
//        List<Long> newKurCds = changeTypeNumtoLong(kurList);
//        dataKeyNew.put(ReportConstant.ReportDataKey.KUR_CDS, newKurCds);
        // add #11973 日常点検一覧帳票が正常に出せない limingzhe end
        // add 11010 スケジュール表出力時の処理が不足している gjn end
//        List<Integer> patIds = null != dataKey.get("patIds") ? (List<Integer>) dataKey.get("patIds") : new ArrayList<>();
//        if (null != patId) {
//          List<OrdMain> ordMain = ordMainDao.selectPatOrdMainByTreatDate(Long.parseLong(patId), ntssUser.getFacilityCd(), dataKey.get("treatDate").toString());
        // del #9558 機能帳票で正しく変数が引き渡されていない 2024.8.23 高 start
//          if (null != ordMain) {
//            ordNosList.addAll(ordMain);
//            List<Integer> ordMainSelectKurCdTmp = new ArrayList();
//            List<Integer> ordMainBedCdsTmp = new ArrayList();
//            for (int index = 0; index < ordMain.size(); index++) {
//              if ("0".equals(ordMain.get(index).getRstDialysisState())) {
//                // クールコード
//                if (!ordMainSelectKurCdTmp.contains(ordMain.get(index).getIndKurCd()) && ordMain.get(index).getIndKurCd() != 0) {
//                  ordMainSelectKurCdTmp.add(ordMain.get(index).getIndKurCd());
//                }
//                // ベッドコード
//                if (!ordMainBedCdsTmp.contains(ordMain.get(index).getIndBedCd()) && ordMain.get(index).getIndBedCd() != 0) {
//                  ordMainBedCdsTmp.add(ordMain.get(index).getIndBedCd());
//                }
//              } else {
//                // クールコード
//                if (!ordMainSelectKurCdTmp.contains(ordMain.get(index).getRstKurCd()) && ordMain.get(index).getRstKurCd() != 0) {
//                  ordMainSelectKurCdTmp.add(ordMain.get(index).getRstKurCd());
//                }
//                // ベッドコード
//                if (!ordMainBedCdsTmp.contains(ordMain.get(index).getRstBedCd()) && ordMain.get(index).getRstBedCd() != 0) {
//                  ordMainBedCdsTmp.add(Integer.parseInt(String.valueOf(ordMain.get(index).getRstBedCd())));
//                }
//              }
//            }
//            dataKeyNew.put("selectKurCd", ordMainSelectKurCdTmp);
//            dataKeyNew.put("bedCds", ordMainBedCdsTmp);
//          }
        // del #9558 機能帳票で正しく変数が引き渡されていない 2024.8.23 高 end
//          ordNoSList = ordMainDao.selectOrdnoByPatId(ntssUser.getFacilityCd()
//            , Long.parseLong(String.valueOf(dataKey.get("patId")))
//            , dataKey.get("treatDate").toString().replace("/", "").replace("-", "")
//            , dataKey.get("treatDate").toString().replace("/", "").replace("-", "")
//            , null);
//          patIdNum.add(Long.parseLong(String.valueOf(dataKey.get("patId"))));
//          dataKeyNew.put("patIds", patIdNum);
//          if (ordNoSList.size() != 0) {
//            for (int indexS = 0; indexS < ordNoSList.size(); indexS++) {
//              ordNoNum.add(Long.parseLong(String.valueOf(ordNoSList.get(indexS))));
//            }
//            dataKeyNew.put(ReportConstant.ReportDataKey.ORD_NOS, ordNoNum);
//          }
//        } else {
//          //患者未選択時
//          if (!StringUtils.isEmpty(dataKey.get("baseDate"))) {
//            List<Long> patIdS = new ArrayList<>();
//            List<Long> ordNoS = new ArrayList<>();
//            List<OrdMain> ordMain = ordMainDao.selectByBaseforPatAndOrd(ntssUser.getFacilityCd(), dataKey.get("baseDate").toString());
            // del #9558 機能帳票で正しく変数が引き渡されていない 2024.8.23 高 start
//            if (null != ordMain) {
//              ordNosList.addAll(ordMain);
//              List<Integer> ordMainSelectKurCdTmp = new ArrayList();
//              List<Integer> ordMainBedCdsTmp = new ArrayList();
//              for (int index = 0; index < ordMain.size(); index++) {
//                if ("0".equals(ordMain.get(index).getRstDialysisState())) {
//                  // クールコード
//                  if (!ordMainSelectKurCdTmp.contains(ordMain.get(index).getIndKurCd()) && ordMain.get(index).getIndKurCd() != 0) {
//                    ordMainSelectKurCdTmp.add(ordMain.get(index).getIndKurCd());
//                  }
//                  // ベッドコード
//                  if (!ordMainBedCdsTmp.contains(ordMain.get(index).getIndBedCd()) && ordMain.get(index).getIndBedCd() != 0) {
//                    ordMainBedCdsTmp.add(ordMain.get(index).getIndBedCd());
//                  }
//                } else {
//                  // クールコード
//                  if (!ordMainSelectKurCdTmp.contains(ordMain.get(index).getRstKurCd()) && ordMain.get(index).getRstKurCd() != 0) {
//                    ordMainSelectKurCdTmp.add(ordMain.get(index).getRstKurCd());
//                  }
//                  // ベッドコード
//                  if (!ordMainBedCdsTmp.contains(ordMain.get(index).getRstBedCd()) && ordMain.get(index).getRstBedCd() != 0) {
//                    ordMainBedCdsTmp.add(Integer.parseInt(String.valueOf(ordMain.get(index).getRstBedCd())));
//                  }
//                }
//              }
//              dataKeyNew.put("selectKurCd", ordMainSelectKurCdTmp);
//              dataKeyNew.put("bedCds", ordMainBedCdsTmp);
//            }
            // del #9558 機能帳票で正しく変数が引き渡されていない 2024.8.23 高 end
//            for (int index = 0; index < patIds.size(); index++) {
//              if (patIds.get(index) != null) {
//                patIdNum.add(Long.parseLong(String.valueOf(patIds.get(index))));
//              }
//            }
//            // add 11010 スケジュール表出力時の処理が不足している gjn start
//            List<OrdMain> ord = ordMainDao.selectAllByPatIdAndTreatDate(dataKey.get("facilityCd").toString(),patIdNum, dataKey.get("baseDate").toString().replace("/", "").replace("-", "")
//              , dataKey.get("toDate").toString().replace("/", "").replace("-", ""));
//            for (int index = 0; index < patIdNum.size(); index++) {
//              for (int indexS = 0; indexS < ord.size(); indexS++) {
//                if (patIdNum.get(index).equals(ord.get(indexS).getPatId())) {
//                  if (ord.get(indexS).getIndBedCd() != 0 && !StringUtils.isEmpty(ord.get(indexS).getIndBedCd()) && bedCdLists.contains(Long.parseLong(String.valueOf(ord.get(indexS).getIndBedCd())))) {
//                    if (ord.get(indexS).getIndKurCd() != 0 && kurList.contains(ord.get(indexS).getIndKurCd())) {
//                      if (!patIdS.contains(Long.parseLong(String.valueOf(patIdNum.get(index))))) {
//                        patIdS.add(Long.parseLong(String.valueOf(patIdNum.get(index))));
//                      }
//                    }
//                  } else if (ord.get(indexS).getIndBedCd() == 0 && !StringUtils.isEmpty(ord.get(indexS).getRstBedCd()) && ord.get(indexS).getRstBedCd() != 0 && bedCdLists.contains(ord.get(indexS).getRstBedCd())) {
//                    if (ord.get(indexS).getRstKurCd() != 0 && kurList.contains(ord.get(indexS).getRstKurCd())) {
//                      if (!patIdS.contains(Long.parseLong(String.valueOf(patIdNum.get(index))))) {
//                        patIdS.add(Long.parseLong(String.valueOf(patIdNum.get(index))));
//                      }
//                    }
//                  }
//                }
//              }
//            }
//            // add 11010 スケジュール表出力時の処理が不足している gjn end
            // del 11010 スケジュール表出力時の処理が不足している gjn start
//            for (int index = 0; index < patIdNum.size(); index++) {
//              ordNoSList = ordMainDao.selectOrdnoByPatId(dataKey.get("facilityCd").toString()
//                , Long.parseLong(String.valueOf(patIdNum.get(index)))
//                , dataKey.get("baseDate").toString().replace("/", "").replace("-", "")
//                , dataKey.get("toDate").toString().replace("/", "").replace("-", "")
//                , null);
//              for (int indexS = 0; indexS < ordNoSList.size(); indexS++) {
//                patIdS.add(Long.parseLong(String.valueOf(patIdNum.get(index))));
//                ordNoS.add(Long.parseLong(String.valueOf(ordNoSList.get(indexS))));
//              }
//            }
            // del 11010 スケジュール表出力時の処理が不足している gjn end

            // mod 11010 スケジュール表出力時の処理が不足している gjn start
//            if (patIdS.size() != 0) {
//              dataKeyNew.put("patIds", patIdS);
//            }
//            if (patIdS.size() != 0) {
//              dataKeyNew.put("patIds", patIdS);
//              dataKeyNew.put("ordNos", ordNoS);
//            }
            // mod 11010 スケジュール表出力時の処理が不足している gjn end
//          }
//        }
        // del #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe start
//        dataKeyNew.put("date", dataKey.get("baseDate"));
//        dataKeyNew.put("fromDate", dataKey.get("baseDate"));
        // del #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe end
        // del #9558 機能帳票で正しく変数が引き渡されていない 2024.8.23 高 start
//        dataKeyNew.put("toDate", dataKey.get("baseDate"));
        // del #9558 機能帳票で正しく変数が引き渡されていない 2024.8.23 高 end
//      }
      // 治療状況リスト
//      else if (dataKey.get("functionCd").toString().equals("01101")) {
//		    // del #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe start
//        //dataKeyNew.put("treatDate",dataKey.get("date"));
//		    // del #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe end
//        List<Long> patIds01101 = dataKey.get("patIds") == null ? new ArrayList<>() : (ArrayList) dataKey.get("patIds");
//        List<Long> ordNos01101 = dataKey.get("ordNos") == null ? new ArrayList<>() : (ArrayList) dataKey.get("ordNos");
//        List<Long> patIds01101Tmp = new ArrayList<>();
//        List<Long> ordNos01101Tmp = new ArrayList<>();
//        for (int index = 0; index < patIds01101.size(); index++) {
//          if (!StringUtils.isEmpty(patIds01101.get(index))) {
//            patIds01101Tmp.add(Long.parseLong(String.valueOf(patIds01101.get(index))));
//            ordNos01101Tmp.add(Long.parseLong(String.valueOf(ordNos01101.get(index))));
//          }
//        }
//        dataKeyNew.put("patIds", patIds01101Tmp);
//        dataKeyNew.put("ordNos", ordNos01101Tmp);
//      }
      // del #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe end
      // del #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe start
      // 治療状況マップ
//      else if (dataKey.get("functionCd").toString().equals("01201")) {
//        dataKeyNew.put("treatDate",dataKey.get("date"));
//        List<Long> patIds01201 = dataKey.get("patIds") == null ? new ArrayList<>() : (ArrayList) dataKey.get("patIds");
//        List<Long> ordNos01201 = dataKey.get("ordNos") == null ? new ArrayList<>() : (ArrayList) dataKey.get("ordNos");
//        List<Long> patIds01201Tmp = new ArrayList<>();
//        List<Long> ordNos01201Tmp = new ArrayList<>();
//        for (int index = 0; index < patIds01201.size(); index++) {
//          if (!StringUtils.isEmpty(patIds01201.get(index))) {
//            patIds01201Tmp.add(Long.parseLong(String.valueOf(patIds01201.get(index))));
//            ordNos01201Tmp.add(Long.parseLong(String.valueOf(ordNos01201.get(index))));
//          }
//        }
//        dataKeyNew.put("patIds", patIds01201Tmp);
//        dataKeyNew.put("ordNos", ordNos01201Tmp);
//      }
      // チェックリスト
//      else if (dataKey.get("functionCd").toString().equals("01501")) {
//        dataKeyNew.put("treatDate",dataKey.get("date"));
//        List<Long> patIds01501 = dataKey.get("patIds") == null ? new ArrayList<>() : (ArrayList) dataKey.get("patIds");
//        List<Long> ordNos01501 = dataKey.get("ordNos") == null ? new ArrayList<>() : (ArrayList) dataKey.get("ordNos");
//        List<Long> patIds01501Tmp = new ArrayList<>();
//        List<Long> ordNos01501Tmp = new ArrayList<>();
//        for (int index = 0; index < patIds01501.size(); index++) {
//          if (!StringUtils.isEmpty(patIds01501.get(index))) {
//            patIds01501Tmp.add(Long.parseLong(String.valueOf(patIds01501.get(index))));
//            ordNos01501Tmp.add(Long.parseLong(String.valueOf(ordNos01501.get(index))));
//          }
//        }
//        dataKeyNew.put("patIds", patIds01501Tmp);
//        dataKeyNew.put("ordNos", ordNos01501Tmp);
//        String bedCd = null != dataKey.get("bedCd") ? dataKey.get("bedCd").toString() : null;
//        ArrayList<Long> machineList = new ArrayList<>();
//        Long machineNo = null;
//        if (bedCd != null) {
//          MstBed mstBed = mstBedDao.selectByBedCd(Long.valueOf(bedCd), null, null);
//          if (mstBed != null) {
//            machineNo = mstBed.getMachineNo();
//            machineList.add(machineNo);
//          }
//        } else {
//          List<Integer> listTemp = new ArrayList();
//          if (dataKey.get("bedCds") != null) {
//            ArrayList<Integer> bedCds = (ArrayList) dataKey.get("bedCds");
//            for (int i = 0; i < bedCds.size(); i++) {
//              if (!listTemp.contains(bedCds.get(i))) {
//                listTemp.add(bedCds.get(i));
//              }
//            }
//            for (Integer bedcd : listTemp) {
//              if (bedcd != null) {
//                MstBed mstBed = mstBedDao.selectByBedCd(Long.valueOf(bedcd), null, null);
//                if (mstBed != null) {
//                  machineNo = mstBed.getMachineNo();
//                  machineList.add(machineNo);
//                }
//              }
//            }
//          }
//        }
//        dataKeyNew.put("machineNos", machineList);
//      }
      // 患者カレンダー
//      else if (dataKey.get("functionCd").toString().equals("02401")) {
//        List<Long> ordNoList = new ArrayList<>();
//        List<Long> patIdNoS = new ArrayList();
//        List<Long> ordNoNoS = new ArrayList();
//        dataKeyNew.put(ReportConstant.ReportDataKey.treatDate, dataKey.get("date"));
//        ordNoList = ordMainDao.selectOrdnoByPatId(dataKey.get("facilityCd").toString()
//          , Long.parseLong(String.valueOf(dataKey.get("patId")))
//          , dataKey.get("fromDate").toString().replace("/", "").replace("-", "")
//          , dataKey.get("toDate").toString().replace("/", "").replace("-", "")
//          , null);
//        patIdNoS.add(Long.parseLong(String.valueOf(dataKey.get("patId"))));
//        if (ordNoList.size() != 0) {
//          ordNoNoS.add(Long.parseLong(String.valueOf(ordNoList.get(ordNoList.size() - 1))));
//        }
//        dataKeyNew.put("patIds", patIdNoS);
//        dataKeyNew.put("ordNos", ordNoNoS);
//        if (ordNoList.size() != 0) {
//          dataKeyNew.put("ordNo", Long.parseLong(String.valueOf(ordNoList.get(ordNoList.size() - 1))));
//        }
//      }
      // del #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe end
      // 体重測定
      if (dataKey.get("functionCd").toString().equals("01301")){
        String patId = null != dataKey.get(ReportConstant.ReportDataKey.PAT_ID) ? dataKey.get(ReportConstant.ReportDataKey.PAT_ID).toString() : null;
        List<Long> patIds = null != dataKey.get(ReportConstant.ReportDataKey.PAT_IDS) ? (List<Long>) dataKey.get(ReportConstant.ReportDataKey.PAT_IDS) : new ArrayList<>();
        if (patIds.size() == 0 && null != patId) {
          patIds.add(Long.parseLong(patId));
        }
        List<Long> ordNoS = new ArrayList<>();
        List<Long> patIdsbyordNoS = new ArrayList<>();
        for (int index = 0; index < patIds.size(); index ++ ){
          Long pId = Long.parseLong(String.valueOf(patIds.get(index)));
          List<Long> ordNoSList = ordMainDao.selectOrdnoByPatId(ntssUser.getFacilityCd(), pId, dataKey.get("fromDate").toString(), dataKey.get("toDate").toString(),null);
          for (int indexS = 0; indexS < ordNoSList.size(); indexS ++) {
            ordNoS.add(Long.parseLong(String.valueOf(ordNoSList.get(indexS))));
            patIdsbyordNoS.add(pId);
          }
        }
        if(ordNoS.size()>0){
          dataKeyNew.put(ReportConstant.ReportDataKey.PAT_IDS, patIdsbyordNoS);
          dataKeyNew.put(ReportConstant.ReportDataKey.ORD_NOS, ordNoS);
        }
      }
      // del #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe start
      // 体重計測定記録
//      else if (dataKey.get("functionCd").toString().equals("01401")){
//        if (dataKey.get(ReportConstant.ReportDataKey.ORD_NOS) != null) {
//          List<Long> ordNos = (List<Long>) dataKey.get(ReportConstant.ReportDataKey.ORD_NOS);
//          List<Long> newOrdNos = new ArrayList<>();
//          for (int i = 0; i < ordNos.size(); i++) {
//            if (!StringUtils.isEmpty(ordNos.get(i))) {
//              newOrdNos.add(Long.parseLong(String.valueOf(ordNos.get(i))));
//            } else {
//              newOrdNos.add(ordNos.get(i));
//            }
//          }
//          dataKeyNew.put(ReportConstant.ReportDataKey.ORD_NOS, newOrdNos);
//        }
//      }
      // del #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe end
      // P-Ca9分割グラフ
      else if (dataKey.get("functionCd").toString().equals("03901")){
        // add #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe start
        dataKey.put(ReportConstant.ReportDataKey.FACILITY_CD, ntssUser.getFacilityCd());
        // add #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe end
        dataKeyNew.put(ReportConstant.ReportDataKey.FACILITY_CD, ntssUser.getFacilityCd());
      }

      // add #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe start
      // mod #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe start
//      if(dataKey.containsKey("dialysisDate") && !StringUtils.isEmpty(dataKey.get("dialysisDate"))){
//        String rstDiaysisState = null;
//        if(dataKey.get("functionCd").toString().equals("00401")
//          || dataKey.get("functionCd").toString().equals("00701")
//          || dataKey.get("functionCd").toString().equals("01001")
//          || dataKey.get("functionCd").toString().equals("01601")
//          || (dataKey.get("functionCd").toString().equals("01801") && dataKey.get(ReportConstant.ReportDataKey.PAT_ID) != null)
//          || (dataKey.get("functionCd").toString().equals("02101") && dataKey.get(ReportConstant.ReportDataKey.PAT_ID) != null)
//          || (dataKey.get("functionCd").toString().equals("02201") && dataKey.get(ReportConstant.ReportDataKey.PAT_ID) != null)
//          || dataKey.get("functionCd").toString().equals("02401")
//          || dataKey.get("functionCd").toString().equals("02701")
//          || (dataKey.get("functionCd").toString().equals("02801") && dataKey.get(ReportConstant.ReportDataKey.PAT_ID) != null)
//          || dataKey.get("functionCd").toString().equals("02901")
//          || dataKey.get("functionCd").toString().equals("03001")
//          || (dataKey.get("functionCd").toString().equals("03901") && dataKey.get(ReportConstant.ReportDataKey.PAT_ID) != null)
//        ){
//          rstDiaysisState = "0";
//        }
//        if(dataKey.get(ReportConstant.ReportDataKey.PAT_ID) != null){
//          // mod #11679 複数患者帳票で「透析条件.補液量」が出ない 20250527 limingzhe start
////          Long ordNo = getLatestOrdNo(dataKey.get("dialysisDate").toString(),
////            dataKey.get(ReportConstant.ReportDataKey.FACILITY_CD).toString(),
////            Long.parseLong(String.valueOf(dataKey.get(ReportConstant.ReportDataKey.PAT_ID))),
////            rstDiaysisState);
//          Long ordNo = -1l;
//          if(dataKey.get("functionCd").toString().equals("01801")) {
//            OrdMain ordMain = ordMainDao.selectRstOrdNoByBaseDate(Long.parseLong(String.valueOf(dataKey.get(ReportConstant.ReportDataKey.PAT_ID))),
//              dataKey.get(ReportConstant.ReportDataKey.FACILITY_CD).toString(),
//              dataKey.get("dialysisDate").toString());
//            if(ordMain != null) ordNo = ordMain.getOrdNo();
//          }
//          else {
//            ordNo = getLatestOrdNo(dataKey.get("dialysisDate").toString(),
//              dataKey.get(ReportConstant.ReportDataKey.FACILITY_CD).toString(),
//              Long.parseLong(String.valueOf(dataKey.get(ReportConstant.ReportDataKey.PAT_ID))),
//              rstDiaysisState);
//          }
//          // mod #11679 複数患者帳票で「透析条件.補液量」が出ない 20250527 limingzhe end
//          dataKeyNew.put(ReportConstant.ReportDataKey.ORD_NO, ordNo);
//        }else{
//          List<Long> patIds = (List<Long>) dataKeyNew.get(ReportConstant.ReportDataKey.PAT_IDS);
//          Map<String, List<Long>> map = getLatestOrdNos(dataKey.get("dialysisDate").toString(),
//            dataKey.get(ReportConstant.ReportDataKey.FACILITY_CD).toString(),
//            patIds,
//            rstDiaysisState);
//          dataKeyNew.put(ReportConstant.ReportDataKey.PAT_IDS, map.get(ReportConstant.ReportDataKey.PAT_IDS));
//          dataKeyNew.put(ReportConstant.ReportDataKey.ORD_NOS, map.get(ReportConstant.ReportDataKey.ORD_NOS));
//        }
//      }
//      if (dataKey.get("bedCds") != null) {
//        if (!dataKey.get("functionCd").toString().equals("00901")) {
//          List<Long> newbedCds = changeTypeNumtoLong((List<Integer>) dataKey.get("bedCds"));
//          dataKeyNew.put("bedCds", newbedCds);
//        }
//      }
      getOrdPara(dataKey, dataKeyNew);
      // mod #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe end
      // add #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe end

      // add #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe start
      if(!dataKey.containsKey(ReportConstant.ReportDataKey.KUR_CDS)){
        List<String> functionCds = Stream.of("01101", "01201", "01501", "01801", "02101", "02201", "02801", "03101", "03201", "03301", "03401", "03701", "03901").toList();
        if (functionCds.contains(dataKey.get("functionCd").toString())
          && !dataKey.containsKey(ReportConstant.ReportDataKey.PAT_ID)
          && !dataKey.containsKey("mainte_no")
        ) {
          List<Long> listKurCd = new ArrayList<>();
          List<MstKur> kurAll = mstKurDao.selectByFacilityCd(SelectOptions.get(), dataKey.get(ReportConstant.ReportDataKey.FACILITY_CD).toString(), "0");
          for (int i = 0; i < kurAll.size(); i++) {
            listKurCd.add(Long.parseLong(String.valueOf(kurAll.get(i).getKurCd())));
          }
          dataKey.put(ReportConstant.ReportDataKey.KUR_CDS, listKurCd);
        }
      }
      if(!dataKey.containsKey(ReportConstant.ReportDataKey.BED_CDS)){
        List<String> functionCds = Stream.of("01101", "01201", "01501", "01801", "02101", "02201", "02801", "03101", "03201", "03301", "03401", "03701", "03901").toList();
        if (functionCds.contains(dataKey.get("functionCd").toString())
          && !dataKey.containsKey(ReportConstant.ReportDataKey.PAT_ID)
          && !dataKey.containsKey("mainte_no")
        ) {
          List<Long> listBedCd = new ArrayList<>();
          List<MstBed> bedAll = mstBedDao.selectByFacilityCdMachineNo(dataKey.get(ReportConstant.ReportDataKey.FACILITY_CD).toString());
          for (int i = 0; i < bedAll.size(); i++) {
            listBedCd.add(bedAll.get(i).getBedCd());
          }
          dataKey.put(ReportConstant.ReportDataKey.BED_CDS, listBedCd);
        }
      }
      // add #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe end
    }

    // add #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe start
    dataKey.putAll(searchReportSettingForDataKey(String.valueOf(dataKey.getOrDefault(ReportConstant.ReportDataKey.FACILITY_CD, "")), reportCd, dataKey));
    // add #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe end

    //ordNosListを使用してdataKeyにkurCdList、bedCdListString、treatDateを追加してみてください
    final String kurl = "kurCdList";
    final String bed = "bedCdListString";
    final String treatDate = "treatDate";
    if (dataKey.get(kurl) == null && (ordNosList != null && ordNosList.size() > 0)) {
      Map<String, String> kurCdList = new HashMap<>();
      Set<String> bedNameList = new HashSet<>();
      List<String> treatDateList = new ArrayList<>();
      for (OrdMain ordMain : ordNosList) {
        if (ordMain != null) {
          bedNameList.add(ordMain.getIndBedName());
          if (ordMain.getIndKurCd() != null) {
            kurCdList.put(ordMain.getIndKurCd().toString(), ordMain.getIndKurName());
          } else if (ordMain.getRstKurCd() != null) {
            kurCdList.put(ordMain.getRstKurCd().toString(), ordMain.getRstKurName());
          } else {
            kurCdList.put("-0", "未指定");
          }
          treatDateList.add(ordMain.getTreatDate());
        }
      }
      List<String> treatDateSList = new ArrayList<String>();
      for (int i = 0; i < treatDateList.size(); i++) {
        if (treatDateList.get(i) != null) {
          treatDateSList.add(treatDateList.get(i));
        }
      }
      if (treatDateSList.size() > 0) {
        SimpleDateFormat fromDateFormat = new SimpleDateFormat("yyyyMMdd");
        SimpleDateFormat toDateFormat = new SimpleDateFormat("yyyy/MM/dd");
        Date treatDate1;
        try {
          treatDate1 = fromDateFormat.parse(treatDateSList.get(0));
        } catch (ParseException e) {
          throw new RuntimeException(e);
        }
        dataKeyNew.put(treatDate, toDateFormat.format(treatDate1));
        dataKeyNew.put("treat_date", toDateFormat.format(treatDate1));
      }
    }

    // add #11256 機能帳票の印刷情報対応① limingzhe start
    // 1日指定日
    if (dataKeyNew.containsKey(ReportConstant.ReportDataKey.DATE) && !StringUtils.isEmpty(dataKeyNew.get(ReportConstant.ReportDataKey.DATE))) {
      dataKeyNew.put("specifyDate", dataKeyNew.get(ReportConstant.ReportDataKey.DATE).toString().replace("/", "").replace("-", ""));
    }
    // 期間
    if (dataKeyNew.containsKey(ReportConstant.ReportDataKey.DATE_FROM) && !StringUtils.isEmpty(dataKeyNew.get(ReportConstant.ReportDataKey.DATE_FROM))) {
      String fromDate = dataKeyNew.get(ReportConstant.ReportDataKey.DATE_FROM).toString().replace("/", "").replace("-", "");
      if(dataKeyNew.containsKey(ReportConstant.ReportDataKey.DATE_TO) && !StringUtils.isEmpty(dataKeyNew.get(ReportConstant.ReportDataKey.DATE_TO))){
        String toDate = dataKeyNew.get(ReportConstant.ReportDataKey.DATE_TO).toString().replace("/", "").replace("-", "");
        String start = fromDate.substring(0,4) + "年" + fromDate.substring(4,6) + "月" + fromDate.substring(6)+ "日";
        String end =  toDate.substring(0,4) + "年" + toDate.substring(4,6) + "月" + toDate.substring(6)+ "日";
        dataKeyNew.put(ReportConstant.ReportDataKey.period,start+"～"+end);
      }
    }
    // 週数
    String dateCalWeek = "";
    if (dataKeyNew.containsKey("baseDate") && !StringUtils.isEmpty(dataKeyNew.get("baseDate"))) {
      dateCalWeek = dataKeyNew.get("baseDate").toString().replace("/","").replace("-","");
    }
    if(dateCalWeek.equals("") && dataKeyNew.containsKey(ReportConstant.ReportDataKey.treatDate) && !StringUtils.isEmpty(dataKeyNew.get(ReportConstant.ReportDataKey.treatDate))){
      if(dataKeyNew.containsKey("functionCd") && (dataKeyNew.get("functionCd").toString().equals("00601") || dataKeyNew.get("functionCd").toString().equals("00901"))){
        dateCalWeek = dataKeyNew.get(ReportConstant.ReportDataKey.treatDate).toString().replace("/","").replace("-","");
      }
    }
    if(dateCalWeek.equals("") && dataKeyNew.containsKey(ReportConstant.ReportDataKey.DATE) && !StringUtils.isEmpty(dataKeyNew.get(ReportConstant.ReportDataKey.DATE))){
      dateCalWeek = dataKeyNew.get(ReportConstant.ReportDataKey.DATE).toString().replace("/","").replace("-","");
    }
    if(dateCalWeek.length()>0){
      String year = dateCalWeek.substring(0, 4);
      String month = dateCalWeek.substring(4, 6);
      String day = dateCalWeek.substring(6,8);
      Calendar calendar =Calendar.getInstance();
      calendar.setFirstDayOfWeek(Calendar.MONDAY);
      calendar.set(Calendar.YEAR, Integer.valueOf(year));
      calendar.set(Calendar.MONTH, Integer.valueOf(month) - 1);
      calendar.set(Calendar.DAY_OF_MONTH, Integer.valueOf(day));
      int week = calendar.get(Calendar.WEEK_OF_MONTH);
      dataKeyNew.put(ReportConstant.ReportDataKey.weeks,week+"週目");
    }
    // add #11256 機能帳票の印刷情報対応① limingzhe end
    // add #10526 クラス「処方情報」の「保険者番号」等に一桁づつ出力するデータセットを追加 sunsy start
    // mod #10526 クラス「処方情報」の「保険者番号」等に一桁づつ出力するデータセットを追加 2025/08/18 sunsy start
//    if (dataKey.containsKey("functionCd") && !dataKey.get("functionCd").toString().equals("02901")) {
    if (dataKey.containsKey("functionCd") && !dataKey.get("functionCd").toString().equals("02901") && dataKey.get("patId") != null) {
    // mod #10526 クラス「処方情報」の「保険者番号」等に一桁づつ出力するデータセットを追加 2025/08/18  sunsy end
      if (!StringUtils.isEmpty(dataKey.get("fromDate")) && !StringUtils.isEmpty(dataKey.get("toDate"))) {
        // del #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe start
//        List<String> prescriptionClassList = new ArrayList<String>(Arrays.asList("1", "2"));
//        dataKey.put("prescriptionClassList", prescriptionClassList);
        // del #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe end
        List<OrdPrescription> ordPrescriptionList = ordPrescriptionDao.selectResultByPatIdAndDateFromTo(
          Long.parseLong(String.valueOf(dataKey.get("patId"))),
          ntssUser.getFacilityCd(),
          dataKey.get("fromDate").toString().replace("/", "").replace("-", ""),
          dataKey.get("toDate").toString().replace("/", "").replace("-", ""),
          // mod #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe start
          //prescriptionClassList
          (List<String>)dataKey.get("prescriptionClassList")
          // mod #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe end
        );
        List<Long> ordPrescriptionNos = new ArrayList<>();
        for (OrdPrescription rx : ordPrescriptionList) {
          ordPrescriptionNos.add(rx.getOrdPrescriptionNo());
        }
        dataKeyNew.put(ReportConstant.ReportDataKey.ORD_PRESCRIPTION_NOS, ordPrescriptionNos);
      }
    }
    // add #10526 クラス「処方情報」の「保険者番号」等に一桁づつ出力するデータセットを追加 sunsy end

    //デフォルトプリンタの設定
    Long defaulPrint = null;
    if (StringUtils.isEmpty(request.getTargetPrinter())) {
      if (StringUtils.isEmpty(defaulPrint)) {
        List<FacilitySettingInfo> settingInfoList = mstFacilitySettingDao.selectFacilitySetting(ntssUser.getFacilityCd(), CoreConstant.FacilitySettingNo.DEFAULT_PRINTER);
        if (null != settingInfoList && settingInfoList.size() > 0 && null != settingInfoList.get(0).getValue()) {
          String defaulPrinter = settingInfoList.get(0).getValue();
          request.setTargetPrinter(Long.valueOf(defaulPrinter));
        }
      } else {
        request.setTargetPrinter(defaulPrint);
      }
    }
    // mod #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe start
//    String reportType = "";
//    if (report.getReportClass().equals(ReportConstant.ReportClass.DIALYSIS_REPORT)) {
//      reportType = "治療経過表";
//    } else if (report.getReportClass().equals(ReportConstant.ReportClass.ONE_PATIENT_REPORT)) {
//      reportType = "単患者帳票";
//    } else if (report.getReportClass().equals(ReportConstant.ReportClass.MULTIPLE_PATIENT_REPORT)) {
//      reportType = "複数患者帳票";
//    } else if (report.getReportClass().equals(ReportConstant.ReportClass.PREPARATION_LIST_REPORT)) {
//      reportType = "準備リスト";
//    } else if (report.getReportClass().equals(ReportConstant.ReportClass.DISTRIBUTION_LIST_BED_REPORT)) {
//      reportType = "配布リスト(ベッド)";
//    } else if (report.getReportClass().equals(ReportConstant.ReportClass.DISTRIBUTION_LIST_GOODS_REPORT)) {
//      reportType = "配布リスト(物品)";
//    } else if (report.getReportClass().equals(ReportConstant.ReportClass.MACHINE_REPORT)) {
//      reportType = "装置帳票";
//    } else if (report.getReportClass().equals(ReportConstant.ReportClass.LABEL_REPORT)) {
//      reportType = "ラベル";
//    } else if (report.getReportClass().equals(ReportConstant.ReportClass.INTRODUCTION_REPORT)) {
//      reportType = "紹介状";
//    } else if (report.getReportClass().equals(ReportConstant.ReportClass.ONE_TOTAL_REPORT)) {
//      reportType = "単集計";
//    } else if (report.getReportClass().equals(ReportConstant.ReportClass.MULTI_TOTAL_REPORT)) {
//      reportType = "複数集計";
//    }
    String reportType = getReportClassName(report.getReportClass());
    // mod #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe end

    if (!StringUtils.isEmpty(dataKey.get("functionCd"))) {
      if (dataKey.get("functionCd").toString().equals("00401")) {
        dataKeyNew.put("screenName", "患者経過総合ビューア");
      } else if (dataKey.get("functionCd").toString().equals("00601")) {
        dataKeyNew.put("screenName", "治療記録");
      } else if (dataKey.get("functionCd").toString().equals("00701")) {
        dataKeyNew.put("screenName", "患者情報");
      } else if (dataKey.get("functionCd").toString().equals("00801")) {
        dataKeyNew.put("screenName", "データリスト");
      } else if (dataKey.get("functionCd").toString().equals("00901")) {
        dataKeyNew.put("screenName", "スケジュール表");
      } else if (dataKey.get("functionCd").toString().equals("01001")) {
        dataKeyNew.put("screenName", "装置設定");
      } else if (dataKey.get("functionCd").toString().equals("01101")) {
        dataKeyNew.put("screenName", "治療状況リスト");
      } else if (dataKey.get("functionCd").toString().equals("01201")) {
        dataKeyNew.put("screenName", "治療状況マップ");
      } else if (dataKey.get("functionCd").toString().equals("01301")) {
        if (dataKey.get("patId") != null) {
          dataKeyNew.put("screenName", "体重測定(個別)");
        } else {
          dataKeyNew.put("screenName", "体重測定(一覧)");
        }
      } else if (dataKey.get("functionCd").toString().equals("01401")) {
        dataKeyNew.put("screenName", "体重計測定記録");
      } else if (dataKey.get("functionCd").toString().equals("01501")) {
        dataKeyNew.put("screenName", "チェックリスト");
      } else if (dataKey.get("functionCd").toString().equals("01601")) {
        dataKeyNew.put("screenName", "観察記録");
      } else if (dataKey.get("functionCd").toString().equals("01801")) {
        if (dataKey.get("patId") != null) {
          if(dataKey.containsKey("selectExamSetCd") && dataKey.containsKey("selectExamGraphCd")){
            dataKeyNew.put("screenName", "検査結果(個別)");
          }
          else {
            dataKeyNew.put("screenName", "検査結果(特殊)");
          }
        } else {
          dataKeyNew.put("screenName", "検査結果(一覧)");
        }
      } else if (dataKey.get("functionCd").toString().equals("02101")) {
        if (dataKey.get("patId") == null) {
          dataKeyNew.put("screenName", "検査依頼(個別)");
        } else {
          dataKeyNew.put("screenName", "検査依頼(一覧)");
        }
      } else if (dataKey.get("functionCd").toString().equals("02201")) {
        if (dataKey.get("patId") == null) {
          dataKeyNew.put("screenName", "一般撮影検査依頼(一覧)");
        } else {
          dataKeyNew.put("screenName", "一般撮影検査依頼(個別)");
        }
      } else if (dataKey.get("functionCd").toString().equals("02301")) {
        dataKeyNew.put("screenName", "患者グループ");
      } else if (dataKey.get("functionCd").toString().equals("02401")) {
        dataKeyNew.put("screenName", "患者カレンダー");
      } else if (dataKey.get("functionCd").toString().equals("02701")) {
        dataKeyNew.put("screenName", "患者イベント");
      } else if (dataKey.get("functionCd").toString().equals("02801")) {
        if (dataKey.get("patId") == null) {
          dataKeyNew.put("screenName", "指示受け・指示承認(一覧)");
        } else {
          dataKeyNew.put("screenName", "指示受け・指示承認(個別)");
        }
      } else if (dataKey.get("functionCd").toString().equals("02901")) {
        dataKeyNew.put("screenName", "処方");
      } else if (dataKey.get("functionCd").toString().equals("03001")) {
        dataKeyNew.put("screenName", "紹介状");
      } else if (dataKey.get("functionCd").toString().equals("03101")) {
        dataKeyNew.put("screenName", "外部連携稼働ビューア");
      } else if (dataKey.get("functionCd").toString().equals("03201")) {
        if (dataKey.get("mainte_no") != null) {
          dataKeyNew.put("screenName", "水質管理(個別)");
        } else {
          dataKeyNew.put("screenName", "水質管理(一覧)");
        }
      } else if (dataKey.get("functionCd").toString().equals("03301")) {
        // add #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe start
        if (dataKey.get("mainteNos") != null) {
          dataKeyNew.put("screenName", "定期点検(履歴)");
        }
        // add #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe end
        else if (dataKey.get("mainte_no") != null) {
          dataKeyNew.put("screenName", "定期点検(個別)");
        } else {
          dataKeyNew.put("screenName", "定期点検(一覧)");
        }
      } else if (dataKey.get("functionCd").toString().equals("03401")) {
        // add #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe start
        if (dataKey.get("mainteNos") != null) {
          dataKeyNew.put("screenName", "日常点検(履歴)");
        }
        // add #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe end
        else if (dataKey.get("mainte_no") != null) {
          dataKeyNew.put("screenName", "日常点検(個別)");
        } else {
          dataKeyNew.put("screenName", "日常点検(一覧)");
        }
      } else if (dataKey.get("functionCd").toString().equals("03901")) {
        if (dataKey.get("patId") != null) {
          dataKeyNew.put("screenName", "P-Ca9分割グラフ(個別)");
        } else {
          dataKeyNew.put("screenName", "P-Ca9分割グラフ(一覧)");
        }
      } else if (dataKey.get("functionCd").toString().equals("03701")) {
        dataKeyNew.put("screenName", "施設カレンダー");
      }
    }
    for (String key : dataKeyNew.keySet()){
      dataKey.put(key,dataKeyNew.get(key));
    }
    // add #11257 機能帳票の出力に帳票保存のソート条件を適用する 高 start
    reportMenuDataKeySortCommonService.dataKeySortCommonMeth(reportCd, dataKey);
    // add #11257 機能帳票の出力に帳票保存のソート条件を適用する 高 end
    // 機能帳票LOG
    logByReport(dataKey, reportType);
    return dataKey;
  }

  // add #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe start
  private static String getDataKind(Integer dateType){
    switch (dateType){
      case 0: return "dialysis_date";
      case 1: return "exam_date";
      case 2: return "issue_date";
      case 3: return "letter_issue_date";
      case 4: return "all_date";
    }
    return "dialysis_date";
  }

  private static String getDataKindPrint(Integer dateType){
    switch (dateType){
      case 0: return "治療日";
      case 1: return "検査日";
      case 2: return "処方日";
      case 3: return "紹介日";
      case 4: return "すべて";
    }
    return "治療日";
  }

  @Override
  public Map<String,Object> searchReportSettingForDataKey(String facilityCd, Long reportCd, Map<String, Object> dataKey){
    Map<String, Object> map = new HashMap<>();
    if(reportCd == null || reportCd < 0 || StringUtils.isEmpty(facilityCd)) return map;

    MstReport reportSettingResult = mstReportDao.selectReportSettingByReportCd(facilityCd, reportCd);
    String jsonString = reportSettingResult == null || reportSettingResult.getReportSetting() == null ? "" : String.valueOf(reportSettingResult.getReportSetting());

    if (!"".equals(jsonString)) {
      JSONObject jsonObject = new JSONObject(jsonString);

      // 並び替え
      if (jsonObject.has("sortList")) {
        JSONArray sortList = jsonObject.getJSONArray("sortList");
        List<Map<String, String>> sortConditions = new ArrayList<>();
        for (int i = 0; i < sortList.length(); i++) {
          JSONObject sortItem = sortList.getJSONObject(sortList.length() - (i+1));
          Map<String, String> sortConditionsMap = new HashMap<>();
          String key = sortItem.isNull("key") ? null : sortItem.getString("key");
          int sort = sortItem.getInt("sort");
          if (key != null) {
            sortConditionsMap.put(key, sort == 0 ? "asc" : "desc");
            sortConditions.add(sortConditionsMap);
          }
          map.put(ReportConstant.ReportDataKey.SORT_CONDITION_COLUMN+(sortList.length() - (i+1) +1), key);
          map.put(ReportConstant.ReportDataKey.SORT_CONDITION_ORDER+(sortList.length() - (i+1) +1), String.valueOf(sort));
        }
        map.put(ReportConstant.ReportDataKey.SORT_CONDITIONS, sortConditions);
      }

      // データ抽出条件
      if (jsonObject.has("dataCond")) {
        JSONObject dataCondJsonObject = (JSONObject)jsonObject.get("dataCond");

        // 基準日
        if (dataCondJsonObject.has("dateType")) {
          map.put(ReportConstant.ReportDataKey.dateKind, getDataKind(dataCondJsonObject.getInt("dateType")));
          map.put(ReportConstant.ReportDataKey.dateKindPrint, getDataKindPrint(dataCondJsonObject.getInt("dateType")));
        }

        // 0: 期間指定、1: 1日指定、2: 検査日数指定
        if (dataCondJsonObject.has("periodType")) {
          if(dataCondJsonObject.getInt("periodType") == 2){
            map.put("inspectionDate", dataKey.get(ReportConstant.ReportDataKey.DATE_FROM));
            map.put("inspectionDirection", dataCondJsonObject.getInt("beforeAfter") == 0 ? "前" : "後");
            map.put("inspectionDays", dataCondJsonObject.getInt("numDay"));
          }
        }

        // 検査区分
        if (dataCondJsonObject.has("regOrderClass")) {
          JSONArray regOrderClass = dataCondJsonObject.getJSONArray("regOrderClass");
          List<String> list = new ArrayList<>();
          for (int i = 0; i < regOrderClass.length(); i++) {
            list.add(regOrderClass.getString(i));
          }
          map.put(ReportConstant.ReportDataKey.EXAM_CLASSS,list);
        }

        // 処方区分
        if (dataCondJsonObject.has("prescriptionClass")) {
          JSONArray regOrderClass = dataCondJsonObject.getJSONArray("prescriptionClass");
          List<String> list = new ArrayList<>();
          for (int i = 0; i < regOrderClass.length(); i++) {
            list.add(regOrderClass.getString(i));
          }
          map.put(ReportConstant.ReportDataKey.PRESCRIPTION_CLASSS,list);
        }

        // 紹介区分
        if (dataCondJsonObject.has("letterCategory")) {
          JSONArray regOrderClass = dataCondJsonObject.getJSONArray("letterCategory");
          List<String> list = new ArrayList<>();
          for (int i = 0; i < regOrderClass.length(); i++) {
            list.add(regOrderClass.getString(i));
          }
          map.put(ReportConstant.ReportDataKey.LETTER_CLASSS,list);
        }
      }

      // 医療材料分類
      if (jsonObject.has("equipment")) {
        JSONArray jsonArray = jsonObject.getJSONObject("equipment").getJSONArray("checkedList");
        List<String> list = new ArrayList<>();
        for (int i = 0; i < jsonArray.length(); i++) {
          list.add(jsonArray.getString(i));
        }
        map.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS, list);
        // ダイアライザマスタ
        List<String> dialyzerCds = new ArrayList<>();
        if(CollectionUtils.isEmpty(list) ? false : list.contains("0") || list.contains("all")) {
          dialyzerCds.add("all");
        }
        else {
          dialyzerCds.add("0");
        }
        map.put(ReportConstant.ReportDataKey.DIALYZER_IDS, dialyzerCds);
      }

      // 薬剤分類
      if (jsonObject.has("medicine")) {
        JSONArray jsonArray = jsonObject.getJSONObject("medicine").getJSONArray("checkedList");
        List<String> list = new ArrayList<>();
        for (int i = 0; i < jsonArray.length(); i++) {
          list.add(jsonArray.getString(i));
        }
        map.put(ReportConstant.ReportDataKey.MEDICINE_IDS, list);
      }

      // 検査セット
      if (jsonObject.has("examSet")) {
        JSONArray jsonArray = jsonObject.getJSONObject("examSet").getJSONArray("checkedList");
        List<String> list = new ArrayList<>();
        for (int i = 0; i < jsonArray.length(); i++) {
          list.add(jsonArray.getString(i));
        }
        map.put(ReportConstant.ReportDataKey.EXAMSET_IDS, list);
      }

      // 採血管
      if (jsonObject.has("inspect")) {
        List<Integer> inspectionlist =new ArrayList<>();
        inspectionlist.add(jsonObject.getInt("inspect"));
        map.put(ReportConstant.ReportDataKey.INSPECT_IDS, inspectionlist);
      }
    }

    // 並び替え
    if(!map.containsKey(ReportConstant.ReportDataKey.SORT_CONDITIONS)){
      for(int i = 0; i < 3; i++){
        map.put(ReportConstant.ReportDataKey.SORT_CONDITION_COLUMN+(i+1), null);
        map.put(ReportConstant.ReportDataKey.SORT_CONDITION_ORDER+(i+1), "0");
      }
      map.put(ReportConstant.ReportDataKey.SORT_CONDITIONS, new ArrayList<>());
    }

    // データ抽出条件の「基準日」
    if(!map.containsKey(ReportConstant.ReportDataKey.dateKind)){
      map.put(ReportConstant.ReportDataKey.dateKind, getDataKind(-1));
      map.put(ReportConstant.ReportDataKey.dateKindPrint, getDataKindPrint(-1));
    }

    // データ抽出条件の「検査区分」
    if(!map.containsKey(ReportConstant.ReportDataKey.EXAM_CLASSS)){
      map.put(ReportConstant.ReportDataKey.EXAM_CLASSS, new ArrayList<String>(Arrays.asList("1", "2", "0")));
    }

    // データ抽出条件の「処方区分」
    if(!map.containsKey(ReportConstant.ReportDataKey.PRESCRIPTION_CLASSS)){
      map.put(ReportConstant.ReportDataKey.PRESCRIPTION_CLASSS, new ArrayList<String>(Arrays.asList("1", "2")));
    }

    // データ抽出条件の「紹介区分」
    if(!map.containsKey(ReportConstant.ReportDataKey.LETTER_CLASSS)){
      map.put(ReportConstant.ReportDataKey.LETTER_CLASSS, new ArrayList<String>(Arrays.asList("0", "1")));
    }

    // ダイアライザマスタ
    if(!map.containsKey(ReportConstant.ReportDataKey.DIALYZER_IDS)
      || (map.containsKey(ReportConstant.ReportDataKey.DIALYZER_IDS) && map.get(ReportConstant.ReportDataKey.DIALYZER_IDS).toString().contains("all"))
    ) {
      List<Integer> list =new ArrayList<>();
      List<MstDialyzer> dialyzerList = mstDialyzerDao.selectByFacillityCd(facilityCd);
      if(null != dialyzerList && dialyzerList.size()>0){
        for(MstDialyzer dl : dialyzerList){
          list.add(dl.getDialyzerCd());
        }
      }
      map.put(ReportConstant.ReportDataKey.DIALYZER_IDS, list);
    }
    else {
      List<String> Strlist = (List<String>)map.get(ReportConstant.ReportDataKey.DIALYZER_IDS);
      List<Integer> list =new ArrayList<>();
      for(String str : Strlist) {
        list.add(Integer.parseInt(str));
      }
    }

    // 医療材料分類
    if(!map.containsKey(ReportConstant.ReportDataKey.EQUIPMENT_IDS)
      || (map.containsKey(ReportConstant.ReportDataKey.EQUIPMENT_IDS) && map.get(ReportConstant.ReportDataKey.EQUIPMENT_IDS).toString().contains("all"))
    ) {
      List<Integer>list =new ArrayList<>();
      MstEquipmentClass params = new MstEquipmentClass();
      params.setFacilityCd(facilityCd);
      List<MstEquipmentClass> mstEquipmentClassList = mstEquipmentClassDao.selectAll(SelectOptions.get(), params);
      if(null != mstEquipmentClassList && mstEquipmentClassList.size()>0){
        list.add(-1);
        for(MstEquipmentClass mec : mstEquipmentClassList){
          list.add(mec.getClassCd());
        }
      }
      map.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS, list);
    }
    else {
      List<String> Strlist = (List<String>)map.get(ReportConstant.ReportDataKey.EQUIPMENT_IDS);
      List<Integer> list =new ArrayList<>();
      for(String str : Strlist) {
        list.add(Integer.parseInt(str));
      }
    }

    // 薬剤分類
    if(!map.containsKey(ReportConstant.ReportDataKey.MEDICINE_IDS)
      || (map.containsKey(ReportConstant.ReportDataKey.MEDICINE_IDS) && map.get(ReportConstant.ReportDataKey.MEDICINE_IDS).toString().contains("all"))
    ) {
      List<Integer>list =new ArrayList<>();
      MstMedicineClass medicineClass = new MstMedicineClass();
      medicineClass.setFacilityCd(facilityCd);
      List<MstMedicineClass> mstMedicineClassList = mstMedicineClassDao.selectAll(SelectOptions.get(), medicineClass);
      if(null != mstMedicineClassList && mstMedicineClassList.size()>0){
        list.add(-1);
        for(MstMedicineClass mdc : mstMedicineClassList){
          list.add(mdc.getClassCd());
        }
      }
      map.put(ReportConstant.ReportDataKey.MEDICINE_IDS, list);
    }
    else {
      List<String> Strlist = (List<String>)map.get(ReportConstant.ReportDataKey.MEDICINE_IDS);
      List<Integer> list =new ArrayList<>();
      for(String str : Strlist) {
        list.add(Integer.parseInt(str));
      }
    }

    // 検査セット
    if(!map.containsKey(ReportConstant.ReportDataKey.EXAMSET_IDS)
      || (map.containsKey(ReportConstant.ReportDataKey.EXAMSET_IDS) && map.get(ReportConstant.ReportDataKey.EXAMSET_IDS).toString().contains("all"))
    ) {
      List<Long>list =new ArrayList<>();
      MstExamSet examSet = new MstExamSet();
      examSet.setFacilityCd(facilityCd);
      List<MstExamSet> mstExamSetList = mstExamSetDao.selectAll(SelectOptions.get(),examSet);
      if(null != mstExamSetList && mstExamSetList.size()>0){
        for(MstExamSet mes : mstExamSetList){
          list.add(mes.getExamSetCd());
        }
      }
      map.put(ReportConstant.ReportDataKey.EXAMSET_IDS, list);
    }
    else {
      List<String> Strlist = (List<String>)map.get(ReportConstant.ReportDataKey.EXAMSET_IDS);
      List<Integer> list =new ArrayList<>();
      for(String str : Strlist) {
        list.add(Integer.parseInt(str));
      }
    }

    // 採血管
    List<Integer> inspectionlist =new ArrayList<>();
    inspectionlist.add(0);//常に出さないように暫定的の対応
    map.put(ReportConstant.ReportDataKey.INSPECT_IDS, inspectionlist);

    return map;
  }
  // add #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe end

  private void outputErrorLog(String facilityCd, String message) {
    outputLog(LogLevel.ERROR, facilityCd, message);
  }
  private void outputLog(LogLevel level, String facilityCd, String message) {
    EventLogMessage elm = new EventLogMessage();
    elm.setFacilityCd(facilityCd);
    elm.setLogMessage(message);
    elm.setInvokeClass(this.getClass().getName());
    logService.log(level, elm, null, LoggingConstant.SERVICE_NAME.FNSI, null);
  }

  /**
   * 指定された日付から1ヶ月前の日付を取得します。
   *
   * @param ymd 年月日を表す文字列 (例: "yyyyMMdd")
   * @return 1ヶ月前の日付を表す文字列 (例: "yyyyMMdd")
   */
  private String minusOneMonth(String ymd) {
    // 日付フォーマットを定義します (例: "yyyyMMdd")
    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyyMMdd");
    // 指定された文字列をLocalDateオブジェクトに変換します
    LocalDate date = LocalDate.parse(ymd, formatter);
    // 1ヶ月前の日付を取得します
    LocalDate oneMonthAgo = date.minus(1, ChronoUnit.MONTHS);
    // 1ヶ月前の日付を指定されたフォーマットの文字列に変換します
    String reStr = oneMonthAgo.format(formatter);
    // 変換された文字列を返します
    return reStr;
  }

  private String addOneMonth(String ymd,String functionCd) throws ParseException {
    SimpleDateFormat sdf = sdf = new SimpleDateFormat("yyyyMMdd");
    Date dt = sdf.parse(ymd);
    Calendar rightNow = Calendar.getInstance();
    rightNow.setTime(dt);
    rightNow.add(Calendar.MONTH, 1);
    Date dt1 = rightNow.getTime();
    String reStr = sdf.format(dt1);
    return reStr;
  }

  // add #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe start
  private Long getLatestOrdNo(String date, String facilityCd, Long patId, String rstDiaysisState){
    List<OrdMain> ordNoList = ordMainDao.selectLastestOrdNoByBaseDate(patId, facilityCd, date, rstDiaysisState);
    Long ordNo = -1l;
    if(ordNoList != null && ordNoList.size()>0) ordNo = ordNoList.get(0).getOrdNo();
    return ordNo;
  }

  private Map<String, List<Long>> getLatestOrdNos(String date, String facilityCd, List<Long> patIds, String rstDiaysisState){
    List<OrdMain> ordNoList = ordMainDao.selectLastestOrdNosByBaseDate(patIds, facilityCd, date, rstDiaysisState);
    List<Long> patIdsNew = new ArrayList<>();
    List<Long> ordNosNew = new ArrayList<>();
    boolean bHaveOrdNo = false;
    for(int i = 0; i < patIds.size(); i++){
      bHaveOrdNo = false;
      for(int j = 0; j < ordNoList.size(); j++){
        if(ordNoList.get(j).getPatId().equals(patIds.get(i))){
          patIdsNew.add(ordNoList.get(j).getPatId());
          ordNosNew.add(ordNoList.get(j).getOrdNo());
          bHaveOrdNo = true;
        }
      }
      if(bHaveOrdNo == false){
        patIdsNew.add(patIds.get(i));
        ordNosNew.add(-1l);
      }
    }
    Map<String, List<Long>> map = new HashMap<>();
    map.put(ReportConstant.ReportDataKey.PAT_IDS, patIdsNew);
    map.put(ReportConstant.ReportDataKey.ORD_NOS, ordNosNew);
    return map;
  }

  // add #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe start
  private Map<String, List<Long>> getOrdNosbyPatIds(String facilityCd, List<Long> patIds, String specifyDate, String fromDate, String toDate, String rstDiaysisState){
    List<OrdMain> ordNoList = ordMainDao.selectOrdNosByPatIds(patIds, facilityCd, specifyDate, fromDate, toDate, rstDiaysisState);
    List<Long> patIdsNew = new ArrayList<>();
    List<Long> ordNosNew = new ArrayList<>();
    boolean bHaveOrdNo = false;
    for(int i = 0; i < patIds.size(); i++){
      bHaveOrdNo = false;
      for(int j = 0; j < ordNoList.size(); j++){
        if(ordNoList.get(j).getPatId().equals(patIds.get(i))){
          patIdsNew.add(ordNoList.get(j).getPatId());
          ordNosNew.add(ordNoList.get(j).getOrdNo());
          bHaveOrdNo = true;
        }
      }
      if(bHaveOrdNo == false){
        patIdsNew.add(patIds.get(i));
        ordNosNew.add(-1l);
      }
    }
    Map<String, List<Long>> map = new HashMap<>();
    map.put(ReportConstant.ReportDataKey.PAT_IDS, patIdsNew);
    map.put(ReportConstant.ReportDataKey.ORD_NOS, ordNosNew);
    return map;
  }

  private void getOrdPara(Map<String, Object> dataKey, Map<String, Object> dataKeyNew){
    String rstDiaysisState = null; // 予定+実績を検索するフラグ
    if(dataKey.get("functionCd").toString().equals("00401")
      || dataKey.get("functionCd").toString().equals("00701")
      || dataKey.get("functionCd").toString().equals("01001")
      || dataKey.get("functionCd").toString().equals("01601")
      || (dataKey.get("functionCd").toString().equals("01801") && dataKey.get(ReportConstant.ReportDataKey.PAT_ID) != null)
      || (dataKey.get("functionCd").toString().equals("02101") && dataKey.get(ReportConstant.ReportDataKey.PAT_ID) != null)
      || (dataKey.get("functionCd").toString().equals("02201") && dataKey.get(ReportConstant.ReportDataKey.PAT_ID) != null)
      || dataKey.get("functionCd").toString().equals("02401")
      || dataKey.get("functionCd").toString().equals("02701")
      || (dataKey.get("functionCd").toString().equals("02801") && dataKey.get(ReportConstant.ReportDataKey.PAT_ID) != null)
      || dataKey.get("functionCd").toString().equals("02901")
      || dataKey.get("functionCd").toString().equals("03001")
      || (dataKey.get("functionCd").toString().equals("03901") && dataKey.get(ReportConstant.ReportDataKey.PAT_ID) != null)
    ){
      rstDiaysisState = "0"; // 実績を検索するフラグ
    }
    if(dataKey.get(ReportConstant.ReportDataKey.PAT_ID) != null){
      // オーダ番号（単）
      // 指定日
      if(dataKey.containsKey("dialysisDate") && !StringUtils.isEmpty(dataKey.get("dialysisDate"))){
        Long ordNo = -1l;
        if(dataKey.get("functionCd").toString().equals("01801") && dataKey.containsKey("selectExamSetCd") && dataKey.containsKey("selectExamGraphCd")) {
          // 指定日の実績
          OrdMain ordMain = ordMainDao.selectRstOrdNoByBaseDate(
            Long.parseLong(String.valueOf(dataKey.get(ReportConstant.ReportDataKey.PAT_ID))),
            dataKey.get(ReportConstant.ReportDataKey.FACILITY_CD).toString(),
            dataKey.get("dialysisDate").toString()
          );
          if(ordMain != null) ordNo = ordMain.getOrdNo();
        }
        else {
          // 指定日から最も近い実績の実績
          ordNo = getLatestOrdNo(
            dataKey.get("dialysisDate").toString(),
            dataKey.get(ReportConstant.ReportDataKey.FACILITY_CD).toString(),
            Long.parseLong(String.valueOf(dataKey.get(ReportConstant.ReportDataKey.PAT_ID))),
            rstDiaysisState
          );
        }
        dataKeyNew.put(ReportConstant.ReportDataKey.ORD_NO, ordNo);
      }
      // 対象日
      else {
        List<String> functionCds = Stream.of("00401", "00701", "01001", "01601", "01801", "02101", "02201", "02401", "02701", "02801", "02901", "03001", "03901").toList();
        if (functionCds.contains(dataKey.get("functionCd").toString())) {
          Long ordNo = -1l;
          if(dataKey.get("functionCd").toString().equals("01801") && dataKey.containsKey("selectExamSetCd") && dataKey.containsKey("selectExamGraphCd")) {
            // 対象日の実績
            OrdMain ordMain = ordMainDao.selectRstOrdNoByBaseDate(
              Long.parseLong(String.valueOf(dataKey.get(ReportConstant.ReportDataKey.PAT_ID))),
              dataKey.get(ReportConstant.ReportDataKey.FACILITY_CD).toString(),
              dataKey.get(ReportConstant.ReportDataKey.DATE).toString()
            );
            if(ordMain != null) ordNo = ordMain.getOrdNo();
          }
          else if(dataKey.get("functionCd").toString().equals("00401")) {
            // 基準日から最も近い実績の実績
            ordNo = getLatestOrdNo(
              dataKey.get("baseDate").toString(),
              dataKey.get(ReportConstant.ReportDataKey.FACILITY_CD).toString(),
              Long.parseLong(String.valueOf(dataKey.get(ReportConstant.ReportDataKey.PAT_ID))),
              rstDiaysisState
            );
          }
          else {
            // 対象日から最も近い実績の実績
            ordNo = getLatestOrdNo(
              dataKey.get(ReportConstant.ReportDataKey.DATE).toString(),
              dataKey.get(ReportConstant.ReportDataKey.FACILITY_CD).toString(),
              Long.parseLong(String.valueOf(dataKey.get(ReportConstant.ReportDataKey.PAT_ID))),
              rstDiaysisState
            );
          }
          dataKeyNew.put(ReportConstant.ReportDataKey.ORD_NO, ordNo);
        }
      }
    }
    else {
      // 指定日
      if(dataKey.containsKey("dialysisDate") && !StringUtils.isEmpty(dataKey.get("dialysisDate"))){
        // 指定日の実績
        List<Long> patIds = (List<Long>) dataKeyNew.get(ReportConstant.ReportDataKey.PAT_IDS);
        Map<String, List<Long>> map = getLatestOrdNos(
          dataKey.get("dialysisDate").toString(),
          dataKey.get(ReportConstant.ReportDataKey.FACILITY_CD).toString(),
          patIds,
          rstDiaysisState
        );
        dataKeyNew.put(ReportConstant.ReportDataKey.PAT_IDS, map.get(ReportConstant.ReportDataKey.PAT_IDS));
        dataKeyNew.put(ReportConstant.ReportDataKey.ORD_NOS, map.get(ReportConstant.ReportDataKey.ORD_NOS));
      }
      // 対象期間
      else {
        List<String> functionCds = Stream.of("00801", "00901", "01801", "02101", "02201", "02301", "02801", "03901").toList();
        if (functionCds.contains(dataKey.get("functionCd").toString())) {
          // 対象期間の実績
          List<Long> patIds = (List<Long>) dataKeyNew.get(ReportConstant.ReportDataKey.PAT_IDS);
          Map<String, List<Long>> map = getOrdNosbyPatIds(
            dataKey.get(ReportConstant.ReportDataKey.FACILITY_CD).toString(),
            patIds,
            null,
            dataKey.get(ReportConstant.ReportDataKey.DATE_FROM).toString(),
            dataKey.get(ReportConstant.ReportDataKey.DATE_TO).toString(),
            rstDiaysisState
          );
          dataKeyNew.put(ReportConstant.ReportDataKey.PAT_IDS, map.get(ReportConstant.ReportDataKey.PAT_IDS));
          dataKeyNew.put(ReportConstant.ReportDataKey.ORD_NOS, map.get(ReportConstant.ReportDataKey.ORD_NOS));
        }
      }
    }
  }
  // add #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe end

  private List<Long> changeTypeNumtoLong(List<Integer> list){
    List<Long> newList = new ArrayList<>();
    if (list != null) {
      for (int i = 0; i < list.size(); i++) {
        if (!StringUtils.isEmpty(list.get(i))) {
          newList.add(Long.parseLong(String.valueOf(list.get(i))));
        } else {
          newList.add(-1l);
        }
      }
    }
    return newList;
  }
  // add #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe end

  private void logByReport (Map<String, Object> dataKey , String reportType) {
    String sqlTestSign =
      "画面：" + dataKey.get("screenName") + "\n"
        + "帳票種別：" + reportType + "\n"
        + "functionCd：" + dataKey.get("functionCd") + "\n"
        + "facilityCd：" + dataKey.get("facilityCd") + "\n"
        + "patId：" + dataKey.get("patId") + "\n"
        + "patIds：" + dataKey.get("patIds") + "\n"
        + "ordNo：" + dataKey.get("ordNo") + "\n"
        + "ordNos：" + dataKey.get("ordNos") + "\n"
        + "baseDate：" + dataKey.get("baseDate") + "\n"
        + "treatDate：" + dataKey.get("treatDate") + "\n"
        + "date：" + dataKey.get("date") + "\n"
        + "fromDate：" + dataKey.get("fromDate") + "\n"
        + "toDate：" + dataKey.get("toDate") + "\n"
        + "machineNos：" + dataKey.get("machineNos") + "\n"
        + "selectKurCd：" + dataKey.get("selectKurCd") + "\n"
        + "bedCds：" + dataKey.get("bedCds") + "\n"
        + "ordPrescriptionNo：" + dataKey.get("ordPrescriptionNo") + "\n"
        + "examineCoopOrdNo：" + dataKey.get("examineCoopOrdNo") + "\n"
        + "angiographyCoopOrdNo：" + dataKey.get("angiographyCoopOrdNo") + "\n"
        + "coopOrdNo：" + dataKey.get("coopOrdNo") + "\n"
        + "selectNos：" + dataKey.get("selectNos") + "\n"
        + "mainte_no：" + dataKey.get("mainte_no") + "\n"
        // add #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe start
        + "mainteNos：" + dataKey.get("mainte_no") + "\n"
        // add #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe end
        // add ##11152 検査結果(個別)で機能帳票のパラメータに「検査セット」を追加 limingzhe start
        + "selectExamSetCd：" + dataKey.get("selectExamSetCd") + "\n"
        + "selectedExamSetName：" + dataKey.get("selectedExamSetName") + "\n"
        + "selectExamGraphCd：" + dataKey.get("selectExamGraphCd") + "\n"
        + "selectedExamGraphName：" + dataKey.get("selectedExamGraphName") + "\n"
        // add #11257 機能帳票の出力に帳票保存のソート条件を適用する 高 start
        + "dateKind：" + dataKey.get("dateKind");
        // add #11257 機能帳票の出力に帳票保存のソート条件を適用する 高 end
        // add ##11152 検査結果(個別)で機能帳票のパラメータに「検査セット」を追加 limingzhe end
    EventLogMessage LogMessage = new EventLogMessage();
    LogMessage.setLogMessage(sqlTestSign + "機能帳票 開始<<<<<<<");
    logService.log(LogLevel.INFO, LogMessage, LoggingConstant.FUNCTION_CODE.FUNC_REPORT_MENU, LoggingConstant.SERVICE_NAME.FNSI, null);
  }

  // add #12107 帳票印刷失敗通知が行われない limingzhe start
  @Override
  public String getReportClassName(Integer reportClass) {
    String reportClassName = "";
    if (reportClass.equals(ReportConstant.ReportClass.DIALYSIS_REPORT)) {
      reportClassName = "治療経過表";
    } else if (reportClass.equals(ReportConstant.ReportClass.ONE_PATIENT_REPORT)) {
      reportClassName = "単患者帳票";
    } else if (reportClass.equals(ReportConstant.ReportClass.MULTIPLE_PATIENT_REPORT)) {
      reportClassName = "複数患者帳票";
    } else if (reportClass.equals(ReportConstant.ReportClass.PREPARATION_LIST_REPORT)) {
      reportClassName = "準備リスト";
    } else if (reportClass.equals(ReportConstant.ReportClass.DISTRIBUTION_LIST_BED_REPORT)) {
      reportClassName = "配布リスト(ベッド)";
    } else if (reportClass.equals(ReportConstant.ReportClass.DISTRIBUTION_LIST_GOODS_REPORT)) {
      reportClassName = "配布リスト(物品)";
    } else if (reportClass.equals(ReportConstant.ReportClass.MACHINE_REPORT)) {
      reportClassName = "装置帳票";
    } else if (reportClass.equals(ReportConstant.ReportClass.LABEL_REPORT)) {
      reportClassName = "ラベル";
    } else if (reportClass.equals(ReportConstant.ReportClass.INTRODUCTION_REPORT)) {
      reportClassName = "紹介状";
    } else if (reportClass.equals(ReportConstant.ReportClass.ONE_TOTAL_REPORT)) {
      reportClassName = "単集計";
    } else if (reportClass.equals(ReportConstant.ReportClass.MULTI_TOTAL_REPORT)) {
      reportClassName = "複数集計";
    }
    return reportClassName;
  }
  // add #12107 帳票印刷失敗通知が行われない limingzhe end
}
// add #9558 機能帳票で正しく変数が引き渡されていない 高 end
