<script>
import baseCard from "@/components/pat-info/base-components/BaseCard.vue";
import cardContent from "@/components/pat-info/visit-hst-card/VisitHstCardContent";

export default {
  components: {
    "card-content": cardContent
  },
  mixins: [baseCard],
  data() {
    return {
      cardName: "入外・転入出",
      addItemAvailable: true,
      actionModeAvailable: true
    };
  },
  
  computed: {
    jsonArray(){
      return this.cardContent.jsonArray;
    }
  },
  
  methods: {
    // 保存時に呼び出す
    addDeathItem(deathDate, deathFacility, deathCourse, deathDoctor) {
      this.cardContent.addDeathItem(
        deathDate,
        deathFacility,
        deathCourse,
        deathDoctor
      );
    },
    // add redmine 8302 透析歴が0年0ヶ月になる guanhao start
    setOldestDialysis() {
      this.cardContent.setOldestDialysis();
    },
    // add redmine 8302 透析歴が0年0ヶ月になる guanhao end
    setFacilityOwnData() {
      this.cardContent.setFacilityOwnData();
    },
    setCourseOwnData(CourseOwnData) {
      this.cardContent.setCourseOwnData(CourseOwnData);
    },
    setDoctorOwnData(DoctorOwnData) {
      this.cardContent.setDoctorOwnData(DoctorOwnData);
    },
    getMoveOutDate() {
      return this.cardContent.getMoveOutDate();
    },
    getIsCheckResetDifficulty() {
      return this.cardContent.getIsCheckResetDifficulty();
    },
    getOldestDialysis() {
      return this.cardContent.oldestDialysis;
    },
    deathItem() {
      return this.cardContent.deathItem();
    },
    deleteDeathItem(deleteJson) {
      return this.cardContent.deleteDeathItem(deleteJson);
    },
    getInOutStauts() {
      return this.cardContent.getInOutStauts();
    },
    setInOutVal(val) {
      return this.cardContent.setInOutVal(val);
    },
    setInOutEditVal(val, val1, val2) {
      return this.cardContent.setInOutEditVal(val, val1, val2);
    }
  }
};
</script>
