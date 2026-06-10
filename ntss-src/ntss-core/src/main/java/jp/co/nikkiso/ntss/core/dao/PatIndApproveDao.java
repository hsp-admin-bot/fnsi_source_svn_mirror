package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.BatchUpdate;
import org.seasar.doma.Dao;
import org.seasar.doma.Delete;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.PatIndApprove;

@ConfigAutowireable
@Dao
public interface PatIndApproveDao {
  @Insert(sqlFile = true)
  int insert(Long ord_no, String facility_cd);

  /* add by chamaojia 2023-03-20 [8101] 新規一括メソッド  --start */
  @Insert(sqlFile = true)
  int insertList(List<Long> ordNoList, String facilityCd);
  /* add by chamaojia 2023-03-20 [8101] 新規一括メソッド  --end */

  @Delete(sqlFile = true)
  int deleteByOrdNo(Long ord_no);

  @Delete(sqlFile = true)
  int deleteByOrdNoList(List<Long> ord_no);

  @Update(sqlFile = true)
  int updateContentChange(PatIndApprove param);

  @Update(sqlFile = true)
  int updateContentChangeSingle(Long ord_no, PatIndApprove param);

  /* modify by chamaojia 2023-04-10 [6118] 新規一括変更方法 --start */
  @Update(sqlFile = true)
  int updateContentChangeSingleByOrdNoList(List<Long> ordNos);
  /* modify by chamaojia 2023-04-10 [6118] 新規一括変更方法 --end */

  // add #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240529 start
  @Update(sqlFile = true)
  int updateAppContentChangeSingleByOrdNoList(List<Long> ordNos);
  // add #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240529 end

  @Update(sqlFile = true)
  int updateContentChangeSingleByBedControl(Long ord_no, PatIndApprove param);

  @Update(sqlFile = true)
  int updateContentChangeList(List<Long> ord_no, PatIndApprove param);

  @Update(sqlFile = true)
  int updateContentChangeListByBedControl(List<Long> ord_no, PatIndApprove param);

  @Update(sqlFile = true)
  int updateChecker(Long ord_no, Long check_user1_cd, Long check_user2_cd, String check_content);

  @Update(sqlFile = true)
  int updateApprover(Long ord_no, Long approve_user1_cd, Long approve_user2_cd,String approve_content);

  @Update(sqlFile = true)
  int updateCheck1(Long ord_no, Long check_user1_cd, String check_content);

  @Update(sqlFile = true)
  int updateCheck2(Long ord_no, Long check_user2_cd, String check_content);

  @Update(sqlFile = true)
  int updateApprove1(Long ord_no, Long approve_user1_cd, String approve_content);

  @BatchUpdate(sqlFile = true)
  int[] updateCheck1List(List<PatIndApprove> patIndApproves);

  @BatchUpdate(sqlFile = true)
  int[] updateCheck2List(List<PatIndApprove> patIndApproves);

  @BatchUpdate(sqlFile = true)
  int[] updateApprove1List(List<PatIndApprove> patIndApproves);

  @BatchUpdate(sqlFile = true)
  int[] updateApprove2List(List<PatIndApprove> patIndApproves);

  @Update(sqlFile = true)
  int updateApprove2(Long ord_no, Long approve_user2_cd, String approve_content);

  @Update(sqlFile = true)
  int updateUncheck1(Long ord_no);

  @Update(sqlFile = true)
  int updateUncheck2(Long ord_no);

  @Update(sqlFile = true)
  int updateUnapprove1(Long ord_no);

  @Update(sqlFile = true)
  int updateUnapprove2(Long ord_no);

  @Update(sqlFile = true)
  int updateForMap(PatIndApprove param);

  @Select
  List<OrdMain> selectOrdMainByOrdNo(Long ord_no);

  @Select
  List<PatIndApprove> selectPatIndApproveByOrdNo(Long ord_no);

  /* modify by chamaojia 2023-04-10 [6118] 新規一括クエリー方法 --start */
  @Select
  List<PatIndApprove> selectBySettingNoAndOrdNoList(List<Long> ordNos, String settingNo, String settingValue);
  /* modify by chamaojia 2023-04-10 [6118] 新規一括クエリー方法 --end */

  // add#10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240529 start
  @Update(sqlFile = true)
  int updateContent(PatIndApprove param);
  // add#10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240529 end

  // add #10739 コンバート施設で指示受け(治療単位)が表示されない 関 start
  @Select
  List<PatIndApprove> updateContentAndMapBatch(List<PatIndApprove> updatedPatIndApproves);

  @Select
  List<PatIndApprove> selectPatIndApproveByOrdNos(List<Long> ordNos);
  // add #10739 コンバート施設で指示受け(治療単位)が表示されない 関 end

  //add #10901 zrx start
  @Select
  List<PatIndApprove> selectPatIndApproveByOrdNoList(String facilityCd, List<Long> ordNoList);
  //add #10901 zrx end
}
