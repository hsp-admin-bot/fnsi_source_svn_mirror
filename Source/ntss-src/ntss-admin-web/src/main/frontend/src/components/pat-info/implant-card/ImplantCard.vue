<script>
import baseCard from "@/components/pat-info/base-components/BaseCard.vue";
import cardContent from "@/components/pat-info/implant-card/ImplantCardContent.vue";

export default {
  components: {
    "card-content": cardContent
  },
  mixins: [baseCard],

  data() {
    return {
      cardName: "インプラント",
      addItemAvailable: true,
      actionModeAvailable: true
    };
  }
};
</script>
