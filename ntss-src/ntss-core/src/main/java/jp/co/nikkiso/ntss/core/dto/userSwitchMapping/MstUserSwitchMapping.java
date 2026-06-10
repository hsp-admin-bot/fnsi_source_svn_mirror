package jp.co.nikkiso.ntss.core.dto.userSwitchMapping;

import jp.co.nikkiso.ntss.core.entity.MstUserSwitch;
import lombok.Data;

import java.util.ArrayList;
import java.util.List;

@Data
public class MstUserSwitchMapping {
  private long switchId;
  private String facilityCd;
  private long userId;
  private String dispUserId;
  private String optStatus;
  private String groupId;

  public static MstUserSwitchMapping toDto(MstUserSwitch userSwitch){
    MstUserSwitchMapping mapping = new MstUserSwitchMapping();
    mapping.setSwitchId(userSwitch.getSwitchId());
    mapping.setUserId(userSwitch.getUserId());
    mapping.setOptStatus(userSwitch.getOptStatus());
    mapping.setGroupId(userSwitch.getGroupId());
    mapping.setFacilityCd(userSwitch.getFacilityCd());
    return mapping;
  }
  public static List<MstUserSwitchMapping> toDtoList(List<MstUserSwitch> userSwitchList){
    List<MstUserSwitchMapping> list = new ArrayList<>();
    for (MstUserSwitch userSwitch : userSwitchList) {
      MstUserSwitchMapping mapping = new MstUserSwitchMapping();
      mapping.setSwitchId(userSwitch.getSwitchId());
      mapping.setUserId(userSwitch.getUserId());
      mapping.setOptStatus(userSwitch.getOptStatus());
      mapping.setGroupId(userSwitch.getGroupId());
      mapping.setFacilityCd(userSwitch.getFacilityCd());
      list.add(mapping);
    }
    return list;
  }

  public static MstUserSwitch toEntity(MstUserSwitchMapping userSwitch){
    MstUserSwitch mapping = new MstUserSwitch();
    mapping.setSwitchId(userSwitch.getSwitchId());
    mapping.setUserId(userSwitch.getUserId());
    mapping.setOptStatus(userSwitch.getOptStatus());
    mapping.setGroupId(userSwitch.getGroupId());
    mapping.setFacilityCd(userSwitch.getFacilityCd());
    return mapping;
  }
  public static List<MstUserSwitch> toEntityList(List<MstUserSwitchMapping> userSwitchList){
    List<MstUserSwitch> list = new ArrayList<>();
    for (MstUserSwitchMapping userSwitch : userSwitchList) {
      MstUserSwitch mapping = new MstUserSwitch();
      mapping.setSwitchId(userSwitch.getSwitchId());
      mapping.setUserId(userSwitch.getUserId());
      mapping.setOptStatus(userSwitch.getOptStatus());
      mapping.setGroupId(userSwitch.getGroupId());
      mapping.setFacilityCd(userSwitch.getFacilityCd());
      list.add(mapping);
    }
    return list;
  }

}
