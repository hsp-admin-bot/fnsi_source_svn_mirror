package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.Insert;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.PatHhdPattern;


@ConfigAutowireable
@Dao
public interface PatHhdPatternDao {
  @Select
  List<PatHhdPattern> selectByFacilityCd(String facility_cd);

  @Select
  List<PatHhdPattern> selectByPatInfo(String facility_cd, Long pat_id, String current_date);

  @Select
  List<PatHhdPattern> selectByPatId(Long pat_id);

  @Select
  List<PatHhdPattern> selectByMachineNo(String facility_cd, Long rst_machine_no);

  /**
   * 管理番号の次番号を取得
   * @param pat_id 患者ID
   * @return 次管理番号
   */
  @Select
  int selectRevisionByPatId(Long pat_id);

  /**
   * 在宅患者治療パターンパターンを保存(追加).
   * @param patExamPattern PatExamPatternのEntity
   * @return 更新件数
   */
  @Insert
  int insertPatHhdPattern(PatHhdPattern patHhdPattern);
}