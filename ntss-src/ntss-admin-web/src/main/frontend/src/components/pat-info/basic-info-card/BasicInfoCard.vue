<script>
import baseCard from "@/components/pat-info/base-components/BaseCard.vue";
import basicInfoCardContent from "@/components/pat-info/basic-info-card/BasicInfoCardContent.vue";

export default {
  components: {
    "card-content": basicInfoCardContent
  },
  mixins: [baseCard],

  data() {
    return {
      cardName: "本人情報"
    };
  },

  methods: {
    //add FNSI-画面部品デザイン じょはく start
    addDeathItem() {
      return this.cardContent.addDeathItem();
    },
    changeFlag() {
      return this.cardContent.changeFlag();
    },
    //add FNSI-画面部品デザイン じょはく end
    getHospPatId() {
      return this.cardContent.getHospPatId();
    },
    getOldNewPatName() {
      return this.cardContent.getOldNewPatName();
    },
    // add FNSI-入外区分の入力方法を2種類(簡易/詳細)用意し、簡易入力 徐博 start
    getPatInOutClass() {
      return this.cardContent.getPatInOutClass();
    },
    // add FNSI-入外区分の入力方法を2種類(簡易/詳細)用意し、簡易入力 徐博 end
    // add FutreNetWeb+SI課題管理No6016 趙 start
    getPatInOutClassInitValue() {
      return this.cardContent.getPatInOutClassInitValue();
    },
    // add FutreNetWeb+SI課題管理No6016 趙 end
    getInOutClass(){
      // let inOutObj = this.getPatData('in_out_class');
      return  this.cardContent.getInOutClass();
    }
  }
};
</script>
