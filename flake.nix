{
  description = "A Nix flake to build a LaTeX document using TeX Live and TikZ";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs"; # Use the latest Nixpkgs
    flake-utils.url = "github:numtide/flake-utils"; # Utility functions for flakes
  };

  outputs = { self, nixpkgs, flake-utils }: 
    flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" ] (system:
      let 
        pkgs = import nixpkgs { inherit system; };
        texlive = pkgs.texlive.combine {
          inherit (pkgs.texlive) scheme-small; # Base scheme
          # Add any additional packages you need here
          extraPackages = with pkgs.texlive; [ tikz ];
        };
      in
      {
        packages.default = pkgs.stdenv.mkDerivation {
          name = "build-paper";
          src = ./.;
          
          buildInputs = [ texlive ];

          buildPhase = ''
            latexmk -pdf paper.tex
          '';

          installPhase = ''
            mkdir -p $out
            cp paper.pdf $out/
          '';
        };
      });
}