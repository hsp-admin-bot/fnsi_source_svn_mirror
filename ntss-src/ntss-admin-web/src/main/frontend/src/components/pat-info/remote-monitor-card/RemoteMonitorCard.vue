<script>
import baseCard from "@/components/pat-info/base-components/BaseCard.vue";
import cardContent from "@/components/pat-info/remote-monitor-card/RemoteMonitorCardContent";

export default {
  components: {
    "card-content": cardContent
  },
  mixins: [baseCard],

  data() {
    return {
      cardName: "利用遠隔モニタリングサービス"
    };
  },

  methods: {
  }
};
</script>
