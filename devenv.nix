{ pkgs, lib, config, inputs, ... }:

{
  # https://devenv.sh/basics/
  env.GREET = "devenv";
  env.PGDATABASE = "postgres";

  # https://devenv.sh/packages/
  packages = [ pkgs.git pkgs.sqlpage pkgs.docker pkgs.postgresql.pg_config ]; # pkgs.ollama ];

  # https://devenv.sh/languages/
  # languages.rust.enable = true;

  # https://devenv.sh/processes/
  # processes.cargo-watch.exec = "cargo-watch";

  # https://devenv.sh/services/
  services.postgres.enable = true;
  services.postgres.extensions = exts: [ exts.anonymizer exts.pg_net ];
  services.postgres.package = pkgs.postgresql_18;
  services.postgres.initialDatabases = [ { name = "postgres"; } ];
  services.postgres.settings = {
      shared_preload_libraries = "pg_net";
  };

  processes = {
    ollama.exec = ''
      ollama serve
    '';
    sqlpage.exec = ''
        ${pkgs.sqlpage}/bin/sqlpage \
            --web-root sqlpage/pages \
            --config-dir sqlpage
     '';
  };

  # https://devenv.sh/scripts/
  scripts.hello.exec = ''
    echo hello from $GREET
  '';

  enterShell = ''
    hello
    git --version
  '';

  # https://devenv.sh/tasks/
  # tasks = {
  #   "myproj:setup".exec = "mytool build";
  #   "devenv:enterShell".after = [ "myproj:setup" ];
  # };

  # https://devenv.sh/tests/
  enterTest = ''
    echo "Running tests"
    git --version | grep --color=auto "${pkgs.git.version}"
  '';

  # https://devenv.sh/git-hooks/
  # git-hooks.hooks.shellcheck.enable = true;

  # See full reference at https://devenv.sh/reference/options/
}
