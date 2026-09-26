# infra-nix

Matt's Nix flake config, covering three hosts: **igloo** (x86_64-linux,
NixOS), **updog** (x86_64-linux, NixOS-WSL) and **mktogo** (aarch64-darwin,
nix-darwin), one user: **matt**.

## What this is

A single Nix flake built with [flake-parts](https://flake.parts/) and the
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

home-manager is wired in as a NixOS/nix-darwin module (`den.hosts.*.users.matt`),
not run standalone - `sudo nixos-rebuild switch` / `darwin-rebuild switch`
applies both system and home config in one shot. There's no separate
`home-manager switch` step, although the `home-manager` CLI binary is on
`$PATH` (useful for things like `home-manager generations`).

Each host declares its own **host aspect** (`den.aspects.igloo`,
`den.aspects.mktogo`) with `nixos = {...}`/`darwin = {...}` blocks as
appropriate - den auto-detects the class from the host's system
(`aarch64-darwin` → `darwin`, everything else → `nixos`). Aspects shared
across hosts branch the same way when their content actually differs per
platform (e.g. `nix-settings.nix` has both a `nixos` and a `darwin` block
for GC/store-optimise, since nix-darwin's options differ slightly from
NixOS's).

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

### WSL (updog)

updog sets `wsl.enable = true` on its `den.hosts` entry (`modules/hosts.nix`),
which makes den's wsl battery import `inputs.nixos-wsl` and has
`den.batteries.primary-user` set `wsl.defaultUser`. It's headless: the
desktop aspects and GUI apps/packages in `modules/users/matt.nix` are gated
off on `host.wsl.enable`.

### macOS (mktogo)

mktogo is a MacBook running [nix-darwin](https://github.com/nix-darwin/nix-darwin)
(input name must be exactly `darwin` - nix-darwin isn't its own flake input
name, den's default `darwin`-class instantiator calls
`inputs.darwin.lib.darwinSystem`). [nix-homebrew](https://github.com/zhaofengli-wip/nix-homebrew)
manages Homebrew itself; app casks (`homebrew.casks` in
`modules/hostnames/mktogo.nix`) cover GUI apps

The Wayland desktop aspects (`mango`, `river`, `fuzzel`, `gtk`, `via`)
obviously don't apply here. Rather than a separate Darwin-only user
aspect, `modules/users/matt.nix` includes them conditionally, gated on
`host.class != "darwin"` - so the same `den.aspects.matt` works
unmodified on both hosts. The cross-platform `home.packages` list is
filtered through `lib.meta.availableOn pkgs.stdenv.hostPlatform`, so
Linux/Wayland-only packages (e.g. `libvirt`, `grim`, `wlr-randr`) silently
drop out on Darwin instead of failing the build.

## Applying changes (SOPs)

**Normal changes:**

```sh
sudo nixos-rebuild switch --flake .#igloo     # igloo
sudo nixos-rebuild switch --flake .#updog     # updog (inside WSL)
darwin-rebuild switch --flake .#mktogo        # mktogo
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
darwin-rebuild build --flake .#mktogo
```

**New files don't show up until they're `git add`ed.** This flake is a
local `git+file://` source, and Nix only evaluates files git already knows
about - a brand-new, untracked `.nix` file under `modules/` is silently
invisible to `nix eval`/`nix build`/`*-rebuild` (an already-tracked file
you've only *modified* is fine). If a new host/aspect file doesn't seem to
apply at all, this is the first thing to check: `git add` it, then
re-evaluate.

**Rolling back:**

```sh
sudo nixos-rebuild switch --rollback   # igloo
darwin-rebuild switch --rollback       # mktogo
```

or, on igloo, pick an older generation from the GRUB boot menu (grub keeps
the last 10 generations - see `boot.loader.grub.configurationLimit` in
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
