package jp.co.nikkiso.ntss.core.dao;

import jp.co.nikkiso.ntss.core.entity.PatGroup;
import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.Insert;
import org.seasar.doma.boot.ConfigAutowireable;

/**
 * 患者グループのDaoインタフェース.
 */
@ConfigAutowireable
@Dao
public interface PatGroupDao {

	/**
	 *
	 * @param facilityCd
	 * @return データセットエンティティ
	 */
	@Select
	List<PatGroup> selectAll(String facilityCd);

	/**
	 *
	 * @param patGroupCd
	 * @param facilityCd
	 * @return データセットエンティティ
	 */
	@Select
	PatGroup selectById(Long patGroupCd, String facilityCd);

	/**
	 *
	 * @param patGroup
	 * @return
	 */
	@Insert(sqlFile = true)
	int insert(PatGroup patGroup);

	/**
	 *
	 * @param patGroupCd
	 * @param patGroup
	 * @return
	 */
	@Update(sqlFile = true)
	int updateById(Long patGroupCd, PatGroup patGroup);

	/**
	 *
	 * @param patGroupCd
	 * @param patGroup
	 * @return
	 */
	@Update(sqlFile = true)
	int updatePatGroupById(String facilityCd, PatGroup patGroup);

	/**
	 *
	 * @param patGroupId
	 * @return
	 */
	@Update(sqlFile = true)
	int deleteById(Long patGroupId);

	/**
	 *
	 * @return
	 */
	@Select
	Long selectNextSeqPatGroupId();

	/**
	 * 患者グループコードに該当する患者グループを取得する。
	 * @param patGroupCd
	 * @param facilityCd
	 * @return データセットエンティティ
	 */
	@Select
	PatGroup selectPatGroupById(Long patGroupCd, String facilityCd);
// add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 dou start
	@Select
  List<PatGroup> selectAllGroup();
// add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 dou end

  //No.7167 upd Paging Optimization runtime by ztc start
  @Select
  List<PatGroup> getPatGroupInfoByFacilityCd(String facilityCd);
  //No.7167 upd Paging Optimization runtime by ztc end

  @Select
  int selectIndexPatIdIsContain(String patId, String facilityCd);

}
