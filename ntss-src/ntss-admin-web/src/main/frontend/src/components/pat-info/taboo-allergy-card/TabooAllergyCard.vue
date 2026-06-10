<script>
import baseCard from "@/components/pat-info/base-components/BaseCard.vue";
import cardContent from "@/components/pat-info/taboo-allergy-card/TabooAllergyCardContent";

export default {
  components: {
    "card-content": cardContent
  },
  mixins: [baseCard],

  data() {
    return {
      cardName: "禁忌・アレルギー",
      addItemAvailable: true,
      actionModeAvailable: true
    };
  }
};
</script>
