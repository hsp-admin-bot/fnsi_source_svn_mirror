package jp.co.nikkiso.ntss.core.dto.PatInfo.SearchPat;

import java.util.List;
import lombok.Data;

@Data
public class OrdMainContainerWithRange {
    private List<Long> patIds;
    private String treatDate;
    private String treatDateStart;
    private String treatDateEnd;
    private String facilityCd;
}
