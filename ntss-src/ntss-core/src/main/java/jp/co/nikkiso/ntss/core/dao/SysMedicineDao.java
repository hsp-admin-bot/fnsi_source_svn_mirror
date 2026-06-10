package jp.co.nikkiso.ntss.core.dao;

import jp.co.nikkiso.ntss.core.entity.SysMedicine;
import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;

import java.util.List;

/**
 * 標準医薬品マスタのDaoインタフェース.
 */
@ConfigAutowireable
@Dao
public interface SysMedicineDao {

  /**
   * 登録されている標準医薬品マスタ情報を全て取得する.
   * 未登録の場合は空のリストを返却する.
   *
   * @return {@link SysMedicine}のリスト
   */
  @Select
  List<SysMedicine> selectAll();

  /* add by zhaohan 2022-10-12 [7280] 標準医薬品マスタ検索を表示するのに時間がかかる。 --start */
  /**
   * 登録されている標準医薬品マスタ情報のキーワード検索
   *
   * @param keyword キーワード
   * @param offset オフセット
   * @return {@link SysMedicine}のリスト
   */
  @Select
  List<SysMedicine> selectSysMedicineByKeyword(String keyword, Integer offset);
  /* add by zhaohan 2022-10-12 [7280] 標準医薬品マスタ検索を表示するのに時間がかかる。 --end */

  /**
   * 基準番号（HOTコード）に該当する {@link SysMedicine} を取得する.
   * 該当データがない場合には、nulｌを返却する.
   *
   * @param standardNo 基準番号(HOTコード)
   * @return 該当する {@link SysMedicine}
   */
  @Select
  SysMedicine selectByStandardNo(String standardNo);

  /**
   * 登録されている標準医薬品マスタ情報を取得する.
   * 本メソッドでは販売名(keyword)と取得開始位置(offset)と取得件数(limit)を指定する.
   * @param keyword 販売名で検索するキーワード
   * @param limit 取得上限件数
   * @param offset 開始位置
   * @return {@link SysMedicine}のリスト
   */
  @Select
  List<SysMedicine> selectSysMedicineByLimitAndOffset(Integer limit, Integer offset, String keyword);

  // add #6930 標準医薬品マスタの抽出で追加読み込みが行われない 徐博 start
  @Select
  String getTotal();
  // add #6930 標準医薬品マスタの抽出で追加読み込みが行われない 徐博 end

  /***
   * 標準医薬品マスタ検索
   *
   * @param salesName 販売名
   * @return {@link SysMedicine}のリスト
   */
  @Select
  List<SysMedicine> selectBySalesName(String salesName);
}
