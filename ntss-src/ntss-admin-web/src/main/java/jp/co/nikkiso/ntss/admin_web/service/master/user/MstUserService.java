package jp.co.nikkiso.ntss.admin_web.service.master.user;

import java.util.List;
import java.util.Map;

import jp.co.nikkiso.ntss.admin_web.response.masterMaintenance.MasterDataResponse;
import jp.co.nikkiso.ntss.admin_web.response.masterMaintenance.MasterUpdateResponse;
// add FNSI-メニューに共有ON／共有OFFを追加する 江 start
// add FNSI-メニューに共有ON／共有OFFを追加する 江 end
import jp.co.nikkiso.ntss.core.entity.MstFacility;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.entity.MstUser;
import jp.co.nikkiso.ntss.core.entity.MstUserAuthentication;
import jp.co.nikkiso.ntss.core.entity.MstUserOTP;
import jp.co.nikkiso.ntss.core.entity.custom.MstUserData;


public interface MstUserService {

  /**
   * 利用者データの取得.
   *
   * @param facilityCd 施設コード.
   * @param isOwnFacility 自施設の情報取得か.
   * @return 利用者データ情報.
   */
  MasterDataResponse getMasterData(String facilityCd, boolean isOwnFacility);

  /**
   * 利用者データの取得（ソート順用)
   *
   * @param facilityCd 施設コード.
   * @param isOwnFacility 自施設の情報取得か.
   * @return 利用者データ情報.
   */
  MasterDataResponse getSortMasterData(String facilityCd, boolean isOwnFacility);


  /**
   * 施設データの取得.
   *
   * @return 施設データ情報.
   */
  List<MstFacility> selectMstFacility();
  // add FNSI-メニューに共有ON／共有OFFを追加する 江 start
  /**
   * 患者共有フラグ取得.
   *
   * @return 患者共有フラグ.
   */
  List<MstPersonalUser> selectPatientSharedFlgById(long userId);
  // add FNSI-メニューに共有ON／共有OFFを追加する 江 end

  /**
   * ユーザの管理者権限を更新.
   *
   * @param mstUser 新規登録ユーザ情報.
   * @return DB更新結果.
   */
  MasterUpdateResponse registNewUser(MstUserData mstUser);

  /**
   * 在宅患者ユーザの新規登録.
   *
   * @param mstUser 新規登録ユーザ情報.
   * @return DB更新結果.
   */
  MasterUpdateResponse registNewPatUser(MstUserData mstUser);

  /**
   * ユーザの管理者権限を更新.
   *
   * @param userId 利用者ID.
   * @param adminFlg 管理者権限(0:一般ユーザ、1:管理者ユーザ).
   * @return DB更新結果.
   */
  MasterUpdateResponse updAdministrator(long userId, int adminFlg);

  /**
   * 患者共有フラグ更新.
   *
   * @param userId 利用者ID.
   * @param patientSharedFlg 管理者権限(0:非表示、1:表示).
   * @return DB更新結果.
   */
  MasterUpdateResponse updPatientShared(long userId, int patientSharedFlg);

  /**
   * ユーザのパスワードを更新.
   *
   * @param userId 利用者ID.
   * @param dispUserId 表示用利用者ID(更新はしないが処理呼び出しで使用する).
   * @param password パスワード.
   * @return DB更新結果.
   */
  MasterUpdateResponse resetPassword(long userId, String dispUserId, String password);

  /**
   * ユーザのログイン失敗回数をクリア.
   *
   * @param userId 利用者ID.
   * @return DB更新結果.
   */
  MasterUpdateResponse resetFailureCnt(long userId);

  /**
   * ユーザの削除.
   *
   * @param userId 利用者ID.
   * @return DB更新結果.
   */
  MasterUpdateResponse deleteUser(long userId);

  /**
   * ログイン用URLの共通部を取得.
   *
   * @param key 取得データのkey
   * @return ログイン用URL共通部文字列.
   */
  String getUrlCom(String key);

  /**
   * 対象施設コードのログインハッシュ値を取得.
   *
   * @param facilityCd 施設コード.
   * @return ログイン用ハッシュ値文字列.
   */
  String getUrlHash(String facilityCd);

  /**
   * 対象施設コードのログインハッシュ値を取得(利用者が患者の場合の処理).
   *
   * @param facilityCd 施設コード.
   * @return ログイン用ハッシュ値文字列.
   */
  String getUrlPatHash(String facilityCd);

  /**
   * 対象施設コードの施設名称を取得.
   *
   * @param facilityCd 施設コード.
   * @return 施設名称.
   */
  String getFacilityName(String facilityCd);

  /**
   * 削除対象メールアドレスリストの取得.
   *
   * @param userEmailAddress 削除するメールアドレス.
   * @return 削除対象メールアドレスリストのResponse.
   */
  List<MstUserData> getDeleteTarget(String userEmailAddress);

  /**
   * 削除対象メールアドレスの削除(nullでアップデート).
   *
   * @param emailAddressList 削除するメールアドレスのリスト.
   * @return DB更新結果.
   */
  MasterUpdateResponse deleteEmailAddress(List<MstUserData> emailAddressList);

  /**
   * ユーザの職種を変更
   *
   * @param userId 利用者ID.
   * @param jobCd 職種コード.
   * @return DB更新結果.
   */
  MasterUpdateResponse updateJobCd(long userId, String jobCd);

  /**
   * 在宅患者データの取得.
   *
   * @param patId 患者ID.
   * @return 利用者データ情報.
   */
  int getUserByPatId(Long patId);

  /**
   * ユーザの職種を変更
   *
   * @param userData 更新するユーザー情報.
   * @return DB更新結果.
   */
  MasterUpdateResponse updatePersonalInfo(MstUserData userData);

  /**
   * 利用者並び順情報の登録更新
   *
   * @param facilityCd 施設コード
   * @param userInfo 利用者情報
   * @return DB更新結果
   */
  MasterUpdateResponse updateMstSelector(String facilityCd, List<Map<String, Object>> userInfo);

  /**
   * アクセスカードを無効にする
   * @param userId ユーザーID
   * @return DB更新結果
   */
  MasterUpdateResponse disableAccessCard(long userId);

  /**
  * 秘密鍵を削除する
  *
  * @param userId 利用者ID（内部用ID）
  * @return DB更新結果
  *
  */
  MasterUpdateResponse deleteSecretKey(long userId);

  /**
  * ユーザーOTPを作成
  *
  * @param dispUserId 表示用利用者ID
  * @param facilityCd 施設コード
  * @return 秘密鍵、QRコード(Base64形式)
  *
  */
  MstUserOTP createSecretKey(String dispUserId, String facilityCd) throws Exception;

  /**
  * ユーザーOTPの更新
  *
  * @param userId 利用者ID（内部用ID）
  * @param secretKey 秘密鍵
  * @return DB更新結果
  *
  */
  MasterUpdateResponse updateSecretKey(long userId, String secretKey);

  /**
  * 秘密鍵設定フラグを更新
  *
  * @param userId 利用者ID（内部用ID）
  * @param isSetQrCode 秘密鍵設定フラグ
  * @return 更新件数
  *
  */
  int updateIsSetQrCode(long userId, int IsSetQrCode);

  /**
  * Otpをチェック
  *
  * @param userId 利用者ID（内部用ID）
  * @param otp ワンタイムパスワード
  * @return 認証成功=true, 認証失敗=false
  *
  */
  boolean checkOtpPassword(long userId,String otp);

  /**
  * Otpをチェック(登録時、要秘密鍵)
  *
  * @param secretKey 秘密鍵
  * @param otp ワンタイムパスワード
  * @return 認証成功=true, 認証失敗=false
  *
  */
  boolean checkOtpOnRegister(String secretKey, String otp);

  /**
  * サインイン日時の更新
  *
  * @param userId 利用者ID（内部用ID）
  * @return DB更新結果
  *
  */
  MasterUpdateResponse updateSigninDate(long userId);


  /**
   *利用者マスタデータ取得
   *
   * @param facilityCd 施設コード
   * @param equals 自施設の場合 = true
   * @return 利用者データ情報.
   *
   */
  List<Map<String, Object>> selectUserDataByFacilityCd(String facilityCd, boolean equals);
  // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
  MstUser getByUserId(long userId);

  MstUserAuthentication selectMstUserAuthenticationByUserId(Long userId);
  // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end
}
