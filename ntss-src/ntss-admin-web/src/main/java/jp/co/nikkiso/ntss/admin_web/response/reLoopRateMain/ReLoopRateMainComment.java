package jp.co.nikkiso.ntss.admin_web.response.reLoopRateMain;

import java.time.ZonedDateTime;

import com.fasterxml.jackson.annotation.JsonProperty;
import tools.jackson.databind.PropertyNamingStrategies;
import tools.jackson.databind.annotation.JsonNaming;

import jp.co.nikkiso.ntss.admin_web.response.treatmentRecord.RecirculationRate;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@JsonNaming(PropertyNamingStrategies.SnakeCaseStrategy.class)
public class ReLoopRateMainComment extends RecirculationRate {
    public ReLoopRateMainComment(Long bioMoniCtlNo, ZonedDateTime date, Integer recirculationRate, Integer bloodFlow,
            String feedbackComment) {
        super(bioMoniCtlNo, date, recirculationRate, bloodFlow);
        this.reloopComment = feedbackComment;
    }
    @JsonProperty("reloop_comment")
    private String reloopComment;
}
