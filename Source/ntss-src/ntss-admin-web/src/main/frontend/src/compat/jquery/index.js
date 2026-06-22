import $ from "jquery";

function installLegacyJQueryApis(jqueryInstance = $) {
  if (!jqueryInstance) {
    return jqueryInstance;
  }
  if (typeof jqueryInstance.parseJSON !== "function") {
    jqueryInstance.parseJSON = function parseJSON(data) {
      return JSON.parse(data);
    };
  }
  return jqueryInstance;
}

// Vue2 時代の jQuery 利用チェーンを Vue3 側でも一箇所に固定します。
// Kendo jQuery fallback も同じインスタンスを参照できるよう global へ同期します。
export function installGlobalJQuery(target = globalThis) {
  installLegacyJQueryApis($);
  if (!target) {
    return $;
  }
  target.$ = $;
  target.jQuery = $;
  if (target.window) {
    target.window.$ = $;
    target.window.jQuery = $;
  }
  return $;
}

export function installJQueryOnOwnerWindow(target = null) {
  installLegacyJQueryApis($);
  const element = target?.$el || target?.element?.[0] || target?.element || target?.wrapper?.[0] || target?.wrapper || target;
  const ownerWindow = element?.ownerDocument?.defaultView;
  if (ownerWindow && ownerWindow.$ !== $) {
    ownerWindow.$ = $;
    ownerWindow.jQuery = $;
  }
  return $;
}

export function toJQuery(target = null) {
  if (!target) {
    return $();
  }
  if (target.jquery) {
    return target;
  }
  const element = target?.$el || target?.element?.[0] || target?.element || target?.wrapper?.[0] || target?.wrapper || target;
  installJQueryOnOwnerWindow(element);
  try {
    return $(element);
  } catch (_error) {
    return $();
  }
}

export function getJQueryData(target, key) {
  const $target = toJQuery(target);
  return key ? $target.data(key) : $target.data();
}

export function setJQueryData(target, key, value) {
  const $target = toJQuery(target);
  if (!$target.length || !key) {
    return $target;
  }
  $target.data(key, value);
  return $target;
}

export function removeJQueryData(target, key) {
  const $target = toJQuery(target);
  if (!$target.length || !key) {
    return $target;
  }
  $target.removeData(key);
  return $target;
}

export function getJQueryWidget(target, names = []) {
  const keys = Array.isArray(names) ? names : [names];
  const $target = toJQuery(target);
  for (const key of keys) {
    const widget = $target.data(key);
    if (widget) {
      return widget;
    }
  }
  return null;
}

export function defineJQueryWidgetData(target, key, widget, aliases = []) {
  const $target = toJQuery(target);
  const keys = [key, ...aliases].filter(Boolean);
  keys.forEach((dataKey) => $target.data(dataKey, widget));
  return $target;
}

export function removeJQueryWidgetData(target, keys = []) {
  const $target = toJQuery(target);
  (Array.isArray(keys) ? keys : [keys]).filter(Boolean).forEach((key) => $target.removeData(key));
  return $target;
}

export function getJQueryPlugin(name) {
  return name ? $.fn[name] : undefined;
}

export function hasJQueryPlugin(name) {
  return typeof getJQueryPlugin(name) === "function";
}

export function callJQueryPlugin(target, name, ...args) {
  const plugin = getJQueryPlugin(name);
  const $target = toJQuery(target);
  if (typeof plugin !== "function") {
    return $target;
  }
  return plugin.apply($target, args);
}

export function ensureJQueryPlugin(name, factory) {
  if (!name || typeof $.fn[name] === "function") {
    return $.fn[name];
  }
  if (typeof factory === "function") {
    $.fn[name] = factory;
  }
  return $.fn[name];
}

export function bridgeJQueryWidgetPlugin(name, mountWidget, options = {}) {
  if (!name || typeof mountWidget !== "function") {
    return $.fn[name];
  }
  const original = typeof $.fn[name] === "function" ? $.fn[name] : null;
  if (original && options.preserveExisting !== false) {
    return original;
  }
  $.fn[name] = function bridgedJQueryWidget(pluginOptions = {}) {
    this.each(function eachWidget() {
      mountWidget(this, pluginOptions);
    });
    return this;
  };
  $.fn[name].__compatOriginal = original;
  return $.fn[name];
}

installGlobalJQuery();

export { $ };
export const jQuery = $;
export default $;
