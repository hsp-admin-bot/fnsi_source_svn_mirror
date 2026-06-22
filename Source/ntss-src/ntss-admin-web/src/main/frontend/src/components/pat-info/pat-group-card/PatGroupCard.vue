<script>
import BaseCard from "@/components/pat-info/base-components/BaseCard";
import cardContent from "@/components/pat-info/pat-group-card/PatGroupCardContent";

export default {
  name: "PatGroupCard",
  components: {
    "card-content": cardContent
  },
  mixins: [BaseCard],
  data() {
    return {
      cardName: "患者グループ",
    };
  }
};
</script>
