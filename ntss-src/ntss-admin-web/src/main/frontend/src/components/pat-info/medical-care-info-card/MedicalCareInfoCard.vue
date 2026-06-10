<script>
import baseCard from "@/components/pat-info/base-components/BaseCard.vue";
import cardContent from "@/components/pat-info/medical-care-info-card/MedicalCareInfoCardContent";

export default {
  components: {
    "card-content": cardContent
  },
  mixins: [baseCard],

  data() {
    return {
      cardName: "診療情報"
    };
  },

  methods: {
    getDialysisCourseCd() {
      return this.cardContent.getDialysisCourseCd();
    },

    setOldestDialysis(dialysis) {
      this.cardContent.setOldestDialysis(dialysis);
    }
  }
};
</script>
