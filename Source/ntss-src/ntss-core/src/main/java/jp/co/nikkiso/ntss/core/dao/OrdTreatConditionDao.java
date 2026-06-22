package jp.co.nikkiso.ntss.core.dao;

import org.seasar.doma.Dao;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;

import java.sql.Timestamp;

@ConfigAutowireable
@Dao
public interface OrdTreatConditionDao {

  /**
   * ？？？？患者治療のデータを割り当て患者のデータになるように書き換える
   * @param baseOrdNo 割り当て対象のオーダ番号
   * @param ordNo ？？？？患者のオーダ番号
   * @param upDate 更新日付
   *
   * @return
   */
  @Update(sqlFile = true)
  int updateOrdNo(Long baseOrdNo, Long ordNo, Timestamp upDate);

  //add FNSI-修正、#6305 fang start
  @Update(sqlFile = true)
  int deleteByOrdNo(Long ordNo, Timestamp upDate);
  //add FNSI-修正、#6305 fang end
}
