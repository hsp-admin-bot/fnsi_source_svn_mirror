package jp.co.nikkiso.ntss.core.dto.ClFacility;

import lombok.Data;

import java.sql.Timestamp;

@Data
public class ClFacilityInfo {

  private String facilityCd;

  private String facilityName;

  private String prefecturesCd;

  private Timestamp expiredDate;

  private int maxDownload;

  private int curDownload;

  private String latestIssuedUser;

  private int attemptFail;

  private int facilityCount;
}
