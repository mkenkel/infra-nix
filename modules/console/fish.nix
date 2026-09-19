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
