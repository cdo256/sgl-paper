{
  description = "A Nix flake to build a LaTeX document using TeX Live and TikZ";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

  outputs = { self, nixpkgs }:
    let 
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      lipicsPkg = pkgs.stdenv.mkDerivation {
        name = "lipics";
        pname = "lipics";
        src = ./lipics;
        outputs = [ "out" "tex" ];
        installPhase = ''
          mkdir -p $out/share/texmf/tex/latex/lipics/
          mkdir -p $tex/tex/latex/lipics/
          cp *.cls $out/share/texmf/tex/latex/lipics/
          cp *.cls $tex/tex/latex/lipics/
        '';
      };
      texliveBundle = pkgs.texliveFull.withPackages (ps: [
        ps.latexmk
        lipicsPkg
      ]);
    in
    {
      packages.${system}.default = pkgs.stdenv.mkDerivation {
        name = "build-paper";
        src = ./.;
        nativeBuildInputs = [
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
    };
}
