{
  description = "A collection of plugins for the Yazi file manager";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Flake utils for stripping some boilerplate
    flake-utils.url = "github:numtide/flake-utils";
    flake-utils.inputs.systems.follows = "systems";
    flake-utils-plus.url = "github:gytis-ivaskevicius/flake-utils-plus/v1.4.0";
    flake-utils-plus.inputs.flake-utils.follows = "flake-utils";

    # The list of supported systems.
    systems.url = "github:nix-systems/default-linux";

    # Haumea for directory-defined attrset loading
    haumea.url = "github:nix-community/haumea/v0.2.2";
    haumea.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, flake-utils-plus, systems, haumea, ... }:
    let
      inherit (self) outputs;
      instantiate_lib = lib: pkgs: rec {
        inherit (pkgs) callPackage;
        inherit (lib)
          mapAttrs mapAttrsToList listToAttrs filterAttrs mkMerge attrValues
          filter flatten attrByPath mkOption mkEnableOption;
        # bypass.package = ...
        # -> bypass = ...
        CondRaiseAttrs = n: set:
          mapAttrs (_n: v: v."${n}") (filterAttrs (_n: v: v ? "${n}") set);

        packages = (CondRaiseAttrs "package" YaziPlugins);

        homeManagerModulesRaised = (CondRaiseAttrs "hm-module" YaziPlugins);
        homeManagerModulesImports = (map (v:
          { config, lib, ... }:
          let cfg = config.programs.yazi.yaziPlugins.plugins.${v.name};
          in {
            imports = (filter (v: v != { }) [
              (inputs: lib.mkIf cfg.enable (v.config cfg inputs))
              #(v.config cfg)
              (v.options cfg)
              ({ ... }: {
                options.programs.yazi.yaziPlugins.plugins.${v.name} = {
                  package = mkOption {
                    type = lib.types.package;
                    description = "The ${v.name} package to use";
                    default = (attrByPath [ "yaziPlugins" v.name ] null pkgs);
                  };
                  enable = mkEnableOption v.name;
                };
              })
            ]);
          }) (attrValues homeManagerModulesRaised));

        YaziPlugins =
          let AttrName = path: builtins.baseNameOf (builtins.dirOf path);
          in haumea.lib.load {
            src = ./plugins;
            inputs = (removeAttrs pkgs [ "self" "super" "root" ]) // {
              flake = self;
            };
            # Call files like with callPackage
            loader = [
              {
                matches = str: str == "package.nix";
                loader = inputs: path: {
                  "${AttrName path}" =
                    (haumea.lib.loaders.callPackage inputs path);
                };
              }
              {
                matches = str: str == "hm-module.nix";
                loader = _: path:
                  let
                    value = haumea.lib.loaders.verbatim { } path;
                    name = AttrName path;
                  in {
                    inherit name;
                    options = if value ? "options" then
                      (cfg: inputs: {
                        options.programs.yazi.yaziPlugins.plugins.${name} =
                          value.options cfg inputs;
                      })
                    else
                      _: _: { };
                    config =
                      if value ? "config" then value.config else _: _: { };
                  };
              }
            ];
          };
      };

    in flake-utils-plus.lib.mkFlake {
      inherit self inputs;

      outputsBuilder = channels:
        let
          pkgs = channels.nixpkgs;
          lib = inputs.nixpkgs.lib;
          instance = (instantiate_lib lib pkgs);
        in {
          inherit (instance) packages;
          formatter = pkgs.nixfmt-rfc-style;

        };

      overlays.default = let lib = inputs.nixpkgs.lib;
      in final: prev: { yaziPlugins = (instantiate_lib lib prev).packages; };

      homeManagerModules = rec {
        yaziPlugins = { lib, ... }: {
          imports = ((instantiate_lib lib
            (inputs.nixpkgs.legacyPackages.x86_64-linux)).homeManagerModulesImports)
            ++ [ ./module.nix ];
        };
        default = yaziPlugins;
      };
    };
}
