package jp.co.nikkiso.ntss.core.dao;

import java.sql.Timestamp;
import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.Insert;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.SysCoopNo;


/**
 * 連携オーダ採番テーブルDao
 *
 */
@ConfigAutowireable
@Dao
public interface SysCoopNoDao {
  /**
   * 連携オーダ採番情報を取得する
   * @param facilityCd 施設コード
   * @return
   */
  @Select
  List<SysCoopNo> selectByFacilityCd(String facilityCd);

  /**
   * コピー元の連携オーダ採番情報を取得する
   * @param coopVersion 連携版番号
   * @return
   */
  @Select
  List<SysCoopNo> selectSourceByCoopVersion(String coopVersion);

  /**
   * 連携オーダ採番情報を取得する
   * @param ctlNo 管理番号
   * @return
   */
  @Select
  SysCoopNo selectByCtlNo(Long ctlNo);

  /**
   * 連携オーダ採番情報を更新
   * @param curCoopOrdNo 現在の連携オーダ番号シーケンス
   * @param ctlNo 管理番号
   * @param upDate Timestamp
   * @return
   */
  @Update(sqlFile = true)
  int updateCurCoopOrdNo(Long curCoopOrdNo, Long ctlNo, Timestamp upDate);

  /**
   * 連携オーダ採番情報を更新する
   * @param scn 連携オーダ採番情報Entity
   * @return 0または1
   */
  @Update(sqlFile = true)
  int update(SysCoopNo scn);

  /**
   * 連携オーダ採番情報を登録する
   * @param scn 連携オーダ採番情報Entity
   * @return 0または1
   */
  @Insert(sqlFile = true)
  int insert(SysCoopNo scn);
}
