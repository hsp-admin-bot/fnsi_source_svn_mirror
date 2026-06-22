package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Delete;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.Insert;

import jp.co.nikkiso.ntss.core.config.ConfigAutowireableAuthDb;
import jp.co.nikkiso.ntss.core.entity.MstUserAuthentication;

/**
 * 利用者マスタ(認証DB)のDaoインタフェース.
 */
@Dao
@ConfigAutowireableAuthDb
public interface MstUserAuthenticationDao {
  //add 7328 IDｍが医療情報DBにて管理されている 関俊楠 start
  /**
   * アクセスカード番号を設定
   * @param cardIdm アクセスカード番号
   * @param userId ユーザーID
   * @return 更新件数
   */
  @Update(sqlFile = true)
  int setCardIdm(String cardIdm, long userId);
  /**
   * カードでユーザーログインを選択
   * @param cardIdm アクセスカード番号
   * @param userId ユーザーID
   * @return ユーザー情報
   */
  @Select
  MstUserAuthentication selectByCardIdm(String cardIdm, String userId);

  /**
   * アクセスカードを削除
   * @param userId ユーザーID
   * @return 更新件数
   */
  @Update(sqlFile = true)
  int disableAccessCard(long userId);
  //add 7328 IDｍが医療情報DBにて管理されている 関俊楠 end
  /**
   * 利用者IDに紐づくユーザーを取得.
   * @param userId 利用者ID
   * @return ユーザー情報
   */
  @Select
  MstUserAuthentication selectById(Long userId);

  /**
   * 表示利用者IDと施設コードに紐づくユーザーを取得（ログイン処理用）.
   * @param dispUserId 表示利用者ID
   * @param facilityCd 施設コード
   * @return ユーザー情報
   */
  @Select
  MstUserAuthentication selectForLogin(String dispUserId, String facilityCd);

  /**
   * サインイン失敗回数を更新.
   * @param mstUserAuthentication 認証用ユーザーEntity
   * @return 更新件数
   */
  @Update(include = {"failureCnt", "upDate"})
  int updateFailureCnt(MstUserAuthentication mstUserAuthentication);

  /**
   * 表示利用者IDに紐づくユーザーを取得.
   * @param dispUserId 表示利用者ID
   * @return 表示利用者IDに該当する全ユーザー情報
   */
  @Select
  List<MstUserAuthentication> selectDispUserId(String dispUserId, String facilityCd);

  /**
   * 表示用ユーザーIDとパスワードを更新.
   * @param mstUserAuthentication ユーザーEntity
   * @return 更新件数
   */
  @Update(sqlFile = true)
  int updateDispUserIdAndUserPassword(MstUserAuthentication mstUserAuthentication);

  /**
   * 施設コードに紐づくユーザーを取得.
   * @param facilityCd 施設コード
   * @return ユーザー情報
   */
  @Select
  List<MstUserAuthentication> selectByFacility(String facilityCd);

  /**
   * 対象ユーザを削除
   * @param userId 利用者ID
   * @return 更新件数
   */
  @Delete(sqlFile = true)
  int delete(long userId);

  /**
   * 新規ユーザを登録
   * @param newMstUserAuth 新規登録ユーザ情報
   * @return 更新件数
   */
  @Insert(sqlFile = true)
  int insertNewUser(MstUserAuthentication newMstUserAuth);

  /**
   * 表示利用者IDと施設コードに紐づくユーザーを取得（ログイン処理用）.
   * @param facilityCd 施設コード
   * @param dispUserIdDt 検索対象の日付(yymmdd形式)
   * @return 当日分の表示用利用者IDの最大値
   */
  @Select
  String selectMaxDispUserId(String facilityCd, String dispUserIdDt);

  /**
   * 利用者IDに紐付く施設コードのリストを取得.
   * @param userIds ユーザーIDのリスト
   * @return 施設コードのリスト
   */
  @Select
  List<String> selectFacilityCdByUserId(List<Long> userIds);

  /**
   * カード情報を取得する
   * @param cardCd　カードコード
   * @param facilityCd　施設コード
   * @return
   */
  @Select
  MstUserAuthentication selectByCardCd(String cardCd, String facilityCd);

  /**
   * 施設コード（複数）に対応するユーザを削除する。
   *
   * @param facilityCd 施設コード
   * @return 削除件数
   */
  @Delete(sqlFile = true)
  int deleteByFacilityCd(String facilityCd);

  /**
   * 表示利用者IDと施設コードに紐づくユーザーＩＤを取得（ログイン処理・2要素認証秘密鍵追加処理用）.
   * @param dispUserId 表示利用者ID
   * @param facilityCd 施設コード
   * @return ユーザー情報
   */
  @Select
  String selectUserId(String dispUserId, String facilityCd);
  /**
   * 全カラム更新処理
   * ※Nullが設定されているカラムは更新対象外
   * @param entity 更新対象のmst_user_authenticationレコード
   * @return 更新件数
   */
  @Update(excludeNull = true)
  int update(MstUserAuthentication entity);
//  add 8074 【デグレ】ログに誤った利用者が記録される 関 start
  /**
   * 表示利用者IDと施設コードに紐づくユーザーＩＤを取得
   * @param facilityCd 施設コード
   * @return ユーザー情報
   */
  @Select
  String selectUserIdByFacilityCd(String dispUserId, String facilityCd);
//  add 8074 【デグレ】ログに誤った利用者が記録される 関  end
}
