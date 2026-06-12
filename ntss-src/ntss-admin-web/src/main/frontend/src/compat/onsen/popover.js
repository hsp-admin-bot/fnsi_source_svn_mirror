import { getComponentParent } from "@/functions/common/ComponentOwnerResolver";
import {
  getOnsElement,
  getOnsElementFromEvent,
  queryOnsPart,
  resolveOnsElement,
  resolveHostElement
} from "@/compat/onsen/host";

function unwrapElement(target) {
  const element = resolveHostElement(target, { allowDocument: false, allowFragment: false });
  return element?.nodeType === 1 ? element : null;
}

export function resolveOnsPopoverTargetElement(target, vm = null) {
  return unwrapElement(target) || unwrapElement(getComponentParent(vm)) || unwrapElement(vm) || null;
}

export function getOnsPopoverElement(target, fallbackRoot = null) {
  const element = resolveOnsElement(target);
  const host = element?.closest?.("ons-popover");
  if (host) {
    return host;
  }
  return getOnsElement(target, "ons-popover", ".popover", fallbackRoot);
}

export function getOnsPopoverFromEvent(event, fallbackRoot = null) {
  return getOnsElementFromEvent(event, "ons-popover", ".popover", fallbackRoot, "popover");
}

export function getOnsPopoverArrowElement(popoverRoot) {
  const popover = getOnsPopoverElement(popoverRoot) || resolveOnsElement(popoverRoot);
  return queryOnsPart(popover, [".popover__arrow"]);
}

export function getOnsPopoverBodyElement(popoverRoot) {
  const popover = getOnsPopoverElement(popoverRoot) || resolveOnsElement(popoverRoot);
  return queryOnsPart(popover, [".popover"]);
}

export function getOnsPopoverContentElement(popoverRoot) {
  const popover = getOnsPopoverElement(popoverRoot) || resolveOnsElement(popoverRoot);
  return queryOnsPart(popover, [".popover__content"]);
}

export function getOnsPopoverParts(popoverRoot) {
  const popover = getOnsPopoverElement(popoverRoot) || resolveOnsElement(popoverRoot);
  return {
    root: popover || null,
    arrow: getOnsPopoverArrowElement(popover),
    popover: getOnsPopoverBodyElement(popover),
    content: getOnsPopoverContentElement(popover)
  };
}

export function getOnsPopoverPartsFromEvent(event) {
  return getOnsPopoverParts(getOnsPopoverFromEvent(event));
}
