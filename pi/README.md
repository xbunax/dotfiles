# Pi configuration

The public configuration is in `agent/`: keybindings, status-line options, the Gruvbox theme, and the plan-mode extension. `agent/settings.example.json` is a sanitized copy of the local settings. It omits the device ID and the machine-specific local package path.

On a new machine, copy `agent/settings.example.json` to the Pi agent directory as `settings.json`, then add any machine-specific packages as needed and sign in with Pi. Do not commit `auth.json`, `sessions/`, `models-store.json`, installed packages, or the live `settings.json`; `pi/.gitignore` only permits explicitly reviewed files.
