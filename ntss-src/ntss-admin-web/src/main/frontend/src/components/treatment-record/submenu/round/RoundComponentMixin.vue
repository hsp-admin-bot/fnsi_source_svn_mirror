
<script>
import { mapGetters, mapActions } from "vuex";
import { RstRoundInfo } from "@/models/treatment-record/round/RstRoundInfo";

export default {
  computed: {
    ...mapGetters("treatment-record/roundsInfo", {
      isNewRoundInfo: "isNewRoundInfo",
      rstRoundsInfoInProgress: "rstRoundsInfoInProgress",
    }),
  },
  methods: {
    ...mapActions("treatment-record/addition", [
      "getTreatmentRecordAddition"
    ]),
    ...mapActions("treatment-record/roundsInfo", [
      "getRoundTypeNameAndContent",
      "getTreatmentRecordRstRoundsInfo",
      "fetchRoundTypes",
      "setRstRoundsInfoToCompare",
      "setRstRoundsInfoInProgress",
      "setSelectedRoundType",
      "setRstIndComments"
    ]),
    async getRstRoundsInfoAndSaveToStore() {
      //add 9724 ljx start コンソールError修正
      if(this.getOrdNo){
	  //add 9724 ljx end コンソールError修正
      const response = await this.getTreatmentRecordRstRoundsInfo(this.getOrdNo);
      const json = JSON.parse(response.data.rst_rounds_info);
      // add 9553 by kangjie 20230915 start
      //   this.rstRoundsInfo.toCompare = json ? RstRoundInfo.of(json) : null;
      //   this.rstRoundsInfo.inProgress = json ? RstRoundInfo.of(json) : RstRoundInfo.of();
      this.rstRoundsInfo.toCompare = json ==null? RstRoundInfo.of():RstRoundInfo.of(json);
      this.rstRoundsInfo.inProgress = json ==null? RstRoundInfo.of() : RstRoundInfo.of(json);
      //mod 10570回診記録指示コメント転記不具合_#10416指摘事項 zhao start
      this.hasInProgressFlag=true;
      //mod 10570回診記録指示コメント転記不具合_#10416指摘事項 zhao end
      this.setRstRoundsInfoToCompare(this.rstRoundsInfo.toCompare);
      this.setRstRoundsInfoInProgress(this.rstRoundsInfo.inProgress);
      const rstIndCommentResponse = await this.getTreatmentRecordAddition(this.getOrdNo);
      /* modify by chamaojia 2024-04-02 [10196] add null judgment processing  --start */
      // const rstIndCommentInfo = JSON.parse(rstIndCommentResponse.data.rst_ind_comment_info);
      // const rstIndComments = rstIndCommentInfo
      //   ? rstIndCommentInfo
      //   : [];
      const rstIndComments = (rstIndCommentResponse.data && rstIndCommentResponse.data.rst_ind_comment_info)
          ? JSON.parse(rstIndCommentResponse.data.rst_ind_comment_info) : [];
      /* modify by chamaojia 2024-04-02 [10196] add null judgment processing  --end */

      this.setRstIndComments({ rstIndComments });
	  //add 9724 ljx start コンソールError修正
      }
      //add 9724 ljx end コンソールError修正
      // add 9553 by kangjie 20230915 end
    },
    saveRoundType() {
      const roundType = (this.isNewRoundInfo && this.rstRoundsInfoInProgress.round_type_cd == null)
        ? this.roundTypes[0]
        : this.roundTypes
            .find(roundType => roundType.round_type_cd === this.rstRoundsInfoInProgress.round_type_cd)
      ;
      this.setSelectedRoundType({ selectedRoundType: roundType });
      if(roundType) this.selectedRoundTypeCd = roundType.round_type_cd;
    }
  }
}
</script>
