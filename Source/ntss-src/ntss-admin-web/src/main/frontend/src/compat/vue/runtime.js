import * as VueRuntime from "vue";
import { createApp as createVueApp } from "vue";
import { installLegacyInstanceCompat } from "@/compat/vue/instance";

const globalComponents = new Map();
let activeApp = null;

function registerQueuedComponents(app) {
  if (!app?.component) {
    return;
  }
  globalComponents.forEach((definition, name) => {
    app.component(name, definition);
  });
}

export function createApp(...args) {
  const app = createVueApp(...args);
  activeApp = app;
  installLegacyInstanceCompat(app);
  registerQueuedComponents(app);
  return app;
}

const VueCompat = {
  ...VueRuntime,
  createApp,
  set(target, key, value) {
    if (target && typeof target === 'object') {
      target[key] = value;
    }
    return value;
  },
  delete(target, key) {
    if (target && typeof target === 'object') {
      delete target[key];
    }
  },
  component(name, definition) {
    if (!name) {
      return undefined;
    }
    if (definition === undefined) {
      return globalComponents.get(name);
    }
    globalComponents.set(name, definition);
    if (activeApp?.component) {
      activeApp.component(name, definition);
    }
    return definition;
  }
};

if (typeof globalThis !== "undefined") {
  globalThis.Vue = VueCompat;
}

export * from "vue";
export * from "@/compat/vue/instance";
export default VueCompat;
