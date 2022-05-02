{ config, pkgs, lib, ... }:

with lib;

let
  hstsConfig = ''
    add_header Strict-Transport-Security $hsts_header;

    # Enable CSP for your services.
    #add_header Content-Security-Policy "script-src 'self'; object-src 'none'; base-uri 'none';" always;

    # Minimize information leaked to other domains
    add_header 'Referrer-Policy' 'origin-when-cross-origin';

    # Disable embedding as a frame
    add_header X-Frame-Options DENY;

    # Prevent injection of code in other mime types (XSS Attacks)
    add_header X-Content-Type-Options nosniff;

    # Enable XSS protection of the browser.
    # May be unnecessary when CSP is configured properly (see above)
    add_header X-XSS-Protection "1; mode=block";

    # This might create errors
    proxy_cookie_path / "/; secure; HttpOnly; SameSite=strict";
  '';
  authConfig = ''
    auth_request /oauth2/auth;

    auth_request_set $user  $upstream_http_x_auth_request_user;
    auth_request_set $email $upstream_http_x_auth_request_email;

    proxy_set_header X-User  $user;
    proxy_set_header X-Email $email;

    auth_request_set $auth_cookie $upstream_http_cookie;
    add_header Set-Cookie $auth_cookie;
  '';
in
{
  config = {
    users.users.oauth2_proxy.group = "oauth2_proxy";
    users.groups.oauth2_proxy = {};

    services.oauth2_proxy = {
      enable = true;

      clientID = "Training";
      clientSecret = "gvx7qenSX4Mfcx4TT1y";
      provider = "oidc";
      scope = "openid email";
      profileURL = "https://cloudsso.cisco.com/idp/userinfo.openid";
      extraConfig = {
        "oidc-issuer-url" = "https://cloudsso.cisco.com";
      };

      setXauthrequest = true;
      reverseProxy = true;

      cookie = {
        domain = "training.martiert.com";
        secret = "f.rTbWTR4RyhyZd3!c6xKk8DCRuo7wyb";
        secure = true;
        httpOnly = true;
      };
      email.domains = [ "cisco.com" ];
    };

    services.nginx = {
      enable = true;

      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      commonHttpConfig = ''
        # Add HSTS header with preloading to HTTPS requests.
        # Adding this header to HTTP requests is discouraged
          map $scheme $hsts_header {
            https   "max-age=31536000; includeSubdomains; preload";
          }
      '';

      virtualHosts."home.martiert.com" = {
        forceSSL = true;
        enableACME = true;

        extraConfig = hstsConfig;

        locations."/" = {
          root = "/var/www/home.martiert.com";
          index = "index.html";
        };
      };

      virtualHosts."training.martiert.com" = {
        forceSSL = true;
        enableACME = true;
        http2 = true;

        extraConfig = ''
          error_page 401 = "@signin";
        '';


        locations = {
          "/" = {
            extraConfig = authConfig;
            proxyWebsockets = true;
            proxyPass = "http://127.0.0.1:3000";
          };

          "/api/v1" = {
            extraConfig = ''
              rewrite /api/v1/?(.*) /$1 break;
            '' + authConfig;
            proxyPass = "http://127.0.0.1:2222";
          };

          "/oauth2/" = {
            proxyPass = "http://127.0.0.1:4180";
            extraConfig = ''
              proxy_set_header X-Scheme                 $scheme;
              proxy_set_header X-Auth-Request-Redirect  $scheme://$host$request_uri;
            '';
          };

          "@signin" = {
            extraConfig = ''
              internal;
            '';

            return = "307 $scheme://$host/oauth2/start";
          };

          "/oauth2/auth" = {
            proxyPass = "http://127.0.0.1:4180";
            extraConfig = ''
              internal;
              proxy_set_header X-Scheme                 $scheme;
              proxy_set_header X-Auth-Request-Redirect  $scheme://$host$request_uri;
              proxy_set_header Content-Length           "";
              proxy_pass_request_body off;
            '';
          };
        };
      };

      virtualHosts."bedlevel.martiert.com" = {
        forceSSL = true;
        enableACME = true;

        extraConfig = ''
            proxy_connect_timeout 1h;
            proxy_send_timeout    1h;
            proxy_read_timeout    1h;
          '' + hstsConfig;

        locations."/" = {
          root = "/var/www/bedlevel.martiert.com";
          index = "index.html";
        };

        locations."/api/v1" = {
          extraConfig = ''
            rewrite /api/v1/?(.*) /$1 break;
          '';
          proxyPass = "http://192.168.1.226:3001";
        };
      };

      virtualHosts."octoprint.martiert.com" = {
        forceSSL = true;
        enableACME = true;

        extraConfig = hstsConfig;

        locations."/" = {
          proxyPass = "http://192.168.1.226:5000";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_set_header X-Scheme $scheme;
            proxy_pass_request_headers on;
          '';
        };

        locations."/webcam" = {
          proxyPass = "http://192.168.1.226:8080";
          extraConfig = ''
            rewrite /webcam/?(.*) /$1 break;
            proxy_pass_request_headers on;
          '';

        };
      };
    };

    security.acme = {
      acceptTerms = true;
      defaults.email = "martiert@gmail.com";
    };

    networking.firewall.allowedTCPPorts = [ 80 443 ];
  };
}
