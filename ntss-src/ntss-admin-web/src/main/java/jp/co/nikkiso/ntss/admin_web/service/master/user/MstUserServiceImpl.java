package jp.co.nikkiso.ntss.admin_web.service.master.user;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
// #12625 2026.05.13 add DE通知の一括化・重複排除 TDC高村 start
import java.util.LinkedHashSet;
import java.util.Set;
// #12625 2026.05.13 add DE通知の一括化・重複排除 TDC高村 end
import java.util.stream.Collectors;

import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.FacilitySettingService;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.logevent.DataUpdateLogCommonNew;
import jp.co.nikkiso.ntss.core.logevent.LogServiceCore;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import org.json.JSONObject;
import org.seasar.doma.jdbc.Config;
import org.seasar.doma.jdbc.SelectOptions;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;
// #12625 2026.05.13 add 利用者削除時に仮想端末スタッフ一覧から対象ユーザーを削除 start
import org.springframework.context.annotation.Lazy;
// #12625 2026.05.13 add 利用者削除時に仮想端末スタッフ一覧から対象ユーザーを削除 end

import tools.jackson.databind.JsonNode;
import tools.jackson.databind.ObjectMapper;
import tools.jackson.databind.node.ArrayNode;
import tools.jackson.databind.node.ObjectNode;
import com.google.common.base.CaseFormat;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebMessage;
import jp.co.nikkiso.ntss.admin_web.response.masterMaintenance.MasterColumn;
import jp.co.nikkiso.ntss.admin_web.response.masterMaintenance.MasterDataResponse;
import jp.co.nikkiso.ntss.admin_web.response.masterMaintenance.MasterUpdateResponse;
import jp.co.nikkiso.ntss.admin_web.service.master.facilitySetting.MstFacilitySettingService;
import jp.co.nikkiso.ntss.admin_web.service.sysSignManager.SysSigninManagerService;
import jp.co.nikkiso.ntss.admin_web.service.sysSignManager.SysSigninManagerService.ForceSignOutReason;
import jp.co.nikkiso.ntss.admin_web.service.utils.QRCodeUtils;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.TransactionManagerName;
import jp.co.nikkiso.ntss.core.dao.MstDestinationGroupDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilityDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilityHashDao;
import jp.co.nikkiso.ntss.core.dao.MstJobDao;
import jp.co.nikkiso.ntss.core.dao.MstPatHashDao;
import jp.co.nikkiso.ntss.core.dao.MstPersonalUserDao;
import jp.co.nikkiso.ntss.core.dao.MstSelectorDao;
import jp.co.nikkiso.ntss.core.dao.MstUserAuthenticationDao;
import jp.co.nikkiso.ntss.core.dao.MstUserDao;
import jp.co.nikkiso.ntss.core.dao.SysSystemDefineDao;
import jp.co.nikkiso.ntss.core.entity.MstDestinationGroup;
import jp.co.nikkiso.ntss.core.entity.MstFacility;
import jp.co.nikkiso.ntss.core.entity.MstFacilityHash;
import jp.co.nikkiso.ntss.core.entity.MstJob;
import jp.co.nikkiso.ntss.core.entity.MstJob.NotificationSettings;
import jp.co.nikkiso.ntss.core.entity.MstJob.NotificationSettingsValue;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.entity.MstSelector;
import jp.co.nikkiso.ntss.core.entity.MstSelector.Item;
import jp.co.nikkiso.ntss.core.entity.MstUser.PersonalSetting;
import jp.co.nikkiso.ntss.core.entity.MstUser.SettingValue;
import jp.co.nikkiso.ntss.core.entity.MstUser;
import jp.co.nikkiso.ntss.core.entity.MstUserOTP;
import jp.co.nikkiso.ntss.core.entity.MstUserAuthentication;
import jp.co.nikkiso.ntss.core.entity.SysMasterDefine.FieldType;
import jp.co.nikkiso.ntss.core.entity.SysSystemDefine;
import jp.co.nikkiso.ntss.core.entity.custom.MstUserData;
import jp.co.nikkiso.ntss.core.entity.SysMasterDefine.ComboValue;
import jp.co.nikkiso.ntss.admin_web.web.rest.util.TwoFactAuth;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.FlagType;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.SystemUseSetting;
import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
// #12625 2026.04.30 add 削除した利用者が仮想端末に表示する TDC高村 start
import jp.co.nikkiso.ntss.admin_web.service.deviceEdgeOrder.DeviceEdgeOrderService;
import jp.co.nikkiso.ntss.core.dao.MstComsvSettingDao;
import jp.co.nikkiso.ntss.core.entity.MstComsvSetting;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
// #12625 2026.04.30 add 削除した利用者が仮想端末に表示する TDC高村 end

import static jp.co.nikkiso.ntss.core.dao.MasterMaintenanceGenericDao.IS_DEL;
import static jp.co.nikkiso.ntss.core.dao.MasterMaintenanceGenericDao.IS_DISP;
import static jp.co.nikkiso.ntss.core.dao.MasterMaintenanceGenericDao.MODAL;
import static jp.co.nikkiso.ntss.core.dao.MasterMaintenanceGenericDao.OPERATION;
import static jp.co.nikkiso.ntss.core.dao.MasterMaintenanceGenericDao.SORT_INPUT_TIME;
import static jp.co.nikkiso.ntss.core.dao.MasterMaintenanceGenericDao.SORT_RANK;
import jp.co.nikkiso.ntss.core.config.DefaultDb;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

@Service
public class MstUserServiceImpl implements MstUserService {

  /**
   * KendoUI 数値項目の標準フォーマット(整数部のみ少数なし).
   */
  static final String NUMBER_FORMAT = "n0";

  /**
   * ソート用表示項目名.
   */
  static final String SORT_RANK_TITLE = "並び順";

  /**
   * レコード追加許可項目名.
   */
  static final String ALLOW_ADD_RECORD = "allowAddRecord";

  /**
   * レコード並び替え許可項目名.
   */
  static final String ALLOW_SORT = "allowSort";
  // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dou start
  // 施設設定マスタNo64:有効
  private static final String VALID = "1";
  //タブ定義 共通設定ID - 通知設定
  private static final int TAB_DEFINE_CD_NOTIFICATION_SETTING = 8;
  @Autowired
  private FacilitySettingService facilitySettingService;
  // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dou end

  /**
   * 利用者マスタのDaoインタフェース.
   */
  @Autowired
  private MstUserDao mstUserDao;

  /**
   * 利用者マスタ(認証DB)のDaoインタフェース.
   */
  @Autowired
  private MstUserAuthenticationDao mstUserAuthenticationDao;

  /**
   * 利用者マスタ(個人情報DB)のDaoインタフェース.
   */
  @Autowired
  private MstPersonalUserDao mstPersonalUserDao;

  /**
   * 施設マスタのDaoインタフェース.
   */
  @Autowired
  private MstFacilityDao mstFacilityDao;

  /**
   * 選択肢マスタのDaoインタフェース.
   */
  @Autowired
  private MstSelectorDao mstSelectorDao;

  /**
   * パスワードエンコーダ.
   */
  @Autowired
  private PasswordEncoder passwordEncoder;

  /**
   * 施設マスタハッシュのDaoインタフェース.
   */
  @Autowired
  private MstFacilityHashDao mstFacilityHashDao;

  /**
   * 患者用施設マスタハッシュのDaoインタフェース.
   */
  @Autowired
  private MstPatHashDao mstPatHashDao;

  /**
   * システム設定のDaoインタフェース.
   */
  @Autowired
  private SysSystemDefineDao sysSystemDefineDao;

  /**
   * 送信先グループマスタのDaoインタフェース.
   */
  @Autowired
  private MstDestinationGroupDao mstDestinationGroupDao;

  // #12625 2026.05.13 add 削除した利用者が仮想端末に表示する TDC高村 start
  /**
   * 装置通信・仮想端末マスタのDaoインタフェース.
   */
  @Autowired
  private MstComsvSettingDao mstComsvSettingDao;

  /**
   * デバイスエッジ指示Serviceインタフェース.
   */
  @Autowired
  private DeviceEdgeOrderService deviceEdgeOrderService;

  /**
   * 自身のSpring管理Beanへの参照.
   */
  @Lazy
  @Autowired
  private MstUserServiceImpl self;
  // #12625 2026.05.13 add 削除した利用者が仮想端末に表示する TDC高村 end

  /**
   * 職種マスタのDaoインタフェース.
   */
  @Autowired
  private MstJobDao mstJobDao;

  @Autowired
  private MstFacilitySettingService mstFacilitySettingService;

  /**
   * サインイン管理のServiceインターフェース
   */
  @Autowired
  SysSigninManagerService sysSigninManagerService;

  // DB更新ログ出力ロジック wangzuo Start
  @Autowired
  private EventLoggerFactory eventLoggerFactory;

  @Autowired
  private LogServiceCore logServiceCore;

  @Autowired
  @DefaultDb
  private Config defaultDbConfig;
  // DB更新ログ出力ロジック wangzuo End

  @Autowired
  private LogService logService;

  /**
   * {@inheritDoc}
   *
   */
  @Override
  public MasterDataResponse getMasterData(String facilityCd, boolean isOwnFacility) {

    //利用者マスタMaintenance
    MasterDataResponse masterResponse = new MasterDataResponse();

    // カラム情報の作成
    masterResponse.columns = makeMasterColumn(facilityCd);

    // スキーマのフィールド情報の作成
    masterResponse.localDataSource.schema.model.fields = makeMasterField();

    // 対象データ取得
    masterResponse.localDataSource.data = selectUserDataByFacilityCd(facilityCd, isOwnFacility);

    // 取得したデータの並び替え
    masterResponse.localDataSource.data = sortData(masterResponse.localDataSource.data, facilityCd);

    // 成功レスポンス返却
    return masterResponse;
  }


  /**
   * {@inheritDoc}
   *
   */
  @Override
  public MasterDataResponse getSortMasterData(String facilityCd, boolean isOwnFacility) {

    MasterDataResponse masterResponse = new MasterDataResponse();

    // カラム情報の作成
    masterResponse.columns = makeSortMasterColumn(facilityCd);

    // スキーマのフィールド情報の作成
    masterResponse.localDataSource.schema.model.fields = makeMasterField();

    // 対象データ取得
    masterResponse.localDataSource.data = selectUserDataByFacilityCd(facilityCd, isOwnFacility);

    // 取得したデータの並び替え
    masterResponse.localDataSource.data = sortData(masterResponse.localDataSource.data, facilityCd);

    // 成功レスポンス返却
    return masterResponse;
  }


  // 利用者一覧取得
  public List<Map<String, Object>> selectUserDataByFacilityCd(String facilityCd, boolean isOwnFacility) {

    // 施設コードを元に利用者マスタを取得
    List<MstUserAuthentication> userAuthenticationList = mstUserAuthenticationDao.selectByFacility(facilityCd);
    SelectOptions options = SelectOptions.get();
    List<MstPersonalUser> personalUser = mstPersonalUserDao.selectAll(options, facilityCd, "0");

    // 取得データをMstUserDataに統合
    List<Map<String, Object>> mstUserDataList = new ArrayList<Map<String, Object>>();
    /* add by chamaojia 2024-03-02 [10303、10304] add batch query methods to reduce the number of queries --start */
    List<Long> userIdList = userAuthenticationList.stream().map(u -> u.getUserId())
            .distinct().collect(Collectors.toList());
    Map<Long, MstUser> mstUserMap = mstUserDao.selectByListId(userIdList).stream()
            .collect(Collectors.toMap(m -> m.getUserId(), m -> m));
    /* add by chamaojia 2024-03-02 [10303、10304] add batch query methods to reduce the number of queries --end */
    for(MstUserAuthentication userAuthentication : userAuthenticationList){
      MstUserData tmpData = new MstUserData();
      tmpData.setUserId(userAuthentication.getUserId());
      tmpData.setFacilityCd(userAuthentication.getFacilityCd());
      tmpData.setFailure_cnt(userAuthentication.getFailureCnt());
      tmpData.setDispUserId(userAuthentication.getDispUserId());
      //add 9437 利用者カードを登録しても利用者マスタのカード無効化列にボタンが表示しない。関俊楠 start
      if (userAuthentication.getCardIdm() != null) {
        tmpData.setCardIdm("1");
      } else {
        tmpData.setCardIdm("0");
      }
      //add 9437 利用者カードを登録しても利用者マスタのカード無効化列にボタンが表示しない。関俊楠 end
      // 同じユーザIDのデータを検索
      Boolean foundPersonalUser = false;
      for(MstPersonalUser user : personalUser){
        if (tmpData.getUserId().equals(user.getUserId())) {
          foundPersonalUser = true;
          tmpData.setAdministrator(user.getAdministrator());
          tmpData.setPatientShared(user.getPatientShared() == null?0:user.getPatientShared());
          tmpData.setUserName(user.getUserLastName() + " " + user.getUserFirstName());
          tmpData.setJobCd(user.getJobCd());
          tmpData.setInHospitalCd_1(user.getInHospitalCd_1());
          tmpData.setInHospitalCd_2(user.getInHospitalCd_2());
          tmpData.setSigninDate(user.getSigninDate());

          // 自施設の場合のみ表示する情報
          if (isOwnFacility) {
            tmpData.setUserLastNameKana(user.getUserLastNameKana());
            tmpData.setUserFirstNameKana(user.getUserFirstNameKana());
            tmpData.setUserLastNameAlpha(user.getUserLastNameAlpha());
            tmpData.setUserFirstNameAlpha(user.getUserFirstNameAlpha());
            tmpData.setExtensionNo(user.getExtensionNo());
            // 自施設且つ、管理者への表示許可がある場合のみ表示する情報
            if (!StringUtils.isEmpty(user.getInfoDispToAdmin()) && user.getInfoDispToAdmin().equals("1")) {
//              add #9584 2023-9-8 lmf start
              tmpData.setUserEmailAddress1(user.getUserEmailAddress1());
              tmpData.setUserEmailAddress2(user.getUserEmailAddress2());
//              add #9584 2023-9-8 lmf end
              tmpData.setHomeNo(user.getHomeNo());
              tmpData.setMobilePhoneNo(user.getMobilePhoneNo());
              tmpData.setFaxNo(user.getFaxNo());
              String zipCd3 = StringUtils.isEmpty(user.getZipcd3()) ? "" : user.getZipcd3();
              String zipCd4 = StringUtils.isEmpty(user.getZipcd4()) ? "" : user.getZipcd4();
              tmpData.setZipcd7(zipCd3 + zipCd4);
              tmpData.setAddress(user.getAddress());
              tmpData.setAddressKana(user.getAddressKana());
//            add no3849 アカウント情報の管理者への表示を許可しない場合、マスキングされず非表示となる 張 start
            }else{
//              add #9584 2023-9-8 lmf start
              tmpData.setUserEmailAddress1(StringUtils.isEmpty(user.getUserEmailAddress1())?null:"*******");
              tmpData.setUserEmailAddress2(StringUtils.isEmpty(user.getUserEmailAddress2())?null:"*******");
//              add #9584 2023-9-8 lmf end
              tmpData.setHomeNo(StringUtils.isEmpty(user.getHomeNo())?null:"*******");
              tmpData.setMobilePhoneNo(StringUtils.isEmpty(user.getMobilePhoneNo())?null:"*******");
              tmpData.setFaxNo(StringUtils.isEmpty(user.getFaxNo())?null:"*******");
              String zipCd3 = StringUtils.isEmpty(user.getZipcd3()) ? "" : user.getZipcd3();
              String zipCd4 = StringUtils.isEmpty(user.getZipcd4()) ? "" : user.getZipcd4();
              tmpData.setZipcd7(StringUtils.isEmpty(zipCd3 + zipCd4)?null:"*******");
              tmpData.setAddress(StringUtils.isEmpty(user.getAddress())?null:"*******");
              tmpData.setAddressKana(StringUtils.isEmpty(user.getAddressKana())?null:"*******");
            }
//            add no3849 アカウント情報の管理者への表示を許可しない場合、マスキングされず非表示となる 張 end
          }
          break;
        }
      }

      // user_type=2 のデータなど、MstPersonalUserから取得しないデータは以降の処理を行わない
      if (!foundPersonalUser) {
        continue;
      }

      /* modify by chamaojia 2024-03-02 [10303、10304] add batch query methods to reduce the number of queries --start */
//      MstUser user = mstUserDao.selectById(tmpData.getUserId());
      MstUser user = mstUserMap.get(tmpData.getUserId());
      /* modify by chamaojia 2024-03-02 [10303、10304] add batch query methods to reduce the number of queries --end */

      tmpData.setIsProvisional(user.getIsProvisional());
//del 7328 IDｍが医療情報DBにて管理されている 関俊楠 start
//      if (user.getCardIdm() != null) {
//        tmpData.setCardIdm("1");
//      } else {
//        tmpData.setCardIdm("0");
//      }
//del 7328 IDｍが医療情報DBにて管理されている 関俊楠 end
      if (user.getPatId() == null) {
        tmpData.setPatFlg(false);
      } else {
        tmpData.setPatFlg(true);
      }
      if (user.getIsSetQrCode() == 0) {
        tmpData.setSecretKey("未設定");
      } else {
        tmpData.setSecretKey("設定済み");
      }
      List<String> lstAuthorities = new ArrayList<String>();
      if (user.getUserSettings() != null && user.getUserSettings().getAuthorizedAuthorities() != null){
        lstAuthorities = user.getUserSettings().getAuthorizedAuthorities();
      }

      // オブジェクトをHashMapに変換
      Map<String, Object> hashData = new HashMap<>();
      hashData.put("userId", tmpData.getUserId());
      hashData.put("facilityCd", tmpData.getFacilityCd());
      hashData.put("administrator", tmpData.getAdministrator());
      hashData.put("patientShared", tmpData.getPatientShared());
      hashData.put("userName", tmpData.getUserName());
      hashData.put("isProvisional", tmpData.getIsProvisional());
      hashData.put("failure_cnt", tmpData.getFailure_cnt());
      hashData.put("dispUserId", tmpData.getDispUserId());
      hashData.put("jobCd", tmpData.getJobCd());
      hashData.put("authorities", lstAuthorities);
      hashData.put("patFlg", tmpData.getPatFlg());
      hashData.put("userLastNameKana", tmpData.getUserLastNameKana());
      hashData.put("userFirstNameKana", tmpData.getUserFirstNameKana());
      hashData.put("userLastNameAlpha", tmpData.getUserLastNameAlpha());
      hashData.put("userFirstNameAlpha", tmpData.getUserFirstNameAlpha());
//      add #9584 2023-9-8 lmf start
      hashData.put("userEmailAddress1", tmpData.getUserEmailAddress1());
      hashData.put("userEmailAddress2", tmpData.getUserEmailAddress2());
//      add #9584 2023-9-8 lmf end
      hashData.put("extensionNo", tmpData.getExtensionNo());
      hashData.put("homeNo", tmpData.getHomeNo());
      hashData.put("mobilePhoneNo", tmpData.getMobilePhoneNo());
      hashData.put("faxNo", tmpData.getFaxNo());
      hashData.put("zipcd7", tmpData.getZipcd7());
      hashData.put("address", tmpData.getAddress());
      hashData.put("addressKana", tmpData.getAddressKana());
      hashData.put("secretKey", tmpData.getSecretKey());
      hashData.put("inHospitalCd_1", tmpData.getInHospitalCd_1());
      hashData.put("inHospitalCd_2", tmpData.getInHospitalCd_2());
      hashData.put("cardIdm", tmpData.getCardIdm());

      if (tmpData.getSigninDate() != null) {
        String signinDate = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss").format(tmpData.getSigninDate());
        hashData.put("signinDate", signinDate);
      }
      mstUserDataList.add(hashData);
    }

    return mstUserDataList;
  }

  // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
  @Override
  public MstUser getByUserId(long userId) {
    return mstUserDao.selectById(userId);
  }

  @Override
  public MstUserAuthentication selectMstUserAuthenticationByUserId(Long userId) {
    return mstUserAuthenticationDao.selectById(userId);
  }
  // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end

  /**
   * {@inheritDoc}
   */
  @Override
  public List<MstFacility> selectMstFacility() {
    List<MstFacility> mstFacilityList = mstFacilityDao.selectAllOrderBy("order by facility_cd");
    // system_use_setting の値を mstFacilityHashList の値で補正
    List<MstFacilityHash> mstFacilityHashList = mstFacilityHashDao.selectAll();
    for(MstFacility fObj : mstFacilityList) {
      for (MstFacilityHash hObj : mstFacilityHashList) {
        if (hObj.getFacilityCd().equals(fObj.getFacilityCd())) {
          fObj.setSystemUseSetting(hObj.getSystemUseSetting());
          break;
        }
      }
    }
    return mstFacilityList;
  }

  // add FNSI-メニューに共有ON／共有OFFを追加する 江 start
  /**
   * {@inheritDoc}
   */
  @Override
  public List<MstPersonalUser> selectPatientSharedFlgById(long userId) {
    List<MstPersonalUser> mstPersonalUserList = mstPersonalUserDao.selectPatientSharedFlgById(userId);
    return mstPersonalUserList;
  }
  // add FNSI-メニューに共有ON／共有OFFを追加する 江 end

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional(TransactionManagerName.ALL)
  public MasterUpdateResponse registNewUser(MstUserData mstUser)
  {
    // 登録時間取得
    java.sql.Timestamp regDt = getCurrentDate();

    // 利用者マスタに登録して利用者ID(シーケンス発行)を取得
    MstPersonalUser newPersonalUser = new MstPersonalUser() {
        {
          setFacilityCd(mstUser.getFacilityCd());
          setUserType(mstUser.getUserType());
          setAdministrator(mstUser.getAdministrator());
          setUserLastName(mstUser.getUserLastName());
          setUserFirstName(mstUser.getUserFirstName());
          setIsDel("0");
          setIsDisp("1");
          setUpDate(regDt);
          setRegDate(regDt);
        }
    };
    mstPersonalUserDao.insertNewUser(newPersonalUser);

    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
    LogEventUtils.setOperatorId(newPersonalUser,logService);
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
    // @Insertでは暗号化項目が平文で登録されてしまうためユーザ苗字・ユーザ名を更新
    mstPersonalUserDao.updateUserName(newPersonalUser);

    // 利用者マスタ(医療情報DB)に登録
    // 設定項目に初期値をセット
    MstUser.UserSettings usrSetting = new MstUser.UserSettings(){
      {
        setTheme(THEME_DEFAULT);
        setFontSize(FONT_SIZE_DEFAULT);
        setIsDispMenu(IS_DISP_MENU_DEFAULT);
        setUseFunctions(new ArrayList<>(Arrays.asList(CoreConstant.DEFAULT_FUNCTION)));
        setAuthorizedFunctions(new ArrayList<>(Arrays.asList(CoreConstant.DEFAULT_FUNCTION)));
        setInitialFunction(CoreConstant.DEFAULT_FUNCTION);
        setDefaultSetting(DEFAULT_SETTING);
      }
    };
    String secretKey = mstFacilitySettingService.getValueSignInByFacilityCd(mstUser.getFacilityCd()).equals("2") ? QRCodeUtils.getSecretKey() : null;

    MstUser newMstUser = new MstUser() {
      {
        setUserId(newPersonalUser.getUserId());
        setFacilityCd(mstUser.getFacilityCd());
        setIsProvisional(mstUser.getIsProvisional());
        setUserSettings(usrSetting);
        setIsDel("0");
        setIsDisp("1");
        setUpDate(regDt);
        setRegDate(regDt);
        setSecretKey(secretKey);
        setIsSetQrCode(0);
      }
    };
    mstUserDao.insertNewUser(newMstUser);

    // 利用者マスタ(認証DB)に登録
    MstUserAuthentication newMstUserAuth = new MstUserAuthentication() {
      {
        setUserId(newPersonalUser.getUserId());
        setFacilityCd(mstUser.getFacilityCd());
        setDispUserId(mstUser.getDispUserId());
        setUserPassword(StringUtils.isEmpty(mstUser.getUserPassword()) ? null : passwordEncoder.encode(mstUser.getUserPassword()));
        setFailureCnt(mstUser.getFailure_cnt());
        setUpDate(regDt);
        setRegDate(regDt);
      }
    };
    mstUserAuthenticationDao.insertNewUser(newMstUserAuth);

    String masterPhysicalName = "mst_user";
    // DB登録前に対象施設の全ユーザ情報を取得
    List<MstUserAuthentication> userAuthenticationList = mstUserAuthenticationDao.selectByFacility(mstUser.getFacilityCd());
    MstSelector mstUserSelector = mstSelectorDao.selectByName(mstUser.getFacilityCd(), masterPhysicalName);
    if (mstUserSelector == null) {
      // 並び順未登録
      // 対象施設の全ユーザ情報を選択肢マスタに登録する(並び順はuserID順)
      List<Item> insItems = new ArrayList<Item>();
      for (MstUserAuthentication user: userAuthenticationList) {
        Item item = new Item();
        item.setCode(user.getUserId());
        item.setName("");
        insItems.add(item);
      }
      // 選択肢マスタ登録用データを用意する
      mstUserSelector = new MstSelector();
      mstUserSelector.setFacilityCd(mstUser.getFacilityCd());
      mstUserSelector.setMasterPhysicalName(masterPhysicalName);
      MstSelector.OrderSettings insOrderSettings = new MstSelector.OrderSettings();
      insOrderSettings.setItems(insItems);
      mstUserSelector.setOrderSettings(insOrderSettings);
      mstUserSelector.setRegDate(regDt);
      mstUserSelector.setUpDate(regDt);

      // 選択肢マスタにinsert
      mstSelectorDao.insert(mstUserSelector);
    } else {
      // 並び順登録済み
      List<Item> ordItems = mstUserSelector.getOrderSettings().getItems();
      // 並び順マスタを1件ずつチェック、未登録ユーザが存在した場合は最後尾にuserID順に登録する
      for (MstUserAuthentication user: userAuthenticationList) {
        if (!ordItems.stream().anyMatch(item -> item.getCode().equals(user.getUserId()))) {
          // 並び順マスタ未登録
          Item InsItem = new Item();
          InsItem.setCode(user.getUserId());
          InsItem.setName("");
          ordItems.add(InsItem);
        }
      }
      MstSelector.OrderSettings updOrderSettings = new MstSelector.OrderSettings();
      updOrderSettings.setItems(ordItems);
      mstUserSelector.setOrderSettings(updOrderSettings);
      // 選択肢マスタをupdate
      // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
      LogEventUtils.setOperatorId(mstUserSelector,logService);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
      // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
      mstSelectorDao.update(mstUserSelector);
    }

    // 成功レスポンス返却
    return new MasterUpdateResponse();
  }

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional(TransactionManagerName.ALL)
  public MasterUpdateResponse registNewPatUser(MstUserData mstUser)
  {
    // 登録時間取得
    java.sql.Timestamp regDt = getCurrentDate();

    // 利用者マスタに登録して利用者ID(シーケンス発行)を取得
    MstPersonalUser newPersonalUser = new MstPersonalUser() {
        {
          setFacilityCd(mstUser.getFacilityCd());
          setUserType(mstUser.getUserType());
          setAdministrator(mstUser.getAdministrator());
          setUserLastName(mstUser.getUserLastName());
          setUserFirstName(mstUser.getUserFirstName());
          setIsDel("0");
          setIsDisp("1");
          setUpDate(regDt);
          setRegDate(regDt);
        }
    };
    mstPersonalUserDao.insertNewUser(newPersonalUser);

    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
    LogEventUtils.setOperatorId(newPersonalUser,logService);
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
    // @Insertでは暗号化項目が平文で登録されてしまうためユーザ苗字・ユーザ名を更新
    mstPersonalUserDao.updateUserName(newPersonalUser);

    // 利用者マスタ(医療情報DB)に登録
    // 設定項目に初期値をセット
    MstUser.UserSettings usrSetting = new MstUser.UserSettings(){
      {
        setTheme(THEME_DEFAULT);
        setFontSize(FONT_SIZE_DEFAULT);
        setIsDispMenu(0);
        setUseFunctions(new ArrayList<>(Arrays.asList(CoreConstant.DEFAULT_PAT_FUNCTION)));
        setAuthorizedFunctions(new ArrayList<>(Arrays.asList(CoreConstant.DEFAULT_PAT_FUNCTION)));
        setInitialFunction(CoreConstant.DEFAULT_PAT_FUNCTION);
      }
    };
    MstUser newMstUser = new MstUser() {
      {
        setUserId(newPersonalUser.getUserId());
        setFacilityCd(mstUser.getFacilityCd());
        setIsProvisional(mstUser.getIsProvisional());
        setUserSettings(usrSetting);
        setIsDel("0");
        setIsDisp("1");
        setUpDate(regDt);
        setRegDate(regDt);
        setPatId(mstUser.getPatId());

      }
    };
    mstUserDao.insertNewUser(newMstUser);

    // 利用者マスタ(認証DB)に登録
    MstUserAuthentication newMstUserAuth = new MstUserAuthentication() {
      {
        setUserId(newPersonalUser.getUserId());
        setFacilityCd(mstUser.getFacilityCd());
        setDispUserId(mstUser.getDispUserId());
        setUserPassword(StringUtils.isEmpty(mstUser.getUserPassword()) ? null : passwordEncoder.encode(mstUser.getUserPassword()));
        setFailureCnt(mstUser.getFailure_cnt());
        setUpDate(regDt);
        setRegDate(regDt);
      }
    };
    mstUserAuthenticationDao.insertNewUser(newMstUserAuth);

    // 成功レスポンス返却
    return new MasterUpdateResponse();
  }



  /**
   * {@inheritDoc}
   */
  @Override
  public MasterUpdateResponse updAdministrator( long userId, int adminFlg )
  {
    MstPersonalUser personalUser = new MstPersonalUser() {
      {
        setUserId(userId);
        setAdministrator(adminFlg);
        setUpDate(getCurrentDate());
      }
    };

    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
    LogEventUtils.setOperatorId(personalUser,logService);
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
    // 更新Dao呼び出し
    int updateResult = mstPersonalUserDao.updateAdministrator(personalUser);
    // 更新結果=1件以外の場合、エラーメッセージを設定したレスポンスを返却
    if (updateResult != 1) {
      return new MasterUpdateResponse(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage());
    }

    // 成功レスポンス返却
    return new MasterUpdateResponse();
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public MasterUpdateResponse updPatientShared( long userId, int patientSharedFlg )
  {
    MstPersonalUser personalUser = new MstPersonalUser() {
      {
        setUserId(userId);
        setPatientShared(patientSharedFlg);
        setUpDate(getCurrentDate());
      }
    };

    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
    LogEventUtils.setOperatorId(personalUser,logService);
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
    // 更新Dao呼び出し
    int updateResult = mstPersonalUserDao.updatePatientshared(personalUser);
    // 更新結果=1件以外の場合、エラーメッセージを設定したレスポンスを返却
    if (updateResult != 1) {
      return new MasterUpdateResponse(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage());
    }

    // 成功レスポンス返却
    return new MasterUpdateResponse();
  }

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  public MasterUpdateResponse resetPassword(long userId, String dispUserId, String password)
  {
    // 利用者マスタ(認証DB)
    MstUserAuthentication userAuthentication = new MstUserAuthentication() {
      {
        setUserId(userId);
        setDispUserId(dispUserId);
        setUserPassword(StringUtils.isEmpty(password) ? null : passwordEncoder.encode(password));
        setUpDate(getCurrentDate());
      }
    };

    // 更新Dao呼び出し


    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
    LogEventUtils.setOperatorId(userAuthentication,logService);
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
    int updateResult = mstUserAuthenticationDao.updateDispUserIdAndUserPassword(userAuthentication);


    // 更新結果=1件以外の場合、エラーメッセージを設定したレスポンスを返却
    if (updateResult != 1) {
      return new MasterUpdateResponse(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage());
    }
    MstPersonalUser persionalUser = mstPersonalUserDao.selectById(userId);

    String secretKey = mstFacilitySettingService.getValueSignInByFacilityCd(persionalUser.getFacilityCd()).equals("2") ? QRCodeUtils.getSecretKey() : null;
    // 利用者マスタ
    MstUser newMstUser = new MstUser() {
      {
        setUserId(userId);
        setIsProvisional(1);
        setUpDate(getCurrentDate());
        setSecretKey(secretKey);
        setIsSetQrCode(0);
      }
    };
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
    LogEventUtils.setOperatorId(newMstUser,logService);
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
    updateResult = mstUserDao.updateIsProvisional(newMstUser);
    // 更新結果=1件以外の場合、エラーメッセージを設定したレスポンスを返却
    if (updateResult != 1) {
      return new MasterUpdateResponse(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage());
    }

    // 成功レスポンス返却
    return new MasterUpdateResponse();
  }

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional(TransactionManagerName.ALL)
  public MasterUpdateResponse resetFailureCnt( long userId )
  {
    MstUserAuthentication userAuthentication = new MstUserAuthentication() {
      {
        setUserId(userId);
        setFailureCnt(0);
        setUpDate(getCurrentDate());
      }
    };

    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
    LogEventUtils.setOperatorId(userAuthentication,logService);
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
    // 更新Dao呼び出し
    int updateResult = mstUserAuthenticationDao.updateFailureCnt(userAuthentication);
    // 更新結果=1件以外の場合、エラーメッセージを設定したレスポンスを返却
    if (updateResult != 1) {
      return new MasterUpdateResponse(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage());
    }

    // 成功レスポンス返却
    return new MasterUpdateResponse();
  }

  /**
   * {@inheritDoc}
   */
  @Override
  // #12625 2026.05.13 mod 利用者削除時に仮想端末スタッフ一覧から対象ユーザーを削除 start
  // @Transactional(TransactionManagerName.ALL)
  public MasterUpdateResponse deleteUser( long userId )
  {
    // 内側 @Transactional メソッドを self プロキシ越しに呼び出す。
    // この戻り値受領時点で、ChainedTransactionManager の commit 全工程および
    // cleanupAfterCompletion（connection 返却・TSM クリア等）は完了している。
    // ＝ ここから先は @Transactional の完全な外側である。
    DeleteUserInTxResult result = self.deleteUserInTx(userId);
    // 通知発火（TX完全外）。
    // 個別 DE 通知 1 件の失敗が他 DE への通知連鎖を止めないよう、ループ内で個別 catch する。
    // 通知失敗はレスポンス自体の失敗にしない（既存設計同様 best-effort）。
    if (!result.notifyDeviceEdgeNos.isEmpty()) {
      for (Integer deviceEdgeNo : result.notifyDeviceEdgeNos) {
        try {
          deviceEdgeOrderService.orderReloadComsvSetting(result.facilityCd, deviceEdgeNo);
        } catch (Exception notifyEx) {
          // ロガーは本クラスでは EventLogMessage 経由を使っていないため、stderr/logger 等
          // 既存スタイルに合わせて出力する。レビュー時にチームのログ規約に合わせて調整可。
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(notifyEx));
          logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
        }
      }
    }
    return result.response;
  }

  /**
   * {@code deleteUser} の内側トランザクションメソッド
   * 通信サーバ設定(mst_comsv_setting) の更新により再読込通知が必要となった DE 番号は、
   * 本メソッド内では「集約」のみ行い、通知発火は外側メソッド側で行う。
   */
  @Transactional(TransactionManagerName.ALL)
  public DeleteUserInTxResult deleteUserInTx( long userId )
  // #12625 2026.05.13 mod 利用者削除時に仮想端末スタッフ一覧から対象ユーザーを削除 end
  {
    // 利用者マスタ
    MstUser newMstUser = new MstUser() {
      {
        setUserId(userId);
        //mod #6229 全施設マスタのis_disp=0のデータが表示される huang start
        //setIsDel("1");
        setIsDel("0");
        //mod #6229 全施設マスタのis_disp=0のデータが表示される huang end
        //add #6229 全施設マスタのis_disp=0のデータが表示される zhou start
        setIsDisp("0");
        //add #6229 全施設マスタのis_disp=0のデータが表示される zhou end
        setUpDate(getCurrentDate());
      }
    };
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
    LogEventUtils.setOperatorId(newMstUser,logService);
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
    int updateResult = mstUserDao.updateIsDel(newMstUser);
    // 更新結果=1件以外の場合、エラーメッセージを設定したレスポンスを返却
    if (updateResult != 1) {
      // #12625 2026.05.13 mod 利用者削除時に仮想端末スタッフ一覧から対象ユーザーを削除 start
      // return new MasterUpdateResponse(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage());
      return new DeleteUserInTxResult(new MasterUpdateResponse(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage()),null, null);
      // #12625 2026.05.13 mod 利用者削除時に仮想端末スタッフ一覧から対象ユーザーを削除 end
    }
    // 利用者マスタ(認証DB)
    updateResult = mstUserAuthenticationDao.delete(userId);
    // 更新結果=1件以外の場合、エラーメッセージを設定したレスポンスを返却
    if (updateResult != 1) {
      // #12625 2026.05.13 mod 利用者削除時に仮想端末スタッフ一覧から対象ユーザーを削除 start
      // return new MasterUpdateResponse(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage());
      return new DeleteUserInTxResult(new MasterUpdateResponse(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage()),null, null);
      // #12625 2026.05.13 mod 利用者削除時に仮想端末スタッフ一覧から対象ユーザーを削除 end
    }
    // 利用者マスタ(個人情報DB)
    MstPersonalUser personalUser = new MstPersonalUser() {
      {
        setUserId(userId);
        //mod #6229 全施設マスタのis_disp=0のデータが表示される huang start
        //setIsDel("1");
        setIsDel("0");
        //mod #6229 全施設マスタのis_disp=0のデータが表示される huang end
        //add #6229 全施設マスタのis_disp=0のデータが表示される zhou start
        setIsDisp("0");
        //add #6229 全施設マスタのis_disp=0のデータが表示される zhou end
        setUpDate(getCurrentDate());
      }
    };
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
    LogEventUtils.setOperatorId(personalUser,logService);
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
    updateResult = mstPersonalUserDao.updateIsDel(personalUser);
    // 更新結果=1件以外の場合、エラーメッセージを設定したレスポンスを返却
    if (updateResult != 1) {
      // #12625 2026.05.13 mod 利用者削除時に仮想端末スタッフ一覧から対象ユーザーを削除 start
      // return new MasterUpdateResponse(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage());
      return new DeleteUserInTxResult(new MasterUpdateResponse(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage()),null, null);
      // #12625 2026.05.13 mod 利用者削除時に仮想端末スタッフ一覧から対象ユーザーを削除 end
    }

    // 対象ユーザが所属していた施設コードを取得
    String facilityCd = mstPersonalUserDao.selectById(userId).getFacilityCd();

    // 対象施設の利用者選択肢から対象ユーザを削除する
    // マスタセレクタを取得
    String masterPhysicalName = "mst_user";
    MstSelector mstSelector = mstSelectorDao.selectByName(facilityCd, masterPhysicalName);
    if(mstSelector != null ){
      MstSelector.OrderSettings orderSettings = new MstSelector.OrderSettings();
      // マスタセレクタから対象ユーザを除いたjsonを生成
      List<Item> items = new ArrayList<Item>();
      for(Item info:mstSelector.getOrderSettings().getItems()){
        if(!info.getCode().equals(userId)){
          items.add(info);
        }
      }
      orderSettings.setItems(items);
      mstSelector.setOrderSettings(orderSettings);
      // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
      LogEventUtils.setOperatorId(mstSelector,logService);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
      // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
      mstSelectorDao.update(mstSelector);
    }
    // 送信先グループマスタから、削除したユーザの情報を削除して登録しなおす
    List<MstDestinationGroup> lstMstDestGrp = mstDestinationGroupDao.selectByFacilityCd(facilityCd);

    // 対象拠点の送信先情報を1件ずつチェック
    for(MstDestinationGroup destGrp : lstMstDestGrp)
    {
      MstDestinationGroup.DestinationTarget destTarget = destGrp.getDestinationTarget();
      // 新規設定用のユーザリスト
      List<MstDestinationGroup.User> lstNewDestGrpUsr = new ArrayList<MstDestinationGroup.User>();

      // 登録ユーザ情報を1件ずつチェック
      for ( MstDestinationGroup.User user : destTarget.getUsers())
      {
        if (! user.getUserId().equals(userId))
        {
          // ユーザIDが異なる場合は登録する
          MstDestinationGroup.User newUser = new MstDestinationGroup.User()
          {
            {
              setUserId(user.getUserId());
              setAddress1Send(user.isAddress1Send());
              setAddress2Send(user.isAddress2Send());
            }
          };
          lstNewDestGrpUsr.add(newUser);
        }
      }

      if (lstNewDestGrpUsr.size() != destTarget.getUsers().size())
      {
        // 既存の送信ユーザ一覧のサイズ != 更新予定のユーザ一覧のサイズ(=ユーザ削除された場合)
        destTarget.setUsers(lstNewDestGrpUsr);
        destGrp.setDestinationTarget(destTarget);
        // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
        LogEventUtils.setOperatorId(destGrp,logService);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
        // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
        // 送信先情報を更新する
        mstDestinationGroupDao.updateDestinationTarget(destGrp);
      }
    }

    // #12625 2026.05.13 add 利用者削除時に仮想端末スタッフ一覧から対象ユーザーを削除 start
    // 対象施設の装置通信・仮想端末マスタ全件を取得
    List<MstComsvSetting> comsvSettingList = mstComsvSettingDao.selectByFacilityCd(facilityCd);
    // 通知対象 Set はメソッド戻り値で外側メソッドへ渡すため、スコープをメソッド全体に拡大する。
    Set<Integer> notifyDeviceEdgeNos = new LinkedHashSet<>();
    if (comsvSettingList != null) {
      ObjectMapper comsvMapper = new ObjectMapper();
      for (MstComsvSetting comsvSetting : comsvSettingList) {
        String lcdStaffListJson = comsvSetting.getLcdStaffList();
        if (lcdStaffListJson == null || lcdStaffListJson.isEmpty()) {
          continue;
        }
        // JsonProcessingException(IOException) を当該1件分のみで握り、
        // 他の通信サーバ設定の処理および利用者削除全体は止めない方針とする。
        // 既存処理(MasterEditServiceImpl, LcdReq29ServiceImpl)と同じ try/catch(IOException) パターンに合わせる。
        try {
          JsonNode root = comsvMapper.readTree(lcdStaffListJson);
          JsonNode staffListNode = root.get("staff_list");
          if (staffListNode == null || !staffListNode.isArray()) {
            continue;
          }
          // 削除対象ユーザーが含まれているか確認しながら新リストを構築
          // 注意：元JSONの user_id は数値/文字列のいずれかで保存されうる（フロントの保存値依存）。
          // 画面側 (ComsvSettingLcdStaffMainItem.vue) では === で厳密比較しているため、
          // ここで型が変わると突合せが壊れる。比較のみ asText() で文字列化し、
          // 書き戻し時は元 JsonNode をそのまま set() して型を保つ。
          boolean changed = false;
          ArrayNode newStaffList = comsvMapper.createArrayNode();
          int newNo = 1;
          for (JsonNode staffNode : staffListNode) {
            JsonNode userIdNode = staffNode.get("user_id");
            String staffUserId = (userIdNode != null) ? userIdNode.asText("") : "";
            if (String.valueOf(userId).equals(staffUserId)) {
              // 削除対象ユーザーのため除外
              changed = true;
            } else {
              ObjectNode newStaff = comsvMapper.createObjectNode();
              newStaff.put("no", newNo++);
              if (userIdNode != null) {
                newStaff.set("user_id", userIdNode);
              }
              newStaffList.add(newStaff);
            }
          }
          if (changed) {
          	// lcd_staff_list を更新
            ObjectNode newRoot = comsvMapper.createObjectNode();
            newRoot.set("staff_list", newStaffList);
            comsvSetting.setLcdStaffList(comsvMapper.writeValueAsString(newRoot));
            LogEventUtils.setOperatorId(comsvSetting,logService);
            mstComsvSettingDao.updateLcdStaffList(comsvSetting.getComsvCd(), comsvSetting.getLcdStaffList());
            // 有効なデバイスエッジのみ通知（is_disp='1' = 表示中）
            // この時点では通知を直接出さず、対象 DE 番号を Set に集約するだけ。
            // 実際の通知はループ完了後・コミット完了後の afterCommit にてまとめて発火する。
            if ("1".equals(comsvSetting.getIsDisp()) && comsvSetting.getDeviceEdgeNo() != null) {
              notifyDeviceEdgeNos.add(comsvSetting.getDeviceEdgeNo());
            }
          }
        } catch (tools.jackson.core.JacksonException e) {
          // lcd_staff_list の JSON が壊れている等で読み書きに失敗した場合は、
          // 当該1件分のみスキップして次のレコード処理へ進む。
//        e.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 del yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 add yangxuewang start
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
          logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 add yangxuewang end
        }
      }
    }
    // #12625 2026.05.13 add 利用者削除時に仮想端末スタッフ一覧から対象ユーザーを削除 end

    // 削除された利用者をタイムアウトさせる
    // mod #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dou start
    // sysSigninManagerService.signOutUser(userId);
    sysSigninManagerService.signOutUserForMultiServer(newMstUser.getFacilityCd(), userId,
      ForceSignOutReason.USER_DELETED);
    // mod #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dou end
    // 成功レスポンス返却
    // #12625 2026.05.13 mod 利用者削除時に仮想端末スタッフ一覧から対象ユーザーを削除 start
    // return new MasterUpdateResponse();
    return new DeleteUserInTxResult(new MasterUpdateResponse(), facilityCd, notifyDeviceEdgeNos);
    // #12625 2026.05.13 mod 利用者削除時に仮想端末スタッフ一覧から対象ユーザーを削除 end
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public String getUrlCom(String key)
  {
    String ret = "";

    List<SysSystemDefine> lstSSD = sysSystemDefineDao.selectByCtlNo(4);

    if ( lstSSD.size() >= 1 )
    {
      String strJson = lstSSD.get(0).getValue();
      JSONObject objJson = new JSONObject(strJson);
      ret = objJson.getString(key);
    }

    return ret;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public String getUrlHash(String facilityCd)
  {
    return mstFacilityHashDao.selectByFacilityCd(facilityCd).getHashValue();
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public String getUrlPatHash(String facilityCd)
  {
    return mstPatHashDao.selectByFacilityCd(facilityCd).getHashValue();
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public String getFacilityName(String facilityCd)
  {
    return mstFacilityDao.selectByCd(facilityCd).getFacilityName();
  }

  /**
   * システム日時を取得します
   * @return システム日時
   */
  private java.sql.Timestamp getCurrentDate() {
    return new java.sql.Timestamp(System.currentTimeMillis());
  }

  /**
   * 文字列をスネークケースに変換.
   *
   * @param targetString 対象文字列
   * @return 変換後文字列
   */
  private String convertToSnake(String targetString) {
    return CaseFormat.LOWER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, targetString);
  }

  /**
   * フォーマット文字列をKendoUI用に変換.
   *
   * @param formatString 対象文字列
   * @return 変換後文字列
   */
  private String getKendoFormatString(String formatString) {
    return "{0:" + formatString + "}";
  }

  /**
   * カラム情報の作成.
   *
   * @return カラム情報リスト
   */
  private List<MasterColumn> makeMasterColumn(String facilityCd) {

    // カラム情報の作成
    List<MasterColumn> masterColumns = new ArrayList<MasterColumn>();

    MasterColumn masterColumn = null;

    // ソート順項目を追加
    masterColumn = new MasterColumn(SORT_RANK, SORT_RANK_TITLE, false, false, getKendoFormatString(NUMBER_FORMAT), null, false, "");
    masterColumns.add(masterColumn);

    // ソート順用追加時刻項目を追加
    masterColumn = new MasterColumn(SORT_INPUT_TIME, SORT_INPUT_TIME, true, false, null, null, true, "");
    masterColumns.add(masterColumn);

    // userId
    masterColumn = new MasterColumn("userId", "userId", true, false, null, null, false, "");
    masterColumns.add(masterColumn);

    // facilityCd
    masterColumn = new MasterColumn("facilityCd", "facilityCd", true, false, null, null, false, "");
    masterColumns.add(masterColumn);

    // userName
    masterColumn = new MasterColumn("userName", "氏名", false, true, null, null, false, "");
    masterColumns.add(masterColumn);

    // 管理者ボタン
    masterColumn = new MasterColumn("administrator", "管理者", false, false, null, null, false, "");
    masterColumns.add(masterColumn);

    // 使用機能ボタン
    masterColumn = new MasterColumn("useFunction", "使用許可機能", false, false, null, null, true, "");
    masterColumns.add(masterColumn);

    // 編集権限ボタン
    masterColumn = new MasterColumn("editAuthority", "編集権限", false, false, null, null, true, "");
    masterColumns.add(masterColumn);

    // ID/PWリセットボタン
    masterColumn = new MasterColumn(convertToSnake(MODAL), "ID/PWリセット", false, false, null, null, true, "");
    masterColumns.add(masterColumn);

    // 患者共有
    masterColumn = new MasterColumn("patientShared", "患者共有", false, false, null, null, true, "");
    masterColumns.add(masterColumn);

    // ロック解除ボタン
    masterColumn = new MasterColumn(convertToSnake(MODAL), "ロック解除", false, false, null, null, true, "");
    masterColumns.add(masterColumn);

    // 職種コード
    List<ComboValue> lstCmbJob = new ArrayList<ComboValue>();
    MstSelector lstJob = mstSelectorDao.selectByName(facilityCd, "mst_job");
    //FNSI-修正 ログシステムエラー対応 baix update start
    if (lstJob != null) {
      for(Item itm : lstJob.getOrderSettings().getItems()) {
        lstCmbJob.add(new ComboValue(itm.getCode(),itm.getName()));
      }
    }
    //FNSI-修正 ログシステムエラー対応 baix update end
    masterColumn = new MasterColumn("jobCd", "職種", false, false, null, lstCmbJob, true, "");
    masterColumns.add(masterColumn);

    // 利用者カナ名_姓
    masterColumn = new MasterColumn("userLastNameKana", "利用者カナ名_姓", false, false, null, null, true, "");
    masterColumns.add(masterColumn);

    // 利用者カナ名_名
    masterColumn = new MasterColumn("userFirstNameKana", "利用者カナ名_名", false, false, null, null, true, "");
    masterColumns.add(masterColumn);

    // 利用者英字名_姓
    masterColumn = new MasterColumn("userLastNameAlpha", "利用者英字名_姓", false, false, null, null, true, "");
    masterColumns.add(masterColumn);

    // 利用者英字名_名
    masterColumn = new MasterColumn("userFirstNameAlpha", "利用者英字名_名", false, false, null, null, true, "");
    masterColumns.add(masterColumn);

//    add #9584 2023-9-8 lmf start
    // メールアドレス1
    masterColumn = new MasterColumn("userEmailAddress1", "メールアドレス1", false, false, null, null, false, "");
    masterColumns.add(masterColumn);

    // メールアドレス2
    masterColumn = new MasterColumn("userEmailAddress2", "メールアドレス2", false, false, null, null, false, "");
    masterColumns.add(masterColumn);
//    add #9584 2023-9-8 lmf end

    // 内線番号
    masterColumn = new MasterColumn("extensionNo", "内線番号", false, false, null, null, true, "");
    masterColumns.add(masterColumn);

    // 自宅番号
    masterColumn = new MasterColumn("homeNo", "自宅番号", false, false, null, null, false, "");
    masterColumns.add(masterColumn);

    // 携帯番号
    masterColumn = new MasterColumn("mobilePhoneNo", "携帯番号", false, false, null, null, false, "");
    masterColumns.add(masterColumn);

    // FAX番号
    masterColumn = new MasterColumn("faxNo", "FAX番号", false, false, null, null, false, "");
    masterColumns.add(masterColumn);

    // 郵便番号7
    masterColumn = new MasterColumn("zipcd7", "郵便番号7", false, false, null, null, false, "");
    masterColumns.add(masterColumn);

    // 自宅住所
    masterColumn = new MasterColumn("address", "自宅住所", false, false, null, null, false, "");
    masterColumns.add(masterColumn);

    // カード作成ボタン
    masterColumn = new MasterColumn(convertToSnake(MODAL), "カード作成", false, false, null, null, true, "");
    masterColumns.add(masterColumn);

    // 連携コード1
    masterColumn = new MasterColumn("inHospitalCd_1", "連携コード1", false, false, null, null, true, "");
    masterColumns.add(masterColumn);

    // 連携コード2
    masterColumn = new MasterColumn("inHospitalCd_2", "連携コード2", false, false, null, null, true, "");
    masterColumns.add(masterColumn);

    // 仮登録フラグ
    masterColumn = new MasterColumn("isProvisional", "isProvisional", true, false, null, null, false, "");
    masterColumns.add(masterColumn);

    // サインイン失敗回数
    masterColumn = new MasterColumn("failure_cnt", "failure_cnt", true, false, null, null, false, "");
    masterColumns.add(masterColumn);

    // 表示用利用者ID
    masterColumn = new MasterColumn("dispUserId", "dispUserId", true, false, null, null, false, "");
    masterColumns.add(masterColumn);

    // 付加情報としてoperationを追加
    masterColumn = new MasterColumn(OPERATION, OPERATION, true, false, null, null, true, "");
    masterColumns.add(masterColumn);

    // 付加情報として追加許可を追加(allowAddRecord=1)
    masterColumn = new MasterColumn(ALLOW_ADD_RECORD, ALLOW_ADD_RECORD, true, false, null, null, true, "");
    masterColumns.add(masterColumn);
    // 秘密鍵列
    masterColumn = new MasterColumn("secretKey", "2要素認証", false, false, null, null, false, "");
    masterColumns.add(masterColumn);
    // 秘密鍵列を削除
    masterColumn = new MasterColumn("unSettingKey", "秘密鍵", false, false, null, null, true, "");
    masterColumns.add(masterColumn);

    // アクセスカードを無効にする
    masterColumn = new MasterColumn("cardIdm", "カード無効化", false, false, null, null, false, "");
    masterColumns.add(masterColumn);

    // サインイン日時
    masterColumn = new MasterColumn("signinDate", "サインイン日時", false, false, null, null, false, "");
    masterColumns.add(masterColumn);

    // 削除ボタン
    masterColumn = new MasterColumn(convertToSnake(MODAL), "削除", false, false, null, null, true, "");
    masterColumns.add(masterColumn);

    return masterColumns;

  }

  /**
   * 利用者ソート順カラム情報の作成.
   *
   * @return カラム情報リスト
   */
  private List<MasterColumn> makeSortMasterColumn(String facilityCd) {

    // カラム情報の作成
    List<MasterColumn> masterColumns = new ArrayList<MasterColumn>();

    MasterColumn masterColumn = null;

    // ソート順項目を追加
    masterColumn = new MasterColumn(SORT_RANK, SORT_RANK_TITLE, false, false, getKendoFormatString(NUMBER_FORMAT), null, true, "");
    masterColumns.add(masterColumn);

    // ソート順用追加時刻項目を追加
    masterColumn = new MasterColumn(SORT_INPUT_TIME, SORT_INPUT_TIME, true, false, null, null, true, "");
    masterColumns.add(masterColumn);

    // userId
    masterColumn = new MasterColumn("userId", "userId", true, false, null, null, false, "");
    masterColumns.add(masterColumn);

    // facilityCd
    masterColumn = new MasterColumn("facilityCd", "facilityCd", true, false, null, null, false, "");
    masterColumns.add(masterColumn);

    // userName
    masterColumn = new MasterColumn("userName", "氏名", false, false, null, null, false, "");
    masterColumns.add(masterColumn);

    // 職種コード
    List<ComboValue> lstCmbJob = new ArrayList<ComboValue>();
    MstSelector lstJob = mstSelectorDao.selectByName(facilityCd, "mst_job");
    for(Item itm : lstJob.getOrderSettings().getItems()) {
      lstCmbJob.add(new ComboValue(itm.getCode(),itm.getName()));
    }

    masterColumn = new MasterColumn("jobCd", "職種", false, false, null, lstCmbJob, false, "");
    masterColumns.add(masterColumn);

    // 管理者データ
    List<ComboValue> lstAdmin = new ArrayList<ComboValue>();
    lstAdmin.add(new ComboValue("0","ユーザー"));
    lstAdmin.add(new ComboValue("1","管理者"));
    masterColumn = new MasterColumn("administrator", "管理者", false, false, null, lstAdmin, false, "");
    masterColumns.add(masterColumn);



    // 付加情報としてoperationを追加
    masterColumn = new MasterColumn(OPERATION, OPERATION, true, false, null, null, true, "");
    masterColumns.add(masterColumn);

    // 付加情報として追加許可を追加(allowAddRecord=1)
    masterColumn = new MasterColumn(ALLOW_ADD_RECORD, ALLOW_ADD_RECORD, true, false, null, null, true, "");
    masterColumns.add(masterColumn);

    // 付加情報として並び替え許可を追加
    masterColumn = new MasterColumn(ALLOW_SORT, ALLOW_SORT, true, false, null, null, true, "");
    masterColumns.add(masterColumn);


    return masterColumns;

  }


  /**
   * フィールド情報の作成.
   *
   * @return フィールド情報MAP
   */
  private Map<String, Object> makeMasterField() {

    Map<String, Object> fieldsMap = new HashMap<>();
    Map<String, Object> fieldsList;

    // userId
    fieldsList = new HashMap<>();
    fieldsList.put("type", FieldType.NUMBER);
    fieldsMap.put("userId", fieldsList);

    // facilityCd
    fieldsList = new HashMap<>();
    fieldsList.put("type", FieldType.STRING);
    fieldsMap.put("facilityCd", fieldsList);

    // userName
    fieldsList = new HashMap<>();
    fieldsList.put("type", FieldType.STRING);
    fieldsMap.put("userName", fieldsList);

    // administrator
    fieldsList = new HashMap<>();
    fieldsList.put("type", FieldType.NUMBER);
    fieldsMap.put("administrator", fieldsList);

    // patientShared
    fieldsList = new HashMap<>();
    fieldsList.put("type", FieldType.NUMBER);
    fieldsMap.put("patientShared", fieldsList);

    // isProvisional
    fieldsList = new HashMap<>();
    fieldsList.put("type", FieldType.NUMBER);
    fieldsMap.put("isProvisional", fieldsList);

    // failure_cnt
    fieldsList = new HashMap<>();
    fieldsList.put("type", FieldType.NUMBER);
    fieldsMap.put("failure_cnt", fieldsList);

    // ソート項目をNUMBER型として追加
    fieldsList = new HashMap<>();
    fieldsList.put("type", FieldType.NUMBER);
    fieldsMap.put(SORT_RANK, sortRankFields());
    fieldsMap.put(SORT_INPUT_TIME, fieldsList);

    // inHospitalCd_1
    fieldsMap.put("inHospitalCd_1", inHospitalCdFields());

    // inHospitalCd_2
    fieldsMap.put("inHospitalCd_2", inHospitalCdFields());

    return fieldsMap;
  }

  @SuppressWarnings("serial")
  private Map<String, Object> sortRankFields() {
    return new HashMap<String, Object>() {
      {
        put("type", FieldType.NUMBER);
        put("validation", new HashMap<String, Integer>() {{put("min", 0);}});
        put("defaultValue", 1);
      }
    };
  }

  @SuppressWarnings("serial")
  private Map<String, Object> inHospitalCdFields() {
    return new HashMap<String, Object>() {
      {
        put("type", FieldType.STRING);
        put("validation", new HashMap<String, Integer>() {{put("maxlength", 20);}});
      }
    };
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<MstUserData> getDeleteTarget(String userEmailAddress)
  {
    // メールアドレスを元に該当するユーザを取得
    List<MstPersonalUser> personalUserList = mstPersonalUserDao.selectByUserEmailAddressList(userEmailAddress);

    List<MstUserData> mstUserDataList = new ArrayList<MstUserData>();
    for(MstPersonalUser personalUser : personalUserList){
      Long userId = personalUser.getUserId();

      // 施設名称を取得
      MstFacility mstFacility = mstFacilityDao.selectByCd(personalUser.getFacilityCd());
      String facilityName = mstFacility.getFacilityName();

      // 表示患者IDを取得
      MstUserAuthentication userAuthentication = mstUserAuthenticationDao.selectById(personalUser.getUserId());
      String dispUserId = userAuthentication.getDispUserId();

      // メールアドレス1、2毎に1レコードとなるようにデータを作成する
      if (!StringUtils.isEmpty(personalUser.getUserEmailAddress1()) && personalUser.getUserEmailAddress1().equals(userEmailAddress)) {
        // メールアドレス1をセット
        MstUserData address1Data = new MstUserData();
        address1Data.setUserId(userId);
        address1Data.setFacilityName(facilityName);
        address1Data.setDispUserId(dispUserId);
        address1Data.setUserEmailAddress1(personalUser.getUserEmailAddress1());
        mstUserDataList.add(address1Data);
      }

      if (!StringUtils.isEmpty(personalUser.getUserEmailAddress2()) && personalUser.getUserEmailAddress2().equals(userEmailAddress)) {
        // メールアドレス2をセット
        MstUserData address2Data = new MstUserData();
        address2Data.setUserId(userId);
        address2Data.setFacilityName(facilityName);
        address2Data.setDispUserId(dispUserId);
        address2Data.setUserEmailAddress2(personalUser.getUserEmailAddress2());
        mstUserDataList.add(address2Data);
      }
    }

    return mstUserDataList;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional(TransactionManagerName.ALL)
  public MasterUpdateResponse deleteEmailAddress(List<MstUserData> emailAddressList)
  {

    for(MstUserData userData : emailAddressList)
    {
      MstPersonalUser personalUser = new MstPersonalUser();
      personalUser.setUserId(userData.getUserId());
      personalUser.setUserEmailAddress1(userData.getUserEmailAddress1());
      personalUser.setUserEmailAddress2(userData.getUserEmailAddress2());



      int updateResult = mstPersonalUserDao.updateUserEmailAddress(personalUser);
      // 更新結果=1件以外の場合、エラーメッセージを設定したレスポンスを返却

      if (updateResult != 1) {
        return new MasterUpdateResponse(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage());
      }
    }

    // 成功レスポンス返却
    return new MasterUpdateResponse();
  }

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  public MasterUpdateResponse updateJobCd( long userId, String jobCd )
  {
    MstPersonalUser personalUser = new MstPersonalUser() {
      {
        setUserId(userId);
        setJobCd(jobCd);
        setUpDate(getCurrentDate());
      }
    };

    // 更新Dao呼び出し
    int updateResult = mstPersonalUserDao.updateUserJob(personalUser);
    // 更新結果=1件以外の場合、エラーメッセージを設定したレスポンスを返却
    if (updateResult != 1) {
      return new MasterUpdateResponse(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage());
    }

    // 職種変更時、許可機能・編集権限・デフォルト表示設定が初期状態の場合はそれぞれ職種に設定された値を割り当てる
    MstUser mstUser = mstUserDao.selectById(userId);
    // 職種の情報を取得
    SelectOptions selectOptions = SelectOptions.get();
    List<MstJob> mstJob = mstJobDao.selectByCd(Long.parseLong(jobCd), selectOptions);

    // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dou start
    String value = facilitySettingService.getFacilitySettingValue(
      mstUser.getFacilityCd(),
      CoreConstant.FacilitySettingNo.AUTHORITY_CHANGE_SIGN_OUT
    );
    boolean signOutFlg = false;
    ForceSignOutReason signOutReason = ForceSignOutReason.USER_AUTHORITY_CHANGED;
    // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dou end

    if ( mstUser.getUserSettings() == null ) {
      // ユーザー設定がnullの場合は職種に設定された情報で上書き
      MstUser.UserSettings userSettings = new MstUser.UserSettings() {
        {
          // 編集権限
          List<String> defaultAuthorizedAuthorities = new ArrayList<String>();
          // add 9522 by kangjie 20231012 start
          if (mstJob != null && mstJob.size() != 0 ){
            if (mstJob.get(0).getDefaultAuthorizedAuthorities() != null && !mstJob.get(0).getDefaultAuthorizedAuthorities().isEmpty()) {
              defaultAuthorizedAuthorities = Arrays.asList(mstJob.get(0).getDefaultAuthorizedAuthorities().split(","));
            }
            // 許可機能
            setAuthorizedFunctions(mstJob.get(0).getDefaultMenuSettings().getUseFunctions());
          }else {
            // 許可機能
            setAuthorizedFunctions(new ArrayList<>());
          }
          // add 9522 by kangjie 20231012 end
          setAuthorizedAuthorities(defaultAuthorizedAuthorities);
          setInitialFunction("005");
        }
      };
      // デフォルト表示設定
      ObjectMapper mapper = new ObjectMapper();
      JsonNode defautSetting = mapper.createObjectNode();
      if (mstJob != null && mstJob.size() != 0 ){
        if (mstJob.get(0).getDefaultDispSettings() != null && !mstJob.get(0).getDefaultDispSettings().isEmpty()) {
          try {
            defautSetting = mapper.readTree(mstJob.get(0).getDefaultDispSettings());
          } catch (tools.jackson.core.JacksonException e) {
            return new MasterUpdateResponse(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage());
          }
        }
      }
      userSettings.setDefaultSetting(defautSetting);
      // デフォルト通知設定
      if (mstJob != null && mstJob.size() != 0 && mstJob.get(0).getDefaultNotificationSettings() != null){
        List<PersonalSetting> personalSettings = new ArrayList<>();
        PersonalSetting personalSetting = copyNotificationSettingToPersonalSetting(mstJob.get(0).getDefaultNotificationSettings());
        personalSettings.add(personalSetting);
        userSettings.setPersonalSettings(personalSettings);
      }
      mstUser.setUserSettings(userSettings);

      updateResult = mstUserDao.updateUserSettings(mstUser);
      // 更新結果=1件以外の場合、エラーメッセージを設定したレスポンスを返却
      if (updateResult != 1) {
        return new MasterUpdateResponse(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage());
      }
    } else {
      MstUser.UserSettings userSettings = mstUser.getUserSettings();

      // 初回ログイン前のユーザのみ職種変更時に編集権限および許可機能を職種のデフォルト値に変更する
      //mod 10136 zhangruixue 2023-12-12 start
      //if (mstUser.getIsProvisional() == 1) {
        // 編集権限
        List<String> defaultAuthorizedAuthorities = new ArrayList<String>();
        // デフォルト表示設定
        ObjectMapper mapper = new ObjectMapper();
        JsonNode defautSetting = mapper.createObjectNode();
        // デフォルト通知設定
        List<PersonalSetting> personalSettings = userSettings.getPersonalSettings() == null ?  new ArrayList<>() : new ArrayList<>(userSettings.getPersonalSettings());
        // add 9522 by kangjie 20231012 start
        if (mstJob != null && mstJob.size() != 0) {
          if (mstJob.get(0).getDefaultAuthorizedAuthorities() != null && !mstJob.get(0).getDefaultAuthorizedAuthorities().isEmpty()) {
            defaultAuthorizedAuthorities = Arrays.asList(mstJob.get(0).getDefaultAuthorizedAuthorities().split(","));
          }
          if (mstJob.get(0).getDefaultDispSettings() != null && !mstJob.get(0).getDefaultDispSettings().isEmpty()) {
            try {
              defautSetting = mapper.readTree(mstJob.get(0).getDefaultDispSettings());
            } catch (tools.jackson.core.JacksonException e) {
              return new MasterUpdateResponse(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage());
            }
          }
          if (mstJob.get(0).getDefaultNotificationSettings() != null){
            PersonalSetting notificationSetting = copyNotificationSettingToPersonalSetting(mstJob.get(0).getDefaultNotificationSettings());
            boolean isUpdate = false;
            for(PersonalSetting personalSetting : personalSettings) {
              // 通知設定登録済みの場合は更新
              if(personalSetting.getTabDefineCd() == notificationSetting.getTabDefineCd()) {
                isUpdate = true;
                personalSetting.setValues(notificationSetting.getValues());
                personalSetting.setSettingImportant(notificationSetting.getSettingImportant());
              }
            }
            // 未登録の場合は追加
            if(!isUpdate) {
              personalSettings.add(notificationSetting);
            }
          }else {
            // 職種マスタのデフォルト通知設定がnullの場合削除扱いなので、登録済みのデータを削除する
            personalSettings.removeIf(val -> val.getTabDefineCd() == TAB_DEFINE_CD_NOTIFICATION_SETTING);
          }
          // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dou start
          if (VALID.equals(value)) {
            // 許可機能
            boolean isAddFunc = mstJob.get(0).getDefaultMenuSettings().getUseFunctions().containsAll(userSettings.getAuthorizedFunctions());
            // 編集権限
            boolean isAddAuth = defaultAuthorizedAuthorities.containsAll(userSettings.getAuthorizedAuthorities());
            if (!isAddFunc || !isAddAuth) {
              signOutFlg = true;
              signOutReason = !isAddFunc ? ForceSignOutReason.USE_AUTH_FUNCTION_CHANGED
                : ForceSignOutReason.USER_AUTHORITY_CHANGED;
            }
          }
          // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dou end
          // add #10136 サインイン時に初期表示機能が許可状態でない場合、許可範囲上のメニュー設定の表示順最上部の項目に遷移する dengshen start
          if (userSettings.getUseFunctions().contains(mstJob.get(0).getDefaultMenuSettings().getInitialFunction())) {
            userSettings.setInitialFunction(mstJob.get(0).getDefaultMenuSettings().getInitialFunction());
          } else {
            boolean findInitialFunctionFlg = false;

            // 変更後権限の初期化画面は新し追加権限の場合、ユーザ使用中権限の一番画面に初期化画面を設定する。
            for (int i = 0; i < userSettings.getUseFunctions().size(); i++) {
              if (mstJob.get(0).getDefaultMenuSettings().getUseFunctions().contains(userSettings.getUseFunctions().get(i))) {
                userSettings.setInitialFunction(userSettings.getUseFunctions().get(i));
                findInitialFunctionFlg = true;
                break;
              }
            }

            // すべて権限は追加の場合、変更後一番権限を利用する。
            if (!findInitialFunctionFlg) {
              userSettings.setInitialFunction(mstJob.get(0).getDefaultMenuSettings().getInitialFunction());
              userSettings.getUseFunctions().add(mstJob.get(0).getDefaultMenuSettings().getInitialFunction());
            }
          }
          // add #10136 サインイン時に初期表示機能が許可状態でない場合、許可範囲上のメニュー設定の表示順最上部の項目に遷移する dengshen end
          userSettings.setAuthorizedFunctions(mstJob.get(0).getDefaultMenuSettings().getUseFunctions());
          // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dengshen start
          userSettings.setAuthorizedAuthorities(defaultAuthorizedAuthorities);
          userSettings.setDefaultSetting(defautSetting);
          userSettings.setPersonalSettings(personalSettings);
          mstUser.setUserSettings(userSettings);
          updateResult = mstUserDao.updateUserSettings(mstUser);
          // 更新結果=1件以外の場合、エラーメッセージを設定したレスポンスを返却
          if (updateResult != 1) {
            return new MasterUpdateResponse(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage());
          }
          // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dengshen end
        } else {
          // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dou start
          if (VALID.equals(value)) {
            if (userSettings.getAuthorizedFunctions().isEmpty() || userSettings.getAuthorizedAuthorities().isEmpty()) {
              signOutFlg = true;
            }
          }
          // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dou end
          // del #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dengshen start
          // userSettings.setAuthorizedFunctions(new ArrayList<>());
          // del #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dengshen end
        }
        // add 9522 by kangjie 20231012 end
        // del #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dengshen start
        // userSettings.setAuthorizedAuthorities(defaultAuthorizedAuthorities);
        //
        // mstUser.setUserSettings(userSettings);
        // updateResult = mstUserDao.updateUserSettings(mstUser);
        // // 更新結果=1件以外の場合、エラーメッセージを設定したレスポンスを返却
        // if (updateResult != 1) {
        //   return new MasterUpdateResponse(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage());
        // }
        // del #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dengshen end
      //}
      //mod 10136 zhangruixue 2023-12-12 end
    }
    // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dou start
    if (signOutFlg) {
      // 権限を変更した利用者をサインアウトさせる
      sysSigninManagerService.signOutUserForMultiServer(mstUser.getFacilityCd(), userId, signOutReason);
    }
    // add #9386 施設設定マスタNo64で有効として権限を編集しても対象のアカウントが強制サインアウトされない dou end
    // 成功レスポンス返却
    return new MasterUpdateResponse();
  }

  /**
   * デフォルト通知設定を個人設定のクラスにコピー
   * @param data デフォルト通知設定
   * @return 個人設定
   */
  private PersonalSetting copyNotificationSettingToPersonalSetting(NotificationSettings data) {
    PersonalSetting notificationSetting = new PersonalSetting();
    // 個人設定タブコード
    notificationSetting.setTabDefineCd(data.getTabDefineCd());
    // 設定値情報
    List<SettingValue> values = new ArrayList<>();
    for(NotificationSettingsValue val : data.getValues()) {
      SettingValue settingValue = new SettingValue();
      settingValue.setSettingId(val.getSettingId());
      settingValue.setSettingValue(val.getSettingValue());
      settingValue.setSettingImportant(val.getSettingImportant());
      values.add(settingValue);
    }
    notificationSetting.setValues(values);
    // 重要通知設定
    List<SettingValue> settingImportant = new ArrayList<>();
    for(NotificationSettingsValue val : data.getSettingImportant()) {
      SettingValue settingValue = new SettingValue();
      settingValue.setSettingId(val.getSettingId());
      settingValue.setSettingValue(val.getSettingValue());
      settingValue.setSettingImportant(val.getSettingImportant());
      settingImportant.add(settingValue);
    }
    notificationSetting.setSettingImportant(settingImportant);
    return notificationSetting;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public int getUserByPatId(Long patId)
  {
    return mstUserDao.countByPatId(patId);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public MasterUpdateResponse updatePersonalInfo(MstUserData userData) {
    // 更新対象のユーザ情報を取得
    MstPersonalUser userInfo = mstPersonalUserDao.selectById(userData.getUserId());
    // リクエストデータから更新用のデータを作成
    userInfo.setUserLastNameKana(userData.getUserLastNameKana());
    userInfo.setUserFirstNameKana(userData.getUserFirstNameKana());
    userInfo.setUserLastNameAlpha(userData.getUserLastNameAlpha());
    userInfo.setUserFirstNameAlpha(userData.getUserFirstNameAlpha());
    userInfo.setExtensionNo(userData.getExtensionNo());
    userInfo.setInHospitalCd_1(userData.getInHospitalCd_1());
    userInfo.setInHospitalCd_2(userData.getInHospitalCd_2());



    // 利用者の情報を更新
    int updateResult = mstPersonalUserDao.updateAllowedItems(userInfo);
    // 更新結果=1件以外の場合、エラーメッセージを設定したレスポンスを返却

    if (updateResult != 1) {
      return new MasterUpdateResponse(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage());
    }

    // 成功レスポンス返却
    return new MasterUpdateResponse();
  }

  /**
   * 取得データの並び替え.
   * @param data 取得したデータ
   * @param facilityCd 施設コード
   * @return 並び替え後のデータ
   */
  private List<Map<String, Object>> sortData(List<Map<String, Object>> data, String facilityCd) {
    // data部にソート用のカラムを追加
    data.forEach(m -> {
      m.put(SORT_RANK, null);
      m.put(SORT_INPUT_TIME, null);
    });

    // mstSelectorから並び順を取得
    MstSelector mstSelector = mstSelectorDao.selectByName(facilityCd, "mst_user");

    if (mstSelector != null) {
      // ソート後データ
      List<Map<String, Object>> sortedData = new ArrayList<>();

      // ソート用配列
      List<Long> sortedCodes = mstSelector.getOrderSettings().getItems()
          .stream().map(e -> e.getCode()).collect(Collectors.toList());

      // ソートした配列
      List<Long> deletedCode = new ArrayList<>();

      // データ順
      int sortIndex = 0;

      // ソート用配列順にデータを並び替え
      for (Long sortedCode : sortedCodes) {
        Map<String, Object> pickupMap = data.stream()
            .filter(e -> e.get("userId").equals(sortedCode))
            .findFirst().orElse(null);

        if (pickupMap != null) {
          boolean isContainsDisp = pickupMap.containsKey(IS_DISP);
          boolean isContainsDel = pickupMap.containsKey(IS_DEL);
          boolean isDisp = StringUtils.isEmpty(pickupMap.get(IS_DISP)) ? true
              : FlagType.FLAG_ON.equals(pickupMap.getOrDefault(IS_DISP, FlagType.FLAG_OFF));
          boolean isDel = StringUtils.isEmpty(pickupMap.get(IS_DEL)) ? false
              : FlagType.FLAG_ON.equals(pickupMap.getOrDefault(IS_DEL, FlagType.FLAG_OFF));

          if ((isContainsDisp && !isDisp) || (isContainsDel && isDel)) {
            deletedCode.add(sortedCode);
          }
          else {
            // ソート順を設定
            pickupMap.put(SORT_RANK, ++sortIndex);
            // ソート順に付加
            sortedData.add(pickupMap);
          }
        }
      }

      // mstSelectorに登録されていないコード、もしくは登録されていてかつ削除されているコードを追加
      List<Map<String, Object>> pickupMaps = data.stream()
          .filter(e -> !sortedCodes.contains(e.get("userId"))
              || (sortedCodes.contains(e.get("userId")) && deletedCode.contains(e.get("userId"))))
          .collect(Collectors.toList());

      pickupMaps.forEach(e -> {
        e.put(SORT_RANK, 999999);
        sortedData.add(e);
        });

      return sortedData;
    }
    // data部にソート用のカラムを追加
    data.forEach(m -> {
      m.put(SORT_RANK, 999999);
      m.put(SORT_INPUT_TIME, null);
    });
    return data;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional(TransactionManagerName.ALL)
  public MasterUpdateResponse updateMstSelector(String facilityCd, List<Map<String, Object>> userInfo)
  {
    // マスタセレクタに追加
    List<Item> items = new ArrayList<Item>();
    for(Map<String, Object> info:userInfo){
      items.add
      (new Item() {{
        setCode(Long.parseLong(info.get("userId").toString()));
        setName("");
      }}
      );
    }
    // マスタセレクタを取得
    String masterPhysicalName = "mst_user";
    MstSelector mstSelector = mstSelectorDao.selectByName(facilityCd, masterPhysicalName);
    MstSelector.OrderSettings orderSettings = new MstSelector.OrderSettings();
    orderSettings.setItems(items);
    // マスタセレクタを更新 (あれば更新なければ追加)
    if (mstSelector == null ) {
      mstSelector = new MstSelector();
      mstSelector.setFacilityCd(facilityCd);
      mstSelector.setMasterPhysicalName(masterPhysicalName);
      mstSelector.setOrderSettings(orderSettings);
      mstSelectorDao.insert(mstSelector);
    } else {
      mstSelector.setOrderSettings(orderSettings);
      // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
      LogEventUtils.setOperatorId(mstSelector,logService);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
      // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
      mstSelectorDao.update(mstSelector);
    }
    // 成功レスポンス返却
    return new MasterUpdateResponse();
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public MasterUpdateResponse deleteSecretKey(long userId) {
    MstUser userData = new MstUser() {
      {
        setUserId(userId);
        setUpDate(getCurrentDate());
      }
    };

    int updateResult = mstUserDao.deleteSecretKey(userData);


    if (updateResult != 1) {
      return new MasterUpdateResponse(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage());
    }
    return new MasterUpdateResponse();
  }

  private void updateResult(String tableName, List<String> filedList, List<Object> valueList) {
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public MstUserOTP createSecretKey(String dispUserId, String facilityCd) throws Exception {
    TwoFactAuth tFA = new TwoFactAuth();
    String secretKey = tFA.createSecretKey();
    String facilityName = mstFacilityDao.selectByCd(facilityCd).getFacilityName();
    MstFacilityHash facilityHash = mstFacilityHashDao.selectByFacilityCd(facilityCd);
    String useSetting = "";
    if(facilityHash != null) {
      switch (facilityHash.getSystemUseSetting()) {
      case "0":
        useSetting = SystemUseSetting.NKK;
        break;
      case "1":
        useSetting = SystemUseSetting.REMS;
        break;
      case "2":
        useSetting = SystemUseSetting.FUTURENETWEB_SI;
        break;
      case "3":
        useSetting = SystemUseSetting.FUTURENETWEB_SI_REMS;
        break;
      default:
        break;
      }
    }
    String QRcode = tFA.TwoFactAuth(secretKey, dispUserId + "@" + facilityName, useSetting);
    return new MstUserOTP(secretKey, QRcode);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public MasterUpdateResponse updateSecretKey(long userId, String secretKey) {
    MstUser userData = new MstUser() {
      {
        setUserId(userId);
        setSecretKey(secretKey);
        setUpDate(getCurrentDate());
      }
    };


    int updateResult = mstUserDao.updateSecretKey(userData);


    if (updateResult != 1) {
      return new MasterUpdateResponse(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage());
    }
    return new MasterUpdateResponse();
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public boolean checkOtpPassword(long userId,String otp){
    MstUser user = new MstUser();
    user = mstUserDao.selectById(userId);
    TwoFactAuth tFA = new TwoFactAuth();
    String otpCode = "";
    if(user.getSecretKey() != null ) {
    	 otpCode = tFA.getOTPCode(user.getSecretKey());
    }
    return otp.equals(otpCode);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public boolean checkOtpOnRegister(String secretKey, String otp){
    TwoFactAuth tFA = new TwoFactAuth();
    String otpCode = "";
    if(secretKey != null ) {
         otpCode = tFA.getOTPCode(secretKey);
    }
    return otp.equals(otpCode);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public int updateIsSetQrCode(long userId, int isSetQrCode){
    MstUser user = new MstUser() {
		{
	      setUserId(userId);
	      setIsSetQrCode(isSetQrCode);
	      setUpDate(getCurrentDate());
		}
    };
    return mstUserDao.updateIsSetQrCode(user);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public MasterUpdateResponse disableAccessCard(long userId) {

    // DB更新ログ出力ロジック wangzuo Start
    String tableName = "mst_user";
    // SQL検索条件
    StringBuffer wheres = new StringBuffer("");
    wheres.append(" WHERE\n");
    wheres.append(" user_id = " + userId + "\n");
    // logCommon設定
    DataUpdateLogCommonNew logCommon = getLogCommon(tableName, wheres, getEventLogMessage());
    // ログ出力カラム情報及び更新前データ情報取得
    boolean setResult = logCommon.setInfo();
    // DB更新ログ出力ロジック wangzuo End

    int result = mstUserAuthenticationDao.disableAccessCard(userId);

    // DB更新ログ出力ロジック wangzuo Start
    // 更新後データ取得、差分あれば、log出力
    if (setResult && result > 0) {
      logCommon.updateLog();
    }
    // DB更新ログ出力ロジック wangzuo End

    if (result > 0) {
      return new MasterUpdateResponse();
    }
    return new MasterUpdateResponse(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage());
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public MasterUpdateResponse updateSigninDate(long userId) {
    MstPersonalUser mstPersonalUser = new MstPersonalUser() {
      {
        setUserId(userId);
        setSigninDate(getCurrentDate());
      }
    };
    int updateResult = mstPersonalUserDao.updateSigninDate(mstPersonalUser);
    if (updateResult != 1) {
      return new MasterUpdateResponse(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage());
    }
    return new MasterUpdateResponse();
  }

  // DB更新ログ出力ロジック wangzuo Start
  /**
   * ログ情報設定
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
    return   eventLogMessage;
  }

  /**
   * ログ出力共通クラス設定、取得
   * @return logCommon ログ出力共通クラス
   */
  private DataUpdateLogCommonNew getLogCommon(String tableName, StringBuffer whereStr, EventLogMessage eventLogMessage) {
    DataUpdateLogCommonNew logCommon = new DataUpdateLogCommonNew();
    logCommon.setEventLoggerFactory(eventLoggerFactory);
    logCommon.setLogServiceCore(logServiceCore);
    logCommon.setConfig(defaultDbConfig);
    logCommon.setTableName(tableName);
    logCommon.setWhereStr(whereStr);
    logCommon.setCommonEventLogMessage(eventLogMessage);
    return logCommon;
  }
  // DB更新ログ出力ロジック wangzuo End

  // #12625 2026.05.13 add 利用者削除時に仮想端末スタッフ一覧から対象ユーザーを削除 start
  /**
   * 内側 @Transactional メソッド {@link #deleteUserInTx(long)} の戻り値専用 DTO
   */
  private static final class DeleteUserInTxResult {
    final MasterUpdateResponse response;
    final String facilityCd;
    final Set<Integer> notifyDeviceEdgeNos;
    DeleteUserInTxResult(MasterUpdateResponse response, String facilityCd, Set<Integer> notifyDeviceEdgeNos) {
      this.response = response;
      this.facilityCd = facilityCd;
      // 防御的コピー。外側メソッドのループ中に内側が触りに来る経路はないが、
      // 不変DTOとして扱う意図を明示する。
      this.notifyDeviceEdgeNos = (notifyDeviceEdgeNos == null) ? new LinkedHashSet<>() : new LinkedHashSet<>(notifyDeviceEdgeNos);
    }
  }
  // #12625 2026.05.13 add 利用者削除時に仮想端末スタッフ一覧から対象ユーザーを削除 end
}
