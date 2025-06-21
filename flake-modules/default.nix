{
  flake-parts-lib,
  ...
}:
let
  inherit (flake-parts-lib) mkPerSystemOption;
in
{
  self,
  ...
}:
{
  options.perSystem = mkPerSystemOption (_: {
    pre-commit = {
      settings = {
        src = self.outPath;
        hooks = {
          deadnix.enable = true;
          editorconfig-checker.enable = true;
          end-of-file-fixer.enable = true;
          nixfmt-rfc-style.enable = true;
          markdownlint.enable = true;
          prettier = {
            enable = true;
            excludes = [ "flake.lock" ];
          };
          shellcheck = {
            enable = true;
            excludes = [ ".envrc" ];
          };
          statix.enable = true;
          trim-trailing-whitespace.enable = true;
        };
      };
    };

  });
}
