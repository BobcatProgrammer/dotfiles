{ config, pkgs, omp, ... }:

{
  imports = [
    omp.homeManagerModules.default
  ];

  programs.omp = {
    enable = true;
    settings = {
      startup.quiet = true;
    };
  };
}
