import Vue3NotificationPlugin, { notify as vue3Notify } from "@kyvg/vue3-notification";

const notifications = new Set();

function normalizeNotificationPayload(payload = {}) {
  if (typeof payload === "string") {
    return { text: payload };
  }
  return payload || {};
}

function toVue3NotificationPayload(payload = {}) {
  const normalized = normalizeNotificationPayload(payload);
  return {
    ...normalized,
    text: normalized.text ?? normalized.message ?? normalized.content ?? "",
    title: normalized.title ?? normalized.type ?? "",
    type: normalized.type ?? normalized.group ?? undefined
  };
}

export function notify(payload = {}) {
  const normalized = normalizeNotificationPayload(payload);
  let delivered = false;
  notifications.forEach((listener) => {
    try {
      listener(normalized);
      delivered = true;
    } catch (_error) {
      // 通知 listener の例外で画面主処理を止めない。
    }
  });

  if (!delivered) {
    try {
      vue3Notify(toVue3NotificationPayload(normalized));
    } catch (_error) {
      // Vue3 notification plugin が未初期化でも、Vue2 互換呼び出し元は止めない。
    }
  }

  return normalized;
}

export function subscribeNotification(listener) {
  if (typeof listener !== "function") {
    return () => {};
  }
  notifications.add(listener);
  return () => notifications.delete(listener);
}

export default {
  install(app) {
    app?.use?.(Vue3NotificationPlugin);
    if (!app?.config?.globalProperties) {
      return;
    }
    app.config.globalProperties.$notify = notify;
  },
  notify,
  subscribeNotification
};
