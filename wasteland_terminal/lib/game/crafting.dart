enum RecipeKind { stimpack, lockpicks, kit, gear }

/// Something you can build at the workshop from parts and scrap.
/// Better recipes need a higher Engineering skill, which grows by crafting
/// and repairing.
class Recipe {
  final String id, name, desc;
  final int parts, scrap, minEng, amount;
  final RecipeKind kind;
  final String? gearId;
  const Recipe({
    required this.id,
    required this.name,
    required this.desc,
    required this.parts,
    required this.scrap,
    required this.kind,
    this.minEng = 0,
    this.amount = 1,
    this.gearId,
  });
}

const recipes = <Recipe>[
  Recipe(id: 'stim', name: 'STIMPACK', desc: 'HEALS WHEN USED',
      parts: 2, scrap: 8, kind: RecipeKind.stimpack),
  Recipe(id: 'picks', name: 'LOCKPICK x2', desc: 'TWO FRESH PICKS',
      parts: 1, scrap: 5, kind: RecipeKind.lockpicks, amount: 2),
  Recipe(id: 'kit', name: 'REPAIR KIT', desc: 'RESTORES 40 DURABILITY',
      parts: 3, scrap: 10, minEng: 1, kind: RecipeKind.kit),
  Recipe(id: 'rpipe', name: 'REINFORCED PIPE', desc: 'WEAPON, DMG 13-17',
      parts: 6, scrap: 40, minEng: 2, kind: RecipeKind.gear, gearId: 'rpipe'),
  Recipe(id: 'plating', name: 'SCRAP PLATING', desc: 'ARMOR 3',
      parts: 8, scrap: 60, minEng: 3, kind: RecipeKind.gear, gearId: 'plating'),
];
