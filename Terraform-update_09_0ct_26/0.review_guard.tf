variable "enable_baseline_plan" {
  type = bool
  default = true
  description = "Enable only a reviewed baseline plan. This does not authorize apply."
}
output "baseline_review_guard" {
  value = "Offline source reconciliation; inspect the normal plan before any apply."
  precondition {
    condition = var.enable_baseline_plan
    error_message = "Read OPEN_ITEMS.md, verify module versions and complete Helm values, then enable_baseline_plan for plan review only."
  }
}
