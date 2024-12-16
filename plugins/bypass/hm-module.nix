{
  options = { cfg, mkKeyOption, ... }:
    { lib, ... }: {
      keys = {
        left = mkKeyOption {
          on = [ "l" ];
          run = "plugin bypass --args=smart_enter";
          desc =
            "Open a file, or recursively enter child directory, skipping children with only a single subdirectory";
        };
      };
      #test = lib.mkEnableOption "test";

      #mkKeyOption =
      #{};
    };
  config = { cfg, setKeys, ... }:
    { config, lib, ... }:
    { } // (setKeys cfg.keys);
}
