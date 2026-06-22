import { findAncestorComponent, findAncestorWithAllKeys, findAncestorWithAnyKey, getComponentParent } from '@/functions/common/ComponentOwnerResolver';
import { getScopedElementById, getScopedElementsByClassName, queryScopedSelector, queryScopedSelectorAll } from '@/functions/common/LayoutMeasureHelper';

export default {
  methods: {
    _deviceSetDialogOwner() {
      return (
        findAncestorComponent(this, vm => vm && vm.messageDialogInfo && (
          'updateDisable' in vm ||
          'settingData' in vm ||
          'styleObj' in vm ||
          'isDialogType9' in vm ||
          'weekEdit' in vm ||
          'isDeviceSetChanged' in vm
        ), { maxDepth: 30 }) ||
        findAncestorWithAllKeys(this, ['messageDialogInfo'], { maxDepth: 30 }) ||
        getComponentParent(this) ||
        this
      );
    },
    _deviceSetRootOwner() {
      return (
        findAncestorWithAnyKey(this, ['ihdfChangeFlag', 'isDialogType9_ihdf', 'isDialogType9_offWater', 'messageDialogInfo'], { maxDepth: 40 }) ||
        this._deviceSetDialogOwner()
      );
    },
    _hideDeviceSetModal() {
      const owner = this._deviceSetDialogOwner();
      if (owner && typeof owner.$emit === 'function') {
        owner.$emit('hide-modal');
      }
    },
    _deviceSetScopeRoot() {
      const dialogOwner = this._deviceSetDialogOwner?.();
      return this.$el || dialogOwner?.$el || this;
    },
    _deviceSetElementById(id) {
      return getScopedElementById(id, this._deviceSetScopeRoot());
    },
    _deviceSetElementsByClassName(className) {
      return getScopedElementsByClassName(className, this._deviceSetScopeRoot());
    },
    _deviceSetFirstElementByClassName(className) {
      return this._deviceSetElementsByClassName(className)[0] || null;
    },
    _deviceSetQuerySelector(selector) {
      return queryScopedSelector(selector, this._deviceSetScopeRoot());
    },
    _deviceSetQuerySelectorAll(selector) {
      return queryScopedSelectorAll(selector, this._deviceSetScopeRoot());
    },
    _deviceSetClosestOrScopedElement(selector) {
      const root = this.$el;
      return root?.closest?.(selector) || queryScopedSelector(selector, this._deviceSetScopeRoot());
    }
  }
};
