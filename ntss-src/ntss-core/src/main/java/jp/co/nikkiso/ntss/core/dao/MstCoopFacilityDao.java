package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.Delete;
import org.seasar.doma.boot.ConfigAutowireable;
import org.seasar.doma.jdbc.SelectOptions;

import jp.co.nikkiso.ntss.core.entity.MstCoopFacility;

/**
 * 連携施設マスタDao
 *
 */
@ConfigAutowireable
@Dao
public interface MstCoopFacilityDao {
  
  /**
   * すべての連携施設を選択します
   * @param options
   * @param facilityCd 施設コード
   * @return リストにはリンク設定マスターエンティティが含まれています
   */
  @Select
  List<MstCoopFacility> selectAllMstCoopFacilityDao(SelectOptions options);
  
  
  /**
   * 管理番号、施設コードで選択
   * @param ctlNo 管理番号
   * @param facilityCd 施設コード
   * @return リストにはリンク設定マスターエンティティが含まれています
   */
  @Select
  List<MstCoopFacility> selectByCtlNoOrFacilityCd(SelectOptions options, Long ctlNo, String facilityCd);
  

	/**
	 * 連携設定マスタの管理番号の取得
	 * @return 管理番号のリンク
	 */
	@Select
	List<String> selectNewestCtlNo();

  /**
   * 管理番号によって連携施設を選択します
   * @param ctlNo 管理番号
   * @return 連携設定マスタEntity
   */
  @Select
  MstCoopFacility selectMstCoopFacilityByCtlNo(Long ctlNo);
  
  /**
   * 管理番号、FacilityCdによる連携施設の削除
   * @param ctlNo
   * @param faclitityCd
   * @return リストにはリンク設定マスターエンティティが含まれています
   */
  @Select
  List<MstCoopFacility> selectMstCoopFacilityByCtlNoOrFacilityCd(Long ctlNo, String facilityCd);

  /**
   * 連携施設の作成
   * @param mstCoopFacility 連携設定マスタEntity
   * @return 0または1
   */
  @Insert(sqlFile = true)
  int insertMstCoopFacility(MstCoopFacility mcf);

  /**
   * 連携施設を更新する
   * @param mstCoopFacility 連携設定マスタEntity
   * @return 0または1
   */
  @Update(sqlFile = true)
  int updateMstMstCoopFacility(MstCoopFacility mcf);
  /**
   * 連携施設を取得
   * @param facilityCd 施設CD
   * @return
   */
  @Select
  MstCoopFacility select(String facilityCd);
  /**
   * 連携施設を登録
   * @param mstCoopFacility 連携施設
   * @return
   */
  @Insert
  int insert(MstCoopFacility mstCoopFacility);
  /**
   * 連携施設を更新
   * @param mstCoopFacility 連携施設
   * @return
   */
  @Update
  int update(MstCoopFacility mstCoopFacility);
  /**
   * 施設コードで連携施設を削除
   * @param facilityCd 施設コード
   * @return
   */
  @Delete(sqlFile = true)
  int deleteByFacilityCd(String facilityCd);
// add 2022-03-10 #7064:GX連携 連携対象患者の判断をini_dialで判断していない 孫 start
  /**
   * 浄化申し込み・初回指示のステータスを取得する
   * @param facilityCd 施設CD
   * @param coopVersion 施設CD
   * @return ステータス
   */
  @Select
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//  String selectIniDialStatus(String facilityCd);
  String selectIniDialStatus(String facilityCd, String coopVersion);
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
// add 2022-03-10 #7064:GX連携 連携対象患者の判断をini_dialで判断していない 孫 end
}
