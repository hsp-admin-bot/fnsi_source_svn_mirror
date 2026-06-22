package jp.co.nikkiso.ntss.core.dao;

import jp.co.nikkiso.ntss.core.config.ConfigAutowireableAuthDb;
import jp.co.nikkiso.ntss.core.entity.SysSigninManager;
import org.seasar.doma.Dao;
import org.seasar.doma.Delete;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;

import java.util.List;

/**
 * サインイン管理のDaoインタフェース.
 */
@Dao
@ConfigAutowireableAuthDb
public interface SysSigninManagerDao {

  /**
   * サインイン管理に登録されている情報を全て取得する.
   *
   * @return サインイン管理情報のリスト
   */
  @Select
  List<SysSigninManager> selectAll();

  /**
   * サインイン管理への登録する.
   *
   * @param sysSigninManager サインイン管理情報
   */
  @Insert
  int insert(SysSigninManager sysSigninManager);

  /**
   * 条件に該当するサインイン管理を取得する.
   * ※設定された端末固有文字列、利用者ID、施設コードに該当する情報を取得する.
   *   条件に含めたくないパラメータの設定は不要
   *   例えば、施設コードに該当するデータを取得した場合には、施設コードのみを設定する.
   * 注意：
   *   空文字を設定した場合でも条件として含められる.
   *
   * @param sysSigninManager サインイン情報エンティティ
   * @return サインイン情報
   */
  @Select
  List<SysSigninManager> selectByParam(SysSigninManager sysSigninManager);

  /**
   * 条件に該当するサインイン管理を削除する.
   *
   * @param sysSigninManager サインイン情報エンティティ
   * @return
   */
  @Delete(sqlFile = true)
  int deleteByParam(SysSigninManager sysSigninManager);

  /**
   * 条件に該当するサインイン管理を削除する(指定端末以外の同一利用者の情報を削除).
   *
   * @param userId 利用者ID
   * @param terminalUniqueString 端末固有文字列
   * @return
   */
  @Delete(sqlFile = true)
  int deleteByUserId(Long userId, String terminalUniqueString);

  /**
   * 対象施設コードのサインイン管理を削除する.
   *
   * @param facilityCd 施設コード
   * @return
   */
  @Delete(sqlFile = true)
  int deleteByFacilityCd(String facilityCd);

  //add 11587 by kangjie 20250226 start
  @Select
  List<SysSigninManager> selectByUserId(String userId);
  //add 11587 by kangjie 20250226 end


  // #12849 複数端末同時サインイン無効の乗っ取りサインインが動かない add 20260619 yangxuewang start
  /**
   * 指定利用者・サーバIPのサインイン管理を削除する.
   *
   * @param userId 利用者ID
   * @param serverIp サーバIP
   * @return 削除件数
   */
  @Delete(sqlFile = true)
  int deleteByUserIdAndServerIp(Long userId, String serverIp, String facilityCd);
  // #12849 複数端末同時サインイン無効の乗っ取りサインインが動かない add 20260619 yangxuewang end
}
