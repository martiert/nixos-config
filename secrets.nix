let
  moridin = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDczcJT6Dw1drNAjK9AeehtE+UUfVPJp/3ud2RESyEZ6 root@moridin";
  perrin = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJBGRf2h4CTeeSWRsozsKAJOstTDNi06NXe/n+GAkQ/K root@Perrin";
  aginor = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMRjg84Y2jgL/qFgc0BPnZvjLkN/fnsDTdLyFfbK+KmZ root@Aginor";
  moghedien = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAlDQcKcShLLVDXOLzzHKx7D6gNetKxC2nL7nFz6SWtu root@moghedien";
  mattrim = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB0jcSi9N1xUK9BHLthykIgI8Wj8/yFdMLdqk5KwL1Hp root@mattrim";

  octoprint = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKU1fdUX2EF8GAH6e6K9gp42XgBjhtrUNYz6kKfHwPpD root@octoprint";
  pihole = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMizRj3YEyAbCL3T9S8Fa2IvSN2Ia/U1hD2ItEzALhZI root@pihole";
  tmate = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBtQnvgjC+fwdv9mLJiWa+PrapWmFvOidO0pxVUPnPm5 root@tmate";
  foundry = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILBSzOZjEk6huvgwj3K+ycCTgSBxYKaxQVHpLd/cRTwH root@foundry";

  editKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIElUoVKWA9hI7T4WIRZZfwZl8+u86/PsewtRJc25ZhKK martin@moridin"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAtv8ELid3Rl95HFtmE55gXyZiO0Hh3RNmwnDYVU2Szb martin@perrin"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKHTWbjpb92qz5YurxsbdV2PzjdN8TZh4S91AXqYCU1s martin@moghedien"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILuFi4JSDhCe/aqTxoL5zt8r45laYRq+kEvGNRDd8REW martin@aginor"
  ];
in {
  "secrets/wpa_supplicant_wired.age".publicKeys = [ perrin moridin ] ++ editKeys;
  "secrets/wpa_supplicant_wireless.age".publicKeys = [ moghedien octoprint ] ++ editKeys;
  "secrets/dns_servers.age".publicKeys = [ perrin moridin mattrim ] ++ editKeys;
}
