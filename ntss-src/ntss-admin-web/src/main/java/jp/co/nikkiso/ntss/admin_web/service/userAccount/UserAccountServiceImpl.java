package jp.co.nikkiso.ntss.admin_web.service.userAccount;

import jp.co.nikkiso.ntss.admin_web.constant.MstToMongoEnum;
import jp.co.nikkiso.ntss.admin_web.request.userAccount.UpdateUserAccountInfoRequest;
import jp.co.nikkiso.ntss.admin_web.request.userAccount.UserAuthenticationRequest;
import jp.co.nikkiso.ntss.admin_web.response.userAccount.UserAccountResponse;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.FacilitySettingService;
import jp.co.nikkiso.ntss.admin_web.service.MongoService;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.DataSourceName;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.FacilitySettingNo;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.MstFacilityDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilityHashDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilitySettingDao;
import jp.co.nikkiso.ntss.core.dao.MstPersonalUserDao;
import jp.co.nikkiso.ntss.core.dao.MstUserAuthenticationDao;
import jp.co.nikkiso.ntss.core.dao.MstUserDao;
import jp.co.nikkiso.ntss.core.dao.MstUserSwitchDao;
import jp.co.nikkiso.ntss.core.dao.PatMainDao;
import jp.co.nikkiso.ntss.core.dao.PatUniqueDao;
import jp.co.nikkiso.ntss.core.entity.MstFacility;
import jp.co.nikkiso.ntss.core.entity.MstFacilityHash;
import jp.co.nikkiso.ntss.core.entity.MstFacilitySetting;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.entity.MstUser;
import jp.co.nikkiso.ntss.core.entity.MstUserAuthentication;
import jp.co.nikkiso.ntss.core.entity.MstUserSwitch;
import jp.co.nikkiso.ntss.core.entity.UserAuthentication;
import jp.co.nikkiso.ntss.core.entity.custom.FacilitySettingInfo;
import jp.co.nikkiso.ntss.core.entity.custom.UserAccountInfo;
import jp.co.nikkiso.ntss.core.exception.DataSourceInconsistencyException;
import jp.co.nikkiso.ntss.core.dto.userSwitchMapping.MstUserSwitchMapping;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import lombok.extern.slf4j.Slf4j;
import org.json.JSONArray;
import org.json.JSONObject;
import org.modelmapper.ModelMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.session.SessionRegistry;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

/**
 * アカウント編集画面のService実装クラス.
 */
@Service
@Slf4j
public class UserAccountServiceImpl implements UserAccountService {

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
   * 施設設定マスタのDaoインタフェース.
   */
  @Autowired
  private MstFacilitySettingDao mstFacilitySettingDao;

  // add #12587 スタッフ切替 start
  /**
   * 施設マスタのDaoインタフェース.
   */
  @Autowired
  private MstFacilityDao mstFacilityDao;

  /** 施設マスタハッシュ */
  @Autowired
  private MstFacilityHashDao mstFacilityHashDao;

  @Autowired
  private MstUserSwitchDao mstUserSwitchDao;
  // add #12587 スタッフ切替 end

  /**
   * パスワードエンコーダ.
   */
  @Autowired
  private PasswordEncoder passwordEncoder;

  /**
   * ロギングのServiceインタフェース.
   */
  @Autowired
  private LogService logService;

  // add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 dengshen start
  @Autowired
  private PatUniqueDao patUniqueDao;
  @Autowired
  private PatMainDao patMainDao;
  @Autowired
  private MongoService mongoService;
  // add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 dengshen end

  /* add by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
  @Autowired
  private FacilitySettingService facilitySettingService;
  /* add by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */

  /* del by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
  // // add #6587 利用者マスタで使用許可機能を編集した時にメッセージが出る場合とでない場合がある 王永吉 start
  // private Map<Long, MstUser> userMiddle = new ConcurrentHashMap<>();
  //
  // public void doInginSoming(boolean loginF, MstUser userData, Long userId){
  //   if (loginF){
  //     userMiddle.remove(userId);
  //   } else {
  //     userMiddle.put(userId, userData);
  //   }
  // }
  //
  // public MstUser getUserMiddle(Long userId){
  //   MstUser user = null;
  //   if (userMiddle.containsKey(userId)) {
  //     user = userMiddle.get(userId);
  //   } else {
  //     user = mstUserDao.selectById(userId);
  //   }
  //   return user;
  // }
  // // add #6587 利用者マスタで使用許可機能を編集した時にメッセージが出る場合とでない場合がある 王永吉 end
  /* del by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */
  
  // add #12587 スタッフ切替 start
  @Override
  public List<UserAuthentication> getCanLoginFacilities(Long userId) {
    return getCanLoginFacilitiesBuckling(userId);
  }
  // add #12587 スタッフ切替 end

  @Autowired
  private SessionRegistry sessionRegistry;
  
  /**
   * {@inheritDoc}
   */
  @Override
  public UserAccountResponse createUserAccountResponse(Long userId) {

    // ユーザIDを元に利用者マスタを取得
    MstPersonalUser personalUser = mstPersonalUserDao.selectById(userId);
    /* del by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
//     // mod #6587 利用者マスタで使用許可機能を編集した時にメッセージが出る場合とでない場合がある 王永吉 start
// //    MstUser user = mstUserDao.selectById(userId);
//     MstUser user = null;
//     // boolean inFalg = false;
//     // if (userMiddle != null){
//     //   for (Long userCd : userMiddle.keySet()){
//     //      if (userCd.equals(userId)){
//     //       inFalg = true;
//     //       break;
//     //     }
//     //   }
//     // }
//     if (userMiddle.containsKey(userId)) {
//       user = userMiddle.get(userId);
//     } else {
//       user = mstUserDao.selectById(userId);
//     }
//     // mod #6587 利用者マスタで使用許可機能を編集した時にメッセージが出る場合とでない場合がある 王永吉 end
    /* del by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
    /* add by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
    MstUser user = mstUserDao.selectById(userId);
    /* add by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */
    MstUserAuthentication userAuthentication = mstUserAuthenticationDao.selectById(userId);
	// add #12587 スタッフ切替 start
    // ログイン可能な施設取得
    List<UserAuthentication> canLoginFacilitiesBuckling = getCanLoginFacilitiesBuckling(userId);
	// add #12587 スタッフ切替 end
    // どれか一つでも検索結果0件の場合、失敗Responseを返す
    if (personalUser == null || user == null || userAuthentication == null) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("There is no UserAccountInfo.");
      logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.REMS, null);
      return new UserAccountResponse();
    }

    // 返却用Entityに値を設定
    UserAccountInfo userAccountInfo = new UserAccountInfo();
    ModelMapper modelMapper = new ModelMapper();
    modelMapper.map(personalUser, userAccountInfo);
    userAccountInfo.setDispUserId(userAuthentication.getDispUserId());
    userAccountInfo.setIsProvisional(user.getIsProvisional());
    userAccountInfo.setUserSettings(user.getUserSettings());
    userAccountInfo.setPatId(user.getPatId());
    userAccountInfo.setSecretKey(user.getSecretKey());
    userAccountInfo.setIsConsent(user.getIsConsent());
    userAccountInfo.setIsSetQrCode(user.getIsSetQrCode());
    userAccountInfo.setRegPasswordDate(user.getRegPasswordDate());
	// add #12587 スタッフ切替 start
    userAccountInfo.setCanLoginFacilities(canLoginFacilitiesBuckling);
	// add #12587 スタッフ切替 end
    // 成功レスポンスを返す
    return new UserAccountResponse(userAccountInfo);

  }

  /**
   * {@inheritDoc}
   */
  @Override
  public void updateUserAccountInfo(UpdateUserAccountInfoRequest request) {

    ModelMapper modelMapper = new ModelMapper();

    // パスワードが設定されていたらエンコードする
    String rawPassword = request.getUserPassword();
    String encodedPassword = "";

    if (!StringUtils.isEmpty(rawPassword)) {
      // エンコード処理
      encodedPassword = passwordEncoder.encode(rawPassword);
      request.setUserPassword(encodedPassword);

      JSONArray passwordHistory = updatePasswordHistory(encodedPassword, request.getUserId());
      request.setUserPasswordHistory(passwordHistory.toString());
    } else {
      request.setUserPassword(null);
      request.setUserPasswordHistory(null);
    }

    // 利用者マスタ(認証DB)更新処理 (dispUserId,userPassword)
	// add #12587 スタッフ切替 start
    // オブジェクト変換 + userId設定
    List<MstUserSwitchMapping> mappingList = setMappingUserId(request);
    // まず削除関係を処理
    long userId = request.getUserId();
    // 現在のユーザーの関係IDを取得
    String groupId = mstUserSwitchDao.selectGroupIdByUserId(userId);
    if (mappingList.isEmpty() && StringUtils.hasText(groupId)) {
      // 現在のユーザーに関係があり、かつ引数リストが空の場合
      // 関係を削除
      mstUserSwitchDao.deleteGroupIdByRefId(groupId);
    } else {
      if (!mappingList.isEmpty()) {
        // 引数リストが空でなく、かつ関係がある場合
        executionRelationshipMethod(request, groupId, mappingList);
      }
    }
	// add #12587 スタッフ切替 end
    int updateCount = mstUserAuthenticationDao.updateDispUserIdAndUserPassword(modelMapper.map(request, MstUserAuthentication.class));

    validateUpdateCount(updateCount, request.getUserId());

    // add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 dengshen start
    String userName = mstPersonalUserDao.selectUserNameById(request.getUserId());
    // add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 dengshen end

    // 利用者マスタ(個人情報DB)更新処理
    validateUpdateCount(mstPersonalUserDao.update(modelMapper.map(request, MstPersonalUser.class)), request.getUserId());

    if (!StringUtils.isEmpty(rawPassword)) {
      // 利用者マスタ パスワード変更日時更新処理
      validateUpdateCount(mstUserDao.updateRegPasswordDate(request.getUserId()), request.getUserId());
    }

    // add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 dengshen start
    //mod #11489 アカウント編集で保存しても処理中のまま zrx start
//    if (userName.equals(request.getUserLastName() + "　" + request.getUserFirstName())) {
    if (Objects.equals(userName, request.getUserLastName() + " " + request.getUserFirstName())) {
      return;
    }
    //mod #11489 アカウント編集で保存しても処理中のまま zrx end

    // 更新対象検索
    // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 start
    Map<String, Object> data = new HashMap<>();
    data.put("code", request.getUserId());
    data.put("name", request.getUserLastName() + "　" + request.getUserFirstName());
    mongoService.updateAndInsertPatMain(request.getFacilityCd(), null, false, Collections.singletonList(data), MstToMongoEnum.MSTUSER);
    mongoService.updateAndInsertPatUnique(request.getFacilityCd(), Collections.singletonList(data), MstToMongoEnum.MSTUSER);
    // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 end
    // add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 dengshen end
  }
  
  // add #12587 スタッフ切替 start
  private void executionRelationshipMethod(UpdateUserAccountInfoRequest request, String groupId, List<MstUserSwitchMapping> mappingList) {
    long updateUserId = getCurrentUserId();
    if (StringUtils.hasText(groupId)) {
      processRelationship(request, groupId, mappingList, updateUserId);

    } else {
      // 引数リストが空でなく、かつ現在のユーザーに関係がない場合
      processNoRelationship(request, mappingList, updateUserId);

    }
  }

  private void processRelationship(UpdateUserAccountInfoRequest request, String groupId, List<MstUserSwitchMapping> mappingList, long updateUserId) {
    // refIdを通じて既に紐付けされているすべての関係を取得
    List<Long> switchIdList = mstUserSwitchDao.selectSwitchIdsByGroupId(groupId);
    List<Long> collect = mappingList.stream().map(MstUserSwitchMapping::getSwitchId).toList();
    //找到自己的switchId
    Long switchId = mstUserSwitchDao.selectSwitchIdByUserId(request.getUserId());
    switchIdList.removeAll(collect);
    switchIdList.remove(switchId);
    //需要删除的id
    if (!switchIdList.isEmpty()) {
      mstUserSwitchDao.batchDeleteBySwitchId(switchIdList);
    }

    // 更新処理
    List<MstUserSwitchMapping> updateList = mappingList.stream().filter(u -> u.getSwitchId() != 0L).toList();
    List<MstUserSwitch> entityList = MstUserSwitchMapping.toEntityList(updateList);
    if (!entityList.isEmpty()) {
      mstUserSwitchDao.batchUpdate(entityList, updateUserId);
    }

    // 新規関係の追加処理
    List<MstUserSwitchMapping> insertList = mappingList.stream().filter(u -> u.getSwitchId() == 0L).toList();
    // 新規追加対象に既存の関係があるか確認
    // 更新が必要なgroupId
    String updateGroupId = "";

    // 2回目に修正する対象
    List<MstUserSwitchMapping> updateDto = new ArrayList<>();
    for (MstUserSwitchMapping mstUserSwitchMapping : insertList) {
      long userId = mstUserSwitchMapping.getUserId();
      if(userId < 1){
        continue;
      }
      Long switchId1 = mstUserSwitchDao.selectSwitchIdByUserId(userId);
      if(switchId1 != null && switchId1 > 0){
        mstUserSwitchMapping.setSwitchId(switchId1);
        updateGroupId = mstUserSwitchDao.selectGroupIdByUserId(userId);
        // ステータスを更新
        updateDto.add(mstUserSwitchMapping);
      }
    }

    if(!updateDto.isEmpty()){
      List<MstUserSwitch> entityList1 = MstUserSwitchMapping.toEntityList(updateDto);
      mstUserSwitchDao.batchUpdate(entityList1, updateUserId);
    }

    // 変更するgroupIdを更新
    List<String> list = new ArrayList<>();
    list.add(updateGroupId);
    // 変更後のgroupId
    String groupIdByUserId = mstUserSwitchDao.selectGroupIdByUserId(updateUserId);
    mstUserSwitchDao.batchRefreshGroupId(list,groupIdByUserId, updateUserId);

    insertList = mappingList.stream().filter(u -> u.getSwitchId() == 0L).toList();
    insertList.stream().forEach(mapping -> mapping.setGroupId(groupId));
    List<MstUserSwitch> entityList1 = MstUserSwitchMapping.toEntityList(insertList);
    if (!entityList1.isEmpty()) {
      entityList1.forEach(entity ->{
        entity.setRegStaff(updateUserId);
        entity.setUpStaff(updateUserId);
      });
      mstUserSwitchDao.batchInsertSwitchMapping(entityList1);
    }
  }

  private void processNoRelationship(UpdateUserAccountInfoRequest request, List<MstUserSwitchMapping> mappingList, long updateUserId) {
    // 新規関係の追加処理
    List<Long> list = mappingList.stream().map(MstUserSwitchMapping::getUserId).toList();
    // 引数リストのuserIdで関連関係があるか確認
    List<String> groupIdList = mstUserSwitchDao.selectGroupIdListByUserIds(list);

    if (groupIdList == null || groupIdList.isEmpty()) {
      // 関連関係がない場合、すべてのデータが新規追加
      // 直接新規追加
      MstUserSwitchMapping user = getMstUserSwitchMappingByLogInUser(request);
      mappingList.add(user);
      mappingList.forEach(mapping -> mapping.setGroupId(user.getGroupId()));

      // オブジェクト変換
      List<MstUserSwitch> entityList = MstUserSwitchMapping.toEntityList(mappingList);
      if (!entityList.isEmpty()) {
        entityList.forEach(entity ->{
          entity.setRegStaff(updateUserId);
          entity.setUpStaff(updateUserId);
        });
        mstUserSwitchDao.batchInsertSwitchMapping(entityList);
      }

    } else {
      // 現在のユーザーをswitchMappingテーブルに追加し、すべての関係を更新
      MstUserSwitchMapping user = getMstUserSwitchMappingByLogInUser(request);
      MstUserSwitch entity = MstUserSwitchMapping.toEntity(user);
      entity.setRegStaff(updateUserId);
      entity.setUpStaff(updateUserId);
      mstUserSwitchDao.insertUserSwitch(entity);

      // 操作対象ユーザーのステータスを更新
      for (MstUserSwitchMapping mstUserSwitchMapping : mappingList) {
        mstUserSwitchDao.updateStatusByUserId(mstUserSwitchMapping.getOptStatus(),mstUserSwitchMapping.getUserId(), updateUserId);
      }
      // 関係を更新
      if (!groupIdList.isEmpty() && StringUtils.hasText(user.getGroupId())) {
        mstUserSwitchDao.batchRefreshGroupId(groupIdList, user.getGroupId(), updateUserId);
      }
    }
  }

  private MstUserSwitchMapping getMstUserSwitchMappingByLogInUser(UpdateUserAccountInfoRequest request) {
    MstUserSwitchMapping user = new MstUserSwitchMapping();
    user.setGroupId(UUID.randomUUID().toString());
    user.setOptStatus("0");
    user.setUserId(request.getUserId());
    user.setFacilityCd(request.getFacilityCd());
    return user;
  }

  private List<MstUserSwitchMapping> setMappingUserId(UpdateUserAccountInfoRequest request) {
    List<MstUserSwitchMapping> mappingList = new ArrayList<>();
    for (UserAuthenticationRequest userAuthenticationRequest : request.getCanLoginFacilitiesList()) {
      // オブジェクト変換
      MstUserSwitchMapping mapping = new MstUserSwitchMapping();
      // まずuserIdを設定
      MstFacilityHash mstFacilityHash = mstFacilityHashDao.selectByHashValue(userAuthenticationRequest.getFacilityHash());
      if (mstFacilityHash == null) {
        continue;
      }
      String userId = mstUserAuthenticationDao.selectUserId(userAuthenticationRequest.getUsername(), mstFacilityHash.getFacilityCd());
      mapping.setUserId(Long.parseLong(userId));
      mapping.setSwitchId(userAuthenticationRequest.getSwitchId());
      mapping.setOptStatus(userAuthenticationRequest.getOptStatus());
      mapping.setFacilityCd(mstFacilityHash.getFacilityCd());
      mappingList.add(mapping);
    }
    return mappingList;
  }
  // add #12587 スタッフ切替 end

  /**
   * 更新件数を判定してデータソース間不整合例外を投げる.
   *
   * @param updateCount 更新件数
   * @param userId      ユーザーID
   */
  private void validateUpdateCount(int updateCount, Long userId) {
    if (updateCount != 1) {
      // DBの更新件数が1以外の場合、データソース間不整合を返し、Rollbackさせる
      throw new DataSourceInconsistencyException(userId, DataSourceName.AUTH, DataSourceName.PERSONAL);
    }
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public long selectDuplicateCount(String dispUserId, Long userId) {
    final MstUserAuthentication entity = mstUserAuthenticationDao.selectById(userId);
    final String facilityCd = (entity.getFacilityCd() == null) ? "" : entity.getFacilityCd();
    return mstUserAuthenticationDao.selectDispUserId(dispUserId, facilityCd)
      .stream()
      .filter(e -> facilityCd.equals(e.getFacilityCd()))
      .filter(e -> !userId.equals(e.getUserId()))
      .filter(e -> dispUserId.equals(e.getDispUserId()))
      .count();
  }

  /**
   * {@inheritDoc}
   */
  public Boolean isMatchCurrentPassword(String CurrentPassword, Long userId) {
    final MstUserAuthentication entity = mstUserAuthenticationDao.selectById(userId);
    return passwordEncoder.matches(CurrentPassword, entity.getUserPassword());
  }

  /**
   * {@inheritDoc}
   */
  public JSONArray updatePasswordHistory(String encodedPassword, Long userId) {
    // パスワード履歴の更新: パスワード履歴のJSONArrayを作成
    JSONArray passwordHistory = null;
    MstUserAuthentication auth = mstUserAuthenticationDao.selectById(userId);
    if (auth.getUserPasswordHistory() != null) {
      passwordHistory = new JSONArray(auth.getUserPasswordHistory());
    } else {
      passwordHistory = new JSONArray();
    }

    // パスワード履歴の更新: 今回追加分のパスワードを追加
    JSONObject newPassword = new JSONObject();
    newPassword.put("password", encodedPassword);
    passwordHistory.put(newPassword);

    // パスワード履歴の更新: 9世代以上ある場合は一番先頭のデータを削除
    while (passwordHistory.length() > 9) {
      passwordHistory.remove(0);
    }
    return passwordHistory;
  }

  /**
   * {@inheritDoc}
   */
  public Boolean isAvailablePassword(Long userId, String newPassword, String facilityCd) {
    // パスワード履歴のJSONArrayを取得
    final MstUserAuthentication auth = mstUserAuthenticationDao.selectById(userId);
    JSONArray passwordHistory = null;
    if (auth.getUserPasswordHistory() != null) {
      passwordHistory = new JSONArray(auth.getUserPasswordHistory());
    } else {
      // userPasswordHistoryがnullの場合、パスワード履歴が無いので利用可能(true)
      return true;
    }
    Integer historyNumber = passwordHistory.length();

    // 再利用禁止世代を取得
    FacilitySettingInfo passwordReuseProhibited = mstFacilitySettingDao.getBySettingNoAndCd(facilityCd, FacilitySettingNo.PASSWORD_REUSE_PROHIBITED);
    Integer prohibitedGeneration = Integer.valueOf(passwordReuseProhibited.getValue());

    // パスワード履歴との突合せ
    for (Integer i = 1; i <= prohibitedGeneration; i++) {
      Integer index = historyNumber - i;
      if (index < 0) {
        break;
      }

      try {
        JSONObject passwordData = passwordHistory.getJSONObject(index);
        if (passwordEncoder.matches(newPassword, passwordData.getString("password"))) {
          return false;
        }
      } catch (Exception e) {
        // エラー発生時、処理を終了する
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("Password availability check failed.");
        logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.REMS, null);
        return false;
      }

    }
    return true;
  }

  /*add FNSI-改修内容全体の合否が俯瞰できるように修正 任 start*/
  @Override
  public List<MstPersonalUser> selectAllUser(String facilityCd) {
    return mstPersonalUserDao.selectAllUser(facilityCd, "0");
  }
  /*add FNSI-改修内容全体の合否が俯瞰できるように修正 任 end*/

  // add #12587 スタッフ切替 start
  /**
   * システム日時を取得します
   * @return システム日時
   */
  private java.sql.Timestamp getCurrentDate() {
    return new java.sql.Timestamp(System.currentTimeMillis());
  }

  public List<UserAuthentication> getCanLoginFacilitiesBuckling(Long userId) {

    List<UserAuthentication> reversedList = new ArrayList<>();

    // UserIdを通じて自分以外のすべての関係を取得

    List<MstUserSwitch> switchList =  mstUserSwitchDao.selectSwitchListByUserId(userId);

    List<MstUserSwitchMapping> dtoList = MstUserSwitchMapping.toDtoList(switchList);

    for (MstUserSwitchMapping mapping : dtoList) {
      UserAuthentication authentication = new UserAuthentication();

      MstFacilityHash mstFacilityHash = mstFacilityHashDao.selectByFacilityCd(mapping.getFacilityCd());
      if(mstFacilityHash == null){
        continue;
      }
      MstFacility mstFacility = mstFacilityDao.selectByCd(mapping.getFacilityCd());
      authentication.setFacilityHash(mstFacilityHash.getHashValue());
      if(mstFacility == null){
        continue;
      }
      authentication.setFacilityName(mstFacility.getFacilityName());
      MstUserAuthentication mstUserAuthentication = mstUserAuthenticationDao.selectById(mapping.getUserId());
      if(mstUserAuthentication == null){
        continue;
      }
      authentication.setUsername(mstUserAuthentication.getDispUserId());
      authentication.setOptStatus(mapping.getOptStatus());
      authentication.setSwitchId(mapping.getSwitchId());
      // ボタン状態とメッセージを判定
      setButtonStatus(mapping, authentication);

      reversedList.add(authentication);
    }

    return reversedList;

  }

  private void setButtonStatus(MstUserSwitchMapping mapping, UserAuthentication authentication) {
    MstFacilitySetting mstFacilitySettingByFacilityCd = mstFacilitySettingDao.getMstFacilitySettingByFacilityCd(mapping.getFacilityCd());
    if(mstFacilitySettingByFacilityCd == null){
      mstFacilitySettingByFacilityCd = new MstFacilitySetting();
      mstFacilitySettingByFacilityCd.setValue("0");
    }
    // システム状態
    String value = mstFacilitySettingByFacilityCd.getValue();
    // 関係テーブルの状態
    String optStatus = mapping.getOptStatus();
    MstUser user = mstUserDao.selectById(mapping.getUserId());
    switch (optStatus){
      case "0":
      case "2":
        if("1".equals(value)){
          if(StringUtils.hasText(user.getSecretKey()) && user.getIsSetQrCode() == 1){
            setMassage(authentication,"ユーザー["+authentication.getUsername()+"]の2要素認証情報が変更されました。再認証して下さい。",true);
            authentication.setSecretKey(user.getSecretKey());
          }
        }else if("2".equals(value)){
          if(StringUtils.hasText(user.getSecretKey()) && user.getIsSetQrCode() == 1){
            setMassage(authentication,"ユーザー["+authentication.getUsername()+"]の2要素認証情報が変更されました。再認証して下さい。",true);
            authentication.setSecretKey(user.getSecretKey());
          }else{
            setMassage(authentication,"ユーザー["+authentication.getUsername()+"]の2要素認証が設定されていませんので、切り替えできません。",false);
          }
        }
        break;
    }
  }

  private static void setMassage(UserAuthentication authentication,String massage,boolean optAuth) {
    authentication.setShowButton(false);
    authentication.setMassage(massage);
    authentication.setOptAuth(optAuth);
  }

  @Override
  public String getHashByCd(String facilityCd) {
    MstFacilityHash mstFacilityHash = mstFacilityHashDao.selectByFacilityCd(facilityCd);
    if (mstFacilityHash != null) {
      return mstFacilityHash.getHashValue();
    }
    return "";
  }
  @Override
  public void updateOptStatus(String status,long userId) {
    long updateUserId = getCurrentUserId();

    mstUserSwitchDao.updateStatusByUserId(status,userId,updateUserId);
  }

  private long getCurrentUserId() {
    Authentication authentication =
      SecurityContextHolder.getContext().getAuthentication();
    long updateUserId = 0L;
    if(authentication.getPrincipal() instanceof NtssUser principal){
      updateUserId = principal.getUserId();
    }
    return updateUserId;
  }

  @Override
  public String getGroupId(long userId) {
    return mstUserSwitchDao.selectGroupIdByUserId(userId);
  }
  // add #12587 スタッフ切替 end
}
