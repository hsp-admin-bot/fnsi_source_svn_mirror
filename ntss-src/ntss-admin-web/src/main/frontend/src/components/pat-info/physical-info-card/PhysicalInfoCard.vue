<script>
import baseCard from "@/components/pat-info/base-components/BaseCard.vue";
import cardContent from "@/components/pat-info/physical-info-card/PhysicalInfoCardContent";

export default {
  components: {
    "card-content": cardContent
  },
  mixins: [baseCard],

  data() {
    return {
      cardName: "身体情報",
      addItemAvailable: true,
      actionModeAvailable: false
    };
  }
};
</script>
