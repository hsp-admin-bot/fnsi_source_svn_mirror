package jp.co.nikkiso.ntss.admin_web.web.rest;

import java.util.List;
import java.util.Map;

import jp.co.nikkiso.ntss.core.dao.MstFacilityDao;
import jp.co.nikkiso.ntss.core.entity.MstFacility;
import org.apache.commons.lang3.RandomStringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.Uri;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.FUNCTION_CODE;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.FacilitySettingNo;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebMessage;
import jp.co.nikkiso.ntss.admin_web.response.masterMaintenance.MasterDataResponse;
import jp.co.nikkiso.ntss.admin_web.response.masterMaintenance.MasterUpdateResponse;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.MstInfoService;
import jp.co.nikkiso.ntss.admin_web.service.FacilitySettingService;
import jp.co.nikkiso.ntss.admin_web.service.MstFacilityService;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.master.user.MstUserService;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.entity.custom.MstUserData;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import lombok.extern.slf4j.Slf4j;

import java.util.ArrayList;
import java.util.HashMap;

/**
 * 利用者マスタ画面のResourceクラス.
 */
@RestController
@Slf4j
@RequestMapping(Uri.MASTER_MAINTENANCE)
public class UserMasterMaintenanceResource {

  /**
   * 利用者一覧Service.
   */
  @Autowired
  private MstUserService mstUserService;

  /**
   * マスタService.
   */
  @Autowired
  MstInfoService mstInfoService;

  @Autowired
  LogService logService;

  @Autowired
  FacilitySettingService facilitySettingService;

  @Autowired
  MstFacilityService mstFacilityServiceImpl;

  /**
   * 施設マスタのDaoインタフェース.
   */
  @Autowired
  private MstFacilityDao mstFacilityDao;

  /**
   * 利用者マスタデータ取得.
   *
   * @param facilityCd 取得対象の施設コード
   * @return 利用者マスタデータのResponse
   *
   */
  @GetMapping("/mst_user/{facilityCd}")
  public ResponseEntity<?> getMasterData(@PathVariable String facilityCd, @AuthenticationPrincipal NtssUser ntssUser) {

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get master : mst_user");
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE,SERVICE_NAME.FNSI, null);

    try {
      // レスポンス生成
      MasterDataResponse response = mstUserService.getMasterData(facilityCd, facilityCd.equals(ntssUser.getFacilityCd()));
      return new ResponseEntity<>(response, HttpStatus.OK);
    } catch (Exception e) {

      // マスタ定義が取得できなかった場合
      eventLogMessage.setLogMessage("Exception message : " + e.getMessage());
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.MASTER_RECORD_ERROR.getMessage()),
          HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * 利用者マスタデータ取得.
   *
   * @param facilityCd 取得対象の施設コード
   * @return 利用者マスタデータのResponse
   *
   */
  @GetMapping("/mst_user/mst_personal_user/{facilityCd}")
  public ResponseEntity<?> getMasterUserJobData(@PathVariable String facilityCd, @AuthenticationPrincipal NtssUser ntssUser) {

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get master : mst_pat_event_data_template");
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE,SERVICE_NAME.FNSI, null);

    try {
      // レスポンス生成
      List<Map<String, Object>>  response = mstUserService.selectUserDataByFacilityCd(facilityCd, facilityCd.equals(ntssUser.getFacilityCd()));
      return new ResponseEntity<>(response, HttpStatus.OK);
    } catch (Exception e) {

      // マスタ定義が取得できなかった場合
      eventLogMessage.setLogMessage("Exception message : " + e.getMessage());
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.MASTER_RECORD_ERROR.getMessage()),
          HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * 利用者表示順マスタデータ取得.
   *
   * @param facilityCd 取得対象の施設コード
   * @return 利用者マスタデータのResponse
   *
   */
  @GetMapping("/mst_user/sortList/{facilityCd}")
  public ResponseEntity<?> getSortMasterData(@PathVariable String facilityCd, @AuthenticationPrincipal NtssUser ntssUser) {

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get master : mst_user(sortList)");
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI, null);

    try {
      // レスポンス生成
      MasterDataResponse response = mstUserService.getSortMasterData(facilityCd, facilityCd.equals(ntssUser.getFacilityCd()));
      return new ResponseEntity<>(response, HttpStatus.OK);
    } catch (Exception e) {

      // マスタ定義が取得できなかった場合
      eventLogMessage.setLogMessage("Exception message : " + e.getMessage());
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.MASTER_RECORD_ERROR.getMessage()),
          HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * 施設マスタデータ取得.
   *
   * @return 施設マスタデータのResponse
   *
   */
  @GetMapping("/mst_user/mst_facility")
  public ResponseEntity<?> getFacilityData() {

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get master : mst_facility");
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI, null);

    try {
      // レスポンス生成
      return new ResponseEntity<>(mstUserService.selectMstFacility(), HttpStatus.OK);
    } catch (Exception e) {

      // マスタ定義が取得できなかった場合
      eventLogMessage.setLogMessage("Exception message : " + e.getMessage());
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.MASTER_RECORD_ERROR.getMessage()),
          HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * 職種データ取得.
   *
   * @param facilityCd 職種一覧を取得する施設コード
   * @return 対象施設の職種データのResponse
   *
   */
  @GetMapping("/mst_user/mst_job/{facilityCd}")
  public ResponseEntity<?> getJobData(@PathVariable String facilityCd) {

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get master job : " + facilityCd);
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI, null);

    try {
      return new ResponseEntity<>(mstInfoService.findMstJobByFacilityCd(facilityCd), HttpStatus.OK);
    } catch (Exception e) {

      // マスタ定義が取得できなかった場合
      eventLogMessage.setLogMessage("Exception message : " + e.getMessage());
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.MASTER_RECORD_ERROR.getMessage()),
          HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * 新規利用者登録.
   *
   * @param facilityCd ユーザを追加する施設コード
   * @return 登録結果
   *
   */
  @GetMapping("/mst_user/add_user/{facilityCd}")
  public ResponseEntity<?> insertNewUser(@PathVariable String facilityCd) {

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to insert new user : " + facilityCd);
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI, null);

    // ユーザー追加処理実行
    return insNewUsr(facilityCd);
  }

  /**
   * 施設マスタのVPNセット、対応するURLを取得
   *
   * @param facilityCd 施設コード
   * @return
   */
  @GetMapping("/mst_user/get_vpn_set/{facilityCd}")
  public ResponseEntity<?> getVpnSet(@PathVariable String facilityCd) {
    String loginUrl = "";
    HashMap<String, String> resData = new HashMap<>();
    // 施設マスタのVPNセットを取得
    MstFacility mstFacility = mstFacilityDao.selectByCd(facilityCd);
    resData.put("vpnSet", mstFacility.getVpnSet());
    if ("2".equals(mstFacility.getVpnSet())) {
      // VPNセットが「CL証明書URLおよびVPN用URLを表示」であれば、VPNのURLを生成して応答に含める
      String urlCom = mstUserService.getUrlCom("urlVpn");
      String urlHash = mstUserService.getUrlHash(facilityCd);
      loginUrl = urlCom + urlHash;
    }
    resData.put("url2", loginUrl);
    return new ResponseEntity<>(resData, HttpStatus.OK);
  }

  // 戻り値用
  private ResponseEntity<?> insNewUsr(String facilityCd) {
    try {
      // 仮表示用ユーザID設定
      String dispUserId = getDispUserId(facilityCd);
      // パスワードポリシー適用レベル取得
      int pwLvl = Integer.parseInt(facilitySettingService.getFacilitySettingValue(facilityCd, FacilitySettingNo.PASSWORD_POLICY));
      // パスワード文字数取得
      int pwCnt = Integer.parseInt(facilitySettingService.getFacilitySettingValue(facilityCd, FacilitySettingNo.NUM_OF_PASSWORD));
      // 仮パスワード設定
      String password = randomPassword(pwLvl, pwCnt);

      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("New Password generated");
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE,SERVICE_NAME.FNSI, null);

      // 追加ユーザ用情報を作成
      MstUserData mstUser = new MstUserData()
      {
        {
          setFacilityCd(facilityCd);
          setDispUserId(dispUserId);
          setUserPassword(password);
          setUserType(facilityCd.equals("nkknkk") ? 1 : 0);
          setAdministrator(0);
          setUserLastName("新規");
          setUserFirstName("ユーザー");
          setIsProvisional(1);
          setFailure_cnt(0);
        }
      };

      // 登録処理
      mstUserService.registNewUser(mstUser);

      // 更新成功時には印刷用モーダル画面に表示する情報を返却する
      String loginUrl = getLoginUrl(facilityCd, false);
      String facilityName = mstUserService.getFacilityName(facilityCd);

      mstUser.setLoginUrl(loginUrl);
      mstUser.setFacilityName(facilityName);
      mstUser.setSystemUseSetting(mstFacilityServiceImpl.getMstFacilityHashByFacilityCd(facilityCd).getSystemUseSetting());
      // レスポンスに設定
      return new ResponseEntity<>(mstUser, HttpStatus.OK);
    } catch (DuplicateKeyException e) {
      // （dispUserIdの重複で）更新処理ができなかった場合、リトライする
      return insNewUsr(facilityCd);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("Exception message : " + e.getMessage());
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage()), HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 在宅患者新規利用者登録.
   *
   * @param facilityCd ユーザを追加する施設コード
   * @return 登録結果
   *
   */
  @PutMapping("/mst_user/add_pat_user")
  public ResponseEntity<?> insertNewPatUser(@RequestBody Map<String, String> patData) {

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to insert new user : " + patData);
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI, null);

    // 存在チェックを行う
    int isExist = mstUserService.getUserByPatId(Long.parseLong(patData.get("patId")));

    // すでにレコードが存在する場合、追加処理を行わない
    if (isExist > 0) {
      MstUserData mstUser = new MstUserData();
      mstUser.setPatFlg(true);
      return new ResponseEntity<>(mstUser, HttpStatus.OK);
    }
    // ユーザー追加処理実行
    return insNewPatUsr(patData);
  }

  private ResponseEntity<?> insNewPatUsr(Map<String, String> patData) {
    try {
      // 仮表示用ユーザID設定
      String dispUserId = getDispUserId(patData.get("facilityCd"));
      // パスワードポリシー適用レベル取得
      int pwLvl = Integer.parseInt(facilitySettingService.getFacilitySettingValue(patData.get("facilityCd"), FacilitySettingNo.PASSWORD_POLICY));
      // パスワード文字数取得
      int pwCnt = Integer.parseInt(facilitySettingService.getFacilitySettingValue(patData.get("facilityCd"), FacilitySettingNo.NUM_OF_PASSWORD));
      // 仮パスワード設定
      String password = randomPassword(pwLvl, pwCnt);

      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("New Password generated");
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI, null);

      // 追加ユーザ用情報を作成
      MstUserData mstUser = new MstUserData()
      {
        {
          setFacilityCd(patData.get("facilityCd"));
          setDispUserId(dispUserId);
          setUserPassword(password);
          setUserType(patData.get("facilityCd").equals("nkknkk") ? 1 : 0);
          setAdministrator(0);
          setUserLastName(patData.get("userLastName"));
          setUserFirstName(patData.get("userFirstName"));
          setIsProvisional(1);
          setFailure_cnt(0);
          setPatId(Long.parseLong(patData.get("patId")));
        }
      };

      // 登録処理
      mstUserService.registNewPatUser(mstUser);

      // 更新成功時には印刷用モーダル画面に表示する情報を返却する
      String loginUrl = getLoginUrl(patData.get("facilityCd"), true);
      String facilityName = mstUserService.getFacilityName(patData.get("facilityCd"));

      mstUser.setLoginUrl(loginUrl);
      mstUser.setFacilityName(facilityName);
      mstUser.setSystemUseSetting(mstFacilityServiceImpl.getMstFacilityHashByFacilityCd(patData.get("facilityCd")).getSystemUseSetting());
      // レスポンスに設定
      return new ResponseEntity<>(mstUser, HttpStatus.OK);
    } catch (DuplicateKeyException e) {
      // （dispUserIdの重複で）更新処理ができなかった場合、リトライする
      return insNewPatUsr(patData);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("Exception message : " + e.getMessage());
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage()), HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 管理者フラグ更新.
   *
   * @param userId 更新対象の利用者ID
   * @param adminFlg 管理者フラグの値
   * @return 利用者マスタデータのResponse
   *
   */
  @PutMapping("/mst_user/administrator/{userId}/{adminFlg}")
  public ResponseEntity<?> updateAdministratorFlg(@PathVariable String userId, @PathVariable String adminFlg) {

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to update administrator : " + userId);
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI, null);

    try {
    // 更新処理
      MasterUpdateResponse response = mstUserService.updAdministrator(Long.parseLong(userId), Integer.parseInt(adminFlg));
      return new ResponseEntity<>(response, HttpStatus.OK);
    } catch (Exception e) {
      // 更新処理ができなかった場合
      eventLogMessage.setLogMessage("Exception message : " + e.getMessage());
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage()),
          HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 患者共有フラグ更新.
   *
   * @param userId 更新対象の利用者ID
   * @param patientSharedFlg 患者共有フラグの値
   * @return 利用者マスタデータのResponse
   *
   */
  @PutMapping("/mst_user/patientShared/{userId}/{patientSharedFlg}")
  public ResponseEntity<?> updatePatientSharedFlg(@PathVariable String userId, @PathVariable String patientSharedFlg) {

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to update administrator : " + userId);
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI, null);

    try {
      // 更新処理
      MasterUpdateResponse response = mstUserService.updPatientShared(Long.parseLong(userId), Integer.parseInt(patientSharedFlg));
      return new ResponseEntity<>(response, HttpStatus.OK);
    } catch (Exception e) {
      // 更新処理ができなかった場合
      eventLogMessage.setLogMessage("Exception message : " + e.getMessage());
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage()),
          HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 患者共有フラグ取得.
   *
   * @param userId 更新対象の利用者ID
   * @return 患者共有フラグ
   *
   */
  @GetMapping("/mst_user/patientShared/{userId}")
  public ResponseEntity<?> getPatientSharedFlg(@PathVariable String userId) {

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get administrator : " + userId);
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI, null);

    try {
      // レスポンス生成
      return new ResponseEntity<>(mstUserService.selectPatientSharedFlgById(Long.parseLong(userId)), HttpStatus.OK);
    } catch (Exception e) {

      // マスタ定義が取得できなかった場合
      eventLogMessage.setLogMessage("Exception message : " + e.getMessage());
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.MASTER_RECORD_ERROR.getMessage()),
        HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * 表示用利用者ID/パスワードリセット.
   *
   * @param facilityCd 利用者の拠点コード
   * @param userId 更新対象の利用者ID
   * @return 利用者マスタデータのResponse
   *
   */
  @GetMapping("/mst_user/password/{facilityCd}/{userId}")
  public ResponseEntity<?> updatePassword(@PathVariable String facilityCd, @PathVariable String userId) {

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to update password : " + userId);
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI, null);

    // 更新処理実行
    return updPwd(facilityCd, userId, false);
  }

  /**
  * 表示用利用者(患者)ID/パスワードリセット.
  *
  * @param facilityCd 利用者の拠点コード
  * @param userId 更新対象の利用者ID
  * @return 利用者マスタデータのResponse
  *
  */
  @GetMapping("/mst_user/pat_password/{facilityCd}/{userId}")
  public ResponseEntity<?> updatePatPassword(@PathVariable String facilityCd, @PathVariable String userId) {

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to update pat password : " + userId);
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI, null);

    // 更新処理実行
    return updPwd(facilityCd, userId, true);
  }

  // 戻り値用
  private ResponseEntity<?> updPwd(String facilityCd, String userId, boolean patFlg) {
    try {
      // 仮表示用ユーザID設定
      String dispUserId = getDispUserId(facilityCd);
      // パスワードポリシー適用レベル取得
      int pwLvl = Integer.parseInt(facilitySettingService.getFacilitySettingValue(facilityCd, FacilitySettingNo.PASSWORD_POLICY));
      // パスワード文字数取得
      int pwCnt = Integer.parseInt(facilitySettingService.getFacilitySettingValue(facilityCd, FacilitySettingNo.NUM_OF_PASSWORD));
      // 仮パスワード設定
      String password = randomPassword(pwLvl, pwCnt);

      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("New Password generated");
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI, null);

      // 更新処理
      mstUserService.resetPassword(Long.parseLong(userId), dispUserId, password);

      // 更新成功時には印刷用モーダル画面に表示する情報を返却する
      String loginUrl = getLoginUrl(facilityCd, patFlg);
      String facilityName = mstUserService.getFacilityName(facilityCd);

      MstUserData updData = new MstUserData()
      {
        {
          setDispUserId(dispUserId);
          setUserPassword(password);
          setLoginUrl(loginUrl);
          setFacilityName(facilityName);
        }
      };
      updData.setSystemUseSetting(mstFacilityServiceImpl.getMstFacilityHashByFacilityCd(facilityCd).getSystemUseSetting());
      // レスポンスに設定
      return new ResponseEntity<>(updData, HttpStatus.OK);
    } catch (DuplicateKeyException e) {
      // （dispUserIdの重複で）更新処理ができなかった場合、リトライする
      return updPwd(facilityCd, userId, patFlg);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("Exception message : " + e.getMessage());
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage()), HttpStatus.BAD_REQUEST);
    }
  }

  // 仮パスワード作成
  private String randomPassword(int level, int count) {
    // ランダム用文字
    String upperCase = "ABCDEFGHJKLMNPQRSTUVWXYZ";
    String lowerCase = "abcdefghijkmnopqrstuvwxyz";
    String numbers = "23456789";
    String specialCharacters = "&%$#@!_-";
    // #12731対応時の仕様メモ：
    // 次の文字は見分けづらいため生成するパスワードには使用しない： 0 1 I O l
    String characters = "";
    // ランダム種類用フラグ
    boolean upperFlg = false;
    boolean lowerFlg = false;
    boolean numbersFlg = false;
    boolean specialFlg = false;

    // パスワードポリシー適用レベルの判定
    if (level == 1) {
      // 無し
      upperFlg = true;
      lowerFlg = true;
      characters = upperCase + lowerCase;
    } else if (level == 2) {
      // ポリシー低
      lowerFlg = true;
      numbersFlg = true;
      characters = lowerCase + numbers;
    } else if (level == 3) {
      // ポリシー中
      lowerFlg = true;
      numbersFlg = true;
      specialFlg = true;
      characters = lowerCase + numbers + specialCharacters;
    } else {
      // ポリシー高
      upperFlg = true;
      lowerFlg = true;
      numbersFlg = true;
      specialFlg = true;
      characters = upperCase + lowerCase + numbers + specialCharacters;
    }

    // パスワードポリシー適用レベルによるランダム種類が含まれているための処理
    List<String> lstString = new ArrayList<>();
    for (int i = 1; i <= count; i++) {
      if (upperFlg) {
        upperFlg = false;
        lstString.add(RandomStringUtils.random(1, upperCase));
      } else if (lowerFlg) {
        lowerFlg = false;
        lstString.add(RandomStringUtils.random(1, lowerCase));
      }  else if (numbersFlg) {
        numbersFlg = false;
        lstString.add(RandomStringUtils.random(1, numbers));
      } else if (specialFlg) {
        specialFlg = false;
        lstString.add(RandomStringUtils.random(1, specialCharacters));
      } else {
        lstString.add(RandomStringUtils.random(1, characters));
      }
    }

    // 該当のランダム種類が含まれている文字列をshuffleする
    StringBuilder sb = new StringBuilder(count);
    while (lstString.size() != 0) {
      int randPicker = (int)(Math.random() * lstString.size());
      sb.append(lstString.remove(randPicker));
    }
    return sb.toString();
  }

  /**
   * ログイン失敗回数リセット.
   *
   * @param userId 更新対象の利用者ID
   * @return 利用者マスタデータのResponse
   *
   */
  @PutMapping("/mst_user/failure_cnt/{userId}")
  public ResponseEntity<?> updateFailureCnt(@PathVariable String userId) {

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to update failureCnt : " + userId);
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI, null);
    try {
      // 更新処理
      MasterUpdateResponse response = mstUserService.resetFailureCnt(Long.parseLong(userId));
      return new ResponseEntity<>(response, HttpStatus.OK);
    } catch (Exception e) {
      // 更新処理ができなかった場合
      eventLogMessage.setLogMessage("Exception message : " + e.getMessage());
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage()),
          HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * ユーザ削除.
   *
   * @param userId 削除対象の利用者ID
   * @return 利用者マスタデータのResponse
   *
   */
  @PutMapping("/mst_user/delete/{userId}")
  public ResponseEntity<?> deleteUser(@PathVariable String userId) {

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to delete user : " + userId);
    logService.log(LogLevel.DEBUG, eventLogMessage,FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI, null);

    try {
     // 更新処理
      MasterUpdateResponse response = mstUserService.deleteUser(Long.parseLong(userId));
      return new ResponseEntity<>(response, HttpStatus.OK);
    } catch (Exception e) {
      // 更新処理ができなかった場合
      eventLogMessage.setLogMessage("Exception message: " + e.getMessage());
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage()),
          HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 表示用ユーザIDを取得.
   *
   * @param facilityCd 削除対象の利用者ID
   * @return 表示用ユーザID
   *
   */
  private String getDispUserId(@PathVariable String facilityCd) {

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to Get DispUserId : " + facilityCd);
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI, null);

    try {
      // 取得処理
      String response = RandomStringUtils.randomNumeric(10);
      eventLogMessage.setLogMessage("New DispUserId Is : " + response);
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI, null);

      return response;
    } catch (Exception e) {
      // データ取得ができなかった場合
      eventLogMessage.setLogMessage("Exception message : " + e.getMessage());
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI, null);
      return null;
    }
  }

  /**
   * ログイン用URL文字列を生成.
   *
   * @param facilityCd 利用者の拠点コード
   * @param patFlg 利用者が患者の場合にtrue
   * @return url 対象施設へのログインURL
   *
   */
  private String getLoginUrl(String facilityCd, boolean patFlg) {
    String key = "";
    if (patFlg) {
      key = "urlHomeDialysis";
    } else {
      MstFacility mstFacility = mstFacilityDao.selectByCd(facilityCd);
      String loginMethod = mstFacility.getVpnSet();
      if ("1".equals(loginMethod)) {
        key = "urlVpn";
      } else if ("2".equals(loginMethod) || "3".equals(loginMethod)) {
        key = "urlCL";
      } else {
        // 初期値の「0」、又は空だった場合
        key = "url";
      }
    }

    String urlCom;
    try {
      // ログインURL(共通)を取得
      urlCom = mstUserService.getUrlCom(key);
    } catch (Exception e) {
      // データ取得ができなかった場合
      urlCom = mstUserService.getUrlCom("url");
    }

    // 対象拠点のハッシュ値を取得
    String urlHash = "";
    if (patFlg) {
      urlHash = mstUserService.getUrlPatHash(facilityCd);
    } else {
      urlHash = mstUserService.getUrlHash(facilityCd);
    }
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("LoginURL Is : " + urlCom + urlHash);
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI, null);

    return urlCom + urlHash;
  }

  /**
   * 削除対象メールアドレスリストの取得.
   *
   * @param userEmailAddress 削除するメールアドレス
   * @return 削除対象メールアドレスリストのResponse
   *
   */
  @GetMapping("/mst_user/user_email_address/{userEmailAddress}")
  public ResponseEntity<?> getDeleteTargetEmailAddress(@PathVariable String userEmailAddress) {

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to get master : mst_user/user_email_address");
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI, null);

    try {
      // レスポンス生成
      return new ResponseEntity<>(mstUserService.getDeleteTarget(userEmailAddress), HttpStatus.OK);
    } catch (Exception e) {

      // 取得できなかった場合
      eventLogMessage.setLogMessage("Exception message : " + e.getMessage());
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.MASTER_RECORD_ERROR.getMessage()),
          HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * 削除対象メールアドレスの削除(nullでアップデート).
   *
   * @param userEmailAddress 削除対象のリスト
   * @return 削除対象メールアドレスリストのResponse
   *
   */
  @PutMapping("/mst_user/user_email_address/delete")
  public ResponseEntity<?> deleteEmailAddress(@RequestBody List<MstUserData> userEmailAddress) {

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to delete email address");
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI, null);
    try {
      // 削除処理
      MasterUpdateResponse response = mstUserService.deleteEmailAddress(userEmailAddress);
      return new ResponseEntity<>(response, HttpStatus.OK);
    } catch (Exception e) {
      // 更新処理ができなかった場合
      eventLogMessage.setLogMessage("Exception message: " + e.getMessage());
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage()),
          HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 職種変更.
   *
   * @param userId 更新対象の利用者ID
   * @param jobCd 更新対象の職種コード
   * @return 利用者マスタデータのResponse
   *
   */
  @PutMapping("/mst_user/chg_job/{userId}/{jobCd}")
  public ResponseEntity<?> updateJobCd(@PathVariable String userId, @PathVariable String jobCd) {

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to update jobCd : " + userId);
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI, null);

    try {
      // 更新処理
      MasterUpdateResponse response = mstUserService.updateJobCd(Long.parseLong(userId), jobCd);
      return new ResponseEntity<>(response, HttpStatus.OK);
    } catch (Exception e) {
      // 更新処理ができなかった場合
      eventLogMessage.setLogMessage("Exception message : " + e.getMessage());
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage()),
          HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * ユーザの個人情報を更新する.
   *
   * @param userEmailAddress 削除対象のリスト
   * @return 削除対象メールアドレスリストのResponse
   *
   */
  @PutMapping("/mst_user/updatePersonalInfo")
  public ResponseEntity<?> updateUserPersonalInfo(@RequestBody MstUserData userPersonalInfo) {

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to update user personal info");
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI, null);

    try {
      // 削除処理
      MasterUpdateResponse response = mstUserService.updatePersonalInfo(userPersonalInfo);
      return new ResponseEntity<>(response, HttpStatus.OK);
    } catch (Exception e) {
      // 更新処理ができなかった場合
      eventLogMessage.setLogMessage("Exception message: " + e.getMessage());
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage()),
          HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * 利用者表示順設定：mst_userのmst_selecter生成
   *
   * @param facilityCd 対象施設
   * @param data mst_userのリスト
   * @return マスタ操作結果 MasterUpdateResponse
   *
   */
  @PutMapping("/mst_user/mstSelecter/UpdIns/{facilityCd}")
  public ResponseEntity<?> updateMstUserSelecter(
    @PathVariable String facilityCd,
    @RequestBody List<Map<String, Object>> data) {

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST request to update mst_user selector ");
    logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI, null);
    try {
      MasterUpdateResponse response = mstUserService.updateMstSelector(facilityCd, data);
      return new ResponseEntity<>(response, HttpStatus.OK);

    } catch (Exception e) {
      // 更新処理ができなかった場合
      eventLogMessage.setLogMessage("Exception message: " + e.getMessage());
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE, SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage()),
          HttpStatus.BAD_REQUEST);
    }
}

  /**
   * アクセスカードを無効
   * @param userId ユーザーID
   * @return マスタデータ更新
   */
  @PutMapping("/mst_user/disableAccessCard/{userId}")
  public ResponseEntity<?> disableAccessCard(@PathVariable(name = "userId", required = true) long userId) {
    try {
      MasterUpdateResponse response = mstUserService.disableAccessCard(userId);
      return new ResponseEntity<>(response, HttpStatus.OK);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(e.getMessage());
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE,SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage()),
          HttpStatus.BAD_REQUEST);
    }
  }

  /**
   * サインイン日時の更新
   *
   * @param userId 利用者ID（内部用ID）
   * @return DB更新結果
   *
   */
  @PutMapping("/mst_user/upd_signin_date/{userId}")
  public ResponseEntity<?> updateSigninDate(@PathVariable String userId) {
    try {
      MasterUpdateResponse response = mstUserService.updateSigninDate(Long.parseLong(userId));
      return new ResponseEntity<>(response, HttpStatus.OK);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("Exception message : " + e.getMessage());
      logService.log(LogLevel.DEBUG, eventLogMessage, FUNCTION_CODE.FUNC_MASTER_MAINTENANCE,SERVICE_NAME.REMS, null);
      return new ResponseEntity<>(new MasterUpdateResponse(AdminWebMessage.Error.DB_UPDATE_ERROR.getMessage()),
          HttpStatus.BAD_REQUEST);
    }
  }
}
