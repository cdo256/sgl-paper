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
        texlivePackages = pkgs.texlive.combine {
          inherit (pkgs.texlive) scheme-full;
          packages = [ lipics.packages.${system}.default ];
        };
      in
      {
        packages.devShell = pkgs.stdenv.mkShell {
          nativeBuildInputs = [ 
            pkgs.gnumake
            texlivePackages
          ];
        };
        packages.default = pkgs.stdenv.mkDerivation {
          name = "build-paper";
          src = ./.;
          
          nativeBuildInputs = [
            texlivePackages
          ];

          buildPhase = ''
            export XDG_CACHE_HOME=$(mktemp -d)
            pdflatex paper.tex
            #latexmk -pdf --shell-escape paper.tex
          '';

          installPhase = ''
            mkdir -p $out
            cp paper.pdf $out/
          '';
        };
      });
}
