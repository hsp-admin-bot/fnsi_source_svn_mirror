package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.Delete;
import org.seasar.doma.boot.ConfigAutowireable;
import org.seasar.doma.jdbc.SelectOptions;

import jp.co.nikkiso.ntss.core.entity.MstCoopDistribute;

/**
 * 連携配信設定マスタDao
 *
 */
@ConfigAutowireable
@Dao
public interface MstCoopDistributeDao {

	/**
	 * すべての連携電文配信を選択します
	 * @param options 選択オプション
	 * @param facilityCd 施設CD
	 * @return リストにはリンクされたメッセージ設定マスターエンティティが含まれています
	 */
	@Select
	List<MstCoopDistribute> selectAllMstCoopDistribute(SelectOptions options);

	/**
	 * 管理番号によって連携電文配信を選択します
	 * @param ctlNo 管理番号
	 * @return 連携電文設定マスタEntity
	 */
	@Select
	MstCoopDistribute selectMstCoopDistributeByCtlNo(Long ctlNo);

	/**
	 * 管理番号、施設コード、電文種別による選択
	 * @param pageable
	 * @param ctlNo 管理番号
	 * @param facilityCd 施設コード
	 * @param coopCd
   * @param coopVersion 連携版番号
	 * @return 連携電文設定マスタEntity
	 */
	@Select
// mod 2022-12-30 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//  List<MstCoopDistribute> selectByCtlNoORFacilityCdAndcoopCd(SelectOptions options, Long ctlNo, String facilityCd, String coopCd);
  List<MstCoopDistribute> selectByCtlNoORFacilityCdAndcoopCd(SelectOptions options, Long ctlNo, String facilityCd,
                                                             String coopCd, String coopVersion);
// mod 2022-12-30 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

	/**
	 * 施設コード、電文種別による連携電文配信の削除
	 * @param facilityCd 施設コード
	 * @param coopCd コープコード
	 * @return
	 */
	@Select
	List<MstCoopDistribute> selectByFacilityCdAndCoopCd(String facilityCd, String coopCd);

	/**
	 * 施設コードによる最新の連携電文配信の管理番号の取得
	 * @param facilityCd 施設コード
	 * @return
	 */
	@Select
	List<String> selectNewestCtlNoByFacilityCd(String facilityCd);

	/**
	 * 連携電文配信の作成または更新を確認する
	 * @param mcd
	 * @return 0または1
	 */
	@Insert(sqlFile = true)
	int insertMstCoopDistribute(MstCoopDistribute mcd);

	/**
	 * 連携電文設定マスタを更新
	 * @param mstCoopDistribute 連携電文設定マスタEntity
	 * @return 0または1
	 */
	@Update(sqlFile = true)
	int updateMstCoopDistribute(MstCoopDistribute mcd);

	/**
	 * 連携電文配信を登録
	 * @param mstCoopDistribute 連携電文配信
	 * @return
	 */
	@Insert
	int insert(MstCoopDistribute mstCoopDistribute);

	/**
	 * 施設コードで連携電文配信を削除
	 * @param facilityCd 施設コード
	 * @return
	 */
	@Delete(sqlFile = true)
	int deleteByFacilityCd(String facilityCd);
}
