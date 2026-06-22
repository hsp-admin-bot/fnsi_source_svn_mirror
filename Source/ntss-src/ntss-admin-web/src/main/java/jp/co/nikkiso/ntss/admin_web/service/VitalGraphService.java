package jp.co.nikkiso.ntss.admin_web.service;

import jp.co.nikkiso.ntss.admin_web.response.vital.VitalGraphDefineResponse;

import java.util.List;

/**
 * モニタグラフ用のServiceインターフェース.
 */
public interface VitalGraphService {
  /**
   * モニタグラフ情報を取得する.
   * @return モニタグラフ情報のレスポンス.
   */
  List<VitalGraphDefineResponse> createVitalGraphDefineResponse(String facilityCd);
}
