{ ... }:


{
  system = "x86_64-linux";
  in {
    martiert = {
      system.type = "laptop";
      i3.enable = true;
      terminal.fontSize = 14;
    };
  };
}
