{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    sbcl
    rlwrap
  ];

  home.activation.bootstrapQuicklisp = config.lib.dag.entryAfter ["writeBoundary"] ''
    if [ ! -d "$HOME/quicklisp" ]; then
      $DRY_RUN_CMD ${pkgs.curl}/bin/curl -sSLO https://beta.quicklisp.org/quicklisp.lisp
      $DRY_RUN_CMD ${pkgs.sbcl}/bin/sbcl --noinform \
        --load quicklisp.lisp \
        --eval '(quicklisp-quickstart:install)' \
        --eval '(ql:add-to-init-file)' \
        --eval '(quit)' \
        > /dev/null 2>&1
      $DRY_RUN_CMD rm -f quicklisp.lisp
    fi
  '';
}
