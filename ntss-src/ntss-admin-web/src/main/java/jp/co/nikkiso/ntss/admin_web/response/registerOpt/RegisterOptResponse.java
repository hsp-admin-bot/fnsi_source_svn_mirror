package jp.co.nikkiso.ntss.admin_web.response.registerOpt;

import jp.co.nikkiso.ntss.core.entity.PatTreatmentPattern;
import jp.co.nikkiso.ntss.core.entity.PatUnique;
import jp.co.nikkiso.ntss.core.entity.custom.PatRadMainData;
import jp.co.nikkiso.ntss.core.entity.custom.PatRadPatternData;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Collections;
import java.util.List;
import java.util.Map;


@AllArgsConstructor
@NoArgsConstructor
@Data
public class RegisterOptResponse {

  private boolean optSuccess = false;

  private String facilityName;

}
