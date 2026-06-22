package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.custom.JournalDistribute;

/**
 * 外部連携用ジャーナルおよび連携設定情報取得用のDao
 *
 */
@ConfigAutowireable
@Dao
public interface SysCoopJournalWithMstCoopDistributeDao {
  // mod 2022-11-02 bug #8028 応答待ちのジャーナルがあると、送信処理が実施されない 孫 start
//  @Select
//  List<JournalDistribute> getDeliveryJournal(String facilityCd);
//
//  // add 2021-07-08 #5266:レポート再送信時の送信済みファイル取得方法について 孫 start
//  @Select
//  List<JournalDistribute> getRetryDeliveryJournal(String facilityCd);
//  // add 2022-11-02 bug #8028 応答待ちのジャーナルがあると、送信処理が実施されない 孫 end
  // add #10061、SQLパフォーマンス改善、 20231221 xugj start
  @Select
  int getStoppedCoopResult(String facilityCd);
  // add #10061、SQLパフォーマンス改善、 20231221 xugj end

  @Select
  List<JournalDistribute> getDeliveryJournal(String facilityCd, List<String> stopCoopCdList);

  @Select
  List<JournalDistribute> getRetryDeliveryJournal(String facilityCd, List<String> stopCoopCdList);
  // mod 2021-07-08 #5266:レポート再送信時の送信済みファイル取得方法について 孫 end
}
