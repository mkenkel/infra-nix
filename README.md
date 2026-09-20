# infra-nix

Matt's NixOS flake config, currently covering one host: **igloo**
(x86_64-linux), one user: **matt**.

## What this is

A single NixOS flake built with [flake-parts](https://flake.parts/) and the
[`den`](https://github.com/denful/den) / [`import-tree`](https://github.com/denful/import-tree)
"dendritic" pattern: every `.nix` file under `modules/` is auto-discovered
and merged into one flake-parts module tree - there's no central list of
imports to maintain. Each file typically defines one **aspect**
(`den.aspects.<name>`), a self-contained bundle of NixOS config and/or
home-manager config for a single concern (an application, a service, a
piece of the desktop). Hosts then just list which aspects they want:

```nix
# modules/hostnames/igloo.nix
den.aspects.igloo.includes = [
  den.aspects.mango
  den.aspects.river
  den.aspects.greetd
  # ...
];
```

home-manager is wired in as a NixOS module (`den.hosts.*.users.matt`), not
run standalone - `sudo nixos-rebuild switch` applies both system and home
config in one shot. There's no separate `home-manager switch` step,
although the `home-manager` CLI binary is on `$PATH` (useful for things
like `home-manager generations`).

### Desktop stack

igloo runs [mango](https://github.com/mangowm/mango) (a dwm-style Wayland
compositor) as the primary session, with
[mangobar](https://github.com/mangowm/mangobar) as the status bar, `fuzzel`
as the launcher, `mako` for notifications, and `dank-greeter` at the login
screen. `river` exists as a second, less-configured session for
comparison/fallback.

The desktop's colors and monitor layout are centralized under `lib/`
(plain data files, deliberately kept *outside* `modules/` since
`import-tree` expects everything under `modules/` to be a proper dendritic
module, not bare data):

- `lib/palette-m3.nix` - a Material 3-inspired color palette. Read by
  mango's window-border colors, mangobar's CSS, fuzzel, and mako, so the
  whole desktop uses one set of tokens instead of N copies drifting apart.
- `lib/monitors.nix` - the physical monitor layout (name/resolution/
  refresh/scale/position). Read by mango, river, grub's boot theme
  resolution, and the greeter's compositor config.

Change either file once and rebuild; everything downstream picks it up.

## Applying changes (SOPs)

**Normal changes:**

```sh
sudo nixos-rebuild switch --flake .#igloo
```

**Check before switching** (evaluates + builds without activating
anything - also runs mango's own config validator over any mango/mangobar
config in the tree):

```sh
nix flake check
```

or, to just build without a full check:

```sh
nixos-rebuild build --flake .#igloo
```

**Rolling back:**

```sh
sudo nixos-rebuild switch --rollback
```

or pick an older generation from the GRUB boot menu (grub keeps the last
10 generations - see `boot.loader.grub.configurationLimit` in
`modules/system/boot/grub.nix`).

**Don't hand-edit `flake.nix`** - it's generated (see the file's own
header comment) from the `flake-file.inputs` block in
`modules/dendritic.nix`. To add/change a flake input, edit that block,
then regenerate:

```sh
nix run .#write-flake   # regenerates flake.nix
nix run .#write-lock    # regenerates flake.lock
```

**CI** runs `nix flake check` on every push/PR (`.github/workflows/test.yml`),
on both Linux and macOS runners.
