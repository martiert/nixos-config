self: super: {
  cnijfilter2 = super.cnijfilter2.overrideAttrs (new: oldAttrs: {
    patches = oldAttrs.patches ++ [
      ./cnijfilter2_include_stdlib.patch
    ];
  });
}
