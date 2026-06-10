package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.Insert;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.MstCoopFilename;

/**
 * 連携ファイル名マスタDao
 *
 */
@ConfigAutowireable
@Dao
public interface MstCoopFilenameDao {

  /**
   * mst_coop_filenameテーブルのレコードを取得する。
   *
   * @param facilityCd 施設コード
   * @param coopCd 電文種別
   * @param coopCdIndex 付帯情報（電文）
   * @param coopVersion 連携版番号
   * @return mst_coop_filenameテーブルのレコード（MstCoopFilenameエンティティ）
   */
  @Select
// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//  MstCoopFilename select(String facilityCd, String coopCd, String coopCdIndex);
  MstCoopFilename select(String facilityCd, String coopCd, String coopCdIndex, String coopVersion);
// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

  /**
   * 最新の連携ファイル名マスタの管理番号を施設CDで取得する
   * @param facilityCd 施設CD
   * @return
   */
  @Select
  List<String> selectNewestCtlNoByFacilityCd(String facilityCd);

  /**
   * 管理番号によって連携ファイル名マスタを選択します
   * @param ctl_no 管理番号
   * @return 連携ファイル名マスタ
   */
  @Select
  MstCoopFilename selectMstCoopFilenameByCtlNo(Long ctlNo);

  /**
   * 連携ファイル名マスタを挿入します
   * @param 連携ファイル名マスタを表すエンティティクラス。
   * @return 0または1
   */
  @Insert(sqlFile = true)
  int insertMstCoopFilename(MstCoopFilename mcfn);

  /**
   * 連携ファイル名マスタを更新
   * @param 連携ファイル名マスタを表すエンティティクラス。
   * @return 0または1
   */
  @Update(sqlFile = true)
  int updateMstCoopFilename(MstCoopFilename mcfn);
}
