# TODO rename to more generic variables
{ users, key }:

builtins.catAttrs key (builtins.attrValues users)
