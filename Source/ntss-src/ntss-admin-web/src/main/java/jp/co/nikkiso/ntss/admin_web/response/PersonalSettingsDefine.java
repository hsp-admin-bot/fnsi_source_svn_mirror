package jp.co.nikkiso.ntss.admin_web.response;

import java.util.List;

import com.fasterxml.jackson.annotation.JsonProperty;
import jp.co.nikkiso.ntss.core.entity.SysPersonalSettingsDefine;
import lombok.AllArgsConstructor;
import lombok.Getter;

@AllArgsConstructor
@Getter
public class PersonalSettingsDefine {

  @JsonProperty("tab_define_cd")
  private final Integer tabDefineCd;

  @JsonProperty("edit_level")
  private final String editLevel;

  @JsonProperty("item_info")
  private final List<SysPersonalSettingsDefine.ItemInfoDetail> itemInfoDetail;

  @JsonProperty("combo_data")
  private final List<SysPersonalSettingsDefine.StaticCombo> staticCombo;
}
