package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.BatchInsert;
import org.seasar.doma.Dao;
import org.seasar.doma.Delete;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;
import org.seasar.doma.jdbc.SelectOptions;

import jp.co.nikkiso.ntss.core.entity.MstCoopLayout;

/**
 * 連携電文設定マスタDao
 *
 */
@ConfigAutowireable
@Dao
public interface MstCoopLayoutDao {

  /**
   * mst_coop_layoutテーブルのレコードをプライマリキーにより取得する。
   *
   * @param facilityCd 施設コード
   * @param coopCd 電文種別
   * @param coopCdIndex 付帯情報（電文）
   * @param coopVersion 連携版番号
   * @param direction 向き（送受信）
   * @param coopCdSub 電文種別補足コード
   * @return mst_coop_layoutテーブルのレコード（MstCoopLayoutエンティティ）
   */
  @Select
// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//  MstCoopLayout select(String facilityCd, String coopCd, String coopCdIndex, String direction, String coopCdSub);
  MstCoopLayout select(String facilityCd, String coopCd, String coopCdIndex, String coopVersion, String direction,
                       String coopCdSub);
// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
  /**
   * mst_coop_layoutテーブルの複数レコードをプライマリキーにより取得する。
   *
   * @param facilityCd 施設コード
   * @param coopCd 電文種別
   * @param coopCdIndex 付帯情報（電文）
   * @param coopVersion 連携版番号
   * @param direction 向き（送受信）
   * @param coopCdSub 電文種別補足コード
   * @return mst_coop_layoutテーブルのレコード（MstCoopLayoutエンティティ）
   */
  @Select
// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//  List<MstCoopLayout> selectList(String facilityCd, String coopCd, String coopCdIndex, String direction, String coopCdSub);
  List<MstCoopLayout> selectList(String facilityCd, String coopCd, String coopCdIndex, String coopVersion,
                                 String direction, String coopCdSub);
// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

  /**
   * mst_coop_layoutテーブルのレコードをプライマリキーにより取得する。
   *
   * @param facilityCd 施設コード
   * @param coopCd 電文種別
   * @param coopCdIndex 付帯情報（電文）
   * @param coopVersion 連携版番号
   * @param direction 向き（送受信）
   * @param coopCdSub 電文種別補足コード
   * @param coopName 連携名
   * @return mst_coop_layoutテーブルのレコード（MstCoopLayoutエンティティ）ｓ
   */
  @Select
// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//  MstCoopLayout selectByMstCoopIniHeaderMode(String facilityCd, String coopCd, String coopCdIndex, String direction, String coopCdSub,String coopName);
  MstCoopLayout selectByMstCoopIniHeaderMode(String facilityCd, String coopCd, String coopCdIndex, String coopVersion,
                                             String direction, String coopCdSub, String coopName);
// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

  /**
   * DB Mst_coop_layoutのすべてのプロパティを選択します
   * @return リストには、DB Mst_coop_layoutのアイテムが含まれています
   */
  @Select
  List<MstCoopLayout> selectAllItemCoopLayout(SelectOptions options);

  /**
   * 管理番号によってMst_coop_layoutを選択します
   * @param ctl_no 管理番号
   * @return オブジェクトには、DB Mst_coop_layoutのアイテムが含まれています
   */
  @Select
  MstCoopLayout selectMstCoopLayoutByCtlNo(Long ctlNo);

  /**
   * レイアウト名称でMst_coop_layoutを選択します
   * @param coop_name レイアウト名称
   * @return オブジェクトには、DB Mst_coop_layoutのアイテムが含まれています
   */
  @Select
  List<MstCoopLayout> selectMstCoopLayoutByCoopName(SelectOptions options, String coopName);

  /**
   * 連携電文レイアウトを挿入
   * @param 連携電文設定マスタEntity
   * @return 0または1
   */
  @Insert(sqlFile = true)
  int insertMstCoopLayout(MstCoopLayout mcl);

  /**
   * 連携電文レイアウトを更新する
   * @param 連携電文設定マスタEntity
   * @return
   */
  @Update(suppressOptimisticLockException = true)
  int updateMstCoopLayout(MstCoopLayout mcl);

  /**
   * 連携電文レイアウトを施設CD、電文種別、電文種別補足コードで削除
   * @param options オプション
   * @param facilityCd 施設CD
   * @param coopCd 電文種別
   * @param coopCdSub 電文種別補足コード
   * @return
   */
  @Select
  List<MstCoopLayout> selectMstCoopLayoutByFacilityCdAndCoopCdAndCoopCdSub(String facilityCd, String coopCd, String coopCdSub);

  /**
   * FacilityCd、CoopCd、CoopCdSubによってMstCoopLayoutを選択します
   * @param options オプション
   * @param facilityCd 施設CD
   * @param coopCd 電文種別
   * @param coopCdSub 電文種別補足コード
   * @return
   */
  @Select
  List<MstCoopLayout> selectMstCoopLayoutByFacilityCdOrCoopCdOrCoopCdSub(MstCoopLayout mstCoopLayout);

  @Select
  List<MstCoopLayout> selectSource(String coopVersion, String coopCd, String direction);

  @Select
  List<MstCoopLayout> selectCurrentByFacilityCd(String facilityCd);

  /**
   * 連携レイアウトを登録
   * @param mstCoopLayouts 連携レイアウトオブジェクト
   * @return
   */
  @BatchInsert
  int[] insert(List<MstCoopLayout> mstCoopLayouts);
  /**
   * 条件で連携レイアウトを取得
   * @param facilityCd 施設CD
   * @param coopCd 電文種別
   * @param coopCdSub 電文種別補足コード
   * @return
   */
  @Select
  List<MstCoopLayout> selectMstCoopLayoutByCondition(String facilityCd, String coopCd, String coopCdSub);
  /**
   * mst_coop_layoutテーブルのレコードをプライマリキーにより取得する。
   * 電文種別補足コードが引数に一致するレコードがなく、allのレコードがある場合は後者を取得する。
   *
   * @param facilityCd 施設コード
   * @param coopCd 電文種別
   * @param coopCdIndex 付帯情報（電文）
   * @param coopVersion 連携版番号
   * @param direction  向き（送受信）
   * @param coopCdSub 電文種別補足コード
   * @param allConst 電文種別補足コードallに対応する定数
   * @return mst_coop_layoutテーブルのレコード（MstCoopLayoutエンティティ）
   */
  @Select
// mod 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 start
//// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
////  MstCoopLayout selectWithAll(String facilityCd, String coopCd, String coopCdIndex, String direction, String coopCdSub,
////                              String allConst);
//  MstCoopLayout selectWithAll(String facilityCd, String coopCd, String coopCdIndex, String coopVersion,
//                              String direction, String coopCdSub, String allConst);
//// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
  List<MstCoopLayout> selectWithAll(String facilityCd, String coopCd, String coopCdIndex, String coopVersion,
                                    String direction, String coopCdSub, String allConst);
// mod 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 end

  // add 2021-03-31 課題2と課題12の対応、受信のプロセスを修正 商 start
  /**
   * mst_coop_layoutテーブルのレコードをプライマリキーにより取得する。
   * 電文種別補足コードが引数に一致するレコードがなく、allのレコードがある場合は後者を取得する。
   *
   * @param facilityCd 施設コード
   * @param coopCd 電文種別
   * @param coopCdIndex 付帯情報（電文）
   * @param coopVersion 連携版番号
   * @param direction  向き（送受信）
   * @param coopCdSub 電文種別補足コード
   * @return mst_coop_layoutテーブルのレコード（MstCoopLayoutエンティティ）
   */
  @Select
// mod 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 start
//// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
////  MstCoopLayout selectAllByCoopCdSub(String facilityCd, String coopCd, String coopCdIndex, String direction, String coopCdSub);
//  MstCoopLayout selectAllByCoopCdSub(String facilityCd, String coopCd, String coopCdIndex, String coopVersion,
//                                     String direction, String coopCdSub);
//// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
//  // add 2021-03-31 課題2と課題12の対応、受信のプロセスを修正 商 end
  List<MstCoopLayout> selectAllByCoopCdSub(String facilityCd, String coopCd, String coopCdIndex, String coopVersion,
                                           String direction, String coopCdSub);
// mod 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 end

  /**
   * 最新の連携電文レイアウトの管理番号を施設CDで取得する
   * @param facilityCd 施設CD
   * @return
   */
  @Select
  List<String> selectNewestCtlNoByFacilityCd(String facilityCd);

  /**
   * 施設コードで連携レイアウトを削除
   * @param facilityCd 施設コード
   * @return
   */
  @Delete(sqlFile = true)
  int deleteByFacilityCd(String facilityCd);
  //add #9256 is_zero_end取得できなかった項目 ljg start
  @Select
  String selectLayoutname(String facilityCd, String coopcd, String coopCdsub , String direction, String coopVersion,String sqcCd, String coopCdIndex);
  //add #9256 is_zero_end取得できなかった項目 ljg end
}
