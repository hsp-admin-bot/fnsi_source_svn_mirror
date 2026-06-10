<script>
import baseCard from "@/components/pat-info/base-components/BaseCard.vue";
import cardContent from "@/components/pat-info/other-contact-card/OtherContactCardContent";

export default {
  components: {
    "card-content": cardContent
  },
  mixins: [baseCard],

  data() {
    return {
      cardName: "連絡先",
      addItemAvailable: true,
      actionModeAvailable: true
    };
  }
};
</script>
