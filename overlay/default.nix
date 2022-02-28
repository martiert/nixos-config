{ cisco
, vysor
, martiert
, system
}:

self: super: {
  vysor = super.callPackage vysor {};
  teamctl = cisco.outputs.packages."${system}".teamctl;
  roomctl = cisco.outputs.packages."${system}".roomctl;
  projecteur = martiert.outputs.packages."${system}".projecteur;
  mutt-ics = martiert.outputs.packages."${system}".mutt-ics;
  generate_ssh_key = martiert.outputs.packages."${system}".generate_ssh_key;
}
