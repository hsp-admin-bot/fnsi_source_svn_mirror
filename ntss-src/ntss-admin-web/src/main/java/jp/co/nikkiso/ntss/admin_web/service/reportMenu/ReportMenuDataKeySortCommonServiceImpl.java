// add #11257 機能帳票の出力に帳票保存のソート条件を適用する 高 start
package jp.co.nikkiso.ntss.admin_web.service.reportMenu;

import com.mongodb.client.FindIterable;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.api.constant.ReportConstant;
import jp.co.nikkiso.ntss.api.domain.report.ReportXmlParam;
import jp.co.nikkiso.ntss.api.service.report.ReportS3Service;
import jp.co.nikkiso.ntss.api.service.utils.ReportUtils;
import jp.co.nikkiso.ntss.api.service.utils.ReportZipFile;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.BaseEntityDao;
import jp.co.nikkiso.ntss.core.dao.DevMenteMainDao;
import jp.co.nikkiso.ntss.core.dao.MniMonitorDao;
import jp.co.nikkiso.ntss.core.dao.MstBedDao;
import jp.co.nikkiso.ntss.core.dao.MstKurDao;
import jp.co.nikkiso.ntss.core.dao.MstMachineDao;
import jp.co.nikkiso.ntss.core.dao.MstReportDao;
import jp.co.nikkiso.ntss.core.dao.MstRoomBedGroupDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.PatGroupDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.dao.ReportMenuDao;
import jp.co.nikkiso.ntss.core.entity.MstBed;
import jp.co.nikkiso.ntss.core.entity.MstKur;
import jp.co.nikkiso.ntss.core.entity.MstMachine;
import jp.co.nikkiso.ntss.core.entity.MstReport;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.PatExamMain;
import jp.co.nikkiso.ntss.core.entity.custom.MniMonitorRemainingTime;
import jp.co.nikkiso.ntss.core.exception.NotExistException;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.StringUtils;
import org.bson.Document;
import org.bson.conversions.Bson;
import org.json.JSONArray;
import org.json.JSONObject;
import org.seasar.doma.jdbc.Config;
import org.seasar.doma.jdbc.SelectOptions;
import org.seasar.doma.jdbc.builder.SelectBuilder;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.stereotype.Service;
import org.springframework.util.CollectionUtils;

import java.sql.Timestamp;
import java.text.ParseException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

import static com.mongodb.client.model.Filters.and;
import static com.mongodb.client.model.Filters.eq;
import static com.mongodb.client.model.Filters.in;
import static com.mongodb.client.model.Filters.lt;
import static com.mongodb.client.model.Sorts.descending;
import static java.util.stream.Collectors.toList;
import jp.co.nikkiso.ntss.core.config.DefaultDb;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

@Service
@Slf4j
public class ReportMenuDataKeySortCommonServiceImpl implements ReportMenuDataKeySortCommonService{


  @Autowired
  private MstReportDao mstReportDao;

  @Autowired
  private ReportMenuDao reportMenuDao;

  @Autowired
  private BaseEntityDao baseEntityDao;

  @Autowired
  private PatPersonalMainDao patPersonalMainDao;

  @Autowired
  private ReportS3Service reportS3Service;

  @Autowired
  MniMonitorDao mniMonitorDao;

  @Autowired
  OrdMainDao rdMainDao;

  @Autowired
  PatGroupDao patGroupDao;

  @Autowired
  MstBedDao mstBedDao;

  @Autowired
  MstKurDao mstKurDao;

  @Autowired
  MstRoomBedGroupDao mstRoomBedGroupDao;

  @Autowired
  DevMenteMainDao devMenteMainDao;

  @Autowired(required = false)
  private MongoTemplate mongoTemplate;

  @Autowired
  private MstMachineDao mstMachineDao;

  @Autowired
  @DefaultDb
  private Config defaultDbConfig;

  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
  @Autowired
  private LogService logService;
  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end

  /**
   * 機能帳票並び替
   *
   * @param reportCd レポートCD
   * @param dataKey 機能帳票パラメータ
   *
   * */
  @Override
  public void dataKeySortCommonMeth(Long reportCd,
                                    Map<String, Object> dataKey) throws ParseException {

    MstReport mstReport = getMstReport(reportCd);
    // mod #12107 帳票印刷失敗通知が行われない limingzhe 20251114 start
//    // S3から帳票定義XML、帳票デザインExcelが格納されたZipファイルを取得する
//    ReportZipFile reportZipFile = getReportZip(mstReport);
//
//    // 帳票定義XMLを params に格納
//    String reportXml = getReportXml(mstReport, reportZipFile);
    String reportXml = "";
    try{
      // S3から帳票定義XML、帳票デザインExcelが格納されたZipファイルを取得する
      ReportZipFile reportZipFile = getReportZip(mstReport);

      // 帳票定義XMLを params に格納
      reportXml = getReportXml(mstReport, reportZipFile);
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
      throw e;
    }
    // mod #12107 帳票印刷失敗通知が行われない limingzhe 20251114 end

    List<ReportXmlParam> params = ReportUtils.getParamElements(reportXml);
    // del #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe start
//    // add #11262 機能帳票でテンプレートを使用した帳票が出力されなくなっている 高 start
//    // dateKind 追加
//    switch (params.get(0).getReportXmlTmplRepeat().getKey()) {
//      case "exam_main_cd":
//        dataKey.put("dateKind","exam_date");
//        // add #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy start
//        dataKey.put("dateKindPrint","検査日");
//        // add #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy end
//        break;
//      case "ord_prescription_no":
//        dataKey.put("dateKind","issue_date");
//        // add #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy start
//        dataKey.put("dateKindPrint","処方日");
//        // add #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy end
//        break;
//      default:
//        dataKey.put("dateKind","dialysis_date");
//        // add #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy start
//        dataKey.put("dateKindPrint","治療日");
//        // add #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy end
//        break;
//    }
//    // add #11262 機能帳票でテンプレートを使用した帳票が出力されなくなっている 高 end

//    MstReport report = mstReportDao.selectReportByReportCd(reportCd);
    // del #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe end
    List<Long> patIdList = dataKey.get("patIds") == null ? new ArrayList<>() : (ArrayList)dataKey.get("patIds");
    List<Long> ordNoList = new ArrayList<>();
    if (dataKey.get("ordNos") == null && dataKey.get("ordNo") != null) {
      ordNoList.add(Long.parseLong(String.valueOf(dataKey.get("ordNo"))));
    } else {
      ordNoList = dataKey.get("ordNos") == null ? new ArrayList<>() : (ArrayList)dataKey.get("ordNos");
    }
    List<OrdMain> ordList = reportMenuDao.selectByTreatDateAndPatIdsAndRst(ordNoList,String.valueOf(dataKey.get("facilityCd")));
    List<Long> listOrdNo = new ArrayList<>();
    List<Long> listPatId = new ArrayList<>();
    List<Long> listPat = new ArrayList<>();
    List<Long> listOrd = new ArrayList<>();
    String tmpSortKeyStr = "";
    String tmpSortDirectionStr = "";
    LocalDateTime localDateFrom = null;
    LocalDateTime localDateTo = null;
    if (dataKey.size() != 0 && StringUtils.isEmpty((CharSequence) dataKey.get("specifyDate"))) {
      // 期間指定
      localDateFrom = LocalDate.parse(String.valueOf(dataKey.get("fromDate")), DateTimeFormatter.ofPattern("uuuuMMdd")).atStartOfDay();
      localDateTo = LocalDate.parse(String.valueOf(dataKey.get("toDate")), DateTimeFormatter.ofPattern("uuuuMMdd")).atStartOfDay();
      localDateTo = localDateTo.plusDays(1L).minusNanos(1000);
    } else {
      // 1日指定
      localDateFrom = LocalDate.parse(String.valueOf(dataKey.get("specifyDate")), DateTimeFormatter.ofPattern("uuuuMMdd")).atStartOfDay();
      localDateTo = localDateFrom.plusDays(1L).minusNanos(1000);
    }
    String mongFromDate = localDateFrom.format(DateTimeFormatter.ofPattern("yyyy-MM-dd")) + " 23:59:59";

    List<Map<String, String>> sortConditions = new ArrayList<>();
    List<String> regOrderClassList = new ArrayList<>();
    // mod #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe start
//    MstReport reportSettingResult = mstReportDao.selectReportSettingByReportCd(String.valueOf(dataKey.get("facilityCd")),reportCd);
//    String jsonString = reportSettingResult.getReportSetting() == null ? "" : String.valueOf(reportSettingResult.getReportSetting());
//
//    if (!"".equals(jsonString)) {
//      JSONObject jsonObject = new JSONObject(jsonString);
//
//      // sortList
//      if (jsonObject.has("sortList")) {
//        JSONArray sortList = jsonObject.getJSONArray("sortList");
//        for (int i = 0; i < sortList.length(); i++) {
//          JSONObject sortItem = sortList.getJSONObject(sortList.length() - (i+1));
//          Map<String, String> sortConditionsMap = new HashMap<>();
//          String key = sortItem.isNull("key") ? null : sortItem.getString("key");
//          int sort = sortItem.getInt("sort");
//          String sortStr = sort == 0 ? "asc" : "desc";
//          String sortStrNo = sort == 0 ? "昇順" : "降順";
//          if (key != null ) {
//            sortConditionsMap.put(key,sortStr);
//            sortConditions.add(sortConditionsMap);
//            dataKey.put("sortColumn"+(sortList.length() - (i+1) +1),key);
//            dataKey.put("sortOrder"+(sortList.length() - (i+1) +1),sortStrNo);
//          }
//        }
//        dataKey.put("sortConditions",sortConditions);
//        // 準備リスト use
//        dataKey.put("sortCondition",sortConditions);
//      }
//
//      // regOrderClass
//      if (jsonObject.has("regOrderClass")) {
//        JSONArray regOrderClass = jsonObject.getJSONArray("regOrderClass");
//        for (int i = 0; i < regOrderClass.length(); i++) {
//          regOrderClassList.add(regOrderClass.getString(i));
//        }
//        dataKey.put("regOrderClass",regOrderClassList);
//      }
//      // add #11603 検査予定のラベル出力とフィルタ機能 高 start
//      else {
//        regOrderClassList = new ArrayList<String>(Arrays.asList("1", "2", "0"));
//        dataKey.put("regOrderClass",regOrderClassList);
//      }
//      // add #11603 検査予定のラベル出力とフィルタ機能 高 end
//    }
    if(dataKey.containsKey(ReportConstant.ReportDataKey.SORT_CONDITIONS)) {
      sortConditions = (List<Map<String, String>>)dataKey.get(ReportConstant.ReportDataKey.SORT_CONDITIONS);
    }
    if(dataKey.containsKey(ReportConstant.ReportDataKey.EXAM_CLASSS)) {
      regOrderClassList = (List<String>)dataKey.get(ReportConstant.ReportDataKey.EXAM_CLASSS);
    }
    // mod #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe end

    // 透析レポート
    if (mstReport.getReportClass().equals(ReportConstant.ReportClass.DIALYSIS_REPORT)) {

      listPatId = dataKey.get("patIds") == null ? new ArrayList<>(): (ArrayList)dataKey.get("patIds");
      listOrdNo = dataKey.get("ordNos") == null ? new ArrayList<>(): (ArrayList)dataKey.get("ordNos");
      // sortConditions (帳票画面>並び替え設定) は、優先3番目 → 優先2番目 → 優先1番目の順でデータがくることを想定しています (帳票種別：8：ラベルの並び替えと同様)
      if (sortConditions != null && sortConditions.size() > 0 && patIdList.size() > 0) {

        String patIdStr = "pat_id";
        String ordNoStr = "ord_no";
        // 01：患者IDのリストを、jsonのリストにまとめる
        List<JSONObject> tmpList = new ArrayList<>();
        for (int idx = 0; idx < listPatId.size(); idx++) {
          JSONObject jsonData = new JSONObject();
          jsonData.put(patIdStr, listPatId.get(idx));
          jsonData.put(ordNoStr, listOrdNo.get(idx));
          jsonData.put("hosp_pat_id", ""); // 患者ID
          jsonData.put("pat_full_name", ""); // 患者名
          jsonData.put("bed_order", ""); // ベッド表示順
          jsonData.put("kur_order", ""); // クール表示順
          jsonData.put("in_out_class", ""); // 入外区分
          jsonData.put("room_group_order", ""); // 透析室表示順
          jsonData.put("bed_group_order", ""); // ベッドグループ表示順
          tmpList.add(jsonData);
        }

        // 02：ソートに必要なデータを「01」で作成したjsonのリストに格納する
        // ※：画面上で並び順を 第1→患者ID(昇順)、第2→患者ID(降順) とした場合、sortConditions は 患者ID(昇順) 1件のみで送られてきます
        // ※：患者ID/入外区分、ベッド/クールのデータは1度の処理で取得できる為、フラグで2回通らないようにします
        boolean ppmhPassedFlg = false;
        boolean ordPassedFlg = false;
        for (int index = 0; index < sortConditions.size(); index++) {
          Map<String, String> item = sortConditions.get(sortConditions.size() - (index+1));

          if ((item.keySet().contains(CoreConstant.ReportMenu.PATIENT_ID) ||
            item.keySet().contains(CoreConstant.ReportMenu.PATIENT_NAME) ||
            item.keySet().contains(CoreConstant.ReportMenu.ENTRANCE_EXIT_CLASSIFICATION)) && !ppmhPassedFlg) {

            // mongoDB検索条件作成
            ArrayList<Bson> arr = new ArrayList<Bson>();
            arr.add(lt("up_date", mongFromDate));
            List<String> searchPatIdlist = new ArrayList<>();
            for (JSONObject tmpJson : tmpList) {
              searchPatIdlist.add(tmpJson.get(patIdStr).toString());
            }
            arr.add(in(patIdStr, searchPatIdlist));
            Bson bson = and(arr);
            // mongoDB検索処理
            FindIterable<Document> resultDocs = mongoTemplate.getCollection("pat_personal_main_history").find(bson).sort(descending("up_date"));
            // 患者ID毎に患者ID/入外区分を格納
            for (JSONObject tmpJson : tmpList) {
              Document doc = resultDocs != null ? resultDocs.filter(eq(patIdStr, tmpJson.get(patIdStr).toString())).first() : new Document();
              String inOutClass = "";
              inOutClass = rdMainDao.getInOutClass(String.valueOf(dataKey.get("facilityCd")), tmpJson.get(ordNoStr).toString(), tmpJson.get(patIdStr).toString());
              if (doc != null) {
                // 患者ID ( ソート用に0埋めして格納 )
                // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 start
//                tmpJson.put("hosp_pat_id", String.format("%12s", doc.get("hosp_pat_id").toString()).replace(" ", "0"));
                tmpJson.put("hosp_pat_id", doc.get("hosp_pat_id").toString());
                // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 end
                // 入外区分
                tmpJson.put("in_out_class", inOutClass !=null ? inOutClass : "");
                // 患者名
                // mod #11513 患者名が指定文字数ぶん出ない 高 start
//                tmpJson.put("pat_full_name", doc.get("pat_last_name").toString() + " " + doc.get("pat_first_name").toString());
                // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 start
                // カナ優先として半角スペースで連結し、ソート用キーを作成。文字列としてソートするソート用キーーカナ姓(漢字姓)&&カナ名(漢字名)
                if (doc.get("pat_last_name") != null && doc.get("pat_first_name") != null){
                  if (doc.get("pat_last_name") != null && doc.get("pat_first_name") != null) {
                    String lastName = !StringUtils.isEmpty((CharSequence) doc.get("pat_last_name_kana")) ? String.valueOf(doc.get("pat_last_name_kana"))
                      : String.valueOf(doc.get("pat_last_name"));
                    String firstName = !StringUtils.isEmpty((CharSequence) doc.get("pat_first_name_kana")) ? String.valueOf(doc.get("pat_first_name_kana"))
                      : String.valueOf(doc.get("pat_first_name"));
                    tmpJson.put("pat_full_name", lastName + " " + firstName);
                  }
                }
//                tmpJson.put("pat_full_name", doc.get("pat_last_name").toString() + "" + doc.get("pat_first_name").toString());
                // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 end
                // mod #11513 患者名が指定文字数ぶん出ない 高 end
              }
            }
            ppmhPassedFlg = true;

          }
          else if (item.keySet().contains(CoreConstant.ReportMenu.PATIENT_BED) ||
            item.keySet().contains(CoreConstant.ReportMenu.PATIENT_COOL) ||
            item.keySet().contains(CoreConstant.ReportMenu.ROOM_BED_GROUP1) ||
            item.keySet().contains(CoreConstant.ReportMenu.DIALYSIS_ROOM_GROUP1) && !ordPassedFlg) {
            // マスタデータを取得
            SelectOptions options = SelectOptions.get();
            List<MstBed> mstBedList = mstBedDao.selectByFacilityCd(String.valueOf(dataKey.get("facilityCd")), "1", "0");
            List<MstKur> mstKurList = mstKurDao.selectByFacilityCd(options, String.valueOf(dataKey.get("facilityCd")), "0");

            for (JSONObject tmpJson : tmpList) {
              String ordNo = tmpJson.get(ordNoStr).toString();
              // ordMainから取得する値
              for (OrdMain ord : ordList) {
                if (ordNo.equals(ord.getOrdNo().toString())) {
                  // ベッド, ベッドグループ表示順, 透析室表示順
                  for (Integer bedListIndex = 0; bedListIndex < mstBedList.size(); bedListIndex++ ) {
                    if (ord.getIndBedCd().toString().equals(mstBedList.get(bedListIndex).getBedCd().toString())) {
                      tmpJson.put("bed_order", String.format("%5s", bedListIndex.toString()).replace(" ", "0"));
                      Integer bedGroupIndex = 999;
                      bedGroupIndex = mstRoomBedGroupDao.selectIndexBedCdIsContain(ord.getIndBedCd().toString(), String.valueOf(dataKey.get("facilityCd")), "1");
                      tmpJson.put("bed_group_order", String.format("%3s", bedGroupIndex.toString()).replace(" ", "0"));
                      Integer RoomIndex = 999;
                      RoomIndex = mstRoomBedGroupDao.selectIndexBedCdIsContain(ord.getIndBedCd().toString(), String.valueOf(dataKey.get("facilityCd")), "2");
                      tmpJson.put("room_group_order", String.format("%3s", RoomIndex.toString()).replace(" ", "0"));
                    }
                  }
                  // クール
                  for (Integer kurListIndex = 0; kurListIndex < mstKurList.size(); kurListIndex++ ) {
                    if (ord.getIndKurCd().toString().equals(mstKurList.get(kurListIndex).getKurCd().toString())) {
                      tmpJson.put("kur_order", String.format("%3s", kurListIndex.toString()).replace(" ", "0"));
                    }
                  }
                }
              }
            }
            ordPassedFlg = true;
          }
        }

        List tmpSortKey = new ArrayList();
        List tmpSortDirection = new ArrayList();
        // 03：条件により並び替えを実施する
        for (int index = 0; index < sortConditions.size(); index++) {
          Map<String, String> item = sortConditions.get(sortConditions.size() - (index+1));

          if (item.keySet().contains(CoreConstant.ReportMenu.PATIENT_ID)) {
            // 患者ID
            tmpSortKey.add(index,"hosp_pat_id");
            tmpSortDirection.add(index,item.get(CoreConstant.ReportMenu.PATIENT_ID).toString());
          } else if (item.keySet().contains(CoreConstant.ReportMenu.PATIENT_NAME)) {
            // 患者名
            tmpSortKey.add(index,"pat_full_name");
            tmpSortDirection.add(index,item.get(CoreConstant.ReportMenu.PATIENT_NAME).toString());
          } else if (item.keySet().contains(CoreConstant.ReportMenu.PATIENT_BED)) {
            // ベッド表示順
            tmpSortKey.add(index,"bed_order");
            tmpSortDirection.add(index,item.get(CoreConstant.ReportMenu.PATIENT_BED).toString());
          } else if (item.keySet().contains(CoreConstant.ReportMenu.PATIENT_COOL)) {
            // クール表示順
            tmpSortKey.add(index,"kur_order");
            tmpSortDirection.add(index,item.get(CoreConstant.ReportMenu.PATIENT_COOL).toString());
          } else if (item.keySet().contains(CoreConstant.ReportMenu.ENTRANCE_EXIT_CLASSIFICATION)) {
            // 入外区分
            tmpSortKey.add(index,"in_out_class");
            tmpSortDirection.add(index,item.get(CoreConstant.ReportMenu.ENTRANCE_EXIT_CLASSIFICATION).toString());
          }
          else if (item.keySet().contains(CoreConstant.ReportMenu.DIALYSIS_ROOM_GROUP1)) {
            // 透析室表示順
            tmpSortKey.add(index, "room_group_order");
            tmpSortDirection.add(index, item.get(CoreConstant.ReportMenu.DIALYSIS_ROOM_GROUP1).toString());
          }
          else if (item.keySet().contains(CoreConstant.ReportMenu.ROOM_BED_GROUP1)) {
            // ベッドグループ
            tmpSortKey.add(index, "bed_group_order");
            tmpSortDirection.add(index, item.get(CoreConstant.ReportMenu.ROOM_BED_GROUP1).toString());
          }
        }

        List sortKey = tmpSortKey;
        List sortDirection = tmpSortDirection;
        for(int indexSort = 0;indexSort < tmpSortKey.size();indexSort++) {
          for (int index = 0; index < tmpList.size();index++) {
            if ("bed_order".equals(tmpSortKey.get(indexSort))) {
              if (StringUtils.isEmpty(tmpList.get(index).get("bed_order").toString())) {
                tmpList.get(index).put("bed_order","asc".equals(sortDirection.get(indexSort)) ? "999999999":"-999999999");
              }
            } else if ("kur_order".equals(tmpSortKey.get(indexSort))) {
              if (StringUtils.isEmpty(tmpList.get(index).get("kur_order").toString())) {
                tmpList.get(index).put("kur_order","asc".equals(sortDirection.get(indexSort)) ? "999999999" : "-999999999");
              }
            } else if ("room_group_order".equals(tmpSortKey.get(indexSort))) {
              if (StringUtils.isEmpty(tmpList.get(index).get("room_group_order").toString())
                || StringUtils.isEmpty(tmpList.get(index).get("room_group_order").toString().replace("0",""))) {
                tmpList.get(index).put("room_group_order","asc".equals(sortDirection.get(indexSort)) ? "999999999" : "-999999999");
              }
            } else if ("bed_group_order".equals(tmpSortKey.get(indexSort))) {
              if (StringUtils.isEmpty(tmpList.get(index).get("bed_group_order").toString())
                || StringUtils.isEmpty(tmpList.get(index).get("bed_group_order").toString().replace("0",""))) {
                tmpList.get(index).put("bed_group_order","asc".equals(sortDirection.get(indexSort)) ? "999999999" : "-999999999");
              }
            }
          }
        }
        if (sortKey.contains("in_out_class")) {
          for (int index = 0;index < tmpList.size();index++) {
            if (tmpList.get(index).get("in_out_class").equals("2")) {
              tmpList.get(index).put("in_out_class",sortDirection.get(sortKey.indexOf("in_out_class")).equals("asc") ? "999999998" : "-999999999");
            } else if (tmpList.get(index).get("in_out_class").equals("3")) {
              tmpList.get(index).put("in_out_class",sortDirection.get(sortKey.indexOf("in_out_class")).equals("asc") ? "999999999" : "-999999998");
            } else if (tmpList.get(index).get("in_out_class").equals("")){
              tmpList.get(index).put("in_out_class",sortDirection.get(sortKey.indexOf("in_out_class")).equals("asc") ? "9999999999" : "-999999997");
            }
          }
        }

        // 並び替え
        tmpList = dialysisReportOrOnePatientCompare(tmpList, sortKey, sortDirection);

        if (sortKey.contains("in_out_class")) {
          for (int index = 0;index < tmpList.size();index++) {
            if (tmpList.get(index).get("in_out_class").equals("999999998") ||
              tmpList.get(index).get("in_out_class").equals("-999999999")) {
              tmpList.get(index).put("in_out_class","2");
            } else if (tmpList.get(index).get("in_out_class").equals("999999999") ||
              tmpList.get(index).get("in_out_class").equals("-999999998")) {
              tmpList.get(index).put("in_out_class","3");
            } else if (tmpList.get(index).get("in_out_class").equals("9999999999") ||
              tmpList.get(index).get("in_out_class").equals("-999999997")){
              tmpList.get(index).put("in_out_class","");
            }
          }
        }

        for(int indexSort = 0;indexSort < tmpSortKey.size();indexSort++) {
          for (int index = 0; index < tmpList.size();index++) {
            if ("bed_order".equals(tmpSortKey.get(indexSort))) {
              if ("999999999".equals(tmpList.get(index).get("bed_order").toString()) ||
                "-999999999".equals(tmpList.get(index).get("bed_order").toString())) {
                tmpList.get(index).put("bed_order","");
              }
            } else if ("kur_order".equals(tmpSortKey.get(indexSort))) {
              if ("999999999".equals(tmpList.get(index).get("kur_order").toString()) ||
                "-999999999".equals(tmpList.get(index).get("kur_order").toString())) {
                tmpList.get(index).put("kur_order","");
              }
            } else if ("room_group_order".equals(tmpSortKey.get(indexSort))) {
              if ("999999999".equals(tmpList.get(index).get("room_group_order").toString()) ||
                "-999999999".equals(tmpList.get(index).get("room_group_order").toString())) {
                tmpList.get(index).put("room_group_order","");
              }
            } else if ("bed_group_order".equals(tmpSortKey.get(indexSort))) {
              if ("999999999".equals(tmpList.get(index).get("bed_group_order").toString()) ||
                "-999999999".equals(tmpList.get(index).get("bed_group_order").toString())) {
                tmpList.get(index).put("bed_group_order","");
              }
            }
          }
        }

        // ソートしたデータを適用
        List<Long> tmpListPatId = new ArrayList<>();
        List<Long> tmpListOrdNo = new ArrayList<>();
        for (JSONObject tmpJson : tmpList) {
          tmpListPatId.add(tmpJson.getLong(patIdStr));
          tmpListOrdNo.add(tmpJson.getLong(ordNoStr));
        }
        if (dataKey.get("patIds") != null && dataKey.get("ordNos") != null ) {
          dataKey.put("patIds",tmpListPatId);
          dataKey.put("ordNos",tmpListOrdNo);
        }
      }
    }
    // 単患者帳票
    else if (mstReport.getReportClass().equals(ReportConstant.ReportClass.ONE_PATIENT_REPORT)) {
      List tmpSortKey = new ArrayList();
      List tmpSortDirection = new ArrayList();
      List<PatExamMain> examMainList = new ArrayList<>();
      Map<String,PatExamMain> newExamMainList = new HashMap<>();

      listPatId = dataKey.get("patIds") == null ? new ArrayList<>(): (ArrayList)dataKey.get("patIds");
      listOrdNo = dataKey.get("ordNos") == null ? new ArrayList<>(): (ArrayList)dataKey.get("ordNos");
      if("exam_date".equals(dataKey.get("dateKind"))){
        // 検査日指定：検査日の存在する日の ordNo をリストに格納します。該当のordNoが存在しない場合は、-1Lを格納します。
        // del #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe start
//        if (regOrderClassList.size() == 0) {
//          // 検査区分が全て未チェックの場合は、全選択扱いとする
//          regOrderClassList = new ArrayList<String>(Arrays.asList("1", "2", "0"));
//        }
        // del #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe end

        // 期間内の透析日リストを取得
        for (Long patId : patIdList) {

          examMainList = reportMenuDao.selectExamByDate(patId, Timestamp.valueOf(localDateFrom), Timestamp.valueOf(localDateTo), regOrderClassList);
          if (examMainList.size()>0) {
            newExamMainList.put(patId.toString(),examMainList.get(0));
          }
        }
      }

      // sortConditions (帳票画面>並び替え設定) は、優先3番目 → 優先2番目 → 優先1番目の順でデータがくることを想定しています (帳票種別：8：ラベルの並び替えと同様)
      if (sortConditions != null && sortConditions.size() > 0 && patIdList.size() > 0) {

        String patIdStr = "pat_id";
        String ordNoStr = "ord_no";
        // 01：患者IDのリストを、jsonのリストにまとめる
        List<JSONObject> tmpList = new ArrayList<>();
        for (int idx = 0; idx < patIdList.size(); idx++) {
          JSONObject jsonData = new JSONObject();
          jsonData.put(patIdStr, patIdList.get(idx));
          jsonData.put(ordNoStr, listOrdNo.get(idx).toString());
          jsonData.put("treat_date", "");
          jsonData.put("hosp_pat_id", "");
          jsonData.put("in_out_class", "");
          jsonData.put("pat_full_name", "");
          jsonData.put("bed_order", "");
          jsonData.put("kur_order", "");
          tmpList.add(jsonData);
        }

        // 02：ソートに必要なデータを「01」で作成したjsonのリストに格納する
        // ※：画面上で並び順を 第1→患者ID(昇順)、第2→患者ID(降順) とした場合、sortConditions は 患者ID(昇順) 1件のみで送られてきます
        // ※：患者ID/入外区分のデータは1度の処理で取得できる為、フラグで2回通らないようにします
        boolean ppmhPassedFlg = false;
        boolean ordPassedFlg = false;
        for (int index = 0; index < sortConditions.size(); index++) {
          Map<String, String> item = sortConditions.get(sortConditions.size() - (index+1));

          if (item.keySet().contains(CoreConstant.ReportMenu.DIALYSIS_DAY)) {
            if ("dialysis_date".equals(String.valueOf(dataKey.get("dateKind")))) {
              // 透析日データを取得 ( 透析日は、開始日～終了日で検索し、開始日に近いほうのデータを使用してソートを行う )
              Config config = defaultDbConfig;
              SelectBuilder builder = SelectBuilder.newInstance(config);
              builder.sql("select pat_id, min(treat_date) as treat_date from ord_main where pat_id in (");
              for (Long patId : patIdList) {
                builder.param(Long.class, patId);
                builder.sql(",");
              }
              builder.removeLast();
              builder.sql(") and treat_date >= '" + localDateFrom.format(DateTimeFormatter.ofPattern("yyyyMMdd")) + "' ");
              builder.sql("and treat_date <= '" + localDateTo.format(DateTimeFormatter.ofPattern("yyyyMMdd")) + "' group by pat_id");
              List<Map<String, Object>> results = baseEntityDao.executeSql(builder);
              // 患者ID毎に透析日を格納
              for (JSONObject tmpJson : tmpList) {
                Long patId = tmpJson.getLong(patIdStr);
                for (Map<String, Object> tmpMap : results) {
                  Long tmpId = Long.valueOf(tmpMap.get(patIdStr).toString());
                  if (tmpId.equals(patId)) {
                    tmpJson.put("treat_date", tmpMap.get("treat_date").toString());
                  }
                }
              }
            }
            else {
              for (JSONObject tmpJson : tmpList) {
                Long patId = tmpJson.getLong(patIdStr);
                for (String tmpMap : newExamMainList.keySet()) {
                  Long tmpId = Long.valueOf(tmpMap);
                  if (tmpId.equals(patId)) {
                    if (newExamMainList.get(tmpMap).getResultExamDate() !=null) {
                      tmpJson.put("treat_date", newExamMainList.get(tmpMap).getResultExamDate().toString());
                      continue;
                    } else if (newExamMainList.get(tmpMap).getRegExamDate() != null) {
                      tmpJson.put("treat_date", newExamMainList.get(tmpMap).getRegExamDate().toString());
                      continue;
                    } else {
                      tmpJson.put("treat_date","");
                      continue;
                    }
                  }
                }
              }
            }
          }
          else if ((item.keySet().contains(CoreConstant.ReportMenu.PATIENT_ID) ||
            item.keySet().contains(CoreConstant.ReportMenu.ENTRANCE_EXIT_CLASSIFICATION) ||
            item.keySet().contains(CoreConstant.ReportMenu.PATIENT_NAME)) && !ppmhPassedFlg) {
            // 患者ID/入外区分/患者名のデータを取得

            // mongoDB検索条件作成
            ArrayList<Bson> arr = new ArrayList<Bson>();
            arr.add(lt("up_date", mongFromDate));
            List<String> searchPatIdlist = new ArrayList<>();
            for (JSONObject tmpJson : tmpList) {
              searchPatIdlist.add(tmpJson.get(patIdStr).toString());
            }
            arr.add(in(patIdStr, searchPatIdlist));
            Bson bson = and(arr);
            // mongoDB検索処理
            FindIterable<Document> resultDocs = mongoTemplate.getCollection("pat_personal_main_history").find(bson).sort(descending("up_date"));
            // 患者ID毎に患者ID/入外区分を格納
            for (JSONObject tmpJson : tmpList) {
              Document doc = resultDocs != null ? resultDocs.filter(eq(patIdStr, tmpJson.get(patIdStr).toString())).first() : new Document();
              String InOutClass = "";
              if(null != tmpJson.get(ordNoStr) && !tmpJson.get(ordNoStr).equals("")){
                InOutClass = rdMainDao.getInOutClass(String.valueOf(dataKey.get("facilityCd")), tmpJson.get(ordNoStr).toString(), tmpJson.get(patIdStr).toString());
              }
              // 患者ID ( ソート用に0埋めして格納 )
              // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 start
//              tmpJson.put("hosp_pat_id", String.format("%12s", doc.get("hosp_pat_id").toString()).replace(" ", "0"));
              tmpJson.put("hosp_pat_id", doc.get("hosp_pat_id").toString());
              // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 end
              // 入外区分
              if ("dialysis_date".equals(String.valueOf(dataKey.get("dateKind"))) && null != InOutClass && !InOutClass.equals("")) {
                tmpJson.put("in_out_class", InOutClass);
              } else {
                tmpJson.put("in_out_class", doc.get("in_out_class") != null ? doc.get("in_out_class") : "");
              }

              // 患者名
              // mod #11513 患者名が指定文字数ぶん出ない 高 start
//              tmpJson.put("pat_full_name", doc.get("pat_last_name").toString() + " " + doc.get("pat_first_name").toString());
              // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 start
              //  カナ優先として半角スペースで連結し、ソート用キーを作成。文字列としてソートするソート用キーーカナ姓(漢字姓)&&カナ名(漢字名)
              if (doc.get("pat_last_name") != null && doc.get("pat_first_name") != null){
                if (doc.get("pat_last_name") != null && doc.get("pat_first_name") != null) {
                  String lastName = !StringUtils.isEmpty((CharSequence) doc.get("pat_last_name_kana")) ? String.valueOf(doc.get("pat_last_name_kana"))
                    : String.valueOf(doc.get("pat_last_name"));
                  String firstName = !StringUtils.isEmpty((CharSequence) doc.get("pat_first_name_kana")) ? String.valueOf(doc.get("pat_first_name_kana"))
                    : String.valueOf(doc.get("pat_first_name"));
                  tmpJson.put("pat_full_name", lastName + " " + firstName);
                }
              }
//              tmpJson.put("pat_full_name", doc.get("pat_last_name").toString() + "" + doc.get("pat_first_name").toString());
              // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 end
              // mod #11513 患者名が指定文字数ぶん出ない 高 end
            }
            ppmhPassedFlg = true;

          } else if (item.keySet().contains(CoreConstant.ReportMenu.PATIENT_BED) ||
            item.keySet().contains(CoreConstant.ReportMenu.PATIENT_COOL) && !ordPassedFlg) {
            // マスタデータを取得
            SelectOptions options = SelectOptions.get();
            List<MstBed> mstBedList = new ArrayList<>();
            List<MstKur> mstKurList = new ArrayList<>();
            mstBedList = mstBedDao.selectByFacilityCd(String.valueOf(dataKey.get("facilityCd")), "1", "0");
            mstKurList = mstKurDao.selectByFacilityCd(options, String.valueOf(dataKey.get("facilityCd")), "0");

            for (JSONObject tmpJson : tmpList) {
              Long patId = tmpJson.getLong(patIdStr);
              // ordMainから取得する値
              for (OrdMain ord : ordList) {
                if (patId.equals(ord.getPatId())) {
                  // ベッド
                  for (Integer bedListIndex = 0; bedListIndex < mstBedList.size(); bedListIndex++ ) {
                    if (ord.getIndBedCd().toString().equals(mstBedList.get(bedListIndex).getBedCd().toString())) {
                      tmpJson.put("bed_order", String.format("%5s", bedListIndex.toString()).replace(" ", "0"));
                    }
                  }
                  // クール
                  for (Integer kurListIndex = 0; kurListIndex < mstKurList.size(); kurListIndex++ ) {
                    if (ord.getIndKurCd().toString().equals(mstKurList.get(kurListIndex).getKurCd().toString())) {
                      tmpJson.put("kur_order", String.format("%3s", kurListIndex.toString()).replace(" ", "0"));
                    }
                  }
                }
              }
            }
            ordPassedFlg = true;
          }
        }

        // 03：条件により並び替えを実施する
        List<Map<String, String>> treatList = new ArrayList();
        treatList = sortConditions.stream().filter(p->p.containsKey(CoreConstant.ReportMenu.DIALYSIS_DAY)).collect(Collectors.toList());
        for (int index = 0; index < treatList.size();index++) {
          Map<String, String> item = treatList.get(treatList.size() - (index+1));
          if (item.keySet().contains(CoreConstant.ReportMenu.DIALYSIS_DAY)) {
            // 透析日
            tmpSortKeyStr = "treat_date";
            tmpSortDirectionStr = item.get(CoreConstant.ReportMenu.DIALYSIS_DAY).toString();

          }
        }
        sortConditions = sortConditions.stream().filter(p->!p.containsKey(CoreConstant.ReportMenu.DIALYSIS_DAY)).collect(Collectors.toList());
        for (int index = 0; index < sortConditions.size(); index++) {
          Map<String, String> item = sortConditions.get(sortConditions.size() - (index+1));
          if (item.keySet().contains(CoreConstant.ReportMenu.PATIENT_ID)) {
            // 患者ID
            tmpSortKey.add(index,"hosp_pat_id");
            tmpSortDirection.add(index,item.get(CoreConstant.ReportMenu.PATIENT_ID).toString());
          } else if (item.keySet().contains(CoreConstant.ReportMenu.ENTRANCE_EXIT_CLASSIFICATION)) {
            // 入外区分
            tmpSortKey.add(index,"in_out_class");
            tmpSortDirection.add(index,item.get(CoreConstant.ReportMenu.ENTRANCE_EXIT_CLASSIFICATION).toString());
          } else if (item.keySet().contains(CoreConstant.ReportMenu.PATIENT_NAME)) {
            // 患者名
            tmpSortKey.add(index,"pat_full_name");
            tmpSortDirection.add(index,item.get(CoreConstant.ReportMenu.PATIENT_NAME).toString());
          } else if (item.keySet().contains(CoreConstant.ReportMenu.PATIENT_BED)) {
            // ベッド表示順
            tmpSortKey.add(index,"bed_order");
            tmpSortDirection.add(index,item.get(CoreConstant.ReportMenu.PATIENT_BED).toString());
          } else if (item.keySet().contains(CoreConstant.ReportMenu.PATIENT_COOL)) {
            // クール表示順
            tmpSortKey.add(index,"kur_order");
            tmpSortDirection.add(index,item.get(CoreConstant.ReportMenu.PATIENT_COOL).toString());
          }
        }
        List sortKey = tmpSortKey;
        List sortDirection = tmpSortDirection;

        if (sortKey.contains("in_out_class")) {
          for (int index = 0;index < tmpList.size();index++) {
            if (tmpList.get(index).get("in_out_class").equals("2")) {
              tmpList.get(index).put("in_out_class",sortDirection.get(sortKey.indexOf("in_out_class")).equals("asc") ? "999999998" : "-999999999");
            }else if (tmpList.get(index).get("in_out_class").equals("3")) {
              tmpList.get(index).put("in_out_class",sortDirection.get(sortKey.indexOf("in_out_class")).equals("asc") ? "999999999" : "-999999998");
            }
          }
        }
        if (sortKey.contains("bed_order")) {
          for (int index = 0;index < tmpList.size();index++) {
            if (StringUtils.isEmpty(tmpList.get(index).get("bed_order").toString())) {
              tmpList.get(index).put("bed_order",sortDirection.get(sortKey.indexOf("bed_order")).equals("asc") ? "999999999" : "-999999999");
            }
          }
        }
        if (sortKey.contains("kur_order")) {
          for (int index = 0;index < tmpList.size();index++) {
            if (StringUtils.isEmpty(tmpList.get(index).get("kur_order").toString())) {
              tmpList.get(index).put("kur_order",sortDirection.get(sortKey.indexOf("kur_order")).equals("asc") ? "999999999" : "-999999999");
            }
          }
        }
        // 並び替え
        tmpList = dialysisReportOrOnePatientCompare(tmpList,sortKey,sortDirection);

        if (sortKey.contains("in_out_class")) {
          for (int index = 0;index < tmpList.size();index++) {
            if (tmpList.get(index).get("in_out_class").equals("999999998") || tmpList.get(index).get("in_out_class").equals("-999999999")) {
              tmpList.get(index).put("in_out_class","2");
            } else if (tmpList.get(index).get("in_out_class").equals("999999999") || tmpList.get(index).get("in_out_class").equals("-999999998")) {
              tmpList.get(index).put("in_out_class","3");
            }
          }
        }
        if (sortKey.contains("bed_order")) {
          for (int index = 0;index < tmpList.size();index++) {
            if (tmpList.get(index).get("bed_order").equals("999999999") || tmpList.get(index).get("bed_order").equals("-999999999")) {
              tmpList.get(index).put("bed_order","");
            }
          }
        }
        if (sortKey.contains("kur_order")) {
          for (int index = 0;index < tmpList.size();index++) {
            if (tmpList.get(index).get("kur_order").equals("999999999") || tmpList.get(index).get("kur_order").equals("-999999999")) {
              tmpList.get(index).put("kur_order","");
            }
          }
        }

        // ソートしたデータを適用
        List<Long> tmpPatIdList = new ArrayList<>();
        for (JSONObject tmpJson : tmpList) {
          if (!tmpPatIdList.contains(tmpJson.getLong(patIdStr))) {
            tmpPatIdList.add(tmpJson.getLong(patIdStr));
          }
        }
        patIdList = tmpPatIdList;

        dataKey.put(tmpSortKeyStr,tmpSortDirectionStr);
        if (dataKey.get("patIds") != null) {
          dataKey.put("patIds",patIdList);
        }
      }
    }
    // 複数患者帳票
    else if (mstReport.getReportClass().equals(ReportConstant.ReportClass.MULTIPLE_PATIENT_REPORT)) {
      List<String> sqlCodes = getSqlCode(params);
      List<OrdMain> questionMarkPatId = rdMainDao.selectOrdMainByNullPatId(String.valueOf(dataKey.get("facilityCd")),
        dataKey.get("fromDate").toString(),
        dataKey.get("toDate").toString());
      listPatId = dataKey.get("patIds") == null ? new ArrayList<>(): (ArrayList)dataKey.get("patIds");
      listOrdNo = dataKey.get("ordNos") == null ? new ArrayList<>(): (ArrayList)dataKey.get("ordNos");
      if (!sqlCodes.contains("133") || (sqlCodes.contains("133") && questionMarkPatId.size() == 0)) {
        // sortConditions (帳票画面>並び替え設定) は、優先3番目 → 優先2番目 → 優先1番目の順でデータがくることを想定しています (帳票種別：8：ラベルの並び替えと同様)
        if (sortConditions != null && sortConditions.size() > 0 && patIdList.size() > 0) {
          dataKey.put("sortFlag","0");

          String patIdStr = "pat_id";
          String ordNoStr = "ord_no";
          // 01：患者IDのリストを、jsonのリストにまとめる
          List<JSONObject> tmpList = new ArrayList<>();
          for (int idx = 0; idx < listPatId.size(); idx++) {
            JSONObject jsonData = new JSONObject();
            jsonData.put(patIdStr, listPatId.get(idx));
            jsonData.put(ordNoStr, idx < listOrdNo.size() ?  listOrdNo.get(idx) : "");
            jsonData.put("treat_date", "");
            jsonData.put("hosp_pat_id", "");
            jsonData.put("in_out_class", "");
            jsonData.put("pat_name_kana", "");
            jsonData.put("pat_group_order", "");
            jsonData.put("pat_sex", "");
            jsonData.put("pat_blood_type_abo", "");
            jsonData.put("pat_blood_type_rh", "");
            jsonData.put("is_infect", "");
            jsonData.put("bed_order", "");
            jsonData.put("bed_group_order", "");
            jsonData.put("kur_order", "");
            jsonData.put("start_time", "");
            jsonData.put("end_time", "");
            jsonData.put("ind_end_date", "");
            jsonData.put("ind_end_date_time", "");
            tmpList.add(jsonData);
          }

          // 02：ソートに必要なデータを「01」で作成したjsonのリストに格納する
          // ※：画面上で並び順を 第1→患者ID(昇順)、第2→患者ID(降順) とした場合、sortConditions は 患者ID(昇順) 1件のみで送られてきます
          // ※：患者ID/入外区分/フリガナ/性別/血液型、ベッド/クールのデータは1度の処理で取得できる為、フラグで2回通らないようにします
          boolean ppmhPassedFlg = false;
          boolean ordPassedFlg = false;
          for (int index = 0; index < sortConditions.size(); index++) {
            Map<String, String> item = sortConditions.get(sortConditions.size() - (index+1));

            if ((item.keySet().contains(CoreConstant.ReportMenu.PATIENT_ID) ||
              item.keySet().contains(CoreConstant.ReportMenu.ENTRANCE_EXIT_CLASSIFICATION) ||
              item.keySet().contains(CoreConstant.ReportMenu.READING) ||
              item.keySet().contains(CoreConstant.ReportMenu.SEX) ||
              item.keySet().contains(CoreConstant.ReportMenu.BLOOD_TYPE)) && !ppmhPassedFlg) {
              // 患者ID/入外区分/フリガナ/性別/血液型のデータを取得

              // mongoDB検索条件作成
              ArrayList<Bson> arr = new ArrayList<Bson>();
              arr.add(lt("up_date", mongFromDate));
              List<String> searchPatIdlist = new ArrayList<>();
              for (JSONObject tmpJson : tmpList) {
                searchPatIdlist.add(tmpJson.get(patIdStr).toString());
              }
              arr.add(in(patIdStr, searchPatIdlist));
              Bson bson = and(arr);
              // mongoDB検索処理
              FindIterable<Document> resultDocs = mongoTemplate.getCollection("pat_personal_main_history").find(bson).sort(descending("up_date"));
              // 患者ID毎に患者ID/入外区分を格納
              for (JSONObject tmpJson : tmpList) {
                Document doc = resultDocs != null ? resultDocs.filter(eq(patIdStr, tmpJson.get(patIdStr).toString())).first() : new Document();
                String inOutClass = "";
                if (!StringUtils.isEmpty(tmpJson.get(ordNoStr).toString()) && !StringUtils.isEmpty(tmpJson.get(patIdStr).toString())) {
                  inOutClass = rdMainDao.getInOutClass(String.valueOf(dataKey.get("facilityCd")),tmpJson.get(ordNoStr).toString(),tmpJson.get(patIdStr).toString());
                }

                if (doc != null) {
                  // 患者ID ( ソート用に0埋めして格納 )
                  // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 start
//                  tmpJson.put("hosp_pat_id", String.format("%12s", doc.get("hosp_pat_id").toString()).replace(" ", "0"));
                  tmpJson.put("hosp_pat_id", doc.get("hosp_pat_id").toString());
                  // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 end
                  // 入外区分
                  if ("dialysis_date".equals(String.valueOf(dataKey.get("dateKind"))) && inOutClass !=null) {
                    tmpJson.put("in_out_class", inOutClass);
                  } else {
                    tmpJson.put("in_out_class", doc.get("in_out_class") != null ? doc.get("in_out_class") : "");
                  }
                  // フリガナ
                  // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 start
//                  if (doc.get("pat_last_name_kana")!=null && doc.get("pat_first_name_kana")!=null) {
//                    // mod #11513 患者名が指定文字数ぶん出ない 高 start
////                    tmpJson.put("pat_name_kana", doc.get("pat_last_name_kana") + " " + doc.get("pat_first_name_kana"));
//                    tmpJson.put("pat_name_kana", doc.get("pat_last_name_kana") + "" + doc.get("pat_first_name_kana"));
//                    // mod #11513 患者名が指定文字数ぶん出ない 高 end
//                  } else if (doc.get("pat_last_name_kana")==null && doc.get("pat_first_name_kana")!=null) {
//                    tmpJson.put("pat_name_kana", doc.get("pat_first_name_kana"));
//                  } else if (doc.get("pat_last_name_kana") != null && doc.get("pat_first_name_kana") == null) {
//                    tmpJson.put("pat_name_kana", doc.get("pat_last_name_kana"));
//                  } else {
//                    tmpJson.put("pat_name_kana", "");
//                  }
                  // カナ優先として半角スペースで連結し、ソート用キーを作成。文字列としてソートするソート用キーーカナ姓(漢字姓)&&カナ名(漢字名)
                  if (doc.get("pat_last_name") != null && doc.get("pat_first_name") != null) {
                    String lastName = !StringUtils.isEmpty((CharSequence) doc.get("pat_last_name_kana")) ? String.valueOf(doc.get("pat_last_name_kana"))
                      : String.valueOf(doc.get("pat_last_name"));
                    String firstName = !StringUtils.isEmpty((CharSequence) doc.get("pat_first_name_kana")) ? String.valueOf(doc.get("pat_first_name_kana"))
                      : String.valueOf(doc.get("pat_first_name"));
                    tmpJson.put("pat_name_kana", lastName + " " + firstName);
                  }
                  // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 end

                  // 性別
                  tmpJson.put("pat_sex", doc.get("pat_sex"));
                  // 血液型
                  tmpJson.put("pat_blood_type_abo", doc.get("pat_blood_type_abo") !=null ? doc.get("pat_blood_type_abo") : "");
                  tmpJson.put("pat_blood_type_rh", doc.get("pat_blood_type_rh") != null ? doc.get("pat_blood_type_rh") : "");
                }
              }
              ppmhPassedFlg = true;

            } else if (item.keySet().contains(CoreConstant.ReportMenu.INFECTIOUS_ISEASE_PATIENTS)) {
              // 感染症患者のデータを取得

              // mongoDB検索条件作成
              ArrayList<Bson> arr = new ArrayList<Bson>();
              arr.add(lt("up_date", mongFromDate));
              List<String> list = new ArrayList<>();
              for (JSONObject tmpJson : tmpList) {
                list.add(tmpJson.get(patIdStr).toString());
              }
              arr.add(in(patIdStr, list));
              Bson bson = and(arr);
              // mongoDB検索処理
              FindIterable<Document> resultDocs = mongoTemplate.getCollection("pat_main_history").find(bson).sort(descending("up_date"));
              // 患者ID毎に感染症患者を格納
              for (JSONObject tmpJson : tmpList) {
                Document doc = resultDocs != null ? resultDocs.filter(eq(patIdStr, tmpJson.get(patIdStr).toString())).first() : new Document();
                if (doc != null) {
                  // 感染症患者
                  tmpJson.put("is_infect", doc.get("is_infect"));
                }
              }
            } else if (item.keySet().contains(CoreConstant.ReportMenu.PATIENT_BED) ||
              item.keySet().contains(CoreConstant.ReportMenu.PATIENT_COOL) ||
              item.keySet().contains(CoreConstant.ReportMenu.ROOM_BED_GROUP)
                && !ordPassedFlg) {
              // マスタデータを取得
              SelectOptions options = SelectOptions.get();
              List<MstBed> mstBedList = mstBedDao.selectByFacilityCd(String.valueOf(dataKey.get("facilityCd")), "1", "0");
              List<MstKur> mstKurList = mstKurDao.selectByFacilityCd(options, String.valueOf(dataKey.get("facilityCd")), "0");

              for (JSONObject tmpJson : tmpList) {
                String ordNo = tmpJson.get(ordNoStr).toString();
                String patId = tmpJson.get(patIdStr).toString();
                // ordMainから取得する値
                for (OrdMain ord : ordList) {
                  if (ordNo.equals(ord.getOrdNo().toString())) {
                    // ベッド, ベッドグループ表示順
                    for (Integer bedListIndex = 0; bedListIndex < mstBedList.size(); bedListIndex++ ) {
                      // mod #11603 検査予定のラベル出力とフィルタ機能 高 start
//                      if (ord.getIndBedCd().toString().equals(mstBedList.get(bedListIndex).getBedCd().toString())) {
                      if (String.valueOf(ord.getIndBedCd()).equals(mstBedList.get(bedListIndex).getBedCd().toString())) {
                        // mod #11603 検査予定のラベル出力とフィルタ機能 高 end
                        tmpJson.put("bed_order", String.format("%5s", bedListIndex.toString()).replace(" ", "0"));
                        Integer bedGroupIndex = 999;
                        bedGroupIndex = mstRoomBedGroupDao.selectIndexBedCdIsContain(ord.getIndBedCd().toString(), String.valueOf(dataKey.get("facilityCd")), "1");
                        tmpJson.put("bed_group_order", String.format("%3s", bedGroupIndex.toString()).replace(" ", "0"));
                      }
                    }
                    // クール
                    for (Integer kurListIndex = 0; kurListIndex < mstKurList.size(); kurListIndex++ ) {
                      // mod #11603 検査予定のラベル出力とフィルタ機能 高 start
//                      if (ord.getIndKurCd().toString().equals(mstKurList.get(kurListIndex).getKurCd().toString())) {
                      if (String.valueOf(ord.getIndKurCd()).equals(mstKurList.get(kurListIndex).getKurCd().toString())) {
                        // mod #11603 検査予定のラベル出力とフィルタ機能 高 end
                        tmpJson.put("kur_order", String.format("%3s", kurListIndex.toString()).replace(" ", "0"));
                      }
                    }
                  }
                }
              }
              ordPassedFlg = true;
            }
            else if (item.keySet().contains(CoreConstant.ReportMenu.RST_START_DATE) ||
              item.keySet().contains(CoreConstant.ReportMenu.RST_END_DATE) ||
              item.keySet().contains(CoreConstant.ReportMenu.IND_END_DATE) ||
              item.keySet().contains(CoreConstant.ReportMenu.IND_END_DATE_TIME) ){
              for (JSONObject tmpJson : tmpList) {
                String ordNo = tmpJson.get(ordNoStr).toString();
                String patId = tmpJson.get(patIdStr).toString();
                // ordMainから取得する値
                for (OrdMain ord : ordList) {
                  if (ordNo.equals(ord.getOrdNo().toString())) {
                    MniMonitorRemainingTime remainingTime = mniMonitorDao.selectRemainingTime(Long.parseLong(ordNo),
                      String.valueOf(dataKey.get("facilityCd")),
                      Long.parseLong(patId),dataKey.get("fromDate").toString(),
                      dataKey.get("toDate").toString());
                    if (item.keySet().contains(CoreConstant.ReportMenu.RST_START_DATE) && ord.getRstStartDate() != null) {
                      // 透析開始
                      LocalDateTime startDate = ord.getRstStartDate().toLocalDateTime();
                      if (startDate != null ) {
                        tmpJson.put("start_time", startDate.toString());
                      }
                    } else if (item.keySet().contains(CoreConstant.ReportMenu.RST_END_DATE) && ord.getRstEndDate() != null) {
                      // 透析終了
                      LocalDateTime endDate = ord.getRstEndDate().toLocalDateTime();
                      if (endDate != null ) {
                        tmpJson.put("end_time", endDate.toString());
                      }
                    } else if (item.keySet().contains(CoreConstant.ReportMenu.IND_END_DATE) && ord.getRstStartDate() != null) {
                      if (remainingTime != null) {
                        tmpJson.put("ind_end_date", remainingTime.getInd_end_date());
                      }
                    } else if (item.keySet().contains(CoreConstant.ReportMenu.IND_END_DATE_TIME) && ord.getRstStartDate() != null) {
                      // 終了予測（透析開始日時＋（透析残り時間と除水残り時間のうち値が大きい方））
                      if (remainingTime != null && remainingTime.getInd_end_date_time() != null) {
                        tmpJson.put("ind_end_date_time", remainingTime.getInd_end_date_time());
                      }
                    }
                  }
                }
              }
            }
            else if (item.keySet().contains(CoreConstant.ReportMenu.PATIENT_GROUP)) {
              for (JSONObject tmpJson : tmpList) {
                Integer patGroupIndex = 999;
                patGroupIndex = patGroupDao.selectIndexPatIdIsContain(tmpJson.get(patIdStr).toString(), String.valueOf(dataKey.get("facilityCd")));
                tmpJson.put("pat_group_order", String.format("%3s", patGroupIndex.toString()).replace(" ", "0"));
              }
            }
          }

          // 03：条件により並び替えを実施する
          List tmpSortKey = new ArrayList();
          List tmpSortDirection = new ArrayList();
          List sortKeyName = new ArrayList();
          String[] newTmpSortKey = new String[]{};
          for (int index = 0; index < sortConditions.size(); index++) {
            Map<String, String> item = sortConditions.get(sortConditions.size() - (index+1));
            // 並び替えに使用する項目を取得
            if (item.keySet().contains(CoreConstant.ReportMenu.DIALYSIS_DAY)) {
              // 透析日
              tmpSortKey.add(index,"treat_date");
              sortKeyName.add(index,CoreConstant.ReportMenu.DIALYSIS_DAY);
              tmpSortDirection.add(index,item.get(CoreConstant.ReportMenu.DIALYSIS_DAY).toString());

            } else if (item.keySet().contains(CoreConstant.ReportMenu.PATIENT_ID)) {
              // 患者ID
              tmpSortKey.add(index,"hosp_pat_id");
              sortKeyName.add(index,CoreConstant.ReportMenu.PATIENT_ID);
              tmpSortDirection.add(index,item.get(CoreConstant.ReportMenu.PATIENT_ID).toString());

            } else if (item.keySet().contains(CoreConstant.ReportMenu.ENTRANCE_EXIT_CLASSIFICATION)) {
              // 入外区分
              tmpSortKey.add(index,"in_out_class");
              sortKeyName.add(index,CoreConstant.ReportMenu.ENTRANCE_EXIT_CLASSIFICATION);
              tmpSortDirection.add(index,item.get(CoreConstant.ReportMenu.ENTRANCE_EXIT_CLASSIFICATION).toString());

            } else if (item.keySet().contains(CoreConstant.ReportMenu.INFECTIOUS_ISEASE_PATIENTS)) {
              // 感染症患者
              tmpSortKey.add(index,"is_infect");
              sortKeyName.add(index,CoreConstant.ReportMenu.INFECTIOUS_ISEASE_PATIENTS);
              tmpSortDirection.add(index,item.get(CoreConstant.ReportMenu.INFECTIOUS_ISEASE_PATIENTS).toString());

            } else if (item.keySet().contains(CoreConstant.ReportMenu.READING)) {
              // フリガナ
              tmpSortKey.add(index,"pat_name_kana");
              sortKeyName.add(index,CoreConstant.ReportMenu.READING);
              tmpSortDirection.add(index,item.get(CoreConstant.ReportMenu.READING).toString());

            } else if (item.keySet().contains(CoreConstant.ReportMenu.SEX)) {
              // 性別
              tmpSortKey.add(index,"pat_sex");
              sortKeyName.add(index,CoreConstant.ReportMenu.SEX);
              tmpSortDirection.add(index,item.get(CoreConstant.ReportMenu.SEX).toString());

            } else if (item.keySet().contains(CoreConstant.ReportMenu.BLOOD_TYPE)) {
              // 血液型
              tmpSortKey.add(index,"pat_blood_type_abo");
              newTmpSortKey = new String[]{"pat_blood_type_abo","pat_blood_type_rh"};
              sortKeyName.add(index,CoreConstant.ReportMenu.BLOOD_TYPE);
              tmpSortDirection.add(index,item.get(CoreConstant.ReportMenu.BLOOD_TYPE).toString());

            } else if (item.keySet().contains(CoreConstant.ReportMenu.PATIENT_BED)) {
              // ベッド表示順
              tmpSortKey.add(index,"bed_order");
              sortKeyName.add(index,CoreConstant.ReportMenu.PATIENT_BED);
              tmpSortDirection.add(index,item.get(CoreConstant.ReportMenu.PATIENT_BED).toString());

            } else if (item.keySet().contains(CoreConstant.ReportMenu.PATIENT_COOL)) {
              // クール表示順
              tmpSortKey.add(index,"kur_order");
              sortKeyName.add(index,CoreConstant.ReportMenu.PATIENT_COOL);
              tmpSortDirection.add(index,item.get(CoreConstant.ReportMenu.PATIENT_COOL).toString());

            }else if (item.keySet().contains(CoreConstant.ReportMenu.ROOM_BED_GROUP)) {
              // ベッドグループ表示順
              tmpSortKey.add(index,"bed_group_order");
              sortKeyName.add(index,CoreConstant.ReportMenu.ROOM_BED_GROUP);
              tmpSortDirection.add(index,item.get(CoreConstant.ReportMenu.ROOM_BED_GROUP).toString());

            }else if (item.keySet().contains(CoreConstant.ReportMenu.PATIENT_GROUP)) {
              // 患者グループ表示順
              tmpSortKey.add(index,"pat_group_order");
              sortKeyName.add(index,CoreConstant.ReportMenu.PATIENT_GROUP);
              tmpSortDirection.add(index,item.get(CoreConstant.ReportMenu.PATIENT_GROUP).toString());

            }else if (item.keySet().contains(CoreConstant.ReportMenu.RST_START_DATE)) {
              // 透析開始
              tmpSortKey.add(index,"start_time");
              sortKeyName.add(index,CoreConstant.ReportMenu.RST_START_DATE);
              tmpSortDirection.add(index,item.get(CoreConstant.ReportMenu.RST_START_DATE).toString());

            }else if (item.keySet().contains(CoreConstant.ReportMenu.RST_END_DATE)) {
              // 透析終了
              tmpSortKey.add(index,"end_time");
              sortKeyName.add(index,CoreConstant.ReportMenu.RST_END_DATE);
              tmpSortDirection.add(index,item.get(CoreConstant.ReportMenu.RST_END_DATE).toString());

            }else if (item.keySet().contains(CoreConstant.ReportMenu.IND_END_DATE)) {
              // 透析開始
              tmpSortKey.add(index,"ind_end_date");
              sortKeyName.add(index,CoreConstant.ReportMenu.IND_END_DATE);
              tmpSortDirection.add(index,item.get(CoreConstant.ReportMenu.IND_END_DATE).toString());

            }else if (item.keySet().contains(CoreConstant.ReportMenu.IND_END_DATE_TIME)) {
              // 透析終了
              tmpSortKey.add(index,"ind_end_date_time");
              sortKeyName.add(index,CoreConstant.ReportMenu.IND_END_DATE_TIME);
              tmpSortDirection.add(index,item.get(CoreConstant.ReportMenu.IND_END_DATE_TIME).toString());

            }
          }
          // 血液型
          List sortKey = tmpSortKey;
          List sortDirection = tmpSortDirection;
          String sortKeyOne = "";
          String sortKeyTwo = "";
          if (sortKeyName.contains(CoreConstant.ReportMenu.BLOOD_TYPE)) {
            sortKeyOne = newTmpSortKey[0];
            sortKeyTwo = newTmpSortKey[1];
            for (int num = 0;num < tmpList.size();num++){
              if (tmpList.get(num).get(sortKeyOne).equals("0")) {
                tmpList.get(num).put(sortKeyOne,sortDirection.get(sortKey.indexOf("pat_blood_type_abo")).equals("asc") ? "5" : "-5");
              }
              if (tmpList.get(num).get(sortKeyTwo).equals("0")) {
                tmpList.get(num).put(sortKeyTwo,sortDirection.get(sortKey.indexOf("pat_blood_type_abo")).equals("asc") ?  "3" : "-3");
              }
            }
          }
          // 入外区分値3(「−」はありません)値の置き換え
          if (sortKey.contains("in_out_class")) {
            for (int index = 0;index < tmpList.size();index++) {
              if (tmpList.get(index).get("in_out_class").equals("2")) {
                tmpList.get(index).put("in_out_class",sortDirection.get(sortKey.indexOf("in_out_class")).equals("asc") ? "999999998" : "-999999999");
              } else if (tmpList.get(index).get("in_out_class").equals("3")) {
                tmpList.get(index).put("in_out_class",sortDirection.get(sortKey.indexOf("in_out_class")).equals("asc") ? "999999999" : "-999999998");
              }
            }
          }
          // 患者の性別値の置き換え
          addTmpValueForSort(sortKey,sortDirection,sortKeyName,tmpList);

          tmpList = multiplePatientCompare(tmpList,sortKey,tmpSortKey,sortDirection,sortKeyOne, sortKeyTwo,sortKeyName);

          removeTmpValueForSort(sortKey,tmpList);

          if (sortKeyName.contains(CoreConstant.ReportMenu.BLOOD_TYPE)) {
            sortKeyOne = newTmpSortKey[0];
            sortKeyTwo = newTmpSortKey[1];
            for (int num = 0;num < tmpList.size();num++){
              if (tmpList.get(num).get(sortKeyOne).equals("5") || tmpList.get(num).get(sortKeyOne).equals("-5")) {
                tmpList.get(num).put(sortKeyOne,"0");
              }
              if (tmpList.get(num).get(sortKeyTwo).equals("3") || tmpList.get(num).get(sortKeyTwo).equals("-3")) {
                tmpList.get(num).put(sortKeyTwo,"0");
              }
            }
          }
          // 入外区分値3(「−」はありません)値の置き換えキャンセル
          if (sortKey.contains("in_out_class")) {
            for (int index = 0;index < tmpList.size();index++) {
              if (tmpList.get(index).get("in_out_class").equals("999999998") ||
                tmpList.get(index).get("in_out_class").equals("-999999999")) {
                tmpList.get(index).put("in_out_class","2");
              } else if (tmpList.get(index).get("in_out_class").equals("999999999") ||
                tmpList.get(index).get("in_out_class").equals("-999999998")) {
                tmpList.get(index).put("in_out_class","3");
              }
            }
          }
          // 患者の性別値の置き換えキャンセル
          // ソートしたデータを適用
          List<Long> tmpListPatId = new ArrayList<>();
          List<Long> tmpListOrdNo = new ArrayList<>();

          if (dataKey.get("patIds") != null) {
            for (JSONObject tmpJson : tmpList) {
              tmpListPatId.add(tmpJson.getLong(patIdStr));
            }
            dataKey.put("patIds",tmpListPatId);
          }
          if (dataKey.get("ordNos") != null ) {
            for (JSONObject tmpJson : tmpList) {
              tmpListOrdNo.add(tmpJson.getLong(ordNoStr));
            }
            dataKey.put("ordNos",tmpListOrdNo);
          }
        }
      }
    }
    // 配布リスト（ベッド）
    else if (mstReport.getReportClass().equals(ReportConstant.ReportClass.DISTRIBUTION_LIST_BED_REPORT)) {
      if (sortConditions != null && sortConditions.size() > 0 && patIdList.size() > 0) {
        String patIdStr = "pat_id";
        String ordNoStr = "ord_no";

        listPat = dataKey.get("patIds") == null ? new ArrayList<>(): (ArrayList)dataKey.get("patIds");
        listOrd = dataKey.get("ordNos") == null ? new ArrayList<>(): (ArrayList)dataKey.get("ordNos");
        List<JSONObject> tmpList = new ArrayList<>();
        for (int idx = 0; idx < listPat.size(); idx++) {
          JSONObject jsonData = new JSONObject();
          jsonData.put(patIdStr, listPat.get(idx));
          jsonData.put(ordNoStr, idx < listOrd.size() ?  listOrd.get(idx) : "");
          jsonData.put("bed_group_order", "");
          jsonData.put("bed_order", "");
          jsonData.put("kur_order", "");
          tmpList.add(jsonData);
        }
        for (int index = 0; index < sortConditions.size(); index++) {

          Map<String, String> item = sortConditions.get(sortConditions.size() - (index+1));
          if (item.keySet().contains(CoreConstant.ReportMenu.ROOM_BED_GROUP) ||
            item.keySet().contains(CoreConstant.ReportMenu.PATIENT_BED) ||
            item.keySet().contains(CoreConstant.ReportMenu.PATIENT_COOL)){

            // マスタデータを取得
            SelectOptions options = SelectOptions.get();
            List<MstBed> mstBedList = mstBedDao.selectByFacilityCd(String.valueOf(dataKey.get("facilityCd")), "1", "0");
            List<MstKur> mstKurList = mstKurDao.selectByFacilityCd(options, String.valueOf(dataKey.get("facilityCd")), "0");

            for (JSONObject tmpJson : tmpList) {
              String ordNo = tmpJson.get(ordNoStr).toString();

              for (OrdMain ord : ordList) {
                if (ordNo.equals(ord.getOrdNo().toString())) {

                  // ベッド, ベッドグループ表示順
                  for (Integer bedListIndex = 0; bedListIndex < mstBedList.size(); bedListIndex++) {
                    if (ord.getIndBedCd().toString().equals(mstBedList.get(bedListIndex).getBedCd().toString())) {
                      tmpJson.put("bed_order", String.format("%5s", bedListIndex.toString()).replace(" ", "0"));
                      Integer bedGroupIndex = 999;
                      bedGroupIndex = mstRoomBedGroupDao.selectIndexBedCdIsContain(ord.getIndBedCd().toString(), String.valueOf(dataKey.get("facilityCd")), "1");
                      tmpJson.put("bed_group_order", String.format("%3s", bedGroupIndex.toString()).replace(" ", "0"));
                    }
                  }
                  // クール
                  for (Integer kurListIndex = 0; kurListIndex < mstKurList.size(); kurListIndex++ ) {
                    if (ord.getIndKurCd().toString().equals(mstKurList.get(kurListIndex).getKurCd().toString())) {
                      tmpJson.put("kur_order", String.format("%3s", kurListIndex.toString()).replace(" ", "0"));
                    }
                  }
                }
              }
            }
          }
        }

        List tmpSortKey = new ArrayList();
        List tmpSortDirection = new ArrayList();
        for (int index = 0; index < sortConditions.size(); index++) {
          Map<String, String> item = sortConditions.get(sortConditions.size() - (index+1));

          if (item.keySet().contains(CoreConstant.ReportMenu.ROOM_BED_GROUP)) {
            // ベッドグループ表示順
            tmpSortKey.add(index,"bed_group_order");
            tmpSortDirection.add(index,item.get(CoreConstant.ReportMenu.ROOM_BED_GROUP).toString());

          }else if (item.keySet().contains(CoreConstant.ReportMenu.PATIENT_BED)){
            // ベッド表示順
            tmpSortKey.add(index,"bed_order");
            tmpSortDirection.add(index,item.get(CoreConstant.ReportMenu.PATIENT_BED).toString());
          }else if (item.keySet().contains(CoreConstant.ReportMenu.PATIENT_COOL)){
            // クール表示順
            tmpSortKey.add(index,"kur_order");
            tmpSortDirection.add(index,item.get(CoreConstant.ReportMenu.PATIENT_COOL).toString());
          }
        }

        // 並び替え
        List sortKey = tmpSortKey;
        List sortDirection = tmpSortDirection;

        for(int indexSort = 0;indexSort < tmpSortKey.size();indexSort++) {
          for (int index = 0; index < tmpList.size();index++) {
            if ("bed_order".equals(tmpSortKey.get(indexSort)) && StringUtils.isEmpty(tmpList.get(index).get("bed_order").toString())) {
              tmpList.get(index).put("bed_order","asc".equals(sortDirection.get(indexSort)) ? "999999999" : "-999999999");
            }
            if ("bed_group_order".equals(tmpSortKey.get(indexSort)) &&
              (StringUtils.isEmpty(tmpList.get(index).get("bed_group_order").toString()) ||
                StringUtils.isEmpty(tmpList.get(index).get("bed_group_order").toString().replace("0","")))) {
              tmpList.get(index).put("bed_group_order","asc".equals(sortDirection.get(indexSort)) ? "999999999" : "-999999999");
            }
            if ("kur_order".equals(tmpSortKey.get(indexSort)) && StringUtils.isEmpty(tmpList.get(index).get("kur_order").toString())) {
              tmpList.get(index).put("kur_order","asc".equals(sortDirection.get(indexSort)) ? "999999999" : "-999999999");
            }
          }
        }

        tmpList = distributionListBedOrIntroductionReportCompare(tmpList,sortKey,sortDirection,tmpSortKey);

        for(int indexSort = 0;indexSort < tmpSortKey.size();indexSort++) {
          for (int index = 0; index < tmpList.size();index++) {
            if ("bed_order".equals(tmpSortKey.get(indexSort))) {
              if ("999999999".equals(tmpList.get(index).get("bed_order").toString()) ||
                "-999999999".equals(tmpList.get(index).get("bed_order").toString())) {
                tmpList.get(index).put("bed_order","");
              }
            }
            if ("bed_group_order".equals(tmpSortKey.get(indexSort))) {
              if ("999999999".equals(tmpList.get(index).get("bed_group_order").toString()) ||
                "-999999999".equals(tmpList.get(index).get("bed_group_order").toString())) {
                tmpList.get(index).put("bed_group_order","");
              }
            }
            if ("kur_order".equals(tmpSortKey.get(indexSort))) {
              if ("999999999".equals(tmpList.get(index).get("kur_order").toString()) ||
                "-999999999".equals(tmpList.get(index).get("kur_order").toString())) {
                tmpList.get(index).put("kur_order","");
              }
            }
          }
        }

        // ソートしたデータを適用
        List<Long> tmpListPatId = new ArrayList<>();
        List<Long> tmpListOrdNo = new ArrayList<>();

        if (dataKey.get("patIds") != null) {
          for (JSONObject tmpJson : tmpList) {
            tmpListPatId.add(tmpJson.getLong(patIdStr));
          }
          dataKey.put("patIds",tmpListPatId);
        }
        if (dataKey.get("ordNos") != null ) {
          for (JSONObject tmpJson : tmpList) {
            tmpListOrdNo.add(tmpJson.getLong(ordNoStr));
          }
          dataKey.put("ordNos",tmpListOrdNo);
        }
      }
    }
    // 紹介状
    else if (mstReport.getReportClass().equals(ReportConstant.ReportClass.INTRODUCTION_REPORT)) {
      List<JSONObject> tmpList = new ArrayList<>();
      String patIdStr = "pat_id";
      String ordNoStr = "ord_no";

      listPatId = dataKey.get("patIds") == null ? new ArrayList<>(): (ArrayList)dataKey.get("patIds");
      listOrdNo = dataKey.get("ordNos") == null ? new ArrayList<>(): (ArrayList)dataKey.get("ordNos");
      for (int idx = 0; idx < listPatId.size(); idx++) {
        JSONObject jsonData = new JSONObject();
        jsonData.put(patIdStr, listPatId.get(idx));
        jsonData.put(ordNoStr, idx < listOrdNo.size() ?  listOrdNo.get(idx) : "");
        jsonData.put("treat_date", "");
        jsonData.put("hosp_pat_id", "");
        jsonData.put("in_out_class", "");
        jsonData.put("is_infect", "");
        tmpList.add(jsonData);
      }

      boolean ppmhPassedFlg = false;
      for (int index = 0; index < sortConditions.size(); index++) {
        Map<String, String> item = sortConditions.get(sortConditions.size() - (index+1));

        if (item.keySet().contains(CoreConstant.ReportMenu.DIALYSIS_DAY)) {

          Config config = defaultDbConfig;
          SelectBuilder builder = SelectBuilder.newInstance(config);
          if (listPatId.size() != 0) {
            builder.sql("select pat_id, min(treat_date) as treat_date from ord_main where pat_id in (");
            for (Long patId : listPatId) {
              builder.param(Long.class, Long.valueOf(patId.toString()));
              builder.sql(",");
            }

            builder.removeLast();
            builder.sql(") and treat_date >= '" + localDateFrom.format(DateTimeFormatter.ofPattern("yyyyMMdd")) + "' ");
            builder.sql("and treat_date <= '" + localDateTo.format(DateTimeFormatter.ofPattern("yyyyMMdd")) + "' group by pat_id");
          }

          List<Map<String, Object>> results = listPatId.size() == 0 ? new ArrayList<>() : baseEntityDao.executeSql(builder);
          // 患者ID毎に透析日を格納
          for (JSONObject tmpJson : tmpList) {
            Long patId = tmpJson.getLong(patIdStr);
            for (Map<String, Object> tmpMap : results) {
              Long tmpId = Long.valueOf(tmpMap.get(patIdStr).toString());
              if (tmpId.equals(patId)) {
                tmpJson.put("treat_date", tmpMap.get("treat_date").toString());
              }
            }
          }
        } else if ((item.keySet().contains(CoreConstant.ReportMenu.PATIENT_ID) ||
          item.keySet().contains(CoreConstant.ReportMenu.ENTRANCE_EXIT_CLASSIFICATION)) && !ppmhPassedFlg) {

          // mongoDB検索条件作成
          ArrayList<Bson> arr = new ArrayList<Bson>();
          arr.add(lt("up_date", mongFromDate));
          List<String> searchPatIdlist = new ArrayList<>();
          for (JSONObject tmpJson : tmpList) {
            searchPatIdlist.add(tmpJson.get(patIdStr).toString());
          }
          arr.add(in(patIdStr, searchPatIdlist));
          Bson bson = and(arr);
          // mongoDB検索処理

          FindIterable<Document> resultDocs = mongoTemplate.getCollection("pat_personal_main_history").find(bson).sort(descending("up_date"));
          // 患者ID毎に患者ID/入外区分を格納
          for (JSONObject tmpJson : tmpList) {
            String inOutClass = "";

            inOutClass = patPersonalMainDao.getInOutClassByPatPersonalMain(String.valueOf(dataKey.get("facilityCd")),tmpJson.get(patIdStr).toString());
            Document doc = resultDocs != null ? resultDocs.filter(eq(patIdStr, tmpJson.get(patIdStr).toString())).first() : new Document();
            if (doc != null) {
              // 患者ID ( ソート用に0埋めして格納 )
              // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 start
//              tmpJson.put("hosp_pat_id", String.format("%12s", doc.get("hosp_pat_id").toString()).replace(" ", "0"));
              tmpJson.put("hosp_pat_id", doc.get("hosp_pat_id").toString());
              // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 end
            }

            // 入外区分
            tmpJson.put("in_out_class", inOutClass != null ? inOutClass : "");
          }
          ppmhPassedFlg= true;
        } else if (item.keySet().contains(CoreConstant.ReportMenu.INFECTIOUS_ISEASE_PATIENTS)) {
          // 感染症患者のデータを取得

          // mongoDB検索条件作成
          ArrayList<Bson> arr = new ArrayList<Bson>();
          arr.add(lt("up_date", mongFromDate));
          List<String> list = new ArrayList<>();
          for (JSONObject tmpJson : tmpList) {
            list.add(tmpJson.get(patIdStr).toString());
          }
          arr.add(in(patIdStr, list));
          Bson bson = and(arr);
          // mongoDB検索処理
          FindIterable<Document> resultDocs = mongoTemplate.getCollection("pat_main_history").find(bson).sort(descending("up_date"));

          // 患者ID毎に感染症患者を格納
          for (JSONObject tmpJson : tmpList) {
            Document doc = resultDocs != null ? resultDocs.filter(eq(patIdStr, tmpJson.get(patIdStr).toString())).first() : new Document();
            if (doc != null) {
              // 感染症患者
              tmpJson.put("is_infect", doc.get("is_infect"));
            }
          }
        }
      }

      // 並び替えに使用する項目を取得
      List tmpSortKey = new ArrayList();
      List tmpSortDirection = new ArrayList();
      for (int j = 0; j < sortConditions.size(); j++) {

        Map<String, String> item = sortConditions.get(sortConditions.size() - (j+1));

        if (item.keySet().contains(CoreConstant.ReportMenu.DIALYSIS_DAY)) {
          // 透析日
          tmpSortKey.add(j,"treat_date");
          tmpSortDirection.add(j,item.get(CoreConstant.ReportMenu.DIALYSIS_DAY).toString());

        } else if (item.keySet().contains(CoreConstant.ReportMenu.PATIENT_ID)) {
          // 患者ID
          tmpSortKey.add(j,"hosp_pat_id");
          tmpSortDirection.add(j,item.get(CoreConstant.ReportMenu.PATIENT_ID).toString());

        } else if (item.keySet().contains(CoreConstant.ReportMenu.ENTRANCE_EXIT_CLASSIFICATION)) {
          // 入外区分
          tmpSortKey.add(j,"in_out_class");
          tmpSortDirection.add(j,item.get(CoreConstant.ReportMenu.ENTRANCE_EXIT_CLASSIFICATION).toString());

        } else if (item.keySet().contains(CoreConstant.ReportMenu.INFECTIOUS_ISEASE_PATIENTS)) {
          // 患者名
          tmpSortKey.add(j,"is_infect");
          tmpSortDirection.add(j,item.get(CoreConstant.ReportMenu.INFECTIOUS_ISEASE_PATIENTS).toString());
        }
      }
      List sortKey = tmpSortKey;
      List sortDirection = tmpSortDirection;
      if (sortKey.contains("in_out_class")) {
        for (int index = 0;index < tmpList.size();index++) {
          if (tmpList.get(index).get("in_out_class").equals("2")) {
            tmpList.get(index).put("in_out_class",sortDirection.get(sortKey.indexOf("in_out_class")).equals("asc") ? "999999998" : "-999999999");
          } else if (tmpList.get(index).get("in_out_class").equals("3")) {
            tmpList.get(index).put("in_out_class",sortDirection.get(sortKey.indexOf("in_out_class")).equals("asc") ? "999999999" : "-999999998");
          }
        }
      }
      tmpList = distributionListBedOrIntroductionReportCompare(tmpList,sortKey,sortDirection,tmpSortKey);

      if (sortKey.contains("in_out_class")) {
        for (int index = 0;index < tmpList.size();index++) {
          if (tmpList.get(index).get("in_out_class").equals("999999998") ||
            tmpList.get(index).get("in_out_class").equals("-999999999")) {
            tmpList.get(index).put("in_out_class","2");
          } else if (tmpList.get(index).get("in_out_class").equals("999999999") ||
            tmpList.get(index).get("in_out_class").equals("-999999998")) {
            tmpList.get(index).put("in_out_class","3");
          }
        }
      }
      // ソート対象のデータが存在しないデータを最下段に寄せる
      List<Long> tmpListPatId = new ArrayList<>();
      List<Long> tmpListOrdNo = new ArrayList<>();

      if (dataKey.get("patIds") != null) {
        for (JSONObject tmpJson : tmpList) {
          tmpListPatId.add(tmpJson.getLong(patIdStr));
        }
        dataKey.put("patIds",tmpListPatId);
      }
      if (dataKey.get("ordNos") != null ) {
        for (JSONObject tmpJson : tmpList) {
          tmpListOrdNo.add(tmpJson.getLong(ordNoStr));
        }
        dataKey.put("ordNos",tmpListOrdNo);
      }
    }
    //装置帳票
    else if (mstReport.getReportClass().equals(ReportConstant.ReportClass.MACHINE_REPORT)) {
      List<JSONObject> tmpList = new ArrayList<>();
      if(dataKey.containsKey(ReportConstant.ReportDataKey.MACHINE_NOS) && dataKey.containsKey("facilityCd")) {
        // 施設コード
        String facilityCd = dataKey.get("facilityCd").toString();
        List<Long> itemList = new ArrayList<Long>();
        Object itemValue = dataKey.get(ReportConstant.ReportDataKey.MACHINE_NOS);
        if(itemValue != null) {
          if (itemValue instanceof List) {
            // リストの場合
            itemList.addAll(((List<?>) itemValue).stream().map(el -> Long.parseLong(el.toString())).collect(toList()));
          } else {
            // リスト以外
            itemList.add((Long)itemValue);
          }
        }
        List<MstBed> mstBedList = mstBedDao.selectByFacilityCd(facilityCd, "1", "0");
        if(!CollectionUtils.isEmpty(mstBedList) && !CollectionUtils.isEmpty(itemList)) {
          for(Long machineNo : itemList) {
            MstMachine mstMachine = mstMachineDao.selectByMachineNo(machineNo);
            if(mstMachine != null) {
              JSONObject jsonObject = new JSONObject();
              // add #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 start
              // 装置マスタの表示順を取得する
              String machineCdIndexNo = mstMachineDao.selectIndexNoFromMstMachine(facilityCd,
                String.valueOf(mstMachine.getMachineTypeCd()),
                String.valueOf(mstMachine.getMachineSerial()));
              // add #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 end
              jsonObject.put("machine_no", mstMachine.getMachineNo().toString());
              // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 start
//              jsonObject.put("machine_name", mstMachine.getMachineName());
              jsonObject.put("machine_cd", machineCdIndexNo);
              // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 end
              jsonObject.put("machine_Serial", mstMachine.getMachineSerial());
              jsonObject.put("machine_type", mstMachine.getMachineTypeCd());
              Optional<MstBed> mstBedOptional = mstBedList.stream().filter(el -> el.getMachineNo() != null && el.getMachineNo().longValue() == machineNo.longValue()).findFirst();
              jsonObject.put("bed_name", mstBedOptional.isPresent() ? mstBedOptional.get().getBedName() == null ? "" : mstBedOptional.get().getBedName() : "");
              jsonObject.put("bed_order", mstBedOptional.isPresent() ? String.format("%5s", mstBedList.indexOf(mstBedOptional.get())).replace(" ", "0") : "");
              tmpList.add(jsonObject);
            }
          }
          List tmpSortKey = new ArrayList();
          List tmpSortDirection = new ArrayList();
          if (sortConditions != null && sortConditions.size()!=0){
            // del #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe start
//            dataKey.put("sortCondition",sortConditions);
          // del #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe end
            for (int index =0;index< sortConditions.size();index++){
              for (Map.Entry<String,String> vv: sortConditions.get(sortConditions.size() - (index+1)).entrySet()) {
                if (CoreConstant.ReportMenu.MACHINE_NAME.equals(vv.getKey())){
                  // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 start
//                  tmpSortKey.add(index,"machine_name");
                  tmpSortKey.add(index,"machine_cd");
                  // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 end
                  tmpSortDirection.add(index,vv.getValue());
                }
                else if (CoreConstant.ReportMenu.MACHINE_SERIAL.equals(vv.getKey())){
                  tmpSortKey.add(index,"machine_Serial");
                  tmpSortDirection.add(index,vv.getValue());
                }
                else if (CoreConstant.ReportMenu.MACHINE_TYPE.equals(vv.getKey())){
                  tmpSortKey.add(index,"machine_type");
                  tmpSortDirection.add(index,vv.getValue());
                }
                else if (CoreConstant.ReportMenu.BED_NAME.equals(vv.getKey())){
                  tmpSortKey.add(index,"bed_order");
                  tmpSortDirection.add(index,vv.getValue());
                }
              }
            }
          }
          List sortKey = tmpSortKey;
          List sortDirection = tmpSortDirection;
          // 並び替え
          tmpList = machineReportCompare(tmpList,sortKey,sortDirection,tmpSortKey);
          // ソート対象のデータが存在しないデータを最下段に寄せる
          List<JSONObject> list = new ArrayList<>();
          List<JSONObject> empList = new ArrayList<>();
          for (JSONObject tmpJson : tmpList) {
            for (int index = 0; index < sortKey.size();index++) {
              if (tmpJson.getString(sortKey.get(index).toString()).equals("")) {
                empList.add(tmpJson);
              }
            }
          }
          list.addAll(empList);
          List<Long> machineNos = new ArrayList<>();
          for(JSONObject tempJsonObject : tmpList) {
            machineNos.add(Long.parseLong(tempJsonObject.get("machine_no").toString()));
          }
          // add #10370 装置帳票向けの「水質管理」データ項目を検討する limingzhe start
          if (itemList != null && itemList.contains(-1l)) machineNos.add(-1l);
          // add #10370 装置帳票向けの「水質管理」データ項目を検討する limingzhe end
          dataKey.put(ReportConstant.ReportDataKey.MACHINE_NOS, machineNos);
        }
      }
    }
  }

  /**
   *
   * 帳票種別：1：治療経過表、帳票種別：2：単患者帳票
   * 並び替え
   * */
  // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 start
//  private List<JSONObject> dialysisReportOrOnePatientCompare(List<JSONObject> tmpList,
//                                                             List sortKey,
//                                                             List sortDirection){
//    if (sortKey.size() != 0) {
//      tmpList = tmpList.stream().sorted((patA, patB) -> {
//        if (sortKey.size() == 1) {
//          String sortKeyOne = "";
//          String sortDirectionOne = "";
//          sortKeyOne = sortKey.get(0).toString();
//          sortDirectionOne = sortDirection.get(0).toString();
//          if (patA.get(sortKeyOne) != null && patA.get(sortKeyOne)!= "" &&
//            !patA.get(sortKeyOne).toString().equals(patB.get(sortKeyOne).toString())) {
//            return "asc".equals(sortDirectionOne) ?
//              patA.get(sortKeyOne).toString().compareTo(patB.get(sortKeyOne).toString()) :
//              patA.get(sortKeyOne).toString().compareTo(patB.get(sortKeyOne).toString()) * -1;
//          } else {
//            return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//          }
//        } else if (sortKey.size()==2){
//          if (patA.get(sortKey.get(0).toString()) != null && patA.get(sortKey.get(0).toString())!= "" &&
//            !patA.get(sortKey.get(0).toString()).toString().equals(patB.get(sortKey.get(0).toString()).toString())) {
//            return "asc".equals(sortDirection.get(0)) ?
//              patA.get(sortKey.get(0).toString()).toString().compareTo(patB.get(sortKey.get(0).toString()).toString()) :
//              patA.get(sortKey.get(0).toString()).toString().compareTo(patB.get(sortKey.get(0).toString()).toString()) * -1;
//          } else {
//            if (patA.get(sortKey.get(1).toString()) != null && patA.get(sortKey.get(1).toString())!= "" &&
//              !patA.get(sortKey.get(1).toString()).toString().equals(patB.get(sortKey.get(1).toString()).toString())) {
//              return "asc".equals(sortDirection.get(1)) ?
//                patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString()) :
//                patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString()) * -1;
//            } else {
//              return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//            }
//          }
//        } else {
//          if (patA.get(sortKey.get(0).toString()) != null && patA.get(sortKey.get(0).toString())!= "" &&
//            !patA.get(sortKey.get(0).toString()).toString().equals(patB.get(sortKey.get(0).toString()).toString())) {
//            return "asc".equals(sortDirection.get(0)) ?
//              patA.get(sortKey.get(0).toString()).toString().compareTo(patB.get(sortKey.get(0).toString()).toString()) :
//              patA.get(sortKey.get(0).toString()).toString().compareTo(patB.get(sortKey.get(0).toString()).toString()) * -1;
//          } else {
//            if (patA.get(sortKey.get(1).toString()) != null && patA.get(sortKey.get(1).toString())!= "" &&
//              !patA.get(sortKey.get(1).toString()).toString().equals(patB.get(sortKey.get(1).toString()).toString())) {
//              return "asc".equals(sortDirection.get(1)) ?
//                patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString()) :
//                patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString()) * -1;
//            } else {
//              if (patA.get(sortKey.get(2).toString()) != null && patA.get(sortKey.get(2).toString())!= "" &&
//                !patA.get(sortKey.get(2).toString()).toString().equals(patB.get(sortKey.get(2).toString()).toString())) {
//                return "asc".equals(sortDirection.get(2)) ?
//                  patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString()) :
//                  patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString()) * -1;
//              } else {
//                return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//              }
//            }
//          }
//        }
//      }).collect(Collectors.toList());
//    }
//    return tmpList;
//  }
  private List<JSONObject> dialysisReportOrOnePatientCompare(List<JSONObject> tmpList,
                                                             List sortKey,
                                                             List sortDirection) {
    // sortKey が null または空の場合はそのまま返す
    if (sortKey == null || sortKey.isEmpty()) return tmpList;

    // Comparator を作成
    Comparator<JSONObject> comparator = (a, b) -> {
      // sortKey の優先順位に従って比較
      for (int i = 0; i < sortKey.size(); i++) {
        // 比較対象のフィールド名
        String key = String.valueOf(sortKey.get(i));
        // sortDirection が存在すれば取得、なければ "asc" をデフォルトに設定
        String direction = (sortDirection != null && i < sortDirection.size()) ? String.valueOf(sortDirection.get(i)) : "asc";

        // JSON 内の値を安全に取得（null 対策）
        String va = safeString(a.opt(key));
        String vb = safeString(b.opt(key));

        // 値が同じ場合（大文字小文字を区別せず） → 次の優先フィールドへ
        if (va.equalsIgnoreCase(vb)) {
          continue;
        }

        int cmp;
        // pat_id の場合はシステム共通患者IDの特殊な比較ルールを使用
        if ("hosp_pat_id".equals(key)) {
          cmp = comparePatientId(va, vb);
        } else {
          // その他のフィールドは大文字小文字を区別しない辞書順で比較
          cmp = va.compareToIgnoreCase(vb);
        }

        // 昇順・降順を反映
        return "asc".equalsIgnoreCase(direction) ? cmp : -cmp;
      }

      // すべての優先フィールドが同じ場合は、最終的に pat_id で tie-breaker
      // これによりソートの安定性と決定性を保証
      return comparePatientId(safeString(a.opt("pat_id")), safeString(b.opt("pat_id")));
    };

    // Comparator に従ってソートしたリストを返す
    return tmpList.stream().sorted(comparator).collect(Collectors.toList());
  }
  // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 end

  /**
   *
   * 帳票種別：3：複数患者帳票
   * 並び替え
   * */
  // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 start
//  private List<JSONObject> multiplePatientCompare(List<JSONObject> tmpList,
//                                                  List sortKey,
//                                                  List tmpSortKey,
//                                                  List sortDirection,
//                                                  String sortKeyOne,
//                                                  String sortKeyTwo,
//                                                  List sortKeyName){
//    if (tmpSortKey.size() != 0) {
//      String finalSortKeyOne = sortKeyOne;
//      String finalSortKeyTwo = sortKeyTwo;
//      tmpList = tmpList.stream().sorted((patA, patB) -> {
//        if (sortDirection.size() == 1) {
//          if (sortKeyName.contains(CoreConstant.ReportMenu.BLOOD_TYPE)) {
//            if (patA.get(finalSortKeyOne) != null && patA.get(finalSortKeyOne)!= "" &&
//              !patA.get(finalSortKeyOne).toString().equals(patB.get(finalSortKeyOne).toString())) {
//              return "asc".equals(sortDirection.get(0)) ?
//                patA.get(finalSortKeyOne).toString().compareTo(patB.get(finalSortKeyOne).toString()) :
//                patA.get(finalSortKeyOne).toString().compareTo(patB.get(finalSortKeyOne).toString()) * -1;
//            } else {
//              if (patA.get(finalSortKeyTwo) != null && patA.get(finalSortKeyTwo)!= "" &&
//                !patA.get(finalSortKeyTwo).toString().equals(patB.get(finalSortKeyTwo).toString())) {
//                return "asc".equals(sortDirection.get(0)) ?
//                  patA.get(finalSortKeyTwo).toString().compareTo(patB.get(finalSortKeyTwo).toString()) :
//                  patA.get(finalSortKeyTwo).toString().compareTo(patB.get(finalSortKeyTwo).toString()) * -1;
//              } else {
//                return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//              }
//            }
//          } else {
//            if (patA.get(sortKey.get(0).toString()) != null && patA.get(sortKey.get(0).toString())!= "" &&
//              !patA.get(sortKey.get(0).toString()).toString().equals(patB.get(sortKey.get(0).toString()).toString())) {
//              return "asc".equals(sortDirection.get(0)) ?
//                patA.get(sortKey.get(0).toString()).toString().compareTo(patB.get(sortKey.get(0).toString()).toString()) :
//                patA.get(sortKey.get(0).toString()).toString().compareTo(patB.get(sortKey.get(0).toString()).toString()) * -1;
//            } else {
//              return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//            }
//          }
//        }
//        else if (sortDirection.size() == 2) {
//          if (sortKeyName.contains(CoreConstant.ReportMenu.BLOOD_TYPE)) {
//            if (sortKeyName.get(0).toString().equals(CoreConstant.ReportMenu.BLOOD_TYPE)) {
//              if (patA.get(finalSortKeyOne) != null && patA.get(finalSortKeyOne)!= "" &&
//                !patA.get(finalSortKeyOne).toString().equals(patB.get(finalSortKeyOne).toString())) {
//                return "asc".equals(sortDirection.get(0)) ?
//                  patA.get(finalSortKeyOne).toString().compareTo(patB.get(finalSortKeyOne).toString()) :
//                  patA.get(finalSortKeyOne).toString().compareTo(patB.get(finalSortKeyOne).toString()) * -1;
//              } else {
//                if (patA.get(finalSortKeyTwo) != null && patA.get(finalSortKeyTwo)!= "" &&
//                  !patA.get(finalSortKeyTwo).toString().equals(patB.get(finalSortKeyTwo).toString())) {
//                  return "asc".equals(sortDirection.get(0)) ?
//                    patA.get(finalSortKeyTwo).toString().compareTo(patB.get(finalSortKeyTwo).toString()) :
//                    patA.get(finalSortKeyTwo).toString().compareTo(patB.get(finalSortKeyTwo).toString()) * -1;
//                } else {
//                  if (patA.get(sortKey.get(1).toString()) != null && patA.get(sortKey.get(1).toString())!= "" &&
//                    !patA.get(sortKey.get(1).toString()).toString().equals(patB.get(sortKey.get(1).toString()).toString())) {
//                    return "asc".equals(sortDirection.get(1)) ?
//                      patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString()) :
//                      patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString()) * -1;
//                  } else {
//                    return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                  }
//                }
//              }
//            } else {
//              if (patA.get(sortKey.get(0).toString()) != null && patA.get(sortKey.get(0).toString())!= "" &&
//                !patA.get(sortKey.get(0).toString()).toString().equals(patB.get(sortKey.get(0).toString()).toString())) {
//                return "asc".equals(sortDirection.get(0)) ?
//                  patA.get(sortKey.get(0).toString()).toString().compareTo(patB.get(sortKey.get(0).toString()).toString()) :
//                  patA.get(sortKey.get(0).toString()).toString().compareTo(patB.get(sortKey.get(0).toString()).toString()) * -1;
//              } else {
//                if (patA.get(finalSortKeyOne) != null && patA.get(finalSortKeyOne)!= "" &&
//                  !patA.get(finalSortKeyOne).toString().equals(patB.get(finalSortKeyOne).toString())) {
//                  return "asc".equals(sortDirection.get(1)) ?
//                    patA.get(finalSortKeyOne).toString().compareTo(patB.get(finalSortKeyOne).toString()) :
//                    patA.get(finalSortKeyOne).toString().compareTo(patB.get(finalSortKeyOne).toString()) * -1;
//                } else {
//                  if (patA.get(finalSortKeyTwo) != null && patA.get(finalSortKeyTwo)!= "" &&
//                    !patA.get(finalSortKeyTwo).toString().equals(patB.get(finalSortKeyTwo).toString())) {
//                    return "asc".equals(sortDirection.get(1)) ?
//                      patA.get(finalSortKeyTwo).toString().compareTo(patB.get(finalSortKeyTwo).toString()) :
//                      patA.get(finalSortKeyTwo).toString().compareTo(patB.get(finalSortKeyTwo).toString()) * -1;
//                  } else {
//                    return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                  }
//                }
//              }
//            }
//          } else {
//            if (patA.get(sortKey.get(0).toString()) != null && patA.get(sortKey.get(0).toString())!= "" &&
//              !patA.get(sortKey.get(0).toString()).toString().equals(patB.get(sortKey.get(0).toString()).toString())) {
//              return "asc".equals(sortDirection.get(0)) ?
//                patA.get(sortKey.get(0).toString()).toString().compareTo(patB.get(sortKey.get(0).toString()).toString()) :
//                patA.get(sortKey.get(0).toString()).toString().compareTo(patB.get(sortKey.get(0).toString()).toString()) * -1;
//            } else {
//              if (patA.get(sortKey.get(1).toString()) != null && patA.get(sortKey.get(1).toString())!= "" &&
//                !patA.get(sortKey.get(1).toString()).toString().equals(patB.get(sortKey.get(1).toString()).toString())) {
//                return "asc".equals(sortDirection.get(1)) ?
//                  patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString()) :
//                  patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString()) * -1;
//              } else {
//                return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//              }
//            }
//          }
//        }
//        else {
//          if (sortKeyName.contains(CoreConstant.ReportMenu.BLOOD_TYPE)) {
//            if (sortKeyName.get(0).toString().equals(CoreConstant.ReportMenu.BLOOD_TYPE)) {
//              if (patA.get(finalSortKeyOne) != null && patA.get(finalSortKeyOne)!= "" &&
//                !patA.get(finalSortKeyOne).toString().equals(patB.get(finalSortKeyOne).toString())) {
//                return "asc".equals(sortDirection.get(0)) ?
//                  patA.get(finalSortKeyOne).toString().compareTo(patB.get(finalSortKeyOne).toString()) :
//                  patA.get(finalSortKeyOne).toString().compareTo(patB.get(finalSortKeyOne).toString()) * -1;
//              } else {
//                if (patA.get(finalSortKeyTwo) != null && patA.get(finalSortKeyTwo)!= "" &&
//                  !patA.get(finalSortKeyTwo).toString().equals(patB.get(finalSortKeyTwo).toString())) {
//                  return "asc".equals(sortDirection.get(0)) ?
//                    patA.get(finalSortKeyTwo).toString().compareTo(patB.get(finalSortKeyTwo).toString()) :
//                    patA.get(finalSortKeyTwo).toString().compareTo(patB.get(finalSortKeyTwo).toString()) * -1;
//                } else {
//                  if (patA.get(sortKey.get(1).toString()) != null && patA.get(sortKey.get(1).toString())!= "" &&
//                    !patA.get(sortKey.get(1).toString()).toString().equals(patB.get(sortKey.get(1).toString()).toString())) {
//                    return "asc".equals(sortDirection.get(1)) ?
//                      patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString()) :
//                      patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString()) * -1;
//                  } else {
//                    if (patA.get(sortKey.get(2).toString()) != null && patA.get(sortKey.get(2).toString())!= "" &&
//                      !patA.get(sortKey.get(2).toString()).toString().equals(patB.get(sortKey.get(2).toString()).toString())) {
//                      return "asc".equals(sortDirection.get(2)) ?
//                        patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString()) :
//                        patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString()) * -1;
//                    } else {
//                      return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                    }
//                  }
//                }
//              }
//            } else if (sortKeyName.get(1).toString().equals(CoreConstant.ReportMenu.BLOOD_TYPE)) {
//              if (patA.get(sortKey.get(0).toString()) != null && patA.get(sortKey.get(0).toString())!= "" &&
//                !patA.get(sortKey.get(0).toString()).toString().equals(patB.get(sortKey.get(0).toString()).toString())) {
//                return "asc".equals(sortDirection.get(0)) ?
//                  patA.get(sortKey.get(0).toString()).toString().compareTo(patB.get(sortKey.get(0).toString()).toString()) :
//                  patA.get(sortKey.get(0).toString()).toString().compareTo(patB.get(sortKey.get(0).toString()).toString()) * -1;
//              } else {
//                if (patA.get(finalSortKeyOne) != null && patA.get(finalSortKeyOne)!= "" &&
//                  !patA.get(finalSortKeyOne).toString().equals(patB.get(finalSortKeyOne).toString())) {
//                  return "asc".equals(sortDirection.get(1)) ?
//                    patA.get(finalSortKeyOne).toString().compareTo(patB.get(finalSortKeyOne).toString()) :
//                    patA.get(finalSortKeyOne).toString().compareTo(patB.get(finalSortKeyOne).toString()) * -1;
//                } else {
//                  if (patA.get(finalSortKeyTwo) != null && patA.get(finalSortKeyTwo)!= "" &&
//                    !patA.get(finalSortKeyTwo).toString().equals(patB.get(finalSortKeyTwo).toString())) {
//                    return "asc".equals(sortDirection.get(1)) ?
//                      patA.get(finalSortKeyTwo).toString().compareTo(patB.get(finalSortKeyTwo).toString()) :
//                      patA.get(finalSortKeyTwo).toString().compareTo(patB.get(finalSortKeyTwo).toString()) * -1;
//                  } else {
//                    if (patA.get(sortKey.get(2).toString()) != null && patA.get(sortKey.get(2).toString())!= "" &&
//                      !patA.get(sortKey.get(2).toString()).toString().equals(patB.get(sortKey.get(2).toString()).toString())) {
//                      return "asc".equals(sortDirection.get(2)) ?
//                        patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString()) :
//                        patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString()) * -1;
//                    } else {
//                      return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                    }
//                  }
//                }
//              }
//            } else {
//              if (patA.get(sortKey.get(0).toString()) != null && patA.get(sortKey.get(0).toString())!= "" &&
//                !patA.get(sortKey.get(0).toString()).toString().equals(patB.get(sortKey.get(0).toString()).toString())) {
//                return "asc".equals(sortDirection.get(0)) ?
//                  patA.get(sortKey.get(0).toString()).toString().compareTo(patB.get(sortKey.get(0).toString()).toString()) :
//                  patA.get(sortKey.get(0).toString()).toString().compareTo(patB.get(sortKey.get(0).toString()).toString()) * -1;
//              } else {
//                if (patA.get(sortKey.get(1).toString()) != null && patA.get(sortKey.get(1).toString())!= "" &&
//                  !patA.get(sortKey.get(1).toString()).toString().equals(patB.get(sortKey.get(1).toString()).toString())) {
//                  return "asc".equals(sortDirection.get(1)) ?
//                    patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString()) :
//                    patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString()) * -1;
//                } else {
//                  if (patA.get(finalSortKeyOne) != null && patA.get(finalSortKeyOne)!= "" &&
//                    !patA.get(finalSortKeyOne).toString().equals(patB.get(finalSortKeyOne).toString())) {
//                    return "asc".equals(sortDirection.get(2)) ?
//                      patA.get(finalSortKeyOne).toString().compareTo(patB.get(finalSortKeyOne).toString()) :
//                      patA.get(finalSortKeyOne).toString().compareTo(patB.get(finalSortKeyOne).toString()) * -1;
//                  } else {
//                    if (patA.get(finalSortKeyTwo) != null && patA.get(finalSortKeyTwo)!= "" &&
//                      !patA.get(finalSortKeyTwo).toString().equals(patB.get(finalSortKeyTwo).toString())) {
//                      return "asc".equals(sortDirection.get(2)) ?
//                        patA.get(finalSortKeyTwo).toString().compareTo(patB.get(finalSortKeyTwo).toString()) :
//                        patA.get(finalSortKeyTwo).toString().compareTo(patB.get(finalSortKeyTwo).toString()) * -1;
//                    } else {
//                      return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                    }
//                  }
//                }
//              }
//            }
//          } else {
//            if (patA.get(sortKey.get(0).toString()) != null && patA.get(sortKey.get(0).toString())!= "" &&
//              !patA.get(sortKey.get(0).toString()).toString().equals(patB.get(sortKey.get(0).toString()).toString())) {
//              return "asc".equals(sortDirection.get(0)) ?
//                patA.get(sortKey.get(0).toString()).toString().compareTo(patB.get(sortKey.get(0).toString()).toString()) :
//                patA.get(sortKey.get(0).toString()).toString().compareTo(patB.get(sortKey.get(0).toString()).toString()) * -1;
//            } else {
//              if (patA.get(sortKey.get(1).toString()) != null && patA.get(sortKey.get(1).toString())!= "" &&
//                !patA.get(sortKey.get(1).toString()).toString().equals(patB.get(sortKey.get(1).toString()).toString())) {
//                return "asc".equals(sortDirection.get(1)) ?
//                  patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString()) :
//                  patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString()) * -1;
//              } else {
//                if (patA.get(sortKey.get(2).toString()) != null && patA.get(sortKey.get(2).toString())!= "" &&
//                  !patA.get(sortKey.get(2).toString()).toString().equals(patB.get(sortKey.get(2).toString()).toString())) {
//                  return "asc".equals(sortDirection.get(2)) ?
//                    patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString()) :
//                    patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString()) * -1;
//                } else {
//                  return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                }
//              }
//            }
//          }
//        }
//      }).collect(Collectors.toList());
//    }
//    return tmpList;
//  }

  private List<JSONObject> multiplePatientCompare(List<JSONObject> tmpList,
                                                  List sortKey,
                                                  List tmpSortKey,
                                                  List sortDirection,
                                                  String sortKeyOne,
                                                  String sortKeyTwo,
                                                  List sortKeyName) {
    // sortKey が null または空の場合はそのまま返す
    if (tmpSortKey == null || tmpSortKey.isEmpty()) return tmpList;

    // 血液型用の2つのフィールドを保持
    String finalSortKeyOne = sortKeyOne;
    String finalSortKeyTwo = sortKeyTwo;

    // Comparator を作成
    Comparator<JSONObject> comparator = (a, b) -> {
      // sortKey の優先順位に従って比較
      for (int i = 0; i < sortKey.size(); i++) {
        String key = String.valueOf(sortKey.get(i));
        // sortDirection が存在すれば取得、なければ "asc" をデフォルト
        String direction = (sortDirection != null && i < sortDirection.size()) ? String.valueOf(sortDirection.get(i)) : "asc";

        // 血液型の場合は特殊処理: finalSortKeyOne, finalSortKeyTwo を順に比較
        if (sortKeyName.contains(CoreConstant.ReportMenu.BLOOD_TYPE) && CoreConstant.ReportMenu.BLOOD_TYPE.equals(key)) {
          String va = safeString(a.opt(finalSortKeyOne));
          String vb = safeString(b.opt(finalSortKeyOne));
          if (!va.equalsIgnoreCase(vb)) {
            int cmp = va.compareToIgnoreCase(vb);
            return "asc".equalsIgnoreCase(direction) ? cmp : -cmp;
          }

          va = safeString(a.opt(finalSortKeyTwo));
          vb = safeString(b.opt(finalSortKeyTwo));
          if (!va.equalsIgnoreCase(vb)) {
            int cmp = va.compareToIgnoreCase(vb);
            return "asc".equalsIgnoreCase(direction) ? cmp : -cmp;
          }

          // 両方のフィールドが同じ場合は次の sortKey へ
          continue;
        }

        // 血液型以外の通常フィールドの処理
        String va = safeString(a.opt(key));
        String vb = safeString(b.opt(key));

        // 値が同じ場合は次の優先キーへ
        if (va.equalsIgnoreCase(vb)) continue;

        int cmp;
        // hosp_pat_id は専用の比較ルールを使用
        if ("hosp_pat_id".equals(key)) {
          cmp = comparePatientId(va, vb);
        } else {
          // その他の文字列は大文字小文字を区別せず辞書順で比較
          cmp = va.compareToIgnoreCase(vb);
        }

        // 昇順・降順を適用
        return "asc".equalsIgnoreCase(direction) ? cmp : -cmp;
      }

      // 全ての優先フィールドが同じ場合は、pat_id で tie-breaker
      // これによりソートの安定性と決定性を保証
      return comparePatientId(safeString(a.opt("pat_id")), safeString(b.opt("pat_id")));
    };

    // Comparator に従ってソートしたリストを返す
    return tmpList.stream().sorted(comparator).collect(Collectors.toList());
  }
  // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 end

  /**
   *
   * 帳票種別：5：配布リスト（ベッド）、帳票種別：9：紹介状
   * 並び替え
   * */
  // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 start
//  private List<JSONObject> distributionListBedOrIntroductionReportCompare (List<JSONObject> tmpList,
//                                                       List sortKey,
//                                                       List sortDirection,
//                                                       List tmpSortKey) {
//    if (tmpSortKey.size() != 0) {
//      tmpList = tmpList.stream().sorted((patA, patB) -> {
//        if (tmpSortKey.size() == 1) {
//          if (!patA.get(sortKey.get(0).toString()).toString().equals(patB.get(sortKey.get(0).toString()).toString()) &&
//            patA.get(sortKey.get(0).toString()).toString() != "" && patB.get(sortKey.get(0).toString()).toString() != "") {
//            return sortDirection.get(0).toString().equals("asc") ?
//              patA.get(sortKey.get(0).toString()).toString().compareTo(patB.get(sortKey.get(0).toString()).toString()) :
//              patA.get(sortKey.get(0).toString()).toString().compareTo(patB.get(sortKey.get(0).toString()).toString()) * -1;
//          } else{
//            return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//          }
//        } else if (tmpSortKey.size() == 2) {
//          if (!patA.get(sortKey.get(0).toString()).toString().equals(patB.get(sortKey.get(0).toString()).toString()) &&
//            patA.get(sortKey.get(0).toString()).toString() != "" && patB.get(sortKey.get(0).toString()).toString() != "") {
//            return sortDirection.get(0).toString().equals("asc") ?
//              patA.get(sortKey.get(0).toString()).toString().compareTo(patB.get(sortKey.get(0).toString()).toString()) :
//              patA.get(sortKey.get(0).toString()).toString().compareTo(patB.get(sortKey.get(0).toString()).toString()) * -1;
//          } else{
//            if (!patA.get(sortKey.get(1).toString()).toString().equals(patB.get(sortKey.get(1).toString()).toString()) &&
//              patA.get(sortKey.get(1).toString()).toString() != "" && patB.get(sortKey.get(1).toString()).toString() != "") {
//              return sortDirection.get(1).toString().equals("asc") ?
//                patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString()) :
//                patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString()) * -1;
//            } else {
//              return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//            }
//          }
//        } else {
//          if (!patA.get(sortKey.get(0).toString()).toString().equals(patB.get(sortKey.get(0).toString()).toString()) &&
//            patA.get(sortKey.get(0).toString()).toString() != "" && patB.get(sortKey.get(0).toString()).toString() != "") {
//            return sortDirection.get(0).toString().equals("asc") ?
//              patA.get(sortKey.get(0).toString()).toString().compareTo(patB.get(sortKey.get(0).toString()).toString()) :
//              patA.get(sortKey.get(0).toString()).toString().compareTo(patB.get(sortKey.get(0).toString()).toString()) * -1;
//          } else{
//            if (!patA.get(sortKey.get(1).toString()).toString().equals(patB.get(sortKey.get(1).toString()).toString()) &&
//              patA.get(sortKey.get(1).toString()).toString() != "" && patB.get(sortKey.get(1).toString()).toString() != "") {
//              return sortDirection.get(1).toString().equals("asc") ?
//                patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString()) :
//                patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString()) * -1;
//            } else {
//              if (!patA.get(sortKey.get(2).toString()).toString().equals(patB.get(sortKey.get(2).toString()).toString()) &&
//                patA.get(sortKey.get(2).toString()).toString() != "" && patB.get(sortKey.get(2).toString()).toString() != "") {
//                return sortDirection.get(2).toString().equals("asc") ?
//                  patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString()) :
//                  patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString()) * -1;
//              } else {
//                return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//              }
//            }
//          }
//        }
//      }).collect(Collectors.toList());
//    }
//    return tmpList;
//  }

  private List<JSONObject> distributionListBedOrIntroductionReportCompare(List<JSONObject> tmpList,
                                                                          List sortKey,
                                                                          List sortDirection,
                                                                          List tmpSortKey) {
    // tmpSortKey が null または空の場合はそのまま返す
    if (tmpSortKey == null || tmpSortKey.isEmpty()) return tmpList;

    // Comparator を作成
    Comparator<JSONObject> comparator = (a, b) -> {
      // sortKey の優先順位に従って比較
      for (int i = 0; i < sortKey.size(); i++) {
        // 比較対象のフィールド名
        String key = String.valueOf(sortKey.get(i));
        // sortDirection が存在すれば取得、なければ "asc" をデフォルトに設定
        String direction = (sortDirection != null && i < sortDirection.size()) ? String.valueOf(sortDirection.get(i)) : "asc";

        // JSON 内の値を安全に取得（null 対策）
        String va = safeString(a.opt(key));
        String vb = safeString(b.opt(key));

        // 値が同じ場合（大文字小文字を区別せず） → 次の優先フィールドへ
        if (va.equalsIgnoreCase(vb)) {
          continue;
        }

        int cmp;
        // pat_id の場合はシステム共通患者IDの特殊な比較ルールを使用
        if ("hosp_pat_id".equals(key)) {
          cmp = comparePatientId(va, vb);
        } else {
          // その他のフィールドは大文字小文字を区別しない辞書順で比較
          cmp = va.compareToIgnoreCase(vb);
        }

        // 昇順・降順を反映
        return "asc".equalsIgnoreCase(direction) ? cmp : -cmp;
      }

      // すべての優先フィールドが同じ場合は、最終的に pat_id で tie-breaker
      // これによりソートの安定性と決定性を保証
      return comparePatientId(safeString(a.opt("pat_id")), safeString(b.opt("pat_id")));
    };

    // Comparator に従ってソートしたリストを返す
    return tmpList.stream().sorted(comparator).collect(Collectors.toList());
  }
  // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 end

  /**
   *
   * 帳票種別：7：装置帳票
   * 並び替え
   * */
  private List<JSONObject> machineReportCompare (List<JSONObject> tmpList,
                                                 List sortKey,
                                                 List sortDirection,
                                                 List tmpSortKey) {

    for(int index = 0; index < sortKey.size();index++) {
      for (int num =0; num < tmpList.size();num++) {
        if (tmpList.get(num).get(sortKey.get(index).toString()) == "") {
          tmpList.get(num).put(sortKey.get(index).toString(),"asc".equals(sortDirection.get(index)) ? "100000000" : "-100000000");
        }
      }
    }

    if (tmpSortKey.size() != 0) {
      tmpList = tmpList.stream().sorted((patA, patB) -> {
        if (tmpSortKey.size() == 1) {
          if (!patA.get(sortKey.get(0).toString()).toString().equals(patB.get(sortKey.get(0).toString()).toString()) &&
            patA.get(sortKey.get(0).toString()).toString() != "" && patB.get(sortKey.get(0).toString()).toString() != "") {
            return sortDirection.get(0).toString().equals("asc") ?
              patA.get(sortKey.get(0).toString()).toString().compareTo(patB.get(sortKey.get(0).toString()).toString()) :
              patA.get(sortKey.get(0).toString()).toString().compareTo(patB.get(sortKey.get(0).toString()).toString()) * -1;
          } else{
            return 0;
          }
        } else if (tmpSortKey.size() == 2) {
          if (!patA.get(sortKey.get(0).toString()).toString().equals(patB.get(sortKey.get(0).toString()).toString()) &&
            patA.get(sortKey.get(0).toString()).toString() != "" && patB.get(sortKey.get(0).toString()).toString() != "") {
            return sortDirection.get(0).toString().equals("asc") ?
              patA.get(sortKey.get(0).toString()).toString().compareTo(patB.get(sortKey.get(0).toString()).toString()) :
              patA.get(sortKey.get(0).toString()).toString().compareTo(patB.get(sortKey.get(0).toString()).toString()) * -1;
          } else{
            if (!patA.get(sortKey.get(1).toString()).toString().equals(patB.get(sortKey.get(1).toString()).toString()) &&
              patA.get(sortKey.get(1).toString()).toString() != "" && patB.get(sortKey.get(1).toString()).toString() != "") {
              return sortDirection.get(1).toString().equals("asc") ?
                patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString()) :
                patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString()) * -1;
            } else {
              return 0;
            }
          }
        } else {
          if (!patA.get(sortKey.get(0).toString()).toString().equals(patB.get(sortKey.get(0).toString()).toString()) &&
            patA.get(sortKey.get(0).toString()).toString() != "" && patB.get(sortKey.get(0).toString()).toString() != "") {
            return sortDirection.get(0).toString().equals("asc") ?
              patA.get(sortKey.get(0).toString()).toString().compareTo(patB.get(sortKey.get(0).toString()).toString()) :
              patA.get(sortKey.get(0).toString()).toString().compareTo(patB.get(sortKey.get(0).toString()).toString()) * -1;
          } else{
            if (!patA.get(sortKey.get(1).toString()).toString().equals(patB.get(sortKey.get(1).toString()).toString()) &&
              patA.get(sortKey.get(1).toString()).toString() != "" && patB.get(sortKey.get(1).toString()).toString() != "") {
              return sortDirection.get(1).toString().equals("asc") ?
                patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString()) :
                patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString()) * -1;
            } else {
              if (!patA.get(sortKey.get(2).toString()).toString().equals(patB.get(sortKey.get(2).toString()).toString()) &&
                patA.get(sortKey.get(2).toString()).toString() != "" && patB.get(sortKey.get(2).toString()).toString() != "") {
                return sortDirection.get(2).toString().equals("asc") ?
                  patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString()) :
                  patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString()) * -1;
              } else {
                return 0;
              }
            }
          }
        }
      }).collect(Collectors.toList());
    }

    for(int index = 0; index < sortKey.size();index++) {
      for (int num =0; num < tmpList.size();num++) {
        if (tmpList.get(num).get(sortKey.get(index).toString()) == "-100000000" ||
          tmpList.get(num).get(sortKey.get(index).toString()) == "100000000") {
          tmpList.get(num).put(sortKey.get(index).toString(),"");
        }
      }
    }
    return tmpList;
  }

  /* (非 Javadoc)
   * @see jp.co.nikkiso.ntss.admin_web.service.report.ReportService#getMstReport(java.lang.Long)
   */
  private MstReport getMstReport(Long reportCd) {
    try {
      return mstReportDao.selectByCd(reportCd);
    } catch (EmptyResultDataAccessException e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("There is no MstReport.");
      throw new NotExistException("テンプレートがない");
    }
  }

  /**
   * 帳票Zipファイルを取得します.
   *
   * @param mstReport 帳票マスタEntity
   * @return 帳票Zipファイル
   */
  private ReportZipFile getReportZip(MstReport mstReport) {
    return new ReportZipFile(
      reportS3Service.getReportFile(
        mstReport.getReportPath().getBucket(),
        mstReport.getReportPath().getReportZip(),
        mstReport.getUpDate()));
  }

  /**
   * 帳票定義XMLを取得します.
   *
   * @param mstReport 帳票マスタEntity
   * @param reportZipFile 帳票Zipファイル
   * @return 帳票定義XML
   */
  private String getReportXml(MstReport mstReport, ReportZipFile reportZipFile) {
    // 帳票定義XMLファイルを取得する
    String reportXml = reportZipFile.getFileToString(mstReport.getReportPath().getXmlFilename());
    if (org.springframework.util.StringUtils.isEmpty(reportXml)) {
      List<String> fileList = reportZipFile.getFileToString();
      throw new NtssException("帳票定義XMLファイルを取得できません。"
        + "MstReport:[" + mstReport.getReportPath().getXmlFilename() + "]"
        + " ReportZipFile:[" + fileList.toString() + "]"
      );
    }
    return reportXml;
  }

  /**
   * Param要素情報からsqlCodeの値を取得します.
   *
   * @param params Param要素情報
   * @return SQLCODEのリスト
   */
  private List<String> getSqlCode(List<ReportXmlParam> params){

    // sqlCodeの値を取得する
    List<String> sqlCodes = params.stream()
      .filter(p -> !org.springframework.util.StringUtils.isEmpty(p.getSqlCode()))
      .map(p -> p.getSqlCode())
      .collect(Collectors.toList())
      ;

    // formula属性に設定されているsqlCodeを取得する
    List<String> tmpList = new ArrayList<>();
    params.stream()
      .filter(p -> p.isFormulaToCalc())
      .forEach(p -> tmpList.addAll(getSqlCodeAndDataCodes(p.getFormula())));
    tmpList.stream().forEach(t -> {
      String[] tmps = t.split(Pattern.quote("."));
      if (tmps.length == 2) {
        sqlCodes.add(tmps[0]);
      }
    });

    // 重複は除外する
    return sqlCodes.stream().distinct().collect(toList());
  }

  /**
   * 計算式から <code>[SqlCode.データ項目コード]</code>を取得します.
   * @param formula 計算式
   * @return <code>[SqlCode.データ項目コード]</code>のリスト
   */
  private List<String> getSqlCodeAndDataCodes(String formula) {
    List<String> result = new ArrayList<>();
    Matcher m = Pattern.compile("\\[([^\\[\\]]+)\\]").matcher(formula);
    while (m.find()) {
      result.add(m.group(1));
    }
    return result;
  }

  /**
   * ソートに使用するための一時的な値を追加提供する
   * @param sortKey
   * @param sortDirection
   * @param sortKeyName
   * @param tmpList
   *
   * */
  public void addTmpValueForSort(List<String> sortKey,
                                 List<String> sortDirection,
                                 List<String> sortKeyName,
                                 List<JSONObject> tmpList) {
    for (int index = 0; index < sortKey.size(); index++) {
      String key = sortKey.get(index);
      if (key == null || CoreConstant.ReportMenu.BLOOD_TYPE.equals(key) || "in_out_class".equals(key) || "is_infect".equals(key)) {
        continue;
      }
      String direction = sortDirection.get(index);
      for (JSONObject jsonObject : tmpList) {
        String value = jsonObject.optString(key, null);
        if (value == null || value.isEmpty() ||
          (("pat_group_order".equals(key) || "bed_group_order".equals(key)) && value.replace("0", "").isEmpty())) {
          jsonObject.put(key, direction.equals("asc") ? "1-" : "0-");
        } else {
          if ("0".equals(value) && "pat_sex".equals(key)) {
            jsonObject.put(key, direction.equals("asc") ? "1-" + value : "0-" + value);
          } else if (" ".equals(value) && "pat_name_kana".equals(key)) {
            jsonObject.put(key, direction.equals("asc") ? "1-" + value : "0-" + value);
          } else {
            jsonObject.put(key, direction.equals("asc") ? "0-" + value : "1-" + value);
          }
        }
      }
    }
  }


  /**
   * 一時的な値を削除する
   * @param sortKey
   * @param tmpList
   *
   * */
  public void removeTmpValueForSort(List sortKey ,List<JSONObject> tmpList) {
    for (int index = 0; index < sortKey.size();index++) {
      if (!CoreConstant.ReportMenu.BLOOD_TYPE.equals(sortKey.get(index).toString()) &&
        !"in_out_class".equals(sortKey.get(index).toString()) &&
        !"is_infect".equals(sortKey.get(index).toString())) {
        for (int indexList = 0;indexList < tmpList.size();indexList++) {
          tmpList.get(indexList).put(sortKey.get(index).toString(),tmpList.get(indexList).get(sortKey.get(index).toString()).toString().replaceFirst("^.{2}",""));
        }
      }
    }
  }
// add #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 start
  /**
   * JSON の値を安全に文字列化する
   * null の場合は空文字列を返す
   */
  private String safeString(Object o) {
    if (o == null) return "";
    return o.toString();
  }

  /**
   * システム共通患者IDの比較ルール
   * "pat_id" 用の特殊なソート処理
   *
   * ルール：
   * 1. "未設定" / "未登録" は常に最後
   * 2. 両方とも数字の場合は数値で比較、数値が同じなら桁数の短い方を先に
   * 3. 一方が数字、一方が文字列の場合は数字を優先（数字が前）
   * 4. 両方とも数字でない場合は辞書順（大文字小文字を区別しない）
   */
  private int comparePatientId(String a, String b) {
    // 特殊値の処理 ("未設定","未登録") — 常に最後
    if (isSpecial(a) && isSpecial(b)) return 0;
    if (isSpecial(a)) return 1;
    if (isSpecial(b)) return -1;

    boolean aIsNum = isNumeric(a);   // 純数字のみか
    boolean bIsNum = isNumeric(b);

    boolean aHasNum = containsDigit(a); // 数字を含むか
    boolean bHasNum = containsDigit(b);

    // タイプ優先度: 純数字(0) < 含数字(1) < 無数字(2)
    int aType = aIsNum ? 0 : (aHasNum ? 1 : 2);
    int bType = bIsNum ? 0 : (bHasNum ? 1 : 2);

    // タイプが違う場合は優先度で比較
    if (aType != bType) return Integer.compare(aType, bType);

    // 両方とも純数字
    if (aType == 0) {
      try {
        java.math.BigInteger na = new java.math.BigInteger(a);
        java.math.BigInteger nb = new java.math.BigInteger(b);
        int cmp = na.compareTo(nb);
        if (cmp != 0) return cmp;
        return Integer.compare(a.length(), b.length()); // 桁数が短い方を先に
      } catch (NumberFormatException ex) {
        return a.compareToIgnoreCase(b);
      }
    }

    // 両方とも含数字または無数字
    if (aType == 1) {
      // 含数字の場合は、文字列内の全数字を取り出して連結し数値比較
      String aDigits = extractDigits(a);
      String bDigits = extractDigits(b);

      java.math.BigInteger na = aDigits.isEmpty() ? java.math.BigInteger.ZERO : new java.math.BigInteger(aDigits);
      java.math.BigInteger nb = bDigits.isEmpty() ? java.math.BigInteger.ZERO : new java.math.BigInteger(bDigits);
      int cmp = na.compareTo(nb);
      if (cmp != 0) return cmp;

      // 数字が同じ場合は辞書順
      return a.compareToIgnoreCase(b);
    }

    // 両方とも無数字（純文字列） → 辞書順
    return a.compareToIgnoreCase(b);
  }

  /**
   * 文字列に数字が含まれるか
   */
  private boolean containsDigit(String s) {
    return s != null && s.matches(".*\\d.*");
  }

  /**
   * 文字列が数字のみか判定
   */
  private boolean isNumeric(String s) {
    return s != null && s.matches("\\d+");
  }

  // 文字列内の数字をすべて取り出して連結
  private String extractDigits(String s) {
    if (s == null) return "";
    return s.replaceAll("\\D", "");
  }

  /**
   * 特殊値か判定
   * "未設定" または "未登録" の場合 true
   */
  private boolean isSpecial(String s) {
    return "未設定".equals(s) || "未登録".equals(s);
  }
  // add #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 end
}
// add #11257 機能帳票の出力に帳票保存のソート条件を適用する 高 end
