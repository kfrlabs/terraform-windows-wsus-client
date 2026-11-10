# Issues

Curated mirror of the GitHub Issues for `kfrlabs/terraform-windows-wsus-client`.
The GitHub Issues tracker is authoritative; this file only preserves the
roadmap at bootstrap time (issue #1).

## Open issues at bootstrap (#1)

- #1 (setup) — Bootstrap du repository.
- #2 (setup) — `versions.tf` : contraintes Terraform et provider.
- #3 (design) — Décision de typage des variables (`false` / `null`).
- #4 (core, validation) — Variables cœur (serveur, mode de mise à jour, planning).
- #5 (core) — `locals` : mapping des enums et valeurs dérivées.
- #6 (core) — Ressources cœur : `UseWUServer`, `WUServer`, `WUStatusServer`.
- #7 (core) — Ressources cœur : `AUOptions`, jour et heure d'installation.
- #8 (feature) — Booléens simples (7 clés registre).
- #9 (feature) — Paires `Valeur` / `Enabled` (5 paramètres).
- #10 (feature) — `AlwaysAutoRebootAtScheduledTimeMinutes` et Active Hours.
- #11 (validation) — Validations croisées entre variables.
- #12 (feature, docs) — `windows_service.wuauserv` et procédure d'import.
- #13 (core) — `outputs.tf`.
- #14 (examples) — Exemples `basic`, `scheduled`, `active-hours`.
- #15 (docs) — README du module (Registry).
- #16 (ci) — CI : fmt, validate, tflint, terraform-docs.
- #17 (test) — Test d'acceptation sur hôte Windows réel.
- #18 (release) — Release `v1.0.0` et publication sur le Registry.

See PLAN.md for the implementation order and acceptance criteria.
