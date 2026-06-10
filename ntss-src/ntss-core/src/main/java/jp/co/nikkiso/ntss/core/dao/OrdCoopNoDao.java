package jp.co.nikkiso.ntss.core.dao;

import java.sql.Timestamp;
import java.util.List;
import java.util.Set;


import org.seasar.doma.Dao;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.OrdCoopNo;


/**
 * 連携オーダ番号テーブルDao
 *
 */
@ConfigAutowireable
@Dao
public interface OrdCoopNoDao {
  /**
   * 連携オーダ番号テーブル情報を取得する
   * @param facilityCd 施設コード
   * @param patId  患者番号
   * @param hospPatId  患者番号(連携用)
   * @param ordNo オーダ番号
   * @param coopCd 連携種別
   * @param coopVersion 連携版番号
   * @return
   */
  @Select
// mod 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//  // mod 2021-04-13 連携オーダ番号の患者番号（連携用）を追加 孫 start
////  List<OrdCoopNo> selectByPatIdAndOrdNoAndCoopCd(Long patId, Long ordNo, String coopCd);
//  List<OrdCoopNo> selectByPatIdAndOrdNoAndCoopCd(String facilityCd, Long patId, String hospPatId, Long ordNo, String coopCd);
//  // mod 2021-04-13 連携オーダ番号の患者番号（連携用）を追加 孫 end
  List<OrdCoopNo> selectByPatIdAndOrdNoAndCoopCd(String facilityCd, Long patId, String hospPatId, Long ordNo,
                                                 String coopCd, String coopVersion);
// mod 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

  /**
   * 連携オーダ番号テーブル情報を取得する
   * @param facilityCd 施設コード
   * @param coopVersion 連携版番号
   * @param patId  患者番号
   * @param hospPatId  患者番号(連携用)
   * @param coopOrdNo 連携オーダ番号
   * @return
   */
  @Select
// mod 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//  // mod 2021-04-13 連携オーダ番号の患者番号（連携用）を追加 孫 start
////  List<OrdCoopNo> selectByPatIdAndCoopOrdNo(Long patId, String coopOrdNo);
//  List<OrdCoopNo> selectByPatIdAndCoopOrdNo(String facilityCd, Long patId, String hospPatId, String coopOrdNo);
//  // mod 2021-04-13 連携オーダ番号の患者番号（連携用）を追加 孫 end
  List<OrdCoopNo> selectByPatIdAndCoopOrdNo(String facilityCd, String coopVersion, Long patId, String hospPatId,
                                            String coopOrdNo);
// mod 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

  /**
   * ord_coop_no_ctl_no_seq を取得します
   * @return sequence
   */
  @Select
  long selectNextSeqCtlNo();

  /**
   * ord_coop_no のレコードがあるかどうかチェック
   *
   * @param facilityCd 施設コード
   * @param ordNo オーダ番号
   * @param coopCd 連携種別
   * @return
   */
  @Select
  List<OrdCoopNo> selectByCondition(String facilityCd, Long ordNo, String coopCd);

  /**
   * insert処理
   * @param ordCoopNo 挿入する連携オーダ番号データのレコード
   * @return
   */
  @Insert(excludeNull = true,sqlFile = true)
  int insert(OrdCoopNo ordCoopNo);

  /**
   * update処理
   * @param patId 患者番号
   * @param hospPatId  患者番号(連携用)
   * @param ordNo オーダ番号
   * @param coopCd 連携種別
   * @param coopVersion 連携版番号
   * @param upDate 更新日時
   * @return
   */
  @Update(sqlFile = true)
// mod 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//  // mod 2021-04-13 連携オーダ番号の患者番号（連携用）を追加 孫 start
////  int updateIsDelIsDisp(Long patId, Long ordNo, String coopCd, Timestamp upDate);
//  int updateIsDelIsDisp(Long patId, String hospPatId, Long ordNo, String coopCd, Timestamp upDate);
//  // mod 2021-04-13 連携オーダ番号の患者番号（連携用）を追加 孫 end
  /* modify by chamaojia 2023-05-16 [8637] クエリー条件を追加してインデックス効率を向上  --start */
  int updateIsDelIsDisp(Long patId, String hospPatId, Long ordNo, String coopCd, String coopVersion, Timestamp upDate
          , String facilityCd, String coopOrdNo);
  /* modify by chamaojia 2023-05-16 [8637] クエリー条件を追加してインデックス効率を向上  --end */
// mod 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

  /**
   * 連携オーダ番号テーブル情報を取得する
   * @param facilityCd 施設コード
   * @param patId  患者番号
   * @param hospPatId  患者番号(連携用)
   * @param coopCd 連携種別
   * @param coopVersion 連携版番号
   * @param coopOrdNo 連携オーダ番号
   * @return
   */
  @Select
// mod 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//  // mod 2021-04-13 連携オーダ番号の患者番号（連携用）を追加 孫 start
////  OrdCoopNo selectByPatIdAndCoopCdAndCoopOrdNo(Long patId, String coopCd, String coopOrdNo);
//  OrdCoopNo selectByPatIdAndCoopCdAndCoopOrdNo(String facilityCd, Long patId, String hospPatId, String coopCd, String coopOrdNo);
//  // mod 2021-04-13 連携オーダ番号の患者番号（連携用）を追加 孫 end
  OrdCoopNo selectByPatIdAndCoopCdAndCoopOrdNo(String facilityCd, Long patId, String hospPatId,
                                               String coopCd, String coopVersion, String coopOrdNo);
// mod 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

  /**
   * ord_coop_no_ctl_no_seq を取得します
   * @return sequence
   */
  /**
   * update処理
   * @param ordCoopNo 連携オーダ番号エンティティ
   * @return
   */
  @Update
  int update(OrdCoopNo ordCoopNo);
  // add 2020-12-17 FNSI-改修 外部連携721(前回処理結果による処理変更) 夏 start

  /**
   * update処理
   * @param facilityCd 施設コード
   * @param patId 患者番号
   * @param hospPatId  患者番号(連携用)
   * @param ordNo オーダ番号
   * @param coopCd 連携種別
   * @param coopVersion 連携版番号
   * @param coopOrdNo 連携オーダ番号
   * @param upDate 更新日時
   * @return
   */
  @Update(sqlFile = true)
// mod 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//  int updateIsStatus(String facilityCd, Long patId, String hospPatId, Long ordNo, String coopCd, String coopOrdNo, Timestamp upDate);
  int updateIsStatus(String facilityCd, Long patId, String hospPatId, Long ordNo,
                     String coopCd, String coopVersion, String coopOrdNo, Timestamp upDate);
// mod 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
  // add 2020-12-17 FNSI-改修 外部連携721(前回処理結果による処理変更) 夏 end

  // add 2021-08-26 「受信時、ord_coop_noに２つデータを追加するの問題」の対応 孫 start
  /**
   * update処理
   * @param ordCoopNo 連携オーダ番号エンティティ
   * @return
   */
  @Update(sqlFile = true)
  int updateByCoopOrdNo(OrdCoopNo ordCoopNo);

  // add 2021-08-26 「受信時、ord_coop_noに２つデータを追加するの問題」の対応 孫 end

  /**
   * @return {OrdCoopNo }
   */
  @Select
  List<OrdCoopNo> selectOrdCoopNoByCoopOrdNoList(List<Long> ordNoSet,String facilityCd);
}
