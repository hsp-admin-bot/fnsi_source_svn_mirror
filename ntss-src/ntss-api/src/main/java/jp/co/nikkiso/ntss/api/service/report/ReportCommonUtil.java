// add #10988 データ項目「処方.処方箋情報.QRコード」を追加　V1.1A 吉 start
package jp.co.nikkiso.ntss.api.service.report;

import jp.co.nikkiso.ntss.api.constant.ReportConstant;
import jp.co.nikkiso.ntss.api.domain.report.ReportXmlParam;
import jp.co.nikkiso.ntss.api.domain.report.ReportXmlTotalTable;
import jp.co.nikkiso.ntss.core.dao.MstPersonalUserDao;
import jp.co.nikkiso.ntss.core.dao.OrdPersonalPrescriptionDao;
import jp.co.nikkiso.ntss.core.dao.OrdPrescriptionDao;
import jp.co.nikkiso.ntss.core.dao.PatInsuranceDao;
import jp.co.nikkiso.ntss.core.dao.ReportMenuDao;
import jp.co.nikkiso.ntss.core.dao.SysFacilityDao;
import jp.co.nikkiso.ntss.core.entity.OrdPrescription;
import jp.co.nikkiso.ntss.core.entity.SysFacility;
import jp.co.nikkiso.ntss.core.entity.patHistory.PatMainHistory;
import jp.co.nikkiso.ntss.core.entity.patHistory.PatPersonalMainHistory;
import jp.co.nikkiso.ntss.core.utils.MongoHealthCheckService;
import lombok.extern.slf4j.Slf4j;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessResourceFailureException;
import org.springframework.data.domain.Sort;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.nio.charset.Charset;
import java.nio.charset.CharsetEncoder;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@Slf4j
public class ReportCommonUtil {

  private static final char FULLWIDTH_BLACK_SQUARE = '■';
  private static final char FULLWIDTH_COMMA = '，';
  private static final char HALFWIDTH_COMMA = ',';
  private static final char FULLWIDTH_SPACE = '\u3000';
  private static final char HALFWIDTH_SPACE = ' ';
  // add #12280 クールやベッドグループ等が「全部」であるときの表現が画面と違う 吉 start
  private static final String MULTIPLE_PAGES_SEPARATOR = "#";
  // add #12280 クールやベッドグループ等が「全部」であるときの表現が画面と違う 吉 end
  @Autowired
  private SysFacilityDao sysFacilityDao;

  @Autowired
  private OrdPrescriptionDao ordPrescriptionDao;

  @Autowired(required = false)
  private MongoTemplate mongoTemplate;

  @Autowired
  private OrdPersonalPrescriptionDao ordPersonalPrescriptionDao;

  @Autowired
  private PatInsuranceDao patInsuranceDao;

  @Autowired
  private MstPersonalUserDao personalUserDao;

  @Autowired
  private ReportMenuDao reportMenuDao;

  public  void getQRContentInfo(Map<String, Object> dataKey, Map<String, String> reportOutputInfo, List<String> qrInfoList,boolean isNewDate){
    SysFacility sysFacility = sysFacilityDao.getSysFacilityByFacilityCd(dataKey.get("facilityCd").toString());
    List<String> list = new ArrayList<>();
    if(dataKey.containsKey("prescriptionClassList")){
      list = (List)dataKey.get("prescriptionClassList");
    }else{
      list.add("1");
      list.add("2");
    }
    List<OrdPrescription> ordPrescriptionList = new ArrayList<>();
    if(isNewDate){
      ordPrescriptionList = ordPrescriptionDao.selectResultLastOneByPatId(Long.valueOf(dataKey.get("patId").toString()),
        dataKey.get("fromDate").toString().replace("/", ""),list);
    }else{
      ordPrescriptionList = ordPrescriptionDao.selectResultByPatId(Long.valueOf(dataKey.get("patId").toString()),
        dataKey.get("fromDate").toString().replace("/", ""),list);
    }
    // PatMainHistory    PatPersonalMainHistory
    List<PatMainHistory> queryLastPatMainHistorys = new ArrayList<>();
    List<PatPersonalMainHistory> queryPatPersonalMainHistory = new ArrayList<>();
    try {
      if (MongoHealthCheckService.getMongoDBConnected()) {
        Query query = new Query();
        query.addCriteria(Criteria.where("facility_cd").is(dataKey.get("facilityCd").toString())
          .and("pat_id").in(dataKey.get("patId").toString())
          .and("up_date").lt(dataKey.get("fromDate")));
        query.with(Sort.by(Sort.Order.desc("up_date")));
        query.limit(1);
        queryLastPatMainHistorys = mongoTemplate.find(query, PatMainHistory.class);

        Query query1 = new Query();
        query1.addCriteria(Criteria.where("facility_cd").is(dataKey.get("facilityCd").toString())
          .and("pat_id").in(dataKey.get("patId").toString())
          .and("up_date").lt(dataKey.get("fromDate")));
        query1.with(Sort.by(Sort.Order.desc("up_date")));
        query1.limit(1);
        queryPatPersonalMainHistory = mongoTemplate.find(query1, PatPersonalMainHistory.class);
      }
    } catch (DataAccessResourceFailureException exception) {
      MongoHealthCheckService.setMongoDBConnected(false);
    }
    if(null != ordPrescriptionList && ordPrescriptionList.size()>0){
      for(int i=0; i<ordPrescriptionList.size(); i++){
        boolean errorFlag = true;
        String errorMsg = "";
        List<Map<String, Object>> ordPersonalPrescriptionMapList = ordPersonalPrescriptionDao.selectByOrdPrescriptionNoForcyou(ordPrescriptionList.get(i).getOrdPrescriptionNo());
        StringBuilder csv = new StringBuilder();
        Map<String, String> ordPersonalPrescriptionMap= new HashMap<>();
        if(null != ordPersonalPrescriptionMapList && ordPersonalPrescriptionMapList.size()>0){
          List<Map<String, String>> convertedList = ordPersonalPrescriptionMapList.stream()
            .map(map -> map.entrySet().stream()
              .collect(Collectors.toMap(
                Map.Entry::getKey,
                e -> e.getValue() != null ? e.getValue().toString() : ""
              ))
            )
            .collect(Collectors.toList());
          ordPersonalPrescriptionMap = convertedList.get(0);
        }else{
          break;
        }
        for(String key : qrInfoList) {
          // NO0
          csv.append(String.join(",", "JAHIS10")).append("\r\n");
          // NO1
          if(null != sysFacility){
            if(StringUtils.isEmpty(sysFacility.getMedicalInstitutionCd())){
              errorMsg = "医療機関コード";
              errorFlag = false;
            }
            if(!errorFlag && StringUtils.isEmpty(sysFacility.getPrefecturesCd())){
              errorMsg = "医療機関都道府県コード";
              errorFlag = false;
            }
            if(errorFlag){
              csv.append(String.join(",", "1", "1", sysFacility.getMedicalInstitutionCd().substring(sysFacility.getMedicalInstitutionCd().length() - 7),
                sysFacility.getPrefecturesCd(), "")).append("\r\n");
            }
          } else {
            errorMsg = "医療機関コード";
            errorFlag = false;
          }
          // NO4
          if(errorFlag && null != queryLastPatMainHistorys && null != queryLastPatMainHistorys.get(0) &&  null != queryLastPatMainHistorys.get(0).getMedical_care_info() &&
            !StringUtils.isEmpty(queryLastPatMainHistorys.get(0).getMedical_care_info().getMain_course_name())){
            String courseName = queryLastPatMainHistorys.get(0).getMedical_care_info().getMain_course_name();
            courseName = trimBothSpaces(courseName);
            courseName = process(courseName);
            csv.append(String.join(",", "4", "1", "",courseName)).append("\r\n");
          } else {
            if(errorFlag){
              errorMsg = "診療科名";
              errorFlag = false;
            }
          }
          // NO5
          if(errorFlag && null != ordPersonalPrescriptionMap && !StringUtils.isEmpty(ordPersonalPrescriptionMap.get("insu_dr_name"))){
            String insuDrName = ordPersonalPrescriptionMap.get("insu_dr_name");
            insuDrName = trimBothSpaces(insuDrName);
            insuDrName = process(insuDrName);
            csv.append(String.join(",", "5","", "", insuDrName)).append("\r\n");
          }else{
            if(errorFlag){
              errorMsg = "医師漢字氏名";
              errorFlag = false;
            }
          }
          // NO11
          if(errorFlag && null == queryPatPersonalMainHistory || queryPatPersonalMainHistory.size() == 0){
            if(errorFlag){
              errorMsg = "患者性別";
              errorFlag = false;
            }
          }
          if(errorFlag){
            String nameA = (StringUtils.isEmpty(queryPatPersonalMainHistory.get(0).getPat_last_name()) ? "" : queryPatPersonalMainHistory.get(0).getPat_last_name())
              + " " + (StringUtils.isEmpty(queryPatPersonalMainHistory.get(0).getPat_first_name()) ? "" : queryPatPersonalMainHistory.get(0).getPat_first_name());
            String nameB = (StringUtils.isEmpty(queryPatPersonalMainHistory.get(0).getPat_last_name_kana()) ? "" : queryPatPersonalMainHistory.get(0).getPat_last_name_kana())
              + " " + (StringUtils.isEmpty(queryPatPersonalMainHistory.get(0).getPat_first_name_kana()) ? "" : queryPatPersonalMainHistory.get(0).getPat_first_name_kana());
            nameA = trimBothSpaces(nameA);
            nameA = process(nameA);
            nameB = trimBothSpaces(nameB);
            nameB = process(nameB);
            csv.append(String.join(",", "11", "",nameA,nameB)).append("\r\n");
          }

          // NO12
          if(errorFlag && !StringUtils.isEmpty(queryPatPersonalMainHistory.get(0).getPat_sex()) && !"0".equals(queryPatPersonalMainHistory.get(0).getPat_sex())){
            csv.append(String.join(",", "12", queryPatPersonalMainHistory.get(0).getPat_sex())).append("\r\n");
          }else{
            if(errorFlag){
              errorMsg = "患者性別";
              errorFlag = false;
            }
          }
          // NO13
          if(errorFlag && !StringUtils.isEmpty(queryPatPersonalMainHistory.get(0).getPat_birthday())){
            csv.append(String.join(",", "13", queryPatPersonalMainHistory.get(0).getPat_birthday())).append("\r\n");
          } else {
            if(errorFlag){
              errorMsg = "患者生年月日";
              errorFlag = false;
            }
          }
          // NO14
          String erderly = "";
          String isChild  = ordPersonalPrescriptionMap.get("is_child");
          String isElderly7 = ordPersonalPrescriptionMap.get("is_elderly7");
          String isElderly = ordPersonalPrescriptionMap.get("is_elderly");
          if("1".equals(isChild)){
            erderly = "3";
          }
          if("1".equals(isElderly7)){
            erderly = "2";
          }
          if("1".equals(isElderly)){
            erderly = "1";
          }
          if (!StringUtils.isEmpty(erderly)) {
            csv.append(String.join(",", "14", erderly)).append("\r\n");
          }
          // NO22
          String insuNo = ordPersonalPrescriptionMap.get("insu_no");
          insuNo = trimBothSpaces(insuNo);
          insuNo = process(insuNo);
          csv.append(String.join(",", "22", insuNo)).append("\r\n");
          // NO23
          String insuPatMark = ordPersonalPrescriptionMap.get("insu_pat_mark");
          insuPatMark = trimBothSpaces(insuPatMark);
          insuPatMark = process(insuPatMark);
          String insuPatNo = ordPersonalPrescriptionMap.get("insu_pat_no");
          insuPatNo = trimBothSpaces(insuPatNo);
          insuPatNo = process(insuPatNo);
          csv.append(String.join(",", "23", insuPatMark,insuPatNo,!StringUtils.isEmpty(ordPersonalPrescriptionMap.get("is_dependent")) ? "2" : "1","")).append("\r\n");


          // NO27
          if(!StringUtils.isEmpty(ordPersonalPrescriptionMap.get("insu_pub1_no")) || !StringUtils.isEmpty(ordPersonalPrescriptionMap.get("insu_pub1_pat_no"))){
            String insuPub1No = ordPersonalPrescriptionMap.get("insu_pub1_no");
            insuPub1No = trimBothSpaces(insuPub1No);
            insuPub1No = process(insuPub1No);
            String insuPub1PatNo = ordPersonalPrescriptionMap.get("insu_pub1_pat_no");
            insuPub1PatNo = trimBothSpaces(insuPub1PatNo);
            insuPub1PatNo = process(insuPub1PatNo);
            csv.append(String.join(",", "27",insuPub1No,insuPub1PatNo)).append("\r\n");
          }
          // NO28
          if(!StringUtils.isEmpty(ordPersonalPrescriptionMap.get("insu_pub2_no")) || !StringUtils.isEmpty(ordPersonalPrescriptionMap.get("insu_pub2_pat_no"))){
            String insuPub2No = ordPersonalPrescriptionMap.get("insu_pub2_no");
            insuPub2No = trimBothSpaces(insuPub2No);
            insuPub2No = process(insuPub2No);
            String insuPub2PatNo = ordPersonalPrescriptionMap.get("insu_pub2_pat_no");
            insuPub2PatNo = trimBothSpaces(insuPub2PatNo);
            insuPub2PatNo = process(insuPub2PatNo);
            csv.append(String.join(",", "28", insuPub2No,insuPub2PatNo)).append("\r\n");
          }
          // NO29
          if(!StringUtils.isEmpty(ordPersonalPrescriptionMap.get("insu_pub3_no")) || !StringUtils.isEmpty(ordPersonalPrescriptionMap.get("insu_pub3_pat_no"))){
            String insuPub3No = ordPersonalPrescriptionMap.get("insu_pub3_no");
            insuPub3No = trimBothSpaces(insuPub3No);
            insuPub3No = process(insuPub3No);
            String insuPub3PatNo = ordPersonalPrescriptionMap.get("insu_pub3_pat_no");
            insuPub3PatNo = trimBothSpaces(insuPub3PatNo);
            insuPub3PatNo = process(insuPub3PatNo);
            csv.append(String.join(",", "29", insuPub3No,insuPub3PatNo)).append("\r\n");
          }
          // NO51
          csv.append(String.join(",", "51", ordPrescriptionList.get(i).getIssueDate())).append("\r\n");
          // NO52
          csv.append(String.join(",", "52", ordPrescriptionList.get(i).getExpirationDate())).append("\r\n");
          // NO61
          String anesthesia = ordPersonalPrescriptionMap.get("is_anesthesia");
          if ("1".equals(anesthesia)) {
            if (null != queryPatPersonalMainHistory.get(0) && null != queryPatPersonalMainHistory.get(0).getPat_contact_info()) {
              JSONObject jsonObject = new JSONObject(queryPatPersonalMainHistory.get(0).getPat_contact_info());
              String address = (jsonObject.get("address") == null || jsonObject.get("address") == JSONObject.NULL) ? "" : jsonObject.get("address").toString();
              address = trimBothSpaces(address);
              address = process(address);
              String tel1 = (jsonObject.get("tel1") == null || jsonObject.get("tel1") == JSONObject.NULL) ? "" : jsonObject.get("tel1").toString();
              tel1 = trimBothSpaces(tel1);
              tel1 = process(tel1);
              if ( !StringUtils.isEmpty(address) || !StringUtils.isEmpty(tel1)) {
                csv.append(String.join(",", "61", "", address, tel1)).append("\r\n");
              }
            }
          }
          OrdPrescription op = ordPrescriptionList.get(i);
          dataKey.put("ordPrescriptionNo", op.getOrdPrescriptionNo());

          List<Map<String, Object>> qrList = reportMenuDao.selectPrescriptionByDateKey(dataKey.get("facilityCd").toString(),ordPrescriptionList.get(i).getOrdPrescriptionNo().toString());
          List<Map<String, Object>> qrIssueNametList = reportMenuDao.selectPrescriptionIssueNameByDateKey(dataKey.get("facilityCd").toString(),ordPrescriptionList.get(i).getOrdPrescriptionNo().toString());
          List<Map<String, Object>> qrCommontList = reportMenuDao.selectPrescriptionCommontByDateKey(dataKey.get("facilityCd").toString(),ordPrescriptionList.get(i).getOrdPrescriptionNo().toString());
          Set<String> set = new HashSet<>();
          for(Map<String, Object> map : qrIssueNametList){
            if(!set.add(map.get("rp").toString())){
              errorMsg = "用法が複数あるRpが存在";
              errorFlag = false;
              break;
            }else{
              boolean flag = true;
              for(Map<String, Object> map1 :qrList){
                if(map.get("rp").toString().equals(map1.get("rp"))){
                  flag = false;
                }
              }
              if(flag){
                errorMsg = "用法が複数あるRpが存在";
                errorFlag = false;
                break;
              }
            }
          }
          String rp = "";
          for (int k = 0; k < qrList.size(); k++) {
            Map<String, Object> qrMap = qrList.get(k);
            String useFuncFlag = qrMap.get("rp").toString();
            if(StringUtils.isEmpty(useFuncFlag)){
              errorMsg = "用法または薬剤がないRpが存在";
              errorFlag = false;
              break;
            }
            String useType = String.valueOf(null != qrMap.get("type") ? qrMap.get("type") :"");
            String useAllCount = null != qrMap.get("day_count") ? String.valueOf(qrMap.get("day_count")) : "";
            String functionName = null != qrMap.get("usage_detail") ? String.valueOf(qrMap.get("usage_detail")) : "";
            String subNo = String.valueOf(qrMap.get("sub_no"));
            if(errorFlag ){
              if(!rp.equals(useFuncFlag)){
                if ("2".equals(useType)) {
                  useType = "1";
                } else if ("3".equals(useType) || "5".equals(useType)) {
                  useType = "3";
                } else if ("4".equals(useType)) {
                  useType = "2";
                } else {
                  errorMsg = "剤形区分";
                  errorFlag = false;
                  break;
                }
                // NO101
                if(!"".equals(useAllCount)){
                  csv.append(String.join(",", "101", useFuncFlag, useType, "", useAllCount)).append("\r\n");
                }else{
                  errorMsg = "調剤数量";
                  errorFlag = false;
                  break;
                }
                // NO111
                if(!"".equals(functionName)){
                  functionName = trimBothSpaces(functionName);
                  functionName = process(functionName);
                  csv.append(String.join(",", "111", useFuncFlag, "1", "", functionName, "")).append("\r\n");
                }else{
                  errorMsg = "用法名称";
                  errorFlag = false;
                  break;
                }
                for(int j = 0;j<qrCommontList.size();j++){
                  Map<String, Object> commontMap = qrCommontList.get(j);
                  if(useFuncFlag.equals(commontMap.get("rp"))){
                    String funcTionBZ = null != commontMap.get("issue_name") ? String.valueOf(commontMap.get("issue_name")) : "";
                    funcTionBZ = trimBothSpaces(funcTionBZ);
                    funcTionBZ = process(funcTionBZ);
                    csv.append(String.join(",", "181", useFuncFlag, subNo, "", funcTionBZ, "", "")).append("\r\n");
                  }
                }
              }
              String medName = null != qrMap.get("medicine_name") ? String.valueOf(qrMap.get("medicine_name")) : "";
              medName = trimBothSpaces(medName);
              medName = process(medName);
              String useCount = null != qrMap.get("rst_value") ? String.valueOf(qrMap.get("rst_value")) : "";
              String unit = null != qrMap.get("unit") ? String.valueOf(qrMap.get("unit")) : "";
              if(StringUtils.isEmpty(unit)){
                errorMsg = "単位名";
                errorFlag = false;
                break;
              }
              unit = trimBothSpaces(unit);
              unit = process(unit);
              String yjcode = null != qrMap.get("standard_medicine_cd") ? String.valueOf(qrMap.get("standard_medicine_cd")) : "";
              if(StringUtils.isEmpty(yjcode)){
                csv.append(String.join(",", "201", useFuncFlag, subNo, "1", "1", "", medName, useCount, "1", unit)).append("\r\n");
              } else {
                csv.append(String.join(",", "201", useFuncFlag, subNo, "1", "4", yjcode, medName, useCount, "1", unit)).append("\r\n");
              }
            }
            rp = useFuncFlag;
          }
          if(isNewDate){
            if(errorFlag){
              String content = csv.toString();
              reportOutputInfo.put(key, content);
            }else{
              reportOutputInfo.put(key, errorMsg);
            }
          }else{
            if(errorFlag){
              String content = csv.toString();
              String pageStr = String.format("%d%s", i+1, "#");
              String cellKey = String.format("%s%s", pageStr, key);
              reportOutputInfo.put(cellKey, content);
            }else{
              String pageStr = String.format("%d%s", i+1, "#");
              String cellKey = String.format("%s%s", pageStr, key);
              reportOutputInfo.put(cellKey, errorMsg);
            }
          }
        }
      }
    }
  }

  public static String process(String input) {
    if (input == null || input.isEmpty()) return input;

    String result = input.replace(HALFWIDTH_COMMA, FULLWIDTH_COMMA);

    result = result.replace(String.valueOf(FULLWIDTH_BLACK_SQUARE), "");

    result = replaceUnmappableCharacters(result, "Shift_JIS", FULLWIDTH_BLACK_SQUARE);

    return result;
  }

  private static String replaceUnmappableCharacters(String input, String encoding, char replacement) {
    CharsetEncoder encoder = Charset.forName(encoding).newEncoder();
    StringBuilder sb = new StringBuilder();
    for (int i = 0; i < input.length(); ) {
      int cp = input.codePointAt(i);
      String charAsString = new String(Character.toChars(cp));
      if (encoder.canEncode(charAsString)) {
        sb.append(charAsString);
      } else {
        sb.append(replacement);
      }
      i += Character.charCount(cp);
    }
    return sb.toString();
  }

  private static String trimBothSpaces(String input) {
    int start = 0;
    int end = input.length();

    while (start < end &&
      (input.charAt(start) == HALFWIDTH_SPACE || input.charAt(start) == FULLWIDTH_SPACE)) {
      start++;
    }

    while (end > start &&
      (input.charAt(end - 1) == HALFWIDTH_SPACE || input.charAt(end - 1) == FULLWIDTH_SPACE)) {
      end--;
    }
    return input.substring(start, end);
  }

  // add #12280 クールやベッドグループ等が「全部」であるときの表現が画面と違う 吉 start
  public static Map<String, String> pageAndPageCount(Map<String, String> result, List<ReportXmlParam> params, Map<String, Object> dataKey){
    ReportXmlTotalTable reportXmlTotalTable = params.size() > 0 ? params.get(0).getReportXmlTotalTable() : null;
    String unitDate = reportXmlTotalTable == null ? "" : reportXmlTotalTable.getUnitDate();
    int totalPages = 0;
    for (String key : result.keySet()) {
      if (key.contains("#")) {
        int resultPageCount = Integer.parseInt(key.split("#")[0]);
        totalPages = resultPageCount > totalPages ? resultPageCount : totalPages;
      }
    }
    for (ReportXmlParam reportXmlParam : params) {
      if(!"1".equals(reportXmlParam.getIsInTmpl())){
        if (ReportConstant.ReportDataKey.currentPage.equals(reportXmlParam.getDataCode())) {
          if(totalPages > 0) result.remove(reportXmlParam.getId());
          for (int i = 1; i <= totalPages ; i++) {
            result.put(String.format("%d%s%s",i,MULTIPLE_PAGES_SEPARATOR,reportXmlParam.getId()),String.valueOf(i));
          }
        } else if (ReportConstant.ReportDataKey.totalPages.equals(reportXmlParam.getDataCode())) {
          if(totalPages > 0) result.remove(reportXmlParam.getId());
          for (int i = 1; i <= totalPages ; i++) {
            result.put(String.format("%d%s%s",i,MULTIPLE_PAGES_SEPARATOR,reportXmlParam.getId()),String.valueOf(totalPages));
          }
        }
      }
    }
    return result;
  }
  // add #12280 クールやベッドグループ等が「全部」であるときの表現が画面と違う 吉 end
}
// add #10988 データ項目「処方.処方箋情報.QRコード」を追加　V1.1A 吉 end
