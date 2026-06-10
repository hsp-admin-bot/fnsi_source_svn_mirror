package jp.co.nikkiso.ntss.device_edge.service;

import java.io.IOException;
import java.net.URISyntaxException;
import java.text.ParseException;

public interface ComsvSendConditionCommFailService {
  int sendConditionProc(String facility_cd, String json) throws ParseException, URISyntaxException, IOException;
}
