package jp.co.nikkiso.ntss.web_api.service;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.MasterMaintenanceGenericDao;
import jp.co.nikkiso.ntss.core.dao.MntMachineStateDao;
import jp.co.nikkiso.ntss.core.dao.MstAdditionDao;
import jp.co.nikkiso.ntss.core.dao.MstCourseDao;
import jp.co.nikkiso.ntss.core.dao.MstDialysisDifficultyDao;
import jp.co.nikkiso.ntss.core.dao.MstDiseaseDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilityDao;
import jp.co.nikkiso.ntss.core.dao.MstFavoriteFacilityDao;
import jp.co.nikkiso.ntss.core.dao.MstImplantDao;
import jp.co.nikkiso.ntss.core.dao.MstInfectionDao;
import jp.co.nikkiso.ntss.core.dao.MstPersonalUserDao;
import jp.co.nikkiso.ntss.core.dao.MstRelationshipDao;
import jp.co.nikkiso.ntss.core.dao.MstSeverityDao;
import jp.co.nikkiso.ntss.core.dao.MstTransportDao;
import jp.co.nikkiso.ntss.core.dao.MstUserAuthenticationDao;
import jp.co.nikkiso.ntss.core.dao.MstWardDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.PatInsuranceDao;
import jp.co.nikkiso.ntss.core.dao.PatMainDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.dao.PatUniqueDao;
import jp.co.nikkiso.ntss.core.dao.SysFacilityDao;
import jp.co.nikkiso.ntss.core.entity.MstAddition;
import jp.co.nikkiso.ntss.core.entity.MstCourse;
import jp.co.nikkiso.ntss.core.entity.MstDialysisDifficulty;
import jp.co.nikkiso.ntss.core.entity.MstDisease;
import jp.co.nikkiso.ntss.core.entity.MstFacility;
import jp.co.nikkiso.ntss.core.entity.MstImplant;
import jp.co.nikkiso.ntss.core.entity.MstInfection;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.entity.MstSeverity;
import jp.co.nikkiso.ntss.core.entity.MstTransport;
import jp.co.nikkiso.ntss.core.entity.MstUserAuthentication;
import jp.co.nikkiso.ntss.core.entity.MstWard;
import jp.co.nikkiso.ntss.core.entity.PatInfo;
import jp.co.nikkiso.ntss.core.entity.PatInsurance;
import jp.co.nikkiso.ntss.core.entity.PatMain;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.PatUnique;
import jp.co.nikkiso.ntss.core.entity.SysFacility;
import jp.co.nikkiso.ntss.core.entity.custom.AdditionInfoOrdMain;
import jp.co.nikkiso.ntss.core.entity.custom.MstFavoriteFacilityData;
import jp.co.nikkiso.ntss.core.entity.custom.PatGroupCustom;
import jp.co.nikkiso.ntss.core.entity.custom.PatInsuInfo;
import jp.co.nikkiso.ntss.core.entity.patHistory.PatGroupDetailHistory;
import jp.co.nikkiso.ntss.core.entity.patHistory.PatInsuranceHistory;
import jp.co.nikkiso.ntss.core.entity.patHistory.PatMainHistory;
import jp.co.nikkiso.ntss.core.entity.patHistory.PatPersonalMainHistory;
import jp.co.nikkiso.ntss.core.entity.patHistory.PatUniqueHistory;
import jp.co.nikkiso.ntss.core.entity.patHistory.patMainHistoryDetail.AdditionInfo;
import jp.co.nikkiso.ntss.core.entity.patHistory.patMainHistoryDetail.ChargeStaffInfo;
import jp.co.nikkiso.ntss.core.entity.patHistory.patMainHistoryDetail.ImplantInfo;
import jp.co.nikkiso.ntss.core.entity.patHistory.patMainHistoryDetail.InfectInfo;
import jp.co.nikkiso.ntss.core.entity.patHistory.patMainHistoryDetail.MedicalCareInfo;
import jp.co.nikkiso.ntss.core.entity.patHistory.patMainHistoryDetail.PatGroupInfo;
import jp.co.nikkiso.ntss.core.entity.patHistory.patMainHistoryDetail.PatMemoInfo;
import jp.co.nikkiso.ntss.core.entity.patHistory.patMainHistoryDetail.TabooAllergyInfo;
import jp.co.nikkiso.ntss.core.entity.patHistory.patPersonalMainHistoryDetail.DialDiffComInfo;
import jp.co.nikkiso.ntss.core.entity.patHistory.patPersonalMainHistoryDetail.OtherContactInfo;
import jp.co.nikkiso.ntss.core.entity.patHistory.patUniqueHistoryDetail.InOutVisitHistoryInfo;
import jp.co.nikkiso.ntss.core.entity.patHistory.patUniqueHistoryDetail.MedicalHstInfo;
import jp.co.nikkiso.ntss.core.entity.patHistory.patUniqueHistoryDetail.PhysicalInfo;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.utils.MongoHealthCheckService;
import jp.co.nikkiso.ntss.web_api.response.WheelChairWithNameResponse;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessResourceFailureException;
import org.springframework.data.domain.Sort;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.core.query.Update;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
// add #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 start
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.concurrent.atomic.AtomicInteger;
// add #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 end
import java.util.stream.Collectors;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

//add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 zhaoqi 20240228 start
@Service
public class PatMongoServiceImpl implements PatMongoService {
  @Autowired
  private PatUniqueDao patUniqueDao;
  @Autowired
  private OrdMainDao ordMainDao;
  @Autowired
  private PatInsuranceDao patInsuranceDao;
  @Autowired
  MntMachineStateDao mntMachineStateDao;
  @Autowired
  MasterMaintenanceGenericDao masterMaintenanceGenericDao;
  @Autowired
  MstDialysisDifficultyDao mstDialysisDifficultyDao;
  @Autowired
  MstInfectionDao mstInfectionDao;
  @Autowired
  MstRelationshipDao mstRelationshipDao;
  @Autowired
  private MstFacilityDao mstFacilityDao;
  @Autowired(required = false)
  MongoTemplate mongoTemplate;
  @Autowired
  private MstPersonalUserDao mstPersonalUserDao;
  @Autowired
  private MstDiseaseDao mstDiseaseDao;
  @Autowired
  private MstCourseDao mstCourseDao;
  @Autowired
  private MstImplantDao mstImplantDao;
  @Autowired
  private MstWardDao mstWardDao;
  @Autowired
  private MstSeverityDao mstSeverityDao;
  @Autowired
  private MstTransportDao mstTransportDao;
  @Autowired
  private MstFavoriteFacilityDao mstFavoriteFacilityDao;
  @Autowired
  private SysFacilityDao sysFacilityDao;
  @Autowired
  private MstUserAuthenticationDao mstUserAuthenticationDao;
  @Autowired
  private MstAdditionDao mstAdditionDao;
  @Autowired
  MstWheelChairService mstWheelChairSerive;
  @Autowired
  private PatMainDao patMainDao;
  @Autowired
  private PatPersonalMainDao patPersonalMainDao;

  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
  @Autowired
  private LogService logService;
// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end

  @Override
  @Transactional
  public void setPatDataToMongoHistory(PatInfo patInfo) throws Exception {
    //add #10532 mongoDBがダウン中の操作について（新患登録） limingzhe start
    try {
      if (MongoHealthCheckService.getMongoDBConnected()) {
    //add #10532 mongoDBがダウン中の操作について（新患登録） limingzhe end
          // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 start
        ObjectMapper mapper = new ObjectMapper();
        // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 end
        // add #11159 特定の患者だけ患者情報編集時にエラーが発生する ztc 20241003 start
        mapper.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);
        // add #11159 特定の患者だけ患者情報編集時にエラーが発生する ztc 20241003 end
        Timestamp now = new Timestamp(new Date().getTime());

        PatPersonalMain patPersonalMain = patInfo.getPatPersonalMain();
        PatMain patMain = patInfo.getPatMain();
        PatUnique patUnique = patInfo.getPatUnique();
        List<PatGroupCustom> patGroupCustoms = patInfo.getPatGroupList();

        PatPersonalMainHistory patPersonalMainHistory = new PatPersonalMainHistory();
        BeanUtils.copyProperties(patPersonalMain, patPersonalMainHistory);
        patPersonalMainHistory.setIns_date(now);
        Long patId = patPersonalMain.getPat_id();
        String patIdStr = patPersonalMain.getPat_id().toString();
        patPersonalMainHistory.setPat_id(patIdStr);
        if (patPersonalMain.getDie_date() != null) {
          patPersonalMainHistory.setDie_date(patPersonalMain.getDie_date().toString());
        }
        if (patPersonalMain.getDie_cd() != null) {
          patPersonalMainHistory.setDie_cd(patPersonalMain.getDie_cd().toString());
        }
        if (patPersonalMain.getPat_sex() != null) {
          patPersonalMainHistory.setPat_sex(patPersonalMain.getPat_sex().toString());
        }
        if (patPersonalMain.getPat_blood_type_abo() != null) {
          patPersonalMainHistory.setPat_blood_type_abo(patPersonalMain.getPat_blood_type_abo().toString());
        }
        if (patPersonalMain.getPat_blood_type_rh() != null) {
          patPersonalMainHistory.setPat_blood_type_rh(patPersonalMain.getPat_blood_type_rh().toString());
        }
        if (patPersonalMain.getPat_blood_type_serovar() != null) {
          patPersonalMainHistory.setPat_blood_type_serovar(patPersonalMain.getPat_blood_type_serovar().toString());
        }
        if (patPersonalMain.getIn_out_class() != null) {
          patPersonalMainHistory.setIn_out_class(patPersonalMain.getIn_out_class().toString());
        }
        if (patPersonalMain.getSeverity_cd() != null) {
          patPersonalMainHistory.setSeverity_cd(patPersonalMain.getSeverity_cd().toString());
        }
        if (patPersonalMain.getTransport_cd() != null) {
          patPersonalMainHistory.setTransport_cd(patPersonalMain.getTransport_cd().toString());
        }
        if (patPersonalMain.getRemote_monitor_service() != null) {
          patPersonalMainHistory.setRemote_monitor_service(patPersonalMain.getRemote_monitor_service().toString());
        }
        patPersonalMainHistory.setLatest_flag("on");

        PatMainHistory patMainHistory = new PatMainHistory();
        BeanUtils.copyProperties(patMain, patMainHistory);
        patMainHistory.setIns_date(now);
        patMainHistory.setPat_id(patIdStr);
        patMainHistory.setLatest_flag("on");

        PatUniqueHistory patUniqueHistory = new PatUniqueHistory();
        BeanUtils.copyProperties(patUnique, patUniqueHistory);
        patUniqueHistory.setIns_date(now);
        patUniqueHistory.setPat_id(patIdStr);
        patUniqueHistory.setLatest_flag("on");

        // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 start
//        Map<String, Map<String, String>> getMstNames = this.getMstNames(patPersonalMainHistory, patMainHistory, patUniqueHistory);
        Map<String, Map<String, String>> getMstNames = this.getMstNames(patPersonalMain, patMain, patUnique);
        // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 end
        // 登録施設名
        patPersonalMainHistory.setFacility_name(this.getCodeName(getMstNames, "facilityNames", patPersonalMainHistory.getFacility_cd()));
        // 死因
        patPersonalMainHistory.setDie_name(this.getCodeName(getMstNames, "diseaseNames", patPersonalMainHistory.getDie_cd()));
        // 死因連携コード
        String dieHospitalCd1 = "";
        if (patPersonalMainHistory.getDie_cd() != null && !patPersonalMainHistory.getDie_cd().isEmpty() && !"null".equals(patPersonalMainHistory.getDie_cd())) {
          MstDisease mstDisease = mstDiseaseDao.selectByCd(Integer.parseInt(patPersonalMainHistory.getDie_cd()));
          // mod #10366 患者カレンダーで特定条件下で既往歴の病名が削除済みと表示されてしまう 20240429 ztc start
//          dieHospitalCd1 = mstDisease.getInHospitalCd_1() != null ? mstDisease.getInHospitalCd_1() : "";
          dieHospitalCd1 = mstDisease != null && mstDisease.getInHospitalCd_1() != null ? mstDisease.getInHospitalCd_1() : "";
          // mod #10366 患者カレンダーで特定条件下で既往歴の病名が削除済みと表示されてしまう 20240429 ztc end
        }
        patPersonalMainHistory.setDie_in_hospital_cd_1(dieHospitalCd1);
        // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 start
        // 透析困難情報を取得する。
//        JSONArray dialDiffComInfoJson = this.getJSONArray(patPersonalMainHistory.getDial_diff_com_info());
        JSONArray dialDiffComInfoJson = this.getJSONArray(patPersonalMain.getDial_diff_com_info());
        // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 end
        // add 10626 データリストのCTR・DW一括登録修正 房 start
        List<Integer> cdList = new ArrayList<>();
        for (int i = 0; i < dialDiffComInfoJson.length(); i++) {
          JSONObject jsonObj = dialDiffComInfoJson.getJSONObject(i);
          if(jsonObj.has("dial_diff_cd") && jsonObj.get("dial_diff_cd") != null && !jsonObj.get("dial_diff_cd").toString().isEmpty() && !"null".equals(jsonObj.get("dial_diff_cd").toString())) {
            cdList.add(Integer.parseInt(dialDiffComInfoJson.getJSONObject(i).get("dial_diff_cd").toString()));
          }
        }
        List<MstDialysisDifficulty> mstDialysisDifficultyList = mstDialysisDifficultyDao.selectByCds(cdList);
        // add 10626 データリストのCTR・DW一括登録修正 房 end

        // 透析困難情報
        for (int i = 0; i < dialDiffComInfoJson.length(); i++) {
          JSONObject jsonObj = dialDiffComInfoJson.getJSONObject(i);
          // 透析困難名
          // mod #10735 患者情報を保存できない dengshen start
          // jsonObj.put("dial_diff_name", this.getCodeName(getMstNames, "mstDialysisDifficultyNames", jsonObj.get("dial_diff_cd")));
          jsonObj.put("dial_diff_name", this.getCodeName(getMstNames, "mstDialysisDifficultyNames", this.checkCodeStr(jsonObj, "dial_diff_cd")));
          // mod #10735 患者情報を保存できない dengshen end
          // 透析困難理由連携コード
          String dialHospitalCd1 = "", dialHospitalCd2 = "";
          // mod #10735 患者情報を保存できない dengshen start
          // if (jsonObj.get("dial_diff_cd") != null && !jsonObj.get("dial_diff_cd").toString().isEmpty() && !"null".equals(jsonObj.get("dial_diff_cd").toString())) {
          if (jsonObj.has("dial_diff_cd") && jsonObj.get("dial_diff_cd") != null && !jsonObj.get("dial_diff_cd").toString().isEmpty() && !"null".equals(jsonObj.get("dial_diff_cd").toString())) {
          // mod #10735 患者情報を保存できない dengshen end
            // mod 10626 データリストのCTR・DW一括登録修正 房 start
            //  MstDialysisDifficulty mstDialysisDifficulty = mstDialysisDifficultyDao.selectByCd(Integer.parseInt(jsonObj.get("dial_diff_cd").toString()));
            MstDialysisDifficulty mstDialysisDifficulty = mstDialysisDifficultyList.stream().filter(el -> el.getDialysisDifficultyCd().toString().equals(jsonObj.get("dial_diff_cd").toString())).findFirst().get();
            // mod 10626 データリストのCTR・DW一括登録修正 房 end
            // mod #10366 患者カレンダーで特定条件下で既往歴の病名が削除済みと表示されてしまう 20240429 ztc start
//            dialHospitalCd1 = mstDialysisDifficulty.getInHospitalCd_1() != null ? mstDialysisDifficulty.getInHospitalCd_1().toString() : "";
//            dialHospitalCd2 = mstDialysisDifficulty.getInHospitalCd_2() != null ? mstDialysisDifficulty.getInHospitalCd_2().toString() : "";
            dialHospitalCd1 = mstDialysisDifficulty != null && mstDialysisDifficulty.getInHospitalCd_1() != null ? mstDialysisDifficulty.getInHospitalCd_1().toString() : "";
            dialHospitalCd2 = mstDialysisDifficulty != null && mstDialysisDifficulty.getInHospitalCd_2() != null ? mstDialysisDifficulty.getInHospitalCd_2().toString() : "";
            // mod #10366 患者カレンダーで特定条件下で既往歴の病名が削除済みと表示されてしまう 20240429 ztc end
          }
          jsonObj.put("in_hospital_cd_1", dialHospitalCd1);
          jsonObj.put("in_hospital_cd_2", dialHospitalCd2);
        }
        // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 start
//        patPersonalMainHistory.setDial_diff_com_info(dialDiffComInfoJson.toString());
        List<DialDiffComInfo> dialDiffComInfos = mapper.readValue(dialDiffComInfoJson.toString(), new TypeReference<List<DialDiffComInfo>>() {});
        patPersonalMainHistory.setDial_diff_com_info(dialDiffComInfos);
        // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 end
        List<OtherContactInfo> otherContactInfos = mapper.readValue(patPersonalMain.getOther_contact_info(), new TypeReference<List<OtherContactInfo>>() {});
        patPersonalMainHistory.setOther_contact_info(otherContactInfos);

        // 重症度名
        patPersonalMainHistory.setSeverity_name(this.getCodeName(getMstNames, "severityNames", patPersonalMainHistory.getSeverity_cd()));

        // 搬送区分
        patPersonalMainHistory.setTransport_name(this.getCodeName(getMstNames, "transportNames", patPersonalMainHistory.getTransport_cd()));

        // 原疾患
        patPersonalMainHistory.setPrimary_disease_name(this.getCodeName(getMstNames, "diseaseNames", patPersonalMainHistory.getPrimary_disease_cd()));

        // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 start
        // 担当スタッフ情報を取得する。
//        JSONArray chargeStaffInfoJson = this.getJSONArray(patMainHistory.getCharge_staff_info());
        JSONArray chargeStaffInfoJson = this.getJSONArray(patMain.getCharge_staff_info());
        // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 end

        // 登録施設名
        patMainHistory.setFacility_name(this.getCodeName(getMstNames, "facilityNames", patMainHistory.getFacility_cd()));

        // 担当スタッフ情報
        for (int i = 0; i < chargeStaffInfoJson.length(); i++) {
          JSONObject jsonObj = chargeStaffInfoJson.getJSONObject(i);
          // スタッフ
          // mod #10735 患者情報を保存できない dengshen start
          // jsonObj.put("staff_name", this.getCodeName(getMstNames, "personalUserNames", jsonObj.get("staff_cd")));
          jsonObj.put("staff_name", this.getCodeName(getMstNames, "personalUserNames", this.checkCodeStr(jsonObj, "staff_cd")));
          // mod #10735 患者情報を保存できない dengshen end
          // スタッフ表示用コード
          String dispUserId = "";
          // mod #10735 患者情報を保存できない dengshen start
          // if (jsonObj.get("staff_cd") != null && !jsonObj.get("staff_cd").toString().isEmpty() && !"null".equals(jsonObj.get("staff_cd").toString())) {
          if (jsonObj.has("staff_cd") && jsonObj.get("staff_cd") != null && !jsonObj.get("staff_cd").toString().isEmpty() && !"null".equals(jsonObj.get("staff_cd").toString())) {
          // mod #10735 患者情報を保存できない dengshen end
            MstUserAuthentication mstUserAuthentication = mstUserAuthenticationDao.selectById(Long.parseLong(jsonObj.get("staff_cd").toString()));
            // mod #10735 患者情報を保存できない dengshen start
            // dispUserId = mstUserAuthentication.getDispUserId() != null ? mstUserAuthentication.getDispUserId() : "";
            dispUserId = mstUserAuthentication != null && mstUserAuthentication.getDispUserId() != null ? mstUserAuthentication.getDispUserId() : "";
            // mod #10735 患者情報を保存できない dengshen end
          }
          jsonObj.put("staff_disp_cd", dispUserId);
        }
        // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 start
//        patMainHistory.setCharge_staff_info(chargeStaffInfoJson.toString());
        List<ChargeStaffInfo> chargeStaffInfos = mapper.readValue(chargeStaffInfoJson.toString(), new TypeReference<List<ChargeStaffInfo>>() {});
        patMainHistory.setCharge_staff_info(chargeStaffInfos);

        // 感染症情報を取得する。
//        JSONArray infectInfoJson = this.getJSONArray(patMainHistory.getInfect_info());
        JSONArray infectInfoJson = this.getJSONArray(patMain.getInfect_info());
        // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 end

        // 感染症情報
        for (int i = 0; i < infectInfoJson.length(); i++) {
          JSONObject jsonObj = infectInfoJson.getJSONObject(i);
          // 感染症名
          // mod #10735 患者情報を保存できない dengshen start
          // j.put("infection_name", this.getCodeName(getMstNames, "infectionNames", jsonObj.get("infection_cd")));
          jsonObj.put("infection_name", this.getCodeName(getMstNames, "infectionNames", this.checkCodeStr(jsonObj, "infection_cd")));
          // mod #10735 患者情報を保存できない dengshen end
        }
        // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 start
//        patMainHistory.setInfect_info(infectInfoJson.toString());
        List<InfectInfo> infectInfos = mapper.readValue(infectInfoJson.toString(), new TypeReference<List<InfectInfo>>() {});
        patMainHistory.setInfect_info(infectInfos);

        // インプラント情報を取得する。
//        JSONArray implantInfoJson = this.getJSONArray(patMainHistory.getImplant_info());
        JSONArray implantInfoJson = this.getJSONArray(patMain.getImplant_info());
        // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 end

        // インプラント情報
        for (int i = 0; i < implantInfoJson.length(); i++) {
          JSONObject jsonObj = implantInfoJson.getJSONObject(i);
          // インプラント名
          // mod #10735 患者情報を保存できない dengshen start
          // jsonObj.put("implant_name", this.getCodeName(getMstNames, "implantNames", jsonObj.get("implant_cd")));
          jsonObj.put("implant_name", this.getCodeName(getMstNames, "implantNames", this.checkCodeStr(jsonObj, "implant_cd")));
          // mod #10735 患者情報を保存できない dengshen end
        }
        // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 start
//        patMainHistory.setImplant_info(implantInfoJson.toString());
        List<ImplantInfo> implantInfos = mapper.readValue(implantInfoJson.toString(), new TypeReference<List<ImplantInfo>>() {});
        patMainHistory.setImplant_info(implantInfos);

        // 共通診療情報を取得する。
//        JSONObject medicalCareInfoJson = new JSONObject(patMainHistory.getMedical_care_info());
        JSONObject medicalCareInfoJson = new JSONObject(patMain.getMedical_care_info());
        // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 end

        // 共通診療情報
        // 主科名
        medicalCareInfoJson.put("main_course_name", this.getCodeName(getMstNames, "courseNames", medicalCareInfoJson.get("main_course_cd")));

        // 透析実施科名
        medicalCareInfoJson.put("dialysis_course_name", this.getCodeName(getMstNames, "courseNames", medicalCareInfoJson.get("dialysis_course_cd")));

        // 診療科連携コード
        String courseHospitalCd = "";
        // mod #10735 患者情報を保存できない dengshen start
        // if (medicalCareInfoJson.get("main_course_cd") != null && !medicalCareInfoJson.get("main_course_cd").toString().isEmpty() && !"null".equals(medicalCareInfoJson.get("main_course_cd").toString())) {
        if (medicalCareInfoJson.has("main_course_cd") && medicalCareInfoJson.get("main_course_cd") != null && !medicalCareInfoJson.get("main_course_cd").toString().isEmpty() && !"null".equals(medicalCareInfoJson.get("main_course_cd").toString())) {
        // mod #10735 患者情報を保存できない dengshen end
          MstCourse mstCourse = mstCourseDao.selectByCd(Integer.parseInt(medicalCareInfoJson.get("main_course_cd").toString()));
          // mod #10735 患者情報を保存できない dengshen start
          // courseHospitalCd = mstCourse.getInHospitalCd_1() != null ? mstCourse.getInHospitalCd_1() : "";
          courseHospitalCd = mstCourse != null && mstCourse.getInHospitalCd_1() != null ? mstCourse.getInHospitalCd_1() : "";
          // mod #10735 患者情報を保存できない dengshen end
        }
        medicalCareInfoJson.put("main_in_hospital_cd_1", courseHospitalCd);

        // 病棟名
        medicalCareInfoJson.put("ward_name", this.getCodeName(getMstNames, "wardNames", medicalCareInfoJson.get("ward_cd")));

        // 病棟名連携コード
        String wardHospitalCd = "";
        // mod #10735 患者情報を保存できない dengshen start
        // if (medicalCareInfoJson.get("ward_cd") != null && !medicalCareInfoJson.get("ward_cd").toString().isEmpty() && !"null".equals(medicalCareInfoJson.get("ward_cd").toString())) {
        if (medicalCareInfoJson.has("ward_cd") && medicalCareInfoJson.get("ward_cd") != null && !medicalCareInfoJson.get("ward_cd").toString().isEmpty() && !"null".equals(medicalCareInfoJson.get("ward_cd").toString())) {
        // mod #10735 患者情報を保存できない dengshen end
          MstWard mstWard = mstWardDao.selectByCd(Integer.parseInt(medicalCareInfoJson.get("ward_cd").toString()));
          // mod #10735 患者情報を保存できない dengshen start
          // wardHospitalCd = mstWard.getInHospitalCd_1() != null ? mstWard.getInHospitalCd_1() : "";
          wardHospitalCd = mstWard != null && mstWard.getInHospitalCd_1() != null ? mstWard.getInHospitalCd_1() : "";
          // mod #10735 患者情報を保存できない dengshen end
        }
        medicalCareInfoJson.put("ward_in_hospital_cd_1", wardHospitalCd);

        // 導入施設名
        // mod #10735 患者情報を保存できない dengshen start
        // medicalCareInfoJson.put("facility_name", this.getCodeName(getMstNames, "sysFacilityNames", medicalCareInfoJson.get("facility_cd")));
        medicalCareInfoJson.put("facility_name", this.getCodeName(getMstNames, "sysFacilityNames", this.checkCodeStr(medicalCareInfoJson, "facility_cd")));
        // mod #10735 患者情報を保存できない dengshen end

                // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 start
//        patMainHistory.setMedical_care_info(medicalCareInfoJson.toString());
        MedicalCareInfo medicalCareInfos = mapper.readValue(medicalCareInfoJson.toString(), new TypeReference<MedicalCareInfo>() {});
        patMainHistory.setMedical_care_info(medicalCareInfos);
        // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 end

        List<WheelChairWithNameResponse> chair = mstWheelChairSerive.getWheelChairListByPatId(patId, patMainHistory.getFacility_cd());
        if (chair != null && !chair.isEmpty()) {
          // 個人所有車いす割当あり
          patMainHistory.setWheel_chair_cd(chair.get(0).getWheelChairCd());
          patMainHistory.setWheel_chair_name(chair.get(0).getWheelChairName());
          patMainHistory.setWheel_chair_weight(chair.get(0).getWheelChairWeight());
        }else if(patMain.getWheel_chair_cd() != null){
          // 共用車いす割当あり
          WheelChairWithNameResponse sharingChair = mstWheelChairSerive.getWheelChair(patMain.getWheel_chair_cd(),null,null);
          if(sharingChair != null) {
            patMainHistory.setWheel_chair_cd(sharingChair.getWheelChairCd());
            patMainHistory.setWheel_chair_name(sharingChair.getWheelChairName());
            patMainHistory.setWheel_chair_weight(sharingChair.getWheelChairWeight());
          }
        }

        // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 start
        // 加算情報を取得する。
//        JSONArray additionInfoJson = this.getJSONArray(patMainHistory.getAddition_info());
        JSONArray additionInfoJson = this.getJSONArray(patMain.getAddition_info());
        // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 end
        // 加算情報
        for (int i = 0; i < additionInfoJson.length(); i++) {
          JSONObject jsonObj = additionInfoJson.getJSONObject(i);
          // 加算・管理料コード名称
          // mod #10735 患者情報を保存できない dengshen start
          // jsonObj.put("name", this.getCodeName(getMstNames, "additionNames", jsonObj.get("cd")));
          jsonObj.put("name", this.getCodeName(getMstNames, "additionNames", this.checkCodeStr(jsonObj, "cd")));
          // mod #10735 患者情報を保存できない dengshen end
          // 加算形式
          // mod #10735 患者情報を保存できない dengshen start
          // .put("kind", this.getCodeName(getMstNames, "additionKinds", jsonObj.get("cd")));
          jsonObj.put("kind", this.getCodeName(getMstNames, "additionKinds", this.checkCodeStr(jsonObj, "cd")));
          // mod #10735 患者情報を保存できない dengshen end
          // 最終算定日
          // mod #10735 患者情報を保存できない dengshen start
          // jsonObj.put("last_date", this.getCodeName(getMstNames, "additionLastDates", jsonObj.get("cd")));
          jsonObj.put("last_date", this.getCodeName(getMstNames, "additionLastDates", this.checkCodeStr(jsonObj, "cd")));
          // mod #10735 患者情報を保存できない dengshen end
        }
        // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 start
//        patMainHistory.setAddition_info(additionInfoJson.toString());
        List<AdditionInfo> additionInfos = mapper.readValue(additionInfoJson.toString(), new TypeReference<List<AdditionInfo>>() {});
        patMainHistory.setAddition_info(additionInfos);

        // 既往歴情報を取得する。
//        JSONArray medicalHstInfoJson = this.getJSONArray(patUniqueHistory.getMedical_hst_info());
        JSONArray medicalHstInfoJson = this.getJSONArray(patUnique.getMedical_hst_info());
        // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 end
        String dialysisUnderlyingDisease = null;
        // add 10626 データリストのCTR・DW一括登録修正 房 start
        cdList = new ArrayList();
        for (int i = 0; i < medicalHstInfoJson.length(); i++) {
          JSONObject jsonObj = medicalHstInfoJson.getJSONObject(i);
          if (jsonObj.has("disease_cd") && jsonObj.get("disease_cd") != null && !jsonObj.get("disease_cd").toString().isEmpty() && !"null".equals(jsonObj.get("disease_cd").toString())) {
            cdList.add(Integer.parseInt(jsonObj.get("disease_cd").toString()));
          }
        }
        List<MstDisease> mstDiseases = mstDiseaseDao.selectByCds(cdList);
        // add 10626 データリストのCTR・DW一括登録修正 房 end
        // 既往歴情報
        for (int i = 0; i < medicalHstInfoJson.length(); i++) {
          JSONObject jsonObj = medicalHstInfoJson.getJSONObject(i);
          // 登録施設名
          // mod #10735 患者情報を保存できない dengshen start
          // jsonObj.put("facility_name", this.getCodeName(getMstNames, "facilityNames", jsonObj.get("facility_cd")));
          jsonObj.put("facility_name", this.getCodeName(getMstNames, "facilityNames", this.checkCodeStr(jsonObj, "facility_cd")));
          // mod #10735 患者情報を保存できない dengshen end
          // 病名マスタ.病名
          // mod #10735 患者情報を保存できない dengshen start
          // jsonObj.put("disease_name", this.getCodeName(getMstNames, "diseaseNames", jsonObj.get("disease_cd")));
          jsonObj.put("disease_name", this.getCodeName(getMstNames, "diseaseNames", this.checkCodeStr(jsonObj, "disease_cd")));
          // mod #10735 患者情報を保存できない dengshen end
          // 病名マスタ.病名連携コード
          String diseaseHospitalCd = "";
          // mod #10735 患者情報を保存できない dengshen start
          // if (jsonObj.get("disease_cd") != null && !jsonObj.get("disease_cd").toString().isEmpty() && !"null".equals(jsonObj.get("disease_cd").toString())) {
          if (jsonObj.has("disease_cd") && jsonObj.get("disease_cd") != null && !jsonObj.get("disease_cd").toString().isEmpty() && !"null".equals(jsonObj.get("disease_cd").toString())) {
          // mod #10735 患者情報を保存できない dengshen end
            // mod 10626 データリストのCTR・DW一括登録修正 房 start
//            MstDisease mstDisease = mstDiseaseDao.selectByCd(Integer.parseInt(jsonObj.get("disease_cd").toString()));
            Optional<MstDisease> mstDisease = mstDiseases.stream().filter(el -> el.getDiseaseCd().toString().equals(jsonObj.get("disease_cd").toString())).findFirst();
            // mod #10366 患者カレンダーで特定条件下で既往歴の病名が削除済みと表示されてしまう 20240429 ztc start
//            diseaseHospitalCd = mstDisease.getInHospitalCd_1() != null ? mstDisease.getInHospitalCd_1() : "";
//            diseaseHospitalCd = mstDisease != null && mstDisease.getInHospitalCd_1() != null ? mstDisease.getInHospitalCd_1() : "";
            diseaseHospitalCd = mstDisease.isPresent() && mstDisease.get().getInHospitalCd_1() != null ? mstDisease.get().getInHospitalCd_1() : "";
            // mod 10626 データリストのCTR・DW一括登録修正 房 end
            // mod #10366 患者カレンダーで特定条件下で既往歴の病名が削除済みと表示されてしまう 20240429 ztc end
          }
          jsonObj.put("dis_in_hospital_cd_1", diseaseHospitalCd);
          // 施設施設名
          inputCdCheck(jsonObj, "diagnosis_facility_cd", "diagnosis_facility_name",
            // mod #10735 患者情報を保存できない dengshen start
            // getMstNames, "sysFacilityNames", jsonObj.get("diagnosis_facility_is_free").toString());
            getMstNames, "sysFacilityNames", this.checkCodeStr(jsonObj, "diagnosis_facility_is_free"));
            // mod #10735 患者情報を保存できない dengshen end
          // 診断医名
          inputCdCheck(jsonObj, "diagnostician_cd", "diagnostician_name",
            // mod #10735 患者情報を保存できない dengshen start
            // getMstNames, "personalUserNames", jsonObj.get("diagnostician_is_free").toString());
            getMstNames, "personalUserNames", this.checkCodeStr(jsonObj, "diagnostician_is_free"));
            // mod #10735 患者情報を保存できない dengshen end
          // 診療科名
          // mod #10735 患者情報を保存できない dengshen start
          // inputCdCheck(jsonObj, "course_cd", "course_name", getMstNames, "courseNames", jsonObj.get("course_is_free").toString());
          inputCdCheck(jsonObj, "course_cd", "course_name", getMstNames, "courseNames", this.checkCodeStr(jsonObj, "course_is_free"));
          // mod #10735 患者情報を保存できない dengshen end
          if ("1".equals(jsonObj.get("is_dialysis_underlying_disease").toString()))
            // mod #10735 患者情報を保存できない dengshen start
            // dialysisUnderlyingDisease = this.getCodeName(getMstNames, "diseaseNames", jsonObj.get("disease_cd"));
            dialysisUnderlyingDisease = this.getCodeName(getMstNames, "diseaseNames", this.checkCodeStr(jsonObj, "disease_cd"));
            // mod #10735 患者情報を保存できない dengshen end
        }
        // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 start
//        patUniqueHistory.setMedical_hst_info(medicalHstInfoJson.toString());
        List<MedicalHstInfo> medicalHstInfos = mapper.readValue(medicalHstInfoJson.toString(), new TypeReference<List<MedicalHstInfo>>() {});
        patUniqueHistory.setMedical_hst_info(medicalHstInfos);
        patMainHistory.setDialysis_underlying_disease(dialysisUnderlyingDisease);
        // 入外・転入出情報を取得する。
//        JSONArray inoutVisitHistoryInfoJson = this.getJSONArray(patUniqueHistory.getIn_out_visit_history_info());
        JSONArray inoutVisitHistoryInfoJson = this.getJSONArray(patUnique.getIn_out_visit_history_info());
        // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 end

        // 入外・転入出情報
        for (int i = 0; i < inoutVisitHistoryInfoJson.length(); i++) {
          JSONObject jsonObj = inoutVisitHistoryInfoJson.getJSONObject(i);
          // 登録施設名
          // mod #10735 患者情報を保存できない dengshen start
          // jsonObj.put("facility_name", this.getCodeName(getMstNames, "facilityNames", jsonObj.get("facility_cd")));
          jsonObj.put("facility_name", this.getCodeName(getMstNames, "facilityNames", this.checkCodeStr(jsonObj, "facility_cd")));
          // mod #10735 患者情報を保存できない dengshen end
          String moveInOut = this.getCode(inoutVisitHistoryInfoJson.getJSONObject(i), "move_in_out", String.class);
          switch (moveInOut) {
            case "3":
            case "4":
            case "5":
            case "9":
              // 元施設
              // mod #10735 患者情報を保存できない dengshen start
              // inputCdCheck(jsonObj, "from_facility", "from_facility_name", getMstNames, "facilityNames", jsonObj.get("facility_is_free").toString());
              inputCdCheck(jsonObj, "from_facility", "from_facility_name", getMstNames, "facilityNames", this.checkCodeStr(jsonObj, "facility_is_free"));
              // mod #10735 患者情報を保存できない dengshen end
              // 先施設
              // mod #10735 患者情報を保存できない dengshen start
              // inputCdCheck(jsonObj, "to_facility", "to_facility_name", getMstNames, "sysFacilityNames", jsonObj.get("facility_is_free").toString());
              inputCdCheck(jsonObj, "to_facility", "to_facility_name", getMstNames, "sysFacilityNames", this.checkCodeStr(jsonObj, "facility_is_free"));
              // mod #10735 患者情報を保存できない dengshen end
              break;
            case "1":
            case "2":
            case "6":
            case "7":
            case "8":
            case "10":
              // 元施設
              // mod #10735 患者情報を保存できない dengshen start
              // inputCdCheck(jsonObj, "from_facility", "from_facility_name", getMstNames, "sysFacilityNames", jsonObj.get("facility_is_free").toString());
              inputCdCheck(jsonObj, "from_facility", "from_facility_name", getMstNames, "sysFacilityNames", this.checkCodeStr(jsonObj, "facility_is_free"));
              // mod #10735 患者情報を保存できない dengshen end
              // 先施設
              // mod #10735 患者情報を保存できない dengshen start
              // inputCdCheck(jsonObj, "to_facility", "to_facility_name", getMstNames, "facilityNames", jsonObj.get("facility_is_free").toString());
              inputCdCheck(jsonObj, "to_facility", "to_facility_name", getMstNames, "facilityNames", this.checkCodeStr(jsonObj, "facility_is_free"));
              // mod #10735 患者情報を保存できない dengshen end
              break;
          }
          // 元科
          // mod #10735 患者情報を保存できない dengshen start
          // inputCdCheck(jsonObj, "from_course", "from_course_name", getMstNames, "courseNames", jsonObj.get("course_is_free").toString());
          inputCdCheck(jsonObj, "from_course", "from_course_name", getMstNames, "courseNames", this.checkCodeStr(jsonObj, "course_is_free"));
          // mod #10735 患者情報を保存できない dengshen end
          // 元施設医
          // mod #10735 患者情報を保存できない dengshen start
          // inputCdCheck(jsonObj, "from_doctor", "from_doctor_name", getMstNames, "personalUserNames", jsonObj.get("doctor_is_free").toString());
          inputCdCheck(jsonObj, "from_doctor", "from_doctor_name", getMstNames, "personalUserNames", this.checkCodeStr(jsonObj, "doctor_is_free"));
          // mod #10735 患者情報を保存できない dengshen end
          // 元医療機関
          jsonObj.put("from_medicalInstitution_name", this.getCodeName(getMstNames, "medicalInstitutionNames",
            jsonObj.has("from_medicalInstitutionCd") ? jsonObj.get("from_medicalInstitutionCd") : ""));
          // 先科
          // mod #10735 患者情報を保存できない dengshen start
          // inputCdCheck(jsonObj, "to_course", "to_course_name", getMstNames, "courseNames", jsonObj.get("course_is_free").toString());
          inputCdCheck(jsonObj, "to_course", "to_course_name", getMstNames, "courseNames", this.checkCodeStr(jsonObj, "course_is_free"));
          // mod #10735 患者情報を保存できない dengshen end
          // 先施設医
          // mod #10735 患者情報を保存できない dengshen start
          // inputCdCheck(jsonObj, "to_doctor", "to_doctor_name", getMstNames, "personalUserNames", jsonObj.get("doctor_is_free").toString());
          inputCdCheck(jsonObj, "to_doctor", "to_doctor_name", getMstNames, "personalUserNames", this.checkCodeStr(jsonObj, "doctor_is_free"));
          // mod #10735 患者情報を保存できない dengshen end
          // 先医療機関
          jsonObj.put("to_medicalInstitution_name", this.getCodeName(getMstNames, "medicalInstitutionNames",
            jsonObj.has("to_medicalInstitutionCd") ? jsonObj.get("to_medicalInstitutionCd") : ""));
        }
        // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 start
//        patUniqueHistory.setIn_out_visit_history_info(inoutVisitHistoryInfoJson.toString());
        List<InOutVisitHistoryInfo> inOutVisitHistoryInfos = mapper.readValue(inoutVisitHistoryInfoJson.toString(), new TypeReference<List<InOutVisitHistoryInfo>>() {});
        patUniqueHistory.setIn_out_visit_history_info(inOutVisitHistoryInfos);

        // 身体情報を取得する。
//        JSONArray physicalInfoJson = this.getJSONArray(patUniqueHistory.getPhysical_info());
        JSONArray physicalInfoJson = this.getJSONArray(patUnique.getPhysical_info());

        // 身体情報
        for (int i = 0; i < physicalInfoJson.length(); i++) {
          JSONObject jsonObj = physicalInfoJson.getJSONObject(i);
          // 指示者
          // mod #10735 患者情報を保存できない dengshen start
          // jsonObj.put("indicator_name", this.getCodeName(getMstNames, "personalUserNames", jsonObj.get("indicator_cd")));
          jsonObj.put("indicator_name", this.getCodeName(getMstNames, "personalUserNames", this.checkCodeStr(jsonObj, "indicator_cd")));
          // mod #10735 患者情報を保存できない dengshen end
          // 施設名
          // mod #10735 患者情報を保存できない dengshen start
          // jsonObj.put("facility_name", this.getCodeName(getMstNames, "facilityNames", jsonObj.get("facility_cd")));
          jsonObj.put("facility_name", this.getCodeName(getMstNames, "facilityNames", this.checkCodeStr(jsonObj, "facility_cd")));
          // mod #10735 患者情報を保存できない dengshen end
        }
        List<PhysicalInfo> physicalInfoHistoryInfos = mapper.readValue(physicalInfoJson.toString(), new TypeReference<List<PhysicalInfo>>() {});
        //        patUniqueHistory.setPhysical_info(physicalInfoJson.toString());
        patUniqueHistory.setPhysical_info(physicalInfoHistoryInfos);
        // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 end

        Query query = new Query();
        Update update = new Update();
        query.addCriteria(Criteria.where("pat_id").is(patId.toString()));
        // add 10626 データリストのCTR・DW一括登録修正 房 start
        query.addCriteria(Criteria.where("facility_cd").is(patPersonalMainHistory.getFacility_cd()));
        // add 10626 データリストのCTR・DW一括登録修正 房 end
        query.addCriteria(Criteria.where("latest_flag").ne("off"));
        update.set("latest_flag", "off");
        mongoTemplate.updateMulti(query, update, PatPersonalMainHistory.class);
        mongoTemplate.updateMulti(query, update, PatUniqueHistory.class);

        mongoTemplate.insert(patPersonalMainHistory);
        mongoTemplate.insert(patUniqueHistory);

        PatGroupDetailHistory patGroupDetailHistory = new PatGroupDetailHistory();

        if (patGroupCustoms != null) {
          JSONArray patGroupInfoJson = new JSONArray();
          BeanUtils.copyProperties(patGroupCustoms, patGroupDetailHistory);
          for (int i = 0; i < patGroupCustoms.size(); i++) {
            PatGroupCustom patGroupCustom = patGroupCustoms.get(i);
            JSONObject jsonObj = new JSONObject();
            jsonObj.put("ctl_no", i + 1);
            // mod #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 start
            // 患者グループコード
//            String patGroupCd = String.valueOf(patGroupCustom.getPatGroupCd());
            String patGroupCd = patGroupCustom.getPatGroupCd() != null ? String.valueOf(patGroupCustom.getPatGroupCd()) : "";
            // mod #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 end
            String patGroupName = patGroupCustom.getPatGroupName();
            patGroupDetailHistory.setPat_group_cd(patGroupCd);
            jsonObj.put("pat_group_cd", patGroupCd);
            // 患者グループ名
            patGroupDetailHistory.setPat_group_name(patGroupName);
            jsonObj.put("pat_group_name", patGroupName);
            patGroupInfoJson.put(jsonObj);
            patGroupDetailHistory.setIns_date(now);
            patGroupDetailHistory.setPat_id(patIdStr);
            // facility_cd
            String facilityCdT = patPersonalMain.getFacility_cd();
            patGroupDetailHistory.setFacility_cd(facilityCdT);
            patGroupDetailHistory.setReg_date(patPersonalMain.getReg_date());
            patGroupDetailHistory.setUp_date(patPersonalMain.getUp_date());
            mongoTemplate.insert(patGroupDetailHistory);
          }
          // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 start
//          patMainHistory.setPat_group_info(patGroupInfoJson.toString());
          List<PatGroupInfo> patGroupInfos = mapper.readValue(patGroupInfoJson.toString(), new TypeReference<List<PatGroupInfo>>() {});
          // add #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 start
          if (patGroupInfos.size() > 0) {
            AtomicInteger atomicInteger = new AtomicInteger(1);
            patGroupInfos.forEach(pginfo -> pginfo.setCtl_no(atomicInteger.getAndIncrement()));
          }
          // add #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 end
          patMainHistory.setPat_group_info(patGroupInfos);
          // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 end
          List<PatMemoInfo> patMemoInfos = mapper.readValue(patMain.getPat_memo_info(), new TypeReference<List<PatMemoInfo>>() {});
          patMainHistory.setPat_memo_info(patMemoInfos);
          List<TabooAllergyInfo> tabooAllergyInfos = mapper.readValue(patMain.getTaboo_allergy_info(), new TypeReference<List<TabooAllergyInfo>>() {});
          patMainHistory.setTaboo_allergy_info(tabooAllergyInfos);
        }
        Query query1 = new Query();
        Update update1 = new Update();
        query1.addCriteria(Criteria.where("pat_id").is(patId.toString()));
        // add 10626 データリストのCTR・DW一括登録修正 房 start
        query1.addCriteria(Criteria.where("facility_cd").is(patPersonalMainHistory.getFacility_cd()));
        // add 10626 データリストのCTR・DW一括登録修正 房 end
        query1.addCriteria(Criteria.where("latest_flag").ne("off"));
        update1.set("latest_flag", "off");
        mongoTemplate.updateMulti(query1, update1, PatMainHistory.class);
        mongoTemplate.insert(patMainHistory);
    //add #10532 mongoDBがダウン中の操作について（新患登録） limingzhe start
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
    //add #10532 mongoDBがダウン中の操作について（新患登録） limingzhe end
  }
  // add #10436 同姓同名フラグの更新時に対になる患者のpat_main_historyがinsertされていない zhao start
  @Override
  @Transactional
  public void setPatIsSameDataToMongoHistory(PatInfo patInfo) throws Exception {
    // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 start
    ObjectMapper mapper = new ObjectMapper();
    // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 end
    // add #11159 特定の患者だけ患者情報編集時にエラーが発生する ztc 20241003 start
    mapper.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);
    // add #11159 特定の患者だけ患者情報編集時にエラーが発生する ztc 20241003 end
    Long patId = patInfo.getPatMain().getPat_id();
    PatMain patMain = patInfo.getPatMain();
    if(patMain == null) return;
    PatMainHistory patMainHistory = new PatMainHistory();
    BeanUtils.copyProperties(patMain, patMainHistory);
    Timestamp now = new Timestamp(new Date().getTime());
    patMainHistory.setIns_date(now);
    patMainHistory.setPat_id(patMain.getPat_id().toString());
    patMainHistory.setLatest_flag("on");
    LocalDateTime currentTime = LocalDateTime.now();
    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
    patMainHistory.setUp_date(currentTime.format(formatter));

    PatPersonalMain patPersonalMain = patPersonalMainDao.selectById(patId);
    PatPersonalMainHistory patPersonalMainHistory = new PatPersonalMainHistory();
    BeanUtils.copyProperties(patPersonalMain, patPersonalMainHistory);
    PatUnique patUnique = patUniqueDao.selectById(patId);
    PatUniqueHistory patUniqueHistory = new PatUniqueHistory();
    BeanUtils.copyProperties(patUnique, patUniqueHistory);
    // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 start
//    Map<String, Map<String, String>> getMstNames = this.getMstNames(patPersonalMainHistory, patMainHistory, patUniqueHistory);
    Map<String, Map<String, String>> getMstNames = this.getMstNames(patPersonalMain, patMain, patUnique);
    // 登録施設名
    patMainHistory.setFacility_name(this.getCodeName(getMstNames, "facilityNames", patMainHistory.getFacility_cd()));
    // 担当スタッフ情報を取得する。
//    JSONArray chargeStaffInfoJson = this.getJSONArray(patMainHistory.getCharge_staff_info());
    JSONArray chargeStaffInfoJson = this.getJSONArray(patMain.getCharge_staff_info());
    // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 end
    // 担当スタッフ情報
    for (int i = 0; i < chargeStaffInfoJson.length(); i++) {
      JSONObject jsonObj = chargeStaffInfoJson.getJSONObject(i);
      // スタッフ
      // mod #10735 患者情報を保存できない dengshen start
      // jsonObj.put("staff_name", this.getCodeName(getMstNames, "personalUserNames", jsonObj.get("staff_cd")));
      jsonObj.put("staff_name", this.getCodeName(getMstNames, "personalUserNames", this.checkCodeStr(jsonObj, "staff_cd")));
      // mod #10735 患者情報を保存できない dengshen end
      // スタッフ表示用コード
      String dispUserId =  "";
      // mod #10735 患者情報を保存できない dengshen start
      // if(!StringUtils.isEmpty(jsonObj.get("staff_cd").toString()) && !"null".equals(jsonObj.get("staff_cd").toString())){
      if(jsonObj.has("staff_cd") && !StringUtils.isEmpty(jsonObj.get("staff_cd").toString()) && !"null".equals(jsonObj.get("staff_cd").toString())){
      // mod #10735 患者情報を保存できない dengshen end
        MstUserAuthentication mstUserAuthentication = mstUserAuthenticationDao.selectById(Long.parseLong(jsonObj.get("staff_cd").toString()));
        // mod #10735 患者情報を保存できない dengshen start
        // dispUserId = mstUserAuthentication.getDispUserId() != null ? mstUserAuthentication.getDispUserId().toString() : "";
        dispUserId = mstUserAuthentication != null && mstUserAuthentication.getDispUserId() != null ? mstUserAuthentication.getDispUserId().toString() : "";
        // mod #10735 患者情報を保存できない dengshen end
      }
      jsonObj.put("staff_disp_cd", dispUserId);
    }
    // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 start
//    patMainHistory.setCharge_staff_info(chargeStaffInfoJson.toString());
    List<ChargeStaffInfo> chargeStaffInfos = mapper.readValue(chargeStaffInfoJson.toString(), new TypeReference<List<ChargeStaffInfo>>() {});
    patMainHistory.setCharge_staff_info(chargeStaffInfos);

    // 感染症情報を取得する。
//    JSONArray infectInfoJson = this.getJSONArray(patMainHistory.getInfect_info());
    JSONArray infectInfoJson = this.getJSONArray(patMain.getInfect_info());
    // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 end
    // 感染症情報
    for (int i = 0; i < infectInfoJson.length(); i++) {
      JSONObject jsonObj = infectInfoJson.getJSONObject(i);
      // 感染症名
      // mod #10735 患者情報を保存できない dengshen start
      // jsonObj.put("infection_name", this.getCodeName(getMstNames, "infectionNames", jsonObj.get("infection_cd")));
      jsonObj.put("infection_name", this.getCodeName(getMstNames, "infectionNames", this.checkCodeStr(jsonObj, "infection_cd")));
      // mod #10735 患者情報を保存できない dengshen end
    }
    // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 start
//    patMainHistory.setInfect_info(infectInfoJson.toString());
    List<InfectInfo> infectInfos = mapper.readValue(infectInfoJson.toString(), new TypeReference<List<InfectInfo>>() {});
    patMainHistory.setInfect_info(infectInfos);

    // インプラント情報を取得する。
//    JSONArray implantInfoJson = this.getJSONArray(patMainHistory.getImplant_info());
    JSONArray implantInfoJson = this.getJSONArray(patMain.getImplant_info());
    // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 end
    // インプラント情報
    for (int i = 0; i < implantInfoJson.length(); i++) {
      JSONObject jsonObj = implantInfoJson.getJSONObject(i);
      // インプラント名
      // mod #10735 患者情報を保存できない dengshen start
      // jsonObj.put("implant_name", this.getCodeName(getMstNames, "implantNames", jsonObj.get("implant_cd")));
      jsonObj.put("implant_name", this.getCodeName(getMstNames, "implantNames", this.checkCodeStr(jsonObj, "implant_cd")));
      // mod #10735 患者情報を保存できない dengshen end
    }
    // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 start
//    patMainHistory.setImplant_info(implantInfoJson.toString());
    List<ImplantInfo> implantInfos = mapper.readValue(implantInfoJson.toString(), new TypeReference<List<ImplantInfo>>() {});
    patMainHistory.setImplant_info(implantInfos);

    // 共通診療情報を取得する。
//    JSONObject medicalCareInfoJson = new JSONObject(patMainHistory.getMedical_care_info());
    JSONObject medicalCareInfoJson = new JSONObject(patMain.getMedical_care_info());
    // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 end
    // 共通診療情報
    // 主科名
    // mod #10735 患者情報を保存できない dengshen start
    // medicalCareInfoJson.put("main_course_name", this.getCodeName(getMstNames, "courseNames", medicalCareInfoJson.get("main_course_cd")));
    medicalCareInfoJson.put("main_course_name", this.getCodeName(getMstNames, "courseNames", this.checkCodeStr(medicalCareInfoJson, "main_course_cd")));
    // mod #10735 患者情報を保存できない dengshen end
    // 透析実施科名
    // mod #10735 患者情報を保存できない dengshen start
    // medicalCareInfoJson.put("dialysis_course_name", this.getCodeName(getMstNames, "courseNames", medicalCareInfoJson.get("dialysis_course_cd")));
    medicalCareInfoJson.put("dialysis_course_name", this.getCodeName(getMstNames, "courseNames", this.checkCodeStr(medicalCareInfoJson, "dialysis_course_cd")));
    // mod #10735 患者情報を保存できない dengshen end
    // 診療科連携コード
    String courseHospitalCd =  "";
    // mod #10735 患者情報を保存できない dengshen start
    // if(!StringUtils.isEmpty(medicalCareInfoJson.get("main_course_cd").toString()) && !"null".equals(medicalCareInfoJson.get("main_course_cd").toString())){
    if(medicalCareInfoJson.has("main_course_cd") && !StringUtils.isEmpty(medicalCareInfoJson.get("main_course_cd").toString()) && !"null".equals(medicalCareInfoJson.get("main_course_cd").toString())){
    // mod #10735 患者情報を保存できない dengshen end
      MstCourse mstCourse = mstCourseDao.selectByCd(Integer.parseInt(medicalCareInfoJson.get("main_course_cd").toString()));
      // mod #10735 患者情報を保存できない dengshen start
      // courseHospitalCd = mstCourse.getInHospitalCd_1() != null ? mstCourse.getInHospitalCd_1().toString() : "";
      courseHospitalCd = mstCourse != null && mstCourse.getInHospitalCd_1() != null ? mstCourse.getInHospitalCd_1().toString() : "";
      // mod #10735 患者情報を保存できない dengshen end
    }
    medicalCareInfoJson.put("main_in_hospital_cd_1", courseHospitalCd);
    // 病棟名
    // mod #10735 患者情報を保存できない dengshen start
    // medicalCareInfoJson.put("ward_name", this.getCodeName(getMstNames, "wardNames", medicalCareInfoJson.get("ward_cd")));
    medicalCareInfoJson.put("ward_name", this.getCodeName(getMstNames, "wardNames", this.checkCodeStr(medicalCareInfoJson, "ward_cd")));
    // mod #10735 患者情報を保存できない dengshen end
    // 病棟名連携コード
    String wardHospitalCd =  "";
    // mod #10735 患者情報を保存できない dengshen start
    // if(!StringUtils.isEmpty(medicalCareInfoJson.get("ward_cd").toString()) && !"null".equals(medicalCareInfoJson.get("ward_cd").toString())){
    if(medicalCareInfoJson.has("ward_cd") && !StringUtils.isEmpty(medicalCareInfoJson.get("ward_cd").toString()) && !"null".equals(medicalCareInfoJson.get("ward_cd").toString())){
    // mod #10735 患者情報を保存できない dengshen end
      MstWard mstWard = mstWardDao.selectByCd(Integer.parseInt(medicalCareInfoJson.get("ward_cd").toString()));
      // mod #10735 患者情報を保存できない dengshen start
      // wardHospitalCd = mstWard.getInHospitalCd_1() != null ? mstWard.getInHospitalCd_1().toString() : "";
      wardHospitalCd = mstWard != null && mstWard.getInHospitalCd_1() != null ? mstWard.getInHospitalCd_1().toString() : "";
      // mod #10735 患者情報を保存できない dengshen end
    }
    medicalCareInfoJson.put("ward_in_hospital_cd_1", wardHospitalCd);
    // 導入施設名
    // mod #10735 患者情報を保存できない dengshen start
    // CareInfoJson.put("facility_name", this.getCodeName(getMstNames, "sysFacilityNames", medicalCareInfoJson.get("facility_cd")));
    medicalCareInfoJson.put("facility_name", this.getCodeName(getMstNames, "sysFacilityNames", this.checkCodeStr(medicalCareInfoJson, "facility_cd")));
    // mod #10735 患者情報を保存できない dengshen end
    // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 start
//    patMainHistory.setMedical_care_info(medicalCareInfoJson.toString());
    MedicalCareInfo medicalCareInfos = mapper.readValue(medicalCareInfoJson.toString(), new TypeReference<MedicalCareInfo>() {});
    patMainHistory.setMedical_care_info(medicalCareInfos);
    // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 end
    List<WheelChairWithNameResponse> chair = mstWheelChairSerive.getWheelChairListByPatId(patId, patMainHistory.getFacility_cd());
    if(chair.size()>0){
      // 個人所有車いす割当あり
      patMainHistory.setWheel_chair_cd(chair.get(0).getWheelChairCd());
      patMainHistory.setWheel_chair_name(chair.get(0).getWheelChairName());
      patMainHistory.setWheel_chair_weight(chair.get(0).getWheelChairWeight());
    }else if(patMain.getWheel_chair_cd() != null){
      // 共用車いす割当あり
      WheelChairWithNameResponse sharingChair = mstWheelChairSerive.getWheelChair(patMain.getWheel_chair_cd(),null,null);
      if(sharingChair != null) {
        patMainHistory.setWheel_chair_cd(sharingChair.getWheelChairCd());
        patMainHistory.setWheel_chair_name(sharingChair.getWheelChairName());
        patMainHistory.setWheel_chair_weight(sharingChair.getWheelChairWeight());
      }
    }
    // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 start
    // 加算情報を取得する。
//    JSONArray additionInfoJson = this.getJSONArray(patMainHistory.getAddition_info());
    JSONArray additionInfoJson = this.getJSONArray(patMain.getAddition_info());
    // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 end
    // 加算情報
    for (int i = 0; i < additionInfoJson.length(); i++) {
      JSONObject jsonObj = additionInfoJson.getJSONObject(i);
      // 加算・管理料コード名称
      // mod #10735 患者情報を保存できない dengshen start
      // jsonObj.put("name", this.getCodeName(getMstNames, "additionNames", jsonObj.get("cd")));
      jsonObj.put("name", this.getCodeName(getMstNames, "additionNames", this.checkCodeStr(jsonObj, "cd")));
      // mod #10735 患者情報を保存できない dengshen end
      // 加算形式
      // mod #10735 患者情報を保存できない dengshen start
      // jsonObj.put("kind", this.getCodeName(getMstNames, "additionKinds", jsonObj.get("cd")));
      jsonObj.put("kind", this.getCodeName(getMstNames, "additionKinds", this.checkCodeStr(jsonObj, "cd")));
      // mod #10735 患者情報を保存できない dengshen end
      // 最終算定日
      // mod #10735 患者情報を保存できない dengshen start
      // jsonObj.put("last_date", this.getCodeName(getMstNames, "additionLastDates", jsonObj.get("cd")));
      jsonObj.put("last_date", this.getCodeName(getMstNames, "additionLastDates", this.checkCodeStr(jsonObj, "cd")));
      // mod #10735 患者情報を保存できない dengshen end
    }
    // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 start
//    patMainHistory.setAddition_info(additionInfoJson.toString());
    List<AdditionInfo> additionInfos = mapper.readValue(additionInfoJson.toString(), new TypeReference<List<AdditionInfo>>() {});
    patMainHistory.setAddition_info(additionInfos);

    // 既往歴情報を取得する。
//    JSONArray medicalHstInfoJson = this.getJSONArray(patUniqueHistory.getMedical_hst_info());
    JSONArray medicalHstInfoJson = this.getJSONArray(patUnique.getMedical_hst_info());
    // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 end
    String dialysisUnderlyingDisease = null;
    // 既往歴情報
    for(int i = 0; i < medicalHstInfoJson.length(); i++) {
      JSONObject jsonObj = medicalHstInfoJson.getJSONObject(i);
      // mod #10735 患者情報を保存できない dengshen start
      // if ("1".equals(jsonObj.get("is_dialysis_underlying_disease").toString())) dialysisUnderlyingDisease = this.getCodeName(getMstNames, "diseaseNames", jsonObj.get("disease_cd"));
      if (jsonObj.has("is_dialysis_underlying_disease") && "1".equals(jsonObj.get("is_dialysis_underlying_disease").toString())) dialysisUnderlyingDisease = this.getCodeName(getMstNames, "diseaseNames", this.checkCodeStr(jsonObj, "disease_cd"));
      // mod #10735 患者情報を保存できない dengshen end
    }
    patMainHistory.setDialysis_underlying_disease(dialysisUnderlyingDisease);

    try {
      if (MongoHealthCheckService.getMongoDBConnected()) {
        Query queryHistory = new Query();
        queryHistory.addCriteria(Criteria.where("pat_id").is(String.valueOf(patId)));
        queryHistory.addCriteria(Criteria.where("latest_flag").is("on"));
        List<PatMainHistory> patMainHistories = mongoTemplate.find(queryHistory, PatMainHistory.class);
        for (PatMainHistory patMainH : patMainHistories) {
          patMainHistory.setPat_group_info(patMainH.getPat_group_info());
          break;
        }

        Query query = new Query();
        Update update = new Update();
        query.addCriteria(Criteria.where("pat_id").is(String.valueOf(patId)));
        query.addCriteria(Criteria.where("latest_flag").ne("off"));
        update.set("latest_flag", "off");
        mongoTemplate.updateMulti(query, update, PatMainHistory.class);
        mongoTemplate.insert(patMainHistory);
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
  }
  // add #10436 同姓同名フラグの更新時に対になる患者のpat_main_historyがinsertされていない zhao end

    // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 start
  /**
   * @param patPersonalMain
   * @param patMain
   * @param patUnique
   * @return Map<String MstName, Map < String MstKey, String MstName>>
   */
//  public Map<String, Map<String, String>> getMstNames(PatPersonalMainHistory patPersonalMainHistory,
//                                                      PatMainHistory patMainHistory,
//                                                      PatUniqueHistory patUniqueHistory) {
  public Map<String, Map<String, String>> getMstNames(PatPersonalMain patPersonalMain,
                                                      PatMain patMain,
                                                      PatUnique patUnique) {

    // 共通診療情報を取得する。
//JSONObject medicalCareInfoJson = new JSONObject(patMainHistory.getMedical_care_info());
    JSONObject medicalCareInfoJson = new JSONObject(patMain.getMedical_care_info());

    // 既往歴情報を取得する。
//JSONArray medicalHstInfoJson = this.getJSONArray(patUniqueHistory.getMedical_hst_info());
    JSONArray medicalHstInfoJson = this.getJSONArray(patUnique.getMedical_hst_info());

    // 入外・転入出情報を取得する。
//JSONArray inoutVisitHistoryInfoJson = this.getJSONArray(patUniqueHistory.getIn_out_visit_history_info());
    JSONArray inoutVisitHistoryInfoJson = this.getJSONArray(patUnique.getIn_out_visit_history_info());

    // 身体情報を取得する。
//    JSONArray physicalInfoJson = this.getJSONArray(patUniqueHistory.getPhysical_info());
    JSONArray physicalInfoJson = this.getJSONArray(patUnique.getPhysical_info());

    // 感染症情報を取得する。
//    JSONArray infectInfoJson = this.getJSONArray(patMainHistory.getInfect_info());
    JSONArray infectInfoJson = this.getJSONArray(patMain.getInfect_info());

    // インプラント情報を取得する。
//    JSONArray implantInfoJson = this.getJSONArray(patMainHistory.getImplant_info());
    JSONArray implantInfoJson = this.getJSONArray(patMain.getImplant_info());

    // 担当スタッフ情報を取得する。
//    JSONArray chargeStaffInfoJson = this.getJSONArray(patMainHistory.getCharge_staff_info());
    JSONArray chargeStaffInfoJson = this.getJSONArray(patMain.getCharge_staff_info());

    // 透析困難情報を取得する。
//    JSONArray dialDiffComInfoJson = this.getJSONArray(patPersonalMainHistory.getDial_diff_com_info());
    JSONArray dialDiffComInfoJson = this.getJSONArray(patPersonalMain.getDial_diff_com_info());
    // add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe start
    // 加算
//    JSONArray additionInfoJson = this.getJSONArray(patMainHistory.getAddition_info());
    JSONArray additionInfoJson = this.getJSONArray(patMain.getAddition_info());
    // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 end
    // add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe end
    // 施設
    List<String> facilitys = new ArrayList<>();

    // 施設施設
    List<String> favoriteFacilitys = new ArrayList<>();

    // 病名マス
    List<Integer> diseases = new ArrayList<>();

    // 診療科
    List<Integer> courses = new ArrayList<>();

    // 感染症
    List<Integer> infections = new ArrayList<>();

    // インプラント
    List<Integer> implants = new ArrayList<>();

    // 病棟
    List<Integer> wards = new ArrayList<>();

    // 利用者
    List<Integer> personalUsers = new ArrayList<>();

    // 重症度
//    List<String> severitys = new ArrayList<>();
    List<Integer> severitys = new ArrayList<>();

    // 搬送区分
//    List<String> transports = new ArrayList<>();
    List<Integer> transports = new ArrayList<>();

    // 透析困難情報
    List<Integer> mstDialysisDifficulties = new ArrayList<>();
    // add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe start
    // 加算
    List<Integer> additions = new ArrayList<>();
    // add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe end
    // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 start
    // 登録施設名
//    facilitys.add(patPersonalMainHistory.getFacility_cd());
    facilitys.add(patPersonalMain.getFacility_cd());

    // 登録施設名
//    facilitys.add(patMainHistory.getFacility_cd());
    facilitys.add(patMain.getFacility_cd());
    // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 end

    // 導入施設名
    favoriteFacilitys.add(this.getCode(medicalCareInfoJson, "facility_cd", String.class));

    // 登録施設名
    facilitys.addAll(this.getJsonObjCodeStr(medicalHstInfoJson, "facility_cd"));

    // 施設施設名
    favoriteFacilitys.addAll(this.getJsonObjCodeStr(medicalHstInfoJson, "diagnosis_facility_cd"));

    // 登録施設名
    facilitys.addAll(this.getJsonObjCodeStr(inoutVisitHistoryInfoJson, "facility_cd"));

    // 施設名
    facilitys.addAll(this.getJsonObjCodeStr(physicalInfoJson, "facility_cd"));

    // 死因
    Integer dieCd = null;
    // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 start
//    if (patPersonalMainHistory.getDie_cd() != null && !"".equals(patPersonalMainHistory.getDie_cd())) {
    if (patPersonalMain.getDie_cd() != null && !"".equals(patPersonalMain.getDie_cd())) {
//      dieCd = Integer.valueOf(patPersonalMainHistory.getDie_cd());
      dieCd = Integer.valueOf(patPersonalMain.getDie_cd());
    }
    diseases.add(this.getCode(dieCd, Integer.class));

    // 原疾患
//    diseases.add(this.getCode(patPersonalMainHistory.getPrimary_disease_cd(), Integer.class));
    diseases.add(this.getCode(patPersonalMain.getPrimary_disease_cd(), Integer.class));
    // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 end

    // 病名マスタ.病名
    diseases.addAll(this.getJsonObjCodeInt(medicalHstInfoJson, "disease_cd"));

    // 主科名
    courses.add(this.getCode(medicalCareInfoJson, "main_course_cd", Integer.class));

    // 透析実施科名
    courses.add(this.getCode(medicalCareInfoJson, "dialysis_course_cd", Integer.class));

    // 診療科名
    courses.addAll(this.getJsonObjCodeInt(medicalHstInfoJson, "course_cd"));

    // 感染症名
    infections.addAll(this.getJsonObjCodeInt(infectInfoJson, "infection_cd"));

    // インプラント名
    implants.addAll(this.getJsonObjCodeInt(implantInfoJson, "implant_cd"));

    // 病棟名
    wards.add(this.getCode(medicalCareInfoJson, "ward_cd", Integer.class));

    // 指示者
    personalUsers.addAll(this.getJsonObjCodeInt(physicalInfoJson, "indicator_cd"));

    // スタッフ
    personalUsers.addAll(this.getJsonObjCodeInt(chargeStaffInfoJson, "staff_cd"));

    // 診断医名
    personalUsers.addAll(this.getJsonObjCodeInt(medicalHstInfoJson, "diagnostician_cd"));

    // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 start
    // 重症度名
//    severitys.add(this.getCode(patPersonalMainHistory.getSeverity_cd(), String.class));
    severitys.add(this.getCode(patPersonalMain.getSeverity_cd(), Integer.class));

    // 搬送区分
//    transports.add(this.getCode(patPersonalMainHistory.getTransport_cd(), String.class));
    transports.add(this.getCode(patPersonalMain.getTransport_cd(), Integer.class));
    // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 end

    // 透析困難名
    mstDialysisDifficulties.addAll(this.getJsonObjCodeInt(dialDiffComInfoJson, "dial_diff_cd"));

    // add #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen start
    if (inoutVisitHistoryInfoJson != null && inoutVisitHistoryInfoJson.length() != 0) {
      for (int i = 0; i < inoutVisitHistoryInfoJson.length(); i++) {
        String moveInOut = this.getCode(inoutVisitHistoryInfoJson.getJSONObject(i), "move_in_out", String.class);
        // 元施設
        String fromFacility = this.getCode(inoutVisitHistoryInfoJson.getJSONObject(i), "from_facility", String.class);
        // 先施設
        String toFacility = this.getCode(inoutVisitHistoryInfoJson.getJSONObject(i), "to_facility", String.class);

        switch (moveInOut) {
          case "3":
          case "4":
          case "5":
          case "9":
            // 元施設
            facilitys.add(fromFacility);
            // 先施設
            favoriteFacilitys.add(toFacility);
            break;
          case "1":
          case "2":
          case "6":
          case "7":
          case "8":
          case "10":
            // 元施設
            favoriteFacilitys.add(fromFacility);
            // 先施設
            facilitys.add(toFacility);
            break;
        }
      }
    }

    // 元科
    courses.addAll(this.getJsonObjCodeInt(inoutVisitHistoryInfoJson, "from_course"));

    // 元施設医
    personalUsers.addAll(this.getJsonObjCodeInt(inoutVisitHistoryInfoJson, "from_doctor"));

    // 元医療機関
    List<String> medicalInstitutionCds = new ArrayList<>();
    medicalInstitutionCds.addAll(this.getJsonObjCodeStr(inoutVisitHistoryInfoJson, "from_medicalInstitutionCd"));

    // 先科
    courses.addAll(this.getJsonObjCodeInt(inoutVisitHistoryInfoJson, "to_course"));

    // 先施設医
    personalUsers.addAll(this.getJsonObjCodeInt(inoutVisitHistoryInfoJson, "to_doctor"));

    // 先医療機関
    medicalInstitutionCds.addAll(this.getJsonObjCodeStr(inoutVisitHistoryInfoJson, "to_medicalInstitutionCd"));
    // add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe start
    //加算
    additions.addAll(this.getJsonObjCodeInt(additionInfoJson, "cd"));
    // add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe end
    // 全施設マスタ情報を取得する。→→→→→→　Map<String MedicalInstitutionCd, String FacilityName>
    Map<String, String> medicalInstitutionNames = new HashMap<>();
    medicalInstitutionCds = this.cleanStrLst(medicalInstitutionCds);
    if (diseases.size() > 0) {
      sysFacilityDao.selectAllName(medicalInstitutionCds).stream()
        .collect(Collectors.toMap(SysFacility::getMedicalInstitutionCd, SysFacility::getFacilityName))
        .forEach((key, value) -> medicalInstitutionNames.put(String.valueOf(key), value));
    }
    // add #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen end

    // 施設マスタ情報を取得する。→→→→→→　Map<String FacilityCd, String FacilityName>
    Map<String, String> facilityNames = mstFacilityDao.selectNamesByCd(this.cleanStrLst(facilitys)).stream()
      .collect(Collectors.toMap(MstFacility::getFacilityCd, MstFacility::getFacilityName));

    // 病名マスタ情報を取得する。→→→→→→　Map<String DiseaseCd, String DiseaseName>
    Map<String, String> diseaseNames = new HashMap<>();
    diseases = this.cleanIntLst(diseases);
    if (diseases.size() > 0) {
      mstDiseaseDao.selectAllName(diseases).stream()
        .collect(Collectors.toMap(MstDisease::getDiseaseCd, MstDisease::getDiseaseName))
        .forEach((key, value) -> diseaseNames.put(String.valueOf(key), value));
    }

    // 診療科マスタ情報を取得する。→→→→→→　Map<String CourseCd, String CourseName>
    Map<String, String> courseNames = new HashMap<String, String>();
    courses = this.cleanIntLst(courses);
    if (courses.size() > 0) {
      mstCourseDao.selectAllName(courses).stream()
        .collect(Collectors.toMap(MstCourse::getCourseCd, MstCourse::getCourseName))
        .forEach((key, value) -> courseNames.put(String.valueOf(key), value));
    }

    // 感染症マスタ情報を取得する。→→→→→→　Map<String InfectionCd, String InfectionName>
    Map<String, String> infectionNames = new HashMap<String, String>();
    infections = this.cleanIntLst(infections);
    if (infections.size() > 0) {
      mstInfectionDao.selectAllName(infections).stream()
        .collect(Collectors.toMap(MstInfection::getInfectionCd, MstInfection::getInfectionName))
        .forEach((key, value) -> infectionNames.put(String.valueOf(key), value));
    }

    // インプラント情報を取得する。→→→→→→　Map<String InfectionCd, String InfectionName>
    Map<String, String> implantNames = new HashMap<String, String>();
    implants = this.cleanIntLst(implants);
    if (implants.size() > 0) {
      mstImplantDao.selectAllName(implants).stream()
        .collect(Collectors.toMap(MstImplant::getImplantCd, MstImplant::getImplantName))
        .forEach((key, value) -> implantNames.put(String.valueOf(key), value));
    }

    // 病棟マスタ情報を取得する。→→→→→→　Map<String WardCd, String WardName>
    Map<String, String> wardNames = new HashMap<String, String>();
    wards = this.cleanIntLst(wards);
    if (wards.size() > 0) {
      mstWardDao.selectAllName(wards).stream()
        .collect(Collectors.toMap(MstWard::getWardCd, MstWard::getWardName))
        .forEach((key, value) -> wardNames.put(String.valueOf(key), value));
    }

    // 利用者マスタ情報を取得する。→→→→→→　Map<String UserId, String UserFirstName+UserLastName>
    Map<String, String> personalUserNames = new HashMap<>();
    personalUsers = this.cleanIntLst(personalUsers);
    if (personalUsers.size() > 0) {
      mstPersonalUserDao.selectAllName(personalUsers).stream()
        .collect(Collectors.toMap(MstPersonalUser::getUserId, MstPersonalUser::getUserName))
        .forEach((key, value) -> personalUserNames.put(String.valueOf(key), value));
    }

    // 重症度マスタ情報を取得する。→→→→→→　Map<String SeverityCd, String SeverityName>
    Map<String, String> severityNames = new HashMap<String, String>();
    List<Integer> severitysInt = new ArrayList<>();
    severitys.stream().distinct().filter(Objects::nonNull).collect(Collectors.toList())
      .forEach(item -> severitysInt.add(Integer.valueOf(item)));
    if (severitys.size() > 0) {
      mstSeverityDao.selectAllName(severitysInt).stream()
        .collect(Collectors.toMap(MstSeverity::getSeverityCd, MstSeverity::getSeverityName))
        .forEach((key, value) -> severityNames.put(String.valueOf(key), value));
    }

    // 搬送区分マスタ情報を取得する。→→→→→→　Map<String TransportCd, String TransportName>
    Map<String, String> transportNames = new HashMap<String, String>();
    List<Integer> transportsInt = new ArrayList<>();
    transports.stream().distinct().filter(Objects::nonNull).collect(Collectors.toList())
      .forEach(item -> transportsInt.add(Integer.valueOf(item)));
    if (transports.size() > 0) {
      mstTransportDao.selectAllName(transportsInt).stream()
        .collect(Collectors.toMap(MstTransport::getTransportCd, MstTransport::getTransportName))
        .forEach((key, value) -> transportNames.put(String.valueOf(key), value));
    }

    // 透析困難情報を取得する。→→→→→→　Map<String TransportCd, String TransportName>
    Map<String, String> mstDialysisDifficultyNames = new HashMap<String, String>();
    mstDialysisDifficulties = this.cleanIntLst(mstDialysisDifficulties);
    if (mstDialysisDifficulties.size() > 0) {
      mstDialysisDifficultyDao.selectAllName(mstDialysisDifficulties).stream()
        .collect(Collectors.toMap(MstDialysisDifficulty::getDialysisDifficultyCd, MstDialysisDifficulty::getDialysisDifficultyName))
        .forEach((key, value) -> mstDialysisDifficultyNames.put(String.valueOf(key), value));
    }

    // 施設施設を取得する。→→→→→→　Map<String MedicalInstitutionCd, String MedicalInstitutionName>
    Map<String, String> sysFacilityNames = new HashMap<String, String>();
    favoriteFacilitys = this.cleanStrLst(favoriteFacilitys);
    if (favoriteFacilitys.size() > 0) {
      mstFavoriteFacilityDao.selectAllName(favoriteFacilitys).stream()
        .collect(Collectors.toMap(MstFavoriteFacilityData::getMedicalInstitutionCd, MstFavoriteFacilityData::getFavoriteFacilityName))
        .forEach((key, value) -> sysFacilityNames.put(key, value));
    }
    // add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe start
    // 加算マスタ情報を取得する。→→→→→→　Map<String AdditionCd, String AdditionName>
    Map<String, String> additionNames = new HashMap<String, String>();
    Map<String, String> additionKinds = new HashMap<String, String>();
    Map<String, String> additionLastDates = new HashMap<String, String>();
    additions = this.cleanIntLst(additions);
    if (additions.size() > 0) {
      mstAdditionDao.selectAllName(additions).stream()
        .collect(Collectors.toMap(MstAddition::getAdditionCd, MstAddition::getAdditionName))
        .forEach((key, value) -> additionNames.put(String.valueOf(key), value));
      mstAdditionDao.selectAllName(additions).stream()
        .collect(Collectors.toMap(MstAddition::getAdditionCd, MstAddition::getAdditionKind))
        .forEach((key, value) -> additionKinds.put(String.valueOf(key), value));
      String date = null;
      // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 start
//      ordMainDao.selectCalculationDateList(null, patMainHistory.getFacility_cd(), Long.parseLong(patMainHistory.getPat_id()), date).stream()
      ordMainDao.selectCalculationDateList(null, patMain.getFacility_cd(), patMain.getPat_id(), date).stream()
        .collect(Collectors.toMap(AdditionInfoOrdMain::getCd, AdditionInfoOrdMain::getLast_date))
        .forEach((key, value) -> additionLastDates.put(String.valueOf(key), value));
      // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 end
    }
    // add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe end
    Map<String, Map<String, String>> names = new HashMap<>();
    names.put("facilityNames", facilityNames);
    names.put("diseaseNames", diseaseNames);
    names.put("courseNames", courseNames);
    names.put("infectionNames", infectionNames);
    names.put("implantNames", implantNames);
    names.put("wardNames", wardNames);
    names.put("personalUserNames", personalUserNames);
    names.put("severityNames", severityNames);
    names.put("transportNames", transportNames);
    names.put("mstDialysisDifficultyNames", mstDialysisDifficultyNames);
    names.put("sysFacilityNames", sysFacilityNames);

    // add #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen start
    names.put("medicalInstitutionNames", medicalInstitutionNames);
    // add #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen end
    // add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe start
    names.put("additionNames", additionNames);
    names.put("additionKinds", additionKinds);
    names.put("additionLastDates", additionLastDates);
    // add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe end
    return names;
  }

  public String getCodeName(Map<String, Map<String, String>> codeMap, String mstName, Object code) {
    String name = "";
    String codeStr = code != null ? code.toString() : "";
    if (codeMap.get(mstName).get(codeStr) != null) {
      name = codeMap.get(mstName).get(codeStr);
    }
    return name;
  }
  // add #10735 患者情報を保存できない dengshen start
  public String checkCodeStr(JSONObject codeList, String codeName) {
    Object code = codeList.has(codeName) ? codeList.get(codeName) : "";
    return code != null ? code.toString() : "";
  }
  // add #10735 患者情報を保存できない dengshen end

  public JSONArray getJSONArray(String json) {
    JSONArray jsonArray = new JSONArray();
    if (json != null) {
      jsonArray = new JSONArray(json);
    }
    return jsonArray;
  }

  public <T> T getCode(Object code, Class<T> clazz) {
    if (code == null) {
      return null;
    } else if (Integer.class.equals(clazz)) {
      return clazz.cast((Integer) code);
    } else if (String.class.equals(clazz)) {
      return clazz.cast((String) code);
    } else {
      return null;
    }
  }

  public <T> T getCode(JSONObject obj, String code, Class<T> clazz) {
    // add #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen start
    try {
      // add #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen end
      // mod #10735 患者情報を保存できない dengshen start
      // Object value = obj.get(code);
      Object value = obj.has(code) ? obj.get(code) : "";
      // mod #10735 患者情報を保存できない dengshen end
      if (value == null || value.equals(null)) {
        return null;
      } else if (Integer.class.equals(clazz)) {
        return clazz.cast((Integer) value);
      } else if (String.class.equals(clazz)) {
        return clazz.cast((String) value);
      } else {
        return null;
      }
      // add #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen start
    } catch (Exception e) {
      return null;
    }
    // add #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen end
  }

  public List<String> getJsonObjCodeStr(JSONArray jsonArray, String code) {
    List<String> codeValue = new ArrayList<>();
    if (jsonArray != null && jsonArray.length() != 0) {
      for (int i = 0; i < jsonArray.length(); i++) {
        codeValue.add(this.getCode(jsonArray.getJSONObject(i), code, String.class));
      }
    }
    return codeValue;
  }

  public static List<Integer> getJsonObjCodeInt(JSONArray jsonArray, String code) {
    List<Integer> codeValue = new ArrayList<>();
    if (jsonArray != null && !jsonArray.isEmpty()) {
      for (int i = 0; i < jsonArray.length(); i++) {
        JSONObject jsonObject = jsonArray.getJSONObject(i);
        // mod #10735 患者情報を保存できない dengshen start
        // Object value = jsonObject.get(code);
        Object value = jsonObject.has(code) ? jsonObject.get(code) : "";
        // mod #10735 患者情報を保存できない dengshen end
        if (value instanceof String) {
          String valueStr = (String) value;
          if (StringUtils.hasText(valueStr)) {
            if (valueStr.matches("\\d+")) {
              codeValue.add(Integer.valueOf(valueStr));
            }
          }
        } else if (value instanceof Integer) {
          codeValue.add((Integer) value);
        }
      }
    }
    return codeValue;
  }

  public List<String> cleanStrLst(List<String> lst) {
    return lst.stream().distinct().filter(Objects::nonNull).collect(Collectors.toList());
  }

  public List<Integer> cleanIntLst(List<Integer> lst) {
    return lst.stream().distinct().filter(Objects::nonNull).collect(Collectors.toList());
  }

  // add #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen end
// //  nkk-外部結合テストNo.80 姜 start
  public List<PatUnique> selectPatInfoById(Long pat_id) throws Exception {
    List<PatUnique> listPatUnique = patUniqueDao.selectPatInfoById(pat_id);
    return listPatUnique;
  }
// //  nkk-外部結合テストNo.80 姜 end

  public void inputCdCheck(JSONObject jsonObj, String cd, String name, Map<String, Map<String, String>> getMstNames, String mstName, String changeKbn) {
    if (!jsonObj.has(cd) || "null".equals(jsonObj.get(cd))) {
      jsonObj.put(name, "");
    } else {
      if ("1".equals(changeKbn)) {
        jsonObj.put(name, jsonObj.get(cd));
      } else {
        jsonObj.put(name, this.getCodeName(getMstNames, mstName, jsonObj.get(cd)));
      }
    }
  }

  @Transactional
  public void updateBulkUpdatePatInsu(List<PatInsuInfo> patInsuInfos) throws Exception {
    for (PatInsuInfo patInsuInfo : patInsuInfos) {
      //del 10532 mongoDBがダウン中の操作について（新患登録） xuehongda start
//      PatInsurance patInsuranceHaiTa = patInsuranceDao.selectById(patInsuInfo.getInsurance_cd());
//      if (patInsuInfo.getOld_up_date() != null && patInsuranceHaiTa != null) {
//        if (!patInsuInfo.getOld_up_date().equals(patInsuranceHaiTa.getOld_up_date())) {
//          throw new OptimisticLockException(SqlLogType.NONE, SqlKind.UPDATE, "", "", "");
//        }
//      } else if (patInsuInfo.getOld_up_date() != null && patInsuranceHaiTa == null) {
//        throw new OptimisticLockException(SqlLogType.NONE, SqlKind.UPDATE, "", "", "");
//      }
//      //  add 10525 保険区分が「セット」のときクラス「処方情報」が出力できない 関  start
//      // 保険情報
//      if (patInsuInfo.getInsu_class().equals(0)) {
//        patInsuInfo.setInsu_pub_info(null);
//        patInsuInfo.setInsu_set_info(null);
//        patInsuInfo.setInsu_self_info(null);
//        // 公費情報
//      }else if(patInsuInfo.getInsu_class().equals(1)) {
//        patInsuInfo.setInsu_info(null);
//        patInsuInfo.setInsu_set_info(null);
//        patInsuInfo.setInsu_self_info(null);
//        // セット情報
//      }else if(patInsuInfo.getInsu_class().equals(2)) {
//        patInsuInfo.setInsu_info(null);
//        patInsuInfo.setInsu_self_info(null);
//        patInsuInfo.setInsu_pub_info(null);
//        // 自費情報
//      }else if (patInsuInfo.getInsu_class().equals(3)) {
//        patInsuInfo.setInsu_info(null);
//        patInsuInfo.setInsu_set_info(null);
//        patInsuInfo.setInsu_pub_info(null);
//      }
//      //  add 10525 保険区分が「セット」のときクラス「処方情報」が出力できない 関  end
//      if ("0".equals(patInsuInfo.getIs_del())) {
//        patInsuranceDao.updateById(patInsuInfo);
//      } else {
//        patInsuranceDao.updateByIdDel(patInsuInfo);
//      }
      //del 10532 mongoDBがダウン中の操作について（新患登録） xuehongda end
      if (mongoTemplate != null) {
        //add #10532 mongoDBがダウン中の操作について（新患登録） limingzhe start
        try {
          if (MongoHealthCheckService.getMongoDBConnected()) {
        //add #10532 mongoDBがダウン中の操作について（新患登録） limingzhe end
            PatInsurance insuInfo = patInsuranceDao.selectByCd(patInsuInfo.getInsurance_cd());
            if(insuInfo == null) return;
            Timestamp now = new Timestamp(new Date().getTime());
            PatInsuranceHistory patInsuranceHistory = new PatInsuranceHistory();
            BeanUtils.copyProperties(insuInfo, patInsuranceHistory);
            patInsuranceHistory.setIns_date(now);
            String pat_idR = patInsuInfo.getPat_id().toString();
            patInsuranceHistory.setPat_id(pat_idR);
            LocalDateTime currentTime = LocalDateTime.now();
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss.SSS");
            //del 10510 システム時間更新　杜start
//            if ("0".equals(patInsuInfo.getIs_del())) {
//              patInsuranceHistory.setUp_date(patInsuInfo.getUp_date());
//            } else {
              //  mod 10525 保険区分が「セット」のときクラス「処方情報」が出力できない 崔  start
              //  patInsuranceHistory.setUp_date(currentTime.minusSeconds(2).format(formatter));
              patInsuranceHistory.setUp_date(currentTime.format(formatter));
              //  mod 10525 保険区分が「セット」のときクラス「処方情報」が出力できない 崔  end
//            }
            //del 10510 システム時間更新　杜end
            if (insuInfo.getInsurance_cd() != null) {
              patInsuranceHistory.setInsurance_cd(insuInfo.getInsurance_cd().toString());
            }
            if (insuInfo.getCtl_no() != null) {
              patInsuranceHistory.setCtl_no(insuInfo.getCtl_no().toString());
            }
            // セット情報
            JSONObject insuSetInfoJson = new JSONObject(patInsuranceHistory.getInsu_set_info());
            //  mod 10525 保険区分が「セット」のときクラス「処方情報」が出力できない 関  start

            // 保険区分を切り替えるmongoDB挿入削除データ
            Query queryHistory = new Query();
            queryHistory.addCriteria(Criteria.where("pat_id").is(String.valueOf(patInsuInfo.getPat_id())));
            queryHistory.addCriteria(Criteria.where("facility_cd").is(patInsuInfo.getFacility_cd()));
            List<PatInsuranceHistory> patInsuranceHistories = mongoTemplate.find(queryHistory.with(Sort.by(Sort.Order.desc("up_date"))), PatInsuranceHistory.class);

            Long insuranceCd = patInsuInfo.getInsurance_cd();
            Integer inClass = patInsuInfo.getInsu_class();
            PatInsuranceHistory deleteRelatedSet = patInsuranceHistories.stream()
              .filter(data -> data.getInsurance_cd().equals(insuranceCd.toString()) && !data.getInsu_class().equals(inClass))
              .findFirst().orElse(null);

            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            Timestamp nowTimestamp = new Timestamp(new Date().getTime());
            String strDate = sdf.format(nowTimestamp);

            List<Long> patIdList = new ArrayList<Long>();
            patIdList.add(patInsuInfo.getPat_id());
            List<PatInsurance> patInsurances = patInsuranceDao.selectByIdListFacilityCd(patIdList, patInsuInfo.getFacility_cd());

            if (deleteRelatedSet != null && deleteRelatedSet.getIs_del().equals("0")) {
              PatInsuranceHistory patInsuranceHistoryUpdate = new PatInsuranceHistory();
              BeanUtils.copyProperties(deleteRelatedSet, patInsuranceHistoryUpdate);
              patInsuranceHistoryUpdate.set_id(null);
              patInsuranceHistoryUpdate.setUp_date(strDate);
              patInsuranceHistoryUpdate.setReg_date(strDate);
              patInsuranceHistoryUpdate.setIns_date(nowTimestamp);
              patInsuranceHistoryUpdate.setIs_del("1");

              mongoTemplate.insert(patInsuranceHistoryUpdate);
            }

            // 保険区分変更以外のmongoDB挿入
            JSONArray insuSetInfo = new JSONArray();
            // 保険名
            String insuCd = "";
            // mod #10735 患者情報を保存できない dengshen start
            // if (insuSetInfoJson.get("insu_cd") != null && !insuSetInfoJson.get("insu_cd").toString().isEmpty() && !"null".equals(insuSetInfoJson.get("insu_cd").toString())) {
            if (insuSetInfoJson.has("insu_cd")  && insuSetInfoJson.get("insu_cd") != null && !insuSetInfoJson.get("insu_cd").toString().isEmpty() && !"null".equals(insuSetInfoJson.get("insu_cd").toString())) {
            // mod #10735 患者情報を保存できない dengshen end
              PatInsurance insuInfo1 = patInsuranceDao.selectByCd(Long.parseLong(String.valueOf(insuSetInfoJson.get("insu_cd"))));
              // add #10735 患者情報を保存できない dengshen start
              if (insuInfo1 != null) {
              // add #10735 患者情報を保存できない dengshen end
                insuCd = insuInfo1.getInsu_name() != null ? insuInfo1.getInsu_name() : "";
                //mod #10510 Number→Staring 杜 start
                //Long insuCode = insuInfo1.getInsurance_cd() != null ? insuInfo1.getInsurance_cd(): null;
                String insuCode = insuInfo1.getInsurance_cd() != null ? insuInfo1.getInsurance_cd().toString() : null;
                String insuInfoName = insuInfo1.getInsu_name() != null ? insuInfo1.getInsu_name() : null;
                //Integer insuClass = insuInfo1.getInsu_class() != null ? insuInfo1.getInsu_class() : null;
                String insuClass = insuInfo1.getInsu_class() != null ? insuInfo1.getInsu_class().toString() : null;
                //mod #10510 Number→Staring 杜 end
                String insuNameShort = insuInfo1.getInsu_name_short() != null ? insuInfo1.getInsu_name_short() : null;

                if (insuInfo.getInsu_class().equals(2)) {
                  JSONObject insuInfoJson = new JSONObject(insuInfo1.getInsu_info());
                  insuInfoJson.put("insu_cd", insuCode != null && !insuCode.equals("null") ? insuCode : JSONObject.NULL);
                  insuInfoJson.put("insu_info_name", insuInfoName != null && !insuInfoName.equals("null") ? insuInfoName : JSONObject.NULL);
                  insuInfoJson.put("insu_info_name_short", insuNameShort != null && !insuNameShort.equals("null") ? insuNameShort : JSONObject.NULL);
                  insuInfoJson.put("insu_class", insuClass != null && !insuClass.equals("null") ? insuClass : JSONObject.NULL);

                  insuSetInfo.put(insuInfoJson);
                }
              // add #10735 患者情報を保存できない dengshen start
              }
              // add #10735 患者情報を保存できない dengshen end
            }
            // 保険情報.公費1
            String insuPub1Cd = "";
            // mod #10735 患者情報を保存できない dengshen start
            // if (!StringUtils.isEmpty(insuSetInfoJson.get("insu_pub1_cd").toString()) && !"null".equals(insuSetInfoJson.get("insu_pub1_cd").toString())) {
            if (insuSetInfoJson.has("insu_pub1_cd") && !StringUtils.isEmpty(insuSetInfoJson.get("insu_pub1_cd").toString()) && !"null".equals(insuSetInfoJson.get("insu_pub1_cd").toString())) {
            // mod #10735 患者情報を保存できない dengshen end
              PatInsurance insuInfo1 = patInsuranceDao.selectByCd(Long.parseLong(String.valueOf(insuSetInfoJson.get("insu_pub1_cd").toString())));
              // add #10735 患者情報を保存できない dengshen start
              if (insuInfo1 != null) {
              // add #10735 患者情報を保存できない dengshen end
              insuPub1Cd = insuInfo1.getInsu_name() != null ? insuInfo1.getInsu_name() : "";
              //mod #10510 Number→Staring 杜 start
              //Long insuCode = insuInfo1.getInsurance_cd() != null ? insuInfo1.getInsurance_cd() : null;
              String insuCode = insuInfo1.getInsurance_cd() != null ? insuInfo1.getInsurance_cd().toString() : null;
              String insuInfoName = insuInfo1.getInsu_name() != null ? insuInfo1.getInsu_name() : null;
              //Integer insuClass = insuInfo1.getInsu_class() != null ? insuInfo1.getInsu_class() : null;
              String insuClass = insuInfo1.getInsu_class() != null ? insuInfo1.getInsu_class().toString() : null;
              //mod #10510 Number→Staring 杜 end
              String insuNameShort = insuInfo1.getInsu_name_short() != null ? insuInfo1.getInsu_name_short() : null;

              if(insuInfo.getInsu_class().equals(2)) {
                JSONObject insuPubInfoJson = new JSONObject(insuInfo1.getInsu_pub_info());
                // mod #10735 患者情報を保存できない dengshen start
                // String insuPub1Name = insuPubInfoJson.get("insu_pub_name") != null && !insuPubInfoJson.get("insu_pub_name").equals("null") ? insuPubInfoJson.get("insu_pub_name") .toString() : null;
                // String insuPubNo = insuPubInfoJson.get("insu_pub_no") != null && !insuPubInfoJson.get("insu_pub_no").equals("null") ? insuPubInfoJson.get("insu_pub_no").toString() : null;
                // String insuPubPatNo = insuPubInfoJson.get("insu_pub_pat_no") != null && !insuPubInfoJson.get("insu_pub_pat_no").equals("null") ? insuPubInfoJson.get("insu_pub_pat_no").toString() : null;
                String insuPub1Name = insuPubInfoJson.has("insu_pub_name") && insuPubInfoJson.get("insu_pub_name") != null && !insuPubInfoJson.get("insu_pub_name").equals("null") ? insuPubInfoJson.get("insu_pub_name") .toString() : null;
                String insuPubNo = insuPubInfoJson.has("insu_pub_no") && insuPubInfoJson.get("insu_pub_no") != null && !insuPubInfoJson.get("insu_pub_no").equals("null") ? insuPubInfoJson.get("insu_pub_no").toString() : null;
                String insuPubPatNo = insuPubInfoJson.has("insu_pub_pat_no") && insuPubInfoJson.get("insu_pub_pat_no") != null && !insuPubInfoJson.get("insu_pub_pat_no").equals("null") ? insuPubInfoJson.get("insu_pub_pat_no").toString() : null;
                // mod #10735 患者情報を保存できない dengshen end
                insuPubInfoJson.put("insu_pub1_cd", insuCode != null && !insuCode.equals("null") ? insuCode : JSONObject.NULL);
                insuPubInfoJson.put("insu_pub1_info_name", insuInfoName != null && !insuInfoName.equals("null") ? insuInfoName : JSONObject.NULL);
                insuPubInfoJson.put("insu_pub1_info_name_short", insuNameShort != null && !insuNameShort.equals("null") ? insuNameShort : JSONObject.NULL);
                insuPubInfoJson.put("insu_class", insuClass != null && !insuClass.equals("null") ? insuClass : JSONObject.NULL);
                insuPubInfoJson.put("insu_pub1_name", insuPub1Name != null && !insuPub1Name.equals("null") ? insuPub1Name : JSONObject.NULL);
                insuPubInfoJson.put("insu_pub1_no", insuPubNo != null && !insuPubNo.equals("null") ? insuPubNo : JSONObject.NULL);
                insuPubInfoJson.put("insu_pub1_pat_no",insuPubPatNo != null && !insuPubPatNo.equals("null")? insuPubPatNo : JSONObject.NULL);
                //add #10510 「障害者手帳番号1」拡張 杜天成　start
                // mod #10735 患者情報を保存できない dengshen start
                // insuPubInfoJson.put("insu_pub1_passbook_no",insuPubInfoJson.get("passbook_no") != null && !insuPubInfoJson.get("passbook_no").equals("null")? insuPubInfoJson.get("passbook_no") : JSONObject.NULL);
                insuPubInfoJson.put("insu_pub1_passbook_no",insuPubInfoJson.has("passbook_no") && insuPubInfoJson.get("passbook_no") != null && !insuPubInfoJson.get("passbook_no").equals("null")? insuPubInfoJson.get("passbook_no") : JSONObject.NULL);
                // mod #10735 患者情報を保存できない dengshen end
                insuPubInfoJson.remove("passbook_no");
                //add #10510 「障害者手帳番号1」拡張 杜天成　end
                insuPubInfoJson.remove("insu_pub_name");
                insuPubInfoJson.remove("insu_pub_no");
                insuPubInfoJson.remove("insu_pub_pat_no");

                insuSetInfo.put(insuPubInfoJson);
              }
              // add #10735 患者情報を保存できない dengshen start
              }
              // add #10735 患者情報を保存できない dengshen end
            }
            // 保険情報.公費2
            String insuPub2Cd = "";
            // mod #10735 患者情報を保存できない dengshen start
            // if (!StringUtils.isEmpty(insuSetInfoJson.get("insu_pub2_cd").toString()) && !"null".equals(insuSetInfoJson.get("insu_pub2_cd").toString())) {
            if (insuSetInfoJson.has("insu_pub2_cd") && !StringUtils.isEmpty(insuSetInfoJson.get("insu_pub2_cd").toString()) && !"null".equals(insuSetInfoJson.get("insu_pub2_cd").toString())) {
            // mod #10735 患者情報を保存できない dengshen end
              PatInsurance insuInfo1 = patInsuranceDao.selectByCd(Long.parseLong(String.valueOf(insuSetInfoJson.get("insu_pub2_cd").toString())));
              // add #10735 患者情報を保存できない dengshen start
              if (insuInfo1 != null) {
              // add #10735 患者情報を保存できない dengshen end
              insuPub2Cd = insuInfo1.getInsu_name() != null ? insuInfo1.getInsu_name() : "";
              //mod #10510 Number→Staring 杜 start
              //Long insuCode = insuInfo1.getInsurance_cd() != null ? insuInfo1.getInsurance_cd() : null;
              String insuCode = insuInfo1.getInsurance_cd() != null ? insuInfo1.getInsurance_cd().toString() : null;
              String insuInfoName = insuInfo1.getInsu_name() != null ? insuInfo1.getInsu_name() : null;
              //Integer insuClass = insuInfo1.getInsu_class() != null ? insuInfo1.getInsu_class() : null;
              String insuClass = insuInfo1.getInsu_class() != null ? insuInfo1.getInsu_class().toString() : null;
              //mod #10510 Number→Staring 杜 end
              String insuNameShort = insuInfo1.getInsu_name_short() != null ? insuInfo1.getInsu_name_short() : null;
              if(insuInfo.getInsu_class().equals(2)) {
                JSONObject insuPubInfoJson = new JSONObject(insuInfo1.getInsu_pub_info());
                // mod #10735 患者情報を保存できない dengshen start
                // String insuPub1Name = insuPubInfoJson.get("insu_pub_name") != null && !insuPubInfoJson.get("insu_pub_name").equals("null") ? insuPubInfoJson.get("insu_pub_name").toString() : null;
                // String insuPubNo = insuPubInfoJson.get("insu_pub_no") != null && !insuPubInfoJson.get("insu_pub_no").equals("null") ? insuPubInfoJson.get("insu_pub_no").toString() : null;
                // String insuPubPatNo = insuPubInfoJson.get("insu_pub_pat_no") != null && !insuPubInfoJson.get("insu_pub_pat_no").equals("null") ? insuPubInfoJson.get("insu_pub_pat_no").toString() : null;
                String insuPub1Name = insuPubInfoJson.has("insu_pub_name") && insuPubInfoJson.get("insu_pub_name") != null && !insuPubInfoJson.get("insu_pub_name").equals("null") ? insuPubInfoJson.get("insu_pub_name").toString() : null;
                String insuPubNo = insuPubInfoJson.has("insu_pub_no") && insuPubInfoJson.get("insu_pub_no") != null && !insuPubInfoJson.get("insu_pub_no").equals("null") ? insuPubInfoJson.get("insu_pub_no").toString() : null;
                String insuPubPatNo = insuPubInfoJson.has("insu_pub_pat_no") && insuPubInfoJson.get("insu_pub_pat_no") != null && !insuPubInfoJson.get("insu_pub_pat_no").equals("null") ? insuPubInfoJson.get("insu_pub_pat_no").toString() : null;
                // mod #10735 患者情報を保存できない dengshen end

                insuPubInfoJson.put("insu_pub2_cd", insuCode != null && !insuCode.equals("null") ? insuCode : JSONObject.NULL);
                insuPubInfoJson.put("insu_pub2_info_name", insuInfoName != null && !insuInfoName.equals("null") ? insuInfoName : JSONObject.NULL);
                insuPubInfoJson.put("insu_pub2_info_name_short", insuNameShort != null && !insuNameShort.equals("null") ? insuNameShort : JSONObject.NULL);
                insuPubInfoJson.put("insu_class", insuClass != null && !insuClass.equals("null") ? insuClass : JSONObject.NULL);
                insuPubInfoJson.put("insu_pub2_name", insuPub1Name != null && !insuPub1Name.equals("null") ? insuPub1Name : JSONObject.NULL);
                insuPubInfoJson.put("insu_pub2_no", insuPubNo != null && !insuPubNo.equals("null") ? insuPubNo : JSONObject.NULL);
                insuPubInfoJson.put("insu_pub2_pat_no",insuPubPatNo != null && !insuPubPatNo.equals("null") ? insuPubPatNo : JSONObject.NULL);
                //add #10510 「障害者手帳番号2」拡張 杜天成　start
                // mod #10735 患者情報を保存できない dengshen start
                // insuPubInfoJson.put("insu_pub2_passbook_no",insuPubInfoJson.get("passbook_no") != null && !insuPubInfoJson.get("passbook_no").equals("null")? insuPubInfoJson.get("passbook_no") : JSONObject.NULL);
                insuPubInfoJson.put("insu_pub2_passbook_no",insuPubInfoJson.has("passbook_no") && insuPubInfoJson.get("passbook_no") != null && !insuPubInfoJson.get("passbook_no").equals("null")? insuPubInfoJson.get("passbook_no") : JSONObject.NULL);
                // mod #10735 患者情報を保存できない dengshen end
                insuPubInfoJson.remove("passbook_no");
                //add #10510 「障害者手帳番号2」拡張 杜天成　end
                insuPubInfoJson.remove("insu_pub_name");
                insuPubInfoJson.remove("insu_pub_no");
                insuPubInfoJson.remove("insu_pub_pat_no");

                insuSetInfo.put(insuPubInfoJson);
              }
              // add #10735 患者情報を保存できない dengshen start
              }
              // add #10735 患者情報を保存できない dengshen end
            }
            // 保険情報.公費3
            String insuPub3Cd = "";
            // mod #10735 患者情報を保存できない dengshen start
            // if (!StringUtils.isEmpty(insuSetInfoJson.get("insu_pub3_cd").toString()) && !"null".equals(insuSetInfoJson.get("insu_pub3_cd").toString())) {
            if (insuSetInfoJson.has("insu_pub3_cd") && !StringUtils.isEmpty(insuSetInfoJson.get("insu_pub3_cd").toString()) && !"null".equals(insuSetInfoJson.get("insu_pub3_cd").toString())) {
            // mod #10735 患者情報を保存できない dengshen end
              PatInsurance insuInfo1 = patInsuranceDao.selectByCd(Long.parseLong(String.valueOf(insuSetInfoJson.get("insu_pub3_cd").toString())));
              // add #10735 患者情報を保存できない dengshen start
              if (insuInfo1 != null) {
              // add #10735 患者情報を保存できない dengshen end
              insuPub3Cd = insuInfo1.getInsu_name() != null ? insuInfo1.getInsu_name() : "";
              //mod #10510 Number→Staring 杜 start
              //Long insuCode = insuInfo1.getInsurance_cd() != null ? insuInfo1.getInsurance_cd() : null;
              String insuCode = insuInfo1.getInsurance_cd() != null ? insuInfo1.getInsurance_cd().toString() : null;
              String insuInfoName = insuInfo1.getInsu_name() != null ? insuInfo1.getInsu_name() : null;
              //Integer insuClass = insuInfo1.getInsu_class() != null ? insuInfo1.getInsu_class() : null;
              String insuClass = insuInfo1.getInsu_class() != null ? insuInfo1.getInsu_class().toString() : null;
              //mod #10510 Number→Staring 杜 end
              String insuNameShort = insuInfo1.getInsu_name_short() != null ? insuInfo1.getInsu_name_short() : null;
              if(insuInfo.getInsu_class().equals(2)) {
                JSONObject insuPubInfoJson = new JSONObject(insuInfo1.getInsu_pub_info());
                // mod #10735 患者情報を保存できない dengshen start
                // String insuPub1Name = insuPubInfoJson.get("insu_pub_name") != null && !insuPubInfoJson.get("insu_pub_name").equals("null") ? insuPubInfoJson.get("insu_pub_name").toString() : null;
                // String insuPubNo = insuPubInfoJson.get("insu_pub_no") != null && !insuPubInfoJson.get("insu_pub_no").equals("null") ? insuPubInfoJson.get("insu_pub_no").toString() : null;
                // String insuPubPatNo = insuPubInfoJson.get("insu_pub_pat_no") != null && !insuPubInfoJson.get("insu_pub_pat_no").equals("null")  ? insuPubInfoJson.get("insu_pub_pat_no").toString() : null;
                String insuPub1Name = insuPubInfoJson.has("insu_pub_name") && insuPubInfoJson.get("insu_pub_name") != null && !insuPubInfoJson.get("insu_pub_name").equals("null") ? insuPubInfoJson.get("insu_pub_name").toString() : null;
                String insuPubNo = insuPubInfoJson.has("insu_pub_no") && insuPubInfoJson.get("insu_pub_no") != null && !insuPubInfoJson.get("insu_pub_no").equals("null") ? insuPubInfoJson.get("insu_pub_no").toString() : null;
                String insuPubPatNo = insuPubInfoJson.has("insu_pub_pat_no") && insuPubInfoJson.get("insu_pub_pat_no") != null && !insuPubInfoJson.get("insu_pub_pat_no").equals("null")  ? insuPubInfoJson.get("insu_pub_pat_no").toString() : null;
                // mod #10735 患者情報を保存できない dengshen end

                insuPubInfoJson.put("insu_pub3_cd", insuCode != null && !insuCode.equals("null") ? insuCode : JSONObject.NULL);
                insuPubInfoJson.put("insu_pub3_info_name", insuInfoName != null && !insuInfoName.equals("null") ? insuInfoName : JSONObject.NULL);
                insuPubInfoJson.put("insu_pub3_info_name_short", insuNameShort != null && !insuNameShort.equals("null") ? insuNameShort : JSONObject.NULL);
                insuPubInfoJson.put("insu_class", insuClass != null && !insuClass.equals("null") ? insuClass : JSONObject.NULL);
                insuPubInfoJson.put("insu_pub3_name", insuPub1Name != null && !insuPub1Name.equals("null") ? insuPub1Name : JSONObject.NULL);
                insuPubInfoJson.put("insu_pub3_no", insuPubNo != null && !insuPubNo.equals("null") ? insuPubNo : JSONObject.NULL);
                insuPubInfoJson.put("insu_pub3_pat_no",insuPubPatNo != null && !insuPubPatNo.equals("null") ? insuPubPatNo : JSONObject.NULL);
                //add #10510 「障害者手帳番号3」拡張 杜天成　start
                // mod #10735 患者情報を保存できない dengshen start
                // insuPubInfoJson.put("insu_pub3_passbook_no",insuPubInfoJson.get("passbook_no") != null && !insuPubInfoJson.get("passbook_no").equals("null")? insuPubInfoJson.get("passbook_no") : JSONObject.NULL);
                insuPubInfoJson.put("insu_pub3_passbook_no", insuPubInfoJson.has("passbook_no") && insuPubInfoJson.get("passbook_no") != null && !insuPubInfoJson.get("passbook_no").equals("null")? insuPubInfoJson.get("passbook_no") : JSONObject.NULL);
                // mod #10735 患者情報を保存できない dengshen end
                insuPubInfoJson.remove("passbook_no");
                //add #10510 「障害者手帳番号3」拡張 杜天成　end
                insuPubInfoJson.remove("insu_pub_name");
                insuPubInfoJson.remove("insu_pub_no");
                insuPubInfoJson.remove("insu_pub_pat_no");


                insuSetInfo.put(insuPubInfoJson);
              }
              // add #10735 患者情報を保存できない dengshen start
              }
              // add #10735 患者情報を保存できない dengshen end
            }
            // 保険情報.公費4
            String insuPub4Cd = "";
            // mod #10735 患者情報を保存できない dengshen start
            // if (!StringUtils.isEmpty(insuSetInfoJson.get("insu_pub4_cd").toString()) && !"null".equals(insuSetInfoJson.get("insu_pub4_cd").toString())) {
            if (insuSetInfoJson.has("insu_pub4_cd") && !StringUtils.isEmpty(insuSetInfoJson.get("insu_pub4_cd").toString()) && !"null".equals(insuSetInfoJson.get("insu_pub4_cd").toString())) {
            // mod #10735 患者情報を保存できない dengshen end
              PatInsurance insuInfo1 = patInsuranceDao.selectByCd(Long.parseLong(String.valueOf(insuSetInfoJson.get("insu_pub4_cd").toString())));
              // add #10735 患者情報を保存できない dengshen start
              if (insuInfo1 != null) {
              // add #10735 患者情報を保存できない dengshen end
              insuPub4Cd = insuInfo1.getInsu_name() != null ? insuInfo1.getInsu_name() : "";
              //mod #10510 Number→Staring 杜 start
              //Long insuCode = insuInfo1.getInsurance_cd() != null ? insuInfo1.getInsurance_cd() : null;
              String insuCode = insuInfo1.getInsurance_cd() != null ? insuInfo1.getInsurance_cd().toString() : null;
              String insuInfoName = insuInfo1.getInsu_name() != null ? insuInfo1.getInsu_name() : null;
              //Integer insuClass = insuInfo1.getInsu_class() != null ? insuInfo1.getInsu_class() : null;
              String insuClass = insuInfo1.getInsu_class() != null ? insuInfo1.getInsu_class().toString() : null;
              //mod #10510 Number→Staring 杜 end
              String insuNameShort = insuInfo1.getInsu_name_short() != null ? insuInfo1.getInsu_name_short() : null;
              if(insuInfo.getInsu_class().equals(2)) {
                JSONObject insuPubInfoJson = new JSONObject(insuInfo1.getInsu_pub_info());
                // mod #10735 患者情報を保存できない dengshen start
                // String insuPub1Name = insuPubInfoJson.get("insu_pub_name") != null && !insuPubInfoJson.get("insu_pub_name").equals("null") ? insuPubInfoJson.get("insu_pub_name").toString() : null;
                // String insuPubNo = insuPubInfoJson.get("insu_pub_no") != null && !insuPubInfoJson.get("insu_pub_no").equals("null") ? insuPubInfoJson.get("insu_pub_no").toString() : null;
                // String insuPubPatNo = insuPubInfoJson.get("insu_pub_pat_no") != null && !insuPubInfoJson.get("insu_pub_pat_no").equals("null") ? insuPubInfoJson.get("insu_pub_pat_no").toString() : null;
                String insuPub1Name = insuPubInfoJson.has("insu_pub_name") && insuPubInfoJson.get("insu_pub_name") != null && !insuPubInfoJson.get("insu_pub_name").equals("null") ? insuPubInfoJson.get("insu_pub_name").toString() : null;
                String insuPubNo = insuPubInfoJson.has("insu_pub_no") && insuPubInfoJson.get("insu_pub_no") != null && !insuPubInfoJson.get("insu_pub_no").equals("null") ? insuPubInfoJson.get("insu_pub_no").toString() : null;
                String insuPubPatNo = insuPubInfoJson.has("insu_pub_pat_no") && insuPubInfoJson.get("insu_pub_pat_no") != null && !insuPubInfoJson.get("insu_pub_pat_no").equals("null") ? insuPubInfoJson.get("insu_pub_pat_no").toString() : null;
                // mod #10735 患者情報を保存できない dengshen end
                insuPubInfoJson.put("insu_pub4_cd", insuCode != null && !insuCode.equals("null") ? insuCode : JSONObject.NULL);
                insuPubInfoJson.put("insu_pub4_info_name", insuInfoName != null && !insuInfoName.equals("null") ? insuInfoName : JSONObject.NULL);
                insuPubInfoJson.put("insu_pub4_info_name_short", insuNameShort != null && !insuNameShort.equals("null") ? insuNameShort : JSONObject.NULL);
                insuPubInfoJson.put("insu_class", insuClass != null && !insuClass.equals("null") ? insuClass : JSONObject.NULL);
                insuPubInfoJson.put("insu_pub4_name", insuPub1Name != null && !insuPub1Name.equals("null") ? insuPub1Name : JSONObject.NULL);
                insuPubInfoJson.put("insu_pub4_no", insuPubNo != null && !insuPubNo.equals("null") ? insuPubNo : JSONObject.NULL);
                insuPubInfoJson.put("insu_pub4_pat_no",insuPubPatNo != null && !insuPubPatNo.equals("null") ? insuPubPatNo : JSONObject.NULL);
                //add #10510 「障害者手帳番号4」拡張 杜天成　start
                // mod #10735 患者情報を保存できない dengshen start
                // insuPubInfoJson.put("insu_pub4_passbook_no",insuPubInfoJson.get("passbook_no") != null && !insuPubInfoJson.get("passbook_no").equals("null")? insuPubInfoJson.get("passbook_no") : JSONObject.NULL);
                insuPubInfoJson.put("insu_pub4_passbook_no", insuPubInfoJson.has("passbook_no") && insuPubInfoJson.get("passbook_no") != null && !insuPubInfoJson.get("passbook_no").equals("null")? insuPubInfoJson.get("passbook_no") : JSONObject.NULL);
                // mod #10735 患者情報を保存できない dengshen end
                insuPubInfoJson.remove("passbook_no");
                //add #10510 「障害者手帳番号4」拡張 杜天成　end
                insuPubInfoJson.remove("insu_pub_name");
                insuPubInfoJson.remove("insu_pub_no");
                insuPubInfoJson.remove("insu_pub_pat_no");

                insuSetInfo.put(insuPubInfoJson);
              }
              // add #10735 患者情報を保存できない dengshen start
              }
              // add #10735 患者情報を保存できない dengshen end
            }
            patInsuranceHistory.setInsu_set_info(insuSetInfo.toString());
            // 保険情報
            if (insuInfo.getInsu_class().equals(0)) {
              patInsuranceHistory.setInsu_pub_info(null);
              patInsuranceHistory.setInsu_set_info(null);
              patInsuranceHistory.setInsu_self_info(null);
              // 公費情報
            }else if(insuInfo.getInsu_class().equals(1)) {
              patInsuranceHistory.setInsu_info(null);
              patInsuranceHistory.setInsu_set_info(null);
              patInsuranceHistory.setInsu_self_info(null);
              // セット情報
            }else if(insuInfo.getInsu_class().equals(2)) {
              patInsuranceHistory.setInsu_info(null);
              patInsuranceHistory.setInsu_self_info(null);
              patInsuranceHistory.setInsu_pub_info(null);
              // 自費情報
            }else if (insuInfo.getInsu_class().equals(3)) {
              patInsuranceHistory.setInsu_info(null);
              patInsuranceHistory.setInsu_set_info(null);
              patInsuranceHistory.setInsu_pub_info(null);
            }
            mongoTemplate.insert(patInsuranceHistory);

        //add #10532 mongoDBがダウン中の操作について（新患登録） limingzhe start
            if (!insuInfo.getInsu_class().equals(2) && "0".equals(insuInfo.getIs_del())) {
              List<PatInsuranceHistory> insuInfoList  = new ArrayList<>();
              List<PatInsuranceHistory> insuPubInfoList  = new ArrayList<>();
              patInsuranceHistories.forEach(item ->{
                if (item.getInsu_set_info() != null) {
                  JSONArray insuSet  = new JSONArray(item.getInsu_set_info());
                  for (int i = 0; i < insuSet.length(); i++) {
                    JSONObject jsonObject = insuSet.getJSONObject(i);
                    if (jsonObject.has("insu_cd") && jsonObject.get("insu_cd").equals(Integer.parseInt(patInsuInfo.getInsurance_cd().toString()))) {
                      insuInfoList.add(item);
                    }
                    if (jsonObject.has("insu_pub1_cd") && jsonObject.get("insu_pub1_cd").equals(Integer.parseInt(patInsuInfo.getInsurance_cd().toString()))) {
                      insuPubInfoList.add(item);
                    }
                    if (jsonObject.has("insu_pub2_cd") && jsonObject.get("insu_pub2_cd").equals(Integer.parseInt(patInsuInfo.getInsurance_cd().toString()))) {
                      insuPubInfoList.add(item);
                    }
                    if (jsonObject.has("insu_pub3_cd") && jsonObject.get("insu_pub3_cd").equals(Integer.parseInt(patInsuInfo.getInsurance_cd().toString()))) {
                      insuPubInfoList.add(item);
                    }
                    if (jsonObject.has("insu_pub4_cd") && jsonObject.get("insu_pub4_cd").equals(Integer.parseInt(patInsuInfo.getInsurance_cd().toString()))) {
                      insuPubInfoList.add(item);
                    }
                  }
                }
              });
            List<PatInsuranceHistory> patInsuranceHistoryList = new ArrayList<>();

              if (insuInfoList.size() >0) {
                List<PatInsuranceHistory> uniqueList = insuInfoList.stream()
                  .collect(Collectors.toMap(
                    PatInsuranceHistory::getInsurance_cd,
                    pat -> pat,
                    (existing, replacement) -> existing,
                    LinkedHashMap::new
                  )).values().stream().collect(Collectors.toList());

                patInsuranceHistoryList.addAll(uniqueList);
              }else if (insuPubInfoList.size() >0) {
                List<PatInsuranceHistory> uniqueList = insuPubInfoList.stream()
                  .collect(Collectors.toMap(
                    PatInsuranceHistory::getInsurance_cd,
                    pat -> pat,
                    (existing, replacement) -> existing,
                    LinkedHashMap::new
                  )).values().stream().collect(Collectors.toList());

                patInsuranceHistoryList.addAll(uniqueList);
              }
              if (patInsuranceHistoryList.size() > 0) {
                for (int j = 0; j < patInsuranceHistoryList.size(); j++) {
                  Long inCd = patInsuranceHistoryList.get(j).getInsurance_cd() != null ? Long.parseLong(patInsuranceHistoryList.get(j).getInsurance_cd()) : null;
                  PatInsurance noDeleteRelated = patInsurances.stream()
                    .filter(data -> data.getInsurance_cd().equals(inCd))
                    .findFirst().orElse(null);
                  if (noDeleteRelated != null && noDeleteRelated.getInsu_class().equals(2)) {
                    JSONArray insuSetInfoArray  = new JSONArray(patInsuranceHistoryList.get(j).getInsu_set_info());
                    for (int i = 0; i < insuSetInfoArray.length(); i++) {
                      JSONObject insuSetInfoJ = new JSONObject(insuSetInfoArray.get(i).toString());
                      //mod #10510 Number→Staring 杜 start
                      //Long insuCode = patInsuInfo.getInsurance_cd() != null ? patInsuInfo.getInsurance_cd(): null;
                      String insuCode = patInsuInfo.getInsurance_cd() != null ? patInsuInfo.getInsurance_cd().toString(): null;
                      String insuInfoName = patInsuInfo.getInsu_name() != null ? patInsuInfo.getInsu_name() : null;
                      //Integer insuClass = patInsuInfo.getInsu_class() != null ? patInsuInfo.getInsu_class() : null;
                      String insuClass = patInsuInfo.getInsu_class() != null ? patInsuInfo.getInsu_class().toString() : null;
                      //mod #10510 Number→Staring 杜 end
                      String insuNameShort = patInsuInfo.getInsu_name_short() != null ? patInsuInfo.getInsu_name_short() : null;

                      if (insuSetInfoJ.has("insu_cd") && insuSetInfoJ.get("insu_cd").equals(Integer.parseInt(patInsuInfo.getInsurance_cd().toString()))) {
                        insuSetInfoArray.remove(i);
                        if (patInsuInfo.getInsu_info() != null) {
                          JSONObject insuInfoJson = new JSONObject(patInsuInfo.getInsu_info());

                          insuInfoJson.put("insu_cd",insuCode != null && !insuCode.equals("null") ? insuCode : JSONObject.NULL);
                          insuInfoJson.put("insu_info_name", insuInfoName != null && !insuInfoName.equals("null") ? insuInfoName : JSONObject.NULL);
                          insuInfoJson.put("insu_info_name_short", insuNameShort != null && !insuNameShort.equals("null") ? insuNameShort : JSONObject.NULL);
                          insuInfoJson.put("insu_class", insuClass != null && !insuClass.equals("null") ? insuClass : JSONObject.NULL);

                          insuSetInfoArray.put(insuInfoJson);
                        }
                      }
                      if (insuSetInfoJ.has("insu_pub1_cd") && insuSetInfoJ.get("insu_pub1_cd").equals(Integer.parseInt(patInsuInfo.getInsurance_cd().toString()))) {
                        insuSetInfoArray.remove(i);
                        if (patInsuInfo.getInsu_pub_info() != null) {
                          JSONObject insuPubInfoJson = new JSONObject(patInsuInfo.getInsu_pub_info());

                          String insuPub1Name = insuPubInfoJson.has("insu_pub_name") && insuPubInfoJson.get("insu_pub_name") != null
                            && !insuPubInfoJson.get("insu_pub_name").equals("null") ? insuPubInfoJson.get("insu_pub_name") .toString() : null;
                          String insuPubNo = insuPubInfoJson.has("insu_pub_no") && insuPubInfoJson.get("insu_pub_no") != null
                            && !insuPubInfoJson.get("insu_pub_no").equals("null") ? insuPubInfoJson.get("insu_pub_no").toString() : null;
                          String insuPubPatNo = insuPubInfoJson.has("insu_pub_pat_no") && insuPubInfoJson.get("insu_pub_pat_no") != null
                            && !insuPubInfoJson.get("insu_pub_pat_no").equals("null") ? insuPubInfoJson.get("insu_pub_pat_no").toString() : null;
                          insuPubInfoJson.put("insu_pub1_cd", insuCode != null && !insuCode.equals("null") ? insuCode : JSONObject.NULL);
                          insuPubInfoJson.put("insu_pub1_info_name", insuInfoName != null && !insuInfoName.equals("null") ? insuInfoName : JSONObject.NULL);
                          insuPubInfoJson.put("insu_pub1_info_name_short", insuNameShort != null && !insuNameShort.equals("null") ? insuNameShort : JSONObject.NULL);
                          insuPubInfoJson.put("insu_class", insuClass != null && !insuClass.equals("null") ? insuClass : JSONObject.NULL);
                          insuPubInfoJson.put("insu_pub1_name", insuPub1Name != null && !insuPub1Name.equals("null") ? insuPub1Name : JSONObject.NULL);
                          insuPubInfoJson.put("insu_pub1_no", insuPubNo != null && !insuPubNo.equals("null") ? insuPubNo : JSONObject.NULL);
                          insuPubInfoJson.put("insu_pub1_pat_no",insuPubPatNo != null && !insuPubPatNo.equals("null")? insuPubPatNo : JSONObject.NULL);
                          //add #10510 「障害者手帳番号1」拡張 杜天成　start
                          // mod #10735 患者情報を保存できない dengshen start
                          // insuPubInfoJson.put("insu_pub1_passbook_no",insuPubInfoJson.get("passbook_no") != null && !insuPubInfoJson.get("passbook_no").equals("null")? insuPubInfoJson.get("passbook_no") : JSONObject.NULL);
                          insuPubInfoJson.put("insu_pub1_passbook_no",insuPubInfoJson.has("passbook_no") && insuPubInfoJson.get("passbook_no") != null && !insuPubInfoJson.get("passbook_no").equals("null")? insuPubInfoJson.get("passbook_no") : JSONObject.NULL);
                          // mod #10735 患者情報を保存できない dengshen end

                          insuPubInfoJson.remove("passbook_no");
                          //add #10510 「障害者手帳番号1」拡張 杜天成　end
                          insuPubInfoJson.remove("insu_pub_name");
                          insuPubInfoJson.remove("insu_pub_no");
                          insuPubInfoJson.remove("insu_pub_pat_no");

                          insuSetInfoArray.put(insuPubInfoJson);
                        }
                      }
                      if (insuSetInfoJ.has("insu_pub2_cd") && insuSetInfoJ.get("insu_pub2_cd").equals(Integer.parseInt(patInsuInfo.getInsurance_cd().toString()))) {
                        insuSetInfoArray.remove(i);
                        if (patInsuInfo.getInsu_pub_info() != null) {
                          JSONObject insuPubInfoJson = new JSONObject(patInsuInfo.getInsu_pub_info());

                          String insuPub1Name = insuPubInfoJson.has("insu_pub_name") && insuPubInfoJson.get("insu_pub_name") != null
                            && !insuPubInfoJson.get("insu_pub_name").equals("null") ? insuPubInfoJson.get("insu_pub_name") .toString() : null;
                          String insuPubNo = insuPubInfoJson.has("insu_pub_no") && insuPubInfoJson.get("insu_pub_no") != null
                            && !insuPubInfoJson.get("insu_pub_no").equals("null") ? insuPubInfoJson.get("insu_pub_no").toString() : null;
                          String insuPubPatNo = insuPubInfoJson.has("insu_pub_pat_no") && insuPubInfoJson.get("insu_pub_pat_no") != null
                            && !insuPubInfoJson.get("insu_pub_pat_no").equals("null") ? insuPubInfoJson.get("insu_pub_pat_no").toString() : null;
                          insuPubInfoJson.put("insu_pub2_cd", insuCode != null && !insuCode.equals("null") ? insuCode : JSONObject.NULL);
                          insuPubInfoJson.put("insu_pub2_info_name", insuInfoName != null && !insuInfoName.equals("null") ? insuInfoName : JSONObject.NULL);
                          insuPubInfoJson.put("insu_pub2_info_name_short", insuNameShort != null && !insuNameShort.equals("null") ? insuNameShort : JSONObject.NULL);
                          insuPubInfoJson.put("insu_class", insuClass != null && !insuClass.equals("null") ? insuClass : JSONObject.NULL);
                          insuPubInfoJson.put("insu_pub2_name", insuPub1Name != null && !insuPub1Name.equals("null") ? insuPub1Name : JSONObject.NULL);
                          insuPubInfoJson.put("insu_pub2_no", insuPubNo != null && !insuPubNo.equals("null") ? insuPubNo : JSONObject.NULL);
                          insuPubInfoJson.put("insu_pub2_pat_no",insuPubPatNo != null && !insuPubPatNo.equals("null")? insuPubPatNo : JSONObject.NULL);
                          //add #10510 「障害者手帳番号2」拡張 杜天成　start
                          // mod #10735 患者情報を保存できない dengshen start
                          // insuPubInfoJson.put("insu_pub2_passbook_no",insuPubInfoJson.get("passbook_no") != null && !insuPubInfoJson.get("passbook_no").equals("null")? insuPubInfoJson.get("passbook_no") : JSONObject.NULL);
                          insuPubInfoJson.put("insu_pub2_passbook_no", insuPubInfoJson.has("passbook_no") && insuPubInfoJson.get("passbook_no") != null && !insuPubInfoJson.get("passbook_no").equals("null")? insuPubInfoJson.get("passbook_no") : JSONObject.NULL);
                          // mod #10735 患者情報を保存できない dengshen end
                          insuPubInfoJson.remove("passbook_no");
                          //add #10510 「障害者手帳番号2」拡張 杜天成　end
                          insuPubInfoJson.remove("insu_pub_name");
                          insuPubInfoJson.remove("insu_pub_no");
                          insuPubInfoJson.remove("insu_pub_pat_no");

                          insuSetInfoArray.put(insuPubInfoJson);
                        }
                      }
                      if (insuSetInfoJ.has("insu_pub3_cd") && insuSetInfoJ.get("insu_pub3_cd").equals(Integer.parseInt(patInsuInfo.getInsurance_cd().toString()))) {
                        insuSetInfoArray.remove(i);
                        if (patInsuInfo.getInsu_pub_info() != null) {
                          JSONObject insuPubInfoJson = new JSONObject(patInsuInfo.getInsu_pub_info());

                          String insuPub1Name = insuPubInfoJson.has("insu_pub_name") && insuPubInfoJson.get("insu_pub_name") != null
                            && !insuPubInfoJson.get("insu_pub_name").equals("null") ? insuPubInfoJson.get("insu_pub_name") .toString() : null;
                          String insuPubNo = insuPubInfoJson.has("insu_pub_no") && insuPubInfoJson.get("insu_pub_no") != null
                            && !insuPubInfoJson.get("insu_pub_no").equals("null") ? insuPubInfoJson.get("insu_pub_no").toString() : null;
                          String insuPubPatNo = insuPubInfoJson.has("insu_pub_pat_no") && insuPubInfoJson.get("insu_pub_pat_no") != null
                            && !insuPubInfoJson.get("insu_pub_pat_no").equals("null") ? insuPubInfoJson.get("insu_pub_pat_no").toString() : null;
                          insuPubInfoJson.put("insu_pub3_cd", insuCode != null && !insuCode.equals("null") ? insuCode : JSONObject.NULL);
                          insuPubInfoJson.put("insu_pub3_info_name", insuInfoName != null && !insuInfoName.equals("null") ? insuInfoName : JSONObject.NULL);
                          insuPubInfoJson.put("insu_pub3_info_name_short", insuNameShort != null && !insuNameShort.equals("null") ? insuNameShort : JSONObject.NULL);
                          insuPubInfoJson.put("insu_class", insuClass != null && !insuClass.equals("null") ? insuClass : JSONObject.NULL);
                          insuPubInfoJson.put("insu_pub3_name", insuPub1Name != null && !insuPub1Name.equals("null") ? insuPub1Name : JSONObject.NULL);
                          insuPubInfoJson.put("insu_pub3_no", insuPubNo != null && !insuPubNo.equals("null") ? insuPubNo : JSONObject.NULL);
                          insuPubInfoJson.put("insu_pub3_pat_no",insuPubPatNo != null && !insuPubPatNo.equals("null")? insuPubPatNo : JSONObject.NULL);
                          //add #10510 「障害者手帳番号3」拡張 杜天成　start
                          // mod #10735 患者情報を保存できない dengshen start
                          // insuPubInfoJson.put("insu_pub3_passbook_no",insuPubInfoJson.get("passbook_no") != null && !insuPubInfoJson.get("passbook_no").equals("null")? insuPubInfoJson.get("passbook_no") : JSONObject.NULL);
                          insuPubInfoJson.put("insu_pub3_passbook_no", insuPubInfoJson.has("passbook_no") && insuPubInfoJson.get("passbook_no") != null && !insuPubInfoJson.get("passbook_no").equals("null")? insuPubInfoJson.get("passbook_no") : JSONObject.NULL);
                          // mod #10735 患者情報を保存できない dengshen end
                          insuPubInfoJson.remove("passbook_no");
                          //add #10510 「障害者手帳番号3」拡張 杜天成　end
                          insuPubInfoJson.remove("insu_pub_name");
                          insuPubInfoJson.remove("insu_pub_no");
                          insuPubInfoJson.remove("insu_pub_pat_no");

                          insuSetInfoArray.put(insuPubInfoJson);
                        }
                      }
                      if (insuSetInfoJ.has("insu_pub4_cd") && insuSetInfoJ.get("insu_pub4_cd").equals(Integer.parseInt(patInsuInfo.getInsurance_cd().toString()))) {
                        insuSetInfoArray.remove(i);
                        if (patInsuInfo.getInsu_pub_info() != null) {
                          JSONObject insuPubInfoJson = new JSONObject(patInsuInfo.getInsu_pub_info());

                          String insuPub1Name = insuPubInfoJson.has("insu_pub_name") && insuPubInfoJson.get("insu_pub_name") != null
                            && !insuPubInfoJson.get("insu_pub_name").equals("null") ? insuPubInfoJson.get("insu_pub_name") .toString() : null;
                          String insuPubNo = insuPubInfoJson.has("insu_pub_no") && insuPubInfoJson.get("insu_pub_no") != null
                            && !insuPubInfoJson.get("insu_pub_no").equals("null") ? insuPubInfoJson.get("insu_pub_no").toString() : null;
                          String insuPubPatNo = insuPubInfoJson.has("insu_pub_pat_no") && insuPubInfoJson.get("insu_pub_pat_no") != null
                            && !insuPubInfoJson.get("insu_pub_pat_no").equals("null") ? insuPubInfoJson.get("insu_pub_pat_no").toString() : null;
                          insuPubInfoJson.put("insu_pub4_cd", insuCode != null && !insuCode.equals("null") ? insuCode : JSONObject.NULL);
                          insuPubInfoJson.put("insu_pub4_info_name", insuInfoName != null && !insuInfoName.equals("null") ? insuInfoName : JSONObject.NULL);
                          insuPubInfoJson.put("insu_pub4_info_name_short", insuNameShort != null && !insuNameShort.equals("null") ? insuNameShort : JSONObject.NULL);
                          insuPubInfoJson.put("insu_class", insuClass != null && !insuClass.equals("null") ? insuClass : JSONObject.NULL);
                          insuPubInfoJson.put("insu_pub4_name", insuPub1Name != null && !insuPub1Name.equals("null") ? insuPub1Name : JSONObject.NULL);
                          insuPubInfoJson.put("insu_pub4_no", insuPubNo != null && !insuPubNo.equals("null") ? insuPubNo : JSONObject.NULL);
                          insuPubInfoJson.put("insu_pub4_pat_no",insuPubPatNo != null && !insuPubPatNo.equals("null")? insuPubPatNo : JSONObject.NULL);
                          //add #10510 「障害者手帳番号4」拡張 杜天成　start
                          // mod #10735 患者情報を保存できない dengshen start
                          // insuPubInfoJson.put("insu_pub4_passbook_no",insuPubInfoJson.get("passbook_no") != null && !insuPubInfoJson.get("passbook_no").equals("null")? insuPubInfoJson.get("passbook_no") : JSONObject.NULL);
                          insuPubInfoJson.put("insu_pub4_passbook_no", insuPubInfoJson.has("passbook_no") && insuPubInfoJson.get("passbook_no") != null && !insuPubInfoJson.get("passbook_no").equals("null")? insuPubInfoJson.get("passbook_no") : JSONObject.NULL);
                          // mod #10735 患者情報を保存できない dengshen end
                          insuPubInfoJson.remove("passbook_no");
                          //add #10510 「障害者手帳番号4」拡張 杜天成　end
                          insuPubInfoJson.remove("insu_pub_name");
                          insuPubInfoJson.remove("insu_pub_no");
                          insuPubInfoJson.remove("insu_pub_pat_no");

                          insuSetInfoArray.put(insuPubInfoJson);
                        }
                      }
                    }

                    PatInsuranceHistory patInsuranceHistoryUp = new PatInsuranceHistory();
                    BeanUtils.copyProperties(patInsuranceHistoryList.get(j), patInsuranceHistoryUp);
                    patInsuranceHistoryUp.set_id(null);
                    patInsuranceHistoryUp.setUp_date(strDate);
                    patInsuranceHistoryUp.setReg_date(strDate);
                    patInsuranceHistoryUp.setInsu_set_info(insuSetInfoArray.toString());
                    patInsuranceHistoryUp.setIns_date(nowTimestamp);

                    mongoTemplate.insert(patInsuranceHistoryUp);
                  }
                }
              }
            }
          }
          //  mod 10525 保険区分が「セット」のときクラス「処方情報」が出力できない 関  end
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
        //add #10532 mongoDBがダウン中の操作について（新患登録） limingzhe end
      }
    }
  }

  //  add 10525 保険区分が「セット」のときクラス「処方情報」が出力できない 関  start
  @Transactional
  public void updateUpdatePatInsu(List<PatInsuInfo> patInsuInfos) throws Exception {
    for (PatInsuInfo patInsuInfo : patInsuInfos) {
      //del 10532 mongoDBがダウン中の操作について（新患登録） xuehongda start
//      PatInsurance patInsuranceHaiTa = patInsuranceDao.selectById(patInsuInfo.getInsurance_cd());
//      if (patInsuInfo.getOld_up_date() != null && patInsuranceHaiTa != null) {
//        if (!patInsuInfo.getOld_up_date().equals(patInsuranceHaiTa.getOld_up_date())) {
//          throw new OptimisticLockException(SqlLogType.NONE, SqlKind.UPDATE, "", "", "");
//        }
//      } else if (patInsuInfo.getOld_up_date() != null && patInsuranceHaiTa == null) {
//        throw new OptimisticLockException(SqlLogType.NONE, SqlKind.UPDATE, "", "", "");
//      }
//      // 保険情報
//      if (patInsuInfo.getInsu_class().equals(0)) {
//        patInsuInfo.setInsu_pub_info(null);
//        patInsuInfo.setInsu_set_info(null);
//        patInsuInfo.setInsu_self_info(null);
//        // 公費情報
//      }else if(patInsuInfo.getInsu_class().equals(1)) {
//        patInsuInfo.setInsu_info(null);
//        patInsuInfo.setInsu_set_info(null);
//        patInsuInfo.setInsu_self_info(null);
//        // セット情報
//      }else if(patInsuInfo.getInsu_class().equals(2)) {
//        patInsuInfo.setInsu_info(null);
//        patInsuInfo.setInsu_self_info(null);
//        patInsuInfo.setInsu_pub_info(null);
//        // 自費情報
//      }else if (patInsuInfo.getInsu_class().equals(3)) {
//        patInsuInfo.setInsu_info(null);
//        patInsuInfo.setInsu_set_info(null);
//        patInsuInfo.setInsu_pub_info(null);
//      }
//      patInsuranceDao.updateById(patInsuInfo);
      //del 10532 mongoDBがダウン中の操作について（新患登録） xuehongda end
      if (mongoTemplate != null) {
        try {
          if (MongoHealthCheckService.getMongoDBConnected()) {
            PatInsurance insuInfo = patInsuranceDao.selectByCd(patInsuInfo.getInsurance_cd());
            if(insuInfo == null) return;
            Timestamp now = new Timestamp(new Date().getTime());
            PatInsuranceHistory patInsuranceHistory = new PatInsuranceHistory();
            BeanUtils.copyProperties(insuInfo, patInsuranceHistory);
            patInsuranceHistory.setIns_date(now);
            String pat_idR = patInsuInfo.getPat_id().toString();
            patInsuranceHistory.setPat_id(pat_idR);
            LocalDateTime currentTime = LocalDateTime.now();
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
            patInsuranceHistory.setUp_date(currentTime.format(formatter));
            if (insuInfo.getInsurance_cd() != null) {
              patInsuranceHistory.setInsurance_cd(insuInfo.getInsurance_cd().toString());
            }
            if (insuInfo.getCtl_no() != null) {
              patInsuranceHistory.setCtl_no(insuInfo.getCtl_no().toString());
            }
            // セット情報
            JSONObject insuSetInfoJson = new JSONObject(patInsuranceHistory.getInsu_set_info());

            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            Timestamp nowTimestamp = new Timestamp(new Date().getTime());

            // 保険区分変更以外のmongoDB挿入
            JSONArray insuSetInfo = new JSONArray();
            // 保険名
            // mod #10735 患者情報を保存できない dengshen start
            // if (insuSetInfoJson.get("insu_cd") != null && !insuSetInfoJson.get("insu_cd").toString().isEmpty() && !"null".equals(insuSetInfoJson.get("insu_cd").toString())) {
            if (insuSetInfoJson.has("insu_cd") && insuSetInfoJson.get("insu_cd") != null && !insuSetInfoJson.get("insu_cd").toString().isEmpty() && !"null".equals(insuSetInfoJson.get("insu_cd").toString())) {
            // mod #10735 患者情報を保存できない dengshen end
              PatInsurance insuInfo1 = patInsuranceDao.selectByCd(Long.parseLong(String.valueOf(insuSetInfoJson.get("insu_cd"))));
              // add #10735 患者情報を保存できない dengshen start
              if (insuInfo1 != null) {
              // add #10735 患者情報を保存できない dengshen end
              //mod #10510 Number→Staring 杜 start
              //Long insuCode = insuInfo1.getInsurance_cd() != null ? insuInfo1.getInsurance_cd(): null;
              String insuCode = insuInfo1.getInsurance_cd() != null ? insuInfo1.getInsurance_cd().toString(): null;
              String insuInfoName = insuInfo1.getInsu_name() != null ? insuInfo1.getInsu_name() : null;
              //Integer insuClass = insuInfo1.getInsu_class() != null ? insuInfo1.getInsu_class() : null;
              String insuClass = insuInfo1.getInsu_class() != null ? insuInfo1.getInsu_class().toString() : null;
              //mod #10510 Number→Staring 杜 end
              String insuNameShort = insuInfo1.getInsu_name_short() != null ? insuInfo1.getInsu_name_short() : null;

              if(insuInfo.getInsu_class().equals(2)) {
                JSONObject insuInfoJson = new JSONObject(insuInfo1.getInsu_info());
                insuInfoJson.put("insu_cd",insuCode != null && !insuCode.equals("null") ? insuCode : JSONObject.NULL);
                insuInfoJson.put("insu_info_name", insuInfoName != null && !insuInfoName.equals("null") ? insuInfoName : JSONObject.NULL);
                insuInfoJson.put("insu_info_name_short", insuNameShort != null && !insuNameShort.equals("null") ? insuNameShort : JSONObject.NULL);
                insuInfoJson.put("insu_class", insuClass != null && !insuClass.equals("null") ? insuClass : JSONObject.NULL);

                insuSetInfo.put(insuInfoJson);
              }
              // add #10735 患者情報を保存できない dengshen start
              }
              // add #10735 患者情報を保存できない dengshen end
            }
            // 保険情報.公費1
            // mod #10735 患者情報を保存できない dengshen start
            // if (!StringUtils.isEmpty(insuSetInfoJson.get("insu_pub1_cd").toString()) && !"null".equals(insuSetInfoJson.get("insu_pub1_cd").toString())) {
            if (insuSetInfoJson.has("insu_pub1_cd") && !StringUtils.isEmpty(insuSetInfoJson.get("insu_pub1_cd").toString()) && !"null".equals(insuSetInfoJson.get("insu_pub1_cd").toString())) {
            // mod #10735 患者情報を保存できない dengshen end
              PatInsurance insuInfo1 = patInsuranceDao.selectByCd(Long.parseLong(String.valueOf(insuSetInfoJson.get("insu_pub1_cd").toString())));
              // add #10735 患者情報を保存できない dengshen start
              if (insuInfo1 != null) {
              // add #10735 患者情報を保存できない dengshen end
              //mod #10510 Number→Staring 杜 start
              //Long insuCode = insuInfo1.getInsurance_cd() != null ? insuInfo1.getInsurance_cd() : null;
              String insuCode = insuInfo1.getInsurance_cd() != null ? insuInfo1.getInsurance_cd().toString() : null;
              String insuInfoName = insuInfo1.getInsu_name() != null ? insuInfo1.getInsu_name() : null;
              //Integer insuClass = insuInfo1.getInsu_class() != null ? insuInfo1.getInsu_class() : null;
              String insuClass = insuInfo1.getInsu_class() != null ? insuInfo1.getInsu_class().toString() : null;
              //mod #10510 Number→Staring 杜 end
              String insuNameShort = insuInfo1.getInsu_name_short() != null ? insuInfo1.getInsu_name_short() : null;

              if(insuInfo.getInsu_class().equals(2)) {
                JSONObject insuPubInfoJson = new JSONObject(insuInfo1.getInsu_pub_info());
                // mod #10735 患者情報を保存できない dengshen start
                // String insuPub1Name = insuPubInfoJson.get("insu_pub_name") != null && !insuPubInfoJson.get("insu_pub_name").equals("null") ? insuPubInfoJson.get("insu_pub_name") .toString() : null;
                // String insuPubNo = insuPubInfoJson.get("insu_pub_no") != null && !insuPubInfoJson.get("insu_pub_no").equals("null") ? insuPubInfoJson.get("insu_pub_no").toString() : null;
                // String insuPubPatNo = insuPubInfoJson.get("insu_pub_pat_no") != null && !insuPubInfoJson.get("insu_pub_pat_no").equals("null") ? insuPubInfoJson.get("insu_pub_pat_no").toString() : null;
                String insuPub1Name = insuPubInfoJson.has("insu_pub_name") && insuPubInfoJson.get("insu_pub_name") != null && !insuPubInfoJson.get("insu_pub_name").equals("null") ? insuPubInfoJson.get("insu_pub_name") .toString() : null;
                String insuPubNo = insuPubInfoJson.has("insu_pub_no") && insuPubInfoJson.get("insu_pub_no") != null && !insuPubInfoJson.get("insu_pub_no").equals("null") ? insuPubInfoJson.get("insu_pub_no").toString() : null;
                String insuPubPatNo = insuPubInfoJson.has("insu_pub_pat_no") && insuPubInfoJson.get("insu_pub_pat_no") != null && !insuPubInfoJson.get("insu_pub_pat_no").equals("null") ? insuPubInfoJson.get("insu_pub_pat_no").toString() : null;
                // mod #10735 患者情報を保存できない dengshen end
                insuPubInfoJson.put("insu_pub1_cd", insuCode != null && !insuCode.equals("null") ? insuCode : JSONObject.NULL);
                insuPubInfoJson.put("insu_pub1_info_name", insuInfoName != null && !insuInfoName.equals("null") ? insuInfoName : JSONObject.NULL);
                insuPubInfoJson.put("insu_pub1_info_name_short", insuNameShort != null && !insuNameShort.equals("null") ? insuNameShort : JSONObject.NULL);
                insuPubInfoJson.put("insu_class", insuClass != null && !insuClass.equals("null") ? insuClass : JSONObject.NULL);
                insuPubInfoJson.put("insu_pub1_name", insuPub1Name != null && !insuPub1Name.equals("null") ? insuPub1Name : JSONObject.NULL);
                insuPubInfoJson.put("insu_pub1_no", insuPubNo != null && !insuPubNo.equals("null") ? insuPubNo : JSONObject.NULL);
                insuPubInfoJson.put("insu_pub1_pat_no",insuPubPatNo != null && !insuPubPatNo.equals("null")? insuPubPatNo : JSONObject.NULL);
                //add #10510 「障害者手帳番号1」拡張 杜天成　start
                // mod #10735 患者情報を保存できない dengshen start
                // insuPubInfoJson.put("insu_pub1_passbook_no",insuPubInfoJson.get("passbook_no") != null && !insuPubInfoJson.get("passbook_no").equals("null")? insuPubInfoJson.get("passbook_no") : JSONObject.NULL);
                insuPubInfoJson.put("insu_pub1_passbook_no",insuPubInfoJson.has("passbook_no") && insuPubInfoJson.get("passbook_no") != null && !insuPubInfoJson.get("passbook_no").equals("null")? insuPubInfoJson.get("passbook_no") : JSONObject.NULL);
                // mod #10735 患者情報を保存できない dengshen end
                insuPubInfoJson.remove("passbook_no");
                //add #10510 「障害者手帳番号1」拡張 杜天成　end
                insuPubInfoJson.remove("insu_pub_name");
                insuPubInfoJson.remove("insu_pub_no");
                insuPubInfoJson.remove("insu_pub_pat_no");

                insuSetInfo.put(insuPubInfoJson);
              }
              // add #10735 患者情報を保存できない dengshen start
              }
              // add #10735 患者情報を保存できない dengshen end
            }
            // 保険情報.公費2
            if (!StringUtils.isEmpty(insuSetInfoJson.get("insu_pub2_cd").toString()) && !"null".equals(insuSetInfoJson.get("insu_pub2_cd").toString())) {
              PatInsurance insuInfo1 = patInsuranceDao.selectByCd(Long.parseLong(String.valueOf(insuSetInfoJson.get("insu_pub2_cd").toString())));
              // add #10735 患者情報を保存できない dengshen start
              if (insuInfo1 != null) {
              // add #10735 患者情報を保存できない dengshen end
              //mod #10510 Number→Staring 杜 start
              //Long insuCode = insuInfo1.getInsurance_cd() != null ? insuInfo1.getInsurance_cd() : null;
              String insuCode = insuInfo1.getInsurance_cd() != null ? insuInfo1.getInsurance_cd().toString() : null;
              String insuInfoName = insuInfo1.getInsu_name() != null ? insuInfo1.getInsu_name() : null;
              //Integer insuClass = insuInfo1.getInsu_class() != null ? insuInfo1.getInsu_class() : null;
              String insuClass = insuInfo1.getInsu_class() != null ? insuInfo1.getInsu_class().toString() : null;
              //mod #10510 Number→Staring 杜 end
              String insuNameShort = insuInfo1.getInsu_name_short() != null ? insuInfo1.getInsu_name_short() : null;
              if(insuInfo.getInsu_class().equals(2)) {
                JSONObject insuPubInfoJson = new JSONObject(insuInfo1.getInsu_pub_info());
                // mod #10735 患者情報を保存できない dengshen start
                // String insuPub1Name = insuPubInfoJson.get("insu_pub_name") != null && !insuPubInfoJson.get("insu_pub_name").equals("null") ? insuPubInfoJson.get("insu_pub_name").toString() : null;
                // String insuPubNo = insuPubInfoJson.get("insu_pub_no") != null && !insuPubInfoJson.get("insu_pub_no").equals("null") ? insuPubInfoJson.get("insu_pub_no").toString() : null;
                // String insuPubPatNo = insuPubInfoJson.get("insu_pub_pat_no") != null && !insuPubInfoJson.get("insu_pub_pat_no").equals("null") ? insuPubInfoJson.get("insu_pub_pat_no").toString() : null;
                String insuPub1Name = insuPubInfoJson.has("insu_pub_name") && insuPubInfoJson.get("insu_pub_name") != null && !insuPubInfoJson.get("insu_pub_name").equals("null") ? insuPubInfoJson.get("insu_pub_name").toString() : null;
                String insuPubNo = insuPubInfoJson.has("insu_pub_no") && insuPubInfoJson.get("insu_pub_no") != null && !insuPubInfoJson.get("insu_pub_no").equals("null") ? insuPubInfoJson.get("insu_pub_no").toString() : null;
                String insuPubPatNo = insuPubInfoJson.has("insu_pub_pat_no") && insuPubInfoJson.get("insu_pub_pat_no") != null && !insuPubInfoJson.get("insu_pub_pat_no").equals("null") ? insuPubInfoJson.get("insu_pub_pat_no").toString() : null;
                // mod #10735 患者情報を保存できない dengshen end

                insuPubInfoJson.put("insu_pub2_cd", insuCode != null && !insuCode.equals("null") ? insuCode : JSONObject.NULL);
                insuPubInfoJson.put("insu_pub2_info_name", insuInfoName != null && !insuInfoName.equals("null") ? insuInfoName : JSONObject.NULL);
                insuPubInfoJson.put("insu_pub2_info_name_short", insuNameShort != null && !insuNameShort.equals("null") ? insuNameShort : JSONObject.NULL);
                insuPubInfoJson.put("insu_class", insuClass != null && !insuClass.equals("null") ? insuClass : JSONObject.NULL);
                insuPubInfoJson.put("insu_pub2_name", insuPub1Name != null && !insuPub1Name.equals("null") ? insuPub1Name : JSONObject.NULL);
                insuPubInfoJson.put("insu_pub2_no", insuPubNo != null && !insuPubNo.equals("null") ? insuPubNo : JSONObject.NULL);
                insuPubInfoJson.put("insu_pub2_pat_no",insuPubPatNo != null && !insuPubPatNo.equals("null") ? insuPubPatNo : JSONObject.NULL);
                //add #10510 「障害者手帳番号2」拡張 杜天成　start
                // mod #10735 患者情報を保存できない dengshen start
                // insuPubInfoJson.put("insu_pub2_passbook_no",insuPubInfoJson.get("passbook_no") != null && !insuPubInfoJson.get("passbook_no").equals("null")? insuPubInfoJson.get("passbook_no") : JSONObject.NULL);
                insuPubInfoJson.put("insu_pub2_passbook_no", insuPubInfoJson.has("passbook_no") && insuPubInfoJson.get("passbook_no") != null && !insuPubInfoJson.get("passbook_no").equals("null")? insuPubInfoJson.get("passbook_no") : JSONObject.NULL);
                // mod #10735 患者情報を保存できない dengshen end
                insuPubInfoJson.remove("passbook_no");
                //add #10510 「障害者手帳番号2」拡張 杜天成　end
                insuPubInfoJson.remove("insu_pub_name");
                insuPubInfoJson.remove("insu_pub_no");
                insuPubInfoJson.remove("insu_pub_pat_no");

                insuSetInfo.put(insuPubInfoJson);
              }
              // add #10735 患者情報を保存できない dengshen start
              }
              // add #10735 患者情報を保存できない dengshen end
            }
            // 保険情報.公費3
            // mod #10735 患者情報を保存できない dengshen start
            // if (!StringUtils.isEmpty(insuSetInfoJson.get("insu_pub3_cd").toString()) && !"null".equals(insuSetInfoJson.get("insu_pub3_cd").toString())) {
            if (insuSetInfoJson.has("insu_pub3_cd") && !StringUtils.isEmpty(insuSetInfoJson.get("insu_pub3_cd").toString()) && !"null".equals(insuSetInfoJson.get("insu_pub3_cd").toString())) {
            // mod #10735 患者情報を保存できない dengshen end
              PatInsurance insuInfo1 = patInsuranceDao.selectByCd(Long.parseLong(String.valueOf(insuSetInfoJson.get("insu_pub3_cd").toString())));
              // add #10735 患者情報を保存できない dengshen start
              if (insuInfo1 != null) {
              // add #10735 患者情報を保存できない dengshen end
              //mod #10510 Number→Staring 杜 start
              //Long insuCode = insuInfo1.getInsurance_cd() != null ? insuInfo1.getInsurance_cd() : null;
              String insuCode = insuInfo1.getInsurance_cd() != null ? insuInfo1.getInsurance_cd().toString() : null;
              String insuInfoName = insuInfo1.getInsu_name() != null ? insuInfo1.getInsu_name() : null;
              //Integer insuClass = insuInfo1.getInsu_class() != null ? insuInfo1.getInsu_class() : null;
              String insuClass = insuInfo1.getInsu_class() != null ? insuInfo1.getInsu_class().toString() : null;
              //mod #10510 Number→Staring 杜 eng
              String insuNameShort = insuInfo1.getInsu_name_short() != null ? insuInfo1.getInsu_name_short() : null;
              if(insuInfo.getInsu_class().equals(2)) {
                JSONObject insuPubInfoJson = new JSONObject(insuInfo1.getInsu_pub_info());
                // mod #10735 患者情報を保存できない dengshen start
                // String insuPub1Name = insuPubInfoJson.get("insu_pub_name") != null && !insuPubInfoJson.get("insu_pub_name").equals("null") ? insuPubInfoJson.get("insu_pub_name").toString() : null;
                // String insuPubNo = insuPubInfoJson.get("insu_pub_no") != null && !insuPubInfoJson.get("insu_pub_no").equals("null") ? insuPubInfoJson.get("insu_pub_no").toString() : null;
                // String insuPubPatNo = insuPubInfoJson.get("insu_pub_pat_no") != null && !insuPubInfoJson.get("insu_pub_pat_no").equals("null")  ? insuPubInfoJson.get("insu_pub_pat_no").toString() : null;
                String insuPub1Name = insuPubInfoJson.has("insu_pub_name") && insuPubInfoJson.get("insu_pub_name") != null && !insuPubInfoJson.get("insu_pub_name").equals("null") ? insuPubInfoJson.get("insu_pub_name").toString() : null;
                String insuPubNo = insuPubInfoJson.has("insu_pub_no") && insuPubInfoJson.get("insu_pub_no") != null && !insuPubInfoJson.get("insu_pub_no").equals("null") ? insuPubInfoJson.get("insu_pub_no").toString() : null;
                String insuPubPatNo = insuPubInfoJson.has("insu_pub_pat_no") && insuPubInfoJson.get("insu_pub_pat_no") != null && !insuPubInfoJson.get("insu_pub_pat_no").equals("null")  ? insuPubInfoJson.get("insu_pub_pat_no").toString() : null;
                // mod #10735 患者情報を保存できない dengshen end

                insuPubInfoJson.put("insu_pub3_cd", insuCode != null && !insuCode.equals("null") ? insuCode : JSONObject.NULL);
                insuPubInfoJson.put("insu_pub3_info_name", insuInfoName != null && !insuInfoName.equals("null") ? insuInfoName : JSONObject.NULL);
                insuPubInfoJson.put("insu_pub3_info_name_short", insuNameShort != null && !insuNameShort.equals("null") ? insuNameShort : JSONObject.NULL);
                insuPubInfoJson.put("insu_class", insuClass != null && !insuClass.equals("null") ? insuClass : JSONObject.NULL);
                insuPubInfoJson.put("insu_pub3_name", insuPub1Name != null && !insuPub1Name.equals("null") ? insuPub1Name : JSONObject.NULL);
                insuPubInfoJson.put("insu_pub3_no", insuPubNo != null && !insuPubNo.equals("null") ? insuPubNo : JSONObject.NULL);
                insuPubInfoJson.put("insu_pub3_pat_no",insuPubPatNo != null && !insuPubPatNo.equals("null") ? insuPubPatNo : JSONObject.NULL);
                //add #10510 「障害者手帳番号3」拡張 杜天成　start
                // mod #10735 患者情報を保存できない dengshen start
                // insuPubInfoJson.put("insu_pub3_passbook_no",insuPubInfoJson.get("passbook_no") != null && !insuPubInfoJson.get("passbook_no").equals("null")? insuPubInfoJson.get("passbook_no") : JSONObject.NULL);
                insuPubInfoJson.put("insu_pub3_passbook_no", insuPubInfoJson.has("passbook_no") && insuPubInfoJson.get("passbook_no") != null && !insuPubInfoJson.get("passbook_no").equals("null")? insuPubInfoJson.get("passbook_no") : JSONObject.NULL);
                // mod #10735 患者情報を保存できない dengshen end
                insuPubInfoJson.remove("passbook_no");
                //add #10510 「障害者手帳番号3」拡張 杜天成　end
                insuPubInfoJson.remove("insu_pub_name");
                insuPubInfoJson.remove("insu_pub_no");
                insuPubInfoJson.remove("insu_pub_pat_no");


                insuSetInfo.put(insuPubInfoJson);
              }
              // add #10735 患者情報を保存できない dengshen start
              }
              // add #10735 患者情報を保存できない dengshen end
            }
            // 保険情報.公費4
            // mod #10735 患者情報を保存できない dengshen start
            // if (!StringUtils.isEmpty(insuSetInfoJson.get("insu_pub4_cd").toString()) && !"null".equals(insuSetInfoJson.get("insu_pub4_cd").toString())) {
            if (insuSetInfoJson.has("insu_pub4_cd") && !StringUtils.isEmpty(insuSetInfoJson.get("insu_pub4_cd").toString()) && !"null".equals(insuSetInfoJson.get("insu_pub4_cd").toString())) {
            // mod #10735 患者情報を保存できない dengshen end
              PatInsurance insuInfo1 = patInsuranceDao.selectByCd(Long.parseLong(String.valueOf(insuSetInfoJson.get("insu_pub4_cd").toString())));
              // add #10735 患者情報を保存できない dengshen start
              if (insuInfo1 != null) {
              // add #10735 患者情報を保存できない dengshen end
              //mod #10510 Number→Staring 杜 start
              //Long insuCode = insuInfo1.getInsurance_cd() != null ? insuInfo1.getInsurance_cd() : null;
              String insuCode = insuInfo1.getInsurance_cd() != null ? insuInfo1.getInsurance_cd().toString() : null;
              String insuInfoName = insuInfo1.getInsu_name() != null ? insuInfo1.getInsu_name() : null;
              //Integer insuClass = insuInfo1.getInsu_class() != null ? insuInfo1.getInsu_class() : null;
              String insuClass = insuInfo1.getInsu_class() != null ? insuInfo1.getInsu_class().toString() : null;
              //mod #10510 Number→Staring 杜 eng
              String insuNameShort = insuInfo1.getInsu_name_short() != null ? insuInfo1.getInsu_name_short() : null;
              if(insuInfo.getInsu_class().equals(2)) {
                JSONObject insuPubInfoJson = new JSONObject(insuInfo1.getInsu_pub_info());
                // mod #10735 患者情報を保存できない dengshen start
                // String insuPub1Name = insuPubInfoJson.get("insu_pub_name") != null && !insuPubInfoJson.get("insu_pub_name").equals("null") ? insuPubInfoJson.get("insu_pub_name").toString() : null;
                // String insuPubNo = insuPubInfoJson.get("insu_pub_no") != null && !insuPubInfoJson.get("insu_pub_no").equals("null") ? insuPubInfoJson.get("insu_pub_no").toString() : null;
                // String insuPubPatNo = insuPubInfoJson.get("insu_pub_pat_no") != null && !insuPubInfoJson.get("insu_pub_pat_no").equals("null") ? insuPubInfoJson.get("insu_pub_pat_no").toString() : null;
                String insuPub1Name = insuPubInfoJson.has("insu_pub_name") && insuPubInfoJson.get("insu_pub_name") != null && !insuPubInfoJson.get("insu_pub_name").equals("null") ? insuPubInfoJson.get("insu_pub_name").toString() : null;
                String insuPubNo = insuPubInfoJson.has("insu_pub_no") && insuPubInfoJson.get("insu_pub_no") != null && !insuPubInfoJson.get("insu_pub_no").equals("null") ? insuPubInfoJson.get("insu_pub_no").toString() : null;
                String insuPubPatNo = insuPubInfoJson.has("insu_pub_pat_no") && insuPubInfoJson.get("insu_pub_pat_no") != null && !insuPubInfoJson.get("insu_pub_pat_no").equals("null") ? insuPubInfoJson.get("insu_pub_pat_no").toString() : null;
                // mod #10735 患者情報を保存できない dengshen end
                insuPubInfoJson.put("insu_pub4_cd", insuCode != null && !insuCode.equals("null") ? insuCode : JSONObject.NULL);
                insuPubInfoJson.put("insu_pub4_info_name", insuInfoName != null && !insuInfoName.equals("null") ? insuInfoName : JSONObject.NULL);
                insuPubInfoJson.put("insu_pub4_info_name_short", insuNameShort != null && !insuNameShort.equals("null") ? insuNameShort : JSONObject.NULL);
                insuPubInfoJson.put("insu_class", insuClass != null && !insuClass.equals("null") ? insuClass : JSONObject.NULL);
                insuPubInfoJson.put("insu_pub4_name", insuPub1Name != null && !insuPub1Name.equals("null") ? insuPub1Name : JSONObject.NULL);
                insuPubInfoJson.put("insu_pub4_no", insuPubNo != null && !insuPubNo.equals("null") ? insuPubNo : JSONObject.NULL);
                insuPubInfoJson.put("insu_pub4_pat_no",insuPubPatNo != null && !insuPubPatNo.equals("null") ? insuPubPatNo : JSONObject.NULL);
                //add #10510 「障害者手帳番号4」拡張 杜天成　start
                // mod #10735 患者情報を保存できない dengshen start
                // insuPubInfoJson.put("insu_pub4_passbook_no",insuPubInfoJson.get("passbook_no") != null && !insuPubInfoJson.get("passbook_no").equals("null")? insuPubInfoJson.get("passbook_no") : JSONObject.NULL);
                insuPubInfoJson.put("insu_pub4_passbook_no", insuPubInfoJson.has("passbook_no") && insuPubInfoJson.get("passbook_no") != null && !insuPubInfoJson.get("passbook_no").equals("null")? insuPubInfoJson.get("passbook_no") : JSONObject.NULL);
                // mod #10735 患者情報を保存できない dengshen end
                insuPubInfoJson.remove("passbook_no");
                //add #10510 「障害者手帳番号4」拡張 杜天成　end
                insuPubInfoJson.remove("insu_pub_name");
                insuPubInfoJson.remove("insu_pub_no");
                insuPubInfoJson.remove("insu_pub_pat_no");

                insuSetInfo.put(insuPubInfoJson);
              }
              // add #10735 患者情報を保存できない dengshen start
              }
              // add #10735 患者情報を保存できない dengshen end
            }
            patInsuranceHistory.setInsu_set_info(insuSetInfo.toString());
            // 保険情報
            if (insuInfo.getInsu_class().equals(0)) {
              patInsuranceHistory.setInsu_pub_info(null);
              patInsuranceHistory.setInsu_set_info(null);
              patInsuranceHistory.setInsu_self_info(null);
              // 公費情報
            }else if(insuInfo.getInsu_class().equals(1)) {
              patInsuranceHistory.setInsu_info(null);
              patInsuranceHistory.setInsu_set_info(null);
              patInsuranceHistory.setInsu_self_info(null);
              // セット情報
            }else if(insuInfo.getInsu_class().equals(2)) {
              patInsuranceHistory.setInsu_info(null);
              patInsuranceHistory.setInsu_self_info(null);
              patInsuranceHistory.setInsu_pub_info(null);
              // 自費情報
            }else if (insuInfo.getInsu_class().equals(3)) {
              patInsuranceHistory.setInsu_info(null);
              patInsuranceHistory.setInsu_set_info(null);
              patInsuranceHistory.setInsu_pub_info(null);
            }

            mongoTemplate.insert(patInsuranceHistory);
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
      }
    }
  }
  //  add 10525 保険区分が「セット」のときクラス「処方情報」が出力できない 関  end

  // add 10626 データリストのCTR・DW一括登録修正 房 start
  @Override
  public void updateAndInsertPatsInfoToMongo(List<PatInfo> patsInfo) throws Exception {
    try {
      if (MongoHealthCheckService.getMongoDBConnected()) {
        Map<String, Map<String, String>> getMstNames = allCodeEdit(patsInfo);
        if(patsInfo != null && patsInfo.size() > 0) {
          Timestamp now = new Timestamp(new Date().getTime());
          ObjectMapper mapper = null;
          PatPersonalMain patPersonalMain = null;
          PatMain patMain = null;
          PatUnique patUnique = null;
          List<PatGroupCustom> patGroupCustoms = null;
          PatPersonalMainHistory patPersonalMainHistory = null;
          PatUniqueHistory patUniqueHistory = null;
          PatMainHistory patMainHistory = null;
          for(PatInfo patInfo : patsInfo) {
            mapper = new ObjectMapper();
            mapper.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);
            patPersonalMain = patInfo.getPatPersonalMain();
            patMain = patInfo.getPatMain();
            patUnique = patInfo.getPatUnique();
            patGroupCustoms = patInfo.getPatGroupList();
            patPersonalMainHistory = new PatPersonalMainHistory();
            BeanUtils.copyProperties(patPersonalMain, patPersonalMainHistory);
            patPersonalMainHistory.setIns_date(now);
            Long patId = patPersonalMain.getPat_id();
            String patIdStr = patPersonalMain.getPat_id().toString();
            patPersonalMainHistory.setPat_id(patIdStr);
            if (patPersonalMain.getDie_date() != null) {
              patPersonalMainHistory.setDie_date(patPersonalMain.getDie_date().toString());
            }
            if (patPersonalMain.getDie_cd() != null) {
              patPersonalMainHistory.setDie_cd(patPersonalMain.getDie_cd().toString());
            }
            if (patPersonalMain.getPat_sex() != null) {
              patPersonalMainHistory.setPat_sex(patPersonalMain.getPat_sex().toString());
            }
            if (patPersonalMain.getPat_blood_type_abo() != null) {
              patPersonalMainHistory.setPat_blood_type_abo(patPersonalMain.getPat_blood_type_abo().toString());
            }
            if (patPersonalMain.getPat_blood_type_rh() != null) {
              patPersonalMainHistory.setPat_blood_type_rh(patPersonalMain.getPat_blood_type_rh().toString());
            }
            if (patPersonalMain.getPat_blood_type_serovar() != null) {
              patPersonalMainHistory.setPat_blood_type_serovar(patPersonalMain.getPat_blood_type_serovar().toString());
            }
            if (patPersonalMain.getIn_out_class() != null) {
              patPersonalMainHistory.setIn_out_class(patPersonalMain.getIn_out_class().toString());
            }
            if (patPersonalMain.getSeverity_cd() != null) {
              patPersonalMainHistory.setSeverity_cd(patPersonalMain.getSeverity_cd().toString());
            }
            if (patPersonalMain.getTransport_cd() != null) {
              patPersonalMainHistory.setTransport_cd(patPersonalMain.getTransport_cd().toString());
            }
            if (patPersonalMain.getRemote_monitor_service() != null) {
              patPersonalMainHistory.setRemote_monitor_service(patPersonalMain.getRemote_monitor_service().toString());
            }
            patPersonalMainHistory.setLatest_flag("on");
            patMainHistory = new PatMainHistory();
            BeanUtils.copyProperties(patMain, patMainHistory);
            patMainHistory.setIns_date(now);
            patMainHistory.setPat_id(patIdStr);
            patMainHistory.setLatest_flag("on");

            patUniqueHistory = new PatUniqueHistory();
            BeanUtils.copyProperties(patUnique, patUniqueHistory);
            patUniqueHistory.setIns_date(now);
            patUniqueHistory.setPat_id(patIdStr);
            patUniqueHistory.setLatest_flag("on");

            // 登録施設名
            patPersonalMainHistory.setFacility_name(this.getCodeName(getMstNames, "facilityNames", patPersonalMainHistory.getFacility_cd()));
            // 死因
            patPersonalMainHistory.setDie_name(this.getCodeName(getMstNames, "diseaseNames", patPersonalMainHistory.getDie_cd()));

            // 死因連携コード
            String dieHospitalCd1 = "";
            if (patPersonalMainHistory.getDie_cd() != null && !patPersonalMainHistory.getDie_cd().isEmpty() && !"null".equals(patPersonalMainHistory.getDie_cd())) {
              if(getMstNames.get("dieHospitalCds") != null && getMstNames.get("dieHospitalCds").get(patPersonalMainHistory.getDie_cd()) != null) {
                dieHospitalCd1= getMstNames.get("dieHospitalCds").get(patPersonalMainHistory.getDie_cd());
              }
            }
            patPersonalMainHistory.setDie_in_hospital_cd_1(dieHospitalCd1);

            // 透析困難情報を取得する。
            JSONArray dialDiffComInfoJson = this.getJSONArray(patPersonalMain.getDial_diff_com_info());
            // 透析困難情報
            for (int i = 0; i < dialDiffComInfoJson.length(); i++) {
              JSONObject jsonObj = dialDiffComInfoJson.getJSONObject(i);
              // 透析困難名
              jsonObj.put("dial_diff_name", this.getCodeName(getMstNames, "mstDialysisDifficultyNames", this.checkCodeStr(jsonObj, "dial_diff_cd")));
              // 透析困難理由連携コード
              String dialHospitalCd1 = "", dialHospitalCd2 = "";
              if (jsonObj.has("dial_diff_cd") && jsonObj.get("dial_diff_cd") != null && !jsonObj.get("dial_diff_cd").toString().isEmpty() && !"null".equals(jsonObj.get("dial_diff_cd").toString())) {
                if(getMstNames.get("mstDialysisDifficultyInHospitalCds1") != null && getMstNames.get("mstDialysisDifficultyInHospitalCds1").get(jsonObj.get("dial_diff_cd").toString()) != null) {
                  dialHospitalCd1 = getMstNames.get("mstDialysisDifficultyInHospitalCds1").get(jsonObj.get("dial_diff_cd").toString());
                }
                if(getMstNames.get("mstDialysisDifficultyInHospitalCds2") != null && getMstNames.get("mstDialysisDifficultyInHospitalCds2").get(jsonObj.get("dial_diff_cd").toString()) != null) {
                  dialHospitalCd2 = getMstNames.get("mstDialysisDifficultyInHospitalCds2").get(jsonObj.get("dial_diff_cd").toString());
                }
              }
              jsonObj.put("in_hospital_cd_1", dialHospitalCd1);
              jsonObj.put("in_hospital_cd_2", dialHospitalCd2);
            }

            List<DialDiffComInfo> dialDiffComInfos = mapper.readValue(dialDiffComInfoJson.toString(), new TypeReference<List<DialDiffComInfo>>() {});
            patPersonalMainHistory.setDial_diff_com_info(dialDiffComInfos);
            List<OtherContactInfo> otherContactInfos = mapper.readValue(patPersonalMain.getOther_contact_info(), new TypeReference<List<OtherContactInfo>>() {});
            patPersonalMainHistory.setOther_contact_info(otherContactInfos);

            // 重症度名
            patPersonalMainHistory.setSeverity_name(this.getCodeName(getMstNames, "severityNames", patPersonalMainHistory.getSeverity_cd()));

            // 搬送区分
            patPersonalMainHistory.setTransport_name(this.getCodeName(getMstNames, "transportNames", patPersonalMainHistory.getTransport_cd()));

            // 原疾患
            patPersonalMainHistory.setPrimary_disease_name(this.getCodeName(getMstNames, "diseaseNames", patPersonalMainHistory.getPrimary_disease_cd()));

            // 担当スタッフ情報を取得する。
            JSONArray chargeStaffInfoJson = this.getJSONArray(patMain.getCharge_staff_info());

            // 登録施設名
            patMainHistory.setFacility_name(this.getCodeName(getMstNames, "facilityNames", patMainHistory.getFacility_cd()));

            // 担当スタッフ情報
            for (int i = 0; i < chargeStaffInfoJson.length(); i++) {
              JSONObject jsonObj = chargeStaffInfoJson.getJSONObject(i);
              // スタッフ
              jsonObj.put("staff_name", this.getCodeName(getMstNames, "personalUserNames", this.checkCodeStr(jsonObj, "staff_cd")));
              // スタッフ表示用コード
              String dispUserId = "";
              if (jsonObj.has("staff_cd") && jsonObj.get("staff_cd") != null && !jsonObj.get("staff_cd").toString().isEmpty() && !"null".equals(jsonObj.get("staff_cd").toString())) {
                MstUserAuthentication mstUserAuthentication = mstUserAuthenticationDao.selectById(Long.parseLong(jsonObj.get("staff_cd").toString()));
                dispUserId = mstUserAuthentication != null && mstUserAuthentication.getDispUserId() != null ? mstUserAuthentication.getDispUserId() : "";
              }
              jsonObj.put("staff_disp_cd", dispUserId);
            }

            List<ChargeStaffInfo> chargeStaffInfos = mapper.readValue(chargeStaffInfoJson.toString(), new TypeReference<List<ChargeStaffInfo>>() {});
            patMainHistory.setCharge_staff_info(chargeStaffInfos);

            // 感染症情報を取得する。
            JSONArray infectInfoJson = this.getJSONArray(patMain.getInfect_info());
            // 感染症情報
            for (int i = 0; i < infectInfoJson.length(); i++) {
              JSONObject jsonObj = infectInfoJson.getJSONObject(i);
              // 感染症名
              jsonObj.put("infection_name", this.getCodeName(getMstNames, "infectionNames", this.checkCodeStr(jsonObj, "infection_cd")));
            }
            List<InfectInfo> infectInfos = mapper.readValue(infectInfoJson.toString(), new TypeReference<List<InfectInfo>>() {});
            patMainHistory.setInfect_info(infectInfos);

            // インプラント情報を取得する。
            JSONArray implantInfoJson = this.getJSONArray(patMain.getImplant_info());

            // インプラント情報
            for (int i = 0; i < implantInfoJson.length(); i++) {
              JSONObject jsonObj = implantInfoJson.getJSONObject(i);
              // インプラント名
              jsonObj.put("implant_name", this.getCodeName(getMstNames, "implantNames", this.checkCodeStr(jsonObj, "implant_cd")));
            }
            List<ImplantInfo> implantInfos = mapper.readValue(implantInfoJson.toString(), new TypeReference<List<ImplantInfo>>() {});
            patMainHistory.setImplant_info(implantInfos);

            // 共通診療情報を取得する。
            JSONObject medicalCareInfoJson = new JSONObject(patMain.getMedical_care_info());

            // 共通診療情報
            // 主科名
            medicalCareInfoJson.put("main_course_name", this.getCodeName(getMstNames, "courseNames", medicalCareInfoJson.get("main_course_cd")));

            // 透析実施科名
            medicalCareInfoJson.put("dialysis_course_name", this.getCodeName(getMstNames, "courseNames", medicalCareInfoJson.get("dialysis_course_cd")));

            // 診療科連携コード
            String courseHospitalCd = "";
            if (medicalCareInfoJson.has("main_course_cd") && medicalCareInfoJson.get("main_course_cd") != null && !medicalCareInfoJson.get("main_course_cd").toString().isEmpty() && !"null".equals(medicalCareInfoJson.get("main_course_cd").toString())) {
              if(getMstNames.get("courseInHospitalCds") != null && getMstNames.get("courseInHospitalCds").get(medicalCareInfoJson.get("main_course_cd").toString()) != null) {
                courseHospitalCd = getMstNames.get("courseInHospitalCds").get(medicalCareInfoJson.get("main_course_cd").toString());
              }
            }
            medicalCareInfoJson.put("main_in_hospital_cd_1", courseHospitalCd);

            // 病棟名
            medicalCareInfoJson.put("ward_name", this.getCodeName(getMstNames, "wardNames", medicalCareInfoJson.get("ward_cd")));

            // 病棟名連携コード
            String wardHospitalCd = "";
            if (medicalCareInfoJson.has("ward_cd") && medicalCareInfoJson.get("ward_cd") != null && !medicalCareInfoJson.get("ward_cd").toString().isEmpty() && !"null".equals(medicalCareInfoJson.get("ward_cd").toString())) {
              if(getMstNames.get("wardInHospitalCds") != null && getMstNames.get("wardInHospitalCds").get(medicalCareInfoJson.get("ward_cd").toString()) != null) {
                wardHospitalCd = getMstNames.get("wardInHospitalCds").get(medicalCareInfoJson.get("ward_cd").toString());
              }
            }
            medicalCareInfoJson.put("ward_in_hospital_cd_1", wardHospitalCd);

            // 導入施設名
            medicalCareInfoJson.put("facility_name", this.getCodeName(getMstNames, "sysFacilityNames", this.checkCodeStr(medicalCareInfoJson, "facility_cd")));

            MedicalCareInfo medicalCareInfos = mapper.readValue(medicalCareInfoJson.toString(), new TypeReference<MedicalCareInfo>() {});
            patMainHistory.setMedical_care_info(medicalCareInfos);

            List<WheelChairWithNameResponse> chair = mstWheelChairSerive.getWheelChairListByPatId(patId, patMainHistory.getFacility_cd());
            if (chair != null && !chair.isEmpty()) {
              // 個人所有車いす割当あり
              patMainHistory.setWheel_chair_cd(chair.get(0).getWheelChairCd());
              patMainHistory.setWheel_chair_name(chair.get(0).getWheelChairName());
              patMainHistory.setWheel_chair_weight(chair.get(0).getWheelChairWeight());
            }else if(patMain.getWheel_chair_cd() != null){
              // 共用車いす割当あり
              WheelChairWithNameResponse sharingChair = mstWheelChairSerive.getWheelChair(patMain.getWheel_chair_cd(),null,null);
              if(sharingChair != null) {
                patMainHistory.setWheel_chair_cd(sharingChair.getWheelChairCd());
                patMainHistory.setWheel_chair_name(sharingChair.getWheelChairName());
                patMainHistory.setWheel_chair_weight(sharingChair.getWheelChairWeight());
              }
            }

            JSONArray additionInfoJson = this.getJSONArray(patMain.getAddition_info());
            // 加算情報
            for (int i = 0; i < additionInfoJson.length(); i++) {
              JSONObject jsonObj = additionInfoJson.getJSONObject(i);
              // 加算・管理料コード名称
              jsonObj.put("name", this.getCodeName(getMstNames, "additionNames", this.checkCodeStr(jsonObj, "cd")));
              // 加算形式
              jsonObj.put("kind", this.getCodeName(getMstNames, "additionKinds", this.checkCodeStr(jsonObj, "cd")));
              // 最終算定日
              jsonObj.put("last_date", this.getCodeName(getMstNames, "additionLastDates", this.checkCodeStr(jsonObj, "cd")));
            }
            List<AdditionInfo> additionInfos = mapper.readValue(additionInfoJson.toString(), new TypeReference<List<AdditionInfo>>() {});
            patMainHistory.setAddition_info(additionInfos);

            // 既往歴情報を取得する。
            JSONArray medicalHstInfoJson = this.getJSONArray(patUnique.getMedical_hst_info());
            String dialysisUnderlyingDisease = null;
            // 既往歴情報
            for (int i = 0; i < medicalHstInfoJson.length(); i++) {
              JSONObject jsonObj = medicalHstInfoJson.getJSONObject(i);
              // 登録施設名
              jsonObj.put("facility_name", this.getCodeName(getMstNames, "facilityNames", this.checkCodeStr(jsonObj, "facility_cd")));
              // 病名マスタ.病名
              jsonObj.put("disease_name", this.getCodeName(getMstNames, "diseaseNames", this.checkCodeStr(jsonObj, "disease_cd")));
              // 病名マスタ.病名連携コード
              String diseaseHospitalCd = "";
              if (jsonObj.has("disease_cd") && jsonObj.get("disease_cd") != null && !jsonObj.get("disease_cd").toString().isEmpty() && !"null".equals(jsonObj.get("disease_cd").toString())) {
                if(getMstNames.get("dieHospitalCds") != null && getMstNames.get("dieHospitalCds").get(jsonObj.get("disease_cd").toString()) != null) {
                  diseaseHospitalCd = getMstNames.get("dieHospitalCds").get(jsonObj.get("disease_cd").toString());
                }
              }
              jsonObj.put("dis_in_hospital_cd_1", diseaseHospitalCd);
              // 施設施設名
              inputCdCheck(jsonObj, "diagnosis_facility_cd", "diagnosis_facility_name",
                getMstNames, "sysFacilityNames", this.checkCodeStr(jsonObj, "diagnosis_facility_is_free"));
              // 診断医名
              inputCdCheck(jsonObj, "diagnostician_cd", "diagnostician_name",
                getMstNames, "personalUserNames", this.checkCodeStr(jsonObj, "diagnostician_is_free"));
              // 診療科名
              inputCdCheck(jsonObj, "course_cd", "course_name", getMstNames, "courseNames", this.checkCodeStr(jsonObj, "course_is_free"));
              if ("1".equals(jsonObj.get("is_dialysis_underlying_disease").toString()))
                dialysisUnderlyingDisease = this.getCodeName(getMstNames, "diseaseNames", this.checkCodeStr(jsonObj, "disease_cd"));
            }
            List<MedicalHstInfo> medicalHstInfos = mapper.readValue(medicalHstInfoJson.toString(), new TypeReference<List<MedicalHstInfo>>() {});
            patUniqueHistory.setMedical_hst_info(medicalHstInfos);
            patMainHistory.setDialysis_underlying_disease(dialysisUnderlyingDisease);

            // 入外・転入出情報を取得する。
            JSONArray inoutVisitHistoryInfoJson = this.getJSONArray(patUnique.getIn_out_visit_history_info());

            // 入外・転入出情報
            for (int i = 0; i < inoutVisitHistoryInfoJson.length(); i++) {
              JSONObject jsonObj = inoutVisitHistoryInfoJson.getJSONObject(i);
              // 登録施設名
              jsonObj.put("facility_name", this.getCodeName(getMstNames, "facilityNames", this.checkCodeStr(jsonObj, "facility_cd")));
              String moveInOut = this.getCode(inoutVisitHistoryInfoJson.getJSONObject(i), "move_in_out", String.class);
              switch (moveInOut) {
                case "3":
                case "4":
                case "5":
                case "9":
                  // 元施設
                  inputCdCheck(jsonObj, "from_facility", "from_facility_name", getMstNames, "facilityNames", this.checkCodeStr(jsonObj, "facility_is_free"));
                  // 先施設
                  inputCdCheck(jsonObj, "to_facility", "to_facility_name", getMstNames, "sysFacilityNames", this.checkCodeStr(jsonObj, "facility_is_free"));
                  break;
                case "1":
                case "2":
                case "6":
                case "7":
                case "8":
                case "10":
                  // 元施設
                  inputCdCheck(jsonObj, "from_facility", "from_facility_name", getMstNames, "sysFacilityNames", this.checkCodeStr(jsonObj, "facility_is_free"));
                  // 先施設
                  inputCdCheck(jsonObj, "to_facility", "to_facility_name", getMstNames, "facilityNames", this.checkCodeStr(jsonObj, "facility_is_free"));
                  break;
              }
              // 元科
              inputCdCheck(jsonObj, "from_course", "from_course_name", getMstNames, "courseNames", this.checkCodeStr(jsonObj, "course_is_free"));
              // 元施設医
              inputCdCheck(jsonObj, "from_doctor", "from_doctor_name", getMstNames, "personalUserNames", this.checkCodeStr(jsonObj, "doctor_is_free"));
              // 元医療機関
              jsonObj.put("from_medicalInstitution_name", this.getCodeName(getMstNames, "medicalInstitutionNames",
                jsonObj.has("from_medicalInstitutionCd") ? jsonObj.get("from_medicalInstitutionCd") : ""));
              // 先科
              inputCdCheck(jsonObj, "to_course", "to_course_name", getMstNames, "courseNames", this.checkCodeStr(jsonObj, "course_is_free"));
              // 先施設医
              inputCdCheck(jsonObj, "to_doctor", "to_doctor_name", getMstNames, "personalUserNames", this.checkCodeStr(jsonObj, "doctor_is_free"));
              // 先医療機関
              jsonObj.put("to_medicalInstitution_name", this.getCodeName(getMstNames, "medicalInstitutionNames",
                jsonObj.has("to_medicalInstitutionCd") ? jsonObj.get("to_medicalInstitutionCd") : ""));
            }
            List<InOutVisitHistoryInfo> inOutVisitHistoryInfos = mapper.readValue(inoutVisitHistoryInfoJson.toString(), new TypeReference<List<InOutVisitHistoryInfo>>() {});
            patUniqueHistory.setIn_out_visit_history_info(inOutVisitHistoryInfos);

            // 身体情報を取得する。
            JSONArray physicalInfoJson = this.getJSONArray(patUnique.getPhysical_info());

            // 身体情報
            for (int i = 0; i < physicalInfoJson.length(); i++) {
              JSONObject jsonObj = physicalInfoJson.getJSONObject(i);
              // 指示者
              jsonObj.put("indicator_name", this.getCodeName(getMstNames, "personalUserNames", this.checkCodeStr(jsonObj, "indicator_cd")));
              // 施設名
              jsonObj.put("facility_name", this.getCodeName(getMstNames, "facilityNames", this.checkCodeStr(jsonObj, "facility_cd")));
            }
            List<PhysicalInfo> physicalInfoHistoryInfos = mapper.readValue(physicalInfoJson.toString(), new TypeReference<List<PhysicalInfo>>() {});
            patUniqueHistory.setPhysical_info(physicalInfoHistoryInfos);

            Query query = new Query();
            Update update = new Update();
            query.addCriteria(Criteria.where("pat_id").is(patId.toString()));
            query.addCriteria(Criteria.where("facility_cd").is(patPersonalMainHistory.getFacility_cd()));
            query.addCriteria(Criteria.where("latest_flag").ne("off"));
            update.set("latest_flag", "off");
            mongoTemplate.updateMulti(query, update, PatPersonalMainHistory.class);
            mongoTemplate.updateMulti(query, update, PatUniqueHistory.class);

            mongoTemplate.insert(patPersonalMainHistory);
            mongoTemplate.insert(patUniqueHistory);
            PatGroupDetailHistory patGroupDetailHistory = new PatGroupDetailHistory();

            if (patGroupCustoms != null) {
              JSONArray patGroupInfoJson = new JSONArray();
              BeanUtils.copyProperties(patGroupCustoms, patGroupDetailHistory);
              for (int i = 0; i < patGroupCustoms.size(); i++) {
                PatGroupCustom patGroupCustom = patGroupCustoms.get(i);
                JSONObject jsonObj = new JSONObject();
                jsonObj.put("ctl_no", i + 1);
                // mod #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 start
                // 患者グループコード
//              String patGroupCd = String.valueOf(patGroupCustom.getPatGroupCd());
                String patGroupCd = patGroupCustom.getPatGroupCd() != null ? String.valueOf(patGroupCustom.getPatGroupCd()) : "";
                // mod #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 end
                String patGroupName = patGroupCustom.getPatGroupName();
                patGroupDetailHistory.setPat_group_cd(patGroupCd);
                jsonObj.put("pat_group_cd", patGroupCd);
                // 患者グループ名
                patGroupDetailHistory.setPat_group_name(patGroupName);
                jsonObj.put("pat_group_name", patGroupName);
                patGroupInfoJson.put(jsonObj);
                patGroupDetailHistory.setIns_date(now);
                patGroupDetailHistory.setPat_id(patIdStr);
                // facility_cd
                String facilityCdT = patPersonalMain.getFacility_cd();
                patGroupDetailHistory.setFacility_cd(facilityCdT);
                patGroupDetailHistory.setReg_date(patPersonalMain.getReg_date());
                patGroupDetailHistory.setUp_date(patPersonalMain.getUp_date());
                mongoTemplate.insert(patGroupDetailHistory);
              }
              List<PatGroupInfo> patGroupInfos = mapper.readValue(patGroupInfoJson.toString(), new TypeReference<List<PatGroupInfo>>() {});
              // add #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 start
              if (patGroupInfos.size() > 0) {
                AtomicInteger atomicInteger = new AtomicInteger(1);
                patGroupInfos.forEach(pginfo -> pginfo.setCtl_no(atomicInteger.getAndIncrement()));
              }
              // add #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 end
              patMainHistory.setPat_group_info(patGroupInfos);
              List<PatMemoInfo> patMemoInfos = mapper.readValue(patMain.getPat_memo_info(), new TypeReference<List<PatMemoInfo>>() {});
              patMainHistory.setPat_memo_info(patMemoInfos);
              List<TabooAllergyInfo> tabooAllergyInfos = mapper.readValue(patMain.getTaboo_allergy_info(), new TypeReference<List<TabooAllergyInfo>>() {});
              patMainHistory.setTaboo_allergy_info(tabooAllergyInfos);
            }
            Query query1 = new Query();
            Update update1 = new Update();
            query1.addCriteria(Criteria.where("pat_id").is(patId.toString()));
            query1.addCriteria(Criteria.where("facility_cd").is(patPersonalMainHistory.getFacility_cd()));
            query1.addCriteria(Criteria.where("latest_flag").ne("off"));
            update1.set("latest_flag", "off");
            mongoTemplate.updateMulti(query1, update1, PatMainHistory.class);
            mongoTemplate.insert(patMainHistory);
          }
        }
      }
    } catch (Exception e) {
      MongoHealthCheckService.setMongoDBConnected(false);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
    }
  }

  public Map<String, Map<String, String>> allCodeEdit(List<PatInfo> patsInfo) {
    Map<String, Map<String, String>> result = new HashMap<>();
    if(patsInfo != null && patsInfo.size() > 0) {
      // 施設
      List<String> facilitys = new ArrayList<>();

      // 施設施設
      List<String> favoriteFacilitys = new ArrayList<>();

      // 病名マス
      List<Integer> diseases = new ArrayList<>();

      // 診療科
      List<Integer> courses = new ArrayList<>();

      // 感染症
      List<Integer> infections = new ArrayList<>();

      // インプラント
      List<Integer> implants = new ArrayList<>();

      // 病棟
      List<Integer> wards = new ArrayList<>();

      // 利用者
      List<Integer> personalUsers = new ArrayList<>();

      // 重症度
      List<Integer> severitys = new ArrayList<>();

      // 搬送区分
      List<Integer> transports = new ArrayList<>();

      // 透析困難情報
      List<Integer> mstDialysisDifficulties = new ArrayList<>();

      // 加算
      List<Integer> additions = new ArrayList<>();

      // 元医療機関
      List<String> medicalInstitutionCds = new ArrayList<>();

      // 患者ID
      List<Long> patIds = new ArrayList<>();

      String facilityCd = patsInfo.get(0).getPatMain().getFacility_cd();

      for(PatInfo patInfo : patsInfo) {
        codesEdit(facilitys, favoriteFacilitys, diseases, courses, infections ,implants, wards, personalUsers, severitys
          ,transports, mstDialysisDifficulties, additions, medicalInstitutionCds, patIds
          ,patInfo.getPatPersonalMain(), patInfo.getPatMain(), patInfo.getPatUnique());
      }
      result = getMstNames(facilitys, favoriteFacilitys, diseases, courses, infections, implants, wards
        ,personalUsers, severitys, transports, mstDialysisDifficulties, additions, medicalInstitutionCds, patIds, facilityCd);
    }
    return result;
  }
  public void codesEdit(List<String> facilitys, List<String> favoriteFacilitys, List<Integer> diseases
    ,List<Integer> courses, List<Integer> infections, List<Integer> implants, List<Integer> wards
    ,List<Integer> personalUsers, List<Integer> severitys, List<Integer> transports, List<Integer> mstDialysisDifficulties
    ,List<Integer> additions, List<String> medicalInstitutionCds, List<Long> patIds, PatPersonalMain patPersonalMain, PatMain patMain, PatUnique patUnique) {

    // 患者ID
    patIds.add(patMain.getPat_id());

    // 共通診療情報を取得する。
    JSONObject medicalCareInfoJson = new JSONObject(patMain.getMedical_care_info());

    // 既往歴情報を取得する。
    JSONArray medicalHstInfoJson = this.getJSONArray(patUnique.getMedical_hst_info());

    // 入外・転入出情報を取得する。
    JSONArray inoutVisitHistoryInfoJson = this.getJSONArray(patUnique.getIn_out_visit_history_info());

    // 身体情報を取得する。
    JSONArray physicalInfoJson = this.getJSONArray(patUnique.getPhysical_info());

    // 感染症情報を取得する。
    JSONArray infectInfoJson = this.getJSONArray(patMain.getInfect_info());

    // インプラント情報を取得する。
    JSONArray implantInfoJson = this.getJSONArray(patMain.getImplant_info());

    // 担当スタッフ情報を取得する。
    JSONArray chargeStaffInfoJson = this.getJSONArray(patMain.getCharge_staff_info());

    // 透析困難情報を取得する。
    JSONArray dialDiffComInfoJson = this.getJSONArray(patPersonalMain.getDial_diff_com_info());

    // 加算
    JSONArray additionInfoJson = this.getJSONArray(patMain.getAddition_info());

    // 登録施設名
    facilitys.add(patPersonalMain.getFacility_cd());

    // 登録施設名
    facilitys.add(patMain.getFacility_cd());

    // 導入施設名
    favoriteFacilitys.add(this.getCode(medicalCareInfoJson, "facility_cd", String.class));

    // 登録施設名
    facilitys.addAll(this.getJsonObjCodeStr(medicalHstInfoJson, "facility_cd"));

    // 施設施設名
    favoriteFacilitys.addAll(this.getJsonObjCodeStr(medicalHstInfoJson, "diagnosis_facility_cd"));

    // 登録施設名
    facilitys.addAll(this.getJsonObjCodeStr(inoutVisitHistoryInfoJson, "facility_cd"));

    // 施設名
    facilitys.addAll(this.getJsonObjCodeStr(physicalInfoJson, "facility_cd"));

    // 死因
    Integer dieCd = null;
    if (patPersonalMain.getDie_cd() != null && !"".equals(patPersonalMain.getDie_cd())) {
      dieCd = Integer.valueOf(patPersonalMain.getDie_cd());
    }
    diseases.add(this.getCode(dieCd, Integer.class));

    // 原疾患
    diseases.add(this.getCode(patPersonalMain.getPrimary_disease_cd(), Integer.class));

    // 病名マスタ.病名
    diseases.addAll(this.getJsonObjCodeInt(medicalHstInfoJson, "disease_cd"));

    // 主科名
    courses.add(this.getCode(medicalCareInfoJson, "main_course_cd", Integer.class));

    // 透析実施科名
    courses.add(this.getCode(medicalCareInfoJson, "dialysis_course_cd", Integer.class));

    // 診療科名
    courses.addAll(this.getJsonObjCodeInt(medicalHstInfoJson, "course_cd"));

    // 感染症名
    infections.addAll(this.getJsonObjCodeInt(infectInfoJson, "infection_cd"));

    // インプラント名
    implants.addAll(this.getJsonObjCodeInt(implantInfoJson, "implant_cd"));

    // 病棟名
    wards.add(this.getCode(medicalCareInfoJson, "ward_cd", Integer.class));

    // 指示者
    personalUsers.addAll(this.getJsonObjCodeInt(physicalInfoJson, "indicator_cd"));

    // スタッフ
    personalUsers.addAll(this.getJsonObjCodeInt(chargeStaffInfoJson, "staff_cd"));

    // 診断医名
    personalUsers.addAll(this.getJsonObjCodeInt(medicalHstInfoJson, "diagnostician_cd"));

    // 重症度名
    severitys.add(this.getCode(patPersonalMain.getSeverity_cd(), Integer.class));

    // 搬送区分
    transports.add(this.getCode(patPersonalMain.getTransport_cd(), Integer.class));

    // 透析困難名
    mstDialysisDifficulties.addAll(this.getJsonObjCodeInt(dialDiffComInfoJson, "dial_diff_cd"));

    if (inoutVisitHistoryInfoJson != null && inoutVisitHistoryInfoJson.length() != 0) {
      for (int i = 0; i < inoutVisitHistoryInfoJson.length(); i++) {
        String moveInOut = this.getCode(inoutVisitHistoryInfoJson.getJSONObject(i), "move_in_out", String.class);
        // 元施設
        String fromFacility = this.getCode(inoutVisitHistoryInfoJson.getJSONObject(i), "from_facility", String.class);
        // 先施設
        String toFacility = this.getCode(inoutVisitHistoryInfoJson.getJSONObject(i), "to_facility", String.class);

        switch (moveInOut) {
          case "3":
          case "4":
          case "5":
          case "9":
            // 元施設
            facilitys.add(fromFacility);
            // 先施設
            favoriteFacilitys.add(toFacility);
            break;
          case "1":
          case "2":
          case "6":
          case "7":
          case "8":
          case "10":
            // 元施設
            favoriteFacilitys.add(fromFacility);
            // 先施設
            facilitys.add(toFacility);
            break;
        }
      }
    }

    // 元科
    courses.addAll(this.getJsonObjCodeInt(inoutVisitHistoryInfoJson, "from_course"));

    // 元施設医
    personalUsers.addAll(this.getJsonObjCodeInt(inoutVisitHistoryInfoJson, "from_doctor"));


    medicalInstitutionCds.addAll(this.getJsonObjCodeStr(inoutVisitHistoryInfoJson, "from_medicalInstitutionCd"));

    // 先科
    courses.addAll(this.getJsonObjCodeInt(inoutVisitHistoryInfoJson, "to_course"));

    // 先施設医
    personalUsers.addAll(this.getJsonObjCodeInt(inoutVisitHistoryInfoJson, "to_doctor"));

    // 先医療機関
    medicalInstitutionCds.addAll(this.getJsonObjCodeStr(inoutVisitHistoryInfoJson, "to_medicalInstitutionCd"));

    //加算
    additions.addAll(this.getJsonObjCodeInt(additionInfoJson, "cd"));
  }

  public Map<String, Map<String, String>> getMstNames(List<String> facilitys, List<String> favoriteFacilitys, List<Integer> diseases
    ,List<Integer> courses, List<Integer> infections, List<Integer> implants, List<Integer> wards
    ,List<Integer> personalUsers, List<Integer> severitys, List<Integer> transports, List<Integer> mstDialysisDifficulties
    ,List<Integer> additions, List<String> medicalInstitutionCds, List<Long> patIds, String facilityCd) {
    Map<String, Map<String, String>> names = new HashMap<>();

    // 施設マスタ情報を取得する。→→→→→→　Map<String FacilityCd, String FacilityName>
    Map<String, String> facilityNames = mstFacilityDao.selectNamesByCd(this.cleanStrLst(facilitys)).stream()
      .collect(Collectors.toMap(MstFacility::getFacilityCd, MstFacility::getFacilityName));

    // 病名マスタ情報を取得する。→→→→→→　Map<String DiseaseCd, String DiseaseName>
    Map<String, String> diseaseNames = new HashMap<>();
    Map<String, String> dieHospitalCds = new HashMap<>();
    diseases = this.cleanIntLst(diseases);
    if (diseases.size() > 0) {
      mstDiseaseDao.selectAllName(diseases).stream().forEach(el -> {
        if(!diseaseNames.containsKey(String.valueOf(el.getDiseaseCd())))
          diseaseNames.put(String.valueOf(el.getDiseaseCd()), el.getDiseaseName());
        if(!dieHospitalCds.containsKey(String.valueOf(el.getDiseaseCd()))) {
          dieHospitalCds.put(String.valueOf(el.getDiseaseCd()), el.getInHospitalCd_1());
        }
      });
    }

    // 診療科マスタ情報を取得する。→→→→→→　Map<String CourseCd, String CourseName>
    Map<String, String> courseNames = new HashMap<String, String>();
    Map<String, String> courseInHospitalCds = new HashMap<String, String>();
    courses = this.cleanIntLst(courses);
    if (courses.size() > 0) {
      mstCourseDao.selectAllName(courses).stream().forEach(el -> {
        if(!courseNames.containsKey(String.valueOf(el.getCourseCd())))
          courseNames.put(String.valueOf(el.getCourseCd()), el.getCourseName());
        if(!courseInHospitalCds.containsKey(String.valueOf(el.getCourseCd())))
          courseInHospitalCds.put(String.valueOf(el.getCourseCd()), el.getInHospitalCd_1());
      });
    }

    // 感染症マスタ情報を取得する。→→→→→→　Map<String InfectionCd, String InfectionName>
    Map<String, String> infectionNames = new HashMap<String, String>();
    infections = this.cleanIntLst(infections);
    if (infections.size() > 0) {
      mstInfectionDao.selectAllName(infections).stream()
        .collect(Collectors.toMap(MstInfection::getInfectionCd, MstInfection::getInfectionName))
        .forEach((key, value) -> {if(!infectionNames.containsKey(String.valueOf(key)))infectionNames.put(String.valueOf(key), value);});
    }

    // インプラント情報を取得する。→→→→→→　Map<String InfectionCd, String InfectionName>
    Map<String, String> implantNames = new HashMap<String, String>();
    implants = this.cleanIntLst(implants);
    if (implants.size() > 0) {
      mstImplantDao.selectAllName(implants).stream()
        .collect(Collectors.toMap(MstImplant::getImplantCd, MstImplant::getImplantName))
        .forEach((key, value) -> {if(!implantNames.containsKey(String.valueOf(key)))implantNames.put(String.valueOf(key), value);});
    }

    // 病棟マスタ情報を取得する。→→→→→→　Map<String WardCd, String WardName>
    Map<String, String> wardNames = new HashMap<String, String>();
    Map<String, String> wardInHospitalCds = new HashMap<>();
    wards = this.cleanIntLst(wards);
    if (wards.size() > 0) {
      mstWardDao.selectAllName(wards).stream().forEach(el -> {
        if(!wardNames.containsKey(String.valueOf(el.getWardCd())))
          wardNames.put(String.valueOf(el.getWardCd()), el.getWardName());
        if(!wardInHospitalCds.containsKey(String.valueOf(el.getWardCd())))
          wardInHospitalCds.put(String.valueOf(el.getWardCd()), el.getInHospitalCd_1());
      });
    }

    // 利用者マスタ情報を取得する。→→→→→→　Map<String UserId, String UserFirstName+UserLastName>
    Map<String, String> personalUserNames = new HashMap<>();
    personalUsers = this.cleanIntLst(personalUsers);
    if (personalUsers.size() > 0) {
      mstPersonalUserDao.selectAllName(personalUsers).stream()
        .collect(Collectors.toMap(MstPersonalUser::getUserId, MstPersonalUser::getUserName))
        .forEach((key, value) -> {if(!personalUserNames.containsKey(String.valueOf(key)))personalUserNames.put(String.valueOf(key), value);});
    }

    // 重症度マスタ情報を取得する。→→→→→→　Map<String SeverityCd, String SeverityName>
    Map<String, String> severityNames = new HashMap<String, String>();
    List<Integer> severitysInt = new ArrayList<>();
    severitys.stream().distinct().filter(Objects::nonNull).collect(Collectors.toList())
      .forEach(item -> {if(!severitysInt.contains(Integer.valueOf(item)))severitysInt.add(Integer.valueOf(item));});
    if (severitys.size() > 0) {
      mstSeverityDao.selectAllName(severitysInt).stream()
        .collect(Collectors.toMap(MstSeverity::getSeverityCd, MstSeverity::getSeverityName))
        .forEach((key, value) -> {if(!severityNames.containsKey(String.valueOf(key)))severityNames.put(String.valueOf(key), value);});
    }

    // 搬送区分マスタ情報を取得する。→→→→→→　Map<String TransportCd, String TransportName>
    Map<String, String> transportNames = new HashMap<String, String>();
    List<Integer> transportsInt = new ArrayList<>();
    transports.stream().distinct().filter(Objects::nonNull).collect(Collectors.toList())
      .forEach(item -> {if(!transportsInt.contains(Integer.valueOf(item)))transportsInt.add(Integer.valueOf(item));});
    if (transports.size() > 0) {
      mstTransportDao.selectAllName(transportsInt).stream()
        .collect(Collectors.toMap(MstTransport::getTransportCd, MstTransport::getTransportName))
        .forEach((key, value) -> {if(!transportNames.containsKey(String.valueOf(key)))transportNames.put(String.valueOf(key), value);});
    }

    // 透析困難情報を取得する。→→→→→→　Map<String TransportCd, String TransportName>
    Map<String, String> mstDialysisDifficultyNames = new HashMap<String, String>();
    Map<String, String> mstDialysisDifficultyInHospitalCds1 = new HashMap<>();
    Map<String, String> mstDialysisDifficultyInHospitalCds2 = new HashMap<>();
    mstDialysisDifficulties = this.cleanIntLst(mstDialysisDifficulties);
    if (mstDialysisDifficulties.size() > 0) {
      mstDialysisDifficultyDao.selectAllName(mstDialysisDifficulties).stream().forEach(el -> {
        if(!mstDialysisDifficultyNames.containsKey(String.valueOf(el.getDialysisDifficultyCd())))
          mstDialysisDifficultyNames.put(String.valueOf(el.getDialysisDifficultyCd()), el.getDialysisDifficultyName());
        if(!mstDialysisDifficultyInHospitalCds1.containsKey(String.valueOf(el.getDialysisDifficultyCd())))
          mstDialysisDifficultyInHospitalCds1.put(String.valueOf(el.getDialysisDifficultyCd()), el.getInHospitalCd_1());
        if(!mstDialysisDifficultyInHospitalCds2.containsKey(String.valueOf(el.getDialysisDifficultyCd())))
          mstDialysisDifficultyInHospitalCds2.put(String.valueOf(el.getDialysisDifficultyCd()), el.getInHospitalCd_2());
      });
    }

    // 施設施設を取得する。→→→→→→　Map<String MedicalInstitutionCd, String MedicalInstitutionName>
    Map<String, String> sysFacilityNames = new HashMap<String, String>();
    favoriteFacilitys = this.cleanStrLst(favoriteFacilitys);
    if (favoriteFacilitys.size() > 0) {
      mstFavoriteFacilityDao.selectAllName(favoriteFacilitys).stream()
        .collect(Collectors.toMap(MstFavoriteFacilityData::getMedicalInstitutionCd, MstFavoriteFacilityData::getFavoriteFacilityName))
        .forEach((key, value) -> {if(!sysFacilityNames.containsKey(key))sysFacilityNames.put(key, value);});
    }

    // 全施設マスタ情報を取得する。→→→→→→　Map<String MedicalInstitutionCd, String FacilityName>
    Map<String, String> medicalInstitutionNames = new HashMap<>();
    medicalInstitutionCds = this.cleanStrLst(medicalInstitutionCds);
    if (diseases.size() > 0) {
      sysFacilityDao.selectAllName(medicalInstitutionCds).stream()
        .collect(Collectors.toMap(SysFacility::getMedicalInstitutionCd, SysFacility::getFacilityName))
        .forEach((key, value) -> {if(!medicalInstitutionNames.containsKey(String.valueOf(key)))medicalInstitutionNames.put(String.valueOf(key), value);});
    }

    // 加算マスタ情報を取得する。→→→→→→　Map<String AdditionCd, String AdditionName>
    Map<String, String> additionNames = new HashMap<String, String>();
    Map<String, String> additionKinds = new HashMap<String, String>();
    Map<String, String> additionLastDates = new HashMap<String, String>();
    additions = this.cleanIntLst(additions);
    if (additions.size() > 0) {
      mstAdditionDao.selectAllName(additions).stream()
        .collect(Collectors.toMap(MstAddition::getAdditionCd, MstAddition::getAdditionName))
        .forEach((key, value) -> {if(!additionNames.containsKey(String.valueOf(key)))additionNames.put(String.valueOf(key), value);});
      mstAdditionDao.selectAllName(additions).stream()
        .collect(Collectors.toMap(MstAddition::getAdditionCd, MstAddition::getAdditionKind))
        .forEach((key, value) -> {if(!additionKinds.containsKey(String.valueOf(key)))additionKinds.put(String.valueOf(key), value);});
      ordMainDao.selectCalculationDateListByPats(facilityCd, patIds).stream().forEach(el -> {
        if(!additionLastDates.containsKey(String.valueOf(el.getCd())))additionLastDates.put(String.valueOf(el.getCd()), el.getLast_date());
      });
    }

    names.put("facilityNames", facilityNames);
    names.put("diseaseNames", diseaseNames);
    names.put("dieHospitalCds", dieHospitalCds);
    names.put("courseNames", courseNames);
    names.put("infectionNames", infectionNames);
    names.put("implantNames", implantNames);
    names.put("wardNames", wardNames);
    names.put("personalUserNames", personalUserNames);
    names.put("severityNames", severityNames);
    names.put("transportNames", transportNames);
    names.put("mstDialysisDifficultyNames", mstDialysisDifficultyNames);
    names.put("sysFacilityNames", sysFacilityNames);
    names.put("medicalInstitutionNames", medicalInstitutionNames);
    names.put("additionNames", additionNames);
    names.put("additionKinds", additionKinds);
    names.put("additionLastDates", additionLastDates);
    names.put("mstDialysisDifficultyInHospitalCds1", mstDialysisDifficultyInHospitalCds1);
    names.put("mstDialysisDifficultyInHospitalCds2", mstDialysisDifficultyInHospitalCds2);
    names.put("courseInHospitalCds", courseInHospitalCds);
    names.put("wardInHospitalCds", wardInHospitalCds);
    return names;
  }
  // add 10626 データリストのCTR・DW一括登録修正 房 end
}
//add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 zhaoqi 20240228 end
