package jp.co.nikkiso.ntss.core.entity.custom;

import lombok.Data;
import org.json.JSONObject;

import java.util.List;

@Data
public class CtlNoInfo {

  private List<String> ctlNoList;

  private List<JSONObject> oldJSONList;

  private List<JSONObject> newJSONList;
}
