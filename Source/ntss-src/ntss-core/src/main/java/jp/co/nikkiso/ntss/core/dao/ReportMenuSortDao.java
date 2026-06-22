package jp.co.nikkiso.ntss.core.dao;
import java.util.List;
import jp.co.nikkiso.ntss.core.entity.EntityDao;
import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import jp.co.nikkiso.ntss.core.config.ConfigAutowireablePersonalDb;


@ConfigAutowireablePersonalDb
@Dao
public interface ReportMenuSortDao {

	/**
	 * 患者IDでソート順の習得
	 * 
	 * @param patId
	 * @param sortValue
	 * @param facilityCd
	 * @return
	 */
  /*mod FNSI-改修内容表示順が全部効かなくて、最後の表示順だけ効いてしまう。 任 start*/
  /*@Select
  List<Long> selectByPatId(List<Long> patId, String sortValue, String facilityCd);*/
	@Select
	List<EntityDao> selectByPatId(List<Long> patId, String sortValue, String facilityCd);
  /*mod FNSI-改修内容表示順が全部効かなくて、最後の表示順だけ効いてしまう。 任 end*/

	/**
	 * 氏名でソート
	 * 
	 * @param patId
	 * @param sortValue
	 * @param facilityCd
	 * @return
	 */
  /*mod FNSI-改修内容表示順が全部効かなくて、最後の表示順だけ効いてしまう。 任 start*/
  /*@Select
  List<Long> selectSortByFullname(List<Long> patId, String sortValue, String facilityCd);*/
	@Select
	List<EntityDao> selectSortByFullname(List<Long> patId, String sortValue, String facilityCd);
  /*mod FNSI-改修内容表示順が全部効かなくて、最後の表示順だけ効いてしまう。 任 end*/

	/**
	 * カナでソート
	 * 
	 * @param patId
	 * @param sortValue
	 * @param facilityCd
	 * @return
	 */
  /*mod FNSI-改修内容表示順が全部効かなくて、最後の表示順だけ効いてしまう。 任 start*/
  /*@Select
  List<Long> selectSortByKanaFullname(List<Long> patId, String sortValue, String facilityCd);*/
	@Select
	List<EntityDao> selectSortByKanaFullname(List<Long> patId, String sortValue, String facilityCd);
  /*mod FNSI-改修内容表示順が全部効かなくて、最後の表示順だけ効いてしまう。 任 end*/

	/**
	 * 性別でソート
	 * 
	 * @param patId
	 * @param sortValue
	 * @param facilityCd
	 * @return
	 */
  /*mod FNSI-改修内容表示順が全部効かなくて、最後の表示順だけ効いてしまう。 任 start*/
  /*@Select
  List<Long> selectSortBySex(List<Long> patId, String sortValue, String facilityCd);*/
	@Select
	List<EntityDao> selectSortBySex(List<Long> patId, String sortValue, String facilityCd);
  /*mod FNSI-改修内容表示順が全部効かなくて、最後の表示順だけ効いてしまう。 任 end*/

	/**
	 * 血液型でソート
	 * 
	 * @param patId
	 * @param sortValue
	 * @param facilityCd
	 * @return
	 */
  /*mod FNSI-改修内容表示順が全部効かなくて、最後の表示順だけ効いてしまう。 任 start*/
  /*@Select
  List<Long> selectSortByPatBloodType(List<Long> patId, String sortValue, String facilityCd);*/
	@Select
	List<EntityDao> selectSortByPatBloodType(List<Long> patId, String sortValue, String facilityCd);
  /*mod FNSI-改修内容表示順が全部効かなくて、最後の表示順だけ効いてしまう。 任 end*/
}
