import { findAncestorComponent, findAncestorWithAllKeys, findAncestorWithAnyKey, getComponentParent } from '@/functions/common/ComponentOwnerResolver';

export default {
  methods: {
    _indicationDialogOwner() {
      return (
        findAncestorComponent(this, vm => vm && vm.messageDialogInfo && (
          'structData' in vm ||
          'settingData' in vm ||
          'updateDisable' in vm ||
          'isUpdating' in vm ||
          'editAddFlg' in vm ||
          'editSelectIdFlg' in vm ||
          'treatMaxSelectedItems' in vm ||
          'kurMaxSelectedItems' in vm ||
          'isWatchParent' in vm ||
          'isDialogType9' in vm ||
          'facilityCd' in vm ||
          'componentData' in vm
        ), { maxDepth: 30 }) ||
        findAncestorWithAllKeys(this, ['messageDialogInfo'], { maxDepth: 30 }) ||
        getComponentParent(this) ||
        this
      );
    },
    _indicationFlowOwner() {
      return (
        findAncestorWithAnyKey(this, ['structData', 'settingData', 'componentData', 'facilityCd', 'edit', 'weekEdit', 'initStructData'], { maxDepth: 30 }) ||
        this._indicationDialogOwner()
      );
    },
    _indicationResultOwner() {
      return (
        findAncestorWithAnyKey(this, [
          'isRstUpdateFlg',
          'isShowedMessage',
          'treatDateListAll',
          'itemMsgCd14Flg',
          'itemMsgCd18Flg',
          'itemMsgCd20Flg',
          'itemMsgCd24Flg',
          'supplyLiquidSpeedFlg',
          'isIndActionChart',
          'isIndActionChartReset',
          'isSendNextPatInfoFlg',
          'isTreatTimeSettingFlg',
          'getDeviceSetInfoInd',
          'showOhdfComment'
        ], { maxDepth: 40 }) ||
        this._indicationFlowOwner()
      );
    },
    _indicationSourceOwner() {
      return (
        findAncestorWithAnyKey(this, ['indStartDate', 'structData', 'selOrdNo'], { maxDepth: 20 }) ||
        this._indicationFlowOwner()
      );
    },
    _hideIndicationModal() {
      const owner = this._indicationDialogOwner();
      if (owner && typeof owner.$emit === 'function') {
        owner.$emit('hide-modal');
      }
    }
  }
};
