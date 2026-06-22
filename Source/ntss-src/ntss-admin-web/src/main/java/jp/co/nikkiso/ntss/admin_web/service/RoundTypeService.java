package jp.co.nikkiso.ntss.admin_web.service;

import java.util.List;

import jp.co.nikkiso.ntss.admin_web.response.roundType.RoundTypeNameAndContentResponse;

/**
 * 種別マスタ用のServiceインターフェース.
 */
public interface RoundTypeService {
  /**
   * 種別名と内容を取得する.
   * @return 種別名と内容のレスポンス.
   */
  List<RoundTypeNameAndContentResponse> createRoundTypeNameAndContentResponse(String facilityCd);
}
