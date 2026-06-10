<script>
import BaseCard from "@/components/pat-info/base-components/BaseCard";
import cardContent from "@/components/pat-info/addition-setting-card/AdditionSettingCardContent";

export default {
  name: "AdditionSettingCard",
  components: { "card-content": cardContent },
  mixins: [BaseCard],
  data() {
    return {
      cardName: "加算・管理料"
    };
  }
};
</script>
