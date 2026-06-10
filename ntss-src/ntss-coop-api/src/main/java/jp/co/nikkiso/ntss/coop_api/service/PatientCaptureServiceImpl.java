package jp.co.nikkiso.ntss.coop_api.service;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import com.fasterxml.jackson.core.JsonProcessingException;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end
import com.fasterxml.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.MstAdditionDao;
import jp.co.nikkiso.ntss.core.dao.MstDeviceSetInfoDefaultDao;
import jp.co.nikkiso.ntss.core.dao.MstDialysisDifficultyDao;
import jp.co.nikkiso.ntss.core.dao.MstPatMemoDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.PatMainDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.dao.PatUniqueDao;
import jp.co.nikkiso.ntss.core.dao.utils.DateTimeUtils;
import jp.co.nikkiso.ntss.core.entity.DeviceSetInfo;
import jp.co.nikkiso.ntss.core.entity.MstAddition;
import jp.co.nikkiso.ntss.core.entity.MstDialysisDifficulty;
import jp.co.nikkiso.ntss.core.entity.MstPatMemo;
import jp.co.nikkiso.ntss.core.entity.PatInfo;
import jp.co.nikkiso.ntss.core.entity.PatMain;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.PatUnique;
import jp.co.nikkiso.ntss.core.entity.patHistory.PatPersonalMainHistory;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end
import jp.co.nikkiso.ntss.core.utils.MongoHealthCheckService;
import org.apache.commons.collections4.CollectionUtils;
import org.json.JSONObject;
import org.seasar.doma.jdbc.SelectOptions;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import org.springframework.aop.framework.AopProxyUtils;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.dao.DataAccessResourceFailureException;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.http.MediaType;
import org.springframework.http.RequestEntity;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;
import org.springframework.web.client.RestTemplate;
import org.springframework.data.mongodb.core.query.Query;

import java.net.URI;
import java.net.URISyntaxException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import static jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils.toJson;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end

@Service
public class PatientCaptureServiceImpl implements PatientCaptureService {

  public static final int DEFAULT_OFFSET = 1;

  public static final int MIN_OFFSET = 1;

  public static final int DEFAULT_LIMIT = 20;

  public static final int MAX_LIMIT = 100;

  @Autowired
  private PatMainDao patMainDao;

  @Autowired
  private PatPersonalMainDao patPersonalMainDao;

  @Autowired
  private PatUniqueDao patUniqueDao;

  @Autowired
  private MstDeviceSetInfoDefaultDao mstDeviceSetInfoDefaultDao;

  @Autowired
  private MstPatMemoDao mstPatMemoDao;

  @Autowired
  private OrdMainDao ordMainDao;

  @Autowired
  private LogService logService;

  // add 2021-12-23 #6679:CSI連携：新患登録時、初期展開データが反映されない。 孫 start
  @Autowired
  private MstDialysisDifficultyDao mstDialysisDifficultyDao;

  @Autowired
  private MstAdditionDao mstAdditionDao;
  // add 2021-12-23 #6679:CSI連携：新患登録時、初期展開データが反映されない。 孫 end

  // add #10436 同姓同名フラグの更新時に対になる患者のpat_main_historyがinsertされていない zhuang start
  @Value("${ntss.web-api.url}")
  private String webApi;

  @Autowired(required = false)
  MongoTemplate mongoTemplate;
  // add #10436 同姓同名フラグの更新時に対になる患者のpat_main_historyがinsertされていない zhuang end

  @Override
  public void addDefultValue(List<Long> pat_id_list, String facility_cd) {
    try {
      if (pat_id_list.size() > 0) {
        for (Long pat_id : pat_id_list) {
          PatPersonalMain patPersonalMain = patPersonalMainDao.selectById(pat_id);
          if (patPersonalMain != null) {
            patPersonalMain = getPatPersonalMain(patPersonalMain, facility_cd);
            patPersonalMainDao.updateById(pat_id, patPersonalMain);
          }
// add 2022-02-22 #6995:profile連携で受信した身体情報登録 孫 start
          else {
            String error = String.format("システムで管理する一意な患者IDが[%d]の患者が無し。", pat_id);
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage(error);
            eventLogMessage.setInvokeClass(this.getClass().getName());
            logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
            throw new NtssException(error);
          }
          // 同姓同名のチェック
          List<PatPersonalMain> patCheck = patPersonalMainDao.selectByPatName(
            patPersonalMain.getFacility_cd(),
            patPersonalMain.getPat_last_name(),
            patPersonalMain.getPat_first_name(),
            patPersonalMain.getPat_last_name_kana(),
            patPersonalMain.getPat_first_name_kana(),
            patPersonalMain.getPat_last_name_alpha(),
            patPersonalMain.getPat_first_name_alpha(),
            patPersonalMain.getPat_id());
          if (CollectionUtils.isNotEmpty(patCheck) && patCheck.size() == 1){
            // 同姓同名患者が存在する、かつ、1つ患者の場合、存在する患者の同姓同名FLAGを設定する
            patMainDao.updateIsSame(Arrays.asList(patCheck.get(0).getPat_id()), "1");
            // add #10436 同姓同名フラグの更新時に対になる患者のpat_main_historyがinsertされていない zhuang start
            isSameToMoGo(patCheck.get(0).getPat_id());
            // add #10436 同姓同名フラグの更新時に対になる患者のpat_main_historyがinsertされていない zhuang end
          }

          //add #10203 profile連携で同姓同名のチェックが行われない 20240110 zhaoqi start
          List<Long> patIdList = patPersonalMainDao.getAllDataForIsSameIsZero(facility_cd);
          if(!patIdList.isEmpty()){
            patMainDao.updateIsSameToZero(patIdList);
          }
          //add #10203 profile連携で同姓同名のチェックが行われない 20240110 zhaoqi end

          // 患者名：ind_dial onlyの同姓同名の解除
          List<PatPersonalMain> patCheckOff = patPersonalMainDao.selectByPatName(
            patPersonalMain.getFacility_cd(),
            "ini_dial",
            "only",
            null,
            null,
            null,
            null,
            0L);
          if (CollectionUtils.isNotEmpty(patCheckOff) && patCheckOff.size() == 1){
            patMainDao.updateIsSame(Arrays.asList(patCheckOff.get(0).getPat_id()), "0");
          }

          // add #10436 同姓同名フラグの更新時に対になる患者のpat_main_historyがinsertされていない zhuang start
          Query queryHistory = new Query();
          queryHistory.addCriteria(Criteria.where("pat_id").is(String.valueOf(patPersonalMain.getPat_id())));
          queryHistory.addCriteria(Criteria.where("is_del").is("0"));
          queryHistory.addCriteria(Criteria.where("latest_flag").is("on"));
          //mod #10532 mongoDBがダウン中の操作について（新患登録） zhao start
          //List<PatPersonalMainHistory> patPersonalMainHistories = mongoTemplate.find(queryHistory, PatPersonalMainHistory.class);
          List<PatPersonalMainHistory> patPersonalMainHistories = new ArrayList<>();
          try {
            if (MongoHealthCheckService.getMongoDBConnected()) {
              patPersonalMainHistories = mongoTemplate.find(queryHistory, PatPersonalMainHistory.class);
            }
          } catch (DataAccessResourceFailureException exception) {
            MongoHealthCheckService.setMongoDBConnected(false);
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage(ExcetionStackTraceToString(exception));
            if (facility_cd != null) {
              eventLogMessage.setFacilityCd(facility_cd);
            }
            logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
          }
          //mod #10532 mongoDBがダウン中の操作について（新患登録） zhao end
          if(!patPersonalMainHistories.isEmpty()){
            if(!(patPersonalMainHistories.get(0).getPat_first_name() ==null? "":patPersonalMainHistories.get(0).getPat_first_name())
                 .equals(patPersonalMain.getPat_first_name() == null? "":patPersonalMain.getPat_first_name())
              ||!(patPersonalMainHistories.get(0).getPat_last_name() ==null? "":patPersonalMainHistories.get(0).getPat_last_name())
                 .equals(patPersonalMain.getPat_last_name() == null? "":patPersonalMain.getPat_last_name())
              ||!(patPersonalMainHistories.get(0).getPat_first_name_kana() ==null? "":patPersonalMainHistories.get(0).getPat_first_name_kana())
                 .equals(patPersonalMain.getPat_first_name_kana() == null? "":patPersonalMain.getPat_first_name_kana())
              ||!(patPersonalMainHistories.get(0).getPat_last_name_kana() ==null? "":patPersonalMainHistories.get(0).getPat_last_name_kana())
                 .equals(patPersonalMain.getPat_last_name_kana() == null? "":patPersonalMain.getPat_last_name_kana())
              ||!(patPersonalMainHistories.get(0).getPat_first_name_alpha() ==null? "":patPersonalMainHistories.get(0).getPat_first_name_alpha())
                 .equals(patPersonalMain.getPat_first_name_alpha() == null? "":patPersonalMain.getPat_first_name_alpha())
              ||!(patPersonalMainHistories.get(0).getPat_last_name_alpha() ==null? "":patPersonalMainHistories.get(0).getPat_last_name_alpha())
                 .equals(patPersonalMain.getPat_last_name_alpha() == null? "":patPersonalMain.getPat_last_name_alpha())){

              patCheckOff = patPersonalMainDao.selectByPatName(
                patPersonalMainHistories.get(0).getFacility_cd(),
                patPersonalMainHistories.get(0).getPat_last_name(),
                patPersonalMainHistories.get(0).getPat_first_name(),
                patPersonalMainHistories.get(0).getPat_last_name_kana(),
                patPersonalMainHistories.get(0).getPat_first_name_kana(),
                patPersonalMainHistories.get(0).getPat_last_name_alpha(),
                patPersonalMainHistories.get(0).getPat_first_name_alpha(),
                patPersonalMain.getPat_id());
              if (CollectionUtils.isNotEmpty(patCheckOff) && patCheckOff.size() == 1){
                isSameToMoGo(patCheckOff.get(0).getPat_id());
              }
            }
          }
          // add #10436 同姓同名フラグの更新時に対になる患者のpat_main_historyがinsertされていない zhuang end

// add 2022-02-22 #6995:profile連携で受信した身体情報登録 孫 end
          PatMain patMain = patMainDao.selectById(pat_id);
          if (patMain != null) {
            patMain = getPatMain(patMain, facility_cd);
            if (CollectionUtils.isNotEmpty(patCheck) && patCheck.size() > 0){
              patMain.setIs_same("1");
            }
// add 2022-03-14 #7136:profile連携で同姓同名のチェックが行われない 孫 start
            else {
              patMain.setIs_same("0");
            }
// add 2022-03-14 #7136:profile連携で同姓同名のチェックが行われない 孫 end
            patMainDao.updateById(pat_id, patMain);
          }
// add 2021-10-18 #5890:Medicom連携ができない(患者プロファイル(profile)) 孫 start
          else {
            // null時 新規作成
            patMain= new PatMain();
            patMain.setFacility_cd(facility_cd);
            patMain.setPat_id(pat_id);
            patMain.setIs_del("0");
            String upDate = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS").format(new Date());
            patMain.setUp_date(upDate);
            patMain.setReg_date(upDate);
            patMain = getPatMain(patMain, facility_cd);
            if (CollectionUtils.isNotEmpty(patCheck) && patCheck.size() > 0){
              patMain.setIs_same("1");
            }
// add 2022-03-14 #7136:profile連携で同姓同名のチェックが行われない 孫 start
            else {
              patMain.setIs_same("0");
            }
// add 2022-03-14 #7136:profile連携で同姓同名のチェックが行われない 孫 end

            patMainDao.insert(patMain);
          }
// add 2021-10-18 #5890:Medicom連携ができない(患者プロファイル(profile)) 孫 end
          PatUnique patUnique = patUniqueDao.selectById(pat_id);
          if (patUnique != null) {
            patUnique = getPatUnique(patUnique);
            patUniqueDao.updateById(pat_id, patUnique);
          }else{
            //null時 新規作成
            PatUnique pat=new PatUnique();
            pat.setPat_id(pat_id);
            pat.setMedical_hst_info("[]");
            pat.setIn_out_visit_history_info("[]");
            pat.setPhysical_info("[]");
            pat.setIs_del("0");
            pat.setFacility_cd(facility_cd);
// add 2021-12-23 #6679:CSI連携：新患登録時、初期展開データが反映されない。 孫 start
            String upDate = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS").format(new Date());
            pat.setUp_date(upDate);
            pat.setReg_date(upDate);
// add 2021-12-23 #6679:CSI連携：新患登録時、初期展開データが反映されない。 孫 end
// add 2021-10-18 #5890:Medicom連携ができない(患者プロファイル(profile)) 孫 start
            pat = getPatUnique(pat);
// add 2021-10-18 #5890:Medicom連携ができない(患者プロファイル(profile)) 孫 end
            patUniqueDao.insert(pat);
          }
        }
      }
    } catch (Exception ex) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(ex));
      if (facility_cd != null) {
        eventLogMessage.setFacilityCd(facility_cd);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
// add 2021-10-09 #6679:CSI連携：新患登録時、初期展開データが反映されない。 孫 start
      throw new NtssException(ex);
// add 2021-10-09 #6679:CSI連携：新患登録時、初期展開データが反映されない。 孫 end
    }
  }

  private PatPersonalMain getPatPersonalMain(PatPersonalMain patPersonalMain, String facility_cd) {
// add 2021-10-09 #6679:CSI連携：新患登録時、初期展開データが反映されない。 孫 start
    // 国籍
    if (StringUtils.isEmpty(patPersonalMain.getNationality())) {
      patPersonalMain.setNationality("JPN");
    }
// add 2021-10-09 #6679:CSI連携：新患登録時、初期展開データが反映されない。 孫 end
    if (patPersonalMain.getPat_sex() == null) {
      patPersonalMain.setPat_sex(0);
    }
    if (patPersonalMain.getIs_die() == null) {
      patPersonalMain.setIs_die("0");
    }
    if (patPersonalMain.getIs_del() == null) {
      patPersonalMain.setIs_del("0");
    }
    if (patPersonalMain.getRemote_monitor_service() == null) {
      patPersonalMain.setRemote_monitor_service(0);
    }
    if (patPersonalMain.getRemote_monitor_user_id() == null) {
      patPersonalMain.setRemote_monitor_user_id("");
    }
    if (patPersonalMain.getRemote_monitor_user_pw() == null) {
      patPersonalMain.setRemote_monitor_user_pw("");
    }
    if (patPersonalMain.getOther_contact_info() == null) {
      patPersonalMain.setOther_contact_info("[]");
    }
    if (patPersonalMain.getVendor_contact_info() == null) {
      patPersonalMain.setVendor_contact_info("[]");
    }
    if (patPersonalMain.getInsurance_info() == null) {
      patPersonalMain.setInsurance_info("[]");
    }
// mod 2021-10-09 #6679:CSI連携：新患登録時、初期展開データが反映されない。 孫 start
//    if (patPersonalMain.getDial_diff_com_info() == null) {
//      patPersonalMain.setDial_diff_com_info("[]");
//    }
    // 透析困難情報
    if (patPersonalMain.getDial_diff_com_info() == null || "[]".equals(patPersonalMain.getDial_diff_com_info())) {
      List<String> dialDiffComInfo = new ArrayList();
// mod 2021-12-23 #6679:CSI連携：新患登録時、初期展開データが反映されない。 孫 start
//      int[] dialDiffCdList = new int[] {1,2,3,4,5,6,7,8,9,10,11,12};
      // 透析困難情報のデフォルトを取得する
      int[] dialDiffCdList = new int[0];
      MstDialysisDifficulty params = new MstDialysisDifficulty();
      params.setFacilityCd(facility_cd);
      SelectOptions selectOptions = SelectOptions.get();
      List<MstDialysisDifficulty> mstDialysisDifficultyList = mstDialysisDifficultyDao.selectAll(selectOptions, params);
      if (mstDialysisDifficultyList != null && mstDialysisDifficultyList.size() > 0) {
        dialDiffCdList = new int[mstDialysisDifficultyList.size()];
        for (int i=0; i<mstDialysisDifficultyList.size(); i++) {
          dialDiffCdList[i] = ((Integer)mstDialysisDifficultyList.get(i).getDialysisDifficultyCd()).intValue();
        }
      }
// mod 2021-12-23 #6679:CSI連携：新患登録時、初期展開データが反映されない。 孫 end
      for (int i=0; i<dialDiffCdList.length; i++) {
        Map<String, Object> mapInfo = new HashMap();
        mapInfo.put("is_main", "0");
        mapInfo.put("reg_date", "");
        mapInfo.put("dial_diff_cd", dialDiffCdList[i]);
        mapInfo.put("is_dial_diff", "0");
        JSONObject json = new JSONObject(mapInfo);
        dialDiffComInfo.add(json.toString().replace("\"\"", "null"));
      }
      patPersonalMain.setDial_diff_com_info(dialDiffComInfo.toString());
    }
// mod 2021-10-09 #6679:CSI連携：新患登録時、初期展開データが反映されない。 孫 end
// mod 2021-10-09 #6679:CSI連携：新患登録時、初期展開データが反映されない。 孫 start
//    if (patPersonalMain.getPat_contact_info() == null) {
    if (patPersonalMain.getPat_contact_info() == null || "{}".equals(patPersonalMain.getPat_contact_info())) {
// mod 2021-10-09 #6679:CSI連携：新患登録時、初期展開データが反映されない。 孫 end
      Map<String, Object> mapPatContactInfo = new HashMap();
      mapPatContactInfo.put("fax", "");
      mapPatContactInfo.put("tel1", "");
      mapPatContactInfo.put("tel2", "");
      mapPatContactInfo.put("memo1", "");
      mapPatContactInfo.put("memo2", "");
      mapPatContactInfo.put("e_mail", "");
      mapPatContactInfo.put("zip_cd", "");
      mapPatContactInfo.put("address", "");
      mapPatContactInfo.put("work_tel", "");
      mapPatContactInfo.put("work_name", "");
      mapPatContactInfo.put("work_address", "");
      JSONObject jsonPatContactInfo = new JSONObject(mapPatContactInfo);
      patPersonalMain.setPat_contact_info(jsonPatContactInfo.toString().replace("\"\"", "null"));
    }
    return patPersonalMain;
  }

  private PatMain getPatMain(PatMain patMain, String facility_cd) throws Exception {
    if (patMain.getIs_same() == null) {
      patMain.setIs_same("0");
    }
    if (patMain.getIs_implant() == null) {
      patMain.setIs_implant("0");
    }
    if (patMain.getIs_infect() == null) {
      patMain.setIs_infect("0");
    }
    if (patMain.getIs_diabetes() == null) {
      patMain.setIs_diabetes("0");
    }
    if (patMain.getIs_blood_suger_exam() == null) {
      patMain.setIs_blood_suger_exam("0");
    }
    if (patMain.getIs_del() == null) {
      patMain.setIs_del("0");
    }
    if (patMain.getIs_wheel_chair() == null) {
      patMain.setIs_wheel_chair("0");
    }
    if (patMain.getSch_ext_status() == null) {
      patMain.setSch_ext_status("0");
    }
    if (patMain.getCharge_staff_info() == null) {
      patMain.setCharge_staff_info("[]");
    }
    if (patMain.getPat_group_info() == null) {
      patMain.setPat_group_info("[]");
    }
    if (patMain.getTaboo_allergy_info() == null) {
      patMain.setTaboo_allergy_info("[]");
    }
    if (patMain.getImplant_info() == null) {
      patMain.setImplant_info("[]");
    }

// mod 2021-09-30 CSI連携ができない(患者プロファイル) 孫 start
//    if (patMain.getDevice_set_info() == null) {
    if (patMain.getDevice_set_info() == null || "{}".equals(patMain.getDevice_set_info())) {
// mod 2021-09-30 CSI連携ができない(患者プロファイル) 孫 end
      //装置設定値(マスタ)取得
      String mstDeviceSetInfo = mstDeviceSetInfoDefaultDao.selectDeviceSetInfo(facility_cd);
      JSONObject jsonMstDeviceSetInfo = new JSONObject(mstDeviceSetInfo);
      Object pat = jsonMstDeviceSetInfo.get("pat");
      patMain.setDevice_set_info(pat.toString());
    }

// mod 2021-09-30 CSI連携ができない(患者プロファイル) 孫 start
//    if (patMain.getPat_memo_info() == null) {
    if (patMain.getPat_memo_info() == null || "[]".equals(patMain.getPat_memo_info())) {
// mod 2021-09-30 CSI連携ができない(患者プロファイル) 孫 end
      MstPatMemo params = new MstPatMemo();
      params.setFacilityCd(facility_cd);
      Pageable pageable = generatePageRequest(null, null);
      Page<MstPatMemo> page = findMstPatMemoAll(pageable, params);
      List<MstPatMemo> mstPatMemo = page.getContent();
      List<String> patMemoTemplate = new ArrayList();
      for (MstPatMemo patMemo : mstPatMemo) {
        Map<String, Object> map = new HashMap();
        map.put("ctl_no", patMemo.getPatMemoNo()==null?"":patMemo.getPatMemoNo());
        map.put("title", patMemo.getTitle()==null?"":patMemo.getTitle());
        map.put("content", patMemo.getContent()==null?"":patMemo.getContent());
        JSONObject json = new JSONObject(map);
        patMemoTemplate.add(json.toString());
      }
      patMain.setPat_memo_info(patMemoTemplate.toString().replace("\"\"", "null"));
    }

// mod 2021-09-30 CSI連携ができない(患者プロファイル) 孫 start
//    if (patMain.getTare_info() == null || patMain.getOff_water_info() == null) {
    if (patMain.getTare_info() == null || "{}".equals(patMain.getTare_info())
      || patMain.getOff_water_info() == null || "{}".equals(patMain.getOff_water_info())) {
// mod 2021-09-30 CSI連携ができない(患者プロファイル) 孫 end
      List<String> tareAndOffWater = selectTareAndOffWater(facility_cd, null, null, null);
      JSONObject jsonTareAndOffWater = new JSONObject(tareAndOffWater.get(0));
// mod 2021-09-30 CSI連携ができない(患者プロファイル) 孫 start
//      if (patMain.getTare_info() == null) {
      if (patMain.getTare_info() == null || "{}".equals(patMain.getTare_info())) {
// mod 2021-09-30 CSI連携ができない(患者プロファイル) 孫 end
        Object tare_info = jsonTareAndOffWater.get("tare_info");
        JSONObject jsonT = new JSONObject(tare_info.toString());
        Map<String, Object> mapTareInfo = new HashMap();
        mapTareInfo.put("1", jsonT);
        mapTareInfo.put("2", jsonT);
        mapTareInfo.put("3", jsonT);
        mapTareInfo.put("4", jsonT);
        mapTareInfo.put("5", jsonT);
        mapTareInfo.put("6", jsonT);
        mapTareInfo.put("7", jsonT);
        JSONObject jsonTareInfo = new JSONObject(mapTareInfo);
        patMain.setTare_info(jsonTareInfo.toString());
      }
// mod 2021-09-30 CSI連携ができない(患者プロファイル) 孫 start
//      if (patMain.getOff_water_info() == null) {
      if (patMain.getOff_water_info() == null || "{}".equals(patMain.getOff_water_info())) {
// mod 2021-09-30 CSI連携ができない(患者プロファイル) 孫 end
        Object off_water_info = jsonTareAndOffWater.get("off_water_info");
        JSONObject jsonO = new JSONObject(off_water_info.toString());
        Map<String, Object> mapOffWaterInfo = new HashMap();
        mapOffWaterInfo.put("1", jsonO);
        mapOffWaterInfo.put("2", jsonO);
        mapOffWaterInfo.put("3", jsonO);
        mapOffWaterInfo.put("4", jsonO);
        mapOffWaterInfo.put("5", jsonO);
        mapOffWaterInfo.put("6", jsonO);
        mapOffWaterInfo.put("7", jsonO);
        JSONObject jsonOffWaterInfo = new JSONObject(mapOffWaterInfo);
        patMain.setOff_water_info(jsonOffWaterInfo.toString());
      }
    }
// mod 2021-10-09 #6679:CSI連携：新患登録時、初期展開データが反映されない。 孫 start
//    if (patMain.getAddition_info() == null) {
//      patMain.setAddition_info("[]");
//    }
    // 加算情報
    if (patMain.getAddition_info() == null || "[]".equals(patMain.getAddition_info())) {
      List<String> additionInfo = new ArrayList();
// mod 2021-12-23 #6679:CSI連携：新患登録時、初期展開データが反映されない。 孫 start
//      int[] additionCdList = new int[] {1,2,3,18,52,53,54,55,56,57};
      // 加算情報のデフォルトを取得する
      int[] additionCdList = new int[0];
      int addCnt = 0;
      List<MstAddition> mstAdditionList = mstAdditionDao.selectByFacilityCd(facility_cd);
      if (mstAdditionList != null && mstAdditionList.size() > 0) {
        additionCdList = new int[mstAdditionList.size()];
        for (int i=0; i<mstAdditionList.size(); i++) {
          // のみ自動データを追加する
          // 種別区分:'12'：汎用
          String additionClass = mstAdditionList.get(i).getAdditionClass();
          // 登録区分:'1':自動、'2':手動
          String additionKind = mstAdditionList.get(i).getAdditionKind();
          if ("12".equals(additionClass) && !"1".equals(additionKind)) {
            // [自動]以外データ
            continue;
          }
          additionCdList[addCnt] = (int)((Long)mstAdditionList.get(i).getAdditionCd()).longValue();
          addCnt++;
        }
      }
// mod 2021-12-23 #6679:CSI連携：新患登録時、初期展開データが反映されない。 孫 end
      String nowDateTime = DateTimeUtils.getDateString_iso8601(new Date());
      for (int i=0; i<addCnt; i++) {
        Map<String, Object> mapInfo = new HashMap();
        mapInfo.put("cd", additionCdList[i]);
        mapInfo.put("reg_date", nowDateTime);
        mapInfo.put("is_enable", "1");
        JSONObject json = new JSONObject(mapInfo);
        additionInfo.add(json.toString());
      }
      patMain.setAddition_info(additionInfo.toString());
    }
// mod 2021-10-09 #6679:CSI連携：新患登録時、初期展開データが反映されない。 孫 end
    if (patMain.getInfect_info() == null) {
      patMain.setInfect_info("[]");
    }
    if (patMain.getAcceptance_status_info() == null) {
      patMain.setAcceptance_status_info("[]");
    }
// mod 2021-09-30 CSI連携ができない(患者プロファイル) 孫 start
//    if (patMain.getMedical_care_info() == null) {
    if (patMain.getMedical_care_info() == null || "{}".equals(patMain.getMedical_care_info())) {
// mod 2021-09-30 CSI連携ができない(患者プロファイル) 孫 end
      Map<String, Object> mapMedicalCareInfo = new HashMap();
      mapMedicalCareInfo.put("ward_cd", "");
      mapMedicalCareInfo.put("facility_cd", "");
      mapMedicalCareInfo.put("dialysis_count", "");
      mapMedicalCareInfo.put("main_course_cd", "");
      mapMedicalCareInfo.put("dialysis_course_cd", "");
      mapMedicalCareInfo.put("purification_count", "");
      mapMedicalCareInfo.put("pat_dialysis_count", "");
      mapMedicalCareInfo.put("dialysis_start_date", "");
      mapMedicalCareInfo.put("hospital_start_date", "");
      JSONObject jsonMedicalCareInfo = new JSONObject(mapMedicalCareInfo);
      patMain.setMedical_care_info(jsonMedicalCareInfo.toString().replace("\"\"", "null"));
    }
// mod 2021-10-09 #6679:CSI連携：新患登録時、初期展開データが反映されない。 孫 start
//    // add 2021-06-10 #5267  受信時の変換処理について（空白対応） wangchen start
//    if (patMain.getOff_water_info() == null) {
//      patMain.setOff_water_info("[]");
//    }
//    if (patMain.getHost_notification_info() == null) {
//      patMain.setHost_notification_info("[]");
//    }
//    // add 2021-06-10 #5267  受信時の変換処理について（空白対応） wangchen end
    // ホスト報知情報
    if (patMain.getHost_notification_info() == null || "{}".equals(patMain.getHost_notification_info())) {
      Map<String, Object> mapLowerUpper = new HashMap();
      mapLowerUpper.put("judge", false);
      mapLowerUpper.put("lower", 0);
      mapLowerUpper.put("upper", 0);
      Map<String, Object> mapInterval = new HashMap();
      mapInterval.put("judge", false);
      mapInterval.put("interval", 0);
      // 除水速度(L/h)
      Map<String, Object> mapUfr = new HashMap();
      mapUfr.put("judge", false);
      mapUfr.put("lower", 0);
      mapUfr.put("upper", 0.1);
      // Na濃度(mEq/L)
      Map<String, Object> mapNaConc = new HashMap();
      mapNaConc.put("judge", false);
      mapNaConc.put("lower", 120);
      mapNaConc.put("upper", 120);
      // 血流量(mL/min)
      Map<String, Object> mapBloodFlow = new HashMap();
      mapBloodFlow.put("judge", false);
      mapBloodFlow.put("lower", 40);
      mapBloodFlow.put("upper", 40);
      // 透析液温度(℃)
      Map<String, Object> mapDialysTemp = new HashMap();
      mapDialysTemp.put("judge", false);
      mapDialysTemp.put("lower", 33);
      mapDialysTemp.put("upper", 33);

      Map<String, Object> mapHostNotificationInfo = new HashMap();
      mapHostNotificationInfo.put("ap", mapLowerUpper);
      mapHostNotificationInfo.put("vp", mapLowerUpper);
      mapHostNotificationInfo.put("ufr", mapUfr);
      mapHostNotificationInfo.put("bpmi", mapInterval);
      mapHostNotificationInfo.put("ldqb", mapLowerUpper);
      mapHostNotificationInfo.put("pulse", mapLowerUpper);
      mapHostNotificationInfo.put("bp_ave", mapLowerUpper);
      mapHostNotificationInfo.put("bp_max", mapLowerUpper);
      mapHostNotificationInfo.put("bp_min", mapLowerUpper);
      mapHostNotificationInfo.put("care_i", mapInterval);
      mapHostNotificationInfo.put("na_conc", mapNaConc);
      mapHostNotificationInfo.put("d_bv_roc", mapLowerUpper);
      mapHostNotificationInfo.put("ip_speed", mapLowerUpper);
      mapHostNotificationInfo.put("blood_flow", mapBloodFlow);
      mapHostNotificationInfo.put("dialys_temp", mapDialysTemp);

      JSONObject jsonHostNotificationInfo = new JSONObject(mapHostNotificationInfo);
      patMain.setHost_notification_info(jsonHostNotificationInfo.toString());
    }
// mod 2021-10-09 #6679:CSI連携：新患登録時、初期展開データが反映されない。 孫 end
    return patMain;
  }

  private PatUnique getPatUnique(PatUnique patUnique) {
    if (patUnique.getMedical_hst_info() == null) {
      patUnique.setMedical_hst_info("[]");
    }
    // add 2021-09-30 CSI連携ができない(患者プロファイル) 孫 start
    else if (!"[]".equals(patUnique.getMedical_hst_info())){
      String info = patUnique.getMedical_hst_info();
      patUnique.setMedical_hst_info(info.replace("\"\"", "null"));
    }
    // add 2021-09-30 CSI連携ができない(患者プロファイル) 孫 end
    if (patUnique.getIn_out_visit_history_info() == null) {
      patUnique.setIn_out_visit_history_info("[]");
    }
    // add 2021-09-30 CSI連携ができない(患者プロファイル) 孫 start
    else if (!"[]".equals(patUnique.getIn_out_visit_history_info())){
      String info = patUnique.getIn_out_visit_history_info();
      patUnique.setIn_out_visit_history_info(info.replace("\"\"", "null"));
    }
    // add 2021-09-30 CSI連携ができない(患者プロファイル) 孫 end
    if (patUnique.getPhysical_info() == null) {
      patUnique.setPhysical_info("[]");
    }
    // add 2021-09-30 CSI連携ができない(患者プロファイル) 孫 start
    else if (!"[]".equals(patUnique.getPhysical_info())){
      String info = patUnique.getPhysical_info();
      patUnique.setPhysical_info(info.replace("\"\"", "null"));
    }
    // add 2021-09-30 CSI連携ができない(患者プロファイル) 孫 end
    if (patUnique.getIs_del() == null) {
      patUnique.setIs_del("0");
    }
    return patUnique;
  }

  public Page<MstPatMemo> findMstPatMemoAll(Pageable pageable, MstPatMemo params) {
    SelectOptions selectOptions = SelectOptions.get();

    List<MstPatMemo> mstPatMemoList = mstPatMemoDao.selectAll(selectOptions, params);
    return new PageImpl<>(mstPatMemoList, pageable, selectOptions.getCount());
  }

  public static Pageable generatePageRequest(Integer offset, Integer limit) {
    return generatePageRequest(offset, limit, null);
  }

  private static Pageable generatePageRequest(Integer offset, Integer limit, Sort sort) {
    if (offset == null || offset < MIN_OFFSET) {
      offset = DEFAULT_OFFSET;
    }
    if (limit == null || limit > MAX_LIMIT) {
      limit = DEFAULT_LIMIT;
    }
    sort = sort == null ? Sort.unsorted() : sort; /* add by xugj 2023-07-27 [#9234] jdk8->aws jdk17 --start */
    return PageRequest.of(offset - 1, limit, sort);
  }

  /**
   * 風袋・除水データ取得
   *
   * @param pat_id
   * @return 抽出条件を満たした風袋・除水補正情報
   */
  @Transactional
  public List<String> selectTareAndOffWater(String facility_cd, Long pat_id, Long ord_no, Integer flgIndRst) throws Exception {
    List<String> payload = new ArrayList<String>();
    ObjectMapper mapper = new ObjectMapper();

    // 装置設定デフォルトマスタ
    if (null != facility_cd) {
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("装置設定デフォルトマスタ");
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
      logService.log(LogLevel.INFO, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 end
      List<DeviceSetInfo> listPatMain = mstDeviceSetInfoDefaultDao.selectTareAndOffWater(facility_cd);
      if (listPatMain.size() == 0) {
        //mod FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 start
        //EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage = new EventLogMessage();
        //mod FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 end
        eventLogMessage.setLogMessage("装置設定(風袋・除水補正)API: 指定されたfacility_cdのmst_device_set_info_defaultレコードが存在しません。(facility_cd: " + facility_cd + ")");
        eventLogMessage.setPatId(pat_id.toString());
        // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
        eventLogMessage.setInvokeClass(this.getClass().getName());
        // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
        logService.log(LogLevel.ERROR, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, "MstDeviceSetInfoDefaultDao/selectTareAndOffWater");
        throw new Exception();
      } else {
        payload.add(mapper.writeValueAsString(listPatMain.get(0)));
      }
    }

    // 患者情報
    if (null != pat_id) {
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("患者情報");
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
      logService.log(LogLevel.INFO, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 end
      List<DeviceSetInfo> listPatMain = patMainDao.selectTareAndOffWater(pat_id);
      if (listPatMain.size() == 0) {
        //mod FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 start
        //EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage = new EventLogMessage();
        //mod FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 end
        eventLogMessage.setLogMessage("装置設定(風袋・除水補正)API: 指定されたpat_idのpat_mainレコードが存在しません。(pat_id: " + pat_id + ")");
        eventLogMessage.setPatId(pat_id.toString());
        // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
        eventLogMessage.setInvokeClass(this.getClass().getName());
        // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
        logService.log(LogLevel.ERROR, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, "PatMainDao/selectTareAndOffWater");
        throw new Exception();
      } else {
        payload.add(mapper.writeValueAsString(listPatMain.get(0)));
      }
    }

    // 治療情報
    if (null != ord_no) {
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("治療情報");
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
      logService.log(LogLevel.INFO, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 end
      List<DeviceSetInfo> listOrdMain = ordMainDao.selectTareAndOffWater(ord_no, flgIndRst);
      if (listOrdMain.size() == 0) {
        //mod FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 start
        //EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage = new EventLogMessage();
        //mod FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 end
        eventLogMessage.setLogMessage("装置設定(風袋・除水補正)API: 指定されたord_noのord_mainレコードが存在しません。(ord_no: " + ord_no + ")");
        eventLogMessage.setPatId(pat_id.toString());
        // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
        eventLogMessage.setInvokeClass(this.getClass().getName());
        // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
        logService.log(LogLevel.ERROR, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, "OrdMainDao/selectTareAndOffWater");
        throw new Exception();
      } else {
        payload.add(mapper.writeValueAsString(listOrdMain.get(0)));
      }
    }

//     if (table_flag == 0) {
//       // 患者情報テーブルの風袋・除水データの取得
//       List<DeviceSetInfo> listPatMain = patMainDao.selectTareAndOffWater(id);
//       if (listPatMain.size() == 0) {
//         NtssLogger.LogOutput(this, LogLevel.ERROR, "装置設定(風袋・除水補正)API: 指定されたpat_idのpat_mainレコードが存在しません。(pat_id: " + id + ")");
//         throw new Exception();
//       } else {
//         payload.add(mapper.writeValueAsString(listPatMain.get(0)));
//       }
//     } else {
//       // 治療情報テーブルの風袋・除水データの取得
//       List<DeviceSetInfo> listOrdMain = ordMainDao.selectTareAndOffWater(id);
//       if (listOrdMain.size() == 0) {
//         NtssLogger.LogOutput(this, LogLevel.ERROR, "装置設定(風袋・除水補正)API: 指定されたord_noのord_mainレコードが存在しません。(ord_no: " + id + ")");
//         throw new Exception();
//       } else {
//         payload.add(mapper.writeValueAsString(listOrdMain.get(0)));
//       }
//     }
    return payload;
  }

  // add #10436 同姓同名フラグの更新時に対になる患者のpat_main_historyがinsertされていない zhuang start
  public void isSameToMoGo(Long patId) throws URISyntaxException {
    PatInfo patInfo = new PatInfo();
    patInfo.setIsSame("1");
    PatMain patMain = patMainDao.selectById(patId);
    patInfo.setPatMain(patMain);
    RestTemplate rt = new RestTemplate();
    URI uri = new URI(webApi + "/util/insertPatToMongo");
    RequestEntity<PatInfo> request = RequestEntity
      .put(uri)
      .contentType(MediaType.APPLICATION_JSON)
      .header("SSECCAYEK", "NTSS-NKK-ESM-TDC-YSK")
      .body(patInfo);
	// #9698 アプリケーションログの内容修正 20260328 mod yangxuewang start
    long start = System.currentTimeMillis();
    ResponseEntity<Object> response = rt.exchange(request, Object.class);
    long cost = System.currentTimeMillis() - start;
    Map<String, Object> map = new HashMap<>();
    map.put("logType", "RESTTEMPLATE-LOG");
    map.put("className", "jp.co.nikkiso.ntss.coop_api.service.PatientCaptureServiceImpl");
    map.put("methodName", "isSameToMoGo");
    map.put("method", request.getMethod());
    map.put("url", request.getUrl());
    map.put("headers", request.getHeaders().toSingleValueMap());
    map.put("requestParameter", request.getBody());
    map.put("status",response.getStatusCode());
    map.put("cost", cost);
    map.put("result",response.getBody());
    EventLogMessage restTemplateEventLogMessage = new EventLogMessage();
    restTemplateEventLogMessage.setLogMessage(toJson(map));
    logService.log(LogLevel.INFO, restTemplateEventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
    // #9698 アプリケーションログの内容修正 20260328 mod yangxuewang end
  }
  // add #10436 同姓同名フラグの更新時に対になる患者のpat_main_historyがinsertされていない zhuang end
}
