let
  moridin = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDczcJT6Dw1drNAjK9AeehtE+UUfVPJp/3ud2RESyEZ6 root@moridin";
  perrin = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJBGRf2h4CTeeSWRsozsKAJOstTDNi06NXe/n+GAkQ/K root@Perrin";
  aginor = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMRjg84Y2jgL/qFgc0BPnZvjLkN/fnsDTdLyFfbK+KmZ root@Aginor";
  moghedien = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAlDQcKcShLLVDXOLzzHKx7D6gNetKxC2nL7nFz6SWtu root@moghedien";

  editKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIElUoVKWA9hI7T4WIRZZfwZl8+u86/PsewtRJc25ZhKK martin@moridin"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAtv8ELid3Rl95HFtmE55gXyZiO0Hh3RNmwnDYVU2Szb martin@perrin"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKHTWbjpb92qz5YurxsbdV2PzjdN8TZh4S91AXqYCU1s martin@moghedien"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILuFi4JSDhCe/aqTxoL5zt8r45laYRq+kEvGNRDd8REW martin@aginor"
  ];
in {
  "secrets/wpa_supplicant_wired.age".publicKeys = [ perrin moridin ] ++ editKeys;
}
