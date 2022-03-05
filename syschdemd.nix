{ lib, pkgs, config, defaultUser, forwardEnv, ... }:

pkgs.substituteAll {
  name = "syschdemd";
  src = ./syschdemd.sh;
  dir = "bin";
  isExecutable = true;

  buildInputs = with pkgs; [ daemonize ];

  inherit (pkgs) daemonize;
  inherit defaultUser;
  inherit (config.security) wrapperDir;
  fsPackagesPath = lib.makeBinPath config.system.fsPackages;
  # There's a couple layers of indirection here. Expand each of `forwardEnv`
  # to a bash expression that itself will expand into a declaration of each
  # environment variable which is run within the user environment.
  #
  # Use a new-ish bash feature to expand a variable as a declaration that
  # properly escapes the value. i.e.:
  # ```
  # $ FOO="A'good\n@string.\$(that has issues expanding"
  # $ echo "${FOO@A}"
  # declare -x FOO='A'\''good\n@string.$(that has issues expanding'
  # ```
  setupScript = lib.concatStringsSep " "
    (map (e: "\${${e}+\${${e}@A};}") forwardEnv);
}
