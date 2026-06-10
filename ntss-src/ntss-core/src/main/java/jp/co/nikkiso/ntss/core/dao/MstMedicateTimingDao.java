package jp.co.nikkiso.ntss.core.dao;

import java.util.List;
import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;
import org.seasar.doma.jdbc.SelectOptions;

import jp.co.nikkiso.ntss.core.entity.MstMedicateTiming;

@ConfigAutowireable
@Dao
public interface MstMedicateTimingDao {
  @Select
  List<MstMedicateTiming> selectAll(SelectOptions options, MstMedicateTiming params);

  @Select
  MstMedicateTiming selectByCd(String facilityCd, Integer medicateTimingCd);

  @Select
  MstMedicateTiming selectByMedicateTimingCd(Integer medicateTimingCd);

  // FNSI-修正 マスタ削除の対応 chen add start
  @Select
  List<MstMedicateTiming> selectIncludeDeleted(SelectOptions options, MstMedicateTiming params);
  // FNSI-修正 マスタ削除の対応 chen add end

  // add 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関 start
  @Select
  List<MstMedicateTiming> selectAllIncludeDeleted(SelectOptions options, MstMedicateTiming params);
  // add 9339 特殊浄化に治療方法変更してもNa注入プログラムが入りのままとなる。 関 end

  /* add by chamaojia 2026-03-24 [12462] 患者情報共有->患者経過総合ビューア --start */
  @Select
  List<MstMedicateTiming> selectByOrdNoList(List<Long> ordNoList);
  /* add by chamaojia 2026-03-24 [12462] 患者情報共有->患者経過総合ビューア --end */

}
