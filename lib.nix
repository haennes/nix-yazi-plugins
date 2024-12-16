{ lib, ... }: {
  mkKeyOption = { keys, run, desc, keysexample ? keys, runexample ? run }:
    let
      inherit (lib) mkOption isList;
      inherit (lib.types) submodule str either listOf;
    in mkOption {
      description = desc;
      type = either (submodule {
        options = {
          on = mkOption {
            type = listOf str;
            example = keysexample;
            default = keys;
          };
          run = mkOption {
            type = str;
            exmaple = runexample;
            default = run;
          };

          desc = mkOption {
            type = str;
            exmaple = desc;
            default = desc;
          };
        };
      }) (listOf str);
      apply = old:
        if isList old then {
          on = old;
          run = run;
        } else
          old;
    };

}
