enum GearSlot { weapon, armor }

/// A piece of equipment. Weapons use dmgMin/dmgMax; armor uses `armor`, a flat
/// reduction applied to every hit the player takes.
class Gear {
  final String id, name, blurb;
  final GearSlot slot;
  final int cost, dmgMin, dmgMax, armor;
  final bool craft; // true = can only be crafted, never bought
  const Gear({
    required this.id,
    required this.name,
    required this.slot,
    required this.cost,
    this.dmgMin = 0,
    this.dmgMax = 0,
    this.armor = 0,
    this.blurb = '',
    this.craft = false,
  });
}

const gearCatalog = <Gear>[
  Gear(id: 'pipe', name: 'RUSTED PIPE', slot: GearSlot.weapon, cost: 0,
      dmgMin: 10, dmgMax: 14, blurb: 'Heavy, reliable, ugly.'),
  Gear(id: 'machete', name: 'SCRAP MACHETE', slot: GearSlot.weapon, cost: 90,
      dmgMin: 13, dmgMax: 18, blurb: 'Sharpened sheet metal.'),
  Gear(id: 'rifle', name: 'PIPE RIFLE', slot: GearSlot.weapon, cost: 220,
      dmgMin: 17, dmgMax: 24, blurb: 'Loud, crude, effective.'),
  Gear(id: 'cutter', name: 'PLASMA CUTTER', slot: GearSlot.weapon, cost: 450,
      dmgMin: 22, dmgMax: 30, blurb: 'Salvaged industrial tool.'),
  Gear(id: 'rpipe', name: 'REINFORCED PIPE', slot: GearSlot.weapon, cost: 60,
      dmgMin: 13, dmgMax: 17, blurb: 'Pipe wrapped in steel plate.', craft: true),
  Gear(id: 'plating', name: 'SCRAP PLATING', slot: GearSlot.armor, cost: 140,
      armor: 3, blurb: 'Welded plates over padding.', craft: true),
  Gear(id: 'vest', name: 'SCRAP VEST', slot: GearSlot.armor, cost: 70,
      armor: 1, blurb: 'Bolted-together plates.'),
  Gear(id: 'jacket', name: 'PLATED JACKET', slot: GearSlot.armor, cost: 160,
      armor: 2, blurb: 'Leather over road signs.'),
  Gear(id: 'riot', name: 'RIOT GEAR', slot: GearSlot.armor, cost: 380,
      armor: 4, blurb: 'Pre-collapse police issue.'),
];

Gear gearById(String id) => gearCatalog.firstWhere((g) => g.id == id);
