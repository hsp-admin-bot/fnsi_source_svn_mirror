<script>
import baseCard from "@/components/pat-info/base-components/BaseCard.vue";
import cardContent from "@/components/pat-info/difficulty-severity-transport-card/DifficultySeverityTransportCardContent.vue";

export default {
  components: {
    "card-content": cardContent
  },
  mixins: [baseCard],
  // 車いす情報取得の為、編集患者のIDを取得(新規患者の場合はID=0)
  props: {
    patId: {
      type: Number,
      default: 0
    }
  },

  data() {
    return {
      cardName: "透析困難・重症度・搬送区分"
    };
  },

  methods: {
    // 更新日設定
    // ※保存時に呼び出す
    setRegDate() {
      this.cardContent.setRegDate();
    },
    // 透析困難情報をリセットする
    // ※保存時に呼び出す
    setClearDialDiffInfo() {
      this.cardContent.setClearDialDiffInfo();
    },
    // 透析困難が未登録か確認する
    // ※保存時に呼び出す
    getHasDialDiffEdit() {
      return this.cardContent.getHasDialDiffEdit();
    }
  }
};
</script>
