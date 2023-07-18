{ pkgs, lib, config, ...}:

let
  tables = config.martiert.networking.tables;

  createTableEntry = name: data: (toString data.number) + " ${name}";
  makeIfCheck = command: ''
      if out=$(${command} 2>&1); then
        echo "done"
      elif ! echo "$out" | grep "File exists" >/dev/null 2>&1; then
        echo "'${command}' failed: $out"
        exit 1
      fi
    '';
  createRule = table: type: rule: if rule != null then 
    (makeIfCheck "ip rule add ${type} ${rule} table ${table}")
    else "";
  createRules = table: rule: builtins.concatStringsSep "\n" (lib.mapAttrsToList (createRule table) rule);
  createRuleFromData = table: data: builtins.concatStringsSep "\n" (map (createRules table) data.rules);
  rules = builtins.concatStringsSep "\n" (lib.mapAttrsToList createRuleFromData tables);

  createRoutes = table: name: route: makeIfCheck "ip route add ${name} ${route.value} table ${table}";
  createRoutesFromTable = table: data: builtins.concatStringsSep "\n" (lib.mapAttrsToList (createRoutes table) data.routes);
  routes = builtins.concatStringsSep "\n" (lib.mapAttrsToList createRoutesFromTable tables);

  waitForDefaultRoute = ''
    set +e
    for i in {0..30}
    do
      ip route | grep --quiet default
      [ $? -eq 0 ] && break
      sleep 1
    done
  '';

  script = builtins.concatStringsSep "\n" [ rules routes ];
in {
  networking.iproute2 = {
    enable = true;
    rttablesExtraConfig = builtins.concatStringsSep "\n" (lib.mapAttrsToList createTableEntry tables) + "\n";
  };

  systemd.services.waitForDefaultRoute = {
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    script = waitForDefaultRoute;
    path = [ pkgs.iproute2 ];

    serviceConfig = {
      Type = "oneshot";
    };
  };

  systemd.services.setuptables = {
    after = [ "waitForDefaultRoute.service" ];
    wantedBy = [ "multi-user.target" ];
    script = script;
    path = [ pkgs.iproute2 ];

    serviceConfig = {
      Type = "oneshot";
    };
  };
}
