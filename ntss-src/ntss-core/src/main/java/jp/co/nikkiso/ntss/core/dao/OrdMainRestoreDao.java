package jp.co.nikkiso.ntss.core.dao;

import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.OrdMainRestore;
import org.seasar.doma.Dao;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;

import java.sql.Timestamp;
import java.util.List;

@ConfigAutowireable
@Dao
public interface OrdMainRestoreDao {
  @Insert(sqlFile = true)
  int insert(OrdMainRestore ordMainRestore);

  /* add by wangying 2022-10-27[6118] 予定中止ボタンを押下時間問題の修正 --start */
  //modify  by guanyingshuai 2023.02.10  [#6118-optimize runtime]   start
//  @BatchInsert
//  int[] insertList(List<OrdMainRestore> ordMainRestoreList);
   @Insert(sqlFile = true)
   int insertList(List<OrdMainRestore> ordMainRestoreList);
  /* add by wangying 2022-10-27[6118] 予定中止ボタンを押下時間問題の修正 --end */
  //modify  by guanyingshuai 2023.02.10  [#6118-optimize runtime]   end
  @Select
  int selectCount(Long ordNo, Timestamp delDate);

  //add  初版確定前の治療実績削除で不要なイベントが登録される ljg　start
  @Select
  List<OrdMain> selectRstByOrdrestoreNo(Long ordNo);
  //add 初版確定前の治療実績削除で不要なイベントが登録される ljg　end

  //add #10901 #10902 mst_coop_apilinkの動作について 20241004 zhaoqi start
  @Select
  OrdMainRestore selectByOrdNo(Long ordNo);

  @Select
  List<OrdMainRestore> selectListByOrdNo(List<Long> ordNoList);
  //add #10901 #10902 mst_coop_apilinkの動作について 20241004 zhaoqi end

  // add #11716 曜日パターン変更の不正 関 start
  @Insert(sqlFile = true)
  int insertListByOrdNoList(List<Long> ordNoList, Long userId, Timestamp delDate);
  // add #11716 曜日パターン変更の不正 関 end
}
