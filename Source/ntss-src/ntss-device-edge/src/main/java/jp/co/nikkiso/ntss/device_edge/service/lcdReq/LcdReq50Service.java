package jp.co.nikkiso.ntss.device_edge.service.lcdReq;

import java.io.IOException;

import jp.co.nikkiso.ntss.core.entity.custom.lcdReq.LcdReq50;

/**
 * 仮想端末情報（愁訴処置）サービス
 */
public interface LcdReq50Service {

  LcdReq50 selectAll(String facility_cd) throws IOException;
}
