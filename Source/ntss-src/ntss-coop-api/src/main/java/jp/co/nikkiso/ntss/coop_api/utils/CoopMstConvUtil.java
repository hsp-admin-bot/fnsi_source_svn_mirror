package jp.co.nikkiso.ntss.coop_api.utils;

import tools.jackson.core.type.TypeReference;
import com.google.common.base.CaseFormat;
import jp.co.nikkiso.ntss.api.utils.ObjectMapperUtil;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.dao.Db6FunctionDao;
import jp.co.nikkiso.ntss.core.dao.MasterMaintenanceGenericDao;
import jp.co.nikkiso.ntss.core.dao.MstCoopIniDao;
import jp.co.nikkiso.ntss.core.dao.MstJobDao;
import jp.co.nikkiso.ntss.core.dao.MstKurDao;
import jp.co.nikkiso.ntss.core.dao.MstPersonalUserDao;
import jp.co.nikkiso.ntss.core.dao.MstSelectorDao;
import jp.co.nikkiso.ntss.core.dao.MstUserAuthenticationDao;
import jp.co.nikkiso.ntss.core.dao.MstUserDao;
import jp.co.nikkiso.ntss.core.dao.SysMasterDefineDao;
import jp.co.nikkiso.ntss.core.entity.MstJob;
import jp.co.nikkiso.ntss.core.entity.MstKur;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.entity.MstSelector;
import jp.co.nikkiso.ntss.core.entity.MstUser;
import jp.co.nikkiso.ntss.core.entity.MstUserAuthentication;
import jp.co.nikkiso.ntss.core.entity.SysMasterDefine;
import jp.co.nikkiso.ntss.core.entity.custom.MstCoopIniInfo;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import org.apache.commons.beanutils.BeanUtils;
import org.apache.commons.collections4.map.HashedMap;
import org.json.JSONArray;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.util.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.TimeZone;

import static jp.co.nikkiso.ntss.core.dao.MasterMaintenanceGenericDao.ALIAS_CODE;
import static jp.co.nikkiso.ntss.core.dao.MasterMaintenanceGenericDao.ALIAS_NAME;
import static jp.co.nikkiso.ntss.core.dao.MasterMaintenanceGenericDao.IS_DISP;
import static jp.co.nikkiso.ntss.core.dao.MasterMaintenanceGenericDao.IS_DEL;
import static jp.co.nikkiso.ntss.core.dao.MasterMaintenanceGenericDao.OPERATION;
import static jp.co.nikkiso.ntss.core.dao.MasterMaintenanceGenericDao.UP_DATE;
import static jp.co.nikkiso.ntss.core.dao.MasterMaintenanceGenericDao.ZONED_DATE_TIME_ISO8601;

/**
 * マスタで、外部連携の院内コードと本システムコードを変換します
 *
 */
@Component
public class CoopMstConvUtil {

  @Autowired
  private MstSelectorDao mstSelectorDao;

  @Autowired
  private SysMasterDefineDao sysMasterDefineDao;

  @Autowired
  private MasterMaintenanceGenericDao masterGenericDao;

  @Autowired
  private MstUserAuthenticationDao mstUserAuthenticationDao;
  @Autowired
  private MstUserDao mstUserDao;
  @Autowired
  private MstPersonalUserDao mstPersonalUserDao;
  @Autowired
  private MstJobDao mstJobDao;
  @Autowired
  private Db6FunctionDao db6FunctionDao;

  @Autowired
  private MstKurDao mstKurDao;

  //add 6996 profile連携で受信した禁忌情報登録 20221228 zhaoqi start
  @Autowired
  private MstCoopIniDao mstCoopIniDao;
  //add 6996 profile連携で受信した禁忌情報登録 20221228 zhaoqi end

  /**
   * 施設コードで、院内コードから本システムコードへの変換。
   *
   * @param facilityCd 施設コード
   * @param convType 変換種類
   * @param hospitalCd 院内コード
   * @param hospitalCdNames 院内コード名
   * @param mstCheckSettingList マスタチェック設定
   * @param masterDataSettingMap マスタデータ設定
   * @param data0Event 0件データの処理
   * @param freeHospitalCd フリー連携コード
   * @param key0 電子カルテ種別
   * @return 本システムコード
   */
  public String GetFnwCdByHospitalCd(String facilityCd, String convType, String hospitalCd, List<String> hospitalCdNames,
                                     List<Map<String, Object>> mstCheckSettingList, Map<String, String> masterDataSettingMap,
// mod 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//                                     String data0Event, String freeHospitalCd) {
                                     String data0Event, String freeHospitalCd, String key0) {
// mod 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
    if (StringUtils.isEmpty(facilityCd) || StringUtils.isEmpty(convType) || StringUtils.isEmpty(hospitalCd) || hospitalCdNames == null || hospitalCdNames.size() == 0) {
      String message = String.format("院内コードから本システムコードへ変換の場合、パラメータが不正または不足しています。施設コード:[%s] 変換種類:[%s] 院内コード:[%s] 院内コード名:[%s]",
        facilityCd, convType, hospitalCd, hospitalCdNames.toString());
      throw new NtssException(message);
    }

    // マスタ存在フラグ
    boolean mstExistsFlag = false;
    // 選択肢マスタ存在フラグ
    boolean selectorExistsFlag = false;
    // マスタチェック設定存在フラグ
    boolean mstCheckExistsFlag = false;
    // 本システムコード
    String fnwCd = "";

    try {
      // マスタチェック設定が有りか
      if (mstCheckSettingList != null && mstCheckSettingList.size() > 0) {
        mstCheckExistsFlag = true;
      }

      // TODO:7304
      // key0の利用の対応待ち

// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//      // 禁忌・アレルギーの場合、追加設定が有り場合、以下処理を実行する(富士通:患者プロファイル)
//      if ("mst_taboo_allergy".equals(convType) && mstCheckExistsFlag) {
//        // 院内コードから本システムコードへの変換（禁忌・アレルギー）
//        fnwCd = GetFnwCdByHospitalCdTaboo(facilityCd, convType, hospitalCd, hospitalCdNames, mstCheckSettingList,
//          masterDataSettingMap, freeHospitalCd);
//      } else if ("mst_personal_user".equals(convType)) {
//        // 利用者マスタの場合、以下処理を実行する(浄化申し込み・初回指示)
//        // 院内コードから本システムコードへの変換（利用者）
//        fnwCd = GetFnwCdByHospitalCdUser(facilityCd, convType, hospitalCd, hospitalCdNames, masterDataSettingMap);
//      } else if ("mst_kur".equals(convType)) {
//        // クールマスタの場合、以下処理を実行する(浄化申し込み・初回指示)
//        // 院内コードから本システムコードへの変換（クール）
//        fnwCd = GetFnwCdByHospitalCdKur(facilityCd, convType, hospitalCd, hospitalCdNames, masterDataSettingMap);
//      } else {
//        // 院内コードから本システムコードへの変換（標準）
//        fnwCd = GetFnwCdByHospitalCdNormal(facilityCd, convType, hospitalCd, hospitalCdNames, masterDataSettingMap, data0Event);
//      }
      // 禁忌・アレルギーの場合、追加設定が有り場合、以下処理を実行する(富士通:患者プロファイル)
      if ("mst_taboo_allergy".equals(convType) && mstCheckExistsFlag) {
        // 院内コードから本システムコードへの変換（禁忌・アレルギー）
        // mod 6996 【デグレ】profile連携で受信した禁忌情報登録 20230119 zhaoqi start
        fnwCd = GetFnwCdByHospitalCdTaboo(facilityCd, key0, convType, hospitalCd, hospitalCdNames, mstCheckSettingList,
          masterDataSettingMap, freeHospitalCd, data0Event);
        // mod 6996 【デグレ】profile連携で受信した禁忌情報登録 20230119 zhaoqi end
      } else if ("mst_personal_user".equals(convType)) {
        // 利用者マスタの場合、以下処理を実行する(浄化申し込み・初回指示)
        // 院内コードから本システムコードへの変換（利用者）
        fnwCd = GetFnwCdByHospitalCdUser(facilityCd, key0, convType, hospitalCd, hospitalCdNames, masterDataSettingMap);
      } else if ("mst_kur".equals(convType)) {
        // クールマスタの場合、以下処理を実行する(浄化申し込み・初回指示)
        // 院内コードから本システムコードへの変換（クール）
        fnwCd = GetFnwCdByHospitalCdKur(facilityCd, key0, convType, hospitalCd, hospitalCdNames, masterDataSettingMap);
      } else {
        // 院内コードから本システムコードへの変換（標準）
        fnwCd = GetFnwCdByHospitalCdNormal(facilityCd, key0, convType, hospitalCd, hospitalCdNames, masterDataSettingMap, data0Event);
      }
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
    } catch (NtssException ex) {
      throw ex;
    } catch (Exception ex) {
      String message = String.format("院内コードから本システムコードへの変換でエラーが発生しました。施設コード:[%s] 内容:[%s]", facilityCd, ex.getMessage());
      throw new NtssException(message + GetStackTrace(ex));
    }
    return fnwCd;
  }

  /**
   * 施設コードで、院内コードから本システムコードへの変換（クール）
   *
   * @param facilityCd 施設コード
   * @param key0 電子カルテ種別
   * @param convType 変換種類
   * @param hospitalCd 院内コード
   * @param hospitalCdNames 院内コード名
   * @param masterDataSettings マスタデータ設定
   * @return 本システムコード
   */
  private String GetFnwCdByHospitalCdKur(String facilityCd, String key0, String convType, String hospitalCd, List<String> hospitalCdNames,
                                         Map<String, String> masterDataSettings) {
    // 本システムコード
    String fnwCd = "";
    // コード名
    String fnwName = "連携" + hospitalCd;

    // マスタ存在フラグ
    boolean mstExistsFlag = false;

    try {
      // ①クールマスタから、院内コードより、本システムコードとコード名を取得する。
      List<MstKur> mstKurList = mstKurDao.selectByInHospitalCd1(facilityCd, hospitalCd);
      if (mstKurList != null && mstKurList.size() > 0) {
        MstKur mstKur = mstKurList.get(0);
        fnwCd = String.valueOf(((Integer) mstKur.getKurCd()).intValue());
        mstExistsFlag = true;
      }
    } catch (Exception ex) {
      String message = String.format("クールスタからデータの取得でエラーが発生しました。施設コード:[%s] 院内コード:[%s] 内容:[%s]", facilityCd, hospitalCd, ex.getMessage());
      throw new NtssException(message + GetStackTrace(ex));
    }

    // クールマスタデータが無し場合、新規追加する
    if (!mstExistsFlag) {
      // 登録時間取得
      java.sql.Timestamp regDate = new java.sql.Timestamp(System.currentTimeMillis());
      // クールマスタに登録してクールコード(シーケンス発行)を取得
      MstKur mstKur = new MstKur();
      // マスタデータ設定から、データを取得する
      if (masterDataSettings != null && masterDataSettings.size() > 0) {
        try {
          Map<String, String> dataMap = new HashMap<>();
          for (String key : masterDataSettings.keySet()) {
            String newKey = CaseFormat.LOWER_UNDERSCORE.to(CaseFormat.LOWER_CAMEL, key);
            dataMap.put(newKey, masterDataSettings.get(key));
          }
          BeanUtils.populate(mstKur, dataMap);
        } catch (Exception ex) {
          String message = String.format("マスタデータ設定からクールマスタデータの取得すでエラーが発生しました。施設コード:[%s] 内容:[%s]", facilityCd, ex.getMessage());
          throw new NtssException(message + GetStackTrace(ex));
        }
      }

      try {
        // mst_kur.kur_cdのシーケンス
        Integer nextSeqKurCd = mstKurDao.selectNextSeqKurCd();
        mstKur.setKurCd(nextSeqKurCd);
        mstKur.setFacilityCd(facilityCd);
        if (StringUtils.isEmpty(mstKur.getKurName())) {
          mstKur.setKurName(fnwName);
        }
        if (StringUtils.isEmpty(mstKur.getKurStandardStartTime()) && !StringUtils.isEmpty(mstKur.getKurStartTime())) {
          if ("0000".equals(mstKur.getKurStartTime())) {
            mstKur.setKurStandardStartTime("0800");
          } else if ("1200".equals(mstKur.getKurStartTime())) {
            mstKur.setKurStandardStartTime("1300");
          } else if ("1800".equals(mstKur.getKurStartTime())) {
            mstKur.setKurStandardStartTime("1900");
          } else {
            mstKur.setKurStandardStartTime(mstKur.getKurStartTime());
          }
        }
        mstKur.setInHospitalCd_1(hospitalCd);
        mstKur.setIsDel("0");
        mstKur.setRegDate(regDate);
        mstKur.setUpDate(regDate);

        mstKurDao.insert(facilityCd, mstKur);
      } catch (Exception ex) {
        String message = String.format("クールマスタの登録でエラーが発生しました。施設コード:[%s] 内容:[%s]", facilityCd, ex.getMessage());
        throw new NtssException(message + GetStackTrace(ex));
      }

      fnwCd = String.valueOf(((Integer)mstKur.getKurCd()).intValue());
    }

    // ②選択肢マスタから、本システムコードを追加する
    setMstSelector(facilityCd, convType, fnwCd, fnwName);
    return fnwCd;
  }

  /**
   * 施設コードで、院内コードから本システムコードへの変換（利用者）
   *
   * @param facilityCd 施設コード
   * @param key0 電子カルテ種別
   * @param convType 変換種類
   * @param hospitalCd 院内コード
   * @param hospitalCdNames 院内コード名
   * @param masterDataSettings マスタデータ設定
   * @return 本システムコード
   */
  private String GetFnwCdByHospitalCdUser(String facilityCd, String key0, String convType, String hospitalCd, List<String> hospitalCdNames,
                                          Map<String, String> masterDataSettings) {
    // 本システムコード
    String fnwCd = "";
    // コード名
    String fnwName = "連携" + hospitalCd;

    // マスタ存在フラグ
    boolean mstExistsFlag = false;
    // add 6996 profile連携で受信した禁忌情報登録 20230106 zhaoqi start
    String hospitalCdName = "";
    // add 6996 profile連携で受信した禁忌情報登録 20230106 zhaoqi end
    try {

      // add 6996 profile連携で受信した禁忌情報登録 20230106 zhaoqi start
      String key2 = convType.substring(4);
      key2 = key2.toUpperCase();
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//      List<MstCoopIniInfo> mstCoopIniInfoList = mstCoopIniDao.selectCoopIniInfoForNormal(facilityCd, "MST", key2);
      List<MstCoopIniInfo> mstCoopIniInfoList = mstCoopIniDao.selectCoopIniInfoForNormal(facilityCd, key0,"MST", key2);
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
      if (mstCoopIniInfoList != null && mstCoopIniInfoList.size() > 0) {
        MstCoopIniInfo mstCoopIniInfo = mstCoopIniInfoList.get(0);
        String val = mstCoopIniInfo.getVal();
        hospitalCdName = val;
      }
//      List<String> hospitalCdNameList = new ArrayList<>();
//      hospitalCdNameList.add(hospitalCdName);
//      List<String> dataList = getCodeFromMst(facilityCd, convType, hospitalCd, hospitalCdNameList);
//      // add 6996 profile連携で受信した禁忌情報登録 20230106 zhaoqi end
//      if (dataList != null && dataList.size() > 0) {
//        fnwCd = dataList.get(0);
//        if (!StringUtils.isEmpty(dataList.get(1))) {
//          fnwName = dataList.get(1);
//        }
//        mstExistsFlag = true;
//      }
      // add 6996 profile連携で受信した禁忌情報登録 20230106 zhaoqi end

      // ①利用者マスタから、院内コードより、本システムコードとコード名を取得する。
      // mod 7275 ini_dial連携で受信した依頼医名が利用者マスタの氏名と異なるとエラーになる 吉 start
//      String inHospitalCd2 = "";
//      if("in_hospital_cd_2".equals(hospitalCdName)){
//        inHospitalCd2 = hospitalCdName;
//      }
//      MstPersonalUser personalUser = mstPersonalUserDao.selectByInHospitalCds(facilityCd, inHospitalCd2, hospitalCd);
      MstUserAuthentication personalUser = mstUserAuthenticationDao.selectForLogin(hospitalCd,facilityCd);
      // mod 7275 ini_dial連携で受信した依頼医名が利用者マスタの氏名と異なるとエラーになる 吉 end
      if (personalUser != null) {
        fnwCd = String.valueOf(((Long) personalUser.getUserId()).longValue());
        mstExistsFlag = true;
      }
    } catch (Exception ex) {
      String message = String.format("利用者マスタからデータの取得でエラーが発生しました。施設コード:[%s] 院内コード:[%s] 内容:[%s]", facilityCd, hospitalCd, ex.getMessage());
      throw new NtssException(message + GetStackTrace(ex));
    }

    // 利用者マスタデータが無し場合、新規追加する
    if (!mstExistsFlag) {
      // 職種コード(医師)取得
      String jobCd = "";
      MstJob.DefaultMenuSettings defaultMenuSettings = null;
      String defaultAuthorizedAuthorities = null;
      try {
        List<MstJob> jobList = mstJobDao.selectAll(facilityCd);
        if (jobList != null && jobList.size() > 0) {
          for (MstJob jobInfo : jobList) {
            jobCd = String.valueOf(((Long) jobInfo.getJobCd()).longValue());
            String isDoctor = jobInfo.getIsDoctor();
            defaultMenuSettings = jobInfo.getDefaultMenuSettings();
            defaultAuthorizedAuthorities = jobInfo.getDefaultAuthorizedAuthorities();
            // '1':医師 か？
            if ("1".equals(isDoctor)) {
              break;
            }
          }
        }
      }catch (Exception ex) {
        String message = String.format("職種マスタから職種コード(医師)の取得でエラーが発生しました。施設コード:[%s] 内容:[%s]", facilityCd, ex.getMessage());
        throw new NtssException(message + GetStackTrace(ex));
      }
      // 登録時間取得
      java.sql.Timestamp regDate = new java.sql.Timestamp(System.currentTimeMillis());
      // 利用者名取得
      String defaultLastName = " ";
      String defaultFirstName = " ";
      String lastName = "";
      String firstName = "";
      //add 9390 NKK連携 profile（XML） 利用者マスタに登録された利用者の職種が常に医師になる zhaoqi 20230810 start
      String isMain = "";
      //add 9390 NKK連携 profile（XML） 利用者マスタに登録された利用者の職種が常に医師になる zhaoqi 20230810 end
      // マスタデータ設定から、データを取得する
      if (masterDataSettings != null && masterDataSettings.size() > 0) {
        if (masterDataSettings.containsKey("user_last_name") && !StringUtils.isEmpty(masterDataSettings.get("user_last_name"))) {
          lastName = masterDataSettings.get("user_last_name");
        }
        if (masterDataSettings.containsKey("user_first_name") && !StringUtils.isEmpty(masterDataSettings.get("user_first_name"))) {
          firstName = masterDataSettings.get("user_first_name");
        }
        //add 9390 NKK連携 profile（XML） 利用者マスタに登録された利用者の職種が常に医師になる zhaoqi 20230810 start
        if (masterDataSettings.containsKey("is_main") && !StringUtils.isEmpty(masterDataSettings.get("is_main"))) {
          isMain = masterDataSettings.get("is_main");
        }
        //add 9390 NKK連携 profile（XML） 利用者マスタに登録された利用者の職種が常に医師になる zhaoqi 20230810 end

        boolean splitFlag = false;
        String splitData = "";
        if (!StringUtils.isEmpty(lastName) && !StringUtils.isEmpty(firstName)) {
          // 両者 not null
          if (lastName.equals(firstName)) {
            splitData = lastName;
            splitFlag = true;
          }
        } else if (!StringUtils.isEmpty(lastName) && StringUtils.isEmpty(firstName)) {
          // のみlastName not null
          splitData = lastName;
          splitFlag = true;
        } else if (StringUtils.isEmpty(lastName) && !StringUtils.isEmpty(firstName)) {
          // のみfirstName not null
          splitData = firstName;
          splitFlag = true;
        } else {
          // 両者 null
          lastName = defaultLastName;
          firstName = defaultFirstName;
        }
        if (true == splitFlag && !StringUtils.isEmpty(splitData)) {
          String[] dataFull = splitData.split("　", 2);
          String[] dataHalf = splitData.split(" ", 2);

          if (2 == dataFull.length && 2 == dataHalf.length) {
            if (dataFull[0].length() < dataHalf[0].length()) {
              lastName = dataFull[0];
              firstName = dataFull[1];
            } else {
              lastName = dataHalf[0];
              firstName = dataHalf[1];
            }
          } else if (2 == dataFull.length && 1 == dataHalf.length) {
            lastName = dataFull[0];
            firstName = dataFull[1];
          } else if (1 == dataFull.length && 2 == dataHalf.length) {
            lastName = dataHalf[0];
            firstName = dataHalf[1];
          } else {
            lastName = dataHalf[0];
            firstName = defaultFirstName;
          }
        }
      }
      // ①利用者マスタに登録して利用者ID(シーケンス発行)を取得
      MstPersonalUser personalInfo = new MstPersonalUser();
      try {
        personalInfo.setFacilityCd(facilityCd);
        personalInfo.setUserType(0);
        personalInfo.setAdministrator(0);
        personalInfo.setUserLastName(StringUtils.isEmpty(lastName)?defaultLastName:lastName);
        personalInfo.setUserFirstName(StringUtils.isEmpty(firstName)?defaultFirstName:firstName);
//        add  7501 profile連携（XML）で受信した担当者コード・名称 関 start
//        del 7501 profile連携（XML）で受信した担当者コード・名称  関 start
//        personalInfo.setJobCd(db6FunctionDao.personalInfoEncrypto(jobCd));
//        del 7501 profile連携（XML）で受信した担当者コード・名称  関 end
        //add 9390 NKK連携 profile（XML） 利用者マスタに登録された利用者の職種が常に医師になる zhaoqi 20230810 start
        if("1".equals(isMain)){
          personalInfo.setJobCd(db6FunctionDao.personalInfoEncrypto(jobCd));
        }
        //add 9390 NKK連携 profile（XML） 利用者マスタに登録された利用者の職種が常に医師になる zhaoqi 20230810 end
        //del 9390 NKK連携 profile（XML） 利用者マスタに登録された利用者の職種が常に医師になる zhaoqi 20230810 start
//        personalInfo.setJobCd(db6FunctionDao.personalInfoEncrypto(jobCd));
        //del 9390 NKK連携 profile（XML） 利用者マスタに登録された利用者の職種が常に医師になる zhaoqi 20230810 end
//        add  7501 profile連携（XML）で受信した担当者コード・名称 関 end
        // mod 7275 ini_dial連携で受信した依頼医名が利用者マスタの氏名と異なるとエラーになる 吉 start
        // personalInfo.setInHospitalCd_1(hospitalCd);
//        personalInfo.setInHospitalCd_1("");
        // mod 7275 ini_dial連携で受信した依頼医名が利用者マスタの氏名と異なるとエラーになる 吉 start
        //add 6996 profile連携で受信した禁忌情報登録 20231306 zhaoqi start
        if("in_hospital_cd_2".equals(hospitalCdName)){
          personalInfo.setInHospitalCd_2(hospitalCd);
        }else{
          personalInfo.setInHospitalCd_1(hospitalCd);
        }
        //add 6996 profile連携で受信した禁忌情報登録 20231306 zhaoqi end
        personalInfo.setInfoDispToAdmin("0");
        personalInfo.setIsDisp("1");
        personalInfo.setIsDel("0");
        personalInfo.setRegDate(regDate);
        personalInfo.setUpDate(regDate);
        mstPersonalUserDao.insertNewUser(personalInfo);
        // ②@Insertでは暗号化項目が平文で登録されてしまうためユーザ苗字・ユーザ名を更新
        mstPersonalUserDao.updateUserName(personalInfo);
      } catch (Exception ex) {
        String message = String.format("利用者マスタ(mst_personal_user)の登録でエラーが発生しました。施設コード:[%s] 内容:[%s]", facilityCd, ex.getMessage());
        throw new NtssException(message + GetStackTrace(ex));
      }
      // 利用者マスタ(医療情報DB)に登録
      // 設定項目に初期値をセット
      try {
        MstUser.UserSettings usrSetting = new MstUser.UserSettings() {
          {
            setTheme(THEME_DEFAULT);
            setFontSize(FONT_SIZE_DEFAULT);
            setIsDispMenu(0);
            setUseFunctions(new ArrayList<>(Arrays.asList(CoreConstant.DEFAULT_PAT_FUNCTION)));
            setAuthorizedFunctions(new ArrayList<>(Arrays.asList(CoreConstant.DEFAULT_PAT_FUNCTION)));
            setInitialFunction(CoreConstant.DEFAULT_PAT_FUNCTION);
          }
        };
        if (!StringUtils.isEmpty(jobCd)) {
          usrSetting.setIsDispMenu(1);
          // デフォルトメニュー設定クラスが有りか
          if (defaultMenuSettings != null) {
            // 使用機能コード.
            List<String> useFunctions = defaultMenuSettings.getUseFunctions();
            if (useFunctions != null && useFunctions.size() > 0) {
              usrSetting.setUseFunctions(useFunctions);
              usrSetting.setAuthorizedFunctions(useFunctions);
            }
            // 初期表示機能コード.
            String initialFunction = defaultMenuSettings.getInitialFunction();
            if (!StringUtils.isEmpty(initialFunction)) {
              usrSetting.setInitialFunction(initialFunction);
            }
          }
          // 許可権限コード.
          if (!StringUtils.isEmpty(defaultAuthorizedAuthorities)) {
            String[] authorizedAuthorities = defaultAuthorizedAuthorities.split(",");
            List<String> authoritieList = new ArrayList<>();
            for (String tmpData : authorizedAuthorities) {
              if (!StringUtils.isEmpty(tmpData)) {
                authoritieList.add(tmpData);
              }
            }
            if (authoritieList.size() > 0) {
              usrSetting.setAuthorizedAuthorities(authoritieList);
            }
          }
        }
        MstUser userInfo = new MstUser();
        userInfo.setUserId(personalInfo.getUserId());
        userInfo.setFacilityCd(facilityCd);
        userInfo.setIsProvisional(0);
        userInfo.setUserSettings(usrSetting);
        userInfo.setIsDel("0");
        userInfo.setIsDisp("1");
        userInfo.setIsSetQrCode(0);
        userInfo.setUpDate(regDate);
        userInfo.setRegDate(regDate);
        mstUserDao.insertNewUser(userInfo);
      } catch (Exception ex) {
        String message = String.format("利用者マスタ(mst_user)の登録でエラーが発生しました。施設コード:[%s] 内容:[%s]", facilityCd, ex.getMessage());
        throw new NtssException(message + GetStackTrace(ex));
      }
      // 利用者マスタ(認証DB)に登録
      try {
        MstUserAuthentication authenticationInfo = new MstUserAuthentication() {
          {
            setUserId(personalInfo.getUserId());
            setFacilityCd(facilityCd);
            setDispUserId(hospitalCd);
            PasswordEncoder encoder = new BCryptPasswordEncoder();
            setUserPassword(encoder.encode(hospitalCd));
            setFailureCnt(0);
            setUpDate(regDate);
            setRegDate(regDate);
          }
        };
        mstUserAuthenticationDao.insertNewUser(authenticationInfo);
      } catch (Exception ex) {
        String message = String.format("利用者マスタ(mst_user_authentication)の登録でエラーが発生しました。施設コード:[%s] 内容:[%s]", facilityCd, ex.getMessage());
        throw new NtssException(message + GetStackTrace(ex));
      }

      fnwCd = String.valueOf(((Long)personalInfo.getUserId()).longValue());
    }

    // ②選択肢マスタから、本システムコードを追加する
    setMstSelector(facilityCd, convType, fnwCd, fnwName);
    return fnwCd;
  }

  /**
   * 施設コードで、院内コードから本システムコードへの変換（禁忌・アレルギー）
   *
   * @param facilityCd 施設コード
   * @param key0 電子カルテ種別
   * @param convType 変換種類
   * @param hospitalCd 院内コード
   * @param hospitalCdNames 院内コード名
   * @param mstCheckSettingList マスタチェック設定
   * @param masterDataSettings マスタデータ設定
   * @param freeHospitalCd フリー連携コード
   * @return 本システムコード
   */
  // mod 6996 【デグレ】profile連携で受信した禁忌情報登録 20230119 zhaoqi start
  private String GetFnwCdByHospitalCdTaboo(String facilityCd, String key0, String convType, String hospitalCd,
                                           List<String> hospitalCdNames, List<Map<String, Object>> mstCheckSettingList,
                                           Map<String, String> masterDataSettings, String freeHospitalCd, String data0Event) {
    // マスタ定義から、禁忌・アレルギーマスタのデータ取得
    SysMasterDefine sysMasterDefine = sysMasterDefineDao.selectByName(convType);
    if (sysMasterDefine == null) {
      String message = String.format("[連携電文設定マスタ->拡張設定->CoopHospitalConvUtil]の変換種類[%s]はマスタ定義にが設定されていません。", convType);
      throw new NtssException(message);
    }
    SysMasterDefine.ColumnInfo columnInfo = sysMasterDefine.getColumnInfo();
    if (columnInfo == null) {
      String message = String.format("マスタ物理名称が[%s]のデータはマスタ定義のカラム情報にが設定されていません。", convType);
      throw new NtssException(message);
    }

    // 本システムコード
    String fnwCd = "";

    String mstNameKey = CaseFormat.LOWER_UNDERSCORE.to(CaseFormat.LOWER_CAMEL, ALIAS_NAME);
    // 禁忌・アレルギーコード
    String tabooAllergyCd = "";
    // 禁忌・アレルギー存在フラグ
    boolean tabooAllergyExistsFlag = false;
    // フリーワード存在フラグ
    boolean freeWordExistsFlag = false;
    Map<String, Object> masterDataForUpdate = null;
    List<Map<String, Object>> detailInfoListForUpdate = null;
    // 禁忌・アレルギーの詳細部分の内容
    String mstFnwCd = "";

    // コード名を取得する
    String mstFnwName = "連携" + hospitalCd;
    if (masterDataSettings != null && masterDataSettings.containsKey(ALIAS_NAME)
      && !StringUtils.isEmpty(masterDataSettings.get(ALIAS_NAME))) {
      mstFnwName = masterDataSettings.get(ALIAS_NAME);
    }

    // '1'：薬剤、'2'：調製薬剤、'3'：医療材料、'4'：ダイアライザ、'5'：フリーワード、'6'：一般名処方
    String mstFnwClassCd = "5";

    //add 6996 profile連携で受信した禁忌情報登録 20221228 zhaoqi start
    //mod 7525 rst_dial連携（拡張）ヘッダON/OFF切り替え 20230105 卓 start
    List<Map<String, Object>> mstCheckSettingListNew = new ArrayList<Map<String, Object>>();
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//    List<MstCoopIniInfo> mstCoopIniInfoExtendsList = mstCoopIniDao.selectCoopIniInfoExtends(facilityCd, "TABOO_CD");
    List<MstCoopIniInfo> mstCoopIniInfoExtendsList = mstCoopIniDao.selectCoopIniInfoExtends(facilityCd, key0, "TABOO_CD");
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
    if (mstCoopIniInfoExtendsList != null && mstCoopIniInfoExtendsList.size() > 0) {
      for (int n = 0; n < mstCoopIniInfoExtendsList.size(); n++) {
        MstCoopIniInfo mstCoopIniInfoExtends = mstCoopIniInfoExtendsList.get(n);
        String key2 = mstCoopIniInfoExtends.getKey2();
        String value = mstCoopIniInfoExtends.getVal();
        List<String> valueList = new ArrayList<>();
        valueList.add(value);
        Map<String, Object> map = new HashMap<>();
        map.put(key2, valueList);
        mstCheckSettingListNew.add(map);
      }
      mstCheckSettingList = mstCheckSettingListNew;
    }
    //mod 7525 rst_dial連携（拡張）ヘッダON/OFF切り替え 20230105 卓 end
    //add 6996 profile連携で受信した禁忌情報登録 20221228 zhaoqi end

    // マスタチェック設定
    for (Map<String, Object> checkSetting : mstCheckSettingList) {
      for (String key : checkSetting.keySet()) {
        String mstConvType = key;
        List<String> mstHospitalCdNames = new ArrayList<>();
        List<String> tempList = ObjectMapperUtil.castToStringList(checkSetting.get(key));
        for (String valueTemp : tempList) {
          if (!StringUtils.isEmpty(valueTemp)) {
            mstHospitalCdNames.add(valueTemp);
          }
        }
        // 関連マスタから、院内コードより、本システムコードとコード名を取得する。
        List<String> dataList = getCodeFromMst(facilityCd, mstConvType, hospitalCd, mstHospitalCdNames);
        if (dataList != null && dataList.size() > 0) {
          mstFnwCd = dataList.get(0);
          // コード名
          String fnwName = dataList.get(1);
          if (StringUtils.isEmpty(fnwName)) {
            fnwName = mstFnwName;
          }
          if ("mst_medicine".equals(mstConvType)) { // 薬剤
            mstFnwClassCd = "1";
          } else if ("mst_equipment".equals(mstConvType)) { // 医療材料
            mstFnwClassCd = "3";
          } else if ("mst_dialyzer".equals(mstConvType)) { // ダイアライザ
            mstFnwClassCd = "4";
          } else { // その他
            String message = String.format("[連携電文設定マスタ->拡張設定->CoopHospitalConvUtil]の変換種類[%s]の[mst_check_settings]のKEYは[mst_medicine、mst_equipment、mst_dialyzer]以外を設定しません。", convType);
            throw new NtssException(message);
          }
          // 選択肢マスタから、本システムコードを追加する
          setMstSelector(facilityCd, mstConvType, mstFnwCd, fnwName);
          break;
        }
      }
      if (!StringUtils.isEmpty(mstFnwCd)) {
        break;
      }
    }


    // 禁忌・アレルギーマスタのデータを取得する
    List<Map<String, Object>> mstData = masterGenericDao.getMasterData(sysMasterDefine, facilityCd);
    if (mstData != null && mstData.size() > 0) {
      for (Map<String, Object> data : mstData) {
// add 2022-03-10 #6996:profile連携で受信した禁忌情報登録 孫 start
        // 表示フラグ と　削除フラグ
        Object isDisp = "";
        Object isDel = "";
        if (data.containsKey(IS_DISP) && !StringUtils.isEmpty(data.get(IS_DISP))) {
          isDisp = data.get(IS_DISP);
        }
        if (data.containsKey(IS_DEL) && !StringUtils.isEmpty(data.get(IS_DEL))) {
          isDel = data.get(IS_DEL);
        }
        if ((!StringUtils.isEmpty(isDisp) && "0".equals(isDisp)) || (!StringUtils.isEmpty(isDel) && "1".equals(isDel))) {
          continue;
        }
// add 2022-03-10 #6996:profile連携で受信した禁忌情報登録 孫 end

        if (StringUtils.isEmpty(mstFnwCd)) {
          // 関連マスタから、院内コードより、本システムコードが無し場合
          for (String hospitalCdName : hospitalCdNames) {
            String cdName = CaseFormat.LOWER_UNDERSCORE.to(CaseFormat.LOWER_CAMEL, hospitalCdName);
            if (data.containsKey(cdName) && data.get(cdName) != null) {
              String tmpInHospitalCd = data.get(cdName).toString();
              if (hospitalCd.equals(tmpInHospitalCd)) {
                tabooAllergyCd = data.get(ALIAS_CODE).toString();
                if (!StringUtils.isEmpty(tabooAllergyCd)) {
                  tabooAllergyExistsFlag = true;
                }
                break;
              }
            }
          }
          // 連携コードと一致する項目が有りの場合、
          if (true == tabooAllergyExistsFlag) {
            masterDataForUpdate = data;
            // 詳細を取得する
            if (data.containsKey("detailInfo") && data.get("detailInfo") != null) {
              String detailInfoTmp = data.get("detailInfo").toString();
              try {
                detailInfoListForUpdate = ObjectMapperUtil.readTypeReference(detailInfoTmp, new TypeReference<List<Map<String, Object>>>() {
                });
                for (Map<String, Object> detailInfo : detailInfoListForUpdate) {
                  String tmpName = detailInfo.get("name") == null ? "" : detailInfo.get("name").toString();
                  String tmpClassCd = detailInfo.get("classCd") == null ? "" : detailInfo.get("classCd").toString();
                  // チェックマスタにデータが無しの場合、「'5'：フリーワード」データをチェックする
                  if (mstFnwClassCd.equals(tmpClassCd) && tmpName.equals(mstFnwName)) {
                    freeWordExistsFlag = true;
                    break;
                  }
                }
              } catch (Exception ex) {
                String message = String.format("禁忌・アレルギーマスタ(%s)の項目[詳細]の内容[%s]はjson-list形式のデータではありません。[%s]",
                  convType, detailInfoTmp, ex.getMessage());
                throw new NtssException(message);
              }
            }
          }
        } else {
          // 関連マスタから、院内コードより、本システムコードが有り場合
          // 詳細を取得する
          if (data.containsKey("detailInfo") && data.get("detailInfo") != null) {
            String detailInfoTmp = data.get("detailInfo").toString();
            try {
              List<Map<String, Object>> detailInfoList = ObjectMapperUtil.readTypeReference(detailInfoTmp, new TypeReference<List<Map<String, Object>>>() {
              });
              for (Map<String, Object> detailInfo : detailInfoList) {
                String tmpCd = detailInfo.get("cd") == null ? "" : detailInfo.get("cd").toString();
                String tmpClassCd = detailInfo.get("classCd") == null ? "" : detailInfo.get("classCd").toString();
                // チェックマスタにデータが有り、「'1'：薬剤、'3'：医療材料、'4'：ダイアライザ」データをチェックする
                if (mstFnwClassCd.equals(tmpClassCd) && tmpCd.equals(mstFnwCd)) {
                  tabooAllergyCd = data.get(ALIAS_CODE).toString();
                  if (!StringUtils.isEmpty(tabooAllergyCd)) {
                    tabooAllergyExistsFlag = true;
                  }
                  break;
                }
              }
            } catch (Exception ex) {
              String message = String.format("禁忌・アレルギーマスタ(%s)の項目[詳細]の内容[%s]はjson-list形式のデータではありません。[%s]",
                convType, detailInfoTmp, ex.getMessage());
              throw new NtssException(message);
            }
          }
        }
        if (tabooAllergyExistsFlag) {
          break;
        }
      }
    }

    //del 6996 【デグレ】profile連携で受信した禁忌情報登録 20230130 zhaoqi start
    //mod 6996 profile連携で受信した禁忌情報登録 20230103 zhaoqi start
    // add 2022-03-10 #6996:profile連携で受信した禁忌情報登録 孫 start
    // 関連マスタから、院内コードより、本システムコードが無し場合(「'5'：フリーワード」データを追加するの場合)
//    if (StringUtils.isEmpty(mstFnwCd)) {
//      // 指定されたコードが存在する場合、null:空のデータを返します
//      if (!StringUtils.isEmpty(freeHospitalCd)) {
//        String[] freeCd = freeHospitalCd.split(",");
//        if (!Arrays.asList(freeCd).contains(hospitalCd)) {
//          //add 6996 profile連携で受信した禁忌情報登録 20221127 zhaoqi start
//          mstFnwClassCd = "5";
//          if (freeCd.length > 0) {
//            //fnwCd = fnwCd + "," + mstFnwClassCd + "," + hospitalCd;
//            hospitalCd = freeCd[0];
//          } else {
//            hospitalCd = "";
//          }
//          //add 6996 profile連携で受信した禁忌情報登録 20221127 zhaoqi end
//        }
//      }
//    }
    // add 2022-03-10 #6996:profile連携で受信した禁忌情報登録 孫 end
    //mod 6996 profile連携で受信した禁忌情報登録 20230103 zhaoqi end
    //del 6996 【デグレ】profile連携で受信した禁忌情報登録 20230130 zhaoqi end

    // 禁忌・アレルギーマスタデータが有りか
    if (tabooAllergyExistsFlag) {
      if (!freeWordExistsFlag) {
        fnwCd = tabooAllergyCd;
      }

      if (!freeWordExistsFlag && StringUtils.isEmpty(mstFnwCd)) {
        // フリーワードが無し、追加する
        Map<String, Object> item = new HashMap<>();
        item.put("cd", "null");
        item.put("name", mstFnwName);
        item.put("type", "null");
        item.put("classCd", "5");
        detailInfoListForUpdate.add(item);
        JSONArray jsonArrayItems = new JSONArray(detailInfoListForUpdate);
        masterDataForUpdate.put("detailInfo", jsonArrayItems.toString().replace("\"null\"", "null"));
        // 2:変更
        masterDataForUpdate.put(OPERATION, 2);
        // 更新日時
        SimpleDateFormat sf = new SimpleDateFormat(ZONED_DATE_TIME_ISO8601);
        sf.setTimeZone(TimeZone.getTimeZone(CoreConstant.DateTimeFormat.TIME_ZONE_ASIA_TOKYO));
        String dateString = sf.format(masterDataForUpdate.get(UP_DATE));
        masterDataForUpdate.put(UP_DATE, dateString);

        // マスタのデータが0件の場合、予定の「0件データの処理」を実行する
        // 予定の「0件データの処理」:error:異常情報を返し、create:新しいデータを作成し、null:空のデータを返します
        if (!StringUtils.isEmpty(data0Event)) {
          if ("error".equals(data0Event)) {
            // error:異常情報を返し
            String message = String.format("マスタテーブル[%s]の連携コード[%s]が[%s]のデータは存在しない。施設コード[%s]",
              convType, hospitalCdNames.get(0), hospitalCd, facilityCd);
            throw new NtssException(message);
          } else if ("null".equals(data0Event)) {
            return fnwCd + "," + mstFnwClassCd + "," + hospitalCd;
          }else{
            masterGenericDao.updateMasterData(masterDataForUpdate, sysMasterDefine);
          }
        }
      }
    } else {
      // 禁忌・アレルギーマスタデータが無しか
      Map<String, Object> masterData = new HashedMap();
      // マスタ定義のカラム情報より、項目を追加する
      for (SysMasterDefine.Field field : sysMasterDefine.getColumnInfo().getFields()) {
        String key = field.getFieldName();
        String newKey = CaseFormat.LOWER_UNDERSCORE.to(CaseFormat.LOWER_CAMEL, key);
        masterData.put(newKey, null);
      }
      // マスタデータ設定のデータより、項目を更新する
      if (masterDataSettings != null && masterDataSettings.size() > 0) {
        for (String key : masterDataSettings.keySet()) {
          String newKey = CaseFormat.LOWER_UNDERSCORE.to(CaseFormat.LOWER_CAMEL, key);
          masterData.put(newKey, masterDataSettings.get(key));
        }
      }

      // 名を取得する（無しの場合、設定する）
      if (masterData.containsKey(ALIAS_NAME) && !StringUtils.isEmpty(masterData.get(ALIAS_NAME))) {
        mstFnwName = masterData.get(ALIAS_NAME).toString();
      } else {
        masterData.put(ALIAS_NAME, mstFnwName);
      }

      // 禁忌・アレルギーマスタの詳細の内容を追加する
      List<Map<String, Object>> items = new ArrayList<>();
      Map<String, Object> item = new HashMap<>();
      // 「'5'：フリーワード」データを追加するの場合
      if (StringUtils.isEmpty(mstFnwCd)) {
        item.put("cd", "null");
        item.put("name", mstFnwName);
        item.put("type", "null");
        item.put("classCd", "5");
      } else {
        // 「'1'：薬剤、'3'：医療材料、'4'：ダイアライザ」データを追加するの場合
        item.put("cd", Long.valueOf(mstFnwCd));
        item.put("name", "");
        item.put("type", "null");
        item.put("classCd", mstFnwClassCd);
      }
      items.add(item);
      JSONArray jsonArrayItems = new JSONArray(items);
      masterData.put("detailInfo", jsonArrayItems.toString().replace("\"null\"", "null"));

      // 院内コードを設定する
      String hospitalCdKey = CaseFormat.LOWER_UNDERSCORE.to(CaseFormat.LOWER_CAMEL, hospitalCdNames.get(0));
      if (!masterData.containsKey(hospitalCdKey) || (masterData.containsKey(hospitalCdKey) && StringUtils.isEmpty(masterData.get(hospitalCdKey)))) {
        masterData.put(CaseFormat.LOWER_UNDERSCORE.to(CaseFormat.LOWER_CAMEL, hospitalCdNames.get(0)), hospitalCd);
      }
      // 共通項目を設定する
      masterData.put("isDisp", "1");
      masterData.put("isDel", "0");

      // マスタのデータが0件の場合、予定の「0件データの処理」を実行する
      // 予定の「0件データの処理」:error:異常情報を返し、create:新しいデータを作成し、null:空のデータを返します
      if (!StringUtils.isEmpty(data0Event)) {
        if ("error".equals(data0Event)) {
          // error:異常情報を返し
          String message = String.format("マスタテーブル[%s]の連携コード[%s]が[%s]のデータは存在しない。施設コード[%s]",
            convType, hospitalCdNames.get(0), hospitalCd, facilityCd);
          throw new NtssException(message);
        } else if ("null".equals(data0Event)) {
          return fnwCd + "," + mstFnwClassCd + "," + hospitalCd;
        }else{
          masterGenericDao.insertMasterData(masterData, sysMasterDefine, facilityCd);
        }
      }

      // 採番されたPK項目の値を取得(serial値)
      if ("1".equals(mstFnwClassCd) || "3".equals(mstFnwClassCd) || "4".equals(mstFnwClassCd)) {
        Long serialValue = masterGenericDao.selectCurrentSeq(masterGenericDao.getFieldName(ALIAS_CODE, sysMasterDefine), sysMasterDefine.getMasterPhysicalName());
        fnwCd = serialValue.toString();
      }
    }

    // 選択肢マスタから、本システムコードを追加する
    if (!StringUtils.isEmpty(fnwCd)) {
      setMstSelector(facilityCd, convType, fnwCd, mstFnwName);
    }
// mod 2022-02-09 #6996:profile連携で受信した禁忌情報登録 孫 start
    // 戻り値再作成
    fnwCd = fnwCd + "," + mstFnwClassCd + "," + hospitalCd;
// mod 2022-02-09 #6996:profile連携で受信した禁忌情報登録 孫 end
    return fnwCd;
  }
// mod 6996 【デグレ】profile連携で受信した禁忌情報登録 20230119 zhaoqi end
  /**
   * 施設コードで、院内コードから本システムコードへの変換（標準）
   *
   * @param facilityCd 施設コード
   * @param key0 電子カルテ種別
   * @param convType 変換種類
   * @param hospitalCd 院内コード
   * @param hospitalCdNames 院内コード名
   * @param masterDataSettings マスタデータ設定
   * @param data0Event 0件データの処理
   * @return 本システムコード
   */
  private String GetFnwCdByHospitalCdNormal(String facilityCd, String key0, String convType, String hospitalCd, List<String> hospitalCdNames,
                                            Map<String, String> masterDataSettings, String data0Event) {
    // 本システムコード
    String fnwCd = "";
    // コード名
    String fnwName = "連携" + hospitalCd;
    // マスタ存在フラグ
    boolean mstExistsFlag = false;

    // add 6996 profile連携で受信した禁忌情報登録 20230106 zhaoqi start
    String hospitalCdName = "";
    String key2 = convType.substring(4);
    key2 = key2.toUpperCase();
    //todo mst_treatment
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//    List<MstCoopIniInfo> mstCoopIniInfoList = mstCoopIniDao.selectCoopIniInfoForNormal(facilityCd, "MST", key2);
    List<MstCoopIniInfo> mstCoopIniInfoList = mstCoopIniDao.selectCoopIniInfoForNormal(facilityCd, key0, "MST", key2);
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
    if (mstCoopIniInfoList != null && mstCoopIniInfoList.size() > 0) {
      MstCoopIniInfo mstCoopIniInfo = mstCoopIniInfoList.get(0);
      hospitalCdName = mstCoopIniInfo.getVal();
    }
    if(StringUtils.isEmpty(hospitalCdName)){
      hospitalCdName = hospitalCdNames.get(0);
    }
    // add 6996 profile連携で受信した禁忌情報登録 20230106 zhaoqi end

    // ①関連マスタから、院内コードより、本システムコードとコード名を取得する。
    // del 6996 profile連携で受信した禁忌情報登録 20230106 zhaoqi start
//    List<String> dataList = getCodeFromMst(facilityCd, convType, hospitalCd, hospitalCdNames);
    // del 6996 profile連携で受信した禁忌情報登録 20230106 zhaoqi end
    // add 6996 profile連携で受信した禁忌情報登録 20230106 zhaoqi start
    List<String> hospitalCdNameList = new ArrayList<>();
    hospitalCdNameList.add(hospitalCdName);
    List<String> dataList = getCodeFromMst(facilityCd, convType, hospitalCd, hospitalCdNameList);
    // add 6996 profile連携で受信した禁忌情報登録 20230106 zhaoqi end
    if (dataList != null && dataList.size() > 0) {
      // マスタのデータが1件の場合、本システムコードを返す
      fnwCd = dataList.get(0);
      if (!StringUtils.isEmpty(dataList.get(1))) {
        fnwName = dataList.get(1);
      }
      mstExistsFlag = true;
    }

    if (!(dataList != null && dataList.size() > 0) || StringUtils.isEmpty(convType)) {
      // マスタのデータが0件の場合、予定の「0件データの処理」を実行する
      // 予定の「0件データの処理」:error:異常情報を返し、create:新しいデータを作成し、null:空のデータを返します
      if (!StringUtils.isEmpty(data0Event)) {
        if ("error".equals(data0Event)) {
          // error:異常情報を返し
          // del 6996 profile連携で受信した禁忌情報登録 20230106 zhaoqi start
//          String message = String.format("マスタテーブル[%s]の連携コード[%s]が[%s]のデータは存在しない。施設コード[%s]", convType, hospitalCdNames.toString(), hospitalCd, facilityCd);
          // del 6996 profile連携で受信した禁忌情報登録 20230106 zhaoqi end
          // add 6996 profile連携で受信した禁忌情報登録 20230106 zhaoqi start
          String message = String.format("マスタテーブル[%s]の連携コード[%s]が[%s]のデータは存在しない。施設コード[%s]", convType, hospitalCdName, hospitalCd, facilityCd);
          // add 6996 profile連携で受信した禁忌情報登録 20230106 zhaoqi end
          throw new NtssException(message);
        } else if ("null".equals(data0Event)) {
          // null:空のデータを返します
          return "";
        } else {
          // create:新しいデータを作成し
          mstExistsFlag = false;
        }
      }
    }

    // 関連マスタデータが無し場合、新規追加する
    if (!mstExistsFlag) {
      // マスタ定義の取得
      SysMasterDefine sysMasterDefine = sysMasterDefineDao.selectByName(convType);
      if (sysMasterDefine == null) {
        String message = String.format("[連携電文設定マスタ->拡張設定->CoopHospitalConvUtil]の変換種類[%s]はマスタ定義にが設定されていません。", convType);
        throw new NtssException(message);
      }

      Map<String, Object> masterData = new HashedMap();
      // マスタ定義のカラム情報より、項目を追加する
      for (SysMasterDefine.Field field : sysMasterDefine.getColumnInfo().getFields()) {
        String key = field.getFieldName();
        String newKey = CaseFormat.LOWER_UNDERSCORE.to(CaseFormat.LOWER_CAMEL, key);
        masterData.put(newKey, null);
      }
      // マスタデータ設定のデータより、項目を更新する
      if (masterDataSettings != null && masterDataSettings.size() > 0) {
        for(String key : masterDataSettings.keySet()) {
          String newKey = CaseFormat.LOWER_UNDERSCORE.to(CaseFormat.LOWER_CAMEL, key);
          if (masterData.containsKey(newKey)) {
            masterData.put(newKey, masterDataSettings.get(key));
          }
        }
      }

      // 名を取得する（無しの場合、設定する）
      if (masterData.containsKey(ALIAS_NAME)) {
        if (!StringUtils.isEmpty(masterData.get(ALIAS_NAME))) {
          fnwName = masterData.get(ALIAS_NAME).toString();
        } else {
          masterData.put(ALIAS_NAME, fnwName);
        }
      } else {
        String nameKey = "";
        // 加算・管理料マスタ
        if ("mst_addition".equals(convType)) {
          nameKey = CaseFormat.LOWER_UNDERSCORE.to(CaseFormat.LOWER_CAMEL, "addition_name");
        }
        if (!StringUtils.isEmpty(nameKey)) {
          if (masterData.containsKey(nameKey) && !StringUtils.isEmpty(masterData.get(nameKey))) {
            fnwName = masterData.get(nameKey).toString();
          } else {
            masterData.put(nameKey, fnwName);
          }
        }
      }

      // 禁忌・アレルギーマスタの場合、詳細の内容を追加する
      if ("mst_taboo_allergy".equals(convType)) {
        List<Map<String,Object>> items = new ArrayList<>();
        Map<String,Object> item = new HashMap<>();
        item.put("cd", "null");
        item.put("name", fnwName);
        item.put("type", "null");
        item.put("classCd", "5");
        items.add(item);
        JSONArray jsonArrayItems = new JSONArray(items);
        masterData.put("detailInfo",jsonArrayItems.toString().replace("\"null\"", "null"));
      }
      // 院内コードを設定する
      // del 6996 profile連携で受信した禁忌情報登録 20230106 zhaoqi start
//      String hospitalCdKey = CaseFormat.LOWER_UNDERSCORE.to(CaseFormat.LOWER_CAMEL, hospitalCdNames.get(0));
      // del 6996 profile連携で受信した禁忌情報登録 20230106 zhaoqi end
      // add 6996 profile連携で受信した禁忌情報登録 20230106 zhaoqi start
      String hospitalCdKey = CaseFormat.LOWER_UNDERSCORE.to(CaseFormat.LOWER_CAMEL, hospitalCdName);
      // add 6996 profile連携で受信した禁忌情報登録 20230106 zhaoqi end
      if (!masterData.containsKey(hospitalCdKey) || (masterData.containsKey(hospitalCdKey) && StringUtils.isEmpty(masterData.get(hospitalCdKey)))) {
        // del 6996 profile連携で受信した禁忌情報登録 20230106 zhaoqi start
//        masterData.put(CaseFormat.LOWER_UNDERSCORE.to(CaseFormat.LOWER_CAMEL, hospitalCdNames.get(0)), hospitalCd);
        // del 6996 profile連携で受信した禁忌情報登録 20230106 zhaoqi end
        // add 6996 profile連携で受信した禁忌情報登録 20230106 zhaoqi start
        masterData.put(CaseFormat.LOWER_UNDERSCORE.to(CaseFormat.LOWER_CAMEL, hospitalCdName), hospitalCd);
        // add 6996 profile連携で受信した禁忌情報登録 20230106 zhaoqi end
      }
      // 共通項目を設定する
      masterData.put("isDisp", "1");
      masterData.put("isDel", "0");

      masterGenericDao.insertMasterData(masterData, sysMasterDefine, facilityCd);
      // 採番されたPK項目の値を取得(serial値)
      Long serialValue = masterGenericDao.selectCurrentSeq(masterGenericDao.getFieldName(ALIAS_CODE, sysMasterDefine), sysMasterDefine.getMasterPhysicalName());
      fnwCd = serialValue.toString();
    }

    // ②選択肢マスタから、本システムコードを追加する
    setMstSelector(facilityCd, convType, fnwCd, fnwName);
    return fnwCd;
  }

  /**
   * 選択肢マスタのデータの設定処理
   *
   * @param facilityCd 施設コード
   * @param masterPhysicalName マスタ物理名称
   * @param code 選択肢コード
   * @param name 選択肢名称
   * @return 無し
   */
  private void setMstSelector(String facilityCd, String masterPhysicalName, String code, String name) {
    // 選択肢マスタ存在フラグ
    boolean selectorExistsFlag = false;

    MstSelector mstSelector = mstSelectorDao.selectByName(facilityCd, masterPhysicalName);
    if (mstSelector == null) {
      // 新規追加レコード
      mstSelector = new MstSelector();
      mstSelector.setFacilityCd(facilityCd);
      mstSelector.setMasterPhysicalName(masterPhysicalName);
      List<MstSelector.Item> items = new ArrayList<MstSelector.Item>();
      addItemList(items, Long.valueOf(code), name);
      MstSelector.OrderSettings orderSettings = new MstSelector.OrderSettings();
      orderSettings.setItems(items);
      mstSelector.setOrderSettings(orderSettings);
      mstSelectorDao.insert(mstSelector);
    } else {
      List<MstSelector.Item> items = (List<MstSelector.Item>) mstSelector.getOrderSettings().getItems();
      if (items == null) {
        items = new ArrayList<MstSelector.Item>();
      } else {
        for (MstSelector.Item item : items) {
          if (item.getCode() != null && ((Long)item.getCode()).equals(Long.valueOf(code))){
            selectorExistsFlag = true;
            break;
          }
        }
      }
      if (!selectorExistsFlag) {
        // 新規追加項目
        addItemList(items, Long.valueOf(code), name);
        MstSelector.OrderSettings orderSettings = new MstSelector.OrderSettings();
        orderSettings.setItems(items);
        mstSelector.setOrderSettings(orderSettings);
        mstSelectorDao.updateMstExamItemSelector(mstSelector);
      }
    }
  }

  /**
   * マスタセレクタItem追加.
   *
   * @param items
   * @param code
   * @param name
   */
  private void addItemList(List<MstSelector.Item> items, Long code, String name) {

    MstSelector.Item item = new MstSelector.Item();
    item.setCode(code);
    item.setName(name);
    item.setJlac10Cd(null);
    items.add(item);
  }

  /**
   * マスタから、データを取得する
   *
   * @param facilityCd 施設コード
   * @param convType 変換種類
   * @param hospitalCd 院内コード
   * @param hospitalCdNames 院内コード名
   * @return 本システムコードとコード名
   */
  private List<String> getCodeFromMst(String facilityCd, String convType, String hospitalCd, List<String> hospitalCdNames) {
    List<String> dataList = new ArrayList<>();

    // マスタ定義の取得
    SysMasterDefine sysMasterDefine = sysMasterDefineDao.selectByName(convType);
    if (sysMasterDefine == null) {
      String message = String.format("[連携電文設定マスタ->拡張設定->CoopHospitalConvUtil]の変換種類[%s]はマスタ定義にが設定されていません。", convType);
      throw new NtssException(message);
    }
    SysMasterDefine.ColumnInfo columnInfo = sysMasterDefine.getColumnInfo();
    if (columnInfo == null) {
      String message = String.format("マスタ物理名称が[%s]のデータはマスタ定義のカラム情報にが設定されていません。", convType);
      throw new NtssException(message);
    }
    // 関連マスタデータを取得する
    List<Map<String, Object>> mstData = masterGenericDao.getMasterDataCoop(sysMasterDefine, facilityCd);
    if (mstData != null && mstData.size() > 0) {
      for (Map<String, Object> data : mstData) {
        for (String hospitalCdName : hospitalCdNames) {
          String cdName = CaseFormat.LOWER_UNDERSCORE.to(CaseFormat.LOWER_CAMEL, hospitalCdName);
          if (data.containsKey(cdName)) {
            Object value = data.get(cdName);
            // 表示フラグ と　削除フラグ
            Object isDisp = "";
            Object isDel = "";
            if (data.containsKey(IS_DISP) && !StringUtils.isEmpty(data.get(IS_DISP))) {
              isDisp = data.get(IS_DISP);
            }
            if (data.containsKey(IS_DEL) && !StringUtils.isEmpty(data.get(IS_DEL))) {
              isDel = data.get(IS_DEL);
            }
            if ((value != null && hospitalCd.equals(value.toString()))
              && (!StringUtils.isEmpty(isDisp) && "1".equals(isDisp))
              && (!StringUtils.isEmpty(isDel) && "0".equals(isDel))) {

              dataList.add(data.get(ALIAS_CODE).toString());
              if (data.containsKey(ALIAS_NAME) && !StringUtils.isEmpty(data.get(ALIAS_NAME))) {
                dataList.add(data.get(ALIAS_NAME).toString());
              } else {
                dataList.add("");
              }
              break;
            }
          }
        }
        if (dataList != null && dataList.size() > 0) {
          break;
        }
      }
    }
    return dataList;
  }

  /**
   * ExceptionのStackTraceInfo
   *
   * @param ex
   * @return 追加error
   */
  private String GetStackTrace(Exception ex) {
    String errAdd = "";
    StackTraceElement[] list = null;
    if (ex.getCause() != null && ex.getCause().getStackTrace() != null
      && ex.getCause().getStackTrace().length > 0) {
      list = ex.getCause().getStackTrace();
      for (StackTraceElement err : list) {
        if (err != null && err.toString().startsWith("jp.co.")) {
          errAdd = errAdd + "\r\n" + err.toString();
        }
      }
    }
    if (org.springframework.util.StringUtils.isEmpty(errAdd)) {
      list = ex.getStackTrace();
      for (StackTraceElement err : list) {
        if (err != null && err.toString().startsWith("jp.co.")) {
          errAdd = errAdd + "\r\n" + err.toString();
        }
      }
    }
    return errAdd;
  }
}
