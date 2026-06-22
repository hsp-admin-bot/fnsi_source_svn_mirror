package jp.co.nikkiso.ntss.core.entity.custom;

import lombok.Data;

import java.util.List;

@Data
public class SendJournalRequestPayload {
  private String facilityCd;
  private String message;


  private Integer ifEdgeType;

  private List<String> ngIpList;
}
