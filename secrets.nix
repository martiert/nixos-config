let
  moridin = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDczcJT6Dw1drNAjK9AeehtE+UUfVPJp/3ud2RESyEZ6 root@moridin";
  perrin = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJBGRf2h4CTeeSWRsozsKAJOstTDNi06NXe/n+GAkQ/K root@Perrin";
  aginor = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMRjg84Y2jgL/qFgc0BPnZvjLkN/fnsDTdLyFfbK+KmZ root@Aginor";
  moghedien = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAlDQcKcShLLVDXOLzzHKx7D6gNetKxC2nL7nFz6SWtu root@moghedien";
  mattrim = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFeYhxfQEqydAEBn9Dw8REkAcBYLc7h+l7CW9QtLjDl+ root@mattrim";
  schnappi = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDA40XbaYVw5sQN25PuEnfahpb4OO3XChh53jk18zkIg root@schnappi";
  pinarello = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEzO9jNL7DNqmz5WPUWe+PceGFUxQV0svBo4uSiacr6b root@pinarello";

  octoprint = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJUplHY8ALir2FCM4dTQlH0L17dhkjxiNhq6p79h1nP5 root@octoprint";
  pihole = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMizRj3YEyAbCL3T9S8Fa2IvSN2Ia/U1hD2ItEzALhZI root@pihole";
  tmate = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBtQnvgjC+fwdv9mLJiWa+PrapWmFvOidO0pxVUPnPm5 root@tmate";
  foundry = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILBSzOZjEk6huvgwj3K+ycCTgSBxYKaxQVHpLd/cRTwH root@foundry";
  vpnrouter = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAPN3+YyY/rqzCAa8PZUf4au4ZkzG5QlN+TJQ8xxzxSe root@vpnrouter";

  editKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIElUoVKWA9hI7T4WIRZZfwZl8+u86/PsewtRJc25ZhKK martin@moridin"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAtv8ELid3Rl95HFtmE55gXyZiO0Hh3RNmwnDYVU2Szb martin@perrin"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKHTWbjpb92qz5YurxsbdV2PzjdN8TZh4S91AXqYCU1s martin@moghedien"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILuFi4JSDhCe/aqTxoL5zt8r45laYRq+kEvGNRDd8REW martin@aginor"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIRw8XCxKsXXpmEvWGdP/edHvfcNhRTnmj/rrdNp+cqM martin@schnappi"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJVZ0SDtC9spMJSAvPyhTfemoqBM3BWstsp5HxmWvXUI martin@pinarello"
  ];
in {
  "secrets/wpa_supplicant_wired.age".publicKeys = [ perrin moridin ] ++ editKeys;
  "secrets/wpa_supplicant_wireless.age".publicKeys = [ moghedien octoprint schnappi pinarello ] ++ editKeys;
  "secrets/dns_servers.age".publicKeys = [ perrin moridin ] ++ editKeys;
  "secrets/citrix.age".publicKeys = [ perrin aginor ] ++ editKeys;
  "secrets/mattrim_dropbear_key.age".publicKeys = [ mattrim ] ++ editKeys;
  "secrets/vpn_passphrase.age".publicKeys = [ vpnrouter ] ++ editKeys;
  "secrets/nordvpn_credentials.age".publicKeys = [ vpnrouter ] ++ editKeys;
}
