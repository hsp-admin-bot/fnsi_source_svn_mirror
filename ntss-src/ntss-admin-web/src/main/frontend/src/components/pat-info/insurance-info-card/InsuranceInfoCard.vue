<script>
import baseCard from "@/components/pat-info/base-components/BaseCard.vue";
import cardContent from "@/components/pat-info/insurance-info-card/InsuranceInfoCardContent";

export default {
  components: {
    "card-content": cardContent
  },
  mixins: [baseCard],

  data() {
    return {
      cardName: "保険情報",
      addItemAvailable: true,
      actionModeAvailable: true
    };
  },
  // add FNSI-保険選択の変更 関 start
  methods:{
    getIsInsuranceChange() {
      // mod FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 start
      return (undefined !== this.cardContent && null !== this.cardContent) ? this.cardContent.getIsInsuranceChange() : null;
      // mod FNSI6512-何も編集していないが、保存ボタンが押せてしまう。 周 end
    },
    getIsInsuranceSelectCd() {
      return this.cardContent.getIsInsuranceSelectCd();
    }
  }
  // add FNSI-保険選択の変更 関 start

};
</script>
