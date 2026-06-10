package jp.co.nikkiso.ntss.core.dto.OrdMain;

import java.util.ArrayList;
import java.util.List;

import jp.co.nikkiso.ntss.core.entity.MniMonitor;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import lombok.Getter;
import lombok.Setter;

/**
 * 予実リスト情報のDTO.
 */
@Getter
@Setter
public class OrdMainSharingInfo extends OrdMain {
    private boolean readOnly;
    //add FNSI-患者カレンダに表示する予定の不足情報を追加する 江 start
    private boolean hasExamResult;
    //add FNSI-患者カレンダに表示する予定の不足情報を追加する 江 end
    private List<MniMonitor> mniMonitorList = new ArrayList<MniMonitor>();
}
