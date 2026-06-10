package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.Insert;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.MstIfEdge;

/**
 * 連携エッジマスタDao
 */
@ConfigAutowireable
@Dao
public interface MstIfEdgeDao {

  /**
   * 連携エッジマスタ情報を取得する
   * @param facilityCd 施設コード
   * @return
   */
  @Select
  List<MstIfEdge> selectByFacilityCd(String facilityCd);

  // add 2021-06-04 #5271:エッジのシリアルチェックがされていない 孫 start
  /**
   * 連携エッジマスタ情報を取得する
   * @param facilityCd 施設コード
   * @param serialNo シリアル番号
   * @return
   */
  @Select
  MstIfEdge selectByFacilityCdSerialNo(String facilityCd, String serialNo);
  // add 2021-06-04 #5271:エッジのシリアルチェックがされていない 孫 end

  /**
   * 連携エッジマスタ情報を取得する
   * @param serialNo 製造番号
   * @return
   */
  @Select
  MstIfEdge selectBySerialNo(String serialNo);

  /**
   * 連携エッジマスタ情報を更新する
   * @param mie 連携エッジマスタ情報Entity
   * @return 0または1
   */
  @Update(sqlFile = true)
  int update(MstIfEdge mie);

  /**
   * 連携エッジマスタ情報を登録する
   * @param mie 連携エッジマスタ情報Entity
   * @return 0または1
   */
  @Insert(sqlFile = true)
  int insert(MstIfEdge mie);
}
