package jp.co.nikkiso.ntss.admin_web.service.mente;

import java.util.List;

import jp.co.nikkiso.ntss.core.entity.custom.CusMenteCategoryResponse;

/**
 * 検査カテゴリのServiceインタフェース.
 */
public interface MstMenteCategoryService {

  /**
   * すべての検査カテゴリを取得
   *
   * @param facilityCd 施設コード
   * @return 検査カテゴリ一覧
   */
  List<CusMenteCategoryResponse> getAll(String facilityCd);

}
