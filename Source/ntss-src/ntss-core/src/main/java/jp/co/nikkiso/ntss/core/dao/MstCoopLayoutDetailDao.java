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

import jp.co.nikkiso.ntss.core.entity.MstCoopLayoutDetail;

/**
 * 連携電文設定マスタ詳細Dao
 *
 */
@ConfigAutowireable
@Dao
public interface MstCoopLayoutDetailDao {

  /**
   * 変換レイアウト詳細テーブルのレコードをプライマリキーにより取得する。
   *
   * @param facilityCd 施設コード
   * @param coopCd 電文種別
   * @param coopVersion 連携版番号
   * @param direction 向き（送受信）
   * @param coopCdDetail 電文種別詳細コード
   * @param coopCdDetailSub 電文種別詳細補足コード
   * @return mst_coop_layout_detailテーブルのレコード（変換レイアウト詳細エンティティ）
   */
  @Select
// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//  MstCoopLayoutDetail select(String facilityCd, String coopCd, String direction, String coopCdDetail,
//      String coopCdDetailSub);
  MstCoopLayoutDetail select(String facilityCd, String coopCd, String coopVersion, String direction, String coopCdDetail,
                             String coopCdDetailSub);
// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

// add 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 start
  /**
   * 変換レイアウト詳細テーブルの複数レコードをプライマリキーにより取得する。
   *
   * @param facilityCd 施設コード
   * @param coopCd 電文種別
   * @param coopVersion 連携版番号
   * @param direction 向き（送受信）
   * @param coopCdDetail 電文種別詳細コード
   * @param coopCdDetailSub 電文種別詳細補足コード
   * @return mst_coop_layout_detailテーブルのレコード（変換レイアウト詳細エンティティ）
   */
  @Select
  List<MstCoopLayoutDetail> selectList(String facilityCd, String coopCd, String coopVersion, String direction,
                                       String coopCdDetail, String coopCdDetailSub);

  @Select
  List<MstCoopLayoutDetail> selectSource(String coopVersion, String coopCd, String direction);

  @Select
  List<MstCoopLayoutDetail> selectCurrentByFacilityCd(String facilityCd);
// add 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 end

  /**
   * すべてのプロパティを選択します
   * @param coopCd 電文種別
   * @return リストには、変換レイアウト詳細のアイテムが含まれています
   */
  @Select
  List<MstCoopLayoutDetail> selectAllMstCoopLayoutDetail(SelectOptions options);

  /**
   * 管理番号によって変換レイアウト詳細を選択します
   * @param ctl_no 管理番号
   * @return 変換レイアウト詳細
   */
  @Select
  MstCoopLayoutDetail selectMstCoopLayoutDetailByCtlNo(Long ctlNo);

  /**
   * 最新の変換レイアウト詳細の管理番号を施設CDで取得する
   * @param facilityCd 施設CD
   * @return
   */
  @Select
  List<String> selectNewestCtlNoByFacilityCd(String facilityCd);

  /**
   * 変換レイアウト詳細を挿入します
   * @param 変換レイアウト詳細を表すエンティティクラス。
   * @return 0または1
   */
  @Insert(sqlFile = true)
  int insertMstCoopLayoutDetail(MstCoopLayoutDetail mcld);

  /**
   * 変換レイアウト詳細を更新
   * @param 変換レイアウト詳細を表すエンティティクラス。
   * @return 0または1
   */
  @Update(sqlFile = true)
  int updateMstCoopLayoutDetail(MstCoopLayoutDetail mcld);

  /**
   * 変換レイアウト詳細を削除する
   * @param ctlNo
   * @return 0または1
   */
  @Delete(sqlFile = true)
  int deleteMstCoopLayoutDetail(Long ctlNo);

  /**
   * ユーザーを介して変換レイアウト詳細を削除する
   * @param ctlNo
   * @return
   */
  @Update(sqlFile = true)
  int deleteMstCoopLayoutDetailByUser(Long ctlNo);

  /**
   * mst_coop_layout_detailテーブルのレコードをプライマリキーにより取得する。
   * 電文種別詳細補足コードが引数に一致するレコードがなく、preのレコードがある場合は後者を取得する。
   *
   * @param facilityCd 施設コード
   * @param coopCd 電文種別
   * @param coopVersion 連携版番号
   * @param direction 向き（送受信）
   * @param coopCdDetail 電文種別詳細コード
   * @param coopCdDetailSub 電文種別詳細補足コード
   * @param preConst 電文種別詳細補足コードpreに対応する定数
   * @param allConst 電文種別詳細補足コードallに対応する定数
   * @return mst_coop_layout_detailテーブルのレコード（MstCoopLayoutDetailエンティティ）
   */
  @Select
// mod 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 start
//// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
////  MstCoopLayoutDetail selectWithPre(String facilityCd, String coopCd, String direction, String coopCdDetail,
////      String coopCdDetailSub, String preConst, String allConst);
//  MstCoopLayoutDetail selectWithPre(String facilityCd, String coopCd, String coopVersion, String direction,
//                                    String coopCdDetail, String coopCdDetailSub, String preConst, String allConst);
//// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
  List<MstCoopLayoutDetail> selectWithPre(String facilityCd, String coopCd, String coopVersion, String direction,
                            String coopCdDetail, String coopCdDetailSub, String preConst, String allConst);
// mod 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 end

  /**
   * 変換レイアウト詳細を登録
   * @param mstCoopLayoutDetail 変換レイアウト詳細
   * @return
   */
  @Insert
  int insert(MstCoopLayoutDetail mstCoopLayoutDetail);

  /**
   * 変換レイアウト詳細一覧を登録
   * @param mstCoopLayoutDetails 変換レイアウト詳細一覧
   * @return
   */
  @BatchInsert
  int[] insert(List<MstCoopLayoutDetail> mstCoopLayoutDetails);

  /**
   * 連携電文設定マスタ詳細を取得する
   * @param facilityCd 施設コード
   * @param coopCd 電文種別
   * @param coopVersion 連携版番号
   * @param direction 向き（送受信）
   * @param coopCdDetail 電文種別詳細コード
   * @param coopCdDetailSub 電文種別詳細補足コード
   * @return 連携電文設定マスタ詳細
   */
  @Select
// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//  MstCoopLayoutDetail selectMstCoopLayoutDetail(String facilityCd, String coopCd, String direction, String coopCdDetail, String coopCdDetailSub);
  MstCoopLayoutDetail selectMstCoopLayoutDetail(String facilityCd, String coopCd, String coopVersion, String direction,
                                                String coopCdDetail, String coopCdDetailSub);
// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

  /**
   * 施設コードで変換レイアウト詳細を削除
   * @param facilityCd 施設コード
   * @return
   */
  @Delete(sqlFile = true)
  int deleteByFacilityCd(String facilityCd);

 //add 7279 detail取得   ljg start
  @Select
// mod 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 start
//// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
////  MstCoopLayoutDetail selectWithPrecopy(String facilityCd, String coopCd, String direction, String coopCdDetail,
////                                        String coopCdDetailSub);
//  MstCoopLayoutDetail selectWithPrecopy(String facilityCd, String coopCd, String coopVersion, String direction,
//                                        String coopCdDetail, String coopCdDetailSub);
//// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
  List<MstCoopLayoutDetail> selectWithPrecopy(String facilityCd, String coopCd, String coopVersion, String direction,
                                      String coopCdDetail, String coopCdDetailSub);
// mod 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 end
  //add 7279 detail取得   ljg end
}
