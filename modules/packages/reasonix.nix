{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "reasonix";
  version = "1.6.0";

  src = fetchFromGitHub {
    owner = "esengine";
    repo = "DeepSeek-Reasonix";
    rev = "v${version}";
    hash = "sha256-R0rAhFRfxAtSxMitYBMpDUMNyZJv0byrAxbXPSiu0fY=";
  };

  vendorHash = "sha256-s5NxBvW86H0oECTL+YDmfeELmIIZ5UvQwyWRb2qicIE=";

  subPackages = [ "cmd/reasonix" ];

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${version}"
  ];

  env = {
    CGO_ENABLED = "0";
    GOTOOLCHAIN = "local";
  };

  meta = with lib; {
    description = "DeepSeek-native AI coding agent for your terminal";
    homepage = "https://github.com/esengine/DeepSeek-Reasonix";
    license = licenses.mit;
    mainProgram = "reasonix";
    platforms = platforms.linux ++ platforms.darwin;
  };
}
