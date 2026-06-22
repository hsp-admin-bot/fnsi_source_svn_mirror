package jp.co.nikkiso.ntss.admin_web.request.weight;

import jp.co.nikkiso.ntss.core.entity.custom.PatExamPrint;
import lombok.Data;

import java.util.List;

@Data
public class PatExamPrintRequest {

  private Long patId;

  private String baseDate;

  private List<PatExamPrint> itemCdList;
}
