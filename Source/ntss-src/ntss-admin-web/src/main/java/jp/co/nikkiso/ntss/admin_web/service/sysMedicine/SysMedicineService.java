package jp.co.nikkiso.ntss.admin_web.service.sysMedicine;

import jp.co.nikkiso.ntss.core.entity.SysMedicine;

import java.util.List;

/**
 * 標準医薬品マスタのServiceインタフェース.
 */
public interface SysMedicineService {

  /**
   * 標準医薬品マスタを取得します.
   */
  List<SysMedicine> getSysMedicineAll();

  /* add by zhaohan 2022-10-12 [7280] 標準医薬品マスタ検索を表示するのに時間がかかる。 --start */
  /**
   * 標準医薬品マスタを取得します.
   * 該当データがない場合には、nullｌを返却する.
   *
   * @param keyword キーワード
   * @param offset オフセット
   * @return 該当する {@link SysMedicine}
   */
  List<SysMedicine> getSysMedicineByKeyword(String keyword, Integer offset);
  /* add by zhaohan 2022-10-12 [7280] 標準医薬品マスタ検索を表示するのに時間がかかる。 --end */

  /**
   * 基準番号（HOTコード）に該当する {@link SysMedicine} を取得する.
   * 該当データがない場合には、nulｌを返却する.
   *
   * @param standardNo 基準番号(HOTコード)
   * @return 該当する {@link SysMedicine}
   */
  SysMedicine getSysMedicineByStandardNo(String standardNo);

  // add redmine 6238 標準医薬品マスタでデータが表示されない 宋qy start
  /**
   * 標準医薬品マスタを取得します.分页
   */
  List<SysMedicine> getSysMedicineByLimitAndOffset(Integer limit, Integer offset, String keyword);
  // add redmine 6238 標準医薬品マスタでデータが表示されない 宋qy end

  // add #6930 標準医薬品マスタの抽出で追加読み込みが行われない 徐博 start
  String getTotal();
  // add #6930 標準医薬品マスタの抽出で追加読み込みが行われない 徐博 end

  /***
   * 標準医薬品マスタ検索
   *
   * @param salesName 販売名
   * @return {@link SysMedicine}のリスト
   */
  List<SysMedicine> selectBySalesName(String salesName);
}
