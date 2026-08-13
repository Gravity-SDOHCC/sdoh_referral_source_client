// app/javascript/controllers/capacity_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["badge"];

  async check(e) {
    const orgId = e.currentTarget.dataset.orgId;
    if (!orgId) return;

    const badge = this.badgeTargets.find(b => b.dataset.orgId === orgId);
    if (!badge) return;

    badge.textContent = "Checking…";
    badge.classList.remove("bg-success", "bg-danger", "bg-warning", "bg-info", "bg-secondary");

    // Fail closed: anything not explicitly recognized reads as Unknown, never
    // as Available.
    const UNKNOWN = { text: "Unknown", cls: "bg-secondary" };
    const STATUSES = {
      "available": { text: "Available", cls: "bg-success" },
      "at-capacity": { text: "At Capacity", cls: "bg-danger" },
      "has-waitlist": { text: "Has Waitlist", cls: "bg-warning" },
      "assessment-required": { text: "Assessment Required", cls: "bg-info" },
      "unknown": UNKNOWN,
    };

    let status = UNKNOWN;
    try {
      const { capacity } = await fetch(`/organizations/${orgId}/check_capacity`).then(r => r.json());
      status = STATUSES[capacity] || UNKNOWN;
    } catch (err) {
      status = UNKNOWN;
    }

    badge.textContent = status.text;
    badge.classList.add(status.cls);
  }
}
