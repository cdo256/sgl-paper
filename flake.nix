{
  description = "A Nix flake to build a LaTeX document using TeX Live and TikZ";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs"; # Use the latest Nixpkgs
    flake-utils.url = "github:numtide/flake-utils"; # Utility functions for flakes
    #lipics.url = "github:cdo256/lipics-authors";
  };

  outputs = { self, nixpkgs, flake-utils }: 
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
      let 
        pkgs = import nixpkgs { inherit system; };
        lipicsPkg = pkgs.stdenv.mkDerivation {
          name = "lipics";
          pname = "lipics";
          src = ./lipics;
          outputs = [ "out" "tex" ];
          #nativeBuildInputs = [ lipicsTexlive ];
          installPhase = ''
            mkdir -p $out/share/texmf/tex/latex/lipics/
            mkdir -p $tex/tex/latex/lipics/
            cp *.cls $out/share/texmf/tex/latex/lipics/
            cp *.cls $tex/tex/latex/lipics/
          '';
        };
        texliveBundle = pkgs.texliveFull.withPackages (ps: [
          ps.latexmk
          #ps.pgf # TikZ
          #pkgs.inkscape
          #ps.luatex
          lipicsPkg
        ]);
        #fucker = 
        #    pkgs.texlive.combine {
        #      inherit (pkgs.texlive) scheme-full;
        #      inherit (lipics.packages."x86_64-linux") default;
        #    };
      in
      {
        packages.default = pkgs.stdenv.mkDerivation {
          name = "build-paper";
          src = ./.;
          
          nativeBuildInputs = [
            #texlive
            ##pkgs.texlivePackages.latexmk
	    #lipics.packages.${system}.default
            texliveBundle
          ];

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
