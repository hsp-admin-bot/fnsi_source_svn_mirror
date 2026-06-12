const LegacyNotifications = {
  install(app) {
    const notify = options => {
      const detail = typeof options === "string" ? { text: options } : { ...(options || {}) };
      window.dispatchEvent(new CustomEvent("legacy-notify", { detail }));
      if (detail.text || detail.title) {
        // Keep Vue2 $notify calls harmless when the visual notification host is not mounted.
        console.info(detail.title || "notification", detail.text || detail.message || "");
      }
    };
    app.config.globalProperties.$notify = notify;
    app.component("LegacyNotificationsHost", {
      name: "LegacyNotificationsHost",
      template: '<div class="legacy-notifications-host" style="display:none"><slot /></div>'
    });
  }
};

export default LegacyNotifications;
