package jp.co.nikkiso.ntss.core.entity;

import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
public class PatientInfoSharingDetails {

  private List<ShrPatInfo>  facilityToList;
  private List<ShrPatInfo>  facilityFromList;
}
