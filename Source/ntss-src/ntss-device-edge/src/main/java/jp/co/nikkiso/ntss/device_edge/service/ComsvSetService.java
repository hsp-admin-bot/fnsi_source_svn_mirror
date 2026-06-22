package jp.co.nikkiso.ntss.device_edge.service;

import jp.co.nikkiso.ntss.core.entity.custom.ComsvSet;

/**
 * 通信サーバ設定サービス
 */
public interface ComsvSetService {

  ComsvSet selectComsvSet(String facilityCd, Integer deviceEdgeNo);
}
