{den, ...}: let
  fishHomeManager = {pkgs, ...}: {
    programs.fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_greeting # Disable greeting
        set fish_tmux_autostart true
      '';
      plugins = [
        {
          name = "grc";
          src = pkgs.fishPlugins.grc.src;
        }
        {
          name = "z";
          src = pkgs.fishPlugins.z.src;
        }
        {
          name = "Catppuccin";
          src = pkgs.fetchFromGitHub {
            owner = "catppuccin";
            repo = "fish";
            rev = "cc8e4d8fffbdaab07b3979131030b234596f18da";
            sha256 = "udiU2TOh0lYL7K7ylbt+BGlSDgCjMpy75vQ98C1kFcc=";
          };
        }
        {
          name = "tmux.fish";
          src = pkgs.fetchFromGitHub {
            owner = "budimanjojo";
            repo = "tmux.fish";
            rev = "7e820cb45c6784df71cbaf6dca0d17e39a9d59d4";
            sha256 = "ynhEhrdXQfE1dcYsSk2M2BFScNXWPh3aws0U7eDFtv4=";
          };
        }
      ];
      shellAliases = {
        ls = "lsd";
        man = "batman";
        vi = "nvim";
        sshp = "sshpass -f ~/.config/ssh/.sshpasswd ssh";
        ave =
          "ansible-vault edit {$HOME}/Repos/ansible-vault/kubernetes.yml --vault-pass-file {$HOME}/.config/ansible/vault/homelab.yml";
        k = "kubectl";
        tf = "terraform";
        cc = "helm -n kube-system get all cilium | sed -n '/USER-SUPPLIED VALUES/,/COMPUTED VALUES/p'";
        sops = "sops --config=/home/matt/Repos/homelab/.sops.yaml";
      };
      functions = {
        # Batch-convert phone clips (H.264/H.265, VFR) to ProRes 422 HQ + PCM
        # so DaVinci Resolve on Linux can read them. Usage:
        #   resolve-convert [-o outdir] [-p profile] [files or dirs...]
        # Defaults to video files in the cwd, writing to ./resolve/.
        # ProRes profiles: 0 proxy, 1 lt, 2 standard, 3 hq (default), 4 4444.
        # Mount the iPhone camera roll, copy new videos off it, and unmount.
        #   iphone-import [-d destdir] [-k] [-c]
        # Defaults to ~/Videos/iphone. Clips already in destdir are skipped.
        # -k keeps the phone mounted at ~/iphone, -c runs resolve-convert after.
        iphone-import = {
          description = "Copy new videos from a connected iPhone";
          body = ''
            argparse 'd/dest=' k/keep c/convert -- $argv; or return 1

            set -l dest $HOME/Videos/iphone
            set -q _flag_dest; and set dest $_flag_dest
            set -l mnt $HOME/iphone

            if not ${pkgs.libimobiledevice}/bin/idevicepair validate >/dev/null 2>&1
              echo "iphone-import: phone not paired; unlock it and tap Trust..." >&2
              ${pkgs.libimobiledevice}/bin/idevicepair pair; or return 1
            end

            mkdir -p $mnt $dest; or return 1

            set -l mounted_here false
            if not mountpoint -q $mnt
              ${pkgs.ifuse}/bin/ifuse $mnt; or return 1
              set mounted_here true
            end

            set -l files (find $mnt/DCIM -type f \( -iname '*.mov' -o -iname '*.mp4' -o -iname '*.m4v' \) 2>/dev/null)
            if test (count $files) -eq 0
              echo "iphone-import: no videos found in $mnt/DCIM" >&2
            else
              for f in $files
                ${pkgs.rsync}/bin/rsync -t --ignore-existing --progress $f $dest/
              end
            end

            if not set -q _flag_keep; and test $mounted_here = true
              fusermount -u $mnt
            end

            if set -q _flag_convert; and test (count $files) -gt 0
              resolve-convert -o $dest/resolve $dest
            end
          '';
        };
        resolve-convert = {
          description = "Batch convert clips to ProRes for DaVinci Resolve";
          body = ''
            argparse 'o/outdir=' 'p/profile=' -- $argv; or return 1

            set -l outdir resolve
            set -q _flag_outdir; and set outdir $_flag_outdir
            set -l profile 3
            set -q _flag_profile; and set profile $_flag_profile

            set -l inputs $argv
            test (count $inputs) -eq 0; and set inputs .

            set -l files
            for item in $inputs
              if test -d $item
                for f in $item/*.{mov,MOV,mp4,MP4,m4v,M4V}
                  test -f $f; and set -a files $f
                end
              else if test -f $item
                set -a files $item
              else
                echo "resolve-convert: skipping '$item' (not found)" >&2
              end
            end

            if test (count $files) -eq 0
              echo "resolve-convert: no clips found" >&2
              return 1
            end

            mkdir -p $outdir; or return 1

            for f in $files
              set -l base (path basename (path change-extension "" $f))
              set -l out $outdir/$base.mov
              if test -e $out
                echo "skip (exists): $out"
                continue
              end
              echo "convert: $f -> $out"
              ${pkgs.ffmpeg}/bin/ffmpeg -nostdin -hide_banner -loglevel error -stats \
                -i $f \
                -map 0:v:0 -map '0:a?' \
                -c:v prores_ks -profile:v $profile -pix_fmt yuv422p10le \
                -fps_mode cfr \
                -c:a pcm_s16le \
                $out
              or begin
                echo "failed: $f" >&2
                rm -f $out
              end
            end
          '';
        };
        ytarchive = ''
          function ytarchive
           yt-dlp -f bestvideo[height<=1080][ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best -o '%(upload_date)s - %(channel)s - %(id)s - %(title)s.%(ext)s' \
           --sponsorblock-mark "all" \
           --geo-bypass \
           --sub-langs 'all' \
           --embed-subs \
           --embed-metadata \
           --convert-subs 'srt' \
           --download-archive $argv[1].txt https://www.youtube.com/$argv[1]/videos;
          end
        '';
        ytarchivevideo = ''
          function ytarchivevideo
            yt-dlp -f bestvideo[height<=1080][ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best -o '%(upload_date)s - %(channel)s - %(id)s - %(title)s.%(ext)s' \
           --sponsorblock-mark "all" \
           --geo-bypass \
           --sub-langs 'all' \
           --embed-metadata \
           --convert-subs 'srt' \
           --download-archive $argv[1] $argv[2];
          end
        '';
        ytd = ''
          function ytd
            yt-dlp -f bestvideo[height<=1080][ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best -o '%(upload_date)s - %(channel)s - %(id)s - %(title)s.%(ext)s' \
            --sponsorblock-mark "all" \
            --geo-bypass \
            --sub-langs 'all' \
            --embed-subs \
            --embed-metadata \
            --convert-subs 'srt' \
            $argv
          end
        '';
      };
    };
  };
in {
  den.aspects.fish = {
    includes = [
      ({
        host,
        user,
        ...
      }: {
        name = "fish/${user.userName}@${host.name}";
        homeManager = fishHomeManager;
      })
    ];
  };
}
