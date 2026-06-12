import { findAncestorWithAnyKey, findAncestorWithMethod, findAncestorWithRef, getComponentParent } from "@/functions/common/ComponentOwnerResolver";

export default {
  methods: {
    _patEventDetailOwner() {
      return (
        findAncestorWithAnyKey(this, ["computedCreatedDate", "isObserveDetail", "editor"], { includeSelf: true, maxDepth: 16 }) ||
        findAncestorWithRef(this, "tab", { includeSelf: true, maxDepth: 16 }) ||
        getComponentParent(this) ||
        this
      );
    },
    _patEventMainOwner() {
      return (
        findAncestorWithAnyKey(this, ["oldOrdNo", "isHideMainList", "clearActiveRow"], { includeSelf: true, maxDepth: 24 }) ||
        this._patEventDetailOwner()
      );
    },
    _patEventTabComponent() {
      const owner = findAncestorWithRef(this, "tab", { includeSelf: true, maxDepth: 16 }) || this._patEventDetailOwner();
      return owner?.$refs?.tab || null;
    },
    _patEventEditorOwner() {
      return findAncestorWithMethod(this, ["editor"], { includeSelf: true, maxDepth: 16 }) || this._patEventDetailOwner();
    }
  }
};
