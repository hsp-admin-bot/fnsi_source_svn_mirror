<script>
import MasterSelector from "@/components/common/master-selector/MasterSelector";
import { CODES } from "@/constants/TreatmentRecord";
//FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat'
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages'
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 end

export default {
  components: {
    "pop-over": MasterSelector
  },
  props: {
    readMasterData: {
      type: Function
    },
    masterDefine: {
      type: Object
    },
    isActiveBtn: {
      type: Boolean
    },
  },
  data() {
    return {
      popoverData: {
        popoverVisible: false,
        popoverTitleHeader: "",
        popoverFilter: [],
        popoverContentLabel: "",
        popoverContentDataset: [],
        popoverContentSelected: {},
        hasUnregisteredOption: true
      }
    };
  },
  watch: {
    /* ポップオーバー表示非表示を監視 */
    "popoverData.popoverVisible": {
      handler(newVal) {
        this.$emit('popover-visible-changed', newVal);
      }
    }
  },
  methods: {
    showPopover() {
      this.popoverData.popoverVisible = true;
    },
    closePopover() {
      this.popoverData.popoverVisible = false;
    },
    // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
    // createPopoverData(itemCd) {
      createPopoverData(itemCd, index) {
      // return this.readMasterData()
      return this.readMasterData(index)
      // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
        .then(response => {
          let masterData = null;
          let classData = null;
          if (Array.isArray(response)) {
            masterData = response[0].data;
            classData = response[1].data;
            if (response.length == 3) {
              masterData = masterData.concat(response[2].data);
            }
          } else {
            masterData = response.data;
          }

          // 有効なマスタのみを表示する
          masterData = masterData.filter(item => item.isDisp === CODES.IS_DISP.DISPLAY.cd);

          // ポップオーバのコンテンツデータ(フィルタしたデータ)を取りまとめる
          let contentArr = masterData.map(this.masterDefine.filterKey);

          this.popoverData.popoverTitleHeader = this.masterDefine.titleHeader;
          this.popoverData.hasUnregisteredOption = this.masterDefine.hasUnregisteredOption;
          if (this.showClassFilter) {
            let filter = [];
            // filterLabelが配列の場合
            if (Array.isArray(this.masterDefine.filterLabel)) {
              for (let index = 0; index < this.masterDefine.filterLabel.length; index++) {
                const label = this.masterDefine.filterLabel[index];
                const filterArr = this.masterDefine.filterArr[index];
                filter.push(
                {
                  popoverFilterLabel: label,
                  popoverFilterDataset: filterArr(masterData, classData)
                }
              );
              }
            } else {
              filter.push(
                {
                  popoverFilterLabel: this.masterDefine.filterLabel,
                  popoverFilterDataset: this.masterDefine.filterArr(
                    masterData,
                    classData
                  )
                }
              );
            }
            this.popoverData.popoverFilter = filter;
          }
          this.popoverData.popoverContentLabel = this.masterDefine.contentLabel;
          this.popoverData.popoverContentDataset = contentArr;
          const selectedItem = this.popoverData.popoverContentDataset.find(
            item => item.value === itemCd
          );
          if (selectedItem || this.isActiveBtn) {
            this.popoverData.popoverContentSelected = selectedItem;
          }
          this.showPopover();
        })
        .catch(() => {
           //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
           getErrorMessage('MasterSelectorMixin.vue', 'createPopoverData', 'システムエラーが発生しました');
           //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
          this.$ons.notification.alert({
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
            // title: "エラー",
            // message: "システムエラーが発生しました。"
            title: DIALOG_MESSAGES['00200002'].title,
            message: messageFormat(DIALOG_MESSAGES['00200002'].message)
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
          });
          this.$router.push({ name: "signin" });
        });
    }
  }
};
</script>
