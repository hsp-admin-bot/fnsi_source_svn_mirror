import {
  getOnsElement,
  queryOnsPart,
  queryOnsParts,
  resolveOnsElement
} from "@/compat/onsen/host";

function unwrapElement(target) {
  return resolveOnsElement(target);
}

export function getOnsSpeedDialElement(target, fallbackRoot = null, selector = null) {
  const direct = getOnsElement(target, "ons-speed-dial", ".speed-dial", fallbackRoot);
  if (direct) {
    return direct;
  }
  const root = unwrapElement(fallbackRoot);
  if (selector && root?.querySelector) {
    try {
      return root.querySelector(selector);
    } catch (_error) {
      return null;
    }
  }
  return null;
}

export function getOnsSpeedDialFabElement(speedDialRoot) {
  const root = getOnsSpeedDialElement(speedDialRoot) || unwrapElement(speedDialRoot);
  return queryOnsPart(root, ["ons-fab", ".fab"]);
}

export function getOnsSpeedDialItemElements(speedDialRoot) {
  const root = getOnsSpeedDialElement(speedDialRoot) || unwrapElement(speedDialRoot);
  return queryOnsParts(root, ["ons-speed-dial-item", ".speed-dial__item"]);
}

export function getOnsSpeedDialIconElements(speedDialRoot) {
  const root = getOnsSpeedDialElement(speedDialRoot) || unwrapElement(speedDialRoot);
  return queryOnsParts(root, [
    "ons-speed-dial-item img.ntss-fab-icon",
    "ons-speed-dial-item img",
    ".fab__icon img"
  ]);
}

export function getOnsSpeedDialEventTarget(event) {
  const rawTarget = unwrapElement(event?.target) || unwrapElement(event?.currentTarget);
  if (!rawTarget) {
    return null;
  }
  try {
    return rawTarget.closest?.("ons-speed-dial-item, ons-fab, .fab, .speed-dial__item, .fab__icon") || rawTarget;
  } catch (_error) {
    return rawTarget;
  }
}
