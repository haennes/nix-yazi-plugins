{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation {
  pname = "yaziPlugins-fg";
  version = "2024-11-09";

  src = fetchFromGitHub {
    owner = "lpnh";
    repo = "fg.yazi";
    rev = "9bba7430dbcd30995deea600499b069fe6067a3e";
    sha256 = "sha256-3VjTL/q4gSDIHyPXwUIQA/26bbhWya+01EZbxSKzzQo=";
  };

  buildPhase = ''
    mkdir $out
    cp $src/* $out
  '';

  meta = with lib; {
    description = "A Yazi plugin for searching by file content or by filenames using ripgrep or ripgrep-all with fzf preview.";
    homepage = "https://github.com/lpnh/fg.yazi";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.all;
  };
}
