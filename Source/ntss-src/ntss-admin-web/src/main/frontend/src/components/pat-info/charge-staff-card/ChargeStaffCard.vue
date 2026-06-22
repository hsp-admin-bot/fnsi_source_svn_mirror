<script>
import baseCard from "@/components/pat-info/base-components/BaseCard.vue";
import cardContent from "@/components/pat-info/charge-staff-card/ChargeStaffCardContent.vue";

export default {
  components: {
    "card-content": cardContent
  },
  mixins: [baseCard],

  data() {
    return {
      cardName: "担当者",
      addItemAvailable: true,
      actionModeAvailable: true
    };
  },

  methods: {
    getMainStaff() {
      return this.cardContent.getMainStaff();
    }
  }
};
</script>
