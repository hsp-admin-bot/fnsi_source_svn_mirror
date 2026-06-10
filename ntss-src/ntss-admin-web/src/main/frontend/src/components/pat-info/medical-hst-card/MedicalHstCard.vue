<script>
import baseCard from "@/components/pat-info/base-components/BaseCard.vue";
import cardContent from "@/components/pat-info/medical-hst-card/MedicalHstCardContent";

export default {
  components: {
    "card-content": cardContent
  },
  mixins: [baseCard],

  data() {
    return {
      cardName: "既往歴",
      addItemAvailable: true,
      actionModeAvailable: true
    };
  },

  computed: {
    isDie() {
      return this.cardContent.isDie;
    },

    dieDate() {
      return this.cardContent.dieDate;
    },

    jsonArray(){
      return this.cardContent.jsonArray;
    }
  },

  methods: {
    // Booleanを返す処理
    // ※保存時に呼び出す
    hasDeathItem() {
      return this.cardContent.hasDeathItem();
    },

    getDeathDate() {
      return this.cardContent.getDeathDate();
    },

    getDeathFacility() {
      return this.cardContent.getDeathFacility();
    },

    getDeathCourse() {
      return this.cardContent.getDeathCourse();
    },

    getDeathDiagnostician() {
      return this.cardContent.getDeathDiagnostician();
    },

    deathItem() {
      return this.cardContent.deathItem();
    },

    deleteDeathItem(deleteJson) {
      return this.cardContent.deleteDeathItem(deleteJson);
    }
  }
};
</script>
