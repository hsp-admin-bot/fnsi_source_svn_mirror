package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.BatchInsert;
import org.seasar.doma.Dao;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;
import org.seasar.doma.jdbc.SelectOptions;

import jp.co.nikkiso.ntss.core.entity.MstChecklist;
import jp.co.nikkiso.ntss.core.entity.custom.ComsvMstCheckList;

@ConfigAutowireable
@Dao
public interface MstChecklistDao {
  @Select
  List<MstChecklist> selectAll(SelectOptions options);

  @Select
  List<MstChecklist> selectByFacilityCd(SelectOptions options, String facility_cd, String is_del);

  @Select
  MstChecklist selectByChecklistCd(SelectOptions options, Long checklistCd);

  @Insert
  int insert(MstChecklist param);

  @Update
  int update(MstChecklist param);

  @Update(sqlFile = true)
  int updateByChecklistCd(Long checklistCd);

  /**
   * 通信サーバ用チェックリストマスタを取得
   * @param facilityCd 施設コード
   * @return
   */
  @Select
  List<ComsvMstCheckList> selectByFacilityCdComSv(String facilityCd);

  /**
  * 対象施設の初期マスタ情報を登録
  * @param facilityCdList 施設コード
  * @return 更新件数
  */
  @BatchInsert(sqlFile = true)
  int[] insertInitMstForFacility(List<String> facilityCdList);
}
