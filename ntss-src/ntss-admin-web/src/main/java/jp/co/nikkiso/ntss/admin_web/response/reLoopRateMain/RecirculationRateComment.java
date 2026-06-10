package jp.co.nikkiso.ntss.admin_web.response.reLoopRateMain;

import java.time.ZonedDateTime;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.databind.PropertyNamingStrategy;
import com.fasterxml.jackson.databind.annotation.JsonNaming;

import jp.co.nikkiso.ntss.admin_web.response.treatmentRecord.RecirculationRate;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@JsonNaming(PropertyNamingStrategy.SnakeCaseStrategy.class)
public class RecirculationRateComment extends RecirculationRate {
    public RecirculationRateComment(Long bioMoniCtlNo, ZonedDateTime date, Integer recirculationRate, Integer bloodFlow,
            String feedbackComment) {
        super(bioMoniCtlNo, date, recirculationRate, bloodFlow);
        this.reloopComment = feedbackComment;
    }
    @JsonProperty("reloop_comment")
    private String reloopComment;
}
