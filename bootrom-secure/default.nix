let
  pinnedPkgs = builtins.fetchTarball {
    name = "nixpkgs";
    url = https://releases.nixos.org/nixos/unstable/nixos-19.03pre170194.2a81eceeba6/nixexprs.tar.xz;
    sha256 = "1yrm6d4y5h2hnxlln8jjx3r8fbmkpbkjavjrw5ps61yzzcjr95p3";
  };
  pkgs = import pinnedPkgs {};
  saw-script = if builtins.currentSystem == "x86_64-darwin" then
    pkgs.stdenv.mkDerivation {
      name = "saw-script";
      version = "0.2-2019-01-29";
      system = "x86_64-darwin";
      src = pkgs.fetchurl {
        url = https://saw.galois.com/builds/nightly/saw-0.2-2019-01-29-MacOSX-64.tar.gz;
        sha256 = "0wfzrg1idkpj1c2f8gm68hfxj4iw85f7gnya67zl5rwflw798nwn";
      };
      installPhase = ''
        mkdir -p $out
        cp -r * $out
      '';
    }
  else
    pkgs.stdenv.mkDerivation {
      name = "saw-script";
      version = "0.2-2019-01-29";
      system = "x86_64-linux";
      dontStrip = true;
      nativeBuildInputs = [ pkgs.autoPatchelfHook ];
      buildInputs = [
        pkgs.gmp
        pkgs.ncurses5
        pkgs.zlib
      ];
      src = pkgs.fetchurl {
        url = https://saw.galois.com/builds/nightly/saw-0.2-2019-01-29-Ubuntu14.04-64.tar.gz;
        sha256 = "1gr5kcya2cy1iwpir8zl7f0w0s04cyvm7kldyrx55r26pfp85i1c";
      };
      installPhase = ''
        mkdir -p $out
        cp -r * $out
      '';
    }
  ;
in with pkgs;
mkShell {
  buildInputs = [
    clang_6
    gnumake
    llvm_6
    python27
    python36Packages.yapf
    saw-script
    yices
    z3
    dtc
    (let
       riscv-toolchain-ver = "7.2.0";
       arch = "rv64imac";
       bits =
         if builtins.substring 0 4 arch == "rv32" then "32"
         else if builtins.substring 0 4 arch == "rv64" then "64"
         else abort "failed to recognize bit with of riscv architecture ${arch}";
     in stdenv.mkDerivation rec {
       name    = "riscv-${arch}-toolchain-${version}";
       version = "${riscv-toolchain-ver}-${builtins.substring 0 7 src.rev}";
       src     = fetchFromGitHub {
         owner  = "riscv";
         repo   = "riscv-gnu-toolchain";
         rev    = "64879b24e18572a3d67aa4268477946ddb248006";
         sha256 = "0pd94vz2ksbrl7v64h32y9n89x2b75da03kj1qcxl2z8wrfi107b";
         fetchSubmodules = true;
       };
       configureFlags   = [ "--with-arch=${arch}" ];
       installPhase     = ":"; # 'make' installs on its own
       hardeningDisable = [ "all" ];
       enableParallelBuilding = true;
       # Stripping/fixups break the resulting libgcc.a archives, somehow.
       # Maybe something in stdenv that does this...
       dontStrip = true;
       dontFixup = true;
       nativeBuildInputs = [ curl gawk texinfo bison flex gperf ];
       buildInputs = [ libmpc mpfr gmp expat ];
       inherit arch;
       triple = "riscv${bits}-unknown-elf";
     })
  ];
}
