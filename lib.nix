{ lib, ... }: {
  mkKeyOption = { on, run, desc, onexample ? on, runexample ? run }:
    let
      inherit (lib) mkOption isList;
      inherit (lib.types) submodule str either listOf;
    in mkOption {
      description = desc;
      type = either (submodule {
        options = {
          on = mkOption {
            type = listOf str;
            #example = onexample;
            default = on;
          };
          run = mkOption {
            type = str;
            #exmaple = runexample;
            default = run;
          };

          desc = mkOption {
            type = str;
            #exmaple = desc;
            default = desc;
          };
        };
      }) (listOf str);
      default = { inherit on run desc; };
      apply = old:
        if isList old then {
          on = old;
          run = run;
        } else
          old;
    };

}
