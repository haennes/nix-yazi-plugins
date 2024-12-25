{
  options = { mkKeyOption, mkRuntimeDeps, ... }:
    { pkgs, lib, ... }: {
      keys = {
        fzf_find_name = mkKeyOption {
          on = [ "f" "f" ];
          run = "plugin fg --args='fzf'";
          desc = "find file by filename";
        };
        fzf_find_content = mkKeyOption {
          on = [ "f" "g" ];
          run = "plugin fg";
          desc = "find file by content (fuzzy match)";
        };
        rg_find_content = mkKeyOption {
          on = [ "f" "G" ];
          run = "plugin fg --args='rg'";
          desc = "find file by content (exact match)";
        };
      };
      runtimeDeps =
        mkRuntimeDeps { pkgs = with pkgs; [ bat fzf ripgrep-all ]; };
    };
  config = { cfg, setKeys, ... }: { pkgs, ... }: { } // (setKeys cfg.keys);
}
