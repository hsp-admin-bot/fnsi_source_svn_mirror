package jp.co.nikkiso.ntss.device_edge.service.lcdReq;

import java.util.List;

import jp.co.nikkiso.ntss.core.entity.custom.lcdReq.LcdReq29;

/**
 * 仮想端末情報（処置者）サービス
 */
public interface LcdReq29Service {

  List<LcdReq29> selectByFacilityCd(String facilityCd, Integer deviceEdgeNo);
}
