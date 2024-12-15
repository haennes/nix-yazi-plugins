{
  options = cfg: { lib, ... }: { test = lib.mkEnableOption "test"; };
  config = cfg:
    { config, lib, ... }: {
      home.file.test.text = if cfg.enable then "a" else "b";
      home.file.test2.text = if cfg.test then "a" else "b";
    };
}
