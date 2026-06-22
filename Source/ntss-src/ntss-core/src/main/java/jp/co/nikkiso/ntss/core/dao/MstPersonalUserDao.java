package jp.co.nikkiso.ntss.core.dao;

import jp.co.nikkiso.ntss.core.config.ConfigAutowireablePersonalDb;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.entity.PatDoctorInfo;
import org.seasar.doma.Dao;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.jdbc.SelectOptions;

import java.util.List;
import java.util.Map;

/**
 * 利用者マスタ(個人情報DB)のDaoインタフェース.
 */
@Dao
@ConfigAutowireablePersonalDb
public interface MstPersonalUserDao extends MasterDao<Map<String, Object>> {

  /**
   * 利用者IDに紐づくユーザを取得.
   * @param userId 利用者ID
   * @return ユーザ情報
   */
  @Select
  MstPersonalUser selectById(Long userId);

  /**
   * 利用者IDを基にユーザー名("利用者名_姓" + "利用者名_名")を取得.
   * @param userId 利用者ID
   * @return ユーザー名
   */
  @Select
  String selectUserNameById(Long userId);

  /**
   * 指定されたEntityの内容で、利用者マスタ(個人情報DB)を更新する.
   * @param entity 利用者マスタ(個人情報DB)Entity
   * @return 更新件数
   */
  @Update(sqlFile = true)
  int update(MstPersonalUser entity);

  /**
   * 利用者マスタで編集可能な項目を更新
   *
   * @param entity 利用者マスタ(個人情報DB)Entity
   * @return 更新件数
   */
  @Update(sqlFile = true)
  int updateAllowedItems(MstPersonalUser entity);

  /**
   * 指定された施設コードに紐づくユーザを取得.
   * @param selectOptions
   * @param facilityCd 施設コード
   * @return ユーザ情報リスト
   */
  @Select
  List<MstPersonalUser> selectAll(SelectOptions selectOptions, String facilityCd, String isDel);

  /**
   * 指定された施設コードに紐づくユーザを取得.包含删除
   * @param selectOptions
   * @param facilityCd 施設コード
   * @return ユーザ情報リスト
   */
  @Select
  List<MstPersonalUser> selectAllIncludeDel(SelectOptions selectOptions, String facilityCd);

  /**
   * 指定された施設コードに紐づくユーザを取得.
   * @param selectOptions
   * @param facilityCd 施設コード
   * @return ユーザ情報リスト
   */
  @Select
  List<MstPersonalUser> selectAll(String facilityCd, String isDel);

  @Override
  @Select
  List<Map<String, Object>> selectAllStatus(Map<String, String> params);

  // add #10659 削除済み含むの接頭文字対応 ztc 20241021 ztc start
  @Select
  List<MstPersonalUser> selectAllIncludeDel(String facilityCd);
  // add #10659 削除済み含むの接頭文字対応 ztc 20241021 ztc end

  // Add By HandsomeLin At 2023/02/16 Start
  // #6174
  @Select
  List<MstPersonalUser> selectUserIdByFacilityCodeList(List<String> facilityCdList);

  @Select
  List<MstPersonalUser> selectAllUserIdAndFacilityCd();
  // Add By HandsomeLin At 2023/02/16 End

  /**
   * 指定されたユーザーIDリストに一致するユーザーの一覧を取得
   * @param userIdList 取得するユーザーIDリスト
   * @return ユーザー情報リスト
   */
  @Select
  List<MstPersonalUser> selectByIdList(List<Long> userIdList);

  /**
   * 指定されたメールアドレスを、メールアドレス1または2に含むユーザーの一覧を取得
   * @param userEmailAddress メールアドレス
   * @return ユーザー情報リスト
   */
  @Select
  List<MstPersonalUser> selectByUserEmailAddressList(String userEmailAddress);

  /**
   * 指定されたメールアドレス(複合化していないもの)を、メールアドレス1または2に含むユーザーの一覧を取得
   * @param addressList メールアドレス(複合化していないもの)のリスト
   * @return ユーザー情報リスト
   */
  @Select
  List<MstPersonalUser> selectByNoDecryptEmailAddressList(List<String> addressList);

  // add FNSI-メニューに共有ON／共有OFFを追加する 江 start
  /**
   * 患者共有フラグ取得
   * @param userId 更新対象の利用者ID
   * @return 患者共有フラグ
   */
  @Select
  List<MstPersonalUser> selectPatientSharedFlgById(long userId);
  // add FNSI-メニューに共有ON／共有OFFを追加する 江 end

  /**
   * サインイン失敗回数を更新.
   * @param mstPersonalUser 認証用ユーザーEntity
   * @return 更新件数
   */
  @Update(include = {"administrator", "upDate"})
  int updateAdministrator(MstPersonalUser mstPersonalUser);

  /**
   * サインイン失敗回数を更新.
   *
   * @param mstPersonalUser 認証用ユーザーEntity
   * @return 更新件数
   */
  @Update(include = {"patientShared", "upDate"})
  int updatePatientshared(MstPersonalUser mstPersonalUser);

  /**
   * 仮登録フラグを更新.
   * @param mstPersonalUser ユーザーEntity
   * @return 更新件数
   */
  //mod #6229 全施設マスタのis_disp=0のデータが表示される zhou start
  //  @Update(include = {"isDel", "upDate"})
  @Update(include = {"isDel", "isDisp","upDate"})
  //mod #6229 全施設マスタのis_disp=0のデータが表示される zhou end
  int updateIsDel(MstPersonalUser mstPersonalUser);

  /**
   * 新規ユーザを登録
   * @param newPersonalUser 新規登録ユーザ情報
   * @return 更新件数
   */
  @Insert
  int insertNewUser(MstPersonalUser newPersonalUser);

  /**
   * ユーザ名を更新.
   * @param mstPersonalUser ユーザーEntity
   * @return 更新件数
   */
  @Update(sqlFile = true)
  int updateUserName(MstPersonalUser mstPersonalUser);

  /**
   * メールアドレス1、2を更新.
   * @param mstPersonalUser ユーザーEntity
   * @return 更新件数
   */
  @Update(sqlFile = true)
  int updateUserEmailAddress(MstPersonalUser mstPersonalUser);

  /**
   * 職種を更新.
   * @param mstPersonalUser ユーザーEntity
   * @return 更新件数
   */
  @Update(sqlFile = true)
  int updateUserJob(MstPersonalUser mstPersonalUser);

  /**
   * 指定された職種コードに紐づくユーザを取得.
   * @param selectOptions
   * @param jobCd 施設コード
   * @return ユーザ情報リスト
   */
  @Select
  List<MstPersonalUser> selectByJobCd(String jobCd,String facilityCd);

  /**
   * 指定された施設コードに関連付けられたユーザーIDを取得します.
   * @param isDel 削除フラグ
   * @param facilityCd 施設コード
   * @return ユーザーIDリスト
   */
  @Select
  List<Long> selectListUserIdByFacilityCd(String facilityCd, String isDel);

  /**
   * サインイン日時を更新.
   * @param mstPersonalUser ユーザーEntity
   * @return
   */
  @Update(include = {"signinDate", "upDate"})
  int updateSigninDate(MstPersonalUser mstPersonalUser);

  /**
   * 院内コード1に紐づくユーザを取得.
   * ※施設コードと院内コード1で一意となる
   * @param facilityCd 施設コード
   * @param inHospitalCd1 院内コード1
   * @return ユーザ情報
   */
  @Select
  MstPersonalUser selectByInHospitalCd1(String facilityCd, String inHospitalCd1);

  // add 6996 profile連携で受信した禁忌情報登録 20230110 zhaoqi start
  @Select
  MstPersonalUser selectByInHospitalCds(String facilityCd, String inHospitalCd2, String hospitalCd);
  // add 6996 profile連携で受信した禁忌情報登録 20230110 zhaoqi end

  /**
   * 全カラム更新処理
   * ※Nullが設定されているカラムは更新対象外
   *   当処理では暗号化されないので、必ずupdateEncryptで暗号化すること
   * @param entity mst_personal_userレコード
   * @return 更新件数
   */
  @Update(excludeNull = true)
  int updateInit(MstPersonalUser entity);

  /**
   * 渡されたエンティティで暗号化
   * @param entity 利用者マスタ(個人情報DB)Entity
   * @return 更新件数
   */
  @Update(sqlFile = true)
  int updateEncrypt(MstPersonalUser entity);

  /*add FNSI-改修内容患者イベント患者情報共有より改修 任 start*/
  @Select
  Integer selectPublicFlag(long userId);
  /*add FNSI-改修内容患者イベント患者情報共有より改修 任 end*/
  /*add FNSI-改修内容全体の合否が俯瞰できるように修正 任 start*/
  @Select
  List<MstPersonalUser> selectAllUser(String facilityCd, String isDel);
  /*add FNSI-改修内容全体の合否が俯瞰できるように修正 任 end*/
// add 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zhou start
  @Select
  List<String> selectByName (String keyWord, List<String> facilityCds , boolean searchFlag);
// add 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zhou end
  // add #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen start
  @Select
  List<MstPersonalUser> selectAllName(List<Integer> patIds);
  // add #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen end

  //add #12462 facility code集合による患者名の取得 by zrx start
  @Select
  List<PatDoctorInfo> getPatDoctorByFacilityCdList(List<String> facilityCdList);
  //add #12462 facility code集合による患者名の取得 by zrx end
}
