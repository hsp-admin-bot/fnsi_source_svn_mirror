<script>
import baseCard from "@/components/pat-info/base-components/BaseCard.vue";
import cardContent from "@/components/pat-info/vendor-contact-card/VendorContactCardContent";

export default {
  components: {
    "card-content": cardContent
  },
  mixins: [baseCard],

  data() {
    return {
      // mod FNSI じょはく start
      // cardName: "連絡先(業者)",
      cardName: "連絡先(サービス業者)",
      // mod FNSI じょはく end
      addItemAvailable: true,
      actionModeAvailable: true
    };
  }
};
</script>
