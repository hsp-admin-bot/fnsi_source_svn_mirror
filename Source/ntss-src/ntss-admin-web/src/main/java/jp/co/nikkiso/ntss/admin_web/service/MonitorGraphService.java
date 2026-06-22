package jp.co.nikkiso.ntss.admin_web.service;

import jp.co.nikkiso.ntss.admin_web.response.monitor.MonitorGraphDefineResponse;

import java.util.List;

/**
 * モニタグラフ用のServiceインターフェース.
 */
public interface MonitorGraphService {
  /**
   * モニタグラフ情報を取得する.
   * @return モニタグラフ情報のレスポンス.
   */
  List<MonitorGraphDefineResponse> createMonitorGraphDefineResponse(String facilityCd);
}
