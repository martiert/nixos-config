{ pkgs, ... }:

let
  securityHeaders = ''
    map $scheme $hsts_header {
      https   "max-age=31536000; includeSubdomains; preload";
    }

    add_header Strict-Transport-Security $hsts_header;

    # Minimize information leaked to other domains
    add_header Referrer-Policy strict-origin;

    # Prevent injection of code in other mime types (XSS Attacks)
    add_header X-Content-Type-Options nosniff;

    # Enable XSS protection of the browser.
    # May be unnecessary when CSP is configured properly (see above)
    add_header X-XSS-Protection "1; mode=block";

    # Remove all permissions
    add_header Permissions-Policy "fullscreen=(), geolocation=()";

    # Enable CSP for your services.
    add_header Content-Security-Policy "script-src 'self' https: 'unsafe-inline' 'unsafe-eval'";
  '';
in {
  users.users.foundry= {
    isSystemUser = true;
    group = "foundry";
  };
  users.groups.foundry = {};

  systemd.services.foundryvtt = {
    enable = true;
    description = "FoundryVTT server";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.nodejs}/bin/node /var/lib/foundry/foundryvtt/resources/app/main.js --dataPath=/var/lib/foundry/foundrydata";
      Restart = "on-failure";
      User = "foundry";
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];

  services.nginx = {
    enable = true;

    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    commonHttpConfig = securityHeaders;

    virtualHosts."foundry.martiert.com" = {
      forceSSL = true;
      enableACME = true;
      http2 = true;

      locations."/" = {
        proxyWebsockets = true;
        proxyPass = "http://localhost:3000";
      };
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "martiert@gmail.com";
  };
}
