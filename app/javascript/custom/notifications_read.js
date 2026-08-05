// 通知ページを離れる際に既読化する

function markNotificationsRead() {
  if (!document.querySelector(".notifications")) return;

  const token = document.querySelector('meta[name="csrf-token"]')?.content;
  fetch("/notifications/read", {
    method: "PATCH",
    headers: {
      "X-CSRF-Token": token,
      "Content-Type": "application/json",
    },
    keepalive: true,
  });
}

document.addEventListener("turbo:before-visit", markNotificationsRead);
document.addEventListener("visibilitychange", function() {
  if (document.visibilityState === "hidden") markNotificationsRead();
});
