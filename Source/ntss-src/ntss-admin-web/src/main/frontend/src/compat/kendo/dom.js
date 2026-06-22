import {
  isElementWithinHost as isCompatElementWithinHost,
  resolveHostElement as resolveCompatHostElement,
  resolveOwnerDocument as resolveCompatOwnerDocument,
} from "@/compat/dom/host";

function asElement(target, depth = 0) {
  if (!target || depth > 8) return null;
  return resolveCompatHostElement(target);
}

const legacyKendoPopupRefs = new WeakMap();

function findPropertyDescriptor(target, propertyName) {
  let current = target;
  while (current && typeof current === 'object') {
    const descriptor = Object.getOwnPropertyDescriptor(current, propertyName);
    if (descriptor) {
      return descriptor;
    }
    current = Object.getPrototypeOf(current);
  }
  return null;
}

function readLegacyProperty(target, propertyName) {
  try {
    return target?.[propertyName];
  } catch (_error) {
    return undefined;
  }
}

function canWriteLegacyProperty(target, propertyName) {
  const descriptor = findPropertyDescriptor(target, propertyName);
  return !descriptor || descriptor.writable === true || typeof descriptor.set === 'function';
}

function safeSetLegacyProperty(target, propertyName, value) {
  if (!target || typeof target !== 'object' || !canWriteLegacyProperty(target, propertyName)) {
    return false;
  }
  try {
    target[propertyName] = value;
    return true;
  } catch (_error) {
    return false;
  }
}

function getWritableLegacyPopupRefs(sender) {
  const popup = readLegacyProperty(sender, 'popup');
  if (popup && typeof popup === 'object') {
    return popup;
  }
  if (!legacyKendoPopupRefs.has(sender)) {
    legacyKendoPopupRefs.set(sender, {});
  }
  const popupRefs = legacyKendoPopupRefs.get(sender);
  safeSetLegacyProperty(sender, 'popup', popupRefs);
  return popupRefs;
}

export function resolveDomElement(target) { return asElement(target); }

function matches(element, selector) {
  if (!element || typeof element.matches !== 'function' || !selector) return false;
  try { return element.matches(selector); } catch (_error) { return false; }
}

function queryOne(root, selector) {
  const safeRoot = asElement(root) || root;
  if (!safeRoot || !selector) return null;
  if (matches(safeRoot, selector)) return safeRoot;
  try { return safeRoot.querySelector?.(selector) || null; } catch (_error) { return null; }
}

function queryAll(root, selector) {
  const safeRoot = asElement(root) || root;
  if (!safeRoot || !selector || typeof safeRoot.querySelectorAll !== 'function') return [];
  try { return Array.from(safeRoot.querySelectorAll(selector)); } catch (_error) { return []; }
}

function first(root, selectors) {
  for (const selector of selectors) {
    const found = queryOne(root, selector);
    if (found) return found;
  }
  return null;
}

function ownerDocumentOf(root) {
  return resolveCompatOwnerDocument(root);
}

export function getKendoOwnerDocument(root = null) {
  return ownerDocumentOf(root);
}

export function getKendoHostElement(target = null, fallback = null) {
  const sender = target?.sender || target;
  return asElement(sender?.wrapper)
    || asElement(sender?.element)
    || asElement(sender?.mountNode?.firstElementChild)
    || asElement(sender?.mountNode)
    || asElement(sender?.popup?.wrapper)
    || asElement(sender?.popup?.element)
    || asElement(fallback)
    || null;
}

export function isElementWithinKendoHost(element, host = null) {
  const safeElement = asElement(element);
  const safeHost = getKendoHostElement(host) || asElement(host);
  if (!safeElement || !safeHost) {
    return false;
  }
  return isCompatElementWithinHost(safeElement, safeHost);
}

function escapeId(id) {
  try { return typeof CSS !== 'undefined' && typeof CSS.escape === 'function' ? CSS.escape(String(id)) : String(id).replace(/"/g, '\\"'); } catch (_error) { return String(id || '').replace(/"/g, '\\"'); }
}

function byIdAll(root, id) {
  if (!id) return [];
  const safeRoot = asElement(root) || root;
  if (!safeRoot) return [];
  const escaped = escapeId(id);
  const literal = String(id).replace(/"/g, '\\"');
  const result = [];
  const push = (candidate) => {
    if (candidate && (!safeRoot.contains || safeRoot.contains(candidate) || safeRoot === candidate || safeRoot.nodeType === 9) && !result.includes(candidate)) {
      result.push(candidate);
    }
  };
  if (typeof safeRoot.getElementById === 'function') {
    push(safeRoot.getElementById(id));
  }
  queryAll(safeRoot, `#${escaped}, [id="${literal}"]`).forEach(push);
  return result;
}

function pickTopmostElement(elements) {
  const connected = elements.filter((element) => element?.ownerDocument?.documentElement?.contains?.(element));
  const candidates = connected.length ? connected : elements.filter(Boolean);
  return candidates[candidates.length - 1] || null;
}

function byId(root, id) {
  return pickTopmostElement(byIdAll(root, id));
}

export function findKendoDropdownRoot(root) { return first(root, ['.k-dropdownlist', '.k-dropdown', '.k-picker']); }
export function findKendoDropdownText(root) { return first(findKendoDropdownRoot(root) || root, ['.k-input-value-text', '.k-input-inner', '.k-input']); }
export function findKendoDropdownButton(root) { return first(findKendoDropdownRoot(root) || root, ['.k-input-button', '.k-select', 'button[aria-label="select"]']); }
export function setKendoActionButtonVisible(root, _visible = true) {
  // 表示制御は Vue2 と同じく利用画面側に委譲し、runtime では対象 button の解決だけを返す。
  return findKendoDropdownButton(root);
}
export function findKendoMultiSelectRoot(root) {
  const wrapper = asElement(root?.wrapper) || asElement(root?.mountNode?.firstElementChild) || asElement(root?.mountNode);
  return first(wrapper || root, ['.k-multiselect']) || wrapper || null;
}
export function findKendoMultiSelectValueArea(root) { return first(findKendoMultiSelectRoot(root) || root, ['.k-input-values', '.k-multiselect-wrap']); }
export function findKendoMultiSelectInput(root) { return first(findKendoMultiSelectRoot(root) || root, ['.k-input-inner', 'input.k-input', '.k-input']); }
export function findKendoMultiSelectChips(root) { return queryAll(findKendoMultiSelectRoot(root) || root, '.k-chip, li.k-button, .k-button'); }
export function findKendoMultiSelectChipLabels(root) { return queryAll(findKendoMultiSelectRoot(root) || root, '.k-chip-label, li.k-button > span[unselectable="on"], .k-button'); }
export function getKendoMultiSelectDomParts(root) {
  const wrapper = findKendoMultiSelectRoot(root);
  const valueArea = findKendoMultiSelectValueArea(wrapper || root);
  return {
    wrapper,
    valueArea,
    chipList: valueArea,
    chips: findKendoMultiSelectChips(wrapper || root),
    chipLabels: findKendoMultiSelectChipLabels(wrapper || root),
    input: findKendoMultiSelectInput(wrapper || root)
  };
}
export function findKendoEditorToolbar(root = null, editorId = null) {
  const scope = asElement(root) || root || (typeof document !== 'undefined' ? document : null);
  if (!editorId) {
    return first(scope, ['.k-editor-toolbar', '[role="toolbar"]']) || null;
  }
  const editorIdText = String(editorId).replace(/"/g, '\\"');
  const selector = `ul[aria-controls="${editorIdText}"], [role="toolbar"][aria-controls="${editorIdText}"]`;
  const scopedToolbar = queryOne(scope, selector);
  if (scopedToolbar) {
    return scopedToolbar;
  }
  const ownerDocument = ownerDocumentOf(scope);
  return queryOne(ownerDocument?.body || ownerDocument, selector);
}

function findKendoEditorToolbarItem(toolbar, commandName) {
  if (!toolbar || !commandName) {
    return null;
  }
  const normalizedCommand = String(commandName).toLowerCase();
  // toolbar.children は HTMLCollection（Array ではない）かつ .k-toolbar-item は
  const toolbarItems = Array.from(toolbar?.children || []).filter(
    (item) => item.classList.contains('k-toolbar-item')
  );
  return toolbarItems.find((item) => {
    const itemCommand = String(item.getAttribute('data-command') || '').toLowerCase();
    return itemCommand === normalizedCommand;
  }) || null;
}

function resolveKendoEditorToolbarClearButtonFromItem(item) {
  if (!item) {
    return null;
  }
  const input = item.querySelector?.('input') || null;
  if (input?.nextElementSibling) {
    return input.nextElementSibling;
  }
  return item.querySelector?.('.k-clear-value, .k-input-clear-value, [aria-label="clear"], [title="clear"]') || null;
}

function resolveKendoEditorToolbarClearButton(toolbar, commandName) {
  const item = findKendoEditorToolbarItem(toolbar, commandName);
  return resolveKendoEditorToolbarClearButtonFromItem(item);
}

export function getKendoEditorToolbarClearButtons(root = null, editorId = null) {
  const toolbar = findKendoEditorToolbar(root, editorId);
  return {
    toolbar,
    fontFamilyClearButton: resolveKendoEditorToolbarClearButton(toolbar, 'fontName'),
    fontSizeClearButton: resolveKendoEditorToolbarClearButton(toolbar, 'fontSize')
  };
}

export function clearKendoEditorControlTitles(container) {
  const root = asElement(container);
  if (!root) {
    return 0;
  }
  const targets = queryAll(root, [
    '.k-editor-toolbar [title]',
    '[role="toolbar"] [title]',
    '.k-textbox[title]',
    '.k-input[title]',
    '.k-input-inner[title]',
    '.k-dropdown[title]',
    '.k-dropdownlist[title]',
    '.k-picker[title]',
    '.k-link[title]',
    '.k-button[title]'
  ].join(','));
  targets.forEach((element) => element.setAttribute('title', ''));
  return targets.length;
}
function findKendoDropDownListBoxElement(root = null, listBoxId = null) {
  const rawListBox = listBoxId ? byId(root, listBoxId) : null;
  if (!rawListBox) {
    return first(root, ['.k-list-ul', '.k-list', '.k-listbox', '[role="listbox"]']);
  }
  return first(rawListBox, ['.k-list-ul', '.k-list', '.k-listbox', '[role="listbox"]']) || rawListBox;
}

function getKendoDropDownListBoxItems(listBox) {
  if (!listBox) {
    return [];
  }
  const directItems = Array.from(listBox.children || []).filter((element) => {
    return matches(element, '.k-item, .k-list-item, li, [role="option"]');
  });
  if (directItems.length > 0) {
    return directItems;
  }
  return queryAll(listBox, '.k-item, .k-list-item, [role="option"]');
}

function applyKendoDropDownListBoxEditedFacade(listBox, enabled, listBoxClass) {
  const targetListBox = findKendoDropDownListBoxElement(listBox) || listBox || null;
  targetListBox?.classList?.toggle?.(listBoxClass, enabled);
  const items = getKendoDropDownListBoxItems(targetListBox);
  items.forEach((item) => {
    if (enabled) {
      if (!item?.classList?.contains?.('k-item') && item?.dataset) {
        item.dataset.kendoDropdownlistLegacyItemClass = 'true';
      }
      item?.classList?.add?.('k-item');
    } else if (item?.dataset?.kendoDropdownlistLegacyItemClass === 'true') {
      item.classList?.remove?.('k-item');
      delete item.dataset.kendoDropdownlistLegacyItemClass;
    }
  });
  return { listBox: targetListBox || null, items };
}

export function setKendoDropDownListEditedState(root = null, options = {}) {
  const scope = asElement(root) || root || (typeof document !== 'undefined' ? document : null);
  const ownerDocument = ownerDocumentOf(scope);
  const selectId = options.selectId || 'kendo-dropdownlist-select-id';
  const listBoxId = options.listBoxId || `${selectId}_listbox`;
  const selectClass = options.selectClass || 'kendo-dropdownlist-select-edited';
  const listBoxClass = options.listBoxClass || 'kendo-dropdownlist-listbox';
  const enabled = options.enabled === true;
  const selectRoot = byId(scope, selectId) || byId(ownerDocument, selectId);
  const listBox = findKendoDropDownListBoxElement(scope, listBoxId)
    || findKendoDropDownListBoxElement(ownerDocument?.body || ownerDocument, listBoxId);
  selectRoot?.classList?.toggle?.(selectClass, enabled);
  if (selectRoot?.dataset) {
    selectRoot.dataset.kendoDropdownlistEditedState = enabled ? 'true' : 'false';
  }
  const applied = applyKendoDropDownListBoxEditedFacade(listBox, enabled, listBoxClass);
  return { selectRoot: selectRoot || null, listBox: applied.listBox, items: applied.items };
}

export function syncKendoDropDownListEditedStateFromWidget(senderOrWidget, fallbackRoot = null, options = {}) {
  const sender = senderOrWidget?.sender || senderOrWidget;
  const defaultSelectId = options.selectId || 'kendo-dropdownlist-select-id';
  const selectClass = options.selectClass || 'kendo-dropdownlist-select-edited';
  const listBoxClass = options.listBoxClass || 'kendo-dropdownlist-listbox';
  const widgetRoot = asElement(sender?.element)
    || asElement(sender?.wrapper)
    || asElement(sender?.mountNode?.firstElementChild)
    || asElement(sender?.mountNode)
    || asElement(fallbackRoot)
    || null;
  const ownerDocument = ownerDocumentOf(widgetRoot || fallbackRoot);
  const selectRoot = byId(widgetRoot, defaultSelectId)
    || byId(fallbackRoot, defaultSelectId)
    || first(widgetRoot, ['.kendo-dropdownlist-select-edited', '[data-kendo-dropdownlist-edited-state]'])
    || byId(ownerDocument, defaultSelectId);
  const enabled = options.enabled !== undefined
    ? options.enabled === true
    : (selectRoot?.dataset?.kendoDropdownlistEditedState === 'true' || selectRoot?.classList?.contains?.(selectClass) || false);
  const listBoxId = options.listBoxId || getKendoPopupListBoxId(sender) || (selectRoot?.id ? `${selectRoot.id}_listbox` : null);
  const popupRoot = getKendoPopupRoot(sender, fallbackRoot) || ownerDocument?.body || widgetRoot;
  const listBox = findKendoDropDownListBoxElement(popupRoot, listBoxId)
    || findKendoDropDownListBoxElement(ownerDocument?.body || ownerDocument, listBoxId);
  const applied = applyKendoDropDownListBoxEditedFacade(listBox, enabled, listBoxClass);
  return { selectRoot: selectRoot || null, listBox: applied.listBox, items: applied.items, enabled };
}

function popupSearchRoots(root, includePortalRoot = false) {
  const safeRoot = asElement(root) || root;
  const ownerDocument = ownerDocumentOf(safeRoot);
  const roots = [];
  const push = (candidate) => { if (candidate && !roots.includes(candidate)) roots.push(candidate); };

  // Vue2 の popup/listbox は widget owner と listbox id の対応で閉じていたため、
  // runtime はまず現在 widget の宿主近傍を検索し、body portal は listbox id がある場合だけ見る。
  push(safeRoot);
  push(getKendoHostElement(root));
  push(safeRoot?.parentElement);
  push(safeRoot?.closest?.('.k-animation-container, .k-popup, .k-list-container, .k-widget'));

  if (includePortalRoot && ownerDocument?.body) {
    push(ownerDocument.body);
    push(ownerDocument);
  }

  // root 未指定の共通 close/find 呼び出しだけは呼び出し側が全体検索を意図したものとして扱う。
  if (!safeRoot) {
    const defaultDocument = ownerDocumentOf(root);
    push(defaultDocument?.body || null);
    push(defaultDocument || null);
  }
  return roots.filter(Boolean);
}

export function findKendoPopup(root = null, listBoxId = null) {
  const roots = popupSearchRoots(root, !!listBoxId);
  let listBox = null;
  if (listBoxId) {
    const matches = [];
    roots.forEach((candidate) => byIdAll(candidate, listBoxId).forEach((element) => {
      if (!matches.includes(element)) matches.push(element);
    }));
    listBox = pickTopmostElement(matches);
  }
  if (!listBox) {
    const candidates = [];
    roots.forEach((candidate) => {
      queryAll(candidate, '.k-list-ul, .k-list, .k-listbox, [role="listbox"]').forEach((element) => {
        if (!candidates.includes(element)) candidates.push(element);
      });
      const direct = first(candidate, ['.k-list-ul', '.k-list', '.k-listbox', '[role="listbox"]']);
      if (direct && !candidates.includes(direct)) candidates.push(direct);
    });
    listBox = pickTopmostElement(candidates);
  }
  if (!listBox) return null;
  const popupSurface = listBox.closest?.('.k-popup, .k-list-container');
  return popupSurface?.closest?.('.k-animation-container')
    || listBox.closest?.('.k-animation-container')
    || popupSurface
    || listBox.parentElement
    || listBox;
}
export function findKendoPopupSurface(root = null, listBoxId = null) { const popup = findKendoPopup(root, listBoxId); return first(popup, ['.k-popup', '.k-list-container', '.k-list', '.k-list-ul']) || popup; }
export function findFirstKendoPopup(root = null) { return findAllKendoPopups(root)[0] || null; }
export function findFirstKendoPopupSurface(root = null) { const popup = findFirstKendoPopup(root); return popup ? (findKendoPopupSurface(popup) || popup) : null; }
export function findKendoPopupScroller(root = null, listBoxId = null) { return first(findKendoPopup(root, listBoxId) || root, ['.k-list-scroller', '.k-list-content', '.k-virtual-content', '.k-list-ul', '.k-list']); }
export function findKendoPopupItems(root = null, listBoxId = null) { return queryAll(findKendoPopup(root, listBoxId) || root, '.k-list-item, .k-item, [role="option"]'); }
export function getKendoPopupListBoxId(senderOrWidget, fallback = null) {
  const sender = senderOrWidget?.sender || senderOrWidget;
  const wrapper = asElement(sender?.wrapper) || asElement(sender?.mountNode?.firstElementChild) || asElement(sender?.mountNode) || asElement(sender?.element) || null;
  const controlled = first(wrapper, ['[aria-controls]', '[aria-owns]', '[role="combobox"]']);
  return sender?.listBoxId
    || sender?.list?.attr?.('id')
    || sender?.ul?.attr?.('id')
    || controlled?.getAttribute?.('aria-controls')
    || controlled?.getAttribute?.('aria-owns')
    || fallback;
}

export function getKendoPopupRoot(senderOrWidget, fallbackRoot = null) {
  const sender = senderOrWidget?.sender || senderOrWidget;
  const popupElement = asElement(sender?.popup?.element)
    || asElement(sender?.popup?.wrapper)
    || null;
  if (popupElement) {
    return popupElement;
  }
  const listBoxId = getKendoPopupListBoxId(sender);
  const widgetRoot = getKendoHostElement(sender, fallbackRoot);
  const ownerDocument = ownerDocumentOf(widgetRoot || fallbackRoot);
  const searchRoots = [widgetRoot?.parentElement, widgetRoot, fallbackRoot, ownerDocument?.body, ownerDocument].filter(Boolean);
  for (const searchRoot of searchRoots) {
    const popupRoot = findKendoPopup(searchRoot, listBoxId);
    if (popupRoot) {
      return popupRoot;
    }
  }
  return null;
}

export function getKendoPopupSurface(senderOrWidget, fallbackRoot = null) {
  const popupRoot = getKendoPopupRoot(senderOrWidget, fallbackRoot);
  const listBoxId = getKendoPopupListBoxId(senderOrWidget);
  return findKendoPopupSurface(popupRoot, listBoxId)
    || popupRoot?.firstElementChild
    || popupRoot
    || null;
}

export function getKendoPopupScroller(senderOrWidget, fallbackRoot = null) {
  const popupRoot = getKendoPopupRoot(senderOrWidget, fallbackRoot);
  const listBoxId = getKendoPopupListBoxId(senderOrWidget);
  return findKendoPopupScroller(popupRoot, listBoxId);
}

function asLegacyElementCollection(element) {
  const collection = [];
  if (element) {
    collection.push(element);
  }
  collection.jquery = true;
  collection.get = (index = 0) => collection[index] || null;
  collection.attr = (name, value) => {
    const target = collection[0];
    if (!target) return value === undefined ? undefined : collection;
    if (value === undefined) return target.getAttribute?.(name);
    target.setAttribute?.(name, value);
    return collection;
  };
  collection.css = (name, value) => {
    const target = collection[0];
    if (!target?.style) return value === undefined ? undefined : collection;
    if (value === undefined) return target.style[name];
    target.style[name] = value;
    return collection;
  };
  collection.find = (selector) => asLegacyElementCollection(collection[0]?.querySelector?.(selector) || null);
  return collection;
}

export function syncKendoPopupWidgetRefs(senderOrWidget, fallbackRoot = null) {
  const sender = senderOrWidget?.sender || senderOrWidget;
  if (!sender || typeof sender !== 'object') {
    return null;
  }
  const popupRoot = getKendoPopupRoot(sender, fallbackRoot);
  const popupSurface = getKendoPopupSurface(sender, fallbackRoot) || popupRoot;
  const popupRefs = getWritableLegacyPopupRefs(sender);
  if (popupRoot) {
    popupRefs.wrapper = popupRefs.wrapper?.jquery ? popupRefs.wrapper : asLegacyElementCollection(popupRoot);
    popupRefs.element = popupRefs.element?.jquery ? popupRefs.element : asLegacyElementCollection(popupSurface || popupRoot);
  }
  const listBoxId = getKendoPopupListBoxId(sender);
  if (listBoxId !== undefined && listBoxId !== null) {
    safeSetLegacyProperty(sender, 'listBoxId', listBoxId);
  }
  return popupRoot || null;
}

export function setKendoPopupSurfaceWidth(senderOrWidget, width, fallbackRoot = null) {
  const popupSurface = getKendoPopupSurface(senderOrWidget, fallbackRoot);
  if (popupSurface?.style) {
    popupSurface.style.width = width;
  }
  return popupSurface;
}

export function setKendoPopupSurfaceStyles(senderOrWidget, styles = {}, fallbackRoot = null) {
  const popupSurface = getKendoPopupSurface(senderOrWidget, fallbackRoot);
  if (popupSurface?.style && styles && typeof styles === 'object') {
    Object.entries(styles).forEach(([name, value]) => {
      if (value !== undefined && value !== null) {
        popupSurface.style[name] = value;
      }
    });
  }
  return popupSurface;
}

export function setKendoPopupHeight(senderOrWidget, height, fallbackRoot = null) {
  const popupRoot = getKendoPopupRoot(senderOrWidget, fallbackRoot);
  const popupScroller = getKendoPopupScroller(senderOrWidget, fallbackRoot);
  if (popupRoot?.style) {
    popupRoot.style.height = height;
  }
  if (popupScroller?.style) {
    popupScroller.style.height = height;
  }
  return { popupRoot: popupRoot || null, popupScroller: popupScroller || null };
}

export function findAllKendoPopups(root = null) {
  const scope = asElement(root) || root || (typeof document !== 'undefined' ? document : null);
  if (!scope) {
    return [];
  }
  const selector = '.k-animation-container, .k-popup, .k-list-container';
  const candidates = [];
  if (matches(scope, selector)) {
    candidates.push(scope);
  }
  queryAll(scope, selector).forEach((element) => {
    if (!candidates.includes(element)) {
      candidates.push(element);
    }
  });
  // body portal 上で popup が親子に重なる場合は、DOM 後方の現在層を優先する。
  return candidates.reverse();
}

export function getKendoEditorOwnerDocument(editor = null, event = null, fallbackRoot = null) {
  const sender = editor?.sender || editor;
  return event?.currentTarget?.document
    || event?.target?.ownerDocument
    || sender?.window?.document
    || sender?.document
    || sender?.body?.ownerDocument
    || ownerDocumentOf(sender?.body || sender?.wrapper || sender?.element || sender?.mountNode || fallbackRoot)
    || null;
}

export function getKendoEditorDocumentElement(editor = null, event = null, fallbackRoot = null) {
  return getKendoEditorOwnerDocument(editor, event, fallbackRoot)?.documentElement || null;
}

export function getKendoEditorBody(editor = null, event = null, fallbackRoot = null) {
  const sender = editor?.sender || editor;
  const ownerDocument = getKendoEditorOwnerDocument(sender, event, fallbackRoot);
  return ownerDocument?.body || sender?.body || ownerDocument?.documentElement || null;
}

export function createKendoEditorRange(editor = null, event = null, fallbackRoot = null) {
  const ownerDocument = getKendoEditorOwnerDocument(editor, event, fallbackRoot);
  if (typeof ownerDocument?.createRange === 'function') {
    return ownerDocument.createRange();
  }
  if (typeof editor?.createRange === 'function') {
    return editor.createRange();
  }
  return null;
}

export function createKendoEditorElement(tagName, editor = null, event = null, fallbackRoot = null) {
  const ownerDocument = getKendoEditorOwnerDocument(editor, event, fallbackRoot);
  return tagName && typeof ownerDocument?.createElement === 'function'
    ? ownerDocument.createElement(tagName)
    : null;
}

export function findKendoEditorWrapper(root) { return first(root || (typeof document !== 'undefined' ? document : null), ['.k-editor']); }

function isWithinScope(element, scope) {
  if (!element) {
    return false;
  }
  const safeScope = asElement(scope);
  return !safeScope || safeScope === element || safeScope.contains?.(element) || element.contains?.(safeScope);
}

function findKendoEditorFromControlledTarget(element, scope = null) {
  const safeElement = asElement(element);
  if (!safeElement) {
    return null;
  }
  const ownerDocument = ownerDocumentOf(safeElement);
  const safeScope = asElement(scope);
  const controlledBy = safeElement.closest?.('[aria-controls], [aria-owns], [data-editor-id]') || null;
  const controlledId = controlledBy?.getAttribute?.('aria-controls')
    || controlledBy?.getAttribute?.('aria-owns')
    || controlledBy?.getAttribute?.('data-editor-id')
    || null;
  const roots = [safeScope, safeElement.closest?.('.k-editor'), ownerDocument?.body, ownerDocument].filter(Boolean);
  if (controlledId) {
    for (const candidateRoot of roots) {
      const controlled = byId(candidateRoot, controlledId);
      const editor = controlled?.closest?.('.k-editor') || null;
      if (editor) {
        return editor;
      }
    }
  }
  const popup = safeElement.closest?.('.k-animation-container, .k-popup, .k-list-container') || null;
  const popupListBox = first(popup, ['[role="listbox"]', '.k-list-ul', '.k-listbox', '.k-list']) || popup;
  const popupId = popupListBox?.id || popupListBox?.getAttribute?.('aria-controls') || null;
  if (popupId) {
    const escapedPopupId = escapeId(popupId);
    for (const candidateRoot of roots) {
      const controller = queryOne(candidateRoot, `[aria-controls="${escapedPopupId}"], [aria-owns="${escapedPopupId}"]`);
      const editor = controller?.closest?.('.k-editor') || null;
      if (editor) {
        return editor;
      }
    }
  }
  return null;
}

export function isInsideKendoEditor(target, root = null) {
  const element = asElement(target);
  if (!element) {
    return false;
  }
  const safeRoot = asElement(root);
  const doc = element.ownerDocument;
  const frameElement = doc?.defaultView?.frameElement;

  let iframeEditor = null;
  if (frameElement) {
    iframeEditor = frameElement.closest?.('.k-editor') || null;
    if(iframeEditor && isWithinScope(frameElement, safeRoot || iframeEditor)){
      return true
    }
  }
  const directEditor = element.closest?.('.k-editor') || null;
  if (directEditor && isWithinScope(element, safeRoot || directEditor)) {
    return true;
  }
  const editorToolbar = element.closest?.('.k-editor-toolbar, [role="toolbar"][aria-controls], ul[aria-controls]') || null;
  if (editorToolbar && isWithinScope(editorToolbar, safeRoot || editorToolbar)) {
    return true;
  }
  const controlledEditor = findKendoEditorFromControlledTarget(element, safeRoot);
  if (controlledEditor && isWithinScope(controlledEditor, safeRoot || controlledEditor)) {
    return true;
  }
  return false;
}

export function isInsideKendoEditorInteraction(target, root = null) {
  const element = asElement(target);
  if (!element) {
    return false;
  }
  if (isInsideKendoEditor(element, root)) {
    return true;
  }
  const safeRoot = asElement(root);
  const legacyGlobalTarget = element.closest?.('.k-state-selected, .popover__content') || null;
  if (legacyGlobalTarget && isWithinScope(legacyGlobalTarget, safeRoot || legacyGlobalTarget)) {
    return true;
  }
  const legacyPopupTarget = element.closest?.('.k-list-item, .k-item, .k-animation-container, .k-popup, .k-list-container') || null;
  if (!legacyPopupTarget) {
    return false;
  }
  const relatedEditor = findKendoEditorFromControlledTarget(legacyPopupTarget, safeRoot);
  if (relatedEditor && isWithinScope(relatedEditor, safeRoot || relatedEditor)) {
    return true;
  }
  return isInsideKendoEditor(legacyPopupTarget, safeRoot);
}

export function findKendoGridRoot(root) { return first(root, ['.k-grid']); }
export function findKendoGridContent(root) { return first(findKendoGridRoot(root) || root, ['.k-grid-content']); }
export function findKendoGridLockedContent(root) { return first(findKendoGridRoot(root) || root, ['.k-grid-content-locked']); }
export function findKendoGridHeader(root) { return first(findKendoGridRoot(root) || root, ['.k-grid-header']); }
export function findKendoGridHeaderWrap(root) { return first(findKendoGridRoot(root) || root, ['.k-grid-header-wrap']); }
export function findKendoGridHeaderScrollHost(root) { return first(findKendoGridHeader(root) || findKendoGridRoot(root) || root, ['.k-grid-header-wrap.k-auto-scrollable', '.k-grid-header-wrap']); }
export function findKendoGridLockedHeader(root) { return first(findKendoGridRoot(root) || root, ['.k-grid-header-locked']); }
export function findKendoGridScrollHost(root) { return first(findKendoGridRoot(root) || root, ['.k-virtual-scrollable-wrap', '.k-grid-content.k-auto-scrollable', '.k-grid-content']); }
export function findKendoGridAutoScrollable(root) { return findKendoGridScrollHost(root) || findKendoGridContent(root); }
export function findKendoGridTable(root) { return first(findKendoGridRoot(root) || root, ['.k-grid-content table', '.k-grid table']); }
export function findKendoGridLockedTable(root) { return first(findKendoGridRoot(root) || root, ['.k-grid-content-locked table']); }
export function findKendoGridHeaderTable(root) { return first(findKendoGridRoot(root) || root, ['.k-grid-header table', '.k-grid-header-wrap table', '.k-grid table']); }
export function findKendoGridBodyTable(root) { return first(findKendoGridRoot(root) || root, ['.k-grid-content table', '.k-grid-container .k-grid-table', '.k-grid table']); }
export function findKendoGridColElements(root) { return queryAll(root, 'colgroup col'); }
export function findKendoGridHeaderColElements(root) {
  const table = findKendoGridHeaderTable(root);
  return findKendoGridColElements(table);
}
export function findKendoGridBodyColElements(root) {
  const table = findKendoGridBodyTable(root);
  return findKendoGridColElements(table);
}
export function findKendoGridThead(root) { return first(findKendoGridRoot(root) || root, ['.k-grid-header thead', '.k-grid-header-wrap thead', '.k-grid thead']); }
export function findKendoGridTbody(root) { return first(findKendoGridRoot(root) || root, ['.k-grid-content tbody', '.k-grid tbody']); }
export function findKendoGridLockedTbody(root) { return first(findKendoGridRoot(root) || root, ['.k-grid-content-locked tbody']); }
function normalizeGridRows(rows) {
  const seen = new Set();
  return (rows || []).filter((row) => {
    if (!row || row.tagName !== 'TR' || seen.has(row)) {
      return false;
    }
    seen.add(row);
    return true;
  });
}

function isInKendoGridLockedContent(row) {
  return Boolean(row?.closest?.('.k-grid-content-locked'));
}

function isInKendoGridBodyContent(row) {
  return !isInKendoGridLockedContent(row);
}

export function findKendoGridBodyRows(root) {
  const gridRoot = findKendoGridRoot(root) || root;
  const tbody = findKendoGridTbody(gridRoot);
  const rows = tbody ? Array.from(tbody.children) : [];
  if (rows.length > 0) {
    return normalizeGridRows(rows.filter(isInKendoGridBodyContent));
  }
  const kendo2026Rows = queryAll(gridRoot, [
    '.k-grid-content tbody > tr',
    '.k-grid-container .k-grid-table tbody > tr',
    '.k-grid-content .k-table-row',
    '.k-grid-content tr.k-master-row'
  ].join(','));
  return normalizeGridRows([...rows, ...kendo2026Rows].filter(isInKendoGridBodyContent));
}

export function findKendoGridLockedRows(root) {
  const gridRoot = findKendoGridRoot(root) || root;
  const tbody = findKendoGridLockedTbody(gridRoot);
  const rows = tbody ? Array.from(tbody.children) : [];
  if (rows.length > 0) {
    return normalizeGridRows(rows.filter(isInKendoGridLockedContent));
  }
  const kendo2026Rows = queryAll(gridRoot, [
    '.k-grid-content-locked tbody > tr',
    '.k-grid-content-locked .k-table-row',
    '.k-grid-content-locked tr.k-master-row'
  ].join(','));
  return normalizeGridRows([...rows, ...kendo2026Rows].filter(isInKendoGridLockedContent));
}

export function findKendoGridLogicalTable(root) {
  const gridRoot = findKendoGridRoot(root) || root;
  const bodyRows = findKendoGridBodyRows(gridRoot);
  const lockedRows = findKendoGridLockedRows(gridRoot);
  const rowCount = Math.max(bodyRows.length, lockedRows.length);
  const rows = [];
  for (let index = 0; index < rowCount; index += 1) {
    const bodyRow = bodyRows[index] || null;
    const lockedRow = lockedRows[index] || null;
    rows.push({
      index,
      bodyRow,
      lockedRow,
      elements: [lockedRow, bodyRow].filter(Boolean)
    });
  }
  return {
    root: gridRoot,
    bodyRows,
    lockedRows,
    rows,
    hasLockedRows: lockedRows.length > 0
  };
}
export function findKendoGridHeaderCells(root) {
  const header = findKendoGridHeader(root) || findKendoGridRoot(root) || root;
  return queryAll(header, 'th[role="columnheader"], th.k-header, th.k-table-th');
}
export function findKendoGridHeaderCellByField(root, field) {
  if (field == null || field === '') {
    return null;
  }
  const targetField = String(field);
  return findKendoGridHeaderCells(root).find((cell) => cell?.getAttribute?.('data-field') === targetField) || null;
}
export function getKendoGridColumnField(senderOrRoot, index, fallback = null) {
  const sender = senderOrRoot?.sender || senderOrRoot;
  const safeIndex = Number(index);
  if (!Number.isInteger(safeIndex) || safeIndex < 0) {
    return fallback;
  }
  const columnField = sender?.columns?.[safeIndex]?.field;
  if (columnField != null && columnField !== '') {
    return columnField;
  }
  const headerCell = findKendoGridHeaderCells(senderOrRoot)[safeIndex] || null;
  return headerCell?.getAttribute?.('data-field') || fallback;
}

export function getKendoGridColumnDomParts(root, options = {}) {
  const index = Number.isInteger(options?.index) ? options.index : -1;
  const headerTable = findKendoGridHeaderTable(root);
  const bodyTable = findKendoGridBodyTable(root);
  const headerCols = findKendoGridHeaderColElements(root);
  const bodyCols = findKendoGridBodyColElements(root);
  const headerCell = options?.field != null
    ? findKendoGridHeaderCellByField(root, options.field)
    : (index >= 0 ? findKendoGridHeaderCells(root)[index] || null : null);
  return {
    headerTable,
    bodyTable,
    headerCell,
    headerCol: index >= 0 ? headerCols[index] || null : null,
    bodyCol: index >= 0 ? bodyCols[index] || null : null,
    headerCols,
    bodyCols
  };
}
export function findKendoGridMasterRows(root) {
  const gridRoot = findKendoGridRoot(root) || root;
  const rows = queryAll(gridRoot, [
    '.k-grid-container .k-grid-table tr.k-master-row',
    '.k-grid-content table tr.k-master-row',
    '.k-grid-content tr.k-master-row',
    '.k-grid-content .k-table-row',
    '.k-grid-container .k-grid-table tbody > tr'
  ].join(','));
  return rows.length > 0 ? normalizeGridRows(rows) : findKendoGridBodyRows(gridRoot);
}
export function findKendoGridRowCells(row) {
  return queryAll(row, 'td');
}
export function resolveKendoGridSelectionElement(senderOrRoot) {
  const sender = senderOrRoot?.sender || senderOrRoot;
  try {
    return asElement(sender?.select?.()) || null;
  } catch (_error) {
    return null;
  }
}
export function isKendoGridSelectionInLockedContent(senderOrRoot) {
  const selected = resolveKendoGridSelectionElement(senderOrRoot);
  const lockedContent = findKendoGridLockedContent(senderOrRoot);
  return !!(selected && lockedContent && (lockedContent === selected || lockedContent.contains?.(selected)));
}
export function findKendoGridSelectedRow(senderOrRoot) {
  return resolveKendoGridSelectionElement(senderOrRoot)?.closest?.('tr') || null;
}
export function getKendoGridSelectedRowIndex(senderOrRoot, options = {}) {
  const selectedRow = findKendoGridSelectedRow(senderOrRoot);
  if (!selectedRow) {
    return -1;
  }
  if (options?.locked === true) {
    return findKendoGridLockedRows(senderOrRoot).indexOf(selectedRow);
  }
  const bodyIndex = findKendoGridBodyRows(senderOrRoot).indexOf(selectedRow);
  if (bodyIndex >= 0) {
    return bodyIndex;
  }
  return findKendoGridLockedRows(senderOrRoot).indexOf(selectedRow);
}

function asArrayLikeElements(value) {
  if (!value) {
    return [];
  }
  if (Array.isArray(value)) {
    return value.map((item) => asElement(item)).filter(Boolean);
  }
  if (value.jquery || (typeof value.get === 'function' && typeof value.length === 'number')) {
    const result = [];
    for (let index = 0; index < value.length; index += 1) {
      const element = asElement(value[index] || value.get?.(index));
      if (element) {
        result.push(element);
      }
    }
    return result;
  }
  if (typeof value.length === 'number' && typeof value !== 'string' && !value.nodeType) {
    return Array.from(value).map((item) => asElement(item)).filter(Boolean);
  }
  const element = asElement(value);
  return element ? [element] : [];
}


export function getKendoWidgetElement(senderOrWidget) {
  const sender = senderOrWidget?.sender || senderOrWidget;
  return asElement(sender?.element) || asElement(sender?.input) || asElement(sender?.wrapper) || asElement(sender);
}

export function getKendoWidgetElementId(senderOrWidget, fallback = null) {
  return getKendoWidgetElement(senderOrWidget)?.id || fallback;
}
export function getKendoWidgetSelectedIndex(senderOrWidget, fallback = -1) {
  const sender = senderOrWidget?.sender || senderOrWidget;
  const rawIndex = typeof sender?.selectedIndex === 'function'
    ? sender.selectedIndex()
    : sender?.selectedIndex;
  const index = Number(rawIndex);
  return Number.isInteger(index) ? index : fallback;
}

export function getKendoWidgetValue(senderOrWidget, fallback = undefined) {
  const sender = senderOrWidget?.sender || senderOrWidget;
  try {
    if (typeof sender?.value === 'function') {
      return sender.value();
    }
  } catch (_error) {
    // noop
  }
  return sender?.value ?? sender?._value ?? sender?._old ?? fallback;
}

export function setKendoWidgetValue(senderOrWidget, nextValue) {
  const sender = senderOrWidget?.sender || senderOrWidget;
  try {
    if (typeof sender?.value === 'function') {
      return sender.value(nextValue);
    }
  } catch (_error) {
    // noop
  }
  if (sender && 'value' in sender) {
    sender.value = nextValue;
  }
  return nextValue;
}

export function getKendoWidgetDataItems(senderOrWidget) {
  const sender = senderOrWidget?.sender || senderOrWidget;
  const sources = [
    () => sender?.dataSource?.view?.(),
    () => sender?.dataSource?.data?.(),
    () => sender?.dataSource?.options?.data,
    () => sender?.options?.dataSource,
    () => sender?.dataItems?.(),
  ];
  for (const resolveSource of sources) {
    try {
      const source = resolveSource();
      const values = source ? Array.from(source) : [];
      if (values.length > 0) {
        return values;
      }
    } catch (_error) {
      // noop
    }
  }
  return [];
}

export function getKendoWidgetDataAt(senderOrWidget, index) {
  const sender = senderOrWidget?.sender || senderOrWidget;
  const safeIndex = Number(index);
  if (!Number.isInteger(safeIndex) || safeIndex < 0) {
    return null;
  }
  const values = getKendoWidgetDataItems(sender);
  if (values[safeIndex]) {
    return values[safeIndex];
  }
  try {
    const item = typeof sender?.dataItem === 'function' ? sender.dataItem(safeIndex) : null;
    if (item) {
      return item;
    }
  } catch (_error) {
    // noop
  }
  return null;
}

export function getKendoWidgetSelectedDataItem(senderOrWidget) {
  return getKendoWidgetDataAt(senderOrWidget, getKendoWidgetSelectedIndex(senderOrWidget));
}

export function getKendoGridWrapperElement(senderOrRoot) {
  const sender = senderOrRoot?.sender || senderOrRoot;
  return asElement(sender?.wrapper) || findKendoGridRoot(senderOrRoot) || asElement(senderOrRoot) || null;
}

export function getKendoGridItems(senderOrRoot) {
  const sender = senderOrRoot?.sender || senderOrRoot;
  try {
    const items = sender?.items?.();
    const normalized = asArrayLikeElements(items);
    if (normalized.length > 0) {
      return normalized;
    }
  } catch (_error) {
    // noop
  }
  return findKendoGridBodyRows(senderOrRoot);
}

export function getKendoGridDataItems(senderOrRoot) {
  const sender = senderOrRoot?.sender || senderOrRoot;
  try {
    const items = sender?.dataItems?.();
    if (items) {
      return Array.from(items);
    }
  } catch (_error) {
    // noop
  }
  try {
    const view = sender?.view?.();
    if (view) {
      return Array.from(view);
    }
  } catch (_error) {
    // noop
  }
  try {
    const data = sender?.data?.();
    if (data) {
      return Array.from(data);
    }
  } catch (_error) {
    // noop
  }
  try {
    const view = sender?.dataSource?.view?.();
    if (view) {
      return Array.from(view);
    }
  } catch (_error) {
    // noop
  }
  try {
    const data = sender?.dataSource?.data?.();
    if (data) {
      return Array.from(data);
    }
  } catch (_error) {
    // noop
  }
  return [];
}


export function setKendoGridDataItems(senderOrRoot, nextData) {
  const sender = senderOrRoot?.sender || senderOrRoot;
  try {
    if (typeof sender?.data === 'function') {
      return sender.data(nextData);
    }
  } catch (_error) {
    // noop
  }
  try {
    if (typeof sender?.dataSource?.data === 'function') {
      return sender.dataSource.data(nextData);
    }
  } catch (_error) {
    // noop
  }
  try {
    if (sender?.dataSource?.options) {
      sender.dataSource.options.data = nextData;
    }
  } catch (_error) {
    // noop
  }
  return nextData;
}

export function findKendoGridRowByUid(senderOrRoot, uid) {
  if (uid == null || uid === '') {
    return null;
  }
  const root = getKendoGridWrapperElement(senderOrRoot) || findKendoGridRoot(senderOrRoot) || senderOrRoot;
  const escaped = String(uid).replace(/"/g, '\\"');
  return queryOne(root, `tr[data-uid="${escaped}"]`);
}

export function findAllKendoGridRowByUid(senderOrRoot, uid) {
  if (uid == null || uid === '') {
    return null;
  }
  const root = getKendoGridWrapperElement(senderOrRoot) || findKendoGridRoot(senderOrRoot) || senderOrRoot;
  const escaped = String(uid).replace(/"/g, '\\"');
  return queryAll(root, `tr[data-uid="${escaped}"]`);
}

export function getKendoGridDataSourceItem(senderOrRoot, index) {
  const sender = senderOrRoot?.sender || senderOrRoot;
  const safeIndex = Number(index);
  if (!Number.isInteger(safeIndex) || safeIndex < 0) {
    return null;
  }
  try {
    const item = sender?.dataSource?.at?.(safeIndex);
    if (item) {
      return item;
    }
  } catch (_error) {
    // noop
  }
  const items = getKendoGridDataItems(sender);
  return items[safeIndex] || null;
}

export function findKendoGridRowByDataItem(senderOrRoot, dataItemOrUid) {
  const uid = dataItemOrUid?.uid ?? dataItemOrUid?._uid ?? dataItemOrUid;
  return findKendoGridRowByUid(senderOrRoot, uid);
}

export function findKendoGridRowCellsByUid(senderOrRoot, uid) {
  const row = findKendoGridRowByUid(senderOrRoot, uid);
  return row ? findKendoGridRowCells(row) : [];
}

export function findKendoGridRowCellsByDataItem(senderOrRoot, dataItemOrUid) {
  const row = findKendoGridRowByDataItem(senderOrRoot, dataItemOrUid);
  return row ? findKendoGridRowCells(row) : [];
}

export function findKendoGridCellByDataItemField(senderOrRoot, dataItemOrUid, field) {
  if (!field) {
    return null;
  }
  const row = findKendoGridRowByDataItem(senderOrRoot, dataItemOrUid);
  if (!row) {
    return null;
  }
  const escapedField = String(field).replace(/"/g, '\\"');
  return queryOne(row, `td[data-field="${escapedField}"], th[data-field="${escapedField}"]`);
}

export function asKendoJQueryElement(element) {
  const resolved = asElement(element);
  if (!resolved) {
    return null;
  }
  const jq = globalThis?.jQuery || globalThis?.$;
  if (typeof jq === 'function') {
    try {
      return jq(resolved);
    } catch (_error) {
      // noop
    }
  }
  return resolved;
}
export function getKendoGridDataItem(senderOrRoot, rowOrElement = null) {
  const sender = senderOrRoot?.sender || senderOrRoot;
  const row = asElement(rowOrElement)?.closest?.('tr') || asElement(rowOrElement);
  if (row?.__ntssKendoDataItem) {
    return row.__ntssKendoDataItem;
  }
  if (sender && typeof sender.dataItem === 'function' && row) {
    try {
      const item = sender.dataItem(row);
      if (item) {
        return item;
      }
    } catch (_error) {
      // noop
    }
    try {
      const item = sender.dataItem(rowOrElement);
      if (item) {
        return item;
      }
    } catch (_error) {
      // noop
    }
  }
  const uid = row?.getAttribute?.('data-uid') || rowOrElement?.attr?.('data-uid') || null;
  if (uid && sender?.dataSource) {
    try {
      const byUid = sender.dataSource.getByUid?.(uid);
      if (byUid) {
        return byUid;
      }
    } catch (_error) {
      // noop
    }
    try {
      const view = sender.dataSource.view?.() || [];
      const found = Array.from(view).find((item) => String(item?.uid || item?._uid || '') === String(uid));
      if (found) {
        return found;
      }
    } catch (_error) {
      // noop
    }
  }
  if (row) {
    const bodyRows = findKendoGridBodyRows(senderOrRoot);
    const bodyIndex = bodyRows.indexOf(row);
    if (bodyIndex >= 0) {
      return getKendoGridDataSourceItem(sender, bodyIndex);
    }
    const lockedRows = findKendoGridLockedRows(senderOrRoot);
    const lockedIndex = lockedRows.indexOf(row);
    if (lockedIndex >= 0) {
      return getKendoGridDataSourceItem(sender, lockedIndex);
    }
  }
  return null;
}

export function getKendoEventContainerElement(eventOrContainer) {
  const container = eventOrContainer?.container || eventOrContainer;
  return asElement(container) || asElement(container?.[0]) || null;
}
export function getKendoGridSelectedElement(senderOrRoot) {
  const sender = senderOrRoot?.sender || senderOrRoot;
  try {
    return asElement(sender?.select?.()) || null;
  } catch (_error) {
    return null;
  }
}

export function getKendoGridSelectedRow(senderOrRoot) {
  return getKendoGridSelectedElement(senderOrRoot)?.closest?.('tr') || null;
}

export function getKendoGridSelectedCell(senderOrRoot) {
  const selected = getKendoGridSelectedElement(senderOrRoot);
  return selected?.matches?.('td,th') ? selected : selected?.closest?.('td,th') || null;
}

export function getKendoGridSelectedDataItem(senderOrRoot) {
  const row = getKendoGridSelectedRow(senderOrRoot);
  return row ? getKendoGridDataItem(senderOrRoot, row) : null;
}

export function getKendoGridCellIndex(senderOrRoot, cellOrElement = null) {
  const sender = senderOrRoot?.sender || senderOrRoot;
  const cell = asElement(cellOrElement)?.closest?.('td,th') || asElement(cellOrElement);
  if (!cell) {
    return -1;
  }
  if (sender && typeof sender.cellIndex === 'function') {
    try {
      const index = sender.cellIndex(cell);
      if (Number.isFinite(index)) {
        return index;
      }
    } catch (_error) {
      // noop
    }
    try {
      const index = sender.cellIndex(cellOrElement);
      if (Number.isFinite(index)) {
        return index;
      }
    } catch (_error) {
      // noop
    }
  }
  return typeof cell.cellIndex === 'number' ? cell.cellIndex : -1;
}

export function getKendoGridSelectedCellIndex(senderOrRoot) {
  return getKendoGridCellIndex(senderOrRoot, getKendoGridSelectedCell(senderOrRoot));
}

export function findKendoGridSelectables(root) { return queryAll(findKendoGridRoot(root) || root, '.k-grid-content .k-selectable, .k-grid-content-locked .k-selectable, .k-grid-content .k-grid-table, .k-grid-content-locked .k-grid-table, .k-grid-content table, .k-grid-content-locked table'); }
export function findKendoGridVerticalScrollbar(root) { return first(findKendoGridRoot(root) || root, ['.k-scrollbar.k-scrollbar-vertical', '.k-scrollbar-vertical']); }

export function findKendoSchedulerRoot(root) { return first(root, ['.k-scheduler']); }
export function findKendoSchedulerToolbar(root) { return first(findKendoSchedulerRoot(root) || root, ['.k-scheduler-toolbar']); }
export function findKendoSchedulerHeaderWrap(root) { return first(findKendoSchedulerRoot(root) || root, ['.k-scheduler-header-wrap']); }
export function findKendoSchedulerHeaderAllDay(root) { return first(findKendoSchedulerRoot(root) || root, ['.k-scheduler-header-all-day']); }
export function findKendoSchedulerContent(root) { return first(findKendoSchedulerRoot(root) || root, ['.k-scheduler-content']); }
export function findKendoSchedulerAllDay(root) { return first(findKendoSchedulerRoot(root) || root, ['.k-scheduler-times-all-day']); }
export function findKendoSchedulerHeader(root) { return first(findKendoSchedulerRoot(root) || root, ['.k-scheduler-header']); }
export function findKendoSchedulerLayout(root) { return first(findKendoSchedulerRoot(root) || root, ['.k-scheduler-layout', '.k-scheduler']); }
export function findKendoSchedulerNavigation(root) { return first(findKendoSchedulerToolbar(root) || findKendoSchedulerRoot(root) || root, ['.k-scheduler-navigation']); }
export function findKendoSchedulerViews(root) { return first(findKendoSchedulerToolbar(root) || findKendoSchedulerRoot(root) || root, ['.k-scheduler-views', '[ref-view-day], [ref-view-week], [ref-view-month], [ref-view-agenda]']); }
export function findKendoSchedulerFooter(root) { return first(findKendoSchedulerRoot(root) || root, ['.k-scheduler-footer']); }
export function findKendoSchedulerTitle(root) { return first(findKendoSchedulerNavigation(root) || findKendoSchedulerToolbar(root) || findKendoSchedulerRoot(root) || root, ['.k-lg-date-format', '.k-sm-date-format']); }
export function findKendoSchedulerNavCurrent(root) { return first(findKendoSchedulerNavigation(root) || findKendoSchedulerToolbar(root) || findKendoSchedulerRoot(root) || root, ['.k-nav-current']); }
export function findKendoSchedulerNavToday(root) { return first(findKendoSchedulerNavigation(root) || findKendoSchedulerToolbar(root) || findKendoSchedulerRoot(root) || root, ['.k-nav-today', '[ref-nav-today]', '.k-scheduler-navigation .k-today']); }
export function findKendoSchedulerNavPrev(root) { return first(findKendoSchedulerNavigation(root) || findKendoSchedulerToolbar(root) || findKendoSchedulerRoot(root) || root, ['.k-nav-prev', '[ref-nav-prev]', '.k-scheduler-navigation .k-prev']); }
export function findKendoSchedulerNavNext(root) { return first(findKendoSchedulerNavigation(root) || findKendoSchedulerToolbar(root) || findKendoSchedulerRoot(root) || root, ['.k-nav-next', '[ref-nav-next]', '.k-scheduler-navigation .k-next']); }
export function findKendoSchedulerTables(root) { return queryAll(findKendoSchedulerRoot(root) || root, '.k-scheduler-content .k-scheduler-table, .k-scheduler-header-wrap .k-scheduler-table, .k-scheduler-times-all-day .k-scheduler-table'); }
export function findKendoSchedulerEvents(root, selector = null) { return queryAll(findKendoSchedulerRoot(root) || root, selector || '.k-scheduler-content .k-event, .k-scheduler-header-wrap .k-event'); }
