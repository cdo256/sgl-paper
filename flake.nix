{
  description = "A Nix flake to build a LaTeX document using TeX Live and TikZ";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs"; # Use the latest Nixpkgs
    flake-utils.url = "github:numtide/flake-utils"; # Utility functions for flakes
    lipics.url = "github:cdo256/lipics-authors";
  };

  outputs = { self, nixpkgs, flake-utils, lipics }: 
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
      let 
        pkgs = import nixpkgs { inherit system; };
        texlive = pkgs.texliveFull.withPackages (ps: [
          ps.latexmk
          ps.pgf # TikZ
          pkgs.inkscape
          #ps.luatex
          lipics.packages.${system}.default
        ]);
      in
      {
        packages.devShell = pkgs.stdenv.mkShell {
          nativeBuildInputs = [ 
            pkgs.gnumake
            texlive
          ];
        };
        packages.default = pkgs.stdenv.mkDerivation {
          name = "build-paper";
          src = ./.;
          
          nativeBuildInputs = [ texlive ];

          buildPhase = ''
            export XDG_CACHE_HOME=$(mktemp -d)
            latexmk -pdf --shell-escape paper.tex
          '';

          installPhase = ''
            mkdir -p $out
            cp paper.pdf $out/
          '';
        };
      });
}
