<script>
import baseCard from "@/components/pat-info/base-components/BaseCard.vue";
import cardContent from "@/components/pat-info/infection-card/InfectionCardContent";

export default {
  components: {
    "card-content": cardContent
  },
  mixins: [baseCard],

  data() {
    return {
      cardName: "感染症"
    };
  },

  methods: {
    // 更新日設定
    // ※保存時に呼び出す
    setRegDate() {
      this.cardContent.setRegDate();
    }
  }
};
</script>
