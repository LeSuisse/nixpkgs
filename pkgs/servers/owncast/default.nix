{ lib, buildGoModule, fetchFromGitHub, fetchpatch, nixosTests, bash, which, ffmpeg, makeWrapper, coreutils, ... }:

buildGoModule rec {
  pname = "owncast";
  version = "0.0.12";

  src = fetchFromGitHub {
    owner = "owncast";
    repo = "owncast";
    rev = "v${version}";
    sha256 = "sha256-i/MxF+8ytpbVzGyRLbfHx7sR2bHEvAYdiwAc5TNrafc=";
  };

  vendorSha256 = "sha256-sQRNf+eT9JUbYne/3E9LoY0K+c7MlxtIbGmTa3VkHvI=";

  patches = [
    (fetchpatch {
      name = "CVE-2022-3751.patch";
      url = "https://github.com/owncast/owncast/commit/23b6e5868d5501726c27a3fabbecf49000968591.patch";
      sha256 = "sha256-OKa724B5Pe3JfpGDb7utvGf8HbVYApvoR602dhm4/1o=";
    })
  ];

  propagatedBuildInputs = [ ffmpeg ];

  nativeBuildInputs = [ makeWrapper ];

  preInstall = ''
    mkdir -p $out
    cp -r $src/{static,webroot} $out
  '';

  postInstall = let

    setupScript = ''
      [ ! -d "$PWD/webroot" ] && (
        ${coreutils}/bin/cp --no-preserve=mode -r "${placeholder "out"}/webroot" "$PWD"
      )

      [ ! -d "$PWD/static" ] && (
        [ -L "$PWD/static" ] && ${coreutils}/bin/rm "$PWD/static"
        ${coreutils}/bin/ln -s "${placeholder "out"}/static" "$PWD"
      )
    '';
  in ''
    wrapProgram $out/bin/owncast \
      --run '${setupScript}' \
      --prefix PATH : ${lib.makeBinPath [ bash which ffmpeg ]}
  '';

  installCheckPhase = ''
    runHook preCheck
    $out/bin/owncast --help
    runHook postCheck
  '';

  passthru.tests.owncast = nixosTests.testOwncast;

  meta = with lib; {
    description = "self-hosted video live streaming solution";
    homepage = "https://owncast.online";
    license = licenses.mit;
    platforms = platforms.unix;
    maintainers = with maintainers; [ MayNiklas ];
  };

}
