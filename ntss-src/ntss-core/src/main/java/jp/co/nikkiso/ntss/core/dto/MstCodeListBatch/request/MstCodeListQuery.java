package jp.co.nikkiso.ntss.core.dto.MstCodeListBatch.request;

import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
public class MstCodeListQuery {
  private String mstCode;
  private List<String> codeList;
}

