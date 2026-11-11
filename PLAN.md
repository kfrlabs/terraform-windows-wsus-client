# Plan — terraform-windows-wsus-client

Module Terraform réutilisable, publiable sur le Terraform Registry, équivalent du module Puppet `puppetlabs/wsus_client` (v6.4.0 analysée).

Repo : `kfrlabs/terraform-windows-wsus-client` (public, organisation `kfrlabs`).
Provider : `kfrlabs/windows` (Windows via SSH + PowerShell, ressources `windows_registry_value` + `windows_service`).
Source Puppet : https://github.com/puppetlabs/puppetlabs-wsus_client (`manifests/init.pp`, `manifests/setting.pp`, `REFERENCE.md`).

## 1. Ce que fait le module Puppet

- Gère le client WSUS uniquement via registre :
  - `HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate`
  - `HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AU`
- Active le service `wuauserv` (`enable => true`).
- Logique `wsus_client::setting` :
  - `data == undef` → ne rien gérer.
  - `has_enabled == true` → gère aussi `<Key>Enabled` (DWORD `bool2num(data != false)`).
  - `validate_bool` → DWORD 0/1.
  - `validate_range` → entier dans intervalle.
- ~21 paramètres, tous optionnels sauf contraintes croisées :
  - `enable_status_server=true` exige `server_url` (URL).
  - `auto_update_option="Scheduled"|4` exige `scheduled_install_day` + `scheduled_install_hour`.
  - `auto_update_option=7` (`NotifyRestart`) ≥ Windows Server 2016.
  - `active_hours_start` + `active_hours_end` : les deux ensemble ou rien.
- Incompatible avec les GPO gérant les mêmes clés (à conserver dans la doc).

## 2. Tableau de correspondance Puppet → Terraform

Base : `hive="HKLM"`. Le path provider exclut la hive (`path="SOFTWARE\\Policies\\Microsoft\\Windows\\WindowsUpdate..."`).

| Param Puppet | Clé(s) registre | Ressource TF | Type / valeur |
|---|---|---|---|
| `server_url` (URL\|`false`\|undef) | `AU\UseWUServer` DWORD, `WUServer` REG_SZ | `windows_registry_value.use_wu_server`, `.wu_server` | `string/false/null`. `null`=absent (`count=0`), `false`→`UseWUServer="0"`, URL→`"1"` + `WUServer=url` |
| `enable_status_server` (bool\|undef) | `WUStatusServer` REG_SZ | `windows_registry_value.wu_status_server` | `true`→`=server_url`, `false`→valeur supprimée/absente, `null`=non géré. Validation : `true` exige `server_url` URL |
| `auto_update_option` | `AU\AUOptions` DWORD | `.au_options` | `NotifyOnly=2, AutoNotify=3, Scheduled=4, AutoInstall=5, NotifyRestart=7`. Accepter string ou int en variable, convertir en `locals` |
| `scheduled_install_day` | `AU\ScheduledInstallDay` DWORD | `.scheduled_install_day` | `Everyday=0, Sunday=1, ..., Saturday=7`. Accepter string ou int |
| `scheduled_install_hour` | `AU\ScheduledInstallTime` DWORD | `.scheduled_install_hour` | `0-23` |
| `detection_frequency_hours` | `AU\DetectionFrequency` + `DetectionFrequencyEnabled` | 2 ressources | `1-22` → valeur + `Enabled="1"` ; `false` → `Enabled="0"` seul ; `null` → rien |
| `reboot_relaunch_timeout_minutes` | `AU\RebootRelaunchTimeout` + `Enabled` | 2 ressources | `1-1440` / `false` / `null`, même pattern |
| `reboot_warning_timeout_minutes` | `AU\RebootWarningTimeout` + `Enabled` | 2 ressources | `1-30` / `false` / `null` |
| `reschedule_wait_time_minutes` | `AU\RescheduleWaitTime` + `Enabled` | 2 ressources | `1-60` / `false` / `null`, seulement si `AUOptions=4` |
| `target_group` | `TargetGroup` REG_SZ + `TargetGroupEnabled` | 2 ressources | `string` → valeur + `Enabled="1"` ; `false` → `Enabled="0"` ; `null` → rien |
| `accept_trusted_publisher_certs` | `AcceptTrustedPublisherCerts` DWORD | 1 ressource | `bool/null` → `"1"/"0"` |
| `auto_install_minor_updates` | `AU\AutoInstallMinorUpdates` DWORD | 1 ressource | `bool/null` |
| `disable_windows_update_access` | `DisableWindowsUpdateAccess` DWORD | 1 ressource | `bool/null` |
| `elevate_non_admins` | `ElevateNonAdmins` DWORD | 1 ressource | `bool/null` |
| `no_auto_reboot_with_logged_on_users` | `AU\NoAutoRebootWithLoggedOnUsers` DWORD | 1 ressource | `bool/null` |
| `no_auto_update` | `AU\NoAutoUpdate` DWORD | 1 ressource | `bool/null` |
| `always_auto_reboot_at_scheduled_time` | `AU\AlwaysAutoRebootAtScheduledTime` DWORD | 1 ressource | `bool/null` |
| `always_auto_reboot_at_scheduled_time_minutes` | `AU\...Minutes` DWORD | 1 ressource | `15-180` |
| `active_hours_start` / `active_hours_end` | `SetActiveHours` + `ActiveHoursStart` + `ActiveHoursEnd` | 3 ressources | `0-23` chacun, les 2 requis ensemble → `SetActiveHours="1"`, `false` → `"0"` |
| `purge_values` | `registry_key purge => true` | — | **Non transposable** : le provider n'a pas de ressource `registry_key`, `windows_registry_value` crée les clés implicitement. Documenter comme limite |
| service `wuauserv` | `enable => true` | `windows_service.wuauserv` | Service existant : pattern `import`, `start_type="Automatic"`. Ne jamais `Create` un `wuauserv` |

Total indicatif : ~25 `windows_registry_value` + 1 `windows_service` (import uniquement).

## 3. Architecture du module

```
terraform-windows-wsus-client/
├── versions.tf        # terraform >= 1.11, windows provider kfrlabs/windows
├── variables.tf       # ~21 vars nullable + validations
├── main.tf            # locals (mapping enums) + ressources conditionnelles
├── outputs.tf         # au_options_effective, wu_server, status_server, etc.
├── README.md          # Registry : usage, exemples, limites (GPO, purge, import wuauserv)
├── PLAN.md            # ce fichier
└── examples/
    ├── basic/         # server_url seul
    ├── scheduled/     # server_url + Scheduled mardi 02h
    └── active-hours/  # + Active Hours
```

Conventions :
- Variables `nullable`, défaut `null` (= Puppet `undef`, non géré).
- `count = var.x != null ? 1 : 0` sur chaque `windows_registry_value` optionnel.
- `value_string` : DWORD exprimés en décimal string (`"1"`, `"4"`), REG_SZ en clair.
- `hive = "HKLM"`, `path` sans hive, `type = "REG_DWORD"` ou `"REG_SZ"`.
- `locals` : maps `NotifyOnly→2...`, `Everyday→0...` pour accepter les deux formes Puppet.

## 4. Variables (projet)

Toutes `default = null` sauf `manage_wuauserv` (`true`) :

- `server_url : string` — validation URL `http(s)://` ou `"false"`. Passer par `string`, interpréter `"false"` comme désactivation.
- `enable_status_server : bool`
- `auto_update_option : string` — `NotifyOnly|AutoNotify|Scheduled|AutoInstall|NotifyRestart|2|3|4|5|7`
- `scheduled_install_day : string` — `Everyday|Sunday|...|Saturday|0-7`
- `scheduled_install_hour : number` — `0-23`
- Décision (issue #3, voir `docs/adr-0001-typing.md`) : option 1 retenue — `string` nullable avec `"false"` = désactivé pour tous les paramètres valeur-ou-false : `server_url`, `detection_frequency_hours` (`1-22`), `reboot_relaunch_timeout_minutes` (`1-1440`), `reboot_warning_timeout_minutes` (`1-30`), `reschedule_wait_time_minutes` (`1-60`), `always_auto_reboot_at_scheduled_time_minutes` (`15-180`), `active_hours_start`/`active_hours_end` (`0-23`), `target_group` (nom de groupe).
- Les 7 booléens simples restent `bool` nullable : `accept_trusted_publisher_certs`, `auto_install_minor_updates`, `disable_windows_update_access`, `elevate_non_admins`, `no_auto_reboot_with_logged_on_users`, `no_auto_update`, `always_auto_reboot_at_scheduled_time`.
- Exception : `scheduled_install_hour` reste `number` (`0-23`) — aucun sens de `false` côté Puppet/registre pour cette clé.
- Sémantique (paires `Valeur`/`Enabled`, voir §2) :

| Entrée | Effet |
|---|---|
| `null` (défaut) | non géré — aucune ressource (équivalent Puppet `undef`) |
| `"false"` (minuscule exacte, sensible à la casse) | `<Key>Enabled = "0"` seul, ressource valeur absente (`count = 0`) |
| valeur | `<Key> = valeur` + `<Key>Enabled = "1"` |

  Cas limite `target_group = "false"` : interprété comme désactivation (`TargetGroupEnabled = "0"`), donc le nom de groupe littéral `"false"` est impossible — limite documentée, héritée de Puppet (`false` booléen). `"False"` (majuscule) créerait un groupe de ce nom au lieu de désactiver ; #11/#4 à faire respecter ou normaliser.
  Paire `active_hours_start`/`active_hours_end` : les deux `null`, les deux `"false"`, ou les deux numériques ; tout mélange `"false"`/numérique est rejeté par la validation #11.
- Conséquences : #5 mappe via `tonumber()` après exclusion de `"false"`/`null` ; #11 vérifie les préconditions sur la forme `string` (`"Scheduled"`/`"4"`, paire `active_hours_start`/`active_hours_end`, `enable_status_server` ⇒ `server_url` URL) ; traçabilité alignée, référencé par #4, #8, #9, #10.
- `manage_wuauserv : bool = true` — gère `windows_service.wuauserv` (import requis, voir §6).

Validations `validation {}` :
- `enable_status_server == true` ⇒ `server_url` URL valide.
- `auto_update_option in ("Scheduled","4")` ⇒ jour + heure non null.
- `reschedule_wait_time_minutes != null` ⇒ `auto_update_option` = Scheduled/4 (warning ou erreur, à trancher).
- ranges : `1-22`, `1-1440`, `1-30`, `1-60`, `0-23`, `15-180`.
- `active_hours_start` xor `active_hours_end` seul ⇒ erreur.

## 5. Exemples

`examples/basic/main.tf` :
```hcl
module "wsus" {
  source     = "kfrlabs/wsus-client/windows"
  version    = "~> 1.0"
  server_url = "http://wsus.example.lan:8530"
}
```

`examples/scheduled/main.tf` :
```hcl
module "wsus" {
  source                = "kfrlabs/wsus-client/windows"
  version               = "~> 1.0"
  server_url            = "http://wsus.example.lan:8530"
  enable_status_server  = true
  auto_update_option    = "Scheduled"
  scheduled_install_day = "Tuesday"
  scheduled_install_hour = 2
}
```

## 6. Points d'attention (à documenter, pas à coder en aveugle)

1. **Service `wuauserv`** : `windows_service` fait du lifecycle complet. Pour un service système existant, le module doit documenter `terraform import module.wsus.windows_service.wuauserv wuauserv` avant `apply`, sinon le provider tentera un `Create`. Vérifier sur hôte réel avec `TF_ACC=1`.
2. **`purge_values`** : sans équivalent. Ne pas promettre le purge. Option : documenter le nettoyage manuel.
3. **GPO** : reprendre l'avertissement Puppet — ne pas utiliser si une GPO gère `WindowsUpdate`.
4. **`AUOptions=7`** : noter `Windows Server 2016+` uniquement.
5. **Types `REG_DWORD` en string décimale** : le provider exige `value_string = "4"`, pas `4`.
6. **Naming Registry** : nom du module Registry `kfrlabs/wsus-client/windows`. Nom du repo GitHub `terraform-windows-wsus-client` conforme à la convention `terraform-<provider>-<name>`.

## 7. Checklist publication Registry

- [ ] Repo public `kfrlabs/terraform-windows-wsus-client`, branche `main`, `README.md` avec bloc `Usage`.
- [ ] `versions.tf` avec `required_providers { windows = { source = "kfrlabs/windows" } }`.
- [ ] Tag semver `v1.0.0` (`git tag`, GitHub Release).
- [ ] Connecter le repo sur `registry.terraform.io` (namespace `kfrlabs`) et vérifier le rendu + `terraform init` depuis la Registry.
- [ ] `examples/*` avec `README` court chacun (requis pour le score Registry).

## 8. Étapes d'implémentation (ordre)

1. `versions.tf` + `variables.tf` (types + validations §4).
2. `main.tf` : `locals` mapping + ressources `WUServer/UseWUServer/WUStatusServer/AUOptions/jour/heure` (cœur).
3. `main.tf` : booléens simples + paires `Valeur/Enabled` (`detection_frequency`, `reboot_*`, `reschedule`, `target_group`, `active_hours`).
4. `windows_service.wuauserv` + doc `import`.
5. `outputs.tf` + `README.md` (usage, limites GPO/purge).
6. `examples/basic|scheduled|active-hours`.
7. `terraform fmt -check`, `terraform validate`, `tflint` si dispo.
8. Test d'acceptance Windows réel (hôte SSH/OpenSSH) : `basic` puis `scheduled`, `terraform plan/apply/destroy`, vérif `reg query HKLM\...\WindowsUpdate`.
9. Tag `v1.0.0`, publication Registry, vérif `init` depuis Registry.

## 9. Critères d'acceptation

- `terraform validate` OK sur module + 3 exemples.
- `plan` avec que `server_url` ne crée que `UseWUServer + WUServer` (+ service si géré).
- `plan` `Scheduled` sans jour/heure → erreur claire.
- `enable_status_server=true` sans `server_url` → erreur claire.
- `false`/`null` ne créent/suppriment que le attendu (pas de diff fantôme).
- Doc mentionne GPO, purge non supporté, import `wuauserv`, équivalence Puppet `wsus_client` 6.x.
