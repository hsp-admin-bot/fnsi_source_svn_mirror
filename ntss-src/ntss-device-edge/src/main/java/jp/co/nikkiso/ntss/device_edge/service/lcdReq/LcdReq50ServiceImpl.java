package jp.co.nikkiso.ntss.device_edge.service.lcdReq;

import java.io.IOException;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import tools.jackson.databind.ObjectMapper;

import jp.co.nikkiso.ntss.core.dao.MstSelectorDao;
import jp.co.nikkiso.ntss.core.entity.MstSelector;
import jp.co.nikkiso.ntss.core.entity.custom.lcdReq.LcdReq50;

/**
 * 仮想端末情報（愁訴処置）サービス
 */
@Service
public class LcdReq50ServiceImpl implements LcdReq50Service {

  @Autowired
  MstSelectorDao mstSelector;

  @Override
  public LcdReq50 selectAll(String facility_cd) throws IOException {
	LcdReq50 lcdReq50 = new LcdReq50();
    ObjectMapper mapper = new ObjectMapper();

	// 愁訴
	MstSelector comp = mstSelector.selectByName(facility_cd, "mst_complaint");
    String compJson = mapper.writeValueAsString(comp.getOrderSettings());
    lcdReq50.setCompOrderSettings(compJson);

	// 処置
	MstSelector treat = mstSelector.selectByName(facility_cd, "mst_comp_treatment");
    String treatJson = mapper.writeValueAsString(treat.getOrderSettings());
    lcdReq50.setTreatOrderSettings(treatJson);

    return lcdReq50;
  }

}
