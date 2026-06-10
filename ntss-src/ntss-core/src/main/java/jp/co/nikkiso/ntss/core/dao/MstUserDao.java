package jp.co.nikkiso.ntss.core.dao;

import jp.co.nikkiso.ntss.core.entity.MstUser;
import java.util.List;
import org.seasar.doma.Dao;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;

/**
 * 利用者マスタのDaoインタフェース.
 */
@ConfigAutowireable
@Dao
public interface MstUserDao {
  /**
   * 利用者IDに紐づくユーザーを取得.
   * @param userId 利用者ID
   * @return ユーザー情報
   */
  @Select
  MstUser selectById(Long userId);

  /**
   * 患者IDに紐づく在宅透析患者用ユーザーを取得.
   * @param patId 患者ID
   * @return ユーザー情報
   */
  @Select
  MstUser selectByPatId(Long patId, String facilityCd);

  // Add By HandsomeLin At 2023/02/16 Start
  // #6174
  @Select
  List<MstUser> selectByFacilityCd(String facilityCd);

  @Select
  List<MstUser> selectByFacilityCdList(List<String> facilityCdList);

  @Select
  List<MstUser> selectAll();
  // Add By HandsomeLin At 2023/02/16 End

  /**
   * 患者IDに紐づくユーザー数を取得.
   * @param patId 患者ID
   * @return ユーザー情報
   */
  @Select
  int countByPatId(Long patId);

  /**
   * ユーザー設定を更新.
   * @param mstUser ユーザーEntity
   * @return 更新件数
   */
  @Update(include = {"userSettings", "upDate"})
  int updateUserSettings(MstUser mstUser);

  /**
   * 仮登録フラグを更新.
   * @param mstUser ユーザーEntity
   * @return 更新件数
   */
  @Update(include = {"isProvisional", "upDate", "secretKey", "isSetQrCode"})
  int updateIsProvisional(MstUser mstUser);

  /**
   * 削除フラグを更新.
   * @param mstUser ユーザーEntity
   * @return 更新件数
   */
  //mod #6229 全施設マスタのis_disp=0のデータが表示される zhou start
  //@Update(include = {"isDel", "upDate"})
  @Update(include = {"isDel","isDisp", "upDate"})
  //mod #6229 全施設マスタのis_disp=0のデータが表示される zhou end
  int updateIsDel(MstUser mstUser);

  /**
   * 新規ユーザを登録
   * @param mstUserData 新規登録ユーザ情報
   * @return 更新件数
   */
  @Insert
  int insertNewUser(MstUser mstUserData);

  /**
   * アクセスカード番号を設定
   * @param cardIdm アクセスカード番号
   * @param userId ユーザーID
   * @return 更新件数
   */
  //del 7328 IDｍが医療情報DBにて管理されている 関俊楠 start
//  @Update(sqlFile = true)
//  int setCardIdm(String cardIdm, long userId);

  /**
   * カードでユーザーログインを選択
   * @param cardIdm アクセスカード番号
   * @param userId ユーザーID
   * @return ユーザー情報
   */
//  @Select
//  MstUser selectByCardIdm(String cardIdm, String userId);

  /**
   * アクセスカードを削除
   * @param userId ユーザーID
   * @return 更新件数
   */
//  @Update(sqlFile = true)
//  int disableAccessCard(long userId);
//del 7328 IDｍが医療情報DBにて管理されている 関俊楠 end
  /**
   * JSON検索条件を更新する
   * @param userId
   * @param conditions
   * @return 更新件数
   */
  @Update(sqlFile = true)
  int saveSearchCondition(long userId, String conditions);

  /**
   * 秘密鍵を削除する
   * @param mstUserData 新規登録ユーザ情報
   * @return 更新件数
   */
  @Update(sqlFile = true)
  int deleteSecretKey(MstUser mstUser);

  /**
   * ユーザーOTPの更新
   * @param mstUserData 新規登録ユーザ情報
   * @return 更新件数
   */
  @Update(sqlFile = true)
  int updateSecretKey(MstUser mstUser);

  /**
   * 暫定版を更新
   * @param mstUserData 新規登録ユーザ情報
   * @return 更新件数
   */
  @Update(include = {"upDate","isSetQrCode"})
  int updateIsSetQrCode(MstUser mstUser);

  /**
   * 秘密鍵を設定する
   * @param mstUserData 新規登録ユーザ情報
   * @return 更新件数
   */
  @Update(include = {"upDate", "secretKey", "isSetQrCode"})
  int setSecretKey(MstUser mstUser);

  /**
   * リストユーザーが秘密鍵を取得していない
   * @param ユーザーコードのリスト
   * @return リストユーザー
   */
  @Select
  List<MstUser> selectListUserNullSercetKey(List<Long> listUserId);

  /**
   * IDリストでユーザーリストを取得する
   * @param userIdList ユーザーIDリスト
   * @return 利用者リスト
   */
  @Select
  List<MstUser> selectByListId(List<Long> userIdList);

  /**
   * 個人情報取扱い規約同意
   * @param userId ユーザーID
   * @return 更新件数
   */
  @Update(sqlFile = true)
  int updateIsConsent(Long userId);

  /**
   * パスワード変更日時を更新.
   * @param userId ユーザーID
   * @return 更新件数
   */
  @Update(sqlFile = true)
  int updateRegPasswordDate(Long userId);

  /**
   * 全カラム更新処理
   * ※Nullが設定されているカラムは更新対象外
   * @param entity 更新対象のmst_userレコード
   * @return 更新件数
   */
  @Update(excludeNull = true)
  int update(MstUser entity);

}
