package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.MntCardappPort;
/**
 * カードアプリポート管理のDaoインタフェース
 */
@ConfigAutowireable
@Dao
public interface MntCardappPortDao {

  @Insert(sqlFile = true)
  int insert(MntCardappPort mntCardappPort);

  @Update(sqlFile = true)
  int updateByGuid(MntCardappPort mntCardappPort);

  @Update(sqlFile = true)
  int updateByClientKey(MntCardappPort mntCardappPort);

  /**
   * GUIDクライアント識別子、指定して施設コードのポート取得
   * @param mntCardappPort カードアプリポート
   * @return ポートリスト
   */
  @Select
  List<MntCardappPort> selectByGuidOrClientKey(MntCardappPort mntCardappPort);

  /**
   * 指定して施設コードのポート取得
   * @param facilityCd 処理対象施設の施設コード
   * @return ポートリスト
   */
  @Select
  List<Integer> selectByFacility(String facilityCd);
}
