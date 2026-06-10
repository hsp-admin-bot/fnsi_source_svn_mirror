package jp.co.nikkiso.ntss.core.dao;

import jp.co.nikkiso.ntss.core.entity.PatGroupDetail;
import jp.co.nikkiso.ntss.core.entity.custom.PatGroupCustom;
import java.util.List;
import org.seasar.doma.BatchInsert;
import org.seasar.doma.Dao;
import org.seasar.doma.Delete;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;

/**
 * 患者グループ詳細のDaoインタフェース.
 */
@ConfigAutowireable
@Dao
public interface PatGroupDetailDao {

	/**
	 *
	 * @param patGroupCd
	 * @return データセットエンティティ
	 */
	@Select
	List<PatGroupDetail> selectByPatGroupCd(Long patGroupCd);

	/**
	 *
	 * @param patId
	 * @return データセットエンティティ
	 */
	@Select
	List<PatGroupDetail> selectByPatId(Long patId);

	/**
	 *
	 * @param patGroupDetail
	 * @return
	 */
	@Insert(sqlFile = true)
	int insert(PatGroupDetail patGroupDetail);

	/**
	 *
	 * @param patGroupId
	 * @return
	 */
	@Delete(sqlFile = true)
	int deleteByPatGroupId(Long patGroupId);
  //  add FNSI-5155 じょはく start
  @Delete(sqlFile = true)
  int deleteByPatIds(List<Long> patList);
  //  add FNSI-5155 じょはく end
  // add bug 7940 修正 chen start
  @Delete(sqlFile = true)
  int deleteByPatIdsByGroupList(List<Long> patList, String facilityCd, List<String> groupIdList);
  // add bug 7940 修正 chen end

	/**
	 *
	 * @param patId
	 * @return
	 */
	@Delete(sqlFile = true)
	int deleteByPatId(Long patId);

	/**
	 *
	 * @param patId
	 * @return データセットエンティティ
	 */
	@Select
	List<PatGroupCustom> selectPatGroupByPatId(Long patId);

	/**
	 *
	 * @param patIdList
	 * @param patGroupList
	 * @return データセットエンティティ
	 */
	@Select
	List<Long> selectIncludeSearch(List<Long> patIdList, List<Integer> patGroupList);

	/**
	 *
	 * @param patIdList
	 * @param patGroupList
	 * @return データセットエンティティ
	 */
	@Select
  // mod FNSI-改修内容 FutreNetWeb+SI課題管理No4816 趙 start
  // mod FNSI-改修内容 患者検索外結No5対応 趙 start
  List<Long> selectMatchSearch(List<Long> patIdList, List<Integer> patGroupList);
  // List<Long> selectMatchSearch(List<Long> patIdList, List<Integer> patGroupList,String patGroupStr);
  // mod FNSI-改修内容 患者検索外結No5対応 趙 end
  // mod FNSI-改修内容 FutreNetWeb+SI課題管理No4816 趙 end
	/**
	 *
	 * @param patGroupDetails
	 * @return
	 */
	@BatchInsert(sqlFile = true)
	int[] insertList(List<PatGroupDetail> patGroupDetails);

  /**
   *
   * @param patId
   * @return データセットエンティティ
   */
  @Select
  List<PatGroupDetail> selectPatGroupDetailByPatId(Long patId);

  // add 11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 start
  @Select
  List<Long> selectPatGroupDetailByGroupList(List<Long> patIdList, List<Integer> dSearchPatGroupList, Integer dSearchType,
                                             List<Integer> sSearchPatGroupList, Integer sSearchType);
  // add 11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 end
}
